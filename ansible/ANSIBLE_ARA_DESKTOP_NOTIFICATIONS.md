# Ansible + ARA + Desktop Notifications - Research Findings

**Date:** 2025-11-19
**Purpose:** Research for implementing Ansible automation with ARA recording and desktop notifications for failed playbooks
**Project:** my-modular-workspace

---

## 1. ARA Records Ansible Overview

**Library ID:** `/ansible-community/ara`
**Trust Score:** 9.5
**Code Snippets:** 273

### What is ARA?

ARA (ARA Records Ansible) makes Ansible easier to understand and troubleshoot by:
- Recording playbook execution automatically
- Providing CLI, REST API, and web interface for viewing results
- Tracking hosts, tasks, results, and statistics

### Key Features

- **Automatic recording** via callback plugin
- **Web UI** for browsing playbook history
- **REST API** for programmatic access
- **Search and filtering** of playbook runs
- **Task-level details** including timing, results, and facts

---

## 2. Enabling ARA Callback Plugin

### Method 1: Environment Variables (Recommended)

```bash
# Set callback plugins path
export ANSIBLE_CALLBACK_PLUGINS=$(python3 -m ara.setup.callback_plugins)

# Configure ARA API client
export ARA_API_CLIENT=http
export ARA_API_SERVER="http://127.0.0.1:8000"

# Optional: Additional configuration
export ARA_CALLBACK_THREADS=4
export ARA_DEFAULT_LABELS=prod,deploy
export ARA_IGNORED_FACTS=all
export ARA_LOCALHOST_AS_HOSTNAME=true
```

### Method 2: ansible.cfg Configuration

```ini
[defaults]
callback_plugins=$(python3 -m ara.setup.callback_plugins)

[ara]
api_client = http
api_server = http://127.0.0.1:8000
api_timeout = 15
callback_threads = 4
argument_labels = check,tags,subset
default_labels = prod,deploy
ignored_facts = all
ignored_files = .ansible/tmp,vault.yaml,vault.yml
ignored_arguments = extra_vars,vault_password_files
localhost_as_hostname = true
localhost_as_hostname_format = fqdn
```

### Installation Steps

```bash
# Install ARA
pip3 install ara

# Get plugin paths
python3 -m ara.setup.callback_plugins
# Output: /usr/lib/python3.7/site-packages/ara/plugins/callback

python3 -m ara.setup.action_plugins
# Output: /usr/lib/python3.7/site-packages/ara/plugins/action

python3 -m ara.setup.lookup_plugins
# Output: /usr/lib/python3.7/site-packages/ara/plugins/lookup

# Export all at once
source <(python3 -m ara.setup.env)
```

### Debug Logging

```bash
export ARA_DEBUG=true
export ARA_LOG_LEVEL=DEBUG
export ANSIBLE_CALLBACK_PLUGINS=$(python3 -m ara.setup.callback_plugins)
ansible-playbook your-playbook.yml
```

---

## 3. Desktop Notifications for Failed Playbooks

### Approach 1: Custom Callback Plugin with libnotify

**Requirements:**
- `libnotify` package (provides `notify-send`)
- Python `subprocess` module

**Implementation:**

```python
# plugins/callbacks/desktop_notify.py
from ansible.plugins.callback import CallbackBase
import subprocess

class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'desktop_notify'

    def v2_runner_on_failed(self, result, ignore_errors=False):
        """Triggered when a task fails"""
        if not ignore_errors:
            host = result._host.get_name()
            task = result._task.get_name()

            subprocess.run([
                'notify-send',
                '-u', 'critical',
                '-i', 'dialog-error',
                f'Ansible Task Failed',
                f'Host: {host}\\nTask: {task}'
            ])

    def v2_playbook_on_stats(self, stats):
        """Triggered at the end of playbook"""
        hosts_failed = [h for h in stats.processed.keys() if stats.failures[h] > 0]

        if hosts_failed:
            subprocess.run([
                'notify-send',
                '-u', 'critical',
                '-i', 'dialog-error',
                'Ansible Playbook Failed',
                f'Failed hosts: {", ".join(hosts_failed)}'
            ])
        else:
            subprocess.run([
                'notify-send',
                '-i', 'emblem-checked',
                'Ansible Playbook Success',
                'All tasks completed successfully!'
            ])
```

