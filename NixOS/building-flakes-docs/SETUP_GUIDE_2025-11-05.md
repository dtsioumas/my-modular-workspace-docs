# Complete Setup Guide: Messaging Apps + Kitty + Brave Default

**Date:** 2025-11-05  
**Session:** Desktop Workspace Package Installation  
**Status:** Ready to implement

---

## 📋 What We're Installing

| Package | Method | Why This Way |
|---------|--------|--------------|
| **Brave (default browser)** | Home Manager XDG | Declarative, per-user |
| **Kitty Terminal** | Home Manager module | Native support, full config |
| **Signal Desktop** | Custom Flake | Avoid "expired version" errors |
| **Session Desktop** | Custom Flake | Consistency with Signal |
| **Discord** | Already installed | ✅ In packages.nix |

---

## 🚀 Step-by-Step Implementation

### Step 1: Set Brave as Default Browser

Edit `/home/mitso/.config/nixos/home/mitso/home.nix`:

```nix
{ config, lib, pkgs, unstable, ... }:

{
  imports = [
    ./shell.nix
    ./claude-code.nix
    ./kitty.nix  # ⬅️ ADD THIS
  ];

  # ... existing config ...

  # ⬅️ ADD THIS SECTION
  # Set Brave as default browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };

  # ... rest of existing config ...
}
```

### Step 2: Configure Kitty Terminal

Create `/home/mitso/.config/nixos/home/mitso/kitty.nix`:

```nix
{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    # Theme
    theme = "Dracula";
    
    # Font
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    
    # Settings
    settings = {
      # Performance
      enable_gpu_rendering = true;
      sync_to_monitor = true;
      
      # Behavior
      scrollback_lines = 10000;
      enable_audio_bell = false;
      
      # Window
      background_opacity = "0.95";
      dynamic_background_opacity = true;
      window_padding_width = 8;
      
      # Tabs
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 0;
      
      # URLs
      url_style = "curly";
      open_url_with = "default";
      
      # Copy/Paste
      copy_on_select = true;
      strip_trailing_spaces = "smart";
    };
    
    # Keybindings
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+equal" = "increase_font_size";
      "ctrl+shift+minus" = "decrease_font_size";
      "ctrl+shift+backspace" = "restore_font_size";
    };
  };
}
```

### Step 3: Initialize Messaging Apps Flake

```bash
cd ~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps

# Make update script executable
chmod +x update-versions.sh

# Get latest versions and hashes
./update-versions.sh
```

**Output will show:**
```
Signal Desktop:
  signalVersion = "7.33.0";
  sha256 = "sha256-ABC...";

Session Desktop:
  sessionVersion = "1.14.4";
  sha256 = "sha256-XYZ...";
```

### Step 4: Update Flake with Latest Versions

Edit `/home/mitso/flakes/messaging-apps/flake.nix`:

Replace these lines:
```nix
# Line 12-13: Update Signal version
signalVersion = "7.33.0";  # ⬅️ Use value from update-versions.sh

# Line 30: Update Signal hash
sha256 = "sha256-ABC...";  # ⬅️ Use hash from update-versions.sh

# Line 16: Update Session version
sessionVersion = "1.14.4";  # ⬅️ Use value from update-versions.sh

# Line 53: Update Session hash
sha256 = "sha256-XYZ...";  # ⬅️ Use hash from update-versions.sh
```

### Step 5: Initialize and Test Flake

```bash
cd ~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps

# Initialize flake.lock
nix flake update

# Test builds (this will take a while first time)
nix build .#signal-desktop
nix build .#session-desktop

# Test run (optional)
./result/bin/signal-desktop --version
```

### Step 6: Add Flake to System Configuration

Edit `/home/mitso/.config/nixos/flake.nix`:

```nix
{
  description = "NixOS configuration for shoshin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # ⬅️ ADD THIS
    messaging-apps = {
      url = "path:/home/mitso/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # ... other existing inputs ...
  };

  outputs = { self, nixpkgs, messaging-apps, ... }@inputs: {
    nixosConfigurations.shoshin = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      # ⬅️ ADD messaging-apps here
      specialArgs = { 
        inherit inputs messaging-apps; 
      };
      
      modules = [
        ./hosts/shoshin/configuration.nix
        # ... other modules ...
      ];
    };
  };
}
```

### Step 7: Add Packages to System

Edit `/home/mitso/.config/nixos/modules/workspace/packages.nix`:

```nix
{ config, pkgs, claude-desktop, messaging-apps, ... }:  # ⬅️ ADD messaging-apps

{
  environment.systemPackages = with pkgs; [
    # ... existing packages ...
    
    # Communication
    teams-for-linux
    discord  # Already installed
    
    # ⬅️ ADD THESE (from custom flake)
    messaging-apps.packages.x86_64-linux.signal-desktop
    messaging-apps.packages.x86_64-linux.session-desktop
    
    # ... rest of packages ...
  ];
  
  # ... rest of config ...
}
```

