# Implementation Plan: Agent Configs Management

**Date:** 2025-12-12
**Planner:** Claude Code (Planner Role)
**Context:** Implementing declarative agent configuration management following research findings
**Status:** 📋 Ready for Review → Implementation

---

## Executive Summary

**Goal:** Implement declarative, reproducible management of AI agent configurations across Claude Code, Codex CLI, and Gemini CLI (future).

**Approach:**
1. ✅ **Global instructions:** Home-manager symlinks to single source of truth
2. ✅ **Config files:** Keep current chezmoi template approach
3. ✅ **Runtime/secrets:** Properly ignored
4. ⏭️ **Testing & validation:** home-manager switch + chezmoi apply

**Confidence:** 0.90 (Band C - SAFE)

---

## Current State (As of 2025-12-12)

### ✅ Completed Today

1. **Research Phase**
   - ✅ Web research on `chezmoi modify` functionality
   - ✅ Local investigation of agent configs
   - ✅ Documentation: `chezmoi-modify-vs-templates-for-agent-configs.md`

2. **Configuration Files Created**
   - ✅ `home-manager/llm-global-instructions-symlinks.nix` (NEW)
   - ✅ `home-manager/llm-tsukuru-project-symlinks.nix` (UPDATED - added WARP.md)
   - ✅ `.local/share/chezmoi/private_dot_gemini/settings.json.tmpl` (NEW - future-ready)
   - ✅ `.local/share/chezmoi/.chezmoiignore` (UPDATED - agent files)
   - ✅ `home-manager/home.nix` (UPDATED - imported new module)

3. **Backups**
   - ✅ `llm-core/config/backups/CLAUDE.md.backup-20251212`
   - ✅ `llm-core/config/backups/AGENTS.md.backup-20251212`

### 🔄 Current Architecture

```
Single Source of Truth
└── llm-core/config/global-config.md
    │
    ├─[symlink via home-manager]→ ~/.claude/CLAUDE.md
    ├─[symlink via home-manager]→ ~/.codex/AGENTS.md
    └─[symlink via home-manager]→ ~/.gemini/AGENTS.md (future)

Project-Specific Instructions
└── llm-core/config/projects/
    ├── my-modular-workspace.md
    ├── llm-tsukuru-llm-core.md
    └── eyeonix-workspace.md
        │
        └─[symlinks via home-manager]→ <project>/CLAUDE.md
                                      → <project>/AGENTS.md
                                      → <project>/WARP.md

Config Files (Templates via chezmoi)
├── ~/.claude/settings.json         ← settings.json.tmpl
├── ~/.claude/mcp_config.json       ← mcp_config.json.tmpl
├── ~/.claude/commands/*.md         ← plain files
├── ~/.codex/config.toml            ← config.toml.tmpl
└── ~/.gemini/settings.json (future) ← settings.json.tmpl

Ignored Files
├── Runtime data (cache/, file-history/, todos/, etc.)
├── Secrets (.credentials.json, auth.json, git-token.json)
└── Local overrides (settings.local.json)
```

---

## Implementation Plan

### Phase 1: Validation & Testing ⏭️ NEXT

**Objective:** Ensure all configurations are syntactically correct and test in dry-run mode.

**Tasks:**

1. **Validate Nix Syntax** ✅ (Already done)
   ```bash
   nix-instantiate --parse home-manager/llm-global-instructions-symlinks.nix
   nix-instantiate --parse home-manager/llm-tsukuru-project-symlinks.nix
   ```

2. **Dry-Run home-manager** (Recommended before apply)
   ```bash
   home-manager build
   ```
   **Expected outcome:** Build succeeds, no errors

3. **Review What Will Change**
   ```bash
   home-manager build && \
   diff -r ~/.config/home-manager $(readlink -f result)
   ```
   **Expected changes:**
   - New symlinks in home.activationPackage
   - Validation scripts added

