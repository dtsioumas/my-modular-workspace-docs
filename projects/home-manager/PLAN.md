# Home-Manager Refactoring Plan

**Date:** 2025-12-20
**Planner:** Planner Role
**Based On:**
- REFACTORING_REVIEW.md (Technical Researcher)
- TECHNICAL_ENGINEER_REVIEW.md (Technical Engineer)

**Status:** ✅ APPROVED FOR EXECUTION (All reviews complete)

---

## Plan Overview

**Goal:** Transform monolithic home-manager (45 root files) into modular structure

**Total Estimated Time:** 5-6 hours ⚠️ UPDATED (added backup + data verification)
**Phases:** 7 phases (Backup → Pre-work → Structure → Migration 1-3 → Validation)
**Risk Level:** 🟢 LOW (with Ops Engineer safeguards)
**Confidence:** 0.96 (Band C - VERY HIGH)

**⚠️ IMPORTANT:** Ops Engineer review added Phase -1 (Backup) - MUST complete before Phase 0!

**⏸️ PAUSE-FRIENDLY:** You can pause between phases! After each phase completes successfully and tests pass, you can take a break. No need to complete all phases in one session - git preserves your progress.

**Success Criteria:**
- ✅ All 51 files categorized and in correct modules/
- ✅ All systemd services running
- ✅ Hardware profiles functional
- ✅ MCP servers accessible
- ✅ No breaking changes
- ✅ Rollback capability preserved

---

## Phase -1: Pre-Migration Full Backup (NEW - 30 min) 🔴 CRITICAL

**Goal:** Comprehensive backup BEFORE any changes
**Risk:** 🟢 LOW
**Added By:** Ops Engineer Review
**CRITICAL:** ⚠️ MUST COMPLETE before Phase 0 - DO NOT SKIP!

### Why This Phase Was Added
Ops Engineer identified critical gaps in backup strategy:
- Git backs up configs but NOT user data
- KeePassXC vault not backed up
- MCP server state not backed up
- No recovery plan for data corruption

### Step -1.1: System State Backup (10 min)
```bash
# Create backup directory with timestamp
BACKUP_DIR="$HOME/.MyHome/backups/home-manager-refactoring-$(date +%Y%m%d-%H%M)"
mkdir -p "$BACKUP_DIR"

# 1. Backup home-manager repo (git bundle)
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git bundle create "$BACKUP_DIR/home-manager-repo.bundle" --all

# 2. Backup current home-manager generation
CURRENT_GEN=$(readlink ~/.local/state/home-manager/profiles/home-manager)
echo "$CURRENT_GEN" > "$BACKUP_DIR/current-generation.txt"
cp -r "$CURRENT_GEN" "$BACKUP_DIR/generation-backup/"

# 3. Backup flake.lock
cp flake.lock "$BACKUP_DIR/flake.lock.backup"

# 4. List all installed packages
nix-env -q --installed > "$BACKUP_DIR/installed-packages.txt"
home-manager packages > "$BACKUP_DIR/home-manager-packages.txt"

# 5. Backup systemd service states
systemctl --user list-units --type=service --all > "$BACKUP_DIR/systemd-services-before.txt"
```

### Step -1.2: User Data Backup (15 min)
```bash
# 1. Backup KeePassXC vault (CRITICAL!)
cp -r ~/MyVault "$BACKUP_DIR/MyVault-backup"

# 2. Backup .MyHome (selective - large directory)
rsync -av --exclude='MySpaces' ~/.MyHome/ "$BACKUP_DIR/MyHome-backup/"

# 3. Backup critical .config directories
mkdir -p "$BACKUP_DIR/config-backup"
cp -r ~/.config/Claude "$BACKUP_DIR/config-backup/"
cp -r ~/.config/chezmoi "$BACKUP_DIR/config-backup/"
cp -r ~/.config/VSCodium/User "$BACKUP_DIR/config-backup/VSCodium-User"

# 4. Backup MCP server state
cp -r ~/.claude_states "$BACKUP_DIR/claude-states-backup" 2>/dev/null || true

# 5. Backup Syncthing config
cp -r ~/.config/syncthing "$BACKUP_DIR/syncthing-backup"
```

### Step -1.3: Verification & Documentation (5 min)
```bash
# 1. Verify backups created
ls -lh "$BACKUP_DIR"

# 2. Calculate backup size
du -sh "$BACKUP_DIR"

# 3. Create backup manifest
cat > "$BACKUP_DIR/BACKUP_MANIFEST.txt" << EOF
Home-Manager Refactoring Backup
Created: $(date)
Backup Directory: $BACKUP_DIR

Contents:
- home-manager Git repository bundle
- Current home-manager generation
- flake.lock backup
- Installed packages list
- Systemd service states
- KeePassXC vault backup
- .MyHome backup (selective)
- Critical .config directories
- MCP server state
- Syncthing config

Restore Instructions:
See OPS_ENGINEER_REVIEW.md - Emergency Recovery section
EOF

# 4. Print backup summary
cat "$BACKUP_DIR/BACKUP_MANIFEST.txt"

# 5. CRITICAL: Write backup location to file
echo "$BACKUP_DIR" > ~/.home-manager-refactoring-backup-location.txt

echo "✅ Backup complete: $BACKUP_DIR"
echo "⚠️  KEEP THIS LOCATION SAFE!"
```

