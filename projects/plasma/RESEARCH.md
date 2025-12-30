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
# Plasma Desktop Dotfiles - Web Research Findings

**Created:** 2025-12-02
**Phase:** Phase 2 - Web Research (Technical Researcher Role)
**Research Confidence:** `topic_research_confidence = 0.87` (Band C - HIGH)
**Status:** ✅ Complete

---

## Research Summary

This document synthesizes findings from comprehensive web research on managing KDE Plasma dotfiles with chezmoi, plasma-manager behavior, and best practices for cross-platform configuration management.

### Research Methodology

**Approach:** `web_research_workflow`
- **Iteration 1:** Firecrawl + exa search for KDE Plasma 6 and plasma-manager
- **Iteration 2:** Targeted scraping of key resources
- **Iteration 3:** Chezmoi best practices and INI templating

**Sources Used:**
- Official KDE Frameworks 6 documentation
- plasma-manager GitHub discussions
- Community blog posts and guides
- Chezmoi official documentation
- Real-world dotfile examples

**Topics Researched:**
1. ✅ KDE Plasma 6 configuration structure (c = 0.85)
2. ✅ plasma-manager behavior and (im)mutability (c = 0.90)
3. ✅ Chezmoi + KDE best practices (c = 0.88)
4. ✅ .chezmoiignore patterns for KDE (c = 0.85)
5. ✅ INI file templating with chezmoi (c = 0.90)

---

## Topic 1: KDE Plasma 6 Configuration Structure

**Research Confidence:** `c = 0.85` (Band C)

### Key Findings

#### 1.1 Plasma 6 vs Plasma 5

