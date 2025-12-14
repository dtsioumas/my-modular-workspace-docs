# Autocomplete.sh + Kitty Integration Plan

**Created:** 2025-11-30
**Session:** autocomplete-sh-integration
**Status:** Implementation Ready
**Estimated Time:** 80-115 minutes (1.5-2 hours)
**Risk Level:** LOW (isolated, reversible changes)

## Executive Summary

This plan integrates autocomplete.sh AI-powered command completion into kitty terminal with secure API key management via KeePassXC and declarative configuration via chezmoi.

**What You Get:**

- ✅ AI completions in kitty (double TAB for LLM suggestions)
- ✅ Secure API key storage (KeePassXC + secret-tool)
- ✅ Declarative config (chezmoi-managed `.bashrc`)
- ✅ Fast, context-aware suggestions

**Deliverables:**

1. autocomplete.sh installed at `~/.local/bin/autocomplete`
2. API keys stored in KeePassXC, accessed via secret-tool
3. Bash configuration template: `dotfiles/dot_bashrc.tmpl`
4. Kitty keybindings for quick access (optional)
5. Working AI completions in kitty terminal

---

## Prerequisites

**Required:**

- ✅ Kitty terminal installed
- ✅ Bash shell  (>=4.0)
- ✅ Chezmoi managing dotfiles
- ✅ KeePassXC installed (for secure key storage)
- ✅ secret-tool (GNOME Keyring) installed
- ✅ Internet connection (for API-based LLMs)

**Verify:**

```bash
which kitty          # Should exist
which chezmoi        # Should exist
which keepassxc      # Should exist
which secret-tool    # Should exist
bash --version       # Should be >= 4.0
```

**Before Starting:**

1. Backup current `.bashrc` (chezmoi handles this automatically)
2. Have your LLM API key ready (OpenAI, Anthropic, or Groq)
3. Or plan to use Ollama (local, free, no key needed)

---

## Phase 1: Secure API Key Setup with KeePassXC

**Goal:** Store LLM API keys securely in KeePassXC and configure secret-tool access

**Time:** 15-20 minutes
**Risk:** LOW (read-only keyring access)

### Step 1.1: Create API Key Entries in KeePassXC

**Open KeePassXC GUI:**

```bash
keepassxc
```

**Create entries in your vault:**

1. **OpenAI API Key**

   - Title: `OpenAI API`
   - Username: `openai`
   - Password: `sk-...your-api-key...`
   - URL: `https://platform.openai.com/api-keys`
2. **Anthropic API Key** (optional)

   - Title: `Anthropic API`
   - Username: `anthropic`
   - Password: `sk-ant-...your-api-key...`
   - URL: `https://console.anthropic.com/`
3. **Groq API Key** (optional, free tier)

   - Title: `Groq API`
   - Username: `groq`
   - Password: `gsk_...your-api-key...`
   - URL: `https://console.groq.com/keys`

**Save vault**

### Step 1.2: Store Keys in Secret Service (GNOME Keyring)

**Using secret-tool:**

```bash
# Store OpenAI API key
secret-tool store --label="OpenAI API Key" service openai key apikey
# When prompted, paste your API key: sk-...

# Store Anthropic API key (optional)
secret-tool store --label="Anthropic API Key" service anthropic key apikey
# Paste: sk-ant-...

# Store Groq API key (optional, free)
secret-tool store --label="Groq API Key" service groq key apikey
# Paste: gsk_...
```

### Step 1.3: Verify Secret Tool Access

```bash
# Test retrieval
secret-tool lookup service openai key apikey
# Should output: sk-... (your API key)

# Test in subshell (simulates bash startup)
bash -c 'echo $(secret-tool lookup service openai key apikey 2>/dev/null)'
# Should output: sk-...

# If empty, check KeePassXC is unlocked and secret service enabled
```

**Success Criteria:**

- ✅ API keys stored in KeePassXC
- ✅ `secret-tool lookup` retrieves keys successfully
- ✅ No plaintext API keys in files

---

## Phase 2: Install autocomplete.sh

**Goal:** Download and install autocomplete.sh to `~/.local/bin/autocomplete`

