# Ansible Playbook Reference

**Last Updated:** 2025-12-20
**Related ADR:** ADR-002, ADR-004, ADR-006
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [rclone-gdrive-sync.yml](#rclone-gdrive-syncyml)
- [gdrive-health-check.yml](#gdrive-health-checkyml)
- [gdrive-backup.yml](#gdrive-backupyml)
- [Running Playbooks](#running-playbooks)
- [Systemd Integration](#systemd-integration)
- [Quality Checks](#quality-checks)
- [Troubleshooting](#troubleshooting)

---

## Overview

The sync infrastructure uses Ansible playbooks for automation. This was chosen over bash scripts for better error handling, idempotency, and maintainability.

**Available Playbooks:**
- `rclone-gdrive-sync.yml` - Hourly bidirectional sync with conflict detection & safety checks.
- `gdrive-health-check.yml` - Daily health check (quota, remote conflicts).
- `gdrive-backup.yml` - Monthly backup (fixed).

**Why Ansible?**
- See ADR-002 and ADR-004 for decision rationale
- Production-quality code
- Desktop notifications for status
- Conflict detection built-in

---

## rclone-gdrive-sync.yml

### Purpose

Performs bidirectional synchronization between local MyHome directory and Google Drive.

**Features:**
- **Git Safety:** Checks for `index.lock` before syncing to prevent git repo corruption.
- **Permissions Fix:** Restores `+x` permissions for scripts (`.sh`, `.py`, etc.) post-sync (GDrive loses metadata).
- **Dry-run mode:** Runs dry-run first to detect conflicts.
- **Desktop notifications:** Success, failure, and conflict alerts (suggests `conflict-manager`).
- **Resync Mode:** Built-in capability to force a full resync.

### Usage

**Manual invocation:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml
```

**With tags:**
```bash
# Dry-run only
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --tags dry-run

# Force Resync (Use if "baseline mismatch" errors occur)
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --tags resync
```

### Configuration

**Key variables** (defined in playbook):
```yaml
local_path: "{{ ansible_env.HOME }}/.MyHome/"
remote_path: "GoogleDrive-dtsioumas0:MyHome/"
log_dir: "{{ ansible_env.HOME }}/.logs/gdrive-sync"
```

**rclone flags:**
- `--resilient` - Retry on soft errors
- `--recover` - Recover from crashes
- `--max-lock 2m` - Auto-expire locks
- `--conflict-resolve path1` - **Local Wins** on conflict (safer for automated sync).
- `--drive-skip-gdocs` - Skip Google Docs (prevents errors).

### Scheduling

Runs **hourly** via systemd timer (configured in home-manager).

### Conflict Detection

The playbook checks for `.conflictN` files after sync.
If conflicts found:
- Desktop notification suggests running: `conflict-manager scan ~/.MyHome`
- Log shows conflict files.

### Troubleshooting

**Playbook fails:**
```bash
# Check last run log
journalctl --user -u rclone-gdrive-sync -n 50
```

**Common issues:**
- **Git Lock:** "ABORTING: Active Git operation detected" -> Wait for git to finish or delete stale `index.lock`.
- **Baseline mismatch:** Run `sync-gdrive-resync`.

---

## gdrive-health-check.yml

### Purpose

Performs proactive health checks on the Google Drive remote.

**Checks:**
1.  **Quota:** Checks used/free space.
2.  **Remote Conflicts:** Scans remote for "conflicted copy" files.

**Output:**
- Logs to `~/.logs/maintenance/gdrive-health-*.jsonl`.
- Desktop notifications with usage stats.

### Usage

```bash
ansible-playbook -i inventories/hosts playbooks/gdrive-health-check.yml
```

---

## gdrive-backup.yml

### Purpose

Monthly backup of critical data to Google Drive backup location.
*Note: Fixed `never` tag issue in Dec 2025.*

### Usage

```bash
# Manual run
ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml
```

---

## Running Playbooks

### Via Helper Scripts

Home-manager provides helper scripts (aliases):

```bash
# Trigger manual sync
sync-gdrive

# Check sync status
sync-gdrive-status

# Force resync (Interactive wrapper)
sync-gdrive-resync
```

---

## Systemd Integration

### How it Works

1. **home-manager** creates systemd user service `rclone-gdrive-sync.service`.
2. **systemd timer** triggers service hourly.
3. **Service executes** ansible-playbook.
4. **Notifications** sent via desktop.
5. **Logs** written to `~/.logs/gdrive-sync/`.

---

## Quality Checks

### Pre-commit Checks

Before committing playbook changes, run:

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
# Run all checks
make check
```

---

## Future Improvements

- [ ] Centralized logging analysis dashboard.
- [ ] Automated conflict resolution for known file types (e.g. JSON state files).

---

**Maintainer:** Mitsos