# ADR-012: Flake-First Toolchain & Auto-Update Standards

**Status:** Accepted
**Date:** 2025-12-22
**Context:** The workspace relies on diverse tools (AI agents, browsers, editors) that require frequent updates. Manually updating packages is inefficient. Building large apps (Firefox, Obsidian) from source causes OOM on the current hardware (16GB RAM).

## Decision

1.  **Flake-First for Critical Tools:**
    *   Critical tools (Gemini, Claude, Codex, Firefox, Obsidian) MUST be defined as **Flake Inputs** in `home-manager/flake.nix` (or `flake.nix` of the respective project) to pin versions and allow independent updates.
    *   This ensures we can track specific branches (e.g., `nixpkgs-unstable`, `firefox-nightly`, or specific commit hashes) for these fast-moving tools.

2.  **Binary Cache Priority:**
    *   To avoid OOM during builds, we MUST prefer **pre-built binaries** (e.g., `firefox-bin`, `obsidian-bin` or standard packages from binary cache) over building from source with custom flags.
    *   Optimization (GPU, Memory) MUST be applied via **Runtime Wrappers** (using `symlinkJoin`, `makeWrapper`, or Home Manager modules that wrap the binary) rather than compilation flags.

3.  **Unified Auto-Update Mechanism:**
    *   A standardized script (`update-workspace.sh`) will handle the update cycle:
        1.  `nix flake update` (locks new versions).
        2.  `git commit flake.lock` (persists state).
        3.  `home-manager switch` (applies updates).
    *   This script can be triggered manually or via Systemd Timer.

## Consequences

*   **Pros:**
    *   Faster builds (no compilation of heavy apps).
    *   No OOM crashes.
    *   Reproducible state (lockfiles committed).
    *   "Nightly" updates possible for specific tools without destabilizing the whole system.
*   **Cons:**
    *   Cannot apply compile-time optimizations (like `-march=native`), but modern binaries are usually optimized enough (O2/O3).
    *   Runtime wrappers add a small layer of complexity to configuration.

## Implementation

*   **Script:** `toolkit/scripts/update-workspace.sh`
*   **Firefox:** Uses `firefox-bin` wrapped with GPU flags in `firefox.nix`.
*   **Gemini:** Uses `numtide/llm-agents` flake input.
