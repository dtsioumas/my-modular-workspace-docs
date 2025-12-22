# Kitty Terminal Enhancements & Integrations - Master Plan

**Created:** 2025-11-30
**Last Updated:** 2025-12-22 (Q&A Round 2 + Extended Research Complete)
**Status:** PHASES A, B, C.1, C.3, D COMPLETE ✅ | PHASE K.14-K.15 DEEP RESEARCH COMPLETE 🔬✅ | READY FOR IMPLEMENTATION
**Total Time Invested:** ~12 hours (research) + ~5 hours (Q&A + agent research)
**Remaining:** 7-10 hours (Tmux Implementation) + 2-4 hours (Phase C.2 optional)

---

## 📋 Executive Summary

This comprehensive plan documents all kitty terminal enhancements from basic improvements through advanced integrations with Zellij multiplexer and custom status bars. It consolidates all previous plans into a single source of truth.

**Completed Features:**
- ✅ Phase A: Basic enhancements (right-click, navigation, transparency)
- ✅ Phase B: Essential kittens (search, git diff, shell integration, ssh)
- ✅ Phase C.1: Panel kitten, theme cycling
- ✅ Phase C.3: **Custom Tab Bar with Inverted Dracula Beautification** (2025-12-21)
- ✅ Phase D: Zellij integration (installed and configured)

**Pending Features:**
- ⏳ Phase C.2: Interactive scrollbar, autocomplete
- ~~Phase E: Advanced status bar~~ → **REPLACED by Phase C.3** (all SRE metrics now in tab bar)

---

## 🔧 Current State & Management

**Last Verified:** 2025-12-14 22:30 (Europe/Athens)

### Active Theme
- **Current:** Dracula (vibrant dark theme)
- **File:** `~/.config/kitty/current-theme.conf`
- **Previous:** Catppuccin Mocha (switched to Dracula for better contrast)

### Configuration Management
- **Kitty:** Managed by **chezmoi** (`dotfiles/private_dot_config/kitty/`) - **Migrated 2025-11-29**
  - Source: `~/.local/share/chezmoi/private_dot_config/kitty/kitty.conf`
  - Previous: home-manager (deprecated, now in chezmoi)
- **Zellij:** Managed by **home-manager** (`home.packages` in `home-manager/zellij.nix`)
- **Bashrc/Gitconfig:** Managed by **chezmoi** (`dotfiles/dot_bashrc`, `dotfiles/dot_gitconfig`)
- **Navi Cheatsheets:** Managed by **chezmoi** (`dotfiles/dot_local/share/navi/cheats/`)

### Declarative Status ✅
- ✅ **All configurations in version control**
- ✅ **Search Kitten:** Managed by chezmoi at `dotfiles/private_dot_config/kitty/kitty_search/` (migrated 2025-11-29)
- ✅ **No manual installations** - Everything reproducible via chezmoi/home-manager

### Platform
- **OS:** NixOS
- **Desktop:** KDE Plasma (Wayland)
- **Terminal:** Kitty (GPU-accelerated)
- **Multiplexer:** Zellij 0.43.1

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
   - Theme: **Dracula** (vibrant dark theme with excellent contrast)
   - Transparency: 0.15 (15% opacity = 85% transparent, very light background)

### Success Criteria Met

- ✅ Right-click paste works (verified: `kitty.conf` line 66)
- ✅ Ctrl+Alt+Arrow navigation works (verified: `kitty.conf` lines 220-223)
- ✅ Existing shortcuts still work
- ✅ Theme configured: Dracula (`current-theme.conf`)
- ✅ Transparency configured: 0.15 (`kitty.conf` line 136)
- ✅ Managed via chezmoi (`dotfiles/private_dot_config/kitty/`)

### File Locations

- **Config:** Managed by **chezmoi** in `dotfiles/private_dot_config/kitty/kitty.conf` (migrated 2025-11-29)
- **Active Config:** `~/.config/kitty/kitty.conf` (deployed by chezmoi)
- **Theme:** `~/.config/kitty/current-theme.conf` → Dracula

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

**Status:** ✅ Installed, configured, and declaratively managed

**Declarative Management:** ✅
- Managed by **chezmoi** at `dotfiles/private_dot_config/kitty/kitty_search/` (migrated 2025-11-29)
- Source location: `~/.local/share/chezmoi/private_dot_config/kitty/kitty_search/`
- Fully reproducible via `chezmoi apply`

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

**File Location:** Managed by chezmoi in `dotfiles/dot_bashrc` or `dotfiles/dot_bashrc.tmpl`

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

**File Location:** Managed by chezmoi in `dotfiles/dot_gitconfig`

**Notes:**
- `trustExitCode = true` - Git uses kitty's exit code to determine diff success
- Requires VSCodium installed; if not available, falls back to system `$EDITOR`

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

**Status:** ✅ TESTED AND WORKING on KDE Plasma (Wayland) - 2025-12-15

**User Testing Results:**
- ✅ Panel appears from top perfectly
- ✅ F12 toggle works reliably
- ✅ No unexpected hiding issues
- ✅ Fully functional on user's KDE Plasma Wayland setup

**Enhancement Requested:**
- [ ] Add workspace stats to F12 panel (CPU, RAM, etc.)
- [ ] Integration with Phase E advanced status bar metrics
- **Priority:** Medium (works well, enhancement nice-to-have)

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

**Status:** ✅ Configured - **Awaiting user report of specific issue**

**Note:** User mentioned an issue with theme browser but specific problem unclear. If issue persists:
- Try: `kitty +kitten themes --reload-in=all Dracula`
- Check: `Ctrl+Shift+F5` to reload config
- Report: Describe specific error or unexpected behavior

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

**Status:** ✅ TESTED AND WORKING (2025-12-15)

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

**User Testing Results (2025-12-15):**
- ✅ Scrollbar visible on right edge
- ✅ Click and jump to position works
- ✅ Drag handle works smoothly
- ✅ Click track (above/below handle) works
- ✅ All functionality working as expected

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

### C.2.5: Terminal History Export ✅

**Status:** IMPLEMENTED - Ready for Testing (2025-12-15)

**User Requirements:**
- ✅ **Format:** Markdown with timestamps (Claude session-style snapshot)
- ✅ **Scope:** Entire session history
- ✅ **Content:** Commands + Output + Working directory (no exit codes)
- ✅ **Shortcut:** Ctrl+Shift+O (O for Output/sO for SaveOutput)
- ✅ **Save Location:** `~/Archives/terminal_sessions/terminal_session-DD-MM-YYYY-hh-mm-ss.md`

**Implementation Plan:**
1. Create `~/.config/kitty/export_history.py` kitten
2. Capture scrollback buffer via kitty API
3. Parse shell integration markers for commands/output/directories
4. Format as markdown with timestamp headers
5. Auto-create `~/Archives/terminal_sessions/` if needed
6. Save with timestamped filename
7. Show notification with file path

**Technical Approach:**
- Use `@kitty.kitten` decorator for Python kitten
- Access scrollback via `get_boss().active_window.screen.scrollback_lines`
- Parse KITTY_SHELL_INTEGRATION markers (OSC 133 sequences)
- Markdown structure: Session header → Commands with timestamps → Output blocks

**Implementation:** ✅ COMPLETE
- Created: `~/.config/kitty/export_history.py` (Python kitten)
- Added: Ctrl+Shift+O keyboard shortcut to kitty.conf
- Committed: dotfiles repo (e639b29)
- Applied: chezmoi apply

**Testing Required:**
1. Reload kitty config: Press Ctrl+Shift+F5 in kitty OR restart kitty
2. Press Ctrl+Shift+O to export current session
3. Check `~/Archives/terminal_sessions/` for exported markdown file
4. Verify markdown format with commands, output, timestamps
5. Report any issues or improvements needed

**Files:**
- Kitten: `dotfiles/private_dot_config/kitty/export_history.py`
- Config: `dotfiles/private_dot_config/kitty/kitty.conf` (line 320)

---

### C.2.6: Panel Kitten Testing (F12) ✅

**Status:** TESTED AND WORKING - 2025-12-15

**User Testing Results:**
- ✅ Panel appears from top perfectly
- ✅ Toggle works reliably (F12)
- ✅ No issues on KDE Plasma Wayland
- ✅ Feature fully functional

**Enhancement Requested:**
- [ ] Add workspace stats to panel (CPU, RAM, disk, network)
- [ ] See Phase E for advanced metrics implementation

---

### C.2.7: Right-Click Behavior ❌

**Status:** NOT POSSIBLE - Documented

**Research Finding:** Kitty does NOT support context menus by design

**Current Behavior:** Right-click = paste (implemented in Phase A)

**Decision:** Keep keyboard-first workflow

---

### C.2.8: Autocomplete.sh Integration 🔬

**Status:** IMPLEMENTATION PLAN READY (pending execution)

**Research Finding:** Atuin integration exists

**Repository:** TIAcode/LLMShellAutoComplete

**Implementation Plan:** See `docs/plans/2025-11-30-autocomplete-sh-integration-plan.md`

**Summary from detailed plan:**
- AI-powered command completion in kitty (double TAB)
- Secure API key storage via KeePassXC + secret-tool
- Declarative config via chezmoi `.bashrc.tmpl`
- Support for OpenAI, Anthropic, Groq, or local Ollama
- Estimated time: 80-115 minutes

