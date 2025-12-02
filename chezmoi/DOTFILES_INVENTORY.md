# Dotfiles Inventory - Complete Analysis

**Created:** 2025-11-18
**System:** shoshin (NixOS)
**User:** mitsio
**Purpose:** Comprehensive inventory of all dotfiles for chezmoi migration
**Comment** This file needs review, it's the inventory of dotfiles. Don't migrate dotfiles before discuss with user each use case.
---

## 📋 Inventory Summary

**Total Configuration Directories:** 47+ in `~/.config/`
**Total Root Dotfiles:** 10+ in `~`
**Home-Manager Managed:** 6 symlinks
**Standalone Files:** Many

---

## 🏠 Home Directory Dotfiles

### Home-Manager Managed (Symlinks to /nix/store)

| File | Target | Source | Status |
|------|--------|--------|--------|
| `~/.bash_profile` | `/nix/store/...-home-manager-files/.bash_profile` | Home-Manager | ✅ Managed |
| `~/.bashrc` | `/nix/store/...-home-manager-files/.bashrc` | Home-Manager | ✅ Managed |
| `~/.profile` | `/nix/store/...-home-manager-files/.profile` | Home-Manager | ✅ Managed |
| `~/.npmrc` | `/nix/store/...-home-manager-files/.npmrc` | Home-Manager | ✅ Managed |
| `~/.keep-myvault` | `/nix/store/...-home-manager-files/.keep-myvault` | Home-Manager | ✅ Managed |
| `~/.nix-profile` | System symlink | Nix | ⚠️ System |

### Standalone Dotfiles (NOT managed)

| File | Purpose | Source App/Tool | Action |
|------|---------|-----------------|--------|
| `~/.bash_history` | Bash command history | Bash | ❌ Don't manage |
| `~/.bashrc.backup` | Backup file | Manual | ❌ Don't manage |
| `~/.gtkrc-2.0` | GTK 2.0 theme config | GTK | ✅ Migrate |
| `~/.viminfo` | Vim session info | Vim | ❌ Don't manage |
| `~/.npmrc.backup` | Backup file | Manual | ❌ Don't manage |
| `~/.claude.json` | Claude settings | Claude Desktop | ⚠️ Contains secrets |
| `~/.claude.json.backup*` | Backup files | Manual | ❌ Don't manage |

---

## ⚙️ ~/.config/ Directory Analysis

### Development Tools

#### Code Editors & IDEs

| Directory/File | App | Purpose | Migrate? | Notes |
|---------------|-----|---------|----------|-------|
| `Code/` | VS Code / VSCodium | Editor settings, extensions | ✅ Yes | Large directory |
| `kate/` | Kate (KDE) | KDE text editor | ✅ Yes | KDE-specific |
| `katerc`, `katemetainfos`, `katevirc` | Kate | Kate configs | ✅ Yes | KDE-specific |

#### Version Control

| Directory/File | App | Purpose | Migrate? | Notes |
|---------------|-----|---------|----------|-------|
| `git/` | Git | Git global config | ✅ Yes | Home-Manager managed? |
| `gh/` | GitHub CLI | GitHub CLI settings | ✅ Yes | Contains credentials? |

#### Language-Specific

| Directory/File | App | Purpose | Migrate? | Notes |
|---------------|-----|---------|----------|-------|
| `go/` | Go | Go environment | ✅ Yes | Development config |
| `godot/` | Godot Engine | Game engine settings | ⚠️ Maybe | Project-specific? |

---

### Terminal & Shell

| Directory/File | App | Purpose | Migrate? | Notes |
|---------------|-----|---------|----------|-------|
| `kitty/` | Kitty Terminal | Terminal emulator config | ✅ Yes | Currently managed by HM |
| `kitty.old` | Legacy | Symlink to old config | ❌ No | Remove |
| `konsolerc` | Konsole | KDE terminal | ✅ Yes | KDE default terminal |
| `htop/` | htop | System monitor | ✅ Yes | User preferences |
| `bottom/` | bottom (btm) | System monitor | ✅ Yes | Alternative to htop |
| `btop/` | btop | System monitor | ✅ Yes | Modern alternative |
| `lnav/` | lnav | Log navigator | ✅ Yes | Log viewer config |

---

