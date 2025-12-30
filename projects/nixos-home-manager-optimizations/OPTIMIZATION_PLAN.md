# Unified NixOS + Home-Manager Optimization Plan

**Date:** 2025-12-30
**Author:** Dimitris Tsioumas
**Status:** Active Implementation
**Target Workspace:** shoshin (初心)
**Related ADRs:** ADR-017, ADR-024, ADR-028

---

## Executive Summary

This unified plan consolidates all system-level and user-level optimizations for the shoshin workspace. The approach is:
1. **Hardware Profile Driven** - All optimizations derive from `shoshin.nix` hardware profile
2. **Decoupled Layers** - NixOS and home-manager optimizations are independent but complementary
3. **Foundation First** - System libraries optimized before applications
4. **Maximum GPU Leverage** - All Electron apps use full GPU acceleration

### Target Hardware (shoshin)

| Component | Specification | Optimization Flags |
|-----------|---------------|-------------------|
| **CPU** | Intel i7-6700K Skylake | `-march=skylake -mtune=skylake -O3` |
| **GPU** | NVIDIA GTX 960 Maxwell | CUDA 5.2, VA-API (nvidia-vaapi-driver), VDPAU |
| **Memory** | 16GB DDR4 + 12GB zram | 28GB effective, tier-based limits |
| **Storage** | 500GB NVMe | `io_uring`, `none` scheduler |

---

## Pre-Implementation: Required Reading

**CRITICAL:** Before implementing any phase, read the relevant research documents:

### Research Documents Index

| Document | Topic | Location |
|----------|-------|----------|
| **Bootstrap Research** | Why glibc/zlib can't be in HM | `docs/researches/2025-12-30_NIXOS_SYSTEM_LIBS_OVERLAY_BOOTSTRAP_RESEARCH.md` |
| **System Libs Expansion** | Additional safe libraries | `docs/researches/2025-12-30_EXPANDED_SYSTEM_LIBS_AND_NIXOS_OPTIMIZATIONS.md` |
| **Electron Apps** | GPU flags, V8 limits, systemd | `docs/researches/2025-12-30_ELECTRON_APPS_OPTIMIZATION_RESEARCH.md` |
| **Plasma Desktop** | KWin, Baloo, Plasmashell | `docs/researches/2025-12-30_PLASMA_DESKTOP_OPTIMIZATION_RESEARCH.md` |
| **VA-API/VDPAU** | GPU video acceleration | `docs/researches/2025-12-30_VAAPI_VDPAU_GPU_ACCELERATION_RESEARCH.md` |

### ADRs Index

| ADR | Topic | Status |
|-----|-------|--------|
| **ADR-017** | Hardware-Aware Build Optimizations | ✅ Implemented |
| **ADR-024** | Language Runtime Hardware Optimizations | ✅ Implemented |
| **ADR-028** | Comprehensive Runtime and Build Optimizations | ✅ Implemented |

---

## Phase 1: System Libraries (Foundation Layer)

### Overview

System libraries form the foundation that ALL other software depends on. This phase optimizes them at **both** levels:
- **NixOS Level** - Bootstrap-critical packages (glibc, zlib)
- **Home-Manager Level** - Post-bootstrap packages (compression, crypto, database, network)

### 1.1 NixOS System Libraries (Bootstrap-Critical)

**Location:** `hosts/shoshin/nixos/modules/system/overlays/system-libs-nixos-optimized.nix`

**Packages:**
| Package | Impact | Expected Gain | Risk |
|---------|--------|---------------|------|
| **glibc** | ALL binaries | 3-8% universal | HIGH |
| **zlib** | git, nix, compression | 10-20% | MEDIUM |

**Implementation:**

```nix
# hosts/shoshin/nixos/modules/system/overlays/system-libs-nixos-optimized.nix
{ config, lib, pkgs, ... }:

let
  # Import hardware profile for CPU-specific flags
  hardwareProfile = import ../../../profiles/hardware/shoshin.nix;
  compiler = hardwareProfile.build.compiler;

  cflags = [
    "-march=${compiler.march}"      # skylake
    "-mtune=${compiler.mtune}"      # skylake
    "-O${toString compiler.optimizationLevel}"  # O3
    "-pipe"
    "-fno-semantic-interposition"
    "-fno-plt"
  ];

  cflagsStr = builtins.concatStringsSep " " cflags;
in
{
  nixpkgs.overlays = [
    (final: prev: {
      # glibc - BOOTSTRAP-CRITICAL
      # DO NOT add nativeBuildInputs (breaks bootstrap)
      glibc = prev.glibc.overrideAttrs (old: {
        env = (old.env or {}) // {
          NIX_CFLAGS_COMPILE = cflagsStr;
        };
      });

      # zlib - BOOTSTRAP-CRITICAL
      zlib = prev.zlib.overrideAttrs (old: {
        env = (old.env or {}) // {
          NIX_CFLAGS_COMPILE = cflagsStr;
        };
      });
    })
  ];
}
```

