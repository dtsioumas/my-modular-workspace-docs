# Plasma Desktop Migration Plan - Chezmoi Integration

**Created:** 2025-12-04
**Status:** ⏸️ Phase 2 COMPLETE - Verification Period (1-2 days before Phase 3)
**Planner Confidence:** `c_plan = 0.84` (Band C - HIGH)
**Approach:** Gradual, hybrid migration with rollback capability

---

## Executive Summary

This plan details the migration of KDE Plasma configuration files from plasma-manager (Nix-based) to chezmoi (cross-platform), preparing for future Fedora migration while maintaining system stability.

### Strategy

**Hybrid Approach:**
- Keep plasma-manager for **high-level structure** (panels, themes, effects)
- Use chezmoi for **user-specific preferences** (shortcuts, application configs)
- Gradually shift configs from plasma-manager to chezmoi over 4 phases
- Maintain rollback capability at each phase

### Timeline

**Estimated:** 4-6 weeks (1-2 weeks per phase)
- Phase 1: Tool setup & preparation (1 week)
- Phase 2: Application configs (1 week)
- Phase 3: Core Plasma configs (2 weeks)
- Phase 4: Final migration & cleanup (1 week)

---

## Migration Phases

### Phase 1: Tool Setup & Preparation (Week 1) ✅ COMPLETE

**Goal:** Install chezmoi_modify_manager, configure tooling, establish workflows

**Confidence:** `c_phase1 = 0.88` (Band C)
**Status:** ✅ COMPLETED 2025-12-05
**Time Spent:** ~2.5 hours

#### 1.1 Install chezmoi_modify_manager ✅ COMPLETE

