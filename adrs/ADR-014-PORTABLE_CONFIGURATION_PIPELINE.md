# ADR-014: Portable Configuration Pipeline via Chezmoi & Home-Manager

**Status:** Proposed  
**Date:** 2025-12-22  
**Deciders:** Dimitris Tsioumas (Mitsos), Codex  

---

## Context

The workspace targets multiple environments (NixOS on shoshin, WSL/Windows laptop `system-laptop01`, future Fedora Atomic, cloud VMs). Recent migrations showed configuration drift:

- CopyQ themes and shortcuts disappeared after chezmoi apply because template/data didn’t exist.
- VSCodium settings diverged per host; manually syncing JSON caused conflicts.
- KDE Plasma shortcuts, Flameshot bindings, etc. still contained literal host paths/IDs.

Existing ADRs (e.g. ADR-005) explain *where* configs live (chezmoi vs Home-Manager) but not *how* to ensure each config is portable/host-agnostic.

---

## Decision

Establish a two-layer pipeline for every user-level config:

1. **chezmoi Source of Truth**
   - All user configs are stored as templates (`*.tmpl`) with data in `.chezmoidata/*.yaml`.
   - No literal hostnames, absolute paths or GPU IDs in templates; host-specific overrides live under `hosts.<hostname>`.
   - Any binary assets (themes, icons) reside in `private_dot_*` and are referenced via template variables so the same file deploys anywhere.

2. **Home-Manager Glue**
   - Home-Manager manages package installation, services, and activation scripts that deploy/call the chezmoi-managed configs.
   - When a config needs helper tooling (e.g. VSCode extensions, systemd units), Home-Manager sets up the tooling, but the actual app settings remain in chezmoi templates.

Workflow requirements:

- Customize live → `chezmoi re-add` → convert to template + data → `chezmoi diff/apply` → commit.
- Every config change must include `.chezmoidata` entries for each current host (`shoshin`, `gyakusatsu`, `system-laptop01`) plus reasonable defaults for future hosts.
- Home-Manager modules must call chezmoi outputs (e.g. activation scripts `runCommand "chezmoi apply"` for certain files when needed) instead of duplicating settings there.

---

## Consequences

### Positive
- Configs survive host migrations automatically.
- New hosts only need data entries; templates remain untouched.
- Eliminates double ownership (no more template + modify scripts).
- Easier reviews: `chezmoi diff` shows intent rather than host noise.

### Negative
- Adds overhead: every customization requires updating templates + data.
- `.chezmoidata` grows and must be kept tidy/documented.
- Requires discipline (you must follow the workflow for every tweak).

---

## Implementation Notes

1. **Data files**
   - `dotfiles/.chezmoidata/{plasma,apps}.yaml` define defaults and `hosts.<name>`.
   - When a new host appears, add an entry before running `chezmoi apply`.

2. **Templates**
   - All configs live in `private_dot_config/**`. Literal values replaced with `{{ ... }}` expressions referencing `.chezmoidata`.
   - Assets (themes, wallpapers) live under `private_dot_config/.../themes` or similar.

3. **Workflow**
   ```
   # Customize live config
   chezmoi re-add ~/.config/myapp/config.ini
   $EDITOR ~/.local/share/chezmoi/private_dot_config/myapp/config.ini.tmpl
   $EDITOR ~/.local/share/chezmoi/.chezmoidata/apps.yaml   # add overrides
   chezmoi diff
   chezmoi apply --keep-going
   chezmoi cd && git add ... && git commit
   ```

4. **Documentation**
   - Update `docs/chezmoi/DOTFILES_INVENTORY.md` whenever a template/data pair is added.
   - Reference this ADR in future plans (Plasma templating, CopyQ, VSCodium).

---

## Status & Next Steps

- CopyQ, Flameshot, VSCodium already follow the new pattern.
- KDE Plasma data files need further host entries (monitors, activities) per this ADR.
- Future tasks (Activities layout, additional apps) must conform before merging.

--- 

**Related ADRs:**  
ADR-005 (Chezmoi Migration Criteria), ADR-007 (Autostart via Home-Manager), ADR-012 (Chezmoi Template Source of Truth).
