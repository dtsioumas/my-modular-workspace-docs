# zjstatus Integration Plan (OPTIONAL)

**Created:** 2025-11-30
**Session:** kitty-configuration
**Dependencies:** Zellij must be installed first (see `zellij-installation-plan.md`)
**Time Estimate:** 30-45 minutes
**Risk Level:** LOW (optional plugin, easy to remove)
**Optional:** YES - Zellij works perfectly without this enhancement

---

## Goal

Install and configure zjstatus - a beautiful, highly customizable status bar plugin for Zellij.

**What is zjstatus?**
- Rust/WebAssembly plugin for Zellij
- Modular status bar with widgets (mode, tabs, session, clock, battery, CPU)
- Fully customizable colors and format strings
- Nerd Font icon support
- Theme integration (Catppuccin, Dracula, Nord, etc.)

**Why Install It?**
- ✅ More beautiful than default status bar
- ✅ Shows more information (current mode, active tab, datetime)
- ✅ Fully customizable to match your aesthetic
- ✅ Catppuccin Mocha color scheme support

**Why Skip It?**
- ❌ Requires manual download of WASM binary (not in nixpkgs)
- ❌ Adds complexity (one more file to manage)
- ❌ Default zellij status bar is already good

**Recommendation:** Install if you want the most beautiful setup. Skip if you prefer simplicity.

---

## Prerequisites

**Required:**
- ✅ Zellij installed and working (complete `zellij-installation-plan.md` first)
- ✅ `~/.config/zellij/config.kdl` exists
- ✅ Internet connection (to download zjstatus.wasm)

**Verify Zellij:**
```bash
# Zellij must be installed
which zellij

# Config must exist
ls ~/.config/zellij/config.kdl
```

---

## Phase 1: Download zjstatus Plugin

**Time:** 5-10 minutes

### Step 1.1: Create Plugins Directory

```bash
mkdir -p ~/.config/zellij/plugins
```

### Step 1.2: Download zjstatus WASM Binary

**Method 1: Direct Download (Recommended)**
```bash
curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm \
  -o ~/.config/zellij/plugins/zjstatus.wasm
```

**Method 2: Specific Version**
```bash
# Check latest release at: https://github.com/dj95/zjstatus/releases
# Replace vX.X.X with desired version

curl -L https://github.com/dj95/zjstatus/releases/download/v0.XX.X/zjstatus.wasm \
  -o ~/.config/zellij/plugins/zjstatus.wasm
```

### Step 1.3: Verify Download

```bash
# Check file exists and size
ls -lh ~/.config/zellij/plugins/zjstatus.wasm

# Should show:
# -rw-r--r-- ... ~1-2MB ... zjstatus.wasm

# Check file type
file ~/.config/zellij/plugins/zjstatus.wasm

# Should show:
# ... WebAssembly (wasm) binary module ...
```

**If download fails:**
- Check internet connection
- Verify GitHub is accessible
- Try alternative release URL from https://github.com/dj95/zjstatus/releases

---

## Phase 2: Configure zjstatus

**Time:** 15-20 minutes

### Step 2.1: Update config.kdl with zjstatus Plugin

**File:** `~/.config/zellij/config.kdl`

**Add at the end (after existing content):**

