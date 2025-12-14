# Kitty Terminal Enhancements & Integrations - Master Plan

**Created:** 2025-11-30
**Last Updated:** 2025-12-14
**Status:** PHASES A, B, C.1, D COMPLETE ✅ | PHASE C.2 PENDING USER INPUT
**Total Time Invested:** ~8 hours
**Remaining:** 3-6 hours (Phase C.2 + Advanced Status Bar)

---

## 📋 Executive Summary

This comprehensive plan documents all kitty terminal enhancements from basic improvements through advanced integrations with Zellij multiplexer and custom status bars. It consolidates all previous plans into a single source of truth.

**Completed Features:**
- ✅ Phase A: Basic enhancements (right-click, navigation, transparency)
- ✅ Phase B: Essential kittens (search, git diff, shell integration, ssh)
- ✅ Phase C.1: Panel kitten, theme cycling
- ✅ Phase D: Zellij integration (installed and configured)

**Pending Features:**
- ⏳ Phase C.2: Interactive scrollbar, tab bar customization, autocomplete
- 📋 Phase E: Advanced status bar with SRE metrics (optional)

---

## 🎯 Overall Goals

1. **Enhance kitty usability** - Better mouse/keyboard shortcuts
2. **Add powerful kittens** - Search, diff, ssh, panel
3. **Integrate with Zellij** - Modern terminal multiplexer
4. **Advanced status bar** - Real-time system metrics for SRE workflows
5. **Declarative management** - All configs via chezmoi + home-manager

---

## ✅ PHASE A: Basic Kitty Enhancements (COMPLETE)

**Status:** ✅ COMPLETE (2025-12-01)
**Time:** 30-45 minutes
**Risk:** Low

### Implemented Features

1. **Right-Click Paste**
   ```conf
   mouse_map right press ungrabbed paste_from_clipboard
   ```

2. **Ctrl+Alt+Arrow Window Navigation**
   ```conf
   map ctrl+alt+left neighboring_window left
   map ctrl+alt+right neighboring_window right
   map ctrl+alt+up neighboring_window up
   map ctrl+alt+down neighboring_window down
   ```

3. **Enhanced Transparency Control**
   - Ctrl+Shift+A, M/L - Adjust opacity
   - Theme: Catppuccin Mocha (later switched to Dracula)
   - Transparency: 0.15 (85% transparent)

### Success Criteria Met

- ✅ Right-click paste works
- ✅ Ctrl+Alt+Arrow navigation works
- ✅ Existing shortcuts still work
- ✅ Theme and transparency configured
- ✅ Changes committed to dotfiles repo

---

## ✅ PHASE B: Essential Kittens & Integrations (COMPLETE)

**Status:** ✅ COMPLETE (2025-12-01 02:15)
**Time:** ~2 hours
**Risk:** Low

### B.1: Search Kitten ✅

**Purpose:** Incremental search in scrollback buffer (like tmux `/`)

**Installation:**
```bash
cd ~/.config/kitty
git clone https://github.com/trygveaa/kitty-kitten-search kitty_search
```

**Configuration:**
```conf
map ctrl+shift+/ launch --location=hsplit --allow-remote-control kitty +kitten kitty_search/search.py @active-kitty-window-id
```

**Features:**
- Incremental search while typing
- Regex support (Tab to toggle)
- Keyboard navigation (↑/↓ for matches)

**Status:** ✅ Installed and configured

---

### B.2: Shell Integration ✅

**Purpose:** Advanced terminal features with command markers

**Configuration in `~/.bashrc`:**
```bash
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi
```

**Kitty keybindings:**
```conf
# Jump to previous/next command prompt
map ctrl+shift+z scroll_to_prompt -1
map ctrl+shift+x scroll_to_prompt 1

# Show last command output
map ctrl+shift+g show_last_command_output
```

**Features:**
- Jump between command prompts
- Show last command output
- Better clipboard integration
- Directory tracking for new windows

**Status:** ✅ Fully configured and working

---

### B.3: Git Diff Integration ✅

**Purpose:** Use kitty's diff kitten as git difftool

**Configuration in `~/.gitconfig`:**
```ini
[diff]
    tool = kitty
[difftool "kitty"]
    cmd = kitty +kitten diff $LOCAL $REMOTE
    trustExitCode = true
[difftool]
    prompt = false
[core]
    editor = codium
```

**Features:**
- Side-by-side diffs with syntax highlighting
- Image diffing support
- Fast GPU rendering
- VSCodium as git editor

**Status:** ✅ Configured and tested

---

