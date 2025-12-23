# ADR-019: Google Drive Tray Application

## Status
Accepted

## Date
2025-12-22

## Context
Our previous Google Drive synchronization strategy relied on:
1.  **Rclone Bisync:** Executed via Systemd Timer every 30 minutes.
2.  **Ansible Playbook:** Handling the logic, notifications, and logging.
3.  **Shell Scripts:** Providing manual triggers (`sync-gdrive`).

While robust, this approach lacked visibility and interactivity. Users had to check logs manually or wait for notifications. Conflict resolution was purely CLI-based (`conflict-manager`), which increased friction for resolving file conflicts.

We needed a solution that provides:
*   Real-time status monitoring (Idle, Syncing, Error).
*   One-click access to logs and manual sync.
*   A user-friendly interface for resolving conflicts (Keep Local vs Remote).
*   Visual feedback on the desktop (System Tray).

## Decision
We decided to implement a custom **Google Drive Tray Application** (`gdrive-tray`) using **Python** and **PyQt6**.

### 1. Architecture
*   **Frontend:** PyQt6 System Tray Icon + Dashboard Widget (QWidget with popup flags).
*   **Backend:** A background `MonitorThread` that polls system state.
*   **Systemd Integration:** Uses `dbus-python` to query `gdrive-sync.service` and `rclone-gdrive-mount.service` status directly from the session bus (avoiding expensive `subprocess` calls).
*   **Log Parsing:** Natively reads and parses `~/.logs/gdrive-sync/` to extract conflict counts and transfer stats.

### 2. Conflict Management
Instead of calling the `conflict-manager` CLI, we **vendorized** the core logic (`models.py`, `utils.py`, `strategies.py`) into the application. This allows the GUI to:
*   Scan for conflicts in real-time.
*   Display them in a list.
*   Perform resolution actions (Delete local/remote) directly via Python `os/shutil` calls.

### 3. Packaging
The application is packaged as a **Nix Flake** within the Home Manager configuration (`home-manager/pkgs/gdrive-tray`). This ensures:
*   Reproducibility.
*   Dependency management (PyQt6, dbus-python).
*   Integration with the existing `home.nix` configuration.

## Consequences

### Positive
*   **UX:** Significant improvement. "Dropbox-like" experience on Linux.
*   **Efficiency:** DBus monitoring is lightweight (~0% CPU idle).
*   **Safety:** Users can resolve conflicts visually, reducing the risk of accidental data loss via CLI.
*   **Maintainability:** The code is structured (MVC pattern) and integrated into the monorepo.

### Negative
*   **Complexity:** We now maintain a custom Python GUI application (~500 lines of code) in addition to the Ansible playbook.
*   **Dependencies:** Adds `qt6` and `python3-pyqt6` to the user closure (size increase).

## References
*   [Rclone Bisync Documentation](https://rclone.org/bisync/)
*   [PyQt6 System Tray Documentation](https://doc.qt.io/qtforpython-6/PySide6/QtWidgets/QSystemTrayIcon.html)
