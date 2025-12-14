# Semantic Search Tools - Claude Integration Guide

**Purpose:** Instructions for Claude on how to use semantic search tools in my workspace
**Tools:** semtools (search) and semantic-grep
**Last Updated:** 2025-12-06

---

## Overview

Two complementary semantic search tools are installed and ready for use:

1. **semtools** (`search`) - Line-level semantic search with document awareness
2. **semantic-grep** - Word-level grep-like semantic search

**Total model storage:** ~853MB (declaratively managed via home-manager)

---

## When to Use Each Tool

### Use `search` (semtools) when:
- Searching across multiple documents
- Need semantic understanding of entire lines/paragraphs
- Want document parsing capabilities
- Searching in workspace directories (MySpaces)
- Need to find conceptually related content

**Best for:** Documentation, notes, markdown files, large text searches

---

### Use `semantic-grep` when:
- Searching for semantically similar words
- Need grep-like word-level matching
- Analyzing logs or structured text
- Quick searches in specific files
- Want to find word variants (error→failure, success→accomplished)

**Best for:** Logs, code comments, single files, word-level semantic matching

---

## Tool 1: semtools (`search`)

### Installation
- **Binary:** `/home/mitsio/.nix-profile/bin/search`
- **Model:** potion-multilingual-128M (507MB)
- **Location:** `~/.cache/huggingface/hub/models--minishlab--potion-multilingual-128M/`
- **Config:** `~/.semtools_config.json`
- **Workspace:** `SEMTOOLS_WORKSPACE=myspaces`

### Basic Usage

```bash
# Basic search - find semantically related lines
search "kubernetes deployment" ~/.MyHome/MySpaces/**/*.md

# With line context (show 5 lines of context)
search "error handling" docs/ --n-lines 5

# Top K results
search "configuration management" . --top-k 10

# Distance threshold (lower = more strict)
search "docker compose" . --max-distance 0.35
```

### Common Use Cases

#### 1. Documentation Discovery
```bash
# Find documentation about a concept
search "authentication setup" ~/.MyHome/MySpaces/my-modular-workspace/docs/

# Find related how-to guides
search "configure nginx" ~/Documents/notes/
```

#### 2. Project Code Search
```bash
# Find semantic matches in codebase
search "database migration" ~/projects/myapp/

# Find error handling patterns
search "exception handling" src/ --n-lines 3
```

#### 3. MySpaces Search (Default Workspace)
```bash
# Search across all MySpaces docs
search "nixos configuration" ~/.MyHome/MySpaces/**/*.md

# Search with context
search "ansible playbook" ~/.MyHome/MySpaces/ --n-lines 5 --top-k 5
```

### Parameters

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `--n-lines` | Lines of context to show | 3 | `--n-lines 5` |
| `--top-k` | Max results to return | 10 | `--top-k 20` |
| `--max-distance` | Similarity threshold (0-1) | 0.5 | `--max-distance 0.35` |

### Distance Threshold Guide
- **0.2-0.3:** Very strict (nearly exact matches)
- **0.35-0.4:** Moderate (recommended for most searches)
- **0.5+:** Broad (may include less relevant results)

### Performance
- **First run:** 2-3 minutes (model loads ~489MB into memory)
- **Subsequent runs:** < 2 seconds (cached)
- **Memory usage:** ~500MB while running

### Limitations (nixpkgs v1.2.0)
- ❌ `workspace` command not available (only in upstream v1.5.0)
- ❌ `ask` command not available (only in upstream v1.5.0)
- ✅ `search` command fully functional
- ✅ `parse` command available (requires LLAMA_CLOUD_API_KEY)

---

## Tool 2: semantic-grep

### Installation
- **Binary:** `/home/mitsio/.nix-profile/bin/semantic-grep`
- **Model:** GoogleNews-vectors-negative300-SLIM (346MB)
- **Location:** `~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin`
- **Config:** `~/.config/semantic-grep/config.json`

### Basic Usage

```bash
# Basic word-level semantic search
semantic-grep -t 0.6 error /var/log/syslog

# With line numbers
semantic-grep -n -t 0.6 deployment logs/app.log

# With context lines (2 before and after)
semantic-grep -C 2 -t 0.65 failure logs/error.log

# Only show matching words
semantic-grep -o -t 0.7 success project-status.txt
```

### Common Use Cases

#### 1. Log Analysis
```bash
# Find semantic variations of "error"
semantic-grep -t 0.6 -C 2 error /var/log/syslog
# Matches: error, failure, exception, crash, problem

# Find deployment-related entries
semantic-grep -n -t 0.65 deployment logs/app.log
# Matches: deployment, rollout, release, installation
```

#### 2. Code Comment Search
```bash
# Find TODO variations
semantic-grep -t 0.65 todo src/**/*.py
# Matches: TODO, FIXME, HACK, NOTE

# Find error handling comments
semantic-grep -t 0.6 -C 1 error src/**/*.go
```

#### 3. Documentation Word Search
```bash
# Find semantic word matches in docs
semantic-grep -t 0.6 configuration docs/**/*.md

# Search with broad threshold
semantic-grep -t 0.5 success project-reports/
```

