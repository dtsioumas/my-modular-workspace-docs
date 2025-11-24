# Ephemerality Strategy for mi-modular-workspace

## Purpose
Define a robust, reproducible, and low-friction workflow that ensures your entire workstation environment—including the base OS, system configuration, user tooling, and home layout—can be rebuilt from scratch at any time with minimal manual effort.

This strategy is designed to:
- Minimize configuration drift.
- Enable regular rebuilds (monthly or faster).
- Keep anxiety and cognitive load low by making the system disposable and fully regenerable.
- Ensure disaster recovery readiness.
- Support experimentation without long-term risk.

---

# 1. Ephemerality Principles

### 1. Treat Machines as Cattle, Not Pets
All state is encoded in Git or shared data stores. No configuration should live only on a device.

### 2. Never Rely on Manual Changes
If a change cannot be reproduced via a script or config, it is considered invalid and must be migrated into the stack.

### 3. Prefer Declarative Over Imperative
Wherever possible, use tools that describe *what* the system should look like, not how to produce it.

### 4. Rebuild Regularly
A predictable rebuild cycle keeps the stack healthy and uncovers hidden drift early.

### 5. Atomic Base, Mutable Home
The base OS should be immutable and easily replaceable. The home layer should be reproducible but flexible.

---

# 2. Stack Components and Roles

## Layer 0 — Base OS Image
- Technology: Fedora Atomic (Kinoite) + custom BlueBuild image.
- Location of truth: `bluebuild/recipe.yml`.
- Responsibility: kernel, drivers, base CLI tools, podman, toolbox, virtualization support.

The base OS is **completely disposable** and replaced via `rpm-ostree rebase`.

## Layer 1 — System Bootstrap
- Technology: Ansible roles and playbooks.
- Location of truth: `ansible/` directory.
- Responsibility: post-install setup: enable services, install flatpaks, set up Nix, install chezmoi, init dotfiles.

Ansible is used only at bootstrap time, keeping the roles small and idempotent.

## Layer 2 — User Environment
- Technology: Home Manager (Nix).
- Location of truth: `home-manager/flake.nix`.
- Responsibility: user CLI tools, dev environments, user services.

Home Manager provides reproducibility for your development environment.

## Layer 3 — Dotfiles and Home Layout
- Technologies: chezmoi + GNU Stow.
- Locations of truth:
  - chezmoi repo: `chezmoi/`
  - stow packages: `stow/`
- Responsibility: dotfiles (configs), Plasma layout, symlinks for SharedHome directories.

chezmoi manages configuration files and templating; Stow handles directory and large-tree symlinking.

## Layer 4 — Shared Data & Sync
- Technology: Syncthing + Google Drive.
- Responsibility: user documents, notes, persistent non-config files.

The SharedHome directory is the only long-term data.

---

# 3. Ephemerality Levels

## Level 1 — Basic Ephemerality (Default)
The system can be rebuilt at any time:
1. Install Fedora Atomic.
2. Rebase to your BlueBuild image.
3. Run Ansible bootstrap.
4. Apply Home Manager.
5. Apply chezmoi.
6. Apply Stow.

Rebuild time: ~30–45 minutes.

## Level 2 — Monthly Rebuilds
Once per month:
- Reinstall/rebase.
- Rerun bootstrap.
- Validate reproducibility.

This verifies:
- Config stability.
- No secrets missing.
- No hidden manual drift.
- Role+image consistency.

## Level 3 — Continuous Ephemerality via VM Tests
Before touching the real machine:
- Spin VM on NixOS.
- Apply full bootstrap.
- Validate dev tools, Plasma config, Syncthing, dotfiles.

If the VM reaches a healthy state, the workstation is safe to rebuild.

## Level 4 — Complete Disposable Workstation
Your ultimate target:
- The machine can be fully recreated in under an hour.
- No step depends on memory or manual intervention.
- Everything is systematized in Git.

---

# 4. Rebuild Workflow

## Step 1 — Install/Rebase Base Image
- Install Fedora Kinoite or boot into live USB.
- Rebase to your BlueBuild custom image.

## Step 2 — Run Ansible Bootstrap
- Configure system services.
- Install flatpaks.
- Set up Syncthing.
- Install Nix + Home Manager.
- Install chezmoi + Stow.

## Step 3 — Apply User Environment
- `home-manager switch` to bring in dev environment.
- `chezmoi apply` to apply dotfiles.
- `stow` to set directory layout.

## Step 4 — Validate
- Plasma layout correct.
- Developer tools loaded.
- Syncthing connected.
- SharedHome symlinked.

---

# 5. Disaster Recovery

## Core Requirements
- Internet access.
- Access to GitHub repos.
- Access to Google Drive (SharedHome).
- Access to Syncthing identity.

## Full Recovery Steps
1. Install/rebase Atomic Fedora.
2. Run the Ansible playbook.
3. Run Home Manager.
4. Sync SharedHome.
5. Apply chezmoi + stow.

Everything else is optional.

---

# 6. Drift Detection

To ensure reproducibility:
- Never modify dotfiles directly in `$HOME`.
- Any manual change must be migrated into chezmoi or Stow.
- Any manual system change must be migrated into BlueBuild or Ansible.
- Regular VM rebuilds detect breakage early.

---

# 7. Verification & CI/CD

Implement automation to validate ephemerality:
- Lint Home Manager configs.
- Lint Ansible roles.
- Check chezmoi templates.
- Run container build via BlueBuild CI.
- Optional: automated VM provisioning for full integration tests.

---

# 8. Long-Term Goals

- Move more system packages into the BlueBuild image.
- Reduce Ansible role complexity.
- Increase Home Manager usage for CLI tooling.
- Improve sharing of Plasma configs.
- Evaluate future Fedora-native home-env management tools.

---

# 9. Summary

This ephemerality strategy ensures:
- Clean reproducibility.
- Low mental overhead.
- Confidence to experiment safely.
- Predictable, automatic recovery.

Your workstation becomes a **cloud-native personal platform**: stateless, rebuildable, and always aligned with the state declared in your Git repositories.

