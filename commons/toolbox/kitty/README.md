# Kitty Terminal Configuration

**Created:** 2025-11-07
**System:** Windows 11 + WSL2 Ubuntu
**Kitty Version:** 0.44.0
**Theme:** Catppuccin Mocha

---

## 📁 Directory Structure

```
kitty/
├── kitty.conf              # Main configuration file
├── current-theme.conf      # Catppuccin Mocha theme
├── DOCUMENTATION.md        # Comprehensive docs με resources
├── CONFIGURATION_SUGGESTIONS.md  # Config suggestions και learning path
├── README.md               # This file
├── launch-kitty.ps1        # PowerShell launcher
├── launch-kitty.bat        # Batch launcher
└── kittens/               # Custom kittens
    ├── shortcuts_cheatsheet.py  # Shortcuts reference (Ctrl+Shift+/)
    └── README.md           # Kittens documentation
```

---

## 🚀 Quick Start

### Launch Kitty

**Method 1: From WSL Terminal**
```bash
kitty
```

**Method 2: From Windows**
- Double-click `launch-kitty.bat`
- Or run: `powershell -File launch-kitty.ps1`

**Method 3: Windows Run Dialog**
```
wsl.exe --cd ~ -e bash -c "kitty"
```

---

## ⚙️ Configuration

### Your Preferences

- **Font:** JetBrains Mono, size 14
- **Theme:** Catppuccin Mocha (soothing pastels)
- **Transparency:** 0.95 (subtle)
- **Copy:** Copy-on-select enabled (modern behavior)
- **Layouts:** tall, stack, splits
- **Scrollback:** 10,000 lines

### Config Location

- **Windows:** `C:\Users\dioklint.ATH\Workspaces\common-dotfiles\kitty\`
- **WSL:** `~/.config/kitty/` (symlinked to Windows location)

### Edit Config

**From Kitty:**
```
Ctrl+Shift+F2
```

**From Terminal:**
```bash
code ~/.config/kitty/kitty.conf
# or
vim ~/.config/kitty/kitty.conf
```

---

## ⌨️ Essential Keyboard Shortcuts

### Window/Tab Management
- `Ctrl+Shift+Enter` - New window
- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+W` - Close window
- `Ctrl+Shift+Q` - Close tab
- `Ctrl+Shift+Right` - Next tab
- `Ctrl+Shift+Left` - Previous tab
- `Ctrl+Shift+1-5` - Go to tab 1-5

### Font Size
- `Ctrl+Shift++` - Increase font
- `Ctrl+Shift+-` - Decrease font
- `Ctrl+Shift+Backspace` - Reset font size

### Copy/Paste
- `Ctrl+Shift+C` - Copy (also: select text automatically copies)
- `Ctrl+Shift+V` - Paste
- `Shift+Insert` - Paste

### Layout Management
- `Ctrl+Shift+L` - Cycle through layouts (tall/stack/splits)

### Scrollback
- `Ctrl+Shift+K` - Scroll up
- `Ctrl+Shift+J` - Scroll down
- `Ctrl+Shift+Page Up/Down` - Page up/down
- `Ctrl+Shift+Home/End` - Scroll to top/bottom
- `Ctrl+Shift+H` - Show scrollback in pager

### Configuration
- `Ctrl+Shift+F2` - Edit config
- `Ctrl+Shift+F5` - Reload config

### Custom Kittens
- `Ctrl+Shift+/` - **Show shortcuts cheatsheet** 📋

---

## 🎨 Theme

**Catppuccin Mocha** - Soothing pastel colors

**Change Theme:**
```bash
# List available themes (if using theme kitten)
kitty +kitten themes

# Theme file location
~/.config/kitty/current-theme.conf
```

---

## 🔧 GPU Support

**Status:** ✅ OpenGL 4.5 detected

```bash
# Verify OpenGL support
glxinfo -B | grep "OpenGL version"
```

**Note:** Currently using software rendering (llvmpipe), but OpenGL 4.5 is more than sufficient for kitty. Hardware GPU passthrough may require additional WSL configuration.

---

## 📚 Documentation

### Comprehensive Docs
- **DOCUMENTATION.md** - All official docs, WSL guides, GPU requirements, troubleshooting
- **CONFIGURATION_SUGGESTIONS.md** - Configuration options με trade-offs, 4-week learning path

