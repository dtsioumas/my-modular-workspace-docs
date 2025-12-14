# Firefox Implementation Plan - Critical Fixes & Addendum

**Date:** 2025-12-14
**Type:** Addendum to Implementation Plan
**Purpose:** Address 13 critical issues found in final ultrathink review
**Priority:** Fix CRITICAL issues before starting Phase 0

---

## Executive Summary

Final ultrathink review of the implementation plan revealed **13 issues** that must be addressed:
- **5 CRITICAL** issues (will cause failures)
- **3 HIGH priority** issues (impact UX/testing)
- **5 MEDIUM priority** issues (completeness)

**Plan Confidence**: 0.84 → **0.92** (after fixes)

---

## CRITICAL FIXES (Fix Before Starting!)

### Fix #1: Plasma Integration System Package MISSING ⚠️

**Issue**: Plasma Integration extension requires `plasma-browser-integration` system package.

**Impact**: Extension will silently fail without this package!

**Fix - Add to Phase 2.0 (NEW Pre-step)**:

```markdown
### Phase 2.0: Install System Dependencies

**Before installing extensions**, install required system packages:

```bash
# Check if plasma-browser-integration is installed
nix-env -qa | grep plasma-browser-integration

# If not installed, add to NixOS configuration:
# Edit: hosts/shoshin/nixos/modules/workspace/kde.nix (or appropriate file)
```

```nix
# Add to environment.systemPackages:
environment.systemPackages = with pkgs; [
  plasma-browser-integration  # Required for Plasma Integration Firefox extension
];
```

```bash
# Rebuild NixOS
sudo nixos-rebuild switch

# Verify installation
which plasma-browser-integration
```

**Success Criteria**:
- [ ] plasma-browser-integration package installed at system level
- [ ] `which plasma-browser-integration` returns path
```

---

### Fix #2: Git Workflow Completely Missing! 📝

**Issue**: Plan has NO git commits. User can't track changes or rollback granularly.

**Fix - Add to EVERY Phase**:

#### After Phase 0 (Discovery):
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/
git add docs/firefox/CURRENT_EXTENSIONS.md
git commit -m "docs(firefox): Document current extension inventory

17 extensions discovered from about:support
Baseline backup created at ~/firefox-backup-20251214

🤖 Generated with Claude Code"
```

#### After Phase 1 (Create firefox.nix):
```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
git add firefox.nix home.nix
git commit -m "feat(firefox): Create firefox.nix declarative module

- Migrate settings from home.nix lines 372-434
- Configure NVIDIA GPU acceleration (X11)
- Memory optimizations: 512MB cache, 4 processes
- Enable userChrome.css for vertical tabs
- Set search engine to Google

🤖 Generated with Claude Code

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

#### After Phase 2 (Extensions):
```bash
git add firefox.nix
git commit -m "feat(firefox): Add 11+ declarative extensions

Extensions installed via Enterprise Policies:
- Sidebery (vertical tabs)
- KeePassXC-Browser, Bitwarden (password mgmt)
- Plasma Integration (KDE)
- uBlock Origin (ad blocking)
- Floccus, Multi-Account Containers
- Gmail, Container Tabs, Google Tasks sidebars
- FireShot, Default Bookmark Folder

🤖 Generated with Claude Code

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

#### After Phase 5 (Sidebery):
```bash
git commit -m "feat(firefox): Configure Sidebery vertical tabs

- userChrome.css hides native tab bar
- Sidebery panels configured
- Tree Style Tab removed

🤖 Generated with Claude Code"
```

#### After Phase 8 (Documentation):
```bash
git add docs/firefox/
git commit -m "docs(firefox): Complete Firefox migration documentation

- README with quick reference
- Troubleshooting guide
- Extension inventory
- Updated ADR-009 with Firefox example

🤖 Generated with Claude Code"

