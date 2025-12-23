# ADR-012: WSL GUI Integration (Fedora Kinoite WSL2 + KDE Plasma via X410)

**Status:** Proposed  
**Date:** 2025-12-23  
**Author:** Mitsos

---

## Context

The corporate workstation is a Windows host (`eyeonix-laptop` / hostname `system-laptop01`). The modular-workspace goal is:

- **WSL-first**: all daily work (CLI + GUI) happens inside WSL2 on the Linux filesystem.
- The Windows host is kept minimal and acts as a launcher and recovery fallback.

The project docs already state that WSLg is not suitable for a full KDE Plasma desktop and that an external X server on Windows is mandatory for this design.

We need a formal architectural decision that locks the primary GUI approach, defines acceptable fallbacks, and clarifies what is in-scope for Windows-host tooling.

## Decision

### Primary GUI path (selected)

1. **WSL2 distro:** Fedora-based WSL2 distro, targeting an Atomic variant (Kinoite) where feasible.
2. **GUI mechanism:** Run a **full KDE Plasma session** inside WSL using **X11**, rendered on Windows via **X410** (X server on Windows).
3. **Scope rule:**
   - All GUI apps should run from WSL and display via X410.
   - The Windows host may have only a minimal set of fallback tools for recovery and emergency productivity.

### Supported fallbacks

- **Fallback A (X server):** VcXsrv (or similar) if X410 is unavailable.
- **Fallback B (no full desktop):** WSLg can be used for *individual* GUI apps, but **not** as the primary strategy for a full KDE desktop.

## Alternatives Considered

1. **WSLg as primary for full desktop** — rejected (good for individual apps, but not a complete KDE desktop for our design).
2. **XRDP into WSL** — possible, but not primary (extra moving parts, different UX; keep as a documented option if X11/X410 becomes a blocker).
3. **Native Windows GUI apps as primary** — rejected (breaks WSL-first + reproducible Linux stack).
4. **Full VM (Hyper-V/VirtualBox) as primary** — rejected (heavier than WSL-first; still useful for CI testing).

## Consequences

### Positive

- Consistent “Linux-first” UX on Windows: same apps, same dotfiles, same package set.
- Keeps most configuration under Linux tooling (home-manager + chezmoi) and reduces Windows drift.
- Clear separation: Windows host is a thin shell; WSL is the actual workspace.

### Negative / Risks

- X11 + external X server adds configuration and potential fragility (DISPLAY, clipboard, multi-monitor quirks).
- X410 is paid software.
- We must maintain launch scripts/services and document recovery paths.

## Implementation Notes

### Required configuration points

- WSL should support `systemd` when needed via `/etc/wsl.conf`:

  ```ini
  [boot]
  systemd=true
  ```

- Provide a canonical Windows launcher (PowerShell) that:
  - ensures X410 is running,
  - starts KDE Plasma inside WSL (`startplasma-x11`),
  - sets/exports `DISPLAY` and any other required environment variables.

### Abstraction hooks

- Do not hardcode `~/.MyHome` in GUI launch logic.
- Prefer variables for path roots and profile selection (to be formalized in ADR-Profiles and ADR-StorageBackends), e.g.:
  - `MW_PROFILE`
  - `MW_SHARED_HOME`

## Acceptance Criteria

A “good” implementation satisfies:

1. From Windows: one-click start of KDE Plasma (or a single command).
2. KDE desktop is usable for at least: Konsole, Dolphin, VSCodium (Linux build), browser (Linux build).
3. Clipboard works between Windows and WSL GUI apps.
4. Multi-monitor works well enough for daily use (document known limitations).
5. Recovery playbook exists (how to use fallback tools and restore WSL config).

## References

- `docs/windows-base/ARCHITECTURE.md`
- `docs/windows-base/` (WSL2 + X410 + KDE Plasma setup notes)
- ADR-005 (chezmoi usage)
- ADR-006 (home-manager autostart)
- ADR-009 (two-layer approach: home-manager + chezmoi)
