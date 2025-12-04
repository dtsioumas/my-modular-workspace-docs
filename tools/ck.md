# CK (Seek) - Semantic and Hybrid Code Search

**Version:** 0.7.1 (Nov 2025)
**Repository:** https://github.com/BeaconBay/ck
**License:** MIT / Apache-2.0
**Status:** ❌ NOT INSTALLED (Available via crates.io)

## Overview

CK is a comprehensive semantic code search tool that combines semantic understanding with traditional grep features. It's designed for both AI agents and humans, with multiple interfaces (CLI, TUI, MCP server).

**Key Concept:** "grep that understands what you're looking for" - find code by meaning, not just keywords.

## Key Features

### 🔍 Multiple Search Modes

1. **Semantic Search** (`--sem`)
   - Find code by concept using embeddings
   - Example: Search "error handling" finds try/catch, error returns, exceptions

2. **Hybrid Search** (`--hybrid`)
   - Combines semantic understanding + BM25 keyword matching
   - Best of both worlds using Reciprocal Rank Fusion

3. **Regex Search** (default)
   - Traditional grep-compatible pattern matching
   - Full grep flag compatibility

### 🎨 Interactive TUI

```bash
ck --tui                          # Launch interactive interface
ck --tui "error handling"         # Start with query
```

**TUI Features:**
- Multiple search modes (Semantic/Regex/Hybrid) - toggle with `Tab`
- Preview modes (Heatmap/Syntax/Chunks) - toggle with `Ctrl+V`
- Multi-select files with `Ctrl+Space`
- Open in `$EDITOR` with line numbers
- Real-time indexing progress

### 🤖 Built-in MCP Server

```bash
ck --serve                        # Start MCP server
```

**MCP Tools:**
- `semantic_search` - Find by meaning
- `regex_search` - Pattern matching
- `hybrid_search` - Combined search
- `index_status` - Check index
- `reindex` - Rebuild index
- `health_check` - Server diagnostics

**Claude Desktop Setup:**
```bash
claude mcp add ck-search -s user -- ck --serve
```

### ⚙️ Automatic Indexing

- Indexes stored in `.ck/` directories
- Chunk-level incremental updates (80-90% cache hit rate)
- Only changed chunks re-embedded
- Content-aware invalidation

## Installation

### Via Cargo (crates.io)

```bash
cargo install ck-search
```

### Via NixOS/home-manager

**Option 1: Simple package installation**
```nix
{ pkgs, ... }:
{
  home.packages = [
    # Note: Requires building from crates.io, not in nixpkgs
    # Use rustPlatform.buildRustPackage or install via cargo
  ];
}
```

**Option 2: Via cargo in home-manager**
```nix
{ pkgs, ... }:
{
  # Ensure cargo is available
  home.packages = with pkgs; [ cargo ];

  # Install ck via cargo
  home.activation.installCk = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v ck &> /dev/null; then
      $DRY_RUN_CMD ${pkgs.cargo}/bin/cargo install ck-search
    fi
  '';
}
```

**NOT in nixpkgs** - Must install via cargo or build custom derivation.

## Usage

### Basic Semantic Search

```bash
# Search by concept
ck --sem "error handling" src/
ck --sem "authentication logic" src/
ck --sem "database connection" src/

# With context
ck --sem -A 3 -B 1 "retry logic" src/

# Complete functions/classes
ck --sem --full-section "validation" src/
```

### Hybrid Search

```bash
# Combine semantic + keyword
ck --hybrid "async timeout" src/
ck --hybrid --scores "cache" src/          # Show relevance scores
ck --hybrid --threshold 0.02 "query" .     # Filter by relevance
```

### Traditional Grep Mode

```bash
# Fully grep-compatible
ck -i "warning" *.log                      # Case-insensitive
ck -n -A 3 "error" src/                    # Line numbers + context
ck -l "TODO" src/                          # List files only
ck -R --exclude "*.test.js" "bug" .        # Recursive with exclusions
```

### Relevance Filtering

```bash
# Threshold control
ck --sem --threshold 0.7 "query"           # High-confidence only
ck --sem --topk 5 "authentication"         # Top 5 results

# Show scores with color highlighting
ck --sem --scores "machine learning" docs/
# Output: [0.847] ./ai_guide.txt: Machine learning...
```

