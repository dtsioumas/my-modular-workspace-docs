# ADR-028: Comprehensive Runtime and Build Optimizations

**Status:** Implemented ✅
**Date:** 2025-12-30
**Authors:** Mitsos, Claude Sonnet 4.5
**Related ADRs:** ADR-017 (Hardware-Aware Builds), ADR-024 (Language Runtimes), ADR-025 (Cachix Strategy)

---

## Context

### Problem Statement

The home-manager configuration suffered from:
1. **Slow builds**: 2-4 hours for full rebuild due to sequential processing
2. **Underutilized hardware**: Only using 2 of 8 threads (25% CPU)
3. **Generic binaries**: Language runtimes using generic x86_64 builds without Skylake optimizations
4. **No foundation optimization**: System libraries (glibc, zlib, openssl) not optimized for hardware

### Research Findings

From comprehensive plan (2025-12-30-comprehensive-home-manager-refactor-plan.md):
- **System libraries**: 3-40% performance gains (glibc: 3-8%, openssl AES-NI: 20-40%)
- **Language runtimes**: 5-30% performance gains with PGO + hardware flags
- **Build parallelism**: Current 2 jobs → 12 jobs possible with tier-based memory management
- **Expected build time**: 2-4 hours → 60-90 minutes for full rebuild

---

## Decision

### Three-Phase Optimization Strategy

#### Phase 0: Foundation Layer - System Libraries

**Overlay:** `modules/system/overlays/system-libs-hardware-optimized.nix`

**Libraries Optimized:**
- **glibc** (affects ALL binaries): `-march=skylake -O3`
- **zlib** (compression): `-march=skylake -O3 -fuse-ld=mold`
- **zstd** (modern compression): `-march=skylake -O3 -fuse-ld=mold`
- **openssl** (crypto + AES-NI): `-march=skylake -O3` + `enable-ec_nistp_64_gcc_128`
- **libgcrypt** (GnuPG crypto): `-march=skylake -O3 -fuse-ld=mold`
- **libsodium** (NaCl crypto): `-march=skylake -O3 -fuse-ld=mold`

**Expected Gains:**
- glibc: 3-8% (universal improvement)
- zlib: 10-20% compression/decompression
- zstd: 15-30% compression speed
- openssl: 20-40% crypto operations (AES-NI acceleration)
- libgcrypt: 15-25% hashing/encryption
- libsodium: 10-20% crypto operations

**Trade-offs:**
- Build time: ~20-40 minutes (one-time)
- Forces rebuild of dependent packages
- No binary cache (hardware-specific)

#### Phase 2: Language Runtimes

**Overlays:**
- `nodejs-hardware-optimized.nix` (Node.js 24)
- `python-hardware-optimized.nix` (Python 3.13)
- `rust-hardware-optimized.nix` (rustc + cargo)
- `go-hardware-optimized.nix` (Go 1.24)

**Optimizations Applied:**

| Runtime | PGO | Hardware Flags | Linker | Memory | Expected Gain |
|---------|-----|----------------|--------|--------|---------------|
| **Node.js 24** | FULL | `-march=skylake -O3` | mold | jemalloc | 10-25% CPU, 10-30% RAM |
| **Python 3.13** | FULL | Custom stdenv | mold | - | 10-30% |
| **Rust (rustc)** | YES | `-march=skylake -O3` | mold | jemalloc | 10-15% rustc, 8-15% binaries |
| **Go 1.24** | - | `GOAMD64=v3` (AVX2) | mold | - | 3-10% |

**Key Features:**
- **PGO (Profile-Guided Optimization)**: Training on realistic workloads
- **Thin LTO**: Cross-module inlining without full LTO memory cost
- **mold linker**: 30-50% faster linking
- **jemalloc**: 10-30% memory reduction (Node.js, Rust)
- **Hardware-aware codegen**: AVX2, BMI2, F16C instruction sets

**Trade-offs:**
- Node.js build: 60-90 minutes (PGO training)
- Python build: 45-75 minutes (PGO training)
- Rust build: ~45 minutes (PGO + bootstrap)
- Go build: ~20 minutes

#### Phase 4: Build Parallelism Optimization

**Hardware Profile:** `modules/profiles/config/hardware/shoshin.nix`

**Tier-Based Build Strategy:**

