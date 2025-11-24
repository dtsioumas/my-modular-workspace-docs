# Kitty Terminal Configuration Documentation

**Date:** 2025-11-07
**System:** Windows 11 with WSL2 (Ubuntu)
**Purpose:** Configure kitty terminal emulator with WSL integration, GPU support, and catppuccin theme

---

## Table of Contents

1. [Overview](#overview)
2. [Official Documentation](#official-documentation)
3. [Installation Requirements](#installation-requirements)
4. [Configuration Resources](#configuration-resources)
5. [Theme Resources](#theme-resources)
6. [WSL Integration](#wsl-integration)
7. [GPU Requirements](#gpu-requirements)
8. [References](#references)

---

## Overview

Kitty is a fast, feature-rich, GPU-based terminal emulator that supports:
- GPU acceleration for performance
- Graphics rendering (images, animations)
- Font ligatures and emoji support
- Python-based extensibility ("kittens")
- Advanced window management (tabs, splits, layouts)
- OpenGL 3.3+ requirement

---

## Official Documentation

### Primary Resources

- **Official Website:** https://sw.kovidgoyal.net/kitty/
- **Quickstart Guide:** https://sw.kovidgoyal.net/kitty/quickstart/
- **Binary Installation:** https://sw.kovidgoyal.net/kitty/binary/
- **ArchWiki Page:** https://wiki.archlinux.org/title/Kitty
- **Ubuntu Manpage:** https://manpages.ubuntu.com/manpages/focal/man1/kitty.1.html
- **Rocky Linux Docs:** https://docs.rockylinux.org/desktop/tools/kitty/
- **Gentoo Wiki:** https://wiki.gentoo.org/wiki/Kitty
- **Wikipedia:** https://en.wikipedia.org/wiki/Kitty_(terminal_emulator)

### Configuration Files

- **Main config:** `~/.config/kitty/kitty.conf`
- **Themes directory:** `~/.config/kitty/themes/`
- **Open config:** `Ctrl+Shift+F2` (from within kitty)

---

## Installation Requirements

### WSL2 Prerequisites

**System Requirements:**
- Windows 10 or Windows 11
- WSL2 installed and configured
- Ubuntu 20.04+ (tested) or compatible Linux distribution
- NVIDIA graphics driver (tested with version 511.23+)

**GPU Requirements:**
- **Critical:** OpenGL 3.3+ support required
- Mesa graphics library (latest version recommended)
- For Windows 11: Built-in window server support (works out of the box)
- For Windows 10: Requires X server (e.g., VcXsrv/XLaunch)

### WSL2 Setup Steps

**Reference Guide:** https://github.com/danielbisar/settings/blob/main/guides/kitty-on-windows-with-wsl2.md

**Installation Gist:** https://gist.github.com/VPraharsha03/dce1692afccdb2d220fffff3ad8448f0

#### Step 1: Update Mesa Graphics Library

```bash
sudo add-apt-repository ppa:kisak/kisak-mesa
sudo apt upgrade
```

Why: Installs latest GPU acceleration packages needed for kitty's graphics rendering.

#### Step 2: Install OpenGL Tools (Optional Verification)

```bash
sudo apt install x11-apps
xclock  # Test X11 connectivity
```

#### Step 3: Verify OpenGL Support

```bash
sudo apt install mesa-utils
glxinfo -B
```

**Important:** Check output for OpenGL 3.SOMETHING or higher.

#### Step 4: Install Kitty

```bash
sudo apt install kitty
kitty
```

---

## Configuration Resources

### Minimal Beginner-Friendly Configs

**GitHub Topics:**
- Kitty Config Topic: https://github.com/topics/kitty-config
- Kitty Terminal Topic: https://github.com/topics/kitty-terminal?o=desc&s=updated

**Recommended Example Configs:**

1. **anongecko/best-kitty.conf**
   - URL: https://github.com/anongecko/best-kitty.conf
   - Features: Intuitive keybindings, commented cheatsheet, installation steps
   - Best for: Complete beginners

2. **LinuxNerdBTW/kitty_terminal_conf**
   - URL: https://github.com/LinuxNerdBTW/kitty_terminal_conf
   - Features: Simple 2-file structure (kitty.conf + dracula.conf)
   - Best for: Understanding basics

3. **ttys3/oh-my-kitty**
   - URL: https://github.com/ttys3/my-kitty-config
   - Features: Configuration for tmux users
   - Best for: Advanced workflow integration

**Blog Resources:**
- **Adam Chalmers' 5-Year Config:** https://blog.adamchalmers.com/kitty-terminal-config/
  - Font recommendations
  - Visual enhancements
  - Keyboard shortcuts
  - Layout preferences

- **It's FOSS Customization Guide (July 2025):** https://itsfoss.com/kitty-customization/
  - 15 customization tips and tweaks
  - Comprehensive beginner guide

**Example Gists:**
- fwfurtado's config: https://gist.github.com/fwfurtado/e7e40cf8b07cff18c6d7bd1649676abf
- sts10's config: https://gist.github.com/sts10/56ffa75c87e1cc2af9a9309d5baeb2ff

### Essential Configuration Recommendations

Based on Adam Chalmers' blog (https://blog.adamchalmers.com/kitty-terminal-config/):

**Font Setup:**
- Use ligature-supporting fonts (e.g., "FiraCode Nerd Font Mono")
- Size: 14.0 recommended for readability

**Visual Enhancements:**
- Window margins: 10 pixels for breathing room
- Border width: 1pt with visible color (e.g., cyan #44ffff)
- Tab bar: "powerline" style with "slanted" styling

**Keyboard:**
- Enable Alt key support (macOS): `macos_option_as_alt yes`
- F1: Open new window in current directory
- F2: Launch editor in current directory

**Layout:**
- Default: "Tall" layout
- Cycle through layouts: `Ctrl+Shift+L`

---

## Theme Resources

### Catppuccin Theme

**Official Repository:** https://github.com/catppuccin/kitty

**Available Flavors:**
- Catppuccin-Latte
- Catppuccin-Frappe
- Catppuccin-Macchiato
- Catppuccin-Mocha

**Installation Methods:**

#### Method 1: Built-in (Kitty >= 0.26.0)
All Catppuccin flavors are included by default!

```bash
kitty +kitten themes --reload-in=all Catppuccin-Mocha
```

#### Method 2: Manual Installation
Copy theme contents from:
- Mocha: https://github.com/catppuccin/kitty/blob/main/themes/mocha.conf
- Latte: https://github.com/catppuccin/kitty/blob/main/themes/latte.conf
- Frappe: https://github.com/catppuccin/kitty/blob/main/themes/frappe.conf
- Macchiato: https://github.com/catppuccin/kitty/blob/main/themes/macchiato.conf

Into `~/.config/kitty/kitty.conf` or `~/.config/kitty/themes/`

**Catppuccin Mocha Theme Details:**
- Foreground: #cdd6f4
- Background: #1e1e2e
- Cursor: #f5e0dc
- Selection bg: #f5e0dc
- Active border: #b4befe
- Soothing pastel colors throughout

**License:** MIT
**Creator:** Catppuccin Org
**Description:** "Soothing pastel theme for the high-spirited!"

---

## WSL Integration

### Windows Launcher (PowerShell Shortcut)

Create shortcut to launch kitty without WSL console window:

```powershell
"C:\Program Files\PowerShell\7\pwsh.exe" -WorkingDirectory ~ -WindowStyle Hidden -Command C:\Windows\System32\wsl.exe --cd ~ -e bash -c kitty
```

**Note:** Initial startup may take considerable time.

### X11 Display Forwarding

**Windows 11:** Works automatically (built-in WSLg support)
**Windows 10:** Requires X server installation (VcXsrv/XLaunch)

### Configuration Symlink Strategy

**Windows Config Location:**
```
C:\Users\dioklint.ATH\Workspaces\common-dotfiles\kitty\
```

**WSL Config Location:**
```
~/.config/kitty/
```

**Symlink Creation:**
```bash
# From WSL
ln -s /mnt/c/Users/dioklint.ATH/Workspaces/common-dotfiles/kitty ~/.config/kitty
```

---

## GPU Requirements

### OpenGL Version Check

**Required:** OpenGL 3.3+

**Verify Command:**
```bash
glxinfo -B
```

**Expected Output:** Look for "OpenGL version string: 3.x" or higher

### Graphics Driver

**NVIDIA:**
- Latest Windows NVIDIA drivers (511.23+ tested)
- Mesa drivers in WSL2 (via kisak PPA)

**AMD/Intel:**
- Latest Mesa drivers
- Verify OpenGL 3.3+ support

### Troubleshooting GPU Issues

If kitty fails to start or graphics are glitchy:

1. **Check OpenGL version:**
   ```bash
   glxinfo -B | grep "OpenGL version"
   ```

2. **Update Mesa:**
   ```bash
   sudo add-apt-repository ppa:kisak/kisak-mesa
   sudo apt update && sudo apt upgrade
   ```

3. **Test X11:**
   ```bash
   xclock  # Should display a clock window
   ```

4. **Verify WSL GPU support:**
   ```bash
   nvidia-smi  # For NVIDIA GPUs
   ```

---

## References

### Documentation
1. Kitty Official Docs: https://sw.kovidgoyal.net/kitty/
2. ArchWiki Kitty: https://wiki.archlinux.org/title/Kitty
3. Adam Chalmers Blog: https://blog.adamchalmers.com/kitty-terminal-config/
4. It's FOSS Guide: https://itsfoss.com/kitty-customization/

### WSL Integration
1. danielbisar WSL2 Guide: https://github.com/danielbisar/settings/blob/main/guides/kitty-on-windows-with-wsl2.md
2. VPraharsha03 Install Gist: https://gist.github.com/VPraharsha03/dce1692afccdb2d220fffff3ad8448f0

### Theme
1. Catppuccin Kitty: https://github.com/catppuccin/kitty
2. Mocha Theme: https://github.com/catppuccin/kitty/blob/main/themes/mocha.conf

### Configuration Examples
1. GitHub kitty-config topic: https://github.com/topics/kitty-config
2. anongecko/best-kitty.conf: https://github.com/anongecko/best-kitty.conf
3. ttys3/oh-my-kitty: https://github.com/ttys3/my-kitty-config

### Additional Tools
1. doctorfree/kitty-control: https://github.com/doctorfree/kitty-control

---

## Next Steps

1. ✅ Documentation complete
2. ⏳ Create minimal kitty.conf
3. ⏳ Install catppuccin mocha theme
4. ⏳ Configure WSL integration
5. ⏳ Set up transparent background
6. ⏳ Test GPU acceleration
7. ⏳ Create symlink to WSL config
8. ⏳ Optional: Configure WSL desktop environment

---

**Last Updated:** 2025-11-07
**Maintainer:** Dimitris Tsioumas (dtsioumas0@gmail.com)
