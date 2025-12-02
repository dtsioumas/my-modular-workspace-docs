# Kitty Advanced Status Bar - Comprehensive Implementation Plan

**Created:** 2025-12-01 23:25
**Author:** Dimitris Tsioumas (Mitsio)
**Status:** PLANNING - Ready for Implementation
**Research Confidence:** 0.87 (High - Band C)
**Estimated Total Time:** 6-8 hours

---

## 📋 Executive Summary

This plan documents the comprehensive implementation of an advanced status bar for kitty terminal using custom Python `tab_bar.py` scripting. The status bar will display real-time system metrics, K8s context, git information, and various operational data critical for SRE/DevOps workflows.

**Research Finding:** Kitty has **native support** for custom tab bar implementation via Python scripting with excellent performance and flexibility.

---

## 🎯 User Requirements & Preferences

### Primary Requirements

**Status Bar Metrics (Left to Right Layout):**

1. **Tab Information**
   - Tab number (current tab index)
   - Tab title (truncated to 25 chars)
   - Window count in tab (if multiple windows)
   - Layout name (current kitty layout)

2. **Git Information**
   - Current git branch (if in git repo)
   - Branch status indicators (ahead/behind - optional Phase 2)

3. **System Metrics**
   - **CPU Usage** - Percentage (0-100%)
     - Refresh: Every 3 seconds
     - Color: Green (<50%), Yellow (50-80%), Red (>80%)
   - **RAM Usage** - Available GB or percentage
     - Refresh: Every 5 seconds
     - Color: Green (>50% available), Yellow (20-50%), Red (<20%)
   - **Disk Usage (Root)** - Percentage used for `/`
     - Refresh: Every 10 seconds
     - Color: Green (<70%), Yellow (70-85%), Red (>85%)
   - **Disk Usage (Backups)** - Percentage used for `/backups/`
     - Refresh: Every 10 seconds
     - Color: Same as root disk

4. **Network Statistics**
   - Upload speed (MB/s or KB/s)
   - Download speed (MB/s or KB/s)
   - Refresh: Every 3 seconds
   - Format: ↑2MB/s ↓5MB/s

5. **K8s & Container Info**
   - **K8s Context** - Current kubectl context ⭐ CRITICAL
     - Alert: Yellow background + ⚠️ symbol for "prod" context
     - Refresh: Every 5 seconds (cached)
   - **Container Count** - Running Docker/Podman containers
     - Format: 🐳 3
     - Refresh: Every 5 seconds

6. **Time**
   - Current time in HH:MM format
   - Refresh: Every 60 seconds

### User Preferences

**Visual Preferences:**
- Theme: Dracula (vibrant colors)
- Transparency: 0.15 (85% transparent)
- Separators: Use `|` or powerline symbols
- Colors: Dracula palette with status indicators (green/yellow/red)

**Performance Preferences:**
- Differentiated refresh rates for different metrics
- Avoid blocking operations
- Use subprocess for external commands
- Cache results to minimize system calls

**Clickability:**
- **Phase 1:** No clickability (keyboard-driven workflow)
- **Meta Phases:** Add clickability when status bar is stable
- Acceptable limitation for initial implementation

**Priority Order:**
1. K8s context (CRITICAL for SRE safety)
2. Time and tab info (always useful)
3. CPU, RAM, Disk (performance monitoring)
4. Network and containers (optional but valuable)
5. Git branch (nice to have)

---

## 🔧 Technical Implementation Details

### Architecture Overview

**Components:**

1. **`~/.config/kitty/tab_bar.py`** - Main custom tab bar script
2. **Helper Functions** - System metric collection functions
3. **Cache System** - Store metric values with timestamps
4. **Refresh Timers** - Multiple timers for different refresh rates
5. **Color Mapping** - Dynamic color selection based on thresholds

### File Structure

```
~/.config/kitty/
├── kitty.conf                  # Main config with tab_bar_style custom
├── tab_bar.py                  # Main status bar script
├── current-theme.conf          # Dracula theme colors
└── kittens/
    └── export_history.py       # History export kitten (Phase 2)
```

### Refresh Rate Implementation

**Multiple Timer Strategy:**

