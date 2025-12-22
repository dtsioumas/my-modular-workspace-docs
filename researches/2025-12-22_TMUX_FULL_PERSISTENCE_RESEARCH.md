# Tmux Full Persistence Configuration Research

**Date:** 2025-12-22
**Author:** Dimitris Tsioumas (Mitsio)
**Purpose:** Complete guide for tmux-resurrect + tmux-continuum configuration on NixOS/Home-Manager

---

## Executive Summary

This research provides a complete configuration guide for achieving full tmux session persistence across reboots on NixOS using Home-Manager. The solution combines **tmux-resurrect** (manual save/restore) and **tmux-continuum** (automatic save/restore) plugins.

**Key Findings:**
- ✅ Full persistence IS possible with tmux-resurrect + continuum
- ✅ Native NixOS/Home-Manager support available
- ✅ Process restoration supported for specific programs
- ⚠️ Plugin ordering is CRITICAL (themes must come BEFORE resurrect/continuum)
- ❌ NOT all processes can be restored (shell state, SSH connections are lost)

---

## 1. What Can and Cannot Be Restored

### ✅ What IS Restored

| Component | Detail | Restoration Quality |
|-----------|--------|---------------------|
| **Sessions** | All session names and structure | 100% |
| **Windows** | All windows, names, and order | 100% |
| **Panes** | All pane splits and exact layouts | 100% |
| **Working Directories** | cwd for each pane | 100% |
| **Active/Alternative** | Active session, window, pane | 100% |
| **Grouped Sessions** | Multi-monitor session groups | 100% |
| **Window Focus** | Which windows have focus | 100% |
| **Zoomed Panes** | Exact zoom state | 100% |

### 🔧 What CAN Be Restored (with configuration)

| Program | Configuration Required | Notes |
|---------|----------------------|-------|
| **vim/nvim** | `@resurrect-strategy-nvim 'session'` | Requires vim session support |
| **htop** | Add to `@resurrect-processes` | Restored with same options |
| **ssh** | Add to `@resurrect-processes` | Reconnects (NOT resuming session) |
| **Node.js tools** | Use yarn wrapper (see NodeJS section) | npm/gulp/grunt need workarounds |
| **Custom programs** | Add to `@resurrect-processes` | See Process Restoration section |

### ❌ What CANNOT Be Restored

| Component | Reason | Workaround |
|-----------|--------|-----------|
| **Shell history** | Not captured by tmux | Use shell history persistence (zsh/bash) |
| **Environment variables** | Process-specific state | Re-export in shell rc files |
| **SSH session state** | Connection lost on reboot | Reconnect manually or script it |
| **Running command output** | Dynamic data | Use pane content capture (optional) |
| **Sudo sessions** | Security limitation | Re-authenticate after restore |

---

## 2. Core Plugins: tmux-resurrect + tmux-continuum

### tmux-resurrect (Manual Save/Restore)

**GitHub:** https://github.com/tmux-plugins/tmux-resurrect
**Stars:** 12.3k
**License:** MIT
**Last Update:** Active (2025)

**Features:**
- Manual save with `prefix + Ctrl-s`
- Manual restore with `prefix + Ctrl-r`
- Saves to `~/.tmux/resurrect/` by default
- Conservative process restoration (safe by default)

**Key Bindings:**
```bash
prefix + Ctrl-s  # Save current tmux environment
prefix + Ctrl-r  # Restore saved environment
```

### tmux-continuum (Automatic Save/Restore)

**GitHub:** https://github.com/tmux-plugins/tmux-continuum
**Stars:** 3.7k
**License:** MIT
**Dependency:** Requires tmux-resurrect

**Features:**
- Auto-save every 15 minutes (configurable)
- Auto-restore on tmux start
- Optional: Auto-start tmux on boot
- Background operation (no workflow interruption)

**Auto-save Interval:**
```bash
set -g @continuum-save-interval '15'  # Minutes (default: 15)
set -g @continuum-save-interval '0'   # Disable auto-save
```

**Auto-restore:**
```bash
set -g @continuum-restore 'on'   # Enable auto-restore on tmux start
set -g @continuum-restore 'off'  # Disable (default)
```

---

## 3. NixOS/Home-Manager Configuration

### 3.1 Complete Home-Manager Example

