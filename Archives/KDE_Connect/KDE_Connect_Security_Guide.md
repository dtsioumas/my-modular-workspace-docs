# KDE Connect Security Configuration Guide
**Date:** November 3, 2025  
**Project:** Desktop Workspace - KDE Connect Secure Setup

---

## 📋 DECLARATIVE NIXOS CONFIGURATION

### 1. Update Your Host Configuration

Edit `/home/mitso/.config/nixos/hosts/shoshin/configuration.nix` and add these imports:

```nix
{
  imports = [
    # ... existing imports ...
    
    # Security & Firewall (ADD THESE)
    ../../modules/system/firewall.nix        # Firewall with KDE Connect rules
    ../../modules/workspace/kdeconnect-secure.nix  # Secure KDE Connect config
    
    # REMOVE or COMMENT OUT the old plasma.nix if it has KDE Connect
    # ../../modules/workspace/plasma.nix  # Comment this if using kdeconnect-secure
  ];
}
```

### 2. Remove KDE Connect from plasma.nix

Edit `/home/mitso/.config/nixos/modules/workspace/plasma.nix` and REMOVE any KDE Connect configuration (it's now in dedicated modules).

### 3. Apply Configuration

```bash
cd ~/.config/nixos

# Test first (temporary)
sudo nixos-rebuild test --flake .#shoshin

# If working, make permanent
sudo nixos-rebuild switch --flake .#shoshin

# Verify firewall is enabled
sudo iptables -L -n | grep -E "171[4-9]|1716"
```

---

## 🔒 SECURITY MEASURES IMPLEMENTED

### NixOS Desktop Security

1. **Firewall Rules:**
   - ✅ Explicit firewall enablement
   - ✅ KDE Connect restricted to local subnet (192.168.1.0/24)
   - ✅ Rate limiting (max 10 connections/minute)
   - ✅ Logging of refused connections

2. **Service Hardening:**
   - ✅ Systemd service isolation
   - ✅ Read-only home directory (except specific paths)
   - ✅ No privilege escalation
   - ✅ Private /tmp directory

3. **Plugin Restrictions:**
   - ❌ Remote input (mousepad) - DISABLED
   - ❌ Remote commands (runcommand) - DISABLED
   - ❌ Remote desktop - DISABLED
   - ❌ System volume control - DISABLED
   - ✅ Safe plugins only (ping, share, notifications)

4. **Network Security:**
   - ✅ Avahi restricted to local network
   - ✅ No IPv6 (if not needed)
   - ✅ No mDNS reflection between networks

---

## 📱 ANDROID (XIAOMI POCO X6) SECURITY SETTINGS

### Essential Security Configuration

1. **KDE Connect App Settings:**
```
KDE Connect App → Settings (⚙️) → Configure:

☑️ Require pairing request
☑️ End-to-end encryption
☐ Allow from non-paired devices (UNCHECKED)
☑️ Show notification when connected

Plugin Settings → Disable:
☐ Remote input
☐ Run commands  
☐ Remote desktop
☐ Presentation remote
```

2. **MIUI Permission Restrictions:**
```
Settings → Apps → Manage Apps → KDE Connect:

Permissions:
✅ Files and media → Media only (not all files)
✅ Notifications → Allowed
⚠️ Location → Only while using app
❌ Camera → Denied
❌ Microphone → Denied
✅ Contacts → Ask every time
❌ Phone → Denied (unless needed for telephony)

Other permissions:
❌ Display over other apps → Denied
❌ Modify system settings → Denied
✅ Background activity → Allowed (required)
```

3. **Network Security:**
```
Settings → Wi-Fi → (Your Network) → Privacy:
☑️ Use randomized MAC
☑️ Encrypted DNS

Settings → Privacy Protection:
→ Special Permissions → KDE Connect:
  ❌ Device admin apps → Not allowed
  ❌ Install unknown apps → Not allowed
```

---

## 🔐 PAIRING SECURITY CHECKLIST

### Before Pairing:
- [ ] Verify both devices are on trusted network
- [ ] Check no unknown devices in KDE Connect list
- [ ] Ensure encryption is enabled (check in logs)

### During Pairing:
- [ ] Verify device fingerprint on both screens
- [ ] Confirm pairing within 30 seconds
- [ ] Set custom device name (not default)

### After Pairing:
- [ ] Test with safe plugin (ping)
- [ ] Review enabled plugins
- [ ] Set download folder restrictions

---

## 🛡️ OPERATIONAL SECURITY RULES

### DO:
✅ Only pair on private networks  
✅ Unpair devices when not in use  
✅ Regularly review paired devices  
✅ Use strong WiFi password (WPA3)  
✅ Keep KDE Connect updated  
✅ Monitor connection logs  

### DON'T:
❌ Pair on public WiFi  
❌ Enable remote input/commands  
❌ Share sensitive files  
❌ Leave Bluetooth enabled (not needed)  
❌ Accept pairing from unknown devices  
❌ Use guest network for KDE Connect  

---

## 🔍 SECURITY MONITORING

### Check Active Connections:
```bash
# See active KDE Connect connections
sudo ss -tuln | grep -E "171[4-9]|1716"

# Monitor in real-time
watch -n 1 'sudo ss -tun | grep -E "171[4-9]"'

# Check connection logs
journalctl -u kdeconnect --since "10 minutes ago"

# See firewall drops
sudo journalctl -t kernel | grep -i drop | tail -20
```

### Audit Paired Devices:
```bash
# List all paired devices
kdeconnect-cli --list-devices

# Show device details
kdeconnect-cli --device [DEVICE_ID] --show

# Unpair suspicious device
kdeconnect-cli --device [DEVICE_ID] --unpair
```

---

## 🚨 INCIDENT RESPONSE

### If Suspicious Activity Detected:

1. **Immediate Actions:**
```bash
# Stop KDE Connect
killall kdeconnectd

# Block all KDE Connect ports
sudo iptables -I INPUT -p tcp --dport 1714:1764 -j DROP
sudo iptables -I INPUT -p udp --dport 1716 -j DROP

# Unpair all devices
rm -rf ~/.config/kdeconnect/
```

2. **Investigation:**
```bash
# Check recent connections
journalctl -u kdeconnect --since "1 hour ago" | grep -i "connect\|pair\|error"

# Look for unauthorized access
sudo ausearch -m avc -ts recent | grep kdeconnect
```

3. **Recovery:**
- Change WiFi password
- Rebuild with fresh configuration
- Re-pair only trusted devices

---

## 📝 CONFIGURATION VALIDATION

After applying configuration, verify:

```bash
# 1. Firewall is active
sudo systemctl status nftables

# 2. Rules are applied
sudo iptables -S | grep -E "1714|1716"

# 3. Service is hardened
systemctl --user status kdeconnect

# 4. Avahi is restricted
systemctl status avahi-daemon

# 5. Only local subnet allowed
sudo iptables -L -n -v | grep "192.168.1.0/24"
```

---

## 🔄 MAINTENANCE SCHEDULE

### Weekly:
- Review paired devices
- Check connection logs
- Verify plugin settings

### Monthly:
- Audit firewall rules
- Update KDE Connect
- Review security settings

### After Updates:
- Re-verify all security settings
- Test pairing process
- Check for new plugins

---

## 📚 REFERENCES

- [KDE Connect Security](https://userbase.kde.org/KDEConnect#Security)
- [NixOS Security](https://nixos.org/manual/nixos/stable/#sec-security)
- [Firewall Best Practices](https://wiki.nixos.org/wiki/Firewall)

---

## ⚡ QUICK COMMANDS

```bash
# Safe restart
systemctl --user restart kdeconnect

# Emergency stop
killall -9 kdeconnectd

# View security status
kdeconnect-cli --list-devices --name-only

# Test connection (safe)
kdeconnect-cli --device [ID] --ping
```