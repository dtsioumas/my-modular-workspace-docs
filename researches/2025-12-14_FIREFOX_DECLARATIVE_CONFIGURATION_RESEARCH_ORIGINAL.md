# Firefox Declarative Configuration Research

**Date:** 2025-12-14
**Author:** Technical Research Session (Claude Sonnet 4.5)
**Status:** Complete
**Confidence:** 0.88 (Band C - HIGH)
**Session Context:** Firefox optimization and declarative configuration via home-manager + chezmoi

---

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

### 2.1 Method 1: NUR Firefox Addons (Recommended for stability)

**Source**: [nur-combined](https://github.com/nix-community/NUR)
**Repository**: `pkgs.nur.repos.rycee.firefox-addons`

**Setup**:
```nix
# flake.nix
{
  inputs.nur.url = "github:nix-community/NUR";
}

# home.nix
programs.firefox.profiles.default = {
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    tree-style-tab
    bitwarden
    privacy-badger
    multi-account-containers
  ];

  # CRITICAL: Auto-enable extensions without user interaction
  settings = {
    "extensions.autoDisableScopes" = 0;
  };
};
```

**Known Issue**: Extension UUIDs change on each rebuild, losing extension state.
**Workaround**: Persist `~/.mozilla/firefox/<profile>/prefs.js` OR use Policy method instead.

### 2.2 Method 2: Enterprise Policies (Best for avoiding NUR)

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

  # Tree Style Tab
  "treestyletab@piro.sakura.ne.jp" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
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
1. Install extension manually
2. Check `about:support` → Extensions section
3. Or: Download XPI, unzip, read `manifest.json`:
   ```bash
   unzip extension.xpi
   jq .browser_specific_settings.gecko.id manifest.json
   ```

### 2.3 Currently Installed Extensions (Manual Analysis)

From `~/.mozilla/firefox/*.default*/extensions/`:
```
- uBlock0@raymondhill.net.xpi (uBlock Origin)
- treestyletab@piro.sakura.ne.jp.xpi (Tree Style Tab)
- tab-stash@condordes.net.xpi (Tab Stash)
- @testpilot-containers.xpi (Multi-Account Containers)
- floccus@handmadeideas.org.xpi (Floccus bookmark sync)
- 17 total extension files
```

**Action Required**: Identify all extension IDs for declarative config.

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
};

# Session variables (in home.sessionVariables)
home.sessionVariables = {
  # NVIDIA-specific for hardware acceleration
  LIBVA_DRIVER_NAME = "nvidia";
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";

  # Firefox-specific (optional)
  MOZ_ENABLE_WAYLAND = "1";  # If using Wayland
  MOZ_WEBRENDER = "1";
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
"dom.ipc.processCount" = 4;  # 4 content processes
"browser.tabs.unloadOnLowMemory" = true;
"browser.sessionhistory.max_total_viewers" = 2;
```

**Additional Tuning Options**:
```nix
# Reduce memory bloat
"browser.cache.memory.max_entry_size" = 512;  # KB
"browser.cache.disk.capacity" = 358400;  # 350MB disk cache
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

## 5. Vertical Tabs (Tree Style Tab)

### 5.1 Extension Configuration

Tree Style Tab (already installed manually) can be configured via:

1. **Extension Preferences** (not declaratively configurable via home-manager)
2. **userChrome.css** (hide native tab bar)

### 5.2 userChrome.css Integration

**Via home-manager**:
```nix
programs.firefox.profiles.default = {
  userChrome = ''
    /* Hide native horizontal tab bar */
    #TabsToolbar {
      visibility: collapse !important;
    }

    /* Hide sidebar header for Tree Style Tab */
    #sidebar-header {
      display: none !important;
    }

    /* Adjust sidebar width */
    #sidebar-box {
      max-width: none !important;
      min-width: 200px !important;
    }
  '';

  settings = {
    # Enable userChrome.css customization
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };
};
```

**Alternative**: Manage userChrome.css via chezmoi at:
`dotfiles/dot_mozilla/firefox/default-release/chrome/userChrome.css.tmpl`

---

## 6. KeePassXC Integration

### 6.1 Extension Installation

**Extension ID**: `keepassxc-browser@keepassxc.org`

**Via Policies**:
```nix
programs.firefox.policies.ExtensionSettings = {
  "keepassxc-browser@keepassxc.org" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
    installation_mode = "force_installed";
  };
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

---

## 7. Theme and Appearance

### 7.1 Current Theme

User currently uses **Catppuccin Mocha** theme for Kitty and has **Dracula** theme available.

**Firefox Theme Options**:
1. **Via Extension** (Firefox Color, Stylus)
2. **Via userChrome.css** (full control)
3. **Built-in themes** (about:addons → Themes)

### 7.2 Declarative Theme Configuration

**Option 1: userChrome.css** (Recommended):
```nix
programs.firefox.profiles.default.userChrome = ''
  /* Catppuccin Mocha theme for Firefox */
  @import url("https://raw.githubusercontent.com/catppuccin/firefox/main/themes/mocha.css");
'';
```

**Option 2: Fetch theme via home-manager**:
```nix
programs.firefox.profiles.default.userChrome = builtins.readFile (
  pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/firefox/main/userChrome.css";
    sha256 = "...";
  }
);
```

**Option 3: Extension installation**:
```nix
# Stylus extension for managing CSS themes
"install_url" = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
```

---

## 8. Sync Configuration

### 8.1 Firefox Sync vs Declarative Config

**Current Situation**: User lost access to Firefox Sync profile.

**Two Strategies**:
1. **Disable Sync** + Use full declarative config (recommended for reproducibility)
2. **Enable Sync** + Use declarative config for base settings

**Recommendation**: **Disable Sync**, manage everything declaratively:

```nix
programs.firefox.policies = {
  DisableFirefoxAccounts = true;  # Fully disable Sync
  # OR
  DisableFirefoxAccounts = false;  # Allow but don't force
};

