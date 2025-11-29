# RClone Bisync Best Practices Guide

**Created:** 2025-11-25
**Author:** Dimitris Tsioumas (Mitsio)
**Source:** Official rclone documentation + research

---

## Table of Contents

1. [Resilient Configuration](#1-resilient-configuration)
2. [Health Check Methods](#2-health-check-methods)
3. [Conflict Resolution](#3-conflict-resolution)
4. [Recovery Procedures](#4-recovery-procedures)
5. [Continuous Sync Setup](#5-continuous-sync-setup)
6. [Maintenance Tasks](#6-maintenance-tasks)
7. [Recommended Flags](#7-recommended-flags)

---

## 1. Resilient Configuration

### Set-It-And-Forget-It Setup

For a robust bisync that can automatically recover from most interruptions:

```bash
rclone bisync Path1 Path2 \
  --resilient \
  --recover \
  --max-lock 2m \
  --conflict-resolve newer
```

**Explanation:**
- `--resilient` - Allows retry after less-serious errors without requiring `--resync`
- `--recover` - Automatically recovers from interruptions using backup listings
- `--max-lock 2m` - Lock files expire after 2 minutes (prevents permanent lockouts)
- `--conflict-resolve newer` - Automatically resolves conflicts by keeping newer file

### Recovery Flags Difference

| Flag | Purpose |
|------|---------|
| `--resilient` | About **retrying** - allows retry on soft errors |
| `--recover` | About **recovering** - uses backup listings to recover from crashes |

**Use both for maximum resilience!**

---

## 2. Health Check Methods

### Method 1: Check-Access Files (Recommended)

Create sentinel files to verify both paths are accessible:

```bash
# Create RCLONE_TEST files
rclone touch Path1/RCLONE_TEST
rclone copyto Path1/RCLONE_TEST Path2/RCLONE_TEST

# Run bisync with check-access
rclone bisync Path1 Path2 --check-access
```

**Benefits:**
- Ensures both filesystems are accessible before sync
- Prevents data loss from failed mounts/network issues
- Aborts if RCLONE_TEST files are missing

### Method 2: Independent Integrity Check with `rclone check`

```bash
# Verify integrity between paths
rclone check -MvPc Path1 Path2 --filter-from /path/to/filters.txt
```

**Use cases:**
- Periodic verification (nightly/weekly)
- After suspected issues
- Before critical data operations

### Method 3: Bisync's Built-in Check-Sync

```bash
# Run only integrity check (no actual sync)
rclone bisync Path1 Path2 --check-sync=only
```

**Note:** This only checks listing snapshots, not actual files.

### Health Check Script Template

```bash
#!/usr/bin/env bash
# rclone-health-check.sh

REMOTE="GoogleDrive-dtsioumas0:MyHome/"
LOCAL="/home/mitsio/.MyHome/"
WORKDIR="$HOME/.cache/rclone/bisync-workdir"

echo "=== RClone Bisync Health Check ==="
echo "Date: $(date)"

# Check 1: Remote connectivity
echo ""
echo "[1/4] Testing remote connectivity..."
if rclone lsd "$REMOTE" >/dev/null 2>&1; then
  echo "  ✅ Remote accessible"
else
  echo "  ❌ Remote NOT accessible"
  exit 1
fi

# Check 2: Baseline integrity
echo ""
echo "[2/4] Checking baseline integrity..."
LST1="$WORKDIR/*.path1.lst"
LST2="$WORKDIR/*.path2.lst"
if [ -f $LST1 ] && [ -f $LST2 ]; then
  SIZE1=$(wc -l < $LST1 2>/dev/null)
  SIZE2=$(wc -l < $LST2 2>/dev/null)
  if [ "$SIZE1" = "$SIZE2" ]; then
    echo "  ✅ Baselines equal ($SIZE1 files)"
  else
    echo "  ⚠️ Baselines differ (Path1: $SIZE1, Path2: $SIZE2)"
  fi
else
  echo "  ❌ Baseline files missing"
fi

# Check 3: Lock file
echo ""
echo "[3/4] Checking for lock files..."
LOCK_FILE="$WORKDIR/*.lck"
if ls $LOCK_FILE 1>/dev/null 2>&1; then
  echo "  ⚠️ Lock file exists - sync may be running or crashed"
else
  echo "  ✅ No lock file"
fi

# Check 4: Conflict files
echo ""
echo "[4/4] Checking for conflicts..."
CONFLICTS=$(find "$LOCAL" -name "*.conflict*" 2>/dev/null | wc -l)
if [ "$CONFLICTS" -gt 0 ]; then
  echo "  ⚠️ Found $CONFLICTS conflict files"
else
  echo "  ✅ No conflict files"
fi

echo ""
echo "=== Health Check Complete ==="
```

---

## 3. Conflict Resolution

### Understanding Conflicts

A "conflict" occurs when a file is:
- New or changed on BOTH sides (since last sync)
- AND not currently identical on both sides

### Resolution Options

| Option | Behavior |
|--------|----------|
| `none` | (default) Keep both versions, rename with suffix |
| `newer` | Keep newer file (by modtime) |
| `older` | Keep older file |
| `larger` | Keep larger file (by size) |
| `smaller` | Keep smaller file |
| `path1` | Always prefer Path1 version |
| `path2` | Always prefer Path2 version |

### Conflict Loser Options

```bash
--conflict-loser num       # Auto-number: file.txt.conflict1, file.txt.conflict2
--conflict-loser pathname  # By path: file.txt.path1, file.txt.path2
--conflict-loser delete    # Delete loser (DANGEROUS - use with care!)
```

### Recommended Configuration

```bash
# For automatic resolution (newer wins, loser gets numbered suffix)
--conflict-resolve newer --conflict-loser num --conflict-suffix conflict

# For manual review (keep both with path suffix)
--conflict-resolve none --conflict-loser pathname --conflict-suffix .sync
```

---

## 4. Recovery Procedures

### When `--resync` is Required

Only use `--resync` in these situations:
1. **First bisync run** (initial setup)
2. **Filter file changes** (modified `--filters-file`)
3. **Critical error recovery** (when bisync demands it)

**DO NOT use `--resync` for every run!** It will prevent deletions from syncing.

### Resync Modes

```bash
--resync                    # Equivalent to --resync-mode path1
--resync-mode path1         # Local (Path1) is source of truth
--resync-mode path2         # Remote (Path2) is source of truth
--resync-mode newer         # Keep newer files from either side
--resync-mode older         # Keep older files
--resync-mode larger        # Keep larger files
--resync-mode smaller       # Keep smaller files
```

### Recovery Workflow

```bash
# Step 1: Dry-run to see what would happen
rclone bisync Path1 Path2 --resync --resync-mode path1 --dry-run -v

# Step 2: If looks good, run actual resync
rclone bisync Path1 Path2 --resync --resync-mode path1 -v

# Step 3: Resume normal syncs (WITHOUT --resync!)
rclone bisync Path1 Path2 --resilient --recover -v
```

### Graceful Shutdown

When you need to stop a running bisync:

1. **First `Ctrl+C`** - Triggers graceful shutdown (30 seconds to complete current transfers)
2. **Second `Ctrl+C`** - Forces immediate exit (may leave messy state)

**Best practice:** Always try graceful shutdown first!

---

## 5. Continuous Sync Setup

### Cron Schedule (Recommended)

```bash
# Every 30 minutes
*/30 * * * * /path/to/rclone bisync /local/path remote:path --resilient --recover --max-lock 2m >> /path/to/bisync.log 2>&1

# Every hour
0 * * * * /path/to/rclone bisync /local/path remote:path --check-access --resilient --recover >> /path/to/bisync.log 2>&1
```

### Systemd Timer (NixOS/Linux)

```nix
# In home-manager or systemd config
systemd.user.timers.rclone-bisync = {
  Timer = {
    OnBootSec = "5min";
    OnUnitActiveSec = "1h";
    Persistent = true;
    RandomizedDelaySec = "2min";
  };
  Install.WantedBy = [ "timers.target" ];
};
```

### Important: Lock File Behavior

- Lock files prevent concurrent bisync runs
- Location: `~/.cache/rclone/bisync/PATH1..PATH2.lck`
- Use `--max-lock` to auto-expire stale locks
- Delete manually if bisync crashed

---

## 6. Maintenance Tasks

### Regular Maintenance Checklist

**Daily:**
- [ ] Verify systemd timer is active
- [ ] Check for error notifications

**Weekly:**
- [ ] Review conflict files and resolve
- [ ] Check log file sizes
- [ ] Verify backup-dir isn't growing too large

**Monthly:**
- [ ] Run independent integrity check (`rclone check`)
- [ ] Review and clean old log files
- [ ] Verify RCLONE_TEST files exist (if using `--check-access`)

### Cleanup Commands

```bash
# Remove conflict files (after review!)
find ~/.MyHome -name "*.conflict*" -type f -delete

# Rotate old logs
find ~/.cache/rclone -name "bisync-*.log" -mtime +30 -delete

# Clear stale lock files (ONLY if no sync running!)
rm ~/.cache/rclone/bisync-workdir/*.lck
```

### Backup Directory Management

```bash
# Use backup-dir to preserve deleted files
rclone bisync Path1 Path2 \
  --backup-dir1 /path/to/backup1 \
  --backup-dir2 remote:backup2 \
  --suffix -$(date +%Y-%m-%d) \
  --suffix-keep-extension
```

---

## 7. Recommended Flags

### Production Configuration

```bash
rclone bisync /home/user/.MyHome/ GoogleDrive:MyHome/ \
  --workdir ~/.cache/rclone/bisync-workdir \
  --compare size,modtime,checksum \
  --resilient \
  --recover \
  --max-lock 2m \
  --conflict-resolve newer \
  --create-empty-src-dirs \
  --drive-skip-gdocs \
  --check-access \
  --max-delete 50 \
  --verbose \
  --log-file ~/.cache/rclone/bisync.log
```

### Flag Reference

| Flag | Purpose | Recommendation |
|------|---------|----------------|
| `--compare size,modtime,checksum` | Compare by all three attributes | Use for maximum accuracy |
| `--resilient` | Retry on soft errors | Always use |
| `--recover` | Recover from crashes | Always use |
| `--max-lock 2m` | Auto-expire locks | Use 2-5 minutes |
| `--check-access` | Verify paths accessible | Use in production |
| `--max-delete 50` | Safety limit on deletes | Adjust based on needs |
| `--drive-skip-gdocs` | Skip Google Docs | Use with Google Drive |
| `--create-empty-src-dirs` | Sync empty directories | Optional |
| `--verbose` | Detailed logging | Recommended |

### Exclude Patterns for Common Issues

```text
# Recommended exclusions
--exclude '.git/**'           # Git internals (if not syncing repos)
--exclude '.obsidian/workspace.json'  # Frequently changing
--exclude 'result'            # Nix build outputs
--exclude 'result-*'
--exclude '*.swp'             # Vim swap files
--exclude '*.tmp'             # Temporary files
--exclude '.stversions/**'    # Syncthing versions
--exclude 'node_modules/**'   # NPM modules
--exclude '__pycache__/**'    # Python cache
```

---

## Quick Reference Card

### Essential Commands

```bash
# First-time setup
rclone bisync Path1 Path2 --resync --dry-run -v
rclone bisync Path1 Path2 --resync -v

# Normal runs
rclone bisync Path1 Path2 --resilient --recover -v

# Recovery after error
rclone bisync Path1 Path2 --resync --resync-mode path1 -v

# Health check
rclone check Path1 Path2 -MvPc

# Status check
rclone bisync Path1 Path2 --check-sync=only
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Non-critical failure (can retry) |
| 2 | Syntax/usage error |
| 7 | Critical abort (requires `--resync`) |

---

## References

- [Official Bisync Documentation](https://rclone.org/bisync/)
- [Rclone Filtering](https://rclone.org/filtering/)
- [Rclone Forum](https://forum.rclone.org/)
- [Bisync Command Reference](https://rclone.org/commands/rclone_bisync/)
