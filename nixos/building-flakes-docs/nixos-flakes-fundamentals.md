# NixOS Flakes Fundamentals

## What are Flakes?

Flakes are the modern way to manage Nix packages and NixOS configurations. They provide:
- **Reproducibility**: Lock files ensure consistent builds across systems
- **Composability**: Easy to combine multiple flakes
- **Discoverability**: Standard structure makes projects easier to understand

## Core Components

### 1. flake.nix
The main configuration file that defines:
- **inputs**: Dependencies (other flakes, nixpkgs, etc.)
- **outputs**: What the flake produces (packages, NixOS configurations, etc.)

### 2. flake.lock
Auto-generated file that pins exact versions of all inputs for reproducibility.

## Basic Structure

```nix
{
  description = "A flake description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Other inputs...
  };

  outputs = { self, nixpkgs, ... }: {
    # NixOS configurations
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
    
    # Packages
    packages.x86_64-linux.default = ...;
    
    # Development shells
    devShells.x86_64-linux.default = ...;
  };
}
```

## Key Concepts

### Inputs
- Define external dependencies
- Can be other flakes, git repositories, or tarballs
- Automatically locked in flake.lock

### Outputs
- Function that takes inputs and produces derivations
- Common output types:
  - `nixosConfigurations`: NixOS system configurations
  - `packages`: Installable packages
  - `devShells`: Development environments
  - `overlays`: Package set modifications

### Special Arguments
- Pass additional arguments to modules
- Common uses:
  - Pass flake inputs to modules
  - Share configuration between modules

## References
- https://nixos.wiki/wiki/Flakes
- https://github.com/ryan4yin/nixos-and-flakes-book
- https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html
