# Plan: NixOS Configuration Refactoring

**Status:** DRAFT
**Date:** 2025-12-21
**Target:** Clean up NixOS configuration to strictly follow the System vs User separation principle (ADR-001).

---

## 🎯 Objective

Ensure `hosts/shoshin/nixos` contains **ONLY** system-level configurations (hardware, boot, networking, display manager, security, users). All user-level tools, dotfiles, and shell environments must be in **Home Manager** or **Chezmoi**.

## 📊 Current State Analysis

### ✅ Already Completed
- **Home Directory:** `hosts/shoshin/nixos/home/` has been successfully removed.
- **KDE Connect:** `modules/workspace/kdeconnect.nix` correctly contains only system firewall/avahi rules.
- **Plasma:** `modules/workspace/plasma.nix` correctly manages X11/Wayland/SDDM system services.

### ⚠️ Issues Identified (Technical Debt)

1.  **Duplicate Packages:**
    `modules/common.nix` installs many packages in `environment.systemPackages` that are also in `home-manager/home.nix`.
    - *Duplicates:* `ripgrep`, `fd`, `fzf`, `jq`, `yq-go`, `btop`, `htop`, `git`, `neofetch`.
    - *Impact:* Redundant, potential version noise, larger system closure.

2.  **User Shell Config in System:**
    `modules/common.nix` contains user-specific shell initialization:
    ```nix
    programs.bash.interactiveShellInit = ''
      eval $(keychain ...)
      export PATH="$HOME/go/bin:..."
    '';
    ```
    - *Impact:* This applies to ALL users (including root), which is messy. It creates a dependency on user-home paths (`$HOME`) that might not exist or be structured the same for root.

3.  **Development Tools in System:**
    `gcc`, `gnumake`, `pkg-config` are in `systemPackages`. While useful for root, they are primarily for the user developer workflow.

---

## 🛠️ Refactoring Plan

### Phase 1: Shell Configuration Migration (High Impact)

Move shell environment setup from NixOS to Home Manager.

1.  **Identify Logic:** Extract the `programs.bash.interactiveShellInit` block from `hosts/shoshin/nixos/modules/common.nix`.
2.  **Migrate to HM:** Move `keychain` eval and `PATH` exports to `home-manager/shell.nix` (or `programs.bash.initExtra`).
3.  **Clean System:** Remove the block from `common.nix`.

### Phase 2: Package Pruning (Cleanup)

Reduce `environment.systemPackages` to a bare minimum admin toolkit.

1.  **Keep (Admin Tools):** `vim`, `git`, `curl`, `wget`, `htop`, `iotop`, `lsof`, `killall`, `tcpdump`, `pciutils`, `usbutils`, `rsync`.
2.  **Remove (User Tools):** `ripgrep`, `fd`, `fzf`, `jq`, `yq-go`, `neofetch`, `btop` (keep `htop` for root), `lnav`.
    *   *Note:* Ensure these remain in `home-manager/home.nix`.
3.  **Dev Tools:** Remove `gcc`, `gnumake` from system unless strictly required for system builds (usually handled by nix-shell/dev-shell).

### Phase 3: Module Review

Review remaining modules for user-specific settings:
- `modules/system/nvidia.nix` (Ensure just driver/hardware config)
- `modules/workspace/power.nix` (Ensure just upower/logind)

---

## 📋 Execution Checklist

- [ ] **Phase 1:** Move Bash Init
    - [ ] Add keychain/PATH to `home-manager`
    - [ ] Remove from `nixos/modules/common.nix`
    - [ ] Apply & Verify (`nixos-rebuild switch`, `home-manager switch`)
- [ ] **Phase 2:** Prune System Packages
    - [ ] Verify `ripgrep`, `fd`, etc. are in `home.nix`
    - [ ] Remove from `nixos/modules/common.nix`
    - [ ] Apply & Verify
- [ ] **Phase 3:** Final Verification
    - [ ] Check `root` user shell (should be clean)
    - [ ] Check `mitsio` user shell (should have all tools)

---

**Approval:** Pending User Review
