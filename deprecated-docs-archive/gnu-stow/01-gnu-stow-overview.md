# GNU Stow Overview & Guide

**Last Updated:** 2025-11-18
**Purpose:** Understanding GNU Stow for symlink management

---

## What is GNU Stow?

**GNU Stow** is a **symlink farm manager** that takes distinct sets of software or configuration files and makes them appear to be installed in a single directory tree.

### Official Resources

- **Official Website:** https://www.gnu.org/software/stow/
- **GitHub Repository:** https://github.com/aspiers/stow
- **Manual:** https://www.gnu.org/software/stow/manual/

---

## Core Concept

Stow **automates the creation of symlinks** from a source directory to a target directory, maintaining the same directory structure.

### The Problem Stow Solves

Without Stow:
```bash
# Manual symlink creation (tedious!)
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/dotfiles/.config/alacritty ~/.config/alacritty
# ... and so on for every file/directory
```

With Stow:
```bash
# Automatic symlink creation
cd ~/dotfiles
stow bash vim nvim alacritty
# All symlinks created automatically!
```

---

## How Stow Works

### Terminology

| Term | Description | Example |
|------|-------------|---------|
| **Stow directory** | Root directory containing packages | `~/dotfiles` |
| **Package** | Subdirectory in stow directory | `~/dotfiles/bash` |
| **Target directory** | Where symlinks are created | `~` (home directory) |
| **Symlink** | Symbolic link pointing to actual file | `~/.bashrc` → `~/dotfiles/bash/.bashrc` |

### Directory Structure Example

```
~/dotfiles/                    # Stow directory
├── bash/                      # Package
│   ├── .bashrc
│   └── .bash_profile
├── nvim/                      # Package
│   └── .config/
│       └── nvim/
│           └── init.lua
└── tmux/                      # Package
    └── .tmux.conf

Target: ~ (home directory)
After stowing:
~/.bashrc         → ~/dotfiles/bash/.bashrc
~/.bash_profile   → ~/dotfiles/bash/.bash_profile
~/.config/nvim/init.lua → ~/dotfiles/nvim/.config/nvim/init.lua
~/.tmux.conf      → ~/dotfiles/tmux/.tmux.conf
```

---

## Key Features

### 1. **Automatic Symlink Management**
- Creates symlinks automatically
- Maintains directory structure
- Handles nested directories

### 2. **Package Organization**
- Each program/tool gets its own package
- Clean separation of concerns
- Easy to add/remove configurations

### 3. **Conflict Detection**
- Warns about existing files
- Prevents accidental overwrites
- Safe operation by default

### 4. **Selective Installation**
- Install only needed packages
- Different configs per machine
- Easy testing of new configurations

### 5. **Easy Uninstallation**
- Remove symlinks with `-D` flag
- Clean removal (no orphaned links)
- Reversible operations

---

## Basic Usage

### Installation

```bash
# NixOS
nix-env -iA nixos.stow
# or in configuration.nix:
environment.systemPackages = [ pkgs.stow ];

# Debian/Ubuntu
sudo apt install stow

# Fedora
sudo dnf install stow

# macOS
brew install stow

# Arch
sudo pacman -S stow
```

### Simple Example

```bash
# 1. Create dotfiles directory
mkdir -p ~/dotfiles
cd ~/dotfiles

# 2. Create a package
mkdir bash
mv ~/.bashrc bash/
mv ~/.bash_profile bash/

# 3. Stow the package (creates symlinks)
stow bash

# Result:
# ~/.bashrc → ~/dotfiles/bash/.bashrc
# ~/.bash_profile → ~/dotfiles/bash/.bash_profile
```

### Basic Commands

```bash
# Stow packages (create symlinks)
stow <package-name>
stow bash vim tmux          # Multiple packages

# Unstow packages (remove symlinks)
stow -D <package-name>
stow -D bash vim tmux

# Restow (remove and recreate symlinks)
stow -R <package-name>

# Simulate (dry run, see what would happen)
stow -n <package-name>
stow -nv <package-name>     # Verbose simulation

# Specify target directory
stow -t /path/to/target <package>
```

---

## Directory Structure Patterns

### Pattern 1: Mirror Home Directory

**Best for:** Simple dotfiles, files in `~`

```
~/dotfiles/
├── bash/
│   ├── .bashrc
│   ├── .bash_profile
│   └── .bash_logout
├── git/
│   └── .gitconfig
└── vim/
    └── .vimrc

Command: stow bash git vim -t ~
Result:
  ~/.bashrc → ~/dotfiles/bash/.bashrc
  ~/.gitconfig → ~/dotfiles/git/.gitconfig
  ~/.vimrc → ~/dotfiles/vim/.vimrc
```

### Pattern 2: XDG Config Structure

**Best for:** Programs using `~/.config/`

