# Quick Start: Implementing Hardware Profile Sharing (Pattern 2)

**Time Required:** 15-20 minutes
**Difficulty:** Beginner to Intermediate
**Files Modified:** 2 flake.nix files
**Breaking Changes:** None

---

## What You're Doing

Making `home-manager/modules/profiles/config/hardware/shoshin.nix` available to the NixOS flake in `hosts/shoshin/nixos/flake.nix` using pure Nix flake inputs.

---

## Step 1: Export Hardware Profiles (5 min)

**File to Edit:** `home-manager/flake.nix`

Find the `outputs =` line and look at the `let` section. After `hardwareProfiles = {` is defined (around line 165):

**Current (lines 165-170):**
```nix
# Define all available hardware profiles
hardwareProfiles = {
  shoshin = import ./modules/profiles/config/hardware/shoshin.nix;
  kinoite = import ./modules/profiles/config/hardware/kinoite.nix;
  gyakusatsu = import ./modules/profiles/config/hardware/gyakusatsu.nix;
};
```

**Verify it already exists** (it does, checked via Read). No changes needed here.

Now check the `in { ... }` section where outputs are defined (around line 376). You should see:

```nix
in
{
  checks.${system} = { ... };
  devShells.${system}.default = { ... };
  homeConfigurations = { ... };
  packages.${system} = { ... };
}
```

**Add this export** before the closing `}`:
```nix
# Expose hardware profiles for other flakes to consume
inherit hardwareProfiles;
```

**Result (around line 442, before closing brace):**
```nix
      # Expose key packages for manual builds/caching
      packages.${system} = {
        codexBinary = codex.packages.${system}.default;
      };

      # Export hardware profiles for use by NixOS flake
      inherit hardwareProfiles;
    };
}
```

---

## Step 2: Add Home-Manager Input to NixOS Flake (5 min)

**File to Edit:** `hosts/shoshin/nixos/flake.nix`

**Current lines 4-13:**
```nix
  inputs = {
    # NixOS stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Pre-commit hooks (code quality automation)
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
```

**Add home-manager input after git-hooks:**
```nix
  inputs = {
    # NixOS stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Pre-commit hooks (code quality automation)
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home-manager flake (for shared hardware profiles)
    home-manager-config = {
      url = "path:../../home-manager";
      flake = true;
    };
  };
```

---

## Step 3: Update Outputs Function Signature (3 min)

**File:** `hosts/shoshin/nixos/flake.nix`, lines 20-27

**Current:**
```nix
  outputs = {
    self,
    nixpkgs,
    git-hooks,
    ...
  }: let
```

**Update to:**
```nix
  outputs = {
    self,
    nixpkgs,
    git-hooks,
    home-manager-config,
    ...
  }: let
```

---

## Step 4: Add specialArgs to nixosSystem (5 min)

**File:** `hosts/shoshin/nixos/flake.nix`, lines 61-67

**Current:**
```nix
    # Desktop configuration
    nixosConfigurations.shoshin = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        # Host-specific config
        ./hosts/shoshin/configuration.nix
      ];
    };
```

**Update to:**
```nix
    # Desktop configuration
    nixosConfigurations.shoshin = nixpkgs.lib.nixosSystem {
      inherit system;

      # Pass hardware profile via specialArgs
      specialArgs = {
        hardwareProfile = home-manager-config.hardwareProfiles.shoshin;
      };

      modules = [
        # Host-specific config
        ./hosts/shoshin/configuration.nix
      ];
    };
```

---

## Step 5: Test Flake Evaluation (2 min)

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos
nix flake show
```

**Expected Output:**
```
nix flake show
git+file:///home/mitsio/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos?dir=.
├── checks
│   └── x86_64-linux
│       └── pre-commit-check: derivation 'pre-commit-check'
├── devShells
│   └── x86_64-linux
│       └── default: development environment 'nix-devenv'
└── nixosConfigurations
    └── shoshin: NixOS 25.05.20251222.a6c3a61
```

**If you see this, success!** If you get errors about `hardwareProfile` being undefined, recheck steps 1-4.

---

## Step 6: Use Hardware Profile in Configuration (Optional - 5-10 min)

**File:** `hosts/shoshin/nixos/hosts/shoshin/configuration.nix`

You can now access `hardwareProfile` in your configuration. Example:

```nix
{ config, lib, pkgs, hardwareProfile, ... }:

{
  # Use hardware spec for memory management
  nix.settings.max-jobs = hardwareProfile.build.parallelism.maxJobs;

  # Or in a module that needs it
  imports = [
    ({ ... }: {
      my.hardwareName = hardwareProfile.system.hostname;
      my.cpuModel = hardwareProfile.cpu.model;
    })
  ];
}
```

---

## Verification Checklist

- [ ] `home-manager/flake.nix` exports `hardwareProfiles`
- [ ] `hosts/shoshin/nixos/flake.nix` has `home-manager-config` input
- [ ] `outputs` function signature includes `home-manager-config`
- [ ] `nixosSystem` call includes `specialArgs`
- [ ] `nix flake show` works without errors
- [ ] Flake evaluates in offline mode: `nix flake show --offline`

---

## Rollback (If Needed)

If something breaks:

1. Undo steps in reverse order
2. `cd hosts/shoshin/nixos && nix flake lock --recreate-lock-file`
3. Git reset if tracking: `git checkout flake.nix`

---

## Next Steps

Once working, you can:

1. **Use hardware profile in NixOS config** (Step 6 above)
2. **Update home-manager** to also receive hardware profile via `specialArgs` (optional)
3. **Add more hardware profiles** (kinoite, gyakusatsu) - no flake changes needed
4. **Plan migration to Pattern 3** (separate hardware-profiles flake) when managing 5+ machines

---

## Troubleshooting

### Error: `attribute 'hardwareProfiles' missing`
**Cause:** Step 1 incomplete. Verify `inherit hardwareProfiles;` is in outputs.

**Fix:**
```bash
cd home-manager
nix flake show | grep hardwareProfiles
```

### Error: `home-manager-config` not found in inputs
**Cause:** Step 2 not complete.

**Fix:** Verify `inputs.home-manager-config` exists and contains exact text from Step 2.

### Error: `specialArgs not recognized`
**Cause:** Using old NixOS version.

**Fix:** Ensure `nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"` (25.05 or newer required)

### Lock file issues
**Fix:**
```bash
cd hosts/shoshin/nixos
nix flake update home-manager-config
```

---

**Need detailed explanation?** See `docs/researches/2025-12-30_Hardware_Profile_Sharing_Patterns.md`
