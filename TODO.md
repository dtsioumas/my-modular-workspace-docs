# Master TODO - My Modular Workspace

**Project:** my-modular-workspace
**Last Updated:** 2025-11-30 17:45
**Current Phase:** Home-Manager Enhancements (Week 48-49)
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

#### Phase 1: Semantic-Grep Installation (2-3 hours)

**Tool:** https://github.com/arunsupe/semantic-grep
**Binary:** `w2vgrep`
**Nix File:** `home-manager/semantic-grep.nix`

##### 1.1 Create Nix Derivation
- [x] Create `semantic-grep.nix` with buildGoModule derivation
- [x] Set up word embedding model download automation
- [ ] Get correct hashes from build output (run build once)
- [ ] Update sha256/vendorHash in derivation
- [ ] Import in home.nix

##### 1.2 Model Management
- [ ] Download GoogleNews-slim word embedding model
- [ ] Store in `~/.config/semantic-grep/models/`
- [ ] Create config.json with model path
- [ ] Verify activation script downloads model

##### 1.3 Testing & Documentation
- [ ] Test: `home-manager build --flake .#mitsio@shoshin`
- [ ] Verify `w2vgrep` command available after switch
- [ ] Test semantic search functionality
- [ ] Document in `docs/tools/semantic-grep.md` (already exists)
- [ ] Create navi cheatsheets in chezmoi repo

---

#### Phase 2: MCP Servers Reorganization (4-6 hours)

**Goal:** Move ALL MCP installations to home-manager, organized in `~/.local-mcp-servers/`
**Architecture Doc:** Create `docs/integrations/mcp-servers.md`

##### 2.1 Directory Setup
- [ ] Create `home-manager/mcps/` directory for derivations
- [ ] Create activation script for `~/.local-mcp-servers/` structure
- [ ] Create `mcps/default.nix` to import all MCPs

##### 2.2 npm-based MCPs (node2nix)
- [ ] Research node2nix workflow
- [ ] **context7-mcp** (`@upstash/context7-mcp`)
  - [ ] Generate node-packages.nix
  - [ ] Create derivation
  - [ ] Test functionality
- [ ] **firecrawl-mcp**
  - [ ] Generate node-packages.nix
  - [ ] Handle API key configuration
  - [ ] Test functionality
- [ ] **mcp-read-website-fast** (`@just-every/mcp-read-website-fast`)
  - [ ] Generate node-packages.nix
  - [ ] Test functionality

##### 2.3 Go-based MCPs (buildGoModule)
- [ ] **git-mcp-go** (github.com/tak-bro/git-mcp-go)
  - [ ] Create derivation with vendorHash
  - [ ] Test with git repositories
- [ ] **mcp-filesystem-server** (github.com/mark3labs/mcp-filesystem-server)
  - [ ] Create derivation
  - [ ] Configure allowed directories
- [ ] **mcp-shell** (github.com/punkpeye/mcp-shell)
  - [ ] Create derivation
  - [ ] Configure security.yaml

##### 2.4 Python/uv-based MCPs
- [ ] **mcp-server-fetch** - buildPythonPackage or uv wrapper
- [ ] **mcp-server-time** - Configure timezone (Europe/Athens)
- [ ] **sequential-thinking** - Test thinking process

##### 2.5 Rust-based MCPs (buildRustPackage)
- [ ] **rust-mcp-filesystem** (optional - compare with Go version)

##### 2.6 Integration
- [ ] Update `claude_desktop_config.json` with new paths
- [ ] All paths use `~/.local-mcp-servers/<mcp>/bin/`
- [ ] Verify paths use `mitsio` not `mitso`
- [ ] Test all MCPs in Claude Desktop

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

### 6. Sync & Backup Infrastructure ✅

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
