# Kitty + Zellij Integration Guide

**Created:** 2025-11-30
**Status:** Active
**Components:** Kitty Terminal + Zellij Multiplexer + zjstatus Plugin

---

## Overview

This integration combines kitty terminal emulator with zellij terminal multiplexer to create a powerful, beautiful terminal workflow.

**Architecture:**
```
Kitty (Rendering Layer)
  └─> Zellij (Multiplexing Layer)
       ├─> zjstatus (Status Bar Plugin)
       ├─> Panes/Tabs (Workspace Management)
       └─> Sessions (Persistence)
```

---

## Components

### 1. Kitty Terminal Emulator

**Role:** GPU-accelerated terminal rendering

**Responsibilities:**
- Font rendering (JetBrains Mono Nerd Font)
- Theme colors (Catppuccin Mocha)
- Transparency and blur effects
- Keyboard/mouse input processing
- Copy/paste clipboard integration

**Configuration:** Managed via chezmoi at `dotfiles/dot_config/kitty/`

### 2. Zellij Terminal Multiplexer

**Role:** Terminal session and workspace management

**Responsibilities:**
- Pane/tab management
- Session persistence (detach/reattach)
- Layout management
- Plugin system (zjstatus)
- Scrollback and search

**Configuration:** Managed via chezmoi at `dotfiles/dot_config/zellij/`

### 3. zjstatus Plugin

**Role:** Beautiful, customizable status bar

**Responsibilities:**
- Display current mode (normal, pane, tab, etc.)
- Show active tabs
- Display session name
- Show date/time (Europe/Athens timezone)
- Provide visual feedback

**Installation:** WASM plugin downloaded to `~/.config/zellij/plugins/zjstatus.wasm`

---

## Integration Benefits

### Why This Combination?

**Kitty Strengths:**
- ✅ Fast GPU rendering
- ✅ Excellent font support (ligatures, Nerd Fonts)
- ✅ Beautiful transparency and blur
- ✅ Powerful keyboard protocol
- ✅ Image display support

**Zellij Strengths:**
- ✅ Session persistence
- ✅ Powerful layouts
- ✅ Modern, intuitive UX
- ✅ Built-in plugin system
- ✅ Better defaults than tmux

**Together:**
- Best-in-class rendering (kitty) + Best-in-class multiplexing (zellij)
- Beautiful theme consistency (Catppuccin everywhere)
- Separate concerns (kitty = display, zellij = logic)
- Can switch terminals later without losing zellij workflows

---

## Workflow

### Starting a Session

**Method 1: Manual (Recommended for testing)**
```bash
# Open kitty
# Then inside kitty:
zellij attach -c default
```

**Method 2: Alias**
```bash
# Add to ~/.bashrc via chezmoi
alias zj="zellij attach -c default"

# Usage:
kitty -e zj
```

**Method 3: Auto-Launch (After confirming workflow)**
```conf
# ~/.config/kitty/startup_session.conf
launch zellij attach -c default
```

Then in `kitty.conf`:
```conf
startup_session startup_session.conf
```

### Day-to-Day Usage

1. **Open kitty** (Super+Enter or from launcher)
2. **Launch zellij** (manually or auto)
3. **Work within zellij:**
   - Create panes: `Ctrl+P, N` (right), `Ctrl+P, D` (down)
   - Navigate panes: `Ctrl+P, H/J/K/L` (vim-style)
   - Create tabs: `Ctrl+T, N`
   - Switch tabs: `Ctrl+T, H/L`
   - Scroll: `Ctrl+S` (enter scroll mode)
4. **Detach** if needed: `Ctrl+O, D`
5. **Reattach** later: `zellij attach default`

### Copy/Paste Workflow

**Inside Kitty (works in zellij too):**
- **Select text** with mouse → auto-copied
- **Right-click** → paste (after enhancement)
- **Ctrl+Shift+C** → copy selection to clipboard
- **Ctrl+Shift+V** → paste from clipboard
- **Middle-click** → paste X11 primary selection

**Inside Zellij Scroll Mode:**
- `Ctrl+S` → enter scroll mode
- `/` → search
- `Space` → start selection (vim-style)
- `Enter` → copy selection
- `Esc` → exit scroll mode

---

## Configuration Files

### Kitty Configuration

**Location:** `dotfiles/dot_config/kitty/`

**Key Files:**
- `kitty.conf` - Main configuration
- `current-theme.conf` - Catppuccin Mocha theme
- `launch.conf` (optional) - Startup session

**Integration-Specific Settings:**
```conf
# Ctrl+Alt+Arrow for window navigation (in case you use kitty windows)
map ctrl+alt+left neighboring_window left
map ctrl+alt+right neighboring_window right
map ctrl+alt+up neighboring_window up
map ctrl+alt+down neighboring_window down

# Right-click paste
mouse_map right press ungrabbed paste_from_clipboard

# Optional: Auto-launch zellij
startup_session launch.conf
```

