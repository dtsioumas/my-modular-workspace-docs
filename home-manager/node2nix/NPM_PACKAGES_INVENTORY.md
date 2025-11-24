# NPM Global Packages Inventory

**Date:** 2025-11-17
**Project:** my-modular-workspace-decoupling-home
**Purpose:** Document all globally installed npm packages and their repositories

---

## 📦 Currently Installed Packages

### From `npm list -g --depth=0`:

```
/home/mitsio/.npm-global/lib
├── @anthropic-ai/claude-code@2.0.42
├── @just-every/mcp-read-website-fast@0.1.20
├── @upstash/context7-mcp@1.0.26
├── cline@1.0.4 (REMOVING - not used)
└── firecrawl-mcp@3.6.0
```

### Binaries in `~/.npm-global/bin/`:
- `claude` - Claude Code CLI
- `cline` - ~~Cline CLI~~ (REMOVING - not used)
- `cline-host` - ~~Cline host~~ (REMOVING - not used)
- `context7-mcp` - Context7 MCP server
- `firecrawl-mcp` - Firecrawl MCP server
- `mcp-read-website-fast` - Fast website reading MCP server

---

## 🔗 Package Repository Information

### 1. @anthropic-ai/claude-code

**NPM:** https://www.npmjs.com/package/@anthropic-ai/claude-code
**GitHub:** https://github.com/anthropics/claude-code
**Version:** 2.0.42
**Purpose:** Claude Code CLI - AI-powered coding assistant
**Install:** `npm install -g @anthropic-ai/claude-code`

**Features:**
- AI-powered code generation
- Context-aware suggestions
- Integration with Anthropic's Claude models

---

### 2. @just-every/mcp-read-website-fast

**NPM:** https://www.npmjs.com/package/@just-every/mcp-read-website-fast
**GitHub:** https://github.com/just-every/mcp-read-website-fast
**Repository:** git+https://github.com/just-every/mcp-read-website-fast.git
**Version:** 0.1.20
**Purpose:** Fast website content reading MCP server
**Install:** `npm install -g @just-every/mcp-read-website-fast`

**Features:**
- Fast website scraping
- Model Context Protocol (MCP) integration
- Markdown conversion
- Efficient content extraction

---

### 3. @upstash/context7-mcp

**NPM:** https://www.npmjs.com/package/@upstash/context7-mcp
**GitHub:** https://github.com/upstash/context7
**Repository:** git+https://github.com/upstash/context7.git
**Version:** 1.0.26
**Purpose:** Context7 documentation MCP server by Upstash
**Install:** `npm install -g @upstash/context7-mcp`

**Features:**
- Library documentation access
- Up-to-date API docs
- Context7 integration for Claude
- Documentation search and retrieval

---

### 4. firecrawl-mcp

**NPM:** https://www.npmjs.com/package/firecrawl-mcp
**GitHub:** https://github.com/firecrawl/firecrawl-mcp-server
**Repository:** git+https://github.com/firecrawl/firecrawl-mcp-server.git
**Version:** 3.6.0
**Purpose:** Firecrawl MCP server for web scraping
**Install:** `npm install -g firecrawl-mcp`

**Features:**
- Advanced web scraping
- Site mapping and crawling
- Content extraction
- Search capabilities
- MCP integration

---

### 5. ~~cline@1.0.4~~ (REMOVED)

**NPM:** https://www.npmjs.com/package/cline
**GitHub:** https://github.com/cline/cline
**Status:** ❌ Removing - not actively used
**Reason:** User doesn't use cline or cline-host binaries

---

## 📋 Migration to node2nix

### Updated npm-packages.json

**File:** `~/.config/my-home-manager-flake/npm-packages.json`

```json
[
  "@anthropic-ai/claude-code",
  "@just-every/mcp-read-website-fast",
  "@upstash/context7-mcp",
  "firecrawl-mcp"
]
```

### Package Categories

**AI/Coding Tools:**
- ✅ @anthropic-ai/claude-code

**MCP Servers:**
- ✅ @just-every/mcp-read-website-fast (web reading)
- ✅ @upstash/context7-mcp (documentation)
- ✅ firecrawl-mcp (web scraping/crawling)

**Removed:**
- ❌ cline (not used)

---

## 🔧 Next Steps

