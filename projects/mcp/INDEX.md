# Project: MCP Server Architecture & Optimization

**Status:** ACTIVE
**Goal:** Build a robust, high-performance, and secure Model Context Protocol (MCP) server ecosystem.

## Documentation Index

- [**RESEARCH.md**](RESEARCH.md): Consolidated research on Connection Pooling (10-80x throughput), Bun runtime migration (50% memory savings), and Nix packaging for servers.
- [**PLAN.md**](PLAN.md): Implementation roadmap for Bun migration, Systemd isolation, and Warp/Kitty integration.
- [**USAGE.md**](USAGE.md): Installation guide and tool descriptions for all 14+ MCP servers.

## Key Optimizations
- **Bun Runtime**: Migrated high-memory servers (context7, firecrawl) to Bun for significant RAM savings.
- **Connection Pooling**: Implementation of `generic-pool` and `pqueue` for HTTP-based servers.
- **Systemd Isolation**: Per-server resource limits (MemoryMax, CPUQuota) via standard Nix modules.
- **Secure Transport**: Migration from stdio to SSE where appropriate for multi-client access.

## Related Resources
- **Nix Modules**: `home-manager/modules/mcp-servers/`
- **Architecture ADR**: `docs/adrs/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md`
- **Monitoring Guide**: `docs/MCP_MONITORING_GUIDE.md`
