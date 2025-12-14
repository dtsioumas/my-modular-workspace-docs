# Kitty + Zellij Integration - Phase 1 Implementation Plan

**Created:** 2025-11-30
**Session:** kitty-configuration
**Status:** Ready for Implementation
**Estimated Time:** 2-3 hours total

---

## Executive Summary

This plan outlines the step-by-step implementation of kitty terminal enhancements and zellij integration based on completed research.

**Goals:**
1. ✅ Enhance kitty with mouse right-click paste and Ctrl+Alt+Arrow navigation
2. ✅ Install zellij via home-manager
3. ✅ Configure zellij with Catppuccin Mocha theme
4. ✅ Install and configure zjstatus beautiful status bar
5. ✅ Integrate everything via chezmoi
6. ✅ Document and test the complete workflow

**Current State:**
- Kitty: Configured with Catppuccin Mocha, transparency ✅
- Zellij: NOT installed ❌
- zjstatus: NOT installed ❌

**Target State:**
- Kitty: Enhanced with better shortcuts ✅
- Zellij: Installed and configured ✅
- zjstatus: Beautiful status bar ✅
- Full integration working ✅

---

## Prerequisites

**Required:**
- ✅ NixOS system (shoshin)
- ✅ Home-manager setup (standalone mode)
- ✅ Chezmoi installed and initialized
- ✅ Kitty terminal installed
- ✅ KeePassXC vault accessible

**Access:**
- ✅ Working directory: `/home/mitsio/.MyHome/MySpaces/my-modular-workspace`
- ✅ Dotfiles repo: `dotfiles/` (chezmoi source)
- ✅ Home-manager repo: `home-manager/`
- ✅ Docs repo: `docs/`

**Before Starting:**
1. Backup current kitty config: `cp ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.backup.$(date +%Y%m%d)`
2. Check home-manager status: `home-manager generations` (note current generation)
3. Ensure all repos are clean: `git status` in each repo

---

## Phase 1: Kitty Enhancements

**Goal:** Add right-click paste and Ctrl+Alt+Arrow navigation
**Time:** 30-45 minutes
**Risk:** Low (non-breaking changes)

### Step 1.1: Update Kitty Configuration

**Location:** `dotfiles/dot_config/kitty/kitty.conf`

**Changes to make:**

1. **Add right-click paste (add after mouse section):**
```conf
# ============ MOUSE ============
# ... existing mouse settings ...

# Right-click paste (Mitso addition 2025-11-30)
mouse_map right press ungrabbed paste_from_clipboard
```

2. **Add Ctrl+Alt+Arrow navigation (add after window management section):**
```conf
# ===== Window Management =====
# ... existing window management ...

# Directional window navigation with Ctrl+Alt+Arrow (Mitso addition 2025-11-30)
map ctrl+alt+left neighboring_window left
map ctrl+alt+right neighboring_window right
map ctrl+alt+up neighboring_window up
map ctrl+alt+down neighboring_window down
```

**Apply changes:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
chezmoi apply
```

### Step 1.2: Test Kitty Enhancements

**Test Checklist:**
- [ ] Right-click paste works (select text, right-click in another window)
- [ ] Ctrl+Alt+Arrow keys navigate between kitty windows
- [ ] Existing Ctrl+Shift+C/V still works
- [ ] Transparency still works (Ctrl+Shift+A, M/L)
- [ ] Theme colors unchanged

**If issues:**
- Reload kitty config: `Ctrl+Shift+F5`
- Or restart kitty
- Check config syntax: `kitty --debug-config`

### Step 1.3: Commit Kitty Changes

**In dotfiles repo:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git add dot_config/kitty/kitty.conf
git commit -m "feat(kitty): Add right-click paste and Ctrl+Alt+Arrow window navigation

- Add mouse right-click paste from clipboard
- Add Ctrl+Alt+Arrow directional window navigation
- Enhances user experience for terminal window management"
git push origin main
```

