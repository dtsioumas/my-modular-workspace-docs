# Implementation Plan: Classic Autocomplete with ble.sh

**Status:** 📋 Planning
**Created:** 2025-12-03
**Author:** Mitsio (with Claude Code)
**Workspace:** shoshin
**Goal:** Implement fish-like proactive autosuggestions in bash using ble.sh

---

## Overview

This plan implements classic (non-LLM) autocomplete for bash in kitty terminal using **ble.sh** (Bash Line Editor). ble.sh provides:
- ✅ Fish-like autosuggestions (as you type)
- ✅ Syntax highlighting
- ✅ History-based suggestions
- ✅ Accept with Right Arrow key

**Architecture:** Two-layer approach per ADR-009
- **Layer 1 (home-manager):** Install ble.sh package
- **Layer 2 (chezmoi):** Configure ble.sh via dotfiles

---

## Prerequisites

✅ **Already satisfied:**
- bash is current shell
- kitty terminal with shell_integration enabled
- atuin installed and configured
- home-manager setup working
- chezmoi setup working
- ADR-009 documented

---

## Phase 1: Package Installation (Home-Manager)

**Goal:** Install ble.sh package via nixpkgs
**Duration:** ~10 minutes
**Dependencies:** None

### Task 1.1: Check ble.sh availability in nixpkgs

**Subtasks:**
1. Search nixpkgs for ble.sh package
   ```bash
   nix search nixpkgs blesh
   # or
   nix search nixpkgs bash-line-editor
   ```

2. Check package details
   ```bash
   nix-env -qa | grep -i blesh
   ```

3. **If not in nixpkgs:** Plan alternative installation via home-manager activation script

**Files involved:** None (research only)

**Success criteria:**
- ✅ Confirmed ble.sh package name in nixpkgs
- ✅ OR: Alternative installation method identified

---

### Task 1.2: Add ble.sh to home-manager

**Subtasks:**

1. **Edit home-manager/shell.nix**

   **File:** `home-manager/shell.nix`

   **Add to packages list:**
   ```nix
   { config, pkgs, ... }:
   {
     # ... existing config ...

     # Shell enhancement packages
     home.packages = with pkgs; [
       blesh  # Bash Line Editor - fish-like autosuggestions
       # or if different name: bash-line-editor
     ];
   }
   ```

2. **If ble.sh not in nixpkgs, use installation script:**

   Add to `home-manager/shell.nix`:
   ```nix
   { config, pkgs, ... }:
   {
     # ble.sh installation (if not in nixpkgs)
     home.activation.installBlesh = lib.hm.dag.entryAfter ["writeBoundary"] ''
       BLESH_DIR="${config.home.homeDirectory}/.local/share/blesh"

       if [ ! -d "$BLESH_DIR" ]; then
         $DRY_RUN_CMD mkdir -p "$BLESH_DIR"
         $DRY_RUN_CMD ${pkgs.git}/bin/git clone --recursive --depth 1 \
           https://github.com/akinomyoga/ble.sh.git "$BLESH_DIR"
         $DRY_RUN_CMD make -C "$BLESH_DIR" install PREFIX="${config.home.homeDirectory}/.local"
       fi
     '';
   }
   ```

**Files involved:**
- `home-manager/shell.nix`

**Success criteria:**
- ✅ ble.sh installation code added to home-manager
- ✅ Syntax is valid Nix

---

### Task 1.3: Apply home-manager configuration

**Subtasks:**

