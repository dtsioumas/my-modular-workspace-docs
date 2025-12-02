# Dotfiles Investigation Context

**Created:** 2025-12-02
**Purpose:** Baseline context for comprehensive home directory dotfiles mapping
**Related Task:** TODO.md section 11 - Complete Home Directory Dotfiles Mapping & Documentation
**Session:** Phase 1 of multi-session investigation project

---

## Session Goals

Create comprehensive mapping and documentation of **ALL** dotfiles in home directory (`~`) to establish:
- Clear categorization of all configs
- Management strategy for each dotfile (chezmoi, home-manager, or ignore)
- Migration priorities and actionable plan  
- Comprehensive documentation for future reference

---

## Current State Summary

### Existing Chezmoi Inventory

**Active in chezmoi** (`dotfiles/` repo):

| Config | Location | Status | Notes |
|--------|----------|--------|-------|
| Atuin | `dot_config/atuin/` | ✅ Active | Shell history sync |
| CopyQ | `dot_config/copyq/` | ✅ Active | Clipboard manager (7 config files + themes) |
| Git | `dot_gitconfig.tmpl` | ✅ Active | Cross-platform template with conditional credential helpers |
| KeePassXC | `dot_config/keepassxc/` | ✅ Active | App settings only (vault managed separately) |
| Kitty | `dot_config/kitty/` | ✅ Active | Dracula theme, full config migrated 2025-11-29 |
| Navi | `dot_config/navi/` + `dot_local/share/navi/` | ✅ Active | Cheatsheets (6 files, ~210 commands) |
| Claude settings | `private_dot_claude/` | ✅ Active | Templated settings |
| Bashrc additions | `dot_bashrc.tmpl` | ✅ Active | Platform-aware shell config |
| VSCodium settings | `dot_config/VSCodium/User/settings.json` | ✅ Active | User preferences (NEW: 2025-12-01) |

**Total Active Configs:** 9 applications/tools

### Home-Manager Managed

**Packages & Services** (not dotfiles):

| Module | Purpose | Why Not Chezmoi |
|--------|---------|-----------------|
| `shell.nix` | Bash/env vars | System integration (PATH, sessionPath) |
| `autostart.nix` | XDG autostart | Systemd integration (NEW: 2025-12-01) |
| `claude-code.nix` | npm CLI install | Package management |
| `vscodium.nix` | Package + product.json | Package management + marketplace config |
| `brave.nix` | Browser + NVIDIA | Package overlays, NVIDIA optimizations |
| `rclone-gdrive.nix` | Sync service | systemd timers (every 30min) |
| `syncthing-myspaces.nix` | P2P sync | systemd service (real-time) |
| `dropbox.nix` | Cloud sync | systemd service |
| `symlinks.nix` | ~/.MyHome links | Nix file management |
| `local-mcp-servers.nix` | MCP derivations | Complex builds (node2nix, buildGoModule) |
| `ansible-backup.nix` | Backup configs | Ansible orchestration |
| `ansible-collections.nix` | Collections | Ansible tooling |
| `git-hooks.nix` | Pre-commit | Nix integration |

**Home-Manager Packages Count:** 100+ packages (CLI tools, dev tools, editors, browsers, etc.)

---

## Known Migrations (From MIGRATION_STATUS.md)

### Recent Successful Migrations

1. **Git Config** (2025-11-29)
   - From: `programs.git` in home.nix
   - To: `dotfiles/dot_gitconfig.tmpl`

2. **Kitty** (2025-11-29)
   - From: `home-manager/kitty.nix`
   - To: `dotfiles/dot_config/kitty/` (Dracula theme)

3. **VSCodium Settings** (2025-12-01)
   - To: `dotfiles/dot_config/VSCodium/User/settings.json`

4. **CopyQ + KeePassXC Autostart** (2025-12-01)
   - Configs in chezmoi, autostart in home-manager

---

## Migration Criteria (ADR-005)

**Migrate to Chezmoi:** Cross-platform, simple configs, app settings, templates
**Keep in Home-Manager:** Packages, systemd services, Nix features, system integration

---

## Investigation Scope

### Priority 1: Plasma Desktop (USER REQUEST)
- All KDE/Plasma configs in `~/.config/`
- Theme and appearance settings
- KDE applications (Dolphin, Kate, Konsole, etc.)

### Priority 2: Claude Configs (USER REQUEST)  
- `~/.config/Claude/` - Desktop config
- `~/.claude.json` - Code settings
- ⚠️ Both contain API keys

### Priority 3: Remaining Applications
- Other `~/.config/` apps
- Root dotfiles in `~/`
- Relevant `~/.local/` configs

---

## User Preferences

1. **Context-wise continuation:** Document each phase, update TODO.md
2. **Priority:** Plasma → Claude → Rest
3. **Mapping first:** Understand before deciding migrations
4. **Ultrathink:** Perform ultrathink at END of each phase before documenting (user instruction)

---

**Status:** ✅ Phase 1 Baseline Complete
**Next:** Begin Phase 2 investigation
