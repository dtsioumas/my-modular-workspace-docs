# Package Upgrade Guide (NixOS & Home-Manager)

**Created**: 2025-12-19
**Scope**: How to upgrade packages in your flake-based home-manager setup

---

## Understanding Nix Package Versions

### How Versions Are Determined

In your current setup:

```nix
# flake.nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # ← This determines package versions
  home-manager.url = "github:nix-community/home-manager";
};
```

**Key concept**:
- Package versions come from the **nixpkgs** channel you're tracking
- `nixos-unstable` gets new package versions every few days
- `flake.lock` pins the exact nixpkgs commit you're using
- No manual version management needed for most packages!

---

## Upgrading Packages

### Option 1: Upgrade Everything (Recommended)

**What it does**: Updates all flake inputs (nixpkgs, home-manager, etc.) to latest versions

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Update all inputs and rebuild
nix flake update && home-manager switch --flake .#mitsio@shoshin -b backup

# Or as a one-liner:
nix flake update && home-manager switch --flake .#mitsio@shoshin -b backup --max-jobs 1 --cores 7
```

**When to use**:
- Monthly maintenance updates
- Want latest Firefox, VSCodium, etc.
- General system updates

---

### Option 2: Upgrade Only nixpkgs (Firefox, System Packages)

**What it does**: Updates only the nixpkgs input, leaving home-manager and other inputs unchanged

```bash
# Update just nixpkgs
nix flake lock --update-input nixpkgs

# Rebuild with new packages
home-manager switch --flake .#mitsio@shoshin -b backup
```

**When to use**:
- Want newer Firefox but current home-manager is working fine
- Security updates for packages
- Targeted updates

---

### Option 3: Upgrade Specific Input

```bash
# Update only home-manager
nix flake lock --update-input home-manager

# Update only Claude Desktop
nix flake lock --update-input claude-desktop
```

---

## Firefox-Specific Upgrades

### Check Current Firefox Version

```bash
# From nixpkgs
nix eval nixpkgs#firefox.version

# Installed version
firefox --version
```

### Upgrade Firefox

```bash
# Method 1: Update nixpkgs (gets latest Firefox from unstable)
nix flake lock --update-input nixpkgs
home-manager switch --flake .#mitsio@shoshin -b backup

# Method 2: Full update (all packages)
nix flake update
home-manager switch --flake .#mitsio@shoshin -b backup
```

### Check Available Firefox Versions

```bash
# See what version would be installed
nix eval github:NixOS/nixpkgs/nixos-unstable#firefox.version

# See what version is in stable
nix eval github:NixOS/nixpkgs/nixos-25.05#firefox.version
```

---

## Pinning Specific Package Versions (Advanced)

### When You Need This

- Want Firefox ESR (Extended Support Release) instead of latest
- Need to stay on specific version for compatibility
- Testing a specific build

### Method 1: Use Different Firefox Package

```nix
# In home.nix or firefox.nix
programs.firefox = {
  enable = true;
  package = pkgs.firefox-esr;  # ← Use ESR instead of latest
};
```

Available Firefox variants in nixpkgs:
- `pkgs.firefox` - Latest release (default)
- `pkgs.firefox-esr` - Extended Support Release (older, stable)
- `pkgs.firefox-beta` - Beta channel
- `pkgs.firefox-devedition` - Developer Edition
- `pkgs.firefox-bin` - Pre-built binary from Mozilla (fastest, no compilation)

### Method 2: Pin nixpkgs to Specific Commit (For Specific Version)

```nix
# flake.nix
inputs = {
  # Pin to specific commit where Firefox was version X
  nixpkgs.url = "github:NixOS/nixpkgs/abc123def456";  # ← Specific commit
};
```

To find the commit for a specific Firefox version:
1. Go to https://lazamar.co.uk/nix-versions/?package=firefox
2. Search for desired Firefox version
3. Copy the nixpkgs commit hash
4. Update `flake.nix` with that commit

---

## Automatic Updates (Optional)

### Daily/Weekly Automatic Updates

You can automate flake updates with a systemd timer:

```nix
# Add to home.nix
systemd.user.services.flake-update = {
  Unit.Description = "Update home-manager flake inputs";
  Service = {
    Type = "oneshot";
    WorkingDirectory = "${config.home.homeDirectory}/.MyHome/MySpaces/my-modular-workspace/home-manager";
    ExecStart = "${pkgs.nix}/bin/nix flake update";
  };
};

systemd.user.timers.flake-update = {
  Unit.Description = "Weekly flake update";
  Timer = {
    OnCalendar = "weekly";  # or "daily", "monthly"
    Persistent = true;
  };
  Install.WantedBy = [ "timers.target" ];
};
```

**Note**: This only updates `flake.lock`, you still need to manually rebuild with `home-manager switch`.

---

## Rollback if Update Breaks Something

### Rollback to Previous Generation

```bash
# List available generations
home-manager generations