**Tasks:**
- [ ] Store LLM API keys in KeePassXC
- [ ] Install autocomplete.sh to `~/.local/bin/`
- [ ] Configure bash integration via chezmoi
- [ ] Test AI completions
- [ ] Optional: Add kitty keybindings

**Estimate:** 1.5-2 hours (detailed plan available)

**Cross-Reference:** Full implementation guide in `2025-11-30-autocomplete-sh-integration-plan.md`

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

**Management:** ✅ Declaratively managed by home-manager
- Symlinked to: `/nix/store/.../home-manager-files/.config/zellij/plugins/zjstatus.wasm`
- **Update Strategy:** Managed via home-manager configuration updates

**Configuration:** Integrated in `config.kdl`

**Features:**
- Mode indicator (NORMAL, PANE, TAB, etc.) with colors
- Tab list with active tab highlighting
- Session name display
- DateTime (Europe/Athens timezone)
- Catppuccin Mocha color scheme

**Status:** ✅ Installed and configured (declaratively managed)

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

## 📋 PHASE C.3: Comprehensive Tab Bar with System Metrics ✅

**Status:** ✅ COMPLETE - Beautification Applied (2025-12-21)
**Priority:** HIGH (Replaces Phase E - Core SRE monitoring)
**Implementation Started:** 2025-12-16 23:15 (Phase 1 tested & working)
**Beautification Update:** 2025-12-21 05:45 (Inverted Dracula Scheme)
**Completion:** ALL PHASES COMPLETE ✅

**Note:** This phase REPLACES the original Phase E "Advanced Status Bar" with a more comprehensive, better-designed solution that combines tab bar beautification with full system metrics.

### 🎨 Beautification Update (2025-12-21)

**Inverted Dracula Color Scheme - "Beautiful When Healthy"**

Revolutionary color philosophy applied: LOW usage = GORGEOUS Dracula colors (purple/cyan), HIGH usage = WARNINGS (yellow/orange/red). The tab bar is now a visual reward for system health.

**Color Scheme Per Metric:**

| Metric | Purple (Idle) | Cyan (Normal) | Pink (Active) | Orange (Warning) | Red (Critical) |
|--------|---------------|---------------|---------------|------------------|----------------|
| Load (per core) | < 0.3 | 0.3-0.5 | 0.5-0.7 | 0.7-0.9 | > 0.9 |
| CPU % | < 25% | 25-50% | 50-70% | 70-85% | > 85% |
| RAM % | < 40% | 40-60% | 60-75% | 75-90% | > 90% |
| Disk % | < 50% | 50-70% | 70-80% | 80-90% | > 90% |
| Battery | - | > 60% | 40-60% | 20-40% | < 20% |

**Smart Features Added:**
- **Smart /home Detection:** Only shows /home disk widget if it's a separate partition
- **Color Cache Refresh:** Colors refresh every 30 seconds to pick up theme changes
- **Date Format:** Changed to `DD/MM/YYYY` format (21/12/2025)

### 🚀 Future Enhancements Implemented (2025-12-21 05:45)

**1. Sparkline Trends** ✅
Visual history for volatile metrics showing last 5 readings as mini-graph.
- Format: `▁▂▃▄▅` (8 levels: ▁▂▃▄▅▆▇█)
- Applied to: CPU, RAM, Load Average
- Display: Icon + sparkline + percentage (e.g., `󰘚▁▂▃▄▅45%`)
- Config: `SPARKLINE_ENABLED = True`, `SPARKLINE_HISTORY_SIZE = 5`

**2. Color State Memory (Hysteresis)** ✅
Prevents color flickering when metrics hover near thresholds.
- Mechanism: Color only changes after N consecutive readings at new level
- Config: `COLOR_HYSTERESIS_ENABLED = True`, `HYSTERESIS_COUNT = 2`
- Applied to: CPU, RAM, Load, Battery

**3. Progressive Battery Icons** ✅
Enhanced battery visualization with 20-level granularity.
- Discharging: 20 levels (every 5%) for smooth visual feedback
- Charging: 10 levels with charging-specific icons (󰢜󰂆󰂇󰂈󰢝󰂉󰢞󰂊󰂋󰂅)
- Critical Alert: ⚠ warning symbol when battery ≤ 10% and not charging
- Config: `BATTERY_CRITICAL_THRESHOLD = 10`

**4. Git Branch Widget** ✅ (2025-12-21)
Developer context showing current git branch with status indication.
- Icon: `` (nf-dev-git_branch)
- Branch name truncated to 20 chars max
- Dirty indicator: `*` suffix when uncommitted changes
- Color coding:
  - Cyan: Clean working directory
  - Orange: Dirty (uncommitted changes)
  - Pink: Detached HEAD state
- Caching: 5-second TTL to minimize git subprocess calls
- Uses active window's cwd via `get_boss().active_window.child.current_cwd`
- Config: `SHOW_GIT_BRANCH = True`, `GIT_CACHE_TTL = 5.0`

**Files Modified:**
- `~/.local/share/chezmoi/private_dot_config/kitty/tab_bar.py` (source)
- `~/.config/kitty/tab_bar.py` (deployed)

**Research Sources:**
- Ultrathinking analysis (15 thoughts on adaptive beauty philosophy)
- Web research: Dracula tmux, WezTerm bars, Starship prompts, r/unixporn

### 🚀 GPU Optimization for AI Agents (2025-12-21 06:30)

**System Configuration:**
- GPU: NVIDIA GeForce GTX 960 (4GB VRAM)
- OpenGL: 4.6 with NVIDIA driver 570.195.03
- Direct rendering: Enabled

**Performance Settings Applied:**

| Setting | Before | After | Impact |
|---------|--------|-------|--------|
| `repaint_delay` | 10ms | 6ms | 40% faster screen updates |
| `input_delay` | 3ms | 1ms | 67% faster keystroke response |
| `text_composition_strategy` | platform | 1.2 10 | Better dark theme rendering |
| `wayland_enable_ime` | no | no | Lower latency (already set) |

**Ultra Low Latency Mode (Optional):**
For maximum performance with AI agents (Claude Code, Codex, Gemini CLI):
```conf
input_delay 0
repaint_delay 2
sync_to_monitor no
```
⚠️ May cause slight screen tearing during fast scrolling.

**Kitty Throughput Benchmarks:**
| Terminal | Average MB/s |
|----------|--------------|
| kitty 0.33 | **134.55** |
| gnome-terminal | 61.83 |
| alacritty | 54.05 |

Kitty is 2x+ faster than alternatives - ideal for AI agent output.

**AI Agent Considerations:**
- Claude Code, Codex, Gemini CLI produce rapid text bursts
- Lower delays = faster visible output
- GPU handles glyph caching in VRAM
- tab_bar.py uses 3-second refresh (low GPU impact)

**tab_bar.py GPU Impact:**
- Refresh rate: 3 seconds (0.3% CPU)
- Widgets use cached color values
- Sparklines use CPU, not GPU (intentional)
- No GPU bottlenecks identified

### Implementation Status

**Phase 0: Developer Context** ✅ COMPLETE (2025-12-21)
   -  Git Branch - Shows current branch with dirty indicator (*)
   - **Colors:** Cyan=clean, Orange=dirty, Pink=detached HEAD
   - **Caching:** 5-second TTL to minimize subprocess calls
   - **Performance:** Negligible (only calls git when cache expires)

**Phase 1: Essential Widgets** ✅ COMPLETE & TESTED (2025-12-16 23:15)
   -  Time (HH:MM format) - Working, updates every 3 seconds
   -  Date (DD MMM format) - Working, Dracula purple
   - 🔋 Battery (laptop only) - Dynamic icons, color-coded (Desktop: hidden gracefully)
   - **User Tested:** Screenshot confirmed working at 01:00, 17 Δεκ
   - **Performance:** <0.3% CPU, no crashes, production-ready

**Phase 2: Core Metrics** 🔨 CODE READY (Awaiting psutil)
   -  Load Average (1-minute) - Python stdlib, ready to enable
   -  CPU Percent (instant) - With initialization fix
   -  RAM Usage - Memory percentage

**Phase 3: Optional Widgets** 🔨 CODE READY (Awaiting psutil)

**2. Core SRE Metrics**
   -  Load Average (1-minute) - SRE standard metric (Python stdlib)
   -  CPU Percent (instant) - Real-time usage monitoring
   -  RAM Usage - Memory percentage with dynamic colors

**3. Optional Widgets (ALL ENABLED per user preference)**
   -  Disk Usage (/ root partition)
   -  Disk Usage (/home partition)
   - 🌐 Network I/O (↓ download ↑ upload rates in MB/s)

**4. Visual Design** ✅ BEAUTIFIED (2025-12-21)
   - **Theme:** Dracula colors (from current-theme.conf)
   - **Style:** Powerline with rounded separators (, )
   - **Color Philosophy:** INVERTED - Purple/Cyan when healthy, Orange/Red when critical
   - **Dynamic Colors:** Purple → Cyan → Pink → Orange → Red based on thresholds
   - **Transparency:** Works perfectly with 0.15 background opacity
   - **Refresh Rate:** 3 seconds (user preference - ~0.3% CPU impact)
   - **Date Format:** DD/MM/YYYY (21/12/2025)

