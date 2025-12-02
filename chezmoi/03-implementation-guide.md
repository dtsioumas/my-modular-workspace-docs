# Chezmoi Implementation Guide

**Last Updated:** 2025-11-17
**Purpose:** Hands-on guide for setting up and using chezmoi on NixOS

---

## Prerequisites

### System Requirements

- NixOS installed and configured
- Git installed and configured
- GitHub account (or other Git hosting)
- KeePassXC vault (already setup at `~/MyVault/`)

### Install Chezmoi

Add to your NixOS config:

```nix
# ~/.config/nixos/home/mitso/home.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    chezmoi
    age           # For encryption
    keepassxc     # For secrets
  ];
}
```

Apply:
```bash
sudo nixos-rebuild switch
```

Verify installation:
```bash
chezmoi --version
```

---

## Initial Setup

### 1. Create GitHub Repository

```bash
# Using GitHub CLI (recommended)
gh repo create dotfiles --private --description "Personal dotfiles managed by chezmoi"

# Or create manually at: https://github.com/new
# Name: dotfiles
# Visibility: Private
# Don't initialize with README
```

### 2. Initialize Chezmoi

```bash
# Initialize with your GitHub repo
chezmoi init git@github.com:dtsioumas/dotfiles.git

# This creates:
# - ~/.local/share/chezmoi/ (Git repo)
# - Initializes Git with your remote
```

### 3. Configure Chezmoi

```bash
# Create config directory
mkdir -p ~/.config/chezmoi

# Create configuration file
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
# Chezmoi Configuration
# https://www.chezmoi.io/reference/configuration-file/

[data]
    # Personal information (used in templates)
    email = "dtsioumas0@gmail.com"
    name = "Dimitris Tsioumas"
    username = "dtsioumas"
    editor = "nvim"
    github_user = "dtsioumas"

[git]
    # Git settings for source directory
    autoCommit = false      # Manual commits for now
    autoPush = false        # Manual pushes for now

[diff]
    # Use nvim for diffs
    command = "nvim"
    args = ["-d"]

[merge]
    # Use nvim for merges
    command = "nvim"
    args = ["-d"]

[keepassxc]
    # KeePassXC integration
    database = "/home/mitso/MyVault/mitsio_secrets.kdbx"
    mode = "cli"

# Enable colored output
[color]
    enabled = true
EOF
```

---

## Working with Files

### Adding Files to Chezmoi

#### Add a Simple File

```bash
# Add your bashrc
chezmoi add ~/.bashrc

# Chezmoi creates:
# ~/.local/share/chezmoi/dot_bashrc
```

#### Add a Directory

```bash
# Add entire nvim config
chezmoi add --recursive ~/.config/nvim/

# Creates:
# ~/.local/share/chezmoi/dot_config/nvim/...
```

#### Add as Template

```bash
# Add git config as template
chezmoi add --template ~/.gitconfig

# Creates:
# ~/.local/share/chezmoi/dot_gitconfig.tmpl
```

#### Add Private File

```bash
# SSH config (will be mode 0600)
chezmoi add ~/.ssh/config

# Creates:
# ~/.local/share/chezmoi/private_dot_ssh/config
```

#### Add Encrypted File

```bash
# First setup age encryption (see Encryption section below)

# Add SSH private key with encryption
chezmoi add --encrypt ~/.ssh/id_ed25519

# Creates:
# ~/.local/share/chezmoi/private_dot_ssh/private_id_ed25519.age
```

### Editing Managed Files

```bash
# Edit using your $EDITOR
chezmoi edit ~/.bashrc

# This:
# 1. Opens ~/.local/share/chezmoi/dot_bashrc in editor
# 2. After saving, automatically runs `chezmoi apply`
# 3. Updates ~/.bashrc with changes
```

### Viewing Changes

```bash
# See what would change
chezmoi diff

# See specific file diff
chezmoi diff ~/.bashrc

# Show source path of managed file
chezmoi source-path ~/.bashrc
```

### Applying Changes

```bash
# Apply all pending changes
chezmoi apply

# Apply with verbose output
chezmoi apply -v

# Dry run (show what would change)
chezmoi apply --dry-run -v

# Apply specific file
chezmoi apply ~/.bashrc
```

---

## Templates

Templates allow platform-specific and machine-specific configurations.

### Basic Template Example

```bash
# Add git config as template
chezmoi add --template ~/.gitconfig

# Edit the template
chezmoi edit ~/.gitconfig
```

Content of `dot_gitconfig.tmpl`:
```gitconfig
[user]
    name = {{ .name }}
    email = {{ .email }}

[github]
    user = {{ .github_user }}

[core]
    editor = {{ .editor }}

{{- if eq .chezmoi.os "linux" }}
[credential]
    helper = libsecret
{{- else if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}
```

