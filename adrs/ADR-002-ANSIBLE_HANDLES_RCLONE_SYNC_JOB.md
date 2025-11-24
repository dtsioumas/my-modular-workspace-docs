# ADR-001: Migrate RClone Automation from Bash Scripts to Ansible Playbooks

**Date:** 2025-11-22
**Status:** ✅ Accepted
**Deciders:** Μήτσο + Claude Code
**Project:** my-modular-workspace / home-manager

---

## Context

The rclone Google Drive bisync automation was initially implemented using bash scripts embedded in the home-manager Nix configuration (`rclone-gdrive.nix`). While functional, this approach has several limitations:

### Current Implementation (Bash Scripts)

**Components:**
- 4 bash scripts in `rclone-gdrive.nix`:
  1. `rclone-gdrive-sync.sh` - Main bisync execution
  2. `rclone-gdrive-status.sh` - Status reporting
  3. `rclone-gdrive-resync.sh` - Initial resync
  4. `rclone-gdrive-manual.sh` - Manual trigger

**Issues Identified:**
1. **Limited error handling:** Bash scripts have basic error checking
2. **No pre-flight checks:** Scripts don't verify prerequisites
3. **Poor observability:** Limited logging and status reporting
4. **No dry-run automation:** User must remember to dry-run first
5. **Notification limitations:** Desktop notifications are basic
6. **Difficult testing:** Bash scripts hard to test systematically
7. **No ARA integration:** Can't track execution history
8. **Maintenance burden:** Bash syntax errors harder to debug

### Triggering Event

On 2025-11-21, the rclone systemd service failed post-reboot with error:
```
env: 'bash': No such file or directory
```

**Root cause:** `#!/usr/bin/env bash` shebang doesn't work in systemd environment with minimal PATH.

**Fix:** Changed to `#!${pkgs.bash}/bin/bash` in all scripts.

**Realization:** If we're already maintaining complex bash scripts in Nix, why not use a better tool for automation?

### Requirements

Based on Nov 21-22 session work, we need:
- ✅ Automated dry-run before actual sync
- ✅ Conflict detection and reporting
- ✅ Pre-flight checks (directory existence, remote connectivity)
- ✅ Desktop notifications with detailed status
- ✅ Comprehensive logging with rotation
- ✅ Error handling with fallback procedures
- ✅ ARA integration for execution tracking
- ✅ Idempotent operations
- ✅ Easy testing and validation
- ✅ Clear separation of concerns

---

## Decision

**We will migrate all rclone automation from embedded bash scripts to Ansible playbooks.**

### Migration Strategy

#### Phase 1: Ansible Playbook Creation (Completed ✅)
- Created `ansible/playbooks/rclone-gdrive-sync.yml`
- Implemented all core features
- Tested dry-run mode successfully
- Status: 330+ lines, functional but has 34 ansible-lint violations

#### Phase 2: Ansible Integration with Home-Manager (Pending)
- Remove bash scripts from `rclone-gdrive.nix`
- Update systemd service to call Ansible playbook
- Configure logging directory via home-manager activation
- Update timer interval from 4 hours to 1 hour

#### Phase 3: Enhancement & Refinement (Pending)
- Fix all ansible-lint violations (34 issues)
- Enhance desktop notifications (conflict details, error preview)
- Implement log rotation via systemd-tmpfiles
- Add monitoring and alerting

#### Phase 4: Additional Playbooks (Future)
- Migrate `gdrive-backup.yml` to new standards
- Create troubleshooting playbooks
- Create maintenance playbooks (cleanup, verification)

---

## Rationale

### Why Ansible Over Bash?

#### 1. **Idempotent Operations**
- Ansible ensures consistent state regardless of execution count
- Bash scripts require manual state checking

#### 2. **Better Error Handling**
- `block/rescue` error handling with graceful degradation
- Clear error messages and recovery procedures
- Bash error handling is verbose and error-prone

#### 3. **Declarative Syntax**
- YAML is more readable than bash
- Easier to understand intent vs implementation
- Better for documentation

#### 4. **Built-in Features**
- Pre-flight checks (stat, assert modules)
- Logging (built-in log-level support)
- Notifications (notify-send module)
- Retries and timeouts
- Conditional execution

