# NixOS Configuration - Quick Start Guide

**Last Updated:** 2025-11-23
**Purpose:** Essential commands and workflows for daily use

---

## Essential Commands

### System Rebuild

```bash
# Standard rebuild (via /etc/nixos symlink)
sudo nixos-rebuild switch --flake .#shoshin

# Explicit path (if not in config dir)
sudo nixos-rebuild switch --flake ~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos#shoshin

# Test changes (non-persistent, reverts on reboot)
sudo nixos-rebuild test --flake .#shoshin

# Dry-run (see what would change, no actual build)
sudo nixos-rebuild dry-build --flake .#shoshin

# Build with full debugging
sudo nixos-rebuild switch --flake .#shoshin --show-trace -v
```

### Development Workflow

```bash
# Enter dev shell (installs pre-commit hooks)
nix develop

# Check config validity
nix flake check

# Update all dependencies
nix flake update

# Run pre-commit hooks manually
nix develop -c pre-commit run --all-files

# Format all Nix files
nix develop -c alejandra .

# Lint all Nix files
nix develop -c statix check .

# Find dead code
nix develop -c deadnix .
```

### Git Workflow

```bash
# Check status
git status

# Stage changes
git add .

# Commit (pre-commit hooks run automatically)
git commit -m "description"

# Push to remote
git push origin main

# Skip hooks if needed (NOT recommended)
SKIP=alejandra git commit -m "description"
```

---

## Common Tasks

### Adding a New Package

**System Package (all users):**
```nix
# Edit: modules/common.nix
environment.systemPackages = with pkgs; [
  # Add package here
  new-package
];
```

**User Package (home-manager):**
```nix
# Edit: home/mitsio/home.nix
home.packages = with pkgs; [
  # Add package here
  new-package
];
```

**Rebuild:**
```bash
sudo nixos-rebuild switch --flake .#shoshin
```

### Creating a New Module

```bash
# 1. Create module file
vim modules/category/feature.nix

# 2. Add import
vim hosts/shoshin/configuration.nix
# Add: ../../modules/category/feature.nix to imports

# 3. Test
sudo nixos-rebuild test --flake .#shoshin

# 4. Apply
sudo nixos-rebuild switch --flake .#shoshin

# 5. Commit
git add . && git commit -m "Add feature module"
```

### Updating Dependencies

```bash
# Update flake.lock
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# See what changed
git diff flake.lock

# Rebuild with updates
sudo nixos-rebuild switch --flake .#shoshin
```

---

## File Locations

### Configuration Files

```bash
# Main config directory
cd ~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/

# Flake entry point
vim flake.nix

# Host-specific config
vim hosts/shoshin/configuration.nix

# Common settings (most edited)
vim modules/common.nix

# User settings
vim home/mitsio/home.nix

# Documentation
cd docs/
```

### System Symlink

```bash
# /etc/nixos points to config directory
ls -la /etc/nixos
# → ~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/
```

---

## Code Quality Tools

### Formatting (alejandra)

```bash
# Format entire project
alejandra .

# Format specific file
alejandra modules/common.nix

# Check without modifying
alejandra --check .
```

### Linting (statix)

```bash
# Lint entire project
statix check .

# Lint specific file
statix check modules/common.nix

# Auto-fix issues
statix fix modules/common.nix

# Ignore directories
statix check . -i .direnv
```

### Dead Code Detection (deadnix)

```bash
# Find dead code
deadnix .

# Auto-remove (DANGEROUS - commit first!)
deadnix --edit .

# Exclude lambda arguments
deadnix -l .

# Exclude pattern names (for nixpkgs callPackage)
deadnix -L .
```

---

## Pre-commit Hooks

### Setup (First Time)

```bash
# Enter dev shell (auto-installs hooks)
nix develop

# Verify installation
ls -la .git/hooks/pre-commit
pre-commit --version
```

### Usage

```bash
# Hooks run automatically on: git commit

# Run manually on all files
nix develop -c pre-commit run --all-files

# Run specific hook
nix develop -c pre-commit run alejandra

# Update hooks
nix flake update
nix develop  # Re-enter shell
```

### Skip Hooks (Emergency)

```bash
# Skip all hooks (NOT recommended)
git commit --no-verify -m "emergency fix"

# Skip specific hook
SKIP=alejandra git commit -m "description"

# Skip multiple hooks
SKIP=alejandra,statix git commit -m "description"
```

---

## Troubleshooting

### Build Fails

