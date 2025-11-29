# Revised Home-Manager Decoupling Plan - Following Skeleton Draft 1

**Session:** my-modular-workspace-decoupling-home
**Date:** 2025-11-17
**Repo Name:** `my-home-manager-flake`
**Username:** `mitsio` (new username, changed from mitso)
**Goal:** Decouple home-manager from NixOS following the skeleton architecture

**Based on:** HOME-MANAGER_REPO_SKELETON_DRAFT_1.md

---

## 🎯 Core Philosophy (From Skeleton)

**Key principle:** System repo owns system-level modules, home repo owns user UX, tools, editors, workflow.

**Package approach:** Keep heavy runtimes in system NixOS modules for now (simpler). Home-manager gets:
- User-local CLI tools (ripgrep, fd, fzf, etc.)
- User-specific configurations (editors, shell, desktop)
- Activation scripts (npm installs, MCP helpers)
- User systemd services

**NOT moving to home-manager:**
- Heavy runtimes: Python, Go, Node.js base packages
- System packages: browsers, large GUI apps
- System services: Docker, rclone mounts, Dropbox daemon

---

## 📁 Target Directory Structure (From Skeleton)

```
~/.config/my-home-manager-flake/  (or ~/MySpaces/my-modular-workspace/my-home-manager-flake/)
├── flake.nix
├── flake.lock
├── README.md
├── home/
│   ├── common/
│   │   ├── core.nix           # Core user options (username, stateVersion, basic env)
│   │   ├── cli-tools.nix      # Generic CLI tools used everywhere
│   │   ├── dev-core.nix       # Language-agnostic dev (git config, editor defaults)
│   │   └── secrets.nix        # Home-manager view of secrets (no raw secrets)
│   └── mitsio/                # USER: mitsio (new username)
│       ├── default.nix        # Main entry for user profile (imports everything)
│       ├── shell.nix          # Bash: aliases, prompts, bw helpers
│       ├── editors.nix        # VSCodium, kitty, editor configs
│       ├── desktop.nix        # Plasma-manager, KDE user settings
│       ├── dev-go.nix         # Go-specific user tools (optional)
│       ├── dev-python.nix     # Python-specific user tools (optional)
│       ├── dev-js.nix         # JS/Node-specific user tools (optional)
│       ├── llm-tools.nix      # Claude Code, Cline, MCP helpers
│       ├── vaults.nix         # KeePassXC config + vault sync service
│       └── machines/
│           ├── shoshin.nix    # NixOS-specific overrides (nrs aliases, etc.)
│           ├── wsl-workspace.nix
│           └── kinoite.nix    # Future Fedora Kinoite config
└── hosts/
    ├── shoshin.nix            # Entry point: `home-manager --flake .#mitsio@shoshin`
    ├── wsl-workspace.nix
    └── kinoite.nix
