# Gemini CLI + MCP Integration Research

**Date:** 2025-12-11
**Author:** Mitsio
**Session:** gemini-cli-mcp-integration
**Research Confidence:** 0.88 (Band C - HIGH)

---

## Executive Summary

Google Gemini CLI is an **official, open-source AI agent** that brings Gemini directly into the terminal with **native MCP (Model Context Protocol) support**. Home-manager has **native support** for Gemini CLI (`programs.gemini-cli`), making it an excellent fit for the modular workspace architecture per ADR-009 and ADR-010.

### Key Findings

✅ **Official Google product** (github.com/google-gemini/gemini-cli)
✅ **Native home-manager integration** available
✅ **Built-in MCP support** (stdio, HTTP, SSE transports)
✅ **Compatible with existing MCP infrastructure** from my-modular-workspace
✅ **Follows ADR-009 pattern**: Package via home-manager, config via settings.json

---

## 1. What is Gemini CLI?

### Overview

Gemini CLI is an AI-powered command-line interface that provides access to Gemini models directly in the terminal. It uses a ReAct (Reason and Act) loop with built-in tools and MCP servers to complete complex tasks.

### Features

- **🧠 Powerful Gemini Models**: Access to Gemini 2.5 Pro with 1M token context window
- **🔧 Built-in Tools**: Google Search, file operations, shell commands, web fetching
- **🔌 MCP Support**: Native Model Context Protocol for custom integrations
- **⚙️ Configurable**: Rich configuration via settings.json and GEMINI.md context files
- **🎯 Agent Mode**: Autonomous task execution with tool chaining

### Architecture

```
┌─────────────────────────────────────────────────┐
│ Gemini CLI                                      │
├─────────────────────────────────────────────────┤
│ Built-in Tools:                                 │
│  - Read/Write Files                             │
│  - Shell Commands                               │
│  - Web Search (Google)                          │
│  - Web Fetch                                    │
├─────────────────────────────────────────────────┤
│ MCP Integration:                                │
│  - STDIO Transport (local servers)              │
│  - HTTP Transport (remote servers)              │
│  - SSE Transport (Server-Sent Events)           │
│  - OAuth & Service Account Auth                 │
├─────────────────────────────────────────────────┤
│ Configuration:                                  │
│  - ~/.gemini/settings.json (user-wide)          │
│  - .gemini/settings.json (project-specific)     │
│  - GEMINI.md (context/instructions)             │
└─────────────────────────────────────────────────┘
```

---

## 2. Installation Methods

### Method 1: NPM (Global Install)

```bash
npm install -g @google/gemini-cli@latest
```

**Pros:**
- Simple, official installation method
- Auto-updates available
- Works on any Linux distribution

**Cons:**
- Not declarative
- Requires npm/node in PATH
- No version pinning

### Method 2: Home-Manager (Recommended for NixOS) ✅

```nix
programs.gemini-cli = {
  enable = true;
  package = pkgs.gemini-cli;  # Available in nixpkgs-unstable
  defaultModel = "gemini-2.5-pro";
  settings = {
    mcpServers = {
      # MCP server configurations here
    };
  };
};
```

**Pros:**
- ✅ Declarative configuration
- ✅ Version pinned via flake.lock
- ✅ Follows ADR-001 (unstable packages via home-manager)
- ✅ Follows ADR-009 (installation vs configuration split)
- ✅ Reproducible across machines

**Cons:**
- Requires home-manager setup (already done!)

---

## 3. MCP Integration

### 3.1 MCP Server Configuration Format

Gemini CLI configures MCP servers in `settings.json` under the `mcpServers` key:

```json
{
  "mcpServers": {
    "server-name": {
      // STDIO Transport (local)
      "command": "python",
      "args": ["-m", "my_mcp_server"],
      "cwd": "./mcp-servers/python",
      "env": {
        "API_KEY": "$MY_API_KEY"
      },
      "timeout": 15000,
      "trust": false,

      // OR HTTP Transport (remote)
      "httpUrl": "http://localhost:3000/mcp",
      "headers": {
        "Authorization": "Bearer token"
      },

      // OR SSE Transport (Server-Sent Events)
      "url": "https://api.example.com/sse",

      // Tool Filtering
      "includeTools": ["tool1", "tool2"],
      "excludeTools": ["unsafe_tool"]
    }
  }
}
```

### 3.2 Compatibility with Existing MCP Servers

Gemini CLI is **fully compatible** with the MCP servers already configured in the workspace:

| MCP Server | Current Transport | Gemini CLI Compatible | Notes |
|------------|-------------------|----------------------|-------|
| **context7-mcp** | npm (npx) | ✅ YES | Can use stdio or HTTP |
| **firecrawl-mcp** | npm (npx) | ✅ YES | Can use stdio or HTTP |
| **exa-mcp** | npm (@modelcontextprotocol/server-exa) | ✅ YES | Can use stdio or HTTP |
| **mcp-server-fetch** | Python (uv) | ✅ YES | Python stdio |
| **mcp-server-time** | Python (uv) | ✅ YES | Python stdio |
| **sequential-thinking-mcp** | Python (uv) | ✅ YES | Python stdio |
| **mcp-read-website-fast** | npm | ✅ YES | Can use stdio or HTTP |
| **any-chat-completions-mcp** | npm | ✅ YES | Can use stdio or HTTP |