### System & Desktop Environment (KDE Plasma)

#### Core Plasma Configs

| File | Purpose | Migrate? | Notes |
|------|---------|----------|-------|
| `kdeglobals` | KDE global settings | ⚠️ Partial | Theme, colors, fonts |
| `kglobalshortcutsrc` | Global shortcuts | ✅ Yes | Keyboard shortcuts |
| `kwinrc` | KWin (window manager) | ✅ Yes | Window behavior |
| `kwinoutputconfig.json` | Display config | ⚠️ Maybe | Hardware-specific |
| `plasmarc` | Plasma shell | ✅ Yes | Desktop behavior |
| `plasmashellrc` | Plasma shell | ✅ Yes | Panel configuration |
| `plasma-org.kde.plasma.desktop-appletsrc` | Desktop widgets | ✅ Yes | Widgets/applets |
| `powerd evilrc`, `powerdevilrc` | Power management | ✅ Yes | Power settings |
| `kscreenlockerrc` | Screen locker | ✅ Yes | Lock screen |
| `ksmserverrc` | Session manager | ✅ Yes | Session settings |
| `krunnerrc` | KRunner launcher | ✅ Yes | Launcher config |

#### Plasma Components

| File | Purpose | Migrate? | Notes |
|------|---------|----------|-------|
| `plasma-localerc` | Locale settings | ✅ Yes | Language/region |
| `plasmanotifyrc` | Notifications | ✅ Yes | Notification settings |
| `plasma_calendar_holiday_regions` | Calendar | ✅ Yes | Holiday config |
| `ksplashrc` | Splash screen | ✅ Yes | Boot splash |
| `kxkbrc` | Keyboard layout | ✅ Yes | Keyboard settings |

#### KDE Applications

| File/Dir | App | Migrate? | Notes |
|----------|-----|----------|-------|
| `dolphinrc` | Dolphin | ✅ Yes | File manager |
| `gwenviewrc` | Gwenview | ✅ Yes | Image viewer |
| `okularrc`, `okularpartrc` | Okular | ✅ Yes | PDF viewer |
| `spectaclerc` | Spectacle | ✅ Yes | Screenshot tool |
| `kwriterc` | KWrite | ✅ Yes | Text editor |
| `kmenueditrc` | Menu editor | ✅ Yes | Application menu |
| `drkonqirc` | Dr. Konqi | ⚠️ Maybe | Crash handler |

#### KDE System Components

| File/Dir | Purpose | Migrate? | Notes |
|----------|---------|----------|-------|
| `KDE/` | KDE data | ⚠️ Partial | Various KDE data |
| `kdedefaults/` | KDE defaults | ⚠️ Maybe | System defaults |
| `kdeconnect/` | KDE Connect | ✅ Yes | Phone integration |
| `kded5rc`, `kded6rc` | KDE daemon | ⚠️ Maybe | System daemon |
| `kconf_updaterc` | Config updates | ❌ No | Auto-generated |
| `autostart/` | Autostart apps | ✅ Yes | Startup programs |
| `environment.d/` | Environment vars | ✅ Yes | Home-Manager managed |

---

### Applications

#### Browsers

| Directory | Browser | Migrate? | Notes |
|-----------|---------|----------|-------|
| `BraveSoftware/` | Brave | ⚠️ Partial | Profile data - large |
| `chromium/` | Chromium | ⚠️ Partial | Profile data |
| `google-chrome/` | Chrome | ⚠️ Partial | Profile data |

**Recommendation:** Don't migrate full browser profiles (huge, contains cache). Only migrate:
- Bookmarks (if not synced)
- Custom settings/flags
- Extensions list (document separately)

#### Communication

| Directory | App | Migrate? | Notes |
|-----------|-----|----------|-------|
| `discord/` | Discord | ⚠️ Partial | Settings only, not cache |
| `Session/` | Session Messenger | ⚠️ Partial | Private messenger |

#### Productivity

| Directory/File | App | Migrate? | Notes |
|---------------|-----|----------|-------|
| `obsidian/` | Obsidian | ⚠️ Partial | Settings only, not vaults |
| `keepassxc/`, `KeePassXCrc` | KeePassXC | ✅ Yes | Password manager config |
| `rclone/` | rclone | ✅ Yes | Cloud sync config |
| `sqlitebrowser/` | DB Browser | ✅ Yes | Database browser |

