# Per-Pane Bottom Status Bar Research

**Research Date:** 2025-12-08
**Author:** Mitsio (with Claude assistance)
**Status:** COMPLETE
**Confidence:** 0.92 (High - verified with official sources and GitHub issues)

---

## Research Question

> Can I have a status bar at the BOTTOM of each split/pane in kitty terminal?

---

## Executive Summary

| Solution | Per-Pane Support | Bottom Position | Native |
|----------|------------------|-----------------|--------|
| **Kitty native** | ❌ No | ❌ No | - |
| **Zellij pane_frames** | ✅ Yes | ❌ TOP only | Yes |
| **tmux pane-border-status** | ✅ Yes | ✅ Yes | Yes |
| **Kitty 1-line window** | ⚠️ Workaround | ✅ Yes | Partial |
| **Shell prompt (PS1)** | ✅ Yes | ✅ Yes (after output) | Yes |

**Verdict:** For native per-pane BOTTOM status bars, **tmux is the only solution** that supports this out of the box.

---

## Detailed Findings

### 1. Kitty Terminal

**Status:** NOT SUPPORTED

Kitty does not have native support for per-window/per-split status bars. This has been confirmed by the kitty author (kovidgoyal) in multiple GitHub issues:

- **Issue #3101:** "For an actual docked status bar it would need #2391"
- **Issue #2391:** Open feature request, not implemented

**Workaround:** Create a 1-character high window via remote control:
```bash
kitty @ launch --location=hsplit --title=status \
  bash -c 'while true; do echo -ne "\r$(date +%H:%M) | $(pwd)"; sleep 1; done'
```

**Limitations:**
- Takes up a real window slot
- Manual setup required per pane
- Complex to maintain
- Not elegant or integrated

---

### 2. Zellij Terminal Multiplexer

**Status:** TOP ONLY (not configurable)

Zellij has `pane_frames` which shows a frame around each pane with a title, but:
- Frame title appears at the **TOP** of each pane
- **Cannot be configured** to appear at the bottom
- This is a known limitation

**Current Behavior:**
```
┌─ Pane: bash ─────────────┬─ Pane: htop ───────────┐
│                          │                         │  ← Title at TOP
│  terminal content        │   htop content          │
│                          │                         │
└──────────────────────────┴─────────────────────────┘
                                      ↑ No status at bottom
```

**Open Feature Requests:**
- **GitHub Issue #680** (Aug 2021): "Configure Pane Frames" - Still OPEN
  - URL: https://github.com/zellij-org/zellij/issues/680
  - Requesting ability to configure frame position, content, style

- **GitHub Issue #4110** (Mar 2025): "Allow setting content_offset per direction"
  - URL: https://github.com/zellij-org/zellij/issues/4110
  - Requesting per-direction frame configuration

**Configuration (current):**
```kdl
// config.kdl
pane_frames true  // Shows frame with title at TOP

// Advanced configuration (ui block)
ui {
    pane_frames {
        hide_session_name true
    }
}
```

---

### 3. tmux - RECOMMENDED SOLUTION

**Status:** FULLY SUPPORTED ✅

tmux natively supports per-pane status bars at either TOP or BOTTOM position via the `pane-border-status` option.

**Configuration:**
```bash
# In ~/.tmux.conf
set -g pane-border-status bottom
set -g pane-border-format "#{pane_index} #{pane_current_command} #{pane_current_path}"
```

**Result:**
```
┌──────────────────────────┬─────────────────────────┐
│                          │                         │
│  terminal content        │   htop content          │
│                          │                         │
├─ 0 bash ~/MySpaces ──────┼─ 1 htop ~/MySpaces ─────┤
│                          │                         │  ↑ Status at BOTTOM!
└──────────────────────────┴─────────────────────────┘
```

**Available Variables for pane-border-format:**
- `#{pane_index}` - Pane number
- `#{pane_current_command}` - Running command
- `#{pane_current_path}` - Current directory
- `#{pane_pid}` - Process ID
- `#{pane_title}` - Pane title
- `#{pane_width}` / `#{pane_height}` - Dimensions
- Custom scripts via `#(command)`

**Advantages of tmux:**
- Native per-pane status at TOP or BOTTOM
- Highly customizable format
- Can show git branch, time, custom info
- Session persistence (like zellij)
- Mature, stable, well-documented
- Works with any terminal (including kitty)

---

## Comparison: Zellij vs tmux

| Feature | Zellij | tmux |
|---------|--------|------|
| Per-pane status bar | TOP only | TOP or BOTTOM |
| Status bar customization | Limited | Extensive |
| Modern UI | Yes | Classic |
| Learning curve | Lower | Higher |
| Session persistence | Yes | Yes |
| Plugin ecosystem | Growing | Mature |
| Configuration syntax | KDL | Custom |
| Floating panes | Yes | Yes (v3.3+) |

---

## Recommended Solution: tmux

For users who need **per-pane BOTTOM status bars**, tmux is the recommended solution.

### Quick Setup

