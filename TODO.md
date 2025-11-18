# TODO - Home-Manager Decoupling Project

**Project:** my-modular-workspace-decoupling-home
**Started:** 2025-11-17
**Status:** Phase 1 Complete - Testing Phase

---

## 🎯 Project Goals

- [x] Decouple home-manager from NixOS system
- [x] Create standalone, portable home-manager configuration
- [x] Change username: mitso → mitsio
- [x] Use unstable packages for user environment (latest versions)
- [x] Enable multi-OS deployment (NixOS, Fedora, WSL)
- [ ] Test and verify complete setup
- [ ] Refactor to modular structure (Phase 2)

---

## 📋 Phase 1: Standalone Home-Manager (COMPLETE ✅)

### System Changes (DONE)
- [x] Change username mitso → mitsio in NixOS config
- [x] Update all user references in system modules
- [x] Remove home-manager module from NixOS flake.nix
- [x] Remove home-manager, plasma-manager inputs
- [x] Remove claude-desktop from system (moved to home)
- [x] Minimal system packages (remove GUI apps)
- [x] System rebuild successful
- [x] User mitsio created (uid=1001)
- [x] Password set for mitsio

### Home-Manager Repo (DONE)
- [x] Create `~/.config/my-home-manager-flake/` repository
- [x] Create standalone flake.nix (nixpkgs-unstable)
- [x] Copy all config files from old home/mitso/
- [x] Update username to mitsio throughout configs
- [x] Verify no hardcoded paths (use ${config.home.homeDirectory})
- [x] Create .gitignore
- [x] Create README.md
- [x] Git init and commit

### Documentation (DONE)
- [x] Create ADR-001: stable vs unstable architecture decision
- [x] Create comprehensive session docs
- [x] Create implementation steps guide
- [x] Create session summary
- [x] Save project state to thread-continuity MCP

---

## 🚀 Phase 1.5: Migration & Testing (IN PROGRESS ⏳)

### Data Migration (CURRENT)
- [ ] **Run full home migration script as root**
  ```bash
  su -
  bash /home/mitso/migrate-full-home-as-root.sh
  exit
  ```
  - [ ] Verify all files migrated
  - [ ] Verify permissions correct (.ssh: 700/600, .gnupg: 700/600)
  - [ ] Verify ownership (mitsio:users)

### System Testing
- [ ] **Reboot system**
  ```bash
  sudo reboot
  ```

- [ ] **Login as mitsio**
  - [ ] Password works
  - [ ] KDE Plasma loads
  - [ ] Can access files

- [ ] **Apply home-manager configuration**
  ```bash
  cd ~/.config/my-home-manager-flake
  nix flake lock
  home-manager switch --flake .#mitsio@shoshin
  ```
  - [ ] Build succeeds without errors
  - [ ] All packages install (~100+ packages from unstable)
  - [ ] Note any errors or warnings

### Verification Checklist
- [ ] **Shell Environment**
  - [ ] Bash loads correctly
  - [ ] Aliases work (gs, ga, gc, nrs, bwu, etc.)
  - [ ] PATH includes npm-global and go bins
  - [ ] EDITOR, GOPATH, GOBIN set correctly
  - [ ] Greeting message displays

- [ ] **GUI Applications**
  - [ ] Firefox launches
  - [ ] Brave launches
  - [ ] Kitty terminal works
  - [ ] VSCodium/VSCode launches
  - [ ] KeePassXC launches
  - [ ] Obsidian launches
  - [ ] Discord launches

- [ ] **Development Tools**
  - [ ] Git config correct (name, email)
  - [ ] Git aliases work
  - [ ] Python available
  - [ ] Go available
  - [ ] Node.js available
  - [ ] Claude Code CLI works

- [ ] **KDE Plasma Settings**
  - [ ] Panels correct (top/bottom)
  - [ ] Keyboard shortcuts work
  - [ ] Virtual desktops configured
  - [ ] Themes applied
  - [ ] System tray widgets correct

- [ ] **User Services**
  - [ ] Check systemd user services: `systemctl --user status`
  - [ ] KeePassXC vault sync timer: `systemctl --user status keepassxc-vault-sync.timer`
  - [ ] VSCode extension updater: `systemctl --user status vscode-extensions-update.timer`
  - [ ] Cline updater: `systemctl --user status cline-update.timer`
  - [ ] Claude Code updater: `systemctl --user status claude-code-update.timer`

- [ ] **Data Integrity**
  - [ ] MyVault/ exists and accessible
  - [ ] SSH keys work (test git push/pull)
  - [ ] GPG keys work (if used)
  - [ ] rclone config exists
  - [ ] Dropbox syncing
  - [ ] GoogleDrive accessible
  - [ ] Workspaces symlink correct
  - [ ] Projects accessible

---

## 🐛 Phase 1.6: Bug Fixes & Refinements (PENDING)

### Known Issues to Fix
- [ ] **Fix syncthing-myspaces.nix**
  - Currently syncs MySpaces, should sync MyHome
  - Update paths in `/home/mitso/.config/nixos/modules/workspace/syncthing-myspaces.nix`

