# Workspace Monitoring Stack - Architecture

**Project:** workspace-monitoring
**Created:** 2025-12-29
**Last Updated:** 2025-12-30

---

## System Architecture Overview

The workspace monitoring stack is built around **btop as the primary control center** with complementary tools integrated through **Zellij** as a dashboard multiplexer, providing comprehensive system monitoring with minimal context switching.

---

## Component Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Desktop Environment                      │
│                         (KDE Plasma)                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                     F12 Global Hotkey
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Kitty Terminal (Host)                           │
│  • F12 keybinding configured                                     │
│  • Auto-start on login (background)                              │
│  • Hotkey shows/hides terminal                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              Zellij Dashboard (Multiplexer)                      │
│  • Layout: monitoring.kdl                                        │
│  • State persistence enabled                                     │
│  • Arrow key navigation (Alt+arrows)                             │
│  • Floating tutorial tips overlay                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
            ┌─────────────────┴─────────────────┐
            ↓                 ↓                  ↓
    ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
    │    btop     │   │    nvtop    │   │   sensors   │
    │   (60%)     │   │    (20%)    │   │    (20%)    │
    │             │   │             │   │             │
    │ Primary     │   │ GPU Process │   │ Motherboard │
    │ Monitor     │   │ Details     │   │ Sensors     │
    └─────────────┘   └─────────────┘   └─────────────┘
            ↓                 ↓                  ↓
       8 Presets        NVIDIA NVML      lm-sensors
                                              ↓
                                    ┌─────────────────┐
                                    │  Hardware       │
                                    │  Sensors        │
                                    │  (IT8628E/      │
                                    │   NCT6793D)     │
                                    └─────────────────┘
```

---

## Data Flow Architecture

### Monitoring Data Collection

```
Hardware Sensors (ASUS Z170 Pro Gaming)
    ↓
┌───────────────────────────────────────────────────┐
│  Kernel Interfaces                                │
│  • /proc/stat           (CPU usage)               │
│  • /proc/meminfo        (Memory)                  │
│  • /sys/class/hwmon/*   (Temps, fans, voltages)   │
│  • /proc/net/dev        (Network)                 │
│  • /sys/block/*/stat    (Disk I/O)                │
│  • NVML API             (NVIDIA GPU)              │
└───────────────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────────────┐
│  Userspace Libraries                              │
│  • libsensors.so        (lm-sensors)              │
│  • libnvidia-ml.so      (NVML for GPU)            │
│  • procps-ng            (Process info)            │
└───────────────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────────────┐
│  Monitoring Applications                          │
│  • btop      → All-in-one system monitor          │
│  • nvtop     → GPU-specific monitor               │
│  • sensors   → Raw sensor data viewer             │
└───────────────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────────────┐
│  User Interface (Zellij Dashboard)                │
│  • Visual presentation                            │
│  • Real-time updates                              │
│  • Interactive navigation                         │
└───────────────────────────────────────────────────┘
```

### Control Flow (Fan Management)

```
User Action (F12 in Dashboard)
    ↓
Zellij Floating Pane (Full Screen)
    ↓
CoreCtrl GUI Application
    ↓
┌───────────────────────────────────────────────────┐
│  Fan Control Backend                              │
│  • Read: /sys/class/hwmon/hwmonX/pwmY             │
│  • Write: /sys/class/hwmon/hwmonX/pwmY            │
│  • Requires: Kernel module + permissions          │
└───────────────────────────────────────────────────┘
    ↓
Kernel PWM Driver (it87 / nct6775)
    ↓
Hardware Fan Controllers (Motherboard)
    ↓
Physical Fans (CPU_FAN, CHA_FAN1-4)
```

---

## Component Details

### 1. btop (Primary Monitor)

**Purpose:** All-in-one system monitoring
**Technology:** C++ TUI application
**Update Rate:** 1.5 seconds
**Data Sources:**
- `/proc/*` for CPU, memory, processes
- `/sys/class/hwmon/*` for temperatures
- `/sys/block/*/stat` for disk I/O
- `/proc/net/dev` for network
- NVML library for GPU data

**Features:**
- 8 configurable presets (different monitoring views)
- Real-time graphs with braille/block/tty symbols
- Process management (kill, sort, filter)
- GPU integration (usage, temp, VRAM)
- Dracula theme for readability

**Configuration:** `~/.config/btop/btop.conf`

**Preset Architecture:**
```
Preset 0: Auto (all boxes, default)
Preset 1: Main Compact (daily use - all essentials)
Preset 2: GPU Focus (detailed GPU monitoring)
Preset 3: Disk I/O (storage performance)
Preset 4: Memory Detail (RAM/swap focus)
Preset 5: Network Focus (bandwidth + connections)
Preset 6: CPU Detail (per-core temps)
Preset 7: Minimal (CPU + processes only)
Preset 8: Server Mode (no GPU, all others)
```

---

### 2. nvtop (GPU Monitor)

**Purpose:** GPU process-level monitoring
**Technology:** C TUI application
**Data Source:** NVML (NVIDIA Management Library)

**Provides What btop Cannot:**
- Per-process GPU usage
- Per-process VRAM allocation
- GPU process tree
- Detailed PCIe throughput per process

**Integration:** Bottom-left pane (20% of dashboard)

---

### 3. lm-sensors (Hardware Sensors)

**Purpose:** Raw hardware sensor access
**Technology:** Kernel modules + userspace library
**Supported Chips:** IT8628E, Nuvoton NCT6793D (ASUS Z170)

**Sensor Types:**
- **Temperature:** CPU package, per-core, motherboard, VRM, chipset
- **Voltages:** +12V, +5V, +3.3V, CPU Vcore, DRAM voltage
- **Fan Speeds:** All fan headers (RPM)
- **Power:** CPU package power (RAPL)

**Configuration Flow:**
```bash
sudo sensors-detect  # Auto-detect sensors
# → Generates /etc/conf.d/lm_sensors
# → Loads kernel modules (it87, nct6775, coretemp)

