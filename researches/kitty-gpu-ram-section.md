## 3. GPU & RAM Optimization

### 3.1 Kitty GPU Settings

**Research Status:** COMPLETED

#### Available Settings

Kitty uses **OpenGL for GPU-accelerated rendering**. All GPU-related configuration happens through `kitty.conf`:

**Performance Tuning Options:**

1. **repaint_delay** (default: 10ms)
   - Controls delay between screen updates
   - Lower values = higher FPS but more CPU/GPU usage
   - Range: 2-20ms recommended
   - Impact: Directly affects rendering smoothness

2. **input_delay** (default: 3ms)
   - Delay before processing input from child programs
   - Lower values = lower latency
   - Minimum: 0ms (for ultra-low latency)
   - Impact: Affects perceived typing responsiveness

3. **sync_to_monitor** (default: yes)
   - Synchronizes rendering with monitor refresh rate
   - `yes`: Uses vsync, eliminates tearing
   - `no`: Allows faster updates but may cause screen tearing
   - Impact: When disabled, can reduce latency by ~3-5ms

4. **text_composition_strategy** (default: platform-dependent)
   - `platform`: Uses native platform text rendering (macOS CoreText, etc.)
   - `legacy`: Uses older pre-0.28 rendering method
   - Impact: Affects text appearance and potentially performance
   - Note: `legacy` mode had issues with transparency on light backgrounds

**OpenGL Backend:**
- Kitty **requires OpenGL 3.3 or higher**
- Uses GLFW for window creation and OpenGL context management
- No alternative rendering backends available (OpenGL only)
- Keeps glyph cache in **VRAM** for performance

**Environment Variables (Advanced):**
- `__GL_SYNC_TO_VBLANK`: NVIDIA-specific vsync control (0=off, 1=on)
- Can force software rendering via Mesa env vars if GPU issues occur
- Generally not needed with proper drivers

#### NVIDIA GTX 960 Specific