```python
# Global cache structure
metrics_cache = {
    'cpu': {'value': 0, 'updated': 0, 'interval': 3},
    'ram': {'value': 0, 'updated': 0, 'interval': 5},
    'disk_root': {'value': 0, 'updated': 0, 'interval': 10},
    'disk_backups': {'value': 0, 'updated': 0, 'interval': 10},
    'network': {'up': 0, 'down': 0, 'updated': 0, 'interval': 3},
    'k8s': {'context': '', 'updated': 0, 'interval': 5},
    'containers': {'count': 0, 'updated': 0, 'interval': 5},
    'time': {'value': '', 'updated': 0, 'interval': 60}
}

def should_update(metric_name):
    """Check if metric needs refresh based on interval"""
    now = time.time()
    cache = metrics_cache[metric_name]
    return (now - cache['updated']) >= cache['interval']
```

### Metric Collection Functions

**CPU Usage:**
```python
def get_cpu_usage():
    """Read CPU stats from /proc/stat"""
    try:
        with open("/proc/stat", "r") as f:
            line = f.readline()
            # Parse and calculate CPU percentage
            # Implementation details in Phase 1
        return cpu_percent
    except:
        return 0
```

**RAM Usage:**
```python
def get_ram_usage():
    """Read RAM stats from /proc/meminfo"""
    try:
        with open("/proc/meminfo", "r") as f:
            # Parse MemTotal, MemAvailable
            # Calculate available GB or percentage
        return f"{available_gb:.1f}GB"
    except:
        return "N/A"
```

**Disk Usage:**
```python
import subprocess

def get_disk_usage(path):
    """Get disk usage for path using df"""
    try:
        result = subprocess.run(
            ["df", "-h", path],
            capture_output=True,
            text=True,
            timeout=1
        )
        # Parse df output for percentage
        return percentage
    except:
        return 0
```

**K8s Context:**
```python
def get_k8s_context():
    """Get current kubectl context"""
    try:
        result = subprocess.run(
            ["kubectl", "config", "current-context"],
            capture_output=True,
            text=True,
            timeout=1
        )
        context = result.stdout.strip()
        return context
    except:
        return ""

def is_prod_context(context):
    """Check if context is production"""
    prod_keywords = ["prod", "production", "prd"]
    return any(kw in context.lower() for kw in prod_keywords)
```

**Network Stats:**
```python
def get_network_stats():
    """Get network upload/download speeds"""
    try:
        with open("/proc/net/dev", "r") as f:
            # Parse network interface stats
            # Calculate delta from previous read
            # Return formatted up/down speeds
        return f"↑{up_speed} ↓{down_speed}"
    except:
        return "↑0 ↓0"
```

### Color Coding System

**Dracula Theme Colors:**
```python
# From current-theme.conf
COLORS = {
    'green': '#50fa7b',    # color2 - Good status
    'yellow': '#f1fa8c',   # color3 - Warning status
    'red': '#ff5555',      # color1 - Critical status
    'cyan': '#8be9fd',     # color6 - Info
    'purple': '#bd93f9',   # color4 - Accent
    'pink': '#ff79c6',     # color5 - Highlight
    'foreground': '#f8f8f2',
    'background': '#282a36',
}

def get_status_color(value, thresholds):
    """Return color based on value and thresholds"""
    if value < thresholds['good']:
        return COLORS['green']
    elif value < thresholds['warning']:
        return COLORS['yellow']
    else:
        return COLORS['red']
```

**Threshold Configuration:**
```python
THRESHOLDS = {
    'cpu': {'good': 50, 'warning': 80},
    'ram': {'good': 50, 'warning': 20},  # Inverted: more available = good
    'disk': {'good': 70, 'warning': 85},
}
```

---

## 📐 Implementation Phases

### Phase 1: Setup & Basic Structure (45 mins)

**Goals:**
- Create `tab_bar.py` file
- Configure kitty.conf for custom tab bar
- Implement basic drawing structure
- Test with static content

**Tasks:**
1. Create `~/.config/kitty/tab_bar.py`
2. Add to `kitty.conf`:
   ```conf
   tab_bar_style custom
   tab_bar_edge bottom
   tab_separator ""
   tab_bar_min_tabs 1
   ```
