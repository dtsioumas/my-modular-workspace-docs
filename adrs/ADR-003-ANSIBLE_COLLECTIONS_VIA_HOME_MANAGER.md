# ADR 001: Ansible Collections Installation via Home-Manager

**Date:** 2025-11-23
**Status:** ✅ Accepted
**Author:** mitsio

---

## Context

We need a consistent, declarative way to manage Ansible collections (like `rolehippie.rclone`) across our workspace. There are two primary approaches:

1. **Manual Installation:** Run `ansible-galaxy role install` manually or in scripts
2. **Home-Manager Integration:** Declare collections in home-manager and install via activation scripts

Our workspace already uses home-manager as the primary configuration management tool for user-level packages and configurations. The question is whether Ansible collections should follow the same pattern.

---

## Decision

**We will install ALL Ansible collections through home-manager activation scripts.**

Collections will be declared in a dedicated Nix module (`home-manager/ansible-collections.nix`) and automatically installed/updated on every `home-manager switch`.

---

## Rationale

### 1. **Consistency with Existing Architecture**
- Our workspace already uses home-manager for:
  - Package installation (ansible, ansible-lint, yamllint)
  - VSCode/VSCodium extensions (via activation scripts)
  - Claude Code CLI (via activation scripts)
  - Pre-commit hooks (via activation scripts)
- Ansible collections are just another type of user-level dependency

### 2. **Declarative Configuration**
- **Current approach (manual):**
  ```bash
  # Must remember to run this
  ansible-galaxy role install rolehippie.rclone
  ```
  - Not tracked in version control
  - Easy to forget
  - No automatic updates
  - Manual intervention required on new machines

- **New approach (home-manager):**
  ```nix
  # Declared in ansible-collections.nix
  ansible_collections = [
    "rolehippie.rclone"
    "community.general"
  ];
  ```
  - Tracked in git
  - Automatically applied
  - Version controlled
  - Works on all machines

### 3. **Reproducibility**
- New machine setup: Just run `home-manager switch`
- No manual steps to remember
- Consistent across all workspace instances
- Atomic updates (collections installed as part of rebuild)

### 4. **Dependency Management**
- Home-manager already manages ansible package
- Collections are extensions of ansible
- Logical grouping of related dependencies

### 5. **Update Workflow**
- Collections update automatically on rebuild
- Force flag prevents version mismatches
- Centralized control over which collections are used

---

## Implementation

### File: `home-manager/ansible-collections.nix`

```nix
{ config, pkgs, lib, ... }:

{
  # Install Ansible collections on every home-manager rebuild
  home.activation.installAnsibleCollections = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v ansible-galaxy >/dev/null 2>&1; then
      echo "Installing Ansible collections..."

      # Role collections (older format)
      ansible-galaxy role install rolehippie.rclone --force || true

      # Collection collections (newer format)
      # ansible-galaxy collection install community.general --force || true

      echo "Ansible collections installed"
    fi
  '';

  # Ensure ansible-galaxy is available
  home.packages = with pkgs; [
    ansible
    ansible-lint
    yamllint
  ];
}
```

### Integration with `home.nix`

```nix
imports = [
  ./shell.nix
  ./claude-code.nix
  ./git-hooks.nix
  ./ansible-collections.nix  # ← Add this
  # ... other imports
];
```

---

## Consequences

### Positive

✅ **Fully Declarative:** All dependencies declared in one place
✅ **Reproducible:** `home-manager switch` installs everything
✅ **Version Controlled:** Collections tracked in git via Nix config
✅ **Automated Updates:** Collections update on every rebuild
✅ **Multi-Machine Consistency:** Same collections on all machines
✅ **No Manual Steps:** Zero manual intervention required
✅ **Self-Documenting:** Nix config serves as documentation

### Negative

⚠️ **Rebuild Time:** Adds ~5-10 seconds to home-manager rebuilds
⚠️ **Force Flag Required:** `--force` needed to prevent version errors
⚠️ **Limited Version Control:** Can't pin specific collection versions easily

### Neutral

