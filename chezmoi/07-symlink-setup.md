# Chezmoi Symlink Setup

**Date:** 2025-11-19
**Purpose:** Document symlink approach for chezmoi source directory

---

## Architecture

### Before (Separate Directories)
```
~/.local/share/chezmoi/          # Chezmoi source (Git repo)
└── (separate from workspace)

~/.MyHome/MySpaces/my-modular-workspace/dotfiles/
└── (workspace dotfiles - not tracked)
```

**Problem:** Duplication, manual copying required

### After (Symlinked)
```
~/.local/share/chezmoi -> ~/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Single source of truth in workspace!
```

**Benefits:**
- ✅ Work directly in workspace
- ✅ No duplication
- ✅ Git repo in workspace
- ✅ Easier to manage
- ✅ Consistent with other workspace tools

---

## How It Was Set Up

**Step 1: Backup existing chezmoi**
```bash
mv ~/.local/share/chezmoi ~/.local/share/chezmoi.backup
```

**Step 2: Move Git repository**
```bash
mv ~/.local/share/chezmoi.backup/.git ~/.MyHome/MySpaces/my-modular-workspace/dotfiles/
```

**Step 3: Copy remaining files**
```bash
cp -r ~/.local/share/chezmoi.backup/* ~/.MyHome/MySpaces/my-modular-workspace/dotfiles/
```

**Step 4: Create symlink**
```bash
ln -s ~/.MyHome/MySpaces/my-modular-workspace/dotfiles ~/.local/share/chezmoi
```

**Step 5: Verify**
```bash
ls -la ~/.local/share/chezmoi  # Should show symlink
chezmoi managed  # Should list all files
```

---

## Directory Structure

```
~/.MyHome/MySpaces/my-modular-workspace/dotfiles/
├── .git/                        # Git repository
├── .chezmoiignore               # Ignore patterns
├── README.md                    # Dotfiles README
│
├── dot_config/                  # Managed configs
│   ├── atuin/                   # Shell history
│   ├── copyq/                   # Clipboard manager
│   ├── autostart/               # Desktop autostart
│   └── navi/                    # Cheatsheet tool
│
├── dot_local/                   # Local files
│   └── share/navi/cheats/       # Navi cheatsheets
│
└── (other dotfiles directories - not yet managed by chezmoi)
    ├── kitty/
    ├── llm-cli/
    └── ...
```

---

## Working with This Setup

### Adding New Configs

**Work directly in workspace:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Add new config
chezmoi add ~/.bashrc

# Edit
chezmoi edit ~/.bashrc

# Or edit directly
vim dot_bashrc.tmpl

# Apply
chezmoi apply
```

### Git Operations

**Commit from workspace:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles

git status
git add .
git commit -m "Update configs"
git push
```

**Or use chezmoi git:**
```bash
chezmoi cd
git add .
git commit -m "Update configs"
git push
exit
```

Both work the same - symlink makes them equivalent!

---

## Symlink Benefits

### Single Source of Truth
- No confusion about which directory is current
- No manual copying between directories
- All changes immediately visible

### Workspace Integration
- Consistent with other workspace tools
- Version control in workspace
- Easy backup with workspace

### Chezmoi Compatibility
- Chezmoi works transparently
- All commands work normally
- No performance impact

---

## Verification

**Check symlink:**
```bash
ls -la ~/.local/share/ | grep chezmoi
# Output: chezmoi -> /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles
```

**Test chezmoi:**
```bash
chezmoi managed
chezmoi diff
chezmoi apply
```

**Test git:**
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
git status
git log
```

---

## Backup

The original chezmoi source is backed up at:
```
~/.local/share/chezmoi.backup/
```

**Can be safely deleted after verifying setup works:**
```bash
rm -rf ~/.local/share/chezmoi.backup
```

---

## Troubleshooting

### Broken Symlink

If workspace isn't mounted:
```bash
ls -la ~/.local/share/chezmoi
# Shows broken symlink (red)

# Fix: ensure ~/.MyHome is mounted
```

### Chezmoi Commands Fail

```bash
# Check symlink
readlink -f ~/.local/share/chezmoi

# Re-create if needed
rm ~/.local/share/chezmoi
ln -s ~/.MyHome/MySpaces/my-modular-workspace/dotfiles ~/.local/share/chezmoi
```

### Want to Revert

```bash
# Remove symlink
rm ~/.local/share/chezmoi

# Restore backup
mv ~/.local/share/chezmoi.backup ~/.local/share/chezmoi
```

---

## Advantages of This Approach

1. **Workspace-Centric**
   - All dotfiles in workspace
   - Easy to find and edit
   - Consistent location

2. **Git Integration**
   - Git repo in workspace
   - Committed with workspace changes
   - Easy to sync

3. **No Duplication**
   - Single copy of files
   - No confusion
   - Less disk space

4. **Transparent to Chezmoi**
   - Works exactly the same
   - No config changes needed
   - All commands work

5. **Easy Collaboration**
   - Share entire workspace
   - Dotfiles included
   - Reproducible setup

---

## Related Files

- **Symlink:** `~/.local/share/chezmoi` → `~/.MyHome/MySpaces/my-modular-workspace/dotfiles`
- **Home-Manager Symlink:** `~/.config/chezmoi-dotfiles` → `~/.local/share/chezmoi`
  - (Now transitively points to workspace!)
- **Config:** `~/.config/chezmoi/chezmoi.toml`

---

**Created:** 2025-11-19
**Status:** ✅ Active
**Backup:** `~/.local/share/chezmoi.backup` (can be deleted)
