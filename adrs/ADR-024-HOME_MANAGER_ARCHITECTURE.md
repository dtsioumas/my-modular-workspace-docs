# ADR-024: Home Manager Architecture and Decoupling

## Status
Accepted

## Context
The previous home-manager configuration was tightly coupled to the user "mitsio" and specific paths, making it difficult to test in CI or adapt to new users/environments. Additionally, hardware-specific configurations were mixed with general settings.

## Decision
1.  **Dynamic User Configuration:** `flake.nix` and `home.nix` MUST NOT hardcode usernames or home directories in a way that prevents overriding. The configuration must derive these from the execution context or explicit but flexible arguments.
2.  **Hardware Decoupling:** Hardware-specific settings (CPU flags, GPU drivers) MUST be isolated in `profiles/hardware/<hostname>.nix`.
3.  **Overlay Pattern:** Runtimes (Node.js, Python, Bun) requiring optimization MUST be customized via Overlays that consume the `hardwareProfile`. They MUST NOT be defined directly in module files.
4.  **Dream2nix Integration:** All source-based packages (e.g. from git inputs) MUST be built using `dream2nix` to ensure reproducible, lock-file based builds without manual hash management.
5.  **Pre-built Binaries:** Proprietary or heavy GUI apps (Obsidian, VSCodium) MUST be installed from `nixpkgs` (cached) and wrapped for optimization, NOT built from source via `dream2nix`.

## Consequences
- **Positive:** Cleaner code, easier to add new hosts/users, clear separation of concerns.
- **Negative:** Slightly more complex `flake.nix` structure (passing arguments).
