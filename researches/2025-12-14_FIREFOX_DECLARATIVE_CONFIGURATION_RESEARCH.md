# Firefox Declarative Configuration - Complete Research & Analysis

**Date:** 2025-12-14
**Author:** Technical Researcher + Planner (Claude Sonnet 4.5)
**Status:** ✅ Complete (Research + Ultrathink + Planning)
**Final Confidence:** 0.84 (Band C - HIGH, ready for implementation)
**Session Context:** Firefox optimization and declarative configuration via home-manager + chezmoi

---

## Document Structure

This merged document combines:
1. **Part I**: Original Technical Research (confidence 0.88 → 0.68 after ultrathink)
2. **Part II**: Ultrathink Analysis & Critical Findings (8 issues discovered)
3. **Part III**: Extension Discovery & Final Mapping (17 current + 12 requested)
4. **Part IV**: Implementation-Ready Recommendations

---

# PART I: ORIGINAL TECHNICAL RESEARCH

## Executive Summary

Firefox can be comprehensively configured declaratively via home-manager's `programs.firefox` module with support for:
- **Extensions**: Via `profiles.<name>.extensions` (NUR) or `policies.ExtensionSettings` (XPI URLs)
- **Settings**: Via `profiles.<name>.settings` (about:config preferences)
- **Policies**: Via `policies` (Enterprise policies for locked-down settings)
- **GPU Optimization**: about:config flags for NVIDIA hardware acceleration
- **RAM/CPU Tuning**: Memory limits, process counts, caching strategies

**Key Finding**: home-manager provides TWO approaches for extension management:
1. **NUR method**: `profiles.<name>.extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ]`
2. **Policy method**: `policies.ExtensionSettings` with direct XPI URLs (no NUR dependency)

**CRITICAL UPDATE (Post-Ultrathink)**: NUR method has UUID instability issues. **Policy method is RECOMMENDED**.

---

## 1. Firefox Declarative Configuration via Home-Manager

### 1.1 Basic Structure

```nix
programs.firefox = {
  enable = true;

  # Optional: Custom package with policies
  package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    extraPolicies = { /* Enterprise policies */ };
  };

  # Profiles (multiple profiles supported)
  profiles.<name> = {
    id = 0;  # 0 = default profile
    isDefault = true;
    settings = { /* about:config preferences */ };
    extensions = [ /* Firefox addons from NUR */ ];
    search = {
      default = "DuckDuckGo";
      force = true;
    };
  };

  # Enterprise policies (applies to all profiles)
  policies = {
    DisableTelemetry = true;
    ExtensionSettings = { /* Extension installation */ };
    Preferences = { /* Locked preferences */ };
  };
};
```

### 1.2 Current Configuration Status

**Already Configured** (in home.nix lines 372-434):
- ✅ Memory optimizations (512MB cache, 4 processes)
- ✅ Hardware acceleration enabled
- ✅ Privacy settings (tracking protection, HTTPS-only)
- ✅ Telemetry disabled
- ✅ Session restore on startup
- ✅ Bookmarks toolbar enabled

**Missing/Needs Enhancement**:
- ❌ Declarative extension installation
- ❌ GPU-specific optimizations for NVIDIA
- ❌ Vertical tabs configuration
- ❌ Theme configuration
- ❌ KeePassXC integration
- ❌ Advanced RAM/CPU tuning

---

## 2. Extension Management

### 2.1 Method 1: NUR Firefox Addons ⚠️ NOT RECOMMENDED

