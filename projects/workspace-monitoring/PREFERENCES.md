# Workspace Monitoring Stack - User Preferences

**Project:** workspace-monitoring
**Created:** 2025-12-29
**Source:** 4 comprehensive QnA rounds with user

---

## Overview

This document captures all user preferences gathered through structured Q&A sessions during the monitoring stack design phase. These preferences drive all implementation decisions and ensure the system matches the user's workflow and philosophy.

---

## QnA Round 1: Dashboard & Tutorial Design

### Tutorial Style
**Choice:** Floating overlay with tips (non-intrusive)

**Rationale:**
- Tips visible but don't block monitoring view
- Always available via '?' toggle
- Non-intrusive, updates based on context
- Good for learning while monitoring

**Rejected Alternatives:**
- Interactive welcome pane (too intrusive)
- Persistent sidebar (takes too much space)
- No tutorial (too minimal, unfamiliar with Zellij)

---

### Dashboard Layout
**Choice:** 3 panes - btop (large) + nvtop + sensors

**Breakdown:**
- **btop:** 60% of screen (main monitoring, primary focus)
- **nvtop:** 20% of screen (GPU process details)
- **sensors:** 20% of screen (motherboard/hardware sensors)

**Rationale:**
- Clean and focused layout
- btop remains primary (SRE workflow)
- GPU and sensors always visible (no switching)
- Not crowded, easy to scan
- Recommended configuration

**Rejected Alternatives:**
- 2 panes (too minimal, missing sensors)
- 4 panes (too crowded with logs)
- 5 panes (overwhelming, only for large displays)

---

### CoreCtrl Appearance
**Choice:** Full takeover (100% screen, focus mode)

**Rationale:**
- Fan tuning requires full attention
- No distractions when adjusting curves
- Esc returns to monitoring cleanly
- Clear single-task focus

**Rejected Alternatives:**
- Large overlay 80% (still partial distraction)
- Side panel 50% (split attention)
- Small widget 25% (too cramped for curves)

---

### Auto-start Behavior
**Choice:** Auto-start in background (always available)

**Rationale:**
- Dashboard always ready, zero launch delay
- F12 hotkey shows/hides instantly
- Runs efficiently in background
- Aligns with "always monitoring" philosophy

**Rejected Alternatives:**
- Auto-start visible (clutters desktop)
- Manual launch (extra step, slower workflow)
- Specific desktop only (too restrictive)

---

## QnA Round 2: Shortcuts & Learning

### Learning Style
**Choice:** Guided tutorial sequence (step-by-step walkthrough)

**Rationale:**
- User unfamiliar with Zellij
- Structured learning preferred
- Interactive practice before usage
- 5-minute investment for long-term efficiency

**Rejected Alternatives:**
- Progressive disclosure (too slow)
- Full cheatsheet upfront (overwhelming)
- Minimal hints (too minimal for new tool)

---

### Global Hotkey
**Choice:** F12 (consistent monitoring key)

**Rationale:**
- F12 = monitoring (semantic consistency)
- Easy to remember single key
- F12 inside dashboard = CoreCtrl (layered meaning)
- No conflicts with existing shortcuts

**Rejected Alternatives:**
- Meta+M (3-key combo, less muscle memory)
- Ctrl+Alt+M (safer but awkward)
- Custom (unnecessary complexity)

---

### Navigation Style
**Choice:** Arrow keys (Alt+arrows, intuitive)

**Rationale:**
- Immediately intuitive for new users
- Familiar from other applications
- Less learning curve than vim
- SRE work requires quick adoption

**Rejected Alternatives:**
- Vim-style hjkl (efficient but requires learning)
- Both vim+arrows (overhead, confusing)
- Mouse-first (slower, breaks flow)

---

### Tips Overlay Behavior
**Choice:** Always visible in corner (persistent reference)

**Rationale:**
- Constant reference while learning
- Small, non-intrusive location (top-right)
- Updates based on context
- User can ignore when confident

**Rejected Alternatives:**
- Auto-hide after 10s (info disappears too fast)
- Show on pane change only (miss context)
- Manual toggle only ('?' extra step)

---

## QnA Round 3: CoreCtrl & Monitoring

