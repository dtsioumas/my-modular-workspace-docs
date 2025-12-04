# Warp Terminal - Post-Installation Steps

**Prerequisites**: `home-manager switch` completed successfully

---

## Phase 1: Verify Installation

### 1.1 Check Warp is Installed
```bash
# Should show path in /nix/store
which warp-terminal

# Check version
warp-terminal --version
```

### 1.2 First Launch
```bash
warp-terminal
```

**What happens**:
1. Warp opens for the first time
2. Welcome/setup screen appears
3. **Sign in** with your existing Warp account
4. Complete any initial setup prompts

---

## Phase 2: Apply Chezmoi Configuration

### 2.1 Apply Launch Configuration
```bash
# Apply chezmoi - this installs the launch configuration
chezmoi apply
```

**What this does**:
- Creates `~/.local/share/warp-terminal/launch_configurations/my-modular-workspace-dev.yaml`
- Makes the "My Modular Workspace Dev" launch config available in Warp

### 2.2 Verify Launch Config
**In Warp**:
```
1. Open Command Palette: Ctrl+Shift+P (or Cmd+P on Mac)
2. Type: "Launch Configuration"
3. You should see: "My Modular Workspace Dev" in the list
4. Select it to test
```

**Expected**:
- 3 tabs open: "Home Manager" (blue), "Docs" (green), "Ansible" (yellow)
- Correct working directories in each tab
- `git status` runs automatically in Home Manager tab

---

## Phase 3: Configure Global Hotkey (F12)

### 3.1 Open Warp Settings
**In Warp**:
```
Settings → Features → Keys
(or Ctrl+, to open settings)
```

### 3.2 Configure Global Hotkey
```
1. Find "Global Hotkey" section
2. Dropdown: Select "Dedicated hotkey window"
3. Click on keybinding field
4. Press: F12
5. Configure window:
   - Position: Top
   - Screen: Primary (or your preference)
   - Width: 100%
   - Height: 80%
6. Toggle: "Autohides on the loss of keyboard focus" → ON
7. Click "Save" or close settings (auto-saves)
```

### 3.3 Test Global Hotkey
```
1. Press F12 → Warp should drop down from top
2. Click outside Warp → Should hide
3. Press F12 again → Warp reappears
4. Works from ANY application (Kitty, browser, IDE, etc.)
```

---

## Phase 4: Verify GPU Acceleration

### 4.1 Check GPU Usage
**Open Kitty (or another terminal) and run**:
```bash
watch -n 1 nvidia-smi
```

**Look for**:
```
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0     <PID>      C   warp-terminal                            50-100MB   |
+-----------------------------------------------------------------------------+
```

✅ **Success**: If you see `warp-terminal` in the GPU processes
❌ **Issue**: If not listed, check environment variables (see troubleshooting)

### 4.2 Test Performance
**In Warp**:
```bash
# Generate large output to test scrolling
seq 1 10000

# Scroll up and down rapidly
# Should be smooth with GPU acceleration
```

---

## Phase 5: Apply Dracula Theme

### 5.1 Theme Browser
**In Warp**:
```
Method 1 (Recommended):
- Press Ctrl+Shift+F9
- Interactive theme browser opens with live preview
- Search: "Dracula"
- Click to apply

Method 2:
- Settings → Appearance → Theme
- Search: "Dracula"
- Select and apply
```

