# VSCode to VSCodium Migration Plan

**Project:** declarative-vscodium
**Created:** 2025-11-05
**Status:** Planning
**Goal:** Migrate from VSCode to VSCodium with fully declarative configuration on NixOS

---

## Executive Summary

**Objective:** Replace proprietary VSCode with open-source VSCodium while maintaining all functionality, extensions, and settings in a declarative, reproducible way using NixOS Home Manager.

**Why VSCodium?**
- ✅ Fully open source (removes telemetry and proprietary bits)
- ✅ Binary compatible with VSCode
- ✅ Supports same extensions (via Open VSX Registry)
- ✅ Aligns with FOSS philosophy
- ✅ Available in nixpkgs

**Why Declarative?**
- ✅ Reproducible across machines
- ✅ Version controlled configuration
- ✅ Easy rollback if issues
- ✅ No manual extension installation
- ✅ Settings managed in Git

---

## Current State Analysis

### VSCode Installation (Current)
**Location:** Installed via system packages
**Config:** `~/.config/Code/User/settings.json`
**Extensions:** Managed via activation scripts in `home.nix`
**Keybindings:** `~/.config/Code/User/keybindings.json` (if customized)

### Extension Management (Current)
**Method:** Home Manager activation script
**File:** `home/mitso/home.nix:58-99`
**Extensions List:**
```
- alefragnani.project-manager
- anthropic.claude-code
- davidanson.vscode-markdownlint
- dracula-theme.theme-dracula
- github.vscode-github-actions
- gitlab.gitlab-workflow
- golang.go
- hashicorp.terraform
- mads-hartmann.bash-ide-vscode
- ms-kubernetes-tools.vscode-kubernetes-tools
- ms-python.debugpy
- ms-python.python
- ms-python.vscode-pylance
- ms-python.vscode-python-envs
- ms-vscode-remote.remote-wsl
- ms-vscode.powershell
- opentofu.vscode-opentofu
- pascalreitermann93.vscode-yaml-sort
- peterschmalfeldt.explorer-exclude
- redhat.vscode-yaml
- sandipchitale.vscode-kubernetes-logs
- saoudrizwan.claude-dev
- shd101wyy.markdown-preview-enhanced
- yzhang.markdown-all-in-one
```

**Update Mechanism:** Daily systemd timer + on-rebuild activation

---

## Migration Strategy

### Phase 1: Assessment & Backup
**Duration:** 30 minutes
**Risk:** Low

1. Export current VSCode configuration
2. Document current extensions and their versions
3. Backup keybindings and snippets
4. Test VSCodium installation in parallel (no conflicts)

### Phase 2: Declarative Configuration
**Duration:** 1-2 hours
**Risk:** Low

1. Create Home Manager VSCodium module
2. Declare settings.json in Nix
3. Set up extension management for VSCodium
4. Configure keybindings declaratively
5. Test configuration builds

### Phase 3: Extension Compatibility
**Duration:** 1 hour
**Risk:** Medium

1. Verify all extensions available in Open VSX
2. Test Microsoft extensions (may need workarounds)
3. Configure extension marketplace settings
4. Handle proprietary extensions (if any)

### Phase 4: Migration & Testing
**Duration:** 1 hour
**Risk:** Medium

1. Apply VSCodium configuration
2. Test all critical workflows
3. Verify extension functionality
4. Check language servers (Go, Python, etc.)
5. Validate Git integration

### Phase 5: Cleanup
**Duration:** 30 minutes
**Risk:** Low

1. Remove VSCode from system packages
2. Clean up old VSCode configs (optional backup)
3. Update documentation
4. Commit final configuration

---

## Technical Approach

### 1. Home Manager VSCodium Module

**File:** `~/.config/nixos/home/mitso/vscodium.nix`

```nix
{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    # Declarative extensions
    extensions = with pkgs.vscode-extensions; [
      # List extensions here
    ];

    # Declarative settings
    userSettings = {
      "editor.fontSize" = 14;
      "workbench.colorTheme" = "Dracula";
      # ... all settings
    };

    # Declarative keybindings
    keybindings = [
      {
        key = "ctrl+shift+p";
        command = "workbench.action.showCommands";
      }
      # ... custom keybindings
    ];
  };
}
```

**Benefits:**
- Settings version controlled
- Extensions automatically installed
- Reproducible across machines
- Easy rollback with git

### 2. Extension Sources

**Primary:** nixpkgs vscode-extensions
**Secondary:** vscode-marketplace (for unavailable extensions)
**Fallback:** Manual extension installation via Open VSX

**Strategy:**
```nix
extensions = with pkgs.vscode-extensions; [
  # From nixpkgs (preferred)
  golang.go
  ms-python.python

  # From marketplace (if needed)
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "extension-name";
      publisher = "publisher";
      version = "1.0.0";
      sha256 = "...";
    };
  })
];
```

### 3. Settings Migration

**Extract current settings:**
```bash
cat ~/.config/Code/User/settings.json > /tmp/vscode-settings.json
```

**Convert to Nix:**
```nix
userSettings = {
  "editor.fontSize" = 14;
  "editor.fontFamily" = "'Fira Code', monospace";
  "editor.fontLigatures" = true;
  # ... all settings
};
```

**Tool:** Manual conversion or use JSON-to-Nix tools

