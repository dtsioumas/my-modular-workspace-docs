# ck-search FP16 Implementation Quick Reference

**Purpose:** Reduce VRAM usage from 4GB to 2GB using FP16 quantized models
**Time Required:** 2-3 hours
**Risk Level:** Low (non-destructive, reversible)
**Recommended:** Only if VRAM pressure becomes an issue

---

## Why FP16 on GTX 960?

| Benefit | Value | Applies to GTX 960? |
|---------|-------|-------------------|
| **Speed Improvement** | 2-4x faster | ❌ No (no Tensor Cores) |
| **VRAM Reduction** | 50% less | ✅ Yes (4GB → 2GB) |
| **Memory Bandwidth** | 50% less | ✅ Yes (helps with transfers) |
| **Accuracy Loss** | Typically <1% | ✅ Acceptable for embeddings |

**Verdict:** Use FP16 for VRAM savings, NOT for speed.

---

## Implementation Steps

### Step 1: Install Python Dependencies
```bash
pip install --upgrade onnx onnxruntime
```

### Step 2: Download Current Model
```bash
# Check where ck stores models
ls ~/.cache/fastembed/

# Or download directly
mkdir -p /tmp/onnx-models
cd /tmp/onnx-models
huggingface-cli download nomic-ai/nomic-embed-text-v1.5 \
  --include "*.onnx" --local-dir .
```

### Step 3: Quantize to FP16
```bash
python3 << 'EOF'
import onnx
import numpy as np
import sys

# Input/output paths
input_model = "/tmp/onnx-models/model.onnx"
output_model = "/tmp/onnx-models/model-fp16.onnx"

print(f"Loading: {input_model}")
model = onnx.load(input_model)

# Convert all FP32 weights to FP16
converted = 0
for initializer in model.graph.initializer:
    # Check if it's FP32 (data_type = 1)
    if initializer.data_type == 1:
        # Convert raw_data to FP16
        data = np.frombuffer(initializer.raw_data, dtype=np.float32)
        data_fp16 = data.astype(np.float16)
        initializer.data_type = 10  # FP16
        initializer.raw_data = data_fp16.tobytes()
        converted += 1

print(f"Converted {converted} initializers to FP16")

# Save
onnx.save(model, output_model)
print(f"Saved: {output_model}")

# Verify
orig_size = len(np.fromfile(input_model, np.uint8)) / (1024**3)
new_size = len(np.fromfile(output_model, np.uint8)) / (1024**3)
print(f"Size reduction: {orig_size:.2f}GB → {new_size:.2f}GB ({100*(1-new_size/orig_size):.1f}%)")
EOF
```

### Step 4: Test FP16 Model Locally
```bash
# First, verify it loads
python3 << 'EOF'
import onnxruntime as ort
import numpy as np

# Load FP16 model
sess = ort.InferenceSession(
    "/tmp/onnx-models/model-fp16.onnx",
    providers=['CUDAExecutionProvider', 'CPUExecutionProvider']
)

# Test inference
dummy_input = {
    sess.get_inputs()[0].name: np.random.randn(1, 384).astype(np.float32)
}
output = sess.run(None, dummy_input)
print(f"✅ Model loads successfully")
print(f"Input shape: {dummy_input[sess.get_inputs()[0].name].shape}")
print(f"Output shape: {output[0].shape}")
EOF
```

### Step 5: Benchmark FP16 vs FP32
```bash
# Create benchmark script
cat > /tmp/benchmark_fp16.py << 'EOF'
import onnxruntime as ort
import numpy as np
import time
import os

os.environ['CUDA_DEVICE_MAX_CONNECTIONS'] = '32'

# Load both models
print("Loading FP32 model...")
sess_fp32 = ort.InferenceSession(
    "/tmp/onnx-models/model.onnx",
    providers=['CUDAExecutionProvider', 'CPUExecutionProvider']
)

print("Loading FP16 model...")
sess_fp16 = ort.InferenceSession(
    "/tmp/onnx-models/model-fp16.onnx",
    providers=['CUDAExecutionProvider', 'CPUExecutionProvider']
)

# Dummy input
input_name = sess_fp32.get_inputs()[0].name
dummy_input = np.random.randn(64, 384).astype(np.float32)

# Warmup
sess_fp32.run(None, {input_name: dummy_input[:1]})
sess_fp16.run(None, {input_name: dummy_input[:1]})

# Benchmark
runs = 10
print(f"\nBenchmarking {runs} runs of batch_size=64...")

print("\n--- FP32 ---")
times_fp32 = []
for i in range(runs):
    start = time.time()
    sess_fp32.run(None, {input_name: dummy_input})
    elapsed = time.time() - start
    times_fp32.append(elapsed)
    print(f"  Run {i+1}: {elapsed*1000:.2f}ms")

print("\n--- FP16 ---")
times_fp16 = []
for i in range(runs):
    start = time.time()
    sess_fp16.run(None, {input_name: dummy_input})
    elapsed = time.time() - start
    times_fp16.append(elapsed)
    print(f"  Run {i+1}: {elapsed*1000:.2f}ms")

avg_fp32 = np.mean(times_fp32[2:])  # Skip first 2 warmup
avg_fp16 = np.mean(times_fp16[2:])
ratio = avg_fp16 / avg_fp32

print(f"\nAverage: FP32={avg_fp32*1000:.2f}ms, FP16={avg_fp16*1000:.2f}ms")
print(f"Speed: FP16 is {ratio:.2f}x ({100*(ratio-1):+.1f}%)")
EOF

# Run benchmark with GPU monitoring
watch -n 0.5 'nvidia-smi | grep -E "GPU|Mem"' &
WATCH_PID=$!
sleep 2

python3 /tmp/benchmark_fp16.py

kill $WATCH_PID
```

