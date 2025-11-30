# ADR-006: Reject rolehippie/rclone Ansible Collection

**Status:** ACCEPTED
**Date:** 2025-11-25
**Decider:** Dimitris Tsioumas (Mitsio)
**Related:** ADR-002, ADR-004

---

## Context

After successfully migrating rclone automation from bash scripts to Ansible playbooks (ADR-004), we considered using the official `rolehippie/rclone` Ansible collection instead of maintaining our custom playbook.

### Potential Benefits
- Official Ansible collection (maintained by community)
- Community support and contributions
- Best practices built-in
- Potentially better tested across different environments
- Standardized approach

### Research Conducted

**Research Session:** 2025-11-22 (Week 47)
**Session:** `sessions/sync-integration/rclone-gdrive-sync-setup-week-47-2025/`

**Sources Reviewed:**
- GitHub: https://github.com/rolehippie/rclone
- Ansible Galaxy: https://galaxy.ansible.com/rolehippie/rclone
- Collection documentation
- Role structure and examples
- Feature comparison with our requirements

---

## Decision

**We will NOT use the `rolehippie/rclone` Ansible collection.**

We will continue using our custom playbook at `ansible/playbooks/rclone-gdrive-sync.yml`.

---

## Reasons

### 1. No bisync Support

**Critical blocker:** The collection does not support `rclone bisync` command.

- Collection focuses on S3-compatible storage backends
- Designed for one-way sync operations
- No modules or roles for bidirectional sync
- Our entire workflow is built on `bisync` functionality

**Our requirement:**
```yaml
# We need this:
rclone bisync ~/.MyHome/ GoogleDrive:MyHome/ \
  --resilient --recover --conflict-resolve newer
```

**Collection provides:**
```yaml
# Collection offers this:
rclone sync source dest  # One-way only
```

### 2. Binary Download Approach

**Philosophy conflict:** Collection downloads rclone binary at runtime.

```yaml
# Collection approach:
- name: Download rclone binary
  get_url:
    url: "https://downloads.rclone.org/..."
    dest: /usr/local/bin/rclone
```

**Our approach:**
- Use NixOS package manager for deterministic builds
- Declarative system configuration
- Reproducible environments
- Version pinning via nixpkgs

**Why this matters:**
- NixOS philosophy: All binaries via Nix store
- Prevents drift between environments
- Ensures reproducibility
- Maintains system integrity

### 3. Limited Google Drive Support

**Target mismatch:** Collection designed for S3/Minio/Wasabi backends.

From collection README:
> "This role provides support for S3-compatible storage providers"

**Google Drive is not a primary target:**
- S3-specific configuration options
- No Google Drive-specific optimizations
- Missing `--drive-skip-gdocs` support
- No consideration for Google Drive quotas/limits

### 4. Custom Requirements Already Met

**Our custom playbook has:**

✅ **Desktop notifications**
```yaml
- name: Send success notification
  command: notify-send "Google Drive Sync" "Sync completed successfully"
```

✅ **Conflict detection logic**
```yaml
- name: Check for conflicts
  find:
    paths: "{{ local_path }}"
    patterns: "*.conflict*"
```

✅ **Integration with systemd timers**
```nix
systemd.user.timers.rclone-gdrive-sync = {
  Timer.OnCalendar = "hourly";
};
```

✅ **NixOS-specific paths and configuration**
```yaml
local_path: "{{ ansible_env.HOME }}/.MyHome/"
remote_path: "GoogleDrive-dtsioumas0:MyHome/"
```

✅ **Production-quality code:**
- 0 ansible-lint violations (production profile)
- 64% yamllint improvement (11 → 4 violations)
- Comprehensive error handling

### 5. Already Production-Quality

**Current state (as of 2025-11-25):**

```
Ansible Lint: ✅ PASS (0 violations, production profile)
YAML Lint:    ✅ ACCEPTABLE (4 minor violations)
Status:       ✅ Running successfully hourly
Reliability:  ✅ No failures in production
Features:     ✅ All requirements met
```