```

---

## 📦 Phase 1: Create Skeleton Structure

### Step 1.1: Create Directory Tree

```bash
mkdir -p ~/.config/my-home-manager-flake
cd ~/.config/my-home-manager-flake
mkdir -p home/{common,mitsio/machines}
mkdir -p hosts
```

### Step 1.2: Create `flake.nix` (Entry Point)

**Responsibilities:**
- Declare inputs: nixpkgs (25.05 aligned), home-manager, plasma-manager
- Define `homeConfigurations` for each host
- Wire common modules + per-host overrides

**Outputs:**
- `homeConfigurations."mitsio@shoshin"` (NixOS desktop - current)
- `homeConfigurations."mitsio@kinoite"` (Fedora Kinoite - future)
- `homeConfigurations."mitsio@wsl-workspace"` (WSL - future)

### Step 1.3: Create `home/common/` Modules

#### `home/common/core.nix`
**Content:**
- `home.username = "mitsio"`
- `home.homeDirectory = "/home/mitsio"`
- `home.stateVersion = "25.05"`
- Shared `home.sessionVariables` (EDITOR, basic env vars)
- `programs.home-manager.enable = true`

**NOT included:** System-level settings (timezone, fonts, DNS - stay in NixOS)

#### `home/common/cli-tools.nix`
**User-local CLI tools only:**
- `ripgrep`, `fd`, `fzf`, `bat`, `eza` (modern ls)
- `jq`, `yq`, `gron`
- `htop`, `btop`, `iotop`
- `lnav` (log viewer)
- `ast-grep` (from unstable)

**NOT included:** System-wide tools already in NixOS (curl, wget, git base)

#### `home/common/dev-core.nix`
**Language-agnostic dev config:**
- `programs.git` (user name: "Dimitris Tsioumas", email: dtsioumas0@gmail.com, username: dtsioumas)
- `programs.git` aliases, diff tools, signing config
- Generic editor settings (default editor = vim/nvim)
- SSH config (if user-specific)

**Source:** Extract from current `home/mitso/home.nix` (git config section)

#### `home/common/secrets.nix`
**Home-manager view of secrets usage:**
- Environment variables that reference secrets (but not the secrets themselves)
- Paths to secret files (e.g., `~/.config/rclone/rclone.conf`)
- No raw secrets - those stay in KeePassXC

---

## 👤 Phase 2: Create `home/mitsio/` User Profile

### Step 2.1: `home/mitsio/default.nix` (Glue Module)

**Responsibilities:**
- Import all common modules
- Import all user-specific modules
- Import machine-specific overrides

**Imports:**
```nix
imports = [
  ../common/core.nix
  ../common/cli-tools.nix
  ../common/dev-core.nix
  ../common/secrets.nix

  ./shell.nix
  ./editors.nix
  ./desktop.nix
  ./dev-go.nix      # Optional - user-side Go tools
  ./dev-python.nix  # Optional - user-side Python tools
  ./dev-js.nix      # Optional - user-side JS tools
  ./llm-tools.nix
  ./vaults.nix

  # Machine-specific (passed via extraSpecialArgs)
  ./machines/${hostname}.nix
];
```

### Step 2.2: `home/mitsio/shell.nix`

**Source:** Current `~/.config/nixos/home/mitso/shell.nix`

**Keep (generic aliases):**
- Bitwarden helpers: `bwu`, `bws`
- Git shortcuts: `gs`, `ga`, `gc`, `gp`, etc.
- Directory shortcuts: `ll`, `la`, `l`
- Greeting message
- Bitwarden status check
- Locale loading

**Move to `machines/shoshin.nix` (NixOS-specific):**
- `nrs`, `nrt`, `nru` (nixos-rebuild aliases)
- `cd-nixos` alias
- NixOS-specific PATH additions

**Session variables:**
- Keep: `GOPATH`, `GOBIN`, `NPM_CONFIG_PREFIX` (user-level)
- Keep: `EDITOR=vim`, `BW_CLIENTID`, `BW_CLIENTSECRET` (from secrets)

**Path updates:** Change `/home/mitso/` → `/home/mitsio/` everywhere

### Step 2.3: `home/mitsio/editors.nix`

**Merge:**
- Current `kitty.nix` → `programs.kitty` config
- Current `vscodium.nix` → `programs.vscode` + product.json override
- Future: `neovim.nix` if added

**Content:**
- Kitty terminal: theme, fonts, keybindings, mouse settings
- VSCodium: settings, extensions (from current home.nix), marketplace override
- VSCode extension updater systemd service (from current home.nix)

**Make portable:** Avoid NixOS-specific paths where possible

### Step 2.4: `home/mitsio/desktop.nix`

**Source:** Current `~/.config/nixos/home/mitso/plasma.nix`

**Content (via plasma-manager):**
- Workspace settings (virtual desktops, rows)
- Panels configuration (top/bottom panels, widgets)
- Keyboard shortcuts (custom shortcuts for apps)
- System tray config
- Dolphin preferences
- Krunner settings
- Notifications (user-side)
- Power management (user-side)

**NOT included:** System-level Plasma enablement (SDDM, Plasma6 package - stays in NixOS)

**Note:** plasma-full.nix if needed, but consolidate into one desktop.nix

### Step 2.5: `home/mitsio/dev-go.nix` (Optional)

**User-side Go tools:**
- Language servers: `gopls` (if not in system)
- Formatters: `gofumpt`, `goimports`
- Linters: `golangci-lint` (user-local)
- Project tools: `air` (hot reload), `mockgen`

**NOT included:** Go runtime, go packages (stay in system `modules/development/go.nix`)

### Step 2.6: `home/mitsio/dev-python.nix` (Optional)

**User-side Python tools:**
- Language servers: `pyright` or `pylsp` (if user-local)
- Formatters: `black`, `ruff`
- Tools: `poetry`, `pipx` (user-local package manager)

**NOT included:** Python runtime, system Python packages (stay in system)

### Step 2.7: `home/mitsio/dev-js.nix` (Optional)

**User-side JS tools:**
- Language servers: `typescript-language-server` (if user-local)
- Formatters: `prettier`, `eslint`
- Tools: `yarn`, `pnpm` (alternative to npm)

**NOT included:** Node.js runtime (stays in system `modules/development/javascript.nix`)

### Step 2.8: `home/mitsio/llm-tools.nix`

**Source:** Current `~/.config/nixos/home/mitso/claude-code.nix` + parts of `home.nix`

**Content:**
1. **Claude Code CLI wrapper:**
   - `claude-code` package derivation (wrapper script)
   - Sets ANTHROPIC_API_KEY from Bitwarden
   - Sets ANTHROPIC_MODEL

2. **Activation scripts:**
   - Ensure `~/.npm-global` exists
   - Install/update `@anthropic-ai/claude-code` via npm
   - Install/update `cline` (VSCode extension CLI)

3. **Cline config:**
   - `~/.config/cline/config.json` (as currently done)

4. **VSCode Claude Code extension patcher:**
   - User-side systemd timer for extension updates
   - From current `modules/development/claude-code-vscode-patcher.nix`

**Portable:** Works on any system with `node` available (assumes system provides Node.js)

**Path updates:** Change `/home/mitso/` → `/home/mitsio/` everywhere

### Step 2.9: `home/mitsio/vaults.nix`

**Source:** Current `~/.config/nixos/home/mitso/keepassxc.nix`

**Content:**
1. **Packages:**
   - `keepassxc` (user package - or assume system provides it?)
   - `libnotify` (for notifications)

2. **KeePassXC config:**
   - `~/.config/keepassxc/keepassxc.ini`
   - Settings: autostart, minimize to tray, auto-type

3. **Vault sync service:**
   - User systemd service: `keepassxc-vault-sync.service`
   - User systemd timer: `keepassxc-vault-sync.timer`
   - Syncs `~/MyVault/` via Dropbox (assumes Dropbox running)

**Paths:**
- Generic: `$HOME/MyVault`, `$HOME/Dropbox/MyVault`
- Works across machines as long as Dropbox syncs
- Update: `/home/mitso/` → `/home/mitsio/`

---

## 🖥️ Phase 3: Per-Host Overrides (`home/mitsio/machines/`)

### Step 3.1: `home/mitsio/machines/shoshin.nix`

**NixOS-specific settings for shoshin desktop:**

1. **Bash aliases (NixOS-only):**
   ```nix
   programs.bash.shellAliases = {
     nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin";
     nrt = "sudo nixos-rebuild test --flake ~/.config/nixos#shoshin";
     nru = "nix flake update ~/.config/nixos && nrs";
     cd-nixos = "cd ~/.config/nixos";
   };
   ```

2. **Enable systemd user timers:**
   - `systemd.user.timers.keepassxc-vault-sync.enable = true`
   - `systemd.user.timers.vscode-extensions-update.enable = true`

3. **Host-specific paths:**
   - NixOS config path: `~/.config/nixos`
   - Anything else specific to NixOS desktop

### Step 3.2: `home/mitsio/machines/wsl-workspace.nix`

**WSL-specific settings (future):**

1. **Disable desktop:**
   - Don't import `desktop.nix` (no Plasma on WSL)

2. **Disable systemd user services:**
   - WSL might not have systemd --user
   - Conditional: `systemd.user.services.*.enable = false`

3. **WSL-specific aliases:**
   - Windows interop commands
   - WSL paths

### Step 3.3: `home/mitsio/machines/kinoite.nix`

**Fedora Kinoite-specific settings (future):**

1. **Keep desktop:**
   - Import `desktop.nix` (Plasma exists on Kinoite)

2. **Disable NixOS aliases:**
   - No `nrs`, `nrt` aliases

3. **Fedora-specific:**
   - Podman instead of Docker?
   - rpm-ostree commands?

---

## 🌐 Phase 4: Host Entry Points (`hosts/`)

### Step 4.1: `hosts/shoshin.nix`

**Entry point for:** `home-manager --flake .#mitsio@shoshin`