#### 5. **ARA Integration**
- Execution recording for troubleshooting
- Web UI for execution history
- Performance metrics
- Error tracking

#### 6. **Testing & Validation**
- Ansible-lint for static analysis
- Ansible molecule for integration testing
- Dry-run mode (--check)
- Diff mode (--diff)

#### 7. **Maintainability**
- Modular structure (tasks, handlers, vars)
- Reusable roles
- Template support
- Version control friendly (YAML vs embedded strings)

#### 8. **Community & Ecosystem**
- Extensive module library
- Active community support
- Best practices documentation
- Ansible Galaxy for role sharing

### Comparison Table

| Feature | Bash Scripts | Ansible Playbooks |
|---------|--------------|-------------------|
| Idempotency | Manual | Built-in |
| Error Handling | Complex | block/rescue |
| Dry-run | Manual implementation | --check flag |
| Pre-flight Checks | Manual | stat/assert modules |
| Logging | Manual tee/redirection | Built-in log-level |
| Notifications | Manual libnotify | notify-send module |
| Testing | Difficult | ansible-lint, molecule |
| ARA Integration | N/A | Native support |
| Readability | Low (bash syntax) | High (YAML) |
| Debugging | echo statements | -vvv verbosity |
| Maintenance | High effort | Lower effort |

---

## Consequences

### Positive

#### ✅ Improved Reliability
- Pre-flight checks catch issues before sync
- Better error handling prevents partial failures
- Dry-run automation prevents user errors

#### ✅ Better Observability
- Comprehensive logging with structured output
- ARA web UI for execution history
- Desktop notifications with detailed status
- Easy to trace what happened when things fail

#### ✅ Easier Maintenance
- YAML more maintainable than bash
- ansible-lint catches issues early
- Modular structure easier to extend
- Template support for reusable patterns

#### ✅ Enhanced Safety
- Automatic dry-run before sync
- Conflict detection with detailed reporting
- Max-delete limits enforced
- Resilient error recovery

#### ✅ Scalability
- Easy to add new playbooks for related tasks
- Reusable roles for common operations
- Can manage multiple remotes with same playbook
- Template-based configuration

### Negative

#### ❌ Additional Dependency
- Requires Ansible installation
- **Mitigation:** Already managed via home-manager (ansible package)

#### ❌ Learning Curve
- Ansible has its own syntax and concepts
- **Mitigation:** Well-documented, large community, similar to existing knowledge

#### ❌ Slightly Higher Resource Usage
- Ansible Python runtime vs bash
- **Mitigation:** Minimal impact, runs infrequently (every hour)

#### ❌ Debugging Differences
- Different debugging tools than bash
- **Mitigation:** Better overall tooling (-vvv, ARA, ansible-lint)

### Neutral

#### Initial Ansible Playbook Status
**Created:** `ansible/playbooks/rclone-gdrive-sync.yml` (330+ lines)

**Features Implemented:**
- ✅ Pre-flight checks (directory, remote connectivity)
- ✅ Automatic dry-run with conflict detection
- ✅ Actual sync with comprehensive logging
- ✅ Desktop notifications (success/failure)
- ✅ Block/rescue error handling
- ✅ Log rotation (keep last 30 logs)
- ✅ ARA-ready configuration

**Known Issues (34 ansible-lint violations):**
- 26 FQCN violations (need `ansible.builtin.*` prefix)
- 5 missing `changed_when: false` on commands
- 2 missing `set -o pipefail` in shell tasks
- 1 truthy value (`yes` → `true`)

**Status:** Functional, needs refinement

---

## Technical Details

### Sync Interval Decision

**Decision:** Change sync interval from **4 hours to 1 hour**

**Rationale:**
1. **More frequent backups:** Reduce risk of data loss
2. **Earlier conflict detection:** Catch conflicts sooner
3. **Less divergence:** Smaller diffs between syncs
4. **Better for active work:** More responsive to changes

**Trade-offs:**
- ✅ Pros: More backups, faster sync, smaller diffs
- ❌ Cons: More network usage, more frequent runs
- **Verdict:** Benefits outweigh costs (local network, Google Drive quota sufficient)

