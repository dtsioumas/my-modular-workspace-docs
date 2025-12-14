# Installation Plan: Gemini CLI with MCP Integration (V2 - CORRECTED)

**Date:** 2025-12-11 (Updated after critical review)
**Last Updated:** 2025-12-14 (Authentication method corrected)
**Author:** Mitsio
**Status:** ✅ **READY TO EXECUTE** - All prerequisites met
**Research:** `docs/researches/2025-12-11_GEMINI_CLI_MCP_INTEGRATION_RESEARCH.md`
**Critical Review:** `docs/researches/2025-12-11_GEMINI_CLI_PLAN_CRITICAL_REVIEW.md`
**Plan Confidence:** 0.90 (Band C - HIGH)
**Estimated Time:** 2-3 hours

---

## ✅ IMPLEMENTATION STATUS

**PREREQUISITES MET:**
- ✅ ADR-010 complete (all MCP servers packaged)
- ✅ llm-tsukuru-project/llm-core structure ready for AGENTS.md symlink
- ✅ All MCP wrappers available

**VERIFIED:**
- ✅ All MCP servers are packaged and have wrappers in `home-manager/mcp-servers/`
- ✅ MCP wrappers follow naming pattern: `mcp-<name>` (e.g., `mcp-context7`, `mcp-firecrawl`)
- ✅ llm-core path exists: `~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/global-config.md`

**AUTHENTICATION METHOD:**
- ✅ Using API Key (GEMINI_API_KEY) - NOT Google Cloud subscription
- ✅ API key stored in KeePassXC (per ADR-011)

---

## Executive Summary

This **corrected** plan addresses all critical issues identified in the ultrathink review:

### 🔴 Critical Fixes Applied (V3 - 2025-12-14)

1. ✅ **ADR-010 Compliance** - Uses Nix-packaged MCP servers with wrappers (NOT runtime installers)
2. ✅ **Correct Authentication** - API Key method (GEMINI_API_KEY) for personal use
3. ✅ **KeePassXC Integration** - Extends existing `load-keepassxc-secrets.service`
4. ✅ **AGENTS.md Symlink** - Uses llm-tsukuru-project/llm-core structure (like CLAUDE.md)
5. ✅ **Vault Unlock Logic** - Explicit dependency + retry + notifications
6. ✅ **No Manual Edits** - All configs managed declaratively
7. ✅ **Verified llm-core Path** - Actual path confirmed and updated in plan

---

## Available MCP Servers (All Installed)

**From flake (from-flake.nix):**
- `mcp-context7` - Library documentation
- `mcp-sequential-thinking` - Deep reasoning
- `mcp-fetch` - Web content fetching
- `mcp-time` - Timezone operations (Europe/Athens)

**From npm-custom.nix:**
- `mcp-firecrawl` - Web scraping (requires API key)
- `mcp-read-website-fast` - Fast web reading
- `mcp-brave-search` - Web search (requires API key)
- `mcp-exa` - AI-powered search (requires API key)

**From python-custom.nix:**
- `mcp-claude-continuity` - Session persistence
- `mcp-ast-grep` - Structural code search

**From rust-custom.nix:**
- `mcp-ck` - Semantic code search with MCP server mode

---

## Prerequisites

Before starting, ensure:

- [x] Home-manager is set up and working (`home-manager switch` succeeds)
- [x] NixOS with nixpkgs-unstable input in flake (per ADR-001)
- [x] **All MCP servers installed** via ADR-010 (Phase 1-5 complete)
- [x] MCP wrappers available in PATH (`which mcp-context7 mcp-firecrawl mcp-exa`)
- [x] KeePassXC vault accessible at `~/MyVault/`
- [x] llm-tsukuru-project/llm-core structure ready for AGENTS.md symlink
- [ ] **Gemini API Key** obtained from https://aistudio.google.com/apikey

**Verify Prerequisites:**

```bash
# Check home-manager
home-manager --version

# Check MCP wrappers exist
which mcp-context7 mcp-fetch mcp-time mcp-firecrawl mcp-exa
# Should return paths to all wrappers

# Check KeePassXC
secret-tool search service keepassxc

# Check llm-core structure
ls -la ~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/global-config.md
# Should exist

# Note: Gemini API key will be added to KeePassXC in Phase 3
```

---

## Phase 1: Home-Manager Module Creation (30 minutes)

### 1.1 Create Gemini CLI Module

