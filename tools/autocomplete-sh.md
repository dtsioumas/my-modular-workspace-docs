# Autocomplete.sh - AI-Powered Terminal Completion

**Official Site:** https://autocomplete.sh/
**GitHub:** https://github.com/closedloop-technologies/autocomplete-sh
**Status:** Active, Open Source (MIT License)
**Current Version:** v0.5.0 (as of 2025-11-30)

---

## What is Autocomplete.sh?

Autocomplete.sh is an AI-powered command-line completion tool that adds intelligent suggestions directly to your Bash or Zsh terminal. Instead of memorizing command syntax and flags, just type `<TAB><TAB>` and it calls an LLM to return contextually relevant suggestions.

**Tagline:** "Command Your Terminal - `--help` less, accomplish more"

**Key Innovation:** Uses Large Language Models (LLMs) to understand your intent and provide smart, context-aware command suggestions based on your environment, history, and current directory.

---

## Key Features

### 1. AI-Powered Suggestions
- **Double TAB (`<TAB><TAB>`)** triggers LLM-powered completions
- Natural language to command translation
- Context-aware suggestions based on current state

### 2. Context-Aware Intelligence
Considers:
- Terminal environment (pwd, user, OS, shell)
- Recent command history (last 20 commands by default)
- Current directory contents
- Command-specific `--help` information
- Environment variables

### 3. Multi-LLM Support

**Supported Providers:**
- **OpenAI:** gpt-4o, gpt-4o-mini, o1, o1-mini, o3-mini
- **Anthropic (Claude):** claude-3-7-sonnet, claude-3-5-sonnet, claude-3-5-haiku
- **Groq:** llama3-8b, llama3-70b, llama-3.3-70b-versatile, mixtral-8x7b, gemma2-9b, qwen-2.5-coder, deepseek-r1-distill
- **Ollama:** Local models (codellama, etc.) - **zero cost, privacy-focused**

**Cost Range:** Free (Groq/Ollama) to ~$0.01/1K completions (GPT-4o)

### 4. Privacy & Security

**Prompt Sanitization:**
- Automatically redacts long hex sequences (hashes)
- Redacts UUIDs
- Redacts API-key-like tokens (16-40 character alphanumeric strings)
- Pattern: `s/\b[A-Za-z0-9]{16,40}\b/REDACTED_APIKEY/g`

**Local LLM Support:**
- Use Ollama for fully local, private completions
- No data leaves your machine
- Zero API costs

### 5. Performance Optimizations
- **Caching:** Recent queries cached for speed
- **Cost Tracking:** Monitors API call sizes and estimated costs
- **Configurable Limits:** Control history depth, file listing, etc.

### 6. Flexible Configuration
- Interactive configuration UI
- Model selection menu
- Per-setting updates
- Usage tracking and statistics

---

## Installation

### Quick Install (Recommended)

**Bash:**
```bash
wget -qO- https://autocomplete.sh/install.sh | bash
```

**Or manual:**
```bash
# Download install script
wget https://autocomplete.sh/install.sh

# Review script (always review before running!)
cat install.sh

# Install
bash install.sh
```

### What the Installer Does:
1. Downloads `autocomplete.sh` script to `~/.local/bin/autocomplete`
2. Adds sourcing line to `~/.bashrc` or `~/.zshrc`
3. Creates config directory at `~/.config/autocomplete/`
4. Prompts for API key configuration

### Manual Installation (For Control)

```bash
# Clone repository
git clone https://github.com/closedloop-technologies/autocomplete-sh.git
cd autocomplete-sh

# Create symlink
ln -s $PWD/autocomplete.sh $HOME/.local/bin/autocomplete

# Source the completion script
. autocomplete.sh install

# Or add to ~/.bashrc
echo '. ~/.local/bin/autocomplete install' >> ~/.bashrc
source ~/.bashrc
```

---

## Configuration

### Configuration File

**Location:** `~/.config/autocomplete/config`

**View Current Config:**
```bash
source autocomplete config
```

**Update Settings:**
```bash
autocomplete config set <key> <value>
```

