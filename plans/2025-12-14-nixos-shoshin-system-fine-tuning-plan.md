# NixOS Shoshin System Fine-Tuning Implementation Plan
## Memory & CPU Optimization - Comprehensive Workstation Tuning

**Plan Created:** 2025-12-14
**System:** Shoshin Desktop (16GB RAM, Intel i7-6700K Skylake)
**Target:** Reduce zram usage from 79% to 10% through comprehensive optimizations
**Approach:** Multi-layer optimization (Kernel → Services → Applications → Desktop)

---

## Executive Summary

### Current State
- **zram usage:** 3.1GB / 3.9GB (79%) - CRITICAL
- **Top memory consumers:** Obsidian (1.1GB), Plasmashell (600MB), Brave browsers (400MB each), Claude CLI instances (300MB each)
- **Optimization potential:** 40-60% memory usage reduction possible

### Target State
- **zram usage:** <400MB / 8GB (10%)
- **Effective RAM:** 28-32GB (16GB physical + 12-16GB compressed)
- **Overall system responsiveness:** +30-50% improvement

###  Prerequisites

All steps in this plan assume:
- You have read and understood `docs/researches/nixos-shoshin-cpu-skylake-tuning.md`
- You have read and understood `docs/researches/nixos-shoshin-system-memory-optimization.md`
- NixOS configuration is at: `~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/`
- You have root access and can rebuild NixOS
- Backups exist before making changes

---

## Implementation Phases

### Phase 1: Kernel & Memory Subsystem (HIGHEST PRIORITY)
**Duration:** 1-2 hours
**Impact:** 20-30% memory pressure reduction
**Risk:** Low

### Phase 2: Application-Level Resource Limits
**Duration:** 2-3 hours
**Impact:** 30-40% memory usage reduction
**Risk:** Low-Medium (may affect user experience)

### Phase 3: Desktop Environment Optimization
**Duration:** 1-2 hours
**Impact:** 10-15% memory reduction
**Risk:** Low

### Phase 4: Systemd Service Resource Limits
**Duration:** 2-3 hours
**Impact:** 5-10% memory reduction
**Risk:** Medium (requires careful tuning)

### Phase 5: Advanced Hardware Optimizations
**Duration:** 1 hour
**Impact:** 5-10% performance improvement
**Risk:** Low

### Phase 6: Monitoring & Validation
**Duration:** Ongoing (1 week)
**Impact:** Ensures stability
**Risk:** None

---

## Phase 1: Kernel & Memory Subsystem Optimization

### Task 1.1: Increase zram Size (CRITICAL)

**Objective:** Increase zram from 25% (3.9GB) to 50% (8GB) of RAM

**Local Paths:**
- File to edit: `hosts/shoshin/nixos/modules/system/zram.nix`
- Research reference: `docs/researches/nixos-shoshin-system-memory-optimization.md`

**Current Configuration:**
```nix
memoryPercent = 25;  # 3.9GB, currently 79% utilized
```

**Target Configuration:**
```nix
memoryPercent = 50;  # 8GB
```

**Subtasks:**
1. ✅ **Backup current configuration**
   ```bash
   cp hosts/shoshin/nixos/modules/system/zram.nix \
      hosts/shoshin/nixos/modules/system/zram.nix.backup-$(date +%Y%m%d)
   ```

2. ✅ **Edit zram.nix**
   - Change `memoryPercent = 25;` to `memoryPercent = 50;`
   - Verify algorithm is still `"zstd"`

3. ✅ **Rebuild and test**
   ```bash
   sudo nixos-rebuild switch
   ```

4. ✅ **Validate**
   ```bash
   # Should show 8GB zram
   swapon --show
   free -h
   ```

**Expected Results:**
- zram size: 3.9GB → 8GB
- Effective RAM: ~24GB → ~28-32GB
- zram usage: 79% → 35-40% (initially)

**Rollback if needed:**
```bash
sudo nixos-rebuild switch --rollback
```

---

### Task 1.2: Optimize Dirty Page Parameters

**Objective:** Reduce dirty page ratios for better desktop responsiveness

**Local Paths:**
- File to edit: `hosts/shoshin/nixos/modules/system/zram.nix`
- Alternative: Create `hosts/shoshin/nixos/modules/system/vm-tuning.nix` (recommended)

