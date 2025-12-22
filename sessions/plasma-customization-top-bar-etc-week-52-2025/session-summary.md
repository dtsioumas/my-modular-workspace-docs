# Plasma Customization Session - Week 52, 2025

**Date:** 2025-12-22
**Session Focus:** Activities, Virtual Desktops, Top/Bottom Bar Customization
**Status:** Planning → Implementation

---

## Session Overview

This session focuses on comprehensive KDE Plasma desktop environment customization, including:
- Creating 4 activities with specific virtual desktop layouts
- Customizing top bar with system metrics, git status, and indicators
- Customizing bottom bar with Spotify integration and cleanup
- Activity switching shortcuts
- Integration with existing chezmoi migration (Phase 4)

---

## Requirements Gathered (Q&A Rounds 1-5)

### Workflow Goals
- **Primary Goal:** Create efficient multi-tasking workflow
- **Usage Pattern:** Frequent switching (multiple times per hour)
- **Bar Style:** Information-dense + Contextual adaptation
- **Desktop Features:** All advanced features (persistent apps, quick navigation, visual names, per-desktop wallpapers)

### Current State
- **Setup:** Starting fresh or mostly from scratch
- **Existing Activities:** 3 unnamed activities (UUIDs discovered)
- **Plasma Migration:** Phase 4 in progress (chezmoi integration)

### Implementation Priority
- **Order:** Activities setup first → Desktops → Bars
- **Approach:** Hybrid (Plasma widgets + custom when needed)
- **Widget Research:** Deep research completed

---

## Defined Activity & Desktop Structure

### 1. MySpace (1st Priority Activity)
**Purpose:** Personal projects and general workspace
**Virtual Desktops:** 6 total
1. Browsing & Monitoring
2. Workspace[1]
3. Workspace[2]
4. Workspace[3]
5. Workspace[4]
6. Workspace[5]

### 2. Dissertation (2nd Priority Activity)
**Purpose:** Academic work and dissertation research/writing
**Virtual Desktops:** 5 total
1. Research & Writing
2. Workspace[1]
3. Workspace[2]
4. Workspace[3]
5. Browsing & Monitoring

### 3. Development (3rd Priority Activity)
**Purpose:** Software development and coding
**Virtual Desktops:** 4 total
1. Editor
2. Terminal
3. Browser
4. Testing

### 4. Chill (4th Priority Activity)
**Purpose:** Entertainment, media consumption, social
**Virtual Desktops:** 4 total
1. Movies
2. Music
3. Browser
4. Chat

---

## Top Bar Requirements

### System Metrics Widgets
**Requirements:** CPU, RAM, GPU (NVIDIA), Disk I/O, Network activity
**Display Style:** Information-dense + Contextual

**Recommended Widgets:**
- **Native System Monitor Sensor** (multiple instances) for:
  - CPU usage (%)
  - RAM usage (%)
  - Network (upload/download - 2 separate widgets)
  - Disk I/O (read/write)
- **Thermal Monitor** for temperatures:
  - CPU temps
  - GPU temps (NVIDIA via ksystemstats)
- **NVIDIA GPU Usage:** Custom nvidia-smi integration (Command Output widget or custom solution)

**Research Confidence:** 0.85 (High)

### Git Repository Status
**Requirements:**
- Context-aware per activity
- Monitor repos under `~/.MyHome/MySpaces/`
- Visual indicators for uncommitted changes, branch info

**Solution:**
- **No existing widget found**
- **Options:**
  1. Custom QML widget development (Medium-High effort)
  2. Command Output widget + custom script (Lower effort)
  3. Short-term: Dolphin git integration + enhanced bash prompt

**Research Confidence:** 0.45-0.65 (Low-Medium - requires custom development)

**Decision Pending:** Evaluate priority vs effort

### Power Mode Indicator
**Requirements:** Show current power profile, manual control visible

**Recommended Widget:**
- **Native Battery & Brightness applet** (built-in)
- Shows power profile with icon badges
- Performance/Balanced/Power Saver modes
- Real-time updates

**Research Confidence:** 0.90 (Very High)

### Desktop & Activity Indicators
**Requirements:** Show current desktop name/number and activity name

**Recommended Widgets:**
- **Virtual Desktop Pager** (built-in) - configure for desktop names display
- **Activity Pager** (built-in) - shows activity names

**Alternative:** Command Output widgets with qdbus queries if pagers too large

**Research Confidence:** 0.85 (High)

---

## Bottom Bar Requirements

### Spotify Integration
**Requirements:**
- Now playing display
- Standard playback controls
- Volume control
- Compact/expandable design

