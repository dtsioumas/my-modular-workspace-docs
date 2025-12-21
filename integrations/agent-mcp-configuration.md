# Agent MCP Configuration Strategy

This document outlines how MCP servers are configured for different agents in the workspace. Configuration is centralized using **Chezmoi templates** to ensure consistency across agents (Claude, Codex, Gemini, Warp).

## Template Structure

Templates are located in `dotfiles/.chezmoitemplates/mcp/`. Each file represents one MCP server configuration block.

| Template | Server | Description |
| :--- | :--- | :--- |
| `ck.json.tmpl` | `mcp-ck` | Semantic code search |
| `context7.json.tmpl` | `mcp-context7` | Library docs |
| `filesystem-go.json.tmpl` | `mcp-filesystem` | Go filesystem server |
| `filesystem-rust.json.tmpl` | `mcp-filesystem-rust` | Rust filesystem server |
| `git.json.tmpl` | `mcp-git` | Git operations |
| `shell.json.tmpl` | `mcp-shell` | Shell execution |
| ... | ... | (See `docs/tools/local-mcp-servers/` for full list) |

## Agent Configurations

### 1. Claude Desktop & CLI
**Config File:** `~/.config/Claude/claude_desktop_config.json`
**Template:** `dotfiles/private_dot_config/Claude/claude_desktop_config.json.tmpl`

Uses the standard JSON format with imports from `.chezmoitemplates`.

```json
"mcpServers": {
  {{ template "mcp/fetch.json.tmpl" . }},
  {{ template "mcp/time.json.tmpl" . }},
  ...
}
```

### 2. Gemini CLI
**Config File:** `~/.gemini/settings.json`
**Template:** `dotfiles/private_dot_gemini/settings.json.tmpl`

Follows the standard MCP configuration format similar to Claude.

### 3. OpenAI Codex (CLI)
**Config File:** `~/.codex/config.toml`
**Template:** `dotfiles/private_dot_codex/config.toml.tmpl`

Uses TOML format. Templates are NOT used directly here because TOML syntax differs from JSON. Instead, the configuration is written explicitly in the TOML template, mirroring the values in the JSON templates.

```toml
[mcp_servers.fetch]
command = "{{ $home }}/.nix-profile/bin/mcp-fetch"
args = []
```

### 4. Warp Terminal
**Config File:** `~/.config/warp-terminal/mcp_servers.json` (Snippet)
**Template:** `dotfiles/private_dot_config/warp-terminal/mcp_servers.json.tmpl`

Generates a JSON snippet that can be pasted into Warp's settings manually (until Warp supports config files).

## Adding a New Server

1.  **Package it:** Add definition to `home-manager/mcp-servers/` (go/npm/python/rust-custom.nix).
2.  **Create Wrapper:** Ensure `mkMcpWrapper` is called to create `~/.nix-profile/bin/mcp-<name>`.
3.  **Create Template:** Create `dotfiles/.chezmoitemplates/mcp/<name>.json.tmpl`.
4.  **Update Agents:**
    *   Add `{{ template ... }}` to Claude/Warp templates.
    *   Add `[mcp_servers.<name>]` block to Codex TOML template.
    *   Add JSON block to Gemini template.
5.  **Apply:** Run `home-manager switch` and `chezmoi apply`.
