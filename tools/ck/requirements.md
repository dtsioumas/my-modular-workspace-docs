# ck Configuration Requirements

**Date:** 2025-12-21
**Status:** Requirements Documented - Implementation Pending

---

## User Preferences

### Configuration Management
- **Method:** Chezmoi templates
- **Rationale:** Cross-platform, machine-specific settings capability

### Index Storage Location
- **Path:** `~/.MyHome/.ck-indexes/`
- **Rationale:**
  - Centralized location in synced MyHome directory
  - Easy to backup/restore
  - Consistent across workspace

### Default Search Mode
- **Mode:** Hybrid (semantic + lexical)
- **Rationale:** Best of both worlds - conceptual similarity + keyword matching

### Hidden Directories
- **Strategy:** Selective (use ignore list)
- **Rationale:** Include important hidden dirs (.config/, .MyHome/) while excluding caches/temp files

---

## Index Scope

### Directories to Index

1. **`~/.MyHome/MySpaces/`** - Projects
   - All project directories
   - Full semantic indexing

2. **`~/.MyHome/Volumes/`** - Mounted Volumes
   - Specific volumes that need semantic search

3. **`~/.config/`** - Configuration Files
   - Purpose: Understand current tool configurations
   - Index config files to know current workspace setup

4. **`~/`** - Home Directory Structure
   - **Structure only** - Not full content scan
   - Index directory tree and file names
   - Exclude file contents to avoid noise

### Exclusion Strategy

Use `.gitignore`-style patterns for exclusions:

```gitignore
# Standard development directories
.git/
node_modules/
target/
.cache/
build/
dist/
__pycache__/

# Trash and temporary
.Trash/
.trash/
*.tmp
*.swp
*.bak

# Binary and media (unless specifically needed)
*.exe
*.so
*.dylib
*.mp4
*.mkv
*.iso

# IDE/Editor caches
.vscode/
.idea/
*.code-workspace

# Large datasets
datasets/
models/*.bin
*.weights
```

---

## Automation Requirements

### Periodic Reindexing

- **Frequency:** Every 4 hours
- **Method:** systemd user timer
- **Service Requirements:**
  - Run `ck --index` on configured paths
  - Clean orphans before reindex
  - Log results for monitoring
  - Resource limits (CPU/Memory) via systemd

### Timer Configuration

```
OnCalendar=00/4:00:00  # Every 4 hours
Persistent=true        # Run missed executions on boot
```

---

## Implementation Plan (Future)

### Phase 1: Research & Documentation (Current)
- [x] Consolidate existing ck documentation
- [ ] Complete comprehensive ck capabilities research
- [ ] Document best practices for index management

### Phase 2: Configuration (Pending)
- [ ] Create chezmoi template for ck ignore patterns
- [ ] Create chezmoi template for ck index paths configuration
- [ ] Design systemd service/timer for automated indexing
- [ ] Test configuration on shoshin workspace

### Phase 3: Home-Manager Integration (Pending)
- [ ] Update `home-manager/semtools.nix` or create `ck.nix`
- [ ] Add systemd service/timer definitions
- [ ] Configure index location via environment variables or runtime flags
- [ ] Integrate with existing semantic search toolchain

### Phase 4: Deployment (Pending)
- [ ] Deploy chezmoi templates
- [ ] Enable systemd timer
- [ ] Initial full index build
- [ ] Monitor and tune performance

---

## Open Questions (To be answered by research)

1. **Index Location Configuration:**
   - How to specify custom index location? Environment variable? CLI flag?
   - Can ck respect `XDG_CACHE_HOME` or similar?

2. **Ignore Patterns:**
   - Does ck support .ckignore file?
   - Can we use existing .gitignore files?
   - How to specify global ignore patterns?

3. **Multi-Directory Indexing:**
   - Can one ck index span multiple root directories?
   - Or do we need separate indexes per root?
   - How to search across multiple indexes?

4. **GPU Configuration:**
   - Current GPU support status (CUDA 11 vs 12)
   - Performance benchmarks GPU vs CPU
   - VRAM requirements for indexing

5. **Incremental Updates:**
   - Does ck support incremental index updates?
   - Or does it require full rebuild each time?
   - How to detect changed files efficiently?

---

## References

- **GitHub:** https://github.com/BeaconBay/ck
- **Current Version:** 0.7.0
- **Home-Manager Module:** `home-manager/mcp-servers/rust-custom.nix`
- **Related Docs:** `docs/tools/ck/`

---

**Next Steps:**
1. Wait for research agent completion
2. Answer open questions based on research
3. Document ck capabilities comprehensively
4. Create detailed implementation plan
5. DO NOT implement yet - await user approval
