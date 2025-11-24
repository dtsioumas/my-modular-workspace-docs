# Declarative VSCodium Migration Project

**Created:** 2025-11-05
**Status:** Planning Complete - Ready for Implementation
**Location:** `~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/`

---

## 📖 Project Overview

This project contains comprehensive planning and task documentation for migrating from proprietary VSCode to open-source VSCodium using a fully declarative NixOS Home Manager configuration.

**Goal:** Replace VSCode with VSCodium while maintaining all functionality through declarative, reproducible configuration.

---

## 📁 Directory Structure

```
declarative-vscodium/
├── README.md                    # This file - project overview
├── PLAN.md                      # Detailed migration strategy and technical approach
├── TODO.md                      # 26 sequential tasks organized in 5 phases
├── NEW_SESSION_PROMPT.md        # Ready-to-use prompt for starting migration
└── backups/                     # (Created during Phase 1)
    ├── settings.json            # Current VSCode settings backup
    ├── keybindings.json         # Current keybindings backup
    ├── extensions-list.txt      # Installed extensions with versions
    └── vscode-version.txt       # Current VSCode version
```

---

## 📚 Documentation Guide

### Start Here: PLAN.md
**Purpose:** High-level strategy and technical approach
**Contains:**
- Executive summary and rationale
- Current state analysis (VSCode setup)
- 5-phase migration strategy
- Technical implementation details
- Risk assessment and mitigation
- Success criteria
- Timeline estimates (4-5 hours)

**Read this first** to understand the overall approach.

### Then: TODO.md
**Purpose:** Detailed task checklist with 26 sequential tasks
**Contains:**
- Phase 1: Assessment & Backup (5 tasks)
- Phase 2: Declarative Configuration (7 tasks)
- Phase 3: Extension Compatibility (4 tasks)
- Phase 4: Migration & Testing (6 tasks)
- Phase 5: Cleanup (4 tasks)
- Troubleshooting guide
- Success checklist

**Use this** as your step-by-step execution guide.

### Finally: NEW_SESSION_PROMPT.md
**Purpose:** Ready-to-copy prompt for starting the migration
**Contains:**
- Complete prompt to paste in new Claude session
- Quick start commands
- Session continuation prompt
- Tips for smooth migration
- Emergency rollback instructions

**Use this** to kickstart the actual migration work.

---

## 🚀 Quick Start

### Option 1: Full Detailed Session
```bash
# Copy the full prompt from NEW_SESSION_PROMPT.md
cat ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/NEW_SESSION_PROMPT.md

# Paste into new Claude Code session
# Claude will read PLAN.md and TODO.md, then start Phase 1
```

### Option 2: Quick Start
```
We're migrating from VSCode to VSCodium declaratively on NixOS.

Project: ~/Workspaces/Personal_Workspace/desktop-workspace/declarative-vscodium/

Read the PLAN.md and TODO.md, then start with Phase 1 (Assessment & Backup). Use TodoWrite to track progress through all 26 tasks.

Current VSCode config: ~/.config/nixos/home/mitso/home.nix (lines 58-99)

Ready to start! 🚀
```

---

## 📋 Migration Phases Overview

### Phase 1: Assessment & Backup (~30 min)
- Export current VSCode configuration
- Document extensions and versions
- Create backups
- Test VSCodium in parallel

### Phase 2: Declarative Configuration (~1.5 hours)
- Create Home Manager VSCodium module
- Convert settings to Nix
- Declare extensions
- Configure keybindings
- Test configuration builds

### Phase 3: Extension Compatibility (~1 hour)
- Categorize extensions by source
- Test critical extensions
- Handle missing extensions
- Configure marketplace access if needed

### Phase 4: Migration & Testing (~1 hour)
- Apply final configuration
- Validate all workflows
- Test language development (Go, Python)
- Test Git integration
- Test DevOps tools

### Phase 5: Cleanup (~30 min)
- Remove VSCode from system
- Clean up old configs
- Update documentation
- Final validation

**Total Time:** 4-5 hours (can be split across sessions)

---

## 🎯 Success Criteria

