# Workspace Monitoring Stack - Implementation Status

**Project:** workspace-monitoring
**Created:** 2025-12-29
**Last Updated:** 2025-12-30
**Current Phase:** Phase 1 Complete, Phase 2 Pending

---

## Implementation Phases

### Phase 1: Configuration & Design ✅ COMPLETE

**Timeline:** 2025-12-29 (Session 1)
**Status:** 100% Complete
**Commits:** 3 commits to dotfiles repo

#### Completed Items:

1. **btop Enhanced Configuration** ✅
   - File: `dotfiles/private_dot_config/btop/btop.conf.tmpl`
   - 8 comprehensive presets configured
   - Memory sorting (SRE preference)
   - Disk filtering (exclude /boot, /efi)
   - All sensors enabled (CPU, GPU, mobo, fans)
   - Update interval: 1.5s
   - Commit: `9e703a2`

2. **Dracula Theme for btop** ✅
   - File: `dotfiles/private_dot_config/btop/themes/dracula.theme`
   - Created from scratch using official Dracula palette
   - All color gradients configured
   - Compatible with btop 1.4.5
   - Commit: `987987f`

3. **Zellij Main Layout** ✅
   - File: `dotfiles/private_dot_config/zellij/layouts/monitoring.kdl`
   - 3-pane layout: btop (60%) + nvtop (20%) + sensors (20%)
   - Floating tutorial tips pane (top-right corner)
   - Arrow key navigation configured
   - State persistence enabled
   - Commit: `cb346b2`

4. **Tutorial Tips System** ✅
   - File: `dotfiles/private_dot_config/zellij/tutorial_tips.txt`
   - Quick start guide
   - Navigation shortcuts
   - btop/nvtop/sensors basics
   - Fan control instructions
   - Pro tips included
   - Commit: `cb346b2`

---

### Phase 2: Tool Installation ⏳ PENDING

**Timeline:** TBD (Next session)
**Status:** 0% Complete
**Target:** Home-manager module creation

#### Pending Items:

1. **Home-Manager Monitoring Module** ⏳
   - File: `home-manager/modules/cli/monitoring.nix`
   - Package installations:
     - `btop` (already installed, verify in module)
     - `nvtop` (NEW - GPU process monitor)
     - `lm_sensors` (NEW - hardware sensors)
     - `corectrl` (NEW - fan control GUI)
     - `coolero` (NEW - alt fan control)
     - `powertop` (NEW - power analysis)
   - Shell aliases:
     - `gpu` → nvtop
     - `monitor` → zellij --layout monitoring
   - Dependencies: polkit rules for CoreCtrl

2. **btop Setcap Service** ⏳
   - File: `home-manager/modules/services/btop-setcap.nix`
   - Purpose: Enable CPU wattage monitoring
   - Capability: `CAP_SYS_NICE`
   - Command: `setcap cap_sys_nice=eip $(which btop)`
   - Type: Systemd oneshot service
   - Trigger: After btop package updates

3. **PowerTOP Weekly Timer** ⏳
   - File: `home-manager/modules/services/powertop-analysis.nix`
   - Timer: Weekly (Sunday 09:00)
   - Service: PowerTOP analysis run
   - Output: Log to `~/.logs/powertop/YYYY-MM-DD.log`
   - Notification: Desktop notification with summary
   - Retention: 90 days

4. **Temperature Monitor Service** ⏳
   - File: `home-manager/modules/services/temperature-monitor.nix`
   - Timer: Every 30 seconds
   - Thresholds: CPU >80°C, GPU >85°C
   - Action: Desktop notification (notify-send)
   - Urgency: Critical
   - Only when dashboard hidden (avoid duplicate info)

---

### Phase 3: Advanced Features ⏳ PENDING

**Timeline:** TBD
**Status:** 0% Complete

#### Pending Items:

1. **Alternate Zellij Layouts** ⏳
   - Files: `dotfiles/private_dot_config/zellij/layouts/*.kdl`
   - Layouts to create:
     - `dev.kdl` - Dev work (btop + git + build logs)
     - `sre.kdl` - SRE on-call (btop + logs + journal + alerts)
     - `gpu.kdl` - GPU workload (nvtop 70% + btop 30%)
     - `minimal.kdl` - Minimal (btop full screen)
   - Launch: `zellij --layout <name>`