### Step 6: Update ck to Use FP16 Model
```bash
# Copy FP16 model to accessible location
mkdir -p ~/.cache/fastembed-models
cp /tmp/onnx-models/model-fp16.onnx ~/.cache/fastembed-models/

# For ck: Create wrapper or update environment
cat > ~/.config/ck/ck-wrapper-fp16.sh << 'EOF'
#!/usr/bin/env bash
# Wrapper using FP16 model

export ORT_ENABLE_GPU=1
# Reduced GPU memory for FP16 (50% less)
export ORT_CUDA_PROVIDER_OPTIONS="gpu_mem_limit:2000000000"

# Fewer CPU threads (FP16 lighter)
export ORT_NUM_THREADS="4"
export ORT_INTER_OP_NUM_THREADS="2"
export ORT_INTRA_OP_NUM_THREADS="2"

# Point to FP16 model directory
export FASTEMBED_MODELS_PATH="~/.cache/fastembed-models"

# Run ck with FP16
exec nice -n 10 \
    ionice -c 2 -n 7 \
    ck "$@"
EOF

chmod +x ~/.config/ck/ck-wrapper-fp16.sh
```

### Step 7: Monitor During Indexing
```bash
# Terminal 1: GPU usage
watch -n 0.5 'nvidia-smi --query-gpu=index,memory.used,memory.free,utilization.gpu,power.draw --format=csv,noheader'

# Terminal 2: System memory
watch -n 0.5 'free -h | head -2'

# Terminal 3: Run indexing with FP16
time ~/.config/ck/ck-wrapper-fp16.sh --index ~/.MyHome/MySpaces/my-modular-workspace --model nomic-embed-text-v1.5
```

### Step 8: Compare Results
```bash
# Document results
cat > /tmp/fp16-benchmark-results.txt << 'EOF'
=== FP32 vs FP16 Comparison ===

FP32 Baseline:
- VRAM Used: 1131 MiB
- GPU Utilization: 37-38%
- Indexing Time: 2-3 minutes
- CPU Usage: 390%

FP16 Test:
- VRAM Used: ___ MiB (expected ~550-560)
- GPU Utilization: ___ % (expected 37-38%, same)
- Indexing Time: ___ minutes (expected 2-3, might be slightly slower)
- CPU Usage: ___ % (expected similar)

Decision:
[ ] Keep FP16 (VRAM savings valuable)
[ ] Revert to FP32 (no benefit for us)
EOF
```

---

## Reverting to FP32
```bash
# Simply stop using the FP16 wrapper
unalias ck-fp16
rm ~/.config/ck/ck-wrapper-fp16.sh

# ck will use default FP32 model
ck --index ~/.MyHome/MySpaces/my-modular-workspace
```

---

## Troubleshooting

### Model won't load
```bash
# Check if ONNX model is valid
python3 << 'EOF'
import onnx
model = onnx.load("/tmp/onnx-models/model-fp16.onnx")
onnx.checker.check_model(model)
print("✅ Model is valid")
EOF
```

### VRAM didn't decrease
Possible causes:
1. Model didn't fully quantize (check conversion script output)
2. ONNX Runtime cached FP32 version (clear cache: `rm -rf ~/.cache/onnxruntime`)
3. Other processes using VRAM

### FP16 is actually slower
This is expected on GTX 960 (Maxwell no Tensor Cores). The 5-10% slowdown is normal. Only use FP16 if VRAM is your constraint.

---

## Environment Variables Reference

### FP32 (Current)
```bash
export ORT_CUDA_PROVIDER_OPTIONS="gpu_mem_limit:3925868544"  # 3.66GB
export ORT_NUM_THREADS="6"
```

### FP16 (Lower VRAM)
```bash
export ORT_CUDA_PROVIDER_OPTIONS="gpu_mem_limit:2000000000"  # 2GB
export ORT_NUM_THREADS="4"
```

---

## When to Use FP16

✅ **Use FP16 if:**
- VRAM usage consistently >3GB (approaching 4GB limit)
- You want to try larger batches (with 2GB headroom)
- You're running multiple concurrent ck operations
- VRAM pressure is limiting functionality

❌ **Don't use FP16 if:**
- Current 1.1GB usage is comfortable
- Speed is important (FP16 is slower on Maxwell)
- Accuracy is critical (though loss is typically <1% for embeddings)

---

## Documentation & Tracking

### After Testing
1. Record results in `/tmp/fp16-benchmark-results.txt`
2. Document decision in project notes
3. If keeping: Update ADR-021 to include FP16 results
4. If reverting: Keep script for future reference

### Files Created
- `/tmp/onnx-models/model-fp16.onnx` — Quantized model
- `~/.config/ck/ck-wrapper-fp16.sh` — FP16 wrapper script
- `~/.cache/fastembed-models/` — Model cache

---

**Last Updated:** 2025-12-26
**Recommended:** Check VRAM usage first; only implement if needed
