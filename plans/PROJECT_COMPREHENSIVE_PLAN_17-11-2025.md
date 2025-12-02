# Complete Multi-Tool Home Management System - Full Architecture Plan

**Session:** my-modular-workspace-decoupling-home
**Date:** 2025-11-17
**Goal:** Decouple all configurations from NixOS and create modular, portable system using best-in-class tools for each concern.

**Timeline:** 1-2 weeks (migration to Fedora on shoshin soon!)

**Architecture:** home-manager (packages) + chezmoi (dotfiles) + GNU Stow (symlinks) + Ansible (bootstrap) + KeePassXC (secrets)

**Design Principle:** Location-agnostic - works in any directory, easy to relocate to `~/MySpaces/my-modular-workspace/` later

---

## 🏗️ Architecture Overview

```
Multi-Tool Setup:

home-manager/          → Package/dependency management ONLY
├── flake.nix         → Standalone flake (packages + minimal services)
├── home.nix          → Minimal entry: packages + systemd services
└── modules/
    ├── packages.nix  → ALL ~105 packages
    └── services.nix  → Sync services (vault-sync, vscode-extensions)

dotfiles/             → Chezmoi + GNU Stow managed dotfiles
├── .chezmoi.toml     → Chezmoi configuration
├── dot_bashrc.tmpl   → Bash config (templated)
├── dot_config/
│   ├── kitty/        → Kitty terminal config
│   ├── plasma/       → KDE Plasma settings
│   └── VSCodium/     → Editor settings
├── private_dot_config/  → Encrypted configs (rclone, etc.)

ansible/              → Bootstrap automation
├── playbooks/
│   ├── bootstrap-nixos.yml      → NixOS fresh install
│   ├── bootstrap-fedora.yml     → Fedora fresh install
│   └── secrets-setup.yml        → KeePassXC + Dropbox integration
├── roles/
│   ├── base-install/            → Install Nix, home-manager, chezmoi
│   ├── secrets/                 → Download vault, setup KeePassXC CLI
│   ├── dotfiles/                → Apply chezmoi + stow
│   └── home-manager/            → Run home-manager switch
└── inventory/
    ├── shoshin-nixos.yml
    └── shoshin-fedora.yml

~/MyVault/            → KeePassXC database (Dropbox synced)
└── mitsio-secrets.kdbx      → All secrets (rclone, git tokens, etc.)
```

---

## 📦 Phase 1: Home-Manager - Packages Only (Day 1-2)

### Step 1.1: Create Standalone Home-Manager Structure

**Location:** Start in `~/.config/home-manager` (relocatable later)

```
~/.config/home-manager/
├── flake.nix              # Minimal standalone flake
├── flake.lock
├── home.nix               # Entry: imports only packages + services
├── modules/
│   ├── packages.nix       # ALL ~105 packages from system
│   └── services.nix       # ONLY sync services (vault-sync, extensions)
└── hosts/
    ├── shoshin-nixos.nix  # NixOS-specific overrides
    └── shoshin-fedora.nix # Fedora-specific overrides
```

**What gets extracted from current config:**
- ✅ ALL packages from `modules/workspace/packages.nix` → `packages.nix`
- ✅ ALL dev tools from `modules/development/` → `packages.nix`
- ✅ Sync services only (vault-sync, vscode-extensions) → `services.nix`
- ❌ NO dotfile configs (plasma.nix, kitty.nix, etc.) - those go to chezmoi

**home.nix structure:**
```nix
{ config, pkgs, ... }: {
  imports = [
    ./modules/packages.nix
    ./modules/services.nix
  ];

  home.username = "mitso";
  home.homeDirectory = "/home/mitso";
  home.stateVersion = "25.05";

  # Minimal settings - NO app configs here!
  programs.home-manager.enable = true;
}
```

### Step 1.2: Extract Packages

Create `modules/packages.nix` with ALL system packages:
- GUI apps: firefox, brave, obsidian, discord, keepassxc, etc.
- Dev tools: vscode, vscodium, git, gh, lazygit, etc.
- Languages: python3, go, nodejs, etc.
- CLI tools: htop, btop, jq, ripgrep, etc.
- System tools: rclone, syncthing, etc.

Total: ~105 packages categorized by function

### Step 1.3: Keep Minimal System Services

Extract to `modules/services.nix`:
```nix
{
  # User systemd services for syncing
  systemd.user.services = {
    keepassxc-vault-sync = { ... };  # Sync ~/MyVault/ via Dropbox
    vscode-extensions-update = { ... };
  };
}
```

**Result:** Home-manager manages packages + sync workflows only. Clean separation.

---

## 📄 Phase 2: Chezmoi - Dotfile Management (Day 2-3)

