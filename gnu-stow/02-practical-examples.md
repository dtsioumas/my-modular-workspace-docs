# GNU Stow: Practical Examples & Symlink Patterns

**Last Updated:** 2025-11-18
**Purpose:** Hands-on examples for using GNU Stow

---

## Quick Start Example

### Complete Setup from Scratch

```bash
# 1. Install Stow
sudo dnf install stow  # Fedora
# or on NixOS: add to configuration.nix

# 2. Create dotfiles directory
mkdir -p ~/dotfiles
cd ~/dotfiles

# 3. Initialize Git
git init
echo ".DS_Store" > .gitignore
echo "*.backup" >> .gitignore

# 4. Create first package (bash)
mkdir -p bash
mv ~/.bashrc bash/
mv ~/.bash_profile bash/

# 5. Stow the package
cd ~/dotfiles
stow bash

# 6. Verify symlinks
ls -la ~ | grep bashrc
# Output: .bashrc -> dotfiles/bash/.bashrc

# 7. Commit to Git
git add .
git commit -m "Add bash configuration"
```

---

## Example 1: Simple Dotfiles Setup

### Goal
Manage bash, vim, and git configurations.

### Structure

```bash
~/dotfiles/
├── bash/
│   ├── .bashrc
│   ├── .bash_profile
│   └── .bash_aliases
├── vim/
│   ├── .vimrc
│   └── .vim/
│       ├── colors/
│       └── plugin/
└── git/
    └── .gitconfig
```

### Implementation

```bash
# Create packages
mkdir -p ~/dotfiles/{bash,vim,git}

# Move existing configs
mv ~/.bashrc ~/dotfiles/bash/
mv ~/.bash_profile ~/dotfiles/bash/
mv ~/.bash_aliases ~/dotfiles/bash/
mv ~/.vimrc ~/dotfiles/vim/
mv ~/.vim ~/dotfiles/vim/
mv ~/.gitconfig ~/dotfiles/git/

# Stow all packages
cd ~/dotfiles
stow bash vim git

# Verify
ls -la ~/ | grep -E "bashrc|vimrc|gitconfig"
```

### Result

```bash
~/.bashrc → ~/dotfiles/bash/.bashrc
~/.bash_profile → ~/dotfiles/bash/.bash_profile
~/.bash_aliases → ~/dotfiles/bash/.bash_aliases
~/.vimrc → ~/dotfiles/vim/.vimrc
~/.vim → ~/dotfiles/vim/.vim
~/.gitconfig → ~/dotfiles/git/.gitconfig
```

---

## Example 2: XDG Config Directory

### Goal
Manage modern applications using `~/.config/`.

### Structure

```bash
~/dotfiles/
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           ├── lua/
│           │   ├── plugins.lua
│           │   └── settings.lua
│           └── after/
│               └── plugin/
├── alacritty/
│   └── .config/
│       └── alacritty/
│           └── alacritty.yml
├── tmux/
│   └── .tmux.conf
└── htop/
    └── .config/
        └── htop/
            └── htoprc
```

### Implementation

```bash
# Create packages with .config structure
mkdir -p ~/dotfiles/nvim/.config
mkdir -p ~/dotfiles/alacritty/.config
mkdir -p ~/dotfiles/htop/.config

# Move existing configs
mv ~/.config/nvim ~/dotfiles/nvim/.config/
mv ~/.config/alacritty ~/dotfiles/alacritty/.config/
mv ~/.config/htop ~/dotfiles/htop/.config/

# Tmux config (top-level file)
mkdir -p ~/dotfiles/tmux
mv ~/.tmux.conf ~/dotfiles/tmux/

# Stow all
cd ~/dotfiles
stow nvim alacritty htop tmux
```

### Result

```bash
~/.config/nvim → ~/dotfiles/nvim/.config/nvim
~/.config/alacritty → ~/dotfiles/alacritty/.config/alacritty
~/.config/htop → ~/dotfiles/htop/.config/htop
~/.tmux.conf → ~/dotfiles/tmux/.tmux.conf
```

---

## Example 3: SSH Configuration

### Goal
Manage SSH keys and config securely.

### Structure

```bash
~/dotfiles/
└── ssh/
    └── .ssh/
        ├── config
        └── authorized_keys
```

**⚠️ Note:** Don't put private keys in Git! Only config files.

### Implementation