**Current Values:**
```
vm.dirty_ratio = 20 (default)
vm.dirty_background_ratio = 10 (default)
```

**Target Values:**
```nix
"vm.dirty_ratio" = 10;
"vm.dirty_background_ratio" = 5;
```

**Subtasks:**
1. ✅ **Add to boot.kernel.sysctl in zram.nix**
   ```nix
   boot.kernel.sysctl = {
     "vm.swappiness" = 10;  # Keep existing

     # NEW: Dirty page management
     "vm.dirty_ratio" = 10;
     "vm.dirty_background_ratio" = 5;
     "vm.dirty_expire_centisecs" = 3000;
     "vm.dirty_writeback_centisecs" = 500;
   };
   ```

2. ✅ **Rebuild**
   ```bash
   sudo nixos-rebuild switch
   ```

3. ✅ **Validate**
   ```bash
   sysctl vm.dirty_ratio vm.dirty_background_ratio
   # Should output:
   # vm.dirty_ratio = 10
   # vm.dirty_background_ratio = 5
   ```

**Expected Results:**
- +15-25% better responsiveness during heavy I/O
- Reduced system freezes during file operations

---

### Task 1.3: Optimize VFS Cache Pressure

**Objective:** Improve filesystem cache retention

**Target Configuration:**
```nix
"vm.vfs_cache_pressure" = 50;  # Down from 100
"vm.min_free_kbytes" = 131072;  # 128MB reserved
```

**Subtasks:**
1. ✅ **Add to sysctl configuration**
   ```nix
   "vm.vfs_cache_pressure" = 50;
   "vm.min_free_kbytes" = 131072;
   ```

2. ✅ **Rebuild and validate**

**Expected Results:**
- +5-10% better file operation performance
- Better cache hit rates

---

### Task 1.4: Consolidate VM Tuning (Optional but Recommended)

**Objective:** Create dedicated VM tuning module for better organization

**Local Paths:**
- New file: `hosts/shoshin/nixos/modules/system/vm-tuning.nix`
- Update: `hosts/shoshin/nixos/hosts/shoshin/configuration.nix`

**Subtasks:**
1. ✅ **Create vm-tuning.nix**
   ```nix
   { config, lib, ... }:
   {
     # Virtual Memory & Kernel Tuning
     boot.kernel.sysctl = {
       # Memory management
       "vm.swappiness" = 10;
       "vm.vfs_cache_pressure" = 50;
       "vm.min_free_kbytes" = 131072;

       # Dirty page management
       "vm.dirty_ratio" = 10;
       "vm.dirty_background_ratio" = 5;
       "vm.dirty_expire_centisecs" = 3000;
       "vm.dirty_writeback_centisecs" = 500;

       # File system
       "fs.file-max" = 2097152;
       "fs.inotify.max_user_watches" = 524288;
     };

     # Transparent Huge Pages
     boot.kernelParams = [
       "transparent_hugepage=madvise"
     ];
   }
   ```

2. ✅ **Update configuration.nix imports**
   ```nix
   imports = [
     ...
     ../../modules/system/vm-tuning.nix  # NEW
   ];
   ```

3. ✅ **Remove duplicate sysctl entries from zram.nix**

**Phase 1 Completion Checklist:**
- [ ] zram size increased to 50% (8GB)
- [ ] Dirty page ratios optimized
- [ ] VFS cache pressure reduced
- [ ] System rebuilt successfully
- [ ] Validation commands run
- [ ] zram usage monitored for 24 hours

---

## Phase 2: Application-Level Resource Limits

### Task 2.1: Browser Memory Optimization

**Objective:** Reduce browser memory footprint through built-in features and system limits

**Local Paths:**
- New file: `hosts/shoshin/nixos/modules/applications/browser-limits.nix`
- Update: `hosts/shoshin/nixos/hosts/shoshin/configuration.nix`

#### Subtask 2.1.1: Brave Browser Optimizations

**Current State (from ps output):**
- Already has: `--js-flags=--max-old-space-size=512`
- Already has: `--renderer-process-limit=4`
- Multiple renderer processes: ~300-400MB each

**Target:** Further limit via systemd user service wrapper

