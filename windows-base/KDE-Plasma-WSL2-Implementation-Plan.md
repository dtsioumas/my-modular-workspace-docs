# KDE Plasma on WSL2 - Implementation Plan
**System:** laptop-system01 (Windows Domain: dioklint.ATH)  
**Date:** November 18, 2025  
**Objective:** Integrate KDE Plasma as the primary graphical environment on Windows via WSL2

---

## Executive Summary

After extensive research of current (2024-2025) documentation, three viable approaches exist for running KDE Plasma on WSL2:

1. **XRDP Method** (⭐ RECOMMENDED) - Simplest, most reliable
2. **X Server Method** (VcXsrv/X410) - Traditional, flexible
3. **WSLg Method** - Native but requires extensive workarounds

**Recommendation:** Use the **XRDP method** as it provides the best balance of simplicity, performance, and compatibility with modern WSL2 features (native systemd support, localhost connectivity, integrated audio).

---

## Method Comparison

### 1. XRDP Method ⭐ RECOMMENDED

**Advantages:**
- ✅ Simplest setup (2-3 commands)
- ✅ Uses Windows built-in RDP client
- ✅ Works with localhost (no IP address lookup needed)
- ✅ Native systemd support
- ✅ Audio support via xrdp-pulseaudio
- ✅ Most stable as of 2024-2025
- ✅ Easy to automate startup

**Disadvantages:**
- ⚠️ Login screen is not as polished as native
- ⚠️ Slight latency for graphics-intensive tasks
- ⚠️ Some users report occasional login delays

**Setup Time:** ~15-30 minutes

**Use Case:** Best for general development work, daily Linux desktop usage, stable performance

---

### 2. X Server Method (VcXsrv/X410)

**Advantages:**
- ✅ More flexible configuration
- ✅ Can run in multi-window or desktop mode
- ✅ Better for multi-monitor setups
- ✅ X410 supports VSOCK (faster than TCP)
- ✅ Can span multiple monitors

**Disadvantages:**
- ⚠️ Requires external software (VcXsrv free, X410 paid)
- ⚠️ Manual DISPLAY variable configuration
- ⚠️ Firewall rules needed
- ⚠️ Audio requires separate PulseAudio setup
- ⚠️ More complex troubleshooting
- ⚠️ VcXsrv reported to crash with some apps (GIMP, LibreOffice)

**Setup Time:** ~45-90 minutes

**Use Case:** Best for advanced users, multi-monitor requirements, specific X11 needs

---

### 3. WSLg Method

**Advantages:**
- ✅ Native Microsoft solution
- ✅ No external software needed
- ✅ GPU acceleration support
- ✅ Integrated audio
- ✅ Clipboard integration

**Disadvantages:**
- ⚠️ **NOT designed for full desktop environments**
- ⚠️ Requires extensive hacks (Xorg diversion script)
- ⚠️ Limited multi-monitor support
- ⚠️ More likely to break with Windows updates
- ⚠️ Keyboard shortcuts conflict with Windows
- ⚠️ Complex troubleshooting

**Setup Time:** ~2-4 hours

**Use Case:** Best for individual GUI apps, not recommended for full desktop takeover

---

## Recommended Implementation: XRDP Method

### Prerequisites Checklist

- [ ] Windows 10 (build 19041+) or Windows 11
- [ ] WSL2 installed and updated (`wsl --version`)
- [ ] Ubuntu 22.04 or 24.04 LTS (recommended)
- [ ] At least 8GB RAM (16GB+ recommended)
- [ ] Native systemd support enabled
- [ ] 20GB+ free disk space for WSL

### Phase 1: WSL2 Setup (Day 1 - Morning)

**Estimated Time:** 30 minutes

1. **Verify WSL2 Installation**
   ```powershell
   wsl --version
   wsl --status
   wsl -l -v
   ```

2. **Install/Update Ubuntu**
   - Use Ubuntu 24.04 LTS for latest features
   - Alternative: Ubuntu 22.04 LTS for stability

3. **Enable Native Systemd**
   - Edit `/etc/wsl.conf`
   - Add systemd configuration
   - Restart WSL

4. **Update System Packages**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

### Phase 2: KDE Plasma Installation (Day 1 - Afternoon)

**Estimated Time:** 45 minutes (including downloads)

**CRITICAL:** Install `kde-plasma-desktop` NOT `kubuntu-desktop`

**Reason:** kubuntu-desktop tries to access hardware (ACPI, GPU drivers) not available in WSL2, causing crashes and instability.

