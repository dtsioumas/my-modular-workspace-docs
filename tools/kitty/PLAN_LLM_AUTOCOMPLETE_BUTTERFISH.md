# Implementation Plan: LLM-Based Autocomplete with Butterfish

**Status:** 📋 Planning
**Created:** 2025-12-04
**Author:** Mitsio (with Claude Code)
**Workspace:** shoshin
**Goal:** Implement LLM-powered shell autocomplete using butterfish for context-aware AI suggestions

---

## Overview

This plan implements LLM-based autocomplete for bash in kitty terminal using **butterfish**. Butterfish provides:
- ✅ Context-aware AI suggestions (understands shell history and current command)
- ✅ GitHub Copilot-like experience for shell
- ✅ Goal mode for multi-step tasks (prefix with `!`)
- ✅ Tab-based autocomplete with AI suggestions
- ✅ Capital letter triggers AI prompt mode
- ✅ Compatible with OpenAI API and local models

**Architecture:** Two-layer approach per ADR-009
- **Layer 1 (home-manager):** Install butterfish (via go install if not in nixpkgs)
- **Layer 2 (chezmoi):** Configure butterfish via dotfiles + bash integration

**⚠️ SECURITY-FIRST APPROACH:**
This plan prioritizes API key security, privacy, and SRE concerns. Butterfish will send shell context to OpenAI API, so proper safeguards are critical.

---

## Prerequisites

✅ **Already satisfied:**
- bash is current shell
- kitty terminal with shell_integration enabled
- Go toolchain available (for installation)
- home-manager setup working
- chezmoi setup working
- ADR-009 documented

⚠️ **Required:**
- OpenAI API key (or compatible LLM provider)
- Secure key storage (KeePassXC or chezmoi age encryption)

---

## Phase 1: Package Installation (Home-Manager)

**Goal:** Install butterfish via home-manager
**Duration:** ~15 minutes
**Dependencies:** None

### Task 1.1: Check butterfish availability in nixpkgs

**Subtasks:**
1. Search nixpkgs for butterfish package
   ```bash
   nix search nixpkgs butterfish
   ```
2. If NOT in nixpkgs (likely case):
   - Proceed to Task 1.2 (go install method)
3. If IN nixpkgs (unlikely):
   - Skip to Task 1.3 (direct package installation)

**Expected outcome:** Determine installation method

---

### Task 1.2: Install butterfish via Go (if not in nixpkgs)

**File:** `home-manager/shell.nix`

**Subtasks:**
1. Add go toolchain to environment (if not already present)
   ```nix
   # home-manager/shell.nix
   { config, pkgs, ... }:
   {
     home.packages = with pkgs; [
       go  # Required for butterfish installation
     ];
   }
   ```

2. Create home-manager activation script to install butterfish
   ```nix
   # home-manager/shell.nix
   { config, pkgs, ... }:
   {
     home.activation.installButterfish = lib.hm.dag.entryAfter ["writeBoundary"] ''
       # Install butterfish via go install
       if ! command -v butterfish &> /dev/null; then
         $DRY_RUN_CMD ${pkgs.go}/bin/go install github.com/bakks/butterfish@latest
       fi
     '';
   }
   ```

3. Verify GOPATH and GOBIN are set correctly
   ```nix
   home.sessionVariables = {
     GOPATH = "${config.home.homeDirectory}/go";
     GOBIN = "${config.home.homeDirectory}/go/bin";
   };
   ```

4. Ensure `$GOBIN` is in PATH
   ```nix
   home.sessionPath = [
     "${config.home.homeDirectory}/go/bin"
   ];
   ```

**Expected outcome:** butterfish binary available at `~/go/bin/butterfish`

---

### Task 1.3: Apply home-manager changes

