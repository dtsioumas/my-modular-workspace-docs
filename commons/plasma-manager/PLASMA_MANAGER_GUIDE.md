# Plasma Manager - Declarative KDE Plasma 6 Configuration

**Date Created:** 2025-11-09
**Purpose:** Complete guide to managing KDE Plasma 6 settings declaratively with NixOS
**Project:** plasma-manager by nix-community
**Documentation:** https://nix-community.github.io/plasma-manager/

---

## Overview

**plasma-manager** is a Home Manager module that allows you to configure KDE Plasma declaratively using Nix. This means all your KDE settings (wallpaper, themes, virtual desktops, sound, etc.) are managed in code and can be version controlled.

### Why Use plasma-manager?

1. **Declarative Configuration** - All settings in one place
2. **Reproducible** - Same config on multiple machines
3. **Version Control** - Track changes with Git
4. **No More Lost Settings** - Settings won't disappear after rebuild!

---

## Installation

### Step 1: Add to flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }: {
    homeConfigurations."mitso@shoshin" = home-manager.lib.homeManagerConfiguration {
      modules = [
        plasma-manager.homeManagerModules.plasma-manager
        ./home/mitso/home.nix
      ];
    };
  };
}
```

### Step 2: Enable in home.nix

```nix
{
  programs.plasma.enable = true;
}
```

---

## Configuration Examples

### 🎨 Wallpaper

```nix
programs.plasma.workspace = {
  # Static wallpaper
  wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Kay/contents/images/1080x1920.png";

  # Or custom wallpaper
  wallpaper = "/home/mitso/Pictures/wallpapers/my-wallpaper.jpg";

  # Slideshow
  wallpaperSlideShow = {
    path = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/";
    interval = 300; # seconds
  };

  # Plain color
  wallpaperPlainColor = "0,64,174,256"; # R,G,B,A

  # Fill mode
  wallpaperFillMode = "stretch"; # Options: stretch, fit, fill, center, tile
};
```

### 🔊 Sound Theme

```nix
programs.plasma.workspace = {
  soundTheme = "ocean"; # Options: ocean, freedesktop, etc.
};
```

**Available sound themes:**
- `ocean` - KDE Ocean sound theme
- `freedesktop` - Freedesktop sound theme
- Check `/usr/share/sounds/` for more options

### 🎨 Themes & Appearance

```nix
programs.plasma.workspace = {
  # Global theme
  lookAndFeel = "org.kde.breezedark.desktop";

  # Plasma theme
  theme = "breeze-dark";

  # Color scheme
  colorScheme = "BreezeDark";

  # Icon theme
  iconTheme = "Papirus-Dark";

  # Cursor
  cursor = {
    theme = "Bibata-Modern-Ice";
    size = 32;
  };
};
```

**To find available themes, run:**
```bash
plasma-apply-lookandfeel --list
plasma-apply-desktoptheme --list-themes
plasma-apply-colorscheme --list-schemes
plasma-apply-cursortheme --list-themes
```

### 🖥️ Window Decorations

```nix
programs.plasma.workspace = {
  windowDecorations = {
    library = "org.kde.kwin.aurorae";
    theme = "__aurorae__svg__CatppuccinMocha-Modern";
  };
};
```

**To find window decoration settings:**
1. Change decorations in System Settings
2. Check `~/.config/kwinrc` → `[org.kde.kdecoration2]` section
3. Copy `library` and `theme` values

### 🚀 Splash Screen

```nix
programs.plasma.workspace = {
  splashScreen = {
    engine = "none"; # or "KSplashQML"
    theme = "None"; # Disable splash, or set to a theme name
  };
};
```

### 🖱️ Workspace Behavior

```nix
programs.plasma.workspace = {
  clickItemTo = "open"; # or "select"
  enableMiddleClickPaste = false;
  tooltipDelay = 5; # milliseconds
};
```

### ⌨️ Hotkeys

```nix
programs.plasma.hotkeys.commands = {
  "launch-konsole" = {
    name = "Launch Konsole";
    key = "Meta+Alt+K";
    command = "konsole";
  };
  "launch-brave" = {
    name = "Launch Brave";
    key = "Meta+Alt+B";
    command = "brave";
  };
};
```

### 📊 Panels

```nix
programs.plasma.panels = [
  {
    location = "bottom";
    height = 44;
    widgets = [
      {
        kickoff = {
          sortAlphabetically = true;
          icon = "nix-snowflake-white";
        };
      }
      {
        iconTasks = {
          launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:org.kde.konsole.desktop"
            "applications:brave-browser.desktop"
          ];
        };
      }
      "org.kde.plasma.marginsseparator"
      {
        systemTray.items = {
          shown = [
            "org.kde.plasma.battery"
            "org.kde.plasma.bluetooth"
          ];
          hidden = [
            "org.kde.plasma.networkmanagement"
          ];
        };
      }
      {
        digitalClock = {
          calendar.firstDayOfWeek = "monday";
          time.format = "24h";
        };
      }
    ];
    hiding = "none"; # or "autohide", "dodgewindows"
  }
];
```

---

## Virtual Desktops & Activities

**Note:** Virtual desktops and activities are NOT yet fully supported in plasma-manager. You'll need to configure these using the `files` module or manually.

### Manual Configuration via KDE Config Files

```nix
programs.plasma.files = {
  kwinrc = {
    Desktops = {
      Number = 4;
      Rows = 2;
    };
  };
};
```

**To find the right settings:**
1. Configure virtual desktops in System Settings
2. Check `~/.config/kwinrc`
3. Copy the relevant sections to `programs.plasma.files`

---

## Using rc2nix to Convert Existing Config

plasma-manager includes a tool called `rc2nix` that reads your current KDE config files and converts them to Nix format:

```bash
# Convert all KDE configs
nix run github:nix-community/plasma-manager

