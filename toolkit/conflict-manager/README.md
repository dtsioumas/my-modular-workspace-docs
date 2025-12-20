# Conflict Manager

A powerful interactive TUI tool for resolving `rclone bisync`, `Dropbox`, and `Syncthing` conflicts.

## Features

- **VS Code Integration:** Support for native 3-Way Merge Editor and CodeLens.
- **TUI:** Beautiful terminal interface using Rich.
- **Safety:** Automatic backups before overwriting files.
- **Batch Operations:** Keep All / Restore All.
- **Universal:** Supports Rclone, Dropbox, Syncthing.

## Installation

```bash
nix-shell -p python3 python3Packages.rich python3Packages.typer
# Or if installed via toolkit:
conflict-manager scan ~/.MyHome
```

## Usage

```bash
conflict-manager scan <path> [OPTIONS]
```

### Options

*   `--exclude-git / --no-exclude-git`: Exclude .git directories (default: True)

### Interactive Modes

1.  **[m]erge (Markers):** Synthesizes Git conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) in a temporary file. Ideal for quick edits using VS Code "Accept Current/Incoming" buttons (CodeLens).
2.  **[3] 3-Way Merge:** Opens the full VS Code Merge Editor (3 panes). Note: Since rclone doesn't provide a common base file, the "Base" (center) pane is empty.
3.  **[d]iff:** View-only diff.
4.  **[k]eep Local:** Deletes the remote conflict file.
5.  **[r]estore Remote:** Overwrites local file with the conflict version (backs up local first).
