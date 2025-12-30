# Design: Plasma Wallpaper & Launcher Templating + Modify Automation (2025-12-19)

**Status:** Draft for implementation
**Author:** mitsio (Codex helper)
**Scope:** KDE Plasma configs tracked via chezmoi (panels, wallpapers, IconTasks, lock/desktop backgrounds) and supporting automation for `chezmoi_modify_manager` refreshes.

---

## 1. Background & Constraints

- Phase 4 of the Plasma migration plan (docs/plans/2025-12-14-plasma-migration-to-chezmoi-plan.md) requires templating host-specific data (wallpapers, launcher order) and building automation for repeated `chezmoi_modify_manager --smart-add` runs before commits.
- Current modify scripts (`private_dot_config/modify_plasma-org...`, `modify_plasmashellrc`, etc.) only ignore volatile keys (wallpaper image paths, geometry). Host-specific paths continue to live in `.src.ini` and break reproducibility.
- `_staging` was retired; all documentation and config decisions must stay under `docs/` and tracked repos.
- Future Fedora/WSL targets must reuse the same chezmoi data with minimal branching.

### Design goals

1. Declaratively define wallpapers, lockscreen backgrounds, IconTasks launchers, and future per-host overrides via `.chezmoidata`.
2. Minimize modify-script complexity: prefer templated `.src.ini.tmpl` when the entire section contains host data; rely on `chezmoi_modify_manager` only for volatile subsections.
3. Provide a single automation entrypoint (Ansible playbook + navi cheats) to re-ingest live Plasma configs before committing.
4. Document testing + rollback strategy so future sessions can validate on VM/Fedora.

### Non-goals

- Rewriting plasma-manager or removing modify scripts entirely.
- Changing panel layouts beyond templating dynamic values.
- Solving CK GPU optimization or other unrelated tasks.

---

## 2. Data Model & Templates

### 2.1 `.chezmoidata/plasma.yaml`

Create a new YAML file with structure:

```yaml
plasma:
  defaults:
    wallpaper_main: "Pictures/wallpapers/current-firewatch-5k.jpg"
    wallpaper_secondary: "Pictures/wallpapers/workspace-portrait.png"
    lockscreen_wallpaper: "Pictures/wallpapers/anime-pattern-wallpaper.jpg"
    icon_tasks:
      - "applications:systemsettings.desktop"
      - "preferred://filemanager"
      - ... (full order)
  hosts:
    shoshin:
      wallpaper_main: "Pictures/wallpapers/shoshin-desktop.jpg"
      lockscreen_wallpaper: "Pictures/wallpapers/anime-pattern-wallpaper.jpg"
    fedora-kinoite:
      wallpaper_main: "Pictures/wallpapers/fedora-default.png"
```

Rules:
- Paths stored relative to `$HOME`; template expands with `{{ joinPath .chezmoi.homeDir value }}`.
- `defaults` apply to all hosts unless overridden.
- Use additional keys for fonts, panel thickness, etc. as needed.

### 2.2 Template targets

| File | Current state | Target state |
|------|---------------|--------------|
| `plasmashellrc.src.ini` | captured raw | convert to `.tmpl`, inject wallpaper references per containment, but keep modify hook for volatile items. |
| `plasma-org.kde.plasma.desktop-appletsrc.src.ini` | captured raw | convert to `.tmpl` for wallpaper `Image`, IconTasks `launchers`, other host-specific keys; keep modify script for geometry + wallpaper fallback removal. |
| `kscreenlockerrc.src.ini` | contains `/home/mitso/...` paths | convert to template referencing `.chezmoidata`. |
| `plasmashellrc` modify script | currently `source auto` | extend to `ignore` only geometry, allow templated wallpaper content to remain. |

Template pattern example (IconTasks):

```ini
launchers={{ join "," (pluck "icon_tasks" .plasma.hostConfig) }}
```

Wallpaper example:

```ini
Image=file://{{ joinPath .chezmoi.homeDir .plasma.hostConfig.wallpaper_main }}
SlidePaths={{ range $path := .plasma.hostConfig.wallpaper_set }}file://{{ joinPath $.chezmoi.homeDir $path }},{{ end }}
```

