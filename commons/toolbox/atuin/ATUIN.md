# Atuin - Modern Shell History

**Official:** https://atuin.sh/
**GitHub:** https://github.com/atuinsh/atuin
**Docs:** https://docs.atuin.sh/

---

## What is Atuin?

Modern shell history manager that replaces `.bash_history` with:
- 🔐 **Encrypted sync** across machines
- 🔍 **Fuzzy search** with context (directory, exit code, duration)
- 🌐 **Cross-machine** history
- 🔒 **Privacy-focused** (end-to-end encrypted)

**Installation:** `home-manager/atuin.nix` (package only)
**Configuration:** `dotfiles/dot_config/atuin/config.toml` (managed by chezmoi)

---

## Quick Start

### Initial Setup (First Machine)

```bash
# 1. Install via home-manager (already configured in atuin.nix)
home-manager switch --flake ~/.MyHome/MySpaces/my-modular-workspace/home-manager/#mitsio@shoshin

# 2. Register account (FREE)
atuin register -u mitsio -e dtsioumas0@gmail.com

# 3. Import existing bash history
atuin import auto

# 4. Sync
atuin sync
```

---

## Restore on New Workspace

When setting up a new machine with your dotfiles:

```bash
# 1. Install atuin (via home-manager)
home-manager switch --flake <path>/#mitsio@<hostname>

# 2. Login with existing account
atuin login -u mitsio

# 3. Sync history from cloud
atuin sync

# Done! Your entire shell history is now available
```

**That's it!** All your command history from all machines is now available.

---

## Daily Usage

### Basic Search

**Press `Ctrl+R`** - Opens Atuin search interface

- Type to search (fuzzy matching)
- ↑/↓ to navigate results
- Enter to execute
- Esc to cancel

### Essential Commands

```bash
# Manual search
atuin search <query>

# Sync now
atuin sync

# View stats
atuin stats

# List recent history
atuin history list

# Show last 20 commands
atuin history list --limit 20
```

---

## Search Filters

```bash
# Commands from specific directory
atuin search --cwd ~/Projects git

# Only successful commands
atuin search --exit 0 npm

# Only failed commands
atuin search --exclude-exit 0

# Commands from today
atuin search --after "1 day ago"

# Commands from specific host
atuin search --host shoshin
```

---

## Key Features

### 1. Context-Aware Search
See when/where/how each command was run:
- Directory path
- Exit code (success/failure)
- Duration
- Timestamp
- Hostname

### 2. Privacy & Security
- **Local:** Stored in `~/.local/share/atuin/history.db`
- **Remote:** End-to-end encrypted (server can't read your history)
- **Key:** Encryption key in `~/.local/share/atuin/key` (backup this!)

### 3. Multi-Machine Sync
- Auto-syncs every 10 minutes (configurable)
- All machines share same history
- Works offline, syncs when online

---

## Configuration

Managed in `atuin.nix`:

```nix
programs.atuin = {
  enable = true;
  enableBashIntegration = true;

  settings = {
    auto_sync = true;
    sync_frequency = "10m";
    search_mode = "fuzzy";
    filter_mode = "global";
    show_preview = true;
  };
};
```

**To change settings:**
1. Edit `atuin.nix`
2. Run `home-manager switch`
3. Reload shell

---

## Useful Commands

```bash
# Statistics
atuin stats              # Show usage statistics

# Export
atuin history export     # Export all history

# Delete
atuin history delete <id>  # Delete specific command

# Re-import
atuin import auto        # Re-import bash history
```

---

## Troubleshooting

### Sync Issues
```bash
# Check status
atuin sync --status

# Force sync
atuin sync --force
```

### Re-import History
```bash
# If history seems incomplete
atuin import auto
atuin sync
```

### Reset (DANGER)
```bash
# Delete local database (will re-sync from server)
rm ~/.local/share/atuin/history.db
atuin sync
```

---

## Tips

1. **Backup encryption key** - Store `~/.local/share/atuin/key` in KeePassXC
2. **Use context filters** - Search by directory/host for better results
3. **Check failed commands** - `atuin search --exclude-exit 0` to debug
4. **Regular sync** - Atuin auto-syncs, but you can force with `atuin sync`

---

## Migration from .bash_history

**After Atuin setup:**
- `.bash_history` remains unchanged (backup)
- New commands go to Atuin
- `Ctrl+R` uses Atuin search
- Regular arrow keys work for session history

**Advantages over .bash_history:**
- ✅ Sync across machines (encrypted)
- ✅ Search with context
- ✅ Never lose history (cloud backup)
- ✅ No security risks (encrypted)
- ✅ Better search (fuzzy, filters)

---

## Self-Hosting (Optional)

If you prefer not to use atuin.sh servers:

1. Run your own Atuin server (Docker available)
2. Change in `atuin.nix`:
   ```nix
   sync_address = "https://your-server.com";
   ```

See: https://docs.atuin.sh/self-hosting/

---

## Next Steps After Install

1. ✅ Configured in `atuin.nix`
2. ⏳ Run `home-manager switch`
3. ⏳ Register: `atuin register -u mitsio -e dtsioumas0@gmail.com`
4. ⏳ Import: `atuin import auto`
5. ⏳ Test: Press `Ctrl+R` and search!

---

**Last Updated:** 2025-11-18
**Config:** `home-manager/atuin.nix`
