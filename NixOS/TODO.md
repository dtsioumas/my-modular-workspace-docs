# NixOS Configuration - TODO List

**Project**: mitsio-workspaces-project-shoshin-workspace  
**Last Updated**: 2025-11-13  
**Token Usage**: 160,800 / 200,000 (80.4% used)

---

## 🔴 CRITICAL - Fix Before Next Session

### Build Errors to Resolve
- [ ] Fix any remaining plasma-manager configuration errors
- [ ] Test successful `nixos-rebuild switch`
- [ ] Verify all declarative settings apply correctly after rebuild

---

## 🟡 HIGH PRIORITY - Immediate Next Steps

### System Verification (After Successful Rebuild)
- [ ] Verify GoogleDrive mount is working (`/home/mitso/GoogleDrive`)
- [ ] Test all 10 symbolic links from home directory to GoogleDrive
- [ ] Verify rclone service status and remote name
- [ ] Check KeePassXC autostart on login
- [ ] Verify KeePassXC Secret Service integration
- [ ] Test Dolphin settings (split view, details mode, hidden files)
- [ ] Verify plasma desktop settings (6 virtual desktops with underscores, Nordic theme)

### Secrets Management
- [ ] **Install and configure sops-nix**
- [ ] Research sops-nix integration with NixOS
- [ ] Setup age key generation for sops
- [ ] Create `.sops.yaml` configuration file
- [ ] Migrate sensitive secrets to sops-encrypted files
- [ ] Configure sops-nix to decrypt secrets at boot/activation
- [ ] Document sops-nix workflow for secret management

### Bitwarden Setup
- [ ] Add Bitwarden GUI to system packages
- [ ] Install Bitwarden desktop application
- [ ] Configure Bitwarden CLI (bitwarden-cli package)
- [ ] Setup Bitwarden CLI login and session management
- [ ] Configure secrets integration for:
  - rclone configuration
  - Dropbox login
  - Brave browser credentials
- [ ] Evaluate sops-nix vs Bitwarden for different secret types

### Ephemeral Secrets Configuration
- [ ] Research tmpfs-based secret storage
- [ ] Create `/run/secrets/` or similar tmpfs mount
- [ ] Configure secrets to be written to tmpfs on login
- [ ] Setup automatic cleanup on reboot
- [ ] Document secret rotation workflow

### KeePass Database Symlink
- [ ] Verify Dropbox path: `/home/mitso/Dropbox/Apps/Keepass2Android (1)/mitsio_secrets.kdbx`
- [ ] Create GoogleDrive target directory: `/home/mitso/GoogleDrive/Sensitive_Files/`
- [ ] Create symbolic link (or copy?) between Dropbox and GoogleDrive
- [ ] Configure KeePassXC to use GoogleDrive location
- [ ] Test database sync between locations

---

## 🟢 MEDIUM PRIORITY - Next Session Tasks

### KDE-Services Plugin Installation
- [ ] Install dependencies already configured in `dolphin-service-menus.nix`
- [ ] Install KDE-Services plugin via Dolphin UI:
  - Settings → Configure → Context Menu → Download New Services
  - Search "KDE-Services" → Install
- [ ] Test service menu functionality
- [ ] Document which features are most useful

### Kitty Terminal Configuration
- [ ] Find kitty configs in GoogleDrive: `/home/mitso/GoogleDrive/common-home-dirs/kitty-emulator/`
- [ ] Review existing kitty configuration files
- [ ] Create declarative kitty configuration in NixOS
- [ ] Migrate color schemes, fonts, keybindings
- [ ] Test kitty functionality (transparency, ligatures, etc.)

