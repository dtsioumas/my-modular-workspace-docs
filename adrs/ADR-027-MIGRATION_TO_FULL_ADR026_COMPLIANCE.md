# ADR-027: Migration to Full ADR-026 Compliance

**Status:** Proposed
**Date:** 2025-12-28
**Author:** Mitsos
**Context:** Developer review revealed ADR-026 violations in home-manager structure

---

## Context and Problem Statement

A comprehensive Developer review (2025-12-28) identified that the home-manager repository has **partial compliance** with ADR-026 (Home Manager Repository Structure and Standards):

**Violations:**
1. **Root clutter:** 9 legacy .nix files in root directory (should be in `modules/`)
2. **Missing module category:** `modules/dev/` for development runtimes
3. **Legacy artifacts:** 3 superseded overlay files not removed

**Impact:**
- Confusing navigation (40+ imports in home.nix, some from root)
- Violates "Single Source of Truth" principle
- Makes future modularization harder
- Inconsistent with documented standards

**Current assessment:** 7.7/10 structure quality

---

## Decision

**We will migrate the home-manager repository to full ADR-026 compliance through a phased cleanup:**

### Phase 1: Create Missing Module Category
Create `modules/dev/` directory structure for development runtimes:
```
modules/dev/
├── node/
│   ├── default.nix                     # Main Node.js config
│   ├── npm-tools.nix                   # Moved from root
│   ├── npm-default.nix                 # Moved from root
│   ├── npm-dream2nix.nix               # Moved from root
│   ├── npm-node-env.nix                # Moved from root
│   ├── npm-node-packages.nix           # Moved from root
│   └── npm-packages.json               # Moved from root
├── python/
│   └── default.nix                     # Future: Python development tools
├── rust/
│   └── default.nix                     # Future: Rust toolchain config
└── go/
    └── default.nix                     # Future: Go toolchain config
```

### Phase 2: Move Root Files to Proper Modules
Relocate all root-level .nix files (except required ones):
```bash
# Required to stay in root:
# - flake.nix, flake.lock, home.nix, README.md, scripts/

# Move to modules:
mv latex.nix                       → modules/apps/latex.nix
mv chezmoi-llm-integration.nix     → modules/agents/chezmoi-llm-integration.nix
mv resource-control.nix            → modules/system/resource-control.nix
mv npm-*.nix node-tools.nix        → modules/dev/node/
mv npm-packages.json               → modules/dev/node/
```

### Phase 3: Remove Legacy Artifacts
Delete superseded overlay files:
```bash
rm modules/system/overlays/onnxruntime-gpu-11.nix
rm modules/system/overlays/onnxruntime-gpu-12.nix
rm modules/system/overlays/rust-tier2-optimized.nix
```

These are superseded by:
- `onnxruntime-gpu-optimized.nix` (replaces both CUDA 11/12 versions)
- `rust-hardware-optimized.nix` (replaces tier2 optimization)

### Phase 4: Simplify Imports
Create `default.nix` in each top-level module directory:

**Example: `modules/system/default.nix`**
```nix
{ ... }: {
  imports = [
    ./autostart.nix
    ./chezmoi.nix
    ./chezmoi-modify-manager.nix
    ./keepassxc.nix
    ./resource-control.nix          # Newly moved here
    ./symlinks.nix
    ./systemd-slices.nix
  ];
}
```

**Updated `home.nix` imports:**
```nix
# BEFORE (40+ individual imports)
imports = [
  ./modules/system/systemd-slices.nix
  ./modules/system/chezmoi.nix
  ./modules/apps/firefox.nix
  # ... 37 more lines ...
  ./npm-tools.nix                  # ❌ Root file
  ./node-tools.nix                 # ❌ Root file
];

# AFTER (7 clean category imports)
imports = [
  ./modules/system
  ./modules/apps
  ./modules/cli
  ./modules/agents
  ./modules/services
  ./modules/desktop
  ./modules/dev                    # ✅ New category
];
```

---

## Rationale

### Why Now?

1. **Fresh Review:** Developer review provides clear migration path
2. **Low Risk:** Changes are structural, not functional
3. **Foundation:** Prepares for future expansion (Python, Rust, Go dev tools)
4. **Consistency:** Aligns actual structure with documented standards

### Why This Approach?

#### 1. Phased Migration (Not Big Bang)
- ✅ Each phase is independently testable
- ✅ Can be done incrementally over multiple sessions
- ✅ Easier to debug if issues arise
- ✅ Can pause/resume without breaking state

#### 2. modules/dev/ Category
- **Decision:** Create full `modules/dev/` with language subdirectories
- **Alternative considered:** Keep npm files in `modules/cli/`
- **Rejected because:** Development runtimes are distinct from CLI tools
- **Aligns with:** ADR-026 module categories