```nix
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;

    # CRITICAL: Plugin ordering matters!
    # Themes MUST come BEFORE resurrect/continuum
    plugins = with pkgs; [
      # 1. Theme plugins FIRST
      # (Example: tmuxPlugins.dracula or custom theme)

      # 2. Session persistence plugins AFTER themes
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          # Save vim/neovim sessions
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-strategy-vim 'session'

          # Capture pane contents (optional, increases file size)
          set -g @resurrect-capture-pane-contents 'on'

          # Restore additional programs
          set -g @resurrect-processes 'ssh psql mysql sqlite3 "~rails server" "~yarn watch"'

          # Custom save directory (optional)
          # set -g @resurrect-dir '~/.tmux/resurrect'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          # Auto-restore on tmux start
          set -g @continuum-restore 'on'

          # Auto-save interval (minutes)
          set -g @continuum-save-interval '10'

          # Display continuum status in status bar (optional)
          # set -g status-right 'Continuum: #{continuum_status}'
        '';
      }
    ];

    extraConfig = ''
      # Basic tmux settings
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1

      # Status bar (IMPORTANT: keep status-right if using continuum status)
      set -g status-position bottom
      set -g status-interval 5

      # CRITICAL: Continuum requires status line to be 'on'
      set -g status on
    '';
  };
}
```

### 3.2 Minimal Configuration (Quick Start)

```nix
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];
  };
}
```

---

## 4. Process Restoration Configuration

### 4.1 Default Restored Programs

Only these programs are restored by default (conservative list):
```
vi vim nvim emacs man less more tail top htop irssi weechat mutt
```

### 4.2 Adding Custom Programs

**Basic syntax:**
```nix
set -g @resurrect-processes 'ssh psql mysql sqlite3'
```

**Programs with arguments (use double quotes):**
```nix
set -g @resurrect-processes 'some_program "git log"'
```

**Fuzzy matching with tilde (~):**
```nix
# Matches any process containing "rails server" anywhere in command
set -g @resurrect-processes '"~rails server" "~rails console"'
```

**Custom restore command (arrow →):**
```nix
# When restoring, use "rails server" instead of full path
set -g @resurrect-processes '"~rails server->rails server"'
```

**Preserve arguments (asterisk *):**
```nix
# Restore with original arguments (e.g., rails server --verbose)
set -g @resurrect-processes '"~rails server->rails server *"'
```

**Restore ALL programs (DANGEROUS!):**
```nix
set -g @resurrect-processes ':all:'
```

⚠️ **WARNING:** `:all:` can be dangerous. A command like `sudo mkfs.vfat /dev/sdb` that was formatting a USB stick could wipe your backup drive if devices change after reboot.

### 4.3 NodeJS Programs (npm, gulp, yarn)

**Problem:** npm/gulp/grunt don't preserve arguments in `ps` output.

**Solution:** Use `yarn` wrapper:

```nix
# Instead of:
# set -g @resurrect-processes '"~npm run watch"'  # WON'T WORK

# Use yarn:
set -g @resurrect-processes '"~yarn watch"'       # WORKS
set -g @resurrect-processes '"~yarn gulp test"'   # WORKS
```

**With nvm:**
```nix
set -g @resurrect-processes '"~yarn gulp test->nvm use && gulp test"'
```

### 4.4 SSH Connections

```nix
set -g @resurrect-processes 'ssh mosh-client'
```

**Note:** This reconnects SSH, but does NOT resume the remote session state.

---

## 5. Advanced Features

### 5.1 Vim/Neovim Session Restoration

**Requirements:**
- vim-obsession plugin OR native vim session support
- Session file created before tmux save

**Configuration:**
```nix
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-strategy-vim 'session'
```

**How it works:**
1. Create vim session: `:mksession`
2. Save tmux: `prefix + Ctrl-s`
3. Restore tmux: `prefix + Ctrl-r`
4. Vim reopens with session restored

**Resources:**
- https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_vim_and_neovim_sessions.md

### 5.2 Pane Content Restoration

**Warning:** Significantly increases save file size.

```nix
set -g @resurrect-capture-pane-contents 'on'
```

**What it does:**
- Saves scrollback buffer content
- Restores visible pane content after restore
- Useful for preserving command output

**Limitations:**
- Does NOT restore shell history
- Does NOT restore interactive program state
- Large scrollback = large save files

