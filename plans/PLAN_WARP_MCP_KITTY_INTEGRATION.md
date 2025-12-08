# Implementation Plan: Warp MCP + Kitty Integration

**Created:** 2025-12-05
**Last Updated:** 2025-12-07
**Status:** Ready for Implementation (Enhanced with Warp CLI)
**Related Research:** [../researches/WARP_KITTY_MCP_INTEGRATION_RESEARCH.md](../researches/WARP_KITTY_MCP_INTEGRATION_RESEARCH.md)

---

## Overview

This plan implements a **three-tier integration** with:
- **Tier 1: Warp App** - AI assistant terminal for complex tasks & Full Terminal Use
- **Tier 2: Warp CLI in Kitty** - Quick AI queries without leaving kitty
- **Tier 3: Kitty** - Primary terminal with zellij multiplexing
- **Shared MCP ecosystem** for unified AI context across all tiers

---

## Phase 1: Configure Warp MCP Servers

**Objective:** Port Claude Code's MCP servers to Warp

### Step 1.1: Add Context7 Server
```
1. Open Warp
2. Settings > MCP Servers > + Add
3. Paste JSON:
```
```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp", "--api-key", "ctx7sk-cf785e40-8581-4dcd-a9c5-01a8de83ec67"]
  }
}
```
```
4. Click Start
5. Verify: Ask Warp AI "What's in the React documentation?"
```

### Step 1.2: Add Exa Web Search Server
```
1. Settings > MCP Servers > + Add
2. Paste JSON:
```
```json
{
  "exa": {
    "url": "https://mcp.exa.ai/mcp"
  }
}
```
```
3. Click Start
4. Verify: Ask Warp AI to search for something
```

### Step 1.3: Add Firecrawl Server
```
1. Settings > MCP Servers > + Add
2. Paste JSON:
```
```json
{
  "firecrawl": {
    "command": "npx",
    "args": ["-y", "firecrawl-mcp"],
    "env": {
      "FIRECRAWL_API_KEY": "fc-4946bf64171a475a93bb660d60a9b614"
    }
  }
}
```
```
3. Click Start
4. Verify: Ask Warp AI to scrape a webpage
```

### Step 1.4: Add Time Server
```
1. Settings > MCP Servers > + Add
2. Paste JSON:
```
```json
{
  "time": {
    "command": "uvx",
    "args": ["mcp-server-time", "--local-timezone=Europe/Athens"]
  }
}
```
```
3. Click Start
4. Verify: Ask Warp AI "What time is it?"
```

### Step 1.5: Add Sequential Thinking Server
```
1. Settings > MCP Servers > + Add
2. Paste JSON:
```
```json
{
  "sequential-thinking": {
    "command": "uvx",
    "args": ["--from", "git+https://github.com/arben-adm/mcp-sequential-thinking", "--with", "portalocker", "mcp-sequential-thinking"]
  }
}
```
```
3. Click Start
4. Verify: Ask Warp AI to "think deeply about" something
```

### Step 1.6: Add Fetch Server
```
1. Settings > MCP Servers > + Add
2. Paste JSON:
```
```json
{
  "fetch": {
    "command": "uvx",
    "args": ["mcp-server-fetch"]
  }
}
```
```
3. Click Start
```

### Step 1.7: Add Read Website Fast Server
```
1. Settings > MCP Servers > + Add
2. Paste JSON:
```
```json
{
  "read-website-fast": {
    "command": "npx",
    "args": ["-y", "@just-every/mcp-read-website-fast"]
  }
}
```
```
3. Click Start
```

### Step 1.8 (Optional): Add Grok Server
```
1. Settings > MCP Servers > + Add
2. Paste JSON:
```
```json
{
  "grok": {
    "command": "npx",
    "args": ["@pyroprompts/any-chat-completions-mcp"],
    "env": {
      "AI_CHAT_KEY": "xai-YOUR_KEY_HERE",
      "AI_CHAT_NAME": "Grok",
      "AI_CHAT_MODEL": "grok-3-mini",
      "AI_CHAT_BASE_URL": "https://api.x.ai/v1"
    }
  }
}
```
```
3. Click Start
```

---

## Phase 1.5: Configure Warp CLI (NEW)

**Objective:** Enable Warp agent features from kitty terminal

### Step 1.5.1: Verify Warp CLI Installation
```bash
# Check if warp-terminal CLI is available (bundled with Warp app)
which warp-terminal
warp-terminal --version

# If not found, the Warp app installation should include it
# On Linux, warp-terminal command is available after installing Warp
```

### Step 1.5.2: Generate Warp API Key (for remote/CI use)
```
1. Open Warp
2. Settings > Platform > API Keys
3. Click "+ Create API Key"
4. Name: "CLI Access"
5. Copy the key (starts with wk-...)
6. Store securely in KeePassXC
```

