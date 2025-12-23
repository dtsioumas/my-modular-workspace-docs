# Hardware-Aware Build Optimizations

**Last Updated:** 2025-12-24  
**Scope:** Home-Manager overlays + hardware profiles (all hosts)

---

## Goals

1. Keep *all* CPU/GPU/RAM tuning data inside `home-manager/profiles/hardware/<host>.nix`.
2. Generate language-specific build settings (Rust, Go, C/C++/CUDA) from that profile so every host automatically uses safe defaults.
3. Provide a universal overlay for WSL/Fedora hosts that fall back to conservative values when no dedicated profile exists.
4. Prepare the codebase for the upcoming rename of `overlays/onnxruntime-gpu-optimized.nix` to the more general `overlays/hardware-build-profiles/{rust,cpp,go}.nix`.

---

## Current Pattern

| Component | Source of truth | Consumer module |
|-----------|-----------------|-----------------|
| Global Nix parallelism (`maxJobs`, `maxCores`, linker jobs) | `hardwareProfile.build.parallelism` | `modules/profiles/build-tooling.nix`, `hm-switch-fast`, `dotfiles/.../nix.conf.tmpl` |
| Rust package settings (`cargoBuildJobs`, `rustCodegenUnits`, `ulimitVirtualMemoryKB`) | `hardwareProfile.packages.<name>` | `modules/agents/codex.nix`, MCP Rust derivations |
| CUDA/CPU flags (ONNX runtime) | `hardwareProfile.packages.onnxruntime` + `hardwareProfile.build.cuda` | `overlays/onnxruntime-gpu-optimized.nix` |

This works, but the overlay/file names are misleading (`onnxruntime-gpu-optimized.nix` also drives ck-search builds) and there is no shared helper for other languages.

---

## Roadmap

### 1. Rename overlay namespace

```
overlays/
└── hardware-build-profiles/
    ├── rust.nix         # consumes hardwareProfile.packages.<pkg>
    ├── cpp-cuda.nix     # CUDA/LTO flags, mold vs lld
    └── go.nix           # GOMAXPROCS, linker tweaks (cgo)
```

- `rust.nix` replaces the ad-hoc logic inside `modules/agents/*` by exporting helper functions (e.g., `mkRustOverrides pkgName`).  
- `cpp-cuda.nix` takes over the ONNX logic plus future ffmpeg/OBS tuning.  
- `go.nix` will handle MCP Go servers (mcp-shell, git-mcp-go) once the Go builder lands.

Until the rename happens, continue to reference `overlays/onnxruntime-gpu-optimized.nix` but update TODOs to point at this document.

### 2. Host-specific + universal fallbacks

- **Dedicated hosts (shoshin, kinoite, wsl-workspace):** define full `build.parallelism` + per-package entries.  
- **Universal fallback (WSL sandbox, CI):** add `profiles/hardware/universal.nix` with conservative defaults; the overlays must detect missing overrides and fall back gracefully (Band A <0.45 confidence rule).

### 3. RAM-focused knobs

For each language:

- **Rust:** `cargoBuildJobs`, `NIX_BUILD_CORES`, `CARGO_PROFILE_RELEASE_CODEGEN_UNITS`, `ulimit -v`, `RAYON_NUM_THREADS`.  
- **Go:** `GOMAXPROCS`, `GODEBUG=madvdontneed=1`, cgo linker flags.  
- **C/C++/CUDA:** `CMAKE_BUILD_PARALLEL_LEVEL`, `-gsplit-dwarf`, mold vs ld, `--use_fast_math`, `maxrregcount`.

Document the acceptable ranges (e.g., Codex safe at 3 jobs on 15 GB) so future hosts know when to adjust.

### 4. Documentation & CI

- Reference ADR-017 for the policy.  
- Update module READMEs to describe which hardware profile fields they expect.  
- Add CI lint (future) to fail if a module hardcodes `CARGO_BUILD_JOBS=` without reading from `hardwareProfile`.

---

## Action Items

- [ ] Rename overlay directory and update imports in `flake.nix`.  
- [ ] Add Go + C++ helper modules following the pattern described above.  
- [ ] Create `profiles/hardware/universal.nix` for WSL/CI fallback.  
- [ ] Extend ADR-017 when the rename is complete (link to commit).  
- [ ] Wire the Terraform/Cachix pipeline (see ADR-018 once published) so tuned packages get cached per host.

Tracking progress here ensures every future package (e.g., ck-search, brave-search MCP, ffmpeg) follows the same hardware-aware pipeline.