**Resources:**
- https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_pane_contents.md

### 5.3 Custom Save Directory

```nix
set -g @resurrect-dir '$HOME/.config/tmux/resurrect'
```

**Default:** `~/.tmux/resurrect/`

**Use cases:**
- Sync save files across machines (Syncthing, Google Drive)
- Separate backups for different machines
- Custom backup strategies

### 5.4 Save/Restore Hooks

```nix
# Before save
set -g @resurrect-hook-pre-save-all 'echo "Saving tmux env..."'

# After save
set -g @resurrect-hook-post-save-all 'echo "Save complete"'

# Before restore
set -g @resurrect-hook-pre-restore-all 'echo "Restoring tmux env..."'

# After restore
set -g @resurrect-hook-post-restore-all 'echo "Restore complete"'
```

**Use cases:**
- Trigger backup scripts
- Send notifications
- Clean up temp files
- Log save/restore events

**Resources:**
- https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/hooks.md

---

## 6. Boot-Time Auto-Start (Optional)

### 6.1 Systemd User Service

**Enable tmux-continuum auto-start:**
```nix
set -g @continuum-boot 'on'
```

**Custom systemd service (alternative):**
```nix
# home.nix
systemd.user.services.tmux = {
  Unit = {
    Description = "Tmux server";
    After = [ "graphical-session-pre.target" ];
    PartOf = [ "graphical-session.target" ];
  };

  Service = {
    Type = "forking";
    ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s main";
    ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
    RestartSec = 2;
  };

  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
```

**Resources:**
- https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/automatic_start.md

---

## 7. Critical Configuration Issues

### 7.1 Plugin Ordering (CRITICAL)

**ISSUE:** If themes overwrite `status-right`, continuum auto-save breaks.

**SOLUTION:** Place tmux-continuum LAST in plugin list:

```nix
plugins = with pkgs; [
  # 1. Themes first
  tmuxPlugins.dracula  # or any theme

  # 2. Other plugins
  tmuxPlugins.yank
  tmuxPlugins.copycat

  # 3. Resurrect/Continuum LAST
  tmuxPlugins.resurrect
  tmuxPlugins.continuum  # MUST BE LAST
];
```

**Why:** Continuum hooks into `status-right` for periodic saves. Themes often overwrite this variable.

**Source:** https://github.com/tmux-plugins/tmux-continuum#known-issues

### 7.2 Status Line Requirement

**ISSUE:** Continuum requires `status on` to function.

```nix
# REQUIRED for continuum
set -g status on
```

**If status line is hidden:**
```nix
# Alternative: Use resurrect manually only
# Remove tmux-continuum plugin
# Use: prefix + Ctrl-s to save manually
```

### 7.3 NixOS Path Issues

**ISSUE:** NixOS programs have long /nix/store paths that don't match restore patterns.

**Example problem:**
```bash
# Saved process:
/nix/store/xxx-neovim-unwrapped-0.2.2/bin/nvim --cmd let g:python_host_prog=...

# Restore pattern:
set -g @resurrect-processes '~nvim->nvim'  # May not match
```

**SOLUTION:** Use fuzzy matching with tilde (~):
```nix
set -g @resurrect-processes '"~nvim->nvim"'
```

**Debugging:**
1. Check `~/.tmux/resurrect/last` file
2. Find the full command path
3. Use `~` to match partial command string

**Resources:**
- https://github.com/tmux-plugins/tmux-resurrect/issues/247

---

## 8. Testing and Verification

### 8.1 Manual Testing Workflow

**1. Setup test session:**
```bash
tmux new-session -s test
# Create windows and panes
# Start some programs (nvim, htop, etc.)
```

**2. Save manually:**
```bash
# Press: prefix + Ctrl-s
# Verify: "Tmux environment saved!" message appears
```

**3. Check save file:**
```bash
cat ~/.tmux/resurrect/last
# Verify your sessions, windows, panes are listed
```

**4. Kill tmux:**
```bash
tmux kill-server
```

**5. Restore:**
```bash
tmux
# If auto-restore on: environment restores automatically
# If manual: press prefix + Ctrl-r
```

**6. Verify:**
- All sessions present
- All windows present
- All panes present
- Working directories correct
- Programs running (if configured)

