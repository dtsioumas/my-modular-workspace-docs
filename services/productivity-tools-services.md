# Productivity Tools - Systemd Services

**Date:** 2025-12-12
**Module:** `home-manager/productivity-tools-services.nix`
**Status:** ✅ Ready for deployment

---

## Overview

Systemd services for productivity tools with automatic restart and monitoring. All application configs managed via chezmoi.

### Services Managed

1. **Atuin** - Shell history sync daemon
2. **CopyQ** - Advanced clipboard manager (replaces Klipper)
3. **Flameshot** - Screenshot tool (replaces Spectacle)

---

## Services Created

### Primary Services

1. **atuin-sync.service**
   - Background sync daemon for shell history
   - Resource limits: 256M RAM, 10% CPU
   - Config: `~/.config/atuin/config.toml` (chezmoi)

2. **copyq.service**
   - Clipboard manager daemon
   - Resource limits: 512M RAM, 15% CPU
   - Config: `~/.config/copyq/` (chezmoi)
   - **Replaces:** Klipper (KDE default)

3. **flameshot.service**
   - Screenshot tool daemon
   - Resource limits: 256M RAM, 15% CPU
   - Config: `~/.config/flameshot/flameshot.ini` (chezmoi)
   - **Replaces:** Spectacle (KDE default)

### Notification Services

4. **notify-atuin-failure.service**
5. **notify-copyq-failure.service**
6. **notify-flameshot-failure.service**

### Health Check

7. **productivity-tools-health-check.service**
   - Checks all services every hour
   - Timer: OnBootSec=10min, OnUnitActiveSec=1h

---

## Resource Limits

| Service | Memory Max | CPU Quota | Restart Delay |
|---------|-----------|-----------|---------------|
| Atuin | 256M | 10% | 30s |
| CopyQ | 512M | 15% | 10s |
| Flameshot | 256M | 15% | 10s |

---

## Default Application Replacements

### Flameshot Replaces Spectacle

**Keyboard Shortcuts** (managed via chezmoi):
```
Print              → Flameshot (full screenshot)
Meta+Shift+Print   → Flameshot GUI
Spectacle          → All shortcuts disabled
```

**Config File:** `~/.config/kglobalshortcutsrc` (via chezmoi_modify_manager)

**Features:**
- Advanced annotation tools
- Drawing, arrows, text
- Blur, pixelate
- Upload to imgur
- Save to ~/Pictures/Screenshots

### CopyQ Replaces Klipper

**Clipboard Manager** (managed via chezmoi):
```
Klipper (KDE default)  → Disabled
CopyQ                  → Enabled as systemd service
```

**Config File:** `~/.config/klipperrc` (via chezmoi) - AutoStart=false

**Features:**
- Unlimited clipboard history
- Search and filter
- Custom tabs
- Scripting support
- Multiple clipboard formats

---

## Chezmoi Configuration Files

All configs managed via chezmoi (NOT home-manager):

```
~/.local/share/chezmoi/
├── private_dot_config/
│   ├── flameshot/
│   │   └── flameshot.ini.tmpl                    # Flameshot config
│   ├── copyq/
│   │   ├── copyq.conf.tmpl                       # CopyQ main config
│   │   └── copyq_tabs.ini                        # CopyQ tabs
│   ├── kglobalshortcutsrc.src.ini               # KDE shortcuts (Flameshot)
│   ├── modify_kglobalshortcutsrc                 # Modify script
│   └── klipperrc.tmpl                            # Disable Klipper

└── .chezmoiignore
    # CopyQ runtime files excluded:
    # - copyq.lock, .copyq_s, copyq_tab_*.dat
    # - copyq-monitor.ini, copyq_geometry.ini
```

---

## Manual Control Scripts

### Check Service Status
```bash
check-productivity-services.sh
```

**Output:**
```
======================================
Productivity Services Status
======================================

--- copyq ---
Status: ✓ RUNNING
Since: Thu 2025-12-12 02:00:00 EET

--- flameshot ---
Status: ✓ RUNNING
Since: Thu 2025-12-12 02:00:05 EET

--- atuin-sync ---
Status: ✓ RUNNING
Since: Thu 2025-12-12 02:00:10 EET

======================================
To restart all: restart-productivity-services.sh
======================================
```

### Restart All Services
```bash
restart-productivity-services.sh
```

---

## Testing After Deploy

