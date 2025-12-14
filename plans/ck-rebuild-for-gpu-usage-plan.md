# Plan: Rebuilding ck-search for GPU Acceleration (Updated 2025-12-14)

## Current Context
- **CK Binary Source**: `home-manager/mcp-servers/rust-custom.nix` builds ck-search 0.7.0 with CPU-only FastEmbed + `pkgs.onnxruntime`.
- **MCP Wrapper**: `mkMcpWrapper` scripts run `ck --serve` via `systemd-run`; no GPU flags exist.
- **FastEmbed Limitations**: GPU use requires a CUDA-enabled ONNX Runtime build; the Rust crate currently links the CPU runtime and exposes no provider flag. citeturn1search1
- **ONNX Runtime Requirements**: CUDA Execution Provider needs matching CUDA/cuDNN versions (CUDA 12.x + cuDNN 9.x for ORT ≥1.19). citeturn0search0

## Goals
1. Produce a reproducible GPU-enabled ck derivation (ideally optional via Home-Manager module option).
2. Keep CPU build as fallback while experimenting.
3. Document exact CUDA/cuDNN expectations and verification steps.

## Work Items
1. **Research Upstream Support**
   - Track ck/FastEmbed issues requesting CUDA provider selection.
   - Determine whether `fastembed` exposes feature flags or environment overrides for GPU.
   - References: add findings to `docs/researches/2025-12-14_ck_gpu_investigation.md`.

2. **Package Dependencies**
   - Create a `pkgs.onnxruntime-gpu` overlay targeting the last CUDA/cuDNN combo supported by GTX 960 (CUDA 11.0 + cuDNN 8.x/9.x per NVIDIA’s compatibility notes).
   - Ensure `LD_LIBRARY_PATH`/`LIBRARY_PATH` include CUDA + cuDNN.
   - Document overlay path: `home-manager/overlays/onnxruntime-gpu.nix` (to be created).

3. **Adjust ck Build**
   - Update `home-manager/mcp-servers/rust-custom.nix` to:
     - Pull in the GPU onnxruntime derivation.
     - Export `ORT_STRATEGY`, `ORT_LIB_LOCATION`, `ORT_CUDA_*` env vars.
     - Optionally include `cudatoolkit`, `cudnn`, `zlib` in `buildInputs`.
   - Consider adding a Home-Manager option `programs.ck.enableGpu = true`.

4. **Runtime Wiring**
   - Extend MCP wrapper to set CUDA-specific env vars when GPU mode is on.
   - Provide detection fallback to CPU mode if CUDA libs missing.

5. **Testing & Verification**
   - Build locally via `home-manager switch`.
   - Run `GPU=1 ck --sem "test" . --jsonl` and monitor `nvidia-smi` for load.
   - Update docs with benchmark before/after CPU usage.

6. **Documentation & Hand-off**
   - Keep instructions updated in this plan + research doc.
   - Record any upstream patches or PR URLs referencing GPU support.

## Additional Tasks Discovered (2025-12-14)
1. **Gather Hardware/Driver Data**
   - Record current NVIDIA driver, CUDA toolkit, and cuDNN versions (`nvidia-smi`, `nvcc --version`, `ls /run/opengl-driver/lib`).
   - Note whether CUDA is installed via `nixpkgs.cudatoolkit` or host system and confirm compute capability (GTX 960 = 5.2 limited to CUDA ≤11.0). citeturn1search0
2. **Overlay Wiring**
   - Decide how overlays are imported (`home-manager/flake.nix`); document required edits before creating `onnxruntime-gpu.nix`.
3. **FastEmbed Provider Check**
   - Inspect ck/FastEmbed source to confirm whether provider selection is configurable (look at `fastembed/src/lib.rs` in the ck vendored version).
4. **MCP Impact**
   - Verify the MCP wrapper still enforces resource limits when GPU mode is enabled; update `mkMcpWrapper` log messages accordingly.
5. **Testing Matrix**
   - Define explicit tests: CLI semantic search, MCP `semantic_search` tool, large-project indexing, and CPU fallback verification.
   - Track known ORT/CUDA bugs (e.g., CUDA 12.4 detection failures) and keep downgrade plan ready. citeturn0search6
6. **Upstream Issue Drafting**
   - Outline the GitHub issue/PR for ck requesting GPU provider support; keep notes in `docs/researches/2025-12-14_ck_gpu_investigation.md`.

## Required Context & Paths
- Docs: `docs/researches/2025-12-14_ck_gpu_investigation.md`, `docs/context/MCP_CODEX_CONFIG.md`, `docs/plans/ck-rebuild-for-gpu-usage-plan.md`
- Prompt: `sessions/prompts/ck_gpu_followup_prompt.txt`
- Home-Manager sources: `home-manager/mcp-servers/rust-custom.nix`, `home-manager/overlays/` (and overlay imports in `home-manager/flake.nix`)
- Dotfiles: `dotfiles/private_dot_codex/config.toml.tmpl`, `dotfiles/dot_bashrc.d/20-systemd-session-env.sh`
- MCP docs: ADR-010 (`docs/adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md`)

## External References
- ONNX Runtime CUDA EP requirements: https://onnxruntime.ai/docs/execution-providers/CUDA-ExecutionProvider.html
- ONNX Runtime build guide for EPs: https://onnxruntime.ai/docs/build/eps.html
- CK GitHub repo (author guide): https://github.com/BeaconBay/ck

## Next Session Checklist
1. Read this plan.
2. Read the research doc listed above.
3. Review `home-manager/mcp-servers/rust-custom.nix`.
4. Gather CUDA/cuDNN versions installed on shoshin.
5. Decide between overlay-based build vs. upstream patch.
