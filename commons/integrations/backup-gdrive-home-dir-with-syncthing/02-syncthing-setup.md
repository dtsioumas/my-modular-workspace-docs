# Syncthing Setup Guide

**Purpose:** Configure Syncthing for real-time P2P synchronization across devices
**Platforms:** Linux (shoshin, laptop-system01), Android (xiaomi-poco-x6)

---

## Table of Contents

1. [Installation](#installation)
2. [Initial Configuration](#initial-configuration)
3. [Adding Devices](#adding-devices)
4. [Folder Configuration](#folder-configuration)
5. [Android Setup](#android-setup)
6. [Verification](#verification)

---

## Installation

### Linux (NixOS via home-manager)

Add to `home-manager/home.nix`:

```nix
home.packages = with pkgs; [
  syncthing
];

# Enable Syncthing service
systemd.user.services.syncthing = {
  Unit = {
    Description = "Syncthing - Open Source Continuous File Synchronization";
    After = [ "network.target" ];
  };

  Service = {
    ExecStart = "${pkgs.syncthing}/bin/syncthing -no-browser -no-restart";
    Restart = "on-failure";
    SuccessExitStatus = [ 3 4 ];
    RestartForceExitStatus = [ 3 4 ];
  };

  Install = {
    WantedBy = [ "default.target" ];
  };
};
```

Apply configuration:
```bash
home-manager switch --flake .#mitsio@shoshin
```

Start service:
```bash
systemctl --user start syncthing
systemctl --user enable syncthing
```

### Android

1. Install from F-Droid or Play Store: **Syncthing**
2. Grant storage permissions
3. Enable "Run in Background"
4. Disable battery optimization for Syncthing

---

## Initial Configuration

### Access Web GUI

**On shoshin (Desktop):**
```bash
# Open browser to:
http://localhost:8384
```

**On laptop-system01:**
```bash
http://localhost:8384
```

**On Android:**
- Open Syncthing app
- Tap menu (☰) → Web GUI

### Get Device IDs

Each device has a unique ID. You'll need these to connect devices.

**Linux:**
```bash
syncthing --device-id
# Or from Web GUI: Actions → Show ID
```

**Android:**
- Tap menu (☰) → Device ID
- Tap to copy or show QR code

**Example Device IDs:**
```
shoshin:         ABC123-DEF456-GHI789...
laptop-system01: XYZ789-UVW456-RST123...
xiaomi-poco-x6:  QWE098-ASD765-ZXC432...
```

---

## Adding Devices

### Step 1: Add Remote Devices on shoshin

1. Open Web GUI: `http://localhost:8384`
2. Click **Add Remote Device**
3. Enter Device ID (from laptop or Android)
4. Set device name:
   - `laptop-system01` (for laptop)
   - `xiaomi-poco-x6` (for Android)
5. Click **Save**

### Step 2: Accept Connection on Remote Device

**On laptop-system01:**
1. Web GUI will show notification: "New Device"
2. Click **Add Device**
3. Confirm device name: `shoshin`
4. Click **Save**

**On Android:**
1. Notification appears: "Device shoshin wants to connect"
2. Tap notification
3. Tap **Add**

### Step 3: Verify Connection

All devices should now show as "Connected" in Web GUI:
```
Devices:
├── shoshin (This Device) - Syncing
├── laptop-system01 - Connected, Idle
└── xiaomi-poco-x6 - Connected, Idle
```

---

## Folder Configuration

### Create Shared Folder

**On shoshin (Hub Device):**

1. Web GUI → **Add Folder**

2. **General Tab:**
   - **Folder Label:** `My Modular Workspace`
   - **Folder ID:** `my-modular-workspace` (auto-generated, can customize)
   - **Folder Path:** `/home/mitsio/.MyHome/MySpaces/my-modular-workspace`

3. **Sharing Tab:**
   - ✅ `laptop-system01`
   - ✅ `xiaomi-poco-x6`

4. **File Versioning:**
   - Type: **Simple File Versioning**
   - Keep Versions: `5`

5. **Ignore Patterns:**
   ```
   # Build artifacts
   *.tmp
   *.swp
   .DS_Store

   # Nix build results
   result
   result-*

   # Git
   .git

   # Editor
   .vscode/
   .idea/

   # Large files (optional)
   *.iso
   *.img
   ```

6. **Advanced Tab:**
   - ✅ Watch for Changes
   - Rescan Interval: `3600` (1 hour)
   - File Pull Order: `Random`
   - ✅ Sync Ownership: false (for cross-platform compatibility)

7. Click **Save**

### Accept Folder on Remote Devices

**On laptop-system01:**

1. Notification: "shoshin wants to share folder 'My Modular Workspace'"
2. Click notification
3. **Folder Path:** `/home/mitsio/.MyHome/MySpaces/my-modular-workspace`
4. Click **Save**

**On Android:**

1. Notification: "shoshin wants to share folder"
2. Tap notification
3. **Folder Path:** `/storage/emulated/0/Syncthing/MyHome`
4. Tap **Create** to create directory
5. Tap **Save**

---

## Android Setup

### Recommended Settings

**Syncthing App → Settings:**

```
Run Conditions:
├── Run in background: ON
├── Start on boot: ON
└── Battery optimization: OFF (grant exemption)

Sync Conditions:
├── Sync on WiFi: ON
├── Sync on mobile data: OFF (optional, based on data plan)
├── Sync on charging: ON
└── Sync only on SSID: (leave blank for all WiFi)

Behavior:
├── Respect Android battery saver: OFF
└── Use wake locks: ON
```

### Storage Permissions

Grant storage access:
```
Settings → Apps → Syncthing → Permissions
└── Storage: Allow
```

### Android Folder Structure

```
/storage/emulated/0/
└── Syncthing/
    └── MyHome/
        ├── MySpaces/
        │   └── my-modular-workspace/
        │       ├── docs/           # ← Synced documentation
        │       └── sessions/       # ← Session notes
        └── .stfolder              # Syncthing marker
```

**Note:** Some folders (e.g., `home-manager/*.nix`) may not be useful on Android but are synced for completeness.

---

## Advanced Configuration

### Bandwidth Limits (Optional)

If you want to limit Syncthing's bandwidth usage:

**Web GUI → Settings → Connections:**

```
Rate Limits:
├── Upload Rate (KiB/s): 0 (unlimited) or set limit
├── Download Rate (KiB/s): 0 (unlimited) or set limit
└── Enable rate limiting in local network: OFF
```

### Discovery Settings

**Web GUI → Settings → Connections:**

```
Discovery:
├── Global Discovery: ON (for internet sync)
├── Local Discovery: ON (for LAN sync)
└── Enable Relaying: ON (for NAT traversal)
```

### Folder Types

Different folder types for different use cases:

| Type | Use Case | Behavior |
|------|----------|----------|
| **Send & Receive** | Default (bidirectional) | Full two-way sync |
| **Send Only** | Source device (e.g., backups) | Only sends files, doesn't receive |
| **Receive Only** | Backup target | Only receives files, doesn't send changes |

**For this setup:** Use **Send & Receive** on all devices for full bidirectional sync.

---

## Verification

### Check Sync Status

**Web GUI:**
```
Folders:
└── My Modular Workspace
    ├── Up to Date: Yes
    ├── Local State: XX files, YY GB
    └── Global State: XX files, YY GB
```

**Command Line:**
```bash
# Check service status
systemctl --user status syncthing

# Monitor sync in real-time
journalctl --user -u syncthing -f
```

### Test Sync

1. **Create test file on shoshin:**
   ```bash
   echo "Syncthing test" > ~/.MyHome/MySpaces/my-modular-workspace/sync-test.txt
   ```

2. **Wait 1-5 seconds**

3. **Verify on laptop-system01:**
   ```bash
   cat ~/.MyHome/MySpaces/my-modular-workspace/sync-test.txt
   # Output: Syncthing test
   ```

4. **Verify on Android:**
   - Open file manager
   - Navigate to `/storage/emulated/0/Syncthing/MyHome/MySpaces/my-modular-workspace/`
   - Check for `sync-test.txt`

5. **Clean up:**
   ```bash
   rm ~/.MyHome/MySpaces/my-modular-workspace/sync-test.txt
   ```

---

## Troubleshooting

### Device Not Connecting

**Check:**
1. Firewall allows TCP/22000 and UDP/22000
2. Both devices on same network (for LAN discovery)
3. Global discovery enabled (for internet sync)
4. Device IDs correct

**Solution:**
```bash
# Restart Syncthing
systemctl --user restart syncthing

# Check logs
journalctl --user -u syncthing -n 50
```

### Folder Not Syncing

**Check:**
1. Folder shared with remote device
2. Folder path exists on both devices
3. No ignore patterns blocking files
4. Sufficient disk space

**Solution:**
```bash
# Force rescan
# Web GUI → Folder → Rescan
```

### Android Battery Drain

**Solutions:**
1. Disable sync on mobile data (use WiFi only)
2. Enable "Sync only when charging"
3. Set specific WiFi SSIDs for sync
4. Reduce fsWatcher sensitivity

---

## Security Best Practices

1. **Enable authentication** on Web GUI:
   ```
   Settings → GUI → Enable Authentication
   Username: mitsio
   Password: <strong-password>
   ```

2. **Use TLS for Web GUI** (optional):
   ```
   Settings → GUI → Use HTTPS for Web GUI
   ```

3. **Device authentication:**
   - Never accept unknown devices
   - Verify device IDs before adding

4. **Untrusted devices** (if needed):
   - Use "Untrusted" device type
   - Requires password for folder access
   - See Syncthing docs for encrypted folders

---

## Next Steps

✅ Syncthing configured and syncing between devices
⏭️ Proceed to [03-rclone-setup.md](03-rclone-setup.md) for Google Drive backup

---

**References:**
- [Syncthing Official Docs](https://docs.syncthing.net/)
- [Syncthing GitHub](https://github.com/syncthing/syncthing)
- [Syncthing Android](https://github.com/syncthing/syncthing-android)

---

**Last Updated:** 2025-11-18
**Version:** 1.0
**Author:** Mitsio
