# Plasma Desktop Dotfiles Migration - Session Context

**Created:** 2025-12-02
**Session:** Plasma Desktop Dotfiles Migration to Chezmoi (Multi-Phase)
**Status:** Phase 0 - Documentation Consolidation
**Goal:** Create comprehensive map and migration plan for moving KDE Plasma configs to chezmoi

---

## Session Overview

### Purpose

This session aims to:
1. **Map** all existing KDE Plasma configuration files and their current management status
2. **Document** current plasma-manager setup in home-manager
3. **Research** best practices for managing KDE Plasma configs with chezmoi
4. **Plan** a comprehensive, well-thought-out migration strategy

### Context

- **Current OS:** NixOS (shoshin desktop)
- **Future OS:** Fedora Atomic (migration planned in weeks/months)
- **Current Plasma Management:** plasma-manager (Nix-based, via home-manager)
- **Target Management:** chezmoi (cross-platform dotfile manager)
- **Keep plasma-manager:** Yes, for now (hybrid approach during transition)

### Why This Migration?

1. **Prepare for Fedora Migration**
   - plasma-manager is Nix-specific and won't work on Fedora
   - Need cross-platform solution for plasma configs
   - chezmoi works on NixOS, Fedora, and other distros

2. **Separate Concerns**
   - Nix/home-manager: package management, systemd services, Nix-specific integrations
   - chezmoi: application configs, dotfiles, cross-platform settings

3. **Future-Proof Configuration**
   - Configs will survive OS migration
   - Platform-agnostic dotfiles
   - Better portability

---

## Current State Analysis

### Existing Plasma Documentation

#### Consolidated Documentation (2025-11-29)

1. **docs/tools/plasma-manager.md** (9,915 bytes)
   - Merged from 6 source files on 2025-11-29
   - Sources: PLASMA_README, PLASMA_MANAGER_GUIDE, PLASMA_QUICK_REFERENCE, PLASMA_RC2NIX_GUIDE, PLASMA_TROUBLESHOOTING, PLASMA_CONFIG_COMPARISON
   - **Status:** ✅ Complete, up-to-date
   - **Content:** Installation, configuration, rc2nix usage, troubleshooting, best practices

2. **docs/tools/chrome-plasma.md** (1,829 bytes)
   - Chrome/Chromium integration with KDE Plasma
   - **Status:** ✅ Complete
   - **Content:** Media controls, KDE Connect integration, download notifications

#### Additional Documentation

