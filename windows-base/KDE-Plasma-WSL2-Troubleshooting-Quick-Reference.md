# KDE Plasma on WSL2 - Quick Troubleshooting Reference
**For XRDP Method**  
**Last Updated:** November 18, 2025

---

## Quick Diagnosis Commands

```bash
# Check all services at once
systemctl status dbus xrdp xrdp-sesman | grep "Active:"

# Check listening ports
sudo netstat -tlnp | grep -E ":(3389|22)"

# Check logs for errors
sudo tail -30 /var/log/xrdp-sesman.log | grep -i error

# Check KDE processes
ps aux | grep -E "(plasma|kwin)" | grep -v grep
```

---

## Common Problems & Fast Fixes

### ⚫ Black Screen After Login

**Quick Fix #1:**
```bash
# Recreate .xsession
echo "/usr/bin/startplasma-x11" > ~/.xsession
chmod +x ~/.xsession
```

**Quick Fix #2:**
```bash
# Restart services
sudo systemctl restart xrdp xrdp-sesman
```

**Quick Fix #3:**
```bash
# Check D-Bus
sudo systemctl status dbus
# If not running:
sudo systemctl start dbus
```

---

### 🔄 Login Loops (Returns to Login Screen)

**Quick Fix #1 - Wait:**
- Services may still be starting
- Wait 30 seconds
- Try again

**Quick Fix #2 - Service Restart:**
```bash
sudo systemctl stop xrdp xrdp-sesman
sleep 5
sudo systemctl start xrdp xrdp-sesman
```

**Quick Fix #3 - Check startwm.sh:**
```bash
# Verify content
tail -5 /etc/xrdp/startwm.sh

# Should end with:
# if [ -f ~/.xsession ]; then
#     . ~/.xsession
# else
#     /usr/bin/startplasma-x11
# fi
```

---

### 🔇 No Audio

**Quick Fix #1:**
```bash
# Restart PulseAudio
systemctl --user restart pulseaudio
```

**Quick Fix #2:**
```bash
# Check XRDP modules
pactl list modules | grep xrdp

# If empty, reinstall xrdp-pulseaudio:
cd /tmp
git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
cd pulseaudio-module-xrdp
./bootstrap && ./configure && make && sudo make install
```

**Quick Fix #3:**
```bash
# Test locally first
speaker-test -c 2 -t wav
```

---

### 🐌 Slow/Laggy Performance

**Quick Fix #1 - Disable Effects:**
```bash
# System Settings → Desktop Effects
# Uncheck "Enable desktop effects"
```

**Quick Fix #2 - Increase Memory:**
```ini
# Edit C:\Users\dioklint.ATH\.wslconfig
[wsl2]
memory=12GB
processors=6
```
Then: `wsl --shutdown` and restart

**Quick Fix #3 - Optimize XRDP:**
```bash
# Verify in /etc/xrdp/xrdp.ini:
sudo grep -E "(max_bpp|xserverbpp|new_cursors)" /etc/xrdp/xrdp.ini

# Should show:
# max_bpp=128
# xserverbpp=128  
# new_cursors=false
```

---

### 🔌 Can't Connect to localhost:3389

**Quick Fix #1:**
```bash
# Check XRDP is listening
sudo netstat -tlnp | grep 3389

# Should show xrdp listening on 0.0.0.0:3389
# If not:
sudo systemctl restart xrdp
```

**Quick Fix #2:**
```bash
# Check port not in use
sudo lsof -i :3389

# If something else using port, change XRDP port:
sudo nano /etc/xrdp/xrdp.ini
# Change: port=3389 to port=3390
# Then: sudo systemctl restart xrdp
```

**Quick Fix #3:**
```powershell
# Check WSL network
wsl hostname -I

# Should return WSL IP
# Try connecting to that IP instead: 172.X.X.X:3389
```

---

### 📁 Can't Access Windows Files

**Quick Fix #1:**
```bash
# Check mounts
ls /mnt/c/

# If empty:
sudo mount -t drvfs C: /mnt/c/
```

**Quick Fix #2:**
```bash
# Restart WSL from Windows
# PowerShell:
wsl --shutdown
wsl -d Ubuntu
```

**Quick Fix #3:**
```bash
# Check wsl.conf
cat /etc/wsl.conf

# Should contain:
# [automount]
# enabled = true
```

---

### ⚙️ Services Don't Auto-Start

**Quick Fix:**
```bash
# Enable all services
sudo systemctl enable dbus
sudo systemctl enable xrdp
sudo systemctl enable xrdp-sesman

# Verify
systemctl list-unit-files | grep enabled | grep -E '(dbus|xrdp)'
```

---

### 📋 Clipboard Not Working

**Diagnosis:**
```bash
# Check xrdp-chansrv process
ps aux | grep xrdp-chansrv
```

**Quick Fix:**
```bash
# Restart XRDP
sudo systemctl restart xrdp xrdp-sesman

# Disconnect and reconnect RDP session
```

---

### 🖥️ Display Scaling Issues

**For HiDPI:**
```bash
# KDE Settings
# System Settings → Display and Monitor → Global Scale
# Set to: 125%, 150%, or 200%
```

**Note:** This is separate from Windows DPI scaling

---

### 🔑 KDE Wallet Prompts

**Quick Fix - Disable:**
```bash
# System Settings → KDE Wallet
# Uncheck "Enable the KDE wallet subsystem"
```

