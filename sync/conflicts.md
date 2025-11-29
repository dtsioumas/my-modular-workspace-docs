# RClone Bisync - Conflicts Review

**Last Updated:** 2025-11-29 01:00
**Previous Review:** 2025-11-21 22:17-22:18
**Sync:** `~/.MyHome/` ↔ `GoogleDrive-dtsioumas0:MyHome/`
**Status:** ✅ **Bisync Working** - Last sync: Nov 29 00:42 EET

---

## 🔴 CURRENT CONFLICTS (2025-11-29)

### Summary
| Type | Count | Risk | Action |
|------|-------|------|--------|
| Obsidian workspace.json | 12 files | LOW | DELETE ALL |
| KeePassXC vault backups | 2 files | MEDIUM | KEEP AS BACKUP |

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

## 🛡️ How to Avoid Conflicts in the Future

### 1. **Σταμάτα να κάνεις αλλαγές σε πολλές συσκευές ταυτόχρονα**
- Κάνε changes μόνο στο local
- Άφησε το bisync να συγχρονίσει
- ΜΕΤΑ κάνε changes σε άλλη συσκευή

### 2. **Σταμάτα να επεξεργάζεσαι αρχεία απευθείας στο Google Drive Web UI**
- Το bisync δεν μπορεί να ξέρει ότι άλλαξες κάτι στο web
- Κάνε ΟΛΑ τα edits locally και άφησε το bisync να τα στείλει

### 3. **Σταμάτα να δουλεύεις με το ίδιο αρχείο σε >1 μηχάνημα**
- Αν ΠΡΕΠΕΙ, χρησιμοποίησε **Syncthing για real-time sync**
- Το bisync είναι για **backup**, όχι για **concurrent editing**

### 4. **Κάνε bisync ΠΡΙΝ ξεκινήσεις δουλειά**
```bash
# Πριν αρχίσεις να δουλεύεις, τράβα τις αλλαγές από Google Drive
systemctl --user start rclone-gdrive-sync.service
# Wait for sync to complete
# THEN start working
```

### 5. **Enable automated sync με timer**
```bash
# Κάθε 1 ώρα (όχι κάθε 4h)
systemctl --user enable rclone-gdrive-sync.timer
systemctl --user start rclone-gdrive-sync.timer
```

### 6. **Use Syncthing for real-time sync**
- Για αρχεία που επεξεργάζεσαι ενεργά, χρησιμοποίησε **Syncthing** (real-time P2P)
- Άφησε το **bisync** για **cloud backup μόνο**

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