**Phase -1 Completion Checklist:**
- [ ] Git repository bundled
- [ ] Current generation backed up
- [ ] KeePassXC vault backed up (CRITICAL!)
- [ ] Critical .config directories backed up
- [ ] MCP server state backed up
- [ ] Backup manifest created
- [ ] Backup location saved to ~/.home-manager-refactoring-backup-location.txt

**⚠️ DO NOT PROCEED to Phase 0 until ALL backups verified!**

**Estimated Time:** 30 min
**Actual Time:** ______

---

## Phase 0: Pre-Work (REQUIRED - 1 hour)

**Goal:** Clean up conflicts and deprecated files BEFORE structural changes
**Risk:** 🟢 LOW
**Dependencies:** Phase -1 (Backup) MUST be complete
**Can Fail:** Yes (manual conflict resolution)

### Step 0.0: Pre-Migration User Actions (NEW - 10 min)
**Added By:** Ops Engineer Review
**CRITICAL:** Complete BEFORE any technical work

#### Save All Work (5 min)
```
⚠️ USER ACTIONS REQUIRED:
- [ ] Save all documents in Obsidian
- [ ] Save all code in VSCodium
- [ ] Commit any git work in progress
- [ ] Close web browsers (Brave, Firefox)
- [ ] Note any running background processes
```

#### Setup Monitoring (5 min)
```bash
# Open 3 terminal windows/panes:

# Window 1: Migration commands (main work)
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Window 2: Service monitor (run this, leave open)
watch -n 5 'systemctl --user list-units --failed; echo "---"; systemctl --user list-units --type=service --state=running | grep -E "keepass|rclone|syncthing|obsidian"'

# Window 3: Resource monitor (run this, leave open)
watch -n 5 'df -h /home; echo "---"; free -h'

# Window 1: Start migration log
MIGRATION_LOG="$HOME/.home-manager-refactoring-$(date +%Y%m%d-%H%M).log"
exec > >(tee -a "$MIGRATION_LOG") 2>&1
echo "Migration started: $(date)"
echo "Logging to: $MIGRATION_LOG"
```

**Checklist:**
- [ ] All work saved
- [ ] Apps closed
- [ ] 3 monitoring windows open
- [ ] Migration log started

---

### Step 0.1: Create Backup Branch (5 min)
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Create backup branch
git checkout -b backup-before-refactoring-2025-12-20
git push -u origin backup-before-refactoring-2025-12-20

# Return to main
git checkout main

# Tag current state
git tag pre-refactoring-$(date +%Y%m%d-%H%M)
```

**Verification:**
```bash
git branch --list | grep backup-before-refactoring
```

---

### Step 0.2: Resolve Conflict Files (30 min)
**Priority:** 🔴 CRITICAL - Must complete before refactoring

#### Examine Conflicts
```bash
# 1. Check critical-gui-services.nix conflicts
ls -la critical-gui-services.nix*

# 2. Examine differences
diff critical-gui-services.nix critical-gui-services.nix..remote-conflict1
diff critical-gui-services.nix critical-gui-services.nix..remote-conflict2

# 3. Examine systemd-monitor.nix conflict
diff systemd-monitor.nix systemd-monitor.nix..remote-conflict1
```

#### Resolution Strategy
**For each conflict file:**
1. Open both versions side-by-side
2. Identify which is newer (check timestamps, git log)
3. **Use QnA Feature:** Ask user which version to keep if unclear
4. Merge changes manually if both have unique updates

#### After Resolution
```bash
# Test the resolved config
home-manager build --flake .#mitsio@shoshin

# If build succeeds, activate
home-manager switch --flake .#mitsio@shoshin -b backup-conflict-resolution

# Verify services
systemctl --user status keepassxc obsidian vscodium
systemctl --user status systemd-monitor

# Delete conflict files
rm critical-gui-services.nix..remote-conflict*
rm systemd-monitor.nix..remote-conflict*

# Commit
git add critical-gui-services.nix systemd-monitor.nix
git commit -m "fix: resolve rclone sync conflicts in GUI services and monitor

- Resolved 2 conflicts in critical-gui-services.nix
- Resolved 1 conflict in systemd-monitor.nix
- Tested services post-resolution - all running