### 4. Extension Marketplace Configuration

**VSCodium uses Open VSX by default, but can use Microsoft marketplace:**

```nix
userSettings = {
  "extensions.autoUpdate" = false;  # Managed by Nix
  # Optional: Use Microsoft marketplace
  "extensions.autoCheckUpdates" = false;
};
```

**For Microsoft extensions:**
```bash
# Add product.json override if needed
```

---

## Extension Compatibility Analysis

### Tier 1: Available in nixpkgs (Preferred)
- ✅ golang.go
- ✅ ms-python.python
- ✅ ms-kubernetes-tools.vscode-kubernetes-tools
- ✅ redhat.vscode-yaml
- ✅ hashicorp.terraform

**Action:** Use from nixpkgs vscode-extensions

### Tier 2: Available in Open VSX
- Most community extensions
- Dracula theme
- Markdown extensions

**Action:** VSCodium will auto-fetch from Open VSX

### Tier 3: Microsoft-only Extensions
- Some Microsoft-specific extensions
- May require marketplace configuration

**Action:** Configure VSCodium to use Microsoft marketplace or find alternatives

### Tier 4: Proprietary Extensions (If any)
- Closed-source extensions not in Open VSX

**Action:** Find FOSS alternatives or manual installation

---

## Rollback Strategy

### If VSCodium Issues

**Quick Rollback:**
```bash
# Disable VSCodium module
# Re-enable VSCode in packages
sudo nixos-rebuild switch --rollback
```

**Gradual Rollback:**
```nix
# Keep VSCode installed alongside VSCodium
environment.systemPackages = with pkgs; [
  vscodium  # New
  vscode    # Old (keep for now)
];
```

**Test both editors until confident, then remove VSCode**

---

## Success Criteria

### Must Have
- ✅ All critical extensions working
- ✅ Settings preserved
- ✅ Keybindings functional
- ✅ Language servers operational (Go, Python, Bash)
- ✅ Git integration working
- ✅ Terminal integration working
- ✅ Debugging functional

### Nice to Have
- ✅ All theme/cosmetic extensions
- ✅ Productivity extensions
- ✅ Non-critical integrations

### Acceptable Losses
- ❌ Microsoft-proprietary features (telemetry, account sync)
- ❌ Extensions not available in FOSS (find alternatives)

---

## Timeline

### Estimated Duration: 4-5 hours total

**Day 1 (2 hours):**
- Phase 1: Assessment & Backup (30 min)
- Phase 2: Declarative Configuration (1.5 hours)

**Day 2 (2 hours):**
- Phase 3: Extension Compatibility (1 hour)
- Phase 4: Migration & Testing (1 hour)

**Day 3 (30 min):**
- Phase 5: Cleanup

**Buffer:** 30 min for unexpected issues

---

## Risk Assessment

### High Risk
- **Extension incompatibility** → Mitigation: Keep VSCode as fallback
- **Settings not transferring** → Mitigation: Manual comparison

### Medium Risk
- **Language server issues** → Mitigation: Test thoroughly before removing VSCode
- **Workflow disruption** → Mitigation: Migrate during low-work period

### Low Risk
- **Build failures** → Mitigation: NixOS rollback
- **Config errors** → Mitigation: Git version control

---

## Resources Needed

### Documentation
- [Home Manager VSCode options](https://nix-community.github.io/home-manager/options.html#opt-programs.vscode.enable)
- [VSCodium documentation](https://github.com/VSCodium/vscodium)
- [Open VSX Registry](https://open-vsx.org/)
- [NixOS VSCodium examples](https://github.com/search?q=vscodium+home-manager)

### Tools
- `nix search nixpkgs vscode-extensions`
- `nix repl` for testing Nix expressions
- `git` for version control

### Time
- 4-5 hours total over 2-3 days

---

## Post-Migration

### Validation
- [ ] All extensions loaded
- [ ] Settings applied correctly
- [ ] Keybindings work
- [ ] Go development works
- [ ] Python development works
- [ ] Kubernetes manifests edit correctly
- [ ] Git operations functional
- [ ] Terminal integrated correctly

### Documentation Updates
- [ ] Update desktop-workspace context
- [ ] Add VSCodium to instructions
- [ ] Document any custom configurations
- [ ] Note extension sources

### Optimization
- [ ] Remove unused extensions
- [ ] Review settings for NixOS-specific optimizations
- [ ] Configure Plasma integration (if available)

---

## Alternative Approaches Considered

### Option A: Imperative VSCodium (Not Chosen)
**Pros:** Quick, familiar workflow
**Cons:** Not reproducible, manual extension management

### Option B: Hybrid Approach (Not Chosen)
**Pros:** Easier migration
**Cons:** Partially defeats purpose of declarative config

### Option C: Fully Declarative (CHOSEN)
**Pros:** Reproducible, version controlled, aligns with NixOS philosophy
**Cons:** Initial setup time, learning curve

**Rationale:** Long-term benefits outweigh short-term effort

---

## Notes

- VSCodium binary is drop-in replacement for VSCode
- Most workflows should work identically
- Extension marketplace is primary difference
- Can run both editors simultaneously during transition
- Home Manager makes config portable across machines

---

**Last Updated:** 2025-11-05
**Status:** Ready for implementation
