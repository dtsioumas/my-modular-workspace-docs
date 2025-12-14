# NixOS Shoshin GPU Optimization Plan
## Maximize NVIDIA GTX 960 Utilization - Phases 7-8

**Plan Created:** 2025-12-14
**System:** Shoshin Desktop (NVIDIA GeForce GTX 960, 4GB VRAM)
**Prerequisites:** CPU Optimization (Phase 1-2) and Memory Optimization (Phase 1-6) Complete
**Goal:** Maximize GPU utilization from 14% to 60-80% by offloading workloads from CPU to GPU

---

## Executive Summary

### Current GPU State (2025-12-14)

```
GPU: NVIDIA GeForce GTX 960 (Maxwell 2.0, GM206)
VRAM: 4096 MiB (1686 MiB used = 41%)
GPU Utilization: 14% (severely underutilized)
Driver: 570.195.03
CUDA Version: 12.8 (reported by driver)
Compute Capability: 5.2 ⚠️ LIMITED TO CUDA ≤ 11.0
```

**Current GPU Users:**
- KWin compositor: 322MB (already optimized) ✅
- Plasmashell: 260MB ✅
- Kitty terminals: ~400MB total ✅
- Firefox: **8MB** (severely underutilized) ❌
- Brave: 126MB (good)
- Obsidian: 83MB
- VSCode: 22MB

**Critical Limitation Discovered:**
> **GTX 960 (Maxwell 2.0) is ONLY supported up to CUDA 11.0!**
> Driver reports CUDA 12.8, but this GPU cannot run CUDA 12.x workloads.
> All GPU-accelerated software MUST use CUDA 11.0 or earlier.

### Target State

```
GPU Utilization: 60-80% (from 14%)
VRAM Usage: 70-85% (from 41%)
CPU Offloading: 30-50% reduction in CPU usage for:
  - Video decode (browsers, media players)
  - LLM inference (Claude, Gemini agents)
  - Semantic search (ck)
  - Image processing
```

### Expected Benefits

1. **CPU Usage:** -30-50% on media/AI workloads
2. **Power Efficiency:** Better performance per watt
3. **Thermal:** Lower CPU temps, GPU designed for sustained load
4. **Performance:** Faster inference, smoother video playback
5. **Memory:** Free up RAM used by CPU-based processing

---

## Phase 7: Browser & Media GPU Acceleration

**Duration:** 2-3 hours
**Impact:** 20-30% CPU reduction for media workloads
**Risk:** Low

### Task 7.1: Firefox VA-API Hardware Video Decode

**Objective:** Enable GPU video decoding in Firefox (currently only 8MB GPU usage)

**Current Problem:**
Firefox on NVIDIA requires VA-API, but NVIDIA proprietary drivers don't support VA-API natively. Need `nvidia-vaapi-driver` bridge.

**Research References:**
- https://github.com/elFarto/nvidia-vaapi-driver
- https://wiki.archlinux.org/title/Hardware_video_acceleration
- https://ossmalta.eu/get-firefox-va-api-hardware-acceleration-working-on-nvidia-gpu/

**Local Paths:**
- New file: `hosts/shoshin/nixos/modules/applications/firefox-gpu.nix`
- Update: `hosts/shoshin/nixos/hosts/shoshin/configuration.nix`

#### Subtask 7.1.1: Install nvidia-vaapi-driver

**Implementation:**

```nix
# hosts/shoshin/nixos/modules/applications/firefox-gpu.nix
{ config, pkgs, ... }:
{
  # NVIDIA VA-API driver for Firefox hardware decode
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver  # NVIDIA → VA-API bridge
      libvdpau-va-gl       # VDPAU fallback
    ];
  };

  # Environment variables for VA-API
  environment.sessionVariables = {
    # Force NVIDIA VDPAU backend for VA-API
    LIBVA_DRIVER_NAME = "nvidia";
    # Enable VDPAU for older codecs
    VDPAU_DRIVER = "nvidia";
    # NVIDIA driver library path
    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
  };

  # Firefox with VA-API support
  programs.firefox = {
    enable = true;
    policies = {
      Preferences = {
        # Enable hardware video acceleration
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;

        # Enable WebRender (GPU rendering)
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;

        # GPU compositing
        "layers.acceleration.force-enabled" = true;
        "layers.gpu-process.enabled" = true;
      };
    };
  };
}
```

