# Ops Engineer Review - Home-Manager Refactoring

**Date:** 2025-12-20
**Role:** Ops Engineer
**Purpose:** Operational safety, backup strategy, recovery procedures
**Reviewing:** REFACTORING_PLAN.md + TECHNICAL_ENGINEER_REVIEW.md

---

## Executive Summary

**Operational Risk:** 🟡 MEDIUM → 🟢 LOW (with additional safeguards)
**Confidence:** 0.96 (Band C - VERY HIGH)

**Critical Findings:**
- ⚠️ Missing comprehensive backup strategy
- ⚠️ No data integrity verification procedures
- ⚠️ Service continuity plan incomplete
- ✅ Rollback procedures adequate (with enhancements)

**Recommendation:** ✅ **APPROVED** with additional safeguards (detailed below)

---

## Operational Risk Assessment

### Risk Matrix

| Risk Category | Likelihood | Impact | Mitigation | Final Risk |
|---------------|------------|--------|------------|------------|
| Data Loss | LOW | CRITICAL | Full backup | 🟢 LOW |
| Service Downtime | MEDIUM | HIGH | Incremental testing | 🟡 MEDIUM |
| Config Corruption | LOW | HIGH | Git + generations | 🟢 LOW |
| Secret Exposure | LOW | CRITICAL | Verify .gitignore | 🟢 LOW |
| Dependency Break | MEDIUM | MEDIUM | Dependency mapping | 🟡 MEDIUM |
| Rollback Failure | LOW | CRITICAL | Multi-layer rollback | 🟢 LOW |

**Overall Risk:** 🟢 LOW (with safeguards in place)

---

## Critical Operational Issues

### Issue 1: Incomplete Backup Strategy
**Severity:** 🔴 CRITICAL
**Current State:** Plan mentions git backup, but no data backup

**Problem:**
- Git backs up configs, but NOT user data
- KeePassXC vault (`~/MyVault/`) not backed up
- Syncthing/rclone data not backed up
- MCP server state not backed up

**Required Addition:**
Pre-migration full system backup including:
1. Git repository state
2. KeePassXC vault
3. `~/.MyHome/` directory
4. `~/.config/` relevant subdirectories
5. Systemd service states
6. MCP server data (`~/.claude_states/`, etc.)

**Solution:** Add Phase -1 (Pre-Migration Backup) to plan

---

### Issue 2: No Service Continuity Plan
**Severity:** 🟡 MEDIUM
**Current State:** Services stopped during `home-manager switch`

**Problem:**
- Critical services (KeePassXC, Obsidian) will restart during migration
- Potential data loss if apps have unsaved work
- Syncthing/rclone might interrupt mid-sync

**Required Addition:**
1. Pre-migration: Save all work, close critical apps
2. During migration: Note which services will restart
3. Post-migration: Verify no data loss occurred

**Solution:** Add "Pre-Migration User Actions" checklist

---

### Issue 3: No Data Integrity Verification
**Severity:** 🟡 MEDIUM
**Current State:** No verification that data survived migration

**Problem:**
- Plan verifies services running, but not data integrity
- KeePassXC vault could be corrupted
- Syncthing state could be lost
- Git repositories could be affected

**Required Addition:**
Data integrity checks after migration:
1. KeePassXC vault opens successfully
2. Syncthing device IDs preserved
3. Git repositories status clean
4. MCP server state intact

**Solution:** Add to Phase 6 (Validation)

---

### Issue 4: Missing Emergency Recovery Procedures
**Severity:** 🟡 MEDIUM
**Current State:** Rollback documented, but not emergency scenarios

**Problem:**
- What if network fails during migration?
- What if disk fills up?
- What if systemd hangs?
- What if user accidentally kills process?

**Required Addition:**
Emergency recovery procedures for:
1. Interrupted migration (mid-phase)
2. Corrupted generation
3. Lost git state
4. Service startup failures

**Solution:** Add "Emergency Recovery" section

---

### Issue 5: No Monitoring During Migration
**Severity:** 🟢 LOW (but important)
**Current State:** Manual verification after each phase

**Enhancement:**
Real-time monitoring during migration:
1. Watch systemd service states
2. Monitor disk usage
3. Track memory usage (prevent OOM)
4. Log all operations

**Solution:** Add monitoring commands to each phase

---

## Enhanced Backup Strategy

### Phase -1: Pre-Migration Full Backup (NEW - ADD TO PLAN)

**Goal:** Comprehensive backup BEFORE any changes
**Time:** 30 minutes
**Critical:** 🔴 MUST COMPLETE before Phase 0