### JSON/JSONL Output

```bash
# For AI agents and scripts
ck --jsonl --sem "error handling" src/
ck --json --sem "auth" . | jq '.file'
ck --jsonl --no-snippet "function" .       # Metadata only
```

## Configuration

### Embedding Models

Choose model based on needs:

```bash
# Default: BGE-Small (fast, 400-token chunks)
ck --index .

# Enhanced: Nomic V1.5 (8K context, 1024-token chunks)
ck --index --model nomic-v1.5 .

# Code-specialized: Jina Code (8K context, optimized for code)
ck --index --model jina-code .
```

**Model Comparison:**
- **bge-small** (default): Fast, good for most code
- **nomic-v1.5**: Better for large functions, 8K capacity
- **jina-code**: Specialized for programming languages

### File Exclusions

```bash
# Respects .gitignore and .ckignore
ck "pattern" .

# Skip .gitignore (still uses .ckignore)
ck --no-ignore "pattern" .

# Skip .ckignore (still uses .gitignore)
ck --no-ckignore "pattern" .

# Custom exclusions
ck --exclude "node_modules" --exclude "*.log" "pattern" .
```

**.ckignore file:**
- Auto-created on first index
- Uses `.gitignore` syntax
- Excludes images, videos, audio, binaries by default
- Persists across searches
- Located at repository root

### Index Management

```bash
# Check status
ck --status .

# Rebuild index
ck --clean .

# Switch models
ck --switch-model nomic-v1.5 .
ck --switch-model nomic-v1.5 --force .     # Force rebuild

# Add single file
ck --add new_file.rs

# Inspect chunking
ck --inspect src/main.rs
ck --inspect --model bge-small src/main.rs
```

**Index Storage:**
- Location: `.ck/` directories alongside code
- Can be safely deleted and rebuilt
- Typical size: 1-3x source code size

## Integration with MySpaces

### Recommended Setup

```bash
# Navigate to MySpaces
cd ~/.MyHome/MySpaces/my-modular-workspace

# Index the codebase
ck --index .

# Semantic search
ck --sem "kubernetes deployment" docs/**/*.md --topk 10
ck --sem "ansible playbook" . --full-section

# Hybrid search for specific terms
ck --hybrid "rclone sync" . --scores
```

### Claude Code Integration

Add to `.claude/CLAUDE.md`:

```markdown
## Semantic Search: ck

Multi-modal semantic code search tool:

**Search Modes:**
- `ck --sem "query"` - Semantic search by meaning
- `ck --hybrid "query"` - Semantic + keyword (best balance)
- `ck "pattern"` - Traditional regex (grep-compatible)

**Advanced:**
- `ck --tui` - Interactive TUI
- `ck --serve` - MCP server (if configured)
- `ck --jsonl --sem "query"` - Structured output for scripting

**Examples:**
```bash
# Find error handling code
ck --sem "error handling" src/

# Hybrid search with scores
ck --hybrid --scores "database connection" .

# Complete functions
ck --sem --full-section "authentication" src/
```
```

### Via MCP Server

Can be configured as MCP server for Claude Desktop:

```json
{
  "mcpServers": {
    "ck": {
      "command": "ck",
      "args": ["--serve"],
      "cwd": "/home/mitsio/.MyHome/MySpaces/my-modular-workspace"
    }
  }
}
```

## Comparison with Other Tools

### vs. semtools

| Feature | ck | semtools |
|---------|-----|----------|
| **Search types** | Semantic + BM25 + Regex | Semantic only (4 commands) |
| **Interface** | CLI + TUI + MCP | CLI only |
| **Indexing** | Automatic .ck/ dirs | Workspace caching |
| **Model** | FastEmbed (multiple) | model2vec (embedded) |
| **Installation** | cargo only | nixpkgs |
| **Best for** | Comprehensive search | Document parsing + search |

### vs. semantic-grep (w2vgrep)

