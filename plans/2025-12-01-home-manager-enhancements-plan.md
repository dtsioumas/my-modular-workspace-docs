# Home-Manager Enhancements Plan

**Session:** home-manager-enhancements-week-48
**Date:** 2025-11-23
**Status:** IN PROGRESS
**Goal:** Properly integrate tools, MCPs, and quality assurance into home-manager with declarative configuration
**Related TODO:** [docs/TODO.md](../TODO.md) Section 5

---

## Overview

This plan aims to enhance the home-manager configuration with:
1. **Semantic-grep** - Semantic search tool for finding docs and code
2. **MCP Servers** - Reorganize all MCP servers into `~/.local-mcp-servers/` with proper Nix installation
3. **Pre-commit Hooks** - Add pre-commit-hooks.nix for Nix code quality
4. **Claude Desktop Config** - Make Claude Desktop config declarative via chezmoi

**Total Estimated Time:** 8-13 hours

---

## Phase 1: Semantic-Grep Installation (2-3 hours)

### Objective
Install semantic-grep via home-manager using proper Nix derivation with all dependencies.

### Tool Information

**Repository:** https://github.com/arunsupe/semantic-grep
- **Language:** Go
- **Binary Name:** `w2vgrep`
- **Dependencies:**
  - Go compiler (build-time)
  - Word2Vec embedding model (runtime)

### Implementation Details

**Installation Method:**
- Use `pkgs.buildGoModule` to create derivation
- Package word embedding model (GoogleNews-slim recommended)
- Create wrapper script to:
  - Set model path via config.json or `-model_path` flag
  - Download model on first run if not present

**Model Management:**
- Store models in `~/.config/semantic-grep/models/`
- Support multiple language models
- Use activation script to download default model

**Files to Create:**
```
home-manager/semantic-grep.nix  # Main derivation
~/.config/semantic-grep/config.json  # Configuration
docs/tools/semantic-grep/  # Documentation
```

### Deliverables
- [x] Nix derivation for semantic-grep
- [x] Model download automation
- [ ] Documentation at `docs/tools/semantic-grep/`
- [ ] Navi cheatsheets in chezmoi repo

---

## Phase 2: MCP Servers Reorganization (4-6 hours)

### Objective
Move ALL MCP server installations to home-manager with organized directory structure.

### Current State Analysis

**Existing MCPs:**
- **npm-based:** context7-mcp, firecrawl-mcp, mcp-read-website-fast
- **Go-based:** git-mcp-go, mcp-filesystem-server, mcp-shell
- **Python/uv-based:** mcp-server-fetch, mcp-server-time, sequential-thinking
- **Rust-based:** rust-mcp-filesystem (to be added)

**Current Issues:**
- Mixed installation methods (npm global, go install, uv tool)
- No single source of truth
- Hard to reproduce across machines
- Username migration issues (mitso → mitsio paths)

### Target Architecture

**Directory Structure:**
```
~/.local-mcp-servers/
├── context7-mcp/
│   ├── bin/
│   └── config/
├── firecrawl-mcp/
│   ├── bin/
│   └── config/
├── mcp-read-website-fast/
│   ├── bin/
│   └── config/
├── git-mcp-go/
│   ├── bin/
│   └── config/
├── mcp-filesystem-server/ (Go)
│   ├── bin/
│   └── config/
├── rust-mcp-filesystem/ (Rust)
│   ├── bin/
│   └── config/
├── mcp-shell/
│   ├── bin/
│   └── config/
├── mcp-server-fetch/
│   ├── bin/
│   └── config/
├── mcp-server-time/
│   ├── bin/
│   └── config/
└── sequential-thinking/
    ├── bin/
    └── config/
```

### Implementation Strategy

**1. npm-based MCPs → node2nix**
- Research node2nix documentation (use semantic-grep once installed)
- Create node-packages.nix for each MCP
- Generate Nix expressions
- Install to `~/.local-mcp-servers/<mcp-name>/`

**2. Go-based MCPs → buildGoModule**
- Create derivations using `buildGoModule`
- Fetch from GitHub with proper version pinning
- Install binaries to MCP-specific directories

**3. Python/uv-based MCPs → buildPythonPackage**
- Convert to proper Python packages
- Use `buildPythonPackage` or keep uv with Nix wrapper

**4. Rust-based MCPs → buildRustPackage**
- Use `rustPlatform.buildRustPackage` for rust-mcp-filesystem
- Fetch from GitHub releases or build from source

### Files to Create
```
home-manager/mcps/  # Directory
├── context7-mcp.nix
├── firecrawl-mcp.nix
├── mcp-read-website-fast.nix
├── git-mcp-go.nix
├── mcp-filesystem-server.nix
├── mcp-shell.nix
├── rust-mcp-filesystem.nix
├── mcp-server-fetch.nix
├── mcp-server-time.nix
├── sequential-thinking.nix
└── default.nix  # Imports all
```

