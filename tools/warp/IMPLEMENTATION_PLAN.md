# Warp Terminal Implementation Plan

**Date**: 2025-12-04
**Target System**: shoshin (NixOS + Home Manager)
**Current Terminal**: Kitty (managed via chezmoi)

---

## Research Summary

### Key Findings

1. **No Home-Manager Module**: Warp doesn't have `programs.warp-terminal`; must use `home.packages` approach
2. **Package Available**: `warp-terminal` in nixpkgs-unstable (already used on shoshin)
3. **GPU Acceleration Critical**: NVIDIA GTX 960 requires specific environment variables
4. **Configuration Structure**:
   - Config: `~/.config/warp-terminal/`
   - Data: `~/.local/share/warp-terminal/`
   - Launch Configs: `~/.local/share/warp-terminal/launch_configurations/` (YAML)
5. **Account Required**: Warp requires user account creation for full functionality

### Integration Pattern (Following Kitty Migration)

Kitty was recently migrated from home-manager to chezmoi (2025-11-29):
- Previously had `kitty.nix` in home-manager for basic setup
- Now managed entirely in `dotfiles/dot_config/kitty/`
- Config is comprehensive YAML with custom keybindings and themes

**Recommended approach for Warp**:
- Create minimal `warp.nix` for installation + GPU env vars
- Manage all configuration in chezmoi from day 1
- Avoid later migration work

---

## Implementation Phases

### Phase 1: Pre-Installation Preparation

#### 1.1 User Decisions Required
See [USER_QUESTIONS.md](./USER_QUESTIONS.md) for detailed questions

**Critical decisions**:
- Warp vs Kitty: Replace or run in parallel?
- Existing config: Import from another machine or start fresh?
- GPU usage: Always NVIDIA or auto-detect?
- Theming: Dracula (like Kitty) or Warp defaults?

#### 1.2 Backup Current Setup
```bash
# Backup current Kitty config (already in chezmoi, but extra safety)
cp -r ~/.config/kitty ~/.config/kitty.backup.$(date +%Y%m%d)

# Document current terminal workflow
cat <<EOF > ~/current-terminal-workflow.md
- Default terminal: Kitty
- Launch method: [document how you start terminal]
- Common sessions: [describe your typical setup]
- Critical workflows: [what must work in new terminal]
EOF
```

### Phase 2: Installation via Home-Manager

#### 2.1 Create `warp.nix`
Location: `home-manager/warp.nix`

```nix
{ config, pkgs, ... }:

{
  # Install Warp Terminal from unstable
  home.packages = with pkgs; [
    warp-terminal
  ];

  # GPU acceleration for NVIDIA GTX 960
  home.sessionVariables = {
    # Enable Wayland support (Plasma 6 default)
    WARP_ENABLE_WAYLAND = "1";

    # NVIDIA-specific environment variables
    # Only enable if GPU acceleration needed
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Optional: Set as default terminal (if replacing Kitty)
  # xdg.mimeApps.defaultApplications = {
  #   "x-scheme-handler/terminal" = "dev.warp.Warp-Stable.desktop";
  # };
}
```

#### 2.2 Import in `home.nix`
Add to imports section:
```nix
imports = [
  # ... existing imports ...
  ./warp.nix
];
```

#### 2.3 Apply Home-Manager Configuration
```bash
home-manager switch
```

### Phase 3: Initial Warp Setup

#### 3.1 First Launch
```bash
# Launch Warp for first time
warp-terminal
# or just: warp
```

#### 3.2 Account Creation
- Follow Warp's account creation flow
- Note: Required for AI features and sync

#### 3.3 Test GPU Acceleration
```bash
# Verify GPU is being used
nvidia-smi  # Check if Warp shows up in GPU processes

# Test rendering performance
# Navigate through Warp UI, check for smooth scrolling
```

### Phase 4: Configuration Migration to Chezmoi

#### 4.1 Explore Default Warp Config
```bash
# Check what Warp created
ls -la ~/.config/warp-terminal/
ls -la ~/.local/share/warp-terminal/
```

#### 4.2 Create Chezmoi Structure
```bash
cd ~/.local/share/chezmoi

# Create Warp config directories
mkdir -p dot_config/warp-terminal
mkdir -p dot_local/share/warp-terminal/launch_configurations
```

#### 4.3 Add Warp Config to Chezmoi
Based on Kitty pattern, likely files to manage:
- Settings/preferences file (if exists)
- Custom themes
- Launch configurations (YAML files)
- Keybinding overrides

```bash
# Add existing config to chezmoi
chezmoi add ~/.config/warp-terminal/*
chezmoi add ~/.local/share/warp-terminal/launch_configurations/*

# Or start with templates for new config
```

#### 4.4 Create Launch Configurations

Example launch config (`dotfiles/dot_local/share/warp-terminal/launch_configurations/dev-workspace.yaml`):