```nix
{ nixpkgs, home-manager, plasma-manager, ... }: {
  homeConfigurations."mitsio@shoshin" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    modules = [
      ../home/mitsio/default.nix
      plasma-manager.homeManagerModules.plasma-manager
    ];

    extraSpecialArgs = {
      hostname = "shoshin";
      # Pass unstable if needed for specific packages
      # unstablePkgs = ...;
    };
  };
}
```

### Step 4.2: `hosts/wsl-workspace.nix`

**Entry point for:** `home-manager --flake .#mitsio@wsl-workspace`

```nix
homeConfigurations."mitsio@wsl-workspace" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;

  modules = [
    ../home/mitsio/default.nix
    # NO plasma-manager (no desktop on WSL)
  ];

  extraSpecialArgs = {
    hostname = "wsl-workspace";
  };
};
```

### Step 4.3: `hosts/kinoite.nix`

**Entry point for:** `home-manager --flake .#mitsio@kinoite`

```nix
homeConfigurations."mitsio@kinoite" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;

  modules = [
    ../home/mitsio/default.nix
    plasma-manager.homeManagerModules.plasma-manager  # Kinoite has KDE!
  ];

  extraSpecialArgs = {
    hostname = "kinoite";
  };
};
```

---

## 🔄 Phase 5: Migration from Current NixOS Config

