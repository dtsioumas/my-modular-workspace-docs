# Ephemeral Home Practices Guide

**Last Updated:** 2025-11-29
**Sources Merged:** EPHEMERAL_HOME_PRACTICES.md, EPHEMERALITY_STRATEGY.md, EPHEMERAL_RESOURCES.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Ephemerality Strategy](#ephemerality-strategy)
- [Impermanence Module](#impermanence-module)
- [What to Persist](#what-to-persist)
- [Implementation](#implementation)
- [References](#references)

---

## Overview

**Impermanence** is the practice of wiping your root filesystem (and optionally home directory) on every reboot, forcing you to explicitly declare what should persist.

### Key Concept
- Root directory (`/`) gets wiped every reboot
- Only `/boot` and `/nix` persist (required for NixOS to boot)
- Everything else must be explicitly persisted via configuration

### Benefits
- **Clean system by default** - No accumulated cruft
- **Declarative everything** - Forces you to declare all state
- **Easy experimentation** - Try software without permanent clutter
- **Reproducibility** - Only declared state persists
- **Security** - Secrets/sensitive data more controlled

### Drawbacks
- Initial setup complexity
- Learning curve
- Potential data loss if you forget to persist something

---

## Ephemerality Strategy

### Core Principles

1. **Treat Machines as Cattle, Not Pets** - All state is encoded in Git
2. **Never Rely on Manual Changes** - If a change cannot be reproduced via script/config, migrate it
3. **Prefer Declarative Over Imperative** - Describe *what* the system should look like
4. **Rebuild Regularly** - Monthly rebuilds uncover hidden drift
5. **Atomic Base, Mutable Home** - Base OS immutable, home layer reproducible but flexible

### Stack Components

| Layer | Technology | Responsibility |
|-------|------------|----------------|
| 0 | Fedora Atomic (BlueBuild) | Kernel, drivers, base tools |
| 1 | Ansible | Post-install bootstrap |
| 2 | Home Manager (Nix) | User CLI tools, dev environments |
| 3 | chezmoi + Stow | Dotfiles, Plasma layout |
| 4 | Syncthing + GDrive | User documents, persistent data |

### Ephemerality Levels

**Level 1 - Basic:** System can be rebuilt from scratch (~30-45 min)
**Level 2 - Monthly Rebuilds:** Reinstall/validate monthly
**Level 3 - VM Tests:** Test bootstrap in VM before real machine
**Level 4 - Complete Disposable:** Full recreation in under an hour

---

## Impermanence Module

### Installation (Flakes)

```nix
{
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { impermanence, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        impermanence.nixosModules.impermanence
        ./configuration.nix
      ];
    };
  };
}
```

### NixOS-Level Persistence

```nix
environment.persistence."/persistent" = {
  enable = true;
  hideMounts = true;

  directories = [
    "/var/log"
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/etc/NetworkManager/system-connections"
  ];

  files = [
    "/etc/machine-id"
  ];

  users.mitsio = {
    directories = [
      "Downloads"
      "Documents"
      { directory = ".ssh"; mode = "0700"; }
      { directory = ".gnupg"; mode = "0700"; }
    ];
    files = [ ".bash_history" ];
  };
};
```

### Home-Manager Persistence

```nix
home.persistence."/persistent/home/mitsio" = {
  directories = [
    "Downloads"
    "Documents"
    ".ssh"
    ".gnupg"
    ".mozilla"
    { directory = ".local/share/Steam"; method = "symlink"; }
  ];
  files = [ ".bash_history" ];
  allowOther = true;
};
```

---

## What to Persist

### System-Level (Always)

```nix
directories = [
  "/var/log"                # System logs
  "/var/lib/nixos"          # NixOS state
  "/var/lib/systemd"        # Systemd state
  "/var/lib/bluetooth"      # Bluetooth pairings
  "/etc/NetworkManager/system-connections"  # WiFi passwords
];

files = [ "/etc/machine-id" ];
```

### User-Level (Always)

```nix
directories = [
  ".ssh"                    # SSH keys
  ".gnupg"                  # GPG keys
  ".local/share/keyrings"   # Secrets
];
```

### Application Data

```nix
directories = [
  # Browsers
  ".mozilla"
  ".config/BraveSoftware"

  # Password managers
  "MyVault"                 # KeePassXC

  # Development
  ".local/share/direnv"
  ".cargo"
  ".npm"

  # Communication
  ".config/discord"
];
```

---

## Implementation

### Gradual Migration Strategy

**Phase 1: Research & Backup**
- Backup everything first
- List current important data
- Identify what you really need

**Phase 2: Test with Home Manager Only**
- Keep NixOS root as-is
- Implement impermanence for home only
- Test for a week, add missing items

**Phase 3: Full Implementation**
- Add root impermanence
- Monitor what breaks
- Iterate until stable

### Discovery Tools

```bash
# Monitor file changes
sudo inotifywait -r -m /home/mitsio

# Find recently modified files
find /home/mitsio -type f -mtime -7

# Check disk usage
ncdu /home/mitsio
```

### Finding Missing Persistence

```bash
# Check what app is looking for
strace -e open,openat app-name 2>&1 | grep ENOENT

# Find app config location
lsof -p $(pgrep app-name) | grep $HOME

# Monitor filesystem access
sudo fatrace | grep $HOME
```

---

## Recommendation for Our Project

Given our goals (Fedora migration, portable configs, chezmoi):

**Recommended Approach:**
1. Use impermanence **concepts** to identify ephemeral vs persistent
2. Focus on **chezmoi** for portable dotfile management
3. Keep current NixOS stable as-is
4. Plan for Fedora where impermanence doesn't apply
5. Make configs location-agnostic using chezmoi templates

---

## References

### Official
- **Impermanence GitHub:** https://github.com/nix-community/impermanence
- **NixOS Wiki:** https://nixos.wiki/wiki/Impermanence
- **Matrix Chat:** https://matrix.to/#/#impermanence:nixos.org

### Blog Posts
- **Elis Hirwing - tmpfs as home:** https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/
- **Graham Christensen - Erase Your Darlings:** https://grahamc.com/blog/erase-your-darlings
- **Will Bush - Impermanent NixOS:** https://willbush.dev/blog/impermanent-nixos/

### Related Tools
- **Chezmoi:** https://www.chezmoi.io/
- **GNU Stow:** https://www.gnu.org/software/stow/

---

*Migrated from docs/home-manager/ideas/ephemeral-home-practices/ on 2025-11-29*
