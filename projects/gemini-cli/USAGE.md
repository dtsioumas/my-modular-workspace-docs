# Gemini CLI - Google's AI Agent for Terminal

**Type:** AI Agent / Terminal Assistant
**Installation:** Home-Manager (Nix)
**Status:** ✅ Installed
**Configuration:** `~/.gemini/settings.json` (chezmoi-managed template)
**Global Instructions:** `~/.gemini/AGENTS.md` (symlinked to llm-core via home-manager)
**Documentation:** https://geminicli.com/

---

## Overview

Gemini CLI is Google's official command-line AI agent that brings Gemini models directly into the terminal with native MCP (Model Context Protocol) support. It provides powerful AI assistance for coding, research, and automation tasks.

**ADR-009 Compliance:**
- ✅ **Installation**: home-manager (`gemini-cli.nix`)
- ✅ **Configuration**: chezmoi dotfiles repo (`private_dot_gemini/settings.json.tmpl`)

### Key Features

- **🧠 Powerful Models**: Access to Gemini 2.5 Pro with 1M+ token context window
- **🔧 Built-in Tools**: File operations, shell commands, web fetching, Google Search
- **🔌 MCP Support**: Native Model Context Protocol integration for custom tools
- **⚙️ Declarative Config**: Managed via home-manager and chezmoi
- **🎯 Agent Mode**: Autonomous task execution with tool chaining
- **📝 Context Files**: AGENTS.md for global instructions (shared with Claude/Codex)

---

## Installation

### Method: Home-Manager + Chezmoi (ADR-009)

**Installation:** `home-manager/gemini-cli.nix`

```nix
# Installation ONLY (no configuration)
home.packages = with pkgs; [
  gemini-cli  # Google's Gemini AI agent for terminal
];

# Environment variables
home.sessionVariables = {
  GEMINI_MODEL = "gemini-2.5-pro";
};

# AGENTS.md symlink (via home-manager)
home.file.".gemini/AGENTS.md".source =
  config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/global-config.md";
```

**Configuration:** `dotfiles/private_dot_gemini/settings.json.tmpl` (chezmoi template)

**Apply changes:**
```bash
# 1. Rebuild home-manager (installs package)
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch

# 2. Apply chezmoi configuration
chezmoi apply
```

---

## Configuration

### Architecture (ADR-009 Compliant)

Following **ADR-009** (Two-layer architecture):

1. **Layer 1: Installation** (home-manager)
   - ✅ Package installation: `home.packages = [ pkgs.gemini-cli ]`
   - ✅ Environment variables: `GEMINI_MODEL`
   - ✅ AGENTS.md symlink: Points to `llm-core/config/global-config.md`
   - ✅ Bash integration: Load API keys from systemd

2. **Layer 2: Configuration** (chezmoi dotfiles)
   - ✅ Settings template: `dotfiles/private_dot_gemini/settings.json.tmpl`
   - ✅ Deployed to: `~/.gemini/settings.json`
   - ✅ MCP servers: All 14 servers configured (same as Claude Code)

### Settings Structure

**Template:** `dotfiles/private_dot_gemini/settings.json.tmpl`
**Deployed:** `~/.gemini/settings.json` (via `chezmoi apply`)

Key sections:
- `general`: Editor (codium), session retention, auto-update (disabled)
- `ui`: Theme (GitHub), line numbers, display options
- `model`: Default model (gemini-2.5-pro), compression settings
- `privacy`: Telemetry disabled
- `tools`: Sandboxing (false), auto-accept (false), shell config
- `context`: AGENTS.md file location
- `mcpServers`: **14 MCP servers** (ADR-010 compliant, Nix-packaged)

### MCP Servers (14 Total)

All MCP servers are Nix-packaged (ADR-010) and use wrapper scripts in PATH:

**From flake inputs:**
1. `context7` - Library documentation (requires API key)
2. `sequential-thinking` - Deep reasoning and planning
3. `fetch` - Web content fetching
4. `time` - Timezone utilities

**From npm packages:**
5. `firecrawl` - Web scraping (requires API key)
6. `read-website-fast` - Fast web reading
7. `brave-search` - Web search (requires API key)
8. `exa` - AI-powered search (requires API key)

**From Python packages:**
9. `claude-continuity` - Session persistence
10. `ast-grep` - Structural code search

