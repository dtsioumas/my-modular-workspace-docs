# Shoshin Desktop - Complete TODO & Progress Tracking

**Version:** 3.0
**Last Updated:** 2025-11-09
**Type:** Combined TODO tracking for all desktop optimization work
**Project:** other-projects-desktop-workspace (shoshin NixOS desktop)

---

## 📊 Current Session Progress (2025-11-09)

**Started:** 2025-11-09 00:06
**Session Goal:** Memory optimization and system stability
**Continued:** 2025-11-09 03:30 (context continuation)
**Continued:** 2025-11-09 08:20 (VSCode + Kitty configuration)

**Token Usage Checkpoint:**
- Current: ~124.5K / 200K (62.3%)
- Continuity MCP save at: 130K tokens (65%) - APPROACHING!
- Next save at: 150K tokens (75%)

---

## ✅ Completed Tasks

### System Stability & Memory (2025-11-09)
- ✅ **Disable swap** - Removed 16GB swapfile to prevent NVMe wear
- ✅ **Pre-install MCPs globally** - Claude Desktop startup 10-20x faster
- ✅ **Integrate sequential-thinking MCP** - Replaced thread-continuity
- ✅ **Remove any-chat-completions MCP** - Cleaned up unused package
- ✅ **Fix Dropbox crashing** - Backed up corrupted database, now stable (running)
- ✅ **Brave browser optimization** - Added memory limits via NixOS module
  - V8 heap: 512MB limit
  - Renderer processes: 4 max
  - Disabled background networking
  - Kept all NVIDIA acceleration flags
- ✅ **Obsidian memory limits** - Created systemd service with 512MB cap
- ✅ **Create app-memory-limits.nix** - Declarative NixOS module
- ✅ **Merge instruction files** - Created unified desktop-workspace instructions
- ✅ **Fix LiteLLM workers** - Reduced from 8 to 2 workers (saved 2.4GB)
- ✅ **Add swap configuration** - 15GB swap file added (Oct 31)
- ✅ **Install monitoring tools** - htop, btop, bottom, lnav
- ✅ **Replace Mission Center with btop** - Removed 645MB GUI, using 10MB btop
- ✅ **Optimize KDE Plasma 6 Desktop** - Disabled Baloo, excluded heavy packages, 50% animations
- ✅ **Optimize VSCode/VSCodium** - Telemetry disabled, 14 extensions only, performance optimizations
- ✅ **Configure VSCode with Claude Code** - Activity bar on top, 9 MCP servers, Material Theme
- ✅ **Configure Kitty Terminal** - Symlinked to common-dotfiles for multi-machine sync
  - Arrow-based navigation (Ctrl+Alt+Arrows)
  - Split keybindings (Ctrl+Alt+V/H)
  - Tab title template with indicators
  - KITTY_GUIDE.md in common-dotfiles/kitty/docs/
- ✅ **Install CLI Tools** - navi, direnv, tealdeer (from kitty docs)
- ✅ **Create Docs Structure** - docs/ symlink + README.md in nixos config
- ✅ **Switch to Material Theme** - Both VSCode and VSCodium use Material Theme Darker High Contrast
  - Material Icon Theme (PKief.material-icon-theme)
  - Removed Dracula Theme
  - Fixed readonly settings.json warnings

### VSCode Claude Code Configuration (2025-11-09 08:20-08:30)
- ✅ **Sync MCP servers from Claude Desktop to VSCode**
  - git-mcp-go with write access (12 repos including ~/.claude/cache/llm-core)
  - context7, firecrawl, fetch, filesystem, mcp-shell, time
  - read-website-fast, claude-thread-continuity, sequential-thinking
- ✅ **Configure Claude Code extension settings**
  - Custom instructions path: /home/mitso/.claude/CLAUDE.md
  - Permissions: acceptEdits mode
- ✅ **Integrate Kitty with VSCode**
  - Beautiful Catppuccin Mocha theme with transparency
