# Cachix Binary Cache Setup Guide

**Date:** 2025-12-28
**Cache:** `modular-workspace`
**Visibility:** Public
**Workspaces:** shoshin (NixOS desktop), gyakusatsu (WSL)

---

## 📋 Overview

This guide sets up Cachix binary caching for your hardware-optimized language runtimes (Node.js, Go, Rust, Python). This allows you to:

1. **Build once on shoshin** (powerful desktop with 6 threads)
2. **Share to gyakusatsu** (WSL) instantly via cache
3. **Avoid rebuilding** 2-3.5 hours of language runtimes on WSL
4. **Enable deterministic builds** (all runtimes use `SOURCE_DATE_EPOCH=1`)

### Benefits

| Without Cachix | With Cachix |
|----------------|-------------|
| Build on shoshin: 2-3.5 hours | Build on shoshin: 2-3.5 hours (once) |
| Build on gyakusatsu: 2-3.5 hours | Pull from cache: **2-5 minutes** |
| Total time: **5-7 hours** | Total time: **2.5-4 hours** |

**Disk space saved:** ~2.2GB build artifacts don't need to be stored twice.

---

## 🔧 Prerequisites

- ✅ Cachix account (you have this)
- ✅ Cachix cache `modular-workspace` (you have this)
- ✅ Cache is public (pulling requires no auth)
- ✅ Auth token for pushing (you'll need to obtain this)

---

## 📦 Part 1: Configure Cache Consumption (Read from Cache)

This allows shoshin and gyakusatsu to **pull** from your cache.

### Step 1.1: Add Cache to `flake.nix`

**File:** `~/.MyHome/MySpaces/my-modular-workspace/home-manager/flake.nix`

Add your cache to the `nixConfig` section at the top:

```nix
{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://modular-workspace.cachix.org"  # ADD THIS LINE
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "modular-workspace.cachix.org-1:5uxHp/7750vCC6SPQ1I+mIt4Y/9NdwWI3VSyO25XJfY="  # ADD THIS LINE
    ];
    # ... rest of config
  };
}
```

### Step 1.2: Rebuild to Apply Changes

On **both shoshin and gyakusatsu:**

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#<hostname>
```

Replace `<hostname>` with:
- `shoshin` on your desktop
- `gyakusatsu` on WSL

### Step 1.3: Verify Cache is Configured

```bash
# Check substituters
nix show-config | grep substituters

# Should show:
# substituters = https://cache.nixos.org https://nix-community.cachix.org https://modular-workspace.cachix.org

# Check trusted public keys
nix show-config | grep trusted-public-keys

# Should include: modular-workspace.cachix.org-1:5uxHp/7750vCC6SPQ1I+mIt4Y/9NdwWI3VSyO25XJfY=
```

✅ **Cache consumption is now configured!** You can pull from the cache, but not push yet.

---

## 🚀 Part 2: Configure Cache Publishing (Push to Cache)

This allows shoshin to **push** built runtimes to the cache.

### Step 2.1: Install Cachix CLI

On **shoshin only** (the machine that will build and push):

```bash
# Check if already installed
which cachix

# If not installed, add to home.nix packages
# File: ~/.MyHome/MySpaces/my-modular-workspace/home-manager/home.nix
```

Add to your `home.packages`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  cachix  # ADD THIS
];
```

Then rebuild:

```bash
home-manager switch --flake .#shoshin
```

### Step 2.2: Authenticate Cachix

On **shoshin:**

```bash
# Login to Cachix
cachix authtoken

# This will prompt you to visit: https://app.cachix.org/personal-auth-tokens
# Copy your auth token and paste it when prompted
```

**Getting your auth token:**
1. Go to: https://app.cachix.org/personal-auth-tokens
2. Click "Create token"
3. Give it a name (e.g., "shoshin-desktop")
4. Copy the token
5. Paste it into the terminal

### Step 2.3: Verify Authentication

```bash
# Test authentication
cachix use modular-workspace

# Should output:
# Configured https://modular-workspace.cachix.org binary cache in /home/mitsio/.config/nix/nix.conf
```

✅ **You can now push to the cache!**

---

## 📤 Part 3: Build and Push Language Runtimes

Now build all 4 optimized runtimes on shoshin and push them to the cache.

### Step 3.1: Trigger the Build

On **shoshin:**

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# IMPORTANT: Run in tmux/screen (build takes 2-3.5 hours)
tmux new-session -s runtime-build

# Start the build with all 4 optimized runtimes
home-manager switch --flake .#shoshin
```

**What will be built:**
- Node.js 24 (30-60 min with PGO)
- Go 1.24 (20-40 min with PGO)
- Rust (30-60 min)
- Python 3.13 (60-90 min with PGO FULL)

**Total time:** ~2-3.5 hours (parallel builds)

### Step 3.2: Monitor the Build

In another terminal:

```bash
# Watch build progress
watch -n 5 'ps aux | grep -E "rustc|python|node|go" | grep -v grep'

# Check memory usage
watch -n 5 'free -h'
```

### Step 3.3: Push Built Runtimes to Cache

After the build completes successfully:

```bash
# Push all language runtime store paths to cache
nix build .#homeConfigurations.shoshin.activationPackage --json \
  | jq -r '.[].outputs.out' \
  | cachix push modular-workspace

# Or push specific runtimes manually:
nix-store -qR $(which node) | cachix push modular-workspace
nix-store -qR $(which go) | cachix push modular-workspace
nix-store -qR $(which rustc) | cachix push modular-workspace
nix-store -qR $(which python3) | cachix push modular-workspace
```

**Expected push time:** 5-15 minutes (uploading ~2.2GB)

### Step 3.4: Verify Push Success

```bash
# Check cache contents
cachix watch-store modular-workspace

# Or check via web UI
# Visit: https://app.cachix.org/cache/modular-workspace
```

✅ **Runtimes are now in the cache!**

---

## 📥 Part 4: Pull from Cache on Other Machines

Now use the cache on gyakusatsu (WSL) to avoid rebuilding.

### Step 4.1: Ensure gyakusatsu is Configured

On **gyakusatsu:**

```bash
# Verify cache is available
nix show-config | grep modular-workspace

# Should show: https://modular-workspace.cachix.org in substituters
```

If not configured, repeat **Part 1** on gyakusatsu.

### Step 4.2: Rebuild Using Cache

On **gyakusatsu:**

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager

# This should pull from cache instead of building!
home-manager switch --flake .#gyakusatsu
```

**Expected behavior:**
```
copying path '/nix/store/...-nodejs-x86-64-v3-optimized-24.12.0' from 'https://modular-workspace.cachix.org'...
copying path '/nix/store/...-go-x86-64-v3-optimized-1.24.0' from 'https://modular-workspace.cachix.org'...
copying path '/nix/store/...-rustc-x86-64-v3-optimized-1.84.0' from 'https://modular-workspace.cachix.org'...
copying path '/nix/store/...-python313-x86-64-v3-optimized-3.13.1' from 'https://modular-workspace.cachix.org'...
```

**Time:** 2-5 minutes (download ~2.2GB) instead of 2-3.5 hours!

### Step 4.3: Verify Runtimes

On **gyakusatsu:**

```bash
# Verify all runtimes are optimized versions from cache
node --version
which node  # Should show /nix/store/...-nodejs-x86-64-v3-optimized-.../bin/node

go version
go env GOAMD64  # Should show: v3

rustc --version
which rustc  # Should show /nix/store/...-rustc-x86-64-v3-optimized-.../bin/rustc

python3 --version
which python3  # Should show /nix/store/...-python313-x86-64-v3-optimized-.../bin/python3
```

✅ **Cache is working! All runtimes pulled successfully!**

---

## 🤖 Part 5: Automation (Optional but Recommended)

Automate pushing to cache after every successful build on shoshin.

### Option A: Post-Build Hook (Recommended)

Create a post-build hook that automatically pushes to cache:

**File:** `~/.config/nix/post-build-hook.sh`

```bash
#!/bin/sh
set -eu
set -f # disable globbing
export IFS=' '

echo "=== Cachix Post-Build Hook ==="
echo "Pushing paths to modular-workspace cache:"
for path in $OUT_PATHS; do
  echo "  - $path"
done

# Push to cache
echo "$OUT_PATHS" | cachix push modular-workspace

echo "✓ Push completed!"
```

Make it executable:

```bash
chmod +x ~/.config/nix/post-build-hook.sh
```

**Configure Nix to use the hook:**

Edit `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf` on NixOS):