**Implementation:**
```nix
# hosts/shoshin/nixos/modules/applications/browser-limits.nix
{ config, pkgs, ... }:
{
  # Browser launch wrappers with resource limits
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "brave-limited" ''
      systemd-run --user --scope \
        -p MemoryMax=2G \
        -p CPUQuota=150% \
        ${pkgs.brave}/bin/brave "$@"
    '')

    (writeShellScriptBin "firefox-limited" ''
      systemd-run --user --scope \
        -p MemoryMax=3G \
        -p CPUQuota=200% \
        ${pkgs.firefox}/bin/firefox "$@"
    '')
  ];
}
```

**Subtasks:**
1. ✅ **Create browser-limits.nix**
2. ✅ **Add to configuration.nix imports**
3. ✅ **Rebuild system**
4. ✅ **Test limited browser launches**
5. ✅ **Update desktop files** (if using as default)

**Expected Results:**
- Brave: Maximum 2GB total memory (currently ~1.5GB across all processes)
- Firefox: Maximum 3GB total memory
- Hard memory limits prevent runaway memory usage

---

#### Subtask 2.1.2: Firefox Tab Discarding

**Objective:** Enable Firefox automatic tab discarding

**User Configuration (not NixOS):**
User must configure in `about:config`:

```
browser.low_commit_space_threshold_mb = 24000  # 2/3 of 32GB (16GB physical)
browser.tabs.unloadOnLowMemory = true
```

**Subtasks:**
1. ✅ **Document in user guide**
2. ✅ **Test tab discarding behavior**

---

### Task 2.2: Desktop Application Memory Limits

**Objective:** Set memory limits for heavy desktop applications

**Local Paths:**
- File: `hosts/shoshin/nixos/modules/applications/app-limits.nix`

**Target Applications:**
- Obsidian (currently 1.1GB - limit to 1.5GB)
- Dolphin (currently 391MB - limit to 500MB)
- VS Code / Editors (limit to 2GB)

**Implementation:**
```nix
{ config, pkgs, ... }:
{
  systemd.user.services = {
    # Per-user application limits
    # Note: These are examples, actual implementation via wrappers
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "obsidian-limited" ''
      systemd-run --user --scope \
        -p MemoryMax=1536M \
        -p CPUQuota=100% \
        ${pkgs.obsidian}/bin/obsidian "$@"
    '')
  ];
}
```

**Subtasks:**
1. ✅ **Identify heavy applications from ps output**
2. ✅ **Create launch wrappers for each**
3. ✅ **Set appropriate limits**
4. ✅ **Test application functionality**
5. ✅ **Update desktop entries if needed**

---

### Task 2.3: CLI Tool Memory Limits

**Objective:** Limit memory for CLI tools (Claude, Gemini, etc.)

**Current State:**
- Claude CLI: Multiple instances at 290-390MB each
- Gemini CLI: ~350MB

**Implementation:**
```nix
{ config, pkgs, ... }:
{
  # Wrapper scripts with memory limits
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "claude-limited" ''
      systemd-run --user --scope \
        -p MemoryMax=500M \
        -p CPUQuota=100% \
        ~/.nix-profile/bin/claude "$@"
    '')

    (writeShellScriptBin "gemini-limited" ''
      systemd-run --user --scope \
        -p MemoryMax=400M \
        -p CPUQuota=75% \
        ~/.nix-profile/bin/gemini "$@"
    '')
  ];

  # Aliases
  environment.shellAliases = {
    claude = "claude-limited";
    gemini = "gemini-limited";
  };
}
```

**Subtasks:**
1. ✅ **Create limited wrappers**
2. ✅ **Set up aliases**
3. ✅ **Test CLI tool functionality**
4. ✅ **Monitor memory usage**

---

## Phase 3: Desktop Environment Optimization (KDE Plasma)

### Task 3.1: KDE Plasma Performance Tuning

**Objective:** Reduce Plasmashell memory usage (currently 600MB)

**Local Paths:**
- File: `hosts/shoshin/nixos/modules/workspace/plasma.nix`
- New file: `hosts/shoshin/nixos/modules/workspace/plasma-optimization.nix`

#### Subtask 3.1.1: Disable Unnecessary Features

