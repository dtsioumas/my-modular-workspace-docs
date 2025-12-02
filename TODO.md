# Master TODO - My Modular Workspace

**Project:** my-modular-workspace
**Last Updated:** 2025-12-01
**Current Phase:** Kitty Terminal Enhancements + Home-Manager Enhancements (Week 48-49)
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

### 4. Ansible RClone Sync Enhancements 🆕

**Status:** PLANNING
**Priority:** 🔴 HIGH
**Estimated Time:** 4-6 hours
**Related Files:**
- `ansible/playbooks/rclone-gdrive-sync.yml`
- `ansible/playbooks/gdrive-backup.yml`
**Documentation:** To be created in `docs/ansible/`

#### 4.1 Real-Time Progress Notifications

**Goal:** Show sync progress via desktop notifications with auto-updating percentage

**Research Phase:**
- [ ] Investigate rclone progress tracking mechanisms
  - [ ] Test `--progress` flag output format
  - [ ] Test `--stats` flag with different intervals (1s, 5s, 10s)
  - [ ] Check if rclone provides JSON progress output
  - [ ] Research `rclone rc` (remote control) for live stats
- [ ] Research desktop notification update mechanisms
  - [ ] Can `notify-send` update existing notifications (replace-id)?
  - [ ] Test `dunst` notification replacement capabilities
  - [ ] Check KDE Plasma notification replacement API
  - [ ] Alternative: Use `zenity --progress` for GUI progress bar
- [ ] Research Ansible real-time output capture
  - [ ] Test `async` tasks with periodic polling
  - [ ] Test piping to `tee` for simultaneous logging and parsing
  - [ ] Check if `script` module can capture real-time output
  - [ ] Research `expect` module for interactive output parsing

**Implementation Options to Evaluate:**

**Option A: File Count Progress (Simple, Recommended)**
```yaml
# Pseudo-code concept
- name: Count total files
  find: path={{ local_path }}
  register: total_files

- name: Start sync with periodic notifications
  command: rclone bisync ... --stats 10s
  async: 3600
  poll: 10

- name: Update notification every 10s
  notify-send "Sync: {{ processed }}/{{ total }} files ({{ percent }}%)"
```

**Option B: rclone rc Progress (Advanced)**
```yaml
# Start rclone with --rc flag
# Poll rclone rc core/stats for live progress
# Update notification with real stats
```

**Option C: Static Milestones (Fallback)**
```yaml
# Show notifications at: Start → 25% → 50% → 75% → Done
# Based on task completion stages (not real file counts)
```

**Tasks:**
- [ ] Research Phase (2-3 hours)
  - [ ] Test all progress tracking options locally
  - [ ] Document findings in `docs/ansible/RCLONE_PROGRESS_RESEARCH.md`
  - [ ] Choose implementation approach (A, B, or C)
  - [ ] Create proof-of-concept script
- [ ] Implementation Phase (2-3 hours)
  - [ ] Update `rclone-gdrive-sync.yml` with progress tracking
  - [ ] Add notification update logic
  - [ ] Test with real sync (dry-run first!)
  - [ ] Measure performance impact
  - [ ] Add configuration option to enable/disable
- [ ] Documentation
  - [ ] Update playbook comments
  - [ ] Add progress configuration to README
  - [ ] Document notification format

