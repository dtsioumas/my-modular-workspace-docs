# ADR-020: GPU Offload Strategy for CPU-Constrained Desktop

**Status:** Proposed
**Date:** 2025-12-24
**Authors:** Mitsos, Claude Sonnet 4.5
**Related ADRs:** ADR-015 (Hardware Data Layer), ADR-017 (Hardware-Aware Build Optimizations)

---

## Context

### Hardware Allocation Plan

The i7-6700K (4 cores / 8 threads) will be split for dissertation work:
- **Desktop:** 1 core / 2 threads (87.5% thread reduction)
- **K8s VM:** 6 cores / 12 threads (for Kubernetes platform development)

This extreme CPU constraint requires **maximum GPU offload** to maintain desktop usability.

**Current Hardware:**
- CPU: Intel i7-6700K (1c/2t allocated to desktop after split)
- GPU: NVIDIA GTX 960 (4GB VRAM, Maxwell GM206, CUDA 5.2)
- RAM: 15GB total (target: reduce to 7-8GB usage for desktop)
- Storage: SSD
- OS: NixOS with KDE Plasma 6 (X11 session)

**Current Baseline Usage (Before Split):**
- RAM: 11GB (9.9GB desktop + services)
- Applications: Firefox (3.5GB), VSCodium (1.5GB), KDE Plasma (1.2GB)
- CPU: 4 cores available, 20-40% average utilization

### Problem Statement

With only 1 core/2 threads, the desktop will face:
1. **Thread starvation:** 2 threads must service 20+ active processes
2. **Context switching overhead:** 30-40% of CPU time wasted
3. **Compositor performance:** Frame drops, UI lag
4. **Browser bottlenecks:** Multi-process browsers struggle with limited threads
5. **Language server slowness:** VSCodium autocomplete/analysis will crawl

**Critical Challenge:** Many desktop operations are **inherently CPU-bound** and cannot be GPU-offloaded:
- JavaScript execution (Firefox/Chromium V8)
- Language servers (rust-analyzer, gopls, TypeScript)
- Process scheduling and system calls
- File I/O and network stack

### Research Conducted

Two parallel research agents analyzed the feasibility and optimization strategies:

**Ultrathink Agent Findings (Confidence: 0.55 - Band B):**
- 1c/2t desktop is technically viable but **SEVERELY limited**
- Expected performance: 5-10s UI lag on heavy tasks, 30-60s Firefox tab switches
- GPU can offload: video decode (30-50% CPU savings), compositor, rendering
- GPU CANNOT offload: JS execution, language servers, process scheduling
- Recommended architectural changes: Switch to lighter compositor (Picom), consider lighter browser

**Web Research Agent Findings (Confidence: 0.60 - Band B):**
- GTX 960 can achieve 70-90% GPU utilization for video decode/encode (NVDEC/NVENC)
- Picom compositor: 5-15% CPU usage (vs KWin: 15-30%)
- Zram with lz4: Trade 5% CPU for compression, save 20-50% CPU by avoiding disk I/O
- Firefox process reduction: Disabling Fission saves CPU but creates **security risk**
- CUDA for desktop: Limited value (only beneficial for Ollama <3B models, video encoding)

---

## Decision

### 1. GPU Offload Strategy (Priority 1 - MUST IMPLEMENT)

**Objective:** Maximize GPU utilization to compensate for extreme CPU reduction.

#### A. Video Decode/Encode (CRITICAL - 30-50% CPU savings)

**Configuration:**
```nix
# hardware.graphics configuration (NixOS)
hardware.graphics = {
  enable = true;
  enable32Bit = true;
  extraPackages = with pkgs; [
    nvidia-vaapi-driver  # NVDEC wrapper for VA-API
    vaapiVdpau          # VDPAU backend
    libvdpau-va-gl      # VDPAU acceleration
  ];
};

# Environment variables
environment.variables = {
  VDPAU_DRIVER = "nvidia";
  LIBVA_DRIVER_NAME = "nvidia";
  MOZ_DISABLE_RDD_SANDBOX = "1";  # Allow Firefox to access NVDEC
  NVD_BACKEND = "direct";
};

# Keep NVIDIA driver loaded (reduce latency)
hardware.nvidia.nvidiaPersistenced = true;
```