### Step 2.1: Initialize Chezmoi

```bash
# Install chezmoi (via home-manager packages.nix)
chezmoi init --apply

# Location: ~/.local/share/chezmoi/ (managed by git)
```

### Step 2.2: Migrate Configs from Home-Manager

**What moves from home-manager to chezmoi:**

| Current File | New Chezmoi Location | Purpose |
|--------------|---------------------|---------|
| `home/mitso/shell.nix` | `dot_bashrc.tmpl` | Bash config |
| `home/mitso/plasma.nix` | `dot_config/plasma/*.tmpl` | KDE settings |
| `home/mitso/kitty.nix` | `dot_config/kitty/kitty.conf.tmpl` | Kitty config |
| `home/mitso/vscodium.nix` | `dot_config/VSCodium/settings.json.tmpl` | VSCodium settings |
| `home/mitso/git.nix` (from home.nix) | `dot_gitconfig.tmpl` | Git config |

**Chezmoi templates with variables:**
```toml
# .chezmoi.toml
[data]
  hostname = "{{ .chezmoi.hostname }}"
  os = "{{ .chezmoi.os }}"

[data.git]
  name = "Dimitris Tsioumas"
  email = "dtsioumas0@gmail.com"

[data.plasma]
  monitor_count = 2  # shoshin-specific
```

### Step 2.3: Encrypted Secrets in Chezmoi

```bash
# For sensitive configs (rclone.conf, etc.)
chezmoi add --encrypt ~/.config/rclone/rclone.conf

# Creates: private_dot_config/rclone/rclone.conf.tmpl (encrypted)
```

**Password:** Retrieved from KeePassXC during bootstrap

### Step 2.4: Chezmoi Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl         # Config with variables
├── dot_bashrc.tmpl            # Bash config
├── dot_bash_aliases.tmpl      # Aliases
├── dot_gitconfig.tmpl         # Git config
├── dot_config/
│   ├── kitty/
│   │   ├── kitty.conf.tmpl
│   │   └── themes/
│   ├── plasma/
│   │   ├── plasmashellrc.tmpl
│   │   ├── plasmarc.tmpl
│   │   └── shortcuts.tmpl
│   ├── VSCodium/
│   │   └── settings.json.tmpl
│   └── keepassxc/
│       └── keepassxc.ini.tmpl
├── private_dot_config/        # Encrypted with chezmoi age
│   └── rclone/
│       └── rclone.conf.tmpl
└── .chezmoiignore             # Ignore patterns
```

**Result:** All dotfiles managed by chezmoi with templating + encryption

---

## 🔗 Phase 3: GNU Stow - Symlink Management (Day 3)

### Step 3.1: Create Stow Structure (Parallel to Chezmoi)

**Why both?**
- Chezmoi: Smart templating, encryption, cross-platform
- Stow: Simple, fast, traditional symlinks (backup/alternative)

```
~/dotfiles-stow/
├── bash/
│   ├── .bashrc
│   └── .bash_aliases
├── git/
│   └── .gitconfig
├── kitty/
│   └── .config/kitty/kitty.conf
├── plasma/
│   └── .config/plasma/
└── vim/
    └── .vimrc
```

### Step 3.2: Stow Deployment

```bash
cd ~/dotfiles-stow
stow bash   # Creates symlink ~/.bashrc → ~/dotfiles-stow/bash/.bashrc
stow git
stow kitty
```

**Use case:** Quick rollback, alternative to chezmoi, simpler for some configs

---

## 🤖 Phase 4: Ansible - Bootstrap Automation (Day 4-5)

### Step 4.1: Ansible Project Structure

```
~/ansible-bootstrap/  (or in my-modular-workspace later)
├── ansible.cfg
├── inventory/
│   ├── shoshin-nixos.yml      # NixOS inventory
│   └── shoshin-fedora.yml     # Fedora inventory
├── playbooks/
│   ├── bootstrap-nixos.yml    # Fresh NixOS setup
│   ├── bootstrap-fedora.yml   # Fresh Fedora setup
│   └── secrets-setup.yml      # KeePassXC + secrets integration
├── roles/
│   ├── base-install/
│   │   └── tasks/
│   │       ├── install-nix.yml
│   │       ├── install-home-manager.yml
│   │       └── install-chezmoi.yml
│   ├── secrets/
│   │   └── tasks/
│   │       ├── download-vault.yml       # Get KeePassXC DB from Dropbox
│   │       ├── setup-keepassxc-cli.yml  # Configure CLI access
│   │       └── configure-ansible-secrets.yml  # Ansible ↔ KeePassXC
│   ├── dotfiles/
│   │   └── tasks/
│   │       ├── clone-repos.yml
│   │       ├── apply-chezmoi.yml
│   │       └── apply-stow.yml
│   └── home-manager/
│       └── tasks/
│           └── run-home-manager.yml
└── group_vars/
    ├── nixos.yml
    └── fedora.yml
