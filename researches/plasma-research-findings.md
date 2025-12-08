# Plasma Desktop Dotfiles - Web Research Findings

**Created:** 2025-12-02
**Phase:** Phase 2 - Web Research (Technical Researcher Role)
**Research Confidence:** `topic_research_confidence = 0.87` (Band C - HIGH)
**Status:** ✅ Complete

---

## Research Summary

This document synthesizes findings from comprehensive web research on managing KDE Plasma dotfiles with chezmoi, plasma-manager behavior, and best practices for cross-platform configuration management.

### Research Methodology

**Approach:** `web_research_workflow`
- **Iteration 1:** Firecrawl + exa search for KDE Plasma 6 and plasma-manager
- **Iteration 2:** Targeted scraping of key resources
- **Iteration 3:** Chezmoi best practices and INI templating

**Sources Used:**
- Official KDE Frameworks 6 documentation
- plasma-manager GitHub discussions
- Community blog posts and guides
- Chezmoi official documentation
- Real-world dotfile examples

**Topics Researched:**
1. ✅ KDE Plasma 6 configuration structure (c = 0.85)
2. ✅ plasma-manager behavior and (im)mutability (c = 0.90)
3. ✅ Chezmoi + KDE best practices (c = 0.88)
4. ✅ .chezmoiignore patterns for KDE (c = 0.85)
5. ✅ INI file templating with chezmoi (c = 0.90)

---

## Topic 1: KDE Plasma 6 Configuration Structure

**Research Confidence:** `c = 0.85` (Band C)

### Key Findings

#### 1.1 Plasma 6 vs Plasma 5

