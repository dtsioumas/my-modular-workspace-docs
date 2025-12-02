# Chezmoi Research Findings & Insights

**Date:** 2025-11-18
**Purpose:** Key insights from research and dotfiles inventory analysis

---

## 🔍 Key Discoveries

### 1. Chezmoi Naming Convention is Critical

Chezmoi uses **prefix-based naming** to encode file attributes:

| Source File | Target File | Explanation |
|------------|-------------|-------------|
| `dot_bashrc` | `~/.bashrc` | `dot_` prefix = dotfile |
| `dot_bashrc.tmpl` | `~/.bashrc` | `.tmpl` suffix = template file |
| `private_dot_ssh/config` | `~/.ssh/config` (0600) | `private_` = 0600 permissions |
| `executable_script.sh` | `~/script.sh` (0755) | `executable_` = executable |
| `private_id_ed25519.age` | `~/.ssh/id_ed25519` | `.age` = encrypted file |
| `exact_dot_config` | `~/.config/` | `exact_` = remove unmanaged files |

**Important:** Directory structure mirrors target:
```
dot_config/kitty/kitty.conf  →  ~/.config/kitty/kitty.conf
```

---

### 2. Home-Manager vs Chezmoi - Clear Separation

**Hybrid architecture works best:**

```
NixOS System
├── NixOS Configuration
│   └── System packages, services, hardware
│
├── Home-Manager (Minimal)
│   ├── Nix-specific integration
│   ├── Systemd user services
│   ├── Directory symlinks (via mkOutOfStoreSymlink)
│   └── Base environment
│
└── Chezmoi (Dotfiles)
    ├── Application configs
    ├── Shell configs
    ├── Templates (platform-specific)
    └── Secrets (encrypted)
```

**Why this works:**
- Home-Manager: Declarative Nix integration (not portable)
- Chezmoi: Portable dotfiles (works anywhere)
- Clear responsibility boundaries

---

### 3. KDE Plasma Configs Are Extensive

