# NixOS Configuration Migration Plan

**Date:** 2025-11-21
**System:** shoshin (NixOS Desktop)
**From:** `~/.config/nixos/` (current active config)
**To:** `~/MySpaces/my-modular-workspace/my-nixos-conifg/`
**Workspace:** my-modular-workspace

---

## Overview

This document outlines the migration plan to consolidate NixOS system configuration into the `my-modular-workspace` project structure while maintaining rebuild functionality and creating proper symlinks.

---

## Current State Analysis

### Existing Structure (~/.config/nixos/)

```
~/.config/nixos/
├── flake.nix                    # Entry point (flake-based)
├── flake.lock                   # Lock file
├── configuration.nix            # OLD root config (not used by flake)
├── hardware-configuration.nix   # OLD hardware config
├── hosts/
│   └── shoshin/
│       ├── configuration.nix    # ✅ ACTUAL system config (used by flake)
│       └── hardware-configuration.nix
├── modules/
│   ├── common.nix               # Common system settings
│   ├── common/security.nix
│   ├── development/             # Development tools
│   ├── platform/                # Docker, K8s
│   ├── system/                  # System configs
│   │   ├── audio.nix
│   │   ├── networking.nix       # ✅ NEW static IP module
│   │   └── ...
│   └── workspace/               # Desktop environment
├── home/                        # ⚠️ Home-manager configs (to be migrated)
│   ├── mitso/
│   │   ├── home.nix
│   │   ├── plasma.nix
│   │   ├── vscodium.nix
│   │   └── ...
│   └── common.nix
└── overlays/
```

### Target Structure (~/MySpaces/my-modular-workspace/my-nixos-conifg/)

```
my-modular-workspace/
├── my-nixos-conifg/             # NEW: NixOS system config
│   ├── flake.nix                # Entry point
│   ├── flake.lock
│   ├── hosts/
│   │   └── shoshin/
│   │       ├── configuration.nix
│   │       └── hardware-configuration.nix
│   ├── modules/
│   │   ├── common.nix
│   │   ├── common/
│   │   ├── development/
│   │   ├── platform/
│   │   ├── system/
│   │   │   ├── networking.nix   # Static IP config
│   │   │   └── ...
│   │   └── workspace/
│   └── overlays/
├── home-manager/                # Home-manager configs (separate)
│   └── ... (already exists)
└── docs/
    └── NixOS/
        ├── MIGRATION_PLAN.md    # This file
        └── STATIC_IP_CONFIGURATION.md
```

---

## Migration Goals

1. **Consolidate NixOS config** into my-modular-workspace
2. **Remove home-manager configs** from system config (already in home-manager/)
3. **Create /etc/nixos symlink** → my-modular-workspace for NixOS tools
4. **Maintain rebuild functionality** (test and verify)
5. **Remove Docker** from system configuration
6. **Clean up old configuration.nix** files

---

## Phase 1: Prepare Target Structure

### Step 1.1: Create Base Directory Structure

```bash
cd ~/MySpaces/my-modular-workspace/my-nixos-conifg

# Already have modules/system/networking.nix
# Need to create full structure

mkdir -p {hosts/shoshin,modules/{common,development,platform,system,workspace},overlays}
```

### Step 1.2: Copy Core Files

```bash
# Copy flake configuration
cp ~/.config/nixos/flake.nix my-nixos-conifg/
cp ~/.config/nixos/flake.lock my-nixos-conifg/

# Copy host-specific configs
cp -r ~/.config/nixos/hosts/shoshin/* my-nixos-conifg/hosts/shoshin/

# Copy module directories (excluding home/)
cp -r ~/.config/nixos/modules/common* my-nixos-conifg/modules/
cp -r ~/.config/nixos/modules/development my-nixos-conifg/modules/
cp -r ~/.config/nixos/modules/platform my-nixos-conifg/modules/
cp -r ~/.config/nixos/modules/system my-nixos-conifg/modules/
cp -r ~/.config/nixos/modules/workspace my-nixos-conifg/modules/

# Copy overlays if needed
cp -r ~/.config/nixos/overlays/* my-nixos-conifg/overlays/ 2>/dev/null || true
```

**Note:** Networking module already exists in target, will be preserved.

---

## Phase 2: Remove Docker Configuration

Docker is currently enabled but we want to remove it from the system.

### Step 2.1: Identify Docker-Related Modules

From snapshot analysis:
- `modules/platform/containers.nix` - Contains Docker configuration
- Host configuration imports this module

### Step 2.2: Disable Docker

**Option A: Comment out in host configuration**
```nix
# hosts/shoshin/configuration.nix
imports = [
  # ...
  # ../../modules/platform/containers.nix  # DISABLED: Removing Docker
  ../../modules/platform/kubernetes.nix
];
```

