# CPU Affinity Verification and Troubleshooting Guide

**Date:** 2025-12-24
**Context:** 1c/2t desktop + 6c/12t K8s VM split on i7-6700K
**Related:** ADR-020, cpu-affinity-slices.nix

---

## Overview

This guide covers verification and troubleshooting of CPU affinity isolation between desktop and K8s VM workloads using systemd slices.

**Goal:** Strict CPU isolation to prevent thrashing
- Desktop: CPU threads 0-1 (1 core / 2 threads)
- K8s VM: CPU threads 2-7 (3 cores / 6 threads on hypervisor)

---

## Quick Verification

### 1. Check Systemd Slices

```bash
# Desktop slice CPU affinity
systemctl show desktop.slice | grep CPUAffinity
# Expected: CPUAffinity=0 1

# Virtualization slice CPU affinity
systemctl show virtualization.slice | grep CPUAffinity
# Expected: CPUAffinity=2 3 4 5 6 7
```

### 2. Check Process Distribution

```bash
# Use provided verification script:
check-cpu-affinity

# Or manually:
ps -eLo psr,comm | grep -E "^[[:space:]]*[01]" | head -20
# Should show desktop processes (kwin, firefox, etc.)

ps -eLo psr,comm | grep -E "^[[:space:]]*[2-7]" | head -20
# Should show VM processes (qemu, libvirt, etc.)
```

### 3. Monitor Per-Core CPU Usage

```bash
# Real-time per-core monitoring:
cpu-usage-per-core

# Or use htop:
htop
# Press F2 → Display Options → Enable "Detailed CPU time"
# CPUs 0-1 should be heavily loaded
# CPUs 2-7 should show VM workload
```

---

## Systemd Slice Configuration

### Desktop Slice (`desktop.slice`)

```nix
systemd.slices."desktop" = {
  description = "Desktop processes (1 core / 2 threads)";
  sliceConfig = {
    CPUAffinity = "0-1";  # Pin to threads 0-1
    MemoryHigh = "7G";    # Warning threshold
    MemoryMax = "8G";     # Hard limit (OOM if exceeded)
  };
};
```

**Services assigned:**
- `display-manager.service`
- `plasma*.service`
- All KDE/Plasma system services

### Virtualization Slice (`virtualization.slice`)

```nix
systemd.slices."virtualization" = {
  description = "K8s VM and virtualization (6 cores / 12 threads)";
  sliceConfig = {
    CPUAffinity = "2-7";  # Pin to threads 2-7
    MemoryHigh = "7G";
    MemoryMax = "8G";
  };
};
```

**Services assigned:**
- `libvirtd.service`
- `virtlogd.service`
- All QEMU/KVM processes

### User Slice (`desktop-user.slice`)

```nix
systemd.user.slices."desktop-user" = {
  description = "User desktop processes";
  sliceConfig = {
    CPUAffinity = "0-1";  # Pin to threads 0-1
    MemoryHigh = "5G";
    MemoryMax = "6G";
  };
};
```

**Processes affected:**
- User Firefox, VSCodium, Kitty
- KDE user services (plasma-plasmashell, etc.)

---

## Common Issues

### Issue 1: Processes Not Respecting Affinity

**Symptoms:**
- Desktop processes appearing on CPUs 2-7
- VM processes appearing on CPUs 0-1
- `check-cpu-affinity` shows mixed distribution

**Diagnosis:**
```bash
# Check if slices are active:
systemctl status desktop.slice
systemctl status virtualization.slice

# Check process slice membership:
systemctl status display-manager | grep Slice
# Expected: Slice: desktop.slice
```

**Causes & Fixes:**

1. **Services not assigned to slices**

   Check `cpu-affinity-slices.nix`:
   ```bash
   grep -A2 "display-manager" modules/system/cpu-affinity-slices.nix
   ```

   **Fix:** Ensure services have `serviceConfig.Slice = "desktop.slice"`

2. **Manual process launch ignoring slices**

   Processes launched directly don't inherit slice affinity

   **Fix:** Use `systemd-run` to launch in specific slice:
   ```bash
   systemd-run --slice=desktop-user.slice --user firefox
   ```

3. **libvirtd not managing VM affinity**

   ```bash
   # Check VM CPU affinity:
   virsh vcpupin <vm-name>
   ```

   **Fix:** Set VM CPU pinning in libvirt XML or use `virsh vcpupin`

### Issue 2: Desktop Threads Overloaded (>95% constantly)

**Symptoms:**
- CPUs 0-1 constantly at 95-100%
- Desktop lags and freezes
- OOM killer activating

**Diagnosis:**
```bash
# Check which processes are hogging CPUs 0-1:
ps -eLo psr,%cpu,comm --sort=-%cpu | grep -E "^[[:space:]]*[01]" | head -20
```

**Causes & Fixes:**

1. **Too many background services**

   **Fix:** Disable non-essential services (see `kde-service-reduction.nix`)

2. **Firefox using too much CPU**

   **Check tabs:**
   ```bash
   # In Firefox, open: about:performance
   # Close heavy tabs
   ```

   **Fix:** Enforce 3-tab maximum, use tab unloading

3. **KWin compositor too heavy**

   **Fix:** Disable more effects or use Picom (Phase 1B)

