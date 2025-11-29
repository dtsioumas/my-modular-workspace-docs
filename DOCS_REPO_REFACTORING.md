# Documentation Repository Refactoring Plan

**Created:** 2025-11-29
**Updated:** 2025-11-29 02:07 EET
**Status:** PLANNING (v2 - Refined)
**Priority:** HIGH
**Estimated Effort:** 1-2 hours

---

## Executive Summary

The docs repository has grown organically and now contains significant duplication, inconsistent naming, and a confusing structure. This plan outlines a phased approach to clean up and reorganize the documentation for better maintainability.

---

## Current State Analysis

### Critical Issues Found

| Issue | Count | Impact |
|-------|-------|--------|
| Case-sensitive duplicate dirs | 2 | `nixos/` vs `NixOS/` |
| Triplicate content | 1 | `Plasma_Manager/` in 3 locations |
| Orphaned TODO files | 9 | Already consolidated into TODO.md |
| Empty files | 2 | 0-byte files |
| Misplaced directories | 3 | Should be reorganized |
| Inconsistent naming | 10+ | Mix of cases and separators |

### Duplicate Locations Identified

```
1. nixos/ AND NixOS/
   - Both contain: building-flakes-docs/, README.md
   - NixOS/ also has: declarative-vscodium/ (unique)

2. Plasma_Manager/ exists in 3 places:
   - docs/Plasma_Manager/ (root)
   - docs/deprecated-docs-archive/Plasma_Manager/
   - docs/commons/plasma-manager/
   All contain identical files!

3. home-manager/ internal duplicates:
   - EPHEMERALITY_STRATEGY.md (root + ideas/ephemeral-home-practices/)
   - NODE2NIX_INTEGRATION.md (root + node2nix/)
   - NPM_PACKAGES_INVENTORY.md (root + node2nix/)
```

### Root-Level TODO Files to Remove

These were consolidated into `TODO.md` on 2025-11-29:
- `ANSIBLE_TODO.md`
- `HOME_MANAGER_TODO.md`
- `SYNCTHING_TODO.md`
- `PLASMA_MANAGER_TODO.md`
- `ETC_NIXOS_CONFIG_TODO.md`
- `TODO_HOME_MANAGER_NIXOS.md`
- `CHEZMOI_NAVI_TODO.md`
- `OLD_TODO_DECOUPLING_HOME.md`
- `REMOVE_APPS_TODO.md` (empty - 0 bytes)
- `TODO.md.backup`

---

## Target Structure (v2 - Simplified)

**Design Principles:**
- Maximum 2 levels of nesting
- Single files for tools (not directories)
- Clear separation: config | tools | sync
- ~40 files total (down from 150+)

```
docs/
├── README.md                    # Index with links to all docs
├── TODO.md                      # Single consolidated TODO
│
├── adrs/                        # Architecture Decision Records
│   └── ADR-*.md                 # (keep as-is, 4 files)
│
├── nixos/                       # NixOS system configuration
│   ├── README.md
│   ├── flakes-guide.md          # Merged from building-flakes-docs/
│   ├── debugging.md
│   └── refactoring-plan.md
│
├── home-manager/                # Home-manager docs
│   ├── README.md
│   ├── node2nix.md              # Merged from node2nix/
│   ├── ephemeral.md             # Merged from ideas/
│   └── plans/                   # Keep for detailed plans
│
├── ansible/                     # Ansible automation
│   ├── README.md
│   └── development.md
│
├── chezmoi/                     # Chezmoi dotfiles (keep existing)
│   ├── README.md
│   └── *.md
│
├── tools/                       # Tool guides - FLAT (no subdirs!)
│   ├── plasma-manager.md        # Merged from 7 files
│   ├── kitty.md                 # Merged from 6 files
│   ├── vscodium.md              # Merged from 4 files
│   ├── navi.md
│   ├── atuin.md
│   ├── kde-connect.md
│   ├── copyq.md
│   ├── llm-cli.md
│   └── semantic-grep.md
│
├── sync/                        # Sync & backup documentation
│   ├── README.md
│   ├── rclone-gdrive.md         # Main sync guide
│   ├── syncthing.md
│   └── conflicts.md             # How to resolve conflicts
│
└── archive/                     # Deprecated content only
    ├── gnu-stow/
    └── old-sessions/
```

**Key Differences from v1:**
1. Removed `components/` wrapper - direct category directories
2. Tools are single files, not directories
3. Added `sync/` for all sync-related docs
4. Flattened structure - max 2 levels

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Directories | kebab-case | `plasma-manager/` |
| Files | UPPER_SNAKE.md or kebab-case.md | `README.md`, `01-overview.md` |
| ADRs | `ADR-NNN-DESCRIPTION.md` | `ADR-001-NIXPKGS_UNSTABLE.md` |

---

## Migration Phases

### Phase 1: Safe Cleanup (LOW RISK)

Delete files that are no longer needed:

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/docs