**Hardware Specs:**
- GPU: NVIDIA GTX 960
- VRAM: 4GB
- OpenGL Support: **4.6** (exceeds kitty's 3.3 requirement)
- Architecture: Maxwell (GM204)

**Driver Recommendations:**

1. **Use Proprietary NVIDIA Drivers**
   - Nouveau (open-source) has ~50% performance vs proprietary
   - Nouveau lacks full OpenGL 4.6 support
   - For terminal emulator: proprietary drivers strongly recommended
   - Performance difference is significant for GPU-accelerated apps

2. **Driver-Specific Settings**
   - NVIDIA drivers handle OpenGL well out-of-the-box
   - No special NVIDIA Control Panel tweaks needed for terminals
   - Flipping/UBB handled automatically by driver
   - Explicit sync supported (may have issues on very new drivers)

**Known Issues with GTX 960:**
- Generally excellent compatibility with kitty
- Some transparency issues reported on Plasma 6 + Wayland (driver-specific)
- Potential crash with explicit sync on bleeding-edge drivers (rare)
- Workaround: Downgrade driver if crashes occur with eglSwapBuffers

**Optimal Settings for GTX 960:**

```conf
# Performance-focused (low latency)
repaint_delay 2
input_delay 0
sync_to_monitor no

# Balanced (recommended)
repaint_delay 6
input_delay 2
sync_to_monitor yes

# Quality-focused (eliminate tearing)
repaint_delay 10
input_delay 3
sync_to_monitor yes
```

### 3.2 RAM Optimization

**Research Status:** COMPLETED

#### Scrollback Buffer Impact

**Primary Memory Consumer:**

Kitty keeps **entire scrollback buffer in RAM** (not paged to disk). This is the main RAM usage factor.

**Memory Calculation:**
- Default: `scrollback_lines 2000`
- Each line consumes memory for:
  - Character data
  - Color/formatting attributes
  - Unicode handling overhead
- Typical usage: **~12-15MB per window** with default scrollback
- With large scrollback (50,000 lines): Can exceed **100-200MB per window**

**Scrollback-Related Options:**

1. **scrollback_lines** (default: 2000)
   ```conf
   scrollback_lines 2000    # Default, ~12-15MB per window
   scrollback_lines 10000   # High, ~30-50MB per window
   scrollback_lines 50000   # Very high, ~100-200MB per window
   scrollback_lines -1      # Unlimited (NOT RECOMMENDED)
   ```

2. **scrollback_pager_history_size** (default: 0)
   - Memory allocated for pager (Ctrl+Shift+H)
   - Maximum: 4GB
   - 0 = uses same as scrollback_lines
   - Impact: Additional memory when using pager

**Clearing Scrollback:**
- `clear_terminal scrollback active` - Clears scrollback buffer
- Modern kitty (post-2021): **Does NOT free memory immediately**
- Memory is reused but not released to OS
- Only way to truly free memory: Close and reopen window/tab

**Recommended Settings for RAM-Conscious Usage:**

```conf
# Low RAM usage
scrollback_lines 1000
scrollback_pager_history_size 0

# Balanced
scrollback_lines 2000
scrollback_pager_history_size 0

# Power user (more RAM)
scrollback_lines 5000
scrollback_pager_history_size 10000
```

#### Font Caching and Other Memory Overhead

**Font Cache:**
- Kitty caches rendered glyphs in **VRAM** (not RAM)
- Minimal RAM impact from font rendering
- GPU handles font atlas/texture storage
- No configuration options for font cache size

**Per-Window/Tab Overhead:**
- Each window: **~12-15MB baseline** (default config)
- Each tab: **~8-12MB** (shares some resources with parent window)
- Window decorations, title bars: negligible
- Shell integration: **~1-2MB** per shell instance

**Other Memory Factors:**
- `background_opacity`: Minimal impact (~1-2MB for compositing buffers)
- Images/graphics protocol: Stored in VRAM, not RAM
- SSH/remote connections: No additional overhead beyond normal terminal

**Total Memory Estimation:**
```
RAM per window = 12MB (base) + (scrollback_lines * 0.005MB) + (pager * 0.005MB)

Examples:
- 1 window, 2000 lines: ~22MB
- 1 window, 10000 lines: ~62MB
- 10 windows, 2000 lines each: ~220MB
- 10 windows, 10000 lines each: ~620MB
```

#### Memory Profiling

**Tools for Measuring Kitty Memory:**

1. **htop** (simple, visual)
   ```bash
   htop -p $(pgrep kitty)
   ```
   - Look at RES (resident) column
   - Shows per-process memory

2. **smem** (accurate, PSS-based)
   ```bash
   smem -c "name pid pss rss uss" -P kitty -k
   ```
   - PSS (Proportional Set Size): Most accurate
   - USS (Unique Set Size): Memory unique to process
   - Accounts for shared libraries correctly

3. **ps** (quick check)
   ```bash
   ps aux | grep kitty
   ```
   - RSS column shows resident memory
   - Less accurate than smem

**Benchmark Results (from kitty author):**
- 12 windows, default config: **~150MB total**
- Per-window average: **~12.5MB**
- Conclusion: "Pretty reasonable" memory usage

### 3.3 Swap Configuration

**Research Status:** COMPLETED

#### Understanding Swap and Terminal Apps

**Why Swap Matters for Terminals:**
- Long-running terminal sessions accumulate scrollback
- Inactive terminal windows ideal candidates for swapping
- Can reduce pressure on physical RAM
- Trade-off: Swapped terminals slow on re-focus

**Swap Options on NixOS:**

1. **Traditional Swap (File or Partition)**
   ```nix
   swapDevices = [{
     device = "/var/lib/swapfile";
     size = 16*1024; # 16GB
   }];
   ```

2. **Zram Swap (Compressed RAM)**
   ```nix
   zramSwap.enable = true;
   zramSwap.algorithm = "zstd";  # or lz4, lzo
   zramSwap.memoryPercent = 50;  # 50% of RAM
   ```
   - Compresses swapped pages in RAM
   - No disk I/O
   - Good for systems with sufficient RAM
   - **Not recommended to use with zswap simultaneously**

3. **Zswap (Compressed Cache + Disk Swap)**
   ```nix
   boot.kernelParams = [
     "zswap.enabled=1"
     "zswap.compressor=lz4"
     "zswap.max_pool_percent=20"
   ];

   # Still need backing swap
   swapDevices = [{ device = "/swapfile"; size = 8192; }];
   ```

#### Swappiness Tuning

**What is Swappiness:**
- Controls how aggressively kernel swaps pages
- Range: 0-200 (default: 60)
- Lower = keep in RAM longer
- Higher = swap more aggressively

**For Terminal-Heavy Workload:**

```nix
boot.kernel.sysctl = {
  "vm.swappiness" = 10;  # Conservative, prefer RAM
};
```

**Recommended Values:**
- `1-10`: Minimal swapping, only under memory pressure
- `10-30`: Conservative, suitable for desktop use
- `60`: Default, balanced
- `100+`: Aggressive swapping (rarely useful)

**Note on Application-Specific Swap:**
- **Cannot force specific apps** (like kitty) to prefer swap
- Swappiness is **system-wide**
- Kernel decides what to swap based on page access patterns
- Inactive kitty windows naturally get swapped out

#### Recommended Configuration

**For GTX 960 System with Memory Concerns:**

```nix
# configuration.nix

# Option 1: Zram only (recommended for 8GB+ RAM)
zramSwap = {
  enable = true;
  algorithm = "zstd";
  memoryPercent = 50;
};

# Option 2: Traditional swap (recommended for 4-8GB RAM)
swapDevices = [{
  device = "/var/lib/swapfile";
  size = 8192;  # 8GB
}];

# Option 3: Zswap + backing swap (advanced)
swapDevices = [{
  device = "/var/lib/swapfile";
  size = 8192;
}];
boot.kernelParams = [
  "zswap.enabled=1"
  "zswap.compressor=lz4"
  "zswap.max_pool_percent=20"
];

# Swappiness tuning (applies to all options)
boot.kernel.sysctl = {
  "vm.swappiness" = 10;
};
```

**Home-Manager Kitty Configuration (Optimized):**

```nix
# home-manager kitty config
programs.kitty = {
  enable = true;

  settings = {
    # GPU Settings for GTX 960
    repaint_delay = 6;
    input_delay = 2;
    sync_to_monitor = "yes";

    # RAM Optimization
    scrollback_lines = 2000;  # Balance: 2000 lines = ~10MB overhead
    scrollback_pager_history_size = 0;

    # Optional: Ultra-low latency (higher GPU/CPU usage)
    # repaint_delay = 2;
    # input_delay = 0;
    # sync_to_monitor = "no";
  };

  keybindings = {
    # Quickly clear scrollback to reclaim memory
    "ctrl+shift+delete" = "clear_terminal scrollback active";
  };
};
```

**Monitoring Swap Usage:**
```bash
# Check swap status
swapon --show

# Watch swap usage in real-time
watch -n 1 swapon --show

# Detailed swap stats
cat /proc/swaps

# Check memory and swap together
free -h
```

---
