# GNU Stow Research Documentation

**Created:** 2025-11-18
**Purpose:** Complete guide to GNU Stow for symlink management

---

## 📚 Documentation Overview

This directory contains comprehensive research and documentation about **GNU Stow** - a symlink farm manager for dotfile and software management.

### Documents

1. **[01-gnu-stow-overview.md](01-gnu-stow-overview.md)**
   - What is GNU Stow and how it works
   - Core concepts and terminology
   - Directory structure patterns
   - Comparison with other methods
   - Installation and basic usage
   - Best practices and troubleshooting

2. **[02-practical-examples.md](02-practical-examples.md)**
   - 10 complete hands-on examples
   - Real-world use cases
   - Platform-specific configurations
   - Git workflow integration
   - Complete automation scripts
   - Quick reference card

---

## 🎯 What is GNU Stow?

**GNU Stow** is a symlink farm manager that automatically creates symbolic links from a source directory (your dotfiles repo) to a target directory (your home folder).

### The Problem It Solves

**Without Stow:**
```bash
# Manual symlink creation for every file
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
# ... tedious and error-prone!
```

**With Stow:**
```bash
# Automatic symlink creation
cd ~/dotfiles
stow bash vim nvim
# All symlinks created automatically!
```

---

## 🚀 Quick Start

### 1. Install Stow

```bash
# NixOS
sudo nixos-rebuild switch  # Add stow to configuration.nix

# Fedora
sudo dnf install stow

# Debian/Ubuntu
sudo apt install stow

# macOS
brew install stow
```

### 2. Create Dotfiles Directory

```bash
mkdir -p ~/dotfiles
cd ~/dotfiles
git init
```

### 3. Create a Package

```bash
# Create bash package
mkdir bash
mv ~/.bashrc bash/

# Stow it
stow bash

# Verify symlink
ls -la ~/.bashrc
# .bashrc -> dotfiles/bash/.bashrc
```

---

## 📖 Key Concepts

### Terminology

| Term | Description |
|------|-------------|
| **Stow Directory** | Root directory containing packages (e.g., `~/dotfiles`) |
| **Package** | Subdirectory in stow directory (e.g., `bash`, `nvim`) |
| **Target Directory** | Where symlinks are created (usually `~`) |
| **Symlink** | Symbolic link pointing to actual file |

### Directory Structure

```
~/dotfiles/              # Stow directory
├── bash/                # Package
│   ├── .bashrc
│   └── .bash_profile
├── nvim/                # Package
│   └── .config/
│       └── nvim/
│           └── init.lua
└── git/                 # Package
    └── .gitconfig

After stowing:
~/.bashrc → ~/dotfiles/bash/.bashrc
~/.config/nvim/init.lua → ~/dotfiles/nvim/.config/nvim/init.lua
~/.gitconfig → ~/dotfiles/git/.gitconfig
```

---

## 🎨 Common Use Cases

### 1. Dotfile Management
Manage all your configuration files with version control.

```bash
# Setup
mkdir -p ~/dotfiles/{bash,nvim,tmux,git}
# ... move configs ...
stow bash nvim tmux git

# Git workflow
cd ~/dotfiles
git add .
git commit -m "Update configs"
git push
```

### 2. Multiple Machines
Different configs per machine.

```bash
# On desktop
stow bash-common bash-desktop nvim-desktop

# On laptop
stow bash-common bash-laptop nvim-laptop
```

### 3. Testing Configs
Test new configurations safely.

```bash
# Current config
stow nvim

# Test new config
stow -D nvim
stow nvim-test

# If good, keep it. If not, rollback.
```

---

## 📋 Basic Commands

```bash
# Stow packages (create symlinks)
stow <package>
stow bash vim git              # Multiple packages

# Unstow packages (remove symlinks)
stow -D <package>
stow -D bash vim git

# Restow (remove and recreate)
stow -R <package>

# Dry run (simulate)
stow -n <package>
stow -nv <package>             # With verbose output

# Custom target
stow -t /path/to/target <package>
```

---

## 🎯 When to Use Stow

### ✅ Use Stow When:
- Managing dotfiles with symlinks
- Want simple, lightweight tool
- Need to organize configs by package
- Managing locally-built software in `/usr/local/`
- Don't need templates or secrets management

### ❌ Consider Alternatives When:
- Need platform-specific templates → Use **Chezmoi**
- Need secrets from password managers → Use **Chezmoi**
- Application doesn't support symlinks → Use **Chezmoi** (copies files)
- Need Nix integration → Use **Home-Manager**

---

## 🔗 Stow vs Chezmoi

| Feature | GNU Stow | Chezmoi |
|---------|----------|---------|
| **Method** | Symlinks | Copies files |
| **Templates** | ❌ No | ✅ Go templates |
| **Secrets** | ❌ No | ✅ Password managers |
| **Simplicity** | ✅ Very simple | Moderate |
| **Cross-platform** | ✅ Yes | ✅ Yes |
| **Learning curve** | Low | Moderate |

**Recommendation:** Use both!
- **Stow** for simple dotfiles that don't need templating
- **Chezmoi** for complex configs with platform differences