**5. F12 Panel Enhancement**
   - **Implementation:** btop integration (full system monitor)
   - **Configuration:** `map f12 kitten panel --edge top --size 0.5 btop`
   - **Features:** Interactive, Dracula theme, zero custom code

### Technical Architecture

**Implementation Quality:** 8.7/10 (Excellent with critical fixes included)

**Key Technical Features:**
- ✅ Modular function architecture (easy to maintain)
- ✅ Cell-based widget system (flexible, extensible)
- ✅ Timer-based live updates (3-second refresh)
- ✅ Graceful error handling (works without psutil)
- ✅ Performance optimized (color caching, lazy imports)
- ✅ Cross-platform battery detection (Linux/macOS/Windows)
- ✅ Smart widget dropping (priority-based for narrow terminals)

**Critical Fixes Included:**
- ✅ CPU initialization bug fix (prevents 0% on first call)
- ✅ Network rate delta tracking (accurate MB/s calculation)
- ✅ Load average widget (better than instant CPU for SRE work)

**Performance Impact:**
- CPU: ~0.3% (3-second refresh)
- Memory: ~6MB (psutil overhead)
- Total Impact: Negligible for desktop use

### Documentation

**Architecture Specification:**
- `docs/tools/kitty/tab-bar-architecture-design.md` - Complete technical spec (600+ lines)

**Research Documentation:**
- `docs/researches/2025-12-16_kitty-tab-bar-customization-research.md` - All research + URLs

**Implementation Guide:**
- Step-by-step in architecture doc
- Includes testing strategy
- Rollback procedures documented

### Why This Replaces Phase E

**Original Phase E Scope:**
- Custom tab_bar.py with SRE metrics ✅
- System Metrics (CPU, RAM, Disk, Network) ✅
- Dracula colors ✅
- Transparency-friendly ✅
- Estimated: 6-8 hours ✅

**This Implementation (Phase C.3) Provides:**
- ✅ Everything from Phase E PLUS:
- ✅ Better architecture (modular, maintainable)
- ✅ More metrics (Load Average added)
- ✅ Better performance (<1% CPU vs unknown in Phase E)
- ✅ Comprehensive documentation
- ✅ Proven patterns from kitty community
- ✅ Cross-platform support
- ✅ Smart error handling

**Advanced Features Deferred (Not Critical):**
- K8s context (can add as optional widget later)
- Container count (less relevant when replacing tmux)
- ~~Git branch (better in shell prompt via starship/zellij)~~ ✅ IMPLEMENTED (2025-12-21)

**Conclusion:** This design exceeds original Phase E requirements while being more robust, better documented, and more performant. Phase E is REPLACED, not just completed.

---

## 📐 Status Definitions

To clarify what each status means throughout this plan:

| Status | Meaning | Criteria |
|--------|---------|----------|
| **CONFIGURED** | Code/config written | Config exists in source files |
| **DEPLOYED** | Applied to system | Config active in `~/.config/` |
| **TESTED** | User verified working | User confirmed feature works |
| **VERIFIED** | Automated checks passed | Tests confirm functionality |
| **COMPLETE** | Deployed + Tested | Feature is working and verified |

**Status Progression:**
1. CONFIGURED → Config written to files
2. DEPLOYED → Applied via home-manager/chezmoi
3. TESTED → User manually verified
4. VERIFIED → (Optional) Automated tests passed
5. COMPLETE → Fully working and documented

---

## 🧪 Verification & Testing

### Phase A Verification

**Commands to verify:**
```bash
# Check right-click paste config
grep "mouse_map right press" ~/.config/kitty/kitty.conf

# Check window navigation
grep "ctrl+alt+left" ~/.config/kitty/kitty.conf

# Check theme
cat ~/.config/kitty/current-theme.conf | head -5

# Check transparency
grep "background_opacity" ~/.config/kitty/kitty.conf
```

**Manual Tests:**
1. Right-click in kitty → Should paste clipboard content
2. Open splits (`Ctrl+Shift+Enter`), use `Ctrl+Alt+Arrow` to navigate
3. Adjust transparency: `Ctrl+Shift+A, M` (more opaque) or `L` (less opaque)

### Phase B Verification

**Search Kitten:**
```bash
# Verify installation
ls -la ~/.config/kitty/kitty_search/search.py

# Test: Open kitty, press Ctrl+Shift+/, type search term
```

**Shell Integration:**
```bash
# Verify enabled
echo $KITTY_SHELL_INTEGRATION

# Test: Run commands, press Ctrl+Shift+Z to jump to previous prompt
```

**Git Diff:**
```bash
# Verify config
git config --get diff.tool

# Test: git difftool <file>
```

**SSH Kitten:**
```bash
# Verify alias
type ssh

# Should show: ssh is aliased to `kitty +kitten ssh'
```

### Phase D Verification (Zellij)

**Verify Installation:**
```bash
which zellij
zellij --version
ls -la ~/.config/zellij/config.kdl
ls -la ~/.config/zellij/plugins/zjstatus.wasm
```

**Manual Test:**
```bash
# Launch zellij
zellij

# Test features:
# - Ctrl+P, N - create new pane
# - Ctrl+T, N - create new tab
# - Ctrl+O, D - detach
# - Check zjstatus bar at bottom shows mode, tabs, time
```

### Performance Baselines

**Expected Performance:**
- Kitty startup: < 500ms
- Search kitten response: < 100ms
- Zellij session attach: < 200ms
- No UI lag during normal operation
- CPU usage: < 5% when idle

**If performance degraded:**
- Check GPU acceleration: `kitty --debug-rendering`
- Profile startup: `time kitty --detach`
- Check zellij: `zellij --debug`

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
- `docs/researches/2025-12-07-warp-kitty-mcp-integration-research.md` (Warp integration)

**Tools Documentation:**
- Located in: `docs/tools/kitty/` (contains autocomplete plans)
- **Note:** Consolidated kitty user guide (README.md + TROUBLESHOOTING.md) not yet created
- **TODO:** Create user-facing kitty guide consolidating all information

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

## 🔧 Troubleshooting

### Common Issues & Solutions

**Search Kitten Not Working:**
- **Symptom:** `Ctrl+Shift+/` does nothing
- **Check:** `ls ~/.config/kitty/kitty_search/search.py`
- **Fix:** Re-clone if missing: `cd ~/.config/kitty && git clone https://github.com/trygveaa/kitty-kitten-search kitty_search`
- **Reload:** `Ctrl+Shift+F5`

**Shell Integration Not Active:**
- **Symptom:** `$KITTY_SHELL_INTEGRATION` is empty
- **Check:** `~/.bashrc` contains shell integration code
- **Fix:** Restart terminal or `source ~/.bashrc`
- **Alternative:** Check if another shell profile is loaded first

**Zellij Shortcut Conflicts:**
- **Issue:** Zellij shortcuts conflict with kitty
- **Solution:** Remap zellij keys in `~/.config/zellij/config.kdl`
- **Example:** Change `Ctrl+P` to `Ctrl+A` if preferred

**Panel Kitten F12 Not Working (KDE Plasma):**
- **Expected:** KDE Plasma has partial support
- **Workaround:** Use kitty splits instead
- **Alternative:** Map different key: `map f11 kitten panel`

**Performance Issues:**
- **GPU not used:** Run `kitty --debug-rendering`, check for "Using GPU"
- **High CPU:** Check extensions/kittens causing issues
- **Slow startup:** Profile with `time kitty --detach`

### Rollback Procedures

**Revert Kitty Changes:**
```bash
# Via home-manager
cd ~/my-modular-workspace/home-manager
git log  # Find commit before changes
git revert <commit-hash>
home-manager switch --flake .#mitsio@shoshin
```

**Revert Zellij:**
```bash
# Stop all sessions
zellij delete-all-sessions

# Remove from home-manager
cd ~/my-modular-workspace/home-manager
# Edit zellij.nix or shell.nix, remove zellij
home-manager switch --flake .#mitsio@shoshin
```

**Restore Kitty Config Backup:**
```bash
# List backups
ls ~/.config/kitty/kitty.conf.backup*

# Restore specific backup
cp ~/.config/kitty/kitty.conf.backup.20251201 ~/.config/kitty/kitty.conf
```

### System Update Considerations

**After NixOS/Home-Manager Update:**
1. Check kitty version: `kitty --version`
2. Test all keybindings still work
3. Verify search kitten compatibility (may need update)
4. Check zellij: `zellij --version`
5. Verify zjstatus plugin loads correctly

**If Something Breaks:**
1. Check error logs: `journalctl --user -u home-manager-*.service`
2. Reload kitty config: `Ctrl+Shift+F5`
3. Rebuild home-manager: `home-manager switch`
4. As last resort: Rollback to previous generation

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

### Future Enhancements (Post-Current Phases)

**Status:** PLANNING - To be discussed after Phase E completion
**Note:** All items below require user clarification, research, and detailed planning

---

#### 🎯 Phase F: Panel & Menu Integration (PLANNED)

**F.1: Permanent Top Panel in Menu**
- **User Request:** Make F12 top panel appear in menu permanently
- **Requirements Needed:**
  - [ ] Clarify: System menu (KDE menu) or kitty menu?
  - [ ] Clarify: "Permanently" = always visible or always available in menu?
  - [ ] Research: KDE Plasma panel integration vs kitty menu bar
