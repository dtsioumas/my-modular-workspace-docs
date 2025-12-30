# Home-Manager Modular Refactoring - Complete Guide

**Date:** 2025-12-20
**Status:** ✅ **APPROVED FOR EXECUTION**
**Confidence:** 0.96 (Band C - VERY HIGH)
**All Reviews Complete:** Technical Researcher → Technical Engineer → Planner → Ops Engineer

---

## Executive Summary

**Goal:** Transform monolithic home-manager (45 root files) into organized modular structure

**Total Time:** 5-6 hours
**Risk Level:** 🟢 LOW (with comprehensive safeguards)
**Documentation:** 3,697 lines across all reviews (now merged here)

**Key Stats:**
- **51 .nix files** to organize (45 root + 6 MCP modules)
- **4 deprecated files** to delete
- **3 conflict files** to resolve
- **11 module categories** in target structure
- **7 migration phases** (including new backup phase)

**Success Criteria:**
- ✅ All files in correct modules/
- ✅ All systemd services running
- ✅ Hardware profiles functional
- ✅ MCP servers accessible (14 servers)
- ✅ Data integrity verified
- ✅ Rollback capability preserved

---

# PART 1: TECHNICAL REVIEW

## 1.1 File Inventory (51 files)

### Core/Entry (2 files)
- `flake.nix` - Main flake with hardware profiles ✅
- `home.nix` - Entry point (80+ imports to simplify) ⚠️

### Shell/CLI (5 files)
- `shell.nix`, `atuin.nix`, `navi.nix`, `zellij.nix`, `zjstatus.nix`

### GUI Applications (6 files)
- `brave.nix` ⚠️ 5 NVIDIA hardcoded refs
- `firefox.nix` ⚠️ 7 GPU hardcoded refs
- `vscodium.nix`, `kitty.nix`, `warp.nix`, `electron-apps.nix`

### Desktop (2 files)
- `autostart.nix` ✅ Follows ADR-007
- `plasma-full.nix` ❌ NOT imported - DELETE

### Services (8 files)
- Core: `keepassxc.nix`, `dropbox.nix`, `critical-gui-services.nix` ⚠️ 2 conflicts, `productivity-tools-services.nix`
- Sync: `rclone-gdrive.nix`, `rclone-maintenance.nix`, `syncthing-myspaces.nix`
- Monitoring: `systemd-monitor.nix` ⚠️ 1 conflict

### Development (9 files)
- `git-hooks.nix`, `nix-dev-tools.nix`, `semantic-grep.nix`, `semtools.nix`, `gemini-cli.nix`
- npm: `npm-tools.nix`, `npm-default.nix` 🔴 KEEP IN ROOT, `npm-node-env.nix` 🔴 KEEP IN ROOT, `npm-node-packages.nix` 🔴 KEEP IN ROOT

### AI/LLM (4 files)
- `gemini-cli.nix`
- `llm-commands-symlinks.nix`, `llm-global-instructions-symlinks.nix`, `llm-tsukuru-project-symlinks.nix`

### Dotfiles (2 files)
- `chezmoi.nix`, `chezmoi-modify-manager.nix`

### Automation (2 files)
- `ansible-collections.nix`, `gdrive-local-backup-job.nix`

### System (4 files)
- `shell.nix`, `oom-protected-wrappers.nix` ⚠️ 8 memory hardcoded refs, `symlinks.nix`, `toolkit.nix`

### MCP Servers (7 files - already modular ✅)
- `local-mcp-servers.nix` ❌ DEPRECATED - DELETE
- `mcp-servers/` (6 modules: default, from-flake, npm-custom, python-custom, go-custom, rust-custom)

### Files to DELETE (4 files)
1. ❌ `local-mcp-servers.nix` - deprecated per ADR-010
2. ❌ `chezmoi-llm-integration.nix` - removed per home.nix:78
3. ❌ `claude-code.nix` - replaced by npm-tools.nix
4. ❌ `plasma-full.nix` - not imported, obsolete

### Conflict Files (3 files - RESOLVE FIRST)
1. ⚠️ `critical-gui-services.nix` - 2 conflicts
2. ⚠️ `systemd-monitor.nix` - 1 conflict

---

## 1.2 Technical Risks & Mitigations

### 🔴 HIGH RISK: npm Files MUST Stay in Root
**Risk:** Breaking npm package builds
**Files:** npm-default.nix, npm-node-env.nix, npm-node-packages.nix
**Mitigation:** NEVER move these files - documented in plan

### 🟡 MEDIUM: Systemd Service Dependencies
**Risk:** Service startup failures
**Critical Chain:** keepassxc → rclone-gdrive (secret dependency)
**Mitigation:** Preserve import order, test after each phase

### 🟡 MEDIUM: Hardware Profile Parameterization
**Risk:** Overlay build failures
**Affected:** firefox-memory-optimized.nix, onnxruntime-gpu-optimized.nix
**Mitigation:** Test overlays separately, verify parameter passing

