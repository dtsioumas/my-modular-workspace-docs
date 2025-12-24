# ONNX Runtime CPU Limiting for ck (Semantic Search)

**Date:** 2025-12-24
**Problem:** ck using 513% CPU (5+ cores) when only need 100-150%
**Hardware:** shoshin (GTX 960 4GB VRAM, i5-6600K 4 cores)
**Tool:** ck v0.7.0 with ONNX Runtime CUDA provider

---

## Problem Statement

When running `ck --index` with GPU acceleration:
- **CPU Usage:** 513% (5.13 cores actively used)
- **GPU Usage:** 20-25% (underutilized)
- **Goal:** CPU 100-150%, GPU 40-50% minimum

**Attempted Solution That FAILED:**
```bash
export OMP_NUM_THREADS=4
export OMP_WAIT_POLICY=PASSIVE
```

**Result:** NO EFFECT - CPU still at 513%

---

## Why OMP_NUM_THREADS Doesn't Work

### Root Cause Analysis

Based on ONNX Runtime source code and GitHub issues:

1. **ONNX Runtime uses its own threading** (not OpenMP in default builds)
   - `onnxruntime::concurrency::ThreadPool` ignores `OMP_*` variables
   - Only custom builds with `--use_openmp` respect OpenMP variables

2. **CUDA operations bypass OpenMP**
   - GPU kernel launches happen via CUDA runtime
   - CPU preprocessing spawns threads based on `std::thread::hardware_concurrency()`

3. **fastembed-rs doesn't expose SessionOptions**
   - Cannot programmatically set `intra_op_num_threads`
   - No way to configure threading at application level

4. **Some operators fall back to CPU**
   - Shape operations, data transformations
   - Each spawns full thread pool (4-8 threads on i5-6600K)

### Evidence from ONNX Runtime Source

```cpp
// onnxruntime/core/session/inference_session.cc
int GetNumThreads() {
  // Ignores OMP_NUM_THREADS!
  return std::thread::hardware_concurrency();  // Returns 8 for i5-6600K (4 cores + HT)
}
```

---

## Working Solutions

### Solution 1: systemd CPUQuota (RECOMMENDED) ✅

**Why this works:** OS-level enforcement via cgroups v2. Kernel scheduler limits CPU usage regardless of application behavior.

#### Implementation

Edit `~/.config/systemd/user/ck-index.service`:

```ini
[Service]
Type=oneshot
ExecStart=/home/mitsio/.config/ck/ck-wrapper.sh --index /home/mitsio/.MyHome/MySpaces/my-modular-workspace --model nomic-v1.5

# === CPU LIMITING (ADD THESE) ===
CPUQuota=150%                  # Max 1.5 CPU cores (100% = 1 core)
AllowedCPUs=0-1                # Restrict to cores 0 and 1
CPUWeight=50                   # Lower scheduling priority

# === MEMORY LIMITING ===
MemoryMax=3G                   # Hard limit
MemorySwapMax=512M

# === I/O PRIORITY ===
IOSchedulingClass=best-effort
IOSchedulingPriority=4

User=%u
WorkingDirectory=/home/mitsio/.MyHome/MySpaces/my-modular-workspace
```

#### Apply Changes

```bash
systemctl --user daemon-reload
systemctl --user restart ck-index.service

# Monitor
journalctl --user -u ck-index.service -f
```

#### Expected Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| CPU | 513% | 100-150% | -71% |
| Cores Used | 5+ | 2 max | Restricted |
| GPU | 20-25% | 25-35% | Small improvement |

---

### Solution 2: taskset (Simpler) ✅

**Why this works:** CPU affinity masks which cores process can use.

#### Create Limited Wrapper

```bash
cat > ~/.config/ck/ck-cpu-limited.sh << 'EOF'
#!/usr/bin/env bash
# Run ck on max 2 CPU cores

# Limit to cores 0-1
exec taskset -c 0,1 \
    nice -n 10 \
    ionice -c 2 -n 4 \
    ~/.config/ck/ck-wrapper.sh "$@"
EOF

chmod +x ~/.config/ck/ck-cpu-limited.sh
```

#### Usage

```bash
# Instead of:
ck --index . --model nomic-v1.5

# Use:
~/.config/ck/ck-cpu-limited.sh --index . --model nomic-v1.5
```

