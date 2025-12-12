# ADR-010: Unified MCP Server Architecture

**Status:** Accepted
**Date:** 2025-12-06
**Author:** Mitsio
**Context:** Standardizing MCP server installation and configuration management

---

## Context and Problem Statement

MCP (Model Context Protocol) servers are currently managed through a fragmented architecture:

### Current State (Problematic)

**Installation (Mixed, Non-Declarative):**
1. **Python servers:** Installed via `uv tool run` at runtime (NOT declarative)
2. **NPM servers:** Installed via `npx` at runtime (NOT declarative)
3. **Go servers:** Installed via `go install` at runtime (NOT declarative)
4. **Rust server:** Properly packaged via `buildRustPackage` (CORRECT)

**Configuration:**
- Chezmoi manages config files via templates (CORRECT)
- But wrappers in `~/.local/bin/mcp-wrapper-*` are NOT managed by home-manager

**Issues:**
- Runtime installation breaks reproducibility
- `uv tool run` requires network access at launch time
- Systemd scopes created by wrappers are disconnected from Nix management
- `uv tool install` for git packages fails (ast-grep issue)
- Git binary not in PATH during home-manager activation
- No single source of truth for MCP server binaries

---

## Decision

### Two-Layer Architecture

**Layer 1: Installation (Home-Manager)**
- ALL MCP servers MUST be Nix packages/derivations
- Use appropriate builders:
  - `buildPythonPackage` for Python MCP servers
  - `buildNpmPackage` for NPM MCP servers
  - `buildGoModule` for Go MCP servers
  - `buildRustPackage` for Rust MCP servers
- Home-manager provides wrapper scripts that use Nix-managed binaries
- NO runtime package managers (`uv`, `npm`, `npx`, `go install`) for installation

**Layer 2: Configuration (Chezmoi)**
- Chezmoi manages MCP configuration files:
  - `~/.claude/mcp_config.json` (Claude Code)
  - `~/.config/warp-terminal/mcp_servers.json` (Warp)
  - `~/.config/VSCodium/...cline_mcp_settings.json` (Cline)
- Templates use data from `.chezmoidata/mcp.yaml`
- Configuration points to Nix-managed binaries

---

## Rationale

### Why Nix Packages for Installation?

#### 1. **Declarative & Reproducible**
```nix
# Good: Declarative Nix derivation
home.packages = [ pkgs.mcp-server-time ];

# Bad: Runtime installation
uv tool run mcp-server-time  # Network dependency at runtime
```

#### 2. **Offline Capability**
- Nix packages work offline after initial build
- Runtime installers require network at every launch

#### 3. **Version Pinning**
- Nix flake.lock pins exact versions
- `uv tool run` gets latest (unpredictable)

#### 4. **No PATH Issues**
- Nix handles all dependencies
- No more "git not found" or "bash not found" errors

#### 5. **Consistent with ADR-001, ADR-007, ADR-008**
- ADR-001: Home-Manager for user packages
- ADR-007: Home-Manager for autostart
- ADR-008: Home-Manager for automated jobs
- Logical extension: Home-Manager for MCP servers

### Why Chezmoi for Configuration?

#### 1. **Cross-Platform**
- Same config templates work on NixOS, Fedora, etc.
- Per ADR-005: Chezmoi for portable configs

#### 2. **Templating**
- Machine-specific paths, API keys, enabled servers
- `.chezmoidata/mcp.yaml` as single source of truth

#### 3. **Already Implemented**
- Templates exist in `dotfiles/.chezmoitemplates/mcp/`
- Just need to point to Nix-managed binaries

---

## Implementation Plan

### Phase 1: Create Python MCP Derivations

