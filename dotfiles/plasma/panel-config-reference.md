# Plasma Panel & Applet Configuration Reference

**Last updated:** 2025-12-20

## Purpose
Keep a single source describing how Plasma panel/desktop state is captured under chezmoi, which pieces are templated via `.chezmoidata/plasma.yaml`, and how to refresh the snapshots with the new automation helpers.

## Captured Assets

### Snapshot files (chezmoi_modify_manager)
- `dotfiles/private_dot_config/plasmashellrc.src.ini` – Raw panel metadata imported from `~/.config/plasmashellrc` (panels 2, 28, 32, 56, 62). Geometry is still read from this snapshot so we can diff panel moves before applying templates.

### Templates backed by `.chezmoidata/plasma.yaml`
- `dotfiles/.chezmoidata/plasma.yaml` – Host-aware data model for wallpapers, lockscreen preview, IconTasks launcher order, locale defaults, power/notification settings, and holiday regions.
- `dotfiles/private_dot_config/plasma-org.kde.plasma.desktop-appletsrc.tmpl` – Renders wallpapers (desktop + folderview) and IconTasks launchers from the YAML; modify-manager now only covers volatile geometry.
- `dotfiles/private_dot_config/kscreenlockerrc.tmpl`
- `dotfiles/private_dot_config/plasma-localerc.tmpl`
- `dotfiles/private_dot_config/plasma_calendar_holiday_regions.tmpl`
- `dotfiles/private_dot_config/plasmarc.tmpl`
- `dotfiles/private_dot_config/powerdevilrc.tmpl`
- `dotfiles/private_dot_config/plasmanotifyrc.tmpl`
- `dotfiles/private_dot_config/krunnerrc.tmpl`
- `dotfiles/private_dot_config/plasma_workspace.notifyrc.tmpl`
- `dotfiles/private_dot_config/ksmserverrc.tmpl`
- `dotfiles/private_dot_config/kglobalshortcutsrc.tmpl`

### Automation helpers
- `ansible/playbooks/chezmoi-modify-refresh.yml` + `ansible/group_vars/all/plasma_configs.yml` drive the refresh pipeline.
- `make plasma-refresh` (and the corresponding navi cheat) wrap the playbook so all modify-managed files are captured in one command before commits.

## Filtering Strategy
- `private_dot_config/modify_plasmashellrc` currently only calls `source auto`; no ignores are active so we retain all geometry until we have finer-grained sections.
- `private_dot_config/modify_plasma-org.kde.plasma.desktop-appletsrc` ignores only high-churn keys (`Image`, `ItemGeometries*`, `positions*`, `activityId`, `SlidePaths`) so YAML-driven wallpapers/IconTasks can be applied while live geometry stays intact.

## Workflow
1. Capture live state whenever you are happy with the layout:
   ```bash
   chezmoi re-add ~/.config/plasmashellrc
   ```
   (IconTasks/wallpaper data flow through `.chezmoidata/plasma.yaml`, so `chezmoi add` is only needed when geometry or new applets appear.)
2. Run the automation to refresh every modify-managed file:
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
   make plasma-refresh
   ```
3. Inspect `chezmoi diff ~/.config/plasmashellrc ~/.config/plasma-org.kde.plasma.desktop-appletsrc` and merge unexpected changes with VSCodium/delta if required.
4. Apply via `chezmoi apply` and, for risky changes, restart the shell: `kquitapp6 plasmashell && kstart6 plasmashell`.

## Current Layout Notes (text only)
- **Panel 56 (primary bottom panel)** – Floating, thickness ≈42–44px, order: Kickoff (57) → Pager (89) → IconTasks (59) → System Tray (61) → Kicker quick menu (87) → Show Desktop (74) → System Monitor (83) → Device Notifier (84) → Digital Clock (73). IconTasks launchers mirror `plasma.yaml`.
- **Digital clock** – JetBrains Mono SemiBold, custom format `\sdddd dd/MM/yyyy`, seconds visible, week numbers enabled.
- **Containments 1 & 26** – Desktop folder views with icon size 3.
- **Containment 27** – Folder containment with Digital Clock (ID 55), wallpaper plugin `org.kde.image`.
- **Containment 62** – System tray hosting keyboard layout, volume, KDE Connect, etc.

Update this section whenever you change panel ordering so the declarative layouts can be re-applied without screenshots.

## Next Improvements
1. Expand `.chezmoidata/plasma.yaml` with additional host overrides (fonts, per-activity wallpapers) before Fedora/WSL adoption.
2. Template remaining wallpaper paths and launcher lists for secondary panels.
3. Schedule VM/fresh-user dry runs once the templated workflow stabilises.