4. **Check for Conflicts**
   ```bash
   # Verify current files that will be replaced
   ls -la ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.gemini/AGENTS.md
   ```
   **Expected:** CLAUDE.md and AGENTS.md exist (will be replaced), AGENTS.md in gemini doesn't exist

5. **Decision Point: Proceed to Phase 2?**
   - [ ] Nix syntax valid ✅
   - [ ] home-manager build succeeds
   - [ ] No unexpected conflicts
   - [ ] User approval ⏳

**Confidence:** 0.92 (Band C)

---

### Phase 2: home-manager Application ⏭️

**Objective:** Apply home-manager configuration to create global instruction symlinks.

**Prerequisites:**
- ✅ Phase 1 validation passed
- ⏳ User approval

**Tasks:**

1. **Apply home-manager**
   ```bash
   home-manager switch
   ```
   **What happens:**
   - Replaces `~/.claude/CLAUDE.md` with symlink → `llm-core/config/global-config.md`
   - Replaces `~/.codex/AGENTS.md` with symlink → `llm-core/config/global-config.md`
   - Creates `~/.gemini/AGENTS.md` symlink → `llm-core/config/global-config.md`
   - Runs validation script (checks if source file exists)
   - Project symlinks updated to include WARP.md

2. **Verify Symlinks Created**
   ```bash
   ls -la ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.gemini/AGENTS.md
   ```
   **Expected:** All are symlinks pointing to `llm-core/config/global-config.md`

3. **Verify Symlink Targets Exist**
   ```bash
   readlink -f ~/.claude/CLAUDE.md
   readlink -f ~/.codex/AGENTS.md
   readlink -f ~/.gemini/AGENTS.md
   ```
   **Expected:** All resolve to actual file path

4. **Check Validation Output**
   ```bash
   # Check home-manager activation log
   journalctl --user -u home-manager-$USER.service -n 50
   ```
   **Expected:** "✅ Global config source exists" message

**Rollback Plan if Issues:**
```bash
# Restore from backup
cp ~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/backups/CLAUDE.md.backup-20251212 \
   ~/.claude/CLAUDE.md

cp ~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/config/backups/AGENTS.md.backup-20251212 \
   ~/.codex/AGENTS.md
```

**Confidence:** 0.88 (Band C)

---

### Phase 3: chezmoi Validation ⏭️

**Objective:** Ensure chezmoi properly ignores symlinked files and manages config templates.

**Prerequisites:**
- ✅ Phase 2 completed
- ✅ Symlinks in place

**Tasks:**

1. **Verify .chezmoiignore Working**
   ```bash
   cd ~/.local/share/chezmoi
   chezmoi managed | grep -E "(CLAUDE.md|AGENTS.md)" || echo "✅ Correctly ignored"
   ```
   **Expected:** No CLAUDE.md or AGENTS.md in managed files list

2. **Check chezmoi Status**
   ```bash
   chezmoi status
   ```
   **Expected:** No conflicts or unexpected changes related to agent files