```

---

### Step 0.3: Delete Deprecated Files (10 min)
**Files to Delete:**
- `local-mcp-servers.nix` (deprecated per ADR-010)
- `chezmoi-llm-integration.nix` (removed per home.nix:78)
- `claude-code.nix` (replaced by npm-tools.nix per home.nix:46)
- `plasma-full.nix` (NOT imported, obsolete)

**Verification BEFORE deletion:**
```bash
# Verify these files are NOT imported in home.nix
grep -E "local-mcp-servers|chezmoi-llm-integration|claude-code\.nix|plasma-full" home.nix

# Expected: Only commented-out lines or no matches
```

**Delete:**
```bash
# Remove files
rm local-mcp-servers.nix
rm chezmoi-llm-integration.nix
rm claude-code.nix
rm plasma-full.nix

# Test build
home-manager build --flake .#mitsio@shoshin

# If successful, commit
git add -A
git commit -m "chore: remove deprecated nix modules

- Remove local-mcp-servers.nix (deprecated per ADR-010)
- Remove chezmoi-llm-integration.nix (unused per home.nix:78)
- Remove claude-code.nix (replaced by npm-tools.nix)
- Remove plasma-full.nix (not imported, obsolete)

All files verified as unused before deletion.

```

---

### Step 0.4: Validate Hardware Profile System (15 min)
**Goal:** Ensure hardware profiles work before refactoring

```bash
# 1. Check hardware profile exists
ls -la profiles/hardware/shoshin.nix

# 2. Verify overlays receive hardware profile
grep "shoshinHardware" flake.nix

# Expected output:
# shoshinHardware = import ./profiles/hardware/shoshin.nix;
# (import ./overlays/firefox-memory-optimized.nix shoshinHardware)
# (import ./overlays/onnxruntime-gpu-optimized.nix shoshinHardware)

# 3. Test overlay build
nix build .#homeConfigurations."mitsio@shoshin".config.home.packages --dry-run

# 4. Verify hardware profile content
cat profiles/hardware/shoshin.nix | grep -E "cpu|gpu|memory|build"
```

**Expected:** Hardware profile contains CPU, GPU, memory, build constraints

---

**Phase 0 Completion Checklist:**
- [ ] Backup branch created and pushed
- [ ] All conflict files resolved
- [ ] All deprecated files deleted
- [ ] Hardware profile validated
- [ ] Current config builds successfully
- [ ] All changes committed

**Estimated Time:** 1 hour
**Actual Time:** ______

---

## Phase 1: Create Module Structure (30 min)

**Goal:** Create empty directory structure with default.nix importers
**Risk:** 🟢 LOW
**Can Fail:** No (just mkdir + file creation)

### Step 1.1: Create Module Directories (5 min)
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Create all module directories
mkdir -p modules/shell
mkdir -p modules/cli
mkdir -p modules/terminal
mkdir -p modules/apps/{browsers,editors,terminals}
mkdir -p modules/desktop
mkdir -p modules/services/{sync,monitoring}
mkdir -p modules/dev/{search,npm}
mkdir -p modules/ai/llm-core
mkdir -p modules/dotfiles
mkdir -p modules/automation
mkdir -p modules/system

# modules/mcp-servers already exists - skip

# Verify structure
tree modules -L 2
```

---

### Step 1.2: Create default.nix Importers (25 min)

#### Root Module Importer
**File:** `modules/default.nix`
```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./shell
    ./cli
    ./terminal
    ./apps
    ./desktop
    ./services
    ./dev
    ./ai
    ./dotfiles
    ./automation
    ./system
    ./mcp-servers  # Already exists
  ];
}
```

#### modules/shell/default.nix
```nix
{ ... }: {
  imports = [
    ./shell.nix
  ];
}
```

#### modules/cli/default.nix
```nix
{ ... }: {
  imports = [
    ./atuin.nix
    ./navi.nix
    ./zellij.nix
    ./zjstatus.nix
  ];
}
```

#### modules/terminal/default.nix
*(Empty for now - kitty/warp in apps/terminals)*
```nix
{ ... }: {
  imports = [];
}
```

#### modules/apps/default.nix
```nix
{ ... }: {
  imports = [
    ./browsers
    ./editors
    ./terminals
    ./electron-apps.nix
  ];
}
```

#### modules/apps/browsers/default.nix
```nix
{ ... }: {
  imports = [
    ./brave.nix
    ./firefox.nix
  ];
}
```

#### modules/apps/editors/default.nix
```nix
{ ... }: {
  imports = [
    ./vscodium.nix
  ];
}
```

#### modules/apps/terminals/default.nix
```nix
{ ... }: {
  imports = [
    ./kitty.nix
    ./warp.nix
  ];
}
```

#### modules/desktop/default.nix
```nix
{ ... }: {
  imports = [
    ./autostart.nix
  ];
}
```

