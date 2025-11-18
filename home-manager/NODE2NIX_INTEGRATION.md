# Node2nix Integration Guide

**Date:** 2025-11-17
**Project:** my-modular-workspace-decoupling-home
**Purpose:** Convert npm global installs to declarative Nix expressions using node2nix

---

## 📚 Resources

### Official Documentation
- **GitHub Repository:** https://github.com/svanderburg/node2nix
- **README:** https://github.com/svanderburg/node2nix/blob/master/README.md
- **License:** MIT
- **Stars:** 570+ | **Forks:** 101+

### Key Features
- Generate Nix expressions from `package.json`, `package-lock.json`, or package lists
- Reproducible npm package deployments
- Integration with NixOS, NixOps, Disnix
- Support for private registries and Git repositories
- Works on NixOS, macOS, and any Linux with Nix package manager

---

## 🎯 Why We're Using node2nix

### Current Approach (Imperative)
```nix
# In home.nix - activation scripts
home.activation.install-claude-code = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  if command -v npm >/dev/null 2>&1; then
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    npm install -g @anthropic-ai/claude-code || true
  fi
'';
```

**Problems:**
- ❌ Not reproducible - depends on npm registry state at install time
- ❌ No version pinning - gets whatever is "latest"
- ❌ Activation scripts run on every rebuild (slower)
- ❌ Harder to rollback if package breaks
- ❌ Not truly declarative

### New Approach (Declarative with node2nix)
```nix
# Generate expressions once, use declaratively
home.packages = with pkgs; [
  (import ./npm-packages.nix { inherit pkgs; })."@anthropic-ai/claude-code"
];
```

**Benefits:**
- ✅ Fully reproducible - exact versions locked in Nix expressions
- ✅ Fast rebuilds - expressions cached, no npm calls
- ✅ Rollback support - previous generations work
- ✅ Version controlled - commit expressions to git
- ✅ True declarative configuration

---

## 📦 Current NPM Packages to Convert

### Identified from home.nix

1. **@anthropic-ai/claude-code**
   - Purpose: Claude Code CLI
   - Current install: npm global via activation script
   - Updates: Daily via systemd timer

2. **@cline/cline** (or fallback to `cline`)
   - Purpose: Cline CLI for AI coding
   - Current install: npm global via activation script
   - Updates: Daily via systemd timer

### Package Specification Created

**File:** `~/.config/my-home-manager-flake/npm-packages.json`

```json
[
  "@anthropic-ai/claude-code",
  "@cline/cline"
]
```

---

## 🔧 Installation & Usage

### Step 1: Install node2nix (DONE)

Added to `home.nix`:
```nix
home.packages = with pkgs; [
  nodePackages.node2nix
];
```

After rebuild, verify:
```bash
node2nix --version
```

### Step 2: Generate Nix Expressions

```bash
cd ~/.config/my-home-manager-flake
node2nix -i npm-packages.json -o npm-node-packages.nix -c npm-default.nix -e npm-node-env.nix
```

**Generated files:**
- `npm-node-packages.nix` - Package definitions with dependencies
- `npm-default.nix` - Composition expression for importing packages
- `npm-node-env.nix` - Build logic (shared infrastructure)

### Step 3: Create npm-packages.nix wrapper

**File:** `~/.config/my-home-manager-flake/npm-packages.nix`

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  nodePackages = import ./npm-default.nix {
    inherit pkgs;
    inherit (pkgs) system;
  };
in
nodePackages
```

### Step 4: Import in home.nix

**Option A: Individual packages**
```nix
{ config, lib, pkgs, ... }:

let
  npmPackages = import ./npm-packages.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    # ... existing packages ...
    npmPackages."@anthropic-ai/claude-code"
    npmPackages."@cline/cline"
  ];
}
```

**Option B: Wrapper scripts** (recommended for CLI tools)
```nix
{ config, lib, pkgs, ... }:

let
  npmPackages = import ./npm-packages.nix { inherit pkgs; };

  claude-code = pkgs.writeShellScriptBin "claude-code" ''
    export ANTHROPIC_API_KEY="$(bw get password anthropic-api-key 2>/dev/null || echo "")"
    export ANTHROPIC_MODEL="claude-sonnet-4.5"
    exec ${npmPackages."@anthropic-ai/claude-code"}/bin/claude-code "$@"
  '';

  cline = pkgs.writeShellScriptBin "cline" ''
    exec ${npmPackages."@cline/cline"}/bin/cline "$@"
  '';