**Migration Strategy:**
- Reuse existing Nix-packaged MCP server binaries (per ADR-010)
- Point Gemini CLI `command` to Nix store paths
- Use wrapper scripts from home-manager/mcp-servers/wrappers.nix

### 3.3 MCP Discovery Commands

Gemini CLI provides built-in commands for managing MCP servers:

```bash
# List all configured MCP servers
/mcp

# Add a new MCP server
gemini mcp add my-server /path/to/server arg1 arg2

# Remove an MCP server
gemini mcp remove my-server

# List available tools from all MCP servers
/tools
```

---

## 4. Configuration Architecture

### 4.1 Configuration Layers (Precedence Order)

1. **System defaults**: `/etc/gemini-cli/system-defaults.json`
2. **User settings**: `~/.gemini/settings.json`
3. **Project settings**: `.gemini/settings.json`
4. **System overrides**: `/etc/gemini-cli/settings.json`
5. **Environment variables**: `GEMINI_API_KEY`, `GEMINI_MODEL`, etc.
6. **Command-line arguments**: `--model`, `--yolo`, etc.

### 4.2 Two-Layer Architecture (Per ADR-009)

**Layer 1: Installation (Home-Manager)**

```nix
# home-manager/gemini-cli.nix
{ config, pkgs, ... }:
{
  programs.gemini-cli = {
    enable = true;
    package = pkgs.gemini-cli;
    defaultModel = "gemini-2.5-pro";
  };
}
```

**Layer 2: Configuration (Settings.json OR Chezmoi)**

**Option A: Direct settings.json in home-manager**

```nix
programs.gemini-cli.settings = {
  ui = {
    theme = "GitHub";
    hideBanner = true;
  };
  mcpServers = {
    context7 = {
      command = "${pkgs.context7-mcp}/bin/context7-mcp";
      env.API_KEY = "$CONTEXT7_API_KEY";
    };
  };
};
```

**Option B: settings.json via chezmoi template**

```yaml
# dotfiles/.chezmoitemplates/gemini-cli/settings.json.tmpl
{
  "ui": {
    "theme": "{{ .ui.theme }}",
    "hideBanner": true
  },
  "mcpServers": {
    {{- range $name, $server := .mcp.servers }}
    "{{ $name }}": {
      "command": "{{ $server.command }}",
      {{- if $server.env }}
      "env": {
        {{- range $key, $val := $server.env }}
        "{{ $key }}": "{{ $val }}"{{ if not (last) }},{{ end }}
        {{- end }}
      }{{ if $server.trust }},{{ end }}
      {{- end }}
      {{- if $server.trust }}
      "trust": {{ $server.trust }}
      {{- end }}
    }{{ if not (last) }},{{ end }}
    {{- end }}
  }
}
```

**Decision Recommendation:**
- Use **Option A** (direct settings in home-manager) for simplicity
- Settings.json is Nix-generated and version-controlled
- No need for chezmoi templates unless cross-platform portability needed

### 4.3 Context Files (GEMINI.md)

Gemini CLI supports **hierarchical context files** (similar to Claude Code):

```
~/.gemini/GEMINI.md              # Global context (all projects)
~/project/.gemini/GEMINI.md      # Project root context
~/project/src/.gemini/GEMINI.md  # Component-specific context
```

**Best Practice:**
- Manage via chezmoi for portability
- Use `programs.gemini-cli.context` option in home-manager

---

## 5. Authentication

### 5.1 Authentication Methods

Gemini CLI supports multiple authentication methods:

| Method | Use Case | Configuration |
|--------|----------|---------------|
| **API Key** | Simple, personal use | `GEMINI_API_KEY` env var |
| **Google Cloud** | Vertex AI, Code Assist | `GOOGLE_CLOUD_PROJECT` + gcloud auth |
| **Service Account** | Production, CI/CD | `GOOGLE_APPLICATION_CREDENTIALS` |
| **OAuth** | MCP server auth | Configured per server in `mcpServers` |

### 5.2 Recommended Setup for My Workspace

**For personal use (via API Key):**

```nix
# home-manager/gemini-cli.nix
programs.gemini-cli = {
  enable = true;
  # API key loaded from KeePassXC via systemd (per ADR-011)
};

# home-manager/secrets/gemini-api-key.nix
systemd.user.services.load-gemini-api-key = {
  Unit.Description = "Load Gemini API Key from KeePassXC";
  Service = {
    Type = "oneshot";
    ExecStart = pkgs.writeShellScript "load-gemini-key" ''
      export GEMINI_API_KEY=$(secret-tool lookup service gemini key apikey)
    '';
  };
  Install.WantedBy = [ "default.target" ];
};
```

