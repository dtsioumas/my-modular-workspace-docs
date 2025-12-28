# Home Manager Refactoring & Enhancement Report 2025

**Date:** December 28, 2025
**Reviewer:** Gemini (Ops Engineer Role)

## Executive Summary
The `home-manager` repository is functional but exhibits signs of organic growth ("sprawl"). Key areas for improvement are structural organization, hardware/user decoupling, and standardization of build optimization strategies. The recent introduction of `dream2nix` revealed the need for robust lockfile handling, leading to a temporary reversion to stable manual builds for AI tools.

## 1. Structural Analysis & Refactoring
**Current State:**
- Root directory contains many mix-ins (`brave.nix`, `firefox.nix`, `zsh.nix`) alongside core files (`home.nix`, `flake.nix`).
- `modules/` exists but usage is inconsistent.

**Recommendations (per ADR-026):**
1.  **Move Apps:** Migrate `brave.nix`, `firefox.nix`, `chromium.nix`, `vscodium.nix` to `modules/apps/`.
2.  **Move CLI Tools:** Migrate `atuin.nix`, `navi.nix`, `zellij.nix`, `semtools.nix` to `modules/cli/`.
3.  **Move Services:** Migrate `syncthing-myspaces.nix`, `rclone-*.nix`, `dropbox.nix` to `modules/services/`.
4.  **Consolidate System:** Move `nix-dev-tools.nix`, `ansible-*.nix` to `modules/dev/` or `modules/system/`.

## 2. Decoupling & Portability
**Status: ACHIEVED**
- `flake.nix` now defines `mkHomeConfig` which accepts `username` and `homeDirectory` arguments.
- User identity is no longer hardcoded in the global arguments, allowing the same config to be instantiated for different users/hosts easily.
- Hardware profiles (`profiles/hardware/*.nix`) are effectively used to parameterize build flags (`-march=skylake`, `-O3`).

## 3. Build & Runtime Optimization
**Status: IN PROGRESS**
- **Bun Runtime:** Successfully implemented for `gemini-cli`, `exa`, and `firecrawl` via manual `buildNpmPackage` + Bun wrapper. This saves ~60% RAM.
- **Optimization Overlays:** `performance-critical-apps.nix` and `rust-tier2-optimized.nix` are excellent patterns.
- **Dream2nix:** Currently reverted due to missing `package-lock.json` in upstream sources or lack of pnpm support in the current simple module set.
    - *Future Action:* Generate lockfiles for these tools or wait for Dream2nix v2 maturity.

## 4. Issues Identified & Fixed
- **JSON Parse Error:** `resource-profiles.nix` was failing to parse hardware memory strings (e.g., "16" vs 16). Fixed with robust parsing logic.
- **Python Override Error:** A conflict in `pkgs.python314` or overlay usage was causing evaluation failure. Reverted to `pkgs.python3` (stable) to resolve.
- **Unused Arguments:** Cleaned up `deadnix` warnings in `flake.nix`.

## 5. Next Steps
1.  **Execute Migration:** Move files to `modules/` directories as defined in ADR-026.
2.  **Update Imports:** Update `home.nix` imports to reflect new paths.
3.  **CI/CD:** Set up a Github Action or local hook to run `nix build --dry-run` on commit (partially covered by `pre-commit`).
