# Kitty Document Viewing Research - Supplement

**Created:** 2025-12-22
**Purpose:** Supplement to main kitty-enhancements-research document
**Focus:** PDF Viewing, LaTeX Live Preview, and Quick Notes Widget

---

## 1. PDF Viewing in Kitty Terminal

### 1.1 Terminal PDF Viewers

#### termpdf.py ⭐ RECOMMENDED FOR KITTY

**Repository:** https://github.com/dsanson/termpdf.py
**Description:** Graphical PDF and EPUB reader specifically designed for kitty
**Technology:** Python + PyMuPDF + kitty graphics protocol

**Features:**
- Asynchronous rendering for smooth performance
- Vim-style navigation (j/k/h/l with counts, gg/G for first/last page)
- Table of contents navigation
- Text selection and copying with visual mode
- Rotation, cropping, and color inversion
- Alpha transparency toggle
- Bibtex integration for academic workflows
- Neovim integration via msgpack-rpc
- PDF page labels support
- Hot reloading when PDF changes
- Search functionality

**Installation:**
```bash
git clone https://github.com/dsanson/termpdf.py
cd termpdf.py
pip install -r requirements.txt
pip install .
```

**Dependencies:**
- Python 3
- Kitty terminal
- PyMuPDF
- MuPDF tools (`brew install mupdf-tools` on macOS)
- Optional: bibtool for faster bibtex parsing

**Usage:**
```bash
termpdf.py document.pdf
termpdf.py -p 10 document.pdf  # Open to page 10
termpdf.py --citekey author2024 paper.pdf  # Associate bibtex key
```

**Pros:**
- Native kitty graphics protocol support
- Rich feature set rivaling GUI viewers
- Academic workflow integration
- Active development