**Subtasks:**
1. ✅ **Create firefox-gpu.nix module**
2. ✅ **Add to configuration.nix imports**
3. ✅ **Rebuild system**
4. ✅ **Verify VA-API detection**
   ```bash
   vainfo
   # Should show NVIDIA VDPAU driver
   ```
5. ✅ **Test in Firefox**
   - Open `about:support`
   - Check "Media" section → "Hardware H264" should say "Supported"
   - Play YouTube video
   - Run `nvidia-smi` to confirm GPU usage increases

**Expected Results:**
- Firefox GPU usage: 8MB → 150-300MB (during video playback)
- CPU usage during video: -40-60%
- VRAM total: 1686MB → 2000-2200MB

---

#### Subtask 7.1.2: Optimize Brave Browser GPU Usage

**Current State:**
Brave already has some GPU flags but can be optimized further.

**Implementation:**

```nix
# hosts/shoshin/nixos/modules/applications/browser-gpu.nix
{ config, pkgs, ... }:
{
  environment.sessionVariables = {
    # Force GPU acceleration in Chromium-based browsers
    CHROMIUM_FLAGS = [
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
      "--use-gl=desktop"
      "--ignore-gpu-blocklist"
    ].join(" ");
  };

  # Brave with enhanced GPU support
  environment.systemPackages = with pkgs; [
    (brave.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--disable-gpu-driver-bug-workarounds"
      ];
    })
  ];
}
```

**Expected Results:**
- Brave GPU usage: 126MB → 200-400MB (during video)
- Better video decode performance

---

### Task 7.2: Media Player GPU Acceleration

**Objective:** Ensure mpv and other media players use GPU decode

**Implementation:**

```nix
# hosts/shoshin/nixos/modules/applications/media-gpu.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (mpv.override {
      scripts = [ mpvScripts.mpris ];
    })
  ];

  # mpv configuration
  environment.etc."mpv/mpv.conf".text = ''
    # GPU video decoding
    hwdec=nvdec          # Use NVIDIA NVDEC
    vo=gpu               # GPU video output
    profile=gpu-hq       # High quality GPU rendering

    # Performance
    video-sync=display-resample
    interpolation=yes
    tscale=oversample
  '';
}
```

**Expected Results:**
- MPV uses NVDEC for hardware decode
- Minimal CPU usage during 4K video playback

---

## Phase 8: AI Agent GPU Acceleration

**Duration:** 4-6 hours
**Impact:** 50-80% CPU reduction for LLM inference
**Risk:** Medium (complex setup, CUDA 11.0 requirement)

### Task 8.1: CK Semantic Search GPU Acceleration

**Objective:** Rebuild ck-search with ONNX Runtime CUDA 11.0 support

**Current Status:**
- Research complete: `docs/researches/2025-12-14_ck_gpu_investigation.md`
- Plan exists: `docs/plans/2025-12-14-ck-rebuild-for-gpu-usage-plan.md`
- **Critical:** Must use CUDA 11.0 (not 12.x) for GTX 960

**Reference:** Existing plan at `docs/plans/2025-12-14-ck-rebuild-for-gpu-usage-plan.md`

**Summary of Work:**
1. Create `onnxruntime-gpu` overlay with CUDA 11.0
2. Patch `home-manager/mcp-servers/rust-custom.nix` to use GPU runtime
3. Add `programs.ck.enableGpu` option to Home-Manager
4. Test semantic search GPU usage

**Expected Results:**
- CK semantic search: Pure CPU → 60-80% GPU
- Indexing speed: 2-4x faster
- VRAM usage: +500-800MB

**Implementation:** Follow existing plan (not duplicated here)

---

### Task 8.2: Local LLM Inference for Agents

**Objective:** Set up local GPU-accelerated LLM inference for Claude/Gemini CLI alternatives

**Research Summary:**

**Option A: llama.cpp (RECOMMENDED for GTX 960)**
- Supports CUDA 11.x
- Lower VRAM requirements
- Good single-user performance
- Works well with smaller models (7B-13B)