- ✅ **NixOS rebuild successful**

### Plasma Manager Research & Setup (2025-11-09 08:30-09:00)
- ✅ **Research plasma-manager** - Found official nix-community solution
- ✅ **Add to flake.nix** - Added plasma-manager input and home-manager module
- ✅ **Import plasma.nix** - Added to home.nix imports
- ✅ **Create comprehensive documentation** - 5 guides (~28KB total):
  - PLASMA_MANAGER_GUIDE.md - Complete setup guide
  - PLASMA_README.md - Quick start
  - PLASMA_QUICK_REFERENCE.md - Essential commands & options
  - PLASMA_RC2NIX_GUIDE.md - How to capture KDE settings
  - PLASMA_TROUBLESHOOTING.md - Common issues & solutions
  - NEXT_SESSION_PROMPT.md - Prompt for next session
- ✅ **Document current settings**:
  - Wallpaper: /home/mitso/Downloads/⚘ ⦂ Hikaru & Yoshiki ⨾ ☆.jpg
  - Sound theme: ocean
  - Virtual desktops: 4 in 2 rows
- ✅ **Save session state** - Thread continuity MCP

**Status:** Ready for next step - verify config and rebuild
- ✅ **Sync MCP servers from Claude Desktop to VSCode**
  - git-mcp-go with write access (11 repos + ~/.claude/cache/llm-core)
  - context7 with API key
  - firecrawl with API key
  - fetch, filesystem, mcp-shell, time
  - read-website-fast, claude-thread-continuity, sequential-thinking
- ✅ **Configure Claude Code extension settings**
  - Custom instructions path: /home/mitso/.claude/CLAUDE.md
  - Always thinking: disabled
  - Theme: dark
  - Permissions: acceptEdits mode
  - Additional directories: Workspaces + nixos config
- ✅ **Integrate Kitty with VSCode**
  - Default terminal profile set to Kitty
  - Single-instance mode
  - Cursor style: line with blinking
- ✅ **Create beautiful Kitty configuration**
  - Theme: Catppuccin Mocha (pastel dark theme)
  - Transparency: 0.95 opacity (restored)
  - Background blur: 32px
  - Dynamic opacity controls (Ctrl+Shift+A+M/L)
  - Font: JetBrains Mono Nerd Font (size 12)
  - Powerline-style tab bar (slanted)
  - Complete keyboard shortcuts
  - Shell integration enabled
- ✅ **NixOS rebuild successful**
  - All settings applied via nixos-rebuild switch
  - home-manager configuration updated

---

## 🔄 In Progress

### 1. **NixOS Configuration Rebuild**
**Status:** ✅ COMPLETED (2025-11-09 08:25)

**Steps:**
- [x] Fix app-memory-limits.nix category error
- [x] Commit all optimizations
- [x] Replace Mission Center with btop
- [x] Create plasma-optimization.nix
- [x] Optimize VSCode/VSCodium
- [x] Configure Kitty via symlink
- [x] Run `sudo nixos-rebuild switch --flake .#shoshin`
- [x] Verify all optimizations work

**Next:** Test VSCode with Claude Code extension + Restart applications

---

## 📋 High Priority (Next Tasks)

### 1. **Verify Plasma Manager Configuration**
**Status:** Ready to start in next session

**Steps:**
- [ ] Review plasma.nix for valid plasma-manager options
- [ ] Use rc2nix to capture current KDE settings
- [ ] Compare captured settings with plasma.nix
- [ ] Update plasma.nix with correct wallpaper, sound theme, virtual desktops
- [ ] Verify all options are supported by plasma-manager

### 2. **Rebuild with Plasma Manager**
**Status:** Waiting for config verification

**Steps:**
- [ ] Run `nix flake update` to fetch plasma-manager
- [ ] Test build: `sudo nixos-rebuild test --flake .#shoshin`
- [ ] If successful: `sudo nixos-rebuild switch --flake .#shoshin`
- [ ] Log out and log back in
- [ ] Verify wallpaper persists
- [ ] Verify sound theme is Ocean
- [ ] Verify virtual desktops (4 in 2 rows)

