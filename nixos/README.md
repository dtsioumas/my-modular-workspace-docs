# NixOS System Documentation

This directory contains documentation for the **NixOS root system configuration**. These configurations are specific to the `shoshin` host and manage hardware, system services, and the base desktop environment.

This part of the workspace is **not portable** and is tightly coupled to NixOS.

## Key Documents

- **[Flakes Guide](./flakes-guide.md):** A guide to building Nix flakes and managing custom packages within the system configuration.
- **[Debugging and Maintenance](./DEBUGGING_AND_MAINTENANCE_GUIDE.md):** A collection of notes and procedures for troubleshooting NixOS build failures and performing system maintenance.
- **[Migration Plan](./MIGRATION_PLAN.md):** The plan and status of migrating configurations from the old system setup.
- **[Static IP Configuration](./STATIC_IP_CONFIGURATION.md):** Instructions for configuring a static IP address for the `shoshin` host.

---

## Architecture Context

The configurations documented here represent the **System Layer** of the workspace. They are intentionally kept separate from the **User Layer**, which is managed by [Home-Manager](../home-manager/) and is designed to be portable across different operating systems.

For the detailed reasoning behind this architectural split, see [ADR-001](../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md).