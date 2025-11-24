# Verification and Troubleshooting Guide

**Purpose:** Verify complete setup and resolve common issues

---

## Complete System Verification

### 1. Syncthing Status Check

```bash
# Service running
systemctl --user status syncthing
# Should show: Active: active (running)

# Web GUI accessible
curl -s http://localhost:8384 | grep -q "Syncthing" && echo "✓ GUI accessible"

# Devices connected
# Open http://localhost:8384
# All devices should show "Connected"
```

### 2. rclone Configuration Check

```bash
# Config exists
rclone config show gdrive && echo "✓ rclone configured"

# Can list Google Drive
rclone lsd gdrive: && echo "✓ Google Drive accessible"

# Test upload
echo "test" > /tmp/test.txt
rclone copy /tmp/test.txt gdrive:MyHome/
rclone ls gdrive:MyHome/test.txt && echo "✓ Upload works"
rclone delete gdrive:MyHome/test.txt
rm /tmp/test.txt
```

### 3. Systemd Timer Check

```bash
# Timer active
systemctl --user is-active rclone-gdrive-sync.timer && echo "✓ Timer active"

# Next scheduled run
systemctl --user list-timers | grep rclone
```

### 4. End-to-End Test

```bash
# Create test file on shoshin
echo "E2E test $(date)" > ~/.MyHome/MySpaces/my-modular-workspace/e2e-test.txt

# Wait 5 seconds
sleep 5

# Check on laptop (if available)
ssh laptop-system01 "cat ~/.MyHome/MySpaces/my-modular-workspace/e2e-test.txt"

# Trigger manual Google Drive sync
systemctl --user start rclone-gdrive-sync.service

# Verify on Google Drive
rclone cat gdrive:MyHome/MySpaces/my-modular-workspace/e2e-test.txt

# Clean up
rm ~/.MyHome/MySpaces/my-modular-workspace/e2e-test.txt
```

---

## Common Issues

### Syncthing Issues

#### Issue: Device Not Connecting

**Symptoms:**
- Device shows "Disconnected" in Web GUI
- No sync happening

**Diagnosis:**
```bash
# Check Syncthing logs
journalctl --user -u syncthing -n 50 | grep -i error

# Check firewall
sudo iptables -L | grep 22000
```

**Solutions:**

1. **Firewall blocking:**
   ```bash
   # NixOS: Add to configuration.nix
   networking.firewall.allowedTCPPorts = [ 22000 ];
   networking.firewall.allowedUDPPorts = [ 22000 21027 ];
   ```

2. **Device ID mismatch:**
   - Verify device ID: `syncthing --device-id`
   - Re-add device with correct ID

3. **Network issues:**
   - Enable relaying: Settings → Connections → Enable Relaying
   - Check global discovery is enabled

#### Issue: Folder Not Syncing

**Diagnosis:**
```bash
# Check folder status in Web GUI
# Look for "Stopped" or "Scanning" state

# Check for errors
journalctl --user -u syncthing | grep -i "folder.*error"
```

**Solutions:**

1. **Out of sync:**
   - Web GUI → Folder → Actions → Override Changes

2. **Ignore patterns blocking files:**
   - Check `.stignore` file
   - Test pattern: Web GUI → Folder → Edit → Ignore Patterns

3. **Insufficient disk space:**
   ```bash
   df -h ~/.MyHome
   ```

#### Issue: High CPU Usage

**Diagnosis:**
```bash
# Check Syncthing process
ps aux | grep syncthing
top -p $(pgrep syncthing)
```

**Solutions:**

1. **Reduce scan frequency:**
   - Web GUI → Folder → Edit → Rescan Interval: 7200 (2 hours)

2. **Disable file watching (large directories):**
   - Web GUI → Folder → Edit → Watch for Changes: OFF

3. **Limit concurrent file scans:**
   - Web GUI → Settings → Options → Max Folder Concurrency: 1

---

### rclone Issues

#### Issue: 403 Forbidden / Authorization Failed

**Symptoms:**
```
Failed to create file system: couldn't find root directory: googleapi: Error 403
```

**Solutions:**

1. **Re-authenticate:**
   ```bash
   rclone config reconnect gdrive:
   ```

