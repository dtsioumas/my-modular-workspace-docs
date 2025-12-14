# mi‑modular‑workspace: Fedora Atomic + Nix/Home Manager Stack

*Version: draft-1 (to be iterated as we test on VMs)*

This document describes the **finalised stack architecture** for migrating from NixOS to a Fedora Atomic / UBlue based workflow, while keeping Nix/Home Manager for the user environment and using Ansible, chezmoi, and GNU Stow for automation and dotfiles.

The goals are:

- Strong reproducibility and modularity.
- Low manual intervention during bootstrap and rebuilds.
- Good support for virtualization, containers, and Kubernetes work.
- Easy portability of the home environment across desktop, laptop, WSL, and cloud workspaces.

---

## 1. High‑Level Architecture

We model the system in **layers**, each with a clear responsibility and toolset.

- **Layer 0 – Base OS / Image**  
  - Fedora Atomic (Kinoite KDE) or UBlue image.  
  - Custom image built with **BlueBuild** on top of Universal Blue.  
  - Provides: kernel, drivers (including NVIDIA), core system tools, rpm-ostree/dnf stack.

- **Layer 1 – System Configuration & Bootstrap**  
  - **Ansible** for machine bootstrap and idempotent system tasks.  
  - Sets up Nix + Home Manager, installs base Flatpaks, configures Syncthing, etc.

- **Layer 2 – User Environment (CLI & dev tools)**  
  - **Nix + Home Manager** to manage user packages and some configs declaratively.

- **Layer 3 – Home / Dotfiles / Layout**  
  - **chezmoi** to manage dotfiles and templates across machines.  
  - **GNU Stow** to manage symlinks for directories (e.g. SharedHome, Pictures, Documents) and some configs.  
  - Synced home data via Google Drive + Syncthing.

Each layer is versioned in Git and can be rebuilt independently.

---

## 2. Components & Responsibilities

### 2.1 Base OS / Image: Fedora Atomic, UBlue, BlueBuild

**Key technologies:**

- **Fedora Silverblue/Kinoite (Atomic desktops)** – rpm‑ostree based immutable desktop variants.
  - Docs: https://docs.fedoraproject.org/en-US/fedora-silverblue/  citeturn0search33
  - Getting started, installing packages via rpm‑ostree: https://docs.fedoraproject.org/en-US/fedora-silverblue/getting-started/  citeturn0search2

- **rpm‑ostree** – hybrid image/package system used by Fedora Atomic:
  - Docs: https://docs.fedoraproject.org/en-US/fedora/f40/system-administrators-guide/package-management/rpm-ostree/  citeturn0search17
  - Technical background and layering behavior for Silverblue/Kinoite: https://docs.fedoraproject.org/en-US/fedora-silverblue/technical-information/  citeturn0search10

- **Universal Blue (UBlue)** – community images built on Fedora Atomic desktops.  
  - Project: https://universal-blue.org/  citeturn0search9
  - Fedora discussion thread: https://discussion.fedoraproject.org/t/universal-blue/81023  citeturn0search13

- **BlueBuild** – toolkit for building custom OCI/Atomic images on top of Fedora/UBlue.
  - Building on Universal Blue: https://blue-build.org/learn/universal-blue/  citeturn0search23  
  - rpm‑ostree module reference: https://blue-build.org/reference/modules/rpm-ostree/  citeturn0search0  
  - dnf module (newer bootc style): https://blue-build.org/blog/dnf-module/  citeturn0search22  
  - Example template image repo: https://github.com/AdamFrey/fedora-atomic-awesome  citeturn0search12

**Responsibilities of this layer:**

- Provides a **stable, immutable base** with:  
  - Kernel & hardware drivers (including NVIDIA via UBlue variants).  
  - Core CLI tools required on every machine (e.g. podman, toolbox, basic network tools).  
  - Virtualization support (KVM/libvirt packages if desired in the image).  
- Encodes default system state in `recipe.yml` (or equivalent) managed by BlueBuild.
- Built and tested via CI (GitHub Actions) and consumed via `rpm-ostree rebase`.

**Why this choice:**

- Gives NixOS‑like atomic upgrades & rollbacks, but on top of Fedora’s hardware support and ecosystem.  
- Universal Blue images are widely used and documented, and BlueBuild helps you create **reproducible images** without hand‑crafted ostree composes.

---

### 2.2 System Configuration & Bootstrap: Ansible

**Key references:**

- General Ansible docs: https://docs.ansible.com/  
- Example of using Ansible to configure Silverblue/Kinoite systems and keep them declarative: blog & scripts referenced in Fedora community posts, e.g.:  
  - Fedora Magazine customisation article: https://fedoramagazine.org/how-i-customize-fedora-silverblue-and-fedora-kinoite/ citeturn0search14  
  - Silverblue/Kinoite post‑install script repo linked from Fedora Reddit: https://github.com/iaacornus/silverblue-postinstall_upgrade  citeturn0search24

**Responsibilities:**

