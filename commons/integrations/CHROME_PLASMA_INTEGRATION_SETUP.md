## Chrome Plasma Integration Setup Guide

### 1. Install the Chrome Extension:
- Open Chrome browser
- Go to: https://chrome.google.com/webstore/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai
- Click "Add to Chrome"
- Confirm installation

### 2. Verify Native Host Installation:
The native host should already be installed via NixOS configuration.
To verify:
```bash
# Check if the native messaging host file exists
ls -la ~/.mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json
# OR
ls -la ~/.config/chromium/NativeMessagingHosts/org.kde.plasma.browser_integration.json
# OR 
ls -la ~/.config/google-chrome/NativeMessagingHosts/org.kde.plasma.browser_integration.json
```

### 3. Extension Features You'll Get:
- **Media Controls**: Control YouTube, Spotify Web, and other media from KDE's media controller widget
- **KDE Connect Integration**: Right-click any link → "Send via KDE Connect" to send to your phone
- **Download Notifications**: See downloads in KDE's notification area
- **Tab Search**: Search open tabs in KRunner (Meta+Space)
- **History Search**: Search browser history in KRunner
- **Share Menu**: Native KDE share menu integration

### 4. Configure Extension Settings:
- Click the extension icon in Chrome
- Go to Settings/Options
- Enable features you want:
  - ✅ Media Controls
  - ✅ Send via KDE Connect
  - ✅ Download Notifications
  - ✅ Tab/History Search in KRunner
  - ✅ Purpose Web Share

### 5. Test the Integration:
1. Play a YouTube video → Check if it appears in Media Player widget
2. Right-click any link → Look for "Send via KDE Connect" option
3. Download a file → Check KDE notifications
4. Press Meta+Space → Type a website name from your tabs

### 6. Troubleshooting:
If the extension doesn't work:
1. Restart Chrome after NixOS rebuild
2. Check if plasma-browser-integration service is running:
   ```bash
   systemctl --user status plasma-browser-integration
   ```
3. Ensure the native host file exists (paths above)
4. Try disabling and re-enabling the extension

### 7. KRunner Configuration:
Make sure these runners are enabled:
- System Settings → Search → KRunner
- Enable:
  - ✅ Browser Tabs
  - ✅ Browser History
  - ✅ Recent Documents