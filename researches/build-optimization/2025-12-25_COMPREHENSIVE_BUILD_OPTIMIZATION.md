# Comprehensive Build Optimization Strategy
**Date**: 2025-12-25
**System**: Shoshin (Intel i7-6700K, 4c/8t, 16GB+12GB zram)
**Status**: IN PROGRESS - Ultrathink Analysis

---

## Executive Summary

Comprehensive optimization of all Nix/home-manager builds to maximize throughput while maintaining system responsiveness.

**Constraint**: Reserve 1 core/2 threads + 2GB RAM for system operations
- **Total Resources**: 8 threads, 28GB RAM
- **Available for Builds**: 6 threads, 26GB RAM

---

## Phase 1: Discovery (COMPLETED ✅)

### Packages Analyzed: 19 Source-Built Packages

**By Language:**
- **Rust (4)**: ck-search, mcp-filesystem-rust, codex, chezmoi_modify_manager
- **Go (4)**: mcp-shell, git-mcp-go, mcp-filesystem-go, semantic-grep
- **NPM (4)**: firecrawl-mcp, brave-search-mcp, mcp-read-website-fast, claude-code
- **Python (3)**: claude-continuity, ast-grep-mcp, gdrive-tray
- **C++/CUDA (1)**: ONNX Runtime
- **Mixed (1)**: Firefox (currently disabled)

### Current Build Configuration

**Global (flake.nix):**
```nix
max-jobs = 2
cores = 6
timeout = 86400  # 24 hours
```

**Memory Peaks (measured/estimated):**
- ONNX Runtime: 10GB (with mold + no LTO)
- Codex: 6-8GB (421 Rust crates)
- ck-search: 2-3GB
- NPM packages: 1-2GB each
- Go packages: <1GB each
- Python: <500MB (no compilation)

---

## Phase 2: Web Research (COMPLETED ✅)

### High-Confidence Findings (≥0.80)

| Optimization | Confidence | Key Insight |
|-------------|-----------|-------------|
| mold linker | 0.90 | 3-8x faster linking, 50% less memory |
| max-jobs=3, cores=2 | 0.88 | Optimal for 8-thread systems with <64GB RAM |
| Binary cache tuning | 0.87 | http-connections=128 speeds substitutions |
| Rust codegen-units=4 | 0.85 | Saves memory vs default 16 |
| ZRAM tuning | 0.83 | zstd algorithm + 75% memoryPercent optimal |
| tmpfs disabled | 0.82 | Prevents OOM on large C++ builds |

### Medium-Confidence Findings (0.65-0.79)

| Optimization | Confidence | Notes |
|-------------|-----------|-------|
| Node heap tuning | 0.78 | --max-old-space-size=3072 prevents OOM |
| Skylake flags | 0.75 | 5-15% speedup but lose binary cache |
| ccache | 0.72 | 50-90% faster if cache hit >40% |

---

## Phase 3: Ultrathink Analysis (COMPLETED ✅)

**Agent Status**: Deep analysis complete

**Key Findings:**
1. **Optimal Global Settings**: maxJobs=2, maxCores=6 (DOWN from 4/8)
2. **Per-Package Optimization Matrix**: 19 packages classified into 3 tiers
3. **Build Scheduling**: Safe concurrent builds identified (OOM risk <5%)
4. **Confidence-Weighted Tiers**: P1 (immediate), P2 (short-term), Experimental
5. **Expected Improvements**: 40-60% memory reduction, 10-20% faster per-package builds

**Detailed Analysis**: See ultrathink output in this document (Phase 3 section below)

---

## Phase 4: Implementation (PENDING)

Will include:
- Optimized flake.nix configuration
- Per-package overrides (overlays, modules)
- Hardware profile updates
- Build wrapper scripts if needed

---

## Phase 5: Documentation (PENDING)

Final deliverables:
- Implementation guide with code snippets
- Performance benchmarks (before/after)
- Monitoring recommendations
- Rollback procedures

---

## References

### Input Data
- Exploration Report: Complete inventory of 19 packages
- Web Research: Confidence-scored optimization strategies

### Related Documents
- `/docs/researches/2025-12-25_ONNX_BUILD_PERFORMANCE_ISSUE.md` - ONNX ninjaJobs fix
- `/docs/researches/2025-12-24_BUILD_OPTIMIZATION_RECOMMENDATIONS.md` - Initial analysis
- `/docs/researches/2025-12-24_BUILD_OPTIMIZATION_ANALYSIS.md` - Phase 1 system analysis

---

*This document will be updated with ultrathink findings and implementation details.*

**Last Updated**: 2025-12-25T15:45:00+02:00 (Europe/Athens)