### Step 5.1: File Mapping (What Goes Where)

| Current File (user: mitso) | New Location (user: mitsio) | Notes |
|--------------|--------------|-------|
| `home/mitso/home.nix` | Split into multiple files | Main entry → `mitsio/default.nix` |
| `home/mitso/shell.nix` | `home/mitsio/shell.nix` | Extract NixOS aliases to machines/ |
| `home/mitso/claude-code.nix` | `home/mitsio/llm-tools.nix` | Merge with Cline, MCP helpers |
| `home/mitso/kitty.nix` | `home/mitsio/editors.nix` | Merge with VSCodium |
| `home/mitso/vscodium.nix` | `home/mitsio/editors.nix` | Merge with kitty |
| `home/mitso/keepassxc.nix` | `home/mitsio/vaults.nix` | Keep as-is, rename, update paths |
| `home/mitso/plasma.nix` | `home/mitsio/desktop.nix` | Consolidate with plasma-full if needed |
| `home/mitso/plasma-full.nix` | `home/mitsio/desktop.nix` | Merge into desktop.nix |
| Git config (from home.nix) | `home/common/dev-core.nix` | Extract programs.git |
| npm installs (from home.nix) | `home/mitsio/llm-tools.nix` | Activation scripts |

**IMPORTANT:** All paths must be updated from `/home/mitso/` to `/home/mitsio/`

### Step 5.2: What Stays in NixOS System Repo

**Keep in `~/.config/nixos`:**

✅ **System-level modules:**
- `modules/common.nix` (timezone, fonts, DNS, IPv6, SSH agent)
- `modules/system/*` (audio, NVIDIA, USB fixes, logging)
- `modules/workspace/plasma.nix` (Plasma6 enablement, SDDM)
- `modules/workspace/packages.nix` (GUI apps: firefox, obsidian, discord)
- `modules/workspace/rclone.nix` (system service: Google Drive mount)
- `modules/workspace/dropbox.nix` (system service: Dropbox daemon)
- `modules/development/tooling.nix` (VSCode, DBeaver, system dev tools)
- `modules/development/python.nix` (Python runtime + system packages)
- `modules/development/go.nix` (Go runtime + system packages)
- `modules/development/javascript.nix` (Node.js runtime)
- `modules/platform/*` (Docker, Kubernetes, etc.)

✅ **Host configs:**
- `hosts/shoshin/configuration.nix`
- `hosts/shoshin/hardware-configuration.nix`

❌ **Remove from NixOS system:**
- `home/mitso/*` (all files move to new home-manager repo)
- home-manager as NixOS module (will be standalone)

**IMPORTANT:** Update NixOS config to use new username `mitsio`:
- `users.users.mitsio` instead of `users.users.mitso`
- Update all references to `mitso` → `mitsio`

---

## 🧪 Phase 6: Testing Strategy

### Step 6.1: Build New Home-Manager Standalone

```bash
cd ~/.config/my-home-manager-flake
nix flake check  # Verify flake is valid
home-manager switch --flake .#mitsio@shoshin
```

### Step 6.2: Parallel Testing (Both Configs Running)

**Current state:**
- NixOS system still has home-manager module enabled (user: mitso)
- New standalone home-manager also builds (user: mitsio)

**Note:** Username change means fresh home directory `/home/mitsio/` will be created

