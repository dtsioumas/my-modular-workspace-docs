# Kitty Terminal: Tab Bar Position & Per-Window Status Bars

**Research Date:** 2025-12-07
**Author:** Mitsio (with Claude assistance)
**Status:** COMPLETE
**Confidence:** 0.90 (High - verified with official sources)

---

## Research Question

> Can kitty terminal have:
> 1. Tab bar at the TOP of the window
> 2. Per-window/per-pane status bars at the BOTTOM

---

## Executive Summary

| Feature | Native Support | Solution |
|---------|---------------|----------|
| Tab bar at TOP | **YES** | `tab_bar_edge top` |
| Tab bar at BOTTOM | **YES** | `tab_bar_edge bottom` (default) |
| Per-window status bar | **NO** | Workaround: 1-line window + remote control |
| Per-tab status bar | **NO** | Use `active_tab_title_template` |
| Status bar at bottom | **Partial** | Use terminal multiplexer (Zellij/tmux) |

**Best Solution:** Kitty tab bar at TOP + Zellij zjstatus at BOTTOM

---

## Research Sources

### 1. GitHub Issue #3101 - Per-Window Statusbar API
- **URL:** https://github.com/kovidgoyal/kitty/issues/3101
- **Date:** November 14, 2020
- **Status:** Closed

**Key Exchange:**

User asked:
> "I'd like for there to be a way to render a string of text at the bottom of a given terminal window to provide per-window stats"

**kovidgoyal (kitty author) response:**
> "See https://sw.kovidgoyal.net/kitty/remote-control.html
> But for an actual docked status bar it would need #2391"

**Clarification from user:**
> "So the idea would be to implement a status bar as a 1 character high window and populate it with content via send-text?"

**kovidgoyal confirmed:** "yes."

---

### 2. GitHub Discussion #9234 - Per-Tab Status Bar
- **URL:** https://github.com/kovidgoyal/kitty/discussions/9234
- **Date:** November 20, 2025 (very recent)
- **Status:** Active discussion

**User requested:** iTerm2-style status bar showing CWD, git info, Python version

**kovidgoyal response:**
> "Not sure what you are asking. If you find the tab title becomes too long you will find that the custom status bar is even longer since it occupies an entire row, regardless of the size of its contents, unlike tab titles."

**Follow-up suggestion:**
> "So use `active_tab_title_template` in kitty.conf to make your active tab longer than all the rest."

---

### 3. GitHub Issue #2391 - Docked Status Bar Feature Request
- **Referenced in #3101**
- **Status:** Open feature request for native status bar support
- **Not implemented as of December 2025**

---

## Tab Bar Configuration

### Position Options

```conf
# Tab bar at TOP of window
tab_bar_edge top

# Tab bar at BOTTOM of window (default)
tab_bar_edge bottom
```

### Style Options

```conf
# Available styles
tab_bar_style fade
tab_bar_style slant
tab_bar_style separator
tab_bar_style powerline
tab_bar_style custom  # Use custom Python tab_bar.py
```

### Title Templates

```conf
# Basic title for all tabs
tab_title_template "{index}: {title[:20]}"

# Detailed title for ACTIVE tab only (recommended for status-like info)
active_tab_title_template "[{layout_name}] {index}: {title} | {num_windows}w"
```

**Available Variables:**
- `{title}` - Window title
- `{index}` - Tab number (1-based)
- `{layout_name}` - Current layout name
- `{num_windows}` - Number of windows in tab
- `{num_window_groups}` - Number of window groups
- `{tab.active_wd}` - Working directory of active window (shell integration required)
- `{fmt.fg.COLOR}` / `{fmt.bg.COLOR}` - Color formatting

---

## Per-Window Status Bar Solutions

### Solution 1: 1-Character High Window (Workaround)

**Concept:** Create a dedicated 1-line window at the bottom that displays status info

**Implementation:**
```bash
# Create status bar window
kitty @ launch --location=hsplit --cwd=current --title=status \
  bash -c 'while true; do
    echo -ne "\r\033[K$(date +%H:%M) | $(git branch --show-current 2>/dev/null || echo "no-git") | $(pwd | sed "s|$HOME|~|")"
    sleep 1
  done'

# Resize to minimum height
kitty @ resize-window --match title:status --axis=vertical --increment=-100
```

**Limitations:**
- Takes up a real window slot
- Manual setup for each tab
- Consumes resources for each status window
- Not elegant or integrated
- Breaks with window management operations

---

### Solution 2: Zellij Integration (Recommended)

