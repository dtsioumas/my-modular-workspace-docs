# chezmoi_modify_manager Cheatsheet

**Quick Reference for Managing KDE/INI Configs with Chezmoi**

---

## What Is This Tool?

`chezmoi_modify_manager` filters INI config files so you only track what matters, not volatile window sizes, recent files, etc.

**Use it for:** KDE Plasma configs, any `.ini`/`.rc` files with `[Section]` format

---

## Basic Workflow

### 1. After Making GUI Changes

```bash
# Sync a single config file
chezmoi_modify_manager --smart-add ~/.config/katerc

# The tool automatically:
# - Updates the .src.ini file (source)
# - Preserves your filtering rules
# - Only syncs tracked sections
```

### 2. Review Changes

```bash
chezmoi cd && git diff
```

### 3. Commit & Push

```bash
chezmoi cd
git add .
git commit -m "Update Kate settings"
git push
```

---

## Common Commands

| Task | Command |
|------|---------|
| **Sync GUI change to chezmoi** | `chezmoi_modify_manager --smart-add ~/.config/FILE` |
| **Add new config to chezmoi** | `chezmoi_modify_manager --add ~/.config/FILE` |
| **Check what changed** | `chezmoi status` |
| **See differences** | `chezmoi diff ~/.config/FILE` |
| **View chezmoi source** | `chezmoi cd` (opens source directory) |
| **Apply chezmoi to system** | `chezmoi apply ~/.config/FILE` |

---

## File Structure

When you add a config with chezmoi_modify_manager, you get:

```
~/.local/share/chezmoi/
└── dot_config/
    ├── katerc.src.ini          # Source (what you edit)
    └── modify_katerc           # Filter script (what gets applied)
```

**Important:** The `.src.ini` is the "source of truth" you edit or sync to.

---

## Your Plasma Configs (Real Examples)

### Application Configs

```bash
# Dolphin file manager
chezmoi_modify_manager --smart-add ~/.config/dolphinrc

# Konsole terminal
chezmoi_modify_manager --smart-add ~/.config/konsolerc

# Kate text editor
chezmoi_modify_manager --smart-add ~/.config/katerc

# Okular PDF viewer
chezmoi_modify_manager --smart-add ~/.config/okularrc
```

### Core Desktop Configs

```bash
# Keyboard layouts
chezmoi_modify_manager --smart-add ~/.config/kxkbrc

# Plasma theme
chezmoi_modify_manager --smart-add ~/.config/plasmarc

# Global shortcuts
chezmoi_modify_manager --smart-add ~/.config/kglobalshortcutsrc

# Window manager
chezmoi_modify_manager --smart-add ~/.config/kwinrc
```

---

## Understanding the Modify Script

Every config has a `modify_*` script in chezmoi source:

```bash
#!/usr/bin/env chezmoi_modify_manager
# This is the filter script

source auto

# Ignore volatile sections (preserved from target)
ignore section "MainWindow"
ignore section "Recent Files"

# Ignore by regex
ignore regex "^Activities\\[.*\\]$" ".*"
```

**What it does:**
- `source auto` = Find the .src.ini file automatically
- `ignore section` = Don't track this section (preserve from target file)
- `ignore regex` = Ignore sections matching pattern

---

## Common Patterns

### Ignore Window Sizes

```bash
ignore section "MainWindow"
ignore section "FileDialogSize"
```

### Ignore Recent Files

```bash
ignore section "Recent Files"
ignore section "RecentDocuments"
```

### Ignore Activity UUIDs

```bash
ignore section "ActivityManager"
ignore regex "^Activities\\[.*\\]$" ".*"
```

### Ignore All Token Sections

```bash
ignore regex "^token_.*" ".*"
```

---

## Editing Configs

### Option 1: Via GUI (Recommended)

1. Change settings in KDE System Settings
2. Run: `chezmoi_modify_manager --smart-add ~/.config/FILE`
3. Done!

### Option 2: Edit Source Directly

```bash
# Edit the source file
chezmoi edit ~/.config/katerc

# Apply changes
chezmoi apply ~/.config/katerc
```

### Option 3: Edit and Test

```bash
# Edit source
nano ~/.local/share/chezmoi/dot_config/katerc.src.ini

# See what would change
chezmoi diff ~/.config/katerc

# Apply
chezmoi apply ~/.config/katerc
```

---

## Troubleshooting

### "No such file or directory"

**Problem:** Config not managed by chezmoi yet

**Solution:**
```bash
# Add it first
chezmoi_modify_manager --add ~/.config/FILE
```

### "Modify script failed"

**Problem:** Syntax error in modify script

**Solution:**
```bash
# Check the modify script
cat ~/.local/share/chezmoi/dot_config/modify_FILE

# Fix syntax (usually missing quotes or backslashes)
chezmoi edit --apply ~/.config/FILE
```

### "Changes not showing in chezmoi"

**Problem:** File might not be tracked or already in sync

**Solution:**
```bash
# Check if managed
chezmoi managed | grep FILE

# Force re-add
chezmoi_modify_manager --smart-add ~/.config/FILE
```

---

## Shell Aliases (Add to ~/.bashrc)

### Quick Sync Function