#### 4. Pipe from stdin
```bash
# Search in command output
cat /var/log/syslog | semantic-grep -t 0.6 problem

# Search in grep results
grep "2025-12" /var/log/app.log | semantic-grep -t 0.65 error
```

### Parameters

| Parameter | Short | Description | Example |
|-----------|-------|-------------|---------|
| `--threshold` | `-t` | Similarity threshold (0-1) | `-t 0.6` |
| `--context` | `-C` | Lines before & after | `-C 2` |
| `--before-context` | `-B` | Lines before match | `-B 3` |
| `--after-context` | `-A` | Lines after match | `-A 3` |
| `--line-number` | `-n` | Show line numbers | `-n` |
| `--only-matching` | `-o` | Only show matching words | `-o` |
| `--only-lines` | `-l` | Only matched lines (no scores) | `-l` |
| `--ignore-case` | `-i` | Case insensitive | `-i` |

### Threshold Guide
- **0.5-0.6:** Broad matches (many semantic variants)
- **0.6-0.7:** Moderate matches (recommended, default)
- **0.7-0.8:** Strict matches (close semantic similarity)
- **0.8+:** Very strict (almost exact)

### Example Semantic Matches

| Query | Threshold | Matches (examples) |
|-------|-----------|-------------------|
| error | 0.6 | error, failure, exception, crash, fault |
| success | 0.6 | success, successful, achieve, accomplish |
| deployment | 0.65 | deployment, rollout, release, installation |
| configuration | 0.7 | configuration, config, setup, settings |
| problem | 0.6 | problem, issue, fault, trouble, defect |

---

## Integration Guidelines for Claude

### When to Use Semantic Search

**DO use semantic search when:**
- User asks to "find" or "search for" something
- Looking for conceptual matches (not exact strings)
- Exploring unfamiliar codebases or documentation
- Need to understand related concepts
- User says "I don't know the exact term, but something like..."

**DO NOT use semantic search when:**
- User wants exact string matches (use `grep` or `rg` instead)
- Searching for function/class names (use `ast-grep` instead)
- File name search (use `fd` or `find` instead)
- Performance is critical (semantic search is slower than grep)

---

### Usage Patterns

#### Pattern 1: Documentation Discovery
```bash
# User: "How do I configure Kubernetes?"
# Claude uses:
search "kubernetes configuration" ~/.MyHome/MySpaces/my-modular-workspace/docs/ --n-lines 5 --top-k 10

# Then read relevant files and provide answer
```

#### Pattern 2: Error Investigation
```bash
# User: "Find errors in the application logs"
# Claude uses:
semantic-grep -t 0.6 -C 2 -n error /var/log/app.log

# Analyze results and explain errors found
```

#### Pattern 3: Concept Exploration
```bash
# User: "What do I have about Docker deployments?"
# Claude uses:
search "docker deployment" ~/.MyHome/MySpaces/ --max-distance 0.4

# Review results and summarize findings
```

#### Pattern 4: Word Variant Discovery
```bash
# User: "Find all success-related messages"
# Claude uses:
semantic-grep -t 0.6 success logs/deployment.log

# Report all semantic variants found
```

---

### Combining with Other Tools

#### Semantic Search + File Read
```bash
# 1. Find relevant files
search "authentication setup" docs/ --top-k 5

# 2. Read the most relevant file
Read <top_result_file>

# 3. Answer user's question with context
```

#### Semantic Search + Grep (Refinement)
```bash
# 1. Broad semantic search
semantic-grep -t 0.5 error logs/

# 2. Refine with exact grep
grep "ERROR.*authentication" <semantic_results_file>
```

#### Semantic Search + Code Tools
```bash
# 1. Find conceptually related files
search "database migration" src/

# 2. Use ast-grep for exact code patterns
ast-grep --pattern 'def migrate_$$$()' <relevant_files>
```

---

### Best Practices

#### 1. Start Broad, Then Narrow
```bash
# Bad: Too specific immediately
semantic-grep -t 0.8 "specific exact phrase" docs/

# Good: Start broad, refine
semantic-grep -t 0.6 "general concept" docs/
# Review results, then narrow with grep if needed
```

#### 2. Use Appropriate Tool for Use Case
```bash
# For documentation - use search (line-level)
search "how to configure nginx" docs/

# For logs - use semantic-grep (word-level)
semantic-grep -t 0.6 error /var/log/syslog
```

#### 3. Show Relevance Scores to User
```bash
# When reporting results, include similarity scores
semantic-grep -n -t 0.6 failure logs/app.log
# → Report: "Found 'error' with similarity 0.73"
```

#### 4. Respect Performance Impact
```bash
# Bad: Search entire filesystem
search "query" /

# Good: Search specific relevant directories
search "query" ~/.MyHome/MySpaces/my-modular-workspace/
```

---

### Error Handling

#### Model Not Loaded
If search fails with "model not found":
```bash
# Check model location
ls -lh ~/.cache/huggingface/hub/models--minishlab--potion-multilingual-128M/snapshots/main/

# For semantic-grep:
ls -lh ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin

# If missing, run:
home-manager switch --flake .#mitsio@shoshin
```

