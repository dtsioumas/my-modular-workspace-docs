# Chezmoi Documentation

**Updated:** 2025-12-14
**Purpose:** Comprehensive guide for chezmoi dotfile management on NixOS

---

## Documentation Index

| Document | Description |
|----------|-------------|
| [chezmoi-guide.md](chezmoi-guide.md) | **Comprehensive guide** - setup, templates, secrets, migration, best practices |
| [MIGRATION_STATUS.md](MIGRATION_STATUS.md) | Current migration progress and what's managed |
| [DOTFILES_INVENTORY.md](DOTFILES_INVENTORY.md) | Complete inventory with priorities and investigation findings |
| README.md (this file) | Index and quick reference |

---

## Quick Reference

### Chezmoi Commands

```bash
chezmoi status          # Show differences
chezmoi diff            # Show what would change
chezmoi apply           # Apply changes
chezmoi add <file>      # Add file to management
chezmoi re-add <file>   # Update source from destination
chezmoi managed         # List managed files
chezmoi verify          # Verify managed files
```

### Repository Location

- **Chezmoi source:** `~/.local/share/chezmoi/` (symlink to dotfiles repo)
- **Dotfiles repo:** `~/.MyHome/MySpaces/my-modular-workspace/dotfiles/`
- **GitHub:** https://github.com/dtsioumas/dotfiles

---

## Architecture: Chezmoi + Home-Manager Split

### What Goes Where

| Component | Manager | Rationale |
|-----------|---------|-----------|
| Packages | Home-Manager | Nix package management |
| Systemd services | Home-Manager | Service lifecycle management |
| Environment variables | Home-Manager | Shell integration |
| Application configs | Chezmoi | Cross-platform, simple files |
| Secrets (templates) | Chezmoi | KeePassXC integration |
| Global instructions (CLAUDE.md) | Home-Manager | Tightly coupled to nix module |

### Decision Criteria (ADR-005)

**Use Chezmoi when:**
- Cross-platform compatibility needed
- Simple config files (ini, toml, yaml, json)
- Application settings only (not packages/services)
- Template benefits apply (machine-specific values)

**Use Home-Manager when:**
- Package management required
- Systemd services involved
- Nix-specific features used
- System integration needed

---

## Claude Code Split Documentation

### Current Management

| File | Manager | Location |
|------|---------|----------|
| `~/.claude/CLAUDE.md` | **Home-Manager** | Symlink to nix-store |
| `~/.claude/settings.json` | **Chezmoi** | `private_dot_claude/settings.json` |
| `~/.claude/mcp_config.json` | **Chezmoi** | `private_dot_claude/mcp_config.json.tmpl` |
| `~/.claude/commands/*.md` | **Chezmoi** | `private_dot_claude/commands/` |
| `~/.config/Claude/claude_desktop_config.json` | **Chezmoi** | `private_dot_config/Claude/` |
| Runtime files (cache, debug, history) | **None** | Not managed (correct) |

### Why CLAUDE.md is Home-Manager Managed

1. **Nix module integration:** CLAUDE.md is generated as part of the `claude.nix` home-manager module
2. **System-level instructions:** Contains global instructions that are tightly coupled to the Nix ecosystem
3. **Declarative management:** Home-manager ensures consistent state across rebuilds
4. **Per ADR-005:** System integration files stay in home-manager

### Why Other .claude/ Files are Chezmoi Managed

1. **Cross-platform:** settings.json, mcp_config.json work on any system
2. **Simple configs:** JSON files without Nix-specific logic
3. **Template benefits:** mcp_config.json uses chezmoi templates for paths
4. **Application settings:** These are Claude Code app configs, not system integration

### Verifying the Split

```bash
# Check CLAUDE.md symlink (home-manager)
ls -la ~/.claude/CLAUDE.md
# Should show: CLAUDE.md -> /nix/store/...-home-manager-files/.claude/CLAUDE.md

# Check chezmoi-managed files
chezmoi managed | grep claude
# Should show: .claude/settings.json, .claude/mcp_config.json, .claude/commands/*
```

---

## Related Documentation

- [ADR-005: Chezmoi Migration Criteria](../adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md)
- [Chezmoi Modify Manager](../tools/chezmoi-modify-manager.md)
- [Dotfiles README](../../dotfiles/README.md)

---

## External Resources

- [Chezmoi Official Docs](https://www.chezmoi.io/)
- [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
- [Command Reference](https://www.chezmoi.io/reference/commands/)

---

**Maintained by:** Dimitris Tsioumas
**Last Updated:** 2025-12-14
