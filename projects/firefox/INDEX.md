# Project: Firefox Declarative Configuration

**Status:** ACTIVE
**Goal:** Fully declarative, hardened, and optimized Firefox configuration via Home-Manager.

## Documentation Index

- [**RESEARCH.md**](RESEARCH.md): Deep research into Firefox's `about:config`, user.js, and policies.json for NixOS. Includes extension mapping and security hardening.
- [**PLAN.md**](PLAN.md): Implementation plan for declarative extensions, profile management, and critical fixes for Wayland/KDE integration.

## Key Features
- **Declarative Extensions**: All extensions managed via Nix flakes to ensure consistency across machines.
- **Hardware Acceleration**: Optimized for Wayland and NVIDIA GPU offloading.
- **Privacy Hardened**: Pre-configured with Arkenfox-inspired security baselines.
- **MCP Integration**: Research into connecting Firefox to the Model Context Protocol.

## Related Resources
- **Nix Module**: `home-manager/modules/apps/browsers/firefox.nix`
- **Policies Guide**: `docs/adrs/ADR-024-LANGUAGE-RUNTIME-HARDWARE-OPTIMIZATIONS.md`