**Verify:**
- New user `mitsio` exists
- Home directory `/home/mitsio/` created
- Configs applied to new user

### Step 6.3: User Migration Plan

**Option 1: Fresh start (recommended)**
1. Create new user `mitsio` on NixOS
2. Apply home-manager config to `mitsio`
3. Manually migrate critical data from `/home/mitso/` to `/home/mitsio/`
4. Delete old user `mitso` when ready

**Option 2: Rename existing user**
1. Rename `mitso` → `mitsio` at system level
2. Move `/home/mitso/` → `/home/mitsio/`
3. Update NixOS config user definitions
4. Apply home-manager to renamed user

**Recommended:** Option 1 (fresh start) - cleaner, less risk

### Step 6.4: Switch NixOS to Minimal System Config

**Edit `~/.config/nixos/flake.nix`:**
1. Remove `home-manager` input
2. Remove `plasma-manager` input (moved to home repo)
3. Remove `home-manager.nixosModules.home-manager` from modules
4. Remove entire `home-manager.*` configuration block
5. Remove `home/` directory (git rm -r home/)
6. Update user definition: `users.users.mitsio` (instead of mitso)

**Rebuild NixOS:**
```bash
cd ~/.config/nixos
sudo nixos-rebuild switch --flake .#shoshin
```

**System now:**
- Provides: Base system, Plasma DE, runtimes (Python, Go, Node), GUI apps
- User: `mitsio` (instead of mitso)
- Does NOT provide: User configs (now from standalone home-manager)

### Step 6.5: Verify Complete Setup

```bash
# Check home-manager packages
home-manager packages

# Check shell
echo $EDITOR
alias | grep -E "(nrs|bwu|gs)"

# Check Plasma settings
# Log out and back in as mitsio, verify panels/shortcuts work

# Check services
systemctl --user status keepassxc-vault-sync.timer
systemctl --user status vscode-extensions-update.timer

# Check apps
code  # VSCodium
kitty
keepassxc
```

---

## 🚀 Phase 7: Fedora Kinoite Migration (Future - Week 2)

### Step 7.1: Pre-Migration Checklist

- [ ] Commit and push home-manager repo
- [ ] Commit and push NixOS repo (in case need to rollback)
- [ ] Verify `~/MyVault/` synced to Dropbox
- [ ] Export Bitwarden data (backup)
- [ ] Backup critical data not in repos
- [ ] Create Fedora Kinoite USB installer

### Step 7.2: Fresh Kinoite Install on Shoshin

1. Boot Kinoite installer
2. Install Fedora Kinoite (KDE variant)
3. Boot into Kinoite
4. Initial setup (user: **mitsio**, language, etc.)

### Step 7.3: Bootstrap Kinoite

**Manual steps:**
```bash
# 1. Install Nix (multi-user install)
sh <(curl -L https://nixos.org/nix/install) --daemon

# 2. Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# 3. Install home-manager
nix run home-manager -- init --switch

# 4. Clone home-manager repo
cd ~/.config
git clone https://github.com/dtsioumas/my-home-manager-flake.git

# 5. Switch to kinoite config
cd ~/.config/my-home-manager-flake
home-manager switch --flake .#mitsio@kinoite

# 6. Setup Dropbox (for ~/MyVault/ sync)
# Install via flatpak or rpm-ostree
flatpak install flathub com.dropbox.Client

# 7. Wait for ~/MyVault/ to sync from Dropbox

# 8. Test!
```

**Result:** Same user environment on Kinoite as on NixOS! 🎉

---

## 🎯 Phase 8: Future Enhancements

Once basic structure works:

### 8.1: Chezmoi Integration (Later)

- Keep home-manager for packages + services
- Move some dotfiles to chezmoi (bash, git, etc.)
- Hybrid approach: home-manager (packages) + chezmoi (configs)

### 8.2: GNU Stow (Optional Backup)

- Traditional symlink approach
- Alternative to chezmoi for simpler configs

### 8.3: Ansible Bootstrap (Full Automation)

- Playbook that:
  1. Installs Nix
  2. Installs home-manager
  3. Clones repos
  4. Applies configs
  5. Sets up secrets (KeePassXC)
- Fresh Kinoite install → Run 1 playbook → Fully configured!

### 8.4: Move to ~/MySpaces/my-modular-workspace/

**When ready:**
```bash
mv ~/.config/my-home-manager-flake ~/MySpaces/my-modular-workspace/my-home-manager-flake

# Update flake reference
home-manager switch --flake ~/MySpaces/my-modular-workspace/my-home-manager-flake#mitsio@kinoite
```