git push origin main
```

---

### Fix #3: KeePassXC Verification Steps Missing 🔐

**Issue**: No verification that KeePassXC integration works. Silent failures possible.

**Fix - Add to Prerequisites Section**:

```markdown
### Verify KeePassXC Setup

```bash
# 1. Verify KeePassXC is running
pgrep -a keepassxc || {
  echo "ERROR: KeePassXC not running!"
  echo "Start KeePassXC and unlock vault at ~/MyVault/"
  exit 1
}

# 2. Verify vault location
test -d ~/MyVault/ || {
  echo "ERROR: KeePassXC vault not found at ~/MyVault/"
  echo "Expected per ADR-011. Check vault location."
  exit 1
}

# 3. Verify KeePassXC Browser Integration enabled
# Open KeePassXC → Settings → Browser Integration
# Verify "Enable browser integration" is checked
# Verify "Firefox" is enabled

# 4. Check for native messaging manifest (will be created on first connect)
# ls ~/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json
# (May not exist yet - will be created when extension first connects)
```
```

**Fix - Add to Phase 6.4 (After Extension Install)**:

```markdown
### Step 6.4.5: Verify KeePassXC-Browser Connection

```bash
# 1. Open Firefox
firefox &

# 2. Navigate to about:addons
# 3. Find KeePassXC-Browser extension
# 4. Click "Manage" → Check it's enabled

# 5. Click KeePassXC-Browser toolbar icon
# 6. Click "Connect" button
# 7. Switch to KeePassXC → Grant permission popup

# 8. Verify native messaging manifest created:
cat ~/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json

# Should show:
# {
#   "name": "org.keepassxc.keepassxc_browser",
#   "description": "KeePassXC integration with native messaging support",
#   ...
# }
```

**Success Criteria**:
- [ ] KeePassXC running and vault unlocked
- [ ] Vault exists at ~/MyVault/
- [ ] KeePassXC-Browser extension connects successfully
- [ ] Native messaging manifest created
```

---

### Fix #4: Extension Auto-Enable Verification Missing ✅

**Issue**: Critical setting `extensions.autoDisableScopes = 0` not verified before installing extensions.

**Fix - Add to Phase 1 Success Criteria**:

```markdown
### Step 1.5: Verify Critical Settings Applied

After `home-manager switch`:

```bash
# 1. Start Firefox
firefox &

# 2. Navigate to about:config

# 3. Search for: extensions.autoDisableScopes
# Expected: 0 (zero)
# If not 0, extensions will require manual approval!

# 4. Alternative: Check prefs.js
grep "extensions.autoDisableScopes" ~/.mozilla/firefox/*.default*/prefs.js

# Should show:
# user_pref("extensions.autoDisableScopes", 0);
```

**Success Criteria**:
- [ ] extensions.autoDisableScopes = 0 in about:config ✅ CRITICAL
- [ ] toolkit.legacyUserProfileCustomizations.stylesheets = true
- [ ] search.default = "Google"
```

---

### Fix #5: Backup Strategy Incomplete 💾

**Issue**: No size check, no verification, inconsistent backup dates.

**Fix - Replace Phase 0.2**:

```markdown
### Step 0.2: Create Baseline Snapshot

**IMPORTANT**: Lock backup to 2025-12-14 for consistency with plan.