**Implementation:**
```nix
# home-manager/rclone-gdrive.nix
systemd.user.timers.rclone-gdrive-sync = {
  Timer = {
    OnBootSec = "5min";
    OnUnitActiveSec = "1h";  # Changed from "4h"
    Persistent = true;
    RandomizedDelaySec = "5min";
  };
};
```

### Systemd Service Integration

**Current (Bash):**
```nix
systemd.user.services.rclone-gdrive-sync = {
  Service = {
    Type = "oneshot";
    ExecStart = "${config.home.homeDirectory}/bin/rclone-gdrive-sync.sh";
  };
};
```

**Future (Ansible):**
```nix
systemd.user.services.rclone-gdrive-sync = {
  Service = {
    Type = "oneshot";
    WorkingDirectory = "${config.home.homeDirectory}/.MyHome/MySpaces/my-modular-workspace/ansible";
    ExecStart = "${pkgs.ansible}/bin/ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml";
  };
};
```

### Logging Strategy

**Current:** `~/.cache/rclone/bisync-*.log`
**Planned:** `~/.logs/ansible/rclone-gdrive-sync/`

**Rationale:**
- Centralized logging location
- Separate from cache (cache can be cleared)
- Per-job directories for organization
- Easier to find logs

**Log Rotation:**
```nix
# Via systemd-tmpfiles or logrotate
# Keep last 30 logs or 30 days
# Compress old logs
# Auto-cleanup on disk space issues
```

### Notification Enhancement

**Current (Basic):**
```bash
notify-send -i "cloud-upload" "rclone Bisync Complete" "Synced with Google Drive successfully"
```

**Planned (Detailed):**
```yaml
- name: Send notification with conflict details
  command: >
    notify-send
    -i "dialog-warning"
    "RClone Sync - Conflicts Detected"
    "Found {{ conflict_count }} conflicts:
    {% for file in conflict_files %}
    - {{ file }}
    {% endfor %}

    Log: {{ log_file }}"
```

**Features:**
- List conflict files in notification
- Show error preview for failures
- Include log file path
- Differentiate severity (info, warning, critical)

---

## Implementation Plan

### Phase 1: Ansible Playbook Creation ✅ DONE

**Completed 2025-11-21:**
- [x] Created `ansible/playbooks/rclone-gdrive-sync.yml`
- [x] Implemented pre-flight checks
- [x] Added automatic dry-run
- [x] Implemented conflict detection
- [x] Added desktop notifications
- [x] Configured logging
- [x] Added error handling
- [x] Tested dry-run mode

### Phase 2: Refinement & Integration 🚧 IN PROGRESS

**Priority: High**
1. **Fix ansible-lint violations** (34 issues)
   - Add FQCN prefixes (`ansible.builtin.*`)
   - Add `changed_when: false` to commands
   - Add `set -o pipefail` to shell tasks
   - Fix truthy values

2. **Create logging infrastructure**
   - home-manager activation to create `~/.logs/ansible/`
   - Configure permissions (user-only read/write)
   - Update playbook to use new location

3. **Update systemd service**
   - Change ExecStart to call Ansible playbook
   - Set working directory
   - Test service restart

4. **Update timer interval**
   - Change from 4 hours to 1 hour
   - Apply home-manager switch
   - Verify new schedule

### Phase 3: Enhancement 📋 PLANNED

**Priority: Medium**
5. **Enhance notifications**
   - Add conflict file list
   - Add error preview
   - Include log file path
   - Test notification appearance

6. **Implement log rotation**
   - Research best practices
   - Configure via systemd-tmpfiles
   - Test rotation mechanism

7. **Add monitoring**
   - Track sync success rate
   - Monitor conflict frequency
   - Alert on repeated failures

### Phase 4: Deprecation 🔮 FUTURE

**Priority: Low**
8. **Remove bash scripts**
   - Keep only if needed for manual operations
   - Document deprecation
   - Archive old scripts

9. **Migrate other automations**
   - `gdrive-backup.yml` to new standards
   - Create troubleshooting playbooks
   - Create maintenance playbooks

---

## Alternatives Considered

