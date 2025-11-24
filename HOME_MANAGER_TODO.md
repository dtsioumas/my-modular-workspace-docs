# Home-Manager Configuration TODO

**Last Updated:** 2025-11-24 00:00
**Location:** `~/.MyHome/MySpaces/my-modular-workspace/home-manager/`
**Repository:** https://github.com/dtsioumas/home-manager
**Current Generation:** #46

---

## ✅ Completed

### Podman Removal (2025-11-22)
- [x] Removed `podman` from home.packages
- [x] Removed `podman-desktop` from home.packages
- [x] Removed `podman-compose` from home.packages
- [x] Kept generic container tools (lazydocker, dive, skopeo, crane, ctop)
- [x] Verified rebuild successful
- [x] Confirmed podman commands not in PATH

### Documentation (2025-11-23)
- [x] Created `docs/DEBUGGING_AND_MAINTENANCE.md`
- [x] Documented build debugging workflows
- [x] Documented common errors and solutions
- [x] Documented maintenance procedures
- [x] Created best practices guide

### Navi Cheatsheets (2025-11-23)
- [x] Created `home-manager-build-debug.cheat`
- [x] Created `home-manager-maintenance.cheat`
- [x] Documented all common workflows
- [x] Added REPL debugging commands
- [x] Added generation management commands

### Build Testing & Package Conflicts (2025-11-23)
- [x] Read all documentation files (README.md, TODO.md, docs/, etc.)
- [x] Fixed VSCode/VSCodium package collision (removed `vscode`, kept `vscodium`)
- [x] Fixed Node.js version collision (removed `nodejs_24` from home.packages)
- [x] Removed `nodejs_24` from claude-code.nix and local-mcp-servers.nix
- [x] Fixed kubectl collision (removed standalone `kubectl`, kept k3s-bundled)
- [x] Added missing atuin.nix import to home.nix
- [x] Committed all changes to git
- [x] Pushed changes to github.com/dtsioumas/home-manager

### Symlink Resolution & Home-Manager Switch (2025-11-23)
- [x] Resolved symlink conflicts using `-b backup` flag
- [x] Created backup: `~/MyVault` → `~/MyVault.backup`
- [x] Created backup: `~/.mozilla/firefox/profiles.ini.backup`
- [x] Successfully switched to home-manager generation #46
- [x] Verified symlink chain: `~/.config/home-manager` → `~/.MyHome/MySpaces/my-modular-workspace/home-manager`
- [x] Confirmed all symlinks working (MyVault, MySpaces, Documents, etc.)
- [x] Verified services: Syncthing (active), Dropbox (started), rclone-gdrive-sync (scheduled)

### Service Cleanup (2025-11-23)
- [x] Removed `vscode-extensions-update.service` and `.timer` (no longer needed)
- [x] Removed `cline-update.service` and `.timer` (no longer needed)
- [x] Kept `claude-code-update.service` and `.timer` (will migrate to node2nix later)
- [x] Documented migration strategy in TODO.md

---

## 📋 Pending Tasks

### Immediate (2025-11-24)

**Post-Switch Tasks:**
- [ ] Test all applications after symlink changes (Firefox, VSCodium, etc.)
- [ ] Verify MyVault accessible and KeePassXC works
- [ ] Check if any services need manual restart
- [ ] Review and clean up `.backup` files if everything works correctly
- [ ] Fix `claude-code-update.timer` (currently inactive/failed)
- [ ] Optional: Rebuild home-manager to apply service cleanup
- [ ] Commit symlinks.nix changes (if any) to git

**Documentation Updates:**
- [ ] Update README.md with symlink structure explanation
- [ ] Document `-b backup` flag usage in debugging guide
- [ ] Add recovery procedures for symlink conflicts

---

### Highest Priority - Home-Manager Enchantments (Week 48)

**Session Directory:** `../sessions/home-manager-enchantments-week-48/`
**Detailed Plan:** `../sessions/home-manager-enchantments-week-48/PLAN.md`
**Detailed TODO:** `../sessions/home-manager-enchantments-week-48/TODO.md`

