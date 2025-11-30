---
status: ARCHIVED
archived_date: 2025-11-30
reason: Content integrated into docs/TODO.md (Section 5: Home-Manager Enhancements)
original_location: sessions/home-manager-enchantments-week-48/PLAN.md
---

# Home-Manager Enhancements Plan

> **ARCHIVED:** This session plan has been integrated into the master TODO.
> See: [docs/TODO.md](../../TODO.md) - Section 5: Home-Manager Enhancements

**Session:** home-manager-enhancements
**Date:** 2025-11-23
**Status:** ARCHIVED (integrated into TODO.md)
**Goal:** Properly integrate tools, MCPs, and quality assurance into home-manager with declarative configuration

---

## Overview

This session aims to enhance the home-manager configuration with:
1. **Semantic-grep** - Semantic search tool for finding docs and code
2. **MCP Servers** - Reorganize all MCP servers into `~/.local-mcp-servers/` with proper Nix installation
3. **Pre-commit Hooks** - Add pre-commit-hooks.nix for Nix code quality
4. **Claude Desktop Config** - Make Claude Desktop config declarative via chezmoi

---

## Phase 1: Semantic-Grep Installation

### Objective
Install semantic-grep via home-manager using proper Nix derivation with all dependencies.

### Implementation Details

**Tool Info:**
- **Repo:** https://github.com/arunsupe/semantic-grep
- **Language:** Go
- **Binary Name:** `w2vgrep`
- **Dependencies:**
  - Go compiler (build-time)
  - Word2Vec embedding model (runtime)

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
- `~/.MyHome/MySpaces/my-modular-workspace/home-manager/semantic-grep.nix`
- Model download activation script
- Config file at `~/.config/semantic-grep/config.json`

### Deliverables
1. ✅ Nix derivation for semantic-grep
2. ✅ Model download automation
3. ✅ Documentation at `docs/tools/semantic-grep/`
4. ✅ Navi cheatsheets in chezmoi repo

---

## Phase 2: MCP Servers Reorganization

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
- `~/.MyHome/MySpaces/my-modular-workspace/home-manager/mcps/` (directory)
  - `context7-mcp.nix`
  - `firecrawl-mcp.nix`
  - `mcp-read-website-fast.nix`
  - `git-mcp-go.nix`
  - `mcp-filesystem-server.nix`
  - `mcp-shell.nix`
  - `rust-mcp-filesystem.nix`
  - `mcp-server-fetch.nix`
  - `mcp-server-time.nix`
  - `sequential-thinking.nix`
  - `default.nix` (imports all)

### Deliverables
1. ✅ All MCPs installed via home-manager
2. ✅ Organized in `~/.local-mcp-servers/`
3. ✅ Single source of truth in Nix configuration
4. ✅ Updated Claude Desktop config with new paths
5. ✅ Tested and verified all MCPs working

---

## Phase 3: Pre-commit Hooks Setup

### Objective
Add pre-commit-hooks.nix to home-manager for automatic Nix code quality checks.

### Tools to Integrate

**From awesome-nix research:**
- **nixfmt** - Official Nix code formatter
- **statix** - Linter to check for antipatterns
- **deadnix** - Find dead/unused code
- **alejandra** - Alternative formatter (evaluate vs nixfmt)

### Implementation
- Add `pre-commit-hooks.nix` from cachix/git-hooks.nix
- Create `.pre-commit-config.yaml` for home-manager repo
- Configure hooks for:
  - Nix formatting
  - Nix linting
  - Dead code detection
  - Syntax validation

### Files to Create
- Add to `home-manager/flake.nix` or create `pre-commit.nix`
- `.pre-commit-config.yaml` in home-manager root
- Documentation in home-manager README

### Deliverables
1. ✅ Pre-commit hooks configured
2. ✅ Auto-run on git commit
3. ✅ Integration with home-manager workflow
4. ✅ Documentation for team members

---

## Phase 4: Claude Desktop Config Management

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
1. **Move config to chezmoi template**
   - Create `.config/Claude/` in chezmoi source
   - Template with `{{ .mcpServers }}` or similar

2. **Secret Management**
   - Extract API keys (Firecrawl, Context7)
   - Store in KeePassXC or age-encrypted file
   - Reference in template via chezmoi secrets

3. **Dynamic Path Resolution**
   - Use chezmoi variables for MCP paths
   - Reference `~/.local-mcp-servers/` structure
   - Ensure paths use `mitsio` not `mitso`

### Files to Create
- `~/.local/share/chezmoi/.config/Claude/claude_desktop_config.json.tmpl`
- Chezmoi data file with variables
- Documentation on updating config

### Deliverables
1. ✅ Claude config in chezmoi
2. ✅ Secrets properly managed
3. ✅ Reproducible across machines
4. ✅ Documentation

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

- [ ] Semantic-grep installed and working
- [ ] All MCPs installed via home-manager
- [ ] MCPs organized in `~/.local-mcp-servers/`
- [ ] Claude Desktop config working with new paths
- [ ] Pre-commit hooks running on Nix files
- [ ] Configuration reproducible via `home-manager switch`
- [ ] Documentation complete
- [ ] All changes committed to git

---

## Timeline Estimate

- **Phase 1 (Semantic-grep):** 2-3 hours
- **Phase 2 (MCP Reorganization):** 4-6 hours
- **Phase 3 (Pre-commit Hooks):** 1-2 hours
- **Phase 4 (Claude Config):** 1-2 hours
- **Total:** 8-13 hours

---

## Notes

- Use semantic-grep once installed to search for node2nix examples
- Refer to https://github.com/nix-community/awesome-nix for best practices
- Test incrementally - don't change everything at once
- Keep detailed notes of what works/doesn't work

---

**Last Updated:** 2025-11-23
**Author:** Claude (with Μήτσο)
