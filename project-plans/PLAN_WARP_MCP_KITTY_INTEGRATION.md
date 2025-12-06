# Implementation Plan: Warp MCP + Kitty Integration

**Created:** 2025-12-05
**Status:** Ready for Implementation
**Related Research:** [../researches/WARP_KITTY_MCP_INTEGRATION_RESEARCH.md](../researches/WARP_KITTY_MCP_INTEGRATION_RESEARCH.md)

---

## Overview

This plan implements a **dual-terminal workflow** with:
- **Kitty** as primary terminal (with zellij for multiplexing)
- **Warp** as AI assistant terminal (with MCP servers from Claude Code)
- **Shared MCP ecosystem** for unified AI context

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

- [ ] Phase 1: MCP Servers
  - [ ] context7
  - [ ] exa
  - [ ] firecrawl
  - [ ] time
  - [ ] sequential-thinking
  - [ ] fetch
  - [ ] read-website-fast
  - [ ] grok (optional)

- [ ] Phase 2: Shortcuts
  - [ ] Warp global hotkey (Ctrl+F12)
  - [ ] KDE shortcuts

- [ ] Phase 3: Customization
  - [ ] Theme
  - [ ] Launch configs

- [ ] Phase 4: Integration
  - [ ] Test workflow
  - [ ] Verify MCP servers work

- [ ] Phase 5: Documentation
  - [ ] Update guides
  - [ ] Chezmoi tracking

---

## Critical Notes

1. **API Keys**: The MCP configs above contain actual API keys. Handle with care.
2. **Warp + Zellij**: Do NOT try to run zellij inside Warp (known issues).
3. **Nesting**: Cannot run Warp inside Kitty - they are both terminal emulators.
4. **MCP Config**: Warp stores MCP config internally, not in a simple file.

---

**Plan Status:** Ready for Implementation
**Estimated Effort:** ~30-45 minutes for all phases
**Dependencies:** Warp installed via home-manager (done)