**Recommended Widget:**
- **PlasMusic Toolbar** ⭐
  - Compact panel display
  - Expandable full view with volume/progress
  - Plasma 6 native
  - MPRIS2 (works with Spotify)

**Installation:** KDE Store or GitHub manual installation
**Research Confidence:** 0.85 (High)

### Bottom Bar Cleanup
**Remove:**
- Application menu widget
- Default clipboard manager (keep copyq system-wide)
- Spectacle widget (keep flameshot system-wide)
- Peek desktop widget

**Keep:**
- Task Manager (IconTasks)
- System Tray
- Digital Clock

---

## Activity Switching Configuration

**Shortcut:** Meta+Shift+Arrows
**Behavior:** Cycle through all activities in order
- Meta+Shift+Right: MySpace → Dissertation → Development → Chill → MySpace
- Meta+Shift+Left: Reverse order

**Configuration Method:** kglobalshortcutsrc (already in chezmoi via Phase 3)

---

## Desktop Switching & Navigation

**Requirements:**
- Quick keyboard navigation between virtual desktops
- Persistent app placement per desktop
- Desktop-specific wallpapers
- Visual desktop names/indicators

**Configuration Files:**
- `kwinrc` - virtual desktop configuration
- `kactivitymanagerdrc` - activity settings
- `plasma-org.kde.plasma.desktop-appletsrc` - wallpapers and widgets

---

## Integration with Existing Chezmoi Migration

**Current Plasma-Chezmoi Status (from ADR and plans):**
- **Phase 4 IN PROGRESS**
- Core configs already migrated:
  - ✅ `kglobalshortcutsrc` (shortcuts)
  - ✅ `kwinrc` (window manager)
  - ✅ `plasmarc` (theme)
  - ✅ `kxkbrc` (keyboard layouts)
  - ✅ `plasmashellrc` (panels)
  - ✅ `plasma-org.kde.plasma.desktop-appletsrc` (widgets)
  - ✅ `powerdevilrc`, `kscreenlockerrc`, `krunnerrc`, etc.

**Templating System:**
- `.chezmoidata/plasma.yaml` for host-specific data
- `.tmpl` files for configs needing templating
- `chezmoi_modify_manager` for volatile sections
- Ansible automation: `chezmoi-modify-refresh.yml`

**Our Changes Must:**
1. Follow existing templating patterns
2. Update `.chezmoidata/plasma.yaml` with new activity/desktop data
3. Use modify scripts for volatile configs
4. Document in `docs/dotfiles/plasma/` directory
5. Update automation playbooks if needed

---

## Widget Research Summary

**Research Completed:** 2025-12-22 (Agent a43b462)
**Thoroughness:** Very thorough
**Confidence:** 0.75 overall

### Key Findings:
- ✅ Native Plasma widgets can handle most requirements
- ⚠️ NVIDIA GPU monitoring challenging (known compatibility issues)
- ⚠️ Git status widget requires custom development
- ❌ External bars (Polybar, Waybar) NOT recommended - lose Plasma integration
- ✅ All solutions compatible with Plasma 6 and chezmoi

### Widget Recommendations Summary:

| Requirement | Solution | Type | Confidence |
|------------|----------|------|------------|
| CPU/RAM/Network/Disk | System Monitor Sensor | Native | 0.85 |
| Temperatures | Thermal Monitor | KDE Store | 0.80 |
| NVIDIA GPU | nvidia-smi + Custom | Custom | 0.60 |
| Power Mode | Battery & Brightness | Native | 0.90 |
| Desktop Indicator | Virtual Desktop Pager | Native | 0.85 |
| Activity Indicator | Activity Pager | Native | 0.80 |
| Spotify | PlasMusic Toolbar | KDE Store | 0.85 |
| Git Status | Custom QML Widget | Custom | 0.45 |

---

## Next Steps & Implementation Plan

### Phase 1: Activities & Desktops Setup
1. Query existing activities and their UUIDs
2. Create/rename activities in correct order
3. Configure virtual desktops per activity
4. Set desktop names
5. Test activity/desktop switching

### Phase 2: Top Bar Configuration
1. Install Thermal Monitor widget
2. Configure System Monitor Sensor widgets (CPU, RAM, Network, Disk)
3. Set up NVIDIA GPU monitoring
4. Add/configure Battery & Brightness applet
5. Add Virtual Desktop Pager
6. Add Activity Pager (or custom indicator)
7. Position and test all widgets

### Phase 3: Bottom Bar Cleanup & Spotify
1. Install PlasMusic Toolbar
2. Remove unwanted widgets (app menu, clipboard, spectacle, peek desktop)
3. Configure PlasMusic Toolbar settings
4. Test Spotify MPRIS integration