**Tool:** [chezmoi_modify_manager](https://github.com/VorpalBlade/chezmoi_modify_manager)
**Chosen:** Nix declarative package (buildRustPackage)
**Version:** 3.5.3
**File:** `home-manager/chezmoi-modify-manager.nix`

**Installation Options:**

**Option A: Cargo Install (Recommended)** ❌ Not Used
```bash
cargo install --git https://github.com/VorpalBlade/chezmoi_modify_manager
```

**Option B: Build from Source**
```bash
git clone https://github.com/VorpalBlade/chezmoi_modify_manager
cd chezmoi_modify_manager
cargo build --release
cp target/release/chezmoi_modify_manager ~/.local/bin/
```

**Option C: Nix Package (Future - if available)**
```nix
# home-manager/chezmoi.nix
home.packages = with pkgs; [
  chezmoi_modify_manager  # When available in nixpkgs
];
```

**Verification:**
```bash
chezmoi_modify_manager --version
```

#### 1.2 Update .chezmoiignore

**File:** `dotfiles/.chezmoiignore`

**Add:**
```
# Plasma config source files (used by chezmoi_modify_manager)
**/*.src.ini

# Volatile Plasma configs (don't track)
.config/kwinoutputconfig.json
.config/kded5rc
.config/kded6rc
.config/*cache*
.config/plasma-org.kde.plasma.desktop-appletsrc  # Too volatile for now
```

**Rationale:**
- `.src.ini` files are source state for modify scripts
- `kwinoutputconfig.json` is hardware-specific (monitor setup)
- `kded*rc` are system daemon configs
- Cache files change constantly
- Desktop applets config changes frequently with widget positions

#### 1.3 Create Documentation Structure

```bash
cd ~/MyHome/MySpaces/my-modular-workspace/docs/dotfiles/plasma/
touch phase1-journal.md phase2-journal.md phase3-journal.md phase4-journal.md
```

**Purpose:** Document decisions, issues, and learnings at each phase

#### 1.4 Backup Current State

```bash
# Backup all current Plasma configs
mkdir -p ~/MyHome/Archives/plasma-configs-backup-$(date +%Y%m%d)
cp -r ~/.config/*rc ~/.config/plasma* ~/MyHome/Archives/plasma-configs-backup-$(date +%Y%m%d)/
```

**Success Criteria Phase 1:** ✅ ALL COMPLETE
- ✅ chezmoi_modify_manager installed and working (v3.5.3, Nix package)
- ✅ .chezmoiignore updated with patterns (commit 069af11)
- ✅ Documentation structure created (migration-plan.md, default-applications.md)
- ✅ Full backup of current Plasma configs (55 files, ~/.MyHome/Archives/plasma-configs-backup-20251205/)
- ✅ Test chezmoi_modify_manager verified working

**Completion Date:** 2025-12-05
**Git Commits:**
- home-manager: `ee3f7dd` - feat: Add chezmoi_modify_manager as declarative Nix package
- dotfiles: `069af11` - feat: Update .chezmoiignore for Plasma config migration

---

### Phase 2: Application Configs Migration (Week 2) ✅ COMPLETE

**Goal:** Migrate KDE application configs (Dolphin, Konsole, Kate, Okular) to chezmoi

**Confidence:** `c_phase2 = 0.85` (Band C)
**Status:** ✅ COMPLETED 2025-12-06
**Time Spent:** ~45 minutes

**Rationale:** Start with application configs (not core Plasma) because:
- Lower risk - won't break desktop if something goes wrong
- Good learning experience with chezmoi_modify_manager
- Applications are more self-contained

#### 2.1 Migrate Dolphin Config

**Priority:** 🟡 MEDIUM
**File:** `~/.config/dolphinrc` (738 bytes)
**plasma-manager:** Currently managed via `programs.dolphin`

**Steps:**

1. **Read current config:**
```bash
cat ~/.config/dolphinrc
```

2. **Identify volatile vs stable sections:**
   - Stable: View settings, toolbar config, general preferences
   - Volatile: Recent folders, window geometry

3. **Create source file:**
```bash
cd ~/.local/share/chezmoi
# Copy current config
cp ~/.config/dolphinrc private_dolphinrc.src.ini
```

4. **Create modify script:**

**File:** `~/.local/share/chezmoi/modify_private_dolphinrc`
```bash
#!/bin/bash
# Filter Dolphin config with chezmoi_modify_manager
chezmoi_modify_manager -t dolphinrc ./private_dolphinrc.src.ini "$1"
```

**Make executable:**
```bash
chmod +x ~/.local/share/chezmoi/modify_private_dolphinrc
```

5. **Create config file for chezmoi_modify_manager:**

**File:** `~/.config/chezmoi_modify_manager/dolphinrc.kdl`
```kdl
// Dolphin file manager config filter
filter {
  # Ignore volatile sections
  ignore-section "^(KFileDialog Settings|MainWindow|PlacesPanel|VersionControl)$"

  # Keep stable preferences
  keep-section "^(General|IconsMode|DetailsMode|PreviewSettings)$"
}
```

6. **Test:**
```bash
chezmoi apply --dry-run --verbose ~/.config/dolphinrc
```

7. **Apply:**
```bash
chezmoi add ~/.config/dolphinrc
chezmoi apply ~/.config/dolphinrc
```

8. **Remove from plasma-manager:**

**File:** `home-manager/plasma.nix`
```nix
# Comment out or remove Dolphin config
# programs.dolphin = { ... };
```

9. **Test dolphin still works:**
```bash
dolphin
# Verify settings are correct
```

#### 2.2 Migrate Konsole Config

**Priority:** 🟡 MEDIUM
**File:** `~/.config/konsolerc` (176 bytes)

**Repeat steps 2.1.1 to 2.1.9 for Konsole**

**Config filter:**
```kdl
// Konsole terminal config filter
filter {
  # Ignore window geometry
  ignore-section "^(MainWindow|UiSettings)$"

  # Keep profile and behavior settings
  keep-section "^(Desktop Entry|TabBar)$"
}
```

#### 2.3 Migrate Kate Config

**Priority:** 🟡 MEDIUM
**File:** `~/.config/katerc` (425 bytes)

**Config filter:**
```kdl
// Kate editor config filter
filter {
  # Ignore recent files and session data
  ignore-section "^(KFileDialog Settings|MainWindow|Recent Files|kate-mdi-view|KTextEditor::Search)$"

  # Keep editor preferences
  keep-section "^(General|KTextEditor Editor|KTextEditor View|KTextEditor Document)$"
}
```

#### 2.4 Migrate Okular Config

**Priority:** 🟡 MEDIUM
**File:** `~/.config/okularrc` (1.3K)

**Config filter:**
```kdl
// Okular PDF viewer config filter
filter {
  # Ignore window states and recent files
  ignore-section "^(MainWindow|Recent Files|Reviews)$"

  # Keep viewer preferences
  keep-section "^(General|Core Presentation|Core Print|DlgAccessibility|DlgGeneral|DlgPerformance)$"
}
```

**Success Criteria Phase 2:** ✅ ALL MET
- ✅ All 4 application configs migrated to chezmoi
- ✅ chezmoi_modify_manager filtering working correctly
- ✅ Applications work normally after migration
- ✅ No volatile data (window positions, recent files) in chezmoi repo
- ✅ Dolphin config removed from plasma-manager
- ✅ All commits successful and pushed

**Completion Date:** 2025-12-06
**Git Commits:**
- dotfiles: `5fced3b` (Dolphin), `805933f` (Konsole), `8854fe6` (Kate), `60d7318` (Okular)
- home-manager: `aaea035` (Remove Dolphin from plasma-manager)

**Detailed Report:** See `docs/dotfiles/plasma/phase2-completion.md`

**⏸️ VERIFICATION PERIOD (1-2 days)**
- **Decision:** Wait before Phase 3 to verify Phase 2 apps work correctly
- **Start Date:** 2025-12-06
- **Earliest Phase 3 Start:** 2025-12-08 or later
- **What to verify:**
  - ✅ Dolphin works normally (file manager operations, settings persist)
  - ✅ Konsole works normally (terminal, tabs, color scheme)
  - ✅ Kate works normally (editor, file tree, settings)
  - ✅ Okular works normally (PDF viewing, sidebar settings)
  - ✅ No unexpected config resets or issues
  - ✅ chezmoi apply runs without errors

**Rationale:** Phase 3 involves **HIGH RISK** core desktop configs (shortcuts, window manager). Better to ensure Phase 2 is solid first.

---

### Phase 3: Core Plasma Configs Migration (Week 3-4) ⏸️ WAITING

**Goal:** Migrate core Plasma desktop configs while keeping plasma-manager as fallback

**Confidence:** `c_phase3 = 0.79` (Band C, but closer to Band B due to complexity)

**Rationale:** This is the most critical phase - core desktop configs that affect system stability

**Strategy:** Migrate one config at a time, test thoroughly before proceeding

#### 3.1 Migrate Keyboard Layouts (Low Risk)

**Priority:** 🟡 MEDIUM
**File:** `~/.config/kxkbrc` (114 bytes)
**plasma-manager:** `programs.plasma.input.keyboard`

**Steps:**

1. Create source file: `private_kxkbrc.src.ini`
2. Create modify script: `modify_private_kxkbrc`
3. Config filter (keep all - small file):
```kdl
filter {
  # Keep all layout settings
  keep-all
}
```
4. Test keyboard layout switching still works
5. Remove from plasma-manager

**Test Criteria:**
- ✅ Alt+Shift switches between US and Greek layouts
- ✅ Layout indicator shows in system tray

#### 3.2 Migrate Plasma Theme Settings (Low Risk)

**Priority:** 🔴 HIGH
**File:** `~/.config/plasmarc` (140 bytes)
**plasma-manager:** `programs.plasma.workspace` (theme, wallpaper)

**Config filter:**
```kdl
filter {
  # Ignore volatile wallpaper path (user-specific)
  ignore-key "^Wallpapers/usersWallpapers$"

  # Keep theme settings
  keep-section "^(Theme|PlasmaToolTips)$"
}
```

**Test Criteria:**
- ✅ Breeze Dark theme active
- ✅ Tooltips work correctly
- ✅ Can still change wallpaper via GUI

#### 3.3 Migrate Global Shortcuts (Medium Risk)

**Priority:** 🔴 HIGH
**File:** `~/.config/kglobalshortcutsrc` (16KB - LARGEST)
**plasma-manager:** `programs.plasma.shortcuts`

**⚠️ CAUTION:** This is the most critical config file

**Config filter:**
```kdl
filter {
  # Ignore volatile shortcut states
  ignore-key "_k_friendly_name"

  # Keep all actual shortcuts
  keep-section "^(kwin|plasmashell|org.kde.*)$"

  # Ignore clipboard and temporary shortcuts
  ignore-section "^(klipper.desktop|KDE Keyboard Layout Switcher)$"
}
```

**Test Plan:**
1. Test Meta+1, Meta+2, Meta+3, Meta+4 (virtual desktop switching)
2. Test Alt+F4 (close window)
3. Test Meta+Enter (terminal launch if configured)
4. Test volume keys (if configured)
5. Test screenshot shortcuts

**Rollback:** Keep plasma-manager version active for 1 week

#### 3.4 Migrate Window Manager Settings (High Risk)

**Priority:** 🔴 HIGH
**File:** `~/.config/kwinrc` (1.3K)
**plasma-manager:** `programs.plasma` (various KWin settings)

**⚠️ HIGHEST RISK:** Window manager behavior affects entire desktop experience

**Config filter:**
```kdl
filter {
  # Ignore volatile activity UUIDs
  ignore-section "^(Activities)$"
  ignore-key ".*UUID.*"

  # Keep virtual desktop configuration
  keep-section "^(Desktops)$"

  # Keep window behavior
  keep-section "^(Windows|Compositing|Effect-*)$"

  # Ignore plugin states (managed by plasma-manager)
  ignore-section "^(Plugins|Script-*)$"
}
```

**Migration Strategy:**
1. Keep plasma-manager managing KWin **and** add to chezmoi
2. Run both in parallel for 1 week
3. Observe for conflicts
4. If stable, comment out plasma-manager's KWin config

**Test Criteria:**
- ✅ 4 virtual desktops present
- ✅ Window effects work (blur, wobbly windows)
- ✅ Window snapping works
- ✅ Alt+Tab works correctly
- ✅ No visual glitches

#### 3.5 Migrate Panel Configuration (Highest Risk - DEFER)

**Priority:** 🔴 HIGH (but DEFERRED to Phase 4)
**Files:**
- `plasmashellrc` (2.4K)
- `plasma-org.kde.plasma.desktop-appletsrc` (7.8K)

**Decision:** DEFER to Phase 4

**Rationale:**
- Panel config is extremely volatile (widget positions change)
- plasma-manager handles panels very well
- Risk vs benefit not favorable for Phase 3
- Better to migrate after other configs are stable

**Success Criteria Phase 3:**
- ✅ Keyboard layouts managed by chezmoi
- ✅ Plasma theme (plasmarc) managed by chezmoi
- ✅ Global shortcuts (kglobalshortcutsrc) managed by chezmoi
- ✅ KWin settings (kwinrc) managed by chezmoi
- ✅ All configs tested and working
- ✅ No regressions in desktop functionality
- ✅ Rollback procedures documented and tested

---

### Phase 4: Final Migration & Cleanup (Week 5-6)

**Goal:** Complete migration, optimize configs, prepare for Fedora

**Confidence:** `c_phase4 = 0.81` (Band C)

#### 4.1 Evaluate Panel Migration

**Decision Point:** Should we migrate panels to chezmoi?

**Options:**

**Option A: Keep plasma-manager for panels**
- ✅ Pros: Stable, well-tested, Nix declarative
- ❌ Cons: Won't work on Fedora

**Option B: Migrate to chezmoi**
- ✅ Pros: Cross-platform, prepares for Fedora
- ❌ Cons: High volatility, complex filtering needed

**Option C: Hybrid - Document panel setup**
- ✅ Pros: Manual reproducibility, flexibility
- ❌ Cons: Not automated

**Recommendation:** Choose Option B with extensive filtering

**Panel Config Filter (if migrating):**
```kdl
filter {
  # Ignore all volatile widget data
  ignore-section "^(PlasmaViews|Panel \\d+)$"

  # Only keep high-level panel structure
  keep-key "^(thickness|alignment|floating)$"

  # Document widget setup separately
}
```

#### 4.2 Create Fedora Migration Guide

**File:** `docs/dotfiles/plasma/fedora-migration.md`

**Contents:**
- How to install Plasma on Fedora
- How to apply chezmoi configs on Fedora
- What needs manual setup (panels if not migrated)
- Package equivalents (NixOS → Fedora)

#### 4.3 Optimize Chezmoi Config Filters

**Review all `.kdl` filter configs:**
- Remove unnecessary ignores
- Add comments explaining each rule
- Test on fresh install (VM)

#### 4.4 Clean Up plasma-manager Config

**File:** `home-manager/plasma.nix`

**Decision:** Keep or remove?

**Recommendation:** Keep minimal plasma-manager config for:
- System-level settings (if any)
- Fallback safety net
- Future NixOS users who might use your config

**Minimal plasma.nix:**
```nix
{ config, pkgs, ... }:
{
  programs.plasma = {
    enable = true;

    # ONLY system-level settings remain
    # All user configs now in chezmoi

    workspace = {
      # Maybe keep wallpaper setter?
    };
  };
}
```

#### 4.5 Test on Fresh NixOS Install (VM)

**Steps:**
1. Create NixOS VM with Plasma
2. Apply chezmoi configs
3. Verify all settings work
4. Document any manual steps needed

**Success Criteria Phase 4:**
- ✅ Decision made on panel migration
- ✅ Fedora migration guide created
- ✅ All config filters optimized
- ✅ plasma-manager cleaned up (minimal or removed)
- ✅ Tested on fresh NixOS install
- ✅ Full documentation complete

---

## Migration Tools & Commands

### Essential Commands

```bash
# Dry-run (see what would change)
chezmoi apply --dry-run --verbose

# Apply single file
chezmoi apply ~/.config/dolphinrc

# Apply all Plasma configs
chezmoi apply ~/.config/*rc

# Check diff
chezmoi diff ~/.config/kwinrc

# Edit config in chezmoi source
chezmoi edit ~/.config/kwinrc

# Re-add file (update source)
chezmoi add ~/.config/kwinrc

# Revert file to source state
chezmoi apply --force ~/.config/kwinrc
```

### Testing Workflow

**After each config migration:**

1. **Apply chezmoi:**
```bash
chezmoi apply --verbose
```

2. **Test functionality:**
   - Test the specific feature (shortcuts, themes, etc.)
   - Log out and log back in
   - Test for 15-30 minutes

3. **Check for issues:**
   - Look for error messages in `journalctl`
   - Check `~/.xsession-errors`

4. **Rollback if needed:**
```bash
# Restore backup
cp ~/MyHome/Archives/plasma-configs-backup-YYYYMMDD/kwinrc ~/.config/kwinrc

# OR reapply plasma-manager
home-manager switch --flake ~/.config/nixos#mitso@shoshin
```

---

## Rollback Procedures

### Per-File Rollback

**If a single config breaks:**

```bash
# Option 1: Restore from backup
cp ~/MyHome/Archives/plasma-configs-backup-YYYYMMDD/[config-file] ~/.config/

# Option 2: Regenerate with plasma-manager (if still configured)
home-manager switch

# Option 3: Reset to defaults
rm ~/.config/[config-file]
kquitapp6 plasmashell && kstart plasmashell
```

### Full Phase Rollback

**If entire phase fails:**

1. **Restore all configs from backup:**
```bash
cp -r ~/MyHome/Archives/plasma-configs-backup-YYYYMMDD/* ~/.config/
```

2. **Revert plasma-manager changes:**
```bash
git revert <commit-hash>  # in home-manager repo
home-manager switch
```

3. **Remove from chezmoi:**
```bash
chezmoi forget ~/.config/[failed-configs]
```

### Emergency Rollback (Desktop Unusable)

**From TTY (Ctrl+Alt+F2):**

```bash
# Stop plasma
systemctl --user stop plasma-plasmashell

# Restore configs
cp -r ~/MyHome/Archives/plasma-configs-backup-YYYYMMDD/* ~/.config/

# Restart plasma
systemctl --user start plasma-plasmashell

# Or reboot
reboot
```

---

## Success Criteria (Overall)

**Phase 1:**
- ✅ Tools installed and tested

**Phase 2:**
- ✅ 4 application configs migrated
- ✅ chezmoi_modify_manager filtering proven

**Phase 3:**
- ✅ Core Plasma configs (shortcuts, themes, KWin) migrated
- ✅ Desktop fully functional

**Phase 4:**
- ✅ Migration complete or strategy finalized
- ✅ Fedora preparation done
- ✅ VM tested successfully

**Final:**
- ✅ All HIGH priority configs in chezmoi
- ✅ plasma-manager minimal or removed
- ✅ Configs work on NixOS
- ✅ Ready for Fedora migration
- ✅ Full documentation and runbooks
- ✅ No loss of functionality

---

## Risk Assessment

| Phase | Risk Level | Mitigation |
|-------|------------|------------|
| Phase 1 | 🟢 LOW | Tool installation only |
| Phase 2 | 🟡 MEDIUM | Apps, not core desktop |
| Phase 3 | 🔴 HIGH | Core desktop configs, careful testing |
| Phase 4 | 🟡 MEDIUM | Refinement, low-risk changes |

**Highest Risk Items:**
1. `kwinrc` (window manager) - desktop breaks if wrong
2. `kglobalshortcutsrc` (shortcuts) - workflow breaks if wrong
3. `plasmashellrc` (panels) - visual/UX breaks if wrong

**Risk Mitigation:**
- Always have backups
- Test in VM first when possible
- Keep plasma-manager as fallback during Phase 3
- One config at a time, test thoroughly
- Don't rush - take breaks between phases

---

## Assumptions & Unknowns

### Assumptions

1. ✅ chezmoi_modify_manager is stable and works as documented
2. ✅ plasma-manager and chezmoi can coexist temporarily
3. ⚠️ User can dedicate 4-6 weeks to this migration (needs confirmation)
4. ⚠️ Fedora migration is weeks/months away (not urgent)
5. ✅ KDE Plasma 6 is stable on NixOS (currently true)

### Unknowns

1. ❓ Will chezmoi_modify_manager handle all edge cases in Plasma configs?
2. ❓ Are there hidden dependencies between configs we haven't discovered?
3. ❓ Will Fedora's Plasma packages have different config paths/formats?
4. ❓ Can panels truly be migrated without losing functionality?

**Resolution Strategy:**
- Unknowns 1-2: Discover during Phase 2-3, adapt plan as needed
- Unknown 3: Research during Phase 4, test on Fedora VM
- Unknown 4: Evaluate during Phase 4, make informed decision

---

## Next Steps (Immediate)

**Before Starting Phase 1:**

1. **Review this plan with user**
   - Confirm timeline is realistic
   - Discuss risk tolerance
   - Agree on when to start

2. **User preparation:**
   - Read all investigation docs (session-context, local-investigation, research-findings)
   - Understand chezmoi_modify_manager concept
   - Prepare for iterative testing

3. **Environment check:**
   - Ensure `cargo` is installed (for chezmoi_modify_manager)
   - Verify chezmoi is up-to-date
   - Check backup space available

4. **Schedule Phase 1 start:**
   - Pick a week where user has time for testing
   - Plan for ~2-3 hours setup time

---

**Plan Confidence:** `c_plan = 0.84` (Band C - HIGH)

**Planner Notes:**
- Plan is conservative and safety-focused (suitable for ADHD-friendly pacing)
- Phases are clearly scoped with success criteria
- Rollback procedures are comprehensive
- Risk assessment is explicit
- Unknowns are acknowledged and mitigation planned

**Created by:** Planner Role (Dimitris Tsioumas / Mitsio)
**Date:** 2025-12-04
**Status:** ✅ Ready for Review
**Next:** User approval to begin Phase 1
