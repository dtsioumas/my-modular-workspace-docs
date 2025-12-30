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
# Gemini CLI Installation Plan - Critical Review

**Date:** 2025-12-11T05:55:32+02:00
**Review Method:** Sequential Thinking (Ultrathink)
**Plan Reviewed:** `docs/plans/PLAN_GEMINI_CLI_INSTALLATION.md`
**Review Confidence:** 0.91 (Band C - HIGH)

---

## Executive Summary

The Gemini CLI installation plan is **structurally sound** and follows best practices for phased implementation. However, **7 critical issues** and **3 minor gaps** were identified that must be addressed before implementation.

### Overall Assessment

| Category | Rating | Notes |
|----------|--------|-------|
| **Structure** | ✅ Excellent | Clear phases, success criteria, rollback procedures |
| **ADR Compliance** | ⚠️ VIOLATION | Violates ADR-010 (MCP servers must be Nix packages) |
| **Security** | ✅ Good | KeePassXC integration well-designed |
| **Prerequisites** | ⚠️ Incomplete | Missing npm/uv availability checks |
| **Testing** | ⚠️ Gaps | No rate limit handling, timing issues |
| **Documentation** | ⚠️ Minor gaps | Missing integration with existing docs structure |

**Recommendation:** Address critical issues before implementation.

---

## Critical Issues (Must Fix)

### 🔴 Issue 1: ADR-010 Violation - Runtime MCP Installers

**Severity:** CRITICAL
**Location:** Phase 1, `mcpServers` configuration
**Impact:** Breaks reproducibility, violates project architecture decisions

**Problem:**

The plan uses runtime installers for MCP servers:

```nix
mcpServers = {
  context7 = {
    command = "npx";  # ❌ Runtime installer
    args = ["-y" "@upstash/context7-mcp" "--api-key" "\${CONTEXT7_API_KEY}"];
  };

  fetch = {
    command = "uvx";  # ❌ Runtime installer
    args = ["mcp-server-fetch"];
  };
}
```

**Why This Is Wrong:**

- **ADR-010 states:** "ALL MCP servers MUST be Nix packages/derivations"
- Runtime installers (`npx -y`, `uvx`) break reproducibility
- No version pinning (gets latest on every run)
- Network dependency at launch time

**Correct Approach:**

```nix
mcpServers = {
  context7 = {
    # Use Nix-packaged binary from home-manager/mcp-servers/
    command = "${pkgs.context7-mcp}/bin/context7-mcp";
    env.API_KEY = "\${CONTEXT7_API_KEY}";
  };

  fetch = {
    # Use Python package from Nix store
    command = "${pkgs.python3Packages.mcp-server-fetch}/bin/mcp-server-fetch";
  };
}
```

**Action Required:**

1. Reference existing Nix MCP packages from ADR-010 implementation
2. Use paths from Nix store (`${pkgs.package-name}/bin/binary`)
3. Remove all `npx -y` and `uvx` runtime installers
4. Update plan Phase 1 with correct paths

**References:**
- ADR-010:410 (MCP servers as Nix packages)
- `home-manager/mcp-servers/` directory structure

---

### 🔴 Issue 2: Nix Variable Escaping Bug

**Severity:** CRITICAL
**Location:** Phase 1, environment variable references
**Impact:** API keys will be literal strings, not environment variables

**Problem:**

```nix
env = {
  CONTEXT7_API_KEY = "\${CONTEXT7_API_KEY}";  # ❌ Wrong escaping
};
```

**Why This Is Wrong:**

In Nix strings:
- `"${VAR}"` → Nix variable interpolation (evaluates at build time)
- `"\${VAR}"` → Escapes the `$`, produces literal string `${VAR}`
- Settings.json will contain literal `${CONTEXT7_API_KEY}` instead of value

**Correct Approach:**

Gemini CLI uses its own variable substitution in settings.json:

```nix
# Option A: Let Gemini CLI handle variable substitution
env = {
  CONTEXT7_API_KEY = "$CONTEXT7_API_KEY";  # Gemini CLI substitutes
};

# Option B: Use Nix's config.home.sessionVariables
env = {
  CONTEXT7_API_KEY = config.home.sessionVariables.CONTEXT7_API_KEY or "$CONTEXT7_API_KEY";
};
```

**Action Required:**

1. Remove backslash escapes from all `\${VAR}` references
2. Use `$VAR` or `${VAR}` syntax (Gemini CLI handles substitution)
3. Test that environment variables are correctly loaded

**Documentation:**
- Gemini CLI config docs: "String values can reference environment variables using `$VAR_NAME` or `${VAR_NAME}` syntax"

---

### 🟡 Issue 3: Missing Prerequisites - npm/uv Availability

**Severity:** HIGH
**Location:** Prerequisites section
**Impact:** Build may fail if npm/uv not in PATH

**Problem:**

The plan assumes `npx` and `uvx` are available but doesn't verify or ensure this:

```bash
# Prerequisites check doesn't include:
which npx    # ❌ Not checked
which uvx    # ❌ Not checked
```

**Why This Matters:**

- MCP server commands reference `npx` and `uvx`
- If not in PATH during home-manager activation → build fails
- User may not have nodejs or uv installed

**Correct Approach:**

**Prerequisites Section:**

