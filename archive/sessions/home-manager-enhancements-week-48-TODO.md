---
status: ARCHIVED
archived_date: 2025-11-30
reason: Content integrated into docs/TODO.md (Section 5: Home-Manager Enhancements)
original_location: sessions/home-manager-enchantments-week-48/TODO.md
---

# Home-Manager Enhancements - TODO

> **ARCHIVED:** This session TODO has been integrated into the master TODO.
> See: [docs/TODO.md](../../TODO.md) - Section 5: Home-Manager Enhancements

**Session:** home-manager-enhancements
**Created:** 2025-11-23
**Status:** ARCHIVED (integrated into TODO.md)

---

## Phase 1: Semantic-Grep Installation

### 1.1 Create Nix Derivation
- [ ] Research semantic-grep build requirements
  - [ ] Check go.mod for Go version
  - [ ] Identify build dependencies
  - [ ] Determine vendorHash (may need to build once to get hash)
- [ ] Create `semantic-grep.nix` file
  - [ ] Use `pkgs.buildGoModule`
  - [ ] Set proper source (fetchFromGitHub)
  - [ ] Configure build flags if needed
  - [ ] Set mainProgram = "w2vgrep"
- [ ] Get correct source hash
  - [ ] Run nix-prefetch-github or let Nix tell us
  - [ ] Update sha256 in derivation

### 1.2 Model Management
- [ ] Research word embedding models
  - [ ] Identify recommended model (GoogleNews-slim)
  - [ ] Determine model size and download source
  - [ ] Check license compatibility
- [ ] Create model download mechanism
  - [ ] Write activation script to download model
  - [ ] Store in `~/.config/semantic-grep/models/`
  - [ ] Handle model verification
- [ ] Create config.json template
  - [ ] Set default model path
  - [ ] Configure via home.file

### 1.3 Integration
- [ ] Import semantic-grep.nix in home.nix
- [ ] Test build: `home-manager build --flake .#mitsio@shoshin`
- [ ] Test installation: `home-manager switch --flake .#mitsio@shoshin`
- [ ] Verify w2vgrep command available
- [ ] Test semantic search functionality

### 1.4 Documentation
- [ ] Create `docs/tools/semantic-grep/` directory
- [ ] Write README.md with:
  - [ ] Installation instructions
  - [ ] Usage examples
  - [ ] Model management guide
  - [ ] Troubleshooting
- [ ] Create navi cheatsheets in chezmoi repo
  - [ ] Basic search commands
  - [ ] Model management commands
  - [ ] Advanced usage patterns

---

## Phase 2: MCP Servers Reorganization

### 2.1 Research & Planning
- [ ] Use semantic-grep to find node2nix documentation
  - [ ] Search in docs repo
  - [ ] Search in nixpkgs
  - [ ] Find working examples
- [ ] Document node2nix workflow
- [ ] Create MCP packaging strategy doc

### 2.2 Setup MCP Directory Structure
- [ ] Create `home-manager/mcps/` directory
- [ ] Create `~/.local-mcp-servers/` via activation script
- [ ] Define per-MCP subdirectory template

### 2.3 npm-based MCPs (node2nix)
#### 2.3.1 context7-mcp
- [ ] Research package: `@upstash/context7-mcp`
- [ ] Generate node-packages.nix with node2nix
- [ ] Create context7-mcp.nix derivation
- [ ] Install to `~/.local-mcp-servers/context7-mcp/`
- [ ] Create config template if needed
- [ ] Test functionality

#### 2.3.2 firecrawl-mcp
- [ ] Research package: `firecrawl-mcp`
- [ ] Generate node-packages.nix
- [ ] Create firecrawl-mcp.nix derivation
- [ ] Install to `~/.local-mcp-servers/firecrawl-mcp/`
- [ ] Handle API key configuration
- [ ] Test functionality

#### 2.3.3 mcp-read-website-fast
- [ ] Research package: `@just-every/mcp-read-website-fast`
- [ ] Generate node-packages.nix
- [ ] Create mcp-read-website-fast.nix derivation
- [ ] Install to `~/.local-mcp-servers/mcp-read-website-fast/`
- [ ] Test functionality

### 2.4 Go-based MCPs (buildGoModule)
#### 2.4.1 git-mcp-go
- [ ] Create git-mcp-go.nix
  - [ ] Use buildGoModule
  - [ ] Source: github.com/tak-bro/git-mcp-go
  - [ ] Get vendorHash
- [ ] Install to `~/.local-mcp-servers/git-mcp-go/`
- [ ] Test with git repositories

#### 2.4.2 mcp-filesystem-server
- [ ] Create mcp-filesystem-server.nix
  - [ ] Use buildGoModule
  - [ ] Source: github.com/mark3labs/mcp-filesystem-server
  - [ ] Get vendorHash
- [ ] Install to `~/.local-mcp-servers/mcp-filesystem-server/`
- [ ] Configure allowed directories
- [ ] Test filesystem operations

#### 2.4.3 mcp-shell
- [ ] Create mcp-shell.nix
  - [ ] Use buildGoModule
  - [ ] Source: github.com/punkpeye/mcp-shell
  - [ ] Get vendorHash
- [ ] Install to `~/.local-mcp-servers/mcp-shell/`
- [ ] Configure security.yaml
- [ ] Test shell commands

### 2.5 Rust-based MCPs (buildRustPackage)
#### 2.5.1 rust-mcp-filesystem
- [ ] Create rust-mcp-filesystem.nix
  - [ ] Use rustPlatform.buildRustPackage
  - [ ] Source: github.com/rust-mcp-stack/rust-mcp-filesystem
  - [ ] Get cargoHash