---

## Phase 2: Zellij Installation

**Goal:** Install zellij via home-manager
**Time:** 15-20 minutes
**Risk:** Low (new package addition)

### Step 2.1: Add Zellij to Home-Manager

**Option A: Add to existing shell.nix (if packages section exists)**

**File:** `home-manager/shell.nix`

Find the `home.packages` section and add zellij:
```nix
home.packages = with pkgs; [
  # ... existing packages ...
  zellij
];
```

**Option B: Create dedicated zellij.nix (recommended)**

**File:** `home-manager/zellij.nix`

```nix
{ config, pkgs, ... }:

{
  # Install zellij terminal multiplexer
  home.packages = with pkgs; [
    zellij
  ];

  # Note: Configuration managed via chezmoi at ~/.config/zellij/
}
```

Then import in `home.nix`:
```nix
imports = [
  # ... existing imports ...
  ./zellij.nix
];
```

### Step 2.2: Apply Home-Manager Changes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager

# Build first (to check for errors)
home-manager build --flake .#mitsio@shoshin

# If build succeeds, apply
home-manager switch --flake .#mitsio@shoshin
```

### Step 2.3: Verify Zellij Installation

```bash
# Check installation
which zellij
# Expected: /nix/store/.../bin/zellij

# Check version
zellij --version
# Expected: zellij 0.XX.X

# Test basic launch
zellij
# Should launch successfully
# Exit with Ctrl+Q
```

### Step 2.4: Commit Home-Manager Changes

**In home-manager repo:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
git add zellij.nix home.nix  # or shell.nix if used
git commit -m "feat(zellij): Add zellij terminal multiplexer via home-manager

- Install zellij from nixpkgs-unstable
- Configuration will be managed via chezmoi
- Adds modern terminal multiplexing capabilities"
git push origin main
```

---

## Phase 3: Zellij Configuration

**Goal:** Configure zellij with Catppuccin Mocha theme
**Time:** 45-60 minutes
**Risk:** Low (new config files)

### Step 3.1: Create Zellij Config Directory Structure

```bash
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.config/zellij/plugins
```

### Step 3.2: Create Basic config.kdl

**File:** `~/.config/zellij/config.kdl`

```kdl
// Zellij Configuration
// Created: 2025-11-30 by Mitso
// Theme: Catppuccin Mocha (matches kitty)

// Theme
theme "catppuccin-mocha"

// UI Settings
simplified_ui true
pane_frames false
default_shell "bash"
mouse_mode true

// Scrollback
scroll_buffer_size 10000

// Copy command (Wayland - KDE Plasma)
copy_command "wl-copy"
// For X11: copy_command "xclip -selection clipboard"

// Clipboard behavior
copy_on_select true

// Session behavior
attach_to_session true
session_serialization false

// Keybindings (use defaults for now)
// Can customize later

// Plugins will be added in next step
```

### Step 3.3: Create Default Layout

**File:** `~/.config/zellij/layouts/default.kdl`

```kdl
// Default Zellij Layout
// Simple single-pane layout with status bar

layout {
    // Top: Tab bar
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main content area
    pane {
        // This is where your shell/apps run
    }

    // Bottom: Status bar (will be replaced by zjstatus)
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

### Step 3.4: Test Zellij with Basic Config

```bash
# Launch zellij
zellij

# Test basic operations:
# 1. Create new pane: Ctrl+P, N
# 2. Navigate panes: Ctrl+P, H/L
# 3. Create new tab: Ctrl+T, N
# 4. Rename tab: Ctrl+T, R
# 5. Detach: Ctrl+O, D
# 6. Reattach: zellij attach
# 7. Quit: Ctrl+Q

# Verify theme colors (should be Catppuccin Mocha)
```

### Step 3.5: Add to Chezmoi

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace

# Add zellij configs to chezmoi
chezmoi add ~/.config/zellij/config.kdl
chezmoi add ~/.config/zellij/layouts/default.kdl

# Verify additions
chezmoi status
```