```nix
# home-manager/mcp-servers/python.nix
{ pkgs, ... }:

let
  # AST-grep MCP Server
  ast-grep-mcp = pkgs.python3Packages.buildPythonPackage rec {
    pname = "sg-mcp";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "ast-grep";
      repo = "ast-grep-mcp";
      rev = "main";  # Pin to specific commit
      sha256 = "sha256-PLACEHOLDER";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [
      pydantic
      mcp
      pyyaml
    ];
    # Requires ast-grep CLI
    buildInputs = [ pkgs.ast-grep ];
  };

  # Sequential Thinking MCP
  sequential-thinking-mcp = pkgs.python3Packages.buildPythonPackage rec {
    pname = "sequential-thinking-mcp";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "arben-adm";
      repo = "mcp-sequential-thinking";
      rev = "main";
      sha256 = "sha256-PLACEHOLDER";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [
      mcp
      portalocker
    ];
  };

  # MCP Server Fetch
  mcp-server-fetch = pkgs.python3Packages.buildPythonPackage rec {
    pname = "mcp-server-fetch";
    version = "0.6.2";
    # From PyPI
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-PLACEHOLDER";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [ mcp ];
  };

  # MCP Server Time
  mcp-server-time = pkgs.python3Packages.buildPythonPackage rec {
    pname = "mcp-server-time";
    version = "0.6.2";
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-PLACEHOLDER";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [ mcp ];
  };
in
{
  home.packages = [
    ast-grep-mcp
    sequential-thinking-mcp
    mcp-server-fetch
    mcp-server-time
  ];
}
```

### Phase 2: Create NPM MCP Derivations

```nix
# home-manager/mcp-servers/npm.nix
{ pkgs, ... }:

let
  # Context7 MCP
  context7-mcp = pkgs.buildNpmPackage rec {
    pname = "context7-mcp";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "upstash";
      repo = "context7-mcp";
      rev = "v${version}";
      sha256 = "sha256-PLACEHOLDER";
    };
    npmDepsHash = "sha256-PLACEHOLDER";
  };

  # Firecrawl MCP
  firecrawl-mcp = pkgs.buildNpmPackage rec {
    pname = "firecrawl-mcp";
    version = "1.0.0";
    # Similar pattern...
  };

  # Read Website Fast
  mcp-read-website-fast = pkgs.buildNpmPackage rec {
    pname = "mcp-read-website-fast";
    version = "1.0.0";
    # Similar pattern...
  };
in
{
  home.packages = [
    context7-mcp
    firecrawl-mcp
    mcp-read-website-fast
  ];
}
```

### Phase 3: Create Go MCP Derivations

```nix
# home-manager/mcp-servers/go.nix
{ pkgs, ... }:

let
  # Git MCP Go
  git-mcp-go = pkgs.buildGoModule rec {
    pname = "git-mcp-go";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "tak-bro";
      repo = "git-mcp-go";
      rev = "v${version}";
      sha256 = "sha256-PLACEHOLDER";
    };
    vendorHash = "sha256-PLACEHOLDER";
  };

  # MCP Shell
  mcp-shell = pkgs.buildGoModule rec {
    pname = "mcp-shell";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "punkpeye";
      repo = "mcp-shell";
      rev = "v${version}";
      sha256 = "sha256-PLACEHOLDER";
    };
    vendorHash = "sha256-PLACEHOLDER";
  };
in
{
  home.packages = [
    git-mcp-go
    mcp-shell
  ];
}
```

### Phase 4: Unified Wrapper Scripts

```nix
# home-manager/mcp-servers/wrappers.nix
{ config, pkgs, lib, ... }:

{
  home.packages = [
    # Wrapper for ast-grep MCP with systemd resource limits
    (pkgs.writeShellScriptBin "mcp-ast-grep" ''
      SECRETS_FILE="${config.home.homeDirectory}/.config/mcp/secrets.env"
      if [[ -f "$SECRETS_FILE" ]]; then
        source "$SECRETS_FILE"
      fi

      exec systemd-run \
        --user \
        --scope \
        --slice=mcp-servers.slice \
        --unit="mcp-ast-grep-''${RANDOM}.scope" \
        --description="MCP Server: ast-grep" \
        --collect \
        --property=MemoryMax=1G \
        --property=CPUQuota=100% \
        -- \
        ${pkgs.ast-grep-mcp}/bin/ast-grep-server "$@"
    '')

    # Similar wrappers for other servers...
  ];
}
```

