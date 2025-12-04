# Semtools - Semantic Search and Document Parsing CLI

**Version researched:** 1.5.0 (upstream) / 1.2.0 (nixpkgs)
**Repository:** https://github.com/run-llama/semtools
**License:** MIT

## Overview

Semtools is a high-performance CLI tool collection for document processing and semantic search, built with Rust. It provides four main commands:

- **`parse`** - Parse documents (PDF, DOCX, PPTX, etc.) using LlamaParse API into markdown
- **`search`** - Local semantic keyword search using multilingual embeddings
- **`ask`** - AI agent with search and read tools for answering questions
- **`workspace`** - Workspace management for accelerating search over large collections

## Key Features

- **Fast semantic search** using model2vec embeddings from `minishlab/potion-multilingual-128M`
- **Reliable document parsing** with caching and error handling
- **Unix-friendly** design with proper stdin/stdout handling
- **Configurable** distance thresholds and chunk sizes
- **Multi-format support** (PDF, DOCX, PPTX, etc.)
- **Concurrent processing** for better parsing performance
- **Workspace management** for efficient document retrieval over large collections
- **Local-only search** - no API calls for `search` and `workspace` commands

## Installation

### Via Nixpkgs (Recommended for NixOS)

Semtools is available in nixpkgs (v1.2.0):

```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    semtools
  ];
}
```

**Note:** Nixpkgs version (1.2.0) lags behind upstream (1.5.0). Consider building from source if newer features are needed.

### Via NPM

```bash
npm i -g @llamaindex/semtools
```

### Via Cargo

```bash
# Install entire crate
cargo install semtools

# Install only select features
cargo install semtools --no-default-features --features=parse
```

## Configuration

### Unified Configuration File

Create `~/.semtools_config.json` with settings for the tools you use. All sections are optional:

```json
{
  "parse": {
    "api_key": "your_llama_cloud_api_key_here",
    "num_ongoing_requests": 10,
    "base_url": "https://api.cloud.llamaindex.ai",
    "parse_kwargs": {
      "parse_mode": "parse_page_with_agent",
      "model": "openai-gpt-4-1-mini",
      "high_res_ocr": "true",
      "adaptive_long_table": "true",
      "outlined_table_extraction": "true",
      "output_tables_as_HTML": "true"
    },
    "check_interval": 5,
    "max_timeout": 3600,
    "max_retries": 10,
    "retry_delay_ms": 1000,
    "backoff_multiplier": 2.0
  },
  "ask": {
    "api_key": "your_openai_api_key_here",
    "base_url": null,
    "model": "gpt-4o-mini",
    "max_iterations": 20,
    "api_mode": "responses"
  }
}
```

### Environment Variables

As an alternative or supplement to the config file:

```bash
# For parse tool
export LLAMA_CLOUD_API_KEY="your_llama_cloud_api_key_here"

# For ask tool
export OPENAI_API_KEY="your_openai_api_key_here"
```

### Configuration Priority

1. **CLI arguments** (e.g., `--api-key`, `--model`, `--base-url`)
2. **Config file** (`~/.semtools_config.json` or custom path via `-c`)
3. **Environment variables** (`LLAMA_CLOUD_API_KEY`, `OPENAI_API_KEY`)
4. **Built-in defaults**

## Usage

### Basic Commands

```bash
# Parse PDF files (requires LLAMA_CLOUD_API_KEY)
parse my_dir/*.pdf

# Search text files (fully local, no API needed)
search "some keywords" *.txt --max-distance 0.3 --n-lines 5

# Ask questions using AI agent (requires OPENAI_API_KEY)
ask "What are the main findings?" papers/*.txt

# Combine parsing and search
parse my_docs/*.pdf | xargs search "API endpoints"

# Ask based on stdin content
cat README.md | ask "How do I install SemTools?"
```

### Workspace Management

Workspaces cache embeddings for faster repeated searches:

```bash
# Create or select a workspace
workspace use my-workspace
# Output: Workspace 'my-workspace' configured.
#         To activate it, run:
#           export SEMTOOLS_WORKSPACE=my-workspace

# Activate the workspace
export SEMTOOLS_WORKSPACE=my-workspace

# Initial search builds the cache
search "some keywords" ./large_dir/*.txt --n-lines 5 --top-k 10

# Subsequent searches use cached embeddings (much faster)
search "other keywords" ./large_dir/*.txt --n-lines 5 --top-k 10

# Clean up stale files
workspace prune

# Check workspace stats
workspace status
# Output: Active workspace: my-workspace
#         Root: ~/.semtools/workspaces/my-workspace
#         Documents: 3000
#         Index: Yes (IVF_PQ)
```

**Workspace behavior:**
- Stored in `~/.semtools/workspaces/`
- Auto-updates when documents change
- No manual re-indexing needed
- Prune to clean up deleted/moved files

### Advanced Usage

```bash
# Combine with grep for pre-filtering
parse *.pdf | xargs cat | grep -i "error" | search "network error" --max-distance 0.3

# Pipeline with content search
find . -name "*.md" | xargs parse | xargs search "installation"

# Save search results
parse report.pdf | xargs cat | search "summary" > results.txt
```

### Search Command Options

```bash
search <QUERY> [FILES]... [OPTIONS]

Options:
  -n, --n-lines <N_LINES>            Lines before/after for context [default: 3]
      --top-k <TOP_K>                Top-k files/texts to return [default: 3]
  -m, --max-distance <MAX_DISTANCE>  Return all results below threshold (0.0+)
  -i, --ignore-case                  Case-insensitive search
```

