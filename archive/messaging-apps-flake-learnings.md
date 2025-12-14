# Messaging Apps Flake - Learnings and Insights

**Date:** 2025-11-05  
**Project:** Always-Updated Signal & Session Desktop  
**Challenge:** Avoid "expired version" errors in Signal Desktop

---

## 🎯 Problem Analysis

### Why Signal Desktop Fails in nixpkgs

Signal Desktop has unique challenges in nixpkgs:

1. **Forced Updates**: Signal enforces version checks and blocks outdated clients
2. **Frequent Releases**: New versions released weekly/bi-weekly for security
3. **nixpkgs Lag**: Maintainers need time to test and merge updates
4. **Cache Invalidation**: Building from source is slow and resource-intensive
5. **Hydra Build Times**: Binary cache availability delayed

**Real Issues Found:**
- Issue #374114: In-app update breaks system package
- Issue #419832: Build failures in stable
- Issue #347465: "Version expired" errors
- Issue #48436: Historic expiration problems

### Solution Decision Tree

```
Is package in nixpkgs?
├─ YES → Is it frequently updated (weekly)?
│  ├─ YES → Does nixpkgs lag cause problems?
│  │  ├─ YES → **Build custom flake** ✅
│  │  └─ NO → Use nixpkgs
│  └─ NO → Use nixpkgs
└─ NO → Build custom flake
```

**Signal Desktop**: YES → YES → YES → **Custom Flake**  
**Session Desktop**: YES → NO → N/A → **Custom Flake** (consistency)  
**Kitty**: YES → NO → N/A → **Home Manager** (native support)

---

## 🏗️ Architecture Decisions

### 1. Override vs. Full Derivation

**Signal Desktop Approach:**
```nix
pkgs.signal-desktop.overrideAttrs (oldAttrs: rec {
  version = signalVersion;
  src = pkgs.fetchurl { ... };
})
```

**Why override?**
- Reuses existing nixpkgs derivation structure
- Inherits build logic, dependencies, patches
- Only changes version and source
- Faster to update
- Less maintenance burden

**When to use full derivation?**
- Package doesn't exist in nixpkgs
- Major build changes needed
- Different dependencies required

**Session Desktop Approach:**
```nix
pkgs.stdenv.mkDerivation rec {
  pname = "session-desktop";
  # Full derivation from scratch
}
```