**Option B: vLLM**
- Optimized for multi-user serving
- Requires CUDA 12.x (incompatible with GTX 960!)
- High throughput but needs modern GPU
- ❌ **NOT COMPATIBLE WITH GTX 960**

**Option C: Ollama**
- Uses llama.cpp backend
- Simple user experience
- Good for local experimentation
- Supports CUDA 11.x

**Recommendation:** Use llama.cpp or Ollama (llama.cpp backend) for GTX 960.

---

#### Subtask 8.2.1: Set Up Ollama with CUDA 11.0

**Local Paths:**
- New file: `hosts/shoshin/nixos/modules/applications/ollama.nix`

**Implementation:**

```nix
# hosts/shoshin/nixos/modules/applications/ollama.nix
{ config, pkgs, ... }:
{
  # Ollama service with CUDA support
  services.ollama = {
    enable = true;
    acceleration = "cuda";  # Enable CUDA acceleration

    # CRITICAL: Must use CUDA 11.0 for GTX 960
    package = pkgs.ollama.override {
      cudaPackages = pkgs.cudaPackages_11;  # CUDA 11.x
    };

    # Resource limits
    systemd.services.ollama = {
      serviceConfig = {
        MemoryMax = "6G";      # Leave room for other apps
        CPUQuota = "300%";     # Max 3 cores
      };
    };
  };

  # CUDA 11.0 runtime libraries
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;  # CUDA 11.0 compatible
  };

  # Environment for Ollama
  environment.systemVariables = {
    OLLAMA_HOST = "127.0.0.1:11434";
    # Force CUDA 11.0
    CUDA_PATH = "${pkgs.cudaPackages_11.cudatoolkit}";
  };
}
```

**Subtasks:**
1. ✅ **Install Ollama with CUDA 11.0**
2. ✅ **Download a model for testing**
   ```bash
   ollama pull llama3.2:3b  # Small 3B model for testing
   ```
3. ✅ **Test GPU usage**
   ```bash
   # Terminal 1: Monitor GPU
   watch -n 1 nvidia-smi

   # Terminal 2: Run inference
   ollama run llama3.2:3b "Explain GPU acceleration in one paragraph"
   ```
4. ✅ **Verify GPU utilization**
   - Should see GPU usage spike to 60-90%
   - VRAM usage increase

**Model Size Recommendations for 4GB VRAM:**
- 3B models: ~2-3GB VRAM (comfortable)
- 7B models (quantized): ~3.5GB VRAM (tight but works)
- 13B models: Too large, will OOM

**Expected Results:**
- GPU utilization during inference: 60-90%
- VRAM usage: +2-3GB (depending on model)
- Inference speed: 10-30x faster than CPU

---

#### Subtask 8.2.2: Create LLM-Powered Agent Wrappers

**Objective:** Replace Claude CLI / Gemini CLI with local GPU-accelerated alternatives

**Implementation:**

```nix
# hosts/shoshin/nixos/modules/applications/llm-agents.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Local LLM wrapper for Claude-like interface
    (writeShellScriptBin "claude-local" ''
      #!/usr/bin/env bash
      # GPU-accelerated local Claude alternative

      if [[ "$1" == "--gpu" ]]; then
        # Use Ollama with GPU
        ${pkgs.ollama}/bin/ollama run llama3.2:3b "$@"
      else
        # Fallback to remote Claude
        ${pkgs.claude}/bin/claude "$@"
      fi
    '')

    # Local LLM API server wrapper
    (writeShellScriptBin "llm-serve" ''
      #!/usr/bin/env bash
      # Start Ollama server with GPU acceleration

      echo "Starting GPU-accelerated LLM server..."
      echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader)"
      echo "VRAM: $(nvidia-smi --query-gpu=memory.total --format=csv,noheader)"
      echo ""
      echo "API endpoint: http://localhost:11434"
      echo "Available models:"
      ${pkgs.ollama}/bin/ollama list
    '')
  ];

  # Aliases for easy switching
  environment.shellAliases = {
    # GPU-first, fallback to cloud
    claude-gpu = "claude-local --gpu";
    llm = "ollama run llama3.2:3b";
  };
}
```

