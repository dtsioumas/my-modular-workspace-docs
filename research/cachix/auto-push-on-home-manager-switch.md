# Research: Automatic Cachix Push on Home-Manager Switch

**Date:** 2025-12-28
**Researcher:** Claude (Technical Researcher Role)
**Status:** ✅ Research Complete - Pending Implementation
**Context:** Multi-profile workspace (shoshin, gyakusatsu) with hardware-optimized builds

---

## Executive Summary

Investigated methods to automatically push home-manager builds to Cachix cache after `home-manager switch` to eliminate manual `publish-builds.sh` execution. Identified **4 viable approaches** with varying trade-offs.

**Recommendation:** Hybrid approach combining home-manager activation scripts (automatic) with cachix watch-exec wrapper (precision control).

---

## Problem Statement

### Current Workflow
1. User runs `home-manager switch` (builds locally)
2. User manually runs `~/.local/bin/publish-builds.sh` (pushes to Cachix)
3. Remote systems pull from Cachix

### Desired Workflow
1. User runs `home-manager switch`
2. **Builds automatically push to Cachix** ✨
3. Remote systems pull from Cachix

### Requirements
- ✅ Zero additional commands after `home-manager switch`
- ✅ Works for all workspaces (shoshin, gyakusatsu, kinoite)
- ✅ Doesn't slow down activation significantly
- ✅ Version-controlled (declarative in home-manager)
- ✅ User-level (no root/system changes if possible)

---

## Research Methodology