- [ ] **Add missing packages to home-manager**
  - Currently only has `ast-grep`
  - Need to add ALL GUI apps, browsers, dev tools (~100+ packages)
  - See: current system packages.nix for full list to migrate

- [ ] **Test on clean boot**
  - Reboot and verify everything persists
  - Check services auto-start

### Optional Improvements
- [ ] Add more comprehensive git aliases
- [ ] Configure Bitwarden CLI integration
- [ ] Add development environment configs (Python, Go, Node)
- [ ] Configure VSCode settings via home-manager
- [ ] Add custom KDE themes/icons

---

## 📦 Phase 2: Modular Refactor (PLANNED)

**Reference:** `HOME-MANAGER_REPO_SKELETON_DRAFT_1.md`

### Restructure home-manager repo
- [ ] Create modular directory structure:
  ```
  my-home-manager-flake/
  ├── flake.nix
  ├── home/
  │   ├── common/
  │   │   ├── core.nix           # username, stateVersion, basic env
  │   │   ├── cli-tools.nix      # generic CLI tools
  │   │   ├── dev-core.nix       # git config, editor defaults
  │   │   └── secrets.nix        # secrets management
  │   └── mitsio/
  │       ├── default.nix        # main entry, imports everything
  │       ├── shell.nix          # bash config
  │       ├── editors.nix        # kitty + vscodium merged
  │       ├── desktop.nix        # plasma settings
  │       ├── dev-go.nix         # Go tools
  │       ├── dev-python.nix     # Python tools
  │       ├── dev-js.nix         # JS/Node tools
  │       ├── llm-tools.nix      # claude-code, cline
  │       ├── vaults.nix         # keepassxc
  │       └── machines/
  │           ├── shoshin.nix    # NixOS-specific overrides
  │           ├── kinoite.nix    # Fedora-specific
  │           └── wsl-workspace.nix
  └── hosts/
      ├── shoshin.nix
      ├── kinoite.nix
      └── wsl-workspace.nix
  ```

### Split monolithic files
- [ ] Extract common configs to `home/common/`
- [ ] Split `home.nix` into modules
- [ ] Merge `kitty.nix` + `vscodium.nix` → `editors.nix`
- [ ] Rename `claude-code.nix` → `llm-tools.nix` (add Cline)
- [ ] Move NixOS-specific aliases to `machines/shoshin.nix`
- [ ] Create host entry points in `hosts/`

### Test modular structure
- [ ] Build and test: `home-manager switch --flake .#mitsio@shoshin`
- [ ] Verify no regressions
- [ ] Update documentation

---

## 🌐 Phase 3: Multi-OS Support (FUTURE)

### Fedora Kinoite Setup
- [ ] Create Fedora Kinoite bluebuild image (or use stock)
- [ ] Install Fedora Kinoite on shoshin (replaces NixOS)
- [ ] Install Nix package manager
- [ ] Install home-manager
- [ ] Clone my-home-manager-flake repo
- [ ] Apply: `home-manager switch --flake .#mitsio@kinoite`
- [ ] Verify same user experience as NixOS
- [ ] Document Fedora-specific quirks

### WSL Support
- [ ] Install WSL2 on work laptop (if applicable)
- [ ] Install Nix in WSL
- [ ] Clone my-home-manager-flake repo
- [ ] Create WSL-specific config (no desktop)
- [ ] Apply: `home-manager switch --flake .#mitsio@wsl-workspace`
- [ ] Test dev tools work in WSL

---

## 🧹 Phase 4: Cleanup (AFTER TESTING)

### Remove old user (CAREFUL!)
- [ ] Verify mitsio user works 100%
- [ ] Verify all data migrated
- [ ] **Backup important files** (just in case)
- [ ] Remove mitso user from NixOS config:
  ```nix
  # In configuration.nix, delete entire users.users.mitso block
  # OR set: users.users.mitso = null;
  ```
- [ ] Rebuild NixOS
- [ ] **Delete old home directory:**
  ```bash
  sudo rm -rf /home/mitso/
  ```

### Repository Management
- [ ] Push NixOS config to git remote (if applicable)
- [ ] Push my-home-manager-flake to GitHub/GitLab
- [ ] Make repo private (contains configs but no secrets)
- [ ] Add proper README
- [ ] Tag releases (v1.0-phase1-complete, etc.)

---

## 📚 Documentation Tasks

### Complete Documentation
- [ ] Add troubleshooting guide
- [ ] Document common workflows
- [ ] Create migration guide for future systems
- [ ] Add screenshots of final setup
- [ ] Document lessons learned

### Update ADRs
- [ ] Create ADR-002 (if needed for major decisions)
- [ ] Document tool choices (chezmoi, stow, ansible plans)

---

## 🔮 Phase 5: Advanced Features (OPTIONAL)

### Dotfile Management
- [ ] Evaluate chezmoi vs current approach
- [ ] Consider GNU Stow for additional flexibility
- [ ] Implement dotfile templating if needed

### Secrets Management
- [ ] Implement sops-nix for encrypted secrets in repo
- [ ] Integrate with KeePassXC CLI
- [ ] Automate secret retrieval from vault

