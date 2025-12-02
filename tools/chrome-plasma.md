# Chrome Plasma Integration Guide

**Last Updated:** 2025-11-29
**Source:** CHROME_PLASMA_INTEGRATION_SETUP.md
**Maintainer:** Mitsos

---

## Overview

Integrates Chrome/Chromium with KDE Plasma for:
- Media controls
- KDE Connect integration
- Download notifications
- Tab/history search in KRunner

---

## Installation

### 1. Install Chrome Extension

- Open Chrome
- Go to: https://chrome.google.com/webstore/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai
- Click "Add to Chrome"

### 2. Verify Native Host

```bash
# Check native messaging host exists
ls -la ~/.config/google-chrome/NativeMessagingHosts/org.kde.plasma.browser_integration.json
# OR for Chromium
ls -la ~/.config/chromium/NativeMessagingHosts/org.kde.plasma.browser_integration.json
```

---

## Features

| Feature | Description |
|---------|-------------|
| Media Controls | Control YouTube/Spotify from KDE widget |
| KDE Connect | Right-click link → Send to phone |
| Downloads | See downloads in KDE notifications |
| Tab Search | Search tabs via KRunner (Meta+Space) |
| Share Menu | Native KDE share integration |

---

## Configuration

Click extension icon → Settings:
- ✅ Media Controls
- ✅ Send via KDE Connect
- ✅ Download Notifications
- ✅ Tab/History Search

### KRunner Setup

System Settings → Search → KRunner:
- ✅ Browser Tabs
- ✅ Browser History

---

## Testing

1. Play YouTube video → Check Media Player widget
2. Right-click link → Look for "Send via KDE Connect"
3. Download file → Check notifications
4. Meta+Space → Type website name from tabs

---

## Troubleshooting

```bash
# Check service
systemctl --user status plasma-browser-integration

# Restart Chrome after NixOS rebuild
# Disable/re-enable extension if needed
```

---

*Migrated from docs/commons/integrations/ on 2025-11-29*
