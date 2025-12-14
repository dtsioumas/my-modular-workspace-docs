# Secrets Management (KeePassXC + systemd)

This document supplements ADR-011 with implementation details, best practices, and optional hardening steps.

## Optional Hardening

- **Per-tool runtime files:** Instead of exporting secrets as systemd environment variables, loader services can write the secret to `$XDG_RUNTIME_DIR/<tool>/<secret>` with `chmod 600` and only processes that explicitly open those files will see the secret. This gives finer-grained control at the cost of more per-tool plumbing.
- **Auto-lock + manual reload:** Configure KeePassXC to auto-lock on screen lock and require the user to re-run `reload-keepassxc-secrets.sh` after unlocking. This reduces the window of exposure if untrusted code runs later in the session.

## Current Secret Matrix (excerpt)

| Tool / Service | KeePassXC attributes | Runtime exposure |
|----------------|----------------------|------------------|
| Dropbox API / scripts | `service=dropbox`, `key=token` | `DROPBOX_ACCESS_TOKEN` (systemd env + dbus sync) |
| rclone (encrypted config) | `service=rclone`, `key=configpassword` | `RCLONE_CONFIG_PASS` env + `RCLONE_PASSWORD_COMMAND` fallback |

(Full contents to be expanded as the strategy evolves.)
