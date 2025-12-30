# Kitty Terminal Quick Reference for AI Agents
## Fast lookup guide for common commands and configurations

---

## Installation & Setup

```bash
# Install kitty (Ubuntu/Debian)
sudo apt install kitty

# Update to latest
kitty @ check-for-updates

# Verify GPU support
glxinfo | grep "OpenGL renderer"

# Check terminal
echo $TERM  # Should show: xterm-kitty
```

---

## Essential Keybindings

### Windows
| Action | Binding |
|--------|---------|
| New Window | `Ctrl+Shift+Enter` |
| Close Window | `Ctrl+Shift+W` |
| Next Window | `Ctrl+Shift+]` |
| Previous Window | `Ctrl+Shift+[` |
| Focus Left | `Ctrl+Left` |
| Focus Right | `Ctrl+Right` |
| Resize Mode | `Ctrl+Shift+R` |

### Tabs
| Action | Binding |
|--------|---------|
| New Tab | `Ctrl+Shift+T` |
| Close Tab | `Ctrl+Shift+Q` |
| Next Tab | `Ctrl+Shift+Right` |
| Previous Tab | `Ctrl+Shift+Left` |
| Goto Tab 1-5 | `Alt+1-5` |
| Move Tab Forward | `Ctrl+Shift+.` |
| Move Tab Backward | `Ctrl+Shift+,` |

### Agents
| Action | Binding |
|--------|---------|
| Claude Code | `Ctrl+Alt+C` |
| Gemini CLI | `Ctrl+Alt+G` |
| Codex | `Ctrl+Alt+X` |

### Text Selection (Hints)
| Action | Binding |
|--------|---------|
| URLs | `Ctrl+Shift+E` |
| File Paths | `Ctrl+Shift+F` |
| Line Numbers | `Ctrl+Shift+P` |
| Git Hashes | `Ctrl+G` |
| Images | `Ctrl+Shift+I` |

---

## Kitty Commands

### Remote Control
```bash
# List windows/tabs
kitten @ --to=unix:/tmp/mykitty ls

# Create new window
kitten @ --to=unix:/tmp/mykitty new_window --title="Name"

# Send text to window
kitten @ --to=unix:/tmp/mykitty send-text "command\n"

# Get colors
kitten @ ask-for-colors

# Check buffer size
kitten @ get-buffer-size
```

### Theme Management
```bash
# Interactive theme selector
kitty +kitten themes

# List available themes
kitty +kitten themes --with-name

# Set theme in config
# include ~/.config/kitty/theme.conf
```

### Other Kittens
```bash
# Display image
icat /path/to/image.png

# Unicode input
kitten unicode_input

# Clipboard operations
kitten +kitten clipboard read
kitten +kitten clipboard  # write stdin
```

---

## Quick Configuration Snippets

### Performance (Balanced)
```bash
# kitty.conf
repaint_delay 10
input_delay 3
sync_to_monitor yes
```

### Performance (Maximum)
```bash
# kitty.conf
repaint_delay 2
input_delay 0
sync_to_monitor no
```

### RAM Optimization
```bash
# kitty.conf
scrollback_lines 2000  # Minimal
scrollback_lines 5000  # Balanced (recommended)
scrollback_lines 10000 # High history
```

### Minimal Keybindings (Add to kitty.conf)
```bash
# Basic agent launching
map ctrl+alt+c launch_window bash -c 'claude-code'
map ctrl+alt+g launch_window bash -c 'gemini-cli'
map ctrl+alt+x launch_window bash -c 'codex'

# Text selection
map ctrl+shift+e kitten hints --type url --program open
map ctrl+shift+f kitten hints --type path --program @
map ctrl+shift+p kitten hints --type=linenum --linenum-action=tab
```

---

## Environment Variables