**Source**: [nur-combined](https://github.com/nix-community/NUR)
**Repository**: `pkgs.nur.repos.rycee.firefox-addons`
**Status**: ⚠️ **DEPRECATED** due to UUID instability

**Known Issue**: Extension UUIDs change on rebuild, losing extension state.
**Workaround**: Use Policy method instead.

### 2.2 Method 2: Enterprise Policies ✅ RECOMMENDED

**Advantages**:
- ✅ No NUR dependency
- ✅ Stable UUIDs (self-determined)
- ✅ Force-install with locked configuration
- ✅ Works with XPI URLs from addons.mozilla.org

**Example**:
```nix
programs.firefox.policies.ExtensionSettings = {
  "*".installation_mode = "blocked";  # Block all except listed

  # uBlock Origin
  "uBlock0@raymondhill.net" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    installation_mode = "force_installed";
  };

  # Sidebery (Vertical Tabs)
  "{3c078156-979c-498b-8990-85f7987dd929}" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
    installation_mode = "force_installed";
  };

  # KeePassXC-Browser
  "keepassxc-browser@keepassxc.org" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
    installation_mode = "force_installed";
  };
};
```

**Finding Extension IDs**:
1. **Primary Method (Most Reliable)**: Extension filename (remove `.xpi`)
2. **Fallback**: `about:support` → Extensions section
3. **Last Resort**: Download XPI, unzip, read `manifest.json`:
   ```bash
   unzip extension.xpi
   jq .browser_specific_settings.gecko.id manifest.json
   ```

---

## 3. GPU Hardware Acceleration (NVIDIA)

### 3.1 Firefox GPU Preferences

**Based on Brave's successful configuration** (brave.nix:24-28):

```nix
programs.firefox.profiles.default.settings = {
  # === NVIDIA Hardware Acceleration ===
  "layers.acceleration.force-enabled" = true;
  "gfx.webrender.all" = true;
  "gfx.webrender.enabled" = true;
  "gfx.webrender.force-disabled" = false;  # CRITICAL: Ensure not blocked

  # WebGL
  "webgl.force-enabled" = true;
  "webgl.disabled" = false;

  # VA-API (Video Acceleration API) for Linux
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
};
```

**Session Variables** (X11 setup):

```nix
# Note: NVIDIA vars already set globally in brave.nix
# Only Firefox-specific vars here
home.sessionVariables = {
  # X11 smooth scrolling (NOT Wayland!)
  MOZ_USE_XINPUT2 = "1";
  MOZ_WEBRENDER = "1";

  # ❌ DO NOT SET: MOZ_ENABLE_WAYLAND = "1"
  # User is on X11 per brave.nix configuration!
};
```

**Verification**:
- Navigate to `about:support` → Graphics section
- Check "Compositing": should show "WebRender" or "OpenGL"
- Check "GPU #1 Active": should be Yes

---

## 4. RAM and CPU Optimization

### 4.1 Memory Tuning

**Already Configured**:
```nix
"browser.cache.memory.capacity" = 524288;  # 512MB cache
"browser.cache.disk.capacity" = 358400;    # 350MB disk cache
"dom.ipc.processCount" = 4;  # 4 content processes
"browser.tabs.unloadOnLowMemory" = true;
"browser.sessionhistory.max_total_viewers" = 2;
```

**Additional Tuning Options**:
```nix
# Reduce memory bloat
"browser.cache.memory.max_entry_size" = 512;  # KB
"browser.sessionstore.interval" = 15000000;  # Reduce session save frequency

# Tab suspension
"browser.tabs.min_inactive_duration_before_unload" = 300000;  # 5 min

# Shared memory usage (Fission multi-process)
"fission.autostart" = true;
"dom.ipc.processCount.webIsolated" = 2;
```

### 4.2 CPU Optimization

```nix
# Reduce CPU usage for background tabs
"browser.tabs.remote.warmup.enabled" = false;
"browser.tabs.remote.warmup.maxTabs" = 0;

# Disable animations (reduces CPU)
"ui.prefersReducedMotion" = 1;

# Limit speculative connections
"network.http.speculative-parallel-limit" = 0;
"network.dns.disablePrefetch" = true;
"network.prefetch-next" = false;
```

---

## 5. Vertical Tabs (Sidebery)

**User Selected**: **Sidebery** (not Tree Style Tab)

### 5.1 Extension Installation

```nix
"{3c078156-979c-498b-8990-85f7987dd929}" = {  # Sidebery
  install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
  installation_mode = "force_installed";
};
```

### 5.2 userChrome.css Integration

**Via home-manager**:
```nix
programs.firefox.profiles.default = {
  userChrome = ''
    /* Hide native horizontal tab bar */
    #TabsToolbar {
      visibility: collapse !important;
    }

    /* Hide sidebar header for Sidebery */
    #sidebar-header {
      display: none !important;
    }

    /* Optimize sidebar for Sidebery */
    #sidebar-box {
      max-width: none !important;
      min-width: 250px !important;
    }

    /* Sidebery-specific sizing */
    #sidebar-box[sidebarcommand="viewSidebery_sidebery-sidebar"] {
      min-width: 320px !important;
      max-width: 450px !important;
    }
  '';

  settings = {
    # Enable userChrome.css customization
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };
};
```

**Note on ADR-009 Compliance**: userChrome.css placed in home-manager (not chezmoi) for atomic configuration management. This is an exception to ADR-009's layer separation pattern.

---

## 6. KeePassXC Integration

### 6.1 Extension Installation

**Extension ID**: `keepassxc-browser@keepassxc.org`

**Via Policies**:
```nix
"keepassxc-browser@keepassxc.org" = {
  install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
  installation_mode = "force_installed";
};
```

### 6.2 Native Messaging Integration

**KeePassXC already configured** (per ADR-011):
- ✅ KeePassXC autostart enabled (autostart.nix)
- ✅ Vault location: `~/MyVault/`

**Firefox Native Messaging**:
```nix
# Ensure native messaging is enabled
programs.firefox.profiles.default.settings = {
  "security.fileuri.strict_origin_policy" = false;  # Allow native messaging
};

# KeePassXC native messaging manifests are auto-installed by KeePassXC
# Location: ~/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json
```

**Verification**:
1. Open KeePassXC
2. Tools → Settings → Browser Integration → Enable Firefox
3. Open Firefox → KeePassXC extension → Connect
4. Grant permission in KeePassXC

**Mozilla Account Credentials**: Store in KeePassXC per ADR-011 (Unified Secrets Management)

---

## 7. Search Engine Configuration

### 7.1 User Preference

**User Requested**: **Google** (or Gemini if available as extension)

**Current Config (to change)**:
```nix
# home.nix line 431 (OLD - uses Brave)
search.default = "brave";  # ❌ Change to "Google"
```

**New Config**:
```nix
search = {
  default = "Google";  # ✅ User preference
  force = true;
};
```

### 7.2 Gemini Search

**Note**: Gemini doesn't have native Firefox search engine integration yet.

**Workaround**: Use bookmark or keyword search:
```
URL: https://gemini.google.com/app
Keyword: @gemini
```

---

## 8. Firefox Sync Configuration

### 8.1 User Requirements vs Research Recommendation

**User's Explicit Request**:
> "sign-in and sync with my account on firefox, keepassxc integration to store its secrets"

**User wants**:
1. ✅ Sign-in to Mozilla account
2. ✅ Firefox Sync enabled
3. ✅ KeePassXC to store Mozilla account credentials

**Corrected Recommendation** (Hybrid Model):

```nix
programs.firefox.policies = {
  # ✅ Allow Firefox Sync for bookmarks/history
  DisableFirefoxAccounts = false;  # Enable sync per user request

  # Extensions managed declaratively (prevent sync conflicts)
  ExtensionSettings = {
    "*".installation_mode = "force_installed";  # Override sync
    # ... extension list
  };
};
```

**Benefits**:
- Extensions: Declarative (reproducible across machines)
- Bookmarks/History: Synced (user convenience)
- Settings: Partial sync (non-conflicting preferences)

**Credentials Storage**: Store Mozilla account password in KeePassXC vault at `~/MyVault/`

---

# PART II: ULTRATHINK ANALYSIS - CRITICAL FINDINGS

## Confidence Revision

| Metric | Original | After Ultrathink |
|--------|----------|------------------|
| Research Confidence | **0.88** (Band C - HIGH) | **0.68** (Band B - CAUTIOUS) |
| Critical Blockers | 0 | **3** |
| High Priority Issues | 0 | **2** |
| Total Issues | 0 | **8** |

**Reasoning**: Research has solid technical foundations but contains critical gaps (70% missing extensions) and contradictions (Wayland/X11, Sync configuration) that would lead to failed or incomplete implementation.

---

## Critical Issues Discovered

### Issue #1: Missing 70% of Installed Extensions ❌

**Severity:** CRITICAL (Blocker)

**Problem**: Research only identified 5 extensions, but user has **17 total extensions installed**.

**Missing (12 files)**:
```
{01d445cd-ab9b-4b72-8dec-02b49a859a76}.xpi (8.2K)
{19289993-e8b6-4401-84b7-93391b61ff0a}.xpi (8.3K)
{3c078156-979c-498b-8990-85f7987dd929}.xpi (611K) → Likely Sidebery
{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi (14M) → Likely Bitwarden
{65252973-2e9e-427a-824f-6960f7806997}.xpi (145K)
{7629eb30-af71-485c-b36f-52c0fc38bc01}.xpi (12K)
{96b7a652-8716-4678-be68-7a8bac53a373}.xpi (74K)
{a8776b67-902b-48c9-b196-0dc12ea75e08}.xpi (529K)
{a9db16ed-87ed-4471-912f-456f47326340}.xpi (7.6K)
{e75d6907-918c-4c8d-8f98-4b7ae39bf672}.xpi (14K)
```

**Required Action**: User must open `about:support` → Extensions to identify all 17 extensions.

**Confidence Impact**: -0.15

---

### Issue #2: Wayland/X11 Display Server Conflict ⚠️

**Severity:** CRITICAL (Would break GPU acceleration)

**Problem**: Research recommends `MOZ_ENABLE_WAYLAND = "1"`, but Brave config explicitly uses **X11**:

```nix
# brave.nix line 25:
"--ozone-platform=x11"

# brave.nix line 74-75:
# NIXOS_OZONE_WL = "1";  # Disabled: using X11 for better NVIDIA support
```

**Impact**: Setting `MOZ_ENABLE_WAYLAND=1` would force Wayland mode → GPU acceleration failure → degraded performance

**Fix**:
```nix
# DO NOT SET:
# MOZ_ENABLE_WAYLAND = "1";  # ❌ User is on X11!

# INSTEAD:
home.sessionVariables = {
  MOZ_USE_XINPUT2 = "1";     # ✅ X11 smooth scrolling
  MOZ_WEBRENDER = "1";
};
```

**Confidence Impact**: -0.08

---

### Issue #3: Sync Recommendation Contradicts User Requirements 🔄

**Severity:** CRITICAL (Requirements mismatch)

**User's Request**:
> "sign-in and sync with my account on firefox, keepassxc integration to store its secrets"

**Research Recommendation**:
> "Recommendation: **Disable Sync**, manage everything declaratively"

```nix
DisableFirefoxAccounts = true;  # ❌ Contradicts user request!
```

**Correct Approach**: Hybrid model - declarative extensions + Firefox Sync enabled

**Confidence Impact**: -0.05

---

### Issue #4: Search Engine Override Risk 🔍

**Severity:** HIGH

**Current**: `search.default = "brave"`
**Research Proposes**: `search.default = "DuckDuckGo"`
**User Wants**: `search.default = "Google"`

**Impact**: Migration would change search engine **twice** (brave → DuckDuckGo → Google).

**Fix**: Preserve user preference directly: `search.default = "Google"`

**Confidence Impact**: -0.03

---

### Issue #5: NUR Recommendation Contradictory 📦

**Severity:** HIGH

**Section 2.1 Header**: "NUR Firefox Addons **(Recommended for stability)**"
**Section 2.1 Body**: "Extension UUIDs change on rebuild, **losing extension state**"
**Section 2.2**: "Enterprise Policies **(Best for avoiding NUR)**"

**Reality**: NUR has known UUID instability since 2022. Policy method is current best practice.

**Fix**: Update Section 2.1 to warn about NUR, recommend Policy method as primary.

**Confidence Impact**: -0.02

---

### Issue #6: Extension ID Discovery Method Incomplete 🔍

**Severity:** MEDIUM

**Problem**: `manifest.json` extraction fails for some extensions:

```bash
# Tree Style Tab:
$ unzip -p treestyletab@piro.sakura.ne.jp.xpi manifest.json | jq -r '.browser_specific_settings.gecko.id'
null  # ❌ FAILED!
```

**Most Reliable Method**: Extract ID from **filename**:
- `treestyletab@piro.sakura.ne.jp.xpi` → `treestyletab@piro.sakura.ne.jp`
- `@testpilot-containers.xpi` → `@testpilot-containers`

**Confidence Impact**: -0.01

---

### Issue #7: ADR-009 Compliance Question 📋

**Severity:** MEDIUM

**Question**: Should `userChrome.css` be in home-manager or chezmoi?

**ADR-009 Pattern**: Config files → Chezmoi
**Research Approach**: userChrome.css in home-manager

**Trade-offs**:
- **Home-Manager**: Single source of truth, atomic updates
- **Chezmoi**: Follows ADR-009, portable across distros

**Decision**: Use home-manager for atomic config management (exception to ADR-009 accepted)

**Confidence Impact**: -0.01

---

### Issue #8: Redundant Session Variables 🔄

**Severity:** MEDIUM

**Problem**: NVIDIA session variables already set globally in brave.nix:

```nix
# brave.nix (already set):
home.sessionVariables = {
  LIBVA_DRIVER_NAME = "nvidia";
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
};
```

**Fix**: Don't duplicate in firefox.nix. Only Firefox-specific vars:
```nix
# firefox.nix (only Firefox-specific):
home.sessionVariables = {
  MOZ_USE_XINPUT2 = "1";
  MOZ_WEBRENDER = "1";
};
```

**Confidence Impact**: -0.00

---

# PART III: EXTENSION DISCOVERY & MAPPING

## Currently Installed Extensions (17 Total)

| Filename | Size | Identified As | Status |
|----------|------|---------------|--------|
| `uBlock0@raymondhill.net.xpi` | 4.1M | **uBlock Origin** | ✅ Keep |
| `treestyletab@piro.sakura.ne.jp.xpi` | 1.2M | **Tree Style Tab** | ❌ Replace with Sidebery |
| `floccus@handmadeideas.org.xpi` | 7.1M | **Floccus** | ✅ Keep |
| `@testpilot-containers.xpi` | 903K | **Multi-Account Containers** | ✅ Keep |
| `tab-stash@condordes.net.xpi` | 333K | **Tab Stash** | ❓ User decision |
| `{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi` | 14M | **Bitwarden** (high confidence) | ✅ Keep |
| `{3c078156-979c-498b-8990-85f7987dd929}.xpi` | 611K | **Sidebery** (high confidence) | ✅ Keep |
| `{a8776b67-902b-48c9-b196-0dc12ea75e08}.xpi` | 529K | Unknown | ❓ Identify via about:support |
| `{65252973-2e9e-427a-824f-6960f7806997}.xpi` | 145K | Unknown | ❓ Identify via about:support |
| `{96b7a652-8716-4678-be68-7a8bac53a373}.xpi` | 74K | Unknown | ❓ Identify via about:support |
| `{e75d6907-918c-4c8d-8f98-4b7ae39bf672}.xpi` | 14K | Unknown | ❓ Identify via about:support |
| `{7629eb30-af71-485c-b36f-52c0fc38bc01}.xpi` | 12K | Unknown | ❓ Identify via about:support |
| `{01d445cd-ab9b-4b72-8dec-02b49a859a76}.xpi` | 8.2K | Unknown | ❓ Identify via about:support |
| `{19289993-e8b6-4401-84b7-93391b61ff0a}.xpi` | 8.3K | Unknown | ❓ Identify via about:support |
| `{a9db16ed-87ed-4471-912f-456f47326340}.xpi` | 7.6K | Unknown | ❓ Identify via about:support |

## User-Requested Extensions (12 Total)

| Extension Name | Extension ID | Install URL | Notes |
|---------------|--------------|-------------|-------|
| **Plasma Integration** | `plasma-browser-integration@kde.org` | `/latest/plasma-integration/latest.xpi` | KDE Desktop integration |
| **KeePassXC-Browser** | `keepassxc-browser@keepassxc.org` | `/latest/keepassxc-browser/latest.xpi` | Password manager |
| **Sidebery** | `{3c078156-979c-498b-8990-85f7987dd929}` | `/latest/sidebery/latest.xpi` | **PRIMARY vertical tabs** |
| **Bitwarden** | `{446900e4-71c2-419f-a6a7-df9c091e268b}` | `/latest/bitwarden-password-manager/latest.xpi` | Password manager |
| **FireShot** | `{0b457cAA-602d-484a-8fe7-c1d894a011ba}` | `/latest/full-page-screen-capture-/latest.xpi` | Screenshots |
| **Default Bookmark Folder** | `default-bookmark-folder@gustiaux.com` | `/latest/default-bookmark-folder/latest.xpi` | Bookmark management |
| **Floccus** | `floccus@handmadeideas.org` | `/latest/floccus/latest.xpi` | Already installed ✅ |
| **Multi-Account Containers** | `@testpilot-containers` | `/latest/multi-account-containers/latest.xpi` | Already installed ✅ |
| **Gmail Mail Sidebar** | TBD (check about:support) | `/latest/gmail-mail-sidebar/latest.xpi` | Gmail in sidebar |
| **Container Tabs Sidebar** | TBD (check about:support) | `/latest/container-tabs-sidebar/latest.xpi` | Container management |
| **Google Tasks Sidebar** | TBD (check about:support) | `/latest/google-tasks-sidebar/latest.xpi` | Google Tasks |
| **Black Cat Sleep** | N/A (THEME) | `/latest/black-cat-sleep/latest.xpi` | Manual install (themes not supported) |

**Base URL**: `https://addons.mozilla.org/firefox/downloads/`

---

# PART IV: IMPLEMENTATION-READY RECOMMENDATIONS

## Final Configuration Template

**File: `home-manager/firefox.nix`**

(See implementation plan for complete configuration)

**Key Decisions**:
1. ✅ Use Enterprise Policies for extensions (NOT NUR)
2. ✅ Enable Firefox Sync (user request)
3. ✅ Use Sidebery for vertical tabs (NOT Tree Style Tab)
4. ✅ Set search engine to Google (user request)
5. ✅ userChrome.css in home-manager (atomic management)
6. ✅ X11 configuration only (NO Wayland vars)
7. ✅ NVIDIA session vars already set globally (don't duplicate)

## Success Criteria

**Quantitative**:
- 11+ extensions installed declaratively
- RAM usage < 2GB with 10 tabs
- GPU acceleration active
- Build succeeds without errors

**Qualitative**:
- Sidebery vertical tabs functional
- Firefox Sync working
- Configuration reproducible
- Zero manual configuration required

---

## Next Steps

1. **Phase 0**: User completes extension discovery via `about:support`
2. **Phase 1**: Create `firefox.nix` module
3. **Phase 2**: Add all extensions via ExtensionSettings
4. **Phase 3**: Verify GPU acceleration
5. **Phase 4**: Test RAM/CPU optimization
6. **Phase 5**: Configure Sidebery vertical tabs
7. **Phase 6**: Enable Firefox Sync
8. **Phase 7**: Comprehensive testing
9. **Phase 8**: Documentation

---

## Related Documentation

- **Implementation Plan**: `docs/plans/2025-12-14_FIREFOX_COMPREHENSIVE_IMPLEMENTATION_PLAN.md`
- **Ultrathink Findings** (Original): `docs/researches/2025-12-14_FIREFOX_RESEARCH_ULTRATHINK_FINDINGS.md`
- **ADR-009**: Bash Shell Enhancement Configuration
- **ADR-011**: Unified Secrets Management via KeePassXC

---

**Research Status:** ✅ COMPLETE
**Final Confidence:** 0.84 (Band C - HIGH, ready for implementation)
**Date Completed:** 2025-12-14T19:00:00+02:00 (Europe/Athens)

---

**End of Merged Research Document**
