# MCP Server Optimization - Implementation Roadmap
**Date:** 2025-12-26
**Status:** Priority 1 Complete, Priority 2-3 Documented
**Next Phase:** Deployment & Optional Advanced Optimizations

---

## Overview

This roadmap provides a clear path from current state to fully optimized MCP infrastructure. Each phase builds on the previous, with clear success criteria and rollback procedures.

**Philosophy:** Incremental optimization with measurement at each step

---

## Current State (2025-12-26)

### Implemented ✅
- jemalloc memory allocator (all Node.js servers)
- Transparent Huge Pages madvise mode (NixOS kernel)
- V8 semi-space tuning (tiered 16/32/64MB)
- Monitoring infrastructure (systemd + GPU)

### Researched & Documented 📚
- GPU optimization (current setup optimal)
- Connection pooling (10-80x throughput potential)

### Not Yet Deployed ⏳
- Priority 1 changes need home-manager rebuild
- NixOS THP change needs system rebuild
- Monitoring timers not enabled

---

## Phase 0: Pre-Deployment Validation (Week 52, Days 1-2)

**Goal:** Validate current state before applying optimizations

**Duration:** 2-4 hours

### Tasks

#### 1. Baseline Metrics Collection
```bash
# Create baseline directory
mkdir -p ~/mcp-optimization-baselines/2025-12-26-pre-optimization

# Collect current metrics
~/.local/bin/monitor-mcp-servers.sh > ~/mcp-optimization-baselines/2025-12-26-pre-optimization/mcp-servers.txt
~/.local/bin/monitor-gpu.sh > ~/mcp-optimization-baselines/2025-12-26-pre-optimization/gpu.txt

# Collect systemd metrics
for scope in $(systemctl --user list-units 'mcp-*' --no-legend | awk '{print $1}'); do
    echo "=== $scope ===" >> ~/mcp-optimization-baselines/2025-12-26-pre-optimization/systemd-metrics.txt
    systemctl --user show "$scope" >> ~/mcp-optimization-baselines/2025-12-26-pre-optimization/systemd-metrics.txt
    echo "" >> ~/mcp-optimization-baselines/2025-12-26-pre-optimization/systemd-metrics.txt
done

# Collect kernel parameters
cat /sys/kernel/mm/transparent_hugepage/enabled > ~/mcp-optimization-baselines/2025-12-26-pre-optimization/thp-before.txt
```

#### 2. Verify Git State
```bash
cd ~/.config/home-manager
git status

cd /etc/nixos
git status

# Ensure no uncommitted changes
```

#### 3. Backup Current Config
```bash
# Home-manager backup
cp -r ~/.config/home-manager ~/.config/home-manager.backup-2025-12-26

# NixOS backup (already versioned via git)
```

### Success Criteria
- [ ] Baseline metrics collected
- [ ] Git repos clean
- [ ] Backups created
- [ ] Current state documented

---

## Phase 1: Deploy Priority 1 Optimizations (Week 52, Days 3-4)

**Goal:** Deploy jemalloc, THP, V8 tuning, and monitoring

**Duration:** 4-6 hours (including testing)

### Step 1.1: Deploy Home-Manager Changes

```bash
cd ~/.config/home-manager

# Verify changes
git diff origin/main

# Expected changes:
# - npm-dream2nix.nix (jemalloc + V8)
# - from-flake.nix (jemalloc + V8)
# - monitoring.nix (new file)
# - toolkit.nix (removed scripts)
# - symlinks.nix (removed toolkit binding)

# Rebuild
home-manager switch

# Expected output: Building, activating, no errors
```

**Rollback if needed:**
```bash
cd ~/.config/home-manager
git revert HEAD~5..HEAD
home-manager switch
```

### Step 1.2: Verify Home-Manager Deployment