```bash
# Create package
mkdir -p ~/dotfiles/ssh/.ssh

# Copy configs (NOT private keys!)
cp ~/.ssh/config ~/dotfiles/ssh/.ssh/
cp ~/.ssh/authorized_keys ~/dotfiles/ssh/.ssh/

# Backup and remove originals
mv ~/.ssh/config ~/.ssh/config.backup
mv ~/.ssh/authorized_keys ~/.ssh/authorized_keys.backup

# Stow
cd ~/dotfiles
stow ssh

# Verify permissions
ls -la ~/.ssh/
# config should be 0600
chmod 600 ~/.ssh/config
```

### For Private Keys

```bash
# DON'T add private keys to Git
# Instead, use this in README:
cat > ~/dotfiles/ssh/README.md <<'EOF'
# SSH Keys

Private keys are NOT in this repo.

Setup:
1. Generate new key: `ssh-keygen -t ed25519`
2. Or copy existing private key to ~/.ssh/
3. Ensure permissions: `chmod 600 ~/.ssh/id_*`
EOF
```

---

## Example 4: Multi-Target Stowing

### Goal
Stow packages to different target directories.

### Structure

```bash
~/dotfiles/
├── bash/          # Target: ~
│   └── .bashrc
├── fonts/         # Target: ~/.local/share/fonts
│   └── FiraCode.ttf
└── systemd/       # Target: ~/.config/systemd/user
    └── service.service
```

### Implementation

```bash
# Stow to different targets
cd ~/dotfiles

# Bash to home
stow bash -t ~

# Fonts to local share
mkdir -p fonts/.local/share/fonts
cp ~/Downloads/FiraCode.ttf fonts/.local/share/fonts/
stow fonts -t ~

# Systemd to config
mkdir -p systemd/.config/systemd/user
# ... add service file ...
stow systemd -t ~
```

---

## Example 5: Platform-Specific Configs

### Goal
Different configs for different operating systems.

### Structure

```bash
~/dotfiles/
├── bash-common/      # Shared config
│   └── .bashrc_common
├── bash-nixos/       # NixOS-specific
│   └── .bashrc_nixos
├── bash-fedora/      # Fedora-specific
│   └── .bashrc_fedora
└── bash-wrapper/     # Main .bashrc
    └── .bashrc
```

### bash-wrapper/.bashrc

```bash
# Load common config
[ -f ~/.bashrc_common ] && source ~/.bashrc_common

# Load OS-specific config
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        nixos)
            [ -f ~/.bashrc_nixos ] && source ~/.bashrc_nixos
            ;;
        fedora)
            [ -f ~/.bashrc_fedora ] && source ~/.bashrc_fedora
            ;;
    esac
fi
```

### Implementation

```bash
# On NixOS
cd ~/dotfiles
stow bash-common bash-nixos bash-wrapper

# On Fedora
cd ~/dotfiles
stow bash-common bash-fedora bash-wrapper
```

---

## Example 6: Git Workflow Integration

### Goal
Manage dotfiles with Git for version control and sync.

### Complete Setup

```bash
# 1. Initialize repository
mkdir -p ~/dotfiles
cd ~/dotfiles
git init

# 2. Create .gitignore
cat > .gitignore <<'EOF'
# OS files
.DS_Store
Thumbs.db

# Backups
*.backup
*.bak

# Editor files
.vscode/
.idea/

# Local overrides (not to be synced)
*.local
EOF

# 3. Create README
cat > README.md <<'EOF'
# Dotfiles

Personal configuration files managed with GNU Stow.

## Quick Setup

```bash
git clone git@github.com:username/dotfiles.git ~/dotfiles
cd ~/dotfiles
./stow.sh
```

## Packages

- `bash` - Bash shell configuration
- `nvim` - Neovim editor
- `tmux` - Terminal multiplexer
- `git` - Git configuration

## Usage

```bash
# Stow all packages
./stow.sh

# Unstow all packages
./stow.sh -D

# Add new package
mkdir new-package
# ... add files ...
stow new-package
```
EOF

# 4. Create stow script
cat > stow.sh <<'EOF'
#!/bin/bash
set -euo pipefail

PACKAGES=(bash nvim tmux git)
ACTION="${1:--S}"  # Default: stow

cd ~/dotfiles

for pkg in "${PACKAGES[@]}"; do
    if [[ ! -d "$pkg" ]]; then
        echo "Package $pkg not found, skipping"
        continue
    fi

    case "$ACTION" in
        -D|unstow)
            echo "Unstowing $pkg..."
            stow -D "$pkg"
            ;;
        -R|restow)
            echo "Restowing $pkg..."
            stow -R "$pkg"
            ;;
        *)
            echo "Stowing $pkg..."
            stow "$pkg"
            ;;
    esac
done
EOF

chmod +x stow.sh

# 5. Add packages (as shown in previous examples)
# ...

# 6. Commit and push
git add .
git commit -m "Initial dotfiles setup"
git remote add origin git@github.com:username/dotfiles.git
git push -u origin main
```

