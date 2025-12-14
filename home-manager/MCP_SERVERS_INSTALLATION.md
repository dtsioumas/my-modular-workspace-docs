# MCP Servers Installation Guide (NixOS/Home-Manager)

**Last Updated:** 2025-12-11
**ADR:** [ADR-010: Unified MCP Server Architecture](../adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md)

---

## Overview

This guide documents how MCP (Model Context Protocol) servers are installed declaratively using Nix and Home-Manager, following ADR-010 principles.

**Architecture:**
- **Layer 1 (Home-Manager):** All MCP servers as Nix derivations
- **Layer 2 (Chezmoi):** Configuration files only

---

## Current MCP Servers

### From natsukium/mcp-servers-nix Flake

These servers are pre-built in the [natsukium/mcp-servers-nix](https://github.com/natsukium/mcp-servers-nix) flake.

| Server | Wrapper | Description | Env Vars |
|--------|---------|-------------|----------|
| context7-mcp | `mcp-context7` | Library documentation lookup | - |
| mcp-server-sequential-thinking | `mcp-sequential-thinking` | Deep reasoning | - |
| mcp-server-fetch | `mcp-fetch` | Web content fetching | - |
| mcp-server-time | `mcp-time` | Timezone operations | - |

**Config file:** `home-manager/mcp-servers/from-flake.nix`

### Custom NPM Derivations

These servers are built using `buildNpmPackage` or `stdenv.mkDerivation`.

| Server | Version | Wrapper | Description | Env Vars |
|--------|---------|---------|-------------|----------|
| firecrawl-mcp | 3.2.1 | `mcp-firecrawl` | Web scraping | `FIRECRAWL_API_KEY` |
| exa-mcp-server | 3.1.3 | `mcp-exa` | Exa AI search | `EXA_API_KEY` |
| brave-search-mcp | 0.8.0 | `mcp-brave-search` | Brave Search | `BRAVE_API_KEY` |
| mcp-read-website-fast | 0.1.20 | `mcp-read-website-fast` | Fast web reading | - |

**Config file:** `home-manager/mcp-servers/npm-custom.nix`

### Custom Python Derivations

| Server | Version | Wrapper | Description | Env Vars |
|--------|---------|---------|-------------|----------|
| claude-thread-continuity | 1.1.0 | `mcp-claude-continuity` | Session persistence | - |

**Config file:** `home-manager/mcp-servers/python-custom.nix`

---

## Installation Steps

### Prerequisites

1. **Home-Manager** (standalone mode recommended)
2. **Nix Flakes** enabled
3. **natsukium/mcp-servers-nix** flake input in `flake.nix`

### Step 1: Add Flake Input

In your `home-manager/flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # MCP Servers Flake
    mcp-servers = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, mcp-servers, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit mcp-servers; };
        modules = [ ./home.nix ];
      };
    };
}
```

### Step 2: Create MCP Servers Directory

```
home-manager/mcp-servers/
├── default.nix       # Main importer
├── from-flake.nix    # Servers from natsukium/mcp-servers-nix
├── npm-custom.nix    # Custom NPM derivations
└── python-custom.nix # Custom Python derivations
```

### Step 3: Import in home.nix

```nix
{ config, lib, pkgs, mcp-servers, ... }:

{
  imports = [
    ./mcp-servers  # Imports mcp-servers/default.nix
  ];

  # ... rest of config
}
```

### Step 4: Build and Switch

```bash
cd ~/home-manager
home-manager switch --flake .#user@host -b backup
```

---

## File Structure

### default.nix

```nix
{ config, pkgs, lib, mcp-servers, ... }:

{
  imports = [
    ./from-flake.nix
    ./npm-custom.nix
    ./python-custom.nix
    # Future: ./go-custom.nix
  ];
}
```

### from-flake.nix

```nix
{ config, pkgs, lib, mcp-servers, ... }:

let
  mcpPkgs = mcp-servers.packages.${pkgs.system};

  mkMcpWrapper = { name, package, binary, extraArgs ? [], description ? "MCP Server: ${name}" }:
    pkgs.writeShellScriptBin "mcp-${name}" ''
      exec ${pkgs.util-linux}/bin/setpriv --pdeathsig SIGTERM -- \
        ${pkgs.systemd}/bin/systemd-run \
          --user --scope --slice=mcp-servers.slice \
          --unit="mcp-${name}-''${RANDOM}.scope" \
          --description="${description}" --collect \
          --property=MemoryMax=1G --property=CPUQuota=100% \
          -- ${package}/bin/${binary} ${lib.escapeShellArgs extraArgs} "$@"
    '';
in
{
  home.packages = [
    mcpPkgs.context7-mcp
    mcpPkgs.mcp-server-sequential-thinking
    mcpPkgs.mcp-server-fetch
    mcpPkgs.mcp-server-time

    (mkMcpWrapper {
      name = "context7";
      package = mcpPkgs.context7-mcp;
      binary = "context7-mcp";
    })
    # ... more wrappers
  ];
}
```

### npm-custom.nix (Example: firecrawl-mcp)

```nix
{ config, pkgs, lib, ... }:

let
  mkMcpWrapper = { ... }: /* same as above */;

  firecrawl-mcp = pkgs.buildNpmPackage rec {
    pname = "firecrawl-mcp";
    version = "3.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "firecrawl";
      repo = "firecrawl-mcp-server";
      rev = "v${version}";
      hash = "sha256-RLcHZrQCdTOtOjv6u2df45pfthiD9BlyMqcZeH32C80=";
    };

    npmDepsHash = "sha256-6/IyDfjFyExuJDKtnYjHZxYoESjS9/rMbK/z7JthlVo=";
    npmBuildScript = "build";

    meta = {
      description = "Firecrawl MCP server for web scraping";
      homepage = "https://github.com/firecrawl/firecrawl-mcp-server";
      license = lib.licenses.mit;
    };
  };
in
{
  home.packages = [
    (mkMcpWrapper {
      name = "firecrawl";
      package = firecrawl-mcp;
      binary = "firecrawl-mcp";
      description = "MCP Server: Firecrawl Web Scraping";
    })
  ];
}
```

### python-custom.nix (Example: claude-thread-continuity)

```nix
{ config, pkgs, lib, ... }:

let
  mkMcpWrapper = { ... }: /* same as above */;

  # Python with MCP dependencies
  pythonWithDeps = pkgs.python3.withPackages (ps: with ps; [
    mcp
    pydantic
  ]);

  claude-thread-continuity = pkgs.stdenv.mkDerivation rec {
    pname = "claude-thread-continuity";
    version = "1.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "peless";
      repo = "claude-thread-continuity";
      rev = "main";
      hash = "sha256-7ktzofF3+S9tU1v2cC811d/Ytv8VSNcJDhXZsb/iQIA=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/lib/claude-thread-continuity $out/bin
      cp server.py $out/lib/claude-thread-continuity/
      cat > $out/bin/claude-thread-continuity << EOF
#!/usr/bin/env bash
exec ${pythonWithDeps}/bin/python3 $out/lib/claude-thread-continuity/server.py "\$@"
EOF
      chmod +x $out/bin/claude-thread-continuity
    '';
  };
in
{
  home.packages = [
    (mkMcpWrapper {
      name = "claude-continuity";
      package = claude-thread-continuity;
      binary = "claude-thread-continuity";
    })
  ];
}
```

---

## Wrapper Script Features

All MCP servers are wrapped with:

1. **`setpriv --pdeathsig SIGTERM`** - Server receives SIGTERM when parent (Claude) exits
2. **`systemd-run --scope`** - Resource isolation (memory, CPU limits)
3. **`--slice=mcp-servers.slice`** - All MCPs in same cgroup slice
4. **`--property=MemoryMax=1G`** - Max 1GB RAM per server
5. **`--property=CPUQuota=100%`** - Max 1 CPU core per server

---

## Hash Calculation

When adding new servers, calculate hashes with:

```bash
# For GitHub sources
nix-prefetch-url --unpack https://github.com/owner/repo/archive/refs/tags/vX.Y.Z.tar.gz

# Convert to SRI format
nix hash to-sri --type sha256 <hash>

# For npm dependencies (buildNpmPackage)
# Use fake hash first, then Nix will tell you the correct one
npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```

---

## Secrets Management

API keys are inherited from systemd user environment via ADR-011:

1. Keys stored in KeePassXC vault
2. `load-keepassxc-secrets.service` exports keys at login
3. `systemd-run` inherits the environment automatically

**Required entries in KeePassXC:**

| Entry Path | Env Var |
|------------|---------|
| `Development/APIs/Firecrawl` | `FIRECRAWL_API_KEY` |
| `Development/APIs/Exa` | `EXA_API_KEY` |
| `Development/APIs/Brave Search` | `BRAVE_API_KEY` |

---

## Testing

After `home-manager switch`, test each server:

```bash
# Check if wrapper is installed
which mcp-firecrawl

# Test server startup (Ctrl+C to stop)
mcp-firecrawl --help

# Check systemd scopes
systemctl --user list-units 'mcp-*.scope'
```

---

## Troubleshooting

### "Module not found" errors

**Problem:** Python servers can't find dependencies.

**Solution:** Use `python3.withPackages` instead of `buildPythonApplication`:

```nix
pythonWithDeps = pkgs.python3.withPackages (ps: with ps; [ mcp pydantic ]);
```

### npm cache errors

**Problem:** `buildNpmPackage` fails with cache errors.

**Solution:** Use `stdenv.mkDerivation` with pre-built npm tarball (see exa-mcp-server example in `npm-custom.nix`).

### Server doesn't stop when Claude exits

**Problem:** Orphaned MCP processes.

**Solution:** Ensure wrapper uses `setpriv --pdeathsig SIGTERM`.

---

## References

- [ADR-010: Unified MCP Server Architecture](../adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md)
- [ADR-011: Secrets Management](../adrs/ADR-011-UNIFIED_SECRETS_MANAGEMENT_VIA_KEEPASSXC.md)
- [natsukium/mcp-servers-nix](https://github.com/natsukium/mcp-servers-nix)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [Nix buildNpmPackage](https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific)
- [Nix buildPythonPackage](https://nixos.org/manual/nixpkgs/stable/#python)