**Time:** 10-15 minutes
**Risk:** LOW (isolated installation)

### Step 2.1: Download and Install

**Method: Official installer (recommended)**

```bash
# Download installer
wget https://autocomplete.sh/install.sh -O /tmp/autocomplete-install.sh

# Review installer (ALWAYS review before running!)
cat /tmp/autocomplete-install.sh

# Run installer
bash /tmp/autocomplete-install.sh

# When prompted for API key, skip (we'll configure via secret-tool)
# Press Ctrl+C when it asks for API key
```

**Expected actions:**

- Downloads `autocomplete.sh` to `~/.local/bin/autocomplete`
- Adds sourcing line to `~/.bashrc` (we'll manage this via chezmoi instead)

### Step 2.2: Verify Installation

```bash
# Check installation
which autocomplete
# Expected: /home/mitsio/.local/bin/autocomplete

# Check version
autocomplete --version
# Expected: 0.5.0 or newer

# Check script is executable
ls -lh ~/.local/bin/autocomplete
# Expected: -rwxr-xr-x ...
```

### Step 2.3: Clean Up Installer Additions

**Remove installer's bashrc modifications (we'll use chezmoi):**

```bash
# Check if installer added lines to ~/.bashrc
grep "autocomplete" ~/.bashrc

# If found, remove them (we'll manage via chezmoi template)
# We'll configure properly in Phase 3
```

**Success Criteria:**

- ✅ `~/.local/bin/autocomplete` exists and is executable
- ✅ `autocomplete --version` returns version number
- ✅ Ready for configuration

---

## Phase 3: Configure Bash via Chezmoi

**Goal:** Create chezmoi-managed bash configuration with API key integration

**Time:** 20-30 minutes
**Risk:** MEDIUM (can break shell if syntax error, use `chezmoi diff` first)

### Step 3.1: Check if dot_bashrc.tmpl Exists

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Check if template exists
ls -lh dot_bashrc.tmpl

# If exists, edit it
# If not exists, create from current .bashrc
chezmoi add --template ~/.bashrc
```

### Step 3.2: Add Autocomplete.sh Configuration

**Edit:** `dotfiles/dot_bashrc.tmpl`

**Add to end of file:**

```bash
# ============================================================================
# Autocomplete.sh - AI-Powered Command Completion
# GitHub: https://github.com/closedloop-technologies/autocomplete-sh
# Docs: ~/.MyHome/MySpaces/my-modular-workspace/docs/tools/autocomplete-sh.md
# Integration Guide: ~/.MyHome/MySpaces/my-modular-workspace/docs/integrations/kitty-autocomplete-integration.md
# ============================================================================

{{- if (lookPath "autocomplete") }}

# ===== API Keys from Secret Service (KeePassXC/GNOME Keyring) =====
{{- if (lookPath "secret-tool") }}
# Retrieve API keys securely from keyring (stored in Phase 1)
export OPENAI_API_KEY=$(secret-tool lookup service openai key apikey 2>/dev/null)
export ANTHROPIC_API_KEY=$(secret-tool lookup service anthropic key apikey 2>/dev/null)
export GROQ_API_KEY=$(secret-tool lookup service groq key apikey 2>/dev/null)
{{- end }}

# ===== Source Autocomplete.sh =====
if [ -f ~/.local/bin/autocomplete ]; then
    . ~/.local/bin/autocomplete install
fi

# ===== Autocomplete.sh Configuration =====

# Preferred model (choose based on your needs)
# Cost-effective: gpt-4o-mini (~$0.01/1K), claude-3-5-haiku (~$0.01/1K)
# Free: llama-3.1-8b-instant (Groq free tier)
# Local/Private: codellama (Ollama, requires local install)
export ACSH_MODEL="gpt-4o-mini"

# Context limits (balance speed vs accuracy)
export ACSH_MAX_HISTORY_COMMANDS=20  # Recent commands to include in prompt
export ACSH_MAX_RECENT_FILES=20      # Recent files to list in prompt

# Security settings
export ACSH_ENABLE_SANITIZATION=true  # Redact API keys/UUIDs/hashes in prompts