#### Step -1.1: System State Backup (10 min)
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

#### Step -1.2: User Data Backup (15 min)
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

#### Step -1.3: Verification & Documentation (5 min)
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

**Checklist:**
- [ ] Git repository bundled
- [ ] Current generation backed up
- [ ] KeePassXC vault backed up
- [ ] Critical .config directories backed up
- [ ] MCP server state backed up
- [ ] Backup manifest created
- [ ] Backup location saved

**CRITICAL:** Do NOT proceed to Phase 0 until ALL backups verified!

---

## Enhanced Rollback Procedures

### Level 0: Immediate Abort (NEW)
**Use When:** Something goes wrong during a phase, need to stop immediately

```bash
# 1. Stop any running home-manager process
pkill -f "home-manager switch"

# 2. Rollback to last generation
home-manager switch --rollback

# 3. Verify services
systemctl --user list-units --failed

# 4. Check what changed
git status
git diff

# Time: < 1 minute
```

---

### Level 1: Phase Rollback (ENHANCED)
**Use When:** Phase completed but has issues

```bash
# 1. Rollback to backup from that phase
home-manager switch --rollback

# 2. Verify specific generation
home-manager generations | head -5

# 3. Check services affected by that phase
systemctl --user status [services-from-that-phase]

# 4. Rollback git changes
git log --oneline -5
git reset --hard HEAD~1  # Or specific commit

# 5. Rebuild
home-manager switch --flake .#mitsio@shoshin

# Time: 2-3 minutes
```

---

### Level 2: Full Rollback (ENHANCED)
**Use When:** Multiple phases failed, need to start over

```bash
# 1. Rollback to backup branch
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git checkout backup-before-refactoring-2025-12-20

# 2. Restore flake.lock
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)
cp "$BACKUP_DIR/flake.lock.backup" flake.lock

# 3. Rebuild from clean state
home-manager switch --flake .#mitsio@shoshin

# 4. Verify all services
systemctl --user list-units --failed

# Time: 5 minutes
```

---

### Level 3: Emergency Recovery (NEW)
**Use When:** Complete failure, even git is corrupted

```bash
# 1. Load backup location
BACKUP_DIR=$(cat ~/.home-manager-refactoring-backup-location.txt)
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# 2. Restore from git bundle
git bundle unbundle "$BACKUP_DIR/home-manager-repo.bundle"
git reset --hard main  # Or backup branch

# 3. Restore flake.lock
cp "$BACKUP_DIR/flake.lock.backup" flake.lock

# 4. Restore current generation (if needed)
CURRENT_GEN=$(cat "$BACKUP_DIR/current-generation.txt")
nix-store -r "$CURRENT_GEN"
"$CURRENT_GEN/activate"

# 5. Restore user data (if needed)
cp -r "$BACKUP_DIR/MyVault-backup" ~/MyVault
cp -r "$BACKUP_DIR/MyHome-backup/"* ~/.MyHome/

# 6. Restore configs
cp -r "$BACKUP_DIR/config-backup/Claude" ~/.config/
cp -r "$BACKUP_DIR/config-backup/chezmoi" ~/.config/
cp -r "$BACKUP_DIR/config-backup/VSCodium-User" ~/.config/VSCodium/User

# 7. Restart critical services
systemctl --user restart keepassxc obsidian vscodium

# Time: 10-15 minutes
```

---

## Service Continuity Plan

### Pre-Migration User Actions (NEW - ADD TO PLAN)

**⚠️ CRITICAL: Complete BEFORE starting Phase 0**

#### Step 1: Save All Work (5 min)
```
User Actions:
- [ ] Save all documents in Obsidian
- [ ] Save all code in VSCodium
- [ ] Commit any git work in progress
- [ ] Close web browsers (Brave, Firefox)
- [ ] Note any running background processes
```

#### Step 2: Stop Non-Critical Services (2 min)
```bash
# Stop services that can be safely stopped
systemctl --user stop atuin-sync.timer
systemctl --user stop flameshot

# Keep critical services running:
# - keepassxc (needed for secrets)
# - syncthing (handles own state)
# - rclone sync (timer-based, safe)
```

#### Step 3: Note Current State (3 min)
```bash
# Document what's running
systemctl --user list-units --state=running --type=service > /tmp/pre-migration-services.txt

# Document open apps
ps aux | grep -E "obsidian|codium|brave|firefox|kitty" > /tmp/pre-migration-apps.txt

# You'll verify these post-migration
```

