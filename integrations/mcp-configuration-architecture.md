# MCP Configuration Architecture

**Date**: 2025-12-14
**Status**: Active
**ADR Reference**: [ADR-010 - Unified MCP Server Architecture](../adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md)

---

## Overview

This document describes the unified MCP (Model Context Protocol) server configuration architecture for the modular workspace. All AI coding agents (Claude Code, Claude Desktop, Codex) use Nix-packaged MCP server wrappers managed declaratively via home-manager.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     MCP Configuration Architecture                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐          │
│  │   Claude Code   │  │ Claude Desktop  │  │     Codex       │          │
│  │                 │  │                 │  │                 │          │
│  │ ~/.claude/      │  │ ~/.config/      │  │ ~/.codex/       │          │
│  │ mcp_config.json │  │ Claude/         │  │ config.toml     │          │
│  │                 │  │ claude_desktop_ │  │                 │          │
│  │                 │  │ config.json     │  │                 │          │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘          │
│           │                    │                    │                    │
│           └────────────────────┼────────────────────┘                    │
│                                │                                         │
│                                ▼                                         │
│           ┌────────────────────────────────────────┐                     │
│           │     Chezmoi Config Management          │                     │
│           │                                        │                     │
│           │  dotfiles/                             │                     │
│           │  ├── private_dot_claude/               │                     │
│           │  │   └── mcp_config.json.tmpl          │                     │
│           │  ├── private_dot_config/Claude/        │                     │
│           │  │   └── claude_desktop_config.json.tmpl│                    │
│           │  ├── private_dot_codex/                │                     │
│           │  │   └── config.toml.tmpl              │                     │
│           │  └── .chezmoitemplates/mcp/            │                     │
│           │      └── *.json.tmpl (reusable)        │                     │
│           └────────────────────┬───────────────────┘                     │
│                                │                                         │
│                                ▼                                         │
│           ┌────────────────────────────────────────┐                     │
│           │   Nix-Packaged MCP Server Wrappers     │                     │
│           │   ~/.nix-profile/bin/mcp-*             │                     │
│           │                                        │                     │
│           │   mcp-fetch         mcp-firecrawl      │                     │
│           │   mcp-time          mcp-exa            │                     │
│           │   mcp-context7      mcp-brave-search   │                     │
│           │   mcp-sequential-thinking              │                     │
│           │   mcp-read-website-fast                │                     │
│           │   mcp-ast-grep      mcp-ck             │                     │
│           │   mcp-claude-continuity                │                     │
│           │   mcp-filesystem-server                │                     │
│           │   mcp-shell         mcp-git            │                     │
│           └────────────────────┬───────────────────┘                     │
│                                │                                         │
│                                ▼                                         │
│           ┌────────────────────────────────────────┐                     │
│           │      Home Manager Derivations          │                     │
│           │      home-manager/mcp-servers.nix      │                     │
│           │                                        │                     │
│           │   - Declarative package definitions    │                     │
│           │   - API keys via KeePassXC/secret-tool │                     │
│           │   - systemd resource isolation         │                     │
│           │   - Automatic SIGTERM on parent death  │                     │
│           └────────────────────────────────────────┘                     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## MCP Servers (17 Total)

All agents share the same 17 MCP servers (14 custom wrappers + 3 upstream packages):

| Server | Purpose | Wrapper Binary |
|--------|---------|----------------|
| `fetch` | URL fetching | `mcp-fetch` |
| `read-website-fast` | Fast web reading | `mcp-read-website-fast` |
| `time` | Time/timezone queries | `mcp-time` |
| `context7` | Developer documentation | `mcp-context7` |
| `sequential-thinking` | Structured reasoning | `mcp-sequential-thinking` |
| `firecrawl` | Web scraping | `mcp-firecrawl` |
| `exa` | AI-powered search | `mcp-exa` |
| `brave-search` | Web search | `mcp-brave-search` |
| `ast-grep` | AST code search | `mcp-ast-grep` |
| `ck` | Semantic code search | `mcp-ck` |
| `claude-continuity` | Session continuity | `mcp-claude-continuity` |
| `filesystem` | File operations | `mcp-filesystem-server` |
| `shell` | Shell commands | `mcp-shell` |
| `git` | Git operations | `mcp-git` |
| `server-fetch` | URL fetching (upstream, 50k limit) | `mcp-server-fetch` |
| `server-time` | Time queries (upstream) | `mcp-server-time` |
| `server-sequential-thinking` | Reasoning (upstream) | `mcp-server-sequential-thinking` |

---

## Configuration Files

### 1. Claude Code
**Location**: `~/.claude/mcp_config.json`
**Chezmoi Source**: `dotfiles/private_dot_claude/mcp_config.json.tmpl`

```json
{
  "mcpServers": {
    "fetch": {
      "command": "/home/mitsio/.nix-profile/bin/mcp-fetch",
      "args": [],
      "env": {}
    },
    // ... 13 more servers
  }
}
```

### 2. Claude Desktop
**Location**: `~/.config/Claude/claude_desktop_config.json`
**Chezmoi Source**: `dotfiles/private_dot_config/Claude/claude_desktop_config.json.tmpl`

Uses reusable templates from `.chezmoitemplates/mcp/`:
```go
{{ template "mcp/fetch.json.tmpl" . }}
```

### 3. Codex
**Location**: `~/.codex/config.toml`
**Chezmoi Source**: `dotfiles/private_dot_codex/config.toml.tmpl`

