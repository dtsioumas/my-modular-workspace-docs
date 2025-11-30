# Advanced Features Plan (OPTIONAL)

**Created:** 2025-11-30
**Session:** kitty-configuration
**Dependencies:** Zellij must be installed (see `zellij-installation-plan.md`)
**Time Estimate:** 30-45 minutes
**Risk Level:** LOW (all optional, easily reversible)
**Optional:** YES - These are power-user enhancements

---

## Goal

Configure advanced zellij features for power users:

1. ✅ Create project-specific layouts (dev, ops/SRE)
2. ✅ Auto-launch zellij in kitty (optional)
3. ✅ Create navi cheatsheets for quick reference

**Who This Is For:**
- Power users who want maximum productivity
- Users with specific workflow patterns (dev, SRE)
- Users who want zellij always available

**Skip This If:**
- You're happy with default layout
- You prefer manual zellij launching
- You want to keep things simple

---

## Prerequisites

**Required:**
- ✅ Zellij installed and configured (complete `zellij-installation-plan.md` first)
- ✅ Basic zellij usage tested
- ✅ Chezmoi managing dotfiles

**Optional:**
- 🤔 zjstatus installed (makes custom layouts prettier)

---

## Feature 1: Custom Layouts

**Time:** 20-25 minutes

### What Are Layouts?

Layouts define the initial arrangement of panes and tabs when starting a zellij session.

**Use Cases:**
- **Dev Layout:** Editor (70%) + Terminal (30%)
- **SRE/Ops Layout:** Logs (top) + Monitor (bottom-left) + Shell (bottom-right)
- **Debug Layout:** Debugger + Logs + Code
- **Meeting Layout:** Notes + Terminal + Clock

### Layout 1: Development Layout

**File:** `~/.config/zellij/layouts/dev.kdl`

```kdl
// Development Layout
// Left: Editor (70% width), Right: Terminal (30% width)
// Perfect for coding: vim/neovim on left, commands on right

layout {
    // Top: Tab bar
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main workspace (split vertically)
    pane split_direction="vertical" {
        // Left pane: Editor (70% width)
        pane size="70%" {
            // Opens in current working directory
            // Run: nvim, vim, or any editor
        }

        // Right pane: Terminal (30% width)
        pane size="30%" {
            // For running commands, testing, git status
        }
    }

    // Bottom: Status bar
    pane size=1 borderless=true {
        // Use zjstatus if installed, otherwise default
        plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
        // Or: plugin location="zellij:status-bar"
    }
}

// Usage:
// zellij --layout dev attach -c myproject
//
// This creates a session named "myproject" with dev layout:
// - Left pane ready for editor
// - Right pane ready for commands
// - Can split further as needed
```

### Layout 2: SRE/Ops Layout

**File:** `~/.config/zellij/layouts/ops.kdl`

```kdl
// SRE/Ops Layout
// Top: Logs (50% height)
// Bottom-left: System monitor (50% width)
// Bottom-right: Shell (50% width)
// Perfect for monitoring and troubleshooting

layout {
    // Top: Tab bar
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main workspace (split horizontally)
    pane split_direction="horizontal" {
        // Top half: Logs (50% height)
        pane size="50%" {
            // Run: journalctl -f, tail -f /var/log/...
            // Or: kubectl logs -f pod-name
        }

        // Bottom half: Split vertically
        pane size="50%" split_direction="vertical" {
            // Bottom-left: System monitor (50% width)
            pane size="50%" {
                // Run: htop, btop, k9s, etc.
            }

            // Bottom-right: Shell (50% width)
            pane size="50%" {
                // For running diagnostic commands
            }
        }
    }

    // Bottom: Status bar
    pane size=1 borderless=true {
        plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
        // Or: plugin location="zellij:status-bar"
    }
}

// Usage:
// zellij --layout ops attach -c monitoring
//
// Perfect for SRE work:
// - Top pane for tailing logs
// - Bottom-left for system monitoring (htop, k9s)
// - Bottom-right for running commands
```

### Layout 3: Full-Screen Focus Layout

**File:** `~/.config/zellij/layouts/focus.kdl`