4. **Fundamental limitation: 1c/2t too little**

   **Fix:** Allocate 2 cores / 4 threads to desktop instead (abort Phase 1A)

### Issue 3: Memory Limits Causing OOM

**Symptoms:**
- `MemoryHigh` threshold exceeded
- OOM killer activating
- System swapping heavily to zram

**Diagnosis:**
```bash
# Check slice memory usage:
systemctl status desktop.slice | grep Memory
systemctl status virtualization.slice | grep Memory

# Check zram usage:
swapon --show
free -h
```

**Causes & Fixes:**

1. **Desktop exceeding 8GB limit**

   **Temporary fix:** Increase MemoryMax to 10GB in cpu-affinity-slices.nix

   **Permanent fix:** Reduce Firefox RAM usage (see firefox optimization guide)

2. **Both desktop + VM exceeding 15GB total**

   System only has 15GB physical RAM

   **Fix:** Reduce K8s VM allocation or desktop usage

3. **Zram not working effectively**

   ```bash
   # Check zram compression ratio:
   zramctl
   # Should show ~3.7:1 ratio with lz4
   ```

   **Fix:** Verify zram.nix configuration

### Issue 4: K8s VM Performance Degraded

**Symptoms:**
- VM slow despite having 6 cores
- K8s pods scheduling slowly
- VM processes appearing on wrong CPUs

**Diagnosis:**
```bash
# Check VM CPU assignment:
virsh vcpuinfo <vm-name>

# Check if VM is pinned correctly:
taskset -cp $(pgrep qemu-system)
# Expected: affinity list: 2,3,4,5,6,7
```

**Causes & Fixes:**

1. **VM not pinned to CPUs 2-7**

   **Fix:** Edit VM XML to pin VCPUs to physical CPUs 2-7

2. **VM overcommitted (>6 vCPUs)**

   **Fix:** Reduce VM vCPUs to 6 or less

3. **Desktop processes stealing VM CPU time**

   **Fix:** Verify desktop.slice affinity, increase VM priority

---

## Performance Tuning

### Recommended CPU Allocation

**For 1c/2t desktop (Phase 1A):**
- Threads 0-1: Desktop (ALL user processes)
- Threads 2-7: K8s VM (6 vCPUs max)

**For 2c/4t desktop (abort scenario):**
- Threads 0-3: Desktop
- Threads 4-7: K8s VM (4 vCPUs max)

### CPU Governor

Ensure performance governor is active:
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# All should show: performance
```

Set in `configuration.nix`:
```nix
powerManagement.cpuFreqGovernor = "performance";
```

### Process Priorities

Lower priority for background tasks:
```bash
# Reduce baloo indexer priority (if enabled):
renice +10 $(pgrep baloo)

# Increase VM priority:
renice -5 $(pgrep qemu-system)
```

---

## Monitoring & Verification Tools

### Built-in Scripts

```bash
# Check CPU affinity assignments:
check-cpu-affinity

# Real-time per-core monitoring:
cpu-usage-per-core

# Alternative with mpstat:
mpstat -P ALL 1
```

### System Tools

```bash
# Per-CPU usage in htop:
htop
# F2 → Display → Detailed CPU time → Save

# Process-specific CPU affinity:
taskset -cp <PID>

# Slice resource usage:
systemd-cgtop
```

### Stress Testing

```bash
# Stress test desktop CPUs (0-1):
stress-ng --cpu 2 --timeout 60s --taskset 0,1

# Stress test VM CPUs (2-7):
stress-ng --cpu 6 --timeout 60s --taskset 2,3,4,5,6,7
```

---

## Expected Behavior

### Desktop Threads (0-1)

**Idle:**
- CPU usage: 10-20% (KWin + background services)
- Processes: ~50-100 threads

**Light workload (2-3 Firefox tabs, text editing):**
- CPU usage: 40-60%
- Expect: 1-2s lag when switching apps

**Medium workload (5 tabs, media playback):**
- CPU usage: 80-95%
- Expect: 5-10s lag, occasional freezes

**Heavy workload (Google Docs, Figma, many tabs):**
- CPU usage: 95-100% sustained
- Expect: UNUSABLE (10-30s freezes)

### VM Threads (2-7)

**Idle:**
- CPU usage: 5-10% (K8s control plane)

**Light K8s workload (few pods):**
- CPU usage: 20-40%

**Heavy K8s workload (many pods, builds):**
- CPU usage: 80-95%

**No cross-contamination:**
- Desktop should NEVER use CPUs 2-7
- VM should NEVER use CPUs 0-1

---

## Abort Criteria

If any of these occur consistently:
1. Desktop freezes > 10s during normal use
2. Desktop CPUs (0-1) at 100% for > 30s at idle
3. OOM killer activating daily
4. Unable to use Firefox with 2-3 tabs

**Action:** Abort Phase 1A, allocate 2 cores / 4 threads to desktop

---

## References

- systemd Resource Control: https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html
- CPU Affinity: https://man7.org/linux/man-pages/man2/sched_setaffinity.2.html
- KVM CPU Pinning: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning

---

**Related Files:**
- `modules/system/cpu-affinity-slices.nix`
- `/etc/cpu-affinity-info.txt` (created after rebuild)
- ADR-020: GPU Offload Strategy
