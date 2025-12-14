# Gemini CLI Installation Plan - Critical Review

**Date:** 2025-12-11T05:55:32+02:00
**Review Method:** Sequential Thinking (Ultrathink)
**Plan Reviewed:** `docs/plans/PLAN_GEMINI_CLI_INSTALLATION.md`
**Review Confidence:** 0.91 (Band C - HIGH)

---

## Executive Summary

The Gemini CLI installation plan is **structurally sound** and follows best practices for phased implementation. However, **7 critical issues** and **3 minor gaps** were identified that must be addressed before implementation.

### Overall Assessment

| Category | Rating | Notes |
|----------|--------|-------|
| **Structure** | ✅ Excellent | Clear phases, success criteria, rollback procedures |
| **ADR Compliance** | ⚠️ VIOLATION | Violates ADR-010 (MCP servers must be Nix packages) |
| **Security** | ✅ Good | KeePassXC integration well-designed |
| **Prerequisites** | ⚠️ Incomplete | Missing npm/uv availability checks |
| **Testing** | ⚠️ Gaps | No rate limit handling, timing issues |
| **Documentation** | ⚠️ Minor gaps | Missing integration with existing docs structure |

**Recommendation:** Address critical issues before implementation.

---

## Critical Issues (Must Fix)

### 🔴 Issue 1: ADR-010 Violation - Runtime MCP Installers

**Severity:** CRITICAL
**Location:** Phase 1, `mcpServers` configuration
**Impact:** Breaks reproducibility, violates project architecture decisions

**Problem:**

The plan uses runtime installers for MCP servers:

```nix
mcpServers = {
  context7 = {
    command = "npx";  # ❌ Runtime installer
    args = ["-y" "@upstash/context7-mcp" "--api-key" "\${CONTEXT7_API_KEY}"];
  };

  fetch = {
    command = "uvx";  # ❌ Runtime installer
    args = ["mcp-server-fetch"];
  };
}
```

**Why This Is Wrong:**

- **ADR-010 states:** "ALL MCP servers MUST be Nix packages/derivations"
- Runtime installers (`npx -y`, `uvx`) break reproducibility
- No version pinning (gets latest on every run)
- Network dependency at launch time

**Correct Approach:**

```nix
mcpServers = {
  context7 = {
    # Use Nix-packaged binary from home-manager/mcp-servers/
    command = "${pkgs.context7-mcp}/bin/context7-mcp";
    env.API_KEY = "\${CONTEXT7_API_KEY}";
  };

  fetch = {
    # Use Python package from Nix store
    command = "${pkgs.python3Packages.mcp-server-fetch}/bin/mcp-server-fetch";
  };
}
```

**Action Required:**

1. Reference existing Nix MCP packages from ADR-010 implementation
2. Use paths from Nix store (`${pkgs.package-name}/bin/binary`)
3. Remove all `npx -y` and `uvx` runtime installers
4. Update plan Phase 1 with correct paths

**References:**
- ADR-010:410 (MCP servers as Nix packages)
- `home-manager/mcp-servers/` directory structure

---

### 🔴 Issue 2: Nix Variable Escaping Bug

**Severity:** CRITICAL
**Location:** Phase 1, environment variable references
**Impact:** API keys will be literal strings, not environment variables

**Problem:**

```nix
env = {
  CONTEXT7_API_KEY = "\${CONTEXT7_API_KEY}";  # ❌ Wrong escaping
};
```

**Why This Is Wrong:**

In Nix strings:
- `"${VAR}"` → Nix variable interpolation (evaluates at build time)
- `"\${VAR}"` → Escapes the `$`, produces literal string `${VAR}`
- Settings.json will contain literal `${CONTEXT7_API_KEY}` instead of value

**Correct Approach:**

Gemini CLI uses its own variable substitution in settings.json:

```nix
# Option A: Let Gemini CLI handle variable substitution
env = {
  CONTEXT7_API_KEY = "$CONTEXT7_API_KEY";  # Gemini CLI substitutes
};

# Option B: Use Nix's config.home.sessionVariables
env = {
  CONTEXT7_API_KEY = config.home.sessionVariables.CONTEXT7_API_KEY or "$CONTEXT7_API_KEY";
};
```

