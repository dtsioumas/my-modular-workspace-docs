# Local Semantic Search Tools Integration Guide

**Author:** mitsio
**Date:** 2025-12-01
**Status:** Research Complete, Implementation Pending
**Related ADRs:** ADR-005 (Chezmoi Migration Criteria), ADR-007 (Autostart via Home-Manager)

---

## Executive Summary

This document outlines the integration of local semantic search tools into the my-modular-workspace project. After researching three tools (ck, semtools, open-semantic-search), the recommended approach is:

1. **Primary:** Use **ck** for code search and Claude Code integration
2. **Optional:** Use **semtools** for document parsing (if needed)
3. **Skip:** Open Semantic Search (too heavy for personal use)

---

## Tool Comparison Matrix

| Criteria | ck | semtools | Open Semantic Search |
|----------|-----|----------|---------------------|
| **Use Case** | Code search | Doc parsing/Q&A | Enterprise research |
| **Installation** | `cargo install` | `npm install` | Docker Compose |
| **Offline** | 100% | Partial | Yes |
| **MCP Support** | Yes (built-in) | No | No |
| **Claude Code** | Native | Manual | No |
| **grep Compatible** | Yes | No | No |
| **Resource Usage** | Low | Low | High |
| **License** | MIT/Apache | MIT | GPL-3.0 |
| **Stars** | 1k | 1.5k | 1.1k |

---

## Recommended Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Environment                   │
├─────────────────────────────────────────────────────────────┤
│  MCP Servers                                                │
│    ├── ck-search (semantic_search, regex_search, hybrid)   │
│    ├── context7 (external library docs)                    │
│    ├── firecrawl (web scraping)                            │
│    └── exa (web search)                                    │
├─────────────────────────────────────────────────────────────┤
│  Local CLI Tools                                            │
│    ├── ck (semantic grep replacement)                      │
│    ├── w2vgrep (word2vec semantic grep - already installed)│
│    └── semtools (optional: document parsing)               │
├─────────────────────────────────────────────────────────────┤
│  Indexed Content                                            │
│    ├── ~/MyHome/MySpaces/my-modular-workspace/             │
│    ├── Home-manager configs                                 │
│    ├── Ansible playbooks                                    │
│    └── Documentation                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Integration Strategy

### 1. ck (Primary Semantic Search)

**Why ck:**
- MCP server built-in for Claude Code
- Drop-in grep replacement
- 100% offline
- Fast Rust implementation
- Tree-sitter language parsing

**Installation via Home-Manager:**

```nix
# home-manager/ck-search.nix
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Option A: If in nixpkgs
    # ck-search

    # Option B: Build from source
    (rustPlatform.buildRustPackage rec {
      pname = "ck-search";
      version = "0.7.0";

      src = fetchFromGitHub {
        owner = "BeaconBay";
        repo = "ck";
        rev = version;
        sha256 = lib.fakeHash;  # Update after first build
      };

      cargoLock = {
        lockFile = "${src}/Cargo.lock";
        allowBuiltinFetchGit = true;
      };

      # Build optimizations
      CARGO_PROFILE_RELEASE_LTO = "thin";

      meta = {
        description = "Semantic and hybrid grep/search tool";
        homepage = "https://github.com/BeaconBay/ck";
        license = with lib.licenses; [ mit asl20 ];
        mainProgram = "ck";
      };
    })
  ];

  # Register as MCP server (via Claude Code settings)
  # Add to ~/.claude/settings.json
}
```

**Configuration via Chezmoi:**

```bash
# ~/.config/ck/ (if config files needed)
# Currently ck uses .ckignore in project root
```

**MCP Registration:**

```bash
# Add to Claude Code
claude mcp add ck-search -s user -- ck --serve

# Or manually in ~/.claude/settings.json
```

### 2. w2vgrep (Already Integrated)

**Status:** Already configured in `home-manager/semantic-grep.nix`

**Current Issues:**
- `vendorHash = lib.fakeHash` needs fixing
- Model download (~350MB) on first activation

**Usage:**
```bash
# Semantic word search
w2vgrep -C 2 -n --threshold=0.55 "configuration" docs/
```

### 3. semtools (Optional)

**Use Case:** Document parsing (PDF, DOCX)

**Installation (if needed):**

```nix
# home-manager/semtools.nix
{ config, pkgs, lib, ... }:

{
  home.activation.install-semtools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    if command -v npm >/dev/null 2>&1; then
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      if ! npm list -g @llamaindex/semtools >/dev/null 2>&1; then
        npm install -g @llamaindex/semtools || true
      fi
    fi
  '';
}
```

**Configuration (Chezmoi):**

```bash
# ~/.semtools_config.json (via chezmoi template)
# dot_semtools_config.json.tmpl
```

---

## Navi Cheatsheets

### ck-search.cheat

