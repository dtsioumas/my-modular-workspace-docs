# ADR-013: Host-Agnostic Dotfiles Requirement

**Date:** 2025-12-21
**Status:** Accepted
**Deciders:** Mitsos + Codex

---

## Context

The workspace is migrating from single-host configs (NixOS on shoshin) to a reusable “modular workspace” that must run on future machines (Fedora Atomic, Windows/WSL, cloud sandboxes). Host-specific values scattered in dotfiles (absolute `/home/mitsio/...` paths, display geometry, hardware IDs) prevent reproducible bootstrap and force manual edits whenever a new machine joins.

Recent work (Plasma templating, ADR-012) introduced `.chezmoidata` and template-first policies, but we need an explicit requirement that **all configurations must be decoupled from the underlying host** so new environments can be provisioned without hand-editing.

---

## Decision

1. **All tracked configs must be host-agnostic.** A repo checkout followed by `chezmoi apply` (plus the documented activation playbooks) must work on any supported machine without editing paths, hostnames, or GPU-specific knobs.
2. **Host-specific data lives in data files**, e.g., `.chezmoidata/plasma.yaml` or host-specific inventories. Templates read from these data sources; modify scripts may only reference abstract tokens (never `/home/mitsio/...`).
3. **Hardware-dependent logic belongs in variables**, not in the rendered config. Example: store NVIDIA driver info in `.chezmoidata/system.yaml`, then conditionally render driver-specific sections inside the template.
4. **CI/automation must stay host-agnostic**: Ansible playbooks, shell helpers, and navi cheats should use `$HOME`, `ansible_user_dir`, or templated values instead of literal `/home/mitsio` paths.
5. **Exceptions require documentation.** If a vendor hardcodes paths (e.g., proprietary binary expects `/etc/nixos`), document the reason in the relevant plan/ADR and log a TODO to rework it.

---

## Consequences

### Positive

* New machines (Fedora Atomic base, WSL, cloud builders) can replay the dotfiles without manual edits.
* Reduces risk of leaking personal paths/emails to public repos.
* Simplifies sync/restore: only `.chezmoidata` and host-specific inventories need updates.

### Negative

* Requires initial effort to migrate remaining absolute paths to data-driven templates.
* More discipline: every new config must pass the “host-agnostic” check before merging.

---

## Implementation Plan

1. **Audit** remaining configs for `/home/mitsio`, `shoshin`, and similar literals. Track findings in `docs/dotfiles/MIGRATION_STATUS.md` (create if absent).
2. **Add linting/CI checks** (optional): e.g., use `rg` in pre-commit to block new commits that contain `/home/mitsio` unless whitelisted.
3. **Migrate & enforce**
   * Convert identified offenders to `.chezmoidata` + templates.
   * Add a short checklist to `docs/CONTRIBUTING.md` (or equivalent): “No absolute paths, no hostnames, no hardcoded device IDs”.
   * Add a “known exceptions” list (small, explicit) with TODOs + owner.

---

## Review

**Next Review:** 2026-03-21
**Review Criteria:**

* Any new host added without manual edits?
* Any regressions (new `/home/mitsio` literals)?
* Does `.chezmoidata` cover all host knobs we actually need?