1. **Install Core KDE Plasma**
   ```bash
   sudo apt install kde-plasma-desktop dbus-x11 -y
   ```

2. **Install Additional KDE Apps** (Optional)
   ```bash
   sudo apt install konsole dolphin kate firefox-esr -y
   ```

3. **Install XRDP**
   ```bash
   sudo apt install xrdp -y
   ```

4. **Configure XRDP for KDE**
   - Create/edit `~/.xsession`
   - Set KDE environment variables
   - Configure xrdp.ini for better performance

---

### Phase 3: XRDP Configuration & Optimization (Day 1 - Evening)

**Estimated Time:** 30 minutes

1. **Configure ~/.xsession**
   ```bash
   echo "/usr/bin/startplasma-x11" > ~/.xsession
   ```

2. **Configure KDE Environment Variables**
   ```bash
   # Add to ~/.xsession or /etc/xrdp/startwm.sh
   export XDG_SESSION_DESKTOP=KDE
   export XDG_DATA_DIRS=/usr/share/plasma:/usr/local/share:/usr/share
   export XDG_CONFIG_DIRS=/etc/xdg
   ```

3. **Optimize XRDP Settings**
   ```bash
   sudo nano /etc/xrdp/xrdp.ini
   # Change:
   # max_bpp=32 → max_bpp=128
   # xserverbpp=24 → xserverbpp=128
   ```

4. **Configure Audio** (Optional)
   ```bash
   sudo apt install xrdp-pulseaudio-installer -y
   cd /tmp
   sudo apt install git -y
   git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
   cd pulseaudio-module-xrdp
   ./bootstrap && ./configure && make
   sudo make install
   ```

5. **Remove Screensaver** (CRITICAL - prevents login issues)
   ```bash
   sudo apt purge xscreensaver gnome-screensaver light-locker i3lock -y
   ```

---

### Phase 4: Service Management & Startup (Day 2 - Morning)

**Estimated Time:** 45 minutes

1. **Enable D-Bus and XRDP Services**
   ```bash
   sudo systemctl enable dbus
   sudo systemctl enable xrdp
   ```

2. **Create Startup Script** (for manual start)
   ```bash
   nano ~/start-kde.sh
   ```
   
   Content:
   ```bash
   #!/bin/bash
   sudo /etc/init.d/dbus start
   sudo /etc/init.d/xrdp start
   echo "KDE Plasma ready at localhost:3389"
   echo "Connect via Windows RDP client (mstsc.exe)"
   ```

3. **Make Executable**
   ```bash
   chmod +x ~/start-kde.sh
   ```

4. **Create Windows Batch File** (for Windows startup)
   - Location: `C:\Users\dioklint.ATH\start-wsl-kde.bat`
   - Add to Windows Startup folder if desired

---

### Phase 5: Windows Integration (Day 2 - Afternoon)

**Estimated Time:** 30 minutes

1. **Configure .wslconfig** (Resource Allocation)
   ```ini
   # C:\Users\dioklint.ATH\.wslconfig
   [wsl2]
   memory=8GB
   processors=4
   swap=2GB
   localhostForwarding=true
   ```

2. **Create RDP Shortcut**
   - Save RDP connection to `localhost:3389`
   - Add to Desktop/Taskbar
   - Configure for automatic login (optional)

3. **Test Connection**
   - Open Windows RDP client (mstsc.exe)
   - Connect to localhost:3389
   - Login with WSL username/password

---

### Phase 6: Testing & Optimization (Day 2 - Evening)

**Estimated Time:** 1-2 hours

**Test Checklist:**
- [ ] RDP connection works
- [ ] KDE Plasma loads successfully
- [ ] Applications launch (Firefox, Dolphin, Konsole)
- [ ] Audio playback works
- [ ] Clipboard between Windows/Linux
- [ ] File access to /mnt/c/
- [ ] Multiple RDP sessions work
- [ ] System restart persistence

**Optimization Tasks:**
- [ ] Configure KDE appearance/themes
- [ ] Set up keyboard shortcuts
- [ ] Install additional applications
- [ ] Configure auto-hide Windows taskbar
- [ ] Set DPI scaling if needed (for HiDPI)
- [ ] Disable unnecessary KDE services
- [ ] Configure KWallet (if needed)

---

## Alternative: X410 Method (If XRDP Fails)

If XRDP proves problematic, X410 is a proven alternative:

