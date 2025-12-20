# Hardware Profile System

**Status**: Implemented (2025-12-19)
**Version**: 1.0
**Author**: Technical Research + System Architecture

---

## Overview

The Hardware Profile System decouples hardware-specific configurations from the codebase, making the home-manager configuration **portable**, **maintainable**, and **future-proof**.

### Problem Statement

Before this system, the codebase contained **57 hardcoded hardware references** across **14 files**:
- GPU model hardcoded: "GTX 960", "Maxwell", "Compute Capability 5.2"
- CPU architecture hardcoded: "i7-6700K", "Skylake", `-march=skylake`
- Memory limits hardcoded: Assumes 16GB RAM system
- Build parallelism hardcoded: Assumes 8-thread CPU

**Consequences**:
- ❌ Cannot use different GPUs without manual overlay edits
- ❌ Builds fail or OOM on systems with <16GB RAM
- ❌ Slow builds on systems with different core counts
- ❌ Non-portable to future workspaces (laptop, Kinoite)

### Solution: Hardware Profiles

Create a **single source of truth** for hardware specifications, then **inject** this profile into overlays and modules.

```nix
# profiles/hardware/shoshin.nix (Hardware Specification)
{
  cpu = { model = "i7-6700K"; cores = 8; family = "skylake"; };
  gpu = { model = "GTX 960"; computeCapability = "52"; vendor = "nvidia"; };
  memory = { total = "16"; };
  build = { parallelism = { cargoBuildJobs = 2; makeJobs = 2; }; };
}

# flake.nix (Inject into overlays)
shoshinHardware = import ./profiles/hardware/shoshin.nix;
overlays = [
  (import ./overlays/firefox-memory-optimized.nix shoshinHardware)
];
```

---

## Architecture

### File Structure

```
home-manager/
├── profiles/
│   └── hardware/
│       ├── shoshin.nix      # Desktop: i7-6700K + GTX 960
│       ├── laptop.nix        # Future: Laptop profile
│       └── kinoite.nix       # Future: Fedora Kinoite profile
├── overlays/
│   ├── firefox-memory-optimized.nix        # Accepts hardwareProfile param
│   └── onnxruntime-gpu-optimized.nix       # Accepts hardwareProfile param
└── flake.nix                                # Loads and injects profiles
```

### Data Flow

```
1. flake.nix loads profile:
   shoshinHardware = import ./profiles/hardware/shoshin.nix;

2. Profile passed to overlays:
   (import ./overlays/firefox-memory-optimized.nix shoshinHardware)

3. Overlay extracts values:
   let
     firefoxSettings = hardwareProfile.packages.firefox;
     cpuMarch = hardwareProfile.build.compiler.march;
   in
   {
     NIX_CFLAGS_COMPILE = "-march=${cpuMarch}";
   }

4. Build adapts automatically to hardware
```

---

## Hardware Profile Specification

### Required Sections

#### 1. System Identification
```nix
system = {
  hostname = "shoshin";
  type = "desktop";           # desktop | laptop | server
  workspace = "personal";     # personal | work | hybrid
};
```

#### 2. CPU Specifications
```nix
cpu = {
  vendor = "intel";           # intel | amd
  model = "i7-6700K";
  family = "skylake";         # For -march= flag
  cores = 4;                  # Physical cores
  threads = 8;                # With hyperthreading
  baseFrequency = "4.0";      # GHz
  turboFrequency = "4.2";     # GHz
  instructionSets = [ "AVX2" "FMA3" "AES-NI" ];
};
```

#### 3. GPU Specifications
```nix
gpu = {
  vendor = "nvidia";          # nvidia | amd | intel | none
  model = "GTX 960";
  architecture = "maxwell";   # maxwell | pascal | turing | ampere
  cudaSupport = true;
  computeCapability = "5.2";  # For CUDA compilation
  vram = "4";                 # GB
  minDriverVersion = "570.195.03";
  maxCudaVersion = "12.8";
};
```

#### 4. Memory Configuration
```nix
memory = {
  total = "16";               # GB
  type = "DDR4";
  speed = "2400";             # MHz
  channels = 2;               # Dual-channel
  zramEnabled = true;
  zramPercentage = 75;        # 75% of RAM
  effectiveTotal = "28";      # RAM + zram
};
```

