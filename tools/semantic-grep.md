# Semantic-Grep (w2vgrep) - Word-level Semantic Search

**Version:** 0.7.0
**Binary name:** w2vgrep
**Repository:** https://github.com/arunsupe/semantic-grep
**License:** MIT
**Status:** ✅ **ALREADY INSTALLED** via home-manager

## Overview

Semantic-grep (binary: `w2vgrep`) is a grep-like tool that performs semantic searches using word embeddings. Unlike regular grep which matches exact strings, w2vgrep finds words with similar meanings.

**Key Concept:** Word-level semantic matching with context display, designed to feel like traditional grep.

## Current Installation Status

**Already installed!** See `/home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager/semantic-grep.nix`

- Built from source using Go
- Model: GoogleNews-vectors-negative300-SLIM.bin (~350MB)
- Config: ~/.config/semantic-grep/config.json
- Binary: w2vgrep (in PATH)

## Usage

### Basic Syntax

```bash
w2vgrep [options] <query> [file]
```

If no file specified, reads from stdin (like grep).

### Common Examples

```bash
# Search for words similar to "death" with context
w2vgrep -C 2 -n --threshold=0.55 death file.txt

# From stdin (pipe-friendly)
cat README.md | w2vgrep -t 0.6 error

# Multiple files
w2vgrep -n important *.txt

# Search MySpaces docs
w2vgrep -C 3 -t 0.6 kubernetes ~/.MyHome/MySpaces/**/*.md
```

### Command-Line Options

```bash
# Model and Threshold
-m, --model_path=      Path to Word2Vec model (overrides config)
-t, --threshold=       Similarity threshold (default: 0.7)
                       Lower = more matches, higher = stricter

# Context Display (like grep)
-A, --before-context=  Lines before match
-B, --after-context=   Lines after match
-C, --context=         Lines before AND after match
-n, --line-number      Show line numbers

# Output Modes
-o, --only-matching    Show only matching words
-l, --only-lines       Show only matched lines (no scores)

# Other
-i, --ignore-case      Case-insensitive search
-f, --file=            Read patterns from file (one per line)
```

### Threshold Guide

The threshold determines how similar words must be:

- `0.5-0.6` - Very loose (many matches, including loosely related)
- `0.6-0.7` - Moderate (good balance, **recommended starting point**)
- `0.7-0.8` - Strict (only closely related words)
- `0.8-0.9` - Very strict (near-synonyms only)
- `0.9-1.0` - Extremely strict (almost exact matches)

**Recommendation:** Start with `0.6` and adjust based on results.

## Configuration

### Current Config

Located at: `~/.config/semantic-grep/config.json`

```json
{
  "model_path": "/home/mitsio/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin",
  "threshold": 0.7
}
```

### Config Search Order

w2vgrep looks for config.json in:
1. Current directory (`./config.json`)
2. User config (`~/.config/semantic-grep/config.json`) ← **Our setup**
3. System config (`/etc/semantic-grep/config.json`)

Command-line options override config file.

## Word Embedding Model

### Current Model

**GoogleNews-vectors-negative300-SLIM.bin**
- Size: ~350MB
- Source: Google's Word2Vec pre-trained on Google News
- Dimensions: 300
- Language: English
- Downloaded automatically by home-manager activation script

### Model Location

```bash
~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin
```

### Testing the Model

Use the synonym-finder utility (if built):

```bash
# Find similar words
synonym-finder -model_path ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin \
               -threshold 0.6 kubernetes
```

### Additional Language Models

For non-English text, download fasttext models:

```bash
# French
curl -s 'https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.fr.300.vec.gz' \
  | gunzip -c | fasttext-to-bin -input - -output ~/.config/semantic-grep/models/cc.fr.300.bin

# Use it
w2vgrep -m ~/.config/semantic-grep/models/cc.fr.300.bin -t 0.6 château french-doc.txt
```

**Available:** 157 languages at https://fasttext.cc/docs/en/crawl-vectors.html

## Comparison with Other Tools

### vs. Semtools

| Feature | semantic-grep (w2vgrep) | semtools |
|---------|------------------------|----------|
| **Matching level** | Word-level | Line-level |
| **Interface** | Grep-like | Multiple commands |
| **Model** | Word2Vec (separate file) | model2vec (embedded) |
| **Model size** | ~350MB download | No download |
| **Workspace** | No | Yes (caching) |
| **Installation** | Build from source | nixpkgs |
| **Best for** | Finding similar words in text | Finding relevant documents |

### vs. Traditional grep

| Feature | w2vgrep | grep/ripgrep |
|---------|---------|--------------|
| **Matching** | Semantic (meaning) | Exact/regex (text) |
| **Speed** | Slower (embedding lookup) | Faster |
| **Flexibility** | Finds synonyms/related terms | Only what you specify |
| **Use case** | Exploratory search | Known patterns |

**Recommendation:** Use both!
- `rg` for exact patterns
- `w2vgrep` for concept-based search

## Integration with MySpaces

### Recommended Usage Patterns

```bash
# Find docs about "deployment" (also matches: release, rollout, ship, etc.)
w2vgrep -C 2 -n -t 0.6 deployment ~/.MyHome/MySpaces/my-modular-workspace/docs/**/*.md

# Search for error-related content
w2vgrep -t 0.65 failure ~/.MyHome/MySpaces/my-modular-workspace/sessions/**/*.md

# Find configuration-related docs
w2vgrep -C 3 -t 0.6 configuration ~/.MyHome/MySpaces/**/*.nix

# Combine with other tools
fd -e md | xargs w2vgrep -t 0.6 kubernetes | bat
```

