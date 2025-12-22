# Obsidian Integration with kitty Terminal - Research Findings

**Date:** 2025-12-22
**Researcher:** Claude Opus 4.5
**Vault Location:** `~/.MyHome/`

---

## Executive Summary

Obsidian can be integrated with kitty terminal through three main approaches:
1. **URI Scheme** - Using `obsidian://` protocol for external control
2. **File System Access** - Direct manipulation of markdown files in vault
3. **Hybrid Workflow** - Combining terminal markdown viewers with Obsidian GUI

**Key Finding:** True overlay/panel integration is NOT possible due to Electron architecture limitations, but practical workflows exist for quick capture and note preview.

---

## 1. Obsidian URI Scheme

### 1.1 Official URI Support

**Available Since:** Obsidian v1.7.4+ (October 2024)

**Core Actions:**

```bash
# Open specific note
obsidian://open?vault=MyVault&file=path/to/note.md

# Create new note
obsidian://new?vault=MyVault&file=new-note.md&content=Initial%20content

# Append to existing note (v1.7.4+)
obsidian://open?vault=MyVault&file=note.md&append=true&content=New%20content

# Prepend to existing note (v1.7.4+)
obsidian://open?vault=MyVault&file=note.md&prepend=true&content=Top%20content

# Open daily note
obsidian://daily?vault=MyVault

# Search vault
obsidian://search?vault=MyVault&query=search%20term
```

**Parameter Requirements:**
- All values must be URI encoded
- Vault name can be either display name or vault ID
- File paths are relative to vault root
- `.md` extension can be omitted

### 1.2 Advanced URI Plugin