```cheat
% ck, semantic search, code search

# Semantic search for concept
ck --sem "<query>" <path>

# Hybrid search (semantic + keyword)
ck --hybrid "<query>" <path>

# Interactive TUI
ck --tui

# Start MCP server for Claude Code
ck --serve

# grep-compatible search with line numbers
ck -n "<pattern>" <path>

# Full function/class extraction
ck --sem --full-section "<query>" <path>

# JSON output for automation
ck --jsonl --sem "<query>" <path>

# Check index status
ck --status <path>

# Force reindex
ck --clean <path>

# Switch embedding model
ck --switch-model nomic-v1.5 <path>
```

### semantic-tools.cheat

```cheat
% semantic, search, w2vgrep, semtools

# w2vgrep: Search by word meaning
w2vgrep -C 2 -n --threshold=<threshold:0.6> "<query>" <file>

# w2vgrep: Case-insensitive semantic search
w2vgrep -i --threshold=0.7 "<query>" <file>

# semtools: Parse documents
parse <files>

# semtools: Search parsed files
search "<query>" <files> --max-distance 0.3

# semtools: AI Q&A over documents
ask "<question>" <files>

# semtools: Workspace management
workspace use <name>
workspace status
workspace prune
```

---

## Directory Structure

```
docs/
├── tools/
│   ├── ck-search.md              # NEW
│   ├── semtools.md               # NEW
│   ├── open-semantic-search.md   # NEW
│   ├── semantic-grep.md          # Existing (w2vgrep)
│   └── README.md
├── integrations/
│   └── local-semantic-search-tools/
│       ├── README.md             # THIS FILE
│       ├── IMPLEMENTATION.md     # Step-by-step guide (TODO)
│       └── TESTING.md            # Test plan (TODO)
└── plans/
    └── semantic-search-tools-integration-plan.md  # TODO
```

---

## Implementation Checklist

### Phase 1: ck Integration (Priority: High)

- [ ] Create `home-manager/ck-search.nix`
- [ ] Build ck from source (get correct hash)
- [ ] Test binary works
- [ ] Register MCP server with Claude Code
- [ ] Create navi cheatsheet
- [ ] Add config to chezmoi (if needed)
- [ ] Document in README

### Phase 2: w2vgrep Fixes (Priority: Medium)

- [ ] Fix `vendorHash` in `semantic-grep.nix`
- [ ] Verify model download works
- [ ] Test semantic search
- [ ] Update documentation

### Phase 3: semtools (Priority: Low)

- [ ] Evaluate if document parsing is needed
- [ ] Create npm activation script
- [ ] Add config template to chezmoi
- [ ] Document API key management

---

## Configuration Files

### Claude Code MCP Settings

```json
// ~/.claude/settings.json (managed by chezmoi)
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

### .ckignore (Project Root)

```gitignore
# Auto-generated by ck on first index
# Customize for project-specific exclusions

# Build artifacts
result
result-*
.direnv

# Large data files
*.pdf
*.zip
*.tar.gz

# Keep searchable
!docs/**/*.md
!*.nix
!*.yml
```

---

## Testing Strategy

### Smoke Tests

```bash
# 1. ck binary works
ck --version

# 2. Semantic search works
ck --sem "rclone sync" ~/.MyHome/MySpaces/my-modular-workspace/

# 3. MCP server starts
ck --serve &
# Check logs

# 4. Claude Code can use it
claude mcp list
```

### Integration Tests

```bash
# Search across workspace
ck --sem "systemd service" ~/MyHome/MySpaces/my-modular-workspace/home-manager/
ck --sem "ansible playbook" ~/MyHome/MySpaces/my-modular-workspace/ansible/
ck --sem "chezmoi template" ~/MyHome/MySpaces/my-modular-workspace/dotfiles/

# Hybrid search for documentation
ck --hybrid "migration plan" ~/MyHome/MySpaces/my-modular-workspace/docs/
```

---

## Security Considerations

1. **No API Keys for ck** - 100% local, no secrets needed
2. **semtools API Keys** - If used, store in KeePassXC, not in config files
3. **Index Files** - `.ck/` directory is cache, safe to delete
4. **MCP Server** - Runs locally, no network exposure

---

## Maintenance

### Weekly

```bash
# Prune stale index entries
ck --clean .

# Update ck binary (if via cargo)
cargo install ck-search --force
```

### On Code Changes

```bash
# ck auto-updates index on search
# No manual intervention needed
```

---

## References

- [ck Documentation](https://beaconbay.github.io/ck/)
- [semtools GitHub](https://github.com/run-llama/semtools)
- [w2vgrep Documentation](../tools/semantic-grep.md)
- [Existing Semantic Search Plan](../../plans/semantic-search-integration.md)

---

## Next Steps

1. Review this document
2. Create implementation plan (`docs/plans/semantic-search-tools-integration-plan.md`)
3. Implement Phase 1 (ck)
4. Test MCP integration
5. Create navi cheatsheets
6. Update chezmoi templates
