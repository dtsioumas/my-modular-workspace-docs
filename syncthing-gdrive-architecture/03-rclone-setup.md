# rclone + Google Drive Setup Guide

**Purpose:** Configure rclone for automated cloud backup to Google Drive
**Platform:** Linux (shoshin primary sync hub)

---

## Table of Contents

1. [Installation](#installation)
2. [Google Drive Configuration](#google-drive-configuration)
3. [rclone Remote Setup](#rclone-remote-setup)
4. [Testing the Connection](#testing-the-connection)
5. [Sync Commands](#sync-commands)
6. [home-manager Integration](#home-manager-integration)

---

## Installation

### Via home-manager (Recommended)

Add to `home-manager/home.nix`:

```nix
home.packages = with pkgs; [
  rclone
];
```

Apply:
```bash
home-manager switch --flake .#mitsio@shoshin
```

### Manual Installation (Alternative)

```bash
# NixOS
nix-env -iA nixos.rclone

# Or download binary
curl https://rclone.org/install.sh | sudo bash
```

Verify installation:
```bash
rclone version
# Output: rclone v1.xx.x
```

---

## Google Drive Configuration

### Prerequisites

1. **Google Account** with Google Drive enabled
2. **Google Cloud Project** (free tier sufficient)
3. **OAuth 2.0 Credentials**

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Create Project**
   - Name: `rclone-gdrive-sync`
   - Click **Create**

### Step 2: Enable Google Drive API

1. In your project, go to **APIs & Services** → **Library**
2. Search for "Google Drive API"
3. Click **Enable**

### Step 3: Create OAuth 2.0 Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. If prompted, configure OAuth consent screen:
   - User Type: **External**
   - App name: `rclone-gdrive-sync`
   - User support email: your@email.com
   - Developer email: your@email.com
   - Scopes: `https://www.googleapis.com/auth/drive`
   - Save and Continue
4. Create OAuth Client ID:
   - Application type: **Desktop app**
   - Name: `rclone-desktop`
   - Click **Create**
5. **Copy the Client ID and Client Secret** (you'll need these next)

---

## rclone Remote Setup

### Interactive Configuration

Run the configuration wizard:

```bash
rclone config
```

Follow these steps:

```
n) New remote
name> gdrive
Storage> drive
client_id> <paste-your-client-id>
client_secret> <paste-your-client-secret>
scope> drive.file
service_account_file> <press Enter>
Edit advanced config? n
Use auto config? Y
```

This will open a browser for Google OAuth authentication:

1. Sign in to your Google Account
2. Click **Allow** to grant access
3. Browser shows: "Success! All done. Please go back to rclone."
4. Return to terminal

```
Configure this as a Shared Drive (Team Drive)? n
y) Yes this is OK
```

Configuration saved!

### Verify Configuration

```bash
rclone config show gdrive
```

Output:
```ini
[gdrive]
type = drive
client_id = <your-client-id>
client_secret = <your-client-secret>
scope = drive.file
token = {"access_token":"...","token_type":"Bearer",...}
```

### Test Connection

```bash
rclone lsd gdrive:
# Should list your Google Drive folders
```

---

## Testing the Connection

### Create Test Directory Structure on Google Drive

```bash
# Create MyHome directory on Google Drive
rclone mkdir gdrive:MyHome
rclone mkdir gdrive:MyHome/MySpaces

# Verify
rclone lsd gdrive:MyHome
# Output: MySpaces
```

### Test Upload

```bash
# Create test file
echo "rclone test" > /tmp/rclone-test.txt

# Upload to Google Drive
rclone copy /tmp/rclone-test.txt gdrive:MyHome/

# Verify
rclone ls gdrive:MyHome/
# Output: 12 rclone-test.txt

# Clean up
rclone delete gdrive:MyHome/rclone-test.txt
rm /tmp/rclone-test.txt
```

---

## Sync Commands

### Basic Sync Command

**One-way sync** (local → Google Drive):

```bash
rclone sync ~/.MyHome/MySpaces/my-modular-workspace/ gdrive:MyHome/MySpaces/my-modular-workspace/
```

**What this does:**
- Copies new/modified files from local to Google Drive
- Deletes files from Google Drive that were deleted locally
- **WARNING:** One-way only! Changes on GDrive will be lost

### Recommended Sync Command (with options)

```bash
rclone sync \
  ~/.MyHome/MySpaces/my-modular-workspace/ \
  gdrive:MyHome/MySpaces/my-modular-workspace/ \
  --fast-list \
  --transfers 4 \
  --checkers 8 \
  --drive-chunk-size 256M \
  --stats 1m \
  --log-file ~/.cache/rclone/sync.log \
  --log-level INFO
```

**Options explained:**
- `--fast-list`: Use recursive list (faster for large directories)
- `--transfers 4`: Upload 4 files in parallel
- `--checkers 8`: Check 8 files concurrently for changes
- `--drive-chunk-size 256M`: Upload in 256MB chunks
- `--stats 1m`: Show progress every 1 minute
- `--log-file`: Save logs to file
- `--log-level INFO`: Detailed logging

### Dry Run (Test Without Changes)

Always test first with `--dry-run`:

```bash
rclone sync \
  ~/.MyHome/MySpaces/my-modular-workspace/ \
  gdrive:MyHome/MySpaces/my-modular-workspace/ \
  --dry-run \
  --verbose
```

This shows what would be transferred without actually doing it.

### Other Useful Commands

**List files:**
```bash
rclone ls gdrive:MyHome/
rclone lsd gdrive:MyHome/  # directories only
```

**Check for differences:**
```bash
rclone check ~/.MyHome/MySpaces/my-modular-workspace/ gdrive:MyHome/MySpaces/my-modular-workspace/
```

**Size of remote directory:**
```bash
rclone size gdrive:MyHome/MySpaces/my-modular-workspace/
```

**Mount Google Drive (optional, for browsing):**
```bash
mkdir -p ~/mnt/gdrive
rclone mount gdrive: ~/mnt/gdrive --daemon
# Browse: ls ~/mnt/gdrive
# Unmount: fusermount -u ~/mnt/gdrive
```

---

## home-manager Integration

### Create rclone Config Module

Create `home-manager/rclone-gdrive.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  # Install rclone
  home.packages = with pkgs; [
    rclone
  ];

  # Create cache directory for logs
  home.file.".cache/rclone/.keep".text = "";

  # rclone sync script
  home.file."bin/rclone-gdrive-sync.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      SOURCE="$HOME/.MyHome/MySpaces/my-modular-workspace/"
      DEST="gdrive:MyHome/MySpaces/my-modular-workspace/"
      LOG_FILE="$HOME/.cache/rclone/sync-$(date +%Y%m%d-%H%M%S).log"

      echo "Starting rclone sync at $(date)" | tee -a "$LOG_FILE"

      ${pkgs.rclone}/bin/rclone sync \
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
        --exclude '*.tmp'

      EXIT_CODE=$?

      if [ $EXIT_CODE -eq 0 ]; then
        echo "Sync completed successfully at $(date)" | tee -a "$LOG_FILE"
        ${pkgs.libnotify}/bin/notify-send \
          -i "cloud-upload" \
          "rclone Sync Complete" \
          "Synced to Google Drive successfully"
      else
        echo "Sync failed with exit code $EXIT_CODE at $(date)" | tee -a "$LOG_FILE"
        ${pkgs.libnotify}/bin/notify-send \
          -i "dialog-error" \
          -u critical \
          "rclone Sync Failed" \
          "Check log: $LOG_FILE"
      fi

      exit $EXIT_CODE
    '';
    executable = true;
  };

  # Systemd service for sync
  systemd.user.services.rclone-gdrive-sync = {
    Unit = {
      Description = "Sync ~/.MyHome to Google Drive";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/bin/rclone-gdrive-sync.sh";
    };
  };

  # Systemd timer for automatic sync every 30 minutes
  systemd.user.timers.rclone-gdrive-sync = {
    Unit = {
      Description = "Google Drive sync every 30 minutes";
    };

    Timer = {
      OnBootSec = "5min";           # First sync 5 minutes after boot
      OnUnitActiveSec = "30min";    # Then every 30 minutes
      Persistent = true;            # Run if missed while system was off
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
```

### Import in home.nix

Add to `home-manager/home.nix`:

```nix
imports = [
  ./rclone-gdrive.nix
  # ... other imports
];
```

### Apply Configuration

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin
```

### Enable and Start Timer

```bash
# Enable timer (auto-start on boot)
systemctl --user enable rclone-gdrive-sync.timer

# Start timer now
systemctl --user start rclone-gdrive-sync.timer

# Check timer status
systemctl --user list-timers | grep rclone

# Trigger manual sync (test)
systemctl --user start rclone-gdrive-sync.service

# Check logs
journalctl --user -u rclone-gdrive-sync.service -n 50
```

---

## Excluding Files from Sync

Create `~/.config/rclone/rclone.conf` filter file or use command-line flags:

```bash
--exclude '.git/**'
--exclude 'result*'
--exclude '*.swp'
--exclude '*.tmp'
--exclude '.stversions/**'
```

Or create filter file `~/.config/rclone/filters.txt`:

```
# Exclude git
- .git/**

# Exclude Nix build artifacts
- result
- result-*

# Exclude editor temporary files
- *.swp
- *.tmp
- *~

# Exclude Syncthing versioning
- .stversions/**

# Exclude large media (optional)
- *.iso
- *.img
- *.vmdk
```

Use filter file:
```bash
rclone sync SOURCE DEST --filter-from ~/.config/rclone/filters.txt
```

---

## Bandwidth Management

### Limit Upload Speed

```bash
rclone sync SOURCE DEST --bwlimit 1M  # 1 MB/s max
```

### Schedule-based Limits

Different limits for different times:

```bash
# 500KB/s on weekdays 9-17, unlimited otherwise
rclone sync SOURCE DEST --bwlimit "Mon-Fri,09:00,17:00,500k"
```

### In home-manager Script

Add to sync script:
```bash
--bwlimit "Mon-Fri,08:00,18:00,1M"
```

---

## Monitoring and Logging

### View Recent Sync Logs

```bash
# Systemd journal
journalctl --user -u rclone-gdrive-sync.service -n 100

# Log files
tail -f ~/.cache/rclone/sync-*.log

# Last sync status
systemctl --user status rclone-gdrive-sync.service
```

### Sync Statistics

```bash
# Show what would be synced
rclone sync SOURCE DEST --dry-run --stats 10s

# Show size comparison
rclone size SOURCE
rclone size DEST
```

---

## Security Considerations

### rclone Config File Location

**Default:** `~/.config/rclone/rclone.conf`

This file contains OAuth tokens - protect it:

```bash
chmod 600 ~/.config/rclone/rclone.conf
```

### Encrypt rclone Config (Optional)

```bash
# Set password for config
rclone config password

# Enter password when prompted
# rclone will now require password to read config
```

### OAuth Token Refresh

rclone automatically refreshes OAuth tokens. If sync fails with authentication error:

```bash
# Re-authenticate
rclone config reconnect gdrive:
```

---

## Troubleshooting

### Error: "403 Forbidden"

**Cause:** API quota exceeded or permissions issue

**Solution:**
1. Check Google Cloud Console → APIs & Services → Quotas
2. Verify OAuth consent screen is published
3. Re-authenticate: `rclone config reconnect gdrive:`

### Error: "Failed to create file system"

**Cause:** Invalid remote name or config

**Solution:**
```bash
rclone config show gdrive  # verify config exists
rclone lsd gdrive:  # test connection
```

### Sync is Slow

**Optimizations:**
```bash
--fast-list           # Use recursive listing
--transfers 8         # More parallel transfers
--checkers 16         # More parallel checks
--drive-chunk-size 256M  # Larger chunks
```

### Partial Sync / Missing Files

**Check:**
1. Exclude patterns not blocking files
2. Sufficient Google Drive quota
3. No file name conflicts (case sensitivity)

**Solution:**
```bash
# Check what's being excluded
rclone sync SOURCE DEST --dry-run --verbose
```

---

## Next Steps

✅ rclone configured with Google Drive
✅ Manual sync tested
⏭️ Proceed to [04-systemd-automation.md](04-systemd-automation.md) for automation details

---

**References:**
- [rclone Documentation](https://rclone.org/docs/)
- [rclone Google Drive](https://rclone.org/drive/)
- [Google Drive API](https://developers.google.com/drive)

---

**Last Updated:** 2025-11-18
**Version:** 1.0
**Author:** Mitsio
