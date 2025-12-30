# Issue: Shoshin Workspace KeePassXC Secret Service Failure
**Date:** 2025-12-13
**Status:** RESOLVED

## Problem
The KeePassXC Secret Service integration was not consistently available, causing a cascade of failures:
- Systemd services (like `gdrive-sync`) failed to load secrets.
- Chezmoi templates using `keepassxcAttribute` failed during non-interactive runs.
- API keys (ANTHROPIC, DROPBOX) were denied access due to configuration drift or lack of authorization.

## Resolution
1. **KeePassXC Fix:**
   - Started the main KeePassXC application and unlocked the vault manually.
   - Re-enabled Secret Service Integration in **Database Security** settings.
   - Removed "Deny" rules for the affected API keys.
2. **Service Recovery:**
   - Restarted `load-keepassxc-secrets.service` to re-populate the systemd environment.
   - Restarted `gdrive-sync.service` and health check services.
3. **Chezmoi Mitigation:**
   - Restored configuration drift (Kitty, Zellij, Mimeapps) using `chezmoi apply --force`.
   - Identified the TTY limitation of `keepassxcAttribute` and recommended `secret-tool` for non-interactive context.

## Prevention
- Ensure KeePassXC autostarts with the session.
- Use `secret-tool lookup` in templates intended for automated/background runs.
- Periodically run `chezmoi diff` to detect configuration drift early.