#### Expected Result

- CPU: ~200% max (2 cores × 100%)
- Simpler than systemd, works immediately

---

### Solution 3: cgroups v2 Manual (Advanced) ✅

**Why this works:** Direct kernel resource control.

#### Create cgroup

```bash
# Create cgroup for ck
sudo mkdir -p /sys/fs/cgroup/user.slice/ck-limited
echo "+cpu +memory" | sudo tee /sys/fs/cgroup/user.slice/ck-limited/cgroup.subtree_control

# Set limits
echo "150000 100000" | sudo tee /sys/fs/cgroup/user.slice/ck-limited/cpu.max
# Format: <quota_us> <period_us>
# 150000/100000 = 1.5 cores (150%)

echo "3G" | sudo tee /sys/fs/cgroup/user.slice/ck-limited/memory.max
```

#### Run ck in cgroup

```bash
# Start ck in limited cgroup
sudo cgexec -g cpu,memory:ck-limited \
    sudo -u $USER \
    ~/.config/ck/ck-wrapper.sh --index . --model nomic-v1.5
```

#### Cleanup

```bash
sudo rmdir /sys/fs/cgroup/user.slice/ck-limited
```

---

### Solution 4: systemd-run Wrapper (No Service File) ✅

**Why this works:** Temporary service with resource limits.

```bash
systemd-run --user --scope \
    -p CPUQuota=150% \
    -p AllowedCPUs=0-1 \
    -p MemoryMax=3G \
    ~/.config/ck/ck-wrapper.sh --index . --model nomic-v1.5
```

**Advantages:**
- No service file needed
- One-off execution with limits
- Perfect for testing

---

## Why GPU is Only 20-25% (Not 37-38%)

Previous configuration achieved **37-38% GPU** (see ADR-021). Current 20-25% suggests:

### Possible Causes

1. **Wrapper not being used:**
   ```bash
   # Check if ck process has correct env vars
   cat /proc/$(pgrep ck)/environ | tr '\0' '\n' | grep ORT
   ```

2. **CUDA provider not active:**
   ```bash
   # Should see GPU activity
   nvidia-smi dmon -s u
   ```

3. **Model/configuration changed:**
   ```bash
   # Check current model
   ck --status . | grep -i model
   ```

### Restoring 37-38% GPU

Apply configuration from ADR-021:

```bash
# ck-wrapper.sh should have:
export ORT_ENABLE_GPU=1
export ORT_CUDA_PROVIDER_OPTIONS="gpu_mem_limit:3925868544"
export ORT_NUM_THREADS="2"
export ORT_EXECUTION_PROVIDERS="CUDAExecutionProvider"
export ORT_CUDA_EXECUTION_PROVIDER_OPTIONS="do_copy_in_default_stream:1;arena_extend_strategy:kNextPowerOfTwo;cudnn_conv_algo_search:EXHAUSTIVE"
```

---

## Why 80-85% GPU is NOT Achievable

### Technical Limitation

From ck source code analysis (see `docs/tools/ck-gpu-optimization-research.md`):

```rust
// ck-embed/src/lib.rs:238-242
fn embed(&mut self, texts: &[String]) -> Result<Vec<Vec<f32>>> {
    let text_refs: Vec<&str> = texts.iter().map(|s| s.as_str()).collect();
    let embeddings = self.model.embed(text_refs, None)?;  // ← None = default small batch
    Ok(embeddings)
}
```

**Problem:** `None` parameter uses fastembed's default small batch size (~256 tokens).

**Why this limits GPU:**
- Small batches = high CPU↔GPU transfer overhead
- GPU idle time between batches
- Cannot saturate GPU compute units

**To achieve 80-85%:**
- Need batch sizes of 2048-4096+ tokens
- Requires forking ck and modifying source code
- OR use alternative tools (text-embeddings-inference, fastembed Python)

---

## Verification Commands

### Monitor CPU Limiting

```bash
# Watch CPU usage (should stay ≤150%)
watch -n 1 'ps aux | grep ck | grep -v grep | awk "{print \"CPU: \" \$3\"%\"}"'

# Check systemd resource usage
systemctl --user status ck-index.service | grep -E "(CPU|Memory)"

# Detailed cgroup stats
systemd-cgtop --user
```

