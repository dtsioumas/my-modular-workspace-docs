# Ansible Bootstrap Repository Skeleton (Draft 1)

This document defines the initial skeleton for the **Ansible bootstrap repository** that will be used by the **my-modular-workspace** project to configure fresh Fedora Atomic / my-kinoite-bluebuild systems.

The goal of this repo is to:
- Take a freshly installed / rebased **my-kinoite-bluebuild** system.
- Run a single Ansible entrypoint.
- Bring the machine to a state where:
  - Nix + Home Manager are installed and configured.
  - chezmoi and GNU Stow are installed and initialised.
  - Syncthing and SharedHome are configured.
  - Core Flatpaks and tooling are present.

We keep this repository **narrowly focused on bootstrap and system-level tasks**, not on user-level dotfiles (managed by chezmoi) or user dev tooling (managed by Home Manager).

---

## 1. Repository Name & Purpose

**Suggested repository name:**
- `my-ansible-bootstrap`

**Part of project:**
- **my-modular-workspace**

**Purpose:**
- Provide automated, idempotent bootstrapping of:
  - Fedora Atomic / my-kinoite-bluebuild workstations.
  - Potentially cloud VMs or other Fedora hosts in the future.

---

## 2. Directory Structure

```text
my-ansible-bootstrap/
├── inventories/
│   ├── hosts_desktop            # inventory for main workstation
│   ├── hosts_laptop             # inventory for laptop
│   └── hosts_vm_lab             # inventory for lab VMs
├── group_vars/
│   ├── all.yml                  # global variables
│   ├── desktop.yml              # desktop-specific vars
│   └── laptop.yml               # laptop-specific vars
├── roles/
│   ├── system_base/
│   │   ├── tasks/main.yml
│   │   ├── vars/main.yml
│   │   ├── defaults/main.yml
│   │   └── README.md
│   ├── nix_home_manager/
│   │   ├── tasks/main.yml
│   │   └── README.md
│   ├── flatpaks/
│   │   ├── tasks/main.yml
│   │   └── README.md
│   ├── syncthing_sharedhome/
│   │   ├── tasks/main.yml
│   │   └── README.md
│   ├── chezmoi_stow/
│   │   ├── tasks/main.yml
│   │   └── README.md
│   └── toolbox_containers/
│       ├── tasks/main.yml
│       └── README.md
├── playbooks/
│   ├── bootstrap.yml            # main entrypoint
│   └── check.yml                # dry-run / validation playbook
├── files/                       # static files if needed (service units, configs)
├── templates/                   # Ansible Jinja2 templates if used
├── ansible.cfg                  # Ansible configuration for this repo
└── README.md
```

This structure emphasises **roles** and **group vars**, so the same playbooks operate on multiple host types.

---

## 3. `README.md` Skeleton

```markdown
# my-ansible-bootstrap

Ansible bootstrap repository for **my-modular-workspace**.

This repo configures a freshly installed or rebased **my-kinoite-bluebuild** workstation into a ready-to-use environment, before Home Manager and chezmoi take over the user layer.

## Requirements

- Ansible installed on the control machine.
- SSH access to the target host (or local connection on the host itself).
- Fedora Atomic / Kinoite system, preferably already rebased to `my-kinoite`.

## Official Ansible Documentation

- Ansible User Guide: https://docs.ansible.com/ansible/latest/user_guide/index.html
- Ansible Best Practices (Directory Layout): https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html
- Ansible Inventory docs: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

## Running the Bootstrap

### For the main desktop

```bash
ansible-playbook -i inventories/hosts_desktop playbooks/bootstrap.yml --limit desktop
```

### For laptop

```bash
ansible-playbook -i inventories/hosts_laptop playbooks/bootstrap.yml --limit laptop
```

### Dry-run / check

```bash
ansible-playbook -i inventories/hosts_desktop playbooks/check.yml --check
```

## What This Repo Configures

- System-level packages and tools not baked into the image.
- Nix + Home Manager installation and initial configuration.
- Flatpak remotes and base applications.
- Syncthing + SharedHome layout.
- chezmoi + GNU Stow installation and initial apply.

User dotfiles and dev tools are managed *outside* this repo.
```

---

## 4. `playbooks/bootstrap.yml` Skeleton

```yaml
---
- name: Bootstrap my Fedora Atomic workstation
  hosts: all
  become: true

  roles:
    - role: system_base
    - role: flatpaks
    - role: nix_home_manager
    - role: syncthing_sharedhome
    - role: chezmoi_stow
    - role: toolbox_containers
```

This is intentionally simple: all logic is encapsulated in roles.

---

## 5. Example Role Responsibilities

### 5.1 Role: `system_base`