### Fan Curve Philosophy
**Choice:** Performance (aggressive cooling, louder)

**Rationale:**
- Prioritize cooling over noise
- Heavy workloads (compiling, k8s, VMs)
- Target CPU <60°C under load
- Fans ramp quickly for safety
- Office/home environment (noise acceptable)

**Configuration Target:**
```
Temp (°C)  →  Fan Duty %
───────────────────────
< 40       →  30%
40-50      →  40%
50-60      →  60%
60-70      →  80%
> 70       →  100% (max)
```

**Rejected Alternatives:**
- Silent priority (higher temps, work risk)
- Balanced (middle ground, insufficient for heavy loads)
- Custom per-scenario (too manual, overhead)

---

### Critical Sensors (Multi-select)
**Choice:** ALL sensors selected

1. **CPU package temp + per-core temps** ✓
   - Critical for thermal monitoring
   - Per-core reveals hotspots
   - Essential for SRE work

2. **GPU temp + VRAM temp** ✓
   - GPU workloads (containers, ML testing)
   - VRAM usage tracking
   - Graphics work

3. **Motherboard/VRM temps** ✓
   - Stability monitoring
   - VRM critical for heavy loads
   - Early warning system

4. **Fan speeds (all headers)** ✓
   - Verify fans working
   - See curve impact
   - Detect failures

**Rationale:** Comprehensive monitoring, all data visible

---

### Alert Notifications
**Choice:** Critical temps only (CPU >80°C, GPU >85°C)

**Rationale:**
- Alerts only for actionable issues
- Temperature thresholds = danger zone
- Not resource usage (visible in dashboard)
- Minimal interruption philosophy

**Thresholds:**
- CPU: >80°C = CRITICAL (thermal throttling imminent)
- GPU: >85°C = CRITICAL (GPU throttling starts)

**Rejected Alternatives:**
- Temps + resource >90% (too noisy)
- Only when hidden (misses immediate issues)
- No notifications (unsafe, no alerts)

---

### State Persistence
**Choice:** Remember focus and preset (resume where left off)

**Rationale:**
- Seamless workflow continuity
- Preserve context between sessions
- No reconfiguration needed
- Smart session management

**Preserved State:**
- Active pane focus (btop/nvtop/sensors)
- btop current preset (1-8)
- Pane sizes (if manually resized)
- Floating pane status

**Rejected Alternatives:**
- Remember focus, reset preset (inconsistent)
- Always reset (lose context)
- Random focus (chaotic, confusing)

---

## QnA Round 4: Documentation & Finalization

### Documentation Organization
**Choice:** Tutorial-style guide (step-by-step learning path)

**Rationale:**
- Structured learning journey
- Beginner-friendly narrative
- Getting Started → Basic → Advanced → Troubleshooting
- Aligns with SRE training philosophy
- Reference for future team members

**Structure:**
1. Getting Started (installation, first launch)
2. Basic Monitoring (btop, presets, navigation)
3. Advanced Features (layouts, fan control, alerts)
4. Troubleshooting (common issues, recovery)

**Rejected Alternatives:**
- Single comprehensive guide (overwhelming)
- Modular docs (harder to follow linearly)
- Quick reference cards (too minimal for learning)

---

### Alternate Layouts (Multi-select)
**Choice:** ALL 4 layouts selected

1. **SRE On-Call Layout** ✓
   - btop + system logs tail + journal follow + alert feed
   - For production monitoring
   - Emergency-ready
   - On-call workflow optimized

2. **GPU Workload Layout** ✓
   - nvtop (70%) + btop (30%)
   - ML/rendering focus
   - GPU utilization primary
   - Training/inference optimized

3. **Minimal Layout** ✓
   - btop full screen only
   - Clean, distraction-free
   - Quick reference mode
   - Demo/presentation ready

4. **Dev Work Layout** ✓
   - btop + git status + build logs
   - Development sessions
   - CI/CD monitoring
   - Build performance tracking

**Rationale:** Maximum flexibility for different workflows

---

### Navi Cheatsheets Depth
**Choice:** Complete reference (every command, every tool)

