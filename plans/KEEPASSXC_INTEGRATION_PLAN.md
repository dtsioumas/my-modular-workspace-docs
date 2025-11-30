# KeePassXC Central Secret Manager - Implementation Plan

**Created:** 2025-11-29
**Status:** Phase 1-2 Complete ✅ | Phases 3-5 Pending
**Author:** Mitsio + Claude Code (Planner Role)
**Ultrathink Duration:** 7+ minutes (15 sequential thoughts)
**Project:** my-modular-workspace
**Last Updated:** 2025-11-30 (Phase 2 completed)

---

## Executive Summary

This plan outlines the complete implementation of KeePassXC as the **central secret manager** for the entire modular workspace ecosystem. The implementation spans **5 phases over 2 weeks**, covering:

- **Phase 1**: Foundation setup (libsecret, FdoSecrets verification)
- **Phase 2**: Chezmoi dotfile secret integration
- **Phase 3**: rclone encrypted config with Secret Service
- **Phase 4**: Ansible playbook secret retrieval
- **Phase 5**: Documentation and testing

**Total Estimated Effort:** 14-16 hours
**Files Affected:** 25+ across 4 repositories
**Risk Level:** Medium (mitigations documented)

---

## Table of Contents

1. [Repository Structure and Paths](#1-repository-structure-and-paths)
2. [Secrets Inventory](#2-secrets-inventory)
3. [Phase 1: Foundation Setup](#3-phase-1-foundation-setup)
4. [Phase 2: Chezmoi Integration](#4-phase-2-chezmoi-integration)
5. [Phase 3: rclone Integration](#5-phase-3-rclone-integration)
6. [Phase 4: Ansible Integration](#6-phase-4-ansible-integration)
7. [Phase 5: Documentation & Testing](#7-phase-5-documentation--testing)
8. [Guidelines and Best Practices](#8-guidelines-and-best-practices)
9. [Verification Criteria](#9-verification-criteria)
10. [Timeline and Dependencies](#10-timeline-and-dependencies)
11. [Troubleshooting Guide](#11-troubleshooting-guide)
12. [Rollback Procedures](#12-rollback-procedures)
13. [Future Enhancements](#13-future-enhancements)

---

## 1. Repository Structure and Paths

### Project Root
```
/home/mitsio/.MyHome/MySpaces/my-modular-workspace/
```

### All Files to Create or Modify

#### HOME-MANAGER REPO (`./home-manager/`)
| File | Action | Purpose |
|------|--------|---------|
| `keepassxc.nix` | **MODIFY** | Add libsecret, helper scripts, activation checks |
| `chezmoi.nix` | **MODIFY** | Add KeePassXC database config |
| `rclone-gdrive.nix` | **MODIFY** | Add RCLONE_PASSWORD_COMMAND, pre-checks |
| `shell.nix` | **MODIFY** | Remove Bitwarden aliases if migrating |
| `home.nix` | **VERIFY** | Ensure all imports correct |
| `flake.nix` | **VERIFY** | No changes needed |

#### DOTFILES REPO (`./dotfiles/`)
| File | Action | Purpose |
|------|--------|---------|
| `dot_bashrc.tmpl` | **MODIFY** | Add KeePassXC secret templates |
| `private_dot_claude/settings.json.tmpl` | **MODIFY** | Add API key from KeePassXC |
| `.chezmoiignore` | **VERIFY** | May need updates |
| `README.md` | **MODIFY** | Document KeePassXC integration |

#### ANSIBLE REPO (`./ansible/`)
| File | Action | Purpose |
|------|--------|---------|
| `playbooks/rclone-gdrive-sync.yml` | **MODIFY** | Add secret retrieval |
| `playbooks/rclone-gdrive-sync-v2.yml` | **MODIFY** | Add secret retrieval |
| `roles/common/tasks/secrets.yml` | **CREATE** | Reusable secret tasks |

#### DOCS REPO (`./docs/`)
| File | Action | Purpose |
|------|--------|---------|
| `adrs/ADR-005-KEEPASSXC_AS_CENTRAL_SECRET_MANAGER.md` | **CREATE** | Decision record |
| `integrations/KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md` | **EXISTS** | Reference doc |
| `integrations/KEEPASSXC_BOOTSTRAP_GUIDE.md` | **CREATE** | Fresh install guide |
| `plans/KEEPASSXC_INTEGRATION_PLAN.md` | **CREATE** | This file |

#### NIXOS CONFIG (`./hosts/shoshin/nixos/`)
| File | Action | Purpose |
|------|--------|---------|
| `configuration.nix` | **MODIFY** | Disable GNOME Keyring if present |

#### USER HOME DIRECTORY
| Path | Action | Purpose |
|------|--------|---------|
| `~/MyVault/mitsio_secrets.kdbx` | **MODIFY** | Add groups and entries |
| `~/.config/rclone/rclone.conf` | **MODIFY** | Enable encryption |
| `~/bin/secret-service-check.sh` | **CREATE** | Diagnostic script |
| `~/bin/rclone-secure.sh` | **CREATE** | Secure rclone wrapper |
| `~/bin/keepassxc-unlock-prompt.sh` | **CREATE** | Notification helper |

---

## 2. Secrets Inventory

### Current Secrets to Migrate

| Secret | Current Location | Risk | Priority |
|--------|------------------|------|----------|
| rclone OAuth tokens | `~/.config/rclone/rclone.conf` | **HIGH** (cleartext) | P1 |
| ANTHROPIC_API_KEY | Environment variable | MEDIUM | P2 |
| GitHub PAT | Various | MEDIUM | P2 |
| Atuin sync key | `~/.config/atuin/` | LOW | P3 |
| Bitwarden password | Memory only | LOW | P4 |

### KeePassXC Database Structure (To Create)

```
Root
├── Workspace Secrets (FdoSecrets Group) ← Secret Service enabled
│   ├── Infrastructure
│   │   ├── rclone-config-password
│   │   └── gdrive-oauth-backup
│   ├── API Keys
│   │   ├── Anthropic
│   │   ├── OpenAI
│   │   └── GitHub-PAT
│   ├── Sync Services
│   │   ├── Atuin-sync-key
│   │   └── Syncthing-device-id
│   └── Development
│       ├── npm-token
│       └── pypi-token
├── SSH Keys (SSH Agent Group) ← Optional
│   ├── id_ed25519_github
│   └── id_ed25519_work
└── Personal (Not automated)
    └── ...
```

---

## 3. Phase 1: Foundation Setup

**Duration:** Days 1-3 (2-3 hours)
**Dependencies:** None
**Prerequisite:** KeePassXC installed and database accessible

### Task 1.1: Update Home-Manager KeePassXC Module

**File:** `home-manager/keepassxc.nix`
**Duration:** 1 hour

#### Subtask 1.1.1: Add libsecret package
```nix
home.packages = with pkgs; [
  keepassxc
  libsecret  # Provides secret-tool CLI
  libnotify
];
```

#### Subtask 1.1.2: Create helper scripts

**secret-service-check.sh:**
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Checking Secret Service..."

if ! command -v secret-tool >/dev/null 2>&1; then
  echo "ERROR: secret-tool not found. Install libsecret."
  exit 1
fi

if ! busctl --user status org.freedesktop.secrets >/dev/null 2>&1; then
  echo "ERROR: No Secret Service provider on D-Bus"
  echo "Make sure KeePassXC is running with FdoSecrets enabled"
  exit 1
fi

echo "SUCCESS: Secret Service is available"
```

**rclone-secure.sh:**
```bash
#!/usr/bin/env bash
export RCLONE_PASSWORD_COMMAND="secret-tool lookup service rclone key config-password"
exec rclone "$@"
```

**keepassxc-unlock-prompt.sh:**
```bash
#!/usr/bin/env bash
notify-send -u critical "KeePassXC Required" \
  "Please unlock your KeePassXC database for automated services"
```

#### Subtask 1.1.3: Add activation verification
```nix
home.activation.verifySecretService = lib.hm.dag.entryAfter ["writeBoundary"] ''
  if command -v secret-tool >/dev/null 2>&1; then
    echo "Verifying Secret Service availability..."
    if ! busctl --user status org.freedesktop.secrets >/dev/null 2>&1; then
      echo "WARNING: Secret Service not available. Start KeePassXC."
    fi
  fi
'';
```

#### Subtask 1.1.4: Apply and test
```bash
home-manager switch --flake .#mitsio@shoshin
which secret-tool
~/bin/secret-service-check.sh
```

### Task 1.2: Disable GNOME Keyring (if present)

**Duration:** 30 minutes

#### Subtask 1.2.1: Check current state
```bash
busctl --user status org.freedesktop.secrets
systemctl --user status gnome-keyring-daemon
```

#### Subtask 1.2.2: Disable if running

**Option A - NixOS config:**
```nix
services.gnome.gnome-keyring.enable = lib.mkForce false;
```

**Option B - systemd mask:**
```bash
systemctl --user stop gnome-keyring-daemon.service
systemctl --user mask gnome-keyring-daemon.service
```

#### Subtask 1.2.3: Verify KeePassXC owns D-Bus
```bash
# Restart KeePassXC
killall keepassxc; keepassxc &

# Check ownership
busctl --user status org.freedesktop.secrets
# Should show KeePassXC process
```

### Task 1.3: Configure KeePassXC Database Structure

**Tool:** KeePassXC GUI
**Duration:** 30 minutes

#### Subtask 1.3.1: Create "Workspace Secrets" group
1. Open KeePassXC
2. Right-click root → New Group
3. Name: `Workspace Secrets`

#### Subtask 1.3.2: Enable Secret Service for group
1. Database → Database Settings
2. Go to "Secret Service Integration" tab
3. Check "Expose entries under this group"
4. Select "Workspace Secrets" group

#### Subtask 1.3.3: Create subgroups
- Infrastructure
- API Keys
- Sync Services
- Development

#### Subtask 1.3.4: Create initial test entry
- Group: Workspace Secrets/Infrastructure
- Title: `test-entry`
- Password: `test-password-123`
- Attributes: `service=test`, `key=test`

### Task 1.4: Verify FdoSecrets Working

**Duration:** 15 minutes

#### Subtask 1.4.1: Test secret-tool store
```bash
printf "test-value" | secret-tool store --label="Test Secret" service test key test
```

#### Subtask 1.4.2: Test secret-tool lookup
```bash
secret-tool lookup service test key test
# Expected: test-value
```

#### Subtask 1.4.3: Clean up test
```bash
secret-tool clear service test key test
```

---

## 4. Phase 2: Chezmoi Integration

**Duration:** Days 4-7 (3-4 hours)
**Dependencies:** Phase 1 complete, FdoSecrets working

### Task 2.1: Configure Chezmoi for KeePassXC

**File:** `home-manager/chezmoi.nix`
**Duration:** 30 minutes

#### Subtask 2.1.1: Update chezmoi.nix
```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    chezmoi
    age
  ];

  home.file.".config/chezmoi/chezmoi.toml".text = ''
    [keepassxc]
        database = "${config.home.homeDirectory}/MyVault/mitsio_secrets.kdbx"

    [data]
        email = "dtsioumas0@gmail.com"
        name = "dtsioumas"
  '';
}
```

#### Subtask 2.1.2: Apply home-manager
```bash
home-manager switch --flake .#mitsio@shoshin
cat ~/.config/chezmoi/chezmoi.toml
```

#### Subtask 2.1.3: Test chezmoi access
```bash
# Unlock KeePassXC first!
chezmoi execute-template '{{ (keepassxc "test-entry").Password }}'
# Expected: test-password-123
```

### Task 2.2: Create KeePassXC Entries for Secrets

**Tool:** KeePassXC GUI
**Duration:** 30 minutes

#### Subtask 2.2.1: Create API/Anthropic entry
- **Group:** Workspace Secrets/API Keys
- **Title:** `Anthropic`
- **UserName:** (your email or leave empty)
- **Password:** (copy from current ANTHROPIC_API_KEY env)
- **URL:** `https://console.anthropic.com`

#### Subtask 2.2.2: Create API/GitHub-PAT entry
- **Group:** Workspace Secrets/API Keys
- **Title:** `GitHub-PAT`
- **Password:** (personal access token)
- **Additional Attributes:**
  - `scope` = `repo,workflow`
  - `service` = `github`
  - `key` = `pat`

#### Subtask 2.2.3: Verify entries accessible
```bash
chezmoi execute-template '{{ (keepassxc "API Keys/Anthropic").Password }}'
```

### Task 2.3: Migrate .bashrc Secrets

**File:** `dotfiles/dot_bashrc.tmpl`
**Duration:** 1 hour

#### Subtask 2.3.1: Backup current .bashrc
```bash
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d)
```

#### Subtask 2.3.2: Update template with conditionals
```bash
# In dotfiles/dot_bashrc.tmpl

# === API Keys from KeePassXC ===
{{- $dbPath := joinPath .chezmoi.homeDir "MyVault/mitsio_secrets.kdbx" }}
{{- if stat $dbPath }}
# Secrets loaded from KeePassXC
export ANTHROPIC_API_KEY="{{ (keepassxc "API Keys/Anthropic").Password }}"
{{- else }}
# KeePassXC database not found - configure secrets manually
# export ANTHROPIC_API_KEY="your-key-here"
{{- end }}
```

#### Subtask 2.3.3: Test template
```bash
chezmoi execute-template < ~/.local/share/chezmoi/dot_bashrc.tmpl | grep ANTHROPIC
```

#### Subtask 2.3.4: Apply with chezmoi
```bash
chezmoi diff ~/.bashrc
chezmoi apply ~/.bashrc
source ~/.bashrc
echo $ANTHROPIC_API_KEY
```

### Task 2.4: Migrate Claude Code Settings

**File:** `dotfiles/private_dot_claude/settings.json.tmpl`
**Duration:** 30 minutes

#### Subtask 2.4.1: Update template
```json
{{- $dbPath := joinPath .chezmoi.homeDir "MyVault/mitsio_secrets.kdbx" }}
{
{{- if stat $dbPath }}
  "apiKey": "{{ (keepassxc "API Keys/Anthropic").Password }}"
{{- else }}
  "apiKey": ""
{{- end }}
}
```

#### Subtask 2.4.2: Apply and verify
```bash
chezmoi diff ~/.claude/settings.json
chezmoi apply ~/.claude/settings.json
```

### Task 2.5: Handle Edge Cases

**Duration:** 30 minutes

#### Subtask 2.5.1: Document bootstrap procedure
Create note in README about:
1. Install basic home-manager first
2. Copy database from backup
3. Unlock database
4. Run full chezmoi apply

#### Subtask 2.5.2: Test graceful degradation
```bash
# Rename database temporarily
mv ~/MyVault/mitsio_secrets.kdbx ~/MyVault/mitsio_secrets.kdbx.bak

# Try chezmoi - should use fallback
chezmoi diff

# Restore
mv ~/MyVault/mitsio_secrets.kdbx.bak ~/MyVault/mitsio_secrets.kdbx
```

---

## 5. Phase 3: rclone Integration

**Duration:** Days 8-10 (2-3 hours)
**Dependencies:** Phase 1 complete (Phase 2 can run in parallel)

### Task 3.1: Encrypt rclone Configuration

**Duration:** 30 minutes

#### Subtask 3.1.1: Backup current config
```bash
cp ~/.config/rclone/rclone.conf ~/.config/rclone/rclone.conf.backup.$(date +%Y%m%d)
# Store backup securely - contains OAuth tokens!
```

#### Subtask 3.1.2: Generate encryption password
- Open KeePassXC
- Tools → Password Generator
- Generate 32+ character password
- Copy to clipboard

#### Subtask 3.1.3: Create KeePassXC entry
- **Group:** Workspace Secrets/Infrastructure
- **Title:** `rclone-config-password`
- **Password:** (paste generated password)
- **Additional Attributes:**
  - `service` = `rclone`
  - `key` = `config-password`

#### Subtask 3.1.4: Enable rclone encryption
```bash
rclone config encryption set
# Enter the password from KeePassXC when prompted
# Confirm password
```

#### Subtask 3.1.5: Verify encryption
```bash
head -5 ~/.config/rclone/rclone.conf
# Should show encryption header

# Test with password command
RCLONE_PASSWORD_COMMAND="secret-tool lookup service rclone key config-password" \
  rclone listremotes
# Should list: GoogleDrive-dtsioumas0:
```

### Task 3.2: Verify Secret Service Entry

**Duration:** 15 minutes

#### Subtask 3.2.1: Test secret-tool lookup
```bash
secret-tool lookup service rclone key config-password
# Should return the password
```

#### Subtask 3.2.2: If lookup fails, check attributes
- Open entry in KeePassXC
- Go to Advanced → Additional Attributes
- Verify: `service=rclone`, `key=config-password`
- Note: Avoid hyphens in attribute names

### Task 3.3: Update rclone-gdrive.nix

**File:** `home-manager/rclone-gdrive.nix`
**Duration:** 1 hour

#### Subtask 3.3.1: Add password command to sync service
```nix
systemd.user.services.rclone-gdrive-sync = {
  Unit = {
    Description = "Sync ~/.MyHome to Google Drive";
    After = [ "network-online.target" ];
    Wants = [ "network-online.target" ];
  };

  Service = {
    Type = "oneshot";
    ExecStartPre = pkgs.writeShellScript "check-keepassxc" ''
      set -euo pipefail
      if ! ${pkgs.libsecret}/bin/secret-tool lookup service rclone key config-password >/dev/null 2>&1; then
        ${pkgs.libnotify}/bin/notify-send -u critical \
          "rclone Sync Failed" \
          "KeePassXC must be unlocked! Please unlock and retry."
        exit 1
      fi
    '';
    ExecStart = "${config.home.homeDirectory}/bin/rclone-gdrive-sync.sh";

    Environment = [
      "RCLONE_CONFIG=${config.home.homeDirectory}/.config/rclone/rclone.conf"
      "RCLONE_PASSWORD_COMMAND=${pkgs.libsecret}/bin/secret-tool lookup service rclone key config-password"
    ];
  };
};
```

#### Subtask 3.3.2: Update mount service similarly
```nix
systemd.user.services.rclone-gdrive-mount = {
  Service = {
    Environment = [
      "RCLONE_PASSWORD_COMMAND=${pkgs.libsecret}/bin/secret-tool lookup service rclone key config-password"
    ];
    # ... rest of config
  };
};
```

#### Subtask 3.3.3: Apply changes
```bash
home-manager switch --flake .#mitsio@shoshin
```

### Task 3.4: Test rclone Integration

**Duration:** 30 minutes

#### Subtask 3.4.1: Test manual sync
```bash
systemctl --user start rclone-gdrive-sync.service
journalctl --user -u rclone-gdrive-sync.service -f
```

#### Subtask 3.4.2: Test with locked database
```bash
# Lock KeePassXC database

# Try sync
systemctl --user start rclone-gdrive-sync.service

# Should see notification about unlocking
# Should fail gracefully
```

#### Subtask 3.4.3: Test mount service
```bash
systemctl --user restart rclone-gdrive-mount
ls ~/GoogleDrive
```

#### Subtask 3.4.4: Test timer
```bash
systemctl --user status rclone-gdrive-sync.timer
# Wait for next trigger or:
systemctl --user start rclone-gdrive-sync.timer
```

---

## 6. Phase 4: Ansible Integration

**Duration:** Days 11-12 (2 hours)
**Dependencies:** Phase 1 complete

### Task 4.1: Update Ansible Playbook

**File:** `ansible/playbooks/rclone-gdrive-sync-v2.yml`
**Duration:** 1 hour

#### Subtask 4.1.1: Add pre-flight secret check
```yaml
- name: Verify Secret Service is available
  block:
    - name: Check secret-tool can retrieve rclone password
      ansible.builtin.command:
        cmd: secret-tool lookup service rclone key config-password
      register: rclone_password_check
      changed_when: false
      failed_when: false
      no_log: true

    - name: Fail if secret not available
      ansible.builtin.fail:
        msg: >
          Cannot retrieve rclone password from Secret Service.
          Ensure KeePassXC is running and unlocked.
      when: rclone_password_check.rc != 0
```

#### Subtask 4.1.2: Set environment for rclone tasks
```yaml
- name: Run rclone bisync
  ansible.builtin.command:
    cmd: rclone bisync ...
  environment:
    RCLONE_PASSWORD_COMMAND: "secret-tool lookup service rclone key config-password"
  # ... rest of task
```

#### Subtask 4.1.3: Add error handling
```yaml
  rescue:
    - name: Send failure notification
      ansible.builtin.command:
        cmd: >
          notify-send -u critical
          "Ansible rclone Sync Failed"
          "Secret Service unavailable or error occurred"
```

### Task 4.2: Create Reusable Secret Role

**File:** `ansible/roles/common/tasks/secrets.yml` (new)
**Duration:** 30 minutes

```yaml
---
# roles/common/tasks/secrets.yml
# Reusable tasks for secret retrieval

- name: Get secret from KeePassXC via Secret Service
  ansible.builtin.command:
    cmd: "secret-tool lookup service {{ secret_service }} key {{ secret_key }}"
  register: secret_result
  changed_when: false
  failed_when: secret_result.rc != 0
  no_log: true

- name: Set secret fact
  ansible.builtin.set_fact:
    "{{ secret_var_name }}": "{{ secret_result.stdout }}"
  no_log: true
```

### Task 4.3: Test Ansible Integration

**Duration:** 30 minutes

#### Subtask 4.3.1: Run in check mode
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync-v2.yml --check
```

#### Subtask 4.3.2: Run actual playbook
```bash
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync-v2.yml -v
```

#### Subtask 4.3.3: Verify no secrets in output
- Check ansible output
- Ensure `no_log: true` is working
- No passwords visible in `-v` output

---

## 7. Phase 5: Documentation & Testing

**Duration:** Days 13-14 (3-4 hours)
**Dependencies:** Phases 1-4 complete

### Task 5.1: Create ADR

**File:** `docs/adrs/ADR-005-KEEPASSXC_AS_CENTRAL_SECRET_MANAGER.md`
**Duration:** 1 hour

Contents:
- Decision context and problem statement
- Why KeePassXC over alternatives (Bitwarden CLI, pass, Vault)
- Technical decisions (FdoSecrets vs keepassxc-cli)
- Consequences (positive/negative)
- Review date

### Task 5.2: Update Project Documentation

**Duration:** 1 hour

#### Subtask 5.2.1: Update dotfiles/README.md
- Add KeePassXC as requirement
- Document chezmoi template usage
- Update quick start instructions

#### Subtask 5.2.2: Update home-manager/README.md
- Document keepassxc.nix changes
- Document rclone-gdrive.nix changes

### Task 5.3: Create Bootstrap Guide

**File:** `docs/integrations/KEEPASSXC_BOOTSTRAP_GUIDE.md`
**Duration:** 1 hour

Contents:
- Fresh install procedure step-by-step
- How to restore database from backup
- How to apply configs with secrets
- Recovery procedures

### Task 5.4: Test on Fresh Environment

**Duration:** 2 hours

#### Subtask 5.4.1: Create test environment
- Use NixOS VM or clean user account

#### Subtask 5.4.2: Follow bootstrap guide
- Note any issues or missing steps

#### Subtask 5.4.3: Test all integrations
- [ ] Chezmoi secrets resolve
- [ ] rclone sync works
- [ ] Ansible playbook runs

#### Subtask 5.4.4: Update documentation
- Fix any issues found
- Add troubleshooting entries

---

## 8. Guidelines and Best Practices

### Security Guidelines

| Do | Don't |
|----|-------|
| Use secret-tool with FdoSecrets | Store master password in files |
| Use `no_log: true` in Ansible | Pass passwords as command arguments |
| Use environment variables | Log or echo passwords |
| Use chezmoi templates | Commit unencrypted secrets to git |
| Enable "Confirm access" in KeePassXC | Share master password |

### Coding Guidelines

#### Nix/Home-Manager
```nix
# GOOD: Use explicit package paths
ExecStart = "${pkgs.libsecret}/bin/secret-tool lookup ...";

# BAD: Rely on PATH
ExecStart = "secret-tool lookup ...";
```

#### Bash Scripts
```bash
# ALWAYS use strict mode
#!/usr/bin/env bash
set -euo pipefail

# ALWAYS check prerequisites
if ! command -v secret-tool >/dev/null 2>&1; then
  echo "ERROR: secret-tool not found" >&2
  exit 1
fi
```

#### Chezmoi Templates
```
# Use conditionals for optional secrets
{{- if stat (joinPath .chezmoi.homeDir "MyVault/mitsio_secrets.kdbx") }}
export SECRET="{{ (keepassxc "entry").Password }}"
{{- end }}
```

#### Ansible
```yaml
# ALWAYS use no_log for secrets
- name: Get secret
  command: secret-tool lookup service foo key bar
  register: my_secret
  no_log: true
  changed_when: false
```

### Operational Guidelines

**Before automated sync:**
- [ ] KeePassXC running
- [ ] Database unlocked
- [ ] Secret Service responding

**Before chezmoi apply:**
- [ ] Run `chezmoi diff` first
- [ ] Database unlocked
- [ ] Check for errors in diff output

**Regular maintenance:**
- [ ] Rotate secrets periodically
- [ ] Review Secret Service access
- [ ] Verify backup sync working
- [ ] Test recovery quarterly

---

## 9. Verification Criteria

### Phase 1 Completion
- [ ] `which secret-tool` returns path
- [ ] `busctl --user status org.freedesktop.secrets` shows KeePassXC
- [ ] `secret-tool lookup service test key test` works
- [ ] Helper scripts exist in `~/bin/`
- [ ] "Workspace Secrets" group exists in database

### Phase 2 Completion
- [ ] `cat ~/.config/chezmoi/chezmoi.toml` shows keepassxc config
- [ ] `chezmoi execute-template '{{ (keepassxc "API Keys/Anthropic").Password }}'` works
- [ ] `source ~/.bashrc && echo $ANTHROPIC_API_KEY` shows value
- [ ] Claude Code settings have API key

### Phase 3 Completion
- [ ] `head -1 ~/.config/rclone/rclone.conf` shows encryption
- [ ] `secret-tool lookup service rclone key config-password` returns password
- [ ] `systemctl --user start rclone-gdrive-sync` succeeds
- [ ] Notification appears when database locked

### Phase 4 Completion
- [ ] Ansible playbook has secret retrieval tasks
- [ ] Playbook runs without errors
- [ ] No passwords visible in output

### Phase 5 Completion
- [ ] ADR-005 exists
- [ ] Bootstrap guide exists
- [ ] Fresh install tested

### Success Metrics (Post-Implementation)
1. Zero secrets in cleartext files
2. All automated jobs use Secret Service
3. chezmoi apply works when KeePassXC unlocked
4. Recovery time < 30 minutes
5. No secret-related failures for 7 days

---

## 10. Timeline and Dependencies

### Implementation Schedule

```
Week 1 (Days 1-7)
├── Days 1-3: Phase 1 - Foundation
│   ├── Day 1: Tasks 1.1, 1.2
│   ├── Day 2: Task 1.3
│   └── Day 3: Task 1.4
└── Days 4-7: Phase 2 - Chezmoi
    ├── Day 4: Tasks 2.1, 2.2
    ├── Day 5: Task 2.3
    ├── Day 6: Task 2.4
    └── Day 7: Task 2.5

Week 2 (Days 8-14)
├── Days 8-10: Phase 3 - rclone
│   ├── Day 8: Tasks 3.1, 3.2
│   ├── Day 9: Task 3.3
│   └── Day 10: Task 3.4
├── Days 11-12: Phase 4 - Ansible
│   ├── Day 11: Tasks 4.1, 4.2
│   └── Day 12: Task 4.3
└── Days 13-14: Phase 5 - Documentation
    ├── Day 13: Tasks 5.1, 5.2
    └── Day 14: Tasks 5.3, 5.4
```

### Dependency Graph

```
Phase 1 Foundation
    │
    ├──► libsecret installed
    │
    ├──► FdoSecrets verified ──────────┐
    │                                   │
    └──► Database groups created ──────┼──► Phase 2 Chezmoi
                                        │         │
                                        │         ▼
                                        │    Templates work
                                        │
                                        ├──► Phase 3 rclone (parallel)
                                        │
                                        └──► Phase 4 Ansible (parallel)
                                                   │
                                                   ▼
                                              Phase 5 Docs
```

### Critical Path
```
Foundation → FdoSecrets Working → Chezmoi Config → First Template Applied
```

---

## 11. Troubleshooting Guide

### Issue: "Another secret service is running"

**Symptom:** KeePassXC shows warning
**Cause:** GNOME Keyring or other D-Bus provider active

**Solution:**
```bash
busctl --user status org.freedesktop.secrets
systemctl --user stop gnome-keyring-daemon.service
systemctl --user mask gnome-keyring-daemon.service
killall keepassxc && keepassxc &
```

### Issue: secret-tool returns empty

**Symptom:** Lookup returns nothing
**Causes:** Entry not in Secret Service group, wrong attributes, database locked

**Solution:**
1. Verify database is unlocked (visual check)
2. Check entry attributes: `service=<value>`, `key=<value>`
3. Check group is enabled for Secret Service
4. Try: `secret-tool search --all service myservice`

### Issue: chezmoi template fails

**Symptom:** Error on chezmoi apply
**Causes:** Database locked, entry missing, wrong path

**Solution:**
```bash
chezmoi execute-template '{{ (keepassxc "entry-name").Password }}'
keepassxc-cli show ~/MyVault/mitsio_secrets.kdbx "entry-name"
```

### Issue: rclone "no password" error

**Symptom:** Encrypted config but no password
**Causes:** Secret Service not responding, wrong attributes

**Solution:**
```bash
secret-tool lookup service rclone key config-password
systemctl --user show rclone-gdrive-sync | grep Environment
echo $DBUS_SESSION_BUS_ADDRESS
```

### Diagnostic Commands

```bash
# Full diagnostic
~/bin/secret-service-check.sh

# D-Bus status
busctl --user status org.freedesktop.secrets

# chezmoi health
chezmoi doctor

# Logs
journalctl --user -u rclone-gdrive-sync -f
```

---

## 12. Rollback Procedures

### Phase 1 Rollback
```bash
# Revert keepassxc.nix
git checkout home-manager/keepassxc.nix
home-manager switch --flake .#mitsio@shoshin

# Re-enable GNOME Keyring if needed
systemctl --user unmask gnome-keyring-daemon.service
systemctl --user start gnome-keyring-daemon.service
```

### Phase 2 Rollback
```bash
# Revert chezmoi files
chezmoi forget ~/.bashrc
cp ~/.bashrc.backup.YYYYMMDD ~/.bashrc

# Or revert templates
git checkout dotfiles/dot_bashrc.tmpl
chezmoi apply
```

### Phase 3 Rollback
```bash
# Remove rclone encryption
rclone config encryption clear

# Restore backup
cp ~/.config/rclone/rclone.conf.backup.YYYYMMDD ~/.config/rclone/rclone.conf

# Revert nix config
git checkout home-manager/rclone-gdrive.nix
home-manager switch --flake .#mitsio@shoshin
```

### Phase 4 Rollback
```bash
# Revert playbook
git checkout ansible/playbooks/rclone-gdrive-sync-v2.yml

# Ansible still works, just won't use secrets
```

### Emergency Recovery
```bash
# If database inaccessible:
# 1. Stop automated services
systemctl --user stop rclone-gdrive-sync.timer

# 2. Restore from backup (Dropbox, USB, etc.)
cp /backup/mitsio_secrets.kdbx ~/MyVault/

# 3. Unlock and restart
keepassxc ~/MyVault/mitsio_secrets.kdbx
systemctl --user start rclone-gdrive-sync.timer
```

---

## 13. Future Enhancements

### Optional Phase 6: Advanced Integrations

- **SSH Agent Integration:** Store SSH keys in KeePassXC
- **Git Credential Integration:** Use git-credential-libsecret
- **Bitwarden Migration:** Full migration from Bitwarden
- **Mobile Sync:** KeePassDX with Syncthing

### Cross-Platform (Fedora Migration)

When migrating to Fedora:
- KeePassXC available in repos
- FdoSecrets works identically
- secret-tool from libsecret
- Chezmoi/rclone unchanged

### Automation Wishlist

- Auto-unlock on login (security trade-off)
- Lock when screen locks
- Pre-flight check in KDE autostart
- Health monitoring and alerting

---

## Appendix A: Quick Reference Commands

```bash
# Check Secret Service
busctl --user status org.freedesktop.secrets
~/bin/secret-service-check.sh

# Secret operations
secret-tool store --label="Name" service svc key k
secret-tool lookup service svc key k
secret-tool clear service svc key k

# Chezmoi with KeePassXC
chezmoi execute-template '{{ (keepassxc "entry").Password }}'
chezmoi diff
chezmoi apply

# rclone with secrets
RCLONE_PASSWORD_COMMAND="secret-tool lookup service rclone key config-password" rclone listremotes

# Ansible
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync-v2.yml --check
```

---

## Appendix B: Related Documentation

- [KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md](../integrations/KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md)
- [ADR-001: NixOS Stable vs Home-Manager Unstable](../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md)
- [ADR-002: Ansible Handles rclone Sync](../adrs/ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md)
- [Chezmoi Migration Docs](../chezmoi/README.md)

---

**Document Version:** 1.1
**Last Updated:** 2025-11-29
**Next Review:** After Phase 5 completion

---

## Appendix C: Review Addendum (Post-Ultrathink Review)

**Review Duration:** 5+ minutes (8 sequential thoughts)
**Findings:** 37 issues across 7 categories

### Critical Fixes Required

These MUST be addressed before implementation:

#### Fix 1: Entry Path Syntax in Chezmoi Templates

**WRONG:**
```
{{ (keepassxc "API Keys/Anthropic").Password }}
```

**CORRECT:**
```
{{ (keepassxc "Anthropic").Password }}
```

KeePassXC lookup uses entry **TITLE only**, not group path. Update all template examples throughout this plan.

#### Fix 2: Attribute Naming Convention

**WRONG:** `key=config-password` (hyphen causes issues)

**CORRECT:** `key=configpassword` or `key=config_password`

Update all secret-tool commands to avoid hyphens in attribute values.

#### Fix 3: KDE Wallet Conflict (Plasma Users)

Add to Phase 1, Task 1.2:

```bash
# Check KDE Wallet status
qdbus org.kde.kwalletd5 /modules/kwalletd5 isEnabled

# Disable via config
cat > ~/.config/kwalletrc << 'EOF'
[Wallet]
Enabled=false
EOF

# Or mask systemd service
systemctl --user mask kwalletd5.service
```

#### Fix 4: Standalone Home-Manager Commands

This project uses **standalone home-manager**, not NixOS module.

**WRONG:** `sudo nixos-rebuild switch`
**CORRECT:** `home-manager switch --flake .#mitsio@shoshin`

---

### Additional Tasks to Add

#### Phase 1 Additions

**Task 1.0: Pre-flight Verification (NEW)**
```bash
# Verify KeePassXC
keepassxc --version

# Verify database path
ls -la ~/MyVault/mitsio_secrets.kdbx

# Verify symlink chain
readlink -f ~/MyVault

# Verify Dropbox (for vault sync)
pgrep -x dropbox || echo "WARNING: Dropbox not running"
```

**Task 1.2.5: Disable KDE Wallet (NEW)**
- Check and disable KDE Wallet if present
- See Fix 3 above for commands

**Task 1.5: Create Paper Backup (NEW)**
1. Write master password on paper
2. Store in secure physical location (safe, lockbox)
3. Consider splitting password (half at home, half at work)
4. Optional: Photograph and encrypt in secondary vault

#### Phase 2 Additions

**Task 2.0: Verify Chezmoi Initialized (NEW)**
```bash
# Check chezmoi source directory
if [ ! -d ~/.local/share/chezmoi ]; then
  echo "Chezmoi not initialized!"
  chezmoi init
fi
```

**Task 2.1.5: Verify KeePassXC Autostart (NEW)**
```bash
# Check existing autostart
ls ~/.config/autostart/*keepass* 2>/dev/null

# If missing, create
cat > ~/.config/autostart/org.keepassxc.KeePassXC.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=KeePassXC
Exec=keepassxc
Icon=keepassxc
Terminal=false
Categories=Utility;Security;
EOF
```

#### Phase 3 Additions

**Task 3.0: Pre-encryption Verification (NEW)**
```bash
# BEFORE encrypting, verify rclone works
rclone listremotes
rclone lsd GoogleDrive-dtsioumas0:MyHome/

# If these fail, DO NOT proceed with encryption
```

**Task 3.1.6: Secure Backup Deletion (NEW)**
```bash
# After encryption verified and working
shred -vfz -n 5 ~/.config/rclone/rclone.conf.backup.*

# Or use srm if available
srm -vz ~/.config/rclone/rclone.conf.backup.*
```

#### Phase 5 Additions

**Task 5.5: Create Integration Test Script (NEW)**

Create `~/bin/test-secrets-integration.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Secrets Integration Test Suite ==="
PASS=0
FAIL=0

# Test 1: D-Bus Secret Service
echo -n "Test 1: D-Bus Secret Service... "
if busctl --user status org.freedesktop.secrets >/dev/null 2>&1; then
  echo "PASS"; ((PASS++))
else
  echo "FAIL"; ((FAIL++))
fi

# Test 2: secret-tool available
echo -n "Test 2: secret-tool available... "
if command -v secret-tool >/dev/null 2>&1; then
  echo "PASS"; ((PASS++))
else
  echo "FAIL"; ((FAIL++))
fi

# Test 3: rclone password accessible
echo -n "Test 3: rclone password in Secret Service... "
if secret-tool lookup service rclone key configpassword >/dev/null 2>&1; then
  echo "PASS"; ((PASS++))
else
  echo "FAIL"; ((FAIL++))
fi

# Test 4: chezmoi can access KeePassXC
echo -n "Test 4: chezmoi KeePassXC access... "
if chezmoi execute-template '{{ (keepassxc "Anthropic").Title }}' >/dev/null 2>&1; then
  echo "PASS"; ((PASS++))
else
  echo "FAIL"; ((FAIL++))
fi

# Test 5: rclone with encryption
echo -n "Test 5: rclone with encrypted config... "
if RCLONE_PASSWORD_COMMAND="secret-tool lookup service rclone key configpassword" \
   rclone listremotes >/dev/null 2>&1; then
  echo "PASS"; ((PASS++))
else
  echo "FAIL"; ((FAIL++))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && exit 0 || exit 1
```

---

### Additional Paths to Document

| Path | Purpose |
|------|---------|
| `~/.config/systemd/user/` | User systemd service files |
| `~/.local/state/home-manager/` | Home-manager generations |
| `~/.cache/rclone/bisync-workdir/` | rclone bisync state |
| `/run/user/1000/` | XDG_RUNTIME_DIR, D-Bus socket |
| `~/.local/share/keyrings/` | GNOME Keyring (if migrating) |
| `~/.config/kwalletrc` | KDE Wallet config |

---

### Security Notes from Review

1. **Rclone Backup Security:** Delete backup after encryption verified (contains OAuth tokens in cleartext)

2. **Password Caching:** Chezmoi caches master password in memory during execution - close promptly after use

3. **Single Database for FdoSecrets:** Only ONE KeePassXC database can provide Secret Service at a time

4. **Entry Uniqueness:** Ensure entry titles are unique - chezmoi uses title for lookup

---

### Discrepancies Clarified

| Issue | Resolution |
|-------|------------|
| Timer interval (30min vs 1h) | Use current: 30 minutes (in rclone-gdrive.nix) |
| Active playbook version | Use v2: `rclone-gdrive-sync-v2.yml` |
| Bitwarden aliases | Keep for now, deprecate after full migration |

---

### Review Summary

| Category | Count |
|----------|-------|
| Critical Fixes | 4 |
| Missing Tasks | 9 |
| Discrepancies | 6 |
| Context Gaps | 8 |
| Security Concerns | 5 |
| Testing Gaps | 5 |
| Additional Paths | 6 |
| **Total Issues** | **43** |

**Recommendation:** Apply critical fixes before starting implementation. Add new tasks to each phase as specified above.

---

## Appendix D: Implementation Log

### Phase 1 Completion - 2025-11-30

**Completed by:** Mitsio + Claude Code
**Duration:** ~2.5 hours (including troubleshooting)
**Date:** 2025-11-30 02:58 EET

#### Tasks Completed

| Task | Status | Notes |
|------|--------|-------|
| Task 1.0: Pre-flight Verification | ✅ | Verified KeePassXC, vault path, Dropbox |
| Task 1.1: Update keepassxc.nix | ✅ | Added libsecret, helper scripts, activation hook |
| Task 1.2: Disable GNOME Keyring | ⏭️ | Skipped - not present on system |
| Task 1.2.5: Disable KDE Wallet | ✅ | Created kwalletrc with Enabled=false |
| Task 1.3: Configure Database Structure | ✅ | Workspace Secrets group already existed |
| Task 1.4: Verify FdoSecrets | ✅ | All diagnostic tests passed |
| Task 1.5: Paper Backup | ⏸️ | Deferred to user |

#### Files Modified

| File | Action | Description |
|------|--------|-------------|
| `home-manager/keepassxc.nix` | Modified | Added libsecret, helper scripts, removed keepassxc.ini |
| `~/.local/share/chezmoi/dot_config/keepassxc/keepassxc.ini` | Created | Migrated from home-manager to chezmoi |
| `~/.config/kwalletrc` | Created | Managed by home-manager, disables KDE Wallet |

#### Helper Scripts Created

- `~/bin/secret-service-check.sh` - Diagnostic script for Secret Service
- `~/bin/rclone-secure.sh` - Secure rclone wrapper with Secret Service
- `~/bin/keepassxc-unlock-prompt.sh` - Desktop notification for unlock prompts

#### Verification Results

```
=== Secret Service Diagnostic ===
1. secret-tool installed: YES
2. D-Bus Secret Service: AVAILABLE (provider: .keepassxc-wrap)
3. KeePassXC owns service: YES
4. Store/Lookup test: OK
=== Diagnostic Complete ===
```

#### Issues Encountered & Resolutions

1. **KDE Wallet conflict**: `ksecretd` was providing `org.freedesktop.secrets`
   - Resolution: Created `~/.config/kwalletrc` with `Enabled=false`, killed ksecretd

2. **keepassxc.ini read-only**: Home-manager created symlink to nix store
   - Resolution: Migrated to chezmoi management for mutable config

3. **FdoSecrets not accessible in UI**: Yellow warning in Database Settings
   - Resolution: Enable in Tools → Settings → Secret Service Integration first

#### Migration Notes

- KDE Wallet contents reviewed before disabling (Brave keys, kshaskpass GitHub creds)
- Browser encryption keys will regenerate automatically
- GitHub PAT already in KeePassXC, kshaskpass cache not needed

#### Next Phase Prerequisites

Phase 2 (Chezmoi Integration) can begin immediately:
- [x] libsecret/secret-tool available
- [x] FdoSecrets working
- [x] Workspace Secrets group exposed
- [x] Create entries for API keys (Anthropic, GitHub-PAT) in Workspace Secrets

---

### Phase 2 Completion - 2025-11-30

**Completed by:** Mitsio + Claude Code
**Duration:** ~2 hours
**Date:** 2025-11-30 23:45 EET

#### Tasks Completed

| Task | Status | Notes |
|------|--------|-------|
| Task 2.1: Configure Chezmoi for KeePassXC | ✅ | Added database path to chezmoi.toml |
| Task 2.2: Create KeePassXC Entries | ✅ | Created Anthropic and GitHub-PAT entries |
| Task 2.3: Migrate .bashrc secrets | ✅ | Migrated to home-manager shell.nix (not chezmoi) |
| Task 2.4: Migrate Claude Code settings | ⏭️ | Skipped - using subscription, not API |
| Task 2.5: Edge cases & bootstrap | ✅ | Created KEEPASSXC_BOOTSTRAP.md |

#### Files Modified

| File | Action | Description |
|------|--------|-------------|
| `home-manager/chezmoi.nix` | Modified | Added keepassxc database config to chezmoi.toml |
| `home-manager/shell.nix` | Modified | Disabled programs.bash, migrated management to chezmoi |
| `home-manager/shell.nix` | Reverted | Re-enabled for .bashrc, added KeePassXC integration |
| `~/.local/share/chezmoi/dot_bashrc.tmpl` | Modified | Added KeePassXC secret retrieval via secret-tool |
| `~/.local/share/chezmoi/KEEPASSXC_BOOTSTRAP.md` | Created | Bootstrap guide for fresh installs |

#### KeePassXC Entries Created

| Entry | Location | Attributes | Status |
|-------|----------|------------|--------|
| Anthropic | Workspace Secrets (root) | service=anthropic, key=apikey | ✅ |
| GitHub-PAT | Workspace Secrets (root) | service=github, key=pat | ✅ |

**Important Discovery:** Entries must be in the **root** of "Workspace Secrets", not in subgroups, for FdoSecrets to expose them.

#### Verification Results

```bash
# secret-tool access
$ secret-tool lookup service anthropic key apikey
sk-ant-api03-Ck5de0J... ✅

# .bashrc integration
$ source ~/.bashrc
$ echo ${ANTHROPIC_API_KEY:0:20}
sk-ant-api03-Ck5de0J... ✅
```

#### Issues Encountered & Resolutions

1. **Chezmoi TTY errors**: `keepassxc` function requires interactive password prompt
   - Resolution: Used `secret-tool` with FdoSecrets instead

2. **.bashrc management conflict**: Both home-manager and chezmoi tried to manage .bashrc
   - Resolution: Initially disabled programs.bash in shell.nix
   - **Final decision:** Keep .bashrc in home-manager, add KeePassXC integration there

3. **Entries in subgroups not accessible**: Created entries in "API Keys" subgroup
   - Resolution: Moved entries to root of "Workspace Secrets" group

4. **Claude Code API vs Subscription confusion**
   - Resolution: User confirmed using subscription → skipped apiKey in settings.json

#### Architecture Decisions

**Why home-manager instead of chezmoi for .bashrc?**
- Simpler integration (no TTY issues)
- All shell config in one place
- secret-tool works perfectly in bash init scripts
- Chezmoi still manages other dotfiles successfully

**Why secret-tool instead of keepassxc function?**
- No password prompt needed when database unlocked
- Works in non-interactive contexts
- Direct FdoSecrets integration

#### Next Phase Prerequisites

Phase 3 (rclone Integration) can begin:
- [x] secret-tool working with KeePassXC entries
- [x] .bashrc successfully loading secrets
- [ ] Create rclone-config-password entry in KeePassXC
- [ ] Encrypt rclone.conf with password
- [ ] Update rclone systemd services