### On New Machine

```bash
# Clone repository
git clone git@github.com:username/dotfiles.git ~/dotfiles

# Run stow script
cd ~/dotfiles
./stow.sh

# Done! All configs are linked
```

---

## Example 7: Backup Before Stowing

### Goal
Safely migrate existing configs to Stow.

### Script

```bash
#!/bin/bash
# backup-and-stow.sh

set -euo pipefail

BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DOTFILES_DIR="$HOME/dotfiles"

echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Files to backup and stow
declare -A FILES=(
    ["bash"]=".bashrc .bash_profile .bash_aliases"
    ["vim"]=".vimrc"
    ["git"]=".gitconfig"
    ["tmux"]=".tmux.conf"
)

# Backup existing files
for package in "${!FILES[@]}"; do
    echo "Backing up $package files..."
    for file in ${FILES[$package]}; do
        if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            cp -r "$HOME/$file" "$BACKUP_DIR/"
            echo "  Backed up: $file"
        fi
    done
done

echo ""
echo "Backup complete! Files saved to: $BACKUP_DIR"
echo ""
echo "Now you can safely stow your dotfiles:"
echo "  cd $DOTFILES_DIR"
echo "  stow bash vim git tmux"
echo ""
echo "If something goes wrong, restore from: $BACKUP_DIR"
```

Usage:
```bash
chmod +x backup-and-stow.sh
./backup-and-stow.sh
```

---

## Example 8: Adopt Existing Files

### Goal
Move existing configs into Stow package.

### Problem

```bash
# You have existing .bashrc
ls -la ~/.bashrc
# -rw-r--r-- 1 user user 1234 Nov 17 10:00 .bashrc

# You create stow package
mkdir -p ~/dotfiles/bash
cp ~/.bashrc ~/dotfiles/bash/

# Try to stow
cd ~/dotfiles
stow bash
# ERROR: target already exists: .bashrc
```

### Solution: Use --adopt

```bash
# Method 1: Adopt (moves existing file into package)
cd ~/dotfiles
stow --adopt bash

# This moves ~/.bashrc → ~/dotfiles/bash/.bashrc
# And creates symlink: ~/.bashrc → ~/dotfiles/bash/.bashrc

# Method 2: Manual (more control)
mv ~/.bashrc ~/dotfiles/bash/
stow bash
```

---

## Example 9: Testing New Configs

### Goal
Test new configuration without breaking current setup.

### Workflow

```bash
# Current working config
~/dotfiles/nvim/  # Stowed and working

# Create test package
mkdir -p ~/dotfiles/nvim-new
# ... add new config ...

# Unstow current
cd ~/dotfiles
stow -D nvim

# Stow test config
stow nvim-new

# Test the new config
nvim test.txt

# If good: Replace
rm -rf nvim
mv nvim-new nvim
stow nvim

# If bad: Rollback
stow -D nvim-new
stow nvim
```

---

## Example 10: Automation Script (Complete)

### Goal
Complete automation for stowing dotfiles.

### Script: `~/dotfiles/manage.sh`