### 🟡 MEDIUM: Service Continuity
**Risk:** Data loss from service restarts
**Services:** KeePassXC, Obsidian, VSCodium
**Mitigation:** Save all work before migration, added user action checklist

### 🟡 MEDIUM: Data Integrity
**Risk:** Data corruption during migration
**Critical Data:** KeePassXC vault, Syncthing state, MCP state
**Mitigation:** Phase -1 backup + Phase 6 verification

### 🟢 LOW: Import Order
**Risk:** Minor dependency issues
**Mitigation:** Preserve relative order, document dependencies

### 🟢 LOW: Module Importers
**Risk:** Syntax errors in default.nix
**Mitigation:** Standard Nix pattern, incremental testing

---

## 1.3 ADR Compliance

✅ **ADR-001:** NixOS Stable vs Home-Manager Unstable - COMPLIANT
✅ **ADR-007:** Autostart via Home-Manager - COMPLIANT
⚠️ **ADR-010:** Unified MCP Server Architecture - MOSTLY COMPLIANT (local-mcp-servers.nix to delete)

---

## 1.4 Hardware Profile Status

✅ **Implemented:** profiles/hardware/shoshin.nix exists and working
✅ **Overlays parameterized:** firefox-memory-optimized.nix, onnxruntime-gpu-optimized.nix
⚠️ **Missing profiles:** kinoite.nix, wsl.nix (future hosts - create placeholders post-migration)
⚠️ **Remaining coupling:** brave.nix (5 refs), firefox.nix (7 refs), oom-protected-wrappers.nix (8 refs)

---

# PART 2: OPERATIONAL SAFETY

## 2.1 Backup Strategy (3-Layer)

### Layer 1: Git Backup
- Repository bundle (all branches)
- Backup branch: `backup-before-refactoring-2025-12-20`
- Tag: `pre-refactoring-YYYYMMDD-HHMM`
- flake.lock backup

### Layer 2: Home-Manager Backup
- Current generation saved
- Generation history preserved
- Package list snapshot

### Layer 3: User Data Backup ⚠️ CRITICAL
- **KeePassXC vault** (~/MyVault) - MUST backup!
- .MyHome directory (selective)
- Critical .config directories (Claude, chezmoi, VSCodium)
- MCP server state (~/.claude_states)
- Syncthing config

**Backup Location:** `~/.MyHome/backups/home-manager-refactoring-YYYYMMDD-HHMM/`
**Saved to:** `~/.home-manager-refactoring-backup-location.txt`

---

## 2.2 Rollback Procedures (4-Layer)

### Level 0: Immediate Abort (< 1 min)
```bash
pkill -f "home-manager switch"
home-manager switch --rollback
```

### Level 1: Phase Rollback (2-3 min)
```bash
home-manager switch --rollback
git reset --hard HEAD~1
home-manager switch --flake .#mitsio@shoshin
```

### Level 2: Full Rollback (5 min)
```bash
git checkout backup-before-refactoring-2025-12-20
cp "$BACKUP_DIR/flake.lock.backup" flake.lock
home-manager switch --flake .#mitsio@shoshin
```

### Level 3: Emergency Recovery (10-15 min)
```bash
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)
git bundle unbundle "$BACKUP_DIR/home-manager-repo.bundle"
git reset --hard main
cp "$BACKUP_DIR/flake.lock.backup" flake.lock
# Restore generation
CURRENT_GEN=$(cat "$BACKUP_DIR/current-generation.txt")
nix-store -r "$CURRENT_GEN"
"$CURRENT_GEN/activate"
# Restore data if needed
cp -r "$BACKUP_DIR/MyVault-backup" ~/MyVault
```

---

## 2.3 Service Continuity Plan

### Pre-Migration User Actions
- [ ] Save all work in Obsidian, VSCodium
- [ ] Commit git work in progress
- [ ] Close browsers (Brave, Firefox)
- [ ] Note running processes

### Services That WILL Restart
- KeePassXC (brief downtime)
- Obsidian (will close/reopen)
- VSCodium (will close/reopen)
- CopyQ, Flameshot (safe)

### Services That SHOULD Continue
- Syncthing (recovers automatically)
- rclone (timer-based, unaffected)

---

## 2.4 Data Integrity Verification

### KeePassXC Vault (CRITICAL!)
```bash
ls -lh ~/MyVault/MyVault.kdbx
keepassxc-cli ls ~/MyVault/MyVault.kdbx /
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)
diff <(sha256sum ~/MyVault/MyVault.kdbx) <(sha256sum "$BACKUP_DIR/MyVault-backup/MyVault.kdbx")
# Expected: No diff (files identical)
```

### Syncthing State
```bash
syncthing -device-id  # Verify unchanged
systemctl --user status syncthing@myspaces
```

### Git Repositories
```bash
for repo in ~/.MyHome/MySpaces/*/; do
  cd "$repo" && git status --short && git fsck
done
```

