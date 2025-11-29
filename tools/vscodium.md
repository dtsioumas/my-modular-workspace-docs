# VSCodium Declarative Configuration Guide

**Last Updated:** 2025-11-29
**Sources Merged:** README.md, PLAN.md, TODO.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [Extensions](#extensions)
- [Migration from VSCode](#migration-from-vscode)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

VSCodium is the open-source version of VSCode with telemetry and proprietary bits removed. This guide covers setting up VSCodium declaratively using NixOS Home Manager.

### Why VSCodium?

- Fully open source (removes telemetry)
- Binary compatible with VSCode
- Supports same extensions (via Open VSX Registry)
- Aligns with FOSS philosophy
- Available in nixpkgs

### Why Declarative?

- Reproducible across machines
- Version controlled configuration
- Easy rollback if issues
- No manual extension installation
- Settings managed in Git

---

## Quick Start

### Basic Home Manager Setup

```nix
# ~/.config/nixos/home/user/vscodium.nix
{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    extensions = with pkgs.vscode-extensions; [
      golang.go
      ms-python.python
      redhat.vscode-yaml
    ];

    userSettings = {
      "editor.fontSize" = 14;
      "workbench.colorTheme" = "Dracula";
    };
  };
}
```

### Apply Configuration

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
```

---

## Installation

### NixOS Home Manager

```nix
# Add to flake.nix outputs
homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
  modules = [
    ./home/user/vscodium.nix
  ];
};
```

### Import in home.nix

```nix
imports = [
  ./vscodium.nix
];
```

---

## Configuration

### Full Module Example

```nix
{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    # Declarative extensions
    extensions = with pkgs.vscode-extensions; [
      # Language support
      golang.go
      ms-python.python
      ms-python.vscode-pylance
      mads-hartmann.bash-ide-vscode

      # DevOps
      redhat.vscode-yaml
      hashicorp.terraform
      ms-kubernetes-tools.vscode-kubernetes-tools

      # Git
      github.vscode-github-actions
      gitlab.gitlab-workflow

      # Themes
      dracula-theme.theme-dracula
      pkief.material-icon-theme

      # Markdown
      yzhang.markdown-all-in-one
      shd101wyy.markdown-preview-enhanced
    ];

    # Declarative settings
    userSettings = {
      # Editor
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrains Mono', monospace";
      "editor.fontLigatures" = true;
      "editor.minimap.enabled" = false;
      "editor.formatOnSave" = true;
      "editor.tabSize" = 2;

      # Workbench
      "workbench.colorTheme" = "Dracula";
      "workbench.iconTheme" = "material-icon-theme";

      # Terminal
      "terminal.integrated.fontSize" = 12;
      "terminal.integrated.defaultProfile.linux" = "bash";

      # Extensions (disable auto-update since Nix manages)
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;

      # Telemetry (should be off in VSCodium, but explicit)
      "telemetry.telemetryLevel" = "off";

      # Language-specific
      "go.useLanguageServer" = true;
      "python.defaultInterpreterPath" = "python";
      "[python]" = {
        "editor.tabSize" = 4;
      };
    };

    # Declarative keybindings
    keybindings = [
      {
        key = "ctrl+shift+p";
        command = "workbench.action.showCommands";
      }
      {
        key = "ctrl+`";
        command = "workbench.action.terminal.toggleTerminal";
      }
    ];
  };
}
```

---

## Extensions

### Extension Sources

1. **nixpkgs vscode-extensions** (Preferred)
   ```bash
   nix search nixpkgs vscode-extensions
   ```

2. **Build from Marketplace** (For unavailable extensions)
   ```nix
   (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
     mktplcRef = {
       name = "extension-name";
       publisher = "publisher";
       version = "1.0.0";
       sha256 = lib.fakeSha256;  # Get real hash on first build
     };
   })
   ```

3. **Open VSX Registry** (VSCodium default)
   - VSCodium uses Open VSX by default
   - Most community extensions available

### Common Extensions Available in nixpkgs

| Extension | Package |
|-----------|---------|
| Go | `golang.go` |
| Python | `ms-python.python` |
| Pylance | `ms-python.vscode-pylance` |
| YAML | `redhat.vscode-yaml` |
| Kubernetes | `ms-kubernetes-tools.vscode-kubernetes-tools` |
| Terraform | `hashicorp.terraform` |
| Bash IDE | `mads-hartmann.bash-ide-vscode` |
| Dracula | `dracula-theme.theme-dracula` |
| Material Icons | `pkief.material-icon-theme` |
| Markdown All in One | `yzhang.markdown-all-in-one` |

### Adding New Extension

```nix
# 1. Search for extension
# nix search nixpkgs vscode-extensions.<name>