### 8.2 Auto-Save Testing

**Check continuum status:**
```bash
# Add to status bar:
set -g status-right 'Continuum: #{continuum_status}'
```

**Status values:**
- `on` - Auto-save enabled
- `off` - Auto-save disabled
- Number - Minutes until next save

**Force save:**
```bash
# Wait 15 minutes OR
# Press: prefix + Ctrl-s (manual save)
```

### 8.3 Process Restoration Testing

**1. Start program:**
```bash
nvim myfile.txt
```

**2. Save:**
```bash
# Press: prefix + Ctrl-s
```

**3. Check save file:**
```bash
grep nvim ~/.tmux/resurrect/last
# Should show nvim command
```

**4. Restore and verify:**
```bash
tmux kill-server
tmux
# Check if nvim restarted with myfile.txt
```

---

## 9. Limitations and Workarounds

### 9.1 What You Lose on Reboot

| Lost Item | Impact | Workaround |
|-----------|--------|-----------|
| **Shell history** | Recent commands not in history file | Use `HISTFILE` and `HISTSIZE` properly |
| **Env variables** | Exported vars lost | Re-export in `.bashrc`/`.zshrc` |
| **SSH sessions** | Connections closed | Use `ssh -t host tmux attach` pattern |
| **Sudo tickets** | Re-auth required | Script sudo commands |
| **Background jobs** | Jobs terminated | Use systemd services instead |

### 9.2 Large Save Files

**Problem:** With pane contents enabled, save files can be >10MB.

**Solutions:**
1. **Disable pane contents:**
   ```nix
   # Don't set @resurrect-capture-pane-contents
   ```

2. **Reduce scrollback:**
   ```nix
   set -g history-limit 5000  # Default: 2000
   ```

3. **Selective pane capture:**
   Currently not possible - it's all or nothing.

### 9.3 Slow Restore Performance

**Problem:** Restoring 50+ panes takes 10-30 seconds.

**Solutions:**
1. **Reduce sessions/windows/panes**
2. **Use tmux layouts instead** (scripted session creation)
3. **Split environments** (work session, dev session, etc.)

---

## 10. Alternative Approaches

### 10.1 Tmuxinator (Session Scripting)

**GitHub:** https://github.com/tmuxinator/tmuxinator

**Pros:**
- Declarative YAML config
- Fast session creation
- Version-controlled layouts

**Cons:**
- Manual configuration required
- Doesn't preserve running state
- Ruby dependency

**When to use:**
- Consistent development environments
- Project-specific layouts
- Team-shared configs

### 10.2 Custom Bash Scripts

**Example:**
```bash
#!/bin/bash
SESSIONNAME="dev"
tmux has-session -t $SESSIONNAME &> /dev/null

if [ $? != 0 ]; then
    tmux new-session -s $SESSIONNAME -n editor -d
    tmux send-keys -t $SESSIONNAME "nvim ." C-m
    tmux split-window -h -t $SESSIONNAME
    tmux send-keys -t $SESSIONNAME "npm run dev" C-m
fi

tmux attach -t $SESSIONNAME
```

**Pros:**
- Simple and flexible
- No dependencies
- Easy to understand

**Cons:**
- Manual scripting
- Doesn't preserve state
- Requires maintenance

---

## 11. Recommended Configuration

### 11.1 For SRE/DevOps Work (User Mitsio's Use Case)

```nix
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;
    prefix = "C-a";
    mouse = true;

    plugins = with pkgs; [
      # 1. Resurrect for manual control
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          # Restore neovim sessions
          set -g @resurrect-strategy-nvim 'session'

          # Restore SSH connections (will reconnect, not resume)
          set -g @resurrect-processes 'ssh "~kubectl" "~k9s" "~htop"'

          # Capture pane contents (optional - increases save size)
          # set -g @resurrect-capture-pane-contents 'on'
        '';
      }

      # 2. Continuum for auto-save (conservative interval)
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          # Auto-restore on tmux start
          set -g @continuum-restore 'on'

          # Auto-save every 10 minutes
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      # Status line (required for continuum)
      set -g status on
      set -g status-position bottom
      set -g status-interval 5

      # Base settings
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
```

### 11.2 For Remote SSH Workflow