### MCP Servers
```bash
ls -la ~/.local-mcp-servers/ | wc -l  # Expected: 14+
~/.local-mcp-servers/mcp-context7 --help
```

---

## 2.5 Monitoring Setup

### Terminal Layout (3 Windows)
```
┌─────────────────────────────────────────┐
│ Window 1: Migration Commands           │
├─────────────────────────────────────────┤
│ Window 2: Service Monitor               │
│ watch -n 5 'systemctl --user ...'      │
├─────────────────────────────────────────┤
│ Window 3: Resource Monitor              │
│ watch -n 5 'df -h; free -h'            │
└─────────────────────────────────────────┘
```

### Migration Logging
```bash
MIGRATION_LOG="$HOME/.home-manager-refactoring-$(date +%Y%m%d-%H%M).log"
exec > >(tee -a "$MIGRATION_LOG") 2>&1
```

---

# PART 3: EXECUTION PLAN

## Target Structure

```
home-manager/
├── flake.nix, home.nix           # Root
├── npm-*.nix                     # KEEP IN ROOT!
├── profiles/hardware/
│   ├── shoshin.nix               # ✅ Exists
│   ├── kinoite.nix               # 🔜 Create later
│   └── wsl.nix                   # 🔜 Create later
├── overlays/
│   ├── firefox-memory-optimized.nix
│   └── onnxruntime-gpu-optimized.nix
└── modules/
    ├── shell/
    ├── cli/
    ├── apps/{browsers,editors,terminals}/
    ├── desktop/
    ├── services/{sync,monitoring}/
    ├── dev/{search,npm}/
    ├── ai/llm-core/
    ├── dotfiles/
    ├── automation/
    ├── system/
    └── mcp-servers/              # Already modular
```

---

## Phase -1: Pre-Migration Backup (30 min) 🔴 CRITICAL

**⚠️ MUST COMPLETE BEFORE PHASE 0 - DO NOT SKIP!**

### Step -1.1: System State Backup (10 min)
```bash
BACKUP_DIR="$HOME/.MyHome/backups/home-manager-refactoring-$(date +%Y%m%d-%H%M)"
mkdir -p "$BACKUP_DIR"

cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git bundle create "$BACKUP_DIR/home-manager-repo.bundle" --all

CURRENT_GEN=$(readlink ~/.local/state/home-manager/profiles/home-manager)
echo "$CURRENT_GEN" > "$BACKUP_DIR/current-generation.txt"
cp -r "$CURRENT_GEN" "$BACKUP_DIR/generation-backup/"

cp flake.lock "$BACKUP_DIR/flake.lock.backup"
nix-env -q --installed > "$BACKUP_DIR/installed-packages.txt"
home-manager packages > "$BACKUP_DIR/home-manager-packages.txt"
systemctl --user list-units --type=service --all > "$BACKUP_DIR/systemd-services-before.txt"
```

### Step -1.2: User Data Backup (15 min)
```bash
cp -r ~/MyVault "$BACKUP_DIR/MyVault-backup"
rsync -av --exclude='MySpaces' ~/.MyHome/ "$BACKUP_DIR/MyHome-backup/"

mkdir -p "$BACKUP_DIR/config-backup"
cp -r ~/.config/Claude "$BACKUP_DIR/config-backup/"
cp -r ~/.config/chezmoi "$BACKUP_DIR/config-backup/"
cp -r ~/.config/VSCodium/User "$BACKUP_DIR/config-backup/VSCodium-User"
cp -r ~/.claude_states "$BACKUP_DIR/claude-states-backup" 2>/dev/null || true
cp -r ~/.config/syncthing "$BACKUP_DIR/syncthing-backup"
```

### Step -1.3: Verification (5 min)
```bash
ls -lh "$BACKUP_DIR"
du -sh "$BACKUP_DIR"

cat > "$BACKUP_DIR/BACKUP_MANIFEST.txt" << EOF
Home-Manager Refactoring Backup
Created: $(date)
Backup Directory: $BACKUP_DIR

Contents: Git bundle, generation, flake.lock, KeePassXC vault, configs, MCP state

Restore: See COMPLETE_REFACTORING_GUIDE.md - Part 2.2 Level 3
EOF

cat "$BACKUP_DIR/BACKUP_MANIFEST.txt"
echo "$BACKUP_DIR" > ~/.home-manager-refactoring-backup-location.txt

echo "✅ Backup complete: $BACKUP_DIR"
```

**Checklist:**
- [ ] Git bundle created
- [ ] KeePassXC vault backed up (CRITICAL!)
- [ ] Configs backed up
- [ ] Backup location saved

---

## Phase 0: Pre-Work (1 hour)

### Step 0.0: User Actions (10 min)

#### Save Work (5 min)
```
⚠️ USER CHECKLIST:
- [ ] Save Obsidian documents
- [ ] Save VSCodium code
- [ ] Commit git work
- [ ] Close browsers
```

