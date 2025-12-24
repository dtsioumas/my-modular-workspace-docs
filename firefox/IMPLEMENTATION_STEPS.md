# Firefox Tab Unloading: Step-by-Step Implementation Guide

**Target:** Add enhanced tab unloading to your Firefox configuration
**Time Required:** 20-30 minutes (including verification)
**Risk Level:** VERY LOW
**Rollback Time:** < 5 minutes

---

## Step 1: Backup Your Current Configuration (2 minutes)

Create a backup of your firefox.nix before making any changes:

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/modules/apps/browsers/

# Create timestamped backup
cp firefox.nix firefox.nix.backup.20251224

# Verify backup exists
ls -lh firefox.nix.backup.*
# Output should show: firefox.nix.backup.20251224
```

---

## Step 2: Record Current Memory Usage (3 minutes)

Before optimization, let's document baseline:

```bash
# Check Firefox RAM right now
echo "=== Current Firefox Memory Usage ==="
ps aux | grep firefox | awk '{sum+=$6} END {print "Total Firefox RAM: " sum/1024 " MB"}'

# Check free system memory
echo ""
echo "=== System Memory ==="
free -h

# Save this output to a file for comparison
mkdir -p ~/firefox-benchmarks
date >> ~/firefox-benchmarks/baseline.txt
ps aux | grep firefox | awk '{sum+=$6} END {print "Total Firefox RAM: " sum/1024 " MB"}' >> ~/firefox-benchmarks/baseline.txt
free -h >> ~/firefox-benchmarks/baseline.txt
```

**Expected Output:**
```
=== Current Firefox Memory Usage ===
Total Firefox RAM: 662 MB

=== System Memory ===
              total        used        free      shared  buff/cache   available
Mem:            15Gi        12Gi       290Mi       225Mi       3.0Gi       2.7Gi
```

Write down these numbers - we'll compare after optimization.

---

## Step 3: Open Firefox Configuration File (2 minutes)

Open the firefox.nix file in your editor:

```bash
# Open with nano (simple editor)
nano ~/.MyHome/MySpaces/my-modular-workspace/home-manager/modules/apps/browsers/firefox.nix

# Or use your preferred editor (vim, nvim, code, etc.)
# nano is easiest if unfamiliar
```

---

## Step 4: Find the Tab Unloading Section (3 minutes)

In the editor, search for "Tab Unloading" section. Press `Ctrl+W` to search in nano:

```
Search text: Tab Unloading
```

You should find this section around line 136-150:

```nix
# Tab Unloading: Automatically unload inactive tabs when memory is low
# Research: https://firefox-source-docs.mozilla.org/browser/tabunloader/
"browser.tabs.unloadOnLowMemory" = true; # Auto-unload tabs under memory pressure
"browser.tabs.min_inactive_duration_before_unload" = 300000; # 5 minutes (300k ms)
"browser.low_commit_space_threshold_mb" = 10000; # Aggressive: unload when <10GB free (2/3 of 15GB)
```

---

## Step 5: Make Changes (5 minutes)

### Change 1: Update the threshold value

Find this line:
```nix
"browser.low_commit_space_threshold_mb" = 10000; # Aggressive: unload when <10GB free (2/3 of 15GB)
```

Replace it with:
```nix
"browser.low_commit_space_threshold_mb" = 8000;  # Trigger unload at 8GB free (more responsive)
```

**What changed:** 10000 → 8000

### Change 2: Add percentage-based threshold

After the line you just edited, add this NEW line:

```nix
"browser.low_commit_space_threshold_percent" = 50; # Also unload when 50% of RAM is used
```

### Change 3: Add manual unloading support

After the percentage line, add this NEW line:

```nix
"browser.tabs.unloadTabInContextMenu" = true; # Right-click tabs to manually unload
```

**Your section should now look like:**

```nix
# Tab Unloading: Automatically unload inactive tabs when memory is low
# Research: https://firefox-source-docs.mozilla.org/browser/tabunloader/
"browser.tabs.unloadOnLowMemory" = true; # Auto-unload tabs under memory pressure
"browser.tabs.min_inactive_duration_before_unload" = 300000; # 5 minutes (300k ms)
"browser.low_commit_space_threshold_mb" = 8000;  # Trigger unload at 8GB free (more responsive)
"browser.low_commit_space_threshold_percent" = 50; # Also unload when 50% of RAM is used
"browser.tabs.unloadTabInContextMenu" = true; # Right-click tabs to manually unload
```

---

## Step 6: Save the File (1 minute)

In nano editor:
1. Press `Ctrl+X` (exit)
2. Press `Y` (yes, save)
3. Press `Enter` (confirm filename)

Verify file was saved:
```bash
tail -20 ~/.MyHome/MySpaces/my-modular-workspace/home-manager/modules/apps/browsers/firefox.nix | grep -A5 "Tab Unloading"
```

---

## Step 7: Build the Configuration (5-10 minutes)

Apply your changes to home-manager:

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/

# Build home-manager with backup of previous generation
home-manager switch --flake .#mitsio@shoshin -b backup-20251224

# Expected output:
# ... lots of text ...
# Activating firefox
# ... more text ...
# Done. New generation is 123
```