```nix
# Global Nix settings (flake.nix)
maxJobs = 12;     # Maximum parallel derivations
cores = 6;        # Default cores per build

# Tier 1: Heavy Builds (Node.js PGO, Python PGO, Rust PGO)
tier1MaxJobs = 1;          # Sequential only
tier1Cores = 7;            # Full CPU (88% utilization)
tier1MemoryLimit = 14 GB;  # High memory

# Tier 2: Medium Builds (Go, Rust crates, MCP servers)
tier2MaxJobs = 3;          # Moderate parallelism
tier2Cores = 4;            # Shared CPU
tier2MemoryLimit = 6 GB;   # Moderate memory

# Tier 3: Light Builds (CLI tools, libraries)
tier3MaxJobs = 12;         # Maximum parallelism
tier3Cores = 2;            # Minimal CPU
tier3MemoryLimit = 2 GB;   # Low memory
```

**Parallelism Improvements:**

| Setting | Old Value | New Value | Impact |
|---------|-----------|-----------|--------|
| maxJobs | 2 | 12 | 6x more parallel builds |
| maxCores | 6 | 7 | 17% more CPU per build |
| cargoBuildJobs | 2 | 4 | 2x faster Rust compilation |
| linkerJobs | 2 | 4 | 2x faster linking |

**Memory Management:**
- Total: 28GB (16GB RAM + 12GB zram)
- Reserved for system: 7GB
- Available for builds: 21GB
- Tier-based limits prevent OOM

---

## Implementation

### Overlay Application Order (flake.nix)

```nix
overlays = [
  # 1. BUILD FIXES
  (import ./modules/system/overlays/pre-commit-no-dotnet.nix)

  # 2. FOUNDATION LAYER (Phase 0)
  (import ./modules/system/overlays/system-libs-hardware-optimized.nix currentHardwareProfile)

  # 3. MEMORY-OPTIMIZED APPS
  (import ./modules/system/overlays/onnxruntime-gpu-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/performance-critical-apps.nix currentHardwareProfile)

  # 4. LANGUAGE RUNTIMES (Phase 2)
  (import ./modules/system/overlays/nodejs-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/go-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/rust-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/python-hardware-optimized.nix currentHardwareProfile)
];
```

### Node.js Critical Fix (2025-12-30)

**Issue:** V8 build failed with `-std=c++20` flag
**Root Cause:** Typo in `nodejs-hardware-optimized.nix:165`
- **Before:** `NIX_CXXSTDLIB_COMPILE` (invalid variable)
- **After:** `NIX_CXXFLAGS_COMPILE` (correct variable)

**Impact:** Node.js overlay was completely disabled, preventing optimization
**Resolution:** Fixed typo + re-enabled overlay in flake.nix
**Commits:** `f697cbd`, `8fca5d2`

### Hardware Profile Updates

**File:** `modules/profiles/config/hardware/shoshin.nix`

**Changes:**
```nix
parallelism = {
  maxJobs = 12;        # Was: 2  → 6x increase
  maxCores = 7;        # Was: 6  → 17% increase
  cargoBuildJobs = 4;  # Was: 2  → 2x increase
  linkerJobs = 4;      # Was: 2  → 2x increase

  # NEW: Tier-based limits
  tier1MaxJobs = 1;          # Heavy PGO builds
  tier1Cores = 7;
  tier1MemoryLimit = 14;     # GB

  tier2MaxJobs = 3;          # Medium builds
  tier2Cores = 4;
  tier2MemoryLimit = 6;

  tier3MaxJobs = 12;         # Light builds
  tier3Cores = 2;
  tier3MemoryLimit = 2;
};
```

---

## Expected Performance Impact

### Build Time Improvements

| Phase | Old Time | New Time | Speedup |
|-------|----------|----------|---------|
| **System Libraries** | N/A | 20-40 min | New optimization |
| **Node.js (PGO)** | N/A | 60-90 min | New optimization |
| **Python (PGO)** | 75 min | 45-75 min | Parallelism gain |
| **Rust (PGO)** | 60 min | 45 min | Parallelism gain |
| **Full Rebuild** | 2-4 hours | **60-90 minutes** | **2-4x faster** |

### Runtime Performance Improvements

| Component | Optimization | Expected Gain |
|-----------|-------------|---------------|
| **All programs** | glibc + system libs | 3-8% universal |
| **Node.js agents** | V8 + PGO + jemalloc | 10-25% CPU, 10-30% RAM |
| **Python scripts** | Interpreter PGO | 10-30% |
| **Rust binaries** | rustc PGO + codegen | 8-15% |
| **Go tools** | GOAMD64=v3 (AVX2) | 3-10% |
| **Crypto ops** | openssl AES-NI | 20-40% |
| **Compression** | zlib/zstd optimized | 10-30% |

### Memory Footprint Improvements

| Component | Optimization | Expected Reduction |
|-----------|-------------|-------------------|
| **Node.js** | jemalloc | 10-30% |
| **Rust binaries** | jemalloc | 10-20% |
| **Overall** | Better allocators | 5-15% system-wide |

---

## Consequences

### Positive