# Cache settings (speed optimization)
export ACSH_CACHE_TTL=3600  # Cache suggestions for 1 hour (seconds)

# ===== Optional: Autocomplete.sh Aliases =====
alias ac-model='autocomplete model'         # Quick model selection
alias ac-config='autocomplete config'       # Quick config view
alias ac-usage='autocomplete usage'         # Usage stats and costs
alias ac-help='autocomplete --help'         # Help

{{- end }}

# ============================================================================
# End Autocomplete.sh Configuration
# ============================================================================
```

### Step 3.3: Preview Changes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Preview what will change
chezmoi diff

# Should show:
# - Addition of autocomplete.sh configuration block
# - Conditional loading (only if autocomplete exists)
# - API key retrieval from secret-tool
```

### Step 3.4: Apply Configuration

```bash
# Apply changes
chezmoi apply

# Reload bash
source ~/.bashrc

# Verify no syntax errors
echo $?
# Should be: 0 (success)
```

### Step 3.5: Verify Configuration Loaded

```bash
# Check API keys are loaded
echo "OpenAI: ${OPENAI_API_KEY:0:10}..."
# Should show: OpenAI: sk-...

echo "Anthropic: ${ANTHROPIC_API_KEY:0:10}..."
# Should show: Anthropic: sk-ant-... (or empty if not configured)

# Check autocomplete function is loaded
type autocomplete
# Should show: autocomplete is a function

# Check configuration variables
echo "Model: $ACSH_MODEL"
# Should show: Model: gpt-4o-mini

echo "Sanitization: $ACSH_ENABLE_SANITIZATION"
# Should show: Sanitization: true
```

**Success Criteria:**

- ✅ No bash syntax errors
- ✅ API keys loaded from secret-tool
- ✅ autocomplete function available
- ✅ Configuration variables set correctly
- ✅ Changes managed by chezmoi

---

## Phase 4: Kitty Enhancements (OPTIONAL)

**Goal:** Add kitty keybindings for quick access to autocomplete.sh features

**Time:** 15-20 minutes
**Risk:** MINIMAL (non-breaking, kitty-specific)

### Step 4.1: Edit Kitty Configuration

**File:** `dotfiles/dot_config/kitty/kitty.conf`

**Add after keyboard shortcuts section:**

```conf
# ============ AUTOCOMPLETE.SH INTEGRATION ============
# Quick access to autocomplete.sh features
# Documentation: ~/.MyHome/MySpaces/my-modular-workspace/docs/integrations/kitty-autocomplete-integration.md

# View usage statistics (API calls, costs, cache hits)
map ctrl+shift+a>u launch --type=overlay --hold autocomplete usage

# Interactive model selection menu
map ctrl+shift+a>m launch --type=overlay autocomplete model

# View current configuration
map ctrl+shift+a>c launch --type=overlay --hold autocomplete config

# Quick help
map ctrl+shift+a>h launch --type=overlay --hold autocomplete --help

# ===== Kitty Hints for Command Selection =====
# Press Ctrl+Shift+H to activate hints on terminal lines
# Useful for selecting suggested commands from autocomplete.sh
map ctrl+shift+h kitten hints --type=line --program=@
```

### Step 4.2: Apply Kitty Configuration

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Preview changes
chezmoi diff

# Apply
chezmoi apply

# Reload kitty config
# In kitty terminal: Ctrl+Shift+F5
```

### Step 4.3: Test Keybindings

**In kitty terminal:**

```bash
# Test usage stats shortcut
# Press: Ctrl+Shift+A, then U
# Should show: Autocomplete usage statistics overlay

# Test model selection
# Press: Ctrl+Shift+A, then M
# Should show: Interactive model selection menu

# Test config view
# Press: Ctrl+Shift+A, then C
# Should show: Current configuration overlay

