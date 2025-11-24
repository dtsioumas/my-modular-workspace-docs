# Master TODO - My Modular Workspace

**Project:** my-modular-workspace
**Last Updated:** 2025-11-24 00:10
**Current Phase:** Phase 1 Complete, Transitioning to Phase 2
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

## 🔴 IMMEDIATE PRIORITY (Week 48 - Nov 24-30, 2025)

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

### 4. Home-Manager Enhancements (Week 48)

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

#### RClone Collection Migration
- [ ] Research rolehippie/rclone collection
- [ ] Create migration plan for bash scripts → collection
- [ ] Install collection via requirements.yml
- [ ] Migrate `rclone-gdrive-sync.yml` playbook
- [ ] Migrate `gdrive-backup.yml` playbook
- [ ] Update systemd services
- [ ] Test and verify

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
- **Status:** Active development, Generation #46
- **Unstaged changes:** 1 file (home.nix)
- **Untracked:** 6 new .nix files + 2 directories
- **Action needed:** Commit and push

### docs (github.com/dtsioumas/my-modular-workspace-docs)
- **Status:** Archive cleanup in progress
- **Unstaged changes:** Multiple deleted Archive files
- **Action needed:** Commit deletions, push

### ansible (github.com/dtsioumas/modular-workspace-ansible)
- **Status:** Pre-commit setup complete, collection migration pending
- **Unstaged changes:** Deleted files, modified playbooks, new files
- **Action needed:** Review, commit, push

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

**Last Review:** 2025-11-24 00:10
**Next Review:** Weekly (every Sunday)
**Maintained by:** Dimitris Tsioumas (Mitsio)
