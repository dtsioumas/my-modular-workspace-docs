# Warp + Kitty + MCP Integration Research

**Research Date:** 2025-12-05
**Last Updated:** 2025-12-07
**Status:** Complete (Enhanced with Warp CLI Discovery)
**Researcher:** Claude (Opus 4.5) + Mitsos

---

## Executive Summary

This research investigates the feasibility of running Warp terminal "under" kitty and configuring MCP servers for Warp similar to Claude Code.

**Key Finding:** Running Warp "inside" kitty is **technically impossible** - both are terminal emulators and cannot be nested. However, an elegant **dual-terminal workflow with shared MCP ecosystem** achieves the desired outcome.

**NEW DISCOVERY (2025-12-07):** The **Warp CLI** enables running Warp agent features from ANY terminal, including kitty! This creates a **third integration tier** that bridges both terminals.

---

## 1. Problem Analysis

### Original Request
> "Configure Warp and customize it to work well with kitty, maybe using zellij"

### Technical Reality
- **Warp** = Terminal emulator (GPU-accelerated, AI-powered, Rust-based)
- **Kitty** = Terminal emulator (GPU-accelerated, highly configurable)
- **Zellij** = Terminal multiplexer (runs *inside* a terminal emulator)

**Constraint:** Terminal emulators cannot run inside each other. They are both GUI applications that render terminal content.

### Reframed Problem
How to achieve a unified workflow that combines:
1. Kitty's proven reliability, transparency, and customization
2. Warp's AI capabilities and MCP server integration
3. Shared AI context via MCP protocol

---

## 2. Research Findings

### 2.1 Warp MCP Server Support

**Source:** [Warp MCP Documentation](https://docs.warp.dev/knowledge-and-collaboration/mcp)

Warp has full MCP support with:
- **CLI Server (Command)**: Local npx/docker commands
- **SSE Server (URL)**: Remote HTTP endpoints
- UI-based management (Settings > MCP Servers)
- OAuth and API key authentication

**Configuration Format (similar to Claude Code):**
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "value"
      }
    }
  }
}
```

**Location:** Warp stores MCP config internally, accessed via:
- Settings > MCP Servers
- Warp Drive > Personal > MCP Servers
- Command Palette > "Open MCP Servers"

### 2.2 Zellij + Warp Compatibility

**Source:** [GitHub Issue #3935](https://github.com/warpdotdev/Warp/issues/3935)

**Known Issues (149+ upvotes):**
- Alt key shortcuts don't work properly in zellij inside Warp
- Display issues (whitespace, not filling terminal)
- Auto-start zellij via .zshrc breaks keyboard input
- Warp features don't work inside zellij

**Verdict:** Zellij inside Warp is NOT recommended. Use zellij inside Kitty instead.

### 2.3 Kitty + Zellij Integration (Reference)

**Source:** `sessions/kitty-configuration/RESEARCH_FINDINGS.md`

Previous research confirmed:
- Zellij works excellently inside Kitty
- zjstatus provides beautiful status bar
- Catppuccin theme works in both
- Keyboard shortcuts work properly

### 2.4 Warp CLI (NEW - 2025-12-07)

**Source:** [Warp CLI Documentation](https://docs.warp.dev/developers/cli)

**Game-Changing Discovery:** Warp provides a standalone CLI that can run agent features from ANY terminal!

**Key Capabilities:**
```bash
# Run agent from any terminal (including kitty!)
warp-terminal agent run --prompt "fix this error"

# Use MCP servers
warp-terminal agent run --prompt "search docs" --mcp-server UUID

# Use specific agent profile
warp-terminal agent run --profile PROFILE_ID --prompt "task"

# Share session with team
warp-terminal agent run --share team:edit --prompt "debug this"

