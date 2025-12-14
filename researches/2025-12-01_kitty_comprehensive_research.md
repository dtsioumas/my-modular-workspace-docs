# Kitty + Zellij Configuration Research Findings

**Session Date:** 2025-11-30
**Status:** Research Complete
**Next Steps:** Documentation & Implementation Planning

---

## Executive Summary

Research completed on configuring kitty terminal emulator with:
- ✅ Beautiful themes (Dracula vs Catppuccin Mocha)
- ✅ Transparency and visual enhancements
- ✅ Mouse right-click and improved copy-paste
- ✅ Ctrl+Alt+Arrow window navigation
- ✅ Zellij terminal multiplexer integration
- ✅ zjstatus beautiful status bar plugin

**Current State:** Kitty already configured with Catppuccin Mocha theme, transparency, and basic functionality via chezmoi.

**Goal:** Enhance kitty with zellij integration and improved shortcuts for better terminal workflow.

---

## 1. Kitty Terminal Aesthetics & Themes

### Current Theme: Catppuccin Mocha ✅

**Location:** `dotfiles/dot_config/kitty/current-theme.conf`

The current configuration already uses Catppuccin Mocha, a modern, soothing pastel theme with excellent color contrast.

**Characteristics:**
- **Background:** `#1e1e2e` (dark blue-gray)
- **Foreground:** `#cdd6f4` (light lavender-white)
- **16 ANSI colors** optimized for readability
- **Transparency:** `background_opacity 0.95` ✅
- **Blur:** `background_blur 32` (requires compositor support - KDE Plasma compatible) ✅

### Dracula Theme Alternative

**Comparison:**

| Feature | Catppuccin Mocha (Current) | Dracula |
|---------|---------------------------|---------|
| Background | `#1e1e2e` (blue-tinted dark) | `#282a36` (gray-tinted dark) |
| Foreground | `#cdd6f4` (lavender) | `#f8f8f2` (off-white) |
| Visual Style | Pastel, soft | Bold, vibrant |
| Eye Strain | Lower (softer colors) | Higher (high contrast) |
| Popularity | Growing (2023+) | Established (2016+) |

**Recommendation:** **Keep Catppuccin Mocha**
- Already configured and working well
- Better for long coding sessions (softer on eyes)
- Modern aesthetic matching KDE Plasma
- User said "dracula or the other" - Catppuccin IS "the other"!

### Transparency Configuration ✅

**Already Configured:**
```conf
background_opacity 0.95          # 95% opacity (5% transparent)
dynamic_background_opacity yes   # Can adjust on-the-fly
background_blur 32               # Blur background (KDE/GNOME/Hyprland)
```

**Keyboard Shortcuts (already configured):**
- `Ctrl+Shift+A+M`: Increase opacity (+0.05)
- `Ctrl+Shift+A+L`: Decrease opacity (-0.05)
- `Ctrl+Shift+A+1`: Full opacity (1.0)
- `Ctrl+Shift+A+D`: Default opacity

---

## 2. Mouse Right-Click & Copy-Paste

### Current Configuration

**Clipboard Settings (already configured):**
```conf
copy_on_select yes  # Auto-copy when selecting text
strip_trailing_spaces smart
clipboard_control write-clipboard write-primary read-clipboard-ask read-primary-ask
```

**Current Shortcuts:**
- `Ctrl+Shift+C`: Copy to clipboard
- `Ctrl+Shift+V`: Paste from clipboard
- `Shift+Insert`: Paste from selection (X11 primary selection)

### Enhancements Needed

#### 1. Enable Right-Click Paste

**Add to kitty.conf:**
```conf
# Right-click paste from clipboard
mouse_map right press ungrabbed paste_from_clipboard
```

This enables traditional right-click → paste behavior like most GUI terminals.

#### 2. Optional: Map Ctrl+C/Ctrl+V (if desired)

**Trade-off Warning:** This conflicts with terminal programs that use Ctrl+C (interrupt signal).

**Solution:** Use `copy_or_interrupt` action:
```conf
map ctrl+c copy_or_interrupt   # Copy if selection exists, otherwise send Ctrl+C
map ctrl+v paste_from_clipboard
```

**Recommendation:** **Keep current Ctrl+Shift+C/V** for safety. Only add right-click paste.

#### 3. Middle-Click Paste (X11 Primary Selection)