**File:** `home-manager/gemini-cli.nix`

```nix
{ config, pkgs, lib, ... }:

{
  #############################################################################
  # Gemini CLI - Google's AI Agent for Terminal
  #############################################################################
  # Follows ADR-009: Two-layer architecture (install via HM, config via settings)
  # Follows ADR-010: MCP servers via Nix packages (NO runtime installers)
  # Follows ADR-011: Secrets from KeePassXC via systemd

  programs.gemini-cli = {
    enable = true;
    package = pkgs.gemini-cli;  # From nixpkgs-unstable

    # Default model (can be overridden with --model flag)
    defaultModel = "gemini-2.5-pro";

    # Main configuration
    settings = {
      #######################################################################
      # General Settings
      #######################################################################
      general = {
        vimMode = false;  # Set to true if you prefer vim keybindings
        preferredEditor = "codium";  # Use VSCodium as default editor
        disableAutoUpdate = true;  # Nix handles updates
        sessionRetention = {
          enabled = true;
          maxAge = "30d";
          maxCount = 100;
        };
      };

      #######################################################################
      # UI Settings
      #######################################################################
      ui = {
        theme = "GitHub";  # Or "dark", "light", etc.
        hideBanner = false;
        hideTips = false;
        showLineNumbers = true;
        useFullWidth = true;
      };

      #######################################################################
      # Model Configuration
      #######################################################################
      model = {
        name = "gemini-2.5-pro";
        maxSessionTurns = -1;  # Unlimited (uses auto-compression)
        compressionThreshold = 0.5;  # Compress context at 50% usage
      };

      #######################################################################
      # Privacy & Telemetry
      #######################################################################
      privacy = {
        usageStatisticsEnabled = false;  # Disable telemetry
      };

      #######################################################################
      # Tools Configuration
      #######################################################################
      tools = {
        # Sandboxing (optional - disable for now, enable later if needed)
        sandbox = false;  # Set to "docker" or "podman" for isolation

        # Auto-accept safe tools (read-only operations)
        autoAccept = false;  # Be conservative, ask for confirmation

        # Shell configuration
        shell = {
          enableInteractiveShell = true;
          showColor = true;
          pager = "cat";
        };

        # Use ripgrep for faster search
        useRipgrep = true;
      };

      #######################################################################
      # Context/Memory Configuration
      #######################################################################
      context = {
        # Will use AGENTS.md from llm-tsukuru-project/llm-core
        fileName = "AGENTS.md";
        fileFiltering = {
          respectGitIgnore = true;
          respectGeminiIgnore = true;
        };
      };

      #######################################################################
      # MCP Servers Configuration
      #######################################################################
      # ✅ CORRECTED: Uses Nix-packaged MCP servers with wrappers
      # ✅ NO runtime installers (npx, uvx) - violates ADR-010
      # ✅ All wrappers from home-manager/mcp-servers/
      mcpServers = {

        #####################################################################
        # From flake (from-flake.nix)
        #####################################################################

        # Context7 - Library documentation lookup
        # Wrapper: mcp-context7
        context7 = {
          command = "mcp-context7";
          env = {
            CONTEXT7_API_KEY = "$CONTEXT7_API_KEY";
          };
          timeout = 15000;
          trust = false;
          description = "Library documentation and code examples";
        };

        # Sequential Thinking - Deep reasoning
        # Wrapper: mcp-sequential-thinking
        sequential-thinking = {
          command = "mcp-sequential-thinking";
          timeout = 30000;
          trust = false;
          description = "Deep reasoning and planning";
        };

        # Fetch - Web content fetching
        # Wrapper: mcp-fetch
        fetch = {
          command = "mcp-fetch";
          timeout = 10000;
          trust = true;  # Safe, read-only
          description = "Fetch web content";
        };

        # Time - Timezone operations (Europe/Athens)
        # Wrapper: mcp-time
        time = {
          command = "mcp-time";
          timeout = 5000;
          trust = true;  # Safe, read-only
          description = "Time and timezone utilities";
        };

        #####################################################################
        # From npm-custom.nix
        #####################################################################

        # Firecrawl - Web scraping and crawling
        # Wrapper: mcp-firecrawl
        firecrawl = {
          command = "mcp-firecrawl";
          env = {
            FIRECRAWL_API_KEY = "$FIRECRAWL_API_KEY";
          };
          timeout = 30000;
          trust = false;
          description = "Web scraping and content extraction";
        };

        # Read Website Fast - Fast web content reading
        # Wrapper: mcp-read-website-fast
        read-website-fast = {
          command = "mcp-read-website-fast";
          timeout = 10000;
          trust = true;  # Safe, read-only
          description = "Fast web content reading";
        };

        # Brave Search - Web search
        # Wrapper: mcp-brave-search
        brave-search = {
          command = "mcp-brave-search";
          env = {
            BRAVE_API_KEY = "$BRAVE_API_KEY";
          };
          timeout = 15000;
          trust = false;
          description = "Brave web search";
        };

        # Exa - AI-powered search
        # Wrapper: mcp-exa
        exa = {
          command = "mcp-exa";
          env = {
            EXA_API_KEY = "$EXA_API_KEY";
          };
          timeout = 15000;
          trust = false;
          description = "AI-powered web search";
        };

        #####################################################################
        # From python-custom.nix
        #####################################################################

        # Claude Thread Continuity - Session persistence
        # Wrapper: mcp-claude-continuity
        claude-continuity = {
          command = "mcp-claude-continuity";
          timeout = 10000;
          trust = false;
          description = "Session persistence and continuity";
        };

        # ast-grep - Structural code search
        # Wrapper: mcp-ast-grep
        ast-grep = {
          command = "mcp-ast-grep";
          timeout = 15000;
          trust = false;
          description = "Structural code search and analysis";
        };

        #####################################################################
        # From rust-custom.nix
        #####################################################################

        # ck-search - Semantic code search with MCP mode
        # Wrapper: mcp-ck
        ck = {
          command = "mcp-ck";
          args = [ "--serve" ];  # MCP server mode
          timeout = 15000;
          trust = false;
          description = "Semantic code search";
        };
      };

      #######################################################################
      # Advanced Settings
      #######################################################################
      advanced = {
        excludedEnvVars = ["DEBUG" "DEBUG_MODE" "NODE_ENV"];
      };
    };

    #########################################################################
    # Context Files (AGENTS.md)
    #########################################################################
    # NOTE: AGENTS.md will be symlinked from llm-tsukuru-project/llm-core
    # Similar to CLAUDE.md pattern
    # This is being prepared in another session
    # For now, we create a placeholder that will be replaced by symlink
  };

  #############################################################################
  # AGENTS.md Symlink (like CLAUDE.md)
  #############################################################################
  # Symlink to llm-core global config (shared with Claude Code and Codex)
  home.file.".gemini/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/global-config.md";
}
```

