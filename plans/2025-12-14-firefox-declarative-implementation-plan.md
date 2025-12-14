# Firefox Declarative Configuration - Comprehensive Implementation Plan

**Date Created:** 2025-12-14
**Planner:** Technical Planner (Sonnet 4.5)
**Plan Confidence:** 0.84 (Band C - HIGH)
**User:** Mitsio (Dimitris Tsioumas)
**Project:** my-modular-workspace

---

## Executive Summary

This plan provides a complete roadmap for migrating Firefox to declarative configuration via home-manager, optimizing performance (GPU/RAM/CPU), installing extensions declaratively, and configuring vertical tabs via Sidebery. The plan addresses all critical issues found in ultrathink analysis and aligns with user requirements.

**Timeline:** 4-6 weeks (phased approach)
**Estimated Effort:** 20-25 hours total
**Risk Level:** MEDIUM (comprehensive testing required)

---

## Table of Contents

1. [Prerequisites and Preparation](#prerequisites-and-preparation)
2. [Phase 0: Extension Discovery & Baseline](#phase-0-extension-discovery--baseline)
3. [Phase 1: Create Firefox Module](#phase-1-create-firefox-module)
4. [Phase 2: Declarative Extensions](#phase-2-declarative-extensions)
5. [Phase 3: GPU Optimization (NVIDIA)](#phase-3-gpu-optimization-nvidia)
6. [Phase 4: RAM & CPU Tuning](#phase-4-ram--cpu-tuning)
7. [Phase 5: Sidebery Vertical Tabs](#phase-5-sidebery-vertical-tabs)
8. [Phase 6: Search Engine & Sync](#phase-6-search-engine--sync)
9. [Phase 7: Testing & Validation](#phase-7-testing--validation)
10. [Phase 8: Documentation](#phase-8-documentation)
11. [Rollback Strategy](#rollback-strategy)
12. [Appendix: Extension Reference](#appendix-extension-reference)

---

## Prerequisites and Preparation

### Required Tools
- ✅ Home-Manager (standalone mode)
- ✅ Firefox already installed
- ✅ KeePassXC (for secrets management per ADR-011)
- ✅ Chezmoi (for dotfiles per ADR-009)

### Required Access
- Firefox `about:support` page (for extension discovery)
- KeePassXC vault at `~/MyVault/`
- Home-manager repository: `~/.MyHome/MySpaces/my-modular-workspace/home-manager/`

### Pre-flight Checks
```bash
# 1. Verify current Firefox is running
pgrep -a firefox

# 2. Check home-manager version
home-manager --version

# 3. Verify KeePassXC connection
secret-tool search service keepassxc

# 4. Check current session variables (should have NVIDIA vars)
env | grep -E 'LIBVA|GBM|GLX'
```

---

## Phase 0: Extension Discovery & Baseline

**Duration:** 1 hour
**Goal:** Complete discovery of all installed extensions and create baseline configuration
**Confidence:** 0.90 (Band C)

### Step 0.1: Discover All Extension IDs

```bash
# Open Firefox
firefox &

# Navigate to about:support
# Screenshot or document the "Extensions" section
```

**Deliverable**: Create `docs/firefox/CURRENT_EXTENSIONS.md` with:
- Extension Name
- Extension ID
- Version
- Source (Manual install / Sync)

### Step 0.2: Create Baseline Snapshot

```bash
# Backup current Firefox profile
cp -r ~/.mozilla/firefox/*.default* ~/firefox-backup-$(date +%Y%m%d)

# Export current settings
cd ~/firefox-backup-*
find . -name "prefs.js" -o -name "userChrome.css" -o -name "extensions.json"
```

**Deliverable**: Backup at `~/firefox-backup-20251214/`

### Step 0.3: Document Currently Installed Extensions

Based on file analysis, currently installed (17 total):

| Filename | Size | Likely Extension |
|----------|------|------------------|
| `uBlock0@raymondhill.net.xpi` | 4.1M | uBlock Origin ✅ |
| `treestyletab@piro.sakura.ne.jp.xpi` | 1.2M | Tree Style Tab (will replace with Sidebery) |
| `floccus@handmadeideas.org.xpi` | 7.1M | Floccus ✅ |
| `@testpilot-containers.xpi` | 903K | Multi-Account Containers ✅ |
| `tab-stash@condordes.net.xpi` | 333K | Tab Stash |
| `{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi` | 14M | **Likely Bitwarden** ✅ |
| `{3c078156-979c-498b-8990-85f7987dd929}.xpi` | 611K | Unknown |
| `{a8776b67-902b-48c9-b196-0dc12ea75e08}.xpi` | 529K | Unknown |
| `{65252973-2e9e-427a-824f-6960f7806997}.xpi` | 145K | Unknown |
| `{96b7a652-8716-4678-be68-7a8bac53a373}.xpi` | 74K | Unknown |
| `{e75d6907-918c-4c8d-8f98-4b7ae39bf672}.xpi` | 14K | Unknown |
| `{7629eb30-af71-485c-b36f-52c0fc38bc01}.xpi` | 12K | Unknown |
| `{01d445cd-ab9b-4b72-8dec-02b49a859a76}.xpi` | 8.2K | Unknown |
| `{19289993-e8b6-4401-84b7-93391b61ff0a}.xpi` | 8.3K | Unknown |
| `{a9db16ed-87ed-4471-912f-456f47326340}.xpi` | 7.6K | Unknown |

**Action Required**: User must open `about:support` and identify the 10 unknown extensions.

### Step 0.4: Success Criteria

- [ ] All 17 extensions identified by name and ID
- [ ] Current Firefox profile backed up
- [ ] Baseline configuration documented

---

## Phase 1: Create Firefox Module

**Duration:** 2-3 hours
**Goal:** Create `home-manager/firefox.nix` module and migrate existing settings
**Confidence:** 0.88 (Band C)

### Step 1.1: Create Firefox Module Structure

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
touch firefox.nix
```

**File: `home-manager/firefox.nix`**

```nix
{ config, pkgs, lib, ... }:

{
  # ====================================
  # Firefox Browser - Declarative Configuration
  # ====================================
  #
  # Migrated from: home.nix lines 372-434
  # Based on: Brave configuration patterns (brave.nix)
  #
  # This configuration includes:
  # - NVIDIA hardware acceleration (X11)
  # - Memory & CPU optimizations
  # - Privacy & performance tuning
  # - Declarative extension management
  # - Vertical tabs (Sidebery)
  # - Firefox Sync enabled (credentials in KeePassXC)
  # ====================================

  programs.firefox = {
    enable = true;

    # Language packs
    languagePacks = [ "en-US" "el" ];  # English and Greek

    # Enterprise Policies (global, all profiles)
    policies = {
      # === Telemetry & Privacy ===
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxScreenshots = true;
      DisableSetDesktopBackground = true;

      # === Tracking Protection ===
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      # === Firefox Sync (User Requested!) ===
      # Allow sync for bookmarks/history while managing extensions declaratively
      DisableFirefoxAccounts = false;  # ✅ Enable sync per user request

      # === Extension Management ===
      # Declarative extension installation via Enterprise Policies
      # This section will be populated in Phase 2
      ExtensionSettings = {
        # Block all extensions except force-installed ones
        "*" = {
          installation_mode = "blocked";
          blocked_install_message = "Extensions are managed declaratively via home-manager. Contact system administrator to add extensions.";
        };

        # Extensions will be added in Phase 2
      };
    };

    # === Default Profile Configuration ===
    profiles.default = {
      id = 0;
      isDefault = true;

      # === Performance & Memory Settings ===
      settings = {
        # === Memory Optimizations (from current config) ===
        "browser.cache.memory.capacity" = 524288;  # 512MB RAM cache
        "browser.cache.disk.capacity" = 358400;    # 350MB disk cache
        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;

        "dom.ipc.processCount" = 4;  # 4 content processes
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.sessionhistory.max_total_viewers" = 2;
        "browser.sessionstore.interval" = 15000000;  # Reduce session save frequency

        # === NVIDIA Hardware Acceleration (X11) ===
        # Based on Brave's successful config
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "gfx.webrender.force-disabled" = false;  # Ensure not blocked

        "webgl.force-enabled" = true;
        "webgl.disabled" = false;

        # VA-API for Linux video acceleration
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;

        # GPU rasterization
        "gfx.canvas.accelerated" = true;
        "gfx.canvas.accelerated.cache-items" = 4096;
        "gfx.canvas.accelerated.cache-size" = 512;

        # Compositing
        "layers.gpu-process.enabled" = true;
        "layers.acceleration.draw-fps" = false;
        "layers.acceleration.disabled" = false;  # Ensure acceleration enabled

        # === Privacy & Security (from current config) ===
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "dom.security.https_only_mode" = true;

        # Disable telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;

        # === UI Preferences (from current config) ===
        "browser.startup.homepage" = "about:home";
        "browser.startup.page" = 3;  # Restore previous session
        "browser.newtabpage.enabled" = true;
        "browser.download.useDownloadDir" = true;
        "browser.download.dir" = "\${config.home.homeDirectory}/Downloads";
        "browser.toolbars.bookmarks.visibility" = "always";  # Show bookmarks toolbar

        # Disable Pocket
        "extensions.pocket.enabled" = false;

        # Smooth scrolling
        "general.smoothScroll" = true;

        # === Extension Auto-Enable (CRITICAL!) ===
        "extensions.autoDisableScopes" = 0;  # Auto-enable installed extensions

        # === Sidebery Vertical Tabs Support ===
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;  # Enable userChrome.css
      };

      # === Search Engine Configuration ===
      search = {
        default = "Google";  # ✅ User requested Google (not "brave" from old config)
        force = true;

        # Optional: Add Gemini if available as search engine extension
        # engines = {
        #   "Gemini" = {
        #     urls = [{
        #       template = "https://gemini.google.com/app?q={searchTerms}";
        #     }];
        #     iconUpdateURL = "https://www.google.com/favicon.ico";
        #     definedAliases = [ "@gemini" ];
        #   };
        # };
      };

      # === userChrome.css for Sidebery ===
      # Decision: Use home-manager (not chezmoi) for atomic config management
      # See ultrathink findings for ADR-009 discussion
      userChrome = ''
        /* ===== SIDEBERY VERTICAL TABS ===== */
        /* Hide native horizontal tab bar when Sidebery is used */
        #TabsToolbar {
          visibility: collapse !important;
        }

        /* Hide sidebar header for cleaner look */
        #sidebar-header {
          display: none !important;
        }

        /* Optimize sidebar for Sidebery */
        #sidebar-box {
          max-width: none !important;
          min-width: 250px !important;
        }

        /* Sidebery-specific optimizations */
        #sidebar-box[sidebarcommand="viewSidebery_sidebery-sidebar"] {
          min-width: 320px !important;
          max-width: 450px !important;
        }
      '';
    };
  };

  # === Session Variables ===
  # Note: NVIDIA vars already set globally in brave.nix
  # Only Firefox-specific vars here
  home.sessionVariables = {
    # X11 smooth scrolling (NOT Wayland!)
    MOZ_USE_XINPUT2 = "1";

    # WebRender enforcement
    MOZ_WEBRENDER = "1";

    # DO NOT SET MOZ_ENABLE_WAYLAND - User is on X11!
  };
}
```

### Step 1.2: Import in home.nix

```nix
# Edit home-manager/home.nix
imports = [
  # ... existing imports
  ./firefox.nix
];
```

### Step 1.3: Remove Duplicate Config from home.nix

```bash
# Comment out lines 372-434 in home.nix (old Firefox config)
# Keep as reference during testing, delete after Phase 7
```

### Step 1.4: Test Build

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
home-manager build --flake .#mitsio@shoshin
```

### Step 1.5: Success Criteria

- [ ] firefox.nix created and imported
- [ ] Build succeeds without errors
- [ ] All existing settings preserved
- [ ] Search engine changed from "brave" to "Google"
- [ ] NO Wayland variables set (X11 only)

---

## Phase 2: Declarative Extensions

**Duration:** 3-4 hours
**Goal:** Install all 12 user-requested extensions + migrate existing extensions
**Confidence:** 0.82 (Band C)

### Step 2.1: User-Requested Extensions Mapping

**12 Extensions Explicitly Requested:**

| # | Extension Name | Extension ID | XPI URL | Notes |
|---|---------------|--------------|---------|-------|
| 1 | **Plasma Integration** | `plasma-browser-integration@kde.org` | `https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi` | KDE Desktop integration |
| 2 | **KeePassXC-Browser** | `keepassxc-browser@keepassxc.org` | `https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi` | Password manager |
| 3 | **Sidebery** | `{3c078156-979c-498b-8990-85f7987dd929}` | `https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi` | **Vertical tabs (PRIMARY)** |
| 4 | **Bitwarden** | `{446900e4-71c2-419f-a6a7-df9c091e268b}` | `https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi` | Password manager |
| 5 | **FireShot** | `{0b457cAA-602d-484a-8fe7-c1d894a011ba}` | `https://addons.mozilla.org/firefox/downloads/latest/full-page-screen-capture-/latest.xpi` | Full page screenshots |
| 6 | **Default Bookmark Folder** | `default-bookmark-folder@gustiaux.com` | `https://addons.mozilla.org/firefox/downloads/latest/default-bookmark-folder/latest.xpi` | Bookmark organization |
| 7 | **Floccus** | `floccus@handmadeideas.org` | `https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi` | Bookmark sync (already installed) |
| 8 | **Multi-Account Containers** | `@testpilot-containers` | `https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi` | Container management (already installed) |
| 9 | **Gmail Mail Sidebar** | `@gmail-sidebar` | `https://addons.mozilla.org/firefox/downloads/latest/gmail-mail-sidebar/latest.xpi` | Gmail in sidebar |
| 10 | **Container Tabs Sidebar** | `@container-tabs-sidebar` | `https://addons.mozilla.org/firefox/downloads/latest/container-tabs-sidebar/latest.xpi` | Container tab management |
| 11 | **Google Tasks Sidebar** | `@google-tasks-sidebar` | `https://addons.mozilla.org/firefox/downloads/latest/google-tasks-sidebar/latest.xpi` | Google Tasks in sidebar |
| 12 | **Black Cat Sleep** | N/A (THEME, not extension) | `https://addons.mozilla.org/firefox/downloads/latest/black-cat-sleep/latest.xpi` | **THEME** (see note below) |

**IMPORTANT NOTE**: Black Cat Sleep is a **THEME**, not an extension. Themes are managed differently:

```nix
# Themes cannot be installed via ExtensionSettings
# User must install manually or use Firefox Sync
```

### Step 2.2: Update firefox.nix ExtensionSettings

**Edit: `home-manager/firefox.nix`**

Add to `programs.firefox.policies.ExtensionSettings`:

```nix
ExtensionSettings = {
  "*" = {
    installation_mode = "blocked";
  };

  # === Core Utilities ===
  "uBlock0@raymondhill.net" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    installation_mode = "force_installed";
  };

  # === Vertical Tabs (PRIMARY) ===
  "{3c078156-979c-498b-8990-85f7987dd929}" = {  # Sidebery
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
    installation_mode = "force_installed";
  };

  # === Password Managers ===
  "keepassxc-browser@keepassxc.org" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
    installation_mode = "force_installed";
  };

  "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {  # Bitwarden
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
    installation_mode = "force_installed";
  };

  # === KDE Integration ===
  "plasma-browser-integration@kde.org" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
    installation_mode = "force_installed";
  };

  # === Bookmarks & Sync ===
  "floccus@handmadeideas.org" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi";
    installation_mode = "force_installed";
  };

  "default-bookmark-folder@gustiaux.com" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/default-bookmark-folder/latest.xpi";
    installation_mode = "force_installed";
  };

  # === Containers ===
  "@testpilot-containers" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
    installation_mode = "force_installed";
  };

  "@container-tabs-sidebar" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/container-tabs-sidebar/latest.xpi";
    installation_mode = "force_installed";
  };

  # === Productivity - Sidebars ===
  "@gmail-sidebar" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/gmail-mail-sidebar/latest.xpi";
    installation_mode = "force_installed";
  };

  "@google-tasks-sidebar" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/google-tasks-sidebar/latest.xpi";
    installation_mode = "force_installed";
  };

  # === Utilities ===
  "{0b457cAA-602d-484a-8fe7-c1d894a011ba}" = {  # FireShot
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/full-page-screen-capture-/latest.xpi";
    installation_mode = "force_installed";
  };

  # === Currently Installed (Discovered in Phase 0) ===
  # User must add remaining extensions discovered in about:support
  # Example:
  # "tab-stash@condordes.net" = {
  #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-stash/latest.xpi";
  #   installation_mode = "force_installed";
  # };
};
```

### Step 2.3: Build and Apply

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
home-manager switch --flake .#mitsio@shoshin -b backup-extensions
```

### Step 2.4: Verify Extensions Auto-Enable

```bash
# Start Firefox
firefox &

# Navigate to about:addons
# All extensions should appear and be ENABLED automatically
```

### Step 2.5: Remove Tree Style Tab

**Tree Style Tab** is now **replaced by Sidebery** per user request. After successful Sidebery installation:

1. Verify Sidebery is working (vertical tabs visible)
2. Manually uninstall Tree Style Tab from `about:addons`
3. Confirm native tab bar is hidden via userChrome.css

### Step 2.6: Success Criteria

- [ ] All 12 user-requested extensions installed
- [ ] Extensions auto-enabled (no manual approval needed)
- [ ] Sidebery vertical tabs functional
- [ ] Tree Style Tab removed
- [ ] Black Cat Sleep theme installed manually (if desired)

---

## Phase 3: GPU Optimization (NVIDIA)

**Duration:** 1 hour
**Goal:** Verify and optimize NVIDIA GPU acceleration
**Confidence:** 0.85 (Band C)

### Step 3.1: Verify Session Variables

```bash
# Check NVIDIA variables (should already be set from brave.nix)
env | grep -E 'LIBVA|GBM|GLX|MOZ'

# Expected output:
# LIBVA_DRIVER_NAME=nvidia
# GBM_BACKEND=nvidia-drm
# __GLX_VENDOR_LIBRARY_NAME=nvidia
# MOZ_USE_XINPUT2=1
# MOZ_WEBRENDER=1
```

### Step 3.2: Test GPU Acceleration

**Open Firefox → Navigate to `about:support`**

Check **Graphics section**:

| Setting | Expected Value |
|---------|----------------|
| Compositing | **WebRender** or **OpenGL** |
| GPU #1 Active | **Yes** |
| GPU #1 Description | **NVIDIA** (your GPU model) |
| WebGL 1 Driver Renderer | **NVIDIA** |
| WebGL 2 Driver Renderer | **NVIDIA** |
| Hardware Video Decoding | **Enabled** (VA-API) |

### Step 3.3: Test Video Acceleration

```bash
# Open YouTube 4K video
firefox 'https://www.youtube.com/watch?v=LXb3EKWsInQ' &

# Monitor GPU usage
watch -n1 nvidia-smi
```

**Expected**: GPU Video Engine usage should show activity during playback.

### Step 3.4: Troubleshooting

**If GPU acceleration NOT working:**

```nix
# Add to firefox.nix profiles.default.settings:
"gfx.x11-egl.force-enabled" = true;
"media.ffvpx.enabled" = false;  # Force hardware decoding
```

### Step 3.5: Success Criteria

- [ ] `about:support` shows WebRender compositing
- [ ] GPU #1 Active = Yes
- [ ] Video playback uses GPU (nvidia-smi shows activity)
- [ ] No software rendering fallback

---

## Phase 4: RAM & CPU Tuning

**Duration:** 30 minutes
**Goal:** Validate and enhance memory/CPU optimizations
**Confidence:** 0.90 (Band C)

### Step 4.1: Current Settings (Already Configured in Phase 1)

✅ **Already Applied**:
- Memory cache: 512MB
- Disk cache: 350MB
- Content processes: 4
- Tab unloading: Enabled
- Session history viewers: 2

### Step 4.2: Optional Additional Tuning

**Add to firefox.nix if RAM usage still high:**

```nix
# Advanced memory optimizations
"browser.cache.memory.max_entry_size" = 512;  # KB
"browser.tabs.min_inactive_duration_before_unload" = 300000;  # 5 min
"fission.autostart" = true;  # Site isolation
"dom.ipc.processCount.webIsolated" = 2;  # Isolated processes

# CPU optimizations
"browser.tabs.remote.warmup.enabled" = false;
"browser.tabs.remote.warmup.maxTabs" = 0;
"ui.prefersReducedMotion" = 1;  # Disable animations
"network.http.speculative-parallel-limit" = 0;
"network.dns.disablePrefetch" = true;
"network.prefetch-next" = false;
```

### Step 4.3: Monitor Performance

```bash
# Before optimization
ps aux | grep firefox | awk '{sum+=$6} END {print "Firefox RAM: " sum/1024 " MB"}'

# Open 10-15 tabs, wait 5 minutes
# After optimization - RAM should be lower
```

### Step 4.4: Success Criteria

- [ ] Firefox RAM usage < 2GB with 10 tabs open
- [ ] CPU usage < 5% when idle
- [ ] Tab unloading working (inactive tabs turn gray in Sidebery)

---

## Phase 5: Sidebery Vertical Tabs

**Duration:** 1-2 hours
**Goal:** Configure Sidebery for optimal vertical tab experience
**Confidence:** 0.83 (Band C)

### Step 5.1: Verify Native Tab Bar Hidden

After Phase 1 userChrome.css application:

1. Start Firefox
2. Native horizontal tab bar should be **completely hidden**
3. Only Sidebery sidebar should be visible

**If native tabs still visible**:

```bash
# Check that userChrome.css was applied
ls -la ~/.mozilla/firefox/*.default*/chrome/userChrome.css

# Restart Firefox with cache clear
firefox --ProfileManager
# Select profile → Restart
```

### Step 5.2: Open Sidebery Sidebar

**Keyboard shortcut**: `Ctrl+E` (or F1, depending on Sidebery config)

Or:
1. View → Sidebar → Sidebery

### Step 5.3: Configure Sidebery Settings

**Access**: Right-click in Sidebery → Settings

**Recommended Configuration**:

**General**:
- ✅ Auto-hide sidebar when not in use: **NO** (always visible)
- ✅ Tabs Tree Limit: **3 levels** (prevent deep nesting)

**Tabs**:
- ✅ Tree structure: **Enabled**
- ✅ Colorize tabs: **By domain**
- ✅ Show close button: **On hover**
- ✅ Tabs sorting: **Manual** (drag and drop)

**Panels**:
- Create panels for different workflows:
  1. **Default** (all tabs)
  2. **Work** (bind to Work container)
  3. **Personal** (bind to Personal container)
  4. **Banking** (bind to Banking container)

**Containers Integration**:
- ✅ Automatically reopen tabs in target container by URL
- ✅ Setup proxy/UserAgent per container (if needed)

**Styles**:
- Choose theme: **Proton** or **Compact**
- Sidebar width: **320px** (matches userChrome.css)

### Step 5.4: Test Vertical Tabs

1. Open multiple tabs
2. Tabs should appear vertically in Sidebery
3. Native tab bar should be hidden
4. Drag tabs to create tree structure
5. Test tab grouping (containers)

### Step 5.5: Sidebery Snapshots (Optional)

Enable auto-snapshots:
- Settings → Snapshots → Enable auto snapshots
- Frequency: **Daily**
- Retention: **7 days**

### Step 5.6: Success Criteria

- [ ] Native horizontal tab bar completely hidden
- [ ] Sidebery sidebar always visible (or auto-hide working)
- [ ] Vertical tabs display correctly
- [ ] Tree structure works (parent/child tabs)
- [ ] Container-based panels configured

---

## Phase 6: Search Engine & Sync

**Duration:** 30 minutes
**Goal:** Configure Google search and Firefox Sync
**Confidence:** 0.92 (Band C)

### Step 6.1: Verify Search Engine

After Phase 1 application, search engine should be **Google**.

**Test**:
1. Open new tab
2. Type search query in address bar
3. Verify it searches via Google (not Brave)

**If still using Brave**:
```bash
# Check settings applied
grep -A5 'search' ~/.mozilla/firefox/*.default*/prefs.js
```

### Step 6.2: Optional: Add Gemini Search

**Note**: Gemini doesn't have a native search engine integration yet. Two options:

**Option A: Bookmark**
```
https://gemini.google.com/app
```

**Option B: Keyword Search**
1. Go to `https://gemini.google.com/app`
2. Right-click address bar → "Add a Keyword for this Search"
3. Keyword: `@gemini`

### Step 6.3: Firefox Sync Setup

**Prerequisites**:
- Mozilla account credentials stored in KeePassXC (per user request)

**Steps**:
1. Firefox → Settings → Firefox Account
2. Sign in with Mozilla account
3. Choose what to sync:
   - ✅ Bookmarks
   - ✅ History
   - ✅ Open Tabs
   - ✅ Passwords (optional, if not using KeePassXC exclusively)
   - ❌ **Add-ons** (DISABLED - managed declaratively!)
   - ✅ Preferences (partial sync, non-conflicting)

**CRITICAL**: **Disable add-on sync** to prevent conflicts with declarative extension management!

### Step 6.4: Store Mozilla Account Credentials in KeePassXC

```bash
# Open KeePassXC
keepassxc &

# Create entry:
# Title: Mozilla Firefox Sync Account
# Username: your-email@example.com
# Password: (your Mozilla account password)
# URL: https://accounts.firefox.com
# Group: Browsers/Firefox
```

### Step 6.5: Success Criteria

- [ ] Default search engine is Google
- [ ] Gemini accessible via bookmark or keyword (optional)
- [ ] Firefox Sync enabled and working
- [ ] Add-on sync DISABLED
- [ ] Mozilla credentials stored in KeePassXC

---

## Phase 7: Testing & Validation

**Duration:** 2-3 hours
**Goal:** Comprehensive testing of entire configuration
**Confidence:** 0.80 (Band C)

### Step 7.1: Full System Test Checklist

**Environment**:
```bash
# Clean test: Close all Firefox instances
pkill firefox
sleep 2

# Start fresh
firefox &
```

**Test Matrix**:

| Component | Test | Expected Result | Status |
|-----------|------|-----------------|--------|
| **Build** | `home-manager build` | Success, no errors | ☐ |
| **Extensions** | Open `about:addons` | 11 extensions installed & enabled | ☐ |
| **Extensions** | Check Sidebery | Vertical tabs visible | ☐ |
| **Extensions** | Check KeePassXC | Connected to vault | ☐ |
| **Extensions** | Check Plasma Integration | Media controls work | ☐ |
| **GPU** | Open `about:support` | WebRender active | ☐ |
| **GPU** | Play YouTube 4K | GPU usage in nvidia-smi | ☐ |
| **Memory** | Open 10 tabs, wait 5 min | RAM < 2GB | ☐ |
| **Memory** | Check inactive tabs | Tabs unloaded/grayed out | ☐ |
| **Tabs** | Native tab bar | **Hidden** | ☐ |
| **Tabs** | Sidebery sidebar | Visible with vertical tabs | ☐ |
| **Tabs** | Create tab tree | Parent/child structure works | ☐ |
| **Search** | Search from address bar | Uses Google | ☐ |
| **Sync** | Sign in to Mozilla | Sync enabled, add-ons disabled | ☐ |
| **Sync** | Check synced data | Bookmarks/history syncing | ☐ |
| **UserChrome** | Restart Firefox | userChrome.css persists | ☐ |

### Step 7.2: Performance Benchmarks

**Memory Test**:
```bash
# Start Firefox
firefox &
sleep 10

# Baseline
ps aux | grep firefox | awk '{sum+=$6} END {print "Baseline RAM: " sum/1024 " MB"}'

# Open 15 tabs (mix of sites)
# Wait 5 minutes

# Check RAM again
ps aux | grep firefox | awk '{sum+=$6} END {print "15-tab RAM: " sum/1024 " MB"}'
```

**GPU Test**:
```bash
# Play 4K 60fps video
firefox 'https://www.youtube.com/watch?v=LXb3EKWsInQ' &

# Monitor GPU in another terminal
watch -n1 nvidia-smi

# Expected: Video Decode usage > 0%
```

### Step 7.3: Regression Testing

**Compare with Baseline (Phase 0 backup)**:

| Metric | Before (Manual Config) | After (Declarative) | Change |
|--------|----------------------|---------------------|--------|
| Extensions | 17 | 11+ (user to verify) | Declarative |
| RAM (10 tabs) | ? MB | < 2000 MB | Target |
| GPU Active | ? | Yes | ✅ |
| Build Reproducible | No | Yes | ✅ |
| Vertical Tabs | Tree Style Tab | Sidebery | ✅ |

### Step 7.4: Failure Scenarios

**Test rollback**:
```bash
# Switch to backup generation
home-manager generations | head -5
# Find previous generation number

home-manager rollback --to <generation>
```

**Test profile recovery**:
```bash
# Restore from backup if catastrophic failure
rm -rf ~/.mozilla/firefox/*.default*
cp -r ~/firefox-backup-20251214 ~/.mozilla/firefox/
```

### Step 7.5: Success Criteria

- [ ] All 17 tests in matrix pass
- [ ] RAM usage acceptable (< 2GB with 10 tabs)
- [ ] GPU acceleration confirmed (nvidia-smi)
- [ ] Rollback tested and working
- [ ] No regressions from manual config

---

## Phase 8: Documentation

**Duration:** 1-2 hours
**Goal:** Document configuration for future maintenance
**Confidence:** 0.95 (Band C)

### Step 8.1: Create Firefox Documentation

**File: `docs/firefox/README.md`**

```markdown
# Firefox Declarative Configuration

**Status**: ✅ Active (Migrated 2025-12-14)
**Configuration**: `home-manager/firefox.nix`
**Backup**: `~/firefox-backup-20251214/`

## Quick Reference

### Rebuild Firefox Config
\`\`\`bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
home-manager switch --flake .#mitsio@shoshin
\`\`\`

### Add New Extension
Edit \`firefox.nix\`, add to \`ExtensionSettings\`:
\`\`\`nix
"extension-id@example.com" = {
  install_url = "https://addons.mozilla.org/firefox/downloads/latest/extension-name/latest.xpi";
  installation_mode = "force_installed";
};
\`\`\`

### Check GPU Acceleration
\`\`\`bash
firefox about:support
# Look for: Compositing = WebRender, GPU #1 Active = Yes
\`\`\`

### Troubleshooting

**Extensions not auto-enabling?**
Check \`extensions.autoDisableScopes = 0\` in settings.

**Native tabs still visible?**
Check \`~/.mozilla/firefox/*.default*/chrome/userChrome.css\` exists.

**GPU not working?**
Check session variables: \`env | grep -E 'LIBVA|GBM|MOZ'\`

## Architecture

- **Package Installation**: home-manager (firefox.nix)
- **Extension Management**: Enterprise Policies (force_installed)
- **UI Customization**: userChrome.css (Sidebery vertical tabs)
- **Secrets**: KeePassXC (Mozilla account credentials)
- **Sync**: Enabled (bookmarks/history), add-ons DISABLED

## Extension List

See: \`firefox.nix\` \`ExtensionSettings\` section

## Related Documentation

- Ultrathink Findings: \`docs/researches/2025-12-14_FIREFOX_RESEARCH_ULTRATHINK_FINDINGS.md\`
- Original Research: \`docs/researches/2025-12-14_FIREFOX_DECLARATIVE_CONFIGURATION_RESEARCH.md\`
- Implementation Plan: \`docs/plans/2025-12-14_FIREFOX_COMPREHENSIVE_IMPLEMENTATION_PLAN.md\` (this file)
```

### Step 8.2: Update ADR References

**File: `docs/adrs/ADR-009-BASH_SHELL_ENHANCEMENT_CONFIGURATION.md`**

Add Firefox as example:

```markdown
### Example 3: Firefox (Hybrid Approach)

**Home-Manager (home-manager/firefox.nix)**:
- Package installation
- Enterprise policies
- about:config settings
- userChrome.css (UI customization) - EXCEPTION to ADR-009

**Chezmoi**: N/A (all configuration in home-manager for atomic management)

**Rationale**: userChrome.css placed in home-manager for atomic config updates, despite ADR-009 recommending chezmoi for config files. Trade-off accepted for single-source-of-truth.
```

### Step 8.3: Create Troubleshooting Guide

**File: `docs/firefox/TROUBLESHOOTING.md`**

(See Appendix C for full content)

### Step 8.4: Update TODO.md

Mark Firefox configuration as complete in `docs/TODO.md`.

### Step 8.5: Success Criteria

- [ ] `docs/firefox/README.md` created
- [ ] ADR-009 updated with Firefox example
- [ ] Troubleshooting guide created
- [ ] TODO.md updated
- [ ] All implementation steps documented

---

## Rollback Strategy

### Scenario 1: Build Fails (Phase 1-2)

```bash
# Revert firefox.nix changes
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
git diff firefox.nix
git checkout firefox.nix

# Rebuild
home-manager switch --flake .#mitsio@shoshin
```

### Scenario 2: Firefox Won't Start (Phase 3-5)

```bash
# Use home-manager rollback
home-manager generations
home-manager rollback --to <last-working-generation>

# Restart Firefox
pkill firefox
firefox &
```

### Scenario 3: Complete Failure (Phase 6-7)

```bash
# Restore from backup
pkill firefox
rm -rf ~/.mozilla/firefox/*.default*
cp -r ~/firefox-backup-20251214 ~/.mozilla/firefox/

# Revert home-manager config
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
git log --oneline | head -5
git revert <commit-hash>
home-manager switch --flake .#mitsio@shoshin
```

### Scenario 4: Extension Conflicts

```bash
# Remove conflicting extension from firefox.nix
# Rebuild without that extension
# Test again
```

---

## Appendix: Extension Reference

### Complete Extension Mapping

**(Based on user's request + currently installed)**

| Extension Name | Extension ID | URL Slug | Status |
|---------------|--------------|----------|--------|
| Plasma Integration | `plasma-browser-integration@kde.org` | plasma-integration | ✅ Requested |
| KeePassXC-Browser | `keepassxc-browser@keepassxc.org` | keepassxc-browser | ✅ Requested |
| Sidebery | `{3c078156-979c-498b-8990-85f7987dd929}` | sidebery | ✅ Requested (PRIMARY vertical tabs) |
| Bitwarden | `{446900e4-71c2-419f-a6a7-df9c091e268b}` | bitwarden-password-manager | ✅ Requested |
| FireShot | `{0b457cAA-602d-484a-8fe7-c1d894a011ba}` | full-page-screen-capture- | ✅ Requested |
| Default Bookmark Folder | `default-bookmark-folder@gustiaux.com` | default-bookmark-folder | ✅ Requested |
| Floccus | `floccus@handmadeideas.org` | floccus | ✅ Requested + Installed |
| Multi-Account Containers | `@testpilot-containers` | multi-account-containers | ✅ Requested + Installed |
| Gmail Mail Sidebar | (TBD - see about:support) | gmail-mail-sidebar | ✅ Requested |
| Container Tabs Sidebar | (TBD - see about:support) | container-tabs-sidebar | ✅ Requested |
| Google Tasks Sidebar | (TBD - see about:support) | google-tasks-sidebar | ✅ Requested |
| uBlock Origin | `uBlock0@raymondhill.net` | ublock-origin | ✅ Installed (keep) |
| Tab Stash | `tab-stash@condordes.net` | (TBD - user decision) | ❓ Installed (keep or remove?) |
| Tree Style Tab | `treestyletab@piro.sakura.ne.jp` | tree-style-tab | ❌ Remove (replaced by Sidebery) |

**Themes** (not extensions, manual install only):
- Black Cat Sleep: Manual installation required (themes not supported via ExtensionSettings)

---

## Timeline & Milestones

### Week 1: Discovery & Foundation (Phases 0-1)
- Day 1: Extension discovery (Phase 0)
- Day 2-3: Create firefox.nix module (Phase 1)
- Day 4: Test build and apply

### Week 2: Extensions & GPU (Phases 2-3)
- Day 1-2: Add all extensions (Phase 2)
- Day 3: Verify extensions auto-enable
- Day 4: GPU optimization (Phase 3)

### Week 3: Optimization & Vertical Tabs (Phases 4-5)
- Day 1: RAM/CPU tuning (Phase 4)
- Day 2-3: Sidebery configuration (Phase 5)
- Day 4: Search & Sync (Phase 6)

### Week 4: Testing & Documentation (Phases 7-8)
- Day 1-2: Comprehensive testing (Phase 7)
- Day 3: Documentation (Phase 8)
- Day 4: Final validation and commit

---

## Risk Assessment

### High Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Extension UUID mismatch | Medium | High | Use exact IDs from about:support |
| GPU acceleration fails | Low | Medium | Comprehensive testing, rollback ready |
| Sync conflicts | Medium | Medium | Disable add-on sync explicitly |

### Medium Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| userChrome.css not applied | Low | Low | Clear cache, restart Firefox |
| Memory usage higher than expected | Medium | Low | Additional tuning in Phase 4 |

### Low Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Theme not compatible | Low | Low | Manual installation fallback |
| Search engine reverts | Low | Low | Force search engine in config |

---

## Success Metrics

**Quantitative**:
- [ ] 11+ extensions installed declaratively
- [ ] RAM usage < 2GB with 10 tabs
- [ ] GPU acceleration active (nvidia-smi shows Video Decode)
- [ ] Build time < 5 minutes
- [ ] Zero manual Firefox configuration required

**Qualitative**:
- [ ] User satisfied with Sidebery vertical tabs
- [ ] Firefox Sync working for bookmarks/history
- [ ] Configuration reproducible on fresh install
- [ ] Rollback tested and functional

---

## Next Actions

1. **Immediate**: User completes Phase 0 (extension discovery via about:support)
2. **This Week**: Phases 1-2 (firefox.nix + extensions)
3. **Next Week**: Phases 3-5 (GPU + optimization + Sidebery)
4. **Week 3**: Phases 6-7 (Sync + testing)
5. **Week 4**: Phase 8 (documentation) + final commit

---

**Plan Status:** ✅ READY FOR EXECUTION
**Plan Confidence:** 0.84 (Band C - HIGH)
**Estimated Total Time:** 20-25 hours (phased over 4 weeks)
**Risk Level:** MEDIUM (comprehensive testing mitigates)

**Planner:** Technical Planner (Sonnet 4.5)
**Date:** 2025-12-14T18:45:00+02:00 (Europe/Athens)

---

**End of Implementation Plan**
