# ADR-015: Hardware Data Layer for Templated Dotfiles

**Status:** Accepted  
**Date:** 2025-12-22  
**Deciders:** Mitsos + Codex  

---

## Context

ADR-013 mandated that dotfiles must be host-agnostic, yet several KDE/Plasma configs (e.g., `kwinrc`, `kwinoutputconfig.json`) still embed monitor scale, orientation, and GPU-specific hints. Without a portable data layer we end up hardcoding monitor geometry inside templates, forcing manual edits whenever shoshin migrates to Fedora Atomic, the WSL host `gyakusatsu`, or the Windows laptop `system-laptop01`.

## Decision

Create a dedicated `.chezmoidata/hardware.yaml` file that captures immutable hardware facts per host (GPU model, monitor resolution/scale, connector IDs). Templates access this structure via `.hardware.hosts.<hostname>` instead of embedding literals.

- `dotfiles/.chezmoidata/hardware.yaml` now stores:
  - Schema metadata.
  - Default monitor/gpu entries.
  - Host overrides (starting with shoshin’s LG 3440×1440 display at scale 1.05).
- Templates consume the data through helpers. Example: `private_dot_config/kwinrc.tmpl` reads the primary monitor scale and applies it to the `[Xwayland]` section.

Future monitor-specific configs (`kwinoutputconfig`, `kscreenlockerrc`, potential SDDM themes) will follow the same pattern so new hosts only require YAML updates, not template rewrites.

## Consequences

**Positive**
- Host onboarding shrinks to editing a single data file (`hardware.yaml`), keeping templates clean.
- Monitor scale/orientation lives in version-controlled YAML, making hardware swaps auditable.
- Reduces risk of applying shoshin-specific geometry on laptops/WSL where it would break Plasma.

**Negative**
- Requires discipline to keep `.chezmoidata/hardware.yaml` accurate (EDID hashes, connectors).
- Templates must handle missing data gracefully (defaults to 1.0 scale, etc.).

## Implementation Notes

1. `hardware.yaml` structure:
   ```yaml
   hardware:
     schema_version: 1
     defaults:
       monitors: []
     hosts:
       shoshin:
         gpu: { vendor: "NVIDIA", model: "GeForce GTX 960" }
         monitors:
           - name: "LG UltraWide (EDID GSM 30626)"
             connector: "HDMI-A-1"
             resolution: "3440x1440"
             refresh_hz: 60
             scale: 1.05
   ```
2. Templates fetch data via:
   ```go
   {{- $hardwareHost := index (index .hardware "hosts") .chezmoi.hostname | default dict -}}
   ```
3. If the requested monitor entry is absent, templates fall back to safe defaults (`Scale=1.0`).
4. Add new hosts (`gyakusatsu`, `system-laptop01`) by appending entries; no template edits needed.

## Related Work
- ADR-013 – Host-agnostic dotfiles requirement.
- ADR-014 – Portable configuration pipeline (chezmoi + Home-Manager).