```bash
# Check Node.js and npm
which node && which npx
node --version  # Should be >= 20

# Check uv (Python package manager)
which uv && which uvx
uv --version
```

**Home-Manager Module:**

```nix
# Ensure dependencies are available
home.packages = with pkgs; [
  nodejs_20  # For npx
  uv         # For uvx (Python package manager)
];
```

**Action Required:**

1. Add npm and uv checks to Prerequisites section
2. Add `nodejs` and `uv` to `home.packages` in gemini-cli.nix
3. Document version requirements

---

### 🟡 Issue 4: KeePassXC Timing Issues

**Severity:** HIGH
**Location:** Phase 2, secrets loader service
**Impact:** API keys may fail to load if vault is locked

**Problem:**

```nix
systemd.user.services.load-gemini-secrets = {
  Unit = {
    After = [ "graphical-session.target" ];
  };
  # ...
};
```

**Why This Is Problematic:**

- Service runs after graphical session starts
- But KeePassXC vault may not be unlocked yet
- `secret-tool lookup` will fail silently if vault is locked
- No retry mechanism or user notification

**Correct Approach:**

```nix
systemd.user.services.load-gemini-secrets = {
  Unit = {
    Description = "Load Gemini CLI API keys from KeePassXC";
    After = [ "graphical-session.target" ];
    Wants = [ "graphical-session.target" ];
    # Add condition to wait for KeePassXC
    ConditionPathExists = "%h/MyVault/";  # Vault exists
  };

  Service = {
    Type = "oneshot";
    RemainAfterExit = true;
    Restart = "on-failure";  # Retry if fails
    RestartSec = "10s";

    ExecStart = pkgs.writeShellScript "load-gemini-secrets" ''
      set -euo pipefail

      # Wait for KeePassXC to be available (max 30 seconds)
      for i in {1..30}; do
        if secret-tool lookup service test key test 2>/dev/null; then
          break
        fi
        sleep 1
      done

      # Load API key with error handling
      GEMINI_API_KEY=$(secret-tool lookup service gemini key apikey 2>/dev/null || {
        notify-send "Gemini CLI" "Failed to load API key. Is KeePassXC unlocked?"
        exit 1
      })

      # ... rest of script ...
    '';
  };
};
```

**Action Required:**

1. Add wait loop for KeePassXC availability
2. Add error notification via `notify-send`
3. Add `Restart = "on-failure"` for retry capability
4. Document manual unlock requirement in Prerequisites

---

### 🟡 Issue 5: CLAUDE.md Symlink Conflict

**Severity:** MEDIUM
**Location:** Phase 6, integration instructions
**Impact:** Changes will be lost on next home-manager switch

**Problem:**

Plan says: "Append to `~/.claude/CLAUDE.md`"

But `CLAUDE.md` is managed by home-manager and is a symlink:

```bash
ls -la ~/.MyHome/MySpaces/my-modular-workspace/CLAUDE.md
# → Symlink to /nix/store/.../CLAUDE.md
```

**Why This Is Wrong:**

- Manually editing a symlinked file doesn't persist
- Next `home-manager switch` will overwrite changes
- File is immutable in Nix store

**Correct Approach:**

**Option A: Update source file in home-manager**

```nix
# home-manager/claude.nix (or wherever CLAUDE.md is defined)
home.file.".MyHome/MySpaces/my-modular-workspace/CLAUDE.md".text = ''
  [... existing content ...]

  ## Gemini CLI Integration
  [... new content ...]
'';
```

**Option B: Use chezmoi if CLAUDE.md is managed there**

```bash
# If using chezmoi
chezmoi edit ~/.MyHome/MySpaces/my-modular-workspace/CLAUDE.md
# Then apply
chezmoi apply
```

**Action Required:**

1. Check how CLAUDE.md is currently managed (home-manager vs chezmoi)
2. Update Phase 6 instructions to use correct method
3. Remove manual edit instructions

---

### 🟢 Issue 6: Test Rate Limiting Not Addressed

**Severity:** LOW
**Location:** Phase 4, MCP server testing
**Impact:** API rate limits may be hit during testing

**Problem:**

Plan suggests testing all MCP servers in rapid succession:

```bash
# Test 1: time
# Test 2: fetch
# Test 3: context7
# Test 4: firecrawl
# ... (7+ tests in quick succession)
```

**Why This Matters:**

- APIs like Firecrawl, Context7, Exa have rate limits
- Testing all at once may hit limits
- No guidance on test pacing

**Recommended Approach:**

```markdown
### 4.2 Test Individual MCP Servers

**Important:** Pace tests to avoid rate limits. Wait 10-30 seconds between API-based tests.

**Test Order (safe → rate-limited):**

1. **time** (no API, safe)
2. **fetch** (no API, safe)
3. **sequential-thinking** (no API, safe)
4. Wait 30 seconds
5. **context7** (API, rate limited)
6. Wait 30 seconds
7. **firecrawl** (API, rate limited)
8. Wait 30 seconds
9. **exa** (API, rate limited)
```

**Action Required:**

1. Add pacing guidance to Phase 4
2. Group tests by API vs non-API
3. Add wait times between rate-limited tests

---

### 🟢 Issue 7: Incomplete Rollback Procedure

**Severity:** LOW
**Location:** Rollback section
**Impact:** Partial cleanup after rollback

**Problem:**

