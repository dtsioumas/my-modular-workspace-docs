# ck (ck-search) - Semantic Code Search

**Tool:** ck (seek)
**Repository:** https://github.com/BeaconBay/ck
**Stars:** 1k
**License:** MIT/Apache-2.0
**Language:** Rust (86.7%)
**Installation:** `cargo install ck-search`
**Crates.io:** https://crates.io/crates/ck-search

---

## Overview

**ck** is a local-first semantic and hybrid BM25 grep/search tool designed for both AI agents and humans. It finds code by meaning, not just keywords - search for "error handling" and find try/catch blocks, error returns, and exception handling code even when those exact words aren't present.

### Key Differentiator

- **100% offline** - No API keys, no cloud services, no network calls
- **MCP Server built-in** - Direct integration with Claude Code/Desktop
- **Drop-in grep replacement** - Same flags, same behavior

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Semantic Search** | `--sem` finds code by concept, not keywords |
| **Hybrid Search** | `--hybrid` combines semantic + BM25 keyword search |
| **Interactive TUI** | `--tui` launches terminal UI with real-time results |
| **MCP Server** | `--serve` for Claude Code integration |
| **grep Compatible** | All standard grep flags work |
| **Automatic Indexing** | Delta indexing with chunk-level caching |
| **Tree-sitter Parsing** | Language-aware code chunking |

---

## Installation

### Via Cargo (Recommended for Nix)

```bash
cargo install ck-search
```

### Via Home-Manager (Planned)

```nix
# home-manager/ck-search.nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    (rustPlatform.buildRustPackage rec {
      pname = "ck-search";
      version = "0.7.0";

      src = fetchFromGitHub {
        owner = "BeaconBay";
        repo = "ck";
        rev = version;
        sha256 = "sha256-...";  # Get from nix-prefetch-github
      };

      cargoLock = {
        lockFile = "${src}/Cargo.lock";
      };

      meta = {
        description = "Semantic and hybrid BM25 grep/search tool";
        homepage = "https://github.com/BeaconBay/ck";
        license = with lib.licenses; [ mit asl20 ];
      };
    })
  ];
}
```

---

## Usage

### Basic Semantic Search

```bash
# Find code by meaning
ck --sem "error handling" src/
ck --sem "authentication logic" src/
ck --sem "database connection pooling" src/

# Get complete functions/classes
ck --sem --full-section "error handling"
```

### Hybrid Search (Best of Both)

```bash
# Combine keyword precision with semantic understanding
ck --hybrid "async timeout" src/
ck --hybrid --scores "cache" src/   # Show relevance scores
```

### Traditional grep Mode

```bash
# All muscle memory works
ck -i "warning" *.log              # Case-insensitive
ck -n -A 3 -B 1 "error" src/       # Line numbers + context
ck -l "error" src/                  # List files with matches only
ck -R --exclude "*.test.js" "bug"  # Recursive with exclusions
```

### Interactive TUI

```bash
# Launch interactive interface
ck --tui
ck --tui "error handling"  # Start with query

# TUI Keybindings:
# Tab - Toggle between Semantic/Regex/Hybrid
# Ctrl+V - Switch preview mode (Heatmap/Syntax/Chunk)
# Ctrl+F - Toggle snippet/full-file view
# Ctrl+Space - Multi-select files
# Enter - Open in $EDITOR
```

### MCP Server for Claude Code

```bash
# Start MCP server
ck --serve

# Add to Claude Code (recommended)
claude mcp add ck-search -s user -- ck --serve

# Verify
claude mcp list
```

**Available MCP Tools:**
- `semantic_search` - Find code by meaning
- `regex_search` - grep-style pattern matching
- `hybrid_search` - Combined semantic + keyword
- `index_status` - Check indexing status
- `reindex` - Force rebuild index
- `health_check` - Server diagnostics

---

## Configuration

### Index Storage

Indexes stored in `.ck/` directories (can be safely deleted):

```
project/
├── src/
├── docs/
└── .ck/           # Semantic index cache
    ├── embeddings.json
    ├── ann_index.bin
    └── tantivy_index/
```

### Exclusion Patterns

```bash
# Uses .gitignore + .ckignore + defaults
ck "pattern" .

# Custom exclusions
ck --exclude "dist" --exclude "logs" .

# .ckignore syntax (same as .gitignore)
# Auto-created on first index
```