2. **Check Google Drive API:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Verify Google Drive API is enabled

3. **OAuth consent screen:**
   - Ensure app is published (or add test users)

#### Issue: Rate Limit Exceeded

**Symptoms:**
```
Error 429: Rate Limit Exceeded
```

**Solutions:**

1. **Add delay between requests:**
   ```bash
   rclone sync SOURCE DEST --tpslimit 10
   ```

2. **Reduce concurrent transfers:**
   ```bash
   --transfers 2
   --checkers 4
   ```

3. **Use exponential backoff:**
   ```bash
   --retries 3
   --low-level-retries 10
   ```

#### Issue: Sync Incomplete / Missing Files

**Diagnosis:**
```bash
# Dry run to see what would sync
rclone sync SOURCE DEST --dry-run -vv

# Compare source and destination
rclone check SOURCE DEST
```

**Solutions:**

1. **Check exclude patterns:**
   ```bash
   rclone sync SOURCE DEST --dry-run -vv | grep "Excluding"
   ```

2. **Check Google Drive quota:**
   ```bash
   rclone about gdrive:
   ```

3. **Force full sync (use carefully!):**
   ```bash
   rclone sync SOURCE DEST --ignore-existing=false
   ```

---

### systemd Timer Issues

#### Issue: Timer Not Triggering

**Diagnosis:**
```bash
# Check timer status
systemctl --user status rclone-gdrive-sync.timer

# Check timer schedule
systemctl --user list-timers | grep rclone

# Check service logs
journalctl --user -u rclone-gdrive-sync.service -n 20
```

**Solutions:**

1. **Timer not enabled:**
   ```bash
   systemctl --user enable rclone-gdrive-sync.timer
   systemctl --user start rclone-gdrive-sync.timer
   ```

2. **Timer definition incorrect:**
   - Check timer file syntax
   - Reload systemd: `systemctl --user daemon-reload`

3. **Service failing:**
   - Test manually: `systemctl --user start rclone-gdrive-sync.service`
   - Check script permissions: `ls -l ~/bin/rclone-gdrive-sync.sh`

#### Issue: Service Fails Immediately

**Diagnosis:**
```bash
# Check service status
systemctl --user status rclone-gdrive-sync.service

# View full error
journalctl --user -u rclone-gdrive-sync.service --no-pager
```

**Solutions:**

1. **Script not executable:**
   ```bash
   chmod +x ~/bin/rclone-gdrive-sync.sh
   ```

2. **rclone binary path incorrect:**
   - Use absolute path or `which rclone`
   - Update in script: `/nix/store/.../bin/rclone` or just `rclone`

3. **Missing directories:**
   ```bash
   mkdir -p ~/.cache/rclone
   mkdir -p ~/.MyHome/MySpaces/my-modular-workspace
   ```

---

## Monitoring Commands

### Quick Status Check

```bash
#!/bin/bash
echo "=== Sync System Status ==="
echo ""
echo "Syncthing:"
systemctl --user is-active syncthing && echo "  ✓ Running" || echo "  ✗ Not running"

echo ""
echo "rclone Timer:"
systemctl --user is-active rclone-gdrive-sync.timer && echo "  ✓ Active" || echo "  ✗ Inactive"

echo ""
echo "Next sync:"
systemctl --user list-timers | grep rclone | awk '{print "  " $1 " " $2}'

echo ""
echo "Last sync:"
systemctl --user show rclone-gdrive-sync.service -p ExecMainExitTimestamp | cut -d'=' -f2

echo ""
echo "Recent sync logs:"
journalctl --user -u rclone-gdrive-sync.service -n 1 --no-pager
```

Save as `~/bin/sync-status.sh` and run:
```bash
chmod +x ~/bin/sync-status.sh
~/bin/sync-status.sh
```

### Detailed Diagnostics

