# VA-API and VDPAU Hardware Video Acceleration Research

**Date:** 2025-12-30
**Hardware:** NVIDIA GTX 960 (Maxwell GM206, 4GB VRAM, Compute Capability 5.2)
**System:** NixOS 25.05 + KDE Plasma 6 (X11)
**Confidence Level:** Band C (0.88)

---

## Executive Summary

This research document provides comprehensive configuration guidance for enabling hardware video acceleration on NixOS with an NVIDIA GTX 960 (Maxwell architecture). The document covers both **VDPAU** (NVIDIA's native video decode API) and **VA-API** (via the third-party `nvidia-vaapi-driver`), with specific configuration for Firefox, Chromium-based browsers, Electron apps, and mpv.

### Key Findings

| Technology | Status | Recommended For | Limitations |
|------------|--------|-----------------|-------------|
| **VDPAU** | Native NVIDIA support | mpv, local media players | Not supported in browsers, limited on Wayland |
| **VA-API (nvidia-vaapi-driver)** | Third-party driver | Firefox, Brave, mpv | Chrome not supported, requires `NVD_BACKEND=direct` |

### GTX 960 Codec Support (NVDEC)

| Codec | Hardware Decode | Notes |
|-------|-----------------|-------|
| H.264 | Full | Native hardware decode |
| HEVC (H.265) | Full | Main & Main 10 profiles |
| VP9 | Full | Native hardware decode |
| VP8 | Full | Native hardware decode |
| MPEG-2 | Full | Native hardware decode |
| VC-1 | Full | Native hardware decode |
| **AV1** | **Not Supported** | Added in Ampere generation |

---

## Part 1: VDPAU Configuration for NVIDIA

### 1.1 Overview

VDPAU (Video Decode and Presentation API for Unix) is NVIDIA's native hardware video acceleration API. For GTX 960, VDPAU provides excellent support for local media playback via mpv and other media players.

**Limitations:**
- VDPAU does not support 10-bit video properly
- 8-bit HEVC can be buggy with some NVIDIA driver versions
- Not supported by any major web browsers (except GNOME Web)
- Cannot detect correct driver on Wayland (requires `VDPAU_DRIVER` env var)

### 1.2 NixOS System Configuration

```nix
# File: hosts/shoshin/nixos/modules/system/nvidia.nix

{ config, pkgs, lib, ... }: {
  # Enable graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For 32-bit applications (Steam, Wine)

    # VDPAU and VA-API packages
    extraPackages = with pkgs; [
      vaapiVdpau           # VDPAU backend for VA-API
      libvdpau-va-gl       # VA-API backend using VDPAU
      nvidia-vaapi-driver  # VA-API implementation using NVDEC
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Environment variables
  environment.variables = {
    # VDPAU driver (NVIDIA native)
    VDPAU_DRIVER = "nvidia";

    # Important for Wayland: VDPAU cannot auto-detect driver
    # This ensures the correct driver is always used
  };

  # Required kernel parameter for nvidia-vaapi-driver
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nouveau.modeset=0"
  ];
}
```

### 1.3 Verification Commands

```bash
# Verify VDPAU support and view supported codecs
nix shell nixpkgs#vdpauinfo -c vdpauinfo

# Expected output for GTX 960:
# VDPAU API version: 1
# Information string: NVIDIA VDPAU Driver Shared Library
# Video surface:
#   - MPEG1, MPEG2, H264, HEVC (Main/Main 10), VP9 (8-bit)
# Decoder capabilities:
#   - H264 up to 4096x4096
#   - HEVC up to 8192x8192
```

---

## Part 2: VA-API Configuration (nvidia-vaapi-driver)

### 2.1 Overview

`nvidia-vaapi-driver` (by elFarto) is a third-party VA-API implementation that uses NVIDIA's NVDEC for hardware video decoding. This is essential for browser hardware acceleration on NVIDIA GPUs.

**Key Points:**
- Uses NVDEC hardware decoder (not VDPAU)
- Requires `nvidia-drm.modeset=1` kernel parameter
- EGL backend broken on driver 525+ - **use direct backend instead**
- Does NOT support Chrome/Chromium (only Firefox and some Electron apps)

### 2.2 Environment Variables

```nix
# File: hosts/shoshin/nixos/modules/system/nvidia.nix

environment.variables = {
  # VA-API driver name
  LIBVA_DRIVER_NAME = "nvidia";

  # Backend selection (CRITICAL - EGL is broken on driver 525+)
  # Options: "direct" (recommended) or "egl"
  NVD_BACKEND = "direct";

  # Firefox-specific: Disable RDD sandbox to allow NVDEC access
  MOZ_DISABLE_RDD_SANDBOX = "1";

  # VDPAU driver (for fallback)
  VDPAU_DRIVER = "nvidia";
};
```

### 2.3 Optional Environment Variables

```bash
# For debugging - set NVD_LOG=1 to enable logging
export NVD_LOG=1

# Limit maximum decode instances (useful for low VRAM GPUs)
# GTX 960 has 4GB VRAM, default is usually fine
export NVD_MAX_INSTANCES=8

# For multi-GPU systems - specify which DRM node to use
export NVD_GPU=/dev/dri/card0
```

### 2.4 Verification Commands

```bash
# Verify VA-API support
nix shell nixpkgs#libva-utils -c vainfo

# Expected output for GTX 960 with nvidia-vaapi-driver:
# libva info: VA-API version 1.20.0
# libva info: Trying to open /run/opengl-driver/lib/dri/nvidia_drv_video.so
# libva info: Found init function __vaDriverInit_1_20
# vainfo: VA-API version: 1.20 (libva 2.20.0)
# vainfo: Driver version: VA-API NVDEC driver
# vainfo: Supported profile and entrypoints
#       VAProfileH264Main               : VAEntrypointVLD
#       VAProfileH264High               : VAEntrypointVLD
#       VAProfileHEVCMain               : VAEntrypointVLD
#       VAProfileHEVCMain10             : VAEntrypointVLD
#       VAProfileVP9Profile0            : VAEntrypointVLD

# Monitor GPU usage during video playback
nvidia-smi dmon -s u

# Per-process GPU usage
nvidia-smi pmon
```

---

## Part 3: Firefox Configuration

### 3.1 Overview

Firefox supports VA-API hardware video decoding on Linux. For NVIDIA GPUs, this requires `nvidia-vaapi-driver` and specific about:config settings.

**Firefox Version Notes:**
- Firefox < 97: Requires `media.rdd-ffmpeg.enabled = true`
- Firefox < 137: Requires `media.ffmpeg.vaapi.enabled = true`
- Firefox >= 137: Requires `media.hardware-video-decoding.force-enabled = true`

### 3.2 Home-Manager Configuration

```nix
# File: home-manager/modules/apps/firefox.nix

{ config, pkgs, lib, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;

    profiles.default = {
      settings = {
        # === Hardware Video Decoding (NVIDIA GTX 960) ===
        # Version-aware configuration

        # For Firefox < 137 (legacy setting)
        "media.ffmpeg.vaapi.enabled" = true;

        # For Firefox >= 137 (new setting)
        "media.hardware-video-decoding.force-enabled" = true;
        "media.hardware-video-decoding.enabled" = true;

        # RDD (Remote Data Decoder) process for secure decoding
        "media.rdd-ffmpeg.enabled" = true;
        "media.rdd-process.enabled" = true;

        # Enable VP9 hardware decode (supported on GTX 960)
        "media.navigator.mediadatadecoder_vpx_enabled" = true;

        # === WebRender and GPU Acceleration ===
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "layers.acceleration.force-enabled" = true;

        # X11/EGL for NVIDIA (REQUIRED)
        "gfx.x11-egl.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;

        # GPU compositing
        "layers.gpu-process.enabled" = true;
        "layers.gpu-process.force-enabled" = true;

        # Canvas acceleration
        "gfx.canvas.accelerated" = true;

        # WebGL support
        "webgl.force-enabled" = true;
        "webgl.disabled" = false;
      };
    };
  };

  # Environment variables for Firefox NVIDIA acceleration
  home.sessionVariables = {
    # VA-API driver
    LIBVA_DRIVER_NAME = "nvidia";

    # Direct backend for nvidia-vaapi-driver (EGL broken on 525+)
    NVD_BACKEND = "direct";

    # Disable RDD sandbox for NVDEC access
    MOZ_DISABLE_RDD_SANDBOX = "1";

    # X11 EGL for NVIDIA
    MOZ_X11_EGL = "1";

    # Enable WebRender
    MOZ_WEBRENDER = "1";

    # X11 smooth scrolling
    MOZ_USE_XINPUT2 = "1";

    # VDPAU fallback
    VDPAU_DRIVER = "nvidia";
  };
}
```

### 3.3 Version-Aware Configuration (Recommended)

For a cleaner configuration that adapts to Firefox version:

```nix
programs.firefox.profiles.default.settings = let
  ffVersion = config.programs.firefox.package.version;
in {
  # Version-aware hardware decoding settings
  "media.ffmpeg.vaapi.enabled" = lib.versionOlder ffVersion "137.0.0";
  "media.hardware-video-decoding.force-enabled" = lib.versionAtLeast ffVersion "137.0.0";
  "media.rdd-ffmpeg.enabled" = lib.versionOlder ffVersion "97.0.0";

  # Always required
  "gfx.x11-egl.force-enabled" = true;
  "widget.dmabuf.force-enabled" = true;
};
```

### 3.4 Verification

1. Open `about:support` in Firefox
2. Look for "Hardware Video Decoding" - should show "available"
3. Check "WebRender" - should show "enabled"
4. Check "GPU Process" - should show a PID

```bash
# Monitor Firefox GPU usage during video playback
nvidia-smi pmon

# Expected: Firefox process with 'C' in Type column
# and decode engine (Dec) usage during playback
```

---

## Part 4: Chromium/Brave Configuration

### 4.1 Overview

**IMPORTANT:** Chrome/Chromium does NOT support nvidia-vaapi-driver. There are experimental flags but they are disabled by default and not recommended for production use.

However, Brave and some Chromium variants may work with limited hardware acceleration.

### 4.2 Current Status (2025)

- The NVIDIA VA-API drivers do not officially support Chromium
- There is a feature switch `--enable-features=VaapiOnNvidiaGPUs` for testing
- GPU rendering (WebGL, canvas) works, but video decoding is limited
- Best approach: Use GPU rasterization and WebGL, accept software video decode

### 4.3 Home-Manager Configuration (Brave)

```nix
# File: home-manager/modules/apps/brave.nix

{ pkgs, ... }: {
  home.packages = [
    (pkgs.brave.override {
      commandLineArgs = [
        # === GPU Rendering (Works on NVIDIA) ===
        "--use-gl=desktop"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-webgl"
        "--enable-zero-copy"

        # === VA-API Flags (Experimental - May Not Work) ===
        # These flags attempt VA-API but Chromium may ignore them
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks,Vulkan,CanvasOopRasterization,UseSkiaRenderer"

        # For NVIDIA (experimental, disabled by default)
        # "--enable-features=VaapiOnNvidiaGPUs"

        # === Platform Configuration (X11) ===
        "--ozone-platform=x11"

        # === Memory Optimizations ===
        "--js-flags=--max-old-space-size=512"
        "--process-per-site"
        "--renderer-process-limit=4"

        # === Disable Problematic Features ===
        "--disable-features=UseChromeOSDirectVideoDecoder"
        "--disable-background-networking"
      ];
    })
  ];
}
```

### 4.4 Updated Flags (2024-2025)

The VA-API related flags have been renamed:

```bash
# Old flags (deprecated):
--enable-features=VaapiVideoDecoder,VaapiVideoEncoder

# New flags (2024+):
--enable-features=AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder

# For NVIDIA specifically:
--enable-features=AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiOnNvidiaGPUs
```

### 4.5 Verification

```bash
# Check flags are recognized
# Open: brave://version or chrome://version

# Check hardware acceleration status
# Open: brave://gpu or chrome://gpu

# Check media internals during video playback
# Open: brave://media-internals or chrome://media-internals
```

**Note:** Even with correct flags, NVIDIA video decode in Chromium likely won't work. Focus on GPU rasterization and WebGL instead.

---

## Part 5: Electron Apps Configuration

### 5.1 Overview

Electron apps (VSCodium, Discord, Slack, etc.) can use GPU acceleration for rendering. Video decode support varies by application.

### 5.2 General Electron Flags

```nix
# File: home-manager/modules/apps/electron-apps.nix

{ pkgs, ... }:
let
  # Common Electron GPU flags
  electronFlags = [
    "--ignore-gpu-blocklist"
    "--enable-gpu-rasterization"
    "--enable-gpu"
    "--enable-webgl"
    "--use-gl=desktop"
    "--ozone-platform=x11"
    "--enable-features=Vulkan,UseSkiaRenderer,CanvasOopRasterization"
    "--enable-zero-copy"
  ];

  electronFlagsStr = builtins.concatStringsSep " " electronFlags;
in {
  # Example: VSCodium with GPU acceleration
  home.packages = [
    (pkgs.vscodium.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/codium \
          --add-flags "${electronFlagsStr}"
      '';
    }))
  ];

  # Or use environment variable for all Electron apps
  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "x11";
  };
}
```

### 5.3 Chezmoi Template (Alternative)

```bash
# File: dotfiles/private_dot_config/electron-flags.conf.tmpl

# Electron GPU acceleration flags (NVIDIA GTX 960)
--ignore-gpu-blocklist
--enable-gpu-rasterization
--enable-gpu
--enable-webgl
--use-gl=desktop
--ozone-platform=x11
--enable-features=Vulkan,UseSkiaRenderer,CanvasOopRasterization
--enable-zero-copy
--enable-native-gpu-memory-buffers
```

---

## Part 6: mpv Configuration

### 6.1 Overview

mpv supports both VDPAU and VA-API for hardware video decoding. For NVIDIA GTX 960, VDPAU is the more reliable option for local media playback.

### 6.2 Recommended Configuration

```nix
# File: home-manager/modules/apps/mpv.nix

{ config, pkgs, ... }: {
  programs.mpv = {
    enable = true;

    config = {
      # === Hardware Decoding ===
      # Options: auto, auto-safe, auto-copy, vaapi, vdpau, nvdec
      #
      # For GTX 960 with NVIDIA proprietary driver:
      # - vdpau: Best for local playback, native NVIDIA support
      # - vaapi: Works via nvidia-vaapi-driver, better for browser-like use
      # - auto-safe: Tries safe options first (recommended)
      # - auto-copy: Always copies frames back to CPU (safer, slightly slower)

      hwdec = "auto-safe";  # Safe default that works on most systems

      # Alternative: Force VDPAU for NVIDIA
      # hwdec = "vdpau";

      # Alternative: Force VA-API (via nvidia-vaapi-driver)
      # hwdec = "vaapi";

      # === Video Output ===
      # For NVIDIA proprietary driver:
      vo = "gpu";           # Modern GPU-based output
      # vo = "vdpau";       # VDPAU-specific output (alternative)

      # GPU API (Vulkan or OpenGL)
      gpu-api = "vulkan";   # Vulkan is more efficient on NVIDIA
      # gpu-api = "opengl"; # Fallback if Vulkan has issues

      # GPU context
      gpu-context = "x11vk"; # X11 with Vulkan
      # gpu-context = "x11egl"; # X11 with EGL (alternative)

      # === Performance ===
      # Interpolation for smooth playback
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";

      # Cache settings
      cache = true;
      cache-secs = 10;

      # === Profiles ===
      # These can be selected with --profile=<name>
    };

    profiles = {
      # High-quality profile (uses GPU heavily)
      "gpu-hq" = {
        scale = "ewa_lanczossharp";
        cscale = "ewa_lanczossharp";
        dscale = "mitchell";
        correct-downscaling = true;
        linear-downscaling = true;
        sigmoid-upscaling = true;
        deband = true;
      };

      # VDPAU-specific profile
      "vdpau" = {
        hwdec = "vdpau";
        vo = "gpu";
      };

      # VA-API profile (uses nvidia-vaapi-driver)
      "vaapi" = {
        hwdec = "vaapi";
        vo = "gpu";
      };

      # Software decode (fallback for problematic files)
      "sw" = {
        hwdec = "no";
      };
    };
  };
}
```

### 6.3 hwdec Options Explained

| Option | Description | Use Case |
|--------|-------------|----------|
| `auto` | Auto-detect best hardware decoder | General use |
| `auto-safe` | Only use safe hardware decoders | Recommended default |
| `auto-copy` | Hardware decode with copy-back | Maximum compatibility |
| `vdpau` | Force VDPAU (NVIDIA native) | Best for NVIDIA local playback |
| `vaapi` | Force VA-API | When VA-API is preferred |
| `nvdec` | NVIDIA NVDEC directly | Alternative to vdpau |
| `no` | Disable hardware decode | Debugging/problematic files |

### 6.4 Known Limitations

- VDPAU does not support 10-bit video well
- 8-bit HEVC can be buggy with some NVIDIA drivers
- Some ffmpeg filters don't work with hardware decoding
- Use `hwdec=auto-copy` if you need filters like `hue`

### 6.5 Verification

```bash
# Test hardware acceleration
mpv --hwdec=auto --msg-level=vo=debug video.mp4

# Check which decoder is being used
# Look for lines like:
# [vo/gpu] Using hardware decoding (vdpau).
# [vo/gpu] Using hardware decoding (vaapi).

# Monitor GPU usage during playback
nvidia-smi dmon -s u
```

---

## Part 7: Complete NixOS System Configuration

### 7.1 Consolidated nvidia.nix

```nix
# File: hosts/shoshin/nixos/modules/system/nvidia.nix

{ config, pkgs, lib, ... }: {
  # ====================================
  # NVIDIA GTX 960 Configuration
  # ====================================

  # Enable graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    # VA-API and VDPAU packages
    extraPackages = with pkgs; [
      vaapiVdpau           # VDPAU backend for VA-API
      libvdpau-va-gl       # VA-API backend using VDPAU
      nvidia-vaapi-driver  # VA-API implementation using NVDEC
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # NVIDIA driver
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;  # GTX 960 (Maxwell) - use proprietary driver
    nvidiaPersistenced = true;
    forceFullCompositionPipeline = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Kernel parameters
  boot.kernelParams = [
    "nvidia-drm.modeset=1"  # REQUIRED for nvidia-vaapi-driver
    "nouveau.modeset=0"
  ];

  boot.blacklistedKernelModules = ["nouveau"];

  # Environment variables for video acceleration
  environment.variables = {
    # GLX vendor
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Vulkan ICD
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";

    # ===== Video Acceleration =====
    # VDPAU (native NVIDIA)
    VDPAU_DRIVER = "nvidia";

    # VA-API (via nvidia-vaapi-driver)
    LIBVA_DRIVER_NAME = "nvidia";

    # Direct backend for nvidia-vaapi-driver (EGL broken on 525+)
    NVD_BACKEND = "direct";

    # Firefox NVDEC access
    MOZ_DISABLE_RDD_SANDBOX = "1";

    # X11/EGL for Firefox
    MOZ_X11_EGL = "1";
  };

  # Utilities
  environment.systemPackages = with pkgs; [
    glxinfo
    vulkan-tools
    glmark2
    ffmpeg-full
    libva-utils   # vainfo
    vdpauinfo     # vdpauinfo
  ];

  # Suspend/resume services
  systemd.services.nvidia-suspend.enable = true;
  systemd.services.nvidia-resume.enable = true;
  systemd.services.nvidia-hibernate.enable = true;
}
```

### 7.2 Hardware Profile Update

```nix
# File: home-manager/modules/profiles/config/hardware/shoshin.nix
# Add/update the display section:

display = {
  protocol = "x11";
  compositor = "kde";

  # Video acceleration
  vaapi = true;
  vdpau = true;
  vulkan = true;

  # VA-API backend for nvidia-vaapi-driver
  vaapi_backend = "direct";  # Not "egl" - broken on 525+

  # Browser-specific
  webrender = true;
  gpuAcceleration = true;
};
```

---

## Part 8: Verification Commands Summary

### 8.1 System-Level Verification

```bash
# Check NVIDIA driver is loaded
nvidia-smi

# Check VA-API support
nix shell nixpkgs#libva-utils -c vainfo

# Check VDPAU support
nix shell nixpkgs#vdpauinfo -c vdpauinfo

# Check environment variables
echo $LIBVA_DRIVER_NAME  # Should be: nvidia
echo $VDPAU_DRIVER       # Should be: nvidia
echo $NVD_BACKEND        # Should be: direct

# Check nvidia-drm.modeset
cat /sys/module/nvidia_drm/parameters/modeset  # Should be: Y
```

### 8.2 Browser Verification

```bash
# Firefox
# Open: about:support
# Check: "Hardware Video Decoding" = available
# Check: "WebRender" = enabled by user

# Brave/Chromium
# Open: brave://gpu or chrome://gpu
# Check: "Video Decode" status
# Open: brave://media-internals for playback details
```

### 8.3 Real-Time Monitoring

```bash
# GPU utilization (overall)
watch -n 1 nvidia-smi

# GPU process monitoring (per-process)
nvidia-smi pmon

# GPU decoder usage (decode engine)
nvidia-smi dmon -s u

# Expected during video playback:
# - Dec column should show usage
# - Firefox/mpv should appear in pmon with 'C' type
```

---

## Part 9: Troubleshooting

### 9.1 Common Issues

#### Issue: vainfo shows "libva error: init failed"

**Causes:**
1. `nvidia-drm.modeset=1` not set
2. nvidia-vaapi-driver not installed
3. Using `hardware.nvidia.open = true` (not supported for Maxwell)

**Solutions:**
```bash
# Check modeset is enabled
cat /sys/module/nvidia_drm/parameters/modeset

# If 'N', add to kernel params and rebuild:
boot.kernelParams = ["nvidia-drm.modeset=1"];

# Ensure open driver is disabled (Maxwell not supported)
hardware.nvidia.open = false;
```

#### Issue: Firefox not using hardware decode

**Causes:**
1. Wrong Firefox version settings
2. RDD sandbox blocking NVDEC
3. X11/EGL not enabled

**Solutions:**
```bash
# Check Firefox version and apply correct settings
# For Firefox >= 137:
"media.hardware-video-decoding.force-enabled" = true;

# Ensure environment variables are set
echo $MOZ_DISABLE_RDD_SANDBOX  # Should be: 1
echo $MOZ_X11_EGL              # Should be: 1
```

#### Issue: Video playback causes high CPU usage

**Causes:**
1. Hardware decode not working
2. Wrong codec (AV1 not supported on GTX 960)

**Solutions:**
```bash
# Monitor which decoder is being used
nvidia-smi pmon

# Disable AV1 in Firefox (not supported on GTX 960)
"media.av1.enabled" = false;

# Force software decode for problematic videos
mpv --hwdec=no video.mp4
```

### 9.2 Debugging

```bash
# Enable nvidia-vaapi-driver logging
export NVD_LOG=1
firefox

# Check Firefox about:support for hardware info

# Check mpv verbose output
mpv --hwdec=auto --msg-level=vo=debug video.mp4
```

---

## Part 10: Performance Expectations

### 10.1 CPU Savings with Hardware Decode

| Scenario | Without HW Decode | With HW Decode | Savings |
|----------|-------------------|----------------|---------|
| YouTube 1080p H.264 | 40-60% CPU | 5-15% CPU | 30-50% |
| YouTube 1080p VP9 | 50-70% CPU | 10-20% CPU | 40-50% |
| Local 1080p HEVC | 60-80% CPU | 10-20% CPU | 50-60% |
| 4K HEVC | May stutter | Smooth (GTX 960 limit) | N/A |

### 10.2 GTX 960 Limitations

- **128-bit memory bus:** May struggle with 4K HEVC
- **4GB VRAM:** Adequate for video decode + desktop
- **No AV1 support:** Falls back to software decode
- **Maxwell architecture:** Some advanced features missing

### 10.3 Expected GPU Usage

```
Idle (compositor only): 5-15%
Video playback (1080p): 30-50%
Browser with WebGL: 20-40%
Video + browser combined: 50-70%
```

---

## Sources

### NixOS Documentation
- [NixOS Wiki - Accelerated Video Playback](https://wiki.nixos.org/wiki/Accelerated_Video_Playback)
- [NixOS Wiki - Graphics](https://wiki.nixos.org/wiki/Graphics)
- [NixOS Discourse - Firefox Hardware Acceleration Nvidia](https://discourse.nixos.org/t/firefox-hardware-acceleration-nvidia/52004)
- [NixOS Discourse - NVIDIA Hardware Video Acceleration](https://discourse.nixos.org/t/nvidia-hardware-video-acceleration-on-nixos-fresh-install/63434)

### NVIDIA VA-API Driver
- [GitHub - elFarto/nvidia-vaapi-driver](https://github.com/elFarto/nvidia-vaapi-driver)
- [nvidia-vaapi-driver README](https://github.com/elFarto/nvidia-vaapi-driver/blob/master/README.md)
- [Phoronix - NVIDIA-VAAPI-Driver 0.0.8 Direct Backend](https://www.phoronix.com/news/NVIDIA-VAAPI-Driver-0.0.8)

### Firefox Configuration
- [Firefox 137 NVIDIA Hardware Decoding](https://powersnail.com/2025/firefox-137-nvidia-hardware-decoding/)
- [Fedora Wiki - Firefox Hardware Acceleration](https://fedoraproject.org/wiki/Firefox_Hardware_acceleration)
- [Mozilla Bug - Implement ffmpeg/VAAPI Video Playback](https://bugzilla.mozilla.org/show_bug.cgi?id=1619523)

### Chromium/Electron
- [Chromium Docs - VA-API](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md)
- [Arch Wiki - Chromium](https://wiki.archlinux.org/title/Chromium)
- [Chrome Flags 2024 Update - Hardware Acceleration](https://dev.to/archerallstars/chrome-flags-latest-2024-update-web-browser-video-hardware-acceleration-on-linux-34k1)
- [Linux Uprising - Hardware Accelerated Video in Chrome/Brave](https://www.linuxuprising.com/2021/01/how-to-enable-hardware-accelerated.html)

### mpv Configuration
- [mpv Manual](https://mpv.io/manual/stable/)
- [Gentoo Wiki - mpv](https://wiki.gentoo.org/wiki/Mpv)
- [Arch Wiki - Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

### NVIDIA Hardware Specs
- [NVIDIA NVDEC - Wikipedia](https://en.wikipedia.org/wiki/Nvidia_NVDEC)
- [NVIDIA PureVideo - Wikipedia](https://en.wikipedia.org/wiki/Nvidia_PureVideo)
- [NVIDIA NVDEC Application Note](https://docs.nvidia.com/video-technologies/video-codec-sdk/12.0/nvdec-application-note/index.html)

---

## Document Status

**Status:** Complete
**Last Updated:** 2025-12-30T05:30:00+02:00
**Next Review:** When Firefox 140+ releases or NVIDIA driver changes

---

**Related Documents:**
- `docs/nixos/GPU_ACCELERATION_TROUBLESHOOTING.md`
- `docs/researches/2025-12-22_agents_gpu_acceleration.md`
- `docs/researches/2025-12-15-gpu-optimization-prerequisites-status.md`
- `ADR-020-GPU_OFFLOAD_STRATEGY_FOR_CPU_CONSTRAINED_DESKTOP.md`
