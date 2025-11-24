# Current Setup and Migration Status

**Last Updated:** 2025-11-18
**Based on:** Session gdrive-migration-syncthing-backup (2025-11-17)

---

## Current State

### What's Already Configured

From your previous sessions, you've already created:

1. **rclone bisync module** (`modules/workspace/rclone-bisync.nix`)
   - Bidirectional sync with Google Drive
   - Hourly schedule via systemd timer
   - Helper scripts: `sync-gdrive`, `sync-gdrive-status`, `sync-gdrive-resync`

2. **Syncthing module** (`modules/workspace/syncthing-myspaces.nix`)
   - Real-time P2P sync
   - Target: MySpaces folder for Android
   - Helper scripts: `syncthing-status`, `syncthing-open`, `syncthing-id`

3. **Firewall configuration** (`modules/system/firewall.nix`)
   - Network: 192.168.1.0/24
   - Ports: 22000 (Syncthing), 21027 (Syncthing discovery)
   - Broadcast/multicast support

### Current vs Target Paths

**IMPORTANT UPDATE:** You've moved from `~/MyHome` to `~/.MyHome`

| Component | Old Path | New Path (Current) | Status |
|-----------|----------|-------------------|--------|
| Local primary | `/home/mitso/MyHome/` | `/home/mitsio/.MyHome/` | ✅ Moved |
| Google Drive remote | `GoogleDrive-dtsioumas0:/MyHome/` | `gdrive:MyHome/` | Update needed |
| Syncthing folder | N/A | `~/.MyHome/MySpaces/my-modular-workspace/` | To configure |
| NixOS config | `~/.config/nixos/` | `~/.config/nixos/` | No change |

**Username change:** `mitso` → `mitsio` (already applied)

---

## Architecture Integration

Your comprehensive architecture combines:

### Layer 1: Local Storage (Primary)
```
~/.MyHome/
└── MySpaces/
    └── my-modular-workspace/    # Your workspace (this repo!)
        ├── home-manager/        # Nix configs
        ├── my-dotfiles/         # App configs
        ├── docs/                # Documentation
        └── sessions/            # Work sessions
```

### Layer 2: Real-time Sync (Syncthing)
```
shoshin ~/.MyHome/MySpaces/my-modular-workspace/
    ↕ (real-time, P2P)
laptop-system01 ~/.MyHome/MySpaces/my-modular-workspace/
    ↕ (real-time, P2P)
Android /storage/emulated/0/Syncthing/MyHome/
```

### Layer 3: Cloud Backup (rclone bisync)
```
~/.MyHome/MySpaces/my-modular-workspace/
    ↕ (every 30 minutes, bidirectional)
gdrive:MyHome/MySpaces/my-modular-workspace/
```

---

## Required Configuration Updates

### 1. Update rclone-bisync.nix Paths

```nix
# OLD (from your previous session)
/home/mitso/MyHome/

# NEW (for moved directory)
/home/mitsio/.MyHome/
```

### 2. Update Sync Remote Name

From your current docs, you're using:
- Old: `GoogleDrive-dtsioumas0:/MyHome/`
- New: `gdrive:MyHome/MySpaces/my-modular-workspace/`

### 3. Sync Interval Change

Your previous plan: **Hourly** (conservative)
Documentation created: **Every 30 minutes** (your requested schedule)

**Recommendation:** Start with 30 minutes as documented, can adjust based on:
- Network stability
- Bandwidth usage
- Conflict frequency
- Battery impact (if on laptop)

---

## Integration with home-manager

### Create Module: `home-manager/rclone-gdrive.nix`

This will be the home-manager equivalent of your NixOS modules:

```nix
{ config, pkgs, lib, ... }:

{
  # Install rclone
  home.packages = with pkgs; [
    rclone
    libnotify  # For notifications
  ];

  # Create script
  home.file."bin/rclone-gdrive-sync.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      SOURCE="${config.home.homeDirectory}/.MyHome/MySpaces/my-modular-workspace/"
      DEST="gdrive:MyHome/MySpaces/my-modular-workspace/"
      LOG_DIR="${config.home.homeDirectory}/.cache/rclone"
      LOG_FILE="$LOG_DIR/sync-$(date +%Y%m%d-%H%M%S).log"

      mkdir -p "$LOG_DIR"
      ls -t "$LOG_DIR"/sync-*.log 2>/dev/null | tail -n +11 | xargs -r rm

      if ${pkgs.rclone}/bin/rclone sync \
        "$SOURCE" "$DEST" \
        --fast-list \
        --transfers 4 \
        --checkers 8 \
        --drive-chunk-size 256M \
        --stats 1m \
        --log-file "$LOG_FILE" \
        --log-level INFO \
        --exclude '.git/**' \
        --exclude 'result*' \
        --exclude '*.swp'; then
        ${pkgs.libnotify}/bin/notify-send -i cloud-upload "rclone Sync" "Success"
      else
        ${pkgs.libnotify}/bin/notify-send -i dialog-error -u critical "rclone Sync Failed" "Check logs"
      fi
    '';
    executable = true;
  };

  # Systemd service + timer (30 min interval)
  systemd.user.services.rclone-gdrive-sync = {
    Unit.Description = "Sync to Google Drive";
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/bin/rclone-gdrive-sync.sh";
    };
  };

  systemd.user.timers.rclone-gdrive-sync = {
    Unit.Description = "Google Drive sync every 30 minutes";
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
```

### Import in home.nix

```nix
imports = [
  ./rclone-gdrive.nix
  # ... other imports
];
```

