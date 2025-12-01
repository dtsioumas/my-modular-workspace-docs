# ADR-007: Autostart Tools via Home-Manager

**Status:** ✅ Accepted
**Date:** 2025-12-01
**Author:** Mitsio
**Context:** Standardizing autostart tool management across the workspace

---

## Context and Problem Statement

Currently, autostart configurations for user applications are scattered across multiple management systems:
1. **Home-Manager:** Some tools configured via `xdg.configFile` or service modules
2. **Chezmoi:** Desktop files in `dotfiles/dot_config/autostart/`
3. **Manual:** Direct placement in `~/.config/autostart/`

This fragmentation creates several issues:
- **Inconsistency:** Unclear which system manages which autostart
- **Non-declarative:** Chezmoi-managed autostart files are imperative, not declarative
- **Difficult to audit:** Can't easily see all autostart applications
- **Version control confusion:** Autostart split between home-manager repo and dotfiles repo
- **No dependency tracking:** Can't ensure application is installed before autostart enabled

**Question:** Where should ALL user application autostart configurations be managed?

---

## Decision

**ALL autostart configurations for user applications MUST be managed via Home-Manager.**

Autostart configurations will be declared in Home-Manager using one of these methods (in order of preference):

1. **Native service modules** (when available):
   ```nix
   services.copyq.enable = true;
   ```

2. **systemd user services** (for programs supporting systemd):
   ```nix
   systemd.user.services.myapp = {
     Unit = {
       Description = "My Application";
       After = [ "graphical-session.target" ];
     };
     Service = {
       ExecStart = "${pkgs.myapp}/bin/myapp";
       Restart = "on-failure";
     };
     Install.WantedBy = [ "graphical-session.target" ];
   };
   ```

3. **XDG autostart desktop files** (for GUI apps without systemd support):
   ```nix
   xdg.configFile."autostart/myapp.desktop".source = "${pkgs.myapp}/share/applications/myapp.desktop";
   ```

**Chezmoi will NO LONGER manage autostart configurations.** Any existing autostart files in chezmoi must be migrated to home-manager.

---

## Rationale

### Why Home-Manager for Autostart?

#### 1. **Declarative Configuration**
- Home-Manager provides declarative autostart management
- Clear dependency on package installation
- Can't autostart an application that isn't installed

#### 2. **Single Source of Truth**
- All user-level services in one place (home-manager repo)
- Easy to audit: `grep -r "autostart\|services\." home-manager/`
- Clear ownership: home-manager manages user environment

#### 3. **Version Control Benefits**
- All autostart in home-manager git repo
- Atomic updates: `home-manager switch` enables/disables all at once
- Rollback support: `home-manager generations` shows history

#### 4. **Dependency Tracking**
```nix
# Good: Home-Manager ensures copyq is installed before autostart
services.copyq.enable = true;

# Bad: Chezmoi can create autostart file even if copyq not installed
# dotfiles/dot_config/autostart/copyq.desktop (might fail on boot)
```

#### 5. **Conditional Autostart**
```nix
# Example: Only autostart on specific machines
services.dropbox.enable = config.networking.hostName == "shoshin";

# Example: Only if GUI installed
services.copyq.enable = config.services.xserver.enable;
```

#### 6. **Consistency with Existing Architecture**
- Per ADR-001: Home-Manager manages all user packages
- Logical extension: Home-Manager should also manage when those packages start
- Per ADR-003: Home-Manager manages ansible collections via activation scripts
- Pattern established: Home-Manager is the user-level orchestrator

### Why NOT Chezmoi for Autostart?

#### 1. **Chezmoi is for Configuration Files, Not Services**
- Chezmoi's strength: Template-based config files with secrets
- Autostart is **service orchestration**, not static config
- Belongs in service manager (systemd/home-manager), not file manager

#### 2. **No Dependency Management**
```bash
# Chezmoi can create autostart file even if app not installed:
chezmoi add ~/.config/autostart/myapp.desktop
# Result: myapp.desktop exists but myapp binary missing → boot errors
```

#### 3. **Cannot Express Logic**
- Chezmoi templates can't easily express "autostart only if X"
- Home-Manager has full Nix language for conditions

