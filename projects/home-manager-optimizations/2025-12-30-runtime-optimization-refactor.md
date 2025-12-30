# Home-Manager Runtime Optimization Refactor

**Date**: 2025-12-30
**Status**: In Progress
**Workspace**: Primary build system (16GB RAM, Skylake i7-6700K, GTX 960)
**Related ADRs**: ADR-024 (Language Runtime Optimizations), ADR-026 (Repo Structure)

## Executive Summary

This refactoring addresses multiple runtime optimization issues in the home-manager configuration:

1. **Fix Node.js Build Failure**: Variable typo blocking hardware-optimized Node.js builds
2. **Integrate Codex Memory-Limited Logic**: Merge orphaned overlay into main codex.nix with RAM-based conditionals
3. **Create LLVM/Clang Optimization**: Add hardware-optimized LLVM overlay for 10-20% faster CUDA compilation
4. **Archive Deprecated Overlays**: Clean up old CUDA 11 and tier-2 Rust configs
5. **Enhance Pre-commit Hooks**: Add overlay variable validation to catch typos
6. **Update Documentation**: ADR-024, create overlay standards guide

**Goals**:
- Optimize CPU usage across runtimes (Go, Rust, Python, Node.js)
- Decrease RAM consumption per runtime
- Leverage GPU usage wherever possible (ONNX Runtime, CUDA compilation)

**Expected Performance Gains**:
- Node.js: 10-30% improvement with FULL PGO + hardware flags
- Codex: 10-15% memory reduction in ≤10GB RAM systems
- LLVM: 10-20% faster CUDA compilation times

## Background: Initial Issues Fixed

### Issue 1: MCP Server Build Failures (RESOLVED)

**Sequential Thinking MCP**:
- Error: 404 fetching from `main` branch
- Root Cause: Repository uses `master` branch
- Fix: `modules/agents/mcp-servers/python-custom.nix:202`
  ```nix
  rev = "master";  # Was "main"
  hash = "sha256-tAIUGHmdmowmyD4tw2WI8wRdE582NLGFmHEfgPXKxxs=";
  ```

**Context7 MCP**:
- Error: Hash mismatch (lib.fakeHash placeholder)
- Fix: `modules/agents/mcp-servers/bun-custom.nix:198`
  ```nix
  hash = "sha256-ntbX2rKg+FXChWHLUdRnKr2TeEuWXouzALeHm1FLsHw=";
  ```

**Python Overlay Deadnix Cleanup**:
- Removed unused declarations in `python-hardware-optimized.nix`
- Changed `final` → `_final` (unused parameter convention)

## Scope: Comprehensive Refactoring

### In-Scope Optimizations

1. **Language Runtimes**:
   - Python (✅ Already optimized with FULL PGO)
   - Rust (✅ Already optimized with PGO + LTO)
   - Go (✅ Already optimized)
   - Node.js (⚠️ BROKEN - needs fix)
   - LLVM/Clang (🔧 NEW - to be created)

2. **AI/ML Infrastructure**:
   - ONNX Runtime (✅ CUDA 12.8 optimized)
   - Codex (🔧 Needs integration with memory-limited mode)

3. **Repository Cleanup**:
   - Archive deprecated overlays
   - Document archival reasons
   - Remove orphaned configs

4. **Quality Assurance**:
   - Pre-commit hook enhancements
   - Overlay variable validation
   - Documentation standards

### Out-of-Scope (For Now)

- Dotnet/C# runtimes (not used in configuration)
- Firefox memory optimization (commented out due to OOM)
- Julia runtime (not currently used)
- Self-hosted binary cache on K8s (future project)

## QnA Decision Log

### Round 1: Initial Architecture

**Q1**: Codex configuration strategy?
- **Decision**: Integrate `codex-memory-limited.nix` into `modules/agents/codex.nix` with conditional logic
- **Rationale**: Single source of truth, RAM-based automatic optimization
- **Threshold**: ≤10GB RAM triggers memory-limited mode

**Q2**: ONNX Runtime version to keep?
- **Decision**: Keep `onnxruntime-gpu-optimized.nix`, archive gpu-11 and minimal gpu-12
- **Rationale**: Optimized version has full features + CUDA 12.8 + cuDNN 9 + TensorRT 10

