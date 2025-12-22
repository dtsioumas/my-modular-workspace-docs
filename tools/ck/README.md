# ck (ck-search) - Semantic Code Search Tool

Consolidated documentation for ck semantic search tool.

## Documentation Index

| Document | Description |
|----------|-------------|
| [overview.md](./overview.md) | General overview and introduction to ck |
| [search-modes.md](./search-modes.md) | Search modes: semantic, lexical, hybrid |
| [gpu-support.md](./gpu-support.md) | GPU acceleration with CUDA/ONNX Runtime |
| [gpu-investigation-2025-12-14.md](./gpu-investigation-2025-12-14.md) | Research on GPU implementation |
| [gpu-rebuild-plan-2025-12-14.md](./gpu-rebuild-plan-2025-12-14.md) | Plan for GPU-enabled rebuild |
| **[capabilities-research-2025-12-21.md](./capabilities-research-2025-12-21.md)** | **✅ Comprehensive research findings** |
| [configuration.md](./configuration.md) | Configuration guide (to be created) |
| [ignore-patterns.md](./ignore-patterns.md) | Ignore patterns and exclusions (to be created) |
| [systemd-automation.md](./systemd-automation.md) | Automated indexing setup (to be created) |

## Quick Links

- **GitHub Repository:** [BeaconBay/ck](https://github.com/BeaconBay/ck)
- **Home-Manager Module:** `home-manager/mcp-servers/rust-custom.nix`
- **Current Version:** 0.7.0
- **Build:** buildRustPackage with GPU support option

## Current Configuration

- **Index Location (Current):** `~/.cache/ck/` (default)
- **Index Location (Planned):** `~/.MyHome/.ck-indexes/` (centralized, synced)
- **Config Management:** Chezmoi templates (per user preference)
- **Auto-indexing:** systemd timer every 4 hours (pending implementation)
- **Search Mode:** Hybrid (semantic + lexical, per user preference)
- **Hidden Dirs:** Selective via ignore list

## Index Scope (Planned)

Directories to index:
- `~/.MyHome/MySpaces/` - All project directories
- `~/.MyHome/Volumes/` - Specific mounted volumes
- `~/.config/` - Configuration files (to understand current workspace)
- `~/` - Directory structure only (not full content scan)

Exclusions (via .ckignore):
- `.git/`, `node_modules/`, `target/`, `.cache/`
- Trash directories, temporary files
- Binary files, large media files

## Related Documentation

- ADR-010: Unified MCP Server Architecture
- docs/tools/semantic-tools-usage.md
- docs/integrations/local-semantic-search-tools/

---

**Status:** Documentation consolidation in progress
**Last Updated:** 2025-12-21
**Next Steps:** Complete research, create configuration templates, implement systemd automation