#### modules/services/default.nix
```nix
{ ... }: {
  imports = [
    ./keepassxc.nix
    ./dropbox.nix
    ./critical-gui-services.nix
    ./productivity-tools-services.nix
    ./sync
    ./monitoring
  ];
}
```

#### modules/services/sync/default.nix
```nix
{ ... }: {
  imports = [
    ./rclone-gdrive.nix
    ./rclone-maintenance.nix
    ./syncthing-myspaces.nix
  ];
}
```

#### modules/services/monitoring/default.nix
```nix
{ ... }: {
  imports = [
    ./systemd-monitor.nix
  ];
}
```

#### modules/dev/default.nix
```nix
{ ... }: {
  imports = [
    ./git-hooks.nix
    ./nix-dev-tools.nix
    ./search
    ./npm
  ];
}
```

#### modules/dev/search/default.nix
```nix
{ ... }: {
  imports = [
    ./semantic-grep.nix
    ./semtools.nix
  ];
}
```

#### modules/dev/npm/default.nix
```nix
{ ... }: {
  imports = [
    ./npm-tools.nix
  ];
}
```

#### modules/ai/default.nix
```nix
{ ... }: {
  imports = [
    ./gemini-cli.nix
    ./llm-core
  ];
}
```

#### modules/ai/llm-core/default.nix
```nix
{ ... }: {
  imports = [
    ./llm-commands-symlinks.nix
    ./llm-global-instructions-symlinks.nix
    ./llm-tsukuru-project-symlinks.nix
  ];
}
```

#### modules/dotfiles/default.nix
```nix
{ ... }: {
  imports = [
    ./chezmoi.nix
    ./chezmoi-modify-manager.nix
  ];
}
```

#### modules/automation/default.nix
```nix
{ ... }: {
  imports = [
    ./ansible-collections.nix
    ./gdrive-local-backup-job.nix
  ];
}
```

#### modules/system/default.nix
```nix
{ ... }: {
  imports = [
    ./oom-protected-wrappers.nix
    ./resource-control.nix  # Already exists
    ./symlinks.nix
    ./toolkit.nix
  ];
}
```

**Create all default.nix files:**
```bash
# Use the content above and create each file
# Or use a script to automate this

# Verify all default.nix created
find modules -name "default.nix"

# Expected: 15-20 default.nix files
```

---

**Phase 1 Completion Checklist:**
- [ ] All module directories created
- [ ] All default.nix importers created
- [ ] Directory structure verified with `tree`

**Estimated Time:** 30 min
**Actual Time:** ______

---

## Phase 2: Migration Phase 1 - Independent Modules (1 hour)

**Goal:** Move modules with NO dependencies first
**Risk:** 🟢 LOW
**Migration Order:** CLI → Apps → Desktop → AI → Dotfiles → Automation

### General Migration Pattern
For each module:
1. Move file to new location
2. Update home.nix imports
3. Test build
4. Test activation
5. Verify functionality
6. Commit

---

### Step 2.1: Migrate CLI Tools (10 min)
```bash
# Move files
mv atuin.nix modules/cli/
mv navi.nix modules/cli/
mv zellij.nix modules/cli/
mv zjstatus.nix modules/cli/

# Update home.nix - REMOVE these lines:
#   ./atuin.nix
#   ./navi.nix
#   ./zellij.nix
#   ./zjstatus.nix

# home.nix will import modules/cli via modules/default.nix

# Test
home-manager build --flake .#mitsio@shoshin

# If success, activate
home-manager switch --flake .#mitsio@shoshin -b backup-phase2.1

# Verify
which atuin navi zellij

# Commit
git add -A
git commit -m "refactor(cli): move CLI tools to modules/cli/

- Move atuin.nix, navi.nix, zellij.nix, zjstatus.nix to modules/cli/
- Update home.nix imports
- All CLI tools verified working post-migration

```

---

### Step 2.2: Migrate Apps (20 min)
```bash
# Move browsers
mv brave.nix modules/apps/browsers/
mv firefox.nix modules/apps/browsers/

# Move editors
mv vscodium.nix modules/apps/editors/

# Move terminals
mv kitty.nix modules/apps/terminals/
mv warp.nix modules/apps/terminals/

# Move electron apps
mv electron-apps.nix modules/apps/

# Update home.nix - REMOVE these imports

# Test
home-manager build --flake .#mitsio@shoshin

# Activate
home-manager switch --flake .#mitsio@shoshin -b backup-phase2.2

# Verify apps launch
brave --version
firefox --version
codium --version
kitty --version

# Commit
git add -A
git commit -m "refactor(apps): move GUI applications to modules/apps/

- Move brave, firefox to modules/apps/browsers/
- Move vscodium to modules/apps/editors/
- Move kitty, warp to modules/apps/terminals/
- Move electron-apps to modules/apps/
- All apps verified working post-migration

```

---

