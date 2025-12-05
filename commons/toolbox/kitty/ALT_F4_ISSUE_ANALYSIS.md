# Kitty Terminal Alt+F4 Issue - Root Cause Analysis and Solutions

**Date:** 2025-12-05
**Environment:** NixOS with KDE Plasma 6 (Wayland)
**Kitty Version:** 0.42.1
**Issue:** Alt+F4 closes terminal immediately without confirmation despite `confirm_os_window_close -1`

---

## Root Cause Analysis

### The Core Problem: Configuration Conflict

Your `kitty.conf` has **TWO conflicting settings** for `confirm_os_window_close`:

```conf
# Line 100
confirm_os_window_close -1

# Line 358 (OVERRIDES the above!)
confirm_os_window_close 0
```

**This is the primary issue.** The second setting (line 358) overrides the first one, effectively disabling close confirmation.

### Secondary Issue: KDE Plasma Wayland Window Manager Interception

Even with the correct `confirm_os_window_close -1` setting, there's a **fundamental architectural limitation** on KDE Plasma Wayland:

1. **KDE Plasma intercepts Alt+F4 at the compositor level** before kitty receives it
2. Your global shortcuts config shows: `Window Close=Alt+F4,Alt+F4,Close Window`
3. On Wayland, the compositor (KWin) handles window management shortcuts **before** applications can intercept them
4. Your `map alt+f4 close_os_window` keybinding (line 165) **never gets triggered** because KWin already consumed the keypress

### How Wayland Differs from X11

**On X11:**
- Applications can grab keyboard input directly
- Kitty could intercept Alt+F4 before the window manager
- `map alt+f4 close_os_window` would work

**On Wayland (your environment):**
- Compositor (KWin) has exclusive control over input routing
- Global shortcuts are processed by the compositor first
- Applications receive keystrokes **only after** the compositor decides not to handle them
- Alt+F4 is registered as a KWin global shortcut → never reaches kitty

### Research Findings

From the web research:

1. **Kitty Issue #8450**: Confirmed that `confirm_os_window_close -1` should work, but only for close events that kitty controls (like keybindings, not OS window manager close buttons)

2. **Wayland Keyboard Shortcuts Inhibit Protocol**: Applications can request the compositor to temporarily disable its shortcuts, but:
   - This requires explicit application support
   - Kitty does not currently implement this protocol for general use
   - The compositor can still reserve certain shortcuts (like Alt+F4)

3. **KDE Plasma Wayland Bug #443129**: Window rules like "Closeable" don't work reliably on Wayland, indicating window management behavior differences

4. **General Wayland Architecture**: Unlike X11's `xbindkeys`, Wayland requires applications to negotiate shortcuts with the compositor, and there's no universal standard

---

## Solutions (Ranked by Reliability)

### Solution 1: Fix the Configuration Conflict (IMMEDIATE)

**Reliability:** ⭐⭐⭐⭐⭐ (100% - for keybinding-triggered closes)

**Action:**
1. Remove the duplicate/conflicting line 358 in `kitty.conf`
2. Keep only line 100 with `confirm_os_window_close -1`

**Implementation:**

```bash
# Edit the config managed by chezmoi
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles/dot_config/kitty
# Remove line 358: confirm_os_window_close 0
```

**Edit required:**

```diff
  # Shell integration (enables features like auto-complete, working directory tracking)
  shell_integration enabled

- # Confirm before closing window with running programs
- confirm_os_window_close 0

  # ====================================
  # End of Kitty Configuration
  # ====================================
```

**Apply:**
```bash
chezmoi apply ~/.config/kitty/kitty.conf
kitty @ load-config  # Reload config in running kitty instances
```

**What this fixes:**
- Close confirmation will work for `Ctrl+Shift+Q` (close_tab)
- Close confirmation will work for `Ctrl+Shift+W` (close_window)
- Close confirmation will work for `Super+Q` (if mapped to close_os_window)

**What this DOES NOT fix:**
- Alt+F4 will still close immediately (because KWin intercepts it)
- Clicking the window's X button will still close immediately (OS window manager close)

---

### Solution 2: Remap Alt+F4 to a Different Action in KDE (RECOMMENDED)

**Reliability:** ⭐⭐⭐⭐ (90% - requires KDE configuration)