#### 5. Build Constraints
```nix
build = {
  memory = {
    maxPerService = "14";     # GB (systemd MemoryMax)
    recommendedHigh = "12";   # GB (systemd MemoryHigh)
    heavyBuildLimit = "10";   # GB peak for Firefox/LLVM
  };

  parallelism = {
    maxJobs = 1;              # Nix --max-jobs
    maxCores = 7;             # Nix --cores
    heavyBuildCores = 2;      # For Firefox, LLVM
    cargoBuildJobs = 2;       # Rust builds
    linkerJobs = 1;           # Linking (memory-intensive)
  };

  compiler = {
    march = "skylake";        # -march=skylake
    mtune = "skylake";        # -mtune=skylake
    optimizationLevel = "3";  # -O3
    lto = { default = false; thin = true; };
    preferredLinker = "mold"; # mold > lld > ld
  };

  cuda = {
    architecture = "52";      # CMAKE_CUDA_ARCHITECTURES
    optimizationLevel = "3";
    useFastMath = true;
    maxRegCount = 64;
  };
};
```

#### 6. Package-Specific Overrides
```nix
packages = {
  firefox = {
    disableLTO = true;
    disableTests = true;
    cargoBuildJobs = 2;
    makeJobs = 2;
    rustCodegenUnits = 16;
  };

  onnxruntime = {
    cudaSupport = true;
    disableLTO = true;
    useModernLinker = true;
    ninjaJobs = 1;
    cudaArch = "52";
  };
};
```

---

## Usage Guide

### Adding a New Workspace

1. **Create hardware profile**:
   ```bash
   cp profiles/hardware/shoshin.nix profiles/hardware/laptop.nix
   ```

2. **Update profile values**:
   ```nix
   # profiles/hardware/laptop.nix
   {
     system.hostname = "laptop";
     cpu = { model = "i5-1240P"; family = "alderlake"; cores = 12; };
     gpu = { vendor = "intel"; model = "Iris Xe"; cudaSupport = false; };
     memory = { total = "32"; };
     # ... adjust build.parallelism for more cores
   }
   ```

3. **Load in flake.nix**:
   ```nix
   let
     shoshinHardware = import ./profiles/hardware/shoshin.nix;
     laptopHardware = import ./profiles/hardware/laptop.nix;
   in
   {
     homeConfigurations = {
       "mitsio@shoshin" = { ... overlays = [ (import ./overlays/XX.nix shoshinHardware) ]; };
       "mitsio@laptop" = { ... overlays = [ (import ./overlays/XX.nix laptopHardware) ]; };
     };
   }
   ```

### Upgrading Hardware

Example: Upgrade GTX 960 → RTX 4060

1. **Update GPU section**:
   ```nix
   # profiles/hardware/shoshin.nix
   gpu = {
     vendor = "nvidia";
     model = "RTX 4060";
     architecture = "ada";         # Ada Lovelace
     computeCapability = "8.9";    # Changed from 5.2
     vram = "8";                   # Changed from 4GB
     maxCudaVersion = "12.8";
   };
   ```

2. **Update CUDA build settings**:
   ```nix
   build.cuda = {
     architecture = "89";          # Changed from 52
     maxRegCount = 128;            # Changed from 64 (more registers on modern GPUs)
   };
   ```

3. **Rebuild**:
   ```bash
   home-manager switch --flake .#mitsio@shoshin
   ```

**All overlays automatically adapt!** No manual overlay edits needed.

---

## Overlay Development Guide

### Template for New Parameterized Overlay

```nix
# overlays/my-package-optimized.nix
hardwareProfile: final: prev:

let
  # Extract package-specific settings
  mySettings = hardwareProfile.packages.myPackage or {
    enableFeature = true;
    maxJobs = 4;
  };

  # Extract hardware specs
  cpuMarch = hardwareProfile.build.compiler.march or "native";
  cudaArch = hardwareProfile.build.cuda.architecture or "75";
in

{
  myPackage = prev.myPackage.overrideAttrs (old: {
    # Use hardwareProfile values instead of hardcoding
    NIX_CFLAGS_COMPILE = "-march=${cpuMarch} -O3";
    CMAKE_CUDA_ARCHITECTURES = cudaArch;
    ninjaFlags = [ "-j${toString mySettings.maxJobs}" ];
  });
}
```