**User Actions (System Settings):**
1. ✅ **Disable Desktop Effects**
   - System Settings → Workspace Behavior → Desktop Effects
   - Disable: Blur, Wobbly Windows, Magic Lamp, etc.
   - Keep: Fade, Slide

2. ✅ **Reduce Animations**
   - System Settings → Workspace Behavior → General Behavior → Animation speed
   - Set to: "Instant" or "Fast"

3. ✅ **Disable Baloo File Indexing** (if not needed)
   - System Settings → Search → File Search
   - Uncheck "Enable File Search"

4. ✅ **Limit Desktop Widgets**
   - Remove unused widgets from panels and desktop
   - Keep only essential widgets

**Expected Results:**
- Plasmashell: 600MB → 400-450MB
- Smoother desktop performance

---

#### Subtask 3.1.2: KWin Compositor Optimization

**Objective:** Optimize compositor settings

**User Actions:**
1. ✅ **System Settings → Display and Monitor → Compositor**
   - Rendering backend: OpenGL 3.1 (or XRender for lower memory)
   - Tearing prevention: "Never" (lowest overhead)
   - Keep window thumbnails: "Only for Shown Windows"

**Expected Results:**
- KWin: 429MB → ~350MB
- Better GPU utilization

---

### Task 3.2: KDE Application Optimization

**Objective:** Configure KDE applications for lower memory usage

**Applications:**
- Dolphin (file manager)
- Konsole (terminal)
- Kate/KWrite (editor)

**User Actions:**
1. ✅ **Dolphin Settings**
   - Settings → Configure Dolphin → General
   - Uncheck "Show preview in tooltips"
   - Uncheck "Show selection marker"

2. ✅ **Konsole Settings**
   - Settings → Configure Konsole → General
   - Reduce scrollback to 1000 lines (from 10000)

---

## Phase 4: Systemd Service Resource Limits

### Task 4.1: Configure User Slice Limits

**Objective:** Set global limits for user.slice (all user processes)

**Local Paths:**
- New file: `hosts/shoshin/nixos/modules/system/user-resource-limits.nix`

**Implementation:**
```nix
{ config, lib, ... }:
{
  systemd.slices."user-${toString config.users.users.mitsio.uid}" = {
    sliceConfig = {
      # Soft limit: Start applying pressure at 12GB
      MemoryHigh = "12G";

      # Hard limit: OOM kill at 14GB
      MemoryMax = "14G";

      # CPU weight (default is 100)
      CPUWeight = 100;

      # Swap limit
      MemorySwapMax = "2G";
    };
  };
}
```

**Subtasks:**
1. ✅ **Create user-resource-limits.nix**
2. ✅ **Get user UID**
   ```bash
   id -u mitsio  # Should be 1001
   ```
3. ✅ **Add to configuration.nix imports**
4. ✅ **Rebuild and test**
5. ✅ **Validate limits**
   ```bash
   systemctl show user-1001.slice | grep Memory
   ```

**Expected Results:**
- All user processes limited to 14GB maximum
- Memory pressure starts at 12GB
- Prevents single user from consuming all RAM

---

### Task 4.2: Configure App-Specific Slices

**Objective:** Create slices for browser, media, and development work

**Implementation:**
```nix
{ config, ... }:
{
  systemd.user.slices = {
    # Browser slice
    "browser.slice" = {
      Unit = {
        Description = "Web Browsers";
      };
      Slice = {
        MemoryHigh = "4G";
        MemoryMax = "6G";
        CPUWeight = 50;  # Lower priority
      };
    };

    # Development slice
    "dev.slice" = {
      Unit = {
        Description = "Development Tools";
      };
      Slice = {
        MemoryHigh = "6G";
        MemoryMax = "8G";
        CPUWeight = 80;  # Higher priority
      };
    };

    # Media slice
    "media.slice" = {
      Unit = {
        Description = "Media Applications";
      };
      Slice = {
        MemoryHigh = "2G";
        MemoryMax = "3G";
        CPUWeight = 30;  # Lowest priority
      };
    };
  };
}
```

**Subtasks:**
1. ✅ **Create slice definitions**
2. ✅ **Update application wrappers to use slices**
   ```nix
   systemd-run --user --scope --slice=browser.slice brave
   ```