#### 4. **Harder to Audit**
```bash
# Chezmoi: Must search dotfiles
find dotfiles -name "*.desktop" -path "*/autostart/*"

# Home-Manager: Grep one repo
grep -r "autostart\|services\." home-manager/
```

---

## Consequences

### Positive

✅ **Single source of truth:** All autostart in home-manager repo
✅ **Declarative:** Clear, version-controlled autostart configuration
✅ **Type-safe:** Nix catches configuration errors before apply
✅ **Dependency-aware:** Can't autostart app that isn't installed
✅ **Conditional logic:** Easy to enable autostart per-machine or per-condition
✅ **Rollback support:** `home-manager generations` shows autostart history
✅ **Consistency:** Aligns with ADR-001 (home-manager for user packages)
✅ **Easier auditing:** One place to see all autostart applications

### Negative

⚠️ **Migration effort:** Must move existing autostart from chezmoi to home-manager
⚠️ **Learning curve:** Need to understand home-manager service syntax
⚠️ **More complex for simple cases:** Adding autostart requires Nix knowledge

### Neutral

ℹ️ **Chezmoi still manages static configs:** Config files remain in chezmoi (e.g., `~/.config/myapp/config.yaml`)
ℹ️ **Two-step process:** Install via home-manager (package + autostart), configure via chezmoi (config file)
ℹ️ **NixOS services vs home-manager services:** System services still in NixOS config, only user services in home-manager

---

## Migration Strategy

### Phase 1: Identify Current Autostart Configurations

**Chezmoi-managed autostart:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
find . -path "*/autostart/*.desktop"
```

**Currently known:**
- `dot_config/autostart/copyq.desktop` ✅ Migrate to home-manager

**Manual autostart:**
```bash
ls ~/.config/autostart/
```

### Phase 2: Migrate to Home-Manager

**For each autostart application:**

1. **Check if native home-manager module exists:**
   ```bash
   # Search home-manager options
   man home-configuration.nix | grep -A 5 "services\.<appname>"
   ```

2. **If native module exists (BEST OPTION):**
   ```nix
   # Example: copyq has services.copyq module (if it exists)
   services.copyq.enable = true;
   ```

3. **If no native module, use XDG autostart:**
   ```nix
   # Example: For apps without home-manager module
   xdg.configFile."autostart/myapp.desktop".source =
     "${pkgs.myapp}/share/applications/myapp.desktop";
   ```

4. **If needs custom configuration, create systemd service:**
   ```nix
   systemd.user.services.myapp = {
     Unit = {
       Description = "My Application";
       After = [ "graphical-session.target" ];
     };
     Service = {
       ExecStart = "${pkgs.myapp}/bin/myapp --custom-flag";
       Restart = "on-failure";
     };
     Install.WantedBy = [ "graphical-session.target" ];
   };
   ```

### Phase 3: Remove from Chezmoi

**After migrating to home-manager:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Remove autostart file from chezmoi
chezmoi forget ~/.config/autostart/myapp.desktop

# Remove from git
git rm dot_config/autostart/myapp.desktop
git commit -m "chore: migrate myapp autostart to home-manager (per ADR-007)"
```

### Phase 4: Document Migration

**Update documentation:**
- `docs/home-manager/README.md`: Add section on autostart management
- Create `docs/home-manager/autostart-guide.md`: How to add/remove autostart apps

---

## Implementation Examples

### Example 1: CopyQ (Clipboard Manager)

**Before (Chezmoi):**
```
dotfiles/dot_config/autostart/copyq.desktop
```

**After (Home-Manager):**

**Option A: If home-manager has native module:**
```nix
# home-manager/copyq.nix
{ config, pkgs, ... }:
{
  # Install package
  home.packages = [ pkgs.copyq ];

  # Enable autostart (if native module exists)
  services.copyq.enable = true;
}
```

**Option B: If no native module, use XDG autostart:**
```nix
# home-manager/copyq.nix
{ config, pkgs, ... }:
{
  # Install package
  home.packages = [ pkgs.copyq ];

  # Enable autostart via XDG
  xdg.configFile."autostart/copyq.desktop".source =
    "${pkgs.copyq}/share/applications/copyq.desktop";
}
```

### Example 2: Conditional Autostart (Dropbox only on main desktop)