3. Implement basic `draw_tab()` function
4. Add timer for refresh
5. Test with placeholder text

**Success Criteria:**
- Tab bar appears at bottom
- Tabs render correctly
- Placeholder text visible on right side
- No errors on reload (`Ctrl+Shift+F5`)

---

### Phase 2: System Metrics (1.5 hours)

**Goals:**
- Implement CPU, RAM, Disk monitoring
- Add color coding
- Implement differentiated refresh rates
- Test performance

**Tasks:**

**2.1 CPU Monitoring (20 mins)**
- [ ] Create `get_cpu_usage()` function
- [ ] Read `/proc/stat`
- [ ] Calculate percentage
- [ ] Add to cache with 3s refresh
- [ ] Color code: green/yellow/red
- [ ] Test accuracy with `top`

**2.2 RAM Monitoring (20 mins)**
- [ ] Create `get_ram_usage()` function
- [ ] Read `/proc/meminfo`
- [ ] Calculate available GB
- [ ] Add to cache with 5s refresh
- [ ] Color code based on availability
- [ ] Test accuracy with `free -h`

**2.3 Disk Monitoring (30 mins)**
- [ ] Create `get_disk_usage(path)` function
- [ ] Use subprocess for `df` command
- [ ] Monitor `/` (root)
- [ ] Monitor `/backups/` (backups disk)
- [ ] Add to cache with 10s refresh
- [ ] Color code: green/yellow/red
- [ ] Test with `df -h`
- [ ] Handle errors if `/backups/` not mounted

**2.4 Performance Testing (20 mins)**
- [ ] Verify refresh rates work correctly
- [ ] Check CPU impact of tab_bar.py
- [ ] Ensure no UI lag
- [ ] Test with multiple tabs open
- [ ] Optimize if needed

**Success Criteria:**
- All metrics display correctly
- Refresh rates work as specified
- Colors change based on thresholds
- No performance degradation
- Handles missing data gracefully

---

### Phase 3: K8s & Container Metrics (1 hour)

**Goals:**
- Add K8s context display
- Add container count
- Implement prod alert
- Add error handling

**Tasks:**

**3.1 K8s Context (30 mins)**
- [ ] Create `get_k8s_context()` function
- [ ] Use subprocess for `kubectl config current-context`
- [ ] Cache with 5s refresh
- [ ] Detect prod context (keywords: prod, production, prd)
- [ ] Apply yellow background + ⚠️ for prod
- [ ] Handle kubectl not installed
- [ ] Handle no context set
- [ ] Test with different contexts

**3.2 Container Count (30 mins)**
- [ ] Create `get_container_count()` function
- [ ] Try Docker: `docker ps -q | wc -l`
- [ ] Try Podman: `podman ps -q | wc -l`
- [ ] Cache with 5s refresh
- [ ] Format: 🐳 3
- [ ] Handle neither installed
- [ ] Handle permission errors
- [ ] Test accuracy with `docker ps`

**Success Criteria:**
- K8s context displays correctly
- Prod context shows yellow + warning
- Container count accurate
- Handles missing tools gracefully
- No blocking operations

---

### Phase 4: Network, Git, Time (1 hour)

**Goals:**
- Add network statistics
- Add git branch detection
- Add current time
- Add layout and tab info

**Tasks:**

**4.1 Network Stats (30 mins)**
- [ ] Create `get_network_stats()` function
- [ ] Read `/proc/net/dev`
- [ ] Detect active interface (eth0, wlan0, etc.)
- [ ] Calculate upload/download speeds
- [ ] Cache with 3s refresh
- [ ] Format: ↑2MB/s ↓5MB/s
- [ ] Handle no active interface
- [ ] Test accuracy