```bash
# GPU/Rendering
export KITTY_GRAPHICS_PROTOCOL=kitty
export KITTY_DISABLE_GPU=0        # 0=enabled, 1=disabled
export KITTY_DEBUG_GL=1           # Debug mode

# Color
export KITTY_COLOR_THEME="Dracula"

# Configuration
export KITTY_CONFIG_DIRECTORY=~/.config/kitty

# In kitty.conf:
env LANG=en_US.UTF-8
env LC_ALL=en_US.UTF-8
```

---

## Hints Kitten Quick Examples

```bash
# Open URL in browser (built-in)
ctrl+shift+e

# Copy file path
kitten hints --type path --program @

# Open file in line number
kitten hints --type=linenum --linenum-action=tab nvim +{line} {path}

# Custom regex matching
kitten hints --type=regex --regex='[a-f0-9]{40}' --program @
```

---

## Troubleshooting

### Color Not Working
```bash
# Verify terminal type
echo $TERM

# Should show: xterm-kitty

# If not, set explicitly
export TERM=xterm-kitty
```

### GPU Not Used
```bash
# Check OpenGL renderer
glxinfo | grep -i "opengl renderer"

# Force enable GPU
KITTY_DISABLE_GPU=0 kitty
```

### High Memory Usage
```bash
# Check current scrollback
kitten @ get-buffer-size

# Reduce and restart
# In kitty.conf: scrollback_lines = 2000
# Then: kitten @ quit --all
```

### Keybinding Not Working
```bash
# Check if loaded
kitten @ list_actions | grep -i "map"

# Verify in config
cat ~/.config/kitty/kitty.conf | grep "map"
```

---

## Performance Benchmarks

### CPU Usage (Idle)
- Kitty: ~2-3%
- Competitors: ~8-15%

### CPU Usage (Scrolling)
- Kitty: ~6-8%
- Competitors: ~15-20%

### Rendering Speed
- Glyph cache: 2x faster than next best
- First output latency: < 1ms

### RAM Usage (Typical)
- Base kitty: ~20-30MB
- Per window: ~0.5-1MB (5000 line scrollback)
- Total 3 agents: ~35-50MB

---

## Layout Reference

```
Tall Layout (70% bias):
┌─────────────────┬─────────┐
│                 │         │
│  Main Agent     │Secondary│
│  (Claude Code)  │  Agents │
│                 │         │
└─────────────────┴─────────┘

Stack Layout (Single window):
┌─────────────────────────────┐
│                             │
│       Active Window         │
│   (Others hidden behind)    │
│                             │
└─────────────────────────────┘

Splits Layout (Custom):
┌─────────────┬─────────┐
│             │ Code    │
│   Analyze   ├─────────┤
│             │ Diff    │
└─────────────┴─────────┘
```

---

## Common Workflows

### Multi-Agent Development
```bash
# Window 1 (70%): Claude Code for main development
# Window 2 (30%): Tabs for Gemini CLI, Codex, monitoring

# Switch layouts: Ctrl+Shift+L
# Move between: Ctrl+Shift+] / [
# Resize: Ctrl+Shift+R
```

### Code Review
```bash
# Tab 1: Git diff view
# Tab 2: Test output
# Tab 3: Agent analysis (Codex)

# Use Splits layout for side-by-side comparison
# Ctrl+Alt+3 to switch to Splits
```

### Documentation Review
```bash
# Use large scrollback or scrollback_pager_history_size
# Scroll with mouse or Shift+Page_Up/Down
# Search in scrollback: Ctrl+Shift+H (with hints)
```

---

## Configuration File Locations

```bash
# Main configuration
~/.config/kitty/kitty.conf

# Theme/color files
~/.config/kitty/theme.conf

# Custom Python hints
~/.config/kitty/custom-hints.py

# Socket for remote control
/tmp/mykitty

# Home Manager config (NixOS)
~/.config/home-manager/home.nix
```

---

## Getting Help

```bash
# View man page
man kitty.conf

# Official documentation
https://sw.kovidgoyal.net/kitty/

# GitHub issues
https://github.com/kovidgoyal/kitty/issues

# In kitty: help with a command
kitten @ help send-text
```