```toml
[mcp_servers.fetch]
command = "/home/mitsio/.nix-profile/bin/mcp-fetch"
args = []

[mcp_servers.context7]
command = "/home/mitsio/.nix-profile/bin/mcp-context7"
args = []
# ... 12 more servers
```

---

## Nix Wrapper Architecture

Each MCP server wrapper includes:

### 1. Resource Isolation
```nix
# Runs under systemd scope with resource limits
systemd-run --user --scope \
  --slice=mcp-servers.slice \
  --property=MemoryMax=2G \
  --property=CPUQuota=200%
```

### 2. Process Cleanup
```nix
# Server receives SIGTERM when parent dies
setpriv --pdeathsig SIGTERM
```

### 3. API Key Injection
```nix
# Keys loaded from KeePassXC via secret-tool
export FIRECRAWL_API_KEY="$(secret-tool lookup service firecrawl-mcp)"
export EXA_API_KEY="$(secret-tool lookup service exa-mcp)"
```

---

## Chezmoi Template Structure

```
dotfiles/
├── .chezmoitemplates/
│   └── mcp/
│       ├── fetch.json.tmpl
│       ├── time.json.tmpl
│       ├── context7.json.tmpl
│       ├── firecrawl.json.tmpl
│       ├── exa.json.tmpl
│       ├── brave-search.json.tmpl
│       ├── ast-grep.json.tmpl
│       ├── ck.json.tmpl
│       ├── claude-continuity.json.tmpl
│       ├── rust-filesystem.json.tmpl
│       ├── shell.json.tmpl
│       ├── git.json.tmpl
│       ├── read-website-fast.json.tmpl
│       └── sequential-thinking.json.tmpl
├── private_dot_claude/
│   └── mcp_config.json.tmpl
├── private_dot_config/
│   └── Claude/
│       └── claude_desktop_config.json.tmpl
└── private_dot_codex/
    └── config.toml.tmpl
```

---

## Updating MCP Configuration

### Adding a New MCP Server

1. **Create Nix derivation** in `home-manager/mcp-servers.nix`:
   ```nix
   mcp-new-server = pkgs.writeShellScriptBin "mcp-new-server" ''
     exec systemd-run --user --scope ... \
       /path/to/actual/server "$@"
   '';
   ```

2. **Add chezmoi template** in `.chezmoitemplates/mcp/new-server.json.tmpl`:
   ```json
   "new-server": {
     "command": "{{ .chezmoi.homeDir }}/.nix-profile/bin/mcp-new-server",
     "args": [],
     "env": {}
   }
   ```

3. **Update all agent configs** to include the new server:
   - `private_dot_claude/mcp_config.json.tmpl`
   - `private_dot_config/Claude/claude_desktop_config.json.tmpl`
   - `private_dot_codex/config.toml.tmpl`

4. **Apply changes**:
   ```bash
   home-manager switch --flake .#mitsio@shoshin
   chezmoi apply
   ```

### Modifying an Existing Server

1. Edit the wrapper in `home-manager/mcp-servers.nix`
2. Rebuild home-manager: `home-manager switch`
3. No chezmoi changes needed (wrapper path stays the same)

### Removing an MCP Server

1. Remove from all three agent config templates
2. Optionally remove the Nix derivation
3. Apply chezmoi: `chezmoi apply`

---

## Verifying Configuration

### Claude Code
```bash
cat ~/.claude/mcp_config.json | jq '.mcpServers | keys'
```

### Claude Desktop
```bash
cat ~/.config/Claude/claude_desktop_config.json | jq '.mcpServers | keys'
```

### Codex
```bash
codex mcp list
```

### Test MCP Server
```bash
# Servers run under systemd and output scope info
timeout 3 ~/.nix-profile/bin/mcp-time
# Output: Running as unit: mcp-time-XXXX.scope
```

---

## Troubleshooting

### MCP Server Not Starting

1. **Check if wrapper exists**:
   ```bash
   ls -la ~/.nix-profile/bin/mcp-*
   ```

2. **Test wrapper directly**:
   ```bash
   timeout 5 ~/.nix-profile/bin/mcp-fetch
   ```

3. **Check systemd logs**:
   ```bash
   journalctl --user -u "mcp-*.scope" --since "5 min ago"
   ```

### Configuration Not Applied

1. **Check chezmoi status**:
   ```bash
   chezmoi status
   chezmoi diff ~/.claude/mcp_config.json
   ```

2. **Apply changes**:
   ```bash
   chezmoi apply --verbose
   ```

### API Key Issues

1. **Verify key in KeePassXC**:
   ```bash
   secret-tool lookup service firecrawl-mcp
   ```

2. **Check wrapper includes key loading**:
   ```bash
   cat ~/.nix-profile/bin/mcp-firecrawl
   ```

---

## Related Documentation

- [ADR-010: Unified MCP Server Architecture](../adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md)
- [ADR-011: Secrets Management via KeePassXC](../adrs/ADR-011-UNIFIED_SECRETS_MANAGEMENT_VIA_KEEPASSXC.md)
- [MCP Servers Investigation](../tools/mcp-servers.md)
- [Codex Configuration](../tools/codex.md)
- [Claude Code Configuration](../tools/claude-code.md)

---

**Last Updated**: 2025-12-14
**Maintainer**: Mitsos
