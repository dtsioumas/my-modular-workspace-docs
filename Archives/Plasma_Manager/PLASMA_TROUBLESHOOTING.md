# Plasma Manager - Troubleshooting Guide

**Last Updated:** 2025-11-09

---

## Common Issues & Solutions

### ❌ Wallpaper Disappeared After Rebuild

**Cause:** Home-manager overwrites KDE config files without plasma-manager

**Solution:**
```nix
# In plasma.nix
programs.plasma.workspace.wallpaper = "/path/to/your/wallpaper.jpg";
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#shoshin
```

**Why this happens:** KDE stores wallpaper path in `~/.config/plasmarc`. When home-manager rebuilds, it recreates config files, losing your wallpaper setting. plasma-manager ensures the wallpaper is always set.

---

### ❌ Sound Theme Reverted to Default

**Cause:** Same as wallpaper - config file overwritten

**Solution:**
```nix
# In plasma.nix
programs.plasma.workspace.soundTheme = "ocean";
```

Available sound themes:
- `ocean` (KDE default - peaceful water sounds)
- `freedesktop` (Classic Linux sounds)

To find more:
```bash
ls /usr/share/sounds/
```

---

### ❌ Virtual Desktops Lost After Rebuild

**Cause:** Virtual desktop settings not managed declaratively

**Solution:**
```nix
# In plasma.nix
programs.plasma.files = {
  kwinrc.Desktops = {
    Number = 4;
    Rows = 2;
  };
};
```

**Note:** Virtual desktops aren't in plasma-manager's high-level API yet, so use the `files` module.

---

### ❌ plasma-manager Options Don't Exist

**Symptom:** Build fails with error like:
```
error: The option `programs.plasma.virtualDesktops` does not exist
```

**Cause:** Using options that don't exist in plasma-manager

