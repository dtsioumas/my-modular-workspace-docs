# Firefox Declarative Configuration

**Status**: ✅ Active (Migrated 2025-12-14)
**Configuration**: `home-manager/firefox.nix`
**Backup**: `~/Local_Backups/firefox-backup-20251214/`

---

## Quick Reference

### Rebuild Firefox Config
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
home-manager switch --flake .#mitsio@shoshin
```

### Add New Extension
1. Find extension ID from addons.mozilla.org
2. Edit `firefox.nix`, add to `ExtensionSettings`:
```nix
"extension-id@example.com" = {
  install_url = "https://addons.mozilla.org/firefox/downloads/latest/extension-name/latest.xpi";
  installation_mode = "force_installed";
};
```
3. Rebuild: `home-manager switch --flake .#mitsio@shoshin`

### Check GPU Acceleration
```bash
# Open Firefox and navigate to:
about:support

# Look for:
# - Compositing: WebRender
# - GPU #1 Active: Yes
# - GPU #1 Description: NVIDIA <your-model>
```

---

## Current Configuration

### Extensions (9 installed declaratively)
- **uBlock Origin** - Ad blocker
- **Sidebery** - Vertical tabs (PRIMARY)
- **KeePassXC-Browser** - Password manager
- **Bitwarden** - Password manager (backup)
- **Plasma Integration** - KDE Desktop integration
- **Floccus** - Bookmark sync
- **Default Bookmark Folder** - Bookmark management
- **Multi-Account Containers** - Container management
- **FireShot** - Full page screenshots

### GPU Acceleration
- **Enabled**: NVIDIA hardware acceleration (X11)
- **Session Variables**:
  - `MOZ_USE_XINPUT2=1` (smooth scrolling)
  - `MOZ_WEBRENDER=1` (GPU rendering)
- **Settings**:
  - VA-API video decoding
  - WebRender compositing
  - Canvas acceleration

### Memory/CPU Optimization
- **RAM Cache**: 512MB
- **Disk Cache**: 350MB
- **Content Processes**: 4
- **Tab Unloading**: Enabled on low memory

### UI Customization
- **Vertical Tabs**: Sidebery with hidden native tab bar
- **userChrome.css**: Managed in home-manager
- **Search Engine**: Google
- **Bookmarks Toolbar**: Always visible

### Sync & Privacy
- **Firefox Sync**: Enabled (bookmarks, history, open tabs)
- **Add-on Sync**: DISABLED (managed declaratively)
- **Telemetry**: Disabled
- **Tracking Protection**: Enabled (strict)
- **Credentials**: Stored in KeePassXC (`~/MyVault/`)

---

## Architecture

```
home-manager/firefox.nix
├── Package: Firefox 146.0
├── Policies (Enterprise)
│   ├── Extension Management
│   ├── Telemetry/Privacy
│   └── Sync Settings
├── Profile: default
│   ├── Settings (about:config)
│   ├── Search Engine
│   └── userChrome.css
└── Session Variables (X11/NVIDIA)
```

**Key Decisions**:
- Extensions: Enterprise Policies (NOT NUR)
- Display Server: X11 (for NVIDIA compatibility)
- userChrome.css: Home-manager (exception to ADR-009)
- Secrets: KeePassXC vault integration

---

## Troubleshooting

### Extensions Not Auto-Enabling
Check `extensions.autoDisableScopes = 0` in about:config:
```bash
# Navigate to about:config in Firefox
# Search: extensions.autoDisableScopes
# Expected: 0 (zero)
```

### Native Tab Bar Still Visible
userChrome.css not applied:
```bash
# Verify file exists
ls ~/.mozilla/firefox/*/chrome/userChrome.css

# Clear cache and restart
pkill firefox
rm -rf ~/.mozilla/firefox/*/startupCache/
firefox &
```

### GPU Acceleration Not Working
Check session variables:
```bash
env | grep -E 'LIBVA|GBM|GLX|MOZ'

# Expected:
# LIBVA_DRIVER_NAME=nvidia
# GBM_BACKEND=nvidia-drm
# __GLX_VENDOR_LIBRARY_NAME=nvidia
# MOZ_USE_XINPUT2=1
# MOZ_WEBRENDER=1
```

### KeePassXC-Browser Won't Connect
```bash
# 1. Verify KeePassXC is running
pgrep -a keepassxc

# 2. Check browser integration enabled
# Open KeePassXC → Settings → Browser Integration → Enable Firefox

# 3. Verify native messaging manifest
cat ~/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json
```

---

## Rollback

### Rollback to Previous Generation
```bash
home-manager generations
home-manager rollback --to <generation-number>
```

### Emergency Profile Restore
```bash
pkill firefox
rm -rf ~/.mozilla/firefox/default
cp -r ~/Local_Backups/firefox-backup-20251214 ~/.mozilla/firefox/default
firefox &
```

---

## Related Documentation

- **Implementation Plan**: `docs/plans/2025-12-14-firefox-declarative-implementation-plan.md`
- **Research**: `docs/researches/2025-12-14_FIREFOX_DECLARATIVE_CONFIGURATION_RESEARCH.md`
- **Troubleshooting**: `docs/firefox/TROUBLESHOOTING.md`
- **ADR-009**: Bash Shell Enhancement Configuration (userChrome.css exception)
- **ADR-011**: Unified Secrets Management via KeePassXC

---

**Last Updated**: 2025-12-15
**Maintainer**: Mitsio (Dimitris Tsioumas)
