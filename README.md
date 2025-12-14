# My Modular Workspace - Documentation

**Status:** Active & Refactored
**Last Updated:** 2025-12-14

This repository is the **single source of truth** for all documentation related to the Modular Workspace project. All component-specific documentation (for Home-Manager, Ansible, Chezmoi, etc.) lives here, not in the component repositories themselves.

---

## The Golden Rule of Documentation

> **If it's documentation, it belongs in this `docs/` repository.**

To maintain consistency and avoid information silos, please adhere to the following:
1.  **Centralize:** Do not create `README.md` or other documentation files within the `home-manager`, `ansible`, or other component-specific source code repositories.
2.  **Structure:** Create or update documentation within the appropriate subdirectory here (e.g., `docs/ansible/`, `docs/home-manager/`).
3.  **Index:** Update the corresponding `README.md` in the subdirectory to reference any new document you create.

---

## Architecture Overview

The workspace is built on a clear separation between the user environment and the underlying system.

```
┌─────────────────────────────────────────────────────────────┐
│              ROOT SYSTEM (NixOS) - requires sudo            │
│  Hardware drivers, DE enablement, system services          │
│  → docs/nixos/                                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│         USER ENVIRONMENT (Home-Manager) - no sudo          │
│  Packages, dotfiles, user services - PORTABLE to any OS    │
│  → docs/home-manager/                                       │
└─────────────────────────────────────────────────────────────┘
```
This structure allows the user environment, managed by Home-Manager, to be portable across different Linux distributions or even WSL, while the system-specific configuration remains isolated.

---

## Documentation Structure

This repository is organized by component. Each directory contains detailed guides, research, and decisions related to that part of the workspace.

| Directory | Description | README |
|-----------|-------------|--------|
| **[adrs/](adrs/)** | **Architecture Decision Records:** The "why" behind key technical choices. | - |
| **[ansible/](ansible/)** | Automation playbooks for bootstrapping and maintenance. | [ansible/README.md](ansible/README.md) |
| **[chezmoi/](chezmoi/)** | Cross-platform dotfile management with `chezmoi`. | [chezmoi/README.md](chezmoi/README.md) |
| **[home-manager/](home-manager/)** | **User Environment:** Declarative management of packages, services, and configs. | [home-manager/README.md](home-manager/README.md) |
| **[integrations/](integrations/)** | How third-party services (like KeePassXC) connect to the workspace. | [integrations/README.md](integrations/README.md) |
| **[nixos/](nixos/)** | **System Environment:** NixOS-specific configs for drivers, kernel, etc. | [nixos/README.md](nixos/README.md) |
| **[plans/](plans/)** | Active and future implementation plans. | [plans/README.md](plans/README.md) |
| **[sync/](sync/)** | File synchronization guides for `rclone` and `syncthing`. | [sync/README.md](sync/README.md) |
| **[tools/](tools/)** | Guides for specific command-line tools (atuin, kitty, navi, etc.). | [tools/README.md](tools/README.md) |
| **[archive/](archive/)** | Deprecated plans, old research, and historical documents. | [archive/README.md](archive/README.md) |
| [TODO.md](TODO.md) | A living document of active tasks and future work for the workspace. | - |

---

## How to Use This Documentation

1.  **Start with the Component:** If you have a question about Ansible, start in the `ansible/` directory.
2.  **Look for the `README.md`:** Each directory has a `README.md` that acts as a table of contents for that section.
3.  **Check the ADRs:** If you want to understand *why* a certain tool or approach was chosen, look for a relevant document in `adrs/`.
4.  **Consult the `TODO.md`:** For the latest tasks and development focus, see the main `TODO.md` file.

---

## Project Goals

1.  **Portability:** The user environment should work on NixOS, Fedora, and WSL.
2.  **Reproducibility:** Everything should be declarative and version-controlled.
3.  **Maintainability:** A clean, single source of truth for documentation makes the project easier to manage.
4.  **Ephemerality:** The ability to rebuild a complete user environment from scratch is a key design goal.

---

## Related Repositories

- **Home Manager:** `../home-manager/`
- **NixOS Config:** `../hosts/shoshin/nixos/`
- **Ansible:** `../ansible/`
- **Dotfiles (Chezmoi):** `../dotfiles/`