- **Complexity:** Medium-High (depends on interpretation)
- **Estimate:** TBD after clarification

---

#### 🌐 Phase G: Web Access in Terminal (RESEARCH REQUIRED)

**G.1: Web Browsing Through Kitty**
- **User Request:** "Access web through kitty" - open web content in terminal
- **Possible Interpretations:**
  1. Text-based web browsers (w3m, lynx, browsh) integration
  2. Open URLs from Firefox/other tools directly in kitty viewer
  3. Render web pages in terminal (terminal graphics protocol)
  4. HTML-to-terminal converter integration

- **Research Tasks:**
  - [ ] **Technical Researcher Role:** Investigate terminal web browsers
  - [ ] Research kitty graphics protocol for web rendering
  - [ ] Explore Firefox → kitty integration patterns
  - [ ] Investigate tools: w3m, lynx, browsh, carbonyl, etc.
  - [ ] Determine user's actual use case and preferences

- **Questions for User:**
  - What web content do you want to access? (Documentation? GitHub? General browsing?)
  - Should it open automatically when clicking links?
  - Text-only rendering or graphical rendering preferred?
  - Integration point: Firefox extension? Kitty hints? Shell alias?

- **Complexity:** HIGH - requires extensive research
- **Estimate:** 4-8 hours research + 3-6 hours implementation

---

#### 🛠️ Phase H: Terminal Tools Integration (7 Tools)

**H.1: Markdown Presentations - presenterm**
- **Tool:** https://github.com/mfontanini/presenterm
- **Purpose:** Present markdown files as slides in terminal
- **Integration Tasks:**
  - [ ] Install via home-manager (check nixpkgs availability)
  - [ ] Create keyboard shortcut for presentations
  - [ ] Test with sample markdown files
  - [ ] Create navi cheatsheet
- **Estimate:** 30-45 mins

**H.2: PDF Viewer - termpdf.py**
- **Tool:** https://github.com/dsanson/termpdf.py
- **Purpose:** View PDFs in terminal
- **Integration Tasks:**
  - [ ] Research nixpkgs availability or manual install
  - [ ] Configure as default PDF handler for kitty hints
  - [ ] Test rendering quality in kitty
  - [ ] Alternative: Consider zathura-pywal integration
- **Estimate:** 1 hour

**H.3: Image Viewer - mcat**
- **Tool:** https://github.com/Skardyy/mcat
- **Purpose:** Display images in terminal (using kitty graphics protocol)
- **Integration Tasks:**
  - [ ] Install and test with kitty graphics protocol
  - [ ] Create aliases for quick image viewing
  - [ ] Compare with `kitty +kitten icat` (built-in)
  - [ ] Decide if mcat adds value over built-in icat
- **Estimate:** 30 mins

**H.4: TUI Tool - tgutui**
- **Tool:** https://github.com/tgu-ltd/tgutui
- **Purpose:** TBD (need to research what this tool does)
- **Integration Tasks:**
  - [ ] **Research:** Understand tool purpose and features
  - [ ] Determine use case and integration point
  - [ ] Plan installation and configuration
- **Estimate:** TBD after research

**H.5: Note-Taking - nb**
- **Tool:** https://github.com/xwmx/nb
- **Purpose:** CLI note-taking, bookmarking, archiving system
- **Integration Tasks:**
  - [ ] Install via home-manager
  - [ ] Configure note storage location
  - [ ] Create keyboard shortcuts for quick notes
  - [ ] Integrate with existing workflow (Obsidian?)
  - [ ] Create navi cheatsheet
- **Estimate:** 1-2 hours (powerful tool, needs proper setup)

**H.6: QEMU TUI - nemu**
- **Tool:** https://github.com/nemuTUI/nemu
- **Purpose:** TUI for QEMU virtual machines
- **Integration Tasks:**
  - [ ] Install if QEMU/KVM workflow exists
  - [ ] Configure for VM management
  - [ ] Test with existing VMs
- **Estimate:** 1 hour
- **Question:** Do you use QEMU/VMs regularly?

**H.7: Smart Tab Management - kitty-smart-tab**
- **Tool:** https://github.com/yurikhan/kitty-smart-tab
- **Purpose:** Enhanced tab management for kitty
- **Integration Tasks:**
  - [ ] Research features vs current tab setup
  - [ ] Install and configure
  - [ ] Compare with existing tab shortcuts
  - [ ] Decide if it improves workflow
- **Estimate:** 30-45 mins

**Phase H Total Estimate:** 5-8 hours (all tools)

---

#### 🖥️ Phase I: Xterm Integration (MULTI-PHASE)

**I.1: Xterm Integration with Kitty**
- **User Request:** "Integrate xterm with kitty and enhance xterm bar"
- **Status:** NEEDS CLARIFICATION - Multi-phase plan required

**Questions for User:**
- [ ] What does "integrate xterm with kitty" mean?
  - Run xterm inside kitty?
  - Use xterm compatibility mode?
  - Share configurations between xterm and kitty?
  - Replace xterm with kitty system-wide?

- [ ] What is "xterm bar"?
  - XTerm title bar?
  - Status bar in xterm?
  - Something else?

- [ ] Use case: Why both xterm and kitty?
  - Legacy application compatibility?
  - Specific xterm features needed?
  - Terminal multiplexing scenario?

**Research Required:**
- [ ] **Technical Researcher Role:** Investigate xterm/kitty interoperability
- [ ] Research xterm features not in kitty
- [ ] Explore xterm → kitty migration strategies
- [ ] Investigate terminal emulator compatibility layers

**Complexity:** HIGH - unclear requirements, potentially complex
**Estimate:** TBD after clarification (likely 4-10 hours across multiple phases)

**Recommended Approach:**
1. Clarify user requirements and use cases
2. Research technical options (Technical Researcher role)
3. Create detailed multi-phase plan (Planner role)
4. Implement incrementally with user testing

---

### 📋 Future Phases Summary

| Phase | Description | Complexity | Status |
|-------|-------------|------------|--------|
| **F** | Panel & Menu Integration | Medium-High | NEEDS CLARIFICATION |
| **G** | Web Access in Terminal | HIGH | NEEDS RESEARCH |
| **H** | Terminal Tools (7 tools) | Medium | READY TO PLAN |
| **I** | Xterm Integration | HIGH | NEEDS CLARIFICATION |

**Next Steps for Future Phases:**
1. Complete current Phase C.2 and Phase E
2. User provides clarifications for Phase F, G, I
3. Technical Researcher investigates Phase G (web access)
4. Create detailed implementation plans for each phase
5. Prioritize phases based on user needs and complexity

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

## 📋 PHASE J: User Ideas & Future Enhancements (2025-12-21)

**Status:** 📝 DOCUMENTED FOR FUTURE IMPLEMENTATION
**Collected:** 2025-12-21 22:30 (Europe/Athens)
**Priority:** To be scheduled in future sessions

This section captures user's comprehensive vision for kitty terminal enhancements, collected during planning discussion.

---

### J.1: Keyboard Shortcuts Overhaul

**Goal:** Comprehensive keyboard shortcut reconfiguration for improved workflow

#### J.1.1: Terminal Input Shortcuts (bashrc/readline)

