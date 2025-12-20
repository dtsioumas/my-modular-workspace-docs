# KDE Connect Guide

**Last Updated:** 2025-11-29
**Sources Merged:** KDE_CONNECT_PLASMA_INTEGRATION_NOTE.md, QUICK_START_TROUBLESHOOTING.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Installation (NixOS)](#installation-nixos)
- [Quick Start Troubleshooting](#quick-start-troubleshooting)
- [Firewall Configuration](#firewall-configuration)
- [Android Setup (Xiaomi/MIUI)](#android-setup-xiaomimiui)
- [Chrome Integration](#chrome-integration)
- [References](#references)

---

## Overview

KDE Connect enables seamless communication between your phone and desktop:
- File sharing
- Clipboard sync
- Notification sync
- Media control
- Remote input
- SMS from desktop

---

## Installation (NixOS)

Add to `/etc/nixos/configuration.nix`:

```nix
# Enable KDE Connect
programs.kdeconnect.enable = true;

# Enable Plasma Browser Integration native host
programs.plasma-browser-integration.enable = true;

# Configure firewall for KDE Connect (ports 1714-1764)
networking.firewall = rec {
  allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  allowedUDPPortRanges = allowedTCPPortRanges;
};

# Optional: Ensure packages are installed
environment.systemPackages = with pkgs; [
  plasma-browser-integration
  kdeconnect
];
```

---

## Quick Start Troubleshooting

### Step 1: Most Common Fix - Firewall

```bash
# Verify firewall allows KDE Connect ports
sudo iptables -L | grep -E "171[4-9]|17[2-5][0-9]|176[0-4]"

# Check ports are listening
sudo netstat -tuln | grep -E "171[4-9]|17[2-5][0-9]|176[0-4]"
```

### Step 2: Manual IP Connection

**On Desktop:**
1. Find Android IP: Settings → About Phone → Status → IP Address
2. In KDE Connect Settings → Add devices by IP
3. Enter: `[ANDROID_IP]:1716`

**On Android:**
1. Find Desktop IP: Run `ip addr` on desktop
2. KDE Connect app → Menu (3 dots) → Add devices by IP
3. Enter desktop IP

### Step 3: Router Configuration

Login to your router and check:

**DISABLE:**
- AP Isolation / Client Isolation
- Guest Mode (if devices on guest network)

**ENABLE:**
- Multicast
- IGMP Snooping (sometimes)
- UPnP (optional but helps)

### Step 4: Nuclear Option - Complete Reset

```bash
# On Desktop
killall kdeconnectd
rm -rf ~/.config/kdeconnect  # Removes all pairings
kdeconnectd &

# On Android: Uninstall and reinstall KDE Connect
```

---

## Firewall Configuration

KDE Connect uses ports **1714-1764** for both TCP and UDP.

### NixOS (Declarative)

```nix
networking.firewall = rec {
  allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  allowedUDPPortRanges = allowedTCPPortRanges;
};
```

### Manual Verification

```bash
# Check if ports are open
sudo netstat -tuln | grep -E "171[4-9]|17[2-5][0-9]|176[0-4]"

# Watch for discovery packets
sudo tcpdump -i any -n port 1716
```

---

## Android Setup (Xiaomi/MIUI)

Xiaomi devices have aggressive battery optimization that kills KDE Connect.

### Critical Steps

1. **Force Stop and Restart:**
   - Settings → Apps → KDE Connect → Force Stop
   - Open KDE Connect again

2. **Lock the App:**
   - Open KDE Connect
   - Press Recent Apps button
   - Find KDE Connect card
   - Pull down/long press → Lock icon

3. **Disable Battery Optimization:**
   - Settings → Battery → KDE Connect
   - Set to "No restrictions"

4. **MIUI-Specific:**
   - Settings → Connection & sharing → Reset Wi-Fi, mobile & Bluetooth
   - (Just resets connection settings, not WiFi passwords)

---

## Chrome Integration

Once devices are paired:

1. **Install Extension:**
   - [Chrome Web Store - Plasma Integration](https://chrome.google.com/webstore/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai)

2. **Test Features:**
   - Play YouTube video → Check media controls in system tray
   - Right-click any link → "Send via KDE Connect"

---

## Quick Test Commands

```bash
# Is KDE Connect running?
pgrep -x kdeconnectd

# Can you reach your phone? (replace with actual IP)
curl 192.168.1.XXX:1716

# Are ports open?
sudo netstat -tuln | grep -E "171[4-9]|17[2-5][0-9]|176[0-4]"

# Watch for discovery packets
sudo tcpdump -i any -n port 1716
```

---

## Common Issues

| Issue | Likely Cause | Solution |
|-------|--------------|----------|
| Devices not visible | Firewall blocking | Check ports 1714-1764 |
| Devices not visible | Android network app | Disable VPN/antenna/network apps |
| Pairing fails | Different subnets | Both on same WiFi network |
| Android disconnects | Battery optimization | Lock app, disable battery save |
| VPN active | VPN interfering | Disable VPN or split tunnel |
| Guest WiFi | AP isolation | Move to main network |
| Discovery fails (Bug #511914) | mDNS disabled | Enable mDNS in Android app settings |

---

## Success Checklist

- [ ] Devices visible to each other
- [ ] Pairing successful
- [ ] Can send files both ways
- [ ] Clipboard sync works
- [ ] Notifications appear
- [ ] Chrome "Send via KDE Connect" works

---

## References

- [KDE Connect Security](https://userbase.kde.org/KDEConnect#Security)
- [NixOS Security](https://nixos.org/manual/nixos/stable/#sec-security)
- [Firewall Best Practices](https://wiki.nixos.org/wiki/Firewall)

---

*Migrated from docs/commons/toolbox/kde-connect/ on 2025-11-29*
