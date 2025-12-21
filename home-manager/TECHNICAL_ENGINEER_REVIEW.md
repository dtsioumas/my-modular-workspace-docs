# Technical Engineer Review - Home-Manager Refactoring

**Date:** 2025-12-20
**Role:** Technical Engineer
**Purpose:** Validate technical risks, dependencies, and migration safety
**Base Document:** REFACTORING_REVIEW.md

---

## Executive Summary

**Risk Level:** 🟡 MEDIUM (manageable with proper planning)
**Confidence:** 0.92 (Band C - HIGH)

**Key Findings:**
- ✅ No critical blocking issues found
- ⚠️ 7 technical risks identified (all mitigable)
- ✅ Module dependencies mapped
- ✅ Migration strategy validated
- ⚠️ Rollback procedures required

---

## Technical Risk Analysis

### 1. Hardware Profile Parameterization Risk
**Risk Level:** 🟡 MEDIUM
**Impact:** Build failures if overlays don't receive hardware profile

**Details:**
- `flake.nix:55` loads `shoshinHardware = import ./profiles/hardware/shoshin.nix`
- Overlays at lines 71, 76 receive `shoshinHardware` as parameter
- If module structure changes, overlay parameterization could break

**Files Affected:**
- `overlays/firefox-memory-optimized.nix`
- `overlays/onnxruntime-gpu-optimized.nix`

**Mitigation:**
1. Keep overlays/ directory structure unchanged
2. Test overlay builds before and after refactoring
3. Verify `shoshinHardware` parameter passing

**Test Command:**
```bash
nix build .#homeConfigurations."mitsio@shoshin".config.home.packages --dry-run
```

---

### 2. MCP Server Dependencies
**Risk Level:** 🟢 LOW
**Impact:** MCP servers already modular, low risk

**Details:**
- MCP servers in `mcp-servers/` already properly modularized (ADR-010)
- 14 servers across 6 files (from-flake, npm-custom, python-custom, go-custom, rust-custom)
- `mcp-servers/default.nix` imports all sub-modules

**Dependency Chain:**
```
home.nix:72 → mcp-servers/ → default.nix → {from-flake, npm-custom, python-custom, go-custom, rust-custom}.nix
```

**No Changes Needed:** ✅ Keep current structure

---

### 3. Systemd Services Interdependencies
**Risk Level:** 🟡 MEDIUM
**Impact:** Service startup order might break

**Critical Service Dependencies:**

#### KeePassXC → Secret Loading Services
**Dependency:**
- `keepassxc.nix` must start BEFORE services needing secrets
- `rclone-gdrive.nix` depends on KeePassXC for `RCLONE_CONFIG_PASS`
- `dropbox.nix` may depend on KeePassXC for credentials

**Systemd Order:**
```
keepassxc.service (graphical-session.target)
  ↓
load-keepassxc-secrets.service
  ↓
rclone-gdrive-sync.timer → rclone-gdrive-sync.service
```

**Mitigation:**
- Verify `After=` directives in systemd services
- Test service startup order after migration
- Keep services/ module structure to preserve dependencies

#### Critical GUI Services → OOM Protection
**Dependency:**
- `critical-gui-services.nix` provides OOM-protected wrappers
- `oom-protected-wrappers.nix` must load before browser services

**Files to Keep Together:**
- `critical-gui-services.nix` → `modules/services/`
- `oom-protected-wrappers.nix` → `modules/system/`

---

### 4. Import Order Sensitivity
**Risk Level:** 🟢 LOW
**Impact:** Most modules order-independent

**Order-Sensitive Modules:**

#### Must Load Early:
1. `shell.nix` - defines base shell environment
2. `symlinks.nix` - creates directory structure

#### Must Load Before Dependent Modules:
1. `keepassxc.nix` before `rclone-gdrive.nix`
2. `npm-*.nix` (auto-generated) before `npm-tools.nix`

**Current Import Order (home.nix:38-80):**
```nix
imports = [
  ./shell.nix              # 1. Shell base (EARLY)
  ./zellij.nix             # 2. Terminal tools
  # ... other modules ...
  ./keepassxc.nix          # BEFORE rclone
  ./rclone-gdrive.nix      # Depends on KeePassXC
  # ... remaining modules ...
];
```

**Recommendation:**
- Preserve relative order when migrating to module directories
- Use numbered imports or explicit ordering if needed

---

### 5. Auto-Generated npm Files
**Risk Level:** 🔴 HIGH
**Impact:** Breaking npm package builds if moved

**Critical Files (MUST STAY IN ROOT):**
- `npm-default.nix` (node2nix generated)
- `npm-node-env.nix` (node2nix generated)
- `npm-node-packages.nix` (node2nix generated)