---

## Phase 4: zjstatus Installation

**Goal:** Install and configure beautiful status bar
**Time:** 30-45 minutes
**Risk:** Low (plugin addition)

### Step 4.1: Download zjstatus Plugin

```bash
# Create plugins directory
mkdir -p ~/.config/zellij/plugins

# Download latest zjstatus WASM
curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm \
  -o ~/.config/zellij/plugins/zjstatus.wasm

# Verify download
ls -lh ~/.config/zellij/plugins/zjstatus.wasm
# Should show file size ~1-2MB
```

### Step 4.2: Configure zjstatus in config.kdl

**Edit:** `~/.config/zellij/config.kdl`

**Add at the end (after existing content):**

```kdl
// zjstatus Plugin Configuration
// Beautiful status bar matching Catppuccin Mocha theme
plugins {
    zjstatus location="file:~/.config/zellij/plugins/zjstatus.wasm" {
        // Layout: [mode + tabs] (left)  [session] (center)  [datetime] (right)
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
        mode_move     "#[bg=#f5c2e7,fg=#1e1e2e,bold] MOVE "

        // Tab formatting
        tab_normal    "#[bg=#181825,fg=#cdd6f4] {index} {name} "
        tab_active    "#[bg=#cba6f7,fg=#1e1e2e,bold] {index} {name} "

        // Date/time (Europe/Athens timezone)
        datetime           "#[fg=#cdd6f4] {format} "
        datetime_format    "%a %d/%m %H:%M"
        datetime_timezone  "Europe/Athens"
    }
}
```

### Step 4.3: Update Default Layout for zjstatus

**Edit:** `~/.config/zellij/layouts/default.kdl`

**Replace the bottom status bar pane:**

```kdl
layout {
    // Top: Tab bar
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main content area
    pane {
        // Your shell/apps
    }

    // Bottom: zjstatus (replaces default status bar)
    pane size=1 borderless=true {
        plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
    }
}
```

### Step 4.4: Test zjstatus

```bash
# Launch zellij (should load zjstatus)
zellij

# Check status bar:
# - Left side: Mode indicator (NORMAL in green)
# - Left side: Tabs list
# - Center: Session name
# - Right side: Date/time (Europe/Athens)

# Test mode changes:
# Ctrl+P → Should show "PANE" in blue
# Ctrl+T → Should show "TAB" in yellow
# Esc → Back to "NORMAL" in green

# Test tab names:
# Ctrl+T, R → Rename tab → Should update in status bar

# Verify colors match Catppuccin Mocha theme
```

### Step 4.5: Add zjstatus to Chezmoi

```bash
# Add plugin file to chezmoi
chezmoi add ~/.config/zellij/plugins/zjstatus.wasm

# Update modified configs
chezmoi add ~/.config/zellij/config.kdl
chezmoi add ~/.config/zellij/layouts/default.kdl

# Verify
chezmoi status
```

---

## Phase 5: Advanced Layouts (Optional)

**Goal:** Create project-specific layouts
**Time:** 20-30 minutes
**Risk:** None (optional feature)

### Step 5.1: Create Development Layout

**File:** `~/.config/zellij/layouts/dev.kdl`

```kdl
// Development Layout
// Left: Editor (70%), Right: Terminal (30%)

layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    pane split_direction="vertical" {
        // Left: Editor (70% width)
        pane size="70%"

        // Right: Terminal (30% width)
        pane size="30%"
    }

    pane size=1 borderless=true {
        plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
    }
}
```

**Usage:**
```bash
zellij --layout dev attach -c myproject
```

### Step 5.2: Create SRE/Ops Layout

**File:** `~/.config/zellij/layouts/ops.kdl`