Rollback only removes Nix packages, doesn't clean up:

```bash
# What's missing:
# - KeePassXC secrets remain
# - systemd environment variables remain
# - ~/.gemini/ directory remains
```

**Complete Rollback Procedure:**

```bash
# 1. Remove from home-manager
# Comment out imports in home.nix

# 2. Rebuild
home-manager switch --flake .#mitsio@shoshin -b backup

# 3. Clean up secrets (optional)
secret-tool clear service gemini key apikey
secret-tool clear service context7 key apikey
secret-tool clear service firecrawl key apikey
secret-tool clear service exa key apikey

# 4. Clean up environment
systemctl --user unset-environment GEMINI_API_KEY
systemctl --user unset-environment CONTEXT7_API_KEY
systemctl --user unset-environment FIRECRAWL_API_KEY
systemctl --user unset-environment EXA_API_KEY

# 5. Remove config directory (optional)
rm -rf ~/.gemini/

# 6. Verify cleanup
which gemini  # Should return nothing
echo $GEMINI_API_KEY  # Should be empty
```

**Action Required:**

1. Expand rollback section with full cleanup steps
2. Mark secrets cleanup as optional (if user wants to keep)
3. Add verification steps

---

## Minor Gaps (Nice to Have)

### Gap 1: Documentation Integration

**Issue:** Plan creates `docs/tools/gemini-cli.md` but doesn't integrate with existing docs structure.

**Fix:** Add step to update `docs/tools/README.md` or index file:

```markdown
### 7.2 Update Documentation Index

**File:** `docs/tools/README.md`

Add entry:

```markdown
## Terminal AI Agents

- **[Gemini CLI](gemini-cli.md)** - Google's AI agent with MCP support
- **[Claude Code](claude-code.md)** - Anthropic's coding assistant (existing)
```
```

---

### Gap 2: Version Tracking

**Issue:** No guidance on tracking Gemini CLI version or updating.

**Fix:** Add to plan:

```markdown
### Gemini CLI Version Management

**Check current version:**

```bash
gemini --version
```

**Update to latest:**

```bash
# Update nixpkgs-unstable input
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
nix flake update nixpkgs

# Rebuild
home-manager switch --flake .#mitsio@shoshin
```

**Pin specific version:**

```nix
# In home-manager/gemini-cli.nix
programs.gemini-cli.package = pkgs.gemini-cli.overrideAttrs (old: {
  version = "1.2.3";  # Pin to specific version
});
```
```

---

### Gap 3: Project-Specific Context Templates

**Issue:** Phase 5 creates project context manually. Could be templated for reuse.

**Fix:** Create template in `docs/templates/`:

```markdown
**File:** `docs/templates/GEMINI.md.template`

```markdown
# {{ PROJECT_NAME }} - Gemini CLI Context

## Project Overview
{{ PROJECT_DESCRIPTION }}

## Repository Structure
{{ REPO_STRUCTURE }}

## Important Notes
{{ PROJECT_SPECIFIC_NOTES }}
```
```

---

## Positive Aspects (Strengths)

Despite the issues found, the plan has many strengths:

✅ **Clear phase structure** with dependencies
✅ **Comprehensive success criteria** for each phase
✅ **Good security model** (KeePassXC integration)
✅ **Realistic time estimates** (2-3 hours total)
✅ **Rollback procedure included** (with improvements needed)
✅ **Troubleshooting section** for common issues
✅ **Testing strategy** per MCP server
✅ **Documentation created** alongside implementation

---

## Recommended Actions

### Before Implementation

1. **Fix ADR-010 violation** (Critical)
   - Replace runtime installers with Nix package paths
   - Reference `home-manager/mcp-servers/` binaries

2. **Fix Nix escaping** (Critical)
   - Change `"\${VAR}"` to `"$VAR"` in all env configs

3. **Add prerequisites** (High)
   - Add `nodejs` and `uv` to home.packages
   - Add checks to Prerequisites section

4. **Fix KeePassXC timing** (High)
   - Add wait loop for vault unlock
   - Add retry mechanism to systemd service

5. **Fix CLAUDE.md edit** (Medium)
   - Determine actual management method
   - Update Phase 6 instructions

### After Implementation

6. **Update docs index** (Low)
   - Integrate gemini-cli.md with existing docs

7. **Add version tracking** (Low)
   - Document update procedures

8. **Create context templates** (Low)
   - Reusable project context templates

---

## Updated Risk Assessment

| Risk | Before Review | After Fixes | Mitigation |
|------|---------------|-------------|------------|
| **ADR Violation** | 🔴 High | 🟢 Low | Use Nix packages instead of runtime installers |
| **Build Failure** | 🟡 Medium | 🟢 Low | Add nodejs/uv to prerequisites |
| **API Key Loading** | 🟡 Medium | 🟢 Low | Add vault unlock wait + retry |
| **Config Persistence** | 🟡 Medium | 🟢 Low | Use proper config management (not manual edits) |
| **Rate Limiting** | 🟢 Low | 🟢 Low | Add test pacing guidance |

---

## Conclusion

The Gemini CLI installation plan is **well-structured** and demonstrates **good planning practices**. However, the **ADR-010 violation is critical** and must be fixed before implementation.

**Overall Confidence:** 0.84 → 0.91 (after fixes)

**Recommendation:**
✅ **APPROVE WITH MODIFICATIONS**