**Rollback Strategy:**
```bash
# Before switch
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Apply
sudo nixos-rebuild switch --flake /etc/nixos#shoshin

# If issues: immediate rollback
sudo nixos-rebuild switch --rollback

# Or: boot previous generation from GRUB
```

### 1.2 Home-Manager System Libraries (Post-Bootstrap)

**Location:** `home-manager/modules/system/overlays/system-libs-hardware-optimized.nix`

**Status:** ✅ Already implemented and working

**Packages (Bootstrap-Safe):**
| Category | Packages | Expected Gain |
|----------|----------|---------------|
| **Compression** | zstd, bzip2, xz, lz4, snappy | 15-30% |
| **Cryptography** | openssl (AES-NI), libgcrypt, libsodium | 20-40% |
| **Database** | sqlite (FTS5, RTREE) | 15-25% |
| **Network** | curl, nghttp2 | 10-15% |
| **Text** | pcre2 (JIT) | 15-25% |

**Key Pattern (Bootstrap-Safe):**
```nix
# Uses NIX_LDFLAGS instead of nativeBuildInputs
mkOptimized = pkg: extraFlags:
  pkg.overrideAttrs (old: {
    env = (old.env or {}) // {
      NIX_CFLAGS_COMPILE = toString (cflags ++ (extraFlags.cflags or []));
    } // (if extraFlags.useMold or false then {
      NIX_LDFLAGS = "-fuse-ld=mold";
    } else {});
    # NO nativeBuildInputs - this breaks bootstrap!
  });
```

### 1.3 Hardware Profile Decoupling

Both NixOS and home-manager overlays read from the **same hardware profile**:

```
┌─────────────────────────────────────────────────────────────┐
│           Hardware Profile: shoshin.nix                     │
│  cpu.family = "skylake"                                     │
│  build.compiler.march = "skylake"                           │
│  build.compiler.mtune = "skylake"                           │
│  build.compiler.optimizationLevel = "3"                     │
└─────────────────────────────────────────────────────────────┘
              │                           │
              ▼                           ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│ NixOS Overlay           │   │ Home-Manager Overlay    │
│ - glibc                 │   │ - zstd, bzip2, xz       │
│ - zlib                  │   │ - openssl, libgcrypt    │
│ (bootstrap-critical)    │   │ - sqlite, curl, pcre2   │
└─────────────────────────┘   └─────────────────────────┘
```

**This ensures:**
- Same `-march=skylake -O3` flags across all layers
- Future hardware changes only require updating one file
- Other workspaces (kinoite, gyakusatsu) can have different profiles

---

## Phase 2: Language Runtimes

**Status:** ✅ Already implemented in home-manager

**Location:** `home-manager/modules/system/overlays/`

| Runtime | Overlay File | Key Optimizations | Expected Gain |
|---------|--------------|-------------------|---------------|
| **Node.js 24** | `nodejs-hardware-optimized.nix` | PGO + jemalloc + hardware flags | 10-25% CPU, 10-30% RAM |
| **Python 3.13** | `python-hardware-optimized.nix` | PGO + custom stdenv | 10-30% |
| **Rust (rustc)** | `rust-hardware-optimized.nix` | PGO + jemalloc + Thin LTO | 10-15% rustc, 8-15% binaries |
| **Go 1.24** | `go-hardware-optimized.nix` | GOAMD64=v3 (AVX2) | 3-10% |

---

## Phase 3: Electron Applications (Maximum GPU Leverage)

### GPU Acceleration Strategy

**CRITICAL REQUIREMENT:** All Electron apps MUST leverage GPU to maximum extent.

**GPU Flags for NVIDIA GTX 960 + X11:**
```bash
--use-gl=desktop
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
--enable-hardware-overlays
```

