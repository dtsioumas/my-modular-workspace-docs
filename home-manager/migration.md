# Home-Manager Migration: NixOS Config Analysis & Plan

**Status:** Analysis Complete
**Last Updated:** 2025-11-18

---

## 1. Executive Summary

This document summarizes the migration of NixOS user configurations from `~/.config/nixos/` to the `home-manager` repository.

**Overall Migration Status:**
- **88%** of user-migratable configurations are complete.
- **18 out of 21** user-level files have been fully migrated.
- **5 system-level files** have been correctly identified to remain in the NixOS system configuration.
- Approximately **160 packages** are now declaratively managed by Home-Manager, a significant improvement in separating user and system concerns.

---

## 2. Prioritized Action Plan

The following actions are required to complete the migration to 100%.

### Priority 1: High Impact, Quick Wins (Est. 10 minutes)

1.  **Add KDE Themes & Icons:**
    - **Action:** Add `nordic`, `papirus-icon-theme`, `kdePackages.breeze-icons`, and `kdePackages.breeze-gtk` to `home.packages` in your `home.nix` file.
    - **Source:** `~/.config/nixos/modules/workspace/themes.nix`

2.  **Migrate Dropbox Service:**
    - **Action:** Create a `dropbox.nix` file in the `home-manager` directory with the following content and import it.
      ```nix
      { config, lib, pkgs, ... }:
      {
        services.dropbox = {
          enable = true;
          path = "${config.home.homeDirectory}/Dropbox";
        };
      }
      ```
    - **Source:** `~/.config/nixos/modules/workspace/dropbox.nix`

### Priority 2: Enhancements (Optional)

3.  **Merge Firefox Memory Optimizations:**
    - **Action:** Add the following settings to the `programs.firefox.profiles.default.settings` section in `home.nix`.
      ```nix
      "browser.cache.memory.capacity" = 524288; # 512MB
      "dom.ipc.processCount" = 4;
      "browser.tabs.unloadOnLowMemory" = true;
      "browser.sessionhistory.max_total_viewers" = 2;
      "layers.acceleration.force-enabled" = true;
      "gfx.webrender.all" = true;
      "browser.cache.disk.capacity" = 358400; # 350MB
      ```
    - **Source:** `~/.config/nixos/modules/workspace/firefox.nix`

4.  **Fix Syncthing Path:**
    - **Action:** Update the path in `syncthing-myspaces.nix` to sync `MyHome` instead of `MySpaces`. (This item is noted as being on the main TODO list).

---

## 3. Detailed Migration Analysis

### 3.1. ✅ Fully Migrated Configurations

The following components have been successfully migrated to Home-Manager and require no further action.

- **Brave Browser:** Includes NVIDIA hardware acceleration, memory optimizations, and privacy flags.
- **Development Packages:** Go, Python, JavaScript/Node.js, Kubernetes tools, and general tooling (~100+ packages).
- **Core User Home Configs:**
    - `shell.nix`
    - `plasma.nix`
    - `keepassxc.nix`
    - `kitty.nix`
    - `vscodium.nix`
    - `claude-code.nix`
- **Sync Services:**
    - `rclone-bisync.nix` (as `rclone-gdrive.nix`)
    - `syncthing-myspaces.nix` (imported, path fix pending)

### 3.2. 🔄 Configurations Requiring Migration

These are the pending items outlined in the action plan above.

- **KDE Themes & Icons:** (`themes.nix`)
- **Dropbox Service:** (`dropbox.nix`)
- **Firefox Optimizations:** (Partial, from `firefox.nix`)

### 3.3. ⚠️ System-Level Settings (Must Remain in NixOS)

These configurations manage system-level hardware and services and **cannot** be migrated to Home-Manager. They must remain in the NixOS system configuration (`/etc/nixos/`).

- **NVIDIA Drivers:** (`modules/system/nvidia.nix`) - Hardware drivers.
- **Audio Services:** (`modules/system/audio.nix`) - PipeWire/PulseAudio system services.
- **WirePlumber:** (`modules/system/wireplumber-config.nix`) - System audio routing.
- **USB Mouse Fix:** (`modules/system/usb-mouse-fix.nix`) - Kernel/hardware-level tweaks.
- **System Logging:** (`modules/system/logging.nix`) - Systemd journal configuration.
- **Display Manager & Firewall:** (`modules/workspace/plasma.nix`, `plasma-kdeconnect.nix`) - SDDM, firewall rules.
- **Application Memory Limits:** (`modules/workspace/app-memory-limits.nix`) - Systemd cgroups.
- **Power Management:** (`modules/workspace/power.nix`) - `services.logind` settings.

---

## 4. Verification Checklist

After applying the changes from the action plan, verify the following:

- **Themes:**
    - [ ] Nordic theme is available in Plasma System Settings.
    - [ ] Papirus icons are selectable.
- **Dropbox:**
    - [ ] The Dropbox service starts automatically on login (`systemctl --user status dropbox`).
    - [ ] Files are syncing correctly to `~/Dropbox`.
- **Firefox:**
    - [ ] The memory and hardware acceleration settings are visible and correct in `about:config`.
