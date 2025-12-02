# Sync Documentation

**Last Updated:** 2025-11-30
**Files:** 8 documents

This directory contains documentation for file synchronization tools.

## Available Guides

| Guide | Description |
|-------|-------------|
| [deployment.md](deployment.md) | Complete deployment guide for sync infrastructure |
| [rclone-gdrive.md](rclone-gdrive.md) | Google Drive bisync backup reference |
| [syncthing.md](syncthing.md) | P2P real-time sync between devices |
| [ansible-playbooks.md](ansible-playbooks.md) | Ansible playbook reference and usage |
| [monitoring.md](monitoring.md) | Health checks and monitoring procedures |
| [conflicts.md](conflicts.md) | Conflict resolution and prevention |
| [disaster-recovery.md](disaster-recovery.md) | Rollback and recovery procedures |

## Architecture

```
┌─────────────────────────────────────────────────────┐
│              SYNCTHING P2P NETWORK                  │
│            (Real-time bidirectional)                │
└─────────────────────────────────────────────────────┘
                         │
       ┌─────────────────┼─────────────────┐
       ▼                 ▼                 ▼
   [SHOSHIN]        [LAPTOP]          [ANDROID]
       │
       │ rclone (hourly)
       ▼
   [GOOGLE DRIVE]
```

## Quick Commands

```bash
# Syncthing status
systemctl --user status syncthing

# rclone sync status
systemctl --user status rclone-gdrive-sync.timer

# Manual rclone sync
rclone bisync ~/.MyHome/ GoogleDrive-dtsioumas0:MyHome/ --resilient --recover -v
```