### 5.2 Verify Theme
- Background: Dark purple-ish (#282a36)
- Foreground: Light gray (#f8f8f2)
- Matches your Kitty terminal theme

---

## Phase 6: KDE Plasma Shortcuts (Optional but Recommended)

### 6.1 Open KDE Shortcuts Settings
```bash
# Or navigate via GUI:
# System Settings → Shortcuts → Custom Shortcuts
```

### 6.2 Create Shortcut 1: Dev Workspace
```
1. Right-click → New → Global Shortcut → Command/URL
2. Name: "Warp - Dev Workspace"
3. Trigger: Click "None" → Press: Meta+Shift+D
4. Action tab:
   - Command/URL: warp-terminal --launch-config "My Modular Workspace Dev"
5. Apply
```

### 6.3 Create Shortcut 2: Regular Warp
```
1. Right-click → New → Global Shortcut → Command/URL
2. Name: "Warp Terminal"
3. Trigger: Meta+Shift+W
4. Action tab:
   - Command/URL: warp-terminal
5. Apply
```

### 6.4 Test KDE Shortcuts
```
Press Meta+Shift+D → Warp opens with 3-tab dev layout
Press Meta+Shift+W → Warp opens normally
```

---

## Phase 7: Commit Configuration

### 7.1 Commit Chezmoi Changes
```bash
cd ~/.local/share/chezmoi

# Check what changed
git status

# Add Warp configs
git add dot_local/share/warp-terminal/
git add dot_config/warp-terminal/  # If any settings files exist

# Commit
git commit -m "Add Warp terminal launch configuration via chezmoi

- Add my-modular-workspace-dev.yaml launch config
- 3-tab layout: home-manager, docs, ansible
- Managed via chezmoi for reproducibility

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 7.2 Commit Home-Manager Changes
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

git status

# Should show:
# - warp.nix (new)
# - home.nix (modified)

git commit -m "Add Warp terminal with GPU acceleration

- Install warp-terminal from nixpkgs-unstable
- Enable NVIDIA GPU acceleration (GTX 960)
- Configure Wayland support for Plasma 6
- Parallel installation (Kitty remains default terminal)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Verification Checklist

After completing all phases:

- [ ] Warp launches: `warp-terminal` command works
- [ ] Account signed in
- [ ] GPU acceleration active (visible in `nvidia-smi`)
- [ ] Launch configuration loads ("My Modular Workspace Dev")
- [ ] 3 tabs with correct directories
- [ ] Global hotkey (F12) toggles Warp window
- [ ] Dracula theme applied
- [ ] KDE shortcuts work (Meta+Shift+D, Meta+Shift+W)
- [ ] Chezmoi configurations committed
- [ ] Home-manager changes committed
- [ ] Smooth scrolling performance
- [ ] Memory usage acceptable (<500MB)

---

## Your Workflow

### Daily Use Pattern:

**Morning - Start in Kitty**:
```bash
# Your main terminal for general work
kitty
```

**Need AI Assistance**:
```
Press F12 → Warp drops down
Ask AI: "generate ansible playbook for..."
Copy result
Press F12 → Back to Kitty
```

**Starting Project Work**:
```
Press Meta+Shift+D
→ Warp opens with full dev workspace
→ Work in Warp for that session
→ Close when done
```

**Quick Warp Access**:
```
Press Meta+Shift+W → Regular Warp window
```

---

## Troubleshooting

### GPU Not Detected
```bash
# Check environment variables
env | grep -E "WARP|NVIDIA|GL"

# Should show:
# WARP_ENABLE_WAYLAND=1
# __NV_PRIME_RENDER_OFFLOAD=1
# __GLX_VENDOR_LIBRARY_NAME=nvidia

# If missing, re-run:
home-manager switch --flake .#mitsio@shoshin
```

### F12 Conflict
```
If F12 doesn't work:
1. Check KDE shortcuts for conflicts
2. Try different key (Ctrl+` or Ctrl+Shift+Space)
3. Configure in Warp Settings → Features → Keys
```

### Launch Config Not Found
```bash
# Verify file exists
ls -la ~/.local/share/warp-terminal/launch_configurations/

# Reapply chezmoi
chezmoi apply

# Check permissions
chmod 644 ~/.local/share/warp-terminal/launch_configurations/*.yaml
```

---

## Next Steps

After verification:
1. **Use Warp for 1-2 weeks** alongside Kitty
2. **Note your usage patterns**:
   - When do you use Warp vs Kitty?
   - Which features are most valuable?
   - Any performance issues?
3. **Iterate on configuration**:
   - Create more launch configs if needed
   - Adjust hotkeys if conflicts
   - Customize theme/settings

---

## Documentation References

- [Complete Guide](./WARP_COMPLETE_GUIDE.md)
- [Implementation Plan](../../project-plans/PLAN_WARP_IMPLEMENTATION.md)
- [Warp Official Docs](https://docs.warp.dev/)

---

**Status**: Ready to execute after `home-manager switch`
**Estimated Time**: 15-20 minutes
**Last Updated**: 2025-12-04
