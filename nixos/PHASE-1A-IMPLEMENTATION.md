# Phase 1A Implementation Summary
**Date:** 2025-12-24
**Status:** ✅ Complete - Ready for Testing
**Related:** ADR-020 (GPU Offload Strategy for CPU-Constrained Desktop)

---

## Overview

Phase 1A implements conservative optimizations to maximize GPU usage and reduce CPU/RAM overhead for the extreme 1c/2t desktop scenario.

**Goal:** Test desktop viability with 1 core/2 threads allocated (6 cores to K8s VM)

---

## Modules Created

### 1. KWin GPU Optimization
**File:** `modules/workspace/kwin-gpu-optimization.nix`

**Changes:**
- Force OpenGL 2.0 backend (most compatible with GTX 960)
- Disable CPU-intensive effects (blur, cube, wobbly windows, desktop grid)
- Keep GPU-only effects (translucency, fade, slide)
- Environment variables for GPU preference
- Emergency compositor toggle scripts

**Expected Impact:**
- KWin CPU usage: 15-30% → 5-10% (50% reduction)
- Maintains KDE Plasma integration
- User can disable compositor entirely (Shift+Alt+F12) if needed

---

### 2. Enhanced NVIDIA Video Acceleration
**File:** `modules/system/nvidia.nix` (modified)

**Changes:**
- Enabled NVIDIA Persistence Daemon (`nvidiaPersistenced = true`)
- Added video acceleration environment variables:
  - `VDPAU_DRIVER = "nvidia"`
  - `LIBVA_DRIVER_NAME = "nvidia"`
  - `MOZ_DISABLE_RDD_SANDBOX = "1"` (Firefox NVDEC access)
  - `NVD_BACKEND = "direct"`
  - `MOZ_X11_EGL = "1"`

**Expected Impact:**
- Video playback CPU usage: 40-60% → 20-30% (30-50% savings)
- Firefox/browser video fully GPU-accelerated
- Reduced driver initialization latency

---

### 3. Firefox Extreme CPU Optimization
**Files:**
- `modules/workspace/firefox-cpu-constrained.nix` (documentation)
- `home-manager/firefox.nix` (modified)

**⚠️ WARNING: Security Features Disabled!**

**Changes:**
- `fission.autostart = false` - DISABLES site isolation (security risk!)
- `dom.ipc.processCount = 1` - Single content process
- `dom.ipc.processCount.webIsolated = 1` - Single isolated process
- `browser.cache.memory.capacity = 65536` - 64MB cache (vs 256MB)
- `browser.sessionhistory.max_entries = 5` - Minimal history

**Security Risks:**
- Vulnerable to malicious websites
- Spectre-like attacks possible
- One tab crash may kill entire browser

**Required Mitigations:**
- uBlock Origin installed (already configured)
- NoScript recommended
- Browse only trusted sites
- Enforce 3-tab maximum

**Expected Impact:**
- Process count: 8+ → 2-3 processes
- RAM: 3.5GB → 2.0GB (1.5GB savings)
- CPU: Reduced context switching overhead

---

### 4. KDE Service Reduction
**File:** `modules/workspace/kde-service-reduction.nix`

**System Services Disabled:**
- `power-profiles-daemon` (conflicts with performance governor)
- `ModemManager` (no mobile broadband)
- `accounts-daemon` (GNOME-specific)

**User Services Already Disabled** (in home-manager):
- `kde-baloo` (file indexing) - 200-500MB
- `plasma-kactivitymanagerd` (activities) - 100-200MB

**Expected Impact:**
- RAM savings: 500MB
- Background CPU: 5-10% reduction

---

### 5. CPU Affinity Systemd Slices
**File:** `modules/system/cpu-affinity-slices.nix`

**Slices Created:**
- `desktop.slice` - CPU threads 0-1, 8GB RAM max
- `virtualization.slice` - CPU threads 2-7, 8GB RAM max
- `desktop-user.slice` - User processes on threads 0-1

**Verification Tools:**
- `check-cpu-affinity` - Check slice assignments
- `cpu-usage-per-core` - Monitor per-core usage (mpstat)

**Expected Impact:**
- Strict CPU isolation (prevents thrashing)
- Desktop guaranteed 2 threads
- K8s VM guaranteed 6 threads

---

### 6. Zram Configuration
**File:** `modules/system/zram.nix` (already optimal)

**Current Settings:**
- Algorithm: lz4 (3.7:1 compression, low CPU overhead)
- memoryPercent: 100% (15GB zram device)
- Effective capacity: ~55GB compressed
- Swappiness: 67 (set in aggressive-ram-optimization.nix)

**Status:** ✅ Already configured optimally, no changes needed

---

## Expected Total Impact

### RAM Reduction
| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| Firefox | 3.5GB | 2.0GB | 1.5GB |
| KDE Services | 1.2GB | 0.7GB | 0.5GB |
| **Total** | **11GB** | **8.5GB** | **2.5GB** |

### CPU Reduction
| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| KWin compositor | 15-30% | 5-10% | 10-20% |
| Video playback | 40-60% | 20-30% | 20-30% |
| Firefox processes | High | Medium | 10-15% |
| Background services | 10-15% | 5-10% | 5% |

### GPU Utilization
| Workload | Before | After | Increase |
|----------|--------|-------|----------|
| Idle | 5-15% | 5-15% | 0% |
| Video playback | 30-40% | 60-80% | +40% |
| Browser (WebGL) | 40-50% | 50-70% | +15% |

---

## How to Enable Phase 1A

### Option 1: Import All Modules (Recommended)