```kdl
// Focus Layout
// Single full-screen pane for deep work
// Minimal distractions, maximum concentration

layout {
    // Top: Tab bar (minimal)
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main: Full-screen pane
    pane {
        // Your focused work happens here
        // No splits, no distractions
    }

    // Bottom: Status bar (minimal)
    pane size=1 borderless=true {
        plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
        // Or: plugin location="zellij:status-bar"
    }
}

// Usage:
// zellij --layout focus attach -c deepwork
//
// For:
// - Writing documentation
// - Deep code reading
// - Focused debugging
// - Presentations/demos
```

### Create Layouts

```bash
# Create dev layout
cat > ~/.config/zellij/layouts/dev.kdl << 'EOF'
[paste dev layout content here]
EOF

# Create ops layout
cat > ~/.config/zellij/layouts/ops.kdl << 'EOF'
[paste ops layout content here]
EOF

# Create focus layout
cat > ~/.config/zellij/layouts/focus.kdl << 'EOF'
[paste focus layout content here]
EOF
```

### Add to Chezmoi

```bash
chezmoi add ~/.config/zellij/layouts/dev.kdl
chezmoi add ~/.config/zellij/layouts/ops.kdl
chezmoi add ~/.config/zellij/layouts/focus.kdl
```

### Test Layouts

```bash
# Test dev layout
zellij --layout dev attach -c test-dev
# Should see: 70/30 vertical split
# Ctrl+Q to exit

# Test ops layout
zellij --layout ops attach -c test-ops
# Should see: top pane (logs), bottom split (monitor/shell)
# Ctrl+Q to exit

# Test focus layout
zellij --layout focus attach -c test-focus
# Should see: single full-screen pane
# Ctrl+Q to exit

# Clean up test sessions
zellij delete-session test-dev
zellij delete-session test-ops
zellij delete-session test-focus
```

---

## Feature 2: Auto-Launch Zellij in Kitty (OPTIONAL)

**Time:** 5-10 minutes
**Warning:** This changes your terminal behavior. Test first!

### Option A: Kitty Startup Session (Recommended)

**Create:** `~/.config/kitty/launch.conf`

```conf
# Auto-launch zellij when kitty starts
# Attaches to "default" session or creates it

launch --type=os-window zellij attach -c default
```

**Update:** `~/.config/kitty/kitty.conf`

**Add after the "ADVANCED" section:**
```conf
# ============ STARTUP SESSION ============
# Auto-launch zellij terminal multiplexer
startup_session launch.conf
```

**Add to chezmoi:**
```bash
chezmoi add ~/.config/kitty/launch.conf
chezmoi add ~/.config/kitty/kitty.conf
```

**Pros:**
- ✅ Zellij available immediately when opening kitty
- ✅ Persistent sessions (can detach/reattach)
- ✅ Clean, declarative config

**Cons:**
- ❌ Can't easily use kitty without zellij
- ❌ Nested terminal if you SSH and run zellij remotely

### Option B: Bash Shell Integration

**Add to `~/.bashrc`:**
```bash
# Auto-start zellij if not already inside
if [ -z "$ZELLIJ" ]; then
    zellij attach -c default
fi
```

**Pros:**
- ✅ Works in any terminal (not just kitty)
- ✅ Won't launch in nested SSH sessions (safer)

**Cons:**
- ❌ Requires bash startup (slower)
- ❌ Not managed by home-manager/chezmoi (unless .bashrc is)

### Option C: Alias (Most Flexible)

**Add to `~/.bashrc`:**
```bash
# Zellij aliases for quick access
alias zj="zellij attach -c default"              # Quick default session
alias zdev="zellij --layout dev attach -c dev"    # Dev layout
alias zops="zellij --layout ops attach -c ops"    # Ops layout
```

**Pros:**
- ✅ Most flexible (choose when to use zellij)
- ✅ Easy to remember shortcuts
- ✅ No behavior changes to kitty

**Cons:**
- ❌ Manual invocation (not automatic)

**Recommendation:** Start with **Option C (aliases)**, migrate to Option A after confirming workflow.

---

## Feature 3: Navi Cheatsheet for Zellij

**Time:** 5-10 minutes

**File:** `~/.local/share/navi/cheats/zellij.cheat`

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

# === Pane Management (inside session) ===

# Create new pane right
# Ctrl+P, N

# Create new pane down
# Ctrl+P, D

