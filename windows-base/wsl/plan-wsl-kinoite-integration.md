# Comprehensive Plan: WSL2 Kinoite Integration with Windows 11

**Project**: my-modular-workspace - Windows Base Integration
**Date**: 2025-12-18
**Timeline**: 3-6 months (flexible, MVP-first approach)
**Status**: Planning Phase

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Project Goals & Context](#project-goals--context)
3. [Architecture Overview](#architecture-overview)
4. [Phase 1: Kinoite Base WSL2 Setup](#phase-1-kinoite-base-wsl2-setup)
5. [Phase 2: Home-Manager Integration](#phase-2-home-manager-integration)
6. [Phase 3: X410 + KDE Plasma + Multi-Monitor](#phase-3-x410--kde-plasma--multi-monitor)
7. [Phase 4: WSL2 Performance Optimization](#phase-4-wsl2-performance-optimization)
8. [Phase 5: Windows 11 as Launcher](#phase-5-windows-11-as-launcher)
9. [Phase 6: Chezmoi + Workspace Unification](#phase-6-chezmoi--workspace-unification)
10. [Phase 7: Advanced Optimizations](#phase-7-advanced-optimizations)
11. [Phase 8: Windows 11 Bootstrap Automation](#phase-8-windows-11-bootstrap-automation)
12. [Phase 9: CI/CD Pipeline with Windows 11 VM](#phase-9-cicd-pipeline-with-windows-11-vm)
13. [Technical Validation & Review](#technical-validation--review)
14. [Risk Assessment](#risk-assessment)
15. [Success Criteria](#success-criteria)
16. [Related Documentation](#related-documentation)

---

## Executive Summary

### Goal

Transform the eyeonix-laptop Windows 11 workspace into a **declarative, reproducible, immutable development environment** using:

- **Windows 11 Pro** (25H2) as minimal launcher
- **Fedora Kinoite** (immutable KDE) in WSL2 as primary environment
- **Nix + home-manager** for declarative package management
- **Chezmoi** for cross-platform dotfiles
- **X410** for graphical integration (KDE Plasma)
- **Ansible** for automation and bootstrapping
- **CI/CD** with Windows 11 VM for reproducibility testing

### Approach

**MVP-first, incremental phases** with validation at each step:
1. Get basic Kinoite working in WSL2
2. Integrate home-manager (test with basic packages)
3. Enable GUI (X410 + KDE Plasma + multi-monitor)
4. Optimize performance (WSL2, hardware-specific)
5. Decide Windows vs WSL boundaries
6. Unify workspace with chezmoi
7. Advanced optimizations (GPU, custom code if needed)
8. **Automate Windows 11 bootstrap** (fully declarative)
9. **Establish CI/CD pipeline** with VM testing

### Timeline

- **3-6 months** (flexible)
- **No rush** - focus on quality and reproducibility
- Validation checkpoints between phases

---

## Project Goals & Context

### Primary Goals

1. **Immutable, reproducible workspace**
   - Fedora Kinoite (rpm-ostree) for system immutability
   - Nix + home-manager for declarative packages
   - Chezmoi for dotfiles
   - All configuration in Git

2. **Preparation for personal workspace (shoshin) improvements**
   - Current shoshin: NixOS + home-manager
   - Learn Kinoite + home-manager hybrid for potential future migration
   - Establish patterns for modular workspace

3. **Cross-platform, shareable configuration**
   - Work seamlessly across eyeonix-laptop (Windows + WSL) and shoshin (NixOS)
   - Dotfiles shared via chezmoi
   - Home-manager configs portable

4. **Full graphical desktop in WSL2**
   - KDE Plasma desktop environment
   - Multi-monitor support (laptop + 2+ external)
   - Native-like performance

5. **Fully automated bootstrap**
   - Windows 11 setup from scratch → automated
   - WSL2 + Kinoite + GUI → automated
   - CI/CD testing in Windows 11 VM

### Current State

**Host System:**
- **OS**: Windows 11 Pro 25H2 (build 26200.7462)
- **Hardware**: Samsung Galaxy Book (eyeonix-laptop)
- **Displays**: Laptop screen + 2+ external monitors

**Existing WSL Distributions:**
- Ubuntu 24.04.3 LTS (running, 974 packages) - **TO CLEAN**
- wsl-vpnkit (stopped) - **TO CLEAN**

**Existing my-modular-workspace Structure:**
- `hosts/shoshin/` - NixOS personal workstation config
- `home-manager/` - Home-manager modules (NixOS)
- `ansible/` - Ansible playbooks
- `docs/` - Documentation
- `docs/adrs/` - Architecture Decision Records (ADRs)

### Architecture Decisions (ADRs)

**Relevant ADRs:**
- [ADR-001: NixOS Stable vs Home-Manager Unstable](../../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md)
- [ADR-002: Ansible Handles RClone Sync Job](../../adrs/ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md)
- [ADR-005: Chezmoi Migration Criteria](../../adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md)

**Key principles from ADRs:**
- System stable, user packages unstable
- Ansible for automation
- Chezmoi for cross-platform simple configs
- Clear separation of concerns

---

## Architecture Overview

### Target Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Windows 11 Pro (25H2) - Minimal Launcher                    │
│                                                              │
│  ├─ X410 X Server (purchased, $10)                          │
│  ├─ Work Software (VPN, VMware) - manual install           │
│  ├─ Chocolatey / Winget (package managers)                  │
│  ├─ PowerShell / DSC (configuration)                        │
│  └─ .wslconfig (mirrored networking mode)                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    VSOCK / localhost
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Fedora Kinoite 41 WSL2 - Primary Development Environment    │
│                                                              │
│  ├─ rpm-ostree (immutable base)                            │
│  │   └─ Minimal layers: vim, git, htop, distrobox, ansible │
│  │                                                          │
│  ├─ Nix + home-manager (declarative packages)              │
│  │   └─ User packages, dotfiles, systemd services          │
│  │                                                          │
│  ├─ Chezmoi (cross-platform dotfiles)                      │
│  │   └─ Shell configs, app settings, templates             │
│  │                                                          │
│  ├─ Toolbox/Distrobox (dev containers)                     │
│  │   ├─ dev-general                                         │
│  │   ├─ sre-tools                                           │
│  │   └─ python-dev, golang-dev, etc.                       │
│  │                                                          │
│  └─ KDE Plasma 6 Desktop (via X410)                        │
│      └─ Multi-monitor support (3+ displays)                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Three-Tier Package Management

| Tier | Tool | Purpose | Example Packages |
|------|------|---------|-----------------|
| **Tier 1** | rpm-ostree | Minimal system base | vim, git, htop, distrobox, ansible |
| **Tier 2** | Nix + home-manager | User packages & config | ripgrep, fd, bat, kubectl, helm, ansible-lint |
| **Tier 3** | Toolbox/Distrobox | Dev environments | Python, Go, Node.js toolchains |

**GUI Apps**: Flatpak (via Flathub)

### Decision: Home-Manager Under Kinoite

**User's Goal**: Integrate home-manager under Fedora Kinoite WSL2

**Purpose**: Preparation for future shoshin (personal workspace) improvements

**Approach**:
1. Install Nix on Kinoite (Determinate Systems installer)
2. Install home-manager on top of Nix
3. Test with basic packages
4. Validate integration
5. Expand to full configuration

**Why**: Learn Kinoite + home-manager hybrid pattern for potential future use.

---

## Phase 1: Kinoite Base WSL2 Setup

**Goal**: Get Fedora Kinoite running in WSL2 with basic terminal functionality.

**Duration**: 1-2 weeks

**Prerequisites**:
- Windows 11 Pro 25H2 (✅ confirmed: build 26200.7462)
- WSL2 enabled
- Sufficient disk space (~50GB minimum)

### Steps

#### 1.1: Research Fedora Kinoite WSL2 Import

**Tasks**:
- [ ] Research Fedora Kinoite WSL2 installation methods
- [ ] Identify best approach (ISO extract, container image, or rebase)
- [ ] Document findings

**Resources**:
- [Fedora WSL Official Docs](https://docs.fedoraproject.org/en-US/cloud/wsl/)
- [Microsoft WSL Custom Distro Guide](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro)

**Options**:
1. Start with Fedora Server → rebase to Kinoite
2. Extract rootfs from Kinoite ISO
3. Use container image and export

**Recommendation** (from research): Option 1 - rebase from Fedora Server

**Q&A Round 1**:
- Which Fedora Kinoite version? (Latest: 41)
- Import location? (Suggested: `C:\WSL\FedoraKinoite`)
- Disk size allocation? (Dynamic, recommend 100GB max)

#### 1.2: Cleanup Existing WSL Distributions

**Tasks**:
- [x] Document Ubuntu WSL packages (already done during session)
- [ ] Export Ubuntu backup (if needed)
- [ ] Unregister Ubuntu WSL
- [ ] Unregister wsl-vpnkit
- [ ] Clean up WSL directories

**Commands**:
```powershell
# Optional: Export Ubuntu backup
wsl --export Ubuntu C:\WSL-Backups\Ubuntu-backup-2025-12-18.tar

# Unregister distributions
wsl --unregister Ubuntu
wsl --unregister wsl-vpnkit

# Verify cleanup
wsl --list --verbose
# Should show: No distributions installed
```

**Note**: Ubuntu had 974 packages installed. Document saved at: `sessions/eyeonix-workspace-cleanup-and-windows-migration/ubuntu-packages.txt` (if created).

#### 1.3: Import Fedora Kinoite to WSL2

**Method: Rebase from Fedora Server**

**Step 1**: Install Fedora from Microsoft Store
```powershell
# Option A: Install from Microsoft Store
# Search: "Fedora" → Install "Fedora Remix for WSL"

# Option B: Manual import (if Store unavailable)
# Download Fedora container base image
# Extract and import
```

**Step 2**: Initial setup
```bash
# Launch Fedora
wsl -d Fedora

# Inside Fedora, update
sudo dnf update -y
```

**Step 3**: Rebase to Kinoite
```bash
# Rebase to Fedora Kinoite 41
sudo rpm-ostree rebase fedora:fedora/41/x86_64/kinoite

# This downloads ~2-3GB and takes 20-60 minutes

# After completion, exit and restart WSL
exit
```

```powershell
# From PowerShell
wsl --shutdown
Start-Sleep -Seconds 10

# Restart
wsl -d Fedora
```

**Step 4**: Verify Kinoite
```bash
# Check rpm-ostree status
rpm-ostree status

# Should show:
# State: idle
# Deployments:
# ● fedora:fedora/41/x86_64/kinoite
```

**Step 5**: Rename to FedoraKinoite
```powershell
# Export current Fedora
wsl --export Fedora C:\Temp\fedora-kinoite-base.tar

# Import as FedoraKinoite
wsl --import FedoraKinoite C:\WSL\FedoraKinoite C:\Temp\fedora-kinoite-base.tar

# Set as default
wsl --set-default FedoraKinoite

# Cleanup temp file
Remove-Item C:\Temp\fedora-kinoite-base.tar

# Verify
wsl --list --verbose
```

#### 1.4: Basic WSL2 Configuration

**Create `.wslconfig`**:

Location: `C:\Users\dioklint.ATH\.wslconfig`

```ini
[wsl2]
# === Resource Allocation ===
memory=12GB                # Adjust based on total RAM
processors=6               # ~75% of CPU cores
swap=4GB
localhostForwarding=true   # CRITICAL for X410

# === Networking ===
networkingMode=mirrored    # Windows 11 22H2+ - use localhost

# === Performance ===
nestedVirtualization=false
vmIdleTimeout=120000       # 2 minutes

# === Experimental Features ===
[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
dnsTunneling=true
autoProxy=true
```

**Apply changes**:
```powershell
wsl --shutdown
wsl -d FedoraKinoite
```

#### 1.5: Layer Minimal Base Packages

**Strategy**: Minimal rpm-ostree layering

```bash
# Layer essential packages
sudo rpm-ostree install \
  vim \
  git \
  htop \
  tmux \
  distrobox

# Reboot WSL to apply
sudo systemctl reboot
# Or: exit, then wsl --shutdown, then wsl -d FedoraKinoite
```

**Verification**:
```bash
rpm-ostree status
# Should show layered packages

which vim git htop tmux distrobox
# All should be found
```

### Validation Checklist - Phase 1

- [ ] Fedora Kinoite imported to WSL2
- [ ] `rpm-ostree status` shows kinoite deployment
- [ ] Basic packages layered (vim, git, htop, tmux, distrobox)
- [ ] .wslconfig configured with mirrored networking
- [ ] Can launch and use terminal
- [ ] Systemd working (check: `systemctl status`)
- [ ] No errors in boot logs

### Q&A Round 2 - Phase 1

**Before proceeding to Phase 2:**

1. Is Kinoite performance acceptable? (terminal responsiveness)
2. Any issues with systemd in WSL2?
3. Resource allocation sufficient? (check with `htop`)
4. Ready to proceed with Nix + home-manager installation?

### Phase 1 Documentation

**Created docs**:
- This plan: `docs/windows-base/wsl/plan-wsl-kinoite-integration.md`

**Update docs**:
- [ ] Create session notes: `sessions/wsl-kinoite-integration/phase1-notes.md`
- [ ] Document any issues encountered
- [ ] Screenshot rpm-ostree status

---

## Phase 2: Home-Manager Integration

**Goal**: Install Nix and home-manager on Kinoite, test with basic packages.

**Duration**: 1-2 weeks

**Prerequisites**:
- Phase 1 complete (Kinoite WSL2 running)
- Internet connectivity
- Git configured

### Steps

#### 2.1: Install Nix on Kinoite

**Use Determinate Systems Nix installer** (officially supports Silverblue/Kinoite):

```bash
# Inside FedoraKinoite WSL
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Follow prompts
# Installer will:
#   - Create /nix directory
#   - Configure SELinux (if needed)
#   - Set up nix-daemon
#   - Configure systemd service

# After installation, source nix-daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Or restart shell
exit
wsl -d FedoraKinoite
```

**Verification**:
```bash
# Check Nix installation
nix --version
# Should show: nix (Nix) 2.x.x

# Check /nix directory
ls -la /nix
# Should show store/, var/, etc.

# Test Nix
nix-shell -p hello
hello
# Should print: Hello, world!
exit  # Exit nix-shell
```

#### 2.2: Install Home-Manager

**Add channels**:
```bash
# Add nixpkgs-unstable
nix-channel --add https://nixos.org/channels/nixpkgs-unstable

# Add home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

# Update channels
nix-channel --update
```

**Install home-manager**:
```bash
# Install home-manager via nix-shell
nix-shell '<home-manager>' -A install

# This creates ~/.config/home-manager/home.nix
```

**Verification**:
```bash
# Check home-manager command
home-manager --version

# Check config file
ls -la ~/.config/home-manager/home.nix
```

#### 2.3: Create Initial Home-Manager Configuration

**Edit configuration**:
```bash
home-manager edit
# Or: vim ~/.config/home-manager/home.nix
```

**Basic configuration**:
```nix
{ config, pkgs, ... }:

{
  # Home Manager configuration version
  home.stateVersion = "24.11";  # Match your Nix version

  # Basic info
  home.username = "mitsio";  # Adjust to your WSL username
  home.homeDirectory = "/home/mitsio";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Test packages (BASIC ONLY for Phase 2)
  home.packages = with pkgs; [
    # CLI utilities
    bat       # cat replacement with syntax highlighting
    fd        # find replacement
    ripgrep   # grep replacement
    fzf       # fuzzy finder

    # Development tools (basic)
    jq        # JSON processor
    htop      # Already in system, but good test
  ];

  # Test program module: Git
  programs.git = {
    enable = true;
    userName = "Dimitris Tsioumas";
    userEmail = "dtsioumas0@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autostash = true;
    };
  };

  # Test program module: Bash
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      gs = "git status";
    };
  };
}
```

**Apply configuration**:
```bash
home-manager switch

# First run takes time (downloads packages)
# Subsequent runs are faster
```

**Verification**:
```bash
# Check installed packages
which bat fd rg fzf jq
# All should be found in ~/.nix-profile/bin/

# Test packages
bat --version
fd --version
rg --version

# Check git config
git config --global --list
# Should show name, email, and extraConfig settings

# Check bash aliases
alias ll
alias gs
```

#### 2.4: Test Distrobox Integration

**Verify Nix mounts in Distrobox** (critical feature):

```bash
# Create test container
distrobox create --name test-nix --image fedora:41

# Enter container
distrobox enter test-nix
```

Inside container:
```bash
# Check if /nix is mounted
ls -la /nix
# Should show /nix directory from host

# Test Nix packages work
bat --version
fd --version

# Exit container
exit
```

**Result**: If /nix is accessible in container, Nix integration is successful!

#### 2.5: Integration with Ansible

**Layer Ansible** (system-wide for consistency):

```bash
sudo rpm-ostree install ansible ansible-lint
sudo systemctl reboot
```

After reboot:
```bash
# Verify Ansible
ansible --version

# Ansible can now manage both:
#   - rpm-ostree packages (via ansible.posix.rpm_ostree_pkg)
#   - System configs
# While home-manager manages:
#   - User packages (via Nix)
#   - User configs
```

### Validation Checklist - Phase 2

- [ ] Nix installed (`nix --version` works)
- [ ] `/nix` directory exists and accessible
- [ ] home-manager installed (`home-manager --version` works)
- [ ] Basic home.nix configuration created
- [ ] `home-manager switch` completes successfully
- [ ] Test packages work (bat, fd, ripgrep, fzf, jq)
- [ ] Git configured via home-manager
- [ ] Bash aliases active
- [ ] `/nix` accessible in Distrobox containers
- [ ] Ansible layered and working

### Q&A Round 2 - Phase 2

**Before proceeding to Phase 3:**

1. Home-manager integration feels solid? Any issues?
2. Performance impact of Nix acceptable?
3. Want to expand home-manager config before Phase 3?
4. Ready to proceed with GUI setup (X410)?

### Phase 2 Documentation

**Reference docs**:
- [rpm-ostree-nix-homemanager-integration.md](./rpm-ostree-nix-homemanager-integration.md)

**Update docs**:
- [ ] Document home-manager config location
- [ ] Save working home.nix example
- [ ] Document any Nix issues encountered

---

## Phase 3: X410 + KDE Plasma + Multi-Monitor

**Goal**: Enable graphical desktop (KDE Plasma) via X410 with basic multi-monitor support.

**Duration**: 2-3 weeks

**Prerequisites**:
- Phase 2 complete (home-manager working)
- X410 purchased and installed
- Multi-monitor hardware setup ready

### Steps

#### 3.1: Purchase and Install X410

**Purchase**:
```
1. Open Microsoft Store
2. Search: "X410"
3. Price: $9.99 (one-time purchase)
4. Click "Get" / "Purchase"
5. Install
```

**Launch X410**:
```
1. Search "X410" in Start Menu
2. Launch
3. X410 icon appears in system tray
```

**Initial configuration**:
```
1. Right-click X410 tray icon → Options
2. General:
   - Mode: Desktop (floating or maximum)
   - Launch at Windows startup: ✓
3. Display:
   - DPI: Auto-detect
   - GPU Acceleration: Enabled
   - Multi-monitor: Use all displays
4. Access Control → TCP (IPv4):
   - Enable: [WSL2] ✓
5. Click "Save"
```

#### 3.2: Configure DISPLAY Environment Variable

**Option A: Using Mirrored Networking Mode** (Recommended for Windows 11)

Since you have Windows 11 Pro 25H2 with `networkingMode=mirrored`:

```bash
# Add to ~/.bashrc
echo 'export DISPLAY=127.0.0.1:0.0' >> ~/.bashrc

# Source
source ~/.bashrc

# Verify
echo $DISPLAY
# Should show: 127.0.0.1:0.0
```

**Option B: Using VSOCK** (Most stable - recommended for production)

```bash
# Install socat
sudo rpm-ostree install socat
sudo systemctl reboot
```

After reboot, create systemd user service:

Create `~/.config/systemd/user/x410-vsock.service`:
```ini
[Unit]
Description=X410 VSOCK relay for WSL2
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/socat -b65536 UNIX-LISTEN:/tmp/.X11-unix/X0,fork,mode=777 VSOCK-CONNECT:2:6000
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

Enable and start:
```bash
systemctl --user enable x410-vsock.service
systemctl --user start x410-vsock.service

# Add to ~/.bashrc
echo 'export DISPLAY=:0.0' >> ~/.bashrc
source ~/.bashrc
```

**Verification**:
```bash
# Test X11 connection
xclock
# Should show a clock window in X410

# If xclock not found, install X11 apps
sudo rpm-ostree install xorg-x11-apps
sudo systemctl reboot
```

#### 3.3: Launch KDE Plasma

**First launch** (manual):

```bash
# Ensure X410 is running (check system tray)

# Launch KDE Plasma
startplasma-x11

# Initial launch may take 1-2 minutes
# KDE Plasma should appear in X410 window
```

**If errors**:
```bash
# Check logs
journalctl -xe | grep plasma

# Check DISPLAY
echo $DISPLAY

# Verify X11 connection
xdpyinfo
```

**Create launcher script** (optional):

`~/launch-kde.sh`:
```bash
#!/bin/bash
export DISPLAY=:0.0  # Or 127.0.0.1:0.0
startplasma-x11
```

```bash
chmod +x ~/launch-kde.sh
./launch-kde.sh
```

#### 3.4: Configure Multi-Monitor Setup

**In KDE Plasma** (via X410):

1. Open **System Settings** (click K menu → System Settings)
2. Navigate to **Display Configuration**
3. Detect displays:
   - Should show: Laptop display + 2 external monitors
   - Example: eDP-1 (laptop), HDMI-1 (external 1), DP-1 (external 2)

4. Arrange monitors:
   - Drag monitor representations to match physical layout
   - Set primary monitor
   - Set resolution for each (1920x1080 @ 75Hz recommended)

5. Click **Apply**

6. **Save profile**:
   - Click "Save As" in Display Configuration
   - Name: "Office Docked" (3 monitors)

7. Create additional profiles:
   - Laptop Only: Disable external monitors
   - Save as: "Laptop Only"

**Create monitor switching scripts**:

`~/bin/dock-monitors.sh`:
```bash
#!/bin/bash
kscreen-doctor output.eDP-1.enable \
               output.HDMI-1.enable \
               output.DP-1.enable \
               output.HDMI-1.mode.1920x1080@75 \
               output.DP-1.mode.1920x1080@75
```

`~/bin/laptop-only.sh`:
```bash
#!/bin/bash
kscreen-doctor output.eDP-1.enable \
               output.HDMI-1.disable \
               output.DP-1.disable
```

```bash
chmod +x ~/bin/dock-monitors.sh ~/bin/laptop-only.sh
```

**Test**:
```bash
# Switch to laptop only
~/bin/laptop-only.sh

# Switch back to docked
~/bin/dock-monitors.sh
```

#### 3.5: Basic KDE Plasma Configuration

**Essential settings**:

1. **Input Latency** (if laggy):
   - System Settings → Display → Compositor
   - Rendering backend: XRender (if OpenGL has issues)
   - Animation speed: Instant (0)

2. **Performance**:
   - System Settings → Desktop Effects
   - Disable heavy effects if laggy

3. **Multi-monitor specific**:
   - System Settings → Window Management → Window Behavior
   - Multi-Screen Behavior: Active screen follows mouse

4. **Keyboard shortcuts** (optional):
   - Set up shortcuts for monitor switching scripts

#### 3.6: Windows Launcher Script

**Create**: `C:\Users\dioklint.ATH\launch-kde.bat`

```batch
@echo off
echo Starting KDE Plasma on WSL2...

REM Start X410 if not running
tasklist /FI "IMAGENAME eq X410.exe" 2>NUL | find /I /N "X410.exe">NUL
if "%ERRORLEVEL%"=="1" (
    echo Starting X410...
    start "" "C:\Program Files\X410\X410.exe"
    timeout /t 5 /nobreak > nul
)

REM Launch KDE Plasma in WSL2
wsl -d FedoraKinoite bash -c "export DISPLAY=:0.0 && startplasma-x11"
```

**Usage**:
- Double-click `launch-kde.bat` from Windows Explorer
- Or create desktop shortcut

**Optional**: Add to Windows startup folder
```
shell:startup
```

### Validation Checklist - Phase 3

- [ ] X410 purchased and installed
- [ ] X410 launches and shows in system tray
- [ ] DISPLAY variable set correctly
- [ ] `xclock` or similar X11 app shows window
- [ ] KDE Plasma launches successfully
- [ ] All monitors detected (laptop + 2 external)
- [ ] Can arrange monitors in Display Configuration
- [ ] Monitor profiles saved (Docked, Laptop Only)
- [ ] Switching scripts work
- [ ] Input latency acceptable (<100ms subjective)
- [ ] Window movement smooth
- [ ] Konsole (terminal) responsive
- [ ] Can open and use Firefox/browser

### Q&A Round 3 - Phase 3

**Before proceeding to Phase 4:**

1. GUI performance acceptable? (input lag, responsiveness)
2. Multi-monitor setup working as expected?
3. Any issues with KDE Plasma stability?
4. Ready to move to performance optimizations?
5. Any specific apps to test before proceeding?

### Phase 3 Documentation

**Reference docs**:
- [wsl2-networking-x410-optimization.md](./wsl2-networking-x410-optimization.md)
- [GRAPHICAL-INTEGRATION-OVERVIEW.md](../GRAPHICAL-INTEGRATION-OVERVIEW.md)

**Update docs**:
- [ ] Screenshot multi-monitor setup
- [ ] Document any X410 issues
- [ ] Save working KDE Plasma config

---

## Phase 4: WSL2 Performance Optimization

**Goal**: Optimize WSL2 and Kinoite for best performance on eyeonix-laptop hardware.

**Duration**: 2-3 weeks

**Prerequisites**:
- Phase 3 complete (GUI working)
- Baseline performance measured

### Steps

#### 4.1: Performance Baseline Measurement

**Measure current performance**:

```bash
# Inside FedoraKinoite

# 1. System resources
htop
# Note: CPU usage, RAM usage, load average

# 2. Disk I/O speed
dd if=/dev/zero of=~/testfile bs=1M count=1024 oflag=direct
# Note: MB/s write speed

dd if=~/testfile of=/dev/null bs=1M iflag=direct
# Note: MB/s read speed

rm ~/testfile

# 3. Input latency (subjective)
# Open Konsole, type rapidly
# Estimate lag: <50ms = excellent, <100ms = good, >100ms = needs work

# 4. Window movement (subjective)
# Drag windows around
# Estimate FPS: >30fps = smooth, <30fps = choppy

# 5. Application launch time
time firefox
# Note: seconds to launch
```

**Document baseline**:
Create `sessions/wsl-kinoite-integration/phase4-baseline-performance.md`

#### 4.2: .wslconfig Optimization

**Current .wslconfig** (from Phase 1):
```ini
[wsl2]
memory=12GB
processors=6
swap=4GB
localhostForwarding=true
networkingMode=mirrored
nestedVirtualization=false
vmIdleTimeout=120000

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
dnsTunneling=true
autoProxy=true
```

**Hardware-specific tuning**:

```bash
# Check actual hardware
# In PowerShell (Windows):
systeminfo | findstr /C:"Total Physical Memory"
# Note total RAM

Get-CimInstance -ClassName Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors
# Note CPU cores
```

**Adjust .wslconfig** based on actual hardware:

Example for 16GB RAM system:
```ini
[wsl2]
memory=12GB                # 75% of 16GB
processors=6               # Adjust based on actual cores
swap=3GB                   # 25% of memory allocation
localhostForwarding=true
networkingMode=mirrored

# Performance tweaks
nestedVirtualization=false
vmIdleTimeout=60000        # 1 minute (adjust if needed)
pageReporting=true         # Return unused memory faster

[experimental]
autoMemoryReclaim=gradual  # Or "dropcache" for more aggressive
sparseVhd=true
dnsTunneling=true
autoProxy=true
```

**Apply**:
```powershell
wsl --shutdown
wsl -d FedoraKinoite
# Test and measure
```

#### 4.3: Filesystem Optimization

**Critical rule**: Work in Linux filesystem, not Windows

**Verify working directory**:
```bash
pwd
# Should be under /home/mitsio/, NOT /mnt/c/
```

**Move projects** if currently in `/mnt/c/`:
```bash
# Move projects to Linux filesystem
mkdir -p ~/projects
cp -r /mnt/c/Users/dioklint.ATH/projects/* ~/projects/
# Or use rsync for large transfers

# Work from ~/projects going forward
cd ~/projects
```

**Disk space management**:
```bash
# Check disk usage
df -h

# If WSL2 VHDX grows too large, compact it
# From PowerShell (when WSL stopped):
wsl --shutdown
# Then optimize-vhd or diskpart commands (see docs)
```

#### 4.4: X410 VSOCK Optimization

**If not already using VSOCK**, switch from TCP to VSOCK:

Benefits:
- 20-30% lower latency
- Stable across sleep/wake, VPN changes
- More reliable connection

Setup (if not done in Phase 3):
```bash
# Already layered socat in Phase 3
# Create systemd service (see Phase 3.2)
systemctl --user enable x410-vsock.service
systemctl --user start x410-vsock.service
```

**X410 settings optimization**:
```
Right-click X410 tray icon → Options:

Display:
  - Renderer: OpenGL (NOT software)
  - GPU Acceleration: Enabled
  - V-Sync: Adaptive

Network:
  - Protocol: VSOCK (if configured)
  - Compression: None (lower latency for local)

Advanced:
  - Buffer Size: Large (for multi-monitor)
  - Refresh Rate: Match Windows (e.g., 75Hz)
```

#### 4.5: KDE Plasma Performance Tuning

**Disable heavy effects** (if laggy):

```bash
# Disable compositor entirely (extreme measure)
kwriteconfig5 --file kwinrc --group Compositing --key Enabled false
qdbus org.kde.KWin /KWin reconfigure

# Or switch to XRender (less GPU-intensive)
kwriteconfig5 --file kwinrc --group Compositing --key Backend XRender
qdbus org.kde.KWin /KWin reconfigure

# Reduce animation speed
kwriteconfig5 --file kwinrc --group Compositing --key AnimationSpeed 0
qdbus org.kde.KWin /KWin reconfigure
```

**Test and revert if worse**:
```bash
# Re-enable compositor
kwriteconfig5 --file kwinrc --group Compositing --key Enabled true
qdbus org.kde.KWin /KWin reconfigure
```

#### 4.6: Hardware-Specific Optimization

**Identify hardware**:
```bash
# CPU info
lscpu

# GPU info (if available in WSL2)
lspci | grep -i vga
# Or: check in Windows Device Manager

# RAM info
free -h
```

**Samsung Galaxy Book specific** (if applicable):
- Adjust power management settings
- Check Samsung utilities on Windows side
- Ensure not throttling CPU

**GPU leveraging** (Phase 7 advanced topic, note for later):
- WSL2 supports GPU passthrough (DirectX, CUDA)
- May require additional setup for full GPU acceleration
- Document for Phase 7

#### 4.7: Re-measure Performance

**After optimizations**, re-run baseline tests:

```bash
# Disk I/O
dd if=/dev/zero of=~/testfile bs=1M count=1024 oflag=direct
dd if=~/testfile of=/dev/null bs=1M iflag=direct
rm ~/testfile

# Input latency (subjective)
# Type in Konsole - should feel snappier

# Window movement
# Drag windows - should be smoother

# Application launch
time firefox
```

**Compare to baseline**:
- I/O speed: Should be similar (limited by WSL2 architecture)
- Input latency: Should improve with VSOCK and compositor tweaks
- Window movement: Should improve with compositor settings
- App launch: May improve slightly

**Document improvements**:
- Update `phase4-baseline-performance.md` with "After" measurements
- Note what worked, what didn't

### Validation Checklist - Phase 4

- [ ] Baseline performance measured and documented
- [ ] .wslconfig tuned for actual hardware
- [ ] Working in Linux filesystem (not /mnt/c/)
- [ ] VSOCK configured for X410 (if not already)
- [ ] X410 settings optimized
- [ ] KDE Plasma compositor tuned
- [ ] Re-measured performance
- [ ] Input latency <100ms (subjective)
- [ ] Window movement smooth (>30fps subjective)
- [ ] Application launch acceptable
- [ ] No regressions from optimizations

### Q&A Round 4 - Phase 4

**Before proceeding to Phase 5:**

1. Performance improvements noticeable?
2. Any regressions from optimizations?
3. Acceptable for daily use?
4. Any specific bottlenecks identified?
5. Ready to decide Windows vs WSL boundaries?

### Phase 4 Documentation

**Reference docs**:
- [wsl2-networking-x410-optimization.md](./wsl2-networking-x410-optimization.md)

**Create docs**:
- [ ] `phase4-baseline-performance.md` (before/after measurements)
- [ ] Document optimal .wslconfig for your hardware
- [ ] Note any hardware-specific issues

---

## Phase 5: Windows 11 as Launcher

**Goal**: Decide what stays in Windows 11 vs WSL2, optimize Windows as minimal launcher.

**Duration**: 2-3 weeks

**Prerequisites**:
- Phase 4 complete (performance optimized)
- Daily usage experience with current setup

### Steps

#### 5.1: Inventory Current Usage

**Document for 1-2 weeks**:
What runs where?

**Windows 11 side**:
- [ ] Work VPN (Check Point) - probably must stay in Windows
- [ ] VMware Workstation - Windows or WSL?
- [ ] Microsoft Office - Windows or WSL?
- [ ] Samsung utilities - Windows only
- [ ] Browser - Windows or WSL?
- [ ] Email client - Windows or WSL?
- [ ] File manager - Windows or WSL?

**WSL2 side**:
- [ ] Development tools (Git, editors, etc.)
- [ ] Terminal work
- [ ] Docker/containers
- [ ] Kubernetes tools
- [ ] Ansible playbooks
- [ ] Personal projects

**Criteria for staying in Windows**:
- Required by corporate policy (VPN, security tools)
- Better Windows integration (Office, Teams)
- Hardware-dependent (Samsung utilities)
- Performance better on Windows (rare, but check browser)

**Criteria for moving to WSL2**:
- Development tools (always WSL)
- CLI tools (always WSL)
- Open source tools (usually better in Linux)
- Personal productivity tools (preference)

#### 5.2: Make Placement Decisions

**Based on usage inventory, decide**:

| Software | Location | Reason |
|----------|----------|--------|
| Check Point VPN | Windows | Corporate requirement |
| VMware Workstation | Windows | (Probably) Native Windows performance |
| Office 365 | Windows | Better integration |
| Samsung utilities | Windows | Hardware-specific |
| Firefox/Brave | ??? | **Decide**: Windows or WSL |
| VS Code / VSCodium | ??? | **Decide**: Windows w/ Remote-WSL or WSL native |
| File Manager | Both | Windows Explorer for Windows files, Dolphin (KDE) for WSL |
| Email | ??? | **Decide**: Outlook (Windows) or Thunderbird (WSL) |
| KeePassXC | ??? | **Decide**: Windows or WSL (affects secret access) |

**Q&A Round 1 - Phase 5**:
User input needed for "Decide" items above.

#### 5.3: Optimize Windows 11

**Goal**: Make Windows 11 a clean, minimal launcher.

**Windows 11 optimizations**:

1. **Disable unnecessary startup programs**:
   ```
   Task Manager → Startup
   Disable non-essential apps
   ```

2. **Disable unnecessary Windows services**:
   ```
   services.msc
   Disable non-critical services (research before disabling!)
   ```

3. **Disable telemetry** (optional):
   ```
   Settings → Privacy → Diagnostics & feedback
   Set to: Basic (or use tools like O&O ShutUp10++)
   ```

4. **Optimize power settings**:
   ```
   Power Plan: High Performance (for desktop use)
   Adjust sleep settings
   ```

5. **Declutter taskbar and Start Menu**:
   - Remove unused pinned apps
   - Keep only: File Explorer, Terminal, X410, and essential work apps

6. **Windows Update policy**:
   ```
   Settings → Windows Update → Advanced options
   Configure to avoid interruptions during work
   ```

#### 5.4: Create Launch Workflows

**Scenario 1: Start Work Day**

Windows batch script: `C:\Users\dioklint.ATH\start-work.bat`
```batch
@echo off
echo Starting Eyeonix Workspace...

REM 1. Start X410
start "" "C:\Program Files\X410\X410.exe"
timeout /t 3 /nobreak > nul

REM 2. Launch WSL2 KDE Plasma
wsl -d FedoraKinoite bash -c "export DISPLAY=:0.0 && startplasma-x11" &

REM 3. Launch work apps (Windows)
start "" "C:\Program Files\Check Point\VPN\vpn_client.exe"
REM start "" "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"

echo Workspace started!
pause
```

**Scenario 2: Shutdown**

`C:\Users\dioklint.ATH\shutdown-work.bat`
```batch
@echo off
echo Shutting down workspace...

REM 1. Close KDE Plasma gracefully
wsl -d FedoraKinoite bash -c "qdbus org.kde.ksmserver /KSMServer logout 0 0 0"

REM 2. Wait for WSL to shutdown
timeout /t 5 /nobreak > nul

REM 3. Shutdown WSL
wsl --shutdown

REM 4. Close X410
taskkill /IM X410.exe /F

echo Workspace shutdown complete!
pause
```

#### 5.5: Integrate with Windows 11 Features

**Windows Terminal integration**:
```json
// settings.json
{
  "profiles": {
    "list": [
      {
        "name": "Fedora Kinoite",
        "commandline": "wsl.exe -d FedoraKinoite",
        "icon": "path/to/fedora-icon.png",
        "colorScheme": "One Half Dark"
      }
    ]
  },
  "defaultProfile": "{guid-of-fedora-kinoite}"
}
```

**File Explorer integration**:
- Access WSL2 files via: `\\wsl$\FedoraKinoite\home\mitsio`
- Pin to Quick Access

**Task Scheduler** (optional):
- Auto-start workspace on Windows login
- Scheduled backups of WSL2

#### 5.6: Windows 11 Declarative Config (Preparation for Phase 8)

**Note for Phase 8**: Document Windows 11 settings that should be declarative:
- [ ] List of installed software (choco/winget)
- [ ] Windows settings (DSC or registry)
- [ ] Taskbar/Start Menu layout
- [ ] Power settings
- [ ] Network settings
- [ ] Firewall rules

**Create documentation**:
`docs/windows-base/windows11-desired-state.md`

### Validation Checklist - Phase 5

- [ ] Usage inventory complete (1-2 weeks of observation)
- [ ] Placement decisions made (Windows vs WSL for each tool)
- [ ] Windows 11 optimized (startup, services, clutter removed)
- [ ] Launch scripts created (start-work.bat, shutdown-work.bat)
- [ ] Windows Terminal configured
- [ ] File Explorer access to WSL2 set up
- [ ] Windows 11 desired state documented

### Q&A Round 5 - Phase 5

**Before proceeding to Phase 6:**

1. Happy with Windows vs WSL boundaries?
2. Any tools need to be moved?
3. Launch workflows smooth?
4. Ready to integrate chezmoi for dotfiles?

### Phase 5 Documentation

**Create docs**:
- [ ] `docs/windows-base/windows11-desired-state.md`
- [ ] `docs/windows-base/workspace-boundaries.md` (what's in Windows vs WSL)
- [ ] Document launch scripts

---

## Phase 6: Chezmoi + Workspace Unification

**Goal**: Integrate chezmoi for cross-platform dotfiles, unify workspace configuration.

**Duration**: 2-3 weeks

**Prerequisites**:
- Phase 5 complete (boundaries defined)
- Existing dotfiles identified

### Steps

#### 6.1: Install Chezmoi on Kinoite

**Method 1: rpm-ostree** (recommended):
```bash
sudo rpm-ostree install chezmoi
sudo systemctl reboot
```

After reboot:
```bash
chezmoi --version
```

**Method 2: Nix + home-manager** (alternative):
```nix
# ~/.config/home-manager/home.nix
home.packages = with pkgs; [
  chezmoi
];
```

```bash
home-manager switch
```

#### 6.2: Initialize Chezmoi Structure

**Option A: Fresh start**

```bash
# Initialize chezmoi
chezmoi init

# This creates ~/.local/share/chezmoi/
cd ~/.local/share/chezmoi/
git init
```

**Option B: Use existing my-modular-workspace**

```bash
# Initialize with existing repo
chezmoi init --source ~/my-modular-workspace/chezmoi

# Or if repo is in different location
cd ~/my-modular-workspace
mkdir -p chezmoi
cd chezmoi
echo "home" > .chezmoiroot
mkdir home
```

#### 6.3: Define Chezmoi Structure

**Create directory structure**:

```
my-modular-workspace/chezmoi/
├── .chezmoiroot             # Points to home/ subdirectory
├── .chezmoi.toml.tmpl       # Per-machine configuration
├── .chezmoiignore           # Conditional file inclusion
├── .chezmoiremove           # Files to remove
│
├── home/                    # Actual dotfiles (via .chezmoiroot)
│   ├── dot_bashrc.tmpl
│   ├── dot_bash_profile.tmpl
│   │
│   └── dot_config/
│       ├── kitty/
│       │   └── kitty.conf.tmpl
│       ├── kde/
│       │   ├── kdeglobals.tmpl
│       │   └── kwinrc.tmpl
│       ├── atuin/
│       │   └── config.toml.tmpl
│       └── git/
│           └── config.tmpl     # Simple git settings
│
└── .chezmoiscripts/
    ├── run_once_before_install-packages.sh
    └── run_once_after_configure-kde.sh
```

#### 6.4: Create Configuration Template

**`.chezmoi.toml.tmpl`**:
```toml
{{- $name := promptString "name" -}}
{{- $email := promptString "email" -}}
{{- $hostname := .chezmoi.hostname -}}
{{- $is_work := promptBool "is_work" -}}

[data]
    name = {{ $name | quote }}
    email = {{ $email | quote }}
    hostname = {{ $hostname | quote }}
    is_work = {{ $is_work }}
```

**`.chezmoiignore`**:
```
# Ignore work-specific configs on personal machines
{{ if not .is_work }}
.config/work-vpn
{{ end }}

# Ignore personal configs on work machines
{{ if .is_work }}
.config/personal-stuff
{{ end }}
```

#### 6.5: Migrate Dotfiles to Chezmoi

**Identify dotfiles to migrate** (based on ADR-005):

**Move to chezmoi**:
- [ ] ~/.bashrc (shell config)
- [ ] ~/.bash_profile
- [ ] ~/.config/kitty/ (terminal settings)
- [ ] ~/.config/atuin/ (history sync)
- [ ] ~/.config/kde/ (KDE Plasma settings)
- [ ] ~/.config/navi/ (cheatsheets)

**Keep in home-manager**:
- [x] Package installation (home.packages)
- [x] Complex programs.* modules (programs.git, programs.tmux)
- [x] Systemd user services

**Add files to chezmoi**:
```bash
# Add existing files
chezmoi add ~/.bashrc
chezmoi add ~/.config/kitty/kitty.conf
chezmoi add ~/.config/atuin/config.toml

# Convert to templates if needed
chezmoi edit ~/.bashrc
# Add templating logic (e.g., {{ if .is_work }})

# Commit to Git
cd ~/.local/share/chezmoi
git add .
git commit -m "Initial chezmoi dotfiles"
```

#### 6.6: Configure Home-Manager + Chezmoi Separation

**Document file ownership**:

Create `docs/CONFIG_OWNERSHIP.md`:
```markdown
# Configuration File Ownership

## Managed by Home-Manager

| File | Module | Reason |
|------|--------|--------|
| ~/.gitconfig | programs.git | Complex Nix logic |
| ~/.tmux.conf | programs.tmux | Uses home-manager module |
| Packages | home.packages | Nix package management |
| Systemd services | systemd.user.* | System integration |

## Managed by Chezmoi

| File | Reason |
|------|--------|
| ~/.bashrc | Simple shell config, machine-specific |
| ~/.config/kitty/ | Terminal preferences |
| ~/.config/kde/ | Desktop settings |
| ~/.config/atuin/ | History sync config |
| ~/.config/navi/ | Cheatsheets |
```

**Principle**: Each file managed by ONE tool only!

#### 6.7: Test Chezmoi on Eyeonix-Laptop

**Initialize and apply**:
```bash
# If using existing repo
chezmoi init --apply ~/my-modular-workspace/chezmoi

# Or with Git URL
chezmoi init --apply https://github.com/dtsioumas/my-modular-workspace.git --source chezmoi
```

**Verification**:
```bash
# Check applied files
chezmoi managed

# Check differences
chezmoi diff

# Dry run
chezmoi apply --dry-run

# Actual apply
chezmoi apply
```

#### 6.8: Extend to Shoshin (Future)

**Goal**: Test cross-platform dotfiles.

**On shoshin** (when ready):
```bash
# Install chezmoi (if not already)
# Via Nix or OS package manager

# Initialize with same repo
chezmoi init --apply https://github.com/dtsioumas/my-modular-workspace.git --source chezmoi

# Answer prompts differently
# hostname: shoshin
# is_work: false

# Templates will adjust configs automatically
```

**Result**: Same dotfiles repo, different configs per machine!

### Validation Checklist - Phase 6

- [ ] Chezmoi installed on Kinoite
- [ ] Chezmoi structure created in my-modular-workspace/chezmoi/
- [ ] Configuration template (.chezmoi.toml.tmpl) created
- [ ] Dotfiles migrated to chezmoi (identified list)
- [ ] Templates created for machine-specific configs
- [ ] CONFIG_OWNERSHIP.md documented
- [ ] `chezmoi apply` works without conflicts
- [ ] No overlap with home-manager files
- [ ] Changes to dotfiles can be edited via `chezmoi edit`
- [ ] Committed to Git

### Q&A Round 6 - Phase 6

**Before proceeding to Phase 7:**

1. Chezmoi integration smooth?
2. Any conflicts with home-manager?
3. Templating working as expected?
4. Ready for advanced optimizations?

### Phase 6 Documentation

**Reference docs**:
- [chezmoi-integration-strategy.md](./chezmoi-integration-strategy.md)

**Create docs**:
- [ ] `docs/CONFIG_OWNERSHIP.md`
- [ ] Document chezmoi template patterns used
- [ ] Example machine-specific configs

---

## Phase 7: Advanced Optimizations

**Goal**: GPU leveraging, home-manager optimization, X410 advanced tuning, custom code if needed.

**Duration**: 3-4 weeks

**Prerequisites**:
- Phases 1-6 complete (full working system)
- Identified performance bottlenecks

### Steps

#### 7.1: Identify Optimization Targets

**Based on usage**, identify what needs optimization:

**Potential targets**:
- [ ] GPU acceleration (CUDA, OpenGL, DirectX)
- [ ] Home-manager rebuild speed
- [ ] X410 rendering performance
- [ ] Disk I/O for development workflows
- [ ] Network latency for remote services
- [ ] KDE Plasma specific slowness

**Measure first**:
- Profile application launch times
- Measure compilation speeds
- Check GPU utilization
- Monitor RAM usage patterns

#### 7.2: GPU Leveraging in WSL2

**WSL2 GPU support**:
- DirectX 12 support (for graphics)
- CUDA support (for ML/AI workloads)
- OpenGL support (for 3D apps)

**Enable GPU passthrough**:

```bash
# Check if GPU is available
lspci | grep -i vga
# or
nvidia-smi  # If NVIDIA GPU

# Install GPU drivers (if needed)
# For NVIDIA:
sudo rpm-ostree install nvidia-driver nvidia-settings
sudo systemctl reboot
```

**Test GPU**:
```bash
# OpenGL test
glxinfo | grep "OpenGL version"

# CUDA test (if applicable)
nvidia-smi

# Run GPU-accelerated app
# Example: Blender, GIMP with GPU acceleration
```

**Optimization**:
- Ensure X410 is using GPU acceleration (already configured in Phase 3)
- Configure apps to use GPU (e.g., Firefox with WebGL, VSCodium with GPU acceleration)

#### 7.3: Home-Manager Optimization

**Current home-manager rebuild time**:
```bash
time home-manager switch
# Note: seconds
```

**Optimization strategies**:

1. **Use binary cache**:
```nix
# ~/.config/home-manager/home.nix
nix.settings = {
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
};
```

2. **Modularize config**:
```
~/.config/home-manager/
├── home.nix              # Main config (imports others)
├── programs/
│   ├── git.nix
│   ├── bash.nix
│   └── vim.nix
└── packages.nix          # Separate package list
```

```nix
# home.nix
{ config, pkgs, ... }:
{
  imports = [
    ./programs/git.nix
    ./programs/bash.nix
    ./programs/vim.nix
    ./packages.nix
  ];
  # ...
}
```

3. **Lazy evaluation**:
- Only build what changed
- Use `home-manager build` to test without switching

4. **Parallel builds**:
```bash
# Set in nix.conf or env
export NIX_BUILD_CORES=6
home-manager switch
```

**Re-measure**:
```bash
time home-manager switch
# Should be faster
```

#### 7.4: X410 Advanced Tuning

**Experiment with X410 settings**:

1. **Display settings**:
   - Try different renderers (OpenGL vs GDI+)
   - Adjust DPI scaling per monitor
   - Test different buffer sizes

2. **Network optimization**:
   - VSOCK already optimal
   - Could write custom relay if needed (advanced)

3. **Custom X410 configuration**:
   - X410 supports config files
   - Document optimal settings for your hardware

**If needed: Custom X410 relay**:

**Scenario**: VSOCK + socat has issues

**Solution**: Write custom relay in Go or Rust
- Optimize buffer sizes
- Implement connection pooling
- Add monitoring/logging

**Example structure** (Go):
```go
// x410-relay/main.go
package main

import (
    "io"
    "log"
    "net"
)

func main() {
    // Listen on Unix socket
    listener, _ := net.Listen("unix", "/tmp/.X11-unix/X0")
    defer listener.Close()

    for {
        conn, _ := listener.Accept()
        go handleConnection(conn)
    }
}

func handleConnection(unixConn net.Conn) {
    // Connect to VSOCK
    vsockConn, _ := net.Dial("vsock", "2:6000")

    // Bidirectional copy with optimized buffer
    go io.Copy(vsockConn, unixConn)
    io.Copy(unixConn, vsockConn)
}
```

**Only implement if socat is insufficient!**

#### 7.5: Disk I/O Optimization

**Strategies**:

1. **Use BTRFS or ext4 optimizations** (if applicable in WSL2)
2. **Tune filesystem mount options**
3. **Use faster storage** (ensure WSL2 VHDX is on SSD)

**Check current**:
```bash
mount | grep " / "
# Check filesystem type and mount options
```

**Windows side**:
```powershell
# Ensure .wslconfig has:
[experimental]
sparseVhd=true

# Check VHDX location
# Should be on SSD, not HDD
# C:\Users\dioklint.ATH\AppData\Local\Packages\...\LocalState\ext4.vhdx
```

#### 7.6: Development Workflow Optimization

**Optimize common workflows**:

**Example: Ansible playbook development**:
```bash
# Use ansible-navigator or ansible-lint with fast feedback
# Cache ansible-galaxy collections

# In home-manager:
programs.bash.shellAliases = {
  ap = "ansible-playbook";
  al = "ansible-lint";
};
```

**Example: Kubernetes development**:
```bash
# Use K3s or Kind in WSL2
# Cache Docker images

# Optimize kubectl with aliases
programs.bash.shellAliases = {
  k = "kubectl";
  kgp = "kubectl get pods";
  kgs = "kubectl get svc";
};
```

**Example: Fast iteration**:
- Use `just` (command runner) for common tasks
- Create Makefile for project builds
- Use `direnv` for per-project environments

#### 7.7: Custom Code for Performance

**If needed**, write custom utilities:

**Example: Fast monitor switching**:

```go
// monitor-switcher/main.go
// Fast binary to switch KDE monitor profiles
package main

import (
    "os"
    "os/exec"
)

func main() {
    profile := os.Args[1]

    switch profile {
    case "docked":
        exec.Command("kscreen-doctor",
            "output.eDP-1.enable",
            "output.HDMI-1.enable",
            "output.DP-1.enable").Run()
    case "laptop":
        exec.Command("kscreen-doctor",
            "output.eDP-1.enable",
            "output.HDMI-1.disable",
            "output.DP-1.disable").Run()
    }
}
```

Build and install:
```bash
go build -o ~/bin/mon
# Usage: mon docked
#        mon laptop
```

#### 7.8: Continuous Performance Monitoring

**Set up monitoring**:
```bash
# Create systemd service to log performance
# ~/.config/systemd/user/perf-monitor.service

[Unit]
Description=Performance Monitor

[Service]
Type=oneshot
ExecStart=/home/mitsio/bin/log-perf.sh

[Install]
WantedBy=default.target
```

```bash
# ~/bin/log-perf.sh
#!/bin/bash
echo "$(date): CPU: $(top -bn1 | grep Cpu | awk '{print $2}')%, RAM: $(free -m | awk 'NR==2{print $3}')MB" >> ~/perf.log
```

**Analyze over time**:
```bash
# Plot performance graphs (optional)
# Use gnuplot or Python matplotlib
```

### Validation Checklist - Phase 7

- [ ] Optimization targets identified
- [ ] GPU passthrough tested (if applicable)
- [ ] Home-manager rebuild time improved
- [ ] X410 tuned for optimal performance
- [ ] Disk I/O optimized
- [ ] Development workflows optimized
- [ ] Custom code written (if needed)
- [ ] Performance monitoring in place
- [ ] Overall performance acceptable for daily use

### Q&A Round 7 - Phase 7

**Before proceeding to Phase 8:**

1. Performance now optimal?
2. Any remaining bottlenecks?
3. Custom code needed? (or is it overkill)
4. Ready to automate Windows 11 bootstrap?

### Phase 7 Documentation

**Create docs**:
- [ ] `docs/windows-base/wsl/performance-tuning-guide.md`
- [ ] Document GPU setup if configured
- [ ] Document custom utilities created

---

## Phase 8: Windows 11 Bootstrap Automation

**Goal**: Fully automate Windows 11 setup from clean install to working Kinoite WSL2 workspace.

**Duration**: 4-6 weeks

**Prerequisites**:
- Phases 1-7 complete (know what final state looks like)
- Windows 11 VM for testing (see Phase 9)

### Steps

#### 8.1: Research Windows 11 Dependencies

**Identify prerequisites**:

**Q&A Round 1 - Phase 8**:
Document all Windows 11 requirements:

- [ ] Windows 11 Pro version requirements (25H2 confirmed working)
- [ ] Features to enable:
  - [ ] WSL2
  - [ ] Virtual Machine Platform
  - [ ] Hyper-V (needed?)
- [ ] Firewall rules for X410
- [ ] Windows Defender exceptions (if needed)
- [ ] Power settings
- [ ] Network settings (proxy, VPN compatibility)

**Research**:
```bash
# Take Technical Researcher role
# Investigate:
# - Windows features for WSL2
# - X410 requirements
# - Network requirements
# - Security requirements
```

**Document findings**:
`docs/windows-base/windows11-prerequisites.md`

#### 8.2: Design Bootstrap Architecture

**Bootstrap stages**:

```
Stage 1: Manual Windows 11 Installation
├─ Install Windows 11 Pro from USB/ISO
├─ Complete OOBE (Out-of-Box Experience)
├─ Create user account
└─ Run Windows Update

Stage 2: PowerShell Bootstrap Script
├─ Enable WSL2 features
├─ Install Chocolatey
├─ Install Winget packages
├─ Install Git
├─ Clone my-modular-workspace
└─ Trigger Stage 3

Stage 3: Ansible Windows Configuration
├─ Run Ansible playbook from my-modular-workspace
├─ Configure Windows via DSC
├─ Install X410
├─ Configure .wslconfig
├─ Configure firewall rules
└─ Trigger Stage 4

Stage 4: WSL2 + Kinoite Setup
├─ Import Fedora Kinoite to WSL2
├─ Run Ansible playbook (Kinoite-side)
├─ Install Nix + home-manager
├─ Apply home-manager config
├─ Apply chezmoi dotfiles
└─ Configure KDE Plasma

Stage 5: Verification & Testing
├─ Launch X410
├─ Launch KDE Plasma
├─ Verify multi-monitor
├─ Run test suite
└─ Document any issues
```

#### 8.3: Create PowerShell Bootstrap Script

**Location**: `windows-base/bootstrap/bootstrap.ps1`

```powershell
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Bootstrap eyeonix-laptop Windows 11 + WSL2 + Fedora Kinoite workspace

.DESCRIPTION
    Fully automated setup from clean Windows 11 install to working Kinoite WSL2 workspace.

    Stages:
    1. Enable WSL2 features
    2. Install package managers (Chocolatey, Winget)
    3. Install essential tools (Git, Python, Ansible)
    4. Clone my-modular-workspace
    5. Hand off to Ansible for Windows config
    6. Hand off to Ansible for WSL2 config

.EXAMPLE
    .\bootstrap.ps1 -FullAuto

.EXAMPLE
    .\bootstrap.ps1 -StopAfterStage 2
#>

[CmdletBinding()]
param(
    [switch]$FullAuto,
    [int]$StopAfterStage = 99
)

$ErrorActionPreference = 'Stop'

# === Configuration ===
$RepoUrl = "https://github.com/dtsioumas/my-modular-workspace.git"
$RepoPath = "$env:USERPROFILE\my-modular-workspace"
$LogFile = "$env:USERPROFILE\bootstrap.log"

# === Functions ===
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

function Test-RebootRequired {
    # Check if reboot required
    return Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
}

# === Stage 1: Enable WSL2 ===
Write-Log "=== Stage 1: Enable WSL2 ==="

if (!(Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled') {
    Write-Log "Enabling WSL feature..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
}

if (!(Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq 'Enabled') {
    Write-Log "Enabling Virtual Machine Platform..."
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
}

if (Test-RebootRequired) {
    Write-Log "Reboot required. Please restart and re-run this script."
    if ($FullAuto) {
        Write-Log "Auto-reboot in 10 seconds..."
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
    exit 0
}

# Install WSL2 kernel update (if needed)
Write-Log "Installing WSL2..."
wsl --install --no-distribution
wsl --set-default-version 2

if ($StopAfterStage -eq 1) { exit 0 }

# === Stage 2: Install Package Managers ===
Write-Log "=== Stage 2: Install Package Managers ==="

# Install Chocolatey
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Install essential tools via Chocolatey
Write-Log "Installing essential tools..."
choco install -y `
    git `
    python3 `
    7zip `
    vim

# Refresh PATH again
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Python packages (including Ansible)
Write-Log "Installing Python packages..."
python -m pip install --upgrade pip
pip install ansible ansible-lint

if ($StopAfterStage -eq 2) { exit 0 }

# === Stage 3: Clone Repository ===
Write-Log "=== Stage 3: Clone Repository ==="

if (!(Test-Path $RepoPath)) {
    Write-Log "Cloning my-modular-workspace..."
    git clone $RepoUrl $RepoPath
} else {
    Write-Log "Repository already exists. Pulling latest..."
    Push-Location $RepoPath
    git pull
    Pop-Location
}

if ($StopAfterStage -eq 3) { exit 0 }

# === Stage 4: Run Ansible Windows Configuration ===
Write-Log "=== Stage 4: Run Ansible Windows Configuration ==="

Push-Location "$RepoPath\ansible"

Write-Log "Running Ansible playbook: windows-config.yml..."
ansible-playbook -i inventory.yml playbooks/windows-config.yml --ask-become-pass

Pop-Location

if ($StopAfterStage -eq 4) { exit 0 }

# === Stage 5: WSL2 + Kinoite Setup ===
Write-Log "=== Stage 5: WSL2 + Kinoite Setup ==="

Write-Log "Running WSL2 setup script..."
& "$RepoPath\windows-base\scripts\setup-wsl2-kinoite.ps1"

Write-Log "=== Bootstrap Complete! ==="
Write-Log "Next steps:"
Write-Log "1. Purchase X410 from Microsoft Store (if not already)"
Write-Log "2. Launch X410"
Write-Log "3. Run: wsl -d FedoraKinoite"
Write-Log "4. Inside WSL, run: startplasma-x11"
```

#### 8.4: Create Ansible Windows Configuration Playbook

**Location**: `ansible/playbooks/windows-config.yml`

```yaml
---
- name: Configure Windows 11 for WSL2 + Kinoite workspace
  hosts: localhost
  connection: local
  gather_facts: yes

  vars:
    wsl_distro_name: FedoraKinoite
    wsl_install_path: 'C:\WSL\FedoraKinoite'
    wslconfig_path: '{{ ansible_env.USERPROFILE }}\.wslconfig'

  tasks:
    # === Winget Packages ===
    - name: Install Winget applications
      win_command: 'winget install --id {{ item }} --silent --accept-package-agreements --accept-source-agreements'
      loop:
        - Anthropic.Claude
        - Mozilla.Firefox
        - KeePassXCTeam.KeePassXC
        - Microsoft.PowerToys
        - Microsoft.VisualStudioCode
      ignore_errors: yes  # Some may already be installed

    # === .wslconfig ===
    - name: Create .wslconfig
      win_copy:
        content: |
          [wsl2]
          memory=12GB
          processors=6
          swap=4GB
          localhostForwarding=true
          networkingMode=mirrored
          nestedVirtualization=false
          vmIdleTimeout=120000

          [experimental]
          autoMemoryReclaim=gradual
          sparseVhd=true
          dnsTunneling=true
          autoProxy=true
        dest: '{{ wslconfig_path }}'

    # === Windows Firewall (X410) ===
    - name: Configure Hyper-V firewall for WSL2
      win_shell: |
        Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultInboundAction Allow
      ignore_errors: yes  # May require manual run as admin

    # === DSC Configuration (optional) ===
    # TODO: Use DSC for more declarative Windows config
    # Examples: Registry settings, power plans, etc.

    # === Manual steps ===
    - name: Remind manual steps
      debug:
        msg: |
          Manual steps remaining:
          1. Install X410 from Microsoft Store ($9.99)
          2. Install Check Point VPN (corporate software)
          3. Install VMware Workstation (if needed)
          4. Configure Samsung utilities (if needed)
```

#### 8.5: Create Ansible Kinoite Configuration Playbook

**Location**: `ansible/playbooks/kinoite-setup.yml`

```yaml
---
- name: Configure Fedora Kinoite WSL2
  hosts: localhost
  connection: local
  gather_facts: yes

  vars:
    nix_installer_url: "https://install.determinate.systems/nix"

  tasks:
    # === Layer packages via rpm-ostree ===
    - name: Layer essential packages
      ansible.posix.rpm_ostree_pkg:
        name:
          - vim
          - git
          - htop
          - tmux
          - distrobox
          - socat
          - ansible
          - ansible-lint
        state: present
      become: yes
      notify: reboot-wsl

    # Flush handlers to reboot if needed
    - meta: flush_handlers

    # === Install Nix ===
    - name: Check if Nix is installed
      stat:
        path: /nix
      register: nix_installed

    - name: Install Nix
      shell: |
        curl --proto '=https' --tlsv1.2 -sSf -L {{ nix_installer_url }} | sh -s -- install --yes
      when: not nix_installed.stat.exists

    - name: Source Nix daemon
      shell: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      when: not nix_installed.stat.exists

    # === Install home-manager ===
    - name: Add Nix channels
      shell: |
        nix-channel --add https://nixos.org/channels/nixpkgs-unstable
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
      environment:
        PATH: "/nix/var/nix/profiles/default/bin:{{ ansible_env.PATH }}"

    - name: Install home-manager
      shell: nix-shell '<home-manager>' -A install
      environment:
        PATH: "/nix/var/nix/profiles/default/bin:{{ ansible_env.PATH }}"

    # === Apply home-manager config ===
    - name: Apply home-manager configuration
      shell: home-manager switch
      environment:
        PATH: "/nix/var/nix/profiles/default/bin:{{ ansible_env.PATH }}"

    # === Apply chezmoi dotfiles ===
    - name: Initialize chezmoi
      shell: |
        chezmoi init --apply {{ ansible_env.HOME }}/my-modular-workspace --source chezmoi
      environment:
        PATH: "/nix/var/nix/profiles/default/bin:{{ ansible_env.PATH }}"

    # === Configure X410 VSOCK ===
    - name: Create X410 VSOCK systemd service
      copy:
        content: |
          [Unit]
          Description=X410 VSOCK relay for WSL2
          After=network.target

          [Service]
          Type=forking
          ExecStart=/usr/bin/socat -b65536 UNIX-LISTEN:/tmp/.X11-unix/X0,fork,mode=777 VSOCK-CONNECT:2:6000
          Restart=on-failure
          RestartSec=5

          [Install]
          WantedBy=default.target
        dest: '{{ ansible_env.HOME }}/.config/systemd/user/x410-vsock.service'

    - name: Enable X410 VSOCK service
      systemd:
        name: x410-vsock
        enabled: yes
        state: started
        scope: user

  handlers:
    - name: reboot-wsl
      debug:
        msg: "Rebooting WSL required. Run: wsl --shutdown && wsl -d FedoraKinoite"
```

#### 8.6: Use DSC for Declarative Windows Config

**Research DSC (Desired State Configuration)**:

**Location**: `windows-base/dsc/WorkspaceConfig.ps1`

```powershell
Configuration WorkspaceConfig {
    param(
        [string]$ComputerName = "localhost"
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName {
        # === Windows Features ===
        WindowsOptionalFeature WSL {
            Name = "Microsoft-Windows-Subsystem-Linux"
            Ensure = "Present"
        }

        WindowsOptionalFeature VMP {
            Name = "VirtualMachinePlatform"
            Ensure = "Present"
        }

        # === Registry Settings ===
        Registry DisableTelemetry {
            Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
            ValueName = "AllowTelemetry"
            ValueData = 0
            ValueType = "Dword"
            Ensure = "Present"
        }

        # === Power Settings ===
        # TODO: Use cChoco DSC resource for power plan

        # === Files ===
        File WSLConfig {
            DestinationPath = "$env:USERPROFILE\.wslconfig"
            Contents = @"
[wsl2]
memory=12GB
processors=6
swap=4GB
localhostForwarding=true
networkingMode=mirrored
"@
            Ensure = "Present"
        }
    }
}

# Compile and apply
WorkspaceConfig -OutputPath "C:\DSC"
Start-DscConfiguration -Path "C:\DSC" -Wait -Verbose
```

#### 8.7: Integrate Chezmoi for Windows

**Use chezmoi to manage Windows configs too**:

**Add to chezmoi structure**:
```
chezmoi/home/
├── dot_gitconfig.tmpl        # Git (shared)
├── dot_bashrc.tmpl            # Linux only
│
└── AppData/                   # Windows only
    └── Local/
        └── Packages/
            └── Microsoft.WindowsTerminal_.../
                └── settings.json.tmpl
```

**In `.chezmoiignore`**:
```
# Ignore Linux-only on Windows
{{ if eq .chezmoi.os "windows" }}
.bashrc
.config/kde
{{ end }}

# Ignore Windows-only on Linux
{{ if eq .chezmoi.os "linux" }}
AppData
{{ end }}
```

**Apply on Windows**:
```powershell
# Install chezmoi on Windows
choco install chezmoi

# Apply dotfiles
chezmoi init --apply https://github.com/dtsioumas/my-modular-workspace.git --source chezmoi
```

#### 8.8: Test in Windows 11 VM (See Phase 9)

**Create test plan**:
- [ ] Create Windows 11 VM
- [ ] Run bootstrap.ps1
- [ ] Verify each stage
- [ ] Document issues
- [ ] Fix and iterate

### Validation Checklist - Phase 8

- [ ] Windows 11 prerequisites documented
- [ ] PowerShell bootstrap script created (bootstrap.ps1)
- [ ] Ansible Windows config playbook created
- [ ] Ansible Kinoite setup playbook created
- [ ] DSC configuration created (optional)
- [ ] Chezmoi Windows integration added
- [ ] Tested in Windows 11 VM (see Phase 9)
- [ ] Bootstrap completes without errors
- [ ] Working Kinoite WSL2 from clean install
- [ ] All automation documented

### Q&A Round 8 - Phase 8

**Before proceeding to Phase 9:**

1. Bootstrap automation tested successfully?
2. Any manual steps remaining?
3. Ready to set up CI/CD pipeline?

### Phase 8 Documentation

**Create docs**:
- [ ] `docs/windows-base/windows11-prerequisites.md`
- [ ] `docs/windows-base/bootstrap-guide.md`
- [ ] `windows-base/bootstrap/README.md`

---

## Phase 9: CI/CD Pipeline with Windows 11 VM

**Goal**: Establish CI/CD pipeline using Windows 11 VM to test workspace reproducibility.

**Duration**: 3-4 weeks

**Prerequisites**:
- Phase 8 complete (bootstrap automation ready)
- Windows 11 VM created and configured

### Steps

#### 9.1: Create Windows 11 Test VM

**Option A: Hyper-V** (if running on Windows Pro/Enterprise)

```powershell
# Create VM
New-VM -Name "WinTest-Kinoite" -MemoryStartupBytes 16GB -Generation 2 -BootDevice VHD

# Create virtual disk
New-VHD -Path "C:\Hyper-V\WinTest-Kinoite.vhdx" -SizeBytes 127GB -Dynamic

# Attach disk
Add-VMHardDiskDrive -VMName "WinTest-Kinoite" -Path "C:\Hyper-V\WinTest-Kinoite.vhdx"

# Configure CPU
Set-VMProcessor -VMName "WinTest-Kinoite" -Count 4

# Configure network
Add-VMNetworkAdapter -VMName "WinTest-Kinoite" -SwitchName "Default Switch"

# Attach Windows 11 ISO
Add-VMDvdDrive -VMName "WinTest-Kinoite" -Path "C:\ISOs\Windows11.iso"

# Start VM
Start-VM -Name "WinTest-Kinoite"
```

**Option B: VMware Workstation**

1. Create new VM
2. OS: Windows 11 (64-bit)
3. RAM: 16GB
4. Disk: 100GB (thin provisioned)
5. CPU: 4 cores
6. Network: NAT
7. Install Windows 11 from ISO

**Option C: VirtualBox**

Similar to VMware, but with VirtualBox settings.

**Q&A Round 1 - Phase 9**:
Which virtualization platform do you prefer?

#### 9.2: Install Windows 11 in VM

**Manual OOBE**:
1. Boot from Windows 11 ISO
2. Complete installation
3. Create user account: `testuser`
4. Skip Microsoft account (local account only)
5. Disable privacy settings
6. Complete setup

**After OOBE**:
```powershell
# Run Windows Update
# Settings → Windows Update → Check for updates

# Enable Remote Desktop (optional, for easier access)
# Settings → System → Remote Desktop → Enable
```

#### 9.3: Test Bootstrap Automation in VM

**In Windows 11 VM**:

```powershell
# 1. Open PowerShell as Administrator

# 2. Download bootstrap script
# Option A: Via Git (if internet access)
git clone https://github.com/dtsioumas/my-modular-workspace.git
cd my-modular-workspace\windows-base\bootstrap

# Option B: Copy from host (via shared folder)
# Setup shared folder in VM settings first

# 3. Run bootstrap
.\bootstrap.ps1 -FullAuto

# Or run in stages
.\bootstrap.ps1 -StopAfterStage 2
# Check Stage 2 result
.\bootstrap.ps1 -StopAfterStage 3
# Check Stage 3 result
# ... and so on
```

**Document results**:
- [ ] Stage 1: WSL2 features enabled? Reboot required?
- [ ] Stage 2: Chocolatey, Git, Python, Ansible installed?
- [ ] Stage 3: Repository cloned?
- [ ] Stage 4: Ansible Windows config applied?
- [ ] Stage 5: Kinoite WSL2 set up?

**Fix issues and iterate**:
- Update bootstrap script based on VM test results
- Commit fixes to repository
- Re-test in VM

#### 9.4: Create CI/CD Test Script

**Location**: `tests/integration/test-bootstrap.ps1`

```powershell
<#
.SYNOPSIS
    Integration test for Windows 11 + Kinoite WSL2 bootstrap

.DESCRIPTION
    Runs in Windows 11 VM, tests full bootstrap process, validates workspace.
#>

$ErrorActionPreference = 'Stop'

# === Configuration ===
$TestLogPath = "C:\TestResults"
$TestLogFile = "$TestLogPath\test-bootstrap-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

New-Item -ItemType Directory -Path $TestLogPath -Force | Out-Null

function Write-TestLog {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp [$Level] $Message"
    Write-Host $LogMessage
    $LogMessage | Out-File -FilePath $TestLogFile -Append
}

function Test-Step {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$Description
    )

    Write-TestLog "Testing: $Name" "TEST"
    Write-TestLog "  Description: $Description" "INFO"

    try {
        $Result = & $Test
        if ($Result) {
            Write-TestLog "  Result: PASS" "PASS"
            return $true
        } else {
            Write-TestLog "  Result: FAIL" "FAIL"
            return $false
        }
    } catch {
        Write-TestLog "  Result: ERROR - $_" "ERROR"
        return $false
    }
}

# === Tests ===
$AllPassed = $true

# Test 1: WSL2 installed
$AllPassed = $AllPassed -and (Test-Step -Name "WSL2 Installed" -Test {
    $wsl = Get-Command wsl -ErrorAction SilentlyContinue
    return $null -ne $wsl
} -Description "Check if wsl.exe is available")

# Test 2: Kinoite WSL distro exists
$AllPassed = $AllPassed -and (Test-Step -Name "Kinoite WSL Distro" -Test {
    $distros = wsl --list --quiet
    return $distros -contains "FedoraKinoite"
} -Description "Check if FedoraKinoite WSL distro is registered")

# Test 3: Kinoite is running
$AllPassed = $AllPassed -and (Test-Step -Name "Kinoite Running" -Test {
    $status = wsl -d FedoraKinoite -e echo "OK"
    return $status -eq "OK"
} -Description "Check if Kinoite can execute commands")

# Test 4: rpm-ostree shows Kinoite
$AllPassed = $AllPassed -and (Test-Step -Name "rpm-ostree Kinoite" -Test {
    $status = wsl -d FedoraKinoite -e rpm-ostree status
    return $status -match "kinoite"
} -Description "Check if rpm-ostree shows Kinoite deployment")

# Test 5: Nix installed
$AllPassed = $AllPassed -and (Test-Step -Name "Nix Installed" -Test {
    $version = wsl -d FedoraKinoite -e bash -c "nix --version 2>/dev/null"
    return $version -match "nix"
} -Description "Check if Nix is installed in Kinoite")

# Test 6: home-manager installed
$AllPassed = $AllPassed -and (Test-Step -Name "home-manager Installed" -Test {
    $version = wsl -d FedoraKinoite -e bash -c "home-manager --version 2>/dev/null"
    return $version -match "home-manager"
} -Description "Check if home-manager is installed")

# Test 7: chezmoi installed
$AllPassed = $AllPassed -and (Test-Step -Name "chezmoi Installed" -Test {
    $version = wsl -d FedoraKinoite -e bash -c "chezmoi --version 2>/dev/null"
    return $version -match "chezmoi"
} -Description "Check if chezmoi is installed")

# Test 8: X410 connection (manual verification)
Write-TestLog "Testing: X410 Connection (Manual)" "TEST"
Write-TestLog "  Please verify manually:" "INFO"
Write-TestLog "  1. X410 is running" "INFO"
Write-TestLog "  2. Run: wsl -d FedoraKinoite -e bash -c 'export DISPLAY=:0.0 && xclock'" "INFO"
Write-TestLog "  3. Clock window appears in X410" "INFO"
$XClockResult = Read-Host "Did clock window appear? (y/n)"
if ($XClockResult -eq "y") {
    Write-TestLog "  Result: PASS" "PASS"
} else {
    Write-TestLog "  Result: FAIL" "FAIL"
    $AllPassed = $false
}

# Test 9: KDE Plasma launch (manual verification)
Write-TestLog "Testing: KDE Plasma Launch (Manual)" "TEST"
Write-TestLog "  Please verify manually:" "INFO"
Write-TestLog "  1. Run: wsl -d FedoraKinoite -e bash -c 'export DISPLAY=:0.0 && startplasma-x11'" "INFO"
Write-TestLog "  2. KDE Plasma desktop appears" "INFO"
Write-TestLog "  3. Can interact with desktop" "INFO"
$PlasmaResult = Read-Host "Did KDE Plasma launch successfully? (y/n)"
if ($PlasmaResult -eq "y") {
    Write-TestLog "  Result: PASS" "PASS"
} else {
    Write-TestLog "  Result: FAIL" "FAIL"
    $AllPassed = $false
}

# === Summary ===
Write-TestLog "=== Test Summary ===" "INFO"
if ($AllPassed) {
    Write-TestLog "All tests PASSED!" "PASS"
    exit 0
} else {
    Write-TestLog "Some tests FAILED. Check log for details." "FAIL"
    exit 1
}
```

#### 9.5: Snapshot VM After Successful Bootstrap

**Create VM snapshots**:

**Hyper-V**:
```powershell
Checkpoint-VM -Name "WinTest-Kinoite" -SnapshotName "Bootstrap-Complete-Clean"
```

**VMware**:
```
VM → Snapshot → Take Snapshot
Name: "Bootstrap Complete Clean"
Description: "After successful bootstrap, before any usage"
```

**VirtualBox**:
```
Machine → Take Snapshot
Name: "Bootstrap Complete Clean"
```

**Purpose**: Quick rollback for re-testing.

#### 9.6: Create CI/CD Pipeline (Optional Advanced)

**Goal**: Automate testing in VM on every commit.

**Options**:

**Option A: GitHub Actions with Hosted Runner**

Challenge: Need self-hosted runner with nested virtualization support.

**Option B: GitLab CI with Self-Hosted Runner**

Similar to GitHub Actions.

**Option C: Jenkins on Local Machine**

```groovy
// Jenkinsfile
pipeline {
    agent any

    stages {
        stage('Revert VM to Clean Snapshot') {
            steps {
                script {
                    powershell '''
                        Restore-VMSnapshot -VMName "WinTest-Kinoite" -Name "Bootstrap-Complete-Clean" -Confirm:$false
                        Start-VM -Name "WinTest-Kinoite"
                        Start-Sleep -Seconds 60  # Wait for boot
                    '''
                }
            }
        }

        stage('Run Bootstrap in VM') {
            steps {
                script {
                    powershell '''
                        # TODO: Remote execution in VM
                        # Copy latest code to VM
                        # Run bootstrap script
                    '''
                }
            }
        }

        stage('Run Integration Tests') {
            steps {
                script {
                    powershell '''
                        # TODO: Run test-bootstrap.ps1 in VM
                        # Collect results
                    '''
                }
            }
        }
    }

    post {
        always {
            powershell '''
                Stop-VM -Name "WinTest-Kinoite" -Force
            '''
        }
    }
}
```

**Decision**: Implement CI/CD pipeline is **optional** and **advanced**. May be overkill for personal workspace. Consider manual testing in VM instead.

**Q&A Round 2 - Phase 9**:
Do you want full CI/CD automation, or is manual VM testing sufficient?

#### 9.7: Create Test Documentation

**Location**: `tests/integration/README.md`

**Content**:
```markdown
# Integration Tests for Windows 11 + Kinoite WSL2 Bootstrap

## Prerequisites

- Windows 11 VM with clean install
- VM snapshot named "Bootstrap-Complete-Clean"
- my-modular-workspace repository cloned

## Running Tests

### Manual Testing

1. Revert VM to clean snapshot
2. Boot VM
3. Run bootstrap script:
   ```powershell
   .\bootstrap.ps1 -FullAuto
   ```
4. Run integration test script:
   ```powershell
   .\tests\integration\test-bootstrap.ps1
   ```
5. Review test log in `C:\TestResults\`

### Automated Testing (Optional)

See Jenkins pipeline configuration in `Jenkinsfile`.

## Test Cases

1. WSL2 installation
2. Kinoite WSL2 import
3. Nix installation
4. home-manager setup
5. chezmoi initialization
6. X410 connectivity
7. KDE Plasma launch
8. Multi-monitor configuration

## Troubleshooting

See `docs/windows-base/bootstrap-guide.md`
```

#### 9.8: Consider New CI/CD Orchestrator Repo

**User mentioned**: "We could possibly make a new repo for CI/CD as main repo/orchestrator for modular-workspace project."

**Options**:

**Option A: New repo `workspace-orchestrator`**

```
workspace-orchestrator/
├── .github/
│   └── workflows/
│       └── test-bootstrap.yml
├── jenkins/
│   └── Jenkinsfile
├── vms/
│   ├── windows11/
│   │   ├── Vagrantfile
│   │   └── provision.ps1
│   └── nixos/  # For testing shoshin configs
│       └── Vagrantfile
├── tests/
│   └── integration/
│       ├── test-windows-bootstrap.ps1
│       └── test-nixos-rebuild.sh
└── README.md
```

**Option B: Keep in my-modular-workspace**

Add CI/CD to existing repo:
```
my-modular-workspace/
├── .github/workflows/
├── ci/
└── tests/
```

**Q&A Round 3 - Phase 9**:
Separate orchestrator repo or keep in my-modular-workspace?

### Validation Checklist - Phase 9

- [ ] Windows 11 VM created
- [ ] Bootstrap tested in VM
- [ ] Integration test script created
- [ ] All tests pass in VM
- [ ] VM snapshot created (clean bootstrap state)
- [ ] CI/CD pipeline implemented (optional)
- [ ] Test documentation created
- [ ] Decision made on orchestrator repo

### Q&A Round 9 - Phase 9

**After Phase 9:**

1. CI/CD setup satisfactory?
2. Manual testing sufficient, or need automation?
3. Separate orchestrator repo?
4. Ready for technical validation of entire plan?

### Phase 9 Documentation

**Create docs**:
- [ ] `tests/integration/README.md`
- [ ] `docs/windows-base/vm-testing-guide.md`
- [ ] Document CI/CD pipeline (if implemented)

---

## Technical Validation & Review

**After all phases planned**, perform technical validation:

### Validation Round 1: Technical Researcher Review

**Take Technical Researcher role**:

**Review plan for**:
- [ ] Technical feasibility of each phase
- [ ] Identify technical assumptions that need validation
- [ ] Find potential technical issues or blockers
- [ ] Identify missing technical resources or dependencies
- [ ] Check for discrepancies between phases
- [ ] Verify all technical documentation references are valid

**Document findings**:
`docs/windows-base/wsl/plan-technical-review.md`

### Validation Round 2: Ultrathink Synthesis

**Perform ultrathink session**:

**Questions to answer**:
1. Is the plan technically complete?
2. Are all phases properly sequenced?
3. Are validation checkpoints sufficient?
4. Are Q&A rounds well-placed?
5. Is timeline realistic (3-6 months)?
6. Are documentation requirements clear?
7. Are there any circular dependencies between phases?
8. Is rollback strategy defined?

**Output**: Validated, complete plan

### Validation Round 3: Planner Review

**Take Planner role again**:

**Review for**:
- [ ] All documentation references valid
- [ ] Paths correct (local and relative)
- [ ] No discrepancies between phases
- [ ] All prerequisites clearly stated
- [ ] Success criteria measurable
- [ ] Risk assessment comprehensive

**Perform ultrathink in parallel** to validate all aspects.

### Validation Round 4: Find Additional Context

**Take Technical Researcher role**:

**Investigate workspace for**:
- [ ] Existing configs that are dependencies (e.g., rclone configs, KeePassXC setup)
- [ ] Software dependencies not yet documented
- [ ] Windows features required but not mentioned
- [ ] Hardware-specific requirements (Samsung Galaxy Book)

**Update plan with findings**.

---

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Kinoite WSL2 instability | Medium | High | Test in VM first, maintain backup, document issues |
| X410 performance issues | Low | Medium | VSOCK method, test in VM, VcXsrv fallback |
| Home-manager conflicts | Low | Medium | Follow ADR-005, test in isolation |
| Multi-monitor issues | Medium | Medium | Manual configuration, create scripts |
| Bootstrap automation failure | Medium | High | Incremental testing, snapshots, rollback plan |
| Windows 11 update breaks WSL2 | Low | High | Test in VM before applying to production |
| GPU passthrough issues | Medium | Low | Phase 7 optional, graceful degradation |
| Time overrun (>6 months) | Medium | Low | MVP-first, flexible timeline |

### Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Work disruption | High if rushed | Critical | Do migration on weekends, have backup system |
| Data loss | Very Low | Critical | Google Drive sync, regular backups, test recovery |
| Corporate policy violation | Low | High | Keep work software separate, document boundaries |
| Learning curve | High | Medium | Take time, document learnings, ask questions |

### Mitigation Strategies

1. **Test everything in VM before production**
2. **Backup before each major phase**
3. **Document issues and solutions**
4. **Have rollback plan for each phase**
5. **No rush - take 3-6 months as needed**
6. **Q&A rounds between phases for course correction**
7. **Ultrathink sessions for validation**

---

## Success Criteria

### Phase-by-Phase Success

Each phase must meet its validation checklist before proceeding.

### Overall Success Criteria

**Minimum (MVP)**:
- [ ] Kinoite WSL2 running stably
- [ ] Home-manager managing packages
- [ ] KDE Plasma usable via X410
- [ ] Basic multi-monitor working
- [ ] Daily development work possible

**Target (Complete)**:
- [ ] All 9 phases complete
- [ ] Performance optimized
- [ ] Fully automated bootstrap
- [ ] Tested in Windows 11 VM
- [ ] Documentation complete
- [ ] CI/CD pipeline (optional)

**Stretch (Advanced)**:
- [ ] GPU fully utilized
- [ ] Custom optimizations implemented
- [ ] Workspace shared with shoshin
- [ ] CI/CD fully automated

---

## Related Documentation

### Research Documents (Created During Session)

- [rpm-ostree-nix-homemanager-integration.md](./rpm-ostree-nix-homemanager-integration.md)
- [wsl2-networking-x410-optimization.md](./wsl2-networking-x410-optimization.md)
- [chezmoi-integration-strategy.md](./chezmoi-integration-strategy.md)

### Existing Project Documentation

- [docs/windows-base/README.md](../README.md)
- [docs/windows-base/INDEX.md](../INDEX.md)
- [docs/windows-base/ARCHITECTURE.md](../ARCHITECTURE.md)
- [docs/windows-base/FEDORA-KINOITE-WSL2.md](../FEDORA-KINOITE-WSL2.md)
- [docs/windows-base/BOOTSTRAP-GUIDE.md](../BOOTSTRAP-GUIDE.md)
- [docs/windows-base/GRAPHICAL-INTEGRATION-OVERVIEW.md](../GRAPHICAL-INTEGRATION-OVERVIEW.md)
- [docs/windows-base/TECHNICAL-ANALYSIS.md](../TECHNICAL-ANALYSIS.md)

### Architecture Decision Records (ADRs)

- [ADR-001: NixOS Stable vs Home-Manager Unstable](../../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md)
- [ADR-002: Ansible Handles RClone Sync Job](../../adrs/ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md)
- [ADR-005: Chezmoi Migration Criteria](../../adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md)

### To Be Created During Implementation

- `docs/windows-base/windows11-prerequisites.md` (Phase 8)
- `docs/windows-base/windows11-desired-state.md` (Phase 5)
- `docs/windows-base/workspace-boundaries.md` (Phase 5)
- `docs/windows-base/bootstrap-guide.md` (Phase 8)
- `docs/windows-base/vm-testing-guide.md` (Phase 9)
- `docs/windows-base/wsl/performance-tuning-guide.md` (Phase 7)
- `docs/windows-base/wsl/plan-technical-review.md` (Validation)
- `docs/CONFIG_OWNERSHIP.md` (Phase 6)
- `tests/integration/README.md` (Phase 9)
- Session notes for each phase: `sessions/wsl-kinoite-integration/phase{1-9}-notes.md`

---

## Next Steps (After This Planning Session)

### Immediate (This Session)

1. **[Technical Researcher]** Review this plan for technical issues
   - Identify technical assumptions
   - Find discrepancies
   - Identify missing resources
   - Document findings in `plan-technical-review.md`

2. **[Ultrathink]** Validate plan completeness
   - Is plan technically sound?
   - Are all phases properly sequenced?
   - Are timelines realistic?
   - Document synthesis in plan review

3. **[Planner]** Final validation
   - Check all documentation references
   - Verify paths (local and relative)
   - Check for discrepancies
   - Perform ultrathink in parallel
   - Finalize plan

4. **[Technical Researcher]** Investigate workspace dependencies
   - Find existing configs that are dependencies
   - Identify Windows features needed for WSL + X410
   - Document how to bootstrap Windows with Ansible
   - Research DSC, choco, winget for declarative Windows
   - Research Ansible bootstrap for WSL
   - **Goal**: Fully declarative, reproducible, testable in VM

5. **Update documentation** with additional research findings

### Week 1 (After Session)

- [ ] User reviews plan
- [ ] User provides feedback / asks questions
- [ ] Adjust plan based on feedback
- [ ] Create `sessions/wsl-kinoite-integration/` directory structure
- [ ] Begin Phase 1 when ready

### Phase 1 Start (User Decision)

- [ ] Backup current Ubuntu WSL (if desired)
- [ ] Clean up existing WSL distributions
- [ ] Begin Kinoite import process
- [ ] Follow Phase 1 steps in this plan

---

**Plan Version**: 1.0
**Last Updated**: 2025-12-18
**Author**: Claude Code (Planner + Technical Researcher Roles)
**Status**: Planning Complete - Awaiting Technical Validation

---

**Action Confidence Summary:**

| Plan Aspect | Confidence | Notes |
|-------------|------------|-------|
| Phase 1-3 (MVP) | 0.90 | Well-researched, proven approach |
| Phase 4 (Performance) | 0.85 | Some hardware-specific unknowns |
| Phase 5 (Boundaries) | 0.80 | Requires user input |
| Phase 6 (Chezmoi) | 0.90 | Clear strategy, proven tool |
| Phase 7 (Advanced) | 0.75 | Some aspects experimental |
| Phase 8 (Bootstrap) | 0.85 | Complex but achievable |
| Phase 9 (CI/CD) | 0.80 | VM testing proven, full CI/CD optional |
| Overall Plan | 0.85 | Solid foundation, some unknowns normal |

---

**Time**: 2025-12-18T18:30:00+02:00 (Europe/Athens)
**Tokens**: in≈123k, out≈15k, total≈138k, usage≈69% of context