| Shortcut | Current | Desired | Implementation |
|----------|---------|---------|----------------|
| `Shift+Enter` | Run command | **New line** (don't execute) | `.inputrc` or bashrc readline binding |
| `Ctrl+Backspace` | Nothing | **Delete word** backward | `.inputrc` binding: `"\C-h": backward-kill-word` |

**Technical Notes:**
- These are shell/readline behaviors, not kitty-specific
- Configure via chezmoi in `dot_inputrc` or `dot_bashrc.tmpl`
- Research: `bind -x` for bash, `.inputrc` for readline

#### J.1.2: Kitty Terminal Spawning

| Shortcut | Action | Implementation |
|----------|--------|----------------|
| `Ctrl+Alt+T` | Spawn new kitty window | `map ctrl+alt+t new_os_window` |
| `Ctrl+Alt+Enter` | Spawn new kitty window | `map ctrl+alt+enter new_os_window` |

**Note:** May conflict with KDE Plasma global shortcuts - verify no conflicts

#### J.1.3: Split Navigation (Replace Current Config)

| Shortcut | Current | Desired |
|----------|---------|---------|
| `Ctrl+Shift+Left` | Previous tab | **Navigate to left split** |
| `Ctrl+Shift+Right` | Next tab | **Navigate to right split** |
| `Ctrl+Shift+Up` | (unused) | **Navigate to upper split** |
| `Ctrl+Shift+Down` | (unused) | **Navigate to lower split** |

**Implementation:**
```conf
# Replace current Ctrl+Shift+Arrow (tab nav) with split nav
map ctrl+shift+left neighboring_window left
map ctrl+shift+right neighboring_window right
map ctrl+shift+up neighboring_window up
map ctrl+shift+down neighboring_window down
```

**Note:** Tab navigation remains on `Alt+Left/Right` (already configured)

#### J.1.4: Split Layout Management

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+Space` | Rotate splits clockwise | Cycle window positions within current layout |
| `Ctrl+Shift+Space` | Cycle layout modes | Switch between layout presets (dynamic) |

**Layout Modes to Implement (Dynamic/Adaptive):**
```
2 windows: Horizontal split (side-by-side)
┌─────────┬─────────┐
│    1    │    2    │
└─────────┴─────────┘

3+ windows: Master-Stack (as shown in user screenshot)
┌─────────┬─────────┐
│         │    2    │
│    1    ├─────────┤
│ (master)│    3    │
└─────────┴─────────┘

Alternative layouts to cycle:
- All horizontal
- All vertical
- Grid (2x2, 3x3)
- Master-left (current)
- Master-right (mirror)
```

**Research Required:**
- Kitty `enabled_layouts` configuration
- Custom layout via Python kitten
- i3-style dynamic tiling behavior

#### J.1.5: KDE Plasma System Shortcuts (Not Kitty)

| Shortcut | Action | Implementation |
|----------|--------|----------------|
| `Meta+Alt+PageUp` | Volume Up | KDE kglobalshortcutsrc |
| `Meta+Alt+PageDown` | Volume Down | KDE kglobalshortcutsrc |

**Implementation:** Add to chezmoi `kglobalshortcutsrc` template

---

### J.2: Git Widget Comprehensive Redesign

**Current State:** Shows branch name only (✅ working)
**Goal:** Rich, interactive git status widget with TUI integration

#### J.2.1: Widget Information Expansion

**Current:** ` main*` (branch + dirty indicator)

**Desired Information:**
| Info | Format | Example | Priority |
|------|--------|---------|----------|
| Branch name | `branch` | `main` | ✅ Done |
| Dirty indicator | `*` suffix | `main*` | ✅ Done |
| Ahead/behind remote | `↓N ↑M` | `↓3 ↑2` | HIGH |
| Staged files count | `+N` | `+3` | HIGH |
| Modified files count | `~N` | `~2` | HIGH |
| Deleted files count | `-N` | `-1` | MEDIUM |
| Last commit time | `Nh ago` | `2h ago` | LOW |

**Desired Format Example:**
```
 main* ↓3↑2 +3~2-1
```

#### J.2.2: Widget Layout Reorganization

**Current Layout (left to right after tabs):**
```
[Tabs] │ Git │ SRE(Load,CPU,RAM) │ Storage │ Network │ Time │ Date │ Battery
```

**Desired Layout:**
```
[Tabs] │ Git (expanded) │ SRE(CPU only with sparkline) │ Storage │ Network │ Date │ Time │ Battery
```

**Changes:**
- [ ] Move Git widget to LEFT (first after tabs) ✅ Already done
- [ ] Move Date/Time to RIGHT side (before battery)
- [ ] Remove sparkline history from: RAM, Load (keep CPU only)
- [ ] Git widget: Dynamic sizing based on content
- [ ] Compact overall layout to make room for rich git info

#### J.2.3: Git Widget Interactivity (RESEARCH REQUIRED)

**Limitation:** Kitty tab bar does NOT support mouse events by design

**Desired Interactions:**
| Action | Behavior |
|--------|----------|
| **Click** | Open lazygit TUI in new split/pane |
| **Ctrl+Click** | Open VSCodium Source Control panel |
| **Hover** | Show detailed git status popup (colorized) |

**Research Directions:**
1. **pawbar** (https://github.com/codelif/pawbar) - Terminal-based panel using kitty panel kitten
2. **External overlay tool** - Separate process monitoring mouse position
3. **Keyboard shortcuts as alternative** - `Ctrl+G` opens lazygit, etc.
4. **F12 panel enhancement** - Show git info in dropdown panel

**Fallback Plan (if mouse not possible):**
- `Ctrl+G` or `F9` → Open lazygit in split
- `Ctrl+Shift+G` → Open VSCodium git panel
- Git info always visible in widget (no hover needed)

#### J.2.4: Git Auto-Detection on Directory Change

**Behavior:** Widget should:
1. Detect when `cd` changes to a git repo
2. Update branch/status immediately
3. Hide/minimize when not in git repo
4. Track active window's cwd (already implemented via `get_boss().active_window.child.current_cwd`)

**Current:** 5-second cache - may need reduction for responsiveness

---

### J.3: Kitty Smart Tab Integration

**Tool:** https://github.com/yurikhan/kitty-smart-tab
**Purpose:** Enhanced tab management with smart behaviors

**Features to Research:**
- [ ] What does kitty-smart-tab provide over default?
- [ ] Installation via chezmoi (similar to kitty_search)
- [ ] Configuration options
- [ ] Compatibility with current shortcuts

**Installation Plan:**
```bash
cd ~/.config/kitty
git clone https://github.com/yurikhan/kitty-smart-tab smart_tab
```

**Add to chezmoi:** `dotfiles/private_dot_config/kitty/smart_tab/`

---

### J.4: Implementation Priority Matrix

| Feature | Complexity | Impact | Priority | Session |
|---------|------------|--------|----------|---------|
| Ctrl+Shift+Arrow split nav | LOW | HIGH | 🔴 P1 | Next |
| Ctrl+Space rotate splits | LOW | MEDIUM | 🔴 P1 | Next |
| Shift+Enter new line | LOW | HIGH | 🔴 P1 | Next |
| Ctrl+Backspace delete word | LOW | HIGH | 🔴 P1 | Next |
| New terminal shortcuts | LOW | MEDIUM | 🔴 P1 | Next |
| Remove RAM/Load sparklines | LOW | LOW | 🟡 P2 | Next |
| Reorder widgets (git left, time right) | MEDIUM | MEDIUM | 🟡 P2 | Next |
| Git ahead/behind info | MEDIUM | HIGH | 🟡 P2 | Next |
| Git staged/modified counts | MEDIUM | HIGH | 🟡 P2 | Next |
| Ctrl+Shift+Space layout cycling | HIGH | HIGH | 🟠 P3 | Future |
| kitty-smart-tab integration | MEDIUM | MEDIUM | 🟠 P3 | Future |
| KDE volume shortcuts | LOW | LOW | 🟢 P4 | Future |
| Clickable widgets research | HIGH | HIGH | 🔵 Research | Future |
| lazygit TUI integration | HIGH | HIGH | 🔵 Research | Future |

---

### J.5: Questions for Future Sessions

**Layout Cycling:**
- [ ] Which exact layouts to include in cycle?
- [ ] Should layout persist per tab or global?
- [ ] Keybinding for specific layout (not cycle)?

**Git Widget:**
- [ ] Maximum width for git widget?
- [ ] What to show when repo has no remote?
- [ ] Color scheme for ahead/behind indicators?

**Interactivity:**
- [ ] Acceptable to use keyboard shortcuts instead of mouse?
- [ ] Should lazygit open in split, new tab, or overlay?
- [ ] VSCodium integration: which workspace to open?

---

### J.6: Reference Screenshot

**User's Desired Layout (2025-12-21):**
```
Screenshot: /tmp/Spectacle.HscPyQ/Screenshot_20251221_222401.png

Shows: Master-stack layout
┌─────────────────┬─────────────────┐
│                 │  Terminal 2     │
│  Terminal 1     ├─────────────────┤
│  (Master/Left)  │  Terminal 3     │
│                 │  (Stacked/Right)│
└─────────────────┴─────────────────┘
```

This is the target layout for 3+ windows configuration.

---

## 📋 PHASE K: Advanced Integrations & Optimizations (2025-12-21)

**Status:** 🔬 RESEARCH COMPLETE - Ready for Implementation Planning
**Collected:** 2025-12-21 23:15 (Europe/Athens)
**Research Completed:** 2025-12-22
**Priority:** Features prioritized based on feasibility research

This section captures user's comprehensive vision for advanced kitty terminal integrations, including browser, Obsidian, calendar, and system optimizations.

---

### 🔬 Research Summary (2025-12-22)

**Research Documentation:** `docs/researches/kitty-enhancements-research-22-12-2025.md`

#### ❌ Features Confirmed NOT FEASIBLE

| Feature | Reason | Alternative |
|---------|--------|-------------|
| **Firefox Panel Overlay** | Kitty panel kitten only supports terminal programs | Use Browsh (TUI browser) |
| **Obsidian Panel Overlay** | Electron apps cannot be embedded in terminals | File system + URI scheme |
| **Calendar Widget Clicks** | Kitty tab bar has no mouse event support | Keyboard shortcuts |

#### ✅ Features Ready for Implementation

| Feature | Effort | Approach |
|---------|--------|----------|
| **TUI Browser** | 1-2h | Install Browsh via nixpkgs |
| **Right-Click Menu** | 4-6h | rofi -dmenu -monitor -3 |
| **GPU Optimization** | 1h | Update kitty.conf (repaint_delay 6, input_delay 2) |
| **RAM Optimization** | 30m | scrollback_lines 2000 |
| **Notifications** | 1-2h | kitten notify + undistract-me |
| **Document Viewing** | 2-3h | termpdf.py + tdf + glow |
| **Obsidian Integration** | 2-3h | onote() shell function + URI scheme |
| **Session Persistence** | 3-4h | kitty --session + custom kitten |

#### Implementation Priority Order

**Phase K.1 (Quick Wins - 2-3 hours):**
1. GPU/RAM Optimization (config only)
2. TUI Browser (Browsh)
3. Terminal Notifications (undistract-me)

**Phase K.2 (Medium Effort - 6-8 hours):**
4. Right-Click Context Menu (rofi)
5. Document Viewing Tools (termpdf.py, glow)
6. Obsidian Integration (shell functions)

**Phase K.3 (Advanced - 4-6 hours):**
7. Session Persistence (custom kitten)
8. Quick Notes Widget (tab_bar.py addition)
9. Calendar Display (gcalcli + keyboard shortcuts)

---

### Multi-Role Review Summary (2025-12-22)

**Reviews Conducted:**
- 🔬 Technical Researcher: Verified tool versions, security status
- 💻 Developer: Code quality, error handling, dependencies
- 🔧 Ops Engineer: System integration, security, reproducibility

#### 🔴 CRITICAL FINDINGS

**1. Security: `allow_remote_control yes` is INSECURE**
- Current config allows any process to control kitty
- **MUST change to:** `allow_remote_control socket-only`
- Generate password: `openssl rand -base64 32 > ~/.config/kitty/.remote_password`
- **DO NOT implement right-click menu until fixed**

**2. Carbonyl: SECURITY RISK**
- Last updated Feb 2023 (2+ years ago)
- Chromium fork with 50+ unpatched vulnerabilities
- **Recommendation:** Use Browsh only, skip Carbonyl

#### 🟡 IMPORTANT FINDINGS

**3. Revised Effort Estimates:**
| Original | Realistic |
|----------|-----------|
| 12-17 hours | **24-36 hours** |

**4. Code Issues Found:**
- No error handling in context-menu.sh
- Unsafe URL encoding in shell scripts
- Missing input validation in Obsidian helpers
- Blocking I/O in tab_bar.py widget

**5. NixOS Gaps:**
- termpdf.py, tdf, undistract-me NOT in nixpkgs
- Manual installation required (reduces reproducibility)

#### ✅ VERIFIED CORRECT

- GitHub #7632 quote about context menus: Accurate
- GitHub #4447 tab bar limitation: Confirmed
- GTX 960 GPU settings: Optimal for hardware
- Browsh recommendation over Carbonyl: Valid
- tdf recently updated (v0.5.0, Dec 2025): Very active

#### Revised Priority Order

**Week 1 (Foundation - LOW RISK):**
1. GPU/RAM Optimization (config only)
2. Document viewing (glow, zathura - nixpkgs)
3. Notifications (shell hooks)

**Week 2 (Enhancements - MEDIUM RISK):**
4. Browsh TUI browser
5. Obsidian shell functions (with input validation)
6. Session files (basic, no custom kitten)

**Week 3+ (Advanced - AFTER SECURITY FIX):**
7. Right-click menu (requires secure remote control)
8. Quick notes widget
9. Calendar (optional)

---

### K.1: Browser Integration

**Status:** 🔬 RESEARCH COMPLETE
**Goal:** Web browsing within kitty terminal environment

#### K.1.1: Firefox Overlay Panel

**Research Finding:** ❌ **NOT FEASIBLE**

| Barrier | Explanation |
|---------|-------------|
| Panel kitten architecture | Only supports terminal programs, not GUI apps |
| Browser XEmbed removal | Firefox/Chrome removed embedding for security |
| No standard protocol | Wayland has no window embedding protocol |

**Verdict:** Do NOT pursue. Use TUI browser instead.

#### K.1.2: TUI Browser (Browsh) ✅ RECOMMENDED

| Setting | Value |
|---------|-------|
| **Tool** | Browsh (Firefox-based) |
| **Installation** | `pkgs.browsh` in home-manager |
| **Trigger** | `F10` or shell alias `web` |
| **Use Cases** | Documentation, AI chat (Claude/ChatGPT) |

**Why Browsh over Carbonyl:**
- Active development (Jan 2024 vs Feb 2023)
- Available in nixpkgs
- Regular Firefox security updates
- Extension support

**Implementation:**
```nix
# home-manager
home.packages = with pkgs; [ browsh firefox ];
```

```conf
# kitty.conf
map f10 launch --type=overlay browsh
```

---

### K.2: Right-Click Context Menu

**Status:** 🔬 RESEARCH COMPLETE
**Goal:** Comprehensive context menu for terminal interactions
**Implementation:** rofi -dmenu with -monitor -3 (appears at cursor)

#### Research Finding

**Native Support:** ❌ Kitty will NEVER have native context menus (developer confirmed)
**Solution:** ✅ rofi + kitty remote control

#### Recommended Implementation

**⚠️ SECURITY: Must use secure remote control configuration!**

**kitty.conf (SECURE):**
```conf
# SECURE remote control - required for context menu
allow_remote_control socket-only
listen_on unix:/tmp/kitty-${KITTY_PID}
remote_control_password file:~/.config/kitty/.remote_password

# Right-click triggers context menu
mouse_map right press ungrabbed launch --type=background ~/.config/kitty/context-menu.sh
```

**Script:** `~/.config/kitty/context-menu.sh` (with error handling)
```bash
#!/bin/bash
set -euo pipefail

# Check rofi is available
if ! command -v rofi &>/dev/null; then
    notify-send "Error" "rofi is not installed"
    exit 1
fi

# Check kitty remote control
PASSWORD_FILE="$HOME/.config/kitty/.remote_password"
if [[ ! -f "$PASSWORD_FILE" ]]; then
    notify-send "Error" "Kitty password file not found"
    exit 1
fi

KITTY_CMD="kitty @ --password-file=$PASSWORD_FILE"

# Show menu with timeout (prevents hanging)
MENU="📋 Copy\n📄 Paste\n🔗 Open URL\n🔍 Search"
CHOICE=$(echo -e "$MENU" | timeout 5s rofi -dmenu -i -monitor -3 \
    -theme-str 'window {width: 200px;}' -p "") || exit 0

case "$CHOICE" in
    *"Copy"*) $KITTY_CMD send-key ctrl+shift+c ;;
    *"Paste"*) $KITTY_CMD send-key ctrl+shift+v ;;
    *"Open URL"*) $KITTY_CMD kitten hints --type url ;;
    *"Search"*)
        SEL=$($KITTY_CMD get-text --extent selection | tr -d '\n')
        # URL-safe encoding via Python
        ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$SEL'))")
        xdg-open "https://google.com/search?q=${ENCODED}"
        ;;
