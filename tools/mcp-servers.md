# MCP Servers - Investigation Report

**Date**: 2025-12-04
**Status**: 🔴 **CRITICAL ISSUE FOUND** - Multiple duplicate instances causing high CPU usage

---

## 🚨 Critical Problem Identified

### Issue: Duplicate MCP Server Instances
Each Claude Code window spawns its **own set of MCP servers**, and they're not being cleaned up properly when windows close.

**Current State**: ~7-8 Claude Code windows open → **50-60+ MCP server processes running**

This is the root cause of the 100% CPU spikes you're experiencing.

---

## 📊 MCP Servers Status

### Currently Running (Live Processes)

| MCP Server | Type | Instances Running | Expected | Status |
|------------|------|-------------------|----------|--------|
| `mcp-server-fetch` | Python/UV | ~8 | 1 | 🔴 **8x duplicates** |
| `mcp-read-website-fast` | NPM | ~8 | 1 | 🔴 **8x duplicates** |
| `mcp-server-time` | Python/UV | ~8 | 1 | 🔴 **8x duplicates** |
| `any-chat-completions-mcp` (Grok/ChatGPT) | NPM | ~8 | 1 | 🔴 **8x duplicates + not declared** |
| `context7-mcp` | NPM | ~8 | 1 | 🔴 **8x duplicates** |
| `sequential-thinking-mcp` | Python/UV | ~8 | 1 | 🔴 **8x duplicates** |
| `firecrawl-mcp` | NPM | ~8 | 1 | 🔴 **8x duplicates** |

**Total Duplicate Processes**: ~56 MCP server processes
**Expected Total**: ~7 MCP server processes
**Overhead**: ~8x resource consumption

---

## 🗂️ MCP Server Configurations

### 1. Home Manager Configuration
**File**: `home-manager/local-mcp-servers.nix`
**Purpose**: Declarative installation of MCP server binaries

#### NPM-based MCPs (Managed by Home Manager)
```nix
- context7-mcp              ✅ Installed
- firecrawl-mcp             ✅ Installed
- mcp-read-website-fast     ✅ Installed
```

#### Go-based MCPs (Managed by Home Manager)
```nix
- git-mcp-go                ✅ Installed
- mcp-filesystem-server     ✅ Installed
- mcp-shell                 ✅ Installed
```

#### Python/UV-based MCPs (Managed by Home Manager)
```nix
- mcp-server-fetch          ✅ Installed
- mcp-server-time           ✅ Installed
- sequential-thinking-mcp   ✅ Installed
```

**Installation Method**: Wrapper scripts that auto-install on first run
**Update Strategy**: Systemd service `mcp-servers-updater.service` (manual trigger)

---

### 2. Claude Code CLI Configuration
**File**: `~/.claude/mcp_config.json`
**Purpose**: Defines which MCPs are active for Claude Code sessions

#### Currently Configured MCPs
```json
{
  "filesystem": {
    "command": "/home/mitso/.mcp-servers/filesystem/mcp-filesystem-server",
    "args": ["/home/mitso"],
    "status": "⚠️ Path uses 'mitso' instead of 'mitsio'"
  },

  "mcp-shell": {
    "command": "/home/mitso/.mcp-servers/mcp-shell/bin/mcp-shell",
    "env": {
      "MCP_SHELL_SEC_CONFIG_FILE": "/home/mitso/.config/mcp-shell/security.json"
    },
    "status": "⚠️ Path uses 'mitso' instead of 'mitsio'"
  },

  "claude-thread-continuity": {
    "command": "/run/current-system/sw/bin/bash",
    "args": ["/home/mitso/.mcp-servers/claude-thread-continuity/run-server.sh"],
    "status": "⚠️ Path uses 'mitso' + not in home-manager"
  },

  "context7": {
    "command": "/run/current-system/sw/bin/npx",
    "args": ["-y", "@upstash/context7-mcp", "--api-key", "ctx7sk-***"],
    "status": "✅ Uses npx (good), API key exposed"
  },

  "github": {
    "command": "/run/current-system/sw/bin/docker",
    "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
    "status": "⚠️ Token exposed in config, Docker-based"
  }
}
```

---

### 3. Claude Code Settings
**File**: `~/.claude/settings.json`

Only `bash-history` MCP is configured here:
```json
{
  "mcpServers": {
    "bash-history": {
      "command": "bunx",
      "args": ["github:nitsanavni/bash-history-mcp", "mcp"]
    }
  }
}
```

---

### 4. NixOS System Configuration
**File**: `hosts/shoshin/nixos/modules/development/mcp-servers.nix`
**Status**: Mostly empty, just ensures Node.js availability
**File**: `hosts/shoshin/nixos/modules/development/mcp-limits.nix`
**Status**: ✅ Has resource limits configured, but **not enforced for MCP processes**

#### Configured Limits (NOT currently applied to MCPs)
```nix
systemd.slices."mcp-servers" = {
  MemoryMax = "6G";     # Not enforced
  MemoryHigh = "5G";    # Not enforced
  CPUQuota = "400%";    # Not enforced (4 cores max)
};
```

