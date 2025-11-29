# Git Hooks Integration with Home-Manager

**Author:** mitsio
**Date:** 2025-11-23
**Module:** `home-manager/git-hooks.nix`

---

## Overview

This document describes the integration of **cachix/git-hooks.nix** with home-manager for automating Ansible quality checks via pre-commit hooks.

## Purpose

Ensure Ansible playbooks and YAML files are automatically linted and validated **before** they are committed to git, preventing broken code from entering the repository.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     home-manager                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                   git-hooks.nix                         │  │
│  │  • Installs pre-commit, ansible-lint, yamllint         │  │
│  │  • Activates hooks in ansible directory on switch      │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│            ansible/.pre-commit-config.yaml                   │
│  • Defines which hooks run on commit                        │
│  • ansible-lint (production profile)                        │
│  • yamllint (.yamllint config)                              │
│  • check-yaml, check-merge-conflict, etc.                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Git Commit Workflow                         │
│  1. Developer: git add playbooks/foo.yml                    │
│  2. Developer: git commit -m "..."                          │
│  3. Pre-commit: Run hooks automatically                     │
│  4. If PASS: Commit succeeds                                │
│  5. If FAIL: Commit blocked, show errors                    │
└─────────────────────────────────────────────────────────────┘
```

## Implementation

### Module: `git-hooks.nix`

**Location:** `~/.MyHome/MySpaces/my-modular-workspace/home-manager/git-hooks.nix`

```nix
{ config, pkgs, lib, ... }:

{
  # Install required packages
  home.packages = with pkgs; [
    pre-commit
    ansible
    ansible-lint
    yamllint
  ];

  # Auto-install hooks in ansible directory on home-manager switch
  home.activation.installAnsiblePreCommitHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ANSIBLE_DIR="$HOME/.MyHome/MySpaces/my-modular-workspace/ansible"
    if [ -d "$ANSIBLE_DIR/.git" ]; then
      echo "Installing pre-commit hooks for ansible directory..."
      cd "$ANSIBLE_DIR"
      ${pkgs.pre-commit}/bin/pre-commit install --install-hooks 2>/dev/null || true
    fi
  '';
}
```

### Integration in `home.nix`

```nix
{
  imports = [
    ./git-hooks.nix
    # ... other modules
  ];
}
```

---

## Activation Script Explained

### `home.activation.installAnsiblePreCommitHooks`

This activation script runs **after** home-manager has finished writing files (`writeBoundary`).

**What it does:**
1. Checks if `ansible/.git` exists (is it a git repository?)
2. Changes to ansible directory
3. Runs `pre-commit install --install-hooks`
   - Installs git hooks in `.git/hooks/`
   - Downloads and caches hook dependencies
   - Makes hooks executable

**When it runs:**
- Every time you run `home-manager switch`
- Ensures hooks are always installed even if you delete `.git/hooks/`

**Why `|| true`:**
- Don't fail home-manager switch if pre-commit install fails
- Allows graceful degradation (user can manually install later)

---

## Benefits of This Approach

### 1. Declarative Configuration ✅
- All tools defined in Nix
- Version-controlled in home-manager
- Reproducible across machines

### 2. Automatic Installation ✅
- Hooks install automatically on `home-manager switch`
- No manual `pre-commit install` needed (but harmless if run)
- Always up-to-date with home-manager state

### 3. No Overhead ⚡
- Tools pre-built by Nix (no compilation on install)
- Fast hook execution (no nix-shell startup time)
- Garbage collection protection (tools won't be deleted)

### 4. Consistent Environment 🔒
- Same tool versions across all developers (if using shared config)
- No Python virtualenv conflicts
- No `pip install` required

### 5. Works Without Flakes 📦
- Compatible with standalone home-manager
- No need to convert to flakes (though flakes are supported)
- Simple `imports = [ ./git-hooks.nix ]`

---

## How Hooks Are Triggered

### On `git commit`:

```bash
$ cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
$ git add playbooks/foo.yml
$ git commit -m "Add new playbook"