### Platform-Specific Template

```bash
# .bashrc.tmpl
# Common aliases
alias ll='ls -lah'
alias vim='{{ .editor }}'

{{- if eq .chezmoi.os "linux" }}
# Linux-specific
alias ls='ls --color=auto'
alias open='xdg-open'
{{- else if eq .chezmoi.os "darwin" }}
# macOS-specific
alias ls='ls -G'
{{- end }}

# NixOS-specific
{{- if eq .chezmoi.osRelease.id "nixos" }}
export NIX_PATH="$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH"
{{- end }}

# Fedora-specific
{{- if eq .chezmoi.osRelease.id "fedora" }}
export PATH="$HOME/.local/bin:$PATH"
{{- end }}
```

### Available Template Variables

```bash
# Show all available variables
chezmoi data

# Common variables:
# .chezmoi.os              → "linux", "darwin", "windows"
# .chezmoi.arch            → "amd64", "arm64"
# .chezmoi.hostname        → "shoshin"
# .chezmoi.username        → "mitso"
# .chezmoi.homeDir         → "/home/mitso"
# .chezmoi.osRelease.id    → "nixos", "fedora", "ubuntu"
```

### Testing Templates

```bash
# Execute template to see output
chezmoi execute-template < $(chezmoi source-path)/dot_bashrc.tmpl

# Or test specific template
cat > /tmp/test.tmpl <<'EOF'
OS: {{ .chezmoi.os }}
Distro: {{ .chezmoi.osRelease.id }}
Email: {{ .email }}
EOF

chezmoi execute-template < /tmp/test.tmpl
```

---

## Encryption with age

### Setup age

```bash
# Generate age key pair
age-keygen -o ~/.config/chezmoi/key.txt

# ⚠️ IMPORTANT: Backup this key securely!
# Without it, you cannot decrypt your files!
```

View your public key:
```bash
age-keygen -y ~/.config/chezmoi/key.txt
```

Add to chezmoi config:
```bash
cat >> ~/.config/chezmoi/chezmoi.toml <<EOF

# Encryption
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "$(age-keygen -y ~/.config/chezmoi/key.txt)"
EOF
```

### Encrypt Files

```bash
# Add SSH private key with encryption
chezmoi add --encrypt ~/.ssh/id_ed25519

# Add AWS credentials
mkdir -p ~/.aws
chezmoi add --encrypt ~/.aws/credentials

# Add any sensitive file
chezmoi add --encrypt ~/.netrc
```

### Encrypted File Location

```bash
# Encrypted files have .age extension
# Example: private_id_ed25519.age

# View source path
chezmoi source-path ~/.ssh/id_ed25519
# Output: ~/.local/share/chezmoi/private_dot_ssh/private_id_ed25519.age
```

### Working with Encrypted Files

```bash
# Edit encrypted file (decrypts, edits, re-encrypts)
chezmoi edit ~/.ssh/id_ed25519

# Decrypt and view
chezmoi cat ~/.ssh/id_ed25519

# Apply encrypted files
chezmoi apply ~/.ssh/id_ed25519
```

---

## Secrets Management with KeePassXC

### Prerequisites

Ensure KeePassXC entries exist with proper structure.

### Using KeePassXC in Templates

```bash
# Add git config as template
chezmoi add --template ~/.gitconfig

# Edit template
chezmoi edit ~/.gitconfig
```

Content with KeePassXC integration:
```gitconfig
[user]
    name = {{ .name }}
    email = {{ .email }}

[github]
    user = {{ .github_user }}
    # Retrieve token from KeePassXC
    token = {{ keepassxcAttribute "Development/GitHub" "password" }}

[gitlab]
    user = {{ .github_user }}
    token = {{ keepassxcAttribute "Development/GitLab" "password" }}
```

### KeePassXC Functions

```go-template
# Get password field
{{ keepassxc "entry/path" }}

# Get specific attribute
{{ keepassxcAttribute "entry/path" "attribute_name" }}

# Example attributes:
# - password
# - username
# - url
# - notes
# - custom_field_name
```

### Testing KeePassXC Integration

```bash
# Unlock your vault first via GUI or:
keepassxc-cli open ~/MyVault/mitsio_secrets.kdbx

# Then apply chezmoi configs
chezmoi apply -v

# Verify secrets were inserted
cat ~/.gitconfig | grep token
```

---

## External Files & Archives

Import external resources (oh-my-zsh, plugins, tools from GitHub).

### Configuration File

