# Comprehensive Installation Plan: Semantic Search Tools

**Date:** 2025-12-03
**Last Updated:** 2025-12-06
**Target System:** shoshin (NixOS desktop)
**Planning Confidence:** 0.85 (Band C - Safe to implement)

## Implementation Status

| Phase | Tool | Status | Completed | Notes |
|-------|------|--------|-----------|-------|
| **Phase 1** | semtools | ✅ COMPLETE | 2025-12-05 | Installed v1.2.0, model cached (507MB), tested working |
| **Phase 2** | semantic-grep | ✅ COMPLETE | 2025-12-06 | Fixed build, model downloaded (346MB), tested working |
| **Phase 3** | ck | ⏸️ PENDING | - | Evaluation needed after Phase 1+2 testing |

**Current Status:** Phase 2 complete. Phase 3 evaluation pending.

---

## Executive Summary

This plan covers the installation and integration of three semantic search tools into the shoshin workspace via home-manager:

1. **semtools** - Line-level semantic search with document parsing and workspace caching
2. **semantic-grep (w2vgrep)** - Word-level grep-like semantic search
3. **ck** - Comprehensive tool with semantic + hybrid search, TUI, and MCP server

**Recommendation:** Install in order 1 → 2, evaluate before installing 3 (potential redundancy).

## Tool Selection Summary

| Tool | Priority | Rationale |
|------|----------|-----------|
| **semtools** | HIGH - Install first | In nixpkgs, simple install, document parsing + workspace features |
| **semantic-grep** | MEDIUM - Install second | Config exists, grep-like interface, complements semtools |
| **ck** | LOW - Evaluate need | Most features but cargo-only, may be redundant |

---

# PHASE 1: Install Semtools

**Goal:** Add semtools v1.2.0 from nixpkgs with shell environment and optional API keys.

## Step 1.1: Create semtools.nix Module

**File:** `home-manager/semtools.nix`

```nix
{ config, pkgs, lib, ... }:

{
  # ====================================
  # Semtools - Semantic Search Tool
  # ====================================
  # Semantic search and document parsing for command line
  # Repo: https://github.com/run-llama/semtools
  # Docs: docs/tools/semtools.md

  home.packages = with pkgs; [
    semtools  # v1.2.0 from nixpkgs
  ];

  # ====================================
  # Shell Environment
  # ====================================

  programs.bash.bashrc = ''
    # Semtools workspace for MySpaces
    export SEMTOOLS_WORKSPACE=myspaces
  '';

  # Optional: Shell aliases for convenience
  programs.bash.shellAliases = {
    "search-docs" = "search --n-lines 5 --max-distance 0.35";
    "search-code" = "search --n-lines 3 --max-distance 0.3";
  };

  # ====================================
  # Configuration (Optional)
  # ====================================
  #
  # API keys are optional:
  # - parse command needs LLAMA_CLOUD_API_KEY
  # - ask command needs OPENAI_API_KEY
  # - search and workspace commands are fully local (no API needed)
  #
  # If you need these commands, set keys via:
  # 1. Environment variables (recommended for secrets)
  # 2. Config file (shown below, leave empty)

  home.file.".semtools_config.json" = {
    text = builtins.toJSON {
      parse = {
        # api_key = "";  # Set from secrets/env if needed
        # num_ongoing_requests = 10;
        # base_url = "https://api.cloud.llamaindex.ai";
      };
      ask = {
        # api_key = "";  # Set from secrets/env if needed
        # base_url = null;
        # model = "gpt-4o-mini";
        # max_iterations = 20;
      };
    };
    onChange = ''
      echo "semtools config updated at ~/.semtools_config.json"
    '';
  };
}
```

## Step 1.2: Import Module in home.nix

**File:** `home-manager/home.nix`

Add to imports section:

```nix
imports = [
  # ... existing imports
  ./semtools.nix
];
```

## Step 1.3: Apply Configuration

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .
```

## Step 1.4: Verify Installation

```bash
# Check binary
which semtools
semtools --version  # Should show: semtools 1.2.0 or similar

# Check environment
echo $SEMTOOLS_WORKSPACE  # Should show: myspaces

# Test search (fully local, no API needed)
echo "test content about kubernetes" > /tmp/test.txt
search "deployment" /tmp/test.txt
```

## Step 1.5: Initialize MySpaces Workspace

```bash
# Create workspace
workspace use myspaces
# Output: Workspace 'myspaces' configured