### Zellij Configuration

**Location:** `dotfiles/dot_config/zellij/`

**Key Files:**
- `config.kdl` - Main configuration
- `layouts/default.kdl` - Default layout
- `plugins/zjstatus.wasm` - Status bar plugin

**Basic config.kdl:**
```kdl
// Theme matching kitty
theme "catppuccin-mocha"

// UI preferences
simplified_ui true
pane_frames false
default_shell "bash"
mouse_mode true

// Load zjstatus plugin
plugins {
    zjstatus location="file:~/.config/zellij/plugins/zjstatus.wasm" {
        format_left  "{mode}#[bg=#1e1e2e] {tabs}"
        format_center "{session}"
        format_right "#[bg=#1e1e2e,fg=#cba6f7] {datetime}"

        mode_normal  "#[bg=#a6e3a1,fg=#1e1e2e,bold] NORMAL "
        tab_active   "#[bg=#cba6f7,fg=#1e1e2e,bold] {index} {name} "

        datetime_format    "%a %d/%m %H:%M"
        datetime_timezone  "Europe/Athens"
    }
}
```

### Home-Manager Integration

**Location:** `home-manager/zellij.nix` (new file) or `home-manager/home.nix`

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];

  # Symlink will be managed by chezmoi
  # home.file.".config/zellij/config.kdl".source = ...;
}
```

---

## Keybinding Reference

### Kitty Shortcuts (Still Available)

**Window Management (if using kitty windows):**
- `Ctrl+Alt+←/→/↑/↓` - Navigate between kitty windows (directional)
- `Ctrl+Shift+]` - Next window
- `Ctrl+Shift+[` - Previous window

**Clipboard:**
- `Ctrl+Shift+C` - Copy
- `Ctrl+Shift+V` - Paste
- `Right-click` - Paste (after enhancement)

**Opacity:**
- `Ctrl+Shift+A, M` - Increase opacity
- `Ctrl+Shift+A, L` - Decrease opacity

**Other:**
- `Ctrl+Shift+F2` - Edit kitty config
- `Ctrl+Shift+F5` - Reload kitty config

### Zellij Shortcuts

**Modes:**
- `Ctrl+G` - Locked mode (disable all keybindings)
- `Ctrl+P` - Pane mode
- `Ctrl+T` - Tab mode
- `Ctrl+N` - Resize mode
- `Ctrl+S` - Scroll mode
- `Ctrl+O` - Session mode
- `Ctrl+H` - Move mode
- `Esc` - Return to normal mode

**Pane Mode (Ctrl+P):**
- `N` - New pane (split right)
- `D` - New pane (split down)
- `X` - Close focused pane
- `F` - Toggle fullscreen
- `H/J/K/L` - Focus pane (left/down/up/right)
- `←/→/↑/↓` - Focus pane (arrow keys)

**Tab Mode (Ctrl+T):**
- `N` - New tab
- `X` - Close current tab
- `H` / `←` - Previous tab
- `L` / `→` - Next tab
- `R` - Rename tab
- `1-9` - Go to tab by number

**Scroll Mode (Ctrl+S):**
- `↑/↓` - Scroll up/down
- `Page Up/Down` - Page up/down
- `U/D` - Half-page up/down
- `/` - Search
- `N` - Next search result
- `Space` - Start selection
- `Enter` - Copy selection
- `Esc` - Exit scroll mode

**Session Mode (Ctrl+O):**
- `D` - Detach session
- `W` - Session manager (list sessions)

**Quick Actions (Normal Mode):**
- `Ctrl+Q` - Quit zellij
- `Alt+N` - New pane (right)
- `Alt+H/J/K/L` - Focus pane

---

## Troubleshooting

### Issue: Zellij doesn't start / errors on launch

**Solution:**
```bash
# Check zellij installation
which zellij
zellij --version

# Check configuration
zellij setup --check

# Run with verbose logging
zellij --debug
```

### Issue: zjstatus not loading

**Solution:**
```bash
# Verify plugin file exists
ls -lh ~/.config/zellij/plugins/zjstatus.wasm

# Check config.kdl syntax
zellij setup --check

# Download plugin again if missing
mkdir -p ~/.config/zellij/plugins
curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm \
  -o ~/.config/zellij/plugins/zjstatus.wasm
```

### Issue: Keyboard shortcuts conflict

**Kitty vs Zellij:**
- Kitty uses `Ctrl+Shift+...`
- Zellij uses `Ctrl+...` (no shift)
- **No conflicts!**

**If conflicts occur:**
- Disable kitty native tabs/windows (use zellij instead)
- Remap zellij keybindings in `config.kdl`

### Issue: Colors don't match / theme looks wrong

**Solution:**
```bash
# Verify kitty theme
cat ~/.config/kitty/current-theme.conf | grep "^background"
# Should show: background #1e1e2e (Catppuccin Mocha)

# Verify zellij theme
grep "^theme" ~/.config/zellij/config.kdl
# Should show: theme "catppuccin-mocha"

# If zellij theme is wrong, edit config.kdl
```

### Issue: Copy/paste not working correctly

**Inside Zellij:**
- Use zellij scroll mode (`Ctrl+S`) for copying text
- Or use kitty's clipboard shortcuts (`Ctrl+Shift+C/V`)

**Between applications:**
- Ensure `clipboard_control` in kitty.conf allows clipboard access
- Use `Ctrl+Shift+C/V` (not `Ctrl+C/V`)

---

## Performance Considerations

**Resource Usage:**
- **Kitty:** ~50-100MB RAM (depends on scrollback)
- **Zellij:** ~20-40MB RAM per session
- **Total:** ~70-140MB (very reasonable)

**CPU Usage:**
- Kitty: GPU-accelerated (minimal CPU)
- Zellij: Rust-based (efficient, low overhead)

**Compared to Alternatives:**
- **tmux + alacritty:** ~60-100MB total
- **VSCode integrated terminal:** ~300-500MB+
- **This setup:** Middle ground - powerful but lightweight

---

## Best Practices

### 1. Session Management

**Create named sessions for projects:**
```bash
zellij attach -c myproject    # or create if doesn't exist
zellij attach myproject        # attach to existing
zellij list-sessions           # list all sessions
zellij delete-session myproject # delete session
```

### 2. Layouts

**Create project-specific layouts:**
```bash
# ~/.config/zellij/layouts/dev.kdl
layout {
    pane split_direction="vertical" {
        pane command="nvim"          # Editor on left
        pane split_direction="horizontal" {
            pane                       # Terminal on top-right
            pane command="git status"  # Git on bottom-right
        }
    }
}
```

**Load layout:**
```bash
zellij --layout dev attach -c myproject
```

### 3. Theme Consistency

**Always match:**
- Kitty theme: `catppuccin-mocha`
- Zellij theme: `catppuccin-mocha`
- zjstatus colors: Use Catppuccin Mocha palette

**Palette reference:**
```
#1e1e2e - base (background)
#cdd6f4 - text (foreground)
#a6e3a1 - green
#f38ba8 - red
#89b4fa - blue
#f9e2af - yellow
#cba6f7 - mauve
#94e2d5 - teal
```

### 4. Workflow Recommendations

**For SRE/DevOps work:**
- **Tab 1:** Development (editor + terminal)
- **Tab 2:** Logs/Monitoring (journalctl, htop, etc.)
- **Tab 3:** Kubernetes/Docker (kubectl, docker ps, etc.)
- **Tab 4:** Scratch/Testing

**Naming tabs:**
- Use `Ctrl+T, R` to rename tabs meaningfully
- Example: "nvim-api", "k8s-prod", "logs"

---

## Migration Path

### From tmux

**Similarities:**
- Panes, tabs (windows in tmux), sessions
- Detach/attach workflow
- Scrollback and copy mode

**Key Differences:**
- Zellij uses modes (not prefix key)
- Config in KDL/YAML (not tmux.conf)
- Plugins in Rust/WASM (not shell scripts)

**Migration:**
1. Keep tmux installed initially
2. Try zellij for new sessions
3. Gradually migrate old workflows
4. Create zellij layouts equivalent to tmux configs
5. Uninstall tmux when comfortable

### From No Multiplexer

**Learning Curve:**
- Day 1: Learn basic pane creation and navigation
- Week 1: Master tabs and detach/attach
- Month 1: Create custom layouts for workflows
- Ongoing: Explore plugins and advanced features

**Tip:** Print zellij keybindings cheatsheet or create navi cheat.

---

## Future Enhancements

**Potential Additions:**
- **More zjstatus widgets:** CPU, battery, git status
- **Custom layouts:** Per-project layouts
- **Custom plugins:** Rust/WASM plugins for specialized workflows
- **Automation:** Scripts to create sessions with specific layouts
- **Integration:** Kitty hints for URLs/paths in zellij panes

---

## Related Documentation

- **Research Findings:** `sessions/kitty-configuration/RESEARCH_FINDINGS.md`
- **Kitty Docs:** `docs/commons/toolbox/kitty/`
- **Zellij Docs:** `docs/commons/toolbox/zellij/README.md`
- **Chezmoi:** `docs/chezmoi/`

---

**Last Updated:** 2025-11-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