```bash
#!/bin/bash
# manage.sh - Complete dotfiles management script

set -euo pipefail

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"
BACKUP_DIR="$HOME/.dotfiles-backups"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $*"; }

# Help message
show_help() {
    cat <<EOF
Dotfiles Management Script

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    stow        Stow all packages (default)
    unstow      Unstow all packages
    restow      Restow all packages
    backup      Backup existing dotfiles
    list        List all packages
    check       Check for conflicts

Options:
    -p, --package <name>    Operate on specific package only
    -h, --help              Show this help message

Examples:
    $0 stow                 # Stow all packages
    $0 unstow -p bash       # Unstow only bash package
    $0 backup               # Backup existing configs
EOF
}

# List packages
list_packages() {
    log_step "Available packages:"
    for dir in "$DOTFILES_DIR"/*/ ; do
        package=$(basename "$dir")
        [[ "$package" =~ ^\..*$ ]] && continue  # Skip hidden dirs
        echo "  - $package"
    done
}

# Backup existing files
backup_files() {
    local backup_date=$(date +%Y%m%d-%H%M%S)
    local backup_path="$BACKUP_DIR/backup-$backup_date"

    log_step "Creating backup at: $backup_path"
    mkdir -p "$backup_path"

    # Find all symlinks pointing to dotfiles
    find "$TARGET_DIR" -maxdepth 3 -type l | while read -r link; do
        if [[ "$(readlink "$link")" == "$DOTFILES_DIR"* ]]; then
            target=$(readlink "$link")
            log_info "Backing up: $link"
            cp -P "$link" "$backup_path/"
        fi
    done

    log_info "Backup complete: $backup_path"
}

# Check for conflicts
check_conflicts() {
    log_step "Checking for conflicts..."
    cd "$DOTFILES_DIR"

    local conflicts=0
    for package in */; do
        package=${package%/}
        [[ "$package" =~ ^\..*$ ]] && continue

        if stow -n "$package" 2>&1 | grep -q "WARNING"; then
            log_warn "Conflicts found in package: $package"
            ((conflicts++))
        fi
    done

    if [[ $conflicts -eq 0 ]]; then
        log_info "No conflicts found!"
    else
        log_warn "Found $conflicts package(s) with conflicts"
    fi
}

# Stow packages
stow_packages() {
    local action="$1"
    local specific_package="$2"

    cd "$DOTFILES_DIR"

    if [[ -n "$specific_package" ]]; then
        # Stow specific package
        if [[ ! -d "$specific_package" ]]; then
            log_error "Package not found: $specific_package"
            return 1
        fi

        case "$action" in
            stow)
                log_step "Stowing $specific_package..."
                stow "$specific_package"
                ;;
            unstow)
                log_step "Unstowing $specific_package..."
                stow -D "$specific_package"
                ;;
            restow)
                log_step "Restowing $specific_package..."
                stow -R "$specific_package"
                ;;
        esac
    else
        # Stow all packages
        for package in */; do
            package=${package%/}
            [[ "$package" =~ ^\..*$ ]] && continue

            case "$action" in
                stow)
                    log_step "Stowing $package..."
                    stow "$package"
                    ;;
                unstow)
                    log_step "Unstowing $package..."
                    stow -D "$package"
                    ;;
                restow)
                    log_step "Restowing $package..."
                    stow -R "$package"
                    ;;
            esac
        done
    fi

    log_info "Done!"
}

# Main
main() {
    local command="${1:-stow}"
    local package=""

    # Parse arguments
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--package)
                package="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done

    # Execute command
    case "$command" in
        stow|unstow|restow)
            stow_packages "$command" "$package"
            ;;
        backup)
            backup_files
            ;;
        list)
            list_packages
            ;;
        check)
            check_conflicts
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
```

### Usage

```bash
# Make executable
chmod +x ~/dotfiles/manage.sh

# Stow all packages
./manage.sh stow

# Unstow specific package
./manage.sh unstow -p bash

# List packages
./manage.sh list

# Check conflicts
./manage.sh check

# Create backup
./manage.sh backup

# Get help
./manage.sh help
```

---

## Quick Reference Card

```bash
# Basic Operations
stow <package>              # Stow package
stow -D <package>           # Unstow package
stow -R <package>           # Restow package
stow -n <package>           # Dry run (simulate)
stow -v <package>           # Verbose output
stow -t <target> <package>  # Custom target

# Multiple Packages
stow bash vim git           # Stow multiple
stow -D bash vim git        # Unstow multiple

# Adoption
stow --adopt <package>      # Adopt existing files

# Conflicts
stow -n -v <package>        # Check for conflicts

# Directory Structure
~/dotfiles/                 # Stow directory
├── <package>/              # Package name
│   └── <same as target>/   # Mirror target structure

# Example
~/dotfiles/bash/.bashrc → ~/.bashrc
~/dotfiles/nvim/.config/nvim/ → ~/.config/nvim/
```

---

## Summary

✅ **GNU Stow** is perfect for:
- Simple dotfile management
- Creating organized symlink farms
- Managing locally-built software
- Version-controlling configurations

🎯 **Best practices:**
- Use Git for version control
- Create automation scripts
- Backup before stowing
- Use clear package names
- Document your setup

📚 **Next:** Read `01-gnu-stow-overview.md` for detailed concepts

---

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [Managing Dotfiles Guide](https://medium.com/quick-programming/managing-dotfiles-with-gnu-stow-9b04c155ebad)
- [Stow GitHub Gist](https://gist.github.com/andreibosco/cb8506780d0942a712fc)