- [ ] Install to `~/.local-mcp-servers/rust-mcp-filesystem/`
- [ ] Configure allowed directories
- [ ] Test filesystem operations
- [ ] Compare with Go mcp-filesystem-server

### 2.6 Python/uv-based MCPs
#### 2.6.1 mcp-server-fetch
- [ ] Research Python package structure
- [ ] Create mcp-server-fetch.nix
  - [ ] Use buildPythonPackage or keep uv with wrapper
  - [ ] Handle dependencies
- [ ] Install to `~/.local-mcp-servers/mcp-server-fetch/`
- [ ] Test URL fetching

#### 2.6.2 mcp-server-time
- [ ] Create mcp-server-time.nix
- [ ] Install to `~/.local-mcp-servers/mcp-server-time/`
- [ ] Configure timezone (Europe/Athens)
- [ ] Test time operations

#### 2.6.3 sequential-thinking
- [ ] Create sequential-thinking.nix
- [ ] Install to `~/.local-mcp-servers/sequential-thinking/`
- [ ] Test thinking process functionality

### 2.7 Integration
- [ ] Create `mcps/default.nix` to import all MCP derivations
- [ ] Import in home.nix
- [ ] Create activation script for directory setup
- [ ] Test full home-manager rebuild
- [ ] Verify all MCPs accessible

### 2.8 Claude Desktop Configuration
- [ ] Update `claude_desktop_config.json` with new paths
  - [ ] Update all `command` paths to ~/.local-mcp-servers/<mcp>/bin/
  - [ ] Update all `PATH` env vars
  - [ ] Verify all repository paths use `mitsio` not `mitso`
- [ ] Backup current config
- [ ] Test Claude Desktop with new config
- [ ] Verify each MCP loads correctly
- [ ] Test MCP functionality in Claude Desktop

---

## Phase 3: Pre-commit Hooks Setup

### 3.1 Research
- [ ] Review pre-commit-hooks.nix documentation
- [ ] Review awesome-nix pre-commit section
- [ ] Identify recommended Nix formatters/linters
- [ ] Check existing git-hooks.nix usage

### 3.2 Implementation
- [ ] Add pre-commit-hooks.nix to flake inputs
- [ ] Create pre-commit.nix configuration
  - [ ] Configure nixfmt or alejandra
  - [ ] Configure statix linter
  - [ ] Configure deadnix
  - [ ] Add custom checks if needed
- [ ] Create .pre-commit-config.yaml
- [ ] Add to home.nix imports

### 3.3 Testing
- [ ] Install hooks: `pre-commit install`
- [ ] Test on sample Nix file
- [ ] Verify auto-formatting works
- [ ] Verify linting catches issues
- [ ] Test commit workflow

### 3.4 Documentation
- [ ] Update home-manager README
- [ ] Document pre-commit commands
- [ ] Add troubleshooting section

---

## Phase 4: Claude Desktop Config Management

### 4.1 Chezmoi Setup
- [ ] Review chezmoi documentation
- [ ] Check current chezmoi structure
- [ ] Plan secrets management strategy

### 4.2 Template Creation
- [ ] Create `.config/Claude/` in chezmoi source
- [ ] Convert config to template
  - [ ] Extract API keys (Firecrawl, Context7)
  - [ ] Parameterize MCP paths
  - [ ] Parameterize repository paths
  - [ ] Use chezmoi variables

### 4.3 Secrets Management
- [ ] Decide: KeePassXC vs age encryption
- [ ] If KeePassXC:
  - [ ] Store API keys in vault
  - [ ] Create chezmoi script to fetch from vault
- [ ] If age:
  - [ ] Create encrypted secrets file
  - [ ] Configure chezmoi to decrypt
- [ ] Test secret retrieval

### 4.4 Integration
- [ ] Apply chezmoi template
- [ ] Verify generated config
- [ ] Test Claude Desktop launches
- [ ] Test all MCPs load
- [ ] Verify secrets work

### 4.5 Documentation
- [ ] Document chezmoi workflow
- [ ] Document secret management
- [ ] Document config updates process
- [ ] Create recovery procedure

---

## Testing & Validation

### Integration Testing
- [ ] Full home-manager rebuild test
- [ ] Verify all packages installed
- [ ] Verify all MCPs functional
- [ ] Verify Claude Desktop works
- [ ] Verify pre-commit hooks active

### Edge Cases
- [ ] Test on fresh machine simulation
- [ ] Test config rollback
- [ ] Test with missing secrets
- [ ] Test with network issues (model downloads)

---

## Documentation

### Code Documentation
- [ ] Comment all Nix derivations
- [ ] Document custom functions
- [ ] Add inline explanations for complex logic

### User Documentation
- [ ] Update home-manager README
- [ ] Create semantic-grep docs
- [ ] Create MCP management guide
- [ ] Create troubleshooting guide

### Cheatsheets
- [ ] Navi cheatsheets for semantic-grep
- [ ] Navi cheatsheets for MCP management
- [ ] Navi cheatsheets for home-manager operations

---

## Git & Version Control

- [ ] Commit changes incrementally
- [ ] Write descriptive commit messages
- [ ] Tag stable versions
- [ ] Push to remote
- [ ] Create PR if using branches

---

## Cleanup

- [ ] Remove old local-mcp-servers.nix (replaced by mcps/)
- [ ] Remove deprecated files
- [ ] Clean up test files
- [ ] Archive old configs

---

**Progress:** 0/150+ tasks completed

**Next Action:** Start Phase 1.1 - Create semantic-grep Nix derivation
