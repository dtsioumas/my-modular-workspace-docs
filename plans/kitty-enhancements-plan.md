# Kitty Terminal Enhancements Plan

**Created:** 2025-11-30
**Session:** kitty-configuration
**Dependencies:** None (independent)
**Time Estimate:** 30-45 minutes
**Risk Level:** LOW (non-breaking changes)

---

## Goal

Enhance kitty terminal with improved mouse and keyboard shortcuts for better usability.

**Specific Enhancements:**
1. ✅ Enable right-click paste from clipboard
2. ✅ Add Ctrl+Alt+Arrow keys for directional window navigation

---

## Prerequisites

**Required:**
- ✅ Kitty terminal installed and configured
- ✅ Chezmoi managing dotfiles at `~/.MyHome/MySpaces/my-modular-workspace/dotfiles`
- ✅ Current kitty.conf exists at `dotfiles/dot_config/kitty/kitty.conf`

**Current State (Verified):**
- Theme: Catppuccin Mocha ✅
- Transparency: 0.95 opacity ✅
- Background blur: 32 ✅
- Existing shortcuts: Ctrl+Shift+C/V for copy/paste ✅

**Before Starting:**
```bash
# Backup current kitty config
cp ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.backup.$(date +%Y%m%d)

# Verify chezmoi source
chezmoi status
```

---

## Step 1: Add Right-Click Paste

**Goal:** Enable traditional GUI-style right-click → paste behavior

**File to Edit:** `dotfiles/dot_config/kitty/kitty.conf`

**Location:** After the "MOUSE" section (around line 37-44)

**Add this line:**
```conf
# ============ MOUSE ============
# ... existing mouse settings (copy_on_select, strip_trailing_spaces, etc.) ...

# Right-click paste (Mitso addition 2025-11-30)
mouse_map right press ungrabbed paste_from_clipboard
```

**Explanation:**
- `mouse_map right press ungrabbed`: Map right mouse button press when mouse is not grabbed
- `paste_from_clipboard`: Paste from system clipboard (not X11 primary selection)
- This gives traditional GUI terminal behavior

**Alternative (if you want middle-click for clipboard):**
```conf
# Middle-click paste from clipboard (instead of primary selection)
mouse_map middle press ungrabbed paste_from_clipboard
```

---

## Step 2: Add Ctrl+Alt+Arrow Window Navigation

**Goal:** Navigate between kitty windows using directional arrow keys

**File to Edit:** `dotfiles/dot_config/kitty/kitty.conf`

**Location:** After "Window Management" section (around line 144-158)

**Add these lines:**
```conf
# ===== Window Management =====
# ... existing window management shortcuts ...

# Directional window navigation with Ctrl+Alt+Arrow (Mitso addition 2025-11-30)
map ctrl+alt+left neighboring_window left
map ctrl+alt+right neighboring_window right
map ctrl+alt+up neighboring_window up
map ctrl+alt+down neighboring_window down
```

**Explanation:**
- `neighboring_window <direction>`: Focus the window in the specified direction
- Works with kitty's window splitting (Ctrl+Alt+Enter for horizontal, Alt+Shift+Enter for vertical)
- More intuitive than Ctrl+Shift+] / [ for cycling

**Note:** These shortcuts do NOT conflict with:
- Existing Ctrl+Shift+[ / ] (previous/next window cycling)
- Existing Ctrl+Alt+1/2/3/4/5 (goto specific tab)
- Zellij keybindings (when zellij is installed later)

---

## Step 3: Apply Changes via Chezmoi

**Commands:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Apply changes to ~/.config/kitty/
chezmoi apply

# Verify application
chezmoi diff
```

**If you see differences:**
- Chezmoi will show what changed
- Review and confirm changes are correct

---

## Step 4: Test Enhancements

**Test Checklist:**

### Right-Click Paste
1. ✅ **Select text** in one kitty window (or external app)
2. ✅ **Right-click** in another kitty window
3. ✅ **Verify** text pastes from clipboard
4. ✅ **Test** that Ctrl+Shift+V still works

### Ctrl+Alt+Arrow Navigation
1. ✅ **Create split windows:**
   - Ctrl+Alt+Enter (horizontal split)
   - Alt+Shift+Enter (vertical split)
   - Create 3-4 windows in grid layout
2. ✅ **Navigate** with Ctrl+Alt+Arrow keys
3. ✅ **Verify** focus moves correctly:
   - Ctrl+Alt+← focuses window to the left
   - Ctrl+Alt+→ focuses window to the right
   - Ctrl+Alt+↑ focuses window above
   - Ctrl+Alt+↓ focuses window below

### Existing Functionality
1. ✅ **Copy/Paste** with Ctrl+Shift+C / Ctrl+Shift+V still works
2. ✅ **Transparency** adjustment with Ctrl+Shift+A, M/L still works
3. ✅ **Theme colors** unchanged (Catppuccin Mocha)
4. ✅ **Font rendering** unchanged

**If Issues:**
```bash
# Reload kitty config
# Ctrl+Shift+F5 (in kitty)

# OR restart kitty
# Close and reopen

# Check for syntax errors
kitty --debug-config
```

---

## Step 5: Commit Changes

**Repository:** `dotfiles` (chezmoi source)

**Commands:**
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Stage changes
git add dot_config/kitty/kitty.conf

# Commit with descriptive message
git commit -m "feat(kitty): Add right-click paste and Ctrl+Alt+Arrow window navigation

- Add mouse right-click paste from clipboard
- Add Ctrl+Alt+Arrow directional window navigation
- Enhances user experience for terminal window management

Closes: Phase 1 of kitty-configuration session"

# Push to remote
git push origin main
```

---

## Rollback Plan

**If something breaks:**

### Option 1: Restore Backup
```bash
cp ~/.config/kitty/kitty.conf.backup.$(date +%Y%m%d) ~/.config/kitty/kitty.conf
# Ctrl+Shift+F5 to reload
```

### Option 2: Git Revert
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
git log --oneline  # Find commit hash
git revert <commit-hash>
chezmoi apply
```

### Option 3: Manual Fix
- Edit `dotfiles/dot_config/kitty/kitty.conf`
- Remove the added lines
- `chezmoi apply`
- Ctrl+Shift+F5 to reload

---

## Success Criteria

**This plan is complete when:**
- ✅ Right-click paste works in kitty
- ✅ Ctrl+Alt+Arrow navigation works between windows
- ✅ Existing shortcuts still work
- ✅ Theme and transparency unchanged
- ✅ Changes committed to dotfiles repo
- ✅ User (Mitsio) satisfied with enhancements

---

## Next Steps (Optional)

After completing this plan, you can:
1. **Continue to Zellij Installation Plan** (independent, can be done anytime)
2. **Use enhanced kitty immediately** (these changes work standalone)
3. **Create more custom shortcuts** if desired

---

## Reference

**Files Modified:**
- `dotfiles/dot_config/kitty/kitty.conf` (2 additions)

**Related Documentation:**
- Kitty Actions Reference: https://sw.kovidgoyal.net/kitty/actions/
- Kitty Mouse Mapping: https://sw.kovidgoyal.net/kitty/conf/#mouse-actions
- Session Research: `sessions/kitty-configuration/RESEARCH_FINDINGS.md`

---

**End of Kitty Enhancements Plan**

This is a standalone, low-risk enhancement. Proceed with confidence! 🚀
