# KeePassXC Bootstrap Guide

**Quick reference for setting up a fresh system with KeePassXC integration**

## Prerequisites

1. **KeePassXC database** exists at `~/MyVault/mitsio_secrets.kdbx`
2. **Home-manager** installed and working
3. **Chezmoi** initialized (`~/.local/share/chezmoi`)

## Bootstrap Steps

### 1. Install Base System (Home-Manager)

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin
```

This installs:
- KeePassXC with libsecret
- Chezmoi
- Helper scripts (`secret-service-check.sh`, etc.)

### 2. Copy Database from Backup

```bash
# If restoring from backup
cp /path/to/backup/mitsio_secrets.kdbx ~/MyVault/

# Or sync from Dropbox (if configured)
# Database auto-syncs every 15 minutes via systemd timer
```

### 3. Unlock KeePassXC

```bash
# Open KeePassXC GUI
keepassxc

# Unlock your database
# ~/MyVault/mitsio_secrets.kdbx
```

### 4. Verify Secret Service

```bash
~/bin/secret-service-check.sh
```

**Expected output:**
```
=== Secret Service Diagnostic ===
1. secret-tool installed: YES
2. D-Bus Secret Service: AVAILABLE
3. KeePassXC owns service: YES
4. Store/Lookup test: OK
```

### 5. Verify Required Entries Exist

Check that these entries are in the "Workspace Secrets" group:

| Entry Name | Attributes |
|------------|------------|
| Anthropic  | `service=anthropic`, `key=apikey` |
| GitHub-PAT | `service=github`, `key=pat` |

**Test access:**
```bash
secret-tool lookup service anthropic key apikey
secret-tool lookup service github key pat
```

### 6. Apply Chezmoi Dotfiles

```bash
# Apply .bashrc (managed by chezmoi)
chezmoi apply ~/.bashrc

# Reload shell
source ~/.bashrc

# Verify API key loaded
echo "API Key: ${ANTHROPIC_API_KEY:0:20}..."
```

## Graceful Degradation

### If KeePassXC is locked:

```bash
$ source ~/.bashrc
# No error - ANTHROPIC_API_KEY just won't be set
```

### If secret-tool is missing:

```bash
$ source ~/.bashrc
# No error - secret-tool check prevents failures
```

### If database doesn't exist:

- Secrets won't load
- No errors thrown
- Manual fallback: set environment variables manually

## Troubleshooting

### "Secret Service not available"

1. Check KeePassXC is running: `pgrep keepassxc`
2. Check database is unlocked (KeePassXC GUI)
3. Run diagnostic: `~/bin/secret-service-check.sh`

### "secret-tool returns empty"

1. Verify entry is in "Workspace Secrets" group (not subgroup!)
2. Check attributes are exactly: `service=anthropic`, `key=apikey`
3. Verify FdoSecrets enabled in Database Settings

### "KDE Wallet conflict"

```bash
# Disable KDE Wallet (already done in home-manager)
cat ~/.config/kwalletrc
# Should show: Enabled=false
```

## Recovery

If something breaks:

1. **Backup exists:** `.bashrc.backup`, `.claude/settings.json.backup`
2. **Database backup:** Dropbox auto-sync every 15 min
3. **Revert home-manager:** `home-manager generations` → `home-manager switch --switch-generation <number>`

---

**Created:** 2025-11-30
**Phase:** 2 (Chezmoi Integration)