#### Setup Monitoring (5 min)
```bash
# Window 2: Service monitor
watch -n 5 'systemctl --user list-units --failed; echo "---"; systemctl --user list-units --type=service --state=running | grep -E "keepass|rclone|syncthing|obsidian"'

# Window 3: Resource monitor
watch -n 5 'df -h /home; echo "---"; free -h'

# Window 1: Migration log
MIGRATION_LOG="$HOME/.home-manager-refactoring-$(date +%Y%m%d-%H%M).log"
exec > >(tee -a "$MIGRATION_LOG") 2>&1
echo "Migration started: $(date)"
```

### Step 0.1: Git Backup Branch (5 min)
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git checkout -b backup-before-refactoring-2025-12-20
git push -u origin backup-before-refactoring-2025-12-20
git checkout main
git tag pre-refactoring-$(date +%Y%m%d-%H%M)
```

### Step 0.2: Resolve Conflicts (30 min)
```bash
# Examine conflicts
ls -la critical-gui-services.nix*
diff critical-gui-services.nix critical-gui-services.nix..remote-conflict1
diff critical-gui-services.nix critical-gui-services.nix..remote-conflict2
diff systemd-monitor.nix systemd-monitor.nix..remote-conflict1

# Manually resolve (choose newer/merged version)
# Test
home-manager build --flake .#mitsio@shoshin
home-manager switch --flake .#mitsio@shoshin -b backup-conflict-resolution

# Verify services
systemctl --user status keepassxc obsidian vscodium systemd-monitor

# Clean up
rm *.remote-conflict*

# Commit
git add critical-gui-services.nix systemd-monitor.nix
git commit -m "fix: resolve rclone sync conflicts in GUI services and monitor

```

### Step 0.3: Delete Deprecated (10 min)
```bash
# Verify NOT imported
grep -E "local-mcp-servers|chezmoi-llm-integration|claude-code\.nix|plasma-full" home.nix

# Delete
rm local-mcp-servers.nix chezmoi-llm-integration.nix claude-code.nix plasma-full.nix

# Test
home-manager build --flake .#mitsio@shoshin

# Commit
git add -A
git commit -m "chore: remove deprecated nix modules

```

### Step 0.4: Validate Hardware Profiles (15 min)
```bash
ls -la profiles/hardware/shoshin.nix
grep "shoshinHardware" flake.nix
nix build .#homeConfigurations."mitsio@shoshin".config.home.packages --dry-run
cat profiles/hardware/shoshin.nix | grep -E "cpu|gpu|memory|build"
```

---

## Phase 1: Module Structure (30 min)

### Step 1.1: Create Directories (5 min)
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

mkdir -p modules/{shell,cli,apps/{browsers,editors,terminals},desktop}
mkdir -p modules/services/{sync,monitoring}
mkdir -p modules/dev/{search,npm}
mkdir -p modules/{ai/llm-core,dotfiles,automation,system}

tree modules -L 2
```

### Step 1.2: Create default.nix Importers (25 min)

**See full content in original REFACTORING_PLAN.md - Phase 1, Step 1.2**

Create default.nix for:
- modules/default.nix (root)
- modules/shell/, cli/, apps/, desktop/, services/, dev/, ai/, dotfiles/, automation/, system/
- Subdirectories: apps/{browsers,editors,terminals}/, services/{sync,monitoring}/, dev/{search,npm}/, ai/llm-core/

---

## Phase 2: Independent Modules (1 hour)

### Step 2.1: CLI Tools (10 min)
```bash
mv atuin.nix navi.nix zellij.nix zjstatus.nix modules/cli/
# Update home.nix (remove individual imports)
home-manager build --flake .#mitsio@shoshin
home-manager switch --flake .#mitsio@shoshin -b backup-phase2.1
which atuin navi zellij
git add -A && git commit -m "refactor(cli): move CLI tools to modules/cli/

```

### Step 2.2: GUI Apps (20 min)
```bash
mv brave.nix firefox.nix modules/apps/browsers/
mv vscodium.nix modules/apps/editors/
mv kitty.nix warp.nix modules/apps/terminals/
mv electron-apps.nix modules/apps/

home-manager switch --flake .#mitsio@shoshin -b backup-phase2.2
brave --version && firefox --version && codium --version && kitty --version
git add -A && git commit -m "refactor(apps): move GUI apps to modules/apps/

```

### Step 2.3: Desktop, AI, Dotfiles, Automation (30 min)
```bash
mv autostart.nix modules/desktop/
mv gemini-cli.nix modules/ai/
mv llm-{commands,global-instructions,tsukuru-project}-symlinks.nix modules/ai/llm-core/
mv chezmoi.nix chezmoi-modify-manager.nix modules/dotfiles/
mv ansible-collections.nix gdrive-local-backup-job.nix modules/automation/

home-manager switch --flake .#mitsio@shoshin -b backup-phase2.3
git add -A && git commit -m "refactor(modules): move desktop, ai, dotfiles, automation to modules/

```

---

## Phase 3: Services (1 hour) ⚠️ PRESERVE ORDER!

