# rolehippie.rclone - Research & Evaluation

**Research Date:** 2025-11-24
**Version Evaluated:** v2.7.0
**Repository:** https://github.com/rolehippie/rclone
**Type:** Ansible Role (NOT Collection)
**License:** Apache-2.0

---

## VERDICT: NOT SUITABLE

**Recommendation:** DO NOT USE for our Google Drive bisync use case.

---

## Quick Summary

| Criteria | Our Requirement | Role Provides | Match |
|----------|-----------------|---------------|-------|
| Remote type | Google Drive OAuth | S3-compatible only | NO |
| Sync mode | Bisync (bidirectional) | One-way (via scripts) | NO |
| Scheduler | systemd user timers | cron (system-level) | NO |
| Installation | NixOS/home-manager | .deb package | NO |
| User context | User-level (~/) | Root (/root/) | NO |

---

## What rolehippie/rclone Actually Does

### 1. Installation
- Downloads rclone `.deb` from GitHub releases
- Installs via `apt` module (Debian/Ubuntu only)
- **Problem:** NixOS doesn't use .deb packages

### 2. Remote Configuration
- Only supports S3-compatible remotes with encryption
- Template generates config for S3 + crypt remotes
- Requires: `access_key`, `secret_key`, `endpoint`
- **Problem:** Google Drive uses OAuth, not S3 credentials

### 3. Backup Jobs
- Creates bash scripts in `/usr/bin/` (requires root)
- Schedules via cron (not systemd)
- Uses `cronic` wrapper for cron job execution
- **Problem:** We use systemd user timers in ~/.config/

### 4. Config Template (config.j2)
```ini
# Only generates S3-type remotes:
[{{ item.name }}]
type = s3
provider = {{ item.provider | default('Other') }}
endpoint = {{ item.endpoint }}
access_key_id = {{ item.access_key }}
secret_access_key = {{ item.secret_key }}

[{{ item.name }}-crypt]
type = crypt
remote = {{ item.name }}:{{ item.bucket }}
password = {{ item.primary_password }}
```

**No support for:**
- `type = drive` (Google Drive)
- OAuth tokens
- Service accounts
- Existing rclone.conf files

---

## Why It Doesn't Work For Us

### 1. NixOS Incompatibility
```yaml
# Role task (won't work on NixOS):
- name: Install upstream deb
  ansible.builtin.apt:
    deb: "{{ rclone_package }}"
```
We already have rclone via home-manager: `pkgs.rclone`

### 2. Google Drive Not Supported
Our `rclone.conf`:
```ini
[GoogleDrive-dtsioumas0]
type = drive
scope = drive
token = {"access_token":"...","token_type":"Bearer"...}
```
Role only supports S3-type with access_key/secret_key.

### 3. Root vs User Level
- Role: `/root/.config/rclone/rclone.conf`
- Ours: `~/.config/rclone/rclone.conf`
- Role: `/usr/bin/` scripts
- Ours: `~/bin/` scripts

### 4. Cron vs Systemd
- Role: Creates cron jobs via `ansible.builtin.cron`
- Ours: systemd user timers via home-manager

---

## Correct Approach

