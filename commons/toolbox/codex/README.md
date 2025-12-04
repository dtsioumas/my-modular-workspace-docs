# OpenAI Codex - AI Coding Agent

> **Version**: 0.64.0
> **Last Updated**: 2025-12-03
> **Status**: Active
> **Installation**: via node2nix in home-manager

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [MCP Integration](#mcp-integration)
- [AGENTS.md Instructions](#agentsmd-instructions)
- [VSCodium Extension](#vscodium-extension)
- [Comparison with Claude Code](#comparison-with-claude-code)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

**OpenAI Codex** is an AI coding agent from OpenAI that helps developers write, review, and ship code faster. It's similar to Claude Code but uses OpenAI's models (GPT-5, etc.) and has its own unique features and capabilities.

### Key Features

1. **Multi-Surface Access**
   - **CLI** - Terminal-based coding agent
   - **IDE Extension** - Works in VSCode, Cursor, Windsurf, and VSCodium
   - **Cloud Agent** - Delegate tasks to run in isolated sandboxes
   - **GitHub Integration** - Automatic PR reviews with `@codex` mentions
   - **Mobile** - Code from ChatGPT mobile app

2. **MCP Support**
   - Full Model Context Protocol support
   - STDIO and HTTP MCP servers
   - OAuth authentication support (experimental)
   - Shared configuration between CLI and IDE

3. **Custom Instructions**
   - `AGENTS.md` files for project-specific instructions
   - Global and per-directory configuration
   - Hierarchical instruction discovery

4. **Security & Sandboxing**
   - Configurable approval policies
   - Workspace-scoped write permissions
   - Command risk assessment

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
     "@anthropic-ai/claude-code",
     // ... other packages
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

  # Execute codex CLI
  exec ${npmPackages."@openai/codex"}/bin/codex "$@"
'';
```

---

## Configuration

### Configuration Files

Codex uses a single configuration file for both CLI and IDE extension:

**Location**: `~/.codex/config.toml`

#### Key Configuration Sections

```toml
# Model
model = "gpt-5"
model_reasoning_effort = "medium"

# Security
approval_policy = "on-request"  # untrusted | on-failure | on-request | never
sandbox_mode = "workspace-write"  # read-only | workspace-write | danger-full-access

# MCP Servers
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]

# Features
[features]
view_image_tool = true
web_search_request = true
```

### Configuration Options

| Option | Values | Description |
|--------|--------|-------------|
| `model` | `gpt-5`, `gpt-4.1`, etc. | Model to use |
| `approval_policy` | `untrusted`, `on-failure`, `on-request`, `never` | When to ask before running commands |
| `sandbox_mode` | `read-only`, `workspace-write`, `danger-full-access` | Filesystem access level |
| `model_reasoning_effort` | `minimal`, `low`, `medium`, `high` | Reasoning depth |
| `model_verbosity` | `low`, `medium`, `high` | Output verbosity |

For complete options, see: [docs/commons/toolbox/codex/CONFIGURATION.md](./CONFIGURATION.md)

---

## Usage

### CLI Usage

#### Basic Commands

```bash
# Start Codex in current directory
codex

# Start with a specific prompt
codex "Add error handling to the API endpoints"

# Use a specific model
codex --model gpt-5

# Change approval policy for this session
codex --ask-for-approval never

# Change sandbox mode
codex --sandbox read-only

# Enable a feature for this session
codex --enable web_search_request
```

#### Common Workflows

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

### IDE Extension Usage

1. **Installation**: Install `openai.chatgpt` extension in VSCodium
2. **Sign in**: Use ChatGPT account or API key
3. **Usage**: Access via sidebar or keyboard shortcuts

### Cloud Agent Usage

Delegate long-running tasks to run in isolated cloud environments:

1. **Set up environment**: Connect GitHub repo at [chatgpt.com/codex](https://chatgpt.com/codex/settings/environments)
2. **Launch task**: Start task from interface
3. **Review changes**: Check diffs, iterate, create PR
4. **Pull locally**: `git fetch && git checkout branch-name`

---

## MCP Integration

### Available MCP Servers

Codex in this workspace has access to:

| Server | Purpose | Command |
|--------|---------|---------|
| **context7** | Technical documentation search | `npx -y @upstash/context7-mcp` |
| **firecrawl** | Web scraping & crawling | `npx -y firecrawl-mcp` |
| **read-website-fast** | Fast web reading | `npx -y @just-every/mcp-read-website-fast` |
| **time** | Time & timezone operations | `mcp-server-time` |
| **fetch** | Web content fetching | `mcp-server-fetch` |
| **sequential-thinking** | Structured reasoning | `mcp-sequential-thinking` |

### Adding MCP Servers

#### Via CLI
```bash
codex mcp add <server-name> --env VAR=VALUE -- <command>

# Example
codex mcp add context7 -- npx -y @upstash/context7-mcp
```

#### Via config.toml
```toml
[mcp_servers.my-server]
command = "npx"
args = ["-y", "my-mcp-server"]

[mcp_servers.my-server.env]
MY_ENV_VAR = "value"
```

### Viewing Active MCP Servers

In the Codex TUI, type `/mcp` to see connected MCP servers.

### MCP Features Support

| Feature | Supported |
|---------|-----------|
| STDIO servers | ✅ Yes |
| HTTP servers | ✅ Yes |
| Environment variables | ✅ Yes |
| Bearer token auth | ✅ Yes |
| OAuth (experimental) | ⚠️ Requires `features.rmcp_client = true` |
| Tool filtering | ✅ Yes (`enabled_tools`, `disabled_tools`) |
| Timeouts | ✅ Yes (configurable) |

---

## AGENTS.md Instructions

### How AGENTS.md Works

Codex reads `AGENTS.md` files before starting work, allowing you to provide persistent guidance.

#### Discovery Order

1. **Global**: `~/.codex/AGENTS.md` (or `AGENTS.override.md`)
2. **Project**: Repository root down to current directory
3. **Merge**: Concatenated from root down (later files override earlier)

#### Our Configuration

**Global file**: `~/.codex/AGENTS.md`
- References `~/.claude/CLAUDE.md` (shared with Claude Code)
- Provides user context, working agreements, task management
- Defines communication style and project structure
- Lists available MCP servers

**Project files**: Can be added per-repository in `my-modular-workspace/` subdirectories

#### Example Project AGENTS.md

```markdown
# Project: Home Manager Configuration

## Context
This is the home-manager configuration repository for the shoshin workspace.

## Guidelines
- Always test changes with `home-manager build` before `switch`
- Check for deprecated options using `home-manager news`
- Follow Nix formatting with `nixfmt`
- Never commit without running quality checks if Makefile exists
```

### Fallback Filenames

Configured in `~/.codex/config.toml`:
```toml
project_doc_fallback_filenames = ["CLAUDE.md", ".agents.md"]
```

This allows Codex to discover `CLAUDE.md` files in project directories.

---

## VSCodium Extension

### Installation

1. **Install extension**
   ```bash
   # Via command line (if codium CLI is available)
   codium --install-extension openai.chatgpt

   # Or via Extensions view in VSCodium
   # Search for "openai.chatgpt" and install
   ```

2. **Configure marketplace** (already done in `vscodium.nix`)
   ```nix
   home.file.".config/VSCodium/product.json".text = builtins.toJSON {
     extensionsGallery = {
       serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery";
       # ...
     };
   };
   ```

3. **Sign in**
   - Open extension sidebar
   - Click "Sign in with ChatGPT" (recommended)
   - Or use "Use API key" and set `OPENAI_API_KEY`

### Usage

- **Agent Mode**: Runs in current directory, can read/write files, run commands
- **Delegate to Cloud**: Send tasks to cloud agent from IDE
- **Keyboard Shortcuts**: Configurable via IDE settings (gear icon → Keyboard shortcuts)

### Configuration

Access settings via gear icon in extension:
- **Codex Settings**: Opens `~/.codex/config.toml`
- **MCP Settings**: Configure MCP servers
- **IDE Settings**: Extension-specific options
- **Keyboard Shortcuts**: Define custom shortcuts

---

## Comparison with Claude Code

| Feature | Claude Code | Codex |
|---------|-------------|-------|
| **Model** | Claude (Anthropic) | GPT-5 (OpenAI) |
| **CLI** | ✅ `claude` | ✅ `codex` |
| **IDE Extension** | ✅ VSCode, Cursor, Windsurf | ✅ VSCode, Cursor, Windsurf, VSCodium |
| **Cloud Agent** | ❌ No | ✅ Yes |
| **GitHub Integration** | ❌ Limited | ✅ PR reviews, issue handling |
| **Mobile** | ❌ No | ✅ ChatGPT mobile app |
| **MCP Support** | ✅ Yes | ✅ Yes |
| **Custom Instructions** | CLAUDE.md | AGENTS.md |
| **Slack Integration** | ❌ No | ✅ Yes |
| **SDK** | ❌ No | ✅ TypeScript SDK |

### When to Use Which

**Use Claude Code when**:
- You prefer Anthropic's Claude models
- You need advanced reasoning capabilities
- You want the latest Claude model features

**Use Codex when**:
- You prefer OpenAI's GPT models
- You need cloud delegation for long-running tasks
- You want GitHub/Slack integration
- You need to code on mobile
- You want SDK for automation

**Use Both when**:
- You want to compare outputs
- Different tasks suit different models
- You want redundancy

---

## Troubleshooting

### Common Issues

#### 1. `codex: command not found`

**Cause**: home-manager rebuild not applied or PATH not updated

**Solution**:
```bash
# Rebuild and switch
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin

# Verify installation
which codex
codex --version
```

#### 2. API Key Not Found

**Cause**: `OPENAI_API_KEY` not set and Bitwarden unavailable

**Solution**:
```bash
# Set environment variable
export OPENAI_API_KEY="sk-..."

# Or store in Bitwarden
bw create item \
  '{"type":1,"name":"openai-api-key","login":{"password":"sk-..."}}'
```

#### 3. MCP Server Not Connecting

**Cause**: Server not installed or command incorrect

**Solution**:
```bash
# Test server command manually
npx -y @upstash/context7-mcp

# Check Codex logs
cat ~/.codex/log/codex-tui.log
```

#### 4. Permission Denied Errors

**Cause**: Sandbox mode too restrictive

**Solution**:
```bash
# Temporarily allow more access
codex --sandbox workspace-write

# Or update config.toml
sandbox_mode = "workspace-write"
```

#### 5. Build Errors with node2nix

**Cause**: `system` parameter deprecated

**Solution**: Already fixed in `npm-tools.nix:27`:
```nix
system = pkgs.stdenv.hostPlatform.system;  # Instead of: inherit (pkgs) system;
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

- Configuration: [CONFIGURATION.md](./CONFIGURATION.md) *(to be created)*
- MCP Setup: [MCP-SETUP.md](./MCP-SETUP.md) *(to be created)*
- Examples: [EXAMPLES.md](./EXAMPLES.md) *(to be created)*

### Related Tools

- **Claude Code**: `~/.claude/` configuration
- **node2nix**: `/home/mitsio/.MyHome/MySpaces/my-modular-workspace/docs/home-manager/node2nix.md`
- **home-manager**: `/home/mitsio/.MyHome/MySpaces/my-modular-workspace/docs/home-manager/README.md`

---

**Last Updated**: 2025-12-03
**Maintainer**: Mitsos
**Status**: Active - Codex installed and configured via home-manager