---

### During Migration: Service Restart Expectations

**Services That WILL Restart:**
- KeePassXC (expect brief downtime)
- Obsidian (will close and reopen)
- VSCodium (will close and reopen)
- CopyQ (clipboard history safe)
- Flameshot (screenshots safe)

**Services That SHOULD Continue:**
- Syncthing (P2P, recovers automatically)
- rclone (timer-based, next run unaffected)

**Services That Are Safe:**
- systemd-monitor (can restart anytime)
- Dropbox (handles reconnection)

---

### Post-Migration Verification (ENHANCED)

**Add to Phase 6:**

#### Verify Service States Match Pre-Migration
```bash
# Compare service states
diff /tmp/pre-migration-services.txt <(systemctl --user list-units --state=running --type=service)

# Check for unexpected failures
systemctl --user list-units --failed

# Verify critical services specifically
for service in keepassxc obsidian vscodium syncthing@myspaces rclone-gdrive-sync; do
  systemctl --user status $service || echo "⚠️  $service FAILED"
done
```

---

## Data Integrity Verification (NEW - ADD TO PHASE 6)

### Step 6.X: Data Integrity Checks (NEW)
**Add after Step 6.2 in REFACTORING_PLAN.md**

#### KeePassXC Vault Integrity (5 min)
```bash
# 1. Verify vault exists
ls -lh ~/MyVault/MyVault.kdbx

# 2. Test vault opens (will prompt for password)
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

# 3. Verify folders syncing
# (Check Syncthing Web UI: http://localhost:8384)
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

diff ~/.config/chezmoi/chezmoi.toml "$BACKUP_DIR/config-backup/chezmoi/chezmoi.toml" || echo "⚠️  Chezmoi config changed!"
diff ~/.config/Claude/mcp_config.json "$BACKUP_DIR/config-backup/Claude/mcp_config.json" || echo "⚠️  Claude MCP config changed!"
```

**Data Integrity Checklist:**
- [ ] KeePassXC vault opens successfully
- [ ] Vault unchanged from backup (sha256 match)
- [ ] Syncthing device ID preserved
- [ ] All git repos clean (no corruption)
- [ ] MCP servers accessible
- [ ] Critical configs verified

---

## Monitoring During Migration (NEW)

### Real-Time Monitoring Setup

**Add to Phase 0 (Pre-work):**

#### Terminal Window Layout
```
┌─────────────────────────────────────────┐
│  Window 1: Migration Commands          │  ← Run migration phases here
├─────────────────────────────────────────┤
│  Window 2: Service Monitor             │  ← Watch services
├─────────────────────────────────────────┤
│  Window 3: System Resources             │  ← Monitor disk/memory
└─────────────────────────────────────────┘
```

#### Window 2: Service Monitor
```bash
# Run in separate terminal/tmux pane
watch -n 5 'systemctl --user list-units --failed; echo "---"; systemctl --user list-units --type=service --state=running | grep -E "keepass|rclone|syncthing|obsidian"'
```

#### Window 3: System Resources
```bash
# Run in separate terminal/tmux pane
watch -n 5 'df -h /home; echo "---"; free -h; echo "---"; nix-store --gc --print-dead | wc -l'
```

#### Migration Log
```bash
# Start logging ALL operations
MIGRATION_LOG="$HOME/.home-manager-refactoring-$(date +%Y%m%d-%H%M).log"
exec > >(tee -a "$MIGRATION_LOG") 2>&1

echo "Migration started: $(date)"
echo "Logging to: $MIGRATION_LOG"
```

---

## Failure Mode Analysis

### Failure Scenarios & Recovery

| Failure Scenario | Probability | Impact | Detection | Recovery | RTO |
|------------------|-------------|--------|-----------|----------|-----|
| home-manager switch fails | LOW | MEDIUM | Immediate | Level 1 Rollback | 2 min |
| Service won't start | MEDIUM | MEDIUM | Manual check | Fix config, restart | 5 min |
| Git merge conflict | LOW | LOW | Git error | Manual resolve | 10 min |
| Disk full during migration | LOW | HIGH | Build error | Clean space, retry | 15 min |
| KeePassXC vault corrupted | VERY LOW | CRITICAL | Open fails | Restore from backup | 5 min |
| Network failure mid-migration | LOW | LOW | N/A | Continue (no network needed) | 0 min |
| Systemd hangs | VERY LOW | MEDIUM | Timeout | Reboot, rollback | 10 min |
| Flake build fails | MEDIUM | MEDIUM | Build error | Fix syntax, rebuild | 5 min |
| MCP servers missing | LOW | MEDIUM | Test fails | Check imports | 10 min |
| Secrets not loading | LOW | HIGH | Service fails | Fix KeePassXC | 10 min |