#### Claude & AI Tools

| Directory/File | App | Migrate? | Notes |
|---------------|-----|----------|-------|
| `Claude/` | Claude Desktop | ⚠️ Secrets | Contains API keys |
| `cline/` | Cline CLI | ✅ Yes | Config managed by HM |
| `.claude.json` | Claude Code | ⚠️ Secrets | Contains settings + keys |

---

### System Utilities

| Directory/File | Purpose | Migrate? | Notes |
|---------------|---------|----------|-------|
| `dconf/` | GNOME settings | ⚠️ Maybe | Desktop settings database |
| `gtk-3.0/`, `gtk-4.0/` | GTK themes | ✅ Yes | GTK application themes |
| `gtkrc`, `gtkrc-2.0` | GTK 2 config | ✅ Yes | Legacy GTK apps |
| `menus/` | Desktop menus | ⚠️ Maybe | Application menus |
| `mimeapps.list` | File associations | ✅ Yes | Managed by HM |
| `QtProject.conf` | Qt settings | ✅ Yes | Qt application framework |
| `pulse/` | PulseAudio | ❌ No | Audio system (system-level) |
| `pavucontrol.ini` | PulseAudio control | ✅ Yes | Audio mixer GUI |
| `session/` | Session data | ❌ No | Runtime session data |

#### Misc Configs

| Directory/File | Purpose | Migrate? | Notes |
|---------------|---------|----------|-------|
| `Bitwarden CLI/` | Bitwarden | ⚠️ Secrets | CLI config may have secrets |
| `Electron/` | Electron apps | ❌ No | Framework cache |
| `akonadi/` | Akonadi (KDE PIM) | ⚠️ Maybe | Personal info manager |
| `baloofilerc`, `baloofileinformationrc` | Baloo (KDE indexer) | ⚠️ Maybe | File indexing |
| `arkrc` | Ark (KDE) | ✅ Yes | Archive manager |
| `kio rc` | KIO | ⚠️ Maybe | KDE I/O subsystem |
| `kwalletrc` | KWallet | ⚠️ Secrets | KDE wallet config |
| `libaccounts-glib/` | Accounts | ⚠️ Secrets | Online accounts |
| `mcp-shell-new/` | Custom | ✅ Yes | User tool config |

---

## 🎯 Migration Priority

### High Priority (Migrate First)

**Shell & Terminal:**
- `.bashrc` (already managed by HM)
- `.bash_profile` (already managed by HM)
- `.profile` (already managed by HM)
- `kitty/` (already managed by HM)
- `htop/`, `btop/`, `bottom/`

**Development:**
- `git/` config
- `gh/` GitHub CLI
- `Code/` VSCode/VSCodium settings
- `go/` Go environment

**Applications:**
- `keepassxc/` + `KeePassXCrc`
- `rclone/`
- `cline/` (already managed by HM)

### Medium Priority

**KDE Desktop:**
- `kdeglobals` (global theme/fonts)
- `kglobalshortcutsrc` (shortcuts)
- `kwinrc` (window manager)
- `plasmarc`, `plasmashellrc` (desktop shell)
- `plasma-org.kde.plasma.desktop-appletsrc` (widgets)

**KDE Apps:**
- `dolphinrc`, `konsolerc`, `okularrc`, `spectaclerc`
- `kate/`, `katerc`, `katevirc`

**System:**
- `gtk-3.0/`, `gtk-4.0/`, `gtkrc`, `gtkrc-2.0`
- `QtProject.conf`
- `mimeapps.list` (already managed by HM)

### Low Priority (Optional)

**Browser Configs** (settings only, not profiles):
- Brave settings
- Chromium settings

**Communication** (settings only):
- Discord settings

**Misc:**
- `sqlitebrowser/`
- `obsidian/` settings (not vaults)

### ❌ Do NOT Migrate

**History/Cache:**
- `.bash_history`
- `.viminfo`
- `session/`
- `Electron/`
- Browser caches/profiles

**Backups:**
- `*.backup` files
- `.claude.json.backup*`

**System/Auto-Generated:**
- `.nix-profile`
- `kconf_updaterc`
- `pulse/` (system-level)
- `dconf/` (complex, system-integrated)

