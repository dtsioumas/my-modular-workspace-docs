# Semantic Grep (w2vgrep) - Documentation

**Tool:** w2vgrep
**Repository:** https://github.com/arunsupe/semantic-grep
**Stars:** 1.2k ⭐
**License:** MIT
**Language:** Go
**Author:** Arun Supe (@arunsupe)
**Installation:** Managed via `home-manager/semantic-grep.nix`

---

## Overview

w2vgrep is a command-line tool that performs **semantic searches** on text using word embeddings (Word2Vec). Unlike traditional grep which finds exact string matches, w2vgrep finds words with **similar meanings**.

### Example

Search for words semantically similar to "death" in a text file:

```bash
cat hemingway.txt | w2vgrep -C 2 -n --threshold=0.55 death
```

**Finds:** death, die, dying, killed, departed, deceased, etc. (based on semantic similarity)

---

## Key Features

✅ **Semantic Search** - Finds words by meaning, not exact match
✅ **Configurable Threshold** - Control similarity sensitivity (0.0-1.0)
✅ **Context Display** - Show lines before/after matches (like grep -C)
✅ **Color-Coded Output** - Highlights matches with similarity scores
✅ **Multi-Language Support** - 157 languages via FastText models
✅ **Pipe-Friendly** - Works with stdin/stdout like grep
✅ **Grep-Compatible** - Similar flags and usage patterns

---

## Installation (Our Setup)

### Via Home-Manager (Declarative)

Already configured in `home-manager/semantic-grep.nix`:

1. **Binary Installation:** Built from source using Go
2. **Model Download:** GoogleNews-vectors-negative300-SLIM.bin (~350MB)
3. **Config Creation:** `$HOME/.config/semantic-grep/config.json`

### Manual Verification

```bash
# Check if installed
which w2vgrep

# Check model exists
ls -lh ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin

# Test with a simple query
echo "The cat is sleeping peacefully" | w2vgrep -n cat
```

---

## Usage

### Basic Syntax

```bash
w2vgrep [OPTIONS] <query> [FILE]
```

If no file is specified, reads from **stdin** (like grep).

### Command-Line Options

| Option | Long Form | Description | Default |
|--------|-----------|-------------|---------|
| `-m` | `--model_path=` | Path to Word2Vec model file | From config.json |
| `-t` | `--threshold=` | Similarity threshold (0.0-1.0) | 0.7 |
| `-C` | `--context=` | Lines before and after match | 0 |
| `-A` | `--before-context=` | Lines before match | 0 |
| `-B` | `--after-context=` | Lines after match | 0 |
| `-n` | `--line-number` | Print line numbers | false |
| `-i` | `--ignore-case` | Case-insensitive search | false |
| `-o` | `--only-matching` | Show only matching words | false |
| `-l` | `--only-lines` | Show lines without scores | false |
| `-f` | `--file=` | Patterns from file (like grep -f) | - |

---

## Configuration

### Config File Locations (Checked in Order)

1. `./config.json` (current directory)
2. `$HOME/.config/semantic-grep/config.json` ← **Default**
3. `/etc/semantic-grep/config.json`

### Example Config

```json
{
  "model_path": "/home/mitsio/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin",
  "threshold": 0.7
}
```

**Our config location:** `~/.config/semantic-grep/config.json` (auto-created by home-manager)

---

## Word Embedding Models

### Default Model (Installed)

- **Name:** GoogleNews-vectors-negative300-SLIM
- **Size:** ~350MB
- **Dimensions:** 300
- **Language:** English
- **Vocabulary:** ~3M words
- **Source:** Google Word2Vec (slim version)
- **License:** Apache 2.0

### Model Performance

| Threshold | Behavior |
|-----------|----------|
| 0.9-1.0 | Very strict - Only near-synonyms |
| 0.7-0.9 | Moderate - Related words |
| 0.5-0.7 | Loose - Semantically connected |
| 0.0-0.5 | Very loose - Distant relations |

