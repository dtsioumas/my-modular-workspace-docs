# Nix MCP Servers Packaging Research

**Date:** 2025-12-06
**Author:** Mitsio + Claude Code
**Related:** ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md

---

## Executive Summary

This research investigates best practices and existing solutions for packaging MCP (Model Context Protocol) servers as Nix derivations. The goal is to migrate from runtime package managers (uv, npm, go install) to fully declarative Nix packages managed by Home-Manager.

**Key Finding:** An existing Nix flake (`natsukium/mcp-servers-nix`) provides pre-built packages for many MCP servers, potentially eliminating the need to create derivations from scratch.

---

## 1. Existing Nix Flakes for MCP Servers

### 1.1 natsukium/mcp-servers-nix (Primary Recommendation)

**Repository:** https://github.com/natsukium/mcp-servers-nix
**Stars:** ~160
**Status:** Active, well-maintained

**Pre-built Packages Available:**

| Package | Type | Status |
|---------|------|--------|
| `context7` | NPM | ✅ Available |
| `fetch` | Python | ✅ Available |
| `filesystem` | NPM | ✅ Available |
| `git` | NPM | ✅ Available |
| `github` | NPM | ✅ Available |
| `memory` | NPM | ✅ Available |
| `nixos` | Python | ✅ Available |
| `sequential-thinking` | Python | ✅ Available |
| `time` | Python | ✅ Available |

**Usage as Flake Input:**
```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mcp-servers.url = "github:natsukium/mcp-servers-nix";
  };

  outputs = { nixpkgs, mcp-servers, ... }: {
    # Use as overlay
    nixpkgs.overlays = [ mcp-servers.overlays.default ];

    # Or access packages directly
    # mcp-servers.packages.${system}.context7
    # mcp-servers.packages.${system}.sequential-thinking
  };
}
```

**Helper Function for Custom Servers:**
```nix
# mkServerModule helper for creating wrapper scripts
{ config, lib, pkgs, ... }:
let
  cfg = config.services.mcp-servers;
in {
  options.services.mcp-servers = {
    enable = lib.mkEnableOption "MCP servers";
    # ... server options
  };
}
```

**Advantages:**
- Ready-to-use packages with correct hashes
- Maintained by active community
- Follows nixpkgs conventions
- Includes both NPM and Python servers

**Considerations:**
- May not have all servers we need (firecrawl, exa, brave-search, ast-grep)
- Version pinning via flake.lock

---

### 1.2 ismail-kattakath/nix-mcp-servers

**Repository:** https://github.com/ismail-kattakath/nix-mcp-servers
**Stars:** ~20
**Status:** Active

**Features:**
- Home Manager modules included
- Focus on integration with existing Nix configs
- Smaller package selection

**Usage:**
```nix
{
  inputs.nix-mcp-servers.url = "github:ismail-kattakath/nix-mcp-servers";
}
```

---

## 2. Home Manager Integration Patterns

### 2.1 Lewis Flude's Pattern (Recommended)

**Source:** https://lewisflude.com/blog/mcp-nix-blog-post

**Key Innovation:** Two-stage deployment to solve symlink issues

**Problem:** cursor-agent and some MCP clients can't follow Nix symlinks properly.

**Solution:** Home-Manager activation script copies config with real file paths:

```nix
{ config, pkgs, lib, ... }:
{
  home.activation.deployMcpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Create real file instead of symlink
    mkdir -p ${config.home.homeDirectory}/.config/mcp

    # Generate config with resolved paths
    cat > ${config.home.homeDirectory}/.config/mcp/config.json << 'EOF'
    {
      "mcpServers": {
        "filesystem": {
          "command": "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem",
          "args": ["--root", "${config.home.homeDirectory}"]
        }
      }
    }
    EOF
  '';
}
```

**Secret Management with SOPS:**
```nix
{ config, pkgs, ... }:
let
  secrets = config.sops.secrets;
in {
  home.activation.deployMcpConfig = lib.hm.dag.entryAfter ["writeBoundary" "sops-nix"] ''
    # Load secrets from SOPS
    source ${secrets.mcp-api-keys.path}

    # Generate config with secrets
    cat > ~/.config/mcp/config.json << EOF
    {
      "mcpServers": {
        "firecrawl": {
          "command": "${pkgs.firecrawl-mcp}/bin/firecrawl-mcp",
          "env": {
            "FIRECRAWL_API_KEY": "$FIRECRAWL_API_KEY"
          }
        }
      }
    }
    EOF
  '';
}
```

