# Workspace Monitoring Stack

**Project:** Comprehensive System Monitoring for shoshin Desktop
**Created:** 2025-12-29
**Status:** Phase 1 Complete - Implementation In Progress
**Owner:** Dimitris Tsioumas (Mitsio)

---

## Overview

A comprehensive, btop-centric monitoring solution with Zellij dashboard integration, providing real-time system monitoring, GPU tracking, hardware sensor visibility, and fan control for the shoshin workspace (ASUS Z170 Pro Gaming + AMD Ryzen 8-core + NVIDIA GPU).

**Philosophy:** btop as the primary control center with complementary tools accessible through an integrated Zellij dashboard, combining TUI efficiency with comprehensive hardware monitoring.

---

## Quick Start

```bash
# Launch monitoring dashboard
monitor          # or: zellij --layout monitoring

# Navigate dashboard
Alt+Arrow keys   # Move between panes
P (in btop)      # Cycle presets (1-8)
F12              # Open CoreCtrl for fan control

# Quick monitoring
gpu              # Launch nvtop (GPU processes)
sensors          # View all hardware sensors
btop             # Full-screen btop
```

---

## Project Structure

```
docs/projects/workspace-monitoring/
├── README.md                    # This file (overview)
├── ARCHITECTURE.md              # System architecture & design
├── PREFERENCES.md               # User preferences from QnA sessions
├── IMPLEMENTATION_STATUS.md     # What's done, what's pending
├── TOOLS.md                     # Tool-by-tool reference
└── ZELLIJ_LAYOUTS.md           # Dashboard layouts design
```

---

## Key Features

### btop Enhancement
- **8 monitoring presets** for different scenarios
- **Dracula theme** for excellent readability
- **Comprehensive sensors:** CPU temps (per-core), GPU, motherboard, fans
- **Memory-first sorting** (SRE preference)
- **Disk filtering** (exclude boot partitions)
- **GPU integration** (usage, temp, VRAM)

### Zellij Dashboard
- **3-pane main layout:** btop (60%) + nvtop (20%) + sensors (20%)
- **4 alternate layouts:** Dev, SRE On-Call, GPU Workload, Minimal
- **Guided tutorial system** with floating tips overlay
- **Arrow key navigation** (Alt+arrows)
- **F12 global hotkey** for show/hide
- **Auto-start in background**
- **State persistence** (remembers focus and presets)

### Hardware Monitoring
- **CPU:** Package temp, per-core temps, frequency, power consumption (watts)
- **GPU:** Usage, temp, VRAM, clocks, PCIe throughput (NVIDIA)
- **Motherboard:** VRM temps, chipset temp, all voltages
- **Fans:** All fan headers (CPU_FAN, CHA_FAN1-4) with RPM monitoring
- **Disks:** I/O stats, usage, SMART data

### Fan Control
- **CoreCtrl** (primary) + **Coolero** (alternative)
- **Performance fan curves** (aggressive cooling, CPU <60°C target)
- **GUI integration** via F12 hotkey (full-screen takeover in Zellij)
- **Multiple profiles** available

### Alerts & Notifications
- **Critical temperature alerts:** CPU >80°C, GPU >85°C
- **Desktop notifications** with actionable information
- **Weekly PowerTOP analysis** for power optimization

---

## Tools in Stack

| Tool | Purpose | Access | Status |
|------|---------|--------|--------|
| **btop** | Primary system monitor | `btop` / main pane | ✅ Configured |
| **nvtop** | GPU process monitoring | `gpu` alias / pane | ⏳ Pending install |
| **lm-sensors** | Hardware sensors detail | `sensors` / pane | ⏳ Pending config |
| **CoreCtrl** | Fan control GUI | F12 hotkey | ⏳ Pending install |
| **Coolero** | Alt fan control GUI | Manual launch | ⏳ Pending install |
| **PowerTOP** | Power consumption analysis | Weekly timer | ⏳ Pending setup |
| **Zellij** | Dashboard/multiplexer | `monitor` alias | ✅ Configured |

---

## Architecture Highlights

