# NixOS System-Level Optimization Plan

**Date:** 2025-12-30
**Author:** Dimitris Tsioumas
**Status:** Planned (Document Only)
**Related ADRs:** ADR-017, ADR-024, ADR-028
**Related Research:** `docs/researches/2025-12-30_NIXOS_SYSTEM_LIBS_OVERLAY_BOOTSTRAP_RESEARCH.md`

---

## Executive Summary

This document outlines the plan for implementing system-level optimizations in NixOS that **cannot** be done in home-manager due to bootstrap constraints. These optimizations target bootstrap-critical packages (glibc, zlib) that require NixOS-level configuration.

### Key Insight

From research, home-manager overlays cannot override bootstrap-critical packages because:
- They use a minimal `boot.nix` version of `fetchurl`
- `boot.nix` doesn't accept `nativeBuildInputs`, `meta`, etc.
- This causes the error: `function 'anonymous lambda' called with unexpected argument 'nativeBuildInputs'`

**Solution:** Move glibc/zlib optimization to `/etc/nixos/` level (shoshin-nixos repo).

---

## Scope

### Packages to Optimize at NixOS Level

| Package | Current Status | Expected Gain | Risk Level |
|---------|---------------|---------------|------------|
| **glibc** | Not optimized | 3-8% universal | **HIGH** |
| **zlib** | Not optimized | 10-20% compression | **MEDIUM** |

### Why These Packages?

- **glibc**: Affects ALL binaries on the system. Any performance improvement here cascades universally.
- **zlib**: Used by git, nix itself, many compression tools. High-impact for SRE workflows.

### Out of Scope (Already in home-manager)

These packages are **already optimized** in `system-libs-hardware-optimized.nix`:
- zstd, bzip2, xz (compression)
- openssl, libgcrypt, libsodium (crypto)
- sqlite, curl, pcre2 (database/network/text)

---

## Implementation Plan

### Phase 1: Create NixOS Overlay

**Location:** `hosts/shoshin/nixos/modules/system/overlays/system-libs-nixos-optimized.nix`

```nix
# NixOS System Libraries Optimization (Bootstrap-Critical)
# =========================================================
# CAUTION: These packages are bootstrap-critical.
# Any issues here can break the entire system.
# Always test on a backup generation first.
#
# Related: ADR-028, docs/projects/nixos-optimizations/
# =========================================================

{ config, lib, pkgs, ... }:

let
  # Skylake-specific flags (shoshin hardware profile)
  cflags = [
    "-march=skylake"
    "-mtune=skylake"
    "-O3"
    "-pipe"
    "-fno-semantic-interposition"
    "-fno-plt"
  ];

  cflagsStr = builtins.concatStringsSep " " cflags;
in
{
  nixpkgs.overlays = [
    (final: prev: {
      # =============================================
      # glibc - Universal C Library (3-8% gain)
      # =============================================
      # CAUTION: Affects ALL binaries
      # DO NOT add nativeBuildInputs (breaks bootstrap)
      # =============================================
      glibc = prev.glibc.overrideAttrs (old: {
        env = (old.env or {}) // {
          NIX_CFLAGS_COMPILE = cflagsStr;
        };
        # NOTE: Cannot use mold linker here - bootstrap constraint
      });

      # =============================================
      # zlib - Compression Library (10-20% gain)
      # =============================================
      # Used by: git, nix, gzip, many tools
      # =============================================
      zlib = prev.zlib.overrideAttrs (old: {
        env = (old.env or {}) // {
          NIX_CFLAGS_COMPILE = cflagsStr;
        };
        # NOTE: Cannot use mold linker here - bootstrap constraint
      });
    })
  ];
}
```

### Phase 2: Integration with NixOS Configuration

**Location:** `hosts/shoshin/nixos/configuration.nix` (or imports)

```nix
{ config, pkgs, ... }:
{
  imports = [
    # Other modules...
    ./modules/system/overlays/system-libs-nixos-optimized.nix
  ];

  # ... rest of configuration
}
```

### Phase 3: Testing Strategy (Staged Rollout)

#### Pre-Implementation Checklist

```bash
# 1. Record current system performance baseline
free -h > ~/baseline_memory.txt
ps aux --sort=-%cpu | head -20 > ~/baseline_cpu.txt

# 2. Verify current generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# 3. Create a backup boot entry (automatic with nixos-rebuild)
# Current generation will be available in GRUB if needed
```

#### Staged Rollout Steps

```bash
# Step 1: Build without switching (validate compilation)
cd /etc/nixos
sudo nixos-rebuild build --flake .#shoshin

# Step 2: If build succeeds, switch with rollback ready
sudo nixos-rebuild switch --flake .#shoshin

# Step 3: Validate system stability
# - System boots correctly
# - Basic commands work (ls, cat, grep, git)
# - Nix operations work (nix-build, nix-shell)
# - Desktop environment loads

# Step 4: If issues occur, rollback immediately
sudo nixos-rebuild switch --rollback

# Alternative: Boot into previous generation from GRUB
```

#### Validation Commands