```bash
# 1. Check Firefox profile size (estimate disk space needed)
du -sh ~/.mozilla/firefox/*.default*
# Example output: 2.3G

# 2. Check available disk space
df -h ~
# Ensure you have 3-4GB free

# 3. Set backup directory (LOCKED DATE for plan consistency)
BACKUP_DIR=~/firefox-backup-20251214

# 4. Check if backup already exists
if [ -d "$BACKUP_DIR" ]; then
  echo "ERROR: Backup already exists at $BACKUP_DIR"
  echo "Remove it first or use a different name"
  exit 1
fi

# 5. Create backup
echo "Creating Firefox profile backup..."
cp -r ~/.mozilla/firefox/*.default* "$BACKUP_DIR"

# 6. Verify backup
ls -lah "$BACKUP_DIR"
du -sh "$BACKUP_DIR"

# 7. Verify critical files backed up
test -f "$BACKUP_DIR"/prefs.js || echo "WARNING: prefs.js not found in backup!"
test -d "$BACKUP_DIR"/extensions || echo "WARNING: extensions/ not found in backup!"

# 8. Create backup manifest
cat > "$BACKUP_DIR/BACKUP_MANIFEST.txt" << EOF
Firefox Profile Backup
Date: $(date)
Source: $(readlink -f ~/.mozilla/firefox/*.default*)
Size: $(du -sh "$BACKUP_DIR" | cut -f1)
Files: $(find "$BACKUP_DIR" -type f | wc -l)
Extensions: $(ls "$BACKUP_DIR"/extensions/*.xpi 2>/dev/null | wc -l)
EOF

cat "$BACKUP_DIR/BACKUP_MANIFEST.txt"
```

**Success Criteria**:
- [ ] Backup created at ~/firefox-backup-20251214/
- [ ] Backup size matches profile size (~2-3GB typical)
- [ ] prefs.js exists in backup
- [ ] extensions/ directory exists with 17 .xpi files
- [ ] BACKUP_MANIFEST.txt created
```

---

## HIGH PRIORITY FIXES (Strongly Recommended)

### Fix #6: Extension ID Discovery Workflow Incomplete 📋

**Issue**: Phase 0.1 says "open about:support" but provides NO instructions for documenting results.

**Fix - Add to Phase 0.1**:

```markdown
### Step 0.1.5: Create Extension Inventory Document

