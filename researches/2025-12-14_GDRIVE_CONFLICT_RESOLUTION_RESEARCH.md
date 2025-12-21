# Research: Google Drive Conflict Resolution & Sync Stability

**Date:** 2025-12-14
**Status:** In Progress
**Context:** `gdrive-sync` job issues (stuck jobs, conflicts) and requirement for a conflict resolution tool.

## 1. Current State Analysis

### Sync Infrastructure
- **Mechanism:** `rclone bisync` via Ansible playbook (`ansible/playbooks/rclone-gdrive-sync.yml`).
- **Schedule:** Systemd timer (`gdrive-sync.timer`) running every 30 minutes.
- **Paths:** `~/.MyHome/` ↔ `GoogleDrive-dtsioumas0:MyHome/`.
- **Logs:** `~/.logs/gdrive-sync/` and `~/.cache/rclone/`.

### Conflict Resolution Strategy (Current)
The playbook uses specific flags to handle conflicts automatically:
```yaml
- --conflict-resolve path1      # Local (Path1) ALWAYS WINS
- --conflict-loser num          # Losers are kept and renamed
- --conflict-suffix .remote-conflict
```
**Implication:**
- When a conflict occurs, the **local version** is kept as the "official" file.
- The **remote version** (the "loser") is downloaded/renamed to `filename.ext.remote-conflict1`.
- **User Experience:** The user sees "duplicate" files with weird extensions rather than a merge prompt.

### "Stuck" Jobs Root Cause
- **Symptoms:** Jobs getting stuck, likely leaving lock files (`.lck`) in `~/.cache/rclone/bisync-workdir/`.
- **Potential Causes:**
    1.  **Timeouts:** Large syncs exceeding the systemd `TimeoutStartSec` (currently 30m).
    2.  **Network Flakiness:** rclone hanging on IO.
    3.  **Overlap:** New timer firing while previous sync is hung (though systemd usually prevents this for same service, `bisync` locks might persist).

## 2. Proposed Solution: "Conflict Manager" Tool

We will develop a sophisticated Python script (`gdrive-conflict-manager.py`) to manage these artifacts.

### A. Discovery Mechanism
Instead of parsing logs (which might be rotated or incomplete), we will **scan the filesystem** for conflict artifacts. This is reliable and stateless.
- **Pattern:** `**/*.remote-conflict*`, `**/*.conflict*`
- **Scope:** `~/.MyHome/`

### B. Visualization (VSCodium Integration)
We can leverage VSCodium's built-in diff capability:
```bash
codium --diff <current_local_file> <conflict_artifact>
```
- **Left Side:** Current Local File (The "Winner").
- **Right Side:** The Conflict Artifact (The "Loser" / Remote version).

### C. Architecture

**Language:** Python 3.11+
**Libraries:**
- `typer` or `argparse` (CLI)
- `rich` (Beautiful terminal output, tables, prompts)
- `subprocess` (Launching VSCodium)
- `pathlib` (Filesystem operations)

**Workflow:**
1.  **Scan:** Find all `filename.ext.remote-conflictN`.
2.  **Match:** Identify the corresponding base file `filename.ext`.
3.  **List:** Show a table of conflicts with metadata (size diff, modtime diff).
4.  **Interact:** User selects a conflict to resolve.
5.  **Visualize:** Launch `codium --diff base conflict`.
6.  **Resolve:**
    *   **Keep Local:** Delete `conflict` file.
    *   **Restore Remote:** Rename `conflict` -> `base` (backup local first?).
    *   **Merge Manual:** User edits `base` in VSCodium; script asks "Did you merge?" -> Delete `conflict` if yes.

## 3. Implementation Plan

### Phase 1: Prototype (CLI)
- Simple scanning and listing.
- `codium --diff` launcher.
- Basic "Accept Local" / "Accept Remote" actions.

### Phase 2: Refinement
- "Safety" backups before overwriting.
- Batch actions (e.g., "Accept all local").

### Phase 3: Integration
- Add to `home-manager` packages.
- Add alias `gdrive-resolve`.

## 4. Open Questions
1.  **Naming Confirmation:** Confirm if existing conflicts are named `.remote-conflict` or just `.conflict` (older runs might have different settings).
2.  **VSCodium Path:** Verify `codium` is in `$PATH`.
3.  **Merge Workflow:** When merging, does the user want to edit the *local* file directly? (Assumed yes).

## 5. References
- rclone bisync docs: https://rclone.org/bisync/
- VS Code CLI: https://code.visualstudio.com/docs/editor/command-line
