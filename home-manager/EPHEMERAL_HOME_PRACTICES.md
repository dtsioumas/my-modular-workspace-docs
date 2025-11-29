# Ephemeral Home Practices for NixOS/Home-Manager

**Date:** 2025-11-17
**Project:** my-modular-workspace-decoupling-home
**Purpose:** Research and document ephemeral/impermanence practices for NixOS and home-manager

---

## 📚 What is Impermanence?

**Impermanence** is the practice of wiping your root filesystem (and optionally home directory) on every reboot, forcing you to explicitly declare what should persist between reboots.

### Key Concept
- Root directory (`/`) gets wiped every reboot
- Only `/boot` and `/nix` persist (required for NixOS to boot)
- Everything else must be explicitly persisted via configuration
- Your system stays clean by default

### Why Use Impermanence?

**Benefits:**
- ✅ **Clean system by default** - No accumulated cruft
- ✅ **Declarative everything** - Forces you to declare all state
- ✅ **Easy experimentation** - Try software without permanent clutter
- ✅ **Reproducibility** - Only declared state persists
- ✅ **Security** - Secrets/sensitive data more controlled
- ✅ **Fresh start** - Every reboot is a clean slate

**Drawbacks:**
- ⚠️ **Initial setup complexity** - Must identify all needed persistent files
- ⚠️ **Learning curve** - Need to understand what to persist
- ⚠️ **Potential data loss** - If you forget to persist something important
- ⚠️ **Debugging harder** - Logs disappear unless persisted

---

## 🔗 Official Resources

### Primary Documentation
- **Impermanence GitHub:** https://github.com/nix-community/impermanence
- **NixOS Wiki - Impermanence:** https://nixos.wiki/wiki/Impermanence
- **Home-Manager Impermanence Module:** https://github.com/nix-community/impermanence/blob/master/home-manager.nix
- **Matrix Chat:** https://matrix.to/#/#impermanence:nixos.org

### Blog Posts & Guides
- **Elis Hirwing - tmpfs as home:** https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/
- **Graham Christensen - Erase Your Darlings:** https://grahamc.com/blog/erase-your-darlings
- **Will Bush - Impermanent NixOS:** https://willbush.dev/blog/impermanent-nixos/

### Community Discussions
- **NixOS Discourse - Impermanence discussions:** https://discourse.nixos.org/t/what-does-impermanence-add-over-built-in-functionality/27939
- **Reddit - Home Manager + Impermanence:** https://www.reddit.com/r/NixOS/comments/119foas/home_manager_impermanence_xdguserdirs/
- **Hacker News Discussion:** https://news.ycombinator.com/item?id=37218289

---

## 🏗️ Architecture Options

### Option 1: tmpfs Root (Easiest)

Mount root as tmpfs (RAM filesystem):

**Pros:**
- Easy to set up on existing systems
- No repartitioning needed
- Automatic cleanup on reboot

**Cons:**
- Everything stored in RAM (limited by memory)
- Data lost on crash/power loss
- Large downloads can fill memory

**Example Configuration:**
```nix
{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=25%" "mode=755" ];
  };

  fileSystems."/persistent" = {
    device = "/dev/root_vg/root";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persistent" ];
  };

  fileSystems."/nix" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";
    fsType = "vfat";
  };
}
```

### Option 2: BTRFS Subvolumes (Advanced)

Create fresh BTRFS subvolume on boot, keep old ones for 30 days:

**Pros:**
- Everything on disk (no RAM limit)
- Keep old roots for rollback
- Survives crashes/power loss

**Cons:**
- More complex setup
- Requires BTRFS
- Need to manage old roots

**Example Configuration:**
```nix
{
  fileSystems."/" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp

    # Move current root to old_roots with timestamp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    # Delete roots older than 30 days
    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    # Create fresh root subvolume
    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/persistent" = {
    device = "/dev/root_vg/root";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persistent" ];
  };

  fileSystems."/nix" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };
}
```

