# Syncthing + Google Drive Sync Architecture

**Version:** 1.0
**Date:** 2025-11-18
**Author:** Mitsio
**Purpose:** Multi-device synchronization with cloud backup for `~/.MyHome` directory

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Components](#components)
4. [Data Flow](#data-flow)
5. [Directory Structure](#directory-structure)
6. [Sync Schedule](#sync-schedule)
7. [Quick Start](#quick-start)
8. [Related Documentation](#related-documentation)

---

## Overview

This architecture implements a robust, multi-layered sync solution that:

- **Syncs in real-time** between multiple devices (desktop + laptop + Android) using Syncthing
- **Backs up to cloud** every 30 minutes to Google Drive using rclone
- **Provides redundancy** with multiple copies across devices and cloud
- **Enables offline work** with Syncthing's peer-to-peer sync
- **Centralizes configuration** in `~/.MyHome` for all workspace files

### Key Benefits

✅ **Real-time sync** across devices via Syncthing (no internet required)
✅ **Automated cloud backup** to Google Drive every 30 minutes
✅ **Conflict-free** with Syncthing's versioning
✅ **Cross-platform** (Linux desktop, laptop, Android phone)
✅ **Portable** configurations managed by home-manager

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SYNCTHING P2P NETWORK                           │
│                     (Real-time bidirectional sync)                      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
│   SHOSHIN         │      │   LAPTOP-SYSTEM01 │      │   ANDROID PHONE   │
│  (Desktop NixOS)  │◄────►│   (Laptop)        │◄────►│   (Xiaomi Poco)   │
│                   │      │                   │      │                   │
│ ~/.MyHome/        │      │ ~/.MyHome/        │      │ /storage/emulated/│
│ MySpaces/         │      │ MySpaces/         │      │ 0/Syncthing/      │
│ my-modular-       │      │ my-modular-       │      │ MyHome/           │
│ workspace/        │      │ workspace/        │      │                   │
└─────────┬─────────┘      └───────────────────┘      └───────────────────┘
          │
          │ rclone sync
          │ (Every 30 minutes)
          │ One-way backup ↓
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                     GOOGLE DRIVE                            │
│                   (Cloud Backup)                            │
│                                                             │
│  📁 MyHome/                                                 │
│     └── MySpaces/                                           │
│         └── my-modular-workspace/                           │
│             ├── home-manager/                               │
│             ├── my-dotfiles/                                │
│             ├── docs/                                       │
│             └── sessions/                                   │
│                                                             │
│  Retention: Indefinite                                      │
│  Sync Direction: One-way (shoshin → GDrive)                 │
│  Schedule: Every 30 minutes via systemd timer               │
└─────────────────────────────────────────────────────────────┘
```

### Alternative ASCII Diagram (Detailed Flow)

```
                    ┌──────────────────────────────┐
                    │   SYNCTHING CLUSTER          │
                    │   (Always-on sync)           │
                    └──────────────────────────────┘
                                 │
         ┌───────────────────────┼────────────────────────┐
         │                       │                        │
         ▼                       ▼                        ▼
    ┌────────┐             ┌────────┐              ┌────────┐
    │ Device │             │ Device │              │ Device │
    │   A    │◄───────────►│   B    │◄────────────►│   C    │
    │shoshin │  Encrypted  │laptop  │   Encrypted  │Android │
    │        │  via TLS    │        │    via TLS   │        │
    └────┬───┘             └────────┘              └────────┘
         │
         │ rclone
         │ bidirectional
         │ check
         │ (30min)
         │
         ▼
    ┌─────────────────────────────────────────────┐
    │         GOOGLE DRIVE BACKUP                 │
    │                                             │
    │  Strategy: Incremental sync                 │
    │  Transfer: Only changed files               │
    │  Bandwidth: Throttled (configurable)        │
    │  Retry: 3 attempts with exponential backoff │
    │                                             │
    └─────────────────────────────────────────────┘
```

---

## Components

### 1. Syncthing (Real-time P2P Sync)

**Purpose:** Real-time, bidirectional file synchronization between devices

**Key Features:**
- **Peer-to-peer**: No central server required
- **Encrypted**: TLS encryption for all transfers
- **Conflict resolution**: Automatic versioning
- **Cross-platform**: Linux, Android, Windows, macOS
- **LAN-optimized**: Direct local network transfers when available

**Configuration:**
- Folder ID: `my-modular-workspace`
- Folder Path (shoshin): `~/.MyHome/MySpaces/my-modular-workspace/`
- Folder Path (laptop): `~/.MyHome/MySpaces/my-modular-workspace/`
- Folder Path (Android): `/storage/emulated/0/Syncthing/MyHome/`
- Sync Type: Send & Receive (bidirectional)
- File Versioning: Simple versioning (keep 5 versions)
- Watch for Changes: Enabled (fsWatcher)
- Rescan Interval: 3600 seconds (1 hour fallback)

**Devices:**
1. `shoshin` - Desktop (always-on hub)
2. `laptop-system01` - Laptop (mobile workstation)
3. `xiaomi-poco-x6` - Android phone (mobile access)

### 2. rclone (Cloud Backup)

**Purpose:** Automated one-way backup to Google Drive

**Key Features:**
- **Cloud agnostic**: Supports 40+ cloud providers
- **Efficient**: Incremental transfers, checksums
- **Reliable**: Retry logic, error handling
- **Configurable**: Bandwidth limits, filters, encryption

**Configuration:**
- Remote Name: `gdrive`
- Source: `~/.MyHome/MySpaces/my-modular-workspace/`
- Destination: `gdrive:MyHome/MySpaces/my-modular-workspace/`
- Sync Command: `rclone sync`
- Direction: One-way (local → cloud)
- Checksum: Yes (md5)
- Bandwidth Limit: None (configurable)

**Transfer Optimization:**
- `--fast-list`: Use recursive list for large directories
- `--transfers 4`: Parallel file transfers
- `--checkers 8`: Parallel checksum operations
- `--drive-chunk-size 256M`: Large chunk uploads
- `--stats 1m`: Progress updates every minute

### 3. systemd (Automation)

**Purpose:** Schedule and manage automated sync services

**Services Created:**

#### `rclone-gdrive-sync.service`
```ini
[Unit]
Description=Sync ~/.MyHome to Google Drive
After=network-online.target

[Service]
Type=oneshot
ExecStart=rclone sync ~/.MyHome/MySpaces/my-modular-workspace/ gdrive:MyHome/MySpaces/my-modular-workspace/ --fast-list --transfers 4
```

#### `rclone-gdrive-sync.timer`
```ini
[Unit]
Description=Google Drive sync every 30 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
Persistent=true

[Install]
WantedBy=timers.target
```

---

## Data Flow

### Scenario 1: File Created on Desktop (shoshin)

```
1. User creates file in ~/.MyHome/MySpaces/my-modular-workspace/docs/new-doc.md

2. Syncthing detects change (via fsWatcher)
   └─> Indexes file
   └─> Announces to cluster

3. laptop-system01 receives announcement
   └─> Requests file blocks
   └─> Downloads file (encrypted TLS)
   └─> Writes to ~/.MyHome/MySpaces/my-modular-workspace/docs/new-doc.md

4. Android phone receives announcement
   └─> Requests file blocks
   └─> Downloads file (encrypted TLS)
   └─> Writes to /storage/emulated/0/Syncthing/MyHome/docs/new-doc.md

5. After 30 minutes (or at next sync window):
   rclone-gdrive-sync.timer triggers
   └─> rclone sync calculates diff
   └─> Uploads new-doc.md to Google Drive
   └─> GDrive: MyHome/MySpaces/my-modular-workspace/docs/new-doc.md
```

### Scenario 2: File Modified on Android Phone

```
1. User edits file on Android:
   /storage/emulated/0/Syncthing/MyHome/docs/existing.md

2. Syncthing (Android) detects change
   └─> Indexes file
   └─> Announces to cluster

3. shoshin receives announcement
   └─> Requests file blocks
   └─> Downloads only changed blocks (delta sync)
   └─> Updates ~/.MyHome/MySpaces/my-modular-workspace/docs/existing.md

4. laptop-system01 receives announcement
   └─> Requests file blocks from either shoshin or Android (whichever is faster)
   └─> Updates local copy

5. Next rclone sync (30 min):
   └─> Detects modification
   └─> Uploads updated file to Google Drive
```

### Scenario 3: Conflict Resolution

```
1. User A edits file.txt on shoshin (offline)
   User B edits same file.txt on laptop (offline)

2. Both devices come online

3. Syncthing detects conflict
   └─> Keeps both versions:
       - file.txt (User A's version - higher device ID wins)
       - file.sync-conflict-20251118-143022.txt (User B's version)

4. User manually resolves conflict
   └─> Reviews both versions
   └─> Merges changes
   └─> Deletes conflict file

5. rclone sync backs up resolution to Google Drive
```

---

## Directory Structure

### On shoshin (Desktop)

```
~/.MyHome/
└── MySpaces/
    └── my-modular-workspace/          # ← Syncthing folder
        ├── home-manager/              # Nix home-manager configs
        ├── my-dotfiles/               # Application dotfiles
        ├── docs/                      # Documentation
        ├── sessions/                  # Work sessions
        ├── .stfolder                  # Syncthing marker
        └── .stignore                  # Syncthing ignore patterns
```

### On laptop-system01 (Laptop)

```
~/.MyHome/
└── MySpaces/
    └── my-modular-workspace/          # ← Syncthing folder (identical)
        ├── home-manager/
        ├── my-dotfiles/
        ├── docs/
        ├── sessions/
        ├── .stfolder
        └── .stignore
```

### On Android Phone

```
/storage/emulated/0/
└── Syncthing/
    └── MyHome/                        # ← Syncthing folder (simplified path)
        ├── MySpaces/
        │   └── my-modular-workspace/
        ├── .stfolder
        └── .stignore
```

### On Google Drive (Cloud)

```
MyHome/                                # ← rclone destination
└── MySpaces/
    └── my-modular-workspace/
        ├── home-manager/
        ├── dotfiles/
        ├── docs/
        └── sessions/
        ....
```

---

## Sync Schedule

| Event | Trigger | Latency | Tool |
|-------|---------|---------|------|
| **File change detected** | fsWatcher (inotify) | < 1 second | Syncthing |
| **File synced to devices** | Automatic (immediate) | 1-30 seconds | Syncthing |
| **First cloud backup** | 5 minutes after boot | 5 minutes | rclone (systemd timer) |
| **Recurring cloud backup** | Every 30 minutes | 30 minutes | rclone (systemd timer) |
| **Manual sync** | `systemctl --user start rclone-gdrive-sync` | Immediate | rclone |

### Sync Behavior Summary

```
┌─────────────────────────────────────────────────────────┐
│ Time │ Event                                            │
├──────┼──────────────────────────────────────────────────┤
│ T+0s │ File created on shoshin                          │
│ T+1s │ Syncthing detects change (fsWatcher)             │
│ T+2s │ Syncthing announces to cluster                   │
│ T+5s │ laptop-system01 downloads file                   │
│ T+8s │ Android phone downloads file                     │
│      │ ... [all devices in sync] ...                    │
│ T+30m│ rclone sync runs (first scheduled backup)        │
│ T+60m│ rclone sync runs again                           │
│ T+90m│ rclone sync runs again                           │
└──────┴──────────────────────────────────────────────────┘
```

---

## Quick Start

### Prerequisites

1. **Syncthing installed** on all devices
2. **rclone configured** with Google Drive remote
3. **systemd** available (Linux systems)

### Setup Steps

1. **Configure Syncthing**
   ```bash
   # See: 02-syncthing-setup.md
   ```

2. **Configure rclone**
   ```bash
   # See: 03-rclone-setup.md
   ```

3. **Enable systemd timer**
   ```bash
   # See: 04-systemd-automation.md
   ```

4. **Verify setup**
   ```bash
   # See: 05-verification.md
   ```

---

## Related Documentation

- [01-architecture-overview.md](01-architecture-overview.md) - Detailed architecture (this file)
- [02-syncthing-setup.md](02-syncthing-setup.md) - Syncthing configuration guide
- [03-rclone-setup.md](03-rclone-setup.md) - rclone & Google Drive setup
- [04-systemd-automation.md](04-systemd-automation.md) - Automated sync with systemd
- [05-verification.md](05-verification.md) - Testing and verification
- [06-troubleshooting.md](06-troubleshooting.md) - Common issues and solutions
- [07-best-practices.md](07-best-practices.md) - Optimization and best practices

---

## Design Decisions

### Why Syncthing + rclone (not just Google Drive Sync)?

| Requirement | Syncthing | rclone | Combined |
|-------------|-----------|--------|----------|
| Real-time sync | ✅ | ❌ | ✅ |
| Offline work | ✅ | ❌ | ✅ |
| Cloud backup | ❌ | ✅ | ✅ |
| No Google dependency | ✅ | ❌ | ✅ |
| Cross-platform | ✅ | ✅ | ✅ |
| Encryption | ✅ | ✅ | ✅ |
| Android support | ✅ | Limited | ✅ |

### Why 30-minute backup interval?

- **Balance**: Frequent enough to avoid data loss, infrequent enough to avoid rate limits
- **Bandwidth**: Avoids excessive network usage
- **Google Drive API**: Stays well below rate limits (10,000 requests/day)
- **Battery (if on laptop)**: Minimal impact on battery life
- **Configurable**: Easily adjustable via systemd timer

### Why one-way backup (not bidirectional)?

- **Simplicity**: Syncthing handles bidirectional sync between devices
- **Safety**: Cloud is "backup of record", not active workspace
- **Conflict avoidance**: No risk of cloud changes overwriting local work
- **Recovery**: Easy restore from cloud if local data lost
- **Cost**: Reduces Google Drive API usage

---

## Summary

This architecture provides:

1. **Instant sync** between devices via Syncthing (real-time, P2P)
2. **Scheduled backup** to Google Drive via rclone (every 30 min)
3. **Redundancy** across multiple devices + cloud
4. **Flexibility** to work offline with automatic sync when online
5. **Simplicity** with automated systemd timers

**Next Steps:** Proceed to [02-syncthing-setup.md](02-syncthing-setup.md) to begin configuration.

---

**Last Updated:** 2025-11-18
**Version:** 1.0
**Author:** Mitsio