```bash
# Verify glibc is using optimized version
ldd /bin/ls
# Should show /nix/store/<hash>-glibc-2.XX/lib/libc.so.6

# Check zlib
nix-store --query --requisites $(which git) | grep zlib

# Performance smoke test
time nix-build '<nixpkgs>' -A hello --check

# Memory comparison
free -h > ~/after_memory.txt
diff ~/baseline_memory.txt ~/after_memory.txt
```

---

## Risk Assessment

### High Risk Factors

| Risk | Impact | Mitigation |
|------|--------|------------|
| System won't boot | Critical | Always have previous generation in GRUB |
| glibc binary incompatibility | Critical | Test basic commands immediately after switch |
| Nix store corruption | Critical | `nix-store --verify --repair` available |
| Subtle memory issues | Medium | Monitor with `journalctl -xb` for segfaults |

### Rollback Plan

1. **Immediate (within session):** `sudo nixos-rebuild switch --rollback`
2. **From boot:** Select previous generation in GRUB
3. **Emergency:** Boot from NixOS live USB, chroot, rebuild

### Recommended Safety Measures

1. **Test on VM first** (if available)
2. **Keep live USB ready**
3. **Document current generation number**
4. **Schedule during low-priority time**
5. **Have phone/secondary device for documentation access**

---

## Expected Performance Impact

### glibc Optimization

| Operation | Expected Improvement |
|-----------|---------------------|
| String operations (strcpy, strlen) | 5-10% |
| Memory allocation (malloc/free) | 3-8% |
| Math operations (sin, cos, exp) | 5-15% |
| System calls overhead | 2-5% |
| **Overall system responsiveness** | **3-8%** |

### zlib Optimization

| Operation | Expected Improvement |
|-----------|---------------------|
| gzip compression | 15-25% |
| git operations (pack/unpack) | 10-20% |
| Nix store compression | 10-20% |
| HTTP content encoding | 10-15% |
| **Overall compression workflows** | **10-20%** |

### Synergy with Home-Manager Overlays

When combined with existing home-manager optimizations:

- **Crypto (openssl):** 20-40% (AES-NI) - already in HM
- **Compression (zstd):** 15-30% - already in HM
- **Universal (glibc):** 3-8% - NEW with NixOS overlay
- **Total expected gain:** 30-50% for typical workflows

---

## Timeline

### Current Status: Document Only

Per user request (QnA Round 5), this optimization is **documented only** for now. Implementation will be scheduled separately.

### Recommended Implementation Order

1. ✅ Document plan (this document)
2. ⏸️ Create NixOS overlay file (when ready)
3. ⏸️ Test on VM or backup system (optional but recommended)
4. ⏸️ Staged rollout on shoshin
5. ⏸️ Performance validation
6. ⏸️ Update ADR-028 with results

### Prerequisites Before Implementation

- [ ] Ensure all home-manager optimizations are stable
- [ ] Have NixOS live USB ready
- [ ] Schedule 30-60 minute maintenance window
- [ ] Backup any critical work

---

## Related Documentation

### Research Documents

- `docs/researches/2025-12-30_NIXOS_SYSTEM_LIBS_OVERLAY_BOOTSTRAP_RESEARCH.md` - Bootstrap constraints research
- `docs/researches/2025-12-30_ELECTRON_APPS_OPTIMIZATION_RESEARCH.md` - Electron optimization
- `docs/researches/2025-12-30_PLASMA_DESKTOP_OPTIMIZATION_RESEARCH.md` - Plasma optimization
- `docs/researches/2025-12-30_VAAPI_VDPAU_GPU_ACCELERATION_RESEARCH.md` - GPU acceleration

### ADRs

- `ADR-017` - Hardware-Aware Build Optimizations (framework)
- `ADR-024` - Language Runtime Hardware Optimizations
- `ADR-028` - Comprehensive Runtime and Build Optimizations

### Home-Manager Overlays (Already Implemented)

- `home-manager/modules/system/overlays/system-libs-hardware-optimized.nix`
- `home-manager/modules/system/overlays/nodejs-hardware-optimized.nix`
- `home-manager/modules/system/overlays/python-hardware-optimized.nix`
- `home-manager/modules/system/overlays/rust-hardware-optimized.nix`
- `home-manager/modules/system/overlays/go-hardware-optimized.nix`

---

## Appendix: Quick Reference

### Bootstrap-Critical Packages (Never Override in HM)

- ❌ glibc
- ❌ zlib
- ❌ gcc/binutils
- ❌ bash
- ❌ coreutils
- ❌ fetchurl

### Safe for Home-Manager Overlay

- ✅ zstd, bzip2, xz
- ✅ openssl, libgcrypt, libsodium
- ✅ sqlite, curl, pcre2
- ✅ lz4, snappy, libevent
- ✅ Node.js, Python, Rust, Go runtimes

### Compiler Flags Reference

```nix
cflags = [
  "-march=skylake"              # Target CPU architecture
  "-mtune=skylake"              # Optimize for CPU scheduling
  "-O3"                         # Maximum optimization
  "-pipe"                       # Use pipes (faster builds)
  "-fno-semantic-interposition" # Better DSO optimization
  "-fno-plt"                    # Direct function calls
];
```

---

**Document Status:** Complete (Planning Only)
**Implementation Status:** Pending (User to schedule)
**Last Updated:** 2025-12-30T05:50:00+02:00