**Solution:** Check the [official options reference](https://nix-community.github.io/plasma-manager/options.xhtml)

**Valid options include:**
- ✅ `workspace.wallpaper`
- ✅ `workspace.soundTheme`
- ✅ `workspace.lookAndFeel`
- ✅ `workspace.cursor`
- ✅ `hotkeys.commands`
- ✅ `files.*` (low-level config)

**Invalid options:**
- ❌ `virtualDesktops.*` (use `files.kwinrc.Desktops` instead)
- ❌ `appearance.*` (use `workspace.*` instead)
- ❌ `powerManagement.*` (not supported yet)

---

### ❌ Build Fails: "Failed to evaluate"

**Symptom:**
```
error: attribute 'plasma-manager' missing
```

**Cause:** plasma-manager not in flake inputs

**Solution:**
```nix
# In flake.nix inputs:
plasma-manager = {
  url = "github:nix-community/plasma-manager";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};

# In outputs:
outputs = { self, nixpkgs, home-manager, plasma-manager, ... }:

# In home-manager config:
home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
```

Then:
```bash
nix flake update
```

---

### ❌ Settings Don't Apply After Rebuild

**Symptom:** Rebuilt successfully but settings unchanged

**Cause:** Need to log out/in for KDE to reload

**Solution:**
1. Save your work
2. Log out of KDE
3. Log back in
4. Settings should now be applied

**Some settings may need:**
- Full system restart (rare)
- Plasma restart: `kquitapp6 plasmashell && kstart plasmashell`

---

### ❌ rc2nix Not Working

**Symptom:**
```bash
$ nix run github:nix-community/plasma-manager
error: experimental Nix feature 'nix-command' is disabled
```

**Solution:**
```bash
# Enable flakes temporarily
nix --extra-experimental-features "nix-command flakes" run github:nix-community/plasma-manager

# Or enable permanently in ~/.config/nix/nix.conf:
experimental-features = nix-command flakes
```

---

### ❌ Flake Update Fails

**Symptom:**
```bash
$ nix flake update
error: cannot add path '/nix/store/...' because it lacks a signature
```

**Solution:**
```bash
# Update with --impure flag
nix flake update --impure

# Or trust the source
nix flake update --override-input plasma-manager github:nix-community/plasma-manager
```

---

### ❌ Home-Manager Activation Fails

**Symptom:**
```
Activating home-manager configuration for mitso...
error: collision between `/nix/store/...plasma-manager` and `/nix/store/...`
```

**Cause:** Conflicting packages or modules

**Solution:**
```nix
# In home-manager config, use backup option:
home-manager.backupFileExtension = "backup";
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#shoshin
```

Conflicting files will be renamed with `.backup` extension.

---

### ❌ Syntax Errors in plasma.nix

**Symptom:**
```
error: syntax error, unexpected '}', expecting ';'
```

**Common causes:**
1. Missing semicolon
2. Mismatched braces
3. Incorrect nesting

**Solution:**
```bash
# Check syntax with nix-instantiate
nix-instantiate --parse ~/.config/nixos/home/mitso/plasma.nix

# Or use show-trace for detailed error
sudo nixos-rebuild switch --flake .#shoshin --show-trace
```

**Common fix:**
```nix
# WRONG - missing semicolon
workspace = {
  wallpaper = "/path/to/image.jpg"  # ❌
}

# CORRECT
workspace = {
  wallpaper = "/path/to/image.jpg";  # ✅
};
```

---

### ❌ Wallpaper Path Invalid

**Symptom:** Build succeeds but wallpaper is black/missing

**Cause:** Invalid file path or file doesn't exist

**Solution:**
```bash
# Verify file exists
ls -la "/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg"

# Check permissions
file "/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg"
```

**Fix:**
```nix
# Use absolute path
wallpaper = "/home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg";

# Or use home directory variable
wallpaper = "${config.home.homeDirectory}/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg";
```

---

### ❌ KDE Config Files Keep Changing

**Symptom:** Every rebuild shows different values in KDE configs

**Cause:** Not using `overrideConfig` mode

**Solution (Nuclear Option):**
```nix
programs.plasma = {
  enable = true;
  overrideConfig = true;  # ⚠️ DELETES all KDE config files on rebuild!
  # ... your settings
};
```

**⚠️ WARNING:** This DELETES all KDE config files and replaces with plasma-manager generated ones. **Backup first!**

**Better approach:** Don't use `overrideConfig`. Let plasma-manager coexist with manual settings.

---

### ❌ Panel/Widget Configuration Lost

**Symptom:** Custom panel layout disappears after rebuild

**Cause:** Panel config not in plasma.nix

**Solution:** Use rc2nix to capture panel config:
```bash
nix run github:nix-community/plasma-manager -- ~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

Then add to plasma.nix using the `panels` module (if supported) or `files` module.

---

## Getting Help

### Debug Mode
```bash
# Rebuild with verbose output
sudo nixos-rebuild switch --flake .#shoshin --show-trace -vvv

# Check home-manager logs
journalctl --user -u home-manager-mitso.service -n 50
```

### Check Generated Config
```bash
# See what plasma-manager generated
cat ~/.config/kdeglobals
cat ~/.config/kwinrc
cat ~/.config/plasmarc
```

### Verify plasma-manager is loaded
```bash
# Check if module is active
home-manager generations | head -5
```

---

## Best Practices

### ✅ DO

1. **Start small** - Add one setting at a time
2. **Test after each change** - Rebuild and verify
3. **Use high-level options** when available
4. **Backup configs** before enabling `overrideConfig`
5. **Check official docs** for supported options
6. **Log out/in** after rebuild to see changes

### ❌ DON'T

1. **Don't use invalid options** - check docs first
2. **Don't enable `overrideConfig` without backups**
3. **Don't assume all KDE settings are supported**
4. **Don't edit ~/.config files directly** - use plasma.nix
5. **Don't skip `nix flake update`** on first install

---

## Documentation

- **plasma-manager:** https://github.com/nix-community/plasma-manager
- **Options:** https://nix-community.github.io/plasma-manager/options.xhtml
- **Issues:** https://github.com/nix-community/plasma-manager/issues

---

**Still stuck?** Check the [GitHub issues](https://github.com/nix-community/plasma-manager/issues) or ask in NixOS Discourse!
