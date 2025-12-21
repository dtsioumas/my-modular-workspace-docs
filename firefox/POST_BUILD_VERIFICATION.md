# Firefox Post-Build Verification Checklist

**Run after**: `home-manager switch` completes successfully

---

## Phase 1.5: Initial Verification

### Step 1: Firefox Starts Successfully
```bash
# Close any running Firefox
pkill firefox
sleep 2

# Start Firefox
firefox &
```
**Expected**: Firefox opens without errors

---

### Step 2: Check New Profile Created
```bash
# List Firefox profiles
ls -la ~/.mozilla/firefox/
```
**Expected**: New `default` profile directory exists

---

### Step 3: Verify Critical Settings

Navigate to `about:config` in Firefox:

| Setting | Expected Value | Status |
|---------|---------------|--------|
| `extensions.autoDisableScopes` | `0` (zero) | ☐ |
| `toolkit.legacyUserProfileCustomizations.stylesheets` | `true` | ☐ |
| `layers.acceleration.force-enabled` | `true` | ☐ |
| `gfx.webrender.all` | `true` | ☐ |
| `media.ffmpeg.vaapi.enabled` | `true` | ☐ |
| `dom.ipc.processCount` | `4` | ☐ |
| `browser.cache.memory.capacity` | `524288` | ☐ |

---

### Step 4: Verify Extensions Installed

Navigate to `about:addons`:

| Extension | Status | Auto-Enabled |
|-----------|--------|--------------|
| uBlock Origin | ☐ Installed | ☐ Enabled |
| Sidebery | ☐ Installed | ☐ Enabled |
| KeePassXC-Browser | ☐ Installed | ☐ Enabled |
| Bitwarden | ☐ Installed | ☐ Enabled |
| Plasma Integration | ☐ Installed | ☐ Enabled |
| Floccus | ☐ Installed | ☐ Enabled |
| Default Bookmark Folder | ☐ Installed | ☐ Enabled |
| Multi-Account Containers | ☐ Installed | ☐ Enabled |
| FireShot | ☐ Installed | ☐ Enabled |

**Total Expected**: 9 extensions

---

### Step 5: Verify Native Tab Bar Hidden

**Check**:
- Native horizontal tab bar at top: ☐ **HIDDEN**
- Only address bar and toolbar visible: ☐ **YES**

**If still visible**:
```bash
# Check userChrome.css exists
ls ~/.mozilla/firefox/*/chrome/userChrome.css

# Clear cache
rm -rf ~/.mozilla/firefox/*/startupCache/
```

---

### Step 6: Verify GPU Acceleration

Navigate to `about:support` → **Graphics** section:

| Item | Expected | Actual | Status |
|------|----------|--------|--------|
| Compositing | WebRender or OpenGL | | ☐ |
| GPU #1 Active | Yes | | ☐ |
| GPU #1 Description | NVIDIA [model] | | ☐ |
| WebGL 1 Driver | NVIDIA | | ☐ |
| Hardware Video Decoding | Available | | ☐ |

**GPU Usage Test**:
```bash
# In another terminal, monitor GPU
watch -n1 nvidia-smi

# In Firefox, play a 4K video:
# https://www.youtube.com/watch?v=LXb3EKWsInQ
```
**Expected**: GPU Video Engine usage > 0%

---

### Step 7: Verify Search Engine

Type in address bar: `test search query`

**Expected**:
- ☐ Search uses Google (check URL bar shows google.com)
- ☐ NOT using Brave search

---

### Step 8: Verify Session Variables

```bash
env | grep -E 'LIBVA|GBM|GLX|MOZ'
```

**Expected output**:
```
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
MOZ_USE_XINPUT2=1
MOZ_WEBRENDER=1
```

