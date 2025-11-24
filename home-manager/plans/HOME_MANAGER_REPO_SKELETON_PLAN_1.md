# Home Manager Flake Skeleton – Draft 1

Goal: decouple user/home configuration from system NixOS config, using a separate `home-manager` flake that you can reuse across:
- NixOS desktops/laptops
- non-NixOS (e.g. Fedora Kinoite bluebuild, Ubuntu, WSL, etc.)

This document is only the skeleton / blueprint – not final code.

---

## 1. Repo Overview

**Repo name (suggested):** `my-home-manager-flake`  
**Primary purpose:** portable, host‑agnostic home‑manager config for user `mitso`.

High‑level layout:

```text
my-home-manager-flake/
├── flake.nix
├── flake.lock                 # (generated)
├── README.md
├── home/
│   ├── common/
│   │   ├── core.nix           # core user options (shell, locale, fonts)
│   │   ├── cli-tools.nix      # generic CLI tools used everywhere
│   │   ├── dev-core.nix       # language-agnostic dev bits (git, editor defaults)
│   │   └── secrets.nix        # home-manager view of secrets usage (no raw secrets)
│   └── mitso/
│       ├── default.nix        # main entry for user profile (imports the others)
│       ├── shell.nix          # user shell: aliases, prompts, bw helpers, etc.
│       ├── editors.nix        # VSCodium/VSCode, kitty, editor configs
│       ├── desktop.nix        # home‑side desktop settings (plasma‑manager, apps)
│       ├── dev-go.nix         # Go-specific tools in home-manager space
│       ├── dev-python.nix     # Python-specific tools in home-manager space
│       ├── dev-js.nix         # JS/Node-specific tools in home-manager space
│       ├── llm-tools.nix      # claude-code, cline, MCP helpers, etc.
│       ├── vaults.nix         # KeePassXC UI + local paths (no secrets)
│       └── machines/
│           ├── shoshin.nix    # per-machine overrides for this user
│           ├── wsl-workspace.nix
│           └── kinoite.nix
└── hosts/
    ├── shoshin.nix            # for `home-manager --flake .#shoshin`
    ├── wsl-workspace.nix
    └── kinoite.nix