**Concept:** Since KWin intercepts Alt+F4, unbind it at the KDE level and use a kitty-controlled shortcut instead.

**Implementation:**

#### Step 1: Disable Alt+F4 in KDE Global Shortcuts

```bash
# Open KDE System Settings
systemsettings

# Navigate to:
# Shortcuts → Shortcuts → KWin → Window Close
# Change Alt+F4 to something else (like Meta+F4) or disable it entirely
```

**OR via command line (if kwriteconfig6 available):**

```bash
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" "Meta+F4,none,Close Window"
qdbus org.kde.KWin /KWin reconfigure
```

#### Step 2: Verify kitty.conf has proper mapping

Your current config already has (line 165):
```conf
map alt+f4 close_os_window
```

This will now work because Alt+F4 is no longer intercepted by KWin.

#### Step 3: Test

1. Press Alt+F4 in kitty
2. You should see: "Are you sure you want to close this OS window? [y/n]"

**Pros:**
- Complete control over Alt+F4 behavior in kitty
- Works for all kitty instances
- Preserves muscle memory (Alt+F4 still closes windows)

**Cons:**
- Alt+F4 won't close OTHER applications (like browsers, editors) unless you remap those too
- Affects system-wide behavior

---

### Solution 3: Use a Custom Close Shortcut (ALTERNATIVE)

**Reliability:** ⭐⭐⭐⭐⭐ (100% - no system changes needed)

**Concept:** Accept that Alt+F4 is owned by KDE, and use a different shortcut for safe closing.

**Implementation:**

Add a new keybinding in `kitty.conf`:

```conf
# Safe close with confirmation (Ctrl+Alt+Q or Super+Q)
map ctrl+alt+q close_os_window
# OR
map super+q close_os_window
```

**Apply:**
```bash
chezmoi apply ~/.config/kitty/kitty.conf
kitty @ load-config
```

**Usage:**
- Press `Ctrl+Alt+Q` (or `Super+Q`) instead of Alt+F4
- Kitty will show confirmation: "Are you sure you want to close this OS window? [y/n]"

**Pros:**
- Works immediately, no system configuration changes
- Doesn't interfere with KDE's Alt+F4 for other apps
- Reliable and predictable

**Cons:**
- Requires breaking the Alt+F4 habit
- Need to remember a new shortcut

---

### Solution 4: KDE Window Rules (PARTIAL WORKAROUND)

**Reliability:** ⭐⭐ (40% - limited effectiveness on Wayland)

**Concept:** Use KDE window rules to make kitty windows non-closeable or require confirmation.

**Implementation:**

```bash
# Open KDE System Settings
systemsettings

# Navigate to:
# Window Management → Window Rules → Add New

# Configure:
# Window class (application): kitty
# Window types: Normal Window
# Add Property: Closeable → Force → No
```

**OR via command line:**

Create `/home/mitsio/.config/kwinrulesrc`:

```ini
[1]
Description=Kitty Close Protection
wmclass=kitty kitty
wmclassmatch=1
closeable=false
closeablerule=2
```

Then reconfigure KWin:
```bash
qdbus org.kde.KWin /KWin reconfigure
```

**What this does:**
- Prevents the X button from closing kitty
- Alt+F4 might still work (KDE bug on Wayland)
- Can make windows feel "stuck" if you genuinely want to close them

**Pros:**
- System-level protection