1. **Test home-manager configuration**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
   home-manager build
   ```

2. **Apply configuration**
   ```bash
   home-manager switch
   ```

3. **Verify installation**
   ```bash
   # If installed via nixpkgs:
   ls -la ~/.nix-profile/share/blesh/ble.sh

   # If installed via activation script:
   ls -la ~/.local/share/blesh/ble.sh
   ```

**Files involved:**
- `home-manager/shell.nix` (modified)

**Success criteria:**
- ✅ home-manager switch completes without errors
- ✅ ble.sh binary/script exists at expected location
- ✅ `command -v ble.sh` or path verification succeeds

---

## Phase 2: Bash Configuration (Chezmoi)

**Goal:** Configure .bashrc to source ble.sh
**Duration:** ~15 minutes
**Dependencies:** Phase 1 complete

### Task 2.1: Add ble.sh sourcing to .bashrc

**Subtasks:**

1. **Determine ble.sh installation path**

   Check which path ble.sh was installed to:
   - nixpkgs: `~/.nix-profile/share/blesh/ble.sh`
   - manual: `~/.local/share/blesh/ble.sh`

2. **Edit dotfiles/dot_bashrc.tmpl**

   **File:** `dotfiles/dot_bashrc.tmpl`

   **Location:** Add AFTER history configuration, BEFORE Atuin initialization

   **Reason:** ble.sh should load early, but Atuin must load LAST

   **Add this block:**
   ```bash
   # ============================================================================
   # BLE.SH - BASH LINE EDITOR (Fish-like autosuggestions)
   # ============================================================================
   # Provides proactive command suggestions based on history
   # GitHub: https://github.com/akinomyoga/ble.sh
   # Config: ~/.config/blesh/init.sh

   # Only load if ble.sh is installed
   {{ if (or (stat (joinPath .chezmoi.homeDir ".nix-profile/share/blesh/ble.sh"))
             (stat (joinPath .chezmoi.homeDir ".local/share/blesh/ble.sh"))) }}

   # Determine installation path
   if [[ -f "{{ .chezmoi.homeDir }}/.nix-profile/share/blesh/ble.sh" ]]; then
     BLE_SH_PATH="{{ .chezmoi.homeDir }}/.nix-profile/share/blesh/ble.sh"
   elif [[ -f "{{ .chezmoi.homeDir }}/.local/share/blesh/ble.sh" ]]; then
     BLE_SH_PATH="{{ .chezmoi.homeDir }}/.local/share/blesh/ble.sh"
   fi

   # Load ble.sh if path found
   if [[ -n "$BLE_SH_PATH" ]]; then
     source "$BLE_SH_PATH" --noattach
   fi
   {{ end }}
   ```

3. **Add ble-attach at END of .bashrc**

   **File:** `dotfiles/dot_bashrc.tmpl`

   **Location:** VERY END of file, AFTER all other sourcing (especially Atuin)

   **Add:**
   ```bash
   # ============================================================================
   # BLE.SH ATTACH (Must be LAST)
   # ============================================================================
   # Attach ble.sh to current shell session
   # This MUST come after all other shell initialization

   ((_ble_bash)) && ble-attach
   ```

**Files involved:**
- `dotfiles/dot_bashrc.tmpl`

**Success criteria:**
- ✅ ble.sh sourcing code added with --noattach flag
- ✅ ble-attach added at end of file
- ✅ Conditional loading based on file existence
- ✅ Chezmoi template syntax is valid

---

### Task 2.2: Test bashrc changes

**Subtasks:**

1. **Check chezmoi diff**
   ```bash
   chezmoi diff
   ```

2. **Apply chezmoi changes**
   ```bash
   chezmoi apply ~/.bashrc
   ```

3. **Test in new bash session**
   ```bash
   bash
   # Should see ble.sh load messages
   # Type a command you've used before - should see gray suggestion
   ```

4. **Verify no conflicts with existing tools**
   - Test Ctrl+R (atuin) still works
   - Test Ctrl+G (navi) still works
   - Test kitty shell integration still works

**Files involved:**
- `dotfiles/dot_bashrc.tmpl` (modified)
- `~/.bashrc` (generated)

**Success criteria:**
- ✅ chezmoi apply succeeds
- ✅ New bash session loads ble.sh
- ✅ Autosuggestions appear in gray
- ✅ Right arrow accepts suggestion
- ✅ No errors during bash startup
- ✅ Existing tools (atuin, navi, kitty) still functional

---

## Phase 3: ble.sh Configuration (Chezmoi)

**Goal:** Configure ble.sh behavior and appearance
**Duration:** ~20 minutes
**Dependencies:** Phase 1 complete (can run parallel to Phase 2)

### Task 3.1: Create ble.sh config directory structure

**Subtasks:**

1. **Create config directory**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
   mkdir -p dot_config/blesh
   ```

2. **Create init.sh file**
   ```bash
   touch dot_config/blesh/init.sh
   ```

