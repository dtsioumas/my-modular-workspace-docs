# Warp Terminal Implementation Plan

**Date**: 2025-12-04
**Status**: Ready for Execution
**Estimated Time**: 45-60 minutes
**Target System**: shoshin (NixOS + Plasma 6)

---

## Executive Summary

Install Warp terminal alongside Kitty on shoshin workspace using:
- **Installation**: Home-manager (`warp.nix`)
- **Configuration**: Chezmoi for dotfiles
- **Strategy**: Parallel terminals with specialized use cases
- **Integration**: Global hotkey (F12) + KDE shortcuts + launch configurations

---

## User Requirements

### Confirmed Answers
1. **Strategy**: B (Parallel use) - Kitty main, Warp for workspace tasks
2. **Existing Config**: B (Start fresh)
3. **GPU**: A (Always use NVIDIA GTX 960)
4. **Account**: A (Already has Warp account)
5. **Theme**: A (Dracula, matching Kitty)

### Use Case
- **Kitty**: Main terminal for daily work
- **Warp**: Specialized use for:
  - AI-assisted command generation
  - Workspace-specific launch configurations
  - Project-based development sessions
  - Quick access via global hotkey

---

## Implementation Phases

### Phase 1: Installation via Home-Manager (15 min)

#### 1.1 Create `warp.nix`
**Location**: `home-manager/warp.nix`

**Content**:
```nix
{ config, pkgs, ... }:

{
  # Install Warp Terminal from nixpkgs-unstable
  home.packages = with pkgs; [
    warp-terminal
  ];

  # NVIDIA GPU acceleration for GTX 960
  home.sessionVariables = {
    # Wayland support for Plasma 6
    WARP_ENABLE_WAYLAND = "1";

    # NVIDIA GPU acceleration
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Note: Kitty remains default terminal (no xdg.mimeApps changes)
}
```

#### 1.2 Import in `home.nix`
Add to imports section:
```nix
imports = [
  # ... existing imports ...
  ./warp.nix              # Warp terminal (parallel with Kitty)
];
```

#### 1.3 Apply Configuration
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch
```

**Expected**: Warp installed, available as `warp-terminal` or `warp`

---

### Phase 2: First Launch & Setup (10 min)

#### 2.1 Launch Warp
```bash
warp-terminal
```

#### 2.2 Sign In
- Use existing Warp account
- Complete authentication flow

#### 2.3 Verify GPU Acceleration
```bash
# In another terminal (Kitty):
nvidia-smi

# Look for "warp-terminal" in GPU processes
# Should show active GPU usage when Warp is running
```

**Success Criteria**:
- ✅ Warp launches without errors
- ✅ Account signed in
- ✅ GPU process visible in `nvidia-smi`

---

### Phase 3: Global Hotkey Configuration (5 min)

#### 3.1 Configure Dedicated Hotkey Window
**In Warp**:
```
Settings → Features → Keys → Global Hotkey
```

**Settings**:
- **Type**: "Dedicated hotkey window"
- **Keybinding**: `F12` (matching Kitty's panel shortcut pattern)
- **Position**: Top
- **Screen**: Primary monitor
- **Size**: 80% height, 100% width
- **Auto-hide on focus loss**: ✅ Enabled

#### 3.2 Test Global Hotkey
```
1. Press F12 → Warp appears from top
2. Click outside → Warp hides
3. Press F12 again → Warp reappears
4. Works from any application (Kitty, browser, IDE)
```

**Success Criteria**:
- ✅ F12 toggles Warp window
- ✅ Quake-style dropdown works smoothly
- ✅ No conflicts with Kitty's F12 (Kitty panel is Ctrl+Shift+F12)

---

### Phase 4: Launch Configuration (10 min)

#### 4.1 Create Chezmoi Structure
```bash
cd ~/.local/share/chezmoi

