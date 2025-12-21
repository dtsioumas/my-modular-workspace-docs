# Eyeonix-Laptop Workspace - System Architecture

**Date**: 2025-12-17
**Version**: 1.0
**Status**: Design Complete

---

## Vision Statement

Transform eyeonix-laptop into a **fully declarative, reproducible, immutable workspace** where:
- **Windows acts as a minimal launcher**
- **Fedora Kinoite (WSL2) is the primary development environment**
- **Everything is version-controlled and reproducible**
- **Recovery time: <8 hours from bare metal**

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    WINDOWS 10 PRO (HOST)                    │
│                     Minimal Launcher                         │
│                                                               │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐        │
│  │  Winget     │  │ Chocolatey  │  │     DSC      │        │
│  │ MS Store    │  │  Dev Tools  │  │   Configs    │        │
│  │   Apps      │  │             │  │              │        │
│  └─────────────┘  └─────────────┘  └──────────────┘        │
│                                                               │
│  ┌──────────────────────────────────────────────┐           │
│  │              X410 X Server                    │           │
│  │     (Graphics Bridge to WSL2)                 │           │
│  └──────────────────────────────────────────────┘           │
│                          │                                    │
└──────────────────────────┼────────────────────────────────────┘
                           │ WSL2 Interface
┌──────────────────────────▼────────────────────────────────────┐
│                 FEDORA KINOITE (WSL2)                         │
│              Primary Development Environment                   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              KDE PLASMA DESKTOP                      │    │
│  │         (Displayed via X410 on Windows)              │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  rpm-ostree  │  │   Ansible    │  │   Chezmoi    │      │
│  │   (System    │  │    (Config   │  │  (Dotfiles)  │      │
│  │   Packages)  │  │  Management) │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           Containerized Development                  │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐     │    │
│  │  │ Toolbox  │  │Distrobox │  │    Docker/   │     │    │
│  │  │ (Fedora) │  │  (Arch,  │  │   Podman     │     │    │
│  │  │          │  │  Ubuntu) │  │  (Services)  │     │    │
│  │  └──────────┘  └──────────┘  └──────────────┘     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
                           │
                           │ Google Drive Sync
                           ▼
              ┌─────────────────────────┐
              │   KeePassXC Database    │
              │  (Single Source of      │
              │   Truth for Secrets)    │
              └─────────────────────────┘
```

---

## Component Breakdown

### Layer 1: Windows Host (Minimal Launcher)

**Role**: Boot system, launch WSL2, minimal native applications

#### Package Management

| Tool | Purpose | Managed By | Idempotent |
|------|---------|------------|------------|
| **Winget** | Microsoft Store apps (Claude, Teams, etc.) | Ansible `win_command` | ✅ Yes |
| **Chocolatey** | Dev tools (git, python, vim) | Ansible `win_chocolatey` | ✅ Yes |
| **DSC** | System configuration (registry, features) | Ansible `win_dsc` | ✅ Yes |

#### Key Components

```
Windows Host
├── System Configuration
│   ├── WSL2 enabled
│   ├── Hyper-V (if needed for VMs)
│   └── Developer Mode
│
├── Native Applications (Minimal)
│   ├── X410 X Server (graphics)
│   ├── Windows Terminal (launcher)
│   ├── VSCodium (fallback, if performance issues)
│   ├── Firefox (fallback, if performance issues)
│   └── Work Software (manual install)
│       ├── Check Point VPN
│       ├── VMware Workstation
│       └── Samsung Utilities
│
└── Automation
    ├── PowerShell bootstrap script
    ├── Ansible playbooks (win_*)
    └── Task Scheduler (weekly updates)
