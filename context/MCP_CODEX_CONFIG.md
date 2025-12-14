# MCP & Codex Configuration Snapshot (Dec 14, 2025)

This file summarizes the current Model Context Protocol (MCP) and Codex CLI settings so another session can
recreate the environment quickly.

## Codex CLI (`dotfiles/private_dot_codex/config.toml.tmpl`)

- **Model**: `gpt-5.1-codex`
- **Sandbox**: `danger-full-access`
- **Profiles**:
  - `default` → full access (unified_exec, streamable_shell, rmcp_client, ghost_commit enabled)
  - `safe_sandbox` → `sandbox_mode = "workspace-write"` for restricted runs
- **Features**:
  - `unified_exec = true`
  - `streamable_shell = true`
  - `rmcp_client = true`
  - `ghost_commit = true`
  - `project_doc_max_bytes = 16777216` (16 MiB)
- **MCP Startup Tweaks**:
  - `server-fetch` args cleared (no invalid `--max-length`)
  - Optional `[mcp_servers.fetch] startup_timeout_sec` can be added if needed.

## Claude Code MCP (`dotfiles/private_dot_claude/mcp_config.json.tmpl`)

- Mirrors the Codex server list (fetch, read-website-fast, time, context7, sequential-thinking, firecrawl,
  exa, brave-search, ast-grep, ck, claude-continuity, filesystem, shell, git, plus upstream Python servers).
- All commands point at `~/.nix-profile/bin/mcp-*` wrappers packaged via Home-Manager.

## Shell Environment (`dotfiles/dot_bashrc.d/20-systemd-session-env.sh`)

- Imports `DBUS_SESSION_BUS_ADDRESS` and `XDG_RUNTIME_DIR` from `systemctl --user show-environment`.
- Falls back to `/run/user/$(id -u)` if the user bus isn’t exported yet.
- Ensures MCP wrappers that rely on `systemd-run --user` have the session bus available.

## MCP Wrapper Behavior (`home-manager/mcp-servers/*`)

- All wrapper helpers (`python-custom.nix`, `npm-custom.nix`, `go-custom.nix`, `rust-custom.nix`,
  `from-flake.nix`) now:
  - `set -euo pipefail`
  - Detect missing D-Bus variables and fall back to running the MCP binary directly (no `systemd-run`),
    logging a warning.
  - Otherwise, they continue to launch within `systemd-run --user --scope` with resource limits.

## Re-applying Configurations

1. `chezmoi apply --source ~/.MyHome/MySpaces/my-modular-workspace/dotfiles`
2. `cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager && home-manager switch --flake .#mitsio@shoshin`
3. Restart Codex/Claude so the new configs and wrappers load.

This file should be updated whenever major Codex/MCP changes occur.
