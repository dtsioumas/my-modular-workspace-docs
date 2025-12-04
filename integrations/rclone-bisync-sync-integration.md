# RClone Bisync Sync Integration

**Created:** 2025-12-01
**Updated:** 2025-12-01 23:00 EET
**Status:** ✅ RESOLVED - Local-as-source-of-truth implemented
**Related:** `docs/TODO.md` Section 4.3

---

## Current Status

**✅ Working:**
- RClone installed via home-manager
- Systemd timer configured (30min interval, 1h timeout, 20% CPU)
- Ansible playbook for sync automation
- KeePassXC secret integration for rclone password
- **Local-as-source-of-truth conflict resolution** (implemented 2025-12-01)
- **.git directories excluded** (prevents 48+ git conflicts)

---

## Solution Implemented

### Problem Summary

The original bisync configuration had no conflict resolution strategy:
- Files changed on both sides created `.conflict1` and `.conflict2` versions
- Original files were **deleted** during conflict resolution
- 74 conflicts created in a single sync (including the playbook itself!)
- `.git` directories were syncing, causing massive conflicts

### Solution: `--conflict-resolve path1`

Added three key flags to `ansible/playbooks/rclone-gdrive-sync.yml`:

```yaml
rclone_bisync_options:
  - --compare size,modtime,checksum
  - --resilient
  - --recover
  - --create-empty-src-dirs
  - --conflict-resolve path1      # LOCAL (Path1) ALWAYS WINS
  - --conflict-loser num          # Keep numbered backups of remote versions
  - --conflict-suffix .remote-conflict  # Clear naming for remote conflicts
```

**How it works:**
- **`--conflict-resolve path1`**: When files differ on both sides, the local (Path1) version unconditionally wins
- **`--conflict-loser num`**: The remote version is renamed with `.remote-conflict1`, `.remote-conflict2`, etc.
- Original local file is **preserved** (never deleted on conflicts!)

### Exclusions Added

```yaml
exclude_patterns:
  # Version control - NEVER sync .git directories!
  - "**/.git/**"
  # Build artifacts and temp files
  - "**/node_modules/**"
  - "**/__pycache__/**"
  - "**/.cache/**"
  # Old conflict files (cleaned up manually)
  - "*.conflict1"
  - "*.conflict2"
```

---

## Research Findings

### Key Flags Discovered

| Flag | Purpose | Our Setting |
|------|---------|-------------|
| `--conflict-resolve` | Who wins on conflict | `path1` (local wins) |
| `--conflict-loser` | What happens to loser | `num` (numbered backups) |
| `--conflict-suffix` | Suffix for loser files | `.remote-conflict` |
| `--recover` | Recover from interruptions | Enabled (NOT about deleted files!) |

### Clarification: `--recover` Flag

**Misconception:** We thought `--recover` was causing deleted files to be "recovered" from remote.

**Reality:** `--recover` is about recovering bisync's **state** after interrupted runs, NOT about recovering deleted files. It keeps a backup listing to resume from interruptions.

### Why Deleted Files Were "Recovered"

