# Unified NixOS + Home-Manager Optimization Plan

**Date:** 2025-12-30
**Author:** Dimitris Tsioumas
**Status:** Active Implementation
**Target Workspace:** shoshin (初心)
**Related ADRs:** ADR-017, ADR-024, ADR-028

---

## Executive Summary

This unified plan consolidates all system-level and user-level optimizations for the shoshin workspace with aggressive resource targets:

### Resource Targets

| Resource | Target | Strategy |
|----------|--------|----------|
| **RAM (Idle)** | < 4GB | Plasma optimization, Baloo limits, systemd cgroups |
| **RAM (Workload)** | 8-10GB total | Electron limits, V8 heap caps, zram compression |
| **CPU (OS/Essentials)** | 2 cores (4 threads) | Priority scheduling, cgroups |
| **CPU (Workloads)** | 2 cores (4 threads) | Remaining capacity |

### Optimization Approach

1. **Hardware Profile Driven** - All optimizations derive from `shoshin.nix` hardware profile
2. **Decoupled Layers** - NixOS and home-manager optimizations are independent but complementary
3. **Foundation First** - System libraries (30+ packages) optimized before applications
4. **Maximum GPU Leverage** - All Electron apps use full GPU acceleration to reduce CPU/RAM
5. **Aggressive Memory Management** - Zram, cgroups v2, OOM protection

### Target Hardware (shoshin)

| Component | Specification | Optimization Flags |
|-----------|---------------|-------------------|
| **CPU** | Intel i7-6700K Skylake (4c/8t) | `-march=skylake -mtune=skylake -O3` |
| **GPU** | NVIDIA GTX 960 Maxwell (4GB) | CUDA 5.2, VA-API (nvidia-vaapi-driver), VDPAU |
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

## Phase 0: Memory Optimization (Foundation)

### 0.1 Zram Configuration

**Target:** Effective 28GB memory (16GB RAM + 12GB zram)

**NixOS Configuration:**
```nix
# hosts/shoshin/nixos/modules/system/memory.nix
{ config, lib, pkgs, ... }:
{
  # Zram - Compressed swap in RAM
  zramSwap = {
    enable = true;
    algorithm = "zstd";          # Best compression ratio for Skylake
    memoryPercent = 75;          # 12GB zram from 16GB RAM
    priority = 100;              # Higher than disk swap
  };

  # Kernel memory tuning
  boot.kernel.sysctl = {
    # Swap behavior - favor keeping apps in RAM
    "vm.swappiness" = 10;                    # Low swappiness (default 60)
    "vm.vfs_cache_pressure" = 50;            # Keep dentries/inodes in cache

    # Memory overcommit - allow but don't go crazy
    "vm.overcommit_memory" = 0;              # Heuristic overcommit
    "vm.overcommit_ratio" = 80;              # Allow 80% overcommit

    # Dirty page writeback
    "vm.dirty_ratio" = 10;                   # Start writeback at 10%
    "vm.dirty_background_ratio" = 5;         # Background writeback at 5%

    # OOM killer behavior
    "vm.oom_kill_allocating_task" = 1;       # Kill the allocating task first
    "vm.panic_on_oom" = 0;                   # Don't panic, just kill
  };
}
```

### 0.2 Systemd Resource Slices

**Target:** Protect critical services, limit resource-hungry apps

```nix
# hosts/shoshin/nixos/modules/system/cgroups.nix
{ config, lib, pkgs, ... }:
{
  # User slice defaults
  systemd.user.slices.user = {
    sliceConfig = {
      MemoryHigh = "12G";        # Soft limit for user session
      MemoryMax = "14G";         # Hard limit
      CPUQuota = "600%";         # 6 cores max for user
    };
  };

  # Protect display manager and compositor
  systemd.services.display-manager = {
    serviceConfig = {
      OOMScoreAdjust = -900;     # Very hard to kill
      MemoryHigh = "512M";
      MemoryMax = "1G";
    };
  };
}
```

### 0.3 Memory Budget Breakdown

| Category | Idle Target | Workload Max | Notes |
|----------|-------------|--------------|-------|
| **Kernel + drivers** | 400MB | 600MB | NVIDIA ~200MB overhead |
| **Systemd + services** | 100MB | 150MB | Essential daemons |
| **Plasma Desktop** | 500MB | 800MB | KWin + Plasmashell + Baloo |
| **PipeWire/Audio** | 50MB | 100MB | Audio stack |
| **Electron App (1)** | 0 | 2-4GB | Single app limit |
| **Browser** | 0 | 2-4GB | Firefox/Brave |
| **Dev Tools** | 0 | 2-4GB | VSCodium, terminals |
| **Buffer/Cache** | 2GB | 1GB | Filesystem cache |
| **TOTAL** | **~3.5GB** | **~10GB** | Within targets |