### Multi-Language Models

FastText provides models for **157 languages**:

**Download a French model:**
```bash
curl -s 'https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.fr.300.vec.gz' \
  | gunzip -c \
  | fasttext-to-bin -input - -output ~/.config/semantic-grep/models/cc.fr.300.bin
```

**Use it:**
```bash
w2vgrep -m ~/.config/semantic-grep/models/cc.fr.300.bin château < french-text.txt
```

**Available languages:** ar, zh, fr, de, es, ru, ja, pt, it, and 148 more
**Source:** https://fasttext.cc/docs/en/crawl-vectors.html

---

## Examples

### Example 1: Find Synonyms in a File

```bash
# Find words similar to "happy" with context
w2vgrep -C 2 -n --threshold=0.6 happy story.txt
```

**Matches:** happy, joyful, pleased, delighted, cheerful, glad

### Example 2: Pipe from URL

```bash
# Search Project Gutenberg text
curl -s 'https://www.gutenberg.org/files/1342/1342-0.txt' \
  | w2vgrep -n --threshold=0.65 love \
  | head -20
```

### Example 3: Multiple Patterns from File

```bash
# Create pattern file
cat > patterns.txt <<EOF
death
love
fear
hope
EOF

# Search for all patterns
w2vgrep -f patterns.txt -n --threshold=0.6 novel.txt
```

### Example 4: Only Show Matching Words

```bash
# Extract semantically similar words only
echo "The quick brown fox jumps over the lazy dog" \
  | w2vgrep -o --threshold=0.7 fast
```

**Output:** quick (0.72)

### Example 5: Code Search

```bash
# Find semantic matches in code comments
find . -name "*.py" -exec w2vgrep -n --threshold=0.6 "bug" {} \;
```

**Matches:** bug, issue, error, defect, fault, problem

---

## Use Cases

### 1. Code Search

**Traditional grep:**
```bash
grep "error" *.log  # Finds only "error"
```

**Semantic grep:**
```bash
w2vgrep --threshold=0.6 "error" *.log  # Finds: error, fault, exception, failure, crash
```

### 2. Documentation Search

```bash
# Find related concepts in docs
w2vgrep -C 3 --threshold=0.65 "authentication" docs/
```

**Matches:** authentication, login, credentials, password, auth, security

### 3. Log Analysis

```bash
# Find all performance-related log entries
tail -f app.log | w2vgrep --threshold=0.6 "slow"
```

**Matches:** slow, latency, timeout, delay, lag, performance

### 4. Content Analysis

```bash
# Find sentiment-related words
w2vgrep -o --threshold=0.7 "excellent" reviews.txt
```

**Matches:** excellent, outstanding, superb, great, amazing

### 5. Research & Writing

```bash
# Find alternative word choices
echo "The implementation is good" | w2vgrep -o --threshold=0.65 "good"
```

**Matches:** good, great, excellent, fine, solid, effective

---

## Performance Optimization

### Reduce Model Size (100-150 dimensions)

```bash
# Build reduce-pca tool
cd ~/.config/semantic-grep/model_processing_utils/reduce-model-size
go build .

# Reduce 300D → 100D (346MB → 117MB)
./reduce-pca \
  -input ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin \
  -output ~/.config/semantic-grep/models/GoogleNews-vectors-negative100-SLIM.bin

# Update config.json to use smaller model
```

**Benefits:**
- ✅ Faster loading (3x speedup)
- ✅ Less memory (3x reduction)
- ✅ Similar accuracy
- ✅ Smaller disk usage

---

## Testing & Troubleshooting

### Test Model with Synonym Finder

```bash
# Build synonym finder
cd ~/.config/semantic-grep/model_processing_utils
go build synonym-finder.go

# Find similar words
./synonym-finder \
  -model_path ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin \
  -threshold 0.6 \
  happiness
```

