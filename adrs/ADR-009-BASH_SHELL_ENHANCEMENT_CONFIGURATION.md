# ADR-009: Bash Shell Enhancement Configuration via Chezmoi

**Status:** ✅ Accepted
**Date:** 2025-12-03
**Author:** Mitsio
**Context:** Standardizing configuration of bash shell enhancements (ble.sh, etc.)

---

## Context and Problem Statement

When adding shell enhancements like ble.sh (Bash Line Editor) or other tools that modify shell behavior, there's potential confusion about where configuration should live:

1. **Package installation** - Where should the tool itself be installed?
2. **Shell configuration** - Where should .bashrc/.bash_profile modifications go?
3. **Tool-specific config** - Where should tool config files go?

Without clear guidelines, we risk:
- ❌ Mixing concerns (package management + dotfile management)
- ❌ Non-portable configurations
- ❌ Difficult migration to other distros (Fedora Atomic)
- ❌ Inconsistency with existing ADRs (ADR-005, ADR-007)

**Question:** How should bash shell enhancements be managed across home-manager and chezmoi?

---

## Decision

**Shell enhancements follow a TWO-LAYER approach:**

### Layer 1: Package Installation (Home-Manager)
**Home-Manager is responsible for:**
- ✅ Installing the shell enhancement tool (ble.sh, fzf, etc.)
- ✅ Making the tool available in PATH
- ✅ Version management via nixpkgs
- ✅ Dependencies and build requirements

**Example (home-manager/shell.nix):**
```nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    blesh  # Bash Line Editor with fish-like autosuggestions
  ];
}
```

### Layer 2: Shell Configuration (Chezmoi)
**Chezmoi is responsible for:**
- ✅ .bashrc modifications to source/enable the tool
- ✅ Tool-specific configuration files
- ✅ User preferences and customization
- ✅ Machine-specific settings via templates

**Example (dotfiles/dot_bashrc.tmpl):**
```bash
# ble.sh - Bash Line Editor (fish-like autosuggestions)
if [[ -f ~/.nix-profile/share/blesh/ble.sh ]]; then
    source ~/.nix-profile/share/blesh/ble.sh
fi
```

**Example (dotfiles/dot_config/blesh/init.sh):**
```bash
# ble.sh configuration
bleopt autocomplete_limit=100
bleopt complete_auto_delay=300
```

---

## Rationale

### Why This Split?

#### 1. **Separation of Concerns**
- **Home-Manager:** "What tools do I have?"
- **Chezmoi:** "How are those tools configured?"
- Clear boundary: Installation vs Configuration

#### 2. **Cross-Platform Compatibility**
```nix
# Home-Manager (NixOS-specific)
home.packages = [ pkgs.blesh ];

# Chezmoi (works on any Linux with ble.sh installed)
{{ if (eq .chezmoi.os "linux") }}
source ~/.local/share/blesh/ble.sh
{{ end }}
```

#### 3. **Consistency with Existing ADRs**

**Per ADR-005 (Chezmoi Migration Criteria):**
- ✅ `.bashrc` is a "simple config file" → Chezmoi
- ✅ "Cross-platform compatibility needed" → Chezmoi
- ✅ "Application settings only" → Chezmoi
- ❌ "Package management required" → Home-Manager

**Per ADR-007 (Autostart Tools via Home-Manager):**
- Pattern established: Home-Manager installs, manages lifecycle
- But: Configuration files remain separate

#### 4. **Migration Path to Fedora Atomic**
When migrating from NixOS to Fedora Atomic:
- **Home-Manager layer** → Replace with rpm-ostree/Toolbx/distrobox
- **Chezmoi layer** → Remains unchanged (already portable!)

---

## Implementation Pattern

### Pattern for ANY Shell Enhancement Tool

**Step 1: Install via Home-Manager**
```nix
# home-manager/shell.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    tool-name
  ];
}
```

**Step 2: Configure via Chezmoi**
```bash
# dotfiles/dot_bashrc.tmpl
{{ if (lookPath "tool-name") }}
# Tool Name - Description
source /path/to/tool-name/init.sh
{{ end }}
```

**Step 3: Tool Config in Chezmoi** (if needed)
```
dotfiles/dot_config/tool-name/config.yaml
```

---

## Specific Guidelines

### ✅ Goes in Chezmoi (dotfiles/)

| Item | Location | Example |
|------|----------|---------|
| .bashrc sourcing | `dotfiles/dot_bashrc.tmpl` | `source ~/.nix-profile/share/blesh/ble.sh` |
| .bash_profile | `dotfiles/dot_bash_profile.tmpl` | PATH additions, env vars |
| Tool config files | `dotfiles/dot_config/<tool>/` | `~/.config/blesh/init.sh` |
| Bash aliases | `dotfiles/dot_bashrc.tmpl` | `alias ll='ls -lah'` |
| Bash functions | `dotfiles/dot_bashrc.tmpl` | Custom shell functions |
| Prompt (PS1) | `dotfiles/dot_bashrc.tmpl` | Starship/custom prompt |

### ✅ Goes in Home-Manager (home-manager/)