```

Key idea: **system repo owns system‑level modules**, this repo owns **user UX, tools, editors, workflow**.

---

## 2. Flake Inputs & Outputs (Conceptual)

### 2.1 Inputs

- `nixpkgs` – pinned channel for home-manager
- `home-manager` – HM itself
- `plasma-manager` – for KDE/Plasma configuration

Align versions with your NixOS config where possible (you already use 25.05 + release‑25.05).

### 2.2 Outputs

- `homeConfigurations."mitso@shoshin"` – NixOS desktop
- `homeConfigurations."mitso@wsl-workspace"` – WSL
- `homeConfigurations."mitso@kinoite"` – Fedora Kinoite bluebuild host (same user profile)

Each `homeConfiguration` will:
- import `home/mitso/default.nix`
- pass in any `extraSpecialArgs` that differ per host (e.g. `unstablePkgs`, feature flags for MCP servers, etc.).

---

## 3. Mapping from current NixOS repo → new home-manager flake

We want to **move home concerns out** of `~/.config/nixos` and into this new flake.

### 3.1 Current home‑manager files

From `home/mitso/` in the NixOS repo:
- `home.nix` – big consolidated home‑manager config (imports shell, claude-code, kitty, vscodium, keepassxc, claude patcher module)
- `shell.nix` – bash and PATH setup, aliases
- `claude-code.nix` – CLI wrapper and updater
- `kitty.nix` – kitty configuration
- `vscodium.nix` – editor settings and marketplace override
- `keepassxc.nix` – KeePassXC UI + sync service
- `plasma.nix` & `plasma-full.nix` – home‑side Plasma settings

**Target split inside new repo:**

- `home/mitso/default.nix` imports:
  - `../common/core.nix` (shared locale, fonts, basic env) – only if it’s *truly* user‑level and not system‐level
  - `../common/cli-tools.nix` (home‑installed tools if you prefer some to be user‑local)
  - `./shell.nix`
  - `./editors.nix`
  - `./desktop.nix`
  - `./llm-tools.nix`
  - `./vaults.nix`
  - `./machines/${host}.nix` (with `host` passed via `extraSpecialArgs` or explicit import in each `homeConfigurations.*`)

Anything that configures `/etc/*`, systemd *system* units, kernel, drivers etc. stays in the NixOS repo.

### 3.2 Plasma/desktop split

Right now you use:
- system modules: `modules/workspace/plasma.nix`, `plasma-kdeconnect.nix`, etc.
- home modules: `home/mitso/plasma.nix`, `plasma-full.nix`

In the new structure:

- **System repo** continues to own:
  - enabling SDDM, Plasma6, audio stack, NVIDIA stuff
  - global defaults (default browser env vars, firewall rules)

- **Home repo** owns:
  - `programs.plasma` (panels, widgets, shortcuts, Dolphin preferences)
  - `programs.kitty`, editor themes, etc.

So `home/mitso/desktop.nix` in the new repo becomes the cleaned‑up union of your current `home/mitso/plasma.nix` (the version that is actually used) and any parts of `plasma-full.nix` you want to keep.

---

## 4. Draft file contents (high‑level descriptions)

### 4.1 `flake.nix` (home repo)

Responsibilities:
- Declare inputs (nixpkgs, home-manager, plasma-manager)
- Define `homeConfigurations` for each host
- Wire common modules + per‑host overrides

You will:
- Import `home/mitso/default.nix` as the main module
- For each host, pass `hostname` or a `variant` enum into `extraSpecialArgs` so that `machines/*.nix` can conditionally enable stuff.

### 4.2 `home/common/core.nix`

Contains things that are **user‑global** and not really host‑specific:
- `home.username` and maybe `home.homeDirectory` (or you keep these in per‑host files if different paths)
- `home.stateVersion`
- Shared `home.sessionVariables` that are safe on any machine (`EDITOR`, high‑level env vars)

Be careful not to duplicate system‑level facts here (e.g. `time.timeZone` is system, not home).

### 4.3 `home/common/cli-tools.nix`

Optional: if you want some tools to be user‑local rather than system packages.

Contains:
- CLI utilities that don’t need root/system integration (e.g. `lnav`, `ripgrep`, `fd`, `fzf`, etc.)
- Possibly your `ast-grep` from `unstable` if you want it only for your user.

### 4.4 `home/common/dev-core.nix`

Things like:
- `programs.git` (user name/email, git config)
- Generic editor/IDE preferences that aren’t tied to a specific tool

You already have `programs.git` in `home/mitso/home.nix`; that belongs here.

---

## 5. User‑specific subtree `home/mitso/`

### 5.1 `home/mitso/default.nix`

The glue module for your personal profile.

Roles:
- set `home.username` = "mitso"
- set `home.homeDirectory` = "/home/mitso" (or get passed from host module if needed)
- import common modules and user‑specific modules
- enable `programs.home-manager.enable`

Imports:
- `../common/core.nix`
- `../common/cli-tools.nix`
- `../common/dev-core.nix`
- `./shell.nix`
- `./editors.nix`
- `./desktop.nix`
- `./llm-tools.nix`
- `./vaults.nix`
- `./machines/shoshin.nix` / etc., via host selection

### 5.2 `home/mitso/shell.nix`

This is basically your current `home/mitso/shell.nix`, but generalized:

- `programs.bash.enable = true`
- `shellAliases` for:
  - Bitwarden helpers (`bwu`, `bws`)
  - NixOS rebuild shortcuts (but those might be gated per‑host – see below)
  - git shortcuts (`gs`, `ga`, etc.)
- `initExtra` for:
  - greeting message
  - Bitwarden status check
  - locale loading
- `home.sessionVariables` for `GOPATH`, `GOBIN`, etc. (or move to core if fully global)

Per‑host: you *don’t* want `nrs = sudo nixos-rebuild` on non‑NixOS hosts. So:
- put NixOS‑specific aliases in `machines/shoshin.nix`
- keep generic aliases in `shell.nix`.

### 5.3 `home/mitso/editors.nix`

Merge:
- current `vscodium.nix` (product.json override + `programs.vscode` settings)
- any future editor config
- `kitty.nix`

Responsibilities:
- Keep all **UI/editor** bits in one place
- Make it portable: avoid assumptions that only exist on NixOS (e.g. paths into `/nix/store`) as much as possible.

### 5.4 `home/mitso/desktop.nix`

This takes your `home/mitso/plasma.nix` and/or `plasma-full.nix` and becomes:

- `programs.plasma` block:
  - workspace (desktops, rows)
  - panels
  - keyboard shortcuts
  - Plasma widgets / system tray config
  - Dolphin settings
  - krunner, notifications, powerManagement (user side)

Constraints:
- Assume that the system has already enabled Plasma and audio; this module just shapes the DE.

### 5.5 `home/mitso/dev-go.nix`, `dev-python.nix`, `dev-js.nix`

Lightweight user‑side dev settings, complementing system modules:
- You already have big system modules under `modules/development/go.nix`, `python.nix`, `javascript.nix`.

In home repo you can add:
- editor integration (language servers, formatters) if they must be user‑local
- project‑specific defaults (e.g. favorite tools in PATH via `home.sessionPath`)

But keep heavy runtimes in system NixOS modules for now (simpler, and you already have them).

### 5.6 `home/mitso/llm-tools.nix`

Moves out things from:
- `home/mitso/claude-code.nix`
- the activation scripts in `home/mitso/home.nix` that manage Cline and Claude Code CLI
- `modules/development/claude-code-vscode-patcher.nix` (at least its *home‑side* enabling)

Responsibilities:
- Manage CLI tools which are safe & meaningful even on non‑NixOS machines (as long as `node` is available)
- Expose activation hooks:
  - ensure `~/.npm-global` exists
  - install/update `@anthropic-ai/claude-code` and Cline on rebuild/login
- configure `.config/cline/config.json` (as you already do)

On non‑NixOS hosts, you’ll probably:
- still use home‑manager (via `nix` standalone) to drive the same activation logic
- rely on system packages or manually installed `node` if not controlled by this repo

### 5.7 `home/mitso/vaults.nix`

Everything from `keepassxc.nix` that is clearly user‑land:
- `home.packages = [ keepassxc libnotify ]`
- user‑level systemd services & timers for vault sync (they’ll still work on non‑NixOS as long as `systemd --user` exists)
- KeePassXC `.ini` file

Paths:
- keep them generic (`$HOME/MyVault`, `$HOME/Dropbox/...`) so the same module works across machines.

---

## 6. Per‑host overlays for the user (`home/mitso/machines/*.nix`)

These are **small** modules that:
- tweak aliases or scripts that only make sense on that host
- turn on/off some features (e.g. WSL doesn’t have systemd‑user? then disable certain services)

Examples:

### 6.1 `home/mitso/machines/shoshin.nix`

- Adds NixOS‑specific bash aliases:
  - `nrs`, `nrt`, etc.
- Enables `systemd.user.timers.*` which rely on services defined in home repo
- Possibly adds host‑specific paths like `~/.config/nixos/docs/...` references

### 6.2 `home/mitso/machines/wsl-workspace.nix`

- Might disable desktop/Plasma related things
- Only keep shell and dev tools

### 6.3 `home/mitso/machines/kinoite.nix`

- Plasma desktop exists; keep `desktop.nix` imports
- But **NixOS‑only assumptions** are off

---

## 7. Host entrypoints under `hosts/`

Each file here corresponds to one `homeConfiguration` output.

Example responsibilities:
- specify the `system` (e.g. `x86_64-linux`)
- import `home/mitso/default.nix`
- set `extraSpecialArgs` (e.g. pass `hostname = "shoshin";` and `unstablePkgs` if you want)

Then you can run:

- `home-manager switch --flake .#mitso@shoshin`
- Or equivalent for WSL / Kinoite from that host.

---

## 8. Division of responsibilities vs your current NixOS flake

### System (old repo) keeps:

- `modules/common.nix` (time zone, console keyboard, fonts, DNS, IPv6 settings, SSH agent, etc.)
- `modules/system/*` (audio, logging, NVIDIA, stress-testing, usb-mouse-fix, wireplumber)
- `modules/workspace/*` that touch systemd **system** units, rclone mounts, docker, etc.
- `modules/development/*` where the tools are better as system packages
- `modules/platform/*` (containers, kubernetes, etc.)
- `hosts/shoshin/configuration.nix` and similar

### Home (new repo) takes:

- all `home/mitso/*` modules and their activation scripts
- plus any new per‑user/per‑host logic you want to be portable to Kinoite or WSL

This gives you:
- clean separation: **system flake** vs **user flake**
- easier disaster‑recovery: you can reapply your home config on any compatible host
- alignment with your "my-modular-workspace" idea.

---

## 9. Next steps

1. Create the new repo `my-home-manager-flake` with this skeleton.
2. Copy current `home/mitso/*.nix` from `~/.config/nixos` into the appropriate modules in the new structure.
3. Strip out NixOS‑specific assumptions from home‑side modules (e.g. aliases that call `nixos-rebuild`) into `machines/shoshin.nix`.
4. Update your NixOS system flake to:
   - remove embedded `home-manager.users.mitso` from there
   - instead, call `home-manager` as a separate flake on the host (or keep it wired but pointing at this external flake).

Once this skeleton is in place, we can then iterate file‑by‑file and rewrite your current `home.nix` into this modular layout.

