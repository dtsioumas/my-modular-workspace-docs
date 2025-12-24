# GPU Acceleration Troubleshooting Guide

**Date:** 2025-12-24
**Hardware:** NVIDIA GTX 960 (Maxwell GM206, 4GB VRAM)
**System:** NixOS + KDE Plasma 6 (X11)
**Related:** ADR-020, kwin-gpu-optimization.nix

---

## Overview

This guide helps troubleshoot GPU acceleration issues on the Shoshin desktop, specifically for:
- KWin compositor GPU rendering
- Firefox/browser hardware video decode (NVDEC)
- Video playback acceleration (VDPAU/VA-API)

---

## Quick Verification

### 1. Check NVIDIA Driver

```bash
nvidia-smi
# Expected: Driver loaded, GPU visible, 0-5% idle usage
```

### 2. Check Video Acceleration Support

```bash
vainfo
# Expected: NVIDIA driver, H264/H265 decode profiles listed

vdpauinfo
# Expected: NVIDIA VDPAU driver, decoder/mixer features listed
```

### 3. Check KWin Compositor

```bash
qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.compositingType
# Expected: "OpenGL"

glxinfo | grep "OpenGL renderer"
# Expected: "NVIDIA GeForce GTX 960"
```

### 4. Monitor GPU Usage During Video Playback

```bash
nvidia-smi dmon -s u
# Play YouTube video in Firefox
# Expected: GPU usage 60-80% during playback
```

---

## Common Issues

### Issue 1: Firefox Not Using GPU for Video Decode

**Symptoms:**
- High CPU usage (40-60%) during video playback
- `nvidia-smi` shows 0-5% GPU usage
- Videos stutter on 1080p+

**Diagnosis:**
```bash
# Check Firefox about:support
# Navigate to: about:support
# Search for: "Hardware Video Decoding"
# Expected: "Available" (not "Unavailable")
```

**Causes & Fixes:**

1. **Missing environment variables**
   ```bash
   # Check if set:
   echo $MOZ_DISABLE_RDD_SANDBOX  # Should be "1"
   echo $LIBVA_DRIVER_NAME  # Should be "nvidia"
   echo $VDPAU_DRIVER  # Should be "nvidia"
   ```

   **Fix:** Verify `modules/system/nvidia.nix` has these in `environment.variables`

2. **RDD Sandbox blocking NVDEC**
   ```bash
   # Check Firefox processes:
   ps aux | grep firefox
   # Should see: RDD process running
   ```

   **Fix:** Ensure `MOZ_DISABLE_RDD_SANDBOX = "1"` is set

3. **VA-API driver not found**
   ```bash
   vainfo
   # If error: "libva error: vaGetDriverNames() failed with unknown libva error"
   ```

   **Fix:** Install nvidia-vaapi-driver (should be in nvidia.nix)

### Issue 2: KWin Using CPU Instead of GPU

**Symptoms:**
- `kwin_x11` process using 15-30% CPU constantly
- Desktop feels laggy with compositor enabled
- Disabling compositor (Shift+Alt+F12) improves performance

**Diagnosis:**
```bash
# Check KWin rendering backend:
kreadconfig6 --file kwinrc --group Compositing --key Backend
# Expected: "OpenGL"

kreadconfig6 --file kwinrc --group Compositing --key GLPlatformInterface
# Expected: "glx" (for X11 with NVIDIA)
```

**Causes & Fixes:**

1. **Wrong OpenGL backend**
   ```bash
   # Check environment:
   echo $KWIN_COMPOSE  # Should be "O2" (OpenGL 2.0)
   ```

   **Fix:** Verify `modules/workspace/kwin-gpu-optimization.nix` sets `KWIN_COMPOSE = "O2"`

2. **CPU-intensive effects enabled**
   ```bash
   # Check enabled effects:
   kreadconfig6 --file kwinrc --group Plugins --key blurEnabled
   # Should be: false
   ```

   **Fix:** Verify kwin-gpu-optimization.nix disables blur, cube, wobbly, etc.

3. **Compositor forcing software rendering**
   ```bash
   # Check for software rendering fallback:
   glxinfo | grep "direct rendering"
   # Expected: "direct rendering: Yes"
   ```

   **Fix:** Ensure `openglIsUnsafe = false` in kwin config

### Issue 3: Video Playback Stuttering

**Symptoms:**
- Videos drop frames on 1080p/4K
- Audio/video out of sync
- GPU usage fluctuates 0-100%

**Diagnosis:**
```bash
# Monitor GPU memory and utilization:
watch -n 1 nvidia-smi

# Check for thermal throttling:
nvidia-smi --query-gpu=temperature.gpu --format=csv
# GTX 960 max: 98°C, throttle starts ~90°C
```

**Causes & Fixes:**