```

### Layer 2: WSL2 + Fedora Kinoite (Primary Environment)

**Role**: Main development workspace, runs 90%+ of daily work

#### Fedora Kinoite Details

| Aspect | Technology |
|--------|------------|
| **Base OS** | Fedora Kinoite (immutable, rpm-ostree) |
| **Desktop** | KDE Plasma (full desktop environment) |
| **Display Server** | X11 (via X410) |
| **Package Manager** | rpm-ostree (layering) + flatpak + toolbox |
| **Configuration** | Ansible + Chezmoi |

#### System Layers

```
Kinoite System
├── Base Layer (Immutable OSTree)
│   ├── Fedora 41+ Kinoite
│   ├── KDE Plasma
│   ├── Systemd
│   └── Base utilities
│
├── Layered Packages (rpm-ostree install)
│   ├── Essential CLI tools
│   │   ├── vim, git, tmux, htop
│   │   └── ansible, rclone
│   ├── System integrations
│   │   ├── keepassxc (secrets)
│   │   └── xorg-x11-server-Xorg
│   └── Minimal! (avoid instability)
│
├── Flatpak Applications
│   ├── Browsers (Firefox)
│   ├── Office (LibreOffice)
│   └── Media (VLC, GIMP)
│
├── Toolbox Containers (Development)
│   ├── dev-general (Fedora 41)
│   │   ├── Python 3.13, pip, poetry
│   │   ├── Go 1.23
│   │   └── Node.js 20 LTS
│   ├── sre-tools (Fedora 41)
│   │   ├── Terraform, Terragrunt
│   │   ├── kubectl, helm
│   │   └── Ansible (latest)
│   └── python-ml (Arch via distrobox)
│       ├── Python 3.13
│       ├── PyTorch, TensorFlow
│       └── Jupyter
│
├── Docker/Podman Services
│   ├── Databases (PostgreSQL, MongoDB)
│   ├── Message queues (Redis, RabbitMQ)
│   └── Dev services (LocalStack, MinIO)
│
└── User Configuration
    ├── Chezmoi dotfiles
    ├── KDE Plasma settings
    └── Systemd user services
```

### Layer 3: Cross-Platform Integration

#### Secrets Management (KeePassXC)

```
KeePassXC Database
├── Location: ~/.MyHome/Secrets/workspace.kdbx
├── Synced: Google Drive (encrypted)
├── Access:
│   ├── Windows: KeePassXC GUI
│   └── Kinoite: keepassxc-cli + systemd
│
└── Stored Secrets
    ├── RCLONE_CONFIG_PASS
    ├── Git credentials (SSH keys)
    ├── API tokens (GitHub, GitLab, AWS)
    └── Service passwords
```

**Integration Pattern**:
```bash
# Read secret from KeePassXC
keepassxc-cli show workspace.kdbx -a password "Entry/Title"

# Export to systemd environment
systemctl --user set-environment \
  RCLONE_CONFIG_PASS="$(keepassxc-cli show ...)"
```

#### Dotfiles Management (Chezmoi)

```
Chezmoi Repository
├── .chezmoi.yaml.tmpl (template config)
│
├── dot_bashrc.tmpl
│   └── {{ if eq .chezmoi.os "windows" }}
│       # Windows-specific bash config
│       {{ else if eq .chezmoi.os "linux" }}
│       # Linux-specific bash config
│       {{ end }}
│
├── dot_config/
│   ├── git/
│   │   └── config.tmpl (OS-specific paths)
│   ├── vim/
│   │   └── vimrc (shared)
│   └── plasma/ (Kinoite only)
│       └── KDE settings
│
└── scripts/
    ├── common.sh (shared utilities)
    ├── linux-only.sh
    └── windows-only.ps1
```

**Chezmoi detects context**:
- `{{ .chezmoi.os }}` - "windows" or "linux"
- `{{ .chezmoi.osRelease.id }}` - "fedora"
- `{{ .chezmoi.kernel.osrelease }}` - Detect WSL

---

## Data Flow & Integration Points

### Bootstrap Flow

```
┌─────────────────────────┐
│  1. Fresh Windows 10    │
│     Install             │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  2. Manual Setup        │
│  - Enable WSL2          │
│  - Install git          │
│  - Clone repo           │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  3. Run Bootstrap       │
│  .\windows\scripts\     │
│    bootstrap.ps1        │
└───────────┬─────────────┘
            │
            ├─────────────────────────┐
            ▼                         ▼
