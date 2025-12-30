# Electron-Based Applications Optimization Research for Linux

**Date**: 2025-12-30
**Author**: Dimitris Tsioumas
**Target System**: NixOS with 16GB RAM, Intel Skylake i7-6700K, NVIDIA GTX 960 (Maxwell)
**Target Apps**: Teams, Discord, Spotify, VSCodium, Claude Desktop, Signal

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Electron Command-Line Flags](#electron-command-line-flags)
   - [Memory Optimization Flags](#memory-optimization-flags)
   - [GPU Acceleration Flags](#gpu-acceleration-flags)
   - [CPU Optimization Flags](#cpu-optimization-flags)
   - [V8 JavaScript Engine Flags](#v8-javascript-engine-flags)
3. [Systemd Cgroup Configuration](#systemd-cgroup-configuration)
   - [Memory Control Settings](#memory-control-settings)
   - [CPU Control Settings](#cpu-control-settings)
   - [I/O Control Settings](#io-control-settings)
   - [Recommended Values by App Category](#recommended-values-by-app-category)
4. [App-Specific Optimizations](#app-specific-optimizations)
   - [Discord](#discord)
   - [Microsoft Teams](#microsoft-teams)
   - [Spotify](#spotify)
   - [VSCodium](#vscodium)
   - [Claude Desktop](#claude-desktop)
   - [Signal Desktop](#signal-desktop)
5. [NixOS/Home-Manager Integration](#nixoshome-manager-integration)
   - [Overlay Pattern](#overlay-pattern)
   - [Wrapper Script Pattern](#wrapper-script-pattern)
   - [Systemd User Service Pattern](#systemd-user-service-pattern)
   - [Combined Template](#combined-template)
6. [Sources](#sources)

---

## Executive Summary

This research document provides comprehensive guidance on optimizing Electron-based applications on Linux systems, specifically targeting NixOS with home-manager. The optimization strategy employs a two-pronged approach:

1. **Wrapper Scripts with Optimized Flags**: Command-line arguments passed to Electron apps to control V8 heap size, GPU acceleration, and process management.

2. **Systemd User Units with Cgroup Limits**: Resource isolation using systemd's cgroup v2 features for memory caps, CPU quotas, and I/O prioritization.

### Key Findings

- **Memory**: Use `--max-old-space-size` to cap V8 heap per app category (512MB-2GB depending on app complexity)
- **GPU**: Enable VAAPI hardware acceleration with `VaapiVideoDecoder` and `enable-gpu-rasterization` for NVIDIA on X11
- **CPU**: Limit renderer processes and disable background throttling where needed
- **Systemd**: Use `MemoryHigh` as soft limit and `MemoryMax` as hard limit; typical allocations 2-4GB per Electron app on 16GB system

---

## Electron Command-Line Flags

### Memory Optimization Flags

| Flag | Description | Recommended Value |
|------|-------------|-------------------|
| `--js-flags='--max-old-space-size=N'` | Maximum V8 heap size in MB | 512-2048 based on app |
| `--js-flags='--optimize-for-size'` | Favor memory over speed | Enable for low-memory systems |
| `--js-flags='--lite-mode'` | Disable TurboFan optimizer, reduce memory by 22% | Use sparingly, affects performance |
| `--renderer-process-limit=N` | Maximum concurrent renderer processes | 2-4 for typical apps |
| `--disable-site-isolation-trials` | Reduce process overhead | Enable for memory savings |
| `--disk-cache-size=N` | Limit disk cache in bytes | 52428800 (50MB) |

**Notes on `--max-old-space-size`**:
- Electron 14+ has an ~8GB memory limit due to V8 pointer compression
- The flag must be passed via `--js-flags` wrapper, not directly
- Setting this for the main process requires special handling (the flag is a no-op after isolate creation)

```bash
# Example: Limit Discord to 1GB V8 heap
discord --js-flags='--max-old-space-size=1024'
```

### GPU Acceleration Flags

These flags enable hardware acceleration for NVIDIA Maxwell (GTX 960) on X11:

| Flag | Description | Notes |
|------|-------------|-------|
| `--use-gl=desktop` | Use desktop OpenGL | Preferred for X11 + NVIDIA |
| `--enable-features=VaapiVideoDecoder` | Enable VA-API video decoding | Hardware video decode |
| `--enable-features=VaapiIgnoreDriverChecks` | Bypass driver blocklist | May be needed for some drivers |
| `--enable-features=Vulkan` | Enable Vulkan rendering | For modern GPU features |
| `--enable-features=CanvasOopRasterization` | Out-of-process canvas raster | GPU memory optimization |
| `--enable-gpu-rasterization` | GPU-accelerated rasterization | Major performance gain |
| `--enable-zero-copy` | Zero-copy texture uploads | Reduces CPU overhead |
| `--ignore-gpu-blocklist` | Ignore GPU hardware blocklist | Override safety checks |
| `--ozone-platform=x11` | Force X11 platform | For X11 sessions |

**Complete GPU Flags String for NVIDIA + X11**:
```bash
--use-gl=desktop \
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization \
--enable-gpu-rasterization \
--enable-zero-copy \
--ignore-gpu-blocklist \
--ozone-platform=x11
```

**For Wayland Sessions** (future reference):
```bash
--use-gl=egl \
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,UseOzonePlatform \
--ozone-platform=wayland \
--enable-gpu-rasterization \
--enable-zero-copy
```

**2025 Update**: The flag naming has changed for accelerated video decode:
- Old: `VaapiVideoDecodeLinuxGL,VaapiDecodeLinuxZeroCopyGL`
- New: `AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL`

### CPU Optimization Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `--disable-background-timer-throttling` | Prevent timer throttling in background | Apps needing background activity |
| `--disable-renderer-backgrounding` | Prevent reducing priority of hidden pages | Background tabs/windows |
| `backgroundThrottling: false` (WebPreferences) | Disable animation/timer throttling | Must be set in app code |
| `--single-process` | Run renderer in main process | **NOT RECOMMENDED** - security risk |
| `--no-sandbox` | Disable sandbox | **NOT RECOMMENDED** - security risk |

**Note**: Starting Chrome 57 (and thus Electron), background tabs/windows are throttled by default. This saves CPU but may affect apps that need background processing.

### V8 JavaScript Engine Flags

These are passed via `--js-flags='...'`:

| Flag | Description | Use Case |
|------|-------------|----------|
| `--max-old-space-size=N` | Max heap size in MB | Primary memory control |
| `--optimize-for-size` | Favor memory over speed | Low-memory environments |
| `--lite-mode` | Disable optimizing compiler | ~22% memory savings, slower JS |
| `--expose-gc` | Expose `gc()` function | Debugging only |
| `--harmony` | Enable harmony features | Experimental JS features |

**Recommended V8 Flags for Memory Constrained Systems**:
```bash
--js-flags='--max-old-space-size=1024 --optimize-for-size'
```

---

## Systemd Cgroup Configuration

### Memory Control Settings

| Setting | Description | Behavior |
|---------|-------------|----------|
| `MemoryMin` | Memory guaranteed to the unit | Protected from reclaim |
| `MemoryLow` | Soft memory protection | Reclaimed only under pressure |
| `MemoryHigh` | Soft memory limit (throttle point) | Processes heavily throttled above |
| `MemoryMax` | Hard memory limit (OOM point) | OOM killer invoked if exceeded |
| `MemorySwapMax` | Maximum swap usage | Limit swap consumption |

**Best Practice**: Use `MemoryHigh` as the primary control mechanism and `MemoryMax` as the last line of defense.

### CPU Control Settings

| Setting | Description | Value Range |
|---------|-------------|-------------|
| `CPUWeight` | Relative CPU priority | 1-10000 (default: 100) |
| `CPUQuota` | Absolute CPU time limit | Percentage (e.g., 50%, 200%) |
| `AllowedCPUs` | Restrict to specific CPU cores | CPU list (e.g., 0-3) |

**Note**: `CPUQuota=100%` means 100% of ONE CPU core. For multi-core allowance, use values like `200%` for 2 cores.

### I/O Control Settings

| Setting | Description | Value Range |
|---------|-------------|-------------|
| `IOWeight` | Relative I/O priority | 1-10000 (default: 100) |
| `IOReadBandwidthMax` | Max read bandwidth per device | Bytes/second |
| `IOWriteBandwidthMax` | Max write bandwidth per device | Bytes/second |

### Recommended Values by App Category

For a **16GB RAM system** with multiple Electron apps running:

#### Communication Apps (Discord, Teams, Slack, Signal)
```ini
[Service]
MemoryHigh=2G
MemoryMax=3G
MemorySwapMax=512M
CPUQuota=80%
IOWeight=80
OOMScoreAdjust=100
```

#### Productivity Apps (VSCodium, Claude Desktop)
```ini
[Service]
MemoryHigh=3G
MemoryMax=4G
MemorySwapMax=1G
CPUQuota=150%
IOWeight=120
OOMScoreAdjust=-100
```

#### Media Apps (Spotify)
```ini
[Service]
MemoryHigh=1.5G
MemoryMax=2G
MemorySwapMax=256M
CPUQuota=50%
IOWeight=60
OOMScoreAdjust=200
```

#### OOMScoreAdjust Guidelines
- **-1000**: Never kill (use sparingly)
- **-500 to -100**: Important apps (editors, productivity)
- **0**: Default
- **100 to 300**: Less critical apps (media, chat)
- **1000**: Kill first under pressure

---

## App-Specific Optimizations

### Discord

**Configuration Location**: `~/.config/discord-flags.conf` (for discord_arch_electron) or modify `.desktop` file

**Recommended Flags**:
```bash
--use-gl=desktop
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
--js-flags='--max-old-space-size=1024'
```

**Known Issues**:
- Official Discord does not read `electron-flags.conf`; uses bundled Electron
- Memory leaks during streams; may need periodic restarts
- Discord has internal 4GB memory restart experiment on Windows

**Systemd Template**:
```ini
[Service]
MemoryHigh=2G
MemoryMax=3G
CPUQuota=60%
OOMScoreAdjust=150
```

### Microsoft Teams

**Important Note**: Teams is transitioning from Electron to Edge WebView2 (Teams 2.0). Linux version may lag behind.

**Optimization Options**:
1. Disable GPU hardware acceleration in Settings > General
2. Clear Teams cache: `~/.config/Microsoft/Microsoft Teams/`
3. Disable Outlook Teams add-ins

**Recommended Flags** (for Electron-based version):
```bash
--disable-gpu-sandbox
--js-flags='--max-old-space-size=1536'
--renderer-process-limit=4
```

**Systemd Template**:
```ini
[Service]
MemoryHigh=3G
MemoryMax=4G
CPUQuota=100%
OOMScoreAdjust=50
```

### Spotify

**Configuration Location**: `~/.config/spotify-flags.conf` or `/etc/spotify-launcher.conf`

**Recommended Flags**:
```bash
--use-gl=desktop
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
--js-flags='--max-old-space-size=512'
--renderer-process-limit=2
--disable-site-isolation-trials
```

**Cache Clearing** (for performance issues):
```bash
rm -rf ~/.cache/spotify/Browser/* ~/.cache/spotify/Data/* ~/.cache/spotify/Storage/*
```

**Known Issues**:
- High GPU usage reported on some systems
- Crashes with `--no-zygote` may need to be added if GPU process fails

**Systemd Template**:
```ini
[Service]
MemoryHigh=2G
MemoryMax=3G
CPUQuota=40%
IOWeight=80
OOMScoreAdjust=100
```

### VSCodium

**Configuration Considerations**:
- VSCodium does NOT read `electron-flags.conf` automatically
- Use `.desktop` file modification or shell alias
- Arch's `code-oss` package reads `code-flags.conf` and `electronNN-flags.conf`

**Recommended Flags**:
```bash
--use-gl=desktop
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
--js-flags='--max-old-space-size=2048'
```

**System-Wide Electron**:
Consider using `vscodium-electron` package (Arch AUR) to share system Electron and save disk space.

**Systemd Template**:
```ini
[Service]
MemoryHigh=4G
MemoryMax=5G
CPUQuota=200%
IOWeight=150
OOMScoreAdjust=-200
```

### Claude Desktop

**Recommended Flags**:
```bash
--use-gl=desktop
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
--js-flags='--max-old-space-size=2048'
--renderer-process-limit=3
```

**Systemd Template** (productivity priority):
```ini
[Service]
MemoryHigh=2.5G
MemoryMax=3G
CPUQuota=100%
IOWeight=100
OOMScoreAdjust=-200
```

### Signal Desktop

**Recent Changes**: Signal Desktop v7.59.0 enabled GPU acceleration by default on Linux.

**Recommended Flags**:
```bash
--use-gl=desktop
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
--js-flags='--max-old-space-size=768'
```

**For Virtual Machines** (if GPU acceleration causes issues):
```bash
--disable-gpu
```

**Systemd Template**:
```ini
[Service]
MemoryHigh=1.5G
MemoryMax=2G
CPUQuota=50%
OOMScoreAdjust=100
```

---

## NixOS/Home-Manager Integration

### Overlay Pattern

Using `nixpkgs.overlays` to wrap Electron apps globally:

```nix
# overlays/electron-optimizations.nix
final: prev: {
  discord = prev.discord.override {
    commandLineArgs = builtins.concatStringsSep " " [
      "--use-gl=desktop"
      "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--ignore-gpu-blocklist"
      "--ozone-platform=x11"
      "--js-flags='--max-old-space-size=1024'"
    ];
  };
}
```

**Usage in Home-Manager**:
```nix
{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (import ./overlays/electron-optimizations.nix)
  ];
}
```

### Wrapper Script Pattern

Using `writeShellScriptBin` for complete control:

```nix
{ pkgs, ... }:

let
  # GPU flags for NVIDIA + X11
  gpuFlags = [
    "--use-gl=desktop"
    "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--ignore-gpu-blocklist"
    "--ozone-platform=x11"
  ];

  # Memory flags by category
  memoryFlags = {
    chat = "--js-flags='--max-old-space-size=1024'";
    productivity = "--js-flags='--max-old-space-size=2048'";
    media = "--js-flags='--max-old-space-size=512'";
  };

  # Wrapper generator
  makeElectronWrapper = pkg: name: memoryFlag: additionalFlags:
    pkgs.writeShellScriptBin name ''
      exec ${pkg}/bin/${name} \
        ${builtins.concatStringsSep " " gpuFlags} \
        ${memoryFlag} \
        ${additionalFlags} \
        "$@"
    '';

in
{
  home.packages = [
    (makeElectronWrapper pkgs.discord "discord" memoryFlags.chat "")
    (makeElectronWrapper pkgs.spotify "spotify" memoryFlags.media "--renderer-process-limit=2")
    (makeElectronWrapper pkgs.signal-desktop "signal-desktop" memoryFlags.chat "")
  ];
}
```

### Systemd User Service Pattern

Using `symlinkJoin` with `makeWrapper` and systemd-run:

```nix
{ pkgs, ... }:

let
  gpuFlags = [
    "--use-gl=desktop"
    "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--ignore-gpu-blocklist"
    "--ozone-platform=x11"
  ];

  # Systemd-wrapped Electron app
  makeSystemdWrappedApp = {
    pkg,
    name,
    jsFlags ? "--max-old-space-size=1024",
    memoryHigh ? "2G",
    memoryMax ? "3G",
    cpuQuota ? "80%",
    oomScoreAdjust ? "100",
    extraFlags ? ""
  }:
    pkgs.writeShellScriptBin name ''
      exec ${pkgs.systemd}/bin/systemd-run --user --scope \
        --unit="app-${name}-$$" \
        --description="${name} (Optimized)" \
        -p MemoryHigh=${memoryHigh} \
        -p MemoryMax=${memoryMax} \
        -p CPUQuota=${cpuQuota} \
        -p OOMScoreAdjust=${oomScoreAdjust} \
        ${pkg}/bin/${name} \
        ${builtins.concatStringsSep " " gpuFlags} \
        --js-flags='${jsFlags}' \
        ${extraFlags} \
        "$@"
    '';

in
{
  home.packages = [
    (makeSystemdWrappedApp {
      pkg = pkgs.discord;
      name = "discord";
      jsFlags = "--max-old-space-size=1024";
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "60%";
      oomScoreAdjust = "150";
    })

    (makeSystemdWrappedApp {
      pkg = pkgs.spotify;
      name = "spotify";
      jsFlags = "--max-old-space-size=512";
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "40%";
      oomScoreAdjust = "100";
      extraFlags = "--renderer-process-limit=2 --disable-site-isolation-trials";
    })
  ];
}
```

### Combined Template

Complete module for all target apps:

```nix
# modules/apps/electron-optimized.nix
{ pkgs, lib, config, ... }:

let
  # ============================================
  # Electron Apps GPU + Memory + Systemd Optimization
  # ============================================
  # Target: NixOS with 16GB RAM, i7-6700K, GTX 960
  # Research: 2025-12-30
  # ============================================

  # GPU acceleration flags for NVIDIA Maxwell + X11
  gpuFlags = [
    "--use-gl=desktop"
    "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--ignore-gpu-blocklist"
    "--ozone-platform=x11"
  ];

  gpuFlagsStr = builtins.concatStringsSep " " gpuFlags;

  # App configurations
  appConfigs = {
    discord = {
      pkg = pkgs.discord;
      jsMaxHeap = 1024;
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "60%";
      oomScore = 150;
      extraFlags = "";
    };

    spotify = {
      pkg = pkgs.spotify;
      jsMaxHeap = 512;
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "40%";
      oomScore = 100;
      extraFlags = "--renderer-process-limit=2 --disable-site-isolation-trials";
    };

    signal-desktop = {
      pkg = pkgs.signal-desktop;
      jsMaxHeap = 768;
      memoryHigh = "1.5G";
      memoryMax = "2G";
      cpuQuota = "50%";
      oomScore = 100;
      extraFlags = "";
    };

    slack = {
      pkg = pkgs.slack;
      jsMaxHeap = 1024;
      memoryHigh = "2G";
      memoryMax = "3G";
      cpuQuota = "60%";
      oomScore = 100;
      extraFlags = "";
    };
  };

  # Generator function
  makeOptimizedApp = name: cfg:
    pkgs.writeShellScriptBin name ''
      exec ${pkgs.systemd}/bin/systemd-run --user --scope \
        --unit="app-${name}-$$" \
        --description="${name} (Optimized)" \
        -p MemoryHigh=${cfg.memoryHigh} \
        -p MemoryMax=${cfg.memoryMax} \
        -p CPUQuota=${cfg.cpuQuota} \
        -p OOMScoreAdjust=${toString cfg.oomScore} \
        ${cfg.pkg}/bin/${name} \
        ${gpuFlagsStr} \
        --js-flags='--max-old-space-size=${toString cfg.jsMaxHeap}' \
        ${cfg.extraFlags} \
        "$@"
    '';

in
{
  home.packages = lib.mapAttrsToList makeOptimizedApp appConfigs;

  # Shell aliases for convenience
  programs.bash.shellAliases = lib.mapAttrs (name: _: name) appConfigs;
}
```

---

## Sources

### Electron Documentation
- [Electron Command Line Switches](https://www.electronjs.org/docs/latest/api/command-line-switches)
- [Electron Performance Guide](https://www.electronjs.org/docs/latest/tutorial/performance)
- [Electron Security](https://www.electronjs.org/docs/latest/tutorial/security)
- [Electron Memory Issues - GitHub #31330](https://github.com/electron/electron/issues/31330)
- [Electron max-old-space-size - GitHub #2056](https://github.com/electron/electron/issues/2056)

### Chromium/GPU Resources
- [Chromium GPU Rasterization](https://www.chromium.org/developers/design-documents/chromium-graphics/how-to-get-gpu-rasterization/)
- [Chromium Command Line Flags](https://www.chromium.org/developers/how-tos/run-chromium-with-flags/)
- [Chromium GPU Switches Source](https://chromium.googlesource.com/chromium/src/+/master/gpu/config/gpu_switches.cc)
- [Arch Linux - Hardware Acceleration on Electron](https://bbs.archlinux.org/viewtopic.php?id=281207)

### App-Specific Resources
- [Discord - ArchWiki](https://wiki.archlinux.org/title/Discord)
- [discord_arch_electron - AUR](https://aur.archlinux.org/packages/discord_arch_electron)
- [Spotify - ArchWiki](https://wiki.archlinux.org/title/Spotify)
- [Visual Studio Code - ArchWiki](https://wiki.archlinux.org/title/Visual_Studio_Code)
- [Signal Desktop GPU Acceleration Issue - GitHub #7400](https://github.com/signalapp/Signal-Desktop/issues/7400)

### Systemd Resources
- [systemd.resource-control - freedesktop.org](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html)
- [systemd.resource-control - Arch Manual](https://man.archlinux.org/man/systemd.resource-control.5.en)
- [cgroups - ArchWiki](https://wiki.archlinux.org/title/Cgroups)
- [Red Hat - Configuring Resource Management with cgroups-v2](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_monitoring_and_updating_the_kernel/assembly_configuring-resource-management-using-systemd_managing-monitoring-and-updating-the-kernel)
- [KDE Blogs - Limit Application Memory with systemd](https://blogs.kde.org/2024/10/18/limit-application-memory-usage-with-systemd/)

### V8 Engine Resources
- [V8 Lite Mode - v8.dev](https://v8.dev/blog/v8-lite)
- [Node.js Memory Management](https://nodejs.org/en/learn/diagnostics/memory/understanding-and-tuning-memory)
- [V8 GC Optimization - Platformatic Blog](https://blog.platformatic.dev/optimizing-nodejs-performance-v8-memory-management-and-gc-tuning)

### NixOS Resources
- [NixOS Wiki - Overlays](https://wiki.nixos.org/wiki/Overlays)
- [NixOS Wiki - Nix Cookbook](https://wiki.nixos.org/wiki/Nix_Cookbook)
- [NixOS Discourse - Wrapping Electron Apps](https://discourse.nixos.org/t/how-to-wrap-all-my-electron-apps-with-args/17111)
- [nixpkgs - makeWrapper Source](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh)
- [Nixcademy - Mastering Overlays](https://nixcademy.com/posts/mastering-nixpkgs-overlays-techniques-and-best-practice/)

### Memory Optimization Guides
- [Debugging Electron Memory Usage - Seena Burns](https://seenaburns.com/debugging-electron-memory-usage/)
- [How to Reduce Electron Memory - AppNize](https://applicationize.me/how-to-reduce-electron-application-memory-consumption/)
- [Limit Browser Memory with cgroups - Raymii.org](https://raymii.org/s/articles/Limit_specific_process_memory_on_desktop_linux_with_cgroups.html)

---

## Appendix: Quick Reference

### Memory Allocation Summary (16GB System)

| App | V8 Heap | MemoryHigh | MemoryMax | CPUQuota | OOMScore |
|-----|---------|------------|-----------|----------|----------|
| Discord | 1024MB | 2G | 3G | 60% | 150 |
| Teams | 1536MB | 3G | 4G | 100% | 50 |
| Spotify | 512MB | 2G | 3G | 40% | 100 |
| VSCodium | 2048MB | 4G | 5G | 200% | -200 |
| Claude Desktop | 2048MB | 2.5G | 3G | 100% | -200 |
| Signal | 768MB | 1.5G | 2G | 50% | 100 |

### Total Memory Budget

With all apps running simultaneously:
- **Soft limit (MemoryHigh total)**: ~15G
- **Hard limit (MemoryMax total)**: ~19G (exceeds RAM, but not all apps run at peak)
- **Realistic concurrent usage**: 8-12G for all Electron apps

### GPU Flags One-Liner

```bash
--use-gl=desktop --enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization --enable-gpu-rasterization --enable-zero-copy --ignore-gpu-blocklist --ozone-platform=x11
```

---

*Research compiled from web sources dated 2024-2025. Verify flag compatibility with your specific Electron/Chromium versions.*