**Plugin:** [obsidian-advanced-uri](https://github.com/Vinzent03/obsidian-advanced-uri)
**Stars:** 1,000+
**Protocol:** `obsidian://adv-uri?` or shorter `obsidian://advanced-uri?`

**Extended Capabilities:**

#### Write Operations
```bash
# Append with clipboard
obsidian://adv-uri?vault=MyVault&daily=true&clipboard=true&mode=append

# Append with data parameter
obsidian://adv-uri?vault=MyVault&filepath=Inbox&mode=append&data=Your%20note%20here

# Prepend to note
obsidian://adv-uri?vault=MyVault&filepath=note&mode=prepend&data=Top%20content

# Write at specific line
obsidian://adv-uri?vault=MyVault&filepath=note&line=10&data=Insert%20here
```

#### Command Execution
```bash
# Execute any Obsidian command
obsidian://adv-uri?vault=MyVault&commandid=workspace:export-pdf&filepath=document.md

# Open with specific command after
obsidian://adv-uri?vault=MyVault&filepath=note&commandid=editor:toggle-source
```

#### Navigation
```bash
# Navigate to heading
obsidian://adv-uri?vault=MyVault&filepath=note&heading=Goal

# Navigate to block
obsidian://adv-uri?vault=MyVault&filepath=note&block=^block-id

# Open in new pane
obsidian://adv-uri?vault=MyVault&filepath=note&newpane=true
```

#### Frontmatter Manipulation
```bash
# Set frontmatter field
obsidian://adv-uri?vault=MyVault&filepath=note&frontmatterkey=status&frontmattervalue=done

# Update nested frontmatter
obsidian://adv-uri?vault=MyVault&filepath=note&frontmatterkey=metadata.author&frontmattervalue=John
```

#### Search and Replace
```bash
# Replace within file
obsidian://adv-uri?vault=MyVault&filepath=note&search=old&replace=new
```

---

## 2. Terminal Integration Workflows

### 2.1 Quick Capture Scripts

#### Option A: URI-Based Capture

```bash
#!/bin/bash
# File: ~/.local/bin/onote
# Quick capture to Obsidian Inbox

VAULT="MyVault"
INBOX="Inbox"

if [ -p /dev/stdin ]; then
    CONTENT=$(cat)
else
    CONTENT="$*"
fi

# Encode and send
ENCODED=$(echo "$CONTENT" | jq -sRr @uri)
xdg-open "obsidian://adv-uri?vault=$VAULT&filepath=$INBOX&mode=append&data=$ENCODED"

echo "✓ Added to Obsidian Inbox"
```

**Usage:**
```bash
onote "Quick thought"
echo "Longer note from command" | onote
```

#### Option B: Direct File System Append (Faster)

```bash
#!/bin/bash
# File: ~/.local/bin/odaily
# Append to today's daily note

VAULT_PATH=~/.MyHome/vault
DAILY_NOTE="$VAULT_PATH/Daily/$(date +%Y-%m-%d).md"

# Create if doesn't exist
if [ ! -f "$DAILY_NOTE" ]; then
    cat > "$DAILY_NOTE" <<EOF
# $(date +%Y-%m-%d)

## Notes

EOF
fi

# Append with timestamp
echo -e "\n- $(date +%H:%M) - $*" >> "$DAILY_NOTE"
echo "✓ Added to Daily Note"
```

**Usage:**
```bash
odaily "Meeting notes: Discussed project timeline"
```

#### Option C: Clipboard to Obsidian

```bash
#!/bin/bash
# File: ~/.local/bin/oclip
# Send clipboard to Obsidian

VAULT="MyVault"
DAILY_NOTE="Daily/$(date +%Y-%m-%d)"

xdg-open "obsidian://adv-uri?vault=$VAULT&filepath=$DAILY_NOTE&clipboard=true&mode=append"
```

### 2.2 kitty Configuration

```conf
# ~/.config/kitty/kitty.conf

# Preview today's daily note in overlay
map ctrl+alt+d launch --type=overlay glow ~/.MyHome/vault/Daily/$(date +%Y-%m-%d).md

# Preview inbox
map ctrl+alt+i launch --type=overlay bat --paging=never --style=plain ~/.MyHome/vault/Inbox.md

# Open Obsidian to vault
map ctrl+alt+o launch --type=background xdg-open "obsidian://open?vault=MyVault"

# Quick capture from selection
map ctrl+alt+c pipe @selection ~/.local/bin/onote

# Edit inbox in neovim overlay
map ctrl+alt+e launch --type=overlay nvim ~/.MyHome/vault/Inbox.md
```

### 2.3 Shell Integration

```bash
# ~/.bashrc or ~/.zshrc

# Quick note functions
alias onote='~/.local/bin/onote'
alias odaily='~/.local/bin/odaily'

# Preview functions
alias opreview='glow ~/.MyHome/vault'
alias oinbox='bat ~/.MyHome/vault/Inbox.md'
alias otoday='bat ~/.MyHome/vault/Daily/$(date +%Y-%m-%d).md'

# Open Obsidian
alias oopen='xdg-open "obsidian://open?vault=MyVault"'

# Search vault from terminal
osearch() {
    xdg-open "obsidian://search?vault=MyVault&query=$(echo "$*" | jq -sRr @uri)"
}

# Create note and open
onew() {
    local note_name="$1"
    shift
    local content="$*"
    local encoded=$(echo "$content" | jq -sRr @uri)
    xdg-open "obsidian://new?vault=MyVault&file=$note_name&content=$encoded"
}
```

---

## 3. Panel/Overlay Integration

### 3.1 Technical Limitations

**Why Obsidian Cannot Be Embedded in kitty:**

1. **Electron Architecture:**
   - Obsidian is built on Electron (Chromium + Node.js)
   - Electron apps run as separate OS-level windows
   - Cannot be embedded into other applications without significant hacks

2. **kitty Panel Kitten Limitations:**
   - Panel kitten only supports terminal programs
   - Renders to GPU-accelerated surface layer
   - No support for embedding GUI applications

3. **No Standard Embedding Protocol:**
   - X11 XEmbed protocol was deprecated
   - Wayland has no equivalent
   - Modern browsers/Electron apps removed embedding support for security

### 3.2 Practical Workarounds

#### Approach 1: Floating Obsidian Window (KDE Plasma)

Create window rules for quick-access Obsidian:

**KDE Window Rule Configuration:**
```
Window Class: obsidian
Window Title: Quick Notes  # Create separate vault for quick notes

Position: Fixed
  - X: Center
  - Y: Center
  - Width: 800px
  - Height: 600px

Appearance:
  - Above: Force Yes
  - Skip Taskbar: Yes
  - Skip Pager: Yes
  - Skip Switcher: No

Shortcuts:
  - Global Shortcut: Meta+O
```

**Launch Command:**
```bash
#!/bin/bash
# Launch minimal Obsidian window
obsidian --new-window "obsidian://open?vault=QuickNotes&file=Inbox"
```

#### Approach 2: Terminal Markdown Editor in Overlay

Instead of Obsidian overlay, use terminal markdown editor:

**neovim with markdown preview:**
```lua
-- ~/.config/nvim/lua/plugins/markdown.lua
return {
  {
    'iamcco/markdown-preview.nvim',
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  {
    'preservim/vim-markdown',
    ft = { "markdown" },
  }
}
```

**kitty keybinding:**
```conf
# Edit vault note in neovim overlay with live preview
map ctrl+alt+n launch --type=overlay nvim -c "MarkdownPreview" ~/.MyHome/vault/Inbox.md
```

#### Approach 3: kitty Hints for Obsidian Links

Create custom hint kitten to extract `obsidian://` URIs from terminal output:

```python
# ~/.config/kitty/hints_obsidian.py
import re

def mark(text, args, Mark, extra_cli_args, *a):
    """Find obsidian:// URIs in terminal output"""
    for idx, match in enumerate(re.finditer(r'obsidian://[^\s]+', text)):
        yield Mark(idx, match.start(), match.end(), text[match.start():match.end()], {})

def handle_result(args, data, target_window_id, boss, extra_cli_args):
    """Open selected URI"""
    if data:
        import subprocess
        subprocess.Popen(['xdg-open', data])
```

**Usage in kitty.conf:**
```conf
# Detect and open obsidian:// links
map ctrl+shift+o kitten hints --type=linenum --program=/path/to/hints_obsidian.py
```

---

## 4. Markdown Terminal Viewers

### 4.1 Tool Comparison

| Tool | Syntax Highlighting | Images | Tables | Links | Live Reload | Installation |
|------|---------------------|--------|--------|-------|-------------|--------------|
| **glow** | ✅ Excellent | ❌ No | ✅ Yes | ✅ Clickable | ❌ No | `pkgs.glow` |
| **bat** | ✅ Very Good | ❌ No | ⚠️ Basic | ❌ No | ❌ No | `pkgs.bat` |
| **mdcat** | ✅ Good | ⚠️ Partial (iTerm2) | ✅ Yes | ⚠️ Display only | ❌ No | `pkgs.mdcat` |

### 4.2 glow - Recommended Primary Tool

**Repository:** https://github.com/charmbracelet/glow
**Stars:** 21.9k
**Written in:** Go

**Features:**
- Beautiful markdown rendering with themes
- Interactive TUI for browsing markdown files
- Pager mode for single files
- Word wrapping and width control
- Style customization
- Config file support

**Installation (NixOS):**
```nix
home.packages = with pkgs; [ glow ];
```

**Usage Examples:**
```bash
# View single file
glow README.md

# Browse directory
glow .

# With specific width
glow -w 80 document.md

# Different style
glow -s dark document.md

# Pipe from stdin
curl https://example.com/doc.md | glow -

# Configure pager
export PAGER="glow -p"
```

**Config File (`~/.config/glow/glow.yml`):**
```yaml
# style name or JSON path
style: "dark"
# mouse support
mouse: true
# use pager
pager: true
# word wrap width
width: 100
# show all files including hidden
all: false
```

### 4.3 bat - Recommended Secondary Tool

**Repository:** https://github.com/sharkdp/bat
**Stars:** 56.3k
**Written in:** Rust

**Features:**
- Syntax highlighting for 200+ languages
- Git integration (shows diffs)
- Automatic paging
- Line numbers
- Themes from Sublime Text
- Fast performance

**Installation (NixOS):**
```nix
home.packages = with pkgs; [ bat ];
```

**Usage Examples:**
```bash
# View markdown with syntax highlighting
bat README.md

# With line numbers
bat -n README.md

# Plain output (no decorations)
bat -p README.md

# Specific theme
bat --theme="Monokai Extended" README.md

# As MANPAGER
export MANPAGER="bat -plman"
```

**Integration with Obsidian Vault:**
```bash
# Quick preview functions
alias oview='bat --style=plain --paging=never'

# Browse vault with bat
find ~/.MyHome/vault -name "*.md" -exec bat {} +

# Preview with line numbers
alias ocat='bat -n'
```

### 4.4 mdcat - Alternative Option

**Repository:** https://github.com/lunaryorn/mdcat
**Features:**
- Inline images (iTerm2, kitty with graphics protocol)
- Clickable links
- Syntax highlighting in code blocks

**Note:** Less mature than glow/bat, but has unique image support in compatible terminals.

---

## 5. Recommended Integration Strategy

### 5.1 Complete Workflow

```
┌─────────────────────┐
│  Terminal (kitty)   │
│                     │
│  Quick Capture:     │
│  onote "text"       │
│  odaily "note"      │
│  oclip (clipboard)  │
└──────────┬──────────┘
           │
           ├─ Direct File Append ─────────┐
           │                               │
           ├─ URI Trigger ────────────────┤
           │                               │
           └─ Preview in Terminal ────────┤
                                           │
                                           ▼
                              ┌────────────────────┐
                              │  Obsidian Vault    │
                              │  (~/.MyHome/vault) │
                              │                    │
                              │  - Daily Notes     │
                              │  - Inbox           │
                              │  - Projects        │
                              └─────────┬──────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    │                   │                   │
                    ▼                   ▼                   ▼
            ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
            │ Terminal     │   │ Obsidian GUI │   │ Mobile Sync  │
            │ Viewers      │   │              │   │              │
            │              │   │ Rich editing │   │ On-the-go    │
            │ glow, bat    │   │ Graph view   │   │ capture      │
            │ Quick scan   │   │ Plugins      │   │              │
            └──────────────┘   └──────────────┘   └──────────────┘
```

### 5.2 Implementation Steps

**Phase 1: Basic Integration (30 minutes)**
1. Create capture scripts (`onote`, `odaily`, `oclip`)
2. Install `glow` and `bat`
3. Add shell aliases for preview
4. Test basic workflow

**Phase 2: kitty Configuration (1 hour)**
5. Add keybindings for preview/capture
6. Create overlay mappings
7. Configure hints kitten for Obsidian URIs
8. Test all keybindings

**Phase 3: Advanced Setup (2-3 hours)**
9. Install Advanced URI plugin in Obsidian
10. Create dedicated Quick Notes vault (optional)
11. Configure KDE window rules for floating window
12. Create custom kittens for specialized workflows

### 5.3 Home Manager Configuration Example

```nix
# ~/.config/home-manager/home.nix

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    glow          # Markdown viewer
    bat           # Cat with syntax highlighting
    jq            # For URI encoding
    xdg-utils     # For xdg-open
  ];

  # Shell scripts
  home.file.".local/bin/onote" = {
    text = ''
      #!/bin/bash
      VAULT="MyVault"
      INBOX="Inbox"

      if [ -p /dev/stdin ]; then
        CONTENT=$(cat)
      else
        CONTENT="$*"
      fi

      ENCODED=$(echo "$CONTENT" | jq -sRr @uri)
      xdg-open "obsidian://adv-uri?vault=$VAULT&filepath=$INBOX&mode=append&data=$ENCODED"
      echo "✓ Added to Obsidian Inbox"
    '';
    executable = true;
  };

  # kitty configuration
  programs.kitty = {
    enable = true;
    extraConfig = ''
      # Obsidian integration
      map ctrl+alt+d launch --type=overlay glow ~/.MyHome/vault/Daily/$(date +%Y-%m-%d).md
      map ctrl+alt+i launch --type=overlay bat ~/.MyHome/vault/Inbox.md
      map ctrl+alt+o launch --type=background xdg-open "obsidian://open?vault=MyVault"
      map ctrl+alt+c pipe @selection ~/.local/bin/onote
    '';
  };

  # Shell aliases
  programs.bash.shellAliases = {
    onote = "~/.local/bin/onote";
    oinbox = "bat ~/.MyHome/vault/Inbox.md";
    otoday = "bat ~/.MyHome/vault/Daily/$(date +%Y-%m-%d).md";
    opreview = "glow";
  };
}
```

---

## 6. Conclusion

### 6.1 What Works Well

✅ **URI-based quick capture** - Reliable and fast
✅ **Direct file system access** - Instant, no dependencies
✅ **Terminal markdown viewers** - Excellent for quick reference
✅ **Shell function integration** - Seamless workflow
✅ **Floating window approach** - Good middle ground for quick access

### 6.2 What Doesn't Work

❌ **True panel/overlay embedding** - Technically impossible
❌ **Live sync without file system** - Requires Obsidian API (doesn't exist)
❌ **Bidirectional real-time sync** - Not supported by URI scheme
❌ **Graph view in terminal** - GUI-only feature

### 6.3 Best Practice Recommendations

1. **Use file system for captures** - Fastest and most reliable
2. **Use URIs for opening/navigation** - When you need Obsidian GUI
3. **Use terminal viewers for quick scans** - glow for beautiful rendering, bat for syntax highlighting
4. **Keep Obsidian for rich editing** - Don't try to replace it with terminal tools
5. **Use floating window rules** - For truly quick access without full context switch

### 6.4 Final Verdict

**Feasibility: HIGH** for practical workflows
**Complexity: LOW** to implement basic integration
**Value: HIGH** for terminal-centric users

The combination of direct file access, URI triggers, and terminal markdown viewers provides a powerful workflow that complements rather than replaces Obsidian's GUI capabilities.

---

## 7. Research Sources

1. **Obsidian URI Documentation**
   - https://help.obsidian.md/Extending+Obsidian/Obsidian+URI

2. **Advanced URI Plugin**
   - GitHub: https://github.com/Vinzent03/obsidian-advanced-uri
   - Documentation: https://publish.obsidian.md/advanced-uri-doc

3. **glow Documentation**
   - GitHub: https://github.com/charmbracelet/glow
   - Features and usage examples

4. **bat Documentation**
   - GitHub: https://github.com/sharkdp/bat
   - Integration guides and examples

5. **Community Discussions**
   - Obsidian Forum: URI scheme feature requests and implementations
   - Reddit r/ObsidianMD: User workflows and scripts

---

**Document Version:** 1.0
**Last Updated:** 2025-12-22
**Author:** Claude Opus 4.5 (Research Assistant)
