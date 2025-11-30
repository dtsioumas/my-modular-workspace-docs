# Home-Manager User Environment

**Scope:** User-level configuration (no sudo required)
**User:** mitsio
**Strategy:** Standalone flake with nixpkgs-unstable
**Last Updated:** 2025-11-30
**Files:** 14 documents

---

## What This Covers

This directory documents the **user environment** - portable configuration that works on any Linux distro with Nix installed:

| Category | Examples |
|----------|----------|
| **Packages** | Browsers, editors, CLI tools (~160 packages) |
| **Dotfiles** | Shell config, aliases, environment variables |
| **User Services** | Syncthing, rclone sync, KeePassXC vault |
| **Desktop Settings** | KDE Plasma user preferences (via plasma-manager) |

> **Note:** System-level configuration (drivers, DE enablement, Docker) is managed by [NixOS](../nixos/) and requires `sudo`.

---

## Key Benefit: Distro-Agnostic

```
┌─────────────────────────────────────────────────────────┐
│              HOME-MANAGER USER ENVIRONMENT               │
│  No sudo | Works on: NixOS, Fedora, Ubuntu, WSL, macOS  │
├─────────────────────────────────────────────────────────┤
│  • User packages (browsers, dev tools, CLI)             │
│  • User services (syncthing, rclone, keepassxc)         │
│  • Dotfiles (shell, git, editor configs)                │
│  • Desktop settings (Plasma user preferences)           │
└─────────────────────────────────────────────────────────┘
```

When migrating to Fedora: **This configuration stays the same!**

---

## Available Guides

### Architecture & Migration

| Guide | Description |
|-------|-------------|
| [decoupling-architecture.md](decoupling-architecture.md) | Target architecture for standalone home-manager |
| [migration-plan.md](migration-plan.md) | File-by-file migration tracking |
| [migration-findings.md](migration-findings.md) | Migration discoveries & notes |
| [NIXOS_CONFIG_MIGRATION.md](NIXOS_CONFIG_MIGRATION.md) | NixOS → Home-Manager migration status |

### Practices & Features

| Guide | Description |
|-------|-------------|
| [ephemeral.md](ephemeral.md) | Ephemerality strategy & impermanence |
| [node2nix.md](node2nix.md) | NPM package management with node2nix |
| [SYMLINK-QUICK-REFERENCE.md](SYMLINK-QUICK-REFERENCE.md) | Symlink management |
| [git-hooks-integration.md](git-hooks-integration.md) | Pre-commit hooks setup |

### Maintenance

| Guide | Description |
|-------|-------------|
| [DEBUGGING_AND_MAINTENANCE.md](DEBUGGING_AND_MAINTENANCE.md) | Build debugging guide |
| [DEPRECATION_FIXES.md](DEPRECATION_FIXES.md) | Fixing deprecated options |

---

## Architecture Comparison

| Layer | Managed By | Requires sudo | Portable |
|-------|------------|---------------|----------|
| **System** | NixOS (→ [../nixos/](../nixos/)) | Yes | No (NixOS only) |
| **User** | Home-Manager (this) | No | Yes (any distro) |

**Home-Manager (unstable packages):**
- ALL user packages (browsers, apps, dev tools)
- ~160 packages, full portability across distros

---

## Usage

```bash
# Apply configuration
home-manager switch --flake .#mitsio@shoshin

# Update all packages
nix flake update
home-manager switch --flake .#mitsio@shoshin
```

---

## Current Modules

| Module | Purpose |
|--------|---------|
| `home.nix` | Main entry |
| `shell.nix` | Bash config, aliases |
| `kitty.nix` | Terminal config |
| `vscodium.nix` | IDE settings |
| `keepassxc.nix` | Password manager |
| `syncthing-myspaces.nix` | File sync |
| `rclone-gdrive.nix` | Cloud backup |

---

## Related Documentation

- [../nixos/](../nixos/) - NixOS system configuration
- [../tools/](../tools/) - Tool-specific guides
- [../sync/](../sync/) - Synchronization setup
