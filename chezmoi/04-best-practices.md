# Chezmoi Best Practices & Patterns

**Last Updated:** 2025-11-17
**Purpose:** Optimization tips, patterns, and lessons learned

---

## Repository Organization

### Recommended Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # Config template (interactive setup)
├── .chezmoiignore                  # Global ignore patterns
├── .chezmoiexternal.toml           # External resources
├── .chezmoiversion                 # Required chezmoi version
│
├── .chezmoidata/                   # Template data files
│   ├── packages.yaml               # Package lists
│   ├── colors.yaml                 # Color schemes
│   └── machines.yaml               # Machine-specific data
│
├── .chezmoitemplates/              # Shared templates
│   ├── colors.conf                 # Color template
│   └── helpers.tmpl                # Helper functions
│
├── .chezmoiscripts/                # Reusable scripts
│   └── common-functions.sh         # Shared functions
│
├── run_once_before_*.sh.tmpl       # Pre-install scripts
├── run_once_after_*.sh.tmpl        # Post-install scripts
├── run_onchange_*.sh.tmpl          # Change-triggered scripts
│
├── dot_bashrc.tmpl                 # Shell config
├── dot_gitconfig.tmpl              # Git config
├── dot_tmux.conf                   # Tmux config
│
├── private_dot_ssh/                # SSH directory (0700)
│   ├── config.tmpl                 # SSH config
│   └── private_id_ed25519.age      # Encrypted key
│
├── dot_config/                     # XDG config directory
│   ├── nvim/                       # Neovim config
│   ├── alacritty/
│   │   └── alacritty.yml.tmpl      # Terminal config
│   └── exact_systemd/              # Exact directory
│       └── user/
│           └── service.service     # User services
│
├── dot_local/
│   ├── bin/                        # User binaries
│   └── share/
│
├── README.md                       # Documentation
├── MIGRATION.md                    # Migration guide
└── LICENSE                         # License file
```

---

## File Naming Best Practices

### Use Descriptive Prefixes

```bash
# ✅ Good: Clear intent
run_once_before_install-base-packages.sh
run_onchange_after_update-vim-plugins.sh

# ❌ Bad: Unclear
run_once_setup.sh
run_script.sh
```

### Ordering Scripts

Use numeric prefixes for execution order:

```bash
run_once_before_10_install-packages.sh
run_once_before_20_setup-directories.sh
run_once_before_30_configure-git.sh

run_once_after_10_install-vim-plugins.sh
run_once_after_20_setup-fonts.sh
```

### Template Suffix Strategy

```bash
# Template everything that might need customization
dot_bashrc.tmpl                    # Platform differences
dot_gitconfig.tmpl                 # User-specific data
dot_config/alacritty/alacritty.yml.tmpl  # OS-specific paths

# Don't template static configs
dot_tmux.conf                      # Same on all platforms
dot_config/nvim/init.lua           # No platform differences
```

---

## Template Patterns

### 1. Platform Detection

```go-template
# Detect OS
{{- if eq .chezmoi.os "linux" }}
# Linux-specific
{{- else if eq .chezmoi.os "darwin" }}
# macOS-specific
{{- else if eq .chezmoi.os "windows" }}
# Windows-specific
{{- end }}

# Detect distribution
{{- if eq .chezmoi.osRelease.id "nixos" }}
# NixOS-specific
{{- else if eq .chezmoi.osRelease.id "fedora" }}
# Fedora-specific
{{- else if eq .chezmoi.osRelease.id "ubuntu" }}
# Ubuntu-specific
{{- end }}

# Detect architecture
{{- if eq .chezmoi.arch "amd64" }}
# x86_64
{{- else if eq .chezmoi.arch "arm64" }}
# ARM64
{{- end }}
```

### 2. Machine-Specific Config

```yaml
# .chezmoidata/machines.yaml
machines:
  shoshin:
    type: desktop
    gpu: nvidia
    monitor_count: 2
    dpi: 96

  laptop:
    type: laptop
    gpu: intel
    monitor_count: 1
    dpi: 144
```

```go-template
# In template file
{{- $machine := index .machines .chezmoi.hostname }}
{{- if eq $machine.type "desktop" }}
# Desktop-specific config
font_size: 11
{{- else if eq $machine.type "laptop" }}
# Laptop-specific config (HiDPI)
font_size: 9
{{- end }}

{{- if eq $machine.gpu "nvidia" }}
# NVIDIA-specific
{{- end }}
```

### 3. Conditional Blocks

```go-template
# Only include if file exists
{{- if stat "/usr/bin/firefox" }}
export BROWSER=firefox
{{- end }}

