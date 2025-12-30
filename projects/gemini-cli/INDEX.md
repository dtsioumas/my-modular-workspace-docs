# Project: Gemini CLI Integration & Optimization

**Status:** ACTIVE
**Goal:** Integrate Google's Gemini CLI into the workspace with secure authentication and optimized resource usage.

## Documentation Index

- [**RESEARCH.md**](RESEARCH.md): Research into Gemini CLI's MCP integration, codebase investigator capabilities, and token caching.
- [**PLAN.md**](PLAN.md): Corrected installation plan using Nix-managed MCP servers and secure Google Cloud authentication.
- [**USAGE.md**](USAGE.md): Practical guide for using Gemini CLI for codebase analysis and research.

## Key Features
- **Codebase Investigator**: High-performance semantic indexing for large repositories.
- **Secure Authentication**: Integration with Google Cloud (gcloud) instead of insecure raw API keys.
- **MCP Native**: Leveraging the Model Context Protocol for tool execution.

## Related Resources
- **Nix Module**: `home-manager/modules/ai/gemini-cli.nix`
- **Secrets Management**: `ADR-011-UNIFIED_SECRETS_MANAGEMENT_VIA_KEEPASSXC.md`