```
~/dotfiles/
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/
│               └── config.lua
├── alacritty/
│   └── .config/
│       └── alacritty/
│           └── alacritty.yml
└── tmux/
    └── .tmux.conf

Command: stow nvim alacritty tmux -t ~
Result:
  ~/.config/nvim/init.lua → ~/dotfiles/nvim/.config/nvim/init.lua
  ~/.config/alacritty/alacritty.yml → ~/dotfiles/alacritty/.config/alacritty/alacritty.yml
  ~/.tmux.conf → ~/dotfiles/tmux/.tmux.conf
```

### Pattern 3: Mixed Structure

**Best for:** Programs with configs in multiple locations

```
~/dotfiles/
└── vscode/
    ├── .config/
    │   └── Code/
    │       └── User/
    │           └── settings.json
    └── Library/           # macOS specific
        └── Application Support/
            └── Code/
                └── User/
                    └── keybindings.json

Command: stow vscode -t ~
Result (Linux):
  ~/.config/Code/User/settings.json → ~/dotfiles/vscode/.config/Code/User/settings.json

Result (macOS):
  ~/Library/Application Support/Code/User/keybindings.json → ...
```

---

## Common Use Cases

### Use Case 1: Managing Dotfiles

**Goal:** Version control and sync dotfiles across machines

```bash
# Setup
mkdir -p ~/dotfiles
cd ~/dotfiles
git init

# Add packages
mkdir -p bash nvim tmux git

# Move existing configs
mv ~/.bashrc bash/
mv ~/.config/nvim nvim/.config/
mv ~/.tmux.conf tmux/
mv ~/.gitconfig git/

# Stow all packages
stow bash nvim tmux git

# Git workflow
git add .
git commit -m "Initial dotfiles"
git remote add origin git@github.com:username/dotfiles.git
git push -u origin main

# On new machine
git clone git@github.com:username/dotfiles.git
cd dotfiles
stow bash nvim tmux git
```

### Use Case 2: Testing New Configurations

**Goal:** Test new config without breaking current setup

```bash
# Current working config
~/dotfiles/nvim/          # Stowed

# Test new config
mkdir ~/dotfiles/nvim-test
# ... add new config to nvim-test ...

# Unstow current
stow -D nvim

# Stow test config
stow nvim-test

# If it works, replace:
rm -rf nvim
mv nvim-test nvim
stow nvim

# If it doesn't work, rollback:
stow -D nvim-test
stow nvim
```

### Use Case 3: Machine-Specific Configs

**Goal:** Different configs per machine

```bash
~/dotfiles/
├── bash-common/        # Shared config
│   └── .bashrc
├── bash-desktop/       # Desktop-specific
│   └── .bashrc_desktop
└── bash-laptop/        # Laptop-specific
    └── .bashrc_laptop

# On desktop:
stow bash-common bash-desktop

# On laptop:
stow bash-common bash-laptop

# In .bashrc:
# Source machine-specific config
[ -f ~/.bashrc_desktop ] && source ~/.bashrc_desktop
[ -f ~/.bashrc_laptop ] && source ~/.bashrc_laptop
```

---

## Advanced Usage

### Multiple Target Directories

```bash
# Different targets for different packages
stow bash -t ~
stow nvim -t ~/.config
stow fonts -t ~/.local/share/fonts

# Or create wrapper script
cat > stow.sh <<'EOF'
#!/bin/bash
stow bash git vim -t ~
stow nvim alacritty -t ~
EOF
chmod +x stow.sh
```

### Ignore Patterns

Create `.stow-local-ignore` in package directory:

```bash
# ~/dotfiles/nvim/.stow-local-ignore
\.git
\.gitignore
README.*
LICENSE
\.DS_Store
```

### Folding vs Unfolding

Stow behavior with existing directories:

```bash
# Scenario 1: Directory doesn't exist
# Stow creates directory symlink (folding)
~/.config/nvim → ~/dotfiles/nvim/.config/nvim

# Scenario 2: Directory exists with files
# Stow creates symlinks for each file (unfolding)
~/.config/nvim/init.lua → ~/dotfiles/nvim/.config/nvim/init.lua
~/.config/nvim/lua/config.lua → ~/dotfiles/nvim/.config/nvim/lua/config.lua
```

---

## Stow vs Other Methods

### Comparison Table

| Feature | GNU Stow | Manual `ln -s` | Chezmoi |
|---------|----------|----------------|---------|
| **Automation** | ✅ Automatic | ❌ Manual | ✅ Automatic |
| **Symlink creation** | ✅ Yes | ✅ Yes | ❌ Copies files |
| **Easy uninstall** | ✅ `stow -D` | ❌ Track manually | ✅ `chezmoi remove` |
| **Templates** | ❌ No | ❌ No | ✅ Go templates |
| **Secrets** | ❌ No | ❌ No | ✅ Password managers |
| **Cross-platform** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Learning curve** | Low | None | Moderate |
| **Dependencies** | Perl | None | Go binary |
| **File type** | Symlinks | Symlinks | Real files |