```kdl
// SRE/Ops Layout
// Top: Logs (50%), Bottom-left: Monitor (25%), Bottom-right: Shell (25%)

layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    pane split_direction="horizontal" {
        // Top: Logs (50% height)
        pane size="50%"

        // Bottom: Split again (50% height)
        pane size="50%" split_direction="vertical" {
            // Bottom-left: Monitor (50% width)
            pane size="50%"

            // Bottom-right: Shell (50% width)
            pane size="50%"
        }
    }

    pane size=1 borderless=true {
        plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
    }
}
```

### Step 5.3: Add Layouts to Chezmoi

```bash
chezmoi add ~/.config/zellij/layouts/dev.kdl
chezmoi add ~/.config/zellij/layouts/ops.kdl
```

---

## Phase 6: Integration & Documentation

**Goal:** Finalize integration and create helper docs
**Time:** 30 minutes
**Risk:** None (documentation only)

### Step 6.1: Create Navi Cheatsheet for Zellij

**File:** `dotfiles/dot_local/share/navi/cheats/zellij.cheat`

```cheat
% zellij, terminal, multiplexer

# Start or attach to default session
zellij attach -c default

# Start or attach to named session
zellij attach -c <session_name>

# Start with specific layout
zellij --layout <layout_name> attach -c <session_name>

# List all sessions
zellij list-sessions

# Delete a session
zellij delete-session <session_name>

# Quit zellij (inside session)
# Ctrl+Q

# Detach from session (inside session)
# Ctrl+O, D

# Create new pane right (inside session)
# Ctrl+P, N

# Create new pane down (inside session)
# Ctrl+P, D

# Close focused pane (inside session)
# Ctrl+P, X

# Navigate panes vim-style (inside session)
# Ctrl+P, H/J/K/L

# Navigate panes with arrows (inside session)
# Ctrl+P, ←/→/↑/↓

# Create new tab (inside session)
# Ctrl+T, N

# Close current tab (inside session)
# Ctrl+T, X

# Rename tab (inside session)
# Ctrl+T, R

# Next/Previous tab (inside session)
# Ctrl+T, L/H or Alt+]/[

# Enter scroll mode (inside session)
# Ctrl+S

# Search in scrollback (in scroll mode)
# /

# Start selection (in scroll mode)
# Space

# Copy selection and exit (in scroll mode)
# Enter

# Enter locked mode - disable all keybindings (inside session)
# Ctrl+G

$ session_name: echo -e "default\nmyproject\nwork\npersonal"
$ layout_name: echo -e "default\ndev\nops"
```

**Add to chezmoi:**
```bash
chezmoi add ~/.local/share/navi/cheats/zellij.cheat
```

### Step 6.2: Update Kitty Navi Cheatsheet

**File:** `dotfiles/dot_local/share/navi/cheats/kitty.cheat`

**Add new shortcuts:**
```cheat
% kitty, terminal, shortcuts

# ... existing content ...

# Paste with right-click (NEW - 2025-11-30)
# Right-click mouse button

# Navigate between windows with Ctrl+Alt+Arrows (NEW - 2025-11-30)
# Ctrl+Alt+←/→/↑/↓
```

**Add to chezmoi:**
```bash
chezmoi add ~/.local/share/navi/cheats/kitty.cheat
```

### Step 6.3: Test Complete Workflow

**Workflow Test Checklist:**

1. **Kitty Enhancements:**
   - [ ] Open kitty
   - [ ] Create multiple windows (splits)
   - [ ] Navigate with Ctrl+Alt+Arrow keys
   - [ ] Test right-click paste
   - [ ] Verify theme and transparency

2. **Zellij Basic:**
   - [ ] Launch: `zellij attach -c test`
   - [ ] Create panes (Ctrl+P, N/D)
   - [ ] Navigate panes (Ctrl+P, H/J/K/L)
   - [ ] Create tabs (Ctrl+T, N)
   - [ ] Rename tab (Ctrl+T, R)
   - [ ] Scroll mode (Ctrl+S, /, search)
   - [ ] Detach (Ctrl+O, D)
   - [ ] Reattach: `zellij attach test`
   - [ ] Delete: `zellij delete-session test`