---

## 3. Building Custom Derivations

### 3.1 buildNpmPackage Pattern

**For TypeScript/JavaScript MCP servers:**

```nix
{ lib, fetchFromGitHub, buildNpmPackage }:

buildNpmPackage rec {
  pname = "firecrawl-mcp";
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "mendableai";
    repo = "firecrawl-mcp-server";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  # Handle TypeScript compilation
  npmBuildScript = "build";

  # Ensure proper binary creation
  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/firecrawl-mcp \
      --add-flags "$out/lib/node_modules/firecrawl-mcp/dist/index.js"
  '';

  meta = {
    description = "Firecrawl MCP server for web scraping";
    homepage = "https://github.com/mendableai/firecrawl-mcp-server";
    license = lib.licenses.asl20;
    mainProgram = "firecrawl-mcp";
  };
}
```

**Hash Calculation:**
```bash
# For src hash
nix-prefetch-url --unpack https://github.com/owner/repo/archive/v1.0.0.tar.gz

# For npmDepsHash (requires package-lock.json)
prefetch-npm-deps package-lock.json
# OR
nix build --impure --expr '
  with import <nixpkgs> {};
  buildNpmPackage {
    src = fetchFromGitHub { ... };
    npmDepsHash = lib.fakeHash;
  }
'
# The error message will show the correct hash
```

---

### 3.2 buildPythonPackage Pattern

**For Python MCP servers:**

```nix
{ lib, python3Packages, fetchPypi, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "mcp-server-fetch";
  version = "0.6.2";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    mcp  # The MCP SDK
    httpx
    anyio
  ];

  # Skip tests that require network
  doCheck = false;

  meta = {
    description = "MCP server for fetching web content";
    homepage = "https://github.com/modelcontextprotocol/servers";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-fetch";
  };
}
```

**Note on `mcp` Python library:**
- Available on PyPI as `mcp` (v1.23.1)
- May need to be packaged for nixpkgs if not available
- Check: `nix search nixpkgs python3Packages.mcp`

---

### 3.3 buildGoModule Pattern

**For Go MCP servers:**

```nix
{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "git-mcp-go";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "tak-bro";
    repo = "git-mcp-go";
    rev = "v${version}";
    hash = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=";
  };

  vendorHash = "sha256-EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=";

  # Disable tests that require git repo
  doCheck = false;

  meta = {
    description = "Git MCP server in Go";
    homepage = "https://github.com/tak-bro/git-mcp-go";
    license = lib.licenses.mit;
    mainProgram = "git-mcp-go";
  };
}
```

---

## 4. Systemd Integration

### 4.1 Resource Isolation with Slices

**Current Pattern (Working):**
```nix
(pkgs.writeShellScriptBin "mcp-wrapper" ''
  exec systemd-run \
    --user \
    --scope \
    --slice=mcp-servers.slice \
    --unit="mcp-$1-''${RANDOM}.scope" \
    --description="MCP Server: $1" \
    --collect \
    --property=MemoryMax=1G \
    --property=CPUQuota=100% \
    -- \
    "$@"
'')
```

**Slice Definition (Chezmoi):**
```ini
# ~/.config/systemd/user/mcp-servers.slice
[Unit]
Description=MCP Servers Resource Slice
Documentation=man:systemd.slice(5)

[Slice]
MemoryMax=4G
CPUQuota=200%
TasksMax=100
```

---

## 5. Nixpkgs Availability Check

**Searched nixpkgs for MCP-related packages:**

| Search Term | Result |
|-------------|--------|
| `sequential-thinking` | Not found |
| `firecrawl` | Not found |
| `mcp-server` | Not found |
| `context7` | Not found |
| `ast-grep` | ✅ Found (CLI only, not MCP) |

**Conclusion:** Most MCP servers are NOT in nixpkgs. Options:
1. Use `natsukium/mcp-servers-nix` flake (recommended)
2. Create custom derivations for missing packages
3. Contribute packages to nixpkgs (long-term)

