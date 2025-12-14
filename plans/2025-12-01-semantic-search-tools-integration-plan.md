# Semantic Search Tools Integration Plan

**Author:** mitsio + Claude Code
**Date:** 2025-12-01
**Status:** Ready for Implementation
**ADRs:** ADR-005, ADR-007
**Priority:** High (enables Claude Code semantic search)

---

## Executive Summary

This plan integrates local semantic search tools into my-modular-workspace to enable:
1. **Code search by meaning** (not just keywords)
2. **Claude Code MCP integration** for AI-assisted search
3. **grep replacement** with semantic capabilities

**Tools Selected:**
- **ck (ck-search)** - PRIMARY: MCP server, 100% local, grep-compatible
- **w2vgrep** - SECONDARY: Word2Vec semantic grep (already partially integrated)

**Tools Skipped:**
- **semtools** - Optional, add later if document parsing needed
- **Open Semantic Search** - Too heavy for personal workspace

---

## Phase 1: ck (ck-search) Integration

**Priority:** High
**Estimated Effort:** 2-3 hours
**Dependencies:** None

### Step 1.1: Create home-manager/ck-search.nix

```nix
# home-manager/ck-search.nix
{ config, pkgs, lib, ... }:

{
  # ====================================
  # ck-search - Semantic Code Search
  # ====================================
  # Local semantic and hybrid BM25 grep/search tool
  # Repo: https://github.com/BeaconBay/ck
  # Binary: ck

  home.packages = with pkgs; [
    (rustPlatform.buildRustPackage rec {
      pname = "ck-search";
      version = "0.7.0";

      src = fetchFromGitHub {
        owner = "BeaconBay";
        repo = "ck";
        rev = version;
        # TODO: Get hash with: nix-prefetch-github BeaconBay ck --rev 0.7.0
        sha256 = lib.fakeHash;
      };

      cargoLock = {
        lockFile = "${src}/Cargo.lock";
        allowBuiltinFetchGit = true;
      };

      # Optimize build
      CARGO_PROFILE_RELEASE_LTO = "thin";

      # Native dependencies (if needed)
      nativeBuildInputs = [ pkg-config ];
      buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

      meta = {
        description = "Semantic and hybrid BM25 grep/search tool for AI and humans";
        homepage = "https://github.com/BeaconBay/ck";
        license = with lib.licenses; [ mit asl20 ];
        mainProgram = "ck";
        platforms = lib.platforms.unix;
      };
    })
  ];

  # Note: ck config is per-project (.ckignore), not user-level
  # MCP server registration handled separately in Claude Code settings
}
```

### Step 1.2: Get Correct Hashes

```bash
# Get source hash
nix-prefetch-github BeaconBay ck --rev 0.7.0

# Update sha256 in ck-search.nix with result

# Build once to get cargoHash (if cargoLock fails)
# The error will show the correct hash
nix build -L
```

### Step 1.3: Add Import to home.nix

```nix
# In home-manager/home.nix, add:
imports = [
  # ... existing imports ...
  ./ck-search.nix        # Semantic code search with MCP
];
```

### Step 1.4: Build and Test

```bash
# Switch home-manager
home-manager switch --flake .#mitsio@shoshin

# Test binary
ck --version
ck --help

# Test semantic search
ck --sem "rclone sync" ~/.MyHome/MySpaces/my-modular-workspace/
ck --hybrid "ansible playbook" ~/.MyHome/MySpaces/my-modular-workspace/ansible/

# Test TUI
ck --tui
```

### Step 1.5: Register MCP Server

**Option A: Via Claude Code CLI (Recommended)**
```bash
claude mcp add ck-search -s user -- ck --serve
claude mcp list  # Verify
```

**Option B: Manual Configuration**
```json
// ~/.claude/settings.json
{
  "mcpServers": {
    "ck-search": {
      "command": "ck",
      "args": ["--serve"],
      "cwd": "/home/mitsio/.MyHome/MySpaces/my-modular-workspace"
    }
  }
}
```

### Step 1.6: Verify MCP Integration

```bash
# In Claude Code, test:
# - /mcp should list ck-search
# - Semantic search should work in prompts
```

---

## Phase 2: Fix w2vgrep (semantic-grep.nix)

**Priority:** Medium
**Estimated Effort:** 1 hour
**Dependencies:** None

### Step 2.1: Fix vendorHash

```nix
# In home-manager/semantic-grep.nix, replace:
vendorHash = lib.fakeHash;

# With actual hash (get from build error):
vendorHash = "sha256-ACTUAL_HASH_HERE";
```

### Step 2.2: Build and Test

```bash
# Build
nix build -L

# Get hash from error, update, rebuild

# Test
w2vgrep --help
echo "The system configuration is working" | w2vgrep -n "config"
```

