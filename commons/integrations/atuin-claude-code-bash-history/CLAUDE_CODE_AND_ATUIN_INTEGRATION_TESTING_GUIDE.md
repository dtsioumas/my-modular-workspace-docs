# Claude Code + Atuin Integration - Testing Guide

## What Was Done

### 1. **Migrated to Chezmoi** ✅
- **Bashrc**: Moved from `home-manager/shell.nix` to `~/.local/share/chezmoi/dot_bashrc.tmpl`
- **Claude Settings**: Created `~/.local/share/chezmoi/private_dot_claude/settings.json.tmpl`

### 2. **Installed Bun via Home-Manager** ✅
- Added `bun` package to `home-manager/home.nix`
- Configured in bashrc: `export BUN_INSTALL="$HOME/.bun"`
- Added to PATH: `$BUN_INSTALL/bin`

### 3. **Configured bash-history-mcp Integration** ✅

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

## Testing the Integration

### Test 1: Verify Bash Configuration

```bash
# Reload shell
exec bash

# Check Atuin is working
atuin --version
atuin history list | head

# Check Bun is available
bun --version
```

**Expected**: Atuin 18.10.0, Bun 1.3.2, history shows

### Test 2: Test Hook (Write Path)

**In Claude Code**, run this conversation:
```
Run this command for me: echo "test-from-claude-$(date +%s)"
```

Then **in your terminal**:
```bash
atuin history search "test-from-claude"
```

**Expected**: The echo command appears in Atuin history with timestamp and exit code

### Test 3: Test MCP Server (Read Path)

**In Claude Code**, ask:
```
Use the bash-history MCP tool to show my last 10 shell commands
```

**Expected**: Claude uses `bash-history.get_recent_history(10)` and shows your commands

### Test 4: Advanced Query

**In Claude Code**, ask:
```
Search my Atuin history for all 'git commit' commands from today and summarize what I committed
```

**Expected**: Claude uses `bash-history.search_history("git commit", ...)` and provides summary

## Troubleshooting

### Hook Not Running?

```bash
# Check if bunx works
bunx --version

# Test hook manually
echo '{"tool":"Bash","command":"ls","exit_code":0}' | bunx github:nitsanavni/bash-history-mcp hook

# Check if it logged to Atuin
atuin history last
```

### MCP Server Not Available?

**Restart Claude Code** for settings to reload.

Check MCP server is registered:
```bash
# In new Claude Code session, ask:
"List all available MCP servers"
```

Should show `bash-history` with tools:
- `search_history(query, limit?)`
- `get_recent_history(limit?)`

### Bun Not Found?

```bash
# Check home-manager installed it
which bun

# If not, reload shell environment
exec bash

# Or apply home-manager again
home-manager switch --flake .#mitsio@shoshin
```

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| Bashrc template | `~/.local/share/chezmoi/dot_bashrc.tmpl` | Shell configuration |
| Claude settings template | `~/.local/share/chezmoi/private_dot_claude/settings.json.tmpl` | Claude MCP + hooks |
| Rendered bashrc | `~/.bashrc` | Active shell config |
| Rendered Claude settings | `~/.claude/settings.json` | Active Claude config |
| Home-manager config | `~/.MyHome/MySpaces/my-modular-workspace/home-manager/` | Nix packages |

## Managing Configuration

### Update Bashrc

```bash
# Edit the template
chezmoi edit ~/.bashrc

# Or directly
vim ~/.local/share/chezmoi/dot_bashrc.tmpl

# Apply changes
chezmoi apply
```

### Update Claude Settings

```bash
# Edit the template
chezmoi edit ~/.claude/settings.json

# Apply changes
chezmoi apply

# Restart Claude Code for changes to take effect
```

### Add to Git

```bash
# Chezmoi dotfiles
cd ~/.local/share/chezmoi
git add dot_bashrc.tmpl private_dot_claude/settings.json.tmpl
git commit -m "Add Claude Code + Atuin integration via bash-history-mcp"
git push

# Home-manager config
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
git add home.nix shell.nix
git commit -m "feat: Add Bun, migrate bashrc to chezmoi"
git push
```

## Integration Architecture

```
┌─────────────────┐
│  Claude Code    │
│                 │
│  User requests  │
│  Bash command   │
└────────┬────────┘
         │
         │ Executes
         ▼
┌─────────────────┐
│  Bash Tool      │  ──┐
│                 │    │
│  Runs command   │    │ PostToolUse Hook
└─────────────────┘    │ (after execution)
         │             │
         │             ▼
         │    ┌──────────────────┐
         │    │ bunx bash-       │
         │    │ history-mcp hook │
         │    └────────┬─────────┘
         │             │
         │             │ Logs to
         │             ▼
         │    ┌──────────────────┐
         │    │ Atuin History DB │◄────┐
         │    └──────────────────┘     │
         │             ▲                │
         │             │ Reads from     │
         │             │                │
         └─────────────┼────────────────┘
                       │
              ┌────────┴─────────┐
              │ bash-history MCP │
              │ Server           │
              │ (bunx mcp)       │
              └──────────────────┘
                       ▲
                       │
              ┌────────┴─────────┐
              │  Claude Code     │
              │  Queries history │
              └──────────────────┘
```

## Next Session

**To test in next session:**
1. Open new terminal → Verify Atuin loads
2. Start new Claude Code session → Run test bash command
3. Check Atuin: `atuin history search "test-from-claude"`
4. Ask Claude to query history via MCP tools

**Done!** 🎉