**Subtasks:**
1. Commit changes to home-manager repo
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
   git add shell.nix
   git commit -m "feat(shell): add butterfish LLM autocomplete via go install"
   ```

2. Apply home-manager configuration
   ```bash
   home-manager switch
   ```

3. Verify activation script ran successfully
   ```bash
   journalctl --user -u home-manager-$(whoami).service -n 50
   ```

**Expected outcome:** home-manager switch completes without errors

---

### Task 1.4: Verify butterfish installation

**Subtasks:**
1. Check butterfish is in PATH
   ```bash
   which butterfish
   # Expected: /home/mitsio/go/bin/butterfish
   ```

2. Check butterfish version
   ```bash
   butterfish --version
   ```

3. Test basic execution (will fail without API key, but should show help)
   ```bash
   butterfish --help
   ```

**Expected outcome:** butterfish command available and executable

---

## Phase 2: API Key Setup (Security-First)

**Goal:** Securely store and load OpenAI API key
**Duration:** ~25 minutes
**Dependencies:** Phase 1 complete

⚠️ **CRITICAL SECURITY REQUIREMENTS:**
- NEVER commit API key to git
- NEVER expose API key in bash history
- NEVER log API key in plain text
- Use systemd credentials or KeePassXC for secure storage

### Task 2.1: Choose API key storage method

**Options:**

**Option A: KeePassXC Integration (RECOMMENDED for SRE workflow)**
- Pros: Already using KeePassXC, systemd service pattern established
- Cons: Requires KeePassXC running and unlocked
- Best for: Interactive desktop use

**Option B: chezmoi age encryption**
- Pros: Portable across machines, doesn't require KeePassXC
- Cons: Key in filesystem (encrypted), more complex setup
- Best for: Server/headless environments

**Decision:**
For shoshin (desktop), use **Option A (KeePassXC)** per ADR-007 pattern.

---

### Task 2.2: Store API key in KeePassXC

**Subtasks:**
1. Open KeePassXC database
   ```bash
   keepassxc
   ```

2. Create new entry:
   - Title: `OpenAI API Key (butterfish)`
   - Username: `butterfish`
   - Password: `<your-openai-api-key>`
   - URL: `https://platform.openai.com/api-keys`
   - Notes: `Used by butterfish for LLM shell autocomplete`

3. Save and lock database

**Expected outcome:** API key stored securely in KeePassXC

---

### Task 2.3: Create systemd user service for API key loading

**File:** `home-manager/butterfish.nix` (NEW)

**Subtasks:**
1. Create new home-manager module
   ```nix
   # home-manager/butterfish.nix
   { config, pkgs, lib, ... }:
   {
     # Butterfish shell wrapper
     home.packages = [ ]; # Installed via activation script in shell.nix

     # Systemd service to load API key from KeePassXC
     systemd.user.services.butterfish-api-key = {
       Unit = {
         Description = "Load OpenAI API key for butterfish from KeePassXC";
         After = [ "graphical-session.target" ];
         PartOf = [ "graphical-session.target" ];
       };

       Service = {
         Type = "oneshot";
         RemainAfterExit = true;

         # Use secret-tool to retrieve key from KeePassXC
         ExecStart = pkgs.writeShellScript "load-butterfish-key" ''
           #!/usr/bin/env bash
           set -euo pipefail

           # Retrieve API key from KeePassXC via secret-tool
           API_KEY=$(${pkgs.libsecret}/bin/secret-tool lookup \
             application butterfish \
             account openai 2>/dev/null || true)

           if [[ -z "$API_KEY" ]]; then
             echo "WARNING: OpenAI API key not found in KeePassXC" >&2
             exit 0  # Don't fail, just log warning
           fi

           # Store in user-specific temp location (only readable by user)
           KEY_FILE="$XDG_RUNTIME_DIR/butterfish-api-key"
           echo "$API_KEY" > "$KEY_FILE"
           chmod 600 "$KEY_FILE"

           echo "Butterfish API key loaded successfully"
         '';

         ExecStop = pkgs.writeShellScript "unload-butterfish-key" ''
           #!/usr/bin/env bash
           KEY_FILE="$XDG_RUNTIME_DIR/butterfish-api-key"
           [[ -f "$KEY_FILE" ]] && rm -f "$KEY_FILE"
         '';
       };

       Install = {
         WantedBy = [ "graphical-session.target" ];
       };
     };
   }
   ```

2. Import module in `home-manager/home.nix`
   ```nix
   imports = [
     # ... other imports
     ./butterfish.nix
   ];
   ```

