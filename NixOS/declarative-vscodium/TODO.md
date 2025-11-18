# VSCode to VSCodium Migration - TODO

**Project:** declarative-vscodium
**Created:** 2025-11-05
**Status:** Not Started
**Tracking:** Sequential task completion

---

## Task Progress Overview

- [ ] Phase 1: Assessment & Backup (0/5 tasks)
- [ ] Phase 2: Declarative Configuration (0/7 tasks)
- [ ] Phase 3: Extension Compatibility (0/4 tasks)
- [ ] Phase 4: Migration & Testing (0/6 tasks)
- [ ] Phase 5: Cleanup (0/4 tasks)

**Total:** 0/26 tasks completed

---

## Phase 1: Assessment & Backup

**Goal:** Understand current VSCode setup and create backups
**Duration:** ~30 minutes
**Risk:** Low

### Task 1.1: Export Current VSCode Configuration
- [ ] **1.1.1** Read current VSCode settings
  ```bash
  cat ~/.config/Code/User/settings.json > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/settings.json
  ```
- [ ] **1.1.2** Read current VSCode keybindings
  ```bash
  cat ~/.config/Code/User/keybindings.json > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/keybindings.json
  ```
- [ ] **1.1.3** Export snippets (if any)
  ```bash
  cp -r ~/.config/Code/User/snippets ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/
  ```
- [ ] **1.1.4** Document workspace-specific settings
  ```bash
  find ~ -name ".vscode" -type d > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/workspace-dirs.txt
  ```

### Task 1.2: Document Current Extensions
- [ ] **1.2.1** List installed extensions with versions
  ```bash
  code --list-extensions --show-versions > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/extensions-list.txt
  ```
- [ ] **1.2.2** Compare with home.nix extension list
  ```bash
  Read: ~/.config/nixos/home/mitso/home.nix (lines 58-99)
  ```
- [ ] **1.2.3** Note any manually installed extensions (not in home.nix)

### Task 1.3: Check Extension Sources
- [ ] **1.3.1** Search nixpkgs for available extensions
  ```bash
  nix search nixpkgs vscode-extensions | grep -E "(golang|python|kubernetes)" > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/extension-sources.txt
  ```
- [ ] **1.3.2** Check Open VSX Registry for missing extensions
  - Visit: https://open-vsx.org/
  - Search for each extension from list
- [ ] **1.3.3** Document unavailable extensions and alternatives

### Task 1.4: Test VSCodium Installation (Parallel)
- [ ] **1.4.1** Install VSCodium temporarily to test
  ```bash
  nix-shell -p vscodium --run "codium --version"
  ```
- [ ] **1.4.2** Verify it doesn't conflict with VSCode
- [ ] **1.4.3** Test basic functionality (open file, edit, save)
- [ ] **1.4.4** Check extension marketplace access

### Task 1.5: Create Backup Directory Structure
- [ ] **1.5.1** Create backups directory
  ```bash
  mkdir -p ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups
  ```
- [ ] **1.5.2** Document current VSCode version
  ```bash
  code --version > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/vscode-version.txt
  ```

---

## Phase 2: Declarative Configuration

**Goal:** Create Home Manager VSCodium module with all settings
**Duration:** ~1.5 hours
**Risk:** Low

### Task 2.1: Create VSCodium Nix Module
- [ ] **2.1.1** Create module file
  ```bash
  touch ~/.config/nixos/home/mitso/vscodium.nix
  ```
- [ ] **2.1.2** Add basic module structure
  ```nix
  { config, pkgs, lib, ... }:
  {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
  }
  ```
- [ ] **2.1.3** Import module in home.nix
  ```nix
  imports = [
    ./vscodium.nix
  ];
  ```

### Task 2.2: Convert Settings to Nix
- [ ] **2.2.1** Read backed-up settings.json
- [ ] **2.2.2** Convert JSON to Nix userSettings
  - Manual conversion or use json2nix tool
- [ ] **2.2.3** Add userSettings to vscodium.nix
  ```nix
  userSettings = {
    # Settings here
  };
  ```
- [ ] **2.2.4** Test settings build (syntax check)
  ```bash
  nixos-rebuild build --flake ~/.config/nixos#shoshin
  ```

### Task 2.3: Configure Extensions Declaratively
- [ ] **2.3.1** Search nixpkgs for each extension
  ```bash
  nix search nixpkgs vscode-extensions.<name>
  ```
- [ ] **2.3.2** Add available extensions to module
  ```nix
  extensions = with pkgs.vscode-extensions; [
    golang.go
    ms-python.python
    # ... more
  ];
  ```
- [ ] **2.3.3** Document extensions not in nixpkgs
- [ ] **2.3.4** Plan fallback for unavailable extensions

### Task 2.4: Handle Unavailable Extensions
- [ ] **2.4.1** For each unavailable extension, choose strategy:
  - Option A: Build from marketplace
  - Option B: Use Open VSX
  - Option C: Find FOSS alternative
- [ ] **2.4.2** Implement buildVscodeMarketplaceExtension for needed extensions
  ```nix
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "extension-name";
      publisher = "publisher";
      version = "1.0.0";
      sha256 = lib.fakeSha256;  # Will get real hash on first build
    };
  })
  ```
