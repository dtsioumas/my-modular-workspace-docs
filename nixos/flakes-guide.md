# NixOS Flakes Guide

**Last Updated:** 2025-11-29
**Sources Merged:** nixos-flakes-fundamentals.md, flake-building-best-practices.md, custom-package-building-guide.md, INSTRUCTIONS.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Fundamentals](#fundamentals)
- [Best Practices](#best-practices)
- [Building Custom Packages](#building-custom-packages)
- [Fetching Sources](#fetching-sources)
- [Build Phases](#build-phases)
- [Decision Tree](#decision-tree)
- [Implementation Workflow](#implementation-workflow)
- [Common Patterns](#common-patterns)
- [Testing & Debugging](#testing--debugging)
- [References](#references)

---

## Overview

Flakes are the modern way to manage Nix packages and NixOS configurations. They provide:
- **Reproducibility**: Lock files ensure consistent builds across systems
- **Composability**: Easy to combine multiple flakes
- **Discoverability**: Standard structure makes projects easier to understand

---

## Fundamentals

### Core Components

#### 1. flake.nix
The main configuration file that defines:
- **inputs**: Dependencies (other flakes, nixpkgs, etc.)
- **outputs**: What the flake produces (packages, NixOS configurations, etc.)

#### 2. flake.lock
Auto-generated file that pins exact versions of all inputs for reproducibility.

### Basic Structure

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

### Key Concepts

**Inputs:**
- Define external dependencies
- Can be other flakes, git repositories, or tarballs
- Automatically locked in flake.lock

**Outputs:**
- Function that takes inputs and produces derivations
- Common output types:
  - `nixosConfigurations`: NixOS system configurations
  - `packages`: Installable packages
  - `devShells`: Development environments
  - `overlays`: Package set modifications

**Special Arguments:**
- Pass additional arguments to modules
- Common uses: Pass flake inputs to modules, share configuration between modules

---

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

### 4. Package Management Strategies

**Using Unstable Packages:**
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
};
```

**Creating Overlays:**
```nix
nixpkgs.overlays = [
  (final: prev: {
    customPackage = prev.package.override {
      # custom settings
    };
  })
];
```

### 5. Testing Changes
- Use `nixos-rebuild test` before `switch`
- Keep generations for rollback
- Test in VM first for major changes

### Key Takeaways
1. Always check nixpkgs first before building custom packages
2. Use overlays sparingly to avoid cache invalidation
3. Keep configurations modular and well-documented
4. Test changes incrementally
5. Leverage existing community flakes when possible

---

## Building Custom Packages

### When to Build Custom
Build a custom package when:
- The package doesn't exist in nixpkgs (stable or unstable)
- You need a specific version/fork not available
- You need custom patches or modifications
- The package requires special build configurations

### Using stdenv.mkDerivation

```nix
{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "my-package";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "username";
    repo = "repository";
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    # Runtime dependencies
  ];

  meta = with lib; {
    description = "Short description";
    homepage = "https://example.com";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
```

### Language-Specific Builders

**Rust Application:**
```nix
rustPlatform.buildRustPackage rec {
  pname = "rust-app";
  version = "1.0.0";
  src = fetchFromGitHub { ... };
  cargoSha256 = "sha256-...";
}
```

**Python Application:**
```nix
python3Packages.buildPythonApplication rec {
  pname = "python-app";
  version = "1.0.0";
  src = fetchFromGitHub { ... };
  propagatedBuildInputs = with python3Packages; [ requests click ];
}
```

**Node.js Application:**
```nix
buildNpmPackage rec {
  pname = "node-app";
  version = "1.0.0";
  src = fetchFromGitHub { ... };
  npmDepsHash = "sha256-...";
}
```

---

## Fetching Sources

### Common Fetchers

```nix
# From GitHub
src = fetchFromGitHub {
  owner = "owner";
  repo = "repo";
  rev = "commit-or-tag";
  sha256 = "sha256-...";
};

# From URL
src = fetchurl {
  url = "https://example.com/package.tar.gz";
  sha256 = "sha256-...";
};

# From Git
src = fetchgit {
  url = "https://git.example.com/repo.git";
  rev = "commit";
  sha256 = "sha256-...";
};

# Tarball
src = fetchTarball {
  url = "https://example.com/archive.tar.gz";
  sha256 = "sha256-...";
};
```

### Getting SHA256 Hashes

```bash
# Method 1: Use nix-prefetch
nix-prefetch-github owner repo

# Method 2: Use fake hash and let Nix tell you
# Put "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
# Build will fail and show correct hash

# Method 3: Use nix hash
nix hash file ./downloaded-file
```

---

## Build Phases

Standard phases in order:
1. **unpackPhase**: Extract source
2. **patchPhase**: Apply patches
3. **configurePhase**: Run configure scripts
4. **buildPhase**: Compile the software
5. **checkPhase**: Run tests (if doCheck = true)
6. **installPhase**: Install to $out
7. **fixupPhase**: Fix paths, strip binaries

### Customizing Phases

```nix
{
  # Skip a phase
  dontConfigure = true;

  # Custom phase commands
  configurePhase = ''
    ./configure --prefix=$out
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp my-binary $out/bin/
  '';

  # Run custom commands before/after phases
  preBuild = ''
    export SOME_VAR=value
  '';

  postInstall = ''
    wrapProgram $out/bin/my-program \
      --set PATH ${lib.makeBinPath [ dependency ]}
  '';
}
```

---

## Decision Tree

```
START
│
├─ Does package exist in nixpkgs?
│  │
│  ├─ YES → Is it in stable channel?
│  │  │
│  │  ├─ YES → Add to environment.systemPackages
│  │  └─ NO → Check unstable channel
│  │     │
│  │     ├─ Available → Use unstable.package-name
│  │     └─ Not available → Build custom package
│  │
│  └─ NO → Search for existing flake
│     │
│     ├─ Found → Add as flake input
│     └─ Not found → Build custom flake
```

### Prerequisites Check

Before starting any flake project:
1. Verify Nix version: `nix --version` (should be 2.4+)
2. Ensure flakes enabled: Check `/etc/nix/nix.conf` for `experimental-features = nix-command flakes`
3. Identify target system architecture
4. Have internet connection for fetching dependencies

---

## Implementation Workflow

### Phase 1: Research and Discovery

```bash
# Search nixpkgs
nix search nixpkgs#package-name
nix search nixpkgs-unstable#package-name

# Check online: https://search.nixos.org/packages
# Search FlakeHub: https://flakehub.com/
```

### Phase 2: Package if Needed

```bash
# Create project structure
mkdir package-name-flake
cd package-name-flake
nix flake init
```

### Phase 3: Integration

**System-wide:**
```nix
# In your system flake.nix
inputs = {
  my-package.url = "github:username/my-package-flake";
};

outputs = { self, nixpkgs, my-package, ... }: {
  nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
    modules = [
      ({ pkgs, ... }: {
        environment.systemPackages = [
          my-package.packages.x86_64-linux.default
        ];
      })
    ];
  };
};
```

**User-level:**
```bash
nix profile install .#package-name
```

---

## Common Patterns

### Adding Unfree Software

```nix
nixpkgs.config.allowUnfree = true;
```

### Development Shells

```nix
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [ nodejs yarn ];
  shellHook = ''
    echo "Development environment ready"
  '';
};
```

### Binary-only Packages

```nix
# Use autoPatchelfHook for dynamic libraries
nativeBuildInputs = [ autoPatchelfHook ];
buildInputs = [ required-libraries ];
```

### Specific Version Override

```nix
(final: prev: {
  package = prev.package.overrideAttrs (old: rec {
    version = "specific-version";
    src = fetchFromGitHub { ... };
  });
})
```

---

## Testing & Debugging

### Local Testing

```bash
# Build the package
nix build .#my-package

# Test in shell
nix shell .#my-package -c my-command

# Enter development shell
nix develop

# Test installation
nix profile install .#my-package
```

### Debugging Build Issues

```bash
# Keep build directory for inspection
nix build --keep-failed

# Print debug output
nix build -L

# Enter build environment
nix develop
nix-shell -A my-package
```

### Verification Checklist

- [ ] Package builds without errors
- [ ] Binary/script is executable
- [ ] Dependencies are satisfied
- [ ] Works in clean environment
- [ ] Metadata is complete
- [ ] License is correctly specified
- [ ] Platform compatibility verified

---

## Troubleshooting

### SHA256 Mismatch
**Solution**: Use the hash Nix provides in error message

### Build Fails with Missing Dependency
**Solution**: Add to buildInputs or nativeBuildInputs

### Runtime Library Not Found
**Solution**: Use wrapProgram or patchelf

### Command Not Found After Installation
**Solution**: Check installPhase copies to $out/bin

---

## References

### Documentation
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- NixOS & Flakes Book: https://nixos-and-flakes.thiscute.world/
- Nixpkgs Manual: https://nixos.org/manual/nixpkgs/stable/
- NixOS Wiki: https://wiki.nixos.org/

### Search
- NixOS Packages: https://search.nixos.org/packages
- NixOS Options: https://search.nixos.org/options
- FlakeHub: https://flakehub.com/

### Tutorials
- Nix Pills: https://nixos.org/guides/nix-pills/
- NixOS Wiki Packaging: https://wiki.nixos.org/wiki/Packaging

---

*Migrated from docs/nixos/building-flakes-docs/ on 2025-11-29*
