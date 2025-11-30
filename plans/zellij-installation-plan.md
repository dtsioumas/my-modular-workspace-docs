# Zellij Installation & Configuration Plan

**Created:** 2025-11-30
**Session:** kitty-configuration
**Dependencies:** None (independent)
**Time Estimate:** 45-60 minutes
**Risk Level:** LOW (new package, isolated config)

---

## Goal

Install zellij terminal multiplexer and configure it with Catppuccin Mocha theme to match kitty.

**What is Zellij?**
- Modern terminal multiplexer (like tmux, but better UX)
- Built in Rust (fast, reliable)
- Modal interface (vim-inspired)
- Beautiful UI with built-in status bar
- Session management (detach/reattach)
- Native layout system

**Deliverables:**
1. ✅ Zellij installed via home-manager
2. ✅ Basic config.kdl with Catppuccin Mocha theme
3. ✅ Default layout created
4. ✅ Configs managed via chezmoi
5. ✅ Verified working workflow

---

## Prerequisites

**Required:**
- ✅ Home-manager installed (standalone mode)
- ✅ Chezmoi managing dotfiles
- ✅ Working directory: `/home/mitsio/.MyHome/MySpaces/my-modular-workspace`

**Current State (Verified):**
- Zellij: NOT installed ❌
- Zellij config: Does not exist ❌

**Before Starting:**
```bash
# Check current home-manager generation (for rollback)
home-manager generations | head -n 3

# Verify home-manager flake
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
git status
```

---

## Phase 1: Install Zellij via Home-Manager

**Time:** 15-20 minutes

### Step 1.1: Create Zellij Nix Module

**Option A: Create Dedicated Module (Recommended)**

**File:** `home-manager/zellij.nix`

```nix
{ config, pkgs, ... }:

{
  # Install zellij terminal multiplexer
  # From nixpkgs-unstable (per ADR-001)
  home.packages = with pkgs; [
    zellij
  ];

  # Note: Configuration managed via chezmoi at ~/.config/zellij/
  # Zellij does not have a home-manager module like programs.zellij yet,
  # so we manage config files declaratively through chezmoi
}
```

**Then import in `home.nix`:**
```nix
imports = [
  # ... existing imports ...
  ./zellij.nix
];
```

**Option B: Add to Existing shell.nix**

If you have a `shell.nix` with `home.packages`, just add `zellij` to the list:
```nix
home.packages = with pkgs; [
  # ... existing packages ...
  zellij
];
```

### Step 1.2: Build and Apply Home-Manager

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager

# Build first (to check for errors)
home-manager build --flake .#mitsio@shoshin

# If build succeeds, apply
home-manager switch --flake .#mitsio@shoshin
```

**Expected Output:**
```
Starting Home Manager activation
...
Activating installAnsibleCollections
Activating ...
...
```

### Step 1.3: Verify Installation

```bash
# Check installation path
which zellij
# Expected: /nix/store/.../bin/zellij

# Check version
zellij --version
# Expected: zellij 0.XX.X (latest from nixpkgs-unstable)

# Test basic launch
zellij
# Should launch successfully with default config
# Exit with: Ctrl+Q
```

### Step 1.4: Commit Home-Manager Changes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager

git add zellij.nix home.nix  # or shell.nix
git commit -m "feat(zellij): Install zellij terminal multiplexer via home-manager

- Install zellij from nixpkgs-unstable (per ADR-001)
- Configuration will be managed via chezmoi
- Adds modern terminal multiplexing capabilities

Part of: kitty-configuration session"

git push origin main
```

---

## Phase 2: Create Zellij Configuration

**Time:** 30-40 minutes

### Step 2.1: Create Config Directory Structure

```bash
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.config/zellij/plugins
```

### Step 2.2: Create config.kdl (Main Configuration)

**File:** `~/.config/zellij/config.kdl`