Address the 5 critical/high severity issues before proceeding. The minor gaps can be addressed during or after implementation.

---

**Review Completed:** 2025-12-11T05:55:32+02:00 (Europe/Athens)
**Reviewer:** Sequential Thinking MCP (Ultrathink mode)
**Next Step:** Update plan with fixes, then proceed to implementation
# Gemini CLI Comprehensive Research Report

**Date:** 2025-12-22
**Researcher:** Technical Researcher Role
**Session:** enhancing_agents_config_week-52-2025
**Status:** Complete
**Confidence Level:** 0.87 (Band C - HIGH)

---

## Executive Summary

This report provides a comprehensive technical analysis of Google's Gemini CLI based on official documentation, GitHub releases, and community resources. The research covers seven critical areas: configuration & compression, GPU capabilities, RAM optimization, unused features, latest releases, custom command implementation, and MCP server optimization.

**Key Findings:**
- Compression threshold can be configured to 90% (value: 0.9) via `model.compressionThreshold`
- GPU support exists for containerized sandboxing but NOT for local model inference
- RAM can be optimized via `sessionRetention` policies and `maxSessionTurns` limiting
- Experimental features (codebaseInvestigator, enableAgents, jitContext) provide advanced capabilities
- Latest stable: v0.21.0-21.1 with preview features; v0.22 (Gemini 3 Flash) in beta
- Custom commands use TOML format with `{{args}}` substitution; `/summary` is built-in but `/continuation` is not standard
- MCP servers support trust settings, timeout management, and tool filtering

---

## 1. Compaction & Compression Configuration

### 1.1 Compression Threshold Setting

**Configuration Parameter:** `model.compressionThreshold`

The compression threshold can be set to **90%** (value: `0.9`) to delay context compression until your context window is nearly full.

```json
{
  "model": {
    "compressionThreshold": 0.9
  }
}
```

**Default Value:** `0.5` (50% of model token limit)
**Valid Range:** 0.0 to 1.0
**Edit Method:** Use `/settings` command in interactive mode

#### How Context Compression Works

- **Monitoring:** Gemini CLI continuously monitors token count of conversation history
- **Threshold Check:** When context exceeds the compression threshold percentage, compression is triggered
- **Process:** Instead of truncating history, the model summarizes the conversation into structured XML:
  - Overall goal
  - Key knowledge gained
  - File system state
  - Current plan
  - Progress tracking

#### The Compression Debate

**Issue #12068** on GitHub reveals the design tension:
- Default 0.5 (50%) threshold triggers compression when 50% of tokens are used
- This "pre-emptive" compression leaves 50% of token budget unused
- Compression takes 3-10 seconds per cycle
- Changing to 0.9 fully utilizes token budget before compressing

**Recommendation:** For optimization, adjust to **0.9** (90%) to minimize compression frequency and maximize context window utilization.

### 1.2 Manual Compression Command

Users can trigger compression manually using:
```
/compress
```

This immediately summarizes the current context state regardless of the threshold setting.

### 1.3 Token Caching for Cost Optimization

Gemini CLI implements **token caching** to reuse previous system instructions and context:
- Available via API key authentication (Gemini API or Vertex AI)
- Reduces tokens processed in subsequent requests
- View savings with `/stats` command
- Automatically managed by CLI

---

## 2. GPU Utilization Capabilities

### 2.1 Current GPU Support Status

**FINDING:** Gemini CLI does NOT support local GPU inference for model computation tasks.

#### What IS Supported

**Container Sandbox GPU Support (Experimental):**
- Issue #4352 proposes GPU support for container-based sandboxing
- Environment variable: `GEMINI_SANDBOX_RUNNING_GPU` (set to `true`)
- GPU hardware detection and validation (primarily NVIDIA GPUs)
- Uses `nvidia-smi` for validation when running in GPU-enabled containers

#### What IS NOT Supported

- **Local model inference** (e.g., running Gemma models locally on GPU)
- **CUDA execution** within Gemini CLI itself
- **Computation tasks** using local GPU acceleration

### 2.2 GPU Usage with Google Gemini Models

Gemini CLI uses cloud-hosted models (Gemini 3 Pro, Gemini 3 Flash, Gemini 2.5 Pro) running on Google's infrastructure. GPU acceleration is handled server-side by Google, not locally.

### 2.3 Local GPU Model Inference Alternative

Users interested in running local models with GPU can use:
- **TensorRT-LLM** (NVIDIA + Google optimized Gemma models)
- **Ollama** (local LLM runner with GPU support)
- **Hugging Face Transformers** (with CUDA backend)
- **Custom downstream forks** of gemini-cli

**Resource:** Google optimized Gemma 3 models for NVIDIA RTX GPUs (desktop & professional).

---

## 3. RAM Optimization

### 3.1 Session Retention Configuration

Control memory usage via session management policies in `settings.json`:

```json
{
  "sessionRetention": {
    "maxAge": "7d",
    "maxCount": 50,
    "minRetention": "1d"
  }
}
```

#### Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `maxAge` | Duration string | Delete sessions older than this | "24h", "7d", "4w" |
| `maxCount` | Integer | Maximum sessions to retain | 50 |
| `minRetention` | Duration string | Safety limit (never delete younger sessions) | "1d" |

#### Behavior

