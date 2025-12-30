# Comprehensive Home-Manager Refactor & Optimization Plan

**Date**: 2025-12-30
**Status**: Planning Complete - Ready for Implementation
**Planner**: Architecture & Deep Planning Mode
**Primary Workspace**: shoshin (16GB RAM, i7-6700K Skylake, GTX 960)
**Secondary Workspace**: gyakusatsu (8GB WSL, AMD Zen3, No GPU)

**Related Documents**:
- [Runtime Optimization Refactor](./2025-12-30-runtime-optimization-refactor.md) - Original plan (Phases 1-8)
- ADR-024: Language Runtime Hardware Optimizations
- ADR-025: Cachix Build Strategy (gyakusatsu pulls from shoshin)
- ADR-027: Workspace-Specific Build Optimization (NEW - to be created)
- ADR-028: System Libraries Hardware Optimization (NEW - to be created)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [QnA Decision Matrix](#qna-decision-matrix)
3. [Web Research: Latest Tool Versions](#web-research-latest-tool-versions)
4. [Build Strategy & Parallelism](#build-strategy--parallelism)
5. [Phase 0: System Libraries Foundation](#phase-0-system-libraries-foundation)
6. [Phase 1: LLVM Compiler Infrastructure](#phase-1-llvm-compiler-infrastructure)
7. [Phase 2: Language Runtimes (Python, Rust, Node.js, Go)](#phase-2-language-runtimes)
8. [Phase 3: Kubernetes & IaC Tooling](#phase-3-kubernetes--iac-tooling)
9. [Phase 4: Build Optimization & Workspace Decoupling](#phase-4-build-optimization--workspace-decoupling)
10. [Workspace-Specific Configurations](#workspace-specific-configurations)
11. [ADR Documentation Requirements](#adr-documentation-requirements)
12. [Risk Assessment & Mitigation](#risk-assessment--mitigation)
13. [Timeline & Execution Roadmap](#timeline--execution-roadmap)
14. [Integration with Existing Plans](#integration-with-existing-plans)

---

## Executive Summary

This comprehensive refactor addresses **five major objectives**:

1. **System-Wide Performance Foundation**: Build ALL critical system libraries (glibc, zlib, zstd, openssl, libgcrypt, libsodium, libstdc++, libc++) with hardware-specific optimizations BEFORE any language runtimes
2. **Maximum Hardware Utilization**: Increase parallelism from maxJobs=2 to intelligent tier-based system (up to 12 jobs for light packages) while using 7/8 CPU cores and leaving 6-8GB RAM for system
3. **Comprehensive Kubernetes Toolkit**: Install complete K8s tooling for CKA certification, production SRE work, and dissertation meta-operator development
4. **Workspace-Specific Optimization**: Decouple shoshin (build server) and gyakusatsu (lightweight consumer) with intelligent tiered Cachix caching
5. **Infrastructure as Code Setup**: Install both OpenTofu v1.10.0 and Terraform v1.14.3 with tenv version manager for maximum compatibility

**Key Performance Expectations**:
- **System-wide gain**: 5-10% performance improvement across ALL applications (from optimized system libraries)
- **CUDA compilation**: 10-20% faster (from LLVM optimization - already planned)
- **Language runtimes**: 10-30% improvement (from FULL PGO - already planned, not being changed)
- **Build time reduction**: 15-25% faster cold builds (from better parallelization)
- **Cachix efficiency**: 80%+ cache hit rate on gyakusatsu (from tiered caching strategy)

**Total Estimated Build Time** (First Run on shoshin):
- Phase 0 (System Libs): 2.5-3.5 hours
- Phase 1 (LLVM): 30-45 minutes
- Phase 2 (Runtimes): 2-3 hours (Python FULL PGO 60-90min + Rust PGO 45min + Node.js FULL PGO 60-90min + Go 15min)
- Phase 3 (K8s Tools): 5-15 minutes (mostly pre-compiled binaries)
- Phase 4 (Build Config): 10-20 minutes (test builds)
- **TOTAL**: 6-8 hours first build, then <30 minutes for incremental changes with Cachix

**Critical Decision**: Test Node.js fix FIRST (from original plan Phase 2) before triggering full refactor. Validates build process and Cachix workflow.

---

## QnA Decision Matrix

All decisions from 5 comprehensive QnA rounds with full user approval.

### Round 1: Foundation & Scope

| Decision Point | User Choice | Rationale |
|---------------|-------------|-----------|
| **Build time optimization priorities** | Reduce initial build time + Improve Cachix utilization | **CRITICAL**: Do NOT sacrifice runtime optimizations. Leverage shoshin hardware fully, use cache for heavy binaries to reduce cold rebuilds on other workspaces. |
| **Build distribution strategy** | Selective builds (gyakusatsu builds lightweight packages only) | gyakusatsu pulls heavy packages (runtimes with PGO, ONNX, CUDA) from Cachix. Builds only lightweight CLI tools locally. Prevents OOM on 8GB WSL. |
| **Kubernetes use case** | All of the above (comprehensive toolkit) | CKA certification prep + Production SRE work at Eyeonix + Dissertation meta-operator development. Need complete toolset. |

### Round 2: Tooling & Optimizations

| Decision Point | User Choice | Rationale |
|---------------|-------------|-----------|
| **K8s toolkit priorities** | Core + Debugging + Context switchers | kubectl v1.35, Helm, stern (logs), kubectx/kubens (productivity). CKA essentials + daily workflow efficiency. |
| **Additional runtimes to optimize** | LLVM/Clang + System libraries + Containers (SKIP) | LLVM already planned. System libs (glibc, openssl) = foundational (5-10% system-wide gain). Skip containers (use nixpkgs defaults, good enough). |
| **Cachix caching strategy** | Tiered caching (Tier 1→Cachix, Tier 2/3→local) | Use existing tier system from ADR. Tier 1 (runtimes with PGO, ONNX) cached. Tier 2 (Codex, MCP) gyakusatsu local. Tier 3 (CLI) always local. Clear, predictable. |
| **IaC tooling preference** | Both OpenTofu + Terraform (with tenv) | OpenTofu v1.10.0 + Terraform v1.14.3. Use tenv (unified version manager, now in nixpkgs). Work compatibility (Eyeonix uses Terraform) + personal preference (OpenTofu). |

### Round 3: Build Strategy & Timeline

| Decision Point | User Choice | Rationale |
|---------------|-------------|-----------|
| **Build time reduction strategies** | **MAXIMIZE hardware utilization** + Keep FULL PGO + Optimize dependencies + **Document as ADR** | **User already increased maxJobs to 12 in other repos (dotfiles, NixOS)**. Use 7 of 8 CPU cores. Leave 6-8GB RAM+swap for system/Plasma. **NO compromise on PGO** - want full optimization gains from long rebuilds. Split heavy derivations for better caching. |
| **Workspace-specific packages** | Skip CUDA/GPU packages on gyakusatsu | WSL has no GPU. Skip ONNX Runtime GPU, CUDA builds. Saves ~30min build time, ~500MB Cachix space. Pull CPU-only if needed. |
| **kubectl plugins (krew)** | Defer krew/plugins (vanilla kubectl for now) | Focus on vanilla kubectl for CKA exam preparation. Add plugins later based on actual workflow needs. Simplifies initial setup. |
| **Implementation timeline** | **Runtimes and optimizations FIRST, THEN K8s tools** | Priority: System libs (Phase 0) → LLVM (Phase 1) → Language runtimes (Phase 2) → K8s tools (Phase 3). Get performance foundation right first, then add tooling. |

### Round 4: Technical Implementation Details

| Decision Point | User Choice | Rationale |
|---------------|-------------|-----------|
| **Parallelism configuration** | **Combination: Dynamic tier-based + Conservative aggressive** + **Document as ADR** | Tier 1 (heavy): maxJobs=1, cores=6. Tier 2 (medium): maxJobs=2-3, cores=4. Tier 3 (light): maxJobs=12, cores=2. PLUS global maxJobs=6, cores=6 as fallback. Prevents OOM while maximizing throughput. **Create ADR-027** for this. |
| **System libraries build timing** | **Phase 0 (before runtimes)** | System libs are FOUNDATIONAL. Build glibc, zlib, openssl FIRST. Language runtimes link against them, so optimizing libs first cascades performance gains to everything. |
| **Container runtime optimization** | Skip container optimizations (use nixpkgs defaults) | containerd, runc already fast enough. Focus optimization effort on system libs and language runtimes only. Don't overcomplicate. |
| **Final go/no-go** | **YES, create plan and proceed** | Full approval for comprehensive refactor. Understands scope and build time impact. |

### Round 5: Final Technical Details

| Decision Point | User Choice | Rationale |
|---------------|-------------|-----------|
| **System libraries to optimize** | **ALL critical system libs (comprehensive foundation)** | Selected ALL options: Core runtime (glibc, zlib, zstd) + Crypto (openssl, libgcrypt, libsodium) + C++ stdlib (libstdc++, libc++) + comprehensive others (ncurses, readline, sqlite). Maximum system-wide performance impact. Build time: +2.5-3.5 hours one-time. |
| **K8s tools installation method** | Mix: nixpkgs for most, latest for critical (kubectl latest) | kubectl 1.35 (latest, for CKA exam alignment) fetched directly. Helm, k9s, stern from nixpkgs (binary cache, stable). Best of both: Latest kubectl + cached binaries for other tools. |
| **ADRs to create** | ADR-027 (Workspace Build) + ADR-028 (System Libraries) | ADR-027: Document tier-based parallelism, workspace package selection, Cachix tiered caching. ADR-028: Document Phase 0 strategy, build order, system libs rationale. (Note: K8s ADR deferred - not selected.) |
| **Final confirmation** | **Yes, but Node.js fix first as test** | Before full refactor, test Node.js typo fix (from original plan Phase 2). Validates build process, Cachix workflow, pre-commit hooks. Then proceed with comprehensive refactor. More cautious approach. |

---

## Web Research: Latest Tool Versions

Comprehensive research conducted 2025-12-30 for latest stable versions.

### Infrastructure as Code (IaC)

| Tool | Latest Stable | Release Date | Source | Notes |
|------|---------------|--------------|--------|-------|
| **OpenTofu** | v1.10.0 | June 23, 2025 | [GitHub Releases](https://github.com/opentofu/opentofu/releases) | Most comprehensive update yet. Features: OCI registry support, Native S3 state locking (no DynamoDB), deprecation support, enhanced planning with -target-file/-exclude-file. v1.11.0 in beta (RC available). |
| **Terraform** | v1.14.3 | December 17, 2025 | [HashiCorp Releases](https://releases.hashicorp.com/terraform/) | Latest stable from HashiCorp. Earlier versions: 1.14.0, 1.14.1, 1.14.2. Alpha v1.15.0-alpha20251203 in development. |
| **tenv** | Latest in nixpkgs | Merged 2025 | [GitHub](https://github.com/tofuutils/tenv) | Unified version manager for OpenTofu/Terraform/Terragrunt/Atmos. **Successor to tfenv + tofuenv**. Now in nixpkgs - install directly without custom derivation. |

**Installation Strategy**: Install both OpenTofu v1.10.0 + Terraform v1.14.3 via tenv. Use `tenv tf use 1.14.3` / `tenv tofu use 1.10.0` for switching. Maximum compatibility for work (Eyeonix Terraform) + personal (OpenTofu preference).

### Kubernetes CLI Tools

| Tool | Latest Stable | Release Date | Source | Notes |
|------|---------------|--------------|--------|-------|
| **kubectl** | v1.35 / v1.34.2 | August 27, 2025 (v1.34) | [Kubernetes Releases](https://kubernetes.io/releases/) | v1.34 released Aug 27, v1.35 available. AWS EKS docs (Nov 2025) list v1.34.2 as latest patch. **CKA exam based on v1.34**. Version compatibility: ±1 minor version of cluster. |
| **Helm** | v3.16+ | 2025 | [Helm Releases](https://github.com/helm/helm/releases) | De facto K8s package manager. CNCF Graduated project. Install from nixpkgs unstable (~v3.15+). |
| **k9s** | v0.50.16 | October 20, 2025 | [GitHub Releases](https://github.com/derailed/k9s/releases) | Kubernetes TUI tool. Latest in 0.50 series. Features: Real-time resource tracking, custom resources, metrics, logs, scaling, port-forwards, restarts. Plugin support. |
| **krew** | Latest in nixpkgs | 2025 | [Krew Website](https://krew.sigs.k8s.io/) | kubectl plugin manager. Over 200 plugins available. Note: **Deferred per QnA Round 3** - install krew but no plugins initially (vanilla kubectl for CKA prep). |

**Kubernetes Ecosystem Tools** (from web research):

| Category | Tools | Priority | Notes |
|----------|-------|----------|-------|
| **Context/Namespace Switchers** | kubectx, kubens, kubecolor | **HIGH** (QnA Round 2) | Fast context switching, colored output. **⚠️ NOT available in CKA exam** - but essential for daily multi-cluster work. Install from nixpkgs. |
| **Log Aggregation** | stern, kubectl-stern | **HIGH** (Core + Debugging) | Tail logs across all pods in deployment/namespace. Color-coded per pod. Essential for troubleshooting. Install from nixpkgs or via krew. |
| **Debugging** | kubectl-tree, kubectl-neat, kubectl-debug | **MEDIUM** | Resource hierarchy visualization (tree), clean YAML output (neat), ephemeral containers (debug). Via krew when ready. |
| **Local Dev Clusters** | kind, k3d, minikube | **DEFERRED** (QnA: defer local dev) | kind = pure K8s (for testing). k3d = fastest (k3s in Docker). minikube = feature-rich, stable. **Decision**: Install kind + k3d for dissertation meta-operator testing later. |
| **Validation** | kubeval, kube-linter, conftest | **DEFERRED** | YAML validation, policy enforcement, security scanning. Good for CI/CD. Install when needed for production workflows. |

### CKA Certification Context

**Exam Details** (from web research):
- **Current Version**: Based on Kubernetes v1.34
- **Duration**: 2 hours
- **Tasks**: 15-20 hands-on tasks in remote shell
- **Pass Score**: 66%
- **Troubleshooting Weight**: 30% of score

**Essential Skills for CKA**:
- Master kubectl, YAML, official documentation
- Core debugging: `kubectl describe`, `kubectl logs`, `kubectl get events`
- Metrics: Metrics Server for `kubectl top` (resource monitoring)
- Practice tasks in 5 minutes or less
- Use aliases, kubectl explain efficiently
- **⚠️ Tools NOT available in exam**: kubectx, kubens, kubecolor, stern, krew plugins

**Recommendation**: Focus on vanilla kubectl mastery first (aligns with QnA decision to defer krew/plugins). Add productivity tools (kubectx, stern) after CKA exam for daily work efficiency.

### kubectl Krew Plugins Ecosystem

**Top Essential Plugins** (from web research, for future reference):

| Plugin | Purpose | Category | Install When |
|--------|---------|----------|--------------|
| **ctx** (kubectx) | Fast context switching | Productivity | Post-CKA (daily work) |
| **ns** (kubens) | Fast namespace switching | Productivity | Post-CKA (daily work) |
| **tree** | Resource hierarchy visualization | Debugging | When debugging complex deployments |
| **get-all** | List ALL namespaced resources | Discovery | When exploring unknown clusters |
| **neat** | Clean YAML output (remove clutter) | Productivity | When copying/sharing manifests |
| **view-secret** | Decode Secrets without base64 | Debugging | When troubleshooting secret issues |
| **access-matrix** | RBAC permissions matrix view | Security | When auditing permissions |
| **score** | Analyze manifests for best practices | Validation | When reviewing production configs |
| **ksniff** | tcpdump + Wireshark integration | Network Debug | When diagnosing network issues |

**Installation via krew**: `kubectl krew install <plugin>` (after installing krew itself)

**Decision per QnA**: Defer all plugins initially. Focus on vanilla kubectl. Add later based on actual workflow needs.

---

## Build Strategy & Parallelism

**Current State (shoshin hardware profile)**:
```nix
build.parallelism = {
  maxJobs = 2;        # Maximum parallel derivation builds
  maxCores = 6;       # CPU cores per build job
  # Thread utilization: 2 jobs × 6 cores = 12 thread requests on 6 physical threads
  # Oversubscription: 2.0x (safe)
};
```

**User Requirement** (QnA Round 3):
> "I have increased jobs on dotfiles repo and flake to 12 parallel max jobs for nixos/ repo and home-manager/ repo. Utilize memory and cpu of the system maximum but it should leave at least 6-8 GB of total ram+swap to the system/plasma desktop etc in order to run efficiently."

**Target State (NEW)**:

### Tier-Based Dynamic Parallelism (Primary Strategy)

Implement intelligent per-package parallelism based on build weight:

```nix
# To be implemented in hardware profile or new overlay

buildTiers = {
  tier1 = {
    # Heavy builds: Python FULL PGO, ONNX Runtime, Firefox, System Libs
    maxJobs = 1;
    cores = 6;
    description = "Single-threaded, maximum performance per build";
    memoryBudget = "10-12GB per job";
    examples = [ "python313" "onnxruntime" "firefox" "glibc" "gcc" ];
  };

  tier2 = {
    # Medium builds: Rust with PGO, Node.js PGO, Codex, MCP servers
    maxJobs = 2-3;
    cores = 4;
    description = "Moderate parallelism, balanced memory usage";
    memoryBudget = "4-6GB per job";
    examples = [ "rustc" "nodejs" "codex" "mcp-servers" "chromium" ];
  };

  tier3 = {
    # Light builds: CLI tools, scripts, simple derivations
    maxJobs = 12;
    cores = 2;
    description = "Maximum parallelism for quick builds";
    memoryBudget = "500MB-1GB per job";
    examples = [ "kubectl" "k9s" "ripgrep" "fd" "bat" "jq" ];
  };
};
```

**Memory Budget Calculation**:
- Total available: 28GB (16GB RAM + 12GB zram)
- Reserved for system: 6-8GB (user requirement)
- Available for builds: 20-22GB

**Tier 1 (Heavy)**:
- 1 job × 6 cores × 10-12GB = 10-12GB used
- Remaining: 10-12GB (safe buffer)

**Tier 2 (Medium)**:
- 3 jobs × 4 cores × 4-6GB = 12-18GB used
- Remaining: 4-10GB (acceptable, some swap usage)

**Tier 3 (Light)**:
- 12 jobs × 2 cores × 1GB = ~12GB used
- Remaining: 10GB+ (very safe)

### Conservative Aggressive Fallback (Secondary Strategy)

For packages not explicitly categorized, use safe global defaults:

```nix
build.parallelism = {
  maxJobs = 6;        # UP from 2 (3x increase)
  maxCores = 6;       # SAME (use all available threads)
  # Thread utilization: 6 jobs × 6 cores = 36 thread requests on 8 threads
  # Oversubscription: 4.5x (high but manageable with good I/O scheduler)
};
```

**Rationale**: Nix build scheduler is smart about I/O and CPU contention. With NVMe SSD (shoshin has M.2 NVMe) and mold linker (30-50% faster), high oversubscription is acceptable for non-heavy packages.

### Implementation Approach

**Option A: Per-Package Override (Most Precise)**
```nix
# In hardware profile packages section
packages = {
  python313 = {
    nixBuildMaxJobs = 1;
    nixBuildCores = 6;
    # ... existing PGO settings
  };

  kubectl = {
    nixBuildMaxJobs = 12;
    nixBuildCores = 2;
  };
};
```

**Option B: Custom Overlay with Build Tier Logic (Most Elegant)**
```nix
# New overlay: modules/system/overlays/build-tier-parallelism.nix
hardwareProfile: final: prev:
let
  tier1Packages = [ "python313" "glibc" "gcc" "llvm" "firefox" "onnxruntime" ];
  tier2Packages = [ "rustc" "nodejs" "go" "codex" "chromium" ];
  # Everything else is tier3

  applyBuildTier = pkg: tierConfig:
    pkg.overrideAttrs (old: {
      NIX_BUILD_CORES = tierConfig.cores;
      # Note: maxJobs is global, can't override per-package
      # But can set resource limits via systemd if needed
    });
in
{
  # Apply tier configurations to packages
  # ...implementation details
}
```

**Option C: Nix Daemon Configuration (Simplest)**
```nix
# In /etc/nix/nix.conf (NixOS level, not home-manager)
max-jobs = 12;
cores = 6;

# Then use per-package overrides for Tier 1 heavy packages
# Force serialization via NIX_BUILD_CORES=6 + build one at a time
```

**Recommended for Initial Implementation**: **Option C + Option A hybrid**
- Set global `max-jobs = 6, cores = 6` as safe fallback
- Override Tier 1 packages individually with `maxJobs=1, cores=6`
- Let Tier 2 use defaults (maxJobs=6 will naturally limit)
- Tier 3 benefits from parallelism automatically

**Document in**: ADR-027 (Workspace-Specific Build Optimization)

### Build Dependency Optimization (User Requirement)

> "Optimize build dependencies and split heavy derivations."

**Current Issue**: Monolithic builds cause unnecessary rebuilds when dependencies change.

**Examples**:
1. **ONNX Runtime**: Single massive derivation including CUDA, cuDNN, TensorRT, Protobuf, etc.
   - If Protobuf updates, entire ONNX Runtime rebuilds (~30 min)
   - **Solution**: Split into onnxruntime-core + onnxruntime-cuda + onnxruntime-providers

2. **Firefox**: Single derivation with all components
   - Small config changes force full rebuild
   - **Solution**: Already split in nixpkgs (firefox-unwrapped + wrapper), but could split further

3. **Python with PGO**: Monolithic with PGO training in same derivation
   - **Current**: Can't cache intermediate steps
   - **Solution**: Split into python313-base + python313-pgo-training + python313-final

**Implementation Strategy**:
- Audit current heavy packages (Tier 1 list)
- Identify split opportunities (look for natural boundaries: core + plugins, base + optimized, etc.)
- Create intermediate derivations that cache independently
- Benefit: Cachix can cache intermediate steps, speeding up rebuilds on gyakusatsu

**Priority**: MEDIUM (implement during Phase 4 after core optimizations working)

**Document in**: ADR-027

---

## Phase 0: System Libraries Foundation

**Objective**: Build ALL critical system libraries with hardware-specific optimizations BEFORE any language runtimes.

**Rationale** (from QnA Round 4 & 5):
- System libs are FOUNDATIONAL - everything links against them
- Language runtimes (Python, Rust, Node.js, Go) link against glibc, zlib, openssl, libstdc++
- Optimizing libs FIRST cascades performance gains to everything built on top
- 5-10% system-wide performance improvement expected

**Libraries to Optimize** (User selected ALL in QnA Round 5):

### Core Runtime Libraries
- **glibc** (GNU C Library): Foundation of EVERYTHING. All programs link against glibc.
- **zlib**: Compression library. Used by: git, curl, Python, browsers, everything that compresses.
- **zstd**: Fast compression. Used by: systemd, btrfs/zfs, tar, Python, modern compression workflows.

### Cryptography Libraries
- **openssl**: TLS/SSL, HTTPS, SSH. Used by: curl, git, Python ssl module, Node.js, Go, browsers.
- **libgcrypt**: GnuPG cryptography. Used by: systemd, gpg, cryptographic operations.
- **libsodium**: Modern cryptography library. Used by: security-focused apps, password managers.

### C++ Standard Libraries
- **libstdc++**: GNU C++ standard library. Used by: All C++ applications (browsers, ONNX, many CLI tools, KDE Plasma).
- **libc++**: LLVM C++ standard library. Alternative to libstdc++. Used by: LLVM-compiled C++ apps.

### Comprehensive Additional Libraries
User selected "All critical system libs (comprehensive foundation)" which includes:
- **ncurses**: Terminal UI library. Used by: vim, htop, many CLI tools.
- **readline**: Line editing for interactive programs. Used by: bash, python REPL, psql, mysql, redis-cli.
- **sqlite**: Embedded database. Used by: Python, browsers (Firefox, Chromium), systemd, many apps.
- **libffi**: Foreign function interface. Used by: Python ctypes, language runtimes calling C.
- **expat**: XML parser. Used by: Python XML modules, many apps.
- **xz-utils** (liblzma): XZ compression. Used by: systemd, package managers.
- **bzip2**: BZ2 compression. Used by: tar, archives, Python bz2 module.
- **libxml2**, **libxslt**: XML/XSLT processing. Used by: Python lxml, GNOME apps.

**Estimated Build Time**: 2.5-3.5 hours one-time on shoshin (Tier 1 builds: maxJobs=1, cores=6)

### Implementation Strategy

**Create New Overlay**: `modules/system/overlays/system-libs-hardware-optimized.nix`

```nix
# modules/system/overlays/system-libs-hardware-optimized.nix
hardwareProfile: _final: prev:

let
  hw = hardwareProfile;
  compiler = hw.build.compiler or { };

  # Hardware-specific compiler flags (from shoshin profile)
  march = compiler.march or "x86-64-v3";  # skylake for shoshin
  mtune = compiler.mtune or "x86-64-v3";  # skylake
  optimizationLevel = toString (compiler.optimizationLevel or "3");  # -O3

  # Standard hardware optimization flags
  hardwareCflags = [
    "-march=${march}"
    "-mtune=${mtune}"
    "-O${optimizationLevel}"
    "-pipe"
    "-fno-semantic-interposition"  # 5-10% gain for shared libs
  ];

  hardwareLdflags = [
    "-O${optimizationLevel}"
    "-fuse-ld=mold"  # 30-50% faster linking
  ];

  # Helper: Apply hardware flags to a package
  optimizePackage = pkg: pkg.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = toString (
      (old.NIX_CFLAGS_COMPILE or []) ++ hardwareCflags
    );
    NIX_LDFLAGS = toString (
      (old.NIX_LDFLAGS or []) ++ hardwareLdflags
    );

    # Use all 6 cores for compilation (Tier 1 build)
    NIX_BUILD_CORES = 6;

    # Enable additional optimizations where supported
    configureFlags = (old.configureFlags or []) ++ [
      "--enable-optimizations"  # If package supports it
    ];
  });

in
{
  # ===========================================================================
  # Core Runtime Libraries
  # ===========================================================================
  glibc = optimizePackage prev.glibc;
  zlib = optimizePackage prev.zlib;
  zstd = optimizePackage prev.zstd;

  # ===========================================================================
  # Cryptography Libraries
  # ===========================================================================
  openssl = optimizePackage prev.openssl;
  libgcrypt = optimizePackage prev.libgcrypt;
  libsodium = optimizePackage prev.libsodium;

  # ===========================================================================
  # C++ Standard Libraries
  # ===========================================================================
  gcc = prev.gcc.override {
    stdenv = prev.stdenvAdapters.overrideCC prev.stdenv (
      prev.wrapCCWith {
        cc = prev.gcc.cc;
        extraBuildCommands = ''
          echo "${toString hardwareCflags}" >> $out/nix-support/cc-cflags
          echo "${toString hardwareLdflags}" >> $out/nix-support/cc-ldflags
        '';
      }
    );
  };

  # ===========================================================================
  # Comprehensive Additional Libraries
  # ===========================================================================
  ncurses = optimizePackage prev.ncurses;
  readline = optimizePackage prev.readline;
  sqlite = optimizePackage prev.sqlite;
  libffi = optimizePackage prev.libffi;
  expat = optimizePackage prev.expat;
  xz = optimizePackage prev.xz;
  bzip2 = optimizePackage prev.bzip2;
  libxml2 = optimizePackage prev.libxml2;
  libxslt = optimizePackage prev.libxslt;
}
```

**Integration in flake.nix**:
```nix
overlays = [
  # PHASE 0: System Libraries (FIRST - foundational)
  (import ./modules/system/overlays/system-libs-hardware-optimized.nix currentHardwareProfile)

  # PHASE 1: Compiler Infrastructure
  (import ./modules/system/overlays/llvm-hardware-optimized.nix currentHardwareProfile)

  # PHASE 2: Language Runtimes (built on top of optimized system libs)
  (import ./modules/system/overlays/go-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/rust-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/python-hardware-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/nodejs-hardware-optimized.nix currentHardwareProfile)

  # Application-specific
  (import ./modules/system/overlays/onnxruntime-gpu-optimized.nix currentHardwareProfile)
  (import ./modules/system/overlays/performance-critical-apps.nix currentHardwareProfile)
];
```

### Workspace-Specific Behavior

**shoshin** (16GB RAM, Skylake):
- Build ALL system libraries with FULL optimizations
- `-march=skylake`, `-mtune=skylake`, `-O3`
- Push to Cachix Tier 1 (highest priority for caching)

**gyakusatsu** (8GB WSL):
- **PULL from Cachix** (DO NOT rebuild locally)
- System libraries are foundational - building them would consume too much RAM
- Pull optimized builds from shoshin via cachix-pull script

### Testing & Verification

**Before enabling overlay**:
1. Test build one library in isolation: `nix build .#glibc`
2. Verify flags applied: `nix log .#glibc | grep -- -march`
3. Check binary size and performance with simple benchmark

**After enabling overlay**:
1. Monitor build time and memory usage
2. Test simple program: Compile "hello world" C program, measure startup time
3. Verify system still boots and runs correctly (CRITICAL - glibc is foundational!)

**Rollback Plan**: If system becomes unstable, comment out system-libs overlay in flake.nix, rebuild.

### Performance Expectations

**Build Time** (one-time cost):
- glibc: ~45-60 minutes (largest, most complex)
- openssl: ~15-20 minutes
- zlib, zstd, bzip2, xz: ~5-10 minutes each
- Others: ~5-15 minutes each
- **Total**: 2.5-3.5 hours

**Runtime Performance Gains**:
- **System-wide**: 5-10% improvement across ALL applications
- **Compilation**: Faster C/C++ compilation (faster headers, faster linking)
- **Compression**: 10-15% faster git operations, tar, xz, etc.
- **Cryptography**: 15-25% faster HTTPS, SSH, git clone over HTTPS
- **Databases**: 8-12% faster sqlite operations
- **Cascading Effect**: Language runtimes built on optimized libs inherit gains

**Cachix Impact**:
- System libs are ~500MB-1GB of derivations
- Tier 1 caching priority (always cached, never evicted)
- gyakusatsu pulls these first, gains immediate system-wide speedup

**Risk Level**: **HIGH** (rebuilding glibc is risky - everything depends on it)

**Mitigation**:
- Test thoroughly before full deployment
- Keep backup generation (can rollback with `home-manager generations`)
- Use Cachix to avoid rebuilding on gyakusatsu if issues arise
- Consider testing on shoshin first, only deploy to gyakusatsu after confirmed stable

**Document in**: ADR-028 (System Libraries Hardware Optimization)

---

## Phase 1: LLVM Compiler Infrastructure

**Status**: Already planned in original runtime optimization refactor (Phase 5).

**Objective**: Build LLVM/Clang with hardware-specific optimizations for 10-20% faster CUDA compilation.

**Reference**: See [2025-12-30-runtime-optimization-refactor.md - Phase 5](./2025-12-30-runtime-optimization-refactor.md#phase-5-create-llvm-overlay-fourth-commit)

**Key Details**:
- Create `modules/system/overlays/llvm-hardware-optimized.nix`
- Target: llvmPackages_19 (latest stable)
- Hardware flags: `-march=skylake`, `-mtune=skylake`, `-O3`
- Benefits: 10-20% faster nvcc compilation (CUDA uses host compiler)
- Impacts: ONNX Runtime builds, PyTorch, TensorFlow, any CUDA code
- Build time: +30-45 minutes one-time

**Integration Note**: Phase 1 (LLVM) builds on top of Phase 0 (system libs). LLVM links against optimized glibc, zlib, zstd, etc., so it inherits those performance gains PLUS gets its own hardware optimizations.

**No changes needed** - already comprehensively planned in original document. Proceed as documented.

---

## Phase 2: Language Runtimes (Python, Rust, Node.js, Go)

**Status**: Already planned in original runtime optimization refactor (Phases 2-4).

**Objective**: Build language runtimes with FULL PGO + hardware flags.

**User Requirement** (QnA Round 3):
> "Do not optimize the PGO I want to gain full gains of this long rebuild or make it as much as possible value for optimizations."

**Decision**: Keep ALL existing PGO plans at FULL level. NO compromises.

### Current Plan (from original document)

**Phase 2: Fix Node.js** (already completed - typo fixed, committed)
- File: `modules/system/overlays/nodejs-hardware-optimized.nix:165`
- Fix: `NIX_CXXSTDLIB_COMPILE` → `NIX_CXXFLAGS_COMPILE` ✅ DONE
- Commit: `f697cbd` ✅ COMMITTED
- Next: **TEST BUILD** (user wants this BEFORE full refactor)

**Phase 3: Test Node.js Build**
- Build Node.js with FULL PGO + hardware flags (without activating overlay)
- Expected time: 60-90 minutes
- Expected RAM: 8-12GB peak
- Success criteria: Build completes, V8 compiles with C++20, hardware flags applied, PGO training succeeds
- **USER WANTS THIS FIRST** (QnA Round 5 final confirmation)

**Phase 4: Integrate Codex Memory-Limited Mode**
- Already planned, no changes needed
- Reference: Original document Phase 4

### Build Order for Language Runtimes

**Order matters** - build in dependency order:

1. **Go** (15-25 minutes, lightest)
   - No external runtime dependencies
   - Build first to validate process
   - Already has hardware overlay: `go-hardware-optimized.nix`
   - Keep existing FULL optimizations

2. **Rust** (45-60 minutes with FULL PGO + LTO)
   - Depends on LLVM (Phase 1)
   - Already has hardware overlay: `rust-hardware-optimized.nix`
   - Keep existing: `enablePGO = true, enableLTO = true, enableJemalloc = true`
   - Now benefits from optimized system libs (glibc, zlib)

3. **Python 3.13** (60-90 minutes with FULL PGO)
   - Depends on zlib, openssl, readline, sqlite, libffi (Phase 0 system libs!)
   - Already has hardware overlay: `python-hardware-optimized.nix`
   - Keep existing: `pgoLevel = "FULL"` (shoshin), `pgoLevel = "NONE"` (gyakusatsu)
   - **HUGE benefit from Phase 0**: Python links heavily against system libs

4. **Node.js** (60-90 minutes with FULL PGO) **← TEST THIS FIRST**
   - Depends on LLVM (Phase 1), openssl, zlib (Phase 0)
   - Already has hardware overlay: `nodejs-hardware-optimized.nix` (FIX APPLIED ✅)
   - Enable overlay in flake.nix AFTER test build succeeds
   - Keep FULL PGO (user requirement)

**Total Runtime Build Time**: 2.5-4 hours (serial) or 1.5-2.5 hours (with Tier 2 parallelism: maxJobs=2-3)

### Integration with Phase 0 (System Libraries)

**Critical Insight**: Language runtimes link against system libraries optimized in Phase 0.

**Examples**:
- **Python**: Links against zlib, openssl, readline, sqlite, libffi, bzip2, xz → Inherits 5-10% gain from Phase 0 PLUS 10-30% from own PGO = **15-40% total gain**
- **Node.js**: Links against openssl, zlib → Inherits crypto/compression speedup from Phase 0 PLUS 10-30% from PGO
- **Rust**: Uses system allocator (can override with jemalloc) → Gains from optimized glibc
- **Go**: Less dependent (has own runtime), but still links against glibc for syscalls

**Cascading Performance Multiplier**: Optimizing foundation (Phase 0) BEFORE runtimes (Phase 2) creates compound gains.

### Workspace-Specific Behavior (Runtimes)

**shoshin** (16GB RAM, Skylake):
- Build ALL runtimes with FULL PGO
- Python: `pgoLevel = "FULL"` ✅ (already set)
- Node.js: Enable FULL PGO ✅ (after test)
- Rust: `enablePGO = true, enableLTO = true` ✅ (already set)
- Go: Hardware flags only (Go PGO less impactful, skip for now)
- Push ALL to Cachix Tier 1

**gyakusatsu** (8GB WSL):
- **PULL ALL runtimes from Cachix** (already configured in gyakusatsu.nix)
- Python: `pgoLevel = "NONE"` ✅ (pulls optimized build from Cachix instead)
- Node.js: Do not build locally (pull from Cachix)
- Rust: `enablePGO = false, enableLTO = false` ✅ (pulls from Cachix)
- Go: Pull from Cachix
- **DO NOT build runtimes locally** - use cachix-pull script

### Testing & Verification

**Phase 2 Test (Node.js BUILD ONLY)**:

```bash
# On shoshin (16GB RAM)
# Test build WITHOUT activating overlay (safe test)

nix build --show-trace --print-build-logs \
  -f '<nixpkgs>' nodejs_22 \
  --arg overlays '[
    (import ./modules/system/overlays/nodejs-hardware-optimized.nix
      (import ./modules/profiles/config/hardware/shoshin.nix))
  ]'

# Expected: 60-90 minutes build time, 8-12GB RAM peak
# Success: Build completes, no errors, V8 compiled with C++20
```

**If test succeeds**:
1. Uncomment nodejs overlay in flake.nix:197
2. `home-manager switch` (pulls cached build or rebuilds if needed)
3. Verify Node.js performance with simple benchmark
4. Proceed to full refactor (Phase 0 system libs)

**If test fails**:
1. Capture build log
2. Analyze error (likely still V8-related or memory OOM)
3. Fix issue before proceeding
4. Do NOT proceed with full refactor until Node.js build validated

**Performance Verification** (after all runtimes built):

```bash
# Python import time test
time python3 -c "import numpy, pandas, scipy"

# Node.js startup time test
time node -e "console.log('test')"

# Rust compilation test
time cargo build --release (small project)

# Go build test
time go build main.go (simple program)
```

**Expected Improvements** (vs non-PGO, non-optimized):
- Python import time: 20-30% faster
- Node.js startup: 15-25% faster
- Rust compilation: 10-15% faster rustc, 8-15% faster binaries
- Go: 5-10% faster compilation

**Document**: Update existing runtime optimization plan with Phase 0 integration notes.

---

## Phase 3: Kubernetes & IaC Tooling

**Objective**: Install comprehensive Kubernetes toolkit + Infrastructure as Code tools.

**User Requirements** (QnA Rounds 1-5):
- **Use case**: All of the above (CKA cert + Eyeonix SRE work + Dissertation meta-operator dev)
- **Priorities**: Core + Debugging (kubectl, helm, stern) + Context switchers (kubectx, kubens, kubecolor)
- **kubectl plugins (krew)**: Defer - focus on vanilla kubectl for CKA prep
- **IaC tools**: Both OpenTofu v1.10.0 + Terraform v1.14.3 with tenv version manager
- **Local dev clusters**: Defer kind/k3d to later (when needed for dissertation)
- **Validation tools**: Defer kubeval/kube-linter (when needed for production CI/CD)

### Kubernetes Core Tooling

**Install in this order**:

1. **kubectl** v1.35 (latest)
2. **Helm** v3.16+ (from nixpkgs)
3. **k9s** v0.50.16 (Kubernetes TUI)
4. **stern** (log aggregation)
5. **kubectx** + **kubens** (context/namespace switching)
6. **kubecolor** (colored kubectl output)
7. **krew** (kubectl plugin manager) - install but no plugins yet

**Installation Strategy** (per QnA Round 5):
> "Mix: nixpkgs for most, latest for critical (kubectl latest, rest nixpkgs)"

#### kubectl v1.35 (Latest from upstream)

```nix
# modules/infra/k8s/kubectl.nix
{ pkgs, ... }:

let
  # Fetch latest kubectl 1.35 directly from Kubernetes releases
  kubectl-latest = pkgs.stdenv.mkDerivation rec {
    pname = "kubectl";
    version = "1.35.0";  # Update as needed

    src = pkgs.fetchurl {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "...";  # Update with actual hash
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      install -Dm755 $src $out/bin/kubectl
    '';

    meta = {
      description = "Kubernetes CLI tool (latest upstream)";
      homepage = "https://kubernetes.io/";
      license = pkgs.lib.licenses.asl20;
      mainProgram = "kubectl";
    };
  };
in
{
  home.packages = [ kubectl-latest ];

  # Shell completions
  programs.bash.initExtra = ''
    source <(kubectl completion bash)
    alias k=kubectl
    complete -F __start_kubectl k
  '';

  programs.zsh.initExtra = ''
    source <(kubectl completion zsh)
    alias k=kubectl
  '';
}
```

**Rationale**: kubectl v1.35 is latest (2025), CKA exam based on v1.34 (Aug 2025). Version 1.35 is forward-compatible (±1 minor version of cluster). Fetching directly ensures always latest, no binary cache but kubectl is pre-compiled (fast download).

#### Helm, k9s, stern from nixpkgs

```nix
# modules/infra/k8s/core-tools.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Helm - Kubernetes package manager (from nixpkgs unstable ~v3.15-3.16)
    kubernetes-helm  # Or just `helm` depending on nixpkgs version

    # k9s - Kubernetes TUI (from nixpkgs ~v0.50.x)
    k9s

    # stern - Multi-pod log tailing (from nixpkgs)
    stern
  ];

  # Helm completion
  programs.bash.initExtra = ''
    source <(helm completion bash)
  '';

  programs.zsh.initExtra = ''
    source <(helm completion zsh)
  '';
}
```

**Rationale**: These tools update less frequently, nixpkgs versions are recent enough. Benefit from binary cache (no compilation). Stable, tested versions.

#### kubectx, kubens, kubecolor (Productivity)

```nix
# modules/infra/k8s/productivity-tools.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Fast context switching (⚠️ NOT available in CKA exam)
    kubectx

    # kubens is usually bundled with kubectx
    # If separate: kubens

    # Colored kubectl output
    kubecolor
  ];

  # Alias kubectl to kubecolor for everyday use
  # (But remember vanilla kubectl for CKA exam practice!)
  programs.bash.shellAliases = {
    kubectl = "kubecolor";
    k = "kubecolor";
    # Vanilla kubectl still available as: \kubectl
  };

  programs.zsh.shellAliases = {
    kubectl = "kubecolor";
    k = "kubecolor";
  };
}
```

**Rationale**: HUGE productivity boost for multi-cluster work (Eyeonix production + dissertation dev + personal clusters). NOT available in CKA exam, so practice with vanilla kubectl too. Install from nixpkgs (stable, cached).

#### krew (kubectl plugin manager) - Deferred plugins

```nix
# modules/infra/k8s/krew.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    krew  # kubectl plugin manager
  ];

  # krew initialization
  programs.bash.initExtra = ''
    export PATH="${config.home.homeDirectory}/.krew/bin:$PATH"
  '';

  programs.zsh.initExtra = ''
    export PATH="${config.home.homeDirectory}/.krew/bin:$PATH"
  '';

  # Note: No plugins installed initially (per QnA Round 3 decision)
  # Install plugins later via: kubectl krew install <plugin>
  # Recommended for later (post-CKA):
  #   - ctx (context switch)
  #   - ns (namespace switch)
  #   - tree (resource hierarchy)
  #   - get-all (list all resources)
  #   - neat (clean YAML output)
  #   - view-secret (decode secrets)
}
```

**Rationale**: Install krew infrastructure now, defer plugins to avoid complexity. Focus on vanilla kubectl for CKA. Add plugins post-CKA based on actual workflow needs (align with web research findings).

### Infrastructure as Code (IaC) Tooling

**User Requirement** (QnA Round 2):
> "Both OpenTofu + Terraform (with version managers)"

**Latest Versions** (from web research):
- OpenTofu: v1.10.0 (stable, June 2025)
- Terraform: v1.14.3 (stable, December 17, 2025)
- tenv: Unified version manager (now in nixpkgs)

#### tenv (Unified Version Manager)

```nix
# modules/infra/iac/tenv.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tenv  # OpenTofu / Terraform / Terragrunt / Atmos version manager
          # Successor to tfenv + tofuenv (merged into nixpkgs 2025)
  ];

  # tenv initialization
  programs.bash.initExtra = ''
    # tenv auto-detection based on .terraform-version or .opentofu-version files
    eval "$(tenv init bash)"
  '';

  programs.zsh.initExtra = ''
    eval "$(tenv init zsh)"
  '';

  # Install specific versions
  home.activation.tenvInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Install OpenTofu v1.10.0
    $DRY_RUN_CMD ${pkgs.tenv}/bin/tenv tofu install 1.10.0
    $DRY_RUN_CMD ${pkgs.tenv}/bin/tenv tofu use 1.10.0

    # Install Terraform v1.14.3
    $DRY_RUN_CMD ${pkgs.tenv}/bin/tenv tf install 1.14.3
    $DRY_RUN_CMD ${pkgs.tenv}/bin/tenv tf use 1.14.3

    echo "tenv: Installed OpenTofu 1.10.0 and Terraform 1.14.3"
  '';
}
```

**Usage**:
```bash
# Switch between versions
tenv tofu use 1.10.0   # Use OpenTofu
tenv tf use 1.14.3     # Use Terraform

# Auto-detection via project files
echo "1.10.0" > .opentofu-version  # tenv auto-uses OpenTofu 1.10.0
echo "1.14.3" > .terraform-version  # tenv auto-uses Terraform 1.14.3

# List installed versions
tenv tofu list
tenv tf list
```

**Rationale**:
- **Both tools installed**: Work compatibility (Eyeonix might use Terraform) + personal preference (OpenTofu)
- **tenv**: Unified manager (simpler than tfenv + tofuenv), now in nixpkgs (no custom derivation needed)
- **Version pinning**: Project-specific version control via `.terraform-version` / `.opentofu-version` files
- **Latest versions**: OpenTofu 1.10.0 (comprehensive features: OCI registry, S3 locking), Terraform 1.14.3 (latest stable)

### Module Structure

Create modular structure for easy management:

```
modules/infra/
├── default.nix           # Main entry point, imports all submodules
├── k8s/
│   ├── default.nix       # K8s entry point
│   ├── kubectl.nix       # kubectl latest
│   ├── core-tools.nix    # helm, k9s, stern
│   ├── productivity-tools.nix  # kubectx, kubens, kubecolor
│   ├── krew.nix          # krew (no plugins yet)
│   └── local-dev.nix     # kind, k3d (DEFERRED)
├── iac/
│   ├── default.nix       # IaC entry point
│   └── tenv.nix          # tenv with OpenTofu + Terraform
└── cloud/
    └── default.nix       # Cloud CLIs (aws-cli, gcloud, azure-cli) - DEFERRED
```

**modules/infra/default.nix**:
```nix
{ ... }:
{
  imports = [
    ./k8s     # Kubernetes tooling
    ./iac     # Infrastructure as Code (OpenTofu, Terraform)
    # ./cloud # Cloud provider CLIs (defer for now)
  ];
}
```

**modules/infra/k8s/default.nix**:
```nix
{ ... }:
{
  imports = [
    ./kubectl.nix
    ./core-tools.nix
    ./productivity-tools.nix
    ./krew.nix
    # ./local-dev.nix  # Defer kind/k3d
  ];
}
```

**modules/infra/iac/default.nix**:
```nix
{ ... }:
{
  imports = [
    ./tenv.nix
  ];
}
```

### Update home.nix

```nix
# home.nix
{
  imports = [
    # ... existing imports ...

    # Infrastructure tooling (NEW)
    ./modules/infra  # Kubernetes + IaC tools
  ];
}
```

### Workspace-Specific Behavior (K8s/IaC Tools)

**shoshin** (16GB RAM, Skylake):
- Install ALL K8s tools
- Install both OpenTofu + Terraform via tenv
- Full CKA toolkit + productivity tools

**gyakusatsu** (8GB WSL):
- Install ALL K8s tools (same as shoshin)
- Install both OpenTofu + Terraform via tenv (same)
- **Rationale**: K8s/IaC tools are pre-compiled binaries (kubectl, helm, tenv), NOT heavy to build. No benefit to skipping on gyakusatsu. Useful for work (Eyeonix K8s management from WSL).

**Note**: No CUDA/GPU tools needed on gyakusatsu (already decided in QnA Round 3), but K8s/IaC tools are lightweight and useful.

### Testing & Verification

**kubectl test**:
```bash
kubectl version --client
kubectl cluster-info  # If connected to cluster
```

**Helm test**:
```bash
helm version
helm repo add stable https://charts.helm.sh/stable
helm search repo stable
```

**k9s test**:
```bash
k9s version
k9s  # Launch TUI (if connected to cluster)
```

**tenv test**:
```bash
tenv tofu list
tenv tf list

tofu version  # Should show OpenTofu 1.10.0
terraform version  # Should show Terraform 1.14.3
```

**Productivity tools test**:
```bash
kubectx  # List contexts
kubens   # List namespaces
kubectl get pods --all-namespaces | kubecolor  # Colored output
```

### Build Time & Performance

**Build time**: 5-15 minutes total
- kubectl: 2-3 minutes (download pre-compiled binary)
- Helm: 1-2 minutes (download or pull from nixpkgs cache)
- k9s: 2-3 minutes (pull from nixpkgs cache)
- stern: 1-2 minutes (pull from cache)
- kubectx, kubens, kubecolor: 1-2 minutes each
- krew: 2-3 minutes
- tenv: 2-3 minutes (pull from nixpkgs) + activation time (download OpenTofu/Terraform binaries)

**Cachix**: Tier 3 (lightweight packages)
- Most tools are pre-compiled binaries or pull from nixpkgs cache
- tenv downloads OpenTofu/Terraform binaries directly (not from Cachix)
- Total Cachix usage: ~100-200MB

**Performance**: N/A (CLI tools, performance depends on usage, not build)

### Future Additions (Deferred)

**Local Development Clusters** (when needed for dissertation):
- kind v0.X (pure Kubernetes for testing)
- k3d v5.X (k3s in Docker, fastest option)
- Installation: Add to modules/infra/k8s/local-dev.nix when dissertation requires local cluster testing

**Validation Tools** (when needed for production workflows):
- kubeval (YAML validation)
- kube-linter (security/best practices linting)
- conftest (policy-as-code)
- Installation: Add when setting up CI/CD pipelines at Eyeonix or for dissertation

**Cloud Provider CLIs** (if needed):
- aws-cli (Eyeonix might use AWS)
- gcloud (Google Cloud)
- azure-cli (Azure)
- Installation: Add to modules/infra/cloud/ when actually using cloud K8s (EKS, GKE, AKS)

**kubectl Plugins via krew** (post-CKA):
Priority order (from web research):
1. ctx, ns (if not using standalone kubectx/kubens)
2. tree (resource hierarchy visualization)
3. get-all (list all resources)
4. neat (clean YAML output)
5. view-secret (decode secrets easily)
6. access-matrix (RBAC permissions visualization)

Installation: `kubectl krew install <plugin>` when actually needed

### Documentation

**No new ADR needed** (per QnA Round 5 - K8s ADR NOT selected)

**Update**: Add K8s/IaC tooling section to ADR-027 (Workspace-Specific Build Optimization) documenting that these tools are installed on ALL workspaces (not workspace-specific).

---

## Phase 4: Build Optimization & Workspace Decoupling

**Objective**: Implement intelligent parallelism, dependency splitting, and workspace-specific package selection.

**User Requirements** (from QnA Rounds 3-4):
- **Parallelism**: "I have increased jobs to 12... Utilize 7 of 8 CPU cores... leave 6-8GB for system"
- **Strategy**: Combination of dynamic tier-based + conservative aggressive + **Document as ADR**
- **Dependencies**: "Optimize build dependencies and split heavy derivations"
- **Workspace**: gyakusatsu skips CUDA/GPU packages

### 4.1: Implement Tier-Based Parallelism

**Goal**: Maximize build throughput while preventing OOM on heavy packages.

**Implementation**: Create new configuration module.

```nix
# modules/profiles/build-parallelism.nix
{ config, lib, hardwareProfile, ... }:

let
  hw = hardwareProfile;

  # Tier definitions (from Build Strategy section)
  tierConfig = {
    tier1 = {
      maxJobs = 1;
      cores = 6;
      packages = [
        "python313" "glibc" "gcc" "llvm" "firefox"
        "onnxruntime" "chromium" "openssl" "zlib" "zstd"
      ];
    };

    tier2 = {
      maxJobs = 3;
      cores = 4;
      packages = [
        "rustc" "nodejs" "go" "codex" "mcp-.*"
        "electron" "vscode" "gcc"
      ];
    };

    tier3 = {
      maxJobs = 12;
      cores = 2;
      # Everything else not in tier1 or tier2
    };
  };

  # Global fallback (conservative aggressive)
  globalParallelism = {
    maxJobs = 6;
    cores = 6;
  };

in
{
  # Nix daemon configuration (requires NixOS integration or nix.conf)
  # This is home-manager, so we document recommended settings:

  home.file.".config/nix/nix.conf".text = ''
    # Build parallelism settings
    max-jobs = ${toString globalParallelism.maxJobs}
    cores = ${toString globalParallelism.cores}

    # Memory and CPU constraints
    # Note: systemd.services.nix-daemon can set MemoryMax, CPUQuota
  '';

  # Document tier assignments for reference
  home.file.".config/home-manager/build-tiers.json".text = builtins.toJSON tierConfig;
}
```

**Note**: Full per-package tier enforcement requires NixOS-level configuration or custom Nix wrapper scripts. For home-manager, we set global defaults and rely on package-specific overrides in overlays.

**Alternative (Package-Level Overrides)**:

Extend hardware profiles with per-package settings:

```nix
# modules/profiles/config/hardware/shoshin.nix (update)
packages = {
  # ... existing entries ...

  # Tier 1: Heavy builds
  glibc = {
    nixBuildMaxJobs = 1;
    nixBuildCores = 6;
  };

  gcc = {
    nixBuildMaxJobs = 1;
    nixBuildCores = 6;
  };

  # Tier 2: Medium builds
  rustc = {
    nixBuildMaxJobs = 3;
    nixBuildCores = 4;
    # ... existing PGO settings ...
  };

  nodejs = {
    nixBuildMaxJobs = 3;
    nixBuildCores = 4;
  };

  # Tier 3: Light builds (use global defaults)
  kubectl = { };  # Uses global maxJobs=6, cores=6
  k9s = { };
};
```

**Then apply in overlays**:

```nix
# In each overlay (e.g., python-hardware-optimized.nix)
python313 = prev.python313.override {
  stdenv = optimizedStdenv;
  # ... other overrides ...
}.overrideAttrs (old: {
  # Apply tier settings from hardware profile
  NIX_BUILD_CORES = hw.packages.python313.nixBuildCores or 6;
  # maxJobs is global, can't override per-package easily
});
```

**Recommendation**:
- **Short-term**: Set global `maxJobs=6, cores=6` in nix.conf
- **Medium-term**: Add `nixBuildCores` to hardware profile packages, apply in overlays
- **Long-term**: Investigate custom Nix wrapper or NixOS-level cgroup controls for per-package maxJobs

**Document in**: ADR-027 (Workspace-Specific Build Optimization)

### 4.2: Split Heavy Derivations

**Goal**: Break monolithic builds into cacheable components.

**Targets** (from Build Strategy section):
1. ONNX Runtime (split: core + CUDA + providers)
2. Python with PGO (split: base + training + final)
3. Firefox (already split in nixpkgs, but audit for further opportunities)

**Example: ONNX Runtime Split**

**Current** (monolithic):
```nix
onnxruntime-gpu = pkgs.stdenv.mkDerivation {
  # ... includes CUDA, cuDNN, TensorRT, Protobuf, all providers ...
  # If Protobuf updates → full 30min rebuild
};
```

**Proposed** (split):
```nix
# Step 1: Core (no GPU)
onnxruntime-core = pkgs.stdenv.mkDerivation {
  # Base runtime, CPU-only
  # Deps: Protobuf, flatbuffers, etc.
};

# Step 2: CUDA layer
onnxruntime-cuda = onnxruntime-core.overrideAttrs (old: {
  # Add CUDA, cuDNN
  # Depends on: onnxruntime-core
});

# Step 3: Full GPU with providers
onnxruntime-gpu = onnxruntime-cuda.overrideAttrs (old: {
  # Add TensorRT, all execution providers
  # Depends on: onnxruntime-cuda
});
```

**Benefits**:
- Protobuf update → Only rebuild onnxruntime-core (~10min), reuse CUDA layer (~5min savings)
- CUDA update → Reuse core, rebuild CUDA layer (~15min), reuse providers
- Cachix can cache intermediate steps → gyakusatsu pulls fastest path

**Implementation**:
- Audit `modules/system/overlays/onnxruntime-gpu-optimized.nix`
- Identify natural split points
- Test incremental builds
- Measure cache effectiveness

**Priority**: MEDIUM (implement after Phases 0-3 stable)

**Document in**: ADR-027

### 4.3: Workspace-Specific Package Selection

**Goal**: gyakusatsu skips packages it doesn't need, pulls optimized versions from Cachix.

**Decisions** (from QnA):
- Skip CUDA/GPU packages (ONNX Runtime GPU) ✅
- Skip GUI apps (Firefox, Brave, VSCodium) - NOT selected, but makes sense
- Skip heavy MCP servers (context7-mcp, firecrawl-mcp Bun/Node) - NOT selected
- Minimal CLI toolkit - NOT selected

**Implemented Strategy**: Skip CUDA/GPU only (user's explicit choice).

**Implementation**:

Update gyakusatsu hardware profile:

```nix
# modules/profiles/config/hardware/gyakusatsu.nix (already has this)
packages = {
  # ... existing ...

  onnxruntime = {
    enableOverlay = false;  # ✅ Already set
    cudaSupport = false;    # ✅ Already set
  };

  # Explicitly mark other GPU packages as disabled
  # (if they exist in configuration)
  # Examples:
  # pytorch = { cudaSupport = false; };
  # tensorflow = { cudaSupport = false; };
};
```

**In modules**, respect hardware profile:

```nix
# modules/apps/... or wherever GPU packages are configured
{ config, pkgs, hardwareProfile, ... }:

let
  hw = hardwareProfile;
  skipGPU = hw.packages.onnxruntime.cudaSupport or true == false;
in
{
  home.packages = pkgs.lib.optionals (!skipGPU) [
    # GPU-dependent packages
    pkgs.onnxruntime-gpu
    # pkgs.pytorch-gpu
    # pkgs.tensorflow-gpu
  ];

  # CPU-only alternatives available on all workspaces
  home.packages = [
    # pkgs.onnxruntime-cpu
  ];
}
```

**Cachix Tiered Caching** (already implemented via ADR-025):

**Tier 1** (always cached, never evicted):
- System libraries (Phase 0): glibc, openssl, zlib, zstd, etc.
- Language runtimes with PGO: python313, rustc, nodejs
- LLVM
- ONNX Runtime GPU (shoshin builds, gyakusatsu never requests)

**Tier 2** (cached when space available):
- Codex
- MCP servers
- Heavy applications (Firefox, Chromium)

**Tier 3** (local builds preferred):
- CLI tools (kubectl, helm, k9s, ripgrep, fd, bat)
- Simple derivations
- Configuration files

**Cachix Management**:
```bash
# On shoshin after builds complete
cachix push modular-workspace <derivation-paths>

# On gyakusatsu before home-manager switch
~/.local/bin/cachix-pull  # Pulls Tier 1 + Tier 2 from Cachix

# Monitor cache usage
cachix use modular-workspace --verbose
```

**5GB Limit Management**:
- Prioritize Tier 1 (system libs + runtimes) = ~2-3GB
- Tier 2 (apps + MCP servers) = ~2GB
- Leave buffer for updates

**Cleanup Strategy**:
```bash
# Regular cleanup (monthly)
cachix push modular-workspace --gc-keep-outputs 3  # Keep last 3 generations
```

**Document in**: ADR-027

### 4.4: Testing & Verification

**Parallelism Test**:
```bash
# Monitor build parallelism
watch -n 1 'ps aux | grep nix-daemon | wc -l'

# Monitor memory usage during build
watch -n 1 free -h

# Test Tier 1 (should see 1 job, 6 cores utilized)
nix build .#python313

# Test Tier 3 (should see multiple jobs)
nix build .#kubectl .#k9s .#helm  # Multiple concurrent builds
```

**Workspace Decoupling Test**:
```bash
# On gyakusatsu
home-manager switch --show-trace

# Verify NO GPU packages installed
nix-store -q --requisites ~/.nix-profile | grep -i cuda  # Should be empty
nix-store -q --requisites ~/.nix-profile | grep -i onnx  # Should be empty or CPU-only

# Verify K8s tools installed
kubectl version
helm version
k9s version
```

**Cachix Effectiveness Test**:
```bash
# On gyakusatsu after fresh pull
home-manager switch --dry-run --show-trace

# Count how many derivations would be built vs downloaded
# Expected: 80%+ cache hit rate for Tier 1 + Tier 2
```

**Performance Test**:
```bash
# Measure home-manager switch time on gyakusatsu
time home-manager switch

# Expected: <5 minutes (vs 2-3 hours if building locally)
```

### Timeline

**Phase 4 Implementation**:
- 4.1 Parallelism config: 1-2 hours (config + testing)
- 4.2 Dependency splitting: 4-6 hours (ONNX audit + implementation + testing)
- 4.3 Workspace decoupling: 1-2 hours (config + testing on gyakusatsu)
- 4.4 Testing: 2-3 hours (comprehensive testing across workspaces)

**Total Phase 4**: 8-13 hours (spread over 1-2 days)

**Document**: Create ADR-027 (detailed spec of all Phase 4 work)

---

## Workspace-Specific Configurations

**Summary table** of how each workspace behaves after refactor:

| Aspect | shoshin (16GB, Skylake, GTX 960) | gyakusatsu (8GB WSL, Zen3, No GPU) |
|--------|----------------------------------|-------------------------------------|
| **Role** | Build server + Development workstation | Lightweight consumer + Work environment |
| **System Libs** | Build ALL with -march=skylake, -O3 | Pull from Cachix (DO NOT build) |
| **LLVM** | Build with hardware flags | Pull from Cachix |
| **Python** | FULL PGO (60-90min build) | Pull from Cachix (pgoLevel=NONE in profile) |
| **Rust** | FULL PGO + LTO (45min build) | Pull from Cachix (PGO disabled in profile) |
| **Node.js** | FULL PGO (60-90min build, after test) | Pull from Cachix (PGO disabled) |
| **Go** | Hardware flags only | Pull from Cachix |
| **ONNX Runtime** | GPU build with CUDA 12.8, cuDNN 9 | Skip entirely (cudaSupport=false) |
| **K8s Tools** | kubectl 1.35, helm, k9s, stern, kubectx, etc. | SAME (pre-compiled, lightweight) |
| **IaC Tools** | OpenTofu 1.10.0 + Terraform 1.14.3 via tenv | SAME (lightweight) |
| **GUI Apps** | Firefox, Brave, VSCodium, Obsidian, etc. | SAME (user didn't request skip) |
| **MCP Servers** | ALL servers (Python, Rust, Bun, Go) | SAME (user didn't request skip) |
| **Parallelism** | maxJobs=6 (global), Tier-based per package | maxJobs=1 (serial), Pull most from cache |
| **Cachix** | Push Tier 1 + Tier 2 to Cachix | Pull Tier 1 + Tier 2 from Cachix |
| **Build Time** | 6-8 hours first time, <30min incremental | <5 minutes (cache hit), ~30min (cache miss) |

**Configuration Sharing**:

Both workspaces share:
- Same flake.nix (overlays applied conditionally based on hardwareProfile)
- Same home.nix (modules enabled conditionally)
- Different hardware profiles (shoshin.nix vs gyakusatsu.nix)

**Hardware Profile Differences**:

Key differences in `modules/profiles/config/hardware/`:

**shoshin.nix**:
```nix
{
  cpu.march = "skylake";
  memory.effectiveTotal = "28";  # 16GB + 12GB zram
  gpu.cudaSupport = true;
  gpu.computeCapability = "5.2";

  build.parallelism.maxJobs = 6;
  build.parallelism.maxCores = 6;

  packages.python313.pgoLevel = "FULL";
  packages.rustc.enablePGO = true;
  packages.onnxruntime.cudaSupport = true;
}
```

**gyakusatsu.nix**:
```nix
{
  cpu.march = "znver3";  # AMD Zen3
  memory.effectiveTotal = "8";  # No zram
  gpu.cudaSupport = false;

  build.parallelism.maxJobs = 1;  # Serial
  build.parallelism.maxCores = 6;

  packages.python313.pgoLevel = "NONE";  # Pull from Cachix
  packages.rustc.enablePGO = false;       # Pull from Cachix
  packages.onnxruntime.cudaSupport = false;  # Skip GPU build
}
```

**Conditional Logic in Overlays**:

```nix
# Example: python-hardware-optimized.nix
hardwareProfile: _final: prev:

let
  hw = hardwareProfile;
  pgoLevel = hw.packages.python313.pgoLevel or "NONE";
in
{
  python313 = if pgoLevel == "NONE" then
    prev.python313  # Use default (from Cachix)
  else
    prev.python313.override {
      # Apply optimizations (shoshin builds, pushes to Cachix)
      # ...
    };
}
```

**Conditional Module Imports**:

```nix
# home.nix
{ config, lib, hardwareProfile, ... }:

let
  hw = hardwareProfile;
  hasGPU = hw.gpu.cudaSupport or false;
in
{
  imports = [
    # ... common imports ...

    # GPU-specific (only on shoshin)
  ] ++ lib.optionals hasGPU [
    ./modules/apps/gpu-accelerated.nix
  ];
}
```

---

## ADR Documentation Requirements

Per QnA Round 5, create **TWO new ADRs**:

### ADR-027: Workspace-Specific Build Optimization

**Filename**: `docs/adr/027-workspace-specific-build-optimization.md`

**Sections**:
1. **Status**: Accepted
2. **Context**:
   - Multiple workspaces (shoshin, gyakusatsu, future kinoite) with different resources
   - Need to maximize performance on powerful machines while avoiding OOM on constrained machines
   - Cachix binary cache has 5GB limit, need intelligent tiering
3. **Decision**:
   - **Tier-Based Parallelism**: Implement 3-tier build system (Tier 1: maxJobs=1/cores=6, Tier 2: maxJobs=3/cores=4, Tier 3: maxJobs=12/cores=2)
   - **Tiered Cachix Caching**: Tier 1 (system libs, runtimes with PGO) always cached, Tier 2 (apps, MCP servers) cached when space, Tier 3 (CLI tools) local builds
   - **Workspace Package Selection**: gyakusatsu skips CUDA/GPU packages, pulls optimized builds from Cachix
   - **Build Dependency Splitting**: Break monolithic builds (ONNX Runtime, Python PGO) into cacheable components
4. **Consequences**:
   - **Positive**:
     - shoshin: 15-25% faster cold builds (from better parallelization)
     - gyakusatsu: <5 minute rebuilds (vs 2-3 hours local build) with 80%+ cache hit rate
     - Efficient Cachix usage (5GB limit respected, Tier 1 priority preserved)
     - Scalable to future workspaces (kinoite laptop)
   - **Negative**:
     - Increased configuration complexity (per-package settings in hardware profiles)
     - Requires Cachix push from shoshin after major updates
     - Split derivations increase derivation count (more Nix evaluation overhead)
5. **References**:
   - ADR-025: Cachix Build Strategy
   - This plan: Build Strategy & Parallelism section
   - This plan: Phase 4 (Build Optimization & Workspace Decoupling)

### ADR-028: System Libraries Hardware Optimization

**Filename**: `docs/adr/028-system-libraries-hardware-optimization.md`

**Sections**:
1. **Status**: Accepted
2. **Context**:
   - Language runtimes (Python, Rust, Node.js, Go) link against system libraries (glibc, zlib, openssl, libstdc++)
   - Optimizing runtimes alone misses foundational performance gains
   - System-wide optimization requires rebuilding core system libraries with hardware flags
3. **Decision**:
   - **Phase 0 Strategy**: Build ALL critical system libs BEFORE language runtimes
   - **Libraries to Optimize**:
     - Core runtime: glibc, zlib, zstd
     - Cryptography: openssl, libgcrypt, libsodium
     - C++ stdlib: libstdc++, libc++
     - Comprehensive: ncurses, readline, sqlite, libffi, expat, xz, bzip2, libxml2, libxslt
   - **Hardware Flags**: -march=skylake (shoshin) / -march=znver3 (gyakusatsu when applicable), -mtune=same, -O3, -fno-semantic-interposition, mold linker
   - **Build Order**: System libs (Phase 0) → LLVM (Phase 1) → Language runtimes (Phase 2) for cascading performance gains
4. **Consequences**:
   - **Positive**:
     - 5-10% system-wide performance improvement (ALL apps benefit)
     - Cascading gains to language runtimes (15-40% total when combined with runtime PGO)
     - Faster compression (git, tar, xz), faster crypto (HTTPS, SSH), faster databases (sqlite)
     - One-time build cost, permanent performance benefit
   - **Negative**:
     - High risk (glibc is foundational - everything depends on it)
     - +2.5-3.5 hours build time one-time
     - Requires thorough testing before deployment
     - System instability if build fails or optimization introduces bugs
5. **Rollback Plan**:
   - Comment out system-libs overlay in flake.nix
   - `home-manager switch --rollback` to previous generation
   - Test on shoshin first, only deploy to gyakusatsu after confirmed stable
6. **References**:
   - This plan: Phase 0 (System Libraries Foundation)
   - ADR-024: Language Runtime Hardware Optimizations
   - ADR-027: Workspace-Specific Build Optimization

**Document Structure**:
```
docs/adr/
├── ...
├── 027-workspace-specific-build-optimization.md  # NEW
├── 028-system-libraries-hardware-optimization.md  # NEW
└── ...
```

**Update ADR Index**: Add entries for ADR-027 and ADR-028 in `docs/adr/README.md` (if it exists).

---

## Risk Assessment & Mitigation

### High-Risk Items

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **System libs build failure/corruption** | CRITICAL - System unbootable or unstable | LOW-MEDIUM | - Test glibc build in isolation first<br>- Keep previous home-manager generation<br>- Test on shoshin only, defer gyakusatsu until confirmed stable<br>- Rollback plan: comment out overlay, home-manager switch --rollback |
| **OOM during Phase 0 (system libs build)** | HIGH - Build fails, wasted time | MEDIUM | - Monitor RAM usage during glibc build<br>- Use Tier 1 parallelism (maxJobs=1, cores=6)<br>- Close Plasma/apps during build<br>- Fallback: Build system libs one at a time |
| **Cachix 5GB limit exceeded** | MEDIUM - Cannot cache new builds, gyakusatsu forced to rebuild | MEDIUM | - Implement tiered caching (Tier 1 priority)<br>- Regular cleanup (monthly gc)<br>- Monitor cache usage (Cachix dashboard)<br>- Long-term: Self-host on K8s (deferred project) |
| **Node.js test build fails** | MEDIUM - Cannot proceed with refactor | LOW | - Already fixed typo (NIX_CXXFLAGS_COMPILE)<br>- Test build WITHOUT activating overlay (safe)<br>- If fails: Analyze error, fix before proceeding<br>- Fallback: Skip Node.js optimization, proceed with rest |
| **Build time exceeds 8 hours** | LOW - Inconvenient, but not critical | LOW-MEDIUM | - Expected: 6-8 hours first build<br>- Run overnight or over weekend<br>- Can pause/resume Nix builds<br>- Subsequent rebuilds <30min with Cachix |

### Medium-Risk Items

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Tier-based parallelism configuration complex** | MEDIUM - Config errors, suboptimal performance | MEDIUM | - Start with simple global maxJobs=6<br>- Gradually add per-package settings<br>- Test each tier separately<br>- Document in ADR-027 |
| **Split derivations don't improve cache effectiveness** | MEDIUM - Wasted effort, no benefit | LOW-MEDIUM | - Test ONNX split first (clear split point)<br>- Measure cache hit rate before/after<br>- If no improvement, revert to monolithic |
| **gyakusatsu cache miss forces local build** | MEDIUM - OOM or very slow build | LOW | - Ensure shoshin pushes to Cachix before gyakusatsu pull<br>- Monitor Cachix availability<br>- Fallback: Build with pgoLevel=NONE (no PGO, lighter) |
| **K8s tools version mismatch with Eyeonix clusters** | LOW-MEDIUM - kubectl incompatible | LOW | - kubectl ±1 version compatible with clusters<br>- tenv allows easy version switching<br>- Update kubectl version in config as needed |

### Low-Risk Items

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **LLVM build fails** | LOW - Can proceed without, already planned | LOW | - Already planned in original doc (Phase 5)<br>- LLVM build is separate, doesn't block runtimes<br>- Fallback: Use nixpkgs LLVM |
| **IaC tools (tenv) version conflicts** | LOW - Easy to fix | LOW | - tenv handles versions well<br>- Project-specific .terraform-version files<br>- Can install multiple versions |
| **Pre-commit hooks slow down commits** | LOW - Annoying, not critical | LOW | - Hooks already tested in Phase 1-2<br>- Can skip with --no-verify if needed |

### Overall Risk Level

**Assessment**: **MEDIUM-HIGH**

**Rationale**:
- System libraries optimization (Phase 0) is HIGH RISK (foundational, everything depends on it)
- But with proper testing (test builds, shoshin first, rollback plan), risk is manageable
- Majority of work (Phases 1-3) is LOW-MEDIUM risk (already planned or lightweight tools)
- Phase 4 (build optimization) is MEDIUM risk (config complexity, but reversible)

**Go/No-Go Decision**:
- ✅ **PROCEED** with caution
- ✅ Test Node.js fix FIRST (Phase 2 test from original plan) to validate build process
- ✅ Test glibc build in isolation before full Phase 0
- ✅ Keep rollback plan ready (previous home-manager generation)
- ✅ Run on shoshin first, deploy to gyakusatsu only after confirmed stable

---

## Timeline & Execution Roadmap

**User Timeline Preference** (QnA Round 3):
> "Runtimes and optimizations first, THEN K8s tools"

**User Final Confirmation** (QnA Round 5):
> "Yes, but Node.js fix first as test"

### Execution Phases (Revised Order)

**Phase 0.5: Node.js Test Build** (FIRST - from original plan Phase 3)
- **Objective**: Validate build process, Cachix workflow, pre-commit hooks
- **Actions**: Test build Node.js with FULL PGO (WITHOUT activating overlay)
- **Duration**: 60-90 minutes (build time)
- **Success Criteria**: Build completes, V8 compiled, hardware flags applied, PGO training succeeds
- **Go/No-Go**: If test succeeds → Proceed to Phase 0. If fails → Fix issue before proceeding.

**Phase 0: System Libraries Foundation** (THEN - NEW)
- **Objective**: Build ALL critical system libs with hardware optimizations
- **Actions**:
  1. Create `system-libs-hardware-optimized.nix` overlay
  2. Test glibc build in isolation
  3. Enable overlay in flake.nix (FIRST in overlay list)
  4. Build all system libs (Tier 1 parallelism: maxJobs=1, cores=6)
  5. Test system stability (reboot, run apps, verify no corruption)
  6. Push to Cachix Tier 1 (highest priority)
- **Duration**: 2.5-3.5 hours build + 1-2 hours testing = **4-5 hours total**
- **Success Criteria**: All libs build successfully, system stable, 5-10% performance gain measured

**Phase 1: LLVM Compiler Infrastructure**
- **Objective**: Build LLVM with hardware optimizations for faster CUDA compilation
- **Actions**: (Already documented in original plan Phase 5)
- **Duration**: 30-45 minutes build + 30min testing = **1-1.5 hours total**
- **Success Criteria**: LLVM builds, nvcc compilation 10-20% faster

**Phase 2: Language Runtimes**
- **Objective**: Build Python, Rust, Node.js, Go with FULL PGO + hardware flags on top of optimized system libs
- **Actions**:
  1. Build Go (light, fast validation)
  2. Build Rust with PGO + LTO
  3. Build Python with FULL PGO
  4. Enable Node.js overlay (already tested in Phase 0.5), rebuild if needed
  5. Integrate Codex memory-limited mode (from original plan Phase 4)
  6. Test all runtimes (import time, startup time, benchmarks)
  7. Push to Cachix Tier 1
- **Duration**: 2.5-4 hours build + 1 hour testing = **3.5-5 hours total**
- **Success Criteria**: All runtimes build with FULL PGO, 15-40% performance gains measured

**Phase 3: Kubernetes & IaC Tooling**
- **Objective**: Install comprehensive K8s toolkit + OpenTofu/Terraform
- **Actions**:
  1. Create modules/infra/ structure (k8s/ and iac/ subdirectories)
  2. Implement kubectl (latest 1.35), helm, k9s, stern, kubectx, kubens, kubecolor, krew
  3. Implement tenv with OpenTofu 1.10.0 + Terraform 1.14.3
  4. Update home.nix to import modules/infra
  5. Test all tools (kubectl version, helm version, tenv list, etc.)
  6. Push lightweight tools to Cachix Tier 3 (optional, mostly pre-compiled)
- **Duration**: 2-3 hours implementation + 1 hour testing = **3-4 hours total**
- **Success Criteria**: All tools installed and working, kubectl 1.35, both IaC tools via tenv

**Phase 4: Build Optimization & Workspace Decoupling**
- **Objective**: Implement tier-based parallelism, split derivations, workspace-specific configs
- **Actions**:
  1. Create build-parallelism.nix configuration
  2. Update hardware profiles with per-package settings (nixBuildCores)
  3. Implement ONNX Runtime derivation split (test case)
  4. Test parallelism (monitor builds, verify Tier 1/2/3 behavior)
  5. Test gyakusatsu workspace (cache hit rate, build time, package selection)
  6. Create ADR-027 and ADR-028
  7. Update existing runtime optimization plan with Phase 0 integration notes
- **Duration**: 8-13 hours (as calculated in Phase 4 section)
- **Success Criteria**: Tier-based parallelism working, 15-25% faster builds, gyakusatsu <5min rebuilds

### Complete Timeline

| Phase | Duration | Cumulative | Can Run Overnight? |
|-------|----------|------------|-------------------|
| **0.5: Node.js Test** | 1.5-2 hours | 1.5-2 hours | ❌ No (need to monitor first test) |
| **0: System Libs** | 4-5 hours | 5.5-7 hours | ✅ Yes (after initial glibc test) |
| **1: LLVM** | 1-1.5 hours | 6.5-8.5 hours | ✅ Yes (can chain with Phase 0) |
| **2: Runtimes** | 3.5-5 hours | 10-13.5 hours | ✅ Yes (overnight batch: Phase 0→1→2) |
| **3: K8s Tools** | 3-4 hours | 13-17.5 hours | ❌ No (implementation/config work, not just building) |
| **4: Build Optimization** | 8-13 hours | 21-30.5 hours | Partial (testing needs active monitoring) |

**Recommended Schedule**:

**Day 1 (Weekend, 2-3 hours active + overnight build)**:
- Morning: Phase 0.5 (Node.js test build) - 1.5 hours
  - Monitor build, verify success
- Afternoon: Phase 0 setup + glibc isolation test - 1.5 hours
  - Create overlay, test glibc build alone
- **Evening: Start overnight batch** (Phase 0 full → Phase 1 → Phase 2)
  - `home-manager switch` with all overlays enabled
  - Let it run overnight (6-10 hours total build time)

**Day 2 (Weekend, 4-6 hours)**:
- Morning: Verify overnight build success - 1 hour
  - Test system stability, run benchmarks, verify performance gains
  - Push to Cachix
- Afternoon: Phase 3 (K8s + IaC tooling) - 3-4 hours
  - Implementation, configuration, testing
- Evening: Test gyakusatsu cache pull - 30 minutes
  - Verify gyakusatsu can pull optimized builds from Cachix
  - Measure rebuild time (<5 minutes expected)

**Day 3+ (Weekday evenings or next weekend, 8-13 hours over 2-3 days)**:
- Phase 4 (Build Optimization & Workspace Decoupling)
  - Can be done incrementally:
    - Day 3: Parallelism config (2-3 hours)
    - Day 4: Dependency splitting (4-6 hours)
    - Day 5: Testing + ADR documentation (2-4 hours)

**Total Calendar Time**: 1 weekend (Phases 0.5-3) + 1 week evenings (Phase 4) = **~1.5 weeks**

**Total Active Work**: 15-25 hours (rest is unattended build time)

### Risk Mitigation During Execution

**Checkpoints** (Go/No-Go decisions):

1. **After Phase 0.5** (Node.js test): If test FAILS → STOP, fix issue, retest
2. **After glibc isolation test**: If build FAILS or system unstable → STOP, investigate
3. **After Phase 0 overnight build**: Verify system stability before Phase 3
4. **After Phase 2**: Test runtimes with simple programs before Phase 3
5. **After Phase 3**: Test K8s tools before Phase 4

**Rollback Points**:

- **Before Phase 0**: Save current home-manager generation number
- **After each phase**: Verify can rollback to previous generation
- **Emergency rollback**: `home-manager switch --rollback` or edit flake.nix to comment out problematic overlay

### Integration with Existing Work

**Already Completed** (from original runtime optimization plan):
- ✅ Phase 1: Archive deprecated overlays (DONE - committed)
- ✅ Phase 2: Fix Node.js typo (DONE - committed)

**This Plan Incorporates**:
- Phase 0.5: Original Phase 3 (Node.js test build) - TEST FIRST
- Phase 1: Original Phase 5 (LLVM overlay) - unchanged
- Phase 2: Original Phases 2-4 (runtimes) - extended with Phase 0 foundation

**This Plan Adds**:
- **NEW Phase 0**: System libraries (not in original plan)
- **NEW Phase 3**: K8s + IaC tooling (not in original plan)
- **NEW Phase 4**: Build optimization + workspace decoupling (not in original plan)
- **NEW ADRs**: ADR-027, ADR-028 (documentation)

**Original Plan Status After This Refactor**:
- Phases 1-2: ✅ Complete (archive + fix)
- Phase 3: ✅ Complete (Node.js test as Phase 0.5 here)
- Phase 4: ✅ Complete (Codex integration in Phase 2 here)
- Phase 5: ✅ Complete (LLVM as Phase 1 here)
- Phases 6-8: Deferred (pre-commit hooks, overlay audit, docs - done gradually in Phase 4 here)

**Net Result**: This comprehensive plan SUPERSEDES and EXTENDS the original runtime optimization plan.

---

## Integration with Existing Plans

### Files Modified/Created

**New Files**:
```
modules/
├── infra/
│   ├── default.nix                    # NEW
│   ├── k8s/
│   │   ├── default.nix                # NEW
│   │   ├── kubectl.nix                # NEW
│   │   ├── core-tools.nix             # NEW
│   │   ├── productivity-tools.nix     # NEW
│   │   └── krew.nix                   # NEW
│   └── iac/
│       ├── default.nix                # NEW
│       └── tenv.nix                   # NEW
├── profiles/
│   └── build-parallelism.nix          # NEW (Phase 4)
└── system/overlays/
    ├── system-libs-hardware-optimized.nix  # NEW (Phase 0)
    └── llvm-hardware-optimized.nix    # NEW (Phase 1, already planned)

docs/
├── adr/
│   ├── 027-workspace-specific-build-optimization.md  # NEW
│   └── 028-system-libraries-hardware-optimization.md  # NEW
└── projects/home-manager-optimizations/
    └── 2025-12-30-comprehensive-home-manager-refactor-plan.md  # THIS DOCUMENT
```

**Modified Files**:
```
flake.nix                              # Add system-libs overlay first, then LLVM, update overlay order
home.nix                               # Import modules/infra
modules/infra/k8s/default.nix          # Replace placeholder with actual imports
modules/infra/iac/default.nix          # Replace placeholder with tenv
modules/profiles/config/hardware/shoshin.nix     # Add per-package parallelism settings (Phase 4)
modules/profiles/config/hardware/gyakusatsu.nix  # Verify CUDA skip settings
modules/system/overlays/nodejs-hardware-optimized.nix  # Enable in flake.nix after test (Phase 0.5)
```

### Dependency Graph

```
Phase 0.5 (Node.js Test)
   ↓
Phase 0 (System Libs) ← FOUNDATIONAL, builds first
   ↓
Phase 1 (LLVM) ← Builds on optimized system libs
   ↓
Phase 2 (Runtimes) ← Python/Rust/Node.js link against Phase 0 libs, compile with Phase 1 LLVM
   ↓
Phase 3 (K8s Tools) ← Independent, can run in parallel with Phase 2 if desired
   ↓
Phase 4 (Build Optimization) ← Applies learnings from Phases 0-3, iterative refinement
```

### Relationship to Original Plan

| Original Plan Phase | This Plan Equivalent | Status |
|---------------------|----------------------|--------|
| Phase 1: Cleanup | ✅ Complete (committed) | Superseded |
| Phase 2: Node.js Fix | ✅ Complete (committed) | Superseded |
| Phase 3: Node.js Test | Phase 0.5 (FIRST in this plan) | **DO THIS FIRST** |
| Phase 4: Codex Integration | Phase 2 (part of Runtimes) | Extended |
| Phase 5: LLVM Overlay | Phase 1 (after System Libs) | Extended with Phase 0 dependency |
| Phase 6: Pre-commit Hooks | Phase 4 (Build Optimization) | Integrated |
| Phase 7: Overlay Audit | Phase 4 (Build Optimization) | Integrated |
| Phase 8: Documentation | Phase 4 + ADR-027/028 | Integrated + Extended |

**Superseded**: Original plan is now subsumed by this comprehensive plan. All original goals achieved plus additional scope (System Libs, K8s Tools, Workspace Decoupling).

---

## Conclusion

This comprehensive refactor plan integrates ALL QnA decisions (5 rounds, 20 questions), web research findings (latest tool versions), and extends the original runtime optimization plan with:

1. **Phase 0: System Libraries Foundation** (NEW) - 5-10% system-wide performance gain
2. **Phase 1-2: Compiler Infrastructure + Runtimes** (EXTENDED) - Now builds on Phase 0, cascading gains
3. **Phase 3: Kubernetes & IaC Tooling** (NEW) - Comprehensive toolkit for CKA + work + dissertation
4. **Phase 4: Build Optimization & Workspace Decoupling** (NEW) - Intelligent parallelism, tiered Cachix, workspace-specific configs

**Expected Outcomes**:
- **shoshin**: 15-40% runtime performance improvements (system libs + runtimes with FULL PGO), 15-25% faster builds (better parallelization)
- **gyakusatsu**: <5 minute rebuilds (vs 2-3 hours local), 80%+ Cachix cache hit rate, inherits shoshin's optimizations
- **K8s/IaC**: Complete professional toolkit ready for CKA exam, Eyeonix SRE work, dissertation development

**Documentation**: ADR-027 (Workspace Build Optimization), ADR-028 (System Libraries Optimization)

**Next Steps** (per user requirement):
1. ✅ Review this plan
2. ✅ Test Node.js fix (Phase 0.5 from original plan) - **DO THIS FIRST**
3. ✅ Proceed with Phase 0 (System Libs) after Node.js test succeeds
4. ✅ Execute Phases 1-4 sequentially as documented
5. ✅ Create ADRs during Phase 4

**Estimated Total Time**: 1.5 weeks calendar time (1 weekend + weekday evenings), 15-25 hours active work

---

**Time**: 2025-12-30T03:20:32+02:00 (Europe/Athens)
**Tokens**: in=120017, out=~17000 (estimated), total=~137000, usage≈69% of context

**Plan Status**: ✅ **COMPLETE - Ready for User Review and Implementation**