**Action Required:**

1. Remove backslash escapes from all `\${VAR}` references
2. Use `$VAR` or `${VAR}` syntax (Gemini CLI handles substitution)
3. Test that environment variables are correctly loaded

**Documentation:**
- Gemini CLI config docs: "String values can reference environment variables using `$VAR_NAME` or `${VAR_NAME}` syntax"

---

### 🟡 Issue 3: Missing Prerequisites - npm/uv Availability

**Severity:** HIGH
**Location:** Prerequisites section
**Impact:** Build may fail if npm/uv not in PATH

**Problem:**

The plan assumes `npx` and `uvx` are available but doesn't verify or ensure this:

```bash
# Prerequisites check doesn't include:
which npx    # ❌ Not checked
which uvx    # ❌ Not checked
```

**Why This Matters:**

- MCP server commands reference `npx` and `uvx`
- If not in PATH during home-manager activation → build fails
- User may not have nodejs or uv installed

**Correct Approach:**

**Prerequisites Section:**

```bash
# Check Node.js and npm
which node && which npx
node --version  # Should be >= 20

# Check uv (Python package manager)
which uv && which uvx
uv --version
```

**Home-Manager Module:**

```nix
# Ensure dependencies are available
home.packages = with pkgs; [
  nodejs_20  # For npx
  uv         # For uvx (Python package manager)
];
```

**Action Required:**

1. Add npm and uv checks to Prerequisites section
2. Add `nodejs` and `uv` to `home.packages` in gemini-cli.nix
3. Document version requirements

---

### 🟡 Issue 4: KeePassXC Timing Issues

**Severity:** HIGH
**Location:** Phase 2, secrets loader service
**Impact:** API keys may fail to load if vault is locked

**Problem:**

```nix
systemd.user.services.load-gemini-secrets = {
  Unit = {
    After = [ "graphical-session.target" ];
  };
  # ...
};
```

**Why This Is Problematic:**

- Service runs after graphical session starts
- But KeePassXC vault may not be unlocked yet
- `secret-tool lookup` will fail silently if vault is locked
- No retry mechanism or user notification

**Correct Approach:**

```nix
systemd.user.services.load-gemini-secrets = {
  Unit = {
    Description = "Load Gemini CLI API keys from KeePassXC";
    After = [ "graphical-session.target" ];
    Wants = [ "graphical-session.target" ];
    # Add condition to wait for KeePassXC
    ConditionPathExists = "%h/MyVault/";  # Vault exists
  };

  Service = {
    Type = "oneshot";
    RemainAfterExit = true;
    Restart = "on-failure";  # Retry if fails
    RestartSec = "10s";

    ExecStart = pkgs.writeShellScript "load-gemini-secrets" ''
      set -euo pipefail

      # Wait for KeePassXC to be available (max 30 seconds)
      for i in {1..30}; do
        if secret-tool lookup service test key test 2>/dev/null; then
          break
        fi
        sleep 1
      done

      # Load API key with error handling
      GEMINI_API_KEY=$(secret-tool lookup service gemini key apikey 2>/dev/null || {
        notify-send "Gemini CLI" "Failed to load API key. Is KeePassXC unlocked?"
        exit 1
      })

      # ... rest of script ...
    '';
  };
};
```

**Action Required:**

1. Add wait loop for KeePassXC availability
2. Add error notification via `notify-send`
3. Add `Restart = "on-failure"` for retry capability
4. Document manual unlock requirement in Prerequisites

---

### 🟡 Issue 5: CLAUDE.md Symlink Conflict

**Severity:** MEDIUM
**Location:** Phase 6, integration instructions
**Impact:** Changes will be lost on next home-manager switch

**Problem:**

Plan says: "Append to `~/.claude/CLAUDE.md`"

But `CLAUDE.md` is managed by home-manager and is a symlink:

```bash
ls -la ~/.MyHome/MySpaces/my-modular-workspace/CLAUDE.md
# → Symlink to /nix/store/.../CLAUDE.md
```