# API key authentication (for CI/CD or remote)
export WARP_API_KEY="wk-xxx..."
warp-terminal agent run --prompt "analyze codebase"
```

**Installation on Linux:**
- Bundled: `warp-terminal` command (comes with Warp app)
- Standalone: `warp-cli` package via apt/yum/pacman

**Agent Profile for CLI:**
- CLI needs a permissive profile (allow reads/writes/commands)
- Create dedicated profile via: Settings > Agent Profiles
- Get profile ID: `warp-terminal agent profile list`

**MCP Server Usage:**
- Get server UUIDs: `warp-terminal mcp list`
- MCP env vars must be set on remote hosts (not synced)

### 2.5 Warp Full Terminal Use (NEW - 2025-12-07)

**Source:** [Full Terminal Use Documentation](https://docs.warp.dev/agents/full-terminal-use)

**What It Does:** Warp agents can interact with interactive terminal applications:
- Database shells: psql, mysql, sqlite
- Debuggers: gdb, lldb
- REPLs: python, node, ipython
- Text editors: vim, nano
- Dev servers: npm run dev, uvicorn

**How It Works:**
1. Start interactive command (or let agent start it)
2. Agent reads terminal buffer in real-time
3. Agent writes to PTY to run commands
4. User can take over/hand back control anytime

**Limitation:** Full Terminal Use requires the Warp GUI app, not available via CLI alone.

### 2.6 Kitty Remote Control Protocol (NEW - 2025-12-07)

**Source:** [Kitty Remote Control](https://sw.kovidgoyal.net/kitty/remote-control/)

**Capabilities for Integration:**
```bash
# Send text to specific windows
kitten @ send-text --match "cmdline:vim" "Hello"

# Launch new window with command
kitten @ launch --title "Warp Agent" warp-terminal agent run --prompt "task"

# Focus specific window
kitten @ focus-window --match "title:Warp"

# List windows
kitten @ ls
```

**Requirements:**
- Enable in kitty.conf: `allow_remote_control yes`
- Or start kitty with: `kitty -o allow_remote_control=yes`

**Integration Potential:**
- Create bash aliases that invoke Warp CLI
- Keyboard shortcuts in kitty to open Warp agent prompts
- Scripts that orchestrate both terminals

---

## 3. Solution Architecture (ENHANCED)

### Recommended: "Three-Tier Integration with Warp CLI Bridge"

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNIFIED MCP ECOSYSTEM                        │
│                                                                 │
│  MCP Servers: context7, exa, firecrawl, time, sequential-      │
│               thinking, fetch, grok, chatgpt, etc.              │
└─────────────────────────┬───────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          │               │               │
          ▼               ▼               ▼
    ┌───────────┐   ┌───────────┐   ┌───────────┐
    │  Claude   │   │   Warp    │   │  Other    │
    │   Code    │   │ Terminal  │   │ MCP Hosts │
    │   CLI     │   │ + CLI     │   │           │
    └───────────┘   └───────────┘   └───────────┘
          │               │
          │       ┌───────┴───────┐
          │       │               │
          ▼       ▼               ▼
    ┌───────────────────┐   ┌───────────┐
    │      Kitty        │   │   Warp    │
    │    (Primary)      │   │   App     │
    │  + Zellij         │   │ (AI GUI)  │
    │  + Warp CLI ←─────┼───│           │
    │  (Quick AI)       │   │           │
    └───────────────────┘   └───────────┘
```

### NEW: Three-Tier Architecture

| Tier | Component | Use Case | Access Method |
|------|-----------|----------|---------------|
| **Tier 1** | Warp App (GUI) | Complex AI tasks, Full Terminal Use, interactive sessions | Ctrl+F12 hotkey |
| **Tier 2** | Warp CLI in Kitty | Quick AI queries, single-shot agent runs | `wai "prompt"` alias or Meta+W |
| **Tier 3** | Kitty Remote Control | Automation, scripting, window orchestration | `kitten @` commands |

### Terminal Role Division

| Terminal | Role | Use Cases |
|----------|------|-----------|
| **Kitty** | Primary daily terminal | Shell work, git, file management, zellij sessions |
| **Warp** | AI assistant terminal | AI command generation, MCP-enhanced workflows |
| **Claude Code** | CLI AI coding | Code writing, file editing (runs in kitty) |

