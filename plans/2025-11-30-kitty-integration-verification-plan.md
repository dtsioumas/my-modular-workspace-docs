# Integration Verification Plan

**Created:** 2025-11-30
**Session:** kitty-configuration
**Dependencies:** Complete all desired implementation plans first
**Time Estimate:** 30 minutes
**Risk Level:** NONE (testing only, no changes)

---

## Goal

Verify that all implemented features work correctly together in a complete, integrated workflow.

**What This Plan Does:**
- ✅ Tests kitty enhancements (if implemented)
- ✅ Tests zellij installation and configuration (if implemented)
- ✅ Tests zjstatus plugin (if implemented)
- ✅ Tests custom layouts (if implemented)
- ✅ Tests complete end-to-end workflow
- ✅ Identifies any integration issues
- ✅ Confirms user satisfaction

**When to Run This:**
- After completing all desired implementation plans
- Before considering the session "done"
- Whenever you make significant config changes

---

## Prerequisites

**Minimum Required:**
- ✅ You've completed at least one other implementation plan
- ✅ You want to verify everything works

**Verification Scope:**
This plan tests only what you've implemented. Skip sections for features you didn't install.

---

## Test 1: Kitty Enhancements

**Run If:** You completed `kitty-enhancements-plan.md`

### Test 1.1: Right-Click Paste

**Steps:**
1. Open kitty terminal
2. Type some text: `echo "test paste"`
3. Select "test paste" with mouse
4. Right-click in the same or different kitty window

**Expected Result:**
- ✅ Right-click should paste "test paste"
- ✅ No error or unexpected behavior

**If fails:**
- Check `mouse_map right press ungrabbed paste_from_clipboard` in kitty.conf
- Reload config: Ctrl+Shift+F5
- Check kitty logs: `kitty --debug-config`

### Test 1.2: Ctrl+Alt+Arrow Window Navigation

**Steps:**
1. Open kitty terminal
2. Create splits:
   - Ctrl+Alt+Enter (horizontal split)
   - Alt+Shift+Enter (vertical split)
   - Create 3-4 windows
3. Test navigation:
   - Ctrl+Alt+← (should focus left window)
   - Ctrl+Alt+→ (should focus right window)
   - Ctrl+Alt+↑ (should focus window above)
   - Ctrl+Alt+↓ (should focus window below)

**Expected Result:**
- ✅ Focus moves to correct window in each direction
- ✅ Visual indicator shows focused window (border color change)

**If fails:**
- Check `map ctrl+alt+left neighboring_window left` etc. in kitty.conf
- Verify keybindings not conflicting with DE shortcuts
- Try in plain window manager (not KDE) to rule out conflict

### Test 1.3: Existing Functionality Unchanged

**Steps:**
1. Test Ctrl+Shift+C / Ctrl+Shift+V (copy/paste)
2. Test transparency adjustment: Ctrl+Shift+A, M/L
3. Verify theme colors (Catppuccin Mocha)
4. Check font rendering (JetBrains Mono Nerd Font)

**Expected Result:**
- ✅ All existing features still work
- ✅ No regressions

---

## Test 2: Zellij Installation

**Run If:** You completed `zellij-installation-plan.md`

### Test 2.1: Zellij Command Available

```bash
# Check installation
which zellij
# Expected: /nix/store/.../bin/zellij

# Check version
zellij --version
# Expected: zellij 0.XX.X
```

**Expected Result:**
- ✅ Zellij found in PATH
- ✅ Version displayed

### Test 2.2: Zellij Launches

```bash
# Launch default session
zellij
```

**Expected Result:**
- ✅ Zellij launches without errors
- ✅ Tab bar appears at top
- ✅ Status bar appears at bottom
- ✅ Single pane in middle (main workspace)

### Test 2.3: Catppuccin Mocha Theme Applied

