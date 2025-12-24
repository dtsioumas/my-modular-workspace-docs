# NixOS Code Linters

**Last Updated:** 2025-11-23

## Overview

Nix linters help identify antipatterns, unused code, and potential issues in Nix expressions. Unlike formatters (which change code style), linters analyze code for problems and suggest improvements.

## Active Linters

### 1. **Statix** (Best Practices Linter)

**Repository:** https://github.com/oppiliappan/statix
**Language:** Rust
**Stars:** 765
**License:** MIT
**Author:** oppiliappan

#### Features

- **Lint and fix** - `statix check` finds issues, `statix fix` fixes them
- **AST-based** - works with rnix-parser AST (no evaluation)
- **Comprehensive** - 16+ antipattern checks
- **Configurable** - disable specific lints via `statix.toml`
- **Multiple output formats** - human-readable, JSON, errfmt (vim-friendly)

#### Installation

**From nixpkgs:**
```bash
nix run nixpkgs#statix -- help
```

**With flakes:**
```bash
nix build git+https://git.peppe.rs/languages/statix
./result/bin/statix --help
```

**Homebrew:**
```bash
brew install statix
```

**Cachix (avoid compilation):**
```bash
cachix use statix
```

#### Usage

```bash
# Check for lints recursively
statix check /path/to/dir

# Ignore specific files
statix check /path/to/dir -i Cargo.nix generated.nix

# Ignore directories
statix check /path/to/dir -i .direnv

# Run in unrestricted mode (ignore .gitignore)
statix check /path/to/dir -u

# Fix issues automatically
statix fix /path/to/file

# Show diff without writing
statix fix --dry-run /path/to/file

# JSON output
statix check /path/to/dir -o json

# Vim-friendly output
statix check /path/to/dir -o errfmt
```

#### Configuration

Create `statix.toml` in project root:

```toml
# Disable specific lints
disabled = [
  "empty_pattern",
  "useless_parens"
]
```

Statix auto-discovers config by traversing parent directories, or use `--config`:

```bash
statix check --config ./my-statix.toml
```

#### Available Lints

```
bool_comparison
empty_let_in
manual_inherit
manual_inherit_from
legacy_let_syntax
collapsible_let_in
eta_reduction
useless_parens
empty_pattern
redundant_pattern_bind
unquoted_uri
empty_inherit
deprecated_to_path
bool_simplification
useless_has_attr
```

All lints enabled by default. Generate minimal config:

```bash
statix dump > statix.toml
```

#### Example Output

```nix
Warning: Assignment instead of inherit from
   ╭─[tests/c.nix:2:3]
   │
 2 │   mtl = pkgs.haskellPackages.mtl;
   ·   ───────────────┬───────────────
   ·                  ╰─── This assignment is better written with inherit
───╯
```

After `statix fix`:

```nix
let
-  mtl = pkgs.haskellPackages.mtl;
+  inherit (pkgs.haskellPackages) mtl;
in
null
```

#### Pros

✅ Fast (Rust-based)
✅ Both checks and fixes
✅ Configurable per-project
✅ Multiple output formats
✅ Respects .gitignore
✅ Comprehensive lint rules

#### Cons

❌ AST-only (no evaluation)
❌ Some lint names not self-explanatory
❌ Requires learning which lints to disable

---

### 2. **Deadnix** (Dead Code Detector)

**Repository:** https://github.com/astro/deadnix
**Language:** Rust
**Stars:** 669
**License:** GPL-3.0
**Author:** Astro

#### Features

- **Finds unused bindings** - detects dead code (unused variable bindings)
- **Auto-fix mode** - removes unused code automatically with `--edit`
- **GitHub Actions** - native action available
- **Pre-commit support** - built-in hook
- **pragma support** - skip checks with `# deadnix: skip`

#### Installation

**From nixpkgs (flakes):**
```bash
nix run github:astro/deadnix -- --help
```

#### Usage

```bash
# Scan for dead code
deadnix example.nix

# Remove unused code (COMMIT FIRST!)
deadnix --edit example.nix

# Don't check lambda arguments
deadnix -l file.nix

# Don't check lambda pattern names (for nixpkgs callPackage)
deadnix -L file.nix

# Don't check bindings starting with _
deadnix -_ file.nix

# Fail exit code if unused code found
deadnix --fail file.nix

# JSON output
deadnix --output-format json file.nix

# Exclude files
deadnix --exclude generated.nix --exclude vendor/ -- .

# Process hidden files
deadnix --hidden .
```