**Responsibilities:**
- Ensure DNF/ostree utilities, basic CLI tools, and required system packages are present (if not already in the image).
- Configure repositories if needed.

**References:**
- Fedora package management (dnf): https://docs.fedoraproject.org/en-US/quick-docs/dnf/
- rpm-ostree basics: https://docs.fedoraproject.org/en-US/fedora/f40/system-administrators-guide/package-management/rpm-ostree/

**Skeleton:**

```yaml
# roles/system_base/tasks/main.yml
---
- name: Ensure basic packages are present (if using dnf on non-Atomic)
  ansible.builtin.package:
    name:
      - curl
      - git
      - jq
      - htop
    state: present
  when: ansible_facts['os_family'] == 'RedHat' and not atomic_host | default(false)

# For Atomic hosts, you might prefer rpm-ostree layer commands via command/module
```

### 5.2 Role: `nix_home_manager`

**Responsibilities:**
- Install Nix on Fedora Atomic.
- Enable multi-user or single-user Nix as needed.
- Install Home Manager.
- Optionally run an initial `home-manager switch`.

**References:**
- Nix installation: https://nixos.org/manual/nix/stable/installation/installing-binary.html
- Home Manager manual: https://home-manager.dev/manual/latest/

**Skeleton:**

```yaml
# roles/nix_home_manager/tasks/main.yml
---
- name: Download and run Nix installer
  ansible.builtin.shell: |
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
  args:
    creates: /nix/store

- name: Ensure home-manager is installed (user-level step may be documented, not fully automated here)
  # This may be a shell or become: false step in a separate play targeting the user.
  debug:
    msg: "TODO: implement home-manager installation for user"
```

### 5.3 Role: `flatpaks`

**Responsibilities:**
- Configure Flathub remote.
- Install a base set of Flatpak apps (Firefox, terminal, etc.).

**References:**
- Flatpak on Fedora: https://docs.fedoraproject.org/en-US/flatpak/

**Skeleton:**

```yaml
# roles/flatpaks/tasks/main.yml
---
- name: Ensure Flathub remote is added
  ansible.builtin.command: >-
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

- name: Install base flatpaks
  ansible.builtin.command: >-
    flatpak install -y flathub {{ item }}
  loop:
    - org.mozilla.firefox
    - com.github.tchx84.Flatseal
  changed_when: true
```

### 5.4 Role: `syncthing_sharedhome`

**Responsibilities:**
- Install Syncthing.
- Configure the systemd user service.
- Place base configuration files (possibly templated).

**References:**
- Syncthing docs: https://docs.syncthing.net/

### 5.5 Role: `chezmoi_stow`

**Responsibilities:**
- Install chezmoi and GNU Stow.
- Clone your dotfiles repository.
- Run `chezmoi init` + `chezmoi apply`.
- Run `stow` for the configured packages.

**References:**
- chezmoi docs: https://chezmoi.io/
- GNU Stow manual: https://www.gnu.org/software/stow/manual/stow.html

**Skeleton:**

```yaml
# roles/chezmoi_stow/tasks/main.yml
---
- name: Install chezmoi
  ansible.builtin.command: >-
    sh -c "curl -fsLS get.chezmoi.io | sh"
  args:
    creates: /usr/local/bin/chezmoi

- name: Install GNU Stow
  ansible.builtin.package:
    name: stow
    state: present

- name: Clone dotfiles repo (if not present)
  ansible.builtin.git:
    repo: "git@github.com:<your-user>/<your-dotfiles-repo>.git"
    dest: "/home/{{ ansible_user }}/.local/share/chezmoi"
    version: main
    update: yes
  become: false

- name: Apply chezmoi configuration
  ansible.builtin.command: chezmoi apply
  args:
    chdir: "/home/{{ ansible_user }}"
  become: false
```

---

## 6. Ansible Configuration (`ansible.cfg`)

A minimal `ansible.cfg` in the repo root:

```ini
[defaults]
inventory = inventories/hosts_desktop
roles_path = roles
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
interpreter_python = auto_silent
```

You can override inventory on the CLI as needed.

---

## 7. Usage Pattern in my-modular-workspace

1. Install Fedora Atomic / my-kinoite and rebase to `my-kinoite` image.
2. Clone `my-ansible-bootstrap` onto the machine (or use `ansible-pull`).
3. Run:

   ```bash
   ansible-playbook -i inventories/hosts_desktop playbooks/bootstrap.yml --limit desktop
   ```

4. After bootstrap completes, run:
   - `home-manager switch` (if not fully driven by the role).
   - Any additional manual test commands.

This repo is intentionally small and focused; most complexity should remain in BlueBuild (image), Home Manager (user env), and chezmoi (dotfiles).