**1. Install tmux (via home-manager):**
```nix
# home-manager/tmux.nix
{ config, pkgs, ... }:
{
    programs.tmux = {
        enable = true;
        terminal = "screen-256color";
        extraConfig = ''
            # Per-pane status bar at BOTTOM
            set -g pane-border-status bottom
            set -g pane-border-format " #{pane_index} #{pane_current_command} "

            # Catppuccin-style colors
            set -g pane-border-style "fg=#6c7086"
            set -g pane-active-border-style "fg=#cba6f7"

            # Mouse support
            set -g mouse on
        '';
    };
}
```

**2. Basic tmux.conf for testing:**
```bash
# ~/.tmux.conf
set -g pane-border-status bottom
set -g pane-border-format " #[fg=green]#{pane_index}#[default] #{pane_current_command} #[fg=blue]#{pane_current_path}#[default] "
set -g pane-border-style "fg=colour238"
set -g pane-active-border-style "fg=colour141"
set -g mouse on
```

**3. Test it:**
```bash
tmux
# Press Ctrl+b % to split vertically
# Press Ctrl+b " to split horizontally
# Each pane shows status at BOTTOM
```

---

## Architecture Options

### Option A: Kitty + Zellij (Current)
```
┌────────────────────────────────────────────┐
│ [Tab 1] [Tab 2]              ← Kitty tabs  │
├────────────────────────────────────────────┤
│ ┌─ bash ──────┬─ htop ──────┐              │
│ │             │             │ ← Zellij     │
│ │             │             │   pane_frames│
│ └─────────────┴─────────────┘   (TOP only) │
├────────────────────────────────────────────┤
│ zjstatus: CPU MEM SWAP TIME  ← Global bar  │
└────────────────────────────────────────────┘
```
**Limitation:** No per-pane BOTTOM status

### Option B: Kitty + tmux (Recommended for per-pane bottom)
```
┌────────────────────────────────────────────┐
│ [Tab 1] [Tab 2]              ← Kitty tabs  │
├────────────────────────────────────────────┤
│ ┌─────────────┬─────────────┐              │
│ │             │             │              │
│ │  pane 1     │  pane 2     │              │
│ │             │             │              │
│ ├─ 0 bash ────┼─ 1 htop ────┤ ← tmux       │
│ │             │             │   per-pane   │
│ │             │             │   BOTTOM!    │
│ └─────────────┴─────────────┘              │
├────────────────────────────────────────────┤
│ tmux status: session info    ← Global bar  │
└────────────────────────────────────────────┘
```
**Benefit:** Per-pane status at BOTTOM

### Option C: Hybrid (Kitty tabs + tmux panes)
- Use Kitty for OS-level tabs and rendering
- Use tmux for pane management with per-pane bottom status
- Best of both worlds

---

## Migration Path: Zellij → tmux

If you decide to switch from Zellij to tmux for this feature:

### Phase 1: Install & Configure tmux
```bash
# Add to home-manager
programs.tmux.enable = true;
```

### Phase 2: Learn Key Differences
| Action | Zellij | tmux |
|--------|--------|------|
| Prefix key | Ctrl+g (modes) | Ctrl+b |
| Split horizontal | Ctrl+p, d | Ctrl+b, " |
| Split vertical | Ctrl+p, r | Ctrl+b, % |
| Navigate panes | Ctrl+p, arrows | Ctrl+b, arrows |
| New tab | Ctrl+t, n | Ctrl+b, c |
| Detach | Ctrl+o, d | Ctrl+b, d |

### Phase 3: Create Equivalent Layouts
tmux has session/window/pane hierarchy similar to zellij's session/tab/pane.

### Phase 4: Migrate zjstatus Features
tmux has powerline plugins and status bar customization that can replicate zjstatus functionality.

---

## Conclusion

**For per-pane BOTTOM status bars:**
- **Zellij:** Not supported (TOP only)
- **Kitty:** Not supported natively
- **tmux:** ✅ Fully supported via `pane-border-status bottom`

**Recommendation:** If per-pane bottom status bars are important, consider:
1. Using tmux instead of zellij
2. OR waiting for Zellij Issue #680 to be implemented
3. OR accepting pane titles at TOP (current zellij behavior)

---

## References

### Zellij
- Pane Frames Config: https://zellij.dev/documentation/options.html#pane_frames
- Issue #680 - Configure Pane Frames: https://github.com/zellij-org/zellij/issues/680
- Issue #4110 - Per-direction frames: https://github.com/zellij-org/zellij/issues/4110

### tmux
- pane-border-status: https://man.openbsd.org/tmux#pane-border-status
- tmux Wiki: https://github.com/tmux/tmux/wiki

### Kitty
- Issue #3101 - Per-window statusbar: https://github.com/kovidgoyal/kitty/issues/3101
- Issue #2391 - Docked status bar: https://github.com/kovidgoyal/kitty/issues/2391

---

**Last Updated:** 2025-12-08
**Maintained By:** Dimitris Tsioumas (Mitsio)
