# CK Semantic Search - Verified Performance Results

**Date:** 2025-12-24 23:56 EET
**Hardware:** shoshin (GTX 960 4GB VRAM, i5-6600K 4C/4T, 15GB RAM)
**Configuration:** systemd CPUQuota + AllowedCPUs
**Service:** ck-index.service (automated indexing)

---

## Verified Performance Metrics

**Test Duration:** 31+ minutes continuous indexing
**Target Directory:** `~/.MyHome/MySpaces/my-modular-workspace`
**Model:** nomic-v1.5 (768 dims, 8k context)

### Final Results

| Metric | Before Optimization | After Optimization | Target | Status |
|--------|---------------------|-------------------|---------|---------|
| **CPU Usage** | 513% | **99.2%** | 100-150% | ✅ Exceeded |
| **CPU Reduction** | - | **81%** | - | ✅ Success |
| **GPU Utilization** | 37-38% | **13-32%** (variable) | 80-85% | ❌ Limited |
| **VRAM Usage** | 1.1GB | **1.1GB (1133 MiB)** | 3GB+ | ❌ Limited |
| **Memory** | - | **1.5G / 3G max** | - | ✅ Within limits |
| **Uptime** | - | **31+ min stable** | - | ✅ Stable |

---

## Solution: systemd CPUQuota

**Working Configuration:** `~/.config/systemd/user/ck-index.service`

```ini
[Service]
Type=oneshot
ExecStart=/home/mitsio/.config/ck/ck-wrapper.sh --index /path --model nomic-v1.5

# CPU Limiting (CRITICAL - This is what works!)
CPUQuota=150%                  # Hard limit to 1.5 CPU cores
AllowedCPUs=0-1                # Restrict to cores 0-1 only
CPUWeight=50                   # Lower scheduling priority

# Memory Limiting
MemoryMax=3G
MemorySwapMax=512M

# I/O Priority
IOSchedulingClass=best-effort
IOSchedulingPriority=4
Nice=10

# Security
NoNewPrivileges=true
PrivateTmp=true
```

---

## Why This Works

### systemd CPUQuota vs OpenMP

**❌ OpenMP Environment Variables (OMP_NUM_THREADS) - DOES NOT WORK:**
- ONNX Runtime uses its own threading system
- `onnxruntime::concurrency::ThreadPool` ignores `OMP_*` variables
- CPU remained at 513% even with `OMP_NUM_THREADS=4`

**✅ systemd CPUQuota - WORKS:**
- OS-level enforcement via cgroups v2
- Kernel scheduler limits CPU usage regardless of application threading
- Hard limit: process cannot exceed specified quota
- Works for ANY application, not just OpenMP-aware programs

---

## GPU Limitations Confirmed

**Why GPU Cannot Reach 80-85%:**

1. **Batch Size Bottleneck:**
   ```rust
   // ck source code (ck-embed/src/lib.rs:238-242)
   let embeddings = self.model.embed(text_refs, None)?;  // ← None = small default batch
   ```

2. **Small Batches = High Overhead:**
   - CPU↔GPU transfer overhead dominates
   - GPU idle time between batches
   - Cannot saturate GPU compute units

3. **No User Configuration:**
   - ck does not expose batch size parameter
   - fastembed-rs defaults to small batches (~256 tokens)
   - Achieving 80-85% requires 2048-4096+ token batches

**Maximum Achievable:** 40-50% GPU on GTX 960 with current ck implementation

---

## Verification Commands

### Monitor Real-Time Performance

```bash
# CPU usage (should stay ≤150%)
ps aux | grep "ck --index" | grep -v grep

# Expected output:
# mitsio   1136147 99.2  9.2 ... ck --index ...

# GPU monitoring
nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader

# Expected output:
# 13 %, 1133 MiB  (varies 13-32%)

# systemd service status
systemctl --user status ck-index.service
```

### Verify systemd Limits Are Active

```bash
# Check that cgroup limits are applied
systemctl --user show ck-index.service | grep -E "(CPUQuota|AllowedCPUs|Memory)"

# Expected:
# CPUQuotaPerSecUSec=1500000us  (150%)
# AllowedCPUs=0-1
# MemoryMax=3221225472           (3GB)
```

---

## Performance Over Time

**Observation Period:** 31+ minutes continuous operation

| Time | CPU % | GPU % | VRAM (MiB) | Notes |
|------|-------|-------|------------|--------|
| 0-10 min | 99-102% | 22-40% | 1133 | Initial indexing |
| 10-20 min | 97-99% | 13-32% | 1133 | Steady state |
| 20-31 min | 99% | 18-37% | 1133 | Stable |

**Conclusion:** systemd CPUQuota provides **consistent, reliable CPU limiting** with zero degradation over time.

---

## Alternative Solutions (If GPU >80% Required)

If high GPU utilization is critical, consider:

1. **Fork ck** - Modify source to increase batch sizes
2. **text-embeddings-inference** (Hugging Face) - Better GPU support, achieves 70-85%
3. **fastembed Python** - Explicit batch size control

See: `docs/tools/onnx-runtime-cpu-limiting.md` for details.

---

## References

- **Research:** `docs/tools/ck-gpu-optimization-research.md`
- **CPU Limiting Guide:** `docs/tools/onnx-runtime-cpu-limiting.md`
- **ADR-021:** `docs/adrs/ADR-021-CK_SEMANTIC_SEARCH_GPU_OPTIMIZATION.md`
- **Configuration:** `dotfiles/private_dot_config/ck/`

---

**Status:** Production-ready
**Last Verified:** 2025-12-24 23:56 EET
**Uptime Record:** 31+ minutes stable, no issues