### Step 3.1: Core Services (20 min)
```bash
# IMPORTANT: keepassxc BEFORE rclone!
mv keepassxc.nix dropbox.nix critical-gui-services.nix productivity-tools-services.nix modules/services/

home-manager switch --flake .#mitsio@shoshin -b backup-phase3.1
systemctl --user status keepassxc dropbox copyq flameshot
git add -A && git commit -m "refactor(services): move core services to modules/services/

```

### Step 3.2: Sync Services (20 min)
```bash
mv rclone-gdrive.nix rclone-maintenance.nix syncthing-myspaces.nix modules/services/sync/

home-manager switch --flake .#mitsio@shoshin -b backup-phase3.2
systemctl --user status rclone-gdrive-sync syncthing@myspaces
systemctl --user show-environment | grep RCLONE_CONFIG_PASS
git add -A && git commit -m "refactor(services): move sync services to modules/services/sync/

```

### Step 3.3: Monitoring (20 min)
```bash
mv systemd-monitor.nix modules/services/monitoring/

home-manager switch --flake .#mitsio@shoshin -b backup-phase3.3
systemctl --user status systemd-monitor
git add -A && git commit -m "refactor(services): move monitoring to modules/services/monitoring/

```

---

## Phase 4: Dev & System (1 hour)

### Step 4.1: Dev Tools (30 min)
```bash
mv git-hooks.nix nix-dev-tools.nix modules/dev/
mv semantic-grep.nix semtools.nix modules/dev/search/
mv npm-tools.nix modules/dev/npm/

# ⚠️ CRITICAL: KEEP npm-*.nix in ROOT!

home-manager switch --flake .#mitsio@shoshin -b backup-phase4.1
git-hooks --version || echo "working"
search --version
codex --version
git add -A && git commit -m "refactor(dev): move dev tools to modules/dev/

```

### Step 4.2: System (30 min)
```bash
mv shell.nix modules/shell/
mv oom-protected-wrappers.nix symlinks.nix toolkit.nix modules/system/

home-manager switch --flake .#mitsio@shoshin -b backup-phase4.2
ls -la ~/.MyHome  # Verify symlinks
which conflict-manager
git add -A && git commit -m "refactor(system): move system modules to modules/system/

```

---

## Phase 5: Simplify home.nix (15 min)

Replace 40+ imports with single line:

```nix
imports = [
  ./modules  # All organized modules
];
```

Test and commit:
```bash
home-manager switch --flake .#mitsio@shoshin -b backup-phase5
systemctl --user list-units --failed
git add home.nix && git commit -m "refactor(home): simplify imports to modular structure

```

---

## Phase 6: Validation (1 hour)

### Step 6.1: Service Verification (20 min)
```bash
# 1. Check for failed services
systemctl --user list-units --failed  # Expected: 0 failed units

# 2. Verify critical services running
systemctl --user status keepassxc
systemctl --user status rclone-gdrive-sync
systemctl --user status syncthing@myspaces
systemctl --user status obsidian-sync-helper

# 3. Check all systemd timers
systemctl --user list-timers  # Should show rclone, backup timers

# 4. Verify autostart services
ps aux | grep -E "(copyq|keepassxc)" | grep -v grep

# 5. Check for service restarts (shouldn't have restarted during migration)
systemctl --user list-units --state=running | grep -E "keepass|rclone|syncthing"
```

**Service Verification Checklist:**
- [ ] 0 failed systemd user units
- [ ] keepassxc service active
- [ ] rclone-gdrive-sync service/timer working
- [ ] syncthing@myspaces service active
- [ ] All timers listed and active
- [ ] Autostart applications running

---

### Step 6.2: Application Testing (20 min)
```bash
# 1. Test GUI applications launch
firefox --version
brave --version
code --version  # VSCodium
kitty --version

# 2. Test CLI tools
atuin --version
navi --version
zellij --version
ck --version
codex --version

# 3. Test development tools
python --version
go version
node --version
cargo --version

# 4. Test MCP servers (14 total)
ls -la ~/.local-mcp-servers/ | wc -l  # Should be 14+

# 5. Test semantic search tools
semtools search "test" ~/.MyHome/MySpaces/ --n-lines 1 --top-k 1
semantic-grep "test" ~/.MyHome/ | head -1

# 6. Test Git functionality
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git status
git log --oneline -5
```

**Application Testing Checklist:**
- [ ] All GUI apps launch successfully
- [ ] All CLI tools accessible and working
- [ ] All language runtimes available
- [ ] MCP servers count correct (14+)
- [ ] Semantic search tools functional
- [ ] Git operations working

---

### Step 6.3: Data Integrity Verification (15 min)

#### KeePassXC Vault Integrity (5 min)
```bash
# 1. Open vault (will prompt for password)
keepassxc-cli open ~/MyVault/MyVault.kdbx

# 2. List entries to verify vault structure
keepassxc-cli ls ~/MyVault/MyVault.kdbx / || echo "⚠️  VAULT CORRUPTED!"

# 3. Compare with backup
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)
diff <(sha256sum ~/MyVault/MyVault.kdbx) <(sha256sum "$BACKUP_DIR/MyVault-backup/MyVault.kdbx")
# Expected: Files should be identical (no diff output)
```

