# Master TODO - My Modular Workspace

**Project:** my-modular-workspace
**Last Updated:** 2025-11-26 02:00
**Current Phase:** Continue.dev Integration Planning Complete
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

### 5. Home-Manager Enhancements (Week 48)

**Session:** `sessions/home-manager-enchantments-week-48/`
**Detailed Plan:** `sessions/home-manager-enchantments-week-48/PLAN.md`

#### Phase 1: Semantic-Grep Installation
- [x] Create `semantic-grep.nix` with buildGoModule derivation
- [x] Set up word embedding model download automation
- [ ] Get correct hashes from build output
- [ ] Update hashes in `semantic-grep.nix`
- [ ] Test semantic-grep (w2vgrep command)
- [ ] Create documentation at `docs/tools/semantic-grep/`
- [ ] Create navi cheatsheets

#### Phase 2: MCP Servers Reorganization
- [ ] Research node2nix for npm-based MCPs
- [ ] Create `mcps/` directory structure
- [ ] Convert npm MCPs to node2nix derivations:
  - [ ] context7-mcp
  - [ ] firecrawl-mcp
  - [ ] mcp-read-website-fast
- [ ] Create Go MCP derivations:
  - [ ] git-mcp-go
  - [ ] mcp-filesystem-server
  - [ ] mcp-shell
- [ ] Handle Python/uv MCPs:
  - [ ] mcp-server-fetch
  - [ ] mcp-server-time
  - [ ] sequential-thinking
- [ ] Install all to `~/.local-mcp-servers/<mcp-name>/`
- [ ] Update Claude Desktop config
- [ ] Test all MCPs

#### Phase 3: Pre-commit Hooks Setup
- [ ] Add pre-commit-hooks.nix to home.nix imports
- [ ] Configure nixfmt/alejandra formatter
- [ ] Configure statix linter
- [ ] Configure deadnix detector
- [ ] Test pre-commit workflow
- [ ] Document in README

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
- [ ] Run home-manager switch to apply changes
- [ ] Test systemd service with ansible playbook
- [ ] Migrate `gdrive-backup.yml` playbook (optional)

### 6. Migration & Conflict Prevention

**Purpose:** Track items needing migration to avoid conflicts

#### Completed Cleanup (2025-11-23)
- [x] Removed `vscode-extensions-update` service/timer
- [x] Removed `cline-update` service/timer
- [x] Resolved symlink conflicts with `-b backup`
- [x] Backed up `~/MyVault` and Firefox profiles

#### Pending Migrations
- [ ] `claude-code-update` service → node2nix derivation
- [ ] `claude-code` activation script → proper Nix derivation
- [ ] Verify all `symlinks.nix` targets exist in `~/.MyHome/`
- [ ] Review Firefox/VSCodium configs for chezmoi migration
- [ ] Document npm global packages migration strategy

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

- [ ] Define cross-component secrets access:
  - [ ] KeePassXC vault location (currently `~/MyVault/`)
  - [ ] Ansible accessing secrets from KeePassXC
  - [ ] Home-manager activation scripts accessing secrets
  - [ ] Secrets rotation policy
- [ ] Chezmoi integration with KeePassXC
- [ ] Replace KDE-Wallet with KeePassXC in home-manager:
  - [ ] Dropbox secrets retrieval
  - [ ] rclone secrets retrieval
- [ ] Document in `docs/security/secrets-management.md`

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

- [ ] Audit current dotfiles under management
- [ ] Create chezmoi templates for configs
- [ ] Set up encryption for sensitive dotfiles
- [ ] Test chezmoi apply workflow
- [ ] Migrate from home-manager dotfile management to chezmoi where appropriate

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

**Last Review:** 2025-11-25 00:45
**Next Review:** Weekly (every Sunday)
**Maintained by:** Dimitris Tsioumas (Mitsio)