---

## Syncthing Configuration

### For shoshin (Desktop)

Already configured in your NixOS modules. Just needs activation.

### For laptop-system01

Use home-manager module (since no NixOS there):

```nix
# In laptop's home.nix
services.syncthing = {
  enable = true;
  dataDir = "${config.home.homeDirectory}/.local/share/syncthing";
  configDir = "${config.home.homeDirectory}/.config/syncthing";
};
```

### For Android (xiaomi-poco-x6)

Install from F-Droid/Play Store:
- App: Syncthing
- Folder path: `/storage/emulated/0/Syncthing/MyHome/`
- Share with: shoshin, laptop-system01

---

## Deployment Status

### From Previous Sessions

✅ Modules created:
- `modules/workspace/rclone-bisync.nix`
- `modules/workspace/syncthing-myspaces.nix`
- `modules/system/firewall.nix`

❌ Not yet deployed:
- Waiting for user confirmation
- Pre-deployment checks needed
- Path updates required (mitso → mitsio, ~/MyHome → ~/.MyHome)

### Current Documentation

✅ Comprehensive architecture documented in:
- `README.md` - Overview with diagrams
- `02-syncthing-setup.md` - Syncthing configuration
- `03-rclone-setup.md` - rclone & Google Drive setup
- `04-systemd-automation.md` - systemd timers
- `05-verification-and-troubleshooting.md` - Testing & debugging
- `00-CURRENT-SETUP.md` - This file (integration with existing work)

---

## Next Steps

### Immediate (Before Deployment)

1. **Update NixOS modules** with new paths:
   - `/home/mitso/` → `/home/mitsio/`
   - `/home/mitso/MyHome/` → `/home/mitsio/.MyHome/`

2. **Verify rclone remote name:**
   ```bash
   rclone config show gdrive
   ```
   If it shows `GoogleDrive-dtsioumas0`, either:
   - Rename: `rclone config rename GoogleDrive-dtsioumas0 gdrive`
   - Or update scripts to use `GoogleDrive-dtsioumas0`

3. **Review pre-deployment checks** from your session:
   - `sessions/gdrive-migration-syncthing-backup/PRE_DEPLOYMENT_CHECKS.md`

### During Deployment

Follow your existing deployment plan:
- `sessions/gdrive-migration-syncthing-backup/DEPLOYMENT_PLAN.md`

Update paths in step 3 (Initial resync):
```bash
# OLD
/home/mitso/MyHome/

# NEW
/home/mitsio/.MyHome/
```

### After Deployment

1. **Verify services:**
   ```bash
   systemctl --user status rclone-gdrive-sync.timer
   systemctl --user status syncthing
   ```

2. **Test sync:**
   ```bash
   # Create test file
   echo "test" > ~/.MyHome/MySpaces/my-modular-workspace/test.txt

   # Wait 30 min or trigger manually
   systemctl --user start rclone-gdrive-sync

   # Verify on Google Drive
   rclone ls gdrive:MyHome/MySpaces/my-modular-workspace/ | grep test.txt
   ```

3. **Setup Android Syncthing:**
   - Follow `02-syncthing-setup.md` Android section
   - Use device ID from: `syncthing-id`

---

## Decision Log

### Why ~/.MyHome instead of ~/MyHome?

✅ **Hidden directory** - Cleaner home folder
✅ **Less clutter** - Not visible in default file browser
✅ **Conventional** - Follows Unix hidden file pattern
✅ **Portable** - Works across all systems

### Why 30-minute sync vs hourly?

✅ **More frequent backups** - Less data loss risk
✅ **Below API limits** - Google Drive handles this easily
✅ **Responsive** - Changes propagate reasonably fast
⚠️ **Can adjust** - Easy to change timer if needed

### Why Syncthing + rclone (not just one)?

From your architecture decision:
- **Syncthing:** Real-time P2P sync (no internet required, offline work)
- **rclone:** Cloud backup (disaster recovery, access from anywhere)
- **Together:** Best of both worlds

---

## Quick Reference

### Common Commands

```bash
# Sync Status
systemctl --user list-timers | grep rclone

# Manual sync
systemctl --user start rclone-gdrive-sync

# View logs
journalctl --user -u rclone-gdrive-sync -f

# Syncthing status
systemctl --user status syncthing

# Web GUI
xdg-open http://localhost:8384
```

### Important Paths

| Purpose | Path |
|---------|------|
| Local workspace | `~/.MyHome/MySpaces/my-modular-workspace/` |
| rclone config | `~/.config/rclone/rclone.conf` |
| Syncthing config | `~/.config/syncthing/` |
| NixOS config | `~/.config/nixos/` |
| Sync logs | `~/.cache/rclone/sync-*.log` |
| Sessions docs | `~/.MyHome/MySpaces/my-modular-workspace/sessions/` |

---

## Conclusion

You have a well-planned architecture combining:
1. **Local-first** storage (`~/.MyHome/`)
2. **Real-time sync** between devices (Syncthing)
3. **Scheduled cloud backup** (rclone every 30 min)
4. **Automated management** (systemd timers)
5. **Comprehensive documentation** (this directory!)

**Status:** Ready for deployment after path updates

**Next:** Update NixOS modules, then follow `DEPLOYMENT_PLAN.md`

---

**Author:** Mitsio + Claude Code
**Session:** my-modular-workspace-gdrive-migration-syncthing-backup
**Documentation:** ~/.MyHome/MySpaces/my-modular-workspace/docs/syncthing-gdrive-architecture/