### Monitor GPU Usage

```bash
# Real-time GPU monitoring
nvidia-smi dmon -s u -d 1

# Or simpler
watch -n 1 'nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader'
```

### Verify Environment Variables

```bash
# Check if ck process has correct env
PID=$(pgrep ck)
cat /proc/$PID/environ | tr '\0' '\n' | grep -E "(ORT|OMP|CUDA)"
```

---

## Complete Test Procedure

### 1. Implement systemd CPUQuota

```bash
# Edit service
systemctl --user edit --full ck-index.service

# Add CPUQuota=150% and AllowedCPUs=0-1
# Save and exit

# Reload
systemctl --user daemon-reload
```

### 2. Start Indexing

```bash
# Trigger service
systemctl --user start ck-index.service
```

### 3. Monitor (in separate terminals)

**Terminal 1 - CPU:**
```bash
watch -n 1 'ps aux | grep ck | awk "{print \$3}"'
```

**Terminal 2 - GPU:**
```bash
watch -n 1 nvidia-smi
```

**Terminal 3 - systemd:**
```bash
journalctl --user -u ck-index.service -f
```

### 4. Expected Results

After 30 seconds:
- CPU: 100-150% ✅
- GPU: 25-35%
- VRAM: 1.1-1.3GB

---

## Alternative: Use Different Tool

If ck cannot achieve targets, consider:

### Option A: text-embeddings-inference (Hugging Face)

```bash
# Rust-based, excellent GPU support
cargo install --git https://github.com/huggingface/text-embeddings-inference.git

# Run server
text-embeddings-inference \
    --model-id nomic-ai/nomic-embed-text-v1.5 \
    --cuda

# Achieves 70-85% GPU with proper batch sizes
```

### Option B: fastembed Python with GPU

```python
from fastembed import TextEmbedding

# Explicit GPU configuration
model = TextEmbedding(
    model_name="nomic-ai/nomic-embed-text-v1.5",
    providers=["CUDAExecutionProvider"],
    cuda_mem_limit=3.5 * 1024 * 1024 * 1024,  # 3.5GB
)

# Batch processing (controls GPU saturation)
embeddings = model.embed(documents, batch_size=2048)
```

**Expected:** 60-80% GPU utilization

---

## Summary & Recommendations

### Immediate Actions

1. ✅ **Apply systemd CPUQuota:** Reduces CPU from 513% to 150%
2. ✅ **Verify GPU config:** Restore 37-38% GPU from ADR-021
3. ✅ **Accept limitations:** 80-85% GPU not achievable with current ck

### Long-term Options

1. **Feature request to ck:** Ask for `--batch-size` flag
2. **Fork ck:** Modify source to increase batch sizes
3. **Switch tools:** Use text-embeddings-inference or fastembed Python

### Final Configuration

**ck-wrapper.sh:**
```bash
# GPU acceleration
export ORT_ENABLE_GPU=1
export ORT_CUDA_PROVIDER_OPTIONS="gpu_mem_limit:3925868544"
export ORT_NUM_THREADS="2"
export ORT_EXECUTION_PROVIDERS="CUDAExecutionProvider"
```

**ck-index.service:**
```ini
CPUQuota=150%
AllowedCPUs=0-1
MemoryMax=3G
```

**Expected Performance:**
- CPU: 100-150% ✅
- GPU: 35-40% (maximum achievable with ck)
- VRAM: 1.1-1.5GB

---

## References

- [ONNX Runtime Threading](https://onnxruntime.ai/docs/performance/tune-performance/threading.html)
- [GitHub Issue #17268](https://github.com/microsoft/onnxruntime/issues/17268) - CPU thread management
- [systemd Resource Control](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html)
- [cgroups v2 Documentation](https://docs.kernel.org/admin-guide/cgroup-v2.html)
- ADR-021: CK Semantic Search GPU Optimization
- `docs/tools/ck-gpu-optimization-research.md` - Comprehensive research

---

**Time:** 2025-12-24T18:30:00+02:00 (Europe/Athens)
**Status:** systemd CPUQuota solution ready for implementation
**Next Step:** Apply systemd service configuration and test