### 1. Apply home-manager
```bash
home-manager switch --flake ~/.MyHome/MySpaces/my-modular-workspace#mitsio
```

### 2. Apply chezmoi configs
```bash
chezmoi apply
```

### 3. Check Services Started
```bash
systemctl --user status copyq.service
systemctl --user status flameshot.service
systemctl --user status atuin-sync.service
```

**Expected:** All active (running)

### 4. Test Flameshot Screenshot
```bash
# Press Print key - should open Flameshot
# Or run manually:
flameshot gui
```

### 5. Test CopyQ Clipboard
```bash
# Copy some text
# Press Meta+V to open clipboard history
# Or run:
copyq show
```

### 6. Test Atuin History
```bash
# Press Ctrl+R in terminal
# Should show Atuin history search
```

---

## Changes from Previous Setup

### Removed

- ✗ CopyQ autostart via `~/.config/autostart/copyq.desktop`
- ✗ Klipper (KDE clipboard manager)
- ✗ Spectacle default shortcuts

### Added

- ✅ CopyQ systemd service (always running)
- ✅ Flameshot systemd service (always running)
- ✅ Atuin sync daemon service
- ✅ Flameshot keyboard shortcuts (Print key)
- ✅ CopyQ as default clipboard manager
- ✅ All configs via chezmoi (not home-manager)

---

## Architecture

```
graphical-session.target
    ├── copyq.service
    │   ├── Restart=always
    │   ├── OnFailure=notify-copyq-failure.service
    │   └── Resource limits (512M RAM, 15% CPU)
    │
    └── flameshot.service
        ├── Restart=always
        ├── OnFailure=notify-flameshot-failure.service
        └── Resource limits (256M RAM, 15% CPU)

default.target
    └── atuin-sync.service
        ├── Restart=always (30s delay)
        ├── OnFailure=notify-atuin-failure.service
        └── Resource limits (256M RAM, 10% CPU)

timers.target
    └── productivity-tools-health-check.timer
        └── triggers: productivity-tools-health-check.service
            └── checks services every hour
```

---

## Integration with KDE

### Flameshot Integration

**Global Shortcuts:**
- Print → Flameshot capture
- Meta+Shift+Print → Flameshot GUI
- Spectacle shortcuts → Disabled

**Config managed by:** chezmoi_modify_manager

**File:** `~/.config/kglobalshortcutsrc`

### CopyQ Integration

**Klipper disabled:**
- AutoStart=false in `~/.config/klipperrc`

**Clipboard shortcuts:**
- Meta+V → Open CopyQ at mouse position
- Meta+Ctrl+X → Automatic action popup

---

## Troubleshooting

### Flameshot Not Capturing
```bash
# Check service running
systemctl --user status flameshot.service

# Test manually
flameshot gui

# Check shortcuts
kreadconfig6 --file kglobalshortcutsrc --group "flameshot.desktop"
```

### CopyQ Not Showing History
```bash
# Check service running
systemctl --user status copyq.service

# Open CopyQ
copyq show

# Check clipboard contents
copyq clipboard
```

### Atuin Sync Not Working
```bash
# Check service
systemctl --user status atuin-sync.service

# View logs
journalctl --user -u atuin-sync.service -f

# Test sync manually
atuin sync
```

---

## Action Confidence

| Component | Confidence | Band |
|-----------|-----------|------|
| Systemd services | 0.95 | C |
| Flameshot shortcuts | 0.90 | C |
| CopyQ clipboard integration | 0.88 | C |
| Chezmoi configs | 0.92 | C |
| Overall implementation | 0.91 | C |

---

## Files Created/Modified

### home-manager
```
productivity-tools-services.nix         # NEW - Systemd services
autostart.nix                           # MODIFIED - Removed CopyQ
home.nix                                # MODIFIED - Import new module
```

### chezmoi
```
private_dot_config/
├── flameshot/flameshot.ini.tmpl       # NEW
├── copyq/copyq.conf.tmpl              # NEW
├── copyq/copyq_tabs.ini               # NEW
├── kglobalshortcutsrc.src.ini         # NEW
├── modify_kglobalshortcutsrc          # NEW
└── klipperrc.tmpl                     # NEW

.chezmoiignore                          # MODIFIED - CopyQ runtime files
```

---

**Created:** 2025-12-12T02:15:00+02:00 (Europe/Athens)
**Ready for:** home-manager switch + chezmoi apply