### Keep Custom Playbook
Our `rclone-gdrive-sync.yml` is the right approach because:
1. Uses existing rclone installation (NixOS package)
2. Uses existing rclone.conf (Google Drive OAuth)
3. Integrates with systemd user timers (home-manager)
4. Supports bisync (role doesn't)
5. User-level execution (not root)

### Playbook Structure (Current - KEEP)
```
ansible/
+-- playbooks/
    +-- rclone-gdrive-sync.yml    # Production-quality (0 lint errors)
    +-- rclone-gdrive-sync-v2.yml # Alternative version
    +-- gdrive-backup.yml         # Monthly backup (needs fixing)
```

---

## What We Learned

### From rolehippie/rclone
- Good variable structure for backup jobs
- Script template pattern (script.j2)
- Cron job creation with ansible.builtin.cron

### From Medium Article (scalably-sync)
- Sources/sinks pattern for multi-cloud sync
- Dynamic rclone config templating
- Provider-agnostic task structure

### Best Practices to Apply
1. **Variable-driven scripts** - Define sync jobs as variables
2. **Template-based scripts** - Use Jinja2 for script generation
3. **Modular tasks** - Separate tasks by concern

---

## Alternative: Improve Our Playbook

Instead of using rolehippie/rclone, enhance our existing playbook:

### 1. Add Variable-Driven Jobs
```yaml
vars:
  rclone_sync_jobs:
    - name: myhome-bisync
      local_path: "{{ ansible_user_dir }}/.MyHome/"
      remote: "GoogleDrive-dtsioumas0:MyHome/"
      workdir: "{{ ansible_user_dir }}/.cache/rclone/bisync-workdir/"
      schedule: "hourly"
      max_delete: 50
```

### 2. Use Templates for Scripts
Create `templates/bisync.sh.j2`:
```bash
#!/usr/bin/env bash
set -euo pipefail

rclone bisync \
  "{{ item.local_path }}" \
  "{{ item.remote }}" \
  --workdir "{{ item.workdir }}" \
  --max-delete {{ item.max_delete }} \
  --resilient --recover --verbose
```

### 3. Keep systemd Integration
Home-manager handles timers - playbook handles sync logic.

---

## Other Roles Evaluated

### stefangweichinger/ansible-rclone (178 stars - BEST alternative)

**Repository:** https://github.com/stefangweichinger/ansible-rclone

**Supports:**
- Google Drive OAuth configs
- Non-root user installation
- Custom binary/config locations
- systemd mount units
- Fedora, Arch, Debian, Ubuntu

**Example - Google Drive config:**
```yaml
rclone_configs:
  - name: GoogleDrive
    properties:
      type: drive
      client_id: 12345
      client_secret: 67890
      token: ' {"access_token":"...","token_type":"Bearer"...}'
```

**Still NOT suitable because:**
1. Downloads rclone binary (we have it via NixOS pkgs.rclone)
2. No native bisync support (only rclone mount)
3. systemd units for mounts, not sync timers
4. Would conflict with home-manager setup

### janikvonrotz/mint_system rclone role

**Repository:** Part of mint_system collection

**Features:**
- Cron-based sync jobs
- copy/sync commands
- Multiple providers

**NOT suitable:** No bisync, cron-based

### Comprehensive Comparison

| Criteria | rolehippie | stefangweichinger | Our Playbook |
|----------|------------|-------------------|--------------|
| Google Drive OAuth | NO | YES | YES |
| Bisync | NO | NO | YES |
| NixOS compatible | NO | PARTIAL | YES |
| User-level | NO | YES | YES |
| systemd timers | NO | mounts only | YES |
| Notifications | NO | NO | YES |
| Conflict detection | NO | NO | YES |

---

## Patterns to Adopt

From stefangweichinger/ansible-rclone:

### 1. Config variable structure
```yaml
rclone_sync_jobs:
  - name: myhome-bisync
    properties:
      local_path: "{{ ansible_user_dir }}/.MyHome/"
      remote: "GoogleDrive-dtsioumas0:MyHome/"
      max_delete: 50
```

### 2. Owner/permission pattern
```yaml
rclone_config_owner:
  OWNER: mitsio
  GROUP: users
```

### 3. Modular task structure
```
tasks/
├── main.yml
├── install.yml      # Skip for NixOS
├── configure.yml    # Config management
└── sync.yml         # Bisync logic
```

---

## References

- **rolehippie/rclone:** https://github.com/rolehippie/rclone
- **stefangweichinger/ansible-rclone:** https://github.com/stefangweichinger/ansible-rclone
- **scalably-sync (Medium):** https://github.com/afoley587/scalably-sync
- **rclone bisync:** https://rclone.org/bisync/

---

## Conclusion

The rolehippie/rclone role is designed for a different use case:
- Server-level backups to S3-compatible storage
- Debian/Ubuntu systems with apt
- Root-level cron jobs

Our use case requires:
- User-level Google Drive bisync
- NixOS with home-manager
- systemd user timers

**Action:** Keep and improve our custom playbook. Do not migrate to rolehippie/rclone.

---

**Last Updated:** 2025-11-24
**Author:** Mitsio + Claude Code