- Run on **fresh installs** to move a machine from “base image” to “ready for user login / Nix / dotfiles”.
- Tasks typically include:
  - Installing core tools not baked into the image (or calling `rpm-ostree install` where appropriate).
  - Installing **Flatpaks** (GUI apps) from Flathub.  
  - Setting up **Toolbx**/Distrobox containers if needed for dev work:  
    - Toolbox docs: https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/ citeturn0search6
  - Installing and configuring **Nix** and **Home Manager** for the main user.
  - Installing and configuring **Syncthing** for SharedHome sync (optional, but part of your design).
  - Installing **chezmoi** and **GNU Stow**, and running initial apply.

**Why Ansible, not something else:**

- Widely used configuration management tool, good docs, and integrates well with SSH/CI.  
- Easy to express idempotent tasks so that **re‑running** the playbook converges the machine into the desired state.  
- Can integrate with external secret backends (including KeePassXC) via lookup plugins:  
  - Example: `viczem/ansible-keepass` collection: https://github.com/viczem/ansible-keepass citeturn1search1  
  - Another KeePass lookup plugin example: https://github.com/xronos-i-am/ansible-keepass-lookup citeturn1search8  
  - Notes on KeePassXC with Ansible: https://jpmens.net/2023/01/22/notes-to-self-keepassxc/ citeturn1search9

**Design rule:**

> Any change that must be reproducible across machines should be encoded in an Ansible role (or the image recipe), not done by hand.

Ansible is the **glue** and the initial bootstrapper, not the main source of truth for the user environment (that’s Nix + chezmoi).

---

### 2.3 User Environment: Nix + Home Manager

**Key references:**

- Home Manager manual: https://home-manager.dev/manual/25.05/ citeturn0search25  
- Home Manager repo: https://github.com/nix-community/home-manager citeturn0search7  
- Home Manager overview on NixOS Wiki: https://nixos.wiki/wiki/Home_Manager citeturn0search20

**Responsibilities:**

- Manage **user‑space packages** and configurations declaratively via Nix, including:
  - CLI tools (ripgrep, fzf, git, kubectl, k9s, etc.).
  - Language toolchains (Go, Python, NodeJS) as needed for dev work, if you choose to use Nix for them.
  - Program configs where Home Manager has modules (e.g. `programs.git`, `programs.zsh`, etc.).
- Provide an idempotent command to fully configure the user environment on any machine:

  ```bash
  home-manager switch --flake /path/to/your/home#mitso@hostname
  ```

- Source of truth for **what tools you expect to exist in your shell** across all machines.

**Why keep Nix/Home Manager even on Fedora:**

- You get NixOS‑style reproducibility for your **user environment** without committing again to NixOS as the base OS.  
- You can share the same Home Manager config across Atomic Fedora, classic Fedora, and even other Linux distros.  
- Nixpkgs versions are usually as fresh as Fedora or fresher for many CLI tools.

**Boundary:**

- Home Manager does **not** manage Fedora system packages or Flatpaks directly; that remains the job of rpm‑ostree/dnf and Ansible. citeturn0search17turn0search2

---

### 2.4 Dotfiles & Home Layout: chezmoi + GNU Stow + SharedHome

#### chezmoi

**Key references:**

- Official docs: https://chezmoi.io/ citeturn0search16  
- GitHub repo: https://github.com/twpayne/chezmoi citeturn0search21  
- Example usage article: https://natelandau.com/managing-dotfiles-with-chezmoi/ citeturn0search26  
- Another article: https://ettoreciarcia.com/publication/21-chezmoi/ citeturn0search31  

**Responsibilities:**

- Act as the **primary manager for dotfiles** in `$HOME`:
  - `~/.config/kitty/`, `~/.config/plasma*`, `~/.gitconfig`, etc.
  - Uses templates to adapt per‑machine or per‑host settings.
  - Stores secrets securely using supported secret backends (GPG, age, or external tools) when needed.
- Provide an easy workflow:

  ```bash
  chezmoi init git@github.com:mitso/dotfiles.git
  chezmoi apply
  ```

- Optionally, define `run_` or `run_onchange_` scripts in chezmoi to perform small per‑user operations (e.g., set some dconf keys, call Flatpak install for a user app, etc.). citeturn0search16turn0search31

#### GNU Stow

**Key references:**

- GNU Stow manual: https://www.gnu.org/software/stow/manual/stow.html  

**Responsibilities:**

- Lightweight, deterministic **symlink manager** on top of your dotfiles and SharedHome directory structure.  
- Used specifically for:
  - Symlinking `~/Pictures`, `~/Documents`, `~/Workspace` to your Syncthing/Google Drive backed **SharedHome** path.  
  - Symlinking some static config trees (e.g., whole directories under `.config` if that’s more convenient than chezmoi templates).

#### SharedHome (Google Drive + Syncthing)

**Responsibilities:**

- Provide a single logical home directory tree (or subset) to be shared across machines, including:
  - personal documents, notes, maybe some config that doesn’t need per‑host divergence.
