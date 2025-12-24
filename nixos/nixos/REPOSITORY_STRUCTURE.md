# NixOS Configuration - Repository Structure

**Last Updated:** 2025-11-23
**Purpose:** Explain the organization and architecture of this NixOS configuration

---

## Overview

This is a **flake-based NixOS configuration** using a modular architecture. The configuration lives inside a larger workspace (`my-modular-workspace`) but maintains its own git repository.

## Directory Tree

```
~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/
├── flake.nix                      # Flake entry point
├── flake.lock                     # Locked dependencies
├── configuration.nix              # Legacy config (imports modules)
│
├── hosts/shoshin/                 # Host-specific configs
│   ├── configuration.nix          # Main system config
│   └── hardware-configuration.nix # Hardware detection
│
├── modules/                       # Modular configuration
│   ├── common.nix                 # Base system (all machines)
│   ├── common/                    # Common submodules
│   │   └── security.nix
│   ├── workspace/                 # Desktop environment & apps
│   │   ├── plasma.nix            # KDE Plasma 6 (plasma-manager)
│   │   ├── packages.nix          # GUI applications
│   │   ├── rclone-bisync.nix     # GoogleDrive sync
│   │   └── ...
│   ├── system/                    # Low-level system configs
│   │   ├── audio.nix             # PipeWire + WirePlumber
│   │   ├── nvidia.nix            # NVIDIA drivers
│   │   └── ...
│   ├── development/               # Developer tools
│   │   ├── tooling.nix           # CLI tools, editors
│   │   ├── go.nix                # Go environment
│   │   ├── python.nix            # Python environment
│   │   ├── mcp-servers.nix       # MCP server configurations
│   │   └── claude-code-vscode-patcher.nix
│   └── platform/                  # Container & orchestration
│       ├── kubernetes.nix        # K3s configuration
│       ├── containers.nix        # Podman + Docker
│       ├── virtualization.nix    # QEMU/KVM
│       └── litellm.nix           # LiteLLM proxy
│
├── home/mitsio/                   # Home-manager configs (as NixOS module)
│   ├── home.nix                  # User packages & settings
│   ├── shell.nix                 # Bash configuration
│   ├── plasma.nix                # KDE user settings
│   ├── vscodium.nix              # VSCodium setup
│   ├── keepassxc.nix             # KeePassXC + vault sync
│   └── ...
│
└── docs/                          # Documentation
    ├── REPOSITORY_STRUCTURE.md   # This file
    ├── QUICK_START.md            # Essential commands
    ├── nixos/                    # NixOS guides
    │   ├── FORMATTERS.md
    │   └── LINTERS.md
    └── pre-commit/               # Development workflow
        └── SETUP.md
```

---

## Architecture Patterns

### 1. Flake-Based Configuration

**Entry Point:** `flake.nix`

The flake defines:
- **Inputs:** nixpkgs, home-manager, plasma-manager, git-hooks.nix, etc.
- **Outputs:**
  - `nixosConfigurations.shoshin` - System configuration
  - `checks.x86_64-linux.pre-commit-check` - Code quality hooks
  - `devShells.x86_64-linux.default` - Development environment

**Why Flakes?**
- Reproducible builds (locked dependencies in `flake.lock`)
- Easy updates: `nix flake update`
- Native development shells: `nix develop`

### 2. Host-Specific Pattern

**Location:** `hosts/shoshin/`

Each physical machine has its own directory:
- `configuration.nix` - Imports modules, sets hostname, users
- `hardware-configuration.nix` - Auto-generated hardware settings

**Future:** Add `hosts/laptop/` for laptop configuration

### 3. Module Organization

All reusable configuration lives in `modules/` organized by purpose:

#### `modules/common.nix` - **Foundation**
- **Purpose:** Settings for ALL machines
- **Contains:**
  - Core system packages (vim, git, htop, etc.)
  - Code quality tools (alejandra, statix, deadnix)
  - Fonts (Hack, JetBrains Mono, Noto)
  - Networking (DNS, IPv6 config)
  - SSH agent
  - Environment variables (PATH exports)

#### `modules/workspace/` - **Desktop Environment**
- KDE Plasma 6 configuration (declarative via plasma-manager)
- Desktop applications (Brave, Firefox, Dropbox)
- Cloud sync (rclone for GoogleDrive)
- Theming (Nordic theme)

#### `modules/system/` - **Hardware & Low-Level**
- Audio (PipeWire, WirePlumber, USB DAC)
- Graphics (NVIDIA drivers)
- Power management
- Logging (journald config)

#### `modules/development/` - **Developer Environment**
- Programming languages (Go, Python, JavaScript, Rust)
- Development tools (VSCode patching, MCP servers)
- Cloud development (LiteLLM limits, MCP configurations)

#### `modules/platform/` - **Infrastructure**
- Kubernetes (K3s with ingress)
- Container runtime (Podman, Docker compat)
- Virtualization (QEMU/KVM)
- LiteLLM proxy server

### 4. Home-Manager Integration

**Pattern:** NixOS Module (not standalone)

Home-manager is integrated as a **NixOS module** in `flake.nix`:

```nix
home-manager.nixosModules.home-manager
{
  home-manager.users.mitsio = import ./home/mitsio/home.nix;
  home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
}
```

**Why NixOS Module?**
- Single `nixos-rebuild` rebuilds both system AND user config
- Shared state version (no version mismatch)
- User settings activate during system activation

**User Config:** `home/mitsio/home.nix`
- User packages (not in system)
- Dotfile management
- User services (timers, systemd units)
- Application-specific configs

---

## Configuration Workflow

### Module Import Chain

