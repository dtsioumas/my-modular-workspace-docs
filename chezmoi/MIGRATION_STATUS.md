# Chezmoi Migration Status

**Last Updated:** 2025-12-01
**Purpose:** Track what's managed by chezmoi vs home-manager

---

## Current State

### Managed by Chezmoi (`dotfiles/`)

| Config | Location | Status | Notes |
|--------|----------|--------|-------|
| Atuin | `dot_config/atuin/` | ✅ Active | Shell history sync |
| CopyQ | `dot_config/copyq/` | ✅ Active | Clipboard manager config |
| Git | `dot_gitconfig.tmpl` | ✅ Active | Cross-platform template |
| KeePassXC | `dot_config/keepassxc/` | ✅ Active | App settings only |
| Kitty | `dot_config/kitty/` | ✅ Active | Catppuccin Mocha theme |
| Navi | `dot_config/navi/` + `dot_local/share/navi/` | ✅ Active | Cheatsheets |
| Claude settings | `private_dot_claude/` | ✅ Active | Templated |
| Bashrc additions | `dot_bashrc.tmpl` | ✅ Active | Templated |
| **VSCodium settings** | `dot_config/VSCodium/User/settings.json` | ✅ Active | User preferences (NEW!) |

### Managed by Home-Manager

| Module | Purpose | Why Not Chezmoi |
|--------|---------|-----------------|
| `shell.nix` | Bash/env vars | System integration |
| `autostart.nix` | XDG autostart files | Systemd integration (NEW!) |
| `claude-code.nix` | npm CLI install | Package management |
| `vscodium.nix` | Package + product.json | Package management + marketplace |
| `brave.nix` | Browser + NVIDIA | Package overlays |
| `rclone-gdrive.nix` | Sync service | systemd timers |
| `syncthing-myspaces.nix` | P2P sync | systemd service |
| `dropbox.nix` | Cloud sync | systemd service |
| `symlinks.nix` | ~/.MyHome links | Nix file management |
| `local-mcp-servers.nix` | MCP derivations | Complex builds |

### Staging Directories (Ignored)

These exist in `dotfiles/` but are **ignored** via `.chezmoiignore`:

| Directory | Reason |
|-----------|--------|
| `kitty/` | Old staging - migrated to `dot_config/kitty/` |
| `navi/` | Staging - actual config in `dot_local/` |
| `BraveBrowser/` | Too large, browser profiles |
| `claude-code/`, `claude-desktop/` | Contains secrets |
| `KDE/`, `Plasma/` | Complex, needs testing |
| `vscode/`, `vscodium/` | Large, complex |

---

## Key Files

### `.chezmoiignore`

Comprehensive ignore patterns for:
- Staging directories (not ready for deployment)
- Backup files (`*.backup`, `*.old`)
- Large files (`*.zip`, `FiraCode.zip`)
- Windows files (`*.bat`, `*.ps1`)
- Platform-specific conditionals

### Naming Conventions

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dot_` | `.` prefix | `dot_bashrc` → `~/.bashrc` |
| `private_` | 0600 perms | `private_dot_ssh/` |
| `executable_` | 0755 perms | `executable_script.sh` |
| `.tmpl` | Template | `dot_bashrc.tmpl` |

---

## Migration Workflow

```bash
# 1. Add config to staging area
cp ~/.config/app/config dotfiles/app/config

# 2. Move to proper location
mkdir -p dotfiles/dot_config/app/
mv dotfiles/app/config dotfiles/dot_config/app/

# 3. Add staging dir to .chezmoiignore
echo "app/" >> dotfiles/.chezmoiignore

# 4. Preview and apply
chezmoi diff
chezmoi apply

# 5. Remove from home-manager (if applicable)
# Comment out import in home.nix
```

---

## Recent Migrations

### Git Config (2025-11-29)
- **From:** `programs.git` in home.nix
- **To:** `dotfiles/dot_gitconfig.tmpl`
- **Features:** Aliases, diff3 merge, platform-specific credential helpers

### Kitty (2025-11-29)
- **From:** `home-manager/kitty.nix` (Dracula theme)
- **To:** `dotfiles/dot_config/kitty/` (Catppuccin Mocha)
- **Merged:** Best features from both configs
- **Features:** Split windows, dynamic opacity, blur, 40+ keybindings