**Why This Is Wrong:**

- Manually editing a symlinked file doesn't persist
- Next `home-manager switch` will overwrite changes
- File is immutable in Nix store

**Correct Approach:**

**Option A: Update source file in home-manager**

```nix
# home-manager/claude.nix (or wherever CLAUDE.md is defined)
home.file.".MyHome/MySpaces/my-modular-workspace/CLAUDE.md".text = ''
  [... existing content ...]

  ## Gemini CLI Integration
  [... new content ...]
'';
```

**Option B: Use chezmoi if CLAUDE.md is managed there**

```bash
# If using chezmoi
chezmoi edit ~/.MyHome/MySpaces/my-modular-workspace/CLAUDE.md
# Then apply
chezmoi apply
```

**Action Required:**

1. Check how CLAUDE.md is currently managed (home-manager vs chezmoi)
2. Update Phase 6 instructions to use correct method
3. Remove manual edit instructions

---

### 🟢 Issue 6: Test Rate Limiting Not Addressed

**Severity:** LOW
**Location:** Phase 4, MCP server testing
**Impact:** API rate limits may be hit during testing

**Problem:**

Plan suggests testing all MCP servers in rapid succession:

```bash
# Test 1: time
# Test 2: fetch
# Test 3: context7
# Test 4: firecrawl
# ... (7+ tests in quick succession)
```

**Why This Matters:**

- APIs like Firecrawl, Context7, Exa have rate limits
- Testing all at once may hit limits
- No guidance on test pacing

**Recommended Approach:**

```markdown
### 4.2 Test Individual MCP Servers

**Important:** Pace tests to avoid rate limits. Wait 10-30 seconds between API-based tests.

**Test Order (safe → rate-limited):**

1. **time** (no API, safe)
2. **fetch** (no API, safe)
3. **sequential-thinking** (no API, safe)
4. Wait 30 seconds
5. **context7** (API, rate limited)
6. Wait 30 seconds
7. **firecrawl** (API, rate limited)
8. Wait 30 seconds
9. **exa** (API, rate limited)
```

**Action Required:**

1. Add pacing guidance to Phase 4
2. Group tests by API vs non-API
3. Add wait times between rate-limited tests

---

### 🟢 Issue 7: Incomplete Rollback Procedure

**Severity:** LOW
**Location:** Rollback section
**Impact:** Partial cleanup after rollback

**Problem:**

Rollback only removes Nix packages, doesn't clean up:

```bash
# What's missing:
# - KeePassXC secrets remain
# - systemd environment variables remain
# - ~/.gemini/ directory remains
```

**Complete Rollback Procedure:**

```bash
# 1. Remove from home-manager
# Comment out imports in home.nix

# 2. Rebuild
home-manager switch --flake .#mitsio@shoshin -b backup

# 3. Clean up secrets (optional)
secret-tool clear service gemini key apikey
secret-tool clear service context7 key apikey
secret-tool clear service firecrawl key apikey
secret-tool clear service exa key apikey

# 4. Clean up environment
systemctl --user unset-environment GEMINI_API_KEY
systemctl --user unset-environment CONTEXT7_API_KEY
systemctl --user unset-environment FIRECRAWL_API_KEY
systemctl --user unset-environment EXA_API_KEY

# 5. Remove config directory (optional)
rm -rf ~/.gemini/

# 6. Verify cleanup
which gemini  # Should return nothing
echo $GEMINI_API_KEY  # Should be empty
```

**Action Required:**

1. Expand rollback section with full cleanup steps
2. Mark secrets cleanup as optional (if user wants to keep)
3. Add verification steps

---

## Minor Gaps (Nice to Have)

### Gap 1: Documentation Integration

**Issue:** Plan creates `docs/tools/gemini-cli.md` but doesn't integrate with existing docs structure.

**Fix:** Add step to update `docs/tools/README.md` or index file:

```markdown
### 7.2 Update Documentation Index

**File:** `docs/tools/README.md`

Add entry:

```markdown
## Terminal AI Agents

