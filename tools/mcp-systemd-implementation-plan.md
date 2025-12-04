# MCP Servers - Systemd Implementation Plan

**Date**: 2025-12-04
**Goal**: Implement proper resource limits and process management for MCP servers
**Estimated Time**: 30-60 minutes

---

## 🎯 Solution Architecture

### Challenge: MCP Protocol Uses stdio
The MCP (Model Context Protocol) uses **stdin/stdout for communication**, which means:
- Each Claude Code session **must spawn its own MCP process**
- We **cannot** have a single shared MCP server that multiple clients connect to
- Traditional "persistent systemd service" approach won't work

### Solution: Systemd Transient Scopes + Resource Limits

Instead of persistent services, we'll use:

1. **Systemd Transient Scopes** - Automatically group MCP processes
2. **Systemd Slice** - Enforce collective resource limits on all MCPs
3. **Wrapper Scripts** - Launch MCPs within systemd scopes
4. **Automatic Cleanup** - systemd cleans up orphaned processes

### Benefits
✅ Each Claude Code session gets its own MCP instances (required for stdio)
✅ All MCPs run under unified resource limits
✅ Automatic cleanup when processes end
✅ No orphaned processes
✅ Works with existing MCP protocol
✅ Centralized monitoring with `systemctl status`

---

## 📋 Implementation Steps

### Phase 1: Cleanup & Preparation (5 min)

#### 1.1 Kill All Current MCP Processes
```bash
# Kill all running MCPs
pkill -f "mcp-server-fetch"
pkill -f "mcp-read-website-fast"
pkill -f "mcp-server-time"
pkill -f "any-chat-completions-mcp"
pkill -f "context7-mcp"
pkill -f "sequential-thinking-mcp"
pkill -f "firecrawl-mcp"

# Verify all killed
ps aux | grep -E "mcp|context7|firecrawl" | grep -v grep
```

#### 1.2 Close Extra Claude Code Windows
- Keep only 1 active Claude Code session for testing
- Close all other windows

---

### Phase 2: Create Systemd Slice (5 min)

#### 2.1 Create Slice Configuration
**File**: `~/.config/systemd/user/mcp-servers.slice`

```ini
[Unit]
Description=MCP Server Resource Limits Slice
Documentation=man:systemd.slice(5)

[Slice]
# Memory Limits
MemoryMax=6G          # Hard limit: kill if exceeded
MemoryHigh=5G         # Soft limit: throttle if exceeded
MemorySwapMax=0       # No swap usage

# CPU Limits
CPUQuota=400%         # Max 4 CPU cores
CPUWeight=100         # Normal priority

# Task Limits
TasksMax=256          # Max 256 processes in this slice

# I/O Limits (optional)
IOWeight=100

[Install]
WantedBy=default.target
```

#### 2.2 Enable Slice
```bash
systemctl --user daemon-reload
systemctl --user start mcp-servers.slice
systemctl --user enable mcp-servers.slice
systemctl --user status mcp-servers.slice
```

---

### Phase 3: Create MCP Wrapper Scripts (15 min)

We'll create wrapper scripts that:
- Launch MCPs inside systemd transient scopes
- Apply resource limits per MCP type
- Provide logging
- Auto-cleanup on exit

#### 3.1 NPM-based MCP Wrapper Template

**File**: `~/.local/bin/mcp-wrapper-npm`

```bash
#!/usr/bin/env bash
# MCP NPM Wrapper - Launches NPM-based MCPs in systemd scope

set -euo pipefail

# Arguments
MCP_NAME="${1:-}"
MCP_PACKAGE="${2:-}"
shift 2
MCP_ARGS=("$@")

if [[ -z "$MCP_NAME" ]] || [[ -z "$MCP_PACKAGE" ]]; then
    echo "Usage: $0 <mcp-name> <npm-package> [args...]"
    exit 1
fi

# Scope name (unique per invocation)
SCOPE_NAME="mcp-${MCP_NAME}-${RANDOM}.scope"

# Launch in systemd scope
exec systemd-run \
    --user \
    --scope \
    --slice=mcp-servers.slice \
    --unit="${SCOPE_NAME}" \
    --description="MCP Server: ${MCP_NAME}" \
    --collect \
    --property=MemoryMax=1G \
    --property=CPUQuota=100% \
    -- \
    npx -y "${MCP_PACKAGE}" "${MCP_ARGS[@]}"
```