**Files involved:**
- `dotfiles/dot_config/blesh/` (new directory)
- `dotfiles/dot_config/blesh/init.sh` (new file)

**Success criteria:**
- ✅ Directory structure created
- ✅ init.sh file exists

---

### Task 3.2: Configure ble.sh settings

**Subtasks:**

1. **Edit dotfiles/dot_config/blesh/init.sh**

   **File:** `dotfiles/dot_config/blesh/init.sh`

   **Content:**
   ```bash
   # ble.sh configuration
   # Auto-sourced by ble.sh if ~/.config/blesh/init.sh exists
   # Documentation: https://github.com/akinomyoga/ble.sh/blob/master/blerc.template

   # ============================================================================
   # AUTOSUGGESTION SETTINGS
   # ============================================================================

   # Auto-complete behavior
   bleopt complete_auto_delay=300        # Delay before showing suggestions (ms)
   bleopt complete_auto_limit=100        # Max candidates to show
   bleopt complete_auto_wordbreaks=$' \t\n'  # Word break characters

   # Auto-complete menu appearance
   bleopt complete_menu_style=align-nowrap  # Menu layout style
   bleopt complete_menu_maxlines=10         # Max menu lines

   # ============================================================================
   # SUGGESTION APPEARANCE
   # ============================================================================

   # History-based suggestion color (gray)
   # Uses terminal color palette - adapts to kitty theme!
   bleopt highlight_color_auto_suggest='fg=242'  # Dark gray

   # Syntax highlighting colors (adapt to kitty theme)
   ble-face -s command_function fg=green
   ble-face -s command_builtin fg=cyan
   ble-face -s command_alias fg=yellow
   ble-face -s command_file fg=blue
   ble-face -s disabled fg=red
   ble-face -s syntax_error fg=red,bold

   # ============================================================================
   # KEYBINDINGS
   # ============================================================================

   # Accept autosuggestion with Right Arrow (default)
   # Accept word with Ctrl+Right Arrow
   # Clear suggestion with Ctrl+C

   # Custom: Accept with Tab (optional - may conflict with completion)
   # bleopt complete_auto_complete_on_tab=true

   # ============================================================================
   # INTEGRATION
   # ============================================================================

   # Disable ble.sh's own history management (use atuin instead)
   bleopt history_share=false
   bleopt history_lazyload=true

   # Performance tuning
   bleopt exec_errexit_mark=''  # Don't mark failed commands
   bleopt exec_elapsed_mark=''  # Don't show execution time

   # ============================================================================
   # COMPATIBILITY
   # ============================================================================

   # Ensure compatibility with atuin (Ctrl+R)
   # atuin binds Ctrl+R, ble.sh should not override
   bleopt keymap_vi_mode_string_nmap=
   ```

2. **Add comments and documentation**
   - Explain each setting
   - Reference official docs
   - Note kitty theme compatibility

**Files involved:**
- `dotfiles/dot_config/blesh/init.sh`

**Success criteria:**
- ✅ Config file created with sensible defaults
- ✅ Colors configured to work with kitty themes
- ✅ Atuin compatibility preserved
- ✅ Well-documented with comments

---

### Task 3.3: Apply ble.sh configuration

**Subtasks:**

