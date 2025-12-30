# KDE Plasma 6 Desktop Optimization Research

**Date:** 2025-12-30
**Topic:** KDE Plasma 6 Desktop Optimization for RAM, CPU, and GPU Usage
**Target System:** NixOS with 16GB RAM, Intel Skylake i7-6700K, NVIDIA GTX 960 (Proprietary Driver)
**Author:** Dimitris Tsioumas

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [KWin/Compositor Optimization](#kwincompositor-optimization)
3. [Plasmashell Memory Optimization](#plasmashell-memory-optimization)
4. [Baloo File Indexer Optimization](#baloo-file-indexer-optimization)
5. [KDE Services Optimization](#kde-services-optimization)
6. [NixOS/Home-Manager Integration](#nixoshome-manager-integration)
7. [Complete Configuration Examples](#complete-configuration-examples)
8. [Sources](#sources)

---

## Executive Summary

This research document provides comprehensive optimization strategies for KDE Plasma 6 desktop environment, specifically targeting systems with moderate hardware (16GB RAM, older Skylake CPU, GTX 960 GPU). The optimizations focus on:

- **KWin Compositor:** OpenGL 3.1 with EGL backend for NVIDIA, proper VSync configuration
- **Plasmashell:** Widget optimization, theme considerations, memory leak prevention
- **Baloo:** Aggressive exclusion patterns, content indexing disabled, CPU priority adjustment
- **KDE Services:** Disabling Akonadi, optimizing KRunner, reducing background services
- **NixOS Integration:** plasma-manager declarative configuration with home-manager

### Key Findings

| Component | Expected RAM (Optimized) | Key Optimization |
|-----------|--------------------------|------------------|
| Plasmashell | 400-600 MB | Minimal widgets, Breeze theme |
| KWin | 150-250 MB | OpenGL 3.1, reduced effects |
| Baloo | ~100 MB (post-indexing) | Exclusions, basic indexing only |
| Total Desktop | ~1.5-2 GB | Full optimization applied |

---

## KWin/Compositor Optimization

### Current Status: OpenGL vs Vulkan

As of late 2025, **Vulkan support for KWin is still under development**. The roadmap exists but implementation is incomplete. For GTX 960 (Maxwell architecture), **OpenGL 3.1 remains the recommended backend**.

> **Note:** Vulkan support will provide benefits like async compute, better multi-GPU support, and more predictable driver behavior, but it's not production-ready yet.

### Recommended Compositor Settings

#### 1. OpenGL Backend Configuration

```ini
# ~/.config/kwinrc
[Compositing]
Backend=OpenGL
GLCore=true
GLPreferBufferSwap=a
GLTextureFilter=1
HiddenPreviews=5
OpenGLIsUnsafe=false
WindowsBlockCompositing=true
AnimationDurationFactor=0.5
```

**Settings Explained:**
- `GLCore=true`: Use OpenGL 3.1+ core profile (better performance on modern GPUs)
- `GLPreferBufferSwap=a`: Automatic buffer swap detection (best for most systems)
- `GLTextureFilter=1`: Smooth filtering (0=crisp, 1=smooth, 2=accurate - avoid 2 for performance)
- `HiddenPreviews=5`: Off-screen preview method
- `WindowsBlockCompositing=true`: Allow games to disable compositor
- `AnimationDurationFactor=0.5`: Faster animations (snappier feel, less CPU)

#### 2. VSync Configuration

For NVIDIA GTX 960 with proprietary drivers:

```bash
# Environment variables for KWin NVIDIA optimization
export KWIN_OPENGL_INTERFACE=egl
export __GL_YIELD=USLEEP
# OR use triple buffer (pick one, not both):
# export KWIN_TRIPLE_BUFFER=1

# Force frame timing (helps with latency)
export KWIN_EXTRA_RENDER_TIME=1500
```

**Important:** Do NOT combine `__GL_YIELD=USLEEP` with `KWIN_TRIPLE_BUFFER=1`. Choose one approach.

#### 3. NVIDIA-Specific Optimizations

```bash
# Set max frames allowed (reduces input latency)
export __GL_MaxFramesAllowed=1

# For X11 with NVIDIA (if using ForceFullCompositionPipeline)
# Note: Don't combine with KWin's OpenGL - it doubles the work
```

**nvidia-settings approach (alternative):**
- Enable "Force Full Composition Pipeline" in nvidia-settings for tear-free
- OR use KWin's compositor - not both

#### 4. Desktop Effects Performance

Recommended effects to keep (low overhead):
- Blur (with reduced settings)
- Slide for desktop switching
- Fade for windows

Effects to disable for performance:
- Wobbly Windows
- Magic Lamp
- Desktop Cube (use Grid instead)
- Translucency (for non-focused windows)

```ini
# ~/.config/kwinrc
[Plugins]
blurEnabled=true
contrastEnabled=false
slideEnabled=true
fadeEnabled=true
wobblywindowsEnabled=false
magiclampEnabled=false
cubeEnabled=false
```

#### 5. Frame Timing Optimization (Plasma 6.3.3+)

```bash
# Microseconds before frame rendering starts
# Higher = earlier rendering (helps with slow drivers)
# Default: 1500
export KWIN_EXTRA_RENDER_TIME=2000
```

---

## Plasmashell Memory Optimization

### Expected Memory Usage

| Configuration | RAM Usage |
|---------------|-----------|
| Stock Plasma (many widgets) | 800-1200 MB |
| Optimized (minimal widgets) | 400-600 MB |
| With Kvantum theme | ~500-600 MB |
| Memory leak scenario | Can exceed several GB |

### Plasma 6.5/6.6 Memory Improvements

Recent Plasma versions (6.5, 6.6) have implemented significant memory optimizations:
- **Plasma 6.5:** Reduced wallpaper copies in memory
- **Plasma 6.6:** ~100 MB reduction by smarter wallpaper unloading

### Widget Optimization

**High-impact widgets to avoid/limit:**
- Network/CPU/IO bandwidth monitors (historically leak-prone, improved but still heavy)
- Fancy clocks with many features
- System monitoring widgets with frequent updates

**Recommended minimal panel setup:**
1. Application Menu (or Kickoff)
2. Task Manager (Icons-only)
3. System Tray
4. Digital Clock (without calendar events)

### Theme Considerations

| Theme Type | Memory Impact | Recommendation |
|------------|---------------|----------------|
| Breeze (default) | Low | Recommended |
| Kvantum themes | Low-Medium | Good choice |
| Heavy animated themes | High | Avoid |
| Custom QML themes | Variable | Test carefully |

### Panel Configuration

```ini
# Reduce panel overhead
# - Use fewer panels (1 is optimal)
# - Avoid floating panels (slightly more overhead)
# - Keep panel simple and minimal
```

### Memory Leak Workaround

If memory usage grows excessively over time:

```bash
# Restart plasmashell (save work first!)
plasmashell --replace &

# Clear swap if needed
sudo swapoff -a && sudo swapon -a
```

**Note:** This is a workaround. Check [bugs.kde.org](https://bugs.kde.org) for known issues.

---

## Baloo File Indexer Optimization

### Understanding Baloo

Baloo is KDE's file indexer. Initial indexing is CPU/IO intensive, but post-indexing resource usage is minimal. The key is proper configuration.

### Recommended Configuration

```ini
# ~/.config/baloofilerc
[General]
dbVersion=2
index hidden folders=false
only basic indexing=true
first run=false

# Exclude filters (case-sensitive!)
exclude filters=*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*,*.obj,*.a,*.orig,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,lzo,*.tar,*.gz,*.bz2,*.xz,*.zst,*.zip,*.rar,*.7z,*.iso,*.dmg,*.img,*.vmdk,*.qcow2,*.vdi,node_modules,.git,.svn,.hg,__pycache__,.cache,Cache,cache,.npm,.yarn,.cargo,target,build,dist,out,.gradle,.m2,.sbt

# Exclude folders (use $HOME for home directory)
exclude folders[$e]=$HOME/Downloads,$HOME/.cache,$HOME/.local/share/Trash,$HOME/VMs,$HOME/.rustup,$HOME/.cargo,$HOME/node_modules,$HOME/.npm,$HOME/.yarn,$HOME/go/pkg,$HOME/.gradle,$HOME/.m2,$HOME/.nix-defexpr,$HOME/.nix-profile,$HOME/Games,/tmp,/var,/run,/snap,/nix/store
```

### Key Settings Explained

| Setting | Recommendation | Reason |
|---------|----------------|--------|
| `only basic indexing=true` | **Enable** | Disables content indexing (huge performance gain) |
| `index hidden folders=false` | **Enable** | Skips .config, .local, etc. |
| `exclude filters` | **Extensive list** | Skip build artifacts, archives, caches |
| `exclude folders` | **Large directories** | Skip Downloads, VMs, package caches |

### Baloo Management Commands

```bash
# Check status (Plasma 6)
balooctl6 status

# Monitor current indexing
balooctl6 monitor

# Disable Baloo completely
balooctl6 disable

# Re-enable
balooctl6 enable

# Purge and rebuild index
balooctl6 purge
balooctl6 enable

# Check index size
balooctl6 indexSize
```

### CPU Priority Adjustment

If Baloo still causes performance issues during indexing:

```bash
# Lower priority (nice value 19 = lowest priority)
renice 19 -p $(pgrep baloo_file)
renice 19 -p $(pgrep baloo_file_extractor)
```

Or use System Monitor GUI: Right-click process -> Change Priority -> Very Low

### File Size Limits

- Baloo automatically skips text files over 10 MB
- Large binary files are metadata-indexed only (with basic indexing)

---

## KDE Services Optimization

### Disabling Akonadi

Akonadi is the PIM (Personal Information Management) backend. If you don't use KMail, KOrganizer, or KAddressBook, you can disable it.

**Step 1: Disable calendar events in Digital Clock**
- Right-click clock -> Configure Digital Clock
- Calendar tab -> Uncheck "Show calendar events"

**Step 2: Prevent Akonadi auto-start**
```bash
# Create override desktop file
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/org.kde.akonadi.server.desktop << 'EOF'
[Desktop Entry]
Hidden=true
EOF
```

**Step 3: Stop running Akonadi**
```bash
akonadictl stop
```

### Optimizing KRunner

KRunner is the launcher (Alt+Space/Alt+F2). Disable unused plugins:

1. Open KRunner (Alt+F2)
2. Click configure icon (left side)
3. Disable plugins you don't use:
   - Browser Tabs
   - Konsole Sessions
   - Recent Documents (if not needed)
   - Software Center
   - Spell Checker
   - Unit Converter
   - Web Search Keywords

**Keep enabled:**
- Applications
- Calculator
- Command Line
- Desktop Sessions
- System Settings

### Background Services to Consider Disabling

| Service | Purpose | Disable if... |
|---------|---------|---------------|
| `kactivitymanagerd` | Activity tracking | Don't use Activities |
| `kded6` modules | Various services | Selective disable |
| `baloo_file` | File indexing | Use alternative search |
| `akonadi` | PIM data | Don't use KDE PIM |

**Disable specific kded modules:**
```bash
# List running kded modules
qdbus6 org.kde.kded6 /kded org.kde.kded6.loadedModules

# Disable module (example: remotenotifier)
cat > ~/.config/kded6rc << 'EOF'
[Module-remotenotifier]
autoload=false
EOF
```

---

## NixOS/Home-Manager Integration

### Enabling Plasma 6 on NixOS

```nix
# /etc/nixos/configuration.nix (or your system config)
{
  services.xserver.enable = true;  # Optional for Wayland-only
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # NVIDIA-specific
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;  # Use proprietary driver for GTX 960
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
```

### Plasma-Manager Setup

Add plasma-manager to your flake inputs:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }: {
    homeConfigurations."mitsio" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        plasma-manager.homeManagerModules.plasma-manager
        ./home.nix
      ];
    };
  };
}
```

### Using rc2nix Migration Tool

Plasma-manager includes `rc2nix` to convert existing KDE configs to Nix:

```bash
# Run from plasma-manager source
nix run github:nix-community/plasma-manager#rc2nix

# Or capture before/after changes
# 1. Save current config
cp ~/.config/kwinrc ~/.config/kwinrc.before
# 2. Make changes in GUI
# 3. Compare
nix run github:nix-community/plasma-manager#rc2nix > after.nix
```

---

## Complete Configuration Examples

### Full plasma-manager Configuration

```nix
# home.nix
{ config, pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    # Optional: Full declarative mode (WARNING: backs up and replaces configs)
    # overrideConfig = true;

    #
    # === KWin Compositor Settings ===
    #
    configFile = {
      "kwinrc" = {
        "Compositing" = {
          "Backend" = "OpenGL";
          "GLCore" = true;
          "GLPreferBufferSwap" = "a";
          "GLTextureFilter" = 1;
          "HiddenPreviews" = 5;
          "OpenGLIsUnsafe" = false;
          "WindowsBlockCompositing" = true;
          "AnimationDurationFactor" = 0.5;
        };

        "Plugins" = {
          "blurEnabled" = true;
          "contrastEnabled" = false;
          "slideEnabled" = true;
          "fadeEnabled" = true;
          "wobblywindowsEnabled" = false;
          "magiclampEnabled" = false;
        };

        # Titlebar buttons
        "org.kde.kdecoration2" = {
          "ButtonsOnLeft" = "M";
          "ButtonsOnRight" = "IAX";
        };
      };

      #
      # === Baloo Configuration ===
      #
      "baloofilerc" = {
        "General" = {
          "only basic indexing" = true;
          "index hidden folders" = false;
        };
        "Basic Settings" = {
          "Indexing-Enabled" = true;
        };
      };

      #
      # === KRunner Configuration ===
      #
      "krunnerrc" = {
        "Plugins" = {
          "baloosearchEnabled" = true;
          "appstreamEnabled" = false;
          "browserhistoryEnabled" = false;
          "browsertabsEnabled" = false;
          "konsabordsessionsEnabled" = false;
          "recentdocumentsEnabled" = false;
          "spellcheckEnabled" = false;
          "unitconverterEnabled" = false;
          "webshortcutsEnabled" = false;
        };
      };

      #
      # === Digital Clock (disable Akonadi trigger) ===
      #
      "plasma-org.kde.plasma.desktop-appletsrc" = {
        "Containments" = {
          # Panel containment - adjust based on your setup
        };
      };
    };

    #
    # === Desktop Effects ===
    #
    kwin = {
      effects = {
        blur = {
          enable = true;
          strength = 6;
          noiseStrength = 0;
        };
        slideBack.enable = true;
        translucency.enable = false;
        wobblyWindows.enable = false;
      };

      titlebarButtons = {
        left = [ "on-all-desktops" ];
        right = [ "minimize" "maximize" "close" ];
      };
    };

    #
    # === Shortcuts ===
    #
    shortcuts = {
      kwin = {
        "Overview" = "Meta+Tab";
        "Window Maximize" = "Meta+Up";
        "Window Minimize" = "Meta+Down";
      };
    };

    #
    # === Workspace Behavior ===
    #
    workspace = {
      clickItemTo = "select";  # Single click to select
      lookAndFeel = "org.kde.breeze.desktop";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
    };

    #
    # === Fonts ===
    #
    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
    };
  };

  #
  # === Environment Variables ===
  #
  home.sessionVariables = {
    # KWin NVIDIA optimizations
    KWIN_OPENGL_INTERFACE = "egl";
    __GL_YIELD = "USLEEP";
    __GL_MaxFramesAllowed = "1";

    # Optional: Frame timing adjustment
    # KWIN_EXTRA_RENDER_TIME = "2000";

    # Qt/Plasma optimizations
    QT_QPA_PLATFORMTHEME = "kde";
  };
}
```

### Baloo Exclusions via Home-Manager

```nix
# baloo-config.nix
{ config, ... }:

{
  # Baloo exclude folders
  xdg.configFile."baloofilerc".text = ''
    [General]
    dbVersion=2
    index hidden folders=false
    only basic indexing=true
    first run=false
    exclude filters=*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*,*.obj,*.a,*.orig,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.tar,*.gz,*.bz2,*.xz,*.zst,*.zip,*.rar,*.7z,*.iso,node_modules,.git,.svn,.hg,__pycache__,.cache,Cache,cache,.npm,.yarn,.cargo,target,build,dist,out,.gradle,.m2,.sbt
    exclude filters version=9
    exclude folders[$e]=$HOME/Downloads,$HOME/.cache,$HOME/.local/share/Trash,$HOME/VMs,$HOME/.rustup,$HOME/.cargo,$HOME/node_modules,$HOME/.npm,$HOME/.yarn,$HOME/go/pkg,$HOME/.gradle,$HOME/.m2,$HOME/.nix-defexpr,$HOME/.nix-profile,$HOME/Games,/tmp,/var,/run,/nix/store
  '';
}
```

### Environment Variables Module

```nix
# plasma-env.nix
{ ... }:

{
  # Session environment for Plasma/KWin optimization
  systemd.user.sessionVariables = {
    # KWin compositor
    KWIN_OPENGL_INTERFACE = "egl";

    # NVIDIA-specific (choose one approach)
    __GL_YIELD = "USLEEP";
    __GL_MaxFramesAllowed = "1";

    # Alternative: Triple buffer (don't use with __GL_YIELD)
    # KWIN_TRIPLE_BUFFER = "1";
  };

  # Also set in shell profile for non-systemd sessions
  home.sessionVariables = {
    KWIN_OPENGL_INTERFACE = "egl";
    __GL_YIELD = "USLEEP";
    __GL_MaxFramesAllowed = "1";
  };
}
```

---

## Verification and Monitoring

### Check Current Settings

```bash
# KWin compositor info
qdbus6 org.kde.KWin /Compositor supportedOpenGLPlatformInterface

# Current compositor backend
qdbus6 org.kde.KWin /Compositor compositingType

# Check if compositing is active
qdbus6 org.kde.KWin /Compositor active

# Toggle compositor (Alt+Shift+F12 alternative)
qdbus6 org.kde.KWin /Compositor suspend
qdbus6 org.kde.KWin /Compositor resume
```

### Memory Monitoring

```bash
# Quick check
ps aux | grep -E '(plasmashell|kwin|baloo)' | awk '{print $11, $6/1024 "MB"}'

# Detailed with htop
htop -p $(pgrep -d',' 'plasmashell|kwin|baloo')

# System resources summary
free -h && echo && ps aux --sort=-%mem | head -10
```

### After Configuration Changes

1. Log out and log back in (required for plasma-manager changes)
2. Or restart individual services:
   ```bash
   kwin_x11 --replace &  # X11
   # OR
   kwin_wayland --replace &  # Wayland

   plasmashell --replace &
   ```

---

## Troubleshooting

### Common Issues

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Screen tearing | VSync misconfiguration | Check GLPreferBufferSwap, try ForceFullCompositionPipeline |
| High plasmashell RAM | Widget memory leak | Remove problematic widgets, restart plasmashell |
| Compositor crashes | OpenGL driver issue | Try `export KWIN_COMPOSE=Q` for software rendering |
| Frozen desktop | Compositor hang | Alt+Shift+F12 twice to reset compositor |
| Baloo high CPU | Initial indexing | Wait for completion, or add more exclusions |

### Reset to Defaults

```bash
# Backup current config
cp -r ~/.config/plasma* ~/.config/plasma-backup/
cp ~/.config/kwinrc ~/.config/kwinrc.backup
cp ~/.config/baloofilerc ~/.config/baloofilerc.backup

# Reset plasma-manager (if using overrideConfig)
# Just comment out plasma-manager in home.nix and rebuild

# Reset specific file
rm ~/.config/kwinrc
# Log out and in to regenerate defaults
```

---

## Sources

### Official Documentation
- [KDE UserBase Wiki - Desktop Effects Performance](https://userbase.kde.org/Desktop_Effects_Performance)
- [KDE Community Wiki - KWin Environment Variables](https://community.kde.org/KWin/Environment_Variables)
- [KDE Community Wiki - Baloo Configuration](https://community.kde.org/Baloo/Configuration)
- [NixOS Wiki - KDE](https://wiki.nixos.org/wiki/KDE)
- [NixOS Wiki - Plasma-Manager](https://nixos.wiki/wiki/Plasma-Manager)

### Plasma-Manager
- [GitHub - plasma-manager](https://github.com/nix-community/plasma-manager)
- [Plasma-Manager Options Reference](https://nix-community.github.io/plasma-manager/options.xhtml)

### Community Resources
- [KDE Discuss - Plasma 6 RAM Usage](https://discuss.kde.org/t/kde-neon-plasma-6-ram-usage-up-by-1g/12272)
- [Arch Wiki - KDE](https://wiki.archlinux.org/title/KDE)
- [Arch Wiki - Baloo](https://wiki.archlinux.org/title/Baloo)

### Performance Updates
- [Phoronix - KDE Plasma 6.5 Memory Optimizations](https://www.phoronix.com/news/Plasma-6.5-Less-Wallpaper-RAM)
- [KDE Blogs - UI and Performance Improvements (Nov 2025)](https://blogs.kde.org/2025/11/22/this-week-in-plasma-ui-and-performance-improvements/)
- [Phoronix - KWin Vulkan Roadmap](https://www.phoronix.com/news/KDE-KWin-Vulkan-Roadmap)

### NVIDIA-Specific
- [KDE Community Wiki - Plasma Wayland NVIDIA](https://community.kde.org/Plasma/Wayland/Nvidia)
- [Gentoo Wiki - Baloo](https://wiki.gentoo.org/wiki/Baloo)

---

## Appendix: Quick Reference

### Essential Environment Variables

```bash
# NVIDIA + KWin (X11)
export KWIN_OPENGL_INTERFACE=egl
export __GL_YIELD=USLEEP
export __GL_MaxFramesAllowed=1

# Frame timing (Plasma 6.3.3+)
export KWIN_EXTRA_RENDER_TIME=1500

# Debug (if needed)
export KWIN_GL_DEBUG=1
```

### Essential Config Files

| File | Purpose |
|------|---------|
| `~/.config/kwinrc` | KWin compositor settings |
| `~/.config/baloofilerc` | Baloo indexer configuration |
| `~/.config/krunnerrc` | KRunner plugins and settings |
| `~/.config/kdeglobals` | Global KDE settings |
| `~/.config/plasma-org.kde.plasma.desktop-appletsrc` | Panel and widget config |

### Useful Commands

```bash
# Restart compositor
kwin_x11 --replace &

# Restart shell
plasmashell --replace &

# Baloo management
balooctl6 status
balooctl6 disable
balooctl6 enable

# Memory check
free -h
ps aux --sort=-%mem | head -15
```

---

*Research completed: 2025-12-30T05:31:02+02:00*