**Distance interpretation:**
- `0.0` = perfect match
- `< 0.3` = very similar
- `0.3 - 0.5` = somewhat similar
- `> 0.5` = less relevant

### Parse Command Options

```bash
parse [OPTIONS] <FILES>...

Options:
  -c, --config <CONFIG>    Path to config file [default: ~/.semtools_config.json]
  -b, --backend <BACKEND>  Backend type [default: llama-parse]
  -v, --verbose            Verbose output
```

**Parse caching:**
- Results cached in `~/.parse/`
- Reuses cached files automatically
- Speeds up repeated operations

### Ask Command Options

```bash
ask [OPTIONS] <QUERY> [FILES]...

Options:
  -c, --config <CONFIG>      Path to config file
      --api-key <API_KEY>    OpenAI API key (overrides config)
      --base-url <BASE_URL>  OpenAI base URL (overrides config)
  -m, --model <MODEL>        Model to use (overrides config)
```

## Integration with MySpaces Directory

### Recommended Workflow

1. **Create a dedicated workspace:**
   ```bash
   workspace use myspaces
   export SEMTOOLS_WORKSPACE=myspaces
   ```

2. **Add to shell config** (e.g., `~/.bashrc`):
   ```bash
   export SEMTOOLS_WORKSPACE=myspaces
   ```

3. **Initial indexing** (builds cache):
   ```bash
   search "test" ~/.MyHome/MySpaces/**/*.md --top-k 1
   ```

4. **Regular usage:**
   ```bash
   # Semantic search across all MySpaces
   search "kubernetes deployment" ~/.MyHome/MySpaces/**/*.md --n-lines 5 --max-distance 0.35

   # Search specific subdirectory
   search "ansible playbook" ~/.MyHome/MySpaces/my-modular-workspace/ansible/**/*.md

   # Ask questions about your docs
   ask "How is rclone configured in this project?" ~/.MyHome/MySpaces/my-modular-workspace/docs/**/*.md
   ```

### Indexing Behavior

- **Automatic:** No manual indexing commands needed
- **Dynamic:** Updates embeddings when files change
- **Incremental:** Only re-embeds changed files
- **Persistent:** Cached in workspace directory
- **Pruning:** Use `workspace prune` to clean up deleted files

## Integration with Claude Code

### Via CLAUDE.md

Add semtools documentation to your `CLAUDE.md` or `.claude/CLAUDE.md`:

```markdown
# Available Tools

## Semtools - Semantic Search

You have access to `semtools` CLI for semantic document search:

- `search "query" files/*.md` - Semantic search
- `parse docs/*.pdf` - Parse PDFs to markdown
- `ask "question?" docs/*.txt` - AI agent Q&A
- Workspace: `export SEMTOOLS_WORKSPACE=myspaces` for faster searches

Examples:
- Find related docs: `search "kubernetes config" ~/.MyHome/MySpaces/**/*.md --n-lines 5`
- Parse and search: `parse papers/*.pdf | xargs search "methodology"`
```

### Via MCP Server

While tempting to wrap semtools in MCP, the recommended approach is giving Claude direct terminal access:

**Pros of terminal access:**
- Full command flexibility
- Pipe composition (parse | search)
- Workspace management
- Follows Unix philosophy

**MCP wrapper considerations:**
- Security implications (unrestricted bash access)
- Recommend Docker container + volume mounts
- See: https://github.com/run-llama/semtools/blob/main/examples/use_with_mcp.md

## Dependencies

### Build Dependencies (for cargo install)
- Rust toolchain (rustup)
- pkg-config
- openssl development libraries

### Runtime Dependencies
- openssl (linked)

### API Dependencies (optional)
- **LlamaParse API** - For `parse` command (get free key at https://cloud.llamaindex.ai)
- **OpenAI API** - For `ask` command

## Performance Notes

- **Search speed:** Very fast with model2vec embeddings
- **Parse speed:** Depends on LlamaParse API (concurrent by default)
- **Workspace caching:** Significant speedup on large collections
- **Memory usage:** Efficient, suitable for large document sets

## Common Issues & Solutions

### Parse Fails with API Error
```bash
# Check API key is set
echo $LLAMA_CLOUD_API_KEY

# Or set in config
cat ~/.semtools_config.json
```

### Search Returns No Results
```bash
# Try increasing max-distance
search "query" files/*.txt --max-distance 0.5

# Check files exist and are readable
ls -lh files/*.txt
```

### Workspace Not Found
```bash
# Check workspace exists
workspace status

# Create if needed
workspace use myworkspace
export SEMTOOLS_WORKSPACE=myworkspace
```

### Version Mismatch (Nixpkgs vs Upstream)
```bash
# Check installed version
semtools --version

# If you need v1.5.0 features:
# Option 1: Install via cargo
cargo install semtools

# Option 2: Wait for nixpkgs update
# Option 3: Build from source with Nix
```

## References

- **GitHub:** https://github.com/run-llama/semtools
- **Nixpkgs:** https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/se/semtools/package.nix
- **Examples:**
  - Using with Claude Code: https://github.com/run-llama/semtools/blob/main/examples/use_with_coding_agents.md
  - Using with MCP: https://github.com/run-llama/semtools/blob/main/examples/use_with_mcp.md
- **Model:** https://huggingface.co/minishlab/potion-multilingual-128M

## Related Tools

- **semantic-grep** - Alternative semantic search tool
- **ck** - Context-aware semantic search
- **ripgrep** - Fast text search (not semantic)
- **ag** - Fast text search (not semantic)
