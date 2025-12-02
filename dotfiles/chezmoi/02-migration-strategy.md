# Migration Strategy: Home-Manager → Chezmoi

**Last Updated:** 2025-11-17
**Goal:** Gradually migrate from home-manager to chezmoi while maintaining system stability

---

## Overview

This document outlines a **phased migration approach** that allows you to:
1. Keep NixOS system configuration intact
2. Gradually decouple home configs from home-manager
3. Test chezmoi alongside home-manager
4. Prepare for future Fedora migration

---

## Migration Philosophy

### ⚠️ Important Principles

1. **Gradual, Not Immediate**
   - Don't migrate everything at once
   - Test each component before moving the next
   - Keep home-manager as fallback initially

2. **Hybrid Approach (Recommended)**
   - NixOS manages: System, core packages, services
   - Home-Manager manages: Base environment, system integration
   - Chezmoi manages: Dotfiles, application configs, secrets

3. **Preparation for Fedora**
   - All configs in chezmoi will work on Fedora
   - Nix-specific things stay in home-manager temporarily
   - Clean separation of concerns

---

## Current State Analysis

### What You Currently Have

```
NixOS System
├── System Configuration
│   └── ~/.config/nixos/
│       ├── configuration.nix
│       ├── hosts/shoshin/
│       └── modules/system/
│
└── Home-Manager
    └── ~/.config/nixos/home/
        ├── home.nix
        ├── keepassxc.nix
        └── ... (other configs)
```

### What Needs Migration

Identify what's currently managed by home-manager:

```bash
# List all files managed by home-manager
home-manager generations | head -1

# Check what's being managed
cat ~/.config/nixos/home/mitso/home.nix
```

Typical categories:
- **Dotfiles:** Shell configs, editor configs, git config
- **Packages:** User packages (home.packages)
- **Services:** User systemd services
- **Programs:** home-manager program modules (programs.*)

---

## Migration Phases

### Phase 1: Setup & Testing (Week 1)

#### Goals
- Install chezmoi
- Create dotfiles repository
- Migrate simple configs
- Test alongside home-manager

#### Steps

1. **Install Chezmoi**

   Add to `~/.config/nixos/home/mitso/home.nix`:
   ```nix
   { config, pkgs, ... }:
   {
     home.packages = with pkgs; [
       chezmoi
       age  # For encryption
     ];
   }
   ```

   Apply:
   ```bash
   sudo nixos-rebuild switch
   ```

2. **Create Dotfiles Repository**

   ```bash
   # Create GitHub repo (via web or gh CLI)
   gh repo create dotfiles --private --description "Personal dotfiles managed by chezmoi"

   # Initialize chezmoi
   chezmoi init git@github.com:dtsioumas/dotfiles.git
   ```

3. **Configure Chezmoi**

   ```bash
   # Create config
   mkdir -p ~/.config/chezmoi
   cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
   [data]
       email = "dtsioumas0@gmail.com"
       name = "Dimitris Tsioumas"
       username = "dtsioumas"
       editor = "nvim"

   [git]
       autoCommit = false  # Manual commits initially
       autoPush = false
   EOF
   ```

4. **Migrate Simple Configs First**

   Start with non-critical dotfiles:

   ```bash
   # Shell aliases (low risk)
   chezmoi add ~/.bash_aliases

   # Git config (extract from home-manager)
   # First, check current git config
   cat ~/.gitconfig

   # Add as template for flexibility
   chezmoi add --template ~/.gitconfig

   # Terminal config (if not managed by home-manager)
   chezmoi add ~/.config/alacritty/alacritty.yml
   ```

5. **Test & Verify**

   ```bash
   # Check what chezmoi thinks should change
   chezmoi diff

   # Apply changes
   chezmoi apply -v

   # Verify files are correct
   cat ~/.gitconfig
   cat ~/.bash_aliases
   ```

6. **Commit Initial Setup**

   ```bash
   chezmoi cd
   git add .
   git commit -m "Initial chezmoi setup with basic configs"
   git push -u origin main
   exit
   ```

---

### Phase 2: Editor & Shell Configs (Week 2)

#### Goals
- Migrate shell configurations
- Migrate editor configs (nvim/vim)
- Remove from home-manager

#### Steps

1. **Identify Home-Manager Shell Config**

   Check `~/.config/nixos/home/mitso/home.nix`:
   ```nix
   programs.bash = {
     enable = true;
     # ... config ...
   };

   programs.zsh = {
     enable = true;
     # ... config ...
   };
   ```

2. **Extract Current Shell Configs**

   ```bash
   # Bash
   chezmoi add ~/.bashrc
   chezmoi add ~/.bash_profile

   # Zsh (if using)
   chezmoi add ~/.zshrc
   chezmoi add ~/.zshenv

   # Starship prompt (if using)
   chezmoi add ~/.config/starship.toml
   ```

