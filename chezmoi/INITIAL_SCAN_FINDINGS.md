# Initial Home Directory Scan Findings

**Date:** 2025-12-02
**Scope:** Priority 1 & 2 configs (Plasma/KDE, Claude) + root dotfiles
**Status:** First round - awaiting user feedback

---

## Summary Statistics

- **Total ~/.config/ directories:** 125
- **Plasma/KDE configs found:** ~40 files/directories
- **Claude configs:** 2 locations (.config/Claude/, ~/.claude.json)
- **Root dotfiles:** ~30 (excluding cache/history)
- **_staging/ contents:** 9 backup directories + README

---

## Priority 1: Plasma/KDE Desktop Configs

### Core Plasma Shell Files

| File | Size | Modified | Purpose |
|------|------|----------|---------|
| `plasmarc` | - | Dec 2 | Plasma shell settings |
| `plasmashellrc` | - | - | Panel configuration |
| `plasma-org.kde.plasma.desktop-appletsrc` | 7.8K | Dec 1 23:25 | Desktop widgets/applets |
| `kdeglobals` | - | - | Global KDE settings (theme, colors, fonts) |
| `kglobalshortcutsrc` | 16K | Nov 30 23:17 | Global keyboard shortcuts |
| `kwinrc` | 1.3K | Dec 2 20:20 | Window manager (KWin) config |
| `kwinoutputconfig.json` | 1.5K | Dec 2 20:20 | Display outputs configuration |

### KDE System Components

| File | Size | Modified | Purpose |
|------|------|----------|---------|
| `ksmserverrc` | 95 | Nov 27 | Session manager |
| `krunnerrc` | 99 | Nov 13 | KRunner launcher |
| `kscreenlockerrc` | 382 | Nov 13 | Screen locker |
| `ksplashrc` | 0 | Nov 13 | Splash screen (empty file) |
| `powerdevilrc` | - | - | Power management |
| `plasma-localerc` | - | - | Locale/language settings |
| `plasmanotifyrc` | - | - | Notification settings |
| `kxkbrc` | 114 | Nov 13 | Keyboard layout |

### KDE Applications

| File | Size | Modified | Purpose |
|------|------|----------|---------|
| `dolphinrc` | - | - | File manager |
| `kate/`, `katerc`, `katevirc` | 425/419 | Dec 1/Oct 24 | Kate text editor |
| `konsolerc` | 176 | Nov 19 | Konsole terminal (SKIP - user uses kitty) |
| `gwenviewrc` | - | - | Image viewer |
| `okularrc`, `okularpartrc` | - | - | PDF viewer |
| `spectaclerc` | - | - | Screenshot tool |
| `kwriterc` | 162 | Oct 25 | Simple text editor |
| `kmenueditrc` | 32 | Nov 2 | Application menu editor |

### KDE System Daemons & Services

| File | Size | Modified | Purpose |
|------|------|----------|---------|
| `kded5rc`, `kded6rc` | 95/40 | Oct 27 | KDE daemon configs |
| `kactivitymanagerdrc` | 1.8K | Nov 12 | Activity manager |
| `kactivitymanagerd-statsrc` | 937 | Nov 8 | Activity statistics |
| `kwalletrc` | 80 | Dec 2 19:43 | KDE Wallet config |
| `kwalletmanagerrc` | 61 | Nov 30 | Wallet manager GUI |

### KDE Connect & Network

| File | Directory | Purpose |
|------|-----------|---------|
| `kdeconnect/` | Yes | Phone integration config |
| `krdpserverrc` | 127 | RDP server settings |

### User Feedback Configs (Optional)

| File | Size | Purpose |
|------|------|---------|
| `UserFeedback.org.kde.dolphin.conf` | 1018 | Dolphin telemetry |
| `UserFeedback.org.kde.kate.conf` | 442 | Kate telemetry |
| `UserFeedback.org.kde.plasmashell.conf` | 693 | Plasma telemetry |

### ~/.local/share/ Plasma Data

| Directory | Purpose |
|-----------|---------|
| `~/.local/share/plasma/` | Plasma-specific data |
| `~/.local/share/plasma-manager/` | Plasma manager data |
| `~/.local/share/plasma-systemmonitor/` | System monitor widgets |
| `~/.local/share/kded6/` | KDE daemon data |

---

## Priority 2: Claude Configs

### Claude Desktop

**Location:** `~/.config/Claude/`
- **Type:** Directory with 16 subdirectories
- **Modified:** Dec 1 22:53
- **⚠️ Contains:** Likely API keys, session data, settings

### Claude Code (CLI)

**Location:** `~/.claude.json`
- **Size:** 55KB
- **Modified:** Dec 2 21:02 (TODAY - very recent!)
- **⚠️ Contains:** API keys, MCP server configs, workspace settings

