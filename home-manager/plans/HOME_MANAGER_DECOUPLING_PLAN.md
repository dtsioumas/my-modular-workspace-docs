# Implementation Steps - Home-Manager Decoupling

**Date:** 2025-11-17
**Repo:** `my-home-manager-flake`
**User:** `mitsio` (username change from mitso)
**Approach:** Standalone home-manager (NOT as NixOS module)

---

## 🎯 Key Decisions

1. **Username change:** `mitso` → `mitsio` in current NixOS system
2. **Home-manager method:** Standalone `home-manager switch --flake` (NOT NixOS module)
3. **Repo location:** `~/.config/my-home-manager-flake` (relocatable later)
4. **Architecture:** Follow HOME-MANAGER_REPO_SKELETON_DRAFT_1.md

---

## 📝 Step-by-Step Implementation

### **Step 1: Change Username in NixOS System** ⚠️

**Do FIRST before creating home-manager repo!**

```bash
# 1. Create new user mitsio in NixOS config
# Edit: ~/.config/nixos/hosts/shoshin/configuration.nix or relevant user config file

# Add new user definition:
users.users.mitsio = {
  isNormalUser = true;
  description = "Dimitris Tsioumas";
  extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
  shell = pkgs.bash;
};

# 2. Rebuild NixOS to create new user
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin

# 3. Set password for new user
sudo passwd mitsio

# 4. Manually migrate critical data
# Log in as mitso, copy important files:
sudo rsync -av /home/mitso/MyVault/ /home/mitsio/MyVault/
sudo rsync -av /home/mitso/Dropbox/ /home/mitsio/Dropbox/
sudo rsync -av /home/mitso/.ssh/ /home/mitsio/.ssh/
sudo rsync -av /home/mitso/.gnupg/ /home/mitsio/.gnupg/
sudo chown -R mitsio:users /home/mitsio/

# 5. Test login as mitsio
# Log out and log back in as mitsio

# 6. Once verified, remove old user (later!)
# users.users.mitso = null;  # in NixOS config
```

---

### **Step 2: Remove Home-Manager from NixOS Config**

**Edit:** `~/.config/nixos/flake.nix`

**Remove:**
```nix
# Remove these lines:
inputs.home-manager = { ... };
inputs.plasma-manager = { ... };

# Remove from modules:
home-manager.nixosModules.home-manager
{
  home-manager.useGlobalPkgs = true;
  home-manager.users.mitso = ...;  # DELETE ALL THIS
}
```

**Keep only system-level inputs:**
- `nixpkgs`
- `nixpkgs-unstable` (if used for system packages)
- `claude-desktop` (system-level flake)

**Remove directory:**
```bash
cd ~/.config/nixos
git rm -r home/  # Remove entire home/ directory
```

**Rebuild:**
```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
```

**Result:** NixOS provides only system-level config. NO user configs.

---

### **Step 3: Create my-home-manager-flake Repo**

```bash
# Create repo
mkdir -p ~/.config/my-home-manager-flake
cd ~/.config/my-home-manager-flake

# Create directory structure
mkdir -p home/{common,mitsio/machines}
mkdir -p hosts

# Initialize git
git init
```

---

### **Step 4: Create flake.nix**

**File:** `~/.config/my-home-manager-flake/flake.nix`

```nix
{
  description = "Mitsio's Portable Home-Manager Configuration";

  inputs = {
    # Align with NixOS system version
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }: {
    homeConfigurations = {
      # NixOS desktop (current)
      "mitsio@shoshin" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          ./home/mitsio/default.nix
          plasma-manager.homeManagerModules.plasma-manager
        ];

        extraSpecialArgs = {
          hostname = "shoshin";
        };
      };

      # Future: Fedora Kinoite
      "mitsio@kinoite" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          ./home/mitsio/default.nix
          plasma-manager.homeManagerModules.plasma-manager
        ];

        extraSpecialArgs = {
          hostname = "kinoite";
        };
      };

      # Future: WSL
      "mitsio@wsl-workspace" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          ./home/mitsio/default.nix
          # NO plasma-manager on WSL
        ];

        extraSpecialArgs = {
          hostname = "wsl-workspace";
        };
      };
    };
  };
}
```

---

### **Step 5: Create home/common/ Modules**

#### `home/common/core.nix`

```nix
{ config, pkgs, ... }: {
  home.username = "mitsio";
  home.homeDirectory = "/home/mitsio";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Basic session variables
  home.sessionVariables = {
    EDITOR = "vim";
  };
}
```

#### `home/common/cli-tools.nix`