**Design for relocation:**
- Use environment variables for paths
- Avoid hardcoded paths where possible

---

## 📊 Summary: Division of Responsibilities

| Component | Managed By | Location |
|-----------|------------|----------|
| **System-level** | NixOS config | `~/.config/nixos/` |
| - Base system, kernel, drivers | NixOS | `modules/system/` |
| - Desktop environment (Plasma6, SDDM) | NixOS | `modules/workspace/plasma.nix` |
| - System services (rclone, Dropbox) | NixOS | `modules/workspace/` |
| - Heavy runtimes (Python, Go, Node) | NixOS | `modules/development/` |
| - GUI applications | NixOS | `modules/workspace/packages.nix` |
| - User definition (username: mitsio) | NixOS | `users.users.mitsio` |
| **User-level** | Home-Manager | `~/.config/my-home-manager-flake/` |
| - Shell config (bash, aliases) | Home-Manager | `home/mitsio/shell.nix` |
| - Editor configs (VSCodium, kitty) | Home-Manager | `home/mitsio/editors.nix` |
| - Desktop settings (Plasma user) | Home-Manager | `home/mitsio/desktop.nix` |
| - LLM tools (Claude Code, Cline) | Home-Manager | `home/mitsio/llm-tools.nix` |
| - Vault sync (KeePassXC user) | Home-Manager | `home/mitsio/vaults.nix` |
| - User CLI tools (ripgrep, fd, etc.) | Home-Manager | `home/common/cli-tools.nix` |
| - User systemd services | Home-Manager | Various modules |

---

## ✅ Success Criteria

- [ ] Standalone home-manager builds successfully
- [ ] All user configs extracted from NixOS repo
- [ ] Username changed from `mitso` to `mitsio` throughout
- [ ] All paths updated: `/home/mitso/` → `/home/mitsio/`
- [ ] No NixOS-specific assumptions in portable modules
- [ ] Per-host overrides work (`machines/shoshin.nix`)
- [ ] Can switch between hosts: `home-manager --flake .#mitsio@shoshin`
- [ ] System survives reboot (all services start)
- [ ] NixOS system repo is minimal (no home-manager module)
- [ ] NixOS uses new username `mitsio`
- [ ] Can migrate to Kinoite: install Nix + home-manager + apply config
- [ ] Same user experience on NixOS and Kinoite
- [ ] All configs version controlled in git

---

## 📅 Implementation Timeline

**Week 1: Home-Manager Standalone (NixOS)**
- Day 1-2: Create skeleton, split modules, extract configs (username: mitsio)
- Day 3-4: Test standalone on NixOS with new user mitsio
- Day 5: Switch NixOS to minimal system + standalone home + new username
- Day 6-7: Verify everything works, migrate data from mitso → mitsio, fix issues

**Week 2: Kinoite Migration**
- Backup everything
- Fresh Kinoite install on shoshin (user: mitsio)
- Bootstrap: Nix + home-manager + configs
- Verify same UX on Kinoite as on NixOS

**Future: Advanced Integration**
- Chezmoi for dotfiles
- GNU Stow for backup
- Ansible for full automation
- Move to ~/MySpaces/my-modular-workspace/

---

## ⚠️ Important Notes: Username Change

**Username:** `mitso` → `mitsio`

**Impacts:**
1. **Home directory:** `/home/mitso/` → `/home/mitsio/`
2. **All configs:** Update paths everywhere
3. **NixOS user definition:** `users.users.mitsio`
4. **Git commits:** Sign with new username `mitsio` (username dtsioumas for public, mitsio for private)
5. **SSH keys:** Copy from old user or regenerate
6. **GPG keys:** Copy from old user or regenerate
7. **Browser profiles:** Firefox/Brave profiles in new home dir
8. **Application data:** Migrate as needed from `/home/mitso/` to `/home/mitsio/`

**Recommendation:** Create new user `mitsio`, apply configs, manually migrate critical data, keep old user as backup temporarily

---

**Generated:** 2025-11-17
**Based on:** HOME-MANAGER_REPO_SKELETON_DRAFT_1.md
**Session:** my-modular-workspace-decoupling-home
**Repo:** `my-home-manager-flake`
**User:** `mitsio` (new username)
**Author:** Claude Code + Mitsio