**Success Criteria:**
- ✅ Desktop notification shows during sync
- ✅ Percentage updates at least every 10-30 seconds
- ✅ Minimal performance impact (< 5% slowdown)
- ✅ Works with both dry-run and actual sync
- ✅ Gracefully handles notification failures (doesn't break sync)

---

#### 4.2 Conflict Files in Notifications

**Goal:** Show conflict files in notification (easy to copy-paste for resolution)

**Current Behavior:**
- Dry-run detects conflicts ✅
- Logs conflicts to file ✅
- Shows conflict count in debug message ❌ (not in notification)

**Desired Behavior:**
```
┌─────────────────────────────────────────────────┐
│ RClone Sync: Conflicts Detected!                │
├─────────────────────────────────────────────────┤
│ 5 conflicts found:                              │
│                                                  │
│ MyVault/backups/mitsio_secrets.conflict.kdbx    │
│ MySpaces/.../CLAUDE_DESKTOP_PROMPT_...md        │
│ docs/sync/conflicts.md                          │
│ ...                                              │
│                                                  │
│ Click to copy paths to clipboard               │
└─────────────────────────────────────────────────┘
```

**Implementation Tasks:**
- [ ] Extract conflict file list from dry-run output
  - [ ] Parse log file for "both path1 and path2" entries
  - [ ] Store in variable (max 10 files to avoid overflow)
  - [ ] Format as newline-separated list
- [ ] Update notification task
  - [ ] Add conflict files to notification body
  - [ ] Truncate long paths for readability
  - [ ] Add "View full log: {{ log_path }}" footer
- [ ] Add clipboard integration (OPTIONAL)
  - [ ] Research `notify-send` actions (if supported in KDE)
  - [ ] Alternative: Save conflict list to temp file, show path in notification
  - [ ] Script to copy from temp file: `xclip -selection clipboard < /tmp/conflicts.txt`
- [ ] Test with real conflicts
  - [ ] Verify notification shows correct files
  - [ ] Test with 0, 1, 5, 20+ conflicts
  - [ ] Ensure notification doesn't overflow/truncate badly

**Success Criteria:**
- ✅ Notification shows up to 10 conflict file paths
- ✅ Paths are readable and correctly formatted
- ✅ If >10 conflicts, shows "... and X more (see log)"
- ✅ Log path included in notification for full details

---

#### 4.3 Local-as-Source-of-Truth & Conflict Resolution ✅ RESOLVED

**Status:** ✅ RESOLVED (2025-12-01)
**Priority:** COMPLETED
**Documentation:** `docs/integrations/RCLONE_BISYNC_SYNC_INTEGRATION.md`
**Commit:** `48a690f` - feat(bisync): Add local-as-source-of-truth conflict resolution

**Original Issues (ALL FIXED):**
- ❌ ~~74 conflicts created in single sync~~ → ✅ Conflicts now keep local, backup remote
- ❌ ~~Deleted files "recovered" from remote~~ → ✅ Not an issue (misunderstood --recover flag)
- ❌ ~~.git directories syncing causing 48+ conflicts~~ → ✅ Excluded with `**/.git/**`
- ❌ ~~No conflict resolution strategy~~ → ✅ `--conflict-resolve path1` (local wins)

**Solution Implemented:**
```yaml
rclone_bisync_options:
  - --compare size,modtime,checksum
  - --resilient
  - --recover                        # Recovers bisync STATE, NOT deleted files
  - --create-empty-src-dirs
  - --conflict-resolve path1         # LOCAL (Path1) ALWAYS WINS
  - --conflict-loser num             # Keep numbered backups of remote
  - --conflict-suffix .remote-conflict

exclude_patterns:
  - "**/.git/**"                     # CRITICAL: Never sync git repos
  - "**/node_modules/**"
  - "**/__pycache__/**"
  - "**/.cache/**"
```

**Key Research Findings:**
- `--recover` flag: Recovers bisync's **state** after interruptions, NOT deleted files
- Deleted files "reappearing" would only happen with `--resync` on every run (we don't do this)
- `--conflict-resolve path1`: Local version UNCONDITIONALLY wins on conflicts

**Remaining Monitoring:**
- [ ] Monitor bisync behavior over 1-2 weeks to confirm fix
- [ ] Watch for any new conflict patterns
- [ ] Update documentation if issues arise

---

#### 4.4 Git Repository Maintenance Playbook 🆕 FUTURE

**Status:** 💡 IDEA - To Be Investigated
**Priority:** MEDIUM
**Estimated Time:** 2-3 hours

**Problem:**
- Even with `.git/**` excluded, old conflict files may exist
- Git repositories need periodic integrity checks
- Conflict files in git directories can corrupt repos

**Proposed Solution: Git Maintenance Playbook**

**Phase A: Conflict File Cleanup**
- [ ] Create `ansible/playbooks/git-maintenance.yml`
- [ ] Find and delete `.conflict*` and `.remote-conflict*` files in .git directories
- [ ] Run every 30 minutes via systemd timer
- [ ] Desktop notification with count of cleaned files
- [ ] Log cleaned files to `~/.logs/maintenance/git-cleanup-YYYY-MM-DD.log`

**Phase B: Integrity Checks**
- [ ] Run `git fsck` on each repository
- [ ] Check for corruption, dangling objects, broken refs
- [ ] Report issues via notification
- [ ] Log integrity status

**Phase C: Interactive Conflict Resolution (FUTURE IDEA)**
- [ ] Script to present conflicts to user interactively
- [ ] Show diff between local and remote versions
- [ ] Let user choose: keep local, keep remote, merge
- [ ] Apply choice and clean up conflict files
- [ ] Consider using `fzf` or `gum` for TUI

**Schedule:**
- Cleanup: Every 30 minutes (lightweight)
- Integrity: Daily at 08:00 (heavier)

**Success Criteria:**
- [ ] No conflict files accumulate in .git directories
- [ ] Git corruption detected early
- [ ] User notified of issues

---

### 5. KeePassXC Authorization Persistence Investigation 🔴 🆕

**Status:** 🔴 CRITICAL INVESTIGATION NEEDED
**Priority:** 🔴 HIGH
**Estimated Time:** 4-6 hours
**Roles Required:** Technical Researcher, Planner
**Related Files:**
- `home-manager/keepassxc.nix`
- `docs/plans/KEEPASSXC_INTEGRATION_PLAN.md`
**Documentation:** See detailed tasks in `KEEPASSXC_INTEGRATION_PLAN.md` (end of file)

#### Problem

**KeePassXC does NOT remember authorization for apps**, prompting EVERY time:
- systemd service `load-keepassxc-secrets` prompts on every run ❌
- Manual sync (`rclone-gdrive-sync`) prompts every time ❌
- User must authorize REPEATEDLY despite clicking "Allow" ❌

**Current behavior:** Phase 3 systemd integration works, BUT requires manual authorization each time
**Expected:** KeePassXC should remember authorized apps and NOT prompt repeatedly

#### Investigation Tasks (Use Technical Researcher Role)

**Phase 1: Research (2-3 hours)**
- [ ] Web research: "KeePassXC FdoSecrets remember authorization application"
- [ ] Check KeePassXC GitHub issues for authorization persistence bugs
- [ ] Read FdoSecrets documentation on application whitelisting
- [ ] Research how KeePassXC identifies calling applications
- [ ] Investigate why systemd services don't get remembered
- [ ] Document findings in `docs/integrations/KEEPASSXC_AUTHORIZATION_RESEARCH.md`

**Phase 2: Test Solutions (1 hour)**
- [ ] Check KeePassXC database for authorization records
- [ ] Test if app path (absolute vs relative) matters
- [ ] Examine `.config/keepassxc/keepassxc.ini` for authorization settings
- [ ] Test alternative: KeePassXC CLI (`keepassxc-cli`) vs FdoSecrets

**Phase 3: Implement Best Solution (1-2 hours)**

**Potential solutions to evaluate:**

**Option A:** Pre-authorize apps in KeePassXC config
- Research if KeePassXC supports app whitelist in config
- Add script paths to allowed apps list
- Test persistence across restarts

**Option B:** Use KeePassXC CLI instead of FdoSecrets
- Replace `secret-tool` with `keepassxc-cli`
- Handle database unlock (may need SSH key or similar)
- Test if this avoids authorization prompts

**Option C:** Alternative secret storage
- Investigate systemd-creds or other mechanisms
- Use for automated access, KeePassXC for manual changes
- Evaluate security trade-offs

**Option D:** Accept current behavior (if no solution)
- Document "one prompt per login" as expected behavior
- This is acceptable if technically unavoidable

#### Success Criteria

- ✅ User authorizes ONCE per login session
- ✅ Subsequent accesses do NOT prompt
- ✅ Security maintained (ConfirmAccessItem=true)
- ✅ Solution documented and reproducible

#### Priority Justification

**HIGH** because:
- Affects UX significantly (repeated authorization prompts)
- User explicitly frustrated ("make keepassxc remember the fucking secrets")
- Blocks smooth automation of systemd services
- May have simple fix if we find the right approach

**Defer to next session** if needed - research phase required first

---

### 6. Continue.dev Integration (Week 48) 🆕

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

### 6. Kitty Terminal Enhancements

**Status:** PHASE A & B ✅ COMPLETE | PHASE C.1 ✅ COMPLETE | PHASE C.2 🚀 IN PROGRESS | PHASE C.2 ADVANCED 📋 PLANNED

**Latest Session:** 2025-12-01 22:30-23:30 (1 hour planning + research session)
**Last Completed:** 2025-12-01 20:00 (Phase C.2 research)
**Last Updated:** 2025-12-01 20:00 (Comprehensive session context documented)
**Goal:** Enhance kitty terminal with advanced features and workflow improvements
**Time Spent:** ~5 hours (Phase A: 30m, Phase B: 2h, Phase C.1: 1h, Research: 2h)
**Remaining:** 3-5 hours (Phase C.2 implementation pending user clarifications)
**Documentation:**
- **Plan (Kittens):** `docs/plans/kitty-kittens-enhancements-plan.md` ⭐ PRIMARY
- Plan (Basic): `docs/plans/kitty-enhancements-plan.md`
- Plan (Zellij): `docs/plans/kitty-zellij-phase1-plan.md`
- Integration (Autocomplete): `docs/integrations/kitty-autocomplete-integration.md`
- Current Config: `dotfiles/dot_config/kitty/kitty.conf`
- Tool Guide: `docs/tools/kitty.md`

**Current State (2025-12-01 23:30):**
- ✅ Kitty 0.42.1 with Dracula theme (switched from Catppuccin Mocha)
- ✅ Configured with transparency (15% = 85% transparent), blur (32)
- ✅ Theme-adaptive bash prompt (shows mitsio@shoshin:path$)
- ✅ Managed via chezmoi at `dotfiles/dot_config/kitty/`
- ✅ **Phase A Complete:** Basic enhancements (right-click paste, navigation, transparency)
- ✅ **Phase B Complete:** Essential kittens (search, git diff, shell integration, ssh)
- ✅ **Phase C.1 Complete:** Panel kitten (F12), theme cycling (Ctrl+Shift+F9)
- ✅ **Tab Navigation Complete:** 4 shortcut options (Alt+Left/Right recommended)
- ✅ **Terminal Helpers Complete:** Navi cheatsheets (kh, khe, ks), daily reminder
- ✅ **Interactive Scrollbar Complete:** Clickable, draggable, auto-hide
- 🔬 **Phase C.2 Advanced Research Complete:** Comprehensive findings (0.87 confidence)
- 📋 **Phase C.2 Advanced Planned:** Full implementation plan created
- ⏳ **Phase C.2 Advanced Pending:** User scheduled for next session

**Session 2025-12-01 Completed Items:**
- [x] Fixed bash prompt to show user@hostname with theme-adaptive colors
- [x] Implemented interactive clickable scrollbar
- [x] Documented scrollbar in kitty guide
- [x] Comprehensive web research on advanced kitty features (0.87 confidence)
- [x] Documented all user preferences and requirements
- [x] Created detailed implementation plan (6-8 hours estimated)
- [x] Updated TODO.md with all Phase C.2 Advanced tasks
- [x] All changes committed to dotfiles repo (4 commits)

**Session 2025-12-01 Pending Items:**
- [ ] User review and approve implementation plan
- [ ] User schedule implementation sessions (3 sessions recommended)
- [ ] Implement custom tab_bar.py with system metrics (4 hours)
- [ ] Configure window splitting (15 mins)
- [ ] Configure mouse actions (30 mins)
- [ ] Configure tab management (45 mins)
- [ ] Implement history export kitten (1.5 hours)
- [ ] Debug F12 panel kitten issue (30 mins)

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

##### C.2.3: Interactive Scrollbar ✅ COMPLETE (2025-12-01 23:00)
- [x] Research complete (native support confirmed)
- [x] Enable interactive scrollbar
- [x] Configure appearance (transparency, colors)
- [x] Documented in kitty guide
- [x] Committed: `8fed456` - "feat: Add interactive clickable scrollbar"
- [ ] Test clickability and drag functionality (USER TODO)
- **Estimate:** 15 mins
- **Status:** Implemented, ready for user testing

##### C.2.4: Enhanced Tab Bar / Status Display ⏳ NEEDS CLARIFICATION
- [x] Research complete (use tab bar at bottom)
- [ ] User to specify what info to show (tab, dir, git, time, etc.)
- [ ] Move tab bar to bottom
- [ ] Add custom template
- [ ] Optional: Git branch detection script
- **Estimate:** 30-45 mins
- **Status:** Waiting for user clarification

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
- [x] User tested: F12 does NOT work (2025-12-01)
- [ ] Debug panel kitten on KDE Plasma
- [ ] Document platform-specific limitations
- [ ] Create workaround or alternative
- **Estimate:** 30-45 mins
- **Status:** F12 confirmed not working, needs debugging

---

#### Phase 1 (C.2 Advanced): System Metrics Status Bar & Advanced Features 🚀 IN PROGRESS (2025-12-01 23:00)

**Status:** Research Complete (0.87 confidence) | Implementation Starting
**Scope:** Custom Python tab bar with system metrics, advanced mouse actions, tab management
**Research:** Web Research Workflow completed 2025-12-01 23:15
**User Choice:** Option B (Full Advanced Status Bar)
**Estimated Time:** 4-6 hours total

##### C.2.7: Advanced Status Bar with System Metrics ⭐ MAIN TASK
**Goal:** Create custom Python tab_bar.py showing real-time system metrics

**Requirements (User-Specified):**
- [x] Research tab_bar.py customization (✅ Native support confirmed)
- [ ] Git branch (current repo branch)
- [ ] Time (HH:MM format)
- [ ] Layout name (active kitty layout)
- [ ] Tab number (current tab #)
- [ ] RAM usage (% or GB available)
- [ ] Network usage (up/down indicators)
- [ ] K8s context (current kubectl context) ⭐ CRITICAL for SRE
- [ ] Container count (running Docker/Podman containers)
- [ ] Disk usage - Root filesystem (/)
- [ ] Disk usage - Backups disk (if mounted)

**Implementation Steps:**
1. **Setup (15 mins)**
   - [ ] Create `~/.config/kitty/tab_bar.py`
   - [ ] Configure `kitty.conf`: `tab_bar_style custom`
   - [ ] Set `tab_bar_edge bottom`
   - [ ] Import required modules

2. **Basic Structure (30 mins)**
   - [ ] Implement `draw_tab()` function
   - [ ] Add timer for periodic updates (every 2 seconds)
   - [ ] Use `draw_tab_with_powerline()` for tab rendering
   - [ ] Add status section on last tab (right side)

3. **System Metrics Collection (1 hour)**
   - [ ] **CPU Usage** - Read from `/proc/stat`, calculate percentage
   - [ ] **RAM Usage** - Read from `/proc/meminfo`, show available GB or %
   - [ ] **Disk Usage (Root)** - Use `df /` or read `/proc/mounts`
   - [ ] **Disk Usage (Backups)** - Detect mount point, use `df`
   - [ ] **Network Stats** - Read from `/proc/net/dev` for active interface
   - [ ] Create helper functions for each metric
   - [ ] Add error handling for missing data

4. **K8s and Container Metrics (1 hour)**
   - [ ] **K8s Context** - Run `kubectl config current-context` via subprocess
   - [ ] **Container Count** - Run `docker ps -q | wc -l` or check `/var/run/docker.sock`
   - [ ] Cache results (update every 5 seconds, not every draw)
   - [ ] Add color coding (red for prod context!)

5. **Git and Layout Info (30 mins)**
   - [ ] **Git Branch** - Use `tab.active_wd` to detect git repo, run `git branch --show-current`
   - [ ] **Layout Name** - Available via tab_bar API
   - [ ] **Tab Number** - Use `index` parameter
   - [ ] **Time** - Use `datetime.now().strftime("%H:%M")`

6. **Visual Styling (30 mins)**
   - [ ] Color-code metrics (green/yellow/red thresholds)
   - [ ] Use theme colors from Dracula palette
   - [ ] Add separators between metrics
   - [ ] Ensure readability with current transparency

7. **Testing & Optimization (30 mins)**
   - [ ] Test with `Ctrl+Shift+F5` (reload config)
   - [ ] Verify all metrics display correctly
   - [ ] Check performance impact
   - [ ] Optimize refresh rate if needed
   - [ ] Test with multiple tabs open

**Estimate:** 4 hours
**Complexity:** HIGH (Custom Python scripting + system metrics)
**Confidence:** 0.85 (Research confirms feasibility)

---

##### C.2.8: Clickable Status Bar Elements ❌ NOT POSSIBLE
**Research Finding:** Kitty does NOT support custom clickable tab bar elements natively

**Alternatives:**
- [ ] Document limitation in kitty guide
- [ ] Use keyboard shortcuts for all actions
- [ ] Consider external panel (kitty-panel project) if clicking is critical

**Decision:** SKIP - Use keyboard-driven workflow instead
**Status:** Will not implement (not natively supported)

---

##### C.2.9: Window Splitting Configuration ✅ SIMPLE FIX
**Issue:** Kitty only splits horizontally on first terminal (not vertically)
**Cause:** Layout configuration (not using `splits` layout)

**Implementation:**
- [x] Research complete (found solution)
- [ ] Set `enabled_layouts splits:split_axis=auto`
- [ ] Configure explicit split shortcuts:
  - [ ] `F5` or custom key → horizontal split
  - [ ] `F6` or custom key → vertical split
- [ ] Test both horizontal and vertical splits work from start
- [ ] Document in kitty guide

**Estimate:** 15 mins
**Confidence:** 0.95 (Simple config change)

---

##### C.2.10: Advanced Mouse Actions (Right-Click) 🖱️
**Goal:** Configure sophisticated right-click behaviors using `mouse_map`

**Research Finding:** No native context menu, but `mouse_map` provides powerful alternatives

**Requirements (User-Specified):**
1. **On empty terminal area:**
   - [ ] Right-click → Paste from clipboard
   - [ ] Ctrl+Right-click → Split horizontally
   - [ ] Shift+Right-click → Split vertically
   - [ ] Alt+Right-click → New tab

2. **On selected text:**
   - [ ] Right-click → Copy selection
   - [ ] Middle-click → Paste from selection

3. **On tab bar (clicking tab):**
   - [ ] Right-click tab → Close tab (if possible)
   - [ ] Middle-click tab → Close tab

4. **Middle mouse button:**
   - [ ] Configure for copy + paste

**Implementation:**
```conf
# Right-click context-sensitive
mouse_map right press ungrabbed mouse_handle_click selection link prompt

# Right-click with modifiers for actions
mouse_map ctrl+right press ungrabbed launch --location=hsplit
mouse_map shift+right press ungrabbed launch --location=vsplit
mouse_map alt+right press ungrabbed new_tab

# Middle-click paste
mouse_map middle release ungrabbed paste_from_selection

# Selection copy (automatic with copy_on_select=yes)
copy_on_select yes
```

**Tasks:**
- [x] Research mouse_map capabilities
- [ ] Add mouse_map configurations to kitty.conf
- [ ] Test each mouse action
- [ ] Document in kitty guide

**Estimate:** 30 mins
**Confidence:** 0.90 (Well-documented feature)

---

##### C.2.11: Tab Management Enhancements 📑
**Goal:** Dynamic tab renaming and color customization

**Features:**
1. **Tab Renaming:**
   - [ ] Keyboard shortcut (F2 suggested) for interactive rename
   - [ ] Configure `map f2 set_tab_title`
   - [ ] Test renaming tabs

2. **Tab Colors:**
   - [ ] Research `kitty @ set-tab-color` command
   - [ ] Create keyboard shortcut to change tab color
   - [ ] Consider tab color presets (red=prod, yellow=staging, green=dev)

3. **Tab Title Templates:**
   - [ ] Update `tab_title_template` with useful info
   - [ ] Show window count if multiple windows in tab
   - [ ] Integrate with git branch (if in repo)

**Implementation:**
```conf
# Tab renaming
map f2 set_tab_title
map shift+f2 set_tab_title ""  # Reset to default

# Tab colors (via remote control - needs wrapper script)
# Create custom kitten for interactive color picker

# Tab title template
tab_title_template "{index}: {title[:25]}"
active_tab_title_template "[{layout_name}] {title[:25]}"
```

**Tasks:**
- [ ] Add F2 keybinding for tab rename
- [ ] Test tab renaming
- [ ] Research tab color changing options
- [ ] Create color preset script (optional)
- [ ] Update tab title templates

**Estimate:** 45 mins
**Confidence:** 0.95 (Fully supported features)

---

##### C.2.12: Terminal History Export (Markdown) 📝
**Goal:** Export terminal session history to markdown with timestamps

**User Requirements:**
- Format: Markdown
- Scope: Entire session (not just scrollback)
- Include: Timestamps
- Include: Commands + output

**Implementation Options:**

**Option A: Use kitty scrollback export**
```bash
# Kitty has native scrollback export
kitty @ get-text --extent=screen  # Current screen
kitty @ get-text --extent=all     # All scrollback
```

**Option B: Custom kitten**
- [ ] Create `~/.config/kitty/kittens/export_history.py`
- [ ] Read scrollback via kitty API
- [ ] Format as markdown with timestamps
- [ ] Save to file with date in name

**Tasks:**
- [ ] Research kitty text export capabilities
- [ ] Design markdown format
- [ ] Implement export script/kitten
- [ ] Add keyboard shortcut (Ctrl+Shift+H suggested)
- [ ] Test with various terminal outputs
- [ ] Handle large exports (pagination or limits)

**Estimate:** 1-1.5 hours
**Confidence:** 0.80 (Requires custom development)

---

**Phase C.2 Advanced Success Criteria:**
- [ ] Custom tab_bar.py showing all requested metrics
- [ ] Metrics update in real-time (1-2 second refresh)
- [ ] Window splitting works both horizontally and vertically
- [ ] Mouse actions configured and tested
- [ ] Tab renaming functional (F2 shortcut)
- [ ] Terminal history export working
- [ ] All changes documented in kitty guide
- [ ] All changes committed to dotfiles repo
- [ ] User testing complete and approved

**Total Estimated Time:** 6-8 hours
**Priority:** HIGH (User-requested comprehensive enhancement)
**Complexity:** HIGH (Custom Python scripting required)

---
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
- [ ] Scrollbar implemented and working
- [ ] Status bar/tab bar configured per user preferences
- [ ] History export functional
- [ ] F12 panel kitten debugged (if issues found)
- [ ] Theme issue resolved
- [ ] All limitations documented

---

#### Phase 2 (Phase D): Zellij Integration (FUTURE - 2-3 hours) 📋 PLANNED

**Priority:** MEDIUM (Powerful enhancement for SRE workflows)
**Risk:** LOW (well-planned, step-by-step)
**Reference:** `docs/plans/kitty-zellij-phase1-plan.md`

**What it includes:**
- Terminal multiplexer (like tmux, but modern)
- zjstatus beautiful status bar
- Catppuccin Mocha theme matching kitty
- Session persistence (detach/reattach)
- Custom layouts (dev, ops)

##### 2.1 Install Zellij via Home-Manager
- [ ] Create `home-manager/zellij.nix`:
  ```nix
  { config, pkgs, ... }:
  {
    home.packages = with pkgs; [ zellij ];
  }
  ```
- [ ] Import in `home-manager/home.nix`
- [ ] Build: `home-manager build --flake .#mitsio@shoshin`
- [ ] Switch: `home-manager switch --flake .#mitsio@shoshin`
- [ ] Verify: `which zellij && zellij --version`

##### 2.2 Configure Zellij with Catppuccin Theme
- [ ] Create `~/.config/zellij/config.kdl` with theme
- [ ] Create `~/.config/zellij/layouts/default.kdl`
- [ ] Test launch: `zellij`
- [ ] Add configs to chezmoi: `chezmoi add ~/.config/zellij/`

##### 2.3 Install zjstatus Plugin
- [ ] Download: `curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm -o ~/.config/zellij/plugins/zjstatus.wasm`
- [ ] Configure in `config.kdl` with Catppuccin Mocha colors
- [ ] Update default layout to use zjstatus
- [ ] Test status bar appearance
- [ ] Add plugin to chezmoi

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

### 10. Plasma Desktop Dotfiles Migration to Chezmoi (Multi-Phase) 🆕

**Status:** PHASE 0-2 COMPLETE ✅ | Phase 3 Pending (Next Session)
**Priority:** MEDIUM
**Estimated Time:** 12-18 hours (across 3-5 sessions)
**Goal:** Systematically investigate, document, and migrate all KDE Plasma configuration files to chezmoi
**Documentation:** `docs/dotfiles/plasma/` (session-context.md, local-investigation.md, research-findings.md)
**Session Summary:** `sessions/summaries/2025-12-02_PLASMA_DOTFILES_MIGRATION_PLANNING_PHASES_0_2.md`

**Prerequisites:**
- Read all existing plasma and home-manager documentation
- Archive deprecated plasmarc content
- Technical Researcher role for web research
- Planner role for migration planning

#### Phase 0: Documentation Consolidation & Cleanup ✅ COMPLETE (2025-12-02)

**Goal:** Establish clean documentation baseline before investigation

- [x] Read all existing documentation files:
  - [x] Read `docs/tools/plasma-manager.md` (already consolidated on 2025-11-29)
  - [x] Read `docs/chezmoi/` guides (01-07)
  - [x] Read `docs/adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md`
  - [x] Read `home-manager/plasma*.nix` modules
  - [x] Document current state of plasma configuration
- [x] Consolidate and merge documentation:
  - [x] Identified that plasma-manager docs already consolidated (no duplicates)
  - [x] Confirmed plasma-manager uses merge approach, not overwrite
  - [x] Noted plasma-manager writes to ~/.config/ directly (not Nix store symlinks)
  - [x] Created unified understanding of current setup
- [x] Archive deprecated content:
  - [x] No deprecated plasmarc docs found to archive (already cleaned up 2025-11-29)
- [x] Create session context document:
  - [x] Created `docs/dotfiles/plasma/session-context.md` (400+ lines)
  - [x] Documented findings from consolidation
  - [x] Listed active plasma configurations
  - [x] Noted gaps in current documentation

#### Phase 1: Local Investigation ✅ COMPLETE (2025-12-02)

**Goal:** Discover and categorize all plasma-related dotfiles in home directory

- [x] Investigate plasma config files in home directory:
  - [x] Listed all files under `~/.config/` matching plasma/kde/kwin patterns
  - [x] Listed all files under `~/.local/share/plasma-manager/` (tracking files)
  - [x] Checked kdeglobals, kwinrc, plasmashellrc, etc.
  - [x] Identified session management files
  - [x] Found theme and appearance configs
  - [x] Located widget/plasmoid configurations (plasma-org.kde.plasma.desktop-appletsrc)
  - [x] Discovered keyboard shortcut configs (kglobalshortcutsrc)
  - [x] Found window management (KWin) settings (kwinrc, kwinoutputconfig.json)
- [x] Categorize findings:
  - [x] Grouped by function: Core Plasma (13), KDE Apps (16+)
  - [x] Prioritized: HIGH (6), MEDIUM (10+), LOW, IGNORE
  - [x] Identified auto-generated (kded5rc/6rc, ksplashrc) vs user-modified
  - [x] Determined version control strategy per category
- [x] Document local investigation:
  - [x] Created `docs/dotfiles/plasma/local-investigation.md` (600+ lines)
  - [x] Listed all 40+ discovered files with paths, sizes, dates
  - [x] Analyzed plasma-manager coverage
  - [x] Created migration decision matrix
  - [x] Flagged hardware-specific configs (kwinoutputconfig.json)
- [x] **User approval received** to proceed to Phase 2

#### Phase 2: Web Research (Technical Researcher Role) ✅ COMPLETE (2025-12-02)

**Goal:** Gather authoritative information on KDE Plasma dotfiles and migration best practices

**Research Confidence Achieved:** 0.87 (Band C - HIGH)

- [x] Research plasma dotfiles structure (Topic 1): **c=0.85**
  - [x] Researched KDE Plasma 6 config structure (same as Plasma 5)
  - [x] Identified stable vs volatile sections (window pos, recent files = volatile)
  - [x] Documented safe version control patterns
  - [x] Found INI file format details and templating strategies
- [x] Research plasma-manager integration (Topic 2): **c=0.90**
  - [x] Confirmed plasma-manager MERGES configs (doesn't overwrite)
  - [x] Discovered plasma-manager writes to ~/.config/ (not Nix store symlinks)
  - [x] Understood immutability options ([$i] suffix)
  - [x] Identified gaps: volatile sections still need filtering
- [x] Research chezmoi + KDE best practices (Topic 3): **c=0.88**
  - [x] **🌟 MAJOR DISCOVERY:** chezmoi_modify_manager tool for filtering INI sections
  - [x] Found community patterns: simple configs → plain chezmoi, complex → modify_manager
  - [x] Documented .chezmoiignore patterns (**/*.src.ini, plasma-manager/, etc.)
  - [x] Identified templating strategy for hardware-specific configs
- [x] Synthesize research findings:
  - [x] Created `docs/dotfiles/plasma/research-findings.md` (600+ lines)
  - [x] Categorized by management approach (hybrid: plasma-manager + chezmoi + chezmoi_modify_manager)
  - [x] Documented best practices with real-world examples
  - [x] Listed authoritative sources (KDE docs, plasma-manager GitHub, community examples)
- [x] **User approval received** - Ready for Phase 3

**📁 Documentation Reorganization (End of Session 2025-12-02):**
- [x] Created `docs/dotfiles/` structure
- [x] Moved `docs/plasma/` → `docs/dotfiles/plasma/`
- [x] Moved `docs/chezmoi/` → `docs/dotfiles/chezmoi/`
- [x] Renamed all documentation files to lowercase
- [x] Created `docs/dotfiles/readme.md` (hybrid approach overview)
- [x] Created session summary: `sessions/summaries/2025-12-02_PLASMA_DOTFILES_MIGRATION_PLANNING_PHASES_0_2.md`

---

#### Phase 3: Migration Planning (Planner Role) ⏳ NEXT SESSION (2-3 hours)
**Goal:** Design a 3-5 phase migration plan for plasma dotfiles to chezmoi

**Prerequisites:** Phase 0, 1, 2 complete with user approval

**Guidelines:**
- Use Planner role throughout
- Use Sequential Thinking MCP for planning
- Create 3-5 implementation phases (1 phase per future session)
- Each phase should be completable in 2-4 hours

- [ ] Take Planner role and frame the migration:
  - [ ] Review all context from Phases 0-2
  - [ ] Clarify migration goals with user
  - [ ] Identify constraints (time, risk, reversibility)
  - [ ] Define success criteria
- [ ] Design migration phases:
  - [ ] Create 3-5 phases (each = 1 future session)
  - [ ] Each phase focuses on related configs
  - [ ] Order by: low-risk → high-risk
  - [ ] Ensure each phase is independently testable
  - [ ] Plan rollback strategy for each phase
- [ ] Create migration plan document:
  - [ ] Create `docs/chezmoi/plasma/MIGRATION_PLAN.md`
  - [ ] Document each phase with:
    - Phase number and name
    - Goals and scope
    - Files/configs to migrate
    - Step-by-step instructions
    - Testing and verification steps
    - Rollback procedure
  - [ ] Add assumptions and prerequisites
  - [ ] Include risk assessment
- [ ] Review plan with user:
  - [ ] Present plan summary
  - [ ] Discuss phase breakdown
  - [ ] Get approval to proceed with Phase 4 (execution)

#### Phase 4+: Migration Execution (Future - Per Phase Plan)
**Goal:** Execute the migration plan created in Phase 3

**Status:** NOT STARTED (depends on Phase 3 completion)

- [ ] Execute Phase 1 of migration plan (1 session)
- [ ] Execute Phase 2 of migration plan (1 session)
- [ ] Execute Phase 3 of migration plan (1 session)
- [ ] Execute Phase 4 of migration plan (if needed, 1 session)
- [ ] Execute Phase 5 of migration plan (if needed, 1 session)

---

### 11. Complete Home Directory Dotfiles Mapping & Documentation 🆕

**Status:** PLANNING
**Priority:** HIGH
**Estimated Time:** 10-15 hours (across 3-4 sessions)
**Goal:** Create comprehensive mapping and documentation of ALL dotfiles in home directory
**Documentation:** `docs/chezmoi/dotfiles-mapping.md` + detailed per-category docs

**Prerequisites:**
- Read all chezmoi documentation first
- Technical Researcher role for context gathering
- Iterative user collaboration (discuss at each major step)

**Guidelines:**
- Stop and discuss with user after each investigation phase
- Suggest categorization layers before implementing
- Gather user clarifications on ambiguous dotfiles
- Document everything for future reference

#### Phase 1: Documentation Review & Context Gathering (2-3 hours)

- [ ] Read all existing chezmoi documentation:
  - [ ] Read `docs/chezmoi/README.md`
  - [ ] Read `docs/chezmoi/MIGRATION_STATUS.md`
  - [ ] Read `docs/chezmoi/*.md` (all guides)
  - [ ] Read `docs/adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md`
  - [ ] Read `docs/adrs/ADR-007-AUTOSTART_TOOLS_VIA_HOME_MANAGER.md`
  - [ ] Review `.chezmoiignore` patterns
- [ ] Review current chezmoi state:
  - [ ] List all files currently in chezmoi source
  - [ ] Understand current categorization approach
  - [ ] Note which dotfiles already migrated
  - [ ] Identify current gaps in coverage
- [ ] Create baseline context document:
  - [ ] Create `docs/chezmoi/DOTFILES_INVESTIGATION_CONTEXT.md`
  - [ ] Document current chezmoi inventory
  - [ ] List known migrations (from MIGRATION_STATUS.md)
  - [ ] Define investigation scope

#### Phase 2: Home Directory Investigation (3-4 hours)

**Guidelines:** This is discovery phase. Create comprehensive inventory before categorization.

- [ ] Discover all dotfiles in home directory:
  - [ ] List all files in `~/.config/` (recursive)
  - [ ] List all dotfiles in `~/` (e.g., `.bashrc`, `.profile`, etc.)
  - [ ] List relevant files in `~/.local/` (config, state, share)
  - [ ] Identify hidden directories with configs
  - [ ] Note symlinks and their targets
- [ ] Gather metadata for each dotfile/directory:
  - [ ] File path
  - [ ] Size and modification date
  - [ ] Whether it's a file, directory, or symlink
  - [ ] Owner and permissions
  - [ ] Whether it exists in chezmoi already
  - [ ] Whether it's managed by home-manager
- [ ] Perform initial web research (when needed):
  - [ ] For unknown/ambiguous dotfiles, use web_research_workflow
  - [ ] Search: "what is [config file name] used for"
  - [ ] Identify the application/service for each config
  - [ ] Understand if config is stable or volatile
- [ ] **STOP HERE:** Present initial inventory to user, discuss scope

#### Phase 3: Categorization Strategy & User Collaboration (1-2 hours)

**Guidelines:** THIS IS CRITICAL - Get user input before finalizing categories

- [ ] Propose categorization layers:
  - [ ] Suggest primary categories (e.g., Desktop, Development, System, Applications)
  - [ ] Suggest subcategories within each primary
  - [ ] Propose management strategy categories:
    - Managed by chezmoi
    - Managed by home-manager
    - Should be ignored (auto-generated)
    - Unknown/needs investigation
  - [ ] **DISCUSS WITH USER:** Get feedback on proposed structure
- [ ] Refine categorization based on user input:
  - [ ] Adjust categories per user preferences
  - [ ] Add user-requested layers or groupings
  - [ ] Clarify edge cases and ambiguous items
- [ ] Create categorization rules document:
  - [ ] Document decision criteria for each category
  - [ ] Define what belongs in chezmoi vs home-manager
  - [ ] Establish naming conventions
  - [ ] Define priority levels (critical, important, optional)

#### Phase 4: Dotfiles Mapping Documentation (3-4 hours)

**Goal:** Create `dotfiles-mapping.md` with comprehensive categorized inventory

**Guidelines:** Stop after each category to discuss findings with user

- [ ] Create master mapping document:
  - [ ] Create `docs/chezmoi/dotfiles-mapping.md`
  - [ ] Structure with categories and subcategories
  - [ ] Use tables for organized presentation
- [ ] Document each dotfile/group with:
  - [ ] **Path:** Full path to config file/directory
  - [ ] **Application/Service:** What uses this config
  - [ ] **Description:** What this config controls
  - [ ] **Management Status:**
    - Currently in chezmoi (✅)
    - In home-manager (🏠)
    - Should migrate to chezmoi (📋)
    - Should stay in home-manager (🔧)
    - Should be ignored (🚫)
    - Unknown/needs research (❓)
  - [ ] **URLs:** Official config documentation
  - [ ] **Notes:** Important details, warnings, dependencies
- [ ] Categorize all findings:
  - [ ] **Desktop Environment:** KDE Plasma, themes, appearance
  - [ ] **Development Tools:** Git, editors, IDEs, language tools
  - [ ] **Terminal & Shell:** Bash, shell tools, prompt configs
  - [ ] **Applications:** Browser, utilities, productivity tools
  - [ ] **System Services:** Systemd user services, timers
  - [ ] **Secrets Management:** KeePassXC, secret-tool, wallets
  - [ ] **Sync & Backup:** rclone, syncthing, dropbox
  - [ ] **Other:** Miscellaneous configs
- [ ] **STOP AFTER EACH CATEGORY:** Review with user, get clarifications

#### Phase 5: Detailed Documentation (2-3 hours)

**Goal:** Create comprehensive per-dotfile or per-group documentation

**Decision Point:** Discuss with user whether to create:
- Option A: One large `dotfiles.md` with everything
- Option B: Separate files per category (e.g., `dotfiles-desktop.md`, `dotfiles-dev.md`)
- Option C: Per-dotfile docs for complex configs, grouped docs for simple ones

- [ ] **DISCUSS WITH USER:** Choose documentation structure
- [ ] Create detailed documentation:
  - [ ] For each dotfile or group, document:
    - **Purpose:** What it does
    - **Config Guidelines:** How to configure it
    - **Best Practices:** Recommended settings and patterns
    - **Chezmoi Guidelines:** How to manage it with chezmoi
      - Template needs (if any)
      - Secret handling (if applicable)
      - Platform-specific variations
      - Ignore patterns for generated content
    - **Official Documentation URLs:** Links to authoritative sources
    - **Examples:** Sample configurations or snippets
    - **Dependencies:** Related configs or services
    - **Migration Notes:** Considerations when moving to chezmoi
- [ ] Document undocumented findings:
  - [ ] Create `docs/chezmoi/UNDOCUMENTED_FINDINGS.md`
  - [ ] Capture any unusual or poorly-documented configs
  - [ ] Note workarounds or edge cases discovered
  - [ ] Document things that "just work" but aren't obvious why
  - [ ] Record useful context for future reference

#### Phase 6: Finalization & Review (1 hour)

- [ ] Final review with user:
  - [ ] Walk through dotfiles-mapping.md
  - [ ] Verify all categories make sense
  - [ ] Confirm management strategies
  - [ ] Get approval on priorities
- [ ] Commit all documentation:
  - [ ] Git add all new/updated docs
  - [ ] Create comprehensive commit message
  - [ ] Push to remote
- [ ] Update MIGRATION_STATUS.md:
  - [ ] Add reference to dotfiles-mapping.md
  - [ ] Update migration priorities based on findings
  - [ ] Note next steps for migrations

---

### 12. Chezmoi Migration

**Status:** IN PROGRESS (Week 48-49, 2025-11-29 to 2025-12-01)
**Documentation:**
- ADR: `docs/adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md`
- ADR: `docs/adrs/ADR-007-AUTOSTART_TOOLS_VIA_HOME_MANAGER.md` ✅ Implemented
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

#### Completed (2025-12-01) 🆕
- [x] Migrate VSCodium settings.json to chezmoi
- [x] Migrate complete CopyQ configuration (7 config files + themes)
- [x] Create autostart.nix module in home-manager
- [x] Migrate CopyQ autostart to home-manager
- [x] Migrate KeePassXC autostart to home-manager
- [x] Remove autostart directory from chezmoi
- [x] Update .chezmoiignore to exclude autostart permanently
- [x] Update MIGRATION_STATUS.md with new migrations
- [x] Update ADR-007 status to "✅ Implemented"
- [x] Clean up staging files (FiraCode.zip, kitty/, navi/)
- [x] Reset kitty config drift to chezmoi state

#### Pending
- [x] ~~Push dotfiles repo changes to origin~~ ✅ All repos committed and clean
- [x] ~~Push docs repo changes to origin~~ ✅ All repos committed and clean
- [x] ~~Push home-manager repo changes to origin~~ ✅ All repos committed and clean
- [ ] Test chezmoi apply on fresh terminal
- [ ] Migrate cline config (simple JSON, low effort)
- [ ] Set up age encryption for sensitive dotfiles
- [ ] Integrate KeePassXC with chezmoi templates
- [x] ~~Consider migrating: VSCodium settings~~ ✅ DONE (2025-12-01)

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

**Last Review:** 2025-12-01 23:30
**Next Review:** Weekly (every Sunday)
**Maintained by:** Dimitris Tsioumas (Mitsio)

---

## 🚨 CRITICAL ADDITIONS (2025-12-02)

### Claude Secrets Management (HIGH PRIORITY)

**Context:** User wants Claude Desktop and Claude Code API keys managed via KeePassXC integration

**Tasks:**
- [ ] 🚨 CRITICAL: Design KeePassXC secrets integration strategy for Claude configs
  - [ ] Identify KeePassXC systemd service (user mentioned but unsure of name)
  - [ ] Research how to access KeePassXC vault programmatically
  - [ ] Design template strategy for chezmoi to use KeePassXC
  - [ ] Document in `docs/security/CLAUDE_SECRETS_KEEPASSXC.md`

- [ ] 🚨 CRITICAL: Migrate ~/.config/Claude/ API keys to KeePassXC
  - [ ] Inventory all secrets in ~/.config/Claude/
  - [ ] Create KeePassXC entries for Claude Desktop API keys
  - [ ] Update chezmoi templates to fetch from KeePassXC
  - [ ] Test secret retrieval and Claude Desktop functionality

- [ ] 🚨 CRITICAL: Migrate ~/.claude.json API keys to KeePassXC
  - [ ] Inventory all secrets in ~/.claude.json (MCP configs, API keys)
  - [ ] Create KeePassXC entries for Claude Code credentials
  - [ ] Update chezmoi template to use KeePassXC integration
  - [ ] Test Claude Code functionality after migration

- [ ] Document backup strategy for _staging/ directory
  - [ ] Rule: All backup files go to dotfiles/_staging/
  - [ ] Update chezmoi best practices
  - [ ] Add to `docs/chezmoi/04-best-practices.md`

**Priority:** 🔴 HIGH - Must be completed before Claude configs can be safely managed
**Blocking:** Dotfiles migration for Claude Desktop and Claude Code
**Related:** Section 8 (Secrets Management Integration)