3. **zjstatus:**
   - [ ] Status bar appears at bottom
   - [ ] Mode indicator changes color per mode
   - [ ] Active tab highlighted
   - [ ] Session name displayed in center
   - [ ] Date/time shows Europe/Athens time
   - [ ] Colors match Catppuccin Mocha

4. **Layouts:**
   - [ ] Test dev layout: `zellij --layout dev attach -c devtest`
   - [ ] Test ops layout: `zellij --layout ops attach -c opstest`
   - [ ] Verify pane arrangements

5. **Navi Integration:**
   - [ ] Open navi (Ctrl+G or navi command)
   - [ ] Search for "zellij"
   - [ ] Verify cheatsheet appears
   - [ ] Test running a command from cheat

### Step 6.4: Commit All Documentation

**In docs repo:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/docs
git add commons/integrations/kitty-zellij-integration.md
git add commons/toolbox/zellij/README.md
git commit -m "docs: Add comprehensive kitty + zellij integration documentation

- Integration guide with workflow examples
- Zellij toolbox documentation with all features
- Troubleshooting and best practices
- Configuration examples"
git push origin main
```

**In dotfiles repo:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git add dot_local/share/navi/cheats/zellij.cheat
git add dot_local/share/navi/cheats/kitty.cheat
git add dot_config/zellij/
git commit -m "feat(zellij): Add complete zellij configuration and cheatsheets

- Add config.kdl with Catppuccin Mocha theme
- Add zjstatus plugin with beautiful status bar
- Add default, dev, and ops layouts
- Add navi cheatsheets for zellij and kitty"
git push origin main
```

**In home-manager repo:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
git status
# Should already be committed in Phase 2
```

### Step 6.5: Create Session Summary

**File:** `sessions/kitty-configuration/SUMMARY.md`

```markdown
# Kitty + Zellij Integration - Session Summary

**Date:** 2025-11-30
**Status:** ✅ COMPLETE
**Time Spent:** ~X hours

## What Was Done

### Research
- ✅ Researched kitty aesthetics, themes (Dracula vs Catppuccin)
- ✅ Researched mouse right-click and copy-paste configurations
- ✅ Researched Ctrl+Alt+Arrow window navigation
- ✅ Researched zellij features, installation, configuration
- ✅ Researched zjstatus beautiful status bar plugin
- ✅ Researched kitty + zellij integration patterns

### Implementation
- ✅ Enhanced kitty with right-click paste
- ✅ Added Ctrl+Alt+Arrow window navigation to kitty
- ✅ Installed zellij via home-manager
- ✅ Configured zellij with Catppuccin Mocha theme
- ✅ Installed zjstatus plugin
- ✅ Created default, dev, and ops layouts
- ✅ Integrated all configs via chezmoi
- ✅ Created navi cheatsheets

### Documentation
- ✅ Research findings document
- ✅ Integration guide
- ✅ Zellij toolbox documentation
- ✅ Implementation plan
- ✅ This summary

## Files Created/Modified

### Modified
- `dotfiles/dot_config/kitty/kitty.conf`

### Created
- `home-manager/zellij.nix`
- `dotfiles/dot_config/zellij/config.kdl`
- `dotfiles/dot_config/zellij/layouts/default.kdl`
- `dotfiles/dot_config/zellij/layouts/dev.kdl`
- `dotfiles/dot_config/zellij/layouts/ops.kdl`
- `dotfiles/dot_config/zellij/plugins/zjstatus.wasm`
- `dotfiles/dot_local/share/navi/cheats/zellij.cheat`
- `docs/commons/integrations/kitty-zellij-integration.md`
- `docs/commons/toolbox/zellij/README.md`
- `sessions/kitty-configuration/RESEARCH_FINDINGS.md`
- `sessions/kitty-configuration/IMPLEMENTATION_PLAN.md`
- `sessions/kitty-configuration/SUMMARY.md`