### Best Practices

1. **Always provide defaults**: Use `or` operator for missing values
   ```nix
   cpuCores = hardwareProfile.cpu.cores or 4;
   ```

2. **Document hardware assumptions** in overlay header
   ```nix
   # This overlay assumes:
   # - hardwareProfile.gpu.cudaSupport = true
   # - hardwareProfile.build.compiler.march is set
   ```

3. **Validate critical values**:
   ```nix
   assert hardwareProfile.gpu.cudaSupport or false;
   assert hardwareProfile.build.cuda.architecture != null;
   ```

4. **Add migration notes** in profile:
   ```nix
   migration = {
     notes = "Update build.cuda.architecture when upgrading GPU";
   };
   ```

---

## Research Findings

### Hardware-Coupled Configurations Identified

**Total**: 57 references across 14 files

| Category | Files | References | Impact |
|----------|-------|-----------|---------|
| GPU/CUDA | 5 | 23 | Cannot use different GPUs |
| CPU/Build | 3 | 12 | Build fails on different CPUs |
| Memory | 6 | 15 | OOM on <16GB systems |
| Display | 3 | 7 | Breaks on Wayland-only |

**Most Critical Files**:
1. `overlays/onnxruntime-gpu-optimized.nix` - 8 GPU/CPU hardcoded refs
2. `overlays/firefox-memory-optimized.nix` - 6 CPU/memory hardcoded refs
3. `brave.nix` - 5 NVIDIA-specific hardcoded refs
4. `firefox.nix` - 7 display/GPU hardcoded refs
5. `oom-protected-wrappers.nix` - 8 memory limit hardcoded refs

**Future Work**:
- Parameterize browser memory limits (brave.nix, firefox.nix)
- Conditional display protocol (X11 vs Wayland)
- Parameterize systemd service resource limits
- Auto-detect hardware specs (nproc, GPU query)

---

## Migration Checklist

When migrating to new hardware:

- [ ] Update `profiles/hardware/<hostname>.nix`
  - [ ] CPU: model, family, cores, threads
  - [ ] GPU: model, architecture, computeCapability
  - [ ] Memory: total, type, speed
  - [ ] Build: parallelism settings for new core count
  - [ ] Compiler: march/mtune for new CPU architecture
  - [ ] CUDA: architecture for new GPU compute capability

- [ ] Test rebuild:
  ```bash
  home-manager switch --flake .#mitsio@<hostname> --dry-run
  ```

- [ ] Verify hardware detection:
  ```bash
  nix eval .#homeConfigurations."mitsio@<hostname>".config.programs.firefox.package.meta
  ```

- [ ] Full rebuild:
  ```bash
  home-manager switch --flake .#mitsio@<hostname>
  ```

---

## Troubleshooting

### Error: "Unknown option '--disable-lto'"
**Cause**: Profile has `packages.firefox.disableLTO = false` but package doesn't support the flag.
**Fix**: Update profile or overlay to handle package-specific flag support.

### Error: "CUDA compute capability mismatch"
**Cause**: Profile has wrong `build.cuda.architecture` for your GPU.
**Fix**: Check GPU compute capability:
```bash
nvidia-smi --query-gpu=compute_cap --format=csv
```
Update profile accordingly.

### Build OOM despite profile settings
**Cause**: Profile `build.memory.maxPerService` too high for system RAM.
**Fix**: Reduce to ~80% of physical RAM:
```nix
build.memory.maxPerService = "${toString (physicalRAM * 0.8)}";
```

---

## References

- **Research**: Hardware-coupled config analysis (57 refs identified)
- **Mozilla Docs**: https://firefox-source-docs.mozilla.org/build/
- **NVIDIA CUDA**: https://docs.nvidia.com/cuda/maxwell-compatibility-guide/
- **NixOS Patterns**: Parameterized overlays, hardware profiles
- **Commit**: `3b4fe10` - Implement modular hardware profile system

---

**Created**: 2025-12-19
**Last Updated**: 2025-12-19
**Next Review**: After hardware upgrade or workspace migration
