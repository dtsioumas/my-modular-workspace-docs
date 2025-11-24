# KDE Connect Quick-Start Troubleshooting Guide

## 🚀 IMMEDIATE ACTIONS TO FIX DISCOVERY ISSUES

### Step 1: Run the Debug Script
```bash
# Make the script executable first
chmod +x /home/mitso/GoogleDrive/Workspaces/Personal_Workspace/desktop-workspace/KDE_Connect/debug-kdeconnect.sh

# Run the debugging script
./debug-kdeconnect.sh
```

### Step 2: Most Common Fix - Firewall Configuration

Since you're on NixOS, verify your `/etc/nixos/configuration.nix`:


### Step 3: Quick Android (Xiaomi POCO X6) Checklist

1. **Force Stop and Restart KDE Connect:**
   - Settings → Apps → KDE Connect → Force Stop
   - Open KDE Connect again

2. **Critical MIUI Setting:**
   - Settings → Connection & sharing → Reset Wi-Fi, mobile & Bluetooth
   - (Don't worry, just resets connection settings, not your WiFi passwords)

3. **Lock the App:**
   - Open KDE Connect
   - Press Recent Apps button
   - Find KDE Connect card
   - Pull down/long press → Lock icon

### Step 4: Manual IP Connection (Quick Workaround)

**On Desktop:**
1. Find Android IP: Settings → About Phone → Status → IP Address
2. In KDE Connect Settings → Add devices by IP
3. Enter: `[ANDROID_IP]:1716`

**On Android:**
1. Find Desktop IP: Run `ip addr` on desktop
2. KDE Connect app → Menu (3 dots) → Add devices by IP  
3. Enter desktop IP

### Step 5: Router Quick Check

Login to your router (usually 192.168.1.1 or 192.168.0.1):

1. **Find and DISABLE:**
   - AP Isolation / Client Isolation
   - Guest Mode (if devices on guest network)
   
2. **Find and ENABLE:**
   - Multicast
   - IGMP Snooping (sometimes)
   - UPnP (optional but helps)

### Step 6: Nuclear Option - Complete Reset

If nothing works:

```bash
# On Desktop
killall kdeconnectd
rm -rf ~/.config/kdeconnect  # Removes all pairings
kdeconnectd &

# On Android
# Uninstall and reinstall KDE Connect from Play Store
```

## 🔍 How to Verify It's Working

1. **Both devices should show in "Available Devices" within 5-10 seconds**
2. **Click "Request Pairing" on one device**
3. **Accept on the other device**
4. **Test: Send a ping from one device to another**

## ⚡ Quick Test Commands

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

## 🆘 Still Not Working?

The issue is likely one of these:

1. **Network Isolation** - Your router is preventing device communication
2. **Different Subnets** - Devices on different network segments  
3. **VPN Active** - VPN might be interfering
4. **Firewall** - Either on NixOS or router level
5. **MIUI Power Saving** - Xiaomi aggressively kills background apps

## 📱 Chrome Integration (After KDE Connect Works)

Once devices are paired:

1. **Install Extension:**
   - [Chrome Web Store - Plasma Integration](https://chrome.google.com/webstore/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai)

2. **Test Features:**
   - Play YouTube video → Check media controls in system tray
   - Right-click any link → "Send via KDE Connect"

## 🎯 Success Checklist

- [ ] Devices visible to each other
- [ ] Pairing successful  
- [ ] Can send files both ways
- [ ] Clipboard sync works
- [ ] Notifications appear
- [ ] Chrome "Send via KDE Connect" works

## References

- [KDE Connect Security](https://userbase.kde.org/KDEConnect#Security)
- [NixOS Security](https://nixos.org/manual/nixos/stable/#sec-security)
- [Firewall Best Practices](https://wiki.nixos.org/wiki/Firewall)

---

**Remember:** The most common issue is firewall/network isolation. If devices can ping each other but KDE Connect doesn't work, it's 99% a firewall issue!