Already works by default in X11:
- Select text with mouse → auto-copied to primary selection
- Middle-click → paste from primary selection

---

## 3. Window Navigation with Ctrl+Alt+Arrow Keys

### Current Configuration

**Window Management (already configured):**
```conf
# Window navigation (Ctrl+Shift+] and [)
map ctrl+shift+] next_window
map ctrl+shift+[ previous_window
```

**Split Window Creation:**
```conf
map ctrl+alt+enter   launch --location=hsplit --cwd=current   # Horizontal split
map alt+shift+enter  launch --location=vsplit --cwd=current   # Vertical split
```

### Enhancement: Add Ctrl+Alt+Arrow Navigation

**Research Findings:**
- Kitty supports `neighboring_window` action for directional navigation
- Can change `kitty_mod` to `ctrl+alt` for easier access
- Arrow keys: `left`, `right`, `up`, `down`

**Configuration to Add:**
```conf
# Window navigation with Ctrl+Alt+Arrow keys
map ctrl+alt+left neighboring_window left
map ctrl+alt+right neighboring_window right
map ctrl+alt+up neighboring_window up
map ctrl+alt+down neighboring_window down
```

**Alternative Approach (rebind kitty_mod):**
```conf
# Change kitty_mod from ctrl+shift to ctrl+alt
kitty_mod ctrl+alt

# Then use kitty_mod+arrow for navigation
map kitty_mod+left neighboring_window left
map kitty_mod+right neighboring_window right
map kitty_mod+up neighboring_window up
map kitty_mod+down neighboring_window down
```

**Recommendation:** **Add explicit Ctrl+Alt+Arrow bindings** without changing `kitty_mod`. This preserves existing `Ctrl+Shift` shortcuts and adds new ones.

---

## 4. Zellij Terminal Multiplexer

### What is Zellij?

**Official Description:** "A terminal workspace with batteries included"

**Key Features:**
- **Terminal Multiplexer** (like tmux, but modern)
- **Native Layout System** with YAML configuration
- **Plugin System** (Rust-based WebAssembly plugins)
- **Beautiful UI** with configurable status bar
- **Session Management** (attach/detach)
- **Pane/Tab Management** with intuitive keybindings
- **Scrollback Search** built-in
- **Copy Mode** (vim-like)

### Why Zellij Over tmux?

| Feature | Zellij | tmux |
|---------|--------|------|
| Configuration | YAML (declarative) | tmux.conf (imperative) |
| UI/Status Bar | Built-in, customizable | Requires plugins (tmux-powerline) |
| Plugin System | Rust/WASM (sandboxed) | Shell scripts (slower) |
| Learning Curve | Easier (modes, on-screen hints) | Steeper (memorize keybindings) |
| Performance | Fast (Rust) | Fast (C) |
| Floating Panes | Yes ✅ | No ❌ |
| Session Switching | Fuzzy finder built-in | Manual or with fzf |
| Default Keybindings | Intuitive, modal | Prefix-based (Ctrl+B) |

**Verdict:** Zellij is more beginner-friendly, has better defaults, and requires less configuration.

### Installation via Home-Manager

**Method 1: Simple Package Installation**
```nix
# home-manager/home.nix or shell.nix
home.packages = with pkgs; [
  zellij
];
```

**Method 2: Using programs.zellij Module (Declarative)**
```nix
programs.zellij = {
  enable = true;
  # Optional: enable shell integration
  enableBashIntegration = true;
  enableZshIntegration = true;
};
```

**Recommendation:** Use **Method 1** for now (simpler). Configuration will be managed via chezmoi.

### Default Keybindings

**Modes (inspired by vim):**
- **Normal Mode** (default): Switch modes, quick nav
- **Pane Mode** (`Ctrl+P`): Create, close, navigate panes
- **Tab Mode** (`Ctrl+T`): Create, close, navigate tabs
- **Resize Mode** (`Ctrl+N`): Resize panes
- **Scroll Mode** (`Ctrl+S`): Scroll, search scrollback
- **Session Mode** (`Ctrl+O`): Detach, manage sessions
- **Locked Mode** (`Ctrl+G`): Disable all keybindings

**Common Operations:**
- `Ctrl+P, N`: New pane (split right)
- `Ctrl+P, D`: New pane (split down)
- `Ctrl+P, X`: Close focused pane
- `Ctrl+P, H/J/K/L`: Focus pane (vim-like navigation)
- `Ctrl+T, N`: New tab
- `Ctrl+T, X`: Close tab
- `Ctrl+T, H/L`: Previous/Next tab

