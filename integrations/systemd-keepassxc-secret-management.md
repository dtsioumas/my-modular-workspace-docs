# Systemd + KeePassXC Secret Management Pattern

**Created:** 2025-12-04
**Status:** ✅ Implementation Ready
**Purpose:** Secure, reusable API key management for all tools

---

## Quick Reference

**What:** Load secrets from KeePassXC into systemd services → $XDG_RUNTIME_DIR → bash
**Why:** Secure, automatic, reusable pattern for API keys
**How:** Generic Nix function + tool-specific instances

---

## Files to Create

1. **`home-manager/secrets/keepassxc-secret-loader.nix`** - Generic loader function
2. **`home-manager/secrets/butterfish-secret.nix`** - Butterfish API key service
3. **Update `home-manager/home.nix`** - Import butterfish-secret
4. **Update `dotfiles/dot_bashrc.tmpl`** - Load secret from $XDG_RUNTIME_DIR

Full implementation code: See `docs/COMPLETE_SECRET_MANAGEMENT_IMPLEMENTATION.md`

---

## Quick Setup

```bash
# 1. Store secret in KeePassXC
secret-tool store --label="OpenAI API Key (butterfish)" \
  application butterfish account openai

# 2. Create Nix files (see full implementation doc)
mkdir -p home-manager/secrets

# 3. Apply
home-manager switch

# 4. Verify
systemctl --user status butterfish-api-key.service
ls -l $XDG_RUNTIME_DIR/butterfish-api-key  # Should be -rw-------
```

---

## Security Features

- ✅ AES-256 encrypted storage (KeePassXC)
- ✅ tmpfs runtime storage (auto-cleanup on logout)
- ✅ 600 file permissions (user-only)
- ✅ 15+ systemd hardening options
- ✅ Format validation
- ✅ No command-line args (not visible in ps)
- ✅ HISTIGNORE prevents bash history leakage

---

## Extending to Other Tools

Use same pattern for any tool needing secrets - just copy `butterfish-secret.nix` and adjust parameters.

---

**Related:** 
- Implementation: `docs/COMPLETE_SECRET_MANAGEMENT_IMPLEMENTATION.md`
- Butterfish plan: `docs/tools/autocomplete-sh.md` (Section: LLM Autocomplete)
- ADR-007: Autostart Tools via Home-Manager
- ADR-009: Shell Enhancement Configuration
