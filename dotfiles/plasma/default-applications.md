# Default Applications Configuration

**Created:** 2025-12-04
**Status:** ✅ Complete
**Managed by:** chezmoi
**Location:** `dotfiles/dot_config/mimeapps.list` + custom `.desktop` files

---

## Summary

This document describes the configuration of default applications for KDE Plasma, managed through chezmoi for cross-platform portability.

### Key Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `mimeapps.list` | MIME type associations | `~/.config/mimeapps.list` |
| `codium-newwindow.desktop` | VSCodium launcher (new window) | `~/.local/share/applications/` |
| `brave-pdf.desktop` | Brave PDF launcher (new window) | `~/.local/share/applications/` |
| `obsidian-newwindow.desktop` | Obsidian launcher (new window + vault) | `~/.local/share/applications/` |

---

## Default Applications

### VSCodium (New Window)

**MIME Types Handled:**
- **Text files:** `text/plain`
- **Code files:**
  - C/C++: `text/x-c`, `text/x-c++`, `text/x-csrc`, `text/x-chdr`, `text/x-c++src`, `text/x-c++hdr`
  - Python: `text/x-python`, `text/x-python3`
  - Go: `text/x-go`
  - JavaScript/TypeScript: `text/javascript`, `text/x-javascript`, `application/javascript`, `text/typescript`, `text/x-typescript`
  - Rust: `text/x-rust`
  - Java: `text/x-java`
  - Shell: `application/x-shellscript`, `text/x-sh`, `text/x-bash`, `text/x-zsh`
- **Config files:**
  - JSON: `application/json`, `text/json`
  - YAML: `application/x-yaml`, `text/x-yaml`, `text/yaml`
  - TOML: `application/toml`, `text/x-toml`
  - XML: `application/xml`, `text/xml`
  - Nix: `text/x-nix`, `application/x-nix`
  - INI: `text/x-ini`, `application/x-ini`

**Desktop File:** `codium-newwindow.desktop`
```desktop
Exec=codium --new-window %F
```

**Behavior:** Opens files in a new VSCodium window every time

---

### Brave Browser (PDFs - New Window)

**MIME Types Handled:**
- `application/pdf`

**Desktop File:** `brave-pdf.desktop`
```desktop
Exec=brave --new-window %U
```

**Behavior:** Opens PDFs in a new Brave window

---

### Obsidian (Markdown - New Window + Vault)

**MIME Types Handled:**
- `text/markdown`
- `text/x-markdown`

**Desktop File:** `obsidian-newwindow.desktop`
```desktop
Exec=obsidian --new-window --path=/home/mitsio/ %u
```

**Behavior:**
- Opens markdown files in a new Obsidian window
- Uses the MyHome vault at `/home/mitsio/` by default

---

## Testing

### Verify MIME Associations

```bash
# Check text files
xdg-mime query default text/plain

# Check PDFs
xdg-mime query default application/pdf

# Check markdown
xdg-mime query default text/markdown

# Check JSON
xdg-mime query default application/json
```

**Expected Output:**
```
codium-newwindow.desktop
brave-pdf.desktop
obsidian-newwindow.desktop
codium-newwindow.desktop
```

### Test File Opening

```bash
# Create test files
echo "test" > /tmp/test.txt
echo "{}" > /tmp/test.json
echo "# Test" > /tmp/test.md

# Open with default apps (should open in new windows)
xdg-open /tmp/test.txt    # → VSCodium new window
xdg-open /tmp/test.json   # → VSCodium new window
xdg-open /tmp/test.md     # → Obsidian new window with /home/mitsio/ vault
```

---

## Chezmoi Management

### File Locations in Dotfiles Repo

```
dotfiles/
├── dot_config/
│   └── mimeapps.list                          # MIME associations
└── dot_local/share/applications/
    ├── codium-newwindow.desktop              # VSCodium new window
    ├── brave-pdf.desktop                     # Brave PDF new window
    └── obsidian-newwindow.desktop            # Obsidian new window + vault
```

### Apply Changes

```bash
# Apply all changes
chezmoi apply

# Apply specific files
chezmoi apply ~/.config/mimeapps.list
chezmoi apply ~/.local/share/applications/
```

---

## Migration Notes

### Why These Files Are in Chezmoi

**Decision:** Managed by chezmoi (not home-manager)
**Rationale:**
- Cross-platform compatibility (works on NixOS and Fedora)
- Application-level configuration (not system-level)
- Prepares for Fedora migration
- Easier to version control and sync across machines

**Reference:** [ADR-005: Chezmoi Migration Criteria](../../adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md)

### Previously Managed By

- **Home-Manager symlink:** `~/.local/share/applications/mimeapps.list` was symlinked to Nix store
- **Now:** Direct file management via chezmoi
- **Benefit:** No dependency on Nix for default applications

---

## Troubleshooting

### Problem: Default apps not changing

**Solution:**
```bash
# Clear MIME cache
rm ~/.cache/mimeapps.list ~/.local/share/applications/mimeapps.list.backup

# Reapply chezmoi
chezmoi apply --force ~/.config/mimeapps.list

# Verify
xdg-mime query default text/plain
```

### Problem: New window not opening

**Check desktop file:**
```bash
cat ~/.local/share/applications/codium-newwindow.desktop | grep Exec
```

**Should show:** `Exec=codium --new-window %F`

### Problem: Obsidian opening wrong vault

**Check Obsidian desktop file:**
```bash
cat ~/.local/share/applications/obsidian-newwindow.desktop | grep Exec
```

**Should show:** `Exec=obsidian --new-window --path=/home/mitsio/ %u`

**Adjust vault path if needed:**
```bash
# Edit in dotfiles repo
cd ~/.local/share/chezmoi
chezmoi edit ~/.local/share/applications/obsidian-newwindow.desktop

# Change --path= to your vault location
# Apply changes
chezmoi apply
```

---

## Future Enhancements

### Potential Improvements

- [ ] Add custom .desktop files for other applications (e.g., LibreOffice variants)
- [ ] Configure Firefox as fallback PDF viewer
- [ ] Add application-specific command-line flags (e.g., VSCodium extensions)
- [ ] Create profiles for different workflows (dev, writing, research)

### Fedora Migration

When migrating to Fedora:
- ✅ mimeapps.list will work as-is (standard XDG)
- ✅ .desktop files will work (standard freedesktop.org format)
- ⚠️ May need to adjust `Exec=` paths if application paths differ
- ⚠️ Verify `obsidian`, `codium`, `brave` are installed on Fedora

---

**Last Updated:** 2025-12-04
**Author:** Dimitris Tsioumas (Mitsio)
**Status:** ✅ Production