# Confirm active
workspace status
# Output: Active workspace: myspaces

# Initial indexing (builds cache)
search "test" ~/.MyHome/MySpaces/my-modular-workspace/docs/**/*.md --top-k 1

# Regular usage
search "kubernetes deployment" ~/.MyHome/MySpaces/**/*.md --n-lines 5 --max-distance 0.35
```

## Step 1.6: Update Claude Code Integration

**File:** `~/.claude/CLAUDE.md` (or project-specific `.claude/CLAUDE.md`)

Add section:

```markdown
## Semantic Search Tools

### Semtools

You have access to `semtools` CLI for semantic search and document parsing:

**Commands:**
- `search "query" files` - Semantic search (fully local)
- `workspace use <name>` - Create/switch workspace
- `workspace status` - Check workspace info
- `parse docs/*.pdf` - Parse documents (requires LLAMA_CLOUD_API_KEY)
- `ask "question?" docs/*` - AI Q&A (requires OPENAI_API_KEY)

**Search is fully local - no API keys needed!**

**Examples:**
```bash
# Semantic search across MySpaces
search "kubernetes config" ~/.MyHome/MySpaces/**/*.md --n-lines 5

# Find related documentation
search "ansible playbook" ~/.MyHome/MySpaces/my-modular-workspace --max-distance 0.3

# Workspace is already active (myspaces)
search "deployment patterns" . --top-k 10
```

**Workspace:** Pre-configured as `myspaces` for faster searches.
```

## Step 1.7: Testing Checklist

- [ ] Binary installed and in PATH
- [ ] Version check passes
- [ ] Environment variable set (SEMTOOLS_WORKSPACE)
- [ ] Workspace created successfully
- [ ] Basic search works on test file
- [ ] MySpaces search works
- [ ] Config file created (even if empty)

**Success Criteria:**
- All tests pass
- No errors during home-manager switch
- Search returns relevant results

---

# PHASE 2: Install Semantic-Grep (w2vgrep)

**Goal:** Activate existing semantic-grep.nix configuration with model download and integration.

## Step 2.1: Review Existing Configuration

**File:** `home-manager/semantic-grep.nix`

The configuration already exists and includes:
- BuildGoModule for semantic-grep v0.7.0
- Config directory creation
- Config file generation
- Automatic model download (~350MB GoogleNews-slim)

## Step 2.2: Fix vendorHash

**Issue:** Current config has `vendorHash = lib.fakeHash;`

**Fix in:** `home-manager/semantic-grep.nix:26`

```nix
# Replace this:
vendorHash = lib.fakeHash;

# With correct hash (after test build):
# Run: nix-build -E 'with import <nixpkgs> {}; callPackage ./semantic-grep.nix {}'
# Get hash from error message, then update:
vendorHash = "sha256-CORRECT_HASH_HERE";
```

**Note:** If hash is difficult to obtain, can temporarily use:
```nix
vendorHash = null;  # Disables vendor verification (not recommended for production)
```

## Step 2.3: Import Module in home.nix

**File:** `home-manager/home.nix`

Add to imports section:

```nix
imports = [
  # ... existing imports
  ./semtools.nix
  ./semantic-grep.nix
];
```

## Step 2.4: Apply Configuration

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# First attempt - may fail on vendorHash
home-manager switch --flake .

# If it fails, note the correct hash from error
# Update semantic-grep.nix:26 with correct hash
# Then retry:
home-manager switch --flake .
```

**Expected:** Model download on first activation (~350MB, may take several minutes).

## Step 2.5: Verify Installation

```bash
# Check binary
which w2vgrep
w2vgrep --help

# Check config
cat ~/.config/semantic-grep/config.json

# Check model
ls -lh ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin
# Should show: ~350MB file

# Test basic search
echo "The server crashed due to an error" | w2vgrep -t 0.6 failure
# Should find "error" as semantically similar to "failure"
```

## Step 2.6: Integration Testing

```bash
# Search MySpaces docs
w2vgrep -C 2 -t 0.6 deployment ~/.MyHome/MySpaces/my-modular-workspace/docs/**/*.md

# Word-level semantic matching
w2vgrep -t 0.65 failure ~/.MyHome/MySpaces/my-modular-workspace/sessions/**/*.md

# Combine with other tools
fd -e md | xargs w2vgrep -t 0.6 kubernetes
```