### Alternative 1: Keep Bash Scripts + Improve Them
**Rejected:** Would require significant effort to match Ansible's built-in features

**Pros:**
- No new dependencies
- Familiar syntax for simple tasks

**Cons:**
- No idempotency guarantees
- Limited error handling
- No ARA integration
- Harder to test
- Maintenance burden increases with complexity

### Alternative 2: Use systemd Units + Oneshot Services
**Rejected:** systemd is great for service management, not workflow automation

**Pros:**
- Native integration
- Well-understood

**Cons:**
- Limited logic capabilities
- No structured error handling
- No logging infrastructure
- Not designed for complex workflows

### Alternative 3: Custom Python/Go Script
**Rejected:** Reinventing the wheel, Ansible already solves this

**Pros:**
- Full control
- Custom tailored

**Cons:**
- Maintenance burden
- Need to implement logging, notifications, error handling
- No ARA equivalent
- Testing infrastructure needed
- Not worth the effort for this use case

### Alternative 4: Combination (Ansible + Bash)
**Considered:** Use Ansible for orchestration, bash for simple operations

**Status:** May revisit for specific edge cases

**Pros:**
- Best of both worlds
- Flexibility

**Cons:**
- Two languages to maintain
- Complexity increases
- Harder to debug

---

## Monitoring & Evaluation

### Success Criteria

#### Short-term (1 month)
- [ ] All ansible-lint violations fixed
- [ ] Systemd service using Ansible playbook
- [ ] Logging centralized to `~/.logs/ansible/`
- [ ] Timer interval updated to 1 hour
- [ ] Zero service failures
- [ ] Notifications working with details

#### Medium-term (3 months)
- [ ] No sync failures due to automation
- [ ] Conflict detection catching all cases
- [ ] ARA providing useful execution history
- [ ] Log rotation working correctly
- [ ] User satisfaction (Μήτσο happy!)

#### Long-term (6 months)
- [ ] All bash scripts deprecated
- [ ] Other automations migrated to Ansible
- [ ] Monitoring and alerting in place
- [ ] Ansible best practices followed
- [ ] Documentation comprehensive

### Rollback Plan

If Ansible automation fails catastrophically:

1. **Immediate:** Re-enable bash script systemd service
2. **Short-term:** Fix Ansible playbook issues
3. **Decision point:** After 2 failures, re-evaluate approach

**Rollback Command:**
```bash
# Edit rclone-gdrive.nix, change ExecStart back to bash script
home-manager switch --flake .#mitsio@shoshin
systemctl --user restart rclone-gdrive-sync.service
```

**Safety:** Bash scripts preserved in git history, can restore easily

---

## Related Documents

### Session Documentation
- **Session README:** `sessions/rclone-gdrive-sync-setup-week-47-2025/README.md`
- **Session Summary:** `sessions/rclone-gdrive-sync-setup-week-47-2025/SUMMARY_Part_1.md`
- **Session TODO:** `sessions/rclone-gdrive-sync-setup-week-47-2025/TODO.md`

### Architecture Documentation
- **RClone Setup Guide:** `docs/syncthing-gdrive-architecture/03-rclone-setup.md`
- **Current Setup:** `docs/syncthing-gdrive-architecture/00-CURRENT-SETUP.md`
- **Implementation Guide:** `docs/syncthing-gdrive-architecture/IMPLEMENTATION-COMPLETE.md`

### Configuration Files
- **Home-Manager Module:** `home-manager/rclone-gdrive.nix`
- **Ansible Playbook:** `ansible/playbooks/rclone-gdrive-sync.yml`
- **Navi Cheatsheet:** `dotfiles/dot_local/share/navi/cheats/rclone.cheat`

### Conflict & Troubleshooting
- **Conflict Review:** `~/RCLONE_CONFLICTS_REVIEW.md`

---

## Changelog

**2025-11-22:**
- Initial ADR created
- Documented bash-to-Ansible migration
- Documented 1-hour sync interval decision
- Outlined implementation plan

---

**Signed:**
- Μήτσο (User)
- Claude Code (Assistant)

**Status:** ✅ Accepted
**Next Review:** 2025-12-22 (1 month)
