# Enhanced Home-Manager Optimization Plan

**Date:** 2025-12-30
**Author:** Mitsos, Claude Opus 4.5
**Status:** Draft - Pending Review
**Related Plans:**
- `2025-12-30-comprehensive-home-manager-refactor-plan.md`
- `2025-12-30-runtime-optimization-refactor.md`

---

## Executive Summary

This enhanced plan extends the existing comprehensive home-manager refactor plan with:
1. **Apps Optimization Phase** - RAM, CPU, and GPU optimization for 17+ applications
2. **NixOS System Optimization** - glibc/zlib optimization at system level
3. **Plasma Desktop Optimization** - Full KDE Plasma suite optimization
4. **System Libraries Expansion** - Additional libraries in home-manager overlay

### User Requirements (from QnA Rounds)

| Category | Decision |
|----------|----------|
| **Primary Goal** | Balanced (RAM, CPU, GPU optimization) |
| **Plasma Scope** | Full Plasma Suite (KWin, Plasmashell, Baloo, KDE services) |
| **NixOS Level** | Both HM and NixOS overlays for glibc/zlib |
| **Electron Approach** | Both Wrappers + Systemd units |
| **GPU Acceleration** | Both VA-API + VDPAU with automatic fallback |
| **NixOS Testing** | Staged Rollout (backup generation, test boot) |
| **App Priority** | All Equally (single comprehensive pass) |
| **Implementation Order** | Foundation First (System libs → NixOS → Apps → Plasma) |

---

## Phase Structure (Updated)

```
Phase 0: System Libraries (home-manager) - EXISTING ✅
   └── Foundation layer: zstd, bzip2, xz, openssl, libgcrypt, libsodium, sqlite, curl, pcre2

Phase 0.5: System Libraries Expansion (home-manager) - NEW
   └── Additional libs: lz4, snappy, libssh2, openblas, libevent

Phase 1: NixOS System Optimization - NEW
   └── glibc, zlib at system level (bootstrap-critical)
   └── Staged rollout with backup generation

Phase 2: Language Runtimes - EXISTING ✅
   └── Node.js, Python, Rust, Go with PGO + hardware flags

Phase 3: Apps Optimization - NEW (EXPANDED)
   └── 17+ applications with wrappers + systemd units
   └── GPU acceleration (VA-API + VDPAU)
   └── RAM limits, CPU quotas

Phase 4: Plasma Desktop Optimization - NEW
   └── KWin compositor
   └── Plasmashell memory optimization
   └── Baloo indexer configuration
   └── KDE services optimization

Phase 5: Build Optimization - EXISTING ✅
   └── Tier-based parallelism, Cachix strategy
```

---

## Phase 0.5: System Libraries Expansion (NEW)

### Objective

Expand the existing `system-libs-hardware-optimized.nix` overlay with additional high-impact libraries.

### Libraries to Add

| Library | Current Status | Expected Gain | Priority |
|---------|---------------|---------------|----------|
| **lz4** | Not optimized | 15-25% compression | High |
| **snappy** | Not optimized | 10-15% compression | Medium |
| **libssh2** | Not optimized | 10-15% SSH ops | Medium |
| **openblas** | Not optimized | 30-50% BLAS ops | High (for ML) |
| **libevent** | Not optimized | 5-10% async I/O | Medium |
| **libuv** | Not optimized | 5-10% Node.js deps | Medium |
| **jemalloc** | Separate overlay | 10-30% memory | High |

### Implementation

```nix
# Add to modules/system/overlays/system-libs-hardware-optimized.nix

# COMPRESSION (Tier 2)
lz4 = mkOptimized prev.lz4 { useMold = true; };
snappy = mkOptimized prev.snappy { useMold = true; };

# CRYPTO/NETWORK (Tier 2)
libssh2 = mkOptimized prev.libssh2 { useMold = true; };

# ASYNC I/O (Tier 2)
libevent = mkOptimized prev.libevent { useMold = true; };
libuv = mkOptimized prev.libuv { useMold = true; };

# MATH/BLAS (Tier 3 - significant gain)
openblas = prev.openblas.overrideAttrs (old: {
  env = (old.env or {}) // {
    NIX_CFLAGS_COMPILE = toString (cflags ++ [
      "-mavx2"
      "-mfma"
      "-DUSE_OPENMP=1"
    ]);
    NIX_LDFLAGS = "-fuse-ld=mold";
  };
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.mold ];
});
```