### Phase 4: Git Status Widget
1. Evaluate priority vs development effort
2. If HIGH priority: Develop custom QML widget
3. If MEDIUM priority: Use Command Output + script
4. If LOW priority: Rely on Dolphin integration + bash prompt

### Phase 5: Persistent Apps & Wallpapers
1. Configure window rules for persistent app placement
2. Set per-desktop wallpapers (integrate with chezmoi plasma.yaml)
3. Test window placement across activities

### Phase 6: Chezmoi Integration
1. Update `.chezmoidata/plasma.yaml` with activity/desktop data
2. Create/update templates for new configs
3. Run `chezmoi-modify-refresh.yml` playbook
4. Test `chezmoi diff` and `chezmoi apply`
5. Document changes in `docs/dotfiles/plasma/`

### Phase 7: Testing & Documentation
1. Full system reboot test
2. Activity switching stress test
3. Desktop switching verification
4. Widget functionality validation
5. Document final configuration
6. Create troubleshooting guide

---

## Files & Paths

### Configuration Files (Plasma):
- `~/.config/kwinrc` - window manager, virtual desktops
- `~/.config/kactivitymanagerdrc` - activity settings
- `~/.config/kglobalshortcutsrc` - keyboard shortcuts
- `~/.config/plasmashellrc` - panel configuration
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` - widgets, wallpapers
- `~/.local/share/kactivitymanagerd/` - activity data

### Chezmoi Files:
- `~/.local/share/chezmoi/.chezmoidata/plasma.yaml` - host-specific data
- `~/.local/share/chezmoi/private_dot_config/` - templated configs
- `~/.local/share/chezmoi/modify_*` scripts - modify manager hooks

### Documentation:
- `docs/sessions/plasma-customization-top-bar-etc-week-52-2025/` - this session
- `docs/dotfiles/plasma/` - Plasma configuration docs
- `docs/plans/2025-12-14-plasma-migration-to-chezmoi-plan.md` - migration plan
- `docs/plans/2025-12-19-plasma-templating-and-automation-design.md` - templating design

### Automation:
- `ansible/playbooks/chezmoi-modify-refresh.yml` - config refresh automation
- `Makefile` targets for plasma operations

---

## Tools & Commands

### Activity Management:
```bash
# List activities
qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities

# Get activity info
qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName <UUID>

# Set activity name
qdbus org.kde.ActivityManager /ActivityManager/Activities SetActivityName <UUID> "Name"

# Create new activity
qdbus org.kde.ActivityManager /ActivityManager/Activities AddActivity "Name"

# Set current activity
qdbus org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity <UUID>
```

### Desktop Management:
```bash
# Get desktop count
qdbus org.kde.KWin /KWin org.kde.KWin.numberOfDesktops

# Set desktop count (per activity via kwinrc)
# Edit ~/.config/kwinrc [Desktops] section

# Get current desktop
qdbus org.kde.KWin /KWin currentDesktop

# Switch desktop
qdbus org.kde.KWin /KWin setCurrentDesktop <number>
```

### Widget Installation:
```bash
# Install widget from archive
kpackagetool6 -i widget.plasmoid

# Update widget
kpackagetool6 -u widget.plasmoid

# List installed widgets
kpackagetool6 --type Plasma/Applet --list

# Remove widget
kpackagetool6 -r org.kde.plasma.widget-name
```

### Plasma Restart:
```bash
# Restart plasmashell (soft)
kquitapp6 plasmashell && kstart plasmashell

# Reload plasmashell with replacement
plasmashell --replace &
```

### Chezmoi Operations:
```bash
# Refresh Plasma configs
cd ~/.MyHome/MySpaces/my-modular-workspace
make plasma-refresh  # or ansible-playbook ansible/playbooks/chezmoi-modify-refresh.yml

# Check differences
chezmoi diff ~/.config/plasma*

# Apply configs
chezmoi apply