### B.4: SSH Kitten ✅

**Purpose:** Better SSH with automatic terminfo copying

**Configuration in `~/.bashrc`:**
```bash
if test -n "$KITTY_INSTALLATION_DIR"; then
    alias ssh="kitty +kitten ssh"
fi
```

**Benefits:**
- Automatically copies terminfo (no more "unknown term type")
- Can copy shell config (`.bashrc`, `.vimrc`)
- Connection reuse for low latency
- Shell integration works on remote

**Status:** ✅ Aliased and working

---

## ✅ PHASE C.1: Panel Kitten & Theme Enhancements (COMPLETE)

**Status:** ✅ COMPLETE (2025-12-01 04:45)
**Time:** ~1 hour
**Risk:** Low

### C.1.1: Panel Kitten (Quake-Style Terminal) ✅

**Purpose:** Dropdown terminal accessible via F12

**Configuration:**
```conf
# Dropdown terminal (Quake-style)
map f12 kitten panel --edge top --size 0.5
```

**Features:**
- Toggle dropdown from any edge
- Configurable size
- Runs arbitrary programs
- GPU-accelerated

**Status:** ✅ Configured (needs user platform testing)

**Known Issue:** Platform-dependent support (KDE Plasma partial)

---

### C.1.2: Theme Cycling Browser ✅

**Purpose:** Browse and switch between 300+ themes

**Configuration:**
```conf
map ctrl+shift+f9 kitten themes
```

**Usage:**
```bash
kitty +kitten themes --reload-in=all Dracula
```

**Features:**
- Preview themes live
- 300+ built-in themes
- Quick theme switching
- Apply to all windows

**Status:** ✅ Configured (user reported issue, needs investigation)

---

## ⏳ PHASE C.2: Enhanced Terminal Experience (RESEARCH COMPLETE)

**Status:** 🔬 RESEARCH COMPLETE - Awaiting User Clarifications
**Research Date:** 2025-12-01 20:00
**Implementation:** PENDING USER INPUT
**Estimated Time:** 3-5 hours

### C.2.1: Tab Navigation Enhancements ✅

**Status:** ✅ COMPLETE - User approved

**Implemented:**
- Alt+Left/Right (browser-style) - **RECOMMENDED**
- Alt+H/L (vim-style)
- Ctrl+PageUp/PageDown (firefox-style)
- Ctrl+Shift+Left/Right (original, kept for compatibility)
- Extended to 9 tabs (Ctrl+Alt+1-9)

---

### C.2.2: Terminal Shortcuts Helper ✅

**Status:** ✅ COMPLETE

**Implemented:**
- Navi cheatsheets (basic + extended)
- Bashrc helpers: `kh`, `khe`, `ks`, `kitty-shortcuts`
- Daily reminder system (non-intrusive, once per day)

**Files:**
- `dotfiles/dot_local/share/navi/cheats/kitty-basic.cheat`
- `dotfiles/dot_local/share/navi/cheats/kitty-extended.cheat`

---

### C.2.3: Interactive Scrollbar ✅

**Status:** ✅ IMPLEMENTED (2025-12-01) - Awaiting User Testing

**Configuration:**
```conf
scrollbar scrolled              # Show when scrolling
scrollbar_interactive yes       # Make clickable/draggable
scrollbar_jump_on_click yes     # Jump to clicked location
scrollbar_width 0.5             # Width in cells
scrollbar_handle_opacity 0.6    # Handle transparency
scrollbar_track_opacity 0.3     # Track transparency
```

**Features:**
- Fully interactive (click, drag, scroll)
- Highly customizable appearance
- Shows position in scrollback buffer
- GPU-accelerated

**Next:** User to test clickability and drag

---

### C.2.4: Tab Bar Position & Configuration 🔬

**Status:** RESEARCH COMPLETE - User to decide

**Research Finding:** Kitty supports:
- ✅ Tab bar at TOP: `tab_bar_edge top`
- ✅ Tab bar at BOTTOM: `tab_bar_edge bottom` (default)
- ✅ Custom tab title templates
- ❌ Per-window status bars (workaround: use Zellij zjstatus)

**Recommended Solution (from 2025-12-08 research):**
```
┌─────────────────────────────────────────┐
│ [Tab 1] [Tab 2] [Tab 3]   ← Kitty tab bar (TOP)
├─────────────────────────────────────────┤
│                                         │
│     Terminal content                    │
│     (managed by Zellij panes)           │
│                                         │
├─────────────────────────────────────────┤
│ git:main | ~/path | 15:30  ← Zellij zjstatus (BOTTOM)
└─────────────────────────────────────────┘
```