### Keyboard Shortcut Harmony

| Shortcut | Application | Action |
|----------|-------------|--------|
| F12 | Kitty | Panel kitten (dropdown) |
| **Ctrl+F12** | Warp (global) | Toggle Warp window |
| Meta+Shift+K | KDE Plasma | Focus/launch Kitty |
| Meta+Shift+W | KDE Plasma | Launch Warp |
| Meta+Shift+D | KDE Plasma | Launch Warp Dev Workspace |
| F5/F6 | Kitty | Horizontal/Vertical split |
| Ctrl+P | Zellij (in kitty) | Pane mode |
| Ctrl+T | Zellij (in kitty) | Tab mode |
| **Meta+W** | Kitty (NEW) | Run Warp CLI agent |

### NEW: Warp CLI Integration Examples

**Bash Aliases (add to ~/.bashrc via chezmoi):**
```bash
# Quick Warp AI alias
wai() {
    warp-terminal agent run --prompt "$*"
}

# Warp AI with specific MCP server
wai-docs() {
    warp-terminal agent run --mcp-server "CONTEXT7_UUID" --prompt "$*"
}

# Warp AI with coding profile
wai-code() {
    warp-terminal agent run --profile "CODING_PROFILE_ID" --prompt "$*"
}
```

**Kitty Keyboard Shortcut (add to kitty.conf):**
```conf
# Meta+W: Open Warp agent prompt in new window
map super+w launch --type=overlay sh -c 'read -p "Warp AI: " prompt && warp-terminal agent run --prompt "$prompt"'
```

**Kitty Remote Control Script:**
```bash
#!/bin/bash
# warp-in-kitty.sh - Run Warp agent from kitty remote control
kitten @ launch --title "Warp Agent" --keep-focus warp-terminal agent run --prompt "$1"
```

---

## 4. MCP Servers to Migrate

From `~/.claude.json`, migrate these servers to Warp:

### Priority 1: Core AI Enhancement
| Server | Type | Purpose |
|--------|------|---------|
| context7 | CLI | Library documentation |
| exa | HTTP | Web search |
| firecrawl | CLI | Web scraping |
| sequential-thinking | CLI | Deep reasoning |

### Priority 2: Utility
| Server | Type | Purpose |
|--------|------|---------|
| time | CLI | Timezone awareness |
| fetch | CLI | URL fetching |
| read-website-fast | CLI | Fast web reading |

### Priority 3: Optional Multi-Model
| Server | Type | Purpose |
|--------|------|---------|
| grok | CLI | X.AI model access |
| chatgpt | CLI | OpenAI model access |

### Claude Code MCP Config Reference
```json
{
  "context7": {
    "command": "/run/current-system/sw/bin/npx",
    "args": ["-y", "@upstash/context7-mcp", "--api-key", "ctx7sk-xxx"]
  },
  "exa": {
    "type": "http",
    "url": "https://mcp.exa.ai/mcp"
  },
  "firecrawl": {
    "command": "npx",
    "args": ["-y", "firecrawl-mcp"],
    "env": { "FIRECRAWL_API_KEY": "fc-xxx" }
  },
  "time": {
    "command": "uvx",
    "args": ["mcp-server-time", "--local-timezone=Europe/Athens"]
  },
  "sequential-thinking": {
    "command": "uvx",
    "args": ["--from", "git+https://github.com/arben-adm/mcp-sequential-thinking",
             "--with", "portalocker", "mcp-sequential-thinking"]
  }
}
```

---

## 5. Configuration Management Strategy

### Chezmoi Structure
```
dotfiles/
├── dot_config/
│   ├── kitty/                    # Existing kitty config
│   │   └── kitty.conf
│   └── warp-terminal/            # NEW: Warp settings (if exportable)
│       └── (user_preferences.json is generated, may not sync well)
└── dot_local/
    └── share/
        └── warp-terminal/
            └── launch_configurations/
                └── my-modular-workspace-dev.yaml  # Existing
```

