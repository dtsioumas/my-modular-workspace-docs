# Using rc2nix to Capture KDE Settings

**Last Updated:** 2025-11-09

---

## What is rc2nix?

`rc2nix` is a tool included with plasma-manager that converts KDE config files (RC files) to Nix expressions. This makes it easy to:

1. **Migrate** existing KDE configuration to declarative Nix
2. **Discover** what settings changed when using GUI tools
3. **Generate** initial plasma-manager configuration

---

## Basic Usage

### Capture All KDE Settings

```bash
# Run rc2nix (downloads and runs from GitHub)
nix run github:nix-community/plasma-manager

# Output goes to stdout, so save to file:
nix run github:nix-community/plasma-manager > captured-plasma-config.nix
```

This will scan common KDE config files in `~/.config/` and convert them to Nix.

### Capture Specific Config File

```bash
# Capture just kwinrc (window manager settings)
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc

# Capture plasmarc
nix run github:nix-community/plasma-manager -- ~/.config/plasmarc

# Capture kdeglobals
nix run github:nix-community/plasma-manager -- ~/.config/kdeglobals
```

---

## Workflow: Finding What Changed

### Step 1: Capture BEFORE
```bash
nix run github:nix-community/plasma-manager > before.nix
```

### Step 2: Make Changes in GUI
Open System Settings and change something (e.g., wallpaper, theme, virtual desktops)

### Step 3: Capture AFTER
```bash
nix run github:nix-community/plasma-manager > after.nix
```

### Step 4: Compare
```bash
diff before.nix after.nix
```

This shows exactly what changed in Nix format!

---

## Example: Finding Virtual Desktop Settings

### 1. Capture before changing
```bash
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc > kwinrc-before.nix
```

### 2. Change virtual desktops in System Settings
- Open System Settings → Workspace Behavior → Virtual Desktops
- Change from 4 to 6 desktops

### 3. Capture after changing
```bash
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc > kwinrc-after.nix
```

### 4. See what changed
```bash
diff kwinrc-before.nix kwinrc-after.nix
```

Output shows:
```diff
< Number = 4;
> Number = 6;
```

Now you know to use:
```nix
files.kwinrc.Desktops.Number = 6;
```

---

## Understanding rc2nix Output

### Output Format

rc2nix generates config using the `files` module:

```nix
{
  programs.plasma = {
    enable = true;

    files = {
      "kwinrc" = {
        "Desktops" = {
          "Id_1" = "12345-uuid-here";
          "Number" = 4;
          "Rows" = 2;
        };
      };
    };
  };
}
```

### High-level vs Low-level

rc2nix outputs **low-level** `files` module config. For better results:

1. **Check if high-level option exists:**
   - ✅ Use `workspace.wallpaper` instead of `files.plasmarc`
   - ✅ Use `workspace.soundTheme` instead of `files.kdeglobals`

2. **Use `files` only when needed:**
   - Virtual desktops (not in high-level API)
   - Custom kwin settings
   - Advanced configurations

---

## Common Config Files

### kwinrc
**Contains:** Window manager settings, virtual desktops, effects

**Capture:**
```bash
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc
```

**Common sections:**
- `[Desktops]` - Virtual desktop configuration
- `[Effect-*]` - Desktop effects
- `[Windows]` - Window behavior

### plasmarc
**Contains:** Plasma theme, wallpaper settings

**Capture:**
```bash
nix run github:nix-community/plasma-manager -- ~/.config/plasmarc
```

**Common sections:**
- `[Theme]` - Theme settings
- `[Wallpapers]` - Wallpaper configuration

### kdeglobals
**Contains:** Global KDE settings, fonts, colors

**Capture:**
```bash
nix run github:nix-community/plasma-manager -- ~/.config/kdeglobals
```

**Common sections:**
- `[General]` - Fonts, colors
- `[KDE]` - KDE-wide settings
- `[Icons]` - Icon theme

---

## Tips & Best Practices

### ✅ DO

- **Capture settings BEFORE making manual changes** - easier to see diffs
- **Use specific files** instead of capturing everything
- **Check high-level options first** before using `files` module
- **Test incrementally** - apply one setting at a time

### ❌ DON'T

- **Don't blindly copy all rc2nix output** - much of it may be unnecessary
- **Don't use `files` for settings that have high-level options**
- **Don't capture after every tiny change** - group related changes

---

## Example Workflow: Setting Up New Machine

### 1. On your current machine
```bash
# Capture your current KDE config
nix run github:nix-community/plasma-manager > my-kde-config.nix

# Review and extract important settings
cat my-kde-config.nix
```

### 2. Create plasma.nix
```nix
{ config, pkgs, lib, ... }:
{
  programs.plasma = {
    enable = true;

    # Use high-level options where available
    workspace = {
      wallpaper = "/path/to/wallpaper.jpg";
      soundTheme = "ocean";
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    # Use files module for unsupported settings
    files = {
      kwinrc.Desktops = {
        Number = 4;
        Rows = 2;
      };
    };
  };
}
```

### 3. On new machine
- Add plasma-manager to flake
- Import plasma.nix
- Rebuild
- Enjoy identical KDE setup!

---

## Troubleshooting

### rc2nix not working?
```bash
# Check if nix flakes are enabled
nix --version

# Try with explicit path
nix --extra-experimental-features "nix-command flakes" run github:nix-community/plasma-manager
```

### Output is empty?
- Check the config file exists: `ls ~/.config/kwinrc`
- Try capturing a different file
- Ensure KDE Plasma is actually running

### Too much output?
```bash
# Capture specific sections only
nix run github:nix-community/plasma-manager -- ~/.config/kwinrc | grep -A 10 "Desktops"
```

---

## Advanced: Scripted Capture

### Capture all important configs
```bash
#!/usr/bin/env bash

CONFIGS=(
  "kwinrc"
  "plasmarc"
  "kdeglobals"
  "kglobalshortcutsrc"
)

for config in "${CONFIGS[@]}"; do
  echo "Capturing $config..."
  nix run github:nix-community/plasma-manager -- ~/.config/$config > captured-$config.nix
done

echo "✅ All configs captured!"
```

---

## Documentation

- **plasma-manager README:** https://github.com/nix-community/plasma-manager#capturing-your-current-configuration-with-rc2nix
- **Options Reference:** https://nix-community.github.io/plasma-manager/options.xhtml

---

**Next:** Use the captured settings to build your declarative plasma.nix! 🚀
