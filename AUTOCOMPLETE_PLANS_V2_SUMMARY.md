# Autocomplete Implementation Plans V2 - Executive Summary

**Date:** 2025-12-04
**Status:** ✅ Ready for Implementation (after critical fixes applied)

---

## Overview

Two autocomplete solutions for kitty/bash on shoshin:

1. **Classic (ble.sh):** Local, fast, fish-like autosuggestions
2. **LLM (butterfish):** AI-powered, context-aware completions

**Current Status:**
- V1 Plans: Created with ultrathink reviews
- Critical Gaps: 16 total identified (5 classic, 11 LLM)
- V2 Plans: Critical fixes integrated
- Secret Management: Pattern designed and documented

---

## PLAN_V2: Classic Autocomplete (ble.sh)

**Base Plan:** `docs/commons/toolbox/kitty/PLAN_CLASSIC_AUTOCOMPLETE_BLE_SH.md`
**Review:** `docs/commons/toolbox/kitty/PLAN_CLASSIC_AUTOCOMPLETE_ULTRATHINK_REVIEW.md`
**Score:** 7/10 → **9/10** (after V2 fixes)

### Critical Fixes Applied in V2:

**Fix #1: Windows/WSL Compatibility** (Critical Gap #3)
```bash
# dotfiles/dot_bashrc.tmpl
{{ if (eq .chezmoi.os "linux") }}
{{ if (not (env "WSL_DISTRO_NAME")) }}
# ble.sh loading code here
{{ end }}
{{ end }}
```

**Fix #2: Backup Strategy** (Critical Gap #2)
```bash
# NEW Task 0.0 (before Phase 2)
cp ~/.bashrc ~/.bashrc.backup-$(date +%Y%m%d-%H%M%S)
cd dotfiles && git commit -m "backup: .bashrc before ble.sh"
```

**Fix #3: Performance Baseline** (Critical Gap #4)
```bash
# NEW Task 1.0 (Phase 1, before installation)
for i in {1..5}; do time bash -i -c exit; done
# Save baseline for comparison in Phase 4
```

**Fix #4: SSH Testing** (Critical Gap #1)
```bash
# NEW Task 4.2.5 (Phase 4 testing)
ssh remote-server
# Verify ble.sh works, no conflicts with SSH
```

**Fix #5: Rollback Testing** (Critical Gap #5)
```bash
# NEW Task 4.6 (Phase 4)
# Test rollback procedure works before declaring success
```

**Implementation:** All phases from V1 plan + 5 new tasks for fixes.

---

## PLAN_V2: LLM Autocomplete (butterfish)

**Base Plan:** `docs/commons/toolbox/kitty/PLAN_LLM_AUTOCOMPLETE_BUTTERFISH.md`
**Review:** `docs/commons/toolbox/kitty/PLAN_LLM_AUTOCOMPLETE_ULTRATHINK_REVIEW.md`
**Score:** 6.5/10 → **8.5/10** (after V2 fixes)

### Critical Fixes Applied in V2:

**Security Fixes:**

**Fix #1: API Key Validation** (Critical Gap #1)
```bash
# In secret loader validate function
validate_format '^sk-[A-Za-z0-9]{48,}$' 'OpenAI API key'
```

**Fix #2: Bash History Protection** (Critical Gap #2)
```bash
# At top of .bashrc
export HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}*API_KEY*:*TOKEN*:*secret-tool*"
```

**Fix #3: Company Pattern Blocking** (Critical Gap #4)
```yaml
# config.yaml
blocked_patterns:
  - "password"
  - "secret"
  - "token"
  - "10\\."  # Private IP ranges
  - "prod-"   # Production prefixes
  - "company\\.internal"  # Internal domains
```

**Cross-Platform Fixes:**

**Fix #4: Windows/WSL Support** (Critical Gap #6)
```nix
# butterfish-secret.nix
lib.mkIf pkgs.stdenv.isLinux {
  # Service only on Linux
}
```