### Embedding Models

```bash
# Default: BGE-Small (fast, 400-token chunks)
ck --index .

# Enhanced: Nomic V1.5 (8K context, 1024-token chunks)
ck --index --model nomic-v1.5 .

# Code-specialized: Jina Code
ck --index --model jina-code .
```

**Model Comparison:**

| Model | Chunk Size | Best For |
|-------|------------|----------|
| `bge-small` (default) | 400 tokens | Most code, fast indexing |
| `nomic-v1.5` | 1024 tokens | Large functions |
| `jina-code` | 1024 tokens | Code understanding |

### Model Cache Locations

- Linux/macOS: `~/.cache/ck/models/`
- Windows: `%LOCALAPPDATA%\ck\cache\models\`
- Fallback: `.ck_models/models/`

---

## Language Support

| Language | Indexing | Tree-sitter | Semantic Chunking |
|----------|----------|-------------|-------------------|
| Python | Yes | Yes | Functions, classes |
| JavaScript/TypeScript | Yes | Yes | Functions, classes, methods |
| Rust | Yes | Yes | Functions, structs, traits |
| Go | Yes | Yes | Functions, types, methods |
| Ruby | Yes | Yes | Classes, methods, modules |
| Haskell | Yes | Yes | Functions, types, instances |
| C# | Yes | Yes | Classes, interfaces, methods |
| Zig | Yes | Yes | Contributed by @Nevon |

**Text Formats:** Markdown, JSON, YAML, TOML, XML, HTML, CSS, shell scripts, SQL, log files, config files.

---

## Integration with My-Modular-Workspace

### Recommended Setup

1. **Install via Home-Manager** (packages)
2. **Configure via Chezmoi** (config files if any)
3. **Register as MCP server** for Claude Code

### Use Cases

```bash
# Search ansible playbooks semantically
ck --sem "backup configuration" ~/.MyHome/MySpaces/my-modular-workspace/ansible/

# Search home-manager configs
ck --sem "systemd service" ~/.MyHome/MySpaces/my-modular-workspace/home-manager/

# Search documentation
ck --hybrid "migration plan" ~/.MyHome/MySpaces/my-modular-workspace/docs/

# Full workspace search
ck --sem "rclone sync" ~/.MyHome/MySpaces/my-modular-workspace/
```

### JSON/JSONL Output (for automation)

```bash
# JSONL format (streaming, one object per line)
ck --jsonl --sem "error handling" src/

# Traditional JSON (single array)
ck --json --sem "error handling" src/ | jq '.file'

# High-confidence results only
ck --jsonl --topk 5 --threshold 0.7 "auth"
```

---

## Performance

- **Indexing:** ~1M LOC in under 2 minutes
- **Incremental indexing:** 80-90% cache hit rate
- **Search:** Sub-500ms queries on typical codebases
- **Index size:** ~2x source code size with compression
- **Memory:** Efficient streaming for large repos

---

## Comparison with Alternatives

| Tool | Type | Offline | MCP | Semantic | grep-compatible |
|------|------|---------|-----|----------|-----------------|
| **ck** | Semantic | Yes | Yes | Yes | Yes |
| semtools | Semantic | Partial | No | Yes | No |
| w2vgrep | Word2Vec | Yes | No | Yes | Partial |
| ripgrep | Exact | Yes | No | No | Yes |
| ast-grep | AST | Yes | No | No | No |

---

## Why ck for My-Modular-Workspace?

1. **100% Local** - No API keys, works offline
2. **MCP Integration** - Native Claude Code support
3. **grep Replacement** - Drop-in for existing workflows
4. **Rust-based** - Easy to package for NixOS
5. **Code-Aware** - Tree-sitter parsing for accurate chunking
6. **Low Overhead** - Single binary, no services to run

---

## References

- **GitHub:** https://github.com/BeaconBay/ck
- **Crates.io:** https://crates.io/crates/ck-search
- **Documentation:** https://beaconbay.github.io/ck/
- **TUI Guide:** https://github.com/BeaconBay/ck/blob/main/TUI.md

---

## Changelog

| Date | Version | Notes |
|------|---------|-------|
| 2025-10-13 | v0.7.0 | Latest release |
| 2025-12-01 | - | Documented for my-modular-workspace |

---

**Maintained by:** mitsio
**Documentation Path:** `docs/tools/ck-search.md`