- Sessions older than `maxAge` are automatically deleted
- If session count exceeds `maxCount`, oldest sessions are purged
- Sessions within `minRetention` period are protected from deletion
- Automatic cleanup prevents history from growing indefinitely

### 3.2 Session Turns Limiting

Limit individual session size with:

```json
{
  "model": {
    "maxSessionTurns": 100
  }
}
```

- `-1` = unlimited turns (default)
- Positive integer = maximum turns in a single session
- Prevents context windows from becoming too large and expensive

### 3.3 RAM Memory Model (Context as RAM)

Gemini CLI conceptualizes context as "ephemeral, short-term information" equivalent to **RAM**:
- **Long-term storage:** Sessions (disk-based)
- **Active memory:** Current context (RAM)
- **Compression:** Context summarization (like memory defragmentation)

### 3.4 Additional RAM Optimization Strategies

#### Tool Output Summarization

```json
{
  "model": {
    "toolOutputSummarization": {
      "run_shell_command": {
        "tokenBudget": 2000
      }
    }
  }
}
```

- Summarizes tool outputs to reduce token consumption
- Per-tool token budgets configurable
- Reduces context bloat from verbose shell command outputs

#### Prompt Completion (Resource-Aware)

```json
{
  "promptCompletion": {
    "enabled": true
  }
}
```

- AI-powered suggestions while typing
- Can impact responsiveness on low-RAM systems
- Disable if RAM is critical constraint

---

## 4. Unused and Underutilized Features Review

### 4.1 Experimental Features (Beta/Preview)

#### 4.1.1 Codebase Investigator

**Status:** Enabled by default in v0.10.0+

```json
{
  "experimental": {
    "codebaseInvestigatorSettings": {
      "enabled": true,
      "maxNumTurns": 15,
      "model": "gemini-2.5-pro",
      "thinkingBudget": -1
    }
  }
}
```

**What it does:**
- Autonomous agent that explores your codebase
- Tackles complex multi-step investigations
- Provides comprehensive report with summary and analysis
- Great for understanding large codebases

**Requires restart:** Yes
**Resource impact:** Medium (runs multiple model turns)

#### 4.1.2 Enable Agents (Local & Remote Subagents)

**Status:** Experimental, disabled by default

```json
{
  "experimental": {
    "enableAgents": true
  }
}
```

**What it does:**
- Enables local and remote subagents
- YOLO mode (requires user oversight)
- Agent coordination and delegation

**Warning:** Experimental feature, requires careful monitoring
**Requires restart:** Yes

#### 4.1.3 JIT Context (Just-In-Time Context Loading)

**Status:** Experimental, disabled by default

```json
{
  "experimental": {
    "jitContext": true
  }
}
```

**What it does:**
- Loads context on-demand instead of pre-loading
- May reduce memory usage
- Could improve responsiveness for large contexts

**Requires restart:** Yes

### 4.2 Feature Utilization Recommendations

**Recommended for Most Users:**
- ✅ Codebase Investigator (enabled by default)
- ✅ Token caching (automatic)
- ✅ Session management policies
- ✅ Compression (automatic with customizable threshold)

**Recommended for Advanced Users:**
- ⚠️ enableAgents (experimental, requires oversight)
- ⚠️ jitContext (experimental, limited documentation)

**Not Recommended Yet:**
- ❌ GPU sandbox acceleration (not yet stable)

---

## 5. Latest Upstream Releases & New Features

### 5.1 Stable Release: v0.21.0 - v0.21.1

**Release Date:** Latest stable (as of Dec 2025)

#### Key Features

| Feature | Status | Notes |
|---------|--------|-------|
| Gemini 3 Pro | Available | For paid users, enable via `/settings` Preview Features |
| Gemini 3 Flash | Available | For paid users, enable via `/settings` Preview Features |
| Fuzzy search in settings | ✅ NEW | `/settings` command improvements |
| Message bus integration | ✅ Default enabled | Improved messaging architecture |
| Remote MCP servers | ✅ Consolidated | Uses `url` in config (simplified) |
| Auto-execute on slash commands | ✅ NEW | Automatic execution for completion functions |
| User-scoped extension settings | ✅ NEW | Per-user configuration options |

### 5.2 Beta Release: v0.22.0-preview

**Status:** In development

#### Key Features

| Feature | Status | Notes |
|---------|--------|-------|
| Gemini 3 Flash Launch | 🚀 PRIMARY | Main v0.22 feature |
| Windows clipboard images | ✅ NEW | Native image paste support |
| Alt+V paste workaround | ✅ NEW | Alternative paste method |
| Agent TOML parser | ✅ NEW | Parse agent definitions in TOML |
| Detailed model stats | ✅ NEW | Shared Table class for display |

### 5.3 Release Schedule

- **Stable:** Weekly updates
- **Nightly:** Daily updates with latest features
- **Preview:** Ongoing (v0.22 series)

### 5.4 Installation via Nixpkgs

```nix
home.packages = with pkgs; [
  gemini-cli  # v0.21.x in nixpkgs-unstable
];
```

**Note:** Nixpkgs updates lag slightly behind npm releases (typically 1-2 weeks).

---

## 6. Custom Commands & Skills Implementation

### 6.1 Creating Custom Commands

#### File Locations

**Global commands** (available in all projects):
```
~/.gemini/commands/
```