**Exit Zellij:** `Ctrl+Q` (in normal mode)

### Configuration Location

**Via chezmoi:**
```
dotfiles/dot_config/zellij/
├── config.kdl          # Main configuration (KDL format)
└── layouts/            # Custom layouts
    └── default.kdl
```

**KDL Format Example:**
```kdl
// ~/.config/zellij/config.kdl
theme "catppuccin-mocha"  // Match kitty theme!

// Keybindings, UI, behavior
simplified_ui true
pane_frames false
default_shell "bash"
```

---

## 5. zjstatus - Beautiful Status Bar for Zellij

### What is zjstatus?

**GitHub:** https://github.com/dj95/zjstatus

**Description:** A highly customizable statusbar plugin for Zellij.

**Features:**
- **Modular Design:** Individual widgets (clock, battery, CPU, mode, session)
- **Nerd Font Support:** Icons for visual appeal
- **Color Customization:** Match your theme (Catppuccin, Dracula, Nord, etc.)
- **Format Strings:** Printf-style templates
- **Multiple Sections:** Left, center, right alignment
- **Responsive:** Shows/hides based on available space

### Example Configuration

**Location:** `~/.config/zellij/config.kdl`

```kdl
// Load zjstatus plugin
plugins {
    zjstatus location="file:~/.config/zellij/plugins/zjstatus.wasm" {
        format_left  "{mode}#[bg=#1e1e2e] {tabs}"
        format_center "{session}"
        format_right "#[bg=#1e1e2e,fg=#cba6f7] {datetime}"
        format_space "#[bg=#1e1e2e]"

        mode_normal        "#[bg=#a6e3a1,fg=#1e1e2e,bold] NORMAL "
        mode_locked        "#[bg=#f38ba8,fg=#1e1e2e,bold] LOCKED "
        mode_pane          "#[bg=#89b4fa,fg=#1e1e2e,bold] PANE "
        mode_tab           "#[bg=#f9e2af,fg=#1e1e2e,bold] TAB "
        mode_resize        "#[bg=#cba6f7,fg=#1e1e2e,bold] RESIZE "
        mode_scroll        "#[bg=#94e2d5,fg=#1e1e2e,bold] SCROLL "
        mode_session       "#[bg=#fab387,fg=#1e1e2e,bold] SESSION "

        tab_normal         "#[bg=#181825,fg=#cdd6f4] {index} {name} "
        tab_active         "#[bg=#cba6f7,fg=#1e1e2e,bold] {index} {name} "

        datetime           "#[fg=#cdd6f4] {format} "
        datetime_format    "%a %d/%m %H:%M"
        datetime_timezone  "Europe/Athens"
    }
}
```

**Colors from Catppuccin Mocha:**
- `#1e1e2e`: Background (base)
- `#cdd6f4`: Foreground (text)
- `#a6e3a1`: Green (normal mode)
- `#f38ba8`: Red (locked mode)
- `#89b4fa`: Blue (pane mode)
- `#f9e2af`: Yellow (tab mode)
- `#cba6f7`: Mauve (resize/active tab)

### Installation

1. **Download zjstatus plugin:**
```bash
mkdir -p ~/.config/zellij/plugins
curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm \
  -o ~/.config/zellij/plugins/zjstatus.wasm
```

2. **Configure in `config.kdl`** (see example above)

3. **Restart zellij** or reload config (`Ctrl+O, R`)

---

## 6. Kitty + Zellij Integration

### How They Work Together

**Architecture:**
```
┌─────────────────────────────────────┐
│   Kitty Terminal Emulator           │  ← Handles rendering, GPU acceleration
│   (manages: fonts, colors, opacity) │  ← Processes keyboard/mouse input
│                                     │  ← Provides transparency, blur
├─────────────────────────────────────┤
│         Zellij Session              │  ← Handles multiplexing (panes/tabs)
│   (manages: layouts, sessions)      │  ← Session persistence (detach/attach)
│                                     │  ← Status bar, plugins
├─────────────────────────────────────┤
│      Shell (bash/zsh)               │  ← Your working environment
│      Running: vim, git, etc         │
└─────────────────────────────────────┘
```

