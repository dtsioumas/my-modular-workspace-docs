# Dotfiles Management Documentation

**Created:** 2025-12-02
**Purpose:** Central documentation for dotfiles management strategy across NixOS and future Fedora migration

---

## Overview

This directory contains all documentation related to dotfiles management, including:
- **Chezmoi** - Cross-platform dotfile manager
- **Plasma** - KDE Plasma desktop configuration migration planning
- **General** - Dotfiles strategy, best practices, and migration guides

---

## Directory Structure

```
dotfiles/
├── readme.md                    # This file
├── chezmoi/                     # General chezmoi documentation
│   ├── 01-chezmoi-overview.md
│   ├── 02-migration-strategy.md
│   ├── 03-implementation-guide.md
│   ├── 04-best-practices.md
│   ├── 05-research-findings.md
│   ├── 06-tool-migration-guides.md
│   ├── 07-symlink-setup.md
│   ├── dotfiles-inventory.md
│   └── readme.md
└── plasma/                      # Plasma desktop migration project
    ├── session-context.md       # Session overview & goals
    ├── local-investigation.md   # Complete file inventory
    └── research-findings.md     # Web research results
```

---

## Quick Links

### Chezmoi Documentation
- [Overview](chezmoi/01-chezmoi-overview.md) - What is chezmoi and why use it
- [Migration Strategy](chezmoi/02-migration-strategy.md) - Phased approach
- [Implementation Guide](chezmoi/03-implementation-guide.md) - Hands-on setup
- [Best Practices](chezmoi/04-best-practices.md) - Patterns and tips

### Plasma Migration Project
- [Session Context](plasma/session-context.md) - Project goals and status
- [Local Investigation](plasma/local-investigation.md) - Complete config inventory
- [Research Findings](plasma/research-findings.md) - Best practices and tools

---

## Current Status

### Chezmoi Setup
✅ **Active** - Currently managing select dotfiles:
- atuin, copyq, keepassxc, kitty, navi, vscodium
- bashrc, gitconfig (templated)

### Plasma Migration
📋 **Planning Phase** - Phases 0-2 complete:
- ✅ Phase 0: Documentation consolidation
- ✅ Phase 1: Local investigation (40+ plasma configs discovered)
- ✅ Phase 2: Web research (chezmoi_modify_manager discovered)
- ⏳ Phase 3: Migration planning (next session)

---

## Strategy Overview

**Hybrid Approach:**
1. **plasma-manager** (NixOS) - High-level desktop structure
2. **chezmoi** - User-specific preferences, cross-platform
3. **chezmoi_modify_manager** - Filter volatile sections from KDE configs

**Goal:** Prepare dotfiles for Fedora Atomic migration while maintaining NixOS compatibility.

---

## Related Documentation

- `docs/adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md` - What goes in chezmoi vs home-manager
- `docs/tools/plasma-manager.md` - plasma-manager usage guide
- `docs/TODO.md` - Main project TODO list

---

**Last Updated:** 2025-12-02T20:25:00+02:00 (Europe/Athens)
