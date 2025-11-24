# Plasma Manager - Quick Reference Card

**Last Updated:** 2025-11-09

---

## Your Current Settings

```nix
# Wallpaper
wallpaper = "/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg";

# Sound Theme
soundTheme = "ocean";

# Virtual Desktops (via files module)
files.kwinrc.Desktops = {
  Number = 4;
  Rows = 2;
};
```

---

## Essential Commands

### Capture Current KDE Settings
```bash
# Capture ALL settings to file
nix run github:nix-community/plasma-manager > plasma-settings.nix

# Capture specific config file
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc
```

### Apply Changes
```bash
cd ~/.config/nixos

# Update flake inputs (first time only)
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#shoshin

# Log out and back in to see changes
```

### Find Available Themes
```bash
# Look and Feel themes
plasma-apply-lookandfeel --list

# Color schemes
plasma-apply-colorscheme --list-schemes

# Desktop themes
plasma-apply-desktoptheme --list-themes

# Cursor themes
plasma-apply-cursortheme --list-themes
```

---

## Common plasma-manager Options

### Workspace Settings
```nix
programs.plasma.workspace = {
  # Wallpaper
  wallpaper = "/path/to/image.jpg";

  # Themes
  lookAndFeel = "org.kde.breezedark.desktop";
  colorScheme = "BreezeDark";
  theme = "breeze-dark";
  iconTheme = "Papirus-Dark";

  # Cursor
  cursor = {
    theme = "Breeze_Snow";
    size = 32;
  };

  # Sound
  soundTheme = "ocean";

  # Behavior
  clickItemTo = "open"; # or "select"
  enableMiddleClickPaste = false;
  tooltipDelay = 5;
};
```

### Hotkeys
```nix
programs.plasma.hotkeys.commands = {
  "launch-app" = {
    name = "Launch App";
    key = "Meta+Alt+A";
    command = "app-name";
  };
};
```

### Files Module (for unsupported options)
```nix
programs.plasma.files = {
  kwinrc = {
    Desktops = {
      Number = 4;
      Rows = 2;
    };
  };

  kdeglobals = {
    General = {
      fixed = "Hack,10,-1,5,50,0,0,0,0,0";
    };
  };
};
```

---

## File Locations

### NixOS Config Files
- Flake: `~/.config/nixos/flake.nix`
- Plasma Config: `~/.config/nixos/home/mitso/plasma.nix`
- Home Config: `~/.config/nixos/home/mitso/home.nix`

### KDE Config Files (for reference)
- `~/.config/kdeglobals` - Global KDE settings
- `~/.config/kwinrc` - Window manager
- `~/.config/plasmarc` - Plasma settings
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` - Desktop/panels

---

## Troubleshooting

### Wallpaper disappeared after rebuild?
✅ **This is why you need plasma-manager!**
1. Add wallpaper path to `plasma.nix`
2. Rebuild
3. Log out/in

### Sound theme not applying?
```nix
workspace.soundTheme = "ocean";
```

### Virtual desktops lost?
Use `files` module:
```nix
files.kwinrc.Desktops = {
  Number = 4;
  Rows = 2;
};
```

### Settings not taking effect?
1. Check for syntax errors: `sudo nixos-rebuild switch --show-trace`
2. Log out and log back in
3. Some settings need system restart

---

## Documentation Links

- **Full Guide:** `PLASMA_MANAGER_GUIDE.md`
- **Official Docs:** https://nix-community.github.io/plasma-manager/
- **GitHub:** https://github.com/nix-community/plasma-manager
- **Options:** https://nix-community.github.io/plasma-manager/options.xhtml

---

**Remember:** Not all KDE settings are supported by plasma-manager yet. Use the `files` module for unsupported options!