---

## Phase 2: Extend Secrets Service (20 minutes)

### 2.1 Extend load-keepassxc-secrets.service

**File:** Find where `load-keepassxc-secrets.service` is defined, then add:

```nix
# Extend existing service to load MCP API keys for Gemini CLI
systemd.user.services.load-keepassxc-secrets = {
  Unit = {
    Description = "Load secrets from KeePassXC vault";
    After = [ "graphical-session.target" ];
    Wants = [ "graphical-session.target" ];

    # ✅ FIX: Add explicit KeePassXC dependency
    Requires = [ "keepassxc.service" ];  # Hard dependency (if service exists)

    # High priority - ensure vault is unlocked
    ConditionPathExists = "%h/MyVault/";
  };

  Service = {
    Type = "oneshot";
    RemainAfterExit = true;

    # ✅ FIX: Add retry logic
    Restart = "on-failure";
    RestartSec = "10s";
    StartLimitBurst = 5;
    StartLimitIntervalSec = "2min";

    ExecStart = pkgs.writeShellScript "load-keepassxc-secrets" ''
      set -euo pipefail

      # ========================================
      # ✅ FIX: Wait for KeePassXC vault unlock
      # ========================================
      echo "Waiting for KeePassXC vault to be unlocked..."
      for i in {1..60}; do
        # Try a test lookup to check if vault is unlocked
        if ${pkgs.libsecret}/bin/secret-tool lookup \
            service keepassxc key test 2>/dev/null; then
          echo "KeePassXC vault is unlocked"
          break
        fi

        if [ $i -eq 60 ]; then
          # ✅ FIX: User notification if vault locked
          ${pkgs.libnotify}/bin/notify-send \
            --urgency=critical \
            "KeePassXC Required" \
            "Please unlock KeePassXC vault to load secrets for Gemini CLI and MCP servers"
          exit 1
        fi

        sleep 1
      done

      # ========================================
      # Existing secrets loading
      # ========================================
      # ... (keep existing code) ...

      # ========================================
      # ✅ NEW: Gemini API Key
      # ========================================

      # Gemini API Key
      GEMINI_API_KEY=$(${pkgs.libsecret}/bin/secret-tool lookup \
        service gemini key apikey 2>/dev/null || true)
      if [ -n "$GEMINI_API_KEY" ]; then
        ${pkgs.systemd}/bin/systemctl --user set-environment \
          GEMINI_API_KEY="$GEMINI_API_KEY"
        echo "Gemini API key loaded"
      fi

      # ========================================
      # ✅ NEW: MCP Server API Keys for Gemini CLI
      # ========================================

      # Context7 API Key
      CONTEXT7_API_KEY=$(${pkgs.libsecret}/bin/secret-tool lookup \
        service context7 key apikey 2>/dev/null || true)
      if [ -n "$CONTEXT7_API_KEY" ]; then
        ${pkgs.systemd}/bin/systemctl --user set-environment \
          CONTEXT7_API_KEY="$CONTEXT7_API_KEY"
        echo "Context7 API key loaded"
      fi

      # Firecrawl API Key
      FIRECRAWL_API_KEY=$(${pkgs.libsecret}/bin/secret-tool lookup \
        service firecrawl key apikey 2>/dev/null || true)
      if [ -n "$FIRECRAWL_API_KEY" ]; then
        ${pkgs.systemd}/bin/systemctl --user set-environment \
          FIRECRAWL_API_KEY="$FIRECRAWL_API_KEY"
        echo "Firecrawl API key loaded"
      fi

      # Exa API Key
      EXA_API_KEY=$(${pkgs.libsecret}/bin/secret-tool lookup \
        service exa key apikey 2>/dev/null || true)
      if [ -n "$EXA_API_KEY" ]; then
        ${pkgs.systemd}/bin/systemctl --user set-environment \
          EXA_API_KEY="$EXA_API_KEY"
        echo "Exa API key loaded"
      fi

      # Brave Search API Key (optional)
      BRAVE_API_KEY=$(${pkgs.libsecret}/bin/secret-tool lookup \
        service brave key apikey 2>/dev/null || true)
      if [ -n "$BRAVE_API_KEY" ]; then
        ${pkgs.systemd}/bin/systemctl --user set-environment \
          BRAVE_API_KEY="$BRAVE_API_KEY"
        echo "Brave API key loaded"
      fi

      # Success notification
      ${pkgs.libnotify}/bin/notify-send \
        "Secrets Loaded" \
        "MCP server API keys loaded successfully for Gemini CLI"
    '';
  };

  Install = {
    WantedBy = [ "default.target" ];
  };
};
```