**Project-specific commands** (only in current project):
```
.gemini/commands/
```

#### TOML File Format

**Filename:** `command-name.toml`

```toml
prompt = """
Your detailed prompt here.
You can use {{args}} to insert user arguments.
"""

description = "Brief one-line description for /help menu"
```

#### {{args}} Substitution

The `{{args}}` placeholder is replaced with text the user types after the command:

```bash
/mycommand hello world
# → {{args}} becomes "hello world"
```

### 6.2 Advanced Custom Command Features

#### Shell Command Integration

Commands can execute shell commands using `!{...}` syntax:

```toml
prompt = """
Analyze these staged changes:
!{git diff --staged}

Generate a concise commit message.
"""

description = "Generate Git commit message from staged changes"
```

#### Multi-line Prompts

```toml
prompt = """
Line 1 of prompt
Line 2 of prompt
{{args}}
More context here
"""

description = "Multi-line example"
```

### 6.3 Built-in Commands

#### /summary Command

The built-in `/summary` command:
- **Purpose:** Replace entire chat context with a summary
- **Effect:** Saves tokens for future interactions
- **Retention:** Preserves high-level summary of conversation
- **Automatic:** Triggered by compression mechanism

```
/summary
```

#### /continuation Command Status

**FINDING:** There is NO built-in `/continuation` command in standard Gemini CLI.

**Options for continuation behavior:**
1. Create custom `/continuation` command
2. Use `/chat resume` (load previous session)
3. Use `/chat save` (checkpoint current context)

**Example Custom Implementation:**

```toml
# ~/.gemini/commands/continuation.toml
prompt = """
Continue from where we left off on this task:
{{args}}

What was our previous context? Let me review our session.
"""

description = "Continue previous session with context reminder"
```

### 6.4 Custom Commands Best Practices

1. **Namespace commands** with colons:
   - `/refactor:pure`, `/test:gen`, `/doc:readme`

2. **Keep prompts focused:**
   - One clear purpose per command
   - Include context requirements in description

3. **Use shell integration cautiously:**
   - Git commands are safe
   - System-modifying commands should require confirmation

4. **Version control:**
   - Add `.gemini/commands/` to project git repo
   - Exclude `.gemini/settings.json` (per ADR-009)

5. **Documentation:**
   - Write clear descriptions for `/help` menu
   - Comment complex prompts inline

---

## 7. MCP Server Optimization & Configuration

### 7.1 MCP Server Configuration Structure

MCP servers are defined in `settings.json` under `mcpServers` object.

#### Transport Options

Gemini CLI supports three transport mechanisms:

| Transport | Use Case | Performance |
|-----------|----------|-------------|
| **Stdio** | Local executables | Fastest, lowest latency |
| **SSE** | Server-Sent Events endpoints | Medium, streaming support |
| **HTTP** | Streaming HTTP endpoints | Flexible, remote compatible |

### 7.2 MCP Server Configuration Example

```json
{
  "mcpServers": {
    "context7": {
      "url": "http://localhost:8000"
    },
    "firecrawl": {
      "url": "http://localhost:3000",
      "timeout": 30000,
      "trust": false
    },
    "filesystem": {
      "command": "/path/to/mcp-server",
      "args": ["--root", "/home/user"],
      "cwd": "/home/user",
      "timeout": 10000,
      "env": {
        "LOG_LEVEL": "info",
        "API_KEY": "$FILESYSTEM_API_KEY"
      }
    }
  }
}
```

### 7.3 Performance Tuning Parameters

#### Timeout Management

```json
{
  "timeout": 600000
}
```

- **Default:** 600,000ms (10 minutes)
- **Adjust based on:** Server response times, network latency
- **Units:** Milliseconds
- **For slow servers:** Increase (e.g., 30000 for 30 seconds)
- **For quick servers:** Decrease (e.g., 5000 for 5 seconds)

#### Connection Persistence

- **Auto-persistence:** CLI maintains persistent connections to servers with registered tools
- **Auto-cleanup:** Connections to servers providing no tools are automatically closed
- **Benefit:** Reduces connection overhead for repeated tool calls

### 7.4 Trust Settings & Security

#### Trust Configuration

```json
{
  "trust": true  // or false (default)
}
```

| Value | Behavior | Use Case |
|-------|----------|----------|
| `false` | All tool executions require user confirmation | Public/untrusted servers |
| `true` | Bypasses confirmations (dangerous!) | Trusted internal servers only |

#### Recommended Trust Strategy

1. **Untrusted servers:** `trust: false` (safer, requires confirmations)
2. **Internal tools:** `trust: true` (faster, only for servers you control)
3. **Partial trust:** Use `includeTools`/`excludeTools` instead

#### Tool Filtering

```json
{
  "includeTools": ["read_file", "search"],  // Allowlist
  "excludeTools": ["delete_file"]            // Blocklist
}
```

- **includeTools:** If set, ONLY these tools are available
- **excludeTools:** Takes precedence over includeTools
- **Purpose:** Prevent dangerous operations from specific servers

### 7.5 Environment Variable Substitution

MCP servers support dynamic configuration via environment variables:

```json
{
  "env": {
    "API_KEY": "$FIRECRAWL_API_KEY",
    "API_SECRET": "${API_SECRET}",
    "LOG_LEVEL": "info"
  }
}
```

