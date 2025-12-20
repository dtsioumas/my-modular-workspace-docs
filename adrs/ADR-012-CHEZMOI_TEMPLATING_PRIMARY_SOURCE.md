# ADR-012: Chezmoi Templates as Cross-Platform Source of Truth

**Date:** 2025-12-20
**Status:** Accepted
**Decider:** Mitsos (with Codex support)
**Context:** Plasma/Dotfiles migration, cross-platform workspace goals (Fedora/Windows)

---

## Problem Statement

The workspace currently mixes two approaches for dotfile management:
1. `chezmoi_modify_manager` snapshots (`*.src.ini` + `modify_*` scripts) to keep high-churn configs
2. Full templates (`*.tmpl`) backed by `.chezmoidata`

Running both for the same target causes:
- `chezmoi` "inconsistent state" errors (template + modify manager referencing one file)
- Host-specific paths baked into `.src.ini`, preventing reuse on Fedora/Windows future hosts
- Drift between declarative data (`.chezmoidata`) and captured configs when only one side updates

We need a single canonical mechanism that works regardless of OS, host name, or hardware layout.

---

## Decision

**All managed dotfiles must be templated through chezmoi**, with host- or environment-specific values stored in `.chezmoidata` (or helper templates). `chezmoi_modify_manager` remains only for legacy configs that cannot yet be templated; when a file is converted to a template, its modify script is removed immediately.

### Key Rules
1. **Single owner per file:** either template or modify-manager, never both.
2. **Data-driven configuration:** `.chezmoidata/<domain>.yaml` holds host overrides (`defaults` + per-host map). Templates read from data; no absolute `$HOME` paths remain inside `.tmpl` files.
3. **Cross-platform readiness:** data keys accommodate future hosts (Fedora, Windows, WSL) so the same template renders correctly on any machine.
4. **Documentation coupling:** every template/data pair is documented (mapping tables under `docs/dotfiles/.../YAML_REFERENCE.md`).
5. **Automation alignment:** the Ansible `plasma-refresh` playbook and navi cheats only reference remaining modify-managed files.

---

## Rationale

| Requirement | Template-first approach | Modify scripts |
|-------------|-------------------------|----------------|
| Cross-platform reuse | ✅ Host data lives in `.chezmoidata`; only template logic changes | ❌ `.src.ini` stores actual paths (e.g., `/home/mitsio/...`)
| Version control clarity | ✅ Text diff inside repo | ⚠️ Diff happens inside generated `.src.ini`
| Declarative overrides | ✅ `defaults` + `hosts.<name>` sections | ❌ Hard-coded per file
| Tooling errors | ✅ `chezmoi diff` works with single source | ❌ Inconsistent-state errors when both owners exist
| Future migration effort | ✅ Copy `.chezmoidata` + templates | ❌ Need manual cleanup of each modify script

---

## Consequences

### Positive
- Unified workflow: host data → YAML → template → `chezmoi apply`
- Easy overrides for new hosts; no more editing `.src.ini`
- `chezmoi diff`/`apply` works reliably (no double ownership)
- Lower coupling to hardware; Windows/Fedora migrations now feasible

### Negative
- Requires initial effort to convert existing modify-managed files to templates
- `.chezmoidata` must stay in sync with actual host settings; needs discipline
- Complex configs (panel geometry) may need richer data structures

---

## Implementation Plan
1. **Inventory:** list all files still using modify scripts; prioritize highest-value configs (Plasma, terminal, app settings).
2. **Data modelling:** extend `.chezmoidata/plasma.yaml` (and similar files) with any new keys template needs.
3. **Template creation:** convert `.src.ini` into `.tmpl` referencing the data; keep `.src.ini` only for historical diff/backup.
4. **Automation updates:** remove converted files from `ansible/group_vars/all/plasma_configs.yml` and navi cheats so the refresh playbook skips them.
5. **Documentation:** update mapping tables + panel references whenever a config switches to templated form.
6. **Verification:** run `chezmoi diff/apply` after each conversion; restart Plasma or affected apps to confirm behavior.

---

## Status & Follow-up
- ✅ Applied for Plasma configs (plasma-org…, plasmashellrc, kglobalshortcutsrc, krunnerrc, ksmserverrc, plasmanotifyrc, plasma_workspace.notifyrc, powerdevilrc, plasmarc, kscreenlockerrc, locale/holiday files).
- ⏳ Remaining: legacy app configs (Dolphin, Konsole, Okular, Kate) still use modify-manager; plan separate conversion.
- Review ADR when Fedora migration begins or if a config cannot be reasonably templated (document exception + reason).