```kdl
// ============ PLUGINS ============
// zjstatus - Beautiful status bar with Catppuccin Mocha theme
// GitHub: https://github.com/dj95/zjstatus

plugins {
    zjstatus location="file:~/.config/zellij/plugins/zjstatus.wasm" {
        // Layout: [mode + tabs] (left)  [session] (center)  [datetime] (right)
        format_left   "{mode}#[bg=#1e1e2e] {tabs}"
        format_center "{session}"
        format_right  "#[bg=#1e1e2e,fg=#cba6f7] {datetime}"
        format_space  "#[bg=#1e1e2e]"

        // ===== Mode Indicators (Catppuccin Mocha colors) =====
        // Normal mode (default) - Green
        mode_normal   "#[bg=#a6e3a1,fg=#1e1e2e,bold] NORMAL "

        // Locked mode (all keys disabled) - Red
        mode_locked   "#[bg=#f38ba8,fg=#1e1e2e,bold] LOCKED "

        // Pane mode (create/navigate panes) - Blue
        mode_pane     "#[bg=#89b4fa,fg=#1e1e2e,bold] PANE "

        // Tab mode (create/navigate tabs) - Yellow
        mode_tab      "#[bg=#f9e2af,fg=#1e1e2e,bold] TAB "

        // Resize mode (resize panes) - Mauve
        mode_resize   "#[bg=#cba6f7,fg=#1e1e2e,bold] RESIZE "

        // Scroll mode (scrollback/search) - Teal
        mode_scroll   "#[bg=#94e2d5,fg=#1e1e2e,bold] SCROLL "

        // Session mode (detach/switch) - Peach
        mode_session  "#[bg=#fab387,fg=#1e1e2e,bold] SESSION "

        // Move mode (move panes/tabs) - Pink
        mode_move     "#[bg=#f5c2e7,fg=#1e1e2e,bold] MOVE "

        // ===== Tab Formatting =====
        // Inactive tabs - Dark background, light text
        tab_normal    "#[bg=#181825,fg=#cdd6f4] {index} {name} "

        // Active tab - Mauve background, dark text
        tab_active    "#[bg=#cba6f7,fg=#1e1e2e,bold] {index} {name} "

        // ===== Date/Time =====
        datetime           "#[fg=#cdd6f4] {format} "
        datetime_format    "%a %d/%m %H:%M"
        datetime_timezone  "Europe/Athens"
    }
}

// Color Reference (Catppuccin Mocha):
// #1e1e2e - Base (background)
// #181825 - Mantle (darker background)
// #cdd6f4 - Text (foreground)
// #a6e3a1 - Green (normal mode)
// #f38ba8 - Red (locked mode)
// #89b4fa - Blue (pane mode)
// #f9e2af - Yellow (tab mode)
// #cba6f7 - Mauve (resize/active tab)
// #94e2d5 - Teal (scroll mode)
// #fab387 - Peach (session mode)
// #f5c2e7 - Pink (move mode)
```

### Step 2.2: Update Default Layout

**File:** `~/.config/zellij/layouts/default.kdl`

**Replace the bottom status bar pane:**

**OLD (default status bar):**
```kdl
pane size=2 borderless=true {
    plugin location="zellij:status-bar"
}
```

**NEW (zjstatus):**
```kdl
pane size=1 borderless=true {
    plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
}
```

**Complete Updated Layout:**
```kdl
// Default Zellij Layout with zjstatus
// Beautiful status bar with Catppuccin Mocha colors

layout {
    // Top: Tab bar
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }

    // Main content area
    pane {
        // Your shell runs here
    }

    // Bottom: zjstatus (replaces default status bar)
    pane size=1 borderless=true {
        plugin location="file:~/.config/zellij/plugins/zjstatus.wasm"
    }
}
```

---

## Phase 3: Test zjstatus

**Time:** 10-15 minutes

### Step 3.1: Launch Zellij

```bash
# Exit any running zellij sessions first
# Ctrl+Q

# Launch fresh
zellij
```

### Step 3.2: Verify zjstatus Loaded

**Check Status Bar:**
- ✅ Status bar appears at bottom of screen
- ✅ Status bar is 1 line tall (not 2 like default)
- ✅ Left side shows mode indicator (e.g., "NORMAL" in green)
- ✅ Left side shows tabs (if multiple tabs exist)
- ✅ Center shows session name
- ✅ Right side shows date/time in Europe/Athens timezone

**If zjstatus doesn't load:**
```bash
# Check zellij logs
cat ~/.cache/zellij/zellij-*/*.log | grep -i error

# Check plugin file exists
ls -lh ~/.config/zellij/plugins/zjstatus.wasm

# Verify config syntax
cat ~/.config/zellij/config.kdl | grep -A 5 zjstatus
```

### Step 3.3: Test Mode Indicators

**Test each mode and verify color changes:**