### Key Configuration Options

| Setting | Description | Default | Values |
|---------|-------------|---------|--------|
| `model` | LLM model to use | `gpt-4o-mini` | See [Supported Models](https://autocomplete.sh/#supported-models) |
| `ACSH_MAX_HISTORY_COMMANDS` | Recent commands to include | `20` | Integer (1-100) |
| `ACSH_MAX_RECENT_FILES` | Recent files to list | `20` | Integer (1-50) |
| `ACSH_CACHE_TTL` | Cache time-to-live | `3600` | Seconds |
| `ACSH_ENABLE_SANITIZATION` | Redact sensitive data | `true` | `true`/`false` |

---

## API Key Management

### Supported Methods

**1. Environment Variables (Recommended for `.bashrc`)**

```bash
# OpenAI
export OPENAI_API_KEY="sk-..."

# Anthropic (Claude)
export ANTHROPIC_API_KEY="sk-ant-..."

# Groq
export GROQ_API_KEY="gsk_..."

# Add to ~/.bashrc for persistence
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.bashrc
source ~/.bashrc
```

**2. Interactive Setup (Installer)**

The installer prompts for API keys during installation and stores them in your shell profile.

**3. KeePassXC Integration (Secure, Recommended)**

Using `secret-tool` (GNOME Keyring) or KeePassXC CLI:

**Option A: secret-tool (GNOME Keyring)**
```bash
# Store API key in keyring
secret-tool store --label="OpenAI API Key" service openai key apikey

# Retrieve in ~/.bashrc
export OPENAI_API_KEY=$(secret-tool lookup service openai key apikey)
```

**Option B: KeePassXC CLI via chezmoi template**

In `~/.bashrc.tmpl` (managed by chezmoi):
```bash
# Autocomplete.sh API keys from KeePassXC
{{- if (lookPath "keepassxc-cli") }}
export OPENAI_API_KEY="{{ (keepassxc "OpenAI").Password }}"
export ANTHROPIC_API_KEY="{{ (keepassxc "Anthropic API").Password }}"
{{- end }}
```

**Option C: KeePassXC Browser Integration (keeenv)**

Using [keeenv](https://github.com/scross01/keeenv):

Create `.keeenv` file:
```ini
[keepass]
database=/path/to/secrets.kdbx
keyfile=/path/to/keyfile  # optional

[env]
OPENAI_API_KEY = ${"OpenAI"."API Key"}
ANTHROPIC_API_KEY = ${"Anthropic"."API Key"}
```

Then use:
```bash
keeenv run autocomplete command "your command here"
```

**4. Ollama (No API Key Needed)**

For privacy-focused local LLMs:
```bash
# Install Ollama
curl https://ollama.ai/install.sh | sh

# Pull a model
ollama pull codellama

# Configure autocomplete.sh to use Ollama
autocomplete model
# Select: ollama: codellama

# No API key required!
```

---

## Usage

### Basic Usage

**Trigger Completions:**
```bash
# Type your command (partial or natural language)
git push

# Press TAB TAB to get AI suggestions
<TAB><TAB>

# Select from suggestions or continue typing
```

### Advanced Usage

**Natural Language Commands:**
```bash
# Type a natural language description
# reformat video to fit youtube

# Press TAB TAB
<TAB><TAB>

# Autocomplete.sh suggests:
# ffmpeg -i input.mp4 -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" -c:a copy output.mp4
```

**Complex Workflows:**
```bash
# create a github repo, init a readme, and push it
<TAB><TAB>

# Autocomplete.sh suggests multi-command chain:
# gh repo create my-repo --public && cd my-repo && echo "# My Repo" > README.md && git add . && git commit -m "Initial commit" && git push
```

### Command Reference

**Model Selection:**
```bash
autocomplete model
```
- Interactive menu to select LLM provider and model
- Shows cost per 1K tokens for each model
- Ollama models marked as "FREE"

**Configuration:**
```bash
# View config
source autocomplete config

# Update setting
autocomplete config set ACSH_MAX_HISTORY_COMMANDS 30
```

**Usage Statistics:**
```bash
autocomplete usage
```
- Shows API call counts
- Estimated costs
- Token usage
- Cache hit rate

**Dry Run (Test Prompt):**
```bash
autocomplete command --dry-run "your command here"
```
- Shows the exact prompt sent to the LLM
- Useful for debugging and understanding context

**System Info:**
```bash
autocomplete sysinfo
```
- Shows OS, shell, terminal details
- Machine signature (for caching)

---

## Integration with Kitty Terminal

### Why Kitty + Autocomplete.sh?

**Benefits:**
- **GPU Acceleration:** Kitty's fast rendering complements quick AI suggestions
- **Ligature Support:** Clean display of suggestion arrows and icons
- **Font Rendering:** Excellent for code-heavy completions
- **Copy/Paste:** Easy to select and copy suggested commands

### Setup for Kitty

**1. Install autocomplete.sh** (see [Installation](https://autocomplete.sh/#installation))

**2. Configure in `~/.bashrc` (managed via chezmoi)**

**File:** `dotfiles/dot_bashrc.tmpl`

```bash
# ============ Autocomplete.sh - AI Command Completion ============
{{- if (lookPath "autocomplete") }}

# API Keys from KeePassXC (secure method)
{{- if (lookPath "secret-tool") }}
export OPENAI_API_KEY=$(secret-tool lookup service openai key apikey 2>/dev/null)
export ANTHROPIC_API_KEY=$(secret-tool lookup service anthropic key apikey 2>/dev/null)
{{- end }}

# Source autocomplete.sh
if [ -f ~/.local/bin/autocomplete ]; then
    . ~/.local/bin/autocomplete install
fi

# Optional: Set preferred model
export ACSH_MODEL="gpt-4o-mini"  # Fast and cheap

# Optional: Configuration
export ACSH_MAX_HISTORY_COMMANDS=20
export ACSH_ENABLE_SANITIZATION=true

{{- end }}
```

**3. Apply via chezmoi**
```bash
chezmoi apply
source ~/.bashrc
```

### Kitty-Specific Enhancements

**Kitty Actions for Autocomplete:**

Add to `~/.config/kitty/kitty.conf`:
```conf
# Quick access to autocomplete usage stats
map ctrl+shift+a>u launch --type=overlay autocomplete usage

# Quick access to model selection
map ctrl+shift+a>m launch --type=overlay autocomplete model

# Quick access to config
map ctrl+shift+a>c launch --type=overlay autocomplete config
```

**Kitty Hints for Suggested Commands:**

Use kitty's `hints` kitten to quickly select autocomplete suggestions:
```conf
# Press Ctrl+Shift+H to activate hints for command selection
map ctrl+shift+h kitten hints --type=line --program=@
```

---

## Tips & Best Practices

### 1. Use Descriptive Comments for Better Suggestions

```bash
# Install dependencies and start development server
<TAB><TAB>

# Better than just:
npm
<TAB><TAB>
```

### 2. Leverage Natural Language

```bash
# find all python files modified in the last 24 hours
<TAB><TAB>

# Suggests:
# find . -name "*.py" -mtime -1
```

### 3. Cost Optimization

**Use cheaper models for simple tasks:**
```bash
# For simple commands: gpt-4o-mini or Groq (free)
autocomplete config set model gpt-4o-mini

# For complex workflows: gpt-4o or claude-3-7-sonnet
autocomplete config set model claude-3-7-sonnet
```

**Or use Ollama (free, local):**
```bash
autocomplete model
# Select: ollama: codellama
```

### 4. Privacy Best Practices

**Use local models for sensitive work:**
```bash
# Install Ollama
curl https://ollama.ai/install.sh | sh
ollama pull codellama

# Set as default
autocomplete config set model codellama
```

**Enable sanitization:**
```bash
autocomplete config set ACSH_ENABLE_SANITIZATION true
```

### 5. Combine with Navi for Cheatsheets

Use autocomplete.sh for discovery, navi for reference:
```bash
# Use autocomplete.sh to explore
docker
<TAB><TAB>

# Use navi for specific commands
navi  # Search: docker
```

---

## Troubleshooting

### Issue: "API key not found"

**Solution:**
```bash
# Check if API key is set
echo $OPENAI_API_KEY

# If empty, set it
export OPENAI_API_KEY="sk-..."

# Add to ~/.bashrc
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.bashrc
source ~/.bashrc
```

### Issue: Completions not appearing

**Solution:**
```bash
# Verify installation
which autocomplete

# Re-source bashrc
source ~/.bashrc

# Check if completion is loaded
complete -p | grep autocomplete
```

### Issue: Slow completions

**Solution:**
```bash
# Switch to faster model
autocomplete model
# Select: groq: llama-3.1-8b-instant (FREE and FAST)

# Or reduce context
autocomplete config set ACSH_MAX_HISTORY_COMMANDS 10
```

### Issue: Sanitization too aggressive

**Solution:**
```bash
# Disable sanitization (use with caution!)
autocomplete config set ACSH_ENABLE_SANITIZATION false

# Or use local Ollama model
autocomplete config set model codellama
```

---

## Configuration Examples

### Example 1: Secure Setup with KeePassXC

**`~/.bashrc` snippet:**
```bash
# Autocomplete.sh with KeePassXC integration
if [ -f ~/.local/bin/autocomplete ]; then
    # Get API keys from secret-tool (GNOME Keyring)
    export OPENAI_API_KEY=$(secret-tool lookup service openai key apikey 2>/dev/null)
    export ANTHROPIC_API_KEY=$(secret-tool lookup service anthropic key apikey 2>/dev/null)

    # Source autocomplete
    . ~/.local/bin/autocomplete install

    # Use Claude for better code understanding
    export ACSH_MODEL="claude-3-5-haiku-20241022"
    export ACSH_MAX_HISTORY_COMMANDS=15
    export ACSH_ENABLE_SANITIZATION=true
fi
```

### Example 2: Privacy-Focused Local Setup

**`~/.bashrc` snippet:**
```bash
# Autocomplete.sh with local Ollama (no API, no cloud)
if [ -f ~/.local/bin/autocomplete ]; then
    . ~/.local/bin/autocomplete install

    # Use local Ollama model
    export ACSH_MODEL="codellama"
    export ACSH_MAX_HISTORY_COMMANDS=20

    # No API keys needed!
fi
```

### Example 3: Cost-Optimized Setup

**`~/.bashrc` snippet:**
```bash
# Autocomplete.sh with free Groq models
if [ -f ~/.local/bin/autocomplete ]; then
    export GROQ_API_KEY="gsk_..."  # Free tier
    . ~/.local/bin/autocomplete install

    # Fast and free
    export ACSH_MODEL="llama-3.1-8b-instant"
    export ACSH_MAX_HISTORY_COMMANDS=10  # Less context = faster
fi
```

---

## Related Tools

**Complementary Tools:**
- **navi:** Cheatsheet navigation (autocomplete.sh finds, navi remembers)
- **fzf:** Fuzzy finder (autocomplete.sh suggests, fzf filters)
- **tldr:** Simplified man pages (autocomplete.sh generates, tldr explains)
- **zoxide:** Smart cd (autocomplete.sh navigates, zoxide learns)

---

## Resources

### Official
- **Website:** https://autocomplete.sh/
- **GitHub:** https://github.com/closedloop-technologies/autocomplete-sh
- **Releases:** https://github.com/closedloop-technologies/autocomplete-sh/releases

### Videos
- [Autocomplete.sh - Wake up n00b.... LLMs in the shell](https://www.youtube.com/watch?v=IAgkjerCvz8)
- [How to use bash in 2024](https://www.youtube.com/watch?v=dS1-qh_dxac)

### Community
- **Maintainer:** Sean Kruzel ([@closedloop](https://github.com/closedloop))
- **Company:** ClosedLoop Technologies
- **License:** MIT
- **Support:** [Buy Me A Coffee](https://www.buymeacoffee.com/skruzel)

---

**Last Updated:** 2025-11-30
**Maintained By:** Dimitris Tsioumas (Mitsio)