```bash
# Verify jemalloc injection
systemctl --user status 'mcp-firecrawl-*' | grep LD_PRELOAD
# Should show: LD_PRELOAD=/nix/store/.../libjemalloc.so

# Verify V8 options
ps aux | grep mcp-firecrawl | grep max-semi-space-size
# Should show: --max-semi-space-size=64

# Verify monitoring scripts
which monitor-mcp-servers.sh
which monitor-gpu.sh

# Test monitoring
~/.local/bin/monitor-mcp-servers.sh
```

### Step 1.3: Deploy NixOS THP Change

```bash
cd /etc/nixos

# Verify change
git diff origin/main modules/system/hardware-optimization.nix
# Should show: transparent_hugepage=madvise

# Rebuild (as root)
sudo nixos-rebuild switch

# Verify THP setting
cat /sys/kernel/mm/transparent_hugepage/enabled
# Should show: always [madvise] never
```

**Rollback if needed:**
```bash
cd /etc/nixos
git revert HEAD
sudo nixos-rebuild switch
```

### Step 1.4: Restart MCP Servers

```bash
# Stop all MCP servers (they'll auto-restart when Claude Code reconnects)
systemctl --user stop 'mcp-*'

# Verify no running scopes
systemctl --user list-units 'mcp-*'

# Restart Claude Code or trigger MCP connection
# Servers will start with new configuration
```

### Step 1.5: Post-Deployment Validation

```bash
# Create post-deployment baseline
mkdir -p ~/mcp-optimization-baselines/2025-12-26-post-priority1

# Collect metrics
~/.local/bin/monitor-mcp-servers.sh > ~/mcp-optimization-baselines/2025-12-26-post-priority1/mcp-servers.txt
~/.local/bin/monitor-gpu.sh > ~/mcp-optimization-baselines/2025-12-26-post-priority1/gpu.txt

# Compare memory usage
diff -u ~/mcp-optimization-baselines/2025-12-26-pre-optimization/mcp-servers.txt \
        ~/mcp-optimization-baselines/2025-12-26-post-priority1/mcp-servers.txt

# Expected: 10-30% reduction in memory usage
```

### Success Criteria
- [ ] home-manager rebuilt successfully
- [ ] NixOS rebuilt successfully
- [ ] jemalloc verified in all Node.js servers
- [ ] THP set to madvise
- [ ] V8 tuning active
- [ ] Monitoring scripts functional
- [ ] Memory usage reduced by 10-30%

### Rollback Plan
If any issues occur:
1. Revert Git commits
2. Rebuild (home-manager or NixOS)
3. Restart MCP servers
4. Verify system returns to baseline

---

## Phase 2: Monitoring & Measurement (Weeks 53-1, 1-2 weeks)

**Goal:** Validate Priority 1 improvements and identify bottlenecks

**Duration:** 1-2 weeks (passive monitoring)

### Step 2.1: Enable Periodic Monitoring (Optional)

```bash
# Enable timers
systemctl --user enable --now mcp-monitor.timer
systemctl --user enable --now gpu-monitor.timer

# Verify timers
systemctl --user list-timers | grep mcp

# Check logs
journalctl --user -u mcp-monitor.service -f
```

### Step 2.2: Manual Monitoring Schedule

**Week 1:**
- Day 1: Immediately after deployment
- Day 3: Mid-week check
- Day 7: End of week summary

**Week 2:**
- Day 14: Final assessment

### Step 2.3: Metrics to Track

**Memory:**
- Total memory usage (all MCP servers)
- Per-server memory usage
- Memory fragmentation (jemalloc benefit)
- OOM events (should be zero)

**Performance:**
- Request latency (mean, p95, p99)
- Latency variance (should decrease)
- Throughput (requests/second)
- GC pause frequency

**GPU:**
- VRAM usage (should be stable ~1.1GB)
- GPU utilization (should be 30-40%)
- Temperature
- Power draw

### Step 2.4: Document Findings