### App-Specific Configuration

**Location:** `home-manager/modules/apps/electron-optimized/`

| App | V8 Heap | MemoryHigh | MemoryMax | CPUQuota | GPU Priority |
|-----|---------|------------|-----------|----------|--------------|
| **Teams** | 1536MB | 2.5G | 4G | 200% | Video calls |
| **Discord** | 1024MB | 2G | 3G | 150% | Streaming |
| **Spotify** | 512MB | 2G | 3G | 100% | Media playback |
| **VSCodium** | 2048MB | 4G | 5G | 200% | Editor GPU |
| **Claude Desktop** | 2048MB | 4G | 6G | 200% | AI context |
| **Signal** | 768MB | 1.5G | 2G | 100% | Messaging |
| **Zoom** | 1024MB | 2.5G | 4G | 250% | Video calls |

### Implementation Template

```nix
# home-manager/modules/apps/electron-optimized/default.nix

{ pkgs, lib, config, ... }:

let
  # Maximum GPU flags for NVIDIA GTX 960 + X11
  gpuFlags = [
    "--use-gl=desktop"
    "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--ignore-gpu-blocklist"
    "--ozone-platform=x11"
    "--enable-hardware-overlays"
    "--enable-native-gpu-memory-buffers"
  ];

  # Systemd-wrapped Electron app with full GPU + memory limits
  mkElectronApp = {
    pkg,
    name,
    maxHeap,        # V8 heap in MB
    memoryHigh,     # Systemd soft limit
    memoryMax,      # Systemd hard limit
    cpuQuota,       # CPU percentage (100% = 1 core)
    extraFlags ? []
  }: pkgs.writeShellScriptBin name ''
    exec ${pkgs.systemd}/bin/systemd-run --user --scope \
      --unit="app-${name}-$$" \
      --description="${name} (GPU Optimized)" \
      -p OOMScoreAdjust=-100 \
      -p MemoryHigh=${memoryHigh} \
      -p MemoryMax=${memoryMax} \
      -p CPUQuota=${cpuQuota} \
      ${pkg}/bin/${name} \
      ${builtins.concatStringsSep " " gpuFlags} \
      --js-flags='--max-old-space-size=${toString maxHeap}' \
      ${builtins.concatStringsSep " " extraFlags} \
      "$@"
  '';
in
{
  home.packages = [
    (mkElectronApp {
      pkg = pkgs.discord;
      name = "discord";
      maxHeap = 1024;
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "150%";
    })
    # ... more apps
  ];
}
```

---

## Phase 4: Plasma Desktop Optimization

### KWin Compositor

**Location:** Managed via chezmoi (`dot_config/kwinrc`)

**Recommended Settings for GTX 960:**
```ini
[Compositing]
Backend=OpenGL
GLCore=true
GLPreferBufferSwap=a
GLTextureFilter=1
WindowsBlockCompositing=true
AnimationDurationFactor=0.5

[Plugins]
blurEnabled=true
contrastEnabled=false
wobblywindowsEnabled=false
magiclampEnabled=false
```

**Environment Variables:**
```nix
home.sessionVariables = {
  KWIN_OPENGL_INTERFACE = "egl";
  __GL_YIELD = "USLEEP";
  __GL_MaxFramesAllowed = "1";
};
```

### Baloo File Indexer

**Configuration:**
```ini
[General]
only basic indexing=true
index hidden folders=false
exclude folders[$e]=$HOME/.cache,$HOME/.local/share/Trash,$HOME/.nix-profile,$HOME/.nix-defexpr,/nix/store,$HOME/node_modules,$HOME/.cargo,$HOME/.rustup
```

### Expected Savings

| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| KWin | 150-300MB | 100-200MB | 30-40% |
| Plasmashell | 200-400MB | 150-300MB | 25-35% |
| Baloo | 50-200MB | 30-100MB | 40-50% |

---

## Phase 5: GPU Video Acceleration

### VA-API Configuration (nvidia-vaapi-driver)