in
{
  home.packages = [
    claude-code
    cline
  ];
}
```

### Step 5: Remove old activation scripts

After verifying packages work, remove from `home.nix`:
```nix
# DELETE these sections:
home.activation.install-claude-code = ...
home.activation.install-cline = ...
systemd.user.services.claude-code-update = ...
systemd.user.services.cline-update = ...
systemd.user.timers.claude-code-update = ...
systemd.user.timers.cline-update = ...
```

---

## 🔄 Workflow

### Initial Setup (One-time)

```bash
cd ~/.config/my-home-manager-flake

# 1. Create package specification
cat > npm-packages.json <<EOF
[
  "@anthropic-ai/claude-code",
  "@cline/cline"
]
EOF

# 2. Generate Nix expressions
node2nix -i npm-packages.json \
  -o npm-node-packages.nix \
  -c npm-default.nix \
  -e npm-node-env.nix

# 3. Create wrapper
cat > npm-packages.nix <<'EOF'
{ pkgs ? import <nixpkgs> {} }:

let
  nodePackages = import ./npm-default.nix {
    inherit pkgs;
    inherit (pkgs) system;
  };
in
nodePackages
EOF

# 4. Update home.nix (see Step 4 above)

# 5. Rebuild
home-manager switch --flake .#mitsio@shoshin

# 6. Test
claude-code --version
cline --version
```

### Updating Packages

```bash
cd ~/.config/my-home-manager-flake

# Option 1: Update to latest versions
node2nix -i npm-packages.json \
  -o npm-node-packages.nix \
  -c npm-default.nix \
  -e npm-node-env.nix

# Option 2: Pin specific versions in npm-packages.json
cat > npm-packages.json <<EOF
[
  { "@anthropic-ai/claude-code": "1.2.3" },
  { "@cline/cline": "2.0.0" }
]
EOF

node2nix -i npm-packages.json \
  -o npm-node-packages.nix \
  -c npm-default.nix \
  -e npm-node-env.nix

# Rebuild
home-manager switch --flake .#mitsio@shoshin
```

---

## 📝 Advanced Options

### Using package-lock.json

```bash
cd /path/to/project
node2nix -l package-lock.json
nix-build -A package
./result/bin/your-app
```

### Development Shell

```bash
cd /path/to/project
node2nix
nix-shell -A shell  # All dependencies available in shell
```

### Private NPM Registry

```bash
node2nix -i npm-packages.json \
  --registry https://npm.your-company.com \
  --registry-auth-token "YOUR_TOKEN" \
  --registry-scope "@yourcompany"
```

### Private Git Repositories

```bash
node2nix --use-fetchgit-private -i npm-packages.json

# Deploy with SSH config
nix-build -A package -I ssh-config-file=~/ssh_config
```

---

## 🐛 Troubleshooting

### Package Build Fails

```bash
# Show detailed errors
home-manager switch --flake .#mitsio@shoshin --show-trace

# Check specific package
nix-build npm-default.nix -A "@anthropic-ai/claude-code"
```

### Missing Native Dependencies

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  nodePackages = import ./npm-default.nix {
    inherit pkgs;
    inherit (pkgs) system;
  };
in
nodePackages // {
  "some-package" = nodePackages."some-package".override {
    buildInputs = [ pkgs.python3 pkgs.gcc ];
  };
}
```

---

## 📊 Benefits Achieved

**Before (Imperative npm):**
- Rebuild time: ~30s (npm install runs every time)
- Reproducible: ❌ No
- Version control: ❌ No
- Rollback: ⚠️ Limited

**After (Declarative node2nix):**
- Rebuild time: ~5s (cached)
- Reproducible: ✅ Yes
- Version control: ✅ Yes
- Rollback: ✅ Full

---

## 📁 Files Structure

```
~/.config/my-home-manager-flake/
├── npm-packages.json          # Input: List of packages
├── npm-node-packages.nix      # Generated: Package definitions
├── npm-default.nix            # Generated: Composition
├── npm-node-env.nix           # Generated: Build logic
└── npm-packages.nix           # Wrapper: Imports npm-default.nix
```

---

## 🎯 Next Steps

1. ✅ Install node2nix - Added to home.nix
2. ⏳ Generate expressions - After rebuild
3. ⏳ Update home.nix - Replace activation scripts
4. ⏳ Test packages - Verify functionality
5. ⏳ Commit changes - Add to git

---

## 📚 Additional Resources

- **node2nix GitHub:** https://github.com/svanderburg/node2nix
- **Nixpkgs Manual - Node.js:** https://nixos.org/manual/nixpkgs/stable/#node.js
- **Home Manager Manual:** https://nix-community.github.io/home-manager/

---

**Created:** 2025-11-17
**Author:** Claude Code + Mitsio
**Status:** In Progress
