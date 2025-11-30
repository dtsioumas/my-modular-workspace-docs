# KeePassXC as Central Secret Manager for Modular Workspace

**Created:** 2025-11-29
**Status:** Phase 1-3 Complete ✅ | Phases 4-5 Pending
**Author:** Mitsio + Claude Code
**Project:** my-modular-workspace
**Last Updated:** 2025-12-01 (Phase 3 completed - systemd environment integration)

---

## Executive Summary

This document outlines a comprehensive plan to integrate KeePassXC as the **primary secret manager** for the entire modular workspace, including:

- **Chezmoi dotfiles** - Template-based secret injection
- **rclone Google Drive** - OAuth token and config password protection
- **Ansible automation** - Playbook secret retrieval
- **General CLI tools** - Via FdoSecrets (D-Bus Secret Service API)

---

## Table of Contents

1. [Current State Analysis](#current-state-analysis)
2. [Integration Architecture](#integration-architecture)
3. [Chezmoi + KeePassXC Integration](#chezmoi--keepassxc-integration)
4. [rclone + KeePassXC Integration](#rclone--keepassxc-integration)
5. [FdoSecrets and secret-tool](#fdosecrets-and-secret-tool)
6. [Home-Manager Configuration](#home-manager-configuration)
7. [Implementation Plan](#implementation-plan)
8. [Security Considerations](#security-considerations)
9. [Troubleshooting](#troubleshooting)
10. [References](#references)

---

## Current State Analysis

### Existing KeePassXC Setup

**Location:** `home-manager/keepassxc.nix`

```nix
# Current configuration
home.packages = with pkgs; [
  keepassxc
  libnotify
];

# FdoSecrets already enabled
home.file.".config/keepassxc/keepassxc.ini".text = ''
  [FdoSecrets]
  Enabled=true
  ConfirmAccessItem=true
  ShowNotification=true
'';
```

**Vault Location:**
- Local: `~/MyVault/mitsio_secrets.kdbx`
- Remote sync: `~/Dropbox/Apps/KeepassXC/mitsio_secrets.kdbx`
- Sync interval: Every 15 minutes via systemd timer

### Current Secrets Landscape

| Secret Type | Current Storage | Target Storage |
|------------|-----------------|----------------|
| rclone OAuth tokens | `~/.config/rclone/rclone.conf` (cleartext) | KeePassXC + encrypted config |
| Anthropic API key | Environment variable | KeePassXC |
| GitHub tokens | Various locations | KeePassXC |
| SSH keys | `~/.ssh/` | Optional KeePassXC SSH Agent |
| Atuin sync key | `~/.config/atuin/` | KeePassXC |
| Bitwarden password | Memory only | KeePassXC (for migration) |

---

## Integration Architecture

```
                    ┌─────────────────────────────────────┐
                    │         KeePassXC Database          │
                    │    ~/MyVault/mitsio_secrets.kdbx    │
                    └─────────────────┬───────────────────┘
                                      │
              ┌───────────────────────┼───────────────────────┐
              │                       │                       │
              ▼                       ▼                       ▼
    ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
    │   keepassxc-cli │     │    FdoSecrets   │     │ Browser Plugin  │
    │   (Direct CLI)  │     │   (D-Bus API)   │     │  (Auto-fill)    │
    └────────┬────────┘     └────────┬────────┘     └─────────────────┘
             │                       │
    ┌────────┴────────┐     ┌────────┴────────┐
    │                 │     │                 │
    ▼                 ▼     ▼                 ▼
┌───────┐      ┌─────────┐  ┌───────────┐  ┌──────────┐
│Chezmoi│      │ Ansible │  │secret-tool│  │  rclone  │
│Templates│    │Playbooks│  │   (CLI)   │  │(RCLONE_  │
└───────┘      └─────────┘  └───────────┘  │PASSWORD_ │
                                           │COMMAND)  │
                                           └──────────┘
```

### Access Methods

1. **keepassxc-cli** - Direct CLI access, requires master password
2. **FdoSecrets (D-Bus)** - When KeePassXC is unlocked, no password needed
3. **secret-tool** - CLI wrapper for FdoSecrets/libsecret
4. **Builtin mode** - Chezmoi's internal KeePassXC library

---

## Chezmoi + KeePassXC Integration

### Configuration

Add to `~/.config/chezmoi/chezmoi.toml`:

```toml
[keepassxc]
    database = "/home/mitsio/MyVault/mitsio_secrets.kdbx"
    # prompt = true  # Default: prompt for password
    # mode = "builtin"  # Use if keepassxc-cli unavailable
```

### Template Functions

| Function | Usage | Example |
|----------|-------|---------|
| `keepassxc` | Get entry fields | `{{ (keepassxc "entry-name").Password }}` |
| `keepassxcAttribute` | Get custom attribute | `{{ keepassxcAttribute "entry" "attr-name" }}` |

### Available Fields

- `.Title`
- `.UserName`
- `.Password`
- `.URL`
- `.Notes`

### Example Templates

**API Key in .bashrc:**
```bash
# dot_bashrc.tmpl
export ANTHROPIC_API_KEY="{{ (keepassxc "API/Anthropic").Password }}"
export OPENAI_API_KEY="{{ (keepassxc "API/OpenAI").Password }}"
```

**SSH Config with custom attributes:**
```
# dot_ssh/config.tmpl
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  # Token for HTTPS fallback
  # {{ keepassxcAttribute "GitHub/PAT" "token" }}
```

**Claude Code settings:**
```json
// private_dot_claude/settings.json.tmpl
{
  "apiKey": "{{ (keepassxc "API/Anthropic").Password }}"
}
```

### KeePassXC Entry Structure

Recommended group organization:

```
Root
├── Workspace Secrets (Secret Service enabled)
│   ├── rclone
│   │   └── config-password
│   ├── API
│   │   ├── Anthropic
│   │   ├── OpenAI
│   │   └── GitHub-PAT
│   └── Sync
│       └── Atuin
├── SSH Keys (SSH Agent)
│   ├── id_ed25519
│   └── github_deploy
└── Personal (Not for automation)
    └── ...
```

---

## rclone + KeePassXC Integration

### Problem Statement

Current `~/.config/rclone/rclone.conf` contains:
- OAuth tokens (access_token, refresh_token)
- Client secrets
- All stored in cleartext or weak obfuscation

### Solution: Encrypted Config + secret-tool

#### Step 1: Enable rclone Config Encryption

```bash
# Set a new config password
rclone config encryption set

# Enter a strong password - this will be stored in KeePassXC
```

#### Step 2: Store Password in KeePassXC

1. Open KeePassXC
2. Create entry in "Workspace Secrets/rclone" group:
   - **Title:** `config-password`
   - **Password:** (the rclone config password)
   - **Attributes:** Add `service: rclone`, `key: config-password`
3. Enable entry for Secret Service access

#### Step 3: Configure Environment Variable

Add to `rclone-gdrive.nix`:

```nix
systemd.user.services.rclone-gdrive-sync = {
  Service = {
    Environment = [
      "RCLONE_PASSWORD_COMMAND=secret-tool lookup service rclone key config-password"
    ];
  };
};
```

#### Alternative: Using keepassxc-cli

For manual/interactive use when KeePassXC may not be unlocked:

```bash
# Wrapper script
export RCLONE_PASSWORD_COMMAND="keepassxc-cli show -q -s -a password \
  ~/MyVault/mitsio_secrets.kdbx 'rclone/config-password'"
rclone sync ...
```

**Trade-offs:**

| Method | Pros | Cons |
|--------|------|------|
| secret-tool | Seamless when unlocked | Requires KeePassXC running |
| keepassxc-cli | Works without GUI | Requires master password input |

---

## FdoSecrets and secret-tool

### What is FdoSecrets?

FdoSecrets implements the [freedesktop.org Secret Service API](https://specifications.freedesktop.org/secret-service/latest/) via D-Bus. This allows any application using libsecret to retrieve secrets from KeePassXC.

### Prerequisites

1. **KeePassXC running and unlocked**
2. **FdoSecrets enabled** in KeePassXC settings
3. **Database group configured** for Secret Service access
4. **GNOME Keyring disabled** (conflicts with KeePassXC)

### Using secret-tool

**Store a secret:**
```bash
printf "my-secret-value" | secret-tool store --label="My Secret" \
  service myapp key api-token
```

**Lookup a secret:**
```bash
secret-tool lookup service myapp key api-token
```

**Search secrets:**
```bash
secret-tool search --all service myapp
```

### Common Issues

#### "Another secret service is running"

Disable GNOME Keyring:

```nix
# In NixOS configuration
services.gnome.gnome-keyring.enable = lib.mkForce false;

# Or via dconf (home-manager)
dconf.settings = {
  "org/gnome/crypto/pgp" = {
    keyservers = [];
  };
};
```

#### "No such object path '/org/freedesktop/secrets/aliases/default'"

Configure Secret Service group in KeePassXC:
1. Open Database > Database Settings
2. Go to "Secret Service Integration" tab
3. Select a group to expose via Secret Service

---

## Home-Manager Configuration

### Enhanced keepassxc.nix

```nix
{ config, pkgs, lib, ... }:

{
  # Install KeePassXC and libsecret
  home.packages = with pkgs; [
    keepassxc
    libsecret  # Provides secret-tool CLI
    libnotify
  ];

  # Create vault directory
  home.activation.createVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/MyVault
  '';

  # KeePassXC configuration with FdoSecrets
  home.file.".config/keepassxc/keepassxc.ini".text = ''
    [General]
    ConfigVersion=2

    [Browser]
    Enabled=true

    [FdoSecrets]
    Enabled=true
    ConfirmAccessItem=true
    ShowNotification=true

    [GUI]
    MinimizeOnClose=true
    MinimizeToTray=true
    ShowTrayIcon=true
    TrayIconAppearance=monochrome-light

    [Security]
    IconDownloadFallback=true
  '';

  # Helper script: Verify Secret Service connection
  home.file."bin/secret-service-check.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "Checking Secret Service..."

      # Check if secret-tool is available
      if ! command -v secret-tool >/dev/null 2>&1; then
        echo "ERROR: secret-tool not found. Install libsecret."
        exit 1
      fi

      # Check D-Bus
      if ! busctl --user status org.freedesktop.secrets >/dev/null 2>&1; then
        echo "ERROR: No Secret Service provider on D-Bus"
        echo "Make sure KeePassXC is running with FdoSecrets enabled"
        exit 1
      fi

      echo "SUCCESS: Secret Service is available"
      echo ""
      echo "Test lookup: secret-tool lookup service test key test"
    '';
    executable = true;
  };

  # Helper script: rclone with secret-tool
  home.file."bin/rclone-secure.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Wrapper for rclone with KeePassXC secret retrieval
      export RCLONE_PASSWORD_COMMAND="secret-tool lookup service rclone key config-password"
      exec ${pkgs.rclone}/bin/rclone "$@"
    '';
    executable = true;
  };

  # Vault sync service (existing)
  systemd.user.services.keepassxc-vault-sync = {
    # ... existing sync configuration ...
  };
}
```

### Chezmoi Configuration

Add to `home-manager/chezmoi.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    chezmoi
    age  # Encryption for non-KeePassXC secrets
  ];

  # Chezmoi configuration with KeePassXC
  home.file.".config/chezmoi/chezmoi.toml".text = ''
    [keepassxc]
        database = "${config.home.homeDirectory}/MyVault/mitsio_secrets.kdbx"

    [data]
        email = "dtsioumas0@gmail.com"
        name = "dtsioumas"
  '';
}
```

---

## Implementation Plan

### Phase 1: Foundation ✅ COMPLETE (2025-11-30)

- [x] Add `libsecret` to home-manager packages
- [x] Verify FdoSecrets is working: `secret-service-check.sh`
- [x] Create "Workspace Secrets" group in KeePassXC (already existed)
- [x] Enable Secret Service for that group
- [x] Disable KDE Wallet (was conflicting with KeePassXC)
- [x] Test with: `secret-tool store --label="test" service test key test`
- [x] Create helper scripts (`secret-service-check.sh`, `rclone-secure.sh`, `keepassxc-unlock-prompt.sh`)
- [x] Migrate `keepassxc.ini` from home-manager to chezmoi (for mutable config)

### Phase 2: Chezmoi Integration (Week 2)

- [ ] Add `keepassxc.database` to chezmoi.toml
- [ ] Create API key entries in KeePassXC
- [ ] Migrate `.bashrc` secrets to templates
- [ ] Migrate Claude Code settings to template
- [ ] Test with `chezmoi diff` and `chezmoi apply`

### Phase 3: rclone Integration (Week 2-3)

- [ ] Encrypt rclone.conf: `rclone config encryption set`
- [ ] Store rclone password in KeePassXC
- [ ] Add to Secret Service group
- [ ] Update `rclone-gdrive.nix` with `RCLONE_PASSWORD_COMMAND`
- [ ] Test with systemd timer
- [ ] Update Ansible playbook if needed

### Phase 4: Ansible Integration (Week 3)

- [ ] Create lookup wrapper using `keepassxc-cli` or `secret-tool`
- [ ] Update playbooks to use secret retrieval
- [ ] Test `rclone-gdrive-sync.yml` with secrets
- [ ] Document Ansible secret patterns

### Phase 5: Documentation & Testing (Week 4)

- [ ] Complete this documentation
- [ ] Create ADR for secret management decision
- [ ] Test on fresh install/VM
- [ ] Create recovery procedures
- [ ] Update dotfiles README

---

## Security Considerations

### Best Practices

1. **Master Password Strength**
   - Use strong passphrase (6+ words)
   - Consider YubiKey for 2FA

2. **Database Backup**
   - Current: Synced to Dropbox every 15 minutes
   - Database is encrypted; safe for cloud storage

3. **Secret Service Exposure**
   - Only expose necessary group
   - Enable "Confirm access" for sensitive entries
   - Review applications requesting access

4. **Memory Security**
   - Chezmoi caches password in memory (plain text) during execution
   - Close chezmoi promptly after use
   - Consider `keepassxc.prompt = true` for additional security

5. **Avoid Shell History**
   - Never pass secrets as command arguments
   - Use environment variables or stdin

### What NOT to Store in KeePassXC

- Biometric data
- Extremely sensitive keys (air-gapped better)
- Secrets that should never leave hardware (use YubiKey)

---

## Troubleshooting

### Chezmoi Issues

**"keepassxc-cli: command not found"**
```bash
# Verify KeePassXC is installed
which keepassxc-cli

# Alternative: use builtin mode
# In chezmoi.toml:
# [keepassxc]
#     mode = "builtin"
```

**"database is locked"**
- Open and unlock KeePassXC before running chezmoi
- Or use `keepassxc --pw-stdin` with a key file

### secret-tool Issues

**"No matching items"**
- Check entry attributes match lookup query
- Verify entry is in Secret Service-enabled group
- Some attribute names with hyphens may not work

**"Another secret service is running"**
```bash
# Check what's running
busctl --user status org.freedesktop.secrets

# Disable GNOME Keyring
systemctl --user stop gnome-keyring-daemon.service
systemctl --user mask gnome-keyring-daemon.service
```

### rclone Issues

**"config file encrypted but no password provided"**
```bash
# Check environment variable is set
echo $RCLONE_PASSWORD_COMMAND

# Test secret-tool
secret-tool lookup service rclone key config-password
```

---

## References

### Official Documentation

- [KeePassXC User Guide](https://keepassxc.org/docs/KeePassXC_UserGuide)
- [chezmoi KeePassXC Integration](https://www.chezmoi.io/user-guide/password-managers/keepassxc/)
- [chezmoi KeePassXC Functions](https://www.chezmoi.io/reference/templates/keepassxc-functions/)
- [NixOS Secret Service Wiki](https://wiki.nixos.org/wiki/Secret_Service)

### Related Project Documentation

- [ADR-001: NixOS Stable vs Home-Manager Unstable](../../../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md)
- [ADR-002: Ansible Handles rclone Sync](../../../adrs/ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md)
- [Chezmoi Migration Docs](../../chezmoi/README.md)
- [rclone GDrive Sync Setup](../backup-gdrive-home-dir-with-syncthing/README.md)

### Community Resources

- [KeePassXC Secret Service walkthrough](https://avaldes.co/2020/01/28/secret-service-keepassxc.html)
- [Using secret-tool with KeePassXC](https://c3pb.de/blog/keepassxc-secrets-service.html)
- [Gentoo Wiki - KeePassXC CLI](https://wiki.gentoo.org/wiki/KeePassXC/cli)

---

## Changelog

| Date | Change |
|------|--------|
| 2025-11-29 | Initial document created from research session |
| 2025-11-30 | **Phase 1 Complete**: libsecret installed, KDE Wallet disabled, FdoSecrets verified, helper scripts created |
| 2025-11-30 | **Phase 2 Complete**: Chezmoi config added, API key entries created, .bashrc integration working |

---

## Phase 1 Implementation Details (2025-11-30)

### What Was Done

1. **Added libsecret to home-manager** (`keepassxc.nix`)
   - Provides `secret-tool` CLI for Secret Service access

2. **Disabled KDE Wallet**
   - Created `~/.config/kwalletrc` with `Enabled=false`
   - KDE Wallet's `ksecretd` was previously owning `org.freedesktop.secrets`

3. **Created Helper Scripts** in `~/bin/`:
   - `secret-service-check.sh` - Comprehensive diagnostic script
   - `rclone-secure.sh` - rclone wrapper with Secret Service password retrieval
   - `keepassxc-unlock-prompt.sh` - Desktop notification for unlock prompts

4. **Migrated keepassxc.ini to chezmoi**
   - Home-manager's symlink to nix store was read-only
   - Now managed by chezmoi at `~/.local/share/chezmoi/dot_config/keepassxc/keepassxc.ini`
   - Allows KeePassXC to modify its own settings

5. **Verified FdoSecrets Integration**
   ```
   === Secret Service Diagnostic ===
   1. secret-tool installed: YES
   2. D-Bus Secret Service: AVAILABLE (provider: .keepassxc-wrap)
   3. KeePassXC owns service: YES
   4. Store/Lookup test: OK
   ```

### Files Modified

| File | Change |
|------|--------|
| `home-manager/keepassxc.nix` | Added libsecret, helper scripts, kwalletrc; removed keepassxc.ini |
| `~/.local/share/chezmoi/dot_config/keepassxc/keepassxc.ini` | Created (migrated from home-manager) |
| `~/.config/kwalletrc` | Created by home-manager to disable KDE Wallet |

### Issues Resolved

1. **KDE Wallet Conflict**: `ksecretd` was providing Secret Service
   - Solution: Disable KDE Wallet via kwalletrc

2. **Read-only Config**: Home-manager symlinks are immutable
   - Solution: Migrate to chezmoi for mutable configs

3. **FdoSecrets UI Greyed Out**: Needed to enable at application level first
   - Solution: Tools → Settings → Secret Service Integration

---

## Phase 2 Implementation Details (2025-11-30)

### What Was Done

1. **Configured Chezmoi for KeePassXC**
   - Updated `home-manager/chezmoi.nix`
   - Added KeePassXC database path to `chezmoi.toml`
   - Preserved existing chezmoi settings (git, diff, merge, data)

2. **Created KeePassXC Entries**
   - **Anthropic** entry: `service=anthropic`, `key=apikey`
   - **GitHub-PAT** entry: `service=github`, `key=pat`
   - **Important Discovery**: Entries must be in **root** of "Workspace Secrets", not subgroups!

3. **Migrated .bashrc Secrets**
   - **Architecture Decision**: Use home-manager instead of chezmoi for .bashrc
   - Added KeePassXC secret retrieval to `home-manager/shell.nix`
   - Uses `secret-tool lookup` (FdoSecrets) instead of `keepassxc` function (TTY issues)
   - Graceful degradation: silent failure if database locked or tool missing

4. **Created Bootstrap Guide**
   - `~/.local/share/chezmoi/KEEPASSXC_BOOTSTRAP.md`
   - Documents fresh install procedure
   - Includes troubleshooting and recovery steps

5. **Claude Code Settings** (SKIPPED)
   - User uses Claude Code subscription, not API mode
   - No `apiKey` needed in settings.json
   - ANTHROPIC_API_KEY in .bashrc reserved for future CLI tools

### Files Modified

| File | Change |
|------|--------|
| `home-manager/chezmoi.nix` | Added KeePassXC database config to chezmoi.toml |
| `home-manager/shell.nix` | Added API key retrieval from KeePassXC via secret-tool |
| `~/.local/share/chezmoi/dot_bashrc.tmpl` | Updated (but not used - kept home-manager approach) |
| `~/.local/share/chezmoi/KEEPASSXC_BOOTSTRAP.md` | Created bootstrap guide |
| `docs/plans/KEEPASSXC_INTEGRATION_PLAN.md` | Updated status, added Phase 2 log |

### Architecture Decisions

**Why home-manager instead of chezmoi for .bashrc?**
- Chezmoi's `keepassxc` function requires TTY for password prompts
- `secret-tool` works perfectly in bash init scripts (non-interactive)
- All shell config stays in one place
- Simpler integration, no conflicts

**Why secret-tool instead of keepassxc function?**
- No password prompt when database already unlocked
- Works in non-interactive contexts (systemd services, scripts)
- Direct FdoSecrets integration

### Verification Results

```bash
# Secret Service access
$ secret-tool lookup service anthropic key apikey
sk-ant-api03-... ✅

$ secret-tool lookup service github key pat
github_pat_... ✅

# Shell integration
$ source ~/.bashrc
$ echo ${ANTHROPIC_API_KEY:0:20}
sk-ant-api03-... ✅
```

### Issues Resolved

1. **Chezmoi TTY Errors**: `keepassxc` function requires interactive terminal
   - Solution: Use `secret-tool` with FdoSecrets instead

2. **.bashrc Management Conflict**: Both home-manager and chezmoi managing .bashrc
   - Solution: Keep .bashrc in home-manager, add KeePassXC integration there

3. **Entries in Subgroups Not Accessible**: FdoSecrets only exposes root-level entries
   - Solution: Move entries to root of "Workspace Secrets" group

4. **Claude Code API vs Subscription**: Confusion about which mode to use
   - Solution: User confirmed subscription → skip apiKey in settings.json

---

**Next Steps:**
1. ~~Review this plan with Mitsio~~ ✅
2. ~~Create ADR for secret management decision~~ (Phase 5)
3. ~~Begin Phase 1 implementation~~ ✅
4. ~~Begin Phase 2: Add API keys to KeePassXC, configure chezmoi templates~~ ✅
5. **Begin Phase 3**: rclone integration (HIGH PRIORITY - cleartext OAuth tokens!)
