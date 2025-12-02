# Kitty Kittens & Advanced Enhancements Plan

**Created:** 2025-12-01
**Updated:** 2025-12-01 20:00
**Status:** PHASE B ✅ | PHASE C.1 ✅ | PHASE C.2 🔬 RESEARCH COMPLETE - Ready for Implementation
**Session:** kitty-configuration-phase2-continuation-extended
**Priority:** MEDIUM → HIGH (New features requested)
**Time Spent:** ~5 hours (Phase B: 2h, Phase C.1: 1h, Research: 2h)
**Remaining:** 3-5 hours (Phase C.2 implementation)

---

## 📋 Executive Summary

This plan documents advanced kitty terminal enhancements discovered through technical research, focusing on "kittens" (kitty plugins/extensions) and advanced features.

**Key Findings:**
- ✅ Kitty has powerful built-in extensibility through "kittens"
- ✅ Several essential kittens can dramatically improve workflow
- ✅ VSCodium integration is straightforward and powerful
- ✅ Kitty's native features can replace most tmux use cases
- ✅ Custom kittens can be created in Python for specific needs

---

## 🎯 Implementation Goals

1. **Enable essential kittens** for productivity (search, hints, diff, icat)
2. **Configure VSCodium** as default editor (DONE ✅)
3. **Enhance hints kitten** for file/URL selection (DONE ✅)
4. **Add shell integration** for advanced features
5. **Configure custom workflows** using kitten combinations

---

## 🔬 Research Findings

### 1. **Essential Kittens Discovered**

#### A. **Search Kitten** (HIGH PRIORITY)

