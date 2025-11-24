# Ansible Automation - TODO List

**Project:** my-modular-workspace / ansible
**Created:** 2025-11-22
**Status:** Active Development

---

## 🔴 HIGH PRIORITY

### 1. RClone Collection Migration
**Goal:** Migrate from custom bash scripts to rolehippie/rclone Ansible collection

#### 1.1 Research & Planning
- [ ] **Research rolehippie/rclone collection**
  - [ ] Read GitHub documentation via MCP
    - Fetch README.md
    - Fetch docs/ directory
    - Fetch examples/
  - [ ] Check latest version and compatibility
  - [ ] Understand collection structure
  - [ ] Identify required roles and modules
  - [ ] Document findings in `ansible/docs/rclone/collection-overview.md`

- [ ] **Plan installation approach**
  - [ ] Option A: ansible-galaxy via home-manager activation
  - [ ] Option B: Nix package (if available)
  - [ ] Option C: Manual with version pinning
  - [ ] Document in `ansible/docs/rclone/installation-guide.md`

- [ ] **Create migration plan**
  - [ ] Map bash scripts to collection features
  - [ ] Identify gaps and workarounds
  - [ ] Plan testing strategy
  - [ ] Document in `ansible/docs/rclone/migration-plan.md`

#### 1.2 Installation
- [ ] **Install rolehippie/rclone collection**
  - [ ] Create requirements.yml
    ```yaml
    collections:
      - name: rolehippie.rclone
        version: ">=1.0.0"  # Check latest
    ```
  - [ ] Create/update home-manager/ansible-automation.nix
  - [ ] Add collection install to activation script
  - [ ] Verify installation: `ansible-galaxy collection list`
  - [ ] Test basic functionality
  - [ ] Document installed version

#### 1.3 Playbook Migration
- [ ] **Migrate rclone-gdrive-sync.yml**
  - [ ] Backup current playbook → `playbooks/backup/`
  - [ ] Study collection roles and modules
  - [ ] Refactor to use collection
  - [ ] Maintain safety features:
    - [ ] Dry-run capability
    - [ ] Conflict detection
    - [ ] Desktop notifications
    - [ ] Comprehensive logging
    - [ ] Error handling
  - [ ] Test in dry-run mode
  - [ ] Test actual sync
  - [ ] Compare with original playbook
  - [ ] Document changes

- [ ] **Migrate gdrive-backup.yml**
  - [ ] Investigate current failure
    - Read log: `/var/log/ansible/gdrive-backup-2025-11-21.log`
    - Diagnose root cause
    - Document issue
  - [ ] Refactor using collection
  - [ ] Update to centralized logging
  - [ ] Add error handling
  - [ ] Test monthly backup

#### 1.4 Integration
- [ ] **Update systemd service**
  - [ ] Modify rclone-gdrive.nix ExecStart
  - [ ] Test service restart
  - [ ] Monitor first automated run
  - [ ] Verify 1-hour timer works

- [ ] **Deprecate bash scripts**
  - [ ] Run for 1 week verification period
  - [ ] Remove from home-manager
  - [ ] Update documentation
  - [ ] Archive old scripts

---

### 2. Bash Scripts Migration (Detailed)
**Goal:** Convert all bash automation to Ansible playbooks

#### 2.1 rclone-gdrive-sync.sh → Ansible Playbook
- [ ] **Analyze current script**
  - [ ] Map all functions to Ansible tasks
  - [ ] Identify dependencies
  - [ ] Document script behavior

- [ ] **Create playbook structure**
  - [ ] Pre-flight checks → assert tasks
  - [ ] Directory creation → file module
  - [ ] Bisync execution → rclone module/role
  - [ ] Success notification → command/notify
  - [ ] Failure notification → rescue block
  - [ ] Log rotation → shell/file tasks

- [ ] **Test parity**
  - [ ] Compare outputs
  - [ ] Verify all features work
  - [ ] Check edge cases

#### 2.2 rclone-gdrive-status.sh → Status Playbook
- [ ] **Create status playbook**
  - [ ] Timer status check
  - [ ] Last sync timestamp
  - [ ] Recent logs summary
  - [ ] Conflict detection
  - [ ] Formatted output

- [ ] **Add to aliases**
  - Update bash aliases
  - Test command

