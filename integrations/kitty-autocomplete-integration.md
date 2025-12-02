# Kitty + Autocomplete.sh Integration

**Created:** 2025-11-30
**Status:** Implementation Guide
**Prerequisites:** Kitty terminal installed, KeePassXC (optional), chezmoi configured

---

## Overview

This guide integrates autocomplete.sh AI-powered command completion with kitty terminal emulator, using KeePassXC for secure API key management and chezmoi for declarative configuration.

**What You Get:**
- **AI-powered completions** in kitty terminal (double TAB for LLM suggestions)
- **Secure API key storage** via KeePassXC + secret-tool
- **Declarative configuration** managed by chezmoi
- **Fast, context-aware suggestions** using your choice of LLM

---

## Architecture

```
┌─────────────────────────────────────────┐
│   Kitty Terminal Emulator               │
│   - Renders completions beautifully     │
│   - GPU-accelerated display             │
│   - Font ligatures for arrows/icons     │
│                                          │
├─────────────────────────────────────────┤
│   Bash Shell with autocomplete.sh       │
│   - Intercepts TAB TAB                  │
│   - Gathers context (history, env, pwd) │
│   - Calls LLM API                       │
│   - Returns suggestions                 │
│                                          │
├─────────────────────────────────────────┤
│   LLM Provider (OpenAI/Anthropic/etc)   │
│   - Receives context                    │
│   - Generates intelligent suggestions   │
│   - Returns 2-5 command options         │
│                                          │
├─────────────────────────────────────────┤
│   KeePassXC (via secret-tool)           │
│   - Stores API keys securely            │
│   - Provides keys to bash on demand     │
│   - Encrypted at rest                   │
└─────────────────────────────────────────┘
```

**Data Flow:**
1. User types command in kitty terminal
2. User presses `<TAB><TAB>`
3. autocomplete.sh retrieves API key from KeePassXC/secret-tool
4. autocomplete.sh sends context to LLM (history, pwd, env)
5. LLM returns intelligent suggestions
6. Kitty renders suggestions beautifully
7. User selects or continues typing

---

## Prerequisites

### Required
- ✅ Kitty terminal installed and configured
- ✅ Bash shell (autocomplete.sh supports Bash >= 4.0)
- ✅ Chezmoi managing dotfiles
- ✅ Home-manager (for nixpkgs installations)
- ✅ Internet connection (for API-based LLMs)

### Optional (Recommended)
- ✅ KeePassXC for secure API key storage
- ✅ secret-tool (GNOME Keyring) for keyring integration
- ✅ Ollama for local, private LLMs (no API key needed)

---

## Step 1: Install autocomplete.sh

### Option A: Via Home-Manager (Recommended)

**Why home-manager?**
- Declarative, reproducible installation
- Per ADR-001: User packages via nixpkgs-unstable
- Version controlled, easy to roll back

**Not available in nixpkgs yet**, so use manual install + track in docs.

### Option B: Manual Install (Current Method)

```bash
# Download and install
wget -qO- https://autocomplete.sh/install.sh | bash

# Or manual for review:
wget https://autocomplete.sh/install.sh
cat install.sh  # Review first!
bash install.sh
```