**Output:**
```
Words similar to 'happiness' with similarity >= 0.60:
joy        0.7245
gladness   0.6812
happiness  1.0000
delight    0.6523
pleasure   0.6891
bliss      0.6712
```

### Common Issues

**Issue 1: Command not found**
```bash
# Check PATH
which w2vgrep

# If not found, rebuild home-manager
home-manager switch --flake .#mitsio@shoshin
```

**Issue 2: Model not found**
```bash
# Check model exists
ls -lh ~/.config/semantic-grep/models/

# Re-download if missing
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
# Trigger activation script
home-manager switch --flake .#mitsio@shoshin
```

**Issue 3: No matches found**
```bash
# Lower threshold
w2vgrep --threshold=0.5 <query> <file>

# Check if word is in model vocabulary
./synonym-finder -model_path <model> -threshold 0.0 <word>
```

---

## Comparison with Alternatives

| Tool | Type | Speed | Accuracy | Language Support |
|------|------|-------|----------|------------------|
| **w2vgrep** | Semantic | Medium | High | 157 (with models) |
| grep | Exact | Very Fast | Exact | N/A |
| ripgrep | Exact | Very Fast | Exact | N/A |
| ag | Exact | Fast | Exact | N/A |
| ast-grep | AST | Fast | High | 20+ |
| semgrep | Pattern | Medium | High | 30+ |

**When to use w2vgrep:**
- ✅ Searching for concepts, not exact strings
- ✅ Finding related terms in documentation
- ✅ Content analysis and sentiment detection
- ✅ Research and synonym discovery
- ✅ Log analysis for semantic patterns

**When NOT to use w2vgrep:**
- ❌ Exact string matching (use grep/ripgrep)
- ❌ Code syntax matching (use ast-grep)
- ❌ Pattern matching (use semgrep)
- ❌ Very large codebases (slower than ripgrep)

---

## Integration with Our Workspace

### Current Setup

- **Installation:** `home-manager/semantic-grep.nix`
- **Binary:** Built from source via Nix
- **Model:** Auto-downloaded on first home-manager switch
- **Config:** Auto-created at `~/.config/semantic-grep/config.json`

### Usage in Workspace

```bash
# Search ansible playbooks semantically
w2vgrep -n --threshold=0.65 "backup" ~/.MyHome/MySpaces/my-modular-workspace/ansible/playbooks/*.yml

# Search documentation
w2vgrep -C 2 --threshold=0.6 "configuration" ~/.MyHome/MySpaces/my-modular-workspace/*/docs/
```

---

## Advanced Topics

### Custom Model Training

For specialized domains (e.g., medical, legal, technical):

1. Collect domain-specific corpus
2. Train Word2Vec model using gensim
3. Convert to w2vgrep binary format
4. Update config.json model_path

**Documentation:** See `model_processing_utils/` in semantic-grep repo

### API Integration

w2vgrep is a CLI tool, but you can use it in scripts:

```bash
#!/bin/bash
# semantic-search.sh - Wrapper for w2vgrep

THRESHOLD=${2:-0.65}
QUERY="$1"

find . -type f -name "*.md" -exec w2vgrep -l -n --threshold="$THRESHOLD" "$QUERY" {} \;
```

---

## References

- **GitHub:** https://github.com/arunsupe/semantic-grep
- **Word2Vec Paper:** https://arxiv.org/abs/1301.3781
- **FastText Vectors:** https://fasttext.cc/docs/en/crawl-vectors.html
- **GloVe Project:** https://nlp.stanford.edu/projects/glove/
- **Home-Manager Config:** `home-manager/semantic-grep.nix`

---

## Changelog

| Date | Version | Notes |
|------|---------|-------|
| 2024-08-06 | v0.7.0 | Latest release |
| 2025-11-23 | - | Documented for my-modular-workspace |

---

**Maintained by:** mitsio
**Documentation Path:** `ansible/docs/tools/semantic-grep/README.md`
**Cheatsheet:** See `~/.local/share/chezmoi/navi/semantic-grep.cheat`