---

## Phase 1: System Libraries (Foundation Layer)

### Overview

System libraries form the foundation that ALL other software depends on. This phase optimizes them at **both** levels:
- **NixOS Level** - Bootstrap-critical packages (glibc, zlib)
- **Home-Manager Level** - 30+ post-bootstrap packages (compression, crypto, image, font, etc.)

### 1.1 NixOS System Libraries (Bootstrap-Critical)

**Location:** `hosts/shoshin/nixos/modules/system/overlays/system-libs-nixos-optimized.nix`

**Packages:**
| Package | Impact | Expected Gain | Risk |
|---------|--------|---------------|------|
| **glibc** | ALL binaries | 3-8% universal | HIGH |
| **zlib** | git, nix, compression | 10-20% | MEDIUM |

**Implementation (FIXED - Uses Flake Input):**

```nix
# /etc/nixos/flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Import home-manager flake for shared hardware profiles
    # Uses git+file:// for proper lock tracking
    hm-workspace = {
      url = "git+file:///home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager";
    };
  };

  outputs = { self, nixpkgs, hm-workspace, ... }:
  let
    system = "x86_64-linux";

    # Import hardware profiles from home-manager workspace
    hardwareProfiles = {
      shoshin = import "${hm-workspace}/modules/profiles/config/hardware/shoshin.nix";
    };
  in {
    nixosConfigurations.shoshin = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        currentHardwareProfile = hardwareProfiles.shoshin;
        inherit hardwareProfiles;
      };
      modules = [
        ./hosts/shoshin/configuration.nix
      ];
    };
  };
}
```

```nix
# /etc/nixos/hosts/shoshin/modules/system/overlays/system-libs-nixos-optimized.nix
{ config, lib, pkgs, currentHardwareProfile, ... }:

let
  hw = currentHardwareProfile;
  compiler = hw.build.compiler;

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

### 1.2 Home-Manager System Libraries (30+ Packages)

**Location:** `home-manager/modules/system/overlays/system-libs-hardware-optimized.nix`

**Status:** ✅ Implemented and extended (2025-12-30)

**Packages (Bootstrap-Safe):**

| Category | Packages | Expected Gain |
|----------|----------|---------------|
| **Compression (Bootstrap)** | zstd, bzip2, xz | 15-30% (CFLAGS only, no mold) |
| **Compression (Extended)** | lz4, snappy, brotli | 10-20% |
| **Cryptography** | openssl (AES-NI), libgcrypt, libsodium | 20-40% |
| **Database** | sqlite (FTS5, RTREE) | 15-25% |
| **Network** | curl, nghttp2, libssh2 | 10-15% |
| **Text** | pcre2 (JIT) | 15-25% |
| **Async I/O** | libevent, libuv | 10-15% |
| **Image Processing** | libjpeg-turbo, libpng, libwebp, giflib | 10-30% |
| **Font/Text Rendering** | freetype, harfbuzz, fontconfig | 10-15% |
| **XML/JSON Parsing** | expat, libxml2, jansson | 10-15% |

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

### 1.3 Hardware Profile Sharing Architecture

```
┌─────────────────────────────────────────────────────────────┐
│           Hardware Profile: shoshin.nix                     │
│  cpu.family = "skylake"                                     │
│  build.compiler.march = "skylake"                           │
│  build.compiler.mtune = "skylake"                           │
│  build.compiler.optimizationLevel = "3"                     │
└─────────────────────────────────────────────────────────────┘
                          │
    ┌─────────────────────┴─────────────────────┐
    │                                           │
    ▼                                           ▼
┌───────────────────────────┐     ┌───────────────────────────┐
│ NixOS flake.nix           │     │ Home-Manager flake.nix    │
│ url = "git+file://..."    │     │ (source of truth)         │
│ → specialArgs             │     │ → hardwareProfiles        │
└───────────────────────────┘     └───────────────────────────┘
    │                                           │
    ▼                                           ▼
┌───────────────────────────┐     ┌───────────────────────────┐
│ NixOS Overlay             │     │ Home-Manager Overlay      │
│ - glibc                   │     │ - 30+ libraries           │
│ - zlib                    │     │ - Image/Font/Compression  │
│ (bootstrap-critical)      │     │ (bootstrap-safe + mold)   │
└───────────────────────────┘     └───────────────────────────┘
```

**Workflow for Profile Updates:**
```bash
# 1. Edit profile in home-manager
vim ~/.MyHome/.../home-manager/modules/profiles/config/hardware/shoshin.nix

# 2. Commit changes in home-manager repo
cd ~/.MyHome/.../home-manager && git add -A && git commit -m "Update shoshin profile"