**For Google Cloud (via gcloud):**

```bash
# Already authenticated via gcloud
gcloud auth application-default login
```

---

## 6. Integration with Existing Workspace

### 6.1 ADR Alignment

| ADR | Requirement | Gemini CLI Alignment |
|-----|-------------|---------------------|
| **ADR-001** | User packages via home-manager unstable | ✅ `programs.gemini-cli` in home-manager |
| **ADR-009** | Two-layer: Install (HM) + Config (settings) | ✅ Perfect fit |
| **ADR-010** | MCP servers as Nix packages | ✅ Reuse existing Nix MCP derivations |
| **ADR-011** | Secrets via KeePassXC | ✅ API key from secret-tool |

### 6.2 Coexistence with Claude Code

Gemini CLI can **coexist** with Claude Code:

```
~/.claude/mcp_config.json       # Claude Code MCP config
~/.gemini/settings.json         # Gemini CLI MCP config
```

**Shared MCP Servers:**
- Both can use the **same MCP server binaries** from Nix store
- Each maintains its own configuration
- No conflicts expected

### 6.3 Use Cases

| Tool | Best Use Case |
|------|---------------|
| **Claude Code** | IDE-integrated coding (VSCodium, continue.dev) |
| **Gemini CLI** | Terminal workflows, automation, deep research |

**Recommendation:** Install both for maximum flexibility!

---

## 7. Package Availability

### 7.1 NixOS Package Status

**Source:** https://mynixos.com/home-manager/options/programs.gemini-cli

✅ **Available in nixpkgs-unstable** via `programs.gemini-cli`

**Home-Manager Options:**
- `programs.gemini-cli.enable` - Enable Gemini CLI
- `programs.gemini-cli.package` - Package to use
- `programs.gemini-cli.defaultModel` - Default model
- `programs.gemini-cli.settings` - JSON config
- `programs.gemini-cli.context` - Context files (GEMINI.md)
- `programs.gemini-cli.commands` - Custom commands

### 7.2 Version Tracking

```bash
# Check latest version in nixpkgs
nix search nixpkgs gemini-cli

# Check package info
nix-env -qa gemini-cli --description
```

---

## 8. Limitations & Considerations

### 8.1 Known Issues

1. **NixOS-specific issues:**
   - Some users reported "undefined variable" errors on older nixpkgs
   - **Solution:** Use nixpkgs-unstable (already done per ADR-001)

2. **NPM vs Nix installation:**
   - NPM version may be newer than Nix package
   - **Solution:** Use home-manager, contribut to nixpkgs if updates needed

3. **MCP server discovery:**
   - Gemini CLI auto-discovers MCP tools at startup
   - May have slight startup delay with many MCP servers
   - **Solution:** Use `mcp.allowed` to limit active servers

### 8.2 Security Considerations

- **Tool auto-approval:** Gemini CLI can auto-approve tools (`--yolo` mode)
  - **Recommendation:** Use sandboxing or explicit approval per tool
- **MCP server trust:** Each server can be marked as `"trust": true`
  - **Recommendation:** Only trust servers you control
- **API key exposure:** Ensure `GEMINI_API_KEY` not in plaintext
  - **Solution:** Use KeePassXC integration (ADR-011)

---

## 9. Next Steps

### 9.1 Immediate Actions

1. ✅ **Research complete** (this document)
2. ⏳ **Create installation plan** (next step)
3. ⏳ **Implement in home-manager**
4. ⏳ **Configure MCP servers**
5. ⏳ **Test integration**
6. ⏳ **Document usage patterns**

### 9.2 Future Enhancements

- Explore Gemini CLI extensions
- Create custom slash commands for workspace
- Integrate with CI/CD pipelines
- Evaluate Gemini Code Assist integration (VS Code agent mode)

---

## 10. References

### Official Documentation

- **GitHub Repository:** https://github.com/google-gemini/gemini-cli
- **Official Docs:** https://geminicli.com/
- **Google Cloud Docs:** https://docs.cloud.google.com/gemini/docs/codeassist/gemini-cli
- **Configuration Guide:** https://github.com/google-gemini/gemini-cli/blob/main/docs/get-started/configuration.md
- **MCP Documentation:** https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md

### NixOS Resources

- **MyNixOS Options:** https://mynixos.com/home-manager/options/programs.gemini-cli
- **NixOS Discourse:** https://discourse.nixos.org/t/gemini-cli-undefined-variable/68905

### Related Projects

- **FastMCP:** https://gofastmcp.com/integrations/gemini-cli
- **Model Context Protocol:** https://modelcontextprotocol.io/
- **Gemini API:** https://ai.google.dev/gemini-api

---

**Research Completed:** 2025-12-11T05:42:50+02:00 (Europe/Athens)
**Next:** Create installation plan in `docs/plans/`
**Confidence:** 0.88 (Band C - Safe to proceed)