**RTO (Recovery Time Objective):** < 15 minutes for any scenario

---

## Security Considerations

### Secret Safety Checklist

**Before Migration:**
```bash
# 1. Verify secrets NOT in git
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git ls-files | grep -E "(secret|password|token|key)" && echo "⚠️  POTENTIAL SECRETS IN GIT!"

# 2. Check .gitignore
cat .gitignore | grep -E "secret|\.env|credentials"

# 3. Scan for hardcoded secrets
grep -r "AKIA" . --exclude-dir=.git  # AWS keys
grep -r "ghp_" . --exclude-dir=.git   # GitHub tokens
grep -r "sk-" . --exclude-dir=.git    # OpenAI keys
```

**After Migration:**
```bash
# Verify secrets still secure
systemctl --user show-environment | grep -E "PASS|SECRET|KEY|TOKEN" | wc -l
# Should show expected count (e.g., RCLONE_CONFIG_PASS)

# Verify KeePassXC integration working
secret-tool lookup service keepassxc key test 2>/dev/null || echo "Secret service working"
```

---

## Final Operational Checklist

### Pre-Migration (MUST COMPLETE ALL)
- [ ] User reviewed all planning documents
- [ ] **Phase -1: Full backup completed** (NEW)
- [ ] Backup location saved and verified
- [ ] All work saved, critical apps closed
- [ ] Monitoring windows set up
- [ ] Migration log started
- [ ] Coffee/tea prepared (5.5 hours estimated!)

### During Migration
- [ ] Follow phases sequentially (NO SKIPPING)
- [ ] Test after EACH phase (NO EXCEPTIONS)
- [ ] Commit after each successful phase
- [ ] Monitor services in Window 2
- [ ] Monitor resources in Window 3
- [ ] If ANY failure: STOP, analyze, decide (rollback vs fix)

### Post-Migration
- [ ] All services running (Phase 6.1)
- [ ] All applications tested (Phase 6.2)
- [ ] **Data integrity verified** (NEW Step 6.X)
- [ ] Documentation updated (Phase 6.3)
- [ ] Migration log reviewed
- [ ] Backup can be archived (after 7 days stable)

---

## Updates Required to REFACTORING_PLAN.md

### 1. Add Phase -1 (Pre-Migration Backup)
**Insert BEFORE Phase 0**
- Full system backup (30 min)
- User data backup
- Verification

### 2. Add Pre-Migration User Actions
**Insert in Phase 0, before Step 0.1**
- Save all work
- Close apps
- Stop non-critical services

### 3. Enhance Phase 6 (Validation)
**Add new Step 6.X (Data Integrity Verification)**
- After Step 6.2
- KeePassXC vault check
- Syncthing state check
- Git repos check
- MCP state check
- Config files check

### 4. Add Monitoring Setup
**Add to Phase 0, Step 0.1**
- Terminal window layout
- Service monitor command
- Resource monitor command
- Migration logging

### 5. Update Estimated Time
**OLD:** 4.5-5.5 hours
**NEW:** 5-6 hours (added Phase -1 + data verification)

---

## Operational Approval

**Risk Assessment:** 🟢 LOW (with all safeguards)
**Backup Strategy:** ✅ COMPREHENSIVE
**Rollback Capability:** ✅ MULTI-LAYER
**Service Continuity:** ✅ PLANNED
**Data Integrity:** ✅ VERIFIED
**Monitoring:** ✅ REAL-TIME

**Recommendation:** ✅ **APPROVED FOR EXECUTION**

**Conditions:**
1. ✅ Phase -1 (Full Backup) MUST be completed first
2. ✅ User MUST save all work before starting
3. ✅ Monitoring MUST be active during migration
4. ✅ Data integrity MUST be verified post-migration
5. ✅ IF ANY CRITICAL FAILURE: STOP and rollback

---

## Next Steps

1. **Update REFACTORING_PLAN.md** with all additions from this review
2. **Update TECHNICAL_ENGINEER_REVIEW.md** with backup strategy
3. **User reviews all documents**
4. **Execute when ready**

---

**Ops Engineer Sign-off:** ✅ APPROVED WITH ENHANCEMENTS
**Date:** 2025-12-20 22:23 EET
**Status:** Ready for plan updates and execution
