# systemd Automation Guide

**Purpose:** Automate sync services with systemd timers
**Platform:** Linux (systemd-based systems)

---

## Overview

This guide covers systemd service and timer configuration for:

1. **Syncthing service** - Continuous P2P sync daemon
2. **rclone-gdrive-sync** - Scheduled cloud backup every 30 minutes

---

## Syncthing systemd Service

### Service File

Located at: `~/.config/systemd/user/syncthing.service` (created by home-manager)

```ini
[Unit]
Description=Syncthing - Open Source Continuous File Synchronization
Documentation=https://docs.syncthing.net/
After=network.target

[Service]
ExecStart=/nix/store/.../bin/syncthing -no-browser -no-restart
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

# Security
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=default.target
```

### Manage Syncthing Service

```bash
# Start
systemctl --user start syncthing

# Stop
systemctl --user stop syncthing

# Restart
systemctl --user restart syncthing

# Enable (start on boot)
systemctl --user enable syncthing

# Status
systemctl --user status syncthing

# Logs
journalctl --user -u syncthing -f
```

---

## rclone Google Drive Sync

### Service File

Create: `~/.config/systemd/user/rclone-gdrive-sync.service`

```ini
[Unit]
Description=Sync ~/.MyHome to Google Drive
After=network-online.target syncthing.service
Wants=network-online.target
Requires=syncthing.service

[Service]
Type=oneshot
ExecStart=%h/bin/rclone-gdrive-sync.sh

# Environment
Environment="RCLONE_CONFIG=%h/.config/rclone/rclone.conf"

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=rclone-sync

# Security
NoNewPrivileges=true
PrivateTmp=true

# Resource limits (optional)
CPUQuota=50%
IOWeight=100
```

### Timer File

Create: `~/.config/systemd/user/rclone-gdrive-sync.timer`

```ini
[Unit]
Description=Google Drive sync every 30 minutes
Requires=rclone-gdrive-sync.service

[Timer]
# First run: 5 minutes after boot
OnBootSec=5min

# Recurring: every 30 minutes from last activation
OnUnitActiveSec=30min

# Run missed timers (if system was off)
Persistent=true

# Randomize start time by up to 2 minutes (reduce server load)
RandomizedDelaySec=2min

[Install]
WantedBy=timers.target
```

### Sync Script

Create: `~/bin/rclone-gdrive-sync.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# Configuration
SOURCE="$HOME/.MyHome/MySpaces/my-modular-workspace/"
DEST="gdrive:MyHome/MySpaces/my-modular-workspace/"
LOG_DIR="$HOME/.cache/rclone"
LOG_FILE="$LOG_DIR/sync-$(date +%Y%m%d-%H%M%S).log"

# Create log directory
mkdir -p "$LOG_DIR"

# Log rotation (keep only last 10 logs)
ls -t "$LOG_DIR"/sync-*.log 2>/dev/null | tail -n +11 | xargs -r rm

# Log start
echo "=== rclone Sync Started at $(date) ===" | tee -a "$LOG_FILE"
echo "Source: $SOURCE" | tee -a "$LOG_FILE"
echo "Dest: $DEST" | tee -a "$LOG_FILE"

# Perform sync
if /nix/store/.../bin/rclone sync \
  "$SOURCE" \
  "$DEST" \
  --fast-list \
  --transfers 4 \
  --checkers 8 \
  --drive-chunk-size 256M \
  --stats 1m \
  --log-file "$LOG_FILE" \
  --log-level INFO \
  --exclude '.git/**' \
  --exclude 'result*' \
  --exclude '*.swp' \
  --exclude '*.tmp'; then

  # Success
  echo "=== Sync Completed Successfully at $(date) ===" | tee -a "$LOG_FILE"

  # Desktop notification (if available)
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -i cloud-upload "rclone Sync" "Synced to Google Drive successfully"
  fi

  exit 0
else
  # Failure
  EXIT_CODE=$?
  echo "=== Sync Failed with code $EXIT_CODE at $(date) ===" | tee -a "$LOG_FILE"

  # Error notification
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -i dialog-error -u critical "rclone Sync Failed" "Check log: $LOG_FILE"
  fi

  exit $EXIT_CODE
fi
```

Make executable:
```bash
chmod +x ~/bin/rclone-gdrive-sync.sh
```

---

## Activation Commands

### Enable and Start Services

```bash
# Reload systemd to see new units
systemctl --user daemon-reload

# Enable Syncthing (auto-start on boot)
systemctl --user enable syncthing.service
systemctl --user start syncthing.service

# Enable rclone timer (auto-start on boot)
systemctl --user enable rclone-gdrive-sync.timer
systemctl --user start rclone-gdrive-sync.timer
```

### Verify Services