# 2. Add to extensions list
extensions = with pkgs.vscode-extensions; [
  # existing extensions...
  new-publisher.new-extension
];

# 3. Rebuild
# sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
```

---

## Migration from VSCode

### Phase 1: Backup

```bash
# Create backup directory
mkdir -p ~/vscodium-migration/backups

# Backup settings
cp ~/.config/Code/User/settings.json ~/vscodium-migration/backups/

# Backup keybindings
cp ~/.config/Code/User/keybindings.json ~/vscodium-migration/backups/

# List extensions
code --list-extensions --show-versions > ~/vscodium-migration/backups/extensions.txt
```

### Phase 2: Create Configuration

1. Create vscodium.nix (see Configuration section)
2. Convert settings.json to Nix userSettings
3. Add extensions from extensions.txt
4. Test build: `nixos-rebuild build`

### Phase 3: Test

1. Apply: `sudo nixos-rebuild test`
2. Launch VSCodium: `codium`
3. Test all workflows
4. Verify extensions loaded

### Phase 4: Switch

1. Apply permanently: `sudo nixos-rebuild switch`
2. Remove VSCode from packages
3. Clean up old configs

### Rollback

```bash
# Immediate rollback
sudo nixos-rebuild switch --rollback

# Or revert git commit
cd ~/.config/nixos
git revert <commit-hash>
sudo nixos-rebuild switch
```

---

## Troubleshooting

### Extension Not Loading

1. Check extension is in vscodium.nix
2. Verify extension available in nixpkgs: `nix search nixpkgs vscode-extensions.<name>`
3. Check VSCodium extension panel for errors
4. Rebuild: `sudo nixos-rebuild switch`

### Settings Not Applied

1. Check userSettings syntax in vscodium.nix
2. Verify no manual settings.json in ~/.config/VSCodium
3. Check for conflicting settings
4. Test with minimal settings

### Language Server Not Working

1. Check language extension is installed
2. Verify language toolchain available (go, python, etc.)
3. Check extension settings for path configurations
4. Review VSCodium output panel for errors

### Build Fails

```bash
# Check with detailed errors
sudo nixos-rebuild build --show-trace

# Verify extension sha256 hashes
# Use lib.fakeSha256 to get correct hash
```

### Microsoft Extensions Issues

Some Microsoft extensions only work with official VSCode. Solutions:
- Find FOSS alternatives
- Use Open VSX versions
- Build from marketplace with sha256

---

## References

### Documentation

- **Home Manager VSCode Options:** https://nix-community.github.io/home-manager/options.html#opt-programs.vscode.enable
- **VSCodium Project:** https://github.com/VSCodium/vscodium
- **Open VSX Registry:** https://open-vsx.org/
- **nixpkgs vscode-extensions:** https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/editors/vscode/extensions

### Workflow After Migration

```bash
# Adding new extension
# 1. Edit vscodium.nix
# 2. sudo nixos-rebuild switch

# Changing settings
# 1. Edit userSettings in vscodium.nix
# 2. sudo nixos-rebuild switch

# Rollback
sudo nixos-rebuild switch --rollback
```

---

*Migrated from docs/commons/toolbox/vscodium/ on 2025-11-29*
