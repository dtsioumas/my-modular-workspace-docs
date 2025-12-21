# Priority Applications - Detailed Analysis

**Date:** 2025-12-02
**Status:** Completed initial scan
**Purpose:** Detailed inventory of user's high-priority applications

---

## 🔥 Highly Important Apps

### OBSIDIAN (Highly Important)

**Location:** `~/.config/obsidian/`
**Config Files:** 1 file
- `1e5390832c6e5179.json` (86 bytes, modified Dec 1)

**Analysis:**
- Minimal config in .config
- Vaults likely stored separately (not in .config)
- Single JSON file suggests app-level settings only

**Management Strategy:**
- ✅ Migrate config.json to chezmoi
- ❌ Do NOT manage vaults (separate data, potentially large)
- Document vault locations separately

---

### CopyQ (Highly Important)

**Location:** `~/.config/copyq/`
**Status:** ✅ Already migrated to chezmoi

**Config Files:** 7 files + themes
- `copyq.conf` - Main configuration
- `copyq-commands.ini` - Custom commands
- `copyq-tabs.ini` - Tab definitions
- Theme files

**Management Strategy:**
- ✅ Already in `dotfiles/dot_config/copyq/`
- ✅ Autostart managed by home-manager (via autostart.nix)
- ✅ Complete

---

### Flameshot (HIGH - New Migration Target)

**Location:** `~/.config/flameshot/`
**Config Files:** 1 file
- `flameshot.ini` (30 bytes, modified TODAY Dec 2 21:37!)

**Context:**
- User migrating from Spectacle to Flameshot (today/tomorrow)
- Very recent config modification

**Management Strategy:**
- ✅ Migrate to chezmoi AFTER user completes Spectacle → Flameshot migration
- Wait for user to stabilize Flameshot config
- Then migrate flameshot.ini

**Action:** Add to migration queue, pending user completion

---

## 🖥️ Desktop & System

### KDE Connect (REALLY Important)

**Location:** `~/.config/kdeconnect/`
**Config Files:** 5 files + 1 device directory

**Files:**
- `certificate.pem` - TLS certificate (⚠️ 623 bytes)
- `privateKey.pem` - Private key (⚠️ 227 bytes, 600 perms)
- `config` - Main config (80 bytes)
- `trusted_devices` - Paired devices list (698 bytes, modified Nov 23)
- `a76cabe05d1c42968d9d8cb42d6ab9b4/` - Device-specific directory

**⚠️ Security Considerations:**
- Contains private keys and certificates
- Must preserve file permissions (600 for private key)
- Device pairing info in trusted_devices

**Management Strategy:**
- ✅ Migrate to chezmoi with `private_` prefix
- ✅ Use `private_dot_config/kdeconnect/` to preserve 600 permissions
- ⚠️ Consider age encryption for extra security
- Document pairing/recovery process

---

### btop (System Monitor)

**Location:** `~/.config/btop/`
**Config Files:** 1 config + themes directory

**Files:**
- `btop.conf` (9.5K, modified Nov 8)
- `themes/` directory

**Analysis:**
- Large config file (9.5K)
- Custom themes may be present

**Management Strategy:**
- ✅ Migrate btop.conf to chezmoi
- ✅ Include themes/ directory if custom themes exist
- Standard dotfile migration

---

### Plasma Notifications

**Locations:**
1. `~/.config/plasmanotifyrc` - Plasma notification settings
2. `~/.config/plasma_workspace.notifyrc` - Workspace notifications

**Management Strategy:**
- ✅ Migrate both to chezmoi
- Part of Plasma desktop configuration
- Important for user experience

---

## 💬 Communication Apps

### Session Messenger (Capital S - Electron App)

**Location:** `~/.config/Session/`
**Config Files:** 2 important files + Electron cache

**Important Files:**
- `config.json` (190 bytes, modified Dec 1)
- `ephemeral.json` (161 bytes, modified Dec 1)

**Cache/Runtime (Ignore):**
- Cache/, Code Cache/, GPUCache/, blob_storage/
- Crashpad/, DawnCache/, Dictionaries/
- DIPS, DIPS-wal (database files)
- attachments.noindex/

**Management Strategy:**
- ✅ Migrate config.json and ephemeral.json only
- ❌ Ignore all cache/runtime directories
- Add to .chezmoiignore: `Session/Cache/`, `Session/blob_storage/`, etc.

---

### Discord