```

### Step 4.2: Bootstrap Playbook (Fresh Fedora Install)

```yaml
# playbooks/bootstrap-fedora.yml
---
- name: Bootstrap Fresh Fedora System
  hosts: shoshin-fedora
  become: yes

  tasks:
    # 1. Install base system packages
    - name: Install base packages via DNF
      dnf:
        name:
          - curl
          - git
          - vim
          - xz  # Required for Nix
        state: present

    # 2. Install Nix package manager
    - import_role:
        name: base-install
        tasks_from: install-nix

    # 3. Setup secrets (FIRST! Needed for everything else)
    - import_role:
        name: secrets
        tasks_from: download-vault  # Get ~/MyVault/ from Dropbox

    - import_role:
        name: secrets
        tasks_from: setup-keepassxc-cli

    - import_role:
        name: secrets
        tasks_from: configure-ansible-secrets  # Ansible can now read secrets

    # 4. Install home-manager
    - import_role:
        name: base-install
        tasks_from: install-home-manager

    # 5. Install chezmoi + stow
    - import_role:
        name: base-install
        tasks_from: install-chezmoi

    # 6. Clone dotfiles repos
    - import_role:
        name: dotfiles
        tasks_from: clone-repos

    # 7. Apply dotfiles (chezmoi)
    - import_role:
        name: dotfiles
        tasks_from: apply-chezmoi

    # 8. Run home-manager (install all packages)
    - import_role:
        name: home-manager
        tasks_from: run-home-manager

    # 9. Done! System ready
    - name: Bootstrap complete
      debug:
        msg: "System bootstrapped! All configs applied, secrets accessible."
```

### Step 4.3: KeePassXC Integration with Ansible

```yaml
# roles/secrets/tasks/configure-ansible-secrets.yml
---
- name: Install keepassxc-cli
  package:
    name: keepassxc
    state: present

- name: Test KeePassXC database access
  shell: |
    keepassxc-cli show {{ vault_path }}/secrets.kdbx rclone/google-drive \
      --no-password  # Uses KDE Wallet integration
  register: keepass_test

- name: Configure Ansible to use KeePassXC for secrets
  template:
    src: ansible-keepassxc-lookup.py.j2
    dest: /usr/local/bin/ansible-keepassxc-lookup
    mode: '0755'

- name: Create lookup plugin
  copy:
    src: keepassxc_lookup.py
    dest: ~/.ansible/plugins/lookup/keepassxc.py
```

**Usage in playbooks:**
```yaml
- name: Configure rclone with secrets from KeePassXC
  template:
    src: rclone.conf.j2
    dest: ~/.config/rclone/rclone.conf
  vars:
    gdrive_client_id: "{{ lookup('keepassxc', 'rclone/google-drive', 'client_id') }}"
    gdrive_client_secret: "{{ lookup('keepassxc', 'rclone/google-drive', 'client_secret') }}"
```

---

## 🔄 Phase 5: Integration & Testing (Day 6-7)

### Step 5.1: Test on Current NixOS (Parallel Setup)

```bash
# 1. Build standalone home-manager (packages only)
cd ~/.config/home-manager
home-manager switch --flake .#mitso@shoshin-nixos

# 2. Apply chezmoi dotfiles
chezmoi init https://github.com/dtsioumas/dotfiles.git
chezmoi apply

# 3. Verify both systems work
# - Old home-manager (in NixOS config) still runs
# - New standalone home-manager also runs
# - Chezmoi applied dotfiles
# Compare and verify no conflicts

# 4. Test Ansible bootstrap (dry run)
cd ~/ansible-bootstrap
ansible-playbook playbooks/bootstrap-nixos.yml --check

# 5. Test secrets access
keepassxc-cli show ~/MyVault/secrets.kdbx rclone/google-drive
```

### Step 5.2: Switch NixOS to New System

```bash
# Remove old home-manager from NixOS config
cd ~/.config/nixos
# Edit flake.nix - remove home-manager module
sudo nixos-rebuild switch --flake .#shoshin

# System now uses:
# - Standalone home-manager for packages
# - Chezmoi for dotfiles
# - Minimal NixOS config (only DE + drivers)
```

---

## 🚀 Phase 6: Fedora Migration on Shoshin (Week 2)

### Step 6.1: Pre-Migration Prep

```bash
# 1. Commit and push all repos
cd ~/.config/home-manager && git push
cd ~/.local/share/chezmoi && git push
cd ~/ansible-bootstrap && git push