1. **Add files to chezmoi**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
   chezmoi add ~/.config/blesh/init.sh
   ```

2. **Apply configuration**
   ```bash
   chezmoi apply ~/.config/blesh/
   ```

3. **Test configuration**
   ```bash
   # Start new bash session
   bash
   # Type a previous command - should see configured behavior
   ```

**Files involved:**
- `dotfiles/dot_config/blesh/init.sh` (added to chezmoi)
- `~/.config/blesh/init.sh` (generated)

**Success criteria:**
- ✅ Files tracked by chezmoi
- ✅ Config applied to home directory
- ✅ ble.sh loads custom config
- ✅ Appearance matches expectations

---

## Phase 4: Integration & Testing

**Goal:** Verify everything works together
**Duration:** ~30 minutes
**Dependencies:** Phases 1, 2, 3 complete

### Task 4.1: Functional testing

**Subtasks:**

1. **Test autosuggestions**
   - Open new kitty window
   - Type first letters of a previous command
   - Verify gray suggestion appears
   - Press Right Arrow → suggestion accepted
   - Verify command executes correctly

2. **Test syntax highlighting**
   - Type valid command → should be colored (e.g., green)
   - Type invalid command → should be colored (e.g., red)
   - Type path that exists → should be underlined

3. **Test history integration**
   - Type command, execute
   - Type first letters → should suggest from history
   - Verify most recent commands prioritized

**Success criteria:**
- ✅ Autosuggestions work as expected
- ✅ Syntax highlighting works
- ✅ History-based suggestions work
- ✅ Suggestions can be accepted with Right Arrow

---

### Task 4.2: Compatibility testing

**Subtasks:**

1. **Test atuin compatibility**
   - Press Ctrl+R → atuin should open
   - Search for command
   - Select command → should work
   - Verify ble.sh doesn't interfere

2. **Test navi compatibility**
   - Press Ctrl+G → navi should open
   - Select a cheatsheet entry
   - Verify works correctly

3. **Test kitty integration**
   - Test kitty shortcuts (F12 dropdown, Ctrl+Shift+F9 themes, etc.)
   - Verify shell integration still works
   - Test SSH kitten

4. **Test other bash features**
   - Test aliases (ll, gs, etc.)
   - Test functions (cht.sh, navi-quick, etc.)
   - Test environment variables

**Success criteria:**
- ✅ Atuin (Ctrl+R) works
- ✅ Navi (Ctrl+G) works
- ✅ Kitty integration works
- ✅ All existing bash features work
- ✅ No conflicts or errors

---

### Task 4.3: Performance testing

**Subtasks:**

1. **Test startup time**
   ```bash
   time bash -i -c exit
   ```
   - Should be < 1 second
   - Compare before/after ble.sh

2. **Test responsiveness**
   - Type rapidly → suggestions should keep up
   - Navigate history → should be smooth
   - Large command output → no lag

3. **Test resource usage**
   - Check memory: `ps aux | grep bash`
   - Should be reasonable (< 50MB per bash session)

**Success criteria:**
- ✅ Bash startup < 1 second
- ✅ Suggestions responsive (< 300ms)
- ✅ No noticeable performance degradation
- ✅ Memory usage acceptable

---

### Task 4.4: Edge case testing

**Subtasks:**

1. **Test with long commands**
   - Type very long command (> 200 chars)
   - Verify suggestion works
   - Verify no visual glitches

2. **Test with special characters**
   - Commands with pipes (`|`)
   - Commands with redirects (`>`, `>>`)
   - Commands with quotes (`"`, `'`)

3. **Test with multiple terminal sessions**
   - Open 3 kitty tabs
   - Verify each has independent suggestions
   - Verify history syncs correctly

4. **Test error scenarios**
   - ble.sh not installed → bash should still work
   - Config file missing → ble.sh should use defaults
   - Corrupted config → should fallback gracefully

**Success criteria:**
- ✅ Long commands handled correctly
- ✅ Special characters don't break suggestions
- ✅ Multiple sessions work independently
- ✅ Graceful fallback on errors

---

## Phase 5: Documentation

**Goal:** Document the implementation and usage
**Duration:** ~30 minutes
**Dependencies:** Phase 4 complete (can run parallel)

### Task 5.1: Create user guide

**Subtasks:**

1. **Create docs/commons/toolbox/kitty/BLE_SH_GUIDE.md**

   **File:** `docs/commons/toolbox/kitty/BLE_SH_GUIDE.md`

   **Structure:**
   - What is ble.sh?
   - Features enabled
   - Usage guide
     - How to accept suggestions
     - How to navigate suggestions
     - Keybindings
   - Configuration
     - Where config files are
     - How to customize
   - Troubleshooting
     - Common issues
     - How to disable/enable
   - Integration notes
     - Works with atuin
     - Works with kitty
   - References

2. **Update docs/commons/toolbox/kitty/README.md**
   - Add reference to ble.sh guide
   - Update feature list to include autocomplete

**Files involved:**
- `docs/commons/toolbox/kitty/BLE_SH_GUIDE.md` (new)
- `docs/commons/toolbox/kitty/README.md` (updated)