## Step 2.7: Update Claude Code Integration

Add to `.claude/CLAUDE.md`:

```markdown
### Semantic-Grep (w2vgrep)

Grep-like semantic search with word-level matching:

**Usage:**
```bash
w2vgrep [options] <query> [files]

Options:
  -t, --threshold=  Similarity threshold (0.5-0.7 recommended)
  -C, --context=    Lines before and after (like grep)
  -n, --line-number Show line numbers
  -i, --ignore-case Case insensitive
```

**Examples:**
```bash
# Find error-related content (matches: failure, crash, exception, etc.)
w2vgrep -t 0.6 error logs/*.txt

# Search docs with context
w2vgrep -C 3 -t 0.6 kubernetes docs/**/*.md

# Pipe-friendly (like grep)
cat README.md | w2vgrep -t 0.65 installation
```

**Threshold Guide:**
- 0.5-0.6: Loose (many matches)
- 0.6-0.7: Moderate (recommended)
- 0.7-0.8: Strict (close synonyms)

**Model:** GoogleNews word2vec, fully local.
```

## Step 2.8: Testing Checklist

- [ ] vendorHash fixed (if needed)
- [ ] Binary built and installed
- [ ] Config file created
- [ ] Model downloaded successfully (~350MB)
- [ ] Basic search works
- [ ] MySpaces search works
- [ ] Threshold tuning tested

**Success Criteria:**
- w2vgrep finds semantically similar words
- Model loading works (1-2 seconds)
- Results are relevant

---

# PHASE 3: Evaluate and Optionally Install CK

**Goal:** Assess whether ck is needed given semtools + semantic-grep coverage.

## Step 3.1: Evaluation Criteria

**Ask these questions before installing:**

1. **Do you need interactive TUI search?**
   - If YES → Install ck
   - If NO → semtools + semantic-grep CLI may be sufficient

2. **Do you need hybrid search (semantic + BM25)?**
   - If YES → Install ck (unique feature)
   - If NO → semtools provides semantic, semantic-grep provides word-level

3. **Do you want built-in MCP server?**
   - If YES → Install ck (has `--serve` command)
   - If NO → Both other tools work via bash wrapper

4. **Is cargo-only installation acceptable?**
   - If YES → Can proceed
   - If NO → Wait for nixpkgs or create custom derivation

## Step 3.2: Installation Decision Tree

```
START
  ↓
[Semtools + Semantic-grep meet needs?]
  ├─ YES → SKIP CK (tool coverage sufficient)
  └─ NO → Continue evaluation
     ↓
[Need TUI or Hybrid search?]
  ├─ YES → INSTALL CK
  └─ NO → SKIP CK
```

## Step 3.3: If Installing - Option A (Direct Cargo)

**Simplest approach:**

```bash
# Install directly via cargo
cargo install ck-search

# Verify
ck --version

# Index MySpaces
cd ~/.MyHome/MySpaces/my-modular-workspace
ck --index .

# Test semantic search
ck --sem "kubernetes" docs/**/*.md

# Test hybrid search
ck --hybrid "ansible playbook" .

# Test TUI
ck --tui
```

**Pros:** Simple, latest version
**Cons:** Not managed by home-manager, manual updates

## Step 3.4: If Installing - Option B (Home-Manager Activation)

**File:** `home-manager/ck.nix`

```nix
{ config, pkgs, lib, ... }:

{
  # ====================================
  # CK - Semantic and Hybrid Search
  # ====================================
  # Comprehensive semantic code search with TUI and MCP server
  # Repo: https://github.com/BeaconBay/ck
  # Docs: docs/tools/ck.md

  # Ensure cargo is available
  home.packages = with pkgs; [ cargo ];

  # Install ck via cargo
  home.activation.installCk = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v ck &> /dev/null; then
      echo "Installing ck-search via cargo..."
      $DRY_RUN_CMD ${pkgs.cargo}/bin/cargo install ck-search
      echo "ck-search installed successfully"
    else
      echo "ck-search already installed"
    fi
  '';

  # Optional: Shell aliases
  programs.bash.shellAliases = {
    "cks" = "ck --sem";              # Quick semantic search
    "ckh" = "ck --hybrid --scores";  # Hybrid with scores
    "ckt" = "ck --tui";              # Launch TUI
  };
}
```