### Phase 5: Update Chezmoi Templates

Update `.chezmoidata/mcp.yaml` to point to Nix-managed binaries:

```yaml
mcp:
  servers:
    ast_grep:
      name: "ast-grep"
      description: "AST-aware code search"
      type: "nix"  # New type: Nix-managed
      command: "{{ .chezmoi.homeDir }}/.nix-profile/bin/mcp-ast-grep"
      risk_level: "low"
```

---

## Consequences

### Positive

- **Fully declarative:** All MCP servers in Nix
- **Reproducible:** `flake.lock` pins versions
- **Offline capable:** Works without network after build
- **No runtime failures:** No more "package not found" errors
- **Consistent architecture:** Aligns with all existing ADRs
- **Single source of truth:** Home-manager for install, chezmoi for config

### Negative

- **Initial effort:** Must create derivations for all MCP servers
- **Maintenance:** Must update derivations when upstream changes
- **Build time:** First build takes longer than runtime install

### Neutral

- **Chezmoi unchanged:** Config templates continue to work
- **Systemd slice unchanged:** Resource limits still apply
- **Secret loading unchanged:** KeePassXC integration preserved

---

## MCP Server Inventory

### From natsukium/mcp-servers-nix Flake ✅ COMPLETE

| Server | Package | Status |
|--------|---------|--------|
| context7-mcp | mcpPkgs.context7-mcp | ✅ WORKING |
| mcp-server-sequential-thinking | mcpPkgs.mcp-server-sequential-thinking | ✅ WORKING |
| mcp-server-fetch | mcpPkgs.mcp-server-fetch | ✅ WORKING |
| mcp-server-time | mcpPkgs.mcp-server-time | ✅ WORKING |

### NPM Servers (npm-custom.nix) ✅ COMPLETE

| Server | Version | Method | Status |
|--------|---------|--------|--------|
| firecrawl-mcp | 3.2.1 | buildNpmPackage | ✅ WORKING |
| exa-mcp-server | 3.1.3 | stdenv.mkDerivation (pre-built tarball) | ✅ WORKING |
| brave-search-mcp | 0.8.0 | buildNpmPackage (mikechao alternative) | ✅ WORKING |
| mcp-read-website-fast | 0.1.20 | buildNpmPackage | ✅ WORKING |

### Python Servers (python-custom.nix) ✅ COMPLETE

| Server | Version | Method | Status |
|--------|---------|--------|--------|
| claude-thread-continuity | 1.1.0 | stdenv.mkDerivation + python3.withPackages | ✅ WORKING |
| ast-grep-mcp | 0.1.0 | stdenv.mkDerivation + python3.withPackages | ✅ WORKING |

### Go Servers (go-custom.nix) ✅ COMPLETE

| Server | Version | Source | Status |
|--------|---------|--------|--------|
| mcp-shell | 0.3.1 | sonirico/mcp-shell | ✅ WORKING |
| git-mcp-go | 1.3.1 | geropl/git-mcp-go | ✅ WORKING |

**mcp-shell Implementation Details (Completed 2025-12-13):**
- **Binary name:** `mcp-shell`
- **Go version:** 1.25
- **MCP wrapper:** `mcp-shell` (with systemd isolation)
- **Features:** Command allowlist/blocklist, audit logging, Docker support
- **Source hash:** `sha256-dgnInK646/jdAUInWPvgRqWo0LbE9ATupuBK2sthDgE=`
- **Vendor hash:** `sha256-FW/GZwVU8Oj02bd3cpaNBOvpq5hbmuto00O4R7/l6wA=`

