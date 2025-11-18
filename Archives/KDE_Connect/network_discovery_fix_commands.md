# Network Discovery Fix Commands

## PRIORITY 1: Immediate Fix Attempts

### A. Restart KDE Connect Services
```bash
# Kill and restart the daemon
killall kdeconnectd
sleep 2
kdeconnectd &

# Alternative: using systemctl (if available)
systemctl --user restart kdeconnect
```

### B. Check and Fix UDP Broadcasting
```bash
# Test if UDP broadcasts are working
# Terminal 1: Listen for broadcasts
nc -lu 1716

# Terminal 2: Send test broadcast
echo "test" | nc -u -b 255.255.255.255 1716
```

### C. Direct Connection by IP (Most Reliable Workaround)
```bash
# Find your devices' IPs
# Desktop:
hostname -I | cut -d' ' -f1

# Or more detailed:
ip route get 1 | awk '{print $NF;exit}'
```

## PRIORITY 2: Network Configuration Checks

### A. Check Network Manager Settings
```bash
# Check if your network is set to "private/trusted"
nmcli connection show

# Make network trusted (replace "NetworkName" with your actual network)
nmcli connection modify "NetworkName" connection.zone trusted
nmcli connection up "NetworkName"
```

### B. Avahi/mDNS Configuration
```bash
# Install avahi if not present (helps with discovery)
# For NixOS, add to configuration.nix:
# services.avahi.enable = true;
# services.avahi.nssmdns = true;

# Check if avahi is running
systemctl status avahi-daemon

# Browse for KDE Connect devices
avahi-browse -a | grep kdeconnect
```

### C. Test Multicast/Broadcast
```bash
# Check if multicast is enabled on interface
ip link show | grep -i multicast

# Enable multicast if needed (replace eth0 with your interface)
sudo ip link set dev eth0 multicast on
```

## PRIORITY 3: Firewall Deep Dive

### A. Temporarily Disable Firewall (for testing only!)
```bash
# NixOS way - add to configuration.nix temporarily:
# networking.firewall.enable = false;

# Or use iptables directly for testing:
sudo iptables -F
sudo iptables -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT

# TEST KDE CONNECT NOW

# Then restore firewall:
sudo nixos-rebuild switch
```

### B. Add Specific Firewall Rules
```bash
# If using iptables directly:
sudo iptables -I INPUT -p tcp --dport 1714:1764 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 1716 -j ACCEPT
sudo iptables -I OUTPUT -p udp --dport 1716 -j ACCEPT

# For nftables:
sudo nft add rule inet filter input tcp dport 1714-1764 accept
sudo nft add rule inet filter input udp dport 1716 accept
```

### C. Check for Double NAT or CGNAT
```bash
# Check if you're behind double NAT
traceroute -m 2 8.8.8.8

# If first hop is 192.168.x.x and second is also private IP,
# you might have double NAT issue
```

## ANDROID-SPECIFIC FIXES

### A. ADB Commands (if USB debugging enabled)
```bash
# Connect phone via USB, enable USB debugging
adb devices

# Check KDE Connect status
adb shell dumpsys activity services | grep -i kdeconnect

# Force stop and restart
adb shell am force-stop org.kde.kdeconnect_tp
adb shell am start org.kde.kdeconnect_tp/.UserInterface.MainActivity

# Check if app can use network
adb shell dumpsys package org.kde.kdeconnect_tp | grep -i permission
```

### B. MIUI Specific Commands
```bash
# Via ADB - Disable MIUI optimizations for KDE Connect
adb shell cmd appops set org.kde.kdeconnect_tp RUN_IN_BACKGROUND allow
adb shell cmd device_config put activity_manager max_phantom_processes 2147483647
```

## VERIFICATION COMMANDS

### Test Sequence:
```bash
# 1. Check daemon is running
ps aux | grep kdeconnect

# 2. Check listening ports
ss -tuln | grep -E "171[4-9]|17[2-6][0-9]"

# 3. Monitor for discovery packets
sudo tcpdump -i any 'udp port 1716' -n

# 4. Check D-Bus interface
qdbus org.kde.kdeconnect

# 5. List detected devices (even if not paired)
qdbus org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices

# 6. Force refresh
qdbus org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.forceRefresh
```

## NUCLEAR OPTIONS

### Complete Reset
```bash
# Desktop - Full reset
rm -rf ~/.config/kdeconnect
rm -rf ~/.local/share/kdeconnect
killall kdeconnectd
kdeconnectd &

# Android - Via ADB
adb shell pm clear org.kde.kdeconnect_tp
```

### Alternative Ports
```bash
# If default ports blocked, try alternative range
# Add to configuration.nix:
# programs.kdeconnect.port = 1800; # Different port
```

## LOG ANALYSIS

### Check all relevant logs:
```bash
# System logs
journalctl -xe | grep -i kdeconnect | tail -50

# Network logs  
journalctl -u NetworkManager | tail -50

# Firewall logs
journalctl -t kernel | grep -E "DPT=171[4-9]|DPT=17[2-6][0-9]"

# D-Bus issues
journalctl --user -u dbus | grep -i kdeconnect
```

## STILL NOT WORKING?

Try GSConnect (GNOME alternative) or LocalSend as alternatives:
- LocalSend: Cross-platform, works on same network
- Syncthing: For file sync
- Barrier/Input-leap: For keyboard/mouse sharing only