**Backup copies found:**
- `.claude.json.backup`
- `.claude.json.backup-20251026`
- `.claude.json.backup-20251026-171028`

**Related directories:**
- `.claude/` - Additional Claude data
- `.claude_states/` - State information

---

## Root Dotfiles (~/)

### Version Control

| File | Purpose |
|------|---------|
| `.gitconfig` | Git configuration (MIGRATED TO CHEZMOI ✅) |
| `.git-credentials` | Git credentials (⚠️ secrets) |

### Shell & Environment

| File | Purpose | Status |
|------|---------|--------|
| `.bashrc` | Bash configuration | ✅ Managed by home-manager |
| `.bashrc.backup` | Backup file | ❌ Ignore |

### Development Tools

| Directory | Purpose |
|-----------|---------|
| `.ansible/` | Ansible local data |
| `.bun/` | Bun JS runtime |
| `.dotnet/` | .NET SDK data |
| `.eclipse/` | Eclipse IDE |
| `.minikube/` | Minikube Kubernetes |

### Secrets & Credentials

| File/Dir | Purpose | Status |
|----------|---------|--------|
| `.keychain/` | SSH key management | ⚠️ Secrets |
| `.keep-myvault` | KeePassXC vault marker | ✅ Home-manager |

### Desktop & UI

| File | Purpose |
|------|---------|
| `.gtkrc-2.0` | GTK 2.0 theme config |
| `.icons/` | Custom icons |
| `.mozilla/` | Firefox profiles |

### Cloud Sync

| Directory | Purpose | Status |
|-----------|---------|--------|
| `.dropbox/` | Dropbox config | 🏠 Home-manager service |
| `.dropbox-dist/` | Dropbox installation | ❌ Don't manage |

### MCP & LLM Tools

| Directory | Purpose |
|-----------|---------|
| `.cline/` | Cline CLI config |
| `.mcp-servers/` | MCP server installations |
| `.mcp_sequential_thinking/` | Sequential Thinking MCP data |
| `.jackofalltrades/` | Custom tool |

### Project Directories

| Directory | Purpose |
|-----------|---------|
| `.MyHome/` | Main workspace (synced to GDrive) |

---

## _staging/ Directory Contents

**Purpose:** Backup location for safe migration of dotfiles to chezmoi

**Contents (9 directories + README):**

| Directory | Status |
|-----------|--------|
| `BraveBrowser/` | Browser profile backup |
| `claude-code/` | Claude Code backup |
| `claude-desktop/` | Claude Desktop backup |
| `KDE/` | KDE configs backup |
| `Plasma/` | Plasma configs backup |
| `vscode/` | VS Code backup |
| `vscodium/` | VSCodium backup |
| `zellij/` | Zellij terminal multiplexer backup |
| `llm-cli/` | LLM CLI tools backup |
| `README.md` | Documentation |

**Note:** All staging contents are IGNORED by chezmoi via `.chezmoiignore`

---

## Questions for Discussion

Before continuing to scan remaining ~/.config/ applications, I need your input:

### Plasma/KDE Configs

1. **Core Plasma files** (plasmarc, kwinrc, kdeglobals, etc.) - Important to you?
2. **KDE Applications** (Dolphin, Kate, Gwenview, Okular, Spectacle) - Which do you use regularly?
3. **KDE Wallet** (kwalletrc) - Do you use KDE Wallet or only KeePassXC?
4. **KDE Connect** - Do you use phone integration?
5. **User Feedback configs** - Can we ignore telemetry configs?
6. **Activity Manager** - Do you use KDE Activities feature?

### Claude Configs

7. **Claude Desktop** (~/.config/Claude/) - How should we handle API keys? (age encryption, KeePassXC, or keep in home-manager?)
8. **Claude Code** (~/.claude.json) - Same question about secrets management
9. **Backup strategy** - Keep the .backup files in _staging/ or delete them?

### Root Dotfiles

10. **Git credentials** (.git-credentials) - Should this be encrypted or in KeePassXC?
11. **GTK themes** (.gtkrc-2.0, .icons/) - Important for your workflow?
12. **Development tools** (.ansible/, .bun/, .dotnet/, etc.) - Which are actively used?
13. **Mozilla/Firefox** - Do you use Firefox or only Brave?

### General

14. **_staging/ directory** - Should we document what's there and why, or is it purely internal backup?
15. **Priority for remaining ~/.config/ scan** - Any specific apps you want me to focus on next?

---

**Next Steps:**

After your feedback, I will:
1. Mark important configs for detailed documentation
2. Scan remaining 85+ applications in ~/.config/
3. Scan ~/.local/ for relevant data
4. Create comprehensive mapping document
5. Categorize everything for migration strategy

---

**Status:** ⏸️ Awaiting user input before continuing