### Step 8: Apply All Changes

```bash
# 1. Test Home Manager changes
cd ~/.config/nixos
home-manager switch --flake .#mitso@shoshin

# 2. Test NixOS changes
sudo nixos-rebuild test

# 3. If everything works, apply permanently
sudo nixos-rebuild switch

# 4. Verify installations
which kitty          # Should show kitty path
xdg-settings get default-web-browser  # Should show brave
signal-desktop --version
session-desktop --version
```

---

## ✅ Verification Checklist

After completing all steps:

- [ ] Kitty terminal opens and looks good (Dracula theme, proper font)
- [ ] Opening a link opens in Brave browser
- [ ] Signal Desktop launches without "expired version" error
- [ ] Session Desktop launches successfully
- [ ] Discord still works (was already installed)
- [ ] Brave is set as default browser in System Settings

---

## 🔄 Future Maintenance

### Every 2-4 Weeks:

```bash
cd ~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps

# 1. Check for updates
./update-versions.sh

# 2. If new versions found, update flake.nix with new values

# 3. Update flake
nix flake update

# 4. Test build
nix build .#signal-desktop
nix build .#session-desktop

# 5. Apply to system
cd ~/.config/nixos
sudo nixos-rebuild switch
```

### When Signal Shows "Update Required":

This means your flake is outdated. Run the update workflow above immediately.

---

## 🎓 What You Learned

### Home Manager vs. System Packages

**Home Manager (Kitty, Brave default):**
- ✅ Per-user configuration
- ✅ Declarative settings
- ✅ Native modules for apps
- ✅ No sudo needed for user config

**System Packages (Signal, Session):**
- ✅ Available to all users
- ✅ System-wide installation
- ✅ Managed by NixOS

### Custom Flakes vs. nixpkgs

**Use Custom Flake When:**
- Package has forced updates (Signal)
- nixpkgs version often outdated
- Need latest version quickly

**Use nixpkgs When:**
- Package stable
- No forced updates
- Community maintenance sufficient

### Key Nix Concepts Applied

1. **Flake Inputs**: Dependencies between flakes
2. **specialArgs**: Passing inputs to modules
3. **Home Manager**: User-level configuration
4. **overrideAttrs**: Modifying existing derivations
5. **mkDerivation**: Building packages from scratch

---

## 📚 Documentation Created

1. **`~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps/flake.nix`** - Signal & Session flake
2. **`~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps/README.md`** - Usage guide
3. **`~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps/update-versions.sh`** - Update helper
4. **`~/Workspaces/Personal_Workspace/building-flake-docs/messaging-apps-flake-learnings.md`** - Deep dive learnings

---

## 🎯 Quick Reference Commands

```bash
# Update messaging apps
cd ~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps && ./update-versions.sh

# Apply Home Manager changes
home-manager switch --flake ~/.config/nixos#mitso@shoshin

# Apply NixOS changes
sudo nixos-rebuild switch

# Test before applying
sudo nixos-rebuild test

# Check what would change
sudo nixos-rebuild dry-build

# Rollback if needed
sudo nixos-rebuild switch --rollback
```

---

## 🐛 Troubleshooting

### Brave Not Default After Rebuild

```bash
# Manually set
xdg-settings set default-web-browser brave-browser.desktop

# Or in KDE System Settings → Applications → Default Applications
```

### Kitty Not Using Custom Config

```bash
# Check if file exists
ls -la ~/.config/kitty/kitty.conf

# Home Manager should create it automatically
# If not, run: home-manager switch --flake ~/.config/nixos#mitso@shoshin
```

### Signal/Session Build Fails

```bash
# SHA256 mismatch?
cd ~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps
./update-versions.sh  # Get new hash
# Update flake.nix with correct hash
nix flake update
nix build .#signal-desktop --rebuild
```

### Package Not Found After Rebuild

```bash
# Check if flake input added
nix flake show ~/.config/nixos

# Should show messaging-apps in inputs
# If not, add to flake.nix inputs section
```

---

## 🎉 You're Done!

After completing these steps, you'll have:
- ✅ Brave as default browser
- ✅ Kitty terminal with full GPU acceleration and custom config
- ✅ Signal Desktop (always latest, no expiration)
- ✅ Session Desktop (privacy-focused alternative)
- ✅ Knowledge of building custom flakes
- ✅ Updated flake-building documentation

**Estimated time:** 30-45 minutes  
**Difficulty:** Medium  
**Value:** High! No more "expired version" errors! 🚀

---

**Need help?** Check the troubleshooting section or review the READMEs in:
- `~/Workspaces/Personal_Workspace/nixos-flakes/messaging-apps/README.md`
- `~/Workspaces/Personal_Workspace/building-flake-docs/messaging-apps-flake-learnings.md`
