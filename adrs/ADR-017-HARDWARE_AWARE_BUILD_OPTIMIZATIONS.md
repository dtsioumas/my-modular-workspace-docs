# ADR-017: Hardware-Aware Build & RAM Optimization

**Status:** Proposed  
**Date:** 2025-12-23  
**Authors:** Mitsos, Codex  

---

## Context

- Rebuilding heavy packages (Codex CLI, ONNX Runtime, MCP servers, Firefox) regularly exhausts RAM on shoshin (15 GB) and requires host-specific GPU flags (Maxwell sm_52) plus CPU-specific optimizations (Skylake AVX2).
- Existing hardware profiles (`home-manager/profiles/hardware/*.nix`) already capture CPU/GPU metadata but package overrides were ad-hoc or embedded directly in modules.
- Resource budgets differ per host (shoshin desktop vs. kinoite WSL vs. wsl-workspace). A portable workflow must let each workspace describe parallelism, linker behavior, CUDA tuning, and cgroup limits without rewriting modules.
- The user wants to aggressively reduce RAM usage and compile times by pushing hardware data into overlays/modules, then (optionally) publish the resulting binaries via Cachix.

---

## Decision

1. **Single Source of Truth:**  
   - Extend each hardware profile with a `build.parallelism` section (global nix limits) and `packages.<name>` sections for per-package knobs (e.g., `cargoBuildJobs`, `nixBuildCores`, CUDA arch, `ulimitVirtualMemoryKB`).  
   - Modules and overlays must read from `currentHardwareProfile` instead of hardcoding values.

2. **Module Pattern:**  
   - Every package that deviates from upstream defaults (Codex, Firefox, ONNX, MCP servers, CUDA ffmpeg, etc.) must have a dedicated module or overlay that accepts `hardwareProfile` and translates its settings into `RUSTFLAGS`, `NIX_BUILD_CORES`, `CMAKE_*`, systemd resource limits, etc.  
   - Runtime wrappers (`systemd-run --scope`, `oom-protected-wrappers.nix`) inherit limits from the same profile to keep CPU/RAM constraints consistent.

3. **Documentation & Enforcement:**  
   - Record new knobs in `docs/home-manager/HARDWARE_OPTIMIZATIONS.md` (or equivalent) and link this ADR whenever a module/overlay consumes hardware data.  
   - When adding a package that needs tuning, update the hardware profile first; CI/review should reject modules that bake literal host data.

4. **Cache Strategy:**  
   - Hardware-tuned derivations are expected to be cached (e.g., personal Cachix) so other hosts can reuse them. The ADR does not mandate cache hosting, but modules should expose standalone `packages.<name>` outputs to make `nix build` + cache push trivial.

---

## Consequences

### Positive
- Per-host RAM/CPU budgets are centralized; changing `cargoBuildJobs` or CUDA flags only requires editing the hardware profile.
- Overlays remain portable: kinoite or future Fedora builders can import the same module and automatically get their preferred settings.
- Easier to reason about rebuild regressions—`git diff` of `profiles/hardware/*.nix` shows exactly why a package suddenly needs more RAM.
- Facilitates automation (Cachix, remote builders) because tuned packages have dedicated outputs.

### Negative
- Hardware profiles grow larger and must stay accurate; forgetting to update them when hardware changes could yield suboptimal binaries.
- Modules need extra plumbing (`hardwareProfile ? { }`), increasing boilerplate.
- CI or new hosts must provide sane defaults (fallback values) to avoid evaluation failures when a profile omits a package override.

### Neutral / Risks
- Aggressive tuning (e.g., `cargoBuildJobs = 4`) can still OOM if the profile lies; mitigated by documenting safe ranges and using runtime limits.
- Cachix pushes are optional but strongly recommended; without them new machines still pay the compile cost.

---

## Implementation Plan

1. **Profile Enhancements:** Update all existing hardware profiles (shoshin, kinoite, wsl-workspace) to include `build.parallelism` and relevant `packages.*` entries. Provide defaults for hosts that lack GPU features.
2. **Module Refactors:**  
   - `modules/agents/codex.nix`, `overlays/onnxruntime-gpu-optimized.nix`, `firefox-memory-optimized.nix`, MCP server derivations, etc., must import `hardwareProfile` and use its values.  
   - Guard overlays with `lib.optional` flags (e.g., `enableCuda`) so hosts that do not need them use upstream binaries.
3. **Documentation:** Create/expand `docs/home-manager/HARDWARE_OPTIMIZATIONS.md` to describe how to add new package overrides and how to tune RAM usage per host. Reference this ADR in the README sections for hardware profiles and overlays.
4. **Tooling:**  
   - Add helper functions/macros (e.g., `lib.hardwareProfile.orDefault pkg "codex" { ... }`) to reduce boilerplate.  
   - Integrate Cachix or remote-builder workflows (future work) so tuned packages are pushed automatically after `nix build`.

---

## Status & Next Steps

- **In Progress:** shoshin profile already defines global parallelism and package overrides for Firefox, ONNX Runtime, and Codex; modules now consume those settings.  
- **Next:** replicate the pattern for other heavy packages (Chromium, ck-search MCP servers, ffmpeg) and document cache/pipeline expectations once the Cachix token is available.