### Ansible Bootstrap
- [ ] Create Ansible playbook for fresh system setup
- [ ] Automate: Nix install → home-manager → apply configs
- [ ] Test on clean Fedora install
- [ ] Create "from zero to hero" script

### Multi-Machine Setup
- [ ] Add laptop-specific configs
- [ ] Sync settings across machines
- [ ] Document machine-specific overrides

---

## 📊 Success Metrics

### Phase 1 Success
- [x] NixOS system minimal and stable
- [x] Home-manager standalone and portable
- [x] Username changed successfully
- [ ] All packages install from unstable
- [ ] All services work
- [ ] No data loss
- [ ] System survives reboot

### Phase 2 Success
- [ ] Modular structure implemented
- [ ] Easier to maintain and understand
- [ ] No regressions from refactor

### Phase 3 Success
- [ ] Same user experience on Fedora
- [ ] Easy migration process
- [ ] Documented for future use

---

## 🆘 Troubleshooting Guide

### If home-manager build fails
```bash
# Check flake syntax
nix flake check

# Show detailed errors
home-manager switch --flake .#mitsio@shoshin --show-trace

# Check specific module
nix eval .#homeConfigurations."mitsio@shoshin".config.home.packages
```

### If services don't start
```bash
# Check all user services
systemctl --user status

# Restart specific service
systemctl --user restart keepassxc-vault-sync

# View logs
journalctl --user -u keepassxc-vault-sync -f
```

### If packages missing
```bash
# List installed packages
home-manager packages

# Search for package
nix search nixpkgs <package-name>

# Add to home.packages in home.nix
```

### If rollback needed
```bash
# List generations
home-manager generations

# Rollback to previous
home-manager switch --rollback

# Or specific generation
/nix/store/...-home-manager-generation/activate
```

---

## 📝 Notes & Reminders

### Important Paths
- **NixOS config:** `~/.config/nixos/`
- **Home-manager:** `~/.config/my-home-manager-flake/`
- **Session docs:** `~/my-modular-workspace-decoupling-home/docs/`
- **Migration script:** `/home/mitso/migrate-full-home-as-root.sh`

### Key Commands
```bash
# Rebuild NixOS system
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin

# Apply home-manager
home-manager switch --flake ~/.config/my-home-manager-flake#mitsio@shoshin

# Update all packages
nix flake update && home-manager switch --flake ...

# Check home-manager status
home-manager packages
home-manager generations
```

### References
- **ADR-001:** Architecture decisions (stable vs unstable)
- **Skeleton:** HOME-MANAGER_REPO_SKELETON_DRAFT_1.md
- **Summary:** SESSION_SUMMARY.md

---

## ✅ Quick Start (Resume Session)

**If resuming from saved state:**

1. Load project state:
   ```
   Load project: my-modular-workspace-decoupling-home
   ```

2. Read documentation:
   ```bash
   cd ~/my-modular-workspace-decoupling-home/docs
   cat SESSION_SUMMARY.md
   cat TODO.md  # this file
   ```

3. Continue from current phase (check checkboxes above)

---

**Last Updated:** 2025-11-17
**Current Phase:** 1.5 - Migration & Testing
**Next Action:** Run migration script as root, reboot, test home-manager

---

## 🎯 TODAY'S PRIORITY

1. ✅ **Reboot system** (DONE - 2025-11-17)
2. ⏳ **Apply home-manager with node2nix** (IN PROGRESS)
3. ⏳ **Convert npm packages to node2nix** (Next)
4. ⏳ **Test all packages and services**
5. 📋 **Mark items complete in this TODO**

### 🆕 Node2nix Integration (2025-11-17)
- [x] Add node2nix to home.packages
- [x] Create npm-packages.json specification
- [x] Document node2nix setup (see docs/NODE2NIX_INTEGRATION.md)
- [x] Inventory all npm global packages (see docs/NPM_PACKAGES_INVENTORY.md)
- [x] Update npm-packages.json with all 4 packages:
  - @anthropic-ai/claude-code
  - @just-every/mcp-read-website-fast
  - @upstash/context7-mcp
  - firecrawl-mcp
- [ ] Generate Nix expressions with node2nix
- [ ] Update home.nix to use generated expressions
- [ ] Replace npm activation scripts with declarative packages
- [ ] Test all binaries work (claude-code, MCP servers)
- [ ] Commit generated files to git
- [ ] Remove old npm global packages

### 🌊 Ephemeral Home Practices Research (2025-11-17)
- [x] Research NixOS impermanence module and practices
- [x] Document ephemeral practices (see docs/EPHEMERAL_HOME_PRACTICES.md)
- [x] Compile resource URLs (see docs/EPHEMERAL_RESOURCES.md)
- [x] Evaluate impermanence vs chezmoi for our use case
- [ ] **Decision:** Impermanence or chezmoi approach?
- [ ] Clean up mitso leftovers from /home/mitsio
- [ ] Audit home directory for unnecessary files
- [ ] Create ephemeral vs persistent file list

**After completing Priority 1-4, all of Phase 1 is DONE! 🎉**