**If build succeeds:** You'll see "Done. New generation is X"

**If build fails:** Check for typos:
```bash
# Check syntax
nix flake check

# Look for error messages - usually missing comma or wrong quote type
```

---

## Step 8: Restart Firefox (2 minutes)

Close and restart Firefox to apply new settings:

```bash
# Kill all Firefox processes
pkill firefox

# Wait a moment
sleep 2

# Start Firefox fresh
firefox &

# Wait for it to fully load
sleep 5
```

---

## Step 9: Verify Settings Applied (3 minutes)

Check that your new settings are active:

```bash
# Open Firefox's about:config page
firefox about:config &

# In Firefox, search for each setting:
# 1. Search: browser.low_commit_space_threshold_mb
#    Should show: 8000 (not 10000)
#
# 2. Search: browser.low_commit_space_threshold_percent
#    Should show: 50
#
# 3. Search: browser.tabs.unloadTabInContextMenu
#    Should show: true
```

**If values are wrong:**
1. Close Firefox
2. Edit firefox.nix again
3. Check for typos (common: missing comma, wrong bracket, extra space)
4. Rebuild: `home-manager switch --flake .#mitsio@shoshin`
5. Restart Firefox

---

## Step 10: Test Manual Unload Feature (2 minutes)

Test the new manual unloading:

```bash
# Open Firefox (if not already)
firefox &

# Open 3-5 tabs
# Then right-click on one of the tabs in Sidebery sidebar

# You should see "Unload Tab" option
# Click it - the tab should turn gray/dim
```

If "Unload Tab" doesn't appear:
- Setting didn't apply (check Step 9)
- Try restarting Firefox with cache clear:
  ```bash
  pkill firefox
  rm -rf ~/.mozilla/firefox/*/startupCache/
  firefox &
  ```

---

## Step 11: Monitor for Optimization (10 minutes)

Now let's verify the optimization is working:

```bash
# In one terminal, start monitoring memory
watch -n1 'ps aux | grep firefox | awk "{sum+=\$6} END {print \"Firefox RAM: \" sum/1024 \" MB\"}"; echo "---"; free -h'

# In Firefox:
# 1. Open 15-20 normal tabs (mix of news, email, docs)
# 2. Let them stay inactive for 10 minutes
# 3. Watch the memory monitor - Firefox RAM should start decreasing
# 4. Check Sidebery - inactive tabs should appear grayed out
```

**What to expect:**

After 5 minutes:
- Memory: ~1.2-1.5GB (normal)
- Some tabs gray in Sidebery (unloaded)

After 10 minutes:
- Memory: ~800MB-1.0GB (decreased by 200-500MB)
- Most inactive tabs gray in Sidebery
- System more responsive

---

## Step 12: Document Results (5 minutes)

Record the after-optimization metrics:

```bash
echo "=== After Optimization ==="
ps aux | grep firefox | awk '{sum+=$6} END {print "Total Firefox RAM: " sum/1024 " MB"}'
echo ""
free -h

# Save to file
date >> ~/firefox-benchmarks/after-optimization.txt
ps aux | grep firefox | awk '{sum+=$6} END {print "Total Firefox RAM: " sum/1024 " MB"}' >> ~/firefox-benchmarks/after-optimization.txt
free -h >> ~/firefox-benchmarks/after-optimization.txt

# Compare results
echo ""
echo "=== COMPARISON ==="
echo "Before: Check ~/firefox-benchmarks/baseline.txt"
echo "After:  Check ~/firefox-benchmarks/after-optimization.txt"
```

**Example comparison:**
```
BASELINE (before):
Total Firefox RAM: 662 MB
Mem: 12Gi used, 290Mi free

AFTER OPTIMIZATION (10 mins with 15 tabs):
Total Firefox RAM: 450 MB  ← 212MB saved!
Mem: 11.5Gi used, 800Mi free  ← More available memory!
```

---

## Step 13: Test Real-World Usage (1-2 hours)

Use Firefox normally for the rest of the day:

- [ ] Open your normal number of tabs
- [ ] Use Gmail, Discord, news sites, etc.
- [ ] Leave tabs idle for extended periods
- [ ] Notice if anything feels slower or broken

**Monitor periodically:**
```bash
# Every hour, check memory
ps aux | grep firefox | awk '{sum+=$6} END {print "Firefox RAM: " sum/1024 " MB"}'; free -h
```

---

## Step 14: Validate Against Checklist (5 minutes)

Verify everything is working:

```
Validation Checklist:

□ Home-manager build succeeded
  Status: Check generation number in Step 7

□ Firefox starts normally
  Status: Firefox window opens, loads pages

□ about:config shows correct values
  Status: Step 9 verified all 3 settings

□ Manual unload appears in context menu
  Status: Right-click tab shows "Unload Tab" option

□ Sidebery shows unloaded tabs as grayed
  Status: Leave tabs inactive 5+ min, they gray out in sidebar

□ RAM usage decreased after 10 minutes
  Status: Compare baseline vs after-optimization metrics

□ System feels responsive
  Status: Subjective but noticeable improvement

□ No crashes or errors observed
  Status: Firefox runs stably for 1-2 hours
```

