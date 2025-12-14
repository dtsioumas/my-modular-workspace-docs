# Dotfiles Inventory & Migration Priorities

**Last Updated:** 2025-12-14
**System:** shoshin (NixOS)
**Purpose:** Comprehensive inventory of dotfiles with migration priorities
**Consolidated from:** DOTFILES_INVENTORY, INITIAL_SCAN_FINDINGS, PRIORITY_SUMMARY, PRIORITY_APPS_DETAILED

---

## Summary Statistics

| Category | Count | Notes |
|----------|-------|-------|
| ~/.config/ directories | 125+ | Total scanned |
| Plasma/KDE configs | ~40 files | Desktop environment |
| Root dotfiles | ~30 | Excluding cache/history |
| Home-Manager managed | 6+ symlinks | Shell, profile, etc. |
| Chezmoi managed | 15+ | See MIGRATION_STATUS.md |

---

## Migration Priority Matrix

### 🔥 HIGH Priority (Migrate First)

| App/Config | Location | Status | Notes |
|------------|----------|--------|-------|
| **OBSIDIAN** | `~/.config/obsidian/` | ⏳ Pending | Minimal config (86B) |
| **CopyQ** | `~/.config/copyq/` | ✅ Migrated | 7 files + themes |
| **Flameshot** | `~/.config/flameshot/` | ⏳ Pending | Screenshot tool |
| **KDE Connect** | `~/.config/kdeconnect/` | ⚠️ Has secrets | TLS certs/keys |
| **btop** | `~/.config/btop/` | ⏳ Pending | 9.5K config |
| **KDE Plasma Core** | Various | ⏳ Pending | 40+ files |

### ⚠️ MEDIUM Priority

| App/Config | Location | Status | Notes |
|------------|----------|--------|-------|
| Discord | `~/.config/discord/` | ⏳ Pending | Settings only |
| Session Messenger | `~/.config/Session/` | ⏳ Pending | Electron app |
| Okular | `~/.config/okularrc` | ⏳ Pending | PDF viewer |
| Dolphin | `~/.config/dolphinrc` | ⏳ Pending | File manager |
| Spectacle | `~/.config/spectaclerc` | 🔻 Low | Migrating to Flameshot |
| pavucontrol | `~/.config/pavucontrol.ini` | ⏳ Pending | Audio control |

### 🔻 LOW Priority / Skip

| App/Config | Reason |
|------------|--------|
| Kate, KWrite | Rarely used |
| Konsole | User uses kitty |
| Firefox profiles | Too large, use sync |
| UserFeedback configs | Telemetry |
| .git-credentials | Deprecated (use systemd service) |

---

## Already Managed

### Chezmoi Managed (dotfiles/)

| Config | Location | Notes |
|--------|----------|-------|
| Atuin | `dot_config/atuin/` | Shell history sync |
| CopyQ | `dot_config/copyq/` | Clipboard manager |
| Git | `dot_gitconfig.tmpl` | Cross-platform |
| KeePassXC | `dot_config/keepassxc/` | App settings |
| Kitty | `dot_config/kitty/` | Catppuccin Mocha |
| Navi | `dot_config/navi/` + `dot_local/` | Cheatsheets |
| Claude | `private_dot_claude/` | Settings + MCP |
| Codex | `private_dot_codex/` | Config template |
| Gemini | `private_dot_gemini/` | Settings |
| VSCodium | `dot_config/VSCodium/` | User settings |
| Bashrc | `dot_bashrc.tmpl` | Additions |
| Zellij | `private_dot_config/zellij/` | Layouts + config |

### Home-Manager Managed

| Module | Purpose | Why Not Chezmoi |
|--------|---------|-----------------|
| `shell.nix` | Bash/env vars | System integration |
| `autostart.nix` | XDG autostart | Systemd integration |
| `claude-code.nix` | npm CLI | Package management |
| `vscodium.nix` | Package | Marketplace config |
| `brave.nix` | Browser | NVIDIA overlays |
| `symlinks.nix` | ~/.MyHome | Nix file management |
| `CLAUDE.md` | Global instructions | Nix module integration |

---

## KDE Plasma Desktop

### Core Plasma Files

| File | Purpose | Priority |
|------|---------|----------|
| `plasmarc` | Plasma shell | ✅ High |
| `plasmashellrc` | Panel config | ✅ High |
| `plasma-org.kde.plasma.desktop-appletsrc` | Widgets | ✅ High |
| `kdeglobals` | Theme, colors, fonts | ✅ High |
| `kglobalshortcutsrc` | Keyboard shortcuts (16K!) | ✅ High |
| `kwinrc` | Window manager | ✅ High |
| `kwinoutputconfig.json` | Display config | ⚠️ Hardware-specific |

### KDE System Components

| File | Purpose | Priority |
|------|---------|----------|
| `ksmserverrc` | Session manager | ✅ |
| `krunnerrc` | KRunner launcher | ✅ |
| `kscreenlockerrc` | Screen locker | ✅ |
| `powerdevilrc` | Power management | ✅ |
| `plasmanotifyrc` | Notifications | ✅ |
| `kactivitymanagerdrc` | Activity manager | ✅ |
| `kxkbrc` | Keyboard layout | ✅ |

### KDE Applications