### Monitoring Flow
```
┌─────────────────────────────────────────────┐
│  F12 Global Hotkey → Show/Hide Dashboard   │
└─────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│          Zellij Monitoring Dashboard        │
├─────────────────────────────────────────────┤
│  ┌───────────────────────────────────────┐  │
│  │         btop (Main - 60%)             │  │
│  │  • 8 presets (P to cycle, 0-9 jump)  │  │
│  │  • CPU, RAM, Net, Disk, GPU           │  │
│  │  • Processes (sorted by memory)       │  │
│  └───────────────────────────────────────┘  │
│  ┌──────────────┬────────────────────────┐  │
│  │ nvtop (20%)  │  sensors (20%)         │  │
│  │ GPU details  │  Motherboard sensors   │  │
│  └──────────────┴────────────────────────┘  │
│  ┌─────────────────────────────────────┐    │
│  │ Tutorial Tips (floating, top-right) │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
                      ↓
            F12 (in dashboard)
                      ↓
┌─────────────────────────────────────────────┐
│     CoreCtrl (Full Screen Fan Control)      │
│  • Adjust fan curves                        │
│  • Performance profile active               │
│  • Esc to return to dashboard               │
└─────────────────────────────────────────────┘
```

### Hardware Monitoring (ASUS Z170 Pro Gaming)
- **Sensor chip:** IT8628E or Nuvoton NCT6793D (auto-detected)
- **Fan headers:** CPU_FAN, CHA_FAN1, CHA_FAN2, CHA_FAN3, CHA_FAN4
- **Temp sensors:** CPU package, per-core, motherboard, VRM, GPU
- **Power monitoring:** CPU watts (via RAPL), GPU watts (via NVML)

---

## Implementation Status

**Phase 1: Configuration Complete ✅**
- btop enhanced configuration (8 presets, Dracula theme)
- Dracula theme file created
- Main Zellij layout (3 panes)
- Tutorial tips system
- All committed to dotfiles repo

**Phase 2: Tool Installation Pending ⏳**
- Home-manager monitoring module
- nvtop, CoreCtrl, Coolero, PowerTOP, lm-sensors installation
- Shell aliases (gpu, monitor)
- btop setcap service (CPU wattage)

**Phase 3: Advanced Features Pending ⏳**
- 4 alternate Zellij layouts
- F12 hotkey configuration
- Auto-start setup
- CoreCtrl fan curve profiles
- Temperature notifications
- PowerTOP weekly timer
- lm-sensors ASUS Z170 config

**Phase 4: Documentation & Testing Pending ⏳**
- Comprehensive navi cheatsheets
- Tutorial-style learning guide
- Live testing validation

See [IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md) for detailed tracking.

---

## User Preferences

All monitoring preferences were gathered through 4 comprehensive QnA rounds:

- **btop theme:** Dracula (purple/pink dark theme)
- **Process sorting:** Memory (RAM usage priority)
- **Disk filtering:** Main storage only (exclude /boot, /boot/efi)
- **Fan philosophy:** Performance (aggressive cooling, <60°C target)
- **Navigation:** Arrow keys (Alt+arrows, not vim-style)
- **Learning:** Guided tutorial sequence with persistent tips
- **Layouts:** 4 alternate layouts for different workflows
- **Cheatsheets:** Complete reference (exhaustive, all tools)
- **Documentation:** Tutorial-style learning path

See [PREFERENCES.md](./PREFERENCES.md) for complete details.

---

## Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System design, component interactions, data flow
- **[PREFERENCES.md](./PREFERENCES.md)** - All user preferences from QnA sessions
- **[IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md)** - Current status, roadmap, testing plan
- **[TOOLS.md](./TOOLS.md)** - Tool-by-tool reference guide
- **[ZELLIJ_LAYOUTS.md](./ZELLIJ_LAYOUTS.md)** - All dashboard layouts explained

---

## Related Sessions

- **Session Summary:** `sessions/summaries/2025-12-30_WORKSPACE_MONITORING_SETUP.md`
- **Research Output:** Comprehensive btop++ research by general-purpose agent

---

## Next Steps

1. **Install monitoring tools** via home-manager
2. **Configure lm-sensors** for ASUS Z170 Pro Gaming
3. **Setup CoreCtrl** with performance fan curves
4. **Create alternate layouts** (Dev, SRE, GPU, Minimal)
5. **Configure F12 hotkey** and auto-start
6. **Write navi cheatsheets** (all tools, complete reference)
7. **Create tutorial guide** (step-by-step learning path)
8. **Live testing** with guided validation

---

**Last Updated:** 2025-12-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
**Working Directory:** `/home/mitsio/.MyHome/MySpaces/my-modular-workspace`