Create `.chezmoiexternal.toml`:
```bash
chezmoi cd
cat > .chezmoiexternal.toml <<'EOF'
# External resources configuration

# Oh-My-Zsh
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"  # Refresh weekly

# Zsh syntax highlighting plugin
[".oh-my-zsh/custom/plugins/zsh-syntax-highlighting"]
    type = "archive"
    url = "https://github.com/zsh-users/zsh-syntax-highlighting/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"

# Age binary (cross-platform example)
{{ $ageVersion := "1.1.1" -}}
[".local/bin/age"]
    type = "archive-file"
    url = "https://github.com/FiloSottile/age/releases/download/v{{ $ageVersion }}/age-v{{ $ageVersion }}-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz"
    executable = true
    path = "age/age"
    refreshPeriod = "720h"  # Monthly

# Starship prompt
{{ if eq .chezmoi.os "linux" -}}
[".local/bin/starship"]
    type = "file"
    url = "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
    executable = true
    refreshPeriod = "720h"
{{- end }}
EOF

exit
```

### Apply External Resources

```bash
# Apply and fetch externals
chezmoi apply -v

# Force refresh of external resources
chezmoi apply --refresh-externals
# or
chezmoi -R apply
```

---

## Run Scripts

Scripts that execute during `chezmoi apply`.

### Script Types

| Prefix | When Runs | Use Case |
|--------|-----------|----------|
| `run_once_` | Once per machine | Initial setup, package install |
| `run_onchange_` | When script changes | Config-dependent tasks |
| `run_before_` | Before apply | Pre-requisites |
| `run_after_` | After apply | Post-processing |

### Examples

#### Install Packages (run once)

```bash
chezmoi cd
cat > run_once_before_install-packages.sh.tmpl <<'EOF'
{{- if eq .chezmoi.osRelease.id "nixos" }}
#!/bin/bash
# NixOS: Packages managed by configuration.nix
echo "✓ NixOS packages managed via configuration.nix"
exit 0
{{- end }}

{{- if eq .chezmoi.osRelease.id "fedora" }}
#!/bin/bash
set -euo pipefail

echo "Installing packages on Fedora..."

# CLI tools
sudo dnf install -y \
    git \
    neovim \
    tmux \
    htop \
    ripgrep \
    fd-find \
    bat \
    fzf \
    age

# Development
sudo dnf install -y \
    golang \
    python3 \
    nodejs \
    docker

echo "✓ Package installation complete!"
{{- end }}
EOF

chmod +x run_once_before_install-packages.sh.tmpl
exit
```

#### Setup Directories (run once)

```bash
chezmoi cd
cat > run_once_setup-directories.sh <<'EOF'
#!/bin/bash
# Create necessary directories

mkdir -p ~/Projects
mkdir -p ~/Workspaces
mkdir -p ~/.local/bin
mkdir -p ~/.local/share

echo "✓ Directories created"
EOF

chmod +x run_once_setup-directories.sh
exit
```

#### Install Tool (onchange)

```bash
chezmoi cd
cat > run_onchange_install-fzf.sh.tmpl <<'EOF'
{{- if eq .chezmoi.os "linux" }}
#!/bin/bash
# Install fzf key bindings
# Runs when this script changes

if command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf key bindings..."
    /usr/share/doc/fzf/examples/install --key-bindings --completion --no-update-rc
    echo "✓ fzf configured"
fi
{{- end }}
EOF

chmod +x run_onchange_install-fzf.sh.tmpl
exit
```

---

## Ignoring Files

Create `.chezmoiignore`:
```bash
chezmoi cd
cat > .chezmoiignore <<'EOF'
# Always ignore
README.md
LICENSE
MIGRATION.md
.git/
.github/

# OS-specific ignores
{{- if eq .chezmoi.os "linux" }}
.DS_Store
Library/
{{- end }}

{{- if eq .chezmoi.os "darwin" }}
.config/systemd/
{{- end }}

# Distribution-specific
{{- if eq .chezmoi.osRelease.id "nixos" }}
# Don't manage these on NixOS (managed by Nix)
.nix-profile
.nix-defexpr
{{- end }}

{{- if eq .chezmoi.osRelease.id "fedora" }}
# Don't manage these on Fedora
.config/nixpkgs/
{{- end }}

# Machine-specific
{{- if ne .chezmoi.hostname "shoshin" }}
# Only manage on shoshin
.config/desktop-specific/
{{- end }}
EOF

exit
```

---

## Git Workflow

### Basic Workflow

```bash
# Make changes to managed files
chezmoi edit ~/.bashrc
chezmoi add ~/.new-config

# Review changes
chezmoi diff
chezmoi status

# Commit to source repo
chezmoi cd
git status
git add .
git commit -m "Update bashrc and add new config"
git push
exit
```