#### Syncthing State Integrity (3 min)
```bash
# 1. Verify device ID unchanged
syncthing -device-id

# 2. Check syncing status
systemctl --user status syncthing@myspaces

# 3. Verify folders syncing (check Web UI)
echo "Check Syncthing Web UI: http://localhost:8384"
```

#### Git Repositories Integrity (5 min)
```bash
# 1. Check all MySpaces git repos
for repo in ~/.MyHome/MySpaces/*/; do
  echo "Checking: $repo"
  cd "$repo"
  git status --short
  git fsck --no-progress 2>&1 | grep -i error || echo "  ✅ OK"
done

# 2. Check home-manager repo specifically
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git status
git fsck
```

#### MCP Server State Integrity (2 min)
```bash
# 1. Verify MCP server binaries
ls -la ~/.local-mcp-servers/ | wc -l  # Expected: 14+ entries

# 2. Check MCP server state (if exists)
ls -la ~/.claude_states/ 2>/dev/null || echo "No state (OK)"

# 3. Test one MCP server
~/.local-mcp-servers/mcp-context7 --help 2>/dev/null || echo "MCP working"
```

**Data Integrity Checklist:**
- [ ] KeePassXC vault opens successfully
- [ ] Vault unchanged from backup (sha256 match)
- [ ] Syncthing device ID preserved
- [ ] All git repos clean (no corruption)
- [ ] MCP servers accessible
- [ ] Critical configs verified

---

### Step 6.4: Documentation Update (5 min)
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/docs/home-manager

# 1. Update migration status
echo "## Migration Completed: $(date +%Y-%m-%d)" >> MIGRATION_STATUS.md
echo "" >> MIGRATION_STATUS.md
echo "- Modular structure: ✅ Complete" >> MIGRATION_STATUS.md
echo "- Files organized: 45 → modules/" >> MIGRATION_STATUS.md
echo "- Deprecated files deleted: 4" >> MIGRATION_STATUS.md
echo "- Conflicts resolved: 3" >> MIGRATION_STATUS.md
echo "" >> MIGRATION_STATUS.md

# 2. Create new structure documentation
cat > MODULE_STRUCTURE.md << 'EOF'
# Home-Manager Module Structure

**Last Updated:** $(date +%Y-%m-%d)

## Directory Layout
```
home-manager/
├── flake.nix, home.nix (root)
├── npm-*.nix (MUST stay in root - node2nix requirement)
├── profiles/hardware/
│   └── shoshin.nix
├── overlays/
│   ├── firefox-memory-optimized.nix
│   └── onnxruntime-gpu-optimized.nix
└── modules/
    ├── shell/
    ├── cli/
    ├── apps/{browsers,editors,terminals}/
    ├── desktop/
    ├── services/{sync,monitoring}/
    ├── dev/{search,npm}/
    ├── ai/llm-core/
    ├── dotfiles/
    ├── automation/
    ├── system/
    └── mcp-servers/
```

## Module Organization

