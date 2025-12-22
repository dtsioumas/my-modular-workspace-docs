# VSCodium & Kitty Agent Integration

**Status:** Implemented (Week 52, 2025)
**Context:** Enhanced Agent Configuration

This document describes the unified integration between VSCodium, Kitty Terminal, and the AI Agents (Claude Code, Gemini CLI, Codex).

## 1. VSCodium Integration

### Keybindings
Send selected text from VSCodium directly to an agent in the terminal.

| Keybinding | Action | Command |
|------------|--------|---------|
| `Ctrl+Alt+C` | Send selection to **Claude Code** | `echo '${selectedText}' | claude` |
| `Ctrl+Alt+G` | Send selection to **Gemini CLI** | `echo '${selectedText}' | gemini` |
| `Ctrl+Alt+X` | Send selection to **Codex** | `echo '${selectedText}' | codex` |

### Tasks
Accessible via `Ctrl+Shift+P` -> `Tasks: Run Task`:
- **Send to Claude Code**
- **Send File to Claude Code** (Opens current file in Claude)
- **Send to Gemini CLI**
- **Send to Codex**

## 2. Kitty Terminal Integration

### Agent Launch Shortcuts
Launch agents in a new tab with the current working directory.

| Keybinding | Action |
|------------|--------|
| `Ctrl+Shift+A` then `C` | Launch **Claude Code** |
| `Ctrl+Shift+A` then `G` | Launch **Gemini CLI** |
| `Ctrl+Shift+A` then `X` | Launch **Codex** |
| `Ctrl+Shift+A` then `V` | Launch **VSCodium** (background) |

## 3. Configuration Files

- **VSCodium Tasks:** `~/.config/VSCodium/User/tasks.json` (managed by `dotfiles/private_dot_config/VSCodium/User/tasks.json.tmpl`)
- **VSCodium Keys:** `~/.config/VSCodium/User/keybindings.json` (managed by `dotfiles/private_dot_config/VSCodium/User/keybindings.json.tmpl`)
- **Kitty Config:** `~/.config/kitty/kitty.conf` (managed by `dotfiles/private_dot_config/kitty/kitty.conf`)
