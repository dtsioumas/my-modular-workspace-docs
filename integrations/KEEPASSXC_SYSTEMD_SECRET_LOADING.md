# KeePassXC systemd Secret Loading Solution

**Created:** 2025-12-01
**Status:** ✅ Implemented and Working
**Author:** Mitsio + Claude Code
**Project:** my-modular-workspace

---

## Problem Statement

### Original Issue

Every time a new terminal was opened, `.bashrc` would call `secret-tool lookup` to retrieve the Anthropic API key from KeePassXC. This triggered a KeePassXC authorization prompt **every single time**, despite:
- `ConfirmAccessItem=true` being set (for security)
- `ShowNotification=true` being enabled
- The user wanting to keep these security features

### Root Cause

**KeePassXC does NOT have a "remember this application" feature** for Secret Service (FdoSecrets) access. This is a fundamental limitation of KeePassXC v2.7.x:

- Each `secret-tool lookup` call is treated as a new authorization request
- KeePassXC attempts to identify applications by executable path, but:
  - This fails for short-lived processes (like bash scripts)
  - The authorization decision is NOT persisted across requests
- Source: GitHub Issue #9255, fixed partially in v2.7.6+

---

## Solution: systemd User Environment Loading

### Architecture

Instead of loading secrets in `.bashrc` (which runs for EVERY terminal), we:

1. **Create a systemd user service** that runs ONCE after login
2. **Load secrets from KeePassXC** into the systemd user session environment
3. **All processes inherit** environment variables automatically

```
Login
  ↓
graphical-session.target starts
  ↓
load-keepassxc-secrets.service runs
  ↓
KeePassXC shows authorization prompt (ONE TIME!)
  ↓
User clicks "Allow" + checks "Show notification"
  ↓
Secrets loaded into systemd environment
  ↓
All terminals inherit ANTHROPIC_API_KEY automatically
  ↓
No more prompts until next login!
```

---

## Implementation

### File 1: `home-manager/keepassxc.nix`

Added new systemd user service:

```nix
systemd.user.services.load-keepassxc-secrets = {
  Unit = {
    Description = "Load secrets from KeePassXC to user session environment";
    After = [ "graphical-session.target" ];
    Wants = [ "graphical-session.target" ];
  };

  Service = {
    Type = "oneshot";
    RemainAfterExit = true;

    ExecStart = pkgs.writeShellScript "load-secrets.sh" ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Wait for KeePassXC Secret Service (max 30 seconds)
      echo "Waiting for KeePassXC Secret Service..."
      for i in {1..30}; do
        if ${pkgs.systemd}/bin/busctl --user status org.freedesktop.secrets >/dev/null 2>&1; then
          echo "✓ Secret Service available"
          break
        fi
        sleep 1
      done

      # Verify KeePassXC is the provider (not KDE Wallet)
      if ! ${pkgs.systemd}/bin/busctl --user status org.freedesktop.secrets 2>/dev/null | grep -q keepassxc; then
        ${pkgs.libnotify}/bin/notify-send -u critical \
          "KeePassXC Secret Loading Failed" \
          "KeePassXC is not providing Secret Service"
        exit 1
      fi

      # Load Anthropic API key (triggers authorization prompt)
      ANTHROPIC_API_KEY=$(${pkgs.libsecret}/bin/secret-tool lookup service anthropic key apikey 2>/dev/null || true)

      if [ -n "$ANTHROPIC_API_KEY" ]; then
        ${pkgs.systemd}/bin/systemctl --user set-environment ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
        echo "✓ Loaded ANTHROPIC_API_KEY"
      fi

      # Load GitHub PAT
      GITHUB_PAT=$(${pkgs.libsecret}/bin/secret-tool lookup service github key pat 2>/dev/null || true)

      if [ -n "$GITHUB_PAT" ]; then
        ${pkgs.systemd}/bin/systemctl --user set-environment GITHUB_PAT="$GITHUB_PAT"
        echo "✓ Loaded GITHUB_PAT"
      fi

      # Success notification
      ${pkgs.libnotify}/bin/notify-send -i keepassxc \
        "KeePassXC Secrets Loaded" \
        "API keys available in all terminals"
    '';
  };

  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
```