# Close focused pane
# Ctrl+P, X

# Navigate panes vim-style
# Ctrl+P, H/J/K/L

# Navigate panes with arrows
# Ctrl+P, ←/→/↑/↓

# Toggle pane fullscreen
# Ctrl+P, F

# === Tab Management (inside session) ===

# Create new tab
# Ctrl+T, N

# Close current tab
# Ctrl+T, X

# Rename tab
# Ctrl+T, R

# Next/Previous tab
# Ctrl+T, L/H or Alt+]/[

# Go to tab number
# Alt+1/2/3/4/5...

# === Scroll & Search (inside session) ===

# Enter scroll mode
# Ctrl+S

# Search in scrollback (in scroll mode)
# /

# Next/Previous search result
# N/P

# Start selection (in scroll mode)
# Space

# Copy selection and exit (in scroll mode)
# Enter

# === Modes (inside session) ===

# Enter pane mode
# Ctrl+P

# Enter tab mode
# Ctrl+T

# Enter resize mode
# Ctrl+N

# Enter scroll mode
# Ctrl+S

# Enter session mode
# Ctrl+O

# Enter locked mode (disable all keys)
# Ctrl+G

# Exit mode (back to normal)
# Esc

$ session_name: echo -e "default\nmyproject\nwork\npersonal\ndev\nops"
$ layout_name: echo -e "default\ndev\nops\nfocus"
```

### Add to Chezmoi

```bash
chezmoi add ~/.local/share/navi/cheats/zellij.cheat
```

### Test Cheatsheet

```bash
# Open navi
navi

# Search for "zellij"
# Should show all zellij commands

# Test interactive execution
# Select "Start or attach to default session"
# Should show: zellij attach -c default
```

---

## Commit All Advanced Features

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

git add dot_config/zellij/layouts/
git add dot_local/share/navi/cheats/zellij.cheat

# If you added kitty auto-launch:
git add dot_config/kitty/launch.conf
git add dot_config/kitty/kitty.conf

git commit -m "feat(zellij): Add advanced features - custom layouts and cheatsheets

- Add dev layout (editor 70% + terminal 30%)
- Add ops layout (logs + monitor + shell)
- Add focus layout (single full-screen pane)
- Add comprehensive navi cheatsheet for zellij
- (Optional) Add kitty auto-launch configuration

Part of: kitty-configuration session (OPTIONAL power-user features)"

git push origin main
```

---

## Rollback Plan

**Remove custom layouts:**
```bash
rm ~/.config/zellij/layouts/{dev,ops,focus}.kdl
```

**Remove auto-launch (if added):**
```bash
# Remove from kitty.conf:
# startup_session launch.conf

rm ~/.config/kitty/launch.conf
chezmoi apply
```

**Remove navi cheatsheet:**
```bash
rm ~/.local/share/navi/cheats/zellij.cheat
```

---

## Success Criteria

**This plan is complete when:**
- ✅ Custom layouts created (dev, ops, focus)
- ✅ Layouts tested and working correctly
- ✅ Navi cheatsheet created and tested
- ✅ (Optional) Auto-launch configured if desired
- ✅ All changes added to chezmoi and committed
- ✅ User (Mitsio) has powerful, customized workflow!

---

## Next Steps

After completing this plan:

1. **Use your custom layouts!**
   - `zj` or `zellij attach -c default` (if alias)
   - `zdev` or `zellij --layout dev attach -c myproject`
   - `zops` or `zellij --layout ops attach -c monitoring`

2. **Create more layouts** as you discover new workflow patterns

3. **Share your setup!** (it's beautiful)

---

## Reference

**Files Created:**
- `~/.config/zellij/layouts/dev.kdl`
- `~/.config/zellij/layouts/ops.kdl`
- `~/.config/zellij/layouts/focus.kdl`
- `~/.local/share/navi/cheats/zellij.cheat`
- (Optional) `~/.config/kitty/launch.conf`

**Related Documentation:**
- Zellij Layouts Docs: https://zellij.dev/documentation/layouts
- Session Research: `sessions/kitty-configuration/RESEARCH_FINDINGS.md`
- Tool Documentation: `docs/tools/zellij.md`

---

**End of Advanced Features Plan**

These are OPTIONAL power-user enhancements - use what you need! 🚀