From dotfiles inventory:
- **30+ KDE configuration files**
- Many auto-generated (shouldn't be managed)
- KDE-specific (won't work on Fedora GNOME)

**Solution:**
Use platform-specific templates:
```yaml
{{- if eq .chezmoi.osRelease.id "nixos" }}
# KDE Plasma configs
{{- else if eq .chezmoi.osRelease.id "fedora" }}
# GNOME configs
{{- end }}
```

**KDE Configs to Migrate:**
- `kdeglobals` - Global theme/fonts ✅
- `kglobalshortcutsrc` - Keyboard shortcuts ✅
- `kwinrc` - Window manager ✅
- Individual app configs (Dolphin, Konsole, etc.) ✅

**KDE Configs to Skip:**
- `kconf_updaterc` - Auto-generated ❌
- `ksplashrc` - Empty file ❌
- Session-specific files ❌

---

### 4. Browser Profiles Should NOT Be Managed

**Finding:**
- Browser profiles are **huge** (GBs of data)
- Contain cache, cookies, session data
- Change constantly
- Not portable between machines

**What to do instead:**
1. **Document extensions** in separate file
2. **Sync bookmarks** via browser sync
3. **Export settings/flags** only
4. **Use browser sync services** (Firefox Sync, Brave Sync)

**Example:**
```markdown
# docs/browser-setup.md

## Brave Extensions
- uBlock Origin
- Bitwarden
- ...

## Chrome Flags
chrome://flags/#enable-webgpu

## Brave Settings
- Hardware acceleration: Enabled
- ...
```

---

### 5. Secrets Management Strategy

**Three-tier approach:**

1. **KeePassXC** (Source of Truth)
   - Store all passwords, API keys, tokens
   - Use keepassxc-cli for retrieval

2. **Chezmoi Templates** (Dynamic Secrets)
   ```gitconfig
   [github]
       token = {{ keepassxcAttribute "Development/GitHub" "token" }}
   ```

3. **age Encryption** (Static Secrets)
   ```bash
   # Encrypt SSH keys, AWS credentials, etc.
   chezmoi add --encrypt ~/.ssh/id_ed25519
   ```

**Never:**
- ❌ Commit unencrypted secrets to git
- ❌ Store secrets in plain text files
- ❌ Use environment variables for persistent secrets

---

### 6. .bash_history Should NOT Be in Git

**Security risks identified:**
- Commands may contain passwords: `mysql -p password123`
- API keys in exports: `export TOKEN=abc123`
- Sensitive paths revealed: `/home/user/company/secret-project/`
- Debugging sessions: `curl -H "Auth: secret"`

**Better alternatives:**
1. **Atuin** - Encrypted cloud sync ⭐
2. **Local only** - Keep `.bash_history` unmanaged
3. **Documented commands** - Curate useful commands in markdown

---

### 7. Dotfiles Inventory Revealed Tool Landscape

**47+ config directories analyzed:**

**Categories identified:**
- Development: 5 tools (VS Code, Git, GitHub CLI, Go, Godot)
- Terminal: 6 tools (Kitty, Konsole, htop, btop, bottom, lnav)
- KDE Plasma: 30+ config files
- Applications: 10+ (browsers, Discord, Obsidian, KeePassXC, rclone)
- System utilities: 15+ (GTK, Qt, dconf, etc.)

**Priority levels established:**
- **High:** Shell, terminal, dev tools (migrate first)
- **Medium:** KDE desktop, apps
- **Low:** Browser settings, optional configs
- **Never:** History, cache, backups, auto-generated

---

### 8. Migration Phases Make Sense

**6-week plan is realistic:**

- **Week 1:** Setup + simple configs (shell, git)
- **Week 2:** Editor + terminal
- **Week 3:** Applications + KeePassXC integration
- **Week 4:** Secrets + encryption
- **Week 5:** Package lists + install scripts
- **Week 6:** Cleanup + testing

**Why gradual?**
- Test each component independently
- Keep home-manager as fallback
- Catch issues early
- Less risk

---

### 9. Platform-Specific Templates Are Essential

**For NixOS → Fedora migration:**

```yaml
# Package management
{{- if eq .chezmoi.osRelease.id "nixos" }}
# Packages in configuration.nix
{{- else if eq .chezmoi.osRelease.id "fedora" }}
sudo dnf install git nvim tmux
{{- end }}

# Paths
{{- if eq .chezmoi.osRelease.id "nixos" }}
export PATH="/run/current-system/sw/bin:$PATH"
{{- else }}
export PATH="/usr/local/bin:$PATH"
{{- end }}

# Desktop environment
{{- if eq .chezmoi.osRelease.id "nixos" }}
# KDE Plasma configs
{{- else }}
# GNOME configs
{{- end }}
```

---

### 10. mkOutOfStoreSymlink for Directories Works Well

**Finding:** Home-Manager's `mkOutOfStoreSymlink` is perfect for directory symlinks.

**Why it works:**
- Declarative
- Version controlled
- Portable (works on standalone Home-Manager)
- No additional tools needed

**Example:**
```nix
home.file."Documents".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/.MyHome/Documents";
```

**Important:** Must use absolute path strings (not path literals) with flakes.

---

### 11. Chezmoi External Resources Feature is Powerful

**Can import from GitHub releases, archives, URLs:**

```toml
# .chezmoiexternal.toml
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    stripComponents = 1
    refreshPeriod = "168h"
```

**Use cases:**
- Oh-my-zsh installation
- Zsh plugins
- Starship prompt binary
- Any tool not in package manager

---

### 12. Run Scripts Enable Automated Setup

**Four types discovered:**

| Type | When | Use For |
|------|------|---------|
| `run_once_` | Once per machine | Package installation |
| `run_onchange_` | When script changes | Config-dependent tasks |
| `run_before_` | Before apply | Prerequisites |
| `run_after_` | After apply | Post-processing |

**Example use:**
```bash
# run_once_before_install-packages.sh.tmpl
{{- if eq .chezmoi.osRelease.id "fedora" }}
#!/bin/bash
sudo dnf install -y git neovim tmux htop
{{- end }}
```

---

### 13. Chezmoi Data Files for Organization

**Can define data in `.chezmoidata/` directory:**

```yaml
# .chezmoidata/packages.yaml
packages:
  cli:
    - git
    - neovim
    - tmux
  development:
    - go
    - python3
    - nodejs
```

**Use in templates:**
```yaml
{{- range .packages.cli }}
- {{ . }}
{{- end }}
```

---

### 14. Git Tree Must Be Clean for Flakes

**Discovery:** Nix flakes won't evaluate with dirty git tree.

**Solutions:**
1. Commit changes: `git add . && git commit`
2. Use `git stash` temporarily
3. Keep working tree clean

**Important for workflow:**
- Commit frequently
- Small, focused commits
- Don't accumulate uncommitted changes

---

### 15. Home-Manager Standalone Works on Any Linux

**Finding:** Home-Manager not tied to NixOS.

**Installation on Fedora:**
```bash
# Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Install Home-Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Use SAME config as NixOS!
home-manager switch --flake /path/to/dotfiles
```

**This means:** Same `home.nix` works on both NixOS and Fedora.

---

## 🎯 Recommended Workflow

Based on all findings:

### Phase 0: Preparation ✅ (Done)
- ✅ Read all documentation
- ✅ Create dotfiles inventory
- ✅ Setup Home-Manager symlinks
- ✅ Install Atuin for history

### Phase 1: Core Configs (Next)
1. Install chezmoi and age
2. Create GitHub dotfiles repo
3. Migrate shell configs (bashrc, profile)
4. Migrate terminal (kitty, htop)
5. Migrate git config
6. Test workflow

### Phase 2: Development Tools
1. VS Code settings
2. GitHub CLI config
3. Go environment
4. Language-specific configs

### Phase 3: Applications
1. KeePassXC config
2. rclone config
3. Application-specific settings

### Phase 4: Secrets
1. Setup age encryption
2. Add KeePassXC integration
3. Encrypt SSH keys
4. Test secret retrieval

### Phase 5: Platform Templates
1. Add NixOS vs Fedora logic
2. Create install scripts
3. Test on both platforms

### Phase 6: KDE/Desktop (Optional)
1. Export KDE configs
2. Create platform-specific templates
3. Document GNOME alternative

---

## 📝 Lessons Learned

1. **Start small** - Don't migrate everything at once
2. **Test thoroughly** - Use `--dry-run` extensively
3. **Backup first** - Keep original configs
4. **Document decisions** - Future you will thank you
5. **Use templates** - Platform-agnostic from start
6. **Encrypt secrets** - Security first
7. **Version control** - Commit frequently
8. **Keep it simple** - Don't over-engineer

---

## 🔗 Useful Links

- **Chezmoi GitHub examples:** Search "chezmoi dotfiles" on GitHub
- **NixOS + Chezmoi discussion:** https://discourse.nixos.org/t/using-chezmoi-on-nixos/30699
- **Migration guide:** https://htdocs.dev/posts/migrating-from-nix-and-home-manager-to-homebrew-and-chezmoi/

---

**Research Date:** 2025-11-18
**Inventory File:** `docs/dotfiles-inventory/DOTFILES_INVENTORY.md`
**Next:** Begin Phase 1 migration
