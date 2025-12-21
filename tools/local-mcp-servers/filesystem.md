# Filesystem MCP Servers

This workspace maintains two implementations of the Filesystem MCP server for comparison and fallback purposes.

## 1. Filesystem (Go)
**Wrapper:** `mcp-filesystem`
**Source:** [github.com/mark3labs/mcp-filesystem-server](https://github.com/mark3labs/mcp-filesystem-server)
**Implementation:** Go

### Capabilities
- Read files
- Write files
- List directories
- Move/Copy/Delete files
- Search (limited)

### Configuration
Defined in `home-manager/mcp-servers/go-custom.nix`.
Template: `dotfiles/.chezmoitemplates/mcp/filesystem-go.json.tmpl`

```json
"filesystem": {
  "command": "{{ .chezmoi.homeDir }}/.nix-profile/bin/mcp-filesystem",
  "args": [],
  "env": {}
}
```

---

## 2. Filesystem (Rust)
**Wrapper:** `mcp-filesystem-rust`
**Source:** [github.com/rust-mcp-stack/rust-mcp-filesystem](https://github.com/rust-mcp-stack/rust-mcp-filesystem)
**Implementation:** Rust

### Capabilities
- Read files
- Write files
- List directories
- Move/Copy/Delete files
- Allowed directory restriction (security)

### Configuration
Defined in `home-manager/mcp-servers/rust-custom.nix`.
Template: `dotfiles/.chezmoitemplates/mcp/filesystem-rust.json.tmpl`

```json
"filesystem-rust": {
  "command": "{{ .chezmoi.homeDir }}/.nix-profile/bin/mcp-filesystem-rust",
  "args": ["{{ .chezmoi.homeDir }}"],
  "env": {}
}
```
