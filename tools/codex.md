# OpenAI Codex - AI Coding Agent

> **Version**: 0.64.0+
> **Last Updated**: 2025-12-14
> **Status**: Active
> **Installation**: via node2nix in home-manager
> **MCP Architecture**: Nix-packaged wrappers (ADR-010)

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [MCP Integration](#mcp-integration)
- [Usage](#usage)
- [AGENTS.md Instructions](#agentsmd-instructions)
- [VSCodium Extension](#vscodium-extension)
- [Comparison with Claude Code](#comparison-with-claude-code)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

**OpenAI Codex** is an AI coding agent from OpenAI that helps developers write, review, and ship code faster. It uses OpenAI's models (GPT-5, o3-mini, etc.) and provides a comprehensive coding assistant experience.

### Key Features

1. **Multi-Surface Access**
   - **CLI** - Terminal-based interactive coding sessions
   - **IDE Extension** - Works in VSCode, Cursor, Windsurf, and VSCodium
   - **Cloud Agent** - Delegate tasks to run in isolated sandboxes
   - **GitHub Integration** - Automatic PR reviews with `@codex` mentions
   - **Mobile** - Code from ChatGPT mobile app

2. **MCP Support (ADR-010)**
   - Full Model Context Protocol support
   - 14 Nix-packaged MCP servers
   - Shared configuration with Claude Code and Claude Desktop
   - systemd resource isolation

3. **Custom Instructions**
   - `AGENTS.md` files for project-specific instructions
   - Global and per-directory configuration
   - Hierarchical instruction discovery
   - Fallback to `CLAUDE.md` files

4. **Security & Sandboxing**
   - Configurable approval policies (4 levels)
   - Workspace-scoped write permissions
   - Command risk assessment
   - systemd process isolation

---

## Installation

### Current Installation Method

Codex is installed via **node2nix** in home-manager for reproducible, declarative package management.

#### Files Involved

```
home-manager/
├── npm-packages.json          # List of npm packages to install
├── npm-default.nix            # Generated: Composition expression
├── npm-node-packages.nix      # Generated: Package definitions
├── npm-node-env.nix           # Generated: Build logic
├── npm-tools.nix              # Wrapper module with codex-wrapper
└── home.nix                   # Imports npm-tools.nix
```

#### Installation Steps

1. **Add to npm-packages.json**
   ```json
   [
     "@openai/codex",
     "@anthropic-ai/claude-code"
   ]
   ```

2. **Generate Nix expressions**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
   node2nix -i npm-packages.json \
     -o npm-node-packages.nix \
     -c npm-default.nix \
     -e npm-node-env.nix
   ```

3. **Add files to git** (required for flakes)
   ```bash
   git add npm-*.nix npm-packages.json
   ```

4. **Rebuild home-manager**
   ```bash
   home-manager switch --flake .#mitsio@shoshin
   ```

#### Wrapper Script

The `codex-wrapper` in `npm-tools.nix` provides:
- Automatic API key loading from Bitwarden (if available)
- Fallback to `$OPENAI_API_KEY` environment variable
- Clean integration with the system PATH

```nix
codex-wrapper = pkgs.writeShellScriptBin "codex" ''
  # Load API key from Bitwarden if available (fallback to env var)
  if command -v bw &>/dev/null; then
    export OPENAI_API_KEY="$(bw get password openai-api-key 2>/dev/null || echo "$OPENAI_API_KEY")"
  fi
  exec ${npmPackages."@openai/codex"}/bin/codex "$@"
'';
```

#### Verification

```bash
which codex
# Expected: /home/mitsio/.nix-profile/bin/codex

codex --version
# Expected: codex-cli 0.64.0
```

---

## Configuration

### Configuration File

**Location**: `~/.codex/config.toml`
**Managed by**: Chezmoi (`dotfiles/private_dot_codex/config.toml.tmpl`)

This configuration file is shared between CLI and IDE extension.

### Key Configuration Sections

#### Model Settings

```toml
model = "gpt-5.1-codex"
model_reasoning_effort = "medium"  # minimal | low | medium | high
model_verbosity = "medium"         # low | medium | high
```

#### Security & Sandbox

```toml
# Approval policy: when to ask before executing
approval_policy = "on-request"  # untrusted | on-failure | on-request | never

# Sandbox mode: filesystem access level
sandbox_mode = "workspace-write"  # read-only | workspace-write | danger-full-access

[sandbox_workspace_write]
writable_roots = []
network_access = true
exclude_tmpdir_env_var = false
exclude_slash_tmp = false
```

#### Shell Environment

```toml
[shell_environment_policy]
inherit = "core"                    # all | core | none
ignore_default_excludes = false
exclude = ["AWS_*", "AZURE_*"]      # Glob patterns to exclude
```

#### Features

```toml
[features]
view_image_tool = true        # Allow attaching local images
web_search_request = true     # Allow web searches
unified_exec = false          # Experimental unified exec tool
rmcp_client = false           # OAuth for HTTP MCP servers
```

#### UI Configuration

```toml
file_opener = "vscode"              # vscode | vscode-insiders | cursor | none
hide_agent_reasoning = false
show_raw_agent_reasoning = false

[tui]
notifications = true
```

#### Project Documentation

```toml
project_doc_max_bytes = 65536
project_doc_fallback_filenames = ["CLAUDE.md", ".agents.md"]
```

---

## MCP Integration

### Architecture (ADR-010)

All MCP servers are Nix-packaged via home-manager with:
- Declarative installation
- systemd resource isolation (MemoryMax=2G, CPUQuota=200%)
- Automatic cleanup via SIGTERM on parent death
- API keys loaded from KeePassXC

### Configured MCP Servers (14 total)

```toml
# ~/.codex/config.toml - MCP section

[mcp_servers.fetch]
command = "/home/mitsio/.nix-profile/bin/mcp-fetch"
args = []

[mcp_servers.read-website-fast]
command = "/home/mitsio/.nix-profile/bin/mcp-read-website-fast"
args = []

[mcp_servers.time]
command = "/home/mitsio/.nix-profile/bin/mcp-time"
args = []

[mcp_servers.context7]
command = "/home/mitsio/.nix-profile/bin/mcp-context7"
args = []

[mcp_servers.sequential-thinking]
command = "/home/mitsio/.nix-profile/bin/mcp-sequential-thinking"
args = []

[mcp_servers.firecrawl]
command = "/home/mitsio/.nix-profile/bin/mcp-firecrawl"
args = []

[mcp_servers.exa]
command = "/home/mitsio/.nix-profile/bin/mcp-exa"
args = []

[mcp_servers.brave-search]
command = "/home/mitsio/.nix-profile/bin/mcp-brave-search"
args = []

[mcp_servers.ast-grep]
command = "/home/mitsio/.nix-profile/bin/mcp-ast-grep"
args = []

[mcp_servers.ck]
command = "/home/mitsio/.nix-profile/bin/mcp-ck"
args = []

[mcp_servers.claude-continuity]
command = "/home/mitsio/.nix-profile/bin/mcp-claude-continuity"
args = []

[mcp_servers.filesystem]
command = "/home/mitsio/.nix-profile/bin/mcp-filesystem-server"
args = ["/home/mitsio"]

[mcp_servers.shell]
command = "/home/mitsio/.nix-profile/bin/mcp-shell"
args = []

[mcp_servers.git]
command = "/home/mitsio/.nix-profile/bin/mcp-git"
args = []
```

### MCP Server Capabilities

| Server | Purpose |
|--------|---------|
| **fetch** | URL fetching with markdown conversion |
| **read-website-fast** | Fast web reading optimized for docs |
| **time** | Time queries and timezone conversion |
| **context7** | Technical documentation search (libraries, APIs) |
| **sequential-thinking** | Structured multi-step reasoning |
| **firecrawl** | Web scraping, crawling, data extraction |
| **exa** | AI-powered web search |
| **brave-search** | Privacy-focused web search |
| **ast-grep** | AST-based code search |
| **ck** | Semantic code search |
| **claude-continuity** | Session state continuity |
| **filesystem** | File read/write operations |
| **shell** | Shell command execution |
| **git** | Git operations |

### Managing MCP Servers

#### List Active Servers
```bash
codex mcp list
```

#### Add Server via CLI
```bash
codex mcp add <name> --env VAR=VALUE -- <command>
```

#### View in TUI
```
# Inside Codex session
/mcp
```

---

## Usage

### CLI Usage

#### Basic Commands

```bash
# Start interactive session
codex

# Start with a prompt
codex "Add error handling to the API endpoints"

# Use specific model
codex --model gpt-5.1

# Change approval policy for session
codex --config approval_policy="never"

# Change sandbox mode
codex --sandbox read-only

# Enable a feature
codex --enable web_search_request
```

#### TUI Commands (inside Codex)

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/mcp` | View active MCP servers |
| `/history` | View session transcript |
| `/clear` | Clear conversation |
| `/exit` | Exit Codex |

### Common Workflows

1. **Generate new code**
   ```bash
   codex "Create a REST API for user management with Express"
   ```

2. **Fix bugs**
   ```bash
   codex "Fix the authentication bug in src/auth.ts"
   ```

3. **Review code**
   ```bash
   codex "Review the changes in the last commit for security issues"
   ```

4. **Add tests**
   ```bash
   codex "Add unit tests for the UserService class"
   ```

5. **Use MCP tools**
   ```
   You: Search for Next.js 14 app router documentation
   (Codex uses context7 MCP)

   You: What's the current time in New York?
   (Codex uses time MCP)
   ```

---

## AGENTS.md Instructions

### How AGENTS.md Works

Codex reads `AGENTS.md` files before starting work, providing persistent guidance.

#### Discovery Order

1. **Global**: `~/.codex/AGENTS.md`
2. **Project**: Repository root down to current directory
3. **Merge**: Concatenated from root down (later files override earlier)

### Our Configuration

**Global file**: `~/.codex/AGENTS.md`
- Symlinked from `llm-core` via home-manager
- References shared instructions with Claude Code
- Provides user context, MCP server list, working agreements

**Fallback support** (in `config.toml`):
```toml
project_doc_fallback_filenames = ["CLAUDE.md", ".agents.md"]
```

This allows Codex to discover `CLAUDE.md` files in project directories.

### Example Project AGENTS.md

```markdown
# Project: Home Manager Configuration

## Context
This is the home-manager configuration repository for shoshin workspace.

## Guidelines
- Always test changes with `home-manager build` before `switch`
- Check for deprecated options using `home-manager news`
- Follow Nix formatting with `nixfmt`
- Never commit without running quality checks if Makefile exists
```

---

## VSCodium Extension

### Installation

Declaratively installed via `vscodium.nix`:

```nix
programs.vscode = {
  enable = true;
  package = pkgs.vscodium;
  extensions = [
    pkgs.vscode-marketplace.openai.chatgpt
  ];
};
```

### Authentication

1. Open VSCodium
2. Click OpenAI icon in sidebar
3. Choose authentication method:
   - **ChatGPT account** (recommended with subscription)
   - **API key** (set in extension settings or `OPENAI_API_KEY` env var)

### Features

- Inline code suggestions
- Chat panel for questions and explanations
- File editing with approval workflow
- Terminal command execution
- Uses same `~/.codex/config.toml` configuration

---

## Comparison with Claude Code

| Feature | Codex | Claude Code |
|---------|-------|-------------|
| **Model** | GPT-5.1, o3-mini | Claude Sonnet 4.5, Opus 4 |
| **Provider** | OpenAI | Anthropic |
| **CLI** | `codex` | `claude` |
| **IDE Extension** | VSCode, VSCodium | VSCode (beta) |
| **MCP Support** | 14 servers (Nix-managed) | 14 servers (Nix-managed) |
| **Cloud Agent** | Yes | Limited |
| **GitHub Integration** | Native | Via MCP |
| **Mobile** | ChatGPT mobile | No |
| **Custom Instructions** | AGENTS.md | CLAUDE.md |
| **Approval Policies** | 4 options | 2 options |
| **Sandbox Modes** | 3 levels | 2 levels |

### When to Use Which

**Use Codex when**:
- You have ChatGPT Plus subscription
- Need cloud delegation for long-running tasks
- Want GitHub/Slack integration
- Need mobile access

**Use Claude Code when**:
- You have Claude Pro subscription
- Prefer Claude's reasoning style
- Need longer context windows

**Use Both**:
- Compare outputs for critical decisions
- Different tasks suit different models
- Both share MCP servers via ADR-010

---

## Troubleshooting

### 1. `codex: command not found`

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin
which codex
codex --version
```

### 2. API Key Not Found

```bash
# Set environment variable
export OPENAI_API_KEY="sk-..."

# Or verify Bitwarden
bw get password openai-api-key
```

### 3. MCP Server Not Connecting

```bash
# List configured servers
codex mcp list

# Test server directly
timeout 5 ~/.nix-profile/bin/mcp-context7

# Check systemd logs
journalctl --user -u "mcp-*.scope" --since "5 min ago"
```

### 4. Configuration Not Applied

```bash
# Check chezmoi status
chezmoi status
chezmoi diff ~/.codex/config.toml

# Apply changes
chezmoi apply ~/.codex/config.toml --verbose
```

### 5. Permission Denied Errors

```bash
# Temporarily allow more access
codex --sandbox workspace-write

# Or update config.toml
sandbox_mode = "workspace-write"
```

---

## References

### Official Documentation

- **Codex Homepage**: https://openai.com/codex/
- **Quickstart**: https://developers.openai.com/codex/quickstart/
- **Configuration**: https://developers.openai.com/codex/local-config
- **MCP Guide**: https://developers.openai.com/codex/mcp
- **AGENTS.md Guide**: https://developers.openai.com/codex/guides/agents-md
- **GitHub**: https://github.com/openai/codex

### Project Documentation

- **MCP Architecture**: [../integrations/mcp-configuration-architecture.md](../integrations/mcp-configuration-architecture.md)
- **ADR-010**: [../adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md](../adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md)
- **MCP Servers**: [mcp-servers.md](mcp-servers.md)

---

**Last Updated**: 2025-12-14
**Maintainer**: Mitsos
**Status**: Active - Codex configured with Nix-managed MCP servers (ADR-010)
