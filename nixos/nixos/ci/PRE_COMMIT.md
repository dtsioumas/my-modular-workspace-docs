# Pre-Commit Hooks Setup for NixOS

**Last Updated:** 2025-11-23
**Tool:** cachix/git-hooks.nix
**Repository:** https://github.com/cachix/git-hooks.nix

## Overview

`git-hooks.nix` provides seamless integration of [pre-commit.com](https://pre-commit.com) hooks with Nix, offering:

- ✅ Trivial integration for Nix projects
- ✅ Low-overhead builds (no nix-shell latency)
- ✅ Common hooks for multiple languages
- ✅ Run hooks in development AND CI
- ✅ Support for alternative implementations (like `prek`)

## Installation Methods

### Method 1: Flakes (Recommended)

Add to your `flake.nix`:

```nix
{
  description = "NixOS configuration with pre-commit hooks";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = { self, nixpkgs, git-hooks, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Run hooks with `nix flake check`
      checks.${system}.pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # Format Nix code
          alejandra.enable = true;

          # Lint Nix code
          statix.enable = true;
          deadnix.enable = true;

          # Shell scripts
          shellcheck.enable = true;
          shfmt.enable = true;
        };
      };

      # Development shell with hooks
      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    };
}
```

**Usage:**

```bash
# Enter dev shell (hooks auto-install)
nix develop

# Run hooks manually
nix develop -c pre-commit run --all-files

# Run in CI (sandboxed)
nix flake check

# Format with hooks
nix fmt  # (if formatter configured)
```

**Important:** Add to `.gitignore`:
```gitignore
/.pre-commit-config.yaml
```

### Method 2: flake-parts

For projects using [flake-parts](https://flake.parts/):

```nix
{
  inputs = {
    git-hooks.url = "github:cachix/git-hooks.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.git-hooks.flakeModule
      ];

      perSystem = { config, ... }: {
        pre-commit.settings.hooks = {
          alejandra.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };

        devShells.default = pkgs.mkShell {
          shellHook = config.pre-commit.installationScript;
        };
      };
    };
}
```

### Method 3: Non-Flakes

**default.nix:**

```nix
let
  nix-pre-commit-hooks = import (builtins.fetchTarball
    "https://github.com/cachix/git-hooks.nix/tarball/master");
in {
  pre-commit-check = nix-pre-commit-hooks.run {
    src = ./.;
    hooks = {
      alejandra.enable = true;
      statix.enable = true;
      deadnix.enable = true;
    };
  };
}
```

**shell.nix:**

```nix
let
  pre-commit = import ./default.nix;
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  shellHook = pre-commit.pre-commit-check.shellHook;
  buildInputs = pre-commit.pre-commit-check.enabledPackages;
}
```

---

## Common Hook Configurations

### For NixOS Projects

```nix
hooks = {
  # Formatting
  alejandra.enable = true;

  # Linting
  statix.enable = true;
  deadnix.enable = true;

  # Flake validation
  flake-checker.enable = true;

  # Prevent commits to main
  no-commit-to-branch.enable = true;
};
```

### With Custom Settings

```nix
hooks = {
  # Clippy with all features
  clippy = {
    enable = true;
    packageOverrides.cargo = pkgs.cargo;
    packageOverrides.clippy = pkgs.clippy;
    settings.allFeatures = true;
  };

  # Ormolu with specific extensions
  ormolu = {
    enable = true;
    package = pkgs.haskellPackages.ormolu;
    settings.defaultExtensions = [ "lhs" "hs" ];
  };

  # Deadnix with flags
  deadnix = {
    enable = true;
    settings = {
      noLambdaArg = true;
      noLambdaPatternNames = true;
    };
  };
};
```

### Multi-Language Project

```nix
hooks = {
  # Nix
  alejandra.enable = true;
  statix.enable = true;

  # Python
  black.enable = true;
  ruff.enable = true;
  mypy.enable = true;

  # JavaScript/TypeScript
  eslint.enable = true;
  prettier.enable = true;

  # Rust
  rustfmt.enable = true;
  clippy.enable = true;

  # Shell
  shellcheck.enable = true;
  shfmt.enable = true;

  # Markdown
  mdformat.enable = true;

  # YAML
  yamllint.enable = true;

  # Git
  check-merge-conflicts.enable = true;
  check-added-large-files.enable = true;

  # Secrets
  detect-private-keys.enable = true;
  detect-aws-credentials.enable = true;
};
```

---

## Available Hooks (Selected)

### Nix
- `alejandra` - Fast Nix formatter
- `deadnix` - Dead code detector
- `nixfmt` - Official Nix formatter
- `nixfmt-rfc-style` - RFC style formatter
- `nixpkgs-fmt` - nixpkgs formatter
- `statix` - Nix linter
- `nil` - Nix LSP
- `flake-checker` - Flake health check

### Python
- `black`, `ruff`, `ruff-format`
- `isort`, `autoflake`, `pyupgrade`
- `mypy`, `pyright`, `pylint`
- `flake8`

### JavaScript/TypeScript
- `eslint`, `prettier`
- `biome` (formerly rome)
- `denofmt`, `denolint`

### Rust
- `cargo-check`, `clippy`, `rustfmt`

### Go
- `gofmt`, `govet`, `gotest`
- `golangci-lint`, `staticcheck`

### Shell
- `shellcheck`, `shfmt`

### Markdown/Docs
- `mdformat`, `mdl`, `markdownlint`

### Git/Commit
- `commitizen`, `convco`, `gitlint`
- `check-merge-conflicts`
- `no-commit-to-branch`

### Secrets
- `detect-private-keys`
- `detect-aws-credentials`
- `trufflehog`
- `pre-commit-ensure-sops`

[Full list of 100+ hooks](https://github.com/cachix/git-hooks.nix/blob/master/modules/hooks.nix)

---

## Custom Hooks

Define project-specific hooks:

```nix
hooks = {
  # Built-in hooks
  alejandra.enable = true;

  # Custom hook
  unit-tests = {
    enable = true;
    name = "Unit tests";
    entry = "make check";
    files = "\\.(c|h)$";
    types = [ "text" "c" ];
    excludes = [ "generated\\.c" ];
    language = "system";
    pass_filenames = false;
    stages = [ "pre-push" ];  # Run on push, not commit
  };
};
```

### Custom Hook Options

- `name` - Display name
- `entry` - Command to execute (mandatory)
- `files` - Pattern of files to run on (regex)
- `types` - File types (default: `[ "file" ]`)
- `excludes` - Exclude patterns
- `language` - How to install (default: "system")
- `pass_filenames` - Pass changed files to command (default: true)
- `stages` - Which git hooks to run on (default: `[ "pre-commit" ]`)

---

## Configuration File

Disable specific hooks via `statix.toml` (for statix example):

```toml
# In project root
disabled = [
  "empty_pattern",
  "useless_parens"
]
```

Or configure globally in flake:

```nix
hooks = {
  statix = {
    enable = true;
    settings = {
      ignore = [ ".direnv" ];
      format = "stderr";
    };
  };
};
```

---

## Best Practices

### 1. Use Binary Cache

Avoid recompilation:

```bash
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use pre-commit-hooks
```

### 2. Separate Dev and CI

- **Development:** Run hooks via `nix develop` (fast, auto-install)
- **CI:** Run via `nix flake check` (sandboxed, no file modification)

```yaml
# .github/workflows/ci.yml
- name: Check formatting
  run: nix flake check
```

### 3. Default Stages for Intrusive Hooks

```nix
hooks = {
  # Quick checks on every commit
  alejandra.enable = true;
  statix.enable = true;

  # Slow checks only on push
  unit-tests = {
    enable = true;
    entry = "pytest tests/";
    stages = [ "pre-push" ];
  };
};
```

### 4. Formatter Integration

Run formatters through pre-commit with `nix fmt`:

```nix
formatter.${system} =
  let
    pkgs = nixpkgs.legacyPackages.${system};
    config = self.checks.${system}.pre-commit-check.config;
    inherit (config) package configFile;
    script = ''
      ${pkgs.lib.getExe package} run --all-files --config ${configFile}
    '';
  in
  pkgs.writeShellScriptBin "pre-commit-run" script;
```

Then:

```bash
nix fmt  # Runs all formatters via pre-commit
```

---

## Troubleshooting

### Hooks not running

```bash
# Verify installation
pre-commit --version

# Reinstall hooks
pre-commit install

# Check hook status
pre-commit run --all-files
```

### Sandbox issues in `nix flake check`

Some hooks need internet or file writes. Run via `nix develop` instead:

```bash
nix develop -c pre-commit run -a
```

### Performance issues

```bash
# Run specific hooks only
pre-commit run alejandra

# Skip slow hooks
SKIP=unit-tests git commit
```

---

## References

- git-hooks.nix: https://github.com/cachix/git-hooks.nix
- pre-commit.com: https://pre-commit.com
- Cachix binary cache: https://pre-commit-hooks.cachix.org/
- flake-parts integration: https://flake.parts/options/git-hooks-nix
