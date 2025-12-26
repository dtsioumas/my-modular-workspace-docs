# MCP Server Monitoring Guide
**Created:** 2025-12-26
**Status:** Production Ready
**Related:** [MCP_OPTIMIZATION_ACTION_PLAN.md](./MCP_OPTIMIZATION_ACTION_PLAN.md)

---

## Overview

This guide documents the monitoring and observability setup for MCP servers, implementing Priority 3 from the MCP Optimization Action Plan.

**What you get:**
- Real-time systemd resource tracking (memory, CPU)
- GPU utilization monitoring
- Memory pressure detection (PSI - Pressure Stall Information)
- Per-server resource breakdown
- Optional periodic monitoring via systemd timers

---

## Quick Start

### Manual Monitoring

Run these commands anytime to check current state:

```bash
# Check all MCP servers (memory, CPU, pressure)
monitor-mcp-servers.sh

# Check GPU usage
monitor-gpu.sh

# Quick status (existing basic tool)
mcp-monitor
```

### Enable Periodic Monitoring

Automatically collect metrics every few minutes:

```bash
# Enable MCP monitoring (every 5 minutes)
systemctl --user enable --now mcp-monitor.timer

# Enable GPU monitoring (every 2 minutes)
systemctl --user enable --now gpu-monitor.timer

# Check timer status
systemctl --user list-timers
```

### View Monitoring Logs

```bash
# View MCP monitoring history
journalctl --user -u mcp-monitor.service -f

# View GPU monitoring history
journalctl --user -u gpu-monitor.service -f

# Last 50 lines from both
journalctl --user -u mcp-monitor.service -u gpu-monitor.service -n 50
```

---

## Monitoring Scripts

### 1. `monitor-mcp-servers.sh` - Comprehensive MCP Resource Monitor

**What it shows:**
- Active MCP server scopes and their state
- Per-server memory usage:
  - Current memory (MB)
  - Memory limits (MemoryMax, MemoryHigh)
  - Utilization percentage
- CPU time per server
- Aggregate MCP slice statistics:
  - Total memory usage
  - Peak memory usage
  - **Memory pressure (PSI)** - early warning for memory issues
  - **CPU pressure (PSI)** - CPU contention detection

**Example output:**
```
==============================
  MCP Server Resource Usage
==============================

Active MCP Server Scopes:
-------------------------
  mcp-context7-12345.scope   loaded active running   MCP Server: Context7
  mcp-firecrawl-67890.scope  loaded active running   MCP Server: Firecrawl

Detailed Memory Usage:
======================

Server: mcp-context7-12345.scope
  Memory Current: 52MB
  Memory Max: 1000MB
  Memory Utilization: 5%
  Memory High (soft limit): 800MB
  CPU Time: 12s

Total MCP Slice Statistics:
===========================
  Memory Current: 1200MB
  Memory Peak: 1850MB

  Memory Pressure (PSI):
    some avg10=0.00 avg60=0.00 avg300=0.00 total=0
    full avg10=0.00 avg60=0.00 avg300=0.00 total=0
```

**Interpreting PSI (Pressure Stall Information):**
- `some`: Percentage of time at least one task was stalled
- `full`: Percentage of time ALL tasks were stalled
- `avg10/avg60/avg300`: 10-second, 60-second, 300-second averages
- **Good**: All values near 0.00
- **Warning**: `some avg60 > 5.0` - memory pressure building
- **Critical**: `full avg60 > 1.0` - serious memory contention

### 2. `monitor-gpu.sh` - GPU Resource Monitor

**What it shows:**
- GPU model and total VRAM
- Current VRAM usage (used/total/free)
- GPU utilization percentage
- Memory controller utilization
- Temperature and power draw
- Per-process GPU memory usage
- MCP-specific GPU processes (e.g., ck-search)