1. **Insufficient video memory bandwidth**
   - GTX 960 has only 128-bit memory bus
   - 4K HEVC can exceed bandwidth

   **Fix:** Limit to 1080p content, use h264 instead of h265

2. **NVDEC queue overrun**
   ```bash
   # Check dmesg for NVIDIA errors:
   dmesg | grep -i nvidia
   ```

   **Fix:** Reduce browser tab count, close other GPU apps

3. **Thermal throttling**
   - GPU temp > 85°C sustained

   **Fix:** Improve case airflow, clean GPU heatsink

### Issue 4: Compositor Crashes or Freezes

**Symptoms:**
- Desktop freezes for 5-10s randomly
- KWin crashes and restarts
- dmesg shows GPU hangs

**Diagnosis:**
```bash
# Check for GPU hangs:
dmesg | grep -i "gpu hang"

# Check KWin crash logs:
journalctl -u display-manager -n 100 | grep -i crash
```

**Causes & Fixes:**

1. **GPU memory leak**
   ```bash
   # Monitor VRAM usage:
   nvidia-smi --query-gpu=memory.used --format=csv
   # GTX 960 has 4GB, if >3.5GB used, leak likely
   ```

   **Fix:** Restart compositor periodically, reduce effects

2. **Driver bug with OpenGL 3.1+**
   - Maxwell (GTX 960) has known issues with some OpenGL 3.x features

   **Fix:** Use OpenGL 2.0 backend (`KWIN_COMPOSE = "O2"`)

3. **Conflicting OpenGL applications**
   ```bash
   # List OpenGL-using processes:
   lsof | grep /dev/nvidia
   ```

   **Fix:** Close other GL apps, use one at a time

---

## Performance Tuning

### Optimal Settings for GTX 960 + 1c/2t Desktop

**KWin Compositor:**
- Backend: OpenGL 2.0 (GLX for X11)
- Effects: Minimal (translucency, fade, slide only)
- Refresh rate: 60Hz (or 30Hz if too heavy)
- Triple buffering: Enabled
- VSync: Enabled

**Firefox:**
- WebRender: Enabled
- Hardware video decode: Enabled (NVDEC via RDD)
- GPU process: Enabled
- Process count: 1 (extreme CPU constraint)

**Expected GPU Usage:**
- Idle: 5-15% (compositor only)
- Video playback (1080p): 60-80%
- Browser with WebGL: 40-60%
- Combined (video + browser): 80-95%

**CPU Savings:**
- KWin: 15-30% → 5-10% (50% reduction)
- Video playback: 40-60% → 20-30% (30-50% reduction)
- Total desktop idle: 30-40% → 15-20%

---

## Monitoring Tools

### Real-time GPU Monitoring

```bash
# GPU utilization + memory
watch -n 1 nvidia-smi

# Detailed GPU stats (util, memory, power, temp)
nvidia-smi dmon -s ucmpt

# Per-process GPU usage
nvidia-smi pmon
```

### KWin Debugging

```bash
# Enable KWin debug output:
export KWIN_COMPOSE=O2
export KWIN_OPENGL_DEBUG=1
kwin_x11 --replace

# Check compositor status:
qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.active
```

### Firefox GPU Debugging

Navigate to: `about:support`

Check these sections:
- **Graphics → WebRender:** Should be "enabled"
- **Graphics → GPU Process:** Should show PID
- **Media → Hardware Video Decoding:** Should be "available"

---

## Emergency Fallbacks

### Disable Compositor Temporarily

```bash
# Via keyboard: Shift+Alt+F12
# Or via command:
qdbus org.kde.KWin /Compositor suspend
```

**Impact:**
- KWin CPU usage: 5-10% → 1-2%
- Trade-off: No window animations, tearing during video

### Force Software Rendering (Last Resort)

```bash
# Edit kwin-gpu-optimization.nix:
# Set: openglIsUnsafe = true;

# Rebuild and switch
sudo nixos-rebuild switch
```

**Impact:**
- GPU usage: 60-80% → 0%
- CPU usage: +20-30% (UNUSABLE on 1c/2t!)

### Switch to Lightweight Compositor

If KWin is too heavy even with optimizations:

```bash
# Phase 1B alternative: Use Picom instead
# See: ADR-020 Phase 1B section
```

---

## References

- NVIDIA GTX 960 Specs: https://www.nvidia.com/gtx-960
- KWin OpenGL: https://userbase.kde.org/KWin#OpenGL
- Firefox Hardware Acceleration: https://wiki.nixos.org/wiki/Accelerated_Video_Playback
- VDPAU/VA-API: https://wiki.archlinux.org/title/Hardware_video_acceleration

---

**Related Files:**
- `modules/workspace/kwin-gpu-optimization.nix`
- `modules/system/nvidia.nix`
- `home-manager/firefox.nix`
- ADR-020: GPU Offload Strategy