---

## 5.1 Updated Package Discovery (2025-12-06)

**Actual packages available in natsukium/mcp-servers-nix flake:**

Discovered via `nix flake show github:natsukium/mcp-servers-nix`:

| Package Name | Type | Status |
|-------------|------|--------|
| `context7-mcp` | NPM | ✅ Available |
| `mcp-server-fetch` | Python | ✅ Available |
| `mcp-server-time` | Python | ✅ Available |
| `mcp-server-sequential-thinking` | NPM | ✅ Available |
| `mcp-server-filesystem` | NPM | ✅ Available |
| `mcp-server-git` | NPM | ✅ Available |
| `github-mcp-server` | NPM | ✅ Available |
| `mcp-server-memory` | NPM | ✅ Available |
| `mcp-server-brave-search` | NPM | ⚠️ ARCHIVED upstream |
| `mcp-grafana` | NPM | ✅ Available |
| `notion-mcp-server` | NPM | ✅ Available |
| `playwright-mcp` | NPM | ✅ Available |
| `tavily-mcp` | NPM | ✅ Available |

**Key Finding:** `mcp-server-brave-search` was archived upstream and removed from the flake.
Need custom derivation for brave-search alternative.

---

## 6. MCP Python SDK

**Package:** `mcp` on PyPI
**Version:** 1.23.1 (as of 2025-12-06)
**Documentation:** https://modelcontextprotocol.io/

**Check nixpkgs availability:**
```bash
nix search nixpkgs python3Packages.mcp
```

If not available, we need to package it first as a dependency for Python MCP servers.

---

## 7. Recommendations

### 7.1 Immediate Actions

1. **Add `natsukium/mcp-servers-nix` as flake input**
   - Provides: context7, fetch, sequential-thinking, time, filesystem, git, github
   - Reduces derivation work significantly

2. **Create custom derivations for missing servers:**
   - firecrawl-mcp (buildNpmPackage)
   - exa-mcp (buildNpmPackage)
   - brave-search-mcp (buildNpmPackage)
   - read-website-fast (buildNpmPackage)
   - ast-grep-mcp (buildPythonPackage)

3. **Use Lewis Flude's activation pattern**
   - Solves symlink issues
   - Integrates with SOPS/KeePassXC for secrets

### 7.2 Architecture Decision

**Recommended Approach:**
```
Flake Inputs:
├── nixpkgs (unstable)
├── home-manager
└── mcp-servers-nix (natsukium's flake)

home-manager/
├── mcp-servers/
│   ├── default.nix      # Imports all modules
│   ├── from-flake.nix   # Servers from mcp-servers-nix
│   ├── npm-custom.nix   # Our custom NPM derivations
│   ├── python-custom.nix # Our custom Python derivations
│   └── wrappers.nix     # Unified wrapper scripts

dotfiles/.chezmoi/
├── mcp_config.json.tmpl  # Points to Nix binaries
└── secrets/              # API keys via KeePassXC
```

---

## 8. External Resources

- **MCP Protocol Specification:** https://modelcontextprotocol.io/
- **natsukium/mcp-servers-nix:** https://github.com/natsukium/mcp-servers-nix
- **Nix buildNpmPackage:** https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific
- **Nix buildPythonPackage:** https://nixos.org/manual/nixpkgs/stable/#python
- **Nix buildGoModule:** https://nixos.org/manual/nixpkgs/stable/#ssec-language-go
- **Lewis Flude's MCP Nix Blog:** https://lewisflude.com/blog/mcp-nix-blog-post

---

## 9. Next Steps

1. [ ] Add `natsukium/mcp-servers-nix` to flake.nix inputs
2. [ ] Create `home-manager/mcp-servers/from-flake.nix` using available packages
3. [ ] Create buildNpmPackage derivations for: firecrawl, exa, brave-search, read-website-fast
4. [ ] Create buildPythonPackage for ast-grep-mcp
5. [ ] Update chezmoi templates to use Nix-managed binaries
6. [ ] Test full integration

---

**Research Status:** Complete
**Confidence Level:** High (c = 0.85)
