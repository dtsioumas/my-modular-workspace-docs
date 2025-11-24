# my-kinoite-bluebuild — Repository Skeleton (Draft 1)

This document provides the updated blueprint for your **my-kinoite-bluebuild** repository, aligned with your renamed project **my-modular-workspace**. It reflects the naming corrections (using *my* instead of *mi*) and clarifies the structure and responsibilities of the BlueBuild image repository.

---

## 1. Repository Name & Purpose

**Repository name:**
- `my-kinoite-bluebuild`

**Project:**
- Part of **my-modular-workspace**.

**Purpose:**
- Build a reproducible **custom Fedora Atomic (Kinoite)** image using **BlueBuild/Universal Blue**.
- Provide a stable host‑level foundation for your ephemeral, declarative personal workspace.
- Deliver virtualization‑ready, container‑ready, development‑ready defaults before Ansible/Home Manager run.

---

## 2. Directory Structure

```text
my-kinoite-bluebuild/
├── .github/
│   └── workflows/
│       └── build.yml                # GitHub Actions workflow
├── recipes/
│   └── kinoite.yaml                 # Main BlueBuild recipe
├── bluebuild.yml                    # (Optional) global config for BlueBuild
├── containerfiles/                  # (Optional) generated or custom containerfiles
├── scripts/                         # Helper/test scripts
├── docs/
│   └── README.md                    # Image-specific documentation
└── README.md                        # Main documentation
```

This structure keeps the repo clean, minimal, and maintainable.

---

## 3. `README.md` Skeleton

```markdown
# my-kinoite-bluebuild

Custom Kinoite-based Fedora Atomic image for the **my-modular-workspace** project.

## Base Image

- Base: `ghcr.io/ublue-os/kinoite-nvidia:latest`

## Features

- Preinstalled system tools:
  - podman, toolbox, distrobox
  - virtualization stack (libvirt, virt-install, virt-manager)
  - git, curl, jq, htop, tmux, etc.
- Built fully declaratively via BlueBuild.

## How to Rebase

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/<your-gh-username>/my-kinoite:latest
reboot
```

## Updating

1. Modify `recipes/kinoite.yaml`.
2. Push changes.
3. GitHub Actions builds the new image.
4. Update your system:

```bash
rpm-ostree upgrade
reboot
```
```

---

## 4. `recipes/kinoite.yaml` Skeleton

```yaml
name: my-kinoite

base-image: ghcr.io/ublue-os/kinoite-nvidia:latest

labels:
  org.opencontainers.image.title: "my-kinoite"
  org.opencontainers.image.description: "My custom Fedora Kinoite image for my-modular-workspace"

modules:
  - type: rpm-ostree
    repos:
      # Add third-party repos here if needed
    install:
      - podman
      - toolbox
      - curl
      - git
      - jq
      - htop
      - libvirt
      - virt-install
      - virt-manager
      # Additional host-level tools

  # Optional modules:
  # - type: flatpak
  #   remotes:
  #     - name: flathub
  #       url: https://dl.flathub.org/repo/flathub.flatpakrepo
  #   install:
  #     - com.mitchellh.ghostty
  #     - org.mozilla.firefox

  # - type: files
  #   files:
  #     - source: files/etc/profile.d/10-my-env.sh
  #       destination: /etc/profile.d/10-my-env.sh

  # - type: run
  #   commands:
  #     - echo "Building my-kinoite customizations"
```

This recipe remains focused on **host-level tools** only.

---

## 5. GitHub Actions Workflow Skeleton

```yaml
name: Build my-kinoite image

on:
  push:
    branches: [ main ]
  workflow_dispatch: {}

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up QEMU (optional)
        uses: docker/setup-qemu-action@v3

      - name: Build with BlueBuild
        uses: blue-build/github-action@vX
        with:
          recipe: recipes/kinoite.yaml
```

Use the BlueBuild documentation for final action arguments.

---

## 6. What Goes Where

### In **my-kinoite-bluebuild** (BlueBuild image)
- Host-level CLI tools
- Virtualization stack
- NVIDIA support (via UBlue base)
- System defaults needed *before* user login

### In **my-modular-workspace/ansible**
- Bootstrap tasks (Nix, Home Manager, Syncthing, Flatpaks)
- Machine-specific post-image configuration

### In **Home Manager**
- User CLI tools
- Dev environments
- User services

### In **chezmoi + Stow**
- Dotfiles
- Plasma configs
- Home directory layout
- Syncthing/SharedHome symlinks

---

## 7. Notes

- Keep the image minimal. Use Ansible & Home Manager for most layers.
- BlueBuild = reproducible base; Home Manager = reproducible user env; chezmoi+Stow = reproducible home layout.

This blueprint will evolve as you test in VM and finalize your Base/Bootstrap layers.