```bash
# Create documentation directory
mkdir -p ~/.MyHome/MySpaces/my-modular-workspace/docs/firefox/

# Create extension inventory template
cat > ~/.MyHome/MySpaces/my-modular-workspace/docs/firefox/CURRENT_EXTENSIONS.md << 'EOF'
# Currently Installed Firefox Extensions

**Date Discovered**: 2025-12-14
**Firefox Profile**: ~/.mozilla/firefox/*.default*
**Total Extensions**: 17

## Extension Inventory

| Extension Name | Extension ID | Filename | Keep/Remove | Notes |
|---------------|--------------|----------|-------------|-------|
| uBlock Origin | uBlock0@raymondhill.net | uBlock0@raymondhill.net.xpi | ✅ Keep | Ad blocker |
| Tree Style Tab | treestyletab@piro.sakura.ne.jp | treestyletab@piro.sakura.ne.jp.xpi | ❌ Remove | Replace with Sidebery |
| Floccus | floccus@handmadeideas.org | floccus@handmadeideas.org.xpi | ✅ Keep | Bookmark sync |
| Multi-Account Containers | @testpilot-containers | @testpilot-containers.xpi | ✅ Keep | Container management |
| Tab Stash | tab-stash@condordes.net | tab-stash@condordes.net.xpi | ❓ TBD | User decision |
| Bitwarden (likely) | {446900e4-71c2-419f-a6a7-df9c091e268b} | {446900e4-71c2-419f-a6a7-df9c091e268b}.xpi | ✅ Keep | Password manager |
| Unknown #1 | TO_FILL_FROM_ABOUT_SUPPORT | {3c078156-979c-498b-8990-85f7987dd929}.xpi | ? | 611K |
| Unknown #2 | TO_FILL_FROM_ABOUT_SUPPORT | {a8776b67-902b-48c9-b196-0dc12ea75e08}.xpi | ? | 529K |
| Unknown #3 | TO_FILL_FROM_ABOUT_SUPPORT | {65252973-2e9e-427a-824f-6960f7806997}.xpi | ? | 145K |
| Unknown #4 | TO_FILL_FROM_ABOUT_SUPPORT | {96b7a652-8716-4678-be68-7a8bac53a373}.xpi | ? | 74K |
| Unknown #5 | TO_FILL_FROM_ABOUT_SUPPORT | {e75d6907-918c-4c8d-8f98-4b7ae39bf672}.xpi | ? | 14K |
| Unknown #6 | TO_FILL_FROM_ABOUT_SUPPORT | {7629eb30-af71-485c-b36f-52c0fc38bc01}.xpi | ? | 12K |
| Unknown #7 | TO_FILL_FROM_ABOUT_SUPPORT | {01d445cd-ab9b-4b72-8dec-02b49a859a76}.xpi | ? | 8.2K |
| Unknown #8 | TO_FILL_FROM_ABOUT_SUPPORT | {19289993-e8b6-4401-84b7-93391b61ff0a}.xpi | ? | 8.3K |
| Unknown #9 | TO_FILL_FROM_ABOUT_SUPPORT | {a9db16ed-87ed-4471-912f-456f47326340}.xpi | ? | 7.6K |

## How to Fill This In

1. Open Firefox
2. Navigate to: about:support
3. Scroll to: "Extensions" section
4. For each extension, copy:
   - Name
   - ID (shown in parentheses or in details)
5. Match the ID to the filename above (by searching for the ID in the filename)
6. Fill in the "Extension Name" and "Extension ID" columns
7. Decide "Keep/Remove" based on:
   - ✅ Keep if you use it regularly
   - ❌ Remove if redundant or unused
   - ❓ TBD if unsure

## Extension Keep/Remove Decisions

**Automatically Keep**:
- uBlock Origin (ad blocker)
- KeePassXC-Browser (password manager - already requested)
- Floccus (bookmark sync - already requested)
- Multi-Account Containers (already requested)
- Bitwarden (already requested)

**Automatically Remove**:
- Tree Style Tab (replacing with Sidebery)

**User Decision Required**:
- Tab Stash - Do you still use this?
- Any other unknown extensions

EOF

echo "Extension inventory template created!"
echo "File: ~/.MyHome/MySpaces/my-modular-workspace/docs/firefox/CURRENT_EXTENSIONS.md"
echo ""
echo "Next: Open Firefox → about:support → Fill in the extension names and IDs"
```

**Deliverable**: `docs/firefox/CURRENT_EXTENSIONS.md` with all 17 extensions identified.
```

---

### Fix #7: Performance Baseline Missing 📊

**Issue**: Phase 7 tests performance but has no "before migration" baseline to compare against.

**Fix - Add to Phase 0**:

```markdown
### Step 0.5: Capture Performance Baseline

**Purpose**: Capture current Firefox performance BEFORE migration for comparison.

```bash
# Create baseline directory
mkdir -p ~/firefox-backup-20251214/baseline-metrics/

# Close all Firefox instances
pkill firefox
sleep 5

# Start Firefox with CURRENT configuration (before migration)
firefox &
FIREFOX_PID=$!
sleep 30  # Let it settle

# 1. Baseline RAM (idle)
echo "=== IDLE RAM ===" > ~/firefox-backup-20251214/baseline-metrics/ram.txt
ps aux | grep firefox | awk '{sum+=$6} END {print "Pre-migration Idle RAM: " sum/1024 " MB"}' >> ~/firefox-backup-20251214/baseline-metrics/ram.txt

# 2. Open 10 tabs (manually or via script)
echo "Open these 10 tabs manually:"
echo "1. about:support"
echo "2-10. Your most common websites"
read -p "Press Enter when all 10 tabs are open..."

# Wait for tabs to load
sleep 30

# RAM with 10 tabs
echo "=== 10 TABS RAM ===" >> ~/firefox-backup-20251214/baseline-metrics/ram.txt
ps aux | grep firefox | awk '{sum+=$6} END {print "Pre-migration 10-tab RAM: " sum/1024 " MB"}' >> ~/firefox-backup-20251214/baseline-metrics/ram.txt

# 3. GPU status
echo "=== GPU STATUS ===" > ~/firefox-backup-20251214/baseline-metrics/gpu.txt
nvidia-smi >> ~/firefox-backup-20251214/baseline-metrics/gpu.txt

# 4. CPU usage (10 second sample)
echo "=== CPU USAGE ===" > ~/firefox-backup-20251214/baseline-metrics/cpu.txt
top -b -n 3 -d 3 | grep firefox >> ~/firefox-backup-20251214/baseline-metrics/cpu.txt

# 5. Display baseline summary
echo ""
echo "=== BASELINE METRICS CAPTURED ==="
cat ~/firefox-backup-20251214/baseline-metrics/ram.txt
echo ""
echo "Full metrics saved to: ~/firefox-backup-20251214/baseline-metrics/"

# Close Firefox
pkill firefox
```