sensors  # View all sensor data
watch -n 2 -c sensors  # Live monitoring (dashboard pane)
```

**Integration:** Bottom-right pane (20% of dashboard)

---

### 4. Zellij (Dashboard Multiplexer)

**Purpose:** Terminal multiplexer for dashboard layout
**Technology:** Rust TUI application
**Layout System:** KDL (KDM Document Language)

**Key Features:**
- Pane management (split, resize, focus)
- Floating panes (tutorial overlay, CoreCtrl)
- Tab system (multiple layouts)
- State persistence (session resurrection)
- Keyboard-driven navigation

**Layout Files:** `~/.config/zellij/layouts/*.kdl`

**Layouts Planned:**
1. **monitoring.kdl** - Main 3-pane layout (btop + nvtop + sensors)
2. **dev.kdl** - Development (btop + git status + build logs)
3. **sre.kdl** - SRE on-call (btop + system logs + journal + alerts)
4. **gpu.kdl** - GPU workload (nvtop 70% + btop 30%)
5. **minimal.kdl** - Minimal (btop full screen only)

---

### 5. CoreCtrl (Fan Control)

**Purpose:** GUI for fan curve management
**Technology:** Qt-based GUI application
**Backend:** Direct sysfs writes to `/sys/class/hwmon/*/pwm*`

**Architecture:**
```
CoreCtrl GUI
    ↓
Polkit Rules (elevated permissions)
    ↓
/sys/class/hwmon/hwmonX/pwmY_enable  (mode: manual/auto)
/sys/class/hwmon/hwmonX/pwmY         (duty cycle: 0-255)
    ↓
Kernel PWM Driver (it87 for ASUS Z170)
    ↓
Motherboard Fan Controller
    ↓
Physical Fans
```

**Fan Curve Design (Performance Profile):**
```
Temp (°C)  →  Fan Duty %  →  Fan RPM (approx)
─────────────────────────────────────────────
< 40       →  30%         →  ~800 RPM
40-50      →  40%         →  ~1000 RPM
50-60      →  60%         →  ~1400 RPM
60-70      →  80%         →  ~1800 RPM
> 70       →  100%        →  ~2200 RPM (max)
```

**Integration:** F12 hotkey → Zellij floating pane (full screen)

---

### 6. PowerTOP (Power Analysis)

**Purpose:** Power consumption monitoring and optimization
**Technology:** Intel-developed power analysis tool
**Data Source:** RAPL (Running Average Power Limit) MSRs

**Features:**
- Per-process power consumption estimates
- Device power states (C-states, P-states)
- Power optimization suggestions
- Historical power usage logs

**Integration:**
- Weekly systemd timer (`powertop-analysis.timer`)
- Logs to `~/.logs/powertop/YYYY-MM-DD.log`
- Desktop notification with summary

---

## Alert & Notification System

### Temperature Monitoring

```
btop / sensors (continuous monitoring)
    ↓
Temperature exceeds threshold?
    ├─ CPU > 80°C  → CRITICAL
    └─ GPU > 85°C  → CRITICAL
    ↓
Custom monitoring script (systemd timer)
    ↓
notify-send (desktop notification)
    ↓
KDE Plasma Notification System
    ↓
User sees: "⚠️ CRITICAL: CPU temp 82°C"
```

**Implementation:**
- Systemd timer: `temperature-monitor.timer` (check every 30s)
- Service: `temperature-monitor.service`
- Script: Check temps via `sensors` output parsing
- Notification: `notify-send` with urgency=critical

---

## State Management

### Zellij Session Persistence

```
User closes dashboard (Ctrl+P → d)
    ↓
Zellij detaches but keeps running
    ↓
Session state saved:
    • Active pane focus
    • btop current preset
    • Pane sizes
    • Floating pane status
    ↓
User reopens (F12 or 'monitor')
    ↓
Zellij attaches to existing session
    ↓