### Option 3: ZFS Snapshots (Alternative)

Use ZFS snapshots to restore to blank state on boot.

**See:** Graham Christensen's "Erase Your Darlings" blog post for ZFS approach.

---

## 📦 Using the Impermanence Module

### Installation

**Via Flakes:**
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        impermanence.nixosModules.impermanence
        ./configuration.nix
      ];
    };
  };
}
```

**Direct Import:**
```nix
{
  imports = [
    (builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz" + "/nixos.nix")
  ];
}
```

### NixOS-Level Persistence

**Example Configuration:**
```nix
{ config, lib, pkgs, ... }:

{
  environment.persistence."/persistent" = {
    enable = true;  # Default: true
    hideMounts = true;  # Hide bind mounts in file manager

    # System directories to persist
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/etc/NetworkManager/system-connections"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];

    # System files to persist
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];

    # User-specific persistence
    users.mitsio = {
      directories = [
        "Downloads"
        "Documents"
        "Pictures"
        "Videos"
        "Music"
        "Projects"
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".local/share/keyrings"; mode = "0700"; }
        ".local/share/direnv"
        ".mozilla"  # Firefox profile
        ".config/BraveSoftware"  # Brave browser
      ];

      files = [
        ".bash_history"
        ".zsh_history"
      ];
    };
  };
}
```

### Home-Manager-Level Persistence

**Installation:**
```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    (builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz" + "/home-manager.nix")
  ];

  # Required for bindfs
  programs.fuse.userAllowOther = true;  # In NixOS config

  home.persistence."/persistent/home/mitsio" = {
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "Music"
      "Projects"
      ".ssh"
      ".gnupg"
      ".mozilla"
      ".config/BraveSoftware"
      ".local/share/keyrings"
      {
        directory = ".local/share/Steam";
        method = "symlink";  # Use symlink instead of bindfs
      }
    ];

    files = [
      ".bash_history"
      ".zsh_history"
    ];

    allowOther = true;  # Allow root to access (needed for sudo, Docker)
  };
}
```

### Methods: Bindfs vs Symlink

**bindfs (default for directories):**
- FUSE filesystem that bind mounts
- Preserves permissions
- Works with most applications
- Shows in `/etc/mtab` and `mount` output (privacy consideration)

**symlink:**
- Creates symbolic links
- Faster, simpler
- Some apps don't follow symlinks
- Better for large directories (e.g., Steam, game libraries)

---

## 🎯 What to Persist?

### System-Level (NixOS)

**Always Persist:**
```nix
directories = [
  "/var/log"                    # System logs
  "/var/lib/nixos"              # NixOS state (users, groups)
  "/var/lib/systemd"            # Systemd state
  "/var/lib/bluetooth"          # Bluetooth pairings
  "/etc/NetworkManager/system-connections"  # WiFi passwords
];

files = [
  "/etc/machine-id"             # Machine identifier
];
```

**Optional (Depending on Usage):**
```nix
directories = [
  "/var/lib/docker"             # Docker images/containers
  "/var/lib/libvirt"            # Virtual machines
  "/var/lib/postgresql"         # Database data
  "/var/cache"                  # System caches
];
```

### User-Level (Home-Manager)

**Always Persist:**
```nix
directories = [
  ".ssh"                        # SSH keys
  ".gnupg"                      # GPG keys
  ".local/share/keyrings"       # Keyring/secrets
];

