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

### Python Servers (buildPythonPackage)

| Server | Source | Status |
|--------|--------|--------|
| ast-grep-mcp | GitHub | Needs derivation |
| sequential-thinking-mcp | GitHub | Needs derivation |
| mcp-server-fetch | PyPI | Needs derivation |
| mcp-server-time | PyPI | Needs derivation |

### NPM Servers (buildNpmPackage)

| Server | Package | Status |
|--------|---------|--------|
| context7-mcp | @upstash/context7-mcp | Needs derivation |
| firecrawl-mcp | firecrawl-mcp | Needs derivation |
| exa-mcp | @modelcontextprotocol/server-exa | Needs derivation |
| brave-search | @brave/brave-search-mcp-server | Needs derivation |
| read-website-fast | @just-every/mcp-read-website-fast | Needs derivation |

### Go Servers (buildGoModule)

| Server | Source | Status |
|--------|--------|--------|
| git-mcp-go | github.com/tak-bro/git-mcp-go | Needs derivation |
| mcp-shell | github.com/punkpeye/mcp-shell | Needs derivation |

### Rust Servers (buildRustPackage)

| Server | Source | Status |
|--------|--------|--------|
| rust-mcp-filesystem | GitHub | DONE (already packaged) |

### Available in nixpkgs

| Server | Package | Status |
|--------|---------|--------|
| github-mcp-server | pkgs.github-mcp-server | Available |
| ast-grep CLI | pkgs.ast-grep | Available (CLI only) |

---

## Migration Checklist

### Phase 1: Python Servers
- [ ] Create `mcp-servers/python.nix`
- [ ] Package `ast-grep-mcp`
- [ ] Package `sequential-thinking-mcp`
- [ ] Package `mcp-server-fetch`
- [ ] Package `mcp-server-time`
- [ ] Test all Python servers

### Phase 2: NPM Servers
- [ ] Create `mcp-servers/npm.nix`
- [ ] Package `context7-mcp`
- [ ] Package `firecrawl-mcp`
- [ ] Package `exa-mcp`
- [ ] Package `brave-search-mcp`
- [ ] Package `read-website-fast`
- [ ] Test all NPM servers

### Phase 3: Go Servers
- [ ] Create `mcp-servers/go.nix`
- [ ] Package `git-mcp-go`
- [ ] Package `mcp-shell`
- [ ] Test all Go servers

### Phase 4: Consolidation
- [ ] Create unified `mcp-servers/wrappers.nix`
- [ ] Remove old wrapper scripts from `~/.local/bin/`
- [ ] Update chezmoi templates
- [ ] Remove runtime installers from `local-mcp-servers.nix`
- [ ] Test full integration

### Phase 5: Cleanup
- [ ] Remove `uv`, `go` from required packages (if not needed elsewhere)
- [ ] Remove activation scripts for MCP installation
- [ ] Update documentation
- [ ] Archive old configuration

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
**Status:** Implementation In Progress (2025-12-06)