**Or create GPG key:**
```bash
gpg --gen-key
# Follow prompts
```

---

## Emergency Procedures

### Nuclear Option #1: Reset XRDP

```bash
sudo apt purge xrdp -y
sudo apt autoremove -y
sudo apt install xrdp -y

# Reconfigure (Phase 4)
echo "/usr/bin/startplasma-x11" > ~/.xsession
chmod +x ~/.xsession

sudo systemctl enable xrdp
sudo systemctl start xrdp
```

---

### Nuclear Option #2: Reset KDE Config

```bash
# Backup first
mv ~/.config ~/.config.backup
mv ~/.local ~/.local.backup
mv ~/.cache ~/.cache.backup

# Logout and login again
# KDE will recreate defaults
```

---

### Nuclear Option #3: Fresh WSL Install

```powershell
# Backup data first!
wsl --export Ubuntu C:\WSL-Backups\Ubuntu-Emergency-Backup.tar

# Unregister
wsl --unregister Ubuntu

# Reinstall
wsl --install -d Ubuntu-24.04

# Restore data:
# Copy needed files from extracted backup
```

---

## Log Files to Check

```bash
# XRDP main log
sudo tail -f /var/log/xrdp.log

# XRDP session manager
sudo tail -f /var/log/xrdp-sesman.log

# Systemd journal for XRDP
journalctl -u xrdp -f

# KDE session errors
cat ~/.xsession-errors

# X server errors
cat ~/.local/share/xorg/Xorg.0.log
```

---

## Health Check Script

Create this script for quick diagnostics:

```bash
nano ~/kde-health-check.sh
```

```bash
#!/bin/bash
echo "=== KDE Plasma WSL2 Health Check ==="
echo ""

echo "1. Services Status:"
systemctl is-active dbus && echo "  ✅ D-Bus: Running" || echo "  ❌ D-Bus: Not running"
systemctl is-active xrdp && echo "  ✅ XRDP: Running" || echo "  ❌ XRDP: Not running"
systemctl is-active xrdp-sesman && echo "  ✅ XRDP-Sesman: Running" || echo "  ❌ XRDP-Sesman: Not running"
echo ""

echo "2. Listening Ports:"
sudo netstat -tlnp | grep ":3389" && echo "  ✅ XRDP listening on 3389" || echo "  ❌ XRDP not listening"
echo ""

echo "3. KDE Processes:"
pgrep -x plasma && echo "  ✅ Plasma running" || echo "  ⚠️  Plasma not running (may be normal if not in RDP session)"
echo ""

echo "4. Last XRDP Errors:"
sudo tail -5 /var/log/xrdp-sesman.log | grep -i error || echo "  ✅ No recent errors"
echo ""

echo "5. Disk Space:"
df -h / | tail -1 | awk '{print "  Used: "$3" / "$2" ("$5")"}'
echo ""

echo "6. Memory Usage:"
free -h | grep "Mem:" | awk '{print "  Used: "$3" / "$2}'
echo ""

echo "=== Health Check Complete ==="
```

Make executable:
```bash
chmod +x ~/kde-health-check.sh
```

Run it:
```bash
~/kde-health-check.sh
```

---

## Quick Reference: Restart Everything

```bash
#!/bin/bash
# Complete restart procedure

echo "Stopping services..."
sudo systemctl stop xrdp xrdp-sesman

echo "Killing any remaining KDE processes..."
pkill -u $USER plasma
pkill -u $USER kwin

echo "Waiting..."
sleep 5

echo "Starting services..."
sudo systemctl start dbus
sudo systemctl start xrdp
sudo systemctl start xrdp-sesman

echo "Ready! Wait 10 seconds before connecting via RDP."
```

---

## Performance Monitoring

```bash
# Real-time resource usage
htop

# Disk I/O
sudo iotop

# Network
sudo nethogs

# Memory
watch -n 1 free -h

# Services
watch -n 1 'systemctl status xrdp | grep Active'
```

---

## When to Restore from Backup

If you experience:
- ❌ Repeated crashes
- ❌ Corruption of KDE config files
- ❌ Broken system after bad update
- ❌ Can't login after multiple troubleshooting attempts

**Restore procedure:**
```powershell
# Windows PowerShell
wsl --shutdown
wsl --unregister Ubuntu
wsl --import Ubuntu C:\WSL\Ubuntu C:\WSL-Backups\Ubuntu-KDE-WORKING-DATE.tar
```

---

## Contact Points

**Official Documentation:**
- [WSL Issues](https://github.com/microsoft/WSL/issues)
- [XRDP GitHub](https://github.com/neutrinolabs/xrdp)
- [KDE Forums](https://forum.kde.org/)

**Community:**
- Reddit: r/bashonubuntuonwindows
- Reddit: r/wsl
- Reddit: r/kde

---

## Prevention is Better than Cure

**Regular maintenance:**
```bash
# Weekly
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Monthly
# Create backup
wsl --export Ubuntu C:\WSL-Backups\Ubuntu-Monthly-$(date +%Y-%m).tar

# Clean logs
sudo journalctl --vacuum-time=7d
```

---

**Remember:** Most issues can be solved by:
1. Restarting services
2. Checking logs
3. Verifying configuration files
4. Restarting WSL

Keep calm and check the logs! 🐧

---

**Document Version:** 1.0  
**Last Updated:** November 18, 2025
