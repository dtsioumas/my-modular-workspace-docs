# Zellij - Terminal Workspace

**Official Site:** https://zellij.dev/
**GitHub:** https://github.com/zellij-org/zellij
**Status:** Active, Installed via Home-Manager
**Version:** Latest (from nixpkgs-unstable)

---

## What is Zellij?

Zellij is a terminal workspace (multiplexer) with batteries included. It's a modern alternative to tmux, designed for developer productivity.

**Tagline:** "A terminal workspace with batteries included"

---

## Key Features

### 1. Terminal Multiplexing
- **Panes:** Split terminal into multiple panes
- **Tabs:** Organize panes into tabs
- **Sessions:** Persist workspaces (detach/reattach)
- **Layouts:** Define workspace arrangements

### 2. Modern UX
- **Modal Interface:** Vim-inspired modes (normal, pane, tab, etc.)
- **On-Screen Hints:** Shows available keybindings
- **Fuzzy Finding:** Built-in session/tab switching
- **Floating Panes:** Temporary overlays for quick tasks

### 3. Plugin System
- **Rust/WebAssembly:** Fast, sandboxed plugins
- **Official Plugins:** Status bar, file browser, session manager
- **Community Plugins:** zjstatus (beautiful status bars)

### 4. Developer-Friendly
- **KDL Configuration:** Human-readable config format
- **Sensible Defaults:** Works great out of the box
- **Scrollback Search:** Vim-like search in scrollback
- **Copy Mode:** Keyboard-driven text selection

---

## Installation

### Via Home-Manager (Current Method)

**File:** `home-manager/zellij.nix` or `home-manager/home.nix`

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];
}
```

**Apply:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin
```

**Verify:**
```bash
which zellij
# /nix/store/.../bin/zellij

zellij --version
# zellij 0.XX.X
```

---

## Configuration

### Location

**Managed by chezmoi:**
```
dotfiles/dot_config/zellij/
├── config.kdl              # Main configuration
├── layouts/
│   ├── default.kdl        # Default layout
│   ├── dev.kdl            # Development layout
│   └── ops.kdl            # SRE/Ops layout
└── plugins/
    └── zjstatus.wasm      # Status bar plugin
```

**Applied to:**
```
~/.config/zellij/
```

### Basic Configuration

**File:** `config.kdl`

```kdl
// Theme
theme "catppuccin-mocha"

// UI Settings
simplified_ui true
pane_frames false
default_shell "bash"
mouse_mode true

// Scrollback
scroll_buffer_size 10000

// Copy behavior
copy_command "wl-copy"  // Wayland
// copy_command "xclip -selection clipboard"  // X11

// Plugins
plugins {
    zjstatus location="file:~/.config/zellij/plugins/zjstatus.wasm" {
        // zjstatus configuration (see zjstatus section)
    }
}
```

---

## Basic Usage

### Starting Zellij

**Create or attach to session:**
```bash
zellij attach -c default        # Attach to "default" or create it
zellij attach -c myproject      # Project-specific session
zellij                          # Start unnamed session
```

**With layout:**
```bash
zellij --layout dev attach -c myproject
```

### Session Management

```bash
# List sessions
zellij list-sessions

# Attach to existing session
zellij attach mysession

# Delete session
zellij delete-session mysession

# Detach from current session
# Inside zellij: Ctrl+O, D
```

### Exiting Zellij

```bash
# Quit (closes session)
# Inside zellij: Ctrl+Q

# Or detach (keeps session running)
# Inside zellij: Ctrl+O, D
```

---

## Keybindings

### Modes

Zellij uses modal interface (like vim):

| Mode | Key | Purpose |
|------|-----|---------|
| **Normal** | (default) | Navigate modes, quick actions |
| **Locked** | `Ctrl+G` | Disable all keybindings (passthrough) |
| **Pane** | `Ctrl+P` | Pane management |
| **Tab** | `Ctrl+T` | Tab management |
| **Resize** | `Ctrl+N` | Resize panes |
| **Scroll** | `Ctrl+S` | Scrollback and search |
| **Session** | `Ctrl+O` | Session management |
| **Move** | `Ctrl+H` | Move panes/tabs |

**Return to Normal:** `Esc` key

### Pane Mode (Ctrl+P)

| Key | Action |
|-----|--------|
| `N` | New pane (split right) |
| `D` | New pane (split down) |
| `X` | Close focused pane |
| `F` | Toggle fullscreen |
| `H` / `←` | Focus pane left |
| `L` / `→` | Focus pane right |
| `J` / `↓` | Focus pane down |
| `K` / `↑` | Focus pane up |
| `P` | Focus previous pane |
| `N` | Focus next pane |

### Tab Mode (Ctrl+T)

| Key | Action |
|-----|--------|
| `N` | New tab |
| `X` | Close current tab |
| `R` | Rename tab |
| `H` / `←` | Previous tab |
| `L` / `→` | Next tab |
| `1-9` | Go to tab number |
| `Tab` | Toggle tab |

### Scroll Mode (Ctrl+S)