### Integration with Claude Code

Add to `.claude/CLAUDE.md`:

```markdown
## Semantic Search Tools

You have access to `w2vgrep` for semantic (meaning-based) search:

- Word-level semantic matching using word embeddings
- Grep-like interface: `w2vgrep -C 2 -t 0.6 <query> files`
- Threshold 0.5-0.7 recommended for broad search
- Model: GoogleNews word2vec (~350MB, already downloaded)

Examples:
- `w2vgrep -t 0.6 error logs/*.txt` - Find error-related content
- `w2vgrep -C 3 deployment docs/**/*.md` - Find deployment discussions
- `cat file.md | w2vgrep -t 0.65 problem` - Search piped input
```

## Model Management

### Reducing Model Size

Large models can be reduced for faster loading:

```bash
# Build reduce-pca tool
cd model_processing_utils/reduce-model-size
go build .

# Reduce from 300 to 100 dimensions (~346MB → ~117MB)
./reduce-pca \
  -input ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin \
  -output ~/.config/semantic-grep/models/GoogleNews-vectors-negative100-SLIM.bin

# Update config.json to use smaller model
```

**Trade-off:** Smaller = faster + less memory, but potentially less accurate.

### Model Formats

w2vgrep requires **binary** format (.bin extension).

Supported conversions:
- Text format (.vec) → Binary (.bin): Use `fasttext-to-bin` utility
- Gensim models → Binary: Use model processing utils

## Performance Considerations

### Speed

- **Model loading:** ~1-2 seconds (one-time per invocation)
- **Search:** Depends on file size and threshold
- **Large files:** Consider using with `head` or `tail` first

### Memory

- Model loaded into RAM: ~350MB (full model)
- Lighter models available: ~100-150MB with minimal accuracy loss

### Optimization Tips

1. **Use stricter thresholds** (0.7+) to reduce matches
2. **Reduce model dimensions** if speed is critical
3. **Combine with `rg` for pre-filtering:**
   ```bash
   rg -i "error|fail" logs/ | w2vgrep -t 0.6 critical
   ```

## Common Issues

### Model Not Found

```bash
$ w2vgrep test file.txt
Error: Could not load model...

# Solution: Check config.json path
cat ~/.config/semantic-grep/config.json
# Verify model file exists
ls -lh ~/.config/semantic-grep/models/
```

### No Matches Found

```bash
# Try lowering threshold
w2vgrep -t 0.5 <query> file.txt

# Test with synonym-finder
synonym-finder -model_path ~/.config/semantic-grep/models/*.bin -threshold 0.5 <query>
```

### Slow Performance

```bash
# Use smaller model
w2vgrep -m ~/.config/semantic-grep/models/GoogleNews-vectors-negative100-SLIM.bin ...

# Or pre-filter with rg
rg "context" | w2vgrep -t 0.6 <query>
```

## Advanced Usage

### Pattern Files

Search for multiple patterns:

```bash
# patterns.txt
error
failure
problem
issue

# Use it
w2vgrep -f patterns.txt -t 0.65 logs/*.txt
```

### Pipeline Integration

```bash
# Find semantically similar content in recent files
fd -e md --changed-within 7d | \
  xargs w2vgrep -t 0.6 deployment | \
  grep -v "^--" | \
  bat --style=numbers

# Semantic search → exact filter → display
w2vgrep -t 0.6 error logs/*.txt | rg "critical" | less
```

### Multi-language Search

```bash
# Search Chinese docs
w2vgrep -m ~/.config/semantic-grep/models/cc.zh.300.bin -t 0.6 合理性 chinese-docs/*.txt

# Search French docs
w2vgrep -m ~/.config/semantic-grep/models/cc.fr.300.bin -t 0.6 château french-docs/*.txt
```

## Maintenance

### Model Updates

To update or replace model:

```bash
# Download new model
curl -L -o /tmp/newmodel.bin.gz https://example.com/model.bin.gz
gunzip /tmp/newmodel.bin.gz

# Move to models directory
mv /tmp/newmodel.bin ~/.config/semantic-grep/models/

# Update config.json
# Edit model_path to point to new model
```

### Config Changes

Edit config file:
```bash
$EDITOR ~/.config/semantic-grep/config.json
```

Or use command-line overrides (no config edit needed):
```bash
w2vgrep -m /path/to/other/model.bin -t 0.5 <query> file.txt
```

## References

- **GitHub:** https://github.com/arunsupe/semantic-grep
- **Current installation:** home-manager/semantic-grep.nix:12-58
- **Config:** ~/.config/semantic-grep/config.json
- **Models:**
  - GoogleNews: https://github.com/mmihaltz/word2vec-GoogleNews-vectors
  - Fasttext (157 langs): https://fasttext.cc/docs/en/crawl-vectors.html
  - GloVe: https://nlp.stanford.edu/projects/glove/

## Related Tools

- **semtools** - Line-level semantic search with workspace caching
- **ck** - Context-aware semantic search (to be evaluated)
- **ripgrep (rg)** - Fast exact/regex text search
- **ag** - The Silver Searcher (exact text search)
