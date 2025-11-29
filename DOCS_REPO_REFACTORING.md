# Documentation Repository Refactoring Plan

**Created:** 2025-11-29
**Updated:** 2025-11-29 03:25 EET
**Status:** IN PROGRESS (Phase 1 Complete)
**Priority:** HIGH
**Estimated Total Effort:** 3 hours
**Version:** 3.0 - Comprehensive

---

## Quick Navigation

- [Current State](#current-state-after-phase-1)
- [Target Structure](#target-structure)
- [Phase Overview](#phase-overview)
- [Detailed Phases](#detailed-phase-instructions)
- [Session Handoff](#session-handoff-template)

---

## Executive Summary

The docs repository has grown organically and contains significant duplication, inconsistent naming, and confusing structure. This plan provides a **10-phase approach** with detailed sub-tasks to reorganize documentation for better maintainability.

**Key Goals:**
1. Eliminate all duplicate files
2. Flatten structure to max 2 levels
3. Merge multi-file tool docs into single comprehensive files
4. Create clear category separation
5. Reduce from 150+ files to ~40-50 files

---

## Current State (After Phase 1)

**Phase 1 completed on 2025-11-29 03:14 EET**

```
docs/
├── README.md                    # Needs update
├── TODO.md                      # Consolidated tasks
├── DOCS_REPO_REFACTORING.md     # This plan
│
├── adrs/                        # 4 ADR files - KEEP AS-IS
├── ansible/                     # development/, collections/
├── archive/                     # NEW - 1 file
├── chezmoi/                     # Multiple md files
├── commons/                     # NEEDS RESTRUCTURING
│   ├── integrations/            # rclone-gdrive-sync/, syncthing, etc.
│   ├── plasma-manager/          # 7 files - TO MERGE
│   ├── toolbox/                 # kitty, vscodium, navi, etc. - TO MERGE
│   └── tools/                   # continue.dev
├── home-manager/                # Many files, some duplicates
├── nixos/                       # building-flakes-docs/ - TO MERGE
├── plans/                       # Project plans
├── sync/                        # NEW - conflicts.md
└── tools/                       # NEW - empty, ready for merged files
```

---

## Target Structure

```
docs/
├── README.md                    # Updated index with navigation
├── TODO.md                      # Single consolidated TODO
├── DOCS_REPO_REFACTORING.md     # This plan (archive after completion)
│
├── adrs/                        # Architecture Decision Records
│   └── ADR-*.md                 # (4 files, unchanged)
│
├── nixos/                       # NixOS system configuration
│   ├── README.md
│   ├── flakes-guide.md          # Merged from building-flakes-docs/
│   └── debugging.md
│
├── home-manager/                # Home-manager docs
│   ├── README.md
│   ├── node2nix.md              # Merged from node2nix/
│   ├── ephemeral.md             # Merged from ideas/
│   └── plans/                   # Keep subdirectory for detailed plans
│
├── ansible/                     # Ansible automation
│   ├── README.md
│   └── development.md
│
├── chezmoi/                     # Chezmoi dotfiles
│   ├── README.md
│   └── *.md                     # Keep existing structure
│
├── tools/                       # Tool guides - FLAT (no subdirs!)
│   ├── README.md
│   ├── plasma-manager.md        # Merged from 7 files
│   ├── kitty.md                 # Merged from 6 files
│   ├── vscodium.md              # Merged from 4 files
│   ├── navi.md
│   ├── atuin.md
│   ├── kde-connect.md
│   ├── copyq.md
│   ├── llm-cli.md
│   ├── semantic-grep.md
│   └── continue-dev.md
│
├── sync/                        # Sync & backup documentation
│   ├── README.md
│   ├── rclone-gdrive.md         # Merged from integrations/
│   ├── syncthing.md             # Merged from integrations/
│   └── conflicts.md             # Already exists
│
├── plans/                       # Project plans (keep)
│   └── *.md
│
└── archive/                     # Deprecated content
    ├── gnu-stow/
    ├── nixos-experiments/
    └── old-integrations/
```

---

## Phase Overview

| Phase | Name | Status | Est. Time | Risk Level |
|-------|------|--------|-----------|------------|
| 1 | Initial Cleanup | ✅ DONE | 10 min | Low |
| 2 | Inventory & Analysis | ⏳ PENDING | 15 min | None |
| 3 | Merge Tools Part 1 | ⏳ PENDING | 30 min | Medium |
| 4 | Merge Tools Part 2 | ⏳ PENDING | 30 min | Medium |
| 5 | Merge Sync Docs | ⏳ PENDING | 20 min | Medium |
| 6 | Merge NixOS Docs | ⏳ PENDING | 20 min | Medium |
| 7 | Consolidate Home-Manager | ⏳ PENDING | 25 min | Medium |
| 8 | Clean Up Commons | ⏳ PENDING | 15 min | Low |
| 9 | Update READMEs | ⏳ PENDING | 20 min | Low |
| 10 | Validation & Finalize | ⏳ PENDING | 10 min | None |

**Total Estimated Time:** ~3 hours

---

## Detailed Phase Instructions

---

### Phase 2: Inventory & Analysis

**Purpose:** Create complete inventory before making changes
**Risk Level:** None (read-only)
**Estimated Time:** 15 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/commons/toolbox/           # All subdirectories
docs/commons/integrations/      # All subdirectories
docs/commons/plasma-manager/    # All files
docs/commons/tools/             # continue.dev
docs/home-manager/              # Root files and subdirectories
docs/nixos/building-flakes-docs/
```

#### Sub-Tasks

- [ ] **2.1** List all files in commons/toolbox/:
  ```bash
  find docs/commons/toolbox -name "*.md" -type f | sort
  ```

- [ ] **2.2** List all files in commons/integrations/:
  ```bash
  find docs/commons/integrations -name "*.md" -type f | sort
  ```

- [ ] **2.3** List all files in commons/plasma-manager/:
  ```bash
  ls -la docs/commons/plasma-manager/
  ```

- [ ] **2.4** Check for duplicates between directories:
  ```bash
  # Compare plasma-manager locations
  diff -rq docs/commons/plasma-manager/ docs/commons/toolbox/plasma-manager/ 2>/dev/null
  ```

- [ ] **2.5** Create inventory table (add to this file):

  | Directory | File Count | Files | Action |
  |-----------|------------|-------|--------|
  | commons/toolbox/plasma-manager/ | ? | ? | Merge to tools/ |
  | commons/toolbox/kitty/ | ? | ? | Merge to tools/ |
  | ... | ... | ... | ... |

- [ ] **2.6** Identify cross-references:
  ```bash
  grep -r "\[.*\](.*\.md)" docs/commons/ --include="*.md" | head -30
  ```

- [ ] **2.7** Document findings below the inventory table

#### Commit
No commit needed - this is analysis only.

#### Success Criteria
- [ ] Complete inventory table created
- [ ] All directories catalogued
- [ ] Cross-references documented
- [ ] No files modified

---

### Phase 3: Merge Tool Docs - Part 1

**Purpose:** Merge plasma-manager, kitty, and vscodium docs into single files
**Risk Level:** Medium
**Estimated Time:** 30 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/commons/plasma-manager/PLASMA_MANAGER_GUIDE.md
docs/commons/plasma-manager/PLASMA_README.md
docs/commons/plasma-manager/PLASMA_QUICK_REFERENCE.md
docs/commons/plasma-manager/PLASMA_RC2NIX_GUIDE.md
docs/commons/plasma-manager/PLASMA_TROUBLESHOOTING.md
docs/commons/plasma-manager/PLASMA_CONFIG_COMPARISON.md
docs/commons/plasma-manager/NEXT_SESSION_PROMPT.md
docs/commons/plasma-manager/TODO.md

docs/commons/toolbox/kitty/README.md
docs/commons/toolbox/kitty/KITTY_GUIDE.md
docs/commons/toolbox/kitty/DOCUMENTATION.md
docs/commons/toolbox/kitty/CONFIGURATION_SUGGESTIONS.md
docs/commons/toolbox/kitty/SESSION_SUMMARY.md
docs/commons/toolbox/kitty/TOOLS_INSTALLATION.md

docs/commons/toolbox/vscodium/README.md
docs/commons/toolbox/vscodium/PLAN.md
docs/commons/toolbox/vscodium/TODO.md
docs/commons/toolbox/vscodium/NEW_SESSION_PROMPT.md
```

#### Sub-Tasks

- [ ] **3.1** Read all plasma-manager files (listed above)

- [ ] **3.2** Create `tools/plasma-manager.md` with merged content:
  ```markdown
  # Plasma Manager Guide

  ## Overview
  [Content from PLASMA_README.md]

  ## Quick Start
  [Content from PLASMA_MANAGER_GUIDE.md - intro section]

  ## Configuration
  [Content from PLASMA_MANAGER_GUIDE.md - main section]

  ## Quick Reference
  [Content from PLASMA_QUICK_REFERENCE.md]

  ## Using rc2nix
  [Content from PLASMA_RC2NIX_GUIDE.md]

  ## Configuration Comparison
  [Content from PLASMA_CONFIG_COMPARISON.md]

  ## Troubleshooting
  [Content from PLASMA_TROUBLESHOOTING.md]

  ## Session Notes
  [Content from NEXT_SESSION_PROMPT.md - if still relevant]

  ## TODO
  [Content from TODO.md - if still relevant, or remove]
  ```

- [ ] **3.3** Verify no content lost (compare word counts):
  ```bash
  wc -w docs/commons/plasma-manager/*.md
  wc -w docs/tools/plasma-manager.md
  ```

- [ ] **3.4** Delete original plasma-manager directories:
  ```bash
  rm -rf docs/commons/plasma-manager/
  # Also check if exists in toolbox
  rm -rf docs/commons/toolbox/plasma-manager/ 2>/dev/null
  ```

- [ ] **3.5** Read all kitty files (listed above)

- [ ] **3.6** Create `tools/kitty.md` with merged content:
  ```markdown
  # Kitty Terminal Guide

  ## Overview
  [Content from README.md]

  ## Configuration
  [Content from KITTY_GUIDE.md]
  [Content from CONFIGURATION_SUGGESTIONS.md]

  ## Documentation
  [Content from DOCUMENTATION.md]

  ## Tool Installation
  [Content from TOOLS_INSTALLATION.md]

  ## Session Notes
  [Content from SESSION_SUMMARY.md - if relevant]
  ```

- [ ] **3.7** Delete original kitty directory:
  ```bash
  rm -rf docs/commons/toolbox/kitty/
  ```

- [ ] **3.8** Read all vscodium files (listed above)

- [ ] **3.9** Create `tools/vscodium.md` with merged content

- [ ] **3.10** Delete original vscodium directory:
  ```bash
  rm -rf docs/commons/toolbox/vscodium/
  ```

#### Commit
```bash
git add -A
git commit -m "refactor(docs): Phase 3 - Merge plasma-manager, kitty, vscodium docs"
```

#### Rollback if Needed
```bash
git reset --hard HEAD~1
```

#### Success Criteria
- [ ] tools/plasma-manager.md exists with all content
- [ ] tools/kitty.md exists with all content
- [ ] tools/vscodium.md exists with all content
- [ ] Original directories deleted
- [ ] No broken links (quick grep check)

---

### Phase 4: Merge Tool Docs - Part 2

**Purpose:** Merge remaining tool docs (navi, atuin, kde-connect, copyq, llm-cli, semantic-grep)
**Risk Level:** Medium
**Estimated Time:** 30 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/commons/toolbox/navi/
docs/commons/toolbox/atuin/
docs/commons/toolbox/kde-connect/
docs/commons/toolbox/copyq/
docs/commons/toolbox/llm-cli/
docs/commons/toolbox/semantic-grep/
docs/commons/integrations/atuin-claude-code-bash-history/
```

#### Sub-Tasks

- [ ] **4.1** For each tool directory, read all .md files

- [ ] **4.2** Create merged file for each tool:
  - [ ] `tools/navi.md`
  - [ ] `tools/atuin.md` (include atuin-claude-code integration)
  - [ ] `tools/kde-connect.md`
  - [ ] `tools/copyq.md`
  - [ ] `tools/llm-cli.md`
  - [ ] `tools/semantic-grep.md`

- [ ] **4.3** Delete original directories after each merge

- [ ] **4.4** Handle atuin-claude-code-bash-history:
  - Move integration content into tools/atuin.md under "## Integrations" section
  - Delete the integration directory

#### Commit
```bash
git add -A
git commit -m "refactor(docs): Phase 4 - Merge remaining tool docs"
```

#### Success Criteria
- [ ] All 6 tool files created in tools/
- [ ] Integration content merged into atuin.md
- [ ] Original directories deleted

---

### Phase 5: Merge Sync Docs

**Purpose:** Consolidate all sync-related documentation into sync/
**Risk Level:** Medium
**Estimated Time:** 20 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/commons/integrations/rclone-gdrive-sync/BEST_PRACTICES.md
docs/commons/integrations/rclone-gdrive-sync/Health_Status_Report_25-11-2025.md
docs/commons/integrations/rclone-gdrive-sync/*.md (all files)
docs/commons/integrations/backup-gdrive-home-dir-with-syncthing/*.md (all files)
docs/sync/conflicts.md (already exists)
```

#### Sub-Tasks

- [ ] **5.1** List all rclone-gdrive-sync files:
  ```bash
  ls -la docs/commons/integrations/rclone-gdrive-sync/
  ```

- [ ] **5.2** Read all rclone-gdrive-sync files

- [ ] **5.3** Create `sync/rclone-gdrive.md`:
  ```markdown
  # RClone Google Drive Sync Guide

  ## Overview
  [Description of the sync setup]

  ## Setup Instructions
  [How to configure]

  ## Configuration
  [Config file details]

  ## Best Practices
  [Content from BEST_PRACTICES.md]

  ## Health Monitoring
  [Content from Health_Status_Report]

  ## Troubleshooting
  [Common issues and solutions]
  ```

- [ ] **5.4** Delete original rclone directory:
  ```bash
  rm -rf docs/commons/integrations/rclone-gdrive-sync/
  ```

- [ ] **5.5** Read all syncthing files

- [ ] **5.6** Create `sync/syncthing.md`

- [ ] **5.7** Delete original syncthing directory

- [ ] **5.8** Create `sync/README.md`:
  ```markdown
  # Sync & Backup Documentation

  ## Overview
  Documentation for file synchronization and backup systems.

  ## Contents
  - [rclone-gdrive.md](rclone-gdrive.md) - Google Drive bisync setup
  - [syncthing.md](syncthing.md) - Syncthing P2P sync
  - [conflicts.md](conflicts.md) - How to resolve sync conflicts
  ```

#### Commit
```bash
git add -A
git commit -m "refactor(docs): Phase 5 - Consolidate sync documentation"
```

#### Success Criteria
- [ ] sync/rclone-gdrive.md created
- [ ] sync/syncthing.md created
- [ ] sync/README.md created
- [ ] Original integration directories deleted

---

### Phase 6: Merge NixOS Docs

**Purpose:** Consolidate NixOS flake documentation
**Risk Level:** Medium
**Estimated Time:** 20 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/nixos/building-flakes-docs/nixos-flakes-fundamentals.md
docs/nixos/building-flakes-docs/flake-building-best-practices.md
docs/nixos/building-flakes-docs/custom-package-building-guide.md
docs/nixos/building-flakes-docs/INSTRUCTIONS.md
docs/nixos/building-flakes-docs/SETUP_GUIDE_2025-11-05.md
docs/nixos/building-flakes-docs/warp-terminal-research.md
docs/nixos/building-flakes-docs/warp-terminal-flake-experience.md
docs/nixos/building-flakes-docs/messaging-apps-flake-learnings.md
docs/nixos/README.md
```

#### Sub-Tasks

- [ ] **6.1** Read all building-flakes-docs files

- [ ] **6.2** Categorize files:
  - **Keep in main guide:** fundamentals, best-practices, custom-package, instructions
  - **Archive:** warp-terminal-*, messaging-apps-* (experimental learnings)
  - **Review:** SETUP_GUIDE (may be outdated)

- [ ] **6.3** Create `nixos/flakes-guide.md`:
  ```markdown
  # NixOS Flakes Guide

  ## Fundamentals
  [Content from nixos-flakes-fundamentals.md]

  ## Best Practices
  [Content from flake-building-best-practices.md]

  ## Building Custom Packages
  [Content from custom-package-building-guide.md]

  ## Setup Instructions
  [Content from INSTRUCTIONS.md and SETUP_GUIDE]
  ```

- [ ] **6.4** Move experimental files to archive:
  ```bash
  mkdir -p docs/archive/nixos-experiments/
  mv docs/nixos/building-flakes-docs/warp-terminal-*.md docs/archive/nixos-experiments/
  mv docs/nixos/building-flakes-docs/messaging-apps-*.md docs/archive/nixos-experiments/
  ```

- [ ] **6.5** Delete building-flakes-docs directory:
  ```bash
  rm -rf docs/nixos/building-flakes-docs/
  ```

- [ ] **6.6** Update nixos/README.md

#### Commit
```bash
git add -A
git commit -m "refactor(docs): Phase 6 - Consolidate NixOS flake documentation"
```

#### Success Criteria
- [ ] nixos/flakes-guide.md created with essential content
- [ ] Experimental docs moved to archive/
- [ ] building-flakes-docs/ deleted

---

### Phase 7: Consolidate Home-Manager Docs

**Purpose:** Clean up duplicates and organize home-manager documentation
**Risk Level:** Medium
**Estimated Time:** 25 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/home-manager/*.md (all root-level files)
docs/home-manager/node2nix/*.md
docs/home-manager/ideas/ephemeral-home-practices/*.md
docs/home-manager/decoupling-from-nixos-config/*.md
docs/home-manager/development/*.md
docs/home-manager/installed-pkgs/*.md
docs/home-manager/manage-symlinks/*.md
docs/home-manager/plans/*.md
```

#### Sub-Tasks

- [ ] **7.1** List all files and identify duplicates:
  ```bash
  find docs/home-manager -name "*.md" -type f | sort
  ```

- [ ] **7.2** For each duplicate (root vs subdirectory):
  - Compare file contents
  - Keep the richer/more complete version
  - Delete the duplicate

- [ ] **7.3** Consolidate node2nix files:
  - Merge into `home-manager/node2nix.md`
  - Delete node2nix/ subdirectory

- [ ] **7.4** Consolidate ephemeral files:
  - Merge into `home-manager/ephemeral.md`
  - Delete ideas/ephemeral-home-practices/ subdirectory

- [ ] **7.5** Handle remaining subdirectories:
  - `development/` - keep or merge into main
  - `installed-pkgs/` - archive if outdated
  - `manage-symlinks/` - merge or archive
  - `decoupling-from-nixos-config/` - keep if active, archive if done

- [ ] **7.6** Move project-wide plans to docs/plans/:
  ```bash
  # Only if plans are cross-project
  mv docs/home-manager/plans/*.md docs/plans/
  ```

- [ ] **7.7** Delete empty subdirectories

- [ ] **7.8** Update home-manager/README.md

#### Commit
```bash
git add -A
git commit -m "refactor(docs): Phase 7 - Consolidate home-manager documentation"
```

#### Success Criteria
- [ ] No duplicate files
- [ ] Subdirectories cleaned up or removed
- [ ] README updated with current structure

---

### Phase 8: Clean Up Commons

**Purpose:** Remove or restructure the commons/ directory
**Risk Level:** Low
**Estimated Time:** 15 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/commons/ (full directory listing)
docs/commons/tools/continue.dev/*.md
```

#### Sub-Tasks

- [ ] **8.1** Inventory remaining commons/ content:
  ```bash
  find docs/commons -type f -name "*.md" | sort
  ```

- [ ] **8.2** Handle commons/tools/continue.dev/:
  - Read all files
  - Merge into `tools/continue-dev.md`
  - Delete directory

- [ ] **8.3** Handle any remaining integrations:
  - chrome-plasma-integration → archive/ if deprecated
  - semantic-search-tools → archive/ or merge

- [ ] **8.4** Delete empty subdirectories in commons/:
  ```bash
  find docs/commons -type d -empty -delete
  ```

- [ ] **8.5** If commons/ is now empty, delete it:
  ```bash
  rmdir docs/commons
  ```

#### Commit
```bash
git add -A
git commit -m "refactor(docs): Phase 8 - Remove commons directory"
```

#### Success Criteria
- [ ] commons/ directory removed (or clearly restructured)
- [ ] All useful content preserved in new locations
- [ ] Deprecated content in archive/

---

### Phase 9: Update READMEs

**Purpose:** Create or update README.md for all directories
**Risk Level:** Low
**Estimated Time:** 20 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
docs/README.md (current main readme)
All existing README.md files in subdirectories
```

#### Sub-Tasks

- [ ] **9.1** Use this README template for each directory:
  ```markdown
  # [Directory Name]

  ## Overview
  Brief description of what's in this directory.

  ## Contents
  - [file1.md](file1.md) - Description
  - [file2.md](file2.md) - Description

  ## Related Documentation
  - [Link to related docs]

  ---
  *Last updated: YYYY-MM-DD*
  ```

- [ ] **9.2** Create/update READMEs for each directory:
  - [ ] tools/README.md
  - [ ] sync/README.md
  - [ ] archive/README.md
  - [ ] nixos/README.md
  - [ ] home-manager/README.md
  - [ ] ansible/README.md
  - [ ] chezmoi/README.md
  - [ ] plans/README.md
  - [ ] adrs/README.md

- [ ] **9.3** Rewrite main docs/README.md:
  ```markdown
  # My Modular Workspace Documentation

  ## Overview
  Central documentation for the my-modular-workspace project.

  ## Directory Structure

  ```
  docs/
  ├── adrs/           # Architecture Decision Records
  ├── ansible/        # Ansible automation docs
  ├── archive/        # Deprecated documentation
  ├── chezmoi/        # Chezmoi dotfiles docs
  ├── home-manager/   # Home-manager configuration docs
  ├── nixos/          # NixOS system configuration docs
  ├── plans/          # Project plans and roadmaps
  ├── sync/           # Sync & backup documentation
  └── tools/          # Tool-specific guides
  ```

  ## Quick Links
  - [TODO.md](TODO.md) - Current tasks and priorities
  - [ADRs](adrs/) - Architecture decisions

  ## Documentation Standards
  - All directories use kebab-case
  - Maximum 2 levels of nesting
  - Each directory has a README.md

  ---
  *Last updated: YYYY-MM-DD*
  ```

#### Commit
```bash
git add -A
git commit -m "refactor(docs): Phase 9 - Update all README files"
```

#### Success Criteria
- [ ] All 9 directories have README.md
- [ ] Main README.md rewritten with structure
- [ ] All READMEs have consistent format

---

### Phase 10: Validation & Finalize

**Purpose:** Verify restructure is complete and correct
**Risk Level:** None
**Estimated Time:** 10 minutes

#### Pre-Read Paths (MUST READ BEFORE STARTING)

```
Full docs/ directory tree
All markdown files (for link validation)
```

#### Sub-Tasks

- [ ] **10.1** Generate final directory tree:
  ```bash
  tree docs/ -I '.git' --noreport
  ```

- [ ] **10.2** Count files:
  ```bash
  find docs -name "*.md" -type f | wc -l
  # Target: 40-50 files
  ```

- [ ] **10.3** Find potential broken links:
  ```bash
  grep -r "\[.*\](.*\.md)" docs/ --include="*.md" | \
    while read line; do
      file=$(echo "$line" | cut -d: -f1)
      link=$(echo "$line" | grep -oP '\]\(\K[^)]+\.md')
      dir=$(dirname "$file")
      if [ ! -f "$dir/$link" ] && [ ! -f "docs/$link" ]; then
        echo "Potential broken link in $file: $link"
      fi
    done
  ```

- [ ] **10.4** Check for empty directories:
  ```bash
  find docs -type d -empty
  ```

- [ ] **10.5** Update this plan with completion status

- [ ] **10.6** Create git tag:
  ```bash
  git tag -a v2.0-docs-restructured -m "Documentation restructured"
  ```

- [ ] **10.7** Final commit:
  ```bash
  git add -A
  git commit -m "refactor(docs): Phase 10 - Validation complete, restructure finished"
  ```

- [ ] **10.8** (Optional) Push to remote:
  ```bash
  git push origin main --tags
  ```

#### Success Criteria
- [ ] File count is 40-50
- [ ] No broken internal links
- [ ] No empty directories
- [ ] All phases marked complete
- [ ] Git tag created

---

## Session Handoff Template

Use this template when starting a new session to continue the refactoring:

```markdown
# Docs Refactoring - Session Continuation

## Context
I'm continuing the documentation repository refactoring.
Plan file: docs/DOCS_REPO_REFACTORING.md

## Current Status
- Phase 1: ✅ COMPLETE
- Phase 2: [STATUS]
- Phase 3: [STATUS]
- ...

## Before Starting
1. Read docs/DOCS_REPO_REFACTORING.md completely
2. Run: `git status` to verify clean state
3. Run: `tree docs/ -d` to see current structure
4. Read the "Pre-read paths" section for the next phase

## Next Phase to Execute
[Phase X: Name]

## Key Rules
- ALWAYS read files before deleting/merging
- ALWAYS commit after each phase
- Use `git mv` to preserve history
- Verify content before deleting originals
```

---

## Rollback Plan

### Per-Phase Rollback
```bash
# Undo last commit (keeps changes staged)
git reset --soft HEAD~1

# Undo last commit (discards changes)
git reset --hard HEAD~1
```

### Full Rollback
```bash
# Find commit before Phase 1
git log --oneline | head -20

# Reset to that commit
git reset --hard <commit-hash>
```

---

## Completion Checklist

### Final Verification
- [ ] No duplicate files in repository
- [ ] All directories use kebab-case
- [ ] Maximum 2 levels of nesting
- [ ] README.md in each directory
- [ ] No broken internal links
- [ ] File count: 40-50 (target)
- [ ] Git history preserved
- [ ] Tag v2.0-docs-restructured created

### Documentation Quality
- [ ] All READMEs have consistent format
- [ ] Main README has navigation
- [ ] Archive clearly marked as deprecated
- [ ] TODO.md is comprehensive

---

## Notes

- Phase 1 was executed on 2025-11-29 03:14 EET
- Commit: `b85c26b` - 52 files changed
- Always use `git mv` to preserve history
- Test after each phase before proceeding
- Archive uncertain content rather than deleting

---

**Plan Author:** Claude Code Session
**Plan Version:** 3.0 - Comprehensive
**Last Updated:** 2025-11-29 03:25 EET
