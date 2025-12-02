# Chezmoi Overview

**Last Updated:** 2025-11-17
**Purpose:** Understanding chezmoi for dotfile management

---

## What is Chezmoi?

Chezmoi is a powerful dotfile manager that helps you **securely manage personal configuration files** across multiple diverse machines. Unlike home-manager (which generates configs from Nix expressions), chezmoi **manages** your actual dotfiles with templating, secrets integration, and cross-platform support.

### Official Resources

- **Official Website:** https://www.chezmoi.io/
- **GitHub Repository:** https://github.com/twpayne/chezmoi
- **Documentation:** https://www.chezmoi.io/user-guide/
- **Quick Start:** https://www.chezmoi.io/quick-start

---

## Key Features

### 1. **Cross-Platform Support**
- Works on Linux, macOS, Windows, BSD
- Single tool for managing dotfiles across all systems
- Platform-specific configurations using templates

### 2. **Templating System**
- Go template syntax for dynamic content
- Machine-specific configurations (hostname, OS, arch)
- Conditional includes based on platform

```go-template
# Example: Platform-specific PATH
{{- if eq .chezmoi.os "darwin" }}
export PATH="/opt/homebrew/bin:$PATH"
{{- else if eq .chezmoi.os "linux" }}
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
{{- end }}
```

### 3. **Secrets Management**
Integrates with multiple password managers:
- **1Password** (CLI integration)
- **Bitwarden** / **Vaultwarden**
- **KeePassXC**
- **pass** (Unix password manager)
- **Keychain** (macOS)
- **HashiCorp Vault**
- **age** encryption

```go-template
# Example: Retrieve from Bitwarden
[user]
    email = {{ (bitwarden "item" "GitHub").login.username }}
    token = {{ (bitwarden "item" "GitHub").login.password }}
```

### 4. **Encryption**
- Built-in file encryption using **age** or **GPG**
- Encrypted files stored in Git repo
- Automatic decryption on apply

### 5. **File Management**
- Copies files (not symlinks by default)
- Preserves permissions, ownership
- Handles executable files, private files
- Supports exact directories (removes unmanaged files)

### 6. **External Resources**
Import files from:
- GitHub releases
- Archived tarballs
- Remote URLs
- Auto-refresh with configurable intervals

```toml
# Example: Import oh-my-zsh
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    stripComponents = 1
    refreshPeriod = "168h"
```

### 7. **Run Scripts**
Execute scripts during `chezmoi apply`:
- `run_once_*` - Run once per machine
- `run_onchange_*` - Run when script changes
- `run_before_*` / `run_after_*` - Ordering control

```bash
# Example: run_once_install-packages.sh
#!/bin/bash
# Install system packages if needed
```

### 8. **Git Integration**
- Source directory is a Git repository
- Track changes to dotfiles
- Push/pull configurations
- Version control for all configs

---

## Architecture

### Directory Structure

```
~/.local/share/chezmoi/          # Source directory (Git repo)
├── .chezmoi.toml.tmpl           # Config template
├── .chezmoiignore               # Ignore patterns
├── .chezmoiexternal.toml        # External resources
├── dot_bashrc                   # Managed ~/.bashrc
├── dot_gitconfig.tmpl           # Template for ~/.gitconfig
├── private_dot_ssh/             # Private directory (~/.ssh/)
│   ├── config
│   └── private_id_rsa.age       # Encrypted file
├── run_once_install.sh          # Run-once script
└── .chezmoidata/                # Template data files
    └── packages.yaml
```

### File Naming Convention

Chezmoi uses prefixes to encode file attributes:

| Prefix | Meaning | Example | Target |
|--------|---------|---------|--------|
| `dot_` | Dotfile | `dot_bashrc` | `~/.bashrc` |
| `private_` | 0600 perms | `private_dot_ssh` | `~/.ssh` (mode 0600) |
| `executable_` | Executable | `executable_script.sh` | `~/script.sh` (mode 0755) |
| `symlink_` | Symlink | `symlink_link.tmpl` | `~/link` → content |
| `exact_` | Exact dir | `exact_dot_config` | Remove unmanaged files |
| `.tmpl` | Template | `dot_gitconfig.tmpl` | Process as template |
| `.age` | Encrypted | `file.age` | Decrypt with age |

---

## How Chezmoi Works

### Workflow

```
1. Source State (Git repo)
   ~/.local/share/chezmoi/
   ↓
2. Chezmoi Processing
   - Apply templates
   - Decrypt files
   - Fetch externals
   ↓
3. Target State (Computed)
   What files should look like
   ↓
4. Destination State (Actual)
   Your home directory
```

### Common Commands

