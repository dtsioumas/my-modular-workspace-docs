# Local MCP Servers Registry

This directory contains documentation for all Model Context Protocol (MCP) servers installed locally in the workspace.

## Architecture (ADR-010)

All MCP servers are managed declaratively via **Home Manager** in the `home-manager/mcp-servers/` directory. They are exposed as systemd-isolated wrapper scripts in `~/.nix-profile/bin/`.

## Installed Servers

| Server | Wrapper Name | Type | Source | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Context7** | `mcp-context7` | Flake | `natsukium/mcp-servers-nix` | Library documentation & code examples |
| **Sequential Thinking** | `mcp-sequential-thinking` | Flake | `natsukium/mcp-servers-nix` | Deep reasoning & dynamic problem solving |
| **Fetch** | `mcp-fetch` | Flake | `natsukium/mcp-servers-nix` | Web content fetching (headless) |
| **Time** | `mcp-time` | Flake | `natsukium/mcp-servers-nix` | Timezone & current time utilities |
| **Shell** | `mcp-shell` | Go | `sonirico/mcp-shell` | Secure shell command execution |
| **Git** | `mcp-git` | Go | `geropl/git-mcp-go` | Git repository operations |
| **Filesystem (Go)** | `mcp-filesystem` | Go | `mark3labs/mcp-filesystem-server` | Local filesystem operations (Go impl) |
| **Filesystem (Rust)** | `mcp-filesystem-rust` | Rust | `modelcontextprotocol/servers` | Local filesystem operations (Rust impl) |
| **Firecrawl** | `mcp-firecrawl` | NPM | `firecrawl/firecrawl-mcp-server` | Advanced web scraping & crawling |
| **Read Website Fast** | `mcp-read-website-fast` | NPM | `just-every/mcp-read-website-fast` | Token-efficient website reading |
| **Brave Search** | `mcp-brave-search` | NPM | `mikechao/brave-search-mcp` | Web, image, video & news search |
| **Exa Search** | `mcp-exa` | NPM | `exa-labs/exa-mcp-server` | AI-powered semantic web search |
| **Claude Continuity** | `mcp-claude-continuity` | Python | `peless/claude-thread-continuity` | Session persistence & context restoration |
| **Ast-Grep** | `mcp-ast-grep` | Python | `ast-grep/ast-grep-mcp` | Structural code search & replacement |
| **CK Search** | `mcp-ck` | Rust | `BeaconBay/ck` | Semantic & hybrid code search (RAG) |

## Configuration

Servers are configured in `dotfiles/.chezmoitemplates/mcp/*.json.tmpl` and injected into agent configurations (Claude, Codex, Gemini).