### 2.2 Bash Integration

```nix
# Ensure environment variables are available in shell
programs.bash.initExtra = lib.mkAfter ''
  # Load Gemini and MCP secrets from systemd environment if not already loaded
  if [ -z "$GEMINI_API_KEY" ]; then
    eval "$(systemctl --user show-environment | grep '^GEMINI_API_KEY=')" 2>/dev/null || true
    eval "$(systemctl --user show-environment | grep '^CONTEXT7_API_KEY=')" 2>/dev/null || true
    eval "$(systemctl --user show-environment | grep '^FIRECRAWL_API_KEY=')" 2>/dev/null || true
    eval "$(systemctl --user show-environment | grep '^EXA_API_KEY=')" 2>/dev/null || true
    eval "$(systemctl --user show-environment | grep '^BRAVE_API_KEY=')" 2>/dev/null || true
  fi
'';
```

### 2.3 Import Modules in home.nix

```nix
{
  imports = [
    # ... existing imports ...
    ./gemini-cli.nix
    # Note: secrets service extension is in existing secrets module
  ];
}
```

---

## Phase 3: API Keys Setup in KeePassXC (15 minutes)

### 3.1 Gemini API Key

**Get your API key:**
1. Visit https://aistudio.google.com/apikey
2. Sign in with your Google account
3. Create a new API key
4. Copy the key

**Store in KeePassXC:**

```bash
# Store Gemini API Key
secret-tool store --label="Gemini API Key" service gemini key apikey
# Paste your API key when prompted

# Verify stored
secret-tool lookup service gemini key apikey
# Should display your key
```

### 3.2 MCP Server API Keys

Store API keys for MCP servers that require them:

```bash
# Context7 (if you have subscription)
secret-tool store --label="Context7 API Key" service context7 key apikey

# Firecrawl (if you have subscription)
secret-tool store --label="Firecrawl API Key" service firecrawl key apikey

# Exa (if you have subscription)
secret-tool store --label="Exa API Key" service exa key apikey

# Brave Search (optional)
secret-tool store --label="Brave Search API Key" service brave key apikey

# Verify all stored
secret-tool lookup service context7 key apikey
secret-tool lookup service firecrawl key apikey
secret-tool lookup service exa key apikey
```

---

## Phase 4: Home-Manager Switch & Verification (15 minutes)

### 4.1 Build and Switch

```bash
# Navigate to home-manager directory
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Build (test first)
home-manager build --flake .#mitsio@shoshin

# If build succeeds, switch
home-manager switch --flake .#mitsio@shoshin -b backup
```

### 4.2 Verify Installation

```bash
# Check gemini CLI is installed
which gemini
gemini --version

# Check settings file created
ls -la ~/.gemini/settings.json
cat ~/.gemini/settings.json | jq .mcpServers

# Check GEMINI_API_KEY loaded
echo $GEMINI_API_KEY
# Should display your API key

# Check MCP API keys loaded
systemctl --user status load-keepassxc-secrets.service
systemctl --user show-environment | grep API_KEY

# Check all MCP wrappers available
which mcp-context7 mcp-fetch mcp-firecrawl mcp-exa

# Check AGENTS.md symlink
ls -la ~/.gemini/AGENTS.md
# Should be symlink to llm-core/config/global-config.md
```

### 4.3 Test Basic Functionality

```bash
# Test with a simple prompt
gemini --prompt "What is the capital of Greece?"

# Expected: Response from Gemini (using Google Cloud subscription)

# Test interactive mode
gemini

# Inside CLI, check MCP servers
/mcp

# Expected: All configured MCP servers listed
```

---

## Phase 5: MCP Server Testing (30 minutes)

### 5.1 Verify MCP Servers Discovered

```bash
gemini

# Inside Gemini CLI
/mcp

# Expected output should show all servers:
# - context7
# - sequential-thinking
# - fetch
# - time
# - firecrawl
# - read-website-fast
# - brave-search
# - exa
# - claude-continuity
# - ast-grep
# - ck
```

### 5.2 Test MCP Servers (with pacing for rate limits)

**Test 1: time (no API)**
```
> What time is it in Athens right now?
```

**Test 2: fetch (no API)**
```
> Fetch content from https://nixos.org
```

*Wait 30 seconds (rate limit safety)*

**Test 3: context7 (has API key)**
```
> Get documentation for React useState hook
```

*Wait 30 seconds*

**Test 4: firecrawl (has API key)**
```
> Scrape https://github.com/google-gemini/gemini-cli homepage
```

*Wait 30 seconds*

**Test 5: exa (has API key)**
```
> Search the web for "NixOS home-manager best practices 2025"
```

---

## Phase 6: AGENTS.md Symlink Setup (Postponed)

**⏸️ POSTPONED** - Waiting for llm-tsukuru-project/llm-core structure from other session

When ready, update `home-manager/gemini-cli.nix`:

```nix
# AGENTS.md Symlink (similar to CLAUDE.md)
home.file.".gemini/AGENTS.md".source =
  config.lib.file.mkOutOfStoreSymlink
    "/path/to/llm-tsukuru-project/llm-core/AGENTS.md";
```

---

## Phase 7: Documentation & Cleanup (20 minutes)

### 7.1 Update Master TODO

Add to `docs/TODO.md`:

```markdown
### Gemini CLI Installation ⏸️ POSTPONED

**Status:** ⏸️ POSTPONED until ADR-010 Phase 2-4 complete
**Plan:** `docs/plans/PLAN_GEMINI_CLI_INSTALLATION_V2_CORRECTED.md`

**Completed:**
- [x] Research Gemini CLI capabilities
- [x] Create corrected installation plan (V2)
- [x] Address all critical issues from ultrathink review

**Pending:**
- [ ] ADR-010 Phase 2-4 completion (firecrawl, exa assumed complete)
- [ ] llm-tsukuru-project/llm-core AGENTS.md structure
- [ ] Execute installation plan
```

### 7.2 Commit Plan Updates

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/docs