2. **F12 Global Hotkey** ⏳
   - File: `dotfiles/private_dot_config/kitty/kitty.conf`
   - Action: Toggle Zellij dashboard visibility
   - Implementation: `map f12 toggle_fullscreen` + show/hide kitty window
   - Requires: KDE global shortcut + kitty instance management

3. **Dashboard Auto-start** ⏳
   - Method: XDG autostart
   - File: `~/.config/autostart/monitoring-dashboard.desktop`
   - Command: `kitty --class monitoring-dashboard -e zellij attach monitoring || zellij --session monitoring --layout monitoring`
   - Start: Hidden/minimized
   - F12: Bring to front

4. **CoreCtrl Configuration** ⏳
   - File: `~/.config/CoreCtrl/profiles/performance.xml`
   - Fan curve: Performance (aggressive)
   - Auto-apply: On boot
   - Polkit rules: `/etc/polkit-1/rules.d/90-corectrl.rules`
   - Requires: NixOS system configuration

5. **lm-sensors Configuration** ⏳
   - Run: `sudo sensors-detect`
   - Output: `/etc/conf.d/lm_sensors`
   - Modules: `it87` or `nct6775` (ASUS Z170)
   - Load: Add to `boot.kernelModules` in NixOS
   - Test: `sensors` command shows all data

---

### Phase 4: Documentation & Learning ⏳ PENDING

**Timeline:** TBD
**Status:** 20% Complete (project docs done)

#### Completed:

1. **Project Documentation** ✅
   - README.md (overview)
   - ARCHITECTURE.md (system design)
   - PREFERENCES.md (user choices)
   - IMPLEMENTATION_STATUS.md (this file)

#### Pending:

2. **TOOLS.md Reference** ⏳
   - Tool-by-tool detailed guide
   - Installation instructions
   - Configuration references
   - Troubleshooting per tool

3. **ZELLIJ_LAYOUTS.md** ⏳
   - All 5 layouts explained
   - Use cases for each
   - Customization guide

4. **Comprehensive Navi Cheatsheets** ⏳
   - Files: `dotfiles/dot_local/share/navi/cheats/*.cheat`
   - Cheatsheets needed:
     - `monitoring-btop.cheat` (all btop shortcuts)
     - `monitoring-nvtop.cheat` (nvtop navigation)
     - `monitoring-zellij.cheat` (Zellij dashboard)
     - `monitoring-sensors.cheat` (lm-sensors commands)
     - `monitoring-corectrl.cheat` (fan control)
     - `monitoring-powertop.cheat` (power analysis)
     - `monitoring-workflows.cheat` (common workflows)
   - ~50+ entries per tool (exhaustive reference)

5. **Tutorial-Style Learning Guide** ⏳
   - File: `docs/guides/workspace-monitoring-tutorial.md`
   - Structure:
     - Getting Started (installation, first launch)
     - Basic Monitoring (btop, navigation, presets)
     - Advanced Features (layouts, fan control, alerts)
     - Troubleshooting (common issues, recovery)
   - Step-by-step with screenshots (optional)
   - Beginner-friendly narrative

---

### Phase 5: Testing & Validation ⏳ PENDING

**Timeline:** After Phase 2 complete
**Status:** 0% Complete
**Method:** Live testing with user (interactive)

#### Test Plan:

1. **btop Configuration Test**
   - Launch btop, verify Dracula theme loads
   - Test all 8 presets (P to cycle, 0-9 to jump)
   - Verify memory sorting active
   - Check disk filtering (no /boot visible)
   - Verify sensors visible (CPU temps, GPU, fans)
   - Test CPU wattage display (requires setcap)

2. **Zellij Dashboard Test**
   - Launch: `monitor` (alias)
   - Verify 3-pane layout loads correctly
   - Test pane navigation (Alt+arrows)
   - Verify tutorial tips visible (top-right)
   - Test btop in main pane (preset navigation)
   - Test nvtop in bottom-left (GPU data)
   - Test sensors in bottom-right (hardware data)
   - Detach and reattach (verify state persistence)

3. **Alternate Layouts Test**
   - Launch each layout: dev, sre, gpu, minimal
   - Verify pane configurations
   - Test workflow suitability

4. **F12 Hotkey Test**
   - Press F12 → dashboard appears
   - Press F12 again → dashboard hides
   - Press F12 in dashboard → CoreCtrl opens

5. **Auto-start Test**
   - Logout and login
   - Verify dashboard running in background
   - Press F12 → instant appearance

