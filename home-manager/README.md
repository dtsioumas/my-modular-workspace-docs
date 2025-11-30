# Home Manager Documentation

**Last Updated:** 2025-11-30
**User:** mitsio
**Strategy:** Standalone home-manager with unstable packages
**Files:** 14 documents

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

## Architecture

**System (NixOS - stable 25.05):**
- Base system, NVIDIA, KDE Plasma
- Virtualization/containerization daemons

**Home-Manager (unstable):**
- ALL user packages (browsers, apps, dev tools)
- ~100+ packages, full portability

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