**Q3**: Node.js optimization approach?
- **Decision**: Fix typo, enable FULL PGO (matching Python strategy)
- **Impact**: 10-30% performance improvement expected

**Q4**: Additional runtime suggestions?
- **Decision**: Create LLVM/Clang hardware-optimized overlay
- **Rationale**: Improves CUDA compilation speed by 10-20%, benefits AI/ML workflow

### Round 2: Implementation Details

**Q5**: Node.js PGO level?
- **Decision**: FULL PGO (matching Python)
- **Trade-off**: 60-90 min build, 8-12GB RAM, but best performance

**Q6**: Codex integration approach?
- **Decision**: Hardware profile conditional
  ```nix
  memoryLimit = if hw.memory.effectiveTotal <= 10 then "3-4" else "4-6";
  ```
- **Implementation**: Use `hw.memory.effectiveTotal` from hardware profile

**Q7**: Archive directory documentation?
- **Decision**: Create `configs-archive/README.md` with detailed reasoning
- **Format**: Table with filename, reason, replacement, date

**Q8**: LLVM optimization timing?
- **Decision**: Apply after Node.js is tested and verified
- **Sequence**: Cleanup → Node.js → Codex → LLVM

### Round 3: Testing & Commits

**Q9**: Testing strategy?
- **Decision**: Test Node.js build only (don't activate in flake.nix yet)
- **Verification**: Document build time, RAM usage, verify no errors
- **Activation**: Only after successful test build

**Q10**: Commit strategy?
- **Decision**: One commit per change
- **Rationale**: Clear history, easy rollback, better git bisect
- **Format**: Conventional commits (fix:, feat:, refactor:, docs:)

**Q11**: ADR updates?
- **Decision**: Update ADR-024 with Node.js FULL PGO decision, LLVM plans
- **New Docs**: Overlay variable standards guide

**Q12**: Codex memory threshold?
- **Decision**: ≤10GB RAM (covers 8GB WSL system)
- **Logic**: `if effectiveTotal <= 10` not `< 10`

### Round 4: Execution Sequence

**Q13**: Execution order?
- **Decision**: Sequential (Cleanup → Node.js → Codex → LLVM)
- **Rationale**: Test each change independently, methodical validation

**Q14**: Cachix strategy?
- **Decision**: Use Cachix for now (5GB limit), plan K8s self-hosted later
- **Future**: Deploy nix-serve or attic on K8s cluster

**Q15**: Preventive measures?
- **Decision**: Full overlay audit + pre-commit hook + documentation
- **Actions**:
  - Audit all overlays for similar typos
  - Add overlay variable validation hook
  - Document NIX_* variable standards

**Q16**: Git archive handling?
- **Decision**: Keep in git history (git mv, not delete)
- **Rationale**: Preserves history, easy to reference/restore

### Round 5: Final Confirmation

**Q17**: Cache strategy confirmation?
- **Decision**: Use Cachix now, self-host later (deferred to separate project)

**Q18**: Pre-commit hook scope?
- **Decision**: Full Nix linting (nixfmt + statix + deadnix + custom overlay validation)
- **Custom Check**: Validate NIX_* variable names against known-good list

**Q19**: Plan document timing?
- **Decision**: After Round 5 (this document)

**Q20**: Go/No-Go?
- **Decision**: ✅ YES, proceed with full plan

## Technical Deep-Dive

### Node.js Build Failure Root Cause

**File**: `modules/system/overlays/nodejs-hardware-optimized.nix`
**Line**: 165

**Current (BROKEN)**:
```nix
env = (old.env or { }) // {
  NIX_CFLAGS_COMPILE = toString cflags;
  NIX_CXXSTDLIB_COMPILE = toString cxxflags;  # ❌ WRONG - typo
  NIX_LDFLAGS = toString ldflags;
};
```

**Correct Fix**:
```nix
env = (old.env or { }) // {
  NIX_CFLAGS_COMPILE = toString cflags;
  NIX_CXXFLAGS_COMPILE = toString cxxflags;  # ✅ CORRECT
  NIX_LDFLAGS = toString ldflags;
};
```

**Why This Broke V8 Build**:
- V8 requires C++20 standard (`-std=c++20`)
- Typo caused C++ flags to be ignored
- V8 compilation defaulted to older C++ standard
- Build failed with "std::string_view not found" errors

**Expected Outcome After Fix**:
- V8 builds with correct C++20 standard
- Hardware flags applied: `-march=skylake -mtune=skylake -O3`
- FULL PGO enabled: 10-30% performance improvement
- Build time: 60-90 minutes (6 threads)
- RAM usage: 8-12GB during build

### Codex Integration Strategy

**Current State**:
- `modules/agents/codex.nix`: Active implementation (Rust-based from flake)
- `modules/system/overlays/codex-memory-limited.nix`: Orphaned helper

**Integration Plan**:

**Before** (codex.nix:42-52):
```nix
codex-pkg = codex-pkg-base.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (if useMold then [ pkgs.mold ] else [ ]);
  CARGO_BUILD_JOBS = cargoJobs;
  # Settings from hardwareProfile.packages.codex
  // ... existing settings
});
```

**After** (integrated):
```nix
let
  # Memory-based optimization
  memoryLimitGb = if hw.memory.effectiveTotal <= 10 then "3-4" else "4-6";
  maxOldSpaceSize = if hw.memory.effectiveTotal <= 10 then "512" else "1024";
in
codex-pkg = codex-pkg-base.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (if useMold then [ pkgs.mold ] else [ ]);
  CARGO_BUILD_JOBS = cargoJobs;

  # Memory-limited mode for ≤10GB systems
  MEMORY_LIMIT_GB = memoryLimitGb;
  NODE_OPTIONS = "--max-old-space-size=${maxOldSpaceSize}";

  # Settings from hardwareProfile.packages.codex
  // ... existing settings
});
```

**Memory Threshold Logic**:
- `effectiveTotal <= 10`: 8GB WSL system, future laptop
- `effectiveTotal > 10`: 16GB desktop, future workstations

**Expected Benefits**:
- 10-15% memory reduction on 8GB systems
- Prevents OOM kills during long MCP sessions
- Automatic adaptation based on hardware profile

### LLVM/Clang Optimization Plan

**File to Create**: `modules/system/overlays/llvm-hardware-optimized.nix`

**Pattern** (following go/rust/python overlays):
```nix
hardwareProfile: _final: prev:

let
  hw = hardwareProfile;
  compiler = hw.build.compiler or { };

  march = compiler.march or "x86-64-v3";
  mtune = compiler.mtune or "generic";
  optimizationLevel = toString (compiler.optimizationLevel or "3");

  hardwareCflags = [
    "-march=${march}"
    "-mtune=${mtune}"
    "-O${optimizationLevel}"
    "-pipe"
    "-fno-semantic-interposition"
  ];

  customCC = prev.wrapCCWith {
    cc = prev.llvmPackages_19.clang-unwrapped;
    bintools = prev.llvmPackages_19.bintools.override {
      extraBuildCommands = ''
        echo "${prev.lib.concatStringsSep " " hardwareCflags}" >> $out/nix-support/cc-cflags
      '';
    };
  };

  optimizedStdenv = prev.stdenvAdapters.overrideCC prev.stdenv customCC;
in
{
  llvmPackages_19 = prev.llvmPackages_19 // {
    stdenv = optimizedStdenv;
    clang = customCC;
  };
}
```

**Expected Performance Gains**:
- 10-20% faster CUDA compilation (nvcc uses host compiler)
- Benefits: ONNX Runtime builds, PyTorch, TensorFlow
- Build time increase: +30-45 minutes (one-time cost)

**Integration Point** (flake.nix:204):
```nix
overlays = [
  (import ./modules/system/overlays/onnxruntime-gpu-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/performance-critical-apps.nix currentHardwareProfile)
  (import ./modules/system/overlays/go-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/rust-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/python-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/llvm-hardware-optimized.nix currentHardwareProfile)  # NEW
  # (import ./modules/system/overlays/nodejs-hardware-optimized.nix currentHardwareProfile) # Enable after test
];
```

## Execution Roadmap

### Phase 1: Cleanup (First Commit)

**Objective**: Archive deprecated overlay configurations

**Actions**:
1. Create `modules/system/overlays/configs-archive/` directory
2. Create `configs-archive/README.md` with archival documentation
3. Move deprecated files using `git mv`:
   - `rust-tier2-optimized.nix` → configs-archive/
   - `onnxruntime-gpu-11.nix` → configs-archive/
   - `onnxruntime-gpu-12.nix` → configs-archive/

**Commit Message**:
```
refactor: archive deprecated overlay configs

Move old/replaced overlays to configs-archive/:
- rust-tier2-optimized.nix (replaced by rust-hardware-optimized)
- onnxruntime-gpu-11.nix (CUDA 11 deprecated, using CUDA 12.8)
- onnxruntime-gpu-12.nix (minimal version, replaced by optimized)

See configs-archive/README.md for detailed reasoning.
```

**Verification**:
- [x] Directory created with proper README
- [x] Files moved (not deleted) via git mv
- [x] Git history preserved
- [ ] Pre-commit hooks pass (in progress)

### Phase 2: Fix Node.js (Second Commit)

**Objective**: Fix variable typo blocking Node.js hardware optimization

**Changes**:
1. Edit `modules/system/overlays/nodejs-hardware-optimized.nix:165`
2. Change `NIX_CXXSTDLIB_COMPILE` → `NIX_CXXFLAGS_COMPILE`
3. Keep overlay disabled in flake.nix (test build only)

**Commit Message**:
```
fix: correct Node.js overlay variable typo

Fix typo NIX_CXXSTDLIB_COMPILE → NIX_CXXFLAGS_COMPILE on line 165.

Root cause of "V8 build fails with -std=c++20" error:
- C++ flags were being ignored due to incorrect variable name
- V8 defaulted to older C++ standard
- Build failed with std::string_view errors

Overlay remains disabled in flake.nix pending successful test build.
```

**Verification**:
- [ ] Typo fixed on line 165
- [ ] Overlay still disabled in flake.nix:197
- [ ] Pre-commit hooks pass

### Phase 3: Test Node.js Build

**Objective**: Verify Node.js builds successfully with hardware optimization

**Test Command**:
```bash
nix build --show-trace --print-build-logs \
  -f '<nixpkgs>' nodejs_22 \
  --arg overlays '[
    (import ./modules/system/overlays/nodejs-hardware-optimized.nix
      (import ./modules/profiles/config/hardware/hardware-profile.nix))
  ]'
```

**Success Criteria**:
- [ ] Build completes without errors
- [ ] V8 compiles with C++20 standard
- [ ] Hardware flags applied (-march=skylake, -mtune=skylake, -O3)
- [ ] FULL PGO training completes

**Documentation**:
- Record build time (expected: 60-90 minutes)
- Record peak RAM usage (expected: 8-12GB)
- Record final binary size
- Save build log excerpt showing V8 compilation success

**If Test Fails**:
- Capture full build log
- Identify new error
- DO NOT proceed to Phase 4
- Investigate and fix issue

### Phase 4: Integrate Codex Overlay (Third Commit)

**Objective**: Merge memory-limited logic into main codex.nix

**Changes**:
1. Edit `modules/agents/codex.nix`
2. Add conditional memory limits based on `hw.memory.effectiveTotal`
3. Move `codex-memory-limited.nix` to configs-archive/

**Commit Message**:
```
feat: integrate codex memory-limited mode conditionally

Add RAM-based optimization to codex.nix:
- Systems with ≤10GB RAM: Use memory-limited settings
  - MEMORY_LIMIT_GB="3-4"
  - NODE_OPTIONS="--max-old-space-size=512"
- Systems with >10GB RAM: Use standard settings
  - MEMORY_LIMIT_GB="4-6"
  - NODE_OPTIONS="--max-old-space-size=1024"

Benefits:
- Prevents OOM kills on 8GB WSL system
- 10-15% memory reduction in constrained environments
- Automatic adaptation via hardware profile

Archive codex-memory-limited.nix (logic now in codex.nix).
```

**Verification**:
- [ ] Conditional logic added to codex.nix
- [ ] Memory threshold uses `<= 10` not `< 10`
- [ ] Old overlay moved to configs-archive/
- [ ] Pre-commit hooks pass
- [ ] Build test (should use >10GB settings)

### Phase 5: Create LLVM Overlay (Fourth Commit)

**Objective**: Add hardware-optimized LLVM/Clang overlay

**Changes**:
1. Create `modules/system/overlays/llvm-hardware-optimized.nix`
2. Follow go/rust/python overlay pattern
3. Target llvmPackages_19 (latest stable)
4. Add to flake.nix overlays list

**Commit Message**:
```
feat: add LLVM/Clang hardware-optimized overlay

Create llvm-hardware-optimized.nix following established overlay pattern:
- Hardware-specific compiler flags from hardware profile
- Supports -march=skylake, -mtune=skylake, -O3
- Benefits CUDA compilation (nvcc uses host compiler)

Expected performance gains:
- 10-20% faster CUDA compilation times
- Improves ONNX Runtime, PyTorch, TensorFlow builds
- One-time build cost: +30-45 minutes

Overlay added to flake.nix but not yet activated (requires testing).
```

**Verification**:
- [ ] Overlay file created
- [ ] Follows hardware-parameterized pattern
- [ ] Added to flake.nix overlays list
- [ ] Pre-commit hooks pass
- [ ] Build test (optional: time-consuming)

### Phase 6: Pre-commit Hook Enhancement

**Objective**: Add overlay variable validation to prevent future typos

**Changes**:
1. Create `scripts/check-overlay-variables.sh`
2. Add validation for known NIX_* variables
3. Integrate into flake.nix hooks configuration

**Script Logic**:
```bash
# Known valid NIX_* variables
VALID_VARS=(
  "NIX_CFLAGS_COMPILE"
  "NIX_CXXFLAGS_COMPILE"
  "NIX_LDFLAGS"
  "NIX_LDFLAGS_BEFORE"
  "NIX_LDFLAGS_AFTER"
  "NIX_BUILD_CORES"
  "NIX_BUILD_JOBS"
)

# Common typos to detect
INVALID_VARS=(
  "NIX_CXXSTDLIB_COMPILE"  # Should be NIX_CXXFLAGS_COMPILE
  "NIX_CXX_COMPILE"        # Should be NIX_CXXFLAGS_COMPILE
  "NIX_LD_FLAGS"           # Should be NIX_LDFLAGS (no underscore)
)

# Check all .nix files in overlays/
for file in modules/system/overlays/*.nix; do
  for invalid in "${INVALID_VARS[@]}"; do
    if grep -q "$invalid" "$file"; then
      echo "ERROR: Invalid NIX variable '$invalid' in $file"
      exit 1
    fi
  done
done
```

**Commit Message**:
```
feat: add overlay variable validation pre-commit hook

Create check-overlay-variables.sh to detect common NIX_* typos:
- Validates against known-good variables list
- Detects common typos (NIX_CXXSTDLIB_COMPILE, etc.)
- Runs automatically on commit

Prevents issues like nodejs-hardware-optimized.nix:165 typo.

Integrated into pre-commit hooks configuration.
```

**Verification**:
- [ ] Script created and executable
- [ ] Detects known typo (test with nodejs file before fix)
- [ ] Integrated into pre-commit system
- [ ] Documented in overlay standards guide

### Phase 7: Audit All Overlays

**Objective**: Find and fix similar variable typos across all overlays

**Audit Checklist**:
- [ ] `go-hardware-optimized.nix`
- [ ] `rust-hardware-optimized.nix`
- [ ] `python-hardware-optimized.nix`
- [ ] `nodejs-hardware-optimized.nix` (already fixing)
- [ ] `llvm-hardware-optimized.nix` (new, verify correct)
- [ ] `onnxruntime-gpu-optimized.nix`
- [ ] `performance-critical-apps.nix`

**Search Patterns**:
```bash
# Search for potential typos
rg "NIX_CXX[^F]" modules/system/overlays/
rg "NIX_LD_FLAGS" modules/system/overlays/
rg "NIX_CXXSTDLIB" modules/system/overlays/
rg "NIX_.*_COMPILE(?!S)" modules/system/overlays/
```

**Documentation**:
- Create `audit-findings.md` in this folder
- List each file audited with status (✅ clean / ⚠️ issues found)
- Document any fixes needed

**Commit Message** (if issues found):
```
fix: correct NIX variable typos in overlays

Audit results:
- file1.nix: Fixed NIX_XXX → NIX_YYY
- file2.nix: No issues found
- ...

See docs/projects/home-manager-optimizations/audit-findings.md
for full audit report.
```

### Phase 8: Documentation

**Objective**: Update ADRs and create overlay standards guide

**Documents to Update/Create**:

1. **Update ADR-024** (Language Runtime Optimizations):
   - Add Node.js FULL PGO decision with rationale
   - Document LLVM overlay creation
   - Update hardware profile matrix
   - Add memory-limited codex strategy

2. **Create `overlay-variable-standards.md` in this folder**:
   ```markdown
   # Nix Overlay Variable Standards

   ## Standard NIX_* Variables

   ### Compiler Flags
   - `NIX_CFLAGS_COMPILE`: C compiler flags
   - `NIX_CXXFLAGS_COMPILE`: C++ compiler flags (⚠️ NOT NIX_CXXSTDLIB_COMPILE)

   ### Linker Flags
   - `NIX_LDFLAGS`: Linker flags (⚠️ NOT NIX_LD_FLAGS)
   - `NIX_LDFLAGS_BEFORE`: Flags before inputs
   - `NIX_LDFLAGS_AFTER`: Flags after inputs

   ### Build Parallelism
   - `NIX_BUILD_CORES`: Cores per derivation
   - `NIX_BUILD_JOBS`: Parallel derivations

   ## Common Typos to Avoid
   - ❌ `NIX_CXXSTDLIB_COMPILE` → ✅ `NIX_CXXFLAGS_COMPILE`
   - ❌ `NIX_CXX_COMPILE` → ✅ `NIX_CXXFLAGS_COMPILE`
   - ❌ `NIX_LD_FLAGS` → ✅ `NIX_LDFLAGS`

   ## Validation
   Pre-commit hook `check-overlay-variables.sh` validates these automatically.
   ```

3. **Update `configs-archive/README.md` in home-manager repo**:
   - Already created with detailed archival reasoning

**Commit Message** (for ADR updates in docs repo):
```
docs: update ADR-024 and create overlay standards guide

Updates:
- ADR-024: Document Node.js FULL PGO, LLVM overlay, codex memory-limited
- New: overlay-variable-standards.md with NIX_* variable reference

Related to runtime optimization refactor (2025-12-30).
```

**Verification**:
- [ ] ADR-024 updated with all decisions
- [ ] Overlay standards guide created
- [ ] All links working

## Performance Expectations

### Build Time Costs (One-Time)

| Component | Build Time | RAM Usage | Notes |
|-----------|-----------|-----------|-------|
| Node.js FULL PGO | 60-90 minutes | 8-12GB | Initial build only |
| Codex (from source) | 15-25 minutes | 4-6GB | Rust compilation |
| LLVM/Clang optimized | 30-45 minutes | 6-8GB | One-time cost |
| **Total** | **~2-3 hours** | **Peak 12GB** | Parallel builds may reduce time |

### Runtime Performance Gains

| Runtime | Optimization | Expected Gain | Verification Method |
|---------|-------------|---------------|---------------------|
| Node.js | FULL PGO + hwflags | 10-30% | Benchmark MCP servers, codex startup |
| Python | FULL PGO (existing) | 10-30% | Already applied, measure import time |
| Rust | PGO + LTO (existing) | 10-20% | cargo build times, ck-search speed |
| Go | hwflags (existing) | 2-8% | go build times |
| Codex | Memory-limited mode | 10-15% less RAM | Monitor systemd scope memory usage |
| CUDA | LLVM optimization | 10-20% faster compile | nvcc compilation benchmarks |

### Memory Impact

| System | Total RAM | After Optimization | Headroom |
|--------|-----------|-------------------|----------|
| Primary (16GB) | 16GB | ~12GB used (builds) | 4GB free |
| WSL (8GB) | 8GB | ~6GB used (runtime) | 2GB free (improved) |

## Risk Assessment

### High Risk Areas

1. **Node.js FULL PGO Build**:
   - Risk: OOM kill during PGO training on 8GB system
   - Mitigation: Build only on 16GB system, use Cachix for WSL
   - Fallback: Reduce to LIGHT PGO if FULL fails

2. **LLVM Overlay Impact**:
   - Risk: Breaks existing CUDA toolchain
   - Mitigation: Test build without activation first
   - Fallback: Revert overlay, use stock llvmPackages

3. **Cachix 5GB Limit**:
   - Risk: Optimized builds exceed cache space
   - Mitigation: Use `nix-store --gc` to clean old builds
   - Long-term: Self-host on K8s (separate project)

### Medium Risk Areas

4. **Codex Memory-Limited Integration**:
   - Risk: Break existing codex functionality
   - Mitigation: Test on both 16GB and 8GB systems
   - Verification: Run sample codex commands, monitor memory

5. **Pre-commit Hook False Positives**:
   - Risk: Hook blocks valid variable names
   - Mitigation: Maintain whitelist of valid variables
   - Escape hatch: `git commit --no-verify` (documented)

### Low Risk Areas

6. **Archive Operation**:
   - Risk: Accidentally delete needed configs
   - Mitigation: Use `git mv` to preserve history
   - Recovery: Files remain in git history

## Testing & Verification Matrix

| Phase | Test Type | Success Criteria | Rollback Plan |
|-------|-----------|------------------|---------------|
| 1: Cleanup | Git history | Files moved (not deleted) | `git reset --hard HEAD~1` |
| 2: Node.js Fix | Static analysis | No syntax errors, typo fixed | `git revert <commit>` |
| 3: Node.js Build | Full build test | Build completes, V8 compiled | Don't activate overlay |
| 4: Codex | Runtime test | Codex runs, memory within limits | `git revert <commit>` |
| 5: LLVM | Build test | LLVM builds successfully | Don't activate overlay |
| 6: Pre-commit | Hook test | Detects known typos | Remove from hooks config |
| 7: Audit | Code review | All overlays checked | N/A (read-only) |
| 8: Docs | Review | ADRs updated, guides complete | Fix documentation |

## Future Work (Deferred)

### K8s Self-Hosted Binary Cache

**Motivation**: Cachix 5GB limit insufficient for optimized builds

**Options**:
1. **nix-serve** (official Nix tool):
   - Pros: Official, simple setup
   - Cons: Single-threaded, basic features

2. **attic** (modern alternative):
   - Pros: Multi-threaded, better performance, garbage collection
   - Cons: Newer project, less battle-tested

**Deployment Plan** (separate project):
1. Create Kubernetes deployment manifest
2. Set up persistent volume for nix store
3. Configure ingress with TLS (Let's Encrypt)
4. Update nixpkgs substituters to include self-hosted cache
5. Test with optimized builds
6. Document setup in new ADR

**Timeline**: After current refactor completes successfully

### Additional Runtime Optimizations

- **Julia**: If ML/scientific computing needs arise
- **Java/JVM**: If Java-based tools added to workspace
- **Haskell GHC**: If Haskell development begins

## References

- **ADR-024**: Language Runtime Hardware Optimizations
- **ADR-026**: Repository Structure and Organization
- **Node.js Overlay**: `modules/system/overlays/nodejs-hardware-optimized.nix`
- **Codex Config**: `modules/agents/codex.nix`
- **Hardware Profiles**:
  - Primary: `modules/profiles/config/hardware/` (hardware-specific settings)
  - WSL: `modules/profiles/config/hardware/` (memory-constrained)
- **Pre-commit Hooks**: `flake.nix:259-368` (pre-commit-check configuration)

## Appendix: QnA Full Transcript

(Detailed record of all 20 questions and decisions from 5 QnA rounds - preserved for future reference and accountability)

### Round 1
**Q1-Q4**: Initial architecture decisions (Codex, ONNX, Node.js, LLVM)

### Round 2
**Q5-Q8**: Implementation details (PGO levels, conditionals, documentation, timing)

### Round 3
**Q9-Q12**: Testing and commit strategy (build-only testing, granular commits, ADR updates, memory thresholds)

### Round 4
**Q13-Q16**: Execution sequence (cleanup first, Cachix usage, preventive measures, git history preservation)

### Round 5
**Q17-Q20**: Final confirmation (cache strategy, pre-commit scope, documentation timing, go/no-go)

---

**Document Status**: ✅ Complete
**Next Action**: Complete Phase 1 commit (home-manager repo)
**Estimated Total Time**: 2-3 hours (build time) + 1-2 hours (implementation/testing)
