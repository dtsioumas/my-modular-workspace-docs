# Syncthing Setup Guide

**Last Updated:** 2025-11-29
**Sources Merged:** README.md, 00-CURRENT-SETUP.md, 02-syncthing-setup.md, 04-systemd-automation.md, 05-verification-and-troubleshooting.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Devices Setup](#devices-setup)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

Syncthing provides real-time, peer-to-peer file synchronization between devices.

**Key Benefits:**
- **Real-time sync** across devices (no internet required)
- **Encrypted** TLS transfers
- **Conflict-free** with automatic versioning
- **Cross-platform** (Linux, Android, Windows, macOS)

**Current Setup:**
- **Folder ID:** `my-modular-workspace`
- **Sync Type:** Send & Receive (bidirectional)
- **Versioning:** Simple (keep 5 versions)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SYNCTHING P2P NETWORK                     │
│                  (Real-time bidirectional)                   │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│    SHOSHIN    │     │   LAPTOP-01   │     │    ANDROID    │
│   (Desktop)   │◄───►│   (Laptop)    │◄───►│    (Phone)    │
│               │     │               │     │               │
│ ~/.MyHome/    │     │ ~/.MyHome/    │     │ /Syncthing/   │
│ MySpaces/     │     │ MySpaces/     │     │ MyHome/       │
└───────┬───────┘     └───────────────┘     └───────────────┘
        │
        │ rclone (every hour)
        ▼
┌───────────────────────────────────┐
│         GOOGLE DRIVE              │
│       (Cloud Backup)              │
└───────────────────────────────────┘
```

---

## Quick Start

### Essential Commands

```bash
# Check status
systemctl --user status syncthing

# Open Web GUI
xdg-open http://localhost:8384

# Get device ID
syncthing -device-id

# View logs
journalctl --user -u syncthing -f
```

### Enable Service

```bash
# Start and enable
systemctl --user enable --now syncthing

# Check timer/service
systemctl --user list-units | grep syncthing
```

---

## Configuration

### NixOS (System-level)

```nix
# In configuration.nix
services.syncthing = {
  enable = true;
  user = "mitsio";
  dataDir = "/home/mitsio/.local/share/syncthing";
  configDir = "/home/mitsio/.config/syncthing";

  settings = {
    devices = {
      "laptop-system01" = { id = "DEVICE-ID-HERE"; };
      "xiaomi-poco-x6" = { id = "DEVICE-ID-HERE"; };
    };

    folders = {
      "my-modular-workspace" = {
        path = "/home/mitsio/.MyHome/MySpaces/my-modular-workspace";
        devices = [ "laptop-system01" "xiaomi-poco-x6" ];
        versioning = {
          type = "simple";
          params.keep = "5";
        };
      };
    };
  };
};
```

### Home-Manager

```nix
# In home.nix
services.syncthing = {
  enable = true;
  dataDir = "${config.home.homeDirectory}/.local/share/syncthing";
  configDir = "${config.home.homeDirectory}/.config/syncthing";
};
```

### Folder Settings

| Setting | Value |
|---------|-------|
| Folder ID | `my-modular-workspace` |
| Path | `~/.MyHome/MySpaces/my-modular-workspace/` |
| Type | Send & Receive |
| Watch for Changes | Enabled (fsWatcher) |
| Rescan Interval | 3600 seconds |
| Versioning | Simple (5 versions) |

---

## Devices Setup

### shoshin (Desktop - Always-on Hub)

```bash
# Already configured via NixOS
syncthing -device-id  # Share this with other devices
```

### laptop-system01 (Laptop)

```bash
# Install via home-manager or package manager
# Add shoshin's device ID in Web GUI
# Share the my-modular-workspace folder
```

### Android (xiaomi-poco-x6)

1. Install **Syncthing** from F-Droid or Play Store
2. Folder path: `/storage/emulated/0/Syncthing/MyHome/`
3. Add device IDs from shoshin and laptop
4. Share the folder

**Important for Xiaomi/MIUI:**
- Lock app in recent apps
- Disable battery optimization
- Enable auto-start

---

## Sync Schedule

| Event | Latency | Tool |
|-------|---------|------|
| File change detected | < 1 second | fsWatcher |
| File synced to devices | 1-30 seconds | Syncthing |
| Cloud backup | Every hour | rclone |

### Data Flow Example

```
1. File created on shoshin
2. Syncthing detects (fsWatcher) → ~1 sec
3. Announces to cluster
4. laptop downloads → ~5 sec
5. Android downloads → ~8 sec
6. rclone backs up to GDrive → next hourly run
```

---

## Troubleshooting

### Devices Not Syncing

```bash
# Check if service running
systemctl --user status syncthing

# Check firewall ports
sudo ss -tuln | grep -E "22000|21027"

# Verify devices connected
curl -s http://localhost:8384/rest/system/connections | jq
```

### Firewall Configuration

Required ports:
- **22000/tcp** - Syncthing data transfer
- **21027/udp** - Syncthing discovery

```nix
# NixOS firewall
networking.firewall = {
  allowedTCPPorts = [ 22000 ];
  allowedUDPPorts = [ 21027 ];
};
```

### Conflict Files

Syncthing creates `.sync-conflict-YYYYMMDD-HHMMSS` files:

```bash
# Find conflicts
find ~/.MyHome -name "*.sync-conflict*"

# Review and remove
# (Manually merge if needed, then delete conflict files)
```

### Out of Sync

```bash
# Force rescan
curl -X POST http://localhost:8384/rest/db/scan?folder=my-modular-workspace

# Check folder status
curl -s http://localhost:8384/rest/db/status?folder=my-modular-workspace | jq
```

### Web GUI Not Loading

```bash
# Check binding
ss -tuln | grep 8384

# If localhost only, that's correct
# Access via: http://localhost:8384
```

---

## Important Paths

| Purpose | Path |
|---------|------|
| Local workspace | `~/.MyHome/MySpaces/my-modular-workspace/` |
| Syncthing config | `~/.config/syncthing/` |
| Syncthing data | `~/.local/share/syncthing/` |
| Conflict versions | `.stversions/` in synced folder |
| Marker file | `.stfolder` in synced folder |

---

## Integration with rclone

Syncthing handles real-time device sync; rclone handles cloud backup:

1. **Syncthing** syncs between devices instantly
2. **rclone** backs up to Google Drive hourly (from shoshin only)
3. Both complement each other for redundancy

See [rclone-gdrive.md](rclone-gdrive.md) for cloud backup details.

---

## References

- **Official Docs:** https://docs.syncthing.net/
- **GitHub:** https://github.com/syncthing/syncthing
- **Android App:** https://syncthing.net/downloads/
- **Home-Manager Module:** `home-manager/syncthing-myspaces.nix`
- **NixOS Module:** `modules/workspace/syncthing-myspaces.nix`

---

*Migrated from docs/commons/integrations/backup-gdrive-home-dir-with-syncthing/ on 2025-11-29*