**From Rust packages:**
11. `ck` - Semantic code search
12. `filesystem` - File operations
13. `git` - Git repository operations
14. `shell` - Shell command execution

---

## Authentication

### API Key Method (Personal Use)

**Obtain API Key:**
1. Visit https://aistudio.google.com/apikey
2. Sign in with Google account
3. Create new API key
4. Store in KeePassXC

**Storage:** KeePassXC (per ADR-011)

```bash
# Store API key
secret-tool store --label="Gemini API Key" service gemini key apikey

# Verify
secret-tool lookup service gemini key apikey
```

**Loading:** Via `load-keepassxc-secrets.service` (systemd)

```bash
# Check if loaded
echo $GEMINI_API_KEY
systemctl --user show-environment | grep GEMINI_API_KEY
```

---

## MCP Servers

Gemini CLI integrates with all MCP servers packaged via ADR-010:

### From Flake (from-flake.nix)

| Server | Command | API Key | Description |
|--------|---------|---------|-------------|
| **context7** | `mcp-context7` | ✅ Required | Library documentation |
| **sequential-thinking** | `mcp-sequential-thinking` | ❌ No | Deep reasoning |
| **fetch** | `mcp-fetch` | ❌ No | Web content fetching |
| **time** | `mcp-time` | ❌ No | Timezone operations |

### From NPM (npm-custom.nix)

| Server | Command | API Key | Description |
|--------|---------|---------|-------------|
| **firecrawl** | `mcp-firecrawl` | ✅ Required | Web scraping |
| **read-website-fast** | `mcp-read-website-fast` | ❌ No | Fast web reading |
| **brave-search** | `mcp-brave-search` | ✅ Optional | Web search |
| **exa** | `mcp-exa` | ✅ Required | AI-powered search |

### From Python (python-custom.nix)

| Server | Command | API Key | Description |
|--------|---------|---------|-------------|
| **claude-continuity** | `mcp-claude-continuity` | ❌ No | Session persistence |
| **ast-grep** | `mcp-ast-grep` | ❌ No | Structural code search |

### From Rust (rust-custom.nix)

| Server | Command | API Key | Description |
|--------|---------|---------|-------------|
| **ck** | `mcp-ck --serve` | ❌ No | Semantic code search |

**Total:** 11 MCP servers configured

---

## Global Instructions (AGENTS.md)

**Location:** `~/.gemini/AGENTS.md`
**Type:** Symlink (managed by home-manager)
**Target:** `~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/global-config.md`

**Purpose:**
- Shared instructions across all AI agents (Claude Code, Codex, Gemini CLI)
- Single source of truth for global context
- User preferences, working agreements, project structure

**Management:**
- Edit source: llm-core/config/global-config.md
- Symlink created: home-manager
- Applied to: Claude Code, Codex, Gemini CLI

---

## Usage

### Basic Commands

```bash
# Interactive mode
gemini

# One-shot prompt
gemini --prompt "What is the capital of Greece?"

# With specific model
gemini --model gemini-2.5-pro

# List MCP servers
gemini
> /mcp

# List available tools
> /tools

# Show memory/context
> /memory show
```

### Common Tasks

**1. Code generation:**
```bash
gemini
> Create a Python function that checks if a number is prime
```

**2. Web research:**
```bash
gemini
> Search for the latest Rust async/await patterns
# Uses firecrawl or exa MCP servers
```

**3. Code analysis:**
```bash
gemini
> Analyze the codebase structure in ./src
# Uses ast-grep or ck MCP servers
```

**4. Time operations:**
```bash
gemini
> What time is it in Athens right now?
# Uses time MCP server
```

---

## Integration with Other Tools

### Coexistence with Claude Code

Gemini CLI **coexists** with Claude Code:

| Aspect | Claude Code | Gemini CLI |
|--------|-------------|------------|
| **Config** | `~/.claude/mcp_config.json` | `~/.gemini/settings.json` |
| **Instructions** | `~/.claude/CLAUDE.md` | `~/.gemini/AGENTS.md` |
| **MCP Servers** | Shared (same Nix binaries) | Shared (same Nix binaries) |
| **Best For** | IDE integration, coding | Terminal workflows, research |

**Shared Resources:**
- MCP server binaries (from Nix store)
- Global instructions (from llm-core)
- API keys (from KeePassXC)

### Use Cases

