# Brave Browser KeePassXC Integration

**Created:** 2025-12-03
**Status:** Documentation Complete | Implementation Pending
**Priority:** 🔴 CRITICAL (Risk of data loss)
**Project:** my-modular-workspace

---

## Executive Summary

Brave browser needs complete integration with KeePassXC to prevent data loss of passwords, sync credentials, and browser settings. While the KeePassXC extension is installed and Brave's built-in password manager is disabled, **passwords may still be stored locally** and could be lost if the Brave profile is deleted or corrupted.

**Critical Risk:** If Brave profile is lost without proper KeePassXC migration, you will lose:
- All passwords not migrated to KeePassXC vault
- Brave Sync chain credentials (cannot recover without seed)
- Browser settings and extension configurations

---

## Current State Analysis

### What's Already Working ✅

1. **KeePassXC Extension Installed**
   - Extension ID: `oboonakemofpalcgghocfoadofidjkkk`
   - Keyboard shortcuts configured:
     - `Alt+Shift+U` - Fill username/password
     - `Alt+Shift+G` - Show password generator
     - `Alt+Shift+O` - Fill TOTP (two-factor auth codes)

2. **Brave's Built-in Password Manager Disabled**
   - `credentials_enable_service: false`
   - `credentials_enable_autosignin: false`
   - This prevents Brave from saving new passwords