```kdl
// Zellij Configuration
// Created: 2025-11-30 by Mitso
// Theme: Catppuccin Mocha (matches kitty)
// Managed via: chezmoi

// ============ THEME ============
theme "catppuccin-mocha"

// ============ UI SETTINGS ============
simplified_ui true       // Hide TMUX-style separators
pane_frames false        // No borders around panes (cleaner look)
default_shell "bash"     // Use bash as default shell
mouse_mode true          // Enable mouse support

// ============ SCROLLBACK ============
scroll_buffer_size 10000  // Lines to keep in scrollback

// ============ CLIPBOARD ============
// Wayland (KDE Plasma on shoshin)
copy_command "wl-copy"

// For X11 (uncomment if needed):
// copy_command "xclip -selection clipboard"

copy_on_select true      // Auto-copy selected text

// ============ SESSION BEHAVIOR ============
attach_to_session true        // Auto-attach to sessions
session_serialization false   // Don't serialize sessions (keep it simple)

// ============ KEYBINDINGS ============
// Using zellij defaults (vim-inspired modes):
//
// Modes:
//   Ctrl+P - Pane mode (create/close/navigate panes)
//   Ctrl+T - Tab mode (create/close/navigate tabs)
//   Ctrl+N - Resize mode (resize panes)
//   Ctrl+S - Scroll mode (scrollback, search, copy)
//   Ctrl+O - Session mode (detach, switch sessions)
//   Ctrl+H - Move mode (move panes/tabs)
//   Ctrl+G - Locked mode (disable all keybindings)
//   Ctrl+Q - Quit zellij
//
// Common operations:
//   Ctrl+P, N - New pane (split right)
//   Ctrl+P, D - New pane (split down)
//   Ctrl+P, X - Close focused pane
//   Ctrl+P, H/J/K/L - Navigate panes (vim-style)
//   Ctrl+T, N - New tab
//   Ctrl+T, R - Rename tab
//   Ctrl+T, X - Close tab
//   Ctrl+S, / - Search scrollback
//   Ctrl+O, D - Detach session
//
// Custom keybindings can be added later if needed

// ============ PLUGINS ============
// Plugins will be configured in zjstatus-integration-plan
// (Optional enhancement, not required for basic functionality)

// ============ MISC ============
// Auto-save layout on exit
auto_layout true

// Default layout to use
// default_layout "default"
```

**Save to:** `~/.config/zellij/config.kdl`

### Step 2.3: Create Default Layout

**File:** `~/.config/zellij/layouts/default.kdl`

```kdl
// Default Zellij Layout
// Simple single-pane layout with tab bar and status bar

layout {
    // Top: Tab bar (shows tabs)
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main content area (your shell runs here)
    pane {
        // Default shell pane
        // All your work happens here
    }

    // Bottom: Status bar (shows mode, keybindings)
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}

// This layout gives you:
// - Tab bar at top (for multiple tabs)
// - Main workspace in the middle
// - Status bar at bottom (shows current mode and hints)
//
// To use: zellij (automatically uses default layout)
// Or explicitly: zellij --layout default
```

**Save to:** `~/.config/zellij/layouts/default.kdl`

---

## Phase 3: Test Zellij

**Time:** 10-15 minutes

### Step 3.1: Launch Zellij

```bash
# Launch with default layout
zellij

# Or create/attach to named session
zellij attach -c test
```

### Step 3.2: Test Basic Operations

**Pane Management:**
```
Ctrl+P, N     # Create new pane (split right) ✅
Ctrl+P, D     # Create new pane (split down) ✅
Ctrl+P, H     # Focus pane left ✅
Ctrl+P, L     # Focus pane right ✅
Ctrl+P, J     # Focus pane down ✅
Ctrl+P, K     # Focus pane up ✅
Ctrl+P, X     # Close focused pane ✅
```

**Tab Management:**
```
Ctrl+T, N     # Create new tab ✅
Ctrl+T, R     # Rename tab (type name, Enter) ✅
Ctrl+T, H     # Previous tab ✅
Ctrl+T, L     # Next tab ✅
Ctrl+T, X     # Close current tab ✅
```

**Scrollback & Search:**
```
Ctrl+S        # Enter scroll mode ✅
↑/↓ or J/K    # Scroll up/down (in scroll mode) ✅
/             # Search (in scroll mode) ✅
N             # Next search result ✅
P             # Previous search result ✅
Space         # Start selection (in scroll mode) ✅
Enter         # Copy selection and exit (in scroll mode) ✅
Esc           # Exit scroll mode ✅
```

