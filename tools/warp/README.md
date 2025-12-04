# Warp Terminal Documentation

This directory contains documentation for installing and configuring Warp Terminal on the shoshin workspace.

## Overview

Warp is a modern, Rust-based terminal with AI-powered features, modern text editing, and GPU acceleration. This documentation covers its integration into the NixOS-based shoshin workspace using home-manager for installation and chezmoi for configuration management.

**Strategy**: Parallel installation with Kitty - Kitty remains main terminal, Warp for specialized workspace tasks.

## Main Documentation

📚 **[WARP_COMPLETE_GUIDE.md](./WARP_COMPLETE_GUIDE.md)** - Complete guide with all findings, workflows, and configuration

📋 **[../../project-plans/PLAN_WARP_IMPLEMENTATION.md](../../project-plans/PLAN_WARP_IMPLEMENTATION.md)** - Step-by-step implementation plan

## Additional Resources

- **[warp-terminal-research.md](./warp-terminal-research.md)** - Initial package research
- **[warp-terminal-flake-experience.md](./warp-terminal-flake-experience.md)** - Flake building insights
- **[USER_QUESTIONS.md](./USER_QUESTIONS.md)** - Decision questionnaire (completed)
- **[IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md)** - Old plan (see project-plans/ for current)

## Quick Reference

### Package Information
- **Package Name**: `warp-terminal`
- **Channel**: nixpkgs-unstable
- **License**: Unfree (requires `allowUnfree = true`)
- **Platforms**: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin

### Configuration Locations
- **Config**: `~/.config/warp-terminal/`
- **Data**: `~/.local/share/warp-terminal/`
- **State**: `~/.local/state/warp-terminal/`
- **Launch Configs**: `${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal/launch_configurations/`

### Current Status
- ✅ Research completed
- ⏳ Implementation plan ready
- ⏳ Awaiting user preferences
- ⏳ Installation pending
- ⏳ Configuration migration pending

## Related Files
- **Home Manager**: `home-manager/warp.nix` (to be created)
- **Chezmoi/Dotfiles**: `dotfiles/dot_config/warp-terminal/` (to be created)
- **Shoshin NixOS**: Integration with existing terminal setup

## Key Findings

1. **No Home Manager Module**: Warp doesn't have a `programs.warp-terminal` module, requires `home.packages` approach
2. **GPU Acceleration Important**: NVIDIA GTX 960 needs specific environment variables
3. **Account Required**: Warp requires user account creation
4. **AI Features**: Includes AI-powered command generation and code writing
5. **Configuration via YAML**: Launch configurations and settings use YAML format

---

**Last Updated**: 2025-12-04
**Workspace**: shoshin
**Status**: Research & Planning Phase
