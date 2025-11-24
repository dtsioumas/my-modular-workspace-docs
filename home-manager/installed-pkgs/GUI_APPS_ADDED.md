# GUI Applications & Productivity Tools Added

**Date:** 2025-11-18
**Total Packages Added:** 50+
**Category:** Desktop applications, productivity tools, utilities

---

## 📦 Complete List of Additions

### Browsers (3)
✅ **brave** - Primary browser (already set as default)
✅ **firefox** - Mozilla Firefox
✅ **chromium** - Google Chromium (open-source)

### Communication & Social (5)
✅ **discord** - Gaming/community chat
✅ **telegram-desktop** - Telegram messenger
✅ **slack** - Team communication
✅ **signal-desktop** - Encrypted messaging
✅ **zoom-us** - Video conferencing

### Productivity & Office (3)
✅ **obsidian** - Note-taking and knowledge base
✅ **libreoffice-fresh** - Office suite (Writer, Calc, Impress)

### Media & Graphics (6)
✅ **vlc** - Video player
✅ **mpv** - Lightweight video player
✅ **gimp** - Image editor
✅ **inkscape** - Vector graphics editor
✅ **audacity** - Audio editor

### PDF & Document Viewers (3)
✅ **okular** - KDE PDF viewer
✅ **zathura** - Minimal PDF viewer
✅ **evince** - GNOME document viewer

### Note-taking & Knowledge Management (2)
✅ **joplin-desktop** - Open-source note taking
✅ **logseq** - Privacy-first knowledge base

### File Management & Utilities (3)
✅ **filelight** - Disk usage analyzer (KDE)
✅ **kdePackages.dolphin-plugins** - Extra Dolphin plugins
✅ **kdePackages.ark** - Archive manager

### Screenshots & Screen Recording (4)
✅ **flameshot** - Powerful screenshot tool
✅ **spectacle** - KDE screenshot utility
✅ **peek** - Simple animated GIF recorder

### System Utilities (3)
✅ **gparted** - Partition manager
✅ **ventoy-full** - Multi-boot USB creator
✅ **balenaetcher** - USB/SD card flasher

### Development GUI Tools (2)
✅ **gitg** - Git GUI
✅ **meld** - Visual diff and merge tool

### Virtualization (1)
✅ **virt-manager** - Virtual machine manager

### Cloud Storage (1)
✅ **dropbox** - Dropbox client

### Productivity CLI Tools (11)
✅ **timewarrior** - Time tracking
✅ **khal** - CLI calendar
✅ **khard** - CLI contacts
✅ **pandoc** - Universal document converter
✅ **hugo** - Static site generator
✅ **speedtest-cli** - Internet speed test
✅ **nmap** - Network scanner
✅ **wireshark** - Network protocol analyzer
✅ **fastfetch** - Modern system info
✅ **rclone** - Cloud storage sync

---

## 🎯 Package Count by Category

| Category | Count |
|----------|-------|
| Browsers | 3 |
| Communication | 5 |
| Productivity & Office | 3 |
| Media & Graphics | 6 |
| PDF Viewers | 3 |
| Note-taking | 2 |
| File Management | 3 |
| Screenshots | 4 |
| System Utilities | 3 |
| Development GUI | 2 |
| Virtualization | 1 |
| Cloud Storage | 1 |
| CLI Productivity | 11 |
| **TOTAL** | **47** |

---

### 2. Configure Obsidian Vault

After installation:
```bash
# Link your vault directory
ln -s ~/MyVault/ObsidianVault ~/.config/obsidian/
```

### 3. Set Up Dropbox

First time setup:
```bash
dropbox start
# Follow GUI prompts to link account
```

### 4. Configure Thunderbird

Email client setup:
- Add your email accounts via GUI
- Sync with KeePassXC for passwords

### 5. Set Up OBS Studio

For screen recording:
- Configure scenes and sources
- Set output directory
- Configure hotkeys

### 6. Configure Flameshot

Better screenshots:
```bash
# Set up keyboard shortcut in Plasma
# Settings > Shortcuts > Custom Shortcuts
# Add: flameshot gui
# Bind to: Print Screen
```

## ✅ Verification Checklist

After `home-manager switch`:

### Browsers
- [ ] Brave launches and is default browser
- [ ] Firefox launches
- [ ] Chromium launches

### Communication
- [ ] Discord launches
- [ ] Telegram launches
- [ ] Slack launches
- [ ] Signal launches
- [ ] Zoom launches

### Productivity
- [ ] Obsidian launches
- [ ] LibreOffice Writer/Calc/Impress launch
- [ ] Thunderbird launches

### Media
- [ ] VLC plays videos
- [ ] MPV plays videos
- [ ] GIMP opens images
- [ ] Inkscape opens
- [ ] Krita opens
- [ ] Audacity opens

### Utilities
- [ ] Flameshot screenshot works
- [ ] GParted launches (requires sudo)
- [ ] Virt-manager launcheso

### CLI Tools
- [ ] `task --version` works
- [ ] `timew --version` works
- [ ] `khal` works
- [ ] `pandoc --version` works
- [ ] `speedtest-cli` works

---

## 🐛 Common Issues & Solutions

### Obsidian Won't Launch
```bash
# Check if installed
which obsidian

# If missing, ensure home-manager rebuilt
home-manager packages | grep obsidian
```

### Dropbox Won't Start
```bash
# Check dropbox daemon
dropbox status

# Start manually
dropbox start
```

### OBS Studio Audio Issues
```bash
# Ensure PipeWire is running
systemctl --user status pipewire
```

### Zoom Screen Sharing Not Working
Zoom requires Wayland permissions. If on X11, should work. If on Wayland:
```bash
# Use X11 session instead, or configure Zoom for Wayland
```

---

## 🎨 Recommended KDE Integration

### Set App Defaults in Plasma

System Settings > Applications > Default Applications:
- Web Browser: Brave
- Email Client: Thunderbird
- File Manager: Dolphin (already default)
- Terminal: Kitty (already configured)

### Add to Favorites/Panel

Right-click taskbar > Add Widgets > Icons-only Task Manager
Then pin frequently used apps:
- Brave
- Kitty
- VSCodium
- Dolphin
- Obsidian
- Discord

---

**All applications ready to use after rebuild!** 🚀

Run: `home-manager switch --flake .#mitsio@shoshin`