---

## Tips & Tricks

1. **Fastest Agent Launch**
   ```bash
   # Bind launcher script to hotkey
   map ctrl+alt+shift+a ~/.local/bin/workspace-agents
   ```

2. **Copy Agent Output**
   ```bash
   # Quick copy screen to clipboard
   Ctrl+Shift+C (custom binding)
   ```

3. **Theme Switching**
   ```bash
   # Change theme on the fly
   kitten +kitten themes
   ```

4. **Screenshot Agent Output**
   ```bash
   # Capture with kitty graphics protocol
   kitten icat --transfer=stream --use-unicode-characters
   ```

5. **Session Persistence**
   ```bash
   # Use tmux inside kitty for session recovery
   tmux new-session -d -s agents
   kitty --session agents
   ```

---

## Performance Optimization Checklist

- [ ] Install latest kitty (0.44+)
- [ ] Verify GPU support enabled
- [ ] Set appropriate scrollback (5000 lines)
- [ ] Configure repaint_delay (10ms balanced)
- [ ] Set sync_to_monitor appropriately
- [ ] Disable unnecessary features (audio bell, IME if not needed)
- [ ] Configure color scheme for readability
- [ ] Set up hints kitten with custom patterns
- [ ] Create agent launcher keybindings
- [ ] Test remote control socket
- [ ] Monitor memory usage after setup
- [ ] Document your custom configuration

---

**Last Updated:** 2025-12-22
**Version:** 1.0
**Status:** Ready for Implementation
# Kitty Terminal - Complete Customization Guide

**Last Updated:** 2025-12-01
**Author:** Dimitris Tsioumas (Mitsio)
**Purpose:** Document all kitty customizations for my-modular-workspace
**Session:** kitty-configuration-phase2-continuation

---

## Table of Contents