**Source:** [KDE Frameworks 6 Porting Guide](https://develop.kde.org/docs/features/configuration/porting_kf6)

**Major Changes:**
- ✅ **KF6 uses KCMUtils** (moved from KDeclarative/KConfigWidgets)
- ✅ **No symlinks allowed** in Plasma 6 global themes due to new kpackage format
- ✅ **Strict theme packaging** - requires `manifest.json` with `"KPackageStructure": "Plasma/LookAndFeel"`
- ✅ **QML imports renamed** - affects custom themes and widgets

**Implications for Migration:**
- Plasma 6 config files are in same locations (`~/.config/`) as Plasma 5
- Config format (INI) remains the same
- plasma-manager handles Plasma 6 compatibility

#### 1.2 Config File Locations

**Source:** Reddit discussion "Where does KDE6 store its configuration files?"

**Standard Locations (Confirmed for Plasma 6):**
```
~/.config/          # All KDE configuration files
~/.local/share/     # KDE data files, themes, plasmoids
~/.cache/           # Temporary/cache files (DON'T manage)
```

**Core Config Files:**
- `kwinrc` - Window manager
- `plasmarc` - Plasma shell theme
- `kdeglobals` - Global KDE settings
- `kglobalshortcutsrc` - Keyboard shortcuts
- `plasma-org.kde.plasma.desktop-appletsrc` - Desktop widgets

#### 1.3 Volatile vs Stable Configs

**Analysis from Community:**

**Volatile (Change Frequently):**
- Window positions, sizes (`[MainWindow]` sections)
- Recent files lists
- File dialog states
- Search history
- Session-specific data

**Stable (Safe to Version Control):**
- Theme settings
- Keyboard shortcuts
- Panel layout
- Widget configuration
- Font preferences
- Power management settings

**Recommendation:** Use chezmoi_modify_manager (see Topic 3) to filter volatile sections.

---

## Topic 2: plasma-manager Behavior

**Research Confidence:** `c = 0.90` (Band C)

### Key Findings

#### 2.1 How plasma-manager Works

**Source:** [plasma-manager GitHub Discussion #120](https://github.com/nix-community/plasma-manager/discussions/120)

**🔴 CRITICAL Finding: plasma-manager writes to `~/.config/` directly**

**Evidence from Local Investigation:**
- `~/.local/share/plasma-manager/last_run_*` scripts track what was applied
- plasma-manager uses **desktop scripts** to apply configs
- Configs are written to actual files, NOT symlinked from Nix store

**Script-Based Approach:**
```
~/.local/share/plasma-manager/
├── last_run_desktop_script_panels
├── last_run_desktop_script_set_desktop_folder_settings
├── last_run_desktop_script_wallpaper_picture
└── last_run_script_apply_themes
```

#### 2.2 Immutability Behavior

**Source:** plasma-manager GitHub Discussion #120

**Key Points from Discussion:**

1. **Immutability Setting:**
   - plasma-manager can mark keys as `immutable = true`
   - Immutable keys get `[$i]` suffix in INI files
   - KDE Plasma respects immutability and won't change them via GUI

2. **Current Default:**
   - `immutable = false` by default
   - Keys are **mutable and persistent** unless explicitly configured

3. **Community Consensus (from discussion):**
   - **Opinion 1:** If value is set explicitly, should be immutable by default
   - **Opinion 2:** Mutable variables should not have explicit value in nix config
   - **Opinion 3:** All keys should be mutable and persistent by default (current behavior)
   - **Opinion 4:** Allow reset by key (selective persistence)

4. **overrideConfig Option:**
   - `overrideConfig = true` → plasma-manager resets entire config files
   - Use with caution - destructive!
   - Current user (Mitsos) likely has `overrideConfig = false`

#### 2.3 Merge vs Overwrite Behavior

**Finding from Discussion:**

**plasma-manager does NOT overwrite, it MERGES:**
- When setting `key[$i]=value`, it does NOT delete `key=value`
- Original values persist when plasma-manager config is removed
- This allows "rollback" to previous state

**Example:**
```ini
# Original file
[Section]
key=original_value

# After plasma-manager applies key[$i]
[Section]
key=original_value        # ← Still there!
key[$i]=nix_managed_value # ← Added by plasma-manager
```

#### 2.4 Coexistence with Chezmoi

**Implications:**

**✅ Coexistence IS Possible:**
- plasma-manager writes to `~/.config/` files
- chezmoi can manage the same files
- **Key:** Use chezmoi's `modify_*` scripts (see Topic 3)

**⚠️ Potential Conflicts:**
- If both try to manage same keys → conflict
- If plasma-manager uses `overrideConfig = true` → chezmoi changes lost

**Recommended Strategy:**
1. Keep plasma-manager for **high-level structure** (panels, themes)
2. Use chezmoi for **user-specific preferences** (shortcuts, app configs)
3. Use `chezmoi_modify_manager` to filter volatile sections

---

## Topic 3: Chezmoi + KDE Best Practices

**Research Confidence:** `c = 0.88` (Band C)

### Key Findings

#### 3.1 The Problem with KDE Configs

**Source:** [Managing KDE Dotfiles with Chezmoi and Chezmoi Modify Manager](https://www.lorenzobettini.it/2025/09/managing-kde-dotfiles-with-chezmoi-and-chezmoi-modify-manager/)

**KDE Config Challenges:**
> "KDE applications like Kate, Dolphin, and KWin store their settings in INI-style configuration files. These files often contain:
> - **Volatile sections** that change frequently (like window positions, recent files)
> - **System-specific data** (like file dialog sizes, screen configurations)
> - **Mixed content** where you only want to track specific settings"

**Result:** Managing these directly with chezmoi = noisy diffs + configs that don't work across machines

#### 3.2 Solution: Chezmoi Modify Manager

**🌟 MAJOR DISCOVERY: `chezmoi_modify_manager`**

**Tool:** [chezmoi_modify_manager](https://github.com/VorpalBlade/chezmoi_modify_manager)

**What It Does:**
- Acts as a **configurable filter** between actual config files and chezmoi repository
- Allows **selective tracking** of INI file sections/keys
- Uses chezmoi's `modify_*` script mechanism

**Capabilities:**
- ✅ **Ignore entire sections** or specific keys
- ✅ **Set specific values** while ignoring everything else
- ✅ **Use regex patterns** for flexible matching
- ✅ **Transform values** during processing

#### 3.3 How chezmoi_modify_manager Works

**File Structure in chezmoi source directory:**

```
~/.local/share/chezmoi/
├── modify_private_kwinrc                 # ← Modify script
├── private_kwinrc.src.ini                # ← Source state
├── modify_private_kdeglobals.tmpl        # ← Templated modify script
├── private_kdeglobals.src.ini            # ← Source state
└── .chezmoiignore                        # ← Must ignore *.src.ini
```

**Process:**
1. **Source file** (`.src.ini`) contains your desired configuration
2. **Modify script** (`modify_*`) defines filtering rules
3. **Chezmoi** applies modifications when deploying configs
4. `.chezmoiignore` ensures source files aren't directly copied

**Required .chezmoiignore:**
```
**/*.src.ini
```

#### 3.4 Real-World Examples

**Example 1: KWin Configuration**

`modify_private_kwinrc`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

ignore section "$Version"
ignore section "Desktops"
ignore regex "Tiling.*" ".*"
ignore section "Xwayland"
```

`private_kwinrc.src.ini`:
```ini
[Effect-cube]
CubeFaceDisplacement=126
DistanceFactor=1.82

[Effect-magiclamp]
AnimationDuration=400

[Plugins]
cubeEnabled=true
magiclampEnabled=true
```

**Result:** Only tracks relevant window manager settings, ignores volatile sections.

---

**Example 2: Global Shortcuts**

`modify_private_kglobalshortcutsrc`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

ignore section "ActivityManager"
```

**Result:** Keeps custom shortcuts, filters activity-specific bindings.

---

**Example 3: Font Configuration (Single Setting)**

`modify_private_kdeglobals`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

set "General" "fixed" "Hack Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1" separator="="
ignore regex ".*" ".*"
```

`private_kdeglobals.src.ini`:
```ini
[General]
fixed=Hack Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
```

**Result:** Tracks ONLY the terminal font, ignores everything else.

---

**Example 4: Kate Editor**

`modify_private_katerc`:
```bash
#!/usr/bin/env chezmoi_modify_manager

source auto

ignore section "KFileDialog Settings"
ignore section "FileDialogSize"
ignore section "KTextEditor::Search"
ignore section "MainWindow"
ignore regex "Kate Print Settings.*" ".*"
```

**Result:** Keeps editor preferences, ignores volatile sections (window sizes, recent searches).

#### 3.5 Benefits & Drawbacks

**✅ Benefits:**
- **Clean diffs** - Only track settings you care about
- **Portable configs** - No system-specific clutter
- **Selective tracking** - Include only relevant sections
- **Precise control** - Regex patterns for flexibility

**⚠️ Drawbacks:**
- **Initial setup time** - Need to understand what to include/exclude
- **Additional tool** - Must install `chezmoi_modify_manager` separately
- **Maintenance** - Updating configs requires [special techniques](https://www.lorenzobettini.it/2025/11/maintaining-kde-dotfiles-with-chezmoi-modify-manager/)
- **No merge support** - Some chezmoi mechanisms won't function

**Recommendation:** Use `chezmoi_modify_manager` for **complex KDE configs** (kwinrc, kdeglobals, kglobalshortcutsrc). Use plain chezmoi for **simple app configs**.

---

## Topic 4: .chezmoiignore Patterns for KDE

**Research Confidence:** `c = 0.85` (Band C)

### Key Findings

#### 4.1 Essential Patterns

**Source:** Multiple chezmoi GitHub discussions and community examples

**Must-Have Patterns:**

```gitignore
# ============ chezmoi_modify_manager ============
# Source files for chezmoi_modify_manager
**/*.src.ini

# ============ KDE CACHE & TEMP ============
# KDE cache files
.cache/
**/.cache/

# KDE lock files
**/*.lock
**/.copyq_s

# ============ KDE VOLATILE CONFIGS ============
# Auto-generated KDE config updates
**/kconf_updaterc

# Session management (volatile)
**/*session*

# Recent files/history (volatile)
**/recentlyused.xbel
**/recently-used.xbel

# ============ PLASMA-SPECIFIC ============
# Plasma containment previews (generated)
.local/share/plasma/containmentpreviews/

# Plasma manager tracking (tool-specific)
.local/share/plasma-manager/

# KDE activities (system-specific)
**/*activities*

# ============ HARDWARE-SPECIFIC ============
# Display configuration (monitor setup)
**/kwinoutputconfig.json
**/kscreen/

# Power management profiles (hardware-specific)
**/powermanagementprofilesrc
```

#### 4.2 Patterns from User's Existing .chezmoiignore

**Current patterns (from dotfiles/.chezmoiignore):**

```gitignore
# Staging/reference
_staging/

# Documentation
*.md
README.md

# Version control
.git/
.gitignore

# Backups
*.backup
*.bak
*.old

# Temporary files
*.tmp
*.swp
*~

# Large files
*.zip
*.tar.gz

# Home-manager managed (per ADR-007)
.config/autostart/
dot_config/autostart/

# CopyQ runtime files
.config/copyq/copyq.lock
.config/copyq/.copyq_s
.config/copyq/copyq_tab_*.dat
```

**✅ Good coverage** - Already handles backups, temp files, and tool-specific runtime files.

#### 4.3 Recommended Additions for Plasma Migration

**Patterns to ADD to .chezmoiignore:**

```gitignore
# ============ CHEZMOI_MODIFY_MANAGER ============
**/*.src.ini

# ============ KDE PLASMA VOLATILE ============
# Auto-generated updates
**/kconf_updaterc

# Session data
**/session/
**/*session*

# Recent files
**/recentlyused.xbel

# Plasma containment previews
.local/share/plasma/containmentpreviews/

# plasma-manager tracking
.local/share/plasma-manager/

# ============ HARDWARE-SPECIFIC (Maybe) ============
# Display config - ONLY if not templating
# **/kwinoutputconfig.json

# ============ EMPTY FILES ============
# ksplashrc is 0 bytes (placeholder)
**/ksplashrc
```

---

## Topic 5: INI File Templating with Chezmoi

**Research Confidence:** `c = 0.90` (Band C)

### Key Findings

#### 5.1 Chezmoi Template Basics

**Source:** [Chezmoi Templates Documentation](https://chezmoi.io/reference/templates/)

**Template Engine:** Go's `text/template`

**File Naming:**
- Files with `.tmpl` extension are processed as templates
- Example: `dot_config/plasma/private_kwinrc.tmpl`

**Available Variables:**
- `.chezmoi.hostname` - Machine hostname
- `.chezmoi.os` - Operating system (linux, darwin, etc.)
- `.chezmoi.osRelease` - Linux OS release info
- `.chezmoi.homeDir` - User's home directory
- `.chezmoi.username` - Current user
- Custom variables from `~/.config/chezmoi/chezmoi.toml`

#### 5.2 Template Syntax for INI Files

**Basic Variable Substitution:**

```ini
[Wallpapers]
usersWallpapers={{ .chezmoi.homeDir }}/Pictures/Wallpapers/current.jpg
```

**Conditional Sections:**

```ini
{{- if eq .chezmoi.hostname "shoshin" }}
[Effect-cube]
CubeFaceDisplacement=126
DistanceFactor=1.82
{{- end }}

{{- if eq .chezmoi.hostname "laptop" }}
[Effect-cube]
CubeFaceDisplacement=100
DistanceFactor=1.5
{{- end }}
```

**Multiple Conditions:**

```ini
[Plugins]
{{- if eq .chezmoi.os "linux" }}
cubeEnabled=true
magiclampEnabled=true
{{- end }}

{{- if eq .work_machine "true" }}
# Disable distracting effects at work
cubeEnabled=false
{{- end }}
```

#### 5.3 Custom Variables in chezmoi.toml

**Define machine-specific data:**

`~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
    work_machine = false
    wallpaper_dir = "{{ .chezmoi.homeDir }}/Pictures/Wallpapers"

[data.monitors]
    main = "DP-1"
    secondary = "HDMI-1"
```

**Use in templates:**

```ini
[Wallpapers]
usersWallpapers={{ .wallpaper_dir }}/current.jpg

{{- if .work_machine }}
[powerdevilrc]
# Work power settings
{{- else }}
# Home power settings
{{- end }}
```

#### 5.4 Template Functions

**String Manipulation:**

```ini
# Uppercase hostname
[General]
HostName={{ .chezmoi.hostname | upper }}

# Conditional path
BackupPath={{ if eq .chezmoi.os "linux" }}{{ .chezmoi.homeDir }}/Backups{{ else }}/mnt/backups{{ end }}
```

**Loops (for lists):**

```toml
# In chezmoi.toml
[data]
    favorite_apps = ["brave", "kitty", "dolphin"]
```

```ini
# In template
[Taskbar]
{{- range .favorite_apps }}
Favorite={{ . }}
{{- end }}
```

#### 5.5 Hardware-Specific Templating

**Example: Monitor Configuration**

**Problem:** `kwinoutputconfig.json` contains hardware-specific display settings

**Solution:** Template with machine-specific monitor names

`dot_config/kwinoutputconfig.json.tmpl`:
```json
{
  "{{ .monitors.main }}": {
    "scale": 1.0,
    "resolution": "2560x1440"
  }
  {{- if .monitors.secondary }},
  "{{ .monitors.secondary }}": {
    "scale": 1.0,
    "resolution": "1920x1080"
  }
  {{- end }}
}
```

**Example: Wallpaper Paths**

`dot_config/plasmarc.tmpl`:
```ini
[Wallpapers]
usersWallpapers={{ .wallpaper_dir }}/{{ .chezmoi.hostname }}-wallpaper.jpg
```

---

## Synthesis & Recommendations

### Overall Strategy

**Hybrid Approach: plasma-manager + chezmoi + chezmoi_modify_manager**

1. **plasma-manager** (Keep for now)
   - Manages high-level plasma structure (panels, themes, basic settings)
   - Provides Nix-native integration
   - Works well for **system-level** configs

2. **chezmoi** (Migrate user preferences)
   - Manages **user-specific** preferences
   - Handles **cross-platform** needs (Fedora migration)
   - Uses templates for **machine-specific** values

3. **chezmoi_modify_manager** (Use for complex configs)
   - Filters **volatile sections** from KDE configs
   - Enables **selective tracking** of INI files
   - Prevents **noisy diffs**

### Migration Strategy Recommendations

#### Phase A: Simple Configs (Plain Chezmoi)
**Migrate these directly to chezmoi:**
- KDE application configs: `konsolerc`, `katerc`, `okularrc`, `spectaclerc`, `gwenviewrc`
- Small configs: `krunnerrc`, `plasma-localerc`
- Application data: Dolphin settings, Kate sessions

**Why:** These are relatively stable, user-specific, and don't change frequently.

#### Phase B: Complex Configs (chezmoi_modify_manager)
**Use chezmoi_modify_manager for:**
- `kwinrc` - Filter volatile sections (window states, session data)
- `kdeglobals` - Track only specific settings (fonts, specific prefs)
- `kglobalshortcutsrc` - Ignore activity-specific bindings
- `katerc` - Ignore file dialog sizes, window positions

**Why:** These mix stable preferences with volatile state.

#### Phase C: Hardware-Specific (Templates)
**Template these configs:**
- `kwinoutputconfig.json` - Monitor setup (use `.monitors.main` variable)
- `plasmarc` - Wallpaper paths (use `.wallpaper_dir` variable)
- Machine-specific power settings

**Why:** Different values needed per machine.

#### Phase D: Keep in plasma-manager
**DO NOT migrate (keep in plasma-manager):**
- Panel layout configuration
- Widget/applet placement
- Theme selection (high-level)
- Virtual desktops structure

**Why:** plasma-manager provides excellent declarative API for these.

### .chezmoiignore Strategy

**Add these patterns:**
```gitignore
# chezmoi_modify_manager sources
**/*.src.ini

# KDE volatile/generated
**/kconf_updaterc
**/session/
**/recentlyused.xbel
.local/share/plasma/containmentpreviews/
.local/share/plasma-manager/
**/ksplashrc

# Optional: Hardware-specific (if not templating)
# **/kwinoutputconfig.json
```

### Templating Strategy

**Define in `~/.config/chezmoi/chezmoi.toml`:**
```toml
[data]
    work_machine = false
    wallpaper_dir = "{{ .chezmoi.homeDir }}/Pictures/Wallpapers"

[data.monitors]
    main = "DP-1"
    secondary = ""  # Empty on desktop (no secondary)
```

**Use templates for:**
1. Wallpaper paths
2. Monitor configurations
3. Work vs home conditional configs

---

## Key Insights

### 1. plasma-manager Writes Directly to ~/.config/

**Finding:** plasma-manager does NOT symlink from Nix store - it writes actual files to `~/.config/`.

**Implication:** Coexistence with chezmoi IS possible, but requires coordination.

**Evidence:** `~/.local/share/plasma-manager/last_run_*` scripts track applications.

### 2. chezmoi_modify_manager is Essential for KDE

**Finding:** KDE configs mix stable preferences with volatile state.

**Solution:** Use `chezmoi_modify_manager` to filter sections selectively.

**Benefit:** Clean diffs, portable configs, precise control.

### 3. Plasma 6 Config Structure is Stable

**Finding:** Plasma 6 uses same config locations and INI format as Plasma 5.

**Implication:** Existing dotfile strategies remain valid.

**Note:** KF6 has breaking changes for **themes/plasmoids**, not for config files.

### 4. Template for Hardware-Specific Configs

**Finding:** Configs like `kwinoutputconfig.json` (monitors) and wallpaper paths are machine-specific.

**Solution:** Use chezmoi templates with machine-specific variables.

**Benefit:** Single dotfiles repo works across multiple machines.

### 5. Selective Tracking is Critical

**Finding:** Tracking everything in KDE configs = noisy diffs + non-portable configs.

**Solution:** Use `.chezmoiignore` + `chezmoi_modify_manager` for selective tracking.

**Result:** Only version-control what matters.

---

## Gaps & Unknowns

### Remaining Questions

1. **plasma-manager + chezmoi_modify_manager Interaction**
   - ❓ Does plasma-manager respect changes made by chezmoi_modify_manager?
   - ❓ What happens if both try to manage the same sections?
   - **Recommendation:** Test in VM before production migration

2. **overrideConfig Behavior**
   - ❓ Does current user (Mitsos) have `overrideConfig = true` or `false`?
   - ❓ How often does plasma-manager run and rewrite configs?
   - **Action:** Check `home-manager/plasma.nix` for `overrideConfig` setting

3. **Wallpaper Directory Migration**
   - ✅ User confirmed: wallpapers should go to `~/Pictures/Wallpapers/`
   - ❓ How to handle the transition? (Move existing wallpapers)
   - **Action:** Include in migration plan

4. **Testing Strategy**
   - ❓ How to safely test plasma config changes?
   - ❓ VM? Separate user account? Backup strategy?
   - **Recommendation:** Plan comprehensive testing approach in Phase 3

### Areas for Further Research (If Needed)

1. **Plasma-manager Internal Implementation**
   - How exactly do desktop scripts work?
   - Can we inspect what plasma-manager will write before applying?

2. **KDE Plasma Config Reload**
   - Do config changes require logout/login?
   - Can configs be reloaded without session restart?

3. **chezmoi_modify_manager Updates**
   - How to update managed configs when source files change?
   - Workflow for incorporating GUI changes back into chezmoi?

---

## Research Sources

### Official Documentation
1. [KDE Frameworks 6 Porting Guide](https://develop.kde.org/docs/features/configuration/porting_kf6) - KF6 changes
2. [Chezmoi Templates](https://chezmoi.io/reference/templates/) - Template syntax
3. [Chezmoi .chezmoiignore](https://chezmoi.io/reference/special-files-and-directories/chezmoiignore/) - Ignore patterns
4. [plasma-manager Options](https://nix-community.github.io/plasma-manager/options.xhtml) - Available options

### Community Resources
5. [Managing KDE Dotfiles with Chezmoi and Chezmoi Modify Manager](https://www.lorenzobettini.it/2025/09/managing-kde-dotfiles-with-chezmoi-and-chezmoi-modify-manager/) - Lorenzo Bettini's guide
6. [plasma-manager Immutability Discussion #120](https://github.com/nix-community/plasma-manager/discussions/120) - Merge/overwrite behavior
7. [Strategies for Declarative Approaches (NixOS Discourse)](https://discourse.nixos.org/t/strategies-for-declarative-approaches-to-programs-with-mutable-configuration-files/66276) - Mutable config patterns
8. Reddit: "Where does KDE6 store its configuration files?" - Config locations

### Tools & Projects
9. [chezmoi_modify_manager](https://github.com/VorpalBlade/chezmoi_modify_manager) - INI filter tool
10. Community dotfiles examples (GitHub)

---

## Next Steps for Phase 3 (Migration Planning)

### Inputs for Planning

**Context Gathered:**
- ✅ Complete inventory of plasma config files (Phase 1)
- ✅ Categorization by priority and complexity (Phase 1)
- ✅ Understanding of plasma-manager behavior (Phase 2)
- ✅ Best practices for chezmoi + KDE (Phase 2)
- ✅ Tool recommendations (chezmoi_modify_manager) (Phase 2)

**Ready for:**
- Designing 3-5 migration phases
- Risk assessment per phase
- Rollback strategies
- Testing approach
- Success criteria

**Questions to Answer in Planning:**
1. Which configs migrate first? (Low-risk → High-risk)
2. When to introduce `chezmoi_modify_manager`?
3. How to test each phase safely?
4. What's the rollback procedure?
5. How to handle wallpaper directory migration?

---

**Status:** ✅ Phase 2 Complete - Comprehensive web research finished
**Next:** Phase 3 - Migration Planning (Planner Role + Sequential Thinking/Ultrathink)
**Created by:** Phase 2 Web Research (Technical Researcher Role)
**Last Updated:** 2025-12-02T19:35:00+02:00 (Europe/Athens)

---

**Research Confidence Summary**

| Topic | c | Band | Quality |
|-------|---|------|---------|
| KDE Plasma 6 config structure | 0.85 | C | HIGH |
| plasma-manager behavior | 0.90 | C | VERY HIGH |
| Chezmoi + KDE best practices | 0.88 | C | HIGH |
| .chezmoiignore patterns | 0.85 | C | HIGH |
| INI file templating | 0.90 | C | VERY HIGH |
| **Overall Research** | **0.87** | **C** | **HIGH** |

**Confidence Assessment:** Research findings are solid and actionable. Ready to proceed with comprehensive migration planning in Phase 3.
