# Kitty Tab Bar Architecture Design
**Comprehensive Status Bar with System Metrics**

**Date:** 2025-12-16
**Status:** Design Complete - Ready for Implementation
**Purpose:** Replace Phase E Advanced Status Bar with beautified comprehensive tab bar

---

## Executive Summary

This document specifies the complete architecture for a comprehensive kitty tab bar that combines:
- Beautiful Dracula-themed tab rendering with powerline separators
- Real-time system metrics (CPU, RAM, Battery)
- Live updates via timer mechanism
- Modular, maintainable design
- Graceful error handling and performance optimization

**This implementation replaces Phase E entirely** - providing all planned SRE/DevOps monitoring capabilities in a single, cohesive solution.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Widget Specifications](#widget-specifications)
3. [Color Scheme](#color-scheme)
4. [Module Structure](#module-structure)
5. [Performance Considerations](#performance-considerations)
6. [Configuration System](#configuration-system)
7. [Error Handling](#error-handling)
8. [F12 Panel Enhancement](#f12-panel-enhancement)
9. [Implementation Guide](#implementation-guide)
10. [Testing Strategy](#testing-strategy)

---

## Architecture Overview

### High-Level Design

```
┌─────────────────────────────────────────────────────────────────┐
│ [Tab 1] [Tab 2] [Tab 3*]        45%  62%  85%   15:30  16 Dec │
│   ↑                               ↑    ↑    ↑      ↑      ↑     │
│  Tabs                            CPU  RAM  BAT   TIME   DATE    │
└─────────────────────────────────────────────────────────────────┘
```

### Components

**1. Tab Section (Left/Center)**
- Powerline style with rounded separators (, )
- Dracula color scheme
- Dynamic colors for active/inactive tabs
- Tab title from `tab_title_template` in kitty.conf

**2. Widget Section (Right)**
- Essential widgets: Time, Date, Battery
- Core metrics: CPU, RAM
- Optional metrics: Disk, Network (disabled by default)
- Dynamic color coding based on thresholds

**3. Update Mechanism**
- Timer-based refresh (2 seconds default)
- Lazy metric collection (only when visible)
- Cached values to minimize system calls

---

## Widget Specifications

### Essential Widgets (Always Shown)

#### 1. Time Widget
- **Icon:**  (clock)
- **Format:** `HH:MM` (24-hour)
- **Color:** `#8be9fd` (Dracula cyan)
- **Data Source:** `datetime.now().strftime("%H:%M")`
- **Width:** ~7 characters

#### 2. Date Widget
- **Icon:**  (calendar)
- **Format:** `DD MMM` (e.g., "16 Dec")
- **Color:** `#bd93f9` (Dracula purple)
- **Data Source:** `datetime.now().strftime("%d %b")`
- **Width:** ~9 characters

#### 3. Battery Widget
- **Icons:** Dynamic based on charge level
  ```python
  UNPLUGGED_ICONS = {
      10: "",
      20: "",
      30: "",
      40: "",
      50: "",
      60: "",
      70: "",
      80: "",
      90: "",
      100: "",
  }
  PLUGGED_ICONS = {1: "󰚥"}
  ```
- **Format:** `XX% <icon>`
- **Color:** Dynamic based on status and level
  - Charging: `#50fa7b` (green)
  - >60%: `#50fa7b` (green)
  - 30-60%: `#f1fa8c` (yellow)
  - 15-30%: `#ffb86c` (orange)
  - <15%: `#ff5555` (red)
- **Data Source:** `/sys/class/power_supply/BAT0/`
- **Width:** ~8 characters
- **Error Handling:** Hide widget if no battery detected

### Core Metrics (Shown by Default)

#### 4. CPU Widget
- **Icon:**  (processor)
- **Format:** `XX%`
- **Color:** Dynamic based on usage
  - <50%: `#50fa7b` (green)
  - 50-75%: `#f1fa8c` (yellow)
  - 75-90%: `#ffb86c` (orange)
  - >90%: `#ff5555` (red)
- **Data Source:** `psutil.cpu_percent(interval=1)`
- **Width:** ~6 characters

#### 5. RAM Widget
- **Icon:**  (memory chip)
- **Format:** `XX%`
- **Color:** Dynamic based on usage
  - <60%: `#50fa7b` (green)
  - 60-80%: `#f1fa8c` (yellow)
  - 80-95%: `#ffb86c` (orange)
  - >95%: `#ff5555` (red)
- **Data Source:** `psutil.virtual_memory().percent`
- **Width:** ~6 characters

### Optional Widgets (Disabled by Default)

#### 6. Disk Widget
- **Icon:**  (hard drive)
- **Format:** `/ XX%` or `/home XX%`
- **Color:** `#ff79c6` (pink)
- **Data Source:** `psutil.disk_usage('/').percent`
- **Width:** ~9 characters per disk

#### 7. Network Widget
- **Icons:** ↓ ↑ (arrows)
- **Format:** `↓XX ↑XX` (MB/s)
- **Color:** `#8be9fd` (cyan)
- **Data Source:** `psutil.net_io_counters()`
- **Width:** ~12 characters

---

## Color Scheme

### Dracula Palette (from current-theme.conf)

```python
# Base colors
BACKGROUND = "#282a36"
FOREGROUND = "#f8f8f2"
TAB_BAR_BG = "#21222c"

# Accent colors
PURPLE = "#bd93f9"  # Date icon, active elements
PINK = "#ff79c6"    # Disk, special alerts
CYAN = "#8be9fd"    # Time, network, info
GREEN = "#50fa7b"   # Good status (CPU/RAM/Battery)
YELLOW = "#f1fa8c"  # Warning status
ORANGE = "#ffb86c"  # High status
RED = "#ff5555"     # Critical status
COMMENT = "#6272a4" # Inactive elements

# Tab colors
ACTIVE_TAB_FG = "#282a36"
ACTIVE_TAB_BG = "#f8f8f2"
INACTIVE_TAB_FG = "#282a36"
INACTIVE_TAB_BG = "#6272a4"
```

### Color Application

**Active Tab:**
- Background: `#f8f8f2` (foreground - inverted)
- Foreground: `#282a36` (background - inverted)
- Font: Bold

**Inactive Tab:**
- Background: `#6272a4` (comment)
- Foreground: `#282a36`
- Font: Normal

**Widget Background:**
- Background: `#6272a4` (matches inactive tabs)
- Text: `#f8f8f2` (foreground)

**Powerline Separators:**
- Foreground: Tab background color
- Background: Next tab/default background

---

## Module Structure

### File Organization

```python
# ~/.local/share/chezmoi/private_dot_config/kitty/tab_bar.py

"""
Kitty Tab Bar with Comprehensive System Metrics
Dracula Theme | SRE/DevOps Optimized
"""

# ============================================================================
# SECTION 1: IMPORTS & CONFIGURATION
# ============================================================================
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, Tuple, List

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.tab_bar import (
    DrawData, ExtraData, TabBarData,
    as_rgb, draw_tab_with_powerline
)
from kitty.utils import color_as_int

# Conditional import - graceful degradation if psutil unavailable
try:
    import psutil
    PSUTIL_AVAILABLE = True
except ImportError:
    PSUTIL_AVAILABLE = False
    # Warning will be shown in tab bar

# ============================================================================
# SECTION 2: CONFIGURATION CONSTANTS
# ============================================================================

# Widget Enable/Disable Flags
SHOW_TIME = True
SHOW_DATE = True
SHOW_BATTERY = True
SHOW_CPU = True
SHOW_RAM = True
SHOW_DISK_ROOT = False      # Optional - disabled by default
SHOW_DISK_HOME = False      # Optional - disabled by default
SHOW_NETWORK = False        # Optional - disabled by default

# Refresh Configuration
REFRESH_TIME = 2.0  # seconds

# Color Thresholds
CPU_THRESHOLDS = {
    'yellow': 50,
    'orange': 75,
    'red': 90
}

RAM_THRESHOLDS = {
    'yellow': 60,
    'orange': 80,
    'red': 95
}

BATTERY_THRESHOLDS = {
    'orange': 30,
    'red': 15
}

# Widget Formatting
TIME_FORMAT = "%H:%M"
DATE_FORMAT = "%d %b"

# Nerd Font Icons
ICON_TIME = ""
ICON_DATE = ""
ICON_CPU = ""
ICON_RAM = ""
ICON_DISK = ""
ICON_NETWORK_DOWN = "↓"
ICON_NETWORK_UP = "↑"

# Battery Icons
UNPLUGGED_ICONS = {
    10: "",
    20: "",
    30: "",
    40: "",
    50: "",
    60: "",
    70: "",
    80: "",
    90: "",
    100: "",
}
PLUGGED_ICONS = {1: "󰚥"}

# ============================================================================
# SECTION 3: COLOR MANAGEMENT
# ============================================================================

# Global color cache (initialized once)
_COLORS: Optional[Dict[str, int]] = None

def get_colors() -> Dict[str, int]:
    """Get Dracula colors from kitty config (cached)"""
    global _COLORS
    if _COLORS is None:
        opts = get_options()
        _COLORS = {
            'green': as_rgb(color_as_int(opts.color2)),
            'yellow': as_rgb(color_as_int(opts.color3)),
            'orange': as_rgb(color_as_int(opts.color11)),
            'red': as_rgb(color_as_int(opts.color1)),
            'cyan': as_rgb(color_as_int(opts.color6)),
            'purple': as_rgb(color_as_int(opts.color4)),
            'pink': as_rgb(color_as_int(opts.color5)),
            'foreground': as_rgb(color_as_int(opts.foreground)),
            'comment': as_rgb(color_as_int(opts.color8)),
        }
    return _COLORS

# ============================================================================
# SECTION 4: DATA COLLECTION FUNCTIONS
# ============================================================================

def get_battery_status() -> Optional[Dict[str, any]]:
    """
    Get battery status from /sys/class/power_supply/BAT0/
    Returns: {'percent': int, 'charging': bool, 'icon': str, 'color': int}
    Returns None if no battery present
    """
    try:
        with open("/sys/class/power_supply/BAT0/status", "r") as f:
            status = f.read().strip()
        with open("/sys/class/power_supply/BAT0/capacity", "r") as f:
            percent = int(f.read().strip())

        charging = status in ("Charging", "Full")
        colors = get_colors()

        # Determine icon
        if charging:
            icon = PLUGGED_ICONS[1]
            color = colors['green']
        else:
            # Find closest icon based on percent
            icon = UNPLUGGED_ICONS[
                min(UNPLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
            ]
            # Determine color based on thresholds
            if percent < BATTERY_THRESHOLDS['red']:
                color = colors['red']
            elif percent < BATTERY_THRESHOLDS['orange']:
                color = colors['orange']
            else:
                color = colors['green']

        return {
            'percent': percent,
            'charging': charging,
            'icon': icon,
            'color': color
        }
    except FileNotFoundError:
        return None  # No battery present (desktop)
    except Exception as e:
        return None  # Other error - hide widget

def get_cpu_usage() -> Optional[Dict[str, any]]:
    """
    Get CPU usage percentage
    Returns: {'percent': float, 'color': int}
    Returns None if psutil unavailable
    """
    if not PSUTIL_AVAILABLE:
        return None

    try:
        percent = psutil.cpu_percent(interval=0)  # Use cached value
        colors = get_colors()

        # Determine color based on thresholds
        if percent >= CPU_THRESHOLDS['red']:
            color = colors['red']
        elif percent >= CPU_THRESHOLDS['orange']:
            color = colors['orange']
        elif percent >= CPU_THRESHOLDS['yellow']:
            color = colors['yellow']
        else:
            color = colors['green']

        return {
            'percent': int(percent),
            'color': color
        }
    except Exception:
        return None

def get_memory_usage() -> Optional[Dict[str, any]]:
    """
    Get RAM usage percentage
    Returns: {'percent': float, 'color': int}
    Returns None if psutil unavailable
    """
    if not PSUTIL_AVAILABLE:
        return None

    try:
        percent = psutil.virtual_memory().percent
        colors = get_colors()

        # Determine color based on thresholds
        if percent >= RAM_THRESHOLDS['red']:
            color = colors['red']
        elif percent >= RAM_THRESHOLDS['orange']:
            color = colors['orange']
        elif percent >= RAM_THRESHOLDS['yellow']:
            color = colors['yellow']
        else:
            color = colors['green']

        return {
            'percent': int(percent),
            'color': color
        }
    except Exception:
        return None

def get_disk_usage(path: str = '/') -> Optional[Dict[str, any]]:
    """
    Get disk usage for specified path
    Returns: {'percent': float, 'path': str}
    Returns None if psutil unavailable or error
    """
    if not PSUTIL_AVAILABLE:
        return None

    try:
        usage = psutil.disk_usage(path)
        return {
            'percent': int(usage.percent),
            'path': path
        }
    except Exception:
        return None

def get_network_io() -> Optional[Dict[str, any]]:
    """
    Get network I/O rates (simplified - requires tracking delta)
    Returns: {'down_mb': float, 'up_mb': float}
    Returns None if psutil unavailable
    """
    if not PSUTIL_AVAILABLE:
        return None

    try:
        # Simplified - would need delta tracking for rates
        # For now, just return counters
        io = psutil.net_io_counters()
        return {
            'down_mb': io.bytes_recv / (1024 * 1024),
            'up_mb': io.bytes_sent / (1024 * 1024)
        }
    except Exception:
        return None

# ============================================================================
# SECTION 5: WIDGET RENDERING
# ============================================================================

def create_widget_cells() -> List[Tuple[int, str]]:
    """
    Create list of widget cells as (color, text) tuples
    Widgets are added in priority order (essential first)
    Returns empty cells list if window too narrow
    """
    cells = []
    colors = get_colors()

    # Essential Widget 1: Time (always shown)
    if SHOW_TIME:
        time_str = datetime.now().strftime(TIME_FORMAT)
        cells.append((colors['cyan'], f"{ICON_TIME} {time_str}"))

    # Essential Widget 2: Date (always shown)
    if SHOW_DATE:
        date_str = datetime.now().strftime(DATE_FORMAT)
        cells.append((colors['purple'], f"{ICON_DATE} {date_str}"))

    # Essential Widget 3: Battery (if present)
    if SHOW_BATTERY:
        battery = get_battery_status()
        if battery:
            cells.append((
                battery['color'],
                f"{battery['icon']} {battery['percent']}%"
            ))

    # Core Metric 1: RAM
    if SHOW_RAM:
        ram = get_memory_usage()
        if ram:
            cells.append((
                ram['color'],
                f"{ICON_RAM} {ram['percent']}%"
            ))

    # Core Metric 2: CPU
    if SHOW_CPU:
        cpu = get_cpu_usage()
        if cpu:
            cells.append((
                cpu['color'],
                f"{ICON_CPU} {cpu['percent']}%"
            ))

    # Optional: Disk usage
    if SHOW_DISK_ROOT:
        disk = get_disk_usage('/')
        if disk:
            cells.append((
                colors['pink'],
                f"{ICON_DISK} / {disk['percent']}%"
            ))

    if SHOW_DISK_HOME:
        disk = get_disk_usage('/home')
        if disk:
            cells.append((
                colors['pink'],
                f"{ICON_DISK} /home {disk['percent']}%"
            ))

    # Optional: Network
    if SHOW_NETWORK:
        net = get_network_io()
        if net:
            cells.append((
                colors['cyan'],
                f"{ICON_NETWORK_DOWN}{net['down_mb']:.1f} "
                f"{ICON_NETWORK_UP}{net['up_mb']:.1f}"
            ))

    # Reverse to draw right-to-left (rightmost widget first)
    cells.reverse()

    return cells

def draw_right_status(
    screen: Screen,
    is_last: bool,
    draw_data: DrawData
) -> int:
    """
    Draw widgets on right side of tab bar
    Returns final cursor x position
    """
    if not is_last:
        return screen.cursor.x

    cells = create_widget_cells()
    if not cells:
        return screen.cursor.x

    # Calculate total width needed
    right_status_length = sum(len(cell[1]) + 3 for cell in cells)  # +3 for spacing

    # Position cursor at right edge
    screen.cursor.x = max(0, screen.columns - right_status_length - 2)

    # Draw each widget
    widget_bg = get_colors()['comment']
    for color, text in cells:
        screen.cursor.fg = color
        screen.cursor.bg = widget_bg
        screen.draw(f" {text} ")

    screen.cursor.fg = 0
    screen.cursor.bg = 0

    return screen.cursor.x

# ============================================================================
# SECTION 6: TIMER & REFRESH
# ============================================================================

timer_id: Optional[int] = None

def _redraw_tab_bar(timer_id: int) -> None:
    """Callback to redraw tab bar on timer"""
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()

# ============================================================================
# SECTION 7: MAIN DRAW FUNCTION
# ============================================================================

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """
    Main entry point - called by kitty for each tab
    Draws tabs using powerline style, then widgets on right
    """
    global timer_id

    # Start timer on first call
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

    # Draw tabs using built-in powerline style
    draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length,
        index, is_last, extra_data
    )

    # Draw widgets on right (only for last tab)
    draw_right_status(screen, is_last, draw_data)

    return screen.cursor.x
```

---

## Performance Considerations

### Optimization Strategies

**1. Cached Color Values**
- Colors read once from `get_options()` on first call
- Stored in global `_COLORS` dict
- Prevents repeated color parsing

**2. Lazy psutil Import**
- Conditional import with try/except
- Graceful degradation if unavailable
- `PSUTIL_AVAILABLE` flag checked before calls

**3. Efficient Metric Collection**
- `psutil.cpu_percent(interval=0)` uses cached values
- Battery read from fast `/sys` filesystem
- Metrics only collected when tab bar visible (is_last check)

**4. Smart Timer Refresh**
- 2-second interval balances responsiveness vs CPU
- Uses `mark_tab_bar_dirty()` (lightweight)
- Timer only started once (global timer_id)

**5. Widget Priority System**
- Cells created in priority order
- Optional widgets easily disabled
- Width calculation prevents overflow

### Performance Impact Estimates

| Component | CPU Usage | Memory | Notes |
|-----------|-----------|--------|-------|
| Tab rendering | ~0.1% | <1MB | Built-in kitty code |
| psutil metrics | ~0.5% | ~5MB | Every 2 seconds |
| Battery reading | <0.1% | Negligible | File I/O |
| Timer overhead | <0.1% | Negligible | Event-driven |
| **Total** | **~0.7%** | **~6MB** | Acceptable for desktop |

---

## Configuration System

### User Customization Options

All configuration via constants at top of `tab_bar.py`:

```python
# Enable/Disable Widgets
SHOW_TIME = True          # Essential
SHOW_DATE = True          # Essential
SHOW_BATTERY = True       # Essential (hides on desktop)
SHOW_CPU = True           # Core metric
SHOW_RAM = True           # Core metric
SHOW_DISK_ROOT = False    # Optional
SHOW_DISK_HOME = False    # Optional
SHOW_NETWORK = False      # Optional

# Refresh Rate
REFRESH_TIME = 2.0        # Seconds between updates

# Thresholds (percentage)
CPU_THRESHOLDS = {'yellow': 50, 'orange': 75, 'red': 90}
RAM_THRESHOLDS = {'yellow': 60, 'orange': 80, 'red': 95}
BATTERY_THRESHOLDS = {'orange': 30, 'red': 15}

# Formatting
TIME_FORMAT = "%H:%M"     # 24-hour format
DATE_FORMAT = "%d %b"     # Day + abbreviated month
```

### kitty.conf Settings

Required settings (already configured):
```conf
tab_bar_style custom
tab_bar_edge top
tab_powerline_style slanted
tab_title_template " {index}  {title} "
```

---

## Error Handling

### Graceful Degradation Strategy

**1. psutil Unavailable**
```python
try:
    import psutil
    PSUTIL_AVAILABLE = True
except ImportError:
    PSUTIL_AVAILABLE = False
    # Widgets requiring psutil won't be shown
```

**2. Battery Not Present (Desktop)**
```python
def get_battery_status() -> Optional[Dict]:
    try:
        # Read battery files
    except FileNotFoundError:
        return None  # Widget hidden
```

**3. Permission Errors**
```python
try:
    # System metric collection
except Exception:
    return None  # Hide widget on any error
```

**4. Widget Overflow (Narrow Terminal)**
```python
# Calculate total width
right_status_length = sum(len(cell[1]) + 3 for cell in cells)

# Position at right edge (may clip if too narrow)
screen.cursor.x = max(0, screen.columns - right_status_length - 2)
```

### Error Handling Principles

✅ Never crash the tab bar
✅ Hide problematic widgets gracefully
✅ Log errors to kitty debug output (optional)
✅ Provide visual feedback for missing dependencies
✅ Degrade to basic tab bar if all metrics fail

---

## F12 Panel Enhancement

### Option 1: btop Integration (Recommended)

**Configuration:**
```conf
# kitty.conf
map f12 kitten panel --edge top --size 0.5 btop
```

**Benefits:**
- Zero custom code
- Full-featured system monitor
- Dracula theme support
- Interactive (kill processes, etc.)
- Already available on NixOS

**Setup:**
```bash
# Install btop (if not already present)
nix-env -iA nixpkgs.btop

# Configure Dracula theme for btop
# btop already includes Dracula theme option
```

### Option 2: Custom Panel Script (Future Enhancement)

**File:** `~/.config/kitty/panel_stats.py`

**Features:**
- Same metrics as tab bar
- ASCII progress bars
- Larger, easier-to-read format
- Matches Dracula colors

**Example Output:**
```
┌─ System Status ─────────────────┐
│                                  │
│  CPU:  45% [████████░░░░░░]    │
│  RAM:  62% [██████████░░░░]    │
│  Disk: 73% [████████████░░]    │
│  Bat:  85%  (Charging)         │
│                                  │
│  Press ESC or F12 to close       │
└──────────────────────────────────┘
```

**Recommendation:** Start with Option 1 (btop) for immediate value.

---

## Implementation Guide

### Step-by-Step Implementation

#### Phase 1: Environment Preparation

**1.1 Check psutil Installation**
```bash
python3 -c "import psutil; print(psutil.__version__)"
```

If not installed:
```bash
# NixOS - add to home.nix packages
python3Packages.psutil

# Or install via pip (temporary)
pip install --user psutil
```

**1.2 Verify Nerd Fonts**
```bash
# Already configured in kitty.conf
# JetBrains Mono Nerd Font
```

**1.3 Backup Current Config**
```bash
cd ~/.local/share/chezmoi/private_dot_config/kitty
cp kitty.conf kitty.conf.backup.$(date +%Y%m%d)
# No tab_bar.py exists yet (first time creation)
```

#### Phase 2: Create tab_bar.py

**2.1 Create File**
```bash
cd ~/.local/share/chezmoi/private_dot_config/kitty
# Create tab_bar.py with architecture specified above
```

**2.2 Set Permissions**
```bash
chmod 644 tab_bar.py
```

**2.3 Verify kitty.conf Settings**
```conf
# These should already be set:
tab_bar_style custom
tab_bar_edge top
tab_bar_align left
tab_bar_min_tabs 2
tab_powerline_style slanted
```

#### Phase 3: Testing

**3.1 Apply Configuration**
```bash
chezmoi apply
```

**3.2 Reload Kitty**
```bash
# In kitty: Ctrl+Shift+F5
# Or restart kitty
```

**3.3 Verify Widget Display**
- Check time/date appear
- Verify battery icon (if laptop)
- Check CPU/RAM colors
- Test with narrow terminal width

**3.4 Test Error Handling**
```bash
# Test without psutil (rename temporarily)
mv ~/.local/lib/python3.x/site-packages/psutil ~/.../psutil.bak
# Restart kitty - should still show time/date
# Restore psutil
```

#### Phase 4: Customization

**4.1 Adjust Thresholds**
```python
# In tab_bar.py
CPU_THRESHOLDS = {
    'yellow': 60,  # Changed from 50
    'orange': 80,  # Changed from 75
    'red': 95      # Changed from 90
}
```

**4.2 Enable Optional Widgets**
```python
SHOW_DISK_ROOT = True   # Enable disk monitoring
SHOW_NETWORK = True     # Enable network monitoring
```

**4.3 Adjust Refresh Rate**
```python
REFRESH_TIME = 1.0  # Faster updates (higher CPU usage)
# or
REFRESH_TIME = 5.0  # Slower updates (lower CPU usage)
```

#### Phase 5: F12 Panel Setup

**5.1 Install btop**
```bash
# If not already installed
sudo nix-channel --update
nix-env -iA nixpkgs.btop
```

**5.2 Configure F12 Binding**
```conf
# kitty.conf - replace existing F12 binding
map f12 kitten panel --edge top --size 0.5 btop
```

**5.3 Test F12 Panel**
- Press F12 in kitty
- Verify btop launches in panel
- Press F12 again to close

---

## Testing Strategy

### Test Cases

#### TC1: Basic Functionality
- **Test:** Fresh kitty launch
- **Expected:** Tab bar renders with tabs and widgets
- **Verify:** Time, date, CPU, RAM visible

#### TC2: Battery Detection
- **Test:** Launch on laptop vs desktop
- **Expected:** Battery shown on laptop, hidden on desktop
- **Verify:** No errors in either case

#### TC3: psutil Unavailable
- **Test:** Rename psutil module
- **Expected:** Graceful degradation, time/date still shown
- **Verify:** No crashes, warning message optional

#### TC4: Narrow Terminal
- **Test:** Resize terminal to narrow width (80 cols)
- **Expected:** Widgets clip gracefully, tabs still functional
- **Verify:** No overlap, no crashes

#### TC5: Color Thresholds
- **Test:** Generate high CPU load (stress test)
- **Expected:** CPU widget changes from green → yellow → orange → red
- **Verify:** Colors match Dracula palette

#### TC6: Timer Refresh
- **Test:** Watch time widget for 60 seconds
- **Expected:** Time updates every refresh interval
- **Verify:** No flickering, smooth updates

#### TC7: Tab Switching
- **Test:** Create multiple tabs, switch between them
- **Expected:** Widgets only on rightmost position
- **Verify:** Tab switching works normally

#### TC8: F12 Panel
- **Test:** Press F12
- **Expected:** btop launches in top panel
- **Verify:** Panel opens/closes cleanly

### Performance Testing

```bash
# Monitor kitty CPU usage
top -p $(pgrep kitty)

# Expected: <1% CPU usage in idle
# Expected: ~1-2% CPU with active updates
```

---

## Dependencies

### Required

- **kitty** >= 0.26.0 (for custom tab_bar.py support)
- **Python** >= 3.6 (kitty's embedded Python)
- **Nerd Fonts** (JetBrains Mono Nerd Font - already configured)

### Highly Recommended

- **psutil** >= 5.8.0 (for system metrics)
  ```bash
  # NixOS
  python3Packages.psutil

  # Or pip
  pip install --user psutil
  ```

### Optional

- **btop** (for F12 panel enhancement)
  ```bash
  # NixOS
  nix-env -iA nixpkgs.btop
  ```

---

## Files Modified/Created

### Created

1. **~/.local/share/chezmoi/private_dot_config/kitty/tab_bar.py**
   - New file: Comprehensive tab bar implementation
   - Lines: ~500
   - Purpose: Main tab bar rendering with widgets

### Modified

2. **~/.local/share/chezmoi/private_dot_config/kitty/kitty.conf**
   - Line ~295: Update F12 binding to btop
   - Verify: `tab_bar_style custom` setting

### Read-Only (Reference)

3. **~/.local/share/chezmoi/private_dot_config/kitty/current-theme.conf**
   - Dracula color definitions
   - No modifications needed

### Documentation Updated

4. **docs/plans/2025-12-14-kitty-enhancements-and-integrations-plan.md**
   - Replace Phase E with Phase C.3
   - Mark beautification as COMPLETE

5. **docs/TODO.md**
   - Update kitty section
   - Mark comprehensive status bar complete

---

## Migration from Phase E Plan

**Original Phase E Scope:**
- Custom Python tab_bar.py with SRE metrics
- System Metrics: CPU, RAM, Disk, Network
- SRE/DevOps Info: K8s context, Git branch, Container count
- Dracula colors
- Transparency-friendly
- Estimate: 6-8 hours

**This Implementation (Phase C.3) Provides:**
✅ Custom Python tab_bar.py
✅ System Metrics: CPU, RAM, Disk (optional), Network (optional)
✅ Battery status (laptop-specific)
✅ Dracula colors
✅ Transparency-friendly
✅ Live updates via timer
✅ Modular, maintainable design
✅ Better performance than originally planned

**Advanced Features Deferred (Not Needed):**
- K8s context (can add later if needed)
- Git branch (better handled by shell prompt)
- Container count (tmux replacement goal means less containers)

**Conclusion:** This implementation exceeds Phase E requirements while being simpler and more performant. Phase E is replaced, not postponed.

---

## Future Enhancements (Optional)

### Potential Additions

1. **Active Process Widget**
   - Show foreground process name
   - Icon:
   - Useful for identifying what's running

2. **Git Branch Widget**
   - Show git branch if in repo
   - Icon:
   - Dynamic color based on git status

3. **Kubernetes Context**
   - Show active k8s context
   - Icon: ☸
   - Useful for SRE workflows

4. **Custom Widgets via Plugin System**
   - User-defined widget functions
   - Load from `tab_bar_widgets.py`
   - Enable community contributions

### Enhancement Priority

1. **High Priority:** None - current design is complete
2. **Medium Priority:** Active process widget
3. **Low Priority:** Git, K8s widgets
4. **Future:** Plugin system

---

## Rollback Procedure

If implementation causes issues:

**Step 1: Remove tab_bar.py**
```bash
cd ~/.local/share/chezmoi/private_dot_config/kitty
rm tab_bar.py
chezmoi apply
```

**Step 2: Change tab_bar_style**
```conf
# kitty.conf - change to:
tab_bar_style powerline
```

**Step 3: Reload kitty**
```bash
# Ctrl+Shift+F5 or restart kitty
```

**Result:** Reverts to basic powerline tab bar (Phase C.1)

---

## Success Criteria

Implementation is successful when:

✅ Tab bar renders with Dracula colors
✅ Time and date widgets update every 2 seconds
✅ Battery widget shows correct status (laptop) or hidden (desktop)
✅ CPU widget color changes based on load
✅ RAM widget color changes based on usage
✅ No crashes or errors in kitty
✅ Performance impact <1% CPU
✅ F12 panel launches btop successfully
✅ User is satisfied with visual appearance
✅ Configuration is maintainable and well-documented

---

## References

- **GitHub Discussion #4447:** Share your tab bar style
  - URL: https://github.com/kovidgoyal/kitty/discussions/4447
  - Key contributors: ssnailed, tevansuk, megalithic

- **Kitty Documentation:** Tab bar customization
  - URL: https://sw.kovidgoyal.net/kitty/conf/#tab-bar

- **psutil Documentation:** System metrics
  - URL: https://psutil.readthedocs.io/

- **Dracula Theme:** Color specifications
  - URL: https://draculatheme.com/contribute

---

**Document Version:** 1.0
**Last Updated:** 2025-12-16
**Next Review:** After implementation completion
