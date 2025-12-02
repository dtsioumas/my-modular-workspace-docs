# Plasma Desktop Dotfiles - Local Investigation

**Created:** 2025-12-02
**Phase:** Phase 1 - Local Investigation
**System:** shoshin (NixOS with KDE Plasma)
**User:** mitsio

---

## Investigation Summary

This document provides a comprehensive analysis of all KDE Plasma configuration files discovered in the home directory, categorized by function, with management status and migration recommendations.

### Scope

- **Target:** All plasma-related config files in `~/.config/` and `~/.local/share/`
- **Method:** Filesystem discovery, file analysis, content sampling
- **Status:** ✅ Complete inventory with detailed categorization

### Key Findings

1. **Total plasma configs discovered:** 40+ files and directories
2. **Currently managed by plasma-manager:** Evidence found in `~/.local/share/plasma-manager/`
3. **Largest configs:** `kglobalshortcutsrc` (16KB), `plasma-org.kde.plasma.desktop-appletsrc` (7.8KB)
4. **Empty configs:** `ksplashrc` (0 bytes)
5. **Config format:** All are INI-style text files with `[Section]` headers

---

## Core Plasma Configuration Files

### 1. Core Shell & Appearance

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `plasmarc` | 140 bytes | Nov 13 | **Plasma shell theme, wallpaper, tooltips** | ✅ Yes (tracked) | 🔴 HIGH |
| `plasmashellrc` | 2.4K | Nov 27 | **Panel configuration, layout** | ✅ Yes (tracked) | 🔴 HIGH |
| `plasma-org.kde.plasma.desktop-appletsrc` | 7.8K | Dec 1 | **Desktop widgets, applets** | ✅ Yes (tracked) | 🔴 HIGH |
| `kdeglobals` | 5.2K | Dec 2 | **Global KDE settings: fonts, colors, UI** | ⚠️ Partial | 🟡 MEDIUM |

**Analysis:**
- These are the **core plasma desktop files**
- plasma-manager writes to these (evidence in `~/.local/share/plasma-manager/last_run_*` files)
- **Critical for desktop functionality**

**Sample Content (plasmarc):**
```ini
[PlasmaToolTips]
Delay=5

[Theme]
name=breeze-dark

[Wallpapers]
usersWallpapers=/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg
```

**Sample Content (kwinrc - Desktops):**
```ini
[Desktops]
Id_1=Desktop_1
Id_2=Desktop_2
Id_3=Desktop_3
Id_4=Desktop_4
```

---

### 2. Window Manager (KWin)

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `kwinrc` | 1.3K | Dec 2 | **Window behavior, virtual desktops, effects** | ✅ Yes | 🔴 HIGH |
| `kwinoutputconfig.json` | 1.5K | Dec 2 | **Display configuration (monitors)** | ⚠️ Maybe | 🟡 MEDIUM |

**Analysis:**
- `kwinrc` is managed by plasma-manager `programs.plasma.files.kwinrc`
- Contains virtual desktops configuration (4 desktops)
- **Critical for window management**
- `kwinoutputconfig.json` is **hardware-specific** (monitor setup)

**Sample Content (kwinrc):**
```ini
[Activities][LastVirtualDesktop]
0762dfd6-3b0e-46b9-bf7d-e0bab60941e7=d0b58b9d-504c-4000-9d83-c64742f30cef

[Desktops]
Id_1=Desktop_1
Id_2=Desktop_2
Id_3=Desktop_3
Id_4=Desktop_4
```

---

### 3. Keyboard & Input

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `kglobalshortcutsrc` | 16K | Nov 30 | **Global keyboard shortcuts** | ✅ Yes | 🔴 HIGH |
| `kxkbrc` | 114 bytes | Nov 13 | **Keyboard layout settings** | ✅ Yes | 🟡 MEDIUM |

**Analysis:**
- `kglobalshortcutsrc` is the **largest plasma config** (16KB)
- Contains **all global shortcuts** (Meta+1-4 for desktops, Alt+F4, etc.)
- plasma-manager manages this via `programs.plasma.shortcuts`
- **Very important for user workflow**