```bash
#!/bin/bash
echo "=== Detailed Sync Diagnostics ==="

echo -e "\n[Syncthing]"
systemctl --user status syncthing --no-pager | head -10

echo -e "\n[Syncthing Devices]"
curl -s -H "X-API-Key: $(grep '<apikey>' ~/.config/syncthing/config.xml | sed 's/.*<apikey>//;s/<\/apikey>.*//')" \
  http://localhost:8384/rest/system/connections | jq '.connections | keys[]'

echo -e "\n[rclone Config]"
rclone config show gdrive >/dev/null 2>&1 && echo "✓ Configured" || echo "✗ Not configured"

echo -e "\n[Google Drive Connection]"
rclone lsd gdrive: 2>&1 | head -5

echo -e "\n[Sync Timer]"
systemctl --user list-timers rclone-gdrive-sync.timer --no-pager

echo -e "\n[Last 3 Sync Results]"
journalctl --user -u rclone-gdrive-sync.service -n 3 --no-pager | grep -E "(Started|Success|Failed)"

echo -e "\n[Disk Space]"
df -h ~/.MyHome | tail -1

echo -e "\n[Google Drive Quota]"
rclone about gdrive: 2>/dev/null || echo "Unable to fetch quota"
```

---

## Health Checks

### Daily Health Check Script

```bash
#!/bin/bash
# Save as ~/bin/sync-health-check.sh

ERRORS=0

# Check Syncthing
if ! systemctl --user is-active syncthing >/dev/null; then
  echo "❌ Syncthing not running"
  ((ERRORS++))
else
  echo "✓ Syncthing running"
fi

# Check rclone timer
if ! systemctl --user is-active rclone-gdrive-sync.timer >/dev/null; then
  echo "❌ rclone timer not active"
  ((ERRORS++))
else
  echo "✓ rclone timer active"
fi

# Check last sync was recent (within 1 hour)
LAST_SYNC=$(systemctl --user show rclone-gdrive-sync.service -p ExecMainExitTimestamp | cut -d'=' -f2)
if [ -z "$LAST_SYNC" ] || [ "$LAST_SYNC" = "0" ]; then
  echo "⚠️  No recent sync found"
  ((ERRORS++))
else
  LAST_EPOCH=$(date -d "$LAST_SYNC" +%s 2>/dev/null)
  NOW_EPOCH=$(date +%s)
  DIFF=$((NOW_EPOCH - LAST_EPOCH))

  if [ $DIFF -gt 3600 ]; then
    echo "⚠️  Last sync was $(($DIFF / 60)) minutes ago"
    ((ERRORS++))
  else
    echo "✓ Recent sync: $(($DIFF / 60)) minutes ago"
  fi
fi

# Check disk space
DISK_USAGE=$(df -h ~/.MyHome | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 90 ]; then
  echo "❌ Disk usage critical: ${DISK_USAGE}%"
  ((ERRORS++))
elif [ "$DISK_USAGE" -gt 80 ]; then
  echo "⚠️  Disk usage high: ${DISK_USAGE}%"
else
  echo "✓ Disk usage OK: ${DISK_USAGE}%"
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✅ All checks passed!"
  exit 0
else
  echo "❌ $ERRORS issue(s) found"
  exit 1
fi
```

Run daily via cron or systemd timer:
```bash
chmod +x ~/bin/sync-health-check.sh
~/bin/sync-health-check.sh
```

---

## Recovery Procedures

### Full Sync Reset

If everything is broken, start fresh:

```bash
# 1. Stop all services
systemctl --user stop syncthing
systemctl --user stop rclone-gdrive-sync.timer

# 2. Backup current config
cp -r ~/.config/syncthing ~/.config/syncthing.backup
cp ~/.config/rclone/rclone.conf ~/.config/rclone/rclone.conf.backup

# 3. Remove Syncthing database
rm -rf ~/.local/state/syncthing/index-*

# 4. Restart Syncthing (will rebuild index)
systemctl --user start syncthing

# 5. Wait for full rescan (check Web GUI)

# 6. Restart rclone timer
systemctl --user start rclone-gdrive-sync.timer
```

### Restore from Google Drive

```bash
# Download everything from Google Drive
rclone sync gdrive:MyHome/MySpaces/my-modular-workspace/ ~/.MyHome/MySpaces/my-modular-workspace/

# Verify
ls -la ~/.MyHome/MySpaces/my-modular-workspace/
```

---

**Last Updated:** 2025-11-18
**Version:** 1.0
**Author:** Mitsio
