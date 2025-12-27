# ADR-022: Scripts Management via Chezmoi

## Status
Accepted

## Context
We have scripts scattered across repositories (`home-manager/scripts`, etc.) which leads to inconsistency, lack of version control centralization for user scripts, and "dirty" git trees in the `home-manager` repo when generated or modified during runtime. The `home-manager` repo should focus on declarative configuration, while `dotfiles` (managed by `chezmoi`) is the designated place for mutable user scripts and templates.

## Decision
1.  All user-facing scripts MUST be managed under the `dotfiles` repository.
2.  These scripts MUST be under `chezmoi` control (e.g., in `dot_local/bin/`).
3.  Scripts inside `home-manager` MUST be restricted to build-time hooks or internal module logic, not user-invoked utilities.
4.  Existing scripts in `home-manager/scripts` that are intended for the user (like update helpers) MUST be migrated to `dotfiles`.

## Consequences
- **Positive:** Centralized script management, clean `home-manager` git tree, leverage `chezmoi` templating for scripts.
- **Negative:** Requires migration of existing scripts.