**Variable syntax:**
- `$VAR_NAME` - Simple substitution
- `${VAR_NAME}` - Explicit boundaries
- `"string-literal"` - Non-variable strings

### 7.6 MCP Server Performance Best Practices

#### 1. Minimize Tool Surface Area

```json
{
  "includeTools": ["search", "read"],  // Only what you need
  "excludeTools": []
}
```

**Benefit:** Reduces model decision space, faster inference

#### 2. Tune Timeouts per Server

```json
{
  "context7": { "timeout": 30000 },      // Long for research
  "filesystem": { "timeout": 5000 },     // Quick for file ops
  "web-fetch": { "timeout": 45000 }      // Long for scraping
}
```

**Benefit:** Prevents hanging on slow responses

#### 3. Use Stdio Transport for Local Servers

```json
{
  "command": "/nix/store/.../mcp-server",
  "args": ["--config", "$HOME/.config/mcp.json"]
}
```

**Benefit:** Faster than HTTP, no network overhead

#### 4. Enable Persistent Connections

```json
{
  "mcpServers": {
    "frequent-server": { "url": "..." }
  }
}
```

**Benefit:** CLI automatically persists connections to servers with tools

#### 5. Strategic Trust Management

```json
{
  "local-filesystem": { "trust": true },   // Only if self-contained
  "public-api": { "trust": false }         // Always confirm
}
```

**Benefit:** Balance security and usability

### 7.7 MCP Integration with Gemini 2.5 Pro

Latest improvements include:
- **Consolidated remote servers:** Uses `url` field (simplified config)
- **Auto-execute on completion:** Functions execute automatically on slash command completion
- **User-scoped extensions:** Per-user extension settings for MCP servers

---

## 8. Configuration Hierarchy (Priority Order)

Gemini CLI applies configuration in this order (highest priority wins):

1. **Command-line arguments** (highest priority)
2. **Environment variables & .env files**
3. **System settings file** (`/etc/gemini-cli/settings.json`)
4. **Project settings file** (`.gemini/settings.json`)
5. **User settings file** (`~/.gemini/settings.json`)
6. **System defaults file**
7. **Default values** (lowest priority)

**Example:**
```bash
# Override everything with CLI arg
gemini --model gemini-3-pro

# Or use environment variable
export GEMINI_MODEL=gemini-3-pro

# Or set in ~/.gemini/settings.json
# Or set in .gemini/settings.json (project-specific)
```

---

## 9. Recommended Configuration Optimizations

### For Mitsos (Your Use Case: SRE/DevOps/Research)

```json
{
  "model": {
    "compressionThreshold": 0.9,
    "maxSessionTurns": 200,
    "chatCompression": {
      "enabled": true
    }
  },
  "sessionRetention": {
    "maxAge": "30d",
    "maxCount": 100,
    "minRetention": "7d"
  },
  "promptCompletion": {
    "enabled": false
  },
  "experimental": {
    "codebaseInvestigatorSettings": {
      "enabled": true,
      "maxNumTurns": 20,
      "model": "gemini-2.5-pro"
    }
  },
  "mcpServers": {
    "context7": {
      "url": "http://localhost:8000",
      "timeout": 30000,
      "trust": false
    },
    "firecrawl": {
      "url": "http://localhost:3000",
      "timeout": 45000,
      "includeTools": ["scrape_url", "batch_scrape"]
    }
  }
}
```

**Rationale:**
- **compressionThreshold: 0.9** → Maximize token usage before compression
- **maxSessionTurns: 200** → Long exploratory sessions without memory pressure
- **sessionRetention: 30d/100 max** → Keep month of research history
- **promptCompletion: false** → Reduce RAM on resource-constrained systems
- **codebaseInvestigator: true** → Essential for large codebase analysis (your use case)
- **MCP servers trusted selectively** → Security with efficiency trade-off

---

## 10. Current Configuration Review

### Current Setup Location
```
~/.gemini/settings.json (via chezmoi: private_dot_gemini/settings.json.tmpl)
```

### Current Features in Use

From your `home-manager/gemini-cli.nix`:
- ✅ Package installation (v0.21.x from nixpkgs-unstable)
- ✅ AGENTS.md symlink (global instructions like CLAUDE.md)
- ✅ API key loading via systemd environment
- ✅ Default model: Gemini 2.5 Pro

### Recommended Additions

1. **Compression Threshold Configuration**
   ```json
   "model": { "compressionThreshold": 0.9 }
   ```

2. **Session Retention Policy**
   ```json
   "sessionRetention": { "maxAge": "30d", "maxCount": 100 }
   ```

3. **Codebase Investigator Settings**
   ```json
   "experimental": { "codebaseInvestigatorSettings": { "enabled": true } }
   ```

4. **MCP Server Configuration**
   - Already in place via your MCP servers (context7, firecrawl, etc.)
   - Verify `timeout` values are appropriate
   - Ensure `trust: false` for untrusted servers

---

## 11. References & Sources

