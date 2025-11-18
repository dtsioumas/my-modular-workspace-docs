# KDE Plasma 6 Declarative Configuration

**Last Updated:** 2025-11-09

---

## Quick Summary

We've set up **plasma-manager** to manage KDE Plasma 6 settings declaratively. This solves the problem of:
- ✅ Wallpaper disappearing after NixOS rebuild
- ✅ Sound theme reverting to default
- ✅ Virtual desktops configuration lost
- ✅ All other KDE settings being ephemeral

---

## What We Did

### 1. Added plasma-manager to flake.nix

```nix
plasma-manager = {
  url = "github:nix-community/plasma-manager";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

### 2. Created plasma.nix

Location: `~/.config/nixos/home/mitso/plasma.nix`

Configured:
- ✅ **Wallpaper** - Now persists across rebuilds
- ✅ **Sound theme** - Set to "ocean"
- ✅ **Virtual desktops** - 4 desktops in 2 rows
- ✅ **Themes** - Breeze Dark
- ✅ **Hotkeys** - Meta+Alt+K for Konsole, Meta+Alt+E for Dolphin

### 3. Flake Updates Needed

Run these commands to apply:

```bash
cd ~/.config/nixos

# Update flake.lock
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#shoshin
```

---

## Current Configuration

### Wallpaper
```nix
wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Kay/contents/images/1080x1920.png";
```

**To use your own wallpaper:**
1. Choose an image
2. Edit `/home/mitso/.config/nixos/home/mitso/plasma.nix`
3. Change `wallpaper = "/path/to/your/image.jpg";`
4. Rebuild: `sudo nixos-rebuild switch --flake .#shoshin`

### Sound Theme
```nix
soundTheme = "ocean";
```

**Ocean** is the default KDE sound theme with pleasant water sounds.

### Virtual Desktops
```nix
files = {
  kwinrc = {
    Desktops = {
      Number = 4;
      Rows = 2;
    };
  };
};
```

**Configuration:** 4 virtual desktops arranged in 2 rows.

---

## Useful Commands

### Find available themes
```bash
# List Look and Feel themes
plasma-apply-lookandfeel --list

# List color schemes
plasma-apply-colorscheme --list-schemes

# List desktop themes
plasma-apply-desktoptheme --list-themes

# List cursor themes
plasma-apply-cursortheme --list-themes
```

### Capture current KDE settings
```bash
# Use rc2nix to convert current configs to Nix
nix run github:nix-community/plasma-manager

# Save to file
nix run github:nix-community/plasma-manager > captured-config.nix
```

---

## Documentation

- **Full Guide:** `PLASMA_MANAGER_GUIDE.md` (in this directory)
- **Official Docs:** https://nix-community.github.io/plasma-manager/
- **Options Reference:** https://nix-community.github.io/plasma-manager/options.xhtml

---

## Troubleshooting

### Wallpaper still disappearing?
1. Check plasma.nix has correct wallpaper path
2. Rebuild: `sudo nixos-rebuild switch --flake .#shoshin`
3. Log out and back in

### Settings not applying?
1. Make sure plasma-manager is in flake.nix
2. Make sure plasma.nix is imported in home.nix
3. Check for errors: `sudo nixos-rebuild switch --flake .#shoshin --show-trace`
4. Log out and log back in

### VSCode readonly warning?
This is NORMAL and CORRECT behavior with NixOS. The settings.json file is intentionally readonly because it's managed declaratively in the Nix store. This is a feature, not a bug. Ignore the warning.

---

**Next:** After rebuild, enjoy persistent KDE settings! 🎉