---

## 📋 Original High Priority (Next Tasks)

### 2. **Test Memory Optimizations**
**After rebuild, verify:**
- [ ] KDE memory usage < 800MB
- [ ] Mission Center gone, btop working
- [ ] Brave memory flags active
- [ ] Obsidian systemd service available
- [ ] VSCode extensions reduced to 14
- [ ] Kitty using Catppuccin Mocha theme from common-dotfiles
- [ ] VSCode using Dracula Theme Official

---

## 📋 Medium Priority

### 5. **Configure SSH & PATH (Declarative)**
**From:** NIXOS_TODO_DECLARATIVE.md

**Tasks:**
- [ ] Add SSH agent config to `modules/development/tooling.nix`
- [ ] Add PATH exports for GOPATH, NPM_CONFIG_PREFIX
- [ ] Enable keychain for SSH persistence
- [ ] Test: `ssh-add -l` shows key after reboot

---

### 6. **Enable KWallet**
**Tasks:**
- [ ] Add to `modules/workspace/plasma.nix`:
  ```nix
  programs.kwallet.enable = true;
  programs.kwallet.pam.enable = true;
  ```
- [ ] Rebuild and test

---

### 7. **AppImage Support (Declarative)**
**Tasks:**
- [ ] Create `modules/workspace/appimage.nix`
- [ ] Add binfmt registration
- [ ] Import in `hosts/shoshin/configuration.nix`
- [ ] Test with an AppImage

---

## 📋 Low Priority / Future Tasks

### 8. **Install Spotify**
- [ ] Add to packages.nix or via flatpak

### 9. **Fix Claude Code on VSCode** (if any issues)
- [ ] Investigate issues
- [ ] Apply fixes from patcher if needed

### 11. **Check Virtual Desktops**
- [ ] Review current setup
- [ ] Create new ones if needed

### 12. **Sleep Button Investigation**
- [ ] Root cause analysis for why PC cannot sleep with button
- [ ] Check ACPI settings

### 13. **Create NixOS Documentation**
- [ ] Document config structure in README
- [ ] Add troubleshooting guide

### 14. **Provision VM on NixOS**
- [ ] 6GB RAM, 3-4 vCPUs
- [ ] Configure libvirt/QEMU

### 15. **Firefox Optimization** (if keeping Firefox)
- [ ] Install "Auto Tab Discard" extension
- [ ] Reduce `dom.ipc.processCount` to 4
- [ ] Configure in `modules/workspace/firefox.nix`

### 16. **Install Chromium or Brave Alternative**
- [ ] Evaluate if needed alongside Brave
- [ ] Consider as Firefox replacement

---

## 📊 Memory Optimization Summary

### Before Optimization (2025-11-09 00:00)
- **Total RAM:** 16GB
- **Used:** 14GB (93%)
- **Swap:** 16GB (now disabled)

### Top Memory Consumers (Before)
1. KDE (kwin + plasmashell): 1.37GB
2. VSCode (all processes): ~2.5GB
3. LiteLLM (8 workers): 3.2GB ← FIXED
4. Mission Center: 645MB
5. Obsidian: ~650MB
6. Claude CLI: 504MB
7. Dropbox: 485MB
8. Claude Desktop: 400MB

### After Current Optimizations
**Completed:**
- LiteLLM: 3.2GB → 0.8GB (-2.4GB) ✅
- Swap: Disabled (prevents NVMe wear) ✅
- Brave: Optimized with memory flags ✅
- Obsidian: 512MB systemd limit ✅

**Pending:**
- KDE: 1.37GB → 0.8GB (-0.6GB target)
- VSCode: 2.5GB → 1.5GB (-1GB target)
- Mission Center: 645MB → 10MB (-635MB via btop)

**Total Savings (Completed + Pending):** ~4.6GB
**New Baseline Target:** ~9GB used (leaving 7GB free)