### File 2: `dotfiles/dot_bashrc.tmpl`

Simplified to just export the variables (they're already set by systemd):

```bash
# ============================================================================
# API KEYS FROM KEEPASSXC (Phase 3 - systemd Environment Integration)
# ============================================================================
# Secrets are loaded into systemd user environment at login by the
# 'load-keepassxc-secrets.service'. All terminals inherit them automatically.
#
# Manage secrets:
#   systemctl --user status load-keepassxc-secrets
#   systemctl --user show-environment | grep ANTHROPIC
#   systemctl --user restart load-keepassxc-secrets

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  export ANTHROPIC_API_KEY
fi

if [ -n "${GITHUB_PAT:-}" ]; then
  export GITHUB_PAT
fi
```

### File 3: `dotfiles/dot_config/keepassxc/keepassxc.ini`

Ensured proper FdoSecrets settings:

```ini
[FdoSecrets]
Enabled=true
ConfirmAccessItem=true
ShowNotification=true
```

---

## User Experience

### Login Flow

1. **User logs into KDE Plasma**
2. ~2-3 seconds after graphical session starts
3. **KeePassXC shows authorization dialog** for `load-secrets.sh`
   - Title: "An application requested access to the wallet"
   - Application: `/nix/store/.../load-secrets.sh`
   - Entry: "Anthropic" (and "GitHub-PAT")
4. **User clicks:**
   - ✅ "Allow" button
   - ✅ (Optional) "Remember authorization" (if available in KeePassXC UI)
5. **Notification appears:** "KeePassXC Secrets Loaded - API keys available in all terminals"
6. **Done!** All future terminals have the secrets automatically

### Terminal Usage

```bash
# Open ANY terminal (Kitty, Konsole, etc.)
$ echo $ANTHROPIC_API_KEY
sk-ant-api03-Ck5de0J...

# No prompts! The variable is already set!
```

---

## Management Commands

### Check Service Status

```bash
systemctl --user status load-keepassxc-secrets.service
```

Expected output:
```
● load-keepassxc-secrets.service - Load secrets from KeePassXC to user session environment
     Loaded: loaded
     Active: active (exited)
    Process: ExecStart=.../load-secrets.sh (code=exited, status=0/SUCCESS)
```

### View Loaded Secrets

```bash
systemctl --user show-environment | grep -E "(ANTHROPIC|GITHUB)"
```

### Reload Secrets (after changing KeePassXC entry)

```bash
systemctl --user restart load-keepassxc-secrets.service
```

This will trigger a new authorization prompt and reload the secrets.

### Clear Secrets (logout/security)

```bash
systemctl --user unset-environment ANTHROPIC_API_KEY
systemctl --user unset-environment GITHUB_PAT
```

Or just log out (systemd clears environment automatically).

### View Service Logs

```bash
journalctl --user -u load-keepassxc-secrets.service -f
```

---

## Security Analysis

### Threat Model

| Threat | Risk Level | Mitigation |
|--------|------------|-----------|
| Physical access to running system | HIGH | Secrets readable by user processes - same as before |
| Process inspection (`/proc/$PID/environ`) | MEDIUM | Any user process can read - acceptable for single-user desktop |
| Persistence after logout | NONE | systemd clears environment on logout ✅ |
| Network exposure | NONE | Environment variables not transmitted ✅ |
| Accidental logging | LOW | Secrets not in bash history or shell scripts ✅ |

### Comparison with Alternatives

| Approach | Prompts per Session | Security | Complexity | Auditability |
|----------|---------------------|----------|------------|--------------|
| **systemd environment** | 1 (at login) | Medium | Low | High |
| tmpfs cache (previous) | 1 (first terminal) | Medium | Medium | Medium |
| Lazy loading (on-demand) | N (per command) | High | Low | Low |
| No secrets (manual copy) | 0 | Highest | Lowest | None |

**Choice:** systemd environment provides the best balance of security and convenience.

---

## Testing & Verification

### Test 1: Service Runs at Login

1. Log out and log back in
2. Wait 5-10 seconds
3. Check service status:
   ```bash
   systemctl --user status load-keepassxc-secrets.service
   ```
4. Expected: `Active: active (exited)` with `status=0/SUCCESS`

### Test 2: Secrets Available in All Terminals

1. Open Kitty terminal:
   ```bash
   echo ${ANTHROPIC_API_KEY:0:20}...
   ```
2. Open Konsole terminal:
   ```bash
   echo ${ANTHROPIC_API_KEY:0:20}...
   ```
3. Both should show the same secret prefix without prompts

### Test 3: Authorization Prompt Shown ONCE

1. Log out completely
2. Log back in
3. Count authorization prompts: **Exactly 1** (for both Anthropic + GitHub entries)
4. Open 5 terminals → **0 additional prompts**

### Test 4: Secrets Cleared on Logout

1. Before logout:
   ```bash
   systemctl --user show-environment | grep ANTHROPIC
   # Should show: ANTHROPIC_API_KEY=sk-ant-...
   ```
2. Log out and log back in
3. Service runs again, prompts again (expected behavior)

---

## Troubleshooting

### Issue: Service fails to start

**Check:**
```bash
journalctl --user -u load-keepassxc-secrets.service -n 50
```

**Common causes:**
- KeePassXC not running / database locked
  - Solution: Unlock KeePassXC before service runs
- KDE Wallet conflicts
  - Solution: Verify `~/.config/kwalletrc` has `Enabled=false`
- Wrong Secret Service provider
  - Check: `busctl --user status org.freedesktop.secrets | grep -i keepass`

### Issue: Secrets not available in terminals

**Check:**
```bash
systemctl --user show-environment | grep ANTHROPIC
```

If empty:
1. Check service status (should be `active (exited)`)
2. Check service logs for errors
3. Verify entries exist in KeePassXC with correct attributes:
   - Service: `anthropic`
   - Key: `apikey`

### Issue: Still getting authorization prompts

**Possible causes:**
1. **Service didn't run** - Check `systemctl --user status load-keepassxc-secrets`
2. **Terminals started BEFORE service** - Restart terminals after login
3. **Different user session** - Secrets only available in the session where service ran

---

## Future Enhancements

### Optional: Auto-Unlock KeePassXC Database

For maximum automation (security trade-off!):

1. Use `keepassxc --pw-stdin` with a key file
2. Store key file on encrypted `/home` partition
3. Auto-unlock database at login via systemd service

**Not implemented** - Current solution requires manual unlock, which is more secure.

### Optional: Multiple Databases

If you have separate databases (work vs personal):

1. Create separate services: `load-work-secrets.service`, `load-personal-secrets.service`
2. Each loads from different `.kdbx` file
3. Prefix environment variables: `WORK_ANTHROPIC_API_KEY`, `PERSONAL_GITHUB_PAT`

---

## Related Documentation

- [KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md](./KEEPASSXC_MODULAR_WORKSPACE_INTEGRATION.md) - Phase 1 & 2 implementation
- [KEEPASSXC_INTEGRATION_PLAN.md](../plans/KEEPASSXC_INTEGRATION_PLAN.md) - Original plan and phases
- [ADR-005: KeePassXC as Central Secret Manager](../adrs/ADR-005-KEEPASSXC_AS_CENTRAL_SECRET_MANAGER.md) *(to be created)*

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2025-12-01 | **Phase 3 Complete**: systemd environment loading implemented | Mitsio + Claude Code |
| 2025-12-01 | Resolved authorization prompt issue with systemd approach | Mitsio + Claude Code |
| 2025-11-30 | Phase 1-2 completed (FdoSecrets + chezmoi integration) | Mitsio + Claude Code |

---

**Document Version:** 1.0
**Last Updated:** 2025-12-01
**Next Review:** After 1 week of usage (2025-12-08)