┌─────────────────────┐   ┌─────────────────────┐
│  4a. Windows Setup  │   │  4b. Kinoite Setup  │
│  - Choco/Winget     │   │  - Import to WSL2   │
│  - DSC configs      │   │  - Install KDE      │
│  - X410             │   │  - rpm-ostree       │
└─────────┬───────────┘   └──────────┬──────────┘
          │                          │
          └────────────┬─────────────┘
                       ▼
            ┌─────────────────────┐
            │  5. Integration     │
            │  - Chezmoi apply    │
            │  - KeePassXC setup  │
            │  - rclone sync      │
            └─────────┬───────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │  6. Validation      │
            │  - Test KDE launch  │
            │  - Test tools       │
            │  - Test sync        │
            └─────────────────────┘
```

### Daily Workflow

```
User turns on laptop
        │
        ▼
Windows boots
        │
        ├─→ (Optional) Launch native apps
        │   └─→ Firefox, Claude, Teams
        │
        ▼
User launches WSL2 KDE
        │
        ▼
Windows runs: wsl -d FedoraKinoite
        │
        ▼
X410 starts listening (port :0)
        │
        ▼
Kinoite starts KDE Plasma
        │
        └─→ DISPLAY=:0 startplasma-x11
        │
        ▼
KDE Plasma appears on Windows
        │
        ├─→ 3 monitors configured
        ├─→ User works in KDE all day
        │   ├─→ Konsole (terminals)
        │   ├─→ VSCodium (editor)
        │   ├─→ Firefox (browser)
        │   └─→ Toolbox containers
        │
        └─→ Background: rclone sync to GDrive
```

### Update Flow

```
Weekly Update Trigger
        │
        ├─→ Windows: Task Scheduler
        └─→ Kinoite: systemd timer
        │
        ▼
┌────────────────────────┐
│  Pull latest from git  │
│  (my-modular-workspace)│
└───────────┬────────────┘
            │
            ├──────────────────────────┐
            ▼                          ▼
┌──────────────────────┐   ┌──────────────────────┐
│  Windows Update      │   │  Kinoite Update      │
│  ansible-playbook    │   │  ansible-playbook    │
│  windows/update.yml  │   │  kinoite/update.yml  │
└──────────┬───────────┘   └───────────┬──────────┘
           │                           │
           │  ┌─────────────────────┐  │
           └─→│  rpm-ostree upgrade │←─┘
              │  (if available)     │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │  Reboot required?   │
              │  - Kinoite: Yes     │
              │  - Windows: Rare    │
              └─────────────────────┘
```

---

## Network Architecture

### Port Mapping

| Service | Port | Protocol | Used By |
|---------|------|----------|---------|
| **X410** | :0 (6000) | X11 | KDE Plasma display |
| **WSL2 localhost** | dynamic | TCP | File access, services |
| **SSH** | 22 (WSL) | TCP | Remote access to Kinoite |
| **RDP** | 3389 | TCP | Alternative (XRDP, not primary) |

### Localhost Forwarding

```ini
# .wslconfig enables localhost forwarding
[wsl2]
localhostForwarding=true

# This means:
# - Windows localhost:8080 → WSL2 localhost:8080
# - WSL2 can access Windows services
# - Windows can access WSL2 services
```

**Use Cases**:
- Access Podman containers from Windows browser
- Use Windows VPN for WSL2 traffic
- Share clipboard (via X410)

---

## Security Architecture

### Threat Model

| Asset | Threat | Mitigation |
|-------|--------|------------|
| **KeePassXC Database** | Unauthorized access | Master password, encrypted sync |
| **Git Credentials** | Theft | Stored in KeePassXC, SSH keys with passphrase |
| **rclone Config** | Exposure | Encrypted with RCLONE_CONFIG_PASS from KeePassXC |
| **Work VPN** | Misconfiguration | Installed manually, not automated |
| **Secrets in Git** | Accidental commit | Ansible Vault not used (KeePassXC only), .gitignore |

### Security Principles

1. **No secrets in git** - Ever. All secrets in KeePassXC.
2. **KeePassXC master password** - Only human-memorized secret.
3. **SSH keys** - Passphrase-protected, stored in KeePassXC.
4. **Work separation** - Corporate tools not automated/managed by our system.
5. **Encrypted sync** - KeePassXC db synced encrypted to Google Drive.

---

## Disaster Recovery

### Recovery Time Objective (RTO)

**Target**: 4-8 hours from bare metal to working system

### Recovery Procedure

```
Laptop dies / needs rebuild
        │
        ▼