**Expected outcome:** Systemd service created for secure key loading

---

### Task 2.4: Store API key in KeePassXC secret service

**Subtasks:**
1. Use secret-tool to store the key (one-time setup)
   ```bash
   # This will prompt for the API key and store it in KeePassXC
   secret-tool store --label="OpenAI API Key (butterfish)" \
     application butterfish \
     account openai
   ```

2. Verify key retrieval works
   ```bash
   secret-tool lookup application butterfish account openai
   # Should output your API key
   ```

3. Apply home-manager changes
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
   git add butterfish.nix home.nix
   git commit -m "feat(butterfish): add systemd service for secure API key loading"
   home-manager switch
   ```

4. Start the service
   ```bash
   systemctl --user start butterfish-api-key.service
   ```

5. Verify service status
   ```bash
   systemctl --user status butterfish-api-key.service
   ```

6. Check key file was created
   ```bash
   ls -lh $XDG_RUNTIME_DIR/butterfish-api-key
   # Should show: -rw------- (only user readable)
   ```

**Expected outcome:** API key securely loaded into runtime directory

---

## Phase 3: Bash Integration (chezmoi)

**Goal:** Integrate butterfish wrapper into bash via chezmoi
**Duration:** ~20 minutes
**Dependencies:** Phase 1 & 2 complete

### Task 3.1: Add butterfish wrapper to .bashrc

**File:** `dotfiles/dot_bashrc.tmpl`

**Subtasks:**
1. Identify correct load order location
   - AFTER ble.sh (line ~170, after ble-attach)
   - AFTER atuin (line ~235)
   - BEFORE any custom functions that might use butterfish

2. Add butterfish wrapper initialization
   ```bash
   # dotfiles/dot_bashrc.tmpl (add at line ~240, after atuin)

   # ============================================
   # Butterfish - LLM-powered shell autocomplete
   # ============================================
   # Load butterfish if:
   # 1. butterfish binary exists
   # 2. API key is available
   # 3. Not in SSH session (privacy concern)
   {{ if (lookPath "butterfish") }}

   # Only load butterfish on local sessions, not SSH
   if [[ -z "$SSH_CONNECTION" ]] && [[ -z "$SSH_CLIENT" ]]; then
     # Check if API key is available
     BUTTERFISH_KEY_FILE="$XDG_RUNTIME_DIR/butterfish-api-key"

     if [[ -f "$BUTTERFISH_KEY_FILE" ]]; then
       # Load API key from secure location
       export OPENAI_API_KEY=$(cat "$BUTTERFISH_KEY_FILE")

       # Butterfish configuration
       export BUTTERFISH_MODEL="gpt-4"  # or gpt-3.5-turbo for cheaper
       export BUTTERFISH_TIMEOUT="10s"

       # Enable butterfish shell wrapper
       # This wraps bash to intercept commands
       eval "$(butterfish shell-init bash)"

       # Helpful aliases
       alias bf='butterfish'
       alias bfgoal='butterfish !'  # Goal mode shortcut

       # Show brief hint on first load (optional)
       if [[ ! -f "$HOME/.config/butterfish/.hint_shown" ]]; then
         echo "💡 Butterfish LLM autocomplete enabled:"
         echo "   - Capital letter + Tab = AI prompt"
         echo "   - Tab = AI autocomplete"
         echo "   - Prefix with ! for goal mode"
         mkdir -p "$HOME/.config/butterfish"
         touch "$HOME/.config/butterfish/.hint_shown"
       fi
     else
       # API key not available - butterfish disabled
       : # Silent fail - systemd service may not have run yet
     fi
   fi

   {{ end }}
   ```

**Expected outcome:** Butterfish loads conditionally and securely

---

### Task 3.2: Apply chezmoi changes

**Subtasks:**
1. Verify template syntax
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
   chezmoi execute-template < $(chezmoi source-path)/dot_bashrc.tmpl | tail -50
   ```

2. Review diff
   ```bash
   chezmoi diff ~/.bashrc
   ```

3. Apply changes
   ```bash
   chezmoi apply ~/.bashrc
   ```

