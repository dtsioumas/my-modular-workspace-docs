# RClone Google Drive Sync Guide

**Last Updated:** 2025-11-29
**Sources Merged:** BEST_PRACTICES.md, Health_Status_Report_25-11-2025.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Best Practices](#best-practices)
- [Health Monitoring](#health-monitoring)
- [Conflict Resolution](#conflict-resolution)
- [Recovery Procedures](#recovery-procedures)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

RClone bisync provides bidirectional synchronization between local files and Google Drive.

**Current Setup:**
- **Local Path:** `/home/mitsio/.MyHome/`
- **Remote:** `GoogleDrive-dtsioumas0:MyHome/`
- **Workdir:** `~/.cache/rclone/bisync-workdir/`
- **Schedule:** Every hour via systemd timer
- **Automation:** Ansible playbook (`ansible/playbooks/rclone-gdrive-sync.yml`)

---

## Quick Start

### Essential Commands

```bash
# Normal sync (resilient mode)
rclone bisync ~/.MyHome/ GoogleDrive-dtsioumas0:MyHome/ \
  --resilient --recover -v

# Check status
systemctl --user status rclone-gdrive-sync.timer

# Manual sync
systemctl --user start rclone-gdrive-sync

# View logs
journalctl --user -u rclone-gdrive-sync -f
```

### First-time Setup

```bash
# 1. Dry-run to preview
rclone bisync Path1 Path2 --resync --dry-run -v

# 2. Initial resync
rclone bisync Path1 Path2 --resync -v

# 3. Normal runs (NO --resync!)
rclone bisync Path1 Path2 --resilient --recover -v
```

---

## Configuration

### Production Configuration

```bash
rclone bisync /home/mitsio/.MyHome/ GoogleDrive-dtsioumas0:MyHome/ \
  --workdir ~/.cache/rclone/bisync-workdir \
  --compare size,modtime,checksum \
  --resilient \
  --recover \
  --max-lock 2m \
  --conflict-resolve newer \
  --create-empty-src-dirs \
  --drive-skip-gdocs \
  --max-delete 50 \
  --verbose \
  --log-file ~/.cache/rclone/bisync.log
```

### Recommended Exclude Patterns

```text
--exclude 'result'
--exclude 'result-*'
--exclude '*.swp'
--exclude '*.tmp'
--exclude '.stversions/**'
--exclude '.obsidian/workspace.json'
--exclude '.obsidian/workspace-mobile.json'
```

### Flag Reference

| Flag | Purpose |
|------|---------|
| `--compare size,modtime,checksum` | Compare by all attributes |
| `--resilient` | Retry on soft errors |
| `--recover` | Recover from crashes |
| `--max-lock 2m` | Auto-expire locks |
| `--max-delete 50` | Safety limit on deletes |
| `--drive-skip-gdocs` | Skip Google Docs |

---

## Best Practices

### Set-It-And-Forget-It Setup

```bash
rclone bisync Path1 Path2 \
  --resilient \
  --recover \
  --max-lock 2m \
  --conflict-resolve newer
```

### When to Use --resync

**ONLY use `--resync` in these situations:**
1. First bisync run (initial setup)
2. Filter file changes (modified exclude patterns)
3. Critical error recovery (when bisync demands it)

**DO NOT use `--resync` for every run!** It prevents deletions from syncing.

### Resync Modes

```bash
--resync-mode path1   # Local is source of truth
--resync-mode path2   # Remote is source of truth
--resync-mode newer   # Keep newer files
```

---

## Health Monitoring

### Health Check Script

```bash
#!/usr/bin/env bash
REMOTE="GoogleDrive-dtsioumas0:MyHome/"
LOCAL="/home/mitsio/.MyHome/"
WORKDIR="$HOME/.cache/rclone/bisync-workdir"

echo "=== RClone Bisync Health Check ==="

# Check 1: Remote connectivity
echo "[1/4] Testing remote connectivity..."
rclone lsd "$REMOTE" >/dev/null 2>&1 && echo "✅ Remote OK" || echo "❌ Remote FAILED"

# Check 2: Baseline integrity
echo "[2/4] Checking baselines..."
LST1=$(ls $WORKDIR/*.path1.lst 2>/dev/null | head -1)
LST2=$(ls $WORKDIR/*.path2.lst 2>/dev/null | head -1)
if [ -f "$LST1" ] && [ -f "$LST2" ]; then
  SIZE1=$(wc -l < "$LST1")
  SIZE2=$(wc -l < "$LST2")
  [ "$SIZE1" = "$SIZE2" ] && echo "✅ Baselines equal ($SIZE1 files)" || echo "⚠️ Baselines differ"
fi

# Check 3: Lock file
echo "[3/4] Checking lock files..."
ls $WORKDIR/*.lck 2>/dev/null && echo "⚠️ Lock exists" || echo "✅ No lock"

# Check 4: Conflicts
echo "[4/4] Checking conflicts..."
CONFLICTS=$(find "$LOCAL" -name "*.conflict*" 2>/dev/null | wc -l)
[ "$CONFLICTS" -gt 0 ] && echo "⚠️ $CONFLICTS conflicts" || echo "✅ No conflicts"
```

### Maintenance Checklist

**Daily:**
- Verify systemd timer is active
- Check for error notifications

**Weekly:**
- Review and resolve conflict files
- Check log file sizes

**Monthly:**
- Run independent integrity check (`rclone check`)
- Clean old log files

---

## Conflict Resolution

### Understanding Conflicts

A conflict occurs when a file is new/changed on BOTH sides since last sync.

### Resolution Options

| Option | Behavior |
|--------|----------|
| `none` | Keep both versions (default) |
| `newer` | Keep newer file (recommended) |
| `path1` | Always prefer local |
| `path2` | Always prefer remote |

### Recommended Configuration

```bash
--conflict-resolve newer --conflict-loser num --conflict-suffix conflict
```

### Cleanup Commands

```bash
# Preview conflicts
find ~/.MyHome -name "*.conflict*" -type f

# Remove after review
find ~/.MyHome -name "*.conflict*" -type f -delete
```

---

## Recovery Procedures

### Recovery Workflow

```bash
# Step 1: Dry-run
rclone bisync Path1 Path2 --resync --resync-mode path1 --dry-run -v

# Step 2: If good, run actual resync
rclone bisync Path1 Path2 --resync --resync-mode path1 -v

# Step 3: Resume normal syncs (WITHOUT --resync!)
rclone bisync Path1 Path2 --resilient --recover -v
```

### Clear Stale Lock

```bash
# ONLY if no sync running!
rm ~/.cache/rclone/bisync-workdir/*.lck
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Non-critical failure (can retry) |
| 2 | Syntax/usage error |
| 7 | Critical abort (requires `--resync`) |

---

## Troubleshooting

### "Too many deletes" Error

**Cause:** Safety limit triggered (>50 deletes)
**Solution:** Increase `--max-delete` or investigate why so many files differ

### Baseline Mismatch

**Cause:** Exclude patterns changed, or interrupted sync
**Solution:** Resync with `--resync --resync-mode path1`

### Lock File Stuck

```bash
# Check if sync is running
pgrep -f "rclone bisync"

# If not running, remove lock
rm ~/.cache/rclone/bisync-workdir/*.lck
```

### Sync Not Running

```bash
# Check timer
systemctl --user status rclone-gdrive-sync.timer

# Enable if needed
systemctl --user enable --now rclone-gdrive-sync.timer
```

---

## References

- **Official Docs:** https://rclone.org/bisync/
- **Filtering:** https://rclone.org/filtering/
- **Forum:** https://forum.rclone.org/
- **Ansible Playbook:** `ansible/playbooks/rclone-gdrive-sync.yml`
- **Home-Manager Module:** `home-manager/rclone-gdrive.nix`

---

*Migrated from docs/commons/integrations/rclone-gdrive-sync/ on 2025-11-29*
