# Master TODO - My Modular Workspace

**Project:** my-modular-workspace
**Last Updated:** 2025-12-06
**Current Phase:** MCP Servers Declarative Migration (ADR-010) + Home-Manager Enhancements (Week 49)
**Working Directory:** `/home/mitsio/.MyHome/MySpaces/my-modular-workspace/`

---

## 📍 Purpose

This is the **MASTER TODO** consolidating all tasks across the my-modular-workspace project.

**Component-Specific Details:**
- **Home-Manager:** `home-manager/TODO.md` - Detailed package management tasks
- **Ansible:** `docs/ANSIBLE_TODO.md` - Automation and playbook tasks
- **NixOS:** `hosts/shoshin/nixos/TODO.md` - System configuration tasks
- **Docs:** `docs/TODO.md` - Documentation and cross-cutting tasks
- **Sessions:** `sessions/*/TODO.md` - Session-specific tasks

---

## 🔴 IMMEDIATE PRIORITY (Week 48-49 - Nov 24 - Dec 6, 2025)

### 0. NixOS Config Refactoring 🆕

**Status:** PLANNING
**Priority:** CRITICAL
**Estimated Time:** 4-6 hours
**Documentation:**
- Plan: `docs/nixos/PLAN_REFFACTORING_NIXOS_CONFIG.md` (to create)
- Best Practices: `docs/nixos/BEST_PRACTICES.md` (to create)

#### Phase 1: Migration Analysis (NixOS → Home-Manager)
- [ ] Read ALL .nix files in nixos repo (`hosts/shoshin/nixos/`)
- [ ] Read documentation under `docs/nixos/` and `docs/home-manager/`
- [ ] Identify user-level services that should be in home-manager
- [ ] Identify user-level packages that should be in home-manager
- [ ] Present numbered list of potential migrations to user
- [ ] Get user confirmation on which migrations to perform
- [ ] Document migration plan in `PLAN_REFFACTORING_NIXOS_CONFIG.md`

**Candidates for Review:**
1. `hosts/shoshin/nixos/home/mitsio/*` - LIKELY REMOVE (duplicates in standalone home-manager)
2. `modules/workspace/packages.nix` - Review for user-level packages
3. `modules/development/*` - Review for user-level tools
4. `modules/workspace/dropbox.nix` - Already in home-manager
5. `modules/workspace/themes.nix` - Could be home-manager
6. `modules/workspace/firefox.nix` - Could be home-manager
7. `modules/workspace/brave-fixes.nix` - Could be home-manager

#### Phase 2: Dead Code Removal
- [ ] Use grep/ast-grep to find unused imports
- [ ] Identify commented-out code (`rclone.nix`, `rclone-bisync.nix`, `syncthing-myspaces.nix`)
- [ ] Find deprecated configurations
- [ ] Plan safe removal of dead code
- [ ] Document findings in `PLAN_REFFACTORING_NIXOS_CONFIG.md`

**Known Dead Code:**
- `modules/workspace/rclone.nix` - DISABLED (moved to home-manager)
- `modules/workspace/rclone-bisync.nix` - DISABLED (moved to home-manager)
- `modules/workspace/syncthing-myspaces.nix` - DISABLED (moved to home-manager)
- `home/mitsio/*` - POTENTIALLY ALL (standalone home-manager has these)

#### Phase 3: Best Practices Research
- [ ] Web search: "NixOS flake configuration best practices 2025"
- [ ] Web search: "NixOS modular configuration structure"
- [ ] Web search: "NixOS home-manager integration patterns"
- [ ] Document findings in `docs/nixos/BEST_PRACTICES.md`
- [ ] Update PLAN to incorporate best practices

#### Phase 4: Plan Review & Enhancement
- [ ] Re-read entire refactoring plan
- [ ] Identify weaknesses and gaps
- [ ] Add missing steps for completeness
- [ ] Make plan executable by agent (clear instructions)
- [ ] Add context requirements for new sessions

#### Phase 5: Execution
- [ ] Follow the plan step by step
- [ ] Test after each change (`nix flake check`)
- [ ] Commit changes incrementally
- [ ] Document any issues encountered
- [ ] Final verification: `nixos-rebuild switch`

**Files to Read (in order):**
```
# ADRs (Architecture Decisions)
docs/adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md
docs/adrs/ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md
docs/adrs/ADR-003-ANSIBLE_COLLECTIONS_VIA_HOME_MANAGER.md
docs/adrs/ADR-004-MIGRATE_RCLONE_AUTOMATION_TO_ANSIBLE.md

# NixOS Repo (ALL FILES)
hosts/shoshin/nixos/flake.nix
hosts/shoshin/nixos/configuration.nix
hosts/shoshin/nixos/hosts/shoshin/configuration.nix
hosts/shoshin/nixos/hosts/shoshin/hardware-configuration.nix
hosts/shoshin/nixos/modules/common.nix
hosts/shoshin/nixos/modules/common/security.nix
hosts/shoshin/nixos/modules/system/*.nix
hosts/shoshin/nixos/modules/workspace/*.nix
hosts/shoshin/nixos/modules/development/*.nix
hosts/shoshin/nixos/modules/platform/*.nix
hosts/shoshin/nixos/home/mitsio/*.nix

# Home-Manager Repo (for comparison)
home-manager/flake.nix
home-manager/home.nix
home-manager/*.nix

# Migration Documentation
docs/nixos/MIGRATION_PLAN.md
docs/home-manager/NIXOS_CONFIG_MIGRATION_PLAN.md
docs/home-manager/MIGRATION_FINDINGS.md
```

**Success Criteria:**
- ✅ No duplicate configs between NixOS and home-manager
- ✅ All dead/commented code removed
- ✅ Best practices documented and applied
- ✅ Clean, modular structure
- ✅ All tests pass (`nix flake check`)
- ✅ System builds successfully

---

### 1. Git Repository Commits & Cleanup

**Status:** IN PROGRESS

#### home-manager repository
- [ ] Commit modified `home.nix` (service cleanup changes)
- [ ] Add and commit untracked files:
  - [ ] `ansible-backup.nix`
  - [ ] `ansible-collections.nix`
  - [ ] `chezmoi.nix`
  - [ ] `continue-dot-dev.nix`
  - [ ] `git-hooks.nix`
  - [ ] `navi.nix`
- [ ] Clean up: `.ansible/` and `.cache/` directories (add to .gitignore)
- [ ] Push all commits to origin/main

#### docs repository
- [ ] Stage and commit deleted Archive files (KDE_Connect, Plasma_Manager)
- [ ] Add commit message: "Archive cleanup: Moved KDE Connect and Plasma Manager docs to deprecated"
- [ ] Push to origin/main

#### ansible repository
- [ ] Commit deleted files (.navi/, TODO.md, docs/development/pre-commit-setup.md)
- [ ] Commit modified: logs/ansible.log, playbooks/gdrive-backup.yml, playbooks/rclone-gdrive-sync.yml
- [ ] Add untracked: playbooks/rclone-gdrive-sync-v2.yml, templates/
- [ ] Review logs before committing (exclude if too large)
- [ ] Push to origin/main

### 2. Post Home-Manager Switch Verification (Gen #46)

**Completed:** 2025-11-23
**Remaining:**
- [ ] Test Firefox with new symlink structure
- [ ] Verify VSCodium extensions loading correctly
- [ ] Confirm KeePassXC vault accessible at `~/MyVault`
- [ ] Check all symlinked directories work: `MySpaces`, `Documents`, `Archives`
- [ ] Review `.backup` files, delete if everything works
- [ ] Document findings in `home-manager/docs/DEBUGGING_AND_MAINTENANCE.md`

### 3. Master TODO Maintenance

- [x] Create MASTER_TODO.md consolidating all TODOs
- [ ] Update all component TODOs to reference MASTER_TODO.md
- [ ] Establish update protocol: when to sync MASTER_TODO with component TODOs

---

## 🟡 HIGH PRIORITY (This Month - November 2025)

### 4. Continue.dev Integration (Week 48) 🆕

**Status:** Research Complete | Ready for Installation
**Documentation:** `docs/commons/tools/continue.dev/`
**Plan:** `docs/commons/tools/continue.dev/PLAN.md`
**Priority:** HIGH
**Estimated Time:** 3-4 hours

