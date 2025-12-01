# ADR-008: Automated Jobs via Home-Manager

**Status:** ✅ Accepted
**Date:** 2025-12-01
**Author:** Mitsio
**Context:** Standardizing automated job management for user-level tasks

---

## Context and Problem Statement

Automated jobs (scheduled tasks, timers, recurring operations) for user-level tasks are currently managed through multiple systems:

1. **Home-Manager:** Some jobs via `systemd.user.timers` and `systemd.user.services`
2. **NixOS System:** Some user jobs incorrectly placed in system-level `systemd.timers`
3. **Cron:** Traditional cron jobs in user crontab
4. **Ansible:** Some recurring tasks via ansible playbooks (e.g., rclone sync)
5. **Manual scripts:** Shell scripts with cron or at-boot execution

This fragmentation creates issues:
- **Inconsistency:** Unclear which system manages which job
- **Poor visibility:** Can't see all automated jobs in one place
- **No dependency tracking:** Jobs might run before dependencies are met
- **Difficult testing:** Each system has different testing/dry-run mechanisms
- **Version control gaps:** Some jobs not tracked in git
- **No rollback support:** Changes to cron/manual scripts aren't versioned

**Question:** Where should ALL user-level automated jobs be managed?

---

## Decision

**ALL automated jobs for user-level tasks MUST be managed via Home-Manager using systemd user timers and services.**

Automated jobs will be declared in Home-Manager using:

1. **Systemd user timers** (preferred method):
   ```nix
   systemd.user.timers.my-job = {
     Unit.Description = "My recurring job";
     Timer = {
       OnCalendar = "hourly";
       Persistent = true;
     };
     Install.WantedBy = [ "timers.target" ];
   };

   systemd.user.services.my-job = {
     Unit.Description = "My job service";
     Service = {
       Type = "oneshot";
       ExecStart = "${pkgs.bash}/bin/bash /path/to/script.sh";
     };
   };
   ```

2. **Home-manager activation scripts** (for one-time setup tasks):
   ```nix
   home.activation.my-setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
     # One-time setup task
   '';
   ```

**The following are PROHIBITED for user-level jobs:**
- ❌ Cron/crontab (unless external requirement demands it)
- ❌ NixOS system-level timers for user tasks
- ❌ Manual at/batch jobs
- ❌ Standalone scripts without orchestration

**Ansible playbooks are ALLOWED** for job logic (what to do), but **timer/scheduler MUST be home-manager** (when to do it).

---

## Rationale

### Why Home-Manager for Automated Jobs?

#### 1. **Declarative Job Management**
```nix
# Clear, version-controlled job declaration
systemd.user.timers.backup = {
  Timer.OnCalendar = "daily";
  Timer.Persistent = true;
};
```

vs.

```bash
# Crontab: imperative, harder to audit
0 0 * * * /home/user/scripts/backup.sh
```

#### 2. **Dependency Tracking**
```nix
# Home-Manager ensures dependencies exist
systemd.user.services.rclone-sync = {
  Service = {
    ExecStart = "${pkgs.rclone}/bin/rclone sync ...";
    # Requires: pkgs.rclone installed
  };
};
```

vs.

```bash
# Cron: Might run before rclone installed
0 * * * * rclone sync ...  # Fails if rclone not in PATH
```

#### 3. **Single Source of Truth**
```bash
# All jobs in one place
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
grep -r "systemd.user.timers" *.nix

# Shows all automated jobs
```

#### 4. **Version Control & Rollback**
```bash
# Rollback to previous job configuration
home-manager generations
/nix/store/.../activate  # Previous generation

# vs. Cron: No rollback, manual undo
```

#### 5. **Conditional Jobs**
```nix
# Example: Only run backup on main desktop
systemd.user.timers.backup.enable =
  config.networking.hostName == "shoshin";

# Example: Only run if rclone configured
systemd.user.services.rclone-sync.enable =
  config.programs.rclone.enable;
```

#### 6. **Better Logging & Monitoring**
```bash
# Systemd: Built-in logging
journalctl --user -u my-job.service -f

# List all user timers
systemctl --user list-timers

# vs. Cron: Must manually redirect to logfile
0 * * * * /script.sh >> /var/log/script.log 2>&1
```

#### 7. **Consistency with Architecture**
- Per ADR-001: Home-Manager manages user packages
- Per ADR-003: Home-Manager orchestrates user environment
- Per ADR-007: Home-Manager manages autostart
- Logical extension: **Home-Manager manages all user automation**

### Why Systemd User Timers over Cron?

| Feature | Systemd Timers | Cron |
|---------|----------------|------|
| **Declarative** | ✅ Nix expressions | ❌ Imperative entries |
| **Dependencies** | ✅ Can require services/units | ❌ No dependency tracking |
| **Logging** | ✅ journalctl integration | ❌ Manual log redirection |
| **Monitoring** | ✅ `systemctl --user list-timers` | ⚠️ `crontab -l` (static) |
| **Missed runs** | ✅ Persistent=true catches up | ⚠️ Skipped if system off |
| **Rollback** | ✅ Via home-manager generations | ❌ Manual undo |
| **Version control** | ✅ Nix config in git | ⚠️ Can commit crontab, but awkward |
| **Testing** | ✅ `systemctl --user start job.service` | ⚠️ Must wait or manually invoke |

**Verdict:** Systemd timers are superior for declarative, version-controlled, dependency-aware automation.

---

## Consequences

### Positive

✅ **Single source of truth:** All jobs in home-manager repo
✅ **Declarative:** Version-controlled job configuration
✅ **Dependency-aware:** Jobs can't run if dependencies missing
✅ **Better logging:** journalctl for all jobs
✅ **Rollback support:** home-manager generations
✅ **Conditional logic:** Per-machine or per-condition jobs
✅ **Monitoring:** `systemctl --user list-timers` shows all jobs
✅ **Persistent:** Catch up on missed runs (if configured)
✅ **Type-safe:** Nix catches config errors before apply

### Negative

⚠️ **Migration effort:** Must port existing cron/manual jobs to systemd
⚠️ **Learning curve:** Need to understand systemd timer syntax
⚠️ **More verbose:** Systemd timers require more lines than cron
⚠️ **User-specific:** Systemd user timers require user login session (mitigated by `loginctl enable-linger`)

### Neutral

ℹ️ **Ansible for logic allowed:** Ansible playbooks can implement job logic, home-manager calls them
ℹ️ **System jobs separate:** System-level jobs (NixOS) remain in system config
ℹ️ **Calendar syntax different:** systemd OnCalendar vs cron syntax

---

## Migration Strategy

### Phase 1: Inventory Existing Jobs

**Cron jobs:**
```bash
crontab -l
```

**Systemd system timers (user jobs incorrectly placed here):**
```bash
sudo systemctl list-timers
# Look for