3. **Brave Sync Configured**
   - Sync chain exists (syncs to Brave's servers)
   - Syncs: bookmarks, settings, extensions, etc.
   - **Does NOT sync** passwords if built-in password manager is disabled

### What Needs Attention 🔴

1. **Legacy Passwords in Brave's Database**
   - Location: `~/.config/BraveSoftware/Brave-Browser/Default/Login Data`
   - SQLite database (locked while Brave is running)
   - **Unknown count** - need to export when Brave is closed
   - **Not synced** to KeePassXC vault yet

2. **Brave Sync Recovery Seed**
   - Critical for disaster recovery
   - Currently only stored in Brave's encrypted preferences
   - **Not backed up** to KeePassXC

3. **Multiple Brave Profiles**
   - Default, Profile 1, Profile 4 detected
   - Each has separate `Login Data` database
   - Need to check all profiles for passwords

---

## Implementation Plan

### Phase 1: Assessment & Backup (30 minutes)

#### 1.1: Export Existing Passwords from Brave

**Prerequisites:**
- Close Brave completely before running these commands
- Backup current Brave profile first

```bash
# 1. Close Brave
pkill -x brave

# 2. Export passwords from each profile
for profile in "Default" "Profile 1" "Profile 4"; do
  LOGIN_DB="$HOME/.config/BraveSoftware/Brave-Browser/$profile/Login Data"
  if [ -f "$LOGIN_DB" ]; then
    echo "=== $profile ==="
    sqlite3 "$LOGIN_DB" "SELECT COUNT(*) FROM logins;"

    # Export URLs and usernames (NOT passwords - encrypted)
    sqlite3 "$LOGIN_DB" \
      "SELECT origin_url, username_value FROM logins ORDER BY origin_url;" \
      > "/tmp/brave-passwords-${profile// /_}.txt"
  fi
done
```

**Output:** List of sites/usernames that need migration

#### 1.2: Backup Brave Sync Chain

**Manual Steps:**
1. Open Brave
2. Settings → Sync → "View sync code"
3. Copy the 24-word recovery phrase
4. **IMMEDIATELY** store in KeePassXC:
   - Group: `Workspace Secrets/Browsers`
   - Entry: `Brave Sync Chain`
   - Password field: (leave empty)
   - Notes field: Paste the 24-word phrase
   - Add attribute: `service=brave`, `key=sync-chain`

#### 1.3: Identify All Passwords Needing Migration

**Review:**
- `/tmp/brave-passwords-*.txt` files
- Manually check each profile in Brave UI:
  - `brave://settings/passwords`
  - Export via UI: ⋮ menu → Export passwords → Save CSV
- **Do NOT commit CSV to git** - contains cleartext passwords

---

### Phase 2: Migration to KeePassXC (1-2 hours)

#### 2.1: Import Passwords to KeePassXC

**Option A: Manual Import (Recommended for small counts)**
1. Open KeePassXC
2. Database → Import → CSV File
3. Select exported CSV from Brave
4. Map columns: URL → URL, Username → Username, Password → Password
5. Import to group: `Personal/Browsers/Brave` or `Workspace Secrets`

**Option B: Automated Import (for large password counts)**
```bash
# Using keepassxc-cli
for profile in "Default" "Profile 1" "Profile 4"; do
  CSV="/tmp/brave-passwords-${profile// /_}.csv"
  if [ -f "$CSV" ]; then
    keepassxc-cli import \
      ~/MyVault/mitsio_secrets.kdbx \
      "$CSV" \
      --group "Browsers/Brave/$profile"
  fi
done
```

#### 2.2: Verify KeePassXC Extension Access

**Test:**
1. Open a website where you have a password (e.g., github.com)
2. Trigger KeePassXC extension:
   - Click extension icon, OR
   - Press `Alt+Shift+U`
3. Verify:
   - KeePassXC database unlocks
   - Extension shows matching credentials
   - Auto-fill works

**If not working:**
- Check KeePassXC Settings → Browser Integration:
  - ✅ Enable browser integration
  - ✅ Brave Browser
  - ✅ Enable KeePassXC browser integration
- Reconnect extension in Brave:
  - Click KeePassXC extension icon
  - Settings → "Connect" to database

#### 2.3: Delete Brave's Local Passwords (After Verification)

**WARNING: Only do this after confirming ALL passwords are in KeePassXC!**

```bash
# Close Brave first
pkill -x brave

# Backup current databases
for profile in "Default" "Profile 1" "Profile 4"; do
  LOGIN_DB="$HOME/.config/BraveSoftware/Brave-Browser/$profile/Login Data"
  if [ -f "$LOGIN_DB" ]; then
    cp "$LOGIN_DB" "$LOGIN_DB.backup-$(date +%Y%m%d)"
  fi
done

# Clear password databases (keeps structure, deletes data)
for profile in "Default" "Profile 1" "Profile 4"; do
  LOGIN_DB="$HOME/.config/BraveSoftware/Brave-Browser/$profile/Login Data"
  if [ -f "$LOGIN_DB" ]; then
    sqlite3 "$LOGIN_DB" "DELETE FROM logins;"
    echo "Cleared passwords from $profile"
  fi
done
```

---

### Phase 3: Brave Configuration Backup (30 minutes)

#### 3.1: Backup Critical Brave Files to KeePassXC

**What to backup:**
1. **Brave Sync Chain** (already done in Phase 1.2)
2. **Extension Settings** (if critical):
   - Brave stores extension data in `~/.config/BraveSoftware/Brave-Browser/Default/`
   - Most extensions sync via their own accounts (e.g., KeePassXC connects to local DB)

3. **Custom Settings/Profiles** (optional):
   - Create a compressed backup of entire Brave profile
   - Store compressed file in Dropbox/GDrive (too large for KeePassXC)
   - Store backup password in KeePassXC if encrypted

```bash
# Create encrypted backup of Brave config
tar czf /tmp/brave-config-backup-$(date +%Y%m%d).tar.gz \
  ~/.config/BraveSoftware/Brave-Browser/

# Optional: Encrypt with age
age -e -o ~/Dropbox/Backups/brave-config-backup-$(date +%Y%m%d).tar.gz.age \
  -R ~/.ssh/id_ed25519.pub \
  /tmp/brave-config-backup-$(date +%Y%m%d).tar.gz

# Clean up temp file
rm /tmp/brave-config-backup-*.tar.gz
```

#### 3.2: Document Recovery Procedure

Create: `~/.MyHome/MySpaces/my-modular-workspace/docs/commons/integrations/keepassxc-integration/BRAVE_RECOVERY.md`

**Contents:**
1. How to restore Brave Sync chain from KeePassXC
2. How to restore config backup
3. How to reconnect KeePassXC extension
4. How to verify all passwords are accessible

---

### Phase 4: Configure Brave in NixOS/Home-Manager (15 minutes)

#### 4.1: Ensure Brave Config Stays Disabled for Password Storage

**File:** `home-manager/brave.nix`

Add validation/documentation:

```nix
{
  # ... existing config ...

  # Brave flags to disable built-in password manager
  # (User must use KeePassXC extension for password management)
  home.packages = [
    (pkgs.brave.override {
      commandLineArgs = [
        # ... existing flags ...

        # Disable built-in password manager (enforced)
        # Note: Brave UI setting "Offer to save passwords" must ALSO be disabled manually
        "--disable-sync"  # Commented out - user can enable Brave Sync for bookmarks/settings
      ];
    })
  ];

  # Documentation comment for future reference
  # Brave password management strategy:
  # - Built-in password manager: DISABLED (brave://settings/passwords)
  # - KeePassXC extension: ENABLED (Extension ID: oboonakemofpalcgghocfoadofidjkkk)
  # - All passwords stored in: ~/MyVault/mitsio_secrets.kdbx
  # - Brave Sync chain backup: KeePassXC entry "Brave Sync Chain"
}
```

#### 4.2: Add Brave Profile Symlinks to chezmoi (Optional)

**If you want declarative Brave profile management:**
- Use chezmoi to manage `Preferences` file (some settings)
- **Warning:** Brave heavily modifies this file at runtime
- Only recommended for read-only settings or templates

---

## Verification Checklist

After completing all phases:

### Password Migration Verification
- [ ] All Brave profiles checked for passwords
- [ ] Password export CSVs created from each profile
- [ ] All passwords imported to KeePassXC
- [ ] KeePassXC extension tested on 3+ websites
- [ ] Auto-fill works with `Alt+Shift+U`
- [ ] Password generator works with `Alt+Shift+G`
- [ ] Brave's local password database cleared (after verification)

### Backup Verification
- [ ] Brave Sync chain recovery phrase saved in KeePassXC
- [ ] Brave Sync chain entry has correct attributes (`service=brave`, `key=sync-chain`)
- [ ] Full Brave config backup created and stored securely
- [ ] Recovery procedure documented

### Configuration Verification
- [ ] Brave's built-in password manager still disabled (check UI)
- [ ] `brave://settings/passwords` shows "Passwords not saved"
- [ ] KeePassXC extension pinned to toolbar
- [ ] Extension keyboard shortcuts working

---

## Security Considerations

### What's Stored Where

| Secret Type | Storage Location | Backup |
|------------|------------------|--------|
| **Passwords** | KeePassXC vault (`~/MyVault/`) | Dropbox (every 15min) |
| **Brave Sync Chain** | KeePassXC entry | Dropbox (with vault) |
| **Brave Profile** | `~/.config/BraveSoftware/` | Optional encrypted backup |
| **Extension Settings** | Brave profile (some sync via extension accounts) | Extension-dependent |

### Risks Mitigated

1. **Brave profile corruption** → Passwords safe in KeePassXC vault ✅
2. **Brave Sync failure** → Recovery phrase backed up ✅
3. **Password loss** → All passwords in encrypted, synced vault ✅
4. **Fresh install** → Can restore from KeePassXC + Brave Sync ✅

### Remaining Risks

1. **KeePassXC vault loss** → Mitigated by Dropbox sync every 15min
2. **Master password forgotten** → No recovery (by design) - REMEMBER IT!
3. **Extension breakage** → Can export passwords from KeePassXC as fallback

---

## Troubleshooting

### KeePassXC Extension Not Connecting

**Symptoms:** Extension icon shows "disconnected" or doesn't fill passwords

**Solution:**
1. Open KeePassXC
2. Tools → Settings → Browser Integration:
   - ✅ Enable browser integration
   - ✅ Brave Browser (check this box)
   - ✅ Return advanced string fields (useful for custom attributes)
3. In Brave extension:
   - Click extension icon → Settings
   - "Connect" or "Re-connect" to database
   - Grant permission when prompted

### Passwords Not Auto-Filling

**Symptoms:** Extension connected but doesn't offer passwords on sites

**Check:**
1. Is the site URL in KeePassXC matching the browser URL?
   - Edit entry → URL field must match (http vs https matters!)
2. Is the entry in a Secret Service-enabled group?
   - May not matter for browser extension, but check anyway
3. Try manual fill: `Alt+Shift+U`

### Brave Asks to Save Passwords (Shouldn't Happen)

**Symptoms:** Brave shows "Save password?" prompt

**Solution:**
1. `brave://settings/passwords`
2. Turn OFF "Offer to save passwords"
3. Turn OFF "Auto Sign-in"
4. Restart Brave

---

## Related Documentation

- [KeePassXC Modular Workspace Integration](./KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md)
- [KeePassXC Systemd Secret Loading](./KEEPASSXC_SYSTEMD_SECRET_LOADING.md)
- [home-manager/brave.nix](/home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager/brave.nix)
- [home-manager/keepassxc.nix](/home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager/keepassxc.nix)

---

## Changelog

| Date | Change |
|------|--------|
| 2025-12-03 | Initial documentation created |
| TBD | Phase 1-4 implementation |

---

## Next Steps

1. **USER ACTION REQUIRED:** Close Brave and run Phase 1 assessment
2. After assessment, decide migration strategy (manual vs automated)
3. Schedule 2-hour session for full migration
4. Verify thoroughly before deleting Brave's local passwords
5. Document any issues in troubleshooting section

---

**CRITICAL REMINDER:** Do NOT delete Brave's local passwords until you have verified that:
1. ALL passwords are imported to KeePassXC
2. KeePassXC extension auto-fill works on multiple test sites
3. You have tested logging in to critical sites (email, bank, work, etc.)
