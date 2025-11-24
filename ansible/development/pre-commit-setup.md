# Pre-Commit Hooks Setup for Ansible

**Author:** mitsio
**Date:** 2025-11-23
**Purpose:** Automate linting and testing before commits

---

## Overview

This document describes how to set up automated quality checks for Ansible playbooks using **git-hooks.nix** (cachix) integrated with home-manager.

## Research Summary

### Tools Evaluated

1. **cachix/git-hooks.nix** ⭐ RECOMMENDED
   - **Repository:** https://github.com/cachix/git-hooks.nix
   - **Integration:** Native Nix/home-manager support
   - **Benefits:**
     - Declarative configuration in Nix
     - Pre-built hooks for ansible-lint, yamllint
     - Fast execution (no nix-shell overhead)
     - Automatic garbage collection prevention
     - Works with flakes and home-manager standalone
   - **Hooks Available:**
     - `ansible-lint`: Ansible best practices linter
     - `yamllint`: YAML syntax and style linter
     - `check-yaml`: Basic YAML validation
     - `shellcheck`: Shell script linting (for Ansible shell tasks)

2. **ansible-lint** (Official)
   - **Repository:** https://github.com/ansible/ansible-lint
   - **Context7 ID:** `/ansible/ansible-lint`
   - **Features:**
     - Checks playbooks for practices and behaviors
     - Supports last 2 major Ansible versions
     - Profiles: min, basic, moderate, safety, shared, production
     - 445 code snippets available
     - Trust score: 9.3/10

3. **yamllint**
   - **Purpose:** YAML syntax and style checking
   - **Configuration:** `.yamllint` or `.yamllint.yaml`
   - **Integration:** Works with pre-commit

### Installation Approach

**CHOSEN:** cachix/git-hooks.nix via home-manager

**Reasons:**
- Native NixOS integration
- Declarative and reproducible
- No Python virtualenv overhead
- Automatic tool installation
- Works seamlessly with flakes

---

## Implementation Plan

### Phase 1: Home-Manager Configuration

**File:** `~/.MyHome/MySpaces/my-modular-workspace/home-manager/git-hooks.nix`

```nix
{ config, pkgs, lib, ... }:

{
  # Import git-hooks.nix from cachix
  imports = [
    (builtins.fetchTarball {
      url = "https://github.com/cachix/git-hooks.nix/tarball/master";
    })
  ];

  # Configure pre-commit hooks for ansible directory
  programs.git-hooks = {
    enable = true;

    hooks = {
      # Ansible linting
      ansible-lint = {
        enable = true;
        name = "Ansible Lint";
        description = "Check Ansible playbooks for best practices";
        files = "\\.(ya?ml)$";
        entry = "${pkgs.ansible-lint}/bin/ansible-lint";
        language = "system";
        pass_filenames = true;
      };

      # YAML linting
      yamllint = {
        enable = true;
        name = "YAML Lint";
        description = "Lint YAML files for syntax and style";
        files = "\\.(ya?ml)$";
        entry = "${pkgs.yamllint}/bin/yamllint";
        language = "system";
        pass_filenames = true;
      };

      # YAML syntax check
      check-yaml = {
        enable = true;
        name = "Check YAML";
        description = "Validate YAML syntax";
      };

      # Ansible syntax check
      ansible-syntax-check = {
        enable = true;
        name = "Ansible Syntax Check";
        description = "Run ansible-playbook --syntax-check";
        files = "playbooks/.*\\.ya?ml$";
        entry = "${pkgs.writeShellScript "ansible-syntax-check" ''
          for file in "$@"; do
            ${pkgs.ansible}/bin/ansible-playbook --syntax-check "$file"
          done
        ''}";
        language = "system";
        pass_filenames = true;
      };

      # Shellcheck for shell tasks
      shellcheck = {
        enable = true;
        name = "ShellCheck";
        description = "Lint shell scripts in playbooks";
        files = "\\.(sh|bash)$";
      };
    };

    # Exclude patterns
    excludes = [
      "^.cache/"
      "^.logs/"
      "^backup/"
    ];

    # Run on these stages
    default_stages = ["pre-commit"];
  };

  # Install required packages
  home.packages = with pkgs; [
    ansible
    ansible-lint
    yamllint
    pre-commit
  ];
}
```

**Integration with main home.nix:**
```nix
imports = [
  ./git-hooks.nix
  # ... other imports
];
```

---

### Phase 2: Configuration Files