4. Commit to dotfiles repo
   ```bash
   cd $(chezmoi source-path)
   git add dot_bashrc.tmpl
   git commit -m "feat(bash): integrate butterfish LLM autocomplete with security controls"
   ```

**Expected outcome:** .bashrc updated with butterfish integration

---

### Task 3.3: Test bash integration

**Subtasks:**
1. Open new terminal (kitty)
2. Verify butterfish loaded
   ```bash
   env | grep -i butterfish
   env | grep -i openai
   ```

3. Test basic butterfish command
   ```bash
   echo "Test Butterfish" | bf summarize
   ```

**Expected outcome:** Butterfish responds successfully

---

## Phase 4: Butterfish Configuration (chezmoi)

**Goal:** Configure butterfish preferences and behavior
**Duration:** ~20 minutes
**Dependencies:** Phase 3 complete

### Task 4.1: Create butterfish config directory structure

**Subtasks:**
1. Create config directory in chezmoi
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
   mkdir -p dot_config/butterfish
   ```

2. Verify directory in filesystem
   ```bash
   chezmoi apply ~/.config/butterfish/
   ls -ld ~/.config/butterfish
   ```

**Expected outcome:** Config directory exists

---

### Task 4.2: Create butterfish configuration file

**File:** `dotfiles/dot_config/butterfish/config.yaml`

**Subtasks:**
1. Create config file with sensible defaults
   ```yaml
   # Butterfish Configuration
   # Managed by: chezmoi
   # Last Updated: 2025-12-04

   # LLM Provider Settings
   provider: openai
   model: gpt-4  # Options: gpt-4, gpt-3.5-turbo, gpt-4-turbo

   # API Configuration
   api_timeout: 10s
   max_tokens: 500
   temperature: 0.7

   # Shell Integration
   shell_integration: true
   autocomplete_enabled: true
   goal_mode_enabled: true

   # Privacy & Security
   # Do NOT log API keys or sensitive commands
   logging_level: warn  # Options: debug, info, warn, error
   log_file: ~/.local/share/butterfish/butterfish.log

   # Context Settings
   # How much shell history to send to LLM
   context_lines: 20
   include_environment: false  # Don't send full env vars (privacy)

   # Performance
   cache_enabled: true
   cache_dir: ~/.cache/butterfish
   cache_ttl: 24h

   # Trigger Settings
   capital_letter_trigger: true  # Capital + Tab = AI prompt
   tab_autocomplete: true
   goal_mode_prefix: "!"

   # Cost Control
   # Approximate token limits per day to control API costs
   daily_token_limit: 50000  # ~$1/day for gpt-4
   warn_on_expensive_requests: true

   # Blocked Patterns
   # Never send these patterns to LLM (privacy)
   blocked_patterns:
     - "password"
     - "secret"
     - "token"
     - "key"
     - "credential"
   ```

2. Add config template if machine-specific settings needed
   ```bash
   # If you need per-machine config, rename to config.yaml.tmpl
   # and use chezmoi templating
   ```

**Expected outcome:** Configuration file created with secure defaults

---

### Task 4.3: Apply butterfish configuration

**Subtasks:**
1. Review config
   ```bash
   chezmoi diff ~/.config/butterfish/config.yaml
   ```

2. Apply configuration
   ```bash
   chezmoi apply ~/.config/butterfish/
   ```

3. Verify config loaded
   ```bash
   cat ~/.config/butterfish/config.yaml
   ```

4. Commit to dotfiles
   ```bash
   cd $(chezmoi source-path)
   git add dot_config/butterfish/
   git commit -m "feat(butterfish): add initial configuration with security defaults"
   ```

**Expected outcome:** Butterfish configured per user preferences

---

## Phase 5: Integration & Testing

**Goal:** Thoroughly test butterfish in real-world scenarios
**Duration:** ~35 minutes
**Dependencies:** All previous phases complete

### Task 5.1: Functional testing

**Subtasks:**
1. **Test basic AI prompt** (capital letter + Tab)
   ```bash
   # Type: "Find all Python files modified in the last week" + Tab
   # Expected: butterfish suggests a find command
   Find all Python files modified in the last week<Tab>
   ```

2. **Test autocomplete** (Tab)
   ```bash
   # Type: "git commit -m " + Tab
   # Expected: butterfish suggests a commit message based on staged changes
   git commit -m <Tab>
   ```

3. **Test goal mode** (! prefix)
   ```bash
   # Type: "!deploy my app to production"
   # Expected: butterfish creates multi-step plan
   !deploy my app to production
   ```

4. **Test summarization**
   ```bash
   cat /var/log/syslog | bf summarize
   ```

5. **Test question answering**
   ```bash
   bf ask "What is the difference between TCP and UDP?"
   ```

**Expected outcome:** All basic features work correctly

---

### Task 5.2: Compatibility testing

**Subtasks:**
1. **Test with ble.sh** (proactive suggestions)
   - Type a partial command
   - Verify ble.sh suggestions appear (gray text)
   - Press Capital+Tab
   - Verify butterfish AI prompt appears
   - Confirm no conflicts

2. **Test with atuin** (Ctrl+R history search)
   ```bash
   # Press Ctrl+R
   # Type search term
   # Verify atuin fuzzy search works
   # Verify butterfish doesn't interfere
   ```

3. **Test with kitty** (shell integration)
   ```bash
   # Verify shell integration markers
   echo $KITTY_SHELL_INTEGRATION

   # Test Ctrl+Shift+G (show last command output)
   ls -la
   # Press Ctrl+Shift+G
   ```

4. **Test SSH behavior** (CRITICAL for SRE)
   ```bash
   # SSH to remote server
   ssh user@remote-server

   # Verify butterfish is NOT active (check for wrapper)
   env | grep BUTTERFISH
   env | grep OPENAI
   # Expected: empty (butterfish disabled on SSH)

   # Type commands on remote
   # Verify normal bash behavior (no LLM)
   ```

5. **Test kitty SSH kitten**
   ```bash
   # Use kitty SSH kitten (user has alias)
   ssh remote-server

   # Verify butterfish doesn't break kitty features
   ```

**Expected outcome:** No conflicts with existing tools, SSH sessions are NOT sent to LLM

---

### Task 5.3: Performance testing

**Subtasks:**
1. **Measure API latency**
   ```bash
   # Time a butterfish request
   time echo "summarize this text" | bf summarize
   # Target: < 3 seconds for acceptable UX
   ```

2. **Test cache effectiveness**
   ```bash
   # Same request twice
   echo "what is kubernetes" | bf ask
   # Wait 2 seconds
   echo "what is kubernetes" | bf ask
   # Second request should be faster (cached)
   ```

3. **Monitor token usage**
   ```bash
   # Check butterfish logs for token counts
   tail -f ~/.local/share/butterfish/butterfish.log
   # Look for: token usage, cost estimates
   ```

4. **Test startup impact**
   ```bash
   # Measure bash startup time with butterfish
   time bash -i -c exit
   # Compare to baseline from classic plan review
   # Target: < 0.5s additional overhead
   ```

**Expected outcome:** Performance is acceptable, no significant slowdown

---

### Task 5.4: Security testing

**Subtasks:**
1. **Verify API key not in bash history**
   ```bash
   history | grep -i "openai\|api.*key"
   # Expected: empty (no key exposure)
   ```

2. **Verify API key not in process list**
   ```bash
   ps aux | grep -i butterfish
   # Expected: no API key visible in command line
   ```

3. **Check key file permissions**
   ```bash
   ls -lh $XDG_RUNTIME_DIR/butterfish-api-key
   # Expected: -rw------- (600, only user)
   ```

4. **Test key rotation**
   ```bash
   # Update key in KeePassXC
   secret-tool store --label="OpenAI API Key (butterfish)" \
     application butterfish \
     account openai

   # Restart service
   systemctl --user restart butterfish-api-key.service

   # Verify new key loaded
   # (Don't print it, just test butterfish works)
   echo "test" | bf summarize
   ```

5. **Check logging doesn't expose secrets**
   ```bash
   # Type a command with "password" in it
   echo "my-password-123"

   # Check logs
   cat ~/.local/share/butterfish/butterfish.log
   # Expected: "password" commands blocked/redacted per config
   ```

**Expected outcome:** No security vulnerabilities, API key properly protected

---

### Task 5.5: Privacy testing (SRE concerns)

**Subtasks:**
1. **Verify company commands not sent to API**
   ```bash
   # Type a company-specific command pattern
   # (simulated - don't use real company commands in test!)
   echo "kubectl get pods -n prod-env"

   # Check logs to see what context was sent
   tail ~/.local/share/butterfish/butterfish.log
   # Expected: context sent is limited per config.yaml
   ```

2. **Test offline behavior**
   ```bash
   # Disconnect network
   sudo ip link set eth0 down  # or equivalent

   # Try butterfish
   echo "test" | bf ask
   # Expected: timeout or error message, bash still works

   # Reconnect
   sudo ip link set eth0 up
   ```

3. **Test blocked patterns**
   ```bash
   # Type commands with sensitive keywords
   export MY_SECRET_TOKEN="test123"
   bf ask "what is my secret token"

   # Check logs - sensitive patterns should be redacted
   ```

**Expected outcome:** Privacy controls working, sensitive data not sent to API

---

## Phase 6: Documentation

**Goal:** Document butterfish setup and usage
**Duration:** ~25 minutes
**Dependencies:** All testing complete

### Task 6.1: Update ADR-009 with butterfish example

**File:** `docs/adrs/ADR-009-BASH_SHELL_ENHANCEMENT_CONFIGURATION.md`

**Subtasks:**
1. Add butterfish as example
   ```markdown
   ### Example 3: Butterfish (LLM Autocomplete)

   **Home-Manager (home-manager/butterfish.nix + shell.nix):**
   ```nix
   # Install via go (not in nixpkgs)
   home.activation.installButterfish = ...

   # Systemd service for secure API key loading
   systemd.user.services.butterfish-api-key = ...
   ```

   **Chezmoi (dotfiles/dot_bashrc.tmpl):**
   ```bash
   {{ if (lookPath "butterfish") }}
   # Load API key from secure location
   export OPENAI_API_KEY=$(cat "$XDG_RUNTIME_DIR/butterfish-api-key")
   eval "$(butterfish shell-init bash)"
   {{ end }}
   ```

   **Chezmoi (dotfiles/dot_config/butterfish/config.yaml):**
   ```yaml
   provider: openai
   model: gpt-4
   blocked_patterns: ["password", "secret", "token"]
   ```
   ```

2. Commit ADR update
   ```bash
   cd ~/.MyHome/MySpaces/my-modular-workspace/docs
   git add adrs/ADR-009-BASH_SHELL_ENHANCEMENT_CONFIGURATION.md
   git commit -m "docs(adr): add butterfish LLM autocomplete example to ADR-009"
   ```

**Expected outcome:** ADR-009 includes butterfish pattern

---

### Task 6.2: Create butterfish usage guide

**File:** `docs/commons/toolbox/butterfish/BUTTERFISH_GUIDE.md` (NEW)

**Subtasks:**
1. Create guide structure
   ```markdown
   # Butterfish - LLM Shell Autocomplete Guide

   ## Overview
   - What is butterfish
   - How it works (shell wrapper)
   - When to use (vs ble.sh)

   ## Installation
   - Link to this plan
   - Prerequisites

   ## Configuration
   - Config file location
   - Key settings explained
   - Privacy controls

   ## Usage
   ### Basic Features
   - Capital letter + Tab (AI prompt)
   - Tab (autocomplete)
   - Goal mode (! prefix)

   ### Commands
   - `bf ask "question"`
   - `bf summarize`
   - `bf shell-init`

   ### Examples
   (10-15 practical examples)

   ## Privacy & Security
   - What data is sent to API
   - How to control context
   - Blocked patterns
   - SSH behavior

   ## Troubleshooting
   - API key not loading
   - "unauthorized" errors
   - High API costs
   - Conflicts with other tools

   ## Cost Management
   - Token usage monitoring
   - Daily limits
   - Model selection (gpt-4 vs gpt-3.5)
   ```

2. Commit guide
   ```bash
   git add docs/commons/toolbox/butterfish/
   git commit -m "docs(butterfish): create comprehensive usage guide"
   ```

**Expected outcome:** Complete usage documentation exists

---

### Task 6.3: Create navi cheatsheet

**File:** `dotfiles/dot_local/share/navi/cheats/butterfish.cheat`

**Subtasks:**
1. Create cheatsheet
   ```
   % butterfish, llm, autocomplete, ai

   # Ask butterfish a question
   bf ask "<question>"

   # Summarize text
   echo "<text>" | bf summarize
   cat <file> | bf summarize

   # AI prompt mode (capital letter + Tab)
   # Type: "Find large files" + Tab
   Find large files<Tab>

   # Autocomplete current command (Tab)
   git commit -m <Tab>

   # Goal mode (multi-step)
   bf ! <goal-description>

   # Check butterfish status
   systemctl --user status butterfish-api-key.service

   # View butterfish logs
   tail -f ~/.local/share/butterfish/butterfish.log

   # Reload API key
   systemctl --user restart butterfish-api-key.service

   # Disable butterfish temporarily
   unset OPENAI_API_KEY

   # Re-enable butterfish
   source ~/.bashrc
   ```

2. Apply via chezmoi
   ```bash
   chezmoi apply ~/.local/share/navi/cheats/butterfish.cheat
   ```

3. Test cheatsheet
   ```bash
   navi --query butterfish
   ```

4. Commit
   ```bash
   cd $(chezmoi source-path)
   git add dot_local/share/navi/cheats/butterfish.cheat
   git commit -m "feat(navi): add butterfish LLM autocomplete cheatsheet"
   ```

**Expected outcome:** Navi cheatsheet available for quick reference

---

### Task 6.4: Update TODO.md

**File:** `docs/TODO.md`

**Subtasks:**
1. Mark butterfish tasks as complete
2. Add any follow-up tasks discovered during implementation
3. Commit
   ```bash
   git add docs/TODO.md
   git commit -m "docs(todo): mark butterfish implementation complete"
   ```

**Expected outcome:** TODO.md reflects current state

---

## Success Criteria

✅ **Installation:**
- [ ] butterfish installed via home-manager
- [ ] `which butterfish` returns valid path
- [ ] `butterfish --version` shows version

✅ **Security:**
- [ ] API key stored in KeePassXC (not in git)
- [ ] API key loaded via systemd service
- [ ] Key file has 600 permissions
- [ ] Key not visible in bash history or process list
- [ ] Blocked patterns prevent sensitive data in logs

✅ **Integration:**
- [ ] Butterfish loads in new terminal
- [ ] Capital+Tab triggers AI prompt
- [ ] Tab provides autocomplete
- [ ] Goal mode (!) works
- [ ] No conflicts with ble.sh
- [ ] No conflicts with atuin
- [ ] SSH sessions do NOT use butterfish

✅ **Performance:**
- [ ] API requests complete in < 5 seconds
- [ ] Cache reduces repeated query time
- [ ] Bash startup overhead < 0.5 seconds
- [ ] Token usage is reasonable

✅ **Privacy:**
- [ ] Sensitive commands blocked per config
- [ ] Limited context sent to API (config.yaml: context_lines)
- [ ] Environment variables not sent
- [ ] Offline fallback works (bash still functions)

✅ **Documentation:**
- [ ] ADR-009 updated with butterfish example
- [ ] Usage guide created
- [ ] Navi cheatsheet available
- [ ] TODO.md updated

---

## Rollback Plan

If butterfish causes issues, rollback in this order:

### Quick Disable (Immediate)
```bash
# Disable in current terminal
unset OPENAI_API_KEY
unalias bf bfgoal 2>/dev/null