- Syncthing handles local sync; Google Drive acts as the cloud backup.
- Stow + chezmoi then make sure the right paths in `$HOME` point into the SharedHome tree.

**Why both chezmoi and Stow:**

- chezmoi is *config-aware*: templating, secrets, machine‑specific logic.  
- Stow is *filesystem‑layout‑aware*: create predictable symlink structures for directories, especially large ones.  
- Using both lets you keep configuration logic in chezmoi while using Stow as a blunt, reliable tool for connecting your shared data tree.

---

### 2.5 Virtualization, Containers & Workloads

**Tools used:**

- **podman** and **toolbox** (container-based dev environments):
  - Toolbox on Atomic: https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/ citeturn0search6
- **Kubernetes tooling** (kubectl, k9s, etc.) installed via Nix (Home Manager) or image.
- **BlueBuild** ensures the base image already contains:
  - podman, toolbox, CRI tools you always want installed. citeturn0search0turn0search22turn0search23

**Responsibilities of this part of the stack:**

- Provide a stable container host (Atomic Fedora image) to run:
  - local dev containers,
  - cluster control-plane tooling,
  - and other workloads (Minikube/k3d/kind, or remote cluster administration).

- Allow you to treat the **desktop as a cloud-native node**:
  - The OS image is declarative (BlueBuild).  
  - User tools are declarative (Home Manager) or containerized.  
  - Dotfiles and project configs are synced and templated (chezmoi + SharedHome).

---

## 3. Why This Stack (Summary of Trade‑offs)

### Pros

- **Reproducible base OS** via BlueBuild + rpm‑ostree images.  
- **Reproducible user environment** via Nix + Home Manager, independent of the base OS.  
- **Portable dotfiles** across desktop, laptop, WSL, and cloud via chezmoi + Stow.  
- **Single source of truth** in Git for:
  - Image recipes,
  - Ansible roles,
  - Home Manager configs,
  - chezmoi dotfiles.
- **Hardware & virtualization friendliness** thanks to Fedora’s rapid kernel/driver updates and UBlue tuning for Atomic desktops. citeturn0search29turn0search34

### Cons / Caveats

- Multiple tools mean more moving parts; you must keep boundaries clear.
- Home Manager still depends on Nixpkgs versions, which may differ from Fedora’s packages; you must choose consciously where a tool is installed (Nix vs rpm‑ostree vs Flatpak).
- BlueBuild and UBlue are community projects (though active); they are not official Fedora products, so you rely on community health. citeturn0search9turn0search13
- Documentation is spread across:
  - Fedora docs,
  - BlueBuild docs,
  - Nix/Home Manager docs,
  - chezmoi docs.

Given your background and goals (SRE/Platform focus, love of modularity, need for reproducibility but not wanting to fight NixOS for hardware), this stack is a balanced compromise.

---

## 4. Rebuild & Migration Workflows (Overview)

### 4.1 New machine / Reinstall workflow (target state)

1. Install Fedora Kinoite (or rebase to your UBlue image).  
2. Rebase to your **custom BlueBuild image**:  
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/<you>/<image>:latest
   ```
3. Run Ansible bootstrap playbook (from `mi-modular-workspace/ansible/`):  
   - Installs Nix and Home Manager.  
   - Installs chezmoi + Stow.  
   - Installs Syncthing & configures SharedHome.  
   - (Optionally) installs baseline flatpaks and toolbox containers.
4. Run Home Manager:  
   ```bash
   home-manager switch --flake /path/to/home#mitso@hostname
   ```
5. Initialize chezmoi and apply dotfiles:  
   ```bash
   chezmoi init git@github.com:<you>/dotfiles.git
   chezmoi apply
   ```
6. Run Stow to connect Pictures/Documents/etc. to SharedHome.

Result: machine is fully configured with minimal manual steps.

### 4.2 Migration from current NixOS

- Phase 1: **Design & implement this stack in a VM** inside NixOS.  
  - Install Fedora Kinoite in VM.  
  - Implement the full bootstrap pipeline.  
  - Iterate until your dev tools, Plasma config, and dotfiles behave as expected.
- Phase 2: **Migrate your real workstation**.  
  - Backup and snapshot.  
  - Install/rebase to Atomic Fedora with your image.  
  - Run the exact same Ansible + Nix + chezmoi procedure.

---

## 5. Open Questions / Future Extensions

- How much of Plasma’s KDE configuration will be managed via Home Manager vs chezmoi vs Stow?  
  (There are tools like `dconf2nix` that can help; see Home Manager options docs. citeturn0search15)
- Exactly which tools go into the BlueBuild image vs Nix vs Flatpak – needs iterative refinement.  
- Secrets: final decision on KeePassXC + Ansible lookups + (optionally) chezmoi secret backends.

This document should be updated as you:

- Implement the first `bluebuild` repo.
- Create the initial Ansible roles and playbooks.
- Add the first Home Manager config and chezmoi repo.

Once those exist, we can add concrete paths, flake names, and command examples.