#### 3.2 Python/UV MCP Wrapper

**File**: `~/.local/bin/mcp-wrapper-uv`

```bash
#!/usr/bin/env bash
# MCP UV Wrapper - Launches Python/UV-based MCPs in systemd scope

set -euo pipefail

MCP_NAME="${1:-}"
MCP_PACKAGE="${2:-}"
shift 2
MCP_ARGS=("$@")

if [[ -z "$MCP_NAME" ]] || [[ -z "$MCP_PACKAGE" ]]; then
    echo "Usage: $0 <mcp-name> <uv-package> [args...]"
    exit 1
fi

SCOPE_NAME="mcp-${MCP_NAME}-${RANDOM}.scope"

exec systemd-run \
    --user \
    --scope \
    --slice=mcp-servers.slice \
    --unit="${SCOPE_NAME}" \
    --description="MCP Server: ${MCP_NAME}" \
    --collect \
    --property=MemoryMax=1G \
    --property=CPUQuota=100% \
    -- \
    uv tool run "${MCP_PACKAGE}" "${MCP_ARGS[@]}"
```

#### 3.3 Go MCP Wrapper

**File**: `~/.local/bin/mcp-wrapper-go`

```bash
#!/usr/bin/env bash
# MCP Go Wrapper - Launches Go-based MCPs in systemd scope

set -euo pipefail

MCP_NAME="${1:-}"
MCP_BINARY="${2:-}"
shift 2
MCP_ARGS=("$@")

if [[ -z "$MCP_NAME" ]] || [[ -z "$MCP_BINARY" ]]; then
    echo "Usage: $0 <mcp-name> <go-binary-path> [args...]"
    exit 1
fi

SCOPE_NAME="mcp-${MCP_NAME}-${RANDOM}.scope"

exec systemd-run \
    --user \
    --scope \
    --slice=mcp-servers.slice \
    --unit="${SCOPE_NAME}" \
    --description="MCP Server: ${MCP_NAME}" \
    --collect \
    --property=MemoryMax=512M \
    --property=CPUQuota=50% \
    -- \
    "${MCP_BINARY}" "${MCP_ARGS[@]}"
```

#### 3.4 Make Wrappers Executable
```bash
chmod +x ~/.local/bin/mcp-wrapper-{npm,uv,go}
```

---

### Phase 4: Update Claude Code MCP Config (10 min)

#### 4.1 Backup Current Config
```bash
cp ~/.claude/mcp_config.json ~/.claude/mcp_config.json.backup-$(date +%Y%m%d)
```

#### 4.2 Create New mcp_config.json

**File**: `~/.claude/mcp_config.json`

