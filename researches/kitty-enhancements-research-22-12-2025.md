# Kitty Terminal Enhancements Research

**Created:** 2025-12-22
**Updated:** 2025-12-22
**Purpose:** Research findings for Phase K implementation
**Status:** ✅ COMPLETE

---

## Table of Contents

1. [Browser Integration](#1-browser-integration)
2. [Right-Click Context Menu](#2-right-click-context-menu)
3. [GPU & RAM Optimization](#3-gpu--ram-optimization)
4. [Obsidian Integration](#4-obsidian-integration)
5. [Calendar & Plasma Integration](#5-calendar--plasma-integration)
6. [Terminal Notifications](#6-terminal-notifications)
7. [Session Persistence](#7-session-persistence)
8. [Document Viewing](#8-document-viewing)
9. [Quick Notes Widget](#9-quick-notes-widget)
10. [Implementation Feasibility Matrix](#10-implementation-feasibility-matrix)
11. [Recommended Implementation Order](#11-recommended-implementation-order)

---

## 1. Browser Integration

### 1.1 Firefox Overlay Panel

**Research Status:** COMPLETED

#### Findings

**Kitty Panel Kitten Capabilities:**
- The panel kitten is designed for **terminal programs only**, not GUI applications
- It renders terminal content to a GPU-accelerated surface layer
- Primary use cases: desktop backgrounds (btop, cava), status bars, floating terminals
- **Cannot directly embed GUI applications like Firefox**

**X11/Wayland Window Embedding:**
- Traditional X11 window embedding (XEmbed protocol) is **not supported** in modern browsers
- Firefox and Chrome removed XEmbed support years ago for security reasons
- Wayland compositors have **no standard window embedding protocol**
- Window management tools (wmctrl, xdotool) can position windows but not embed them

**Alternative Approaches Investigated:**
1. **Layered Windows**: Use window manager rules to keep Firefox always-on-top and positioned over kitty
   - Requires manual window management
   - Not truly "embedded"
   - Browser still appears as separate window

2. **Picture-in-Picture**: Firefox/Chrome PiP for video content only
   - Limited to video elements
   - Not suitable for full web browsing

3. **VNC/RDP in Terminal**: Run browser remotely and display via terminal client
   - High latency
   - Defeats purpose of local integration

#### Tools & Approaches

**Not Feasible:**
- Kitty panel kitten + Firefox (panel only supports terminal programs)
- X11 XEmbed (removed from modern browsers)
- Wayland subsurfaces for browser embedding (no standard protocol)

**Possible Workarounds (Not Recommended):**
- Window manager positioning scripts (fragile, not true embedding)
- Headless browser + VNC viewer in terminal (high overhead)
- X11 nested server (Xephyr) + window positioning (complex, defeats purpose)

#### Implementation Complexity

**Feasibility: VERY HARD / NOT PRACTICALLY ACHIEVABLE**

**Technical Barriers:**
1. Kitty panel kitten architecture fundamentally incompatible with GUI apps
2. Modern browsers removed embedding support for security
3. No standard protocol exists for browser-in-terminal embedding
4. Would require either:
   - Forking and modifying Firefox (massive maintenance burden)
   - Creating custom window server/compositor (months of work)
   - Using workarounds that provide poor UX

**Estimated Effort:** 200+ hours for hacky workaround, potentially impossible for true embedding

#### Recommended Approach

**Do NOT pursue Firefox overlay in kitty panel.**

**Better Alternatives:**
1. **Use TUI browsers** (see section 1.2) - Browsh or Carbonyl provide actual terminal-native browsing
2. **External browser with keybindings** - Use kitty's remote control to spawn Firefox in separate window
3. **tmux/zellij + browser-in-adjacent-pane** - Side-by-side layout with terminal multiplexer
4. **KDE Activities/Virtual Desktops** - Organize browser and terminal in workspace layouts

---

### 1.2 TUI Browsers (Carbonyl/Browsh)

**Research Status:** COMPLETED

#### Findings

**Carbonyl (Chromium-based):**
- **Architecture**: Full Chromium fork rendered natively to terminal via Skia hooks
- **Rendering**: Uses Unicode half-blocks (▄) with 24-bit ANSI colors for 2 colors per cell
- **Performance**: Extremely fast - starts in <1s, runs at 60 FPS, idles at 0% CPU
- **Features**: Full Web API support (WebGL, WebGPU, audio, video, JavaScript, CSS3, HTML5)
- **Size**: ~200MB binary, no external dependencies besides terminal
- **Pros**:
  - True native terminal rendering (not downscaled screenshots)
  - Full modern web standards support
  - Excellent performance
  - No window server required (works in console, SSH)
- **Cons**:
  - Large binary size
  - Infrequent updates (security concern for Chromium fork)
  - Last release: v0.0.3 (Feb 2023) - project may be abandoned
  - Building from source takes hours

**Browsh (Firefox-based):**
- **Architecture**: Headless Firefox + WebExtension + Go terminal client via websocket
- **Rendering**: Screenshots downscaled to terminal resolution, text overlay
- **Performance**: Slower than Carbonyl (50x more CPU for same content according to Carbonyl docs)
- **Features**: Full Firefox capabilities, supports extensions
- **Size**: ~11MB binary + Firefox dependency
- **Pros**:
  - Easy to update (just update Firefox)
  - Active development (last release: v1.8.3, Jan 2024)
  - Extension support
  - Easier to build/modify (Go + JS vs. forking Chromium)
  - Better for bandwidth-constrained connections (designed for SSH/Mosh)
- **Cons**:
  - Requires Firefox installation
  - Higher CPU usage than Carbonyl
  - Lower quality rendering (downscaled screenshots vs. native)
  - Layout fixes via custom CSS (less reliable)

**w3m (Traditional text browser):**
- **No JavaScript support**
- **No CSS support** (basic styling only)
- **Image support** via external viewers (w3m-img)
- **Very lightweight** and fast
- **Best for**: Reading documentation, simple HTML pages, HN/Reddit text

**lynx (Oldest text browser):**
- **No JavaScript support**
- **No images** at all
- **No CSS support**
- **Extremely lightweight**
- **Best for**: Pure text content, accessibility, ancient systems

#### Comparison Table

| Feature | Carbonyl | Browsh | w3m | lynx |
|---------|----------|--------|-----|------|
| **Images** | ✅ High quality (24-bit color blocks) | ✅ Medium quality (downscaled) | ⚠️ External viewer only | ❌ No |
| **JavaScript** | ✅ Full V8/Chromium | ✅ Full SpiderMonkey/Firefox | ❌ No | ❌ No |
| **CSS** | ✅ Full Blink support | ✅ Full Gecko support | ⚠️ Basic only | ❌ No |
| **Video/Audio** | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Performance** | ⭐⭐⭐⭐⭐ (60 FPS) | ⭐⭐⭐ (50x slower) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **CPU (idle)** | 0% | ~5-10% | <1% | <1% |
| **Binary Size** | 200MB | 11MB | <1MB | <1MB |
| **Dependencies** | None | Firefox 57+ | libgc, ncurses | ncurses |
| **Installation (NixOS)** | Not in nixpkgs | `pkgs.browsh` | `pkgs.w3m` | `pkgs.lynx` |
| **Last Update** | Feb 2023 ⚠️ | Jan 2024 ✅ | 2016 (stable) | Active (2025) |
| **AI Chat Support** | ✅ Excellent | ✅ Good | ❌ Won't work | ❌ Won't work |
| **SSH/Remote** | ✅ Yes | ✅ Optimized for it | ✅ Yes | ✅ Yes |
| **Extension Support** | ❌ No (roadmap) | ✅ Yes | ❌ No | ❌ No |

#### AI Chat Interface Compatibility

**For claude.ai / chat.openai.com:**
- **Carbonyl**: ✅ Excellent - Full JavaScript, proper rendering, interactive
- **Browsh**: ✅ Good - Works but may have layout quirks, slower
- **w3m**: ❌ Won't work - No JavaScript, modern SPAs won't load
- **lynx**: ❌ Won't work - No JavaScript, no CSS

**Recommendation for AI chat**: Use Carbonyl if available, Browsh as fallback

#### Recommended Tool

**Primary Recommendation: Browsh**

**Reasoning:**
1. **Active maintenance** - Last updated Jan 2024 vs. Carbonyl's Feb 2023
2. **Security** - Regular Firefox updates vs. stale Chromium fork
3. **Available in nixpkgs** - Easy installation via home-manager
4. **Lower risk** - Smaller codebase, easier to audit/modify
5. **Extension support** - Can add ad-blockers, user scripts
6. **Designed for remote use** - Better for SSH scenarios

**Secondary Option: Carbonyl (if needed)**
- Use for **maximum performance** when performance is critical
- Use for **local browsing only** (security concerns for remote/sensitive)
- Requires manual installation (build from source or binary download)

**Home-manager installation example:**
```nix
# For Browsh (recommended)
home.packages = with pkgs; [
  browsh
  firefox  # Required dependency
];

# For Carbonyl (manual)
# Download binary from: https://github.com/fathyb/carbonyl/releases
# Place in ~/.local/bin or add to home.packages via fetchurl
```

**Traditional browsers (w3m/lynx):**
- Keep installed for lightweight HTML viewing, documentation, simple pages
- Not suitable for modern web apps or AI chat interfaces

---

## 2. Right-Click Context Menu

### 2.1 Native Kitty Support

**Research Status:** COMPLETED

#### Findings

**Official Stance:** Kitty's developer has explicitly stated there will be **NO native context menu support**.

From GitHub Issue #7632:
- Developer quote: "No, there is going to be no context menu. kitty is for terminal power users. No power user is going to use a context menu for copy/paste, it's too inefficient."
- Issue closed as "completed" (meaning: will not implement)
- Similar requests in Issue #3825 were also rejected

**Available Native Features:**
- `mouse_map` directive: Can map any mouse button/action to kitty actions
- Copy/paste can be mapped to keyboard shortcuts
- Mouse actions support: `mouse_map right press ungrabbed <action>`
- Actions available: `copy_or_interrupt`, `paste_from_clipboard`, `mouse_click_url`, etc.

**Mouse Event Detection:**
```
mouse_map right press ungrabbed <action>
```

However, there is NO built-in action to spawn a popup menu at cursor position.

#### Limitations

- No native way to get cursor screen coordinates from within kitty
- No built-in popup/menu rendering capability
- `mouse_map` can only trigger kitty actions or launch external programs
- Cannot pass mouse coordinates to external programs directly via mouse_map

### 2.2 External Solutions

#### 2.2.1 rofi Integration ✅ RECOMMENDED

**Feasibility:** HIGH (7.5/10)

**How it Works:**
- X11/Wayland popup window switcher and menu system
- Can display custom menus via dmenu mode
- Supports positioning via `-monitor -3` flag (positions at mouse cursor)

**Implementation:**
1. Use `mouse_map right press ungrabbed` to trigger a script
2. Launch rofi with `-monitor -3` flag (appears at cursor)
3. Pass menu items via stdin (dmenu mode)
4. Execute selected action via kitty remote control

**Pros:**
- Works on both X11 and Wayland (rofi 1.7+)
- `-monitor -3` gives true context menu behavior (appears at cursor)
- Highly customizable appearance via themes
- Fast and lightweight (~100-200ms delay)

**Cons:**
- Requires external tools (rofi, xdotool for some use cases)
- Need to enable kitty remote control for some actions
- Slight delay compared to native implementation

#### 2.2.2 wofi Integration

**Feasibility:** MEDIUM

**Limitations:**
- No direct "position at cursor" option like rofi's `-monitor -3`
- Would need compositor-specific positioning
- Less flexible than rofi for context menu use case

**Recommendation:** Use rofi instead (it now supports Wayland)

#### 2.2.3 yad/zenity Integration

**Feasibility:** MEDIUM-LOW

**Limitations:**
- Heavier than rofi (GTK+ overhead)
- Slower startup time
- Menu appearance is more "dialog-like" than context menu
- Better for graphical notifications, not context menus

#### 2.2.4 KDE Plasma Integration

**Feasibility:** HIGH (for KDE users only)

**Implementation:**
- Create `.desktop` files in `~/.local/share/kservices5/ServiceMenus/`
- Trigger via DBus or custom shortcuts

**Limitation:**
- KDE-specific, won't work in other DEs
- Not directly integrated with terminal window

#### 2.2.5 Custom Kitten Approach

**Feasibility:** MEDIUM-HIGH (but NOT suitable for this use case)

**Why NOT Recommended:**
- Kittens run in overlay windows (fullscreen or similar)
- Cannot create floating popup at cursor position
- Would block entire terminal window
- Better use case: full-screen interactive tools, not popup menus

#### 2.2.6 Terminal Emulator Comparison

| Terminal | Context Menu | Implementation |
|----------|--------------|----------------|
| Konsole | Yes | Native Qt context menu |
| GNOME Terminal | Yes | Native GTK context menu |
| Alacritty | No | Philosophy similar to kitty |
| WezTerm | No | Uses launch_menu (different concept) |
| iTerm2 | Yes | Native macOS context menu |

### 2.3 Recommended Approach

**✅ RECOMMENDED: rofi + kitty remote control**

**Feasibility Rating: 7.5/10**

**Architecture:**
```
Right-click → mouse_map → shell script → rofi -dmenu -monitor -3 → kitty @ commands
```

**Implementation Steps:**

1. **Enable kitty remote control** in `kitty.conf`:
   ```
   allow_remote_control yes
   listen_on unix:/tmp/kitty-${KITTY_PID}
   ```

2. **Create context menu script** (`~/.config/kitty/context-menu.sh`):
   ```bash
   #!/bin/bash
   # Menu items
   MENU="📋 Copy\n📄 Paste\n🔗 Open URL\n📝 Edit Selection\n🔍 Search Selection"

   # Show menu at cursor position
   CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -monitor -3 \
       -theme-str 'window {width: 250px;}' -p "")

   # Execute based on choice
   case "$CHOICE" in
       *"Copy"*) kitty @ send-key ctrl+shift+c ;;
       *"Paste"*) kitty @ send-key ctrl+shift+v ;;
       *"Open URL"*) kitty @ kitten hints --type url ;;
       *"Edit Selection"*)
           SEL=$(kitty @ get-text --extent selection)
           echo "$SEL" | kitty @ launch --type overlay $EDITOR -
           ;;
       *"Search"*)
           SEL=$(kitty @ get-text --extent selection)
           xdg-open "https://google.com/search?q=$SEL"
           ;;
   esac
   ```

3. **Map right-click** in `kitty.conf`:
   ```
   mouse_map right press ungrabbed launch --type=background ~/.config/kitty/context-menu.sh
   ```

4. **Install dependencies** (home-manager):
   ```nix
   home.packages = with pkgs; [
     rofi
     xdotool  # For X11 (optional, not needed with rofi -monitor -3)
     ydotool  # For Wayland (optional, for advanced use cases)
   ];
   ```

**Security Considerations:**
- Limit remote control to socket-based (not TCP)
- Use `remote_control_password` if concerned
- Script runs with user permissions only

**Complexity Rating:**
- Implementation: 5/10 (moderate scripting)
- Maintenance: 3/10 (minimal)
- User Experience: 8/10 (near-native feel)

---

## 3. GPU & RAM Optimization

### 3.1 Kitty GPU Settings

**Research Status:** ✅ COMPREHENSIVE RESEARCH COMPLETE (2025-12-22)

#### Available Settings

| Setting | Description | Default | Impact |
|---------|-------------|---------|--------|
| `repaint_delay` | Time (ms) between screen redraws | 10 | Lower = smoother, higher CPU |
| `input_delay` | Delay (ms) before processing input | 3 | Lower = more responsive |
| `sync_to_monitor` | Wait for vsync before displaying | yes | Prevents tearing |
| `text_composition_strategy` | Font rendering mode | platform | `1.2 10` for dark themes |
| `wayland_enable_ime` | IME support on Wayland | yes | Disable for lower latency |

#### text_composition_strategy Explained

**From Official Documentation:**

| Value | Description |
|-------|-------------|
| `platform` (default) | Native rendering (Linux: `1.0 0`, macOS: `1.7 30`) |
| `legacy` | Pre-0.28 behavior (thicker dark text on light) |
| `gamma multiplier` | Custom: higher gamma = thicker text, higher % = more contrast |

**For Dracula Dark Theme:**
```conf
text_composition_strategy 1.2 10
```
- `1.2` gamma = slightly thicker than Linux default
- `10%` contrast = subtle enhancement for dark backgrounds (#282a36)

#### NVIDIA GTX 960 Specific

**System Profile:**
- GPU: NVIDIA GeForce GTX 960 (4GB VRAM)
- OpenGL: 4.6 (exceeds kitty's 3.3 requirement)
- Driver: nvidia-570.x (proprietary recommended)
- Direct rendering: Enabled

**GPU Memory Usage:**
- Single kitty window: **8 MB VRAM**
- Glyph texture atlas: ~5-8MB
- With 100 tabs: Still <1GB VRAM

**Optimized Settings for GTX 960:**
```conf
# Balanced (RECOMMENDED - good performance + stability)
repaint_delay 6              # 40% faster than default (166 FPS vs 100 FPS)
input_delay 1                # 67% faster than default
sync_to_monitor yes          # Prevent screen tearing
text_composition_strategy 1.2 10   # Better dark theme rendering
wayland_enable_ime no        # Disable IME (not using Asian input)

# Ultra Low Latency (for AI agents like Claude Code)
input_delay 0                # Maximum responsiveness
repaint_delay 3              # ~333 FPS
sync_to_monitor no           # May cause slight tearing
wayland_enable_ime no
```

**Performance Benchmarks (Official Kitty 0.33):**
| Terminal | ASCII | Unicode | CSI | Average MB/s |
|----------|-------|---------|-----|--------------|
| **kitty 0.33** | 121.8 | 105.0 | 59.8 | **134.55** |
| gnome-terminal | 33.4 | 55.0 | 16.1 | 61.83 |
| alacritty | 43.1 | 46.5 | 32.5 | 54.05 |

**Key Insight:** Kitty processes ANSI escape codes (CSI) at **59.8 MB/s** - 100x faster than xterm (0.6 MB/s). Ideal for Claude Code's heavy ANSI formatting.

**Energy vs Performance Tradeoff:**
| Setting | FPS | Latency | Energy | Tearing |
|---------|-----|---------|--------|---------|
| Default (10/3) | 100 | 13ms | Low | None |
| **Balanced (6/1)** | 166 | 7ms | Medium | None |
| Ultra (3/0) | 333 | 3ms | High | Possible |

### 3.2 RAM Optimization

#### Scrollback Buffer Deep Dive

**Key Finding from GitHub Issue #970:** Scrollback memory scales dramatically:
- Empty kitty with 64k scrollback: **50MB base**
- Filling 64k buffer: **Additional 300MB** (total 350MB)

**Memory Formula:**
```
Memory per window ≈ scrollback_lines × 0.005 MB + base_overhead (~1MB)
```

**Default Configuration Impact:**
| scrollback_lines | Memory per Window | 10 Windows | Notes |
|------------------|-------------------|------------|-------|
| 10000 (default) | ~51 MB | ~510 MB | Current setup |
| **3000 (recommended)** | ~16 MB | ~160 MB | Good for AI sessions |
| 2000 | ~11 MB | ~110 MB | Previous recommendation |
| 500 (minimal) | ~3.5 MB | ~35 MB | Very constrained |

**scrollback_pager Alternative (Official Recommendation):**
```conf
scrollback_lines 3000                    # Keep modest in-memory buffer
scrollback_pager_history_size 8          # 8MB compressed pager history (~80k lines)
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
```

**Benefits:**
- In-memory buffer: 3000 lines = ~16MB per window
- Pager storage: 8MB compressed = full session archive
- Total memory reduction: **68% savings** vs 10,000 line buffer
- With 10 windows: **350MB saved**

**Important:** Memory is allocated on-demand but doesn't shrink until window closes.

#### Memory Profiling

**Check Current Usage:**
```bash
# Per-process memory (basic)
ps aux | grep kitty

# Detailed memory map
pmap -x $(pgrep kitty)

# Most accurate: shared vs unique memory
smem -t -k -c "command pid rss pss uss" | grep kitty
```

**What to look for:**
- **RSS:** Total memory including shared libraries
- **PSS:** Proportional set size (more accurate)
- **USS:** Unique set size (true per-process usage)

#### Multiple Windows Memory Impact

**From Community Research:**
- Each kitty window (split/pane): **+10-15MB** RAM
- Each tab: **+10-20MB** RAM (includes scrollback)
- OS Window: **+50MB** base overhead

**Example (Your Workflow):**
- 1 OS window + 10 tabs + 3k scrollback each
- Memory: 50MB base + (10 × 16MB) = **210MB total**
- vs Current (10k scrollback): 50MB + (10 × 51MB) = **560MB**
- **Savings: 350MB (62%)**

### 3.3 Swap Configuration

**NixOS Swap Options:**

**Option 1: Zram (Compressed RAM swap) - RECOMMENDED**
```nix
# /etc/nixos/configuration.nix
zramSwap = {
  enable = true;
  algorithm = "zstd";       # Fast compression
  memoryPercent = 50;       # Use 50% of RAM for zram
};
```

**Option 2: Zswap (Compressed cache + disk swap)**
```nix
boot.kernelParams = [ "zswap.enabled=1" "zswap.compressor=zstd" ];
```

**Option 3: Traditional Swap File**
```nix
swapDevices = [ { device = "/swapfile"; size = 8192; } ];  # 8GB
```

**Recommendation:** Use zram - fastest, works entirely in RAM with compression.

### 3.4 Recommended Configuration

**For GTX 960 + AI Agents (Claude Code):**
```conf
# ~/.config/kitty/kitty.conf

# === GPU OPTIMIZATION ===
repaint_delay 6                      # 40% faster than default
input_delay 1                        # Optimal for responsiveness
sync_to_monitor yes                  # Prevent tearing (GTX 960 handles well)
text_composition_strategy 1.2 10     # Dracula dark theme optimization
wayland_enable_ime no                # Disable IME (lower latency)

# === RAM OPTIMIZATION ===
scrollback_lines 3000                # Enough for typical AI session
scrollback_pager_history_size 8      # 8MB compressed archive (~80k lines)
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER

# === OPTIONAL: Ultra Low Latency Mode ===
# Uncomment for maximum speed with AI agents (may cause slight tearing)
# input_delay 0
# repaint_delay 3
# sync_to_monitor no
```

### 3.5 Benchmarking Your System

**Run kitty's built-in benchmark:**
```bash
kitty +kitten __benchmark__
```

**Expected results on GTX 960:**
- ASCII throughput: **90-120 MB/s**
- Unicode: **80-100 MB/s**
- CSI (formatting): **50-70 MB/s**

**Verify GPU acceleration:**
```bash
kitty --debug-rendering

# Should show:
# [glfw info] Using GPU: NVIDIA GeForce GTX 960/PCIe/SSE2
# [glfw info] OpenGL version: 4.6.0 NVIDIA 570.xxx
```

**Monitor during AI session:**
```bash
# Add to .bashrc
alias kitty-mem='smem -t -k -c "command pid rss pss uss" | grep kitty'

# GPU usage
nvidia-smi dmon -s u
```

### 3.6 CPU Usage Comparison

**Official Kitty CPU Usage (scrolling file in less):**
| Terminal | CPU Usage |
|----------|-----------|
| **kitty** | **6-8%** |
| xterm | 5-7% (janky) |
| gnome-terminal | 15-17% |
| konsole | 29-31% |

**tab_bar.py Impact:**
- Refresh rate: 3 seconds
- CPU overhead: **~0.3%**
- Negligible compared to terminal rendering

**Complexity Rating:**
- Implementation: 2/10 (simple config changes)
- Maintenance: 1/10 (set and forget)
- User Experience: 9/10 (noticeable improvement)

---

## 4. Obsidian Integration

### 4.1 Terminal Integration Options

**Research Status:** COMPLETED

#### Obsidian URI Scheme

**Official URI Protocol:**
```
obsidian://open?vault=<vault_name>&file=<path>
obsidian://new?vault=<vault_name>&name=<filename>&content=<text>
obsidian://search?vault=<vault_name>&query=<search_term>
```

**Examples:**
```bash
# Open a specific note
xdg-open "obsidian://open?vault=MyVault&file=notes/daily"

# Create new note with content
xdg-open "obsidian://new?vault=MyVault&name=quick-note&content=$(echo 'Hello' | jq -sRr @uri)"

# Search vault
xdg-open "obsidian://search?vault=MyVault&query=TODO"
```

**Integration Script:**
```bash
#!/bin/bash
# ~/.local/bin/obsidian-open
VAULT="MyVault"
FILE="${1:-.}"
xdg-open "obsidian://open?vault=${VAULT}&file=${FILE}"
```

#### Terminal Plugins

| Plugin | Purpose | URL |
|--------|---------|-----|
| Shell commands | Run terminal commands from Obsidian | Community plugins |
| Execute Code | Run code blocks in terminal | Community plugins |
| Local REST API | HTTP API for vault access | For advanced integrations |

**Note:** Plugins work FROM Obsidian → Terminal, not reverse direction.

### 4.2 Quick Capture Methods

**Method 1: Shell Function (RECOMMENDED)**
```bash
# ~/.bashrc or ~/.zshrc
onote() {
    local vault="$HOME/.MyHome/vault"
    local inbox="$vault/Inbox.md"
    echo "- $(date +%H:%M) - $@" >> "$inbox"
    echo "Added to Obsidian Inbox"
}

# Usage
onote "Remember to check the logs"
onote "Meeting notes: project deadline moved to Friday"
```

**Method 2: Dedicated Daily Note**
```bash
daily_note() {
    local vault="$HOME/.MyHome/vault"
    local today=$(date +%Y-%m-%d)
    local note="$vault/Daily/${today}.md"

    if [[ ! -f "$note" ]]; then
        echo "# ${today}" > "$note"
        echo "" >> "$note"
    fi

    echo "- $(date +%H:%M) - $@" >> "$note"
}
```

**Method 3: FZF Selection**
```bash
note_search() {
    local vault="$HOME/.MyHome/vault"
    local selected=$(find "$vault" -name "*.md" | fzf --preview 'head -20 {}')
    [[ -n "$selected" ]] && $EDITOR "$selected"
}
```

### 4.3 Panel Overlay Options

**Key Finding:** ❌ Obsidian panel overlay is **NOT FEASIBLE**

**Why Not Possible:**
1. Obsidian is an Electron app (Chromium + Node.js)
2. Cannot be embedded in terminal windows
3. Same limitation as Firefox (see Section 1)
4. No standard protocol for embedding GUI apps in kitty

**Alternative Approaches:**

**1. Window Manager Positioning (Workaround)**
```bash
# KDE: Position Obsidian as floating window
obsidian &
sleep 1
wmctrl -r "Obsidian" -e 0,1000,50,800,900  # x,y,width,height
```

**2. File System Access (RECOMMENDED)**
- Access vault directly: `~/.MyHome/vault/`
- Use terminal editors (nvim, micro) for quick edits
- Use glow/mdcat for markdown rendering

**3. Hybrid Workflow**
```
┌──────────────────────────────────────┐
│ Kitty Terminal (Left 60%)            │ Obsidian Window (Right 40%)
│ ┌──────────────────────────────────┐ │ ┌─────────────────────────────┐
│ │ Edit notes with nvim             │ │ │ View rendered notes         │
│ │ Quick capture with onote()       │ │ │ Graph view                  │
│ │ Search with fzf                  │ │ │ Backlinks                   │
│ └──────────────────────────────────┘ │ └─────────────────────────────┘
└──────────────────────────────────────┘
```

#### Recommended Approach

**Hybrid File System + URI Integration:**

1. **Quick Capture:** Use `onote()` shell function
2. **Editing:** Terminal editor (nvim) for Markdown files directly
3. **Viewing:** Use glow/mdcat for terminal rendering
4. **Full Features:** Open Obsidian app when needed (graph, backlinks)

**Implementation:**
```bash
# ~/.bashrc additions
export OBSIDIAN_VAULT="$HOME/.MyHome/vault"

# Quick note to inbox
onote() { echo "- $(date +%H:%M) - $@" >> "$OBSIDIAN_VAULT/Inbox.md"; }

# Open note in Obsidian
oopen() { xdg-open "obsidian://open?vault=MyVault&file=$1"; }

# Render markdown in terminal
oview() { glow "$OBSIDIAN_VAULT/$1.md"; }

# Search vault
osearch() { grep -rn "$1" "$OBSIDIAN_VAULT" --include="*.md" | fzf; }
```

**Complexity Rating:**
- Implementation: 3/10 (shell functions)
- Maintenance: 2/10 (minimal)
- User Experience: 7/10 (good hybrid workflow)

---

## 5. Calendar & Plasma Integration

### 5.1 Plasma Calendar Widget

**Research Status:** COMPLETED

#### DBus Interface

**Key Finding:** ❌ No direct DBus method to open Plasma calendar popup

**Investigation Results:**
```bash
# List Plasma shell DBus interfaces
qdbus org.kde.plasmashell /PlasmaShell

# Available methods (none for calendar)
org.kde.PlasmaShell.activateLauncherMenu  # Opens app launcher
org.kde.PlasmaShell.showDesktop           # Shows desktop
```

**Why No Calendar DBus:**
- Calendar is a widget, not a standalone component
- Plasma widgets don't expose individual DBus interfaces
- System tray calendar is part of shell, not separable

#### Command Line Access

**Available Options:**

**1. Open KOrganizer (Full calendar app)**
```bash
korganizer &
```

**2. Open Merkuro (Modern KDE calendar)**
```bash
merkuro-calendar &
```

**3. Simulate click on system tray (hacky)**
```bash
# Not reliable - depends on widget position
xdotool mousemove x y click 1
```

### 5.2 Google Calendar Sync

#### Plasma Integration Methods

**Method 1: Merkuro + Akonadi (RECOMMENDED)**
```bash
# Install via home-manager
home.packages = [ pkgs.merkuro pkgs.akonadi ];
```

**Setup:**
1. Open System Settings → Online Accounts
2. Add Google account
3. Merkuro automatically syncs

**Method 2: KDE PIM Suite**
- KOrganizer for calendar
- Akonadi for sync backend
- More complex but full-featured

**Method 3: Third-party Tools**
| Tool | Description |
|------|-------------|
| gcalcli | CLI for Google Calendar |
| calcurse | TUI calendar (import via ICS) |
| khal | Terminal calendar with vdirsyncer |

**Terminal Calendar Integration:**
```bash
# gcalcli quick view
gcalcli agenda --nocolor

# khal with vdirsyncer
khal calendar today 7d
```

### 5.3 Kitty Widget Click Handling

#### Limitations

**Key Finding:** ❌ Kitty tab bar does NOT support mouse click handling for custom content

**GitHub Issue #4447 Confirmation:**
- Tab bar only supports **rendering** custom content
- **No mouse event callbacks** for custom widgets
- By design: kitty is keyboard-first terminal

**What IS Supported:**
- Clicking native tab titles (switches tabs)
- Standard window decorations

**What is NOT Supported:**
- Custom widget click handlers
- Hover events on tab bar content
- Right-click context menus on tab bar

#### Workarounds

**1. Keyboard Shortcuts (RECOMMENDED)**
```conf
# kitty.conf
map ctrl+shift+c launch --type=overlay gcalcli agenda
map f8 launch --type=background korganizer
map ctrl+alt+c launch --type=background merkuro-calendar
```

**2. F12 Panel with Calendar**
```conf
# Show today's agenda in panel
map f12 kitten panel --edge top bash -c "gcalcli agenda today; read"
```

**3. Display-Only Badge**
Show next event in tab bar (no click needed):
```python
# In tab_bar.py
def get_next_event():
    # Parse gcalcli output
    import subprocess
    result = subprocess.run(['gcalcli', 'agenda', '--nocolor', '--military'],
                          capture_output=True, text=True)
    # Extract first event...
    return "📅 Meeting 14:00"
```

#### Recommended Approach

**Hybrid: Display + Keyboard Shortcuts**

1. **Tab Bar Display:** Show date/time + optional event count
   ```
   | ... tabs ... | 📅 Dec 22 | 3 events | 14:35 |
   ```

2. **Keyboard Access:**
   - `F8` → Open full calendar (Merkuro/KOrganizer)
   - `Ctrl+Shift+C` → Quick agenda overlay
   - `Ctrl+Alt+C` → Calendar in background

3. **Google Calendar Sync:** Via Akonadi + Merkuro

**Complexity Rating:**
- Implementation: 5/10 (requires gcalcli setup)
- Maintenance: 4/10 (sync needs occasional attention)
- User Experience: 6/10 (keyboard workaround, not clickable)

---

## 6. Terminal Notifications

### 6.1 Kitty Native Support

**Research Status:** COMPLETED

#### notify Action

**OSC 99 Protocol:** Kitty's desktop notification protocol

**Built-in kitten:**
```bash
# Basic notification
kitten notify "Title" "Body message"

# With icon
kitten notify --icon firefox "Build Complete" "Your build finished successfully!"

# From Python
from kitty.boss import Boss
boss.notification_activated('title', 'body')
```

**From Any Program (via escape sequence):**
```bash
printf '\x1b]99;i=1;d=0;p=body;Title\x1b\\'
```

**Features:**
- Integrates with system notification daemon
- Supports icons (by name or path)
- Works with KDE Plasma notifications
- Can include actions (buttons)

#### command_on_bell

**Configuration:**
```conf
# kitty.conf
command_on_bell notify-send -a kitty "Terminal Bell" "Bell triggered in kitty"
enable_audio_bell no      # Disable beep
visual_bell_duration 0.3  # Flash screen
visual_bell_color #ff5555 # Dracula red
```

**Advanced Bell Handler:**
```bash
#!/bin/bash
# ~/.config/kitty/bell-handler.sh
notify-send -a kitty -i terminal "Kitty Bell" "Terminal requires attention"
paplay /usr/share/sounds/freedesktop/stereo/bell.oga &
```

### 6.2 Shell Integration

#### Long Command Detection

**Method 1: undistract-me (RECOMMENDED)**
```bash
# Install
sudo apt install undistract-me  # Debian/Ubuntu
# Or via nix
nix-shell -p undistract-me

# Enable in ~/.bashrc
source /usr/share/undistract-me/long-running.bash
notify_when_long_running_commands_finish_install
```

**Features:**
- Automatic threshold (10 seconds by default)
- Configurable via environment variables
- Works with bash and zsh

**Method 2: Custom Zsh Hooks**
```zsh
# ~/.zshrc
autoload -Uz add-zsh-hook
typeset -g _cmd_start_time

function _track_cmd_start() {
    _cmd_start_time=$EPOCHSECONDS
}

function _track_cmd_end() {
    if [[ -n $_cmd_start_time ]]; then
        local elapsed=$((EPOCHSECONDS - _cmd_start_time))
        local threshold=${NOTIFY_THRESHOLD:-30}
        if [[ $elapsed -gt $threshold ]]; then
            kitten notify "Command completed" "Took ${elapsed} seconds"
        fi
        unset _cmd_start_time
    fi
}

add-zsh-hook preexec _track_cmd_start
add-zsh-hook precmd _track_cmd_end
```

**Method 3: Bash Equivalent**
```bash
# ~/.bashrc
_notify_threshold=${NOTIFY_THRESHOLD:-30}

function _track_preexec() {
    _cmd_start=$SECONDS
}

function _track_precmd() {
    local elapsed=$((SECONDS - _cmd_start))
    if [[ $elapsed -gt $_notify_threshold && -n $_cmd_start ]]; then
        kitten notify "Command completed" "Took ${elapsed}s"
    fi
    unset _cmd_start
}

trap '_track_preexec' DEBUG
PROMPT_COMMAND="_track_precmd; $PROMPT_COMMAND"
```

#### Tools

| Tool | Description | Complexity | Integration |
|------|-------------|------------|-------------|
| **undistract-me** | Auto-notify for long commands | LOW | Bash/Zsh hooks |
| **ntfy** | Push notifications via HTTP | MEDIUM | Any command |
| **notify-send** | Local desktop notifications | LOW | System standard |
| **kitten notify** | Kitty-native notifications | LOW | Built-in |
| **pushover** | Mobile push notifications | MEDIUM | API calls |

#### Recommended Approach

**Tiered Notification System:**

**1. Quick Setup (5 minutes):**
```bash
# ~/.bashrc or ~/.zshrc
source /usr/share/undistract-me/long-running.bash
notify_when_long_running_commands_finish_install
```

**2. Enhanced Setup (Custom thresholds):**
```bash
# ~/.bashrc
export LONG_RUNNING_COMMAND_TIMEOUT=30  # Notify after 30s
export UDM_PLAY_SOUND=0                 # No sound, just visual

# Use kitten notify for consistent styling
export LONG_RUNNING_NOTIFICATION_COMMAND='kitten notify "Done" "$1 completed in $2s"'
```

**3. Build/Test Specific Notifications:**
```bash
# Aliases for common long commands
alias make='make && kitten notify "Build Success" "make completed" || kitten notify "Build Failed" "make returned error"'
alias pytest='pytest && kitten notify "Tests Passed" || kitten notify "Tests Failed"'
```

**Complexity Rating:**
- Implementation: 2/10 (undistract-me is plug-and-play)
- Maintenance: 1/10 (no maintenance needed)
- User Experience: 9/10 (seamless notifications)

---

## 7. Session Persistence

### 7.1 Kitty Session Files

**Research Status:** COMPLETED

#### Native Session Support

**Session File Format:**
```
# ~/.config/kitty/sessions/dev.session
new_tab Main
cd ~/projects/myapp
launch bash

new_tab Logs
cd ~/projects/myapp/logs
launch bash -c "tail -f app.log"

new_tab Tests
cd ~/projects/myapp
launch bash -c "pytest -v --watch"
```

**Launch with Session:**
```bash
kitty --session ~/.config/kitty/sessions/dev.session
```

**Features:**
- Define tabs, splits, and layouts
- Set working directories per pane
- Launch specific commands
- Set environment variables
- Configure window titles

#### --session Flag

**Usage Patterns:**
```bash
# Load session on startup
kitty --session dev.session

# Attach to existing or create new
kitty --single-instance --session project.session

# Override default session
kitty --session none  # Start fresh
```

**Startup Session (kitty.conf):**
```conf
# Default session on launch
startup_session ~/.config/kitty/sessions/default.session
```

### 7.2 Custom Kitten for Sessions

**Session Save Kitten:**
```python
# ~/.config/kitty/save_session.py
from kitty.boss import Boss
import json
from pathlib import Path

def main(args):
    boss = args[0]
    session_name = args[1] if len(args) > 1 else 'quicksave'
    session_dir = Path.home() / '.MyHome/Shared_Volumes/kitty-sessions-volume'
    session_dir.mkdir(parents=True, exist_ok=True)

    session_data = []
    for tab in boss.active_tab_manager.tabs:
        tab_data = {
            'title': tab.title,
            'windows': []
        }
        for window in tab.windows:
            tab_data['windows'].append({
                'cwd': str(window.child.current_cwd),
                'cmdline': window.child.cmdline,
            })
        session_data.append(tab_data)

    session_file = session_dir / f'{session_name}.json'
    with open(session_file, 'w') as f:
        json.dump(session_data, f, indent=2)

    boss.notification_activated('Session Saved', str(session_file))
```

**Load Session Helper:**
```bash
#!/bin/bash
# ~/.local/bin/kitty-load-session
SESSION_DIR="$HOME/.MyHome/Shared_Volumes/kitty-sessions-volume"
SESSION=$(ls "$SESSION_DIR"/*.session | fzf --preview 'cat {}')
[ -n "$SESSION" ] && kitty --session "$SESSION"
```

### 7.3 Full State Preservation

#### What Can Be Saved

| Component | Saveable | Method |
|-----------|----------|--------|
| Tab layout | ✅ Yes | Session file |
| Split positions | ✅ Yes | Session file |
| Working directories | ✅ Yes | Session file + shell |
| Window titles | ✅ Yes | Session file |
| Environment variables | ✅ Yes | Session file |
| Active foreground commands | ⚠️ Partial | Requires command restart |
| Scrollback history | ❌ No | Would need export first |
| Shell history | ✅ Yes | Via shell (histfile) |
| Running background processes | ❌ No | Not tied to terminal |

#### What Cannot Be Saved

**Fundamental Limitations:**

1. **Process State:** Running programs cannot be serialized
2. **Scrollback Content:** Terminal buffer not persistent
3. **SSH Sessions:** Connections must be re-established
4. **Environment Mutations:** Runtime `export` commands lost
5. **vim/nvim State:** Editor sessions need separate handling

**Workarounds:**

| Limitation | Workaround |
|------------|------------|
| Scrollback | Export via Ctrl+Shift+O before closing |
| SSH | Use mosh for persistent connections |
| vim session | `:mksession` before exit |
| env vars | Store in project `.envrc` (direnv) |

### 7.4 Storage Location

**Configured:** `~/.MyHome/Shared_Volumes/kitty-sessions-volume`

**Directory Structure:**
```
~/.MyHome/Shared_Volumes/kitty-sessions-volume/
├── default.session        # Default startup session
├── dev.session           # Development layout
├── ops.session           # Operations/monitoring
├── quicksave.json        # Last quick-save
└── archive/              # Old sessions
    └── 2025-12-22-project.session
```

**Home-Manager Configuration:**
```nix
# Ensure directory exists
home.file.".MyHome/Shared_Volumes/kitty-sessions-volume/.keep".text = "";
```

#### Recommended Approach

**Tiered Session Management:**

**1. Named Sessions (Manual):**
```bash
# Save current layout
kitty @ launch --type=background save_session.py project-name

# Load session
kitty --session ~/.../kitty-sessions-volume/project-name.session
```

**2. Quick Save/Restore:**
```conf
# kitty.conf
map ctrl+shift+s launch --type=background python3 ~/.config/kitty/save_session.py quicksave
map ctrl+shift+r launch --type=background ~/.local/bin/kitty-load-session
```

**3. Auto-Save on Exit (Advanced):**
```python
# In custom kitten triggered by exit hook
# Saves current state before kitty closes
```

**Integration with Zellij:**
```bash
# For complex session needs, delegate to zellij
zellij attach -c project-name
# Zellij handles session persistence natively
```

**Complexity Rating:**
- Implementation: 5/10 (requires Python kitten)
- Maintenance: 3/10 (session files need occasional cleanup)
- User Experience: 7/10 (manual save/restore, not automatic)

---

## 8. Document Viewing

### 8.1 PDF Viewing

**Research Status:** COMPLETED

#### Tools

| Tool | Terminal Support | Panel Support | Quality | Best For |
|------|-----------------|---------------|---------|----------|
| **termpdf.py** ⭐ | Kitty only | ❌ No | Excellent | Kitty users, academic work |
| **tdf** ⭐ | Most terminals | ❌ No | Excellent | Fast viewing, any terminal |
| **zathura** | External (GUI) | Via WM rules | Excellent | LaTeX workflow |
| **pdftotext+less** | All terminals | ❌ No | Text only | Quick extraction |

#### termpdf.py (RECOMMENDED for Kitty)

**Repository:** https://github.com/dsanson/termpdf.py

**Features:**
- Native kitty graphics protocol
- Vim-style navigation (j/k/h/l, gg/G)
- Text selection and copying
- Table of contents navigation
- Hot reloading when PDF changes
- Bibtex integration for academic workflows
- Search functionality

**Installation:**
```bash
git clone https://github.com/dsanson/termpdf.py
cd termpdf.py
pip install -r requirements.txt
pip install .
```

**Usage:**
```bash
termpdf.py document.pdf
termpdf.py -p 10 document.pdf  # Open to page 10
```

#### tdf (RECOMMENDED for Performance)

**Repository:** https://github.com/itsjunetime/tdf

**Features:**
- Rust-based, extremely fast
- Works in most modern terminals
- Asynchronous rendering
- Full-text search
- Hot reloading

**Installation:**
```bash
cargo install --git https://github.com/itsjunetime/tdf.git
# With EPUB support
cargo install --git https://github.com/itsjunetime/tdf.git --features epub
```

#### Panel/Overlay Options

**Key Finding:** ❌ Cannot embed PDF viewers directly in kitty

**Workaround: Window Manager Rules**
```bash
# Launch zathura with fixed position
zathura --title="PDF Preview" document.pdf &

# KDE window rule: Settings → Window Management → Window Rules
# Set "PDF Preview" to always-on-top, specific position/size
```

### 8.2 LaTeX Live Preview

#### Tools

| Tool | Description | Watch Mode | Complexity |
|------|-------------|------------|------------|
| **latexmk -pvc** ⭐ | Standard LaTeX automation | ✅ Built-in | Low |
| **tectonic** | Modern Rust LaTeX engine | ✅ Via `-X watch` | Low |
| **entr** | Generic file watcher | ⚠️ Manual | Very Low |

#### latexmk Workflow (RECOMMENDED)

**Basic Usage:**
```bash
latexmk -pdf -pvc document.tex
```

**Project Configuration (`.latexmkrc`):**
```perl
$pdf_mode = 1;
$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error %O %S';
$aux_dir = '.cache/latex';
$sleep_time = 1;
$view = 'none';  # Manage viewer manually
```

**Complete Workflow:**
```bash
# Terminal 1: Editor
nvim document.tex

# Terminal 2: Continuous compilation
latexmk -pdf -pvc -interaction=nonstopmode document.tex

# External: Auto-refreshing viewer
zathura document.pdf &
```

### 8.3 Markdown Rendering

#### Tools Comparison

| Tool | Features | Colors | Images | Installation |
|------|----------|--------|--------|--------------|
| **glow** ⭐ | Full rendering, paging | ✅ | ✅ Kitty | `pkgs.glow` |
| **mdcat** | Inline images | ✅ | ✅ Kitty | `pkgs.mdcat` |
| **bat** | Syntax highlight only | ✅ | ❌ | `pkgs.bat` |
| **rich-cli** | Python-based | ✅ | ❌ | `pip install rich-cli` |

#### glow (RECOMMENDED)

**Features:**
- Beautiful terminal markdown rendering
- Pager with navigation
- Supports inline images (kitty)
- Glamour-based styling

**Usage:**
```bash
glow README.md              # Render file
glow                        # Browse current directory
cat notes.md | glow -       # Render from stdin
```

**Configuration (`~/.config/glow/glow.yml`):**
```yaml
style: "dracula"
local: true
mouse: true
pager: true
width: 120
```

#### Recommended Tools

**Primary Setup:**
```bash
# NixOS/Home-manager
home.packages = with pkgs; [
  glow      # Markdown rendering
  bat       # Syntax highlighting + markdown
  mdcat     # Alternative with images
];

# Aliases
alias md='glow'
alias mdb='bat --language markdown'
```

**Integration with Obsidian:**
```bash
# View Obsidian note in terminal
oview() { glow "$HOME/.MyHome/vault/$1.md"; }
```

---

## 9. Quick Notes Widget

### 9.1 Widget Options

**Research Status:** COMPLETED

#### Display Options

**Option 1: Note Count Indicator (RECOMMENDED)**

**Format:** `📝 5 today`

**Pros:**
- Compact (10-15 characters)
- Privacy-friendly
- Motivating to see progress
- Low cognitive load

**Implementation:**
```python
# In tab_bar.py
def count_notes_today(vault_path):
    import os
    from datetime import datetime

    today = datetime.now().date()
    count = 0

    try:
        for root, dirs, files in os.walk(vault_path):
            for file in files:
                if file.endswith('.md'):
                    filepath = os.path.join(root, file)
                    mtime = datetime.fromtimestamp(os.path.getmtime(filepath)).date()
                    if mtime == today:
                        count += 1
    except Exception:
        count = 0

    return count
```

**Option 2: Last Note Snippet**

**Format:** `📝 "Meeting notes with..."`

**Pros:**
- Shows actual content
- Contextual preview

**Cons:**
- Privacy concerns if screensharing
- Needs truncation logic

**Option 3: Combined Approach**

**Format:** `📝 3 | "Meeting..."`

Balances information and brevity.

#### Integration with Obsidian

**Vault Path Configuration:**
```python
# In tab_bar.py
VAULT_PATH = os.path.expanduser('~/.MyHome/vault')
CACHE_DURATION = 60  # seconds
```

**Caching Implementation:**
```python
_notes_cache = {'time': 0, 'count': 0}

def get_notes_count():
    import time
    now = time.time()

    if now - _notes_cache['time'] < CACHE_DURATION:
        return _notes_cache['count']

    count = _count_vault_notes(VAULT_PATH)
    _notes_cache['time'] = now
    _notes_cache['count'] = count

    return count
```

**Tab Bar Widget:**
```python
def draw_notes_widget(screen, colors):
    count = get_notes_count()
    text = f"📝 {count}"

    screen.cursor.fg = colors['fg']
    screen.draw(text)

    return len(text)
```

#### Update Mechanisms

**1. Passive Updates (RECOMMENDED)**
- Widget refreshes when tab bar redraws
- 60-second cache reduces I/O
- No background processes needed

**2. Active Updates with inotify (Advanced)**
```bash
#!/bin/bash
# Watch vault and trigger refresh
inotifywait -m -r -e create,modify,delete "$VAULT" | while read FILE
do
    if [[ "$FILE" == *.md ]]; then
        # Trigger kitty refresh
        kitty @ send-text --match recent:0 '\x0c'
    fi
done
```

#### Alternative: Keybinding Approach

Instead of persistent widget, show stats on-demand:
```conf
# kitty.conf
map ctrl+shift+n launch --type=overlay --hold bash -c '
    cd ~/.MyHome/vault
    echo "Notes today: $(find . -name "*.md" -mtime 0 | wc -l)"
    echo "Notes this week: $(find . -name "*.md" -mtime -7 | wc -l)"
    echo "Total notes: $(find . -name "*.md" | wc -l)"
'
```

#### Recommended Approach

**Start Simple, Iterate:**

1. **Phase 1:** Note count widget (`📝 3 today`)
   - 60-second cache
   - Passive updates
   - Minimal code

2. **Phase 2:** Add last note title (optional)
   - Truncate to 20 chars
   - Only if screen width allows

3. **Phase 3:** Consider inotify (if needed)
   - Real-time updates
   - Only if delay is noticeable

**Quick Implementation:**
```python
# Add to existing tab_bar.py
def notes_widget(colors):
    vault = os.path.expanduser('~/.MyHome/vault')
    count = _cached_notes_count(vault)
    return f"📝 {count}", colors['purple']
```

**Complexity Rating:**
- Implementation: 4/10 (Python widget code)
- Maintenance: 2/10 (minimal)
- User Experience: 7/10 (passive updates acceptable)

---

## 10. Implementation Feasibility Matrix

| Feature | Feasibility | Effort | Native Support | External Tools | Priority |
|---------|-------------|--------|----------------|----------------|----------|
| Firefox Panel | ❌ NOT FEASIBLE | N/A | No (panel = terminal only) | None viable | SKIP |
| TUI Browser (Browsh) | ✅ Easy | 1-2 hours | No | Browsh (nixpkgs) | HIGH |
| Right-Click Menu | ✅ Medium | 4-6 hours | No (by design) | rofi -monitor -3 | HIGH |
| GPU Optimization | ✅ Easy | 1-2 hours | Yes (kitty.conf) | N/A | HIGH |
| RAM Optimization | ✅ Easy | 30 min | Yes (kitty.conf) | N/A | HIGH |
| **Tmux Integration** | ✅ Medium | 4-7 hours | Via plugins | tmux, PowerKit/tmux2k | **HIGH** |
| Obsidian Integration | ✅ Medium | 2-3 hours | No | URI scheme + shell | MEDIUM |
| Calendar Display | 🟡 Medium | 3-4 hours | No | gcalcli, Merkuro | MEDIUM |
| Calendar Clicks | ❌ NOT SUPPORTED | N/A | No (tab bar limitation) | Keyboard shortcuts | SKIP |
| Notifications | ✅ Easy | 1-2 hours | Yes (kitten notify) | undistract-me | HIGH |
| Session Persistence | ✅ Medium | 3-4 hours | Partial (--session) | Custom kitten / tmux | MEDIUM |
| Document Viewing | ✅ Easy | 2-3 hours | No | termpdf.py, tdf, glow | MEDIUM |
| Quick Notes Widget | ✅ Medium | 2-3 hours | No | Custom tab_bar.py | LOW |
| Obsidian Panel | ❌ NOT FEASIBLE | N/A | No (Electron app) | Window positioning | SKIP |

### Key Technical Limitations Discovered

| Limitation | Reason | Impact |
|------------|--------|--------|
| **Tab bar clicks** | Kitty tab bar only renders, no mouse events for custom content | No clickable widgets |
| **GUI embedding** | Kitty panel kitten only supports terminal programs | No Firefox/Obsidian overlays |
| **Plasma calendar DBus** | No method to programmatically open calendar popup | Keyboard workaround needed |
| **Browser XEmbed** | Modern browsers removed XEmbed for security | TUI browsers only alternative |

---

## 10.1 Security Considerations (Added 2025-12-22)

**⚠️ CRITICAL: Remote Control Security**

The right-click menu and session persistence features require `allow_remote_control`. Using `allow_remote_control yes` is **INSECURE**.

| Setting | Security Level | Use Case |
|---------|----------------|----------|
| `allow_remote_control no` | ✅ Secure | No remote control features |
| `allow_remote_control yes` | ❌ **INSECURE** | Any process can control kitty |
| `allow_remote_control socket-only` | ✅ **RECOMMENDED** | Only via explicit socket path |

**REQUIRED Configuration for Phase K.2:**
```conf
# kitty.conf - SECURE version
allow_remote_control socket-only
listen_on unix:/tmp/kitty-${KITTY_PID}
remote_control_password file:~/.config/kitty/.remote_password
```

**Generate password file:**
```bash
openssl rand -base64 32 > ~/.config/kitty/.remote_password
chmod 600 ~/.config/kitty/.remote_password
```

---

## 10.2 Tool Version & Security Matrix (Added 2025-12-22)

| Tool | Version | Last Update | Security Status |
|------|---------|-------------|-----------------|
| **Browsh** | v1.8.0 | Jan 2024 | ✅ Safe - Active development |
| **Carbonyl** | v0.0.3 | Feb 2023 | ❌ **OUTDATED CHROMIUM - DO NOT USE FOR SENSITIVE SITES** |
| **termpdf.py** | Latest | Ongoing | ✅ Safe - Not network-facing |
| **tdf** | v0.5.0 | Dec 3, 2025 | ✅ Safe - Very recently updated |
| **glow** | Latest | Ongoing | ✅ Safe |

**⚠️ SECURITY WARNING - Carbonyl:**
Carbonyl is a Chromium fork last updated Feb 2023. Chromium has had 50+ security patches since. **DO NOT use for browsing sensitive websites.** Use Browsh instead.

---

## 10.3 NixOS Package Availability

| Tool | In nixpkgs | Installation |
|------|------------|--------------|
| browsh | ✅ | `pkgs.browsh` + `pkgs.firefox` |
| rofi | ✅ | `pkgs.rofi` |
| glow | ✅ | `pkgs.glow` |
| zathura | ✅ | `pkgs.zathura` |
| termpdf.py | ❌ | `pip install --user git+https://github.com/dsanson/termpdf.py` |
| tdf | ❌ | `cargo install --git https://github.com/itsjunetime/tdf.git` |
| undistract-me | ❌ | Custom bash hooks (provided in Section 6) |

---

## 10.4 Revised Effort Estimates (Added 2025-12-22)

Based on developer review, original estimates were optimistic. Realistic estimates:

| Feature | Original | Realistic | Reason |
|---------|----------|-----------|--------|
| GPU/RAM Optimization | 1h | 1-2h | Testing needed |
| TUI Browser (Browsh) | 1-2h | 2-3h | Firefox config |
| Right-Click Menu | 4-6h | **6-10h** | Script debugging, security |
| Notifications | 1-2h | 1-2h | Accurate |
| Document Viewing | 2-3h | 4-6h | Multiple tools |
| Obsidian Integration | 2-3h | 2-3h | Accurate |
| Session Persistence | 3-4h | **6-8h** | Python kitten complexity |
| Quick Notes Widget | 2-3h | 4-6h | tab_bar.py debugging |

**Total: 24-36 hours** (vs original 12-17 hours)

---

## 11. Recommended Implementation Order (REVISED)

### Phase K.1 (Quick Wins) - 1-2 days

**Priority: HIGH - Immediate productivity gains**

1. **TUI Browser Installation** (1-2 hours)
   - Install Browsh via home-manager
   - Test with claude.ai and common workflows
   - Create launch alias/keybinding
   - Expected impact: Terminal-native web browsing

2. **GPU & RAM Optimization** (1-2 hours)
   - Review kitty.conf GPU settings for GTX 960
   - Optimize scrollback buffer
   - Test performance improvements
   - Expected impact: Reduced resource usage

3. **Session Persistence** (2-3 hours)
   - Configure kitty session storage location
   - Create save/restore keybindings
   - Test session recovery
   - Expected impact: Faster workflow restoration

### Phase K.2 (Medium Effort) - 3-5 days

**Priority: MEDIUM - Quality of life improvements**

4. **Terminal Notifications** (3-4 hours)
   - Configure notify action
   - Integrate with long-running commands
   - Test with KDE notification system
   - Expected impact: Better awareness of background tasks

5. **Document Viewing** (4-6 hours)
   - Install zathura (PDF), glow (Markdown)
   - Create viewer integrations
   - Test with common document types
   - Expected impact: Less context switching

6. **Right-Click Context Menu** (6-8 hours)
   - Research rofi/wofi integration
   - Design menu structure
   - Implement via keybinding
   - Expected impact: Improved discoverability

### Phase K.3 (Advanced Features) - 1-2 weeks

**Priority: LOW-MEDIUM - Enhanced integration**

7. **Obsidian Integration** (8-12 hours)
   - Implement Obsidian URI handling
   - Create quick capture workflow
   - Design terminal-friendly interface
   - Expected impact: Seamless note-taking

8. **Calendar Integration** (8-12 hours)
   - Research KDE DBus APIs
   - Implement calendar display
   - Add Google Calendar sync
   - Expected impact: Better time management

9. **Quick Notes Widget** (10-15 hours)
   - Design custom kitten
   - Implement panel integration
   - Test with Obsidian backend
   - Expected impact: Instant note capture

### Phase K.4 (Not Recommended / Deferred)

**Priority: VERY LOW - High effort, low return**

10. **Firefox Overlay Panel** - ❌ **DO NOT IMPLEMENT**
    - Technical barriers insurmountable
    - No practical path forward
    - Use TUI browsers instead
    - Alternative: External browser + workspace management

---

## Research Sources

### Browser Integration Research

1. **Kitty Panel Kitten Documentation**
   - Official docs: https://sw.kovidgoyal.net/kitty/kittens/panel/
   - Man page: https://man.archlinux.org/man/extra/kitty/kitten-panel.1.en
   - Use cases: Terminal programs as desktop backgrounds, status bars

2. **Carbonyl Browser**
   - GitHub: https://github.com/fathyb/carbonyl
   - Blog post: https://fathy.fr/carbonyl
   - Tutorial: https://www.linux-magazine.com/Issues/2023/272/Light-Browsing
   - Last release: v0.0.3 (February 2023)

3. **Browsh Browser**
   - GitHub: https://github.com/browsh-org/browsh
   - Official site: https://www.brow.sh/
   - Documentation: https://www.brow.sh/docs/introduction/
   - Last release: v1.8.3 (January 2024)

4. **Comparison Articles**
   - Carbonyl vs Browsh: https://monodes.com/predaelli/2023/02/05/browsh-and-carbonyl-the-return-of-the-terminal-browser/
   - Obsidian comparison: https://publish.obsidian.md/xybre/permalink/5430dbca-e92f-4a0a-ac37-3123dcfea743

5. **X11/Wayland Embedding Research**
   - XEmbed protocol status (deprecated in modern browsers)
   - Wayland fragmentation: https://www.semicomplete.com/blog/xdotool-and-exploring-wayland-fragmentation/
   - Window management limitations: GitHub issues on xdotool/wmctrl

6. **Kitty Graphics Protocol**
   - Documentation: https://sw.kovidgoyal.net/kitty/graphics-protocol/
   - Integrations: https://sw.kovidgoyal.net/kitty/integrations/

7. **Right-Click Context Menu Research**
   - Kitty Issue #7632 (Context Menu Request - Rejected): https://github.com/kovidgoyal/kitty/issues/7632
   - Kitty Issue #3825 (Mouse Interaction): https://github.com/kovidgoyal/kitty/issues/3825
   - Kitty Actions Documentation: https://sw.kovidgoyal.net/kitty/actions/
   - Kitty Configuration: https://sw.kovidgoyal.net/kitty/conf/
   - Custom Kittens Documentation: https://sw.kovidgoyal.net/kitty/kittens/custom/
   - rofi Documentation: https://davatorium.github.io/rofi/1.7.3/rofi.1/
   - rofi GitHub: https://github.com/davatorium/rofi
   - xdotool mouse position detection: StackOverflow answers and man pages
   - yad/zenity comparison: https://unix.stackexchange.com/questions/270782/is-there-a-program-that-will-launch-a-configurable-context-menu
   - KDE Plasma service menus: https://develop.kde.org/docs/apps/dolphin/service-menus/

---

---

## 12. Tmux Integration with Kitty (Added 2025-12-22)

### 12.1 Executive Summary

**Research Status:** ✅ COMPREHENSIVE RESEARCH COMPLETE

**User Requirements Captured:**
- Keep kitty tabs/splits as primary (superior to tmux)
- Use tmux for session persistence (local + remote)
- Use tmux as second status bar for SRE/DevOps stats
- Status bar at **bottom** with **Dracula theme**
- Full git details (branch, ahead/behind, staged/unstaged)
- Full remote context (hostname, IP, connection time, kubectl context)

### 12.2 Philosophical Tension

**Kitty Author's Position:** The kitty creator considers tmux an "anti-pattern" since kitty provides native multiplexing features.

**Community Reality:** Many users successfully run tmux inside kitty for:
- Session persistence (local and remote)
- Cross-machine consistency
- Remote SSH session management
- Status bar #2 for monitoring

### 12.3 Recommended Integration Pattern

**Architecture: Kitty-First with Selective Tmux**

```
Kitty (Primary Interface)
├── Tabs and splits for local work
├── Window management
├── Visual features (GPU, themes)
└── Tab bar #1 (SRE metrics)

Tmux (Secondary, Targeted)
├── Session persistence (resurrect/continuum)
├── Remote SSH sessions
└── Status bar #2 (git, remote, DevOps stats)
```

**Use Kitty For:**
- Local tabs and window management
- Splits for side-by-side viewing
- Native OS integration (clipboard, mouse)
- Font rendering and ligatures
- GPU acceleration

**Use Tmux For:**
- Session persistence (tmux-resurrect + continuum)
- Remote SSH session management
- Secondary status bar with DevOps stats
- Cross-platform consistency

### 12.4 Performance Impact

**From Kitty's Official Benchmarks:**
| Terminal | Average MB/s | Performance |
|----------|--------------|-------------|
| alacritty | 54.05 | Baseline |
| alacritty+tmux | 24.73 | **-54%** |

**Why Tmux Adds Overhead:**
1. Extra layer of terminal emulation
2. Tmux's own escape code parsing
3. Double buffering (kitty → tmux → application)
4. Tmux's redraw logic introduces latency

**Practical Impact:** Measurable but rarely noticeable for typical DevOps work (kubectl, terraform, git).

### 12.5 Status Bar Options

#### Option 1: PowerKit (RECOMMENDED for SRE/DevOps)

**Repository:** `fabioluciano/tmux-powerkit`
**Status:** Actively maintained (Dec 2024)
**Plugins:** 37+ built-in

**Relevant Plugins for SRE/DevOps:**

| Category | Plugins |
|----------|---------|
| **System** | cpu, memory, gpu, disk, loadavg, temperature, network |
| **DevOps** | kubernetes (context+namespace), terraform, docker, cloud (AWS/GCP/Azure) |
| **Git** | git (branch + dirty + dynamic colors) |
| **Remote** | ssh, hostname, vpn, ping |

**Configuration Example:**
```tmux
set -g @plugin 'fabioluciano/tmux-powerkit'
set -g @powerkit_theme 'tokyo-night'  # Or dracula
set -g @powerkit_plugins 'git,kubernetes,cpu,memory,network,hostname'
```

**Pros:**
- Most comprehensive for DevOps
- Smart caching system (configurable TTL)
- 15 themes included
- Interactive selectors (kubectl context, terraform workspace)

**Cons:**
- Heavier than alternatives
- Many features you may not need

#### Option 2: tmux2k (Lighter Alternative)

**Repository:** `2KAbhishek/tmux2k`
**Status:** Actively maintained (Dec 2024)
**Plugins:** 20 plugins

**Configuration Example:**
```tmux
set -g @plugin '2kabhishek/tmux2k'
set -g @tmux2k-theme 'onedark'
set -g @tmux2k-left-plugins "session git cpu ram"
set -g @tmux2k-right-plugins "battery network time"
```

**Pros:**
- Simpler, more focused
- Good theming support (catppuccin, gruvbox, onedark)
- Less overhead

**Cons:**
- Fewer DevOps-specific plugins (no kubernetes, terraform)
- Less interactive features

### 12.6 User's Specific Requirements (Refined via Q&A 2025-12-22)

**Bar Position:** Bottom (traditional)

#### Feature Split Strategy
| Context | Splits | Tmux Usage |
|---------|--------|------------|
| **Local work** | Kitty splits only | Session persistence + status bar |
| **Remote SSH** | Tmux splits | Full tmux features |

#### SSH Auto-Tmux Behavior
- **Always attach/create** - SSH automatically runs `tmux attach || tmux new`
- Works with both production and development servers
- Must prevent nested tmux sessions

#### Status Bar Layout (Refined)
```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│ [session] │ 󰣀 server01 (192.168.1.10) ↑45d 2h15m │ 󰠳 CPU 45% │ ⎈ gke-eu/prod/default │  main ↓3↑2 +3~2 │
└─────────────────────────────────────────────────────────────────────────────────────┘
LEFT ──────────────────────────────────────────────────────────────────────────── RIGHT
```

**NO time widget** - kitty tab bar handles time display

#### Git Information (Right Side)
```
 main ↓3↑2 +3~2-1
```
| Component | Display | Color |
|-----------|---------|-------|
| Branch | `main` | Cyan (clean) / Orange (dirty) |
| Behind remote | `↓3` | Yellow |
| Ahead of remote | `↑2` | Green |
| Staged | `+3` | Green |
| Modified | `~2` | Yellow |
| Deleted | `-1` | Red |

#### Remote Information (Full Context)
```
󰣀 server01 (192.168.1.10) ↑45d 2h15m
```
| Component | Icon | Example | Purpose |
|-----------|------|---------|---------|
| Hostname | 󰣀 | `server01` | Know which server |
| IP address | () | `192.168.1.10` | Network identification |
| Server uptime | ↑ | `45d` | Stability indicator |
| Session time | - | `2h15m` | How long connected |

#### Kubernetes Information (Full Detail)
```
⎈ gke-eu/prod/default
```
| Component | Example | Notes |
|-----------|---------|-------|
| Cluster | `gke-eu` | From kubeconfig cluster name |
| Context | `prod` | Current kubectl context |
| Namespace | `default` | Current namespace |

**Color Coding for K8s:**
- Production contexts → Red background
- Staging contexts → Yellow/Orange
- Development contexts → Green

#### CPU Widget (Minimal Overlap)
- **Only CPU shown in tmux** - kitty handles RAM, Load, etc.
- Provides remote server context when SSH'd
- Hidden or shows local CPU when working locally

#### Local Behavior
When working locally (not SSH):
- Show local hostname
- Show local kubectl context (if configured)
- Show local git info
- Show local CPU (optional)

**Visual Style:** Dracula theme to match kitty

### 12.7 NixOS Home-Manager Configuration

**Basic Setup:**
```nix
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;

    plugins = with pkgs; [
      # Session persistence (ORDER MATTERS!)
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }

      # Status bar plugins
      tmuxPlugins.cpu
      tmuxPlugins.battery
    ];

    extraConfig = ''
      # Tmux configuration
      set -g prefix C-a
      bind C-a send-prefix

      # Mouse support
      set -g mouse on

      # Status bar position
      set-option -g status-position bottom

      # Enable window titles for kitty detection
      set-option -g set-titles on
      set-option -g set-titles-string "tmux:#S:#I:#W"

      # Reduce update frequency
      set -g status-interval 5
    '';
  };
}
```

**⚠️ Critical: Plugin Ordering**
Plugin order is critical. Status bar themes/plugins must come **before** resurrect/continuum.

**Correct Order:**
1. Theme plugins (catppuccin, powerkit, tmux2k)
2. Status bar content plugins
3. tmux-resurrect
4. tmux-continuum

### 12.8 Kitty Keybinding Forwarding

**From Aron Griffis blog (2024-12-08):**

When tmux is detected via window title, forward keybindings:

```conf
# kitty.conf - Forward keybindings when tmux detected
map --when-focus-on title:tmux super+n send_text all \x01n
map --when-focus-on title:tmux super+p send_text all \x01p

# Normal kitty behavior when not in tmux
map super+n next_tab
map super+p previous_tab
```

This allows seamless keyboard use - kitty shortcuts work normally, but forward to tmux when you're in a tmux session.

### 12.9 Dracula Theme Configuration

**Dracula Colors for Tmux:**
```tmux
# Dracula colors
set -g @dracula-colors "pink cyan green orange red purple yellow bg fg comment selection"

# Or manual Dracula palette:
# Background: #282a36
# Current Line: #44475a
# Selection: #44475a
# Foreground: #f8f8f2
# Comment: #6272a4
# Cyan: #8be9fd
# Green: #50fa7b
# Orange: #ffb86c
# Pink: #ff79c6
# Purple: #bd93f9
# Red: #ff5555
# Yellow: #f1fa8c
```

**Apply to Status Bar:**
```tmux
set -g status-style "bg=#282a36,fg=#f8f8f2"
set -g status-left-style "bg=#44475a,fg=#f8f8f2"
set -g status-right-style "bg=#44475a,fg=#f8f8f2"
```

### 12.10 Performance Optimization

**Cache Configuration:**
```tmux
# PowerKit example
set -g @powerkit_plugin_cpu_cache_ttl '3'       # CPU: 3s
set -g @powerkit_plugin_git_cache_ttl '10'      # Git: 10s
set -g @powerkit_plugin_memory_cache_ttl '5'    # Memory: 5s
set -g @powerkit_plugin_kubernetes_cache_ttl '15' # K8s: 15s
set -g @powerkit_plugin_network_cache_ttl '5'   # Network: 5s

# Global status update
set -g status-interval 5
```

**Minimize Active Plugins:**
Only enable plugins you actually use - each plugin = extra script execution.

**Use Compiled Tools:**
Prefer `tmux-mem-cpu-load` (C++) over bash scripts for system stats.

### 12.11 Workflow Recommendation

**Local Development (Pure Kitty):**
- Use kitty tabs/splits
- No tmux needed
- Maximum performance

**Persistent Work:**
```bash
# Start tmux session for persistent work
tmux new -s work
```

**Remote SSH:**
```bash
# Always use tmux for remote
ssh server -t "tmux attach || tmux new"
```

### 12.12 Comparison: Tmux Bar vs Enhanced Kitty Tab Bar

| Aspect | Tmux Status Bar | Kitty Tab Bar Enhancement |
|--------|-----------------|---------------------------|
| **Session Persistence** | ✅ Native (resurrect/continuum) | ❌ Would need separate solution |
| **Remote SSH** | ✅ Works seamlessly | ❌ Doesn't transfer to remote |
| **Performance** | ⚠️ Some overhead | ✅ Native speed |
| **Setup Complexity** | ✅ Plugin ecosystem exists | ❌ Write Python from scratch |
| **DevOps Plugins** | ✅ PowerKit: 37+ ready-made | ❌ Implement each manually |
| **Maintenance** | ✅ Community maintained | ❌ You maintain it |

**Verdict:** For session persistence + SRE stats, tmux status bar is the clear winner.

### 12.13 Implementation Steps

**Phase 1: Basic Setup (1-2 hours)**
1. Install tmux via Home-Manager with resurrect plugin
2. Configure basic keybindings
3. Test session persistence

**Phase 2: Status Bar (2-3 hours)**
1. Install PowerKit or tmux2k
2. Configure plugins (git, kubernetes, system stats)
3. Apply Dracula theme
4. Test caching performance

**Phase 3: Integration (1-2 hours)**
1. Configure kitty keybinding forwarding
2. Create workflow aliases
3. Test local vs remote scenarios

**Total Estimated Time:** 4-7 hours

### 12.14 SSH Auto-Attach/Create Patterns (Deep Dive Research)

**Research Date:** 2025-12-22
**Agent:** SSH Auto-Tmux Patterns Researcher

#### 12.14.1 Approach Comparison

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| **SSH Config RemoteCommand** | Declarative, works with kitty ssh kitten | Breaks git/scp if global, needs separate entries | NixOS/Home-Manager users |
| **Bashrc Auto-Attach** | Server-side, any client works | Modify remote server, lockout risk | Team-wide tmux |
| **Bash Function Wrapper** | Simple, no server changes | Shell-specific, no kitty ssh kitten | Quick alias |

#### 12.14.2 RECOMMENDED: SSH Config with RemoteCommand

**Home-Manager Configuration:**
```nix
programs.ssh = {
  enable = true;
  controlMaster = "auto";
  controlPath = "~/.ssh/sockets/%r@%h:%p";
  controlPersist = "10m";

  matchBlocks = {
    # Tmux-enabled aliases (use: ssh prod-tmux)
    "prod-tmux" = {
      hostname = "production.example.com";
      user = "admin";
      extraOptions = {
        RequestTTY = "yes";
        RemoteCommand = "tmux new-session -A -s prod";
      };
    };

    "dev-tmux" = {
      hostname = "dev.example.com";
      user = "developer";
      extraOptions = {
        RequestTTY = "yes";
        RemoteCommand = "tmux new-session -A -s dev";
      };
    };

    # Regular connections (git push, scp work)
    "prod" = {
      hostname = "production.example.com";
      user = "admin";
    };

    "dev" = {
      hostname = "dev.example.com";
      user = "developer";
    };
  };
};
```

**Usage Pattern:**
- `kitten ssh prod-tmux` → Connect with tmux auto-attach
- `kitten ssh prod` → Regular connection for git/scp
- `git push origin main` → Works with plain "prod" host

#### 12.14.3 Nested Tmux Prevention

**Critical Check (all approaches must use):**
```bash
# Simple check
[[ -z "$TMUX" ]]

# Full interactive check
[[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]
```

**Explanation:**
- `$TMUX` is set when inside tmux session
- `$SSH_TTY` confirms SSH connection
- `[[ $- =~ i ]]` ensures interactive shell (protects scp)

#### 12.14.4 Alternative: Server-Side Bashrc

**Place in remote `~/.bashrc`:**
```bash
# Detect interactive SSH session with no existing tmux
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  tmux attach-session -t ssh_session || tmux new-session -s ssh_session
fi
```

**Safe version with exit on detach:**
```bash
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  tmux attach-session -t "$USER" || tmux new-session -s "$USER"
  exit  # Disconnect SSH when detaching tmux
fi
```

**Recovery if locked out:**
```bash
ssh -t user@host bash --norc
# or
ssh -t user@host sh
```

#### 12.14.5 Session Naming Conventions

| Style | Command | Example |
|-------|---------|---------|
| By hostname | `tmux new -A -s $(hostname -s)` | `prod-server` |
| By user | `tmux new -A -s $USER` | `mitsos` |
| By purpose | `tmux new -A -s prod-mon` | `prod-mon` |
| SSH config token | `tmux new -A -s %n` | Whatever you typed |

#### 12.14.6 Kitty SSH Kitten Integration

**Compatible Approach:**
```nix
programs.ssh.matchBlocks."remote" = {
  hostname = "example.com";
  extraOptions = {
    RequestTTY = "yes";
    RemoteCommand = "tmux new-session -A -s kitty";
  };
};
```

**Note:** Bash function wrappers do NOT work with kitty's ssh kitten (it wraps the ssh command itself).

#### 12.14.7 Complete Home-Manager Example

```nix
{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/sockets/%r@%h:%p";
    controlPersist = "10m";

    matchBlocks = {
      # Production with tmux
      "prod-*-tmux" = {
        hostname = "prod-*.example.com";
        user = "admin";
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "tmux new-session -A -s prod";
        };
      };

      # Development with tmux
      "dev-*-tmux" = {
        hostname = "dev-*.example.com";
        user = "developer";
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "tmux new-session -A -s dev";
        };
      };

      # Plain connections for automation
      "prod-*" = {
        hostname = "prod-*.example.com";
        user = "admin";
      };

      "dev-*" = {
        hostname = "dev-*.example.com";
        user = "developer";
      };
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      bind-key S command-prompt -p "New session:" "new-session -A -s '%%'"
      bind-key J command-prompt -p "Join session:" "switch-client -t '%%'"
    '';
  };
}
```

### 12.15 Kubectl Context Display Patterns (Deep Dive Research)

**Research Date:** 2025-12-22
**Agent:** Kubectl Context Widget Researcher

#### 12.15.1 Recommended kubectl Parsing Approach

**Primary Method: kubectl config view with jsonpath**
```bash
# Get current context
kubectl config current-context

# Get current namespace (handles empty = default)
NS=$(kubectl config view --minify -o jsonpath='{..namespace}')
NS=${NS:-default}

# Get cluster name
kubectl config view --minify -o jsonpath='{.clusters[0].name}'

# All in one call
kubectl config view --minify -o 'go-template={{range .contexts}}{{.name}}/{{.context.cluster}}/{{.context.namespace}}{{end}}'
```

#### 12.15.2 Plugin Comparison

| Plugin | Repository | Stars | Features | Best For |
|--------|------------|-------|----------|----------|
| **kube-tmux** | jonmosco/kube-tmux | 378 | Context+namespace, color customization, TPM | Simplicity |
| **tmux-kubectx** | Tony-Sol/tmux-kubectx | 6 | Separate vars, full format control, yq support | Flexibility |
| **powerline-k8s** | j4ckofalltrades/powerline-k8s | - | Python powerline segment | Powerline users |

#### 12.15.3 RECOMMENDED: tmux-kubectx

**Configuration:**
```tmux
set -g @plugin "tony-sol/tmux-kubectx"
set -g @kubectx-format "%{cluster}/%{context}:%{namespace}"
set -g status-right '#[bg=blue]#{kubectx_context}:#[bg=red]#{kubectx_namespace}#[default]'
```

**Available Variables:**
- `#{kubectx_context}` - Current context name
- `#{kubectx_cluster}` - Cluster name
- `#{kubectx_namespace}` - Current namespace
- `#{kubectx_user}` - User name
- `#{kubectx_full}` - Combined format string

#### 12.15.4 Alternative: kube-tmux

**Installation (TPM):**
```tmux
set -g @plugin 'jonmosco/kube-tmux'
# Format: default_fg context_color namespace_color
set -g status-right "#(/bin/bash $HOME/.tmux/kube-tmux/kube.tmux 250 red cyan)"
```

**Cluster Name Truncation:**
```bash
# ~/.bashrc or function
function get_cluster_short() {
    echo "$1" | cut -d . -f1
}
export KUBE_TMUX_CLUSTER_FUNCTION=get_cluster_short
```

#### 12.15.5 Environment Color Coding

**Recommended Color Scheme:**
```bash
get_context_color() {
    local context="$1"
    case "$context" in
        *prod*|*production*)
            echo "colour196"  # bright red
            ;;
        *stg*|*staging*)
            echo "colour226"  # bright yellow
            ;;
        *dev*|*development*)
            echo "colour40"   # bright green
            ;;
        minikube|kind-*|docker-desktop)
            echo "colour33"   # blue
            ;;
        *)
            echo "colour250"  # default gray
            ;;
    esac
}
```

**Tmux Color Variables:**
```tmux
# Production - RED (danger)
set -g @k8s_prod_fg "colour196"
set -g @k8s_prod_bg "colour234"

# Staging - YELLOW (warning)
set -g @k8s_staging_fg "colour226"
set -g @k8s_staging_bg "colour234"

# Development - GREEN (safe)
set -g @k8s_dev_fg "colour40"
set -g @k8s_dev_bg "colour234"

# Local (minikube/kind) - BLUE
set -g @k8s_local_fg "colour33"
set -g @k8s_local_bg "colour234"
```

#### 12.15.6 Interactive Context Switching

**Tmux Key Bindings with Popup:**
```tmux
# Context selector
bind-key C-k display-popup -E "kubectx"

# Namespace selector
bind-key C-n display-popup -E "kubens"

# Custom fzf-based selector
bind-key K run-shell "tmux display-popup -E 'kubectl config get-contexts -o name | fzf | xargs kubectl config use-context'"
```

**Note:** Tmux status bar elements are NOT directly clickable. Use key bindings instead.

#### 12.15.7 Performance & Caching

**Issue:** kubectl calls are slow (100-300ms each)

**Recommended Cache Strategy (TTL-based):**
```bash
CACHE_FILE="/tmp/kube-tmux-cache-$$"
CACHE_TTL=5  # seconds

if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c%Y "$CACHE_FILE"))) -lt $CACHE_TTL ]]; then
    cat "$CACHE_FILE"
else
    kubectl config view --minify -o jsonpath='{..namespace}' > "$CACHE_FILE"
    cat "$CACHE_FILE"
fi
```

**Performance Comparison:**
| Method | Latency |
|--------|---------|
| kubeconfig parsing | ~50ms |
| kubectl command | ~100-300ms |
| yq parsing | ~20-30ms |

**Recommended Settings:**
```tmux
set -g status-interval 5  # Balance freshness vs performance
```

#### 12.15.8 Custom Color Script

**Full Implementation:**
```bash
#!/bin/bash
# ~/.config/tmux/scripts/k8s-status.sh

CACHE_FILE="/tmp/k8s-status-$$"
CACHE_TTL=5

get_k8s_info() {
    local context=$(kubectl config current-context 2>/dev/null || echo "N/A")
    local cluster=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}' 2>/dev/null | cut -d. -f1)
    local namespace=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
    namespace=${namespace:-default}

    # Determine color
    local color="colour250"
    case "$context" in
        *prod*) color="colour196" ;;
        *stg*|*staging*) color="colour226" ;;
        *dev*) color="colour40" ;;
        minikube|kind-*) color="colour33" ;;
    esac

    echo "#[fg=$color]⎈ ${cluster}/${context}:${namespace}#[default]"
}

# Cache logic
if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c%Y "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $CACHE_TTL ]]; then
    cat "$CACHE_FILE"
else
    get_k8s_info | tee "$CACHE_FILE"
fi
```

#### 12.15.9 NixOS/Home-Manager Integration

```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kubectl
    kubectx  # includes kubens
    yq-go    # faster parsing
  ];

  programs.tmux.extraConfig = ''
    # K8s context with caching
    set -g status-right "#(~/.config/tmux/scripts/k8s-status.sh)"
    set -g status-interval 5

    # Interactive switching
    bind-key K display-popup -E -w 80% -h 60% "kubectx"
    bind-key N display-popup -E -w 80% -h 60% "kubens"
  '';
}
```

### 12.16 Tmux Status Bar Plugin Deep Comparison

**Research Date:** 2025-12-22
**Agent:** PowerKit/tmux2k Deep Dive Researcher

#### 12.16.1 PowerKit vs tmux2k Summary

| Feature | PowerKit | tmux2k |
|---------|----------|--------|
| **Plugins** | 37+ | 20 |
| **Themes** | 15 (including Dracula) | 6 |
| **K8s Support** | ✅ Native | ❌ Need custom |
| **Git Support** | ✅ Full details | ✅ Basic |
| **Terraform** | ✅ | ❌ |
| **Docker** | ✅ | ❌ |
| **Cloud (AWS/GCP)** | ✅ | ❌ |
| **Caching** | ✅ Configurable TTL | ⚠️ Limited |
| **Setup Complexity** | Medium | Simple |
| **Performance** | Heavier | Lighter |

#### 12.16.2 PowerKit Plugin Categories

**System Monitoring:**
- `cpu` - CPU usage percentage
- `memory` - RAM usage
- `gpu` - GPU usage (NVIDIA/AMD)
- `disk` - Disk usage
- `loadavg` - Load average
- `temperature` - System temp
- `network` - Network throughput

**DevOps/SRE:**
- `kubernetes` - Context + namespace
- `terraform` - Workspace
- `docker` - Container stats
- `cloud` - AWS/GCP/Azure account

**Development:**
- `git` - Branch + dirty state + dynamic colors

**Remote:**
- `ssh` - SSH indicator
- `hostname` - Machine name
- `vpn` - VPN status
- `ping` - Latency indicator

#### 12.16.3 PowerKit Configuration

```tmux
set -g @plugin 'fabioluciano/tmux-powerkit'
set -g @powerkit_theme 'dracula'
set -g @powerkit_plugins 'git,kubernetes,cpu,hostname'

# Cache TTL per plugin
set -g @powerkit_plugin_cpu_cache_ttl '3'
set -g @powerkit_plugin_git_cache_ttl '10'
set -g @powerkit_plugin_kubernetes_cache_ttl '15'
```

#### 12.16.4 tmux2k Configuration

```tmux
set -g @plugin '2kabhishek/tmux2k'
set -g @tmux2k-theme 'onedark'
set -g @tmux2k-left-plugins "session git"
set -g @tmux2k-right-plugins "cpu ram"
set -g @tmux2k-group "session,git"  # Compact related widgets
```

#### 12.16.5 Standalone Tools

**gitmux - Dedicated Git Status:**
- Repository: arl/gitmux
- Highly customizable via YAML
- Very low overhead
- Better than plugin git in most cases

**tmux-mem-cpu-load - System Stats:**
- Repository: thewtex/tmux-mem-cpu-load
- Written in C++ (fast!)
- CPU, RAM, load average
- Preferred over bash-based alternatives

#### 12.16.6 User's Final Configuration Recommendation

Based on Q&A requirements:
- Context-dependent splits (kitty local, tmux remote)
- Full git details on right side
- Full k8s context with color coding
- CPU only for remote context
- No time widget (kitty handles it)

**Recommended Stack:**
1. **Framework:** PowerKit (for k8s and DevOps widgets)
2. **Git:** gitmux standalone (better customization)
3. **System:** tmux-mem-cpu-load (fast C++ binary)
4. **SSH auto-attach:** SSH Config RemoteCommand approach

**Final Status Bar Layout:**
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ [session] │ 󰣀 server (IP) ↑uptime │ 󰠳 CPU% │ ⎈ cluster/ctx:ns │  branch ↓↑ +~- │
└─────────────────────────────────────────────────────────────────────────────────┘
LEFT ──────────────────────────────────────────────────────────────── RIGHT
```

### 12.17 Q&A Round 2 - Extended Requirements (2025-12-22)

**Q&A Session Date:** 2025-12-22
**Purpose:** Refine tmux configuration with extended features

#### User Preferences Captured

| Question | User Answer | Implication |
|----------|-------------|-------------|
| **Auto-start on kitty** | Manual only | Tmux ONLY for remote SSH, local kitty stays pure |
| **Extra widgets** | Docker/containers | Add Docker widget with resource usage |
| **Session management** | Hybrid approach | Project-based + context-based sessions |
| **Visual style** | Left rounded | Browser tab-like appearance |
| **Docker info** | Resource usage | Show count + total CPU/RAM |
| **Session naming** | Full descriptive | `work-dissertation`, `infra-prod`, `ssh-server01` |
| **Segment style** | Left rounded | Rounded start, flat end (like tabs) |
| **Persistence** | Full persistence | Auto-restore ALL on reboot |

### 12.18 Docker Container Widget (Deep Dive)

**Research Date:** 2025-12-22
**Agent:** Docker tmux Widget Researcher

#### 12.18.1 Existing Plugins Analysis

**tmux-docker-status** (stonevil/tmux-docker-status):
- ❌ Only shows container count
- ❌ No CPU/RAM metrics
- ❌ No caching (slow)
- ❌ Last updated 2018

**Verdict:** No existing plugin meets requirements. Custom script needed.

#### 12.18.2 RECOMMENDED: Custom Script with Caching

**Output Format:**
```
🐳 5 ↑12.3% 512MB
```

**Complete Implementation:**
```bash
#!/usr/bin/env bash
# ~/.config/tmux/scripts/docker-stats.sh

CACHE_FILE="/tmp/tmux-docker-stats-cache"
CACHE_TTL=5

get_docker_stats() {
  # Check docker availability
  if ! command -v docker &> /dev/null; then
    echo "🐳 N/A"
    return
  fi

  # Check docker daemon
  if ! docker info &> /dev/null 2>&1; then
    echo "🐳 ●"
    return
  fi

  # Get running container count
  local count=$(docker ps -q 2>/dev/null | wc -l)

  if [[ $count -eq 0 ]]; then
    echo "🐳 0"
    return
  fi

  # Get stats in one call
  local stats=$(docker stats --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | tail -n +2)

  # Sum CPU percentages
  local cpu=$(echo "$stats" | awk -F'%' '{sum+=$1} END {printf "%.1f", sum}')

  # Sum memory (handle MiB)
  local mem=$(echo "$stats" | grep -oP '\d+(\.\d+)?(?=MiB)' | awk '{sum+=$1} END {printf "%.0f", sum}')

  # Format output
  echo "🐳 ${count} ↑${cpu}% ${mem}MB"
}

# Use cache if fresh
if [[ -f "$CACHE_FILE" ]]; then
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [[ $age -lt $CACHE_TTL ]]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# Update and display
result=$(get_docker_stats)
echo "$result" > "$CACHE_FILE"
echo "$result"
```

#### 12.18.3 Docker Compose Detection (Optional)

```bash
detect_compose_project() {
  if [[ -f "docker-compose.yml" ]] || [[ -f "compose.yaml" ]]; then
    local project=$(basename "$PWD" | tr '[:upper:]' '[:lower:]')
    local containers=$(docker ps --filter "label=com.docker.compose.project=$project" -q 2>/dev/null | wc -l)
    if [[ $containers -gt 0 ]]; then
      echo "📦 $project:$containers"
    fi
  fi
}
```

#### 12.18.4 Performance Considerations

| Command | Latency |
|---------|---------|
| `docker ps -q` | ~50-100ms |
| `docker stats --no-stream` | ~200-500ms |
| Cache read | ~1ms |

**Recommendation:** 5-second cache TTL optimal for SRE work

### 12.19 Rounded Segment Styling (Deep Dive)

**Research Date:** 2025-12-22
**Agent:** Rounded Segment Styling Researcher

#### 12.19.1 Nerd Font Powerline Characters

**Left Rounded (Tab-like):**
- `` (\uE0B4) - Left rounded separator (segment start)
- `` (\uE0B6) - Right rounded separator (segment end)

**Standard Powerline (reference):**
- `` (\uE0B0) - Right triangle (solid)
- `` (\uE0B2) - Left triangle (solid)

**Alternative Styles:**
- Angled: `\uE0B8`, `\uE0B9`
- Flames: `\uE0C0`, `\uE0C1`
- Pixelated: `\uE0C6`

#### 12.19.2 Catppuccin Rounded Style (RECOMMENDED)

```tmux
set -g @plugin 'catppuccin/tmux'
set -g @catppuccin_flavor "mocha"  # Closest to Dracula
set -g @catppuccin_window_status_style "rounded"

# Window separators
set -g @catppuccin_window_left_separator ""
set -g @catppuccin_window_middle_separator " █"
set -g @catppuccin_window_right_separator " "

# Status separators
set -g @catppuccin_status_left_separator ""
set -g @catppuccin_status_right_separator "█"
```

#### 12.19.3 Dracula with Rounded Powerline

```tmux
set -g @plugin 'dracula/tmux'
set -g @dracula-show-powerline true
set -g @dracula-show-edge-icons true
set -g @dracula-show-left-sep
set -g @dracula-show-right-sep
set -g @dracula-transparent-powerline-bg true
```

#### 12.19.4 Manual Dracula Rounded Config

```tmux
# Dracula colors
set -g status-style "bg=#282a36,fg=#f8f8f2"

# Window format with rounded segments
set -g window-status-format "#[fg=#282a36,bg=#44475a]#[fg=#f8f8f2,bg=#44475a] #I #W #[fg=#44475a,bg=#282a36]"
set -g window-status-current-format "#[fg=#282a36,bg=#bd93f9]#[fg=#282a36,bg=#bd93f9,bold] #I #W #[fg=#bd93f9,bg=#282a36]"

# Status left with rounded edge
set -g status-left "#[fg=#282a36,bg=#50fa7b,bold]  #S #[fg=#50fa7b,bg=#282a36]"
```

### 12.20 Hybrid Session Management (Deep Dive)

**Research Date:** 2025-12-22
**Agent:** Session Management Researcher

#### 12.20.1 Tool Comparison

| Tool | Language | Stars | Best For |
|------|----------|-------|----------|
| **sesh** | Go | 1.5k | Smart auto-naming, zoxide integration |
| **smug** | Go | 790 | Zero deps, fast, simple |
| **tmuxp** | Python | 4.4k | Stable, complex configs |
| **tmuxinator** | Ruby | 13.3k | Most features, large community |

**RECOMMENDED:** sesh + fzf + zoxide

#### 12.20.2 Session Naming Convention

**Format:** `{category}-{descriptor}`

| Session Name | Purpose |
|--------------|---------|
| `work-dissertation` | Dissertation project |
| `work-homelab` | Homelab infrastructure |
| `infra-prod` | Production monitoring |
| `infra-staging` | Staging environment |
| `ssh-server01` | SSH to server01 |
| `ssh-gke-cluster` | SSH to k8s node |

#### 12.20.3 Sesh Configuration

```toml
# ~/.config/sesh/sesh.toml

dir_length = 1
blacklist = ["scratch", "tmp"]

[[session]]
name = "work-dissertation 📚"
path = "~/Documents/dissertation"
startup_command = "nvim"

[[session]]
name = "infra-prod 🏭"
path = "~/"
startup_command = "ssh admin@prod-server"

[[session]]
name = "ssh-server01 🖥️"
path = "~/"
startup_command = "ssh user@server01"
```

#### 12.20.4 Tmux Session Switcher Keybinding

```tmux
# Sesh with fzf popup
bind-key "T" run-shell "sesh connect \"$(
  sesh list --icons | fzf-tmux -p 80%,70% \
    --no-sort --ansi --border-label ' sesh ' --prompt '⚡  '
)\""

# Quick last session switch
bind-key "C-j" run-shell "sesh last"
```

### 12.21 Full Persistence Configuration (Deep Dive)

**Research Date:** 2025-12-22
**Agent:** Full Persistence Researcher

#### 12.21.1 What Gets Persisted

**✅ Fully Restored:**
- All sessions, windows, panes with exact layouts
- Working directories for each pane
- Active/alternative session states
- Zoomed pane states

**⚠️ Configurable Restoration:**
- vim/neovim sessions (with strategy option)
- SSH connections (reconnects, not resumes)
- htop, psql, mysql, sqlite3
- Custom programs via `@resurrect-processes`

**❌ Cannot Restore:**
- Shell history (use shell config)
- Environment variables (re-export in rc)
- Running command output
- Sudo tickets

#### 12.21.2 Critical: Plugin Ordering

**WRONG (breaks continuum):**
```nix
plugins = [
  tmuxPlugins.resurrect
  tmuxPlugins.continuum
  tmuxPlugins.dracula  # Theme AFTER = BROKEN
];
```

**CORRECT:**
```nix
plugins = [
  tmuxPlugins.dracula      # Themes FIRST
  tmuxPlugins.resurrect    # Then resurrect
  tmuxPlugins.continuum    # MUST BE LAST
];
```

#### 12.21.3 Complete NixOS Configuration

```nix
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;
    prefix = "C-a";
    mouse = true;

    plugins = with pkgs; [
      # 1. Resurrect for session persistence
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-processes 'ssh "~kubectl" "~k9s" "~htop"'
        '';
      }

      # 2. Continuum (MUST BE LAST)
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      set -g status on  # REQUIRED for continuum
      set -g status-position bottom
      set -g base-index 1
      setw -g pane-base-index 1
    '';
  };
}
```

#### 12.21.4 NixOS Path Fuzzy Matching

**Problem:** NixOS programs have `/nix/store/` paths

**Solution:** Use `~` for fuzzy match
```nix
# Instead of 'nvim' (won't match /nix/store/.../nvim)
set -g @resurrect-processes '"~nvim->nvim"'
```

#### 12.21.5 Manual Save/Restore

- `prefix + Ctrl-s` - Save environment
- `prefix + Ctrl-r` - Restore environment

### 12.22 Updated Implementation Phases

Based on Q&A Round 2, implementation expands to:

**Phase 1: SSH Auto-Attach (1 hour)**
- Configure SSH matchBlocks
- Test nested tmux prevention

**Phase 2: Basic Tmux + Persistence (2 hours)**
- Install tmux with resurrect + continuum
- Test full persistence (save/kill/restore)

**Phase 3: Visual Styling (1-2 hours)**
- Configure rounded segments (Catppuccin or Dracula)
- Apply left-rounded tab style

**Phase 4: Status Bar Widgets (2-3 hours)**
- Docker widget with caching
- K8s context with color coding
- Git status (right side)

**Phase 5: Session Management (1-2 hours)**
- Install sesh + fzf
- Configure session templates
- Add keybindings

**Total Estimated Time:** 7-10 hours

### 12.23 Sources (Extended)

**Original Sources:**
- Aron Griffis blog: kitty+tmux integration (2024-12-08)
- Andrew Haust: From tmux to kitty migration
- awesome-tmux: Plugin list (rothgar/awesome-tmux)
- fabioluciano/tmux-powerkit: 37+ plugins
- 2KAbhishek/tmux2k: Lightweight alternative
- jonmosco/kube-tmux: K8s status for tmux
- Tony-Sol/tmux-kubectx: Flexible k8s context
- arl/gitmux: Git status for tmux
- thewtex/tmux-mem-cpu-load: Fast system stats
- NixOS Home-Manager: tmux/ssh configuration examples

**Q&A Round 2 Sources:**
- stonevil/tmux-docker-status: Docker plugin analysis
- catppuccin/tmux: Rounded segment styling
- dracula/tmux: Powerline configuration
- joshmedeski/sesh: Session management
- tmux-plugins/tmux-resurrect: Persistence docs
- tmux-plugins/tmux-continuum: Auto-save docs
- Nerd Fonts: Powerline Extra Symbols
- NixOS Home-Manager: Advanced tmux config

---

**Research Compiled By:** Dimitris Tsioumas (via Claude Code)
**Last Updated:** 2025-12-22 (Q&A Round 2 Complete)
**Research Duration:** ~3 hours (expanded with Q&A Round 2)
**Sources Consulted:** 40+ web pages, official documentation, GitHub repositories