**Option B: Modify containers.nix to disable Docker**
```nix
# modules/platform/containers.nix
{
  # Docker disabled - using K3s containerd only
  # virtualisation.docker.enable = false;

  # Keep K3s if needed
  # services.k3s.enable = true;
}
```

### Step 2.3: Clean Up Docker Data (Post-Migration)

After successful migration and rebuild:
```bash
# Stop Docker service
sudo systemctl stop docker
sudo systemctl disable docker

# Remove Docker data (CAREFUL!)
# sudo rm -rf /var/lib/docker

# Prune iptables rules (if needed)
# sudo iptables -t nat -F
# sudo iptables -t mangle -F
```

---

## Phase 3: Remove Home-Manager from System Config

The `home/` directory in system config conflicts with dedicated home-manager setup.

### Step 3.1: Verify Home-Manager Is Separate

Check that home-manager is managed separately (not as NixOS module):
```bash
# Should show home-manager active
systemctl --user status home-manager-*.service

# Check home-manager location
ls -la ~/MySpaces/my-modular-workspace/home-manager/
```

### Step 3.2: Remove home/ from System Config

In `my-nixos-conifg/hosts/shoshin/configuration.nix`:

**Remove any home-manager imports:**
```nix
{
  imports = [
    # Remove these if present:
    # home-manager.nixosModules.home-manager
    # ../../home/mitso/home.nix
  ];

  # Remove home-manager configuration blocks
  # home-manager.users.mitso = ...;
}
```

**Note:** Home-manager configs in `~/MySpaces/my-modular-workspace/home-manager/` are managed separately via `home-manager switch`.

---

## Phase 4: Update Flake Configuration

### Step 4.1: Review Current flake.nix

Current flake.nix points to:
```nix
nixosConfigurations.shoshin = nixpkgs.lib.nixosSystem {
  modules = [
    ./hosts/shoshin/configuration.nix
  ];
};
```

This is correct! No changes needed.

### Step 4.2: Verify Imports in Host Config

Ensure all module imports use relative paths from `hosts/shoshin/`:
```nix
imports = [
  ./hardware-configuration.nix
  ../../modules/common.nix
  ../../modules/system/networking.nix
  # etc.
];
```

---

## Phase 5: Create Symlinks

### Step 5.1: Backup Current /etc/nixos

```bash
# /etc/nixos is managed by NixOS, but let's be safe
sudo cp -r /etc/nixos /etc/nixos.backup-2025-11-21
```

### Step 5.2: Remove Old /etc/nixos Symlink (if exists)

```bash
# Check what /etc/nixos is
ls -la /etc/nixos

# If it's a symlink to ~/.config/nixos
sudo rm /etc/nixos  # Only if symlink
```

### Step 5.3: Create New Symlink

```bash
# Symlink /etc/nixos → my-modular-workspace config
sudo ln -sf ~/MySpaces/my-modular-workspace/my-nixos-conifg /etc/nixos

# Verify
ls -la /etc/nixos  # Should show symlink
```

**Important:** This allows `nixos-rebuild` to work from anywhere without `--flake` flag.

### Step 5.4: Alternative: Keep ~/.config/nixos and Symlink It

If you want to keep the traditional location:
```bash
# Remove current ~/.config/nixos
rm -rf ~/.config/nixos

# Symlink ~/.config/nixos → my-modular-workspace
ln -sf ~/MySpaces/my-modular-workspace/my-nixos-conifg ~/.config/nixos

# Then symlink /etc/nixos → ~/.config/nixos
sudo ln -sf ~/.config/nixos /etc/nixos
```

---

## Phase 6: Test and Verify

### Step 6.1: Test Build (Dry Run)

```bash
cd ~/MySpaces/my-modular-workspace/my-nixos-conifg

# Test without applying
sudo nixos-rebuild test --flake .#shoshin
```

**Expected:** System should build without errors.

### Step 6.2: Verify Network Configuration

After test rebuild:
```bash
# Check static IP is still 192.168.1.17
ip addr show enp0s31f6 | grep "inet "

# Should show ONLY:
# inet 192.168.1.17/24 scope global enp0s31f6
```

### Step 6.3: Check for Docker Removal

```bash
# Docker should not be active
systemctl status docker
# Should show "Unit docker.service could not be found"

# K3s should still work if you're using it
systemctl status k3s
```

### Step 6.4: Apply Permanently

```bash
cd ~/MySpaces/my-modular-workspace/my-nixos-conifg
sudo nixos-rebuild switch --flake .#shoshin
```

### Step 6.5: Test from Symlink Location