```nix
{
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          # For remote servers - restore connections
          set -g @resurrect-processes 'ssh "~kubectl" "~k9s"'
        '';
      }
      # Note: Consider NOT using continuum on remote servers
      # Manual save gives you more control
    ];
  };

  # SSH config for auto-attach
  programs.ssh.matchBlocks = {
    "prod-tmux" = {
      hostname = "production.example.com";
      user = "admin";
      extraOptions = {
        RequestTTY = "yes";
        RemoteCommand = "tmux new-session -A -s prod";
      };
    };
  };
}
```

---

## 12. Resources and Documentation

### Official Documentation
- **tmux-resurrect GitHub:** https://github.com/tmux-plugins/tmux-resurrect
- **tmux-continuum GitHub:** https://github.com/tmux-plugins/tmux-continuum
- **Restoring Programs Doc:** https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_programs.md
- **Vim/Neovim Sessions:** https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_vim_and_neovim_sessions.md
- **Pane Contents:** https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_pane_contents.md
- **Hooks:** https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/hooks.md

### NixOS Resources
- **Home-Manager tmux options:** https://mynixos.com/home-manager/option/programs.tmux
- **NixOS tmux plugins:** https://mynixos.com/nixpkgs/package/tmuxPlugins.resurrect
- **Blog: Setting Up Tmux With Nix Home Manager:** https://haseebmajid.dev/posts/2023-07-10-setting-up-tmux-with-nix-home-manager

### Community Examples
- **NixOS tmux config example:** https://git.peppe.rs/config/nixos/tree/programs/tmux.nix
- **GitHub Issue - NixOS paths:** https://github.com/tmux-plugins/tmux-resurrect/issues/247

### Related Tools
- **Tmuxinator:** https://github.com/tmuxinator/tmuxinator
- **Teamocil:** https://github.com/remiprev/teamocil
- **tmux-session script:** https://github.com/mislav/dotfiles/blob/master/bin/tmux-session

---

## 13. Troubleshooting

### Issue: Resurrect not saving/restoring

**Check:**
1. Plugin loaded: `tmux show-option -g @plugin`
2. Save file exists: `ls -la ~/.tmux/resurrect/last`
3. Bindings work: `tmux list-keys | grep resurrect`

**Solution:**
```bash
# Reload tmux config
tmux source-file ~/.config/tmux/tmux.conf

# Or restart tmux
tmux kill-server && tmux
```

### Issue: Continuum not auto-saving

**Check:**
1. Status line enabled: `tmux show-option -g status`
2. Continuum in status-right: `tmux show-option -g status-right`
3. Theme plugin order (theme before continuum)

**Solution:**
```nix
# Ensure status is on
set -g status on

# Check continuum status
set -g status-right 'Continuum: #{continuum_status}'
```

### Issue: Programs not restoring

**Check:**
1. Program in resurrect-processes: `tmux show-option -g @resurrect-processes`
2. Full command in save file: `grep <program> ~/.tmux/resurrect/last`
3. Fuzzy match with `~` if needed

**Solution:**
```nix
# Add debug to see saved command
cat ~/.tmux/resurrect/last | grep pane

# Then configure with ~ and -> as needed
set -g @resurrect-processes '"~program_name->program_name"'
```

---

## Conclusion

**Recommended Setup for NixOS/Home-Manager:**

1. ✅ Use **tmux-resurrect** for manual save/restore control
2. ✅ Add **tmux-continuum** for auto-save (10-15 min interval)
3. ✅ Enable auto-restore: `set -g @continuum-restore 'on'`
4. ⚠️ Be conservative with process restoration (start minimal, expand as needed)
5. ✅ Keep plugin order: themes → resurrect → continuum (last)
6. 🧪 Test thoroughly before relying on auto-restore

**What You Get:**
- Sessions survive reboots
- Layouts perfectly preserved
- Working directories restored
- Selected programs restarted
- Zero manual intervention (with auto-restore)

**What You Don't Get:**
- Active shell state
- SSH session state
- Environment variables
- Sudo tickets
- Background job state

**Best Practice:**
- Use resurrect/continuum for tmux structure
- Use shell rc files for environment
- Use systemd services for critical background jobs
- Use ssh-agent for key management

---

**Research Complete:** 2025-12-22
**Next Steps:** Implement in home-manager configuration per Phase K.14 of Kitty Enhancements Plan
