# Home-Manager: Debugging and Maintenance Guide

**Created:** 2025-11-23
**Research Sources:** Home-Manager Official Docs, NixOS & Flakes Book
**Workspace:** my-modular-workspace/home-manager

---

## Table of Contents

1. [Overview](#overview)
2. [Build Debugging](#build-debugging)
3. [Common Errors](#common-errors)
4. [Maintenance](#maintenance)
5. [Workflows](#workflows)
6. [Navi Cheatsheets](#navi-cheatsheets)

---

## Overview

This guide documents best practices for debugging and maintaining Home-Manager configurations in the my-modular-workspace project.

### Home-Manager Configuration

- **Location:** `~/MySpaces/my-modular-workspace/home-manager/`
- **Flake:** Standalone flake (not NixOS module)
- **Packages:** All from `nixpkgs-unstable`
- **Hosts:** `mitsio@shoshin` (desktop), `mitsio@laptop-system01` (future)

---

## Build Debugging

### Essential Commands

```bash
# Build without activation (safe testing)
home-manager build --flake .#mitsio@shoshin --show-trace

# Switch with full debugging
home-manager switch --flake .#mitsio@shoshin --show-trace -v

# Clear evaluation cache (fixes "cached failure")
rm -rf ~/.cache/nix/eval-cache-*
home-manager build --flake .#mitsio@shoshin --show-trace
```

### Debug Workflow

1. **Build first, switch later**
   ```bash
   cd ~/MySpaces/my-modular-workspace/home-manager
   home-manager build --flake .#mitsio@shoshin --show-trace
   # If successful:
   home-manager switch --flake .#mitsio@shoshin
   ```

2. **Use REPL for interactive debugging**
   ```bash
   cd ~/MySpaces/my-modular-workspace/home-manager
   nix repl
   :lf .
   # Explore configuration
   outputs.homeConfigurations."mitsio@shoshin".<TAB>
   ```

3. **Check specific options**
   ```bash
   home-manager option programs.git.enable
   home-manager option home.packages
   ```

### Flake Debugging

```bash
# Validate flake
nix flake check --show-trace

# Show flake metadata
nix flake metadata

# Inspect flake inputs
nix flake metadata --json | jq '.locks.nodes'

# Update inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

---

## Common Errors

### 1. Package Collisions

**Error:**
```
collision between '/nix/store/.../bin/hello' and '/nix/store/.../bin/hello'
building path(s) '/nix/store/...-user-environment'
builder for '...-user-environment.drv' failed with exit code 2
```

**Cause:** Package installed both via `home.packages` and `nix-env -i`

**Solution:**
```bash
# Check manually installed packages
nix-env --query

# Remove specific package
nix-env --uninstall <package>

# Nuclear option - remove all manually installed
nix-env --uninstall '*'
```

**Prevention:** Always use `home.packages` instead of `nix-env -i`

### 2. Dotfile Conflicts

**Error:**
```
Existing file '/home/mitsio/.config/git/config' is in the way
Please move the above files and try again
```

**Solution:**
```bash
# Backup existing file
mkdir -p ~/.dotfiles-backup
mv ~/.config/git/config ~/.dotfiles-backup/

# Retry
home-manager switch --flake .#mitsio@shoshin
```

**Alternative:** Use `--no-backup` flag (not recommended)

### 3. Type Errors

**Error:**
```
error: A definition for option `programs.emacs.enable' is not of type `boolean'
Definition values:
- In `/home/mitsio/.config/home-manager/home.nix': "yes"
```

**Cause:** Wrong type for option (string instead of boolean)

**Solution:**
```nix
# Wrong
programs.emacs.enable = "yes";

# Correct
programs.emacs.enable = true;
```

**Debug in REPL:**
```bash
nix repl
:lf .
outputs.homeConfigurations."mitsio@shoshin".config.programs.emacs.enable
```

### 4. Cached Failure

**Error:**
```
error: cached failure of attribute '...'
```

**Solution:**
```bash
rm -rf ~/.cache/nix/eval-cache-*
home-manager build --flake .#mitsio@shoshin --show-trace
```

### 5. Activation Failures

**Error:**
```
Activating checkLinkTargets
Existing file '/home/mitsio/.bashrc' is in the way
```

**Solution:**
1. Backup conflicting file
2. Remove or rename it
3. Retry switch
4. Manually merge if needed

### 6. nix-ld Required for uv/Python Tools (CRITICAL)

**Error:**
```
error: Querying Python at `/home/mitsio/.local/share/uv/python/cpython-3.14.0-linux-x86_64-gnu/bin/python3.14` failed
NixOS cannot run dynamically linked executables intended for generic linux environments out of the box.
```

**Cause:** `uv` downloads pre-compiled Python binaries that are dynamically linked. NixOS doesn't have `/lib64/ld-linux-x86-64.so.2` by default.

**Solution:** Enable nix-ld in your **NixOS configuration** (NOT home-manager):

```nix
# In /etc/nixos/configuration.nix or your NixOS flake
{
  # Enable nix-ld for running dynamically linked executables (uv, pip wheels, etc.)
  # See: https://wiki.nixos.org/wiki/Python_quickstart_using_uv
  programs.nix-ld.enable = true;
}
```

Then rebuild NixOS:
```bash
sudo nixos-rebuild switch --flake <your-nixos-flake>
```

**Reference:** https://wiki.nixos.org/wiki/Python_quickstart_using_uv

### 7. Hash Mismatch in nixpkgs-unstable

**Error:**
```
error: hash mismatch in fixed-output derivation '/nix/store/...-source.drv':
         specified: sha256-LzPjvJ/...
            got:    sha256-OYK86Ga...
```

**Cause:** Upstream source has changed but nixpkgs hasn't updated the hash yet. Common with nixpkgs-unstable.

**Solution Options:**
1. **Temporary:** Comment out the package in `home.packages` until nixpkgs fixes it
2. **Wait:** nixpkgs-unstable usually fixes within 1-3 days
3. **Override:** Use an overlay to fix the hash (advanced)

**Example (temporary disable):**
```nix
home.packages = with pkgs; [
  # kubectl-rook-ceph  # TEMPORARILY DISABLED - hash mismatch (2025-11-29)
];
```

### 8. Symlink Backup Conflicts

**Error:**
```
Existing file '/home/mitsio/MyVault' is in the way of '/nix/store/.../MyVault'
```

**Solution:** Use `-b backup` flag:
```bash
home-manager switch --flake .#mitsio@shoshin -b backup
```

Files are moved to `<filename>.backup`. Clean up old backups:
```bash
# Find all backup files
find ~ -maxdepth 3 -name "*.backup" -type f 2>/dev/null

# Remove specific backup
rm ~/MyVault.backup
```

---

## Maintenance

### Generation Management

```bash
# List all generations
home-manager generations

# Detailed generation history
nix profile history --profile ~/.local/state/nix/profiles/home-manager

# Delete old generations (older than 7 days)
home-manager expire-generations "7 days"

# Delete specific generations
nix-env --delete-generations 42 43 44 \
  --profile ~/.local/state/nix/profiles/home-manager
```

### Rollback

```bash
# List generations
home-manager generations

# Copy activation path from output
# Example: id 123 -> /nix/store/xxx-home-manager-generation

# Activate previous generation
/nix/store/<path-from-generations>/activate
```

### Garbage Collection

```bash
# Collect garbage (user-level)
nix-collect-garbage --delete-old

# Full garbage collection
nix-collect-garbage -d

# Dry run (see what would be deleted)
nix-collect-garbage --dry-run
```

**Important:** Run as user (NOT with sudo)

### Store Optimization

```bash
# Optimize store (deduplicate files)
nix-store --optimise

# Show disk usage
du -sh ~/.local/state/nix/profiles/home-manager*

# Find largest packages
nix path-info -rsSh ~/.local/state/nix/profiles/home-manager | \
  sort -k2 -hr | head -20
```

### Flake Updates

```bash
cd ~/MySpaces/my-modular-workspace/home-manager

# Update all inputs
nix flake update

# Update nixpkgs only
nix flake lock --update-input nixpkgs

# Show what changed
git diff flake.lock

# Rebuild with updates
home-manager switch --flake .#mitsio@shoshin
```

### Cache Cleanup

```bash
# Clean user cache
rm -rf ~/.cache/nix/*

# Clean evaluation cache only
rm -rf ~/.cache/nix/eval-cache-*

# Clean build cache
rm -rf ~/.cache/nix/fetchers
```

---

## Workflows

### Daily Development

```bash
# 1. Edit configuration
code ~/MySpaces/my-modular-workspace/home-manager/home.nix

# 2. Test build
home-manager build --flake .#mitsio@shoshin --show-trace

# 3. If successful, switch
home-manager switch --flake .#mitsio@shoshin

# 4. Commit changes
cd ~/MySpaces/my-modular-workspace/home-manager
git add .
git commit -m "Update home-manager config"
```

### Weekly Maintenance

```bash
# 1. Update flake inputs
cd ~/MySpaces/my-modular-workspace/home-manager
nix flake update

# 2. Rebuild
home-manager switch --flake .#mitsio@shoshin

# 3. Delete old generations
home-manager expire-generations "7 days"

# 4. Garbage collect
nix-collect-garbage --delete-old

# 5. Optimize store
nix-store --optimise
```

### Adding New Package

```bash
# 1. Search for package
nix search nixpkgs <package-name>

# 2. Add to home.nix
# home.packages = with pkgs; [ ... new-package ];

# 3. Test build
home-manager build --flake .#mitsio@shoshin --show-trace

# 4. Switch
home-manager switch --flake .#mitsio@shoshin

# 5. Verify
which <command>
```

### Debugging Type Errors

```bash
# 1. Note the option from error message
# Example: programs.git.userName

# 2. Check in REPL
nix repl
:lf .
outputs.homeConfigurations."mitsio@shoshin".config.programs.git.userName

# 3. Check expected type
home-manager option programs.git.userName

# 4. Fix in home.nix
# programs.git.userName = "John Doe";  # Must be string

# 5. Rebuild
home-manager switch --flake .#mitsio@shoshin
```

---

## Navi Cheatsheets

### Available Commands

```bash
# Launch Navi and search
navi --query "home-manager"

# Filter by tag
navi --tag home-manager

# Print command without executing
navi --print
```

### Cheatsheets Locations

- **home-manager-build-debug.cheat** - Build debugging workflows
- **home-manager-maintenance.cheat** - Maintenance commands

**Path:** `~/.local/share/navi/cheats/`

---

## Best Practices

### 1. Always Build Before Switch

```bash
# Good
home-manager build --flake .#mitsio@shoshin --show-trace
home-manager switch --flake .#mitsio@shoshin

# Bad (switch immediately without testing)
home-manager switch --flake .#mitsio@shoshin
```

### 2. Use Git for Version Control

```bash
# Before making changes
git status
git add .
git commit -m "Before adding X"

# Make changes
# ...

# If something breaks
git diff
git restore home.nix
```

### 3. Never Use nix-env

**Bad:**
```bash
nix-env -iA nixpkgs.hello  # Creates collisions!
```

**Good:**
```nix
# In home.nix
home.packages = with pkgs; [ hello ];
```

### 4. Test New Packages in REPL First

```bash
nix repl
:lf .
pkgs = nixpkgs.legacyPackages.x86_64-linux
pkgs.hello
```

### 5. Regular Maintenance

Schedule weekly:
- Update flake inputs
- Delete old generations (> 7 days)
- Garbage collect
- Optimize store

### 6. Clear Cache When Seeing Cached Failures

```bash
rm -rf ~/.cache/nix/eval-cache-*
```

### 7. Use Dry-Run for Testing

```bash
home-manager build --flake .#mitsio@shoshin --dry-run
```

---

## Quick Reference

### Most Used Commands

```bash
# Build
home-manager build --flake .#mitsio@shoshin --show-trace

# Switch
home-manager switch --flake .#mitsio@shoshin

# List generations
home-manager generations

# Expire old
home-manager expire-generations "7 days"

# GC
nix-collect-garbage --delete-old

# Update
nix flake update

# REPL
nix repl
:lf .
```

### Debugging Checklist

- [ ] Clear eval cache
- [ ] Use --show-trace
- [ ] Check in REPL
- [ ] Verify syntax
- [ ] Check for collisions
- [ ] Review error message carefully
- [ ] Test build before switch

### Maintenance Checklist

- [ ] Update flake inputs
- [ ] Delete old generations (> 7 days)
- [ ] Garbage collect
- [ ] Optimize store
- [ ] Check disk space
- [ ] Review and clean manual packages

---

## References

- **Home-Manager Manual:** https://nix-community.github.io/home-manager/
- **Home-Manager GitHub:** https://github.com/nix-community/home-manager
- **NixOS & Flakes Book:** https://github.com/ryan4yin/nixos-and-flakes-book
- **Package Search:** https://search.nixos.org/packages
- **Options Search:** https://search.nixos.org/options

---

**Last Updated:** 2025-11-23
**Maintained by:** Dimitris Tsioumas (mitsio)
**Workspace:** my-modular-workspace/home-manager