6. **CoreCtrl Test**
   - Open CoreCtrl (F12 in dashboard)
   - Verify sensors visible
   - Test fan curve adjustment
   - Apply performance profile
   - Verify fans respond
   - Esc → return to dashboard

7. **lm-sensors Test**
   - Run `sensors` command
   - Verify all sensors visible:
     - CPU package temp
     - Per-core temps (all 8 cores)
     - Motherboard temp
     - GPU temp
     - All fan speeds (CPU_FAN, CHA_FAN1-4)
     - Voltages (+12V, +5V, +3.3V, Vcore)

8. **Alerts Test**
   - Stress CPU: `stress-ng --cpu 8 --timeout 60s`
   - Wait for temp >80°C
   - Verify notification appears
   - Check notification content

9. **PowerTOP Test**
   - Wait for weekly timer OR trigger manually
   - Verify log created in `~/.logs/powertop/`
   - Verify desktop notification
   - Check log content

10. **Navi Cheatsheets Test**
    - Run: `navi fn monitoring`
    - Verify all cheatsheets appear
    - Test search functionality
    - Verify command accuracy

---

## Dependencies

### NixOS System Configuration

Some features require NixOS system-level config (cannot be done via home-manager):

1. **Kernel Modules** (lm-sensors)
   ```nix
   boot.kernelModules = [ "it87" "coretemp" ];
   ```

2. **Polkit Rules** (CoreCtrl)
   ```nix
   security.polkit.extraConfig = ''
     polkit.addRule(function(action, subject) {
       // CoreCtrl permissions
     });
   '';
   ```

3. **Setcap Persistence** (btop)
   ```nix
   systemd.services.btop-setcap = { ... };
   ```

**Action Required:** Coordinate with NixOS config updates

---

## Blockers & Risks

### Current Blockers:

- None (Phase 1 complete)

### Potential Risks:

1. **lm-sensors auto-detect may fail**
   - Mitigation: Manual modprobe with force_id
   - Backup: Add to boot.kernelModules

2. **CoreCtrl may need BIOS changes**
   - Risk: BIOS locks PWM controls
   - Mitigation: Check BIOS settings, disable "Q-Fan Control"
   - Alternative: Use fancontrol CLI

3. **NVIDIA driver issues**
   - Risk: nvtop shows "No GPU found"
   - Mitigation: Verify nvidia module loaded
   - Test: `nvidia-smi` works first

4. **F12 hotkey conflicts**
   - Risk: Another app using F12
   - Mitigation: Check KDE global shortcuts, reassign if needed

5. **Zellij version compatibility**
   - Risk: Layout syntax changes between versions
   - Mitigation: Pin Zellij version in home-manager

---

## Success Criteria

### Phase 2 Success:
- ✅ All tools installed via home-manager
- ✅ `gpu` alias launches nvtop
- ✅ `monitor` alias launches dashboard
- ✅ `sensors` shows all hardware data
- ✅ btop shows CPU wattage

### Phase 3 Success:
- ✅ All 4 alternate layouts functional
- ✅ F12 toggles dashboard globally
- ✅ Dashboard auto-starts on login
- ✅ CoreCtrl applies performance profile
- ✅ Temperature alerts working

### Phase 4 Success:
- ✅ All documentation complete
- ✅ All navi cheatsheets created
- ✅ Tutorial guide published

### Phase 5 Success:
- ✅ All tests pass
- ✅ User validates workflow
- ✅ No critical issues found
- ✅ Documentation accurate

### Final Success:
- ✅ Complete monitoring stack operational
- ✅ btop-centric workflow achieved
- ✅ All sensors visible
- ✅ Fan control functional
- ✅ Alerts working
- ✅ Documentation complete
- ✅ User satisfied

---

## Next Actions

**Immediate (Next Session):**
1. Create `home-manager/modules/cli/monitoring.nix`
2. Test basic tool installation
3. Verify sensors work
4. Create one alternate layout (GPU or minimal)
5. Update this status document

**Short-term (Week 1):**
1. Complete all 4 alternate layouts
2. Configure F12 hotkey
3. Setup auto-start
4. Configure CoreCtrl fan curves
5. Write 2-3 navi cheatsheets

**Medium-term (Week 2-3):**
1. Complete all navi cheatsheets
2. Write tutorial guide
3. Full testing validation
4. Refinement based on usage

---

**Last Updated:** 2025-12-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
**Next Review:** After Phase 2 complete
