# NixOS System-Level Changes for Firefox

**Required for**: Plasma Integration extension to work properly

---

## Phase 2.0: Install plasma-browser-integration System Package

The **Plasma Integration** Firefox extension requires a companion system package to communicate with KDE Plasma.

### Where to Add

**File**: `hosts/shoshin/nixos/modules/workspace/kde.nix`

(Or wherever your KDE/Plasma system packages are configured)

### Changes Required

```nix
# hosts/shoshin/nixos/modules/workspace/kde.nix
{ config, pkgs, lib, ... }:

{
  # ... existing KDE configuration ...

  environment.systemPackages = with pkgs; [
    # ... existing packages ...

    # ADD THIS LINE:
    plasma-browser-integration  # Required for Plasma Integration Firefox extension
  ];
}
```

### Apply Changes

```bash
# Rebuild NixOS system
sudo nixos-rebuild switch

# Verify installation
which plasma-browser-integration

# Expected output:
# /run/current-system/sw/bin/plasma-browser-integration
```

### Verification

After rebuilding NixOS:

1. **Check package installed**:
   ```bash
   which plasma-browser-integration
   # Should return: /run/current-system/sw/bin/plasma-browser-integration
   ```

2. **Check Firefox extension**:
   - Open Firefox → `about:addons`
   - Find "Plasma Integration"
   - Should show as **Enabled** (no errors)

3. **Test integration**:
   - Play video in Firefox
   - Media controls should appear in Plasma panel
   - ☐ Play/Pause works from Plasma
   - ☐ Track info shows in notification area

### What This Package Does

`plasma-browser-integration` provides:
- Native messaging host for browser-plasma communication
- Media controls integration (play/pause/skip from Plasma)
- Download progress in Plasma notifications
- Browser tabs in KRunner (if enabled)

### Troubleshooting

**If extension shows errors after installing package**:
```bash
# Restart Firefox
pkill firefox
firefox &
```

**If media controls don't work**:
```bash
# Check native messaging manifest
ls ~/.mozilla/native-messaging-hosts/ | grep plasma

# Should show:
# org.kde.plasma.browser_integration.json
```

**If manifest is missing**:
```bash
# Reinstall the extension (declarative config will recreate it)
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
home-manager switch --flake .#mitsio@shoshin
```

---

## No Other System Changes Required

All other Firefox configuration is handled by **home-manager** declaratively:
- Extensions → `home-manager/firefox.nix` (Enterprise Policies)
- Settings → `home-manager/firefox.nix` (about:config preferences)
- Session Variables → `home-manager/firefox.nix` (NVIDIA/X11 vars)
- userChrome.css → `home-manager/firefox.nix` (vertical tabs CSS)

---

**Required**: ✅ Yes (for Plasma Integration extension)
**Apply**: Before Phase 2 testing
**Safety**: Safe - only adds one system package
