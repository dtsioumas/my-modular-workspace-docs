# ADR-001: NixOS System (Stable) vs Home-Manager (Unstable)

**Status:** Accepted
**Date:** 2025-11-17
**Author:** Mitsio
**Context:** Decoupling home-manager from NixOS system configuration

---

## Context and Problem Statement

When decoupling home-manager from NixOS, we need to decide which nixpkgs channel to use for:
1. System-level packages (NixOS)
2. User-level packages (home-manager)

**Considerations:**
- System stability vs latest features
- Security updates vs bleeding edge
- Testing burden vs convenience

---

## Decision

**NixOS System will use `nixpkgs-stable` (25.05):**
- Base system components
- NVIDIA drivers
- KDE Plasma 6 desktop environment
- Basic core tools (curl, wget, vim, git)
- Virtualization/containerization daemons (libvirtd, podman, docker)
- System services (rclone, Dropbox)

**Home-Manager will use `nixpkgs-unstable`:**
- **ALL user packages** (GUI apps, dev runtimes, CLI tools)
- Always latest versions of applications
- Faster access to new features and bug fixes
- User-level packages don't affect system stability

---

## Rationale

### Why Stable for System?
1. **Stability:** System-level components (kernel, drivers, DE) should be stable and well-tested
2. **Security:** Stable channel receives security backports
3. **Predictability:** Less frequent breakage on system rebuilds
4. **NVIDIA:** Proprietary drivers work better with stable kernel versions

### Why Unstable for Home-Manager?
1. **Latest features:** User wants bleeding edge applications (VSCode, Claude Desktop, dev tools)
2. **Faster updates:** Bug fixes and new features arrive faster
3. **No system risk:** User packages don't affect system boot or core functionality
4. **Development tools:** Latest language runtimes and toolchains
5. **Isolation:** home-manager can be rebuilt independently without touching system

---

## Consequences

### Positive:
- ✅ Stable, reliable system that always boots
- ✅ Latest user applications and development tools
- ✅ Can update home-manager frequently without risk
- ✅ Best of both worlds: stability + bleeding edge

### Negative:
- ⚠️ Need to manage two nixpkgs channels
- ⚠️ Slightly more complex flake inputs
- ⚠️ Potential version mismatches (rarely an issue for user apps)

### Neutral:
- System rebuilds are less frequent (only for system updates)
- Home-manager rebuilds are more frequent (for latest packages)
- Clear separation of concerns

---

## Implementation

### NixOS System Flake (`~/.config/nixos/flake.nix`):
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";  # Stable ONLY
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.shoshin = nixpkgs.lib.nixosSystem {
      # System uses stable channel
    };
  };
}
```

### Home-Manager Flake (`~/.config/my-home-manager-flake/flake.nix`):
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # Unstable for latest!
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations."mitsio@shoshin" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;  # Unstable packages!
      # All user packages from unstable
    };
  };
}
```

---

## Package Distribution

### System (Stable):
- `environment.systemPackages` = Minimal core tools only
- NVIDIA drivers, Plasma base, virtualization daemons

### Home-Manager (Unstable):
- `home.packages` = ~100+ packages
- Firefox, Brave, VSCode, Obsidian, Discord, KeePassXC
- Python, Go, Node.js runtimes
- virt-manager, podman CLI, Docker tools
- All development and productivity tools

---

## Alternatives Considered

### Alternative 1: Both Stable
- ❌ User stuck with outdated applications
- ❌ Missing latest features
- ❌ Slower bug fixes

### Alternative 2: Both Unstable
- ❌ System less stable
- ❌ Risk of kernel/driver breakage
- ❌ NVIDIA driver issues on unstable kernel

### Alternative 3: System Unstable, Home Stable
- ❌ Worst of both worlds
- ❌ No benefit, only downsides

---

## Review Date

Review this decision when:
- NixOS 25.11 releases (next stable)
- Major issues arise with unstable packages
- System requires unstable features

---

## References

- NixOS Channels: https://nixos.org/manual/nixos/stable/#sec-upgrading
- Home-Manager Docs: https://nix-community.github.io/home-manager/
- Discussion: my-modular-workspace-decoupling-home session (2025-11-17)

---

**Decision:** ✅ Accepted
**Status:** Implemented in Phase 1
