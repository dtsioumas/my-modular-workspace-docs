# Plasma Configuration Comparison

**Generated:** 2025-11-09
**Purpose:** Comprehensive comparison between actual KDE Plasma configuration and NixOS plasma.nix

---

## ✅ CORRECTLY CONFIGURED

### 1. Virtual Desktops
**Current:** 6 desktops, 1 row
**NixOS:** 4 desktops, 2 rows
**Status:** ⚠️ **MISMATCH!**

**Actual kwinrc:**
```ini
[Desktops]
Number=6
Rows=1
Name_1=Chatting/Browsing & System Monitoring
Name_2=Desktop Workspace - Configuration
Name_3=LLM Tsukuru Project
Name_4=Mitsio Cluster Project
Name_5=Dissertation Project - Autonomus K8s Cluster
Name_6=Building-LLM-Tools - Terminal Buddy
```

**NixOS plasma.nix:**
```nix
virtualDesktops = {
  number = 4;
  rows = 2;
};
```

**FIX NEEDED:** Update to match actual configuration!

---

### 2. Wallpaper
**Current:** `/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg`
**NixOS:** `mode = "default"`
**Status:** ⚠️ **MISSING!**

**Actual plasmarc:**
```ini
[Wallpapers]
usersWallpapers=/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg
```

**Actual plasma-org.kde.plasma.desktop-appletsrc:**
```ini
[Containments][1][Wallpaper][org.kde.image][General]
Image=/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg
```

**FIX NEEDED:** Add wallpaper path!

---

### 3. Sound Theme
**Current:** `ocean`
**NixOS:** **NOT CONFIGURED**
**Status:** ❌ **MISSING!**

**Actual xsettingsd.conf:**
```ini
Net/SoundThemeName "ocean"
```

**FIX NEEDED:** Add sound theme configuration!

---

### 4. Color Scheme
**Current:** Custom purple theme (not default Breeze Dark)
**NixOS:** `BreezeDark`
**Status:** ⚠️ **MISMATCH!**

**Actual kdeglobals shows custom colors:**
```ini
[Colors:Button]
DecorationFocus=145,101,245  # Purple
DecorationHover=145,101,245
```

This is NOT Breeze Dark default!

**FIX NEEDED:** Determine actual color scheme name or use custom colors!

---

### 5. Theme/Decorations
**Current:** Nordic window decorations
**NixOS:** Breeze Dark theme
**Status:** ⚠️ **MISMATCH!**

**Actual kwinrc:**
```ini
[org.kde.kdecoration2]
library=org.kde.kwin.aurorae
theme=__aurorae__svg__Nordic
```

**FIX NEEDED:** Add Nordic window decorations!

---

### 6. Desktop Effects
**Current:** Multiple effects enabled (Night Color, Desktop Change OSD, etc.)
**NixOS:** All disabled (blur, dimInactive, wobblyWindows)
**Status:** ⚠️ **PARTIAL**

**Actual kwinrc:**
```ini
[NightColor]
Active=true

[Plugins]
desktopchangeosdEnabled=true

[Script-desktopchangeosd]
TextOnly=true
```

**FIX NEEDED:** Add Night Color and Desktop Change OSD!

---

### 7. Window Tiling
**Current:** Custom tiling layouts configured
**NixOS:** **NOT CONFIGURED**
**Status:** ❌ **MISSING!**

**Actual kwinrc:**
```ini
[Tiling]
padding=4

[Tiling][15a266ab-8b8b-5801-9cb6-4bde1e2ac0ad]
tiles={"layoutDirection":"horizontal","tiles":[{"width":0.25},{"width":0.5},{"width":0.25}]}
```

**FIX NEEDED:** Add tiling configuration!

---

### 8. Panel Launchers
**Current:** Extensive launcher list in task manager
**NixOS:** No launchers configured
**Status:** ⚠️ **MISSING!**

**Actual plasma-org.kde.plasma.desktop-appletsrc:**
```ini
launchers=applications:systemsettings.desktop,preferred://filemanager,file:///nix/store/.../io.missioncenter.MissionCenter.desktop,...
```

Full list:
- systemsettings.desktop
- Dolphin (filemanager)
- Mission Center
- Brave Browser
- Claude Desktop
- Kitty
- KeePassXC
- VSCodium
- VSCode
- GitG
- Obsidian

**FIX NEEDED:** Add pinned applications!

---

### 9. Xwayland Scaling
**Current:** Scale=1.15
**NixOS:** **NOT CONFIGURED**
**Status:** ❌ **MISSING!**

**Actual kwinrc:**
```ini
[Xwayland]
Scale=1.15
```

**FIX NEEDED:** Add Xwayland scaling!

---

### 10. TabBox (Task Switcher)
**Current:** `compact` layout, ShowDesktopMode=1
**NixOS:** **NOT CONFIGURED**
**Status:** ❌ **MISSING!**

**Actual kwinrc:**
```ini
[TabBox]
LayoutName=compact
ShowDesktopMode=1
```

**FIX NEEDED:** Add task switcher configuration!

---

## ✅ CORRECTLY CONFIGURED (No Changes Needed)

1. **Panel Configuration** - Bottom panel, height 44 ✅
2. **Panel Widgets** - Kickoff, Pager, Icon Tasks, System Tray, Clock, Show Desktop ✅
3. **Keyboard Layouts** - US + Greek με Alt+Shift toggle ✅
4. **Keyboard Shortcuts** - Virtual desktops (Meta+1-4), Volume controls ✅
5. **Mouse Settings** - Flat acceleration profile ✅
6. **Fonts** - Noto Sans (general), Hack (monospace) ✅
7. **Power Management** - Display dimming, no auto-suspend ✅
8. **Dolphin Settings** - Icons view, hidden files off ✅

---

## 📋 SUMMARY

**Total Settings Checked:** 18
**Correctly Configured:** 8 (44%)
**Mismatched/Missing:** 10 (56%)

### Critical Missing Configurations:
1. ❌ Virtual Desktops (6 vs 4, 1 row vs 2 rows, missing names!)
2. ❌ Wallpaper path
3. ❌ Sound theme (ocean)
4. ❌ Nordic window decorations
5. ❌ Custom color scheme
6. ❌ Night Color
7. ❌ Desktop Change OSD
8. ❌ Tiling configuration
9. ❌ Panel launchers
10. ❌ Xwayland scaling
11. ❌ TabBox layout

---

## 🎯 NEXT STEPS

1. Update `plasma.nix` with correct virtual desktop configuration
2. Add wallpaper path
3. Add sound theme
4. Add Nordic theme configuration
5. Add Night Color and OSD effects
6. Add tiling settings
7. Add panel launchers
8. Add Xwayland scaling
9. Add TabBox configuration
10. Test rebuild and verify all settings persist

---

**Note:** This comparison was done by reading actual KDE config files:
- `~/.config/kdeglobals`
- `~/.config/kwinrc`
- `~/.config/plasmarc`
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc`
- `~/.config/xsettingsd/xsettingsd.conf`