┌──────────────────────────┐
│  1. New Windows Install  │
│     (2 hours)            │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│  2. Manual Phase 1       │
│     - WSL2               │
│     - Git                │
│     - Clone repo         │
│     (30 minutes)         │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│  3. Run Bootstrap        │
│     (1-2 hours)          │
│     - Windows setup      │
│     - Kinoite import     │
│     - Automation         │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│  4. Restore Secrets      │
│     - Download KeePassXC │
│       db from GDrive     │
│     - Enter master pass  │
│     (15 minutes)         │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│  5. Sync Data            │
│     - rclone restore     │
│     - Pull git repos     │
│     (1-2 hours)          │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│  6. Manual Work Setup    │
│     - VPN, VMware, etc.  │
│     (1 hour)             │
└───────────┬──────────────┘
            │
            ▼
        ✅ RECOVERED
    Total: 6-8 hours
```

### Backup Strategy

| Data | Backup Method | Frequency | Retention |
|------|---------------|-----------|-----------|
| **Code repos** | Git + GitHub/GitLab | Continuous | Infinite |
| **Dotfiles** | Git (chezmoi) | On change | Infinite |
| **Documents** | rclone → Google Drive | Daily (automated) | Infinite |
| **KeePassXC DB** | Google Drive sync | On save | Infinite |
| **WSL2 Kinoite** | `wsl --export` backup | Weekly | 4 weeks |
| **Windows System** | System Image | Before major changes | 2 images |

---

## Multi-Machine Support

### Machine Profiles

```
my-modular-workspace/
├── machines/
│   ├── eyeonix-laptop/
│   │   ├── vars.yml
│   │   ├── windows-apps.yml
│   │   └── kinoite-layers.yml
│   │
│   ├── personal-desktop/  (future)
│   │   └── vars.yml
│   │
│   └── profiles/
│       ├── work.yml       (corporate constraints)
│       └── personal.yml   (no restrictions)
```

### Machine-Specific Variables

```yaml
# machines/eyeonix-laptop/vars.yml
hostname: eyeonix-laptop
machine_type: work_laptop
os_type: windows
wsl_distro: FedoraKinoite

# Display
monitors: 3
laptop_dpi: 96
external_dpi: 96

# Resources
wsl_memory: 12GB
wsl_processors: 6

# Profile
profile: work
install_work_software: false  # documented, not automated

# Sync
rclone_remote: GoogleDrive-dtsioumas0:MyHome/
sync_frequency: daily
```

### Platform Detection

```yaml
# Ansible playbook
- name: Set platform facts
  ansible.builtin.set_fact:
    is_windows: "{{ ansible_os_family == 'Windows' }}"
    is_wsl: "{{ ansible_kernel is search('microsoft') }}"
    is_kinoite: "{{ ansible_distribution == 'Fedora' and ansible_pkg_mgr == 'atomic_container' }}"

- name: Windows-specific tasks
  when: is_windows
  block:
    - name: Install chocolatey packages
      win_chocolatey:
        name: "{{ windows_packages }}"

- name: Kinoite-specific tasks
  when: is_kinoite
  block:
    - name: Layer rpm-ostree packages
      ansible.posix.rpm_ostree_pkg:
        name: "{{ kinoite_layers }}"