#### `.ansible-lint`

**File:** `~/.MyHome/MySpaces/my-modular-workspace/ansible/.ansible-lint`

```yaml
---
# Ansible-lint configuration
# Profile: production (strictest)
profile: production

# Exclude paths
exclude_paths:
  - .cache/
  - .logs/
  - backup/
  - '*.md'

# Enable opt-in rules
enable_list:
  - args
  - empty-string-compare
  - no-log-password
  - no-same-owner
  - name[prefix]
  - galaxy-version-incorrect
  - yaml

# Warnings (don't fail)
warn_list:
  - experimental
  - yaml[line-length]  # We allow long lines for readability

# Skip specific rules (if needed)
skip_list: []

# Mock modules (if using custom modules)
mock_modules: []

# Mock roles (if using custom roles)
mock_roles: []

# Variable naming pattern
var_naming_pattern: "^[a-z_][a-z0-9_]*$"

# Loop variable prefix enforcement
loop_var_prefix: "^(__|{role}_)"

# Offline mode (for CI/CD without internet)
offline: false

# Extra variables for syntax check
extra_vars: {}

# Write mode (auto-fix when possible)
# write_list:
#   - all

# Complexity limits
max_block_depth: 20
```

#### `.yamllint`

**File:** `~/.MyHome/MySpaces/my-modular-workspace/ansible/.yamllint`

```yaml
---
# yamllint configuration
extends: default

rules:
  # Line length - relaxed for readability
  line-length:
    max: 200
    level: warning
    allow-non-breakable-words: true
    allow-non-breakable-inline-mappings: true

  # Comments
  comments:
    min-spaces-from-content: 2

  # Indentation
  indentation:
    spaces: 2
    indent-sequences: true

  # Trailing spaces
  trailing-spaces: enable

  # Document start
  document-start:
    present: true

  # Truthy values
  truthy:
    allowed-values: ['true', 'false']
    check-keys: true

  # Brackets
  brackets:
    min-spaces-inside: 0
    max-spaces-inside: 1

  # Braces
  braces:
    min-spaces-inside: 0
    max-spaces-inside: 1

# Ignore paths
ignore: |
  .cache/
  .logs/
  backup/
  *.md
```

---

### Phase 3: Navi Cheatsheet

**File:** `~/.MyHome/MySpaces/my-modular-workspace/ansible/.navi/ansible-quality.cheat`

```cheat
% ansible, quality, lint

# Run ansible-lint on all playbooks
ansible-lint playbooks/

# Run ansible-lint on specific playbook
ansible-lint playbooks/<playbook_name>.yml

# Run ansible-lint with auto-fix
ansible-lint --fix playbooks/

# Run ansible-lint in production profile
ansible-lint --profile production playbooks/

# Run yamllint on all YAML files
yamllint .

# Run yamllint on specific file
yamllint <file_path>

# Run pre-commit on all files
pre-commit run --all-files

# Run pre-commit on staged files only
pre-commit run

# Run specific pre-commit hook
pre-commit run <hook_id>

# Install pre-commit hooks
pre-commit install

# Update pre-commit hooks
pre-commit autoupdate

# Ansible syntax check on playbook
ansible-playbook --syntax-check playbooks/<playbook_name>.yml

# Ansible syntax check on all playbooks
find playbooks/ -name "*.yml" -exec ansible-playbook --syntax-check {} \;

# Check Ansible version
ansible --version

# List all pre-commit hooks
pre-commit run --all-files --hook-stage manual --verbose

$ playbook_name: ls playbooks/*.yml | xargs -n1 basename | sed 's/\.yml$//'
$ file_path: find . -name "*.yml" -o -name "*.yaml"
$ hook_id: pre-commit run --all-files --hook-stage manual --verbose 2>&1 | grep -E "^\[.*\]" | sed 's/\[//;s/\].*//'
```

---

### Phase 4: Makefile for CI/CD

**File:** `~/.MyHome/MySpaces/my-modular-workspace/ansible/Makefile`