### When to Use Stow

✅ **Use Stow when:**
- You want symlinks (some apps don't work with copies)
- Simple dotfile management without templates
- Quick setup with minimal dependencies
- Managing locally-built software in `/usr/local/`

❌ **Don't use Stow when:**
- You need templating (platform-specific configs)
- You need secrets management
- Application doesn't support symlinks
- You want files copied instead of linked

---

## Best Practices

### 1. Organization

```bash
# Good: Clear package names
~/dotfiles/
├── bash/
├── zsh/
├── nvim/
├── git/
└── tmux/

# Bad: Generic names
~/dotfiles/
├── shell/
├── editor/
└── misc/
```

### 2. Version Control

```bash
# Always use Git
cd ~/dotfiles
git init
echo ".DS_Store" > .gitignore
git add .
git commit -m "Initial commit"
```

### 3. Documentation

```bash
# Create README
cat > ~/dotfiles/README.md <<'EOF'
# Dotfiles

Personal configuration files managed with GNU Stow.

## Setup

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
stow bash nvim tmux git
```

## Packages

- `bash` - Bash shell configuration
- `nvim` - Neovim editor configuration
- `tmux` - Terminal multiplexer configuration
- `git` - Git version control configuration
EOF
```

### 4. Backup Before Stowing

```bash
# Backup existing configs
mkdir ~/dotfiles-backup
cp ~/.bashrc ~/dotfiles-backup/
cp ~/.vimrc ~/dotfiles-backup/

# Then stow
stow bash vim
```

---

## Troubleshooting

### Problem: Existing Files

```bash
# Error: target ~/.bashrc already exists
stow: WARNING: target already exists: .bashrc

# Solution 1: Backup and remove
mv ~/.bashrc ~/.bashrc.backup
stow bash

# Solution 2: Adopt existing file
stow --adopt bash
# This moves existing file into stow package
```

### Problem: Conflicts

```bash
# Error: conflicts with package X
stow: WARNING: conflicts with existing file

# Solution: Check what's conflicting
stow -nv bash  # Dry run with verbose

# Then manually resolve
```

### Problem: Wrong Target

```bash
# Accidentally stowed to wrong target
stow bash  # Created links in ~/dotfiles instead of ~

# Solution: Unstow and restow with correct target
cd ~/dotfiles
stow -D bash
stow bash -t ~
```

---

## Script for Automation

Create `~/dotfiles/stow.sh`:

```bash
#!/bin/bash
# Stow dotfiles automation script

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
TARGET_DIR="$HOME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Packages to stow
PACKAGES=(
    "bash"
    "nvim"
    "tmux"
    "git"
    "alacritty"
)

# Parse command line
ACTION="stow"
if [[ "${1:-}" == "-D" ]] || [[ "${1:-}" == "unstow" ]]; then
    ACTION="unstow"
elif [[ "${1:-}" == "-R" ]] || [[ "${1:-}" == "restow" ]]; then
    ACTION="restow"
fi

cd "$DOTFILES_DIR"

for package in "${PACKAGES[@]}"; do
    if [[ ! -d "$package" ]]; then
        log_warn "Package '$package' not found, skipping"
        continue
    fi

    case "$ACTION" in
        stow)
            log_info "Stowing $package..."
            stow -t "$TARGET_DIR" "$package"
            ;;
        unstow)
            log_info "Unstowing $package..."
            stow -D -t "$TARGET_DIR" "$package"
            ;;
        restow)
            log_info "Restowing $package..."
            stow -R -t "$TARGET_DIR" "$package"
            ;;
    esac
done

log_info "Done!"
```

Usage:
```bash
# Stow all packages
./stow.sh

# Unstow all packages
./stow.sh -D

# Restow all packages
./stow.sh -R
```

---

## NixOS Integration

### Using Stow with NixOS

```nix
# configuration.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    stow
  ];

  # Or in home-manager
  home.packages = with pkgs; [
    stow
  ];
}
```

### Hybrid Approach: NixOS + Stow

```
System Management:
├── NixOS (System config)
│   └── /etc/nixos/configuration.nix
└── Stow (User dotfiles)
    └── ~/dotfiles/
        ├── bash/
        ├── nvim/
        └── tmux/
```

**Benefits:**
- NixOS manages system and packages
- Stow manages personal configs
- Simple, no Nix expressions for dotfiles
- Easy to migrate to Fedora (just use stow there too)

---

## Next Steps

1. **Read** 02-stow-practical-examples.md for hands-on examples
2. **Try** simple example with bash config
3. **Expand** to other dotfiles
4. **Automate** with shell script

---

## Resources

- [GNU Stow Official Manual](https://www.gnu.org/software/stow/manual/)
- [GitHub Repository](https://github.com/aspiers/stow)
- [Managing Dotfiles with Stow (Article)](https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
- [Video Tutorial](https://www.youtube.com/watch?v=06x3ZhwrrwA)