# Test hints
# Press: Ctrl+Shift+H
# Should highlight terminal lines for selection
```

**Success Criteria:**

- ✅ All keybindings work
- ✅ Overlays display correctly
- ✅ No conflicts with existing kitty shortcuts

---

## Phase 5: Model Selection & Configuration

**Goal:** Choose and configure your preferred LLM model

**Time:** 5-10 minutes
**Risk:** MINIMAL (configuration only)

### Option A: Use Cloud LLM (Recommended for Starting)

**Interactive selection:**

```bash
autocomplete model
```

**Recommended choices:**


| Model                    | Provider  | Cost (1K) | Speed     | Best For              |
| ------------------------ | --------- | --------- | --------- | --------------------- |
| **gpt-4o-mini**          | OpenAI    | ~$0.01    | Fast      | **Default, balanced** |
| **llama-3.1-8b-instant** | Groq      | FREE      | Very Fast | **Budget testing**    |
| **claude-3-5-haiku**     | Anthropic | ~$0.01    | Very Fast | Quick completions     |

**Select:** `gpt-4o-mini` (default) or `llama-3.1-8b-instant` (free)

### Option B: Use Local LLM (Privacy-Focused)

**Install Ollama:**

```bash
# Install Ollama
curl https://ollama.ai/install.sh | sh

# Pull model
ollama pull codellama

# Verify
ollama list
# Should show: codellama
```

**Configure autocomplete.sh:**

```bash
autocomplete model
# Select: ollama: codellama
```

**Benefits:**

- ✅ Zero API costs
- ✅ Complete privacy (no data leaves machine)
- ✅ No API key needed
- ✅ Works offline

### Step 5.1: Test Model

```bash
# Test completion (dry run, doesn't call API)
autocomplete command --dry-run "git status"

# Should show the prompt that would be sent to LLM
# Includes: system message, terminal info, command history, etc.

# Test actual completion
autocomplete command "git push"

# Should return 2-5 suggested commands
```

**Success Criteria:**

- ✅ Model selected
- ✅ Test completion works
- ✅ API key authenticated (or Ollama running locally)

---

## Phase 6: Testing & Verification

**Goal:** Verify complete integration works correctly

**Time:** 15-20 minutes
**Risk:** NONE (testing only)

### Test 1: Basic Completion

```bash
# In kitty terminal, type:
git push

# Press TAB TAB
<TAB><TAB>

# Expected: 2-5 AI-generated suggestions appear
# Example suggestions:
# git push origin main
# git push --set-upstream origin feature-branch
# git push --force-with-lease
```

**✅ Pass:** Suggestions appear
**❌ Fail:** No suggestions → Check Phase 3 configuration

### Test 2: Natural Language Completion

```bash
# Type natural language comment:
# find all python files modified today

# Press TAB TAB
<TAB><TAB>

# Expected: Command suggestions like:
# find . -name "*.py" -mtime 0
# find . -type f -name "*.py" -mtime -1
```

**✅ Pass:** Natural language translated to commands
**❌ Fail:** No suggestions → Check model configuration

### Test 3: Complex Workflow

```bash
# Type:
# create a github repo, init a readme, and push it

# Press TAB TAB
<TAB><TAB>

# Expected: Multi-command chain like:
# gh repo create my-repo --public && cd my-repo && echo "# My Repo" > README.md && git init && git add . && git commit -m "Initial commit" && git push -u origin main
```

**✅ Pass:** Complex multi-command suggestions
**❌ Fail:** Simple suggestions only → Try more powerful model (gpt-4o)

### Test 4: API Key Security

```bash
# Check API key not exposed in process list
ps aux | grep -i "sk-"
# Should NOT show your API key

# Check history doesn't contain API key
history | grep -i "sk-"
# Should NOT show your API key

# Verify secret-tool used
grep "OPENAI_API_KEY=" ~/.bashrc
# Should show: export OPENAI_API_KEY=$(secret-tool...)
# Should NOT show: export OPENAI_API_KEY="sk-..."
```

**✅ Pass:** No plaintext keys found
**❌ Fail:** Keys exposed → Review Phase 1 and 3

### Test 5: Chezmoi Idempotency

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Apply again
chezmoi apply

# Should show: No changes (idempotent)

# Source bashrc again
source ~/.bashrc

# Test completion still works
autocomplete command "ls"
```

**✅ Pass:** Idempotent, still works after re-apply
**❌ Fail:** Errors on re-apply → Check chezmoi template syntax

### Test 6: Usage Tracking

