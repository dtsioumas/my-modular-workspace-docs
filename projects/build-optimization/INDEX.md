# Project: Workspace Build & Resource Optimization

**Status:** ACTIVE
**Goal:** Maximize build throughput and system responsiveness through intelligent resource management.

## Documentation Index

- [**RESEARCH.md**](RESEARCH.md): Deep analysis of build bottlenecks (Nix, Rust, C++), linker optimizations (mold), and memory management (ZRAM).
- [**PLAN.md**](PLAN.md): Implementation steps for hardware-aware build strategies.

## Key Strategies
- **Linker Optimization**: Using `mold` for significantly faster Rust and C++ linking.
- **Job Capping**: Intelligently limiting `max-jobs` based on RAM and CPU core counts (e.g., 6 cores/2 jobs for 16GB systems).
- **ZRAM Tuning**: Aggressive ZRAM allocation (75% of RAM) to handle memory-heavy builds (ONNX, Firefox).
- **Binary Caching**: Using Cachix and local caches to minimize redundant compilation.

## Related Resources
- **ADR**: `docs/adrs/ADR-017-HARDWARE_AWARE_BUILD_OPTIMIZATIONS.md`
- **Nix Config**: `home-manager/modules/system/oom-protected-wrappers.nix`