### Automated Workflow

Enable auto-commit and auto-push:
```bash
# Edit config
cat >> ~/.config/chezmoi/chezmoi.toml <<'EOF'

[git]
    autoCommit = true
    autoPush = true
EOF
```

Now changes are automatically committed and pushed:
```bash
chezmoi edit ~/.bashrc
# Automatically commits and pushes!
```

### Pulling Updates

```bash
# Pull latest changes and apply
chezmoi update

# Equivalent to:
# chezmoi cd && git pull && exit && chezmoi apply
```

---

## Verification & Testing

### Check Status

```bash
# Show managed files
chezmoi managed

# Show unmanaged files in home
chezmoi unmanaged

# Check what would change
chezmoi diff

# Verify specific file
chezmoi verify ~/.bashrc
```

### Test in Dry-Run Mode

```bash
# See what would happen without applying
chezmoi apply --dry-run --verbose

# Test specific file
chezmoi apply --dry-run ~/.gitconfig
```

### Dump Configuration

```bash
# Show all template data
chezmoi data

# Show computed state
chezmoi state dump

# Show source path
chezmoi source-path
```

---

## Common Workflows

### Daily Usage

```bash
# 1. Edit config
chezmoi edit ~/.bashrc

# 2. Review changes
chezmoi diff

# 3. Apply
chezmoi apply -v

# 4. Commit (if not auto)
chezmoi cd
git add .
git commit -m "Update bashrc"
git push
exit
```

### Adding New Machine

```bash
# On new machine:
# 1. Install chezmoi
sudo dnf install chezmoi  # or via Nix

# 2. Initialize from repo
chezmoi init --apply git@github.com:dtsioumas/dotfiles.git

# 3. Done! Configs are applied
```

### Migrating to Fedora

```bash
# 1. Fresh Fedora install
# 2. Install base tools
sudo dnf install git age keepassxc

# 3. Setup SSH keys temporarily
# (Or use HTTPS for initial clone)

# 4. Clone and apply dotfiles
chezmoi init --apply git@github.com:dtsioumas/dotfiles.git

# 5. Run install scripts execute automatically
# 6. Setup KeePassXC and unlock vault
# 7. Re-apply to populate secrets
chezmoi apply -v
```

---

## Troubleshooting

### Reset Everything

```bash
# Purge chezmoi state
chezmoi purge

# Remove source directory
rm -rf ~/.local/share/chezmoi

# Re-initialize
chezmoi init --apply git@github.com:dtsioumas/dotfiles.git
```

### Fix Permissions Issues

```bash
# Re-apply with correct permissions
chezmoi apply --force

# Check file attributes
chezmoi chattr ~/.ssh/config
```

### Debug Templates

```bash
# Show template execution
chezmoi execute-template < $(chezmoi source-path)/dot_bashrc.tmpl

# Show all data
chezmoi data

# Verbose apply
chezmoi apply -v --debug
```

### KeePassXC Not Working

```bash
# Verify database path
cat ~/.config/chezmoi/chezmoi.toml | grep database

# Test keepassxc-cli
keepassxc-cli show ~/MyVault/mitsio_secrets.kdbx Development/GitHub

# Unlock vault first
keepassxc-cli open ~/MyVault/mitsio_secrets.kdbx
```

---

## Next Steps

1. Start with Phase 1 from **02-migration-strategy.md**
2. Add simple configs first (bashrc, gitconfig)
3. Test thoroughly before migrating complex configs
4. Read **04-best-practices.md** for optimization tips

---

## Quick Reference

```bash
# Essential Commands
chezmoi init <repo>              # Initialize with remote repo
chezmoi add <file>               # Add file to management
chezmoi edit <file>              # Edit managed file
chezmoi apply                    # Apply changes
chezmoi diff                     # Show pending changes
chezmoi update                   # Pull and apply
chezmoi cd                       # Enter source directory

# Git Operations
chezmoi git add .
chezmoi git commit -m "message"
chezmoi git push

# Inspection
chezmoi managed                  # List managed files
chezmoi data                     # Show template data
chezmoi source-path <file>       # Show source location
chezmoi cat <file>               # Show target content

# Advanced
chezmoi execute-template         # Test templates
chezmoi apply --dry-run -v       # Preview changes
chezmoi --refresh-externals      # Update external resources
```

---

## Resources

- [Official Documentation](https://www.chezmoi.io/)
- [User Guide](https://www.chezmoi.io/user-guide/)
- [Command Reference](https://www.chezmoi.io/reference/commands/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