### Sources Investigated
1. **Official Nix Documentation**
   - [Nix Post-Build Hook Guide](https://nix.dev/guides/recipes/post-build-hook.html)

2. **Cachix Documentation & Releases**
   - [Cachix v1.7 Release Blog](https://blog.cachix.org/posts/2024-01-12-cachix-v1-7/) - Daemon mode & watch-exec
   - [Cachix Documentation](https://docs.cachix.org/)

3. **Community Discussions**
   - [GitHub Issue #541: Push home-manager to Cachix](https://github.com/cachix/cachix/issues/541)
   - [Home-Manager Discussion #7462: Custom Activation Scripts](https://github.com/nix-community/home-manager/discussions/7462)
   - [NixOS Discourse: Home-Manager Hooks](https://discourse.nixos.org/t/does-home-manager-or-nixos-support-hooks-when-rebuilding/59290)

4. **Local Codebase Patterns**
   - Analyzed `home-manager/modules/cli/ansible-tools.nix` (activation script example)
   - Searched for existing activation patterns in 19 files

### Key Findings

1. **Home-Manager Activation DAG** exists and is already used in codebase
2. **Cachix v1.7+** introduced `watch-exec` specifically for this use case
3. **Nix post-build-hook** is system-wide and blocks build loop
4. **No official home-manager integration** for post-switch hooks (as of 2025-12-28)

---

## Approach 1: Home-Manager Activation Script ⭐ RECOMMENDED

### Overview
Use `home.activation` DAG (Directed Acyclic Graph) to execute cachix push after successful home-manager activation.

### Technical Details

**Mechanism:**
```nix
home.activation.pushToCachix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  # Run cachix push on activation package
  if command -v cachix >/dev/null 2>&1; then
    CACHE_NAME="modular-workspace"
    HOSTNAME=$(hostname)

    echo "Pushing ${HOSTNAME} home-manager generation to Cachix..."
    ${pkgs.cachix}/bin/cachix push "$CACHE_NAME" "$HOME/.local/state/nix/profiles/home-manager"
  fi
'';
```

**DAG Ordering:**
- `writeBoundary`: Files written to home directory
- `linkGeneration`: New generation linked
- **Our script**: Runs AFTER generation is active
- `onFilesChange`: File change handlers

### Pros & Cons

**Advantages:**
- ✅ **Zero global config changes** (no `/etc/nix/nix.conf` editing)
- ✅ **No daemon restart required**
- ✅ **Version controlled** (lives in home-manager git repo)
- ✅ **Per-user control** (doesn't affect other users)
- ✅ **Workspace-aware** (can detect hostname and push to correct cache)
- ✅ **Non-blocking** (activation already complete, push is fire-and-forget)
- ✅ **Pattern already exists** in codebase (`ansible-tools.nix:20-27`)
- ✅ **Conditional execution** (can skip if cachix not installed)

**Disadvantages:**
- ⚠️ **Pushes only on success** (if activation fails, nothing pushed)
- ⚠️ **Requires cachix in PATH** (need to add to `home.packages`)
- ⚠️ **May push cached paths** (pushes entire generation, not just built paths)
- ⚠️ **Asynchronous failures hidden** (push errors won't stop activation)

### Implementation Complexity
🟢 **Low** - Approximately 30-50 lines of Nix code

### Performance Impact
- **Activation time:** +0-2 seconds (cachix check)
- **Push time:** Asynchronous, doesn't block
- **Network impact:** Minimal (Cachix is smart about deduplication)

### Security Considerations
- ✅ User-level operation (no privilege escalation)
- ✅ Cachix auth token already configured (`~/.config/cachix/cachix.dhall`)
- ⚠️ Push happens in user context (uses user's cachix permissions)

---

## Approach 2: Cachix watch-exec Wrapper ⭐ MODERN ALTERNATIVE

### Overview
Wrap `home-manager switch` command with Cachix's official `watch-exec` utility that hooks into Nix's build pipeline.

### Technical Details

**Mechanism:**
```bash
cachix watch-exec modular-workspace home-manager switch
```

**How it works:**
1. `cachix watch-exec` monitors Nix store operations
2. Detects exactly which paths are built (not cached)
3. Pushes only those paths to specified cache
4. Uses Nix's post-build-hook infrastructure internally

**Cachix v1.7+ Features:**
- Daemon mode (asynchronous pushing)
- Precise path tracking (no over-pushing)
- Multi-user safe (doesn't push other users' builds)

### Pros & Cons

**Advantages:**
- ✅ **Official Cachix recommendation** (from maintainer on GitHub #541)
- ✅ **Precise pushing** (only built paths, not cached ones)
- ✅ **No configuration needed** (works out of the box)
- ✅ **Works with Cachix v1.7+ daemon** (async, non-blocking)
- ✅ **Zero permanent changes** (just change the command you run)
- ✅ **Easy testing** (try it once to see if it works)

**Disadvantages:**
- ⚠️ **Not fully automatic** (user must remember to use wrapper)
- ⚠️ **Requires alias/wrapper script** (not transparent)
- ⚠️ **Command change** (`hms` vs `home-manager switch`)
- ⚠️ **Requires Cachix v1.7+** (need to verify version)

### Implementation Complexity
🟢 **Low** - Just create alias or wrapper script

### Wrapper Script Example

**Option A: Bash alias**
```bash
# In ~/.bashrc or fish config
alias hms='cachix watch-exec modular-workspace home-manager switch'
```

**Option B: Dedicated script (chezmoi-managed)**
```bash
#!/usr/bin/env bash
# ~/.local/bin/hms
exec cachix watch-exec modular-workspace home-manager switch "$@"
```

**Option C: Smart wrapper (detects profile)**
```bash
#!/usr/bin/env bash
HOSTNAME=$(hostname)
CACHE_NAME="modular-workspace"

echo "Building home-manager for ${HOSTNAME}..."
cachix watch-exec "$CACHE_NAME" home-manager switch "$@"
```

### Performance Impact
- **Build time:** Same as normal `home-manager switch`
- **Push time:** Happens during build (concurrent)
- **Network:** Only new/changed paths pushed

---

## Approach 3: Nix Post-Build Hook (System-Wide)

### Overview
Configure system-wide `/etc/nix/nix.conf` to run a hook after EVERY Nix build operation.

### Technical Details

**Configuration (`/etc/nix/nix.conf`):**
```conf
post-build-hook = /etc/nix/post-build-hook.sh
```

**Hook Script (`/etc/nix/post-build-hook.sh`):**
```bash
#!/usr/bin/env bash
set -euo pipefail

export IFS=' '
for path in $OUT_PATHS; do
  cachix push modular-workspace "$path"
done
```

**Nix Daemon Setup:**
```bash
# After config change:
sudo systemctl restart nix-daemon
```

### Pros & Cons

**Advantages:**
- ✅ **Fully automatic** (works for ALL nix builds)
- ✅ **Zero user intervention** after setup
- ✅ **Daemon-integrated** (native Nix feature)
- ✅ **Comprehensive** (catches all builds: home-manager, nixos-rebuild, nix build)

**Disadvantages:**
- ❌ **Blocks build loop** (synchronous, waits for push to complete)
- ❌ **Network dependency** (slow/unreliable network blocks builds)
- ❌ **Requires root access** (system config)
- ❌ **Requires daemon restart** (service disruption)
- ❌ **Pushes EVERYTHING** (dev shells, garbage, test builds)
- ❌ **Not workspace-specific** (can't differentiate shoshin vs gyakusatsu)
- ❌ **Requires trusted user** (security consideration in multi-user systems)
- ❌ **Not version controlled** (lives in system config, not home-manager)

### Implementation Complexity
🟡 **Medium** - Requires system configuration + script creation + daemon management

### Performance Impact
- **Build time:** +5-60 seconds per build (network dependent)
- **Risk:** Build failures on network issues
- **Overhead:** Pushes even tiny builds (wasteful)

### Security Considerations
- ⚠️ **Requires trusted user status** (`trusted-users` in nix.conf)
- ⚠️ **System-wide impact** (affects all users)
- ⚠️ **Privilege escalation risk** (hook runs with build permissions)

### Use Case
**Only recommended for:**
- Dedicated build servers (Hydra, CI)
- Single-user development machines with reliable networks
- Systems where blocking builds is acceptable

**Not recommended for:**
- Laptops with unreliable WiFi ❌
- Multi-user systems ❌
- Development machines (too many builds) ❌

---

## Approach 4: Systemd User Service (Hybrid)

### Overview
Create a systemd path unit that watches for new home-manager generations and triggers a push service.

### Technical Details

**Path Unit (`~/.config/systemd/user/hm-cachix-push.path`):**
```ini
[Unit]
Description=Watch for new home-manager generations

[Path]
PathChanged=%h/.local/state/nix/profiles/home-manager
Unit=hm-cachix-push.service

[Install]
WantedBy=default.target
```

**Service Unit (`~/.config/systemd/user/hm-cachix-push.service`):**
```ini
[Unit]
Description=Push home-manager generation to Cachix

[Service]
Type=oneshot
ExecStart=/home/mitsio/.local/bin/push-hm-to-cachix.sh
```

**Push Script:**
```bash
#!/usr/bin/env bash
CACHE_NAME="modular-workspace"
PROFILE="$HOME/.local/state/nix/profiles/home-manager"

if [ -L "$PROFILE" ]; then
  TARGET=$(readlink -f "$PROFILE")
  cachix push "$CACHE_NAME" "$TARGET"
fi
```

### Pros & Cons

**Advantages:**
- ✅ **Asynchronous** (doesn't block home-manager switch)
- ✅ **User-level** (no root required)
- ✅ **Declarative** (can be managed via home-manager systemd module)
- ✅ **Reliable** (systemd ensures execution)

**Disadvantages:**
- ⚠️ **Complex setup** (3 files: path unit + service + script)
- ⚠️ **Delayed execution** (push happens AFTER switch completes)
- ⚠️ **Path detection challenges** (hard to know what was built vs cached)
- ⚠️ **May push too much** (entire generation, not just new paths)
- ⚠️ **Potential race conditions** (if multiple switches happen rapidly)
- ⚠️ **Debugging difficulty** (systemd logs separate from home-manager)

### Implementation Complexity
🔴 **High** - Requires systemd configuration + path filtering logic + error handling

### Performance Impact
- **Activation time:** No impact (async)
- **Push delay:** 1-5 seconds after activation
- **Resource usage:** Minimal (systemd is efficient)

### When to Use
**Good for:**
- Users who want guaranteed async pushing
- Systems with slow networks (won't block activation)
- Advanced users comfortable with systemd

**Not ideal for:**
- Simple use cases (over-engineered)
- Users unfamiliar with systemd debugging

---

## Comparative Analysis

| Criterion | Activation Script | watch-exec | Post-Build Hook | Systemd Service |
|-----------|------------------|------------|-----------------|-----------------|
| **Ease of Setup** | 🟢 Easy | 🟢 Easy | 🟡 Medium | 🔴 Complex |
| **Automation Level** | 🟢 Full | 🟡 Semi (alias) | 🟢 Full | 🟢 Full |
| **Performance Impact** | 🟢 Minimal | 🟢 None | 🔴 Blocks builds | 🟢 Async |
| **Precision** | 🟡 Generation-level | 🟢 Path-level | 🟡 All builds | 🟡 Generation-level |
| **Version Control** | 🟢 Yes (home-manager) | 🟢 Yes (dotfiles) | 🔴 No (system) | 🟢 Yes (home-manager) |
| **User-Level** | 🟢 Yes | 🟢 Yes | 🔴 No (requires root) | 🟢 Yes |
| **Network Resilience** | 🟢 Async, non-blocking | 🟢 Concurrent | 🔴 Blocks on failure | 🟢 Async |
| **Workspace-Aware** | 🟢 Yes | 🟢 Yes | 🔴 No | 🟢 Yes |
| **Debugging** | 🟢 Easy (stdout) | 🟢 Easy (cachix logs) | 🟡 Daemon logs | 🟡 systemd logs |
| **Maintenance** | 🟢 Low | 🟢 Low | 🟡 Medium | 🔴 High |

### Legend
- 🟢 Excellent / Low effort
- 🟡 Good / Medium effort
- 🔴 Poor / High effort

---

## Recommended Implementation Strategy

### Hybrid Approach: Activation Script + Optional watch-exec

**Rationale:** Combines best of both worlds
- **Primary:** Activation script (always works, zero thought)
- **Secondary:** watch-exec wrapper (precision control when needed)

### Phase 1: Activation Script (Immediate)

**File:** `home-manager/modules/dev/cachix-auto-push.nix`

```nix
{ config, lib, pkgs, ... }:

let
  cacheName = "modular-workspace";
  hostname = config.home.hostname or (builtins.readFile /etc/hostname);

  pushScript = pkgs.writeShellScript "push-hm-to-cachix" ''
    set -euo pipefail

    CACHE_NAME="${cacheName}"
    HOSTNAME="${hostname}"

    echo "[Cachix Auto-Push] Hostname: $HOSTNAME"
    echo "[Cachix Auto-Push] Cache: $CACHE_NAME"

    # Push home-manager generation
    PROFILE="$HOME/.local/state/nix/profiles/home-manager"
    if [ -L "$PROFILE" ]; then
      echo "[Cachix Auto-Push] Pushing generation to cache..."
      ${pkgs.cachix}/bin/cachix push "$CACHE_NAME" "$PROFILE" 2>&1 | \
        grep -E "compressed|already in cache|error" || true
      echo "[Cachix Auto-Push] Done."
    else
      echo "[Cachix Auto-Push] Warning: home-manager profile not found"
    fi
  '';

in
{
  # Ensure cachix is available
  home.packages = [ pkgs.cachix ];

  # Auto-push on activation
  home.activation.pushToCachix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Running Cachix auto-push..."
    ${pushScript} &
    disown
  '';

  # Optional: Create manual push command
  home.file.".local/bin/hm-push".source = pushScript;
  home.file.".local/bin/hm-push".executable = true;
}
```

**Enable in `home.nix`:**
```nix
imports = [
  # ... existing imports
  ./modules/dev/cachix-auto-push.nix
];
```

### Phase 2: watch-exec Wrapper (Optional)

**File:** `dotfiles/dot_local/bin/executable_hms.tmpl`

```bash
#!/usr/bin/env bash
# Home-Manager Switch with Cachix watch-exec
# Usage: hms [home-manager switch args]

CACHE_NAME="modular-workspace"
HOSTNAME=$(hostname)

echo "Building home-manager for ${HOSTNAME}..."
echo "Using Cachix watch-exec for precise path tracking..."

exec cachix watch-exec "$CACHE_NAME" home-manager switch "$@"
```

**Usage:**
```bash
# Automatic push (activation script):
home-manager switch

# Precise push (watch-exec):
hms  # or: hms --flake .#mitsio@shoshin
```

---

## Testing Plan

### Phase 1: Activation Script Testing

**Test 1: Basic Functionality**
```bash
# 1. Apply activation script module
home-manager switch

# 2. Check for auto-push output
# Expected: "[Cachix Auto-Push] Pushing generation to cache..."

# 3. Verify on Cachix web UI
# Visit: https://app.cachix.org/cache/modular-workspace
```

**Test 2: Multi-Profile**
```bash
# On shoshin:
home-manager switch --flake .#mitsio@shoshin
# Check: Pushes shoshin-optimized paths

# On gyakusatsu (when available):
home-manager switch --flake .#mitsio@gyakusatsu
# Check: Pushes gyakusatsu-optimized paths
```

**Test 3: Failure Handling**
```bash
# Disable network
sudo iptables -A OUTPUT -d cachix.org -j DROP

# Run switch
home-manager switch
# Expected: Activation succeeds, push fails silently (background)

# Re-enable network
sudo iptables -D OUTPUT -d cachix.org -j DROP
```

### Phase 2: watch-exec Testing

**Test 1: Install and Verify**
```bash
# Check cachix version
cachix --version
# Required: v1.7+

# Test watch-exec
hms
# Expected: Same as home-manager switch + push output
```

**Test 2: Precision Comparison**
```bash
# Build with watch-exec
hms 2>&1 | grep "Pushing"
# Note: Number of paths pushed

# Build normally (activation script)
home-manager switch 2>&1 | grep "Pushing"
# Compare: watch-exec should push fewer paths (more precise)
```

---

## Rollback Plan

If auto-push causes issues:

**Disable Activation Script:**
```nix
# In home.nix, comment out:
# ./modules/dev/cachix-auto-push.nix

home-manager switch
```

**Revert to Manual:**
```bash
# Just use publish-builds.sh as before
~/.local/bin/publish-builds.sh
```

**No system changes to undo** (all user-level)

---

## Future Enhancements

### 1. Smart Push (Only on Hardware-Specific Builds)
```nix
# Only push if profile contains hardware-optimized packages
home.activation.pushToCachix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  if grep -q "hardwareProfile" "$PROFILE/activate"; then
    # This is a hardware-optimized build, push it
    ${pushScript}
  fi
'';
```

### 2. Multi-Cache Support
```nix
# Push to different caches based on hostname
cacheName =
  if hostname == "shoshin" then "modular-workspace-skylake"
  else if hostname == "gyakusatsu" then "modular-workspace-zen3"
  else "modular-workspace";
```

### 3. Cachix Daemon Integration
```nix
# Use cachix daemon for async queue
systemd.user.services.cachix-daemon = {
  Unit.Description = "Cachix push daemon";
  Service = {
    ExecStart = "${pkgs.cachix}/bin/cachix daemon";
    Restart = "always";
  };
  Install.WantedBy = [ "default.target" ];
};
```

### 4. Push Notifications
```bash
# Notify on successful push
${pkgs.libnotify}/bin/notify-send \
  "Cachix" \
  "Pushed ${HOSTNAME} home-manager generation"
```

---

## Estimated Implementation Time

| Task | Time Estimate |
|------|--------------|
| Create `cachix-auto-push.nix` module | 30 minutes |
| Test on shoshin | 15 minutes |
| Create `hms` wrapper script | 10 minutes |
| Test watch-exec | 15 minutes |
| Documentation updates | 20 minutes |
| **Total** | **~90 minutes** |

---

## Decision Matrix

**Choose Activation Script IF:**
- ✅ You want zero-thought automation
- ✅ You're okay with pushing entire generations
- ✅ You want version-controlled config
- ✅ You value simplicity over precision

**Choose watch-exec IF:**
- ✅ You want precise path tracking
- ✅ You don't mind using a wrapper command
- ✅ You have Cachix v1.7+
- ✅ You want official Cachix-recommended approach

**Choose Post-Build Hook IF:**
- ✅ You have a dedicated build server
- ✅ Network is always reliable
- ✅ You want to cache ALL Nix builds
- ❌ NOT for development laptops

**Choose Systemd Service IF:**
- ✅ You love over-engineering 😄
- ✅ You need guaranteed async execution
- ✅ You're comfortable debugging systemd
- ❌ NOT for simple use cases

---

## Open Questions

1. **Cachix version check:** Need to verify installed cachix supports daemon/watch-exec
   ```bash
   cachix --version  # Need v1.7+
   ```

2. **Auth token expiry:** How often does `~/.config/cachix/cachix.dhall` need refreshing?

3. **Network failures:** Should activation script retry on push failure?

4. **Disk space:** Will pushing every generation fill up Cachix cache quota?
   - Current plan: 5GB free tier
   - Estimated usage: ~500MB per profile × 3 profiles = 1.5GB
   - Should implement cache GC strategy

5. **Cross-profile deduplication:** Do shoshin and gyakusatsu builds share paths in Cachix?
   - Expected: Some overlap (base packages)
   - Different: Hardware-optimized binaries (codex, ck-search)

---

## Conclusion

**Recommended approach:** Implement **Activation Script (Approach 1)** immediately, with **watch-exec wrapper (Approach 2)** as optional enhancement.

This provides:
- ✅ Automatic pushing (zero additional commands)
- ✅ Version controlled (in home-manager git repo)
- ✅ User-level (no system changes)
- ✅ Multi-workspace support (shoshin, gyakusatsu, kinoite)
- ✅ Non-blocking (async background push)
- ✅ Minimal complexity (30-50 lines of Nix)

**Next steps:**
1. Review this document
2. Approve implementation approach
3. Create `cachix-auto-push.nix` module
4. Test on shoshin
5. Deploy to all workspaces

---

## References

### Official Documentation
- [Nix Post-Build Hook Guide](https://nix.dev/guides/recipes/post-build-hook.html)
- [Cachix Documentation](https://docs.cachix.org/)
- [Home-Manager Manual](https://nix-community.github.io/home-manager/)

### Cachix Resources
- [Cachix v1.7 Release Blog](https://blog.cachix.org/posts/2024-01-12-cachix-v1-7/)
- [Cachix GitHub](https://github.com/cachix/cachix)

### Community Discussions
- [GitHub Issue #541: Push home-manager to Cachix](https://github.com/cachix/cachix/issues/541)
- [Home-Manager Discussion #7462: Custom Activation Scripts](https://github.com/nix-community/home-manager/discussions/7462)
- [NixOS Discourse: Home-Manager Hooks](https://discourse.nixos.org/t/does-home-manager-or-nixos-support-hooks-when-rebuilding/59290)
- [NixOS Discourse: Activation Script After Programs Setup](https://discourse.nixos.org/t/home-manager-run-activation-script-after-programs-are-set-up-e-g-git/49855)

### Related Tools
- [cachix/git-hooks.nix](https://github.com/cachix/git-hooks.nix) - Pre-commit hooks (inspiration for post-activation)
- [nix-community/home-manager](https://github.com/nix-community/home-manager)

---

**Research completed:** 2025-12-28T03:15:28+02:00
**Document author:** Claude (Technical Researcher)
**Review status:** ⏳ Pending user review
**Implementation status:** 📋 Planned (not yet implemented)