**Example output:**
```
==============================
     GPU Resource Usage
==============================

GPU Summary:
------------
  GPU: NVIDIA GeForce GTX 1650
  Memory: 1200MB / 4096MB (2896MB free)
  Utilization: GPU 35%, Memory 29%
  Temperature: 52°C
  Power Draw: 28.5W

Per-Process GPU Memory:
----------------------
  [MCP] PID: 12345 | Memory: 400MB | Process: ck-search
        Command: /nix/store/.../bin/mcp-ck-search

MCP GPU Processes (detailed):
==============================
  PID: 12345 | GPU Memory: 400MB
  Command: /nix/store/.../bin/mcp-ck-search --port 8080
```

**Interpreting GPU metrics:**
- **VRAM usage target:** Keep below 80% (3.2GB on 4GB card)
- **Temperature:**
  - Normal: 40-60°C idle, 60-80°C load
  - Warning: >80°C
  - Critical: >85°C
- **GPU utilization:**
  - Low (<20%): Underutilized or CPU-bound
  - Medium (20-70%): Healthy workload
  - High (>70%): GPU-bound (good for GPU tasks)

### 3. `mcp-monitor` - Quick Status (Existing Tool)

Basic quick check showing:
- MCP servers slice status
- Active MCP scopes
- Resource usage via systemd-cgtop
- Running MCP processes

---

## Systemd Services & Timers

### MCP Monitor Service

**Service:** `mcp-monitor.service`
**Timer:** `mcp-monitor.timer`
**Interval:** Every 5 minutes
**Config:** `/home/mitsio/.config/home-manager/mcp-monitoring.nix`

```bash
# Manual run
systemctl --user start mcp-monitor.service

# Enable periodic monitoring
systemctl --user enable --now mcp-monitor.timer

# Check status
systemctl --user status mcp-monitor.timer
systemctl --user status mcp-monitor.service

# View logs
journalctl --user -u mcp-monitor.service -f
```

### GPU Monitor Service

**Service:** `gpu-monitor.service`
**Timer:** `gpu-monitor.timer`
**Interval:** Every 2 minutes
**Config:** `/home/mitsio/.config/home-manager/mcp-monitoring.nix`

```bash
# Manual run
systemctl --user start gpu-monitor.service

# Enable periodic monitoring
systemctl --user enable --now gpu-monitor.timer

# Check status
systemctl --user status gpu-monitor.timer
systemctl --user status gpu-monitor.service

# View logs
journalctl --user -u gpu-monitor.service -f
```

---

## Understanding Memory Limits

### The 70% Self-Limiting Rule

MCP servers use **runtime self-limiting** to prevent OOM kills:

```
MemoryMax (systemd hard limit)
    ↓ 100%
    ├─────────────────────────────── OOM kill threshold
    ↓ 80%
MemoryHigh (systemd soft limit)
    ↓ 70%
    ├─────────────────────────────── Runtime limit (V8 heap, GOMEMLIMIT)
    ↓
    └─── 30% headroom for:
         - Native modules
         - OS buffers
         - GC overhead
```

**Example: firecrawl MCP**
- MemoryMax: 1500MB (systemd hard limit)
- MemoryHigh: 1200MB (80% - systemd soft limit)
- V8 heap: 1050MB (70% - runtime self-limit)
- Headroom: 450MB (30%)

**Why this matters:**
- Process limits itself BEFORE hitting systemd limits
- Prevents sudden OOM kills that disconnect MCP clients
- Allows graceful GC instead of forced termination

### Memory Tiers

**Tier 1 - Lightweight (400-500MB):**
- time, mcp-shell
- Simple operations, minimal state

**Tier 2 - Standard (800-1000MB):**
- sequential-thinking, exa, context7
- Moderate complexity, caching

**Tier 3 - Heavy (1500-2000MB):**
- firecrawl, ck-search, mcp-filesystem-rust
- Browser automation, embeddings, large file operations

---

## Troubleshooting

### High Memory Usage

**Symptom:** Server using >70% of MemoryMax

**Check:**
```bash
# Which server?
monitor-mcp-servers.sh

# Memory pressure?
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/mcp-servers.slice/memory.pressure
```

**Actions:**
1. Check if workload is legitimate (large request)
2. Review memory tier - might need increase
3. Check for memory leaks (usage growing over time)
4. Consider restarting the server if stuck high

