# Documentation Repository Refactoring Plan

**Created:** 2025-11-29
**Updated:** 2025-11-30 03:52 EET
**Status:** Phase 2 Planning Complete
**Priority:** HIGH
**Version:** 4.0 - Phase 2 Compaction

---

## Quick Navigation

- [Phase 1 Summary](#phase-1-summary-complete)
- [Phase 2 Plan](#phase-2-further-compaction)
- [Target Structure](#phase-2-target-structure)
- [Detailed Phases](#phase-2-detailed-phases)

---

## Executive Summary

### Phase 1 (Complete - 2025-11-29)
Reduced 121 files to 82 files. Merged tools/, sync/, created archive/.

### Phase 2 (This Plan - 2025-11-30)
Further compaction: **76 → ~57 files** (-19 files)

**Key Goals:**
1. Archive dated plans (17-11-2025)
2. Expand integrations/ with KeePassXC content
3. Compact chezmoi/ (11 → 6 files)
4. Compact home-manager/ (14 → 9 files)
5. Clean up URL lists and duplicates

---

## Phase 1 Summary (Complete)

**Commits:**
- `7ec38c5` - Remove duplicates, consolidate home-manager plans (-3,233 lines)
- `66c580b` - Update READMEs
- Previous phases: 10 total

**Current State (76 files):**
```
docs/
├── tools/           # 12 files - DONE
├── sync/            # 4 files - DONE
├── nixos/           # 6 files
├── home-manager/    # 14 files - NEEDS COMPACTION
├── chezmoi/         # 11 files - NEEDS COMPACTION
├── ansible/         # 5 files
├── adrs/            # 5 files - KEEP
├── archive/         # 8 files
├── plans/           # 7 files - NEEDS CLEANUP
├── integrations/    # 1 file - NEEDS EXPANSION
└── root             # 3 files
```

---

## Phase 2: Further Compaction

### Target Reduction

| Directory | Before | After | Change | Action |
|-----------|--------|-------|--------|--------|
| tools/ | 12 | 12 | 0 | Keep |
| sync/ | 4 | 4 | 0 | Keep |
| nixos/ | 6 | 5 | -1 | Remove NIXOS_URLS.md |
| home-manager/ | 14 | 9 | -5 | Merge migrations, remove URL list |
| chezmoi/ | 11 | 6 | -5 | Merge numbered files |
| ansible/ | 5 | 4 | -1 | Remove duplicate skeleton |
| adrs/ | 5 | 5 | 0 | Keep |
| archive/ | 8 | 15 | +7 | Absorbs archived content |
| plans/ | 7 | 3 | -4 | Archive dated plans |
| integrations/ | 1 | 2 | +1 | Merge KeePassXC content |
| root | 3 | 2 | -1 | Archive DOCS_REPO_REFACTORING |
| **TOTAL** | **76** | **~57** | **-19** | |

---

## Phase 2 Target Structure

```
docs/
├── README.md                    # Main index (updated)
├── TODO.md                      # Active tasks
│
├── tools/                       # 12 files - KEEP AS-IS
│   └── *.md
│
├── sync/                        # 4 files - KEEP AS-IS
│   └── *.md
│
├── nixos/                       # 5 files
│   ├── README.md
│   ├── flakes-guide.md
│   ├── DEBUGGING_AND_MAINTENANCE_GUIDE.md
│   ├── MIGRATION_PLAN.md
│   └── STATIC_IP_CONFIGURATION.md
│
├── home-manager/                # 9 files
│   ├── README.md
│   ├── decoupling-architecture.md
│   ├── migration.md             # MERGED: migration-plan + findings + NIXOS_CONFIG
│   ├── ephemeral.md
│   ├── node2nix.md
│   ├── DEBUGGING_AND_MAINTENANCE.md
│   ├── git-hooks-integration.md
│   ├── SYMLINK-QUICK-REFERENCE.md
│   └── DEPRECATION_FIXES.md
│
├── chezmoi/                     # 6 files
│   ├── README.md
│   ├── overview.md              # MERGED: 01 + 05
│   ├── migration.md             # MERGED: 02 + 03 + 06
│   ├── best-practices.md        # MERGED: 04 + 07
│   ├── DOTFILES_INVENTORY.md
│   └── MIGRATION_STATUS.md
│
├── ansible/                     # 4 files
│   ├── README.md
│   ├── ANSIBLE_ARA_DESKTOP_NOTIFICATIONS.md
│   ├── development/pre-commit-setup.md
│   └── collections/rclone/RESEARCH.md
│
├── integrations/                # 2 files
│   ├── README.md                # NEW
│   └── keepassxc-secrets.md     # MERGED: existing + plans/ KeePassXC
│
├── adrs/                        # 5 files - KEEP AS-IS
│   └── ADR-*.md
│
├── plans/                       # 3 files
│   ├── README.md                # Updated
│   ├── fedora-migration.md      # RENAMED from FEDORA_BLUEBUILD...
│   └── ephemerality-strategy.md # MOVED from plans/
│
└── archive/                     # 15 files
    ├── plans/                   # +4 dated plans
    ├── nixos-experiments/       # 4 files (existing)
    ├── sessions/                # +1 chezmoi session
    └── deprecated/              # +3 misc
```

---

## Phase 2 Detailed Phases

### Phase 2.1: Archive Dated Plans

**Purpose:** Move old 17-11-2025 plans to archive
**Risk:** Low
**Time:** 10 min

**Actions:**
```bash
# Create archive subdirectory
mkdir -p docs/archive/plans/

# Move dated plans
git mv plans/PLAN_OF_THE_NEW_STACK_17-11-2025.md archive/plans/
git mv plans/PROJECT_COMPREHENSIVE_PLAN_17-11-2025.md archive/plans/
git mv plans/PLAN_ANSIBLE_BOOTSTRAP_REPO_SKELETON_17-11-2025.md archive/plans/

# Rename Fedora plan (keep as active)
git mv plans/FEDORA_BLUEBUILD_REPO_SKELETON_PLAN-17-11-2025.md plans/fedora-migration.md

# Move ephemerality to plans/ (not dated, still relevant)
git mv plans/PLAN_USING_EPHEMERALITY_STRATEGY.md plans/ephemerality-strategy.md
```

**Result:** plans/ reduced from 7 to 4 files

---

### Phase 2.2: Merge KeePassXC Integration

**Purpose:** Consolidate KeePassXC docs into integrations/
**Risk:** Low
**Time:** 15 min

**Actions:**
1. Read both files:
   - `integrations/KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md`
   - `plans/KEEPASSXC_INTEGRATION_PLAN.md`

2. Create merged `integrations/keepassxc-secrets.md`:
   ```markdown
   # KeePassXC Secrets Integration

   ## Overview
   [From INTEGRATION file]

   ## Setup
   [From INTEGRATION file]

   ## Integration Points
   - Chezmoi encryption
   - Ansible secrets
   - rclone credentials
   [From both files]

   ## Implementation Plan
   [From PLAN file - if still relevant]
   ```

3. Create `integrations/README.md`

4. Delete originals:
   ```bash
   git rm plans/KEEPASSXC_INTEGRATION_PLAN.md
   git rm integrations/KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md
   git add integrations/keepassxc-secrets.md
   git add integrations/README.md
   ```

**Result:** integrations/ has 2 files, plans/ reduced by 1

---

### Phase 2.3: Compact Chezmoi Docs

**Purpose:** Merge 11 files into 6 consolidated guides
**Risk:** Medium
**Time:** 25 min

**Merge Plan:**
| New File | Source Files | Content |
|----------|--------------|---------|
| overview.md | 01-overview.md + 05-research-findings.md | What is chezmoi, research |
| migration.md | 02-migration-strategy.md + 03-implementation-guide.md + 06-tool-migration-guides.md | How to migrate |
| best-practices.md | 04-best-practices.md + 07-symlink-setup.md | Best practices |
| KEEP | DOTFILES_INVENTORY.md, MIGRATION_STATUS.md, README.md | Reference files |
| ARCHIVE | SESSION-2025-11-18.md | → archive/sessions/ |

**Actions:**
```bash
# Archive session file
mkdir -p archive/sessions/
git mv chezmoi/SESSION-2025-11-18.md archive/sessions/chezmoi-session-2025-11-18.md

# Create merged files (after reading all sources)
# Then remove old numbered files
git rm chezmoi/01-chezmoi-overview.md
git rm chezmoi/02-migration-strategy.md
git rm chezmoi/03-implementation-guide.md
git rm chezmoi/04-best-practices.md
git rm chezmoi/05-research-findings.md
git rm chezmoi/06-tool-migration-guides.md
git rm chezmoi/07-symlink-setup.md
```

**Result:** chezmoi/ reduced from 11 to 6 files

---

### Phase 2.4: Compact Home-Manager Docs

**Purpose:** Merge migration files, remove outdated lists
**Risk:** Medium
**Time:** 20 min

**Actions:**

1. **Merge migration files:**
   - migration-plan.md + migration-findings.md + NIXOS_CONFIG_MIGRATION.md → migration.md

2. **Delete outdated files:**
   ```bash
   git rm home-manager/GUI_APPS_ADDED.md      # Outdated, info in home.nix
   git rm home-manager/LIST-GUI_APPS.md       # Outdated, info in home.nix
   git rm home-manager/USEFULL_URLS.md        # Outdated links
   ```

3. **Update README.md** with new file list

**Result:** home-manager/ reduced from 14 to 9 files

---

### Phase 2.5: Final Cleanup

**Purpose:** Remove remaining duplicates and URL lists
**Risk:** Low
**Time:** 15 min

**Actions:**

1. **Remove NIXOS_URLS.md:**
   ```bash
   git rm nixos/NIXOS_URLS.md  # Outdated links
   ```

2. **Remove ansible duplicate:**
   ```bash
   git rm ansible/ANSIBLE_BOOTSTRAP_REPO_SKELETON_DRAFT_1.md  # Duplicate of plans/
   ```

3. **Archive this plan file:**
   ```bash
   git mv DOCS_REPO_REFACTORING.md archive/DOCS_REPO_REFACTORING.md
   ```

4. **Update main README.md** with final file counts

5. **Create archive/README.md** explaining archived content

---

### Phase 2.6: Validation

**Purpose:** Verify final state
**Time:** 10 min

**Checks:**
```bash
# Count files
find docs -name "*.md" | wc -l  # Target: ~57

# Check structure
tree docs -d

# Verify no broken links
grep -r "\.md)" docs --include="*.md" | head -20

# Verify no empty directories
find docs -type d -empty
```

**Final Commit:**
```bash
git add -A
git commit -m "docs: Phase 2 compaction complete - 76 to 57 files"
git tag v2.1-docs-compacted
```

---

## Summary

### Phase 2 Overview

| Phase | Name | Files Changed | Time |
|-------|------|--------------|------|
| 2.1 | Archive dated plans | -4 moved | 10 min |
| 2.2 | Merge KeePassXC | -1 merged | 15 min |
| 2.3 | Compact chezmoi | -5 merged | 25 min |
| 2.4 | Compact home-manager | -5 merged | 20 min |
| 2.5 | Final cleanup | -3 removed | 15 min |
| 2.6 | Validation | verify | 10 min |
| **TOTAL** | | **-19 files** | **~95 min** |

### Expected Result

**Before Phase 2:** 76 files
**After Phase 2:** ~57 files
**Reduction:** 25% fewer files, better organization

---

**Plan Author:** Claude Code Session
**Plan Version:** 4.0 - Phase 2 Compaction
**Last Updated:** 2025-11-30 03:52 EET
