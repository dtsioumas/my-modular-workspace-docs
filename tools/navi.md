# Navi - Interactive Cheatsheet Tool

**Official:** https://github.com/denisidoro/navi
**Docs:** https://github.com/denisidoro/navi/tree/master/docs

---

## What is Navi?

Interactive cheatsheet tool for the command-line that provides:
- 📚 **Interactive search** - Find commands with fuzzy search
- 🎯 **Smart suggestions** - Dynamic argument completion
- ⚡ **Quick access** - Keyboard shortcut (Ctrl+G)
- 🔧 **Custom sheets** - Create your own cheatsheets
- 💾 **Community repos** - Import shared cheatsheets

**Installation:** `home-manager/navi.nix` (package only)
**Configuration:** `dotfiles/dot_config/navi/config.yaml` (managed by chezmoi)
**Cheatsheets:** `dotfiles/dot_local/share/navi/cheats/` (custom cheats)

---

## Quick Start

### Daily Usage

**Open navi interactively:**
```bash
# Press Ctrl+G in terminal (configured in shell.nix)
# Or run manually:
navi
```

**Search for specific topic:**
```bash
navi --query "kitty"
navi --query "rclone"
```

**Print command without executing:**
```bash
navi --print
```

### Terminal Startup

On every new terminal session, you'll see:
```
╔════════════════════════════════════════════════════════════╗
║          🚀 Quick Reference - Local Tools                  ║
╚════════════════════════════════════════════════════════════╝

  📚 Navi Interactive Cheatsheets:
     • Press Ctrl+G to open navi
     • Or type: navi --print --query '<tool>'

  🔧 Available Cheatsheets:
     • kitty      - Terminal emulator commands
     • tealdeer   - TLDR pages helper
     • rclone     - Cloud sync monitoring
     • local-tools - Quick workspace reference

  💡 Other Tools:
     • atuin (Ctrl+R) - Shell history search
     • copyq (Ctrl+Shift+C) - Clipboard manager
     • tldr <cmd> - Quick command examples
```

---

## Available Cheatsheets

### Kitty Terminal (`kitty.cheat`)

Commands for managing kitty terminal:
- Open new windows/tabs
- Reload configuration
- SSH integration
- Screenshot terminal
- Image display (icat)
- File diff viewer

**Usage:**
```bash
navi --query "kitty"
# Then select from interactive menu
```

### Tealdeer/TLDR (`tealdeer.cheat`)

Commands for tldr page management:
- Show command examples
- Update cache
- Search pages
- Platform-specific docs
- Offline mode

**Usage:**
```bash
navi --query "tealdeer"
```

### Rclone Monitoring (`rclone.cheat`)

Monitor cloud sync status:
- Check bisync status
- View sync logs
- Manual sync trigger
- Bandwidth monitoring
- Conflict detection

**Usage:**
```bash
navi --query "rclone"
```

### Local Tools (`local-tools.cheat`)

Quick reference for workspace:
- Directory structure
- Service status checks
- Clipboard history
- Cloud sync monitoring

**Usage:**
```bash
navi --query "local"
```

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+G` | Open navi interactive search |
| `Ctrl+R` | Atuin shell history (not navi) |
| `Enter` | Execute selected command |
| `Tab` | Select multiple |
| `Esc` | Cancel |

**Within navi:**
- Type to search
- ↑/↓ to navigate
- Enter to select

---

## Creating Custom Cheatsheets

### Cheatsheet Syntax

```bash
% tag1, tag2

# Description of command
command <variable>

$ variable: command to generate options | awk/sed processing
```

### Example: Custom Tool Cheatsheet

Create file: `~/.local/share/navi/cheats/mytool.cheat`

```bash
% mytool, custom

# Start mytool service
systemctl --user start mytool

# Check mytool logs
journalctl --user -u mytool -n <lines>

# Restart mytool
systemctl --user restart mytool

$ lines: echo "10 50 100 500" | tr ' ' '\n'
```

### Variables with Dynamic Options

```bash
# List files in directory
cat <file>

$ file: find ~/.config -name "*.conf" -type f | head -20
```

The `$ variable:` line runs a command to populate the selection menu.

---

## Configuration

Located at: `~/.config/navi/config.yaml`

```yaml
# Cheatsheet paths
cheats:
  paths:
    - ~/.local/share/navi/cheats  # Custom local cheatsheets

# Finder (fzf) configuration
finder:
  command: fzf
  overrides: --height 50% --reverse --border

# Color scheme
style:
  tag:
    color: cyan
  comment:
    color: blue
  snippet:
    color: white
```

**To modify:**
1. Edit `dotfiles/dot_config/navi/config.yaml`
2. Apply: `chezmoi apply`

---

## Useful Commands

```bash
# Interactive search
navi

# Query specific topic
navi --query "docker"

# Print command only (don't execute)
navi --print

# Show best match for query
navi --query "git commit" --best-match

# List all available cheatsheets
navi info cheats-example

# Show navi config path
navi info config-path

# Show cheatsheets path
navi info cheats-path
```

---

## Import Community Cheatsheets

**Browse available repositories:**
```bash
navi repo browse
```

**Add repository:**
```bash
navi repo add https://github.com/denisidoro/cheats
```

**Update repositories:**
```bash
navi repo update
```

---

## Integration with Other Tools

### Atuin (Shell History)

- **Atuin:** `Ctrl+R` - Cloud-synced shell history
- **Navi:** `Ctrl+G` - Interactive cheatsheets

Both complement each other!

### TLDR/Tealdeer

- **tldr:** Quick command examples
- **navi:** Interactive command builder

Use navi cheatsheet to remember tldr commands!

---

## Restore on New Workspace

```bash
# 1. Install navi (via home-manager)
home-manager switch --flake <path>

# 2. Apply chezmoi config
chezmoi apply

# 3. Verify cheatsheets
ls ~/.local/share/navi/cheats/

# 4. Test navi
navi --query "kitty"

# 5. Open new terminal - should see quick reference display
```

---

## Tips

1. **Use Ctrl+G frequently** - Faster than remembering commands
2. **Create sheets for repetitive tasks** - Document once, use forever
3. **Combine with tldr** - Use tldr for examples, navi for workflows
4. **Pin common commands** - Add to local-tools.cheat
5. **Share sheets** - Export custom cheats to dotfiles repo

---

## Troubleshooting

### Cheatsheets not found

```bash
# Check paths
navi info cheats-path

# Verify files exist
ls -la ~/.local/share/navi/cheats/

# Re-apply chezmoi
chezmoi apply
```

### Ctrl+G not working

```bash
# Reload shell config
exec bash

# Or manually bind
bind -x '"\C-g": navi --print'
```

### Navi not installed

```bash
# Check installation
which navi

# Reinstall via home-manager
home-manager switch --flake <path>
```

---

## Next Steps After Install

1. ✅ Configured in `navi.nix`
2. ✅ Custom cheatsheets created
3. ✅ Terminal startup configured
4. ✅ Ctrl+G bound
5. ⏳ Run `home-manager switch`
6. ⏳ Test: Press `Ctrl+G`
7. ⏳ Create your own cheatsheets

---

**Last Updated:** 2025-11-18
**Config:** `dotfiles/dot_config/navi/`
**Cheatsheets:** `dotfiles/dot_local/share/navi/cheats/`
**Shell Integration:** `home-manager/shell.nix`