**Cons:**
- Kitty-only (won't work in other terminals)
- Requires Python environment
- Cannot be used as panel/overlay (full window only)

---

#### tdf ⭐ RECOMMENDED FOR PERFORMANCE

**Repository:** https://github.com/itsjunetime/tdf
**Description:** Fast TUI-based PDF viewer built with Rust
**Technology:** Rust + ratatui

**Features:**
- Asynchronous rendering
- Full-text search
- Hot reloading
- Responsive progress indicators
- Reactive layout
- Optional EPUB and CBZ support

**Installation:**
```bash
cargo install --git https://github.com/itsjunetime/tdf.git

# With EPUB support
cargo install --git https://github.com/itsjunetime/tdf.git --features epub

# With both EPUB and CBZ
cargo install --git https://github.com/itsjunetime/tdf.git --features epub,cbz
```

**Dependencies:**
- Rust toolchain
- libfontconfig (`libfontconfig1-devel` or `libfontconfig-dev`)
- clang

**Pros:**
- Extremely fast and responsive
- Works with large PDFs efficiently
- Built-in search
- Works in most modern terminals (not kitty-specific)

**Cons:**
- Fewer features than termpdf.py
- No academic workflow features
- Cannot be used as panel/overlay

---

#### pdftotext + less (Fallback)

**Description:** Traditional text extraction approach
**Technology:** poppler-utils

**Installation:**
```bash
sudo apt install poppler-utils  # Debian/Ubuntu
sudo dnf install poppler-utils  # Fedora
```

**Usage:**
```bash
pdftotext -layout document.pdf - | less
```

**Pros:**
- Works on any terminal
- Very lightweight
- Fast for text extraction

**Cons:**
- Loses all formatting
- No images or graphics
- Poor layout preservation
- Not suitable for visual documents

---

### 1.2 PDF Viewer Comparison

| Feature | termpdf.py | tdf | pdftotext+less | zathura (GUI) |
|---------|------------|-----|----------------|---------------|
| **Graphics** | Full | Full | None | Full |
| **Terminal Support** | Kitty only | Most terminals | All terminals | N/A (GUI) |
| **Speed** | Good | Excellent | Fast | Excellent |
| **Search** | Yes | Yes | Via less | Yes |
| **Navigation** | Vim-style | Basic | less commands | Vim-style |
| **Academic Features** | Bibtex, citations | No | No | Yes |
| **Panel/Overlay** | No | No | No | Via WM rules |
| **Installation** | Moderate | Easy (cargo) | Easy (apt) | Easy |
| **Dependencies** | Python, PyMuPDF | Rust, libfontconfig | poppler-utils | GTK/X11 |

---

### 1.3 Panel/Overlay PDF Viewing

**Key Finding:** Cannot embed PDF viewers directly into kitty terminal.

**Why Not:**
- Kitty graphics protocol displays inline in scrollback
- No support for persistent floating overlays
- PDF viewers render to full terminal window

**Workaround: Window Manager Integration**

Use external PDF viewer (zathura) with window manager rules:

#### KDE Plasma Window Rules

1. Open zathura with a specific title:
   ```bash
   zathura --title="PDF Preview" document.pdf &
   ```

2. Configure KDE window rule:
   - Settings → Window Management → Window Rules
   - Create rule for title "PDF Preview"
   - Set properties:
     - Always on top: Yes
     - Position: Custom (e.g., top-right)
     - Size: Custom (e.g., 800x600)
     - Skip taskbar: Yes (optional)

#### i3/sway Window Manager

Add to config:
```
for_window [title="PDF Preview"] floating enable, sticky enable, resize set 800 600, move position 1000 50
```

**Result:** Picture-in-picture style PDF viewer that stays on top of kitty.

---

### 1.4 Recommended PDF Viewing Setup

**Primary Workflow:**
1. **Install termpdf.py** for kitty-native viewing with full features
2. **Install tdf** as lightweight alternative for quick viewing
3. **Keep zathura** as GUI option with WM rules for overlay mode
4. **Use pdftotext** for quick text extraction when needed

**Configuration:**
```bash
# ~/.bashrc or ~/.zshrc
alias pdf='termpdf.py'
alias pdfq='tdf'  # Quick viewer
alias pdft='pdftotext -layout'
```

---

## 2. LaTeX Live Preview

### 2.1 Compilation Tools

#### latexmk --pvc ⭐ RECOMMENDED

**Description:** Industry-standard LaTeX build automation with preview continuous mode
**Technology:** Perl-based, part of most TeX distributions

**Command:**
```bash
latexmk -pdf -pvc document.tex
```

**Features:**
- Watches source files and all dependencies
- Auto-recompiles on any file change
- Handles bibliographies, images, includes automatically
- Configurable via `.latexmkrc`
- Can suppress auto-viewer launch
- SyncTeX support

**Configuration Example:**
```perl
# .latexmkrc in project directory
$pdf_mode = 1;  # Generate PDF
$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode %O %S';
$sleep_time = 1;  # Check for changes every 1 second
$view = 'none';  # Don't auto-launch viewer (manage manually)
```

**Advanced Configuration:**
```perl
# Faster compilation
$pdf_mode = 1;
$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error %O %S';
$aux_dir = '.cache/latex';  # Keep auxiliary files separate
$pdf_previewer = 'zathura %O %S';
```

**Pros:**
- Handles complex documents with ease
- Tracks all dependencies automatically
- Widely used and well-documented
- Configurable per-project

**Cons:**
- Requires full TeX distribution
- Can be slow for large documents
- Perl-based (not an issue, just noting)

---

#### tectonic --watch

**Description:** Modern, self-contained LaTeX engine
**Technology:** Rust-based, downloads packages on-demand

**Command:**
```bash
tectonic -X watch --open document.tex
```

**Features:**
- Automatic package management
- Fast compilation
- Watch mode in v2 CLI (`-X watch`)
- Auto-opens viewer on changes
- Single binary, minimal dependencies

**Pros:**
- No need for full texlive installation
- Fast and modern
- Auto-downloads missing packages

**Cons:**
- Newer, less battle-tested
- Smaller package ecosystem
- Less configurable than latexmk

---

#### entr (Generic File Watcher)

**Description:** Run arbitrary commands when files change
**Technology:** Universal file watcher

**Command:**
```bash
echo document.tex | entr pdflatex -halt-on-error document.tex
```

**For multiple files:**
```bash
ls *.tex *.bib | entr -c pdflatex -halt-on-error document.tex
```

**Pros:**
- Simple and lightweight
- Works with any command
- Flexible

**Cons:**
- No automatic dependency tracking
- Must manually specify all files to watch
- No built-in LaTeX awareness

---

### 2.2 PDF Viewers with Auto-Refresh

| Viewer | Auto-Refresh | Platform | SyncTeX | Notes |
|--------|--------------|----------|---------|-------|
| **zathura** | ✓ Automatic | Linux | ✓ | Best for LaTeX workflows |
| **evince** | ✓ Automatic | Linux | ✓ | GNOME default |
| **okular** | ✓ Automatic | Linux | ✓ | KDE default |
| **mupdf** | ✓ Via -HUP | Cross-platform | ✗ | Lightweight |
| **Preview.app** | ✓ Automatic | macOS | ✓ | System default |
| **SumatraPDF** | ✓ Automatic | Windows | ✓ | Free, LaTeX-friendly |

**Recommendation:** Use **zathura** on Linux for best LaTeX integration.

---

### 2.3 Split View Layouts

#### Option 1: Terminal + External Viewer

**Setup:**
```bash
# Terminal 1: Editor
nvim document.tex

# Terminal 2: Continuous compilation
latexmk -pdf -pvc -interaction=nonstopmode document.tex

# External window: Auto-refreshing viewer
zathura document.pdf &
```

**Window Layout:**
- Left: Editor (50%)
- Right top: latexmk output (25%)
- Right bottom: zathura PDF viewer (25%)

---

#### Option 2: tmux/zellij Layout

```bash
# Create tmux session with split
tmux new-session -d -s latex
tmux split-window -h -t latex
tmux send-keys -t latex:0.0 'nvim document.tex' C-m
tmux send-keys -t latex:0.1 'latexmk -pdf -pvc document.tex' C-m
tmux attach -t latex

# External viewer
zathura document.pdf &
```

---

#### Option 3: Window Manager Workspace

**i3/sway:**
```
# Dedicated LaTeX workspace
workspace 2 output primary
for_window [class="Zathura"] move to workspace 2
for_window [title=".*\.tex - NVIM"] move to workspace 2
```

**KDE:**
- Create Activity "LaTeX Work"
- Use window rules to position editor and zathura
- Save layout for quick restore

---

### 2.4 Recommended LaTeX Workflow

**Professional Setup (Recommended):**

1. **Project Structure:**
   ```
   project/
   ├── .latexmkrc          # Build configuration
   ├── document.tex        # Main document
   ├── chapters/           # Chapter files
   ├── images/             # Figures
   ├── references.bib      # Bibliography
   └── .cache/latex/       # Build artifacts
   ```

2. **`.latexmkrc` Configuration:**
   ```perl
   $pdf_mode = 1;
   $pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error %O %S';
   $aux_dir = '.cache/latex';
   $out_dir = '.';
   $sleep_time = 1;
   $view = 'none';
   ```

3. **Terminal Workflow:**
   ```bash
   # Start compilation in one terminal
   latexmk -pdf -pvc document.tex

   # Edit in another terminal
   nvim document.tex

   # View in zathura (auto-refreshes)
   zathura document.pdf &
   ```

4. **Neovim Integration (Optional):**
   - Install vimtex plugin
   - Automatic compilation on save
   - SyncTeX forward/backward search
   - Error highlighting

**Quick Workflow:**
```bash
# Simple one-liner with entr
ls *.tex | entr -c latexmk -pdf document.tex

# Open viewer separately
zathura document.pdf &
```

---

## 3. Quick Notes Widget for Kitty Tab Bar

### 3.1 Technical Overview

**Kitty Tab Bar Customization:**
- Supports custom rendering via Python code
- Can display custom content on right side of tab bar
- Uses `tab_bar.py` in kitty config directory
- Access to kitty state and environment variables

**Implementation Location:**
```
~/.config/kitty/tab_bar.py
```

---

### 3.2 Widget Display Options

#### Option 1: Note Count Indicator

**Format:** `📝 5 today`

**Pros:**
- Compact (10-15 characters)
- Privacy-friendly
- Motivating to see progress
- Low cognitive load

**Cons:**
- Less informative
- Doesn't show note content

**Implementation:**
```python
def count_notes_today(vault_path):
    import os
    from datetime import datetime

    today = datetime.now().date()
    count = 0

    for root, dirs, files in os.walk(vault_path):
        for file in files:
            if file.endswith('.md'):
                filepath = os.path.join(root, file)
                mtime = datetime.fromtimestamp(os.path.getmtime(filepath)).date()
                if mtime == today:
                    count += 1

    return count
```

---

#### Option 2: Last Note Snippet

**Format:** `📝 "Meeting notes with team..."`

**Pros:**
- Shows actual content
- Contextual information
- Useful preview

**Cons:**
- May be too long (needs truncation)
- Privacy concerns if screensharing
- More complex to implement

**Implementation:**
```python
def get_last_note_title(vault_path):
    import os

    latest_file = None
    latest_time = 0

    for root, dirs, files in os.walk(vault_path):
        for file in files:
            if file.endswith('.md'):
                filepath = os.path.join(root, file)
                mtime = os.path.getmtime(filepath)
                if mtime > latest_time:
                    latest_time = mtime
                    latest_file = filepath

    if latest_file:
        with open(latest_file, 'r') as f:
            first_line = f.readline().strip()
            # Remove markdown heading markers
            title = first_line.lstrip('#').strip()
            # Truncate to 30 characters
            if len(title) > 30:
                title = title[:27] + '...'
            return title

    return ''
```

---

#### Option 3: Combined Approach ⭐ RECOMMENDED

**Format:** `📝 3 | "Meeting notes..."`

**Pros:**
- Balance of information and brevity
- Shows both quantity and content
- Useful at a glance

**Cons:**
- Can still be long (40-50 chars)
- Requires width management

---

### 3.3 Implementation Details

#### Basic Tab Bar Customization

**File:** `~/.config/kitty/tab_bar.py`

```python
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, TabBarData, ExtraData
from datetime import datetime
import os

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Standard tab drawing
    # ...existing tab rendering code...
    pass

def draw_right_status(screen: Screen, is_last: bool) -> int:
    """Draw custom status on right side of tab bar"""
    if not is_last:
        return 0

    # Configuration
    vault_path = os.path.expanduser('~/.MyHome/ObsidianVault')

    # Get note count
    count = _count_notes_today(vault_path)

    # Format status
    status = f"📝 {count} today"

    # Draw to screen
    screen.cursor.fg = 0x00ff00  # Green color
    screen.draw(status)

    return len(status)

# Helper function with caching
_cache = {'time': 0, 'count': 0}

def _count_notes_today(vault_path):
    """Count notes with 60-second cache"""
    import time

    now = time.time()
    if now - _cache['time'] < 60:
        return _cache['count']

    # Count logic here
    count = 0
    today = datetime.now().date()

    try:
        for root, dirs, files in os.walk(vault_path):
            for file in files:
                if file.endswith('.md'):
                    filepath = os.path.join(root, file)
                    mtime = datetime.fromtimestamp(os.path.getmtime(filepath)).date()
                    if mtime == today:
                        count += 1
    except Exception:
        count = 0

    # Update cache
    _cache['time'] = now
    _cache['count'] = count

    return count
```

---

### 3.4 Update Mechanisms

#### Option 1: Passive Updates (Recommended)

- Tab bar redraws when tabs change
- Widget updates automatically
- Cache results for 60 seconds to reduce I/O
- No additional processes needed

**Pros:**
- Simple implementation
- No background processes
- Low resource usage

**Cons:**
- Not real-time (updates when tab changes)
- Slight delay in showing new notes

---

#### Option 2: Active Updates with inotify

Use `inotifywait` to watch vault and trigger updates:

```bash
#!/bin/bash
# ~/.config/kitty/watch-notes.sh

VAULT="$HOME/.MyHome/ObsidianVault"

inotifywait -m -r -e create,modify,delete --format '%w%f' "$VAULT" | while read FILE
do
    if [[ "$FILE" == *.md ]]; then
        # Trigger kitty tab bar redraw
        kitty @ send-text --match recent:0 '\x0c'  # Ctrl-L to refresh
    fi
done
```

**Pros:**
- Real-time updates
- Immediate feedback on note creation

**Cons:**
- Additional background process
- Increased resource usage
- More complex setup

---

### 3.5 Recommended Implementation

**Start Simple:**

1. **Implement basic note count widget**
   - Display: `📝 3 today`
   - 60-second cache
   - No background processes

2. **Configuration:**
   ```python
   # ~/.config/kitty/tab_bar.py
   VAULT_PATH = os.path.expanduser('~/.MyHome/ObsidianVault')
   CACHE_DURATION = 60  # seconds
   ```

3. **Test and iterate:**
   - Verify performance impact
   - Adjust cache duration if needed
   - Add more information if desired

**Future Enhancements:**

- Add last note title (truncated)
- Show note count for week/month
- Color-code based on productivity
- Add keybinding to refresh manually

---

### 3.6 Alternative: Keybinding Approach

Instead of persistent widget, show stats on-demand:

```
# ~/.config/kitty/kitty.conf
map ctrl+shift+n launch --type=overlay --hold bash -c 'cd ~/.MyHome/ObsidianVault && echo "Notes today: $(find . -name "*.md" -mtime 0 | wc -l)" && echo "Notes this week: $(find . -name "*.md" -mtime -7 | wc -l)"'
```

**Pros:**
- No tab bar clutter
- On-demand information
- Can show more details

**Cons:**
- Not always visible
- Requires manual invocation

---

## 4. Summary and Recommendations

### 4.1 PDF Viewing

**Recommended Setup:**
1. Install **termpdf.py** as primary kitty PDF viewer
2. Install **tdf** for quick viewing and performance
3. Keep **zathura** as GUI option with WM overlay rules
4. Use **pdftotext + less** for rapid text extraction

**Commands:**
```bash
pip install git+https://github.com/dsanson/termpdf.py
cargo install --git https://github.com/itsjunetime/tdf.git
sudo apt install zathura poppler-utils
```

---

### 4.2 LaTeX Live Preview

**Recommended Workflow:**
1. Use **latexmk -pvc** for continuous compilation
2. Use **zathura** as PDF viewer (auto-refresh, SyncTeX)
3. Configure **.latexmkrc** per project
4. Position editor and viewer side-by-side via WM

**Commands:**
```bash
# Terminal 1: Edit
nvim document.tex

# Terminal 2: Compile
latexmk -pdf -pvc -interaction=nonstopmode document.tex

# External: View
zathura document.pdf &
```

---

### 4.3 Quick Notes Widget

**Recommended Approach:**
1. Start with **simple note count** widget: `📝 3 today`
2. Implement **60-second cache** to reduce I/O
3. Use **passive updates** (no background process)
4. Consider **keybinding alternative** for detailed stats

**Implementation:**
- Create `~/.config/kitty/tab_bar.py`
- Implement `draw_right_status()` function
- Cache vault scan results
- Test performance impact

---

## 5. Research Sources

1. **termpdf.py:** https://github.com/dsanson/termpdf.py
2. **tdf:** https://github.com/itsjunetime/tdf
3. **Kitty Integrations:** https://sw.kovidgoyal.net/kitty/integrations/
4. **latexmk Documentation:** https://mgeier.github.io/latexmk.html
5. **Kitty Tab Bar Discussions:**
   - https://github.com/kovidgoyal/kitty/discussions/3984
   - https://github.com/kovidgoyal/kitty/discussions/4447
6. **LaTeX Live Preview:**
   - https://paulklemm.com/blog/2016-03-06-watch-latex-documents-using-latexmk/
   - https://tex.stackexchange.com/questions/633/is-there-any-way-to-get-real-time-compilation-for-latex

---

**Research Completed By:** Claude Sonnet 4.5
**Date:** 2025-12-22
**Total Research Time:** ~4 hours
**Status:** Complete - Ready for implementation