files = [
  ".bash_history"
  ".zsh_history"
];
```

**Application Data:**
```nix
directories = [
  # Browsers
  ".mozilla"                    # Firefox
  ".config/BraveSoftware"       # Brave
  ".config/google-chrome"       # Chrome

  # Password managers
  "MyVault"                     # KeePassXC database

  # Development
  ".local/share/direnv"         # Direnv cache
  ".cargo"                      # Rust cargo
  ".npm"                        # NPM cache
  ".cache/go-build"             # Go build cache

  # Desktop
  ".local/share/applications"   # Desktop entries
  ".local/share/fonts"          # Custom fonts

  # Communication
  ".config/discord"
  ".config/Slack"

  # Gaming
  ".local/share/Steam"
  ".minecraft"
];
```

---

## 🔧 Practical Implementation

### Gradual Migration Strategy

**Don't do everything at once!** Start small and gradually add more.

#### Phase 1: Research & Backup
1. **Backup everything first**
2. **List current important data:**
   ```bash
   du -sh ~/* | sort -h
   find ~/.config -type d -maxdepth 1
   ```
3. **Identify what you really need**

#### Phase 2: Test with Home Manager Only
1. **Keep NixOS root as-is** (don't wipe yet)
2. **Implement impermanence for home only:**
   ```nix
   fileSystems."/home/mitsio" = {
     device = "none";
     fsType = "tmpfs";
     options = [ "size=4G" "mode=777" ];
   };
   ```
3. **Start with minimal persistence**
4. **Test for a week**, add missing items as you discover them

#### Phase 3: Full Implementation
1. **Once home is stable**, add root impermanence
2. **Start with tmpfs** (easier to test)
3. **Monitor what breaks**, add to persistence
4. **Iterate until stable**

### Discovery Tools

**Find what needs persistence:**
```bash
# Monitor file changes during usage
sudo inotifywait -r -m /home/mitsio

# Find recently modified files
find /home/mitsio -type f -mtime -7

# Check what's using disk space
ncdu /home/mitsio
```

---

## ⚠️ Important Considerations

### Warnings

**CRITICAL - Always Persist:**
- SSH keys (`.ssh/`)
- GPG keys (`.gnupg/`)
- KeePassXC database (`MyVault/`)
- User passwords (handled by NixOS via `/var/lib/nixos`)
- Machine ID (`/etc/machine-id`)

**Set User Passwords Declaratively:**
```nix
users.users.mitsio = {
  isNormalUser = true;
  hashedPassword = "$6$...";  # Use mkpasswd to generate
};
```

### Common Pitfalls

1. **Forgetting to persist logs** → Can't debug issues after reboot
2. **Not persisting browser profiles** → Lose all bookmarks/sessions
3. **Forgetting application state** → Apps reset to defaults
4. **Not testing before deploying** → System becomes unusable

### Performance Considerations

- **tmpfs size:** Set to reasonable % of RAM (25-50%)
- **Bindfs overhead:** Minimal for most use cases
- **Symlinks faster:** For large directories (Steam, games)

---

## 🚀 Integration with Our Setup

### Current State (my-modular-workspace-decoupling-home)

We have:
- ✅ Standalone home-manager (`~/.config/my-home-manager-flake/`)
- ✅ NixOS system config (`~/.config/nixos/`)
- ✅ Username: `mitsio`
- ⏳ Planning: Chezmoi for dotfiles
- ⏳ Planning: Fedora migration

### Recommended Approach for Us

**Option A: Gradual Impermanence (Recommended)**
1. **Keep current setup as-is**
2. **Add impermanence module** to home-manager only
3. **Test with home on tmpfs** first
4. **Document what needs persistence**
5. **Later:** Add system-level impermanence if desired

**Option B: Wait for Fedora Migration**
- Impermanence is NixOS-specific
- On Fedora, use **chezmoi** for dotfile management instead
- Focus on making configs portable via chezmoi now
- Skip impermanence entirely

**Option C: Hybrid**
- Use impermanence concepts to **identify ephemeral vs persistent**
- Apply this thinking to our chezmoi setup
- Make conscious decisions about what to persist
- Don't actually wipe root, but organize as if we did

---

## 📝 Example: Our Home-Manager with Impermanence

```nix
# ~/.config/my-home-manager-flake/impermanence.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    (builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz" + "/home-manager.nix")
  ];

  home.persistence."/persistent/home/mitsio" = {
    # Essential data
    directories = [
      # Password/Secrets
      "MyVault"                           # KeePassXC database
      { directory = ".ssh"; mode = "0700"; }
      { directory = ".gnupg"; mode = "0700"; }

      # Browsers
      ".mozilla"                          # Firefox
      ".config/BraveSoftware"             # Brave

      # Development
      "Projects"                          # All code projects
      "Workspaces"                        # Workspace directories
      ".local/share/direnv"

      # User data
      "Documents"
      "Downloads"
      "Pictures"
      "Videos"
      "Music"

      # Dropbox/Google Drive
      "Dropbox"
      "GoogleDrive"

      # Application state
      ".local/share/keyrings"
      ".config/obsidian"                  # Obsidian notes
    ];

    files = [
      ".bash_history"
      ".npmrc"                            # NPM config
    ];

    allowOther = true;
  };
}
```

Then import in `home.nix`:
```nix
{
  imports = [
    ./impermanence.nix
  ];
}
```

---

## 🧪 Testing Checklist

Before implementing:
- [ ] Backup all important data
- [ ] List all applications you use daily
- [ ] Identify their config locations
- [ ] Create persistence configuration
- [ ] Test in VM first (recommended)
- [ ] Test on real system with home only
- [ ] Monitor for a week
- [ ] Add missing items
- [ ] Only then: add system-level impermanence

After implementing:
- [ ] Reboot and verify all apps work
- [ ] Check all services start
- [ ] Verify browser profiles intact
- [ ] Test SSH keys work
- [ ] Check KeePassXC database accessible
- [ ] Confirm development tools work

---

## 🔍 Finding What's Missing

If something breaks after reboot:

```bash
# 1. Check what the app is looking for
strace -e open,openat app-name 2>&1 | grep ENOENT

# 2. Find app config location
lsof -p $(pgrep app-name) | grep $HOME

# 3. Monitor filesystem access
sudo fatrace | grep $HOME

# 4. Check XDG directories
echo $XDG_CONFIG_HOME
echo $XDG_DATA_HOME
echo $XDG_CACHE_HOME
```

Add missing paths to persistence config and rebuild.

---

## 📊 Decision Matrix: Should We Use Impermanence?

### Use Impermanence If:
- ✅ You want maximum system cleanliness
- ✅ You're staying on NixOS long-term
- ✅ You enjoy tinkering and optimizing
- ✅ You want forced declarative everything
- ✅ You have good backups

### Skip Impermanence If:
- ❌ Migrating to Fedora soon (we are!)
- ❌ Want stable, "just works" system
- ❌ Don't want debugging overhead
- ❌ Nervous about data loss
- ❌ Limited time for setup/testing

---

## 🎯 Recommendation for Our Project

Given our goals (Fedora migration, portable configs, chezmoi):

**My Recommendation: Don't implement full impermanence**

Instead:
1. ✅ **Use impermanence concepts** to identify what's ephemeral vs persistent
2. ✅ **Focus on chezmoi** for portable dotfile management
3. ✅ **Keep current NixOS** stable as-is
4. ✅ **Plan for Fedora** where impermanence doesn't apply anyway
5. ✅ **Make configs location-agnostic** using chezmoi templates

**Compromise Option:**
- Document what WOULD be persisted (this analysis is valuable)
- Organize configs accordingly in chezmoi
- Don't actually wipe root filesystem
- Get benefits of thinking without complexity of implementing

---

## 📚 Further Reading

- **Impermanence README:** https://github.com/nix-community/impermanence/blob/master/README.org
- **NixOS Wiki:** https://nixos.wiki/wiki/Impermanence
- **Matrix Room:** https://matrix.to/#/#impermanence:nixos.org
- **Blog Posts:**
  - https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/
  - https://grahamc.com/blog/erase-your-darlings
  - https://willbush.dev/blog/impermanent-nixos/

---

**Created:** 2025-11-17
**Author:** Claude Code + Mitsio
**Status:** Research Complete - Implementation Optional
**Recommendation:** Focus on chezmoi instead for Fedora portability