```bash
# Check Syncthing status
systemctl --user status syncthing.service

# Check timer status
systemctl --user list-timers | grep rclone

# Output:
# NEXT                         LEFT          LAST  PASSED  UNIT                       ACTIVATES
# Mon 2025-11-18 15:30:00 EET  29min left    n/a   n/a     rclone-gdrive-sync.timer   rclone-gdrive-sync.service
```

---

## Testing

### Manual Trigger

Trigger sync manually (without waiting for timer):

```bash
systemctl --user start rclone-gdrive-sync.service
```

Watch logs in real-time:
```bash
journalctl --user -u rclone-gdrive-sync.service -f
```

### Dry Run Test

Modify script temporarily to add `--dry-run`:

```bash
# Edit ~/bin/rclone-gdrive-sync.sh
# Add --dry-run to rclone command

# Run
systemctl --user start rclone-gdrive-sync.service

# Check what would be synced
journalctl --user -u rclone-gdrive-sync.service -n 100
```

---

## Monitoring

### Check Last Sync Time

```bash
systemctl --user show rclone-gdrive-sync.service -p ExecMainExitTimestamp
```

### View Sync History

```bash
# Last 5 syncs
journalctl --user -u rclone-gdrive-sync.service -n 5

# Today's syncs
journalctl --user -u rclone-gdrive-sync.service --since today
```

### Sync Statistics

```bash
# Log files
ls -lh ~/.cache/rclone/sync-*.log

# Latest log
tail -f ~/.cache/rclone/sync-*.log | sort | tail -1
```

---

## Timer Modifications

### Change Sync Frequency

Edit timer file to change frequency:

**Every 15 minutes:**
```ini
OnUnitActiveSec=15min
```

**Every hour:**
```ini
OnUnitActiveSec=1h
```

**Specific times (e.g., every day at 2 AM):**
```ini
# Remove OnUnitActiveSec
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
```

After changes:
```bash
systemctl --user daemon-reload
systemctl --user restart rclone-gdrive-sync.timer
```

### Disable Automatic Sync

```bash
# Stop and disable timer
systemctl --user stop rclone-gdrive-sync.timer
systemctl --user disable rclone-gdrive-sync.timer

# Manual sync only
systemctl --user start rclone-gdrive-sync.service
```

---

## home-manager Integration (Complete Example)

### Create Module: `rclone-automation.nix`

```nix
{ config, pkgs, lib, ... }:

{
  # Sync script
  home.file."bin/rclone-gdrive-sync.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      SOURCE="$HOME/.MyHome/MySpaces/my-modular-workspace/"
      DEST="gdrive:MyHome/MySpaces/my-modular-workspace/"
      LOG_DIR="$HOME/.cache/rclone"
      LOG_FILE="$LOG_DIR/sync-$(date +%Y%m%d-%H%M%S).log"

      mkdir -p "$LOG_DIR"
      ls -t "$LOG_DIR"/sync-*.log 2>/dev/null | tail -n +11 | xargs -r rm

      echo "=== Sync Started at $(date) ===" | tee -a "$LOG_FILE"

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
        --exclude 'result*'; then
        echo "=== Success at $(date) ===" | tee -a "$LOG_FILE"
        ${pkgs.libnotify}/bin/notify-send -i cloud-upload "rclone Sync" "Success"
        exit 0
      else
        echo "=== Failed at $(date) ===" | tee -a "$LOG_FILE"
        ${pkgs.libnotify}/bin/notify-send -i dialog-error -u critical "rclone Sync Failed" "Check logs"
        exit 1
      fi
    '';
    executable = true;
  };

  # Systemd service
  systemd.user.services.rclone-gdrive-sync = {
    Unit = {
      Description = "Sync to Google Drive";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/bin/rclone-gdrive-sync.sh";
    };
  };

  # Systemd timer
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

### Import and Apply

```nix
# In home.nix
imports = [
  ./rclone-automation.nix
];
```

```bash
home-manager switch --flake .#mitsio@shoshin
systemctl --user start rclone-gdrive-sync.timer
```

---

## Troubleshooting

### Timer Not Triggering

```bash
# Check timer is active
systemctl --user is-active rclone-gdrive-sync.timer

# Check timer schedule
systemctl --user list-timers rclone-gdrive-sync.timer

# Restart timer
systemctl --user restart rclone-gdrive-sync.timer
```

### Service Failing

```bash
# Check service status
systemctl --user status rclone-gdrive-sync.service

# View full logs
journalctl --user -u rclone-gdrive-sync.service --no-pager

# Test script manually
~/bin/rclone-gdrive-sync.sh
```

### Sync Not Running

**Check:**
1. Timer enabled: `systemctl --user is-enabled rclone-gdrive-sync.timer`
2. Script executable: `ls -l ~/bin/rclone-gdrive-sync.sh`
3. rclone configured: `rclone config show gdrive`
4. Network connectivity: `ping google.com`

---

**Last Updated:** 2025-11-18
**Version:** 1.0
**Author:** Mitsio
