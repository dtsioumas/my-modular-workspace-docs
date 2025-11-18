# KDE Connect Configuration & Troubleshooting TODO
**Date:** November 3, 2025
**Project:** other-projects-desktop-workspace-Configuring_KDE_Connect_Do_week-45-2025
**Goal:** Configure KDE Connect between shoshin desktop and Xiaomi POCO X6, integrate with Chrome Plasma Integration

## 🔥 Critical Issue: Devices Cannot Discover Each Other on Same Network

## ✅ Completed Tasks
- [x] Read existing documentation files
- [x] Gather KDE Connect technical documentation
- [x] Research common network discovery issues

## 📋 TODO: Network Discovery Troubleshooting

### 1. Firewall Configuration Check
- [ ] **1.1 Check NixOS firewall configuration**
  ```bash
  sudo nix-shell -p nmap --run "nmap -p 1714-1764 localhost"
  ```
  
- [ ] **1.2 Verify KDE Connect ports are open**
  - TCP ports: 1714-1764 (required)
  - UDP port: 1716 (for discovery broadcasts)
  
- [ ] **1.3 Test firewall rules**
  ```bash
  # Check if firewall is enabled
  sudo firewall-cmd --state
  
  # Check if KDE Connect service is allowed
  sudo firewall-cmd --list-services
  
  # If using nftables
  sudo nft list ruleset | grep -E "1714|1764|1716"
  ```

### 2. Network Connectivity Tests
- [ ] **2.1 Get device IP addresses**
  - Desktop: `ip addr show | grep inet`
  - Android: Settings → About Phone → Status → IP Address
  
- [ ] **2.2 Test basic connectivity**
  ```bash
  # From desktop, try to ping phone (if ICMP allowed)
  ping [PHONE_IP]
  
  # Test KDE Connect port specifically
  curl [PHONE_IP]:1716
  # Expected: "curl: (52) Empty reply from server" = GOOD
  # Any other error = network issue
  ```
  
- [ ] **2.3 Check if both devices are on same subnet**
  - Ensure both IPs are in same range (e.g., 192.168.1.x)
  - Check subnet mask matches

### 3. Router/Network Configuration
- [ ] **3.1 Check for AP/Client Isolation**
  - Login to router admin panel
  - Look for: "AP Isolation", "Client Isolation", "Guest Mode"
  - MUST be disabled for KDE Connect
  
- [ ] **3.2 Check for VLAN separation**
  - Ensure devices aren't on different VLANs
  
- [ ] **3.3 Enable Multicast/Broadcast**
  - Some routers disable multicast by default
  - Look for "IGMP Snooping" or "Multicast" settings

### 4. KDE Connect Service Status
- [ ] **4.1 Check KDE Connect daemon**
  ```bash
  # Check if kdeconnectd is running
  ps aux | grep kdeconnect
  
  # Restart KDE Connect
  killall kdeconnectd
  kdeconnectd &
  ```
  
- [ ] **4.2 Check for error messages**
  ```bash
  # View KDE Connect logs
  journalctl -xe | grep kdeconnect
  ```

### 5. Manual Device Addition (Workaround)
- [ ] **5.1 Add device by IP address**
  - Open KDE Connect settings
  - Click "Add devices by IP"
  - Enter phone IP address and port 1716
  
- [ ] **5.2 Try from phone side too**
  - In Android KDE Connect app
  - Menu → Add devices by IP
  - Enter desktop IP

### 6. Android (MIUI) Specific Checks
- [ ] **6.1 Verify MIUI settings** (Already documented)
  - Battery optimization: Disabled ✓
  - Autostart: Enabled ✓
  - Background activity: Allowed ✓
  
- [ ] **6.2 Check Android firewall**
  - Some MIUI versions have built-in firewall
  - Security app → Manage apps → KDE Connect → Allow network

### 7. Alternative Discovery Methods
- [ ] **7.1 Try Bluetooth pairing first**
  - Enable Bluetooth on both devices
  - Pair via Bluetooth, then switch to WiFi
  
- [ ] **7.2 Use mDNS discovery**
  ```bash
  # Install avahi if not present
  avahi-browse -a | grep kdeconnect
  ```

### 8. Chrome Plasma Integration Setup
- [ ] **8.1 Install browser extension**
  - Chrome Web Store: Plasma Integration extension
  - Extension ID: cimiefiiaegbelhefglklhhakcgmhkai
  
- [ ] **8.2 Verify native messaging host**
  ```bash
  ls -la ~/.config/google-chrome/NativeMessagingHosts/org.kde.plasma.browser_integration.json
  ```
  
- [ ] **8.3 Test features**
  - Media controls with YouTube
  - Right-click → Send via KDE Connect
  - Download notifications

## 🔧 Advanced Troubleshooting

### A. Network Packet Analysis
- [ ] **A.1 Monitor UDP broadcasts**
  ```bash
  sudo tcpdump -i any -n port 1716
  # Should see UDP packets when KDE Connect searches
  ```

### B. SELinux/AppArmor (if applicable)
- [ ] **B.1 Check security contexts**
  ```bash
  # For SELinux
  sestatus
  
  # Check for denials
  sudo ausearch -m avc -ts recent | grep kdeconnect
  ```

### C. DNS/mDNS Issues
- [ ] **C.1 Check hostname resolution**
  ```bash
  # Can devices resolve each other's hostnames?
  nslookup [phone-hostname]
  avahi-resolve -n [phone-hostname].local
  ```

## 📝 Configuration Files to Create/Update

### 1. NixOS Configuration Update
- [ ] Verify `/etc/nixos/configuration.nix` includes all settings from `kde-connect-nixos-config.txt`

### 2. Create debugging script
- [ ] Create `/home/mitso/GoogleDrive/Workspaces/Personal_Workspace/desktop-workspace/KDE_Connect/debug-kdeconnect.sh`

## 🎯 Success Criteria
- [ ] Desktop and phone see each other in available devices
- [ ] Successful pairing and connection
- [ ] File sharing works both ways
- [ ] Clipboard sync functional
- [ ] Chrome integration working (media controls, send links)
- [ ] Notification mirroring active

## 📚 Resources & References
- KDE Connect Ports: TCP 1714-1764, UDP 1716
- [KDE Connect Documentation](https://kdeconnect.kde.org)
- [Arch Wiki - KDE Connect](https://wiki.archlinux.org/title/KDE_Connect)
- Chrome Extension: [Plasma Integration](https://chrome.google.com/webstore/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai)

## 🚨 Common Issues & Solutions
1. **"No devices found"** → Firewall/router isolation
2. **"Connection refused"** → Port blocked
3. **"Paired but not connected"** → Background app killed (Android)
4. **"Can't send files"** → File permissions or firewall

## Next Steps After Basic Connection
1. Configure persistent connection
2. Set up automated file sync locations  
3. Configure notification filtering
4. Set up remote control features
5. Test all Chrome integration features