# Dotfiles Priority Summary - User Feedback

**Date:** 2025-12-02
**Session:** Home Directory Dotfiles Investigation
**Source:** User responses to initial findings

---

## 🎯 High Priority Configs

### Plasma/KDE Desktop (MUCH Important)

**Core Plasma:**
- ✅ plasmarc, plasmashellrc, plasma-org.kde.plasma.desktop-appletsrc
- ✅ kdeglobals, kglobalshortcutsrc (16K of shortcuts!)
- ✅ kwinrc, kwinoutputconfig.json

**KDE Applications:**
- ✅ **Dolphin** - IMPORTANT (file manager)
- ✅ **Spectacle** - IMPORTANT (screenshot) → BUT migrating to **Flameshot** today/tomorrow
- ⚠️ **Okular** - MEDIUM (PDF viewer)
- 🔻 Kate - very low
- 🔻 KWrite - very low

**KDE Services:**
- ✅ **KDE Connect** - REALLY important, uses A LOT
- ✅ **Activity Manager** - IMPORTANT, will utilize MUCH more in future
- ✅ Power management, notifications, session management

### Applications (HIGHLY Important)

**Productivity:**
- 🔥 **OBSIDIAN** - HIGHLY important
  - Location: `~/.config/obsidian/`
  - Config: 1e5390832c6e5179.json (86 bytes)
  - Note: Minimal config (vaults separate?)

- 🔥 **CopyQ** - HIGHLY important
  - Status: ✅ Already migrated to chezmoi
  - Config: 7 files + themes in `dot_config/copyq/`

**Screenshot Tools:**
- 🔥 **Flameshot** - HIGH (migrating from Spectacle)
  - Location: `~/.config/flameshot/`
  - Config: flameshot.ini (30 bytes, modified TODAY!)
  - Status: NEW migration target

**System Monitoring:**
- ✅ **btop** - Important
  - Location: `~/.config/btop/`
  - Config: btop.conf (9.5K) + themes/

**Communication:**
- ✅ **Session** messenger - Priority scan
  - Locations: `~/.config/session/` AND `~/.config/Session/`
- ✅ **Signal** - Priority scan
- ✅ **Discord** - Priority scan
  - Location: `~/.config/discord/`

**Browsers:**
- ✅ **Brave** - Main browser
  - Status: ✅ Already in home-manager (with NVIDIA optimizations)
- ⚠️ **Firefox** - Backup browser (lower priority)

### Development Tools

**Much Important:**
- ✅ **.ansible/** - MUCH important
  - Root dotfile directory

**Maybe Important:**
- ⚠️ **.bun/** - Not sure, maybe yes

### Audio & Sound

- ✅ **pavucontrol.ini** - Audio control (GTK-based PulseAudio)
- ✅ **pulse/** - PulseAudio configs
- ✅ **Audio "tools"** - Need to identify

### Notifications

- ✅ **plasmanotifyrc** - Plasma notification settings
- ✅ **plasma_workspace.notifyrc** - Workspace notifications

---

## 🚨 CRITICAL Tasks

### Claude Secrets Management (HIGH PRIORITY)

**Problem:** API keys in Claude configs need secure management

**Affected Files:**
- `~/.config/Claude/` (16 subdirectories, modified Dec 1)
- `~/.claude.json` (55KB, modified TODAY Dec 2)

**Solution:**
- ✅ Use KeePassXC integration via systemd service
- ✅ Add to TODO.md as HIGH CRITICAL
- ✅ Design template strategy for chezmoi

**Status:** 🚨 ADDED to TODO.md (2025-12-02)

### Backup Strategy

**Rule:** All backup files go to `dotfiles/_staging/`
- Include in plan and best practices docs
- Current _staging/ contents: 9 directories (BraveBrowser, claude-code, claude-desktop, KDE, Plasma, vscode, vscodium, zellij, llm-cli)

---

## 🔻 Low Priority / Skip

### KDE Apps
- 🔻 Kate - very low
- 🔻 KWrite - very low
- 🔻 Konsole - SKIP (user uses kitty)

### Telemetry
- 🔻 User Feedback configs - low important
  - UserFeedback.org.kde.dolphin.conf
  - UserFeedback.org.kde.kate.conf
  - UserFeedback.org.kde.plasmashell.conf

### Root Dotfiles
- 🔻 .git-credentials - DEPRECATED (secret available via systemd service)

---

## ⚠️ Secrets & Security

### Files with Secrets

**KDE Connect:**
- `~/.config/kdeconnect/certificate.pem` - TLS certificate
- `~/.config/kdeconnect/privateKey.pem` - Private key (600 perms)
- Strategy: Keep in chezmoi with proper permissions (private_)

**Git Credentials:**
- `~/.git-credentials` - DEPRECATED, use systemd service instead

**SSH Keys:**
- `~/.keychain/` - SSH key management
- Strategy: TBD (age encryption or KeePassXC)

**Claude Configs:**
- See CRITICAL section above

---

## 📊 Config Statistics

### Priority Apps Found

| App | Location | Files | Size | Modified |
|-----|----------|-------|------|----------|
| Flameshot | `.config/flameshot/` | 1 | 30B | Dec 2 (TODAY!) |
| OBSIDIAN | `.config/obsidian/` | 1 | 86B | Dec 1 |
| btop | `.config/btop/` | 1 + themes | 9.5K | Nov 8 |
| KDE Connect | `.config/kdeconnect/` | 5 files + 1 dir | - | Nov 23 (trusted_devices) |
| CopyQ | `.config/copyq/` | 7 files + themes | - | ✅ Migrated |
| Discord | `.config/discord/` | TBD | TBD | TBD |
| Session | `.config/session/` + `.config/Session/` | TBD | TBD | TBD |
| Plasma Notify | `.config/plasmanotifyrc` | 1 | - | - |

**Total Priority Apps Config Files:** 158+ (across flameshot, obsidian, discord, session, Session, btop, kdeconnect)

---

## 🎯 Next Actions

### Immediate (This Session)

1. ✅ Add Claude secrets tasks to TODO.md (DONE)
2. ⏳ Finish scanning priority apps:
   - Session messenger (both session/ and Session/)
   - Signal
   - Discord details
   - Audio tools identification
3. ⏳ Scan remaining 85+ apps in ~/.config/
4. ⏳ Create comprehensive mapping document
5. ⏳ Present findings for final user approval

### After User Approval

1. Create detailed per-app documentation
2. Design categorization structure
3. Document management strategies (chezmoi vs home-manager)
4. Create migration plan

---

## 📝 User Preferences Summary

**What User Uses:**
- **Desktop:** KDE Plasma (core + important apps)
- **Terminal:** kitty (NOT Konsole)
- **Browser:** Brave (main), Firefox (backup)
- **Screenshot:** Flameshot (migrating from Spectacle)
- **Clipboard:** CopyQ (highly important)
- **Notes:** OBSIDIAN (highly important)
- **Phone:** KDE Connect (really important)
- **Monitoring:** btop, htop
- **Development:** Ansible (much important), .bun (maybe)
- **Messaging:** Session, Signal, Discord

**Secrets Management:**
- KeePassXC for all secrets (NOT KDE Wallet)
- Systemd service for credential access
- age encryption for sensitive files in chezmoi

**Themes:**
- GTK themes important (.gtkrc-2.0, .icons/)
- Plasma themes and appearance

---

**Status:** ✅ Priority summary complete
**Next:** Continue scanning remaining apps