3. **Test chezmoi Apply (Dry-Run)**
   ```bash
   chezmoi apply --dry-run --verbose
   ```
   **Expected:** Only manages settings.json, mcp_config.json, config.toml, commands/*

4. **Apply chezmoi if Dry-Run OK**
   ```bash
   chezmoi apply
   ```
   **What happens:**
   - Updates `~/.claude/settings.json` from template
   - Updates `~/.claude/mcp_config.json` from template
   - Updates `~/.codex/config.toml` from template
   - Creates `~/.gemini/settings.json` from template (new)
   - Ignores CLAUDE.md, AGENTS.md (symlinks)

5. **Verify Templates Applied**
   ```bash
   diff ~/.claude/settings.json \
        <(chezmoi execute-template < ~/.local/share/chezmoi/private_dot_claude/settings.json.tmpl)
   ```
   **Expected:** No diff (files match)

**Confidence:** 0.90 (Band C)

---

### Phase 4: Agent Testing ⏭️

**Objective:** Test that agents can read global instructions from symlinked files.

**Prerequisites:**
- ✅ Phases 1-3 completed
- ✅ All symlinks in place
- ✅ Templates applied

**Tasks:**

1. **Test Claude Code**
   ```bash
   # Start new Claude Code session
   claude-code
   ```
   **Verify:**
   - [ ] Can read CLAUDE.md
   - [ ] Instructions from global-config.md are active
   - [ ] No errors about missing files

2. **Test Codex CLI**
   ```bash
   # Start Codex session
   codex
   ```
   **Verify:**
   - [ ] Can read AGENTS.md
   - [ ] Global instructions loaded
   - [ ] MCP servers from config.toml working

3. **Test Project-Level Symlinks**
   ```bash
   # Navigate to project
   cd ~/.MyHome/MySpaces/my-modular-workspace

   # Check symlinks exist
   ls -la CLAUDE.md AGENTS.md WARP.md
   ```
   **Expected:** All three symlinks exist and point to merged project config

4. **Decision Point: Success?**
   - [ ] Claude Code reads instructions correctly
   - [ ] Codex reads instructions correctly
   - [ ] Project symlinks working
   - [ ] No errors or issues

**Confidence:** 0.85 (Band C, requires practical testing)

---

### Phase 5: Documentation & Cleanup ⏭️

**Objective:** Document the new architecture and clean up any temporary files.

**Tasks:**

1. **Update ADRs if Needed**
   - Consider creating ADR-012 for agent config management
   - Or update existing ADRs to reference this approach

2. **Update README/Docs**
   - Document symlink architecture in project README
   - Add troubleshooting guide for broken symlinks

3. **Clean Up**
   ```bash
   # Remove any test files or temporary configs
   # (if any were created during testing)
   ```

4. **Git Commit**
   ```bash
   # In home-manager repo
   cd ~/.MyHome/MySpaces/my-modular-workspace
   git status
   git add home-manager/llm-global-instructions-symlinks.nix \
           home-manager/llm-tsukuru-project-symlinks.nix \
           home-manager/home.nix \
           docs/researches/*.md
   git commit -m "Add declarative agent config management

   - Create llm-global-instructions-symlinks.nix for Claude/Codex/Gemini
   - Update llm-tsukuru-project-symlinks.nix to include WARP.md
   - Add Gemini CLI chezmoi template (future-ready)
   - Update .chezmoiignore for agent instruction files
   - Document research findings and implementation plan

   Related: ADR-005 (chezmoi criteria), ADR-010 (MCP architecture)

   🤖 Generated with Claude Code"

   git push
   ```

5. **chezmoi Commit**
   ```bash
   # In chezmoi repo
   chezmoi cd
   git status
   git add .chezmoiignore \
           private_dot_gemini/settings.json.tmpl
   git commit -m "Update ignore patterns and add Gemini config template

   - Ignore agent instruction files (managed by home-manager symlinks)
   - Ignore Claude Code runtime files
   - Add Gemini CLI settings template (future-ready)

   🤖 Generated with Claude Code"

   git push
   ```

**Confidence:** 0.95 (Band C - straightforward)

---

## Risk Assessment & Mitigation

### Risk 1: Symlink Breaks if Source File Missing

**Severity:** Medium
**Likelihood:** Low

**Scenario:** If `llm-core/config/global-config.md` is deleted or moved, symlinks become broken.

**Mitigation:**
- ✅ Validation script in home-manager checks source exists
- ✅ Backups created before changes
- 📋 Keep backups for at least 1 month
- 📋 Add git hook to warn if global-config.md deleted

**Recovery:**
```bash
# Restore from backup or git history
cd ~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core
git checkout config/global-config.md
```

### Risk 2: chezmoi Tries to Manage Symlinked Files

**Severity:** Low
**Likelihood:** Very Low

**Scenario:** chezmoi ignores patterns don't work, tries to manage CLAUDE.md/AGENTS.md

**Mitigation:**
- ✅ .chezmoiignore updated with explicit patterns
- ✅ Phase 3 validation tests this
- 📋 Test before full apply

**Recovery:**
```bash
# Remove from chezmoi if accidentally added
chezmoi forget ~/.claude/CLAUDE.md
chezmoi forget ~/.codex/AGENTS.md
```

### Risk 3: home-manager Apply Fails

**Severity:** Medium
**Likelihood:** Very Low (syntax already validated)

**Scenario:** home-manager switch fails due to Nix error

**Mitigation:**
- ✅ Nix syntax pre-validated
- ✅ home-manager build tested first
- 📋 Rollback to previous generation

**Recovery:**
```bash
# Rollback to previous home-manager generation
home-manager generations
home-manager switch --rollback
```

### Risk 4: Agents Can't Read Symlinked Files

**Severity:** High (blocks agents from working)
**Likelihood:** Very Low

**Scenario:** Permissions or symlink issues prevent agents from reading instruction files

**Mitigation:**
- ✅ mkOutOfStoreSymlink used (correct for this use case)
- 📋 Phase 4 tests this explicitly
- 📋 Backups available for quick restore

**Recovery:**
```bash
# Quick restore from backup
cp llm-core/config/backups/*.backup-20251212 <target-locations>

# Or convert symlink to regular file temporarily
rm ~/.claude/CLAUDE.md
cp llm-core/config/global-config.md ~/.claude/CLAUDE.md
```

---

## Success Criteria

### Must Have ✅

- [ ] home-manager switch completes successfully
- [ ] Symlinks created and pointing to correct source
- [ ] Source file (global-config.md) readable by agents
- [ ] Claude Code can read CLAUDE.md
- [ ] Codex can read AGENTS.md
- [ ] chezmoi applies without conflicts
- [ ] No broken symlinks

### Should Have 📋

- [ ] Validation scripts run and pass
- [ ] Project symlinks include WARP.md
- [ ] Gemini config template ready for future
- [ ] Documentation complete
- [ ] Git commits made

### Nice to Have ⭐

- [ ] ADR created for this architecture
- [ ] Git hooks for validation
- [ ] Monitoring/alerts for broken symlinks

---

## Timeline Estimate

**Phase 1 (Validation):** 15-20 minutes
**Phase 2 (Apply home-manager):** 5-10 minutes
**Phase 3 (chezmoi Validation):** 10-15 minutes
**Phase 4 (Agent Testing):** 15-20 minutes
**Phase 5 (Documentation):** 20-30 minutes

**Total:** 1-1.5 hours (conservative, including testing and verification)

**Note:** No time pressure - can pause between phases for review.

---

## Next Steps

### Immediate (Awaiting User Approval)

1. **Review this plan** - User confirms approach
2. **Proceed to Phase 1** - Validation & testing
3. **Decision gate** - Continue to Phase 2 if validation passes

### After Completion

1. Monitor for issues over 1-2 weeks
2. Consider creating ADR-012
3. Evaluate if Gemini CLI installation needed
4. Archive backups after 1 month if no issues

---

## Questions for User

Before proceeding to implementation, please confirm:

1. ✅ **Approach approved?** Single source of truth via symlinks for global instructions
2. ✅ **Keep templates?** For settings.json, mcp_config.json, config.toml (not using modify_)
3. ⏳ **Ready to proceed?** Start Phase 1 validation now?
4. ⏳ **Time to allocate?** Have 1-1.5 hours for full implementation + testing?
5. ⏳ **Prefer to review phases?** Or trust plan and execute all at once?

---

**Plan Status:** 📋 Ready for User Review
**Confidence:** 0.90 (Band C - SAFE)
**Recommendation:** Proceed when ready, no urgency

---

**Planner:** Claude Code (Planner Role)
**Time:** 2025-12-12T00:19:14+02:00 (Europe/Athens)
**Context Used:** 91.8k tokens (~46% of 200k budget)