3. **Migrate Neovim/Vim**

   ```bash
   # Neovim config
   chezmoi add --recursive ~/.config/nvim/

   # Or vim
   chezmoi add ~/.vimrc
   ```

4. **Create Templates for Platform Differences**

   Edit managed files to use templates:
   ```bash
   chezmoi edit ~/.bashrc
   ```

   Add platform-specific content:
   ```bash
   # .bashrc template example
   {{- if eq .chezmoi.os "linux" }}
   # Linux-specific
   alias ls='ls --color=auto'
   {{- else if eq .chezmoi.os "darwin" }}
   # macOS-specific
   alias ls='ls -G'
   {{- end }}

   # Common aliases
   alias ll='ls -lah'
   alias vim='{{ .editor }}'
   ```

5. **Remove from Home-Manager**

   Edit `~/.config/nixos/home/mitso/home.nix`:
   ```nix
   # Comment out or remove
   # programs.bash.enable = true;
   # programs.zsh.enable = true;
   ```

   Apply:
   ```bash
   sudo nixos-rebuild switch
   ```

6. **Test Thoroughly**

   ```bash
   # Start new shell
   exec bash
   # or
   exec zsh

   # Test aliases
   ll

   # Test editor
   nvim test.txt

   # Check environment
   echo $EDITOR
   ```

---

### Phase 3: Application Configs (Week 3-4)

#### Goals
- Migrate app-specific configs
- Setup secrets management
- Handle platform-specific configs

#### Steps

1. **Inventory Application Configs**

   Common configs to migrate:
   ```
   ~/.config/
   ├── alacritty/
   ├── kitty/
   ├── tmux/
   ├── git/
   ├── htop/
   ├── bat/
   └── ... (other apps)
   ```

2. **Add Application Configs**

   ```bash
   # Terminal emulator
   chezmoi add --recursive ~/.config/alacritty/

   # Terminal multiplexer
   chezmoi add ~/.tmux.conf

   # File viewers
   chezmoi add ~/.config/bat/

   # System monitor
   chezmoi add ~/.config/htop/
   ```

3. **Setup KeePassXC Integration**

   Since you're already using KeePassXC on NixOS:

   Install keepassxc-cli:
   ```nix
   # In home.nix
   home.packages = with pkgs; [
     keepassxc
   ];
   ```

   Configure chezmoi to use KeePassXC:
   ```bash
   # Edit chezmoi config
   cat >> ~/.config/chezmoi/chezmoi.toml <<'EOF'

   [keepassxc]
       database = "/home/mitso/MyVault/mitsio_secrets.kdbx"
       mode = "cli"  # Use keepassxc-cli
   EOF
   ```

   Use in templates:
   ```bash
   # Example: .gitconfig.tmpl
   [github]
       user = dtsioumas
       # Retrieve token from KeePassXC
       token = {{ keepassxcAttribute "GitHub/Personal" "password" }}
   ```

4. **Handle Platform-Specific Configs**

   For configs that differ between NixOS and future Fedora:

   ```bash
   # Create template
   chezmoi add --template ~/.config/some-app/config

   # Edit with platform logic
   chezmoi edit ~/.config/some-app/config
   ```

   ```yaml
   # Example: config.tmpl
   app:
     {{- if eq .chezmoi.osRelease.id "nixos" }}
     font: /run/current-system/sw/share/fonts/...
     {{- else if eq .chezmoi.osRelease.id "fedora" }}
     font: /usr/share/fonts/...
     {{- end }}
   ```

5. **Test on Fresh Directory**

   ```bash
   # Backup current configs
   mv ~/.config ~/.config.backup

   # Apply chezmoi configs
   chezmoi apply -v

   # Test applications
   # ... test each app ...

   # If issues, rollback:
   # rm -rf ~/.config
   # mv ~/.config.backup ~/.config
   ```

---

### Phase 4: Secrets & Sensitive Data (Week 4-5)

#### Goals
- Migrate API keys, tokens
- Setup encryption for sensitive files
- Integrate with KeePassXC vault

#### Steps

1. **Setup age Encryption**

   ```bash
   # Generate age key
   age-keygen -o ~/.config/chezmoi/key.txt

   # Add to chezmoi config
   cat >> ~/.config/chezmoi/chezmoi.toml <<EOF

   encryption = "age"
   [age]
       identity = "~/.config/chezmoi/key.txt"
       recipient = "$(age-keygen -y ~/.config/chezmoi/key.txt)"
   EOF
   ```

   **⚠️ IMPORTANT:** Back up `~/.config/chezmoi/key.txt` securely!