### Must Have ✅
- All critical extensions working
- Settings preserved
- Keybindings functional
- Language servers operational (Go, Python, Bash)
- Git integration working
- Terminal integration working
- Debugging functional

### Nice to Have ✅
- All theme/cosmetic extensions
- Productivity extensions
- Non-critical integrations

### Acceptable Losses ❌
- Microsoft-proprietary features (telemetry)
- Extensions not available in FOSS ecosystem

---

## 🔧 Key Technologies

- **Editor:** VSCodium (open-source VSCode)
- **Config Management:** NixOS Home Manager
- **Extension Registry:** nixpkgs vscode-extensions + Open VSX
- **Declarative Config:** Nix language
- **Version Control:** Git

---

## 📊 Current State

### VSCode (Current)
- **Location:** System packages
- **Config:** `~/.config/Code/User/`
- **Extensions:** 24 extensions via home.nix activation scripts
- **Update:** Daily systemd timer

### VSCodium (Target)
- **Location:** Home Manager programs.vscode
- **Config:** `~/.config/nixos/home/mitso/vscodium.nix`
- **Extensions:** Declarative via Nix expressions
- **Update:** Automatic on nixos-rebuild

---

## 🛡️ Risk Mitigation

- **Backups created** before any changes
- **VSCode kept** during parallel testing
- **Rollback available** via NixOS generations
- **Documentation complete** for troubleshooting
- **Test phase** before final cleanup

---

## 📖 Related Documentation

### NixOS Config
- Main config: `~/.config/nixos/`
- Home Manager: `~/.config/nixos/home/mitso/`
- Current VSCode config: `home.nix` lines 58-99

### External Resources
- [Home Manager VSCode options](https://nix-community.github.io/home-manager/options.html#opt-programs.vscode.enable)
- [VSCodium project](https://github.com/VSCodium/vscodium)
- [Open VSX Registry](https://open-vsx.org/)
- [nixpkgs vscode-extensions](https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/editors/vscode/extensions)

---

## 🔄 Workflow After Migration

### Adding New Extension
```nix
# Edit ~/.config/nixos/home/mitso/vscodium.nix
programs.vscode = {
  extensions = with pkgs.vscode-extensions; [
    # ... existing extensions
    new-publisher.new-extension
  ];
};

# Apply
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
```

### Changing Settings
```nix
# Edit ~/.config/nixos/home/mitso/vscodium.nix
programs.vscode = {
  userSettings = {
    # ... existing settings
    "new.setting" = "value";
  };
};

# Apply
sudo nixos-rebuild switch --flake ~/.config/nixos#shoshin
```

### Rolling Back
```bash
# Immediate rollback
sudo nixos-rebuild switch --rollback

# Or revert specific git commit
cd ~/.config/nixos
git revert <commit-hash>
sudo nixos-rebuild switch --flake .#shoshin
```

---

## 📝 Notes

- Migration can be split across multiple sessions
- Testing is critical - don't skip Phase 4
- Keep VSCode until confident VSCodium works
- All configuration will be version controlled
- Declarative approach makes configuration portable

---

## 🚨 Emergency Contacts

If stuck during migration:

1. **Check TODO.md troubleshooting section**
2. **Review PLAN.md for technical details**
3. **Use rollback if needed:** `sudo nixos-rebuild switch --rollback`
4. **Ask Claude for help** with specific error messages

---

## ✅ Post-Migration Checklist

After completing all phases:

- [ ] VSCodium launches without errors
- [ ] All extensions loaded and functional
- [ ] Settings applied correctly
- [ ] Go/Python/Bash development works
- [ ] Git integration functional
- [ ] Terminal works correctly
- [ ] VSCode removed from system
- [ ] Configuration committed to git
- [ ] Documentation updated

---

**Status:** Planning complete, ready for execution
**Next Step:** Use prompt from NEW_SESSION_PROMPT.md in a new session
**Estimated Duration:** 4-5 hours
**Risk Level:** Low (with proper backups and testing)

---

**Good luck with the migration, Μήτσο! You got this! 💪🚀**