3. ✅ **Test slice enforcement**
4. ✅ **Monitor with systemd-cgtop**

---

### Task 4.3: System Service Optimization

**Objective:** Optimize system services that don't need unlimited resources

**Local Paths:**
- File: `hosts/shoshin/nixos/modules/system/service-limits.nix`

**Target Services:**
- nix-daemon
- ModemManager
- NetworkManager

**Implementation:**
```nix
{ config, ... }:
{
  systemd.services = {
    nix-daemon = {
      serviceConfig = {
        MemoryMax = "4G";        # Limit nix builds
        CPUQuota = "300%";       # Max 3 cores
        TasksMax = 4096;
        OOMScoreAdjust = 100;   # Kill this before user apps
      };
    };

    ModemManager = {
      serviceConfig = {
        MemoryMax = "128M";
        CPUQuota = "25%";
      };
    };
  };
}
```

**Subtasks:**
1. ✅ **Identify services to limit**
   ```bash
   systemctl list-units --type=service --state=running
   ```
2. ✅ **Create service-limits.nix**
3. ✅ **Test services still function**
4. ✅ **Monitor resource usage**

---

## Phase 5: Advanced Hardware Optimizations

### Task 5.1: OOM Score Adjustment

**Objective:** Configure OOM killer priorities

**Implementation:**
```nix
{ config, pkgs, ... }:
{
  # System services - highest OOM score (kill first)
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 500;

  # User-facing apps - protect more
  # (configured via application wrappers with OOMScoreAdjust=-100)
}
```

**OOM Score Reference:**
- -1000: Never kill
- -100 to -1: Protected
- 0: Default
- 1 to 1000: Prefer to kill

**Priority:**
1. System services: 100-500 (kill first)
2. Browsers: 0 (default)
3. Editors/terminals: -100 to -200 (protect)
4. Critical apps: -500 (highly protected)

**Subtasks:**
1. ✅ **Define OOM priority strategy**
2. ✅ **Apply to services**
3. ✅ **Apply to application wrappers**
4. ✅ **Test OOM behavior**

---

### Task 5.2: CPU Frequency Scaling Integration

**Objective:** Ensure CPU optimizations from Phase 1 are applied

**Reference:** `docs/researches/nixos-shoshin-cpu-skylake-tuning.md`

**Verification:**
```bash
# Check CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Should output: performance
```

**If not applied, refer to CPU optimization plan.**

---

### Task 5.3: I/O Priority (ionice)

**Objective:** Set I/O priorities for processes

**Implementation:**
```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "brave-limited" ''
      systemd-run --user --scope \
        -p MemoryMax=2G \
        -p CPUQuota=150% \
        -p IOWeight=50 \
        ${pkgs.brave}/bin/brave "$@"
    '')
  ];
}
```

**I/O Weight Values:**
- 1-100: Low priority (background tasks)
- 100: Default
- 100-10000: High priority (interactive apps)

---

## Phase 6: Monitoring & Validation

### Task 6.1: Create Monitoring Dashboard

**Objective:** Set up continuous monitoring

**Local Paths:**
- New script: `~/bin/system-monitor.sh`

**Implementation:**
```bash
#!/usr/bin/env bash
# system-monitor.sh - Display system resource usage

clear
echo "=== System Resource Monitor ==="
echo ""

echo "--- Memory Usage ---"
free -h
echo ""

echo "--- zram Status ---"
swapon --show
echo ""
zram_used=$(awk '/^Swap:/ {print $3}' /proc/meminfo | sed 's/kB//')
zram_total=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
zram_percent=$((zram_used * 100 / zram_total))
echo "zram utilization: $zram_percent%"
echo ""

echo "--- zram Compression Ratio ---"
cat /sys/block/zram0/mm_stat | awk '{
  orig=$1; comp=$2; mem=$3
  ratio=orig/comp
  saved=(orig-comp)/1024/1024/1024
  printf "Compression ratio: %.2f:1\n", ratio
  printf "Memory saved: %.2f GB\n", saved
}'
echo ""

echo "--- Top 10 Memory Consumers ---"
ps aux --sort=-%mem | head -11 | awk 'NR==1 || NR>1 {printf "%-8s %5s %5s %s\n", $1, $3, $4, $11}'
echo ""

echo "--- Systemd Slice Usage ---"
systemd-cgtop -n 1 --depth=2 2>/dev/null | head -15
```