**Secrets (Handle Separately with Encryption):**
- `Claude/` (contains API keys)
- `.claude.json` (contains keys)
- `Bitwarden CLI/` (may contain secrets)
- `kwalletrc` (KDE wallet config)
- `libaccounts-glib/` (online accounts)

---

## 📦 Application Sources

### Identified Applications

| App | Official Website | Package Source | Config Location |
|-----|------------------|----------------|-----------------|
| **Kitty** | https://sw.kovidgoyal.net/kitty/ | nixpkgs | `~/.config/kitty/` |
| **VS Code** | https://code.visualstudio.com/ | nixpkgs | `~/.config/Code/` |
| **Git** | https://git-scm.com/ | nixpkgs | `~/.config/git/` |
| **GitHub CLI (gh)** | https://cli.github.com/ | nixpkgs | `~/.config/gh/` |
| **htop** | https://htop.dev/ | nixpkgs | `~/.config/htop/` |
| **btop** | https://github.com/aristocratos/btop | nixpkgs | `~/.config/btop/` |
| **bottom** | https://github.com/ClementTsang/bottom | nixpkgs | `~/.config/bottom/` |
| **lnav** | https://lnav.org/ | nixpkgs | `~/.config/lnav/` |
| **KeePassXC** | https://keepassxc.org/ | nixpkgs | `~/.config/keepassxc/` |
| **rclone** | https://rclone.org/ | nixpkgs | `~/.config/rclone/` |
| **Cline** | https://github.com/cline/cline | npm | `~/.config/cline/` |
| **Claude Desktop** | https://claude.ai/ | Flake | `~/.config/Claude/` |
| **Brave** | https://brave.com/ | nixpkgs | `~/.config/BraveSoftware/` |
| **Discord** | https://discord.com/ | nixpkgs | `~/.config/discord/` |
| **Obsidian** | https://obsidian.md/ | nixpkgs | `~/.config/obsidian/` |
| **DB Browser for SQLite** | https://sqlitebrowser.org/ | nixpkgs | `~/.config/sqlitebrowser/` |
| **Kate** | https://kate-editor.org/ | KDE | `~/.config/kate/` |
| **Dolphin** | https://apps.kde.org/dolphin/ | KDE | `~/.config/dolphinrc` |
| **Konsole** | https://konsole.kde.org/ | KDE | `~/.config/konsolerc` |
| **Okular** | https://okular.kde.org/ | KDE | `~/.config/okularrc` |
| **Spectacle** | https://apps.kde.org/spectacle/ | KDE | `~/.config/spectaclerc` |
| **Gwenview** | https://apps.kde.org/gwenview/ | KDE | `~/.config/gwenviewrc` |
| **KDE Plasma** | https://kde.org/plasma-desktop/ | KDE | Various `~/.config/` files |

---

## 🚀 Next Steps

### 1. Create Dotfiles Repository Structure

```
my-modular-workspace/dotfiles/
├── dot_bashrc.tmpl
├── dot_bash_profile
├── dot_profile
├── dot_gtkrc-2.0
├── dot_config/
│   ├── kitty/
│   ├── git/
│   ├── gh/
│   ├── htop/
│   ├── btop/
│   ├── Code/
│   │   └── User/
│   │       └── settings.json
│   ├── keepassxc/
│   ├── rclone/
│   ├── kate/
│   ├── kde/  # KDE configs
│   ├── gtk-3.0/
│   └── gtk-4.0/
├── .chezmoiignore
├── .chezmoiexternal.toml
└── README.md
```

### 2. Prioritize Migration

**Week 1:** Shell, terminal, development tools
**Week 2:** KDE desktop settings
**Week 3:** Applications
**Week 4:** Secrets management, testing

### 3. Handle Secrets

- Use `age` encryption for sensitive files
- Use KeePassXC integration for API keys/tokens
- Never commit unencrypted secrets

---

## 📝 Notes

- Many files are KDE Plasma-specific (won't work on Fedora GNOME)
- Consider platform-specific templates for KDE vs GNOME configs
- Browser profiles are huge - document extensions/settings separately
- Some configs are auto-generated and shouldn't be managed

---

**Status:** ✅ Inventory Complete
**Next:** Begin migration with high-priority dotfiles
