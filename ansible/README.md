# Ansible Automation for my-modular-workspace

**Project:** my-modular-workspace
**Purpose:** Ansible automation for GDrive backups and system bootstrap
**Date Created:** 2025-11-19

---

## Overview

This directory contains Ansible playbooks, roles, and plugins for automating:
- Google Drive full backups with compression
- Desktop notifications for task status
- ARA recording integration (optional)

---

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── inventories/
│   └── hosts                # Inventory file (localhost/desktop)
├── playbooks/
│   └── gdrive-backup.yml    # GDrive backup playbook
├── roles/                   # Custom roles (future)
├── plugins/
│   └── callbacks/
│       └── desktop_notify.py  # Desktop notification callback plugin
├── logs/                    # Ansible logs
└── README.md                # This file
```

---

## Prerequisites

### Required Packages

```bash
# Install Ansible
sudo dnf install ansible  # Fedora/RHEL
# or
pip3 install ansible

# Install rclone (should already be configured)
which rclone

# Install libnotify for desktop notifications
sudo dnf install libnotify

# Optional: Install ARA for playbook recording
pip3 install ara
```

### Configuration

1. **rclone**: Must have `GoogleDrive-dtsioumas0:` remote configured
   ```bash
   rclone listremotes  # Should show GoogleDrive-dtsioumas0:
   ```

2. **/backups/**: Must be mounted and writable
   ```bash
   ls -ld /backups/  # Should show: drwxrwxr-x mitsio users
   ```

3. **ARA** (optional): Start ARA server for recording
   ```bash
   ara-manage runserver 0.0.0.0:8000
   ```

---

## Usage

### GDrive Backup Playbook

**Full backup (sync + compress):**
```bash
cd ~/. MyHome/MySpaces/my-modular-workspace/ansible
ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml --tags sync,compress
```

**Compress only (if already synced):**
```bash
ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml --tags compress
```

**With cleanup (remove old backups):**
```bash
ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml --tags sync,compress,cleanup
```

**Check mode (dry-run):**
```bash
ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml --check
```

### Playbook Tags

- `always`: Runs always (notifications, setup)
- `sync`: Sync GoogleDrive with rclone
- `compress`: Compress synced data to .tar.xz
- `compress-max`: Use explicit xz -9 compression
- `cleanup`: Remove old backups (rotation)
- `info`: Show backup information

---

## Features

### 1. Desktop Notifications

The playbook sends desktop notifications:
- ✅ **Success**: Green checkmark notification
- ❌ **Failure**: Critical red error notification

Notifications include:
- Playbook name
- Archive name and size
- Completion time

### 2. ARA Integration (Optional)

When ARA is enabled:
- All playbook runs are recorded
- Access web UI at http://localhost:8000
- Browse history, search runs, view task details

**Enable ARA:**
1. Uncomment lines in `ansible.cfg`:
   ```ini
   callback_plugins = plugins/callbacks:$(python3 -m ara.setup.callback_plugins)
   callback_whitelist = ara_default, desktop_notify
   ```

2. Start ARA server:
   ```bash
   ara-manage runserver 0.0.0.0:8000 &
   ```

### 3. Compression

- **Format**: tar.xz (LZMA2 compression)
- **Level**: Maximum (9) for best compression
- **Archive naming**: `gdrive-backup-YYYY-MM-DD.tar.xz`

### 4. Backup Rotation

Keeps last 7 backups, removes older ones (run with `--tags cleanup`).

### 5. Logging

- **Ansible logs**: `logs/ansible.log`
- **rclone logs**: `/var/log/ansible/gdrive-backup-YYYY-MM-DD.log`
- **Backup info**: `/backups/GDrive_Backups/gdrive-backup-YYYY-MM-DD.info`

---

## Backup Process

1. **Pre-flight checks**:
   - Create backup directories
   - Check available disk space (min 50GB)

2. **Sync** (if `--tags sync`):
   - rclone sync GoogleDrive to `/backups/GDrive_Backups/gdrive-backup-DATE/`
   - Progress stats every 30s
   - Skip Google Docs, exclude temp files

3. **Compress**:
   - Create tar.xz archive with maximum compression
   - Set proper ownership (mitsio:users)
   - Generate .info file with metadata

4. **Cleanup**:
   - Remove uncompressed directory (save space)
   - Rotate old backups (keep last 7)

5. **Notify**:
   - Desktop notification with results
   - Log summary to file

---

## Troubleshooting

### Desktop notifications not working

```bash
# Test notify-send
notify-send -i emblem-checked "Test" "This is a test"