# Create directories
mkdir -p dot_local/share/warp-terminal/launch_configurations
mkdir -p dot_config/warp-terminal
```

#### 4.2 Create Dev Workspace Launch Config
**File**: `dotfiles/dot_local/share/warp-terminal/launch_configurations/my-modular-workspace-dev.yaml`

```yaml
---
name: My Modular Workspace Dev
active_window_index: 0
windows:
  - active_tab_index: 0
    tabs:
      # Home Manager tab
      - title: Home Manager
        layout:
          cwd: /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
          commands:
            - exec: git status
        color: blue

      # Docs tab
      - title: Docs
        layout:
          cwd: /home/mitsio/.MyHome/MySpaces/my-modular-workspace/docs
        color: green

      # Ansible tab
      - title: Ansible
        layout:
          cwd: /home/mitsio/.MyHome/MySpaces/my-modular-workspace/ansible
          commands:
            - exec: ls -la playbooks/
        color: yellow
```

#### 4.3 Add to Chezmoi
```bash
cd ~/.local/share/chezmoi

# Add launch configuration
chezmoi add ~/.local/share/warp-terminal/launch_configurations/my-modular-workspace-dev.yaml

# Add any Warp settings (after first run creates them)
chezmoi add ~/.config/warp-terminal/* 2>/dev/null || true
```

#### 4.4 Test Launch Config
**In Warp**:
```
1. Open Command Palette (Ctrl+Shift+P or Cmd+P)
2. Type "Launch Configuration"
3. Select "My Modular Workspace Dev"
4. Verify 3 tabs open with correct directories
```

**Success Criteria**:
- ✅ Launch config loads
- ✅ 3 tabs created (home-manager, docs, ansible)
- ✅ Correct working directories
- ✅ Tab colors applied

---

### Phase 5: KDE Plasma Integration (Optional - 5 min)

#### 5.1 Create Custom Shortcuts
**KDE System Settings**:
```
System Settings → Shortcuts → Custom Shortcuts
→ Right-click → New → Global Shortcut → Command/URL
```

**Shortcut 1: Launch Warp with Dev Workspace**
- Name: "Warp - Dev Workspace"
- Command: `warp-terminal --launch-config "My Modular Workspace Dev"`
- Trigger: `Meta+Shift+D`

**Shortcut 2: Launch Warp (Regular)**
- Name: "Warp Terminal"
- Command: `warp-terminal`
- Trigger: `Meta+Shift+W`

#### 5.2 Test KDE Shortcuts
```
1. Press Meta+Shift+D → Warp opens with dev workspace
2. Press Meta+Shift+W → Warp opens normally
```

**Success Criteria**:
- ✅ Shortcuts trigger Warp
- ✅ Launch config loads when using Meta+Shift+D
- ✅ No conflicts with existing KDE shortcuts

---

### Phase 6: Theming (5 min)

#### 6.1 Apply Dracula Theme
**In Warp**:
```
Settings → Appearance → Theme
→ Search "Dracula"
→ Select and apply
```

**Or use Ctrl+Shift+F9** for theme browser with live preview

#### 6.2 Verify Theme Match
Compare with Kitty:
- Background colors similar
- Syntax highlighting consistent
- Visual comfort maintained

---

### Phase 7: Validation & Documentation (10 min)

#### 7.1 Functional Tests
```bash
# Test 1: Basic terminal operations
echo "Hello Warp"
ls -la
cd ~/.MyHome/MySpaces/my-modular-workspace

# Test 2: Shell integration
# Verify command history, completions work

# Test 3: AI features (optional)
# Try Warp AI command generation

# Test 4: Multiple tabs/panes
# Create splits, verify navigation

# Test 5: GPU performance
# Scroll through large output
# Verify smooth rendering
```

#### 7.2 Performance Check
```bash
# In Kitty, monitor Warp:
watch -n 1 nvidia-smi

# Check memory usage
ps aux | grep warp-terminal

# Expected:
# - GPU utilization: 5-20% when active
# - RAM usage: 200-400MB
# - Smooth scrolling, no lag
```

#### 7.3 Commit Configuration
```bash
# Home-manager changes
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git add warp.nix
git add home.nix  # if modified imports
git commit -m "Add Warp terminal with GPU acceleration

- Install warp-terminal from unstable
- Enable NVIDIA GPU acceleration for GTX 960
- Configure Wayland support for Plasma 6
- Parallel installation with Kitty (Kitty remains default)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Chezmoi/dotfiles changes
cd ~/.local/share/chezmoi
git add dot_local/share/warp-terminal/
git add dot_config/warp-terminal/
git commit -m "Add Warp terminal configuration via chezmoi

- Add launch configuration for my-modular-workspace
- Configure Dracula theme
- Set up global hotkey (F12)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Success Criteria

### Must Have (Critical)
- ✅ Warp installs via home-manager
- ✅ GPU acceleration works (verified via nvidia-smi)
- ✅ Global hotkey (F12) toggles Warp
- ✅ Launch configuration loads correctly
- ✅ No interference with Kitty
- ✅ Configuration managed via chezmoi

### Should Have (Important)
- ✅ Dracula theme applied
- ✅ KDE shortcuts configured
- ✅ Smooth performance (< 2s startup)
- ✅ Memory usage reasonable (< 500MB)

### Nice to Have (Optional)
- ⏸️ AI features explored and tested
- ⏸️ Additional launch configs for other projects
- ⏸️ Custom keybindings configured

---

## Rollback Plan

If issues arise:

```bash
# 1. Remove from home-manager
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
# Comment out ./warp.nix from home.nix imports
home-manager switch

# 2. Remove configurations
rm -rf ~/.config/warp-terminal
rm -rf ~/.local/share/warp-terminal

# 3. Remove from chezmoi
cd ~/.local/share/chezmoi
chezmoi forget ~/.config/warp-terminal
chezmoi forget ~/.local/share/warp-terminal
```

---

## Known Issues & Mitigations

### Issue 1: Global Hotkey on Linux
**Problem**: Some X11 window managers don't support global hotkey
**Status**: Not applicable (using Plasma 6 with Wayland)
**Mitigation**: Use KDE custom shortcuts as fallback

### Issue 2: GPU Memory Usage
**Problem**: GPU acceleration can increase memory usage
**Impact**: Low (GTX 960 has sufficient memory)
**Mitigation**: Monitor via `nvidia-smi`, disable if needed

### Issue 3: Warp Account Required
**Problem**: Full features require account
**Status**: Resolved (user has account)

---

## Post-Implementation

### Workflow Integration
**Daily use**:
1. Start Kitty for general terminal work
2. Press F12 when need Warp AI assistance
3. Use Meta+Shift+D for dev workspace sessions
4. Both terminals coexist peacefully

### Monitoring
First week:
- Track GPU usage patterns
- Monitor memory consumption
- Note any performance issues
- Gather feedback on workflow

### Iteration
After 1-2 weeks:
- Review usage patterns
- Decide if creating more launch configs
- Adjust hotkeys if conflicts found
- Consider migration vs. parallel long-term

---

## References

- [Warp Official Docs](https://docs.warp.dev/)
- [Warp Global Hotkey](https://docs.warp.dev/terminal/windows/global-hotkey)
- [Warp Launch Configurations](https://docs.warp.dev/terminal/sessions/launch-configurations)
- [docs/tools/warp/](../tools/warp/) - All Warp documentation
- [Kitty Config](../../dotfiles/dot_config/kitty/) - For comparison

---

**Plan Status**: ✅ Ready for Execution
**Next Step**: Create `warp.nix` and begin Phase 1

---

**Created**: 2025-12-04T02:38:00+02:00
**Last Updated**: 2025-12-04T02:38:00+02:00
