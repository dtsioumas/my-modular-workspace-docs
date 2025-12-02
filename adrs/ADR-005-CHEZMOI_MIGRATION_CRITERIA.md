# ADR-005: Chezmoi Migration Criteria

**Status:** Accepted
**Date:** 2025-11-29
**Decision Makers:** Dimitris Tsioumas

---

## Context

The project uses both **Home-Manager** (Nix-based) and **chezmoi** for dotfile management. This creates confusion about where new configurations should be placed. Clear criteria are needed to decide what goes where.

### Current State

- **Home-Manager**: Manages packages, systemd services, and Nix-specific integrations
- **Chezmoi**: Manages cross-platform dotfiles and templated configurations

---

## Decision

### Migrate to Chezmoi When:

1. **Cross-platform compatibility is needed**
   - Config should work on NixOS, Fedora, and other Linux distros
   - Preparing for future OS migration

2. **Simple configuration files**
   - Plain text configs (ini, toml, yaml, json)
   - No complex generation logic needed
   - No secrets requiring Nix-specific encryption

3. **Application settings only**
   - App UI preferences, keybindings, themes
   - NOT package installation or service management

4. **Template benefits apply**
   - Machine-specific values (hostname, paths)
   - Platform-specific conditionals (Linux vs macOS)

### Keep in Home-Manager When:

1. **Package management required**
   - Installing packages via nixpkgs
   - Version pinning needed

2. **systemd services involved**
   - User services and timers
   - Activation scripts

3. **Nix-specific features used**
   - Package overlays
   - Complex derivations
   - Home-manager modules (programs.*)

4. **System integration needed**
   - Environment variables (PATH, etc.)
   - Shell initialization
   - Symlink management to Nix store

---

## Migration Checklist

Before migrating a config:

- [ ] Is it a simple config file? (not service/package)
- [ ] Does it need cross-platform support?
- [ ] Can it work without Nix-specific features?
- [ ] Is the home-manager version just setting options?

If all YES → Migrate to chezmoi

---

## Examples

### Migrate to Chezmoi

| Config | Reason |
|--------|--------|
| `~/.gitconfig` | Simple config, cross-platform |
| `~/.config/kitty/` | App settings, themes |
| `~/.config/atuin/` | Simple toml config |
| `~/.config/navi/` | Cheatsheets, config |

### Keep in Home-Manager

| Config | Reason |
|--------|--------|
| VSCodium extensions | Complex activation scripts |
| rclone sync service | systemd timer required |
| Brave browser | NVIDIA overlays |
| Shell initialization | PATH, environment vars |

---

## Consequences

### Positive

- Clear decision framework for new configs
- Easier Fedora migration path
- Reduced home-manager complexity
- Cross-platform dotfiles

### Negative

- Two systems to maintain temporarily
- Need to track what's where (see MIGRATION_STATUS.md)
- Some configs split between systems

---

## References

- `docs/chezmoi/MIGRATION_STATUS.md` - Current migration state
- `docs/chezmoi/README.md` - Chezmoi documentation
- `home-manager/home.nix` - Home-manager configuration