---

## 📂 Example Structures

### Simple Dotfiles

```
~/dotfiles/
├── bash/
│   └── .bashrc
├── vim/
│   └── .vimrc
└── git/
    └── .gitconfig
```

### XDG Config Structure

```
~/dotfiles/
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua
├── alacritty/
│   └── .config/
│       └── alacritty/
│           └── alacritty.yml
└── tmux/
    └── .tmux.conf
```

### Complex Multi-Level

```
~/dotfiles/
└── vscode/
    ├── .config/
    │   └── Code/
    │       └── User/
    │           └── settings.json
    └── Library/              # macOS
        └── Application Support/
            └── Code/
                └── User/
                    └── keybindings.json
```

---

## 🛠️ Best Practices

### 1. Use Git

```bash
cd ~/dotfiles
git init
echo ".DS_Store" > .gitignore
git add .
git commit -m "Initial commit"
```

### 2. Create Automation Script

```bash
# ~/dotfiles/stow.sh
#!/bin/bash
PACKAGES=(bash nvim tmux git)

for pkg in "${PACKAGES[@]}"; do
    stow "$pkg"
done
```

### 3. Backup First

```bash
# Before stowing, backup existing configs
mkdir ~/dotfiles-backup
cp ~/.bashrc ~/dotfiles-backup/
cp ~/.vimrc ~/dotfiles-backup/
```

### 4. Document Your Setup

```bash
# Create README
cat > ~/dotfiles/README.md <<'EOF'
# Dotfiles

Managed with GNU Stow.

## Setup
```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./stow.sh
```
EOF
```

---

## 🔧 NixOS Integration

### Use with NixOS

```nix
# configuration.nix
environment.systemPackages = [ pkgs.stow ];
```

### Hybrid Approach

```
System:
├── NixOS → System config, packages
└── Stow → User dotfiles (symlinks)

Benefits:
- NixOS handles system/packages
- Stow handles personal configs
- Simple migration to Fedora
```

---

## 📚 Documentation Structure

1. **Read Overview First** → Understand concepts
2. **Try Quick Start** → Get hands-on experience
3. **Study Examples** → Learn patterns
4. **Create Your Setup** → Apply knowledge

---

## 🎓 Learning Path

### Beginner
1. Read 01-gnu-stow-overview.md
2. Try Example 1 (Simple Dotfiles)
3. Add to Git

### Intermediate
1. Try Example 2 (XDG Config)
2. Create automation script
3. Multi-machine setup

### Advanced
1. Platform-specific configs
2. Complex multi-target setups
3. Integration with other tools

---

## 💡 Quick Tips

### Tip 1: Check Before Stowing
```bash
stow -nv bash  # Dry run with verbose output
```

### Tip 2: Adopt Existing Files
```bash
stow --adopt bash  # Move existing files into package
```

### Tip 3: List Symlinks
```bash
# Find all symlinks to dotfiles
find ~ -type l -ls | grep dotfiles
```

### Tip 4: Verify Package
```bash
# Check what a package would create
cd ~/dotfiles
tree bash
```

---

## 🐛 Common Issues

### Issue: "Target already exists"
```bash
# Solution: Backup and remove, or use --adopt
mv ~/.bashrc ~/.bashrc.backup
stow bash
# or
stow --adopt bash
```

### Issue: Wrong directory structure
```bash
# Wrong:
~/dotfiles/bash/bashrc      # ❌ Missing dot

# Right:
~/dotfiles/bash/.bashrc     # ✅ Matches target
```

### Issue: Stowed to wrong place
```bash
# Make sure you're in stow directory
cd ~/dotfiles  # ← Important!
stow bash

# Or specify target explicitly
stow bash -t ~
```

---

## 📖 External Resources

### Official
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [GitHub Repository](https://github.com/aspiers/stow)

### Tutorials
- [Managing Dotfiles with Stow (Medium)](https://medium.com/quick-programming/managing-dotfiles-with-gnu-stow-9b04c155ebad)
- [Using GNU Stow (GitHub Gist)](https://gist.github.com/andreibosco/cb8506780d0942a712fc)
- [Video Tutorial](https://www.youtube.com/watch?v=06x3ZhwrrwA)

---

## 🎯 Next Steps

1. **Read** [01-gnu-stow-overview.md](01-gnu-stow-overview.md) for detailed concepts
2. **Try** examples from [02-practical-examples.md](02-practical-examples.md)
3. **Create** your own dotfiles setup
4. **Experiment** with different structures
5. **Share** your dotfiles on GitHub!

---

## 📝 Summary

**GNU Stow** is a simple, powerful tool for:
- ✅ Managing dotfiles with symlinks
- ✅ Organizing configs by package
- ✅ Version controlling configurations
- ✅ Easy setup on multiple machines

**Perfect for:** Developers who want lightweight dotfile management without complex features.

**Combine with Chezmoi for:** Platform-specific templates and secrets management.

---

**Created by:** Research session with Claude Code
**Date:** 2025-11-18
**Version:** 1.0

**Ready to start?** → Begin with [01-gnu-stow-overview.md](01-gnu-stow-overview.md)