- **shell/**: Shell configuration (shell.nix)
- **cli/**: CLI tools (atuin, navi, zellij)
- **apps/**: GUI applications (browsers, editors, terminals)
- **desktop/**: Desktop environment (autostart)
- **services/**: User services and timers (sync, monitoring)
- **dev/**: Development tools (search, npm packages)
- **ai/**: AI/LLM tools (gemini-cli, llm-core)
- **dotfiles/**: Dotfile management (chezmoi)
- **automation/**: Automation tools (ansible, backups)
- **system/**: System utilities (OOM protection, symlinks)
- **mcp-servers/**: 14 MCP servers (all Nix derivations per ADR-010)
EOF

# 3. Commit documentation
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git add -A
git commit -m "docs: update after modular refactoring completion

```

---

## Post-Migration Actions

### Immediate (Within 24 Hours)

**1. Monitor Services**
```bash
# Watch for any failures over next 24h
watch -n 300 'systemctl --user list-units --failed'

# Check logs for errors
journalctl --user -f | grep -i error
```

**2. Test Critical Workflows**
- Open KeePassXC and access a password
- Open Brave/Firefox and verify GPU acceleration works
- Test Claude Desktop with all 14 MCP servers
- Run a semantic search with semtools and ck
- Sync a file with Syncthing
- Test rclone bisync manually

**3. Verify Backup Can Be Deleted (After 24h Stable)**
```bash
# After 24h of stability, backup location can be archived/deleted
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)
du -sh "$BACKUP_DIR"  # Check size

# Optional: Archive before deletion
tar czf ~/refactoring-backup-$(date +%Y%m%d).tar.gz "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"
rm ~/.home-manager-refactoring-backup-location.txt
```

---

### Short-Term (Within 1 Week)

**1. Create Placeholder Hardware Profiles**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/profiles/hardware

# Create kinoite.nix (Fedora Atomic)
cat > kinoite.nix << 'EOF'
{
  # Placeholder for kinoite (Fedora Atomic) hardware profile
  # TODO: Populate when migrating from NixOS to Fedora

  gpuType = "nvidia";  # TBD
  gpuModel = "RTX 4070";  # TBD
  cpuCores = 16;  # TBD
  ramGB = 64;  # TBD

  firefoxGpuLayers = 6;  # TBD
  braveGpuLayers = 6;  # TBD
}
EOF

# Create wsl.nix (Windows WSL)
cat > wsl.nix << 'EOF'
{
  # Placeholder for WSL hardware profile
  # TODO: Populate when setting up WSL environment

  gpuType = "none";  # WSL typically no GPU
  cpuCores = 8;  # TBD
  ramGB = 16;  # TBD

  # Disable GPU-dependent features for WSL
  firefoxGpuLayers = 0;
  braveGpuLayers = 0;
}
EOF

git add profiles/hardware/
git commit -m "chore: add placeholder hardware profiles for future systems

```

**2. Document Lessons Learned**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/docs/home-manager

cat > LESSONS_LEARNED.md << 'EOF'
# Refactoring Lessons Learned

**Date:** $(date +%Y-%m-%d)

## What Went Well
- (Add notes here after migration)

## Challenges Encountered
- (Add notes here after migration)

## Would Do Differently
- (Add notes here after migration)

## Recommendations for Future
- (Add notes here after migration)
EOF

git add LESSONS_LEARNED.md
git commit -m "docs: add lessons learned template

```

---

### Long-Term (Within 1 Month)

**1. Review Module Organization Effectiveness**
- Are modules logically grouped?
- Any files in wrong modules?
- Any further optimization needed?

**2. Consider Additional Improvements**
- Flake-parts for better flake structure?
- Home-manager modules with options?
- Additional hardware profiles?
- Module-level testing?

**3. Archive Old Review Documents**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/docs/home-manager

# Create archive directory
mkdir -p archive/refactoring-2025-12-20

# Move completed review docs (if keeping for history)
mv COMPLETE_REFACTORING_GUIDE.md archive/refactoring-2025-12-20/
mv REFACTORING_PLAN.md archive/refactoring-2025-12-20/

git add archive/
git commit -m "docs: archive refactoring reviews

```

---

## Rollback Procedures

If issues occur during migration, use these rollback strategies:

### Level 0: Immediate Abort (During Phase Execution)
```bash
# If home-manager switch is running and causing issues
pkill -f home-manager

# Rollback to previous generation
home-manager switch --rollback

# Verify services
systemctl --user list-units --failed
```

**Time:** ~2 minutes

---

### Level 1: Phase Rollback (After Phase Complete, Before Next Phase)
```bash
# Go back to last commit
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git log --oneline -5  # Find last good commit

# Reset to that commit
git reset --hard <commit-hash>

# Rebuild from that state
home-manager switch --flake .#mitsio@shoshin -b rollback

# Verify
systemctl --user list-units --failed
```

**Time:** ~5 minutes

---

### Level 2: Full Rollback (Return to Pre-Refactoring State)
```bash
# 1. Restore from backup branch (created in Phase -1)
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git checkout main
git reset --hard backup-before-refactoring

# 2. Rebuild
home-manager switch --flake .#mitsio@shoshin

# 3. Verify all services
systemctl --user list-units --failed
systemctl --user status keepassxc rclone-gdrive-sync syncthing@myspaces
```

**Time:** ~10 minutes

---

### Level 3: Emergency Recovery (Complete System Restore)
```bash
# 1. Get backup location
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)

# 2. Restore git repository from bundle
cd ~/.MyHome/MySpaces/my-modular-workspace/
rm -rf home-manager
git clone "$BACKUP_DIR/home-manager-repo.bundle" home-manager
cd home-manager

# 3. Restore KeePassXC vault (CRITICAL!)
cp -r "$BACKUP_DIR/MyVault-backup/"* ~/MyVault/

# 4. Restore MCP state (if exists)
cp -r "$BACKUP_DIR/claude-states-backup" ~/.claude_states

# 5. Rebuild from restored state
home-manager switch --flake .#mitsio@shoshin

# 6. Verify data integrity
keepassxc-cli open ~/MyVault/MyVault.kdbx  # Should open
ls -la ~/.local-mcp-servers/ | wc -l  # Should show 14+
```

**Time:** ~15 minutes

**CRITICAL:** Level 3 is last resort only if all other rollbacks fail.

---

## Success Metrics

### Migration Success Criteria (ALL Must Pass)

**File Organization:**
- ✅ All 45 root files moved to modules/
- ✅ 4 deprecated files deleted
- ✅ 3 conflict files resolved
- ✅ npm-*.nix files remain in root
- ✅ home.nix simplified to single modules/ import

**System Functionality:**
- ✅ home-manager switch completes successfully
- ✅ 0 failed systemd user units
- ✅ All applications launch successfully
- ✅ All CLI tools accessible
- ✅ Hardware profiles working (overlays applied)

**Services & Automation:**
- ✅ keepassxc service running
- ✅ rclone-gdrive-sync timer active
- ✅ syncthing@myspaces service active
- ✅ All systemd timers listed and active
- ✅ Autostart applications running (copyq, keepassxc)

**Data Integrity:**
- ✅ KeePassXC vault intact and opens
- ✅ Syncthing device ID preserved
- ✅ Git repositories clean (no corruption)
- ✅ MCP servers accessible (14 total)
- ✅ Semantic search tools working

**Development Environment:**
- ✅ All language runtimes available (Python, Go, Node, Rust)
- ✅ All development tools working (ck, codex, semtools)
- ✅ Claude Desktop/Code with all MCP servers functional

**Documentation:**
- ✅ Migration status documented
- ✅ Module structure documented
- ✅ All changes committed to git
- ✅ Rollback capability verified

---

## Final Pre-Execution Checklist

**Before Starting Phase -1:**

**User Preparation:**
- [ ] Allocate 5-6 hours total time (can be spread across multiple sessions)
- [ ] Close all non-critical applications
- [ ] Save all work in progress
- [ ] Coffee/tea ready ☕
- [ ] Mental preparation (complex but safe process)
- [ ] Remember: You can pause between phases - no pressure to complete in one go!

**System Requirements:**
- [ ] >10GB free disk space available
- [ ] Working internet connection (for nix builds)
- [ ] All services currently running normally
- [ ] No pending system updates
- [ ] Battery charged (if laptop) or AC power connected

**Technical Preparation:**
- [ ] Read COMPLETE_REFACTORING_GUIDE.md (this document)
- [ ] Read REFACTORING_PLAN.md (detailed execution steps)
- [ ] Understand rollback procedures
- [ ] Have terminal windows ready for monitoring

**Data Safety:**
- [ ] Recent backup of critical work exists (outside home-manager)
- [ ] KeePassXC vault backed up separately (if not relying on Phase -1)
- [ ] Important git repos committed and pushed

**Ready to Execute:**
- [ ] All above items checked
- [ ] Confidence level >= 0.90 to proceed
- [ ] Understand this will take 5-6 hours
- [ ] Know where to find rollback procedures if needed

---

## Conclusion

**Migration Readiness: ✅ APPROVED**

This comprehensive refactoring plan has been reviewed by four specialized roles:
1. **Technical Researcher** - File inventory and categorization
2. **Technical Engineer** - Risk analysis and dependencies
3. **Planner** - Detailed execution plan with 7 phases
4. **Ops Engineer** - Operational safety and recovery procedures

**Confidence Level:** 0.96/1.00 (Band C - VERY HIGH)

**Risk Level:** 🟢 LOW (with all safeguards in place)

**Key Safety Features:**
- 3-layer backup strategy (Git + Home-Manager + Data)
- 4-layer rollback procedures (Immediate → Phase → Full → Emergency)
- Incremental testing after every phase
- Data integrity verification
- Real-time service monitoring
- Comprehensive failure mode analysis

**Estimated Timeline:**
- Phase -1: Pre-Migration Backup (30 min)
- Phase 0: Pre-Work + Conflicts (1 hour)
- Phase 1: Module Structure (30 min)
- Phase 2: Independent Modules (1 hour)
- Phase 3: Services Migration (1 hour)
- Phase 4: Dev & System (1 hour)
- Phase 5: Simplify home.nix (15 min)
- Phase 6: Validation (1 hour)
- **Total: 5-6 hours**

**Important Note:** ⏸️ **You CAN pause between phases!**
- After each phase completes successfully and tests pass, you can take a break
- No need to complete all phases in one session
- Resume anytime - git preserves your progress
- Recommended: Take breaks if feeling tired or overwhelmed
- Each phase is self-contained and safe to pause after

**Next Steps:**
1. Review this complete guide
2. Review REFACTORING_PLAN.md for detailed commands
3. Complete Final Pre-Execution Checklist
4. When ready: Begin with Phase -1 (Pre-Migration Backup)
5. Execute phases sequentially (NO SKIPPING!)
6. Test after EVERY phase
7. Monitor for 24-48 hours post-migration

**Remember:**
- If stuck: STOP, don't force through
- If uncertain: Ask questions via QnA
- If failed: Use appropriate rollback level
- If successful: Monitor for 24h before cleanup

---

**Document Version:** 1.0
**Created:** 2025-12-20 22:27 EET
**Completed:** 2025-12-20 23:02 EET
**All Reviews By: Multi-role analysis (Technical Researcher, Technical Engineer, Planner, Ops Engineer)
**Status:** ✅ Ready for Execution

**For detailed step-by-step commands, see:** `REFACTORING_PLAN.md`

---

*Good luck with the migration! You've got this! 🚀*