Then import in home.nix and apply.

**Pros:** Semi-declarative, auto-installs
**Cons:** Doesn't auto-update

## Step 3.5: CK Configuration (If Installed)

```bash
# Choose embedding model
ck --index --model nomic-v1.5 ~/.MyHome/MySpaces/my-modular-workspace

# Create .ckignore if needed
ck --print-default-ckignore > ~/.MyHome/MySpaces/my-modular-workspace/.ckignore

# Test searches
ck --sem "deployment patterns" .
ck --hybrid --scores "kubernetes config" .
ck --tui
```

## Step 3.6: CK Claude Integration (If Installed)

Add to `.claude/CLAUDE.md`:

```markdown
### CK (Comprehensive Search)

Multi-modal semantic search with TUI and hybrid capabilities:

**Search Modes:**
```bash
ck --sem "query"     # Semantic search
ck --hybrid "query"  # Semantic + BM25 keyword
ck "pattern"         # Traditional regex (grep-compatible)
```

**Interactive:**
```bash
ck --tui            # Launch interactive TUI
ck --tui "query"    # TUI with initial query
```

**Advanced:**
```bash
ck --sem --scores --threshold 0.7 "query"    # High-confidence with scores
ck --hybrid --full-section "auth" src/        # Complete functions
ck --jsonl --sem "error" . | jq               # Structured output
```

**Index managed automatically in `.ck/` directories.**
```

---

# CROSS-PHASE: Integration & Workflow

## Recommended Workflow by Use Case

### Document Discovery
```bash
# Broad semantic search (semtools)
search "kubernetes concepts" ~/.MyHome/MySpaces/**/*.md --n-lines 5

# Word-level refinement (semantic-grep)
w2vgrep -C 3 -t 0.6 orchestration ~/.MyHome/MySpaces/**/*.md

# If ck installed: Hybrid for best precision
ck --hybrid --scores "kubernetes orchestration" ~/.MyHome/MySpaces/**/*.md
```

### Code Search
```bash
# Semantic by meaning (semtools)
search "error handling patterns" src/ --max-distance 0.3

# Grep-like semantic (semantic-grep)
w2vgrep -t 0.65 exception src/**/*.py

# If ck installed: Full-section extraction
ck --sem --full-section "error handling" src/
```

### Interactive Exploration
```bash
# If ck installed: Use TUI
ck --tui

# Otherwise: Combine tools
fd -e md | fzf --preview "search {} --n-lines 3"
```

## Tool Comparison Matrix

| Feature | semtools | semantic-grep | ck |
|---------|----------|---------------|-----|
| **Installation** | Simple (nixpkgs) | Medium (Go build) | Complex (cargo) |
| **Matching** | Line-level | Word-level | Line + chunk |
| **Search modes** | Semantic | Semantic | Semantic + BM25 + Regex |
| **Interface** | CLI | CLI (grep-like) | CLI + TUI |
| **Workspace** | Yes (caching) | No | Yes (.ck/ dirs) |
| **MCP server** | Via bash | Via bash | Built-in |
| **Model size** | Embedded | 350MB download | Embedded |
| **Best for** | Document search | Grep replacement | Comprehensive search |

## Shell Integration

Add to `~/.bashrc` (or via home-manager):

```bash
# Semantic search shortcuts
alias search-docs='search --n-lines 5 --max-distance 0.35'
alias search-code='search --n-lines 3 --max-distance 0.3'

# Semantic-grep shortcuts
alias semgrep='w2vgrep -t 0.6'
alias wgrep='w2vgrep'

# If ck installed
# alias cks='ck --sem'
# alias ckh='ck --hybrid --scores'
# alias ckt='ck --tui'

# Combined workflows
search-related() {
  echo "=== Semtools search ==="
  search "$1" "${@:2}" --n-lines 3 --max-distance 0.35
  echo ""
  echo "=== Semantic-grep search ==="
  w2vgrep -t 0.6 -C 2 "$1" "${@:2}"
}
```

---

# POST-INSTALLATION

## Validation & Testing

### Comprehensive Test Suite