| Task | Recommended Tool |
|------|-----------------|
| IDE-integrated coding | Claude Code (VSCodium/Continue.dev) |
| Terminal automation | Gemini CLI |
| Deep research | Gemini CLI (larger context window) |
| Code review | Claude Code |
| Shell scripting help | Gemini CLI |
| Quick queries | Either (based on preference) |

---

## Troubleshooting

### API Key Issues

**Problem:** "API key not found" error

**Solution:**
```bash
# Check if key is stored
secret-tool lookup service gemini key apikey

# Check if key is loaded
echo $GEMINI_API_KEY

# Restart secrets service
systemctl --user restart load-keepassxc-secrets.service
```

### MCP Server Not Working

**Problem:** MCP server not discovered or failing

**Solution:**
```bash
# Check MCP wrappers exist
which mcp-context7 mcp-fetch mcp-firecrawl

# Test MCP server directly
mcp-context7 --help

# Check MCP server logs
journalctl --user -u gemini-cli -f

# Verify API keys for servers that need them
systemctl --user show-environment | grep API_KEY
```

### AGENTS.md Not Loading

**Problem:** Global instructions not appearing

**Solution:**
```bash
# Check symlink
ls -la ~/.gemini/AGENTS.md

# Verify target exists
cat ~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/global-config.md

# Recreate symlink (if needed)
home-manager switch --flake .#mitsio@shoshin
```

---

## Maintenance

### Update Gemini CLI

```bash
# Update nixpkgs-unstable
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
nix flake update nixpkgs

# Rebuild
home-manager switch --flake .#mitsio@shoshin

# Verify new version
gemini --version
```

### Rotate API Key

```bash
# 1. Get new key from https://aistudio.google.com/apikey
# 2. Update in KeePassXC
secret-tool store --label="Gemini API Key" service gemini key apikey

# 3. Reload secrets
systemctl --user restart load-keepassxc-secrets.service

# 4. Verify
echo $GEMINI_API_KEY
```

### Add New MCP Server

Follow ADR-010 process:
1. Package MCP server via Nix (in `home-manager/mcp-servers/`)
2. Create wrapper script
3. Add to gemini-cli.nix mcpServers section
4. Rebuild: `home-manager switch`

---

## ADR Compliance

### ADR-001: Unstable Packages via Home-Manager
✅ Gemini CLI installed from `nixpkgs-unstable`

### ADR-009: Two-Layer Architecture
✅ Installation: home-manager
✅ Configuration: settings.json (home-manager managed)

### ADR-010: MCP Servers as Nix Packages
✅ All MCP servers packaged via Nix
✅ No runtime installers (npx, uvx)
✅ Wrappers in `home-manager/mcp-servers/`

### ADR-011: Secrets via KeePassXC
✅ API keys stored in KeePassXC
✅ Loaded via systemd service
✅ Environment variables set securely

---

## Configuration Files

### Home-Manager Module

**File:** `home-manager/gemini-cli.nix`
**Purpose:** Declarative Gemini CLI installation and configuration

### Secrets Service Extension

**File:** Part of existing `load-keepassxc-secrets.service`
**Purpose:** Load GEMINI_API_KEY and MCP API keys

### Global Instructions Symlink

**File:** `home-manager/llm-global-instructions-symlinks.nix`
**Purpose:** Create `~/.gemini/AGENTS.md` symlink

---

## References

### Official Documentation
- **GitHub:** https://github.com/google-gemini/gemini-cli
- **Website:** https://geminicli.com/
- **API Keys:** https://aistudio.google.com/apikey
- **Google Cloud Docs:** https://docs.cloud.google.com/gemini/docs/codeassist/gemini-cli

### Project Documentation
- **Installation Plan:** `docs/plans/PLAN_GEMINI_CLI_INSTALLATION.md`
- **Research:** `docs/researches/2025-12-11_GEMINI_CLI_MCP_INTEGRATION_RESEARCH.md`
- **Critical Review:** `docs/researches/2025-12-11_GEMINI_CLI_PLAN_CRITICAL_REVIEW.md`

### Related ADRs
- **ADR-001:** nixpkgs-unstable on home-manager
- **ADR-009:** Two-layer architecture (install vs config)
- **ADR-010:** MCP servers as Nix packages
- **ADR-011:** Secrets management via KeePassXC

---

**Last Updated:** 2025-12-14
**Status:** Ready for installation
**Confidence:** 0.90 (Band C - High)