**Problem**: MCPs are not running under this systemd slice, so limits are not applied.

---

## 🔍 Mystery: Undeclared MCP Servers

Some MCPs are **running but not declared** in any config file:

1. **`any-chat-completions-mcp`** (Grok/ChatGPT wrapper)
   - Running: ✅ Yes (~8 instances)
   - Declared in home-manager: ❌ No
   - Declared in Claude config: ❌ No
   - **Hypothesis**: Launched dynamically by Claude Code or configured per-project/session

---

## 📈 Resource Impact

### CPU Usage Pattern
- **Normal state**: 10-30% baseline
- **During MCP spawn**: Spikes to **80-100%** CPU
- **Contributing factors**:
  - 8x duplicate instances of each MCP
  - Node.js processes for NPM MCPs
  - Python processes for UV MCPs
  - Multiple `uv tool uvx` wrapper processes

### Memory Usage
- **Each MCP set**: ~1-2GB total
- **Current state** (8 sets): ~8-16GB consumed by MCPs alone
- **System has**: 16GB RAM total
- **Risk**: System swap thrashing when all MCPs are active

---

## 🎯 Root Cause Analysis

### Why Multiple Instances?

1. **Each Claude Code window spawns its own MCPs**
   - No shared MCP server pool
   - No cleanup when window closes
   - Orphaned processes accumulate

2. **MCP servers don't auto-terminate**
   - Continue running even after Claude Code window closes
   - No systemd service management
   - No automatic cleanup mechanism

3. **No resource limits enforced**
   - systemd slice `mcp-servers` exists but is **not used**
   - MCPs run as regular user processes without cgroups control
   - No per-process CPU/memory limits

---

## 🛠️ Recommended Solutions

### Immediate Actions (Priority Order)

#### 1. **Kill Duplicate MCP Processes** (Immediate relief)
```bash
# Kill all MCP server processes
pkill -f "mcp-server-fetch"
pkill -f "mcp-read-website-fast"
pkill -f "mcp-server-time"
pkill -f "any-chat-completions-mcp"
pkill -f "context7-mcp"
pkill -f "sequential-thinking-mcp"
pkill -f "firecrawl-mcp"

# Or kill all at once
pkill -f "mcp|context7|firecrawl|sequential-thinking"
```

#### 2. **Close Extra Claude Code Windows**
- Keep only 1-2 active Claude Code sessions
- Use `/quit` or close windows properly
- Monitor with: `ps aux | grep claude | wc -l`

#### 3. **Fix mcp_config.json Paths**
- Update `/home/mitso/` → `/home/mitsio/` in `~/.claude/mcp_config.json`
- Ensure all MCP paths are correct

### Long-term Solutions

#### Option A: **Systemd User Services** (Recommended)
Create systemd user services for each MCP server that:
- Run as singleton instances (only one per user)
- Auto-restart on failure
- Enforce resource limits via systemd slice
- Cleanup automatically on logout

#### Option B: **Shared MCP Server Pool**
- Run MCPs as persistent background services
- All Claude Code instances connect to the same pool
- Use systemd socket activation

#### Option C: **Reduce Active MCPs**
- Disable heavy MCPs you don't use frequently
- Keep only essential MCPs enabled globally
- Enable others on-demand per project

---

## 📋 MCP Server Usage Recommendations

### Core MCPs (Keep Always Active)
```
✅ filesystem          - Essential for file operations
✅ mcp-shell           - Essential for command execution
✅ mcp-server-fetch    - Lightweight, useful for web content
✅ mcp-server-time     - Minimal overhead, timezone helper
```

### Heavy MCPs (Enable On-Demand)
```
⚠️ firecrawl-mcp           - Use only when doing heavy web scraping
⚠️ context7-mcp            - Use only when researching libraries/docs
⚠️ sequential-thinking-mcp - Use only for complex planning tasks
⚠️ any-chat-completions    - Consider if really needed (adds Grok/ChatGPT)
```

### Optional MCPs (Consider Disabling)
```
❌ github                  - Docker-based, heavy, only for GitHub-specific tasks
❌ claude-thread-continuity - Experimental, evaluate if actually useful
```

---

## 🔧 Next Steps

1. **Document which MCPs you actually use regularly**
2. **Decide on preferred architecture** (systemd services vs on-demand vs shared pool)
3. **Fix path inconsistencies** (`mitso` vs `mitsio`)
4. **Implement resource limits properly**
5. **Add cleanup automation** (systemd units or shell scripts)

---

## 📝 Notes

- **Home Manager vs Direct Install**: home-manager ensures MCPs are reproducible and version-controlled
- **NPX vs Installed**: Using `npx -y` spawns temporary processes, using installed binaries is more efficient
- **UV Tool Uvx**: Python MCPs use UV's tool runner, which caches environments
- **API Keys**: Several MCPs have API keys exposed in plaintext config (context7, github)

---

**Investigation Date**: 2025-12-04T20:11+02:00 (Europe/Athens)
**Next Review**: After implementing cleanup solution
