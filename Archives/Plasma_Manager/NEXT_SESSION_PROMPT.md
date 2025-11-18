# Next Session - Quick Start Prompt

Copy and paste this into your next Claude Code session:

---

## 🚀 Session Initialization Prompt

```
Load session for desktop-workspace project from thread-continuity.

After loading:
1. Read the NixOS config snapshot at ~/GoogleDrive/Workspaces/Personal_Workspace/llm-tsukuru-project/llm-artifacts/repo_snapshots/nixos-workspaces.json to understand the current configuration structure
2. Read all plasma-manager documentation in ~/Workspaces/Personal_Workspace/desktop-workspace/ (PLASMA_*.md files)
3. Verify that plasma.nix has the correct settings:
   - Wallpaper: /home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg
   - Sound theme: ocean
   - Virtual desktops: 4 in 2 rows (via files.kwinrc)
4. Check if all plasma-manager options used are valid (consult docs)
5. Prepare to use rc2nix to capture current KDE settings
6. Help me verify the config is correct before rebuild

Current status:
- plasma-manager added to flake.nix ✅
- plasma.nix imported in home.nix ✅
- Documentation complete ✅
- Need to: verify config → capture with rc2nix → rebuild → test

Let's continue from where we left off!
```

---

## Alternative: Minimal Prompt

If you just want to continue quickly:

```
Load desktop-workspace from thread-continuity.

We're setting up plasma-manager for declarative KDE config.

Next steps:
1. Verify plasma.nix config is correct
2. Use rc2nix to capture current settings
3. Rebuild with plasma-manager

Continue!
```

---

## What This Will Do

1. **Load session state** from Thread Continuity MCP
   - Restores context about plasma-manager setup
   - Loads files modified list
   - Restores next actions

2. **Read config snapshot**
   - Understands NixOS structure
   - Reviews current configuration
   - Identifies what needs verification

3. **Read documentation**
   - Reviews plasma-manager guides
   - Understands valid options
   - Knows how to use rc2nix

4. **Verify configuration**
   - Checks plasma.nix uses valid options
   - Confirms wallpaper/sound/virtual desktop settings
   - Identifies any issues before rebuild

5. **Continue workflow**
   - Use rc2nix to capture settings
   - Compare with current config
   - Rebuild with confidence

---

## Files That Will Be Read

1. **Session State** (Thread Continuity MCP)
   - Project: desktop-workspace
   - Current focus: plasma-manager setup
   - Files modified: flake.nix, home.nix, plasma.nix, etc.
   - Next actions

2. **Config Snapshot**
   - `~/GoogleDrive/Workspaces/Personal_Workspace/llm-tsukuru-project/llm-artifacts/repo_snapshots/nixos-workspaces.json`
   - Full NixOS config structure
   - All file paths and organization

3. **Documentation** (~/Workspaces/Personal_Workspace/desktop-workspace/)
   - PLASMA_MANAGER_GUIDE.md
   - PLASMA_README.md
   - PLASMA_QUICK_REFERENCE.md
   - PLASMA_RC2NIX_GUIDE.md
   - PLASMA_TROUBLESHOOTING.md
   - TODO.md

4. **Config Files**
   - ~/.config/nixos/flake.nix
   - ~/.config/nixos/home/mitso/plasma.nix
   - ~/.config/nixos/home/mitso/home.nix

---

## Expected Token Usage

**Estimated loading cost:**
- Thread Continuity load: ~2K tokens
- Config snapshot: ~5K tokens
- Documentation files: ~15K tokens
- Total session start: ~22K tokens (11% of budget)

**Remaining for work:** ~178K tokens (89%)

This leaves plenty of room for:
- Running rc2nix
- Comparing configs
- Debugging issues
- Rebuilding system

---

## Success Criteria

After initialization, Claude should:
- ✅ Know we're setting up plasma-manager
- ✅ Understand NixOS config structure
- ✅ Know current plasma settings (wallpaper, sound, virtual desktops)
- ✅ Be familiar with all documentation
- ✅ Be ready to verify config and rebuild

---

## Alternative: If Thread Continuity Fails

If thread-continuity MCP is not available or fails to load:

```
I'm continuing work on plasma-manager setup for declarative KDE Plasma 6 configuration.

Context:
- Added plasma-manager to flake.nix
- Created plasma.nix with wallpaper, sound theme, virtual desktops
- Documentation complete in ~/Workspaces/Personal_Workspace/desktop-workspace/

Read:
1. ~/GoogleDrive/Workspaces/Personal_Workspace/llm-tsukuru-project/llm-artifacts/repo_snapshots/nixos-workspaces.json
2. All PLASMA_*.md files in ~/Workspaces/Personal_Workspace/desktop-workspace/
3. ~/Workspaces/Personal_Workspace/desktop-workspace/TODO.md

My wallpaper: /home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg
Sound theme: ocean
Virtual desktops: 4 in 2 rows

Next: Verify plasma.nix config, use rc2nix, rebuild.
```

---

## Tips

- **Use the full prompt** for complete context restoration
- **Use minimal prompt** if you're in a hurry
- **Use alternative** if thread-continuity isn't working

**Save this file!** You'll need it for the next session.

---

**Location:** ~/Workspaces/Personal_Workspace/desktop-workspace/NEXT_SESSION_PROMPT.md