```nix
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Modern CLI tools
    ripgrep
    fd
    fzf
    bat
    eza

    # Data tools
    jq
    yq
    gron

    # Monitoring
    htop
    btop

    # Log viewer
    lnav

    # Unstable: ast-grep
    # (need unstable overlay or pass via extraSpecialArgs)
  ];
}
```

#### `home/common/dev-core.nix`

```nix
{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Dimitris Tsioumas";
    userEmail = "dtsioumas0@gmail.com";

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";
    };
  };
}
```

#### `home/common/secrets.nix`

```nix
{ config, pkgs, ... }: {
  # Placeholder for secrets management
  # Paths to secret files (no raw secrets!)

  home.sessionVariables = {
    # BW_CLIENTID loaded from shell.nix after Bitwarden unlock
    # BW_CLIENTSECRET loaded from shell.nix after Bitwarden unlock
  };
}
```

---

### **Step 6: Create home/mitsio/default.nix**

```nix
{ config, pkgs, hostname, ... }: {
  imports = [
    # Common modules
    ../common/core.nix
    ../common/cli-tools.nix
    ../common/dev-core.nix
    ../common/secrets.nix

    # User-specific modules
    ./shell.nix
    ./editors.nix
    ./desktop.nix
    ./llm-tools.nix
    ./vaults.nix

    # Machine-specific overrides
    ./machines/${hostname}.nix
  ];
}
```

---

### **Step 7: Migrate Existing Configs**

Copy and adapt from `~/.config/nixos/home/mitso/`:

1. **shell.nix** → `home/mitsio/shell.nix`
   - Update paths: `/home/mitso/` → `/home/mitsio/`
   - Extract NixOS aliases to `machines/shoshin.nix`

2. **kitty.nix + vscodium.nix** → `home/mitsio/editors.nix`
   - Merge both into one file
   - Update paths

3. **plasma.nix** → `home/mitsio/desktop.nix`
   - Keep as-is, update paths if needed

4. **claude-code.nix + npm scripts from home.nix** → `home/mitsio/llm-tools.nix`
   - Merge Claude Code wrapper + activation scripts
   - Update paths

5. **keepassxc.nix** → `home/mitsio/vaults.nix`
   - Update paths to `/home/mitsio/MyVault/`

---

### **Step 8: Create machines/shoshin.nix**

```nix
{ config, pkgs, ... }: {
  # NixOS-specific bash aliases
  programs.bash.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin";
    nrt = "sudo nixos-rebuild test --flake ~/.config/nixos#shoshin";
    nru = "nix flake update ~/.config/nixos && nrs";
    cd-nixos = "cd ~/.config/nixos";
  };

  # Enable user systemd timers (NixOS has systemd)
  systemd.user.timers = {
    keepassxc-vault-sync.enable = true;
    vscode-extensions-update.enable = true;
  };
}
```

---

### **Step 9: Build and Test**

```bash
cd ~/.config/my-home-manager-flake

# Check flake
nix flake check

# First build (as user mitsio!)
home-manager switch --flake .#mitsio@shoshin

# Check what was installed
home-manager packages

# Test shell
source ~/.bashrc
alias | grep -E "(nrs|bwu|gs)"

# Test apps
kitty
code  # VSCodium
```

---

### **Step 10: Verify Everything Works**

- [ ] Home-manager builds without errors
- [ ] Shell aliases work (generic + NixOS-specific)
- [ ] Kitty terminal launches with correct theme/settings
- [ ] VSCodium launches with extensions
- [ ] Plasma settings applied (panels, shortcuts)
- [ ] KeePassXC vault sync service running
- [ ] Claude Code CLI wrapper works
- [ ] Git config correct (name, email, aliases)
- [ ] User systemd services running

---

### **Step 11: Clean Up Old User (Later!)**

**Only after verifying mitsio works completely!**

```bash
# In NixOS config, remove old user
users.users.mitso = null;  # or just delete the whole block

# Rebuild
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin

# Optionally delete old home directory
sudo rm -rf /home/mitso/
```

---

## ✅ Final State

**NixOS System (`~/.config/nixos`):**
- Provides: Base system, Plasma DE, runtimes, GUI apps
- User: `users.users.mitsio`
- NO home-manager module

**Home-Manager (`~/.config/my-home-manager-flake`):**
- Manages: User configs, shell, editors, desktop settings
- Run: `home-manager switch --flake .#mitsio@shoshin`
- Completely standalone from NixOS

**User mitsio:**
- Home: `/home/mitsio/`
- All configs managed by standalone home-manager
- Can easily migrate to Kinoite by running same home-manager config

---

**Ready to start implementation!** 🚀