### Build Time

- Additional 15-25 minutes one-time
- No binary cache (hardware-specific)

---

## Phase 1: NixOS System Optimization (NEW)

### Objective

Optimize bootstrap-critical packages (glibc, zlib) at NixOS system level for maximum performance gains.

### Why NixOS Level?

From research (`2025-12-30_NIXOS_SYSTEM_LIBS_OVERLAY_BOOTSTRAP_RESEARCH.md`):
- glibc and zlib are bootstrap-critical
- Cannot be overridden in home-manager (causes `anonymous lambda` error)
- Must be optimized at `/etc/nixos/` level

### Implementation Location

```
hosts/shoshin/nixos/modules/system/overlays/
└── system-libs-nixos-optimized.nix  # NEW
```

### NixOS Overlay (Draft)

```nix
# hosts/shoshin/nixos/modules/system/overlays/system-libs-nixos-optimized.nix
{ config, lib, pkgs, ... }:

let
  # Skylake-specific flags
  cflags = [
    "-march=skylake"
    "-mtune=skylake"
    "-O3"
    "-pipe"
    "-fno-semantic-interposition"
    "-fno-plt"
  ];
in
{
  nixpkgs.overlays = [
    (final: prev: {
      # glibc - affects ALL binaries (3-8% universal gain)
      # WARNING: High risk - test thoroughly
      glibc = prev.glibc.overrideAttrs (old: {
        env = (old.env or {}) // {
          NIX_CFLAGS_COMPILE = toString cflags;
        };
        # DO NOT add nativeBuildInputs (breaks bootstrap)
      });

      # zlib - affects compression everywhere (10-20% gain)
      zlib = prev.zlib.overrideAttrs (old: {
        env = (old.env or {}) // {
          NIX_CFLAGS_COMPILE = toString cflags;
        };
      });
    })
  ];
}
```

### Testing Strategy (Staged Rollout)

```bash
# Step 1: Create backup generation
sudo nixos-rebuild build

# Step 2: Build new generation with overlay
sudo nixos-rebuild build --flake /etc/nixos#shoshin

# Step 3: Switch to new generation (creates rollback point)
sudo nixos-rebuild switch --flake /etc/nixos#shoshin

# Step 4: Test system stability
# - Check system boots
# - Run basic commands
# - Monitor for issues

# Step 5: Rollback if issues
sudo nixos-rebuild switch --rollback
```

### Risk Assessment

| Risk | Mitigation |
|------|------------|
| System won't boot | Staged rollout with backup generation |
| Subtle binary issues | Test common tools (ls, cat, grep) |
| Performance regression | Benchmark before/after |

### Expected Gains

| Library | Impact | Gain |
|---------|--------|------|
| **glibc** | All programs | 3-8% universal |
| **zlib** | git, nix, compression | 10-20% |

### Documentation

Create new ADR: `ADR-029-NIXOS_SYSTEM_LIBS_OPTIMIZATION.md`

---

## Phase 3: Apps Optimization (EXPANDED)

### Objective

Optimize 17+ applications for RAM, CPU, and GPU usage using:
1. **Wrapper scripts** with optimized Electron/app flags
2. **Systemd user units** with cgroup limits

### Applications List