#### 3. Legacy Cleanup
- **Decision:** Remove superseded overlays immediately
- **Alternative considered:** Keep for reference
- **Rejected because:** Git history preserves them; clutter adds confusion

#### 4. Directory-based Imports
- **Decision:** Import module directories, not individual files
- **Alternative considered:** Keep individual imports for clarity
- **Rejected because:** Harder to maintain, violates DRY principle

---

## Consequences

### Positive

✅ **Full ADR-026 compliance:** Clean root, complete module categories
✅ **Improved navigation:** Clear module structure, fewer imports
✅ **Better scalability:** Easy to add new dev tools (Python, Rust, Go)
✅ **Reduced confusion:** No more "where does this file go?"
✅ **Cleaner git history:** Obvious location for all changes
✅ **Easier onboarding:** New contributors can navigate structure

### Negative

⚠️ **Breaking change:** All imports in `home.nix` must be updated
⚠️ **Git history noise:** File moves create large diffs
⚠️ **Temporary breakage risk:** Must update imports atomically
⚠️ **Muscle memory:** Need to remember new file locations

### Neutral

ℹ️ **No functional changes:** Pure refactoring, no behavior change
ℹ️ **One-time effort:** ~2-4 hours total work
ℹ️ **Testing required:** `home-manager switch --dry-run` after each phase

---

## Implementation Plan

### Phase 1: Create modules/dev/ (30 min)

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# 1. Create directory structure
mkdir -p modules/dev/node

# 2. Move npm/node files
mv npm-default.nix modules/dev/node/
mv npm-dream2nix.nix modules/dev/node/
mv npm-node-env.nix modules/dev/node/
mv npm-node-packages.nix modules/dev/node/
mv npm-packages.json modules/dev/node/
mv npm-tools.nix modules/dev/node/
mv node-tools.nix modules/dev/node/tools.nix

# 3. Create default.nix
cat > modules/dev/node/default.nix <<'EOF'
{ ... }: {
  imports = [
    ./npm-default.nix
    ./npm-dream2nix.nix
    ./npm-tools.nix
    ./tools.nix
  ];
}
EOF

# 4. Create top-level dev default.nix
cat > modules/dev/default.nix <<'EOF'
{ ... }: {
  imports = [
    ./node
  ];
}
EOF

# 5. Git commit
git add modules/dev
git commit -m "feat(structure): create modules/dev/ for development runtimes

Per ADR-027 Phase 1:
- Create modules/dev/node/ directory
- Move 7 npm/node files from root to modules/dev/node/
- Create default.nix aggregators

Partial ADR-026 compliance - root cleanup"
```

### Phase 2: Move Remaining Root Files (15 min)

```bash
# Move to apps
mv latex.nix modules/apps/

# Move to agents
mv chezmoi-llm-integration.nix modules/agents/

# Move to system
mv resource-control.nix modules/system/

# Git commit
git add modules/apps/latex.nix modules/agents/chezmoi-llm-integration.nix modules/system/resource-control.nix
git commit -m "feat(structure): move remaining root files to proper modules

Per ADR-027 Phase 2:
- latex.nix → modules/apps/
- chezmoi-llm-integration.nix → modules/agents/
- resource-control.nix → modules/system/

Root directory now clean per ADR-026"
```

### Phase 3: Remove Legacy Overlays (10 min)

```bash
cd modules/system/overlays

# Remove superseded files
git rm onnxruntime-gpu-11.nix
git rm onnxruntime-gpu-12.nix
git rm rust-tier2-optimized.nix

git commit -m "chore(overlays): remove legacy superseded overlay files

Per ADR-027 Phase 3:
- Remove onnxruntime-gpu-11.nix (superseded by onnxruntime-gpu-optimized.nix)
- Remove onnxruntime-gpu-12.nix (superseded by onnxruntime-gpu-optimized.nix)
- Remove rust-tier2-optimized.nix (superseded by rust-hardware-optimized.nix)

Cleanup reduces confusion and maintains only active overlays"
```

### Phase 4: Simplify Imports (1-2 hours)

```bash
# Create default.nix in each module category
# (Already exists in some, create for others)

# modules/system/default.nix
cat > modules/system/default.nix <<'EOF'
{ ... }: {
  imports = [
    ./autostart.nix
    ./chezmoi.nix
    ./chezmoi-modify-manager.nix
    ./keepassxc.nix
    ./resource-control.nix
    ./symlinks.nix
    ./systemd-slices.nix
  ];
}
EOF

# Repeat for modules/apps/, modules/cli/, modules/agents/, modules/services/, modules/desktop/
# (Create similar default.nix for each)

# Update home.nix imports
# Replace 40+ individual imports with 7 directory imports

# Test
home-manager switch --flake .#$(hostname) --dry-run

