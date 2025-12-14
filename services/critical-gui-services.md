# Critical GUI Services with Monitoring

**Date:** 2025-12-12
**Module:** `home-manager/critical-gui-services.nix`
**Status:** ✅ Ready for deployment

---

## Overview

Ensures critical GUI applications are always running with automatic restart and failure notifications.

### Services Managed

1. **KeePassXC** (enhanced from keepassxc.nix)
   - Password manager
   - Secret Service provider
   - Already had basic service, now enhanced

2. **KDE Connect** (new)
   - Phone integration
   - File sharing, notifications, clipboard sync
   - System tray indicator

---

## Features

### 🔄 Always Running
- **Restart=always** - Services restart automatically if they crash
- **RestartSec=10s** - Wait 10 seconds before restarting
- **StartLimitBurst=5** - Allow up to 5 restarts in 60 seconds

### 🔔 Failure Notifications
- **OnFailure** directive triggers notification service
- **Critical notifications** appear immediately when service fails
- **Persistent notifications** (timeout=0) require manual dismiss

### 📊 Health Monitoring
- **Periodic health checks** every 30 minutes
- **Success notifications** every 6 hours (00:00, 06:00, 12:00, 18:00)
- **Failure alerts** if any critical service is down

### 🛡️ Resource Limits
```
KeePassXC:
- MemoryMax: 1G
- CPUQuota: 75%

KDE Connect:
- MemoryMax: 512M
- CPUQuota: 50%
```

---

## Services Created

### Primary Services

1. **kdeconnect.service**
   - Runs KDE Connect indicator
   - Auto-starts after graphical-session.target
   - Restarts always

2. **keepassxc-gui.service** (enhanced)
   - Already defined in keepassxc.nix
   - Enhanced with OnFailure and always restart

### Notification Services

3. **notify-kdeconnect-failure.service**
   - Triggered when KDE Connect fails
   - Shows critical notification

4. **notify-keepassxc-failure.service**
   - Triggered when KeePassXC fails
   - Shows critical notification

### Health Check

5. **critical-services-health-check.service**
   - Checks all critical services
   - Runs every 30 minutes via timer

6. **critical-services-health-check.timer**
   - Timer for health check service
   - OnBootSec=5min, OnUnitActiveSec=30min

---

## Manual Control Scripts

### Check Service Status
```bash
check-critical-services.sh
```

**Output:**
```
======================================
Critical Services Status
======================================

--- keepassxc-gui ---
Status: ✓ RUNNING
Since: Thu 2025-12-12 01:00:00 EET

--- kdeconnect ---
Status: ✓ RUNNING
Since: Thu 2025-12-12 01:00:05 EET

======================================
To restart all: restart-critical-services.sh
To view logs: journalctl --user -u <service>.service -f
======================================
```

### Restart All Services
```bash
restart-critical-services.sh
```

**What it does:**
1. Restarts keepassxc-gui.service
2. Restarts kdeconnect.service
3. Shows status summary
4. Sends notification when complete

### View Logs
```bash
# Real-time logs
journalctl --user -u keepassxc-gui.service -f
journalctl --user -u kdeconnect.service -f

# Last 50 lines
journalctl --user -u keepassxc-gui.service -n 50
journalctl --user -u kdeconnect.service -n 50
```

---

## Notification Examples

### Service Failure (Critical)
```
Title: Service Failed: kdeconnect
Body:  kdeconnect has stopped unexpectedly. Click to view logs.

       Run: journalctl --user -u kdeconnect.service

Icon:  ❌ (dialog-error)
Urgency: Critical
Timeout: 0 (persistent)
```

### Health Check Failure
```
Title: Critical Services Check
Body:  Failed services: kdeconnect

       Run: systemctl --user status <service>

Icon:  ⚠️ (dialog-warning)
Urgency: Critical
```

### Health Check Success (Periodic)
```
Title: Critical Services
Body:  All critical services running (KeePassXC, KDE Connect)

Icon:  ✓ (checkbox)
Urgency: Low
(Only shown at 00:00, 06:00, 12:00, 18:00)
```

### Services Restarted
```
Title: Critical Services Restarted
Body:  KeePassXC and KDE Connect have been restarted

Icon:  ✓ (checkbox)
```

---

## Architecture

```
graphical-session.target
    ├── keepassxc-gui.service (enhanced)
    │   ├── Restart=always
    │   ├── OnFailure=notify-keepassxc-failure.service
    │   └── Resource limits (1G RAM, 75% CPU)
    │
    └── kdeconnect.service (new)
        ├── Restart=always
        ├── OnFailure=notify-kdeconnect-failure.service
        └── Resource limits (512M RAM, 50% CPU)

timers.target
    └── critical-services-health-check.timer
        └── triggers: critical-services-health-check.service
            └── checks both services every 30min
```

---

## Testing After Deploy

### 1. Check Services Started
```bash
systemctl --user status keepassxc-gui.service
systemctl --user status kdeconnect.service
```

**Expected:** Both active (running)

### 2. Test Failure Notifications
```bash
# Stop a service manually
systemctl --user stop kdeconnect.service

# Should see critical notification immediately
# Service should restart after 10 seconds
```

### 3. Test Health Check
```bash
# Trigger health check manually
systemctl --user start critical-services-health-check.service

# Should see notification if any service is down
```

### 4. Test Manual Scripts
```bash
check-critical-services.sh
restart-critical-services.sh
```

---

## Integration with Existing Services

### KeePassXC (keepassxc.nix)
- **Already has:** keepassxc-gui.service (basic)
- **We add:** OnFailure, Restart=always, resource limits
- **Method:** lib.mkForce to override settings
- **No conflicts:** Both modules work together

### Autostart (autostart.nix)
- **Currently manages:** CopyQ via XDG autostart
- **We add:** KDE Connect via systemd (better control)
- **No conflicts:** Different tools

---

## Troubleshooting

### Service Won't Start
```bash
# Check logs
journalctl --user -u kdeconnect.service -n 100

# Check if binary exists
which kdeconnect-indicator

# Try starting manually
kdeconnect-indicator
```

### Too Many Restart Attempts
```bash
# Reset failure count
systemctl --user reset-failed kdeconnect.service

# Start again
systemctl --user start kdeconnect.service
```

### Notifications Not Appearing
```bash
# Test notify-send
notify-send "Test" "This is a test notification"

# Check notification daemon
ps aux | grep notification

# KDE Plasma should have notification daemon running
```

---

## Future Enhancements

### Possible Additions
- [ ] Add more critical services (Syncthing, Dropbox)
- [ ] Email notifications for failures (optional)
- [ ] Prometheus metrics export
- [ ] Service dependency checks
- [ ] Automatic service recovery strategies

### Configuration Options
Could add to home-manager config:
```nix
criticalServices = {
  enableNotifications = true;
  healthCheckInterval = "30min";
  successNotificationInterval = "6h";
};
```

---

## Action Confidence

| Component | Confidence | Band |
|-----------|-----------|------|
| Service definitions | 0.95 | C |
| Notification setup | 0.92 | C |
| Health monitoring | 0.90 | C |
| Resource limits | 0.88 | C |
| Overall implementation | 0.93 | C |

---

## References

- systemd.service(5): https://www.freedesktop.org/software/systemd/man/systemd.service.html
- KDE Connect: https://kdeconnect.kde.org/
- KeePassXC: https://keepassxc.org/
- home-manager systemd services: https://nix-community.github.io/home-manager/options.html#opt-systemd.user.services

---

**Created:** 2025-12-12T01:50:00+02:00 (Europe/Athens)
**Ready for:** home-manager switch