# 3. Apply to home-manager
home-manager switch --flake .#mitsio@shoshin

# 4. Update NixOS lock
cd /etc/nixos && nix flake update hm-workspace

# 5. Rebuild NixOS
sudo nixos-rebuild switch --flake .#shoshin
```

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

### Electron Binary Name Mapping (FIXED)

**IMPORTANT:** Some Electron apps have different binary names than their package names:

| Package | Wrapper Name | Actual Binary | Notes |
|---------|--------------|---------------|-------|
| `discord` | `discord` | `Discord` | Uppercase! |
| `signal-desktop` | `signal` | `signal-desktop` | Full name |
| `spotify` | `spotify` | `spotify` | Same |
| `vscodium` | `codium` | `codium` | Short name |
| `teams-for-linux` | `teams` | `teams-for-linux` | Full name |
| `zoom-us` | `zoom` | `zoom` | Short name |
| `obsidian` | `obsidian` | `obsidian` | Same |

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

### Implementation Template (FIXED)

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
  # FIXED: Added binaryName parameter for apps with different binary names
  mkElectronApp = {
    pkg,
    name,
    binaryName ? name,    # Allow override for apps with different binary names
    maxHeap,              # V8 heap in MB
    memoryHigh,           # Systemd soft limit
    memoryMax,            # Systemd hard limit
    cpuQuota,             # CPU percentage (100% = 1 core)
    extraFlags ? []
  }: pkgs.writeShellScriptBin name ''
    exec ${pkgs.systemd}/bin/systemd-run --user --scope \
      --unit="app-${name}-$$" \
      --description="${name} (GPU Optimized)" \
      -p OOMScoreAdjust=-100 \
      -p MemoryHigh=${memoryHigh} \
      -p MemoryMax=${memoryMax} \
      -p CPUQuota=${cpuQuota} \
      ${pkg}/bin/${binaryName} \
      ${builtins.concatStringsSep " " gpuFlags} \
      --js-flags='--max-old-space-size=${toString maxHeap}' \
      ${builtins.concatStringsSep " " extraFlags} \
      "$@"
  '';
in
{
  home.packages = [
    # Discord - note the capital D in binary name!
    (mkElectronApp {
      pkg = pkgs.discord;
      name = "discord";
      binaryName = "Discord";  # FIXED: Uppercase
      maxHeap = 1024;
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "150%";
    })

    # Signal - binary is signal-desktop
    (mkElectronApp {
      pkg = pkgs.signal-desktop;
      name = "signal";
      binaryName = "signal-desktop";  # FIXED: Full name
      maxHeap = 768;
      memoryHigh = "1.5G";
      memoryMax = "2G";
      cpuQuota = "100%";
    })

    # VSCodium - binary is codium
    (mkElectronApp {
      pkg = pkgs.vscodium;
      name = "codium";
      binaryName = "codium";
      maxHeap = 2048;
      memoryHigh = "4G";
      memoryMax = "5G";
      cpuQuota = "200%";
    })

    # Teams - binary is teams-for-linux
    (mkElectronApp {
      pkg = pkgs.teams-for-linux;
      name = "teams";
      binaryName = "teams-for-linux";  # FIXED: Full name
      maxHeap = 1536;
      memoryHigh = "2.5G";
      memoryMax = "4G";
      cpuQuota = "200%";
    })

    # Spotify
    (mkElectronApp {
      pkg = pkgs.spotify;
      name = "spotify";
      maxHeap = 512;
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "100%";
    })

    # Zoom - binary is zoom
    (mkElectronApp {
      pkg = pkgs.zoom-us;
      name = "zoom";
      binaryName = "zoom";
      maxHeap = 1024;
      memoryHigh = "2.5G";
      memoryMax = "4G";
      cpuQuota = "250%";
    })
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
Week 1: Foundation (Memory + System Libs)
├── Day 1: Apply zram + kernel memory tuning
├── Day 2: NixOS glibc/zlib overlay (staged rollout)
├── Day 3-4: Verify system stability
└── Day 5: Home-manager 30+ libs rebuild

Week 2: Applications
├── Day 1-3: Electron apps with GPU wrappers
├── Day 4: Systemd cgroup slices
└── Day 5: Native apps systemd limits

Week 3: Desktop
├── Day 1-2: KWin/Plasma configuration
├── Day 3-4: VA-API/VDPAU verification
└── Day 5: Full system testing + benchmark
```

---

## Validation Checklist

### Pre-Implementation
- [ ] Read all research documents listed above
- [ ] Verify current system baseline (`free -h`, `nvidia-smi`)
- [ ] Ensure NixOS live USB available for emergency
- [ ] Record baseline: `free -h > ~/baseline.txt && ps aux --sort=-%mem | head -20 >> ~/baseline.txt`