ℹ️ **Learning Curve:** Users need to edit Nix instead of running ansible-galaxy
ℹ️ **Additional Nix Module:** One more file to maintain

---

## Alternatives Considered

### Alternative 1: Manual ansible-galaxy Commands

**Approach:**
```bash
ansible-galaxy role install rolehippie.rclone
```

**Rejected because:**
- ❌ Not declarative
- ❌ Not tracked in version control
- ❌ Easy to forget
- ❌ Inconsistent across machines
- ❌ Requires manual intervention

### Alternative 2: Ansible Playbook for Collection Installation

**Approach:**
```yaml
- name: Install Ansible collections
  command: ansible-galaxy role install rolehippie.rclone
```

**Rejected because:**
- ❌ Circular dependency (need ansible to install ansible tools)
- ❌ Requires running playbook manually
- ❌ Still not fully declarative
- ❌ Adds complexity without benefit

### Alternative 3: Nix Package Override

**Approach:**
Create Nix derivation that bundles ansible + collections

**Rejected because:**
- ❌ Overly complex for our use case
- ❌ Harder to maintain
- ❌ Breaks ansible-galaxy workflow for other collections
- ❌ Less flexible

### Alternative 4: System-Level Installation

**Approach:**
Install collections at NixOS system level (`/etc/nixos/`)

**Rejected because:**
- ❌ Ansible is user-level concern, not system-level
- ❌ Breaks multi-user separation
- ❌ Inconsistent with our home-manager-first architecture
- ❌ Requires sudo for updates

---

## Migration Path

### Phase 1: Create Module ✅
1. Create `home-manager/ansible-collections.nix`
2. Add activation script for `rolehippie.rclone`
3. Add to `home.nix` imports

### Phase 2: Test
1. Run `home-manager switch`
2. Verify collection installed: `ansible-galaxy role list`
3. Test playbook execution

### Phase 3: Document
1. Update `ansible/docs/collections/rclone/RESEARCH.md`
2. Create this ADR
3. Update README files

### Phase 4: Expand
1. Add more collections as needed
2. Create collection inventory in ADR
3. Document version requirements

---

## Collection Inventory

### Currently Managed

| Collection | Type | Version | Purpose |
|-----------|------|---------|---------|
| `rolehippie.rclone` | Role | Latest | Google Drive sync automation |

### Future Candidates

| Collection | Type | Reason |
|-----------|------|--------|
| `community.general` | Collection | Common Ansible modules |
| `ansible.posix` | Collection | POSIX system management |
| `community.docker` | Collection | Docker management (if needed) |

---

## Verification

After implementation, verify with:

```bash
# Check collections are installed
ansible-galaxy role list | grep rolehippie

# Verify collection works
ansible-playbook playbooks/rclone-gdrive-sync-v2.yml --check

# Test on fresh machine
rm -rf ~/.ansible/roles/rolehippie.rclone
home-manager switch
ansible-galaxy role list | grep rolehippie  # Should show installed
```

---

## Related Decisions

- **home-manager/git-hooks.nix:** Pre-commit hooks installed via activation script (same pattern)
- **home-manager/claude-code.nix:** CLI tools installed via activation script (same pattern)
- **home-manager/vscodium.nix:** Extensions managed via activation script (same pattern)

This ADR extends the established pattern of managing user-level dependencies through home-manager activation scripts.

---

## References

- Home-Manager Activation Scripts: https://nix-community.github.io/home-manager/index.xhtml#sec-usage-activation
- Ansible Galaxy CLI: https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html
- Our Pre-Commit Setup: `ansible/docs/development/pre-commit-setup.md`
- Collection Research: `ansible/docs/collections/rclone/RESEARCH.md`

---

## Status History

| Date | Status | Notes |
|------|--------|-------|
| 2025-11-23 | ✅ Accepted | Initial decision, implementing for rolehippie.rclone |

---

## Review Schedule

**Next Review:** 2025-12-23 (1 month)

**Review Criteria:**
- Is the pattern working well?
- Are rebuild times acceptable?
- Any issues with collection versions?
- Should we add more collections?