**Subtasks:**
1. ✅ **Create agent wrappers**
2. ✅ **Test local inference**
3. ✅ **Compare performance**
   - CPU Claude: baseline
   - GPU Ollama: measure speedup
4. ✅ **Document usage patterns**

**Expected Results:**
- Local inference: 10-30x faster than CPU
- Privacy: No data sent to cloud
- Cost: No API costs
- Limitation: Smaller models (3B-7B vs Claude's 175B+)

---

### Task 8.3: CUDA 11.0 Environment Setup

**Objective:** Ensure CUDA 11.0 libraries available for all GPU workloads

**Critical Context:**
GTX 960 (Maxwell 2.0, compute capability 5.2) is **NOT supported** by CUDA 12.x. All GPU-accelerated applications must use CUDA 11.0 or earlier.

**Local Paths:**
- New file: `hosts/shoshin/nixos/modules/system/cuda-11.nix`

**Implementation:**

```nix
# hosts/shoshin/nixos/modules/system/cuda-11.nix
{ config, pkgs, lib, ... }:
{
  # CUDA 11.0 for GTX 960 (Maxwell 2.0)
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    cudaCapabilities = [ "5.2" ];  # GTX 960 compute capability
    cudaForwardCompat = false;      # Don't try CUDA 12.x
  };

  # Install CUDA 11.0 toolkit
  environment.systemPackages = with pkgs; [
    cudaPackages_11.cudatoolkit
    cudaPackages_11.cudnn
    cudaPackages_11.cuda_cudart
    cudaPackages_11.libcublas
    cudaPackages_11.libcufft
  ];

  # CUDA environment variables
  environment.variables = {
    CUDA_PATH = "${pkgs.cudaPackages_11.cudatoolkit}";
    CUDA_HOME = "${pkgs.cudaPackages_11.cudatoolkit}";
    CUDNN_PATH = "${pkgs.cudaPackages_11.cudnn}";

    # Ensure CUDA libraries are found
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.cudaPackages_11.cudatoolkit.lib
      pkgs.cudaPackages_11.cudnn
      "/run/opengl-driver/lib"
    ];
  };

  # Persist across reboots
  environment.etc."profile.d/cuda11.sh".text = ''
    export CUDA_PATH="${pkgs.cudaPackages_11.cudatoolkit}"
    export CUDA_HOME="${pkgs.cudaPackages_11.cudatoolkit}"
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"
  '';
}
```

**Subtasks:**
1. ✅ **Install CUDA 11.0 packages**
2. ✅ **Set environment variables**
3. ✅ **Verify CUDA availability**
   ```bash
   # Check CUDA version
   nvcc --version  # Should show CUDA 11.x

   # Verify libraries
   ldconfig -p | grep cuda

   # Test with simple CUDA program
   cuda-samples deviceQuery
   ```

**Expected Results:**
- CUDA 11.0 toolkit available system-wide
- All GPU applications can link to CUDA libraries
- No conflicts with driver's CUDA 12.8 reporting

---

## Phase 7-8 Implementation Timeline

### Week 1: Browser & Media Acceleration (Phase 7)
- **Day 1:** Task 7.1 - Firefox VA-API setup
- **Day 2:** Task 7.1 validation, Task 7.2 - Media players
- **Day 3:** Testing and optimization
- **Day 4:** Monitor and validate (GPU usage should increase)
- **Day 5:** Buffer for issues

### Week 2: AI Agent Acceleration (Phase 8)
- **Day 8:** Task 8.3 - CUDA 11.0 environment setup
- **Day 9:** Task 8.1 - CK rebuild (follow existing plan)
- **Day 10:** Task 8.2.1 - Ollama setup
- **Day 11:** Task 8.2.2 - Agent wrappers
- **Day 12:** Testing and benchmarking
- **Day 13-14:** Optimization and validation

---

## Expected Results Summary

### Phase 7 (Browser & Media)
- **Firefox GPU usage:** 8MB → 150-300MB (during video)
- **CPU reduction:** -40-60% for video decode
- **VRAM increase:** +300-500MB
- **GPU utilization:** 14% → 30-40%

### Phase 8 (AI Agents)
- **LLM inference:** CPU-only → 60-90% GPU
- **CK semantic search:** CPU-only → 60-80% GPU
- **VRAM increase:** +2-3GB (model dependent)
- **GPU utilization:** 30-40% → 60-80%

### Combined Impact
- **GPU utilization:** 14% → 60-80% (4-5x increase)
- **VRAM utilization:** 41% (1686MB) → 75-85% (3000-3500MB)
- **CPU offloading:** 30-50% reduction for media/AI workloads
- **Power efficiency:** Better performance per watt
- **Faster workflows:** 10-30x faster LLM inference

---

## Monitoring & Validation

### GPU Monitoring Dashboard

**Script:** `~/bin/gpu-monitor.sh`

```bash
#!/usr/bin/env bash
# gpu-monitor.sh - GPU utilization monitoring

clear
echo "=== GPU Utilization Monitor ==="
echo ""

# GPU info
nvidia-smi --query-gpu=name,memory.total,memory.used,memory.free,utilization.gpu,utilization.memory,temperature.gpu,power.draw --format=csv,noheader,nounits | \
  awk -F', ' '{
    printf "GPU: %s\n", $1
    printf "VRAM: %sMiB / %sMiB (%.1f%%)\n", $3, $2, ($3/$2)*100
    printf "GPU Util: %s%%\n", $5
    printf "Mem Util: %s%%\n", $6
    printf "Temp: %s°C\n", $7
    printf "Power: %sW\n\n", $8
  }'

# Top GPU processes
echo "--- Top GPU Processes ---"
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader | \
  sort -t',' -k3 -rn | head -10 | \
  awk -F', ' '{printf "%-8s %-40s %sMiB\n", $1, $2, $3}'
echo ""

# Comparison with baseline
echo "--- Baseline Comparison ---"
echo "Initial: 14% GPU util, 1686MiB VRAM (41%)"
echo "Target:  60-80% GPU util, 3000-3500MiB VRAM (75-85%)"
```

### Validation Commands

```bash
# Check CUDA version and compute capability
nvidia-smi --query-gpu=compute_cap,driver_version,cuda_version --format=csv

# Verify VA-API
vainfo

# Test Firefox GPU
firefox about:support  # Check Media section

# Test Ollama GPU
ollama run llama3.2:3b "test" && nvidia-smi

# Monitor real-time
watch -n 1 nvidia-smi

# Detailed GPU stats
nvidia-smi dmon -s pucvmet
```

### Success Criteria

**Phase 7 Complete:**
- [ ] Firefox shows "Hardware H264: Supported" in about:support
- [ ] YouTube video playback uses GPU (nvidia-smi shows +100MB VRAM)
- [ ] CPU usage during video < 30%
- [ ] GPU utilization during video > 30%

**Phase 8 Complete:**
- [ ] Ollama runs and uses GPU (nvidia-smi shows 60-90% util)
- [ ] CK semantic search uses GPU (verify with nvidia-smi)
- [ ] CUDA 11.0 toolkit accessible (nvcc --version shows 11.x)
- [ ] LLM inference 10x+ faster than CPU
- [ ] Overall GPU utilization > 60%

---

## Troubleshooting

### Issue: CUDA Version Mismatch
**Symptom:** Applications fail with "CUDA version mismatch" or "unsupported compute capability"

**Cause:** Trying to run CUDA 12.x on GTX 960 (only supports up to 11.0)

**Solution:**
```bash
# Verify compute capability
nvidia-smi --query-gpu=compute_cap --format=csv
# Should show: 5.2

# Ensure using CUDA 11.x
nvcc --version
# Should show: CUDA 11.x, NOT 12.x

# Check application CUDA version
ldd $(which ollama) | grep cuda
# Should link to CUDA 11.x libraries
```

---

### Issue: VA-API Not Working in Firefox
**Symptom:** Firefox still shows "Hardware H264: Unsupported"

**Diagnosis:**
```bash
# Check VA-API driver
vainfo
# Should show: NVIDIA VDPAU driver

# Check Firefox process
env | grep LIBVA
# Should show: LIBVA_DRIVER_NAME=nvidia

# Check VDPAU
vdpauinfo
# Should list supported codecs
```

**Solution:**
1. Ensure nvidia-vaapi-driver installed
2. Verify environment variables set
3. Restart Firefox
4. Try Firefox policies (declarative config)

---

### Issue: Ollama Not Using GPU
**Symptom:** Ollama runs but GPU utilization stays at 0%

**Diagnosis:**
```bash
# Check Ollama CUDA support
ollama --version

# Check CUDA libraries
ldd $(which ollama) | grep cuda

# Verify CUDA available
nvidia-smi
```

**Solution:**
1. Ensure CUDA 11.0 toolkit installed
2. Rebuild Ollama with CUDA support
3. Set CUDA_VISIBLE_DEVICES=0
4. Check GPU memory not exhausted

---

### Issue: Out of VRAM
**Symptom:** Applications crash with "out of memory" error

**Solution:**
```bash
# Check VRAM usage
nvidia-smi

# Use smaller models
ollama pull llama3.2:3b  # Instead of 7b/13b

# Limit concurrent GPU apps
# Don't run: Ollama + CK + Firefox video + games simultaneously

# Increase zram if RAM is bottleneck
```

---

## Hardware Limitations & Realistic Expectations

### GTX 960 Constraints

**Strengths:**
- ✅ Good for 1080p video decode
- ✅ Suitable for small LLMs (3B-7B models)
- ✅ Efficient for semantic search
- ✅ Desktop compositing
- ✅ Low power consumption

**Limitations:**
- ❌ **CUDA 11.0 maximum** (no CUDA 12.x support)
- ❌ Only 4GB VRAM (limits model sizes)
- ❌ No Tensor Cores (slower inference than RTX)
- ❌ No RT cores (no ray tracing)
- ❌ Compute capability 5.2 (old architecture)

**Realistic Targets:**
- Small LLMs (≤7B parameters, quantized)
- Video decode (up to 4K HEVC)
- Semantic search with small models
- GPU compositing and UI acceleration
- **NOT suitable for:** Training, large models (>13B), 8K video, ray tracing

### Performance Expectations

**LLM Inference (7B quantized model):**
- CPU: ~5-10 tokens/sec
- GTX 960 GPU: ~50-100 tokens/sec
- Modern RTX 4090: ~500-1000 tokens/sec

**CK Semantic Search:**
- CPU: ~100-200 docs/sec
- GTX 960 GPU: ~400-800 docs/sec
- Modern RTX 4090: ~2000-4000 docs/sec

**Conclusion:** GTX 960 provides meaningful acceleration (5-10x) but is not comparable to modern GPUs (50-100x).

---

## Integration with Previous Phases

### Dependencies

**Phase 1-6 Must Be Complete:**
- CPU optimization ensures CPU available for GPU-CPU coordination
- Memory optimization ensures enough RAM for GPU drivers and buffers
- zram optimization leaves more VRAM free

**Resource Budget:**
After Phase 1-6, available resources:
- **RAM:** ~10-12GB free (after optimizations)
- **CPU:** 3-4 cores available (rest reserved for critical tasks)
- **VRAM:** 4GB total, ~2.5GB free (after desktop use)

**GPU Workload Priority:**
1. Desktop compositing (always highest priority)
2. Video decode (interactive)
3. LLM inference (when needed)
4. Semantic search (background)

**Resource Allocation:**
```
Desktop (KWin + Plasma): 600MB VRAM (fixed)
Video decode:            0-500MB VRAM (dynamic)
LLM inference:           2-3GB VRAM (exclusive, when active)
Semantic search:         500-800MB VRAM (background)
```

---

## Cost-Benefit Analysis

### Development Time
- Phase 7 (Browser): 2-3 hours
- Phase 8 (AI Agents): 4-6 hours
- Testing & validation: 2-3 hours
- **Total:** 8-12 hours

### Performance Gains
- Video decode: 40-60% CPU reduction
- LLM inference: 10-30x speedup
- Semantic search: 4-8x speedup
- Overall system: 20-30% CPU freed up

### Alternatives Considered

**Option A: Do Nothing**
- Cost: $0
- Benefit: None
- CPU remains bottleneck

**Option B: Upgrade GPU (RTX 4060, $300)**
- Cost: $300
- Benefit: 10x better than GTX 960
- Verdict: Better ROI, but want to maximize existing hardware first

**Option C: This Plan (Optimize GTX 960)**
- Cost: 8-12 hours time
- Benefit: 5-10x speedup for targeted workloads
- Verdict: **RECOMMENDED** - Good ROI, learn NixOS GPU optimization

**Decision:** Implement this plan first, consider GPU upgrade in 6-12 months if needed.

---

## Next Steps After Phase 7-8

### Potential Phase 9: Advanced GPU Optimization
- [ ] Multi-GPU support (if second GPU added)
- [ ] GPU power management tuning
- [ ] Custom CUDA kernels for specific workloads
- [ ] GPU memory management optimization
- [ ] Wayland protocol GPU acceleration

### Future Hardware Considerations
- [ ] Evaluate RTX 4060 (~$300, 8GB VRAM, CUDA 12.x, Tensor Cores)
- [ ] Consider used RTX 3060 (~$200, 12GB VRAM)
- [ ] Wait for RTX 5060 release (2026?)

---

## Documentation & References

### Local Documentation
- **CK GPU Research:** `docs/researches/2025-12-14_ck_gpu_investigation.md`
- **CK GPU Plan:** `docs/plans/2025-12-14-ck-rebuild-for-gpu-usage-plan.md`
- **Memory Optimization:** `docs/researches/nixos-shoshin-system-memory-optimization.md`
- **CPU Optimization:** `docs/researches/nixos-shoshin-cpu-skylake-tuning.md`
- **This Plan:** `docs/plans/nixos-shoshin-gpu-optimization-plan.md`

### External References

**VA-API for NVIDIA:**
- https://github.com/elFarto/nvidia-vaapi-driver
- https://wiki.archlinux.org/title/Hardware_video_acceleration
- https://ossmalta.eu/get-firefox-va-api-hardware-acceleration-working-on-nvidia-gpu/

**LLM Inference:**
- llama.cpp: https://github.com/ggerganov/llama.cpp
- Ollama: https://ollama.ai/
- vLLM: https://github.com/vllm-project/vllm (not compatible with GTX 960)

**CUDA & NixOS:**
- NixOS CUDA wiki: https://wiki.nixos.org/wiki/CUDA
- NVIDIA CUDA support matrix: https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/
- Maxwell GPU support: https://en.wikipedia.org/wiki/Maxwell_(microarchitecture)

**ONNX Runtime:**
- CUDA EP requirements: https://onnxruntime.ai/docs/execution-providers/CUDA-ExecutionProvider.html

---

## Completion Checklist

### Phase 7: Browser & Media
- [ ] nvidia-vaapi-driver installed
- [ ] Firefox VA-API enabled
- [ ] Firefox shows hardware decode support
- [ ] Brave GPU flags optimized
- [ ] mpv using NVDEC
- [ ] Video playback GPU usage verified
- [ ] CPU usage during video reduced
- [ ] GPU utilization > 30% during media

### Phase 8: AI Agents
- [ ] CUDA 11.0 toolkit installed
- [ ] CUDA environment variables set
- [ ] Ollama installed with CUDA support
- [ ] Test model downloaded (llama3.2:3b)
- [ ] Ollama GPU inference working
- [ ] CK rebuilt with GPU support (follow existing plan)
- [ ] Agent wrappers created
- [ ] Performance benchmarks completed
- [ ] GPU utilization > 60% during inference

### Overall Success
- [ ] GPU utilization: 14% → 60-80%
- [ ] VRAM utilization: 41% → 75-85%
- [ ] CPU reduction: 30-50% for media/AI
- [ ] No application functionality loss
- [ ] System stable for 1 week
- [ ] Documentation complete

---

**Plan Status:** Ready for Implementation (After Phase 1-6 Complete)
**Next Step:** Complete CPU and Memory optimization phases first, then begin Phase 7
**Estimated Total Time:** 10-14 hours over 2 weeks
**Review Date:** After Phase 7 completion

---

**End of GPU Optimization Plan**
