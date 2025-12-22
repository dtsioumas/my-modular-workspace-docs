# ck-search GPU Support (CUDA 11.0)

**Status**: ✅ Implemented (2025-12-14)
**Target Hardware**: NVIDIA GTX 960 (Compute Capability 5.2)
**CUDA Version**: 11.0 (max supported by GTX 960)

## Overview

ck-search can now leverage GPU acceleration via CUDA for faster semantic search operations. This is achieved through:
1. GPU-enabled ONNX Runtime overlay (CUDA 11.0 + cuDNN)
2. Rust build configuration using system ONNX Runtime
3. Optional home-manager configuration flag

## Implementation Details

### Files Modified

1. **`flake.nix`**
   - Imports `overlays/onnxruntime-gpu-11.nix` for shoshin configuration
   - Replaces `legacyPackages` with manual nixpkgs import

2. **`overlays/onnxruntime-gpu-11.nix`**
   - Overrides `pkgs.onnxruntime` with CUDA 11.0 support
   - Uses `cudaPackages_11` for GTX 960 compatibility

3. **`mcp-servers/rust-custom.nix`**
   - Adds `programs.ck.enableGpu` option (default: false)
   - Builds ck-search against GPU-enabled onnxruntime
   - MCP wrapper shows "(GPU-accelerated)" when enabled

### How It Works

The overlay globally replaces `pkgs.onnxruntime` with a CUDA-enabled version for the shoshin configuration. This means:
- ✅ ck-search automatically gets GPU-accelerated ONNX Runtime
- ✅ No code changes needed in ck-search itself
- ✅ Falls back to CPU if GPU unavailable at runtime
- ⚠️  All packages using onnxruntime get the GPU version (currently only ck-search)

## Enabling GPU Support

### In home.nix

Add this configuration:

```nix
# home.nix
{
  programs.ck.enableGpu = true;
}
```

### Rebuild Home-Manager

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin
```

## Testing GPU Acceleration

### Test 1: Verify GPU-enabled ONNX Runtime

```bash
# Check ck dependencies
nix-store --query --requisites $(which ck) | grep onnxruntime
```

Expected: Should show onnxruntime with CUDA in dependencies

### Test 2: Monitor GPU Usage During Search

Terminal 1 - Monitor GPU:
```bash
watch -n 0.5 nvidia-smi
```

Terminal 2 - Run semantic search:
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace
ck --sem "kubernetes GPU acceleration" docs/ --n 10
```

Expected behavior:
- `nvidia-smi` should show increased GPU utilization
- GPU memory usage should increase during search
- Search should complete faster than CPU-only version

### Test 3: Verify MCP Server Description

```bash
systemctl --user status mcp-ck*.scope 2>/dev/null || echo "No active MCP sessions"
```

When ck MCP server is running, the description should show "(GPU-accelerated)".

## Performance Expectations

### GTX 960 Specifications
- **CUDA Cores**: 1024
- **Memory**: 4GB GDDR5
- **Compute Capability**: 5.2
- **Max CUDA Version**: 11.0

### Expected Improvements
- **Semantic search**: 2-5x faster (depends on model size)
- **Index building**: 1.5-3x faster
- **Memory usage**: +500MB-1GB GPU memory

## Troubleshooting

### GPU Not Detected

**Symptom**: ck runs but GPU shows 0% utilization

**Solutions**:
1. Check NVIDIA driver:
   ```bash
   nvidia-smi
   ```

2. Verify CUDA libraries:
   ```bash
   ls /run/opengl-driver/lib/libcuda*
   ```

3. Check onnxruntime CUDA support:
   ```bash
   nix-store --query --requisites $(which ck) | grep -i cuda
   ```

### CUDA Version Mismatch

**Symptom**: Error about CUDA version incompatibility

**Solution**: GTX 960 is limited to CUDA 11.0. The overlay is correctly configured for this. If you see errors, check:
```bash
nix-store --query --tree $(which ck) | grep -E "cuda|cudnn"
```

### Out of GPU Memory

**Symptom**: CUDA out-of-memory errors

**Solutions**:
1. Reduce batch size (if configurable in ck)
2. Search smaller directories
3. Close other GPU-using applications
4. Fall back to CPU mode (remove `enableGpu` option)

## Upstream Tracking

### FastEmbed GPU Support

**Issue**: FastEmbed (ck's embedding library) doesn't expose GPU provider selection at build time.

**Current State**:
- FastEmbed uses ONNX Runtime for embeddings
- GPU support requires CUDA-enabled ONNX Runtime build
- No runtime flag to select CPU vs GPU provider

**Workaround**:
- Our implementation provides GPU-enabled ONNX Runtime at build time
- ONNX Runtime automatically uses CUDA if available
- Falls back to CPU if GPU unavailable

### Related Issues

Track these for upstream improvements:
1. BeaconBay/ck - Request GPU provider selection flag
2. FastEmbed - Request runtime provider configuration

## Future Improvements

### Planned Enhancements
- [ ] Add runtime environment variable to force CPU mode
- [ ] Benchmark suite comparing CPU vs GPU performance
- [ ] Optional overlay (currently always active for shoshin)
- [ ] Support for newer CUDA versions (when upgrading GPU)

### Alternative Approaches Considered
1. **Separate GPU-specific package**: Rejected (maintains two builds)
2. **Dynamic library loading**: Rejected (complex, fragile)
3. **Upstream patch**: Waiting for FastEmbed API changes

## References

- Plan: `docs/plans/2025-12-14-ck-rebuild-for-gpu-usage-plan.md`
- Research: `docs/researches/2025-12-14_ck_gpu_investigation.md`
- ADR-010: `docs/adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md`
- ONNX Runtime CUDA EP: https://onnxruntime.ai/docs/execution-providers/CUDA-ExecutionProvider.html

---

**Last Updated**: 2025-12-14
**Tested On**: NixOS 25.05, GTX 960, Driver 570.195.03
**Confidence**: 0.85 (Band C - SAFE)
