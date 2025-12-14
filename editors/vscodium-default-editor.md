# VSCodium as Default Editor

**Date:** 2025-12-12
**Status:** ✅ Ready for deployment

---

## Overview

Configures VSCodium as the system-wide default editor with proper file opening behavior and home directory as default.

---

## Configuration Files (All via Chezmoi)

### 1. VSCodium Settings
**File:** `~/.config/VSCodium/User/settings.json`
**Managed by:** chezmoi template

**Key Settings:**
- Default directory: `$HOME`
- Open files in same window
- No preview tabs
- Auto-save enabled (1s delay)
- Format on save: disabled
- Trim trailing whitespace: enabled

### 2. XDG Default Applications
**File:** `~/.config/mimeapps.list`
**Managed by:** chezmoi template

**Associates VSCodium with:**
- All text files (`text/plain`, `text/markdown`)
- Source code files (Python, C/C++, shell scripts)
- Config files (JSON, YAML, TOML, XML)
- Nix files

### 3. Environment Variables
**File:** `~/.bashrc.d/editor.sh`
**Managed by:** chezmoi template

**Sets:**
```bash
export EDITOR="codium --wait"
export VISUAL="codium --wait"
```

**Helpers:**
- `edit` command - opens files in VSCodium
- `e` alias - shortcut for edit
- Fallback to vim if VSCodium not available

### 4. Git Integration
**File:** `~/.gitconfig.d/editor.gitconfig`
**Managed by:** chezmoi template

**Configures:**
- Git editor: `codium --wait`
- Diff tool: codium
- Merge tool: codium

---

## Features

### File Opening Behavior
```json
"window.openFoldersInNewWindow": "off"
"window.openFilesInNewWindow": "off"
"workbench.editor.enablePreview": false
"files.defaultLocation": "$HOME"
```

**What this means:**
- New files open in existing window
- No preview tabs (permanent tabs immediately)
- Default open dialog starts at home directory

### Editor Settings
- **Font:** JetBrains Mono, Fira Code (with ligatures)
- **Font Size:** 14px
- **Tab Size:** 2 spaces (auto-detect)
- **Rulers:** 80, 120 columns
- **Minimap:** Enabled
- **Breadcrumbs:** Enabled

### Auto-Save
- **Enabled:** Yes
- **Delay:** 1 second
- **Trim trailing whitespace:** Yes
- **Insert final newline:** Yes

### Performance
- **Max memory for large files:** 4GB
- **Max search results:** 20,000
- **Telemetry:** Disabled

---

## Language-Specific Settings

### Markdown
- Word wrap: on
- Quick suggestions: off

### Nix
- Tab size: 2 spaces

### Python
- Tab size: 4 spaces

### Go
- Tabs (not spaces)
- Tab size: 4

---

## Usage

### Open files from terminal
```bash
# Using editor command
edit myfile.txt

# Using e alias
e myfile.txt

# Using $EDITOR
$EDITOR myfile.txt

# Direct
codium myfile.txt
```

### Git integration
```bash
# Commit message editor
git commit  # Opens VSCodium

# Diff
git difftool

# Merge conflicts
git mergetool
```

### XDG integration
```bash
# Open any text file with default app
xdg-open myfile.txt  # Opens in VSCodium
```

---

## Deployment Steps

### 1. Apply home-manager
```bash
home-manager switch
```
(No changes needed - VSCodium already installed)

### 2. Apply chezmoi
```bash
chezmoi apply
```

**This will:**
- Create VSCodium settings
- Set up XDG associations
- Configure environment variables
- Set up git integration

### 3. Restart shell
```bash
# Reload bashrc
source ~/.bashrc

# Or start new terminal
```

### 4. Verify
```bash
# Check editor variable
echo $EDITOR
# Expected: codium --wait

# Test opening file
edit ~/.bashrc
# Should open in VSCodium
```

---

## Fixes Applied

### KeePassXC Service Issue ✅
**Problem:** `KeePassXC: Unknown option 'minimize'`

**Fix:** Removed `--minimize` flag from keepassxc.nix
```diff
- ExecStart = "${pkgs.keepassxc}/bin/keepassxc --minimize";
+ ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
```

**Status:** Fixed, need to rebuild home-manager

---

## Files Created/Modified

### Chezmoi
```
private_dot_config/
├── VSCodium/User/settings.json.tmpl       # NEW - Editor settings
├── mimeapps.list.tmpl                     # NEW - XDG associations

dot_bashrc.d/
└── editor.sh.tmpl                         # NEW - Environment variables

dot_gitconfig.d/
└── editor.gitconfig.tmpl                  # NEW - Git integration
```

### home-manager
```
keepassxc.nix                              # MODIFIED - Fixed --minimize
```

---

## Action Confidence

| Component | Confidence | Band |
|-----------|-----------|------|
| VSCodium settings | 0.95 | C |
| XDG associations | 0.92 | C |
| Environment variables | 0.95 | C |
| Git integration | 0.93 | C |
| KeePassXC fix | 0.98 | C |
| **Overall** | **0.94** | **C** |

---

**Created:** 2025-12-12T02:25:00+02:00 (Europe/Athens)
**Ready for:** chezmoi apply