**Division of Responsibilities:**
- **Kitty:** Terminal emulator (rendering, themes, fonts, shortcuts)
- **Zellij:** Terminal multiplexer (windows, tabs, sessions, layouts)
- **Benefits:** Best of both worlds - beautiful rendering + powerful multiplexing

### Auto-Launch Zellij in Kitty

**Method 1: Startup Session (Recommended for this project)**

Create `~/.config/kitty/launch.conf`:
```conf
# Auto-launch zellij
launch --type=os-window zellij attach -c default
```

Then reference in `kitty.conf`:
```conf
startup_session launch.conf
```

**Method 2: Shell Integration**

Add to `~/.bashrc` or `~/.zshrc`:
```bash
# Auto-start zellij if not already inside
if [ -z "$ZELLIJ" ]; then
    zellij attach -c default
fi
```

**Method 3: Alias/Manual**
```bash
alias tj="zellij attach -c default"  # tj = "terminal job" or "tmux-like join"
```

**Recommendation:** Use **Method 3** (alias) initially to test. Migrate to Method 1 after confirming workflow.

### Kitty Window Management vs Zellij

**Decision Point:** Use Kitty windows/tabs OR Zellij panes/tabs?

**Recommendation:** **Use Zellij for all pane/tab management:**

**Rationale:**
- **Consistency:** One mental model for splitting/navigation
- **Session Persistence:** Can detach/reattach Zellij (survives kitty crashes)
- **Layouts:** Zellij layouts are more powerful than kitty sessions
- **Status Bar:** zjstatus provides context-aware status

**Keep Kitty Features:**
- Transparency, blur, fonts, themes
- Copy/paste, scrollback
- Right-click paste (new addition)
- Opening new OS windows (`Super+Enter`)

**Disable Kitty Tabs/Splits (Optional):**
```conf
# Disable kitty native tabs (use zellij instead)
map ctrl+shift+t no_op  # Unbind new tab
map ctrl+shift+w no_op  # Unbind close tab

# Disable kitty window splits (use zellij instead)
map ctrl+alt+enter no_op    # Unbind horizontal split
map alt+shift+enter no_op   # Unbind vertical split
```

**Or keep them** for rare cases when you want multiple independent zellij sessions.

---

## 7. Summary of Enhancements

### Kitty Configuration Changes

**File:** `dotfiles/dot_config/kitty/kitty.conf`

**Additions:**
1. ✅ **Right-click paste:**
   ```conf
   mouse_map right press ungrabbed paste_from_clipboard
   ```

2. ✅ **Ctrl+Alt+Arrow window navigation:**
   ```conf
   map ctrl+alt+left neighboring_window left
   map ctrl+alt+right neighboring_window right
   map ctrl+alt+up neighboring_window up
   map ctrl+alt+down neighboring_window down
   ```

3. 🤔 **Optional: Auto-launch zellij:**
   ```conf
   # Create startup_session.conf with:
   # launch zellij attach -c default
   startup_session launch.conf
   ```

**NO CHANGES NEEDED:**
- Theme (Catppuccin Mocha is excellent)
- Transparency (already configured)
- Copy/paste shortcuts (already configured)

### Zellij Installation

**Method:** Home-Manager

**File:** `home-manager/home.nix` or new `home-manager/zellij.nix`

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];
}
```

### Zellij Configuration via Chezmoi

**Files to create:**
```
dotfiles/dot_config/zellij/
├── config.kdl                    # Main config (theme, UI, keybindings)
├── layouts/
│   ├── default.kdl              # Default layout
│   ├── dev.kdl                  # Development layout (code + terminal)
│   └── ops.kdl                  # SRE layout (monitoring + logs + shell)
└── plugins/
    └── zjstatus.wasm            # Status bar plugin