**No breaking changes needed** - System is stable and working.

---

## Consequences

### Positive

✅ **Full control over bisync workflow**
- Can customize for our specific use case
- No dependency on external collection updates
- Immediate bug fixes without waiting for upstream

✅ **Maintain NixOS integration**
- Consistent with system philosophy
- Declarative configuration throughout
- No external binary downloads

✅ **No breaking changes to working system**
- System already stable and tested
- Users familiar with current setup
- No migration needed

✅ **Custom features preserved**
- Desktop notifications continue to work
- Conflict detection remains
- NixOS-specific optimizations kept

### Negative

❌ **No community support for our playbook**
- We maintain the code ourselves
- No one to ask for help
- Must solve issues independently

❌ **We maintain the playbook ourselves**
- Must keep up with Ansible best practices
- Need to handle rclone API changes
- Responsibility for bugs and fixes

❌ **No community contributions**
- Miss out on improvements from others
- No shared knowledge base
- Limited external review

### Neutral

⚪ **We can still learn from collection best practices**
- Review their code for ideas
- Adopt patterns that make sense
- Contribute knowledge back if helpful

⚪ **Re-evaluate if collection adds bisync support**
- Monitor collection development
- Reconsider if bisync support added
- Could migrate later if beneficial

---

## Alternatives Considered

### Alternative 1: Fork the Collection
**Considered:** Fork `rolehippie/rclone` and add bisync support

**Rejected because:**
- Significant development effort
- Would need to maintain fork long-term
- Simpler to maintain standalone playbook
- Fork would diverge from upstream

### Alternative 2: Contribute bisync Support Upstream
**Considered:** Add bisync support to official collection

**Rejected because:**
- Large scope change (S3 focus → Google Drive)
- Uncertain acceptance by maintainers
- Would delay our implementation
- Our use case may be too specific

### Alternative 3: Use Collection + Custom Wrapper
**Considered:** Use collection for basics, wrap for bisync

**Rejected because:**
- Adds unnecessary complexity
- Collection doesn't help if we wrap everything
- Simpler to maintain single playbook

---

## Implementation

No changes required. Continue with current implementation:

**Playbook:** `ansible/playbooks/rclone-gdrive-sync.yml`
**Schedule:** Hourly via systemd timer
**Maintained by:** Mitsos

**Quality Standards:**
- Run `make check` before commits
- Keep ansible-lint violations at 0
- Maintain yamllint compliance
- Test major changes manually first

---

## Review

**Next Review:** 2026-06-01 (6 months)

**Review Criteria:**
- Has `rolehippie/rclone` added bisync support?
- Have our requirements changed?
- Is custom playbook still maintainable?
- Are there other collections worth evaluating?

---

## References

### Related ADRs
- [ADR-002: Ansible handles rclone sync job](ADR-002-ANSIBLE_HANDLES_RCLONE_SYNC_JOB.md)
- [ADR-004: Migrate rclone automation to Ansible](ADR-004-MIGRATE_RCLONE_AUTOMATION_TO_ANSIBLE.md)

### Research Session
- Session: `sessions/sync-integration/rclone-gdrive-sync-setup-week-47-2025/`
- TODO: Section 1 (RClone Ansible Collection Migration)
- Date: 2025-11-22

### External Links
- Collection: https://github.com/rolehippie/rclone
- Ansible Galaxy: https://galaxy.ansible.com/rolehippie/rclone
- rclone bisync docs: https://rclone.org/bisync/

### Internal Documentation
- [Ansible Playbooks Guide](../sync/ansible-playbooks.md)
- [rclone bisync Guide](../sync/rclone-gdrive.md)
- Master TODO: Section 5 (Ansible Repository Setup)

---

**Approved by:** Dimitris Tsioumas (Mitsio)
**Date:** 2025-11-25
**Status:** Implemented (by not implementing collection)

---

*This ADR documents why we maintain a custom Ansible playbook instead of using the official rolehippie/rclone collection. The decision prioritizes bisync support and NixOS integration over community support.*