1. **Dramatically faster builds**: 60-90 minutes vs 2-4 hours (2-4x speedup)
2. **Better hardware utilization**: 88% CPU (7/8 cores) vs 25% (2/8 cores)
3. **Runtime performance gains**: 10-30% for language runtimes, 3-8% system-wide
4. **Memory efficiency**: 10-30% reduction in runtime footprint
5. **Crypto acceleration**: 20-40% faster with AES-NI (openssl)
6. **Portable**: Works across workspaces (shoshin, gyakusatsu, kinoite) with hardware profile fallbacks

### Negative

1. **One-time build cost**: ~90-120 minutes for initial build of all optimized packages
2. **No binary cache**: Hardware-specific builds cannot use Hydra cache
3. **Increased complexity**: Tier-based parallelism requires maintenance
4. **Rebuilds cascade**: Updating system libs forces runtime rebuilds
5. **Memory risk**: Aggressive parallelism can OOM if tier limits are wrong

### Mitigations

1. **Cachix**: Push optimized builds to personal cache (ADR-025, 5GB limit)
2. **Tier limits**: Conservative memory limits prevent OOM
3. **Fallback values**: Hardware profile defaults to x86-64-v3 + generic when missing
4. **Documentation**: This ADR + inline comments explain rationale
5. **Selective optimization**: Can disable PGO per-runtime if needed (e.g., `enablePGO = false`)

---

## Validation

### Dry-Run Test

```bash
home-manager switch --flake .#mitsio@shoshin --dry-run
```

**Expected behavior:**
- Node.js overlay evaluates correctly (no C++20 errors)
- All runtime overlays apply successfully
- System libs overlay applies to foundational packages
- No evaluation errors

### Build Test

```bash
# Build system libraries first (Phase 0)
nix build --show-trace .#homeConfigurations.mitsio@shoshin.config.home.packages.glibc
nix build --show-trace .#homeConfigurations.mitsio@shoshin.config.home.packages.zlib
nix build --show-trace .#homeConfigurations.mitsio@shoshin.config.home.packages.openssl

# Build language runtimes (Phase 2)
nix build --show-trace .#homeConfigurations.mitsio@shoshin.config.home.packages.nodejs_24
nix build --show-trace .#homeConfigurations.mitsio@shoshin.config.home.packages.python313
nix build --show-trace .#homeConfigurations.mitsio@shoshin.config.home.packages.rustc
nix build --show-trace .#homeConfigurations.mitsio@shoshin.config.home.packages.go

# Full rebuild
home-manager switch --flake .#mitsio@shoshin
```

**Success criteria:**
- All builds complete without OOM
- Build time < 90 minutes
- No errors in build logs
- Runtime binaries show hardware flags in `--version` or metadata

### Performance Validation

```bash
# Verify hardware flags applied
node --version  # Should show custom build metadata
python3 --version
rustc --version --verbose  # Check "host" and "LLVM version"

# Benchmark improvements (optional)
# Compare optimized vs nixpkgs binaries
```

---

## Maintenance

### When to Rebuild

1. **Hardware upgrade**: Update `modules/profiles/config/hardware/shoshin.nix` with new CPU/RAM/GPU specs
2. **Runtime updates**: Nixpkgs unstable updates Node.js/Python/Rust → auto-rebuild with optimizations
3. **Performance issues**: Adjust tier limits if OOM occurs
4. **New workspace**: Create hardware profile for gyakusatsu/kinoite

### Monitoring

```bash
# Check build resource usage
nix build --show-trace --print-build-logs ...

# Monitor memory during build
watch -n 1 'free -h && ps aux --sort=-%mem | head -20'

# Check Cachix usage
cachix usage modular-workspace
```

### Tuning

**If OOM occurs:**
1. Reduce tier1MemoryLimit (14GB → 12GB)
2. Reduce tier2MaxJobs (3 → 2)
3. Disable PGO for specific runtime (e.g., Node.js)

**If build too slow:**
1. Increase tier2MaxJobs (3 → 4)
2. Increase tier3MaxJobs (12 → 16)
3. Push more packages to Cachix

---

## Related Work

- **ADR-017**: Hardware-Aware Build Optimizations (framework)
- **ADR-024**: Language Runtime Hardware Optimizations (runtimes)
- **ADR-025**: Cachix Build Strategy (binary cache)
- **ADR-026**: Home Manager Structure Standard (overlay organization)

**Comprehensive Plan:** `docs/projects/home-manager-optimizations/2025-12-30-comprehensive-home-manager-refactor-plan.md`

---

**Approved By:** Mitsos
**Date:** 2025-12-30
**Implementation Status:** ✅ Completed (Phase 0, Phase 2, Phase 4)