**What it does:** Incremental search in scrollback buffer (like tmux's `/` search)

**Repository:** https://github.com/trygveaa/kitty-kitten-search

**Installation:**
```bash
cd ~/.config/kitty
git clone https://github.com/trygveaa/kitty-kitten-search kitty_search
```

**Configuration (add to kitty.conf):**
```conf
# Incremental search in scrollback (like tmux search)
map kitty_mod+/ launch --location=hsplit --allow-remote-control kitty +kitten kitty_search/search.py @active-kitty-window-id
```

**Keybindings:**
- `Ctrl+Shift+/` - Open search
- `↑/↓` - Navigate matches
- `Tab` - Switch between literal/regex
- `Ctrl+U` - Clear query
- `Enter` - Keep position and exit
- `Esc` - Scroll to bottom and exit

**Benefits:**
- ✅ Instantly search through terminal output
- ✅ Regex support
- ✅ Keyboard-driven navigation
- ✅ Replaces tmux search functionality

---

#### B. **Hints Kitten** (PARTIALLY IMPLEMENTED ✅)

**Current Status:** Enhanced in Phase A

**What we added:**
- URL selection (`Ctrl+Shift+E`)
- Path selection (`Ctrl+Shift+P, F`)
- Line number selection for stack traces (`Ctrl+Shift+P, N`)
- Open paths in VSCodium (`Ctrl+Shift+P, E`)

**Additional possibilities:**
```conf
# Select git commit hashes
map ctrl+shift+p>g kitten hints --type hash --program "git show"

# Select IPs
map ctrl+shift+p>i kitten hints --type ip

# Custom regex for SQL tables
map ctrl+shift+p>t kitten hints --type regex --regex "TABLE\s+(\w+)" --program -
```

---

#### C. **icat Kitten** (Display Images)

**What it does:** Display images directly in terminal

**Built-in usage:**
```bash
# Display an image
kitty +kitten icat image.png

# Display with specific size
kitty +kitten icat --align left --place 40x40@0x0 image.png

# Display from URL
kitty +kitten icat https://example.com/image.jpg
```

**Use cases:**
- Preview images before opening in editor
- Display diagrams/charts in terminal
- Show thumbnails of files
- Display QR codes for sharing

**Integration with file managers:**
```bash
# With ranger file manager
set preview_images_method kitty
```

**Configuration (optional shortcuts):**
```conf
# Quick image preview (select path, then preview)
map f1 launch --stdin-source=@screen_scrollback --type=overlay kitten icat

# Preview image at cursor (with hints)
map ctrl+shift+p>img kitten hints --type path --program "kitty +kitten icat"
```

---

#### D. **diff Kitten** (Side-by-Side File Comparison)

**What it does:** Fast, side-by-side diff with syntax highlighting

**Built-in usage:**
```bash
# Compare two files
kitty +kitten diff file1.py file2.py

# Compare directories
kitty +kitten diff dir1/ dir2/

# Use as git difftool
git config --global diff.tool kitty
git config --global difftool.kitty.cmd 'kitty +kitten diff $LOCAL $REMOTE'
```

**Features:**
- ✅ Syntax highlighting
- ✅ Image diffing (!)
- ✅ Fast GPU rendering
- ✅ Keyboard navigation
- ✅ Git integration

**Git integration setup:**
```bash
# Add to ~/.gitconfig (via chezmoi)
[diff]
    tool = kitty
[difftool "kitty"]
    cmd = kitty +kitten diff $LOCAL $REMOTE
```

---

#### E. **Panel Kitten** (Quick-Access Terminal)

**What it does:** Quake-style dropdown terminal

**Official docs:** https://sw.kovidgoyal.net/kitty/kittens/panel/

**Configuration:**
```conf
# Quick-access dropdown terminal (Quake-style)
map f12 kitten panel --edge top --size 0.5
```

**Features:**
- ✅ Dropdown from any edge (top/bottom/left/right)
- ✅ Configurable size
- ✅ Hotkey toggle
- ✅ Runs arbitrary programs
- ✅ GPU-accelerated

**Advanced example:**
```conf
# System monitor panel
map ctrl+shift+m kitten panel --edge bottom --size 0.3 --output-name DP-1 btop

# Quick notes panel
map ctrl+shift+n kitten panel --edge right --size 0.4 nvim ~/notes/quick.md
```

---

#### F. **SSH Kitten** (Better SSH)

**What it does:** SSH with automatic terminfo copying and config transfer

**Usage:**
```bash
# Instead of: ssh myserver
kitty +kitten ssh myserver
```

**Benefits:**
- ✅ Automatically copies terminfo (no more "unknown term type")
- ✅ Can copy shell config (`.bashrc`, `.vimrc`, etc.)
- ✅ Connection reuse for low latency
- ✅ Shell integration automatically works

**Configuration:**
```bash
# Add to ~/.bashrc (via chezmoi)
alias ssh="kitty +kitten ssh"
```

---

#### G. **Themes Kitten** (Theme Switcher)

**What it does:** Preview and switch between 300+ themes

**Usage:**
```bash
# Browse and preview themes
kitty +kitten themes

# Apply a specific theme
kitty +kitten themes --reload-in=all Catppuccin-Mocha
```

**Configuration shortcut:**
```conf
# Quick theme switcher
map ctrl+shift+t kitten themes
```

---

### 2. **Shell Integration** (ESSENTIAL)

**Current status:** Enabled but not fully configured

**What it enables:**
- Jump to previous/next command prompt
- Show output of last command
- Better clipboard integration
- Directory tracking for new windows
- Marks for command output (used by search kitten)

**Full setup (add to ~/.bashrc via chezmoi):**
```bash
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"

    # Keybinding to jump to previous prompt
    bind '"\e[1;5A": previous-history'  # Ctrl+Up
    bind '"\e[1;5B": next-history'      # Ctrl+Down
fi
```

**Kitty config additions:**
```conf
# Jump to previous/next prompt (requires shell integration)
map ctrl+shift+z scroll_to_prompt -1
map ctrl+shift+x scroll_to_prompt 1

# Show last command output
map ctrl+shift+g show_last_command_output
```

---

### 3. **Remote Control Features** (ALREADY ENABLED ✅)

**Current config:**
```conf
allow_remote_control yes
listen_on unix:/tmp/kitty
```

**Powerful automation examples:**
```bash
# Change theme from command line
kitty @ set-colors --all --configured ~/.config/kitty/current-theme.conf

# Create new tab programmatically
kitty @ launch --type=tab --title "My Task" --cwd ~/projects/myproject

# Send text to specific window
kitty @ send-text --match title:mywindow "echo hello\n"

# Get list of all windows (JSON)
kitty @ ls

# Close specific window
kitty @ close-window --match title:temp
```

**Use cases:**
- Script complex terminal workflows
- Integrate with external tools
- Automate repetitive tasks
- Build custom productivity tools

---

### 4. **VSCodium Integration** (IMPLEMENTED ✅)

**Current status:** Completed in Phase A

**What we configured:**
- Set VSCodium as default editor
- Open files from hints kitten
- Open files at specific line numbers (stack traces)

**Additional enhancements:**
```bash
# Add to ~/.bashrc (via chezmoi)
export VISUAL="codium"
export EDITOR="codium"
export GIT_EDITOR="codium --wait"
```

**Git integration:**
```bash
# Set as git editor
git config --global core.editor "codium --wait"

# Use for commit messages
git config --global sequence.editor "codium --wait"
```

---

## 📦 Implementation Plan

### **Phase B: Essential Kittens** ✅ COMPLETE (2025-12-01)

#### B.1: Install Search Kitten ✅
- [x] Clone search kitten repository
- [x] Add keybinding to `kitty.conf`
- [x] Test incremental search
- [ ] Document usage in navi cheatsheet (TODO)

**Commands:**
```bash
cd ~/.config/kitty
git clone https://github.com/trygveaa/kitty-kitten-search kitty_search
```

**Add to kitty.conf:**
```conf
# Incremental search in scrollback
map kitty_mod+/ launch --location=hsplit --allow-remote-control kitty +kitten kitty_search/search.py @active-kitty-window-id
```

#### B.2: Configure Git Diff Integration ✅
- [x] Set up kitty diff as git difftool
- [x] Add to `~/.gitconfig` via chezmoi
- [x] Git editor updated to codium
- [ ] Test with `git difftool` (USER TODO)

**Add to `~/.gitconfig`:**
```ini
[diff]
    tool = kitty
[difftool "kitty"]
    cmd = kitty +kitten diff $LOCAL $REMOTE
    trustExitCode = true
[difftool]
    prompt = false
```

#### B.3: Add Shell Integration ✅
- [x] Enable full shell integration in `~/.bashrc` (changed from no-rc to enabled)
- [x] Add keybindings for prompt navigation (Ctrl+Shift+Z/X)
- [x] Add show last command output (Ctrl+Shift+G)
- [ ] Test command output features (USER TODO)

**Add to chezmoi `dot_bashrc.tmpl`:**
```bash
# ============ Kitty Shell Integration ============
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi
```

**Add to kitty.conf:**
```conf
# Jump to previous/next command prompt
map ctrl+shift+z scroll_to_prompt -1
map ctrl+shift+x scroll_to_prompt 1

# Show last command output
map ctrl+shift+g show_last_command_output
```

#### B.4: Configure SSH Kitten Alias ✅
- [x] Add SSH alias to `~/.bashrc` (via chezmoi)
- [ ] Test SSH with automatic terminfo (USER TODO)

**Add to `~/.bashrc`:**
```bash
# Better SSH with kitty
if test -n "$KITTY_INSTALLATION_DIR"; then
    alias ssh="kitty +kitten ssh"
fi
```

---

### **Phase C: Advanced Features** (OPTIONAL - 1-2 hours)

#### C.1: Panel Kitten (Quick-Access Terminal) ✅ COMPLETE (2025-12-01 04:45)
- [x] Configure F12 for dropdown terminal
- [x] Document panel configuration options
- [x] Add alternative panel examples (bottom, right, left, with programs)
- [ ] Test Quake-style behavior (USER TODO)
- [ ] Configure additional panels (system monitor, notes) - Optional

#### C.2: Enhanced Terminal Experience 🔬 RESEARCH COMPLETE (2025-12-01 20:00)

**Status:** Research complete, awaiting user clarifications before implementation

**Scope:** Scrollbar, status bar, right-click, autocomplete, history export

##### C.2.1: Interactive Scrollbar ✅ READY
- [x] Research native scrollbar support (FOUND: Fully supported!)
- [ ] Enable interactive scrollbar
- [ ] Configure appearance (transparency, colors)
- [ ] Test clickability and drag functionality
- **Estimate:** 15 mins
- **Status:** Native support confirmed, ready to implement

##### C.2.2: Enhanced Tab Bar (Status Display) ⏳ AWAITING CLARIFICATION
- [x] Research status bar options (FOUND: Use tab bar at bottom)
- [ ] Move tab bar to bottom
- [ ] Add custom template showing: tab number, current directory
- [ ] Optional: Git branch detection script
- **Estimate:** 30-45 mins
- **Status:** Waiting for user to specify what info to show

##### C.2.3: Terminal History Export 🔬 NEEDS DESIGN
- [ ] Design export format (markdown with timestamps)
- [ ] Create export script/kitten
- [ ] Add keyboard shortcut (Ctrl+Shift+H suggested)
- [ ] Test with large scrollback buffers
- **Estimate:** 1 hour
- **Status:** Waiting for user clarification on format preferences

##### C.2.4: Panel Kitten Debugging 🐛 IN PROGRESS
- [x] Research panel kitten issues (Platform-dependent!)
- [ ] Debug F12 not spawning panel
- [ ] Test on KDE Plasma (user's environment)
- [ ] Document platform-specific limitations
- **Estimate:** 30 mins
- **Status:** Waiting for user to test F12 and report results
- **Known Issue:** KDE Plasma has partial support (clicks outside may hide panel)

##### C.2.5: Right-Click Menu ❌ NOT SUPPORTED
- [x] Research right-click context menu (NOT POSSIBLE - by design)
- [x] Document keyboard shortcuts as alternative
- [ ] Customize mouse_map if user wants different right-click behavior
- **Estimate:** N/A (cannot implement)
- **Status:** Documented limitations, suggest keyboard shortcuts
- **Alternative:** Custom mouse_map actions available

##### C.2.6: Autocomplete.sh Integration 🔬 RESEARCH PHASE
- [x] Research autocomplete.sh architecture
- [x] Confirm Atuin integration exists
- [ ] Web research for best integration approach
- [ ] Test autocomplete.sh with Atuin history
- [ ] Configure LLM backend (requires API keys)
- [ ] Integrate with kitty shell integration
- **Estimate:** 2-3 hours
- **Status:** Needs deep research + testing
- **Repository:** TIAcode/LLMShellAutoComplete

##### C.2.7: Fix Theme Browser Issue 🐛 NEEDS INFO
- [ ] Understand what broke (user to clarify)
- [ ] Fix configuration error
- [ ] Test theme persistence
- **Estimate:** 15-30 mins
- **Status:** Waiting for user to describe the issue

##### C.2.8: Tab Navigation Enhancements ✅ COMPLETE
- [x] Add Alt+Left/Right shortcuts (browser-style)
- [x] Add Alt+H/L shortcuts (vim-style)
- [x] Add Ctrl+PageUp/PageDown (firefox-style)
- [x] Extend to 9 tabs (Ctrl+Alt+1-9)
- **Status:** Complete, user approved current logic

##### C.2.9: Terminal Shortcuts Helper ✅ COMPLETE
- [x] Create navi cheatsheets (basic + extended)
- [x] Add bashrc helpers (kh, khe, ks)
- [x] Implement daily reminder (non-intrusive)
- **Status:** Complete and documented

**Phase C.2 Success Criteria:**
- [ ] Scrollbar is clickable and visually pleasing
- [ ] Status bar shows relevant info at bottom
- [ ] Terminal history export works reliably
- [ ] F12 panel kitten functioning
- [ ] Autocomplete.sh integrated with Atuin
- [ ] Theme issue resolved
- [ ] All limitations documented

---

#### C.3: Image Display Setup (OPTIONAL)
- [ ] Test icat with sample images
- [ ] Create alias for quick image preview
- [ ] Document use cases

#### C.4: Custom Kittens (ADVANCED - OPTIONAL)
- [ ] Explore custom kitten creation
- [ ] Consider creating SRE-specific kittens (log analysis, etc.)

---

### **Phase D: Zellij Integration (FUTURE - 2-3 hours)**

**Note:** Planned for separate Zellij integration session

#### D.1: Ctrl+H Shortcuts Overlay 📋 PLANNED
- [ ] Install and configure zellij
- [ ] Create zellij layout for shortcuts display
- [ ] Map Ctrl+H to spawn floating pane with navi cheatsheets
- [ ] Arrow navigation: Up/Down = scroll, Left/Right = switch basic ↔ extended
- [ ] Auto-hide on Esc or Ctrl+H again
- **Estimate:** 1-2 hours (after zellij setup)
- **Status:** Noted for Zellij Phase 2
- **Alternative:** Temporary workaround with split window (if needed now)

#### D.2: Session Persistence (FUTURE)
- [ ] Zellij sessions for persistent terminal state
- [ ] Can attach from different kitty instances
- [ ] "Merge" instances by attaching to same session
- **Estimate:** 1 hour
- **Status:** Planned for Zellij Phase

---

### **Phase E: Environment Variables** (5-10 mins) ✅ COMPLETE

Already configured in bashrc:
```bash
# ============ Editor Configuration ============
export VISUAL="codium"
export EDITOR="codium"
export GIT_EDITOR="codium --wait"
```

---

## 🎯 Success Criteria

**Phase B Complete When:**
- [x] VSCodium integration working ✅
- [x] Hints kitten enhanced ✅
- [x] Search kitten installed and working ✅
- [x] Git diff using kitty ✅
- [x] Shell integration active ✅
- [x] SSH kitten aliased ✅

**Phase B Status:** ✅ COMPLETE (2025-12-01 02:15)

**Phase C Complete When:**
- [ ] Panel kitten configured
- [ ] icat tested and documented
- [ ] All features documented in navi cheatsheets

---

## 📚 Related Documentation

**Official Resources:**
- Kittens Overview: https://sw.kovidgoyal.net/kitty/kittens_intro/
- Custom Kittens: https://sw.kovidgoyal.net/kitty/kittens/custom/
- Search Kitten: https://github.com/trygveaa/kitty-kitten-search
- Remote Control: https://sw.kovidgoyal.net/kitty/remote-control/

**Project Docs:**
- Kitty Guide: `docs/tools/kitty.md`
- Kitty Basic Enhancements: `docs/plans/kitty-enhancements-plan.md`
- Zellij Integration: `docs/plans/kitty-zellij-phase1-plan.md`

---

## 🔧 Navi Cheatsheet Additions

**File:** `dotfiles/dot_local/share/navi/cheats/kitty.cheat`

```cheat
% kitty, kittens, plugins

# Search in scrollback buffer
<Ctrl+Shift+/>

# Display image in terminal
kitty +kitten icat <image_path>

# Side-by-side file diff
kitty +kitten diff <file1> <file2>

# Git diff with kitty
git difftool

# SSH with terminfo copying
kitty +kitten ssh <hostname>

# Browse and apply themes
kitty +kitten themes

# Jump to previous command prompt
<Ctrl+Shift+Z>

# Jump to next command prompt
<Ctrl+Shift+X>

# Show last command output
<Ctrl+Shift+G>

$ image_path: find . -name "*.png" -o -name "*.jpg" -o -name "*.gif"
$ file1: find . -type f
$ file2: find . -type f
$ hostname: cat ~/.ssh/config | grep "^Host " | awk '{print $2}'
```

---

## 💡 Tips & Best Practices

1. **Search Kitten:**
   - Use regex mode (Tab) for powerful searches
   - Ctrl+U to clear and start fresh search
   - Enter to stay at found position

2. **Hints Kitten:**
   - `Ctrl+Shift+P` opens hint mode menu
   - Combine with different actions (copy, paste, open)
   - Create custom regex patterns for project-specific patterns

3. **Git Integration:**
   - Use `git difftool` instead of `git diff` for visual diffs
   - Configure as default: `git config --global diff.tool kitty`

4. **SSH Kitten:**
   - Always use `kitty +kitten ssh` to avoid terminfo issues
   - Alias it to `ssh` in bashrc

5. **Remote Control:**
   - Use for scripting complex workflows
   - Build custom productivity tools
   - Integrate with external programs

---

## 🚧 Known Limitations

1. **Search Kitten:** Third-party, not built-in (requires git clone)
2. **Panel Kitten:** Experimental, may have edge cases
3. **icat:** Only works in kitty (not over SSH unless using kitty ssh kitten)
4. **Custom Kittens:** Requires Python knowledge

---

## 🎬 Next Steps

**Immediate (Phase B):**
1. Install search kitten
2. Configure git diff
3. Enable shell integration
4. Alias SSH kitten

**Later (Phase C):**
1. Experiment with panel kitten
2. Explore image display use cases
3. Consider custom kitten development for SRE workflows

---

**Last Updated:** 2025-12-01
**Maintained By:** Dimitris Tsioumas (Mitsio)