```json
{
  "mcpServers": {
    "fetch": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-uv",
      "args": ["fetch", "mcp-server-fetch"],
      "env": {
        "PATH": "/run/current-system/sw/bin:/usr/bin:/bin"
      }
    },

    "read-website-fast": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-npm",
      "args": ["read-website-fast", "@just-every/mcp-read-website-fast"],
      "env": {
        "PATH": "/run/current-system/sw/bin:/usr/bin:/bin"
      }
    },

    "time": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-uv",
      "args": ["time", "mcp-server-time", "--local-timezone=Europe/Athens"],
      "env": {
        "PATH": "/run/current-system/sw/bin:/usr/bin:/bin"
      }
    },

    "context7": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-npm",
      "args": [
        "context7",
        "@upstash/context7-mcp",
        "--api-key",
        "ctx7sk-cf785e40-8581-4dcd-a9c5-01a8de83ec67"
      ],
      "env": {
        "PATH": "/run/current-system/sw/bin:/usr/bin:/bin"
      }
    },

    "sequential-thinking": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-uv",
      "args": [
        "sequential-thinking",
        "--from",
        "git+https://github.com/arben-adm/mcp-sequential-thinking",
        "--with",
        "portalocker",
        "mcp-sequential-thinking"
      ],
      "env": {
        "PATH": "/run/current-system/sw/bin:/usr/bin:/bin"
      }
    },

    "firecrawl": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-npm",
      "args": ["firecrawl", "firecrawl-mcp"],
      "env": {
        "PATH": "/run/current-system/sw/bin:/usr/bin:/bin",
        "FIRECRAWL_API_KEY": "fc-4946bf64171a475a93bb660d60a9b614"
      }
    },

    "filesystem": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-go",
      "args": [
        "filesystem",
        "/home/mitsio/go/bin/mcp-filesystem-server",
        "/home/mitsio"
      ],
      "env": {
        "PATH": "/home/mitsio/go/bin:/run/current-system/sw/bin:/usr/bin:/bin"
      }
    },

    "mcp-shell": {
      "command": "/home/mitsio/.local/bin/mcp-wrapper-go",
      "args": [
        "shell",
        "/home/mitsio/go/bin/mcp-shell"
      ],
      "env": {
        "PATH": "/home/mitsio/go/bin:/run/current-system/sw/bin:/usr/bin:/bin",
        "MCP_SHELL_SEC_CONFIG_FILE": "/home/mitsio/.config/mcp-shell/security.json"
      }
    },

    "github": {
      "command": "systemd-run",
      "args": [
        "--user",
        "--scope",
        "--slice=mcp-servers.slice",
        "--unit=mcp-github-${RANDOM}.scope",
        "--collect",
        "--property=MemoryMax=2G",
        "--property=CPUQuota=100%",
        "--",
        "/run/current-system/sw/bin/docker",
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
      }
    }
  }
}
```

**Note**: `claude-thread-continuity` removed (needs investigation if actually useful)

---

### Phase 5: Update ~/.claude/settings.json (5 min)

Keep bash-history as-is, no changes needed:

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

### Phase 6: Testing (10 min)

#### 6.1 Start Fresh Claude Code Session
```bash
# Open new Claude Code window
code ~/.MyHome/MySpaces/my-modular-workspace
```

#### 6.2 Verify MCPs Launch in Systemd Scopes
```bash
# Check running scopes
systemctl --user list-units --type=scope | grep mcp

# Check slice resource usage
systemd-cgtop --user
```

#### 6.3 Test MCP Functionality
In Claude Code, test each MCP:
- `fetch`: Ask to fetch a webpage
- `time`: Ask for current time
- `context7`: Ask about a library
- `sequential-thinking`: Ask to "ultrathink" about something
- `filesystem`: Ask to list files
- `mcp-shell`: Ask to run a command

#### 6.4 Monitor Resource Usage
```bash
# Watch MCP resource consumption in real-time
watch -n 2 'systemctl --user status mcp-servers.slice'

# Or with systemd-cgtop
systemd-cgtop --user
```

#### 6.5 Test Cleanup
```bash
# Close Claude Code window
# Wait 10 seconds
# Verify all MCP scopes are cleaned up:
systemctl --user list-units --type=scope | grep mcp
# Should return empty
```

---

### Phase 7: Monitoring & Verification (5 min)

#### 7.1 Create Monitoring Script

**File**: `~/.local/bin/mcp-monitor`

