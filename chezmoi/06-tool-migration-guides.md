# Chezmoi Tool Migration Guides

**Date:** 2025-11-18
**Purpose:** Practical guides for migrating specific tools to chezmoi

---

## Table of Contents

1. [Git Configuration](#git-configuration)
2. [Kitty Terminal](#kitty-terminal)
3. [SSH Keys & Secrets](#ssh-keys--secrets)
4. [htop/btop System Monitors](#htopbtop-system-monitors)
5. [VSCode/VSCodium](#vscodevscodium)
6. [General Tips](#general-tips)

---

## Git Configuration

### Current State

**Home-Manager Location:**
- Likely in `shell.nix` or inline in `home.nix`
- May have `programs.git.enable = true;`

### Migration Steps

**1. Add git config as template:**

```bash
# Add current git config as template
chezmoi add --template ~/.gitconfig
```

**2. Edit the template:**

```bash
chezmoi edit ~/.gitconfig
```

**3. Template content with platform-specific logic:**

```gitconfig
# ~/.local/share/chezmoi/dot_gitconfig.tmpl
[user]
    name = {{ .name }}
    email = {{ .email }}

[github]
    user = {{ .github_user }}

[core]
    editor = {{ .editor }}
    autocrlf = input

{{- if eq .chezmoi.os "linux" }}
[credential]
    helper = libsecret
{{- else if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}

# Platform-specific pager
{{- if eq .chezmoi.osRelease.id "nixos" }}
[core]
    pager = less
{{- else if eq .chezmoi.osRelease.id "fedora" }}
[core]
    pager = delta
{{- end }}

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = current
    autoSetupRemote = true

[alias]
    st = status
    ci = commit
    br = branch
    co = checkout
    df = diff
    lg = log --graph --oneline --decorate --all
```

**4. Apply and verify:**

```bash
# See what would change
chezmoi diff ~/.gitconfig

# Apply changes
chezmoi apply ~/.gitconfig

# Verify
git config --list --show-origin
```

**5. Commit to dotfiles:**

```bash
chezmoi cd
git add dot_gitconfig.tmpl
git commit -m "Add templated git configuration"
git push
exit
```

**6. Remove from Home-Manager** (after verification):

```nix
# Comment out or remove from home.nix or shell.nix
# programs.git = { ... };
```

---

## Kitty Terminal

### Current State

**Location:** `~/.config/kitty/kitty.conf`
**Home-Manager:** May have `programs.kitty` configuration

### Migration Steps

**1. Add kitty config directory:**

```bash
# Add entire kitty directory
chezmoi add --recursive ~/.config/kitty/
```

**2. Convert to template for platform differences:**

```bash
chezmoi add --template ~/.config/kitty/kitty.conf
chezmoi edit ~/.config/kitty/kitty.conf
```

**3. Template example:**

```conf
# ~/.local/share/chezmoi/dot_config/kitty/kitty.conf.tmpl

# Font configuration
{{- if eq .chezmoi.osRelease.id "nixos" }}
font_family FiraCode Nerd Font Mono
{{- else if eq .chezmoi.osRelease.id "fedora" }}
font_family FiraCode Nerd Font
{{- end }}
font_size 11.0

# Theme
{{- if eq .chezmoi.hostname "shoshin" }}
# Desktop - Dark theme
include ~/.config/kitty/theme-dark.conf
{{- else if eq .chezmoi.hostname "laptop" }}
# Laptop - Light theme
include ~/.config/kitty/theme-light.conf
{{- end }}

# Shell integration
shell_integration enabled

# Copy/paste
copy_on_select yes
```

**4. Test and apply:**

```bash
chezmoi diff
chezmoi apply ~/.config/kitty/
```

---

## SSH Keys & Secrets

### Encryption Strategy

**Two approaches:**

1. **age encryption** - For SSH private keys
2. **KeePassXC templates** - For passwords/tokens (future)

### SSH Key Migration

**1. Add SSH directory with encryption:**

```bash
# Add SSH config
chezmoi add ~/.ssh/config

# Add private keys with encryption (IMPORTANT!)
chezmoi add --encrypt ~/.ssh/id_ed25519
chezmoi add --encrypt ~/.ssh/id_rsa

# Public keys don't need encryption
chezmoi add ~/.ssh/id_ed25519.pub
```

**2. Verify encrypted storage:**

```bash
# Check source files
ls -la $(chezmoi source-path ~/.ssh/)

# Should see:
# private_dot_ssh/
#   ├── config
#   ├── private_id_ed25519.age    # Encrypted!
#   └── id_ed25519.pub
```

**3. Template SSH config for different machines:**

```bash
chezmoi add --template ~/.ssh/config
chezmoi edit ~/.ssh/config
```

```text
# ~/.local/share/chezmoi/private_dot_ssh/config.tmpl

# Personal GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes

{{- if eq .chezmoi.hostname "work-laptop" }}
# Work GitHub
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_work
{{- end }}

# Default settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    {{- if eq .chezmoi.os "darwin" }}
    UseKeychain yes
    {{- end }}
```

**4. Test secret retrieval:**

```bash
# View decrypted content (doesn't write to disk)
chezmoi cat ~/.ssh/id_ed25519

# Edit encrypted file
chezmoi edit ~/.ssh/id_ed25519
```

**5. CRITICAL: Backup age key:**

Store `~/.config/chezmoi/key.txt` in KeePassXC:
- Entry: "Development/Chezmoi"
- Field: "age_private_key"
- **Without this key, you cannot decrypt your secrets!**

---

## htop/btop System Monitors

### htop Configuration

**Location:** `~/.config/htop/htoprc`

**Migration:**

```bash
# Simple add (no templating needed)
chezmoi add ~/.config/htop/htoprc

# Apply
chezmoi apply
```

### btop Configuration

**Location:** `~/.config/btop/btop.conf`

**Migration with templates** (for theme differences):

```bash
chezmoi add --template ~/.config/btop/btop.conf
chezmoi edit ~/.config/btop/btop.conf
```

```conf
# ~/.local/share/chezmoi/dot_config/btop/btop.conf.tmpl

{{- if eq .chezmoi.hostname "shoshin" }}
# Desktop - detailed view
color_theme = "gruvbox_dark"
update_ms = 1000
{{- else if eq .chezmoi.hostname "laptop" }}
# Laptop - power-saving
color_theme = "gruvbox_light"
update_ms = 2000
{{- end }}

# Common settings
theme_background = True
truecolor = True
```

---

## VSCode/VSCodium

### What to Migrate

**Migrate:**
- ✅ `settings.json` - Editor settings
- ✅ `keybindings.json` - Keyboard shortcuts
- ✅ `snippets/` - Custom snippets

**Don't Migrate:**
- ❌ Extension state/cache
- ❌ Workspace files
- ❌ Session data

### Migration Steps

**1. Add VSCode settings:**

```bash
# VSCodium
chezmoi add --template ~/.config/VSCodium/User/settings.json
chezmoi add --template ~/.config/VSCodium/User/keybindings.json

# Or VSCode
chezmoi add --template ~/.config/Code/User/settings.json
```

**2. Template for platform differences:**

```json
// ~/.local/share/chezmoi/dot_config/VSCodium/User/settings.json.tmpl
{
  "editor.fontFamily": {{- if eq .chezmoi.osRelease.id "nixos" -}}
  "'FiraCode Nerd Font Mono'"
  {{- else -}}
  "'FiraCode Nerd Font'"
  {{- end }},

  "editor.fontSize": {{- if eq .chezmoi.hostname "laptop" -}}
  12
  {{- else -}}
  11
  {{- end }},

  "terminal.integrated.shell.linux": {{- if eq .chezmoi.osRelease.id "nixos" -}}
  "bash"
  {{- else if eq .chezmoi.osRelease.id "fedora" -}}
  "/usr/bin/bash"
  {{- end }},

  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/**": true
  }
}
```

**3. Extensions list (document, don't manage):**

```bash
# Create extensions list document
cat > $(chezmoi source-path)/../docs/vscode-extensions.md <<EOF
# VSCode Extensions

## Development
- GitHub.copilot
- ms-python.python
- golang.go

## Themes
- zhuangtongfa.material-theme

## Utilities
- eamodio.gitlens
- esbenp.prettier-vscode
EOF
```

---

## General Tips

### Template Variables to Use

```yaml
# Always available:
{{ .chezmoi.os }}              # "linux", "darwin", "windows"
{{ .chezmoi.osRelease.id }}    # "nixos", "fedora", "ubuntu"
{{ .chezmoi.hostname }}        # "shoshin", "laptop"
{{ .chezmoi.arch }}            # "amd64", "arm64"
{{ .chezmoi.username }}        # "mitsio"
{{ .chezmoi.homeDir }}         # "/home/mitsio"

# From chezmoi.toml [data]:
{{ .email }}                   # "dtsioumas0@gmail.com"
{{ .name }}                    # "Dimitris Tsioumas"
{{ .editor }}                  # "nvim"
{{ .github_user }}             # "dtsioumas"
```

### Testing Templates

```bash
# Test template output
chezmoi execute-template < $(chezmoi source-path)/dot_gitconfig.tmpl

# Show all template data
chezmoi data

# Dry run
chezmoi apply --dry-run --verbose
```

### Common Patterns

**1. OS-specific paths:**

```yaml
{{- if eq .chezmoi.os "linux" }}
path = "/usr/share/fonts"
{{- else if eq .chezmoi.os "darwin" }}
path = "/Library/Fonts"
{{- end }}
```

**2. Hostname-specific settings:**

```yaml
{{- if eq .chezmoi.hostname "shoshin" }}
# Desktop config
{{- else if eq .chezmoi.hostname "laptop" }}
# Laptop config
{{- end }}
```

**3. Distribution-specific:**

```yaml
{{- if eq .chezmoi.osRelease.id "nixos" }}
# NixOS-specific
{{- else if eq .chezmoi.osRelease.id "fedora" }}
# Fedora-specific
{{- end }}
```

### Workflow

**Daily usage:**

```bash
# 1. Edit config
chezmoi edit ~/.gitconfig

# 2. Review changes
chezmoi diff

# 3. Apply
chezmoi apply

# 4. Commit
chezmoi cd
git add .
git commit -m "Update gitconfig"
git push
exit
```

**Adding new configs:**

```bash
# Simple file
chezmoi add ~/.config/app/config.conf

# With template
chezmoi add --template ~/.bashrc

# With encryption
chezmoi add --encrypt ~/.ssh/id_ed25519
```

---

## Next Steps

1. **Start with Git** - Low risk, high value
2. **Add Kitty** - Terminal config
3. **Migrate SSH** - With encryption
4. **Add monitoring tools** - htop, btop
5. **VSCode settings** - Last (most complex)

See `02-migration-strategy.md` for the full 6-week migration plan.

---

**Research Sources:**
- chezmoi documentation (via Context7 MCP)
- Official chezmoi user guide
- Community examples

**Last Updated:** 2025-11-18