---

### 4. Notifications & System Tray

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `plasmanotifyrc` | 248 bytes | Nov 30 | **Notification settings** | ⚠️ Maybe | 🟢 LOW |
| `plasma_workspace.notifyrc` | 133 bytes | Nov 26 | **Workspace notifications** | ⚠️ Maybe | 🟢 LOW |

**Analysis:**
- Notification configs are relatively small and simple
- Likely **auto-generated** or defaults
- Lower migration priority

---

### 5. Locale & Region

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `plasma-localerc` | 123 bytes | Nov 4 | **Locale settings (language, region)** | ⚠️ Maybe | 🟡 MEDIUM |
| `plasma_calendar_holiday_regions` | 32 bytes | Nov 14 | **Calendar holiday regions** | ⚠️ Maybe | 🟢 LOW |

---

### 6. Desktop Portal & Integration

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `xdg-desktop-portal-kderc` | 75 bytes | Dec 2 | **Desktop portal integration** | ❌ No | 🟢 LOW |

**Analysis:**
- Portal integration config for Flatpak/sandboxed apps
- System-level, likely should stay in NixOS config

---

### 7. KDE Daemons

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `kded5rc` | 95 bytes | Oct 27 | **KDE daemon (Plasma 5)** | ❌ No | 🔵 IGNORE |
| `kded6rc` | 40 bytes | Oct 27 | **KDE daemon (Plasma 6)** | ❌ No | 🔵 IGNORE |

**Analysis:**
- KDE daemon configs (system services)
- **Should NOT be migrated** (system-level)

---

## KDE Application Configs

### 8. File Manager (Dolphin)

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `dolphinrc` | 738 bytes | Nov 18 | **Dolphin file manager settings** | ⚠️ Maybe | 🟡 MEDIUM |

**Analysis:**
- plasma-manager has `programs.dolphin` module
- Check if currently managed in home-manager/plasma.nix

---

### 9. Terminal (Konsole)

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `konsolerc` | 176 bytes | Nov 19 | **Konsole terminal settings** | ❌ No | 🟡 MEDIUM |
| `konsolesshconfig` | 43 bytes | Dec 1 | **Konsole SSH configuration** | ❌ No | 🟢 LOW |

---

### 10. Text Editors (Kate, KWrite)

| File/Dir | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|----------|------|---------------|---------|----------------|------------------|
| `kate/` | 4.0K | Oct 23 | **Kate editor data directory** | ❌ No | 🟡 MEDIUM |
| `katerc` | 425 bytes | Dec 1 | **Kate editor config** | ❌ No | 🟡 MEDIUM |
| `katevirc` | 419 bytes | Oct 24 | **Kate vi mode config** | ❌ No | 🟢 LOW |
| `katemetainfos` | 920 bytes | Nov 24 | **Kate metadata** | ❌ No | 🟢 LOW |
| `kwriterc` | 162 bytes | Oct 25 | **KWrite editor config** | ❌ No | 🟢 LOW |

---

### 11. PDF Viewer (Okular)

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `okularrc` | 1.3K | Nov 23 | **Okular PDF viewer settings** | ❌ No | 🟡 MEDIUM |
| `okularpartrc` | 32 bytes | Nov 23 | **Okular part config** | ❌ No | 🟢 LOW |

---

### 12. Screenshot Tool (Spectacle)

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `spectaclerc` | 532 bytes | Dec 1 | **Spectacle screenshot settings** | ❌ No | 🟡 MEDIUM |

---

### 13. Image Viewer (Gwenview)

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `gwenviewrc` | 420 bytes | Oct 25 | **Gwenview image viewer** | ❌ No | 🟡 MEDIUM |
| `gwenview_importerrc` | 153 bytes | Nov 19 | **Gwenview importer** | ❌ No | 🟢 LOW |

---

### 14. Launcher (KRunner)

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `krunnerrc` | 99 bytes | Nov 13 | **KRunner launcher config** | ✅ Yes | 🟡 MEDIUM |