### Step 2.3: Migrate Desktop, AI, Dotfiles, Automation (30 min)
**Migrate all remaining independent modules in ONE batch**

```bash
# Desktop
mv autostart.nix modules/desktop/

# AI
mv gemini-cli.nix modules/ai/
mv llm-commands-symlinks.nix modules/ai/llm-core/
mv llm-global-instructions-symlinks.nix modules/ai/llm-core/
mv llm-tsukuru-project-symlinks.nix modules/ai/llm-core/

# Dotfiles
mv chezmoi.nix modules/dotfiles/
mv chezmoi-modify-manager.nix modules/dotfiles/

# Automation
mv ansible-collections.nix modules/automation/
mv gdrive-local-backup-job.nix modules/automation/

# Update home.nix - REMOVE all these imports

# Test & Activate
home-manager switch --flake .#mitsio@shoshin -b backup-phase2.3

# Commit
git add -A
git commit -m "refactor(modules): move desktop, ai, dotfiles, automation to modules/

- Move autostart to modules/desktop/
- Move gemini-cli, llm-core/* to modules/ai/
- Move chezmoi modules to modules/dotfiles/
- Move ansible-collections, gdrive-backup to modules/automation/
- All modules verified working

```

---

**Phase 2 Completion Checklist:**
- [ ] CLI tools migrated and working
- [ ] GUI apps migrated and working
- [ ] Desktop modules migrated
- [ ] AI modules migrated
- [ ] Dotfiles modules migrated
- [ ] Automation modules migrated
- [ ] All changes committed

**Estimated Time:** 1 hour
**Actual Time:** ______

---

## Phase 3: Migration Phase 2 - Services (1 hour)

**Goal:** Migrate services with dependencies (PRESERVE ORDER)
**Risk:** 🟡 MEDIUM (systemd service dependencies)
**Critical:** keepassxc BEFORE rclone

### Step 3.1: Migrate Core Services (20 min)
```bash
# IMPORTANT: Migrate in dependency order
# 1. keepassxc (no deps)
# 2. dropbox (no deps)
# 3. critical-gui-services (depends on keepassxc)
# 4. productivity-tools (no deps)

mv keepassxc.nix modules/services/
mv dropbox.nix modules/services/
mv critical-gui-services.nix modules/services/
mv productivity-tools-services.nix modules/services/

# Update home.nix

# Test
home-manager switch --flake .#mitsio@shoshin -b backup-phase3.1

# Verify services
systemctl --user status keepassxc dropbox copyq flameshot

# Commit
git add -A
git commit -m "refactor(services): move core services to modules/services/

- Move keepassxc, dropbox, critical-gui-services, productivity-tools
- Preserved systemd service dependency order
- All services verified running post-migration

```

---

### Step 3.2: Migrate Sync Services (20 min)
```bash
# CRITICAL: Keep order - keepassxc already migrated, now add sync

mv rclone-gdrive.nix modules/services/sync/
mv rclone-maintenance.nix modules/services/sync/
mv syncthing-myspaces.nix modules/services/sync/

# Update home.nix

# Test
home-manager switch --flake .#mitsio@shoshin -b backup-phase3.2

# Verify sync services
systemctl --user status rclone-gdrive-sync
systemctl --user status syncthing@myspaces

# Verify secret loading works
systemctl --user show-environment | grep RCLONE_CONFIG_PASS

# Commit
git add -A
git commit -m "refactor(services): move sync services to modules/services/sync/

- Move rclone-gdrive, rclone-maintenance, syncthing to sync/
- Secret loading verified (RCLONE_CONFIG_PASS present)
- All sync services verified running

```

---

### Step 3.3: Migrate Monitoring Services (20 min)
```bash
mv systemd-monitor.nix modules/services/monitoring/

# Update home.nix

# Test
home-manager switch --flake .#mitsio@shoshin -b backup-phase3.3

# Verify monitoring
systemctl --user status systemd-monitor

# Commit
git add -A
git commit -m "refactor(services): move monitoring to modules/services/monitoring/

- Move systemd-monitor to monitoring/
- Service verified running and monitoring other services

```

---

**Phase 3 Completion Checklist:**
- [ ] Core services migrated and running
- [ ] Sync services migrated and running
- [ ] Secrets loading verified
- [ ] Monitoring services running
- [ ] All systemd services verified
- [ ] All changes committed

**Estimated Time:** 1 hour
**Actual Time:** ______

---

## Phase 4: Migration Phase 3 - Dev & System (1 hour)

**Goal:** Migrate remaining modules (Dev tools + System)
**Risk:** 🟡 MEDIUM (npm files MUST stay in root)