### 1. Generate Nix Expressions
```bash
cd ~/.config/my-home-manager-flake
node2nix -i npm-packages.json \
  -o npm-node-packages.nix \
  -c npm-default.nix \
  -e npm-node-env.nix
```

### 2. Create Wrapper Scripts

**claude-code wrapper** (with API key from Bitwarden):
```nix
claude-code = pkgs.writeShellScriptBin "claude-code" ''
  export ANTHROPIC_API_KEY="$(bw get password anthropic-api-key 2>/dev/null || echo "")"
  export ANTHROPIC_MODEL="claude-sonnet-4.5"
  exec ${npmPackages."@anthropic-ai/claude-code"}/bin/claude-code "$@"
'';
```

**MCP servers** (direct binaries):
```nix
home.packages = [
  npmPackages."@just-every/mcp-read-website-fast"
  npmPackages."@upstash/context7-mcp"
  npmPackages."firecrawl-mcp"
];
```

### 3. Update Claude Desktop MCP Config

**File:** `~/.config/Claude/claude_desktop_config.json`

MCP servers should point to Nix store paths:
```json
{
  "mcpServers": {
    "read-website-fast": {
      "command": "/nix/store/.../bin/mcp-read-website-fast"
    },
    "context7": {
      "command": "/nix/store/.../bin/context7-mcp"
    },
    "firecrawl": {
      "command": "/nix/store/.../bin/firecrawl-mcp"
    }
  }
}
```

Or use home-manager to generate this file declaratively!

---

## 📊 Benefits of node2nix Migration

### Before (npm global)
```bash
npm install -g @anthropic-ai/claude-code
npm install -g @just-every/mcp-read-website-fast
npm install -g @upstash/context7-mcp
npm install -g firecrawl-mcp
```

**Issues:**
- ❌ Not reproducible (registry-dependent)
- ❌ No version pinning
- ❌ Manual updates required
- ❌ No rollback support

### After (node2nix)
```nix
home.packages = with pkgs; [
  claude-code-wrapper
  npmPackages."@just-every/mcp-read-website-fast"
  npmPackages."@upstash/context7-mcp"
  npmPackages."firecrawl-mcp"
];
```

**Benefits:**
- ✅ Fully reproducible
- ✅ Version locked in Nix expressions
- ✅ Automatic updates via home-manager rebuild
- ✅ Full rollback support (previous generations)
- ✅ Commit expressions to git
- ✅ Same packages on all machines

---

## 🗑️ Cleanup Old Packages

After node2nix migration succeeds:

```bash
# Remove old npm global packages
npm uninstall -g @anthropic-ai/claude-code
npm uninstall -g @just-every/mcp-read-website-fast
npm uninstall -g @upstash/context7-mcp
npm uninstall -g firecrawl-mcp
npm uninstall -g cline  # Already decided to remove

# Verify clean
npm list -g --depth=0
```

---

## 📝 Configuration Files to Update

### 1. home.nix
- Remove: `home.activation.install-claude-code`
- Remove: `home.activation.install-cline`
- Remove: `systemd.user.services.claude-code-update`
- Remove: `systemd.user.services.cline-update`
- Remove: `systemd.user.timers.claude-code-update`
- Remove: `systemd.user.timers.cline-update`
- Add: Import npm-packages.nix
- Add: Wrapper scripts for binaries

### 2. Claude Desktop Config
- Update MCP server paths to Nix store
- Or make declarative via home-manager

### 3. .gitignore (if needed)
```
# Exclude generated npm artifacts
npm-node-packages.nix
npm-default.nix
npm-node-env.nix
```

**OR** commit them for reproducibility (recommended)!

---

## 🔍 Verification Checklist

After migration:

- [ ] `node2nix --version` works
- [ ] Generated files exist (npm-node-packages.nix, etc.)
- [ ] `home-manager switch` succeeds
- [ ] `claude-code --version` works
- [ ] `mcp-read-website-fast --version` works
- [ ] `context7-mcp --version` works
- [ ] `firecrawl-mcp --version` works
- [ ] Claude Desktop MCP servers work
- [ ] Old npm global packages removed
- [ ] All changes committed to git

---

**Created:** 2025-11-17
**Author:** Claude Code + Mitsio
**Status:** Ready for node2nix generation