**Pending User Decisions:**
- [ ] Move tab bar to top: `tab_bar_edge top` ✅ (2025-12-08)
- [ ] Add F2/Shift+F2 for quick tab renaming ✅ (2025-12-08)
- [ ] Customize `active_tab_title_template` for detailed info
- [ ] Optional: Git branch via custom Python `tab_bar.py`

**Reference:** `docs/plans/kitty-advanced-statusbar-plan.md`

---

### C.2.5: Terminal History Export 🔬

**Status:** NEEDS DESIGN - Waiting for user preferences

**Requirements to clarify:**
- [ ] Export format (markdown with timestamps?)
- [ ] Export scope (entire session or scrollback only?)
- [ ] Include commands + output or just commands?
- [ ] Keyboard shortcut (Ctrl+Shift+H suggested)

**Estimate:** 1 hour after clarifications

---

### C.2.6: Panel Kitten Debugging (F12) 🐛

**Status:** NEEDS USER TESTING

**Known Issue:** F12 may not work on KDE Plasma

**User to test and report:**
- [ ] What happens when pressing F12?
- [ ] Panel appears?
- [ ] Nothing happens?
- [ ] Error message?

**Estimate:** 30 mins debugging after user feedback

---

### C.2.7: Right-Click Behavior ❌

**Status:** NOT POSSIBLE - Documented

**Research Finding:** Kitty does NOT support context menus by design

**Current Behavior:** Right-click = paste (implemented in Phase A)

**Decision:** Keep keyboard-first workflow

---

### C.2.8: Autocomplete.sh Integration 🔬

**Status:** NEEDS DEEP RESEARCH (2-3 hours)

**Research Finding:** Atuin integration exists

**Repository:** TIAcode/LLMShellAutoComplete

**Tasks:**
- [ ] Web research for best integration approach
- [ ] Test autocomplete.sh with Atuin history
- [ ] Configure LLM backend (requires API keys)
- [ ] Integrate with kitty shell integration

**Estimate:** 2-3 hours

---

## ✅ PHASE D: Zellij Integration (COMPLETE)

**Status:** ✅ INSTALLED AND CONFIGURED (2025-12-08)
**Version:** Zellij 0.43.1
**Time:** 2-3 hours
**Risk:** Low

### D.1: Zellij Installation ✅

**Method:** Home-Manager

**File:** `home-manager/zellij.nix` or added to `shell.nix`

```nix
{
  home.packages = with pkgs; [
    zellij
  ];
}
```

**Verification:**
```bash
which zellij  # /nix/store/.../bin/zellij
zellij --version  # zellij 0.43.1
```

**Status:** ✅ Installed via home-manager

---

### D.2: Zellij Configuration ✅

**Location:** `~/.config/zellij/config.kdl` (managed by chezmoi)

**Configuration:**
```kdl
// Theme matching kitty
theme "catppuccin-mocha"

// UI Settings
simplified_ui true
pane_frames false  // Currently disabled per user preference
default_shell "bash"
mouse_mode true

// Scrollback
scroll_buffer_size 10000

// Clipboard (Wayland - KDE Plasma)
copy_command "wl-copy"
copy_on_select true
```

**Status:** ✅ Configured with Catppuccin Mocha theme

---

### D.3: zjstatus Plugin ✅

**Location:** `~/.config/zellij/plugins/zjstatus.wasm`

**Configuration:** Integrated in `config.kdl`

**Features:**
- Mode indicator (NORMAL, PANE, TAB, etc.) with colors
- Tab list with active tab highlighting
- Session name display
- DateTime (Europe/Athens timezone)
- Catppuccin Mocha color scheme

**Status:** ✅ Installed and configured

---

### D.4: Layouts (Optional)

**Created:**
- `default.kdl` - Simple single-pane layout
- `dev.kdl` - Editor (70%) + Terminal (30%)
- `ops.kdl` - Logs (50%) + Monitor (25%) + Shell (25%)

**Usage:**
```bash
zellij --layout dev attach -c myproject
zellij --layout ops attach -c monitoring
```

**Status:** ✅ Layouts created (optional, user can expand)

---

### D.5: Navi Cheatsheets ✅

**Files:**
- `dotfiles/dot_local/share/navi/cheats/zellij.cheat` - Complete zellij reference
- Updated `kitty.cheat` with new shortcuts

**Status:** ✅ Cheatsheets created

---

## 📋 PHASE E: Advanced Status Bar (OPTIONAL - PLANNED)