**Deliverables**:
- `~/firefox-backup-20251214/baseline-metrics/ram.txt`
- `~/firefox-backup-20251214/baseline-metrics/gpu.txt`
- `~/firefox-backup-20251214/baseline-metrics/cpu.txt`

**Then in Phase 7.2 - Add Comparison**:

```bash
# Compare with baseline
echo "=== PERFORMANCE COMPARISON ==="
echo ""
echo "BEFORE (from baseline):"
cat ~/firefox-backup-20251214/baseline-metrics/ram.txt
echo ""
echo "AFTER (current):"
ps aux | grep firefox | awk '{sum+=$6} END {print "Post-migration 10-tab RAM: " sum/1024 " MB"}'
echo ""
echo "Improvement calculation left as exercise ;-)"
```
```

---

### Fix #8: Firefox Profile Path Not Verified 🔍

**Issue**: Plan assumes `~/.mozilla/firefox/*.default*` exists without verification.

**Fix - Add to Prerequisites Section**:

```markdown
### Verify Firefox Profile Exists

```bash
# 1. Check Firefox has run at least once
if ! ls ~/.mozilla/firefox/*.default* 2>/dev/null; then
  echo "ERROR: No Firefox profile found!"
  echo "Please run Firefox at least once to create a profile."
  echo ""
  echo "Run: firefox"
  echo "Wait for it to open, then close it."
  exit 1
fi

# 2. Identify default profile
echo "Firefox profiles found:"
ls -d ~/.mozilla/firefox/*.default* 2>/dev/null

# 3. Check profiles.ini for default profile
echo ""
echo "Default profile configuration:"
cat ~/.mozilla/firefox/profiles.ini | grep -A5 "Default=1"

# 4. Get exact profile path for use in plan
PROFILE_PATH=$(ls -d ~/.mozilla/firefox/*.default* 2>/dev/null | head -1)
echo ""
echo "Using profile: $PROFILE_PATH"

# 5. Verify profile has extensions (expected if Firefox was used before)
if [ -d "$PROFILE_PATH/extensions" ]; then
  echo "Extensions directory exists: $(ls $PROFILE_PATH/extensions/*.xpi 2>/dev/null | wc -l) extensions found"
else
  echo "WARNING: No extensions directory yet (might be first run)"
fi
```

**Success Criteria**:
- [ ] Firefox profile exists at ~/.mozilla/firefox/*.default*
- [ ] profiles.ini shows default profile
- [ ] Profile path identified for backup
```

---

## MEDIUM PRIORITY FIXES (Recommended for Completeness)

### Fix #9: Missing home.nix Import Location Details

**Issue**: Plan says "edit home.nix imports" but doesn't show exact location.

**Fix - Update Phase 1.2**:

```markdown
### Step 1.2: Import firefox.nix in home.nix

**File**: `~/.MyHome/MySpaces/my-modular-workspace/home-manager/home.nix`

```bash
# Open home.nix
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
$EDITOR home.nix
```

Find the `imports = [` section (usually near the top of the file).

**Add** `./firefox.nix` to the imports list:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Existing imports (keep these):
    ./atuin.nix
    ./brave.nix
    ./git.nix
    # ... other imports ...

    # NEW: Add this line:
    ./firefox.nix
  ];

  # ... rest of file ...
}
```

**Location**: Add after `./brave.nix` (keeps browser configs together).
```

---

### Fix #10: Chezmoi Relationship Not Explained (ADR-009)

**Issue**: Plan uses home-manager for userChrome.css but never explains why (ADR-009 exception).

**Fix - Add to Phase 1 Introduction**:

```markdown
## Architectural Decision: userChrome.css Placement

**ADR-009 Pattern**:
- Layer 1 (home-manager): Package installation
- Layer 2 (chezmoi): Configuration files

**Our Decision**: userChrome.css in **home-manager** (exception to ADR-009)

**Rationale**:
1. **Atomic Updates**: userChrome.css tightly coupled with Firefox settings
   - Changes to firefox.nix and userChrome.css should be atomic
   - Single `home-manager switch` applies both
2. **Single Source of Truth**: All Firefox config in one module
   - Easier to maintain
   - No sync issues between home-manager and chezmoi
3. **Rollback Simplicity**: `home-manager rollback` reverts both settings + UI

**Trade-offs Accepted**:
- ❌ Less portable across distros (Nix-specific)
- ❌ Violates ADR-009 layer separation
- ✅ Better atomic guarantees
- ✅ Simpler maintenance

**Future Migration Path** (if needed):
If you later want userChrome.css in chezmoi:
1. Remove `userChrome = ''...''` from firefox.nix
2. Create `dotfiles/dot_mozilla/firefox/*/chrome/userChrome.css.tmpl` in chezmoi
3. Run `chezmoi apply`

**Documentation**: This exception is documented in ADR-009 update (Phase 8.2).
```