# Commit
git add modules/*/default.nix home.nix
git commit -m "refactor(imports): simplify home.nix with directory-based imports

Per ADR-027 Phase 4:
- Create default.nix in all module categories
- Simplify home.nix from 40+ imports to 7 directory imports
- Improves maintainability and readability

Full ADR-026 compliance achieved"
```

---

## Validation Criteria

After each phase, verify:

**Phase 1:**
```bash
# 1. No files remain in root except:
ls *.nix | grep -v -E '(flake|home|WARP).nix'
# Should return: (empty)

# 2. modules/dev/ exists
ls modules/dev/node/
# Should show: default.nix, npm-*.nix, tools.nix, npm-packages.json

# 3. Dry-run succeeds
home-manager switch --flake .#$(hostname) --dry-run
```

**Phase 2:**
```bash
# 1. Root absolutely clean
ls *.nix
# Should show ONLY: flake.nix home.nix WARP.md

# 2. Files moved correctly
ls modules/apps/latex.nix
ls modules/agents/chezmoi-llm-integration.nix
ls modules/system/resource-control.nix

# 3. Dry-run succeeds
home-manager switch --flake .#$(hostname) --dry-run
```

**Phase 3:**
```bash
# 1. Legacy overlays removed
ls modules/system/overlays/ | grep -E '(gpu-11|gpu-12|tier2)'
# Should return: (empty)

# 2. Active overlays remain
ls modules/system/overlays/
# Should show: onnxruntime-gpu-optimized.nix, rust-hardware-optimized.nix, etc.

# 3. Dry-run succeeds
home-manager switch --flake .#$(hostname) --dry-run
```

**Phase 4:**
```bash
# 1. home.nix imports simplified
grep "imports = \[" -A 10 home.nix | wc -l
# Should be < 15 lines (was 40+)

# 2. All categories have default.nix
find modules -maxdepth 2 -name "default.nix" | wc -l
# Should be >= 7

# 3. Full rebuild succeeds
home-manager switch --flake .#$(hostname)
```

---

## Rollback Plan

If any phase fails:

```bash
# Immediately rollback last commit
git reset --hard HEAD~1

# Or rollback specific file
git checkout HEAD~1 -- path/to/file.nix

# Test rollback
home-manager switch --flake .#$(hostname) --dry-run

# If that fails, use home-manager generations
home-manager generations
home-manager switch --flake .#<previous-generation>
```

---

## Success Metrics

After full migration:

- ✅ Root directory: Only 3 .nix files (flake.nix, home.nix, WARP.md)
- ✅ All 7 module categories present (system, apps, cli, agents, services, desktop, dev)
- ✅ `home.nix` imports: < 15 lines (down from 40+)
- ✅ Developer review score: 9/10 (up from 7.7/10)
- ✅ Full ADR-026 compliance
- ✅ `home-manager switch` succeeds on all machines

---

## Alternatives Considered

### Alternative 1: Leave Root Files as "Legacy" Category

**Rejected because:**
- ❌ Violates ADR-026 explicitly
- ❌ Creates confusion ("is this legacy or active?")
- ❌ Harder to deprecate later (tech debt accumulates)

### Alternative 2: Big Bang Migration (All Phases at Once)

**Rejected because:**
- ❌ High risk of breaking builds
- ❌ Harder to debug if issues arise
- ❌ No intermediate checkpoints
- ❌ Can't pause/resume work

### Alternative 3: Keep npm Files in modules/cli/

**Rejected because:**
- ❌ CLI tools != Development runtimes (semantic difference)
- ❌ Would need `modules/cli/dev-tools/` which is awkward
- ❌ `modules/dev/` aligns better with ADR-026 intent

---

## Related Decisions

- **ADR-001:** Home-Manager manages user packages → Structure must support this
- **ADR-007:** Autostart via home-manager → Now in modules/system/autostart.nix (correct)
- **ADR-010:** MCP servers as Nix packages → Now in modules/agents/mcp-servers/ (correct)
- **ADR-022:** Scripts in dotfiles → Future: move service scripts per this ADR
- **ADR-024:** Language runtime optimizations → Overlays in modules/system/overlays/ (correct)
- **ADR-026:** Structure standards → **This ADR achieves full compliance**

---

## Review Schedule

**Next Review:** 2026-01-28 (1 month after implementation)

**Review Criteria:**
- Has the migration been completed?
- Are all phases validated?
- Any issues encountered?
- Is the structure easier to navigate?
- Developer review score improved?

---

## References

- **Developer Review (2025-12-28):** `docs/home-manager/DEVELOPER_REVIEW_2025-12-28.md`
- **ADR-026:** Home Manager Repository Structure and Standards
- **Nix Flakes Manual:** https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html
- **Home-Manager Manual:** https://nix-community.github.io/home-manager/

---

**Decision:** Proposed
**Status:** Awaiting user approval for implementation
**Estimated Effort:** 2-4 hours (phased over 1-2 sessions)
**Risk:** Low (pure refactoring, validated at each phase)
**Impact:** High (full ADR-026 compliance, improved maintainability)