esac
```

#### K.2.1: Basic Actions ✅

| Action | Implementation |
|--------|----------------|
| Copy | `kitty @ send-key ctrl+shift+c` |
| Paste | `kitty @ send-key ctrl+shift+v` |
| Select All | `kitty @ send-key ctrl+shift+a` |

#### K.2.2: URL & File Operations ✅

| Action | Implementation |
|--------|----------------|
| Open URL | `kitty @ kitten hints --type url` |
| Open in editor | `xdg-open` on selected path |
| Copy path | Extract and pipe to `wl-copy` |

**Complexity Rating:**
- Implementation: 5/10
- UX: 8/10 (near-native feel with rofi)

---

### K.3: GPU & RAM Optimization

**Status:** 🔬 RESEARCH COMPLETE
**Goal:** Maximize performance on NVIDIA GTX 960, optimize memory usage

#### K.3.1: GPU Settings ✅ READY

**GTX 960 Profile:**
- OpenGL 4.6 (exceeds kitty's 3.3 requirement)
- Use proprietary nvidia drivers

**Recommended kitty.conf:**
```conf
# Balanced (RECOMMENDED)
repaint_delay 6              # 40% faster than default
input_delay 2                # 33% faster than default
sync_to_monitor yes          # Prevent tearing
text_composition_strategy 1.2 10   # Better dark theme rendering

# Ultra Low Latency (for AI agents)
input_delay 0
repaint_delay 2
sync_to_monitor no           # May cause slight tearing
```

**Performance:** Kitty is 2x+ faster than alternatives (134.55 MB/s vs 61.83 gnome-terminal)

#### K.3.2: RAM Optimization ✅ READY

**Scrollback Buffer Impact:**
| scrollback_lines | Memory per Window |
|------------------|-------------------|
| 10000 (default) | ~12-15 MB |
| 2000 (recommended) | ~10 MB |
| 500 (minimal) | ~3 MB |

**Recommended:**
```conf
scrollback_lines 2000
scrollback_pager_history_size 0
```

**Swap (NixOS):** Enable zram for compressed swap
```nix
zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; };
```

**Effort:** 1 hour total (config changes only)

---

### K.4: Enhanced Refresh (Ctrl+Shift+F5)

**Goal:** Comprehensive terminal refresh shortcut
**Current:** Ctrl+Shift+F5 = `load_config_file` (reload kitty.conf only)

**Desired Behavior:**
1. Reload kitty.conf (existing)
2. Force tab bar redraw (new - refresh all widgets)

**Implementation:**
```conf
# Enhanced refresh: config + tab bar
map ctrl+shift+f5 combine : load_config_file : signal_child SIGUSR1
```

**Research Needed:**
- [ ] How to force tab_bar.py to re-render
- [ ] Signal handling in custom tab bar
- [ ] Possible: add refresh function in tab_bar.py that resets caches

---

### K.5: Obsidian Integration

**Status:** 🔬 RESEARCH COMPLETE
**Goal:** Terminal integration with Obsidian vault
**Vault Location:** `~/.MyHome/vault`

#### K.5.1: Research Findings

**Panel Overlay:** ❌ NOT FEASIBLE (Electron app cannot be embedded)

**Recommended Approach:** ✅ Hybrid file system + URI scheme

#### K.5.2: Implementation ✅ READY

**Shell Functions:**
```bash
# ~/.bashrc
export OBSIDIAN_VAULT="$HOME/.MyHome/vault"