```
post-build-hook = /home/mitsio/.config/nix/post-build-hook.sh
```

Restart Nix daemon (NixOS):

```bash
sudo systemctl restart nix-daemon
```

### Option B: Manual Push After Build

If you prefer manual control, just run after each successful rebuild:

```bash
# After: home-manager switch --flake .#shoshin
nix-store -qR ~/.nix-profile | cachix push modular-workspace
```

---

## 🔍 Troubleshooting

### Problem: Cache Not Being Used

**Symptom:** Nix still builds from source instead of using cache.

**Solution:**

```bash
# 1. Check cache is configured
nix show-config | grep modular-workspace

# 2. Check cache is reachable
curl -I https://modular-workspace.cachix.org/nix-cache-info

# Should return: HTTP/2 200

# 3. Force use of cache
nix build --option substituters "https://modular-workspace.cachix.org" \
  --option trusted-public-keys "modular-workspace.cachix.org-1:5uxHp/7750vCC6SPQ1I+mIt4Y/9NdwWI3VSyO25XJfY=" \
  .#homeConfigurations.gyakusatsu.activationPackage
```

### Problem: "Untrusted Public Key" Error

**Symptom:** `error: cannot add path ... because it lacks a signature by a trusted key`

**Solution:**

```bash
# On NixOS, add to /etc/nixos/configuration.nix:
nix.settings.trusted-public-keys = [
  "modular-workspace.cachix.org-1:5uxHp/7750vCC6SPQ1I+mIt4Y/9NdwWI3VSyO25XJfY="
];

# Then rebuild
sudo nixos-rebuild switch
```