2. **Add Encrypted Files**

   ```bash
   # SSH keys (if not in KeePassXC)
   chezmoi add --encrypt ~/.ssh/id_rsa
   chezmoi add --encrypt ~/.ssh/id_ed25519

   # AWS credentials
   chezmoi add --encrypt ~/.aws/credentials

   # Other sensitive configs
   chezmoi add --encrypt ~/.netrc
   ```

3. **Use KeePassXC for Secrets**

   Example template with KeePassXC:
   ```bash
   # .gitconfig.tmpl
   [user]
       name = Dimitris Tsioumas
       email = dtsioumas0@gmail.com

   [github]
       user = dtsioumas
       token = {{ keepassxcAttribute "Development/GitHub" "token" }}

   [gitlab]
       user = dtsioumas
       token = {{ keepassxcAttribute "Development/GitLab" "api_token" }}
   ```

4. **Test Secret Retrieval**

   ```bash
   # Ensure KeePassXC database is unlocked
   # Then apply
   chezmoi apply -v

   # Verify secrets were inserted
   cat ~/.gitconfig | grep token
   ```

5. **Document Secret Management**

   Create README in dotfiles:
   ```bash
   cat > $(chezmoi source-path)/README.md <<'EOF'
   # Dotfiles

   ## Secret Management

   Secrets are stored in KeePassXC vault at: `~/MyVault/mitsio_secrets.kdbx`

   Required entries:
   - Development/GitHub (with 'token' attribute)
   - Development/GitLab (with 'api_token' attribute)
   - ... (other entries)

   ## Setup

   1. Unlock KeePassXC vault
   2. Run: `chezmoi apply`
   EOF
   ```

---

### Phase 5: Package Management (Week 5-6)

#### Goals
- Document package lists
- Create install scripts
- Prepare for Fedora migration

#### Steps

1. **Extract NixOS Package List**

   ```bash
   # List installed packages
   nix-env -qa --installed > ~/nix-packages.txt

   # Or from home-manager
   cat ~/.config/nixos/home/mitso/home.nix | grep -A 100 "home.packages"
   ```

2. **Create Package Manifest**

   ```bash
   # Create data file for packages
   cat > $(chezmoi source-path)/.chezmoidata/packages.yaml <<'EOF'
   packages:
     cli:
       - git
       - neovim
       - tmux
       - htop
       - ripgrep
       - fd
       - bat
       - fzf
       - age
       - chezmoi

     development:
       - go
       - python3
       - nodejs
       - docker
       - kubectl

     desktop:
       - alacritty
       - firefox
       - keepassxc
       - rclone
   EOF
   ```

3. **Create NixOS Install Script**

   ```bash
   cat > $(chezmoi source-path)/run_once_before_install-packages-nixos.sh.tmpl <<'EOF'
   {{- if eq .chezmoi.osRelease.id "nixos" }}
   #!/bin/bash
   # Note: This is informational only
   # Packages should be in configuration.nix

   echo "NixOS packages managed via configuration.nix"
   echo "Ensure these are in your config:"
   {{- range .packages.cli }}
   echo "  - {{ . }}"
   {{- end }}
   {{- end }}
   EOF
   ```

4. **Create Fedora Install Script**

   ```bash
   cat > $(chezmoi source-path)/run_once_before_install-packages-fedora.sh.tmpl <<'EOF'
   {{- if eq .chezmoi.osRelease.id "fedora" }}
   #!/bin/bash
   set -eu

   echo "Installing packages on Fedora..."

   # CLI tools
   sudo dnf install -y \
   {{- range .packages.cli }}
       {{ . }} \
   {{- end }}

   # Development tools
   sudo dnf install -y \
   {{- range .packages.development }}
       {{ . }} \
   {{- end }}

   # Desktop apps
   sudo dnf install -y \
   {{- range .packages.desktop }}
       {{ . }} \
   {{- end }}

   echo "Package installation complete!"
   {{- end }}
   EOF

   chmod +x $(chezmoi source-path)/run_once_before_install-packages-fedora.sh.tmpl
   ```

5. **Test Package Scripts**

   ```bash
   # Execute templates to see output
   chezmoi execute-template < $(chezmoi source-path)/run_once_before_install-packages-nixos.sh.tmpl

   # This won't run on NixOS, but you can preview:
   chezmoi execute-template < $(chezmoi source-path)/run_once_before_install-packages-fedora.sh.tmpl
   ```

---

### Phase 6: Cleanup & Optimization (Week 6-7)

#### Goals
- Remove duplicates from home-manager
- Optimize chezmoi setup
- Document everything

#### Steps