# Convert specific config file
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc

# Save to file
nix run github:nix-community/plasma-manager > plasma-config.nix
```

This generates Nix code that you can copy into your home-manager configuration.

---

## Override Config Mode

By default, plasma-manager writes settings but leaves other options alone. For a fully declarative setup:

```nix
programs.plasma = {
  enable = true;
  overrideConfig = true; # ⚠️ This deletes all config files on rebuild!
};
```

**⚠️ WARNING:** `overrideConfig = true` will DELETE all KDE config files and replace them with plasma-manager generated ones. Backup your configs first!

---

## Complete Example

```nix
{ pkgs, ... }:
{
  programs.plasma = {
    enable = true;

    workspace = {
      # Appearance
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      theme = "breeze-dark";
      iconTheme = "Papirus-Dark";

      # Cursor
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 32;
      };

      # Wallpaper
      wallpaper = "/home/mitso/Pictures/wallpapers/my-wallpaper.jpg";

      # Sound
      soundTheme = "ocean";

      # Behavior
      clickItemTo = "open";
      enableMiddleClickPaste = false;
    };

    hotkeys.commands = {
      "launch-konsole" = {
        name = "Launch Konsole";
        key = "Meta+Alt+K";
        command = "konsole";
      };
    };

    panels = [
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
  };
}
```

---

## Troubleshooting

### Settings Not Applying

1. **Log out and back in** - Some settings require re-login
2. **Check syntax** - Use `nixos-rebuild switch --show-trace` for errors
3. **Use rc2nix** - Generate config from working manual setup
4. **Check plasma-manager version** - Update to latest trunk

### Wallpaper Disappears After Rebuild

**This is why you need plasma-manager!** KDE writes wallpaper settings to config files that get overwritten by home-manager. Solution:

```nix
programs.plasma.workspace.wallpaper = "/path/to/wallpaper.jpg";
```

### Finding Config Values

1. Configure setting in System Settings (GUI)
2. Check the relevant config file in `~/.config/`
3. Use `rc2nix` to convert to Nix format
4. Add to your configuration

**Common config files:**
- `~/.config/kwinrc` - Window manager settings
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` - Desktop/panel widgets
- `~/.config/kdeglobals` - Global KDE settings
- `~/.config/plasmarc` - Plasma theme settings

---

## Links & Resources

- **Official Documentation:** https://nix-community.github.io/plasma-manager/
- **GitHub:** https://github.com/nix-community/plasma-manager
- **Options Reference:** https://nix-community.github.io/plasma-manager/options.xhtml
- **Examples:** https://github.com/nix-community/plasma-manager/tree/trunk/examples

---

## Next Steps for Shoshin

1. Add plasma-manager to `flake.nix` inputs
2. Create `home/mitso/plasma.nix` with configuration
3. Import in `home/mitso/home.nix`
4. Run `rc2nix` to capture current settings
5. Migrate settings to declarative config
6. Test with `nixos-rebuild switch`

---

**Last Updated:** 2025-11-09
**Maintained By:** plasma-manager nix-community