#### Example Output

```
Warning: Unused declarations were found.
    ╭─[example.nix:1:1]
  1 │unusedArgs@{ unusedArg, usedArg, ... }:
    ·     │           ╰───── Unused lambda pattern: unusedArg
    ·     ╰───────────────── Unused lambda pattern: unusedArgs
  3 │  inherit (builtins) unused_inherit;
    ·                            ╰─────── Unused let binding: unused_inherit
  5 │  unused = "fnord";
    ·     ╰─── Unused let binding: unused
```

#### Skip Pragma

```nix
# deadnix: skip
let unused = "this will be ignored";
```

#### Special Behaviors

**Lambda arguments renamed to start with `_`:**
All unused lambda args are renamed with `_` prefix. Use `-l` to disable.

**nixpkgs callPackages:**
Use `-L` flag for packages that use `@args` to pass arguments to imports:

```nix
# In package.nix imported by callPackage
{ stdenv, fetchurl, ... }@args: import ./build.nix args
```

Without `-L`, deadnix will report `args` as unused even though it's used in the imported file.

#### Pre-commit Integration

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/astro/deadnix
    rev: da39a3ee5e6b4b0d3255bfef95601890afd80709  # frozen: v1.2.1
    hooks:
      - id: deadnix
        #args: [--edit]  # Uncomment to auto-fix
        stages: [commit]
```

#### Pros

✅ Specialized for dead code
✅ Auto-fix capability
✅ GitHub Actions support
✅ Pragma support for exceptions
✅ Fast (Rust-based)

#### Cons

❌ Can have false positives with complex imports
❌ Requires flags for nixpkgs patterns
❌ GPL license (more restrictive)

---

### 3. **Nixd** (LSP with Linting)

**Repository:** https://github.com/oxalica/nil
**Note:** `nil` is different from `nixd` but both are Nix LSPs

**Nixd** is a Nix language server that provides linting via LSP protocol.

#### Features

- **IDE integration** - works with VS Code, Neovim, Emacs
- **Real-time linting** - as you type
- **Advanced analysis** - more than simple AST checks
- **Autocomplete** - plus diagnostics

#### Installation

Nixd integration varies by editor. Typically installed via:

```nix
environment.systemPackages = [ pkgs.nixd ];
```

Then configured in your editor's LSP client.

#### Pros

✅ Real-time feedback
✅ IDE integration
✅ Advanced analysis
✅ Autocomplete + linting combined

#### Cons

❌ Requires editor setup
❌ Less suitable for CI
❌ Learning curve for configuration

---

## Comparison Table

| Feature              | Statix       | Deadnix      | Nixd (LSP)   |
|----------------------|--------------|--------------|--------------|
| **Purpose**          | Antipatterns | Dead code    | LSP linting  |
| **Speed**            | ⭐⭐⭐⭐⭐    | ⭐⭐⭐⭐⭐    | ⭐⭐⭐⭐     |
| **Auto-fix**         | ✅           | ✅           | ✅ (editor)  |
| **CI-friendly**      | ✅           | ✅           | ❌           |
| **Configurable**     | ✅           | ⚠️ Flags only | ✅ (complex) |
| **Output Formats**   | 3 formats    | 2 formats    | LSP only     |
| **Pre-commit**       | ✅           | ✅           | ❌           |
| **False Positives**  | Low          | Medium       | Low          |

---

## Recommendation

### Use All Three

These tools complement each other:

1. **Statix** - for antipattern detection in CI/CD
2. **Deadnix** - for dead code cleanup before commits
3. **Nixd** - for real-time feedback while coding

### Typical Workflow

```bash
# While coding: use Nixd in your editor

# Before committing:
deadnix --fail .        # Check for dead code
statix check .          # Check for antipatterns

# Fix automatically:
deadnix --edit file.nix
statix fix file.nix
```

### Pre-commit Setup

Use both in pre-commit hooks (see PRE_COMMIT.md):

```nix
hooks = {
  statix.enable = true;
  deadnix.enable = true;
};
```

---

## References

- Statix GitHub: https://github.com/oppiliappan/statix
- Deadnix GitHub: https://github.com/astro/deadnix
- Deadnix GitHub Action: https://github.com/astro/deadnix-action
- NixOS Discourse - Statix announcement: https://discourse.nixos.org/t/statix-lints-and-suggestions-for-the-nix-programming-language/15714