#### Phase 1: Semantic-Grep Installation
- [x] Create `semantic-grep.nix` with proper buildGoModule derivation
- [x] Set up word embedding model download automation
- [ ] Get correct hashes: Run `home-manager build --flake .#mitsio@shoshin`
- [ ] Update hashes in `semantic-grep.nix` based on build output
- [ ] Install and test semantic-grep (w2vgrep command)
- [ ] Create documentation at `docs/tools/semantic-grep/`
- [ ] Create navi cheatsheets in chezmoi repo

#### Phase 2: MCP Servers Reorganization
- [ ] Research node2nix for npm-based MCPs (use semantic-grep!)
- [ ] Create `mcps/` directory with individual MCP Nix files
- [ ] Convert all npm MCPs to node2nix derivations
  - [ ] context7-mcp
  - [ ] firecrawl-mcp
  - [ ] mcp-read-website-fast
- [ ] Create Go MCP derivations with buildGoModule
  - [ ] git-mcp-go
  - [ ] mcp-filesystem-server
  - [ ] mcp-shell
- [ ] Create Rust MCP derivations with buildRustPackage
  - [ ] rust-mcp-filesystem
- [ ] Handle Python/uv MCPs
  - [ ] mcp-server-fetch
  - [ ] mcp-server-time
  - [ ] sequential-thinking
- [ ] Install all to `~/.local-mcp-servers/<mcp-name>/`
- [ ] Update Claude Desktop config with new paths
- [ ] Test all MCPs working in Claude Desktop

#### Phase 3: Pre-commit Hooks Setup
- [ ] Add pre-commit-hooks.nix from cachix/git-hooks.nix
- [ ] Configure nixfmt/alejandra formatter
- [ ] Configure statix linter
- [ ] Configure deadnix dead code detector
- [ ] Create .pre-commit-config.yaml
- [ ] Test pre-commit workflow
- [ ] Document in README

#### Phase 4: Claude Desktop Config Management
- [ ] Move Claude config to chezmoi template
- [ ] Extract API keys to secrets management (KeePassXC or age)
- [ ] Parameterize MCP paths in template
- [ ] Test chezmoi apply
- [ ] Verify Claude Desktop works with templated config
- [ ] Document chezmoi workflow for config updates

**See `sessions/home-manager-enhancements/` for comprehensive task breakdown**

---

### Migration & Conflict Prevention (2025-11-23)

**Purpose:** Track home-manager components that need migration to avoid future conflicts

#### Completed Cleanup (2025-11-23)
- [x] Removed `vscode-extensions-update.service` and `.timer` (conflicted with manual extension management)
- [x] Removed `cline-update.service` and `.timer` (no longer needed)
- [x] Resolved symlink conflicts with `-b backup` during home-manager switch
- [x] Backed up `~/MyVault` and `~/.mozilla/firefox/profiles.ini`

#### Pending Migrations

**Services to Migrate:**
- [ ] `claude-code-update.service` + `.timer` - Migrate to node2nix derivation (Phase 2)
- [ ] `claude-code` activation script - Replace with proper Nix derivation

**Symlinks to Review:**
- [ ] Verify all `symlinks.nix` targets exist in `~/.MyHome/`
- [ ] Document symlink chain: `~/.config/home-manager` → Nix store → `~/.MyHome/MySpaces/my-modular-workspace/home-manager`
- [ ] Ensure no conflicts with chezmoi-managed dotfiles

**Configuration Files:**
- [ ] Firefox configuration (`programs.firefox`) - May conflict with existing profiles
- [ ] VSCodium settings - Currently managed by home-manager, consider chezmoi migration
- [ ] Plasma settings - Review for potential conflicts with KDE's own management

**NPM Global Packages:**
- [ ] Document all npm global packages in home-manager
- [ ] Plan migration strategy for `@anthropic-ai/claude-code`
- [ ] Plan migration strategy for `@cline/cline` (removed from services)
- [ ] Consider node2nix for all npm-based tools

