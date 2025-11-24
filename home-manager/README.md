# My Home-Manager Flake

**Portable, declarative user environment configuration**

**User:** mitsio
**Strategy:** Standalone home-manager with unstable packages
**Status:** Phase 1 - Monolithic (working), Phase 2 - Modular (planned)

---

## Architecture

See: [ADR-001: NixOS System (Stable) vs Home-Manager (Unstable)](../my-modular-workspace-decoupling-home/docs/ADR-001-nixpkgs-stable-vs-unstable.md)

**System (NixOS - stable 25.05):**
- Base system, NVIDIA, KDE Plasma
- Virtualization/containerization daemons
- Minimal, stable base

**Home-Manager (unstable):**
- ALL user packages (browsers, apps, dev tools)
- Latest versions from unstable
- ~100+ packages
- Full portability

---

## Usage

### Build & Apply

```bash
# First time (generates flake.lock)
cd ~/.config/my-home-manager-flake
nix flake lock

# Apply configuration
home-manager switch --flake .#mitsio@shoshin
```

### Update All Packages

```bash
# Update flake inputs (all packages!)
nix flake update

# Apply updates
home-manager switch --flake .#mitsio@shoshin
```

---

## Hosts

- **mitsio@shoshin** - NixOS desktop (current)
- **mitsio@kinoite** - Fedora Kinoite (future)
- **mitsio@wsl-workspace** - WSL (future)

---

## Current State (Phase 1)

**Monolithic structure:**
- `flake.nix` - Standalone home-manager flake (unstable)
- `home.nix` - Main entry (imports all modules)
- `shell.nix` - Bash config, aliases
- `claude-code.nix` - Claude Code CLI wrapper
- `kitty.nix` - Kitty terminal
- `vscodium.nix` - VSCodium settings
- `keepassxc.nix` - KeePassXC + vault sync
- `plasma.nix` - KDE Plasma user settings

**Phase 2 (planned):** Modular refactor following skeleton pattern

---

## Session

**Date:** 2025-11-17
**Session:** my-modular-workspace-decoupling-home
**Docs:** `~/my-modular-workspace-decoupling-home/docs/`

---

## Notes

- Username changed: `mitso` → `mitsio`
- All paths use `${config.home.homeDirectory}` (portable!)
- No hardcoded paths
- Ready for multi-OS deployment (NixOS, Fedora, etc.)
