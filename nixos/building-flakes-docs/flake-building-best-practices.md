# NixOS Flake Building Best Practices

## Overview
This document provides comprehensive best practices for building and managing flakes in NixOS, compiled from official documentation and community resources.

## Core Concepts

### 1. Flake Structure
A Nix flake consists of:
- **inputs**: External dependencies (nixpkgs, other flakes)
- **outputs**: What your flake produces (packages, NixOS configurations, overlays)

### 2. Package Management Strategies

#### Using Unstable Packages
When you need newer packages not available in stable:
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
};
```

#### Creating Overlays
Overlays modify existing packages or add new ones:
```nix
nixpkgs.overlays = [
  (final: prev: {
    customPackage = prev.package.override {
      # custom settings
    };
  })
];
```

## Best Practices

### 1. Modular Configuration
- Separate concerns into different modules
- Use imports for organization
- Keep hardware-specific config separate

### 2. Version Pinning
- Lock flake inputs with `flake.lock`
- Use specific commits when stability is crucial
- Document why specific versions are pinned

### 3. Overlay Usage
- Use overlays for small modifications
- Create separate pkgs instances for major changes
- Avoid global overlays that trigger mass rebuilds

### 4. Custom Packages

#### When Package Exists in Nixpkgs
If a package exists (like warp-terminal), use it directly:
```nix
environment.systemPackages = with pkgs; [
  warp-terminal  # from stable
];

# Or from unstable
environment.systemPackages = [
  unstable.warp-terminal  # from unstable channel
];
```

#### When Creating Custom Packages
For packages not in nixpkgs:
```nix
# Create a derivation
customPackage = pkgs.stdenv.mkDerivation {
  pname = "custom-package";
  version = "1.0.0";
  src = fetchFromGitHub { ... };
  buildInputs = [ ... ];
  installPhase = '' ... '';
};
```

### 5. Testing Changes
- Use `nixos-rebuild test` before `switch`
- Keep generations for rollback
- Test in VM first for major changes

## Common Patterns

### Adding Unfree Software
Many proprietary applications require:
```nix
nixpkgs.config.allowUnfree = true;
```

### Cross-compilation
For different architectures:
```nix
nixpkgs.crossSystem = {
  config = "aarch64-unknown-linux-gnu";
};
```

### Development Shells
Create isolated development environments:
```nix
devShells.default = pkgs.mkShell {
  buildInputs = [ ... ];
};
```

## References
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- NixOS & Flakes Book: https://nixos-and-flakes.thiscute.world/
- Nixpkgs Manual: https://nixos.org/manual/nixpkgs/stable/
- NixOS Wiki: https://wiki.nixos.org/

## Key Takeaways
1. Always check nixpkgs first before building custom packages
2. Use overlays sparingly to avoid cache invalidation
3. Keep configurations modular and well-documented
4. Test changes incrementally
5. Leverage existing community flakes when possible