# Disable systemd service
systemctl --user stop butterfish-api-key.service
systemctl --user disable butterfish-api-key.service

# Open new terminal - butterfish won't load (no API key)
```

### Partial Rollback (Remove bash integration, keep package)
```bash
# Comment out butterfish section in .bashrc
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
chezmoi edit ~/.bashrc
# Comment lines ~240-265 (butterfish section)
chezmoi apply ~/.bashrc

# Commit
cd $(chezmoi source-path)
git add dot_bashrc.tmpl
git commit -m "rollback(butterfish): disable bash integration"
```

### Full Rollback (Remove everything)
```bash
# 1. Remove from chezmoi
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
chezmoi forget ~/.bashrc
# Edit dot_bashrc.tmpl, remove butterfish section
git add dot_bashrc.tmpl
git commit -m "rollback(butterfish): remove bash integration"

chezmoi forget ~/.config/butterfish/
rm -rf $(chezmoi source-path)/dot_config/butterfish
git add -u
git commit -m "rollback(butterfish): remove configuration"

# 2. Remove from home-manager
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
# Remove butterfish.nix import from home.nix
# Remove activation script from shell.nix
git add home.nix shell.nix
git rm butterfish.nix
git commit -m "rollback(butterfish): remove home-manager integration"

home-manager switch

