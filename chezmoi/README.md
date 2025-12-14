# Chezmoi Documentation

This directory contains all documentation related to dotfile management using `chezmoi`.

## Documentation Index

| Document | Description |
|----------|-------------|
| [chezmoi-guide.md](chezmoi-guide.md) | **Comprehensive guide** covering setup, templates, secrets, migration, and best practices. |
| [MIGRATION_STATUS.md](MIGRATION_STATUS.md) | The current status of the dotfile migration process. |
| [DOTFILES_INVENTORY.md](DOTFILES_INVENTORY.md) | A complete inventory of dotfiles with priority and investigation findings. |
| README.md (this file) | An index of the `chezmoi` documentation. |

---

## Quick Reference

### Core Commands

```bash
chezmoi status          # Show differences between source and destination
chezmoi diff            # Show a diff of what would change
chezmoi apply           # Apply changes to the destination
chezmoi add <file>      # Add a file to the source state
chezmoi re-add <file>   # Update the source state from the destination
chezmoi managed         # List all files managed by chezmoi
```

### Architecture: Chezmoi vs. Home-Manager

A key architectural decision in this workspace is the split of responsibilities between `chezmoi` and `home-manager`.

**Use Chezmoi when:**
- The configuration is cross-platform (will work on non-NixOS systems).
- The files are simple configs (ini, toml, yaml, json).
- Templating is needed for machine-specific values.

**Use Home-Manager when:**
- Managing Nix packages or systemd services.
- Configuration is tightly coupled to the Nix ecosystem.
- Declarative management of symlinks to the Nix store is required.

See [ADR-005](../adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md) for the full decision record.