```yaml
# Warp Launch Configuration
# Development workspace for my-modular-workspace
---
name: My Modular Workspace Dev
active_window_index: 0
windows:
  - active_tab_index: 0
    tabs:
      - title: Home Manager
        layout:
          cwd: /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
          commands:
            - exec: git status
        color: blue

      - title: Docs
        layout:
          cwd: /home/mitsio/.MyHome/MySpaces/my-modular-workspace/docs
        color: green

      - title: Ansible
        layout:
          split_direction: horizontal
          panes:
            - cwd: /home/mitsio/.MyHome/MySpaces/my-modular-workspace/ansible
              commands:
                - exec: ls -la playbooks/
            - cwd: /home/mitsio/.MyHome/MySpaces/my-modular-workspace/ansible
        color: yellow
```

### Phase 5: Customization & Theming

#### 5.1 Theme Selection
Options:
- Use Warp's built-in themes
- Import Dracula theme (matching Kitty)
- Create custom theme based on Catppuccin Mocha

#### 5.2 Keybinding Configuration
Compare with Kitty keybindings and decide:
- Keep Kitty muscle memory
- Adopt Warp defaults
- Hybrid approach

#### 5.3 AI Features Setup
- Configure AI command generation preferences
- Set up custom rules if needed

### Phase 6: Testing & Validation

#### 6.1 Functional Testing
- [ ] Terminal opens and renders correctly
- [ ] GPU acceleration works (smooth scrolling)
- [ ] Wayland integration functional (Plasma 6)
- [ ] Copy/paste works
- [ ] Launch configurations load properly
- [ ] Multi-tab/pane layouts work
- [ ] Shell integration (bash) works
- [ ] SSH sessions functional

#### 6.2 Workflow Testing
- [ ] Open typical development sessions
- [ ] Test with real work (editing, compiling, running)
- [ ] Verify performance under load
- [ ] Check memory usage (compare with Kitty)

#### 6.3 Chezmoi Integration Testing
```bash
# Test chezmoi apply
chezmoi apply

# Verify configs are applied correctly
diff ~/.config/warp-terminal/... <expected>

# Test on clean state
rm -rf ~/.config/warp-terminal
chezmoi apply
# Verify recreation works
```

### Phase 7: Migration Decision

#### Option A: Complete Migration (Replace Kitty)
- Remove/comment out kitty.nix import in home.nix
- Set Warp as default terminal
- Keep Kitty configs in chezmoi for backup/reference
- Update documentation

#### Option B: Parallel Use
- Keep both terminals available
- Use Kitty for specific workflows
- Use Warp for AI-assisted development
- No default terminal change

---

## Rollback Procedure

If Warp doesn't work out:

```bash
# 1. Restore Kitty as primary
# In home.nix, ensure kitty.nix is imported

# 2. Remove Warp package
# In home.nix or warp.nix, comment out warp-terminal

# 3. Apply home-manager
home-manager switch

# 4. Clean up Warp configs
rm -rf ~/.config/warp-terminal
rm -rf ~/.local/share/warp-terminal

# 5. Remove from chezmoi
chezmoi forget ~/.config/warp-terminal
```

---

## Success Criteria

Warp installation is considered successful when:

1. **Functionality**:
   - ✅ Terminal launches without errors
   - ✅ GPU acceleration active (verified via nvidia-smi)
   - ✅ All keybindings responsive
   - ✅ Launch configurations work

2. **Performance**:
   - ✅ Startup time < 2 seconds
   - ✅ Smooth scrolling with GPU
   - ✅ Memory usage acceptable (<500MB idle)

3. **Integration**:
   - ✅ Chezmoi manages all configs
   - ✅ Reproducible via `chezmoi apply`
   - ✅ Works with existing workflow

4. **Workflow**:
   - ✅ At least as productive as Kitty
   - ✅ AI features provide value
   - ✅ No critical features missing

---

## Timeline Estimate

**Total estimated time**: 3-5 hours across multiple sessions

- Phase 1 (Decisions): 30 min
- Phase 2 (Installation): 30 min
- Phase 3 (Initial Setup): 30 min
- Phase 4 (Chezmoi Migration): 1-2 hours
- Phase 5 (Customization): 1-2 hours
- Phase 6 (Testing): 30-60 min
- Phase 7 (Decision): 15 min

**Recommended approach**: Split across 2-3 sessions with breaks between phases

---

## Next Steps

1. **Review** this plan and [USER_QUESTIONS.md](./USER_QUESTIONS.md)
2. **Answer** user questions about preferences
3. **Begin** Phase 2 (installation) when ready
4. **Document** any deviations or issues during implementation

---

**References**:
- [warp-terminal-research.md](./warp-terminal-research.md) - Package info
- [warp-terminal-flake-experience.md](./warp-terminal-flake-experience.md) - Flake building insights
- [Warp Official Docs](https://docs.warp.dev/)
- [Kitty config in chezmoi](../../dotfiles/dot_config/kitty/)
