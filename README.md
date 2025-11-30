# My Modular Workspace - Documentation

**Last Updated:** 2025-11-30
**Status:** Active Development
**Total Files:** 80 markdown documents

Documentation for a portable, declarative workspace configuration system built with NixOS, Home Manager, and modern tools.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│              ROOT SYSTEM (NixOS) - requires sudo            │
│  Hardware drivers, DE enablement, system services          │
│  → docs/nixos/                                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│         USER ENVIRONMENT (Home-Manager) - no sudo          │
│  Packages, dotfiles, user services - PORTABLE to any OS    │
│  → docs/home-manager/                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

| Directory | Files | Description | README |
|-----------|-------|-------------|--------|
| [nixos/](nixos/) | 6 | **Root system** config (drivers, DE, sudo) | [nixos/README.md](nixos/README.md) |
| [home-manager/](home-manager/) | 15 | **User environment** (portable, no sudo) | [home-manager/README.md](home-manager/README.md) |
| [tools/](tools/) | 12 | Tool guides (atuin, kitty, navi, etc.) | [tools/README.md](tools/README.md) |
| [sync/](sync/) | 8 | Syncthing + rclone sync guides | [sync/README.md](sync/README.md) |
| [chezmoi/](chezmoi/) | 11 | Dotfile management guides | [chezmoi/README.md](chezmoi/README.md) |
| [ansible/](ansible/) | 5 | Automation playbook docs | [ansible/README.md](ansible/README.md) |
| [adrs/](adrs/) | 6 | Architecture Decision Records | - |
| [archive/](archive/) | 5 | Historical/deprecated docs | [archive/README.md](archive/README.md) |
| [plans/](plans/) | 8 | Implementation plans | [plans/README.md](plans/README.md) |

---

## Quick Navigation

### Configuration Layers

| Layer | Directory | Scope | Portable |
|-------|-----------|-------|----------|
| **System** | [nixos/](nixos/) | Drivers, DE, Docker (sudo required) | NixOS only |
| **User** | [home-manager/](home-manager/) | Packages, configs, services | Any distro |

### Supporting Documentation

| Component | Purpose | Key Docs |
|-----------|---------|----------|
| **Sync** | File synchronization | [README](sync/README.md), [Syncthing](sync/syncthing.md), [rclone](sync/rclone-gdrive.md) |
| **Tools** | Development tools | [README](tools/README.md), [Atuin](tools/atuin.md), [Kitty](tools/kitty.md) |
| **Chezmoi** | Cross-platform dotfiles | [README](chezmoi/README.md), [Migration](chezmoi/02-migration-strategy.md) |
| **Ansible** | Bootstrap automation | [README](ansible/README.md) |
| **ADRs** | Architecture decisions | [ADR-001](adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md) |

---

## Key Documents

| Document | Description |
|----------|-------------|
| [home-manager/ephemeral.md](home-manager/ephemeral.md) | Ephemerality strategy |
| [home-manager/node2nix.md](home-manager/node2nix.md) | NPM package management |
| [nixos/flakes-guide.md](nixos/flakes-guide.md) | Building Nix flakes |
| [sync/syncthing.md](sync/syncthing.md) | P2P sync setup |
| [sync/rclone-gdrive.md](sync/rclone-gdrive.md) | Cloud backup |
| [tools/atuin.md](tools/atuin.md) | Shell history sync |

---

## Project Goals

1. **Portability** - Same config across NixOS, Fedora, WSL
2. **Reproducibility** - Declarative everything
3. **Ephemerality** - Rebuild home directory from scratch
4. **Maintainability** - Clear docs, modular structure

---

## Technology Stack

| Layer | Tool |
|-------|------|
| Package Management | Nix + Home Manager |
| Dotfiles | Chezmoi |
| Secrets | KeePassXC |
| Sync | Syncthing + rclone |
| Bootstrap | Ansible |
| Base OS | NixOS (current) |

---

## Related Repositories

- **Home Manager:** `~/.MyHome/MySpaces/my-modular-workspace/home-manager/`
- **NixOS Config:** `~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/`
- **Ansible:** `~/.MyHome/MySpaces/my-modular-workspace/ansible/`
- **Dotfiles:** `~/.MyHome/MySpaces/my-modular-workspace/dotfiles/`

---

**Author:** Dimitris Tsioumas (Mitsos)
**GitHub:** [@dtsioumas](https://github.com/dtsioumas)