**Rationale:**
- Exhaustive reference material
- All commands documented
- All options explained
- Long-term utility
- ~50+ entries per tool
- Searchable with navi

**Coverage:**
- btop: All shortcuts, all presets, all modes
- nvtop: Navigation, sorting, filtering, GPU selection
- Zellij: All pane management, tabs, layouts, sessions
- lm-sensors: sensors commands, sensor configuration
- CoreCtrl: Profile management, fan curves, GPU tuning
- PowerTOP: Analysis commands, optimization recommendations

**Rejected Alternatives:**
- Essential commands only (incomplete reference)
- Workflow-based (harder to find specific commands)
- Minimal quick-start (too sparse)

---

### Testing Approach
**Choice:** Live testing together (guided walkthrough)

**Rationale:**
- Interactive refinement
- Immediate feedback loop
- Hands-on validation
- Real-world usage testing
- Iterate based on actual experience

**Process:**
1. Implementation checkpoint (pause for review)
2. Testing checklist provided
3. User tests each feature
4. Reports results/issues
5. Immediate iteration/fixes
6. Continue until validated

**Rejected Alternatives:**
- Automated validation (no human feedback)
- Dry-run first (slower, theoretical)
- Apply immediately without testing (risky)

---

## Additional Preferences (General Context)

### From User Profile (CLAUDE.md Global Context)

**Work Style:**
- SRE mindset (reliability, observability, automation)
- Prefers declarative configs
- FOSS preference
- Pragmatic over perfect
- Small realistic steps (depression/ADHD considerations)

**Technical Preferences:**
- Go and Python (monitoring scripts if needed)
- Avoid complex bash one-liners
- Clear, maintainable automation
- Reproducible environments
- Good observability

**Desktop Environment:**
- KDE Plasma on NixOS
- Kitty terminal (Dracula theme preference)
- Multi-workspace user
- Keyboard-driven workflows

---

## Motherboard Question (Session Context)

**Question:** Can ASUS Z170 Pro Gaming be controlled from Linux?

**Answer Provided:**
- ✅ Fan speeds: Yes (lm-sensors + CoreCtrl)
- ✅ Monitor sensors: Yes (all temps, voltages, fans)
- ✅ RGB lighting: Yes (OpenRGB if Aura Sync headers)
- ✅ CPU frequency: Yes (Linux kernel governors)
- ⚠️ Voltage control: Limited (safer in BIOS)
- ❌ BIOS updates: Not recommended from Linux
- ❌ XMP/overclocking: Must be done in BIOS

**User Clarification:** OpenRGB added to monitoring stack (optional)

---

## btop-Centric Philosophy

**User Vision:**
> "Can btop be over the complementary tools and through its TUI see the status and control fans through CoreCtrl when I need it?"

**Interpretation:**
- btop is PRIMARY control center
- Complementary tools SUPPORT btop (not replace)
- Access to CoreCtrl when needed (not always)
- TUI-first, GUI-secondary
- Integrated workflow, minimal context switching

**Implementation:**
- btop: Main pane (60%), largest focus
- nvtop/sensors: Supporting panes (20% each)
- CoreCtrl: On-demand (F12 when needed)
- Everything in ONE terminal dashboard
- Zellij orchestrates, btop dominates

---

## Summary of Philosophy

**Monitoring Approach:**
- **Comprehensive:** All sensors, all data, always visible
- **Efficient:** TUI-based, keyboard-driven, minimal overhead
- **Centralized:** One dashboard, one hotkey, one workflow
- **Pragmatic:** Performance over silence (aggressive cooling)
- **Learning-Friendly:** Guided tutorials, complete references
- **Flexible:** Multiple layouts for different scenarios
- **SRE-Oriented:** Logs, metrics, alerts, production-ready

**Key Themes:**
1. btop as primary (not equal) to other tools
2. Comprehensive over minimal (all sensors, all data)
3. Learning support (tutorials, cheatsheets, docs)
4. Performance priority (aggressive cooling, fast updates)
5. Workflow flexibility (4 alternate layouts)
6. State persistence (resume where you left off)

---

**Last Updated:** 2025-12-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
**Source:** 4 QnA rounds + user profile context + session dialogue
