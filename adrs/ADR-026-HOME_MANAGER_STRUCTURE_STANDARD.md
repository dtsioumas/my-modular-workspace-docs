# ADR-026: Home Manager Repository Structure and Standards

## Status
Accepted

## Context
The `home-manager` repository has grown organically, leading to a mix of root-level modules, `modules/` directory usage, and scattered configurations. This inconsistency makes it difficult to navigate, refactor, and decouple the configuration. We need a standardized structure to ensure maintainability and scalability.

## Decision
1.  **Modules Directory:** All configuration logic MUST reside in `modules/`.
    *   `modules/apps/`: Graphical applications (Obsidian, VSCodium, Browsers).
    *   `modules/cli/`: CLI tools (Atuin, Bat, Git, etc.).
    *   `modules/services/`: Systemd services and daemons (Syncthing, Rclone).
    *   `modules/desktop/`: Desktop environment settings (Hyprland, Plasma, Kitty).
    *   `modules/dev/`: Development languages and runtimes (Node, Python, Rust).
    *   `modules/agents/`: AI Agents and MCP servers.
    *   `modules/system/`: Core system settings (Nix config, Shell aliases, Variables).

2.  **Root Cleanliness:** The root directory MUST only contain:
    *   `flake.nix` & `flake.lock`
    *   `home.nix` (entry point)
    *   `README.md`
    *   Required hidden files (`.gitignore`, etc.)
    *   (Temporary) Legacy files during migration.

3.  **Dynamic Configuration:**
    *   Hardcoded usernames/paths are FORBIDDEN in modules. Use `config.home.username` or `config.home.homeDirectory`.
    *   Hardware-specific settings MUST be retrieved from `hardwareProfile` (passed via `specialArgs`).

4.  **Naming Convention:**
    *   Files should be named after the primary tool or service they configure (e.g., `modules/apps/firefox.nix`).
    *   Group related small configs into a directory with `default.nix` (e.g., `modules/cli/modern-unix-tools/default.nix`).

## Consequences
- **Positive:** Predictable location for configs, easier to share modules, cleaner root.
- **Negative:** Requires moving existing files and updating imports in `home.nix`.