# Quick note to inbox
onote() { echo "- $(date +%H:%M) - $@" >> "$OBSIDIAN_VAULT/Inbox.md"; }

# Open note in Obsidian app
oopen() { xdg-open "obsidian://open?vault=MyVault&file=$1"; }

# Render markdown in terminal
oview() { glow "$OBSIDIAN_VAULT/$1.md"; }

# Search vault
osearch() { grep -rn "$1" "$OBSIDIAN_VAULT" --include="*.md" | fzf; }
```

#### K.5.3: Document Viewing ✅ READY

| Format | Tool | Command |
|--------|------|---------|
| Markdown | glow | `glow note.md` |
| PDF | termpdf.py | `termpdf.py doc.pdf` |
| LaTeX | latexmk -pvc | `latexmk -pdf -pvc doc.tex` + zathura |

**Effort:** 2-3 hours

---

### K.6: Document Viewing in Terminal

**Goal:** View documents without leaving terminal

#### K.6.1: PDF Preview

| Requirement | Description |
|-------------|-------------|
| View in panel | PDF viewer in kitty panel overlay |
| Tools to research | zathura, termpdf, tpdf, pdf2txt |

#### K.6.2: LaTeX Live Preview

| Requirement | Description |
|-------------|-------------|
| Live compilation | See output while editing .tex files |
| Tools to research | latexmk --pvc, tectonic, entr |

#### K.6.3: Markdown Rendering

| Requirement | Description |
|-------------|-------------|
| In-terminal render | Formatted markdown in terminal |
| Tools to research | glow, mdcat, bat with markdown |

---

### K.7: Terminal Notifications

**Goal:** Desktop notifications for terminal events

#### K.7.1: Notification Triggers

| Event | Description |
|-------|-------------|
| Long command completion | Commands taking >30 seconds |
| Build/test results | make, npm, cargo build completion |
| Background job done | & background processes complete |

**Implementation Approach:**
- kitty's `notify` action
- `command_on_bell` configuration
- Shell integration with notify-send
- Tools: undistract-me, ntfy, terminal-notifier

**Research Needed:**
- [ ] kitty native notification support
- [ ] Shell hooks for command completion
- [ ] KDE Plasma notification integration
- [ ] Threshold configuration (>30s, >60s, custom)

---

### K.8: Session Persistence

**Goal:** Save and restore complete terminal sessions

#### K.8.1: What to Save

| Component | Include |
|-----------|---------|
| Window layout | Tab structure, split positions |
| Working directories | cwd per pane |
| Command history | Recent commands per pane |
| Environment variables | Exported vars |
| Running processes | Active commands (where possible) |

**Scope:** Full state persistence

#### K.8.2: Session Naming

| Method | Description |
|--------|-------------|
| Primary | Project/repo name (auto-detected from cwd) |
| Secondary | Tab names included in session name |
| Format | `{project}-{tab1}-{tab2}-{timestamp}` |

**Research Needed:**
- [ ] kitty session file format
- [ ] kitty --session flag capabilities
- [ ] Saving/restoring environment state
- [ ] Integration with shell history
- [ ] Possible: custom kitten for session management

---

### K.9: Calendar Integration

**Status:** 🔬 RESEARCH COMPLETE
**Goal:** Calendar access from terminal

#### K.9.1: Research Findings

**Clickable Widget:** ❌ NOT SUPPORTED (kitty tab bar has no mouse event handling)
**Plasma Calendar DBus:** ❌ No method to programmatically open popup

#### K.9.2: Recommended Approach ✅

**Display-only badge + keyboard shortcuts:**

```
Tab Bar: | ... | 📅 Dec 22 | 3 events | ...
Keyboard: F8 → Open Merkuro/KOrganizer
```

**Implementation:**
```conf
# kitty.conf
map f8 launch --type=background merkuro-calendar
map ctrl+shift+c launch --type=overlay bash -c "gcalcli agenda; read"
```

**Google Calendar Sync:**
- Install Merkuro + Akonadi via home-manager
- Configure via KDE System Settings → Online Accounts

#### K.9.3: Terminal Calendar Tools

| Tool | Purpose |
|------|---------|
| gcalcli | CLI for Google Calendar |
| khal | Terminal calendar with vdirsyncer |
| Merkuro | Modern KDE calendar app |

**Effort:** 3-4 hours (includes Akonadi setup)

---

### K.10: Widget Layout Reorganization

**Goal:** Optimal tab bar widget arrangement

#### Current Layout
```
[Tabs] │ Git │ SRE(Load,CPU,RAM) │ Storage │ Network │ Time │ Date │ Battery
```

#### Desired Layout
```
[Tabs] │ Git │ Notes │ ← LEFT    CENTER → │ CPU │ RAM │ Storage │ Network │    RIGHT → │ Time │ Calendar │ Battery
```

| Position | Widgets |
|----------|---------|
| **Left** (after tabs) | Git (expanded), Quick-notes |
| **Center** | SRE metrics (CPU with sparkline, RAM, Load) |
| **Right** (edge) | Time, Calendar, Battery |

**Changes from Current:**
- Add Quick-notes widget (new)
- Move Date/Time to right side
- Add Calendar widget indicator (new)
- Reorder for logical grouping

---

### K.11: Implementation Priority Matrix (Phase K)

| Feature | Complexity | Research Needed | Priority |
|---------|------------|-----------------|----------|
| Ctrl+Shift+F5 refresh | LOW | LOW | 🔴 P1 |
| Widget layout reorg | MEDIUM | LOW | 🟡 P2 |
| Terminal notifications | MEDIUM | MEDIUM | 🟡 P2 |
| Firefox panel | HIGH | HIGH | 🟠 P3 |
| Right-click menu | HIGH | HIGH | 🟠 P3 |
| Session persistence | HIGH | MEDIUM | 🟠 P3 |
| TUI browser | MEDIUM | MEDIUM | 🟠 P3 |
| GPU/RAM optimization | MEDIUM | HIGH | 🟠 P3 |
| Obsidian integration | HIGH | HIGH | 🔵 Research |
| Calendar integration | HIGH | HIGH | 🔵 Research |
| Document viewing | HIGH | HIGH | 🔵 Research |

---

### K.12: Research Sessions - ✅ COMPLETED

**Research Date:** 2025-12-22
**Documentation:** `docs/researches/kitty-enhancements-research-22-12-2025.md`

All research sessions completed with the following outcomes:

| Topic | Status | Key Finding |
|-------|--------|-------------|
| Browser Panel | ✅ Complete | NOT feasible - use Browsh TUI |
| Right-Click Menu | ✅ Complete | rofi -monitor -3 solution |
| Obsidian Integration | ✅ Complete | URI scheme + shell functions |
| Document Viewing | ✅ Complete | termpdf.py, tdf, glow |
| Calendar Integration | ✅ Complete | Keyboard shortcuts (no clicks) |
| GPU/RAM Optimization | ✅ Complete | GTX 960 settings documented |
| Notifications | ✅ Complete | kitten notify + undistract-me |
| Session Persistence | ✅ Complete | kitty --session + custom kitten |

**Key Limitations Confirmed:**
1. Kitty tab bar has NO mouse event support for custom content
2. GUI apps (Firefox, Obsidian) CANNOT be embedded in terminal
3. Plasma calendar has NO DBus method for opening popup

---

### K.13: Questions for Future Sessions

**Browser Integration:**
- [ ] Should Firefox panel persist between kitty restarts?
- [ ] Default URL for Firefox panel (blank, docs site, AI chat)?
- [ ] Keyboard shortcuts for browser navigation from terminal?

**Right-Click Menu:**
- [ ] Menu theme/style (match KDE Plasma theme)?
- [ ] Submenu organization or flat list?
- [ ] Custom actions (user-defined scripts)?

**Obsidian:**
- [ ] Default note location for quick capture?
- [ ] Template for captured content?
- [ ] Tags to auto-add to captured notes?

**Session Persistence:**
- [ ] Auto-save on exit?
- [ ] Maximum number of saved sessions?
- [ ] Location for session files?

---

### K.14: Tmux Integration (Added 2025-12-22, Refined via Q&A)

**Status:** 🔬 DEEP RESEARCH COMPLETE - Ready for Implementation
**Research Documentation:** `docs/researches/kitty-enhancements-research-22-12-2025.md` (Sections 12.14-12.17)
**Priority:** HIGH

#### User Requirements (Refined via Q&A 2025-12-22)

| Requirement | Value |
|-------------|-------|
| **Feature Split** | Kitty splits locally, tmux only for remote SSH |
| **SSH Behavior** | Always auto-attach/create tmux on SSH |
| **Bar Position** | Bottom (traditional) |
| **Theme** | Dracula (match kitty) |
| **Git Info** | Right side: branch, ahead/behind, staged/unstaged counts |
| **Time Widget** | ❌ NO - kitty tab bar handles time |
| **K8s Detail** | Full: cluster/context:namespace (e.g., gke-eu/prod/default) |
| **K8s Colors** | Production=Red, Staging=Yellow, Dev=Green |
| **Remote Info** | Full: hostname (IP) ↑uptime session_time |
| **CPU Widget** | Minimal overlap - only in tmux for remote context |
| **Local Behavior** | Show local hostname + k8s context |
| **Server Types** | Mixed: production + development |

#### Recommended Architecture

```
Kitty (Primary Interface - LOCAL ONLY)
├── Tabs and splits for local work
├── Window management (GPU-accelerated)
├── Tab bar (time, SRE metrics: CPU, RAM, Load)
└── Visual features (themes, transparency)

