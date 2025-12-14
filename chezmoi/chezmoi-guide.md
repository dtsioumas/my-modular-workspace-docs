# Chezmoi Comprehensive Guide

**Last Updated:** 2025-12-14
**Purpose:** Complete guide for chezmoi dotfile management on NixOS
**Consolidated from:** 01-07 guides, research findings, symlink setup

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Setup & Installation](#setup--installation)
4. [Working with Files](#working-with-files)
5. [Templates](#templates)
6. [Secrets Management](#secrets-management)
7. [Migration Strategy](#migration-strategy)
8. [Tool Migration Guides](#tool-migration-guides)
9. [Best Practices](#best-practices)
10. [Symlink Setup](#symlink-setup)
11. [Troubleshooting](#troubleshooting)

---

## Overview

### What is Chezmoi?

Chezmoi is a powerful dotfile manager that **securely manages personal configuration files** across multiple machines. Unlike home-manager (which generates configs from Nix expressions), chezmoi **manages** your actual dotfiles with templating, secrets integration, and cross-platform support.

### Key Features

| Feature | Description |
|---------|-------------|
| **Cross-Platform** | Linux, macOS, Windows, BSD support |
| **Templating** | Go templates for dynamic content |
| **Encryption** | age/GPG encryption for secrets |
| **KeePassXC** | Direct password manager integration |
| **External Resources** | Import from GitHub, archives, URLs |
| **Run Scripts** | Automated setup scripts |

### Naming Convention

Chezmoi uses **prefix-based naming** to encode file attributes:

| Source File | Target File | Explanation |
|------------|-------------|-------------|
| `dot_bashrc` | `~/.bashrc` | `dot_` = dotfile |
| `dot_bashrc.tmpl` | `~/.bashrc` | `.tmpl` = template |
| `private_dot_ssh/config` | `~/.ssh/config` (0600) | `private_` = 0600 |
| `executable_script.sh` | `~/script.sh` (0755) | `executable_` |
| `private_id.age` | `~/.ssh/id` | `.age` = encrypted |
| `exact_dot_config` | `~/.config/` | `exact_` = remove unmanaged |
| `modify_*` | (modifies existing) | Runs script to modify |

### Official Resources

- **Website:** https://www.chezmoi.io/
- **GitHub:** https://github.com/twpayne/chezmoi
- **Documentation:** https://www.chezmoi.io/user-guide/
- **Quick Start:** https://www.chezmoi.io/quick-start

---

## Architecture

### Hybrid Approach (Recommended)

```
System Management
├── NixOS (System level)
│   └── /etc/nixos/configuration.nix
│       - System packages, services, hardware
│
├── Home-Manager (Minimal)
│   └── home.nix
│       - Systemd user services
│       - Nix-specific integration
│       - Package management
│
└── Chezmoi (Dotfiles)
    └── ~/.local/share/chezmoi/
        - Application configs
        - Shell configs
        - Secrets (encrypted)
```

### Decision Criteria (ADR-005)

**Use Chezmoi when:**
- Cross-platform compatibility needed
- Simple config files (ini, toml, yaml, json)
- Application settings only (not packages/services)
- Template benefits apply (machine-specific values)

**Use Home-Manager when:**
- Package management required
- Systemd services involved
- Nix-specific features used
- System integration needed

---

## Setup & Installation

### Prerequisites

```nix
# home.nix
home.packages = with pkgs; [
  chezmoi
  age           # For encryption
  keepassxc     # For secrets
];
```

### Initialize Chezmoi

```bash
# Initialize with GitHub repo
chezmoi init git@github.com:dtsioumas/dotfiles.git

# Creates: ~/.local/share/chezmoi/
```

### Configure Chezmoi

```bash
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
[data]
    email = "dtsioumas0@gmail.com"
    name = "Dimitris Tsioumas"
    username = "dtsioumas"
    editor = "nvim"

[git]
    autoCommit = false
    autoPush = false

[keepassxc]
    database = "/home/mitsio/MyVault/mitsio_secrets.kdbx"
    mode = "cli"
EOF
```

---

## Working with Files

### Adding Files

```bash
# Simple file
chezmoi add ~/.bashrc

# As template
chezmoi add --template ~/.gitconfig

# Private file (0600)
chezmoi add ~/.ssh/config

# Encrypted
chezmoi add --encrypt ~/.ssh/id_ed25519

# Recursive directory
chezmoi add --recursive ~/.config/nvim/
```

### Editing & Applying

```bash
# Edit managed file
chezmoi edit ~/.bashrc

# View changes
chezmoi diff

# Apply changes
chezmoi apply -v

# Dry run
chezmoi apply --dry-run -v
```

### Git Workflow

```bash
chezmoi cd
git status
git add .
git commit -m "Update configs"
git push
exit
```

---

## Templates

### Basic Template

```go-template
# dot_gitconfig.tmpl
[user]
    name = {{ .name }}
    email = {{ .email }}

[core]
    editor = {{ .editor }}
```

### Platform Detection

```go-template
{{- if eq .chezmoi.os "linux" }}
# Linux
{{- else if eq .chezmoi.os "darwin" }}
# macOS
{{- end }}

{{- if eq .chezmoi.osRelease.id "nixos" }}
# NixOS-specific
{{- else if eq .chezmoi.osRelease.id "fedora" }}
# Fedora-specific
{{- end }}
```

### Available Variables

```bash
chezmoi data
# .chezmoi.os         → "linux", "darwin", "windows"
# .chezmoi.arch       → "amd64", "arm64"
# .chezmoi.hostname   → "shoshin"
# .chezmoi.username   → "mitsio"
# .chezmoi.homeDir    → "/home/mitsio"
# .chezmoi.osRelease.id → "nixos", "fedora"
```

### Testing Templates

```bash
chezmoi execute-template < $(chezmoi source-path)/dot_bashrc.tmpl
```

---

## Secrets Management

### Three-Tier Approach

1. **KeePassXC** - Source of truth for passwords/tokens
2. **Chezmoi Templates** - Dynamic secret insertion
3. **age Encryption** - Static encrypted files

### age Encryption Setup

```bash
# Generate key
age-keygen -o ~/.config/chezmoi/key.txt

# Add to config
cat >> ~/.config/chezmoi/chezmoi.toml <<EOF
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "$(age-keygen -y ~/.config/chezmoi/key.txt)"
EOF

# BACKUP KEY.TXT TO KEEPASSXC!
```

### Using age

```bash
# Add encrypted file
chezmoi add --encrypt ~/.ssh/id_ed25519

# Edit encrypted file
chezmoi edit ~/.ssh/id_ed25519

# View decrypted
chezmoi cat ~/.ssh/id_ed25519
```

### KeePassXC Templates

```go-template
# dot_gitconfig.tmpl
[github]
    token = {{ keepassxcAttribute "Development/GitHub" "password" }}
```

---

## Migration Strategy

### Phase Overview

| Phase | Focus | Duration |
|-------|-------|----------|
| 1 | Setup + simple configs | Week 1 |
| 2 | Editor + shell | Week 2 |
| 3 | Applications | Week 3-4 |
| 4 | Secrets | Week 4-5 |
| 5 | Packages | Week 5-6 |
| 6 | Cleanup | Week 6-7 |

### Migration Workflow

1. **Add to chezmoi:** `chezmoi add ~/.config/app/`
2. **Test:** `chezmoi diff && chezmoi apply --dry-run`
3. **Apply:** `chezmoi apply`
4. **Remove from home-manager** (if applicable)
5. **Verify:** Test application works
6. **Commit:** `chezmoi cd && git commit -am "Add app config"`

### Rollback Plan

```bash
# Restore from home-manager
sudo nixos-rebuild switch

# Reset chezmoi
chezmoi purge
rm -rf ~/.local/share/chezmoi
chezmoi init --apply git@github.com:dtsioumas/dotfiles.git
```

---

## Tool Migration Guides

### Git Configuration

```bash
chezmoi add --template ~/.gitconfig
chezmoi edit ~/.gitconfig
```

```gitconfig
# dot_gitconfig.tmpl
[user]
    name = {{ .name }}
    email = {{ .email }}

{{- if eq .chezmoi.os "linux" }}
[credential]
    helper = libsecret
{{- else if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}
```

### Kitty Terminal

```bash
chezmoi add --recursive ~/.config/kitty/
chezmoi add --template ~/.config/kitty/kitty.conf
```

### SSH Keys

```bash
chezmoi add ~/.ssh/config
chezmoi add --encrypt ~/.ssh/id_ed25519
chezmoi add ~/.ssh/id_ed25519.pub
```

### VSCodium/VSCode

```bash
chezmoi add ~/.config/VSCodium/User/settings.json
# Don't add extension cache or workspace files
```

---

## Best Practices

### Repository Structure

```
~/.local/share/chezmoi/
├── .chezmoiignore
├── .chezmoiexternal.toml
├── .chezmoidata/
│   └── packages.yaml
├── .chezmoitemplates/
│   └── helpers.tmpl
├── run_once_before_*.sh.tmpl
├── run_once_after_*.sh.tmpl
├── dot_bashrc.tmpl
├── dot_gitconfig.tmpl
├── private_dot_ssh/
│   └── config.tmpl
├── dot_config/
│   ├── kitty/
│   └── nvim/
└── README.md
```

### Security

1. **Never commit secrets** - Use encryption or KeePassXC
2. **Use age for sensitive files** - SSH keys, AWS creds
3. **Audit before commit** - `git diff --cached | grep -i token`
4. **Backup age key** - Store in KeePassXC

### Performance

- Use `lookPath` instead of `output "which"` in templates
- Set longer `refreshPeriod` for stable external resources
- Use `.chezmoiignore` for large/unnecessary files

---

## Symlink Setup

### Current Architecture

```
~/.local/share/chezmoi -> ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
```

**Benefits:**
- ✅ Work directly in workspace
- ✅ No duplication
- ✅ Git repo in workspace
- ✅ Consistent with workspace tools

### Setup Commands

```bash
# Backup existing
mv ~/.local/share/chezmoi ~/.local/share/chezmoi.backup

# Create symlink
ln -s ~/.MyHome/MySpaces/my-modular-workspace/dotfiles ~/.local/share/chezmoi

# Verify
ls -la ~/.local/share/chezmoi
chezmoi managed
```

---

## Troubleshooting

### Reset Everything

```bash
chezmoi purge
rm -rf ~/.local/share/chezmoi
chezmoi init --apply git@github.com:dtsioumas/dotfiles.git
```

### Debug Templates

```bash
chezmoi execute-template < file.tmpl
chezmoi data
chezmoi apply -v --debug
```

### KeePassXC Issues

```bash
# Verify database path
cat ~/.config/chezmoi/chezmoi.toml | grep database

# Test CLI access
keepassxc-cli show ~/MyVault/mitsio_secrets.kdbx Development/GitHub
```

### Broken Symlink

```bash
readlink -f ~/.local/share/chezmoi
# Re-create if needed
rm ~/.local/share/chezmoi
ln -s ~/.MyHome/MySpaces/my-modular-workspace/dotfiles ~/.local/share/chezmoi
```

---

## Quick Reference

```bash
# Essential Commands
chezmoi init <repo>              # Initialize
chezmoi add <file>               # Add file
chezmoi add --template <file>    # Add as template
chezmoi add --encrypt <file>     # Add encrypted
chezmoi edit <file>              # Edit managed file
chezmoi apply                    # Apply changes
chezmoi diff                     # Show pending changes
chezmoi update                   # Pull and apply
chezmoi cd                       # Enter source directory
chezmoi managed                  # List managed files
chezmoi data                     # Show template data
chezmoi source-path <file>       # Show source location

# Verification
chezmoi verify                   # Verify managed files
chezmoi status                   # Show status
chezmoi apply --dry-run -v       # Preview changes
```

---

## Related Documentation

- [MIGRATION_STATUS.md](MIGRATION_STATUS.md) - Current migration progress
- [DOTFILES_INVENTORY.md](DOTFILES_INVENTORY.md) - Complete inventory
- [ADR-005](../adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md) - Migration criteria

---

**Maintained by:** Dimitris Tsioumas
**Original Sources:** 01-07 guides, research findings