**Why full derivation?**
- Package uses AppImage (different from Signal's deb)
- Requires autoPatchelfHook
- Different dependency tree
- More control over installation

### 2. Package Format Handling

**DEB Packages (Signal):**
```nix
src = pkgs.fetchurl {
  url = "https://.../signal-desktop_${version}_amd64.deb";
  sha256 = "...";
};
```

- Uses existing `signal-desktop` base
- nixpkgs already handles deb extraction
- Override just changes source

**AppImage Packages (Session):**
```nix
nativeBuildInputs = [
  autoPatchelfHook  # Critical for AppImages
  dpkg
  wrapGAppsHook
];
```

- Requires `autoPatchelfHook` to fix dynamic libraries
- Need to manually copy files to $out
- Must handle library paths with `makeWrapper`

### 3. Hash Management

**The SHA256 Problem:**
Every version update requires new hash. Two approaches:

**Approach A: Pre-fetch (Recommended)**
```bash
nix-prefetch-url <URL>
# Returns: sha256-ABC...
# Update flake.nix immediately
```

**Approach B: Let Nix fail**
```bash
nix build .#signal-desktop
# Error shows correct hash
# Update flake.nix with provided hash
```

**Our Solution: update-versions.sh**
```bash
#!/usr/bin/env bash
# Automates version and hash fetching
SIGNAL_VERSION=$(curl -s https://api.github.com/repos/.../releases/latest | jq -r '.tag_name')
SIGNAL_HASH=$(nix-prefetch-url "$SIGNAL_URL")
```

---

## 📚 Key Learnings

### 1. When to Build Custom Flakes

**Build Custom Flake When:**
- ✅ Package has forced update requirements (Signal)
- ✅ nixpkgs version consistently outdated
- ✅ Upstream releases frequently (weekly/bi-weekly)
- ✅ "Expired version" errors common
- ✅ Need specific version control
- ✅ Contributing back to nixpkgs impractical (speed needed)

**Use nixpkgs When:**
- ✅ Package stable and slow-changing
- ✅ No forced update requirements
- ✅ nixpkgs version acceptable
- ✅ Community maintenance available

**Use Home Manager When:**
- ✅ Native `programs.<name>` support exists (Kitty, Git, Neovim)
- ✅ Declarative configuration desired
- ✅ Per-user config needed

### 2. Flake Structure Best Practices

**Multi-Package Flake Pattern:**
```nix
{
  outputs = { self, nixpkgs }: {
    packages.${system} = {
      signal-desktop = ...;
      session-desktop = ...;
      default = self.packages.${system}.signal-desktop;
    };
  };
}
```

**Benefits:**
- Related packages grouped logically
- Shared dependencies
- Single flake.lock for consistency
- Easy to maintain

### 3. Update Workflow Optimization

**Manual Updates Are Inevitable:**
For fast-moving packages like Signal, accept that:
- Full automation is complex and fragile
- Manual updates every 2-4 weeks acceptable
- Semi-automated scripts (like update-versions.sh) sufficient
- Version pinning in flake.lock ensures reproducibility

**Update Frequency Recommendation:**
- Signal Desktop: Weekly check, update as needed
- Session Desktop: Monthly check
- Other stable apps: When issues arise

### 4. Integration with NixOS

**Pattern for Flake Inputs:**
```nix
# In system flake.nix
inputs = {
  messaging-apps.url = "path:/home/mitso/flakes/messaging-apps";
};

outputs = { messaging-apps, ... }: {
  nixosConfigurations.shoshin = {
    specialArgs = { inherit messaging-apps; };
    modules = [
      ({ messaging-apps, ... }: {
        environment.systemPackages = [
          messaging-apps.packages.x86_64-linux.signal-desktop
        ];
      })
    ];
  };
};
```

**Why `specialArgs`?**
- Passes flake inputs to NixOS modules
- Cleaner than overlays for this use case
- Explicit dependency tracking

### 5. Documentation is Critical

**Lessons Learned:**
- README.md must explain **why** custom flake needed
- Update workflow must be documented clearly
- Troubleshooting section prevents frustration
- Version check script reduces friction

**Documentation Checklist:**
- [ ] Problem statement (why custom flake?)
- [ ] Quick start guide
- [ ] Update workflow with commands
- [ ] Troubleshooting common issues
- [ ] Links to upstream releases
- [ ] Maintenance instructions

---

## 🔧 Technical Deep Dive

### autoPatchelfHook Explained

For AppImages and binaries:

```nix
nativeBuildInputs = [ autoPatchelfHook ];
buildInputs = [ libX11 libXrandr ... ];
```

**What it does:**
1. Scans binaries for dynamic library dependencies
2. Finds matching libraries in buildInputs
3. Patches binary to use Nix store paths
4. Prevents "library not found" errors

**When needed:**
- AppImages
- Pre-compiled binaries
- Non-Nix-built software

### Library Path Management

**Problem:** Binary expects system libraries  
**Solution:** Wrapper with LD_LIBRARY_PATH

```nix
makeWrapper $out/share/session-desktop/session-desktop $out/bin/session-desktop \
  --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
```

This ensures the binary finds all required `.so` files.

### Meta Attributes Matter

```nix
meta = with pkgs.lib; {
  description = "Clear, concise description";
  longDescription = ''
    Why this package exists
    How to update
    Special considerations
  '';
  homepage = "https://...";
  license = licenses.gpl3Plus;
  platforms = platforms.linux;
  maintainers = [ ];  # Your info here
};
```

**Why important:**
- Shows up in `nix search`
- Documents package purpose
- Helps future maintainers
- License compliance

---

## 🎓 Context7 + NixOS Flakes Book Insights

### From NixOS & Flakes Book (Trust Score: 10)

**Key Patterns Learned:**

1. **Localized Package Overrides:**
```nix
pkgs-gcc12 = import nixpkgs {
  overlays = [ (self: super: { gcc = self.gcc12; }) ];
};
```
Use separate pkgs instances to avoid cache invalidation.

2. **callPackage Pattern:**
```nix
packages.${system}.default = pkgs.callPackage ./package.nix { };
```
Automatically injects dependencies from scope.

3. **Cross-Compilation Awareness:**
```nix
crossSystem = { config = "riscv64-unknown-linux-gnu"; };
```
Even if not cross-compiling now, structure flakes to support it.

4. **devShells for Development:**
```nix
devShells.${system}.default = pkgs.mkShell {
  buildInputs = [ nix dpkg curl jq ];
  shellHook = ''
    echo "Available commands: ..."
  '';
};
```
Provide context and tools for development/testing.

---

## 🚀 Future Improvements

### Potential Enhancements:

1. **GitHub Actions CI:**
   - Auto-check for new releases
   - Run test builds
   - Create PR with version bumps

2. **Nix Flake Updater:**
   - Use `nix flake update` automation
   - Pin to known-good versions
   - Rollback capability

3. **Binary Cache:**
   - Self-hosted cache for faster deployments
   - Pre-build common versions
   - Share across machines

4. **Notification System:**
   - Alert when new version available
   - Email/webhook on release
   - Integration with Home Assistant?

---

## 📊 Comparison: Approaches

| Approach | Update Speed | Maintenance | Reliability | Complexity |
|----------|-------------|-------------|-------------|------------|
| nixpkgs stable | Slow | None | High | Low |
| nixpkgs unstable | Medium | None | Medium | Low |
| Custom flake (manual) | Fast | Medium | High | Medium |
| Custom flake (automated) | Fast | Low | High | High |
| Overlay | Fast | High | Medium | High |

**Recommendation:** Custom flake with semi-automated updates (our approach).

---

## 🎯 Key Takeaways

1. **Not Everything Belongs in nixpkgs:**
   - Fast-moving packages benefit from custom flakes
   - nixpkgs is for stable, community-maintained packages

2. **Override > Full Derivation:**
   - Reuse nixpkgs work when possible
   - Only write from scratch when necessary

3. **Documentation = Success:**
   - Future you will thank present you
   - Others can contribute/help

4. **Semi-Automation is OK:**
   - Perfect automation not always worth the effort
   - Scripts + documentation > full automation

5. **Home Manager for Config:**
   - Use native modules when available
   - Declarative > imperative

6. **Version Pinning with flake.lock:**
   - Reproducibility is king
   - Commit flake.lock always

---

**Next Steps:**
- Monitor Signal/Session releases
- Update every 2-4 weeks
- Consider automating checks
- Share approach with community

**Estimated Maintenance:** 30 minutes every 2-4 weeks

**Value:** Never miss messages due to "expired version" errors! 🎉
