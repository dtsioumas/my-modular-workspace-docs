# Home-Manager Documentation

This directory contains documentation for the **user environment**, which is managed by Home-Manager. These configurations are designed to be portable and should work on any Linux distribution with Nix installed.

## Key Documents

### Architecture & Strategy
- **[Decoupling Architecture](./decoupling-architecture.md):** The target architecture for using a standalone Home-Manager flake, separate from the base NixOS system.
- **[Migration](./migration.md):** A consolidated guide detailing the migration from the old monolithic NixOS configuration to the current decoupled Home-Manager setup.
- **[Ephemerality Strategy](./ephemeral.md):** The plan and principles for achieving an ephemeral, fully reproducible home environment.

### Features & Implementation
- **[Node2Nix for NPM Packages](./node2nix.md):** A guide on how `node2nix` is used to manage NPM packages declaratively.
- **[Git Hooks Integration](./git-hooks-integration.md):** Documentation for the pre-commit hook setup.
- **[Symlink Management](./SYMLINK-QUICK-REFERENCE.md):** A quick reference for how symlinks are managed declaratively.
- **[Symlink Research](./symlink-research.md):** Research notes on different declarative symlink tools.

### Maintenance
- **[Debugging and Maintenance](./DEBUGGING_AND_MAINTENANCE.md):** A guide for debugging `home-manager build` failures.
- **[Deprecation Fixes](./DEPRECATION_FIXES.md):** Notes on fixing deprecated options as the Nix ecosystem evolves.
- **[MCP Servers Installation](./MCP_SERVERS_INSTALLATION.md):** A guide on how to install and setup the MCP servers.