# My Modular Workspace — Project Context & Operating Manual (v0.1)

**Status:** Active (alpha, under construction)  
**This document’s job:** Be the single “read me first” file that explains what the project *is*, how it’s structured, and how to operate it—so future-you (and future assistants) instantly have context.

---

## 1) One-sentence definition

A modular, reproducible workspace stack that lets me rebuild my tools, configs, and personal file layout across **Linux (NixOS → Fedora Atomic)** and **Windows (via WSL2)** with GitOps/Declarative practices (Home-Manager + Chezmoi + systemd user services), while keeping personal files synced via a shared “MyHome” directory.

---

## 2) Goals and non-goals

### Goals
- **Portability:** user environment should work on NixOS, Fedora (Atomic/Kinoite), and WSL2.
- **Reproducibility:** rebuild from scratch with minimal manual work.
- **Declarative user services:** systemd user services, symlinks, configs—defined in code.
- **Cross-workspace consistency:** same stack across personal + corporate devices.
- **Ephemerality:** fast rebuild/replace of machines/VMs without losing your stack.

### Non-goals (for now)
- Replacing corporate device management.
- Perfect “one tool to rule them all” for every OS corner-case (Windows vs Linux friction exists).

---

## 3) The architecture (mental model)

The project is based on a strict separation between:

1. **Root System layer** (OS-specific, requires sudo)  
   - NixOS now (shoshin), Fedora Atomic planned (future), Windows host is “system layer” too.
2. **User Environment layer** (portable, no sudo)  
   - Managed by **Home-Manager**: packages, dotfiles links, user services, scripts, PATH, etc.
3. **Dotfiles & cross-platform configs layer**  
   - Managed by **Chezmoi** (including Windows host configs where needed).
4. **Personal files layer (“MyHome”)**  
   - Shared directory synced via **rclone bisync**; exposed under `~/.MyHome/` and symlinked into `$HOME`.

---

## 4) Workspaces / Machines (current)

### 4.1 shoshin (personal desktop)
- **Role:** primary dev workspace for this project.
- **Current OS:** NixOS (planned migration to Fedora Atomic/Kinoite in 4–6 months).
- **Runs:** Home-Manager + Chezmoi + MyHome sync.

### 4.2 eyeonix-laptop (hostname: system-laptop01) — corporate Windows
- **Role:** corporate workspace integrated via WSL2.
- **Host OS:** Windows 11
- **WSL distro plan:** Fedora (maybe Atomic/Kinoite).
- **GUI integration plan:** X410 + KDE Plasma (subject to performance/limitations).
- **Runs:** Chezmoi on Windows host + Home-Manager inside WSL + MyHome sync.

---

## 5) “MyHome” shared directory (file sync & layout)

### 5.1 Canonical storage
- Canonical location on each Linux/WSL environment: `~/.MyHome/`
- Physical backing store: Google Drive “MyHome” (synced locally via rclone).

### 5.2 Sync mechanism
- rclone **bisync** is used to keep local `~/.MyHome/` aligned with Google Drive.
- This is currently **buggy and high-maintenance**, but expected to stabilize over time.

### 5.3 Symlink strategy
- Subdirectories of `~/.MyHome/` are exposed via symlinks into `$HOME`
  - Example: `~/Documents -> ~/.MyHome/Documents` (exact list is configurable).

---

## 6) Repositories and components (source-of-truth map)

> NOTE: repo names/paths might change later (e.g. to `modular-workspace-project`).

### 6.1 Docs (single source of truth)
- **Docs repo:** `my-modular-workspace-docs`
- Docs live here for *all* components. Code repos should avoid duplicating docs.
- Subdirectories include: `adrs/`, `home-manager/`, `chezmoi/`, `sync/`, `tools/`, etc.

### 6.2 Home-Manager (user environment)
- Code + modules to declare:
  - packages
  - systemd user services
  - symlinks
  - per-host/user overlays

### 6.3 Dotfiles (Chezmoi)
- Cross-platform dotfiles and config templates.
- Includes Windows host configs (VSCode/VSCodium, Firefox, agents, etc.) where required.

### 6.4 Host configs
- Example: `hosts/shoshin/nixos/` for system-level NixOS settings.

---

## 7) Secrets model (current approach)

- Source of truth: **KeePassXC database**
- Integration: **KeePassXC Secret Service**
- Mechanism: a **systemd user unit** that loads secrets as environment variables (no plaintext in repos).
- Scripts/services read secrets via environment variables.

*(We will document exact unit names and expected env var keys once stabilized.)*

---

## 8) Daily operations (what “working on this” looks like)

### 8.1 Update workflow (typical)
1. Make config changes (home-manager / chezmoi / docs).
2. Apply:
   - `home-manager switch` (Linux/WSL user env)
   - `chezmoi apply` (dotfiles/config templates)
3. Validate:
   - user services healthy (systemd --user)
   - MyHome sync clean (rclone bisync logs)

### 8.2 Bootstrap workflow (new machine)
1. Bring up OS base (NixOS/Fedora/Windows+WSL).
2. Clone repos (docs + home-manager + dotfiles + host config).
3. Install/enable:
   - Nix + Home-Manager
   - Chezmoi
   - rclone + bisync config
4. Apply configs, restart user services.

---

## 9) Current risks / pain points (explicitly acknowledged)

- **rclone bisync churn** (conflicts, filesystem semantics, Windows/Linux edits).
- **Windows host vs WSL boundaries** (where configs should live, performance constraints).
- **Immutable Fedora Atomic** (tooling install path, ostree layering decisions).
- **Naming drift** (project rename, repo rename).

---

## 10) Open questions (things to decide and freeze as ADRs)

1. **Windows host tool policy:** which tools must exist on host Windows vs inside WSL?
2. **Filesystem policy:** which directories are “Linux-only” and which are safe to edit from Windows apps?
3. **Source-of-truth for secrets:** KeePassXC-only, or partial migration to age/sops/1Password/etc?
4. **Final repo naming & ownership:** does `my-modular-workspace` become `modular-workspace-project`?

---

## 11) Conventions (anchors for future reference)

- **Workspaces:** `shoshin`, `system-laptop01` (eyeonix-laptop)
- **Shared root:** `~/.MyHome/`
- **Project working root (inside MyHome):** `~/.MyHome/MySpaces/my-modular-workspace/`
- **Docs rule:** documentation belongs in docs repo.

---

## 12) Next steps (to move from “alpha” to stable)

- Create ADRs for the 4 open questions above.
- Define canonical directory map for symlinks under `$HOME`.
- Document rclone bisync “conflict playbook” (how to recover safely).
- Decide WSL Fedora Atomic base image + minimal set of rpm-ostree layers.
- Add a “bootstrap checklist” per host (shoshin vs system-laptop01).

---
