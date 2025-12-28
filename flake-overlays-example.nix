# ==============================================================================
# Example flake.nix Overlays Section
# ==============================================================================
# Copy this section into your home-manager/flake.nix
#
# Location: Inside the pkgs definition, overlays list
# ==============================================================================

{
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      # Import hardware profile
      hardwareProfile = import ./profiles/hardware/shoshin.nix;

      # Create pkgs with overlays
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        # ===================================================================
        # OVERLAYS
        # ===================================================================
        overlays = [
          # ------------------------------------------------------------------
          # Existing Overlays (Keep These)
          # ------------------------------------------------------------------
          (import ./overlays/performance-critical-apps.nix hardwareProfile)
          (import ./overlays/codex-memory-limited.nix hardwareProfile)
          (import ./overlays/firefox-memory-optimized.nix hardwareProfile)
          (import ./overlays/onnxruntime-gpu-optimized.nix hardwareProfile)
          # (import ./overlays/rust-tier2-optimized.nix hardwareProfile)  # REPLACED by rust-hardware-optimized.nix

          # ------------------------------------------------------------------
          # NEW: Language Runtime Hardware Optimizations (ADR-024)
          # ------------------------------------------------------------------
          # Total build time: ~2-3.5 hours (one-time)
          # Total disk space: ~2.2GB
          # Performance gains: 3-30% depending on workload and runtime
          #
          # Status: Ready for integration (2025-12-28)
          # Research: docs/researches/nodejs-hardware-optimization-2025-12-28.md
          # Guide: docs/LANGUAGE_RUNTIMES_OPTIMIZATION_GUIDE.md
          # ADR: docs/adrs/ADR-024-LANGUAGE-RUNTIME-HARDWARE-OPTIMIZATIONS.md
          # ------------------------------------------------------------------

          # Node.js 24 LTS (Agents, MCP Servers, Build Tools)
          # Build: 20-45 minutes
          # Gain: 5-15% for CPU-bound workloads
          # Benefits: Claude Code, Gemini CLI, context7, npm/pnpm builds
          (import ./overlays/nodejs-hardware-optimized.nix hardwareProfile)

          # Go 1.24+ (CLI Tools, Services)
          # Build: 15-30 minutes
          # Gain: 3-10% for CPU-bound programs, 5-15% for CGO
          # Benefits: mcp-shell, git-mcp-go, yq-go, all Go CLI tools
          # Note: Enables GOAMD64=v3 (AVX2, BMI2) for all Go binaries
          (import ./overlays/go-hardware-optimized.nix hardwareProfile)

          # Rust (Compiler + All Rust Tools)
          # Build: 30-60 minutes
          # Gain: 5-12% for binaries, 5-10% for cargo compilation
          # Benefits: bat, ripgrep, fd, eza, zoxide, starship, zellij, atuin
          # Note: REPLACES rust-tier2-optimized.nix (keep this one, remove old)
          (import ./overlays/rust-hardware-optimized.nix hardwareProfile)

          # Python 3.13 (CPython Interpreter)
          # Build: 60-90 minutes (PGO FULL), 45min (LIGHT), 20min (NONE)
          # Gain: 10-30% (FULL), 10-15% (LIGHT), 2-8% (NONE)
          # Benefits: Python scripts, data processing, pip/poetry, Django/Flask
          # Note: PGO level configurable in hardware profile (default: FULL)
          (import ./overlays/python-hardware-optimized.nix hardwareProfile)

          # ------------------------------------------------------------------
          # End of Language Runtime Optimizations
          # ------------------------------------------------------------------
        ];
      };
    in {
      homeConfigurations.shoshin = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          # ... other modules
        ];
        extraSpecialArgs = {
          inherit hardwareProfile;
        };
      };
    };
}

# ==============================================================================
# Optional: Python PGO Level Configuration
# ==============================================================================
# Edit profiles/hardware/shoshin.nix to change Python build time:
#
#   packages = {
#     # ... existing packages ...
#
#     python313 = {
#       pgoLevel = "FULL";   # 90 min, 10-30% gain (default)
#       # pgoLevel = "LIGHT"; # 45 min, 10-15% gain
#       # pgoLevel = "NONE";  # 20 min, 2-8% gain (just compiler flags)
#     };
#   };
#
# ==============================================================================

# ==============================================================================
# Build Command (After Adding Overlays)
# ==============================================================================
# cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
#
# # Recommended: Run in tmux/screen (build takes 2-3.5 hours)
# tmux new-session -s build
# home-manager switch --flake .#shoshin
#
# # Monitor progress in another terminal:
# watch -n 5 'ps aux | grep -E "rustc|python|node|go" | grep -v grep'
#
# ==============================================================================
