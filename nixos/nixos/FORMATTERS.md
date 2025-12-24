# NixOS Code Formatters

**Last Updated:** 2025-11-23

## Overview

Nix has several actively maintained code formatters. Choosing the right one depends on your priorities: speed, semantic correctness, standardization, or configurability.

## Active Formatters

### 1. **Alejandra** (Recommended for Personal Projects)

**Repository:** https://github.com/kamadorueda/alejandra
**Language:** Rust
**Stars:** 1.2k
**License:** Unlicense (Public Domain)

#### Features

- **Fastest formatter** - formats entire Nixpkgs in seconds
- **Semantically correct** - guarantees no semantic changes after formatting
  - Only 89 rebuilds when formatting all of Nixpkgs (vs thousands with other formatters)
  - Code evaluation hash remains identical
- **Uncompromising** - comprehensive style for all Nix expression combinations
- **Battle-tested** - high test coverage, used in production
- **Zero configuration** - no options, enforces single style

#### Installation

**NixOS (flakes):**
```nix
{
  inputs = {
    alejandra.url = "github:kamadorueda/alejandra/4.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {alejandra, nixpkgs, ...}: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [{
        environment.systemPackages = [alejandra.defaultPackage.${system}];
      }];
    };
  };
}
```

**From nixpkgs:**
```bash
nix-env -ivf https://github.com/kamadorueda/alejandra/tarball/4.0.0
# or with flakes
nix profile install github:kamadorueda/alejandra/4.0.0
```

**Homebrew:**
```bash
brew install alejandra
```

#### Usage

```bash
# Format files
alejandra .

# Check without modifying
alejandra --check .

# Format specific files
alejandra file1.nix file2.nix
```

#### Integration

- **VS Code:** Official extension available
- **Neovim:** Plugin available
- **Vim:** Plugin available
- **Emacs:** Integration available
- **Pre-commit:** Native support

#### Benchmark (on Nixpkgs)

System: Intel i7-1165G7 @ 2.80GHz (4 cores)

| Threads | Time (seconds) |
|---------|----------------|
| 1       | 45            |
| 2       | 25            |
| 4       | 14            |

#### Pros

✅ Fastest formatter
✅ Semantically correct (proven)
✅ Beautiful, readable output
✅ Zero configuration needed
✅ Excellent tooling integration
✅ Public domain license

#### Cons

❌ Not (yet) the official standard
❌ No configuration options
❌ Opinionated style (2-space indent)

---

### 2. **nixfmt-rfc-style** (Future Standard)

**Repository:** https://github.com/NixOS/nixfmt
**Language:** Haskell
**RFC:** https://github.com/NixOS/rfcs/pull/166
**Status:** Close to final comment period (FCP)

#### Features

- **Official formatter** - will become the enforced standard for Nixpkgs
- **RFC-driven** - style defined through community consensus
- **Favors readability** - designed for human comprehension
- **Git-friendly** - optimized for clean diffs
- **Correct formatting** - architectural focus on correctness

#### Installation

Available in nixpkgs unstable:

```nix
environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
```

#### Current Status (as of 2025-11-23)

- RFC is close to FCP
- Will become both official AND enforced for nixpkgs
- Expected to become community default soon
- Style differs completely from original `nixfmt`
- `nixfmt` codebase selected for architectural reasons

#### Pros

✅ Will be the official standard
✅ Community-driven style
✅ Optimized for readability
✅ Git diff friendly
✅ Strong correctness guarantees

#### Cons

❌ Not yet finalized
❌ Slower than Alejandra (Haskell vs Rust)
❌ Style still evolving

---

### 3. **nixpkgs-fmt** (Current Nixpkgs Default)

**Repository:** https://github.com/nix-community/nixpkgs-fmt
**Language:** Rust
**Status:** De-facto standard (will be replaced by nixfmt-rfc-style)

#### Features

- **Current standard** - used in Nixpkgs today
- **Rust-based** - reasonably fast
- **Community-maintained** - nix-community organization

#### Installation

```nix
environment.systemPackages = [ pkgs.nixpkgs-fmt ];
```

#### Usage

```bash
nixpkgs-fmt .
```

#### Pros

✅ Current Nixpkgs standard
✅ Fast (Rust)
✅ Well-established

#### Cons

❌ Being replaced by nixfmt-rfc-style
❌ Not semantically correct
❌ Less comprehensive than Alejandra

---

## Comparison Table

| Feature                  | Alejandra | nixfmt-rfc-style | nixpkgs-fmt |
|--------------------------|-----------|------------------|-------------|
| **Speed**                | ⭐⭐⭐⭐⭐ | ⭐⭐⭐           | ⭐⭐⭐⭐    |
| **Semantic Correctness** | ✅ Proven  | ✅ By design     | ❌          |
| **Official Standard**    | ❌         | ✅ Soon          | ✅ Current  |
| **Configurability**      | ❌         | ❌               | ❌          |
| **Readability**          | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐        | ⭐⭐⭐⭐    |
| **Git Diff Friendly**    | ⭐⭐⭐⭐  | ⭐⭐⭐⭐⭐        | ⭐⭐⭐⭐    |
| **Tooling Support**      | ⭐⭐⭐⭐⭐ | ⭐⭐⭐           | ⭐⭐⭐⭐    |

---

## Recommendation

### For Personal Projects
**Use Alejandra** - Fastest, semantically correct, excellent tooling support.

### For Nixpkgs Contributions
**Use nixfmt-rfc-style** - Will be enforced soon, get ahead of the curve.

### For Legacy Projects
**Use nixpkgs-fmt** - If already using it, no rush to change until nixfmt-rfc-style is finalized.

---

## Playground Links

Try formatters online before installing:

- **Alejandra:** https://kamadorueda.com/alejandra/
- **nixfmt:** https://nixfmt.serokell.io/
- **nixpkgs-fmt:** https://nix-community.github.io/nixpkgs-fmt/

---

## Inactive/Deprecated Formatters

### nix-format
- **Status:** Unmaintained since 2017
- **Technology:** Emacs-based
- **Recommendation:** Do not use

### format-nix
- **Status:** Unmaintained since 2019
- **Technology:** tree-sitter-nix
- **Recommendation:** Use nixpkgs-fmt instead (as suggested in README)

### canonix
- **Status:** Unmaintained since 2019
- **Authors:** Robert Hensing, Domen Kožar (core NixOS contributors)
- **Technology:** tree-sitter-nix
- **Recommendation:** Do not use

---

## References

- Alejandra GitHub: https://github.com/kamadorueda/alejandra
- nixfmt RFC: https://github.com/NixOS/rfcs/pull/166
- NixOS Discourse - Alejandra announcement: https://discourse.nixos.org/t/the-uncompromising-nix-code-formatter/17385
- Drake Rossman's overview: https://drakerossman.com/blog/overview-of-nix-formatters-ecosystem