| Item | Location | Why |
|------|----------|-----|
| Package installation | `home-manager/shell.nix` | Nix package management |
| Environment variables | `home-manager/shell.nix` | System integration (PATH, etc.) |
| Shell programs.* modules | `home-manager/shell.nix` | Complex Nix derivations |

### ❌ NEVER Do This

| Anti-Pattern | Why Wrong | Correct Approach |
|--------------|-----------|------------------|
| Install ble.sh via `git clone` in .bashrc | Non-declarative, version chaos | Install via home-manager |
| Put entire .bashrc in home-manager | Not portable, Nix-locked | Manage via chezmoi |
| Duplicate config in both | Sync nightmare | Pick ONE based on criteria |

---

## Migration Strategy

### For Existing Home-Manager Shell Configs

**Audit Checklist:**
```bash
# Check what's currently in home-manager
grep -r "bashrc\|bash_profile" home-manager/
```

**Migration Steps:**

1. **Identify shell config in home-manager**
   - programs.bash.initExtra
   - programs.bash.bashrcExtra
   - home.file.".bashrc"

2. **Extract pure configuration**
   - Tool sourcing → Move to chezmoi
   - Aliases → Move to chezmoi
   - Functions → Move to chezmoi
   - ENV vars needed by Nix → Keep in home-manager

3. **Move to chezmoi**
   ```bash
   chezmoi add ~/.bashrc
   chezmoi cd
   git add dot_bashrc.tmpl
   ```

4. **Update home-manager**
   - Remove shell config blocks
   - Keep only package installation

5. **Test**
   ```bash
   chezmoi apply
   source ~/.bashrc
   # Verify tools work
   ```

---

## Examples

### Example 1: ble.sh (Bash Line Editor)

**Home-Manager (home-manager/shell.nix):**
```nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    blesh  # Bash Line Editor
  ];
}
```

**Chezmoi (dotfiles/dot_bashrc.tmpl):**
```bash
# ble.sh - Bash Line Editor (fish-like autosuggestions)
# Only load if installed
if [[ -f ~/.nix-profile/share/blesh/ble.sh ]]; then
    source ~/.nix-profile/share/blesh/ble.sh
fi
```

**Chezmoi (dotfiles/dot_config/blesh/init.sh):**
```bash
# ble.sh configuration
bleopt autocomplete_limit=100
bleopt complete_auto_delay=300
bleopt complete_auto_wordbreaks=$' \t\n'
```

### Example 2: Atuin (Already Correct!)

**Home-Manager (home-manager/atuin.nix):**
```nix
{ config, pkgs, ... }:
{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };
}
```

**Chezmoi (dotfiles/dot_config/atuin/config.toml):**
```toml
search_mode = "fuzzy"
filter_mode = "global"
```

**Analysis:** ✅ Already follows the pattern!
- Home-Manager: Installs + enables bash integration
- Chezmoi: User configuration

---

## Consequences

### Positive

✅ **Clear separation of concerns:** Install vs Configure
✅ **Portable dotfiles:** Work across NixOS, Fedora, Ubuntu
✅ **Easier migration:** Chezmoi layer is distro-agnostic
✅ **Consistent with ADR-005:** Follows established criteria
✅ **Version control:** Both layers tracked separately
✅ **Type-safe install:** Nix catches missing dependencies
✅ **Flexible config:** Chezmoi templates for machine-specific settings

### Negative

⚠️ **Two-step setup:** Install (home-manager) + Configure (chezmoi)
⚠️ **Learning curve:** Need to understand both tools
⚠️ **Coordination needed:** Package version in HM, config in chezmoi

### Neutral

ℹ️ **Not a new pattern:** Already used for atuin, kitty, etc.
ℹ️ **Migration work:** Existing configs may need splitting
ℹ️ **Documentation needed:** Clear examples for each tool

---

## Decision Matrix

**Use this to decide where configuration goes:**

```
Is it a package/binary?
├─ YES → Home-Manager (shell.nix)
└─ NO → Is it shell configuration?
    ├─ YES → Chezmoi (dot_bashrc.tmpl)
    └─ NO → Is it tool-specific config?
        ├─ YES → Chezmoi (dot_config/<tool>/)
        └─ NO → Consult ADR-005
```

---

## Review Schedule

**Next Review:** 2025-06-03 (6 months)

**Review Criteria:**
- Are shell enhancements consistently split across layers?
- Is migration to Fedora Atomic progressing smoothly?
- Any tools that don't fit this pattern?
- User satisfaction with the approach?

---

## References

- **ADR-005:** Chezmoi Migration Criteria
- **ADR-007:** Autostart Tools via Home-Manager
- **ble.sh:** https://github.com/akinomyoga/ble.sh
- **Chezmoi Templates:** https://www.chezmoi.io/user-guide/templating/
- **Home-Manager:** https://nix-community.github.io/home-manager/

---

## Related Decisions

- **ADR-005:** Establishes dotfile management criteria → Extended here for shell
- **ADR-007:** Autostart via home-manager → Similar install/configure split
- **ADR-001:** Unstable pkgs in HM → Applies to shell enhancement packages

---

**Decision:** ✅ Accepted
**Status:** ✅ Active (2025-12-03)