**Reason:**
- `npm-tools.nix` imports these with relative paths
- Moving them breaks `buildNodePackage` derivations
- node2nix expects specific file structure

**Verification:**
```bash
grep -n "import.*npm-" home-manager/npm-tools.nix
```

**Mitigation:**
- ❌ DO NOT MOVE npm-*.nix files
- ✅ Keep in root directory
- ✅ Document in MIGRATION_PLAN.md

---

### 6. Conflict Files Resolution
**Risk Level:** 🟡 MEDIUM
**Impact:** Service failures if wrong version chosen

**Affected Files:**
- `critical-gui-services.nix` (2 conflicts)
- `systemd-monitor.nix` (1 conflict)

**Before Refactoring:**
1. Examine conflict markers in files
2. Determine correct version (likely most recent)
3. Test services after resolution
4. Delete `.remote-conflict*` files

**Resolution Strategy:**
```bash
# 1. Examine conflicts
diff critical-gui-services.nix critical-gui-services.nix..remote-conflict1

# 2. Manually resolve (keep newer or merged version)
# 3. Test
home-manager switch -b backup

# 4. Clean up
rm *.remote-conflict*
```

---

### 7. Module Default.nix Importers
**Risk Level:** 🟢 LOW
**Impact:** Easy to implement

**Requirement:**
Each module directory needs `default.nix` to import sub-modules.

**Example Structure:**
```nix
# modules/services/default.nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./keepassxc.nix
    ./dropbox.nix
    ./critical-gui-services.nix
    ./productivity-tools-services.nix
    ./sync          # Directory import
    ./monitoring    # Directory import
  ];
}

# modules/services/sync/default.nix
{ ... }: {
  imports = [
    ./rclone-gdrive.nix
    ./rclone-maintenance.nix
    ./syncthing-myspaces.nix
  ];
}
```

**Implementation:**
- Create `default.nix` for each module directory
- Test imports incrementally
- Verify no circular dependencies

---

## Module Dependency Map

### Critical Dependencies

```
home.nix (ROOT)
  ├── shell.nix (BASE - must load early)
  ├── symlinks.nix (EARLY - creates directories)
  │
  ├── modules/services/
  │   ├── keepassxc.nix (REQUIRED BY secrets)
  │   ├── sync/
  │   │   ├── rclone-gdrive.nix (DEPENDS ON keepassxc)
  │   │   └── syncthing-myspaces.nix
  │   └── monitoring/
  │       └── systemd-monitor.nix
  │
  ├── modules/dev/npm/
  │   └── npm-tools.nix (DEPENDS ON npm-*.nix in root)
  │
  ├── modules/system/
  │   ├── oom-protected-wrappers.nix (REQUIRED BY browsers)
  │   └── resource-control.nix
  │
  └── modules/mcp-servers/ (SELF-CONTAINED)
      └── default.nix → all MCP modules
```