```nix
# home-manager/dropbox.nix
{ config, pkgs, lib, ... }:
{
  # Install on all machines
  home.packages = [ pkgs.dropbox ];

  # Only autostart on shoshin (main desktop)
  services.dropbox = {
    enable = config.networking.hostName == "shoshin";
    path = "${config.home.homeDirectory}/Dropbox";
  };
}
```

### Example 3: Custom Systemd Service with Flags

```nix
# home-manager/syncthing.nix
{ config, pkgs, ... }:
{
  systemd.user.services.syncthing = {
    Unit = {
      Description = "Syncthing - File Synchronization";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${pkgs.syncthing}/bin/syncthing -no-browser -logflags=0";
      Restart = "on-failure";
      SuccessExitStatus = [ 3 4 ];
      RestartForceExitStatus = [ 3 4 ];
    };

    Install.WantedBy = [ "default.target" ];
  };
}
```

---

## Verification

**After migration, verify:**

1. **Autostart working:**
   ```bash
   # List systemd user services
   systemctl --user list-units --type=service

   # Check specific service
   systemctl --user status copyq

   # List XDG autostart files (managed by home-manager)
   ls -lh ~/.config/autostart/
   ```

2. **No chezmoi-managed autostart:**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
   find . -path "*/autostart/*.desktop"
   # Should return: (empty)
   ```

3. **Home-manager manages all autostart:**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
   grep -r "autostart\|services\." *.nix
   # Should show all autostart configurations
   ```

---

## Current Autostart Inventory (As of 2025-12-01)

**Migrated Autostart Applications:**

| Application | Home-Manager Module | Implementation | Status |
|-------------|---------------------|----------------|--------|
| CopyQ | `autostart.nix` | `home.file.".config/autostart/copyq.desktop"` | ✅ Complete |
| KeePassXC | `autostart.nix` | `home.file.".config/autostart/org.keepassxc.KeePassXC.desktop"` | ✅ Complete |

**Migration Checklist:**
- [x] Identify all autostart in chezmoi
- [x] Identify all manual autostart in `~/.config/autostart/`
- [x] Migrate CopyQ to home-manager
- [x] Migrate KeePassXC to home-manager
- [x] Create `autostart.nix` module
- [x] Remove autostart directory from chezmoi
- [x] Update `.chezmoiignore` to exclude autostart
- [x] Verify no remaining autostart in chezmoi
- [x] Update MIGRATION_STATUS.md

---

## Alternatives Considered

### Alternative 1: Keep Chezmoi for Autostart

**Rejected because:**
- ❌ Not declarative
- ❌ No dependency tracking (can autostart non-existent app)
- ❌ Inconsistent with ADR-001 (home-manager manages user packages)
- ❌ Harder to audit (split across two repos)

### Alternative 2: NixOS System-Level Autostart

**Rejected because:**
- ❌ Autostart is user-level, not system-level
- ❌ Breaks multi-user separation
- ❌ Inconsistent with ADR-001 (user packages via home-manager)
- ❌ Requires sudo for updates

### Alternative 3: Split Approach (Some in Chezmoi, Some in Home-Manager)

**Rejected because:**
- ❌ Worst of both worlds (fragmentation)
- ❌ Unclear ownership (which system for which app?)
- ❌ Harder to maintain
- ❌ Confusing for future reference

---

## Related Decisions

- **ADR-001:** Home-Manager manages user packages → Logical extension: also manages when they start
- **ADR-003:** Home-Manager activation scripts for tools → Pattern: home-manager orchestrates user environment
- **ADR-008:** Automated jobs via home-manager → Consistent approach: home-manager for all automation

---

## Review Schedule

**Next Review:** 2025-12-31 (1 month after migration complete)

**Review Criteria:**
- Are all autostart applications in home-manager?
- Is chezmoi free of autostart configurations?
- Is the approach working well?
- Any issues or edge cases discovered?

---

## References

- Home-Manager Services: https://nix-community.github.io/home-manager/options.xhtml#opt-services
- Home-Manager XDG: https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configFile
- Systemd User Services: https://wiki.archlinux.org/title/Systemd/User
- Discussion: my-modular-workspace architecture (2025-12-01)

---

**Decision:** ✅ Accepted
**Status:** ✅ Implemented (2025-12-01)