| App | Type | Current Status | Target Optimization |
|-----|------|----------------|---------------------|
| **Teams** | Electron | Not configured | Wrapper + Systemd |
| **Discord** | Electron | Basic wrapper | Enhance + Systemd |
| **Spotify** | Electron | Optimized ✅ | Verify limits |
| **VSCodium** | Electron | GPU flags | Add Systemd |
| **Claude Desktop** | Electron | Basic config | Wrapper + Systemd |
| **Signal** | Electron | Basic config | Enhance + Systemd |
| **Session** | Electron | Optimized ✅ | Verify limits |
| **Zoom** | Native + Electron | Not configured | Wrapper + Systemd |
| **Brave** | Chromium | GPU flags ✅ | Verify |
| **Firefox** | Native | Overlay ✅ | Verify VA-API |
| **KeePassXC** | Qt | Not optimized | Systemd limits |
| **Copyq** | Qt | Not optimized | Systemd limits |
| **Kitty** | Native | Not optimized | GPU config |
| **Dropbox** | Native | Not optimized | Systemd limits |
| **Flameshot** | Qt | Not optimized | Minimal |
| **KDE Connect** | Qt | Not optimized | Background service |

### Electron Apps Standard Configuration

```nix
# modules/apps/electron-optimized.nix

let
  # Standard GPU flags for NVIDIA GTX 960 + X11
  gpuFlags = [
    "--use-gl=desktop"
    "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--ignore-gpu-blocklist"
    "--ozone-platform=x11"
    "--enable-hardware-overlays"
  ];

  # Memory optimization flags (per-app tunable)
  memoryFlags = maxHeap: [
    "--js-flags='--max-old-space-size=${toString maxHeap}'"
    "--renderer-process-limit=4"
    "--disable-background-timer-throttling=false"
  ];

  # Create optimized wrapper with systemd scope
  mkElectronWrapper = {
    pkg,
    name,
    maxHeap ? 1024,      # MB for V8 heap
    memoryHigh ? "2G",   # systemd soft limit
    memoryMax ? "3G",    # systemd hard limit
    cpuQuota ? "150%",   # 1.5 cores
    extraFlags ? []
  }: pkgs.writeShellScriptBin name ''
    exec ${pkgs.systemd}/bin/systemd-run --user --scope \
      --unit="app-${name}-$$" \
      --description="${name} (Optimized)" \
      -p OOMScoreAdjust=-100 \
      -p MemoryHigh=${memoryHigh} \
      -p MemoryMax=${memoryMax} \
      -p CPUQuota=${cpuQuota} \
      ${pkg}/bin/${name} \
      ${builtins.concatStringsSep " " (gpuFlags ++ memoryFlags maxHeap ++ extraFlags)} \
      "$@"
  '';
in
{
  # ... app definitions
}
```

### Per-App Configuration

#### Teams (Microsoft Teams)

```nix
teams = mkElectronWrapper {
  pkg = pkgs.teams-for-linux;  # Or pkgs.teams
  name = "teams";
  maxHeap = 1536;      # Teams is memory-hungry
  memoryHigh = "2.5G";
  memoryMax = "4G";
  cpuQuota = "200%";   # 2 cores (video calls)
};
```

#### Discord

```nix
discord = mkElectronWrapper {
  pkg = pkgs.discord;
  name = "discord";
  maxHeap = 1024;
  memoryHigh = "1.5G";
  memoryMax = "2G";
  cpuQuota = "150%";
  extraFlags = [
    "--disable-smooth-scrolling"  # Reduce GPU overhead
  ];
};
```

#### Claude Desktop

```nix
claude-desktop = mkElectronWrapper {
  pkg = claude-desktop-pkg;  # From flake input
  name = "claude-desktop";
  maxHeap = 2048;      # AI context needs more
  memoryHigh = "4G";
  memoryMax = "6G";
  cpuQuota = "200%";
};
```

#### Signal

```nix
signal = mkElectronWrapper {
  pkg = pkgs.signal-desktop;
  name = "signal-desktop";
  maxHeap = 512;       # Signal is lightweight
  memoryHigh = "1G";
  memoryMax = "1.5G";
  cpuQuota = "100%";
};
```

#### Zoom

