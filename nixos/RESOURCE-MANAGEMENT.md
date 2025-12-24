# Resource Management Configuration

## Problem Statement

**Daily OOM and CPU starvation issues on 16GB RAM, 8-core system:**

- Memory: 11GB baseline usage + build spikes = frequent OOM
- CPU: 50-60% usage by single tasks blocks everything else
- OOMD kills critical processes: browser, VMs, k8s cluster, IDE
- **Frequency**: EVERY DAY
- **Root cause**: Nix configured to use ALL resources (8 jobs × 8 cores = 64x parallelism!)

## Solution: Multi-Layer Defense Strategy

### Layer 1: Nix Build Resource Limits ✅

**File**: `modules/common.nix`

```nix
nix.settings = {
  max-jobs = 4;      # Max 4 parallel builds (was: auto = 8, then 2)
  cores = 1;         # Each build uses max 1 core (was: 0 = all!, then 2)
  timeout = 21600;   # 6 hours for long builds (was: 1 hour, then 4)
};
```

**Impact**:
- **Before**: 8 builds × 8 cores = up to 64x parallelism 💀
- **After**: 4 builds × 1 core = max 4 cores used ✅
- **Free**: 4 cores ALWAYS available for browser, IDE, VMs, k8s
- **Improvement**: More parallelism (4 vs 2 jobs) with same CPU usage

**Applies to**:
- ✅ `nixos-rebuild` (system builds)
- ✅ `home-manager switch` (home-manager builds)
- ✅ `nix build` (manual builds)
- ✅ ALL nix commands (uses same nix-daemon)

### Layer 2: Systemd Resource Limits for Nix-Daemon ✅

**File**: `modules/system/resource-control.nix`

```nix
systemd.services.nix-daemon.serviceConfig = {
  CPUQuota = "400%";        # Max 4 cores total
  MemoryHigh = "6G";        # Soft limit (throttling)
  MemoryMax = "8G";         # Hard limit (OOM kill)
  TasksMax = 4096;          # Prevent fork bombs
};
```

**Why needed?** Defense in depth. Even with nix.settings limits, this ensures builds CAN'T exceed these limits.

### Layer 3: OOMD Protection Configuration ✅

**File**: `modules/system/resource-control.nix`

**Protected processes** (ManagedOOMPreference=avoid):
- VMs (libvirt, qemu)
- k8s/k3s cluster
- IDE (VSCodium)
- Active terminals
- Desktop environment

**Killable processes** (killed first when memory tight):
- Browser tabs (Brave, Firefox)
- Background scripts (python, bash)
- Nix builds (already limited)

**Configuration**:
```nix
systemd.slices."user-" = {
  sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "80%";  # Trigger at 80% pressure
  };
};
```

### Layer 4: Swap Configuration ✅

**Current**:
- 4GB zram (compressed, priority 100) ← Keep this!
- 0GB disk swap

**Target**:
- 4GB zram (compressed, priority 100)
- 4GB disk swap (priority 50) ← Add this!
- **Total**: 8GB swap capacity

**To enable disk swap**:

```bash
# Create 4GB swap file
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

# Then uncomment in resource-control.nix:
# swapDevices = [
#   {
#     device = "/swapfile";
#     priority = 50;  # Lower than zram, so zram used first
#   }
# ];

# Rebuild
sudo nixos-rebuild switch
```

**Swap tuning**:
```nix
boot.kernel.sysctl = {
  "vm.swappiness" = 10;  # Only swap when necessary (was: 60)
};
```

### Layer 5: Early Warning Monitoring System ✅

**File**: `modules/monitoring/memory-monitor.nix`

**Features**:
- Monitors memory and CPU every 30 seconds
- Desktop notification at 85% usage (WARNING)
- Desktop notification at 90% usage (CRITICAL)
- Logs to journal for analysis
- Optional auto-kill of low-priority processes at 90%

**Notifications you'll see**:
```
⚠️ WARNING: Memory at 86%
Top process: brave (3.2%)
Swap: 75%
Consider closing some tabs or applications.
```

```
⚠️ CRITICAL: Memory at 92%
Top process: nix-daemon (5.1%)
Swap: 95%
Consider closing applications!
```

**Enable auto-kill** (optional):
Edit `modules/monitoring/memory-monitor.nix`, uncomment:
```bash
# kill_low_priority_processes  # Line ~95
```

## Application Instructions

### Step 1: Review Changes

```bash
# Check what will be rebuilt
cd /etc/nixos
sudo nixos-rebuild dry-build
```

### Step 2: Apply Configuration

```bash
# Apply and make permanent
sudo nixos-rebuild switch

# OR test first (doesn't make it boot default)
sudo nixos-rebuild test
```

### Step 3: Verify Nix Daemon Limits

```bash
# Check nix.conf was updated
cat /etc/nix/nix.conf | grep -E "max-jobs|cores|timeout"

# Expected output:
# cores = 1
# max-jobs = 4
# timeout = 21600
```

### Step 4: Verify Systemd Resource Limits