**git-mcp-go Implementation Details (Completed 2025-12-13):**
- **Binary name:** `git-mcp-go`
- **Go version:** 1.23.6
- **MCP wrapper:** `mcp-git` (with systemd isolation, uses `serve` subcommand)
- **Features:** git_status, git_diff, git_commit, git_add, git_log, git_push, multi-repo support
- **Source hash:** `sha256-3wUClzm3IO1/LXkGStzdh3PW/anZHbtBN7LdKjaDn6I=`
- **Vendor hash:** `sha256-IuWyvYzczCmbEuwf05vHXH2N0gldHRYiySnZf7cm2do=`

### Rust Servers (rust-custom.nix) ✅ COMPLETE

| Server | Version | Source | Status |
|--------|---------|--------|--------|
| ck | 0.7.0 | github.com/BeaconBay/ck | ✅ WORKING |
| rust-mcp-filesystem | - | GitHub | ✅ DONE (already packaged) |

**ck-search Implementation Details (Completed 2025-12-12):**
- **Crate name:** `ck-search` (crates.io)
- **Binary name:** `ck`
- **Rust version:** 1.92.0 (via rust-overlay)
- **MCP Server mode:** `ck --serve`
- **MCP wrapper:** `mcp-ck` (with systemd isolation)
- **MCP Tools:** `semantic_search`, `regex_search`, `hybrid_search`, `index_status`, `reindex`, `health_check`
- **Source hash:** `sha256-CZsayq1JxOhGaT9iTNVKcyqGGnJlxcjDAbcMKArtR6k=`
- **Cargo hash:** `sha256-+74XPcv/mnG7GAG6H8QJe6EtyO2xWhHXvdyTGSPwZeI=`
- **ONNX fix:** Uses nixpkgs onnxruntime with `ORT_STRATEGY=system`

### Available in nixpkgs

| Server | Package | Status |
|--------|---------|--------|
| github-mcp-server | pkgs.github-mcp-server | Available |
| ast-grep CLI | pkgs.ast-grep | Available (CLI only) |

---

## Migration Checklist

### Phase 0: Infrastructure ✅ COMPLETE (2025-12-06)
- [x] Add `natsukium/mcp-servers-nix` as flake input
- [x] Create `home-manager/mcp-servers/` directory structure
- [x] Create `mcp-servers/default.nix` (main importer)
- [x] Create `mcp-servers/from-flake.nix` (flake packages with wrappers)

### Phase 1: Flake-Based Servers ✅ COMPLETE (2025-12-06)
- [x] Package `context7-mcp` (from flake)
- [x] Package `mcp-server-sequential-thinking` (from flake)
- [x] Package `mcp-server-fetch` (from flake)
- [x] Package `mcp-server-time` (from flake)
- [x] Test all flake-based servers

### Phase 2: NPM Servers ✅ COMPLETE (2025-12-11)
- [x] Create `mcp-servers/npm-custom.nix`
- [x] Package `firecrawl-mcp` (buildNpmPackage)
- [x] Package `exa-mcp-server` (stdenv.mkDerivation - pre-built tarball)
- [x] Package `brave-search-mcp` (buildNpmPackage - mikechao alternative)
- [x] Package `mcp-read-website-fast` (buildNpmPackage)
- [x] Test all NPM servers

### Phase 3: Python Servers ✅ COMPLETE (2025-12-11)
- [x] Create `mcp-servers/python-custom.nix`
- [x] Package `claude-thread-continuity` (stdenv.mkDerivation + python3.withPackages)
- [x] Package `ast-grep-mcp` (stdenv.mkDerivation + python3.withPackages + ast-grep CLI)
- [x] Add declarative symlink for ~/.claude_states storage
- [x] Test claude-thread-continuity - ✅ WORKING
- [x] Test ast-grep-mcp - Build success