**Critical**: NO `MOZ_ENABLE_WAYLAND` variable (we're on X11!)

---

## Phase 2.0: System Package Verification

**BEFORE Phase 2 extension work**, verify system package:

```bash
# Check if plasma-browser-integration is installed
which plasma-browser-integration
```

**If NOT found**, add to NixOS config:
```nix
# Edit: hosts/shoshin/nixos/modules/workspace/kde.nix
environment.systemPackages = with pkgs; [
  plasma-browser-integration
];

# Then rebuild
sudo nixos-rebuild switch
```

---

## Phase 3: GPU Acceleration Full Test

### Test 1: WebGL
Navigate to: `https://get.webgl.org/`
- ☐ WebGL 1: ENABLED
- ☐ WebGL 2: ENABLED

### Test 2: Video Playback
Play 4K 60fps video: `https://www.youtube.com/watch?v=LXb3EKWsInQ`
```bash
# Monitor in another terminal
nvidia-smi dmon -s u
```
- ☐ GPU decode usage visible
- ☐ Smooth playback, no dropped frames

### Test 3: Canvas Acceleration
Navigate to: `https://kevs3d.co.uk/dev/canvask3d/`
- ☐ High FPS (>30fps)
- ☐ GPU usage visible in nvidia-smi

---

## Phase 4: RAM/CPU Optimization Test

### Baseline RAM
```bash
# Close all other apps
# Restart Firefox fresh
pkill firefox && sleep 2 && firefox &
sleep 10

# Measure baseline
ps aux | grep firefox | awk '{sum+=$6} END {print "Baseline RAM: " sum/1024 " MB"}'
```
**Target**: < 500MB idle

### 10-Tab Test
Open 10 tabs with common websites, wait 2 minutes:
```bash
ps aux | grep firefox | awk '{sum+=$6} END {print "10-tab RAM: " sum/1024 " MB"}'
```
**Target**: < 2000MB (2GB)

### CPU Idle Test
```bash
# With Firefox idle
top -b -n 3 -d 3 | grep firefox
```
**Target**: < 5% CPU when idle

---

## Phase 5: Sidebery Configuration

### Visual Check
- ☐ Sidebery sidebar visible on left
- ☐ Tabs displayed vertically
- ☐ Native horizontal tab bar HIDDEN
- ☐ Can create tab trees (drag tab onto parent)

### Configuration (Right-click in Sidebery → Settings)
**Recommended settings**:
- Tabs Tree Limit: 3 levels
- Colorize tabs: By domain
- Style: Proton or Compact
- Sidebar width: 320px

---

## Phase 6: KeePassXC & Sync

### KeePassXC Integration
```bash
# 1. Verify KeePassXC running
pgrep -a keepassxc

# 2. In Firefox: Click KeePassXC toolbar icon → Connect
# 3. Grant permission in KeePassXC popup
```
- ☐ KeePassXC-Browser connected
- ☐ Native messaging working

### Firefox Sync Setup
1. Firefox → Settings → Firefox Account
2. Sign in with Mozilla account
3. Choose sync items:
   - ☐ Bookmarks: YES
   - ☐ History: YES
   - ☐ Open Tabs: YES
   - ☐ **Add-ons**: **NO** (CRITICAL!)
   - ☐ Preferences: YES
4. Store Mozilla credentials in KeePassXC (`~/MyVault/`)

---

## Summary Checklist

- ☐ Firefox starts without errors
- ☐ All 9 extensions installed and enabled
- ☐ Native tab bar hidden
- ☐ Sidebery vertical tabs working
- ☐ GPU acceleration active (about:support)
- ☐ RAM usage < 2GB with 10 tabs
- ☐ CPU < 5% when idle
- ☐ Search engine is Google
- ☐ KeePassXC integration working
- ☐ Firefox Sync enabled (add-ons sync disabled)
- ☐ Session variables correct (X11, NVIDIA)

---

**If all checks pass**: ✅ Firefox declarative configuration successful!

**If any checks fail**: See `docs/firefox/TROUBLESHOOTING.md`

---

**Created**: 2025-12-15
**For**: Phase 1.5+ verification after home-manager switch
