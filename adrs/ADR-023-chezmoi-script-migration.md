# ADR-023: Chezmoi as Canonical Source for User Scripts
**Status:** Proposed
**Date:** 2025-12-27
**Related:** ADR-022 (Dotfiles as Canonical Script Store)

## Context
Multiple user scripts (rclone helper wrappers, syncthing helpers, critical/productivity service restart scripts, OOM-protected launchers) were still generated via `home.file` blocks inside the Home-Manager repo. After a reboot, scripts disappeared when the generation path changed or when HM wasn't rebuilt, causing service failures (e.g., gdrive sync, Git cleanup). ADR-022 already declared dotfiles/chezmoi the single source of truth for user scripts, but implementation lagged.

## Decision
1. **Move all user scripts to the dotfiles/chezmoi repo** (`dot_local/bin/executable_*.tmpl`, `private_dot_local` for host-specific details).
2. **Home-Manager references scripts only via path** (`~/.local/bin/<script>`), no longer generating inline text. HM adds activation guards to fail fast if a required script is missing, instructing the user to run `chezmoi apply`.
3. **Chezmoi apply includes scripts by default** by configuring `[apply].include = ["dot_local/bin", ...]` in `chezmoi.toml`. `home-manager switch` now assumes scripts were refreshed and fails loudly otherwise.
4. **Flake workflow:** After `nix flake update` and before `home-manager switch`, run `chezmoi apply` (or a scripted helper) to guarantee scripts/services stay in sync.

## Consequences
- ✅ Scripts survive HM rebuilds/reboots (managed by dotfiles).
- ✅ Service/timer units no longer break if HM isn't rebuilt immediately; they just rely on dotfiles.
- ✅ Single review surface for scripts (dotfiles repo), matching ADR-022.
- ⚠️ Requires `chezmoi apply` before each HM switch; enforced via activation guard.
- ⚠️ Home-Manager configs now depend on dotfiles layout being correct; missing script causes `home-manager switch` failure with explicit instructions.

## Implementation Checklist
1. Migrate `rclone-gdrive-{sync,status,resync,manual}.sh` and `rclone-notify` into dotfiles templates; remove `home.file` bodies and replace with activation guard.
2. Repeat for `syncthing-{id,open,status,restart}.sh` and service restart scripts (`critical-services`, `productivity-services`).
3. Move OOM-protected wrappers, `hm-switch-fast`, and remaining helper scripts to dotfiles.
4. Update docs (`docs/chezmoi/chezmoi-guide.md`, `docs/TODO.md`) with the new workflow.
5. Add CI/checklist step in flake update instructions: `chezmoi apply --include dot_local/bin && home-manager switch`.
