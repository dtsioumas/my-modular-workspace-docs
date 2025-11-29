# Plasma Manager Guide

**Last Updated:** 2025-11-29
**Sources Merged:** PLASMA_README.md, PLASMA_MANAGER_GUIDE.md, PLASMA_QUICK_REFERENCE.md, PLASMA_RC2NIX_GUIDE.md, PLASMA_TROUBLESHOOTING.md, PLASMA_CONFIG_COMPARISON.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [Using rc2nix](#using-rc2nix)
- [Quick Reference](#quick-reference)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

**plasma-manager** is a Home Manager module that allows you to configure KDE Plasma declaratively using Nix. This means all your KDE settings (wallpaper, themes, virtual desktops, sound, etc.) are managed in code and can be version controlled.

### Why Use plasma-manager?

1. **Declarative Configuration** - All settings in one place
2. **Reproducible** - Same config on multiple machines
3. **Version Control** - Track changes with Git
4. **No More Lost Settings** - Settings won't disappear after rebuild!

### What We Solved

- Wallpaper disappearing after NixOS rebuild
- Sound theme reverting to default
- Virtual desktops configuration lost
- All other KDE settings being ephemeral

---

## Quick Start

### 1. Add plasma-manager to flake.nix

```nix
plasma-manager = {
  url = "github:nix-community/plasma-manager";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

### 2. Create plasma.nix

```nix
{ pkgs, ... }:
{
  programs.plasma = {
    enable = true;
    workspace = {
      wallpaper = "/path/to/your/wallpaper.jpg";
      soundTheme = "ocean";
    };
  };
}
```

### 3. Apply Changes

```bash
cd ~/.config/nixos
nix flake update
sudo nixos-rebuild switch --flake .#shoshin
# Log out and back in
```

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
    homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
      modules = [
        plasma-manager.homeManagerModules.plasma-manager
        ./home/user/home.nix
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

## Configuration

### Workspace Settings

```nix
programs.plasma.workspace = {
  # Wallpaper
  wallpaper = "/path/to/image.jpg";
  wallpaperSlideShow = {
    path = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/";
    interval = 300; # seconds
  };
  wallpaperFillMode = "stretch"; # stretch, fit, fill, center, tile

  # Themes
  lookAndFeel = "org.kde.breezedark.desktop";
  theme = "breeze-dark";
  colorScheme = "BreezeDark";
  iconTheme = "Papirus-Dark";

  # Cursor
  cursor = {
    theme = "Bibata-Modern-Ice";
    size = 32;
  };

  # Sound
  soundTheme = "ocean"; # or "freedesktop"

  # Behavior
  clickItemTo = "open"; # or "select"
  enableMiddleClickPaste = false;
  tooltipDelay = 5;
};
```

### Hotkeys

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

### Panels

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
          shown = ["org.kde.plasma.battery"];
          hidden = ["org.kde.plasma.networkmanagement"];
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

### Files Module (for unsupported options)

Virtual desktops and other settings not in high-level API:

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

### Complete Example

```nix
{ pkgs, ... }:
{
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      theme = "breeze-dark";
      iconTheme = "Papirus-Dark";
      cursor = { theme = "Bibata-Modern-Ice"; size = 32; };
      wallpaper = "/home/user/wallpaper.jpg";
      soundTheme = "ocean";
      clickItemTo = "open";
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

## Using rc2nix

`rc2nix` is a tool included with plasma-manager that converts KDE config files to Nix expressions.

### Basic Usage

```bash
# Capture ALL KDE settings
nix run github:nix-community/plasma-manager > captured-config.nix

# Capture specific config file
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc

# Save to file
nix run github:nix-community/plasma-manager > plasma-config.nix
```

### Workflow: Finding What Changed

```bash
# 1. Capture BEFORE
nix run github:nix-community/plasma-manager > before.nix

# 2. Make changes in GUI (System Settings)

# 3. Capture AFTER
nix run github:nix-community/plasma-manager > after.nix

# 4. Compare
diff before.nix after.nix
```

### Common Config Files

| File | Contains |
|------|----------|
| `~/.config/kwinrc` | Window manager, virtual desktops, effects |
| `~/.config/plasmarc` | Plasma theme, wallpaper settings |
| `~/.config/kdeglobals` | Global KDE settings, fonts, colors |
| `~/.config/plasma-org.kde.plasma.desktop-appletsrc` | Desktop/panel widgets |

### Tips

- **DO:** Capture settings BEFORE making manual changes
- **DO:** Use specific files instead of capturing everything
- **DO:** Check high-level options first before using `files` module
- **DON'T:** Blindly copy all rc2nix output
- **DON'T:** Use `files` for settings that have high-level options

---

## Quick Reference

### Find Available Themes

```bash
plasma-apply-lookandfeel --list
plasma-apply-colorscheme --list-schemes
plasma-apply-desktoptheme --list-themes
plasma-apply-cursortheme --list-themes
```

### Apply Changes

```bash
cd ~/.config/nixos
nix flake update
sudo nixos-rebuild switch --flake .#shoshin
# Log out and back in
```

### Valid Options

- `workspace.wallpaper`
- `workspace.soundTheme`
- `workspace.lookAndFeel`
- `workspace.cursor`
- `hotkeys.commands`
- `files.*` (low-level config)

### Invalid Options

- `virtualDesktops.*` (use `files.kwinrc.Desktops`)
- `appearance.*` (use `workspace.*`)
- `powerManagement.*` (not supported yet)

---

## Troubleshooting

### Wallpaper Disappeared After Rebuild

**Cause:** Home-manager overwrites KDE config files without plasma-manager

**Solution:**
```nix
programs.plasma.workspace.wallpaper = "/path/to/your/wallpaper.jpg";
```

### Sound Theme Reverted to Default

**Solution:**
```nix
programs.plasma.workspace.soundTheme = "ocean";
```

### Virtual Desktops Lost After Rebuild

**Solution:**
```nix
programs.plasma.files = {
  kwinrc.Desktops = {
    Number = 4;
    Rows = 2;
  };
};
```

### plasma-manager Options Don't Exist

**Error:** `The option 'programs.plasma.virtualDesktops' does not exist`

**Solution:** Check the [official options reference](https://nix-community.github.io/plasma-manager/options.xhtml)

### Build Fails: "attribute 'plasma-manager' missing"

**Solution:** Add plasma-manager to flake inputs and run `nix flake update`

### Settings Don't Apply After Rebuild

**Solution:**
1. Log out and log back in
2. Or restart Plasma: `kquitapp6 plasmashell && kstart plasmashell`

### rc2nix Not Working

**Error:** `experimental Nix feature 'nix-command' is disabled`

**Solution:**
```bash
nix --extra-experimental-features "nix-command flakes" run github:nix-community/plasma-manager
```

### Override Config Mode

For fully declarative setup (WARNING: deletes all KDE config files!):
```nix
programs.plasma = {
  enable = true;
  overrideConfig = true;  # DELETES all KDE configs on rebuild!
};
```

### Best Practices

**DO:**
- Start small - add one setting at a time
- Test after each change
- Use high-level options when available
- Backup configs before enabling `overrideConfig`
- Log out/in after rebuild

**DON'T:**
- Use invalid options without checking docs
- Enable `overrideConfig` without backups
- Assume all KDE settings are supported
- Edit ~/.config files directly - use plasma.nix

---

## References

- **Official Documentation:** https://nix-community.github.io/plasma-manager/
- **GitHub:** https://github.com/nix-community/plasma-manager
- **Options Reference:** https://nix-community.github.io/plasma-manager/options.xhtml
- **Examples:** https://github.com/nix-community/plasma-manager/tree/trunk/examples

---

*Migrated from docs/commons/plasma-manager/ on 2025-11-29*