```bash
# Should work from /etc/nixos if symlink created
cd /etc/nixos
sudo nixos-rebuild switch --flake .#shoshin

# Should also work without --flake if /etc/nixos/flake.nix exists
sudo nixos-rebuild switch
```

---

## Phase 7: Cleanup

### Step 7.1: Archive Old Configuration

```bash
# Move old config to archive
mkdir -p ~/Archives/nixos-configs/
mv ~/.config/nixos ~/Archives/nixos-configs/nixos-pre-migration-2025-11-21

# Or if you created symlink, it's already pointing to new location
```

### Step 7.2: Clean Up Docker Data (Optional)

```bash
# After verifying system works without Docker
sudo systemctl stop docker 2>/dev/null || true
sudo rm -rf /var/lib/docker  # CAREFUL! Only if you're sure
```

### Step 7.3: Update Documentation

```bash
# Update README in my-modular-workspace
cd ~/MySpaces/my-modular-workspace

# Document the new structure
# Update docs/NixOS/README.md with new paths
```

---

## Rollback Plan

If something goes wrong:

### Immediate Rollback (Same Boot)

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### Full Rollback (Restore Old Config)

```bash
# Remove symlink
sudo rm /etc/nixos

# Restore backup
sudo cp -r /etc/nixos.backup-2025-11-21 /etc/nixos

# Rebuild from old config
cd ~/.config/nixos  # or wherever old config is
sudo nixos-rebuild switch --flake .#shoshin
```

---

## Verification Checklist

After migration, verify:

- [ ] System boots successfully
- [ ] Static IP is 192.168.1.17 (only, no DHCP)
- [ ] Network connectivity works (ping 1.1.1.1)
- [ ] K3s/Kubernetes still works (if needed)
- [ ] Docker is removed/disabled
- [ ] Home-manager works independently
- [ ] Can rebuild from /etc/nixos symlink
- [ ] Can rebuild from my-modular-workspace directly
- [ ] All desktop environment features work

---

## Timeline Estimate

**Total Time:** 2-3 hours

| Phase | Task | Time |
|-------|------|------|
| 1 | Prepare structure & copy files | 30 min |
| 2 | Remove Docker configuration | 15 min |
| 3 | Remove home-manager from system | 15 min |
| 4 | Update flake configuration | 15 min |
| 5 | Create symlinks | 15 min |
| 6 | Test and verify | 45 min |
| 7 | Cleanup | 15 min |

**Best Time:** Saturday afternoon (focused work time)

---

## Notes

### Why Migrate?

1. **Centralization:** All workspace configs in one place (my-modular-workspace)
2. **Separation:** System config vs user config (home-manager) clearly separated
3. **Organization:** Follows NixOS best practices for modular configuration
4. **Syncthing:** My-modular-workspace is synced, configs backed up automatically

### Why Remove Docker?

1. **K3s Conflict:** K3s uses containerd, Docker adds complexity
2. **Resource Usage:** Docker daemon unnecessary overhead
3. **Simplification:** One container runtime is enough

### Why Symlinks?

1. **NixOS Tools:** `nixos-rebuild` expects config at /etc/nixos
2. **Convenience:** Can rebuild from anywhere
3. **Compatibility:** Existing workflows continue working

---

**Created:** 2025-11-21
**Status:** ✅ COMPLETED
**Completed:** 2025-11-22 (Part 1) + 2025-11-22 (Part 2)

---

## ✅ Migration Status: COMPLETED

### Part 1 (2025-11-22 Session 1)
- ✅ Phase 1: Structure created in `nixos/` directory
- ✅ Phase 2: Docker disabled in containers.nix
- ✅ Phase 3: Home-manager separation (already separate)
- ✅ Phase 4: Flake configuration verified

### Part 2 (2025-11-22 Session 2)
- ✅ Phase 5: Symlink created `/etc/nixos` → `~/MySpaces/my-modular-workspace/nixos/`
- ✅ Phase 6: Testing completed - all systems operational
- ✅ Phase 7: Cleanup completed - old configs archived
- ✅ K3s database reset - now using IP 192.168.1.17
- ✅ Podman removed from home-manager

### Final State
- **NixOS Config:** `~/MySpaces/my-modular-workspace/nixos/`
- **Symlink:** `/etc/nixos` → workspace nixos/
- **Rebuild:** Works from anywhere (`sudo nixos-rebuild switch`)
- **Static IP:** 192.168.1.17 (no DHCP)
- **K3s:** Running with new IP
- **Docker:** Completely removed
- **Podman:** Removed from home-manager
- **Old Configs:** Archived in llm-artifacts/archives/nixos-configs/

---
