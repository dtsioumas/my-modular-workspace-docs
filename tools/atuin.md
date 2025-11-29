# Atuin - Modern Shell History

**Last Updated:** 2025-11-29
**Sources Merged:** ATUIN.md, CLAUDE_CODE_AND_ATUIN_INTEGRATION_TESTING_GUIDE.md
**Maintainer:** Mitsos

**Official:** https://atuin.sh/
**GitHub:** https://github.com/atuinsh/atuin
**Docs:** https://docs.atuin.sh/

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Daily Usage](#daily-usage)
- [Configuration](#configuration)
- [Claude Code Integration](#claude-code-integration)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

Modern shell history manager that replaces `.bash_history` with:
- **Encrypted sync** across machines
- **Fuzzy search** with context (directory, exit code, duration)
- **Cross-machine** history
- **Privacy-focused** (end-to-end encrypted)

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

### Restore on New Workspace

```bash
# 1. Install atuin (via home-manager)
home-manager switch --flake <path>/#mitsio@<hostname>

# 2. Login with existing account
atuin login -u mitsio

# 3. Sync history from cloud
atuin sync

# Done! Your entire shell history is now available
```

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

### Search Filters

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

### Key Features

1. **Context-Aware Search** - See when/where/how each command was run
2. **Privacy & Security** - End-to-end encrypted (server can't read history)
3. **Multi-Machine Sync** - Auto-syncs every 10 minutes

### Important Paths

- **Local DB:** `~/.local/share/atuin/history.db`
- **Encryption key:** `~/.local/share/atuin/key` (backup this!)

---

## Claude Code Integration

Atuin integrates with Claude Code via the `bash-history-mcp` tool.

### Architecture

```
Claude Code → Bash Tool → PostToolUse Hook → Atuin DB
                                              ↑
Claude Code ← bash-history MCP ← Atuin DB ───┘
```

### Configuration (Claude settings.json)

**PostToolUse Hook** (Write to Atuin):
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "bunx github:nitsanavni/bash-history-mcp hook"
        }]
      }
    ]
  }
}
```

**MCP Server** (Read from Atuin):
```json
{
  "mcpServers": {
    "bash-history": {
      "command": "bunx",
      "args": ["github:nitsanavni/bash-history-mcp", "mcp"]
    }
  }
}
```

### Testing Integration

**Test Write Path:**
```bash
# In Claude Code, run a command, then verify:
atuin history search "test-from-claude"
```

**Test Read Path:**
```
# Ask Claude Code:
"Use the bash-history MCP tool to show my last 10 shell commands"
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

### Hook Not Running?

```bash
# Check if bunx works
bunx --version

# Test hook manually
echo '{"tool":"Bash","command":"ls","exit_code":0}' | bunx github:nitsanavni/bash-history-mcp hook
```

---

## Tips

1. **Backup encryption key** - Store `~/.local/share/atuin/key` in KeePassXC
2. **Use context filters** - Search by directory/host for better results
3. **Check failed commands** - `atuin search --exclude-exit 0` to debug
4. **Regular sync** - Atuin auto-syncs, but you can force with `atuin sync`

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

## References

- **Official Docs:** https://docs.atuin.sh/
- **GitHub:** https://github.com/atuinsh/atuin
- **bash-history-mcp:** https://github.com/nitsanavni/bash-history-mcp

---

*Migrated from docs/commons/toolbox/atuin/ and docs/commons/integrations/atuin-claude-code-bash-history/ on 2025-11-29*