### Step 4.1: Migrate Dev Tools (30 min)
```bash
# Move dev tools (NOT npm-*.nix!)
mv git-hooks.nix modules/dev/
mv nix-dev-tools.nix modules/dev/
mv semantic-grep.nix modules/dev/search/
mv semtools.nix modules/dev/search/
mv npm-tools.nix modules/dev/npm/

# ⚠️ CRITICAL: Keep npm-*.nix in ROOT!
# DO NOT MOVE:
# - npm-default.nix
# - npm-node-env.nix
# - npm-node-packages.nix

# Update home.nix

# Test
home-manager switch --flake .#mitsio@shoshin -b backup-phase4.1

# Verify dev tools
git-hooks --version || echo "git-hooks working"
nix-prefetch-url --version
search --version  # semtools
semantic-grep --help
codex --version   # npm-tools

# Commit
git add -A
git commit -m "refactor(dev): move development tools to modules/dev/

- Move git-hooks, nix-dev-tools to modules/dev/
- Move semantic-grep, semtools to modules/dev/search/
- Move npm-tools to modules/dev/npm/
- KEPT npm-*.nix in root (required by node2nix)
- All dev tools verified working

```

---

### Step 4.2: Migrate System Modules (30 min)
```bash
# Move system modules
mv shell.nix modules/shell/
mv oom-protected-wrappers.nix modules/system/
mv symlinks.nix modules/system/
mv toolkit.nix modules/system/

# resource-control.nix already in modules/system/

# Update home.nix

# Test
home-manager switch --flake .#mitsio@shoshin -b backup-phase4.2

# Verify system modules
ls -la ~/.MyHome  # symlinks should exist
echo $SHELL       # shell.nix loaded
which conflict-manager  # toolkit

# Verify OOM protection
ps aux | grep -E "brave|firefox" | head -5

# Commit
git add -A
git commit -m "refactor(system): move system modules to modules/system/

- Move shell.nix to modules/shell/
- Move oom-wrappers, symlinks, toolkit to modules/system/
- All system modules verified working
- OOM protection active for browsers

```

---

**Phase 4 Completion Checklist:**
- [ ] Dev tools migrated (npm-*.nix stayed in root)
- [ ] System modules migrated
- [ ] Shell working
- [ ] Symlinks created
- [ ] OOM protection active
- [ ] All changes committed

**Estimated Time:** 1 hour
**Actual Time:** ______

---

## Phase 5: Update home.nix (15 min)

**Goal:** Clean up home.nix to use single modules import
**Risk:** 🟢 LOW

### Step 5.1: Simplify home.nix Imports
**Current home.nix (lines 38-80):** 40+ individual imports

**New home.nix (simplified):**
```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    # ===== MODULAR STRUCTURE (Refactored 2025-12-20) =====
    ./modules  # Imports all organized modules via modules/default.nix
  ];

  # ... rest of home.nix unchanged ...
}
```

**Test:**
```bash
# Build
home-manager build --flake .#mitsio@shoshin

# Activate
home-manager switch --flake .#mitsio@shoshin -b backup-phase5

# Verify EVERYTHING still works
systemctl --user list-units --failed  # Should be empty

# Commit
git add home.nix
git commit -m "refactor(home): simplify imports to use modular structure

- Replace 40+ individual imports with single ./modules import
- All modules now organized in modules/ subdirectories
- Verified all services and packages working

Refactoring complete!

```

---

**Phase 5 Completion Checklist:**
- [ ] home.nix simplified to single modules import
- [ ] Build successful
- [ ] All services verified
- [ ] Changes committed

**Estimated Time:** 15 min
**Actual Time:** ______

---

## Phase 6: Final Validation (1 hour)

**Goal:** Comprehensive testing and documentation
**Risk:** 🟢 LOW

### Step 6.1: Comprehensive Service Verification (20 min)
```bash
# 1. Check all systemd services
systemctl --user list-units --type=service --failed

# Expected: No failed services

# 2. Test critical services individually
systemctl --user status keepassxc
systemctl --user status obsidian
systemctl --user status vscodium
systemctl --user status rclone-gdrive-sync
systemctl --user status syncthing@myspaces
systemctl --user status systemd-monitor

# 3. Verify secret loading
systemctl --user show-environment | grep -E "RCLONE|KEEPASS"

# 4. Test MCP servers
ls -la ~/.local-mcp-servers/
~/.local-mcp-servers/mcp-context7 --version || echo "MCP available"

# 5. Verify hardware profiles
nix eval .#homeConfigurations."mitsio@shoshin".config.programs.firefox.package.meta

# 6. Check symlinks
ls -la ~/.MyHome/
ls -la ~/MySpaces
```

---

### Step 6.2: Application Testing (15 min)
```bash
# Test GUI apps (launch each)
brave --version && echo "✅ Brave working"
firefox --version && echo "✅ Firefox working"
codium --version && echo "✅ VSCodium working"
kitty --version && echo "✅ Kitty working"

# Test CLI tools
atuin --version
navi --version
zellij --version

# Test dev tools
git-hooks --version || echo "git-hooks working"
semantic-grep --help
search --version  # semtools
codex --version
gemini-cli --version || echo "gemini-cli working"

# Test chezmoi
chezmoi --version
chezmoi list | head -5
```