**Cons:**
- Unreliable on Wayland (KDE bug #443129)
- Makes it hard to close kitty even when you want to
- Doesn't provide "confirm and close" behavior, just blocks closing

**Verdict:** Not recommended as a primary solution.

---

### Solution 5: Shell-Level Trap (MINIMAL PROTECTION)

**Reliability:** ⭐ (20% - very limited)

**Concept:** Trap SIGHUP in bash to prompt before exit.

**Implementation:**

Add to `~/.bashrc`:

```bash
# Trap SIGHUP (sent when terminal closes)
trap 'read -p "Terminal closing, are you sure? [y/N] " -n 1 -r; echo; if [[ ! $REPLY =~ ^[Yy]$ ]]; then return; fi' SIGHUP
```

**Limitations:**
- Only works if bash is the shell
- KWin's Alt+F4 sends SIGKILL or similar, which cannot be trapped
- Unreliable timing (terminal might close before the prompt displays)
- Does not work for the OS window close event

**Verdict:** Not effective for this use case.

---

## Recommended Implementation Plan

### Immediate Actions (Fix Config)

1. **Remove the conflicting `confirm_os_window_close 0` from line 358**

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles/dot_config/kitty
# Edit kitty.conf and remove line 358
```

2. **Apply changes**

```bash
chezmoi apply ~/.config/kitty/kitty.conf
# In a running kitty instance:
kitty @ load-config
# OR press Ctrl+Shift+F5 (your configured reload shortcut)
```

3. **Test with keybindings** (these should now show confirmation):
   - `Ctrl+Shift+Q` (close tab)
   - `Ctrl+Shift+W` (close window)

### Long-term Solution (Choose One)

**Option A: Remap Alt+F4 System-Wide (Recommended for consistent behavior)**

```bash
# KDE System Settings → Shortcuts → KWin → Window Close
# Change Alt+F4 to Meta+F4 or disable

# OR command line:
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" "Meta+F4,none,Close Window"
qdbus org.kde.KWin /KWin reconfigure
```

**Option B: Use Custom Shortcut (Recommended for minimal system impact)**

Add to `kitty.conf`:
```conf
# Custom safe-close shortcut
map ctrl+alt+q close_os_window
```

Train yourself to use `Ctrl+Alt+Q` instead of `Alt+F4` for kitty.

---

## Testing Checklist

After implementing Solution 1 (config fix):

- [ ] `Ctrl+Shift+W` shows confirmation prompt
- [ ] `Ctrl+Shift+Q` shows confirmation prompt
- [ ] `Alt+F4` still closes immediately (expected - KWin intercepts)

After implementing Solution 2 (remap Alt+F4):

- [ ] `Alt+F4` in kitty shows confirmation prompt
- [ ] `Alt+F4` in other apps still works (or adjust as needed)

After implementing Solution 3 (custom shortcut):

- [ ] `Ctrl+Alt+Q` (or `Super+Q`) shows confirmation prompt
- [ ] `Alt+F4` still closes immediately (expected behavior)

---

## Additional Context: Why `map alt+f4 close_os_window` Doesn't Work

From your config (line 165):
```conf
map alt+f4 close_os_window
```

**Why this keybinding is never triggered:**

1. User presses `Alt+F4`
2. **KWin (Wayland compositor) intercepts the keypress** (because it's registered in `kglobalshortcutsrc`)
3. KWin executes its "Window Close" action → sends close signal to kitty
4. Kitty receives **WM_DELETE_WINDOW** (or Wayland equivalent), not a keyboard event
5. **Kitty never sees the `Alt+F4` keypress** → your `map alt+f4` binding is never evaluated
6. Because `confirm_os_window_close 0` (line 358), kitty closes immediately

**The fix:**
- Remove `confirm_os_window_close 0` (fixes config conflict)
- Either unbind Alt+F4 in KDE (so kitty receives the keypress), or use a different shortcut

---

## References

- [Kitty Documentation: confirm_os_window_close](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.confirm_os_window_close)
- [Kitty Issue #8450: Disable close confirmation](https://github.com/kovidgoyal/kitty/issues/8450)
- [Wayland Keyboard Shortcuts Inhibit Protocol](https://wayland.app/protocols/keyboard-shortcuts-inhibit-unstable-v1)
- [KDE Bug #443129: Closeable window rule doesn't work on Wayland](https://bugs.kde.org/show_bug.cgi?id=443129)
- [Kitty Issue #3960: confirm_os_window_close ignored](https://github.com/kovidgoyal/kitty/issues/3960)

---

## Action Confidence Summary

| Action | Confidence | Band |
|--------|-----------|------|
| Root cause identification (config conflict) | 0.98 | C |
| KDE Plasma Wayland Alt+F4 interception analysis | 0.92 | C |
| Solution 1 effectiveness (config fix) | 0.95 | C |
| Solution 2 effectiveness (remap Alt+F4) | 0.88 | C |
| Solution 3 effectiveness (custom shortcut) | 0.95 | C |
| Solution 4 effectiveness (window rules) | 0.45 | B |
| Solution 5 effectiveness (shell trap) | 0.25 | A |

---

Time: 2025-12-05T14:32:00+02:00 (Europe/Athens)
Tokens: in=51153, out≈4200, total≈55353, usage≈27.7% of context