```makefile
.PHONY: help lint syntax-check test format check all

help: ## Show this help message
	@echo "Ansible Quality Checks"
	@echo "======================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: ## Run ansible-lint on all playbooks
	@echo "Running ansible-lint..."
	@ansible-lint playbooks/

yaml-lint: ## Run yamllint on all YAML files
	@echo "Running yamllint..."
	@yamllint .

syntax-check: ## Run ansible-playbook --syntax-check on all playbooks
	@echo "Running syntax check..."
	@find playbooks/ -name "*.yml" -exec ansible-playbook --syntax-check {} \;

pre-commit: ## Run all pre-commit hooks
	@echo "Running pre-commit..."
	@pre-commit run --all-files

format: ## Auto-fix issues where possible
	@echo "Running ansible-lint --fix..."
	@ansible-lint --fix playbooks/

check: lint yaml-lint syntax-check ## Run all checks (lint, yaml-lint, syntax-check)

all: check ## Run all checks (alias for check)

install-hooks: ## Install pre-commit hooks
	@echo "Installing pre-commit hooks..."
	@pre-commit install
```

---

## Usage Instructions

### Initial Setup

1. **Add git-hooks.nix to home-manager:**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
   # Create git-hooks.nix (see Phase 1)
   # Update home.nix imports
   ```

2. **Apply home-manager configuration:**
   ```bash
   home-manager switch
   ```

3. **Navigate to ansible directory:**
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/ansible
   ```

4. **Install pre-commit hooks:**
   ```bash
   pre-commit install
   ```

5. **Test hooks:**
   ```bash
   pre-commit run --all-files
   ```

### Daily Workflow

**Automated (on git commit):**
- ansible-lint runs automatically
- yamllint runs automatically
- Syntax check runs automatically
- Commit blocked if errors found

**Manual runs:**
```bash
# Before committing
make check

# Auto-fix issues
make format

# Run specific check
make lint
make yaml-lint
make syntax-check
```

**With Navi:**
```bash
# Open navi with ansible context
navi --path ~/.MyHome/MySpaces/my-modular-workspace/ansible/.navi

# Search for "lint" commands
navi --query "ansible lint"
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Ansible Quality Checks

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Nix
        uses: cachix/install-nix-action@v24

      - name: Install ansible-lint and yamllint
        run: |
          nix-env -iA nixpkgs.ansible-lint
          nix-env -iA nixpkgs.yamllint
          nix-env -iA nixpkgs.ansible

      - name: Run ansible-lint
        run: ansible-lint playbooks/

      - name: Run yamllint
        run: yamllint .

      - name: Run syntax check
        run: make syntax-check
```

---

## Forcing Automation Without Instructions

To make these checks **mandatory** and run automatically without you having to remind me:

### 1. Git Hooks (Local Enforcement)

The pre-commit hooks will automatically run on every commit. If checks fail, the commit is blocked.

**Force level:** 🔒 STRONG - Cannot commit without passing checks

### 2. Repository Pre-Receive Hooks (Server-Side)

For the new `modular-workspace-ansible` repository, set up GitHub Actions as a required check:

**GitHub Settings → Branches → Branch Protection Rules:**
- Require status checks to pass before merging
- Require "Ansible Quality Checks" workflow to pass

**Force level:** 🔒🔒 STRONGER - Cannot merge without CI passing

### 3. Home-Manager Activation Script

Add to home-manager to verify hooks are installed:

```nix
home.activation.verifyAnsibleHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
  if [ -d "$HOME/.MyHome/MySpaces/my-modular-workspace/ansible/.git" ]; then
    cd "$HOME/.MyHome/MySpaces/my-modular-workspace/ansible"
    ${pkgs.pre-commit}/bin/pre-commit install --install-hooks || echo "Warning: Failed to install ansible pre-commit hooks"
  fi
'';
```

---

## Benefits

✅ **Automated Quality:** Checks run on every commit
✅ **Fast Execution:** No nix-shell overhead (pre-built tools)
✅ **Declarative:** Configuration in Nix (reproducible)
✅ **Comprehensive:** Covers syntax, style, best practices
✅ **CI/CD Ready:** Same tools work in GitHub Actions
✅ **Developer Friendly:** Clear error messages, auto-fix options
✅ **Mandatory:** Cannot commit/merge without passing

---

## Next Steps

1. ✅ Research complete
2. ⏳ Create home-manager configuration
3. ⏳ Create .ansible-lint and .yamllint configs
4. ⏳ Create Makefile
5. ⏳ Create navi cheatsheet
6. ⏳ Test on existing playbooks
7. ⏳ Document in ansible/TODO.md

---

**References:**
- cachix/git-hooks.nix: https://github.com/cachix/git-hooks.nix
- ansible-lint docs: https://ansible.readthedocs.io/projects/lint/
- yamllint docs: https://yamllint.readthedocs.io/
- pre-commit.com: https://pre-commit.com/
