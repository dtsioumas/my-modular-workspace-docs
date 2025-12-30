# Issue: ONNX Runtime Build Performance & Memory OOM
**Date:** 2025-12-25
**Status:** RESOLVED

## Problem
Building ONNX Runtime from source was causing System Out of Memory (OOM) and extremely slow build times.
- Parallel jobs were too high for the available 16GB RAM + 12GB ZRAM.
- LTO (Link Time Optimization) was consuming excessive memory during the linking phase.

## Resolution
1. **Resource Capping:**
   - Modified the Nix derivation to limit parallel jobs using `ninjaJobs = 2;`.
   - Optimized the linker by using `mold` instead of `ld` (3-8x faster, 50% less memory).
2. **Configuration Adjustments:**
   - Disabled LTO for debug/iterative builds where performance was secondary to build success.
   - Reserved 1 core and 2GB RAM for system operations to prevent system lockups.

## Prevention
- Always cap parallel jobs for heavy C++ builds on systems with <32GB RAM.
- Use `mold` for large Rust and C++ projects.
- Monitor ZRAM usage during builds to ensure swap isn't thrashing.