**Enable in ansible.cfg:**

```ini
[defaults]
callback_plugins = ./plugins/callbacks
callback_whitelist = desktop_notify
```

### Approach 2: Block/Rescue Pattern with notify-send

**In playbook:**

```yaml
---
- name: GDrive Backup with Notifications
  hosts: localhost
  connection: local

  tasks:
    - name: Run backup tasks
      block:
        - name: Create backup directory
          file:
            path: /backups/GDrive_Backups
            state: directory
            owner: mitsio
            group: users
            mode: '0755'

        - name: Sync Google Drive
          command: >
            rclone sync
            GoogleDrive-dtsioumas0:
            /backups/GDrive_Backups/gdrive-backup-{{ ansible_date_time.date }}
            --progress
            --log-file=/var/log/ansible/gdrive-backup.log

        - name: Compress backup
          archive:
            path: /backups/GDrive_Backups/gdrive-backup-{{ ansible_date_time.date }}
            dest: /backups/GDrive_Backups/gdrive-backup-{{ ansible_date_time.date }}.tar.xz
            format: xz
            owner: mitsio
            group: users
            mode: '0644'

        - name: Success notification
          command: >
            notify-send
            -i emblem-checked
            "Backup Successful"
            "GDrive backup completed at {{ ansible_date_time.time }}"

      rescue:
        - name: Failure notification
          command: >
            notify-send
            -u critical
            -i dialog-error
            "Backup Failed"
            "GDrive backup failed! Check logs: /var/log/ansible/gdrive-backup.log"

        - name: Log failure
          debug:
            msg: "Backup failed on {{ ansible_date_time.iso8601 }}"
```

### Approach 3: Handler-Based Notifications

**handlers/main.yml:**

```yaml
---
- name: notify_success
  command: >
    notify-send
    -i emblem-checked
    "{{ notification_title | default('Ansible Task Success') }}"
    "{{ notification_message | default('Task completed successfully') }}"

- name: notify_failure
  command: >
    notify-send
    -u critical
    -i dialog-error
    "{{ notification_title | default('Ansible Task Failed') }}"
    "{{ notification_message | default('Task execution failed') }}"
```

**Usage in tasks:**

```yaml
tasks:
  - name: My task
    command: /some/command
    register: result
    notify:
      - notify_success
    failed_when: false  # Don't stop on failure

  - name: Check if failed
    set_fact:
      task_failed: "{{ result.rc != 0 }}"

  - name: Notify on failure
    debug:
      msg: "Task failed!"
    notify: notify_failure
    when: task_failed
```

---

## 4. Built-in Ansible Callback Plugins

### Available Notification Callbacks

1. **community.general.mail** - Email notifications
   - Configure SMTP server, recipients
   - Send on failures

2. **community.general.syslog_json** - Syslog in JSON format
   - Central logging integration
   - SIEM compatibility

3. **community.general.logstash** - Send to Logstash
   - ELK stack integration
   - Structured logging

4. **community.general.jabber** - XMPP/Jabber notifications
   - Chat notifications
   - Real-time alerts

5. **community.general.slack** - Slack notifications
   - Team notifications
   - Webhook integration

### Configuration Example (ansible.cfg)

```ini
[defaults]
callback_whitelist = community.general.mail, ara_default, desktop_notify

[callback_mail]
mta = smtp.gmail.com
mtaport = 587
sender = ansible@example.com
to = admin@example.com

[ara]
api_client = http
api_server = http://localhost:8000
```

---

## 5. Complete Ansible + ARA Setup

### Directory Structure

```
my-ansible-bootstrap/
├── ansible.cfg
├── inventories/
│   └── hosts
├── playbooks/
│   ├── gdrive-backup.yml
│   └── bootstrap.yml
├── roles/
│   └── gdrive_backup/
│       ├── tasks/main.yml
│       └── handlers/main.yml
├── plugins/
│   └── callbacks/
│       └── desktop_notify.py
├── logs/
│   └── .gitkeep
└── README.md
```

