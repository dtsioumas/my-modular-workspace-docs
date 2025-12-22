# Kitty Enhancements Research Summary

**Date:** 2025-12-22
**Researcher:** Claude Opus 4.5 (via Claude Code)
**Status:** Research Phase Complete

---

## Research Completed

### ✅ Obsidian Integration (100%)

**Key Findings:**
- **Obsidian URI Scheme** fully functional since v1.7.4 with append/prepend support
- **Advanced URI Plugin** (1k stars) provides extended functionality
- **Panel overlay NOT possible** due to Electron architecture
- **Best approach:** Hybrid workflow with file system access + terminal viewers

**Deliverables:**
- Comprehensive integration guide: `obsidian-kitty-integration-findings.md`
- Shell script examples for quick capture
- kitty configuration recommendations
- Home-manager integration examples

**Recommended Tools:**
- `glow` for markdown preview (21.9k stars)
- `bat` for syntax highlighting (56.3k stars)
- Advanced URI plugin for Obsidian

---

### ✅ Browser Integration Research (100%)

**Key Findings:**
- **Firefox overlay in kitty panel:** NOT FEASIBLE (technical barriers insurmountable)
- **TUI browsers available:** Browsh (recommended) and Carbonyl
- **Browsh advantages:** Active maintenance, security updates, easier installation

**Technical Barriers Identified:**
1. Kitty panel kitten only supports terminal programs
2. Modern browsers removed XEmbed support
3. No standard embedding protocol exists
4. Electron/GUI apps cannot be embedded

**Recommendation:** Use Browsh for full web capabilities in terminal, abandon Firefox overlay approach

---

### ✅ Markdown Terminal Viewers Comparison (100%)

**Research Completed:**

| Tool | Stars | Highlights | Best For |
|------|-------|-----------|----------|
| **glow** | 21.9k | Beautiful rendering, TUI mode, themes | Primary viewer, browsing vaults |
| **bat** | 56.3k | Git integration, 200+ languages, fast | Quick scans, syntax highlighting |
| **mdcat** | 2k | Image support (limited), clickable links | When images needed |

**Installation (NixOS):**
```nix
home.packages = with pkgs; [ glow bat ];
```

**Recommendation:** Use `glow` as primary markdown viewer, `bat` for quick syntax-highlighted previews

---

## Research Pending

### ⏳ Items Not Yet Researched

1. **Right-Click Context Menu** - Low priority
2. **GPU & RAM Optimization** - Medium priority
3. **Calendar & Plasma Integration** - Low priority
4. **Terminal Notifications** - Medium priority
5. **Session Persistence** - High priority
6. **PDF Viewing Tools** - Medium priority
7. **LaTeX Live Preview** - Low priority
8. **Quick Notes Widget** - Low priority (superseded by Obsidian findings)

---

## Immediate Action Items

### For User (Mitsos)

**Priority 1: Test Obsidian Integration (30 min)**
1. Review `obsidian-kitty-integration-findings.md`
2. Install Advanced URI plugin in Obsidian
3. Test basic URI commands
4. Decide on vault structure for quick notes

**Priority 2: Install Tools (15 min)**
```nix
# Add to home-manager config
home.packages = with pkgs; [
  glow    # Markdown viewer
  bat     # Syntax highlighter
  browsh  # TUI browser (optional)
];
```

**Priority 3: Create Capture Scripts (30 min)**
1. Create `~/.local/bin/onote` script
2. Create `~/.local/bin/odaily` script
3. Test workflow
4. Add kitty keybindings

### For Next Research Session

**High Priority:**
1. Session persistence mechanisms
2. GPU/RAM optimization settings for NVIDIA GTX 960
3. Terminal notifications setup

**Medium Priority:**
4. PDF viewing in terminal (zathura, termpdf)
5. Right-click context menu solutions

**Low Priority:**
6. Calendar integration
7. LaTeX preview tools
8. Custom quick notes widget (may not be needed)

---

## Implementation Roadmap

### Phase 1: Quick Wins (2-3 hours)
- ✅ Research complete
- ⏳ Install glow and bat
- ⏳ Create Obsidian capture scripts
- ⏳ Configure kitty keybindings
- ⏳ Test basic workflow

### Phase 2: Advanced Integration (4-6 hours)
- ⏳ Session persistence
- ⏳ GPU optimization
- ⏳ Terminal notifications
- ⏳ PDF viewing setup

### Phase 3: Optional Enhancements (8-12 hours)
- ⏳ Right-click menus
- ⏳ Calendar integration
- ⏳ Custom kittens
- ⏳ Advanced workflows

---

## Key Decisions Made

### ❌ Will NOT Implement

1. **Firefox Overlay in kitty Panel**
   - **Reason:** Technically impossible due to architectural constraints
   - **Alternative:** Use Browsh for TUI browsing

2. **Obsidian Panel Overlay**
   - **Reason:** Electron apps cannot be embedded
   - **Alternative:** Floating window + file system access

### ✅ Will Implement

1. **Obsidian URI Integration**
   - Quick capture scripts
   - Terminal markdown viewers
   - Hybrid workflow

2. **TUI Browser (Browsh)**
   - For occasional web browsing in terminal
   - AI chat interfaces (claude.ai, chat.openai.com)

3. **Markdown Workflow**
   - glow for beautiful rendering
   - bat for quick syntax highlighting
   - Direct file system access for captures

---

## Research Quality Metrics

**Sources Consulted:** 30+ web pages, GitHub repositories, official documentation
**Tools Evaluated:** 10+ (Browsh, Carbonyl, glow, bat, mdcat, w3m, lynx, etc.)
**Plugins Researched:** 5+ Obsidian plugins
**Time Invested:** ~2 hours intensive research
**Documentation Created:**
- Main research file: `kitty-enhancements-research-22-12-2025.md`
- Obsidian integration guide: `obsidian-kitty-integration-findings.md`
- This summary: `RESEARCH-SUMMARY-22-12-2025.md`

**Code Examples Provided:**
- 10+ shell scripts
- 5+ kitty configuration snippets
- 3+ home-manager configuration examples
- 2+ Python kittens

---

## Questions for User

1. **Obsidian Vault Location:** Confirmed as `~/.MyHome/` - correct?
2. **Vault Name:** What is your primary vault called?
3. **Quick Notes Strategy:** Prefer dedicated vault or subfolder in main vault?
4. **Browser Usage:** How often do you need web browsing from terminal? (Determines Browsh priority)
5. **Session Persistence:** How important is restoring kitty sessions after reboot?

---

## Next Session Agenda

1. Review this summary with user
2. Answer questions about vault configuration
3. Begin Phase 1 implementation if user approves
4. Continue research on high-priority pending items:
   - Session persistence
   - GPU/RAM optimization
   - Terminal notifications

---

**Research Session Complete**
**Next Steps:** User review and decision on implementation priorities