#### 2.3 rclone-gdrive-resync.sh → Resync Playbook
- [ ] **Create resync playbook**
  - [ ] Interactive confirmation
  - [ ] --resync flag handling
  - [ ] Progress reporting
  - [ ] Success/failure notifications

- [ ] **Safety features**
  - [ ] Dry-run first
  - [ ] Backup check
  - [ ] Rollback plan

#### 2.4 rclone-gdrive-manual.sh → Manual Trigger
- [ ] **Replace with ansible-playbook call**
  - [ ] Update bash alias
  - [ ] Add log following
  - [ ] Test manual trigger

---

### 3. Documentation Organization
**Goal:** Centralize all Ansible documentation under ansible/docs/

#### 3.1 Directory Structure
- [ ] **Create docs/ structure**
  ```
  ansible/docs/
  ├── rclone/
  │   ├── collection-overview.md
  │   ├── installation-guide.md
  │   ├── migration-plan.md
  │   ├── best-practices.md
  │   └── examples/
  │       ├── basic-sync.yml
  │       ├── backup.yml
  │       └── status-check.yml
  ├── adr/
  │   ├── 001-bash-to-ansible-migration.md
  │   ├── 002-rclone-collection-adoption.md
  │   └── 003-centralized-logging.md
  ├── playbooks/
  │   ├── rclone-gdrive-sync.md
  │   ├── gdrive-backup.md
  │   └── health-check.md
  ├── development/
  │   ├── writing-playbooks.md
  │   ├── testing-guide.md
  │   └── linting-guide.md
  └── README.md
  ```

