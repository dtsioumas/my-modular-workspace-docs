# RClone Google Drive Sync Guide

**Last Updated:** 2025-12-21
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
# Normal sync (via wrapper)
sync-gdrive

# Check status
systemctl --user status rclone-gdrive-sync.timer

# Manual resync (Fix DB corruption)
sync-gdrive-resync

# View logs
journalctl --user -u rclone-gdrive-sync -f
```

---

## Configuration

### Production Configuration (Ansible Managed)

The Ansible playbook applies the following configuration:

```bash
rclone bisync /home/mitsio/.MyHome/ GoogleDrive-dtsioumas0:MyHome/ \
  --workdir ~/.cache/rclone/bisync-workdir \
  --compare size,modtime,checksum \
  --resilient \
  --recover \
  --max-lock 2m \
  --conflict-resolve path1 \
  --create-empty-src-dirs \
  --drive-skip-gdocs \
  --max-delete 199 \
  --retries 3 \
  --timeout 10m \
  --verbose \
  --log-file ~/.logs/gdrive-sync/bisync.log
```

### Safety Features (Implemented Dec 2025)
1.  **Git Lock Check:** Aborts sync if `index.lock` is found to prevent git repo corruption.
2.  **Permissions Fix:** Automatically restores `+x` permissions to scripts (`.sh`, `.py`, etc.) after sync (since GDrive drops them).
3.  **Smart Limit:** `max-delete` set to **199** to allow routine cleanups while preventing catastrophic data loss.

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
| `--max-delete 199` | Safety limit on deletes |
| `--conflict-resolve path1` | **Local Wins** (Safer for automation) |
| `--drive-skip-gdocs` | Skip Google Docs |

---

## Best Practices

### Set-It-And-Forget-It Setup

The automated job handles 99% of cases. Your role is:
1.  **Delete locally:** Use `conflict-manager` or `rm` to manage files.
2.  **Wait:** Let the hourly sync propagate changes.
3.  **Don't panic:** If files reappear, it means you deleted >199 files (safety trigger). Run a manual sync with override if needed.

### When to Use --resync

**ONLY use `sync-gdrive-resync` in these situations:**
1.  **Exit Code 7:** Log says "Bisync aborted. Must run --resync".
2.  **Filter Changes:** You modified `.gitignore` or exclude patterns.
3.  **Baseline Mismatch:** Logs show "path1 and path2 have different number of files".

**DO NOT use `--resync` to fix deleted files reappearing.** (See [conflicts.md](conflicts.md)).

---

## Health Monitoring

### Automated Checks
A daily health check (`gdrive-health-check.yml`) runs at 09:00 to:
*   Check Drive Quota.
*   Scan for remote conflicts.
*   Notify desktop if issues found.

### Maintenance Checklist

**Daily:**
- Verify systemd timer is active
- Check for error notifications

**Weekly:**
- Review and resolve conflict files (`conflict-manager scan ~/.MyHome`)

**Monthly:**
- The `gdrive-backup` job creates an archival snapshot.

---

## Conflict Resolution

### Understanding Conflicts

A conflict occurs when a file is new/changed on BOTH sides since last sync.

### Resolution Options

| Option | Behavior |
|--------|----------|
| `path1` | **Local Wins** (Current Config) |
| `path2` | Remote Wins |
| `newer` | Keep newer file |

### Recommended Tool

Use the **Conflict Manager**:
```bash
conflict-manager scan ~/.MyHome
```

---

## Recovery Procedures

### Fix "Reappearing Files" Loop

If you deleted files but they keep coming back:
1.  **Clean Remote:** `rclone sync ~/.MyHome GoogleDrive-dtsioumas0:MyHome --drive-skip-gdocs` (Force Push).
2.  **Reset DB:** `sync-gdrive-resync`.

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

## References

- **Official Docs:** https://rclone.org/bisync/
- **Ansible Playbook:** `ansible/playbooks/rclone-gdrive-sync.yml`
- **Home-Manager Module:** `home-manager/rclone-gdrive.nix`

---

*Migrated from docs/commons/integrations/rclone-gdrive-sync/ on 2025-11-29*