```bash
#!/bin/bash
# test-semantic-tools.sh

echo "Testing Semantic Search Tools Installation"
echo "=========================================="

# Test 1: Semtools
echo "1. Testing semtools..."
if command -v semtools &> /dev/null; then
  echo "  ✓ semtools binary found"
  search "test" ~/.MyHome/MySpaces/my-modular-workspace/docs/README.md &> /dev/null && echo "  ✓ search command works" || echo "  ✗ search command failed"
  workspace status &> /dev/null && echo "  ✓ workspace command works" || echo "  ✗ workspace command failed"
else
  echo "  ✗ semtools not found"
fi

# Test 2: Semantic-grep
echo ""
echo "2. Testing semantic-grep (w2vgrep)..."
if command -v w2vgrep &> /dev/null; then
  echo "  ✓ w2vgrep binary found"
  echo "test content" | w2vgrep -t 0.6 "test" &> /dev/null && echo "  ✓ semantic matching works" || echo "  ✗ search failed"
  [ -f ~/.config/semantic-grep/models/*.bin ] && echo "  ✓ model file exists" || echo "  ✗ model file missing"
else
  echo "  ✗ w2vgrep not found"
fi

# Test 3: CK (if installed)
echo ""
echo "3. Testing ck..."
if command -v ck &> /dev/null; then
  echo "  ✓ ck binary found"
  ck --version &> /dev/null && echo "  ✓ version check works" || echo "  ✗ version check failed"
else
  echo "  ℹ ck not installed (optional)"
fi

echo ""
echo "=========================================="
echo "Test suite complete"
```

### Performance Benchmarks

```bash
# Benchmark semantic search performance
cd ~/.MyHome/MySpaces/my-modular-workspace

# Semtools search
time search "kubernetes deployment" docs/**/*.md --top-k 10

# Semantic-grep search
time w2vgrep -t 0.6 "deployment" docs/**/*.md

# If ck installed
# time ck --sem "deployment" docs/**/*.md --topk 10
```

## Documentation Updates

### Files Created/Modified

- ✅ `docs/tools/semtools.md` - Semtools usage guide
- ✅ `docs/tools/semantic-grep.md` - Semantic-grep usage guide
- ✅ `docs/tools/ck.md` - CK usage guide
- ✅ `sessions/local-semantic-tools-week-49/semtools-installation-requirements.md`
- ✅ `sessions/local-semantic-tools-week-49/semantic-grep-installation-requirements.md`
- ✅ `sessions/local-semantic-tools-week-49/ck-installation-requirements.md`
- ✅ `docs/plans/plan-installing-semantic-tools.md` - This document

### Home-Manager Files

- 📝 `home-manager/semtools.nix` (to be created)
- 📝 `home-manager/semantic-grep.nix` (exists, needs vendorHash fix)
- 📝 `home-manager/ck.nix` (optional, to be created if needed)
- 📝 `home-manager/home.nix` (add imports)

## Maintenance & Updates

### Regular Maintenance

```bash
# Check workspace sizes
du -sh ~/.semtools/workspaces/myspaces
du -sh ~/.MyHome/MySpaces/my-modular-workspace/.ck

# Prune old workspace data
workspace prune

# Check semantic-grep model
ls -lh ~/.config/semantic-grep/models/

# Update tools
home-manager switch --flake ~/.MyHome/MySpaces/my-modular-workspace/home-manager
```

### Update Strategy

| Tool | Update Method | Frequency |
|------|--------------|-----------|
| semtools | Wait for nixpkgs update | When needed for features |
| semantic-grep | Update semantic-grep.nix version | As needed |
| ck | `cargo install --force ck-search` | Monthly or as needed |

---

# RISK ASSESSMENT & MITIGATIONS

## Risk Matrix

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| semantic-grep vendorHash error | High | Medium | Document hash fix procedure, provide fallback |
| Model download fails | Low | Medium | Manual download instructions, verify network |
| Tool redundancy/overlap | Medium | Low | Clear use case guidelines, evaluation phase |
| Storage space issues | Low | Low | Document sizes, provide cleanup scripts |
| Version conflicts | Low | Medium | Pin versions, test before applying |

## Rollback Procedures

### Rollback Semtools

```bash
# Remove from home.nix imports
# Then:
home-manager switch --flake ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Clean up
rm -rf ~/.semtools/
rm ~/.semtools_config.json
```

### Rollback Semantic-Grep