**Expected Impact:**
- Video playback: 20-30% CPU → GPU offloaded
- Browser video: 40-60% CPU reduction on YouTube/streaming

#### B. Compositor GPU Acceleration (CRITICAL)

**Decision:** Switch from KWin to Picom (lightweight GLX compositor)

**Rationale:**
- KWin CPU usage: 15-30% (too high for 1 core)
- Picom CPU usage: 5-15% (50% reduction)
- KWin features (blur, transparency effects) are **CPU/GPU expensive** with minimal benefit

**Configuration:**
```nix
services.picom = {
  enable = true;
  backend = "glx";  # GPU-accelerated
  vSync = true;

  settings = {
    # GPU rendering
    glx-no-stencil = true;
    glx-no-rebind-pixmap = true;
    use-damage = true;

    # Disable CPU-heavy effects
    blur = false;
    shadow = false;
    fading = false;

    # Unredirect fullscreen windows (bypass compositor)
    unredir-if-possible = true;
  };
};

# Replace KDE Plasma with lightweight window manager
services.xserver.windowManager.i3.enable = true;
```

**Alternative (Fallback):** Keep KDE Plasma but disable compositor entirely (Shift+Alt+F12)
- Saves 15-30% CPU but loses transparency/compositing
- Acceptable trade-off for 1-core scenario

#### C. Browser GPU Acceleration (HIGH PRIORITY)

**Firefox Configuration:**
```nix
programs.firefox.preferences = {
  # Force GPU acceleration
  "layers.acceleration.force-enabled" = true;
  "gfx.webrender.all" = true;
  "media.ffmpeg.vaapi.enabled" = true;
  "media.hardware-video-decoding.force-enabled" = true;
  "media.rdd-ffmpeg.enabled" = true;  # NVDEC via RDD process

  # WebGL2/WebGPU (already implemented in ADR-019 optimizations)
  "webgl.enable-webgl2" = true;
  "dom.webgpu.enabled" = true;
  "gfx.webgpu.force-enabled" = true;

  # X11/EGL optimizations
  "gfx.x11-egl.force-enabled" = true;
  "widget.dmabuf.force-enabled" = true;

  # CRITICAL for 1 core: Reduce process count (SECURITY TRADE-OFF!)
  "dom.ipc.processCount" = 1;  # Single content process
  "dom.ipc.processCount.webIsolated" = 1;
  "fission.autostart" = false;  # Disable site isolation
};
```

**⚠️ SECURITY WARNING:** Disabling Fission (site isolation) saves CPU but makes browser vulnerable to:
- Session hijacking
- Spectre-like attacks
- Malicious site exploits

**Mitigation:** Use uBlock Origin, NoScript, browse only trusted sites.

**Alternative:** Switch to lighter browser (qutebrowser, Falkon) with single-process mode.

### 2. Extreme RAM Optimization (Target: 7-8GB from 11GB)

**Objective:** Reduce RAM by 30% to minimize process count and context switching overhead.

#### A. KDE Plasma Service Reduction

```nix
systemd.user.services = {
  # Already disabled: baloo (200-500MB)

  # NEW disables:
  "kdeconnect".Install.WantedBy = lib.mkForce [];          # ~50MB
  "plasma-browser-integration-host".Install.WantedBy = lib.mkForce [];  # ~30MB
  "kwalletd5".Install.WantedBy = lib.mkForce [];           # ~40MB (if using KeePassXC)
  "kwalletd6".Install.WantedBy = lib.mkForce [];
  "plasma-vault".Install.WantedBy = lib.mkForce [];        # ~30MB
  "plasma-discover".Install.WantedBy = lib.mkForce [];     # ~80MB
};
```