| Feature | ck | semantic-grep |
|---------|-----|---------------|
| **Matching** | Line + chunk | Word-level |
| **Interface** | CLI + TUI + MCP | Grep-like CLI |
| **Model** | FastEmbed (embedded) | word2vec (separate 350MB) |
| **Hybrid search** | Yes (BM25 + semantic) | No |
| **Installation** | cargo | Build from source (Go) |
| **Best for** | Comprehensive search | Grep-like semantic search |

## Language Support

**Full Support (Tree-sitter + chunking):**
- Python, JavaScript/TypeScript, Rust, Go, Ruby, Haskell, C#, Zig

**Text Formats:**
- Markdown, JSON, YAML, TOML, XML, HTML, CSS
- Shell scripts, SQL, log files, config files

**Binary Detection:**
- Automatic text vs binary detection (ripgrep-style)
- Text files with unrecognized extensions indexed as plain text

## Performance

- **Indexing:** ~1M LOC in under 2 minutes
- **Incremental:** 80-90% cache hit rate on changes
- **Search:** Sub-500ms on typical codebases
- **Index size:** 1-3x source code size
- **Memory:** Efficient streaming for large repos

## Advanced Features

### Query-Based Chunking

Uses Tree-sitter queries for semantic code analysis:
- Function/class boundary detection
- Ancestry and breadcrumbs in metadata
- Gap-filling for imports
- Language-specific optimizations

### TUI Keyboard Shortcuts

- `Tab` - Toggle search modes (Semantic/Regex/Hybrid)
- `Ctrl+V` - Toggle preview modes (Heatmap/Syntax/Chunks)
- `Ctrl+F` - Toggle snippet/full-file view
- `Ctrl+Space` - Multi-select files
- `Enter` - Open in editor
- `Ctrl+Up/Down` - Search history

### MCP Pagination

Built-in pagination for large result sets:
- Configurable page size (1-200 results)
- Cursor-based navigation
- Snippet length management

## Common Use Cases

### Code Discovery

```bash
# Find authentication/authorization
ck --sem "user permissions" src/
ck --sem "access control" src/

# Find performance code
ck --sem "caching strategies" src/
ck --sem "database optimization" src/
```

### Team Workflows

```bash
# Find related tests
ck --sem "unit tests for auth" tests/

# Identify refactoring candidates
ck --sem "duplicate logic" src/
ck -L "test" src/                    # Files without tests
```

### Security Audit

```bash
# Find security-sensitive code
ck --hybrid "password|credential|secret" src/
ck --sem "input validation" src/
```

### Documentation

```bash
# Find public APIs
ck --json --sem "public API" src/ | generate_docs.py

# Code review prep
ck --hybrid --scores "performance" src/ > review.txt
```

## Installation Requirements

### System Dependencies

- Rust toolchain (for cargo install)
- ~500MB disk space (binary + models)

### Model Downloads

Models cached in:
- Linux/macOS: `~/.cache/ck/models/`
- Windows: `%LOCALAPPDATA%\ck\cache\models\`
- Fallback: `.ck_models/models/` in current directory

Downloaded automatically on first use.

## Troubleshooting

### Index Issues

```bash
# Rebuild index
ck --clean .
ck --index .

# Check status
ck --status .
```

### No Results

```bash
# Lower threshold
ck --sem --threshold 0.5 "query"

# Try hybrid search
ck --hybrid "query"

# Verify index exists
ls -la .ck/
```

### Slow Performance

```bash
# Use bge-small (faster)
ck --switch-model bge-small .

# Limit results
ck --sem --topk 10 "query"
```

## Future Roadmap

- ✅ MCP server (v0.7+)
- ✅ TUI interface (v0.7+)
- ✅ Chunk-level incremental indexing (v0.7+)
- 🚧 Configuration file support
- 🚧 Package manager distributions (brew, apt)
- 🚧 VS Code extension
- 🚧 JetBrains plugin

## References

- **GitHub:** https://github.com/BeaconBay/ck
- **Documentation:** https://beaconbay.github.io/ck/
- **Crates.io:** https://crates.io/crates/ck-search
- **Examples:** https://github.com/BeaconBay/ck/blob/main/EXAMPLES.md

## Related Tools

- **semtools** - Document parsing + semantic search with workspace caching
- **semantic-grep (w2vgrep)** - Word-level grep-like semantic search
- **ripgrep** - Fast exact/regex text search