# Pre-commit hooks run automatically:
[ansible-lint] Running...
[yamllint] Running...
[check-yaml] Running...

# If all pass:
[main abc1234] Add new playbook
 1 file changed, 50 insertions(+)

# If any fail:
[ansible-lint] Failed
- playbooks/foo.yml:10: [name] All tasks should be named

Error: Commit blocked by pre-commit hooks
```

### Manual Runs:

```bash
# Run all hooks manually
pre-commit run --all-files

# Run specific hook
pre-commit run ansible-lint

# Skip hooks for one commit (emergency only!)
git commit --no-verify -m "Emergency fix"
```

---

## Updating Hook Versions

### Auto-Update (Recommended):

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
pre-commit autoupdate
```

This updates `.pre-commit-config.yaml` with latest hook versions.

### Manual Update in `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/ansible/ansible-lint
    rev: v24.12.2  # Change this to newer version
    hooks:
      - id: ansible-lint
```

---

## Troubleshooting

### Hooks not running on commit

**Solution:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
pre-commit install
```

### Hooks fail with "command not found"

**Check tools are installed:**
```bash
which ansible-lint
which yamllint
which pre-commit
```

**If missing, rebuild home-manager:**
```bash
home-manager switch
```

### Want to bypass hooks temporarily

**Skip for one commit (use sparingly):**
```bash
git commit --no-verify -m "WIP: bypass hooks"
```

### Clear hook cache

```bash
pre-commit clean
pre-commit install --install-hooks
```

---

## Comparison with Alternatives

### Option 1: git-hooks.nix (Chosen) ✅

**Pros:**
- Declarative in Nix
- Automatic installation
- No overhead
- Version controlled

**Cons:**
- Requires home-manager knowledge
- Nix-specific

### Option 2: Manual pre-commit + Python

**Pros:**
- Platform-independent
- Official pre-commit.com approach

**Cons:**
- Manual `pip install pre-commit`
- Python virtualenv management
- Not declarative
- Version drift between machines

### Option 3: Git hooks manually

**Pros:**
- No dependencies
- Full control

**Cons:**
- No standardization
- Hard to share across team
- Manual maintenance
- Easy to forget to install

---

## Integration with CI/CD

The same `.pre-commit-config.yaml` works in GitHub Actions:

```yaml
name: Pre-commit

on: [push, pull_request]

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
      - uses: pre-commit/action@v3.0.0
```

Or with Nix (for exact same environment as local):

```yaml
name: Pre-commit (Nix)

on: [push, pull_request]

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v24
      - name: Run pre-commit
        run: |
          nix-shell -p pre-commit ansible-lint yamllint \
            --run "pre-commit run --all-files"
```

---

## Related Files

- `home-manager/git-hooks.nix` - This module
- `ansible/.pre-commit-config.yaml` - Hook configuration
- `ansible/.ansible-lint` - ansible-lint settings
- `ansible/.yamllint` - yamllint settings
- `ansible/Makefile` - Manual quality check commands
- `ansible/docs/development/pre-commit-setup.md` - Detailed pre-commit docs

---

## Future Enhancements

### Potential Improvements:

1. **Flake-based Configuration:**
   - Migrate to flake.nix with git-hooks flakeModule
   - Run checks in `nix flake check`

2. **Custom Hooks:**
   - Add project-specific validation hooks
   - Ansible inventory validation
   - Role dependency checks

3. **Hook Performance:**
   - Cache ansible-lint results
   - Only check changed files in large repos

4. **Additional Hooks:**
   - `prettier` for JSON/Markdown
   - `shellcheck` for scripts in playbooks
   - `markdownlint` for documentation

---

## References

- **cachix/git-hooks.nix:** https://github.com/cachix/git-hooks.nix
- **pre-commit.com:** https://pre-commit.com
- **ansible-lint:** https://ansible.readthedocs.io/projects/lint/
- **yamllint:** https://yamllint.readthedocs.io/
- **Home-Manager Manual:** https://nix-community.github.io/home-manager/

---

**Status:** ✅ Production Ready
**Last Updated:** 2025-11-23
**Maintainer:** mitsio
