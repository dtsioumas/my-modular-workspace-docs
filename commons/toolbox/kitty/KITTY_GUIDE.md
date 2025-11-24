# Kitty Terminal Emulator - Complete Guide

**Last Updated:** 2025-11-05  
**For:** NixOS (shoshin desktop)  
**Version:** Latest

---

## Table of Contents

1. [Essential Keyboard Shortcuts](#essential-keyboard-shortcuts)
2. [Configuration Overview](#configuration-overview)
3. [Custom Configuration](#custom-configuration)
4. [Advanced Features](#advanced-features)
5. [Layouts](#layouts)
6. [Tips & Tricks](#tips--tricks)

---

## Essential Keyboard Shortcuts

### Tabs (Multiple Terminal Tabs)

| Action | Shortcut | Description |
|--------|----------|-------------|
| **New tab** | `Ctrl+Shift+T` | Open new tab in current window |
| **Close tab** | `Ctrl+Shift+Q` | Close current tab |
| **Next tab** | `Ctrl+Shift+Right` or `Ctrl+Tab` | Switch to next tab |
| **Previous tab** | `Ctrl+Shift+Left` or `Ctrl+Shift+Tab` | Switch to previous tab |
| **Move tab forward** | `Ctrl+Shift+.` | Move current tab right |
| **Move tab backward** | `Ctrl+Shift+,` | Move current tab left |
| **Set tab title** | `Ctrl+Shift+Alt+T` | Rename current tab |
| **Goto tab N** | `Ctrl+Alt+N` (1-9) | Jump to specific tab number |

### Windows (Split Terminals - "Panes")

| Action | Shortcut | Description |
|--------|----------|-------------|
| **New window/split** | `Ctrl+Shift+Enter` | Create new split/pane |
| **Close window** | `Ctrl+Shift+W` | Close current split |
| **Next window** | `Ctrl+Shift+]` | Focus next split |
| **Previous window** | `Ctrl+Shift+[` | Focus previous split |
| **Move window forward** | `Ctrl+Shift+F` | Reorder split forward |
| **Move window backward** | `Ctrl+Shift+B` | Reorder split backward |
| **Resize window** | `Ctrl+Shift+R` | Enter resize mode |
| **Visual window select** | `Ctrl+Shift+F7` | Select window by overlay |
| **Visual window swap** | `Ctrl+Shift+F8` | Swap windows visually |
| **Cycle layouts** | `Ctrl+Shift+L` | Change split layout style |

### OS Windows (New Application Windows)

| Action | Shortcut | Description |
|--------|----------|-------------|
| **New OS window** | `Ctrl+Shift+N` | New kitty application window |
| **Close OS window** | `Alt+F4` | Close application window |

### Copy/Paste & Selection

| Action | Shortcut | Description |
|--------|----------|-------------|
| **Copy** | `Ctrl+Shift+C` | Copy selected text |
| **Paste** | `Ctrl+Shift+V` | Paste from clipboard |
| **Paste from selection** | `Ctrl+Shift+S` or `Shift+Insert` | Paste mouse selection |

### Scrolling & Navigation

| Action | Shortcut | Description |
|--------|----------|-------------|
| **Scroll line up** | `Ctrl+Shift+Up` or `Ctrl+Shift+K` | Scroll up one line |
| **Scroll line down** | `Ctrl+Shift+Down` or `Ctrl+Shift+J` | Scroll down one line |
| **Scroll page up** | `Ctrl+Shift+Page Up` | Scroll up one page |
| **Scroll page down** | `Ctrl+Shift+Page Down` | Scroll down one page |
| **Scroll to top** | `Ctrl+Shift+Home` | Jump to scrollback start |
| **Scroll to bottom** | `Ctrl+Shift+End` | Jump to bottom |
| **Show scrollback** | `Ctrl+Shift+H` | Open scrollback in pager (less) |
| **Show last command output** | `Ctrl+Shift+G` | View last command output |
| **Scroll to prev prompt** | `Ctrl+Shift+Z` | Jump to previous shell prompt |
| **Scroll to next prompt** | `Ctrl+Shift+X` | Jump to next shell prompt |

### Font Size Control

| Action | Shortcut | Description |
|--------|----------|-------------|
| **Increase font size** | `Ctrl+Shift++` or `Ctrl+Shift+=` | Make text larger |
| **Decrease font size** | `Ctrl+Shift+-` | Make text smaller |
| **Reset font size** | `Ctrl+Shift+Backspace` | Reset to default size |

### Configuration & Misc

| Action | Shortcut | Description |
|--------|----------|-------------|
| **Edit config** | `Ctrl+Shift+F2` | Open kitty.conf in editor |
| **Reload config** | `Ctrl+Shift+F5` | Reload configuration |
| **Debug config** | `Ctrl+Shift+F6` | Show config debug info |
| **Toggle fullscreen** | `Ctrl+Shift+F11` | Enter/exit fullscreen |
| **Toggle maximized** | `Ctrl+Shift+F10` | Maximize/restore window |
| **Open URL** | `Ctrl+Shift+E` | Open URL under cursor |
| **Unicode input** | `Ctrl+Shift+U` | Insert Unicode character |
| **Kitty shell** | `Ctrl+Shift+Escape` | Open kitty command shell |

---

## Configuration Overview

### Config File Location

- **NixOS:** Managed via NixOS configuration
- **Standard:** `~/.config/kitty/kitty.conf`

### Opening/Editing Config

```bash
# Method 1: Using kitty shortcut
# Press: Ctrl+Shift+F2

# Method 2: Direct editing
$EDITOR ~/.config/kitty/kitty.conf

# Method 3: From terminal
kitty +open-config
```

### Reloading Config

```bash
# Method 1: Using shortcut
# Press: Ctrl+Shift+F5

# Method 2: Send signal
kill -SIGUSR1 $KITTY_PID

# Method 3: From kitty shell
# Press Ctrl+Shift+Escape, then type:
# load_config_file
```

---

## Custom Configuration

### Basic Customization

```conf
# Font Configuration
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size 11.0

# Cursor
cursor_shape block
cursor_blink_interval 0

# Scrollback
scrollback_lines 10000
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER

# Mouse
copy_on_select yes
strip_trailing_spaces smart
select_by_word_characters @-./_~?&=%+#

# Window layout
remember_window_size  yes
initial_window_width  1200
initial_window_height 800
window_padding_width 4
enabled_layouts splits,stack,tall,grid

# Tab bar
tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted
tab_title_template "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}"

# Colors (Gruvbox Dark example)
background #282828
foreground #ebdbb2
cursor #ebdbb2

# Terminal bell
enable_audio_bell no
visual_bell_duration 0.0
window_alert_on_bell yes

# Advanced
shell_integration enabled
allow_remote_control yes
listen_on unix:/tmp/kitty
```

### Custom Keyboard Shortcuts

Add to `kitty.conf`:

```conf
# Custom split shortcuts (easier than default)
map ctrl+alt+v launch --location=vsplit --cwd=current
map ctrl+alt+h launch --location=hsplit --cwd=current

# Quick layout switching
map ctrl+alt+t goto_layout tall
map ctrl+alt+s goto_layout stack
map ctrl+alt+g goto_layout grid
map ctrl+alt+z toggle_layout stack

# Better window navigation (vim-style)
map ctrl+h neighboring_window left
map ctrl+l neighboring_window right
map ctrl+k neighboring_window up
map ctrl+j neighboring_window down

# Move windows (vim-style)
map shift+ctrl+h move_window left
map shift+ctrl+l move_window right
map shift+ctrl+k move_window up
map shift+ctrl+j move_window down

# Resize windows
map ctrl+left resize_window narrower
map ctrl+right resize_window wider
map ctrl+up resize_window taller
map ctrl+down resize_window shorter

# Tab management
map ctrl+shift+1 goto_tab 1
map ctrl+shift+2 goto_tab 2
map ctrl+shift+3 goto_tab 3
map ctrl+shift+4 goto_tab 4
map ctrl+shift+5 goto_tab 5

# Quick actions
map f1 launch --stdin-source=@screen_scrollback --stdin-add-formatting --type=overlay less +G -R
map f2 launch --type=overlay --hold --cwd=current git status
map f3 launch --type=overlay --hold --cwd=current git diff
```

---

## Advanced Features

### Shell Integration

Requires shell integration in your `.bashrc` or `.zshrc`:

```bash
# For bash
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi

# For zsh
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    source "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh"
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
# Shortcut: Ctrl+Shift+U
# kitten unicode_input

# Hints (URL/path picker)
# Shortcut: Ctrl+Shift+E (URLs)
map ctrl+shift+p>f kitten hints --type path --program -
map ctrl+shift+p>l kitten hints --type line --program -
map ctrl+shift+p>w kitten hints --type word --program -
map ctrl+shift+p>h kitten hints --type hash --program -
map ctrl+shift+p>n kitten hints --type linenum

# Diff tool
# kitten diff file1 file2

# SSH integration
# kitten ssh hostname
```

---

## Layouts

### Available Layouts

1. **Splits** - Manual horizontal/vertical splits
2. **Stack** - All windows stacked, only one visible
3. **Tall** - One main window, others stacked vertically
4. **Grid** - Windows arranged in a grid
5. **Fat** - Like tall, but horizontal
6. **Horizontal** - All windows in a row
7. **Vertical** - All windows in a column

### Layout Cycle

Press `Ctrl+Shift+L` to cycle through layouts.

### Setting Default Layout

```conf
# In kitty.conf
enabled_layouts splits,stack,tall,grid

# First layout is the default startup layout
```

---

## Tips & Tricks

### 1. Quick Split with Current Directory

```conf
# Add to kitty.conf
map f1 launch --location=vsplit --cwd=current
map f2 launch --location=hsplit --cwd=current
```

### 2. Temporary "Zoom" Window

```conf
# Toggle stack layout to focus on current window
map ctrl+alt+z toggle_layout stack
```

### 3. Multiple Terminal Sessions

```bash
# Launch multiple kitty instances for different projects
kitty --session ~/dev-session &
kitty --session ~/monitor-session &
```

### 4. Remote Control

```bash
# Enable in kitty.conf
allow_remote_control yes
listen_on unix:/tmp/kitty

# Control from shell
kitty @ ls                                    # List windows
kitty @ launch --type=tab                     # New tab
kitty @ send-text "echo hello\n"             # Send text
kitty @ set-colors background=#000000        # Change colors
kitty @ close-window                          # Close window
```

### 5. Background Opacity

```conf
# In kitty.conf
background_opacity 0.9
dynamic_background_opacity yes

# Then use shortcuts:
# Ctrl+Shift+A > M : Increase opacity
# Ctrl+Shift+A > L : Decrease opacity
# Ctrl+Shift+A > 1 : Full opacity
# Ctrl+Shift+A > D : Default opacity
```

### 6. Custom Themes

```bash
# List available themes
kitty +kitten themes

# Apply theme (creates theme.conf)
kitty +kitten themes --reload-in=all <theme-name>

# Or include in kitty.conf
include ~/.config/kitty/themes/gruvbox-dark.conf
```

### 7. Performance Tweaks

```conf
# Faster rendering
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Disable features you don't need
enable_audio_bell no
visual_bell_duration 0
```

### 8. Save Terminal Output

```bash
# From within kitty, save scrollback
# Ctrl+Shift+H (opens in pager)

# Or programmatically
kitty @ get-text --extent=all > output.txt
```

### 9. Image Display

```bash
# Kitty supports displaying images in terminal
kitty +kitten icat image.png
kitty +kitten icat --align=center image.jpg
```

### 10. Debugging

```bash
# Show current configuration
# Shortcut: Ctrl+Shift+F6

# Check input events
kitty --debug-input

# Check config errors
kitty --debug-config
```

---

## Common Issues & Solutions

### Issue: Shortcuts Not Working

**Solution:**
1. Check if conflicting with system shortcuts
2. Verify `kitty.conf` syntax
3. Reload config: `Ctrl+Shift+F5`

### Issue: Clipboard Not Working

**Solution:**
```conf
# Add to kitty.conf
clipboard_control write-clipboard write-primary read-clipboard-ask read-primary-ask
```

### Issue: Font Rendering Issues

**Solution:**
```conf
# Try different font rendering
text_composition_strategy platform
# or
text_composition_strategy legacy
```

### Issue: Colors Look Wrong

**Solution:**
```conf
# Ensure proper term
term xterm-kitty

# Check color space (NixOS/Linux)
linux_display_server auto
```

---

## Additional Resources

- **Official Documentation:** https://sw.kovidgoyal.net/kitty/
- **GitHub:** https://github.com/kovidgoyal/kitty
- **Themes:** https://github.com/kovidgoyal/kitty-themes
- **Community Configs:** https://github.com/topics/kitty-config

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                  KITTY QUICK REFERENCE                       │
├─────────────────────────────────────────────────────────────┤
│ TABS            │ WINDOWS (SPLITS) │ SCROLLING              │
├─────────────────┼──────────────────┼─────────────────────────┤
│ Ctrl+Shift+T    │ Ctrl+Shift+Enter │ Ctrl+Shift+Up/Down     │
│ Ctrl+Shift+Q    │ Ctrl+Shift+W     │ Ctrl+Shift+PgUp/PgDn   │
│ Ctrl+Shift+→/← │ Ctrl+Shift+]/[  │ Ctrl+Shift+Home/End    │
│ Ctrl+Shift+L    │ Ctrl+Shift+L     │ Ctrl+Shift+H (pager)   │
├─────────────────┼──────────────────┼─────────────────────────┤
│ FONT SIZE       │ CONFIG           │ COPY/PASTE             │
├─────────────────┼──────────────────┼─────────────────────────┤
│ Ctrl+Shift++/-  │ Ctrl+Shift+F2    │ Ctrl+Shift+C           │
│ Ctrl+Shift+BS   │ Ctrl+Shift+F5    │ Ctrl+Shift+V           │
│                 │ Ctrl+Shift+F6    │ Shift+Insert           │
└─────────────────┴──────────────────┴─────────────────────────┘
```

**Remember:** Most shortcuts use `Ctrl+Shift+` prefix!

---

**Created for:** shoshin NixOS Desktop Configuration  
**Author:** Μήτσο  
**Date:** November 2025
