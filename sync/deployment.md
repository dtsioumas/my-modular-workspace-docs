# Sync System Deployment Guide

**Last Updated:** 2025-11-30
**Sources:** sessions/sync-integration/gdrive-migration-syncthing-backup/
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Deployment Procedure](#deployment-procedure)
- [Post-Deployment Verification](#post-deployment-verification)
- [Troubleshooting](#troubleshooting)

---

## Overview

This guide covers deploying rclone bisync and Syncthing for the sync infrastructure.

**What this deployment does:**
- Sets up bidirectional Google Drive sync (rclone bisync)
- Configures Syncthing for real-time device sync
- Enables hourly automatic sync
- Provides helper scripts for management

**Estimated Time:** 30-60 minutes

---

## Quick Start

For experienced users who have completed pre-deployment checks:

```bash
# 1. Initial resync
rclone bisync ~/.MyHome/ GoogleDrive-dtsioumas0:MyHome/ \
  --resync --dry-run -v  # Dry run first!

# 2. Real resync (if dry run looks good)
rclone bisync ~/.MyHome/ GoogleDrive-dtsioumas0:MyHome/ \
  --resync -v --progress

# 3. Deploy configuration
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin

# 4. Verify services
systemctl list-timers rclone-bisync.timer
systemctl --user status syncthing
```

---

## Prerequisites

### System Health Checks

Run all checks before deployment:

#### 1. Git Repository
```bash
cd ~/.config/nixos
git status  # Should be clean or ready to commit
```

**Required:** Clean working directory with modules committed

#### 2. rclone Configuration
```bash
rclone listremotes  # Should show: GoogleDrive-dtsioumas0:
```

**Required:** Google Drive remote configured

#### 3. Disk Space
```bash
df -h /  # Need at least 20GB free
```

**Required:** Sufficient space for sync

#### 4. Network Connectivity
```bash
ping -c 3 8.8.8.8
rclone lsd GoogleDrive-dtsioumas0:
```

**Required:** Internet and Google Drive accessible

#### 5. NixOS Configuration Test
```bash
cd ~/.config/nixos
sudo nixos-rebuild test --flake .#shoshin
```

**Required:** Configuration builds without errors

### Time Requirements

- **Initial resync:** 10-30 minutes (depends on data size)
- **Deployment:** 5-10 minutes
- **Verification:** 10-15 minutes
- **Total:** 30-60 minutes

**Ensure you have uninterrupted time available.**

---

## Deployment Procedure

Follow these steps in order:

### Step 1: Git Commit Current State

**Purpose:** Safety checkpoint for rollback

```bash
cd ~/.config/nixos

# Check what's new
git status

# Stage new modules
git add modules/workspace/rclone-bisync.nix
git add modules/workspace/syncthing-myspaces.nix

# Commit with detailed message
git commit -m "feat: Add rclone bisync & Syncthing

- Add rclone-bisync.nix: Bidirectional sync hourly
- Add syncthing-myspaces.nix: Real-time device sync
- Update firewall for Syncthing ports

Deployment: $(date +%Y-%m-%d)"

# Tag for easy rollback
git tag -a pre-deployment -m "State before sync deployment"

# Verify
git log --oneline -3
```

**Checkpoint:** ✅ Git commit successful

---

### Step 2: Stop Old rclone Mount (if applicable)

If you're migrating from rclone mount:

```bash
# Stop mount service
systemctl --user stop rclone-gdrive.service
systemctl --user disable rclone-gdrive.service

# Verify mount removed
mount | grep GoogleDrive || echo "Mount removed"
```

**Note:** GoogleDrive will be inaccessible until bisync is configured!

**Checkpoint:** ✅ Old mount stopped

---

### Step 3: Initial rclone bisync Resync

**IMPORTANT:** First run MUST use `--resync` flag!

#### 3a. Dry Run (Recommended)

```bash
# Create local directory
mkdir -p ~/.MyHome

# Test with --dry-run
rclone bisync \
  ~/.MyHome/ \
  GoogleDrive-dtsioumas0:MyHome/ \
  --resync \
  --dry-run \
  --verbose \
  --compare size,modtime,checksum \
  --create-empty-src-dirs \
  --drive-skip-gdocs \
  2>&1 | tee /tmp/bisync-dryrun.log

# Review output
tail -50 /tmp/bisync-dryrun.log
```

**Review the dry run output carefully!**
- Check files that will be downloaded
- Check for unexpected deletions
- Verify no errors

**Checkpoint:** ✅ Dry run successful

#### 3b. Real Resync

Only proceed if dry run looks correct:

```bash
# Run REAL resync
echo "⚠️ Starting resync - this will take 10-30 minutes..."

rclone bisync \
  ~/.MyHome/ \
  GoogleDrive-dtsioumas0:MyHome/ \
  --resync \
  --verbose \
  --compare size,modtime,checksum \
  --create-empty-src-dirs \
  --drive-skip-gdocs \
  --progress \
  2>&1 | tee /tmp/bisync-resync.log

# Verify success
if [ $? -eq 0 ]; then
    echo "✅ Resync completed successfully!"
else
    echo "❌ Resync failed! Check /tmp/bisync-resync.log"
    exit 1
fi

# Verify files
ls -lah ~/.MyHome/ | head -20
find ~/.MyHome/ -type f | wc -l
```

**Checkpoint:** ✅ Real resync completed

---

### Step 4: Deploy NixOS Configuration

```bash
cd ~/.config/nixos

# Build and activate
echo "🔨 Building NixOS configuration..."
sudo nixos-rebuild switch --flake .#shoshin 2>&1 | tee /tmp/nixos-rebuild.log

# Check for errors
if [ $? -eq 0 ]; then
    echo "✅ NixOS rebuild successful!"
else
    echo "❌ Build failed! Check /tmp/nixos-rebuild.log"
    exit 1
fi

# List new generation
sudo nixos-rebuild list-generations | tail -5
```

**Checkpoint:** ✅ NixOS deployment successful

---

### Step 5: Verify Services

#### rclone bisync
```bash
# Check timer is active
systemctl list-timers rclone-bisync.timer

# Check service status
systemctl status rclone-bisync.service

# Verify helper scripts
which sync-gdrive sync-gdrive-status sync-gdrive-resync
```

**Expected:** Timer active, scheduled hourly

#### Syncthing
```bash
# Check service
systemctl --user status syncthing

# Verify helper scripts
which syncthing-status syncthing-open syncthing-id

# Check firewall ports
sudo iptables -L -n | grep 22000
```

**Expected:** Service running, ports open

**Checkpoint:** ✅ Services verified

---

### Step 6: Test Sync

```bash
# Create test file
echo "Test from shoshin - $(date)" > ~/.MyHome/test-deployment.txt

# Trigger manual sync
sync-gdrive

# Verify in GoogleDrive
rclone ls GoogleDrive-dtsioumas0:MyHome/ | grep test-deployment

# Clean up
rm ~/.MyHome/test-deployment.txt
sync-gdrive
```

**Expected:** File syncs to Google Drive successfully

**Checkpoint:** ✅ Sync test successful

---

### Step 7: Enable Automatic Sync

```bash
# Verify timer enabled
systemctl is-enabled rclone-bisync.timer

# Check next run time
systemctl list-timers rclone-bisync.timer

# Show schedule
echo "Next sync: $(systemctl list-timers rclone-bisync.timer --no-pager | grep rclone | awk '{print $1, $2}')"
echo "Frequency: Hourly"
```

**Checkpoint:** ✅ Automatic sync enabled

---

## Post-Deployment Verification

### Final Verification Summary

```bash
echo "═══ DEPLOYMENT VERIFICATION ═══"

# Check all services
echo "🔄 rclone bisync timer:"
systemctl is-active rclone-bisync.timer && echo "  ✅ Active" || echo "  ❌ Inactive"

echo ""
echo "📱 Syncthing service:"
systemctl --user is-active syncthing && echo "  ✅ Active" || echo "  ❌ Inactive"

echo ""
echo "🔥 Firewall:"
sudo iptables -L -n | grep -q 22000 && echo "  ✅ Ports open" || echo "  ❌ Ports closed"

echo ""
echo "📁 Local MyHome:"
[ -d ~/.MyHome ] && echo "  ✅ Exists" || echo "  ❌ Missing"

echo ""
echo "🎯 Helper scripts:"
which sync-gdrive > /dev/null && echo "  ✅ Available" || echo "  ❌ Missing"
```

### Deployment Success Criteria

All must be ✅:
- [ ] rclone bisync timer active
- [ ] Syncthing service running
- [ ] Firewall ports open
- [ ] Local MyHome directory exists
- [ ] Helper scripts available
- [ ] Manual sync tested successfully
- [ ] No failed services

---

## Troubleshooting

### Build Fails

```bash
# Check error log
cat /tmp/nixos-rebuild.log | grep error

# Test syntax
cd ~/.config/nixos
nix flake check

# Rollback if needed
sudo nixos-rebuild --rollback
```

### Resync Fails

```bash
# Check connectivity
rclone lsd GoogleDrive-dtsioumas0:

# Check permissions
ls -la ~/.MyHome/

# Review log
cat /tmp/bisync-resync.log | grep ERROR
```

### Services Not Starting

```bash
# Check failed services
systemctl --list-units --failed
systemctl --user --list-units --failed

# View logs
journalctl -u rclone-bisync.service -n 50
journalctl --user -u syncthing -n 50
```

---

## Next Steps

After successful deployment:

1. ✅ **Monitor for 24 hours** - Watch first few automatic syncs
2. 📱 **Setup Android** - Pair Syncthing with mobile device
3. 🔍 **Review conflicts** - Check for any conflict files
4. 📚 **Read monitoring guide** - See [monitoring.md](monitoring.md)

---

## References

- **Post-Deployment:** [See session files](../../sessions/sync-integration/gdrive-migration-syncthing-backup/POST_DEPLOYMENT.md)
- **Rollback Procedures:** [disaster-recovery.md](disaster-recovery.md)
- **rclone Guide:** [rclone-gdrive.md](rclone-gdrive.md)
- **Syncthing Guide:** [syncthing.md](syncthing.md)

---

*Migrated from sessions/sync-integration/ on 2025-11-30*