1. [Overview](#overview)
2. [Theme & Appearance](#theme--appearance)
3. [Kittens (Plugins)](#kittens-plugins)
4. [Keyboard Shortcuts](#keyboard-shortcuts)
5. [Window & Tab Management](#window--tab-management)
6. [Advanced Features](#advanced-features)
7. [Configuration Files](#configuration-files)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### Current Configuration Status

**Theme:** Dracula (vibrant dark purple)
**Transparency:** 0.15 (85% transparent - very transparent)
**Font:** JetBrains Mono Nerd Font, size 12
**Management:** Chezmoi (`dotfiles/dot_config/kitty/`)
**Last Major Update:** 2025-12-01 (Phase B & C.1 completion)

### Customization Philosophy

Our kitty configuration focuses on:
- **SRE/DevOps workflows** - Log analysis, command history, git integration
- **Transparency** - See browser/documentation while working in terminal
- **Productivity** - Quick access panels, search, theme switching
- **Minimal friction** - Everything keyboard-driven, no mouse needed

---

## Theme & Appearance

### Current Theme: Dracula

**Colors:**
- Background: `#282a36` (dark purple-gray)
- Foreground: `#f8f8f2` (light gray)
- Selection: `#44475a` (purple-gray)
- Cursor: `#f8f8f2` (light gray)
- URL: `#8be9fd` (cyan)

**Why Dracula?**
- Vibrant, high-contrast colors
- Excellent readability
- Popular theme with wide support
- Easy on the eyes for long sessions

### Transparency Settings

**Current Opacity:** 0.15 (85% transparent)

```conf
background_opacity 0.15
dynamic_background_opacity yes
background_blur 32
```

**Dynamic Adjustments:**
- `Ctrl+Equal` - Increase opacity (less transparent)
- `Ctrl+Minus` - Decrease opacity (more transparent)
- `Ctrl+Shift+A, 1` - Full opacity (100%, no transparency)
- `Ctrl+Shift+A, D` - Default opacity (back to 0.15)

**Use Cases:**
- **High transparency (0.15):** See browser/docs behind terminal (current)
- **Medium transparency (0.30-0.50):** Balance between visibility and readability
- **Low transparency (0.70-0.90):** Focus on terminal content only

### Theme Switching

**Quick Theme Switcher:** `Ctrl+Shift+F9`

**How It Works:**
1. Press `Ctrl+Shift+F9`
2. Interactive theme browser opens with live preview
3. Use `↑`/`↓` arrow keys to browse 300+ themes
4. Press `Enter` to apply a theme permanently
5. Press `Esc` to cancel and revert

**Popular Themes to Try:**
- **Dracula** (current) - Vibrant purple
- **Tokyo Night** - Modern dark blue
- **Nord** - Arctic blue-gray
- **Gruvbox Dark** - Retro warm colors
- **One Dark** - Atom editor theme
- **Solarized Dark** - Classic low-contrast
- **Catppuccin Mocha** - Soothing pastels (previous theme)

**Permanent Theme Change:**
```bash
# Apply theme to all kitty windows
kitty +kitten themes --reload-in=all Dracula

# Theme is saved to current-theme.conf automatically
```

---

## Kittens (Plugins)

Kittens are kitty's plugin system. We use several essential kittens for productivity.

### 1. Search Kitten (Scrollback Search)

**What:** Incremental search in terminal scrollback buffer (like tmux `/` search)

**Shortcut:** `Ctrl+Shift+/`

**Features:**
- Incremental search while typing
- Regex support (press `Tab` to toggle)
- Navigate matches with `↑`/`↓`
- `Ctrl+U` to clear query
- `Enter` to keep position and exit
- `Esc` to scroll to bottom and exit

**Installation:**
```bash
cd ~/.config/kitty
git clone https://github.com/trygveaa/kitty-kitten-search kitty_search
```

**Use Cases:**
- Search through command output
- Find specific log entries
- Navigate large files displayed in terminal
- Analyze stack traces

**Configuration:**
```conf
map kitty_mod+/ launch --location=hsplit --allow-remote-control kitty +kitten kitty_search/search.py @active-kitty-window-id
```

---

### 2. Panel Kitten (Dropdown Terminal)

**What:** Quake-style dropdown terminal overlay

**Shortcut:** `F12`

**Features:**
- Drops from top of screen (50% height)
- Toggle show/hide with same key
- Runs any program (shell, editor, monitor)
- Positioned over current workspace
- GPU-accelerated rendering

**Use Cases:**
- Quick commands without opening new window
- Temporary calculations or notes
- System monitoring (htop, btop)
- Quick git status checks
- Scratchpad terminal

**Configuration:**
```conf
# F12 - Top dropdown (50% height)
map f12 kitten panel --edge top --size 0.5
```

**Advanced Panel Examples:**
```conf
# Bottom panel (50% height)
map f11 kitten panel --edge bottom --size 0.5

# Right side panel with system monitor
map ctrl+shift+f10 kitten panel --edge right --size 0.4 btop

# Left side panel with quick notes
map ctrl+shift+f11 kitten panel --edge left --size 0.3 nvim ~/notes/quick.md

# Specific output (multi-monitor setup)
map f12 kitten panel --edge top --size 0.5 --output-name DP-1
```

**Panel Customization:**
- `--edge`: top, bottom, left, right
- `--size`: 0.0-1.0 (fraction of screen)
- `--output-name`: Specific monitor (DP-1, HDMI-1, etc.)
- Last argument: Program to run (default: shell)

---

### 3. Hints Kitten (URL/Path Selection)

**What:** Keyboard-driven selection of URLs, paths, lines, hashes

**Shortcuts:**
- `Ctrl+Shift+E` - Select and open URLs in browser
- `Ctrl+Shift+P, F` - Select and copy file paths
- `Ctrl+Shift+P, L` - Select and copy lines
- `Ctrl+Shift+P, W` - Select and copy words
- `Ctrl+Shift+P, H` - Select and copy git hashes
- `Ctrl+Shift+P, E` - Open file path in VSCodium
- `Ctrl+Shift+P, N` - Open file:line in VSCodium (stack traces)

**How It Works:**
1. Press hint shortcut
2. Hints (letters) appear over clickable items
3. Type the hint letters to select
4. Item is opened/copied based on configuration

**Use Cases:**
- Open URLs from terminal output
- Open files mentioned in error messages
- Jump to specific line in stack traces
- Copy git commit hashes
- Open config files in editor

**Configuration Examples:**
```conf
# Open URLs in browser
map ctrl+shift+e kitten hints --type url

# Select and copy paths
map ctrl+shift+p>f kitten hints --type path --program -

# Open paths in VSCodium
map ctrl+shift+p>e kitten hints --type path --program "codium"

# Open line numbers in VSCodium (stack traces)
map ctrl+shift+p>n kitten hints --type linenum --linenum-action=tab codium +{line} {path}

# Custom regex hints (e.g., SQL tables)
map ctrl+shift+p>t kitten hints --type regex --regex "TABLE\\s+(\\w+)" --program -
```

---

### 4. Diff Kitten (Side-by-Side File Comparison)

**What:** Fast, GPU-accelerated side-by-side diff with syntax highlighting

**Usage:**
```bash
# Compare two files
kitty +kitten diff file1.py file2.py

# Compare directories
kitty +kitten diff dir1/ dir2/

# Use as git difftool
git difftool
```

**Features:**
- Syntax highlighting
- Image diffing (!)
- Fast GPU rendering
- Keyboard navigation
- Git integration

**Git Integration (Configured):**
```ini
# ~/.gitconfig
[diff]
    tool = kitty
[difftool "kitty"]
    cmd = kitty +kitten diff $LOCAL $REMOTE
    trustExitCode = true
[difftool]
    prompt = false
```

**Keyboard Navigation in Diff:**
- `N` / `P` - Next/Previous change
- `Q` - Quit
- Arrow keys - Scroll
- `Ctrl+L` - Refresh

---

### 5. SSH Kitten (Better SSH)

**What:** SSH with automatic terminfo copying and config transfer

**Usage:**
```bash
# Aliased - just use ssh as normal
ssh user@remote-host
```

**Benefits:**
- Automatically copies kitty terminfo to remote
- No more "unknown term type" errors
- Can copy shell config (.bashrc, .vimrc)
- Connection reuse for low latency
- Shell integration works on remote

**Configuration:**
```bash
# ~/.bashrc (via chezmoi)
if test -n "$KITTY_INSTALLATION_DIR"; then
    alias ssh="kitty +kitten ssh"
fi
```

**Advanced Usage:**
```bash
# Copy shell config to remote
kitty +kitten ssh --copy-config user@host

# Specific config files
kitty +kitten ssh --copy-config --copy-only .bashrc,.vimrc user@host
```

---

### 6. Themes Kitten (Theme Browser)

**Shortcut:** `Ctrl+Shift+F9`

**What:** Interactive theme browser with live preview

**Features:**
- 300+ built-in themes
- Live preview (see changes instantly)
- Filter by name
- Apply permanently or temporarily

**Usage:**
1. Press `Ctrl+Shift+F9`
2. Browse with arrow keys
3. Filter by typing theme name
4. Press `Enter` to apply
5. Press `Esc` to cancel

**Command Line:**
```bash
# Browse and apply theme
kitty +kitten themes

# Apply specific theme to all windows
kitty +kitten themes --reload-in=all Dracula

# Apply to current window only
kitty +kitten themes --reload-in=self Nord

# Dump theme config
kitty +kitten themes --dump-theme Dracula
```

---

### 7. icat Kitten (Image Display)

**What:** Display images directly in terminal

**Usage:**
```bash
# Display an image
kitty +kitten icat image.png

# Display with specific size
kitty +kitten icat --align left --place 40x40@0x0 image.png

# Display from URL
kitty +kitten icat https://example.com/image.jpg
```

**Use Cases:**
- Preview images before opening in editor
- Display diagrams/charts in terminal
- Show thumbnails of files
- Display QR codes for sharing

**Hints Integration:**
```conf
# Select path, then preview image
map ctrl+shift+p>img kitten hints --type path --program "kitty +kitten icat"
```

---

## Keyboard Shortcuts

### Essential Shortcuts

#### Copy/Paste
- `Ctrl+Shift+C` - Copy to clipboard
- `Ctrl+Shift+V` - Paste from clipboard
- **Right-click** - Paste from clipboard (custom addition)

#### Scrolling
- `Ctrl+Shift+Up/Down` - Scroll line up/down
- `Ctrl+Shift+Page Up/Down` - Scroll page up/down
- `Ctrl+Shift+Home/End` - Scroll to top/bottom
- `Ctrl+Shift+H` - Show scrollback in pager

#### Search & Navigation (Shell Integration)
- `Ctrl+Shift+/` - Incremental search in scrollback
- `Ctrl+Shift+Z` - Jump to previous command prompt
- `Ctrl+Shift+X` - Jump to next command prompt
- `Ctrl+Shift+G` - Show last command output

#### Windows & Tabs
- `Ctrl+Shift+Enter` - New window (split)
- `Ctrl+Alt+H` - Horizontal split
- `Ctrl+Alt+V` - Vertical split
- `Ctrl+Shift+W` - Close window
- `Ctrl+Alt+Left/Right/Up/Down` - Navigate between windows (directional)
- `Ctrl+Tab` / `Ctrl+Shift+Tab` - Cycle windows
- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+Q` - Close tab
- `Ctrl+Shift+Right/Left` - Next/Previous tab
- `Ctrl+Alt+1-5` - Go to tab 1-5

#### Layouts
- `Ctrl+Shift+L` - Next layout (cycle through tall, stack, splits, grid)
- `Ctrl+Shift+R` - Start resizing window (use arrows to resize)

#### Font Size
- `Ctrl+Shift+Equal` - Increase font size
- `Ctrl+Shift+Minus` - Decrease font size
- `Ctrl+Shift+Backspace` - Reset font size to default

#### Opacity (Transparency)
- `Ctrl+Equal` - Increase opacity (less transparent)
- `Ctrl+Minus` - Decrease opacity (more transparent)
- `Ctrl+Shift+A, M` - Increase opacity (alternative)
- `Ctrl+Shift+A, L` - Decrease opacity (alternative)
- `Ctrl+Shift+A, 1` - Full opacity (no transparency)
- `Ctrl+Shift+A, D` - Default opacity

#### Special Features
- `F12` - Toggle dropdown terminal (panel kitten)
- `Ctrl+Shift+F9` - Theme browser
- `Ctrl+Shift+F5` - Reload config
- `Ctrl+Shift+F2` - Edit config file
- `Ctrl+Shift+F11` - Toggle fullscreen
- `Ctrl+Shift+U` - Unicode input
- `Ctrl+Shift+Delete` - Clear terminal and reset
- `Ctrl+Shift+Escape` - Kitty shell (advanced)

---

## Window & Tab Management

### Window Splitting

**Create Splits:**
- `Ctrl+Alt+H` - Horizontal split (new window below)
- `Ctrl+Alt+V` - Vertical split (new window to right)
- `Ctrl+Shift+Enter` - New window (uses current layout)

**Navigate Splits:**
- `Ctrl+Alt+Left` - Focus window to the left
- `Ctrl+Alt+Right` - Focus window to the right
- `Ctrl+Alt+Up` - Focus window above
- `Ctrl+Alt+Down` - Focus window below
- `Ctrl+Tab` - Next window (cycle)
- `Ctrl+Shift+Tab` - Previous window (cycle)

**Resize Windows:**
1. Press `Ctrl+Shift+R` (enter resize mode)
2. Use arrow keys to resize
3. Press `Esc` to exit resize mode

**Move Windows:**
- `Ctrl+Shift+F` - Move window forward (in stack order)
- `Ctrl+Shift+B` - Move window backward
- `Ctrl+Shift+\`` - Move window to top

### Layouts

**Available Layouts:**
- **Splits** - Manual splits (like tmux)
- **Stack** - All windows stacked, only one visible (like tabs)
- **Tall** - One main window, others stacked vertically
- **Grid** - Windows arranged in grid

**Cycle Layouts:**
- `Ctrl+Shift+L` - Next layout

**Use Cases:**
- **Splits** - Code + logs side-by-side
- **Stack** - Focus on one window, quick switching
- **Tall** - Main editor + support terminals
- **Grid** - Multiple monitoring windows

### Tabs

**Tab Management:**
- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+Q` - Close tab
- `Ctrl+Shift+Right/Left` - Next/Previous tab
- `Ctrl+Alt+1-5` - Go to specific tab (1-5)
- `Ctrl+Shift+.` / `Ctrl+Shift+,` - Move tab forward/backward
- `Ctrl+Shift+Alt+T` - Set tab title

**Tab Organization:**
- Use tabs for different projects/contexts
- Use windows within tabs for related tasks
- Set descriptive tab titles for clarity

---

## Advanced Features

### Shell Integration

**Status:** Enabled (full mode)

**Features:**
- Command prompt markers
- Jump to previous/next prompt
- Show last command output
- Current directory tracking
- Better clipboard integration

**Configuration:**
```bash
# ~/.bashrc (via chezmoi)
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi
```

**Keyboard Shortcuts:**
- `Ctrl+Shift+Z` - Jump to previous prompt
- `Ctrl+Shift+X` - Jump to next prompt
- `Ctrl+Shift+G` - Show last command output

### Remote Control

**Status:** Enabled

**Configuration:**
```conf
allow_remote_control yes
listen_on unix:/tmp/kitty
```

**Use Cases:**
- Script complex terminal workflows
- Integrate with external tools
- Automate repetitive tasks
- Change themes from command line

**Examples:**
```bash
# List all windows (JSON)
kitty @ ls

# Create new tab
kitty @ launch --type=tab --title "My Task" --cwd ~/projects

# Send text to specific window
kitty @ send-text --match title:mywindow "echo hello\n"

# Change colors
kitty @ set-colors background=#000000

# Close specific window
kitty @ close-window --match title:temp

# Change theme from command line
kitty @ set-colors --all --configured ~/.config/kitty/current-theme.conf
```

### Session Management

**Create reusable terminal layouts:**

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

---

## Configuration Files

### File Structure

```
~/.config/kitty/
├── kitty.conf           # Main configuration
├── current-theme.conf   # Active theme
└── kitty_search/        # Search kitten (git clone)
    └── search.py
```

**Managed by Chezmoi:**
```
dotfiles/
└── dot_config/
    └── kitty/
        ├── kitty.conf
        └── current-theme.conf
```

### Configuration Sections

**kitty.conf structure:**
1. Font settings
2. Cursor settings
3. Scrollback settings
4. Mouse settings
5. Performance tuning
6. Window layout
7. Tab bar
8. Transparency
9. Color scheme (includes current-theme.conf)
10. Advanced settings
11. Keyboard shortcuts
12. Kittens configuration

### Applying Changes

**Method 1: Reload Config (Recommended)**
```bash
# Press in kitty
Ctrl+Shift+F5
```

**Method 2: Edit and Reload**
```bash
# Edit config
Ctrl+Shift+F2

# Make changes, save
# Then reload
Ctrl+Shift+F5
```

**Method 3: Via Chezmoi (Our Setup)**
```bash
cd ~/. MyHome/MySpaces/my-modular-workspace/dotfiles

# Edit files
vim dot_config/kitty/kitty.conf

# Apply changes
chezmoi apply

# Reload in kitty
Ctrl+Shift+F5
```

---

## Troubleshooting

### Config Not Loading

**Check config syntax:**
```bash
kitty --debug-config
```

**Test with specific config:**
```bash
kitty --config ~/.config/kitty/kitty.conf
```

**Verify config location:**
```bash
ls -la ~/.config/kitty/kitty.conf
```

### Transparency Not Working

**Requirements:**
- Compositor support (KDE Plasma, GNOME, Hyprland, etc.)
- `background_opacity` and `dynamic_background_opacity` enabled
- GPU acceleration working

**Check:**
```bash
# Verify GPU acceleration
glxinfo -B | grep "OpenGL version"

# Test transparency
echo "background_opacity 0.5" > test.conf
kitty --config test.conf
```

**KDE Plasma:**
- System Settings → Window Management → Window Rules
- Check if transparency is disabled for specific windows

### Kittens Not Working

**Search kitten not found:**
```bash
# Reinstall
cd ~/.config/kitty
rm -rf kitty_search
git clone https://github.com/trygveaa/kitty-kitten-search kitty_search
```

**Panel kitten issues:**
- Check if compositor is running (required for overlays)
- Try different edge (top/bottom/left/right)
- Reduce size (0.3 instead of 0.5)

### SSH Kitten Issues

**Terminfo not copying:**
```bash
# Manual terminfo copy
infocmp xterm-kitty | ssh user@host tic -x -o ~/.terminfo /dev/stdin
```

**Connection issues:**
```bash
# Use regular ssh
command ssh user@host

# Or disable alias temporarily
\ssh user@host
```

### Theme Issues

**Theme not applying:**
```bash
# Reload theme
Ctrl+Shift+F9
# Select theme again
# Press Enter

# Or from command line
kitty +kitten themes --reload-in=all Dracula
```

**Colors look wrong:**
- Check `term` setting (should be `xterm-kitty` or `xterm-256color`)
- Verify theme file exists: `~/.config/kitty/current-theme.conf`
- Test with default theme first

---

## Quick Reference

### Most Used Shortcuts

```
Copy/Paste:     Ctrl+Shift+C/V, Right-click
Search:         Ctrl+Shift+/
Prompt Jump:    Ctrl+Shift+Z/X
Panel:          F12
Theme:          Ctrl+Shift+F9
Transparency:   Ctrl+Equal/Minus
Split H/V:      Ctrl+Alt+H/V
Navigate:       Ctrl+Alt+Arrow
New Tab:        Ctrl+Shift+T
Reload Config:  Ctrl+Shift+F5
```

### Configuration Locations

```
Config:         ~/.config/kitty/kitty.conf
Theme:          ~/.config/kitty/current-theme.conf
Chezmoi:        dotfiles/dot_config/kitty/
Search Kitten:  ~/.config/kitty/kitty_search/
```

### Color Scheme (Dracula)

```
Background:     #282a36  (dark purple-gray)
Foreground:     #f8f8f2  (light gray)
Selection:      #44475a  (purple-gray)
Red:            #ff5555
Green:          #50fa7b
Yellow:         #f1fa8c
Blue:           #bd93f9
Magenta:        #ff79c6
Cyan:           #8be9fd
```

---

## Related Documentation

- **Tool Guide:** `docs/tools/kitty.md`
- **Enhancement Plans:** `docs/plans/kitty-*.md`
- **Session Summary:** `docs/sessions/summaries/01-12-2025_KITTY_KITTENS_PHASE_B_COMPLETION.md`
- **Testing Checklist:** `docs/sessions/summaries/KITTY_PHASE_B_TESTING_CHECKLIST.md`

**Official Resources:**
- Kitty Documentation: https://sw.kovidgoyal.net/kitty/
- Kittens Overview: https://sw.kovidgoyal.net/kitty/kittens_intro/
- Search Kitten: https://github.com/trygveaa/kitty-kitten-search
- Dracula Theme: https://draculatheme.com/kitty

---

**Maintained By:** Dimitris Tsioumas (Mitsio)
**Last Updated:** 2025-12-01
**Session:** kitty-configuration-phase2-continuation
**Status:** Phase B ✅ Complete | Phase C.1 ✅ Complete