```nix
zoom = mkElectronWrapper {
  pkg = pkgs.zoom-us;
  name = "zoom";
  maxHeap = 1024;
  memoryHigh = "2G";
  memoryMax = "3G";
  cpuQuota = "250%";   # Video conferencing needs CPU
  extraFlags = [
    "--enable-features=UseOzonePlatform"  # Better Wayland compat
  ];
};
```

### Native Apps (Qt/GTK) Systemd Configuration

```nix
# modules/apps/native-apps-systemd.nix

let
  # Create systemd user service for native app
  mkNativeService = {
    name,
    exec,
    memoryHigh ? "512M",
    memoryMax ? "1G",
    cpuQuota ? "50%",
    description ? "${name} Desktop Application"
  }: {
    systemd.user.services.${name} = {
      Unit = {
        Description = description;
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = exec;
        MemoryHigh = memoryHigh;
        MemoryMax = memoryMax;
        CPUQuota = cpuQuota;
        OOMScoreAdjust = -100;
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
in
{
  # KeePassXC (already has good defaults, just add limits)
  systemd.user.services.keepassxc = {
    Service = {
      MemoryHigh = "256M";
      MemoryMax = "512M";
      CPUQuota = "25%";
    };
  };

  # Copyq (clipboard manager)
  systemd.user.services.copyq = {
    Service = {
      MemoryHigh = "128M";
      MemoryMax = "256M";
      CPUQuota = "10%";
    };
  };

  # Flameshot (screenshot)
  systemd.user.services.flameshot = {
    Service = {
      MemoryHigh = "256M";
      MemoryMax = "512M";
      CPUQuota = "50%";  # Needs CPU for processing
    };
  };
}
```

### Kitty Terminal Optimization

```nix
# modules/apps/kitty-optimized.nix

{
  programs.kitty = {
    settings = {
      # GPU Rendering
      linux_display_server = "x11";
      sync_to_monitor = "yes";

      # Memory optimization
      scrollback_lines = 5000;  # Reduced from default 10000
      scrollback_pager_history_size = 10;  # MB

      # Performance
      repaint_delay = 10;  # ms
      input_delay = 3;     # ms

      # GPU acceleration
      wayland_titlebar_color = "background";
    };
  };

  # Environment for Kitty GPU
  home.sessionVariables = {
    KITTY_ENABLE_WAYLAND = "0";  # Use X11 for NVIDIA
  };
}
```

### Expected RAM Savings

| App | Before | After | Savings |
|-----|--------|-------|---------|
| Teams | 1.5-2.5GB | 1-2GB | 25-40% |
| Discord | 500-800MB | 300-500MB | 30-40% |
| VSCodium | 800-1.5GB | 500-1GB | 30-40% |
| Claude Desktop | 1-2GB | 800MB-1.5GB | 20-30% |
| Spotify | 300-600MB | 200-400MB | 30-40% |
| Signal | 200-400MB | 150-300MB | 25-35% |
| **Total** | 4-8GB | 2.5-5GB | **35-40%** |

---

## Phase 4: Plasma Desktop Optimization (NEW)

### Objective

Optimize KDE Plasma 6 for RAM, CPU, and GPU usage.

### Components

1. **KWin Compositor** - GPU compositing, VSync, animations
2. **Plasmashell** - Widgets, panels, themes
3. **Baloo** - File indexer
4. **KDE Services** - Krunner, Akonadi, etc.

### KWin Compositor Configuration

Via chezmoi (`dot_config/kwinrc`):

```ini
[Compositing]
# Use OpenGL for GTX 960 (better than Vulkan for Maxwell)
Backend=OpenGL
GLCore=true
GLPreferBufferSwap=a  # Auto buffer swap
GLTextureFilter=2     # Trilinear filtering

# Performance
OpenGLIsUnsafe=false
WindowsBlockCompositing=true  # Disable for fullscreen games
AnimationSpeed=3      # Faster animations (1=slowest, 6=instant)

# VSync
RefreshRate=60

[Effect-overview]
BorderActivate=9      # Disable corner activation
TouchBorderActivate=7

[Effect-zoom]
Enabled=false         # Disable zoom effect

[TabBox]
LayoutName=thumbnail_grid  # Lighter than coverswitch
```