#### 3.2 Migrate Existing Docs
- [ ] **From home-manager/docs/**
  - [ ] Move `adr/001-migrate-rclone-automation-to-ansible.md`
    → `ansible/docs/adr/001-bash-to-ansible-migration.md`
  - [ ] Update references in other files

- [ ] **From docs/ (project root)**
  - [ ] Move `docs/syncthing-gdrive-architecture/03-rclone-setup.md`
    → `ansible/docs/rclone/original-setup.md`
  - [ ] Move `docs/syncthing-gdrive-architecture/04-systemd-automation.md`
    → `ansible/docs/rclone/systemd-integration.md`
  - [ ] Update cross-references

#### 3.3 Create New Documentation
- [ ] **ADRs**
  - [ ] 002-rclone-collection-adoption.md
    - Why using official collection
    - Benefits and trade-offs
    - Installation approach
  - [ ] 003-centralized-logging.md
    - Logging location rationale
    - Rotation strategy
    - Monitoring approach

- [ ] **Playbook docs**
  - [ ] rclone-gdrive-sync.md
    - Purpose and features
    - Usage examples
    - Troubleshooting
  - [ ] gdrive-backup.md
    - Backup strategy
    - Restore procedures
    - Scheduling

- [ ] **Development guides**
  - [ ] writing-playbooks.md
    - Best practices
    - Code style
    - Testing requirements
  - [ ] testing-guide.md
    - Manual testing
    - Automated testing (molecule)
    - CI/CD integration
  - [ ] linting-guide.md
    - ansible-lint setup
    - yamllint configuration
    - Pre-commit hooks

---

### 4. Logging Infrastructure
**Goal:** Centralized, rotated logging for all Ansible jobs

- [ ] **Create directory structure**
  - [ ] Add to home-manager activation
    ```nix
    home.activation.createAnsibleLogs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.logs/ansible/{rclone-gdrive-sync,gdrive-backup,health-check}
      chmod 700 $HOME/.logs/ansible
    '';
    ```

- [ ] **Update playbooks**
  - [ ] rclone-gdrive-sync.yml → `~/.logs/ansible/rclone-gdrive-sync/`
  - [ ] gdrive-backup.yml → `~/.logs/ansible/gdrive-backup/`

- [ ] **Implement log rotation**
  - [ ] Research systemd-tmpfiles vs logrotate
  - [ ] Choose rotation method
  - [ ] Configure 30-day retention
  - [ ] Test rotation
  - [ ] Document in `docs/logging-strategy.md`

- [ ] **Migrate existing logs**
  - [ ] Copy important logs from `~/.cache/rclone/`
  - [ ] Clean up cache directory

---

### 5. Automated Quality Checks
**Goal:** Automatic syntax, format, and lint checks for playbooks

#### 5.1 Pre-commit Hooks
- [ ] **Research pre-commit framework**
  - [ ] Web search for Ansible pre-commit hooks
  - [ ] Find best practices
  - [ ] Document findings

- [ ] **Create .pre-commit-config.yaml**
  ```yaml
  repos:
    - repo: https://github.com/ansible/ansible-lint
      rev: v6.22.0
      hooks:
        - id: ansible-lint
          files: \.(yaml|yml)$

    - repo: https://github.com/adrienverge/yamllint
      rev: v1.33.0
      hooks:
        - id: yamllint
          args: [-c=.yamllint]

    - repo: https://github.com/pre-commit/pre-commit-hooks
      rev: v4.5.0
      hooks:
        - id: check-yaml
        - id: end-of-file-fixer
        - id: trailing-whitespace
  ```

- [ ] **Configure yamllint**
  - [ ] Create .yamllint
  - [ ] Allow 100-char lines for commands
  - [ ] Configure other rules

- [ ] **Test hooks**
  - [ ] Install pre-commit
  - [ ] Test on playbooks
  - [ ] Document usage

#### 5.2 Make targets for CI
- [ ] **Create Makefile**
  ```makefile
  .PHONY: lint
  lint:
  	ansible-lint playbooks/
  	yamllint playbooks/

  .PHONY: syntax-check
  syntax-check:
  	ansible-playbook --syntax-check playbooks/*.yml

  .PHONY: test
  test: syntax-check lint
  ```

- [ ] **Document in README**

#### 5.3 Editor Integration
- [ ] **VSCodium integration**
  - [ ] Add ansible-lint extension
  - [ ] Configure workspace settings
  - [ ] Test in editor

---

## 🟡 MEDIUM PRIORITY

### 6. Health Checks & Monitoring
**Goal:** Automated weekly health checks for rclone setup

#### 6.1 Health Check Playbook
- [ ] **Create playbooks/health-check.yml**
  - [ ] Check rclone config validity
  - [ ] Test remote connectivity
  - [ ] Verify sync workdir integrity
  - [ ] Check for orphaned conflicts
  - [ ] Verify log files exist
  - [ ] Check disk space
  - [ ] Validate systemd timer status
  - [ ] Generate health report

- [ ] **Add to systemd timer**
  - [ ] Weekly schedule
  - [ ] Desktop notification with results
  - [ ] Email on failures (optional)

#### 6.2 Drive Health Checks
**Goal:** Daily automated checks for Google Drive issues

- [ ] **Research drive health tools**
  - [ ] Web search for rclone health check tools
  - [ ] Research `rclone check` command
  - [ ] Research `rclone lsf` for metadata
  - [ ] Find corruption detection tools
  - [ ] Document findings in `docs/rclone/health-tools.md`

- [ ] **Create playbooks/drive-health-check.yml**
  - [ ] Run `rclone check --one-way`
  - [ ] Detect file corruption
  - [ ] Find duplicate files
  - [ ] Check quota usage
  - [ ] Verify file counts
  - [ ] Compare checksums
  - [ ] Report issues found

- [ ] **Add daily systemd timer**
  - [ ] Schedule for 2am daily
  - [ ] Log results
  - [ ] Notify on errors only

#### 6.3 Sync Success/Failure Tracking
**Goal:** Track and visualize sync operations

- [ ] **Create sync tracking system**
  - [ ] Log each sync result to database/file
    ```yaml
    # ~/.logs/ansible/rclone-gdrive-sync/history.jsonl
    {"timestamp": "2025-11-22T20:00:00", "status": "success", "files_synced": 15, "conflicts": 0}
    {"timestamp": "2025-11-22T21:00:00", "status": "failed", "error": "connection timeout"}
    ```
  - [ ] Track:
    - Timestamp
    - Success/failure status
    - Files synced
    - Conflicts found
    - Error messages
    - Duration

- [ ] **Create visualization playbook**
  - [ ] Parse history.jsonl
  - [ ] Generate summary:
    - Success rate (last 24h, 7d, 30d)
    - Total syncs
    - Conflicts found
    - Error types
  - [ ] Output to console or HTML report

- [ ] **Conflict tracking**
  - [ ] Scan for .conflict* files
  - [ ] Track creation time
  - [ ] Notify if conflicts older than 7 days
  - [ ] Generate conflict report

#### 6.4 Navi Cheatsheets
**Goal:** Easy command reference for manual operations

- [ ] **Create dotfiles/dot_local/share/navi/cheats/ansible-rclone.cheat**
  ```
  % ansible, rclone, playbook

  # Run rclone sync (with dry-run first)
  ansible-playbook -i ansible/inventories/hosts ansible/playbooks/rclone-gdrive-sync.yml --tags dry-run
  ansible-playbook -i ansible/inventories/hosts ansible/playbooks/rclone-gdrive-sync.yml

  # Check sync status
  ansible-playbook -i ansible/inventories/hosts ansible/playbooks/rclone-status.yml

  # Run health check
  ansible-playbook -i ansible/inventories/hosts ansible/playbooks/health-check.yml

  # Check drive health
  ansible-playbook -i ansible/inventories/hosts ansible/playbooks/drive-health-check.yml

  # View sync history
  ansible-playbook -i ansible/inventories/hosts ansible/playbooks/sync-history.yml

  # Manual resync
  ansible-playbook -i ansible/inventories/hosts ansible/playbooks/rclone-resync.yml
  ```

- [ ] **Update existing rclone.cheat**
  - [ ] Add Ansible playbook commands
  - [ ] Keep legacy rclone commands
  - [ ] Add troubleshooting section

---

### 7. Enhanced Notifications
**Goal:** Rich desktop notifications with actionable information

- [ ] **Add conflict details to notifications**
  ```yaml
  - name: Send notification with conflicts
    ansible.builtin.command: >
      notify-send
      -i dialog-warning
      "RClone Sync - Conflicts Found"
      "{{ conflicts | length }} conflicts detected:
      {% for file in conflicts[:5] %}
      • {{ file }}
      {% endfor %}
      {% if conflicts|length > 5 %}
      ... and {{ conflicts|length - 5 }} more
      {% endif %}

      Log: {{ log_file }}"
    changed_when: false
  ```

- [ ] **Add error preview**
  - [ ] Extract last 5 error lines
  - [ ] Include in notification
  - [ ] Truncate long messages

- [ ] **Add log file path**
  - [ ] Always include in notifications
  - [ ] Make clickable (if possible)

---

### 8. Ansible Molecule Testing
**Goal:** Automated playbook testing framework

- [ ] **Research Ansible Molecule**
  - [ ] Read documentation
  - [ ] Understand workflow
  - [ ] Evaluate for our use case

- [ ] **Set up Molecule**
  - [ ] Install via home-manager
  - [ ] Create molecule/ directory
  - [ ] Configure scenarios

- [ ] **Write tests**
  - [ ] Test rclone-gdrive-sync.yml
  - [ ] Test health-check.yml
  - [ ] Test error handling

---

## 🟢 LOW PRIORITY

### 9. Advanced Features

#### 9.1 Conflict Resolution Helper
- [ ] **Create playbooks/resolve-conflicts.yml**
  - [ ] List all .conflict* files
  - [ ] Show file sizes and dates
  - [ ] Interactive resolution (if possible)
  - [ ] Generate diff reports

#### 9.2 Backup Verification
- [ ] **Create playbooks/verify-backup.yml**
  - [ ] Compare local vs remote checksums
  - [ ] Verify file counts
  - [ ] Check for missing files
  - [ ] Generate verification report

#### 9.3 Dashboard (Optional)
- [ ] **Create web dashboard**
  - [ ] Show sync history
  - [ ] Display maintenance status
  - [ ] Show error trends

---

### 10. System Maintenance & Health Monitoring

#### 10.1 Home-Manager Maintenance
- [ ] **Create playbooks/maintenance/home-manager-health.yml**
  - [ ] Check home-manager state version compatibility
  - [ ] Verify activation scripts completed successfully
  - [ ] Check symlinks integrity (~/.config/, ~/.bashrc, etc.)
  - [ ] Verify systemd user services status
    ```yaml
    services_to_check:
      - vscode-extensions-update.service
      - claude-code-update.service
      - cline-update.service
      - rclone-gdrive-sync.service
      - keepassxc-vault-sync.service
    ```
  - [ ] Check flake.lock freshness (warn if >30 days old)
  - [ ] Validate no broken Nix store references
  - [ ] Log to `~/.logs/maintenance/home-manager-health.log`
  - [ ] Desktop notification with status summary
  - [ ] Schedule: Weekly via systemd timer (Sunday 09:00)

- [ ] **Create playbooks/maintenance/home-manager-errors.yml**
  - [ ] Scan journalctl for home-manager activation errors
  - [ ] Check for failed systemd user services
  - [ ] Parse ~/.xsession-errors for HM issues
  - [ ] Extract last 100 error/warning messages
  - [ ] Group errors by type/source
  - [ ] Log findings to `~/.logs/maintenance/hm-errors-YYYY-MM-DD.jsonl`
  - [ ] Desktop notification: "Found X home-manager issues"
  - [ ] Include log path in notification
  - [ ] Schedule: Daily via systemd timer (08:00)

#### 10.2 NixOS System Maintenance
- [ ] **Create playbooks/maintenance/nixos-health.yml**
  - [ ] Check /etc/nixos/ git status (uncommitted changes?)
  - [ ] Verify current system generation
  - [ ] Check for failed systemd services (system-level)
  - [ ] Verify boot loader entries
  - [ ] Check disk space on / and /nix/store
  - [ ] Warn if /nix/store > 80% full
  - [ ] Validate no orphaned Nix profiles
  - [ ] Scan dmesg for critical errors
  - [ ] Log to `/var/log/maintenance/nixos-health.log`
  - [ ] Desktop notification with system health
  - [ ] Schedule: Weekly via systemd timer (Sunday 10:00)

- [ ] **Create playbooks/maintenance/nixos-errors.yml**
  - [ ] Scan journalctl --system for errors (err, crit, alert, emerg)
  - [ ] Parse dmesg for hardware errors
  - [ ] Check systemd failed units: `systemctl --failed`
  - [ ] Scan /var/log/nixos/ for build failures
  - [ ] Extract kernel panic messages
  - [ ] Group errors by subsystem (disk, network, GPU, etc.)
  - [ ] Log findings to `/var/log/maintenance/nixos-errors-YYYY-MM-DD.jsonl`
  - [ ] Desktop notification: "Found X system issues"
  - [ ] Schedule: Daily via systemd timer (08:05)

#### 10.3 Google Drive Health & Conflict Monitoring
- [ ] **Research gdrive health check tools** (HIGH PRIORITY)
  - [ ] **Web research:** Tools to detect:
    - Corrupted files in Google Drive
    - Orphaned files (no parent folder)
    - Duplicate files (same name, different content)
    - Quota issues and usage patterns
    - Checksum mismatches
  - [ ] **Research rclone commands:**
    - `rclone check` vs `rclone cryptcheck` (which is better?)
    - `rclone dedupe` modes and usage
    - `rclone size` for quota monitoring
    - `rclone lsjson` for metadata analysis
    - `rclone tree` for structure verification
  - [ ] **Document findings:**
    - Create `ansible/docs/rclone/health-checks.md`
    - Document command examples with outputs
    - List best practices for gdrive health
    - Include troubleshooting guide

- [ ] **Create playbooks/maintenance/gdrive-health.yml**
  - [ ] Run `rclone check --one-way local remote` (detect differences)
  - [ ] Run `rclone check --download remote local` (verify checksums)
  - [ ] Detect file corruption (checksum mismatches)
  - [ ] Find duplicates: `rclone dedupe --dedupe-mode list`
  - [ ] Check quota: `rclone about GoogleDrive-dtsioumas0:`
  - [ ] Count files per directory (detect anomalies)
  - [ ] Measure total sync size
  - [ ] Compare with expected baseline
  - [ ] Log results to `~/.logs/maintenance/gdrive-health-YYYY-MM-DD.jsonl`
  - [ ] Format:
    ```json
    {
      "timestamp": "2025-11-23T09:00:00Z",
      "check_type": "checksum",
      "mismatches": 0,
      "duplicates": 5,
      "quota_used_gb": 15.3,
      "quota_total_gb": 100,
      "file_count": 12847,
      "issues": []
    }
    ```
  - [ ] Desktop notification with results summary
  - [ ] Schedule: Daily via systemd timer (09:00)

- [ ] **Create playbooks/maintenance/gdrive-conflicts.yml**
  - [ ] Find all `.conflictN` files in bisync workdir
  - [ ] Find all "conflicted copy" files in Google Drive
  - [ ] List all `.conflict` files in local sync directory
  - [ ] Parse conflict file naming patterns
  - [ ] Analyze conflict age (days since creation)
  - [ ] Group conflicts by:
    - File type (.md, .json, .txt, etc.)
    - Directory (which folder has most conflicts?)
    - Age (new vs old conflicts)
  - [ ] Generate resolution recommendations based on:
    - File size difference
    - Modification time difference
    - Content similarity (if text files)
  - [ ] Log to `~/.logs/maintenance/gdrive-conflicts-YYYY-MM-DD.jsonl`
  - [ ] Format:
    ```json
    {
      "timestamp": "2025-11-23T09:15:00Z",
      "total_conflicts": 10,
      "by_type": {
        "workspace.json": 8,
        "keepass_backup.kdbx": 2
      },
      "oldest_conflict_days": 15,
      "newest_conflict_days": 1,
      "recommendations": [
        {
          "file": ".MyHome/Obsidian/workspace.json.conflict7",
          "action": "delete",
          "reason": "Current file is newer and larger"
        }
      ]
    }
    ```
  - [ ] Desktop notification:
    - Title: "Google Drive Conflicts Detected"
    - Body: "Found X conflicts. Oldest: Y days, Newest: Z days"
    - Actions: "View Log", "Resolve Now"
  - [ ] Include navi cheat reference for manual resolution
  - [ ] Schedule: Daily via systemd timer (09:15, after health check)

- [ ] **Create playbooks/maintenance/bisync-integrity.yml**
  - [ ] Verify bisync database is not corrupted
  - [ ] Check for stale locks:
    ```bash
    find ~/.cache/rclone/bisync-workdir -name "*.lck" -mtime +1
    ```
  - [ ] Validate listings are consistent
  - [ ] Check for RCLONE_TEST artifacts
  - [ ] Verify workdir size (shouldn't grow indefinitely)
  - [ ] Check last successful sync timestamp
  - [ ] Warn if last sync > 2 hours ago
  - [ ] Notify if resync required
  - [ ] Log to `~/.logs/maintenance/bisync-integrity.log`
  - [ ] Schedule: Weekly via systemd timer (Sunday 09:30)

#### 10.4 Maintenance Dashboard & Reporting
- [ ] **Create playbooks/maintenance/generate-report.yml**
  - [ ] Parse all `~/.logs/maintenance/*.jsonl` files
  - [ ] Parse all `/var/log/maintenance/*.jsonl` files (requires sudo)
  - [ ] Generate weekly health report:
    ```
    === System Health Report (Week 47, 2025) ===

    Home-Manager: ✓ HEALTHY
      - All services running
      - No activation errors
      - Flake.lock age: 5 days

    NixOS: ⚠ WARNING
      - 2 failed systemd units
      - /nix/store at 85% capacity
      - See /var/log/maintenance/ for details

    Google Drive: ✓ HEALTHY
      - 10 conflicts detected (down from 15 last week)
      - Quota: 15.3GB / 100GB used
      - Last health check: 2025-11-23 09:00

    Trends:
      - System errors: ↓ 20% vs last week
      - Conflicts: ↓ 33% vs last week
      - Disk usage: ↑ 5GB vs last week
    ```
  - [ ] Show error trends (increasing/decreasing?)
  - [ ] Highlight critical issues
  - [ ] Include actionable recommendations
  - [ ] Output formats:
    - Plain text for terminal
    - Markdown for documentation
    - HTML for web dashboard (optional)
    - JSON for automation
  - [ ] Integrate with navi cheatsheet
  - [ ] Schedule: Weekly (Sunday 18:00)

#### 10.5 Log Management
- [ ] **Create playbooks/maintenance/rotate-logs.yml**
  - [ ] Rotate ~/.logs/maintenance/ (keep 90 days)
  - [ ] Rotate /var/log/maintenance/ (keep 180 days)
  - [ ] Compress old logs with gzip:
    ```bash
    find ~/.logs/maintenance -name "*.jsonl" -mtime +7 -exec gzip {} \;
    ```
  - [ ] Delete very old logs:
    ```bash
    find ~/.logs/maintenance -name "*.jsonl.gz" -mtime +90 -delete
    ```
  - [ ] Archive critical logs to Google Drive before deletion
  - [ ] Calculate total log space savings
  - [ ] Log rotation statistics
  - [ ] Desktop notification: "Log rotation complete. Freed X MB"
  - [ ] Schedule: Monthly (1st of month, 00:00)

#### 10.6 Notification System Standardization
- [ ] **Create notification template module**
  - [ ] Create `roles/desktop-notify/`
  - [ ] Standardize notification format:
    ```yaml
    - name: Send standardized notification
      ansible.builtin.command: >
        notify-send
        --icon={{ notification_icon }}
        --urgency={{ notification_urgency }}
        "{{ notification_title }}"
        "{{ notification_body }}"
    ```
  - [ ] Icon mapping:
    - Success: `emblem-checked` (green checkmark)
    - Warning: `dialog-warning` (yellow warning)
    - Error: `dialog-error` (red X)
    - Info: `emblem-information` (blue i)
  - [ ] Urgency levels:
    - low: Info, routine health checks
    - normal: Warnings, conflicts detected
    - critical: Errors, failed services
  - [ ] Include in all notifications:
    - Component name (Home-Manager, NixOS, GDrive)
    - Status (OK, WARNING, ERROR)
    - Brief details (e.g., "3 conflicts found")
    - Log file path
  - [ ] Add action buttons (KDE Plasma):
    ```bash
    notify-send --action="view=View Log" --action="dismiss=Dismiss"
    ```
  - [ ] Document notification best practices
  - [ ] Create examples in `docs/playbooks/notifications.md`

#### 10.7 Systemd Timer Integration
- [ ] **Create home-manager module for maintenance timers**
  - [ ] File: `home-manager/maintenance-timers.nix`
  - [ ] Define timers for:
    - home-manager-errors: Daily 08:00
    - gdrive-health: Daily 09:00
    - gdrive-conflicts: Daily 09:15
    - home-manager-health: Weekly Sunday 09:00
    - bisync-integrity: Weekly Sunday 09:30
    - generate-report: Weekly Sunday 18:00
    - rotate-logs: Monthly 1st 00:00
  - [ ] Add to home.nix imports
  - [ ] Test timer activation
  - [ ] Verify timers run correctly: `systemctl --user list-timers`
  - [ ] Display conflict status
  - [ ] Health check results
  - [ ] Drive statistics

---

## 📋 COMPLETED

_Tasks will be moved here as completed_

---

## 🔗 References

### External Resources
- **rolehippie/rclone:** https://github.com/rolehippie/rclone
- **Ansible Galaxy:** https://galaxy.ansible.com/rolehippie/rclone
- **Ansible Best Practices:** https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
- **ansible-lint:** https://ansible-lint.readthedocs.io/
- **yamllint:** https://yamllint.readthedocs.io/
- **Ansible Molecule:** https://molecule.readthedocs.io/

### Internal Docs
- **Session TODO:** `../sessions/rclone-gdrive-sync-setup-week-47-2025/TODO.md`
- **ADR:** `docs/adr/001-bash-to-ansible-migration.md`
- **Summaries:** `../sessions/rclone-gdrive-sync-setup-week-47-2025/SUMMARY_Part_*.md`

---

## 📍 Important Paths

```
ansible/
├── TODO.md                    # This file
├── playbooks/
│   ├── rclone-gdrive-sync.yml
│   ├── gdrive-backup.yml
│   ├── health-check.yml       # To create
│   ├── drive-health-check.yml # To create
│   ├── sync-history.yml       # To create
│   └── backup/                # Backups of old playbooks
├── docs/
│   ├── rclone/                # Collection docs
│   ├── adr/                   # Architecture decisions
│   ├── playbooks/             # Playbook documentation
│   ├── development/           # Dev guides
│   └── README.md
├── inventories/
│   └── hosts
├── ansible.cfg
├── requirements.yml           # To create
├── .pre-commit-config.yaml    # To create
├── .yamllint                  # To create
├── Makefile                   # To create
└── molecule/                  # To create (testing)
```

---

**Last Updated:** 2025-11-22
**Maintainer:** Μήτσο + Claude Code