# Rollback to previous generation
home-manager generations | head -2 | tail -1 | awk '{print $NF}' | sh

# Or manually activate a specific generation
/nix/store/...-home-manager-generation/activate
```

### Rollback flake.lock

```bash
# Undo last flake update
git checkout HEAD~1 flake.lock

# Rebuild with old versions
home-manager switch --flake .#mitsio@shoshin -b backup
```

---

## Checking What Will Be Updated

### Before Updating

```bash
# See what packages would change (dry-run)
nix flake update && home-manager switch --flake .#mitsio@shoshin --dry-run

# See diff between current and new nixpkgs
nix flake metadata nixpkgs

# Compare package versions
nix eval .#homeConfigurations."mitsio@shoshin".config.programs.firefox.package.version
nix eval github:NixOS/nixpkgs/nixos-unstable#firefox.version
```

---

## Firefox Upgrade Checklist

When upgrading Firefox:

- [ ] **Backup current generation** (automatic with `-b backup` flag)
- [ ] **Check Firefox release notes** (https://www.mozilla.org/firefox/notes/)
- [ ] **Update flake**: `nix flake lock --update-input nixpkgs`
- [ ] **Rebuild**: `home-manager switch --flake .#mitsio@shoshin -b backup`
- [ ] **Test Firefox**: Launch and verify extensions/settings work
- [ ] **Check memory usage**: Ensure no new memory issues
- [ ] **Rollback if needed**: Use `home-manager generations` to revert

---

## Upgrade Strategy Recommendations

### Conservative (Recommended for Stability)

- Update monthly or when security issues arise
- Test updates in dry-run first
- Keep backups of working generations

```bash
# Monthly update routine
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git pull  # Get latest config changes
nix flake update  # Update package versions
home-manager switch --flake .#mitsio@shoshin -b backup  # Rebuild
```

### Bleeding Edge (Latest Everything)

- Update weekly or daily
- Accept occasional breakage
- Quick rollback if issues

```bash
# Weekly bleeding edge
nix flake update && home-manager switch --flake .#mitsio@shoshin -b backup
```

### Stable (Rarely Update)

- Use `nixos-25.05` (stable) instead of `nixos-unstable`
- Update only for security patches
- Change `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";  # ← Use stable
};
```

---

## Troubleshooting Upgrades

### Issue: Build Fails After Update

```bash
# Check what changed
nix flake metadata

# See nixpkgs diff
git diff flake.lock

# Rollback flake.lock
git checkout HEAD~1 flake.lock
```

### Issue: Firefox Won't Start After Update

```bash
# Check for profile incompatibility
rm -rf ~/.mozilla/firefox/*.default-release/lock

# Clear cache
rm -rf ~/.cache/mozilla/firefox

# Rollback to previous generation
home-manager generations | head -2 | tail -1 | awk '{print $NF}' | sh
```

### Issue: Extensions Break

- Firefox extensions are managed separately from Nix
- Extensions auto-update via Mozilla
- If extension breaks, disable in Firefox settings

---

## Quick Reference Commands

```bash
# Update everything
nix flake update && home-manager switch --flake .#mitsio@shoshin -b backup

# Update only Firefox (via nixpkgs)
nix flake lock --update-input nixpkgs && home-manager switch --flake .#mitsio@shoshin -b backup

# Check Firefox version
firefox --version

# List backups
home-manager generations

# Rollback
home-manager generations | head -2 | tail -1 | awk '{print $NF}' | sh
```

---

## Future: Switching Firefox Variants

If you later want to switch from source-built Firefox to binary:

```nix
# In firefox.nix or home.nix
programs.firefox = {
  enable = true;
  package = pkgs.firefox-bin;  # ← Instant install, no compilation!
};
```

Or use Firefox ESR for stability:

```nix
programs.firefox = {
  enable = true;
  package = pkgs.firefox-esr;  # ← LTS version
};
```

**Note**: When switching Firefox variants, your overlays still apply! The hardware profile system works with all Firefox variants.

---

## Summary

**TL;DR for Firefox upgrades:**

```bash
# Most common: Update everything monthly
nix flake update
home-manager switch --flake .#mitsio@shoshin -b backup --max-jobs 1 --cores 7

# If it breaks, rollback:
home-manager generations | head -2 | tail -1 | awk '{print $NF}' | sh
```

That's it! No version pinning needed unless you have specific requirements.

---

**See Also**:
- NixOS Manual: https://nixos.org/manual/nixos/stable/index.html#sec-upgrading
- Home-Manager Manual: https://nix-community.github.io/home-manager/
- Nix Flakes: https://nixos.wiki/wiki/Flakes
