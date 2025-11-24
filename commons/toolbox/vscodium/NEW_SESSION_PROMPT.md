# VSCode to VSCodium Migration - New Session Prompt

**Copy and paste this prompt to start the migration in a new Claude Code session:**

---

## 📋 Prompt for New Session:

```
Hello! We're on workspace shoshin, working on the desktop-workspace project.

I need your help migrating from VSCode to VSCodium using a fully declarative approach with NixOS Home Manager.

**Project Location:**
~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/

**Please do the following:**

1. **Load project planning documents:**
   - Read: ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/PLAN.md
   - Read: ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/TODO.md

2. **Understand current VSCode setup:**
   - Read: ~/.config/nixos/home/mitso/home.nix (lines 58-99 for extension management)
   - Check current VSCode installation and configuration

3. **Execute the migration following the TODO:**
   - Start with Phase 1: Assessment & Backup
   - Create backups of current VSCode configuration
   - Document current extensions and settings
   - Follow all tasks in sequential order

4. **Use TodoWrite tool to track progress:**
   - Create a todo list from TODO.md
   - Mark tasks as completed as we go
   - Keep me informed of progress

5. **Ask for confirmation before:**
   - Removing VSCode from system
   - Deleting old configurations
   - Any breaking changes

**Goal:** Fully working VSCodium with declarative configuration, all extensions, and settings migrated from VSCode.

**Time estimate:** 4-5 hours (can be split across multiple sessions)

Let's start with Phase 1! 💪
```

---

## Alternative Shorter Prompt:

If you want to start immediately with a specific phase, use this:

```
We're migrating from VSCode to VSCodium declaratively on NixOS.

Project: ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/

Read the PLAN.md and TODO.md in that directory, then start with Phase 1 (Assessment & Backup). Use TodoWrite to track progress through all 26 tasks.

Current VSCode config is in ~/.config/nixos/home/mitso/home.nix (lines 58-99).

Ready to start! 🚀
```

---

## Quick Start Commands:

Once Claude loads the documents, these commands will be useful:

### Read Planning Documents
```bash
# View the plan
cat ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/PLAN.md

# View the TODO
cat ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/TODO.md
```

### Check Current State
```bash
# Current VSCode installation
which code
code --version

# Current extensions
code --list-extensions --show-versions

# Current settings
cat ~/.config/Code/User/settings.json
```

### Start Backup (Phase 1, Task 1.1)
```bash
# Create backup directory
mkdir -p ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups

# Backup settings
cat ~/.config/Code/User/settings.json > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/settings.json

# Backup keybindings
cat ~/.config/Code/User/keybindings.json > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/keybindings.json 2>/dev/null || echo "No custom keybindings"

# List extensions
code --list-extensions --show-versions > ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/backups/extensions-list.txt
```

---

## Session Continuation

If you need to split this across multiple sessions, use this prompt to continue:

```
Continuing VSCode to VSCodium migration for desktop-workspace.

Project: ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/

Please:
1. Read TODO.md to see task list
2. Check which tasks are already completed (look for ✅ or checked boxes)
3. Continue from the next incomplete task
4. Update TODO.md as we complete tasks

Where did we leave off?
```

---

## Tips for a Smooth Migration:

1. **Start during low-work period** - Don't migrate during critical development
2. **Keep VSCode installed initially** - Test VSCodium in parallel first
3. **Take breaks** - 26 tasks is a lot; split across 2-3 sessions
4. **Test thoroughly** - Don't rush through Phase 4 (testing)
5. **Commit often** - Git commit after each phase completion
6. **Ask questions** - If something's unclear, ask Claude to explain

---

## Expected Outcomes:

After migration:
- ✅ VSCodium installed and configured declaratively
- ✅ All settings in ~/.config/nixos/home/mitso/vscodium.nix
- ✅ All extensions managed by Nix (no manual installs)
- ✅ Version controlled configuration
- ✅ VSCode removed from system
- ✅ Documentation updated

---

## Emergency Rollback:

If anything goes wrong:

```bash
# Quick rollback to previous working config
sudo nixos-rebuild switch --rollback

# Or manually disable VSCodium
# Edit ~/.config/nixos/home/mitso/home.nix
# Comment out vscodium.nix import
# Rebuild
```

---

**Ready to start? Copy the prompt above and paste it into a new Claude Code session!**

**Good luck, Μήτσο! 💪🚀**