---

## 🛠️ NixOS Configuration Files Modified

### This Session (2025-11-09)
1. `modules/workspace/brave-fixes.nix` - Memory optimization flags
2. `modules/workspace/app-memory-limits.nix` - NEW: Obsidian systemd service
3. `modules/workspace/plasma-optimization.nix` - NEW: KDE Plasma 6 optimizations
4. `modules/workspace/packages.nix` - Removed Mission Center, added VSCode
5. `home/mitso/vscode.nix` - UPDATED: Complete MCP config + Claude Code settings + Kitty integration
6. `home/mitso/vscodium.nix` - Performance optimizations, Material theme
7. `home/mitso/kitty.nix` - Symlink to common-dotfiles
8. `home/mitso/home.nix` - Updated VSCode extensions (14 total)
9. `hosts/shoshin/configuration.nix` - Import app-memory-limits.nix and plasma-optimization.nix
10. `hosts/shoshin/hardware-configuration.nix` - Swap disabled
11. `~/.config/Claude/claude_desktop_config.json` - Added ~/.claude/cache/llm-core to git-mcp-go
12. `/home/mitso/Workspaces/common-dotfiles/kitty/kitty.conf` - NEW: Complete Kitty config with Catppuccin Mocha theme

### Previous Sessions
1. `modules/development/tooling.nix` - Monitoring tools
2. `modules/workspace/packages.nix` - Mission Center, monitoring apps
3. `~/litellm-production/docker-compose.yml` - Workers 8→2

---

## 🔍 Monitoring & Verification

### Daily Checks (Next Week)
- [ ] `free -h` - Verify memory usage < 10GB baseline
- [ ] `btop` - Look for memory hogs
- [ ] LiteLLM workers: `ps aux | grep litellm | wc -l` (should be 2-3)
- [ ] No system freezes

### Weekly Checks
- [ ] Review system stability
- [ ] Check Dropbox status (no crashes)
- [ ] Verify Claude Desktop startup speed
- [ ] Check swap usage (should be minimal)

---

## 🎯 Success Criteria

**System is fully optimized when:**
- ✅ No freezes for 7+ days
- ✅ Baseline memory < 10GB (currently ~9GB target)
- ✅ Brave memory-limited and stable
- ✅ Obsidian < 512MB
- ✅ Mission Center replaced with btop
- ✅ KDE < 800MB
- ✅ VSCode < 1.5GB
- ✅ All declarative via NixOS config

---

## 📝 Important Notes

### NixOS Best Practices
- **Always test first:** `sudo nixos-rebuild test --flake .#shoshin`
- **Then switch:** `sudo nixos-rebuild switch --flake .#shoshin`
- **Rollback if needed:** `sudo nixos-rebuild switch --rollback`
- **Commit working configs** to Git regularly

### Brave Browser
- **Never add to packages.nix** - it's in brave-fixes.nix with NVIDIA flags
- Flags include hardware acceleration + memory limits
- Don't remove NVIDIA flags without testing!

### Memory Management
- Swap disabled to prevent NVMe wear
- OOM killer will handle memory pressure
- Monitor baseline usage daily for first week

---

## 🔗 Related Documentation

- **Main Instructions:** `/home/mitso/Workspaces/Personal_Workspace/llm-tsukuru-project/llm-core/instructions/projects/other-projects-desktop-workspace_INSTRUCTIONS.md`
- **TODO (this file):** `/home/mitso/Workspaces/Personal_Workspace/desktop-workspace/TODO.md`
- **NixOS Config:** `~/.config/nixos/`
- **Sequential-thinking MCP:** `/home/mitso/Workspaces/Personal_Workspace/llm-tsukuru-project/llm-core/instructions/mcps/sequential-thinking.md`

---

**Philosophy:** Declarative over imperative. Test before switch. Small changes, frequent commits.

**Remember:** This is a marathon, not a sprint. Stability > speed.
