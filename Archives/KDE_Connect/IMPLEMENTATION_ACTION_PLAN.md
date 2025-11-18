# 🚀 ACTION PLAN: Apply Secure KDE Connect Configuration

## ✅ Current Status
- Firewall issue identified: Must be explicitly enabled
- Configuration files created and ready
- Security measures documented

---

## 📋 STEP-BY-STEP IMPLEMENTATION

### Step 1: Backup Current Configuration
```bash
cd ~/.config/nixos
git status
git add .
git commit -m "backup: Before KDE Connect security configuration"
```

### Step 2: Update Host Configuration
Edit `/home/mitso/.config/nixos/hosts/shoshin/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    # Hardware config
    ./hardware-configuration.nix
    
    # Common system tools
    ../../modules/common.nix
    ../../modules/common/security.nix
    
    # System
    ../../modules/system/audio.nix
    ../../modules/system/wireplumber-config.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/logging.nix
    ../../modules/system/stress-testing.nix
    ../../modules/system/firewall.nix  # ← ADD THIS (New firewall module)
    
    # Workspace
    ../../modules/workspace/plasma.nix  # ← Keep but remove KDE Connect from it
    ../../modules/workspace/kdeconnect-secure.nix  # ← ADD THIS (Secure KDE Connect)
    ../../modules/workspace/packages.nix
    ../../modules/workspace/firefox.nix
    ../../modules/workspace/brave-fixes.nix
    ../../modules/workspace/sound-tools-menu.nix
    ../../modules/workspace/themes.nix
    ../../modules/workspace/power.nix
    ../../modules/workspace/rclone.nix
 
    # ... rest of imports ...
  ];
  
  # ... rest of configuration ...
}
```

### Step 3: Clean Up plasma.nix
```bash
# Replace with clean version (no KDE Connect)
cp ~/.config/nixos/modules/workspace/plasma-clean.nix ~/.config/nixos/modules/workspace/plasma.nix
```

### Step 4: Test Configuration
```bash
cd ~/.config/nixos

# Syntax check
sudo nixos-rebuild dry-run --flake .#shoshin

# Build test
sudo nixos-rebuild build --flake .#shoshin

# Apply temporarily (safe)
sudo nixos-rebuild test --flake .#shoshin
```

### Step 5: Verify Security Features
```bash
# Check firewall is enabled and rules applied
sudo iptables -L -n | grep -E "171[4-9]|1716"

# Should see:
# - ACCEPT rules for ports 1714-1764 (TCP)
# - ACCEPT rule for port 1716 (UDP)
# - DROP rules for non-192.168.1.0/24 sources

# Check Avahi is running
systemctl status avahi-daemon

# Check KDE Connect
kdeconnectd &
sleep 3
kdeconnect-cli --list-available
```

### Step 6: Configure Android Device
On Xiaomi POCO X6:

1. **KDE Connect App:**
   - Settings → Require pairing ✓
   - Settings → Encryption ✓
   - Plugins → Disable: Remote input, Run commands, Remote desktop

2. **MIUI Settings:**
   - Apps → KDE Connect → Permissions → Restrict as per guide
   - Battery → No restrictions (keep it running)

### Step 7: Test Secure Pairing
```bash
# Desktop: Refresh and list devices
kdeconnect-cli --refresh
sleep 5
kdeconnect-cli --list-available

# Pair with Android (should work now!)
kdeconnect-cli --pair --device [DEVICE_ID]

# Verify pairing
kdeconnect-cli --list-devices
```

### Step 8: Make Configuration Permanent
```bash
# Only after testing!
sudo nixos-rebuild switch --flake .#shoshin
```

### Step 9: Commit Changes
```bash
cd ~/.config/nixos
git add .
git commit -m "feat: Add secure KDE Connect configuration

- Enable firewall with rate limiting
- Restrict KDE Connect to local subnet (192.168.1.0/24)  
- Disable dangerous plugins (remote input, commands)
- Add systemd hardening
- Configure Avahi with security restrictions
- Add fail2ban protection"

git push
```

---

## ✅ Verification Checklist

- [ ] Firewall enabled and rules visible in `iptables -L`
- [ ] KDE Connect daemon running without errors
- [ ] Devices can discover each other
- [ ] Pairing successful with encryption
- [ ] Only safe plugins enabled
- [ ] File transfers restricted to ~/Downloads/KDE_Connect/
- [ ] Connection logs show no errors
- [ ] Android permissions properly restricted

---

## 🔧 Troubleshooting

### If devices still can't connect:
```bash
# Check your actual subnet
ip route | grep default
# If not 192.168.1.x, update firewall.nix accordingly

# Temporarily allow all local networks (for testing)
sudo iptables -I INPUT -p tcp --dport 1714:1764 -s 192.168.0.0/16 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 1716 -s 192.168.0.0/16 -j ACCEPT
```

### If KDE Connect crashes:
```bash
# Run with debug output
QT_LOGGING_RULES="*=true" kdeconnectd 2>&1 | tee kdeconnect.log
```

---

## 📊 Success Criteria

You'll know it's working when:
1. `sudo iptables -L -n` shows KDE Connect rules
2. `kdeconnect-cli --list-available` shows your phone
3. Pairing completes with fingerprint verification
4. Ping test works: `kdeconnect-cli --ping --device [ID]`
5. Files transfer to ~/Downloads/KDE_Connect/ only

---

## 🎯 Next Actions

1. Apply the configuration (`test` first, then `switch`)
2. Configure Android security settings
3. Test pairing and basic functions
4. Document any customizations needed
5. Create backup of working configuration

Good luck! The configuration is now secure and ready to deploy!