# KeePassXC as Central Secret Manager for Modular Workspace

**Status:** Implemented
**Project:** my-modular-workspace
**Last Updated:** 2025-12-01

---

## 1. Executive Summary

This document outlines the architecture and implementation of KeePassXC as the **primary secret manager** for the entire modular workspace. It provides a single, secure source of truth for secrets used by:

- **Shell Environments** (API Keys, tokens)
- **rclone** (Encrypted configuration password)
- **Chezmoi** (Dotfile templates)
- **Ansible** (Playbook secret retrieval)

The core of the integration relies on the **freedesktop.org Secret Service API (FdoSecrets)**, allowing applications to request secrets from an unlocked KeePassXC database via D-Bus.

---

## 2. Architecture

### 2.1. Core Components
- **KeePassXC Database:** A single `.kdbx` file (`~/MyVault/mitsio_secrets.kdbx`) stores all secrets, encrypted and synced via Dropbox.
- **FdoSecrets (D-Bus API):** KeePassXC exposes an API on the user's D-Bus session when a database is unlocked.
- **`secret-tool`:** A command-line utility from `libsecret` that acts as a client to the FdoSecrets API. It is the primary method for scripts and services to retrieve secrets.
- **systemd User Environment:** A systemd service runs once at login, retrieves all necessary secrets via `secret-tool`, and injects them into the systemd user environment. This makes secrets available to all shell sessions and applications without requiring a prompt for every new terminal.

### 2.2. Secret Flow Diagram
```
┌──────────────────────────┐      ┌───────────────────────────────┐      ┌──────────────────────────┐
│        User Login        │ ───> │ systemd --user starts         │ ───> │ load-keepassxc-secrets.service │
└──────────────────────────┘      └───────────────────────────────┘      └────────────┬─────────────┘
                                                                                      │ (One-time prompt)
                                                                                      ▼
┌──────────────────────────┐      ┌───────────────────────────────┐      ┌──────────────────────────┐
│ KeePassXC (Unlocked DB)  │ <─── │ secret-tool lookup service... │ <─── │   (Loads multiple secrets)     │
└──────────────────────────┘      └───────────────────────────────┘      └────────────┬─────────────┘
                                                                                      │
                                                                                      ▼
┌──────────────────────────┐      ┌───────────────────────────────┐      ┌──────────────────────────┐
│  systemd User Environment  │ ───> │ All New Terminals & Apps    │ ───> │ Inherit secrets as ENV VARS  │
└──────────────────────────┘      └───────────────────────────────┘      └──────────────────────────┘
```

---

## 3. Implementation Details

### 3.1. KeePassXC Configuration
- **FdoSecrets Enabled:** The feature is enabled in KeePassXC settings (`Tools > Settings > Secret Service Integration`).
- **Group Exposure:** A specific group within the database (e.g., "Workspace Secrets") is designated for Secret Service exposure.
- **Entry Attributes:** Secrets intended for automation are given specific attributes (`service=...`, `key=...`) to be discoverable by `secret-tool`.
- **Important:** FdoSecrets only exposes entries in the *root* of the designated group, not in subgroups.

### 3.2. Home-Manager Configuration (`keepassxc.nix`)
The `home-manager` module is responsible for setting up the entire integration environment:
- Installs `keepassxc`, `libsecret` (for `secret-tool`), and `libnotify`.
- Creates helper scripts for diagnostics and secure wrappers (e.g., `rclone-secure.sh`).
- Deploys the `load-keepassxc-secrets.service` systemd user unit.

### 3.3. Systemd Secret Loading (`load-keepassxc-secrets.service`)
- **Trigger:** Runs once after `graphical-session.target` is reached.
- **Action:**
    1. Waits for the KeePassXC D-Bus service to be available.
    2. Executes `secret-tool lookup` for each required secret.
    3. Injects the retrieved secrets into the systemd environment using `systemctl --user set-environment`.
- **Benefit:** This method requires only a **single KeePassXC authorization prompt** per login session, which is then inherited by all subsequent processes.

### 3.4. Rclone Integration
- The `rclone.conf` file is encrypted with a strong password.
- This password is stored as a secret in KeePassXC.
- The `rclone-gdrive.nix` systemd services use the `RCLONE_PASSWORD_COMMAND` environment variable, set to `secret-tool lookup service rclone key config-password`, to retrieve the password on demand.

### 3.5. Chezmoi Integration
- `chezmoi.toml` is configured with the path to the KeePassXC database.
- Templates can use the `keepassxc` function to pull secrets during `chezmoi apply`.
- **Example:** `export API_KEY="{{ (keepassxc "API/Entry-Title").Password }}"`
- **Note:** This method is best for static file generation, as it may require an interactive password prompt if the database is locked. For shell startup, the systemd approach is preferred.

---

## 4. Guidelines and Best Practices

- **Security:**
    - Use a strong master password for the database, backed by a YubiKey if possible.
    - Only expose the "Workspace Secrets" group to the Secret Service API.
    - Enable "Confirm access" for sensitive entries in KeePassXC.
- **Automation:**
    - Use `secret-tool` with `service` and `key` attributes for reliable lookups.
    - Avoid hyphens in attribute names.
    - In shell scripts and systemd services, always use the full path to `secret-tool` (e.g., `${pkgs.libsecret}/bin/secret-tool`).
- **Maintenance:**
    - Regularly backup the `.kdbx` database.
    - Create a paper backup of the master password.
    - Periodically review which applications have requested secret access.

---

## 5. Troubleshooting

- **"Another secret service is running"**: Usually a conflict with GNOME Keyring or KDE Wallet. Ensure they are disabled. For KDE, setting `Enabled=false` in `~/.config/kwalletrc` is effective.
- **`secret-tool` returns empty**:
    1.  Verify the KeePassXC database is unlocked.
    2.  Check that the entry's group is exposed to the Secret Service.
    3.  Confirm the entry is in the **root** of the exposed group.
    4.  Ensure the `service` and `key` attributes in KeePassXC match the `secret-tool lookup` command exactly.
- **Rclone "no password" error**: The `secret-tool` command failed. Run it manually to debug. Ensure the systemd service has the correct D-Bus environment to communicate.

---
This document is a consolidation of the original integration plan and the implementation logs. It reflects the final, working architecture.