This happens when using `--resync` on every run (which we don't do).

From rclone docs:
> "if you included `--resync` for every bisync run, it would never be possible to delete a file -- the deleted file would always keep reappearing"

Our playbook only uses `--resync` for initial setup, not regular runs - so this shouldn't be an issue.

---

## Configuration Files

### Ansible Playbook: `ansible/playbooks/rclone-gdrive-sync.yml`

**Key sections:**

```yaml
# SYNC JOB DEFINITIONS
rclone_sync_jobs:
  - name: myhome-bisync
    enabled: true
    local_path: "{{ ansible_user_dir }}/.MyHome/"
    remote: GoogleDrive-dtsioumas0:MyHome/
    max_delete: 50
    exclude_patterns:
      - "**/.git/**"           # Critical: Never sync git repos!
      - "**/node_modules/**"
      - "**/__pycache__/**"
      - "*.conflict1"
      - "*.conflict2"
      # ... more patterns

# BISYNC OPTIONS
rclone_bisync_options:
  - --compare size,modtime,checksum
  - --resilient
  - --recover
  - --create-empty-src-dirs
  - --conflict-resolve path1        # Local always wins
  - --conflict-loser num            # Keep numbered backups
  - --conflict-suffix .remote-conflict
```

### Systemd Service: `home-manager/rclone-gdrive.nix`

```nix
systemd.user.services.rclone-gdrive-sync = {
  Service = {
    Type = "oneshot";
    TimeoutStartSec = "1h";     # Kill after 1 hour (prevent runaway)
    CPUQuota = "20%";           # Prevent desktop freezing
    # ...
  };
};

systemd.user.timers.rclone-gdrive-sync = {
  Timer = {
    OnBootSec = "5min";
    OnUnitActiveSec = "30min";  # Every 30 minutes
    Persistent = true;
  };
};
```

---

## Usage

### Manual Sync (Dry-Run First)

```bash
# Always dry-run first to see what will happen
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --tags dry-run

# If dry-run looks good, run full sync
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml
```

### Check Timer Status

```bash
systemctl --user status rclone-gdrive-sync.timer
systemctl --user list-timers
```

### View Logs

```bash
# Today's log
cat ~/.cache/rclone/bisync-$(date +%Y-%m-%d).log

# Dry-run log
cat ~/.cache/rclone/bisync-dryrun-$(date +%Y-%m-%d).log
```

### Find Conflict Files

```bash
# Count conflicts
find ~/.MyHome -name "*.remote-conflict*" | wc -l

# List conflicts
find ~/.MyHome -name "*.remote-conflict*" -type f
```

---

## Conflict Resolution Process

### When Conflicts Occur

1. Local file and remote file both changed since last sync
2. Bisync detects the conflict
3. **Local file wins** (preserved as-is)
4. Remote version saved as `filename.remote-conflict1`
5. Both files synced to both sides

### Resolving Conflicts Manually

```bash
# View conflict
diff file.txt file.txt.remote-conflict1

# If local is correct, delete remote conflict
rm file.txt.remote-conflict1

# If remote is correct, replace local with remote
mv file.txt.remote-conflict1 file.txt
```

---

## Troubleshooting

### Problem: Too Many Conflicts

**Cause:** Long time between syncs, major changes on both sides

**Solution:**
1. Review conflicts: `find ~/.MyHome -name "*.remote-conflict*"`
2. Resolve them manually
3. If needed, run `--resync` once to reset state

### Problem: Deleted Files Reappearing

**Cause:** Using `--resync` on regular runs (not our case)

**Solution:**
- Never use `--resync` on regular runs
- Use playbook without `--tags resync`

### Problem: Desktop Freezing During Sync

**Cause:** High CPU usage

**Solution:** ✅ Already fixed
- `CPUQuota = "20%"` limits CPU usage
- `TimeoutStartSec = "1h"` kills runaway syncs

### Problem: Git Repository Conflicts

**Cause:** `.git` directories being synced

**Solution:** ✅ Already fixed
- Added `"**/.git/**"` to exclude patterns
- Git repos now sync cleanly

---

## Best Practices

1. **Always dry-run first** when testing changes
2. **Never use `--resync`** on regular runs
3. **Review conflicts** promptly - don't let them accumulate
4. **Keep .git excluded** - version control handles itself
5. **Monitor logs** periodically for issues
6. **Local is source of truth** - commit from this workspace

---

## Future Enhancements

- [ ] Real-time progress notifications (TODO.md Section 4.1)
- [ ] Conflict files in notifications (TODO.md Section 4.2)
- [ ] Health check playbook (docs/sync/monitoring.md)
- [ ] Android Syncthing integration

---

## Related Documentation

- **Ansible Playbook:** `ansible/playbooks/rclone-gdrive-sync.yml`
- **Home-Manager Config:** `home-manager/rclone-gdrive.nix`
- **ADR:** `docs/adrs/ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md`
- **TODO:** `docs/TODO.md` Section 4.3
- **Session Summary:** `sessions/summaries/2025-12-01_SESSION_SUMMARY_RCLONE_BISYNC_DISASTER.md`

---

**Author:** Dimitris Tsioumas
**Last Updated:** 2025-12-01 23:00 EET