# Only if environment variable set
{{- if env "DISPLAY" }}
# GUI-specific config
{{- end }}

# Check for command
{{- if lookPath "nvim" }}
export EDITOR=nvim
{{- else if lookPath "vim" }}
export EDITOR=vim
{{- else }}
export EDITOR=vi
{{- end }}
```

### 4. Shared Templates

Create reusable templates:

```go-template
# .chezmoitemplates/colors.conf
background = {{ .bg }}
foreground = {{ .fg }}
cursor = {{ .cursor }}
```

Use in other templates:

```go-template
# dot_config/alacritty/alacritty.yml.tmpl
colors:
  primary:
{{- template "colors.conf" dict "bg" "#1e1e1e" "fg" "#d4d4d4" "cursor" "#d4d4d4" }}
```

### 5. Helper Functions

```go-template
# .chezmoitemplates/helpers.tmpl
{{- define "is_desktop" -}}
{{- $machine := index .machines .chezmoi.hostname -}}
{{- eq $machine.type "desktop" -}}
{{- end -}}

{{- define "has_gpu" -}}
{{- $machine := index .machines .chezmoi.hostname -}}
{{- ne $machine.gpu "none" -}}
{{- end -}}
```

Use in configs:

```go-template
{{- if template "is_desktop" . }}
# Desktop configuration
{{- end }}

{{- if template "has_gpu" . }}
# GPU-specific settings
{{- end }}
```

---

## Secrets Management Patterns

### 1. KeePassXC Structure

Organize entries logically:

```
MyVault/
├── Development/
│   ├── GitHub
│   │   ├── password: <token>
│   │   ├── username: dtsioumas
│   │   └── api_key: <key>
│   ├── GitLab
│   └── NPM
│
├── Services/
│   ├── AWS
│   │   ├── access_key_id: <id>
│   │   └── secret_access_key: <key>
│   ├── DigitalOcean
│   └── Cloudflare
│
└── Personal/
    ├── Email
    └── SSH
```

### 2. Template Usage

```go-template
# dot_gitconfig.tmpl
[user]
    name = {{ .name }}
    email = {{ .email }}

[github]
    user = {{ keepassxcAttribute "Development/GitHub" "username" }}
    token = {{ keepassxcAttribute "Development/GitHub" "password" }}

[gitlab]
    user = {{ keepassxcAttribute "Development/GitLab" "username" }}
    token = {{ keepassxcAttribute "Development/GitLab" "password" }}
```

```bash
# dot_aws/credentials.tmpl
[default]
aws_access_key_id = {{ keepassxcAttribute "Services/AWS" "access_key_id" }}
aws_secret_access_key = {{ keepassxcAttribute "Services/AWS" "secret_access_key" }}
region = eu-west-1
```

### 3. Encrypted Files

For files that don't need templating but contain secrets:

```bash
# Add entire file encrypted
chezmoi add --encrypt ~/.ssh/id_ed25519
chezmoi add --encrypt ~/.gnupg/private.key

# Edit encrypted files
chezmoi edit ~/.ssh/id_ed25519
```

### 4. Mixed Approach

Combine templates and encryption:

```go-template
# private_dot_netrc.tmpl.age
# Encrypted template file

machine github.com
login {{ keepassxcAttribute "Development/GitHub" "username" }}
password {{ keepassxcAttribute "Development/GitHub" "password" }}

machine gitlab.com
login {{ keepassxcAttribute "Development/GitLab" "username" }}
password {{ keepassxcAttribute "Development/GitLab" "password" }}
```

---

## Package Management Patterns

### 1. Centralized Package Lists

```yaml
# .chezmoidata/packages.yaml
packages:
  base:
    - git
    - curl
    - wget
    - unzip
    - htop
    - tree

  shell:
    - zsh
    - bash-completion
    - fzf
    - ripgrep
    - fd-find
    - bat
    - eza

  development:
    - neovim
    - tmux
    - gcc
    - make
    - python3
    - nodejs
    - go

  desktop:
    - alacritty
    - firefox
    - keepassxc
    - rclone

  # Distribution-specific overrides
  fedora_specific:
    - dnf-plugins-core
    - fedora-workstation-repositories

  nixos_specific:
    - nix-index
    - comma
```

### 2. Smart Install Scripts

```bash
# run_once_before_install-packages.sh.tmpl
{{- if eq .chezmoi.osRelease.id "nixos" }}
#!/bin/bash
# NixOS: Inform user to update configuration.nix
cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║                     NIXOS PACKAGES                         ║
╚════════════════════════════════════════════════════════════╝