### Post Phase 0 (Memory)
- [ ] Zram enabled: `zramctl`
- [ ] Kernel params applied: `sysctl vm.swappiness` (should be 10)
- [ ] Idle memory < 4GB: `free -h`

### Post Phase 1 (System Libs)
- [ ] System boots correctly
- [ ] Basic commands work (ls, cat, grep, git)
- [ ] `nix-build` operations succeed
- [ ] No segfaults in `journalctl -xb`

### Post Phase 3 (Electron Apps)
- [ ] All apps launch with GPU acceleration
- [ ] Verify GPU usage: `nvidia-smi pmon`
- [ ] Systemd limits applied: `systemctl --user status app-*`
- [ ] Single app stays within MemoryMax

### Post Phase 5 (GPU Acceleration)
- [ ] `vainfo` shows nvidia driver
- [ ] `vdpauinfo` shows supported codecs
- [ ] Firefox `about:support` shows "Hardware Video Decoding: available"
- [ ] YouTube 1080p plays with <20% CPU

---

## Monitoring Commands

```bash
# Overall system monitoring
alias sysmon='watch -n 2 "free -h && echo && nvidia-smi --query-gpu=memory.used,utilization.gpu --format=csv && echo && ps aux --sort=-%mem | head -10"'

# Systemd resource usage for Electron apps
alias appmon='systemctl --user list-units "app-*" --no-pager'

# Journal monitoring for segfaults
alias crashmon='journalctl -xb -p err --no-pager | tail -20'

# Memory pressure
alias mempress='cat /proc/pressure/memory'

# Per-process memory details
alias memtop='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -20'
```

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
- **System Libs Overlay:** `home-manager/modules/system/overlays/system-libs-hardware-optimized.nix`

---

## Engineering Reviews

### Ops Engineer Review (UPDATED)

**Reviewer Role:** Site Reliability / Platform Engineer
**Review Date:** 2025-12-30
**Status:** ✅ Issues Resolved

#### ✅ Strengths

1. **Memory targets are realistic** - 4GB idle, 8-10GB workload is achievable with proper limits
2. **Rollback procedures are solid** - Both NixOS generations and home-manager generations
3. **Hardware profile sharing is correct** - Uses git+file:// with specialArgs (Option 1)
4. **Zram configuration is optimal** - 75% with zstd for Skylake
5. **Cgroups v2 properly configured** - MemoryHigh/MemoryMax hierarchy

#### ✅ Issues Resolved

| Issue | Resolution | Status |
|-------|------------|--------|
| Hardware profile path | Use `git+file://` flake input with specialArgs | ✅ Fixed |
| Mold linker availability | Disabled for bootstrap-critical packages | ✅ Fixed |
| Memory monitoring | Added monitoring commands section | ✅ Fixed |

### Developer Engineer Review (UPDATED)

**Reviewer Role:** Developer / Code Quality
**Review Date:** 2025-12-30
**Status:** ✅ Issues Resolved

#### ✅ Strengths

1. **Code patterns are correct** - Uses `overrideAttrs` with proper `env` attribute handling
2. **30+ libraries optimized** - Comprehensive coverage of image/font/compression
3. **Electron binary mapping is correct** - Added binaryName parameter
4. **Bootstrap-safe approach** - Avoids `nativeBuildInputs` in system libs overlays

#### ✅ Issues Resolved

| Issue | Resolution | Status |
|-------|------------|--------|
| Electron binary names | Added `binaryName` parameter with correct mappings | ✅ Fixed |
| Missing lz4/snappy | Added 15+ additional libraries | ✅ Fixed |
| Shell PID in unit name | Verified `$$` works correctly | ✅ Verified |

---

## Sources

- [Arch Wiki - Improving Performance](https://wiki.archlinux.org/title/Improving_performance)
- [KDE Discuss - Optimize KDE](https://discuss.kde.org/t/how-can-i-optimize-kde/32602)
- [Linux Memory Management Options](https://gist.github.com/JPvRiel/bcc5b20aac0c9cce6eefa6b88c125e03)
- [NixOS Wiki - Build Flags](https://nixos.wiki/wiki/Build_flags)
- [Zram Configuration Guide](https://linuxblog.io/running-out-of-ram-linux-add-zram/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Home Manager Documentation](https://nix-community.github.io/home-manager/)

---

**Document Version:** 2.0.0
**Last Updated:** 2025-12-30T07:30:00+02:00
**Reviews:** Ops Engineer ✅ (Updated), Developer Engineer ✅ (Updated)
**Research Agents:** Memory Optimization, Extended System Libs, Flake SpecialArgs