### ansible.cfg (Complete Configuration)

```ini
[defaults]
inventory = inventories/hosts
roles_path = roles
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
interpreter_python = auto_silent
callback_plugins = plugins/callbacks:$(python3 -m ara.setup.callback_plugins)
callback_whitelist = ara_default, desktop_notify
log_path = logs/ansible.log

[ara]
api_client = http
api_server = http://localhost:8000
api_timeout = 15
callback_threads = 4
default_labels = backup,automated
ignored_facts = ansible_env,ansible_all_ipv4_addresses
localhost_as_hostname = true
localhost_as_hostname_format = fqdn
```

### Start ARA Server

```bash
# Install ARA
pip3 install ara

# Initialize database
ara-manage migrate

# Start API server
ara-manage runserver 0.0.0.0:8000

# Or run in background
nohup ara-manage runserver 0.0.0.0:8000 > /tmp/ara-server.log 2>&1 &

# Access web UI
xdg-open http://localhost:8000
```

---

## 6. Testing Desktop Notifications

### Test notify-send

```bash
# Success notification
notify-send -i emblem-checked "Test Success" "This is a success message"

# Error notification
notify-send -u critical -i dialog-error "Test Error" "This is an error message"

# With custom timeout (milliseconds)
notify-send -t 5000 -i info "Test Info" "5 second notification"
```

### Test Ansible Callback

```yaml
# test-notification.yml
---
- name: Test Desktop Notifications
  hosts: localhost
  connection: local
  gather_facts: no

  tasks:
    - name: Success task
      debug:
        msg: "This will trigger success notification"

    - name: Failing task (for testing)
      command: /bin/false
      ignore_errors: yes
```

Run with:
```bash
ansible-playbook test-notification.yml
```

---

## 7. Integration with Systemd (Auto-run with ARA)

### systemd service for ARA server

```ini
# /etc/systemd/system/ara-server.service
[Unit]
Description=ARA Records Ansible API Server
After=network.target

[Service]
Type=simple
User=mitsio
Environment="PATH=/home/mitsio/.local/bin:/usr/bin"
ExecStart=/home/mitsio/.local/bin/ara-manage runserver 0.0.0.0:8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable ara-server.service
sudo systemctl start ara-server.service
sudo systemctl status ara-server.service
```

---

## 8. Key Takeaways

### ARA Benefits
- ✅ **Automatic recording** - No manual intervention needed
- ✅ **Web UI** - Easy browsing of playbook history
- ✅ **Search & filter** - Find specific runs quickly
- ✅ **API access** - Programmatic querying
- ✅ **Lightweight** - Minimal performance impact

### Desktop Notifications
- ✅ **Immediate feedback** - Know instantly when jobs fail
- ✅ **Custom callback plugin** - Full control over notifications
- ✅ **Block/rescue pattern** - Simple per-playbook notifications
- ✅ **Handlers** - Reusable notification tasks

### Best Practices
1. **Always enable ARA** for production playbooks
2. **Use custom callback** for desktop notifications
3. **Configure labels** for easy filtering in ARA
4. **Ignore unnecessary facts** to reduce database size
5. **Set callback_threads** for better performance
6. **Use block/rescue** for critical tasks
7. **Log to file** in addition to ARA for debugging

---

## 9. Next Steps

1. ✅ Enable ARA callback in ansible.cfg
2. ✅ Create custom desktop notification callback plugin
3. ✅ Start ARA server as systemd service
4. ✅ Create GDrive backup playbook with notifications
5. ✅ Test and iterate

---

## 10. References

- **ARA Documentation:** https://ara.readthedocs.io/
- **Ansible Callbacks:** https://docs.ansible.com/ansible/latest/plugins/callback.html
- **Ansible Best Practices:** https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
- **libnotify Documentation:** https://manpages.org/notify-send
- **Context7 Ansible Docs:** `/websites/ansible_ansible`
- **Context7 ARA Docs:** `/ansible-community/ara`

---

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Author:** Claude Code + Μήτσο
**Status:** Ready for implementation