#### Phase 1: Research & Documentation ✅ COMPLETE (2025-11-26)
- [x] Research Continue.dev architecture and capabilities
- [x] Investigate VSCodium compatibility (Open VSX lag issues)
- [x] Identify NixOS-specific issues (#821, Discourse #36652)
- [x] Document API configuration for Claude Max + ChatGPT
- [x] Research prompt caching for cost optimization
- [x] Create comprehensive documentation suite:
  - [x] README.md (Overview and quick start)
  - [x] INSTALLATION.md (NixOS-specific installation guide)
  - [x] CONFIGURATION.md (Complete config.yaml examples)
  - [x] API_KEYS.md (Secure key management with KeePassXC)
  - [x] PLAN.md (Detailed implementation plan)

#### Phase 2: Installation (NEXT)
- [ ] Download latest VSIX from GitHub releases
- [ ] Install extension in VSCodium (`codium --install-extension`)
- [ ] Verify extension loads without errors
- [ ] Test for NixOS compatibility issues
- [ ] Apply FHS wrapper if needed (documented in INSTALLATION.md)
- [ ] Confirm Continue sidebar appears and activates

#### Phase 3: API Key Setup
- [ ] Obtain Anthropic API key from console.anthropic.com
- [ ] Obtain OpenAI API key from platform.openai.com
- [ ] Store both keys in KeePassXC vault
  - [ ] Create entries in Development/APIs/ group
  - [ ] Label: "Anthropic API - Claude Max" and "OpenAI API - ChatGPT"
- [ ] Set environment variables (temporary for testing)
- [ ] Test API connectivity with curl commands
- [ ] Document in permanent location (bashrc or chezmoi template)

#### Phase 4: Configuration
- [ ] Create ~/.continue/config.yaml with dual-provider setup:
  - [ ] Claude 4 Sonnet (chat, edit roles)
  - [ ] GPT-4o (chat fallback)
  - [ ] Claude Haiku (autocomplete - fast/cheap)
  - [ ] OpenAI Embeddings (codebase search)
- [ ] Enable prompt caching for Claude (cost optimization)
- [ ] Validate YAML syntax
- [ ] Reload configuration in Continue.dev
- [ ] Verify all models appear in selector

#### Phase 5: Testing & Verification
- [ ] Test chat with Claude 4 Sonnet
- [ ] Test chat with GPT-4o
- [ ] Test inline code editing (Ctrl+I)
- [ ] Test autocomplete functionality
- [ ] Verify prompt caching working (check Anthropic console)
- [ ] Monitor API usage and costs
- [ ] Test all Continue.dev features comprehensively

#### Phase 6: Home-Manager Integration
- [ ] Create continue-dev.nix module
- [ ] Move config.yaml to dotfiles/continue/
- [ ] Set up symlink via home.file
- [ ] Add environment variable placeholders (no real keys!)
- [ ] Add to home.nix imports
- [ ] Test home-manager build
- [ ] Apply with home-manager switch
- [ ] Verify declarative configuration works

#### Phase 7: Documentation & Cleanup
- [ ] Update this TODO.md with completion status
- [ ] Document any NixOS-specific fixes applied
- [ ] Create summary of installation experience
- [ ] Commit all changes to git:
  - [ ] Documentation files
  - [ ] continue-dev.nix module
  - [ ] config.yaml template
- [ ] Push to remote repository

**Success Criteria:**
- ✅ Continue.dev extension active in VSCodium
- ✅ Both Claude Max and ChatGPT accessible
- ✅ Prompt caching reducing API costs
- ✅ Configuration managed declaratively
- ✅ No secrets in git
- ✅ Fully documented and reproducible

---

### 5. Home-Manager Enhancements (Week 48-49)

**Status:** IN PROGRESS
**Goal:** Integrate tools, MCPs, and quality assurance into home-manager declaratively
**Estimated Time:** 8-13 hours total

---

#### Phase 1: Semantic Search Tools Installation (3-5 hours total)

**Goal:** Install 3 semantic search tools for local code/docs discovery
**Status:** NOT INSTALLED (config files exist but not activated)
**Plan:** `docs/plans/plan-installing-semantic-tools.md`
**Session:** `sessions/local-semantic-tools-week-49/`
**Tool Docs:** `docs/tools/{semtools,semantic-grep,ck}.md`

**Installation Order:** semtools → semantic-grep → evaluate ck

---

##### 1.1 Semtools Installation ✅ COMPLETE

**Tool:** https://github.com/run-llama/semtools
**Binary:** `search`, `parse` (nixpkgs v1.2.0 - `workspace` and `ask` only in upstream v1.5.0)
**Status:** ✅ COMPLETE - Installed, Tested, Working
**Docs:** `docs/tools/semtools.md`
**Phase Status:** `sessions/local-semantic-tools-week-49/PHASE1_SEMTOOLS_STATUS.md`
**Completed:** 2025-12-05

**Tasks:**
- [x] Create `home-manager/semtools.nix` module
- [x] Add semtools package (v1.2.0 from nixpkgs)
- [x] Configure SEMTOOLS_WORKSPACE=myspaces environment variable (via sessionVariables)
- [ ] Add shell aliases to chezmoi's dot_bashrc.tmpl (deferred - optional)
- [x] Create .semtools_config.json (empty, for future API keys)
- [x] Import in home.nix
- [x] Apply: `home-manager switch --flake .#mitsio@shoshin -b backup`
- [x] Verify: `search --version` → semtools 1.2.0 ✅
- [x] Model downloaded manually (507MB total in HuggingFace cache)
- [x] Test basic search → Works! (relevance 0.47)
- [x] Test MySpaces search → Works! (5 matches, relevance 0.28-0.31)

**Performance:**
- First run: 2-3 min (model loading - normal)
- Subsequent: < 2 sec (cached)

**Success Criteria:**
- ✅ Package installed (semtools 1.2.0)
- ✅ Config file created
- ✅ Environment variable configured
- ✅ Model downloaded and cached
- ✅ Search command functional and tested
- ✅ MySpaces semantic search working excellently

---

##### 1.2 Semantic-Grep Installation ✅ COMPLETE

**Tool:** https://github.com/arunsupe/semantic-grep
**Binary:** `semantic-grep` (NOT `w2vgrep` - documentation outdated)
**Status:** ✅ COMPLETE - Installed, Tested, Working
**Nix File:** `home-manager/semantic-grep.nix`
**Docs:** `docs/tools/semantic-grep.md`
**Phase Status:** `sessions/local-semantic-tools-week-49/PHASE2_SEMANTIC_GREP_STATUS.md`
**Completed:** 2025-12-06

**Tasks:**
- [x] Fix vendorHash in `semantic-grep.nix:26` → `sha256-HpKY5DkP9hRtH9O18irlNE2yd8eTSLogTpYTWR1kbXA=`
- [x] Add `subPackages = ["."]` to fix build error (multiple main functions)
- [x] Import `./semantic-grep.nix` in home.nix
- [x] Apply: `home-manager switch --flake .#mitsio@shoshin -b backup`
- [x] Add declarative model download via activation script
- [x] Model downloaded (346MB uncompressed, 264MB compressed)
- [x] Test: `which semantic-grep && semantic-grep --help` ✅
- [x] Test exact match: Similarity 1.0000 ✅
- [x] Test semantic match: "success" → "successful" (0.6168) ✅
- [ ] Update `.claude/CLAUDE.md` with semantic-grep integration (deferred - optional)
- [ ] Create navi cheatsheets in chezmoi repo (deferred - optional)

**Performance:**
- Model loads into memory on first run
- Semantic word-level matching working excellently
- Threshold tuning: 0.5-0.6 (broad), 0.65-0.7 (moderate), 0.75+ (strict)

**Success Criteria:**
- ✅ Package built and installed (semantic-grep v0.7.0)
- ✅ Config file created at `~/.config/semantic-grep/config.json`
- ✅ Model downloaded declaratively (346MB)
- ✅ Exact matching tested and working
- ✅ Semantic word-level matching tested and working
- ✅ Declarative model installation via home.activation script

**Key Finding:** Binary is `semantic-grep`, not `w2vgrep` as documented upstream

---

##### 1.3 CK Evaluation & Optional Installation ⏸️ DEFERRED

**Tool:** https://github.com/BeaconBay/ck
**Binary:** `ck`
**Status:** ⏸️ EVALUATION PENDING (deferred until after real-world usage of Phase 1+2)
**Docs:** `docs/tools/ck.md`

**Recommendation:** Test semtools + semantic-grep in daily workflow for 1-2 weeks, then evaluate if ck is needed.

**Evaluation Criteria (answer BEFORE installing):**
- [ ] Do semtools + semantic-grep cover your needs? (TEST FIRST)
- [ ] Do you need interactive TUI search?
- [ ] Do you need hybrid search (semantic + BM25)?
- [ ] Do you want built-in MCP server?

**If YES to TUI/hybrid/MCP after testing:**
- [ ] Install via cargo: `cargo install ck-search`
- [ ] Index MySpaces: `cd ~/.MyHome/MySpaces/my-modular-workspace && ck --index .`
- [ ] Test semantic: `ck --sem "kubernetes" docs/`
- [ ] Test hybrid: `ck --hybrid "ansible playbook" .`
- [ ] Test TUI: `ck --tui`
- [ ] Update `.claude/CLAUDE.md` with ck integration

**If NO to above criteria after testing:**
- [ ] Mark Phase 3 as SKIPPED - semtools + semantic-grep sufficient

**Success Criteria (if installed):**
- All 3 search modes work (sem/hybrid/regex)
- TUI launches and is navigable
- Index builds and persists in `.ck/` directories

**Current Decision:** DEFERRED - Use Phase 1+2 tools first, evaluate later

---

#### Phase 2: MCP Servers Declarative Migration (ADR-010) 🔄 IN PROGRESS

**Goal:** Migrate ALL MCP servers to Nix packages via Home-Manager (ADR-010)
**Status:** Phases 0-2 COMPLETE ✅ | Phase 3 IN PROGRESS | Phases 4-5 PENDING
**ADR:** `docs/adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md`
**Research:** `docs/researches/2025-12-06_NIX_MCP_SERVERS_PACKAGING_RESEARCH.md`
**Session:** `sessions/summaries/12-06-2025_SUMMARY_MCP_SERVERS_DECLARATIVE_MIGRATION_SESSION.md`
**Last Updated:** 2025-12-11

##### Key Discovery: natsukium/mcp-servers-nix Flake ✅
- [x] Added flake input to home-manager/flake.nix
- [x] Pre-built packages available for many MCP servers
- [x] Created `home-manager/mcp-servers/default.nix` and `from-flake.nix`

##### 2.1 Phase 0: Infrastructure ✅ COMPLETE (2025-12-06)
- [x] Add `natsukium/mcp-servers-nix` as flake input
- [x] Create `home-manager/mcp-servers/` directory structure
- [x] Create `mcp-servers/default.nix` (main importer)
- [x] Create `mcp-servers/from-flake.nix` (flake packages with wrappers)
- [x] Fix context7-mcp conflict (removed from local-mcp-servers.nix)

##### 2.2 Phase 1: Flake-Based Servers ✅ COMPLETE (2025-12-06)
**Using natsukium/mcp-servers-nix packages:**
- [x] **context7-mcp** - Library documentation lookup
- [x] **mcp-server-sequential-thinking** - Deep reasoning
- [x] **mcp-server-fetch** - Web content fetching
- [x] **mcp-server-time** - Timezone operations (Europe/Athens)
- [x] Created systemd wrapper scripts with resource isolation
- [x] Build and activation successful

##### 2.3 Phase 2: Custom NPM Derivations ✅ COMPLETE (2025-12-11)
**Using buildNpmPackage/stdenv.mkDerivation in `mcp-servers/npm-custom.nix`:**
- [x] **firecrawl-mcp** v3.2.1 - Web scraping (buildNpmPackage)
- [x] **exa-mcp-server** v3.1.3 - Exa AI search (stdenv.mkDerivation with pre-built npm tarball)
- [x] **brave-search-mcp** v0.8.0 - Brave Search (mikechao alternative - buildNpmPackage)
- [x] **mcp-read-website-fast** v0.1.20 - Fast web reading (buildNpmPackage)

**Key Solution for exa-mcp-server:**
- npm tarball contains pre-built `.smithery/stdio/index.cjs` (fully bundled)
- Used `stdenv.mkDerivation` instead of `buildNpmPackage` to bypass smithery dynamic deps
- No npm install needed - just extract and wrap with Node.js

##### 2.4 Phase 3: Custom Python Derivations ✅ COMPLETE (2025-12-11)
**Using stdenv.mkDerivation + python3.withPackages in `mcp-servers/python-custom.nix`:**
- [x] **claude-thread-continuity** v1.1.0 (github.com/peless/claude-thread-continuity) - ✅ WORKING
  - [x] Created derivation using stdenv.mkDerivation + python3.withPackages
  - [x] Depends on: mcp>=1.0.0, pydantic>=2.0.0
  - [x] Data storage: declarative symlink `~/.claude_states/` -> `~/.MyHome/MySpaces/random-space/mcps-common-space/claude-thread-continuity`
- [x] **ast-grep-mcp** v0.1.0 (github.com/ast-grep/ast-grep-mcp) - ✅ WORKING
  - [x] Created derivation using stdenv.mkDerivation + python3.withPackages
  - [x] Depends on: mcp[cli]>=1.6.0, pydantic>=2.11.0, pyyaml>=6.0.2
  - [x] Requires: ast-grep CLI (added to PATH in wrapper)

##### 2.5 Phase 4: Custom Rust Derivations ⏳ IN PROGRESS (2025-12-11)

**Pre-requisite: Add rust-overlay to flake.nix**
- [ ] Add `rust-overlay` flake input (github:oxalica/rust-overlay)
- [ ] Pass `rust-overlay` via `extraSpecialArgs`
- [ ] Verified: nixpkgs Rust is 1.86.0, ck requires 1.88.0+

**ck-search MCP Server:**
- [ ] **ck** v0.7.1 (github.com/BeaconBay/ck) - Local semantic & hybrid search with MCP server
  - [ ] Create `mcp-servers/rust-custom.nix`
  - [ ] Use rustPlatform.buildRustPackage with rust-overlay Rust 1.88+
  - [ ] Calculate cargoHash for workspace
  - [ ] Handle dependencies: fastembed, tantivy, tree-sitter, rmcp, openssl
  - [ ] MCP Tools: `semantic_search`, `regex_search`, `hybrid_search`, `index_status`, `reindex`, `health_check`
  - [ ] Binary: `ck`, MCP mode: `ck --serve`
  - [ ] Create wrapper script with systemd isolation
  - [ ] Update ~/.claude/mcp_config.json
  - [ ] Test MCP server connection

**Research Findings (2025-12-11):**
- Crate name on crates.io: `ck-search`
- Rust workspace with 9 crates: ck-cli, ck-core, ck-index, ck-engine, ck-chunk, ck-embed, ck-ann, ck-models, ck-tui
- Edition 2024 (requires Rust 1.88.0+)
- Uses `rmcp` for MCP protocol implementation
- TUI support included (ratatui)

##### 2.6 Phase 5: Custom Go Derivations ⏳ PENDING
- [ ] **git-mcp-go** (github.com/tak-bro/git-mcp-go)
- [ ] **mcp-shell** (github.com/punkpeye/mcp-shell)
- [ ] **mcp-filesystem-server** (github.com/mark3labs/mcp-filesystem-server)

##### 2.7 Phase 6: Consolidation & Cleanup ⏳ PENDING
- [ ] Remove runtime installers from `local-mcp-servers.nix`
- [ ] Update chezmoi templates to use Nix-managed binaries
- [ ] Test Claude Desktop with all MCP servers
- [ ] Update Claude Code mcp_config.json
- [ ] Remove uv/npm/go activation scripts for migrated servers

---

#### Phase 3: Pre-commit Hooks Setup (1-2 hours)

**Goal:** Automatic Nix code quality checks on commit
**Reference:** https://github.com/cachix/git-hooks.nix

##### 3.1 Implementation
- [ ] Add pre-commit-hooks.nix to flake inputs
- [ ] Create pre-commit.nix configuration
- [ ] Configure formatters:
  - [ ] nixfmt OR alejandra (evaluate both)
- [ ] Configure linters:
  - [ ] statix (antipattern checker)
  - [ ] deadnix (dead code finder)

##### 3.2 Testing
- [ ] Run `pre-commit install`
- [ ] Test on sample Nix file with issues
- [ ] Verify auto-formatting works
- [ ] Verify linting catches issues

##### 3.3 Documentation
- [ ] Update home-manager/README.md
- [ ] Document pre-commit commands
- [ ] Add troubleshooting section

---

#### Phase 4: Claude Desktop Config Management (1-2 hours)

**Goal:** Make Claude Desktop config declarative via chezmoi

##### 4.1 Chezmoi Template
- [ ] Create `.config/Claude/` in chezmoi source
- [ ] Convert config to template (`claude_desktop_config.json.tmpl`)
- [ ] Parameterize MCP paths with chezmoi variables
- [ ] Ensure all paths use `mitsio`

##### 4.2 Secrets Management
- [ ] Extract API keys (Firecrawl, Context7)
- [ ] Store in KeePassXC vault
- [ ] Create chezmoi script to fetch from vault
- [ ] Test secret retrieval

##### 4.3 Verification
- [ ] Apply chezmoi template
- [ ] Verify generated config is valid JSON
- [ ] Test Claude Desktop launches
- [ ] Test all MCPs load correctly

---

**Success Criteria:**
- [ ] Semantic-grep installed and working (`w2vgrep` available)
- [ ] All MCPs installed via home-manager in `~/.local-mcp-servers/`
- [ ] Claude Desktop working with new MCP paths
- [ ] Pre-commit hooks running on Nix files
- [ ] Configuration reproducible via `home-manager switch`
- [ ] All changes committed to git

### 5. Ansible Repository Setup

**Goal:** Establish ansible as standalone git repository

- [x] Research pre-commit automation (git-hooks.nix)
- [x] Create quality check infrastructure (Makefile, lint configs)
- [ ] Initialize ansible as separate repo: `github.com/dtsioumas/modular-workspace-ansible`
- [ ] Set up branch protection
- [ ] Update my-modular-workspace docs to reference repo

#### RClone Playbook Migration (COMPLETED 2025-11-25)
- [x] Research rolehippie/rclone collection - NOT suitable (S3 only, no bisync)
- [x] Research stefangweichinger/ansible-rclone - NOT suitable (no bisync, downloads binary)
- [x] Decision: Keep custom playbook (NixOS + bisync + systemd timers)
- [x] Improve `rclone-gdrive-sync.yml` playbook structure (variable-driven)
- [x] Fix yamllint and pass quality checks
- [x] Migrate systemd service wrapper to use ansible-playbook
- [x] Add ansible + ansible-lint + yamllint to home.packages
- [x] Run home-manager switch to apply changes (2025-11-29)
- [ ] Test systemd service with ansible playbook
- [ ] Migrate `gdrive-backup.yml` playbook (optional)

#### nix-ld and MCP Servers Fix (COMPLETED 2025-11-29)

**Summary:** `sessions/summaries/29-11-2025_SUMMARY_NIX_LD_MCP_SERVERS_FIX.md`

- [x] Enable `programs.nix-ld.enable = true;` in NixOS configuration
- [x] Run `sudo nixos-rebuild switch` to apply nix-ld
- [x] Fix `sequential-thinking-mcp` package name in local-mcp-servers.nix
- [x] Add `~/.local/bin` to sessionPath for uv tools
- [x] Run successful home-manager switch with all MCP servers
- [x] Update DEBUGGING_AND_MAINTENANCE.md with new error types (sections 6-8)
- [ ] **kubectl-rook-ceph**: Re-enable when nixpkgs-unstable fixes hash mismatch
- [ ] **MyVault.backup**: Clean up symlink backup conflicts
- [ ] **gdrive-monthly-backup.service**: Investigate why service failed

### 6. Kitty Terminal Enhancements

**Status:** PHASE A & B ✅ COMPLETE | PHASE C.1 ✅ COMPLETE | PHASE C.2 🔬 RESEARCH UPDATED 2025-12-07
**Last Completed:** 2025-12-07 03:15 (Session research update)
**Last Updated:** 2025-12-07 03:15 (New research on per-window status bars)
**Goal:** Enhance kitty terminal with advanced features and workflow improvements
**Time Spent:** ~5.5 hours (Phase A: 30m, Phase B: 2h, Phase C.1: 1h, Research: 2.5h)
**Remaining:** 4-6 hours (Phase C.2 + new ideas from sessions)
**Documentation:**
- **Plan (Kittens):** `docs/plans/kitty-kittens-enhancements-plan.md` ⭐ PRIMARY
- Plan (Basic): `docs/plans/kitty-enhancements-plan.md`
- Plan (Zellij): `docs/plans/kitty-zellij-phase1-plan.md`
- Integration (Autocomplete): `docs/integrations/kitty-autocomplete-integration.md`
- Current Config: `dotfiles/dot_config/kitty/kitty.conf`
- Tool Guide: `docs/tools/kitty.md`

**Current State (2025-12-01 20:00):**
- ✅ Kitty 0.42.1 with Dracula theme (switched from Catppuccin Mocha)
- ✅ Configured with transparency (15% = 85% transparent - very transparent), blur (32)
- ✅ Managed via chezmoi at `dotfiles/dot_config/kitty/`
- ✅ **Phase A Complete:** Basic enhancements (right-click paste, navigation, transparency)
- ✅ **Phase B Complete:** Essential kittens (search, git diff, shell integration, ssh)
- ✅ **Phase C.1 Complete:** Panel kitten (F12), theme cycling (Ctrl+Shift+F9)
- ✅ **Tab Navigation Complete:** 4 shortcut options (Alt+Left/Right recommended)
- ✅ **Terminal Helpers Complete:** Navi cheatsheets (kh, khe, ks), daily reminder
- 🔬 **Phase C.2 Research Complete:** Scrollbar, status bar, autocomplete, history export
- ⏳ **Phase C.2 Pending:** Awaiting user clarifications before implementation

---

#### 🔬 Research Findings: Tab Bar + Window Bars (2025-12-07)

**User Question:** Can I have tab bar on TOP and per-window status bars at BOTTOM?

**Research Sources:**
- GitHub Issue #3101: Per-window statusbar API
- GitHub Discussion #9234: Per-tab status bar (Nov 2025)
- Kitty official docs: Tab bar configuration
- Context7 documentation search

**Findings:**

| Feature | Native Support | Status |
|---------|---------------|--------|
| Tab bar at TOP | ✅ YES | `tab_bar_edge top` |
| Tab bar at BOTTOM | ✅ YES | `tab_bar_edge bottom` (default) |
| Per-window status bar | ❌ NO | Workaround: 1-char window + remote control |
| Per-tab status bar | ❌ NO | Use `active_tab_title_template` for active tab only |

**Key Insight from kovidgoyal (kitty author):**
> "For an actual docked status bar it would need issue #2391. As a workaround, implement a status bar as a 1 character high window and populate it with content via send-text."

**Recommended Solution: Kitty + Zellij Architecture**
```
┌─────────────────────────────────────────┐
│ [Tab 1] [Tab 2] [Tab 3]   ← Kitty tab bar (TOP)
├─────────────────────────────────────────┤
│                                         │
│     Terminal content                    │
│     (managed by Zellij panes)           │
│                                         │
├─────────────────────────────────────────┤
│ git:main | ~/path | 15:30  ← Zellij zjstatus (BOTTOM)
└─────────────────────────────────────────┘
```

**Action Items:**
- [x] Move tab bar to top: `tab_bar_edge top` ✅ (2025-12-08)
- [x] Add F2/Shift+F2 for quick tab renaming ✅ (2025-12-08)
- [x] Enable Zellij pane_frames for per-pane titles ✅ (2025-12-08)
- [x] Research: Per-pane BOTTOM status bars ✅ (2025-12-08)
- [ ] Customize active tab template: `active_tab_title_template`
- [ ] **CONSIDER:** tmux for per-pane bottom bars (see research below)

**Research Finding (2025-12-08):** Per-pane BOTTOM status bars
- **Zellij:** Only supports pane titles at TOP (Issue #680 open since 2021)
- **Kitty:** Not supported natively
- **tmux:** ✅ SUPPORTS THIS via `pane-border-status bottom`
- **Reference:** `docs/researches/2025-12-08_PER_PANE_BOTTOM_STATUS_BAR_RESEARCH.md`

**Alternative: tmux Integration**
If per-pane bottom bars are critical, consider tmux instead of zellij:
```bash
# tmux.conf
set -g pane-border-status bottom
set -g pane-border-format " #{pane_index} #{pane_current_command} #{pane_current_path} "
```

---

#### Phase 1 (A): Basic Kitty Enhancements ✅ COMPLETE (2025-12-01)

**Completed:** 2025-12-01
**Reference:** `docs/plans/kitty-enhancements-plan.md`

##### Implemented Features:
- [x] Right-click paste from clipboard
- [x] Ctrl+Alt+Arrow directional window navigation
- [x] Transparency set to 30% (very transparent glass effect)
- [x] Ctrl+/-  for quick transparency adjustment
- [x] Window splitting: Ctrl+Alt+H (horizontal), Ctrl+Alt+V (vertical)
- [x] Window cycling: Ctrl+Tab / Ctrl+Shift+Tab
- [x] VSCodium as default editor
- [x] Enhanced hints kitten (URLs, paths, files, line numbers)
- [x] All changes committed to dotfiles repo

---

#### Phase 1 (B): Essential Kittens & Integrations ✅ COMPLETE (2025-12-01)

**Completed:** 2025-12-01 02:15
**Reference:** `docs/plans/kitty-kittens-enhancements-plan.md`

##### B.1: Search Kitten (Incremental Scrollback Search) ✅
- [x] Installed from github.com/trygveaa/kitty-kitten-search
- [x] Keybinding: Ctrl+Shift+/ for incremental search
- [x] Replaces tmux's `/` search functionality
- [ ] Test: Use Ctrl+Shift+/ in kitty (USER TODO)

##### B.2: Shell Integration ✅
- [x] Enabled full shell integration (changed from no-rc to enabled)
- [x] Ctrl+Shift+Z - Jump to previous command prompt
- [x] Ctrl+Shift+X - Jump to next command prompt
- [x] Ctrl+Shift+G - Show last command output
- [ ] Test: Run commands and use prompt navigation (USER TODO)

##### B.3: Git Diff Integration ✅
- [x] Configured kitty as git difftool
- [x] Side-by-side diffs with syntax highlighting
- [x] Git editor updated to codium
- [ ] Test: Run `git difftool` (USER TODO)

##### B.4: SSH Kitten ✅
- [x] Alias: `ssh="kitty +kitten ssh"`
- [x] Auto-copies terminfo to remote servers
- [x] Fixes "unknown term type" errors
- [ ] Test: SSH to a server (USER TODO)

**Phase B Success Criteria:**
- [x] All features implemented and committed ✅
- [ ] User testing complete (PENDING USER ACTION)

---

#### Phase 1 (C.1): Panel Kitten & Theme Enhancements ✅ COMPLETE (2025-12-01 04:45)

**Completed:** 2025-12-01 04:45

##### Implemented Features:
- [x] Panel kitten configured with F12 for dropdown terminal
- [x] Theme cycling browser (Ctrl+Shift+F9) with 300+ themes
- [x] Dracula theme applied (switched from Catppuccin Mocha)
- [x] Enhanced transparency (0.15 = 85% transparent)
- [x] Alternative panel examples documented
- [ ] F12 panel kitten debugging (USER TO TEST - platform-dependent)

---

#### Phase 1 (C.2): Enhanced Terminal Experience 🔬 RESEARCH COMPLETE (2025-12-01 20:00)

**Status:** Research complete, awaiting user clarifications before implementation
**Scope:** Scrollbar, status bar, right-click, autocomplete, history export, Ctrl+H overlay
**Reference:** `docs/sessions/summaries/01-12-2025_KITTY_SESSION_CONTINUATION_CONTEXT.md`

##### C.2.1: Tab Navigation Enhancements ✅ COMPLETE
- [x] Alt+Left/Right (browser-style) - RECOMMENDED
- [x] Alt+H/L (vim-style)
- [x] Ctrl+PageUp/PageDown (firefox-style)
- [x] Ctrl+Shift+Left/Right (original, kept for compatibility)
- [x] Extended to 9 tabs (Ctrl+Alt+1-9)
- **Status:** Complete, user approved

##### C.2.2: Terminal Shortcuts Helper ✅ COMPLETE
- [x] Navi cheatsheets (basic + extended)
- [x] Bashrc helpers (kh, khe, ks, kitty-shortcuts)
- [x] Daily reminder (non-intrusive, once per day)
- [x] All changes committed
- **Status:** Complete and documented

##### C.2.3: Interactive Scrollbar ✅ IMPLEMENTED (2025-12-01)
- [x] Research complete (native support confirmed)
- [x] Enable interactive scrollbar (`scrollbar scrolled`)
- [x] Configure appearance (opacity 0.6 handle, 0.3 track)
- [x] Added to kitty.conf and committed
- [ ] Test clickability and drag functionality (USER TODO)
- **Estimate:** 15 mins → DONE
- **Status:** Implemented, awaiting user testing

##### C.2.4: Tab Bar Position & Configuration ✅ MOSTLY COMPLETE (2025-12-08)
- [x] Research complete (2025-12-07)
- [x] **Option A:** Move tab bar to TOP (`tab_bar_edge top`) ✅ (2025-12-08)
- [x] Add F2/Shift+F2 for quick tab renaming ✅ (2025-12-08)
- [ ] Customize `active_tab_title_template` for detailed active tab info
- [ ] Optional: Git branch via custom Python `tab_bar.py`
- **Status:** Tab bar at TOP done, template customization pending
- **Reference:** `docs/plans/kitty-advanced-statusbar-plan.md`

##### C.2.5: Terminal History Export 🔬 NEEDS DESIGN
- [ ] User to specify format preferences
- [ ] Design export format (markdown with timestamps)
- [ ] Create export script/kitten
- [ ] Add keyboard shortcut (Ctrl+Shift+H suggested)
- [ ] Test with large scrollback buffers
- **Estimate:** 1 hour
- **Status:** Waiting for user clarification

##### C.2.6: Panel Kitten Debugging (F12) 🐛 NEEDS USER TESTING
- [x] Research complete (platform-dependent)
- [ ] User to test F12 and report results
- [ ] Debug if not working
- [ ] Document platform-specific limitations (KDE Plasma partial support)
- **Estimate:** 30 mins
- **Status:** Waiting for user test results
- **Known:** KDE Plasma has partial support, clicks outside may hide panel

##### C.2.7: Right-Click Menu ❌ NOT POSSIBLE
- [x] Research complete (NOT SUPPORTED by design)
- [x] Documented keyboard shortcuts as alternative
- [ ] User to decide: Keep right-click = paste, or customize?
- **Status:** Cannot implement (kitty philosophy: keyboard-first)
- **Alternative:** Custom mouse_map actions available

##### C.2.8: Autocomplete.sh Integration 🔬 NEEDS DEEP RESEARCH
- [x] Initial research (Atuin integration exists)
- [ ] Web research for best integration approach
- [ ] Test autocomplete.sh with Atuin history
- [ ] Configure LLM backend (requires API keys)
- [ ] Integrate with kitty shell integration
- **Estimate:** 2-3 hours
- **Status:** Needs dedicated research session
- **Repository:** TIAcode/LLMShellAutoComplete

##### C.2.9: Fix Theme Browser Issue 🐛 NEEDS INFO
- [ ] User to describe what broke
- [ ] Fix configuration error
- [ ] Test theme persistence
- **Estimate:** 15-30 mins
- **Status:** Waiting for user to describe the issue

##### C.2.10: Ctrl+H Shortcuts Overlay 📋 PLANNED FOR ZELLIJ PHASE
- [ ] Planned for Zellij Phase 2 (Phase D)
- [ ] Will use zellij floating pane
- [ ] Arrow navigation (up/down = scroll, left/right = switch cheatsheets)
- **Estimate:** 1-2 hours (after zellij setup)
- **Status:** Noted for future zellij integration
- **Alternative:** Temporary split window workaround if needed now

**Phase C.2 Success Criteria:**
- [ ] User provides clarifications
- [x] Scrollbar implemented and working ✅
- [ ] Tab bar configured per user preferences
- [ ] History export functional
- [ ] F12 panel kitten debugged (if issues found)
- [ ] Theme issue resolved
- [ ] All limitations documented

---

#### 💡 Ideas from Previous Sessions (Collected 2025-12-07)

**From: `sessions/summaries/01-12-2025_KITTY_ADVANCED_STATUSBAR_SESSION_SUMMARY.md`**

##### Advanced Status Bar (Custom tab_bar.py) 📋 PLANNED
- **Purpose:** SRE-focused status bar with system metrics
- **Requested Metrics:**
  1. Tab number, layout name
  2. Git branch (current repo)
  3. Time (HH:MM format)
  4. CPU usage (refresh 3s)
  5. RAM usage (refresh 5s)
  6. Disk usage - Root `/` (refresh 10s)
  7. Disk usage - Backups `/backups/` (refresh 10s)
  8. Network stats (↑/↓ speeds, refresh 3s)
  9. K8s context ⭐ CRITICAL (refresh 5s, prod alert: yellow + ⚠️)
  10. Container count (Docker/Podman, refresh 5s)
- **Estimate:** 4-6 hours (custom Python development)
- **Status:** Plan created, implementation pending
- **Reference:** `docs/plans/kitty-advanced-statusbar-plan.md`

##### Window Splitting Enhancements ✅ MOSTLY DONE
- [x] Splits layout enabled (`splits:split_axis=auto`)
- [x] F5 = horizontal split, F6 = vertical split
- [x] F7 = rotate layout
- [x] Ctrl+Alt+Arrow navigation
- [ ] Test first terminal split behavior (USER TODO)

##### Tab Renaming Shortcut ✅ COMPLETE (2025-12-08)
- [x] Add F2 for tab renaming: `map f2 set_tab_title` ✅
- [x] Add Shift+F2 for reset: `map shift+f2 set_tab_title ""` ✅
- **Completed:** 2025-12-08

##### icat Image Preview 📋 OPTIONAL
- [ ] Test `kitty +kitten icat image.png`
- [ ] Create alias for quick preview
- [ ] Consider ranger integration (`preview_images_method kitty`)
- **Estimate:** 15 mins

##### pawbar - Panel-based Desktop Bar 🆕 DISCOVERED
- **URL:** https://github.com/codelif/pawbar
- **What:** Desktop panel using kitty's panel kitten
- **Use case:** Replace polybar/waybar with terminal-based status
- **Status:** Research needed, optional enhancement

---

#### Phase 2 (Phase D): Zellij Integration ✅ COMPLETE (2025-12-08)

**Status:** ✅ INSTALLED AND CONFIGURED
**Zellij Version:** 0.43.1
**Reference:** `docs/plans/kitty-zellij-phase1-plan.md`

**What's working:**
- ✅ Zellij installed via home-manager
- ✅ zjstatus plugin configured (CPU, MEM, SWAP, datetime)
- ✅ Catppuccin Mocha theme
- ✅ Mouse mode enabled
- ✅ pane_frames available (currently disabled per user preference)

##### 2.1 Install Zellij via Home-Manager ✅ COMPLETE
- [x] Zellij installed via home-manager
- [x] Version: 0.43.1
- [x] Verified: `which zellij && zellij --version` ✅

##### 2.2 Configure Zellij with Catppuccin Theme ✅ COMPLETE
- [x] Created `~/.config/zellij/config.kdl` with theme
- [x] Catppuccin Mocha theme configured
- [x] Added to chezmoi

##### 2.3 Install zjstatus Plugin ✅ COMPLETE
- [x] zjstatus.wasm installed at `~/.config/zellij/plugins/`
- [x] Configured with Catppuccin Mocha colors
- [x] Shows: Mode, Tabs, CPU, MEM, SWAP, DateTime
- [x] Added to chezmoi

##### 2.4 Create Custom Layouts (Optional)
- [ ] Create `~/.config/zellij/layouts/dev.kdl` (editor + terminal)
- [ ] Create `~/.config/zellij/layouts/ops.kdl` (logs + monitor + shell)
- [ ] Test layouts
- [ ] Add to chezmoi

##### 2.5 Create Navi Cheatsheets
- [ ] Create `dotfiles/dot_local/share/navi/cheats/zellij.cheat`
- [ ] Update `dotfiles/dot_local/share/navi/cheats/kitty.cheat` with new shortcuts
- [ ] Add to chezmoi

##### 2.6 Commit All Changes
- [ ] Commit home-manager changes
- [ ] Commit dotfiles changes (zellij configs + cheatsheets)
- [ ] Push all repos

**Success Criteria:**
- [ ] Zellij installed and launches
- [ ] zjstatus status bar working with correct colors
- [ ] Custom layouts functional
- [ ] Navi cheatsheets created
- [ ] All changes committed

---

#### Phase 3: Autocomplete.sh AI Integration (1-2 hours) 🤖 OPTIONAL

**Priority:** LOW (Nice-to-have, requires API keys)
**Risk:** MEDIUM (external dependencies, API costs)
**Reference:** `docs/integrations/kitty-autocomplete-integration.md`

**What it includes:**
- AI-powered command completion (double TAB for LLM suggestions)
- Secure API key management via KeePassXC
- Support for OpenAI, Anthropic, Groq, or local Ollama
- Natural language to command translation

##### 3.1 Install autocomplete.sh
- [ ] Download: `wget -qO- https://autocomplete.sh/install.sh | bash`
- [ ] Or manual review before install
- [ ] Verify: `which autocomplete && autocomplete --version`

##### 3.2 Setup API Keys in KeePassXC
- [ ] Obtain API key (OpenAI/Anthropic/Groq)
- [ ] Store in KeePassXC vault (Development/APIs/ group)
- [ ] Store in secret-tool: `secret-tool store --label="OpenAI API Key" service openai key apikey`
- [ ] Verify: `secret-tool lookup service openai key apikey`

##### 3.3 Configure Bash via Chezmoi
- [ ] Edit `dotfiles/dot_bashrc.tmpl`
- [ ] Add autocomplete.sh configuration section:
  - API key retrieval from secret-tool
  - Model selection (gpt-4o-mini, llama-3.1-8b-instant, codellama)
  - Context limits and security settings
- [ ] Apply chezmoi: `chezmoi apply`
- [ ] Reload bash: `source ~/.bashrc`

##### 3.4 Configure Kitty Shortcuts (Optional)
- [ ] Edit `dotfiles/dot_config/kitty/kitty.conf`
- [ ] Add autocomplete.sh integration shortcuts:
  - `Ctrl+Shift+A, U` - usage stats
  - `Ctrl+Shift+A, M` - model selection
  - `Ctrl+Shift+A, C` - config view
- [ ] Apply chezmoi

##### 3.5 Test Integration
- [ ] Test basic completion: `git push<TAB><TAB>`
- [ ] Test natural language: `# find all python files modified today<TAB><TAB>`
- [ ] Test complex workflow suggestions
- [ ] Verify API key security (not in plaintext)

##### 3.6 Commit Changes
- [ ] Commit dotfiles changes (bashrc template, kitty config)
- [ ] Push to remote

**Success Criteria:**
- [ ] autocomplete.sh installed
- [ ] API keys stored securely in KeePassXC
- [ ] Double TAB triggers AI suggestions
- [ ] No secrets in git
- [ ] Configuration managed via chezmoi

---

**Overall Success Criteria:**
- [ ] Phase 1 (Basic): Right-click paste + Ctrl+Alt+Arrow working
- [ ] Phase 2 (Zellij): Terminal multiplexer integrated (if pursued)
- [ ] Phase 3 (Autocomplete): AI completions working (if pursued)
- [ ] All changes committed and pushed
- [ ] Documentation updated with completion status

**Related Documentation:**
- Kitty Tool Guide: `docs/tools/kitty.md`
- Kitty + Zellij Integration: `docs/integrations/kitty-zellij-integration.md`
- Implementation Plans: `docs/plans/kitty-*.md`

---

### 7. Sync & Backup Infrastructure ✅

**Status:** IN PROGRESS (Documentation ✅ Complete)
**Goal:** Improve reliability, monitoring, and Android integration
**Estimated Time:** 6-8 hours total
**Documentation:** [docs/sync/](sync/) - Comprehensive guides created 2025-11-30

---

#### ✅ Phase 7: Documentation (COMPLETED 2025-11-30)
- [x] Create docs/sync/deployment.md
- [x] Create docs/sync/disaster-recovery.md
- [x] Create docs/sync/ansible-playbooks.md
- [x] Create docs/sync/monitoring.md
- [x] Create docs/adrs/ADR-006-REJECT-ROLEHIPPIE-RCLONE.md
- [x] Enhance docs/sync/conflicts.md with prevention strategies
- [x] Update docs/sync/README.md navigation
- [x] Create session index: sessions/sync-integration/README.md
- [x] Create git recovery case study: archives/issues/2025-11-17-git-repository-recovery/
- [x] Clean up sessions/sync-integration/ directory

---

#### Phase 0: Bisync recovery after secret refactor (HIGH - 20 min)
- [ ] Run `ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --tags resync` once to rebuild bisync state after the secret-service changes.
- [ ] Manually trigger `systemctl --user start rclone-gdrive-sync.service` and monitor `journalctl --user -u rclone-gdrive-sync -f` to ensure RCLONE_CONFIG_PASS is detected and no KeePassXC prompts appear.
- [ ] Confirm `systemctl --user show-environment | grep RCLONE_CONFIG_PASS` prints the password placeholder (reload via `reload-keepassxc-secrets.sh` if missing).

#### Phase 1: Android Syncthing Setup (HIGH - 30 min)
- [ ] Install Syncthing app on Android (xiaomi-poco-x6)
- [ ] Get desktop Syncthing device ID: `syncthing -device-id`
- [ ] Add desktop device on Android
- [ ] Get Android device ID from Syncthing app
- [ ] Add Android to NixOS config: `modules/workspace/syncthing-myspaces.nix`
- [ ] Rebuild NixOS: `sudo nixos-rebuild switch`
- [ ] Accept connection on desktop (Web GUI: http://localhost:8384)
- [ ] Test bidirectional sync (create test files)

**Priority:** 🔴 HIGH
**Benefit:** Real-time sync to mobile device

---

#### Phase 2: Conflict Resolution (HIGH - 15 min)
- [x] ~~Delete 12 Obsidian workspace.json conflicts~~ ✅ Resolved 2025-11-30
- [x] ~~Rename 2 KeePassXC conflicts as backups~~ ✅ Archived 2025-11-30
- [ ] Review KeePassXC backups after 30 days (delete if identical)
- [ ] Update docs/sync/conflicts.md status (mark as resolved)

**Priority:** 🔴 HIGH (mostly done)
**Status:** Obsidian conflicts resolved, KeePassXC archived

---

#### Phase 3: Fix Backup Playbook (HIGH - 1 hour)
- [ ] Investigate gdrive-backup.yml failure
- [ ] Read log: `/var/log/ansible/gdrive-backup-2025-11-21.log`
- [ ] Diagnose root cause
- [ ] Fix playbook errors
- [ ] Test monthly backup workflow
- [ ] Document fix in docs/sync/ansible-playbooks.md

**Priority:** 🔴 HIGH
**Issue:** Monthly backup currently failing

---

#### Phase 4: Logging Infrastructure (MEDIUM - 1-2 hours)
- [ ] Create log directories via home-manager:
  ```nix
  home.activation.createAnsibleLogs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.logs/ansible/rclone-gdrive-sync
    mkdir -p $HOME/.logs/ansible/gdrive-backup
    chmod 700 $HOME/.logs/ansible
  '';
  ```
- [ ] Update `ansible/playbooks/rclone-gdrive-sync.yml` log path
- [ ] Update `ansible/playbooks/gdrive-backup.yml` log path
- [ ] Implement log rotation (systemd-tmpfiles or logrotate)
- [ ] Configure 30-day retention
- [ ] Migrate existing logs from `~/.cache/rclone/`

**Priority:** 🟡 MEDIUM
**Benefit:** Centralized logging with rotation

---

#### Phase 5: Enhanced Notifications (MEDIUM - 1 hour)
- [ ] Add conflict file list to desktop notifications
  ```yaml
  {% if conflict_files %}
  Conflicts:
  {% for file in conflict_files %}
  - {{ file }}
  {% endfor %}
  {% endif %}
  ```
- [ ] Add error preview from logs (first 5 lines)
- [ ] Include log file path in all notifications
- [ ] Test notification appearance

**Priority:** 🟡 MEDIUM
**Benefit:** Better awareness of sync issues

---

#### Phase 6: Monitoring & Health Checks (MEDIUM - 2-3 hours)

##### 6.1 Google Drive Health Check Playbook
- [ ] Create `ansible/playbooks/gdrive-health-check.yml`
- [ ] Run `rclone check` between local and remote
- [ ] Detect file corruption (checksum mismatches)
- [ ] Check quota: `rclone about GoogleDrive-dtsioumas0:`
- [ ] Log results to `~/.logs/maintenance/gdrive-health-YYYY-MM-DD.jsonl`
- [ ] Desktop notification with results summary
- [ ] Schedule: Daily (09:00) via systemd timer

##### 6.2 Conflict Hunter Playbook
- [ ] Create `ansible/playbooks/conflict-hunter.yml`
- [ ] Find all `.conflictN` files in bisync workdir
- [ ] Find all "conflicted copy" files in Google Drive
- [ ] Analyze conflict age (how old are they?)
- [ ] Group conflicts by file type (.md, .json, workspace.json, etc.)
- [ ] Generate resolution recommendations
- [ ] Log to `~/.logs/maintenance/gdrive-conflicts-YYYY-MM-DD.jsonl`
- [ ] Desktop notification: "Found X conflicts. Age: oldest=Y, newest=Z"
- [ ] Schedule: Daily (09:15) via systemd timer

##### 6.3 Home-Manager Health Check (Optional)
- [ ] Create `ansible/playbooks/home-manager-health-check.yml`
- [ ] Check home-manager state version compatibility
- [ ] Verify activation scripts completed successfully
- [ ] Check symlinks integrity (`~/.config/`, `~/` dotfiles)
- [ ] Verify systemd user services running
- [ ] Check flake.lock freshness (warn if >30 days old)
- [ ] Schedule: Weekly (Sunday 09:00)

##### 6.4 NixOS System Health Check (Optional)
- [ ] Create `ansible/playbooks/nixos-health-check.yml`
- [ ] Check `/etc/nixos/` git status
- [ ] Verify system generation matches expected version
- [ ] Check for failed systemd services (system-level)
- [ ] Check disk space on `/` and `/nix/store`
- [ ] Schedule: Weekly (Sunday 10:00)

**Priority:** 🟡 MEDIUM
**Benefit:** Automated monitoring and early issue detection

---

**Success Criteria:**
- [ ] Android syncing in real-time
- [ ] All conflicts resolved
- [ ] Monthly backup working
- [ ] Centralized logging with rotation
- [ ] Automated health checks running
- [x] Complete documentation suite ✅

**Related Documentation:**
- **Deployment:** [docs/sync/deployment.md](sync/deployment.md)
- **Monitoring:** [docs/sync/monitoring.md](sync/monitoring.md)
- **Playbooks:** [docs/sync/ansible-playbooks.md](sync/ansible-playbooks.md)
- **Conflicts:** [docs/sync/conflicts.md](sync/conflicts.md)
- **Recovery:** [docs/sync/disaster-recovery.md](sync/disaster-recovery.md)
- **ADR-006:** [docs/adrs/ADR-006-REJECT-ROLEHIPPIE-RCLONE.md](adrs/ADR-006-REJECT-ROLEHIPPIE-RCLONE.md)

---

## 🟢 MEDIUM PRIORITY (This Quarter - Q4 2025)

### 7. Documentation Updates

- [ ] Update README.md with symlink structure explanation
- [ ] Document `-b backup` flag usage in debugging guide
- [ ] Add recovery procedures for symlink conflicts
- [ ] Create integration architecture document:
  - [ ] Document home-manager + ansible + NixOS interaction
  - [ ] Map activation scripts and timing
  - [ ] Document shared secrets strategy (KeePassXC)
  - [ ] Create component relationship diagrams
  - [ ] Location: `docs/commons/integrations/KEEPASSXC_INTEGRATION.md`

### 8. Secrets Management Integration

**Goal:** Unified KeePassXC-based secrets strategy

- [x] Approve ADR-012 (KeePassXC-centralized secret management contract)
- [ ] Define cross-component secrets access (update `docs/security/secrets-management.md`):
  - [x] KeePassXC vault location (currently `~/MyVault/`)
  - [ ] Ansible playbooks accessing secrets via `secret-tool`/systemd loaders
  - [ ] Home-manager activation/systemd loaders referencing the factory module
  - [ ] Secrets rotation policy (define cadence + documentation)
  - [x] Secret health-check timer + notifications (every 10 min → 1h later)
- [ ] Chezmoi integration with KeePassXC (template references + docs refresh)
- [ ] Replace KDE-Wallet with KeePassXC in home-manager:
  - [x] Dropbox secrets retrieval (loader + vault entry)
  - [x] rclone secrets retrieval (RCLONE_PASSWORD_COMMAND via secret-tool)
- [ ] Integrate Brave browser password/sync secrets with KeePassXC (follow Brave migration plan)
- [ ] Integrate Claude Code & Codex CLI API tokens via KeePassXC loader modules
- [ ] Integrate autocomplete/butterfish (`OPENAI_API_KEY` loader, HISTIGNORE guards) – Autocomplete Phase 1
- [ ] Store Brave Sync recovery phrase in KeePassXC and document recovery steps
- [ ] Document entire strategy in `docs/security/secrets-management.md`

### 9. Repository Structure Reorganization

- [ ] Evaluate git submodules for components:
  - [ ] home-manager/ → Separate repo?
  - [ ] ansible/ → Separate repo (in progress)
  - [ ] docs/ → Keep in main workspace
- [ ] Write ADR for decision
- [ ] Implement if approved

### 10. Session Management Cleanup

- [ ] Review all sessions/ directories
- [ ] Archive obsolete sessions
- [ ] Update project context in `my-modular-workspace.json`
- [ ] Document session naming convention

---

---

## 📦 ARCHIVED/CONSOLIDATED TODO SECTIONS

*The following sections were consolidated from individual TODO files on 2025-11-29.*
*Original files: ANSIBLE_TODO.md, HOME_MANAGER_TODO.md, SYNCTHING_TODO.md, PLASMA_MANAGER_TODO.md, ETC_NIXOS_CONFIG_TODO.md, TODO_HOME_MANAGER_NIXOS.md, CHEZMOI_NAVI_TODO.md, OLD_TODO_DECOUPLING_HOME.md*

### Ansible Automation (from ANSIBLE_TODO.md)

**Pending High Priority:**
- [ ] Fix ansible-lint violations in rclone-gdrive-sync.yml
- [ ] Create centralized logging infrastructure (`~/.logs/ansible/`)
- [ ] Implement log rotation via systemd-tmpfiles
- [ ] Create health check playbook for rclone setup
- [ ] Create conflict resolution helper playbook
- [ ] Add pre-commit hooks for ansible (ansible-lint, yamllint)

**Pending Medium Priority:**
- [ ] Create navi cheatsheets for ansible-rclone workflows
- [ ] Enhanced notifications with conflict details
- [ ] Drive health checks (daily automated)
- [ ] Sync success/failure tracking system

### Home-Manager (from HOME_MANAGER_TODO.md)

**Pending Immediate:**
- [ ] Test all applications after symlink changes
- [ ] Verify MyVault accessible and KeePassXC works
- [ ] Fix `claude-code-update.timer` (currently inactive/failed)
- [ ] Clean up `.backup` files

**Pending High Priority:**
- [ ] Complete semantic-grep installation (get correct hashes)
- [ ] MCP servers reorganization (node2nix for npm-based MCPs)
- [ ] Pre-commit hooks setup for home-manager repo
- [ ] Migrate `claude-code-update.service` to node2nix derivation

### Syncthing (from SYNCTHING_TODO.md)

- [ ] Configure Android Syncthing and pair devices
- [ ] Test Syncthing sync (create test files, verify sync)
- [ ] Test conflict resolution

### Plasma Manager (from PLASMA_MANAGER_TODO.md)

**Pending High Priority:**
- [ ] Verify Plasma Manager configuration with rc2nix
- [ ] Test memory optimizations (KDE < 800MB target)
- [ ] Configure SSH & PATH declaratively

**Pending Medium Priority:**
- [ ] KDE-Services plugin installation
- [ ] Kitty terminal declarative configuration
- [ ] Clipboard enhancement (Klipper configuration)
- [ ] Polonium tiling window manager investigation

### NixOS Configuration (from ETC_NIXOS_CONFIG_TODO.md)

**Pending High Priority:**
- [ ] Install and configure sops-nix for secrets management
- [ ] Bitwarden setup (GUI + CLI + integration)
- [ ] KeePass database symlink configuration

**Pending Medium Priority:**
- [ ] Taskbar customization
- [ ] Plasma widgets exploration
- [ ] VeraCrypt integration

### Navi Cheatsheets (from CHEZMOI_NAVI_TODO.md)

**Completed:** 6 cheatsheets (~210 commands)

**Pending:**
- [ ] `linux-debug.cheat` - Process, network, filesystem debugging
- [ ] `nix-linting.cheat` - nixpkgs-fmt, alejandra, statix, deadnix
- [ ] `git-workflows.cheat` - Common git operations
- [ ] `k3s-debug.cheat` - Cluster debugging
- [ ] `ansible-workflows.cheat` - Playbook execution
- [ ] `dev-tools.cheat` - Go, Python, Node.js workflows

### Decoupling Project (from OLD_TODO_DECOUPLING_HOME.md)

**Phase 1 Complete ✅**
**Phase 1.5 - Migration & Testing:**
- [ ] Verify all files migrated with correct permissions
- [ ] Test all GUI applications (Firefox, Brave, Kitty, VSCodium, KeePassXC)
- [ ] Test all development tools (Git, Python, Go, Node.js, Claude Code)
- [ ] Verify KDE Plasma settings apply correctly

**Phase 2 - Modular Refactor (PLANNED):**
- [ ] Create modular directory structure for home-manager
- [ ] Split home.nix into modules
- [ ] Create host-specific configurations

---

## 🔵 LOW PRIORITY (Q1 2026)

### 11. Chezmoi Migration

**Status:** IN PROGRESS (Week 48, 2025-11-29)
**Documentation:**
- ADR: `docs/adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md`
- Status: `docs/chezmoi/MIGRATION_STATUS.md`

#### Completed (2025-11-29)
- [x] Audit current dotfiles under management
- [x] Fix .chezmoiignore with comprehensive patterns
- [x] Simplify repo structure (create `_staging/` directory)
- [x] Remove duplicates and large files (FiraCode.zip, duplicate dirs)
- [x] Migrate kitty config (Catppuccin Mocha theme)
- [x] Migrate git config (dot_gitconfig.tmpl)
- [x] Create ADR-005 for migration criteria
- [x] Update README.md with current structure

#### Pending
- [ ] Push dotfiles repo changes to origin
- [ ] Push docs repo changes to origin
- [ ] Push home-manager repo changes to origin
- [ ] Test chezmoi apply on fresh terminal
- [ ] Migrate cline config (simple JSON, low effort)
- [ ] Set up age encryption for sensitive dotfiles
- [ ] Integrate KeePassXC with chezmoi templates
- [ ] Consider migrating: Firefox settings, VSCodium settings

### 12. NixOS to Fedora Atomic Migration Planning

**Status:** Research phase
**Target:** Q1-Q2 2026

- [ ] Research BlueBuild custom image creation
- [ ] Plan desktop environment migration (KDE Plasma)
- [ ] Test home-manager standalone on Fedora
- [ ] Create migration runbook
- [ ] Test on VM before production

### 13. Lint Tools & Code Quality

- [ ] Research Nix formatters (nixpkgs-fmt, alejandra)
- [ ] Research syntax checkers (statix, deadnix)
- [ ] Add to home.packages
- [ ] Configure VSCodium integration
- [ ] Create navi cheatsheets

---

## 📊 Repository Status Summary

### home-manager (github.com/dtsioumas/home-manager)
- **Status:** Ansible integration complete, ready for switch
- **Last commit:** feat(rclone): Migrate sync job from bash script to Ansible playbook
- **Action needed:** Run `home-manager switch` to apply ansible integration

### docs (github.com/dtsioumas/my-modular-workspace-docs)
- **Status:** Archive cleanup in progress
- **Unstaged changes:** Multiple deleted Archive files
- **Action needed:** Commit deletions, push

### ansible (github.com/dtsioumas/modular-workspace-ansible)
- **Status:** Playbook migration complete, systemd wrapper ready
- **Last commit:** refactor(playbook): Improve rclone-gdrive-sync.yml structure
- **Action needed:** None - pushed to main

### nixos (hosts/shoshin/nixos/)
- **Status:** Stable, decoupled from home-manager
- **Last update:** 2025-11-22
- **Action needed:** None immediate

---

## 📅 Timeline & Milestones

### Week 48 (Nov 24-30, 2025)
- Complete all immediate priority tasks
- Commit all pending changes across repos
- Verify home-manager generation #46 stable
- Begin MCP servers reorganization

### December 2025
- Complete home-manager enhancements (Phases 1-3)
- Finalize ansible repository setup
- Complete rclone collection migration
- Documentation updates

### Q1 2026
- Secrets management unification
- Chezmoi migration planning
- Fedora Atomic research and testing
- Code quality tooling setup

### 14. Plasma Desktop Dotfiles Migration to Chezmoi 🆕

**Status:** PHASE 0-3 COMPLETE ✅ | Ready to Start Phase 1 (Execution)
**Priority:** MEDIUM
**Documentation:** `docs/dotfiles/plasma/`
**Migration Plan:** `docs/dotfiles/plasma/migration-plan.md` ⭐
**Session Summary:** `sessions/summaries/2025-12-02_PLASMA_DOTFILES_MIGRATION_PLANNING_PHASES_0_2.md`

#### Phase 0: Documentation Consolidation ✅ COMPLETE (2025-12-02)
- [x] Created `docs/dotfiles/plasma/session-context.md` (400+ lines)
- [x] Consolidated existing documentation

#### Phase 1: Local Investigation ✅ COMPLETE (2025-12-02)
- [x] Discovered 40+ plasma files, categorized by priority
- [x] Created `docs/dotfiles/plasma/local-investigation.md` (600+ lines)

#### Phase 2: Web Research ✅ COMPLETE (2025-12-02)
- [x] Research confidence: 0.87 (Band C - HIGH)
- [x] Discovered chezmoi_modify_manager tool
- [x] Created `docs/dotfiles/plasma/research-findings.md` (600+ lines)

#### Phase 3: Migration Planning ✅ COMPLETE (2025-12-04)
- [x] Used Planner role for comprehensive planning
- [x] Designed 4-phase migration strategy (4-6 weeks)
- [x] Created `docs/dotfiles/plasma/migration-plan.md` (500+ lines)
- [x] Plan confidence: 0.84 (Band C - HIGH)

#### Next: Execution Phases (User Decision)

**Phase 1 (Execution): Tool Setup & Preparation** (1 week)
- [ ] Install chezmoi_modify_manager
- [ ] Update .chezmoiignore patterns
- [ ] Create backup of current Plasma configs
- [ ] Test chezmoi_modify_manager with sample file

**Phase 2 (Execution): Application Configs** (1 week)
- [ ] Migrate Dolphin config
- [ ] Migrate Konsole config
- [ ] Migrate Kate config
- [ ] Migrate Okular config

**Phase 3 (Execution): Core Plasma Configs** (2 weeks)
- [ ] Migrate keyboard layouts
- [ ] Migrate theme settings
- [ ] Migrate global shortcuts
- [ ] Migrate KWin settings

**Phase 4 (Execution): Final Migration** (1 week)
- [ ] Decide on panel migration
- [ ] Create Fedora migration guide
- [ ] Test on VM
- [ ] Cleanup plasma-manager

---

## 🔗 Quick Links

- **Project Root:** `/home/mitsio/.MyHome/MySpaces/my-modular-workspace/`
- **Home-Manager Repo:** `home-manager/` → [github.com/dtsioumas/home-manager](https://github.com/dtsioumas/home-manager)
- **Docs Repo:** `docs/` → [github.com/dtsioumas/my-modular-workspace-docs](https://github.com/dtsioumas/my-modular-workspace-docs)
- **Ansible Repo:** `ansible/` → [github.com/dtsioumas/modular-workspace-ansible](https://github.com/dtsioumas/modular-workspace-ansible)
- **NixOS Config:** `hosts/shoshin/nixos/` → [github.com/dtsioumas/shoshin-nixos](https://github.com/dtsioumas/shoshin-nixos)

---

## 📝 Notes

- **Username:** mitsio
- **Primary Workspace:** shoshin (初心 - "beginner's mind")
- **Current OS:** NixOS 25.05
- **Future OS:** Fedora Atomic (BlueBuild)
- **Home-Manager Mode:** Standalone (not NixOS module)
- **Package Strategy:** nixpkgs-unstable for user packages

---

**Last Review:** 2025-12-14
**Next Review:** Weekly (every Sunday)
**Maintained by:** Dimitris Tsioumas (Mitsio)

---

## OpenAI Codex Implementation (Added 2025-12-14)

**Status:** Mostly Complete
**Last Updated:** 2025-12-04

### Completed (2025-12-04)
- [x] Research OpenAI Codex agent capabilities and configuration
- [x] Fix build errors during node2nix installation
- [x] Install Codex via node2nix (declarative)
- [x] Configure Codex MCP servers (context7, firecrawl, read-website-fast, time, fetch, sequential-thinking)
- [x] Create global AGENTS.md with shared instructions
- [x] Verify Codex installation (`codex --version` returns `codex-cli 0.64.0`)
- [x] Install OpenAI VSCodium extension (declarative)
- [x] Create comprehensive documentation (docs/tools/codex.md - 500+ lines)

### Pending
- [ ] Apply home-manager rebuild to install VSCodium extension
- [ ] Verify VSCodium extension installation
- [ ] Test Codex with real coding tasks
- [ ] Fine-tune approval_policy and sandbox_mode
- [ ] Configure additional MCP servers (exa, grok, chatgpt)

---

## Autocomplete Implementation Progress
**Updated:** 2025-12-05 (Session 2)

### Phase 1: Secret Management 🔄 IN PROGRESS
- [x] Design generic systemd + KeePassXC pattern
- [x] Research existing implementation (discovered working system!)
- [x] Adapt design to existing pattern
- [ ] Add OPENAI_API_KEY to load-keepassxc-secrets.service
- [ ] Store OpenAI API key in KeePassXC
- [ ] Test secret loading via systemd

### Phase 2: LLM Autocomplete (Butterfish) ⏳ PENDING
- [ ] Install butterfish via go (home-manager activation script)
- [ ] Add bash integration (dot_bashrc.tmpl)
- [ ] Create butterfish config with blocked patterns
- [ ] Add HISTIGNORE for secret protection
- [ ] Test functionality (Capital+Tab, goal mode)
- [ ] Test security (SSH detection, history, company patterns)
- [ ] Test performance (baseline vs after)

### Phase 3: Classic Autocomplete (ble.sh) ⏳ PENDING
- [ ] Check ble.sh availability in nixpkgs
- [ ] Install via home-manager/shell.nix
- [ ] Configure in dot_bashrc.tmpl
- [ ] Create dot_config/blesh/init.sh
- [ ] Test fish-like suggestions
- [ ] Verify no conflicts with butterfish

### Documentation 📝
- [x] Plans V2 created with all fixes
- [x] Ultrathink reviews completed
- [x] ADR-009 created
- [x] Session summaries written
- [ ] Update plans with actual implementation details
- [ ] Document adaptation from generic to existing pattern
- [ ] Create troubleshooting guide based on real issues

---