# Re-add after manual GUI changes
chezmoi re-add ~/.config/kwinrc
```

---

## Risks & Mitigations

### Risk: Breaking Desktop Functionality
**Mitigation:**
- Create backup before changes: `cp -r ~/.config ~/.config.backup-$(date +%Y%m%d)`
- Test in phases
- Know rollback commands

### Risk: Activity/Desktop Config Conflicts
**Mitigation:**
- Work with qdbus commands first (non-destructive queries)
- Understand existing activity UUIDs before renaming
- Keep activity data backed up

### Risk: Widget Installation Failures
**Mitigation:**
- Check Plasma 6 compatibility before installation
- Prefer KDE Store installations over manual
- Test widgets individually

### Risk: Chezmoi Merge Conflicts
**Mitigation:**
- Run `chezmoi diff` before and after changes
- Understand modify_manager filter rules
- Document changes in session notes

### Risk: NVIDIA GPU Monitoring Not Working
**Mitigation:**
- Accept this as low-priority "nice to have"
- Have fallback plan (external monitor like nvidia-smi in terminal)
- Don't spend excessive time troubleshooting

---

## Success Criteria

### Must Have (Critical):
- ✅ 4 activities created and ordered correctly
- ✅ All virtual desktops configured with correct names
- ✅ Activity switching works with Meta+Shift+Arrows
- ✅ Desktop switching works smoothly
- ✅ Top bar shows CPU, RAM, Network metrics
- ✅ Bottom bar has Spotify widget working
- ✅ Unwanted widgets removed from bottom bar
- ✅ All changes integrated with chezmoi

### Should Have (Important):
- ✅ Power mode indicator visible
- ✅ Desktop/Activity names visible in bar
- ✅ Thermal monitoring working
- ✅ Persistent app placement configured
- ✅ Per-desktop wallpapers set

### Nice to Have (Optional):
- NVIDIA GPU monitoring working
- Git status widget implemented
- Disk I/O monitoring detailed
- Custom widget development completed

---

## Questions & Decisions Log

### Q1: Primary goal for Plasma configuration?
**A:** Create efficient multi-tasking workflow

### Q2: Usage pattern?
**A:** Frequent switching (multiple times per hour)

### Q3: Bar style preference?
**A:** Information-dense + Contextual (hybrid of options 2 & 3)

### Q4: Important desktop features?
**A:** All - persistent apps, quick navigation, visual names, per-desktop wallpapers

### Q5: Current setup state?
**A:** Starting fresh or mostly from scratch

### Q6: Fourth activity type?
**A:** Development/Coding focused

### Q7: Top bar implementation?
**A:** Hybrid approach (Plasma + custom when needed)

### Q8: Git monitoring scope?
**A:** Per-activity configuration + context-aware repos

### Q9: System metrics priority?
**A:** All metrics (CPU, RAM, GPU, Network, Disk I/O) + Spotify integration

### Q10: Activity switching behavior?
**A:** Cycle through all activities in order

### Q11: Activity names?
**A:** MySpace | Dissertation | Development | Chill

### Q12: Spotify widget style?
**A:** Standard controls + Compact expandable (hybrid)

### Q13: Desktop naming?
**A:** Yes, specific custom names per activity

### Q14: Widget technology preference?
**A:** Mix of both (existing + custom when necessary)

### Q15: Implementation priority?
**A:** Activities setup first, then desktops, then bars

### Q16: Power management?
**A:** Manual control, just show current mode in bar

### Q17: Widget research depth?
**A:** Spawn research agent for best widgets (completed)

### Q18: Development activity desktops?
**A:** 4 desktops (compact): Editor, Terminal, Browser, Testing

### Q19: Chill activity desktops?
**A:** 4 desktops: Movies, Music, Browser, Chat

---

## Research References

- Research Agent ID: a43b462 (can be resumed for follow-up research)
- Research Confidence: 0.75 overall
- Research Date: 2025-12-22
- Research Scope: KDE Store, GitHub, community forums, documentation

Key widget sources:
- [Thermal Monitor](https://store.kde.org/p/2100418)
- [PlasMusic Toolbar](https://github.com/ccatterina/plasmusic-toolbar)
- [KDE Plasma Development Docs](https://develop.kde.org/docs/plasma/)

---

## Session Notes

### Session Start: 2025-12-22
**Context:** User requested comprehensive Plasma customization with 5 Q&A rounds to understand requirements

### Key Realizations:
1. User already has advanced Plasma-to-chezmoi migration in Phase 4
2. Must integrate with existing templating system
3. Git status widget is unique requirement without existing solution
4. NVIDIA GPU monitoring has known compatibility challenges
5. Native Plasma widgets can handle most requirements

### Technical Challenges Identified:
1. NVIDIA GPU monitoring (known bugs in ksystemstats)
2. Git status widget development (no existing solution)
3. Context-aware git monitoring per activity
4. Chezmoi integration with volatile Plasma configs

### User Preferences Noted:
- Power user who switches contexts frequently
- Values efficiency and multi-tasking
- Wants information density but also clean aesthetics
- Prefers native solutions when available
- Open to custom development when necessary
- Already invested in chezmoi migration (good foundation)

---

**Status:** Planning complete, ready for implementation
**Next Action:** Begin Phase 1 - Activities & Desktops Setup
**Estimated Time:** 4-6 hours total implementation (across phases)
