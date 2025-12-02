# RClone Bisync - Conflict Resolution & Prevention

**Last Updated:** 2025-11-30
**Previous Review:** 2025-11-29 01:00
**Sync:** `~/.MyHome/` ↔ `GoogleDrive-dtsioumas0:MyHome/`
**Status:** ✅ **Bisync Working**

---

## Table of Contents

- [Current Conflicts](#current-conflicts-2025-11-29)
- [Conflict Prevention Strategies](#conflict-prevention-strategies)
- [Recommended Workflows](#recommended-workflows)
- [How to Review Conflicts](#how-to-review-conflicts)
- [Historical Conflicts](#historical-conflicts-previous-review)
- [Automated Conflict Detection](#automated-conflict-detection)

---

## ✅ CONFLICT STATUS (Last Checked: 2025-11-30)

### Current State

**All conflicts resolved!** ✅

| Type | Previous Count | Status | Action Taken |
|------|----------------|--------|--------------|
| Obsidian workspace.json | 12 files | ✅ RESOLVED | Deleted (safe - ephemeral files) |
| KeePassXC vault backups | 2 files | ✅ ARCHIVED | Renamed as `.conflict-backup.kdbx` |

**Check for new conflicts:**
```bash
find ~/.MyHome -name "*.conflict*" -type f
# Currently: Only 2 archived KeePassXC backups
```

---

## 📜 HISTORICAL CONFLICTS (2025-11-29 Review)

### Summary from Nov 29
| Type | Count | Risk | Resolution |
|------|-------|------|------------|
| Obsidian workspace.json | 12 files | LOW | ✅ Deleted Nov 30 |
| KeePassXC vault backups | 2 files | MEDIUM | ✅ Archived as backups |

---

### 1️⃣ Obsidian Workspace Conflicts (12 files)

**Location:** `~/.MyHome/.obsidian/`
**Files:**
- workspace.json (current - 11572 bytes, Nov 29 00:56)
- workspace.json.conflict1 through conflict12

**Analysis:**
- These are **ephemeral state files** (open tabs, pane layout, scroll positions)
- Obsidian regenerates workspace.json on every session
- The current file is the latest and correct

**Risk Level:** 🟢 **LOW** - No data loss possible

**Resolution:**
```bash
# SAFE TO DELETE ALL - Obsidian regenerates on startup
rm ~/.MyHome/.obsidian/workspace.json.conflict*
```

---

### 2️⃣ KeePassXC Vault Conflicted Copies (2 files)

**Location:** `~/.MyHome/MyVault/backups/`
**Files:**
- `mitsio_secrets (D T's conflicted copy 2025-11-13).kdbx` (2.2MB, Nov 13)
- `passwords (D T's conflicted copy 2025-11-04).kdbx` (2.2MB, Nov 4)

**Analysis:**
- These are Dropbox sync conflicts (NOT rclone bisync)
- Dropbox uses "(D T's conflicted copy)" naming
- They contain password database snapshots

**Risk Level:** 🟡 **MEDIUM** - Password data requires careful handling

**Resolution:**
```bash
# Rename for clarity but KEEP for 90 days as safety backup
cd ~/.MyHome/MyVault/backups/
mv "mitsio_secrets (D T's conflicted copy 2025-11-13).kdbx" \
   "mitsio_secrets.2025-11-13.conflict-backup.kdbx"
mv "passwords (D T's conflicted copy 2025-11-04).kdbx" \
   "passwords.2025-11-04.conflict-backup.kdbx"
```

**After 30 days:** Open in KeePassXC, compare entry counts with current vault, delete if identical

---

## 🛡️ Prevention for Future

### 1. Ignore Obsidian workspace.json in bisync
Add to filter file (`~/.config/rclone/bisync-filter.txt`):
```
- .obsidian/workspace.json
- .obsidian/workspace-mobile.json
```

### 2. KeePassXC conflicts are from Dropbox
- These are NOT rclone bisync conflicts
- Dropbox sync with mobile creates these
- Keep using KeePassXC auto-backup feature

---

## 📜 HISTORICAL CONFLICTS (Previous Review)

---

## 📋 Conflicts Detected & Resolved

Τα παρακάτω αρχεία είχαν αλλαγές **και στις δύο πλευρές** (local & remote).
Το bisync δημιούργησε `.conflictN` αντίγραφα για να **ΜΗΝ χαθούν data**.

---

### 1️⃣ `.obsidian/workspace.json`

**Problem:** Changed on both local and Google Drive

**What bisync did:**
- Renamed local version → `.obsidian/workspace.json.conflict7`
- Renamed remote version → `.obsidian/workspace.json.conflict8`
- Copied both conflict versions to both sides

**Files to review:**
```bash
~/.MyHome/.obsidian/workspace.json.conflict7  # Local version
~/.MyHome/.obsidian/workspace.json.conflict8  # Google Drive version
```

**Action needed:**
1. Compare the two files
2. Decide which one to keep (or merge manually)
3. Rename the winner back to `workspace.json`
4. Delete the conflict files

---

### 2️⃣ `llm-core/instructions/all-in-one-instructions.md`

**Problem:** Changed on both local and Google Drive

**What bisync did:**
- Renamed local version → `all-in-one-instructions.md.conflict1`
- Renamed remote version → `all-in-one-instructions.md.conflict2`
- Copied both conflict versions to both sides

**Files to review:**
```bash
~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/instructions/all-in-one-instructions.md.conflict1  # Local version
~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/instructions/all-in-one-instructions.md.conflict2  # Google Drive version
```

**Action needed:**
1. Compare the two files:
   ```bash
   diff ~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/instructions/all-in-one-instructions.md.conflict{1,2}
   ```
2. Decide which one to keep (or merge manually)
3. Rename the winner back to `all-in-one-instructions.md`
4. Delete the conflict files

---

### 3️⃣ `Untitled.md`

**Problem:** Changed on both local and Google Drive

**What bisync did:**
- Detected warning: "New or changed in both paths"
- Likely one version was chosen automatically (check which one survived)

**Files to check:**
```bash
~/.MyHome/Untitled.md
```

**Action needed:**
1. Check if there are `.conflict` versions of this file
2. Review the content to ensure it's the correct version

---

## 🔍 How to Review Conflicts

### Compare conflict files:

```bash
# For .obsidian/workspace.json
diff ~/.MyHome/.obsidian/workspace.json.conflict{7,8}

# For all-in-one-instructions.md
diff ~/.MyHome/MySpaces/my-projects-space/llm-tsukuru-project/llm-core/instructions/all-in-one-instructions.md.conflict{1,2}
```

### Resolve manually:

```bash
# Option 1: Keep local version (conflict7 or conflict1)
mv ~/.MyHome/.obsidian/workspace.json.conflict7 ~/.MyHome/.obsidian/workspace.json
rm ~/.MyHome/.obsidian/workspace.json.conflict8

# Option 2: Keep remote version (conflict8 or conflict2)
mv ~/.MyHome/.obsidian/workspace.json.conflict8 ~/.MyHome/.obsidian/workspace.json
rm ~/.MyHome/.obsidian/workspace.json.conflict7

# Option 3: Merge manually using a text editor
```

---

## Conflict Prevention Strategies

### Understanding Conflict Causes

**A conflict occurs when:**
- Same file modified on BOTH local and remote since last sync
- bisync cannot determine which version is "correct"
- Both versions are preserved as `.conflictN` files

**Common scenarios:**
1. Editing on multiple devices without syncing first
2. Editing in Google Drive web UI
3. Using same file on >1 machine simultaneously
4. Syncthing + bisync both modifying files

---

### Prevention Strategy 1: Sequential Editing

**Rule:** Only edit on ONE device at a time

**Workflow:**
1. Sync BEFORE starting work: `sync-gdrive`
2. Edit files locally
3. Sync AFTER finishing work: `sync-gdrive`
4. THEN switch to another device

**Why this works:**
- Each device gets latest version before editing
- No overlapping modifications
- bisync can determine file history

---

### Prevention Strategy 2: Never Edit in Google Drive Web UI

**Rule:** ALL edits must be local

**Why:**
- Google Drive web edits happen "between" syncs
- bisync sees remote changes without local history
- Creates artificial conflicts

**Exception:** Read-only access is fine

---

### Prevention Strategy 3: Use Syncthing for Active Work

**Rule:** Real-time work → Syncthing, Backup → bisync

**Setup:**
```
Active work files (editing now):
  ~/.MyHome/MySpaces/my-modular-workspace/
  ↓ Syncthing (real-time, P2P)
  Android, Laptop

All files (backup):
  ~/.MyHome/
  ↓ rclone bisync (hourly)
  Google Drive
```

**Why this works:**
- Syncthing handles concurrent edits gracefully
- bisync only sees "finished" work
- No conflicts from active editing

---

### Prevention Strategy 4: Sync Before Starting Work

**Habit:** Always sync before opening files

```bash
# Morning workflow
sync-gdrive          # Pull latest from Google Drive
# WAIT for sync to complete
# THEN start working
```

**Automate with shell alias:**
```bash
alias work='sync-gdrive && echo "✅ Synced. Ready to work!"'
```

---

### Prevention Strategy 5: Use Exclude Patterns

**For files that change frequently on multiple devices:**

Create `~/.config/rclone/bisync-filter.txt`:
```
# Exclude ephemeral Obsidian files
- .obsidian/workspace.json
- .obsidian/workspace-mobile.json
- .obsidian/.trash/**

# Exclude IDE state
- .vscode/settings.json
- .idea/workspace.xml

# Exclude temp files
- *.tmp
- *.swp
- *~
```

**Apply in playbook:**
```yaml
- name: Run bisync
  command: |
    rclone bisync ... \
      --filters-file ~/.config/rclone/bisync-filter.txt
```

---

### Prevention Strategy 6: Hourly Automatic Sync

**Already configured!** Timer runs hourly.

**Why this helps:**
- Reduces window for conflicts (1h max)
- Catches changes quickly
- Less time between sync = less chance of overlap

**Verify:**
```bash
systemctl list-timers rclone-bisync.timer
```

---

## Recommended Workflows

### Workflow 1: Single-Device User

**Best for:** Working primarily on one machine (shoshin)

```
Morning:
1. sync-gdrive (pull latest)
2. Work on shoshin all day
3. Automatic syncs happen hourly
4. Evening: verify sync-gdrive-status

Occasional laptop use:
1. sync-gdrive on laptop
2. Work on laptop
3. sync-gdrive when done
4. Switch back to shoshin
5. sync-gdrive on shoshin
```

**Conflict risk:** 🟢 LOW

---

### Workflow 2: Multi-Device with Syncthing

**Best for:** Frequent switching between devices

```
Setup:
- Syncthing syncs MySpaces/ in real-time
- bisync backs up ALL of MyHome/ hourly

Daily use:
1. Work on any device (Syncthing handles sync)
2. Files sync within seconds
3. bisync backs up to cloud hourly
4. No manual intervention needed
```

**Conflict risk:** 🟢 VERY LOW

---

### Workflow 3: Mobile + Desktop

**Best for:** Note-taking on phone, serious work on desktop

```
Phone (Syncthing):
- Quick notes in Obsidian
- Syncthing syncs to shoshin instantly

Desktop (shoshin):
- All serious work
- Syncthing keeps phone updated
- bisync backs up to cloud

Google Drive:
- Backup only (never edit here)
```

**Conflict risk:** 🟢 VERY LOW

---

## When to Use Which Tool

| Scenario | Tool | Why |
|----------|------|-----|
| Real-time editing | Syncthing | Handles concurrent edits |
| Cloud backup | rclone bisync | Reliable, automatic |
| Mobile access | Syncthing | Real-time, works offline |
| Cross-platform sync | Syncthing | Works everywhere |
| Long-term archive | Google Drive (via bisync) | Cloud storage |

---

## Conflict-Free Architecture

```
┌─────────────────────────────────────────┐
│  SYNCTHING P2P (Real-time, <1s)         │
│  shoshin ↔ laptop ↔ Android             │
│                                          │
│  Folder: MySpaces/                       │
│  Conflicts: Auto-resolved with versions │
└─────────────────────────────────────────┘
             │
             │ (shoshin is hub)
             ▼
┌─────────────────────────────────────────┐
│  RCLONE BISYNC (Hourly backup)          │
│  shoshin → Google Drive                 │
│                                          │
│  Folder: MyHome/ (all files)            │
│  Conflicts: Rare (only shoshin writes)  │
└─────────────────────────────────────────┘
```

**Why this works:**
- Syncthing handles all device synchronization
- Only shoshin writes to Google Drive (via bisync)
- No overlapping modifications to Google Drive
- Conflicts only if you edit in Google Drive web UI (don't!)

---

## Best Practices Summary

✅ **DO:**
- Sync before starting work
- Use Syncthing for active files
- Let hourly timer run automatically
- Review conflicts weekly
- Delete obsolete conflicts after resolving

❌ **DON'T:**
- Edit same file on >1 device without syncing
- Edit files in Google Drive web UI
- Work during sync (wait for completion)
- Ignore conflict notifications
- Disable automatic timer

---

## 🚀 Automated Conflict Detection

Το Ansible playbook που δημιούργησα έχει:

### 1. **Dry-run first** (πάντα!)
```bash
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --tags dry-run
```

### 2. **Conflict check**
```bash
ansible-playbook -i inventories/hosts playbooks/rclone-gdrive-sync.yml --tags check-conflicts
```

### 3. **Notifications**
- Desktop notification αν βρεθούν conflicts
- Log με λεπτομέρειες

---

## 📊 Other Warnings (Not Critical)

**"WARNING: hash unexpectedly blank"**
- Αυτό είναι φυσιολογικό για **πρώτο bisync run**
- Το bisync χτίζει το baseline hash database
- Θα εξαφανιστούν στα επόμενα syncs
- **Δεν επηρεάζουν τα data!**

---

## ✅ Conclusion

**Sync Status:** ✅ **SUCCESSFUL**
**Data Lost:** ❌ **NONE** (όλα τα conflicts έγιναν .conflictN copies)
**Action Required:** Review τα 2-3 conflict files παραπάνω

---

**Next Steps:**
1. Review conflicts (diff τα .conflict* files)
2. Decide winner for each conflict
3. Delete conflict files μετά το merge
4. Enable hourly timer: `systemctl --user enable rclone-gdrive-sync.timer`
5. Use Syncthing για real-time sync (για active work)

---

**Generated:** 2025-11-21
**By:** Claude Code + Μήτσο
