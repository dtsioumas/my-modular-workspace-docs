# Building Custom Nix Flakes and Packages

## When to Build a Custom Package

Build a custom package when:
- The package doesn't exist in nixpkgs (stable or unstable)
- You need a specific version/fork not available
- You need custom patches or modifications
- The package requires special build configurations

## Basic Package Structure

### Using stdenv.mkDerivation

The fundamental building block for packages in Nix:

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

  nativeBuildInputs = [ 
    cmake 
    pkg-config 
  ];

  buildInputs = [ 
    # Runtime dependencies
  ];

  meta = with lib; {
    description = "Short description";
    homepage = "https://example.com";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
```

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

## Creating a Flake for Custom Package

### Basic Flake Structure

```nix
# flake.nix
{
  description = "My custom package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.packages.${system}.my-package;
          
          my-package = pkgs.callPackage ./package.nix { };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Development tools
          ];
        };
      });
}
```

### Adding to NixOS Configuration

```nix
# In your system flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    my-package.url = "github:username/my-package-flake";
  };

  outputs = { self, nixpkgs, my-package, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            my-package.packages.x86_64-linux.default
          ];
        })
      ];
    };
  };
}
```

## Complex Build Examples

### Rust Application

```nix
{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = version;
    sha256 = "sha256-...";
  };

  cargoSha256 = "sha256-...";

  meta = with lib; {
    description = "A Rust application";
    homepage = "https://example.com";
    license = licenses.mit;
  };
}
```

### Python Application

```nix
{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonApplication rec {
  pname = "python-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = version;
    sha256 = "sha256-...";
  };

  propagatedBuildInputs = with python3Packages; [
    requests
    click
  ];

  meta = with lib; {
    description = "A Python application";
    homepage = "https://example.com";
    license = licenses.mit;
  };
}
```

### Node.js Application

```nix
{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "node-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = version;
    sha256 = "sha256-...";
  };

  npmDepsHash = "sha256-...";

  meta = with lib; {
    description = "A Node.js application";
    homepage = "https://example.com";
    license = licenses.mit;
  };
}
```

## Testing Your Package

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

## Best Practices Summary

1. **Start Simple**: Begin with basic stdenv.mkDerivation
2. **Use Existing Builders**: rustPlatform, buildPythonApplication, etc.
3. **Pin Dependencies**: Use specific commits/tags
4. **Test Locally**: Before pushing to repository
5. **Document Well**: Include clear descriptions and usage
6. **Follow Conventions**: Use standard Nix naming and structure
7. **Handle Licenses**: Specify correct license information
8. **Consider Platforms**: Test on target platforms

## Resources

- Nix Pills (packaging tutorial): https://nixos.org/guides/nix-pills/
- Nixpkgs Manual: https://nixos.org/manual/nixpkgs/stable/
- NixOS Wiki Packaging: https://wiki.nixos.org/wiki/Packaging
- Example packages in nixpkgs: https://github.com/NixOS/nixpkgs