**NixOS Configuration:**
```nix
# hosts/shoshin/nixos/modules/system/nvidia.nix

hardware.graphics = {
  enable = true;
  enable32Bit = true;
  extraPackages = with pkgs; [
    nvidia-vaapi-driver  # VA-API via NVDEC
    vaapiVdpau           # VDPAU backend
    libvdpau-va-gl       # VA-API via VDPAU
  ];
};

environment.variables = {
  LIBVA_DRIVER_NAME = "nvidia";
  NVD_BACKEND = "direct";  # CRITICAL: EGL broken on driver 525+
  VDPAU_DRIVER = "nvidia";
  MOZ_DISABLE_RDD_SANDBOX = "1";
};

boot.kernelParams = [
  "nvidia-drm.modeset=1"  # REQUIRED for nvidia-vaapi-driver
];
```

### GTX 960 Codec Support

| Codec | Hardware Decode | Notes |
|-------|-----------------|-------|
| H.264 | ✅ Full | Native NVDEC |
| HEVC (H.265) | ✅ Full | Main & Main 10 |
| VP9 | ✅ Full | Native NVDEC |
| VP8 | ✅ Full | Native NVDEC |
| **AV1** | ❌ None | Ampere+ only |

---

## Implementation Order

```
Week 1: Foundation
├── Day 1-2: NixOS glibc/zlib overlay (staged rollout)
├── Day 3-4: Verify system stability
└── Day 5: Home-manager system libs verification

Week 2: Applications
├── Day 1-3: Electron apps with GPU wrappers
└── Day 4-5: Native apps systemd limits

Week 3: Desktop
├── Day 1-2: KWin/Plasma configuration
├── Day 3-4: VA-API/VDPAU verification
└── Day 5: Full system testing
```

---

## Validation Checklist

### Pre-Implementation
- [ ] Read all research documents listed above
- [ ] Verify current system baseline (`free -h`, `nvidia-smi`)
- [ ] Ensure NixOS live USB available for emergency

### Post Phase 1 (System Libs)
- [ ] System boots correctly
- [ ] Basic commands work (ls, cat, grep, git)
- [ ] `nix-build` operations succeed
- [ ] No segfaults in `journalctl -xb`

### Post Phase 3 (Electron Apps)
- [ ] All apps launch with GPU acceleration
- [ ] Verify GPU usage: `nvidia-smi pmon`
- [ ] Systemd limits applied: `systemctl --user status app-*`

### Post Phase 5 (GPU Acceleration)
- [ ] `vainfo` shows nvidia driver
- [ ] `vdpauinfo` shows supported codecs
- [ ] Firefox `about:support` shows "Hardware Video Decoding: available"
- [ ] YouTube 1080p plays with <20% CPU

---

## Rollback Procedures

### NixOS Rollback
```bash
# Immediate rollback
sudo nixos-rebuild switch --rollback

# Boot previous generation
# Select in GRUB at boot

# Emergency: Live USB
# Mount, chroot, rebuild
```

### Home-Manager Rollback
```bash
# List generations
home-manager generations

# Switch to previous
home-manager switch --flake .#mitsio@shoshin --recreate-lock-file

# Or manually restore
rm -rf ~/.config/home-manager
home-manager switch
```

---

## Related Documentation

- **Project README:** `docs/projects/nixos-home-manager-optimizations/README.md`
- **ADR-028:** `docs/adrs/ADR-028-COMPREHENSIVE_RUNTIME_AND_BUILD_OPTIMIZATIONS.md`
- **Hardware Profile:** `home-manager/modules/profiles/config/hardware/shoshin.nix`

---

## Engineering Reviews

### Ops Engineer Review

**Reviewer Role:** Site Reliability / Platform Engineer
**Review Date:** 2025-12-30

#### ✅ Strengths

1. **Rollback procedures are solid** - Both NixOS generations and home-manager generations provide recovery paths
2. **Staged implementation** - Week-by-week approach with validation between phases
3. **Tier-based resource limits** - Memory limits are appropriate for the hardware
4. **Hardware profile decoupling** - Single source of truth for optimization flags

#### ⚠️ Concerns Identified

| Issue | Severity | Status | Resolution |
|-------|----------|--------|------------|
| **Mold linker in PATH** | Medium | Needs Verification | Verify mold is available in NixOS build environment |
| **Combined memory limits** | Low | Acceptable | Apps don't run simultaneously; documented in plan |
| **NixOS flake structure** | Medium | Needs Verification | Verify shoshin-nixos uses flake pattern |
| **Missing continuous monitoring** | Low | Added Below | Added monitoring section |

#### Recommended Monitoring

