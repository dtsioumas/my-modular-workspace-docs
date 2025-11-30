# My Modular Workspace - Documentation

**Last Updated:** 2025-11-30
**Status:** Active Development
**Total Files:** 76 markdown documents

Documentation for a portable, declarative workspace configuration system built with NixOS, Home Manager, and modern tools.

---

## Repository Structure

| Directory | Files | Description | README |
|-----------|-------|-------------|--------|
| [tools/](tools/) | 12 | Tool guides (atuin, kitty, navi, etc.) | [tools/README.md](tools/README.md) |
| [sync/](sync/) | 4 | Syncthing + rclone sync guides | [sync/README.md](sync/README.md) |
| [nixos/](nixos/) | 6 | NixOS configuration & flakes | [nixos/README.md](nixos/README.md) |
| [home-manager/](home-manager/) | 14 | Home Manager guides & migration | [home-manager/README.md](home-manager/README.md) |
| [chezmoi/](chezmoi/) | 11 | Dotfile management guides | [chezmoi/README.md](chezmoi/README.md) |
| [ansible/](ansible/) | 5 | Automation playbook docs | [ansible/README.md](ansible/README.md) |
| [adrs/](adrs/) | 5 | Architecture Decision Records | - |
| [archive/](archive/) | 8 | Historical/deprecated docs | - |
| [plans/](plans/) | 7 | Implementation plans | [plans/README.md](plans/README.md) |

---

## Quick Navigation

### Core Components

| Component | Purpose | Key Docs |
|-----------|---------|----------|
| **Home Manager** | User packages & configs | [README](home-manager/README.md), [Architecture](home-manager/decoupling-architecture.md), [Ephemeral](home-manager/ephemeral.md) |
| **NixOS** | System configuration | [README](nixos/README.md), [Flakes Guide](nixos/flakes-guide.md) |
| **Sync** | File synchronization | [README](sync/README.md), [Syncthing](sync/syncthing.md), [rclone](sync/rclone-gdrive.md) |
| **Tools** | Development tools | [README](tools/README.md), [Atuin](tools/atuin.md), [Kitty](tools/kitty.md) |

### Supporting Systems

| Component | Purpose | Key Docs |
|-----------|---------|----------|
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