```bash
# Quick sync KDE config to chezmoi
cm-sync() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Usage: cm-sync <file>"
        echo "Example: cm-sync ~/.config/katerc"
        return 1
    fi

    # Auto-detect INI files
    if [[ "$file" == *"rc" ]] || grep -q "^\[.*\]$" "$file" 2>/dev/null; then
        echo "📝 INI file - using modify_manager..."
        chezmoi_modify_manager --smart-add "$file"
    else
        echo "📝 Regular file - using chezmoi..."
        chezmoi re-add "$file"
    fi

    echo -e "\n📊 Changes:"
    chezmoi cd && git diff

    echo -e "\n💾 Commit? (y/n)"
    read -r reply
    if [[ $reply =~ ^[Yy]$ ]]; then
        echo "✏️  Message:"
        read -r msg
        chezmoi cd && git add . && git commit -m "$msg" && git push
        echo "✅ Synced!"
    fi
}

# Quick status
alias cm-status='chezmoi status'

# Quick diff
alias cm-diff='chezmoi diff'

# Open chezmoi source
alias cm-cd='cd $(chezmoi source-path)'
```

**Usage:**
```bash
cm-sync ~/.config/katerc   # Syncs any file
cm-status                  # Shows changed files
cm-diff ~/.config/kwinrc  # Shows specific diff
cm-cd                     # Go to chezmoi source
```

---

## Advanced: Filter Config (.kdl files)

You can also create separate filter configs (optional, modify script is usually enough):

```bash
# Create filter config
cat > ~/.config/chezmoi_modify_manager/katerc.kdl << 'EOF'
filter {
  # Ignore volatile sections
  ignore-section "^MainWindow$"
  ignore-section "^Recent Files$"

  # Keep stable sections
  keep-section "^General$"
  keep-section "^Editor$"
}
EOF
```

**Note:** For most cases, the modify script is simpler and sufficient.

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│ CHEZMOI_MODIFY_MANAGER QUICK CARD                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  After GUI Change:                                      │
│    chezmoi_modify_manager --smart-add ~/.config/FILE   │
│                                                         │
│  Review:                                                │
│    chezmoi cd && git diff                               │
│                                                         │
│  Commit:                                                │
│    chezmoi cd && git commit -am "msg" && git push       │
│                                                         │
│  Check Status:                                          │
│    chezmoi status                                       │
│                                                         │
│  View Diff:                                             │
│    chezmoi diff ~/.config/FILE                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Real-World Examples

### Example 1: Changed Kate Color Scheme

```bash
# 1. Changed via System Settings → Appearance
# 2. Sync to chezmoi
chezmoi_modify_manager --smart-add ~/.config/katerc

# 3. Review
chezmoi cd && git diff
# Shows: color scheme changed in [KTextEditor] section

# 4. Commit
chezmoi cd
git commit -am "Kate: Switch to Dracula theme"
git push
```

### Example 2: Added New Keyboard Shortcut

```bash
# 1. Added shortcut via System Settings → Shortcuts
# 2. Sync
chezmoi_modify_manager --smart-add ~/.config/kglobalshortcutsrc

# 3. Commit
chezmoi cd && git commit -am "Add Meta+T for terminal" && git push
```

### Example 3: Changed Virtual Desktop Names

```bash
# 1. Renamed desktops via System Settings → Virtual Desktops
# 2. Sync
chezmoi_modify_manager --smart-add ~/.config/kwinrc

# 3. Commit
chezmoi cd && git commit -am "Update desktop names" && git push
```

---

## Tips & Best Practices

### ✅ DO

- Use `--smart-add` for existing configs (updates source)
- Use `--add` only for new configs (first time)
- Review with `git diff` before committing
- Write meaningful commit messages
- Commit related changes together

### ❌ DON'T

- Don't use `chezmoi add` for modify_manager files (won't update .src.ini)
- Don't edit both GUI and source at same time (confusion)
- Don't ignore errors - check what went wrong
- Don't commit without reviewing (might capture temporary settings)

---

## Learning Path

### Week 1: Get Comfortable

- Use GUI to change settings
- Run `chezmoi_modify_manager --smart-add` for each change
- Review diffs, commit manually

### Week 2: Understand Filtering

- Look at your modify scripts: `cat ~/.local/share/chezmoi/dot_config/modify_*`
- Understand what's ignored vs tracked
- Maybe tweak ignore patterns if needed

### Week 3: Optimize Workflow

- Set up shell aliases
- Consider batching commits
- Decide on automation level

---

## Help & Resources

### Get Help

```bash
# Tool help
chezmoi_modify_manager --help

# Syntax help
chezmoi_modify_manager --help-syntax

# Check version
chezmoi_modify_manager --version
```

### Documentation

- Tool repo: https://github.com/VorpalBlade/chezmoi_modify_manager
- Your docs: `~/.MyHome/MySpaces/my-modular-workspace/docs/plasma/`
- Phase reports: See `phase1-completion.md`, `phase2-completion.md`, `phase3-completion.md`

### Ask Claude Code

If stuck, ask Claude Code - they helped you set all this up! 😊

---

## Summary

**The workflow is simple:**

1. Change settings via GUI ✏️
2. `chezmoi_modify_manager --smart-add FILE` 🔄
3. `chezmoi cd && git diff` 👀
4. `git commit && git push` 💾

**That's it!** Everything else is optimization.

---

**Created:** 2025-12-09
**Your Plasma Migration:** Phase 3 Complete ✅
**Status:** 8/8 configs managed with chezmoi_modify_manager