```bash
#!/usr/bin/env bash
# Monitor MCP servers resource usage

echo "=== MCP Servers Slice Status ==="
systemctl --user status mcp-servers.slice --no-pager

echo ""
echo "=== Active MCP Scopes ==="
systemctl --user list-units --type=scope 'mcp-*.scope' --no-pager

echo ""
echo "=== MCP Resource Usage ==="
systemd-cgtop --user -n 1 --raw | grep -E "mcp-servers.slice|UNIT"

echo ""
echo "=== Running MCP Processes ==="
ps aux --sort=-%cpu | grep -E "mcp|context7|firecrawl|sequential" | grep -v grep | head -20
```

```bash
chmod +x ~/.local/bin/mcp-monitor
```

#### 7.2 Create Cleanup Script

**File**: `~/.local/bin/mcp-cleanup`

```bash
#!/usr/bin/env bash
# Kill all MCP processes and clean up scopes

echo "🧹 Cleaning up MCP processes..."

# Kill all MCP processes
pkill -f "mcp-server-fetch"
pkill -f "mcp-read-website-fast"
pkill -f "mcp-server-time"
pkill -f "any-chat-completions-mcp"
pkill -f "context7-mcp"
pkill -f "sequential-thinking-mcp"
pkill -f "firecrawl-mcp"

# Stop all MCP scopes
systemctl --user stop 'mcp-*.scope' 2>/dev/null || true

echo "✅ Cleanup complete!"
echo ""
echo "Remaining MCP processes:"
ps aux | grep -E "mcp|context7|firecrawl" | grep -v grep || echo "  None"
```

```bash
chmod +x ~/.local/bin/mcp-cleanup
```

---

## 📊 Expected Results

### Before Implementation
```
Active MCP Processes: ~50-60
Memory Usage: ~8-16GB
CPU Usage: Spikes to 100%
Cleanup: Manual, orphaned processes
```

### After Implementation
```
Active MCP Processes: ~7-14 (depending on open Claude Code windows)
Memory Usage: Max 6GB (enforced by slice)
CPU Usage: Max 400% (4 cores, enforced)
Cleanup: Automatic via systemd
Resource Limits: Enforced per-MCP and globally
```

---

## 🔧 Troubleshooting

### Issue: Wrapper Scripts Don't Execute
```bash
# Check if scripts exist
ls -la ~/.local/bin/mcp-wrapper-*

# Check permissions
chmod +x ~/.local/bin/mcp-wrapper-*

# Test wrapper manually
~/.local/bin/mcp-wrapper-npm test @just-every/mcp-read-website-fast
```

### Issue: Systemd Slice Not Applied
```bash
# Check slice status
systemctl --user status mcp-servers.slice

# Reload systemd
systemctl --user daemon-reload

# Restart slice
systemctl --user restart mcp-servers.slice
```

### Issue: MCPs Not Starting
```bash
# Check Claude Code logs
journalctl --user -u 'mcp-*.scope' -f

# Check wrapper script logs
systemd-run --user --scope --slice=mcp-servers.slice -- \
    ~/.local/bin/mcp-wrapper-npm test @just-every/mcp-read-website-fast
```

### Issue: Resource Limits Not Working
```bash
# Verify limits are applied
systemctl --user show mcp-servers.slice | grep -E "Memory|CPU"

# Check actual resource usage
systemd-cgtop --user
```

---

## 📝 Next Steps After Implementation

1. **Monitor for 1 week** - Watch resource usage patterns
2. **Adjust limits** - Fine-tune MemoryMax/CPUQuota based on actual usage
3. **Add to home-manager** - Make wrappers & slice declarative
4. **Document learnings** - Update docs/tools/mcp-servers.md
5. **Consider optional MCPs** - Disable rarely-used heavy MCPs

---

## 🎯 Success Criteria

- ✅ All MCPs launch successfully
- ✅ Resource usage stays under limits
- ✅ No orphaned processes after closing Claude Code
- ✅ No CPU spikes to 100%
- ✅ Memory usage capped at 6GB for all MCPs
- ✅ Easy monitoring with `mcp-monitor` script

---

**Created**: 2025-12-04T21:17+02:00
**Status**: Ready for implementation
**Estimated Total Time**: 30-60 minutes