**4.2 Git Branch (15 mins)**
- [ ] Use `tab.active_wd` to get current directory
- [ ] Check if directory is git repo
- [ ] Run `git branch --show-current`
- [ ] Cache per tab (doesn't change often)
- [ ] Handle non-git directories
- [ ] Format: main, feature/xyz

**4.3 Time & Info (15 mins)**
- [ ] Get current time: `datetime.now().strftime("%H:%M")`
- [ ] Cache with 60s refresh
- [ ] Get layout name from tab bar API
- [ ] Get tab number from index parameter
- [ ] Format nicely

**Success Criteria:**
- Network speeds display correctly
- Git branch shows in git repos
- Time updates every minute
- Layout and tab info accurate

---

### Phase 5: Visual Polish & Optimization (1 hour)

**Goals:**
- Refine layout and spacing
- Optimize colors for readability
- Add separators
- Improve performance
- Handle edge cases

**Tasks:**

**5.1 Visual Layout (30 mins)**
- [ ] Add separators between metrics (|)
- [ ] Ensure proper spacing
- [ ] Test with different terminal widths
- [ ] Handle long metric values
- [ ] Truncate if necessary
- [ ] Test with transparency

**5.2 Color Optimization (15 mins)**
- [ ] Verify colors with Dracula theme
- [ ] Ensure readability with transparency
- [ ] Test different metric states
- [ ] Adjust brightness if needed

**5.3 Performance Optimization (15 mins)**
- [ ] Profile tab_bar.py execution time
- [ ] Minimize subprocess calls
- [ ] Optimize cache checks
- [ ] Remove debug code
- [ ] Test with all metrics active

**Success Criteria:**
- Visually appealing layout
- Easy to read at a glance
- No performance impact
- Handles all edge cases
- Production-ready quality

---

### Phase 6: Testing & Documentation (30 mins)

**Goals:**
- Comprehensive testing
- Document configuration
- Create troubleshooting guide
- Update kitty guide

**Tasks:**
- [ ] Test all metrics individually
- [ ] Test all metrics together
- [ ] Test with multiple tabs
- [ ] Test with different themes
- [ ] Test error conditions
- [ ] Document configuration in kitty guide
- [ ] Create troubleshooting section
- [ ] Add to navi cheatsheet
- [ ] Commit all changes

**Success Criteria:**
- All tests pass
- Documentation complete
- Ready for daily use
- User approved

---

## 🔀 Additional Features (Completed This Session)

### Window Splitting Configuration ✅

**Issue:** Kitty only splits horizontally on first terminal

**Solution:**
```conf
# Use splits layout with auto axis selection
enabled_layouts splits:split_axis=auto

# Explicit split shortcuts
map f5 launch --location=hsplit
map f6 launch --location=vsplit
map f7 layout_action rotate
```

**Status:** Configuration ready, needs testing

---

### Advanced Mouse Actions ✅

**Requirements Met:**

1. **Right-click behaviors:**
```conf
# Context-sensitive right-click
mouse_map right press ungrabbed mouse_handle_click selection link prompt

# Right-click with modifiers
mouse_map ctrl+right press ungrabbed launch --location=hsplit
mouse_map shift+right press ungrabbed launch --location=vsplit
mouse_map alt+right press ungrabbed new_tab
```

2. **Middle-click:**
```conf
mouse_map middle release ungrabbed paste_from_selection
```

3. **Selection copy:**
```conf
copy_on_select yes
```

**Status:** Configuration ready, needs testing

---

### Tab Management Enhancements ✅

**Tab Renaming:**
```conf
map f2 set_tab_title
map shift+f2 set_tab_title ""  # Reset to default
```

**Tab Title Templates:**
```conf
tab_title_template "{index}: {title[:25]}"
active_tab_title_template "[{layout_name}] {title[:25]}"
```

**Status:** Configuration ready, needs testing

---

## 🚫 Features NOT Implemented (By Design)

### Clickable Status Bar Elements

**Research Finding:** Kitty does not natively support custom click handlers on tab bar elements

**Decision:**
- **Phase 1-3:** No clickability (keyboard-driven workflow)
- **Meta Phases:** Revisit when status bar is stable
- **Alternative:** Use keyboard shortcuts for all actions

**Rationale:**
- Kitty philosophy: Keyboard-first terminal
- Native support doesn't exist
- Workarounds are fragile and unsupported
- User accepted this limitation

---

## 📊 Performance Considerations

### Refresh Rate Summary

| Metric | Refresh | Rationale |
|--------|---------|-----------|
| CPU | 3s | Fast-changing, needs frequent updates |
| RAM | 5s | Moderate changes, balance performance |
| Disk | 10s | Slow-changing, minimal updates needed |
| Network | 3s | Fast-changing for accurate speed |
| K8s Context | 5s | Rarely changes, cached for safety |
| Containers | 5s | Infrequent changes, moderate refresh |
| Time | 60s | Only needs minute precision |
| Git | On tab switch | Rarely changes within tab |

### Performance Targets

- **Max CPU Impact:** <1% average CPU usage
- **Max Memory:** <10MB additional RAM
- **UI Responsiveness:** <10ms per draw call
- **Startup Time:** <50ms to initialize

### Optimization Strategies

1. **Caching:** All metrics cached with timestamps
2. **Lazy Updates:** Only update when interval elapsed
3. **Subprocess Limits:** Timeout all subprocess calls (1 second max)
4. **Error Handling:** Graceful fallbacks, no crashes
5. **Batch Operations:** Group metric collection where possible

---

## 🔒 Security & Safety Considerations

### K8s Production Alert

**Critical Safety Feature:**
- **Purpose:** Prevent accidental operations in production
- **Detection:** Keywords: "prod", "production", "prd" (case-insensitive)
- **Visual Alert:** Yellow background (🟡) + warning symbol (⚠️)
- **Refresh:** Every 5 seconds to ensure always accurate

**Implementation:**
```python
def format_k8s_context(context):
    """Format K8s context with prod alert"""
    if is_prod_context(context):
        # Yellow background + warning
        return f"⚠️  {context}"
    else:
        # Normal format
        return f"⎈ {context}"
```

### Subprocess Security

**All subprocess calls must:**
1. Use timeout (1 second max)
2. Handle errors gracefully
3. Not block drawing thread
4. Validate output before display

---

## 📝 Configuration Files

### kitty.conf Additions

```conf
# ============ CUSTOM TAB BAR (STATUS BAR) ============
tab_bar_style custom
tab_bar_edge bottom
tab_separator ""
tab_bar_min_tabs 1

# Tab title templates (fallback if custom tab_bar.py fails)
tab_title_template "{index}: {title[:25]}"
active_tab_title_template "[{layout_name}] {title[:25]}"

# ============ WINDOW SPLITTING ============
# Enable splits layout with auto axis
enabled_layouts splits:split_axis=auto

# Split shortcuts
map f5 launch --location=hsplit
map f6 launch --location=vsplit
map f7 layout_action rotate

# ============ MOUSE ACTIONS ============
# Right-click context-sensitive
mouse_map right press ungrabbed mouse_handle_click selection link prompt

# Right-click with modifiers for actions
mouse_map ctrl+right press ungrabbed launch --location=hsplit
mouse_map shift+right press ungrabbed launch --location=vsplit
mouse_map alt+right press ungrabbed new_tab

# Middle-click paste
mouse_map middle release ungrabbed paste_from_selection

# Auto-copy on selection
copy_on_select yes

# ============ TAB MANAGEMENT ============
# Tab renaming
map f2 set_tab_title
map shift+f2 set_tab_title ""
```

---

## 🧪 Testing Checklist

### Unit Testing (Per Metric)

- [ ] CPU usage displays correctly
- [ ] CPU colors change at thresholds
- [ ] RAM usage displays correctly
- [ ] RAM colors change at thresholds
- [ ] Root disk usage correct
- [ ] Backups disk usage correct (if mounted)
- [ ] Backups disk handles missing mount
- [ ] Network speeds display
- [ ] Network handles no interface
- [ ] K8s context displays
- [ ] K8s prod alert shows correctly
- [ ] K8s handles no context
- [ ] Container count correct
- [ ] Container count handles no docker
- [ ] Git branch displays in repo
- [ ] Git handles non-repo directory
- [ ] Time displays and updates
- [ ] Layout name correct
- [ ] Tab number correct

### Integration Testing

- [ ] All metrics display together
- [ ] No visual overlap
- [ ] Readable with transparency
- [ ] Works with multiple tabs
- [ ] Refresh rates work correctly
- [ ] No performance degradation
- [ ] No UI lag when scrolling
- [ ] Works after theme change
- [ ] Works after config reload

### Edge Cases

- [ ] Handle very long metric values
- [ ] Handle terminal too narrow
- [ ] Handle metrics unavailable
- [ ] Handle subprocess timeouts
- [ ] Handle permission errors
- [ ] Handle missing commands
- [ ] Handle rapid tab switching
- [ ] Handle high system load

---

## 📚 References & Resources

### Official Documentation
- **Tab Bar API:** https://sw.kovidgoyal.net/kitty/conf/#tab-bar
- **Custom Tab Bar:** https://sw.kovidgoyal.net/kitty/kittens/custom/
- **Mouse Actions:** https://sw.kovidgoyal.net/kitty/conf/#mouse-actions
- **Remote Control:** https://sw.kovidgoyal.net/kitty/remote-control/

### Code Examples
- **Built-in tab_bar.py:** kitty source `kitty/tab_bar.py`
- **GitHub Issue #4447:** Extensive custom tab bar examples
- **kitty-panel Project:** System metrics integration

### Research Output
- **Research Confidence:** 0.87 (High - Band C)
- **Research Date:** 2025-12-01 23:15
- **Research Method:** Web Research Workflow
- **Sources:** Official docs, GitHub issues, community examples

---

## 🎯 Success Metrics

### Quantitative Goals

- ✅ All requested metrics displayed
- ✅ Refresh rates as specified
- ✅ <1% CPU impact
- ✅ <10MB memory usage
- ✅ 0 UI lag

### Qualitative Goals

- ✅ Visually appealing
- ✅ Easy to read at a glance
- ✅ Integrates with Dracula theme
- ✅ Useful for SRE workflows
- ✅ Production-ready quality

### User Acceptance Criteria

- [ ] User approves visual layout
- [ ] User finds metrics useful
- [ ] User experiences no performance issues
- [ ] User approves color scheme
- [ ] User ready for daily use

---

## 📅 Timeline & Next Steps

### Immediate Next Steps

1. **User Review (This Session):**
   - Review this plan
   - Confirm preferences documented correctly
   - Note any missing requirements
   - Update plan if needed

2. **Next Session (User scheduled):**
   - Implementation Session 1: Setup + System Metrics (2-3 hours)
   - Implementation Session 2: K8s + Advanced Features (2-3 hours)
   - Implementation Session 3: Testing + Polish (1-2 hours)

### Recommended Schedule

**Session 1 (2-3 hours):**
- Phase 1: Setup (45 mins)
- Phase 2: System Metrics (1.5 hours)
- Break and test

**Session 2 (2-3 hours):**
- Phase 3: K8s & Containers (1 hour)
- Phase 4: Network, Git, Time (1 hour)
- Break and test

**Session 3 (1-2 hours):**
- Phase 5: Visual Polish (1 hour)
- Phase 6: Testing & Documentation (30 mins)
- Final review and commit

---

## 🔄 Future Enhancements (Meta Phases)

### Phase 7: Clickability (Future)

**When status bar is stable and tested:**
- Research clickable element implementation
- Explore monkey-patching approach
- Consider external panel integration
- Evaluate risk vs. benefit
- Implement if feasible

### Phase 8: Advanced Features (Future)

**Additional metrics to consider:**
- Battery status (if laptop)
- Temperature monitoring
- Process count
- Swap usage
- Custom metrics via config

### Phase 9: Customization (Future)

**User-configurable options:**
- Enable/disable specific metrics
- Adjust thresholds
- Change colors
- Custom formatters
- Position preferences

---

## ✅ Completion Checklist

### Planning Phase ✅
- [x] Research completed (0.87 confidence)
- [x] User requirements gathered
- [x] User preferences documented
- [x] Technical approach defined
- [x] Implementation phases planned
- [x] Timeline estimated
- [x] Testing strategy defined
- [x] Documentation structure created

### Ready for Implementation
- [ ] User reviewed and approved plan
- [ ] User scheduled implementation sessions
- [ ] Development environment ready
- [ ] Backup of current configuration
- [ ] All prerequisites met

---

**Plan Status:** COMPLETE - Ready for User Review
**Next Action:** User reviews plan and schedules implementation session
**Plan Maintainer:** Dimitris Tsioumas (Mitsio)
**Last Updated:** 2025-12-01 23:25
