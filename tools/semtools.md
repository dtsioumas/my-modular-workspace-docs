# SemTools - Semantic Search & Document Parsing CLI

**Tool:** semtools
**Repository:** https://github.com/run-llama/semtools
**Stars:** 1.5k
**License:** MIT
**Language:** Rust (81.2%), Python (14.8%), JavaScript (4%)
**Installation:** `npm i -g @llamaindex/semtools` or `cargo install semtools`
**Author:** LlamaIndex (run-llama)

---

## Overview

SemTools is a collection of high-performance CLI tools for document processing and semantic search, built with Rust for speed and reliability. It's designed for Unix-friendly workflows with proper stdin/stdout handling.

### Key Differentiator

- **Document Parsing** - Parse PDFs, DOCX, PPTX via LlamaParse API
- **Local Semantic Search** - Fast multilingual embeddings
- **AI Agent** - Built-in agent for Q&A over documents (OpenAI)
- **Workspace Management** - Efficient caching for large collections

---

## Key Features

| Feature | Description | API Required |
|---------|-------------|--------------|
| `parse` | Parse documents (PDF, DOCX, etc.) to markdown | LlamaParse |
| `search` | Local semantic keyword search | None |
| `ask` | AI agent with search/read tools | OpenAI |
| `workspace` | Workspace management for caching | None |

---

## Installation

### Via npm (Recommended)

```bash
npm i -g @llamaindex/semtools
```

### Via Cargo

```bash
# Full install
cargo install semtools

# Select features only
cargo install semtools --no-default-features --features=parse
```

**Note:** npm install builds Rust binaries locally if prebuilt not available (requires Rust toolchain).

---

## Usage

### Parse Documents

```bash
# Parse some files (requires LLAMA_CLOUD_API_KEY)
parse my_dir/*.pdf

# Output: Markdown files
```

### Semantic Search (Local)

```bash
# Search text-based files
search "some keywords" *.txt --max-distance 0.3 --n-lines 5

# Pipeline with parsing
parse my_docs/*.pdf | xargs search "API endpoints"
```

### Ask Agent (OpenAI)

```bash
# Ask questions about documents (requires OPENAI_API_KEY)
ask "What are the main findings?" papers/*.txt

# Combine parsing with agent
parse research_papers/*.pdf | xargs ask "Summarize the key methodologies"

# Ask based on stdin
cat README.md | ask "How do I install SemTools?"
```

### Workspace Management

```bash
# Create/select workspace (caches embeddings)
workspace use my-workspace
export SEMTOOLS_WORKSPACE=my-workspace

# Search with caching
search "some keywords" ./some_large_dir/*.txt --n-lines 5 --top-k 10

# Clean up stale files
workspace prune

# Check workspace status
workspace status
```

---

## Configuration

### Config File (`~/.semtools_config.json`)

```json
{
  "parse": {
    "api_key": "your_llama_cloud_api_key_here",
    "num_ongoing_requests": 10,
    "base_url": "https://api.cloud.llamaindex.ai",
    "parse_kwargs": {
      "parse_mode": "parse_page_with_agent",
      "model": "openai-gpt-4-1-mini"
    }
  },
  "ask": {
    "api_key": "your_openai_api_key_here",
    "model": "gpt-4o-mini",
    "max_iterations": 20
  }
}
```

### Environment Variables

```bash
# For parse tool
export LLAMA_CLOUD_API_KEY="your_key"

# For ask tool
export OPENAI_API_KEY="your_key"
```

### Configuration Priority

1. CLI arguments (`--api-key`, `--model`)
2. Config file (`~/.semtools_config.json`)
3. Environment variables
4. Built-in defaults

---

## CLI Reference

### parse

```
parse [OPTIONS] <FILES>...

Arguments:
  <FILES>...  Files to parse

Options:
  -c, --config <CONFIG>    Config file path
  -b, --backend <BACKEND>  Backend type [default: llama-parse]
  -v, --verbose            Verbose output
```

### search

```
search [OPTIONS] <QUERY> [FILES]...

Arguments:
  <QUERY>     Query to search for
  [FILES]...  Files or directories to search

Options:
  -n, --n-lines <N_LINES>            Context lines [default: 3]
      --top-k <TOP_K>                Top-k results [default: 3]
  -m, --max-distance <MAX_DISTANCE>  Distance threshold (0.0+)
  -i, --ignore-case                  Case-insensitive
```

### ask

```
ask [OPTIONS] <QUERY> [FILES]...

Arguments:
  <QUERY>     Query for the agent
  [FILES]...  Files to search (optional with stdin)

Options:
  -c, --config <CONFIG>      Config file path
      --api-key <API_KEY>    OpenAI API key
      --base-url <BASE_URL>  OpenAI base URL
  -m, --model <MODEL>        Model name
```

---

## Embeddings

- **Model:** model2vec from minishlab/potion-multilingual-128M
- **Type:** Static embeddings (fast inference)
- **Multilingual:** Yes
- **Local:** Yes (search/workspace commands)

---

## Comparison: SemTools vs ck

| Feature | SemTools | ck |
|---------|----------|-----|
| Semantic Search | Yes (local) | Yes (local) |
| Document Parsing | Yes (API) | No |
| AI Agent | Yes (OpenAI) | No |
| MCP Server | No | Yes |
| grep Compatible | No | Yes |
| 100% Offline | No (parse/ask need APIs) | Yes |
| Language | Rust | Rust |

**Recommendation:**
- Use **ck** for code search and grep replacement
- Use **semtools** for document parsing and AI Q&A

---

## Integration with My-Modular-Workspace

### Use Cases

1. **Parse Documentation** - Convert PDFs to searchable markdown
2. **Search Docs** - Local semantic search over text files
3. **AI Q&A** - Ask questions about project documentation

### Setup (if needed)

```bash
# Get free LlamaParse API key
# https://cloud.llamaindex.ai/

# Export keys
export LLAMA_CLOUD_API_KEY="llx-..."
export OPENAI_API_KEY="sk-..."

# Parse and search
parse ~/Documents/*.pdf
search "deployment strategy" ~/Documents/*.md
```

### Home-Manager Integration (Optional)

```nix
# Install via npm globally
home.activation.install-semtools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  set -euo pipefail
  if command -v npm >/dev/null 2>&1; then
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    npm install -g @llamaindex/semtools || true
  fi
'';
```

---

## Limitations

1. **parse** requires LlamaParse API key (free tier available)
2. **ask** requires OpenAI API key (costs money)
3. No MCP server integration (unlike ck)
4. Not a grep replacement

---

## References

- **GitHub:** https://github.com/run-llama/semtools
- **npm:** https://www.npmjs.com/package/@llamaindex/semtools
- **LlamaParse:** https://cloud.llamaindex.ai/
- **Embeddings:** https://huggingface.co/minishlab/potion-multilingual-128M

---

## Changelog

| Date | Version | Notes |
|------|---------|-------|
| 2025-11-26 | v1.5.0 | Latest release |
| 2025-12-01 | - | Documented for my-modular-workspace |

---

**Maintained by:** mitsio
**Documentation Path:** `docs/tools/semtools.md`