### MCP Server Management

**Challenge:** Warp stores MCP config internally (not in a simple JSON file like Claude Code).

**Solutions:**
1. **Manual Setup**: Configure MCP servers via Warp UI (documented below)
2. **Export/Import**: Warp supports JSON paste for multiple servers
3. **Team Sharing**: Use Warp's share feature for team configs

---

## 6. Implementation Checklist

### Phase 1: MCP Server Configuration in Warp
- [ ] Open Warp > Settings > MCP Servers
- [ ] Add context7 server (with API key)
- [ ] Add exa server (HTTP endpoint)
- [ ] Add firecrawl server (with API key)
- [ ] Add time server
- [ ] Add sequential-thinking server
- [ ] Test each server with Warp AI

### Phase 2: Shortcut Configuration
- [ ] Configure Warp global hotkey (Ctrl+F12 recommended)
- [ ] Add KDE Plasma shortcuts for Warp
- [ ] Verify no conflicts with Kitty shortcuts
- [ ] Document final shortcut map

### Phase 3: Workflow Integration
- [ ] Test dual-terminal workflow
- [ ] Create additional launch configs if needed
- [ ] Add to chezmoi tracking

---

## 7. Important Limitations

1. **No Warp in Kitty**: Cannot nest terminal emulators (but Warp CLI bridges this!)
2. **Zellij in Warp**: Has issues - use zellij in Kitty instead
3. **MCP Config Sync**: Warp MCP config not easily exportable to chezmoi
4. **API Keys**: Must be manually configured in Warp (security feature)
5. **Full Terminal Use**: Only available in Warp GUI app, not via CLI
6. **CLI MCP Env Vars**: Not synced between hosts - must set manually on remote
7. **CLI Agent Profile**: Requires dedicated permissive profile for CLI usage

---

## 8. Decision Matrix

| Question | Decision | Rationale |
|----------|----------|-----------|
| Can Warp run under kitty? | **No** (but CLI can!) | Terminal emulators can't nest, but Warp CLI bridges them |
| Should I replace kitty with Warp? | **No** | Kitty + zellij works well; Warp has zellij issues |
| How to share AI context? | **MCP Servers** | Same servers in Claude Code and Warp |
| Best shortcut for Warp GUI? | **Ctrl+F12** | Avoids F12 (kitty panel) conflict |
| Best shortcut for Warp CLI? | **Meta+W** | Quick AI access from kitty |
| Config management? | **Hybrid** | Chezmoi for launch configs; Warp UI for MCP |
| Quick AI in kitty? | **Warp CLI** | `wai "prompt"` alias for instant AI help |

---

## 9. References

### Original Research (2025-12-05)
- [Warp MCP Documentation](https://docs.warp.dev/knowledge-and-collaboration/mcp)
- [Warp Zellij Issue #3935](https://github.com/warpdotdev/Warp/issues/3935)
- [Context7 MCP Server](https://github.com/upstash/context7)
- [Kitty + Zellij Research](../sessions/kitty-configuration/RESEARCH_FINDINGS.md)
- [Warp Complete Guide](../tools/warp/WARP_COMPLETE_GUIDE.md)

### Deep Research (2025-12-07)
- [Warp CLI Documentation](https://docs.warp.dev/developers/cli)
- [Full Terminal Use](https://docs.warp.dev/agents/full-terminal-use)
- [Kitty Remote Control Protocol](https://sw.kovidgoyal.net/kitty/remote-control/)
- [Kitty Remote Control Commands](https://man.archlinux.org/man/kitten-@.1.en)
- [doctorfree/kitty-control](https://github.com/doctorfree/kitty-control) - Community tool for kitty control

---

**Document Status:** Complete (Enhanced 2025-12-07)
**Next Steps:** See Implementation Plan (PLAN_WARP_MCP_KITTY_INTEGRATION.md)