**Subtasks:**
1. ✅ **Create monitoring script**
2. ✅ **Make executable**
   ```bash
   chmod +x ~/bin/system-monitor.sh
   ```
3. ✅ **Add to PATH**
4. ✅ **Run periodically**

---

### Task 6.2: Validation Commands

**Daily Checks (First Week):**

```bash
# Check zram usage (target: <10%)
swapon --show
free -h

# Check memory pressure
systemctl status systemd-oomd
journalctl -u systemd-oomd -n 50

# Check cgroup limits
systemctl show user-1001.slice | grep Memory
systemd-cgtop -n 1

# Check application memory
ps aux --sort=-%mem | head -20

# Check for OOM kills
journalctl -k | grep -i oom

# Check sysctl parameters
sysctl -a | grep -E "vm\.(dirty|swap|vfs_cache)"
```

**Subtasks:**
1. ✅ **Document validation commands**
2. ✅ **Create validation checklist**
3. ✅ **Run daily for first week**
4. ✅ **Adjust limits as needed**

---

### Task 6.3: Performance Benchmarking

**Objective:** Measure before/after performance

**Benchmarks:**
1. ✅ **Memory pressure test**
   ```bash
   stress-ng --vm 4 --vm-bytes 75% --timeout 60s
   # Monitor: zram usage, system responsiveness
   ```

2. ✅ **I/O responsiveness**
   ```bash
   time find /nix/store -name '*.nix' | wc -l
   # Compare before/after times
   ```

3. ✅ **Desktop responsiveness**
   - Open 20 browser tabs
   - Launch heavy applications
   - Switch between applications
   - Measure subjective lag

**Subtasks:**
1. ✅ **Run baseline benchmarks (before optimizations)**
2. ✅ **Document baseline results**
3. ✅ **Run benchmarks after each phase**
4. ✅ **Compare results**

---

## Implementation Timeline

### Week 1: Core System Optimization
- **Day 1:** Phase 1 - Kernel & Memory Subsystem
- **Day 2:** Phase 1 validation, monitoring
- **Day 3:** Phase 2.1 - Browser limits
- **Day 4:** Phase 2.2 - Application limits
- **Day 5:** Phase 3 - Desktop optimization
- **Weekend:** Monitoring and adjustments

### Week 2: Advanced Optimization
- **Day 8:** Phase 4.1-4.2 - User slice limits
- **Day 9:** Phase 4.3 - Service limits
- **Day 10:** Phase 5 - Hardware optimizations
- **Day 11-14:** Monitoring, validation, fine-tuning

---

## Expected Results

### Immediate (After Phase 1)
- zram usage: 79% → 35-40%
- System responsiveness: +20-30%
- I/O latency: -25%

### After Phase 2
- zram usage: 35-40% → 20-25%
- Browser memory: -30-40%
- Application memory: -20-30%

### After Phase 3-4
- zram usage: 20-25% → 10-15%
- Desktop memory: -15-20%
- OOM protection: Improved

### Final Target
- **zram usage:** <10% (< 800MB / 8GB)
- **Effective RAM:** 28-32GB
- **System responsiveness:** +40-60%
- **Memory pressure events:** Near zero

---

## Risk Mitigation