**Source:** [KDE Frameworks 6 Porting Guide](https://develop.kde.org/docs/features/configuration/porting_kf6)

**Major Changes:**
- ✅ **KF6 uses KCMUtils** (moved from KDeclarative/KConfigWidgets)
- ✅ **No symlinks allowed** in Plasma 6 global themes due to new kpackage format
- ✅ **Strict theme packaging** - requires `manifest.json` with `"KPackageStructure": "Plasma/LookAndFeel"`
- ✅ **QML imports renamed** - affects custom themes and widgets

**Implications for Migration:**
- Plasma 6 config files are in same locations (`~/.config/`) as Plasma 5
- Config format (INI) remains the same
- plasma-manager handles Plasma 6 compatibility

#### 1.2 Config File Locations

**Source:** Reddit discussion "Where does KDE6 store its configuration files?"

**Standard Locations (Confirmed for Plasma 6):**
```
~/.config/          # All KDE configuration files
~/.local/share/     # KDE data files, themes, plasmoids
~/.cache/           # Temporary/cache files (DON'T manage)
```

**Core Config Files:**
- `kwinrc` - Window manager
- `plasmarc` - Plasma shell theme
- `kdeglobals` - Global KDE settings
- `kglobalshortcutsrc` - Keyboard shortcuts
- `plasma-org.kde.plasma.desktop-appletsrc` - Desktop widgets

#### 1.3 Volatile vs Stable Configs

**Analysis from Community:**

**Volatile (Change Frequently):**
- Window positions, sizes (`[MainWindow]` sections)
- Recent files lists
- File dialog states
- Search history
- Session-specific data

**Stable (Safe to Version Control):**
- Theme settings
- Keyboard shortcuts
- Panel layout
- Widget configuration
- Font preferences
- Power management settings

**Recommendation:** Use chezmoi_modify_manager (see Topic 3) to filter volatile sections.

---

## Topic 2: plasma-manager Behavior

**Research Confidence:** `c = 0.90` (Band C)

### Key Findings

#### 2.1 How plasma-manager Works

**Source:** [plasma-manager GitHub Discussion #120](https://github.com/nix-community/plasma-manager/discussions/120)

**🔴 CRITICAL Finding: plasma-manager writes to `~/.config/` directly**

**Evidence from Local Investigation:**
- `~/.local/share/plasma-manager/last_run_*` scripts track what was applied
- plasma-manager uses **desktop scripts** to apply configs
- Configs are written to actual files, NOT symlinked from Nix store

**Script-Based Approach:**
```
~/.local/share/plasma-manager/
├── last_run_desktop_script_panels
├── last_run_desktop_script_set_desktop_folder_settings
├── last_run_desktop_script_wallpaper_picture
└── last_run_script_apply_themes
```

#### 2.2 Immutability Behavior

**Source:** plasma-manager GitHub Discussion #120

**Key Points from Discussion:**

1. **Immutability Setting:**
   - plasma-manager can mark keys as `immutable = true`
   - Immutable keys get `[$i]` suffix in INI files
   - KDE Plasma respects immutability and won't change them via GUI

2. **Current Default:**
   - `immutable = false` by default
   - Keys are **mutable and persistent** unless explicitly configured

3. **Community Consensus (from discussion):**
   - **Opinion 1:** If value is set explicitly, should be immutable by default
   - **Opinion 2:** Mutable variables should not have explicit value in nix config
   - **Opinion 3:** All keys should be mutable and persistent by default (current behavior)
   - **Opinion 4:** Allow reset by key (selective persistence)

4. **overrideConfig Option:**
   - `overrideConfig = true` → plasma-manager resets entire config files
   - Use with caution - destructive!
   - Current user (Mitsos) likely has `overrideConfig = false`

#### 2.3 Merge vs Overwrite Behavior

**Finding from Discussion:**

**plasma-manager does NOT overwrite, it MERGES:**
- When setting `key[$i]=value`, it does NOT delete `key=value`
- Original values persist when plasma-manager config is removed
- This allows "rollback" to previous state

**Example:**
```ini
# Original file
[Section]
key=original_value

# After plasma-manager applies key[$i]
[Section]
key=original_value        # ← Still there!
key[$i]=nix_managed_value # ← Added by plasma-manager
```

#### 2.4 Coexistence with Chezmoi

**Implications:**

**✅ Coexistence IS Possible:**
- plasma-manager writes to `~/.config/` files
- chezmoi can manage the same files
- **Key:** Use chezmoi's `modify_*` scripts (see Topic 3)

**⚠️ Potential Conflicts:**
- If both try to manage same keys → conflict
- If plasma-manager uses `overrideConfig = true` → chezmoi changes lost

**Recommended Strategy:**
1. Keep plasma-manager for **high-level structure** (panels, themes)
2. Use chezmoi for **user-specific preferences** (shortcuts, app configs)
3. Use `chezmoi_modify_manager` to filter volatile sections

---

## Topic 3: Chezmoi + KDE Best Practices

**Research Confidence:** `c = 0.88` (Band C)

### Key Findings

#### 3.1 The Problem with KDE Configs

**Source:** [Managing KDE Dotfiles with Chezmoi and Chezmoi Modify Manager](https://www.lorenzobettini.it/2025/09/managing-kde-dotfiles-with-chezmoi-and-chezmoi-modify-manager/)

**KDE Config Challenges:**
> "KDE applications like Kate, Dolphin, and KWin store their settings in INI-style configuration files. These files often contain:
> - **Volatile sections** that change frequently (like window positions, recent files)
> - **System-specific data** (like file dialog sizes, screen configurations)
> - **Mixed content** where you only want to track specific settings"

**Result:** Managing these directly with chezmoi = noisy diffs + configs that don't work across machines

#### 3.2 Solution: Chezmoi Modify Manager

**🌟 MAJOR DISCOVERY: `chezmoi_modify_manager`**

**Tool:** [chezmoi_modify_manager](https://github.com/VorpalBlade/chezmoi_modify_manager)

**What It Does:**
- Acts as a **configurable filter** between actual config files and chezmoi repository
- Allows **selective tracking** of INI file sections/keys
- Uses chezmoi's `modify_*` script mechanism

**Capabilities:**
- ✅ **Ignore entire sections** or specific keys
- ✅ **Set specific values** while ignoring everything else
- ✅ **Use regex patterns** for flexible matching
- ✅ **Transform values** during processing

#### 3.3 How chezmoi_modify_manager Works

**File Structure in chezmoi source directory:**

```
~/.local/share/chezmoi/
├── modify_private_kwinrc                 # ← Modify script
├── private_kwinrc.src.ini                # ← Source state
├── modify_private_kdeglobals.tmpl        # ← Templated modify script
├── private_kdeglobals.src.ini            # ← Source state
└── .chezmoiignore                        # ← Must ignore *.src.ini
```

**Process:**
1. **Source file** (`.src.ini`) contains your desired configuration
2. **Modify script** (`modify_*`) defines filtering rules
3. **Chezmoi** applies modifications when deploying configs
4. `.chezmoiignore` ensures source files aren't directly copied

**Required .chezmoiignore:**
```
**/*.src.ini
```

#### 3.4 Real-World Examples

**Example 1: KWin Configuration**

`modify_private_kwinrc`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

ignore section "$Version"
ignore section "Desktops"
ignore regex "Tiling.*" ".*"
ignore section "Xwayland"
```

`private_kwinrc.src.ini`:
```ini
[Effect-cube]
CubeFaceDisplacement=126
DistanceFactor=1.82

[Effect-magiclamp]
AnimationDuration=400

[Plugins]
cubeEnabled=true
magiclampEnabled=true
```

**Result:** Only tracks relevant window manager settings, ignores volatile sections.

---

**Example 2: Global Shortcuts**

`modify_private_kglobalshortcutsrc`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

ignore section "ActivityManager"
```

**Result:** Keeps custom shortcuts, filters activity-specific bindings.

---

**Example 3: Font Configuration (Single Setting)**

`modify_private_kdeglobals`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

set "General" "fixed" "Hack Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1" separator="="
ignore regex ".*" ".*"
```

`private_kdeglobals.src.ini`:
```ini
[General]
fixed=Hack Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
```

**Result:** Tracks ONLY the terminal font, ignores everything else.

---

**Example 4: Kate Editor**

`modify_private_katerc`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

ignore section "KFileDialog Settings"
ignore section "FileDialogSize"
ignore section "KTextEditor::Search"
ignore section "MainWindow"
ignore regex "Kate Print Settings.*" ".*"
```

**Result:** Keeps editor preferences, ignores volatile sections (window sizes, recent searches).

#### 3.5 Benefits & Drawbacks

**✅ Benefits:**
- **Clean diffs** - Only track settings you care about
- **Portable configs** - No system-specific clutter
- **Selective tracking** - Include only relevant sections
- **Precise control** - Regex patterns for flexibility

**⚠️ Drawbacks:**
- **Initial setup time** - Need to understand what to include/exclude
- **Additional tool** - Must install `chezmoi_modify_manager` separately
- **Maintenance** - Updating configs requires [special techniques](https://www.lorenzobettini.it/2025/11/maintaining-kde-dotfiles-with-chezmoi-modify-manager/)
- **No merge support** - Some chezmoi mechanisms won't function

**Recommendation:** Use `chezmoi_modify_manager` for **complex KDE configs** (kwinrc, kdeglobals, kglobalshortcutsrc). Use plain chezmoi for **simple app configs**.

---

## Topic 4: .chezmoiignore Patterns for KDE

**Research Confidence:** `c = 0.85` (Band C)

### Key Findings

#### 4.1 Essential Patterns

**Source:** Multiple chezmoi GitHub discussions and community examples

**Must-Have Patterns:**

```gitignore
# ============ chezmoi_modify_manager ============
# Source files for chezmoi_modify_manager
**/*.src.ini

# ============ KDE CACHE & TEMP ============
# KDE cache files
.cache/
**/.cache/

# KDE lock files
**/*.lock
**/.copyq_s

# ============ KDE VOLATILE CONFIGS ============
# Auto-generated KDE config updates
**/kconf_updaterc

# Session management (volatile)
**/*session*

# Recent files/history (volatile)
**/recentlyused.xbel
**/recently-used.xbel

# ============ PLASMA-SPECIFIC ============
# Plasma containment previews (generated)
.local/share/plasma/containmentpreviews/

# Plasma manager tracking (tool-specific)
.local/share/plasma-manager/

# KDE activities (system-specific)
**/*activities*

# ============ HARDWARE-SPECIFIC ============
# Display configuration (monitor setup)
**/kwinoutputconfig.json
**/kscreen/

# Power management profiles (hardware-specific)
**/powermanagementprofilesrc
```

#### 4.2 Patterns from User's Existing .chezmoiignore

**Current patterns (from dotfiles/.chezmoiignore):**

```gitignore
# Staging/reference
_staging/

# Documentation
*.md
README.md

# Version control
.git/
.gitignore

# Backups
*.backup
*.bak
*.old

# Temporary files
*.tmp
*.swp
*~

# Large files
*.zip
*.tar.gz

# Home-manager managed (per ADR-007)
.config/autostart/
dot_config/autostart/

# CopyQ runtime files
.config/copyq/copyq.lock
.config/copyq/.copyq_s
.config/copyq/copyq_tab_*.dat
```

**✅ Good coverage** - Already handles backups, temp files, and tool-specific runtime files.

#### 4.3 Recommended Additions for Plasma Migration

**Patterns to ADD to .chezmoiignore:**

```gitignore
# ============ CHEZMOI_MODIFY_MANAGER ============
**/*.src.ini

# ============ KDE PLASMA VOLATILE ============
# Auto-generated updates
**/kconf_updaterc

# Session data
**/session/
**/*session*

# Recent files
**/recentlyused.xbel

# Plasma containment previews
.local/share/plasma/containmentpreviews/

# plasma-manager tracking
.local/share/plasma-manager/

# ============ HARDWARE-SPECIFIC (Maybe) ============
# Display config - ONLY if not templating
# **/kwinoutputconfig.json

# ============ EMPTY FILES ============
# ksplashrc is 0 bytes (placeholder)
**/ksplashrc
```

---

## Topic 5: INI File Templating with Chezmoi

**Research Confidence:** `c = 0.90` (Band C)

### Key Findings

#### 5.1 Chezmoi Template Basics

**Source:** [Chezmoi Templates Documentation](https://chezmoi.io/reference/templates/)

**Template Engine:** Go's `text/template`

**File Naming:**
- Files with `.tmpl` extension are processed as templates
- Example: `dot_config/plasma/private_kwinrc.tmpl`

**Available Variables:**
- `.chezmoi.hostname` - Machine hostname
- `.chezmoi.os` - Operating system (linux, darwin, etc.)
- `.chezmoi.osRelease` - Linux OS release info
- `.chezmoi.homeDir` - User's home directory
- `.chezmoi.username` - Current user
- Custom variables from `~/.config/chezmoi/chezmoi.toml`

#### 5.2 Template Syntax for INI Files

**Basic Variable Substitution:**

```ini
[Wallpapers]
usersWallpapers={{ .chezmoi.homeDir }}/Pictures/Wallpapers/current.jpg
```

**Conditional Sections:**

```ini
{{- if eq .chezmoi.hostname "shoshin" }}
[Effect-cube]
CubeFaceDisplacement=126
DistanceFactor=1.82
{{- end }}

{{- if eq .chezmoi.hostname "laptop" }}
[Effect-cube]
CubeFaceDisplacement=100
DistanceFactor=1.5
{{- end }}
```

**Multiple Conditions:**

```ini
[Plugins]
{{- if eq .chezmoi.os "linux" }}
cubeEnabled=true
magiclampEnabled=true
{{- end }}

{{- if eq .work_machine "true" }}
# Disable distracting effects at work
cubeEnabled=false
{{- end }}
```

#### 5.3 Custom Variables in chezmoi.toml

**Define machine-specific data:**

`~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
    work_machine = false
    wallpaper_dir = "{{ .chezmoi.homeDir }}/Pictures/Wallpapers"

[data.monitors]
    main = "DP-1"
    secondary = "HDMI-1"
```

**Use in templates:**

```ini
[Wallpapers]
usersWallpapers={{ .wallpaper_dir }}/current.jpg

{{- if .work_machine }}
[powerdevilrc]
# Work power settings
{{- else }}
# Home power settings
{{- end }}
```

#### 5.4 Template Functions

**String Manipulation:**

```ini
# Uppercase hostname
[General]
HostName={{ .chezmoi.hostname | upper }}

# Conditional path
BackupPath={{ if eq .chezmoi.os "linux" }}{{ .chezmoi.homeDir }}/Backups{{ else }}/mnt/backups{{ end }}
```

**Loops (for lists):**

```toml
# In chezmoi.toml
[data]
    favorite_apps = ["brave", "kitty", "dolphin"]
```

```ini
# In template
[Taskbar]
{{- range .favorite_apps }}
Favorite={{ . }}
{{- end }}
```

#### 5.5 Hardware-Specific Templating

**Example: Monitor Configuration**

**Problem:** `kwinoutputconfig.json` contains hardware-specific display settings

**Solution:** Template with machine-specific monitor names

`dot_config/kwinoutputconfig.json.tmpl`:
```json
{
  "{{ .monitors.main }}": {
    "scale": 1.0,
    "resolution": "2560x1440"
  }
  {{- if .monitors.secondary }},
  "{{ .monitors.secondary }}": {
    "scale": 1.0,
    "resolution": "1920x1080"
  }
  {{- end }}
}
```

**Example: Wallpaper Paths**

`dot_config/plasmarc.tmpl`:
```ini
[Wallpapers]
usersWallpapers={{ .wallpaper_dir }}/{{ .chezmoi.hostname }}-wallpaper.jpg
```

---

## Synthesis & Recommendations

### Overall Strategy

**Hybrid Approach: plasma-manager + chezmoi + chezmoi_modify_manager**

1. **plasma-manager** (Keep for now)
   - Manages high-level plasma structure (panels, themes, basic settings)
   - Provides Nix-native integration
   - Works well for **system-level** configs

2. **chezmoi** (Migrate user preferences)
   - Manages **user-specific** preferences
   - Handles **cross-platform** needs (Fedora migration)
   - Uses templates for **machine-specific** values

3. **chezmoi_modify_manager** (Use for complex configs)
   - Filters **volatile sections** from KDE configs
   - Enables **selective tracking** of INI files
   - Prevents **noisy diffs**

### Migration Strategy Recommendations

#### Phase A: Simple Configs (Plain Chezmoi)
**Migrate these directly to chezmoi:**
- KDE application configs: `konsolerc`, `katerc`, `okularrc`, `spectaclerc`, `gwenviewrc`
- Small configs: `krunnerrc`, `plasma-localerc`
- Application data: Dolphin settings, Kate sessions

**Why:** These are relatively stable, user-specific, and don't change frequently.

#### Phase B: Complex Configs (chezmoi_modify_manager)
**Use chezmoi_modify_manager for:**
- `kwinrc` - Filter volatile sections (window states, session data)
- `kdeglobals` - Track only specific settings (fonts, specific prefs)
- `kglobalshortcutsrc` - Ignore activity-specific bindings
- `katerc` - Ignore file dialog sizes, window positions

**Why:** These mix stable preferences with volatile state.

#### Phase C: Hardware-Specific (Templates)
**Template these configs:**
- `kwinoutputconfig.json` - Monitor setup (use `.monitors.main` variable)
- `plasmarc` - Wallpaper paths (use `.wallpaper_dir` variable)
- Machine-specific power settings

**Why:** Different values needed per machine.

#### Phase D: Keep in plasma-manager
**DO NOT migrate (keep in plasma-manager):**
- Panel layout configuration
- Widget/applet placement
- Theme selection (high-level)
- Virtual desktops structure

**Why:** plasma-manager provides excellent declarative API for these.

### .chezmoiignore Strategy

**Add these patterns:**
```gitignore
# chezmoi_modify_manager sources
**/*.src.ini

# KDE volatile/generated
**/kconf_updaterc
**/session/
**/recentlyused.xbel
.local/share/plasma/containmentpreviews/
.local/share/plasma-manager/
**/ksplashrc

# Optional: Hardware-specific (if not templating)
# **/kwinoutputconfig.json
```

### Templating Strategy

**Define in `~/.config/chezmoi/chezmoi.toml`:**
```toml
[data]
    work_machine = false
    wallpaper_dir = "{{ .chezmoi.homeDir }}/Pictures/Wallpapers"

[data.monitors]
    main = "DP-1"
    secondary = ""  # Empty on desktop (no secondary)
```

**Use templates for:**
1. Wallpaper paths
2. Monitor configurations
3. Work vs home conditional configs

---

## Key Insights

### 1. plasma-manager Writes Directly to ~/.config/

**Finding:** plasma-manager does NOT symlink from Nix store - it writes actual files to `~/.config/`.

**Implication:** Coexistence with chezmoi IS possible, but requires coordination.

**Evidence:** `~/.local/share/plasma-manager/last_run_*` scripts track applications.

### 2. chezmoi_modify_manager is Essential for KDE

**Finding:** KDE configs mix stable preferences with volatile state.

**Solution:** Use `chezmoi_modify_manager` to filter sections selectively.

**Benefit:** Clean diffs, portable configs, precise control.

### 3. Plasma 6 Config Structure is Stable

**Finding:** Plasma 6 uses same config locations and INI format as Plasma 5.

**Implication:** Existing dotfile strategies remain valid.

**Note:** KF6 has breaking changes for **themes/plasmoids**, not for config files.

### 4. Template for Hardware-Specific Configs

**Finding:** Configs like `kwinoutputconfig.json` (monitors) and wallpaper paths are machine-specific.

**Solution:** Use chezmoi templates with machine-specific variables.

**Benefit:** Single dotfiles repo works across multiple machines.

### 5. Selective Tracking is Critical

**Finding:** Tracking everything in KDE configs = noisy diffs + non-portable configs.

**Solution:** Use `.chezmoiignore` + `chezmoi_modify_manager` for selective tracking.

**Result:** Only version-control what matters.

---

## Gaps & Unknowns

### Remaining Questions

1. **plasma-manager + chezmoi_modify_manager Interaction**
   - ❓ Does plasma-manager respect changes made by chezmoi_modify_manager?
   - ❓ What happens if both try to manage the same sections?
   - **Recommendation:** Test in VM before production migration

2. **overrideConfig Behavior**
   - ❓ Does current user (Mitsos) have `overrideConfig = true` or `false`?
   - ❓ How often does plasma-manager run and rewrite configs?
   - **Action:** Check `home-manager/plasma.nix` for `overrideConfig` setting

3. **Wallpaper Directory Migration**
   - ✅ User confirmed: wallpapers should go to `~/Pictures/Wallpapers/`
   - ❓ How to handle the transition? (Move existing wallpapers)
   - **Action:** Include in migration plan

4. **Testing Strategy**
   - ❓ How to safely test plasma config changes?
   - ❓ VM? Separate user account? Backup strategy?
   - **Recommendation:** Plan comprehensive testing approach in Phase 3

### Areas for Further Research (If Needed)

1. **Plasma-manager Internal Implementation**
   - How exactly do desktop scripts work?
   - Can we inspect what plasma-manager will write before applying?

2. **KDE Plasma Config Reload**
   - Do config changes require logout/login?
   - Can configs be reloaded without session restart?

3. **chezmoi_modify_manager Updates**
   - How to update managed configs when source files change?
   - Workflow for incorporating GUI changes back into chezmoi?

---

## Research Sources

### Official Documentation
1. [KDE Frameworks 6 Porting Guide](https://develop.kde.org/docs/features/configuration/porting_kf6) - KF6 changes
2. [Chezmoi Templates](https://chezmoi.io/reference/templates/) - Template syntax
3. [Chezmoi .chezmoiignore](https://chezmoi.io/reference/special-files-and-directories/chezmoiignore/) - Ignore patterns
4. [plasma-manager Options](https://nix-community.github.io/plasma-manager/options.xhtml) - Available options

### Community Resources
5. [Managing KDE Dotfiles with Chezmoi and Chezmoi Modify Manager](https://www.lorenzobettini.it/2025/09/managing-kde-dotfiles-with-chezmoi-and-chezmoi-modify-manager/) - Lorenzo Bettini's guide
6. [plasma-manager Immutability Discussion #120](https://github.com/nix-community/plasma-manager/discussions/120) - Merge/overwrite behavior
7. [Strategies for Declarative Approaches (NixOS Discourse)](https://discourse.nixos.org/t/strategies-for-declarative-approaches-to-programs-with-mutable-configuration-files/66276) - Mutable config patterns
8. Reddit: "Where does KDE6 store its configuration files?" - Config locations

### Tools & Projects
9. [chezmoi_modify_manager](https://github.com/VorpalBlade/chezmoi_modify_manager) - INI filter tool
10. Community dotfiles examples (GitHub)

---

## Next Steps for Phase 3 (Migration Planning)

### Inputs for Planning

**Context Gathered:**
- ✅ Complete inventory of plasma config files (Phase 1)
- ✅ Categorization by priority and complexity (Phase 1)
- ✅ Understanding of plasma-manager behavior (Phase 2)
- ✅ Best practices for chezmoi + KDE (Phase 2)
- ✅ Tool recommendations (chezmoi_modify_manager) (Phase 2)

**Ready for:**
- Designing 3-5 migration phases
- Risk assessment per phase
- Rollback strategies
- Testing approach
- Success criteria

**Questions to Answer in Planning:**
1. Which configs migrate first? (Low-risk → High-risk)
2. When to introduce `chezmoi_modify_manager`?
3. How to test each phase safely?
4. What's the rollback procedure?
5. How to handle wallpaper directory migration?

---

**Status:** ✅ Phase 2 Complete - Comprehensive web research finished
**Next:** Phase 3 - Migration Planning (Planner Role + Sequential Thinking/Ultrathink)
**Created by:** Phase 2 Web Research (Technical Researcher Role)
**Last Updated:** 2025-12-02T19:35:00+02:00 (Europe/Athens)

---

**Research Confidence Summary**

| Topic | c | Band | Quality |
|-------|---|------|---------|
| KDE Plasma 6 config structure | 0.85 | C | HIGH |
| plasma-manager behavior | 0.90 | C | VERY HIGH |
| Chezmoi + KDE best practices | 0.88 | C | HIGH |
| .chezmoiignore patterns | 0.85 | C | HIGH |
| INI file templating | 0.90 | C | VERY HIGH |
| **Overall Research** | **0.87** | **C** | **HIGH** |

**Confidence Assessment:** Research findings are solid and actionable. Ready to proceed with comprehensive migration planning in Phase 3.