1. **Install X410 from Microsoft Store**
2. **Configure DISPLAY variable in WSL**
3. **Launch X410 in Desktop mode**
4. **Start KDE via `startplasma-x11`**

**Note:** X410 costs ~$10 but provides better stability than free VcXsrv

---

## Troubleshooting Preparation

### Common Issues & Solutions

**Issue 1: Black screen after login**
- Solution: Check ~/.xsession permissions and content
- Solution: Verify KDE installation completed
- Solution: Check /var/log/xrdp-sesman.log

**Issue 2: Login fails immediately**
- Solution: Wait 5-10 seconds, services may still be starting
- Solution: Check that xrdp service is running
- Solution: Verify no conflicting X sessions

**Issue 3: No audio**
- Solution: Install xrdp-pulseaudio-installer
- Solution: Check PulseAudio configuration
- Solution: Restart xrdp service

**Issue 4: Poor performance**
- Solution: Increase .wslconfig memory allocation
- Solution: Optimize xrdp.ini settings (128-bit color depth)
- Solution: Disable desktop effects in KDE
- Solution: Use XRender instead of OpenGL compositor

**Issue 5: Keyboard shortcuts don't work**
- Solution: Windows captures some shortcuts - remap in KDE
- Solution: Use Windows+[Key] for Windows, configure KDE differently
- Solution: Consider using Alt+Space for KDE launcher

---

## Post-Implementation Tasks

### Week 1
- [ ] Monitor stability and performance
- [ ] Document any issues encountered
- [ ] Fine-tune KDE settings
- [ ] Install development tools needed
- [ ] Set up backup strategy

### Week 2
- [ ] Create snapshot/backup of WSL distro
  ```powershell
  wsl --export Ubuntu C:\WSL-Backups\Ubuntu-KDE-backup.tar
  ```
- [ ] Document custom configurations
- [ ] Test with real workload
- [ ] Optimize based on usage patterns

---

## Success Metrics

- ✅ KDE Plasma launches in < 30 seconds
- ✅ RDP connection stable for 8+ hour work sessions
- ✅ No crashes during normal development work
- ✅ Audio works for meetings/multimedia
- ✅ File operations feel responsive
- ✅ Can run development tools (IDEs, containers)
- ✅ Multi-tasking is smooth
- ✅ Clipboard integration works reliably

---

## Rollback Plan

If implementation fails or causes system issues:

1. **Disable auto-start scripts**
2. **Stop WSL services:**
   ```powershell
   wsl --shutdown
   ```
3. **Uninstall KDE (if needed):**
   ```bash
   sudo apt remove kde-plasma-desktop xrdp -y
   sudo apt autoremove -y
   ```
4. **Restore from backup:**
   ```powershell
   wsl --unregister Ubuntu
   wsl --import Ubuntu C:\WSL\Ubuntu C:\WSL-Backups\Ubuntu-KDE-backup.tar
   ```

---

## Resources & References

### Official Documentation
- [Microsoft: Systemd support in WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd)
- [Microsoft: WSL Basic Commands](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
- [KDE Plasma Documentation](https://userbase.kde.org/)

### Community Guides (2024-2025)
- GitHub: XRDP + KDE implementations
- X410 Cookbook: WSL2 Desktop Environments
- Reddit r/bashonubuntuonwindows

### Tools
- **XRDP:** Open-source RDP server
- **X410:** Premium X server ($9.99, Microsoft Store)
- **VcXsrv:** Free X server (less stable)
- **WSL Utilities:** Various helper scripts

---

## Timeline Summary

| Phase | Duration | Completion |
|-------|----------|-----------|
| Phase 1: WSL2 Setup | 30 min | Day 1 AM |
| Phase 2: KDE Installation | 45 min | Day 1 PM |
| Phase 3: XRDP Configuration | 30 min | Day 1 Eve |
| Phase 4: Service Management | 45 min | Day 2 AM |
| Phase 5: Windows Integration | 30 min | Day 2 PM |
| Phase 6: Testing & Optimization | 1-2 hrs | Day 2 Eve |
| **Total Estimated Time** | **4-5 hours** | **2 Days** |

---

## Next Steps

1. ✅ Review this implementation plan
2. ⬜ Backup current WSL installation
3. ⬜ Schedule implementation time block
4. ⬜ Proceed to detailed step-by-step guide
5. ⬜ Execute Phase 1

---

**Document Version:** 1.0  
**Last Updated:** November 18, 2025  
**Status:** Ready for Implementation