### Memory Pressure Detected

**Symptom:** PSI shows `some avg60 > 5.0`

**Immediate actions:**
```bash
# Check which servers are near limits
monitor-mcp-servers.sh | grep -A5 "Utilization: [89][0-9]%"

# Check cgroup peak usage
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/mcp-servers.slice/memory.peak
```

**Long-term fixes:**
- Increase MemoryMax for the affected server
- Reduce concurrent requests
- Implement connection pooling (see action plan)
- Enable jemalloc (see action plan)

### OOM Kills

**Symptom:** MCP server suddenly disappears, systemd shows "failed"

**Diagnosis:**
```bash
# Check systemd logs
journalctl --user -u 'mcp-*.scope' | grep -i oom

# Check kernel OOM killer
dmesg | grep -i "killed process"

# Find which server
systemctl --user list-units 'mcp-*.scope' --failed
```

**Prevention:**
1. Verify 70% rule is applied (check V8 heap limits, GOMEMLIMIT)
2. Increase MemoryMax if workload legitimately needs more
3. Enable MemoryHigh soft limit (should already be at 80%)

### GPU Not Showing MCP Processes

**Symptom:** `monitor-gpu.sh` shows no MCP GPU processes

**Check:**
```bash
# Is CUDA available?
nvidia-smi

# Is ck-search using GPU?
ps aux | grep ck-search

# Check ck-search config
cat ~/.config/ck/config.toml | grep -i cuda
```

**Fix:**
- Verify ck-search was built with GPU support
- Check `CUDA_VISIBLE_DEVICES` not set to empty
- Restart ck-search: `systemctl --user restart 'mcp-ck-search*.scope'`

### High GPU Temperature

**Symptom:** GPU >80°C

**Immediate:**
```bash
# Check what's using GPU
monitor-gpu.sh

# Reduce workload or stop non-essential processes
```

**Long-term:**
- Improve case airflow
- Check GPU fan curve
- Consider undervolting
- Reduce concurrent GPU workloads

---

## Prometheus Integration (Optional)

For production-grade monitoring with graphs and alerts, see action plan section 3.3.

**Quick setup:**
```nix
# In NixOS configuration
services.prometheus = {
  enable = true;
  exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" "meminfo" "cpu" ];
    };
    nvidia-gpu = {
      enable = true;
    };
  };
};

services.grafana = {
  enable = true;
  settings.server.http_port = 3000;
};
```

**Useful queries:**
```promql
# MCP server memory usage
systemd_unit_memory_usage_bytes{name=~"mcp-.*"}

# GPU memory usage
nvidia_gpu_memory_used_bytes

# CPU usage by MCP server
rate(systemd_unit_cpu_seconds_total{name=~"mcp-.*"}[5m])
```

---

## Files & Locations

**Monitoring scripts:**
- `/home/mitsio/.local/bin/monitor-mcp-servers.sh`
- `/home/mitsio/.local/bin/monitor-gpu.sh`
- `/home/mitsio/.local/bin/mcp-monitor` (basic)

**Source:**
- `~/.MyHome/MySpaces/my-modular-workspace/toolkit/bin/`

**Systemd config:**
- `~/.config/home-manager/mcp-monitoring.nix`

**Logs:**
- MCP monitor: `journalctl --user -u mcp-monitor.service`
- GPU monitor: `journalctl --user -u gpu-monitor.service`

**Cgroup paths:**
- MCP slice: `/sys/fs/cgroup/user.slice/user-$(id -u).slice/mcp-servers.slice/`
- Per-server: `/sys/fs/cgroup/user.slice/user-$(id -u).slice/mcp-servers.slice/mcp-<name>-*.scope/`

---

## Next Steps

After setting up monitoring, see **MCP_OPTIMIZATION_ACTION_PLAN.md** for:
1. **Week 1-2:** Memory optimizations (jemalloc, THP, V8 tuning)
2. **Week 3-4:** GPU acceleration (context7, ck-search FP16)
3. **Week 5-6:** Advanced monitoring (Prometheus, Grafana)

---

**End of Guide**
