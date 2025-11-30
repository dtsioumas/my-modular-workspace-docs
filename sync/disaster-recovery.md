# Disaster Recovery & Rollback Procedures

**Last Updated:** 2025-11-30
**Sources:** sessions/sync-integration/gdrive-migration-syncthing-backup/ROLLBACK_PROCEDURES.md
**Maintainer:** Mitsos

---

## Table of Contents

- [When to Use This Guide](#when-to-use-this-guide)
- [Emergency Quick Rollback](#emergency-quick-rollback)
- [Recovery Scenarios](#recovery-scenarios)
- [Complete Rollback Procedure](#complete-rollback-procedure)
- [Case Study: Git Recovery (Nov 17, 2025)](#case-study-git-recovery-nov-17-2025)

---

## When to Use This Guide

### Use these procedures if:
- ❌ Deployment failed with errors
- ❌ Services not starting correctly
- ❌ Data loss or corruption suspected
- ❌ System unstable after deployment
- ❌ Need to undo sync changes

### DO NOT use for:
- ✅ Minor configuration tweaks (just rebuild)
- ✅ Normal troubleshooting (check logs first)
- ✅ Planned maintenance

---

## Emergency Quick Rollback

**If you need to rollback immediately:**

```bash
# 1. Rollback NixOS to previous generation
sudo nixos-rebuild --rollback

# 2. Restart system
sudo systemctl reboot
```

This restores the system to before deployment.

**Then follow detailed procedures below to clean up.**

---

## Recovery Scenarios

### Scenario 1: Deployment Failed During nixos-rebuild

**Symptoms:**
- Build errors during `nixos-rebuild switch`
- Services failing to start
- System configuration errors

**Solution:**

```bash
# Check current generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild --rollback

# Or rollback to specific generation
sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation XX

# Restart services
sudo systemctl daemon-reload

# Verify system
systemctl status
```

**Verify rollback:**
```bash
# Check active generation
ls -l /run/current-system

# Check if old services back
systemctl --user status rclone-gdrive.service  # If was using mount
```

---

### Scenario 2: rclone bisync Issues

**Symptoms:**
- Bisync not working
- Data sync issues
- Too many conflicts

**Solution A: Restore Old Mount**

If migrating from rclone mount:

```bash
# Re-enable old rclone mount
systemctl --user enable rclone-gdrive.service
systemctl --user start rclone-gdrive.service

# Verify mount
mount | grep GoogleDrive

# Disable new bisync
sudo systemctl disable rclone-bisync.timer
sudo systemctl stop rclone-bisync.service
```

**Solution B: Reset Bisync State**

```bash
# Remove bisync cache
rm -rf ~/.cache/rclone/bisync/

# Run fresh resync
sync-gdrive-resync

# Or manually:
rclone bisync ~/.MyHome/ GoogleDrive-dtsioumas0:MyHome/ --resync -v
```

---

### Scenario 3: Data Loss or Corruption

**Symptoms:**
- Files missing from MyHome
- Files corrupted
- Can't access Google Drive

**Solution:**

```bash
# 1. STOP all sync immediately
sudo systemctl stop rclone-bisync.service
sudo systemctl disable rclone-bisync.timer
systemctl --user stop syncthing

# 2. Check Google Drive data (via web)
# Go to: https://drive.google.com
# Verify MyHome/ folder intact

# 3. Restore from Google Drive
rclone copy GoogleDrive-dtsioumas0:MyHome/ ~/.MyHome-restore/ -v

# 4. Compare and verify
diff -r ~/.MyHome/ ~/.MyHome-restore/

# 5. Manual recovery as needed
# Move files from MyHome-restore/ to MyHome/
```

---

### Scenario 4: Syncthing Issues

**Symptoms:**
- Syncthing service crashing
- Can't access Web GUI
- Port conflicts

**Solution:**

```bash
# Stop Syncthing
systemctl --user stop syncthing

# Check logs
journalctl --user -u syncthing -n 100

# Reset Syncthing config (nuclear option)
mv ~/.config/syncthing ~/.config/syncthing.backup
systemctl --user start syncthing

# Or just disable
systemctl --user disable syncthing
```

**Comment out in configuration.nix:**
```nix
# imports = [
#   ../../modules/workspace/syncthing-myspaces.nix
# ];
```

**Rebuild:**
```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
```

---

### Scenario 5: Firewall Issues

**Symptoms:**
- Can't access network
- KDE Connect not working
- Syncthing can't connect

**Solution:**

```bash
# Temporarily disable firewall (testing only!)
sudo systemctl stop firewall

# If that fixes it, rollback firewall config
cd ~/.config/nixos
git diff modules/system/firewall.nix

# Restore previous version
git checkout HEAD~1 modules/system/firewall.nix

# Rebuild
sudo nixos-rebuild switch --flake .#shoshin

# Re-enable firewall
sudo systemctl start firewall
```

---

## Complete Rollback Procedure

### Full Rollback to Pre-Deployment State

#### Step 1: NixOS Rollback
```bash
# Rollback to previous generation
sudo nixos-rebuild --rollback

# Or to specific pre-deployment tag
cd ~/.config/nixos
git checkout pre-deployment
sudo nixos-rebuild switch --flake .#shoshin
```

#### Step 2: Restore Old rclone Mount (if applicable)
```bash
# Enable old mount service
systemctl --user enable rclone-gdrive.service
systemctl --user start rclone-gdrive.service

# Verify
mount | grep GoogleDrive
```

#### Step 3: Disable New Services
```bash
# Disable bisync
sudo systemctl disable rclone-bisync.timer
sudo systemctl stop rclone-bisync.service

# Disable Syncthing
systemctl --user disable syncthing
systemctl --user stop syncthing
```

#### Step 4: Clean Up
```bash
# Optional: Remove MyHome directory
# ONLY if you don't need the local copy
# rm -rf ~/.MyHome/

# Remove bisync cache
rm -rf ~/.cache/rclone/bisync/

# Remove Syncthing config (if needed)
# mv ~/.config/syncthing ~/.config/syncthing.rollback
```

#### Step 5: Verify System
```bash
# Check services
systemctl --list-units --failed

# Check mount
mount | grep GoogleDrive

# Check Git repo
cd ~/.config/nixos
git status
```

---

## Case Study: Git Recovery (Nov 17, 2025)

**Full case study:** [archives/issues/2025-11-17-git-repository-recovery/](../../archives/issues/2025-11-17-git-repository-recovery/README.md)

### Quick Summary

**Date:** 2025-11-17
**Issue:** Git repository corruption in `~/.config/nixos/`
**Impact:** Repository unusable, `.git` directory damaged
**Resolution:** Re-initialized successfully, zero data loss
**Time:** ~15 minutes

### Recovery Commands

```bash
# 1. Backup broken git
mv .git .git.broken

# 2. Re-initialize
git init
git add .
git commit -m "Recovery: Re-initialize after corruption"

# 3. Verify
git status  # ✅ Clean
```

**Recovery commit:** `c6e4496`

### Key Learnings

✅ Files > History - All configs preserved
✅ Fast action prevented bigger issues
✅ Prevention: Commit before risky operations

**For detailed analysis, recovery script, and prevention measures, see the [full case study](../../archives/issues/2025-11-17-git-repository-recovery/README.md).**

---

## Diagnostic Commands

### Check What's Running
```bash
# All rclone processes
ps aux | grep rclone

# All systemd timers
systemctl list-timers --all

# Failed services
systemctl --list-units --failed
systemctl --user --list-units --failed

# Recent logs
journalctl -xe | tail -100
```

### Check Data Integrity
```bash
# Local MyHome file count
find ~/.MyHome/ -type f | wc -l

# GoogleDrive file count
rclone ls GoogleDrive-dtsioumas0:MyHome/ | wc -l

# Compare counts (should match)
```

### Check Configuration
```bash
# Current generation
ls -l /run/current-system

# Config syntax
cd ~/.config/nixos
nix flake check

# Git history
git log --oneline -10
```

---

## Post-Rollback Verification

After rollback, verify:

- [ ] System boots normally
- [ ] Old rclone mount accessible (if applicable)
- [ ] No failed services
- [ ] Git repository intact
- [ ] NixOS can rebuild
- [ ] Network functional
- [ ] User can login

**Quick Health Check:**
```bash
systemctl status
systemctl --user status
mount | grep GoogleDrive
cd ~/.config/nixos && git status
```

---

## Prevention for Next Time

**Before next deployment:**

1. ✅ Full home backup to external disk
2. ✅ Test build without activating (`nixos-rebuild test`)
3. ✅ More thorough pre-checks
4. ✅ Deploy during low-usage time
5. ✅ Have this document open
6. ✅ Don't rush - take your time

---

## After Rollback

**If you rolled back:**

1. Document what went wrong
2. Fix the issue in configuration
3. Test the fix
4. Try deployment again when ready

**Files to review:**
- Error logs in `/tmp/`
- `journalctl` output
- Configuration files
- This rollback document (add notes)

---

**Remember:** Rollback is not failure - it's safety! Better to rollback and fix than to have a broken system.

---

## References

- **Deployment Guide:** [deployment.md](deployment.md)
- **NixOS Generations:** https://nixos.org/manual/nixos/stable/#sec-rollback
- **rclone Recovery:** [rclone-gdrive.md#recovery-procedures](rclone-gdrive.md#recovery-procedures)

---

*Migrated from sessions/sync-integration/ on 2025-11-30*
