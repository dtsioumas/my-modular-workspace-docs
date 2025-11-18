# Instructions for Building NixOS Flakes

## For LLMs and Humans

This document provides step-by-step instructions for building flakes in NixOS, designed to be clear for both AI assistants and human developers.

## Prerequisites Check

Before starting any flake project:
1. Verify Nix version: `nix --version` (should be 2.4+)
2. Ensure flakes enabled: Check `/etc/nix/nix.conf` for `experimental-features = nix-command flakes`
3. Identify target system architecture
4. Have internet connection for fetching dependencies

## Decision Tree for Package Installation

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

## Step-by-Step Process

### Phase 1: Research and Discovery

1. **Search nixpkgs**
   ```bash
   # Search stable
   nix search nixpkgs#package-name
   
   # Search unstable
   nix search nixpkgs-unstable#package-name
   
   # Check online
   # Visit: https://search.nixos.org/packages
   ```

2. **Search for existing flakes**
   ```bash
   # Search GitHub for "package-name nix flake"
   # Check FlakeHub: https://flakehub.com/
   # Search NixOS discourse and wiki
   ```

3. **Analyze package requirements**
   - Language/framework (Rust, Python, Node.js, Go, C/C++)
   - Build system (cargo, pip, npm, make, cmake)
   - Dependencies (libraries, tools)
   - Runtime requirements

### Phase 2: Implementation Decision

If package exists in nixpkgs:
```nix
# For stable packages
environment.systemPackages = with pkgs; [
  package-name
];

# For unstable packages
environment.systemPackages = [
  unstable.package-name
];
```

If building custom package, proceed to Phase 3.

### Phase 3: Custom Package Creation

1. **Create project structure**
   ```bash
   mkdir package-name-flake
   cd package-name-flake
   ```

2. **Initialize flake**
   ```bash
   nix flake init
   ```

3. **Edit flake.nix**
   ```nix
   {
     description = "Package description";
     
     inputs = {
       nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     };
     
     outputs = { self, nixpkgs }: 
       let
         system = "x86_64-linux";
         pkgs = nixpkgs.legacyPackages.${system};
       in {
         packages.${system}.default = pkgs.callPackage ./package.nix { };
       };
   }
   ```

4. **Create package.nix**
   - Use appropriate builder for language
   - Define all dependencies
   - Set correct build phases
   - Add metadata

5. **Test build**
   ```bash
   nix build
   ./result/bin/program-name --version
   ```

### Phase 4: Integration

1. **For system-wide installation**
   - Add flake as input to system flake
   - Reference in systemPackages
   - Run `nixos-rebuild switch`

2. **For user installation**
   ```bash
   nix profile install .#package-name
   ```

## Common Patterns and Solutions

### Pattern: Binary-only package
```nix
# Use autoPatchelfHook for dynamic libraries
nativeBuildInputs = [ autoPatchelfHook ];
buildInputs = [ required-libraries ];
```

### Pattern: Unfree software
```nix
# In configuration
nixpkgs.config.allowUnfree = true;

# In package
meta.license = licenses.unfree;
```

### Pattern: Specific version needed
```nix
# Use overlay to override version
(final: prev: {
  package = prev.package.overrideAttrs (old: rec {
    version = "specific-version";
    src = fetchFromGitHub { ... };
  });
})
```

## Verification Checklist

- [ ] Package builds without errors
- [ ] Binary/script is executable
- [ ] Dependencies are satisfied
- [ ] Works in clean environment
- [ ] Metadata is complete
- [ ] License is correctly specified
- [ ] Platform compatibility verified

## Troubleshooting Guide

### Issue: SHA256 mismatch
**Solution**: Use the hash Nix provides in error message

### Issue: Build fails with missing dependency
**Solution**: Add to buildInputs or nativeBuildInputs

### Issue: Runtime library not found
**Solution**: Use wrapProgram or patchelf

### Issue: Command not found after installation
**Solution**: Check installPhase copies to $out/bin

## Documentation Requirements

When creating a new flake, always document:
1. Purpose and functionality
2. Build requirements
3. Usage examples
4. Known limitations
5. Upstream source
6. Maintenance contact

## Quality Standards

A well-built flake should:
- Build reproducibly
- Follow Nix conventions
- Include comprehensive metadata
- Handle errors gracefully
- Support common platforms
- Provide clear error messages

## Final Validation

Before considering complete:
```bash
# Clean build test
nix build --no-link --rebuild

# Check runtime
nix run .#package-name

# Verify in shell
nix shell .#package-name -c which program-name

# Test on target system
nixos-rebuild test
```

## Remember

1. Always check existing solutions first
2. Keep builds reproducible
3. Document everything
4. Test in isolation
5. Follow community conventions
6. Contribute back when possible

This process ensures reliable, maintainable NixOS packages and flakes.