### Step 1.5.3: Create CLI Agent Profile
```
1. Open Warp
2. Settings > Agent Profiles
3. Click "Create Profile"
4. Name: "CLI Usage"
5. Configure permissions:
   - File Operations: Allow reading and writing
   - Code Diffs: Allow applying
   - Commands: Allow executing (with default denylist)
   - MCP Servers: Allow specific servers you want CLI to use
6. Save profile
7. Get profile ID:
   warp-terminal agent profile list
```

### Step 1.5.4: Get MCP Server UUIDs
```bash
# List all configured MCP servers with their UUIDs
warp-terminal mcp list

# Output example:
# +--------------------------------------+--------------------+
# | UUID                                 | Name               |
# +===============================================+
# | 1deb1b14-b6e5-4996-ae99-233b7555d2d0 | context7           |
# | 65450c32-9eb1-4c57-8804-0861737acbc4 | exa                |
# +--------------------------------------+--------------------+

# Save these UUIDs for use in bash aliases
```

### Step 1.5.5: Add Bash Aliases (via Chezmoi)
```bash
# Add to dotfiles/dot_bashrc.tmpl or create new file
# dotfiles/dot_config/bash/warp-aliases.sh

# ========================================
# Warp CLI Aliases for Kitty Integration
# ========================================

# Quick Warp AI - simple prompt
wai() {
    warp-terminal agent run --prompt "$*"
}

# Warp AI with documentation MCP server
wai-docs() {
    warp-terminal agent run \
        --mcp-server "REPLACE_WITH_CONTEXT7_UUID" \
        --prompt "$*"
}

# Warp AI with coding profile
wai-code() {
    warp-terminal agent run \
        --profile "REPLACE_WITH_CLI_PROFILE_ID" \
        --prompt "$*"
}

# Warp AI with web search
wai-search() {
    warp-terminal agent run \
        --mcp-server "REPLACE_WITH_EXA_UUID" \
        --prompt "$*"
}

# Warp AI - fix last command error
wai-fix() {
    local last_cmd=$(fc -ln -1)
    local last_output=$(fc -ln -1 | sh 2>&1)
    warp-terminal agent run --prompt "Fix this command error: Command: $last_cmd Output: $last_output"
}
```

### Step 1.5.6: Add to Chezmoi
```bash
# Create the alias file
chezmoi add ~/.config/bash/warp-aliases.sh

# Or add directly to .bashrc
# Add this line to dotfiles/dot_bashrc.tmpl:
# source ~/.config/bash/warp-aliases.sh
```

### Step 1.5.7: Test Warp CLI
```bash
# Reload bash config
source ~/.bashrc

# Test basic prompt
wai "what is the current directory structure?"

# Test with MCP server
wai-docs "explain React hooks"

# Test quick fix
ls nonexistent_file 2>&1
wai-fix
```

---

## Phase 2: Configure Warp Shortcuts

**Objective:** Set up non-conflicting shortcuts

### Step 2.1: Warp Global Hotkey
```
1. Open Warp
2. Settings > Features > Keys
3. Set Global Hotkey:
   - Type: "Dedicated hotkey window"
   - Key: Ctrl+F12 (avoids kitty's F12)
   - Position: Top
   - Size: 80% height, 100% width
   - Auto-hide: Enabled
4. Save
```

### Step 2.2: KDE Plasma Shortcuts
```
1. System Settings > Shortcuts > Custom Shortcuts
2. Add new shortcuts:

   Name: "Warp Terminal"
   Command: warp-terminal
   Key: Meta+Shift+W

   Name: "Warp Dev Workspace"
   Command: warp-terminal --launch-config "My Modular Workspace Dev"
   Key: Meta+Shift+D

   Name: "Focus Kitty"
   Command: kitty (or use KDE's focus window)
   Key: Meta+Shift+K
```

### Step 2.3: Verify Shortcut Map
| Shortcut | App | Action | Conflict? |
|----------|-----|--------|-----------|
| F12 | Kitty | Panel | ✅ No |
| Ctrl+F12 | Warp | Global hotkey | ✅ No |
| F5 | Kitty | Horizontal split | ✅ No |
| F6 | Kitty | Vertical split | ✅ No |
| Meta+Shift+W | KDE | Launch Warp | ✅ No |
| Meta+Shift+D | KDE | Warp Dev Workspace | ✅ No |
| Meta+Shift+K | KDE | Focus Kitty | ✅ No |

---

## Phase 3: Customize Warp for Workflow

### Step 3.1: Theme Consistency
```
1. In Warp: Ctrl+Shift+F9 (Theme browser)
2. Select "Dracula" (matches kitty current-theme.conf)
3. Or select theme matching your preference
```

### Step 3.2: Verify Launch Configurations
```bash
# Check existing launch config
cat ~/.local/share/warp-terminal/launch_configurations/my-modular-workspace-dev.yaml

# Should show 3 tabs: Home Manager, Docs, Ansible
```

### Step 3.3: Create Additional Launch Configs (Optional)
If needed, create more launch configs in:
`~/.local/share/warp-terminal/launch_configurations/`