**Analysis:**
- plasma-manager has `programs.plasma.krunner` module
- Check current management status

---

### 15. Lock Screen & Session

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `kscreenlockerrc` | 382 bytes | Nov 13 | **Screen locker settings** | ⚠️ Maybe | 🟡 MEDIUM |
| `ksplashrc` | **0 bytes** | Nov 13 | **Splash screen (empty!)** | ⚠️ Maybe | 🔵 IGNORE |

**Analysis:**
- `ksplashrc` is **empty** - may be a placeholder
- Screen locker settings may be in plasma-manager

---

### 16. Power Management

| File | Size | Last Modified | Purpose | plasma-manager? | Migrate Priority |
|------|------|---------------|---------|----------------|------------------|
| `powerdevilrc` | 963 bytes | Nov 13 | **Power management settings** | ✅ Yes | 🟡 MEDIUM |
| `powermanagementprofilesrc` | 51 bytes | Oct 22 | **Power profiles** | ⚠️ Maybe | 🟢 LOW |

**Analysis:**
- plasma-manager has `programs.plasma.powerManagement`
- Check if currently managed

---

## Plasma Data Directories

### 17. ~/.local/share/plasma/

| Item | Type | Purpose |
|------|------|---------|
| `containmentpreviews/` | Directory | Desktop/panel preview images |

**Analysis:**
- This directory contains **generated preview images**
- **Should NOT be migrated** (auto-generated)

---

### 18. ~/.local/share/plasma-manager/

| Item | Type | Last Modified | Purpose |
|------|------|---------------|---------|
| `last_run_desktop_script_panels` | File | Nov 13 | **Tracks last plasma-manager panel script run** |
| `last_run_desktop_script_set_desktop_folder_settings` | File | Nov 13 | **Tracks desktop folder settings script** |
| `last_run_desktop_script_wallpaper_picture` | File | Nov 13 | **Tracks wallpaper script run** |
| `last_run_script_apply_themes` | File | Nov 13 | **Tracks theme application script** |