| App | Config | Priority | Notes |
|-----|--------|----------|-------|
| Dolphin | `dolphinrc` | ✅ | File manager - IMPORTANT |
| Spectacle | `spectaclerc` | 🔻 | Migrating to Flameshot |
| Okular | `okularrc` | ⚠️ | PDF viewer |
| Kate | `katerc` | 🔻 | Text editor |
| KWrite | `kwriterc` | 🔻 | Simple editor |
| Gwenview | `gwenviewrc` | ⚠️ | Image viewer |

---

## Communication Apps

### Session Messenger (`~/.config/Session/`)

**Important Files:**
- `config.json` (190B)
- `ephemeral.json` (161B)

**Ignore (Cache):**
- Cache/, Code Cache/, GPUCache/, blob_storage/
- Crashpad/, DawnCache/, attachments.noindex/

### Discord (`~/.config/discord/`)

**Important Files:**
- `settings.json` (296B)
- `Preferences` (208B)
- `quotes.json` (34B)

**Ignore (Cache):**
- Cache/, Code Cache/, GPUCache/, blob_storage/
- IndexedDB/, Local Storage/

### Signal

**Status:** ⚠️ NOT FOUND in ~/.config/
- May not be installed or uses different location

---

## Root Dotfiles (~/)

### Home-Manager Managed (Symlinks)

| File | Target |
|------|--------|
| `~/.bash_profile` | /nix/store/...-home-manager-files/ |
| `~/.bashrc` | /nix/store/...-home-manager-files/ |
| `~/.profile` | /nix/store/...-home-manager-files/ |
| `~/.npmrc` | /nix/store/...-home-manager-files/ |
| `~/.keep-myvault` | /nix/store/...-home-manager-files/ |

### Standalone (Not Managed)

| File | Purpose | Action |
|------|---------|--------|
| `~/.gtkrc-2.0` | GTK 2.0 theme | ✅ Migrate |
| `~/.icons/` | Custom icons | ⚠️ Review |
| `~/.bash_history` | Command history | ❌ Don't manage |
| `~/.viminfo` | Vim session | ❌ Don't manage |
| `~/.git-credentials` | Git creds | ❌ Deprecated |

### Development Directories

| Directory | Purpose | Priority |
|-----------|---------|----------|
| `.ansible/` | Ansible data | ✅ High |
| `.bun/` | Bun JS runtime | ⚠️ Maybe |
| `.dotnet/` | .NET SDK | 🔻 Low |
| `.eclipse/` | Eclipse IDE | 🔻 Low |
| `.minikube/` | Kubernetes | 🔻 Low |

---

## Secrets & Security

### Files with Secrets (Handle Carefully)

| File/Dir | Contents | Strategy |
|----------|----------|----------|
| `~/.config/kdeconnect/certificate.pem` | TLS cert | private_ prefix |
| `~/.config/kdeconnect/privateKey.pem` | Private key | private_ + age |
| `~/.config/Claude/` | API keys | Template with KeePassXC |
| `~/.claude.json` | Settings + keys | Template |
| `~/.ssh/` | SSH keys | age encryption |

### Secrets Management Strategy

1. **KeePassXC** - Source of truth
2. **Chezmoi templates** - Dynamic insertion
3. **age encryption** - Static sensitive files
4. **private_ prefix** - Correct permissions (0600)

---

## User Preferences Summary

**What User Uses:**
- **Desktop:** KDE Plasma (core + important apps)
- **Terminal:** kitty (NOT Konsole)
- **Browser:** Brave (main), Firefox (backup)
- **Screenshot:** Flameshot (migrating from Spectacle)
- **Clipboard:** CopyQ (highly important)
- **Notes:** OBSIDIAN (highly important)
- **Phone:** KDE Connect (really important)
- **Monitoring:** btop, htop
- **Messaging:** Session, Discord

**Secrets Management:**
- KeePassXC for all secrets (NOT KDE Wallet)
- Systemd service for credential access
- age encryption for sensitive files

---

## Staging Directory

**Location:** `dotfiles/_staging/`
**Purpose:** Backup/reference for safe migration

| Directory | Contents |
|-----------|----------|
| BraveBrowser/ | Browser profile backup |
| claude-code/ | Claude Code backup |
| claude-desktop/ | Claude Desktop backup |
| KDE/ | KDE configs backup |
| Plasma/ | Plasma configs backup |
| vscode/ | VS Code backup |
| vscodium/ | VSCodium backup |
| zellij/ | Zellij backup |
| llm-cli/ | LLM CLI backup |

**Note:** All staging contents are IGNORED by chezmoi via `.chezmoiignore`

---

## Next Actions

### Ready to Migrate NOW

1. OBSIDIAN config
2. btop.conf + themes
3. KDE Connect (with private_ prefix)
4. Plasma notification configs
5. pavucontrol.ini
6. Session messenger (config.json only)
7. Discord (settings.json only)

### Needs Investigation

1. Signal location/status
2. pulse/ directory contents
3. Audio tools identification
4. KDE Plasma full scan

### After User Approval

1. Create detailed per-app migration
2. Design .chezmoiignore patterns
3. Test on clean system

---

## Related Documentation

- [chezmoi-guide.md](chezmoi-guide.md) - Implementation guide
- [MIGRATION_STATUS.md](MIGRATION_STATUS.md) - Current progress
- [README.md](README.md) - Documentation index

---

**Maintained by:** Dimitris Tsioumas
**Original Sources:** INITIAL_SCAN_FINDINGS, PRIORITY_SUMMARY, PRIORITY_APPS_DETAILED, dotfiles_investigation_context