**Expected Savings:** 500MB (1.2GB → 0.7GB KDE footprint)

#### B. Browser RAM Reduction

**Option 1:** Limit Firefox to 3 tabs maximum (PAINFUL but effective)
- Current: 3.5GB for 10-15 tabs
- Target: 2.0GB for 3 tabs
- **Savings:** 1.5GB

**Option 2:** Switch to qutebrowser (Chromium-based, single-process mode)
- Expected RAM: 1.5-2.0GB for 5 tabs
- **Savings:** 1.5-2.0GB
- **Trade-off:** Keyboard-driven UI, learning curve

**Decision:** Implement Option 1 initially, fallback to Option 2 if unusable.

#### C. VSCodium RAM Reduction

```nix
programs.vscode.userSettings = {
  # Limit language server memory
  "typescript.tsserver.maxTsServerMemory" = 512;  # 512MB max
  "rust-analyzer.server.extraEnv" = {
    "RA_LOG" = "error";  # Reduce logging
  };

  # Disable memory-heavy features
  "editor.minimap.enabled" = false;
  "editor.suggest.preview" = false;
  "editor.hover.enabled" = false;
  "git.autorefresh" = false;
  "git.autofetch" = false;

  # File watcher exclusions (200-500MB savings - already implemented)
  "files.watcherExclude" = {
    "**/.git/objects/**" = true;
    "**/node_modules/**" = true;
    "**/dist/**" = true;
    "**/build/**" = true;
    "**/target/**" = true;
  };
};
```

**Expected Savings:** 500MB (1.5GB → 1.0GB)

#### D. AI Agents to K8s VM

**Decision:** Move AI agents (Gemini CLI, Claude Code) from desktop to K8s VM
- Current RAM on desktop: 800MB
- **Savings:** 800MB
- **Access:** Via HTTP API from desktop
- **Trade-off:** Network latency, requires API wrapper

#### E. Zram Configuration (CRITICAL)

```nix
zramSwap = {
  enable = true;
  algorithm = "lz4";  # Fast compression, low CPU overhead
  memoryPercent = 50;  # 7.5GB zram device (compresses 2-3x)
  priority = 10;
};

boot.kernel.sysctl = {
  "vm.swappiness" = 150;  # Aggressive swap to zram (it's fast!)
  "vm.page-cluster" = 0;  # Don't read ahead
};

swapDevices = [];  # Disable disk swap (zram only)
```

**Rationale:**
- Zram uses ~5% CPU for compression but saves 20-50% CPU by avoiding disk I/O
- lz4 provides 2-3x compression ratio
- Net benefit: Significant CPU savings despite compression overhead

### 3. Application Strategy

#### Browser Decision Matrix

| Browser | RAM (5 tabs) | CPU Usage | Security | Recommendation |
|---------|--------------|-----------|----------|----------------|
| Firefox | 3.5GB | HIGH | Medium (Fission disabled) | Fallback |
| qutebrowser | 1.5-2.0GB | MEDIUM | Good | **Primary choice** |
| Falkon | 800MB | LOW | Good | Emergency fallback |

**Decision:** Migrate to qutebrowser for better CPU/RAM efficiency.

#### Editor Decision

**VSCodium:** Keep for light editing only
**Neovim:** Use for heavy development (saves 1GB when VSCodium not running)

#### Desktop Environment

**Current:** KDE Plasma 6 with KWin
**Proposed:** i3wm + Picom (saves 500MB RAM + significant CPU)

**Rationale:**
- KDE Plasma RAM: 700MB (after service reduction)
- i3wm + Picom RAM: 200MB
- **Savings:** 500MB RAM + 10-20% CPU

**Implementation:** Phase 2 (after validating GPU offload works)

### 4. CPU Affinity & Resource Limits

**Systemd Slices Configuration:**

