# Comprehensive Research: `ck` (ck-search) Semantic Search Tool

**Research Date:** 2025-12-21
**Status:** Complete
**Agent ID:** ae0b997

Based on research from the [GitHub repository](https://github.com/BeaconBay/ck), [official documentation](https://beaconbay.github.io/ck/), and various technical sources.

---

## 1. Index Storage & Configuration

### Index Location

**Project-level indexes:**
- Stored in `.ck/` directory at the repository root
- Contains three main components:
  - `embeddings.json` - serialized embeddings
  - `ann_index.bin` - approximate nearest neighbor index
  - `tantivy_index/` - BM25/keyword search index

**Model cache:**
- Embedding models (ONNX format) cached in platform-specific directories
- Linux/macOS: `~/.cache/ck/models/`
- The `.ck/` directory acts as a disposable cache - can be safely deleted and rebuilt anytime

### Configuration

**No explicit config file** - `ck` operates through command-line flags rather than a configuration file like `~/.config/ck/config.toml`. All behavior is controlled via CLI arguments.

**Index size:**
- Typically 1-3x the size of your source code
- Scales with codebase size and chosen embedding model

### Environment Variables

Not explicitly documented in available sources. The tool appears to rely primarily on CLI flags for configuration.

---

## 2. Ignore Patterns

### Multi-layer Filtering Approach

**`.gitignore` integration:**
- Respects `.gitignore` files by default
- Can skip with `--no-ignore` flag
- Example: `ck --no-ignore "pattern" .` (uses only `.ckignore`)

**`.ckignore` file:**
- Automatically created on first index at repository root
- Uses same glob syntax as `.gitignore`
- Supports negation patterns with `!`
- Persists across searches and is user-editable

**Default exclusions in `.ckignore`:**
- Images, videos, audio files
- Binaries and archives
- JSON/YAML configuration files

**Why separate `.ckignore`?**
Many files should be in version control but aren't ideal for semantic search. This allows you to maintain files in Git while excluding them from semantic indexing.

### Custom Exclusions

**Command-line exclusions:**
```bash
ck --exclude "dist" --exclude "logs" "pattern" .
```

**Smart binary detection:**
- Detects text vs binary based on file contents, not just extensions
- Reduces noise in semantic search results

**Combined usage examples:**
```bash
ck "pattern" .                              # Uses .gitignore + .ckignore + defaults
ck --no-ignore "pattern" .                  # Skip .gitignore (still uses .ckignore)
ck --no-ckignore "pattern" .                # Skip .ckignore (still uses .gitignore)
ck --exclude "node_modules" "pattern" .     # Add custom exclusions
```

---

## 3. Indexing Behavior

### Automatic Indexing

**Transparent operation:**
- Semantic and hybrid searches automatically create/refresh indexes before running
- First search builds what's needed
- Subsequent searches leverage cached embeddings

**Delta indexing (80-90% cache hit rate):**
- Only changed chunks are re-embedded
- Chunk-level caching with hash-based invalidation
- Uses `blake3(text + trivia)` for reliable change detection

**Content-aware invalidation:**
- Doc comments and whitespace changes properly trigger re-indexing
- Prevents stale embeddings from affecting results

### Index Management Commands

**Status and inspection:**
```bash
ck --status              # Check indexing status and metadata
ck --inspect file.rs     # Analyze chunking and token usage for a file
ck --inspect --model bge-small src/main.rs  # Test different models
```

**Index maintenance:**
```bash
ck --clean .             # Clean up and rebuild index
ck --add new_file.rs     # Add single file to index
ck --switch-model nomic-v1.5  # Switch embedding model
ck --switch-model jina-code --force  # Force rebuild with new model
```

**Model switching:**
- Prevents silent embedding corruption when changing models
- Optional `--force` flag for complete rebuild
- Model consistency checks ensure cache validity

### Pre-building Indexes

**For automation/CI:**
While not explicitly documented, you can trigger index creation by running a semantic search:
```bash
ck --sem "placeholder" .  # Builds index
```

### Multi-directory Support

Not explicitly documented. The tool appears to operate on a single directory tree per invocation, though you could run multiple instances for different directories.

---

## 4. Search Modes & Features

### Three Primary Search Modes

**1. Semantic Search (`--sem`):**
- Finds code by concept using embeddings
- Example: searching "error handling" returns try/catch blocks even without exact keyword matches
- Uses cosine similarity on vector embeddings

**2. Regex/Keyword Search:**
- Traditional grep-compatible pattern matching
- Standard regex syntax support

**3. Hybrid Search (`--hybrid`):**
- Combines semantic relevance with keyword filtering
- Uses Reciprocal Rank Fusion (RRF) to merge results
- Balances meaning-based and keyword-based matching

### Embedding Models

Three options with different trade-offs:

| Model | Chunk Size | Context Window | Specialization |
|-------|-----------|----------------|----------------|
| **bge-small** (default) | 400 tokens | Standard | Fast indexing, general purpose |
| **nomic-v1.5** | 1024 tokens | 8K | Larger context, better for complex code |
| **jina-code** | 1024 tokens | Standard | Code-specialized embeddings |

**Model characteristics:**
- All models use ONNX format for local inference
- Downloaded once and cached locally
- No network calls after initial download

### Search Features

**Filtering and tuning:**
```bash
--threshold <float>     # Minimum relevance score (semantic/hybrid only)
--topk <n>             # Limit total results
--full-section         # Return complete functions/classes containing matches
--scores               # Display relevance scores with color highlighting
```

**Grep compatibility flags:**
```bash
-i                     # Case-insensitive search
-n                     # Show line numbers
-A <n>                 # Context lines after match
-B <n>                 # Context lines before match
-C <n>                 # Context lines before and after
-l                     # List matching files only
-L                     # List non-matching files
-R                     # Recursive search
```

### Language Support

**Semantic chunking** using Tree-sitter parsing:
- Extracts complete functions, classes, traits, methods, structs
- Preserves code context for better embedding quality

**Supported languages:**
- Python, JavaScript/TypeScript, Rust, Go, Ruby, Haskell, C#, Zig
- Text formats: Markdown, JSON, YAML, SQL, etc.

### Performance Characteristics

**Speed:**
- Sub-second searches on large projects (after initial indexing)
- 80-90% cache hit rate for typical code changes
- First-time indexing varies by codebase size and chosen model

**Accuracy:**
- Semantic search understands code meaning vs just keywords
- Hybrid mode balances precision (keyword) with recall (semantic)

---

## 5. Integration & Automation

### Programmatic Output Formats

**Standard text (grep-compatible):**
```bash
ck "pattern" .
```

**JSON (single array):**
```bash
ck --json "pattern" .
```

**JSON Lines (recommended for AI agents):**
```bash
ck --jsonl "pattern" .
```

**Metadata only:**
```bash
ck --no-snippet "pattern" .
```

### MCP Server Integration

**Starting the server:**
```bash
ck --serve
```

**Installation via Claude Code CLI:**
```bash
claude mcp add ck-search -s user -- ck --serve
claude mcp list  # Verify installation
```

**MCP tools exposed:**
- `semantic_search` - Find code by meaning
- `regex_search` - Pattern matching
- `hybrid_search` - Combined search
- `index_status` - Check indexing metadata
- `reindex` - Force rebuild
- `health_check` - Server diagnostics

**Compatible with:**
- Claude Desktop
- Cursor
- Any MCP-compatible AI client

### Systemd Timer Automation

**Suitability for periodic reindexing:**
While not explicitly documented, `ck` is well-suited for automation:

**Advantages:**
- Transparent index refresh on search
- Safe interruption - partial indexes save and resume from checkpoint
- Delta indexing minimizes reprocessing

**Example systemd service** (untested, conceptual):
```ini
[Unit]
Description=Reindex ck semantic search
After=network.target

[Service]
Type=oneshot
User=your-user
WorkingDirectory=/path/to/repo
ExecStart=/usr/bin/ck --clean .

[Install]
WantedBy=multi-user.target
```

**Example timer:**
```ini
[Unit]
Description=Daily ck reindex timer

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

**Better approach:**
Since `ck` auto-updates indexes on search, you might just run periodic searches instead of explicit reindexing:
```bash
ck --sem "placeholder_query" /path/to/repo >/dev/null
```

### Interactive TUI

**Launch:**
```bash
ck --tui                           # Current directory
ck --tui "error handling"          # Start with query
```

**Features:**
- Real-time search results
- Multiple search modes (toggle with Tab)
- Preview modes via Ctrl+V:
  - Heatmap - visual score representation
  - Syntax - syntax-highlighted code
  - Chunk - chunk boundaries
- Multi-select with Ctrl+Space
- Editor integration - opens files with line numbers

**Keyboard shortcuts:**
- The repository references `TUI.md` for complete documentation
- Standard TUI navigation: ↑/↓ for navigation
- Tab: toggle search modes
- Ctrl+V: cycle preview modes
- Ctrl+Space: multi-select
- Common: `?` or `h` likely shows help (standard TUI convention)

---

## 6. GPU Support

**Current status:**
- **Not explicitly documented** in available sources
- The tool uses ONNX Runtime for model inference
- ONNX Runtime supports CUDA and TensorRT execution providers

**Potential for GPU acceleration:**
Given that `ck` uses ONNX models and ONNX Runtime has robust GPU support, GPU acceleration may be possible but would require:
1. Building with ONNX Runtime GPU features enabled
2. Proper CUDA/cuDNN installation
3. Compatible NVIDIA GPU

**Performance without GPU:**
The tool is already optimized for CPU inference with fast embeddings models, achieving sub-second searches on large codebases.

**Recommendation:**
Check the [GitHub repository issues](https://github.com/BeaconBay/ck/issues) or discussions for GPU support status, or file a feature request if needed.

---

## 7. Best Practices & Recommendations

### For NixOS/Home Manager Integration

**Installation:**
```nix
# In your configuration
environment.systemPackages = with pkgs; [
  # Install from crates.io via cargo
  (pkgs.rustPlatform.buildRustPackage {
    pname = "ck-search";
    # ... derivation details
  })
];
```

**Currently:**
- No official Nix package found in nixpkgs (as of search date)
- Can install via `cargo install ck-search`
- May need custom derivation for declarative setup

### Typical Workflow

1. **Initial setup:**
   ```bash
   cd /path/to/project
   ck --sem "initial query" .  # Creates .ck/ and .ckignore
   ```

2. **Customize ignore patterns:**
   ```bash
   # Edit .ckignore to taste
   vim .ckignore
   ```

3. **Regular searches:**
   ```bash
   ck --hybrid "error handling" src/
   ck --sem --scores --full-section "authentication" .
   ```

4. **Model experimentation:**
   ```bash
   ck --inspect --model jina-code src/auth.rs
   ck --switch-model jina-code  # If jina performs better
   ```

5. **Maintenance:**
   ```bash
   ck --status        # Check index health
   ck --clean .       # Rebuild if needed (rarely necessary)
   ```

### Privacy & Security

**Local-first design:**
- Everything runs locally
- No code or queries sent to external services
- Embedding model downloaded once and cached
- Complete offline operation after initial model download

---

## Key Findings for Your Use Case

Based on your requirements:

### ✅ Supported Features

1. **Centralized Index Location:**
   - ❌ No native support for custom index location
   - Indexes always created in `.ck/` at project root
   - **Workaround:** Use symlinks from project `.ck/` to `~/.MyHome/.ck-indexes/project-name/`

2. **Ignore Patterns:**
   - ✅ Supports `.ckignore` (gitignore syntax)
   - ✅ Respects existing `.gitignore` files
   - ✅ Can use `--exclude` flags for additional exclusions
   - ✅ Smart binary detection

3. **Multi-directory Indexing:**
   - ⚠️ Not explicitly supported
   - Operates on single directory tree per invocation
   - **Workaround:** Run separate indexes per directory, or index parent containing all targets

4. **Automation:**
   - ✅ Well-suited for systemd timers
   - ✅ Delta indexing minimizes reprocessing
   - ✅ Auto-updates indexes on search
   - **Recommendation:** Periodic searches preferred over explicit reindexing

5. **Hybrid Search:**
   - ✅ Fully supported with `--hybrid` flag
   - ✅ Combines semantic + lexical via RRF
   - Default can be set via shell alias or wrapper script

6. **Selective Hidden Directories:**
   - ✅ Use `.ckignore` to exclude unwanted hidden dirs
   - ✅ Include desired ones by not excluding them

---

## Summary Table

| Category | Details |
|----------|---------|
| **Index Location** | `.ck/` at project root; models in `~/.cache/ck/models/` |
| **Config File** | None - all configuration via CLI flags |
| **Ignore Patterns** | `.gitignore` + `.ckignore` + custom `--exclude` flags |
| **Auto-Indexing** | Yes - transparent on first semantic/hybrid search |
| **Delta Indexing** | Yes - 80-90% cache hit rate, blake3-based invalidation |
| **Search Modes** | Semantic, Regex, Hybrid (RRF) |
| **Models** | bge-small (default), nomic-v1.5, jina-code |
| **Output Formats** | Text, JSON, JSONL, metadata-only |
| **MCP Server** | `ck --serve` - exposes semantic/regex/hybrid tools |
| **TUI** | `ck --tui` - interactive search with preview modes |
| **GPU Support** | Not documented; uses ONNX Runtime (has GPU capability) |
| **Automation** | Suitable for systemd timers; safe interruption/resume |
| **Privacy** | Fully local - no external API calls |

---

## Sources

- [GitHub - BeaconBay/ck](https://github.com/BeaconBay/ck)
- [ck Official Documentation](https://beaconbay.github.io/ck/)
- [ck-search on crates.io](https://crates.io/crates/ck-search)
- [Introduction to ck](https://beaconbay.github.io/ck/guide/introduction.html)
- [grep Compatibility | ck](https://beaconbay.github.io/ck/features/grep-compatibility.html)
- [ONNX Runtime CUDA Provider](https://onnxruntime.ai/docs/execution-providers/CUDA-ExecutionProvider.html)
- [FastEmbed-rs](https://github.com/Anush008/fastembed-rs)
- [BLAKE3 Hash Function](https://github.com/BLAKE3-team/BLAKE3)
- [Semantic Search on the Cheap](https://medium.com/neuml/semantic-search-on-the-cheap-55940c0fcdab)

---

**Research Agent:** ae0b997
**Research Date:** 2025-12-21
**Time:** 2025-12-21T23:55:00+02:00 (Europe/Athens)