## Results

### Kitty Enhancements
- ✅ Right-click paste working
- ✅ Ctrl+Alt+Arrow navigation working
- ✅ Theme and transparency unchanged (Catppuccin Mocha)

### Zellij Integration
- ✅ Installed via home-manager
- ✅ Configured with Catppuccin Mocha theme
- ✅ zjstatus beautiful status bar working
- ✅ Multiple layouts available
- ✅ Managed via chezmoi

### Documentation
- ✅ Comprehensive integration guide
- ✅ Complete zellij toolbox documentation
- ✅ Navi cheatsheets for quick reference

## Next Steps (Optional)

- Consider auto-launching zellij in kitty (add `startup_session.conf`)
- Create more project-specific layouts as needed
- Explore additional zellij plugins
- Configure custom keybindings if defaults don't suit workflow

## Lessons Learned

- Zellij is easier to configure than tmux
- zjstatus provides excellent visual feedback
- Catppuccin Mocha theme consistency is beautiful
- Modal interface (like vim) feels natural
- Chezmoi + home-manager = perfect declarative setup

**Session Complete! Enjoy your beautiful terminal workflow! 🎉**
```

---

## Rollback Plan (If Needed)

### Rollback Kitty Changes

```bash
# Restore backup
cp ~/.config/kitty/kitty.conf.backup.$(date +%Y%m%d) ~/.config/kitty/kitty.conf

# Or via chezmoi
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git revert <commit-hash>
chezmoi apply
```

### Rollback Zellij Installation

```bash
# Remove from home-manager
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
git revert <commit-hash>
home-manager switch --flake .#mitsio@shoshin

# Or remove manually and rebuild
```

### Rollback Zellij Configuration

```bash
# Remove configs
rm -rf ~/.config/zellij

# Remove from chezmoi
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git revert <commit-hash>
```

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] Kitty right-click paste works
- [ ] Kitty Ctrl+Alt+Arrow navigation works
- [ ] All kitty changes committed to dotfiles repo

**Phase 2 Complete When:**
- [ ] Zellij installed via home-manager
- [ ] `zellij --version` works
- [ ] Installation committed to home-manager repo

**Phase 3 Complete When:**
- [ ] Zellij launches with Catppuccin Mocha theme
- [ ] Basic config.kdl working
- [ ] Default layout created
- [ ] Configs added to chezmoi

**Phase 4 Complete When:**
- [ ] zjstatus plugin downloaded
- [ ] zjstatus configured in config.kdl
- [ ] Status bar appears with correct colors
- [ ] Plugin added to chezmoi

**Phase 5 Complete When:**
- [ ] Dev and ops layouts created
- [ ] Layouts tested and working
- [ ] Layouts added to chezmoi

**Phase 6 Complete When:**
- [ ] Navi cheatsheets created
- [ ] Full workflow tested
- [ ] All documentation committed
- [ ] Session summary written

**Overall Success:**
- [ ] All phases complete
- [ ] All tests passing
- [ ] All commits pushed
- [ ] User (Mitsio) happy with workflow! 😊

---

## Estimated Timeline

**Conservative Estimate:** 3 hours total
**Optimistic Estimate:** 2 hours total
**If Issues:** 4-5 hours

**Breakdown:**
- Phase 1: 30-45 min
- Phase 2: 15-20 min
- Phase 3: 45-60 min
- Phase 4: 30-45 min
- Phase 5: 20-30 min (optional)
- Phase 6: 30 min

**Recommendation:** Do Phases 1-4 in one session (2-2.5 hours). Phases 5-6 can be done later.

---

**End of Implementation Plan**

Ready to implement! Good luck, Mitsio! 🚀