**Status:** PLANNED - Comprehensive plan exists
**Priority:** OPTIONAL (nice-to-have for SRE workflows)
**Estimated Time:** 6-8 hours
**Plan File:** `docs/plans/kitty-advanced-statusbar-plan.md` (will be archived)

### Proposed Features

**Custom Python `tab_bar.py` with:**

1. **System Metrics**
   - CPU usage (refresh 3s, color-coded)
   - RAM usage (refresh 5s, color-coded)
   - Disk usage for `/` (refresh 10s)
   - Disk usage for `/backups/` (refresh 10s)
   - Network stats (↑/↓ speeds, refresh 3s)

2. **SRE/DevOps Info**
   - **K8s context** ⭐ CRITICAL - Yellow background + ⚠️ for prod
   - Container count (Docker/Podman)
   - Git branch (current repo)
   - Time (HH:MM, Europe/Athens)

3. **Visual Design**
   - Dracula theme colors
   - Color-coded thresholds (green/yellow/red)
   - Transparency-friendly
   - Readable at a glance

### Implementation Phases (if pursued)

**Phase E.1:** Setup & Basic Structure (45 mins)
**Phase E.2:** System Metrics (1.5 hours)
**Phase E.3:** K8s & Container Metrics (1 hour)
**Phase E.4:** Network, Git, Time (1 hour)
**Phase E.5:** Visual Polish & Optimization (1 hour)
**Phase E.6:** Testing & Documentation (30 mins)

### Decision

**User to decide:** Pursue advanced status bar or use Zellij zjstatus?

**Current Recommendation:** Use Zellij zjstatus for status bar needs (already installed)

---

## 🎯 Success Criteria

### Overall Project Success

**Completed:**
- ✅ Kitty enhanced with better shortcuts (Phase A)
- ✅ Essential kittens installed and working (Phase B)
- ✅ Panel kitten and themes configured (Phase C.1)
- ✅ Zellij integrated with zjstatus (Phase D)

**Pending:**
- [ ] User clarifications for Phase C.2 features
- [ ] User testing: scrollbar, F12 panel
- [ ] Decision on advanced status bar (Phase E)

### User Acceptance

- [x] User approves basic enhancements ✅
- [x] User approves zellij integration ✅
- [ ] User tests scrollbar clickability
- [ ] User decides on tab bar position
- [ ] User decides on history export format
- [ ] User decides on advanced status bar

---

## 📊 Implementation Status Summary

| Phase | Description | Status | Time Spent |
|-------|-------------|--------|------------|
| A | Basic Enhancements | ✅ COMPLETE | 30-45 min |
| B | Essential Kittens | ✅ COMPLETE | 2 hours |
| C.1 | Panel & Themes | ✅ COMPLETE | 1 hour |
| C.2 | Enhanced Experience | 🔬 RESEARCH DONE | 2 hours |
| D | Zellij Integration | ✅ COMPLETE | 2-3 hours |
| E | Advanced Status Bar | 📋 PLANNED | - |
| **Total** | | **~70% Complete** | **~8 hours** |

---

## 📚 Documentation References

### Official Resources

- **Kitty Docs:** https://sw.kovidgoyal.net/kitty/
- **Kitty Kittens:** https://sw.kovidgoyal.net/kitty/kittens_intro/
- **Zellij Docs:** https://zellij.dev/
- **zjstatus Plugin:** https://github.com/dj95/zjstatus

### Project Documentation

**Research:**
- `docs/researches/2025-12-01_kitty_comprehensive_research.md`
- `docs/researches/2025-12-07_kitty_tab_bar_window_bars_research.md`
- `docs/researches/2025-12-08_kitty_per_pane_status_bars_research.md`
- `docs/researches/2025-12-07-warp-kitty-mcp-integration-research.md` (Warp integration)

**Tools:**
- `docs/tools/kitty/README.md` (consolidated guide)
- `docs/tools/kitty/TROUBLESHOOTING.md`

**Related Active Plans:**
- `2025-11-30-kitty-integration-verification-plan.md` - Testing/QA checklist for all integrations
- `2025-12-07-warp-kitty-integration-and-mcp-plan.md` - Warp + Kitty + MCP 3-tier integration
- `2025-11-30-autocomplete-sh-integration-plan.md` - AI autocomplete (Phase C.2.6 implementation)

