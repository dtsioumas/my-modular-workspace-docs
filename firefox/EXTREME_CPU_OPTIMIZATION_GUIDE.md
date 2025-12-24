# Firefox Extreme CPU Optimization Guide

**Date:** 2025-12-24
**Context:** CPU-constrained desktop (1 core / 2 threads)
**Related:** ADR-020, PHASE-1A-IMPLEMENTATION.md

---

## Overview

This guide documents Firefox extreme CPU optimizations for scenarios where the desktop has only 1 core / 2 threads available. These settings **disable critical security features** to reduce CPU and RAM usage.

## Security Trade-offs

### Features Disabled

1. **Site Isolation (Fission)** - `fission.autostart = false`
   - **Risk:** Malicious websites can access data from other tabs
   - **Attack vector:** Cross-site scripting, Spectre-like attacks
   - **Impact:** HIGH

2. **Multiple Content Processes** - `dom.ipc.processCount = 1`
   - **Risk:** One tab crash can kill entire browser
   - **Impact:** MEDIUM (usability degradation)

3. **Process Prelaunch** - `dom.ipc.processPrelaunch.enabled = false`
   - **Risk:** Slower tab opening (no security impact)
   - **Impact:** LOW

### Required Mitigations

**Mandatory Extensions:**
- uBlock Origin (already installed)
- NoScript (recommended)

**Browsing Practices:**
- Browse ONLY trusted sites
- Maximum 3 tabs simultaneously
- Avoid: Google Docs, Figma, heavy web apps
- Keep Firefox updated

**Alternative:** Use separate browser for untrusted sites (Brave with sandboxing)

---

## Settings Breakdown

### RAM Cache Reduction

```nix
"browser.cache.memory.capacity" = 65536;  # 64MB (vs 256MB default)
"browser.cache.memory.max_entry_size" = 5120;  # 5MB max per entry
```

**Impact:**
- RAM savings: ~200MB
- Trade-off: More disk cache usage (acceptable with SSD)

### Process Management

```nix
"dom.ipc.processCount" = 1;  # Single content process
"dom.ipc.processCount.webIsolated" = 1;  # Single isolated process
"fission.autostart" = false;  # DISABLE site isolation
```

**Impact:**
- Process count: 8+ → 2-3 processes
- RAM savings: ~1.5GB
- CPU savings: ~10-15% (reduced context switching)
- **Security risk:** HIGH

### Session History Reduction

```nix
"browser.sessionhistory.max_entries" = 5;  # 5 back/forward entries
"browser.sessionhistory.max_total_viewers" = 1;  # Cache 1 previous page
```

**Impact:**
- RAM savings: ~50-100MB per tab
- Trade-off: Limited back/forward navigation

### Tab Unloading (Conservative - Tier 1)

```nix
"browser.tabs.unloadOnLowMemory" = true;
"browser.tabs.min_inactive_duration_before_unload" = 300000;  # 5 minutes
"browser.low_commit_space_threshold_mb" = 8000;  # 8GB threshold
"browser.low_commit_space_threshold_percent" = 50;  # 50% threshold
"browser.tabs.unloadTabInContextMenu" = true;  # Manual unload option
```

**Impact:**
- Automatic unload of inactive tabs when RAM < 8GB or < 50%
- Manual unload via right-click on tab
- Additional savings: 300-500MB

---

## Verification

### Check Process Count

```bash
ps aux | grep firefox | wc -l
# Expected: 2-4 processes (vs 8+ default)
```

### Check RAM Usage

```bash
ps aux | grep firefox | awk '{sum+=$6} END {print sum/1024 " MB"}'
# Expected: ~2GB with 3 tabs (vs 3.5GB default)
```

### Verify Fission Disabled

Open Firefox, navigate to `about:support`, search for "Fission":
- Expected: "Disabled by user"

### Check GPU Acceleration

Navigate to `about:support`, scroll to "Graphics":
- **WebRender:** Enabled
- **Hardware Video Decoding:** Enabled
- **GPU Process:** Active

---

## Rollback Instructions

### Re-enable Security Features

Edit `~/.MyHome/MySpaces/my-modular-workspace/home-manager/firefox.nix`:

```nix
# Change:
"fission.autostart" = false;  # → true
"dom.ipc.processCount" = 1;  # → 4
"dom.ipc.processCount.webIsolated" = 1;  # → 2
```

Rebuild:
```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager switch --flake .#mitsio@shoshin
```

### Increase Cache Sizes

```nix
# Change:
"browser.cache.memory.capacity" = 65536;  # → 262144 (256MB)
"browser.sessionhistory.max_entries" = 5;  # → 10
```

---

## Performance Expectations

### Light Workload (2-3 tabs, text sites)
- **Performance:** Acceptable
- **Lag:** 1-2s when switching tabs
- **RAM:** ~1.5-2GB

### Medium Workload (3-5 tabs, some media)
- **Performance:** Marginal
- **Lag:** 3-5s when switching tabs
- **RAM:** ~2-2.5GB
- **Risk:** System slowdown

### Heavy Workload (5+ tabs, Google Docs, Figma)
- **Performance:** UNUSABLE
- **Lag:** 10-30s freezes
- **Recommendation:** AVOID or use separate machine

---

## Known Issues

1. **Tab Crashes Affect Entire Browser**
   - Symptom: One bad tab crashes all tabs
   - Mitigation: Restart Firefox frequently, keep ≤3 tabs

2. **Slower Tab Opening**
   - Symptom: 2-3s delay when opening new tab
   - Cause: No process prelaunch
   - Mitigation: None (expected behavior)

3. **Limited Back/Forward Navigation**
   - Symptom: Can only go back 5 pages
   - Cause: `sessionhistory.max_entries = 5`
   - Mitigation: Use bookmarks instead of history

---

## Alternative Browsers for Heavy Tasks

When Firefox is too slow:

1. **Brave** (use for heavy web apps)
   - Better process isolation
   - More RAM/CPU available (allocate 2nd core temporarily)

2. **Chromium** (minimal profile)
   - Faster JavaScript execution
   - Use only when needed

3. **Links2** (text-based for documentation)
   - Zero GPU/CPU overhead
   - Perfect for reading docs

---

## References

- ADR-020: GPU Offload Strategy for CPU-Constrained Desktop
- Firefox Tweaks: https://wiki.archlinux.org/title/Firefox/Tweaks
- Tab Unloading: https://firefox-source-docs.mozilla.org/browser/tabunloader/
- Hardware Acceleration: https://wiki.nixos.org/wiki/Accelerated_Video_Playback

---

**Warning:** These optimizations are EXTREME and involve significant security trade-offs. Only use if you fully understand the risks and accept them.
