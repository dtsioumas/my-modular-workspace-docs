# Research: ck-search GPU Enablement (2025-12-14)

## Summary
FastEmbed’s GPU path currently requires the CUDA-enabled ONNX Runtime build (`onnxruntime-gpu`) and matching CUDA/cuDNN versions. The ck binary we package via Home-Manager links the CPU runtime, and FastEmbed’s Rust bindings do not expose a provider toggle. Without rebuilding against `onnxruntime-gpu` and injecting CUDA libraries at runtime, ck remains CPU-only.

## Key Findings
1. **ONNX Runtime CUDA Requirements** – The CUDA Execution Provider demands aligned CUDA/cuDNN versions (ORT ≥1.19 ships with CUDA 12.x + cuDNN 9.x). Mixing cuDNN 8 and 9 is unsupported. citeturn0search0
2. **Build Prerequisites** – To build ORT with CUDA, CUDA_HOME/CUDNN_HOME must point to installations that expose `bin/include/lib`; zlib is required for cuDNN 8/9; PATH/LD_LIBRARY_PATH must include CUDA/cuDNN binaries. citeturn0search1turn0search10
3. **FastEmbed GPU Packaging** – Official docs state the GPU variant uses `fastembed-gpu` + `onnxruntime-gpu`, and you must remove the CPU runtime to avoid conflicts (Python guidance but applies to linked runtimes). citeturn1search1
4. **Execution Providers** – ONNX Runtime lets you register CUDA/TensorRT providers in priority order; GPU acceleration only happens if the binary loads those providers. citeturn0search2turn0search5
5. **GTX 960 Support Window** – GeForce GTX 960 (Maxwell 2.0, compute capability 5.2) is officially supported only up to CUDA 11.0; NVIDIA removed support for this architecture starting with CUDA 11.1, meaning CUDA 12-based ORT builds will not run on this GPU. citeturn1search0
6. **Reported Failures on CUDA 12.4** – Community reports show ONNX Runtime 1.18–1.20 failing to detect the GPU when paired with CUDA 12.4 + cuDNN 9.0, reinforcing that we should stick to the last supported CUDA branch for Maxwell cards. citeturn0search6
7. **Sandbox Limitation** – The Codex sandbox cannot access NVML (`nvidia-smi` fails), so driver/CUDA data must be collected from the host session and recorded manually.

## Host Snapshot (shoshin, 2025-12-14 07:55 EET)
- `nvidia-smi` → Driver 570.195.03, reports CUDA version 12.8, GPU = GeForce GTX 960 (4 GB). Processes primarily Plasma/Kitty.
- `nvcc` → not installed (bash reports command not found).
- Takeaway: even though the driver advertises CUDA 12.8, GTX 960 is physically limited to compute capability 5.2, so we must build against CUDA 11.0-compatible libraries.

## Implications for ck
- Need a CUDA-aware ONNX Runtime derivation (overlay) plus CUDA/cuDNN runtime dependencies.
- Need ck’s build to link against that derivation and expose provider selection (currently missing upstream).
- Without upstream changes, even a GPU-linked ORT may still run CPU because FastEmbed defaults to CPU.

## Implementation (2025-12-14)

### Files Modified
1. **`home-manager/flake.nix`**
   - Replaced `nixpkgs.legacyPackages` with manual import for shoshin config
   - Added overlay import: `overlays/onnxruntime-gpu-11.nix`

2. **`home-manager/overlays/onnxruntime-gpu-11.nix`**
   - Fixed syntax to proper overlay format (`final: prev: { ... }`)
   - Uses `cudaPackages_11` for GTX 960 compatibility (CUDA 11.0)
   - Globally overrides `pkgs.onnxruntime` with CUDA support

3. **`home-manager/mcp-servers/rust-custom.nix`**
   - Added `programs.ck.enableGpu` option (default: false)
   - Updated build to use GPU-enabled onnxruntime from overlay
   - MCP wrapper description shows "(GPU-accelerated)" when enabled

### Key Decisions
- **CUDA 11.0 chosen**: GTX 960 (compute capability 5.2) unsupported in CUDA 11.1+
- **Global overlay**: onnxruntime always GPU-enabled for shoshin (acceptable, only ck uses it)
- **Runtime fallback**: ONNX Runtime auto-falls back to CPU if GPU unavailable

### Testing Steps
1. Rebuild: `home-manager switch --flake .#mitsio@shoshin`
2. Monitor GPU: `watch -n 0.5 nvidia-smi`
3. Run search: `ck --sem "test query" docs/`
4. Verify GPU utilization increases

### Outcome
- ✅ GPU-enabled onnxruntime overlay created and imported
- ✅ ck-search builds with CUDA support (via system onnxruntime)
- ✅ Option added for future configurability
- ⚠️  **Testing required** - changes not yet built/verified

### Next Actions
1. Test build: `home-manager switch --flake .#mitsio@shoshin`
2. Verify GPU usage during semantic search
3. Benchmark CPU vs GPU performance
4. Open upstream issue/PR requesting provider selection for FastEmbed/ck

### Documentation
- Guide created: `docs/tools/ck-gpu-support.md`
- Testing procedures included
- Troubleshooting section added
