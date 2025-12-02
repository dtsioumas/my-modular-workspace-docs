# Node2nix Integration Guide

**Last Updated:** 2025-11-29
**Sources Merged:** NODE2NIX_INTEGRATION.md, NPM_PACKAGES_INVENTORY.md, NODE2NIX_MIGRATION_PLAN.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Current NPM Packages](#current-npm-packages)
- [Installation & Usage](#installation--usage)
- [Migration Steps](#migration-steps)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

Node2nix converts npm global installs to declarative Nix expressions for reproducible package management.

### Why node2nix?

**Before (Imperative npm):**
- Not reproducible - depends on npm registry state
- No version pinning
- Activation scripts run on every rebuild
- Harder to rollback

**After (Declarative node2nix):**
- Fully reproducible - exact versions locked
- Fast rebuilds - expressions cached
- Rollback support via generations
- Version controlled in git

---

## Current NPM Packages

### Active Packages

| Package | Version | Purpose |
|---------|---------|---------|
| @anthropic-ai/claude-code | 2.0.42 | Claude Code CLI |
| @just-every/mcp-read-website-fast | 0.1.20 | Web reading MCP |
| @upstash/context7-mcp | 1.0.26 | Documentation MCP |
| firecrawl-mcp | 3.6.0 | Web scraping MCP |

### npm-packages.json

```json
[
  "@anthropic-ai/claude-code",
  "@just-every/mcp-read-website-fast",
  "@upstash/context7-mcp",
  "firecrawl-mcp"
]
```

---

## Installation & Usage

### Step 1: Install node2nix

```nix
home.packages = with pkgs; [
  nodePackages.node2nix
];
```

### Step 2: Generate Nix Expressions

```bash
cd ~/.config/my-home-manager-flake

node2nix -i npm-packages.json \
  -o npm-node-packages.nix \
  -c npm-default.nix \
  -e npm-node-env.nix \
  --nodejs-24
```

**Generated files:**
- `npm-node-packages.nix` - Package definitions
- `npm-default.nix` - Composition expression
- `npm-node-env.nix` - Build logic

### Step 3: Create Wrapper

```nix
# npm-packages.nix
{ pkgs ? import <nixpkgs> {} }:

let
  nodePackages = import ./npm-default.nix {
    inherit pkgs;
    inherit (pkgs) system;
  };
in
nodePackages
```

### Step 4: Import in home.nix

```nix
let
  npmPackages = import ./npm-packages.nix { inherit pkgs; };

  claude-code = pkgs.writeShellScriptBin "claude-code" ''
    export ANTHROPIC_API_KEY="$(bw get password anthropic-api-key 2>/dev/null || echo "")"
    exec ${npmPackages."@anthropic-ai/claude-code"}/bin/claude-code "$@"
  '';
in
{
  home.packages = [
    claude-code
    npmPackages."@just-every/mcp-read-website-fast"
    npmPackages."@upstash/context7-mcp"
    npmPackages."firecrawl-mcp"
  ];
}
```

---

## Migration Steps

### 1. Generate Expressions

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
node2nix -i npm-packages.json -o npm-node-packages.nix -c npm-default.nix -e npm-node-env.nix
```

### 2. Update home.nix Imports

```nix
imports = [
  ./npm-tools.nix  # Add this line
];
```

### 3. Remove Old Code

Remove from home.nix:
- `home.activation.install-claude-code`
- `home.activation.install-cline`
- `systemd.user.services.claude-code-update`
- `systemd.user.timers.claude-code-update`

### 4. Test Build

```bash
home-manager build --flake .#mitsio@shoshin
home-manager switch --flake .#mitsio@shoshin
```

### 5. Verify

```bash
claude --version
mcp-read-website-fast --version
context7-mcp --version
firecrawl-mcp --version

# Should show Nix store paths
which claude
```

### 6. Clean Up Old Packages

```bash
npm uninstall -g @anthropic-ai/claude-code
npm uninstall -g @just-every/mcp-read-website-fast
npm uninstall -g @upstash/context7-mcp
npm uninstall -g firecrawl-mcp
```

---

## Updating Packages

```bash
# Update to latest versions
node2nix -i npm-packages.json \
  -o npm-node-packages.nix \
  -c npm-default.nix \
  -e npm-node-env.nix

# Or pin specific versions
cat > npm-packages.json <<EOF
[
  { "@anthropic-ai/claude-code": "1.2.3" },
  { "firecrawl-mcp": "3.6.0" }
]
EOF

home-manager switch --flake .#mitsio@shoshin
```

---

## Troubleshooting

### Build Errors

```bash
# Show detailed errors
home-manager switch --show-trace

# Check specific package
nix-build npm-default.nix -A "@anthropic-ai/claude-code"
```

### Missing Native Dependencies

```nix
nodePackages // {
  "some-package" = nodePackages."some-package".override {
    buildInputs = [ pkgs.python3 pkgs.gcc ];
  };
}
```

### node2nix Command Not Found

```bash
# Rebuild with current config first
home-manager switch --flake .#mitsio@shoshin
```

---

## Files Structure

```
home-manager/
├── npm-packages.json          # Package list
├── npm-node-packages.nix      # Generated definitions
├── npm-default.nix            # Generated composition
├── npm-node-env.nix           # Generated build logic
└── npm-tools.nix              # Wrapper module
```

---

## Benefits Summary

| Aspect | Before | After |
|--------|--------|-------|
| Rebuild time | ~30s | ~5s |
| Reproducible | No | Yes |
| Version control | No | Yes |
| Rollback | Limited | Full |

---

## References

- **node2nix GitHub:** https://github.com/svanderburg/node2nix
- **Nixpkgs Node.js:** https://nixos.org/manual/nixpkgs/stable/#node.js
- **Home Manager:** https://nix-community.github.io/home-manager/

---

*Migrated from docs/home-manager/node2nix/ on 2025-11-29*