#### First Run Slowness
- Expected: First search takes 2-3 minutes (model loading)
- Explain to user: "Loading semantic search model (one-time, ~3 min)..."
- Subsequent searches: < 2 seconds

#### No Results
If no results found:
1. Lower threshold (make search broader)
2. Try alternative query terms
3. Expand search directory
4. Verify files exist in search path

---

### Output Formatting

#### When Reporting Results
```markdown
**Semantic Search Results** (search "kubernetes deployment")

Found 5 relevant matches:

1. **docs/kubernetes/deployment-guide.md** (relevance: 0.31)
   - Line 42: "Kubernetes Deployment strategies include..."

2. **sessions/k8s-setup/notes.md** (relevance: 0.28)
   - Line 15: "Deploy applications using kubectl apply..."

[Read top result for detailed answer]
```

#### When Using in Analysis
```markdown
Searching codebase for authentication patterns...

```bash
search "authentication setup" src/ --n-lines 5 --top-k 10
```

Found 10 relevant files. Top 3:
- src/auth/setup.py (relevance: 0.25)
- src/middleware/auth.js (relevance: 0.29)
- docs/auth-guide.md (relevance: 0.32)

[Analyze and summarize patterns found]
```

---

## Advanced Usage

### Combining Both Tools

```bash
# 1. Use search for high-level concept discovery
search "error handling patterns" ~/projects/myapp/ --top-k 5

# 2. Use semantic-grep for detailed word-level analysis
semantic-grep -t 0.6 -C 2 error <relevant_files_from_step1>

# 3. Combine insights from both
```

### Threshold Tuning Strategy

```bash
# Start with moderate threshold
semantic-grep -t 0.65 deployment logs/app.log

# If too few results, lower threshold
semantic-grep -t 0.55 deployment logs/app.log

# If too many irrelevant results, raise threshold
semantic-grep -t 0.75 deployment logs/app.log
```

### Search Across Multiple Locations

```bash
# Search in multiple doc directories
search "configuration" \
  ~/.MyHome/MySpaces/my-modular-workspace/docs/ \
  ~/Documents/notes/ \
  ~/projects/*/README.md

# Use fd + semantic-grep
fd -e md | xargs semantic-grep -t 0.6 configuration
```

---

## Configuration Files

### Semtools Config (`~/.semtools_config.json`)
```json
{
  "parse": {},
  "ask": {}
}
```

**Note:** Empty by default. API keys needed only for `parse` and `ask` commands.

### Semantic-grep Config (`~/.config/semantic-grep/config.json`)
```json
{
  "model_path": "/home/mitsio/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin",
  "threshold": 0.7
}
```

**Note:** Default threshold is 0.7. Override with `-t` flag.

---

## Troubleshooting

### Issue: "Model not found"
**Solution:** Run `home-manager switch --flake .#mitsio@shoshin` to download models declaratively.

### Issue: First search is very slow
**Cause:** Model loading into memory (489MB or 346MB)
**Expected:** 2-3 minutes first time, < 2 seconds after
**Action:** Wait for first run to complete, subsequent runs will be fast

### Issue: No results found
**Causes:**
1. Threshold too high (try lowering with `-t 0.5`)
2. Query too specific (try broader terms)
3. Files not in search path (verify with `ls`)

### Issue: Too many irrelevant results
**Solutions:**
1. Raise threshold: `-t 0.75`
2. Narrow search directory
3. Use more specific query terms
4. Combine with exact grep for refinement

---

## Quick Reference

### Semtools (`search`)
```bash
search "query" <path> [--n-lines N] [--top-k K] [--max-distance D]
```

### Semantic-grep
```bash
semantic-grep [-t THRESHOLD] [-C CONTEXT] [-n] query <file>
```

### Environment
- **Workspace:** `$SEMTOOLS_WORKSPACE=myspaces`
- **Semtools model:** `~/.cache/huggingface/hub/models--minishlab--potion-multilingual-128M/`
- **Semantic-grep model:** `~/.config/semantic-grep/models/`

---

## See Also

- **Installation Plan:** `docs/plans/plan-installing-semantic-tools.md`
- **Phase 1 Status:** `sessions/local-semantic-tools-week-49/PHASE1_SEMTOOLS_STATUS.md`
- **Phase 2 Status:** `sessions/local-semantic-tools-week-49/PHASE2_SEMANTIC_GREP_STATUS.md`
- **Session Summary:** `sessions/summaries/2025-12-06_SEMANTIC_TOOLS_PHASE2_AND_DECLARATIVE_MODELS.md`
- **Tool Docs:** `docs/tools/semtools.md`, `docs/tools/semantic-grep.md`
- **TODO.md:** Section 1.1 (semtools), Section 1.2 (semantic-grep)

---

**Last Updated:** 2025-12-06
**Tools Version:** semtools v1.2.0, semantic-grep v0.7.0
**Status:** Both tools installed, tested, and working ✅
