# NixOS & Home-Manager: Debugging and Maintenance Guide

**Created:** 2025-11-23
**Research Sources:** NixOS & Flakes Book, Home-Manager Docs, NixOS Discourse
**Navi Cheatsheets:** 6 interactive cheatsheets created

---

## Table of Contents

1. [Overview](#overview)
2. [NixOS Build Debugging](#nixos-build-debugging)
3. [NixOS Maintenance](#nixos-maintenance)
4. [Home-Manager Debugging](#home-manager-debugging)
5. [Home-Manager Maintenance](#home-manager-maintenance)
6. [Navi Cheatsheets](#navi-cheatsheets)
7. [Best Practices](#best-practices)
8. [Common Issues & Solutions](#common-issues--solutions)

---

## Overview

This guide documents best practices for debugging build errors and maintaining NixOS and Home-Manager configurations. All commands are also available as interactive Navi cheatsheets for quick access.

### Key Resources

- **NixOS & Flakes Book:** https://github.com/ryan4yin/nixos-and-flakes-book
- **Home-Manager Manual:** https://github.com/nix-community/home-manager
- **NixOS Discourse:** https://discourse.nixos.org/

---

## NixOS Build Debugging

### Essential Debug Flags

The most important flags for debugging NixOS builds:

```bash
# Full debugging (recommended)
sudo nixos-rebuild switch --flake .#shoshin --show-trace -L -v

# Breakdown:
# --show-trace  : Show detailed evaluation trace
# -L            : Print build logs (--print-build-logs)
# -v            : Verbose output (--verbose)
```

### Key Debugging Techniques

#### 1. Clear Evaluation Cache

**Problem:** "cached failure of attribute" errors hide actual error messages.

**Solution:**
```bash
rm -rf ~/.cache/nix/eval-cache-*
sudo nixos-rebuild switch --flake .#shoshin --show-trace
```

**Source:** NixOS Discourse - https://discourse.nixos.org/t/31577

#### 2. Use `test` Instead of `switch` During Development

**Problem:** Failed builds create unnecessary generations.

**Solution:**
```bash
sudo nixos-rebuild test --flake .#shoshin --show-trace
```

**Benefit:** Activates configuration without adding to bootloader (no new generation).

#### 3. Interactive Debugging with Nix REPL

```bash
cd /etc/nixos
nix repl

# In REPL:
:lf .
# Explore configuration
outputs.nixosConfigurations.shoshin.<TAB>
outputs.nixosConfigurations.shoshin.config.<option>
```

**Use Cases:**
- Inspect option values
- Test expressions before adding to config
- Debug type mismatches
- Explore configuration structure

#### 4. Dry Builds for Quick Syntax Checks

```bash
# Check what would be built without building
sudo nixos-rebuild dry-build --flake .#shoshin --show-trace

# Show what would change
sudo nixos-rebuild dry-activate --flake .#shoshin
```

#### 5. Flake Validation

```bash
# Check flake syntax
nix flake check --show-trace

# Show flake metadata
nix flake metadata

# Verify flake.lock consistency
nix flake lock --update-input nixpkgs
```

### Common Error Patterns

#### Type Errors
```
error: A definition for option `programs.emacs.enable' is not of type `boolean'
```

**Solution:** Check option type in configuration.nix manual or via REPL.

#### Infinite Recursion
```
error: infinite recursion encountered
```

**Debug with:**
```bash
nix-instantiate --eval --strict --show-trace
```

#### Package Collisions
```
collision between '/nix/store/.../bin/hello' and '/nix/store/.../bin/hello'
```

**Solution:** Check for duplicate package definitions or conflicts between system and home-manager.

---

## NixOS Maintenance

### Garbage Collection Strategy

#### Automatic Cleanup (Recommended Configuration)

Add to `configuration.nix`:
```nix
{
  # Limit boot generations
  boot.loader.systemd-boot.configurationLimit = 10;

  # Auto garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Auto optimize store (deduplicate files)
  nix.settings.auto-optimise-store = true;
}
```

#### Manual Cleanup Commands

```bash
# Delete old generations (keep last 7 days)
sudo nix profile wipe-history \
  --profile /nix/var/nix/profiles/system \
  --older-than 7d

# Garbage collect unreferenced packages
sudo nix-collect-garbage --delete-old

# Optimize store (can save significant disk space)
sudo nix-store --optimise
```

#### Generation Management

```bash
# List all generations
sudo nix-env --list-generations \
  --profile /nix/var/nix/profiles/system

# Show current generation
nix profile history --profile /nix/var/nix/profiles/system

# Delete specific generation
sudo nix-env --delete-generations 42 \
  --profile /nix/var/nix/profiles/system
```

### Disk Space Analysis

```bash
# Show disk usage of nix store
du -sh /nix/store

# Find largest packages
nix path-info -rsSh /run/current-system | \
  sort -k2 -hr | head -20

# Show closure size
nix path-info -rS /run/current-system
```

### Store Maintenance

```bash
# Verify store integrity
sudo nix-store --verify --check-contents

# Repair corrupted files
sudo nix-store --verify --check-contents --repair

# Show garbage collection roots
nix-store --gc --print-roots

# Find why package is kept
nix-store --query --roots /nix/store/<package>
```

---

## Home-Manager Debugging

### Build Debugging Workflow

```bash
# 1. Build without activation
home-manager build --flake .#mitsio@shoshin --show-trace

# 2. If successful, activate
home-manager switch --flake .#mitsio@shoshin

# 3. If errors occur, use verbose mode
home-manager switch --flake .#mitsio@shoshin --show-trace -v
```

### Common Home-Manager Issues

#### Package Collisions

**Error:**
```
collision between '/nix/store/.../bin/hello' and '/nix/store/.../bin/hello'
```

**Cause:** Package installed both via `home.packages` and `nix-env -i`.

**Solution:**
```bash
# List manually installed packages
nix-env --query

# Remove specific package
nix-env --uninstall hello

# Remove ALL manually installed packages (drastic)
nix-env --uninstall '*'
```

#### Dotfile Conflicts

**Error:**
```
Existing file '/home/mitsio/.config/git/config' is in the way
```

**Solution:**
```bash
# Backup existing file
mkdir -p ~/.dotfiles-backup
mv ~/.config/git/config ~/.dotfiles-backup/

# Then retry
home-manager switch --flake .#mitsio@shoshin
```

#### Type Errors

**Error:**
```
error: A definition for option `programs.git.userName' is not of type `string'
```

**Debug:**
```bash
# Check option in REPL
cd ~/MySpaces/my-modular-workspace/home-manager
nix repl
:lf .
outputs.homeConfigurations."mitsio@shoshin".config.programs.git.userName
```

### Home-Manager REPL Debugging

```bash
cd ~/MySpaces/my-modular-workspace/home-manager
nix repl

# Load flake
:lf .

# Inspect configuration
outputs.homeConfigurations."mitsio@shoshin".<TAB>

# Check specific options
outputs.homeConfigurations."mitsio@shoshin".config.home.packages

# Inspect activation package
outputs.homeConfigurations."mitsio@shoshin".activationPackage
```

---

## Home-Manager Maintenance

### Generation Management

```bash
# List all generations
home-manager generations

# Show detailed history
nix profile history \
  --profile ~/.local/state/nix/profiles/home-manager

# Delete old generations
home-manager expire-generations "7 days"

# Rollback to previous generation
home-manager generations
# Copy activation path from output and run:
/nix/store/<path>/activate
```

### Garbage Collection

```bash
# Garbage collect user packages
nix-collect-garbage --delete-old

# Full user garbage collection
nix-collect-garbage -d

# Show what would be collected (dry run)
nix-collect-garbage --dry-run
```

**Important:** Unlike system garbage collection, user GC must be run as the user (not with sudo).

### Flake Updates

```bash
cd ~/MySpaces/my-modular-workspace/home-manager

# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Rebuild with updated inputs
home-manager switch --flake .#mitsio@shoshin
```

### Disk Space Analysis

```bash
# Show generation sizes
du -sh ~/.local/state/nix/profiles/home-manager-*-link

# Show package sizes
nix path-info -rsSh \
  ~/.local/state/nix/profiles/home-manager | \
  sort -k2 -hr | head -20

# Check disk usage
df -h ~
```

---

## Navi Cheatsheets

All debugging and maintenance commands are available as interactive Navi cheatsheets:

### Available Cheatsheets

1. **nixos-build-debug.cheat** - NixOS build debugging
   - Trace options
   - REPL debugging
   - Syntax checking
   - Error analysis

2. **nixos-maintenance.cheat** - NixOS maintenance
   - Garbage collection
   - Generation management
   - Store optimization
   - Disk space analysis

3. **nixos-rebuild.cheat** - NixOS rebuild workflows
   - Test, switch, boot modes
   - Dry-run operations
   - Flake updates

4. **nixos-rollback.cheat** - NixOS rollback procedures
   - Generation switching
   - Emergency recovery
   - Generation comparison

5. **home-manager-build-debug.cheat** - Home-Manager debugging
   - Build errors
   - Type checking
   - Collision resolution

6. **home-manager-maintenance.cheat** - Home-Manager maintenance
   - Generation cleanup
   - Package management
   - Flake updates

### Using Navi

```bash
# Launch Navi
navi

# Search for specific command
navi --query "rebuild switch"

# Filter by tag
navi --tag nixos

# Print command instead of executing
navi --print
```

**Location:** `~/.local/share/navi/cheats/`

---

## Best Practices

### Development Workflow

1. **Make small, incremental changes**
   - Easier to debug when errors occur
   - Git commit frequently

2. **Use `test` during development**
   ```bash
   sudo nixos-rebuild test --flake .#shoshin --show-trace
   ```

3. **Clear eval cache when seeing cached failures**
   ```bash
   rm -rf ~/.cache/nix/eval-cache-*
   ```

4. **Test in REPL before adding to config**
   ```bash
   nix repl
   :lf .
   # Test expressions interactively
   ```

5. **Use dry-build for quick validation**
   ```bash
   sudo nixos-rebuild dry-build --flake .#shoshin
   ```

### Maintenance Schedule

**Weekly:**
- Garbage collect old generations
- Optimize store

**Monthly:**
- Update flake inputs
- Review and delete old generations
- Check disk space

**Configuration:**
```nix
# Automated weekly cleanup
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};
```

### Error Debugging Process

1. **Read the error message carefully**
   - Look for file paths in your configuration
   - Note the specific option causing the issue

2. **Use `--show-trace`**
   - Always add this flag when debugging

3. **Clear caches if you see "cached failure"**
   ```bash
   rm -rf ~/.cache/nix/eval-cache-*
   ```

4. **Inspect in REPL**
   - Load flake and explore affected options

5. **Make targeted fixes**
   - Fix one issue at a time
   - Test after each fix

6. **Consult documentation**
   - `man configuration.nix`
   - https://search.nixos.org/options

---

## Common Issues & Solutions

### Issue: Build Takes Forever

**Symptoms:** Rebuild seems stuck

**Solutions:**
1. Check if actually building (not just evaluating)
2. Monitor with: `sudo journalctl -fu nix-daemon`
3. Kill and restart with `-v` to see progress

### Issue: "cached failure of attribute"

**Symptoms:** No detailed error, just "cached failure"

**Solution:**
```bash
rm -rf ~/.cache/nix/eval-cache-*
sudo nixos-rebuild switch --flake .#shoshin --show-trace
```

### Issue: Package Collision

**Symptoms:** "collision between" error

**Solutions:**
1. Check for duplicate package in system + home-manager
2. Remove manually installed packages: `nix-env --uninstall '*'`
3. Use `lib.mkForce` to override conflicting options

### Issue: Out of Disk Space

**Symptoms:** "/nix/store is full"

**Solutions:**
```bash
# Quick cleanup
sudo nix-collect-garbage -d
sudo nix-store --optimise

# Check what's using space
nix path-info -rsSh /run/current-system | sort -k2 -hr | head -20
```

### Issue: Type Mismatch

**Symptoms:** "not of type X" error

**Solution:**
```bash
# Check option type in REPL
nix repl
:lf .
outputs.nixosConfigurations.shoshin.config.<option>

# Or check manual
man configuration.nix
```

### Issue: Flake Lock Inconsistency

**Symptoms:** Unexpected package versions

**Solution:**
```bash
cd /etc/nixos
nix flake lock --update-input nixpkgs
sudo nixos-rebuild switch --flake .#shoshin
```

---

## References

### Documentation
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- NixOS & Flakes Book: https://github.com/ryan4yin/nixos-and-flakes-book
- Home-Manager Manual: https://nix-community.github.io/home-manager/
- NixOS Wiki: https://wiki.nixos.org/

### Tools
- Nix REPL: Built-in (`nix repl`)
- Navi: https://github.com/denisidoro/navi
- nix-tree: `nix-shell -p nix-tree`
- nix-diff: `nix-shell -p nix-diff`

### Search
- Options: https://search.nixos.org/options
- Packages: https://search.nixos.org/packages
- NixOS Discourse: https://discourse.nixos.org/

---

**Last Updated:** 2025-11-23
**Maintained by:** Dimitris Tsioumas (mitsio)
**Workspace:** my-modular-workspace/nixos