Add these packages to configuration.nix or home.nix:

Base packages:
{{- range .packages.base }}
  - {{ . }}
{{- end }}

Development:
{{- range .packages.development }}
  - {{ . }}
{{- end }}

EOF
exit 0
{{- end }}

{{- if eq .chezmoi.osRelease.id "fedora" }}
#!/bin/bash
set -euo pipefail

echo "Installing packages on Fedora..."

# Base packages
sudo dnf install -y \
{{- range .packages.base }}
    {{ . }} \
{{- end }}

# Shell tools
sudo dnf install -y \
{{- range .packages.shell }}
    {{ . }} \
{{- end }}

# Development tools
sudo dnf install -y \
{{- range .packages.development }}
    {{ . }} \
{{- end }}

# Fedora-specific
sudo dnf install -y \
{{- range .packages.fedora_specific }}
    {{ . }} \
{{- end }}

echo "✓ Package installation complete!"
{{- end }}
```

### 3. Conditional Package Install

```bash
# run_once_install-optional-packages.sh.tmpl
#!/bin/bash

{{- if template "is_desktop" . }}
# Desktop packages
sudo dnf install -y \
{{- range .packages.desktop }}
    {{ . }} \
{{- end }}
{{- end }}

{{- $machine := index .machines .chezmoi.hostname }}
{{- if eq $machine.gpu "nvidia" }}
# NVIDIA packages
sudo dnf install -y \
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda
{{- end }}
```

---

## External Resources Patterns

### 1. Version Pinning

```toml
# .chezmoiexternal.toml
{{- $nvimVersion := "v0.9.5" }}
{{- $ageVersion := "v1.1.1" }}

# Neovim AppImage (Linux)
{{- if eq .chezmoi.os "linux" }}
[".local/bin/nvim"]
    type = "file"
    url = "https://github.com/neovim/neovim/releases/download/{{ $nvimVersion }}/nvim.appimage"
    executable = true
    refreshPeriod = "720h"
{{- end }}

# Age binary
[".local/bin/age"]
    type = "archive-file"
    url = "https://github.com/FiloSottile/age/releases/download/{{ $ageVersion }}/age-{{ $ageVersion }}-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz"
    executable = true
    path = "age/age"
    refreshPeriod = "720h"
```

### 2. Plugin Management

```toml
# Vim plugins
[".vim/pack/plugins/start/vim-airline"]
    type = "archive"
    url = "https://github.com/vim-airline/vim-airline/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"

# Oh-My-Zsh
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"

# Zsh plugins
[".oh-my-zsh/custom/plugins/zsh-autosuggestions"]
    type = "archive"
    url = "https://github.com/zsh-users/zsh-autosuggestions/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
```

### 3. Configuration Files from URLs

```toml
# Fetch remote configs
[".config/starship.toml"]
    type = "file"
    url = "https://raw.githubusercontent.com/starship/starship/master/docs/public/presets/toml/nerd-font-symbols.toml"
    refreshPeriod = "720h"
```

---

## Run Script Patterns

### 1. Idempotent Scripts

Always check before installing:

```bash
#!/bin/bash
# run_once_install-rust.sh

# Exit if already installed
if command -v cargo &> /dev/null; then
    echo "✓ Rust already installed"
    exit 0
fi

# Install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "✓ Rust installed successfully"
```

### 2. Change Detection

Use `run_onchange_` with checksums:

```bash
# run_onchange_before_update-vim-plugins.sh.tmpl
#!/bin/bash
# This script runs when package list changes

# Package list checksum: {{ include ".chezmoidata/packages.yaml" | sha256sum }}

echo "Updating vim plugins..."
vim +PlugUpdate +qall
echo "✓ Plugins updated"
```

### 3. Error Handling

```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

# Main logic with error handling
log "Starting setup..."

command -v git &> /dev/null || error "git not found"
command -v curl &> /dev/null || error "curl not found"

log "✓ Prerequisites met"

# Do work...

log "✓ Setup complete"
```

### 4. Interactive vs Non-Interactive

```bash
#!/bin/bash
# run_once_setup-git.sh.tmpl

{{- if .is_interactive }}
# Interactive mode: Prompt for input
read -p "Enter your Git username: " git_user
read -p "Enter your Git email: " git_email

git config --global user.name "$git_user"
git config --global user.email "$git_email"
{{- else }}
# Non-interactive: Use template data
git config --global user.name "{{ .name }}"
git config --global user.email "{{ .email }}"
{{- end }}
```

---

## Performance Optimization

### 1. Minimize Template Execution

```go-template
# ❌ Bad: Executes command every time
{{- if output "which" "firefox" }}
export BROWSER=firefox
{{- end }}