```bash
# Add to ~/.bashrc or alias
alias sysmon='watch -n 2 "free -h && echo && nvidia-smi --query-gpu=memory.used,utilization.gpu --format=csv && echo && ps aux --sort=-%mem | head -10"'

# Systemd resource usage for Electron apps
alias appmon='systemctl --user list-units "app-*" --no-pager'

# Journal monitoring for segfaults
alias crashmon='journalctl -xb -p err --no-pager | tail -20'
```

#### Pre-Implementation Checklist (Ops)

- [ ] Verify `mold` is in PATH: `which mold`
- [ ] Check NixOS flake exists: `ls /etc/nixos/flake.nix`
- [ ] Backup current NixOS generation: `nixos-rebuild build`
- [ ] Record baseline: `free -h > ~/baseline.txt && nvidia-smi >> ~/baseline.txt`
- [ ] Verify GRUB timeout allows generation selection

---

### Developer Engineer Review

**Reviewer Role:** Developer / Code Quality
**Review Date:** 2025-12-30

#### ✅ Strengths

1. **Code patterns are correct** - Uses `overrideAttrs` with proper `env` attribute handling
2. **Bootstrap-safe approach** - Avoids `nativeBuildInputs` in system libs overlays
3. **Template-based app generation** - DRY pattern for Electron wrappers
4. **Hardware profile reuse** - Avoids hardcoding march/mtune

#### ⚠️ Technical Issues Identified

| Issue | Severity | Status | Resolution |
|-------|----------|--------|------------|
| **Hardware profile path in NixOS** | High | ⚠️ Needs Fix | Path `../../../profiles/hardware/shoshin.nix` is wrong |
| **Electron binary names vary** | Medium | ⚠️ Needs Fix | Some apps have different binary names |
| **Missing lz4/snappy in overlay** | Low | To Implement | Not yet in system-libs-hardware-optimized.nix |
| **Shell PID in unit name** | Low | Acceptable | `$$` works correctly in bash |

#### Code Fixes Required

**1. NixOS Overlay Hardware Profile Path**

The sample code has incorrect path. Correct approach:

```nix
# Option A: Pass hardware profile via specialArgs in NixOS flake
{ config, lib, pkgs, hardwareProfile, ... }:

# Option B: Import from home-manager location (if symlinked)
let
  hardwareProfile = import /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager/modules/profiles/config/hardware/shoshin.nix;
in
```

**2. Electron Binary Name Handling**

```nix
mkElectronApp = {
  pkg,
  name,
  binaryName ? name,  # Allow override for apps with different binary names
  ...
}: pkgs.writeShellScriptBin name ''
  exec ... ${pkg}/bin/${binaryName} ...
'';

# Usage for signal-desktop (binary is 'signal-desktop' not just 'signal')
(mkElectronApp {
  pkg = pkgs.signal-desktop;
  name = "signal";
  binaryName = "signal-desktop";
  ...
})
```

**3. Add Missing Libraries to Overlay**

```nix
# Add to system-libs-hardware-optimized.nix

# COMPRESSION (Tier 2 - Not yet implemented)
lz4 = mkOptimized prev.lz4 { useMold = true; };
snappy = mkOptimized prev.snappy { useMold = true; };

# ASYNC I/O (Tier 2 - Not yet implemented)
libevent = mkOptimized prev.libevent { useMold = true; };
libuv = mkOptimized prev.libuv { useMold = true; };
```

#### Testing Recommendations

```bash
# Test overlay evaluation (before building)
nix eval --json .#homeConfigurations.mitsio@shoshin.config.home.packages | jq 'length'

# Test single package build
nix build .#homeConfigurations.mitsio@shoshin.config.home.packages.zstd

# Verify compiler flags in build log
nix log /nix/store/...-zstd-*.drv | grep march
```

---

## Issues Requiring Research

The following issues were identified during review and may require additional research:

| Issue | Research Status | Action |
|-------|-----------------|--------|
| NixOS overlay hardware profile path strategy | 🔍 To Research | Verify best pattern for cross-repo imports |
| Mold linker availability in bootstrap | ✅ Documented | NIX_LDFLAGS approach is correct |
| Electron app binary name mapping | 📝 Manual Check | Verify each app's binary name |

---

**Document Version:** 1.1.0
**Last Updated:** 2025-12-30T06:15:00+02:00
**Reviews:** Ops Engineer ✅, Developer Engineer ✅
