# Fedora Kinoite on WSL2 - Installation Guide

**Date**: 2025-12-17
**Target**: Fedora Kinoite 41+ with KDE Plasma
**Method**: Custom WSL2 import with OSTree rebase
**Difficulty**: Intermediate
**Time**: 1-2 hours

---

## Overview

This guide walks through installing **Fedora Kinoite** (immutable Fedora with KDE Plasma) on WSL2.

### Challenge

**Problem**: No official Fedora Kinoite WSL2 image exists.

**Solution**: Three approaches (we'll use #3 - the cleanest):

1. ❌ Extract from Kinoite ISO (complex, large download)
2. ❌ Export from container image (requires customization)
3. ✅ **Start with Fedora Server WSL2, rebase to Kinoite** (recommended)

---

## Prerequisites

### Windows Side

```powershell
# Check WSL version
wsl --version
# Need: WSL 2.0.0+ (ideally)

# Check Windows build
winver
# Need: Windows 10 build 19041+ or Windows 11

# Ensure WSL2 is installed
wsl --install --no-distribution

# Update WSL if needed
wsl --update
```

### System Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| **RAM** | 8GB total (4GB for WSL) | 16GB+ total (8-12GB for WSL) |
| **Storage** | 20GB free | 40GB+ free |
| **CPU** | 4 cores | 6+ cores |

### .wslconfig Configuration

```powershell
# Create/edit C:\Users\dioklint.ATH\.wslconfig
notepad $env:USERPROFILE\.wslconfig
```

**Add this content**:
```ini
[wsl2]
# Resource allocation
memory=12GB
processors=6
swap=4GB

# Performance
nestedVirtualization=false
vmIdleTimeout=60000

# Networking (critical for X410)
localhostForwarding=true
networkingMode=NAT

# Experimental (optional, for systemd)
[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
```

**Apply changes**:
```powershell
wsl --shutdown
# Wait 10 seconds, then proceed
```

---

## Installation Methods

### ✅ Method 1: Fedora Server → Kinoite Rebase (RECOMMENDED)

**This is the cleanest approach:**
1. Install Fedora Server from Microsoft Store or Fedora's WSL image
2. Rebase to Kinoite using rpm-ostree
3. Maintains official update path

#### Step 1: Install Base Fedora

**Option A: Microsoft Store** (easiest)
```powershell
# Search Microsoft Store for "Fedora"
# Install "Fedora WSL" or "Fedora Remix for WSL"

# Or via command:
wsl --install -d Fedora
```

**Option B: Manual Import** (if Store unavailable)
```powershell
# Download Fedora WSL rootfs
# Visit: https://github.com/fedora-cloud/docker-brew-fedora
# Or use Fedora's official WSL image

# Download rootfs tar.xz
# Example URL (check for latest):
# https://dl.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-41-*.tar.xz

# Extract if needed (to .tar.gz)
# Then import:
wsl --import FedoraKinoite C:\WSL\FedoraKinoite "C:\path\to\fedora-rootfs.tar.gz"

# Set as default
wsl --set-default FedoraKinoite
```

#### Step 2: Initial Fedora Setup

```bash
# Launch Fedora
wsl -d FedoraKinoite  # Or "Fedora" if from Store

# Create user (if needed, Store version prompts on first launch)
# If manual import, create user now:
useradd -m -G wheel dioklint
passwd dioklint

# Set as default user (from Windows PowerShell):
# fedora config --default-user dioklint  # If from Store
# Or edit /etc/wsl.conf:
```

```bash
# Inside WSL, edit wsl.conf
sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[boot]
systemd=true

[user]
default=dioklint

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
EOF

# Exit and restart
exit
```

```powershell
# From Windows
wsl --shutdown
wsl -d FedoraKinoite
```

#### Step 3: Update Base System

```bash
# Update Fedora Server
sudo dnf update -y

# Install essentials
sudo dnf install -y \
  git \
  vim \
  wget \
  curl \
  gnupg

# Reboot to apply updates
sudo systemctl reboot  # Actually just exits WSL

# Restart from Windows
# wsl -d FedoraKinoite
```

#### Step 4: Rebase to Kinoite

**This is the magic step!**

```bash
# Check current status
rpm-ostree status
# If this errors, Fedora Server might not be ostree-based
# That's OK, we'll install rpm-ostree

# Install rpm-ostree if needed (Fedora Server)
if ! command -v rpm-ostree &> /dev/null; then
    sudo dnf install -y rpm-ostree ostree
fi

# Rebase to Kinoite
sudo rpm-ostree rebase \
  fedora:fedora/41/x86_64/kinoite

# This will:
# - Download Kinoite OSTree commit (~2-3GB)
# - Prepare new deployment
# - Take 20-60 minutes depending on connection

# Output will show:
# Receiving objects: XX% (XXXX/XXXX)
# Writing objects: XX% (XXXX/XXXX)
# Applying XX metadata, XX content objects
# ...
# Run "systemctl reboot" to start a reboot
```

**Monitor progress**:
```bash
# In another terminal (if needed):
sudo rpm-ostree status
# Shows: "Transaction in progress"
```

#### Step 5: Reboot and Verify

```bash
# Reboot (exits WSL)
sudo systemctl reboot
```

```powershell
# From Windows, restart
wsl --shutdown
wsl -d FedoraKinoite
```

```bash
# Verify Kinoite
rpm-ostree status

# Output should show:
# State: idle
# Deployments:
# ● fedora:fedora/41/x86_64/kinoite
#     Version: 41.XXXXXXXX (timestamp)
#     ...

# Check KDE is installed
rpm -q plasma-workspace
# Should show: plasma-workspace-X.YY.Z...

# List KDE packages
rpm -qa | grep -i plasma | head -20
```

#### Step 6: Install KDE Plasma (if not included)

```bash
# Check if KDE is installed
which startplasma-x11

# If not found, install KDE desktop
sudo rpm-ostree install @kde-desktop-environment

# Or minimal KDE:
sudo rpm-ostree install \
  plasma-workspace \
  plasma-desktop \
  kde-cli-tools \
  dolphin \
  konsole \
  kate

# Reboot
sudo systemctl reboot
```

---

### ⚠️ Method 2: Container Image Export (Alternative)

**Use if Method 1 fails.**

```powershell
# Requires Podman Desktop or Docker Desktop on Windows

# Pull Kinoite container
podman pull quay.io/fedora-ostree-desktops/kinoite:41

# Export to rootfs
podman create --name kinoite-tmp quay.io/fedora-ostree-desktops/kinoite:41
podman export kinoite-tmp | gzip > fedora-kinoite-41.tar.gz
podman rm kinoite-tmp

# Import to WSL2
wsl --import FedoraKinoite C:\WSL\FedoraKinoite fedora-kinoite-41.tar.gz

# Launch and configure
wsl -d FedoraKinoite
```

**Note**: This method requires additional setup (user creation, systemd, etc.)

---

## Post-Installation Configuration

### Enable Systemd (Should Already Be Enabled)

```bash
# Verify systemd is running
systemctl --version

# Check wsl.conf
cat /etc/wsl.conf
```

**Should contain**:
```ini
[boot]
systemd=true
```

**If not**:
```bash
sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[boot]
systemd=true

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
EOF

# Exit and restart
exit
```

```powershell
wsl --shutdown
wsl -d FedoraKinoite
```

### Layer Essential System Packages

**Remember**: Minimize layered packages! Use toolbox for dev tools.

```bash
# System essentials only
sudo rpm-ostree install \
  vim \
  git \
  tmux \
  htop \
  ansible \
  rclone \
  keepassxc \
  xorg-x11-server-Xorg \
  xorg-x11-xauth \
  xorg-x11-apps

# Reboot to apply
sudo systemctl reboot
```

```powershell
# Restart from Windows
wsl --shutdown
wsl -d FedoraKinoite
```

### Configure KDE Plasma for X11

```bash
# Ensure X11 session is default (not Wayland)
# Create ~/.xsession or use startplasma-x11 directly

# Test X11 utilities
which startplasma-x11
# Should be: /usr/bin/startplasma-x11

# Create launch script
mkdir -p ~/bin
cat > ~/bin/launch-kde << 'EOF'
#!/bin/bash
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
startplasma-x11
EOF

chmod +x ~/bin/launch-kde
```

### Test KDE Plasma (With X410)

**Prerequisites**: X410 installed and running on Windows

```bash
# Set DISPLAY
export DISPLAY=:0

# Test X11 connection
xclock
# Should show a clock window in X410

# If that works, launch KDE Plasma
startplasma-x11

# KDE Plasma should appear in X410 window/desktop
```

**Troubleshooting**:
```bash
# Check DISPLAY
echo $DISPLAY
# Should be :0 or similar

# Check X410 is reachable
xdpyinfo | head
# Should show X server info

# Check for errors
journalctl -xe | grep -i plasma
```

### Configure Flathub (Optional, for GUI Apps)

```bash
# Add Flathub remote
flatpak remote-add --if-not-exists flathub \
  https://dl.flathub.org/repo/flathub.flatpakrepo

# Install example app
flatpak install flathub org.mozilla.firefox -y

# Run flatpak app
flatpak run org.mozilla.firefox
```

---

## Kinoite-Specific Configuration

### Understanding rpm-ostree

```bash
# Show current deployment
rpm-ostree status

# Output:
# State: idle
# Deployments:
# ● fedora:fedora/41/x86_64/kinoite
#     Version: 41.20250115.0 (2025-01-15T...)
#     BaseCommit: abc123...
#     LayeredPackages: vim git tmux htop ansible rclone keepassxc xorg-x11-server-Xorg...

# Upgrade to latest Kinoite
sudo rpm-ostree upgrade

# Rollback to previous deployment
sudo rpm-ostree rollback

# Remove layered package
sudo rpm-ostree uninstall vim

# Search for package (uses dnf database)
rpm-ostree search htop
```

### Best Practices

1. **Minimize Layered Packages**
   ```bash
   # ❌ Don't layer development tools
   # sudo rpm-ostree install python3 nodejs golang

   # ✅ Use toolbox instead
   toolbox create dev
   toolbox enter dev
   sudo dnf install python3 nodejs golang
   ```

2. **Use Flatpak for GUI Apps**
   ```bash
   # ✅ Install as flatpak
   flatpak install flathub org.gimp.GIMP
   flatpak install flathub org.libreoffice.LibreOffice
   ```

3. **Layer Only System Integrations**
   ```bash
   # ✅ OK to layer:
   # - System utilities (vim, git, tmux)
   # - X11 server components
   # - System services (rclone, keepassxc)
   # - Configuration tools (ansible)
   ```

### Create Development Toolbox

```bash
# Create Fedora 41 toolbox
toolbox create --distro fedora --release 41 dev-general

# Enter toolbox
toolbox enter dev-general

# Install dev tools (inside toolbox)
sudo dnf install -y \
  python3 \
  python3-pip \
  python3-poetry \
  golang \
  nodejs \
  npm \
  gcc \
  make \
  ansible-lint \
  yamllint

# Exit toolbox
exit

# Your base system stays clean!
```

### Ansible Integration

```bash
# Create Ansible inventory
mkdir -p ~/.ansible
cat > ~/.ansible/inventory.yml << 'EOF'
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: /usr/bin/python3

kinoite:
  hosts:
    localhost:
  vars:
    ansible_pkg_mgr: atomic_container  # Special for Kinoite
EOF

# Example playbook for Kinoite
cat > test-kinoite.yml << 'EOF'
---
- name: Configure Fedora Kinoite
  hosts: localhost
  become: true
  tasks:
    - name: Layer essential packages
      ansible.posix.rpm_ostree_pkg:
        name:
          - vim
          - git
          - tmux
        state: present

    - name: Install flatpaks
      community.general.flatpak:
        name: org.mozilla.firefox
        state: present
EOF

# Run playbook
ansible-playbook test-kinoite.yml
```

---

## Windows Integration

### Create Windows Launcher

```powershell
# C:\Users\dioklint.ATH\launch-kinoite-kde.bat
@echo off
title Launching Fedora Kinoite KDE Plasma
echo ============================================
echo Starting Fedora Kinoite KDE Plasma Desktop
echo ============================================
echo.

REM Start X410 if not running
tasklist /FI "IMAGENAME eq X410.exe" 2>NUL | find /I /N "X410.exe">NUL
if "%ERRORLEVEL%"=="1" (
    echo Starting X410...
    start "" "C:\Program Files\X410\X410.exe"
    timeout /t 3 /nobreak > nul
)

echo Launching KDE Plasma in WSL2...
wsl -d FedoraKinoite bash -c "export DISPLAY=:0; ~/bin/launch-kde"

echo.
echo ============================================
echo KDE Plasma launched
echo Check X410 window for desktop
echo ============================================
pause
```

### Add to Windows Startup (Optional)

```powershell
# Copy launcher to Startup folder
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
copy C:\Users\dioklint.ATH\launch-kinoite-kde.bat $startup\
```

---

## Backup and Export

### Export Kinoite Instance

```powershell
# Create backup directory
mkdir C:\WSL-Backups

# Export Kinoite
wsl --export FedoraKinoite C:\WSL-Backups\FedoraKinoite-$(Get-Date -Format 'yyyy-MM-dd').tar

# This creates a ~5-15GB tar file
# Store securely (external drive, cloud backup)
```

### Restore from Backup

```powershell
# Unregister current instance (deletes all data!)
wsl --unregister FedoraKinoite

# Import backup
wsl --import FedoraKinoite C:\WSL\FedoraKinoite C:\WSL-Backups\FedoraKinoite-2025-12-17.tar

# Set default user (edit /etc/wsl.conf inside WSL)
wsl -d FedoraKinoite
sudo tee -a /etc/wsl.conf > /dev/null << 'EOF'
[user]
default=dioklint
EOF
exit

# Restart
wsl --shutdown
wsl -d FedoraKinoite
```

---

## Troubleshooting

### Issue 1: rpm-ostree rebase fails

**Error**: `error: While pulling...`

**Solutions**:
```bash
# Check internet connection
ping -c 3 fedoraproject.org

# Try with --download-only first
sudo rpm-ostree rebase \
  --download-only \
  fedora:fedora/41/x86_64/kinoite

# If partial download, resume
sudo rpm-ostree rebase fedora:fedora/41/x86_64/kinoite
```

### Issue 2: KDE Plasma won't start

**Error**: `startplasma-x11: command not found`

**Solutions**:
```bash
# Check if KDE is installed
rpm -q plasma-workspace

# If not installed
sudo rpm-ostree install plasma-workspace plasma-desktop
sudo systemctl reboot

# Check X11 display
echo $DISPLAY  # Should be :0
xdpyinfo  # Should show X server info
```

### Issue 3: Permission denied errors

**Error**: Various permission errors in WSL

**Solutions**:
```bash
# Check /etc/wsl.conf automount options
cat /etc/wsl.conf

# Should have metadata option
sudo tee -a /etc/wsl.conf > /dev/null << 'EOF'
[automount]
options="metadata,umask=22,fmask=11"
EOF

# Restart WSL
exit
# wsl --shutdown
# wsl -d FedoraKinoite
```

### Issue 4: Systemd not working

**Error**: `systemctl: command not found` or `System has not been booted with systemd`

**Solutions**:
```bash
# Check if systemd is enabled
cat /etc/wsl.conf | grep systemd

# If missing, add it
sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[boot]
systemd=true
EOF

# MUST restart WSL from Windows
exit
```

```powershell
wsl --shutdown
# Wait 10 seconds
wsl -d FedoraKinoite
```

---

## Performance Tuning

### Optimize WSL2 Resources

```ini
# C:\Users\dioklint.ATH\.wslconfig
[wsl2]
# For KDE Plasma + 3 monitors
memory=12GB
processors=6
swap=4GB

# Performance
nestedVirtualization=false
vmIdleTimeout=120000  # Keep VM alive 2 minutes

# Page file
pageReporting=false  # Slight performance gain
```

### Optimize Kinoite

```bash
# Disable unnecessary services
sudo systemctl mask \
  bluetooth.service \
  ModemManager.service \
  wpa_supplicant.service

# Optimize journal
sudo tee /etc/systemd/journald.conf.d/size.conf > /dev/null << 'EOF'
[Journal]
SystemMaxUse=100M
RuntimeMaxUse=50M
EOF

sudo systemctl restart systemd-journald
```

---

## Next Steps

After successful Kinoite installation:

1. ✅ Verify KDE Plasma launches via X410
2. ⬜ Configure multi-monitor setup
3. ⬜ Install development tools (via toolbox)
4. ⬜ Apply Ansible configurations
5. ⬜ Set up chezmoi dotfiles
6. ⬜ Configure KeePassXC secrets
7. ⬜ Set up rclone sync

**Continue to**: [BOOTSTRAP-GUIDE.md](BOOTSTRAP-GUIDE.md) for full automation

---

**Document Version**: 1.0
**Last Updated**: 2025-12-17
**Tested On**: Windows 10 Pro (build 26100), Fedora Kinoite 41