```bash
# Check nix-daemon resource limits
systemctl show nix-daemon | grep -E "CPUQuota|MemoryMax|MemoryHigh"

# Expected output:
# CPUQuotaPerSecUSec=4s (400%)
# MemoryMax=8589934592 (8G)
# MemoryHigh=6442450944 (6G)
```

### Step 5: Verify Monitoring

```bash
# Check timer is active
systemctl list-timers | grep memory-cpu-monitor

# Check recent monitor output
journalctl -u memory-cpu-monitor -n 20

# Force a manual check
sudo systemctl start memory-cpu-monitor
```

### Step 6: Test Nix Build

```bash
# Start a simple build and monitor
nix-shell -p hello --run hello

# In another terminal, watch resources
htop  # or btop
systemd-cgtop  # Watch cgroup resource usage
```

## Monitoring and Maintenance

### Check Current Resource Usage

```bash
# Overall system
htop  # or btop (prettier)

# Per-cgroup (shows nix-daemon limits)
systemd-cgtop

# Memory pressure
cat /proc/pressure/memory
cat /proc/pressure/cpu

# Swap usage
swapon --show
free -h
```

### Check Monitor Logs

```bash
# Recent warnings
journalctl -u memory-cpu-monitor --since "1 hour ago"

# All critical alerts
journalctl -u memory-cpu-monitor | grep CRITICAL

# Follow in real-time
journalctl -u memory-cpu-monitor -f
```

### Adjust Limits (If Needed)

**If builds are too slow**:
- Increase `cores = 2` (4×2 = 8 cores max, uses all cores!)
- Or increase `max-jobs = 6` with `cores = 1` (6 cores, leaves 2 free)
- Increase `CPUQuota = "600%"`  # 6 cores
- Increase `MemoryMax = "10G"`

**If still getting OOM**:
- Add disk swap (see Layer 4)
- Decrease other application usage
- Upgrade RAM

**If builds timeout**:
- Increase `timeout = 28800`  # 8 hours
- Or use `--option timeout 28800` per-build

## Troubleshooting

### Build Fails with "Timeout"

```bash
# Temporary override for one build
nix build --option timeout 28800  # 8 hours

# Or increase permanently in common.nix:
# timeout = 28800;
```

### Build Killed by OOM Despite Limits

Check if it's nix-daemon or something else:
```bash
# Check journal for OOM events
journalctl -k | grep -i "out of memory"
journalctl | grep -i oom

# If nix-daemon was killed, increase MemoryMax
# If browser was killed, that's expected (low priority)
```

### Monitor Not Sending Notifications

```bash
# Test notification manually
notify-send "Test" "This is a test"

# Check monitor service logs
journalctl -u memory-cpu-monitor -n 50

# Ensure libnotify is installed
which notify-send
```

### Swap Not Being Used

```bash
# Check swap priority
swapon --show

# Check swappiness
sysctl vm.swappiness

# Force memory pressure to test
# (DON'T DO THIS in production!)
# stress-ng --vm 1 --vm-bytes 12G --timeout 30s
```

## File Locations

```
/etc/nixos/
├── modules/
│   ├── common.nix                          # Layer 1: Nix build limits
│   ├── system/
│   │   └── resource-control.nix            # Layers 2,3,4: Systemd + OOMD + Swap
│   └── monitoring/
│       └── memory-monitor.nix              # Layer 5: Early warning
├── hosts/
│   └── shoshin/
│       └── configuration.nix               # Imports all modules
└── docs/
    └── RESOURCE-MANAGEMENT.md              # This file
```

## Expected Behavior After Configuration

### Normal Operation

- **Nix builds**: Use max 4 cores, 6-8GB RAM
- **Other apps**: Have 4 cores, 8-10GB RAM available
- **System**: Responsive, no freezing
- **Notifications**: None (below 85% thresholds)

### Under Load (Multiple Builds)

- **Nix builds**: Throttled when approaching 6GB
- **Build time**: May increase 10-20% (acceptable trade-off)
- **System**: Still responsive
- **Notifications**: WARNING at 85%, CRITICAL at 90%

### Crisis Scenario (>90% Memory)

- **OOMD**: Kills browser tabs first
- **Nix builds**: May be OOM killed at 8GB
- **Protected**: VMs, k8s, IDE stay alive
- **Notifications**: CRITICAL alerts
- **Recovery**: Automatic (low-priority processes killed)

## Success Criteria

✅ **No more daily OOM kills of critical processes**
✅ **System stays responsive during builds**
✅ **VMs and k8s cluster never killed or swapped**
✅ **Browser tabs sacrificed instead of critical work**
✅ **Early warnings before crisis**
✅ **Build times acceptable (slightly slower but stable)**

## References

- [Nix Manual: Tuning Cores and Jobs](https://nix.dev/manual/nix/2.24/advanced-topics/cores-vs-jobs)
- [systemd Resource Control](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html)
- [systemd-oomd](https://www.freedesktop.org/software/systemd/man/systemd-oomd.service.html)
- [Linux cgroups v2](https://docs.kernel.org/admin-guide/cgroup-v2.html)
- [Memory Pressure (PSI)](https://docs.kernel.org/accounting/psi.html)