Example for SRE work:
```yaml
---
name: SRE Monitoring
active_window_index: 0
windows:
  - active_tab_index: 0
    tabs:
      - title: Logs
        layout:
          cwd: /var/log
        color: red
      - title: K8s
        layout:
          cwd: ~/.MyHome/MySpaces/my-modular-workspace
          commands:
            - exec: kubectl get pods -A
        color: blue
```

### Step 3.4: Add New Launch Configs to Chezmoi
```bash
# Add any new launch configs
chezmoi add ~/.local/share/warp-terminal/launch_configurations/*.yaml
chezmoi diff
chezmoi apply
```

---

## Phase 4: Workflow Integration

### Step 4.1: Daily Workflow Pattern
```
1. Start session: Open Kitty (default terminal)
2. Multiplexing: Use zellij inside Kitty for panes/tabs
3. AI assistance: Press Ctrl+F12 for Warp dropdown
4. AI query: Ask Warp AI for help (uses MCP servers)
5. Continue: Press Ctrl+F12 to hide Warp
6. Project work: Use Meta+Shift+D for Warp dev workspace
```

### Step 4.2: Verify Integration
```bash
# Test 1: Kitty works normally
kitty  # Should open with zellij integration

# Test 2: Warp global hotkey
# Press Ctrl+F12 - Warp should drop down

# Test 3: Warp MCP servers
# In Warp: "Search for NixOS documentation using context7"

# Test 4: KDE shortcuts
# Press Meta+Shift+D - Warp dev workspace should open
```

---

## Phase 5: Documentation & Tracking

### Step 5.1: Update Warp Guide
Add MCP configuration section to:
`docs/tools/warp/WARP_COMPLETE_GUIDE.md`

### Step 5.2: Update Chezmoi Tracking
Ensure these are tracked:
- `~/.local/share/warp-terminal/launch_configurations/*.yaml`

Note: `~/.config/warp-terminal/user_preferences.json` is generated by Warp and may not sync well.

### Step 5.3: Mark Status
Update `docs/tools/warp/README.md`:
```markdown
### Current Status
- ✅ Research completed
- ✅ Implementation plan ready
- ✅ Installation complete (home-manager)
- ✅ MCP servers configured
- ✅ Shortcuts configured
- ✅ Kitty integration verified
```

---

## Summary Checklist

- [ ] Phase 1: MCP Servers in Warp App
  - [ ] context7
  - [ ] exa
  - [ ] firecrawl
  - [ ] time
  - [ ] sequential-thinking
  - [ ] fetch
  - [ ] read-website-fast
  - [ ] grok (optional)

- [ ] Phase 1.5: Warp CLI Setup (NEW)
  - [ ] Verify warp-terminal CLI available
  - [ ] Generate API key (optional, for remote)
  - [ ] Create CLI agent profile
  - [ ] Get MCP server UUIDs
  - [ ] Add bash aliases (wai, wai-docs, wai-code, wai-fix)
  - [ ] Add to chezmoi
  - [ ] Test Warp CLI from kitty

- [ ] Phase 2: Shortcuts
  - [ ] Warp global hotkey (Ctrl+F12)
  - [ ] KDE shortcuts
  - [ ] Kitty shortcut for Warp CLI (Meta+W)

- [ ] Phase 3: Customization
  - [ ] Theme
  - [ ] Launch configs

- [ ] Phase 4: Integration
  - [ ] Test three-tier workflow
  - [ ] Verify MCP servers work in app
  - [ ] Verify Warp CLI works from kitty

- [ ] Phase 5: Documentation
  - [ ] Update guides
  - [ ] Chezmoi tracking

---

## Critical Notes

1. **API Keys**: The MCP configs above contain actual API keys. Handle with care.
2. **Warp + Zellij**: Do NOT try to run zellij inside Warp (known issues).
3. **Nesting**: Cannot run Warp inside Kitty - they are both terminal emulators.
4. **MCP Config**: Warp stores MCP config internally, not in a simple file.
5. **Warp CLI Bridge**: Use Warp CLI (`warp-terminal agent run`) to get AI help without leaving kitty!
6. **CLI Agent Profile**: Create a dedicated permissive profile for CLI usage.
7. **MCP UUIDs**: Get server UUIDs via `warp-terminal mcp list` for CLI commands.
8. **Full Terminal Use**: Only available in Warp GUI app, not via CLI.

---

## Architecture Summary (Three-Tier)

```
┌─────────────────────────────────────────────────────────────────┐
│                         USE CASE                                │
├─────────────────────────────────────────────────────────────────┤
│ Complex AI task, Full Terminal Use  →  Warp App (Ctrl+F12)     │
│ Quick AI query from kitty           →  Warp CLI (wai "prompt") │
│ Daily terminal work, multiplexing   →  Kitty + Zellij          │
└─────────────────────────────────────────────────────────────────┘
```

---

**Plan Status:** Ready for Implementation (Enhanced 2025-12-07)
**Estimated Effort:** ~45-60 minutes for all phases (including CLI setup)
**Dependencies:** Warp installed via home-manager (done)