| Key | Action |
|-----|--------|
| `↑` / `K` | Scroll up |
| `↓` / `J` | Scroll down |
| `Page Up` / `U` | Page up |
| `Page Down` / `D` | Page down |
| `/` | Search |
| `N` | Next search result |
| `P` | Previous search result |
| `Space` | Start selection |
| `Enter` | Copy selection and exit |
| `Esc` | Exit scroll mode |

### Session Mode (Ctrl+O)

| Key | Action |
|-----|--------|
| `D` | Detach session |
| `W` | Session manager (list sessions) |

### Quick Actions (Normal Mode)

| Key | Action |
|-----|--------|
| `Ctrl+Q` | Quit zellij |
| `Alt+N` | New pane (right) |
| `Alt+H/J/K/L` | Focus pane (vim-like) |
| `Alt+←/→/↑/↓` | Focus pane (arrows) |
| `Alt+[/]` | Previous/next tab |
| `Alt+1-9` | Go to tab number |

---

## Layouts

### What are Layouts?

Layouts define the initial arrangement of panes and tabs in a session.

**Use Cases:**
- **Dev Layout:** Editor + terminal + git
- **SRE Layout:** Logs + metrics + terminal
- **Debug Layout:** Debugger + logs + code

### Default Layout

**File:** `~/.config/zellij/layouts/default.kdl`

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }
    pane {
        // Main pane (full screen by default)
    }
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

### Development Layout Example

**File:** `~/.config/zellij/layouts/dev.kdl`

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main workspace
    pane split_direction="vertical" {
        // Editor (left side, 70% width)
        pane size="70%" {
            command "nvim"
            args "."
        }

        // Right side (30% width)
        pane split_direction="horizontal" {
            // Terminal (top-right, 70% height)
            pane size="70%"

            // Git status (bottom-right, 30% height)
            pane size="30%" {
                command "git"
                args "status" "-sb"
            }
        }
    }

    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

**Usage:**
```bash
zellij --layout dev attach -c myproject
```

### SRE/Ops Layout Example

**File:** `~/.config/zellij/layouts/ops.kdl`

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    pane split_direction="horizontal" {
        // Logs (top half)
        pane size="50%" {
            command "journalctl"
            args "-f" "-n" "100"
        }

        // Bottom half
        pane size="50%" split_direction="vertical" {
            // System monitor (left)
            pane size="50%" {
                command "htop"
            }

            // Shell (right)
            pane size="50%"
        }
    }

    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

---

## zjstatus Plugin

### What is zjstatus?

A highly customizable status bar plugin for Zellij.

**GitHub:** https://github.com/dj95/zjstatus

**Features:**
- Modular widgets (mode, tabs, session, clock, battery, CPU, etc.)
- Format strings for customization
- Nerd Font icon support
- Theme integration (Catppuccin, Dracula, Nord, etc.)

### Installation

```bash
mkdir -p ~/.config/zellij/plugins
curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm \
  -o ~/.config/zellij/plugins/zjstatus.wasm
```

**Add to chezmoi:**
```bash
chezmoi add ~/.config/zellij/plugins/zjstatus.wasm
```

### Configuration

**In `config.kdl`:**

```kdl
plugins {
    zjstatus location="file:~/.config/zellij/plugins/zjstatus.wasm" {
        // Layout: [mode + tabs]  [session]  [datetime]
        format_left   "{mode}#[bg=#1e1e2e] {tabs}"
        format_center "{session}"
        format_right  "#[bg=#1e1e2e,fg=#cba6f7] {datetime}"
        format_space  "#[bg=#1e1e2e]"

        // Mode indicators (Catppuccin Mocha colors)
        mode_normal   "#[bg=#a6e3a1,fg=#1e1e2e,bold] NORMAL "
        mode_locked   "#[bg=#f38ba8,fg=#1e1e2e,bold] LOCKED "
        mode_pane     "#[bg=#89b4fa,fg=#1e1e2e,bold] PANE "
        mode_tab      "#[bg=#f9e2af,fg=#1e1e2e,bold] TAB "
        mode_resize   "#[bg=#cba6f7,fg=#1e1e2e,bold] RESIZE "
        mode_scroll   "#[bg=#94e2d5,fg=#1e1e2e,bold] SCROLL "
        mode_session  "#[bg=#fab387,fg=#1e1e2e,bold] SESSION "

        // Tab formatting
        tab_normal    "#[bg=#181825,fg=#cdd6f4] {index} {name} "
        tab_active    "#[bg=#cba6f7,fg=#1e1e2e,bold] {index} {name} "

        // Date/time
        datetime           "#[fg=#cdd6f4] {format} "
        datetime_format    "%a %d/%m %H:%M"
        datetime_timezone  "Europe/Athens"
    }
}
```

**Color Palette (Catppuccin Mocha):**
- `#1e1e2e` - base (background)
- `#cdd6f4` - text
- `#a6e3a1` - green
- `#f38ba8` - red
- `#89b4fa` - blue
- `#f9e2af` - yellow
- `#cba6f7` - mauve/purple
- `#94e2d5` - teal
- `#fab387` - peach

---

## Common Workflows

### Workflow 1: Development Session