### Baloo Configuration

```ini
# Via chezmoi: dot_config/baloofilerc

[Basic Settings]
Indexing-Enabled=true
only basic indexing=true  # Don't index file contents

[General]
# Exclude paths
exclude filters[$e]=*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,*.pyc,*.pyo
exclude folders[$e]=$HOME/.cache/,$HOME/.local/share/Trash/,$HOME/node_modules/,$HOME/.npm/,$HOME/.cargo/,$HOME/.rustup/,$HOME/.nix-profile/,$HOME/.nix-defexpr/,/nix/store/

# Limit resources
database maximum size=500  # MB
```

### KDE Services to Disable

```nix
# Via home-manager or chezmoi

# Disable Akonadi (PIM) if not using KMail/Kontact
systemd.user.services.akonadi = {
  Service.ExecStart = "${pkgs.coreutils}/bin/true";
};

# Limit Krunner plugins
# Via krunnerrc
```

### Plasmashell Memory Tips

1. **Use lighter themes** - Breeze Dark is lighter than custom themes
2. **Limit widgets** - Each widget uses ~10-50MB RAM
3. **Reduce panel animations** - Disable floating panel effects
4. **Use icon-only taskbar** - Less text rendering

### Expected Savings

| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| KWin | 150-300MB | 100-200MB | 30-40% |
| Plasmashell | 200-400MB | 150-300MB | 25-35% |
| Baloo | 50-200MB | 30-100MB | 40-50% |
| **Total Plasma** | 400-900MB | 280-600MB | **30-35%** |

---

## Implementation Order

### Week 1: Foundation

1. **Phase 0.5**: Expand system-libs overlay
2. **Phase 1**: Create NixOS glibc/zlib overlay (document only, test in VM)

### Week 2: Apps

3. **Phase 3**: Implement Electron apps optimization
4. **Phase 3**: Implement native apps systemd limits

### Week 3: Desktop

5. **Phase 4**: KWin compositor configuration
6. **Phase 4**: Baloo and KDE services optimization

### Week 4: Validation

7. Full system testing
8. Performance benchmarking
9. Documentation updates

---

## Validation Checklist

### Before Implementation

- [ ] Current RAM usage baseline (htop/btop)
- [ ] Current CPU usage baseline
- [ ] GPU acceleration status (vainfo, vdpauinfo)
- [ ] Backup current generation

### After Each Phase

- [ ] System boots correctly
- [ ] All apps launch
- [ ] No OOM kills in journalctl
- [ ] RAM usage reduced
- [ ] GPU acceleration working (chrome://gpu, about:support)

### Final Validation

```bash
# RAM usage
free -h

# Per-app memory (with systemd)
systemd-cgls --user

# GPU status
nvidia-smi
vainfo
vdpauinfo

# Build time
time home-manager switch
```

---

## Related Documentation

- `2025-12-30-comprehensive-home-manager-refactor-plan.md` - Original plan
- `2025-12-30_NIXOS_SYSTEM_LIBS_OVERLAY_BOOTSTRAP_RESEARCH.md` - System libs research
- `ADR-024` - Language runtime optimizations
- `ADR-028` - Comprehensive runtime and build optimizations
- `docs/researches/2025-12-30_ELECTRON_APPS_OPTIMIZATION_RESEARCH.md` - Electron research (pending)
- `docs/researches/2025-12-30_PLASMA_DESKTOP_OPTIMIZATION_RESEARCH.md` - Plasma research (pending)
- `docs/researches/2025-12-30_VAAPI_VDPAU_GPU_ACCELERATION_RESEARCH.md` - GPU research (pending)

---

**Time:** 2025-12-30T08:XX:XX+02:00 (Europe/Athens)