**Activation Scripts to Review:**
- [ ] `install-claude-code` - Migrate to derivation
- [ ] `install-cline` - Migrate to derivation or remove if unused
- [ ] `update-vscode-extensions` - Keep or migrate to separate service?

**Priority Actions:**
1. Complete MCP servers migration to node2nix (Phase 2)
2. Document all potential conflicts in migration plan
3. Create rollback procedures for each migration step
4. Test migrations in isolated environment first

---

### High Priority

#### Lint Tools Research & Installation
- [ ] Research Nix formatters (nixpkgs-fmt, alejandra)
- [ ] Research syntax checkers (statix, deadnix)
- [ ] Test tools locally
- [ ] Add chosen tools to home.packages
- [ ] Configure VSCodium integration
- [ ] Create navi cheatsheet for linting
- [ ] Document in workflows

### Medium Priority

#### Configuration Optimization
- [ ] Review package list for unused packages
- [ ] Organize packages by category
- [ ] Consider splitting large home.nix into modules
- [ ] Review activation scripts for optimization

#### VSCodium Extensions
- [ ] Review extension list for redundancies
- [ ] Test extension update timer
- [ ] Verify excluded extensions are removed

#### Documentation
- [ ] Create quick reference card
- [ ] Document daily workflows
- [ ] Add troubleshooting examples from real issues
- [ ] Create upgrade guide for major changes

### Low Priority

#### Future Hosts
- [ ] Prepare configuration for laptop-system01
- [ ] Test configuration on WSL
- [ ] Create host-specific configurations if needed

#### Automation
- [ ] Consider automating weekly maintenance
- [ ] Add systemd timer for flake updates (optional)
- [ ] Create backup script for generations

---

## 📝 Notes

### Current Configuration

**Structure:**
```
home-manager/
├── flake.nix           # Standalone flake
├── flake.lock          # Lock file
├── home.nix            # Main config (imports all modules)
├── shell.nix           # Bash configuration
├── claude-code.nix     # Claude Code CLI
├── kitty.nix           # Kitty terminal
├── vscodium.nix        # VSCodium config
├── keepassxc.nix       # KeePassXC + vault sync
├── navi.nix            # Navi cheatsheet tool
└── docs/               # Documentation
    └── DEBUGGING_AND_MAINTENANCE.md
```

**Hosts:**
- `mitsio@shoshin` (active - desktop)
- `mitsio@laptop-system01` (planned - laptop)
- `mitsio@wsl-workspace` (future - WSL)

**Packages:** All from `nixpkgs-unstable`

### Common Commands

```bash
# Build
cd ~/MySpaces/my-modular-workspace/home-manager
home-manager build --flake .#mitsio@shoshin --show-trace

# Switch
home-manager switch --flake .#mitsio@shoshin

# Update inputs
nix flake update

# List generations
home-manager generations

# Expire old generations
home-manager expire-generations "7 days"

# Garbage collect
nix-collect-garbage --delete-old
```

### Debugging

```bash
# Clear eval cache (fixes "cached failure")
rm -rf ~/.cache/nix/eval-cache-*

# Use REPL
nix repl
:lf .
outputs.homeConfigurations."mitsio@shoshin".<TAB>

# Check option
home-manager option programs.git.enable

# Dry run
home-manager build --flake .#mitsio@shoshin --dry-run
```

### Maintenance Schedule

**Weekly:**
- Update flake inputs
- Delete generations > 7 days
- Garbage collect
- Optimize store

**Monthly:**
- Review package list
- Check for unused packages
- Review extension list
- Check disk space

---

## 🔗 References

- **Documentation:** `docs/DEBUGGING_AND_MAINTENANCE.md`
- **Navi Cheatsheets:** `~/.local/share/navi/cheats/home-manager-*.cheat`
- **Flake:** `flake.nix`
- **Main Config:** `home.nix`

---

**See Also:**
- NixOS configuration: `../nixos/`
- Documentation: `docs/`
- ADR (Architecture Decision Records): `docs/adr/`