**Success criteria:**
- ✅ User guide created with clear instructions
- ✅ README updated with reference
- ✅ All keybindings documented
- ✅ Troubleshooting section complete

---

### Task 5.2: Document configuration in README

**Subtasks:**

1. **Update main project README if needed**

   **File:** Could update project root README or keep in docs/

2. **Create changelog entry**
   - Note: Enhancement added (ble.sh autocomplete)
   - Date: 2025-12-03
   - Files changed

**Files involved:**
- Project documentation files

**Success criteria:**
- ✅ Changes documented
- ✅ Future reference available

---

### Task 5.3: Update relevant ADRs

**Subtasks:**

1. **Review ADR-009**

   **File:** `docs/adrs/ADR-009-BASH_SHELL_ENHANCEMENT_CONFIGURATION.md`

   - Add ble.sh as example in "Examples" section
   - Note that implementation follows the documented pattern

2. **Create follow-up notes if needed**
   - Document any deviations from original plan
   - Note any discoveries during implementation

**Files involved:**
- `docs/adrs/ADR-009-BASH_SHELL_ENHANCEMENT_CONFIGURATION.md`

**Success criteria:**
- ✅ ADR updated with real-world example
- ✅ Pattern validation complete

---

## Rollback Plan

If ble.sh causes issues, follow these steps:

### Immediate Rollback (< 5 minutes)

1. **Disable ble.sh in .bashrc**
   ```bash
   # Comment out ble.sh loading in ~/.bashrc
   # Open new terminal - should work without ble.sh
   ```

2. **Or remove from chezmoi**
   ```bash
   cd dotfiles
   # Edit dot_bashrc.tmpl, comment out ble.sh section
   chezmoi apply ~/.bashrc
   ```

### Full Removal (< 15 minutes)

1. **Remove from chezmoi**
   - Remove ble.sh sections from `dotfiles/dot_bashrc.tmpl`
   - Remove `dotfiles/dot_config/blesh/`
   - Apply: `chezmoi apply`

2. **Remove from home-manager**
   - Remove ble.sh from `home-manager/shell.nix`
   - Run: `home-manager switch`

3. **Cleanup**
   ```bash
   rm -rf ~/.local/share/blesh  # If manually installed
   rm -rf ~/.config/blesh
   ```

---

## Success Criteria (Overall)

✅ **Functional:**
- ble.sh provides fish-like autosuggestions
- Suggestions appear in gray as you type
- Right arrow accepts suggestions
- Syntax highlighting works
- History-based suggestions work

✅ **Integration:**
- No conflicts with atuin (Ctrl+R works)
- No conflicts with navi (Ctrl+G works)
- No conflicts with kitty integration
- All existing bash features work

✅ **Performance:**
- Bash startup < 1 second
- Suggestions responsive (< 300ms delay)
- No noticeable lag during normal use

✅ **Architecture:**
- Follows ADR-009 pattern
- Package via home-manager
- Config via chezmoi
- Well-documented

✅ **Quality:**
- No errors during bash startup
- Graceful fallback if ble.sh unavailable
- Clear user documentation
- Easy to disable if needed

---

## Timeline Estimate

| Phase | Duration | Can Run Parallel? |
|-------|----------|-------------------|
| Phase 1: Package Installation | 10 min | No (prerequisite) |
| Phase 2: Bash Configuration | 15 min | No (needs Phase 1) |
| Phase 3: ble.sh Configuration | 20 min | Yes (with Phase 2) |
| Phase 4: Integration & Testing | 30 min | No (needs 1,2,3) |
| Phase 5: Documentation | 30 min | Yes (with Phase 4) |

**Total Sequential Time:** ~1 hour 45 minutes
**Total With Parallelization:** ~1 hour 15 minutes

---

## Next Steps

After this plan is approved:

1. Execute Phase 1 (Package Installation)
2. Execute Phase 2 (Bash Configuration)
3. Execute Phase 3 (ble.sh Configuration) - in parallel with Phase 2
4. Execute Phase 4 (Integration & Testing)
5. Execute Phase 5 (Documentation) - in parallel with Phase 4

**Ready to proceed?** 🚀
