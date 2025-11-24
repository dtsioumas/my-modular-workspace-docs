# NixOS Configuration - Shoshin Desktop

**Host:** shoshin
**System:** NixOS 25.05
**Desktop:** KDE Plasma 6
**Project:** other-projects-desktop-workspace

---

## 📁 Directory Structure

```
~/.config/nixos/
├── flake.nix                 # Flake configuration
├── README.md                 # This file
├── docs/                     # → Symlink to desktop-workspace
├── hosts/shoshin/            # System configuration
├── modules/                  # Modular configs
└── home/mitso/               # User home-manager config
```

## 🎯 Project: Desktop Workspace Optimization

**Main Documentation:**
- **TODO:** `~/.config/nixos/docs/desktop-workspace/TODO.md`
- **Instructions:** `/home/mitso/Workspaces/Personal_Workspace/llm-tsukuru-project/llm-core/instructions/projects/other-projects-desktop-workspace_INSTRUCTIONS.md`

## 🔧 Key Configurations

- **workspace/plasma-optimization.nix** - KDE memory optimization
- **workspace/brave-fixes.nix** - Brave with NVIDIA + memory limits
- **home/mitso/kitty.nix** - Terminal (symlink to common-dotfiles)
- **home/mitso/vscode.nix** - VSCode with Claude Code + MCPs

## 🚀 Common Commands

```bash
# Rebuild system
cd ~/.config/nixos
sudo nixos-rebuild switch --flake .#shoshin

# Test changes first
sudo nixos-rebuild test --flake .#shoshin
```

## 🔄 Session Initialization (Claude Code)

When starting conversation on this project:
1. Read: `/home/mitso/Workspaces/Personal_Workspace/llm-tsukuru-project/llm-core/instructions/projects/other-projects-desktop-workspace_INSTRUCTIONS.md`
2. Check: `~/.config/nixos/docs/desktop-workspace/TODO.md`
3. Review: `cd ~/.config/nixos && git log --oneline -10`

---

**Last Updated:** 2025-11-09