**Location:** `~/.config/discord/`
**Config Files:** 2 user-configurable files

**Important Files:**
- `settings.json` (296 bytes, modified TODAY Dec 2 23:31!)
- `Preferences` (208 bytes)
- `quotes.json` (34 bytes)
- `Local State` (298 bytes)

**Cache/Runtime (Ignore):**
- Cache/, Code Cache/, GPUCache/, blob_storage/
- Crashpad/, Service Worker/, Session Storage/
- Cookies, DIPS, Network Persistent State
- IndexedDB/, Local Storage/

**Management Strategy:**
- ✅ Migrate settings.json, Preferences, quotes.json
- ❌ Ignore all cache and runtime data
- Add to .chezmoiignore: `discord/Cache/`, `discord/blob_storage/`, etc.

---

### session (lowercase - KDE Session Management)

**Location:** `~/.config/session/`
**Config Files:** 2 KDE session files

**Files:**
- `dolphin_dolphin_dolphin` (1.9K) - Dolphin session state
- `kwin_saved at previous logout_` (568 bytes) - KWin session

**Analysis:**
- This is NOT Session messenger (that's `Session/` with capital S)
- These are KDE session management files
- Auto-generated on logout

**Management Strategy:**
- ❌ Do NOT migrate (auto-generated)
- ❌ Add to .chezmoiignore
- These should be regenerated by KDE on each system

---

### Signal

**Status:** ⚠️ NOT FOUND

**Search Results:**
- Not found in `~/.config/`
- Not found in `~/.local/share/`

**Possible Explanations:**
1. Signal not installed yet
2. Signal Desktop uses different config location
3. User meant Signal protocol in Session messenger

**Action:** Ask user to clarify Signal status

---

## 🎨 Audio & Sound

### PulseAudio Control (pavucontrol)

**Location:** `~/.config/pavucontrol.ini`
**Config Files:** 1 file

**Management Strategy:**
- ✅ Migrate to chezmoi
- Simple INI configuration

---

### PulseAudio Core

**Location:** `~/.config/pulse/`
**Config Files:** Multiple

**Analysis:**
- System audio daemon configuration
- May be auto-generated

**Management Strategy:**
- ⚠️ Review contents before deciding
- Some files may be auto-generated
- Action: Need to inspect pulse/ directory

---

## 📊 Summary Statistics

### Priority Apps Scanned

| App | Location | User-Modifiable Files | Total Files | Cache/Runtime |
|-----|----------|----------------------|-------------|---------------|
| OBSIDIAN | `.config/obsidian/` | 1 | 1 | Minimal |
| CopyQ | `.config/copyq/` | 7 + themes | ~10 | ✅ Migrated |
| Flameshot | `.config/flameshot/` | 1 | 1 | New |
| KDE Connect | `.config/kdeconnect/` | 5 + 1 dir | ~10+ | ⚠️ Has secrets |
| btop | `.config/btop/` | 1 + themes | ~5+ | None |
| Session | `.config/Session/` | 2 | 20+ | Heavy Electron cache |
| Discord | `.config/discord/` | 4 | 30+ | Heavy Electron cache |
| session (KDE) | `.config/session/` | 0 (auto-gen) | 2 | N/A |
| Signal | - | ⚠️ NOT FOUND | - | - |
| pavucontrol | `.config/pavucontrol.ini` | 1 | 1 | None |

**Total User-Modifiable Files:** ~23 files (excluding CopyQ already migrated)

---

## 🎯 Next Steps

### Immediate Actions

1. **Signal clarification** - Ask user about Signal status
2. **Flameshot stabilization** - Wait for user to complete Spectacle migration
3. **pulse/ inspection** - Review PulseAudio config directory
4. **Remaining ~/.config/ scan** - ~85 more directories to analyze

### Migration Priorities

**Ready to migrate NOW:**
1. OBSIDIAN config.json
2. btop.conf + themes
3. KDE Connect configs (with private_ prefix)
4. Plasma notification configs
5. pavucontrol.ini
6. Session messenger (config.json, ephemeral.json)
7. Discord (settings.json, Preferences, quotes.json)

**Wait for user action:**
1. Flameshot (after Spectacle migration complete)

**Needs investigation:**
1. Signal location/status
2. pulse/ directory contents
3. "Audio tools" identification

---

**Status:** ✅ Priority apps analysis complete
**Next:** User discussion and remaining ~/.config/ scan