```bash
# Initialize chezmoi with remote repo
chezmoi init --apply https://github.com/username/dotfiles.git

# Add a file to chezmoi
chezmoi add ~/.bashrc

# Add as template
chezmoi add --template ~/.gitconfig

# Edit a managed file
chezmoi edit ~/.bashrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Update from Git and apply
chezmoi update

# Git operations
chezmoi cd               # Enter source directory
chezmoi git add .
chezmoi git commit -m "Update configs"
chezmoi git push
exit
```

---

## Comparison: Chezmoi vs Home-Manager

| Feature | Chezmoi | Home-Manager |
|---------|---------|--------------|
| **Philosophy** | Manage actual dotfiles | Generate configs from Nix |
| **Approach** | Imperative + templates | Declarative Nix expressions |
| **Cross-platform** | ✅ Linux, macOS, Windows, BSD | ❌ Nix-only (Linux, macOS) |
| **Secrets** | Multiple password managers | sops-nix, agenix |
| **Templates** | Go templates | Nix expressions |
| **File handling** | Copy files (customizable) | Symlinks to Nix store |
| **Learning curve** | Moderate | Steep (Nix language) |
| **State** | Stateful (actual files) | Immutable (Nix store) |
| **Package management** | Separate (Homebrew, nix, etc.) | Integrated (home.packages) |
| **Git repo** | Your dotfiles directly | Nix expressions |
| **Migration** | Easy (works anywhere) | Tied to Nix ecosystem |

---

## Why Use Chezmoi with NixOS?

### Use Cases for Chezmoi on NixOS

1. **Preparing for Fedora Migration**
   - Decouple home configs from NixOS
   - Test configs independently
   - Smooth transition path

2. **Cross-Platform Configs**
   - Share dotfiles between NixOS and non-Nix systems
   - Same tool on work laptop (macOS) and home (NixOS)

3. **Simpler Home Configs**
   - Not everything needs to be in Nix
   - Editor configs, shell aliases, etc.
   - Easier for others to understand

4. **Secrets Management**
   - Better integration with Bitwarden/1Password
   - More password manager options
   - Simpler secret workflow

5. **Testing & Development**
   - Quickly test config changes
   - No home-manager rebuild needed
   - Instant apply

### Hybrid Approach (Recommended)

```
NixOS System:
├── System config (NixOS)
│   └── /etc/nixos/configuration.nix
├── System packages (NixOS)
│   └── environment.systemPackages
├── User environment (Home-Manager)
│   └── Basic packages, services
└── Dotfiles (Chezmoi)
    └── Application configs, secrets
```

**Benefits:**
- System reproducibility via NixOS
- Package management via Nix
- Dotfile flexibility via Chezmoi
- Easy migration to Fedora later

---

## Quick Start Example

```bash
# Install chezmoi
nix-shell -p chezmoi

# Or via home-manager
programs.chezmoi.enable = true;

# Initialize with GitHub repo
chezmoi init https://github.com/dtsioumas/dotfiles.git

# See what would change
chezmoi diff

# Apply configurations
chezmoi apply -v

# Add new file
chezmoi add ~/.config/alacritty/alacritty.yml

# Edit managed file
chezmoi edit ~/.bashrc

# Commit changes
chezmoi cd
git add .
git commit -m "Update bashrc"
git push
exit
```

---

## Key Advantages

### ✅ **Portability**
Works on any system, not just Nix

### ✅ **Simplicity**
Manage actual files, not Nix expressions

### ✅ **Secrets Integration**
First-class support for password managers

### ✅ **Templates**
Platform-specific configs made easy

### ✅ **Git Native**
Your dotfiles are directly in Git

### ✅ **No Rebuild**
Instant config changes

---

## Important Concepts

### 1. **Source vs Target vs Destination**
- **Source:** Files in `~/.local/share/chezmoi/` (Git repo)
- **Target:** Computed state after templates/decryption
- **Destination:** Actual files in `~/` (your home)

### 2. **State Management**
Chezmoi tracks state in `~/.local/share/chezmoi/.chezmoi.<format>.tmpl`

### 3. **Data Variables**
Define in `~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
    email = "dtsioumas0@gmail.com"
    editor = "nvim"
```

Use in templates:
```go-template
email = {{ .email }}
```

---

## Next Steps

1. Read **02-migration-strategy.md** for migrating from home-manager
2. Read **03-implementation-guide.md** for hands-on setup
3. Check **04-best-practices.md** for tips and patterns

---

## Resources

- [Official Docs](https://www.chezmoi.io/)
- [GitHub Repo](https://github.com/twpayne/chezmoi)
- [Quick Start Guide](https://www.chezmoi.io/quick-start)
- [User Guide](https://www.chezmoi.io/user-guide/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