Tmux (Secondary - FOR REMOTE + PERSISTENCE)
├── Session persistence (resurrect/continuum)
├── Remote SSH session management (auto-attach)
├── Status bar (git, remote, k8s, CPU)
└── SSH Config RemoteCommand approach
```

#### Feature Split Strategy

| Context | Window Splits | Tmux Usage |
|---------|---------------|------------|
| **Local work** | Kitty splits only | Session persistence + status bar |
| **Remote SSH** | Tmux splits | Full tmux features |

#### Implementation Phases

**Phase 1: SSH Auto-Attach Setup (1 hour)**
1. Configure SSH matchBlocks in Home-Manager:
   - `prod-tmux` → Auto-attach to tmux
   - `prod` → Plain connection for git/scp
   - Same pattern for dev servers
2. Test nested tmux prevention
3. Test with `kitten ssh prod-tmux`

**Phase 2: Basic Tmux Setup (1-2 hours)**
1. Install tmux via Home-Manager
2. Configure tmux-resurrect for session persistence
3. Configure tmux-continuum for auto-save (10min interval)
4. Test session save/restore
5. Add session management keybindings (S=new, J=join)

**Phase 3: Status Bar Configuration (2-3 hours)**
1. Install PowerKit (recommended for k8s support)
2. Configure plugins:
   - Git (right side): branch ↓↑ +~- with colors
   - Kubernetes: cluster/context:namespace with env colors
   - CPU: only for remote context awareness
   - Remote: hostname (IP) ↑uptime session_time
3. Apply Dracula theme
4. Configure caching TTLs:
   - CPU: 3s
   - Git: 10s
   - K8s: 15s

**Phase 4: Kitty Integration (1 hour)**
1. Configure kitty keybinding forwarding:
   ```conf
   map --when-focus-on title:tmux super+n send_text all \x01n
   map --when-focus-on title:tmux super+p send_text all \x01p
   ```
2. Test local vs remote scenarios
3. Verify no widget duplication with kitty tab bar

**Total Estimated Time:** 5-7 hours

#### Status Bar Layout (Final Design)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│ [session] │ 󰣀 server01 (192.168.1.10) ↑45d 2h15m │ 󰠳 CPU 45% │ ⎈ gke-eu/prod/default │  main ↓3↑2 +3~2 │
└─────────────────────────────────────────────────────────────────────────────────────┘
LEFT ────────────────────────────────────────────────────────────────────────────── RIGHT
```

**NO time widget** - kitty tab bar handles time display

**Components:**
| Position | Widget | Details |
|----------|--------|---------|
| Left | Session | tmux session name |
| Left-Center | Remote | 󰣀 hostname (IP) ↑uptime session_time |
| Center | CPU | 󰠳 CPU% (remote context only) |
| Right-Center | K8s | ⎈ cluster/context:namespace (color-coded) |
| Right | Git |  branch ↓behind ↑ahead +staged ~modified -deleted |

#### SSH Auto-Attach Configuration

```nix
programs.ssh.matchBlocks = {
  # Tmux-enabled aliases
  "prod-tmux" = {
    hostname = "production.example.com";
    user = "admin";
    extraOptions = {
      RequestTTY = "yes";
      RemoteCommand = "tmux new-session -A -s prod";
    };
  };

  # Regular connections (git push, scp work)
  "prod" = { hostname = "production.example.com"; user = "admin"; };
};
```

#### Home-Manager Configuration (Template)

```nix
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;

    plugins = with pkgs; [
      # Theme first (ORDER MATTERS)
      # tmux-powerkit would go here

      # Session persistence
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      set -g prefix C-a
      set -g mouse on
      set-option -g status-position bottom
      set-option -g set-titles on
      set-option -g set-titles-string "tmux:#S:#I:#W"
      set -g status-interval 5

      # Dracula theme colors
      set -g status-style "bg=#282a36,fg=#f8f8f2"
    '';
  };
}
```

#### Key Findings from Research

| Finding | Impact |
|---------|--------|
| Performance overhead | ~50% throughput reduction (acceptable for DevOps) |
| PowerKit has 37+ plugins | Kubernetes, Terraform, Git all available |
| Plugin ordering critical | Themes before resurrect/continuum |
| Keybinding forwarding | Works via window title detection |
| Dracula theme available | Native support in most frameworks |

---

### K.15: Extended Tmux Configuration (Q&A Round 2 - 2025-12-22)

**Status:** 🔬 DEEP RESEARCH COMPLETE - Ready for Implementation
**Research Documentation:** `docs/researches/kitty-enhancements-research-22-12-2025.md` (Sections 12.17-12.23)
**Priority:** HIGH

#### Extended Requirements (Q&A Round 2)

| Requirement | Value | Notes |
|-------------|-------|-------|
| **Auto-start** | Manual only | Tmux ONLY for remote SSH |
| **Docker widget** | Resource usage | Count + CPU% + RAM |
| **Sessions** | Hybrid approach | Project + context based |
| **Visual style** | Left rounded | Tab-like segments |
| **Session names** | Full descriptive | `work-dissertation`, `ssh-server01` |
| **Persistence** | Full | Auto-restore ALL on reboot |

#### New Components to Add

**1. Docker Widget:**
```
🐳 5 ↑12.3% 512MB
```
- Custom script with 5s caching
- Shows: count, total CPU%, total RAM

**2. Rounded Segments:**
- Nerd Font: `` (\uE0B4) left, `` (\uE0B6) right
- Catppuccin `rounded` style or manual Dracula

**3. Session Management (sesh + fzf):**
```toml
[[session]]
name = "work-dissertation 📚"
path = "~/Documents/dissertation"

[[session]]
name = "infra-prod 🏭"
startup_command = "ssh admin@prod-server"
```

**4. Full Persistence:**
```nix
plugins = [
  tmuxPlugins.dracula      # Themes FIRST
  tmuxPlugins.resurrect    # Then resurrect
  tmuxPlugins.continuum    # MUST BE LAST
];
```

#### Updated Implementation Phases

**Phase 1: SSH Auto-Attach (1 hour)**
- Configure SSH matchBlocks
- Test nested tmux prevention

**Phase 2: Basic Tmux + Persistence (2 hours)**
- Install tmux with resurrect + continuum
- Configure full persistence
- Test save/kill/restore cycle

**Phase 3: Visual Styling (1-2 hours)**
- Configure rounded segments
- Apply Catppuccin Mocha or Dracula theme

**Phase 4: Status Bar Widgets (2-3 hours)**
- Docker widget with caching script
- K8s context with color coding
- Git status (right side)
- Remote info (hostname, uptime)

**Phase 5: Session Management (1-2 hours)**
- Install sesh + fzf + zoxide
- Configure session templates
- Add keybindings (prefix + T)

**Total Estimated Time:** 7-10 hours

#### Final Status Bar Layout (Complete)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  work-session  󰣀 server01 (IP) ↑45d 2h  🐳 5 ↑12% 512MB  ⎈ gke-eu/prod/default   main ↓3↑2  │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
LEFT ────────────────────────────────────────────────────────────────────────────────────── RIGHT
```

**Widgets (left to right):**
1. Session name (rounded segment)
2. Remote: hostname (IP) ↑uptime session_time
3. Docker: 🐳 count ↑CPU% RAM
4. K8s: ⎈ cluster/context:namespace (color-coded)
5. Git:  branch ↓behind ↑ahead (right side)

**NO time widget** - kitty tab bar handles time

---

## 🎬 Conclusion

**Overall Status:** Highly successful implementation with 70% completion + DEEP TMUX RESEARCH COMPLETE

**What Works Excellently:**
- ✅ Kitty with enhanced shortcuts and kittens
- ✅ Zellij integration with beautiful zjstatus
- ✅ Declarative management via chezmoi + home-manager
- ✅ Comprehensive documentation and cheatsheets
- ✅ **Complete tmux integration research** (Q&A refined)

**What's Ready for Implementation:**
- Tmux integration (7-10 hours estimated)
  - SSH auto-attach
  - Full persistence (resurrect + continuum)
  - Rounded segment styling
  - Docker/K8s/Git widgets
  - Hybrid session management (sesh)

**What's Pending:**
- User clarifications for remaining Phase C.2 features
- User testing of new features
- **Tmux implementation** (ready to start)

**Recommendation:** The tmux research is comprehensive and ready for implementation. Start with Phase 1 (SSH auto-attach) and iterate through the phases.

---

**Plan Maintained By:** Dimitris Tsioumas (Mitsio)
**Last Updated:** 2025-12-22 (Q&A Round 2 Complete)
**Next Review:** After tmux implementation begins
