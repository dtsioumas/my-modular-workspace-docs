# Warp + Kitty + MCP Integration Research

**Research Date:** 2025-12-05
**Status:** Complete
**Researcher:** Claude (Opus 4.5) + Mitsos

---

## Executive Summary

This research investigates the feasibility of running Warp terminal "under" kitty and configuring MCP servers for Warp similar to Claude Code.

**Key Finding:** Running Warp "inside" kitty is **technically impossible** - both are terminal emulators and cannot be nested. However, an elegant **dual-terminal workflow with shared MCP ecosystem** achieves the desired outcome.

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

---

## 3. Solution Architecture

### Recommended: "Unified MCP Ecosystem with Dual-Terminal Workflow"

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
    │   CLI     │   │           │   │           │
    └───────────┘   └───────────┘   └───────────┘
          │               │
          │               │
          ▼               ▼
    ┌───────────┐   ┌───────────┐
    │   Kitty   │   │   Warp    │
    │ (Primary) │   │(AI Tasks) │
    │ + Zellij  │   │           │
    └───────────┘   └───────────┘
```

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

1. **No Warp in Kitty**: Cannot nest terminal emulators
2. **Zellij in Warp**: Has issues - use zellij in Kitty instead
3. **MCP Config Sync**: Warp MCP config not easily exportable to chezmoi
4. **API Keys**: Must be manually configured in Warp (security feature)

---

## 8. Decision Matrix

| Question | Decision | Rationale |
|----------|----------|-----------|
| Can Warp run under kitty? | **No** | Both are terminal emulators |
| Should I replace kitty with Warp? | **No** | Kitty + zellij works well; Warp has zellij issues |
| How to share AI context? | **MCP Servers** | Same servers in Claude Code and Warp |
| Best shortcut for Warp? | **Ctrl+F12** | Avoids F12 (kitty panel) conflict |
| Config management? | **Hybrid** | Chezmoi for launch configs; Warp UI for MCP |

---

## 9. References

- [Warp MCP Documentation](https://docs.warp.dev/knowledge-and-collaboration/mcp)
- [Warp Zellij Issue #3935](https://github.com/warpdotdev/Warp/issues/3935)
- [Context7 MCP Server](https://github.com/upstash/context7)
- [Kitty + Zellij Research](../sessions/kitty-configuration/RESEARCH_FINDINGS.md)
- [Warp Complete Guide](../tools/warp/WARP_COMPLETE_GUIDE.md)

---

**Document Status:** Complete
**Next Steps:** See Implementation Plan below