**Architecture:**
```
┌─────────────────────────────────────────┐
│ [Tab 1] [Tab 2] [Tab 3]   ← Kitty tab bar (TOP)
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────┬─────────────┐          │
│  │  Pane 1     │  Pane 2     │  ← Zellij panes
│  │             │             │
│  └─────────────┴─────────────┘
│                                         │
├─────────────────────────────────────────┤
│ mode: normal | git:main | ~/path | 15:30│
│ ↑ Zellij zjstatus (BOTTOM)              │
└─────────────────────────────────────────┘
```

**zjstatus Features:**
- Git branch display
- Current mode indicator
- Path display
- Time
- Custom widgets
- Catppuccin/Dracula theme support

**Installation:**
```bash
# Download zjstatus plugin
curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm \
  -o ~/.config/zellij/plugins/zjstatus.wasm
```

---

### Solution 3: Custom tab_bar.py (Advanced)

**For:** Advanced users who want system metrics in the tab bar

**How it works:**
- Kitty supports `tab_bar_style custom`
- Custom Python file: `~/.config/kitty/tab_bar.py`
- Can display arbitrary content including system metrics

**Example Structure:**
```python
from kitty.fast_data_types import add_timer, get_options
from kitty.tab_bar import DrawData, ExtraData, TabBarData

def draw_tab(
    draw_data: DrawData,
    screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Custom drawing logic here
    pass
```

**Considerations:**
- Requires Python knowledge
- Performance impact (use caching)
- Complexity for maintenance

---

## Comparison of Solutions

| Solution | Complexity | Native | Per-Pane | Maintenance |
|----------|------------|--------|----------|-------------|
| Tab bar at top | Low | Yes | No | Low |
| active_tab_title_template | Low | Yes | No | Low |
| 1-line window workaround | Medium | Partial | Yes | High |
| Zellij + zjstatus | Medium | External | Yes | Medium |
| Custom tab_bar.py | High | Yes | No | High |

**Recommendation:** Zellij + zjstatus for per-pane status bars

---

## Implementation Guide

### Quick Setup (5 minutes)

```conf
# ~/.config/kitty/kitty.conf

# Move tab bar to top
tab_bar_edge top

# Enhanced active tab title (pseudo-status)
active_tab_title_template "{fmt.fg._cba6f7}[{layout_name}]{fmt.fg.tab} {index}: {title}"

# Keep inactive tabs simple
tab_title_template "{index}: {title[:15]}"
```

### Full Setup with Zellij (1-2 hours)

1. **Install Zellij:**
   ```nix
   # home-manager
   home.packages = [ pkgs.zellij ];
   ```

2. **Configure Kitty:**
   ```conf
   tab_bar_edge top
   ```

3. **Configure Zellij with zjstatus:**
   - See `docs/plans/kitty-zellij-phase1-plan.md`

4. **Auto-launch (optional):**
   ```conf
   # In kitty.conf
   shell zellij
   ```

---

## Known Limitations

### What Kitty CANNOT Do Natively

1. **Per-window docked status bar** - No API, requires workarounds
2. **Click handlers on tab bar** - Tab bar mouse events are hardcoded
3. **Multiple status bars** - Only one tab bar exists
4. **Right-click context menu** - Rejected by design (keyboard-first philosophy)

### Design Philosophy

From kovidgoyal:
> "Kitty is for keyboard-first power users. No power user is going to use a context menu."

This explains why many GUI-like features (context menus, clickable status bars) are not prioritized.

---

## Related Resources

### Official Documentation
- Tab Bar Config: https://sw.kovidgoyal.net/kitty/conf/#tab-bar
- Remote Control: https://sw.kovidgoyal.net/kitty/remote-control/
- Custom Kittens: https://sw.kovidgoyal.net/kitty/kittens/custom/

### Third-Party Tools
- zjstatus: https://github.com/dj95/zjstatus
- pawbar: https://github.com/codelif/pawbar
- Zellij: https://zellij.dev/

### Project Documentation
- Zellij Plan: `docs/plans/kitty-zellij-phase1-plan.md`
- Advanced Status Bar Plan: `docs/plans/kitty-advanced-statusbar-plan.md`
- Kitty Guide: `docs/tools/kitty.md`

---

## Conclusion

**For tab bar at TOP:** Simply add `tab_bar_edge top` to kitty.conf.

**For per-window status bars:** Use Zellij with zjstatus plugin. Native kitty does not support this, and workarounds are cumbersome.

**Recommended Setup:**
```
Kitty (rendering) → Zellij (multiplexing + status) → Shell
```

This provides:
- Tab bar at top (kitty)
- Status bar at bottom (zellij/zjstatus)
- Per-pane information
- Session persistence
- Best of both worlds

---

**Last Updated:** 2025-12-07
**Maintained By:** Dimitris Tsioumas (Mitsio)