### Official Resources
- **Kitty Docs:** https://sw.kovidgoyal.net/kitty/
- **Catppuccin Theme:** https://github.com/catppuccin/kitty
- **Keyboard Shortcuts:** https://sw.kovidgoyal.net/kitty/keyboard-protocol/

---

## 🐱 Kittens (Extensions)

### Shortcuts Cheatsheet
**Activate:** `Ctrl+Shift+/`

Shows all configured keyboard shortcuts in a nice formatted display.

**Location:** `kittens/shortcuts_cheatsheet.py`

### Create Custom Kittens

Kittens are Python scripts that extend kitty functionality. See `kittens/README.md` for details.

---

## 🔄 Syncing Config

Config is stored in Windows and symlinked to WSL:

```bash
# Check symlink
ls -la ~/.config/kitty

# Should show:
# ~/.config/kitty -> /mnt/c/Users/dioklint.ATH/Workspaces/common-dotfiles/kitty
```

**Benefits:**
- ✅ One config για both Windows και WSL
- ✅ Version controlled με Git
- ✅ Easy backup με cloud storage
- ✅ Consistent across systems

---

## 🚨 Troubleshooting

### Kitty Won't Launch

**Check if kitty is in PATH:**
```bash
which kitty
# Should show: /home/dioklint/.local/kitty.app/bin/kitty
```

**If not in PATH:**
```bash
echo 'export PATH="$HOME/.local/kitty.app/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Config Not Loading

**Verify symlink:**
```bash
ls -la ~/.config/kitty
```

**Test config:**
```bash
kitty --config ~/.config/kitty/kitty.conf
```

### Font Not Working

**Check if font is installed:**
- JetBrains Mono: https://www.jetbrains.com/lp/mono/
- Download and install in Windows
- WSLg will automatically use Windows fonts

### Transparency Not Working

**WSLg supports transparency on Windows 11.**

If not working:
1. Check Windows transparency settings
2. Verify `background_opacity` in kitty.conf
3. Try adjusting με `Ctrl+Shift+A+M/L`

---

## 📝 Next Steps

### Week 1: Get Comfortable
- [ ] Launch kitty and explore interface
- [ ] Practice basic shortcuts (new tab, copy/paste)
- [ ] Try `Ctrl+Shift+/` για shortcuts cheatsheet
- [ ] Experiment με font size (Ctrl+Shift++/-)

### Week 2: Customize
- [ ] Adjust transparency to your liking
- [ ] Try different layouts (Ctrl+Shift+L)
- [ ] Customize shortcuts if needed
- [ ] Explore scrollback με Ctrl+Shift+H

### Week 3: Advanced Features
- [ ] Learn window splits
- [ ] Create custom kittens
- [ ] Configure remote control features
- [ ] Integrate με other tools (tmux, vim)

### Week 4: Master It
- [ ] Optimize workflow με custom shortcuts
- [ ] Create project-specific configs
- [ ] Share configs με team
- [ ] Contribute back to community

---

## 🤝 Contributing

Found a better configuration? Created a useful kitten? Share it!

- Open an issue/PR in your dotfiles repo
- Document your changes
- Help others learn kitty

---

## 📄 License

Configuration files: MIT License
Catppuccin Theme: MIT License
Kitty Terminal: GPL-3.0 License

---

## 🙏 Credits

- **Kitty Terminal:** Kovid Goyal - https://github.com/kovidgoyal/kitty
- **Catppuccin Theme:** Catppuccin Org - https://github.com/catppuccin/kitty
- **Configuration:** Created for Dimitris Tsioumas (@dtsioumas)

---

**Last Updated:** 2025-11-07
**Maintainer:** Dimitris Tsioumas (dtsioumas0@gmail.com)
**System:** laptop-system01 (Windows 11 + WSL2)

---

## 🎯 Quick Reference Card

```
╔══════════════════════════════════════════════════════════════╗
║                     KITTY QUICK REFERENCE                    ║
╠══════════════════════════════════════════════════════════════╣
║  Ctrl+Shift+/        Show this shortcuts cheatsheet         ║
║  Ctrl+Shift+F2       Edit configuration                     ║
║  Ctrl+Shift+F5       Reload configuration                   ║
║  Ctrl+Shift+L        Cycle layouts                          ║
║  Ctrl+Shift+T        New tab                                ║
║  Ctrl+Shift+Enter    New window                             ║
║  Ctrl+Shift+C        Copy                                   ║
║  Ctrl+Shift+V        Paste                                  ║
╚══════════════════════════════════════════════════════════════╝
```

**Enjoy your new terminal! 🚀**