```bash
# dot_bashrc.tmpl
{{ if (eq .chezmoi.os "linux") }}
{{ if (not (env "WSL_DISTRO_NAME")) }}
# butterfish loading here
{{ end }}
{{ end }}
```

**Safety Fixes:**

**Fix #5: Backup Strategy** (Critical Gap #7)
Same as classic plan - backup before changes.

**Fix #6: Performance Baseline** (Critical Gap #8)
Same as classic plan - measure before/after.

**Secret Management Integration:**

**Fix #7-11:** Integrated systemd + KeePassXC pattern
- See: `docs/integrations/systemd-keepassxc-secret-management.md`
- See: `docs/COMPLETE_SECRET_MANAGEMENT_IMPLEMENTATION.md`

**Implementation:** All 6 phases from V1 + secret management integration + 11 critical fixes.

---

## Implementation Priority

**Recommended Order:**

### Phase 1: Secret Management Setup (30 min)
1. Create `keepassxc-secret-loader.nix`
2. Create `butterfish-secret.nix`
3. Store API key in KeePassXC
4. Test systemd service

### Phase 2: Classic Autocomplete (ble.sh) (2 hours)
- Lower risk, no secrets needed
- Implement PLAN_V2 with all fixes
- Test thoroughly
- Commit when working

### Phase 3: LLM Autocomplete (butterfish) (3 hours)
- Depends on Phase 1 (secrets)
- Implement PLAN_V2 with all fixes
- Test security, privacy, performance
- Commit when working

### Phase 4: Validation (30 min)
- Test both tools together
- Verify no conflicts
- Document any issues
- Update TODO.md

---

## Success Criteria

**Classic (ble.sh):**
- ✅ Installs via home-manager
- ✅ Works on NixOS (shoshin)
- ✅ Doesn't break Windows/WSL (laptop-system01)
- ✅ Fish-like suggestions as-you-type
- ✅ Right arrow accepts
- ✅ Performance overhead < 0.5s
- ✅ SSH sessions work normally
- ✅ Rollback tested

**LLM (butterfish):**
- ✅ API key secure (KeePassXC → systemd → tmpfs)
- ✅ SSH sessions don't use butterfish
- ✅ Company patterns blocked
- ✅ Bash history protected
- ✅ Windows/WSL conditional loading
- ✅ Capital+Tab triggers AI
- ✅ Graceful degradation if API unavailable
- ✅ No secrets in logs/history/process list

---

## File Locations

**Documentation:**
- This summary: `docs/AUTOCOMPLETE_PLANS_V2_SUMMARY.md`
- Secret management: `docs/integrations/systemd-keepassxc-secret-management.md`
- Full implementation: `docs/COMPLETE_SECRET_MANAGEMENT_IMPLEMENTATION.md`

**Original Plans:**
- Classic V1: `docs/commons/toolbox/kitty/PLAN_CLASSIC_AUTOCOMPLETE_BLE_SH.md`
- Classic Review: `docs/commons/toolbox/kitty/PLAN_CLASSIC_AUTOCOMPLETE_ULTRATHINK_REVIEW.md`
- LLM V1: `docs/commons/toolbox/kitty/PLAN_LLM_AUTOCOMPLETE_BUTTERFISH.md`
- LLM Review: `docs/commons/toolbox/kitty/PLAN_LLM_AUTOCOMPLETE_ULTRATHINK_REVIEW.md`

**Implementation Files (to create):**
- `home-manager/secrets/keepassxc-secret-loader.nix`
- `home-manager/secrets/butterfish-secret.nix`
- Update `home-manager/home.nix`
- Update `dotfiles/dot_bashrc.tmpl`

---

## Next Actions

1. ✅ Review this summary
2. ⏳ Create secret management infrastructure
3. ⏳ Implement classic autocomplete (ble.sh) with V2 fixes
4. ⏳ Implement LLM autocomplete (butterfish) with V2 fixes
5. ⏳ Test and validate
6. ⏳ Document results

---

**Status:** ✅ Plans ready, all critical gaps addressed
**Recommendation:** Proceed with Phase 1 (Secret Management) implementation