- [ ] **2.4.3** Test extension builds

### Task 2.5: Configure Keybindings
- [ ] **2.5.1** Read backed-up keybindings.json
- [ ] **2.5.2** Convert to Nix keybindings array
  ```nix
  keybindings = [
    {
      key = "ctrl+shift+p";
      command = "workbench.action.showCommands";
    }
    # ... more
  ];
  ```
- [ ] **2.5.3** Add to vscodium.nix

### Task 2.6: Configure Extension Settings
- [ ] **2.6.1** Review extension-specific settings in settings.json
- [ ] **2.6.2** Ensure all extension settings in userSettings
- [ ] **2.6.3** Configure marketplace settings
  ```nix
  userSettings = {
    "extensions.autoUpdate" = false;
    "extensions.autoCheckUpdates" = false;
  };
  ```

### Task 2.7: Test Configuration Build
- [ ] **2.7.1** Build configuration
  ```bash
  sudo nixos-rebuild build --flake ~/.config/nixos#shoshin
  ```
- [ ] **2.7.2** Check for build errors
- [ ] **2.7.3** Fix any Nix syntax errors
- [ ] **2.7.4** Verify all extensions resolve correctly

---

## Phase 3: Extension Compatibility

**Goal:** Ensure all critical extensions work in VSCodium
**Duration:** ~1 hour
**Risk:** Medium

### Task 3.1: Categorize Extensions by Source
- [ ] **3.1.1** List Tier 1 (nixpkgs)
  - golang.go
  - ms-python.python
  - redhat.vscode-yaml
  - ...
- [ ] **3.1.2** List Tier 2 (Open VSX)
  - Check each extension on open-vsx.org
- [ ] **3.1.3** List Tier 3 (Microsoft marketplace only)
  - Identify problematic extensions
- [ ] **3.1.4** List Tier 4 (Proprietary/unavailable)
  - Find FOSS alternatives

### Task 3.2: Test Critical Extensions
- [ ] **3.2.1** Apply test configuration
  ```bash
  sudo nixos-rebuild test --flake ~/.config/nixos#shoshin
  ```
- [ ] **3.2.2** Launch VSCodium
  ```bash
  codium
  ```
- [ ] **3.2.3** Check that extensions are loaded
  - View → Extensions
  - Verify count matches expected
- [ ] **3.2.4** Test each critical extension:
  - [ ] Go extension (golang.go)
  - [ ] Python extension (ms-python.python)
  - [ ] Kubernetes extension
  - [ ] YAML extension
  - [ ] Markdown extensions
  - [ ] Claude Code/Dev extensions

### Task 3.3: Configure Marketplace Access (If Needed)
- [ ] **3.3.1** Check if Microsoft marketplace needed
- [ ] **3.3.2** Configure product.json override
  ```bash
  # If needed, add marketplace URL config
  ```
- [ ] **3.3.3** Test extension installation from marketplace
- [ ] **3.3.4** Document marketplace configuration

### Task 3.4: Handle Missing Extensions
- [ ] **3.4.1** For each missing extension, implement solution:
  - Build from marketplace
  - Use alternative
  - Skip if non-critical
- [ ] **3.4.2** Update vscodium.nix with solutions
- [ ] **3.4.3** Rebuild and retest
- [ ] **3.4.4** Document any permanent losses

---

## Phase 4: Migration & Testing

**Goal:** Fully migrate to VSCodium and validate all workflows
**Duration:** ~1 hour
**Risk:** Medium

### Task 4.1: Apply Final Configuration
- [ ] **4.1.1** Review vscodium.nix one last time
- [ ] **4.1.2** Commit configuration to git
  ```bash
  cd ~/.config/nixos
  git add home/mitso/vscodium.nix
  git commit -m "Add declarative VSCodium configuration"
  ```
- [ ] **4.1.3** Apply configuration
  ```bash
  sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
  ```
- [ ] **4.1.4** Verify no errors in activation

### Task 4.2: Validate Core Functionality
- [ ] **4.2.1** Launch VSCodium
- [ ] **4.2.2** Open a project workspace
- [ ] **4.2.3** Verify settings applied
  - Check theme
  - Check font size
  - Check editor preferences
- [ ] **4.2.4** Verify keybindings work
  - Test custom keybindings
  - Test standard shortcuts

### Task 4.3: Test Language Development Workflows
- [ ] **4.3.1** Test Go development
  - [ ] Open Go file
  - [ ] Check syntax highlighting
  - [ ] Test autocomplete
  - [ ] Test Go to definition
  - [ ] Run/debug Go program
- [ ] **4.3.2** Test Python development
  - [ ] Open Python file
  - [ ] Check virtual environment detection
  - [ ] Test autocomplete
  - [ ] Test linting
  - [ ] Run/debug Python script
- [ ] **4.3.3** Test Bash/shell scripting
  - [ ] Open bash file
  - [ ] Check syntax highlighting
  - [ ] Test bash-language-server
- [ ] **4.3.4** Test Markdown editing
  - [ ] Open markdown file
  - [ ] Test preview
  - [ ] Test linting

