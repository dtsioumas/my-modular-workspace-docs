# CopyQ - Advanced Clipboard Manager

**Official:** https://hluk.github.io/CopyQ/
**GitHub:** https://github.com/hluk/CopyQ
**Docs:** https://copyq.readthedocs.io/

---

## What is CopyQ?

Advanced clipboard manager with:
- 📋 **Clipboard history** - Store unlimited clipboard items
- 🔍 **Search** - Find items quickly
- 📝 **Edit** - Modify clipboard contents
- 🏷️ **Tags** - Organize clipboard items
- 🔒 **Encryption** - Encrypt sensitive items
- ⌨️ **Shortcuts** - Keyboard-driven workflow
- 🎨 **Customizable** - Themes and scripts

**Replaces:** Klipper (KDE default clipboard)

**Installation:** `home-manager/home.nix` (copyq package)
**Configuration:** `dotfiles/dot_config/copyq/copyq.conf` (managed by chezmoi)

---

## Quick Start

### Initial Setup on New Workspace

After installing via home-manager and applying chezmoi:

**1. Disable Klipper (KDE default):**
```bash
# Disable Klipper in system settings
kwriteconfig5 --file klipper --group General --key Enabled false

# Or via GUI:
# System Settings → Autostart → Disable "Clipboard" (Klipper)
```

**2. Start CopyQ:**
```bash
# Will autostart on next login, or start manually:
copyq &
```

**3. Verify:**
```bash
# Check if CopyQ is running
ps aux | grep copyq

# Open CopyQ window
copyq toggle
```

---

## Daily Usage

### Basic Operations

**Show/Hide CopyQ:**
- `Ctrl+Shift+C` - Toggle CopyQ window (configurable)
- Or click system tray icon

**Copy and Access:**
1. Copy text as usual (`Ctrl+C`)
2. Open CopyQ (`Ctrl+Shift+C`)
3. Select item from history
4. Press `Enter` to copy to clipboard
5. Paste (`Ctrl+V`)

### Search History
- Open CopyQ
- Start typing to search
- Use ↑/↓ to navigate
- `Enter` to select

### Essential Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+C` | Show/hide CopyQ |
| `Ctrl+F` | Search |
| `F2` | Edit item |
| `Shift+F2` | Edit notes |
| `Del` | Delete item |
| `Ctrl+N` | New item |
| `Ctrl+P` | Preferences |
| `Enter` | Copy to clipboard |

---

## Key Features

### 1. Clipboard History
- Stores last 200 items (configurable)
- Includes text, images, files
- Persistent across reboots

### 2. Tabs
- Organize items by category
- Default tab: `&clipboard`
- Create custom tabs for projects

### 3. Editing
- Edit clipboard items before pasting
- Add notes to items
- Format text

### 4. Pinning
- Pin important items
- Pinned items never expire
- Quick access to frequent snippets

### 5. Tags
- Tag items for organization
- Filter by tag
- Color-coded

### 6. Encryption
- Encrypt sensitive clipboard items
- Password-protected
- Transparent encryption/decryption

---

## Configuration

Managed in `copyq.conf`:

**Key settings:**
- `maxitems=200` - History size
- `autostart=true` - Start with system
- `editor=nvim %F` - External editor
- `clipboard_notification_lines=0` - Disable notifications

**To change settings:**
1. Edit `dotfiles/dot_config/copyq/copyq.conf`
2. Apply with chezmoi: `chezmoi apply`
3. Restart CopyQ: `copyq exit && copyq &`

---

## Useful Commands

```bash
# Show CopyQ window
copyq toggle
copyq show

# Hide CopyQ window
copyq hide

# Exit CopyQ
copyq exit

# Copy text to clipboard
echo "text" | copyq copy -

# Get clipboard content
copyq clipboard

# Show clipboard history (text only)
copyq read 0 10  # First 10 items

# Add item to clipboard
copyq add "custom text"

# Remove item by row number
copyq remove 0

# Clear all history
copyq clear
```

---

## KDE Integration

### Disabling Klipper

**Method 1: Command line**
```bash
# Disable Klipper
kwriteconfig5 --file klipper --group General --key Enabled false

# Remove from autostart
rm ~/.config/autostart/org.kde.klipper.desktop 2>/dev/null
```

**Method 2: System Settings**
1. Open System Settings
2. Go to Autostart
3. Find "Clipboard" or "Klipper"
4. Uncheck or disable
5. Restart session

### Setting CopyQ as Default

CopyQ is now your default clipboard manager once:
- ✅ Klipper is disabled
- ✅ CopyQ is in autostart
- ✅ CopyQ is running

---

## Restore on New Workspace

When setting up a new machine:

```bash
# 1. Install CopyQ (via home-manager)
home-manager switch --flake <path>

# 2. Apply chezmoi config
chezmoi apply

# 3. Disable Klipper
kwriteconfig5 --file klipperrc --group General --key Enabled false

# 4. Start CopyQ (or reboot)
copyq &

# Done! CopyQ is now your default clipboard manager
```

---

## Troubleshooting

### CopyQ Not Starting
```bash
# Check if already running
ps aux | grep copyq

# Kill and restart
pkill copyq
copyq &
```

### Klipper Still Active
```bash
# Verify Klipper is disabled
kreadconfig5 --file klipperrc --group General --key Enabled

# Force kill Klipper
pkill klipper
```

### Lost Clipboard History
```bash
# CopyQ database location
~/.config/copyq/copyq.dat
~/.config/copyq/copyq_tabs/

# Backup before major changes
cp -r ~/.config/copyq ~/.config/copyq.backup
```

---

## Tips

1. **Pin frequently used snippets** - Right-click → Pin
2. **Use tabs for projects** - Organize by context
3. **Enable encryption** for sensitive data
4. **Create keyboard shortcuts** for quick actions
5. **Use editor** (F2) to modify before pasting
6. **Search is powerful** - Type to filter instantly

---

## Advanced Features

### Custom Commands
Create commands to process clipboard items:
- Transform text (uppercase, lowercase, etc.)
- Format code
- Execute scripts
- API calls

### Scripting
CopyQ has built-in scripting (JavaScript-like):
```javascript
// Example: Auto-format JSON
var json = clipboard()
var formatted = JSON.stringify(JSON.parse(json), null, 2)
copy(formatted)
```

---

## Migration from Klipper

**What you lose:** Nothing significant
**What you gain:**
- ✅ More history (200 vs ~20 items)
- ✅ Better search
- ✅ Editing capability
- ✅ Tabs and organization
- ✅ Encryption
- ✅ Scripting
- ✅ Cross-platform (works on non-KDE too)

---

## Next Steps After Install

1. ✅ Added to `home.nix`
2. ⏳ Run `home-manager switch`
3. ⏳ Apply chezmoi: `chezmoi apply`
4. ⏳ Disable Klipper
5. ⏳ Start CopyQ: `copyq &`
6. ⏳ Configure shortcuts in System Settings

---

**Last Updated:** 2025-11-18
**Config:** `dotfiles/dot_config/copyq/`
**Autostart:** `dotfiles/dot_config/autostart/copyq.desktop`