# 2. Verify ~/MyVault/ is synced to Dropbox
# 3. Backup critical data
# 4. Create Fedora USB installer
```

### Step 6.2: Fresh Fedora Install on Shoshin

1. Boot Fedora installer
2. Install Fedora (KDE Spin recommended)
3. Boot into Fedora
4. Install minimal tools: `sudo dnf install git ansible`

### Step 6.3: Run Ansible Bootstrap

```bash
# Clone ansible repo
git clone https://github.com/dtsioumas/ansible-bootstrap.git
cd ansible-bootstrap

# Run bootstrap playbook
ansible-playbook -i inventory/shoshin-fedora.yml playbooks/bootstrap-fedora.yml

# This will:
# 1. Install Nix
# 2. Download ~/MyVault/ from Dropbox
# 3. Setup KeePassXC + secrets access
# 4. Install home-manager + apply packages
# 5. Apply dotfiles via chezmoi
# 6. System ready!
```

### Step 6.4: Verify Migration

```bash
# Check packages installed
home-manager packages

# Check dotfiles applied
chezmoi diff

# Check services running
systemctl --user status keepassxc-vault-sync

# Check secrets accessible
keepassxc-cli show ~/MyVault/secrets.kdbx rclone/google-drive

# Launch applications - everything should work!
```

---

## 📁 Future: Move to ~/MySpaces/my-modular-workspace/

**Design for easy relocation:**

```bash
# All repos use relative paths and environment variables
# Example in home.nix:
home.sessionVariables = {
  DOTFILES_ROOT = "${config.home.homeDirectory}/.local/share/chezmoi";
  WORKSPACE_ROOT = "${config.home.homeDirectory}/MySpaces/my-modular-workspace";
};

# When ready to move:
mv ~/.config/home-manager ~/MySpaces/my-modular-workspace/home-manager
mv ~/.local/share/chezmoi ~/MySpaces/my-modular-workspace/dotfiles
mv ~/ansible-bootstrap ~/MySpaces/my-modular-workspace/ansible

# Update flake.nix path reference
home-manager switch --flake ~/MySpaces/my-modular-workspace/home-manager#mitso@shoshin-fedora
```

---

## 📊 Summary: What Lives Where

| Tool | Manages | Location | Portable? |
|------|---------|----------|-----------|
| **home-manager** | ~105 packages + sync services | `~/.config/home-manager/` | ✅ NixOS + Fedora + any Linux |
| **chezmoi** | All dotfiles (bash, git, plasma, apps) | `~/.local/share/chezmoi/` | ✅ Cross-platform |
| **GNU Stow** | Symlinks (backup method) | `~/dotfiles-stow/` | ✅ Any Unix system |
| **Ansible** | Bootstrap automation | `~/ansible-bootstrap/` | ✅ Any system with Python |
| **KeePassXC** | Secrets store | `~/MyVault/secrets.kdbx` | ✅ Dropbox synced |

---

## ✅ Expected Outcomes

After complete setup:
- ✅ Fresh Fedora install → Run 1 Ansible playbook → Fully configured system
- ✅ All packages managed by home-manager (declarative)
- ✅ All dotfiles managed by chezmoi (templated, encrypted)
- ✅ Secrets in KeePassXC (synced, accessible to Ansible)
- ✅ Can migrate to any distro easily (NixOS, Fedora, Ubuntu, Arch, etc.)
- ✅ Modular design - each tool does one thing well
- ✅ Location-agnostic - can move to workspace directory easily

---

## 📅 Implementation Timeline

**Week 1:**
- Day 1-2: Phase 1 (home-manager packages)
- Day 2-3: Phase 2 (chezmoi dotfiles)
- Day 3: Phase 3 (GNU Stow)
- Day 4-5: Phase 4 (Ansible bootstrap)
- Day 6-7: Phase 5 (Testing & integration)

**Week 2:**
- Phase 6: Fedora migration on shoshin

---

## 🎯 Success Criteria

- [ ] Standalone home-manager builds successfully
- [ ] All 105+ packages install via home-manager
- [ ] Chezmoi manages all dotfiles
- [ ] GNU Stow provides backup symlink method
- [ ] Ansible playbook completes without errors
- [ ] KeePassXC integration works (secrets accessible)
- [ ] System survives reboot (all services start)
- [ ] Can migrate between NixOS ↔ Fedora seamlessly
- [ ] No manual configuration needed after Ansible run
- [ ] All configs version controlled in git

---

**Generated:** 2025-11-17
**Session:** my-modular-workspace-decoupling-home
**Author:** Claude Code + Mitso
