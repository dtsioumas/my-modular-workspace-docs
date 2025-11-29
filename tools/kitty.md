# Kitty Terminal Guide

**Last Updated:** 2025-11-29
**Sources Merged:** README.md, KITTY_GUIDE.md, DOCUMENTATION.md, CONFIGURATION_SUGGESTIONS.md, SESSION_SUMMARY.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Layouts](#layouts)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

Kitty is a fast, feature-rich, GPU-based terminal emulator that supports:
- GPU acceleration for performance
- Graphics rendering (images, animations)
- Font ligatures and emoji support
- Python-based extensibility ("kittens")
- Advanced window management (tabs, splits, layouts)
- OpenGL 3.3+ requirement

### Current Configuration

- **Font:** JetBrains Mono Nerd Font, size 12
- **Theme:** Catppuccin Mocha (soothing pastels)
- **Transparency:** 0.95 (subtle)
- **Copy:** Copy-on-select enabled
- **Layouts:** tall, stack, splits
- **Scrollback:** 10,000 lines

---

## Quick Start

### Launch Kitty

```bash
# From terminal
kitty

# From WSL (Windows 11)
wsl.exe --cd ~ -e bash -c "kitty"
```

### Essential Shortcuts

| Action | Shortcut |
|--------|----------|
| New tab | `Ctrl+Shift+T` |
| New window/split | `Ctrl+Shift+Enter` |
| Close window | `Ctrl+Shift+W` |
| Cycle layouts | `Ctrl+Shift+L` |
| Copy | `Ctrl+Shift+C` |
| Paste | `Ctrl+Shift+V` |
| Edit config | `Ctrl+Shift+F2` |
| Reload config | `Ctrl+Shift+F5` |

---

## Installation

### NixOS

```nix
programs.kitty = {
  enable = true;
  font = {
    name = "JetBrainsMono Nerd Font";
    size = 11;
  };
};
```

### WSL2 Prerequisites

```bash
# Update Mesa for GPU support
sudo add-apt-repository ppa:kisak/kisak-mesa
sudo apt upgrade

# Install kitty
sudo apt install kitty

# Verify OpenGL
glxinfo -B | grep "OpenGL version"
```

### Config Location

- **NixOS:** Managed via NixOS/home-manager configuration
- **Standard:** `~/.config/kitty/kitty.conf`

---

## Configuration

### Basic Configuration

```conf
# Font
font_family      JetBrainsMono Nerd Font
font_size        12.0
disable_ligatures never

# Appearance
background_opacity 0.95
dynamic_background_opacity yes
window_padding_width 10

# Cursor
cursor_shape block
cursor_blink_interval 0

# Scrollback
scrollback_lines 10000

# Mouse
copy_on_select yes

# Terminal bell
enable_audio_bell no
visual_bell_duration 0.1

# Tab bar
tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted

# Layouts
enabled_layouts splits,stack,tall,grid
```

### Theme (Catppuccin Mocha)

```bash
# Apply theme (built-in for kitty >= 0.26.0)
kitty +kitten themes --reload-in=all Catppuccin-Mocha

# Or include in config
include ~/.config/kitty/themes/mocha.conf
```

### Custom Shortcuts

```conf
# Splits (custom - easier than default)
map ctrl+alt+v launch --location=vsplit --cwd=current
map ctrl+alt+h launch --location=hsplit --cwd=current

# Vim-style navigation
map ctrl+h neighboring_window left
map ctrl+l neighboring_window right
map ctrl+k neighboring_window up
map ctrl+j neighboring_window down

# Layout switching
map ctrl+alt+t goto_layout tall
map ctrl+alt+s goto_layout stack
map ctrl+alt+z toggle_layout stack

# Tab navigation
map ctrl+shift+1 goto_tab 1
map ctrl+shift+2 goto_tab 2
map ctrl+shift+3 goto_tab 3
map ctrl+shift+4 goto_tab 4
map ctrl+shift+5 goto_tab 5

# Quick actions
map f1 launch --stdin-source=@screen_scrollback --type=overlay less +G -R
map f2 launch --type=overlay --hold --cwd=current git status
map f3 launch --type=overlay --hold --cwd=current git diff
```

---

## Keyboard Shortcuts

### Tabs

| Action | Shortcut |
|--------|----------|
| New tab | `Ctrl+Shift+T` |
| Close tab | `Ctrl+Shift+Q` |
| Next tab | `Ctrl+Shift+Right` |
| Previous tab | `Ctrl+Shift+Left` |
| Move tab forward | `Ctrl+Shift+.` |
| Move tab backward | `Ctrl+Shift+,` |
| Goto tab N | `Ctrl+Alt+N` (1-9) |

### Windows (Splits)

| Action | Shortcut |
|--------|----------|
| New split | `Ctrl+Shift+Enter` |
| Close window | `Ctrl+Shift+W` |
| Next window | `Ctrl+Shift+]` |
| Previous window | `Ctrl+Shift+[` |
| Resize mode | `Ctrl+Shift+R` |
| Cycle layouts | `Ctrl+Shift+L` |

### Scrolling

| Action | Shortcut |
|--------|----------|
| Scroll up | `Ctrl+Shift+Up` |
| Scroll down | `Ctrl+Shift+Down` |
| Page up | `Ctrl+Shift+Page Up` |
| Page down | `Ctrl+Shift+Page Down` |
| Scroll to top | `Ctrl+Shift+Home` |
| Scroll to bottom | `Ctrl+Shift+End` |
| Show scrollback | `Ctrl+Shift+H` |

### Font Size

| Action | Shortcut |
|--------|----------|
| Increase | `Ctrl+Shift++` |
| Decrease | `Ctrl+Shift+-` |
| Reset | `Ctrl+Shift+Backspace` |

### Opacity (if dynamic enabled)

| Action | Shortcut |
|--------|----------|
| Increase opacity | `Ctrl+Shift+A+M` |
| Decrease opacity | `Ctrl+Shift+A+L` |
| Full opacity | `Ctrl+Shift+A+1` |
| Default opacity | `Ctrl+Shift+A+D` |

---

## Layouts

### Available Layouts

1. **Splits** - Manual horizontal/vertical splits (like tmux)
2. **Stack** - All windows stacked, only one visible
3. **Tall** - One main window, others stacked vertically
4. **Grid** - Windows arranged in a grid
5. **Fat** - Like tall, but horizontal
6. **Horizontal** - All windows in a row
7. **Vertical** - All windows in a column

### Layout Usage

```conf
# Enable specific layouts
enabled_layouts splits,stack,tall,grid

# Cycle: Ctrl+Shift+L
# Toggle stack (zoom): Ctrl+Alt+Z (custom)
```

---

## Advanced Features

### Shell Integration

Add to `~/.bashrc`:

```bash
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi
```

Features enabled:
- Jump to previous/next prompt
- Show last command output
- Better clipboard integration
- Current working directory tracking

### Session Management

Create reusable terminal layouts:

```bash
# ~/.config/kitty/sessions/dev.session
new_tab Development
cd ~/projects/myproject
launch --type=window
launch --location=vsplit

new_tab Monitoring
launch htop
launch --location=vsplit btop

# Load session
kitty --session ~/.config/kitty/sessions/dev.session
```

### Kittens (Plugins)

```bash
# Unicode picker
# Ctrl+Shift+U

# Hints (URL/path picker)
map ctrl+shift+p>f kitten hints --type path --program -
map ctrl+shift+p>l kitten hints --type line --program -

# Display images
kitty +kitten icat image.png

# Diff files
kitty +kitten diff file1 file2

# SSH with terminal features
kitty +kitten ssh hostname
```

### Remote Control

```conf
# Enable in config
allow_remote_control yes
listen_on unix:/tmp/kitty
```

```bash
# Control from shell
kitty @ ls                              # List windows
kitty @ launch --type=tab               # New tab
kitty @ send-text "echo hello\n"        # Send text
kitty @ set-colors background=#000000   # Change colors
```

---

## Troubleshooting

### Kitty Won't Launch

```bash
# Check PATH
which kitty

# Add to PATH if needed
export PATH="$HOME/.local/kitty.app/bin:$PATH"
```

### Config Not Loading

```bash
# Verify config exists
ls -la ~/.config/kitty/kitty.conf

# Test with specific config
kitty --config ~/.config/kitty/kitty.conf

# Debug config
kitty --debug-config
```

### Shortcuts Not Working

1. Check for system shortcut conflicts
2. Verify kitty.conf syntax
3. Reload config: `Ctrl+Shift+F5`

### Clipboard Not Working

```conf
clipboard_control write-clipboard write-primary read-clipboard-ask read-primary-ask
```

### Transparency Not Working

```conf
background_opacity 0.95
dynamic_background_opacity yes
```

On WSL: Requires WSLg (Windows 11) or X server

### Colors Look Wrong

```conf
term xterm-kitty
linux_display_server auto
```

---

## References

### Official Resources

- **Official Docs:** https://sw.kovidgoyal.net/kitty/
- **GitHub:** https://github.com/kovidgoyal/kitty
- **Quickstart:** https://sw.kovidgoyal.net/kitty/quickstart/

### Themes

- **Catppuccin:** https://github.com/catppuccin/kitty
- **Kitty Themes:** https://github.com/kovidgoyal/kitty-themes

### Configuration Examples

- **GitHub Topic:** https://github.com/topics/kitty-config
- **ArchWiki:** https://wiki.archlinux.org/title/Kitty

---

## Quick Reference Card

```
+--------------------------------------------------------------+
|                  KITTY QUICK REFERENCE                        |
+------------------+-------------------+------------------------+
| TABS             | WINDOWS (SPLITS)  | SCROLLING              |
+------------------+-------------------+------------------------+
| Ctrl+Shift+T     | Ctrl+Shift+Enter  | Ctrl+Shift+Up/Down     |
| Ctrl+Shift+Q     | Ctrl+Shift+W      | Ctrl+Shift+PgUp/PgDn   |
| Ctrl+Shift+Left  | Ctrl+Shift+]/[    | Ctrl+Shift+Home/End    |
| Ctrl+Shift+Right | Ctrl+Shift+L      | Ctrl+Shift+H (pager)   |
+------------------+-------------------+------------------------+
| FONT SIZE        | CONFIG            | COPY/PASTE             |
+------------------+-------------------+------------------------+
| Ctrl+Shift++/-   | Ctrl+Shift+F2     | Ctrl+Shift+C           |
| Ctrl+Shift+BS    | Ctrl+Shift+F5     | Ctrl+Shift+V           |
+------------------+-------------------+------------------------+
```

---

*Migrated from docs/commons/toolbox/kitty/ on 2025-11-29*