Add to `/etc/nixos/configuration.nix`:

```nix
imports = [
  # ... existing imports ...

  # Phase 1A: GPU Offload + CPU/RAM Optimization
  ./modules/workspace/kwin-gpu-optimization.nix
  ./modules/workspace/kde-service-reduction.nix
  ./modules/workspace/firefox-cpu-constrained.nix  # Documentation only
  ./modules/system/cpu-affinity-slices.nix
];
```

### Option 2: Selective Import

Import only the modules you want to test:

```nix
# Start with just GPU optimizations
imports = [
  ./modules/workspace/kwin-gpu-optimization.nix
];
```

### Rebuild System

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos
sudo nixos-rebuild switch --flake .#shoshin
```

### Rebuild Home Manager

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin
```

---

## Testing Phase 1A (Week 1)

### Day 1-2: GPU Acceleration
1. Rebuild NixOS + home-manager
2. Reboot system
3. Verify NVIDIA video acceleration:
   ```bash
   vainfo  # Should show nvidia driver
   vdpauinfo  # Should show NVIDIA capabilities
   ```
4. Test Firefox video playback (YouTube):
   ```bash
   nvidia-smi dmon -s u  # Should show GPU usage 60-80%
   ```
5. Check KWin compositor CPU usage:
   ```bash
   htop  # Find kwin_x11 process, should be 5-10% CPU
   ```

### Day 3-4: RAM Optimization
6. Monitor RAM usage:
   ```bash
   free -h  # Should show ~8.5GB used (vs 11GB before)
   ```
7. Check Firefox RAM:
   ```bash
   ps aux | grep firefox | awk '{sum+=$6} END {print sum/1024 " MB"}'
   # Should show ~2GB (vs 3.5GB before)
   ```
8. Verify KDE services disabled:
   ```bash
   systemctl status power-profiles-daemon  # Should be inactive
   systemctl --user status kde-baloo  # Should be disabled
   ```

### Day 5-7: CPU Affinity
9. Verify CPU affinity:
   ```bash
   check-cpu-affinity  # Desktop on CPUs 0-1, VMs on 2-7
   ```
10. Monitor per-core CPU usage:
    ```bash
    cpu-usage-per-core  # CPUs 0-1 should be heavily loaded
    ```
11. Test desktop usability:
    - Open 3 tabs in Firefox
    - Open VSCodium
    - Open Kitty terminal
    - Switch between applications
    - **Expected:** 5-10s lag, but usable

---

## Success Criteria

### ✅ Phase 1A Successful If:
1. Desktop is **usable** for light tasks (browsing 2-3 tabs, text editing)
2. Video playback is smooth (GPU decode working)
3. RAM usage reduced to ~8.5GB
4. No crashes or system hangs
5. CPU affinity working (desktop on 0-1, VMs on 2-7)

### ❌ Abort Phase 1A If:
1. Desktop becomes **unusable** (>10s freezes, frequent crashes)
2. Applications fail to start
3. System hangs during normal use
4. GPU acceleration not working

### Next Steps After Phase 1A:
- **If successful:** Continue to Phase 1B (optional Picom switch)
- **If marginal:** Stay on Phase 1A, skip Phase 2
- **If failed:** Abort, recommend 2 cores/4 threads allocation instead

---

## Rollback Instructions

### If System Becomes Unusable:

1. **Boot into previous generation:**
   ```bash
   # At GRUB menu, select previous NixOS generation
   ```

2. **Or revert specific modules:**
   ```bash
   cd /etc/nixos
   # Comment out problematic imports
   sudo nixos-rebuild switch
   ```

3. **Emergency compositor disable:**
   ```bash
   # Press Shift+Alt+F12 in KDE
   # Or run: qdbus org.kde.KWin /Compositor suspend
   ```

4. **Restore Firefox security:**
   Edit `home-manager/firefox.nix`:
   ```nix
   "fission.autostart" = true;  # Re-enable site isolation
   "dom.ipc.processCount" = 4;  # Restore 4 processes
   ```
   ```bash
   home-manager switch
   ```

---

## Documentation

**Created Files:**
- `modules/workspace/kwin-gpu-optimization.nix`
- `modules/workspace/kde-service-reduction.nix`
- `modules/workspace/firefox-cpu-constrained.nix`
- `modules/system/cpu-affinity-slices.nix`
- `PHASE-1A-IMPLEMENTATION.md` (this file)

**Modified Files:**
- `modules/system/nvidia.nix` (video acceleration variables)
- `home-manager/firefox.nix` (extreme CPU optimization)

**Documentation Files:**
- `/etc/firefox-cpu-optimization-warning.txt`
- `/etc/kde-service-reduction-info.txt`
- `/etc/cpu-affinity-info.txt`

**Related:**
- ADR-020: GPU Offload Strategy for CPU-Constrained Desktop

---

## Confidence Assessment

| Optimization | Confidence | Risk | Reversibility |
|--------------|-----------|------|---------------|
| NVIDIA video accel | 0.90 | Low | Easy |
| KWin GPU optimization | 0.85 | Low | Easy |
| Firefox CPU reduction | 0.72 | **High (Security)** | Easy |
| KDE service disable | 0.85 | Low | Easy |
| CPU affinity slices | 0.80 | Medium | Easy |
| Zram config | 0.90 | Low | N/A (already optimal) |
| **Overall Phase 1A** | **0.75** | **Medium** | **Easy** |

---

**Status:** ✅ Ready for deployment
**Recommendation:** Deploy Phase 1A, test for 1 week, then decide on Phase 2
