# Google Drive Tray Application

A lightweight, "Dropbox-like" system tray utility for monitoring and managing Rclone Bisync jobs on NixOS/Linux.

## Features

*   **Real-time Status:** Shows icon state (Idle, Syncing, Error, Warning) based on Systemd service status.
*   **Dashboard:** Click the icon to see detailed stats (Files changed, Last sync time).
*   **Mount Monitor:** Checks if `~/GoogleDrive` mount is active.
*   **Conflict Manager:** Built-in GUI to view and resolve file conflicts (Keep Local vs Keep Remote).
*   **Controls:** Quick access to "Sync Now", "Force Resync", and Logs.

## Architecture

The application is written in **Python 3** using **PyQt6** and integrated via Home Manager.

### Components

1.  **Monitor (`monitor.py`):**
    *   Connects to **Systemd DBus** (`org.freedesktop.systemd1`) to check `gdrive-sync.service` state.
    *   Parses Rclone logs (`~/.logs/gdrive-sync/`) to extract file transfer stats and conflict counts.
2.  **GUI (`gui.py`):**
    *   Implements a frameless popup widget that positions itself near the tray icon.
    *   Contains tabs for "Status" and "Conflicts".
3.  **Conflict Utils:**
    *   Vendorized logic from `conflict-manager` CLI to perform scanning and resolution.

## Installation

This tool is part of the `my-modular-workspace` Home Manager configuration.

1.  Ensure `home-manager/gdrive-tray.nix` is imported in `home.nix`.
2.  Run:
    ```bash
    home-manager switch
    ```
3.  The service `gdrive-tray.service` will start automatically.

## Usage

*   **Left Click:** Toggle Dashboard.
*   **Right Click:** Open Menu (Sync, Logs, Quit).
*   **Resolving Conflicts:**
    1.  Click the Tray Icon.
    2.  Go to "Conflicts" tab.
    3.  Select a file.
    4.  Click "Keep Local" (deletes remote conflict file) or "Keep Remote" (overwrites local).

## Troubleshooting

**Logs:**
```bash
journalctl --user -u gdrive-tray -f
```

**Manual Start:**
```bash
gdrive-tray
```