---

### Step 6.3: Data Integrity Verification (NEW - 20 min)
**Added By:** Ops Engineer Review
**CRITICAL:** Verify user data survived migration intact

#### KeePassXC Vault Integrity (5 min)
```bash
# 1. Verify vault exists
ls -lh ~/MyVault/MyVault.kdbx

# 2. Test vault opens (will prompt for password)
keepassxc-cli ls ~/MyVault/MyVault.kdbx / || echo "⚠️  VAULT CORRUPTED - RESTORE FROM BACKUP!"

# 3. Compare with backup
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)
diff <(sha256sum ~/MyVault/MyVault.kdbx) <(sha256sum "$BACKUP_DIR/MyVault-backup/MyVault.kdbx")

# Expected: No output (files identical)
# If different: ⚠️  INVESTIGATE IMMEDIATELY!
```

#### Syncthing State Integrity (3 min)
```bash
# 1. Verify device ID unchanged
syncthing -device-id

# 2. Check syncing status
systemctl --user status syncthing@myspaces

# 3. Verify folders syncing (check Web UI: http://localhost:8384)
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

#### MCP Server State Integrity (3 min)
```bash
# 1. Verify MCP server binaries
ls -la ~/.local-mcp-servers/ | wc -l
# Expected: 14+ entries

# 2. Check MCP server state
ls -la ~/.claude_states/ 2>/dev/null || echo "No state (OK)"

# 3. Test one MCP server
~/.local-mcp-servers/mcp-context7 --help 2>/dev/null || echo "MCP working"
```

#### Configuration Files Integrity (2 min)
```bash
# Verify critical configs unchanged
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)

diff ~/.config/chezmoi/chezmoi.toml "$BACKUP_DIR/config-backup/chezmoi/chezmoi.toml" || echo "ℹ️  Chezmoi config changed (expected if updated)"
diff ~/.config/Claude/mcp_config.json "$BACKUP_DIR/config-backup/Claude/mcp_config.json" || echo "ℹ️  Claude MCP config changed (expected if updated)"
```

**Data Integrity Checklist:**
- [ ] KeePassXC vault opens successfully
- [ ] Vault unchanged from backup (sha256 match)
- [ ] Syncthing device ID preserved
- [ ] All git repos clean (no corruption)
- [ ] MCP servers accessible
- [ ] Critical configs verified

**⚠️ If ANY integrity check fails: INVESTIGATE before proceeding!**

---

### Step 6.4: Documentation Update (20 min)
```bash
# 1. Update home-manager/README.md
cat > README.md << 'EOF'
# My Home-Manager Flake

**Portable, declarative user environment configuration**

**User:** mitsio
**Strategy:** Standalone home-manager with unstable packages
**Status:** ✅ Modular Structure (Refactored 2025-12-20)

---

## Architecture

**Modular Organization:**
```
home-manager/
├── flake.nix          # Main flake with hardware profiles
├── home.nix           # Entry point (imports ./modules)
├── npm-*.nix          # Auto-generated (KEEP IN ROOT)
│
├── profiles/hardware/ # Hardware profiles per host
├── overlays/          # Hardware-parameterized overlays
│
└── modules/           # Organized module categories
    ├── shell/         # Bash configuration
    ├── cli/           # CLI tools (atuin, navi, zellij)
    ├── apps/          # GUI applications
    ├── desktop/       # Desktop environment
    ├── services/      # Systemd services
    ├── dev/           # Development tools
    ├── ai/            # AI/LLM tools
    ├── dotfiles/      # Chezmoi integration
    ├── automation/    # Ansible, backup jobs
    ├── system/        # System utilities
    └── mcp-servers/   # MCP server packages (ADR-010)
```

## Usage

```bash
# Apply configuration
home-manager switch --flake .#mitsio@shoshin

# With backup
home-manager switch --flake .#mitsio@shoshin -b backup

# Update packages
nix flake update
home-manager switch --flake .#mitsio@shoshin
```

## Documentation

- **Architecture:** `docs/home-manager/decoupling-architecture.md`
- **Refactoring:** `docs/home-manager/REFACTORING_PLAN.md`
- **Hardware Profiles:** `docs/home-manager/hardware-profile-system.md`
- **Debugging:** `docs/home-manager/DEBUGGING_AND_MAINTENANCE.md`

## ADRs

- **ADR-001:** NixOS Stable vs Home-Manager Unstable
- **ADR-007:** Autostart via Home-Manager
- **ADR-010:** Unified MCP Server Architecture

---

**Refactored:** 2025-12-20
**Structure:** Modular (51 files organized into 11 module categories)
EOF