```bash
# Create analysis document
cat > ~/mcp-optimization-baselines/priority1-analysis.md <<'EOF'
# Priority 1 Optimization Analysis

## Memory Reduction
- Before: [insert baseline]
- After: [insert post-deployment]
- Reduction: [calculate percentage]

## Latency Improvement
- Before variance: [baseline]
- After variance: [post-deployment]
- Improvement: [calculate percentage]

## Throughput
- Before: [baseline req/s]
- After: [post-deployment req/s]
- Improvement: [calculate percentage]

## Issues Encountered
[List any problems]

## Recommendations
[Next steps based on data]
EOF
```

### Success Criteria
- [ ] 10-30% memory reduction confirmed
- [ ] <10% latency variance achieved
- [ ] 11-45% throughput improvement measured
- [ ] No OOM events
- [ ] No performance regressions

---

## Phase 3: Optional Connection Pooling (Weeks 2-4)

**Goal:** Implement 10-80x throughput improvement for high-traffic servers

**Duration:** 12-16 hours over 2-3 weeks

**Decision Point:** Only proceed if:
- Current throughput insufficient for workload
- High-frequency MCP requests identified
- Willing to invest 12-16 hours

### Phase 3A: firecrawl Connection Pooling (Week 2)

**Priority:** HIGH
**Effort:** 6-8 hours
**Impact:** 10-20x throughput (2-5 → 50-100 req/s)

#### Implementation Steps

1. **Read Implementation Template**
   ```bash
   # Review template
   cat ~/docs/researches/2025-12-26_MCP_POOLING_IMPLEMENTATION_TEMPLATES.md | grep -A 100 "firecrawl"
   ```

2. **Modify firecrawl Package**
   ```bash
   cd ~/.config/home-manager/mcp-servers

   # Follow template exactly
   # Add generic-pool dependency
   # Implement connection pooling layer
   # Update wrapper configuration
   ```

3. **Test & Benchmark**
   ```bash
   # Baseline (current)
   time firecrawl-benchmark.sh

   # With pooling
   time firecrawl-benchmark-pooled.sh

   # Compare results
   ```

4. **Deploy**
   ```bash
   home-manager switch
   systemctl --user restart mcp-firecrawl*
   ```

#### Success Criteria
- [ ] 10-20x throughput improvement
- [ ] Memory overhead <200MB
- [ ] No connection leaks
- [ ] Graceful degradation on errors

### Phase 3B: exa Connection Pooling (Week 3)

**Priority:** MEDIUM
**Effort:** 3-4 hours
**Impact:** 10-20x throughput (5-10 → 100-200 req/s)

Same steps as Phase 3A, but for exa server.

### Phase 3C: context7 Connection Pooling (Week 4)

**Priority:** LOW
**Effort:** 3-4 hours
**Impact:** 10-20x throughput (10-20 → 200-400 req/s)

Same steps as Phase 3A, but for context7 server.

### Phase 3 Success Criteria
- [ ] All target servers implemented
- [ ] 10-80x throughput confirmed
- [ ] Memory overhead <2%
- [ ] No regressions in latency
- [ ] Production stability verified

---

## Phase 4: Advanced Optimizations (Months 1-3, Optional)

**Goal:** Research-driven optimizations based on real-world usage

**Decision Point:** Only if specific needs identified

### Potential Areas

#### 4A: FP16 on Hardware Upgrade
**Trigger:** Upgrade to RTX 3060+ GPU
**Effort:** 4-8 hours
**Impact:** 2-4x speedup for embeddings
**Reference:** `docs/tools/ck/FP16_QUICK_REFERENCE.md`

#### 4B: INT8 Quantization
**Trigger:** VRAM constraint or multi-model usage
**Effort:** 8-16 hours
**Impact:** 75% VRAM reduction
**Trade-off:** Potential accuracy loss

#### 4C: Vector Database Integration
**Trigger:** Need for persistent semantic search cache
**Effort:** 40+ hours
**Impact:** Faster lookups, cross-session caching
**Options:** Milvus (GPU), Weaviate, Qdrant

#### 4D: Custom Semantic MCP Server
**Trigger:** Frequent semantic search workload
**Effort:** 40-80 hours
**Impact:** Reusable, local, GPU-accelerated search
**Benefit:** Privacy, customization

