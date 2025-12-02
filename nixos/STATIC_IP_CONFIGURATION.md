# Static IP Configuration for NixOS

**Date:** 2025-11-21
**System:** shoshin (NixOS Desktop)
**Purpose:** Configure static IP address for stable network access
**Status:** ✅ COMPLETED (2025-11-22)

---

## Overview

This document describes the static IP configuration for the shoshin system, implemented as a modular NixOS configuration.

## Configuration Details

### Network Information

- **Interface:** `enp0s31f6` (Ethernet)
- **Static IP:** `192.168.1.17/24`
- **Gateway:** `192.168.1.1`
- **DNS Servers:**
  - Primary: `192.168.1.1` (Router)
  - Fallback: `1.1.1.1` (Cloudflare)
  - Fallback: `8.8.8.8` (Google)

### Module Location

The networking configuration is defined in a modular file:

**Active config (via symlink):**
```
/etc/nixos/modules/system/networking.nix
→ ~/MySpaces/my-modular-workspace/nixos/modules/system/networking.nix
```

**Direct path:**
```
~/MySpaces/my-modular-workspace/nixos/modules/system/networking.nix
```

### Features

1. **Static IP Assignment:** Fixed IP address prevents DHCP reassignments
2. **NetworkManager Enabled:** Easier network management through GUI/CLI
3. **Multiple DNS Servers:** Redundancy for DNS resolution
4. **IPv6 Privacy Extensions:** Enabled for privacy
5. **Firewall:** Enabled by default (configure ports as needed)

---

## Module Structure

The networking module configures:

```nix
{
  networking.hostName = "shoshin";
  networking.useDHCP = false;  # Disable global DHCP
  networking.networkmanager.enable = true;

  networking.interfaces.enp0s31f6 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.1.17";
      prefixLength = 24;
    }];
  };

  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "enp0s31f6";
  };

  networking.nameservers = [ "192.168.1.1" "1.1.1.1" "8.8.8.8" ];
  networking.firewall.enable = true;
  networking.tempAddresses = "enabled";
}
```

---

## Integration with configuration.nix

The module is imported in `~/.config/nixos/configuration.nix`:

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./modules/system/networking.nix
  ];
}
```

---

## Testing & Applying

### 1. Test the Configuration

Before applying, test for syntax errors:

```bash
sudo nixos-rebuild test
```

This will:
- Build the new configuration
- Activate it temporarily (doesn't survive reboot)
- Allow you to verify network connectivity

### 2. Verify Network Configuration

After testing, verify the static IP:

```bash
# Check IP address
ip addr show enp0s31f6

# Expected output should show:
# inet 192.168.1.17/24 brd 192.168.1.255 scope global enp0s31f6

# Check routing
ip route show

# Expected output should show:
# default via 192.168.1.1 dev enp0s31f6

# Test connectivity
ping -c 4 192.168.1.1   # Gateway
ping -c 4 1.1.1.1       # Internet
```

### 3. Apply Permanently

Once verified, make it permanent:

```bash
sudo nixos-rebuild switch
```

This will:
- Build and activate the configuration
- Make it the default boot configuration
- Survive reboots

---

## Troubleshooting

### Network Not Working After Apply

If network doesn't work after applying:

1. **Check interface name:**
   ```bash
   ip link show
   ```
   Verify `enp0s31f6` is correct. If different, update the module.

2. **Revert to DHCP temporarily:**
   ```bash
   sudo dhclient enp0s31f6
   ```

3. **Check NetworkManager status:**
   ```bash
   systemctl status NetworkManager
   ```

4. **Rollback to previous generation:**
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

### K3s/Docker Conflicts

The configuration should **not** interfere with:
- `flannel.1` (K3s CNI)
- `cni0` (K3s pod network)
- `docker0` (Docker bridge)
- `br-*` (Docker custom networks)

These virtual interfaces are managed separately by their respective services.

---

## Notes

- **Router DHCP:** Ensure 192.168.1.17 is **outside** your router's DHCP range to avoid IP conflicts
- **IPv6:** IPv6 privacy extensions are enabled (`networking.tempAddresses = "enabled"`)
- **Firewall:** Firewall is enabled. Open ports as needed in the module
- **NetworkManager:** Provides GUI management via Plasma network settings

---

## Change History

| Date | Change | Reason |
|------|--------|--------|
| 2025-11-21 | Initial static IP setup (192.168.1.17) | Desktop stability, K3s cluster preparation |
| 2025-11-22 | Configuration tested and verified | Migration Part 1 completed |
| 2025-11-22 | DHCP lease removed, single IP only | Fixed NetworkManager conflict |
| 2025-11-22 | K3s updated to use new IP | Database reset after static IP change |
| 2025-11-22 | KDE Connect port 1716 opened | Phone integration |

---

## References

- [NixOS Manual - Networking](https://nixos.org/manual/nixos/stable/index.html#sec-networking)
- [NetworkManager on NixOS](https://nixos.wiki/wiki/NetworkManager)
- Interface name detected from: `ip addr show`
