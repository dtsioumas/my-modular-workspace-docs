# NixOS Root System Configuration

**Scope:** System-level configuration (`/etc/nixos`)
**Host:** shoshin
**System:** NixOS 25.05 (stable)
**Last Updated:** 2025-11-30

---

## What This Covers

This directory documents the **root system configuration** - things that require `sudo` and affect the entire machine:

| Category | Examples |
|----------|----------|
| **Hardware** | NVIDIA drivers, audio (PipeWire), USB fixes |
| **Desktop** | KDE Plasma 6, SDDM display manager |
| **System Services** | Docker, systemd, networking |
| **Security** | Firewall, SSH, user accounts |

> **Note:** User-level configuration (packages, dotfiles, user services) is managed by [Home-Manager](../home-manager/) and is **distro-agnostic**.

---

## Available Guides

| Guide | Description |
|-------|-------------|
| [flakes-guide.md](flakes-guide.md) | Building Nix flakes, custom packages |
| [DEBUGGING_AND_MAINTENANCE_GUIDE.md](DEBUGGING_AND_MAINTENANCE_GUIDE.md) | Troubleshooting NixOS builds |
| [MIGRATION_PLAN.md](MIGRATION_PLAN.md) | NixOS configuration migration |
| [STATIC_IP_CONFIGURATION.md](STATIC_IP_CONFIGURATION.md) | Network configuration |

---

## Repository Location

```
Config:  ~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/
Symlink: /etc/nixos → (above path)
```

---

## Quick Commands

```bash
# Rebuild system
sudo nixos-rebuild switch --flake /etc/nixos#shoshin

# Test changes (no permanent switch)
sudo nixos-rebuild test --flake /etc/nixos#shoshin

# Check flake
nix flake check /etc/nixos
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    ROOT SYSTEM (NixOS)                   │
│  Requires: sudo | Affects: entire machine               │
├─────────────────────────────────────────────────────────┤
│  • Hardware drivers (NVIDIA, audio)                     │
│  • Desktop environment (Plasma 6, SDDM)                 │
│  • System services (Docker, networking)                 │
│  • User account definitions                             │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                USER ENVIRONMENT (Home-Manager)           │
│  No sudo | Portable across distros                      │
├─────────────────────────────────────────────────────────┤
│  → See: ../home-manager/                                │
└─────────────────────────────────────────────────────────┘
```

---

## Related Documentation

- [../home-manager/](../home-manager/) - User environment (distro-agnostic)
- [../adrs/ADR-001](../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md) - Why stable for system, unstable for user

---

## Future: Fedora Migration

When migrating to Fedora Kinoite/BlueBuild:
- This directory will be **archived** (`archive/nixos/`)
- Home-Manager configuration **stays the same**
- New `system/` docs will be created for BlueBuild