```nix
systemd.slices."desktop" = {
  description = "Desktop processes";
  sliceConfig = {
    CPUAffinity = "0-1";  # Pin to threads 0-1
    MemoryHigh = "7G";
    MemoryMax = "8G";
  };
};

systemd.slices."k8s" = {
  description = "Kubernetes VM";
  sliceConfig = {
    CPUAffinity = "2-7";  # Pin to threads 2-7
    MemoryHigh = "7G";
    MemoryMax = "8G";
  };
};
```

**Purpose:** Prevent CPU thrashing and ensure strict isolation between desktop and K8s workloads.

### 5. CUDA Enablement Decision

**Decision:** **SKIP CUDA** for desktop use

**Rationale:**
- GTX 960 VRAM: 4GB (limits to 2-3B parameter LLM models only)
- CUDA toolkit size: 2-3GB disk space
- Desktop applications don't use CUDA (use OpenGL/Vulkan instead)
- Local LLM inference: Too slow on Maxwell architecture (5-10 tokens/sec)

**Exception:** Enable only if specifically needed for:
- Video encoding (FFmpeg with NVENC)
- Ollama with <3B models
- Blender GPU rendering

---

## Consequences

### Positive

1. **GPU utilization:** Expected increase from 29-38% to 50-70% (video decode, compositor, browser rendering)
2. **RAM savings:** 3.1GB reduction (28% savings) brings usage to 7.9GB
3. **Video performance:** 30-50% CPU savings on video playback
4. **Compositor efficiency:** 50% CPU reduction (Picom vs KWin)
5. **Desktop remains functional:** Light tasks (browsing 2-3 tabs, text editing) should be acceptable
6. **K8s workload:** Gets 75% of CPU resources for dissertation work

### Negative

1. **Security risk:** Disabling Firefox Fission creates vulnerability to site isolation attacks
2. **Usability degradation:** Expected 5-10s lag on heavy tasks, 30-60s Firefox tab switches
3. **Development slowness:** Language servers (rust-analyzer) will crawl on 1 core
4. **Build times:** NixOS rebuilds will take 10x longer (use remote builder)
5. **Application limits:** Heavy IDEs (IntelliJ, full VS Code) become unusable
6. **Learning curve:** qutebrowser, i3wm, Neovim all require time to learn
7. **Workflow disruption:** 3-tab limit forces aggressive tab management

### Neutral / Risks

1. **Feasibility uncertainty (Confidence: 0.55):** Desktop might still be unusable for daily work despite optimizations
2. **Context switching:** 2 threads servicing 20+ processes = 10:1 contention ratio
3. **GPU limitations:** GPU cannot solve fundamental CPU bottlenecks (JS execution, process scheduling)
4. **Alternative recommended:** 2 cores/4 threads for desktop would be much more viable (still challenging but functional)

### Critical Reality Check

**Even with perfect GPU offload, 1 core/2 threads is EXTREMELY limiting.**

**What will work:**
- ✅ Video playback (GPU decode)
- ✅ Terminal work (GPU-accelerated)
- ✅ Light coding (with patience)

**What will struggle:**
- ⚠️ Web browsing (main thread bottleneck)
- ⚠️ Multitasking (switching apps)
- ⚠️ Language servers (autocomplete lag)

**What won't work well:**
- ❌ Large builds (use remote builder)
- ❌ Heavy web apps (Google Docs, Figma)
- ❌ Modern gaming (CPU bottleneck despite good GPU)

---

## Implementation Plan

### Phase 1: Viability Baseline (Week 1)

**Priority 1 (MUST implement for viability):**

1. **Enable NVIDIA video acceleration** (Day 1)
   - Configure hardware.graphics, nvidia-vaapi-driver
   - Set environment variables (VDPAU_DRIVER, LIBVA_DRIVER_NAME, MOZ_DISABLE_RDD_SANDBOX)
   - Test with `vainfo`, `vdpauinfo`, Firefox video playback

