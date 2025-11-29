# Continue.dev Installation Guide for NixOS

**Target:** VSCodium on NixOS 25.05 (shoshin)
**Date:** 2025-11-26
**Status:** Installation Pending

---

## Installation Methods

### Method 1: Manual VSIX Installation (RECOMMENDED for NixOS)

This is the most reliable method for VSCodium on NixOS due to Open VSX version lag issues.

#### Step 1: Download Latest VSIX

```bash
# Create downloads directory if needed
mkdir -p ~/Downloads/continue-dev

# Download latest release
cd ~/Downloads/continue-dev
wget https://github.com/continuedev/continue/releases/latest/download/continue-vscode.vsix

# Or download specific version
# wget https://github.com/continuedev/continue/releases/download/v<VERSION>/continue-vscode.vsix
```

#### Step 2: Install Extension

```bash
# Install in VSCodium
codium --install-extension ~/Downloads/continue-dev/continue-vscode.vsix

# Verify installation
codium --list-extensions | grep Continue
```

Expected output:
```
Continue.continue
```

#### Step 3: Restart VSCodium

```bash
# Close all VSCodium windows
pkill codium

# Start VSCodium
codium
```

---

### Method 2: Open VSX Registry (NOT RECOMMENDED - Version Lag)

**Warning:** Open VSX may have outdated versions (see GitHub issue #924)

```bash
# Search for Continue extension
codium --list-extensions | grep -i continue

# Install from Open VSX (if available)
# May not be latest version!
```

---

### Method 3: Home-Manager Automation (FUTURE)

Create `continue-dev.nix` module for declarative installation:

```nix
# home-manager/continue-dev.nix
{ config, lib, pkgs, ... }:

{
  # Download and install VSIX via activation script
  home.activation.install-continue-dev = lib.hm.dag.entryAfter ["writeBoundary"] ''
    VSIX_URL="https://github.com/continuedev/continue/releases/latest/download/continue-vscode.vsix"
    VSIX_FILE="$HOME/.cache/continue-dev/continue.vsix"

    mkdir -p $HOME/.cache/continue-dev

    # Download if not exists or outdated
    if [ ! -f "$VSIX_FILE" ]; then
      ${pkgs.wget}/bin/wget -O "$VSIX_FILE" "$VSIX_URL"
      ${pkgs.vscodium}/bin/codium --install-extension "$VSIX_FILE"
    fi
  '';

  # Manage config.yaml
  home.file.".continue/config.yaml".source = ./continue-config.yaml;
}
```

---

## Verification Steps

### 1. Check Extension is Loaded

```bash
# List installed extensions
codium --list-extensions | grep Continue

# Check extension directory exists
ls -la ~/.vscode-oss/extensions/ | grep continue
```

### 2. Verify Extension Activates

1. Open VSCodium
2. Look for Continue icon in left sidebar (or move to right sidebar)
3. Click Continue icon
4. Check for sidebar panel opening

### 3. Check for Errors

```bash
# View VSCodium logs
tail -f ~/.config/VSCodium/logs/*/window1/exthost/output*
```

---

## NixOS-Specific Issues & Fixes

### Issue 1: Extension Fails to Activate (GitHub #821)

**Symptom:** "Error activating the Continue extension"

**Cause:** Missing dynamic libraries in NixOS's non-FHS filesystem

**Solution 1: FHS User Environment Wrapper**

```nix
# In your home.nix or system configuration
{ pkgs, ... }:

let
  vscodiumFHS = pkgs.buildFHSUserEnv {
    name = "vscodium-fhs";
    targetPkgs = pkgs: with pkgs; [
      vscodium
      # Add any missing libraries
      stdenv.cc.cc.lib
      zlib
      libGL
      glib
      gtk3
    ];
    runScript = "codium";
  };
in
{
  home.packages = [ vscodiumFHS ];
}
```

Then use `vscodium-fhs` command instead of `codium`.

**Solution 2: LD_LIBRARY_PATH Wrapper**

```bash
# Create wrapper script
cat > ~/.local/bin/codium-wrapped <<'EOF'
#!/usr/bin/env bash
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"
exec codium "$@"
EOF

chmod +x ~/.local/bin/codium-wrapped
```

**Solution 3: Use nixGL**

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "codium-nixgl" ''
      ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.vscodium}/bin/codium "$@"
    '')
  ];
}
```

### Issue 2: Extension Server Won't Start

**Symptom:** Extension loads but Continue server fails

**Check Logs:**

```bash
# Continue extension logs
ls ~/.continue/
cat ~/.continue/*.log

# VSCodium extension host logs
journalctl --user -xe | grep -i continue
```

**Solution:** Ensure Node.js is available

```nix
{
  home.packages = with pkgs; [
    nodejs_20  # Continue requires Node.js
  ];
}
```

---

## Post-Installation Checklist

- [ ] Extension appears in `codium --list-extensions`
- [ ] Continue icon visible in VSCodium sidebar
- [ ] No errors in extension host logs
- [ ] Continue sidebar panel opens when clicked
- [ ] Ready for configuration (see CONFIGURATION.md)

---

## Troubleshooting

If installation fails, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for:
- Detailed error diagnosis
- NixOS-specific fixes
- Known issues and workarounds
- Community solutions

---

## Next Steps

1. ✅ Installation complete
2. → Configure models: [CONFIGURATION.md](./CONFIGURATION.md)
3. → Set up API keys: [API_KEYS.md](./API_KEYS.md)
4. → Optimize model usage: [MODELS.md](./MODELS.md)
