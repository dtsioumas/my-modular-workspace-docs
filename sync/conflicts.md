# RClone Bisync - Conflict Resolution & Prevention

**Last Updated:** 2025-12-20
**Sync:** `~/.MyHome/` ↔ `GoogleDrive-dtsioumas0:MyHome/`
**Status:** ✅ **Bisync Working**

---

## Table of Contents

- [Quick Resolution (Conflict Manager)](#quick-resolution-tool)
- [Conflict Prevention Strategies](#conflict-prevention-strategies)
- [Recommended Workflows](#recommended-workflows)
- [Historical Conflicts](#historical-conflicts)

---

## 🛠️ Quick Resolution Tool

The recommended way to resolve conflicts is using the interactive **Conflict Manager** tool.

### Usage

```bash
conflict-manager scan ~/.MyHome
```

### Features
- **TUI Interface:** Easily view and select conflicts.
- **3-Way Merge:** Opens VS Code (if available) with 3 panes (Remote, Base, Local) for smart merging.
- **Batch Actions:** "Keep All Local" or "Restore All Remote".
- **Safety:** Backs up local files before overwriting.

**Installation:**
The tool is installed via home-manager and symlinked to `~/.local/bin/conflict-manager`.

---

## Conflict Prevention Strategies

### 1. Sequential Editing
**Rule:** Only edit on ONE device at a time.
1. Sync BEFORE work: `sync-gdrive`
2. Work...
3. Sync AFTER work: `sync-gdrive`

### 2. Git Safety
**Rule:** Do NOT run `sync-gdrive` while a `git commit` or `git rebase` is active.
- The sync playbook now includes a **Git Safety Check**: It will **ABORT** if it finds an `index.lock` file in the sync path to prevent corrupting your git repositories.

### 3. Use Syncthing for Active Work
- Use Syncthing for real-time syncing of hot files between devices.
- Use GDrive/Bisync for archival/backup syncing (hourly).

---

## 🔍 Manual Conflict Review

If you prefer manual resolution:

1. **Find conflicts:**
   ```bash
   find ~/.MyHome -name "*.conflict*"
   ```

2. **Compare:**
   ```bash
   diff file.txt file.txt.conflict1
   ```

3. **Resolve:**
   - Keep Local: `rm file.txt.conflict1`
   - Keep Remote: `mv file.txt.conflict1 file.txt`

---

## 📜 Historical Conflicts

### Dec 2025
- **Git Repo Corruption Risk:** Mitigated by adding `index.lock` check to playbook.
- **Permissions:** GDrive loses `+x` permissions. Mitigated by `post_task` in playbook that restores executable permissions to scripts in `.local/bin` and `MySpaces`.

### Nov 2025
- **Obsidian workspace.json:** 12 conflicts. Resolved by ignoring ephemeral files.
- **KeePassXC:** Dropbox conflicts. Renamed to backups.

---

**Generated:** 2025-12-20