| Mode | Shortcut | Expected Color | Expected Text |
|------|----------|----------------|---------------|
| Normal | (default) | Green (#a6e3a1) | NORMAL |
| Locked | Ctrl+G | Red (#f38ba8) | LOCKED |
| Pane | Ctrl+P | Blue (#89b4fa) | PANE |
| Tab | Ctrl+T | Yellow (#f9e2af) | TAB |
| Resize | Ctrl+N | Mauve (#cba6f7) | RESIZE |
| Scroll | Ctrl+S | Teal (#94e2d5) | SCROLL |
| Session | Ctrl+O | Peach (#fab387) | SESSION |

**Test:**
```
1. Ctrl+P → Should show "PANE" in blue ✅
2. Esc → Back to "NORMAL" in green ✅
3. Ctrl+T → Should show "TAB" in yellow ✅
4. Esc → Back to "NORMAL" ✅
5. Ctrl+S → Should show "SCROLL" in teal ✅
6. Esc → Back to "NORMAL" ✅
```

### Step 3.4: Test Tab Display

```bash
# Create multiple tabs
Ctrl+T, N    # New tab
Ctrl+T, R    # Rename tab to "test1"
Ctrl+T, N    # Another tab
Ctrl+T, R    # Rename to "test2"
```

**Verify:**
- ✅ Active tab highlighted with mauve background (#cba6f7)
- ✅ Inactive tabs have dark background (#181825)
- ✅ Tab names appear correctly
- ✅ Tab numbers (indices) shown

### Step 3.5: Test DateTime Widget

**Verify:**
- ✅ Shows correct time for Europe/Athens timezone
- ✅ Format matches: "Mon 30/11 14:30" (day, date/month, hour:minute)
- ✅ Updates every minute

---

## Phase 4: Add to Chezmoi

**Time:** 5 minutes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace

# Add zjstatus plugin binary
chezmoi add ~/.config/zellij/plugins/zjstatus.wasm

# Update modified configs
chezmoi add ~/.config/zellij/config.kdl
chezmoi add ~/.config/zellij/layouts/default.kdl

# Verify
chezmoi status
```

---

## Phase 5: Commit Changes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

git add dot_config/zellij/
git commit -m "feat(zellij): Add zjstatus beautiful status bar plugin

- Download zjstatus.wasm v0.XX.X plugin
- Configure with Catppuccin Mocha color scheme
- Update default layout to use zjstatus
- Add datetime widget (Europe/Athens timezone)
- Mode indicators with color-coded states
- Enhanced tab display with active highlighting

Part of: kitty-configuration session (OPTIONAL enhancement)"

git push origin main
```

---

## Customization (Optional)

### Add More Widgets

**Battery widget:**
```kdl
format_right  "#[bg=#1e1e2e,fg=#a6e3a1] {battery} #[fg=#cba6f7] {datetime}"

battery       "#[] {percent}%"
```

**CPU widget:**
```kdl
format_right  "#[bg=#1e1e2e,fg=#89b4fa] {cpu} #[fg=#cba6f7] {datetime}"

cpu           "#[] {usage}%"
```

**Kubernetes context (if using k8s):**
```kdl
format_left   "{mode}#[bg=#1e1e2e] {tabs} #[fg=#f9e2af] {k8s}"

k8s           "#[] {context}"
```

See zjstatus documentation for all available widgets:
https://github.com/dj95/zjstatus#widgets

---

## Rollback Plan

**If zjstatus is broken or unwanted:**

### Option 1: Revert to Default Status Bar

**Edit:** `~/.config/zellij/layouts/default.kdl`

**Change bottom pane back to:**
```kdl
pane size=2 borderless=true {
    plugin location="zellij:status-bar"
}
```

**Remove zjstatus config from config.kdl:**
- Delete the entire `plugins { ... }` block

```bash
chezmoi apply
# Ctrl+Q to exit zellij, then restart
```

### Option 2: Remove Plugin File

```bash
rm ~/.config/zellij/plugins/zjstatus.wasm
# Zellij will fallback to default status bar
```

### Option 3: Git Revert

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git revert <commit-hash>
chezmoi apply
```

---

## Success Criteria

**This plan is complete when:**
- ✅ zjstatus.wasm downloaded successfully
- ✅ Plugin configured in config.kdl with Catppuccin Mocha colors
- ✅ Default layout updated to use zjstatus
- ✅ All mode indicators work and show correct colors
- ✅ Tab display works with highlighting
- ✅ DateTime widget shows Europe/Athens time
- ✅ Status bar looks beautiful and matches kitty theme
- ✅ Changes added to chezmoi and committed
- ✅ User (Mitsio) satisfied with beautiful status bar!

---

## Next Steps

After completing this plan, you can:

1. **Enjoy your beautiful terminal!** - zjstatus + zellij + kitty = gorgeous setup
2. **Customize further** - Add battery, CPU, k8s context widgets
3. **Create custom layouts** - See `advanced-features-plan.md`
4. **Auto-launch zellij** - See `advanced-features-plan.md`

---

## Reference

**Files Modified:**
- `~/.config/zellij/config.kdl` (added plugins block)
- `~/.config/zellij/layouts/default.kdl` (changed status bar)

**Files Created:**
- `~/.config/zellij/plugins/zjstatus.wasm` (binary plugin)

**Related Documentation:**
- zjstatus GitHub: https://github.com/dj95/zjstatus
- zjstatus Examples: https://github.com/dj95/zjstatus/discussions/44
- Catppuccin Colors: https://github.com/catppuccin/catppuccin
- Session Research: `sessions/kitty-configuration/RESEARCH_FINDINGS.md`

---

**End of zjstatus Integration Plan**

This is an OPTIONAL enhancement - skip if you prefer simplicity! 🎨