# Store sync credentials in KeePassXC (per ADR-011)
```

---

## 9. Complete Configuration Example

### 9.1 Proposed home-manager/firefox.nix

```nix
{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;

    # Optional: Language packs
    languagePacks = [ "en-US" "el" ];  # Greek support

    # Enterprise policies (global settings)
    policies = {
      # Disable telemetry
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxScreenshots = true;

      # Tracking protection
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      # Extension installation (Policy method)
      ExtensionSettings = {
        "*".installation_mode = "blocked";  # Block all except listed

        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };

        "treestyletab@piro.sakura.ne.jp" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
          installation_mode = "force_installed";
        };

        "keepassxc-browser@keepassxc.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          installation_mode = "force_installed";
        };

        "@testpilot-containers" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    # Profile configuration
    profiles.default = {
      id = 0;
      isDefault = true;

      settings = {
        # === Memory Optimizations ===
        "browser.cache.memory.capacity" = 524288;  # 512MB
        "dom.ipc.processCount" = 4;
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.sessionhistory.max_total_viewers" = 2;

        # === NVIDIA Hardware Acceleration ===
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "webgl.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "gfx.canvas.accelerated" = true;
        "layers.gpu-process.enabled" = true;

        # === Privacy & Security ===
        "privacy.trackingprotection.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "dom.security.https_only_mode" = true;

        # === Disable Telemetry ===
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;

        # === UI Preferences ===
        "browser.startup.page" = 3;  # Restore session
        "browser.toolbars.bookmarks.visibility" = "always";
        "extensions.pocket.enabled" = false;

        # === Performance ===
        "browser.sessionstore.interval" = 15000000;
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;

        # === Tree Style Tab Support ===
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # === Extension Auto-Enable ===
        "extensions.autoDisableScopes" = 0;
      };

      # userChrome.css for vertical tabs
      userChrome = ''
        /* Hide native horizontal tab bar */
        #TabsToolbar {
          visibility: collapse !important;
        }

        /* Hide sidebar header */
        #sidebar-header {
          display: none !important;
        }

        /* Optimize sidebar for Tree Style Tab */
        #sidebar-box {
          max-width: none !important;
          min-width: 200px !important;
        }

        /* Optional: Catppuccin Mocha theme */
        /* @import url("path/to/catppuccin-mocha.css"); */
      '';

      # Search engine
      search = {
        default = "DuckDuckGo";
        force = true;
      };
    };
  };

  # Session variables for NVIDIA
  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    MOZ_WEBRENDER = "1";
  };
}
```

---

## 10. Comparison with Brave Configuration

### 10.1 Brave (brave.nix) vs Firefox

| Feature | Brave Implementation | Firefox Equivalent |
|---------|---------------------|-------------------|
| GPU acceleration | `--enable-features=VaapiVideoDecoder` | `media.ffmpeg.vaapi.enabled = true` |
| WebRender | `UseSkiaRenderer` | `gfx.webrender.all = true` |
| Memory limit | `--js-flags=--max-old-space-size=512` | `dom.ipc.processCount = 4` |
| Process limit | `--renderer-process-limit=4` | `dom.ipc.processCount = 4` |
| NVIDIA vars | `LIBVA_DRIVER_NAME=nvidia` | Same |
| Extensions | N/A (Brave has built-in) | Via Policies or NUR |

### 10.2 Lessons from Brave Config

✅ **GPU acceleration works** on NVIDIA with proper flags
✅ **Memory limits** are critical (Brave: 512MB V8, Firefox: 512MB cache)
✅ **Process limits** reduce RAM usage (Brave: 4, Firefox: 4)
✅ **Session variables** must be set for NVIDIA

---

## 11. Migration Strategy

### Phase 1: Create firefox.nix Module (2-3 hours)
1. Create `home-manager/firefox.nix`
2. Move existing settings from `home.nix` to `firefox.nix`
3. Add import to `home.nix`
4. Test with `home-manager switch`

### Phase 2: Declarative Extensions (2-3 hours)
1. Identify all manually-installed extension IDs
2. Add to `policies.ExtensionSettings`
3. Test auto-enable with `extensions.autoDisableScopes = 0`
4. Verify all extensions load correctly

### Phase 3: GPU Optimization (1 hour)
1. Add NVIDIA-specific settings
2. Add session variables (may already be set for Brave)
3. Test with `about:support` → Graphics
4. Verify hardware video decoding works

### Phase 4: Vertical Tabs (1 hour)
1. Add userChrome.css for native tab bar hiding
2. Verify Tree Style Tab displays correctly
3. Optional: Add theme customization

### Phase 5: KeePassXC Integration (30 mins)
1. Verify KeePassXC-Browser extension installed
2. Test connection to KeePassXC
3. Document any manual steps required

---

## 12. Risks and Limitations

### 12.1 Known Issues

**Extension State Loss**:
- Problem: Extension UUIDs change on rebuild when using NUR method
- Impact: Extension settings reset after home-manager switch
- Workaround: Use Policy method OR persist `prefs.js`

**userChrome.css Caching**:
- Problem: Firefox caches userChrome.css aggressively
- Impact: Changes may not apply immediately
- Workaround: Restart Firefox with cache cleared

**Native Messaging**:
- Problem: KeePassXC native messaging may require manual approval
- Impact: First-time setup still needs user interaction
- Workaround: Document manual steps in home-manager README

### 12.2 Testing Checklist

Before deploying:
- [ ] `home-manager switch` builds successfully
- [ ] Firefox launches without errors
- [ ] All extensions appear in `about:addons`
- [ ] Extensions are auto-enabled (no "allow" prompt)
- [ ] `about:support` shows hardware acceleration active
- [ ] Native tab bar is hidden (vertical tabs visible)
- [ ] KeePassXC connection works
- [ ] Video playback uses GPU (check `about:support`)
- [ ] RAM usage stays under 2GB with 10 tabs open

---

## 13. References

### 13.1 Documentation

- **Home-Manager Firefox Module**: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox
- **Mozilla Policy Templates**: https://mozilla.github.io/policy-templates/
- **Firefox Enterprise Policies**: https://github.com/mozilla/policy-templates/blob/master/README.md
- **NUR Firefox Addons**: https://github.com/nix-community/nur-combined
- **Tree Style Tab**: https://github.com/piroor/treestyletab

### 13.2 Research Sources

- NixOS Discourse: "Declare Firefox extensions and settings" (43.6k views)
- GitHub Issue #4618: Declarative Firefox extension configurations
- GitHub Issue #6398: Firefox extensions with home-manager + impermanence
- Reddit /r/NixOS: Firefox configuration examples
- Home-Manager Manual: Firefox options

### 13.3 Code Examples

- sleepy's Firefox config: https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
- gvolpe's nix-config: https://github.com/gvolpe/nix-config (referenced as best example)

---

## 14. Next Steps

1. ✅ **Research Complete** (Current phase)
2. ⏳ **Perform Ultrathink** (Find discrepancies and gaps)
3. ⏳ **Create Implementation Plan** (Detailed step-by-step)
4. ⏳ **User Approval** (Review plan, get confirmation)
5. ⏳ **Implementation** (Execute plan in phases)
6. ⏳ **Testing & Verification**
7. ⏳ **Documentation Update** (README, troubleshooting)

---

## Appendix A: Extension ID Discovery

### Method 1: From Installed Extensions
```bash
cd ~/.mozilla/firefox/*.default*/extensions/
ls -1 *.xpi
```

### Method 2: From manifest.json
```bash
unzip -p extension.xpi manifest.json | jq -r '.browser_specific_settings.gecko.id'
```

### Method 3: From about:support
1. Navigate to `about:support`
2. Scroll to "Extensions" section
3. Copy "ID" column for each extension

---

## Appendix B: GPU Verification Commands

```bash
# Check Firefox processes
ps aux | grep firefox

# Check GPU usage
nvidia-smi

# Monitor GPU video decode
watch -n1 nvidia-smi

# Check VA-API support
vainfo
```

---

## Confidence Assessment

| Area | Confidence | Band | Notes |
|------|-----------|------|-------|
| Declarative config | 0.92 | C | Well-documented, proven examples |
| Extension installation | 0.85 | C | Policy method reliable |
| GPU optimization | 0.80 | C | Based on Brave success |
| RAM/CPU tuning | 0.88 | C | Standard Firefox tweaks |
| KeePassXC integration | 0.75 | C | May need manual steps |
| Vertical tabs | 0.90 | C | userChrome.css well-known |
| Overall | 0.88 | C | **HIGH confidence** |

**Research Quality**: Band C (HIGH) - Ready for implementation planning.

---

**End of Research Document**

Time: 2025-12-14T17:11:32+02:00 (Europe/Athens)