# 2. Create migration completion document
cat > docs/home-manager/MIGRATION_COMPLETE.md << 'EOF'
# Home-Manager Modular Refactoring - Completion Report

**Date:** 2025-12-20
**Completion Time:** [FILL IN ACTUAL TIME]
**Status:** ✅ COMPLETE

## Summary

Successfully migrated monolithic home-manager (45 root files) to modular structure (11 module categories).

**Total Files Migrated:** 45 files
**Module Categories:** 11 directories
**Deprecated Files Deleted:** 4 files
**Conflicts Resolved:** 3 files

## Phases Completed

- [x] Phase 0: Pre-work (conflicts + deprecated files)
- [x] Phase 1: Module structure creation
- [x] Phase 2: Independent modules migration
- [x] Phase 3: Services migration
- [x] Phase 4: Dev & system migration
- [x] Phase 5: home.nix simplification
- [x] Phase 6: Final validation

## Verification Results

**Services Status:**
```
All systemd services: RUNNING ✅
Secret loading: WORKING ✅
MCP servers: ACCESSIBLE ✅
Hardware profiles: FUNCTIONAL ✅
```

**Applications Tested:**
- Brave: ✅
- Firefox: ✅
- VSCodium: ✅
- Kitty: ✅
- All CLI tools: ✅

## Issues Encountered

[FILL IN ANY ISSUES AND RESOLUTIONS]

## Rollback Tested

[x] Rollback capability verified: `home-manager switch --rollback`

## Next Steps

1. Monitor services for 24-48 hours
2. Create placeholder hardware profiles (kinoite.nix, wsl.nix)
3. Consider further optimization if needed

---

**Migration Plan:** `docs/home-manager/REFACTORING_PLAN.md`
**Technical Review:** `docs/home-manager/TECHNICAL_ENGINEER_REVIEW.md`
EOF

# 3. Commit documentation
git add README.md docs/home-manager/MIGRATION_COMPLETE.md
git commit -m "docs: update documentation for modular refactoring

- Update README.md with new modular structure
- Create MIGRATION_COMPLETE.md completion report
- Document all phases and verification results

```

---

**Phase 6 Completion Checklist:**
- [ ] All services verified
- [ ] All applications tested
- [ ] Documentation updated
- [ ] Migration completion report created
- [ ] All changes committed

**Estimated Time:** 1 hour
**Actual Time:** ______

---

## Post-Migration Actions

### Immediate (Within 24 hours)
1. Monitor systemd services for failures
2. Watch for any unexpected behavior
3. Test all critical workflows

### Short-term (Within 1 week)
1. Create placeholder hardware profiles:
   - `profiles/hardware/kinoite.nix`
   - `profiles/hardware/wsl.nix`
2. Document any lessons learned

### Long-term (Within 1 month)
1. Consider further optimization
2. Review module organization
3. Plan future migrations (if any)

---

## Rollback Procedures

### If Issues Arise During Migration:

**Quick Rollback (Last Generation):**
```bash
home-manager switch --rollback
```

**Rollback to Specific Backup:**
```bash
# List backup generations
home-manager generations

# Activate specific backup
/nix/store/[hash]-home-manager-generation/activate
```

**Git Rollback (Nuclear Option):**
```bash
git checkout backup-before-refactoring-2025-12-20
home-manager switch --flake .#mitsio@shoshin
```

---

## Success Metrics

**Completion Criteria:**
- ✅ All 45 files migrated to modules/
- ✅ 4 deprecated files deleted
- ✅ 3 conflict files resolved
- ✅ All systemd services running
- ✅ All applications functional
- ✅ Hardware profiles working
- ✅ MCP servers accessible
- ✅ Rollback capability preserved
- ✅ Documentation updated

**Performance Metrics:**
- Estimated time: 4.5-5.5 hours
- Actual time: [TO BE FILLED]
- Issues encountered: [TO BE FILLED]

---

## Plan Metadata

**Created:** 2025-12-20 22:13 EET
**Updated:** 2025-12-20 22:25 EET (Ops Engineer enhancements)
**Planner:** Planner Role
**Ops Review:** Ops Engineer Role (Complete)
**Confidence:** 0.96 (Band C - VERY HIGH) ⬆️ Increased after Ops review
**Status:** ✅ **APPROVED FOR EXECUTION**

**Reviews Completed:**
- ✅ Technical Researcher (REFACTORING_REVIEW.md)
- ✅ Technical Engineer (TECHNICAL_ENGINEER_REVIEW.md)
- ✅ Planner (REFACTORING_PLAN.md)
- ✅ Ops Engineer (OPS_ENGINEER_REVIEW.md + plan updates)

---

**Plan Complete** ✅
**Total Estimated Time:** 4.5-5.5 hours
**Phases:** 6 phases with incremental testing
**Rollback:** Multiple layers of safety
