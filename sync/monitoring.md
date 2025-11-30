# Sync System Monitoring

**Last Updated:** 2025-11-30
**Sources:** rclone-gdrive.md health check script, sessions/sync-integration TODO Section 11
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Quick Health Check](#quick-health-check)
- [Manual Monitoring](#manual-monitoring)
- [Automated Monitoring (Planned)](#automated-monitoring-planned)
- [Log Analysis](#log-analysis)
- [Alert Configuration](#alert-configuration)
- [Metrics to Track](#metrics-to-track)

---

## Overview

Monitoring ensures your sync infrastructure is healthy and operating correctly.

**Current Status:**
- ✅ Manual health checks available
- ✅ Helper scripts for status checking
- ⏳ Automated monitoring playbooks (planned)

**Goals:**
- Early detection of sync failures
- Conflict awareness
- Performance monitoring
- Automated health checks

---

## Quick Health Check

### One-Command Health Check

```bash
#!/usr/bin/env bash
# Quick sync health check

echo "=== RClone Bisync Health Check ==="

# Check 1: Remote connectivity
echo "[1/4] Testing remote connectivity..."
rclone lsd GoogleDrive-dtsioumas0:MyHome/ >/dev/null 2>&1 && \
  echo "✅ Remote OK" || echo "❌ Remote FAILED"

# Check 2: Timer status
echo "[2/4] Checking timer..."
systemctl is-active rclone-bisync.timer >/dev/null 2>&1 && \
  echo "✅ Timer active" || echo "❌ Timer inactive"

# Check 3: Conflicts
echo "[3/4] Checking conflicts..."
CONFLICTS=$(find ~/.MyHome -name "*.conflict*" 2>/dev/null | wc -l)
[ "$CONFLICTS" -eq 0 ] && echo "✅ No conflicts" || echo "⚠️  $CONFLICTS conflicts"

# Check 4: Syncthing
echo "[4/4] Checking Syncthing..."
systemctl --user is-active syncthing >/dev/null 2>&1 && \
  echo "✅ Syncthing running" || echo "❌ Syncthing stopped"
```

**Save as:** `~/bin/sync-health-check.sh`

---

## Manual Monitoring

### Check Sync Status

```bash
# Using helper script
sync-gdrive-status

# Manual check
systemctl list-timers rclone-bisync.timer
journalctl --user -u rclone-bisync -n 20
```

**What to look for:**
- Next scheduled sync time
- Recent sync results
- No error messages in logs

### Check for Conflicts

```bash
# Find all conflicts
find ~/.MyHome -name "*.conflict*" -type f

# Count conflicts
find ~/.MyHome -name "*.conflict*" -type f | wc -l

# Group by type
find ~/.MyHome -name "*.conflict*" -type f -exec basename {} \; | \
  sed 's/\.conflict.*//' | sort | uniq -c
```

**Action:** Resolve conflicts weekly (see [conflicts.md](conflicts.md))

### Check Bisync Baseline

```bash
WORKDIR="$HOME/.cache/rclone/bisync-workdir"

# Check baseline files exist
ls -lh $WORKDIR/*.path1.lst $WORKDIR/*.path2.lst 2>/dev/null

# Compare baseline sizes
LST1=$(ls $WORKDIR/*.path1.lst 2>/dev/null | head -1)
LST2=$(ls $WORKDIR/*.path2.lst 2>/dev/null | head -1)

if [ -f "$LST1" ] && [ -f "$LST2" ]; then
  SIZE1=$(wc -l < "$LST1")
  SIZE2=$(wc -l < "$LST2")
  echo "Path1 files: $SIZE1"
  echo "Path2 files: $SIZE2"
  [ "$SIZE1" = "$SIZE2" ] && echo "✅ Baselines equal" || echo "⚠️ Baselines differ"
fi
```

**What to look for:**
- Both baseline files exist
- File counts are equal or close

### Check Lock Files

```bash
# Check for stale locks
ls -lh ~/.cache/rclone/bisync-workdir/*.lck 2>/dev/null

# If lock older than 24h and no sync running:
# rm ~/.cache/rclone/bisync-workdir/*.lck
```

**Warning:** Only remove locks if certain no sync is running!

### Check Syncthing

```bash
# Using helper script
syncthing-status

# Check connections
curl -s http://localhost:8384/rest/system/connections | jq

# Check sync status
curl -s http://localhost:8384/rest/db/status?folder=my-modular-workspace | jq
```

---

## Automated Monitoring (Planned)

### Google Drive Health Check Playbook

**Status:** 📋 Planned (not yet implemented)

**Purpose:** Daily automated health check

**Tasks:**
- Run `rclone check` between local and remote
- Detect file corruption (checksum mismatches)
- Find duplicates
- Check quota usage
- Log results
- Desktop notification with summary

**Planned location:** `ansible/playbooks/gdrive-health-check.yml`

**Schedule:** Daily (09:00)

**Log:** `~/.logs/maintenance/gdrive-health-YYYY-MM-DD.jsonl`

**See:** TODO.md Section 6, Phase 6

---

### Conflict Hunter Playbook

**Status:** 📋 Planned (not yet implemented)

**Purpose:** Daily automated conflict detection

**Tasks:**
- Find all `.conflictN` files in bisync workdir
- Find all "conflicted copy" files in Google Drive
- Analyze conflict age
- Group by file type
- Generate resolution recommendations
- Desktop notification with conflict count

**Planned location:** `ansible/playbooks/conflict-hunter.yml`

**Schedule:** Daily (09:15)

**Log:** `~/.logs/maintenance/gdrive-conflicts-YYYY-MM-DD.jsonl`

**See:** TODO.md Section 6, Phase 6

---

### Bisync Workdir Integrity Check

**Status:** 📋 Planned (not yet implemented)

**Purpose:** Weekly verification of bisync state

**Tasks:**
- Verify bisync database not corrupted
- Check for stale locks (>24h)
- Validate listings are consistent
- Check for test artifacts
- Notify if resync required

**Schedule:** Weekly (Sunday 09:30)

---

## Log Analysis

### rclone bisync Logs

**Location:** `~/.cache/rclone/bisync-*.log`

**View latest log:**
```bash
ls -t ~/.cache/rclone/bisync-*.log | head -1 | xargs less
```

**Search for errors:**
```bash
grep -i error ~/.cache/rclone/bisync-*.log | tail -20
```

**Common log messages:**

| Message | Meaning | Action |
|---------|---------|--------|
| `Bisync successful` | Sync completed OK | None |
| `Resync is required` | Baseline mismatch | Run `sync-gdrive-resync` |
| `too many deletes` | Safety limit hit | Investigate why |
| `conflicts found` | Bidirectional changes | Resolve conflicts |

### Systemd Journal Logs

```bash
# Recent sync logs
journalctl --user -u rclone-bisync -n 50

# Follow live
journalctl --user -u rclone-bisync -f

# Filter by time
journalctl --user -u rclone-bisync --since today

# Only errors
journalctl --user -u rclone-bisync -p err
```

### Syncthing Logs

```bash
# Systemd logs
journalctl --user -u syncthing -n 50

# Syncthing internal logs (via API)
curl -s http://localhost:8384/rest/system/log | jq
```

---

## Alert Configuration

### Desktop Notifications

**Current implementation:**
- Ansible playbook sends notifications via `notify-send`
- Success: ✅ "Google Drive sync completed"
- Conflicts: ⚠️ "Sync completed with conflicts"
- Failure: ❌ "Sync failed - check logs"

**Planned enhancements:**
- Add conflict file list to notification
- Add error preview (first 5 lines of log)
- Include log file path in notification

**See:** TODO.md Section 6, Phase 5

### Email Notifications (Optional)

For critical errors only:

```nix
# In systemd service config:
OnFailure = "email-admin@%n.service";
```

*Requires email setup - skip if not needed*

---

## Metrics to Track

### Sync Performance

| Metric | How to Check | Target |
|--------|--------------|--------|
| Sync frequency | `systemctl list-timers` | Every hour |
| Sync duration | Check logs | < 2 minutes |
| Files synced | rclone log output | Varies |
| Conflicts per week | `find ... | wc -l` | < 5 |

### System Health

| Metric | How to Check | Target |
|--------|--------------|--------|
| Timer active | `systemctl is-active` | active |
| Service failures | `journalctl -p err` | 0 |
| Lock files | `ls *.lck` | 0 |
| Baseline integrity | Compare lst sizes | Equal |

### Storage

| Metric | How to Check | Target |
|--------|--------------|--------|
| Local disk usage | `du -sh ~/.MyHome` | < 80% of / |
| GDrive quota | `rclone about` | < 90% |
| Log disk usage | `du -sh ~/.cache/rclone` | < 1GB |

---

## Maintenance Schedule

### Daily
- ✅ Check `sync-gdrive-status` once
- ✅ Verify no failed notifications
- ⏳ Automated health check (when implemented)

### Weekly
- ✅ Review sync logs
- ✅ Resolve conflicts
- ✅ Check Syncthing connections
- ⏳ Automated integrity check (when implemented)

### Monthly
- ✅ Review Syncthing versioning
- ✅ Clean old logs (manual for now)
- ✅ Check disk usage
- ✅ Verify backup disk accessible

---

## Troubleshooting

### Sync Not Running

```bash
# Check timer
systemctl list-timers rclone-bisync.timer

# If not listed, enable it
systemctl --user enable --now rclone-bisync.timer
```

### High Sync Duration

```bash
# Check file counts
find ~/.MyHome -type f | wc -l

# Check for large files
find ~/.MyHome -type f -size +100M

# Consider excluding large files
# Edit exclude patterns in playbook
```

### Persistent Conflicts

See [conflicts.md#conflict-prevention](conflicts.md) for strategies.

---

## References

- **Helper Scripts:** Check `sync-gdrive-status`, `syncthing-status`
- **Ansible Playbooks:** [ansible-playbooks.md](ansible-playbooks.md)
- **Conflict Resolution:** [conflicts.md](conflicts.md)
- **rclone bisync:** [rclone-gdrive.md](rclone-gdrive.md)
- **Planned Improvements:** TODO.md Section 6, Phase 6

---

*Created 2025-11-30 from rclone-gdrive.md health check script and session TODO Section 11*