Helper template partial (optional): create `.chezmoitemplates/plasma_helpers.tmpl` to expose:

```gotemplate
{{- define "plasmaHostConfig" -}}
{{- $host := .chezmoi.hostname -}}
{{- merge .plasma.defaults (index .plasma.hosts $host | default dict) -}}
{{- end -}}
```

Use `{{ $plasma := template "plasmaHostConfig" . }}` inside each template for clarity.

### 2.3 Modify script adjustments

- `modify_plasma-org...` keeps `ignore regex` rules for geometry but removes wallpaper ignores once templated.
- Add `transform` rules if enumeration (IconTasks) needs deterministic ordering.
- Document all regs in comments referencing Phase-4 plan.

---

## 3. Automation Plan (`chezmoi_modify_manager` refresh)

### 3.1 Ansible playbook

`ansible/playbooks/chezmoi-modify-refresh.yml`

Key tasks:
1. Load config list from `group_vars/all/plasma_configs.yml` (single source list of config paths).
2. Loop with `command: chezmoi_modify_manager --smart-add {{ item.path }}` and register change state.
3. Optional `changed_when: "'No changes' not in result.stderr"` for idempotence.
4. Summary task prints changed files + reminder to run `chezmoi diff`.
5. Tag tasks (`plasmakit`, `modify`) for selective runs.

### 3.2 Integration

- Provide `make plasma-refresh` wrapper calling `ansible-playbook -i inventories/hosts localhost, ...`.
- Optionally add a home-manager activation DAG hook to remind user when manual run is required (skip automatic invocation to avoid Plasma writes during rebuilds).

### 3.3 Cheatsheets / UX

- Extend `dotfiles/dot_local/share/navi/cheats/chezmoi-modify-plasma.cheat` with entries:
  1. `navi` command to run the playbook.
  2. Grouped `chezmoi_modify_manager` commands (panels, workspace, power) referencing `plasma_configs.yml` for manual control.
- Add references in `docs/dotfiles/plasma/panel-config-reference.md` to keep human workflow in sync.

---

## 4. Validation & Testing

1. **Unit validation:** After templating, run `chezmoi apply --dry-run --verbose ~/.config/plasma-org...` and ensure output reproduces live files.
2. **Plasma restart test:** `kquitapp6 plasmashell && kstart plasmashell` after each major change; confirm panels intact.
3. **System reboot / VM:** Schedule a VM test once templating + automation implemented, per Phase-4 plan.
4. **Fedora readiness:** Update `docs/dotfiles/plasma/fedora-migration.md` (new doc) summarizing manual steps/outstanding gaps.
5. **CI-ish check:** `ansible-playbooks/chezmoi-modify-refresh.yml --check` to confirm list coverage.

---

## 5. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Template mistakes break panels | High | Keep `.src.ini` backups; use `chezmoi apply --dry-run` and manual diff before apply. |
| Host-specific data missing for new machine | Medium | Document defaults and add `TODO` to update `.chezmoidata/plasma.yaml` whenever new host added. |
| Automation accidentally runs during Plasma session and overwrites active config | Medium | Keep playbook manual; prompt user to close Plasma config UIs first (doc + task message). |
| Data drift (IconTasks reorder) still occurs | Low | Add `transform` rule enforcing `launchers` sorted from data file. |

---

## 6. Execution Checklist

1. **Data** – Create `.chezmoidata/plasma.yaml` with defaults + shoshin overrides.
2. **Templates** – Convert `.src.ini` files to `.tmpl` (desktop, lockscreen, panels) referencing data + helper template.
3. **Modify scripts** – Update to remove wallpaper ignores, document rules.
4. **Automation** – Create Ansible play + `group_vars` + Make/navi helpers.
5. **Docs** – Update `panel-config-reference.md`, `Phase 4 plan`, `docs/TODO.md`, session summary.
6. **Testing** – Dry-run apply, restart plasmashell, schedule VM regression.

---

*End of design draft. Implementation can now proceed following sections 6 & 3.*