# 3. Remove binary
rm ~/go/bin/butterfish

# 4. Remove API key from KeePassXC
secret-tool clear application butterfish account openai

# 5. Verify clean state
which butterfish  # Should return: not found
env | grep -i butterfish  # Should return: empty
env | grep -i openai  # Should return: empty
```

---

## Timeline

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| Phase 1: Installation | 1.1 - 1.4 | 15 minutes |
| Phase 2: API Key Setup | 2.1 - 2.4 | 25 minutes |
| Phase 3: Bash Integration | 3.1 - 3.3 | 20 minutes |
| Phase 4: Configuration | 4.1 - 4.3 | 20 minutes |
| Phase 5: Testing | 5.1 - 5.5 | 35 minutes |
| Phase 6: Documentation | 6.1 - 6.4 | 25 minutes |
| **Total** | | **~2.5 hours** |

---

## Notes

### Differences from ble.sh (Classic) Plan

1. **Security-First Approach:** Butterfish requires API key management (Phase 2)
2. **Privacy Concerns:** LLM sees shell context - SSH detection critical
3. **Cost Monitoring:** API usage has real cost - daily limits configured
4. **Conditional Loading:** Only loads if API key available AND not in SSH
5. **Systemd Service:** Uses systemd pattern per ADR-007 for key loading

### Integration with Classic Autocomplete

Butterfish and ble.sh serve different purposes and can coexist:

- **ble.sh:** Fast, local, fish-like suggestions (history-based)
  - Gray text suggestions as you type
  - Right arrow to accept
  - No API calls, instant
  - Always available (offline)

- **butterfish:** Intelligent, context-aware, AI-powered
  - Capital+Tab for AI prompt
  - Tab for AI autocomplete
  - Goal mode for complex tasks
  - Requires API, 1-5s latency
  - Only available when API key loaded and online

**Recommended workflow:**
- Use ble.sh for fast, common commands
- Use butterfish for complex/novel tasks where you need AI help
- Use butterfish goal mode (!) for multi-step workflows

### SRE Considerations

⚠️ **PRIVACY WARNING:**
Butterfish sends shell context (recent commands, environment info) to OpenAI API. For SRE work:

1. **SSH Detection:** Plan DISABLES butterfish on SSH (company commands never sent to API)
2. **Blocked Patterns:** Prevents "password", "secret", "token" from being logged
3. **Context Limits:** Only sends last 20 lines per config (not full history)
4. **Environment Protection:** `include_environment: false` prevents env var leakage

**Best Practice:**
- Use ble.sh for routine SRE work (local, private)
- Use butterfish for learning/exploring new tools (AI-assisted)
- Never use butterfish on production servers (SSH detection handles this)

---

## References

- **Butterfish GitHub:** https://github.com/bakks/butterfish
- **ADR-009:** Shell Enhancement Configuration
- **Classic Plan:** PLAN_CLASSIC_AUTOCOMPLETE_BLE_SH.md
- **KeePassXC Integration:** ADR-007 Autostart Tools via Home-Manager
- **OpenAI API:** https://platform.openai.com/docs/api-reference

---

**Plan Status:** 📋 Ready for Ultrathink Review
**Next Step:** Perform comprehensive ultrathink review to identify gaps and weaknesses