# Check DISPLAY variable
echo $DISPLAY  # Should show :0 or similar

# Ensure running in graphical session
who  # Should show your session
```

### rclone errors

```bash
# Test rclone connection
rclone lsd GoogleDrive-dtsioumas0:

# Check config
rclone config show GoogleDrive-dtsioumas0
```

### Insufficient disk space

```bash
# Check available space
df -h /backups/

# Clean old backups manually
ls -lh /backups/GDrive_Backups/
rm /backups/GDrive_Backups/gdrive-backup-OLD-DATE.tar.xz
```

### ARA not recording

```bash
# Check ARA server is running
curl http://localhost:8000/api/

# Check callback plugins path
python3 -m ara.setup.callback_plugins

# Enable debug logging
export ARA_DEBUG=true
export ARA_LOG_LEVEL=DEBUG
```

---

## Customization

### Change backup retention

Edit `gdrive-backup.yml`:
```yaml
# Keep last N backups
ls -t gdrive-backup-*.tar.xz | tail -n +N | xargs -r rm -f
#                                           ^ Change this number
```

### Change compression level

For faster compression with less compression:
```yaml
# Use xz -6 instead of xz -9
tar -cf - {{ backup_dir }} | xz -6 -c > {{ backup_archive }}
```

### Add email notifications

Install and configure `community.general.mail` callback:
```ini
[defaults]
callback_whitelist = ara_default, desktop_notify, community.general.mail

[callback_mail]
mta = smtp.gmail.com
sender = ansible@example.com
to = admin@example.com
```

---

## Scheduled Execution

### Using cron

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd ~/. MyHome/MySpaces/my-modular-workspace/ansible && ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml --tags sync,compress,cleanup >> logs/cron.log 2>&1
```

### Using systemd timer (Recommended)

Create `~/.config/systemd/user/gdrive-backup.service`:
```ini
[Unit]
Description=GDrive Backup with Ansible
After=network-online.target

[Service]
Type=oneshot
WorkingDirectory=%h/.MyHome/MySpaces/my-modular-workspace/ansible
ExecStart=/usr/bin/ansible-playbook -i inventories/hosts playbooks/gdrive-backup.yml --tags sync,compress
StandardOutput=journal
StandardError=journal
```

Create `~/.config/systemd/user/gdrive-backup.timer`:
```ini
[Unit]
Description=GDrive Backup Timer (Weekly)

[Timer]
OnCalendar=Sun 02:00
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start:
```bash
systemctl --user daemon-reload
systemctl --user enable gdrive-backup.timer
systemctl --user start gdrive-backup.timer
systemctl --user list-timers gdrive-backup.timer
```

---

## Documentation

- **Ansible ARA Desktop Notifications**: `../docs/ansible/ANSIBLE_ARA_DESKTOP_NOTIFICATIONS.md`
- **Ansible Bootstrap Repo Skeleton**: `../docs/ansible/ANSIBLE_BOOTSTRAP_REPO_SKELETON_DRAFT_1.md`
- **rclone bisync configuration**: `../home-manager/rclone-gdrive.nix`

---

## Future Enhancements

- [ ] Add roles for modular task organization
- [ ] Bootstrap playbooks for fresh system setup
- [ ] Integration with Syncthing for incremental backups
- [ ] Email notifications for critical failures
- [ ] Backup verification and integrity checks
- [ ] Multi-destination backups (local + cloud)
- [ ] Encrypted backups with GPG
- [ ] Differential/incremental backup support

---

**Created:** 2025-11-19
**Author:** Μήτσο + Claude Code
**Status:** Production Ready