**What it does:**
1. Downloads `autocomplete.sh` to `~/.local/bin/autocomplete`
2. Adds sourcing line to `~/.bashrc`
3. Prompts for API key (we'll configure securely later)

**Verify:**
```bash
which autocomplete
# Expected: /home/mitsio/.local/bin/autocomplete

autocomplete --version
# Expected: 0.5.0 or newer
```

---

## Step 2: Secure API Key Setup with KeePassXC

### 2.1: Store API Keys in KeePassXC

**Using KeePassXC GUI:**

1. Open KeePassXC
2. Open your vault (e.g., `~/Passwords.kdbx`)
3. Create entries:
   - **Title:** `OpenAI API`
     - **Username:** `openai`
     - **Password:** `sk-...your-openai-api-key...`
   - **Title:** `Anthropic API`
     - **Username:** `anthropic`
     - **Password:** `sk-ant-...your-anthropic-api-key...`
   - **Title:** `Groq API`
     - **Username:** `groq`
     - **Password:** `gsk_...your-groq-api-key...`

4. Save vault

### 2.2: Store in Secret Service (GNOME Keyring)

**Method 1: Via secret-tool (Recommended for bash)**

```bash
# Store OpenAI API key
secret-tool store --label="OpenAI API Key" service openai key apikey
# Prompts for password, paste: sk-...

# Store Anthropic API key
secret-tool store --label="Anthropic API Key" service anthropic key apikey
# Prompts for password, paste: sk-ant-...

# Store Groq API key (optional, Groq is free)
secret-tool store --label="Groq API Key" service groq key apikey
# Prompts for password, paste: gsk_...
```

**Verify:**
```bash
secret-tool lookup service openai key apikey
# Should print: sk-...

secret-tool lookup service anthropic key apikey
# Should print: sk-ant-...
```

**Method 2: Via KeePassXC Secret Service Integration**

KeePassXC can expose entries via Secret Service protocol:

1. Open KeePassXC Settings → Browser Integration
2. Enable "Enable browser integration"
3. Enable "Integrate with system-wide Secret Service"
4. Unlock your database

Now entries are accessible via `secret-tool`:
```bash
secret-tool lookup Title "OpenAI API"
```

---

## Step 3: Configure Bash via Chezmoi

### 3.1: Create Bash Configuration Template

**File:** `dotfiles/dot_bashrc.tmpl`

**Add to end of file:**

```bash
# ============================================================================
# Autocomplete.sh - AI-Powered Command Completion
# GitHub: https://github.com/closedloop-technologies/autocomplete-sh
# Docs: ~/.MyHome/MySpaces/my-modular-workspace/docs/tools/autocomplete-sh.md
# ============================================================================

{{- if (lookPath "autocomplete") }}

# ===== API Keys from Secret Service (KeePassXC/GNOME Keyring) =====
{{- if (lookPath "secret-tool") }}
export OPENAI_API_KEY=$(secret-tool lookup service openai key apikey 2>/dev/null)
export ANTHROPIC_API_KEY=$(secret-tool lookup service anthropic key apikey 2>/dev/null)
export GROQ_API_KEY=$(secret-tool lookup service groq key apikey 2>/dev/null)
{{- end }}

# ===== Source Autocomplete.sh =====
if [ -f ~/.local/bin/autocomplete ]; then
    . ~/.local/bin/autocomplete install
fi

# ===== Autocomplete.sh Configuration =====
# Preferred model (change based on your needs)
# Options: gpt-4o-mini (cheap), gpt-4o (powerful), claude-3-5-haiku (fast),
#          llama-3.1-8b-instant (free via Groq), codellama (local via Ollama)
export ACSH_MODEL="gpt-4o-mini"  # Default: fast and cheap

# Context limits (lower = faster, higher = more accurate)
export ACSH_MAX_HISTORY_COMMANDS=20  # Recent commands to include
export ACSH_MAX_RECENT_FILES=20      # Recent files to list

# Security
export ACSH_ENABLE_SANITIZATION=true  # Redact sensitive data in prompts

# Cache settings
export ACSH_CACHE_TTL=3600  # Cache suggestions for 1 hour

# ===== Optional: Autocomplete.sh Aliases =====
alias ac-model='autocomplete model'         # Quick model selection
alias ac-config='autocomplete config'       # Quick config view
alias ac-usage='autocomplete usage'         # Quick usage stats
alias ac-help='autocomplete --help'         # Quick help

{{- end }}

# ============================================================================
# End Autocomplete.sh Configuration
# ============================================================================
```

### 3.2: Apply Configuration

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply

# Reload bash
source ~/.bashrc
```

### 3.3: Verify Integration

```bash
# Check API keys loaded
echo "OpenAI: ${OPENAI_API_KEY:0:10}..."  # Should show: sk-...
echo "Anthropic: ${ANTHROPIC_API_KEY:0:10}..."  # Should show: sk-ant-...

# Test autocomplete is loaded
type autocomplete
# Should show: autocomplete is a function

# Test basic completion (dry run)
autocomplete command --dry-run "git push"
# Should show the prompt that would be sent to LLM
```

---

## Step 4: Kitty-Specific Enhancements

### 4.1: Add Kitty Keybindings

**File:** `dotfiles/dot_config/kitty/kitty.conf`

**Add after keyboard shortcuts section:**

```conf
# ============ AUTOCOMPLETE.SH INTEGRATION ============

# Quick access to autocomplete usage stats
map ctrl+shift+a>u launch --type=overlay --hold autocomplete usage

# Quick access to model selection
map ctrl+shift+a>m launch --type=overlay autocomplete model

# Quick access to configuration
map ctrl+shift+a>c launch --type=overlay --hold autocomplete config

# Quick access to help
map ctrl+shift+a>h launch --type=overlay --hold autocomplete --help
```

**Apply:**
```bash
chezmoi apply
# Ctrl+Shift+F5 in kitty to reload config
```

### 4.2: Configure Kitty Hints for Command Selection

Kitty's hints kitten can help select auto-suggested commands:

**File:** `dotfiles/dot_config/kitty/kitty.conf`

```conf
# ===== Kitty Hints for Command Selection =====
# Press Ctrl+Shift+H to activate hints on command lines
map ctrl+shift+h kitten hints --type=line --program=@

# Alternative: hints for URLs and file paths
map ctrl+shift+p>h kitten hints
```

---

## Step 5: Choose Your LLM Model

### Decision Matrix

| Model | Provider | Cost (1K chars) | Speed | Privacy | Rec. Use Case |
|-------|----------|----------------|-------|---------|---------------|
| **gpt-4o-mini** | OpenAI | ~$0.01 | Fast | Cloud | **Default** - balanced |
| **gpt-4o** | OpenAI | ~$0.03 | Medium | Cloud | Complex workflows |
| **claude-3-5-haiku** | Anthropic | ~$0.01 | Very Fast | Cloud | Quick completions |
| **claude-3-7-sonnet** | Anthropic | ~$0.02 | Medium | Cloud | Code understanding |
| **llama-3.1-8b-instant** | Groq | FREE | Very Fast | Cloud | **Budget option** |
| **llama-3.3-70b** | Groq | FREE | Fast | Cloud | Powerful + free |
| **codellama** | Ollama | FREE | Medium | **Local** | **Privacy-focused** |

### Configure Model

**Interactive selection:**
```bash
autocomplete model
```

**Or via config:**
```bash
autocomplete config set model gpt-4o-mini

# Or edit ~/.bashrc (via chezmoi)
# export ACSH_MODEL="gpt-4o-mini"
```

### Local Model Setup (Privacy-Focused)

**Install Ollama:**
```bash
curl https://ollama.ai/install.sh | sh

# Pull model
ollama pull codellama

# Verify
ollama list
```

**Configure autocomplete.sh:**
```bash
autocomplete model
# Select: ollama: codellama

# Or in ~/.bashrc:
export ACSH_MODEL="codellama"
```

**Benefits:**
- ✅ Zero API costs
- ✅ Complete privacy (no data leaves machine)
- ✅ No API key management
- ✅ Works offline

---

## Step 6: Test Integration

### Basic Test

```bash
# Type a partial command
git push

# Press TAB TAB
<TAB><TAB>

# Should see AI-generated suggestions like:
# git push origin main
# git push --force
# git push --set-upstream origin feature-branch
```

### Natural Language Test

```bash
# Type natural language
# find all python files modified today

# Press TAB TAB
<TAB><TAB>

# Should see:
# find . -name "*.py" -mtime 0
```

### Complex Workflow Test

```bash
# create a github repo, init a readme, and push it

# Press TAB TAB
<TAB><TAB>

# Should see multi-command suggestions
```

---

## Usage Examples

### Example 1: Docker Commands

```bash
# Start typing
docker run

<TAB><TAB>

# Suggestions:
# docker run -d -p 8080:80 nginx
# docker run -it ubuntu bash
# docker run --rm -v $(pwd):/app node:16 npm install
```

### Example 2: Git Workflows

```bash
# Scenario: You want to create a feature branch
git

<TAB><TAB>

# Or be specific:
# create a feature branch called user-auth

<TAB><TAB>

# Suggestions:
# git checkout -b feature/user-auth
# git switch -c feature/user-auth
```

### Example 3: File Operations

```bash
# find large files

<TAB><TAB>

# Suggestions:
# find . -type f -size +100M
# du -ah . | sort -rh | head -n 20
```

---

## Troubleshooting

### Issue: No suggestions appear

**Check:**
```bash
# 1. Verify autocomplete is loaded
type autocomplete
# Should show: autocomplete is a function

# 2. Check API key
echo $OPENAI_API_KEY
# Should show: sk-...

# 3. Test manually
autocomplete command "git status"
# Should return suggestions

# 4. Check logs
tail ~/.config/autocomplete/autocomplete.log
```

**Fix:**
```bash
# Reload bashrc
source ~/.bashrc

# Re-apply chezmoi
chezmoi apply
source ~/.bashrc
```

### Issue: API key not found

**Check secret-tool:**
```bash
secret-tool lookup service openai key apikey
# Should return key, not empty

# If empty, re-store:
secret-tool store --label="OpenAI API Key" service openai key apikey
```

**Check KeePassXC:**
```bash
# Ensure KeePassXC is running
pgrep -x keepassxc
# Should return process ID

# Unlock your database
# Then retry
```

### Issue: Slow completions

**Solution 1: Switch to faster model**
```bash
autocomplete model
# Select: groq: llama-3.1-8b-instant (FREE and FAST!)
```

**Solution 2: Reduce context**
```bash
autocomplete config set ACSH_MAX_HISTORY_COMMANDS 10
autocomplete config set ACSH_MAX_RECENT_FILES 10
```

**Solution 3: Use local model**
```bash
# Install Ollama
curl https://ollama.ai/install.sh | sh
ollama pull codellama

# Switch model
autocomplete model
# Select: ollama: codellama
```

---

## Best Practices

### 1. Use Comments for Better Suggestions

```bash
# Good:
# Install project dependencies and start dev server
<TAB><TAB>

# Bad:
npm
<TAB><TAB>
```

### 2. Model Selection Strategy

- **Quick commands:** `groq: llama-3.1-8b-instant` (free, fast)
- **Complex workflows:** `gpt-4o` or `claude-3-7-sonnet` (powerful)
- **Privacy-sensitive:** `ollama: codellama` (local)
- **Default:** `gpt-4o-mini` (balanced)

### 3. Cost Management

**Monitor usage:**
```bash
autocomplete usage
```

**Switch to free models for daily use:**
```bash
# In ~/.bashrc (via chezmoi)
export ACSH_MODEL="llama-3.1-8b-instant"  # Groq, free tier
```

### 4. Security

**Always enable sanitization:**
```bash
export ACSH_ENABLE_SANITIZATION=true
```

**Use secret-tool, not plaintext:**
```bash
# ❌ Don't do this:
export OPENAI_API_KEY="sk-..."  # Visible in ps, history

# ✅ Do this:
export OPENAI_API_KEY=$(secret-tool lookup service openai key apikey 2>/dev/null)
```

---

## Maintenance

### Update autocomplete.sh

```bash
# Check current version
autocomplete --version

# Download latest
wget -qO ~/.local/bin/autocomplete https://raw.githubusercontent.com/closedloop-technologies/autocomplete-sh/main/autocomplete.sh

# Reload
source ~/.bashrc
```

### Rotate API Keys

```bash
# Update in KeePassXC GUI or:
secret-tool store --label="OpenAI API Key" service openai key apikey
# Paste new key

# Reload bash
source ~/.bashrc
```

---

## Reference

**Related Documentation:**
- Tool Documentation: `docs/tools/autocomplete-sh.md`
- Implementation Plan: `docs/plans/autocomplete-sh-integration-plan.md`
- Navi Cheatsheet: `~/.local/share/navi/cheats/autocomplete.cheat`

**External Links:**
- Official Site: https://autocomplete.sh/
- GitHub: https://github.com/closedloop-technologies/autocomplete-sh
- KeePassXC: https://keepassxc.org/
- Ollama: https://ollama.ai/

---

**Last Updated:** 2025-11-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