### Step 2.3: Uncomment Import

```nix
# In home-manager/home.nix, uncomment:
./semantic-grep.nix  # w2vgrep - TEMPORARILY DISABLED → ENABLED
```

### Step 2.4: Switch and Verify

```bash
home-manager switch --flake .#mitsio@shoshin

# Verify model download
ls -lh ~/.config/semantic-grep/models/

# Test search
w2vgrep -C 2 --threshold=0.6 "configuration" docs/
```

---

## Phase 3: Navi Cheatsheet

**Priority:** Medium
**Estimated Effort:** 30 minutes

### Create local-semantic-search.cheat

```bash
# File: dotfiles/dot_local/share/navi/cheats/local-semantic-search.cheat
```

```cheat
% ck, semantic, search, code

# Semantic search for concept in codebase
ck --sem "<query>" <path>

# Hybrid search (semantic + keyword BM25)
ck --hybrid "<query>" <path>

# Interactive TUI mode
ck --tui

# Start MCP server for Claude Code
ck --serve

# grep-compatible search with context
ck -n -A 3 -B 1 "<pattern>" <path>

# Full function/class extraction with semantic search
ck --sem --full-section "<query>" <path>

# JSONL output for automation/scripting
ck --jsonl --sem "<query>" <path>

# Show relevance scores
ck --hybrid --scores "<query>" <path>

# High-confidence results only
ck --jsonl --topk 5 --threshold 0.7 "<query>" <path>

# Check index status
ck --status <path>

# Force reindex with specific model
ck --clean <path> && ck --index --model nomic-v1.5 <path>

% w2vgrep, semantic, word2vec

# Semantic word search (word2vec)
w2vgrep -C 2 -n --threshold=<threshold:0.6> "<query>" <file>

# Case-insensitive semantic search
w2vgrep -i --threshold=0.7 "<query>" <file>

# Only show matching words with scores
w2vgrep -o --threshold=0.7 "<query>" <file>

# Search with multiple patterns from file
w2vgrep -f patterns.txt -n --threshold=0.6 <file>
```

### Add to Chezmoi

```bash
chezmoi add ~/.local/share/navi/cheats/local-semantic-search.cheat
```

---

## Phase 4: Documentation Updates

**Priority:** Low
**Estimated Effort:** 30 minutes

### 4.1 Update docs/tools/README.md

Add links to new tool documentation:
- ck-search.md
- semtools.md (reference only)
- open-semantic-search.md (reference only)

### 4.2 Update CLAUDE.md (if needed)

Document MCP server availability for semantic search.

---

## Verification Checklist

### Phase 1 Complete

- [ ] `ck --version` returns version
- [ ] `ck --sem "test" .` returns results
- [ ] `ck --tui` launches interface
- [ ] `claude mcp list` shows ck-search
- [ ] Semantic search works in Claude Code

### Phase 2 Complete

- [ ] `w2vgrep --help` works
- [ ] Model file exists in ~/.config/semantic-grep/models/
- [ ] `w2vgrep "config" docs/` returns results

### Phase 3 Complete

- [ ] `navi` shows local-semantic-search category
- [ ] ck commands work from navi

---

## Rollback Plan

### If ck fails to build:

```bash
# Remove import from home.nix
# Or use cargo install as fallback:
cargo install ck-search

# Add to PATH via shell.nix
```

### If w2vgrep fails:

```bash
# Keep import commented out in home.nix
# Document manual installation option
```

---

## Success Criteria

1. **ck works as grep replacement** with semantic capabilities
2. **MCP server enables Claude Code** to search code by meaning
3. **w2vgrep provides alternative** for word-level semantic search
4. **Navi cheatsheet documents** all common commands
5. **Documentation complete** for future reference

---

## Future Enhancements (Optional)

1. **Add semtools** if document parsing becomes needed
2. **Create workspace presets** for common search paths
3. **Integrate with atuin** for command history search
4. **Add kitty integration** for search results preview

---

## Timeline

| Phase | Task | Effort | Status |
|-------|------|--------|--------|
| 1 | ck integration | 2-3h | Pending |
| 2 | w2vgrep fix | 1h | Pending |
| 3 | Navi cheatsheet | 30m | Pending |
| 4 | Documentation | 30m | Done |

**Total Estimated Effort:** 4-5 hours

---

## References

- [ck Documentation](https://beaconbay.github.io/ck/)
- [ck GitHub](https://github.com/BeaconBay/ck)
- [semantic-grep GitHub](https://github.com/arunsupe/semantic-grep)
- [docs/tools/ck-search.md](../tools/ck-search.md)
- [docs/integrations/local-semantic-search-tools/](../integrations/local-semantic-search-tools/)

---

**Next Action:** Start Phase 1, Step 1.1 - Create ck-search.nix