### Phase 4: Rust Servers ✅ COMPLETE (2025-12-12)
- [x] Add `rust-overlay` flake input to `flake.nix`
- [x] Add `fenix` flake input to `flake.nix`
- [x] Create `mcp-servers/rust-custom.nix`
- [x] Package `ck` v0.7.0 using Rust 1.92.0 from rust-overlay
  - [x] Create rustPlatform.buildRustPackage derivation
  - [x] Calculate cargoHash
  - [x] Handle fastembed/ONNX dependencies (ORT_STRATEGY=system)
- [x] Create MCP wrapper for `ck --serve` (mcp-ck)
- [x] Test ck MCP server initialization
- [x] Update llm-core mcp_config.json.tmpl

### Phase 5: Go Servers ✅ COMPLETE (2025-12-13)
- [x] Create `mcp-servers/go-custom.nix`
- [x] Package `mcp-shell` v0.3.1 (sonirico/mcp-shell - user choice)
  - [x] Create buildGoModule derivation
  - [x] Calculate vendorHash: `sha256-FW/GZwVU8Oj02bd3cpaNBOvpq5hbmuto00O4R7/l6wA=`
  - [x] Create MCP wrapper (mcp-shell)
- [x] Package `git-mcp-go` v1.3.1 (geropl/git-mcp-go)
  - [x] Create buildGoModule derivation
  - [x] Calculate vendorHash: `sha256-IuWyvYzczCmbEuwf05vHXH2N0gldHRYiySnZf7cm2do=`
  - [x] Create MCP wrapper (mcp-git)
- [x] Test all Go servers
- [x] Remove old runtime `go install` wrappers from local-mcp-servers.nix

### Phase 6: Consolidation & Cleanup ✅ COMPLETE (2025-12-13)
- [x] Remove old Go binaries from `~/go/bin/` (git-mcp-go, mcp-shell)
- [x] Update chezmoi templates to use Nix-managed binaries
- [x] Add git.json.tmpl for mcp-git
- [x] Update shell.json.tmpl to note sonirico version
- [x] Remove runtime installers from `local-mcp-servers.nix`
- [x] Update Claude Desktop config (14 MCP servers)
- [x] Update Claude Code config (14 MCP servers)
- [x] Remove unused grok/chatgpt from Claude Code config
- [x] Test full integration with Claude Desktop/Code
- [x] Update documentation

---

## Alternatives Considered

### Alternative 1: Keep Runtime Installation
**Rejected because:**
- Not declarative
- Not reproducible
- Network dependency at launch
- Causes issues like the ast-grep failure

### Alternative 2: Docker Containers for MCP
**Rejected because:**
- Overkill for simple servers
- Adds complexity
- Slower startup
- NixOS already provides isolation

### Alternative 3: Flake Inputs for Each Server
**Considered:**
- Could use flake inputs to pin external repos
- Would simplify version management

**Status:** May adopt later for complex servers

---

## Related Decisions

- **ADR-001:** Home-Manager manages user packages
- **ADR-005:** Chezmoi for cross-platform configs
- **ADR-007:** Home-Manager for autostart
- **ADR-008:** Home-Manager for automated jobs
- **ADR-009:** Two-layer architecture for shell tools

---

## Review Schedule

**Next Review:** 2026-01-06 (1 month)

**Review Criteria:**
- Are all MCP servers packaged as Nix derivations?
- Has build time increased unacceptably?
- Are there new MCP servers to add?
- Is the architecture working well?

---

## References

- MCP Protocol: https://modelcontextprotocol.io/
- Nix buildPythonPackage: https://nixos.org/manual/nixpkgs/stable/#python
- Nix buildNpmPackage: https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific
- Nix buildGoModule: https://nixos.org/manual/nixpkgs/stable/#ssec-language-go

---

**Decision:** Accepted
**Status:** Implementation COMPLETE ✅
**Last Updated:** 2025-12-13
**Progress:** ALL PHASES COMPLETE ✅ (0-6) | 14 MCP servers declaratively packaged