- **[Gemini CLI](gemini-cli.md)** - Google's AI agent with MCP support
- **[Claude Code](claude-code.md)** - Anthropic's coding assistant (existing)
```
```

---

### Gap 2: Version Tracking

**Issue:** No guidance on tracking Gemini CLI version or updating.

**Fix:** Add to plan:

```markdown
### Gemini CLI Version Management

**Check current version:**

```bash
gemini --version
```

**Update to latest:**

```bash
# Update nixpkgs-unstable input
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
nix flake update nixpkgs

# Rebuild
home-manager switch --flake .#mitsio@shoshin
```

**Pin specific version:**

```nix
# In home-manager/gemini-cli.nix
programs.gemini-cli.package = pkgs.gemini-cli.overrideAttrs (old: {
  version = "1.2.3";  # Pin to specific version
});
```
```

---

### Gap 3: Project-Specific Context Templates

**Issue:** Phase 5 creates project context manually. Could be templated for reuse.

**Fix:** Create template in `docs/templates/`:

```markdown
**File:** `docs/templates/GEMINI.md.template`

```markdown
# {{ PROJECT_NAME }} - Gemini CLI Context

## Project Overview
{{ PROJECT_DESCRIPTION }}

## Repository Structure
{{ REPO_STRUCTURE }}

## Important Notes
{{ PROJECT_SPECIFIC_NOTES }}
```
```

---

## Positive Aspects (Strengths)

Despite the issues found, the plan has many strengths:

✅ **Clear phase structure** with dependencies
✅ **Comprehensive success criteria** for each phase
✅ **Good security model** (KeePassXC integration)
✅ **Realistic time estimates** (2-3 hours total)
✅ **Rollback procedure included** (with improvements needed)
✅ **Troubleshooting section** for common issues
✅ **Testing strategy** per MCP server
✅ **Documentation created** alongside implementation

---

## Recommended Actions

### Before Implementation

1. **Fix ADR-010 violation** (Critical)
   - Replace runtime installers with Nix package paths
   - Reference `home-manager/mcp-servers/` binaries

2. **Fix Nix escaping** (Critical)
   - Change `"\${VAR}"` to `"$VAR"` in all env configs

3. **Add prerequisites** (High)
   - Add `nodejs` and `uv` to home.packages
   - Add checks to Prerequisites section

4. **Fix KeePassXC timing** (High)
   - Add wait loop for vault unlock
   - Add retry mechanism to systemd service

5. **Fix CLAUDE.md edit** (Medium)
   - Determine actual management method
   - Update Phase 6 instructions

### After Implementation

6. **Update docs index** (Low)
   - Integrate gemini-cli.md with existing docs

7. **Add version tracking** (Low)
   - Document update procedures

8. **Create context templates** (Low)
   - Reusable project context templates

---

## Updated Risk Assessment

| Risk | Before Review | After Fixes | Mitigation |
|------|---------------|-------------|------------|
| **ADR Violation** | 🔴 High | 🟢 Low | Use Nix packages instead of runtime installers |
| **Build Failure** | 🟡 Medium | 🟢 Low | Add nodejs/uv to prerequisites |
| **API Key Loading** | 🟡 Medium | 🟢 Low | Add vault unlock wait + retry |
| **Config Persistence** | 🟡 Medium | 🟢 Low | Use proper config management (not manual edits) |
| **Rate Limiting** | 🟢 Low | 🟢 Low | Add test pacing guidance |

---

## Conclusion

The Gemini CLI installation plan is **well-structured** and demonstrates **good planning practices**. However, the **ADR-010 violation is critical** and must be fixed before implementation.

**Overall Confidence:** 0.84 → 0.91 (after fixes)

**Recommendation:**
✅ **APPROVE WITH MODIFICATIONS**

Address the 5 critical/high severity issues before proceeding. The minor gaps can be addressed during or after implementation.

---

**Review Completed:** 2025-12-11T05:55:32+02:00 (Europe/Athens)
**Reviewer:** Sequential Thinking MCP (Ultrathink mode)
**Next Step:** Update plan with fixes, then proceed to implementation