---

### Fix #11: Home-Manager Flake Path Not Verified

**Issue**: Commands use `.#mitsio@shoshin` without verifying flake location.

**Fix - Add to Prerequisites**:

```markdown
### Verify Home-Manager Flake Configuration

```bash
# 1. Navigate to home-manager directory
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/

# 2. Verify flake.nix exists
test -f flake.nix || {
  echo "ERROR: flake.nix not found!"
  echo "Expected at: $(pwd)/flake.nix"
  exit 1
}

# 3. Show flake outputs
echo "Flake outputs:"
nix flake show .

# Expected to see:
# └───homeConfigurations
#     └───mitsio@shoshin

# 4. Verify flake reference
echo ""
echo "Flake reference to use in commands: .#mitsio@shoshin"
echo "Full path: $(pwd)#mitsio@shoshin"

# 5. Test build (dry-run to verify config)
echo ""
echo "Testing flake build (dry-run)..."
nix flake check .
```

**All subsequent commands assume**:
- Working directory: `~/.MyHome/MySpaces/my-modular-workspace/home-manager/`
- Flake reference: `.#mitsio@shoshin`

**If your flake reference is different**, replace `.#mitsio@shoshin` with your actual reference.
```

---

### Fix #12: Sidebery Configuration Migration Gap

**Issue**: No mention of exporting Tree Style Tab config or Sidebery first-launch wizard.

**Fix - Add to Phase 5**:

```markdown
### Step 5.0: Export Tree Style Tab Configuration (Optional)

**If you want to recreate your Tree Style Tab setup in Sidebery**:

```bash
# 1. Before removing Tree Style Tab
# 2. Open Firefox → Tree Style Tab settings (right-click in TST sidebar)
# 3. Export configuration to file
# 4. Save to backup:
mkdir -p ~/firefox-backup-20251214/tree-style-tab-config/
# Manual: Save exported config to the above directory
```

---

### Step 5.2.5: Sidebery First-Launch Configuration Wizard

**On first Sidebery launch, configuration wizard will appear**:

1. **Tabs Tree Limit**:
   - Recommended: 3 levels
   - Prevents deeply nested tabs

2. **Style/Theme**:
   - Recommended: Proton (matches Firefox)
   - Alternative: Compact (saves space)

3. **Sidebar Position**:
   - Left (default, matches TST)

4. **Auto-hide**:
   - Disabled (sidebar always visible)
   - Alternative: Enable if you prefer more screen space

5. **Tab Colorization**:
   - By domain (automatically color tabs by website)

6. **Click behavior**:
   - Click to activate tab
   - Middle-click to close tab

Click "Save and Continue" when done.

**Success Criteria**:
- [ ] Tree Style Tab config exported (if desired)
- [ ] Sidebery first-launch wizard completed
- [ ] Sidebery sidebar displays tabs vertically
```

---

### Fix #13: Documentation Files - Missing Exact Paths

**Issue**: Phase 8 mentions files but doesn't create them with exact paths.

**Fix - Update Phase 8.3**:

```markdown
### Step 8.3: Create Troubleshooting Guide

**File**: `~/.MyHome/MySpaces/my-modular-workspace/docs/firefox/TROUBLESHOOTING.md`

```bash
# Create troubleshooting guide
cat > ~/.MyHome/MySpaces/my-modular-workspace/docs/firefox/TROUBLESHOOTING.md << 'EOF'
# Firefox Troubleshooting Guide

**Last Updated**: 2025-12-14

---

## Extensions Not Auto-Enabling

**Symptom**: Extensions appear in about:addons but show "disabled" or require manual approval.

**Cause**: `extensions.autoDisableScopes` not set to 0.

**Fix**:
1. Open Firefox → about:config
2. Search: `extensions.autoDisableScopes`
3. Verify value is: **0** (zero)
4. If not 0, edit firefox.nix and rebuild

---

## Native Tab Bar Still Visible

**Symptom**: Horizontal tab bar at top still visible despite userChrome.css.

**Cause**: userChrome.css not applied or cached.

**Fix**:
1. Verify userChrome.css exists:
   ```bash
   ls ~/.mozilla/firefox/*.default*/chrome/userChrome.css
   ```
2. If missing, rebuild home-manager:
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
   home-manager switch --flake .#mitsio@shoshin
   ```
3. Clear Firefox cache and restart:
   - Close all Firefox windows
   - `rm -rf ~/.mozilla/firefox/*.default*/startupCache/`
   - Restart Firefox

---

## GPU Acceleration Not Working

**Symptom**: about:support shows "Compositing: Basic" or "GPU #1 Active: No"

**Checks**:
1. Verify NVIDIA drivers loaded:
   ```bash
   nvidia-smi
   ```
2. Verify session variables set:
   ```bash
   env | grep -E 'LIBVA|GBM|GLX|MOZ'
   ```
   Expected:
   - LIBVA_DRIVER_NAME=nvidia
   - GBM_BACKEND=nvidia-drm
   - __GLX_VENDOR_LIBRARY_NAME=nvidia
   - MOZ_USE_XINPUT2=1
   - MOZ_WEBRENDER=1

3. Check firefox.nix settings:
   - `layers.acceleration.force-enabled = true`
   - `gfx.webrender.all = true`
   - `gfx.webrender.force-disabled = false`

---

## KeePassXC-Browser Won't Connect

**Symptom**: Extension shows "Cannot connect to KeePassXC"

**Fix**:
1. Verify KeePassXC is running:
   ```bash
   pgrep -a keepassxc
   ```
2. Open KeePassXC → Settings → Browser Integration
   - Enable browser integration: ✅
   - Enable Firefox: ✅
3. Click "Connect" in Firefox extension
4. Grant permission in KeePassXC popup
5. Verify native messaging manifest exists:
   ```bash
   cat ~/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json
   ```

---

## Sidebery Not Showing Tabs