Exact state restored
```

**Storage:** `~/.local/share/zellij/sessions/`

---

## Hardware-Specific Notes

### ASUS Z170 Pro Gaming Motherboard

**Chipset:** Intel Z170 (Skylake)
**Sensor IC:** IT8628E or Nuvoton NCT6793D
**Kernel Module:** `it87` or `nct6775`

**Fan Headers:**
- CPU_FAN (4-pin PWM)
- CHA_FAN1 (4-pin PWM)
- CHA_FAN2 (4-pin PWM)
- CHA_FAN3 (4-pin PWM)
- CHA_FAN4 (4-pin PWM)

**Limitations:**
- BIOS may lock certain PWM controls
- Some sensors may be hidden by ACPI
- Voltage readings require board-specific calibration

**Setup Required:**
```bash
sudo sensors-detect  # Auto-detect IT8628E/NCT6793D
sudo modprobe it87 force_id=0x8628  # If auto-detect fails
sensors  # Verify all sensors visible
```

---

## Integration Points

### Home Manager → Tools Installation
- `modules/cli/monitoring.nix` (to be created)
- Installs: btop, nvtop, lm-sensors, CoreCtrl, Coolero, PowerTOP
- Configures: systemd services, timers, polkit rules

### Chezmoi → Configuration Files
- `dotfiles/private_dot_config/btop/btop.conf.tmpl`
- `dotfiles/private_dot_config/btop/themes/dracula.theme`
- `dotfiles/private_dot_config/zellij/layouts/*.kdl`
- `dotfiles/private_dot_config/zellij/tutorial_tips.txt`

### Kitty → Hotkey & Auto-start
- Global F12 keybinding → toggle Zellij dashboard
- Auto-start kitty in background on login
- Zellij session resurrection on attach

---

## Security Considerations

### Fan Control Permissions

CoreCtrl requires write access to `/sys/class/hwmon/*/pwm*`.

**Options:**
1. **Polkit rules** (recommended) - Grant CoreCtrl elevated permissions
2. **udev rules** - Change sysfs file permissions at boot
3. **Setuid wrapper** (not recommended) - Security risk

**Implementation (Polkit):**
```javascript
// /etc/polkit-1/rules.d/90-corectrl.rules
polkit.addRule(function(action, subject) {
    if ((action.id == "org.corectrl.helper.init" ||
         action.id == "org.corectrl.helperkiller.init") &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("mitsio")) {
            return polkit.Result.YES;
    }
});
```

### CPU Wattage Monitoring (btop)

Reading CPU power requires `CAP_SYS_NICE` capability.

**Implementation (Systemd):**
```nix
systemd.services.btop-setcap = {
  description = "Set capabilities for btop CPU wattage";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.libcap}/bin/setcap cap_sys_nice=eip ${pkgs.btop}/bin/btop";
  };
};
```

---

## Performance Impact

### Resource Usage (Estimated)

| Component | CPU % | RAM (MB) | Notes |
|-----------|-------|----------|-------|
| btop | 1-2% | ~50 | Efficient C++ implementation |
| nvtop | 0.5-1% | ~30 | Lightweight GPU monitor |
| sensors (watch) | 0.1% | ~5 | Minimal shell command |
| Zellij | 0.2-0.5% | ~20 | Rust, very efficient |
| CoreCtrl (idle) | 0.1% | ~80 | Qt GUI, only when open |
| **Total** | **~2-4%** | **~185 MB** | Negligible impact |

### Update Frequency
- btop: 1.5 seconds
- nvtop: 1 second (default)
- sensors: 2 seconds (watch -n 2)
- Temperature monitor: 30 seconds

---

## Extensibility

### Adding New Layouts

```kdl
// ~/.config/zellij/layouts/custom.kdl
layout {
    tab name="Custom" {
        pane split_direction="vertical" {
            pane size="50%" { command "your-tool" }
            pane size="50%" { command "another-tool" }
        }
    }
}
```

Launch: `zellij --layout custom`

### Adding New Monitoring Tools

1. Install via home-manager: `modules/cli/monitoring.nix`
2. Create Zellij layout with new tool in pane
3. Update navi cheatsheet
4. Document in TOOLS.md

---

## Failure Modes & Recovery

### Zellij Session Crash
- Session state lost
- Next attach creates new session
- **Mitigation:** Zellij auto-resurrection (planned)

### Sensor Module Fails to Load
- btop/sensors show no temp data
- **Recovery:** `sudo modprobe it87 force_id=0x8628`
- **Prevention:** Add to NixOS `boot.kernelModules`

### Fan Control Stops Working
- Fans revert to BIOS defaults (usually safe)
- **Recovery:** Restart CoreCtrl, reapply profile
- **Prevention:** Systemd service to restore profile on boot

### GPU Monitoring Unavailable
- nvtop shows error: "No GPU found"
- **Cause:** NVIDIA driver not loaded
- **Recovery:** `sudo modprobe nvidia`

---

**Last Updated:** 2025-12-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