# ✅ Good: Use lookPath (cached)
{{- if lookPath "firefox" }}
export BROWSER=firefox
{{- end }}
```

### 2. Cache Expensive Operations

```go-template
# Cache git branch in variable
{{- $gitBranch := output "git" "branch" "--show-current" | trim }}

# Use multiple times without re-executing
Current branch: {{ $gitBranch }}
Prompt: ({{ $gitBranch }}) $
```

### 3. Conditional File Inclusion

```bash
# .chezmoiignore
# Don't manage large directories on laptops
{{- if eq .chezmoi.hostname "laptop" }}
Videos/
Downloads/large-files/
{{- end }}
```

### 4. Lazy External Updates

```toml
# Set longer refresh periods for stable resources
[".oh-my-zsh"]
    type = "archive"
    url = "..."
    refreshPeriod = "720h"  # Monthly instead of weekly
```

---

## Testing & Validation

### 1. Dry Run Everything

```bash
# Before applying
chezmoi apply --dry-run --verbose

# Check specific changes
chezmoi diff ~/.bashrc
```

### 2. Template Testing

```bash
# Test template execution
chezmoi execute-template < $(chezmoi source-path)/dot_bashrc.tmpl

# Test with different data
echo 'OS: {{ .chezmoi.os }}' | chezmoi execute-template
```

### 3. VM Testing

```bash
# Test on NixOS VM
nixos-rebuild build-vm --flake .#test-vm

# Boot VM and test chezmoi
./result/bin/run-test-vm-vm

# Inside VM:
chezmoi init --apply git@github.com:dtsioumas/dotfiles.git
```

### 4. Validation Scripts

```bash
# run_after_validate-setup.sh
#!/bin/bash

errors=0

# Check required commands
for cmd in git nvim tmux; do
    if ! command -v $cmd &> /dev/null; then
        echo "✗ Missing: $cmd"
        ((errors++))
    fi
done

# Check files exist
for file in ~/.bashrc ~/.gitconfig; do
    if [[ ! -f $file ]]; then
        echo "✗ Missing: $file"
        ((errors++))
    fi
done

if [[ $errors -eq 0 ]]; then
    echo "✓ Validation passed"
    exit 0
else
    echo "✗ Validation failed with $errors errors"
    exit 1
fi
```

---

## Migration-Specific Patterns

### 1. Gradual Migration Marker

```yaml
# .chezmoidata/migration.yaml
migration:
  phase: 2  # Current migration phase
  complete: false

  migrated:
    - bashrc
    - gitconfig
    - nvim

  pending:
    - tmux
    - alacritty
    - ssh
```

Use in templates:

```go-template
{{- if has "bashrc" .migration.migrated }}
# Managed by chezmoi
{{- else }}
# Still managed by home-manager
{{- end }}
```

### 2. Compatibility Layer

```bash
# dot_bashrc.tmpl
# Support both NixOS and Fedora

{{- if eq .chezmoi.osRelease.id "nixos" }}
# NixOS paths
export NIX_PATH="$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH"
{{- end }}

{{- if eq .chezmoi.osRelease.id "fedora" }}
# Fedora paths
export PATH="$HOME/.local/bin:$PATH"
{{- end }}

# Common configuration (works on both)
export EDITOR="{{ .editor }}"
export VISUAL="$EDITOR"

# Aliases (platform-agnostic)
alias ll='ls -lah'
alias vim='$EDITOR'
```

### 3. Feature Flags

```toml
# ~/.config/chezmoi/chezmoi.toml
[data]
    # Feature flags for gradual rollout
    use_chezmoi_git = true
    use_chezmoi_nvim = true
    use_chezmoi_shell = false  # Still using home-manager
```

```go-template
{{- if .use_chezmoi_shell }}
# Chezmoi-managed shell config
{{- else }}
# Fallback to home-manager
{{- end }}
```

---

## Security Best Practices

### 1. Never Commit Secrets

```bash
# .gitignore in source directory
key.txt
*.key
*.pem
secrets/
```

### 2. Use age for Everything Sensitive

```bash
# SSH keys
chezmoi add --encrypt ~/.ssh/id_ed25519