2. **Switch to Picom compositor** (Day 2)
   - Disable KWin, enable Picom with GLX backend
   - Configure minimal effects (no blur, shadow, fading)
   - Test compositor CPU usage with `htop`

3. **Firefox GPU acceleration + process reduction** (Day 2-3)
   - Enable WebRender, NVDEC, WebGL2/WebGPU
   - Reduce process count (dom.ipc.processCount = 1)
   - **WARNING:** Disable Fission (security risk - user must accept)
   - Limit tabs to 3 maximum

4. **Disable KDE services** (Day 3)
   - Disable: baloo, kdeconnect, plasma-vault, discover, kwalletd
   - Expected RAM savings: 500MB

5. **Enable Zram** (Day 4)
   - Configure lz4 algorithm, 50% memoryPercent
   - Set swappiness=150, disable disk swap
   - Monitor CPU overhead

6. **CPU affinity (systemd slices)** (Day 5)
   - Create desktop and k8s slices
   - Pin desktop to threads 0-1, K8s to threads 2-7
   - Test isolation

**Checkpoint:** Test if desktop is usable. If NO → **ABORT plan** and recommend 2 cores/4 threads instead.

### Phase 2: Major Changes (Week 2) - IF Phase 1 succeeds

7. **Switch to i3wm** (Day 8-10)
   - Replace KDE Plasma with i3 window manager
   - Keep some KDE apps (Dolphin, Kate, Konsole)
   - Expected RAM savings: 500MB

8. **Migrate to qutebrowser** (Day 11-12)
   - Configure single-process mode
   - Import bookmarks, setup keybindings
   - Expected RAM savings: 1.5GB

9. **Move AI agents to K8s VM** (Day 13-14)
   - Deploy Gemini CLI, Claude Code in K8s pods
   - Create HTTP API wrapper
   - Test from desktop
   - Expected RAM savings: 800MB

### Phase 3: Fine-Tuning (Week 3)

10. **VSCodium memory limits** (Day 15-16)
11. **Neovim setup for heavy development** (Day 17-18)
12. **Monitor and optimize** (Day 19-21)
    - Measure actual CPU/RAM usage
    - Test K8s + desktop workload simultaneously
    - Document limitations and workarounds

---

## Verification & Testing

### GPU Utilization Monitoring

```bash
# Real-time GPU monitoring
nvtop

# Check GPU state
nvidia-smi

# Monitor GPU during video playback
nvidia-smi dmon -s u
```

**Expected:**
- Idle: 5-15% GPU
- Video playback: 60-80% GPU
- Browser (WebGL): 40-60% GPU

### CPU Usage Baseline

```bash
htop

# Expected:
# Idle: <10% CPU
# Video: 15-30% CPU (vs 60-80% without GPU decode)
# Browser: 40-60% CPU (main thread bottleneck remains)
```

### RAM Usage Verification

```bash
free -h

# Expected:
# Total: 15GB
# Used: ~7.9GB (vs 11GB before optimizations)
# Swap (zram): 3-4GB used
```

### Video Acceleration Tests

```bash
# Test VDPAU
vdpauinfo

# Test VA-API
vainfo

# Firefox GPU check
# Navigate to about:support → Graphics
# Verify: WebRender = enabled, Hardware H264 Decoding = Yes
```

---

## Risks & Mitigation Strategies

### Risk 1: Desktop Becomes Unusable (LIKELIHOOD: MEDIUM, IMPACT: CRITICAL)

**Symptoms:**
- 10+ second UI freezes
- Applications crash frequently
- Cannot switch between apps

**Mitigation:**
- Checkpoint at Phase 1 - abort if unusable
- Fallback: Allocate 2 cores/4 threads to desktop instead
- Emergency: Disable K8s VM, restore full 4c/8t to desktop

### Risk 2: Security Compromise (LIKELIHOOD: MEDIUM, IMPACT: HIGH)

**Cause:** Disabled Firefox Fission (site isolation)