---

## Decision Framework

### When to Implement Connection Pooling

**Implement if:**
- MCP requests > 50/minute per server
- Latency increases under load
- Throughput is a bottleneck
- Willing to invest 12-16 hours

**Skip if:**
- Current performance acceptable
- Low request frequency (<10/minute)
- Other priorities higher
- Want to minimize complexity

### When to Pursue Advanced Optimizations

**Implement if:**
- Specific, measurable problem identified
- ROI justifies effort (hours vs benefit)
- Solution directly addresses bottleneck
- Resources available for maintenance

**Skip if:**
- Premature optimization
- No clear metrics showing need
- Complexity outweighs benefit
- Other work more valuable

---

## Rollback Procedures

### Home-Manager Rollback
```bash
cd ~/.config/home-manager
git log --oneline -10
git revert <commit-hash>
home-manager switch
```

### NixOS Rollback
```bash
cd /etc/nixos
git log --oneline -10
git revert <commit-hash>
sudo nixos-rebuild switch

# Or use NixOS generations
sudo nixos-rebuild switch --rollback
```

### Individual Server Rollback
```bash
# Disable specific optimization
systemctl --user stop mcp-<server>*
# Edit config, remove optimization
home-manager switch
```

---

## Success Metrics by Phase

| Phase | Metric | Target | Actual |
|-------|--------|--------|--------|
| **Phase 1** | Memory reduction | 10-30% | _____ |
| | Latency variance | <10% | _____ |
| | Throughput | +11-45% | _____ |
| **Phase 2** | Monitoring uptime | 99%+ | _____ |
| | Metrics quality | Complete | _____ |
| **Phase 3** | firecrawl throughput | 10-20x | _____ |
| | exa throughput | 10-20x | _____ |
| | context7 throughput | 10-20x | _____ |

---

## Timeline Summary

```
Week 52 (Dec 2025):
├── Days 1-2: Pre-deployment validation
├── Days 3-4: Deploy Priority 1
└── Days 5-7: Initial monitoring

Week 53 - Week 1 (Jan 2026):
└── Passive monitoring & measurement

Week 2-4 (Optional):
├── Week 2: firecrawl pooling (if needed)
├── Week 3: exa pooling (if needed)
└── Week 4: context7 pooling (if needed)

Months 1-3 (Optional):
└── Advanced optimizations (as needed)
```

---

## Checkpoint Questions

### After Phase 1 Deployment
- [ ] Are all optimizations active?
- [ ] Is performance improved?
- [ ] Any regressions observed?
- [ ] Monitoring working correctly?

### After Phase 2 Monitoring
- [ ] Do metrics confirm improvements?
- [ ] Are there unexpected bottlenecks?
- [ ] Is throughput sufficient?
- [ ] Should we proceed to Phase 3?

### After Phase 3 (If Implemented)
- [ ] Is 10-80x throughput achieved?
- [ ] Is system stable under load?
- [ ] Was effort worth the benefit?
- [ ] Are there new bottlenecks?

---

## Contact Points for Help

### Documentation References
- Main guide: `docs/MCP_OPTIMIZATION_GUIDE.md`
- Monitoring guide: `docs/MCP_MONITORING_GUIDE.md`
- Templates: `docs/researches/*_TEMPLATES.md`

### Troubleshooting Guides
- GPU issues: `docs/tools/ck/ONNX_GPU_SUPPORT_SUMMARY.md`
- FP16 questions: `docs/tools/ck/FP16_QUICK_REFERENCE.md`
- Pooling issues: `docs/researches/MCP_POOLING_IMPLEMENTATION_TEMPLATES.md`

### External Resources
- MCP Protocol: https://modelcontextprotocol.io/
- jemalloc docs: https://jemalloc.net/
- ONNX Runtime: https://onnxruntime.ai/
- generic-pool: https://github.com/coopernurse/node-pool

---

**End of Implementation Roadmap**
