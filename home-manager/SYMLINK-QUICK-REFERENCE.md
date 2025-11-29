# Symlink Management Quick Reference

**Last Updated:** 2025-11-18
**Purpose:** Quick lookup for symlink patterns and commands

---

## 🎯 Tool Decision Matrix

| Scenario | Tool | Reason |
|----------|------|--------|
| **Directory symlinks** | Home-Manager | Declarative, NixOS-native, reproducible |
| **Complex dotfiles** | Chezmoi | Templates, secrets, cross-platform |
| **Simple dotfiles** | Stow | Quick, lightweight, optional |
| **System config** | NixOS | System-level, packages, services |

---

## 📝 Home-Manager Symlink Patterns

### Basic Out-of-Store Symlink

```nix
home.file."<target-in-home>".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/<source-path>";
```

### Example: Single Directory

```nix
{ config, ... }:
{
  home.file."Documents".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.MyHome/Documents";
}
```

Result: `~/Documents → ~/.MyHome/Documents`

### Example: Multiple Directories

```nix
{ config, ... }:
{
  home.file = {
    "Documents".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.MyHome/Documents";

    "Downloads".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.MyHome/Downloads";

    "Pictures".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.MyHome/Pictures";
  };
}
```

### Example: List Pattern (DRY)

```nix
{ config, ... }:
let
  myHome = "${config.home.homeDirectory}/.MyHome";
  dirs = [ "Documents" "Downloads" "Pictures" "Videos" "Music" "Projects" ];
in
{
  home.file = builtins.listToAttrs (
    map (dir: {
      name = dir;
      value = {
        source = config.lib.file.mkOutOfStoreSymlink "${myHome}/${dir}";
      };
    }) dirs
  );
}
```

### Example: Nested Path

```nix
{ config, ... }:
{
  home.file.".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.MyHome/MySpaces/my-modular-workspace/home-manager";
}
```

Result: `~/.config/home-manager → ~/.MyHome/MySpaces/my-modular-workspace/home-manager`

### Example: Conditional Symlink

```nix
{ config, lib, ... }:
{
  home.file."Work" = lib.mkIf (config.networking.hostName == "work-laptop") {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.MyHome/Work";
  };
}
```

---

## 🚀 Common Commands

### Home-Manager

```bash
# Build (test configuration)
home-manager build --flake ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# Switch (apply configuration)
home-manager switch --flake ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# List generations
home-manager generations

# Rollback to previous generation
home-manager switch --switch-generation <number>

# Remove old generations
nix-collect-garbage -d
```

### Manual Symlink (for comparison)

```bash
# Create symlink manually
ln -s ~/.MyHome/Documents ~/Documents

# Remove symlink
rm ~/Documents  # Just removes link, not target

# Verify symlink
ls -la ~/Documents
readlink ~/Documents
```

### Verification

```bash
# List all symlinks in home
ls -la ~ | grep "\->"

# Check specific symlink
ls -la ~/.config/home-manager

# Find all symlinks pointing to .MyHome
find ~ -maxdepth 1 -type l -ls | grep .MyHome
```

---

## 📋 Implementation Checklist

### Before Starting

- [ ] Backup existing directories
- [ ] Document current structure
- [ ] Identify directories to symlink
- [ ] Check for conflicts

### Implementation

- [ ] Create `symlinks.nix` module
- [ ] Define all symlink mappings
- [ ] Import in `home.nix`
- [ ] Build configuration (test)
- [ ] Review build output
- [ ] Switch configuration (apply)

### After Applying

- [ ] Verify all symlinks created
- [ ] Test accessing directories
- [ ] Check for broken links
- [ ] Commit to Git
- [ ] Document changes

---

## 🎨 Module Template

### File: `symlinks.nix`

```nix
{ config, lib, pkgs, ... }:

let
  # Helper variables
  myHome = "${config.home.homeDirectory}/.MyHome";
  workspace = "${myHome}/MySpaces/my-modular-workspace";

  # List of user directories to symlink
  userDirs = [
    "Documents"
    "Downloads"
    "Pictures"
    "Videos"
    "Music"
    "Projects"
  ];

in
{
  home.file =
    # User directories
    builtins.listToAttrs (
      map (dir: {
        name = dir;
        value = {
          source = config.lib.file.mkOutOfStoreSymlink "${myHome}/${dir}";
        };
      }) userDirs
    )
    //
    # Special directories
    {
      ".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink
        "${workspace}/home-manager";

      # Add more special directories here...
    };
}
```

### File: `home.nix` (import)

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./symlinks.nix
    # ... other imports
  ];

  # ... rest of configuration
}
```

---

## 🔧 Troubleshooting

### Issue: "Existing file in the way"

```nix
# Error during home-manager switch
# Solution: Move existing file/directory to .MyHome/ first

# Example:
mv ~/Documents ~/.MyHome/Documents
home-manager switch
```

### Issue: Broken Symlink

```bash
# Check if symlink is broken
ls -la ~/Documents  # Shows red if broken

# Fix: Ensure target exists
ls -la ~/.MyHome/Documents

# Recreate if needed
rm ~/Documents
home-manager switch
```

### Issue: Symlink Not Created

```bash
# Check if module is imported
grep "symlinks.nix" ~/.MyHome/MySpaces/my-modular-workspace/home-manager/home.nix

# Check build output
home-manager build --flake <path> 2>&1 | less

# Rebuild with verbose
home-manager switch --flake <path> -v
```

---

## 📚 Resources

### Documentation

- **Home-Manager Manual:** https://nix-community.github.io/home-manager/
- **home.file Option:** https://nix-community.github.io/home-manager/options.html#opt-home.file
- **Session Summary:** `~/.MyHome/MySpaces/my-modular-workspace/sessions/summaries/symlink-management-session-2025-11-18.md`

### Example Configurations

```bash
# Real-world examples
# Find home-manager configs on GitHub with symlink patterns
# Search: "mkOutOfStoreSymlink" site:github.com
```

---

## 💡 Best Practices

1. **Group related symlinks** in separate modules
2. **Use variables** for common paths
3. **Document why** each symlink exists
4. **Test before committing** to Git
5. **Keep backups** of important data
6. **Use list patterns** for similar symlinks (DRY)

---

## 🎯 Common Patterns

### User Directories

```nix
# Standard user directories
Documents Downloads Pictures Videos Music Projects
```

### Config Directories

```nix
# Special config locations
".config/home-manager"
".config/Code"
".local/share/applications"
```

### Workspace Links

```nix
# Development workspaces
"Projects/work"
"Projects/personal"
"Projects/opensource"
```

---

**Quick access:** Keep this file open for reference during implementation!