```
flake.nix
  └─> nixosConfigurations.shoshin
       └─> hosts/shoshin/configuration.nix
            ├─> modules/common.nix
            ├─> modules/workspace/*.nix
            ├─> modules/system/*.nix
            ├─> modules/development/*.nix
            ├─> modules/platform/*.nix
            └─> home-manager → home/mitsio/home.nix
```

### Rebuild Process

1. **Edit** any `.nix` file
2. **Test** (optional): `sudo nixos-rebuild test --flake .#shoshin`
3. **Apply**: `sudo nixos-rebuild switch --flake .#shoshin`
4. **Commit**: `git add . && git commit`

**Pre-commit hooks** run automatically on commit (formatting, linting).

---

## Symlink Strategy

**System Symlink:**
```bash
/etc/nixos → ~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/
```

**Benefits:**
- Use `sudo nixos-rebuild switch` without explicit path
- System knows where config lives
- Legacy tools work without modification

**Created by:** Manual `ln -s` (not managed by config)

---

## Relationship with Workspace

This NixOS config is **part of** `my-modular-workspace`:

```
my-modular-workspace/
├── hosts/shoshin/nixos/       # This repo (separate git)
├── home-manager/              # Separate home-manager repo
├── ansible/                   # Ansible automation
└── docs/                      # Workspace-level docs
```

**Separation Strategy:**
- **NixOS config** - System-level settings
- **Home-manager** - User packages and dotfiles (separate repo)
- **Ansible** - Bootstrap and multi-machine orchestration

---

## Key Files Explained

### `flake.nix`
- Defines all dependencies (inputs)
- Declares system configurations (outputs)
- Sets up pre-commit hooks and dev shell
- **Don't edit manually** - Use Nix functions

### `configuration.nix`
- Legacy compatibility file
- Imports `hosts/shoshin/configuration.nix`
- Exists for non-flake tools

### `modules/common.nix`
- **Most edited file** - common packages, system settings
- If something should be on ALL machines, put it here
- Split into sections: packages, networking, environment

### `home/mitsio/home.nix`
- User-level packages (not system-wide)
- Activation scripts (runs on rebuild)
- User services and timers
- Application configs

---

## Module Design Principles

### 1. **Single Responsibility**
Each module has ONE purpose:
- ✅ `audio.nix` - Only audio configuration
- ❌ `desktop.nix` - Too broad (split into workspace/*.nix)

### 2. **Self-Contained**
Modules should be independently removable:
- Disable by commenting out import
- No hidden dependencies between modules

### 3. **Declarative**
Prefer declarative options over imperative scripts:
- ✅ `services.pipewire.enable = true;`
- ❌ `system.activationScripts.setupAudio = "..."`

### 4. **Documented**
Every complex module should have:
- Purpose comment at top
- Source/reference links
- Why decisions were made

---

## Special Configurations

### Pre-commit Hooks (`git-hooks.nix`)
- **Configured in:** `flake.nix` (checks output)
- **Installed by:** `nix develop` (auto-installs on first shell entry)
- **Runs:** alejandra, statix, deadnix, merge conflict checks
- **Config file:** `.pre-commit-config.yaml` (auto-generated, gitignored)

### Plasma Manager (Declarative KDE)
- **Module:** `plasma-manager` (from nix-community)
- **Config:** `modules/workspace/plasma.nix` + `home/mitsio/plasma.nix`
- **Replaces:** Manual KDE settings (95% declarative)
- **Limitations:** Some settings still need manual config (noted in files)

### MCP Servers (Model Context Protocol)
- **Module:** `modules/development/mcp-servers.nix`
- **Purpose:** Claude Desktop and VSCode MCP configurations
- **Limits:** `modules/development/mcp-limits.nix` (prevent OOM)

---

## Migration Patterns

### Adding a New Module

1. Create file: `modules/category/feature.nix`
2. Add imports in `hosts/shoshin/configuration.nix`:
   ```nix
   imports = [
     ../../modules/category/feature.nix
   ];
   ```
3. Test: `sudo nixos-rebuild test --flake .#shoshin`
4. Commit when working

### Splitting a Large Module

If a module grows too large (>300 lines):
1. Create subdirectory: `modules/category/feature/`
2. Split into logical pieces: `default.nix`, `packages.nix`, `services.nix`
3. Import `default.nix` which imports the rest

### Moving to Separate Host

To make a module host-specific:
1. Move from `modules/` to `hosts/shoshin/modules/`
2. Update import path
3. Document why it's host-specific

---

## Future Architecture Plans

### Multi-Host Support

When adding laptop:
1. Create `hosts/laptop/configuration.nix`
2. Reuse `modules/common.nix` (shared)
3. Add `modules/laptop-specific/` for laptop-only features
4. Add to `flake.nix`:
   ```nix
   nixosConfigurations.laptop = nixpkgs.lib.nixosSystem { ... };
   ```

### Home-Manager Convergence

Eventually merge home-manager configs:
- Move `home-manager/` repo contents here
- Single source of truth
- Unified rebuild command

---

## Troubleshooting

### Config doesn't rebuild?
- Check syntax: `nix flake check`
- See errors: `sudo nixos-rebuild switch --show-trace`

### Module not loading?
- Verify import in `hosts/shoshin/configuration.nix`
- Check for typos in module path

### Hooks blocking commit?
- See errors: `nix develop -c pre-commit run --all-files`
- Fix issues or commit with `SKIP=hook-name git commit`

---

## References

- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Flakes: https://nixos.wiki/wiki/Flakes
- Plasma Manager: https://github.com/nix-community/plasma-manager
- Git-hooks.nix: https://github.com/cachix/git-hooks.nix

**Last Revised:** 2025-11-23