# Delete consolidated TODO files
rm ANSIBLE_TODO.md
rm HOME_MANAGER_TODO.md
rm SYNCTHING_TODO.md
rm PLASMA_MANAGER_TODO.md
rm ETC_NIXOS_CONFIG_TODO.md
rm TODO_HOME_MANAGER_NIXOS.md
rm CHEZMOI_NAVI_TODO.md
rm OLD_TODO_DECOUPLING_HOME.md
rm REMOVE_APPS_TODO.md
rm TODO.md.backup

# Delete duplicate Plasma_Manager at root
rm -rf Plasma_Manager/

# Commit
git add -A
git commit -m "cleanup: Remove consolidated TODO files and duplicate Plasma_Manager"
```

### Phase 2: Resolve Case-Sensitive Duplicates (MEDIUM RISK)

```bash
# Check for unique content in NixOS/ vs nixos/
diff -rq nixos/ NixOS/

# NixOS/declarative-vscodium/ is unique - move it
mkdir -p tools/vscodium
mv NixOS/declarative-vscodium/* tools/vscodium/

# Remove NixOS/ (duplicate of nixos/)
rm -rf NixOS/

# Commit
git add -A
git commit -m "refactor: Merge NixOS/ into nixos/, move vscodium to tools/"
```

### Phase 3: Reorganize Directory Structure

```bash
# Create new structure
mkdir -p components
mkdir -p tools
mkdir -p integrations

# Move component docs
git mv nixos components/
git mv home-manager components/
git mv ansible components/
git mv chezmoi components/

# Move tools from commons/toolbox
git mv commons/toolbox/plasma-manager tools/
git mv commons/toolbox/kitty tools/
git mv commons/toolbox/navi tools/
git mv commons/toolbox/atuin tools/
git mv commons/toolbox/copyq tools/
git mv commons/toolbox/kde-connect tools/
git mv commons/toolbox/llm-cli tools/
git mv commons/toolbox/semantic-grep tools/
git mv commons/toolbox/vscodium tools/  # already moved in Phase 2

# Move integrations
git mv commons/integrations/* integrations/
git mv syncthing-gdrive-architecture integrations/syncthing

# Rename deprecated-docs-archive
git mv deprecated-docs-archive archive

# Move project-plans content
git mv project-plans/* plans/
rmdir project-plans

# Cleanup empty directories
rmdir commons/toolbox commons/services commons/researches commons 2>/dev/null
rmdir workspace-toolbox 2>/dev/null
rmdir tools/navi  # if duplicate

# Commit
git add -A
git commit -m "refactor: Reorganize docs into components/tools/integrations structure"
```

### Phase 4: Remove Internal Duplicates

```bash
# In home-manager - remove root-level duplicates
cd components/home-manager
rm EPHEMERALITY_STRATEGY.md  # keep in ideas/ephemeral-home-practices/
rm EPHEMERAL_HOME_PRACTICES.md
rm EPHEMERAL_RESOURCES.md
rm NODE2NIX_INTEGRATION.md  # keep in node2nix/
rm NPM_PACKAGES_INVENTORY.md
rm NODE2NIX_URLS.md  # check if duplicate

# Commit
git add -A
git commit -m "cleanup: Remove duplicate files in home-manager/"
```

### Phase 5: Update Cross-References

1. Search for broken links in markdown files
2. Update any relative paths that changed
3. Add README.md to each major directory

```bash
# Find all markdown links
grep -r "\[.*\](.*\.md)" . --include="*.md"

# Update paths as needed
# Add README.md files
```

---

## Rollback Plan

If issues occur, the repository is git-tracked:

```bash
# View recent commits
git log --oneline -10

# Revert a specific commit
git revert <commit-hash>

# Or reset to before refactoring started
git reset --hard <commit-before-refactoring>
```

---

## Success Criteria

- [ ] No duplicate files in repository
- [ ] All directories use kebab-case
- [ ] Maximum 3-level directory depth
- [ ] README.md in each major directory
- [ ] All cross-references working
- [ ] Git history preserved
- [ ] Estimated file count: ~80-90 (down from 150+)

---

## Execution Checklist

### Phase 1: Safe Cleanup
- [ ] Delete 10 root-level TODO files
- [ ] Delete duplicate Plasma_Manager/
- [ ] Commit changes
- [ ] Verify git status clean

### Phase 2: Case-Sensitive Duplicates
- [ ] Diff nixos/ vs NixOS/
- [ ] Move unique content from NixOS/
- [ ] Remove NixOS/
- [ ] Commit changes

### Phase 3: Reorganize Structure
- [ ] Create components/, tools/, integrations/
- [ ] Move component directories
- [ ] Move tool directories
- [ ] Move integration directories
- [ ] Rename deprecated-docs-archive → archive
- [ ] Remove empty directories
- [ ] Commit changes

### Phase 4: Remove Internal Duplicates
- [ ] Clean home-manager/ duplicates
- [ ] Check for other internal duplicates
- [ ] Commit changes

### Phase 5: Update References
- [ ] Find broken links
- [ ] Update paths
- [ ] Add README.md files
- [ ] Final commit

---

## Notes

- Always use `git mv` to preserve history
- Test after each phase
- Keep this plan updated with progress
- User should approve structure before Phase 3

---

**Author:** Claude Code Session
**Reviewed:** Pending user approval
