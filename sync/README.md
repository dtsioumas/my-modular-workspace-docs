# Sync Documentation

**Last Updated:** 2025-11-29

This directory contains documentation for file synchronization tools.

## Available Guides

| Guide | Description |
|-------|-------------|
| [syncthing.md](syncthing.md) | P2P real-time sync between devices |
| [rclone-gdrive.md](rclone-gdrive.md) | Google Drive bisync backup |
| [conflicts.md](conflicts.md) | Conflict resolution procedures |

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
