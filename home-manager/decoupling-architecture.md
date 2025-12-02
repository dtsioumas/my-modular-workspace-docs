# Home-Manager Decoupling Architecture

**Last Updated:** 2025-11-30
**Status:** Reference Architecture
**Goal:** Decouple home-manager from NixOS for portable, cross-platform user configuration

---

## Overview

This document describes the target architecture for standalone home-manager that works across NixOS, Fedora Kinoite, WSL, and other distributions.

### Design Principles

1. **System repo** owns: drivers, DE enablement, system services
2. **Home repo** owns: user packages, configs, editors, shell
3. **Location-agnostic**: Works from any directory
4. **Host-specific overrides**: NixOS-only aliases go in `hosts/shoshin.nix`

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER CONFIGURATION                        │
├─────────────────────────────────────────────────────────────┤
│  home-manager/           → Packages + systemd services       │
│  ├── flake.nix          → Standalone flake                  │
│  ├── home.nix           → Entry point                       │
│  └── *.nix              → Shell, editors, desktop, etc.     │
├─────────────────────────────────────────────────────────────┤
│  chezmoi (dotfiles/)    → Cross-platform config files       │
│  KeePassXC              → Secrets management                │
│  Ansible                → Bootstrap automation               │
└─────────────────────────────────────────────────────────────┘
```

---

## Target Repository Structure

```
home-manager/
├── flake.nix                   # Standalone flake
├── flake.lock
├── home.nix                    # Main entry, imports all modules
│
├── # Core Modules
├── shell.nix                   # Bash config, aliases
├── git.nix                     # Git configuration
│
├── # Applications
├── kitty.nix                   # Terminal emulator
├── vscodium.nix                # IDE settings
├── brave.nix                   # Browser configuration
│
├── # Services
├── keepassxc.nix               # Password manager + vault sync
├── syncthing-myspaces.nix      # P2P file sync
├── rclone-gdrive.nix           # Cloud backup
│
├── # Desktop
├── plasma.nix                  # KDE Plasma user settings
├── plasma-full.nix             # Extended Plasma config
│
├── # Development
├── claude-code.nix             # AI assistant
├── npm-tools.nix               # Node.js packages
├── semantic-grep.nix           # Code search
│
└── hosts/
    ├── shoshin.nix             # NixOS-specific (nrs, nrt aliases)
    ├── kinoite.nix             # Fedora-specific (future)
    └── wsl-workspace.nix       # WSL-specific (future)
```

---

## Flake Structure

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }: {
    homeConfigurations = {
      "mitsio@shoshin" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home.nix
          plasma-manager.homeModules.plasma-manager
        ];
        extraSpecialArgs = { hostname = "shoshin"; };
      };

      "mitsio@kinoite" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix plasma-manager.homeModules.plasma-manager ];
        extraSpecialArgs = { hostname = "kinoite"; };
      };
    };
  };
}
```

---

## What Stays in NixOS System Config

| Category | Files | Reason |
|----------|-------|--------|
| Hardware | `nvidia.nix`, `audio.nix` | System drivers |
| Desktop | `plasma.nix` (system) | SDDM, Plasma6 enablement |
| Services | `docker.nix`, containers | Root-level daemons |
| Development | `python.nix`, `go.nix` | Heavy runtimes |
| Security | `security.nix` | System-level policies |

---

## Host-Specific Overrides

### NixOS (shoshin.nix)
```nix
{
  programs.bash.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin";
    nrt = "sudo nixos-rebuild test --flake ~/.config/nixos#shoshin";
    nru = "nix flake update ~/.config/nixos && nrs";
    cd-nixos = "cd ~/.config/nixos";
  };
}
```

### Fedora Kinoite (kinoite.nix)
```nix
{
  programs.bash.shellAliases = {
    # No NixOS aliases
    rpm-update = "rpm-ostree upgrade";
  };
}
```

---

## Usage Commands

```bash
# Apply configuration
home-manager switch --flake .#mitsio@shoshin

# Update all packages
nix flake update
home-manager switch --flake .#mitsio@shoshin

# Check installed packages
home-manager packages

# List generations
home-manager generations

# Rollback
home-manager switch --rollback
```

---

## Multi-Tool Integration

| Tool | Purpose | Location |
|------|---------|----------|
| **home-manager** | Packages + services | `home-manager/` |
| **chezmoi** | Cross-platform dotfiles | `dotfiles/` |
| **KeePassXC** | Secrets storage | `~/MyVault/` |
| **Ansible** | Bootstrap automation | `ansible/` |

---

## Success Criteria

- [ ] Standalone home-manager builds without NixOS
- [ ] All user configs extracted from system repo
- [ ] Per-host overrides work correctly
- [ ] Can migrate to Kinoite with same config
- [ ] Works after fresh install + Nix

---

## Related Documentation

- [Migration Plan](migration-plan.md) - File-by-file migration tracking
- [Ephemeral Practices](ephemeral.md) - Ephemerality strategy
- [Debugging Guide](DEBUGGING_AND_MAINTENANCE.md)
- [ADR-001](../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md)

---

**Consolidated from:** COMPREHENSIVE_PLAN.md, HOME-MANAGER_REPO_SKELETON_DRAFT_1.md, REVISED_PLAN_FOLLOWING_SKELETON.md, IMPLEMENTATION_STEPS.md