### Deliverables
- [ ] All MCPs installed via home-manager
- [ ] Organized in `~/.local-mcp-servers/`
- [ ] Single source of truth in Nix configuration
- [ ] Updated Claude Desktop config with new paths
- [ ] Tested and verified all MCPs working

---

## Phase 3: Pre-commit Hooks Setup (1-2 hours)

### Objective
Add pre-commit-hooks.nix to home-manager for automatic Nix code quality checks.

### Tools to Integrate

**From awesome-nix research:**
- **nixfmt** - Official Nix code formatter
- **statix** - Linter to check for antipatterns
- **deadnix** - Find dead/unused code
- **alejandra** - Alternative formatter (evaluate vs nixfmt)

### Implementation

**Configuration:**
- Add `pre-commit-hooks.nix` from cachix/git-hooks.nix
- Create `.pre-commit-config.yaml` for home-manager repo
- Configure hooks for:
  - Nix formatting
  - Nix linting
  - Dead code detection
  - Syntax validation

### Files to Create
- `home-manager/pre-commit.nix` or add to `flake.nix`
- `.pre-commit-config.yaml` in home-manager root
- Documentation in home-manager README

### Deliverables
- [ ] Pre-commit hooks configured
- [ ] Auto-run on git commit
- [ ] Integration with home-manager workflow
- [ ] Documentation for team members

---

## Phase 4: Claude Desktop Config Management (1-2 hours)

### Objective
Make Claude Desktop configuration declarative and managed by chezmoi.

### Current State
- Config at `~/.config/Claude/claude_desktop_config.json`
- Manual edits required
- No version control
- Secrets (API keys) embedded in config

### Target State
- Template in chezmoi: `~/.local/share/chezmoi/.config/Claude/claude_desktop_config.json.tmpl`
- Secrets managed via chezmoi/age encryption or KeePassXC
- Automated config generation
- MCP paths dynamically set via home-manager

### Implementation Steps

**1. Move config to chezmoi template**
- Create `.config/Claude/` in chezmoi source
- Template with `{{ .mcpServers }}` or similar

**2. Secret Management**
- Extract API keys (Firecrawl, Context7)
- Store in KeePassXC or age-encrypted file
- Reference in template via chezmoi secrets

**3. Dynamic Path Resolution**
- Use chezmoi variables for MCP paths
- Reference `~/.local-mcp-servers/` structure
- Ensure paths use `mitsio` not `mitso`

### Files to Create
- `~/.local/share/chezmoi/.config/Claude/claude_desktop_config.json.tmpl`
- Chezmoi data file with variables
- Documentation on updating config

### Deliverables
- [ ] Claude config in chezmoi
- [ ] Secrets properly managed
- [ ] Reproducible across machines
- [ ] Documentation

---

## Dependencies & Prerequisites

### System Requirements
- NixOS/home-manager with flakes enabled
- Go compiler (for Go-based MCPs)
- Node.js (for node2nix)
- Rust toolchain (for Rust MCPs)
- Python 3.12+ (for Python MCPs)

### Nix Packages Needed
- `pkgs.buildGoModule`
- `pkgs.node2nix`
- `pkgs.rustPlatform.buildRustPackage`
- `pkgs.python3Packages.buildPythonPackage`
- `pkgs.fetchFromGitHub`

---

## Risks & Mitigation

### Risk 1: Breaking Existing MCPs
**Mitigation:**
- Test each MCP after installation
- Keep backup of current working config
- Use home-manager generations for rollback

### Risk 2: node2nix Complexity
**Mitigation:**
- Start with one npm package (simplest)
- Use semantic-grep to find examples
- Refer to nixpkgs existing node packages

### Risk 3: Model Downloads for semantic-grep
**Mitigation:**
- Use activation script with error handling
- Provide manual download instructions
- Cache models to avoid re-downloading

---

## Success Criteria

- [ ] Semantic-grep installed and working (`w2vgrep` available)
- [ ] All MCPs installed via home-manager in `~/.local-mcp-servers/`
- [ ] Claude Desktop working with new paths
- [ ] Pre-commit hooks running on Nix files
- [ ] Configuration reproducible via `home-manager switch`
- [ ] All changes committed to git

---

## Testing Strategy

### Integration Testing
- Full home-manager rebuild test
- Verify all packages installed
- Verify all MCPs functional
- Verify Claude Desktop works
- Verify pre-commit hooks active

### Edge Cases
- Test on fresh machine simulation
- Test config rollback
- Test with missing secrets
- Test with network issues (model downloads)

---

## References

- **Main TODO:** [docs/TODO.md](../TODO.md) Section 5
- **Session TODO:** [sessions/home-manager-enchantments-week-48/TODO.md](../../sessions/home-manager-enchantments-week-48/TODO.md)
- **Semantic-grep Docs:** https://github.com/arunsupe/semantic-grep
- **awesome-nix:** https://github.com/nix-community/awesome-nix
- **pre-commit-hooks.nix:** https://github.com/cachix/git-hooks.nix

---

**Last Updated:** 2025-11-30 (migrated to docs/plans/)
**Original Date:** 2025-11-23
**Author:** Claude (with Μήτσο)
