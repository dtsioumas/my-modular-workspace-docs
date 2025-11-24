# TODO: rclone bisync, Backup & Syncthing Migration

**Session Date:** 2025-11-17
**Project:** my-modular-workspace
**Workspace:** shoshin

---


### Syncthing Setup

- [ ] Create Syncthing NixOS module
  - [ ] Create `modules/workspace/syncthing-myspaces.nix`
  - [ ] Configure user and dataDir
  - [ ] Open firewall ports (8384, 22000, 21027)
  - [ ] Setup device configuration (Android)
  - [ ] Setup folder: MySpaces
  - [ ] Add versioning strategy
  - **Priority:** 🟡 MEDIUM

- [ ] Configure Android Syncthing
  - [ ] Install Syncthing on Android
  - [ ] Get device ID
  - [ ] Add device ID to NixOS config
  - [ ] Pair devices
  - [ ] Test sync
  - **Priority:** 🟡 MEDIUM

- [ ] Test Syncthing sync
  - [ ] Create test file on desktop
  - [ ] Verify appears on Android
  - [ ] Create test file on Android
  - [ ] Verify appears on desktop
  - [ ] Test conflict resolution
  - **Priority:** 🟡 MEDIUM

---

### Testing & Verification Custom Integration gdrive-rclone-syncthing

- [ ] Test rclone bisync
  - [ ] Manual sync test
  - [ ] Timer trigger test
  - [ ] Conflict resolution test
  - [ ] Performance check
  - **Priority:** 🔴 HIGH

- [ ] Test Syncthing
  - [ ] Real-time sync test
  - [ ] Large file test
  - [ ] Conflict test
  - [ ] Battery impact check (Android)
  - **Priority:** 🟡 MEDIUM

- [ ] Test NixOS rebuild
  - [ ] Test rebuild from new location
  - [ ] Test all modules load
  - [ ] Test services start
  - [ ] Test KDE Connect pairing
  - **Priority:** 🔴 CRITICAL

- [ ] Test symlinks
  - [ ] Verify all symlinks resolve
  - [ ] Test file editing through symlinks
  - [ ] Test Git operations through symlinks
  - **Priority:** 🟡 MEDIUM

---

## 🚨 CRITICAL NOTES

### Before ANY Move Operations:
1. ✅ Git commit current state
2. ✅ Full home backup to external disk
3. ✅ Verify backup integrity
4. ✅ Test restore process
5. ✅ Have recovery plan ready

### After ANY Config Changes:
1. Test with `nixos-rebuild test` first
2. Check logs: `journalctl -xe`
3. Keep old config for 1 week
4. Document any issues


---

## 📝 Notes & Learnings

### Issues Encountered:
1. **Git corruption:** Fixed by re-initializing repo
   - Cause: Failed move operations
   - Solution: `git init` + commit recovery
   - Prevention: Always commit before operations

### Important Paths:
- Project: `~/.MyHome/MySpaces/my-modular-workspace/`
- NixOS config: `~/.MyHome/MySpaces/my-modular-workspace/hosts/shoshin/nixos/`
- Sessions: `my-modular-workspace-/sessions/`

---

**Last Updated:** 2025-11-17 23:59 UTC  
**Next Review:** After Phase 1 completion
