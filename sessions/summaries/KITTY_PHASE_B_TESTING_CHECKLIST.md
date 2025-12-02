# Kitty Phase B - User Testing Checklist

**Date Created:** 2025-12-01
**Purpose:** Test and provide feedback on Phase B features
**Maintainer:** Dimitris Tsioumas (Mitsio)

---

## 🎨 Visual & Theme

### Transparency
- [ ] **Background transparency works correctly**
  - Current issue: Transparency not working well
  - Expected: Can see browser/windows behind terminal
  - Actual behavior: _______________________________________________

- [ ] **Transparency controls work**
  - [ ] `Ctrl+Equal` increases opacity
  - [ ] `Ctrl+Minus` decreases opacity
  - Feedback: ___________________________________________________

### Dracula Theme (NEW)
- [ ] **Theme colors look good**
  - [ ] Background: Dark purple-ish (#282a36)
  - [ ] Foreground: Light gray (#f8f8f2)
  - [ ] Selection: Purple (#44475a)
  - [ ] Comments: Muted (#6272a4)
  - Feedback: ___________________________________________________

- [ ] **Syntax highlighting readable**
  - Test in: `vim`, `bat`, `git diff`
  - Feedback: ___________________________________________________

---

## 🔍 Phase B Features Testing

### B.1: Search Kitten (Ctrl+Shift+/)

**Test Steps:**
1. Open kitty terminal
2. Run: `ls -la /etc` (or any command with lots of output)
3. Scroll up to see more output
4. Press `Ctrl+Shift+/`
5. Type a search term (e.g., "conf")
6. Use `↑`/`↓` to navigate matches
7. Press `Tab` to toggle regex mode
8. Press `Enter` to stay at position
9. Press `Ctrl+Shift+/` again, then `Esc` to return to bottom

**Testing Checklist:**
- [ ] Search window opens in horizontal split
- [ ] Typing shows incremental search results
- [ ] `↑`/`↓` navigation works smoothly
- [ ] `Tab` toggles between literal and regex mode
- [ ] `Ctrl+U` clears the search query
- [ ] `Enter` keeps position and exits search
- [ ] `Esc` scrolls to bottom and exits search
- [ ] Search is fast and responsive

**Issues/Feedback:**
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

**Rating:** ⭐⭐⭐⭐⭐ (1-5 stars)

---

### B.2: Shell Integration - Prompt Navigation

**Test Steps:**
1. Run several commands:
   ```bash
   pwd
   ls -la
   echo "test"
   git status
   df -h
   ```
2. Press `Ctrl+Shift+Z` (jump to previous prompt)
3. Press multiple times to go back further
4. Press `Ctrl+Shift+X` (jump to next prompt)
5. Navigate back and forth

**Testing Checklist:**
- [ ] `Ctrl+Shift+Z` jumps to previous command prompt
- [ ] Multiple presses navigate through command history
- [ ] `Ctrl+Shift+X` jumps to next command prompt
- [ ] Navigation is smooth and predictable
- [ ] Visual indicator shows current position (if any)
- [ ] Works across multiple terminal sessions

**Issues/Feedback:**
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

**Rating:** ⭐⭐⭐⭐⭐ (1-5 stars)

---

### B.3: Show Last Command Output (Ctrl+Shift+G)

**Test Steps:**
1. Run a command with lots of output:
   ```bash
   ls -laR /etc | head -50
   ```
2. Run another command:
   ```bash
   echo "new command"
   ```
3. Press `Ctrl+Shift+G`
4. Check if it shows the output of `ls -laR /etc | head -50`

**Testing Checklist:**
- [ ] `Ctrl+Shift+G` opens last command output
- [ ] Output is complete and not truncated
- [ ] Output is displayed in a readable format (pager or overlay)
- [ ] Easy to exit/close the output view
- [ ] Works correctly after multiple commands

**Issues/Feedback:**
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

**Rating:** ⭐⭐⭐⭐⭐ (1-5 stars)

---

### B.4: Git Diff Integration (git difftool)

**Test Steps:**
1. Navigate to a git repository:
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
   ```
2. Make a small change to a file:
   ```bash
   echo "# test comment" >> README.md
   ```
3. Run git difftool:
   ```bash
   git difftool
   ```
4. Check the side-by-side diff display

**Testing Checklist:**
- [ ] `git difftool` launches kitty diff kitten
- [ ] Side-by-side diff is displayed clearly
- [ ] Syntax highlighting works for code files
- [ ] Navigation between changes is intuitive
- [ ] Colors distinguish added/removed/modified lines
- [ ] Easy to close and return to terminal
- [ ] Diff is readable and useful

**Issues/Feedback:**
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

**Rating:** ⭐⭐⭐⭐⭐ (1-5 stars)

**After Testing:**
```bash
# Discard the test change
git restore README.md
```

---

### B.5: SSH Kitten (Remote Terminal)

**Prerequisites:** You need a remote server to SSH into

**Test Steps:**
1. SSH to a remote server:
   ```bash
   ssh user@remote-host
   ```
2. Check if terminfo is automatically copied
3. Run commands on remote server
4. Check for "unknown term type" errors
5. Test terminal features (colors, cursor, etc.)

**Testing Checklist:**
- [ ] SSH connection works via `ssh` command (aliased to kitty +kitten ssh)
- [ ] No "unknown term type" errors on remote
- [ ] Terminal colors work correctly on remote
- [ ] Cursor and special characters display properly
- [ ] Remote prompt looks correct
- [ ] Shell integration works on remote (if possible)
- [ ] Connection is stable

**Issues/Feedback:**
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

**Rating:** ⭐⭐⭐⭐⭐ (1-5 stars)

**Note:** If you don't have a remote server to test, mark as N/A

---

## 🐛 Issues & Bug Reports

### Issue Template

**Issue #1:**
- **Feature:** _______________________________________________
- **Expected Behavior:** _____________________________________
- **Actual Behavior:** _______________________________________
- **Steps to Reproduce:**
  1. ___________________________________________________________
  2. ___________________________________________________________
  3. ___________________________________________________________
- **Screenshot/Logs:** (if applicable)
- **Priority:** 🔴 High / 🟡 Medium / 🟢 Low

**Issue #2:**
- **Feature:** _______________________________________________
- **Expected Behavior:** _____________________________________
- **Actual Behavior:** _______________________________________
- **Steps to Reproduce:**
  1. ___________________________________________________________
  2. ___________________________________________________________
  3. ___________________________________________________________
- **Screenshot/Logs:** (if applicable)
- **Priority:** 🔴 High / 🟡 Medium / 🟢 Low

---

## 💡 Suggestions & Improvements

### Feature Requests

**Suggestion #1:**
- **What:** ____________________________________________________
- **Why:** _____________________________________________________
- **Priority:** 🔴 High / 🟡 Medium / 🟢 Low

**Suggestion #2:**
- **What:** ____________________________________________________
- **Why:** _____________________________________________________
- **Priority:** 🔴 High / 🟡 Medium / 🟢 Low

---

## 📊 Overall Assessment

### What Works Well ✅
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

### What Needs Improvement ⚠️
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

### Overall Rating (Phase B)
⭐⭐⭐⭐⭐ (1-5 stars)

### Would You Recommend Phase B Features?
- [ ] Yes, essential for my workflow
- [ ] Yes, nice to have
- [ ] Neutral, doesn't matter much
- [ ] No, not useful for me

---

## 🎯 Phase C Interest Level

**Rate your interest in each Phase C feature:**

### C.1: Panel Kitten (Dropdown Terminal)
Interest Level: 🔥🔥🔥🔥🔥 (1-5 flames)

**Comments:**
```
___________________________________________________________________________
```

### C.2: Image Display (icat)
Interest Level: 🔥🔥🔥🔥🔥 (1-5 flames)

**Comments:**
```
___________________________________________________________________________
```

### C.3: Custom Kittens (SRE-specific tools)
Interest Level: 🔥🔥🔥🔥🔥 (1-5 flames)

**Ideas for custom kittens:**
```
___________________________________________________________________________
___________________________________________________________________________
```

---

## 📝 Final Notes

**Testing Date:** _____________________________________________
**Testing Duration:** __________________________________________
**Environment:** Kitty on NixOS (shoshin) with Plasma Desktop
**Ready for Phase C?** ☐ Yes  ☐ No  ☐ Fix issues first

**Additional Comments:**
```
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________
```

---

**Next Steps After Testing:**
1. Share feedback with Claude
2. Fix any reported issues
3. Decide on Phase C implementation
4. Continue with Option 2 (Phase C features)

---

**Maintained By:** Dimitris Tsioumas (Mitsio)
**Session:** kitty-configuration-phase2-continuation
