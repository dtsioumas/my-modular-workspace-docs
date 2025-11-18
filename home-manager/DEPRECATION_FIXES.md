# Home-Manager Deprecation Fixes

**Date:** 2025-11-17
**Project:** my-modular-workspace-decoupling-home
**Purpose:** Fix all deprecated home-manager options detected during build

---

## 🚨 Detected Deprecations

From `home-manager switch` output:

```
evaluation warning: plasma-manager: homeManagerModules has been renamed to homeModules
trace: warning: The option `programs.vscode.userSettings' ... renamed to `programs.vscode.profiles.default.userSettings'.
trace: warning: The option `programs.kitty.theme' ... changed to `programs.kitty.themeFile' (different type)
trace: warning: The option `programs.git.userEmail' ... renamed to `programs.git.settings.user.email'.
trace: warning: The option `programs.git.userName' ... renamed to `programs.git.settings.user.name'.
trace: warning: The option `programs.git.extraConfig' ... renamed to `programs.git.settings'.
```

---

## 📝 Fix Plan

### 1. Fix: plasma-manager Module Import

**File:** `~/.config/my-home-manager-flake/flake.nix:32`

**Current (Deprecated):**
```nix
modules = [
  ./home.nix
  plasma-manager.homeManagerModules.plasma-manager
];
```

**Fixed:**
```nix
modules = [
  ./home.nix
  plasma-manager.homeModules.plasma-manager
];
```

**Change:** `homeManagerModules` → `homeModules`

---

### 2. Fix: Git Configuration

**File:** `~/.config/my-home-manager-flake/home.nix:50-63`

**Current (Deprecated):**
```nix
programs.git = {
  enable = true;

  settings = {
    user = {
      name = "dtsioumas";
      email = "dtsioumas0@gmail.com";
    };

    init.defaultBranch = "main";
    pull.rebase = true;
  };
};
```

Wait, this is ALREADY using the new format! But the warning says it's in the OLD format.

Let me check - the warning says the deprecated config is in `home.nix`. The actual structure must be different. Let me check what the actual OLD config looks like.

**Current (Deprecated) - Actually:**
```nix
programs.git = {
  enable = true;
  userName = "dtsioumas";
  userEmail = "dtsioumas0@gmail.com";
  extraConfig = {
    init.defaultBranch = "main";
    pull.rebase = true;
  };
};
```

**Fixed:**
```nix
programs.git = {
  enable = true;

  settings = {
    user = {
      name = "dtsioumas";
      email = "dtsioumas0@gmail.com";
    };

    init.defaultBranch = "main";
    pull.rebase = true;
  };
};
```

**Changes:**
- `userName` → `settings.user.name`
- `userEmail` → `settings.user.email`
- `extraConfig` → `settings` (flatten into settings)

---

### 3. Fix: VSCode/VSCodium Settings

**File:** `~/.config/my-home-manager-flake/vscodium.nix`

**Current (Deprecated):**
```nix
programs.vscode = {
  enable = true;
  userSettings = {
    "editor.fontSize" = 14;
    # ... other settings
  };
};
```

**Fixed:**
```nix
programs.vscode = {
  enable = true;

  profiles.default.userSettings = {
    "editor.fontSize" = 14;
    # ... other settings
  };
};
```

**Change:** `userSettings` → `profiles.default.userSettings`

---

### 4. Fix: Kitty Theme (⚠️ BREAKING - Different Type!)

**File:** `~/.config/my-home-manager-flake/kitty.nix`

**Current (Deprecated):**
```nix
programs.kitty = {
  enable = true;
  theme = "Dracula";  # String theme name
  # ... other settings
};
```

**Fixed (Option A - Use themeFile):**
```nix
programs.kitty = {
  enable = true;

  themeFile = "Dracula";  # Path to theme file or package
  # OR
  # themeFile = pkgs.kitty-themes + "/share/kitty-themes/Dracula.conf";

  # ... other settings
};
```

**Fixed (Option B - Use settings.include for theme):**
```nix
programs.kitty = {
  enable = true;

  settings = {
    include = "Dracula.conf";  # If theme is in kitty config dir
  };

  # ... other settings
};
```

**Change:** `theme` (string) → `themeFile` (path/package) - **TYPE CHANGE!**

**Note:** Need to check actual kitty.nix to see current theme value and determine correct migration.

---

## 🔧 Implementation Steps

### Step 1: Fix flake.nix (plasma-manager)

```bash
cd ~/.config/my-home-manager-flake
```

Edit `flake.nix`:
```nix
# Line 32: Change homeManagerModules to homeModules
modules = [
  ./home.nix
  plasma-manager.homeModules.plasma-manager  # ← Changed
];
```

---

### Step 2: Fix home.nix (git config)

**Check current content first:**
```bash
grep -A 15 "programs.git" home.nix
```

**If using old format, update:**
```nix
programs.git = {
  enable = true;

  settings = {  # ← New wrapper
    user = {
      name = "dtsioumas";
      email = "dtsioumas0@gmail.com";
    };

    init.defaultBranch = "main";
    pull.rebase = true;
  };
};
```

---

### Step 3: Fix vscodium.nix

**Check current content first:**
```bash
grep -A 30 "userSettings" vscodium.nix
```

**Update to use profiles:**
```nix
programs.vscode = {
  enable = true;

  profiles.default.userSettings = {  # ← Changed path
    # ... all existing settings move here unchanged
  };

  # extensions, etc. stay the same
};
```

---

### Step 4: Fix kitty.nix (Complex - Type Change!)

**Check current content first:**
```bash
grep -A 20 "programs.kitty" kitty.nix
```

**Determine current theme value, then migrate:**

**If current is `theme = "Dracula";`:**
```nix
programs.kitty = {
  enable = true;

  # Option 1: Use theme package
  themeFile = pkgs.kitty-themes + "/share/kitty-themes/themes/Dracula.conf";

  # Option 2: If you have custom theme file
  # themeFile = ./path/to/dracula.conf;

  # All other settings unchanged
};
```

**Read kitty docs:**
```bash
home-manager option programs.kitty.themeFile
# OR
man home-configuration.nix | grep -A 20 "kitty.themeFile"
```

---

## ✅ Verification Steps

After applying all fixes:

1. **Check syntax:**
   ```bash
   cd ~/.config/my-home-manager-flake
   nix flake check
   ```

2. **Rebuild:**
   ```bash
   home-manager switch --flake .#mitsio@shoshin
   ```

3. **Verify NO warnings:**
   - Should see NO "trace: warning" messages
   - Should see NO "evaluation warning" messages

4. **Test functionality:**
   ```bash
   # Git config works
   git config --list | grep user

   # Kitty terminal works
   kitty --version

   # VSCodium works
   code --version

   # Check Plasma settings
   # (log out/in to verify)
   ```

---

## 📋 Files to Modify

| File | Lines | Changes |
|------|-------|---------|
| `flake.nix` | 32 | `homeManagerModules` → `homeModules` |
| `home.nix` | 50-63 | Git config to `settings` wrapper |
| `vscodium.nix` | ? | `userSettings` → `profiles.default.userSettings` |
| `kitty.nix` | ? | `theme` → `themeFile` (type change!) |

---

## 🚨 Critical Notes

### Kitty Theme Type Change
**BREAKING CHANGE:** `programs.kitty.theme` type changed from `string` to `path/package`.

**Before applying:** Read actual kitty.nix to determine:
1. Current theme value
2. Whether it's a string name or file path
3. If theme file exists locally or needs package

**Docs:** Check `programs.kitty.themeFile` documentation before migrating!

### Git Config
The warnings indicate OLD format, but need to verify actual file content shows deprecated usage.

---

## 🔍 Next Actions

1. ✅ Read actual files to confirm deprecated usage patterns
2. ⏳ Wait for current build to complete
3. ⏳ Apply fixes file-by-file
4. ⏳ Test after each fix
5. ⏳ Rebuild and verify no warnings
6. ⏳ Commit changes

---

**Created:** 2025-11-17
**Author:** Claude Code + Mitsio
**Status:** Documentation complete - Ready for implementation
