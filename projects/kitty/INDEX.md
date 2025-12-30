# Project: Kitty Terminal Enhancements

**Status:** ACTIVE
**Goal:** Transform Kitty into a high-performance, SRE-optimized terminal with deep integration into the workspace.

## Documentation Index

- [**RESEARCH.md**](RESEARCH.md): Consolidated research on GPU optimization, tab bar customization, and integration possibilities (Obsidian, Browsers, etc.).
- [**PLAN.md**](PLAN.md): Active implementation plan for pending features (Tmux persistence, secure remote control).
- [**USAGE.md**](USAGE.md): Quick reference for shortcuts, kittens, and custom integrations.
- [**TESTING.md**](TESTING.md): Verification checklists for all kitty-related features.

## Key Features
- **GPU Acceleration**: Optimized for NVIDIA GTX 960 (6ms repaint delay).
- **Consolidated Tab Bar**: Powerline-style bar with SRE metrics (CPU, RAM, Load).
- **Zellij Integration**: Native multiplexing with shared themes.
- **Search Kitten**: Incremental scrollback search.
- **Markdown Support**: Integrated `glow` and `bat` for document viewing.

## Related Resources
- **Nix Module**: `home-manager/modules/apps/terminals/kitty.nix`
- **Dotfiles**: `dotfiles/private_dot_config/kitty/`