**Visual Check:**
- ✅ Background: Dark blue-gray (#1e1e2e)
- ✅ Text: Lavender-white (#cdd6f4)
- ✅ Status bar colors match Catppuccin
- ✅ Tab bar colors match Catppuccin

**If theme not applied:**
```bash
# Check config
grep "theme" ~/.config/zellij/config.kdl
# Should show: theme "catppuccin-mocha"
```

### Test 2.4: Basic Operations

**Panes:**
```
Ctrl+P, N   # New pane right ✅
Ctrl+P, D   # New pane down ✅
Ctrl+P, H   # Focus left ✅
Ctrl+P, L   # Focus right ✅
Ctrl+P, X   # Close pane ✅
```

**Tabs:**
```
Ctrl+T, N   # New tab ✅
Ctrl+T, R   # Rename tab → type "test" → Enter ✅
Ctrl+T, H   # Previous tab ✅
Ctrl+T, L   # Next tab ✅
Ctrl+T, X   # Close tab ✅
```

**Scroll & Search:**
```
Ctrl+S      # Enter scroll mode ✅
↑/↓         # Scroll up/down ✅
/           # Search → type "test" → Enter ✅
N           # Next result ✅
Esc         # Exit scroll mode ✅
```

**Sessions:**
```
Ctrl+O, D   # Detach ✅
```

```bash
# Reattach
zellij attach  # or zellij attach -c <session-name>
```

**Expected Result:**
- ✅ All operations work smoothly
- ✅ No crashes or freezes

---

## Test 3: zjstatus Plugin

**Run If:** You completed `zjstatus-integration-plan.md`

### Test 3.1: zjstatus Loads

```bash
# Launch zellij
zellij
```

**Visual Check:**
- ✅ Status bar is 1 line tall (not 2 like default)
- ✅ Left side: Mode indicator (e.g., "NORMAL" in green)
- ✅ Left side: Tabs (if multiple tabs exist)
- ✅ Center: Session name
- ✅ Right side: Date/time (Europe/Athens timezone)

**If zjstatus doesn't load:**
```bash
# Check plugin file
ls -lh ~/.config/zellij/plugins/zjstatus.wasm
# Should exist and be ~1-2MB

# Check logs
cat ~/.cache/zellij/zellij-*/*.log | grep -i error
```

### Test 3.2: Mode Indicators

**Test each mode:**
```
(default)  → "NORMAL" in green (#a6e3a1) ✅
Ctrl+P     → "PANE" in blue (#89b4fa) ✅
Ctrl+T     → "TAB" in yellow (#f9e2af) ✅
Ctrl+N     → "RESIZE" in mauve (#cba6f7) ✅
Ctrl+S     → "SCROLL" in teal (#94e2d5) ✅
Ctrl+O     → "SESSION" in peach (#fab387) ✅
Ctrl+G     → "LOCKED" in red (#f38ba8) ✅
Esc        → Back to "NORMAL" ✅
```

**Expected Result:**
- ✅ Mode indicator changes color correctly
- ✅ Mode name updates correctly

### Test 3.3: Tab Display

**Create tabs:**
```
Ctrl+T, N   # New tab
Ctrl+T, R   # Rename to "tab1"
Ctrl+T, N   # Another tab
Ctrl+T, R   # Rename to "tab2"
Ctrl+T, H   # Switch between tabs
```

**Visual Check:**
- ✅ Active tab: Mauve background (#cba6f7), dark text
- ✅ Inactive tabs: Dark background (#181825), light text
- ✅ Tab names appear correctly
- ✅ Tab indices (numbers) shown

### Test 3.4: DateTime Widget

**Visual Check:**
- ✅ Time displayed in format: "Mon 30/11 14:30"
- ✅ Timezone is Europe/Athens (GMT+2 or GMT+3 depending on DST)
- ✅ Time updates every minute

**Verify timezone:**
```bash
# Check current time
date

# Compare with zjstatus display
# Should match (accounting for Europe/Athens timezone)
```

---

## Test 4: Custom Layouts

**Run If:** You completed `advanced-features-plan.md` and created custom layouts

### Test 4.1: Dev Layout

```bash
zellij --layout dev attach -c test-dev
```

**Expected Result:**
- ✅ Two vertical panes appear
- ✅ Left pane: ~70% width
- ✅ Right pane: ~30% width
- ✅ Both panes in current working directory

**Test within dev layout:**
```
# In left pane: launch editor
nvim test.txt

# Switch to right pane: Ctrl+P, L
# In right pane: run commands
ls -la
git status
```

**Clean up:**
```
Ctrl+Q
zellij delete-session test-dev
```

### Test 4.2: Ops Layout

```bash
zellij --layout ops attach -c test-ops
```

**Expected Result:**
- ✅ Three panes appear
- ✅ Top pane: ~50% height (for logs)
- ✅ Bottom-left pane: ~25% of total (for monitor)
- ✅ Bottom-right pane: ~25% of total (for shell)

**Test within ops layout:**
```
# Top pane: tail logs
journalctl -f -n 20

# Ctrl+P, ↓ to move to bottom panes
# Bottom-left: run htop
htop

# Ctrl+P, → to move to bottom-right
# Run commands
df -h
```

**Clean up:**
```
Ctrl+Q
zellij delete-session test-ops
```

### Test 4.3: Focus Layout (if created)

```bash
zellij --layout focus attach -c test-focus
```

**Expected Result:**
- ✅ Single full-screen pane
- ✅ Minimal tab bar (top)
- ✅ Minimal status bar (bottom)
- ✅ Maximum workspace area

**Clean up:**
```
Ctrl+Q
zellij delete-session test-focus
```

---

## Test 5: Navi Integration

**Run If:** You created navi cheatsheets

### Test 5.1: Zellij Cheatsheet

```bash
# Open navi
navi

# Search: zellij
# Or use: navi --query zellij
```

**Expected Result:**
- ✅ Zellij cheatsheet appears
- ✅ All commands listed (attach, detach, layouts, etc.)
- ✅ Interactive prompts for session names and layouts work

**Test Command Execution:**
1. Select "Start or attach to default session"
2. Navi should show: `zellij attach -c default`
3. Press Enter to execute (or Ctrl+C to cancel)

### Test 5.2: Kitty Cheatsheet (Updated)

```bash
navi --query kitty
```

**Expected Result:**
- ✅ Kitty cheatsheet includes new shortcuts:
  - Right-click paste
  - Ctrl+Alt+Arrow navigation

---

## Test 6: End-to-End Workflow

**This is the complete, integrated workflow test.**

### Scenario: Typical Development Session

**Steps:**
1. **Open kitty terminal** (should auto-launch zellij if configured)
   - Or manually: `zellij attach -c myproject`

2. **Start dev layout:**
   ```bash
   zellij --layout dev attach -c myproject
   ```

3. **Work in editor (left pane):**
   - Launch nvim or your editor
   - Edit some files

4. **Switch to terminal (right pane):**
   - Ctrl+P, L (focus right pane)
   - Run commands: `git status`, `make test`, etc.

5. **Need more space? Create tabs:**
   - Ctrl+T, N (new tab)
   - Ctrl+T, R → rename to "testing"
   - Work in new tab

6. **Search scrollback:**
   - Ctrl+S (scroll mode)
   - / → search for error message
   - N (next result)
   - Space → select text
   - Enter → copy and exit

7. **Detach session:**
   - Ctrl+O, D (detach)
   - Session keeps running in background

8. **Reattach later:**
   ```bash
   zellij attach myproject
   ```
   - Everything exactly as you left it!

9. **Clean up:**
   ```bash
   zellij delete-session myproject
   ```

**Expected Result:**
- ✅ All steps work smoothly
- ✅ Workflow feels natural and productive
- ✅ No crashes, freezes, or unexpected behavior
- ✅ Session persistence works (detach/reattach)
- ✅ Theme looks beautiful throughout

---

## Test 7: Cross-Feature Integration

### Test 7.1: Kitty + Zellij Keybinding Conflicts

**Verify no conflicts:**
- ✅ Ctrl+Alt+Arrow (kitty window nav) works OUTSIDE zellij
- ✅ Ctrl+Alt+Arrow (kitty window nav) works INSIDE zellij for kitty windows
- ✅ Ctrl+P, H/J/K/L (zellij pane nav) works INSIDE zellij for zellij panes
- ✅ No keybinding confusion

**If conflicts:**
- Kitty shortcuts should take precedence outside zellij
- Zellij shortcuts should work inside zellij
- You can use both independently

### Test 7.2: Theme Consistency

**Visual Verification:**
- ✅ Kitty theme: Catppuccin Mocha
- ✅ Zellij theme: Catppuccin Mocha
- ✅ zjstatus colors: Catppuccin Mocha
- ✅ All colors harmonize beautifully
- ✅ Transparency and blur work correctly

### Test 7.3: Copy/Paste Across Tools

**Test:**
1. Select text in kitty (outside zellij)
2. Right-click paste in kitty → works ✅
3. Launch zellij
4. Inside zellij: Ctrl+S, select text, Enter (copy)
5. Exit zellij: Ctrl+Q
6. Paste in kitty: Ctrl+Shift+V → should paste zellij text ✅

**Expected Result:**
- ✅ Clipboard integration works across all tools

---

## Test 8: Chezmoi Verification

**Verify all configs managed by chezmoi:**

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace

# Check chezmoi status
chezmoi status

# Should show no untracked files (everything managed)
```

**Verify files in chezmoi:**
```bash
chezmoi managed | grep -E "(kitty|zellij|navi)"
```

**Expected files (based on what you implemented):**
- ✅ `dot_config/kitty/kitty.conf` (if enhanced)
- ✅ `dot_config/kitty/launch.conf` (if auto-launch)
- ✅ `dot_config/zellij/config.kdl` (if installed)
- ✅ `dot_config/zellij/layouts/default.kdl` (if installed)
- ✅ `dot_config/zellij/layouts/dev.kdl` (if created)
- ✅ `dot_config/zellij/layouts/ops.kdl` (if created)
- ✅ `dot_config/zellij/plugins/zjstatus.wasm` (if installed)
- ✅ `dot_local/share/navi/cheats/zellij.cheat` (if created)

### Test Chezmoi Apply

```bash
# Test dry-run
chezmoi apply --dry-run

# Should show no changes (everything already applied)
```

---

## Test 9: Home-Manager Verification

**Verify zellij package (if installed via home-manager):**

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager

# Check git status
git status
# Should be clean (all changes committed)

# Verify zellij in config
grep -r "zellij" *.nix
# Should show zellij package
```

**Test home-manager rebuild (idempotent):**
```bash
home-manager switch --flake .#mitsio@shoshin

# Should complete without errors
# Should not make any changes (everything already applied)
```

---

## Test 10: Git Repository Status

**Verify all repos are clean and committed:**

```bash
# Home-manager repo
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
git status  # Should be clean ✅

# Dotfiles repo (chezmoi source)
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git status  # Should be clean ✅

# Docs repo
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/docs
git status  # Should be clean ✅
```

**If untracked files:**
- Decide if they should be committed
- Add to .gitignore if not needed
- Commit if needed

---

## Test 11: Documentation Verification

**Verify documentation exists:**

```bash
# Session docs
ls -lh sessions/kitty-configuration/
# Should show: RESEARCH_FINDINGS.md, (split research files if created), README (if created)

# Plan docs
ls -lh docs/plans/
# Should show: kitty-enhancements-plan.md, zellij-installation-plan.md, etc.

# Integration docs
ls -lh docs/integrations/
# Should show: kitty-zellij-integration.md (if created)

# Tool docs
ls -lh docs/tools/
# Should show: zellij.md (if created)
```

---

## Final Checklist

**Mark what you implemented and tested:**

### Kitty Enhancements
- [ ] Right-click paste works
- [ ] Ctrl+Alt+Arrow navigation works
- [ ] Existing features still work
- [ ] Changes committed to dotfiles repo

### Zellij Installation
- [ ] Zellij command available
- [ ] Zellij launches successfully
- [ ] Catppuccin Mocha theme applied
- [ ] Basic operations work (panes, tabs, scroll, sessions)
- [ ] Changes committed to home-manager repo
- [ ] Config committed to dotfiles repo

### zjstatus Plugin
- [ ] zjstatus loads without errors
- [ ] Mode indicators work and show correct colors
- [ ] Tab display works with highlighting
- [ ] DateTime widget shows correct time (Europe/Athens)
- [ ] Plugin file committed to dotfiles repo

### Custom Layouts
- [ ] Dev layout created and tested
- [ ] Ops layout created and tested
- [ ] (Optional) Focus layout created and tested
- [ ] Layouts committed to dotfiles repo

### Navi Integration
- [ ] Zellij cheatsheet created and tested
- [ ] Kitty cheatsheet updated (if applicable)
- [ ] Cheatsheets committed to dotfiles repo

### Cross-Feature Integration
- [ ] No keybinding conflicts
- [ ] Theme consistency across all tools
- [ ] Clipboard works across all tools

### Configuration Management
- [ ] All configs managed by chezmoi
- [ ] Chezmoi apply is idempotent
- [ ] All repos clean and committed

### Documentation
- [ ] Research findings documented
- [ ] Implementation plans created
- [ ] Integration guide exists (if created)
- [ ] Tool documentation exists (if created)

---

## Success Criteria

**This verification is complete when:**
- ✅ All implemented features tested and working
- ✅ No critical bugs or regressions
- ✅ Theme consistency across all tools
- ✅ All configs managed by chezmoi
- ✅ All changes committed to appropriate repos
- ✅ Documentation complete and accurate
- ✅ User (Mitsio) satisfied with the integrated workflow!

---

## If Issues Found

**Document any issues:**
1. Create an issue in appropriate repo (or TODO.md)
2. Mark severity (critical, major, minor, cosmetic)
3. Add to backlog for future sessions

**For critical issues:**
- Fix immediately before considering session complete
- Re-run verification after fix

---

## Conclusion

**After completing this verification:**

1. **Session is DONE!** 🎉
2. **Enjoy your beautiful, productive terminal setup!**
3. **Share screenshots** (it's worth it)
4. **Consider creating session summary** (see session README template)

---

**End of Integration Verification Plan**

This ensures everything works together beautifully! ✅
