# Node2nix Migration - Step-by-Step Guide

**Date:** 2025-11-18
**Status:** Ready to execute
**Location:** `/home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager/`

---

## ✅ Completed Prep Work

1. ✅ Created `npm-packages.json` with 4 packages:
   - @anthropic-ai/claude-code
   - @just-every/mcp-read-website-fast
   - @upstash/context7-mcp
   - firecrawl-mcp

2. ✅ Created `npm-tools.nix` module (prepared for node2nix)

3. ✅ Installed `nodePackages.node2nix` in home.packages

---

## 📋 Migration Steps (Run After Current Rebuild Completes)

### Step 1: Generate Nix Expressions

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager

# Generate node2nix expressions
node2nix -i npm-packages.json \
  -o npm-node-packages.nix \
  -c npm-default.nix \
  -e npm-node-env.nix \
  --nodejs-24

# Verify files were created
ls -la npm-*.nix
```

**Expected output:**
- `npm-node-packages.nix` (package definitions)
- `npm-default.nix` (composition)
- `npm-node-env.nix` (build infrastructure)

---

### Step 2: Uncomment npm-tools.nix

Edit `npm-tools.nix` and uncomment:
1. The `npmPackages` import (lines ~17-21)
2. The `claude-code-wrapper` definition (lines ~24-36)
3. The `home.packages` section (lines ~42-50)

**Or simply replace the entire file with the active version (provided below)**

---

### Step 3: Import npm-tools.nix in home.nix

Add to the imports section in `home.nix`:

```nix
imports = [
  ./shell.nix
  ./claude-code.nix
  ./kitty.nix
  ./vscodium.nix
  ./keepassxc.nix
  ./rclone-gdrive.nix
  ./syncthing-myspaces.nix
  ./symlinks.nix
  ./npm-tools.nix        # <-- ADD THIS LINE
];
```

---

### Step 4: Remove Old NPM Management Code from home.nix

**Remove these sections from home.nix:**

#### A. Remove Claude Code activation script (lines ~211-221)
```nix
# DELETE THIS ENTIRE BLOCK:
home.activation.install-claude-code = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  set -euo pipefail
  if command -v npm >/dev/null 2>&1; then
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    if ! npm list -g @anthropic-ai/claude-code >/dev/null 2>&1; then
      npm install -g @anthropic-ai/claude-code || true
    else
      npm update -g @anthropic-ai/claude-code || true
    fi
  fi
'';
```

#### B. Remove Cline activation script (lines ~112-125)
```nix
# DELETE THIS ENTIRE BLOCK:
home.activation.install-cline = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  set -euo pipefail
  if command -v npm >/dev/null 2>&1; then
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    for pkg in @cline/cline cline; do
      if ! npm list -g "$pkg" >/dev/null 2>&1; then
        npm install -g "$pkg" || true
      else
        npm update -g "$pkg" || true
      fi
    done
  fi
'';
```

#### C. Remove systemd services and timers

```nix
# DELETE THESE BLOCKS:
systemd.user.services.claude-code-update = { ... };
systemd.user.timers.claude-code-update = { ... };
systemd.user.services.cline-update = { ... };
systemd.user.timers.cline-update = { ... };
```

#### D. Remove Cline config file management
```nix
# DELETE THIS BLOCK:
home.file.".config/cline/config.json".text = ''
  {
    "provider": "anthropic",
    "baseUrl": "http://localhost:4000",
    "model": "claude-sonnet-4.5"
  }
'';
```

---

### Step 5: Optionally Remove claude-code.nix

Since npm-tools.nix now manages Claude Code:

```bash
# Option A: Remove the import from home.nix
# Remove line: ./claude-code.nix

# Option B: Keep it as backup (comment out in home.nix)
# Comment: # ./claude-code.nix  # Old npm wrapper, now using npm-tools.nix
```

---

### Step 6: Test Build

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager

# Check flake syntax
nix flake check

# Build (dry-run)
home-manager build --flake .#mitsio@shoshin

# If successful, apply
home-manager switch --flake .#mitsio@shoshin
```

---

### Step 7: Verify Everything Works

```bash
# Test Claude Code CLI
claude --version

# Test MCP servers
mcp-read-website-fast --version
context7-mcp --version
firecrawl-mcp --version

# Check that binaries are from Nix store
which claude
which mcp-read-website-fast
# Should show paths like: /nix/store/...
```

---

### Step 8: Clean Up Old NPM Global Packages

```bash
# Uninstall old npm global packages
npm uninstall -g @anthropic-ai/claude-code
npm uninstall -g @just-every/mcp-read-website-fast
npm uninstall -g @upstash/context7-mcp
npm uninstall -g firecrawl-mcp
npm uninstall -g cline
npm uninstall -g @cline/cline

# Verify clean
npm list -g --depth=0
# Should show empty or minimal packages
```

---

### Step 9: Update Claude Desktop MCP Config (Optional)

If using Claude Desktop with MCP servers, update paths:

**File:** `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "read-website-fast": {
      "command": "/home/mitsio/.nix-profile/bin/mcp-read-website-fast"
    },
    "context7": {
      "command": "/home/mitsio/.nix-profile/bin/context7-mcp"
    },
    "firecrawl": {
      "command": "/home/mitsio/.nix-profile/bin/firecrawl-mcp"
    }
  }
}
```

Or make this declarative via home-manager (advanced).

---

### Step 10: Commit Changes to Git

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager

git add .
git commit -m "feat: migrate npm packages to node2nix for reproducibility

- Add npm-packages.json with 4 packages
- Generate node2nix expressions
- Create npm-tools.nix module
- Remove activation scripts and systemd services
- Full declarative npm package management

Packages migrated:
- @anthropic-ai/claude-code
- @just-every/mcp-read-website-fast
- @upstash/context7-mcp
- firecrawl-mcp

Benefits:
- Fully reproducible builds
- Version locking
- Rollback support
- No manual npm installs
"
```

---

## 🎯 Benefits After Migration

### Before (Imperative)
❌ Activation scripts run on every rebuild
❌ No version locking
❌ Manual npm updates required
❌ Not fully reproducible
❌ Hard to rollback

### After (Declarative)
✅ Packages built from locked expressions
✅ Versions locked in Nix store
✅ Automatic with home-manager rebuild
✅ Fully reproducible
✅ Easy rollback via generations

---

## 🔍 Troubleshooting

### node2nix command not found
```bash
# Ensure node2nix is installed
home-manager packages | grep node2nix

# If not, rebuild with current config first
home-manager switch --flake .#mitsio@shoshin
```

### Build errors after node2nix
```bash
# Check generated file syntax
nix-instantiate --parse npm-default.nix

# Try regenerating with --development flag
node2nix -i npm-packages.json --development
```

### MCP servers don't work
```bash
# Check binary paths
ls -la ~/.nix-profile/bin/mcp-*
ls -la ~/.nix-profile/bin/context7-mcp

# Restart Claude Desktop
pkill -f claude
# Then relaunch
```

---

## 📝 Files Modified

- `npm-packages.json` (created)
- `npm-tools.nix` (created)
- `npm-node-packages.nix` (generated)
- `npm-default.nix` (generated)
- `npm-node-env.nix` (generated)
- `home.nix` (imports + cleanup)
- `claude-code.nix` (optional removal)

---

**Ready to execute!** Follow steps 1-10 in order after current rebuild completes.

**Estimated time:** 10-15 minutes
**Complexity:** Medium (mostly automated)
**Rollback:** Easy via `home-manager switch --rollback`