**Session Management:**
```
Ctrl+O, D     # Detach from session ✅
zellij attach test   # Reattach to session ✅
zellij list-sessions # List all sessions ✅
zellij delete-session test # Delete session ✅
```

**Exit:**
```
Ctrl+Q        # Quit zellij (closes session) ✅
```

### Step 3.3: Verify Theme

**Check Colors:**
- Background should be dark blue-gray (`#1e1e2e` - Catppuccin Mocha base)
- Text should be lavender-white (`#cdd6f4`)
- Mode indicator (top-right in status bar) should change colors
- Tab bar should match Catppuccin colors

**If theme not applied:**
```bash
# Verify config loaded
cat ~/.config/zellij/config.kdl | grep theme

# Reload zellij
# Exit (Ctrl+Q) and restart
```

---

## Phase 4: Add to Chezmoi

**Time:** 5 minutes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace

# Add zellij configs to chezmoi
chezmoi add ~/.config/zellij/config.kdl
chezmoi add ~/.config/zellij/layouts/default.kdl

# Verify additions
chezmoi status

# Should show:
#  A .config/zellij/config.kdl
#  A .config/zellij/layouts/default.kdl
```

---

## Phase 5: Commit Dotfiles Changes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

git add dot_config/zellij/
git commit -m "feat(zellij): Add zellij configuration with Catppuccin Mocha theme

- Add config.kdl with Catppuccin Mocha theme matching kitty
- Configure scrollback, clipboard (wl-copy for Wayland)
- Set simplified UI with clean borders
- Add default layout with tab bar and status bar
- Document all keybindings in config comments

Part of: kitty-configuration session"

git push origin main
```

---

## Rollback Plan

**If zellij installation fails:**

### Option 1: Home-Manager Rollback
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
git revert <commit-hash>
home-manager switch --flake .#mitsio@shoshin
```

### Option 2: Home-Manager Generation Rollback
```bash
# List generations
home-manager generations

# Activate previous generation
/nix/store/.../activate
```

**If config is broken:**
```bash
# Remove config
rm -rf ~/.config/zellij

# Remove from chezmoi
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git revert <commit-hash>
```

---

## Success Criteria

**This plan is complete when:**
- ✅ Zellij installed via home-manager (verified with `which zellij`)
- ✅ `zellij --version` works
- ✅ config.kdl exists with Catppuccin Mocha theme
- ✅ Default layout created
- ✅ All basic operations tested (panes, tabs, scrollback, sessions)
- ✅ Theme colors match kitty (Catppuccin Mocha)
- ✅ Configs added to chezmoi
- ✅ Changes committed to both home-manager and dotfiles repos
- ✅ User (Mitsio) can create, navigate, and detach sessions successfully

**Checkpoint:** After this plan, you have a **fully working terminal multiplexer** ready to use!

---

## Next Steps

After completing this plan, you can:

1. **Use zellij immediately** - Works standalone, no further setup needed
2. **Optional: Install zjstatus** - Beautiful status bar (see `zjstatus-integration-plan.md`)
3. **Optional: Create custom layouts** - Dev, ops, etc. (see `advanced-features-plan.md`)
4. **Optional: Auto-launch in kitty** - Start zellij automatically (see `advanced-features-plan.md`)

---

## Reference

**Files Created:**
- `home-manager/zellij.nix`
- `dotfiles/dot_config/zellij/config.kdl`
- `dotfiles/dot_config/zellij/layouts/default.kdl`

**Related Documentation:**
- Zellij Official Docs: https://zellij.dev/documentation/
- Zellij Configuration: https://zellij.dev/documentation/configuration
- Catppuccin Zellij Theme: https://github.com/catppuccin/zellij
- Session Research: `sessions/kitty-configuration/RESEARCH_FINDINGS.md`
- Tool Documentation: `docs/tools/zellij.md`

---

**End of Zellij Installation Plan**

This creates a stable, working terminal multiplexer baseline. Proceed! 🚀