```

### zjstatus Installation

**Steps:**
1. Download plugin WASM file
2. Configure in `config.kdl`
3. Customize colors to match Catppuccin Mocha

---

## 8. Next Steps / Implementation Plan

### Phase 1: Kitty Enhancements (30-45 min)

1. **Update kitty.conf via chezmoi:**
   - Add right-click paste
   - Add Ctrl+Alt+Arrow navigation
   - Test changes with `chezmoi apply`

2. **Verify functionality:**
   - Test right-click paste
   - Test window navigation with arrows
   - Ensure existing shortcuts still work

3. **Commit changes to dotfiles repo**

### Phase 2: Zellij Installation (15-20 min)

1. **Add zellij to home-manager:**
   - Edit `home-manager/home.nix` or create `zellij.nix`
   - Run `home-manager switch`
   - Verify: `which zellij` → `/nix/store/.../bin/zellij`

2. **Test basic zellij:**
   - Run `zellij`
   - Try keybindings (`Ctrl+P, N` for new pane, etc.)
   - Detach with `Ctrl+O, D`
   - Reattach with `zellij attach`

### Phase 3: Zellij Configuration (45-60 min)

1. **Create basic config.kdl:**
   - Theme: catppuccin-mocha
   - Simplified UI
   - Custom keybindings (if desired)

2. **Add to chezmoi:**
   - `chezmoi add ~/.config/zellij/config.kdl`
   - Test: `chezmoi apply`

3. **Create default layout:**
   - Simple 2-pane layout (editor + terminal)
   - Add to layouts/

4. **Commit to dotfiles repo**

### Phase 4: zjstatus Setup (30-45 min)

1. **Download plugin:**
   ```bash
   mkdir -p ~/.config/zellij/plugins
   curl -L <latest-release-url> -o ~/.config/zellij/plugins/zjstatus.wasm
   ```

2. **Configure zjstatus in config.kdl:**
   - Add plugin block with Catppuccin colors
   - Set datetime timezone to "Europe/Athens"
   - Format: mode + tabs (left), session (center), datetime (right)

3. **Test and refine:**
   - Reload zellij config
   - Adjust colors/format as needed

4. **Add to chezmoi and commit**

### Phase 5: Integration & Documentation (30 min)

1. **Update project documentation:**
   - `docs/commons/integrations/kitty-zellij-integration.md`
   - `docs/commons/toolbox/zellij/README.md`

2. **Create navi cheatsheets:**
   - `dotfiles/dot_local/share/navi/cheats/zellij.cheat`
   - `dotfiles/dot_local/share/navi/cheats/kitty.cheat` (update)

3. **Test full workflow:**
   - Open kitty
   - Launch zellij
   - Create panes/tabs
   - Test all shortcuts
   - Verify status bar

4. **Final commits across repos:**
   - dotfiles
   - home-manager
   - docs

---

## 9. Reference Links

### Official Documentation
- **Kitty:** https://sw.kovidgoyal.net/kitty/
  - Conf Reference: https://sw.kovidgoyal.net/kitty/conf/
  - Actions: https://sw.kovidgoyal.net/kitty/actions/
  - Keyboard Protocol: https://sw.kovidgoyal.net/kitty/keyboard-protocol/

- **Zellij:** https://zellij.dev/
  - Configuration: https://zellij.dev/documentation/configuration
  - Layouts: https://zellij.dev/documentation/layouts
  - Plugins: https://zellij.dev/documentation/plugins

- **zjstatus:** https://github.com/dj95/zjstatus
  - Examples: https://github.com/dj95/zjstatus/discussions/44

### Themes
- **Catppuccin Kitty:** https://github.com/catppuccin/kitty
- **Catppuccin Zellij:** https://github.com/catppuccin/zellij

### NixOS / Home-Manager
- **Home-Manager Manual:** https://home-manager.dev/manual/
- **Zellij on nixpkgs:** https://search.nixos.org/packages?query=zellij

---

## 10. Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Theme** | Keep Catppuccin Mocha | Already configured, modern, softer on eyes |
| **Transparency** | Keep 0.95 opacity | Already configured, good balance |
| **Right-Click** | Enable paste_from_clipboard | Standard GUI behavior, user-friendly |
| **Copy Shortcuts** | Keep Ctrl+Shift+C/V | Safer than Ctrl+C/V (no terminal conflicts) |
| **Window Nav** | Add Ctrl+Alt+Arrow | User-requested, intuitive |
| **Multiplexer** | Use Zellij | Modern, better UX than tmux, good defaults |
| **Status Bar** | Use zjstatus | Beautiful, customizable, Catppuccin support |
| **Installation** | Home-Manager | Declarative, reproducible, version controlled |
| **Configuration** | Chezmoi | Dotfiles already managed there |
| **Auto-Launch** | Manual/Alias (initially) | Test workflow before automating |

---

**End of Research Findings**

Next: Create comprehensive implementation plan.