git add plans/PLAN_GEMINI_CLI_INSTALLATION_V2_CORRECTED.md \
        researches/2025-12-11_GEMINI_CLI_PLAN_CRITICAL_REVIEW.md \
        TODO.md

git commit -m "docs(gemini-cli): Add corrected installation plan (V2)

- Fixed ADR-010 violation (use Nix MCP packages, not runtime installers)
- Fixed authentication (Google Cloud subscription, not API key)
- Fixed secrets service (extend load-keepassxc-secrets)
- Fixed KeePassXC dependency (explicit + retry + notification)
- Fixed AGENTS.md approach (symlink from llm-core, like CLAUDE.md)
- Marked as POSTPONED until ADR-010 complete

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Success Criteria (When Unpostponed)

### Prerequisites Met ✅
- [x] ADR-010 Phase 2-4 complete (all MCP servers packaged)
- [x] llm-core AGENTS.md structure ready
- [ ] All MCP wrappers available (`which mcp-*`)

### Phase 1 ✅
- [ ] Home-manager module created (`gemini-cli.nix`)
- [ ] All MCP servers configured with wrappers (NO npx/uvx)
- [ ] Module imported in `home.nix`

### Phase 2 ✅
- [ ] `load-keepassxc-secrets.service` extended
- [ ] KeePassXC dependency added (explicit + retry)
- [ ] Vault unlock notification working

### Phase 3 ✅
- [ ] Google Cloud authenticated (subscription)
- [ ] MCP API keys stored in KeePassXC
- [ ] API keys loaded via systemd service

### Phase 4 ✅
- [ ] `home-manager switch` succeeds
- [ ] `gemini --version` works
- [ ] `~/.gemini/settings.json` exists
- [ ] All MCP env vars set
- [ ] `load-keepassxc-secrets.service` active

### Phase 5 ✅
- [ ] `/mcp` shows all 11 configured servers
- [ ] At least 5 MCP servers tested successfully
- [ ] No ADR-010 violations in config

### Phase 6 ✅
- [ ] AGENTS.md symlinked from llm-core
- [ ] `/memory show` displays AGENTS.md content

### Phase 7 ✅
- [ ] `docs/TODO.md` updated
- [ ] All changes committed to git

---

## Rollback Procedure (Complete)

```bash
# 1. Remove from home-manager
# Comment out in home.nix:
# ./gemini-cli.nix

# 2. Rebuild
home-manager switch --flake .#mitsio@shoshin -b backup

# 3. Clean up secrets (optional)
secret-tool clear service context7 key apikey
secret-tool clear service firecrawl key apikey
secret-tool clear service exa key apikey
secret-tool clear service brave key apikey

# 4. Clean up environment
systemctl --user unset-environment CONTEXT7_API_KEY
systemctl --user unset-environment FIRECRAWL_API_KEY
systemctl --user unset-environment EXA_API_KEY
systemctl --user unset-environment BRAVE_API_KEY

# 5. Remove config directory (optional)
rm -rf ~/.gemini/

# 6. Verify cleanup
which gemini  # Should return nothing
echo $CONTEXT7_API_KEY  # Should be empty
systemctl --user status load-keepassxc-secrets.service  # Should succeed
```

---

## Key Differences from V1 (Original Plan)

| Aspect | V1 (WRONG) | V2 (CORRECTED) |
|--------|------------|----------------|
| **MCP Servers** | ❌ Runtime installers (`npx -y`, `uvx`) | ✅ Nix wrappers (`mcp-context7`, etc.) |
| **Authentication** | ❌ GEMINI_API_KEY env var | ✅ Google Cloud subscription (gcloud) |
| **Secrets Service** | ❌ New service | ✅ Extend existing `load-keepassxc-secrets` |
| **KeePassXC Dependency** | ❌ Soft dependency | ✅ Explicit + retry + notification |
| **Context File** | ❌ Create GEMINI.md | ✅ Symlink AGENTS.md from llm-core |
| **Config Management** | ❌ Manual CLAUDE.md edit | ✅ Declarative (home-manager/chezmoi) |
| **ADR-010 Compliance** | ❌ VIOLATION | ✅ COMPLIANT |

---

**Plan Created:** 2025-12-11T05:56:41+02:00 (Europe/Athens)
**Plan Corrected:** 2025-12-11T06:15:00+02:00 (Europe/Athens)
**Status:** ⏸️ POSTPONED until ADR-010 complete
**Confidence:** 0.92 (Band C - Safe to execute when unpostponed)