### Rollback Strategy
```bash
# Quick rollback
sudo nixos-rebuild switch --rollback

# Specific generation
sudo nixos-rebuild switch --switch-generation <number>

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Backup Strategy
Before each phase:
```bash
# Backup current configuration
cd ~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos
git add -A
git commit -m "Pre-Phase X backup - $(date +%Y-%m-%d)"
git push
```

### Testing Strategy
1. Test each change in isolation
2. Monitor for 24 hours before proceeding
3. Roll back if issues detected
4. Document any unexpected behavior

---

## Troubleshooting Guide

### Issue: Application Killed by OOM
**Symptoms:** Application suddenly closes, `journalctl -k` shows OOM kill
**Solution:**
1. Check which cgroup was killed: `journalctl -k | grep -i oom`
2. Increase limit for that slice/service
3. Adjust OOM scores if needed

### Issue: System Freezes
**Symptoms:** Unresponsive system during heavy load
**Solution:**
1. Check if zram is full: `swapon --show`
2. Increase zram size further (75-100%)
3. Check dirty page ratios are applied
4. Verify systemd-oomd is running

### Issue: Application Performance Degraded
**Symptoms:** Slow application startup or operation
**Solution:**
1. Check resource limits: `systemctl status app.service`
2. Increase MemoryMax if too restrictive
3. Adjust CPUQuota if CPU-bound
4. Check for memory leaks

### Issue: Browser Tabs Discarding Too Aggressively
**Symptoms:** Tabs reload frequently
**Solution:**
1. Reduce `browser.low_commit_space_threshold_mb`
2. Increase browser MemoryMax limit
3. Close unnecessary tabs

---

## Maintenance

### Weekly Tasks
- [ ] Check zram usage trends
- [ ] Review OOM kills in journal
- [ ] Monitor application memory usage
- [ ] Adjust limits if needed

### Monthly Tasks
- [ ] Review and optimize limits based on usage patterns
- [ ] Update documentation with findings
- [ ] Clean up unused services/applications
- [ ] Benchmark system performance

### Quarterly Tasks
- [ ] Full system performance review
- [ ] Update optimization plan
- [ ] Research new optimization techniques
- [ ] Consider hardware upgrades if needed

---

## Reference Documentation

### Local Paths
- **CPU Optimization Research:** `docs/researches/nixos-shoshin-cpu-skylake-tuning.md`
- **Memory Optimization Research:** `docs/researches/nixos-shoshin-system-memory-optimization.md`
- **NixOS Configuration:** `hosts/shoshin/nixos/`
- **This Plan:** `docs/plans/nixos-shoshin-system-fine-tuning-plan.md`

### External Resources
- systemd.resource-control(5): https://man7.org/linux/man-pages/man5/systemd.resource-control.5.html
- Linux VM Tuning: https://docs.kernel.org/admin-guide/sysctl/vm.html
- KDE Plasma Optimization: https://userbase.kde.org/Plasma/FAQ#Performance
- Firefox Tab Discarding: https://support.mozilla.org/en-US/kb/unload-inactive-tabs-save-system-memory-firefox

---

## Completion Checklist

### Phase 1: Kernel & Memory
- [ ] zram increased to 50%
- [ ] Dirty page ratios optimized
- [ ] VFS cache pressure reduced
- [ ] System rebuilt successfully
- [ ] 24-hour monitoring completed
- [ ] zram usage < 40%

### Phase 2: Applications
- [ ] Browser memory limits configured
- [ ] Application wrappers created
- [ ] CLI tool limits applied
- [ ] Desktop files updated
- [ ] Application functionality verified

### Phase 3: Desktop Environment
- [ ] KDE effects optimized
- [ ] Baloo indexing configured
- [ ] Desktop widgets minimized
- [ ] Compositor settings optimized
- [ ] Plasmashell < 450MB

### Phase 4: Systemd Services
- [ ] User slice limits configured
- [ ] App-specific slices created
- [ ] System service limits applied
- [ ] Limits validated
- [ ] No service failures

### Phase 5: Hardware Optimizations
- [ ] OOM scores configured
- [ ] CPU governor verified
- [ ] I/O priorities set
- [ ] Hardware features enabled

### Phase 6: Monitoring
- [ ] Monitoring script created
- [ ] Daily checks performed
- [ ] Benchmarks completed
- [ ] Documentation updated
- [ ] zram usage < 10%

---

## Success Criteria

### Primary Goals
✅ zram usage reduced from 79% to <10%
✅ Effective RAM increased from ~20GB to 28-32GB
✅ System responsiveness improved by 40-60%
✅ No application functionality loss
✅ Stable system for 1 week

### Secondary Goals
✅ OOM kills reduced to near zero
✅ Desktop memory usage reduced by 15-20%
✅ Browser memory usage reduced by 30-40%
✅ Comprehensive monitoring in place
✅ Documentation complete and accurate

---

**Plan Status:** Ready for Implementation
**Next Step:** Begin Phase 1 - Kernel & Memory Subsystem Optimization
**Estimated Total Time:** 10-15 hours over 2 weeks
**Review Date:** After Phase 1 completion (Week 1)