**Symptom**: Sidebery sidebar is empty or doesn't show tabs.

**Fix**:
1. Open Sidebery settings (right-click in sidebar)
2. Settings → Panels → Verify "Tabs" panel is configured
3. Check native tab bar is hidden (via userChrome.css)
4. Restart Firefox

---

## Firefox Sync Not Working

**Symptom**: Cannot sign in to Firefox Account or sync not syncing.

**Check**:
1. Verify policies don't block sync:
   - about:policies
   - Should show: DisableFirefoxAccounts = false
2. Check internet connection
3. Verify credentials in KeePassXC

---

## Home-Manager Build Fails

**Symptom**: `home-manager switch` fails with errors.

**Common Causes**:
1. **Syntax error in firefox.nix**:
   - Check for missing semicolons, brackets, quotes
   - Validate nix syntax: `nix-instantiate --parse firefox.nix`

2. **Missing import**:
   - Verify home.nix includes: `imports = [ ./firefox.nix ];`

3. **Hash mismatch** (for extensions):
   - Update XPI URLs in firefox.nix
   - Extensions may have been updated

**Debug**:
```bash
home-manager build --flake .#mitsio@shoshin --show-trace
```

---

## Rollback Instructions

**Rollback to previous generation**:
```bash
home-manager generations
home-manager rollback --to <generation-number>
```

**Restore from backup (emergency)**:
```bash
pkill firefox
rm -rf ~/.mozilla/firefox/*.default*
cp -r ~/firefox-backup-20251214 ~/.mozilla/firefox/
```

---

**For more help**: See docs/firefox/README.md
EOF

echo "Troubleshooting guide created at: docs/firefox/TROUBLESHOOTING.md"
```
```

---

## Summary Table

| # | Issue | Severity | Impact | Fixed |
|---|-------|----------|--------|-------|
| 1 | Plasma Integration system package missing | CRITICAL | Extension fails | ✅ |
| 2 | No git workflow | CRITICAL | Can't track changes | ✅ |
| 3 | KeePassXC verification missing | CRITICAL | Silent failures | ✅ |
| 4 | Extension auto-enable not verified | CRITICAL | Extensions don't work | ✅ |
| 5 | Backup strategy incomplete | CRITICAL | Bad rollback | ✅ |
| 6 | Extension ID discovery incomplete | HIGH | Phase 0 blocked | ✅ |
| 7 | Performance baseline missing | HIGH | Can't compare | ✅ |
| 8 | Firefox profile not verified | HIGH | Assumptions fail | ✅ |
| 9 | home.nix import location unclear | MEDIUM | User confusion | ✅ |
| 10 | Chezmoi relationship unexplained | MEDIUM | ADR-009 violation | ✅ |
| 11 | Flake path not verified | MEDIUM | Build fails | ✅ |
| 12 | Sidebery config migration gap | MEDIUM | Lost settings | ✅ |
| 13 | Documentation paths missing | MEDIUM | Incomplete docs | ✅ |

---

## Updated Plan Confidence

| Metric | Before Fixes | After Fixes |
|--------|-------------|-------------|
| **Overall Confidence** | 0.84 | **0.92** |
| **Confidence Band** | C (HIGH) | **C (VERY HIGH)** |
| **Critical Blockers** | 5 | **0** |
| **Implementation Ready** | No | **YES** |

---

## How to Use This Addendum

1. **Before starting Phase 0**: Apply ALL CRITICAL fixes (#1-#5)
2. **During implementation**: Reference fixes as needed for each phase
3. **Review checklist**: Verify all fixed items as you go

**All fixes have been integrated into this addendum. Use alongside the main implementation plan.**

---

**Addendum Complete**
**Date:** 2025-12-14T19:30:00+02:00 (Europe/Athens)
**Reviewer:** Technical Researcher (Final Ultrathink)
**Status:** ✅ READY FOR IMPLEMENTATION