**🔴 CRITICAL FINDING:**
- plasma-manager **writes tracking files** here to know what it has already applied
- This proves plasma-manager **modifies ~/.config/** files
- plasma-manager uses a **script-based approach** to apply configs

**Implications for Migration:**
- plasma-manager is **actively managing** plasma configs
- Migration must account for plasma-manager tracking
- During migration, both systems will coexist temporarily

---

## Categorization by Function

### Category A: Appearance & Themes
**Files:** `plasmarc`, `kdeglobals`, `powerdevilrc` (partially)
**Current Management:** plasma-manager (themes, colors, icons, cursor)
**Migration Priority:** 🔴 HIGH

### Category B: Behavior & Settings
**Files:** `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`
**Current Management:** plasma-manager (panels, widgets)
**Migration Priority:** 🔴 HIGH

### Category C: Keyboard Shortcuts
**Files:** `kglobalshortcutsrc`, `kxkbrc`
**Current Management:** plasma-manager (shortcuts)
**Migration Priority:** 🔴 HIGH

### Category D: Window Management (KWin)
**Files:** `kwinrc`, `kwinoutputconfig.json`
**Current Management:** plasma-manager (virtual desktops, effects)
**Migration Priority:** 🔴 HIGH (kwinrc), 🟡 MEDIUM (kwinoutputconfig - hardware-specific)

### Category E: Applications (KDE)
**Files:** `dolphinrc`, `konsolerc`, `katerc`, `okularrc`, `spectaclerc`, `gwenviewrc`, `krunnerrc`
**Current Management:** Partial (some have plasma-manager modules)
**Migration Priority:** 🟡 MEDIUM

### Category F: Notifications & Locale
**Files:** `plasmanotifyrc`, `plasma_workspace.notifyrc`, `plasma-localerc`, `plasma_calendar_holiday_regions`
**Current Management:** Minimal or auto-generated
**Migration Priority:** 🟢 LOW

### Category G: System-Level (DON'T MIGRATE)
**Files:** `kded5rc`, `kded6rc`, `xdg-desktop-portal-kderc`
**Current Management:** System
**Migration Priority:** 🔵 IGNORE

### Category H: Auto-Generated (DON'T MIGRATE)
**Files:** `ksplashrc` (empty), containment previews
**Current Management:** Auto-generated
**Migration Priority:** 🔵 IGNORE

---

## plasma-manager Coverage Analysis

### What plasma-manager Currently Manages

Based on `home-manager/plasma.nix` and `home-manager/plasma-full.nix`:

#### ✅ High-Level API (Covered)
- `programs.plasma.workspace` → writes to `plasmarc`, `kdeglobals`
- `programs.plasma.panels` → writes to `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`
- `programs.plasma.shortcuts` → writes to `kglobalshortcutsrc`
- `programs.plasma.input.keyboard` → writes to `kxkbrc`
- `programs.plasma.appearance` → writes to `kdeglobals`, theme files
- `programs.plasma.powerManagement` → writes to `powerdevilrc`
- `programs.plasma.krunner` → writes to `krunnerrc`
- `programs.plasma.desktop` → writes to desktop config
- `programs.dolphin` → writes to `dolphinrc` (optional)

#### ⚠️ Low-Level API (Partial Coverage)
- `programs.plasma.files.kwinrc.Desktops` → writes specific sections to `kwinrc`
- `programs.plasma.files.kdeglobals` → writes specific sections

#### ❌ NOT Covered by plasma-manager
- Most KDE application configs (`konsolerc`, `katerc`, `okularrc`, `spectaclerc`, `gwenviewrc`, `katevirc`, `kwriterc`)
- Small/niche configs (`konsolesshconfig`, `katemetainfos`, `gwenview_importerrc`, `okularpartrc`)
- Notification configs (mostly auto-generated)
- System daemon configs (should stay in NixOS)

---

## Migration Decision Matrix

### 🔴 HIGH Priority - Migrate to chezmoi
**Why:** Core desktop functionality, user-specific, cross-platform needs

| File | Reason |
|------|--------|
| `plasmarc` | Core plasma settings (theme, wallpaper) |
| `plasmashellrc` | Panel layout - user-specific |
| `plasma-org.kde.plasma.desktop-appletsrc` | Widgets - user-specific |
| `kwinrc` | Virtual desktops, window behavior |
| `kglobalshortcutsrc` | Personal keyboard shortcuts |
| `kdeglobals` | Fonts, colors (partial - filter machine-specific parts) |

**Strategy:**
- Use chezmoi **templates** for machine-specific values (hostnames, paths)
- Keep plasma-manager for **generating initial configs**
- Migrate **user preferences** to chezmoi

---

### 🟡 MEDIUM Priority - Consider Migration
**Why:** Application settings, less critical, some auto-generation

| File | Reason | Consideration |
|------|--------|---------------|
| `kwinoutputconfig.json` | Display config | **Hardware-specific** - template or ignore |
| `dolphinrc` | File manager | plasma-manager has module - check coverage |
| `konsolerc` | Terminal settings | Separate from Plasma - could go to chezmoi |
| `katerc`, `okularrc`, `spectaclerc`, `gwenviewrc` | App settings | Personal prefs - good for chezmoi |
| `krunnerrc` | Launcher | plasma-manager covers - check gaps |
| `powerdevilrc` | Power settings | plasma-manager covers - check gaps |
| `kscreenlockerrc` | Lock screen | Likely covered by plasma-manager |
| `plasma-localerc` | Locale | User-specific but simple |

**Strategy:**
- **Template** hardware-specific parts (`kwinoutputconfig.json`)
- Migrate **application configs not covered by plasma-manager**
- Keep configs **already well-managed by plasma-manager**

---

### 🟢 LOW Priority - Low Value or Auto-Generated
**Why:** Small, auto-generated, or defaults

| File | Reason |
|------|--------|
| `plasmanotifyrc`, `plasma_workspace.notifyrc` | Notification defaults - likely auto-generated |
| `plasma_calendar_holiday_regions` | Calendar regions - simple |
| `kxkbrc` | Keyboard layout - covered by plasma-manager |
| `konsolesshconfig` | SSH config - tiny |
| `katevirc`, `kwriterc`, `katemetainfos` | Editor details - low impact |
| `okularpartrc`, `gwenview_importerrc` | App parts - auto-generated |
| `powermanagementprofilesrc` | Power profiles - system default |

**Strategy:**
- **Document** their existence
- **Don't migrate** unless user requests
- Some are **read-only references**

---

### 🔵 IGNORE - System-Level or Generated
**Why:** System configs, empty files, or auto-generated data

| File/Dir | Reason |
|----------|--------|
| `kded5rc`, `kded6rc` | KDE daemon - system-level |
| `xdg-desktop-portal-kderc` | Desktop portal - system integration |
| `ksplashrc` | **EMPTY FILE** (0 bytes) |
| `~/.local/share/plasma/containmentpreviews/` | Preview images - generated |
| `~/.local/share/plasma-manager/last_run_*` | plasma-manager tracking - tool-specific |

**Strategy:**
- **Exclude** from chezmoi with `.chezmoiignore`
- **Document** why they're excluded

---

## Gaps & Unknowns

### Questions for Phase 2 (Web Research)

1. **Plasma Config Stability**
   - Which configs are volatile (change frequently)?
   - Which configs are stable (safe to version control)?
   - KDE Plasma 5 vs 6 compatibility?

2. **plasma-manager Integration**
   - Does plasma-manager **overwrite** ~/.config files or **merge**?
   - How to safely coexist with chezmoi during migration?
   - Can plasma-manager **read** from chezmoi-managed files?

3. **Hardware-Specific Data**
   - What to do with `kwinoutputconfig.json` (monitor setup)?
   - How to template machine-specific paths in `plasmarc` (wallpapers)?

4. **Chezmoi Best Practices**
   - How do others manage KDE Plasma with chezmoi?
   - Recommended `.chezmoiignore` patterns for Plasma?
   - Template patterns for KDE configs?

---

## Observations & Notes

### Strengths of Current Setup
✅ **plasma-manager provides high-level API** - easier than raw config editing
✅ **Configs are text-based INI format** - easy to version control
✅ **plasma-manager tracks what it applies** - reduces config drift
✅ **Well-structured config separation** - core vs apps vs system

### Challenges Ahead
⚠️ **plasma-manager writes to ~/.config/** - potential conflict with chezmoi
⚠️ **Large configs** like `kglobalshortcutsrc` (16KB) - need careful templating
⚠️ **Hardware-specific configs** - need templating strategy
⚠️ **Plasma 5 vs 6 migration** - some configs have both versions

### Opportunities
✨ **Clear categorization possible** - by function and priority
✨ **INI format is chezmoi-friendly** - easy to template
✨ **plasma-manager can generate base configs** - then chezmoi manages them
✨ **Hybrid approach feasible** - plasma-manager for system, chezmoi for user prefs

---

## Recommended Next Steps

### For Phase 2 (Web Research)
1. Research **KDE Plasma 6 config file structure** and stability
2. Research **plasma-manager behavior** (overwrite vs merge)
3. Research **chezmoi + KDE best practices** from community
4. Research **templating strategies** for hardware-specific configs

### For Phase 3 (Migration Planning)
1. Design **hybrid approach** (plasma-manager + chezmoi coexistence)
2. Plan **phased migration** by category (High → Medium → Low priority)
3. Create **rollback strategy** for each phase
4. Design **testing approach** (VM? Separate user?)

---

**Status:** ✅ Phase 1 Complete - Comprehensive local investigation finished
**Next:** Phase 2 - Web Research (Technical Researcher Role)
**Created by:** Phase 1 Local Investigation
**Last Updated:** 2025-12-02T19:01:04+02:00 (Europe/Athens)