```

---

## Technology Stack Summary

### Windows Side

| Category | Technology | Purpose |
|----------|------------|---------|
| **OS** | Windows 10 Pro | Host system |
| **Package Mgmt** | Winget, Chocolatey | Application installation |
| **Configuration** | DSC (via Ansible) | System settings |
| **Automation** | Ansible, PowerShell | Orchestration |
| **Graphics** | X410 | X server for KDE |
| **Terminal** | Windows Terminal | Launcher |

### Kinoite Side

| Category | Technology | Purpose |
|----------|------------|---------|
| **OS** | Fedora Kinoite 41+ | Immutable base |
| **Desktop** | KDE Plasma 6+ | Full desktop environment |
| **Package Mgmt** | rpm-ostree, flatpak, toolbox | Layered approach |
| **Configuration** | Ansible, Chezmoi | Automation, dotfiles |
| **Containers** | Podman, toolbox, distrobox | Development isolation |
| **Secrets** | KeePassXC | Password management |
| **Sync** | rclone | Google Drive backup |

### Cross-Platform

| Category | Technology | Purpose |
|----------|------------|---------|
| **Version Control** | Git | Source of truth |
| **Dotfiles** | Chezmoi | Cross-platform config |
| **Secrets** | KeePassXC | Single source of truth |
| **Orchestration** | Ansible | Both Windows & Linux |
| **Backup** | rclone + Google Drive | Data protection |

---

## Design Principles

### 1. Declarative Everything

**Principle**: If it's not in git, it doesn't exist.

- System packages → Ansible playbooks
- Dotfiles → Chezmoi templates
- KDE settings → Ansible tasks + git-tracked configs
- Even this documentation → Markdown in git

**Exception**: Secrets (in KeePassXC, not git)

### 2. Immutability Where Possible

**Principle**: Prefer immutable, atomic systems.

- Kinoite: Immutable OSTree base
- rpm-ostree: Atomic updates, easy rollback
- Containers: Ephemeral, reproducible

**Exception**: Windows (traditional mutable OS)

### 3. Minimal Host, Rich Guest

**Principle**: Keep Windows minimal, do real work in WSL2.

- Windows: Just enough to boot and run X410
- Kinoite: Full development environment
- Work isolation: Corporate tools on Windows, personal on Kinoite

### 4. Separation of Concerns

**Principle**: Each tool does one thing well.

| Concern | Tool |
|---------|------|
| System packages | rpm-ostree |
| System config | Ansible |
| User dotfiles | Chezmoi |
| Secrets | KeePassXC |
| Dev tools | Toolbox/distrobox |
| GUI apps | Flatpak |

### 5. Test Before Deploy

**Principle**: Never touch production without VM validation.

- Test all automation in Hyper-V VM
- Validate on test machine first
- Incremental rollout with rollback plans

---

## Success Criteria

### Technical Success

- ✅ Can rebuild from bare metal in <8 hours
- ✅ KDE Plasma performs acceptably (subjective but measured)
- ✅ All development workflows functional
- ✅ Multi-monitor configuration works (even if manual)
- ✅ Updates automated (weekly or on-demand)
- ✅ Rollback possible within 30 minutes

### Operational Success

- ✅ Daily work uninterrupted
- ✅ No data loss during migration
- ✅ Work software continues to function
- ✅ Performance meets or exceeds current setup
- ✅ Maintenance effort acceptable (<2 hours/month)

### Personal Success

- ✅ Workspace feels "right" and productive
- ✅ Reduces context-switching friction
- ✅ Knowledge documented for future use
- ✅ Learnings applicable to other projects

---

## Open Questions

1. **Fedora Kinoite specific**: What's the best way to create initial WSL2 rootfs?
2. **KDE multi-monitor**: Can we script profile switching on plug/unplug?
3. **Performance**: Will X410 + 3 monitors + KDE perform well enough?
4. **rpm-ostree**: How many packages can we layer before instability?
5. **Windows updates**: How to handle major Windows updates (feature updates)?

---

## Next Steps

1. ✅ Requirements gathering (complete)
2. ✅ Technical research (complete)
3. ✅ Architecture design (this document)
4. ⬜ Create detailed implementation guides
5. ⬜ Build proof-of-concept in test VM
6. ⬜ Develop automation scripts
7. ⬜ Execute migration (weekend)
8. ⬜ Iterate and optimize

---

**Document Version**: 1.0
**Last Updated**: 2025-12-17
**Author**: Technical Researcher (based on 8 clarification rounds)
**Next Review**: After PoC completion