**Archived Plans:**
- `archive/plans/kitty-enhancements-plan-01-12-2025.md` (merged into this plan)
- `archive/plans/kitty-kittens-enhancements-plan-03-12-2025.md` (merged into this plan)
- `archive/plans/kitty-advanced-statusbar-plan-02-12-2025.md` (merged into this plan)
- `archive/plans/kitty-zellij-phase1-plan-01-12-2025.md` (merged into this plan)
- `archive/plans/2025-11-30-kitty-advanced-features-plan.md` (zellij layouts - completed)
- `archive/plans/2025-12-01-zellij-installation-and-integration-with-kitty-plan.md` (completed)
- `archive/plans/2025-12-01-zjstatus-integration-plan.md` (zjstatus - completed)

**Session History:**
- `sessions/kitty-configuration/ARCHIVE_NOTE.md` (points to new locations)
- `sessions/summaries/*KITTY*.md` (session summaries)

---

## 🔄 Related Integrations

### VSCodium Integration ✅

**Status:** COMPLETE

**Configuration:**
- VSCodium as default editor
- Git editor integration
- Open files from hints kitten
- Open files at specific line numbers

### Navi Integration ✅

**Status:** COMPLETE

**Cheatsheets:**
- `kitty-basic.cheat` - Essential shortcuts
- `kitty-extended.cheat` - Complete reference
- `zellij.cheat` - Zellij commands

**Helpers:**
- `kh` - Show basic cheatsheet
- `khe` - Show extended cheatsheet
- `ks` - Quick shortcuts reference

---

## 🐛 Known Issues & Limitations

### Platform-Specific

1. **F12 Panel Kitten**
   - KDE Plasma: Partial support (clicks outside may hide panel)
   - GNOME Wayland: No support
   - Workaround: Use window splits

2. **Per-Window Status Bars**
   - NOT natively supported by kitty
   - Workaround: Use Zellij zjstatus for bottom status bar

3. **Clickable Status Bar Elements**
   - NOT supported by kitty design
   - Philosophy: Keyboard-first terminal

### Configuration

1. **Theme Browser**
   - User reported issue (needs investigation)
   - Temporary: Use `kitty +kitten themes --reload-in=all ThemeName`

---

## 📅 Next Steps

### Immediate Actions (User)

1. **Test Implemented Features:**
   - [ ] Test scrollbar clickability
   - [ ] Test F12 panel kitten (report what happens)
   - [ ] Test tab navigation shortcuts

2. **Provide Clarifications for Phase C.2:**
   - [ ] Tab bar position preference (top or bottom?)
   - [ ] History export format preferences
   - [ ] Right-click behavior preference
   - [ ] Describe theme browser issue

3. **Make Decisions:**
   - [ ] Pursue advanced status bar (Phase E)?
   - [ ] Or use Zellij zjstatus for status needs?

### Future Enhancements (Optional)

- [ ] Custom kittens for SRE workflows
- [ ] More zellij layouts
- [ ] Autocomplete.sh integration
- [ ] Advanced automation with kitty remote control

---

## ✅ Completion Checklist

### Planning & Research

- [x] Research completed for all phases ✅
- [x] User requirements gathered ✅
- [x] Technical approaches defined ✅
- [x] Implementation tested ✅

### Implementation

- [x] Phase A: Basic Enhancements ✅
- [x] Phase B: Essential Kittens ✅
- [x] Phase C.1: Panel & Themes ✅
- [ ] Phase C.2: Enhanced Experience (awaiting user)
- [x] Phase D: Zellij Integration ✅
- [ ] Phase E: Advanced Status Bar (optional)

### Documentation

- [x] Session summaries created ✅
- [x] Comprehensive research documented ✅
- [x] Plans consolidated into this file ✅
- [x] Navi cheatsheets created ✅
- [ ] User guide complete (pending Phase C.2)

### Repository Management

- [x] All changes committed to dotfiles ✅
- [x] All changes committed to home-manager ✅
- [x] All changes committed to docs ✅
- [x] All repos pushed to remote ✅

---

## 🎬 Conclusion

**Overall Status:** Highly successful implementation with 70% completion

**What Works Excellently:**
- ✅ Kitty with enhanced shortcuts and kittens
- ✅ Zellij integration with beautiful zjstatus
- ✅ Declarative management via chezmoi + home-manager
- ✅ Comprehensive documentation and cheatsheets

**What's Pending:**
- User clarifications for remaining Phase C.2 features
- User testing of new features
- Decision on advanced status bar

**Recommendation:** Test current setup in daily workflow before adding more features. The existing implementation already provides a powerful, beautiful terminal experience.

---

**Plan Maintained By:** Dimitris Tsioumas (Mitsio)
**Last Updated:** 2025-12-14
**Next Review:** After user testing and clarifications