```bash
# Remove from home.nix imports
# Then:
home-manager switch --flake ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Clean up
rm -rf ~/.config/semantic-grep/
```

### Rollback CK

```bash
cargo uninstall ck-search
rm -rf ~/.cache/ck/
find ~/.MyHome -name ".ck" -type d -exec rm -rf {} +
```

---

# TIMELINE & EFFORT ESTIMATE

## Phase 1: Semtools
- **Effort:** 30-45 minutes
- **Complexity:** Low
- **Dependencies:** None

## Phase 2: Semantic-Grep
- **Effort:** 45-60 minutes (including vendorHash fix)
- **Complexity:** Medium
- **Dependencies:** Go build environment (handled by nix)

## Phase 3: CK (Optional)
- **Effort:** 20-30 minutes (cargo install)
- **Complexity:** Low (if cargo method)
- **Dependencies:** Rust/Cargo

## Total Estimated Time
- **Minimum (Phase 1+2):** 1.5-2 hours
- **Maximum (All phases):** 2-2.5 hours

---

# SUCCESS METRICS

## Installation Success

- [ ] All selected tools installed and in PATH
- [ ] No errors during home-manager switch
- [ ] Basic search functionality works for each tool
- [ ] Documentation accessible and clear

## Integration Success

- [ ] MySpaces searches return relevant results
- [ ] Claude Code can access tools via bash
- [ ] Workspace/indexing features work
- [ ] Performance is acceptable (< 2s for typical searches)

## Usability Success

- [ ] Clear use case guidelines for each tool
- [ ] No confusion about which tool to use when
- [ ] Workflow examples documented
- [ ] Team members can use effectively

---

# APPENDIX

## A: Useful Commands Reference

### Semtools Quick Reference
```bash
search "query" files --n-lines 5 --max-distance 0.35
workspace use <name>
workspace status
workspace prune
```

### Semantic-Grep Quick Reference
```bash
w2vgrep -t 0.6 -C 2 "query" files
w2vgrep -t 0.65 -n "query" *.md
w2vgrep --help
```

### CK Quick Reference (if installed)
```bash
ck --sem "query" .
ck --hybrid --scores "query" .
ck --tui
ck --status .
ck --index .
```

## B: Troubleshooting Guide

### Issue: semtools not found after install
**Solution:**
```bash
# Verify in nix store
nix-store -q --outputs $(nix-store -qd $(which home-manager))
# Re-apply
home-manager switch --flake <path>
```

### Issue: semantic-grep build fails
**Solution:**
```bash
# Check vendorHash
nix-build home-manager/semantic-grep.nix
# Update hash from error message
# Retry
```

### Issue: Model download slow/fails
**Solution:**
```bash
# Manual download
curl -L -o /tmp/model.bin.gz https://github.com/eyaler/word2vec-slim/raw/master/GoogleNews-vectors-negative300-SLIM.bin.gz
gunzip /tmp/model.bin.gz
mkdir -p ~/.config/semantic-grep/models/
mv /tmp/model.bin ~/.config/semantic-grep/models/GoogleNews-vectors-negative300-SLIM.bin
```

## C: Performance Tuning

### Semtools Performance
- Use stricter `--max-distance` for faster searches
- Regular `workspace prune` to remove stale data
- Consider workspace per project for isolation

### Semantic-Grep Performance
- Lower threshold (0.5-0.6) = slower but more matches
- Higher threshold (0.7-0.8) = faster but fewer matches
- Pre-filter with `rg` before semantic search

### CK Performance (if installed)
- Choose bge-small model for speed
- Use `--topk` to limit results
- Enable `.ckignore` to reduce index size

---

# PLAN CONFIDENCE & REVIEW

**Overall Plan Confidence:** 0.85 (Band C - Safe)

**Strengths:**
- Clear phased approach
- Well-researched tool capabilities
- Comprehensive testing procedures
- Good rollback procedures
- Realistic effort estimates

**Weaknesses:**
- semantic-grep vendorHash uncertainty (solvable)
- Tool overlap not fully validated in practice
- CK installation less integrated (cargo vs nix)

**Recommendation:** Proceed with Phase 1 (semtools) and Phase 2 (semantic-grep). Evaluate tool coverage before Phase 3 (ck).

**Last Updated:** 2025-12-03
**Next Review:** After Phase 2 completion