# GPG keys
chezmoi add --encrypt ~/.gnupg/private-keys-v1.d/*

# API tokens (if not in KeePassXC)
chezmoi add --encrypt ~/.config/hub/config
```

### 3. Audit Before Commit

```bash
# Check what's being added
chezmoi cd
git status
git diff --cached

# Look for potential secrets
git diff --cached | grep -i "password\|token\|secret\|key"

# If found, remove and add with encryption
git reset HEAD <file>
exit
chezmoi forget <file>
chezmoi add --encrypt <file>
```

### 4. Separate Public/Private Repos

```
dotfiles/           # Public repo
├── shell configs
├── editor configs
└── general configs

dotfiles-private/   # Private repo (or encrypted in main)
├── SSH keys
├── GPG keys
└── work configs
```

---

## Documentation Best Practices

### 1. README Structure

```markdown
# Dotfiles

Personal configuration files managed by [chezmoi](https://www.chezmoi.io/).

## Quick Start

```bash
chezmoi init --apply git@github.com:dtsioumas/dotfiles.git
```

## Requirements

- chezmoi
- age (for encryption)
- KeePassXC (for secrets)

## Secrets Management

Secrets stored in KeePassXC vault at `~/MyVault/mitsio_secrets.kdbx`.

Required entries:
- `Development/GitHub`
- `Development/GitLab`

## Platform Support

- NixOS (primary)
- Fedora (migration target)
- Linux (general)

## Structure

- `.chezmoidata/` - Template data
- `.chezmoitemplates/` - Shared templates
- `run_once_*` - Setup scripts

## License

MIT
```

### 2. Inline Documentation

```bash
# run_once_install-packages.sh.tmpl
#!/bin/bash
# Install base packages
#
# This script:
# - Detects the OS
# - Installs packages from .chezmoidata/packages.yaml
# - Skips already installed packages
#
# Runs once per machine.
```

### 3. Change Documentation

```bash
chezmoi cd
cat > CHANGELOG.md << 'EOF'
# Changelog

## 2025-11-17

- Initial chezmoi setup
- Migrated bashrc, gitconfig
- Setup KeePassXC integration
- Created install scripts

## 2025-11-18

- Added nvim config
- Created platform templates
- Setup age encryption
EOF
```

---

## Common Pitfalls to Avoid

### ❌ Don't:

1. **Hardcode paths**
   ```bash
   # Bad
   export PATH="/home/mitso/.local/bin:$PATH"

   # Good
   export PATH="{{ .chezmoi.homeDir }}/.local/bin:$PATH"
   ```

2. **Forget to test templates**
   ```bash
   # Always test before applying
   chezmoi execute-template < file.tmpl
   ```

3. **Mix managed and unmanaged files**
   ```bash
   # Either manage with chezmoi OR home-manager, not both
   ```

4. **Commit encrypted keys**
   ```bash
   # Never add key.txt to Git
   echo "key.txt" >> .gitignore
   ```

5. **Use absolute paths in templates**
   ```bash
   # Bad
   source /home/mitso/.bashrc.d/aliases

   # Good
   source {{ .chezmoi.homeDir }}/.bashrc.d/aliases
   ```

### ✅ Do:

1. **Use variables**
2. **Test on fresh system**
3. **Document everything**
4. **Version your configs**
5. **Keep secrets secure**

---

## Maintenance Workflow

### Weekly

```bash
# Update external resources
chezmoi apply --refresh-externals

# Check for changes
chezmoi diff

# Update if needed
chezmoi update
```

### Monthly

```bash
# Review ignored files
chezmoi unmanaged

# Add missing configs
chezmoi add <new-file>

# Audit secrets
chezmoi cd
git log --all -- '*.age'
```

### Before Migration

```bash
# Full test
chezmoi apply --dry-run --verbose

# Backup current state
tar czf ~/backup-home-$(date +%Y%m%d).tar.gz ~

# Test in VM
# ... VM testing ...
```

---

## Summary

**Key Takeaways:**

1. ✅ **Organize logically** - Group related configs
2. ✅ **Template smartly** - Only what needs it
3. ✅ **Secure secrets** - KeePassXC + age encryption
4. ✅ **Test thoroughly** - Dry run, VM testing
5. ✅ **Document well** - Future you will thank you
6. ✅ **Version everything** - Git is your friend
7. ✅ **Automate carefully** - Idempotent scripts
8. ✅ **Migrate gradually** - Phase by phase

---

## Additional Resources

- [Chezmoi User Guide](https://www.chezmoi.io/user-guide/)
- [Chezmoi FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
- [Example Dotfiles](https://github.com/twpayne/dotfiles)
- [Community Examples](https://github.com/topics/chezmoi)

---

**Ready to Start?** Go to **02-migration-strategy.md** and begin Phase 1!