1. **Audit What's Left in Home-Manager**

   ```nix
   # Minimal home.nix after migration
   { config, pkgs, ... }:
   {
     # Only keep:
     # - System integration packages
     # - Services that need systemd
     # - Nix-specific configurations

     home.packages = with pkgs; [
       # Only packages needed for NixOS integration
     ];

     # Services
     services.syncthing.enable = true;  # Example

     # Nix-specific
     programs.home-manager.enable = true;
   }
   ```

2. **Optimize Chezmoi**

   Create `.chezmoiignore`:
   ```bash
   cat > $(chezmoi source-path)/.chezmoiignore <<'EOF'
   README.md
   LICENSE
   .git/

   # Ignore certain files on NixOS (managed by Nix)
   {{ if eq .chezmoi.osRelease.id "nixos" }}
   .config/systemd/
   {{ end }}

   # Ignore certain files on Fedora
   {{ if eq .chezmoi.osRelease.id "fedora" }}
   .nix-profile
   {{ end }}
   EOF
   ```

3. **Create Documentation**

   ```bash
   cat > $(chezmoi source-path)/MIGRATION.md <<'EOF'
   # Migration from NixOS to Fedora

   ## Pre-Migration Checklist

   - [ ] All configs in chezmoi
   - [ ] Secrets in KeePassXC
   - [ ] Package lists documented
   - [ ] Install scripts tested

   ## Migration Steps

   1. Install Fedora
   2. Install chezmoi: `sudo dnf install chezmoi`
   3. Initialize: `chezmoi init git@github.com:dtsioumas/dotfiles.git`
   4. Apply: `chezmoi apply -v`
   5. Packages installed via run scripts

   ## Post-Migration

   - [ ] Test all applications
   - [ ] Verify secrets loaded
   - [ ] Setup systemd services manually
   EOF
   ```

4. **Test Complete Setup**

   Simulate fresh install:
   ```bash
   # Create test user or VM
   # Install chezmoi
   # Run: chezmoi init --apply git@github.com:dtsioumas/dotfiles.git
   # Verify everything works
   ```

---

## Migration Checklist

### ✅ Phase 1: Setup
- [ ] Chezmoi installed
- [ ] Dotfiles repo created
- [ ] Basic configs migrated
- [ ] Initial commit pushed

### ✅ Phase 2: Shell & Editor
- [ ] Shell configs migrated
- [ ] Editor configs migrated
- [ ] Removed from home-manager
- [ ] Tested in new shell

### ✅ Phase 3: Applications
- [ ] App configs migrated
- [ ] Templates created for platform differences
- [ ] KeePassXC integration configured
- [ ] All apps tested

### ✅ Phase 4: Secrets
- [ ] age encryption setup
- [ ] Key backed up securely
- [ ] Sensitive files encrypted
- [ ] KeePassXC templates working
- [ ] Secrets verified

### ✅ Phase 5: Packages
- [ ] Package lists documented
- [ ] Install scripts created
- [ ] NixOS script written
- [ ] Fedora script written
- [ ] Scripts tested

### ✅ Phase 6: Cleanup
- [ ] Home-manager minimized
- [ ] Chezmoi optimized
- [ ] Documentation complete
- [ ] Fresh install tested

---

## Rollback Plan

If something goes wrong:

```bash
# Restore from home-manager
sudo nixos-rebuild switch

# Restore specific config
chezmoi diff ~/.config/some-app/config
# If wrong, delete and let home-manager recreate:
rm ~/.config/some-app/config
sudo nixos-rebuild switch

# Reset chezmoi completely
chezmoi purge
rm -rf ~/.local/share/chezmoi
```

---

## Final Architecture

After migration:

```
System Management
├── NixOS (System level)
│   └── /etc/nixos/configuration.nix
│       - System packages
│       - System services
│       - Hardware config
│
├── Home-Manager (Minimal)
│   └── ~/.config/nixos/home/mitso/home.nix
│       - SystemD user services
│       - Nix-specific integration
│       - Base packages (optional)
│
└── Chezmoi (Dotfiles)
    └── ~/.local/share/chezmoi/
        - Application configs
        - Shell configs
        - Editor configs
        - Secrets (encrypted)
        - Install scripts
```

---

## Next Steps

1. Begin Phase 1 this week
2. Follow timeline or adjust to your pace
3. Test thoroughly at each phase
4. Document any issues/solutions
5. Read **03-implementation-guide.md** for detailed commands

---

## Resources

- [Migrating from Nix (macOS example)](https://htdocs.dev/posts/migrating-from-nix-and-home-manager-to-homebrew-and-chezmoi/)
- [Using Chezmoi on NixOS Discussion](https://discourse.nixos.org/t/using-chezmoi-on-nixos/30699)
- [Dotfiles Journey with Chezmoi + NixOS](https://seds.nl/notes/my-journey-in-managing-dotfiles/)