```bash
# Check syntax
nix flake check

# See detailed errors
sudo nixos-rebuild switch --flake .#shoshin --show-trace

# Check specific file syntax
nix-instantiate --parse modules/common.nix

# Verify all imports exist
find . -name "*.nix" -exec echo "Checking {}" \; -exec nix-instantiate --parse {} \;
```

### Hooks Blocking Commit

```bash
# See what failed
nix develop -c pre-commit run --all-files

# Fix formatting
nix develop -c alejandra .

# Fix linting (manual - read errors)
statix check .

# Commit after fixes
git add . && git commit -m "description"
```

### Module Not Loading

```bash
# Verify import in configuration.nix
grep -r "feature.nix" hosts/shoshin/configuration.nix

# Check for typos
find modules/ -name "feature.nix"

# Test rebuild
sudo nixos-rebuild test --flake .#shoshin --show-trace
```

### System Rollback

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous
sudo nixos-rebuild switch --rollback

# Switch to specific generation
sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation 42
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

---

## Session Start Checklist

When starting a new work session:

```bash
# 1. Navigate to config
cd ~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/

# 2. Check git status
git status

# 3. Pull latest (if working across machines)
git pull

# 4. Review TODO
cat TODO.md | head -50

# 5. Enter dev shell (if committing)
nix develop
```

---

## Quick Reference

### Package Search

```bash
# Search nixpkgs online
# https://search.nixos.org/packages

# Search locally
nix-env -qaP firefox

# Search flake
nix search nixpkgs firefox
```

### Service Management

```bash
# System services
systemctl status service-name
systemctl restart service-name
systemctl enable service-name

# User services
systemctl --user status service-name
systemctl --user restart service-name
```

### Logs

```bash
# System journal
journalctl -xe

# Service logs
journalctl -u service-name -f

# Boot logs
journalctl -b

# User journal
journalctl --user -xe
```

### Nix Store

```bash
# Garbage collect
nix-collect-garbage -d

# With sudo for system profiles
sudo nix-collect-garbage -d

# Optimize store (deduplicate)
nix-store --optimise
```

---

## Performance Tips

### Faster Rebuilds

```bash
# Use binary cache (automatically enabled)
# Avoid --option substitute false

# Parallel builds (already set in config)
# nix.settings.max-jobs = auto;

# Use `test` instead of `switch` during development
sudo nixos-rebuild test --flake .#shoshin
```

### Editor Integration

**VSCode/VSCodium:**
- Install: `jnoortheen.nix-ide` extension
- Formatter: alejandra (configured in settings)
- Linter: statix (via extension)

**Neovim:**
```lua
-- Use null-ls or conform.nvim
require('null-ls').setup({
  sources = {
    require('null-ls').builtins.formatting.alejandra,
    require('null-ls').builtins.diagnostics.statix,
  }
})
```

---

## Emergency Procedures

### Can't Boot

```bash
# Boot into previous generation
# At GRUB: Select "NixOS - Configuration X (previous)"

# Or from recovery:
sudo nixos-rebuild switch --rollback
```

### Broken Config

```bash
# Revert last commit
git revert HEAD
sudo nixos-rebuild switch --flake .#shoshin

# Or reset to known-good state
git reset --hard <commit-hash>
sudo nixos-rebuild switch --flake .#shoshin
```

### Out of Disk Space

```bash
# Quick cleanup
sudo nix-collect-garbage -d
nix-collect-garbage -d

# Aggressive cleanup (removes ALL old generations)
sudo nix-collect-garbage --delete-older-than 1d

# Check space
df -h /nix
du -sh /nix/store
```

---

## Documentation Links

- **Repository Structure:** [REPOSITORY_STRUCTURE.md](REPOSITORY_STRUCTURE.md)
- **Formatters:** [nixos/FORMATTERS.md](nixos/FORMATTERS.md)
- **Linters:** [nixos/LINTERS.md](nixos/LINTERS.md)
- **Pre-commit Setup:** [pre-commit/SETUP.md](pre-commit/SETUP.md)

**External:**
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Nix Package Search: https://search.nixos.org/packages
- Home Manager Manual: https://nix-community.github.io/home-manager/
- Plasma Manager: https://github.com/nix-community/plasma-manager

---

## Cheat Sheet

```bash
# Most common commands
sudo nixos-rebuild switch --flake .#shoshin  # Apply changes
nix develop                                   # Enter dev shell
git status && git add . && git commit        # Commit changes
nix flake update                             # Update dependencies
alejandra .                                   # Format code
statix check .                                # Lint code
```

**Last Revised:** 2025-11-23