### Problem: Push Fails (Auth Error)

**Symptom:** `cachix push` fails with authentication error

**Solution:**

```bash
# Re-authenticate
cachix authtoken

# Verify token is valid
cat ~/.config/cachix/cachix.dhall

# Should contain your auth token
```

### Problem: Build Doesn't Use All Cores

**Symptom:** Build is slower than expected

**Solution:**

Check your hardware profile `maxCores` setting:

```bash
# File: profiles/hardware/shoshin.nix
parallelism.maxCores = 6;  # Should match your CPU threads

# Rebuild after changing
home-manager switch --flake .#shoshin
```

---

## 📊 Cache Usage Monitoring

### Check Cache Size

```bash
# Via CLI
cachix watch-store modular-workspace

# Via Web UI
# Visit: https://app.cachix.org/cache/modular-workspace
```

### Check What's in Cache

```bash
# List all paths in cache (if small cache)
cachix use modular-workspace
curl https://modular-workspace.cachix.org/nix-cache-info

# Check specific runtime
nix path-info --store https://modular-workspace.cachix.org \
  /nix/store/...-nodejs-x86-64-v3-optimized-24.12.0
```

---

## 🎯 Expected Workflow After Setup

### On shoshin (Build Machine)

1. Update flake inputs: `nix flake update`
2. Rebuild: `home-manager switch --flake .#shoshin`
3. **Automatic**: Post-build hook pushes to cache
4. **Or Manual**: `nix-store -qR ~/.nix-profile | cachix push modular-workspace`

### On gyakusatsu (Consumer Machine)

1. Update flake inputs: `nix flake update` (same lockfile as shoshin via Git)
2. Rebuild: `home-manager switch --flake .#gyakusatsu`
3. **Automatic**: Pulls from cache (2-5 min instead of 2-3.5 hours!)

---

## ✅ Verification Checklist

After completing this guide, verify:

**On shoshin:**
- [ ] Cache configured: `nix show-config | grep modular-workspace`
- [ ] Cachix CLI installed: `which cachix`
- [ ] Authenticated: `cachix use modular-workspace` works
- [ ] Runtimes built: `which node go rustc python3` show optimized paths
- [ ] Pushed to cache: Check https://app.cachix.org/cache/modular-workspace

**On gyakusatsu:**
- [ ] Cache configured: `nix show-config | grep modular-workspace`
- [ ] Can reach cache: `curl -I https://modular-workspace.cachix.org/nix-cache-info`
- [ ] Rebuild pulls from cache (see "copying path from..." messages)
- [ ] Runtimes work: `node --version`, `go version`, `rustc --version`, `python3 --version`

---

## 📚 Related Documentation

- **Cachix Official Docs:** https://docs.cachix.org/
- **Nix Binary Cache:** https://nixos.org/manual/nix/stable/package-management/binary-cache-substituter
- **ADR-024:** Language Runtime Hardware Optimizations
- **LANGUAGE_RUNTIMES_OPTIMIZATION_GUIDE.md:** Integration guide for overlays

---

## 🎉 Success!

You now have a fully functional binary cache setup that:

✅ Builds once on powerful hardware (shoshin)
✅ Shares instantly to other machines (gyakusatsu)
✅ Saves **5+ hours** of rebuild time
✅ Saves **~2.2GB** of duplicate build artifacts
✅ Works seamlessly with hardware-optimized runtimes

**Next Steps:**
1. Follow Part 1-3 on shoshin (configure + build + push)
2. Follow Part 1 + Part 4 on gyakusatsu (configure + pull)
3. Optional: Set up automation (Part 5)

---

**Created:** 2025-12-28
**Status:** Ready for Implementation
**Confidence:** 0.95 (High)