### Clipboard Enhancement
- [ ] Research KDE Plasma clipboard managers (Klipper)
- [ ] Evaluate clipboard history features
- [ ] Configure clipboard sync between X11 and Wayland
- [ ] Setup clipboard history size and retention
- [ ] Add custom clipboard actions/scripts
- [ ] Configure clipboard security (don't save passwords)
- [ ] Test clipboard persistence across sessions

### Taskbar Customization
- [ ] Review current panel configuration in plasma.nix
- [ ] Research additional panel widgets
- [ ] Configure system tray icon visibility
- [ ] Setup panel auto-hide behavior (if desired)
- [ ] Configure panel opacity and styling
- [ ] Add/remove widgets as needed

### Polonium Tiling Window Manager
- [ ] **Install Polonium KWin script**
- [ ] Research Polonium vs native KWin tiling
- [ ] Configure Polonium tiling layouts
- [ ] Setup Polonium keyboard shortcuts
- [ ] Test Polonium with 6 virtual desktops
- [ ] Configure per-desktop tiling behavior
- [ ] Document Polonium workflows and features
- [ ] Evaluate Polonium impact on system performance

### Plasma Widgets
- [ ] **Research and add useful Plasma widgets**
- [ ] Explore KDE Store for widget recommendations
- [ ] Install system monitoring widgets (CPU, RAM, network)
- [ ] Add weather widget (if useful)
- [ ] Calendar/agenda widget configuration
- [ ] Media player control widget
- [ ] Configure widget placement on panels/desktop
- [ ] Test widget performance and resource usage

### Polybar Investigation
- [ ] Research Polybar vs KDE Plasma panels
- [ ] Determine if Polybar works with Plasma/KWin
- [ ] Evaluate benefits of Polybar over Plasma panels
- [ ] Document Polybar installation for NixOS
- [ ] Create sample Polybar configuration
- [ ] Test Polybar with current Plasma setup
- [ ] **Decision needed**: Keep Plasma panels or migrate to Polybar?

---

## 🔵 LOW PRIORITY - Future Enhancements

### KDE Activities Deep Dive
- [ ] **Research**: What are KDE Activities?
- [ ] **Understand**: How Activities differ from Virtual Desktops
- [ ] **Explore**: Activity-specific settings and configurations
- [ ] **Check current activity**: How to see which activity is active
- [ ] **Learn**: Activity switcher and management tools
- [ ] **Evaluate**: Use cases for multiple activities
- [ ] **Consider**: Should we configure activities declaratively?
- [ ] **Resources**:
  - KDE Activities documentation
  - Example use cases (Work/Personal/Gaming activities)
  - Activity-specific wallpapers, panels, widgets
  - Activity-based window management rules

### Plasma Widget Exploration
- [ ] Research available Plasma widgets
- [ ] Find widgets for system monitoring
- [ ] Evaluate weather widgets
- [ ] Check calendar/agenda widgets
- [ ] Test note-taking widgets

### Advanced KeePassXC Integration
- [ ] Setup KeePassXC browser extension in Brave (manual step)
- [ ] Configure Brave to disable built-in password manager
- [ ] Test KeePassXC auto-fill functionality
- [ ] Setup KeePassXC SSH agent integration
- [ ] Configure KeePassXC auto-type rules

### Additional Dolphin Service Menus
- [ ] Create custom service menus for common tasks
- [ ] Add "Open in VSCode" context menu
- [ ] Add "Copy path" service menu
- [ ] Add custom compression options
- [ ] Add custom sync/backup actions

### VeraCrypt Integration
- [ ] Add VeraCrypt package to system packages
- [ ] Install VeraCrypt GUI application
- [ ] Configure VeraCrypt for directory encryption
- [ ] Create encrypted volume for sensitive data
- [ ] Document VeraCrypt workflow and best practices
- [ ] Setup auto-mount for VeraCrypt volumes (if desired)
- [ ] Test VeraCrypt integration with file managers

### Theme and Appearance
- [ ] Find more Nordic theme components
- [ ] Setup consistent GTK theme for non-KDE apps
- [ ] Configure icon theme exceptions
- [ ] Setup custom window decoration rules
- [ ] Create consistent color scheme across all apps
- [ ] **Configure rounded window corners** on all 4 corners
- [ ] Research KWin window decoration options for rounded corners
- [ ] Find or create Nordic-compatible rounded corner theme

---

## 📚 DOCUMENTATION TO CREATE

### Guides Needed
- [ ] KDE Activities explanation and configuration guide
- [ ] Bitwarden CLI workflow documentation
- [ ] Ephemeral secrets management guide
- [ ] Clipboard management best practices
- [ ] Taskbar vs Polybar comparison document
- [ ] KDE-Services features reference
- [ ] Complete keyboard shortcuts reference

### Configuration Maps
- [ ] Map of all declarative vs manual settings
- [ ] Dependency tree of NixOS modules
- [ ] Service startup order documentation
- [ ] Secrets management flow diagram

---

## ❓ QUESTIONS FOR NEXT SESSION

### KDE Activities
1. What exactly are KDE Activities?
2. How do Activities differ from Virtual Desktops?
3. Which Activity am I currently in?
4. Should I configure different activities for different workflows?
5. Can Activities have different panels/widgets?
6. Are Activities useful for desktop/laptop workflow separation?

### Polybar
1. Can Polybar replace KDE Plasma panels?
2. Will Polybar work with KWin window manager?
3. What are the advantages of Polybar over Plasma panels?
4. How to configure Polybar declaratively in NixOS?
5. Can I use both Plasma panels and Polybar simultaneously?

### Clipboard
1. What clipboard manager is currently active? (Klipper?)
2. How to configure clipboard history size?
3. Can clipboard sync between X11 apps and Wayland?
4. How to prevent sensitive data from being saved in clipboard?
5. Can clipboard history persist across reboots?

### General
1. Should mouse configuration be added to files module?
2. Are there other plasma-manager options we're missing?
3. How to check which KDE Store plugins are installed?
4. Best practices for managing secrets in NixOS?

---

## ✅ COMPLETED IN THIS SESSION

### Plasma-Manager Migration
- [x] Migrated all kwinrc settings to declarative API
- [x] Changed all virtual desktop names to use underscores
- [x] Renamed Desktop 2 to "Mitsio_Workspaces_Project"
- [x] Fixed theme consistency (Nordic-darker icons, nordicbluish colors)
- [x] Configured night light (automatic, 4500K)
- [x] Setup window tiling (4px padding)
- [x] Added screen locker configuration
- [x] Added window position memory
- [x] Fixed power management (powerdevil structure)
- [x] Added lock screen wallpaper configuration

### Dolphin Configuration
- [x] Analyzed actual Dolphin usage from screenshot
- [x] Changed view mode to Details (was Icons)
- [x] Enabled show hidden files (was disabled)
- [x] Enabled split view by default
- [x] Configured all confirmation dialogs
- [x] Disabled all telemetry (9 data sources)
- [x] Added menu bar, toolbar, and panel configurations
- [x] Created dolphin-service-menus.nix for dependencies

### KeePassXC Setup
- [x] Disabled KWallet in favor of KeePassXC
- [x] Configured Secret Service integration
- [x] Enabled browser integration
- [x] Setup auto-lock (5 min idle, screen lock)
- [x] Created XDG autostart desktop file
- [x] Documented browser extension installation steps

### Documentation Created
- [x] COMPLETE_MIGRATION_SUMMARY.md
- [x] MIGRATION_ANALYSIS.md  
- [x] SETTINGS_COMPARISON.md
- [x] KEEPASSXC_INTEGRATION_GUIDE.md
- [x] DOLPHIN_CONFIGURATION.md
- [x] PLASMA_MANAGER_STATUS.md

### Session Management
- [x] Saved session state to thread continuity MCP
- [x] Created comprehensive TODO.md (this file)

---

## 🎯 SUCCESS CRITERIA

### For Next Session Start
- [ ] NixOS rebuild completes successfully
- [ ] All plasma settings apply correctly
- [ ] GoogleDrive mounts automatically
- [ ] KeePassXC starts and unlocks
- [ ] Dolphin shows correct settings
- [ ] No configuration errors in logs

### For Project Completion
- [ ] All settings declaratively managed
- [ ] Secrets properly secured (ephemeral + Bitwarden)
- [ ] All documentation complete and accurate
- [ ] System reproducible from configuration alone
- [ ] User workflow optimized and efficient

---

## 📊 PROJECT METRICS

- **Total Files Modified**: 7
- **Configuration Lines**: ~500+
- **Documentation Pages**: 6
- **Settings Migrated**: ~95% declarative
- **Build Attempts**: Multiple (fixing plasma-manager API issues)
- **Session Duration**: Extended (complex migration)

---

## 🔗 QUICK REFERENCES

### Important Paths
- Config: `~/.config/nixos/home/mitso/plasma.nix`
- Modules: `~/.config/nixos/modules/workspace/`
- Docs: `~/.config/nixos/docs/`
- Wallpapers: `~/Pictures/wallpapers/`
- GoogleDrive: `/home/mitso/GoogleDrive/`

### Key Commands
```bash
# Rebuild system
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin

# Check services
systemctl --user status rclone-gdrive
systemctl --user status keepassxc

# View current activity (KDE)
qdbus org.kde.ActivityManager /ActivityManager/Activities CurrentActivity

# List all activities
qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities

# Git operations
cd ~/.config/nixos
git status
git add .
git commit -m "Plasma configuration migration"
```

### Documentation Locations
- Plasma-Manager: `~/.config/nixos/docs/plasma-manager/`
- KeePassXC Guide: `~/.config/nixos/docs/KEEPASSXC_INTEGRATION_GUIDE.md`
- Dolphin Config: `~/.config/nixos/docs/DOLPHIN_CONFIGURATION.md`

---

**End of TODO List**  
Resume session with: `load the session mitsio-workspaces-project-shoshin-workspace through continuity mcp`
