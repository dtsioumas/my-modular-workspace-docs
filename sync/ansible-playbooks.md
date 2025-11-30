# Ansible Playbook Reference

**Last Updated:** 2025-11-30
**Related ADR:** ADR-002, ADR-004, ADR-006
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [rclone-gdrive-sync.yml](#rclone-gdrive-syncyml)
- [gdrive-backup.yml](#gdrive-backupyml)
- [Running Playbooks](#running-playbooks)
- [Systemd Integration](#systemd-integration)
- [Quality Checks](#quality-checks)
- [Troubleshooting](#troubleshooting)

---

## Overview

The sync infrastructure uses Ansible playbooks for automation. This was chosen over bash scripts for better error handling, idempotency, and maintainability.

**Available Playbooks:**
- `rclone-gdrive-sync.yml` - Hourly bidirectional sync
- `gdrive-backup.yml` - Monthly backup (currently needs fixing)

**Why Ansible?**
- See ADR-002 and ADR-004 for decision rationale
- Production-quality code (0 ansible-lint violations)
- Desktop notifications for status
- Conflict detection built-in

---

## rclone-gdrive-sync.yml

### Purpose

Performs bidirectional synchronization between local MyHome directory and Google Drive.

**Features:**
- Dry-run mode first
- Conflict detection
- Desktop notifications (success/failure/conflicts)
- Detailed logging
- Error handling

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

# Check conflicts only
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --tags check-conflicts
```

### Configuration

**Key variables** (defined in playbook):
```yaml
local_path: "{{ ansible_env.HOME }}/.MyHome/"
remote_path: "GoogleDrive-dtsioumas0:MyHome/"
log_dir: "{{ ansible_env.HOME }}/.cache/rclone"
```

**rclone flags:**
- `--resilient` - Retry on soft errors
- `--recover` - Recover from crashes
- `--max-lock 2m` - Auto-expire locks
- `--conflict-resolve newer` - Keep newer files
- `--drive-skip-gdocs` - Skip Google Docs

### Scheduling

Runs **hourly** via systemd timer (configured in home-manager):

```nix
# home-manager/rclone-gdrive.nix
systemd.user.timers.rclone-gdrive-sync = {
  Timer = {
    OnCalendar = "hourly";
    Persistent = true;
  };
};
```

**Check schedule:**
```bash
systemctl --user list-timers rclone-gdrive-sync.timer
```

### Notifications

Desktop notifications via `notify-send`:

- ✅ **Success:** "Google Drive sync completed"
- ⚠️ **Conflicts detected:** "Sync completed with conflicts"
- ❌ **Failure:** "Sync failed - check logs"

### Logging

Logs written to:
```
~/.cache/rclone/bisync-YYYY-MM-DD-HHMMSS.log
```

**View latest log:**
```bash
ls -t ~/.cache/rclone/bisync-*.log | head -1 | xargs cat
```

### Conflict Detection

The playbook checks for `.conflictN` files after sync:

```bash
# Find conflicts
find ~/.MyHome -name "*.conflict*" -type f
```

If conflicts found:
- Desktop notification sent
- Log shows conflict files
- User must resolve manually

See [conflicts.md](conflicts.md) for resolution procedures.

### Troubleshooting

**Playbook fails:**
```bash
# Check last run log
journalctl --user -u rclone-gdrive-sync -n 50

# Check rclone log
tail -100 ~/.cache/rclone/bisync-*.log | tail -1
```

**Common issues:**
- Lock file stuck → Remove `~/.cache/rclone/bisync-workdir/*.lck`
- Too many deletes → Increase `--max-delete` or investigate
- Baseline mismatch → Run `sync-gdrive-resync`

---

## gdrive-backup.yml

### Purpose

Monthly backup of critical data to Google Drive backup location.

**Status:** ⚠️ Currently failing (needs investigation)

**Last known issue:** Nov 21, 2025 - service failed
**Log:** `/var/log/ansible/gdrive-backup-2025-11-21.log`

### TODO: Fix Backup Playbook

**Investigation needed:**
1. Read failure log
2. Diagnose root cause
3. Fix playbook
4. Test manually
5. Re-enable monthly timer

**Tracking:** See docs/TODO.md Section 6, Phase 3

### Expected Usage (once fixed)

```bash
# Manual run
ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml

# Scheduled monthly (via systemd timer)
systemctl --user list-timers gdrive-monthly-backup.timer
```

---

## Running Playbooks

### Prerequisites

Ansible and quality tools installed via home-manager:
```nix
home.packages = with pkgs; [
  ansible
  ansible-lint
  yamllint
];
```

### Manual Execution

**From ansible directory:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/ansible

# Run sync playbook
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml

# Verbose mode
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml -v

# Check mode (dry run)
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --check
```

### Via Helper Scripts

Home-manager provides helper scripts:

```bash
# Trigger manual sync
sync-gdrive

# Check sync status
sync-gdrive-status

# Force resync
sync-gdrive-resync
```

---

## Systemd Integration

### How it Works

1. **home-manager** creates systemd user service
2. **systemd timer** triggers service hourly
3. **Service executes** ansible-playbook
4. **Notifications** sent via desktop
5. **Logs** written to ~/.cache/rclone/

### Service Definition

```nix
# home-manager/rclone-gdrive.nix
systemd.user.services.rclone-gdrive-sync = {
  Unit.Description = "RClone Google Drive Sync";
  Service = {
    Type = "oneshot";
    ExecStart = "${pkgs.ansible}/bin/ansible-playbook ...";
    StandardOutput = "journal";
    StandardError = "journal";
  };
};
```

### Managing Services

```bash
# Start manual sync
systemctl --user start rclone-gdrive-sync

# Check service status
systemctl --user status rclone-gdrive-sync

# View service logs
journalctl --user -u rclone-gdrive-sync -f

# Restart timer
systemctl --user restart rclone-gdrive-sync.timer
```

---

## Quality Checks

### Pre-commit Checks

Before committing playbook changes, run:

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/ansible

# Run all checks
make check
```

This runs:
- `ansible-lint` (production profile)
- `yamllint` (checks YAML syntax)

### ansible-lint

**Current status:** 0 violations (production profile) ✅

**Run manually:**
```bash
cd ansible/
ansible-lint playbooks/rclone-gdrive-sync.yml
```

**Common rules:**
- Use FQCN (Fully Qualified Collection Names)
- Add `changed_when` to command/shell tasks
- Use `true`/`false` for booleans (not `yes`/`no`)
- Add `set -o pipefail` to shell tasks with pipes

### yamllint

**Current status:** 4 acceptable violations

**Run manually:**
```bash
yamllint playbooks/rclone-gdrive-sync.yml
```

**Acceptable warnings:**
- Line length (commands can be long)
- Comments formatting

---

## Troubleshooting

### Playbook Won't Run

**Check Ansible version:**
```bash
ansible --version  # Should be >= 2.9
```

**Check inventory:**
```bash
ansible -i inventories/hosts all --list-hosts
```

**Test connection:**
```bash
ansible -i inventories/hosts localhost -m ping
```

### Dry Run Shows Unexpected Changes

**Review the dry-run output:**
```bash
# The playbook always runs dry-run first
# Check the output carefully before proceeding
```

**Common causes:**
- Files modified on both sides
- Time zone differences
- Exclude patterns changed

### Notifications Not Showing

**Check notify-send:**
```bash
notify-send "Test" "This is a test notification"
```

**If fails:**
- Install libnotify: Included in NixOS desktop
- Check DISPLAY variable: `echo $DISPLAY`
- Check DBUS session: `echo $DBUS_SESSION_BUS_ADDRESS`

### Logs Not Being Created

**Check log directory:**
```bash
ls -la ~/.cache/rclone/
```

**Create if missing:**
```bash
mkdir -p ~/.cache/rclone
chmod 700 ~/.cache/rclone
```

---

## Best Practices

1. **Always review dry-run output** before real sync
2. **Monitor first few automatic runs** after setup
3. **Check for conflicts weekly** - `find ~/.MyHome -name "*.conflict*"`
4. **Review logs after failures** - Don't ignore notification errors
5. **Test playbook changes** with `--check` mode first
6. **Run quality checks** before committing - `make check`

---

## Future Improvements

See session TODO for planned enhancements:

- [ ] Centralized logging (`~/.logs/ansible/`)
- [ ] Log rotation (30-day retention)
- [ ] Enhanced notifications (conflict file lists)
- [ ] Error preview in notifications
- [ ] Health check playbook
- [ ] Conflict hunter playbook

---

## References

- **ADR-002:** [Ansible handles rclone sync job](../adrs/ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md)
- **ADR-004:** [Migrate rclone automation to Ansible](../adrs/ADR-004-MIGRATE_RCLONE_AUTOMATION_TO_ANSIBLE.md)
- **ADR-006:** [Reject rolehippie/rclone collection](../adrs/ADR-006-REJECT-ROLEHIPPIE-RCLONE.md)
- **rclone Guide:** [rclone-gdrive.md](rclone-gdrive.md)
- **Ansible Repo:** `~/.MyHome/MySpaces/my-modular-workspace/ansible/`

---

*Created 2025-11-30 from sessions/sync-integration/ and master TODO*