### Independent Modules (No Dependencies)
- `modules/cli/` - atuin, navi
- `modules/terminal/` - zellij, zjstatus
- `modules/apps/` - browsers, editors, terminals
- `modules/desktop/` - autostart
- `modules/ai/` - gemini-cli, llm-core/*
- `modules/dotfiles/` - chezmoi, chezmoi-modify-manager
- `modules/automation/` - ansible-collections, gdrive-local-backup-job

---

## Breaking Changes Analysis

### ❌ Will Break (High Risk)
1. **Moving npm-*.nix files** - FORBIDDEN
2. **Changing overlay parameterization** - Must preserve hardware profile passing
3. **Reordering keepassxc.nix after rclone-gdrive.nix** - Secret loading fails

### ⚠️ Might Break (Medium Risk)
1. **Changing systemd service names** - Timers might fail to trigger
2. **Moving resource-control.nix incorrectly** - OOM protection fails
3. **Incorrect conflict resolution** - Services fail to start

### ✅ Safe Changes (Low Risk)
1. **Moving GUI apps to modules/apps/** - No dependencies
2. **Moving CLI tools to modules/cli/** - No dependencies
3. **Creating module default.nix importers** - Standard Nix pattern
4. **Grouping sync services** - No breaking changes

---

## Build-Time vs Runtime Changes

### Build-Time (Requires `home-manager switch`)
- Moving .nix files to modules/
- Creating default.nix importers
- Deleting deprecated files
- Updating home.nix imports

### Runtime-Only (No Rebuild Needed)
- Resolving conflict files
- Deleting .remote-conflict* files
- Git operations

**Note:** ALL refactoring changes are build-time - require `home-manager switch`

---

## Rollback Strategy

### Level 1: Home-Manager Generations
```bash
# List generations
home-manager generations

# Rollback to previous
home-manager switch --rollback

# Rollback to specific generation
/nix/store/XXX-home-manager-generation/activate
```

### Level 2: Git Revert
```bash
# Create backup branch before refactoring
cd ~/home-manager-workspace/my-modular-workspace/home-manager
git checkout -b backup-before-refactoring

# After refactoring, if issues:
git checkout main
git reset --hard backup-before-refactoring
home-manager switch --flake .#mitsio@shoshin
```

### Level 3: Flake Lock Pinning
```bash
# Pin current working flake.lock
cp flake.lock flake.lock.backup

# If issues after update:
cp flake.lock.backup flake.lock
home-manager switch --flake .#mitsio@shoshin
```

### Emergency Rollback Procedure
1. `home-manager switch --rollback` (fastest)
2. If fails: `git reset --hard <last-good-commit>`
3. If fails: Restore from `flake.lock.backup`
4. If all fails: Use system backup

---

## Migration Testing Strategy

### Pre-Migration Tests
```bash
# 1. Current config builds successfully
home-manager build --flake .#mitsio@shoshin

# 2. Hardware profiles work
nix eval .#homeConfigurations."mitsio@shoshin".config.programs.firefox.package.meta

# 3. Services are active
systemctl --user list-units --type=service | grep -E "keepassxc|rclone|syncthing"
```

### Incremental Migration Tests
**After Each Module Category:**
```bash
# 1. Build (don't activate yet)
home-manager build --flake .#mitsio@shoshin

# 2. Check for errors
echo $?  # Should be 0

# 3. Dry-run activation
home-manager switch --flake .#mitsio@shoshin --dry-run

# 4. Activate with backup
home-manager switch --flake .#mitsio@shoshin -b backup

# 5. Verify services
systemctl --user status keepassxc rclone-gdrive-sync
```

### Post-Migration Validation
```bash
# 1. All services running
systemctl --user list-units --failed

# 2. MCP servers available
ls -la ~/.local-mcp-servers/

# 3. Secrets loaded
systemctl --user show-environment | grep RCLONE_CONFIG_PASS

# 4. Hardware profiles applied
nix eval .#homeConfigurations."mitsio@shoshin".config.programs.firefox.package

# 5. Git status clean
git status
```

---

## Technical Recommendations

### 1. Pre-Refactoring Checklist
- [ ] Resolve all conflict files
- [ ] Delete deprecated files (local-mcp-servers.nix, chezmoi-llm-integration.nix, claude-code.nix)
- [ ] Verify plasma-full.nix is unused, then delete
- [ ] Create git backup branch
- [ ] Document current systemd service states

### 2. Migration Order (Safest to Riskiest)
1. **Phase 1:** Independent modules (cli, terminal, apps, desktop, ai, dotfiles, automation)
2. **Phase 2:** Low-risk services (productivity-tools, monitoring)
3. **Phase 3:** Sync services (keep order: keepassxc before rclone)
4. **Phase 4:** System modules (oom-wrappers, symlinks, toolkit)
5. **Phase 5:** Dev tools (keep npm-* in root!)
6. **Phase 6:** Final validation

### 3. Safety Measures
- Use `home-manager switch -b backup` for EVERY migration step
- Test services after each phase
- Keep home.nix imports in logical order
- Document any unexpected issues

### 4. Risk Mitigation
- **npm files:** Create symlinks if needed (AVOID moving)
- **Systemd services:** Verify `After=` directives preserved
- **Hardware profiles:** Test overlays separately
- **Secrets:** Test secret loading before rclone services

---

## Technical Constraints

### Must Not Change:
1. npm-*.nix file locations (MUST stay in root)
2. Hardware profile parameter passing to overlays
3. Systemd service dependency order
4. MCP servers/ directory structure (already optimal)

### Can Safely Change:
1. Module organization (as long as imports update)
2. Directory structure for independent modules
3. Addition of default.nix importers

### Recommended Changes:
1. Group related services (sync/, monitoring/)
2. Create semantic module directories
3. Add default.nix for each module category

---

## Conclusion

**Migration Feasibility:** ✅ SAFE with proper planning

**Critical Success Factors:**
1. Keep npm-*.nix in root
2. Preserve systemd service order
3. Test incrementally
4. Maintain rollback capability

**Estimated Migration Time:**
- Pre-work (conflicts, deprecation): 1 hour
- Module structure creation: 30 min
- File migration: 2-3 hours (incremental)
- Testing & validation: 1 hour
- **Total: 4.5-5.5 hours**

**Confidence Level:** 0.92 (Band C - HIGH)

**Recommendation:** ✅ **PROCEED** with Planner role to create detailed migration plan

---

**Technical Engineer Sign-off:** ✅ APPROVED FOR PLANNING
**Date:** 2025-12-20 22:11 EET
**Next:** Planner Role - Create detailed refactoring plan with phases