### Official Documentation
- [Gemini CLI Official Docs](https://geminicli.com/docs/)
- [Gemini CLI Configuration Guide](https://geminicli.com/docs/get-started/configuration/)
- [Gemini CLI Custom Commands](https://geminicli.com/docs/cli/custom-commands/)
- [MCP Servers with Gemini CLI](https://geminicli.com/docs/tools/mcp-server/)
- [Session Management](https://geminicli.com/docs/cli/session-management/)
- [Token Caching & Cost Optimization](https://geminicli.com/docs/cli/token-caching/)

### GitHub Repository
- [google-gemini/gemini-cli - Official Repository](https://github.com/google-gemini/gemini-cli)
- [Gemini CLI Releases](https://github.com/google-gemini/gemini-cli/releases)
- [Issue #12068 - Compression Threshold Discussion](https://github.com/google-gemini/gemini-cli/issues/12068)
- [Issue #4352 - GPU Sandbox Support Proposal](https://github.com/google-gemini/gemini-cli/issues/4352)
- [Discussion #5945 - Local Model Support Request](https://github.com/google-gemini/gemini-cli/discussions/5945)
- [Discussion #11375 - Codebase Investigator Beta Testing](https://github.com/google-gemini/gemini-cli/discussions/11375)

### Community Articles
- [Gemini CLI Tutorial Series (Parts 1-9) - Romin Irani](https://medium.com/google-cloud/gemini-cli-tutorial-series-77da7d494718)
- [Gemini CLI Custom Slash Commands - Google Cloud Blog](https://cloud.google.com/blog/topics/developers-practitioners/gemini-cli-custom-slash-commands)
- [A Look at Context Engineering in Gemini CLI - Paul Datta](https://aipositive.substack.com/p/a-look-at-context-engineering-in)
- [Gemini CLI Hands-on Codelab - Google Codelabs](https://codelabs.developers.google.com/gemini-cli-hands-on)
- [Google Gemini CLI Cheatsheet - Philipp Schmid](https://www.philschmid.de/gemini-cli-cheatsheet)

### NPM Package
- [@google/gemini-cli - npm](https://www.npmjs.com/package/@google/gemini-cli)

---

## 12. Research Methodology

**Scope:** 7 research areas covering configuration, features, optimization, and upstream status
**Sources:** 35+ primary sources (official docs, GitHub, community articles, web research)
**Confidence Bands:**
- Configuration details: Band C (0.87) - Official docs + source code verification
- GPU support: Band B (0.72) - Discussions/issues but not production-ready
- Custom commands: Band C (0.89) - Official docs with working examples
- MCP optimization: Band C (0.85) - Official docs + configuration examples
- Releases: Band C (0.91) - Direct GitHub releases + official changelog

**Research Date:** 2025-12-22
**Status:** Complete and verified against official sources

---

## 13. Next Steps & Recommendations

### Immediate Actions (This Week)

1. **Update settings.json** in `private_dot_gemini/settings.json.tmpl`:
   - Add `compressionThreshold: 0.9`
   - Add `sessionRetention` policy
   - Add `codebaseInvestigatorSettings`

2. **Verify MCP Configuration**:
   - Check timeout values for each server
   - Verify trust settings (recommended: false for all external)
   - Test connection to each MCP server

3. **Create Custom Commands** (Optional):
   - `/continuation` command for session continuation
   - `/research` command for web research workflows
   - `/refactor` commands for code optimization

### Medium-term (Next 2-4 Weeks)

1. **Test Experimental Features**:
   - Enable codebaseInvestigator and test on real project
   - Evaluate enableAgents for multi-step tasks
   - Monitor RAM usage with jitContext enabled

2. **Document Configuration**:
   - Create `docs/tools/gemini-cli-optimization.md`
   - Document custom commands in `docs/commons/tools/gemini-cli/`
   - Add troubleshooting guide for MCP servers

3. **Integrate with Workspace**:
   - Link AGENTS.md to your llm-tsukuru-project configuration
   - Coordinate with Claude Desktop MCP server setup
   - Update ADR-009 (Two-layer architecture) with findings

### Long-term (Next Month)

1. **Monitor v0.22 Release**:
   - Test Gemini 3 Flash when available
   - Evaluate performance improvements
   - Update Nix package to latest stable

2. **Explore GPU Options**:
   - Consider local Gemma models for privacy-critical tasks
   - Investigate TensorRT-LLM or Ollama integration
   - Document hybrid cloud/local strategy

3. **Advanced Customization**:
   - Build custom MCP servers for your workflows
   - Create workspace-specific agent configurations
   - Integrate with CI/CD pipelines for automated analysis

---

**End of Research Report**

---

## Appendix: Quick Reference

### Configuration Checklist

- [ ] `compressionThreshold` set to `0.9`
- [ ] `sessionRetention` configured with `maxAge: "30d"`
- [ ] `maxSessionTurns` set to `200` or higher
- [ ] All MCP servers have appropriate `timeout` values
- [ ] Untrusted MCP servers have `trust: false`
- [ ] `codebaseInvestigator` enabled in experimental
- [ ] API keys loaded via systemd environment (per ADR-011)
- [ ] Custom commands created for common workflows
- [ ] `settings.json` stored in chezmoi (no real API keys)

### Useful Commands

```bash
# View current settings
/settings

# Trigger manual compression
/compress

# View token usage and cache savings
/stats

# List available commands
/help

# Resume previous session
/chat resume

# Save current context
/chat save

# Show codebase investigation report
/investigate <objective>
```

---

Report compiled by Technical Researcher
Session: enhancing_agents_config_week-52-2025
Confidence Level: **0.87 (Band C - HIGH)**