**Mitigation:**
- Install uBlock Origin, NoScript (mandatory)
- Browse only trusted sites
- Use separate browser (ungoogled-chromium) for untrusted sites
- Keep Firefox updated for security patches

### Risk 3: Build Failure (LIKELIHOOD: HIGH, IMPACT: MEDIUM)

**Cause:** NixOS builds fail due to RAM/CPU exhaustion

**Mitigation:**
- Use remote builder (ADR-018 remote builders pipeline)
- Cache builds on Cachix (ADR-017 hardware-aware caching)
- Build heavy packages (Firefox, VSCodium) on remote machine

### Risk 4: K8s VM Performance (LIKELIHOOD: LOW, IMPACT: MEDIUM)

**Cause:** Desktop workload starves K8s VM despite CPU pinning

**Mitigation:**
- Strict CPU affinity via systemd slices
- Monitor with `htop` for cross-contamination
- Adjust if needed (emergency: give K8s 7 threads, desktop 1 thread)

---

## Alternatives Considered

### Alternative 1: 2 cores/4 threads for desktop (RECOMMENDED)

**Pros:**
- Much more viable (50% thread reduction vs 87.5%)
- Desktop remains functional for daily work
- Language servers usable
- Firefox Fission can stay enabled (secure)

**Cons:**
- K8s VM gets 5 cores/10 threads (still plenty for dissertation)

**Verdict:** **Strongly recommended** over 1c/2t unless K8s needs are extreme.

### Alternative 2: Time-share CPU between desktop and K8s

**Approach:**
- Desktop mode: 4 cores desktop, 4 threads K8s (light)
- K8s mode: 1 core desktop, 7 threads K8s (heavy)
- Switch via systemd targets

**Pros:**
- Flexible resource allocation
- Desktop usable when needed

**Cons:**
- Manual switching overhead
- Complexity

### Alternative 3: Separate hardware

**Approach:**
- Keep i7-6700K for desktop only
- Use separate machine for K8s (Raspberry Pi cluster, old laptop)

**Pros:**
- Both workloads run optimally
- No resource contention

**Cons:**
- Cost (additional hardware)
- Space/power requirements

---

## Status & Next Steps

**Status:** Proposed (awaiting user decision)

**Critical Decision Required:**
User must decide:
1. Accept 1c/2t risk and proceed with Phase 1 testing
2. Switch to 2c/4t allocation (recommended)
3. Defer K8s VM until separate hardware available

**Next Steps (if approved):**
1. Update hardware profile (profiles/hardware/shoshin.nix) with new CPU allocation
2. Implement Phase 1 optimizations (GPU offload, RAM reduction)
3. Test desktop viability for 1 week
4. Document findings and adjust plan if needed

---

## References

### Research Agents
- Ultrathink Agent (a315249): Extreme CPU constraint feasibility analysis
- Web Research Agent (a0f2b1c): Maximum GPU utilization strategies

### Documentation
- NVIDIA - NixOS Wiki: https://nixos.wiki/wiki/Nvidia
- Hardware video acceleration - ArchWiki: https://wiki.archlinux.org/title/Hardware_video_acceleration
- Firefox Tweaks - ArchWiki: https://wiki.archlinux.org/title/Firefox/Tweaks
- KDE Desktop Effects Performance: https://userbase.kde.org/Desktop_Effects_Performance
- Zram/Zswap: https://wiki.nixos.org/wiki/Swap

### Related ADRs
- ADR-015: Hardware Data Layer (monitor/GPU metadata)
- ADR-017: Hardware-Aware Build Optimizations (per-host tuning)
- ADR-018: Remote Builders and Cache Pipeline (offload heavy builds)

---

**Decision Confidence:** 0.55 (Band B - PROCEED WITH EXTREME CAUTION)

**Recommendation:** Strongly consider 2 cores/4 threads allocation instead of 1c/2t for better desktop viability while still providing 5c/10t for K8s VM.