```bash
# Start dev session
zellij --layout dev attach -c myproject

# Inside zellij:
# - Editor is open in left pane
# - Terminal in top-right
# - Git status in bottom-right

# Work in editor (left pane)
# Run commands in terminal (top-right)
# Check git status (bottom-right)

# Create new tab for testing
# Ctrl+T, N

# Detach when done
# Ctrl+O, D
```

### Workflow 2: Multi-Project Session

```bash
# Create tabs for different projects
zellij attach -c work

# Inside zellij:
# Tab 1: Project A (Ctrl+T, R to rename "proj-a")
# Tab 2: Project B (Ctrl+T, N, rename "proj-b")
# Tab 3: Infrastructure (Ctrl+T, N, rename "infra")

# Switch between tabs:
# Alt+1, Alt+2, Alt+3
# or Ctrl+T, H/L
```

### Workflow 3: SRE Monitoring

```bash
# Start ops layout
zellij --layout ops attach -c monitoring

# Inside zellij:
# Top pane: journalctl -f (logs)
# Bottom-left: htop (system monitor)
# Bottom-right: shell (commands)

# Watch logs in real-time
# Check system resources
# Run diagnostic commands
```

---

## Tips & Tricks

### 1. Rename Tabs for Context

```
# In tab mode (Ctrl+T)
R → Type name → Enter
```

**Example Names:**
- "nvim-api" - Editing API code
- "k8s-prod" - Production Kubernetes
- "logs" - Log monitoring
- "test" - Testing/experiments

### 2. Use Floating Panes for Quick Tasks

```
# Ctrl+P, W → Create floating pane
# Do quick task
# Ctrl+P, X → Close floating pane
```

**Use Cases:**
- Quick file look-up
- Running one-off commands
- Temporary calculations

### 3. Search Scrollback Efficiently

```
# Ctrl+S (scroll mode)
# / → Type search term
# N → Next result
# P → Previous result
```

### 4. Copy from Scrollback

```
# Ctrl+S (scroll mode)
# Space → Start selection (move with arrows)
# Enter → Copy and exit
```

### 5. Session Naming Convention

```
# Project sessions
zellij attach -c proj-<name>

# Work vs personal
zellij attach -c work-<context>
zellij attach -c personal-<task>

# Examples:
zellij attach -c proj-api
zellij attach -c work-k8s
zellij attach -c personal-configs
```

---

## Troubleshooting

### Issue: Zellij won't start

```bash
# Check installation
which zellij
zellij --version

# Reinstall if needed
home-manager switch --flake .#mitsio@shoshin
```

### Issue: Configuration not loading

```bash
# Check config syntax
zellij setup --check

# View effective config
zellij setup --dump-config

# Check config location
ls -lh ~/.config/zellij/config.kdl
```

### Issue: Plugins not loading

```bash
# Verify plugin file
ls -lh ~/.config/zellij/plugins/

# Check permissions
chmod 644 ~/.config/zellij/plugins/*.wasm

# Reload config
# Inside zellij: Ctrl+O, R
```

### Issue: Wrong colors/theme

```bash
# Check theme setting
grep theme ~/.config/zellij/config.kdl

# Should be:
# theme "catppuccin-mocha"

# Reload after fix
# Inside zellij: Ctrl+O, R
```

---

## Comparison with tmux

| Feature | Zellij | tmux |
|---------|--------|------|
| **Configuration** | KDL (declarative) | tmux.conf (imperative) |
| **Default UI** | Built-in status bar | Requires plugin |
| **Keybindings** | Modal (vim-like) | Prefix-based |
| **Floating Panes** | Yes ✅ | No ❌ |
| **Plugin System** | Rust/WASM | Shell scripts |
| **Session Manager** | Built-in fuzzy finder | Manual/fzf |
| **Scrollback** | Built-in search | Requires setup |
| **Learning Curve** | Easier (guided) | Steeper |
| **Performance** | Fast (Rust) | Fast (C) |
| **Maturity** | Newer (2021+) | Established (2007+) |

**Verdict:** Zellij is better for new users, better defaults, modern UX. tmux is battle-tested, more plugins/integrations.

---

## Resources

### Official Documentation
- **Website:** https://zellij.dev/
- **Documentation:** https://zellij.dev/documentation/
- **Layouts:** https://zellij.dev/documentation/layouts.html
- **Plugins:** https://zellij.dev/documentation/plugins.html

### Community
- **GitHub:** https://github.com/zellij-org/zellij
- **Discord:** https://discord.gg/CrUAFH3
- **Reddit:** r/zellij

### Plugins
- **zjstatus:** https://github.com/dj95/zjstatus
- **Plugin Examples:** https://zellij.dev/documentation/plugin-examples.html

### Themes
- **Catppuccin:** https://github.com/catppuccin/zellij
- **Theme Gallery:** https://zellij.dev/documentation/themes.html

---

## Related Documentation

- **Integration Guide:** `docs/commons/integrations/kitty-zellij-integration.md`
- **Kitty Docs:** `docs/commons/toolbox/kitty/`
- **Research:** `sessions/kitty-configuration/RESEARCH_FINDINGS.md`

---

**Last Updated:** 2025-11-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