3. **docs/chezmoi/** (Directory)
   - Complete chezmoi migration guides (01-07)
   - DOTFILES_INVENTORY.md - Comprehensive dotfiles inventory (created 2025-11-18)
   - README.md - Overview and quick start
   - **Status:** ✅ Comprehensive

4. **docs/adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md**
   - Decision framework for what goes in chezmoi vs home-manager
   - **Status:** ✅ Accepted (2025-11-29)

### Current Plasma Configuration in Home-Manager

#### 1. home-manager/plasma.nix (273 lines)
**Current Config Includes:**
- Workspace settings (4 virtual desktops, 2 rows)
- Desktop effects (blur, dim inactive, wobbly windows)
- Panel configuration (bottom panel, 44px height)
- Panel widgets:
  - Kickoff launcher
  - Virtual desktop pager
  - Icon tasks (task manager)
  - System tray
  - Digital clock
  - Show desktop button
- Input devices (keyboard layouts: US, Greek; Alt+Shift toggle)
- Mouse settings (no acceleration, flat profile)
- Keyboard shortcuts (volume, layout switching, virtual desktops)
- Appearance (Breeze Dark theme, colorScheme, icons, cursor)
- Fonts (Noto Sans, Hack)
- Power management (AC settings, display dimming)
- Dolphin file manager settings
- Desktop wallpaper settings
- KRunner configuration

#### 2. home-manager/plasma-full.nix (404 lines)
**Extended Config Template Includes:**
- All features from plasma.nix
- Additional desktop effects (slide desktops, morphing popups, minimize animation)
- Window management settings (title bar double-click, window snapping)
- Activities configuration (placeholder)
- Optional top panel for global menu (commented out)
- Window decorations (Breeze library)
- Splash screen settings
- Touchpad settings (placeholder)
- Battery power profile (placeholder)
- Lid close action
- Window rules (placeholder with example)
- Additional font settings (small, toolbar, menu, windowTitle)
- KRunner plugins configuration
- Notifications settings (Do Not Disturb, low battery)
- Desktop containment settings
- Folder view settings

### Discovered Plasma Config Files in ~/.config/

**Found 13 plasma-related config files:**

| File | Purpose | Size |
|------|---------|------|
| `plasmarc` | Plasma shell settings | Unknown |
| `plasmashellrc` | Panel configuration | Unknown |
| `kwinrc` | Window manager (KWin) | Unknown |
| `kdeglobals` | Global KDE settings | Unknown |
| `plasma-org.kde.plasma.desktop-appletsrc` | Desktop widgets | Unknown |
| `plasma_workspace.notifyrc` | Workspace notifications | Unknown |
| `plasmanotifyrc` | Notifications | Unknown |
| `plasma-localerc` | Locale settings | Unknown |
| `plasma_calendar_holiday_regions` | Calendar | Unknown |
| `xdg-desktop-portal-kderc` | Desktop portal | Unknown |
| `kwinoutputconfig.json` | Display config | Unknown |
| `kded5rc` | KDE daemon (Plasma 5) | Unknown |
| `kded6rc` | KDE daemon (Plasma 6) | Unknown |

**Status:** Need detailed investigation in Phase 1

### Dotfiles Inventory Analysis

From **docs/chezmoi/DOTFILES_INVENTORY.md** (created 2025-11-18):

**KDE Plasma Configs Identified (Lines 88-135):**

#### Core Plasma Configs
- `kdeglobals` - ⚠️ Partial migrate (theme, colors, fonts)
- `kglobalshortcutsrc` - ✅ Migrate (keyboard shortcuts)
- `kwinrc` - ✅ Migrate (window behavior)
- `kwinoutputconfig.json` - ⚠️ Maybe (hardware-specific)
- `plasmarc` - ✅ Migrate (desktop behavior)
- `plasmashellrc` - ✅ Migrate (panel configuration)
- `plasma-org.kde.plasma.desktop-appletsrc` - ✅ Migrate (widgets/applets)
- `powerdevilrc` - ✅ Migrate (power settings)
- `kscreenlockerrc` - ✅ Migrate (lock screen)
- `ksmserverrc` - ✅ Migrate (session settings)
- `krunnerrc` - ✅ Migrate (launcher config)

#### Plasma Components
- `plasma-localerc` - ✅ Migrate (language/region)
- `plasmanotifyrc` - ✅ Migrate (notification settings)
- `plasma_calendar_holiday_regions` - ✅ Migrate (holiday config)
- `ksplashrc` - ✅ Migrate (boot splash)
- `kxkbrc` - ✅ Migrate (keyboard settings)

#### KDE Applications
- `dolphinrc` - ✅ Migrate (file manager)
- `gwenviewrc` - ✅ Migrate (image viewer)
- `okularrc`, `okularpartrc` - ✅ Migrate (PDF viewer)
- `spectaclerc` - ✅ Migrate (screenshot tool)
- `kwriterc` - ✅ Migrate (text editor)
- `konsolerc` - ✅ Migrate (terminal)
- `kate/`, `katerc`, `katevirc` - ✅ Migrate (text editor)

#### System Components
- `KDE/` - ⚠️ Partial (various KDE data)
- `kdedefaults/` - ⚠️ Maybe (system defaults)
- `kdeconnect/` - ✅ Migrate (phone integration)
- `kded5rc`, `kded6rc` - ⚠️ Maybe (system daemon)
- `kconf_updaterc` - ❌ Don't migrate (auto-generated)
- `autostart/` - ✅ Migrate (handled by home-manager ADR-007)

**Recommendation from Inventory:**
- ✅ Migrate: ~25 plasma-related configs
- ⚠️ Partial/Maybe: ~8 configs (need investigation)
- ❌ Don't migrate: ~2 configs (auto-generated)

---

## Phase 0: Documentation Consolidation - Findings

### What Was Already Consolidated

✅ **plasma-manager.md** - Already consolidated on 2025-11-29
- Merged 6 source files from `docs/commons/plasma-manager/`
- Original directory no longer exists
- Complete guide with installation, configuration, rc2nix, troubleshooting

✅ **chrome-plasma.md** - Already consolidated on 2025-11-29
- Merged from `docs/commons/integrations/`
- Complete Chrome/Plasma integration guide

### What Needs Organization

📋 **Create dedicated plasma migration directory structure:**
- `docs/plasma/` - Created ✅
- `docs/plasma/SESSION_CONTEXT.md` - This file ✅
- `docs/plasma/LOCAL_INVESTIGATION.md` - To be created in Phase 1
- `docs/plasma/RESEARCH_FINDINGS.md` - To be created in Phase 2
- `docs/plasma/MIGRATION_PLAN.md` - To be created in Phase 3

### Documentation Gaps Identified

1. **Detailed file-by-file analysis** of ~/.config/ plasma files
   - Need sizes, modification dates, content analysis
   - Categorization by function (appearance, behavior, shortcuts, etc.)
   - Identification of auto-generated vs user-modified files

2. **plasma-manager coverage analysis**
   - What plasma configs are handled by plasma-manager?
   - What configs are NOT covered by plasma-manager's high-level API?
   - Which files require `programs.plasma.files` low-level config?

3. **Migration strategy for each config type**
   - Which configs can be templated in chezmoi?
   - Which configs contain machine-specific data?
   - Which configs are volatile vs stable?

4. **Cross-platform considerations**
   - How will plasma configs work on Fedora vs NixOS?
   - Are there KDE Plasma version differences to account for?
   - What about KDE Plasma 5 vs 6 compatibility?

---

## Key Questions for Phase 1 (Local Investigation)

1. **File Analysis**
   - What is the actual size and content of each plasma config file?
   - Which files are symlinks vs real files?
   - Which files are managed by home-manager/plasma-manager?
   - Which files are manually created/edited?

2. **Categorization**
   - Appearance & themes
   - Behavior & settings
   - Keyboard shortcuts
   - Window management (KWin)
   - Widgets & plasmoids
   - Session management
   - Auto-generated vs user-modified

3. **Management Status**
   - Currently in plasma-manager (home-manager/plasma.nix)
   - Currently in plasma-manager (home-manager/plasma-full.nix)
   - Not managed by plasma-manager (standalone files)
   - Auto-generated and should be ignored

---

## Key Questions for Phase 2 (Web Research)

### Topic 1: Plasma Dotfiles Structure
- What is the official KDE Plasma 6 config file structure?
- Which files are stable vs volatile?
- Which files should be version controlled?
- What's the relationship between different plasma files?

### Topic 2: plasma-manager Integration Gaps
- What settings does plasma-manager handle via high-level API?
- What settings require `programs.plasma.files` (low-level)?
- What plasma configs are NOT supported by plasma-manager at all?
- How does plasma-manager apply configs? (Does it write to ~/.config/ or Nix store?)

### Topic 3: chezmoi + KDE Best Practices
- How do others manage KDE Plasma configs with chezmoi?
- What are recommended .chezmoiignore patterns for KDE?
- Are there community examples of plasma + chezmoi?
- Common pitfalls and solutions?

---

## Key Questions for Phase 3 (Migration Planning)

### Strategic Questions
1. **Hybrid Approach:** Keep plasma-manager for NixOS, add chezmoi for Fedora compatibility?
2. **Full Migration:** Move everything from plasma-manager to chezmoi?
3. **Selective Migration:** Migrate only user-specific configs, keep system-level in plasma-manager?

### Technical Questions
1. **Templates:** Which configs need chezmoi templates for machine-specific values?
2. **Secrets:** Do any plasma configs contain secrets? (unlikely, but check)
3. **Rollback:** How to safely rollback if migration breaks desktop?
4. **Testing:** How to test plasma configs before applying? (VM? Separate user?)

### Phasing Questions
1. **Low-Risk First:** Migrate non-critical configs (themes, appearance) first?
2. **High-Impact Later:** Migrate critical configs (shortcuts, panel) after testing?
3. **Per-Category:** Migrate by category (appearance → behavior → shortcuts → etc.)?

---

## Success Criteria

### Phase 0 (Documentation Consolidation) ✅
- [x] Read all existing documentation
- [x] Identify documentation gaps
- [x] Create docs/plasma/ directory structure
- [x] Create SESSION_CONTEXT.md

### Phase 1 (Local Investigation)
- [ ] Complete inventory of all plasma config files with sizes/dates
- [ ] Categorize files by function
- [ ] Identify which files are managed by plasma-manager
- [ ] Document findings in LOCAL_INVESTIGATION.md
- [ ] Flag files that might contain secrets or machine-specific data

### Phase 2 (Web Research)
- [ ] Achieve topic_research_confidence ≥ 0.85 for each research topic
- [ ] Document plasma dotfiles structure (official KDE docs)
- [ ] Document plasma-manager coverage and gaps
- [ ] Document chezmoi + KDE best practices
- [ ] Create RESEARCH_FINDINGS.md with sources

### Phase 3 (Migration Planning)
- [ ] Use Sequential Thinking MCP for planning
- [ ] Design 3-5 implementation phases (1 phase = 1 future session)
- [ ] Each phase independently testable with rollback strategy
- [ ] Order phases by risk: low-risk → high-risk
- [ ] Create MIGRATION_PLAN.md with detailed steps
- [ ] Apply ultrathink for validation and double-checking
- [ ] Get user approval before execution

---

## Timeline & Effort Estimates

### Phase 0: Documentation Consolidation ✅
- **Time:** ~1 hour
- **Status:** Complete

### Phase 1: Local Investigation
- **Time:** 2-3 hours
- **Status:** Pending
- **Next Session:** Can be started immediately

### Phase 2: Web Research (Technical Researcher Role)
- **Time:** 3-4 hours
- **Status:** Pending
- **Prerequisites:** Phase 1 complete, user approval

### Phase 3: Migration Planning (Planner Role + Ultrathink)
- **Time:** 2-3 hours
- **Status:** Pending
- **Prerequisites:** Phase 0, 1, 2 complete, user approval

### Phase 4+: Migration Execution (Future Sessions)
- **Time:** TBD based on migration plan
- **Status:** Not started (depends on Phase 3 completion)

**Total Estimated Time (Phases 0-3):** 8-11 hours across 3-5 sessions

---

## References

### Internal Documentation
- `docs/tools/plasma-manager.md` - plasma-manager guide
- `docs/tools/chrome-plasma.md` - Chrome integration
- `docs/chezmoi/` - Complete chezmoi guides (01-07)
- `docs/chezmoi/DOTFILES_INVENTORY.md` - Comprehensive dotfiles inventory
- `docs/chezmoi/README.md` - Chezmoi migration overview
- `docs/adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md` - Migration criteria
- `home-manager/plasma.nix` - Current plasma config (273 lines)
- `home-manager/plasma-full.nix` - Full plasma config template (404 lines)

### External Resources (To be added in Phase 2)
- Official KDE Plasma documentation
- plasma-manager GitHub repository
- chezmoi official documentation
- Community examples and best practices

---

## Notes & Observations

### Strengths of Current Setup
✅ **Well-documented** - Comprehensive plasma-manager guide already exists
✅ **Organized** - Home-manager configs are well-structured
✅ **Working** - Current plasma setup is functional
✅ **Version-controlled** - Configs are in Git

### Challenges Ahead
⚠️ **Complexity** - Plasma has many interconnected config files
⚠️ **NixOS → Fedora** - Need to ensure configs work on both platforms
⚠️ **plasma-manager Dependency** - Currently relies on Nix-specific tool
⚠️ **Testing** - Need safe way to test configs without breaking desktop

### Opportunities
✨ **Future-Proof** - Configs will work on any distro with chezmoi
✨ **Portable** - Can share configs with non-NixOS users
✨ **Learning** - Deep understanding of KDE Plasma config structure
✨ **Clean Separation** - Better separation between Nix and dotfiles

---

**Last Updated:** 2025-12-02T19:01:04+02:00 (Europe/Athens)
**Next Phase:** Phase 1 - Local Investigation
**Created by:** Session Initialization & Phase 0 Documentation Consolidation