### Task 4.4: Test Git Integration
- [ ] **4.4.1** Open Git repository in VSCodium
- [ ] **4.4.2** Check Source Control panel works
- [ ] **4.4.3** Make a test commit
- [ ] **4.4.4** Test Git blame, history, diff
- [ ] **4.4.5** Test GitLab/GitHub workflow extensions (if installed)

### Task 4.5: Test Kubernetes/DevOps Workflows
- [ ] **4.5.1** Open Kubernetes manifest
- [ ] **4.5.2** Check YAML validation
- [ ] **4.5.3** Test Kubernetes extension features
- [ ] **4.5.4** Test Terraform/OpenTofu extension

### Task 4.6: Test Terminal Integration
- [ ] **4.6.1** Open integrated terminal (Ctrl+`)
- [ ] **4.6.2** Check shell is correct (bash)
- [ ] **4.6.3** Test running commands
- [ ] **4.6.4** Test multiple terminals
- [ ] **4.6.5** Check terminal theme/colors

---

## Phase 5: Cleanup

**Goal:** Remove VSCode and finalize migration
**Duration:** ~30 minutes
**Risk:** Low

### Task 5.1: Remove VSCode from System
- [ ] **5.1.1** Disable VSCode activation scripts in home.nix
  - Comment out or remove vscode-extensions-update service
  - Comment out or remove activation scripts
- [ ] **5.1.2** Rebuild without VSCode packages
  ```bash
  sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
  ```
- [ ] **5.1.3** Verify VSCode command no longer available
  ```bash
  which code  # Should not find
  ```
- [ ] **5.1.4** Verify VSCodium is default
  ```bash
  which codium  # Should find /run/current-system/sw/bin/codium
  ```

### Task 5.2: Clean Up Old VSCode Configuration (Optional)
- [ ] **5.2.1** Decide if keeping old config as backup
  - Keep: Rename ~/.config/Code to ~/.config/Code.backup
  - Remove: Delete ~/.config/Code
- [ ] **5.2.2** Move backups to permanent location
  ```bash
  mv ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups-$(date +%Y%m%d)
  ```
- [ ] **5.2.3** Document what was kept/removed

### Task 5.3: Update Documentation
- [ ] **5.3.1** Update desktop-workspace CONTEXT
  - Note VSCodium is now used
  - Document declarative configuration location
- [ ] **5.3.2** Update desktop-workspace INSTRUCTIONS
  - Add VSCodium configuration workflow
  - Document extension management
- [ ] **5.3.3** Create VSCodium section in instructions
- [ ] **5.3.4** Commit documentation changes to llm-core

### Task 5.4: Final Validation
- [ ] **5.4.1** Reboot system (optional but recommended)
- [ ] **5.4.2** Launch VSCodium after reboot
- [ ] **5.4.3** Verify all extensions loaded
- [ ] **5.4.4** Test critical workflows one more time
- [ ] **5.4.5** Declare migration complete!

---

## Success Checklist

After completing all phases, verify:

### Critical Functionality
- [ ] VSCodium launches without errors
- [ ] All settings applied correctly
- [ ] All critical extensions installed and working
- [ ] Go development works (syntax, autocomplete, debug)
- [ ] Python development works (venv, linting, debug)
- [ ] Git integration functional
- [ ] Terminal integration works
- [ ] Keybindings functional

### Configuration Quality
- [ ] All configs in version control
- [ ] Settings declarative in vscodium.nix
- [ ] Extensions declarative (no manual installs)
- [ ] Documentation complete
- [ ] Backups created and stored

### System State
- [ ] VSCode removed from system
- [ ] Old configs backed up or removed
- [ ] No conflicts between editors
- [ ] NixOS builds successfully

---

## Troubleshooting Guide

### Issue: Extension Not Loading
**Solution:**
1. Check extension is in vscodium.nix
2. Verify extension available in nixpkgs or Open VSX
3. Check VSCodium extension panel for errors
4. Try rebuilding: `sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin`

### Issue: Settings Not Applied
**Solution:**
1. Check userSettings syntax in vscodium.nix
2. Verify settings.json not manually created in ~/.config/VSCodium
3. Check for conflicting settings
4. Test with minimal settings to isolate issue

### Issue: Language Server Not Working
**Solution:**
1. Check language extension is installed
2. Verify language toolchain available (go, python, etc.)
3. Check extension settings for path configurations
4. Review VSCodium output panel for errors

### Issue: Build Fails
**Solution:**
1. Check Nix syntax errors in vscodium.nix
2. Verify extension sha256 hashes correct
3. Try building with `--show-trace` for detailed errors
4. Rollback if needed: `sudo nixos-rebuild switch --rollback`

---

## Notes & Observations

**During Migration:**
- Note any issues encountered
- Document solutions
- Track time spent per phase
- Note extensions that didn't work

**After Migration:**
- Compare VSCodium vs VSCode performance
- Note any missing features
- Track any workflow changes
- Document workarounds used

---

**Created:** 2025-11-05
**Status:** Ready to execute
**Estimated Time:** 4-5 hours
**Last Updated:** 2025-11-05