```bash
# View usage stats
autocomplete usage

# Should show:
# - Number of API calls
# - Estimated costs
# - Cache hit rate
# - Token usage
```

**✅ Pass:** Usage stats displayed correctly

### Test 7: Kitty Keybindings (if Phase 4 completed)

```bash
# In kitty terminal:
# Press: Ctrl+Shift+A, U
# Should show usage overlay

# Press: Ctrl+Shift+A, M
# Should show model selection menu
```

**✅ Pass:** All keybindings work

**Success Criteria:**

- ✅ All 7 tests pass
- ✅ Completions work in kitty
- ✅ API keys secure
- ✅ Configuration managed by chezmoi

---

## Rollback Plan

**If something breaks:**

### Rollback Bash Configuration

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Revert chezmoi changes
git log --oneline  # Find commit before autocomplete.sh
git revert <commit-hash>

# Re-apply
chezmoi apply
source ~/.bashrc
```

### Remove autocomplete.sh

```bash
# Remove installation
rm ~/.local/bin/autocomplete

# Remove from bashrc (via chezmoi)
# Edit dotfiles/dot_bashrc.tmpl, remove autocomplete.sh block
chezmoi apply
source ~/.bashrc
```

### Remove API Keys from Keyring

```bash
# List keys
secret-tool search service openai

# Remove key
secret-tool clear service openai key apikey
secret-tool clear service anthropic key apikey
```

---

## Post-Implementation

### Maintenance

**Update autocomplete.sh:**

```bash
# Check for updates
curl -s https://api.github.com/repos/closedloop-technologies/autocomplete-sh/releases/latest | grep tag_name

# Update if newer version available
wget -qO ~/.local/bin/autocomplete https://raw.githubusercontent.com/closedloop-technologies/autocomplete-sh/main/autocomplete.sh

# Reload
source ~/.bashrc
```

**Rotate API Keys:**

```bash
# Update in KeePassXC GUI, then update keyring:
secret-tool store --label="OpenAI API Key" service openai key apikey
# Paste new key

# Reload bash
source ~/.bashrc
```

### Cost Monitoring

```bash
# Check usage weekly
autocomplete usage

# Switch to cheaper model if needed
autocomplete model
# Select: groq: llama-3.1-8b-instant (FREE)
```

---

## Success Criteria

**Implementation complete when:**

- ✅ autocomplete.sh installed at `~/.local/bin/autocomplete`
- ✅ API keys stored in KeePassXC, retrieved via secret-tool
- ✅ Bash configuration template managed by chezmoi
- ✅ Double TAB triggers AI completions in kitty
- ✅ Natural language converts to commands
- ✅ No plaintext API keys in files
- ✅ Kitty keybindings work (if Phase 4 completed)
- ✅ All tests pass
- ✅ User (Mitsio) satisfied with intelligent completions!

---

## Next Steps

**After successful implementation:**

1. **Explore models:** Try different LLMs to find your favorite
2. **Create workflows:** Use natural language for complex tasks
3. **Monitor costs:** Check `autocomplete usage` weekly
4. **Share knowledge:** Help teammates set up autocomplete.sh
5. **Provide feedback:** Star the GitHub repo, report issues

**Optional enhancements:**

- Create navi cheatsheet for autocomplete.sh commands
- Add more kitty keybindings
- Explore Ollama for fully local completions
- Configure per-project model preferences

---

## Reference

**Documentation:**

- Tool Guide: `docs/tools/autocomplete-sh.md`
- Integration Guide: `docs/integrations/kitty-autocomplete-integration.md`
- This Plan: `docs/plans/autocomplete-sh-integration-plan.md`
- Navi Cheatsheet: `~/.local/share/navi/cheats/autocomplete.cheat` (to be created)

**External:**

- Official Site: https://autocomplete.sh/
- GitHub: https://github.com/closedloop-technologies/autocomplete-sh
- KeePassXC: https://keepassxc.org/
- Ollama: https://ollama.ai/

---

**Last Updated:** 2025-11-30
**Maintained By:** Dimitris Tsioumas (Mitsio)

**Implementation Status:** Ready to Execute!