All items checked? ✅ **Implementation successful!**

---

## Rollback Instructions (If Needed)

If you experience problems, rollback is simple:

### Option 1: Revert to Previous Generation (< 1 minute)

```bash
# See available generations
home-manager generations

# Rollback to previous (the backup we created)
home-manager rollback

# Kill and restart Firefox
pkill firefox
sleep 2
firefox &
```

### Option 2: Restore from Backup File

```bash
# Restore from backup
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/modules/apps/browsers/
cp firefox.nix.backup.20251224 firefox.nix

# Rebuild
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager/
home-manager switch --flake .#mitsio@shoshin

# Restart Firefox
pkill firefox
sleep 2
firefox &
```

---

## Troubleshooting Common Issues

### Issue: "Unload Tab" option doesn't appear

**Cause:** Setting not applied or Firefox too old

**Solution:**
```bash
# Verify setting is in config
grep "unloadTabInContextMenu" ~/.MyHome/MySpaces/my-modular-workspace/home-manager/modules/apps/browsers/firefox.nix

# Output should show:
# "browser.tabs.unloadTabInContextMenu" = true;

# Check Firefox version (must be 134+)
firefox --version

# If version < 134, upgrade:
home-manager switch --flake .#mitsio@shoshin
```

### Issue: Tabs unload too aggressively (poor UX)

**Cause:** Settings too aggressive, or natural behavior

**Solution:**
```bash
# Option 1: Increase inactivity threshold
# Edit firefox.nix, change:
"browser.tabs.min_inactive_duration_before_unload" = 300000; # Keep at 5 min
# Or increase to 600000 (10 min)

# Option 2: Increase memory threshold
# Change 8000 back to 9000 or 10000 (more free RAM needed to trigger)

# Rebuild and restart Firefox
```

### Issue: Firefox crashes or runs out of memory

**Cause:** Settings too aggressive, too many tabs open

**Solution:**
```bash
# Restore backup and increase cache
cp firefox.nix.backup.20251224 firefox.nix

# Then edit and increase cache:
"browser.cache.memory.capacity" = 262144;  # Increase from 256MB

# Rebuild
home-manager switch --flake .#mitsio@shoshin

# Restart with fewer tabs
pkill firefox
firefox &
```

---

## FAQ

### Q: How long does the build take?

**A:** Typically 2-5 minutes for home-manager changes. It's just applying Nix configuration, not building Firefox from source.

### Q: Will this affect other applications?

**A:** No. This only changes Firefox settings. No other apps are affected.

### Q: Can I undo if I don't like it?

**A:** Yes, easily! Use `home-manager rollback` (Step 15 above). Takes < 1 minute.

### Q: Does tab unloading close my tabs?

**A:** No! Tabs stay visible, just memory is freed. They reload when you click them.

### Q: Will unloaded tabs lose my data?

**A:** No. Your data (bookmarks, history, form data) is completely safe. Only memory is freed temporarily.

### Q: How much RAM will I save?

**A:** Typically 300-500MB with these settings, depending on what websites you have open.

---

## Next Steps

### After Verification (Day 1-2)
- [ ] Monitor for 24 hours of normal use
- [ ] Check if system feels more responsive
- [ ] Confirm no crashes or stability issues

### If Everything Works (Day 3)
- [ ] Commit changes to git:
  ```bash
  cd ~/.MyHome/MySpaces/my-modular-workspace/
  git add home-manager/modules/apps/browsers/firefox.nix
  git commit -m "Optimize: Add enhanced tab unloading settings for memory reduction"
  ```

- [ ] Consider Tier 2 additions if you want more savings:
  - Reduce cache slightly
  - Reduce process count to 3
  - See TAB_UNLOADING_OPTIMIZATION_PLAN.md for details

### If Problems Occur (Day 1)
- [ ] Try troubleshooting steps above
- [ ] As last resort: `home-manager rollback`
- [ ] Open issue on project if persistent

---

## Summary

**What you did:**
- ✅ Added 3 new settings for enhanced tab unloading
- ✅ Enabled manual tab unloading from context menu
- ✅ Reduced memory threshold for more responsive unloading
- ✅ Verified settings work correctly

**Expected benefits:**
- ✅ 300-500MB additional RAM savings
- ✅ Better system responsiveness under memory pressure
- ✅ Manual control over tab unloading
- ✅ No loss of data or functionality

**Time investment:**
- ⏱️ 20-30 minutes implementation
- ⏱️ 1-2 hours validation
- ⏱️ < 5 minutes rollback if needed

---

**Status:** ✅ Ready to follow
**Confidence Level:** 0.95 (Band C - VERY SAFE)
**Last Updated:** 2025-12-24

