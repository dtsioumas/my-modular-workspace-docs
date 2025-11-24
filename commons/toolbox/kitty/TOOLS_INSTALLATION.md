# CLI Tools Installation Guide

**For:** shoshin NixOS Desktop  
**Date:** 2025-11-05  
**Tools:** navi, direnv, llm-cli, tealdeer

---

## Summary

| Tool | Latest Version | In Nixpkgs? | Method |
|------|----------------|-------------|--------|
| **navi** | v2.24.0 (Jan 2025) | Yes | `pkgs.navi` |
| **direnv** | v2.37.1 (July 2025) | Yes | `pkgs.direnv` |
| **llm-cli** | Latest (datasette) | Yes (Python) | `pkgs.python3Packages.llm` |
| **tealdeer** | v1.8.0 | Yes | `pkgs.tealdeer` |

**Status:** ✅ All tools available in nixpkgs! No flakes needed.

---

## Installation Methods

### Option 1: System-Wide (NixOS Configuration)

Add to your `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  navi        # Interactive cheatsheet tool
  direnv      # Environment switcher for shells
  tealdeer    # Fast tldr client in Rust
  
  # For llm-cli (Python tool)
  (python3.withPackages (ps: with ps; [
    llm
  ]))
];

# Enable direnv integration
programs.direnv.enable = true;
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

### Option 2: User-Level (home-manager)

Add to your home-manager config:

```nix
home.packages = with pkgs; [
  navi
  direnv  
  tealdeer
];

programs.direnv = {
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  nix-direnv.enable = true;
};

# For llm-cli
home.packages = [
  (pkgs.python3.withPackages (ps: [ ps.llm ]))
];
```

### Option 3: Temporary Testing

Test before installing:

```bash
# Try navi
nix-shell -p navi --run "navi --help"

# Try direnv  
nix-shell -p direnv --run "direnv --version"

# Try tealdeer
nix-shell -p tealdeer --run "tldr ls"

# Try llm-cli
nix-shell -p 'python3.withPackages (ps: [ps.llm])' --run "llm --help"
```

---

## Tool Descriptions & Basic Usage

### 1. **navi** - Interactive Cheatsheet Tool

**Purpose:** Browse and execute command-line cheatsheets interactively.

**Basic Setup:**

```bash
# First run - downloads cheatsheets
navi

# Shell widget (add to ~/.bashrc or ~/.zshrc)
eval "$(navi widget bash)"  # For bash
eval "$(navi widget zsh)"   # For zsh

# Use with Ctrl+G shortcut after setup
```

**Usage Examples:**

```bash
# Browse all cheatsheets
navi

# Search for specific command
navi --query "git"

# Best practices mode
navi --path /path/to/your/cheats
```

**Create Custom Cheatsheets:**

```bash
# Location: ~/.local/share/navi/cheats/
mkdir -p ~/.local/share/navi/cheats/custom

# Create a cheat file: custom.cheat
% git, version control

# Create a new branch and switch to it
git checkout -b <branch_name>

$ branch_name: git branch | awk '{print $NF}'
```

---

### 2. **direnv** - Environment Switcher

**Purpose:** Automatically load/unload environment variables based on directory.

**Basic Setup:**

```bash
# Add to ~/.bashrc
eval "$(direnv hook bash)"

# Add to ~/.zshrc
eval "$(direnv hook zsh)"
```

**Usage Examples:**

```bash
# Create .envrc in project directory
cd ~/projects/myapp
echo 'export DATABASE_URL="postgresql://localhost/mydb"' > .envrc

# Allow the .envrc
direnv allow

# Variables are now loaded when entering directory!
cd ~/projects/myapp  # DATABASE_URL is set
cd ~                  # DATABASE_URL is unset
```

**Common Patterns:**

```bash
# Python virtualenv
echo 'layout python' > .envrc
direnv allow

# Node.js version
echo 'use node 18' > .envrc
direnv allow

# Load .env file
echo 'dotenv' > .envrc
direnv allow
```

**NixOS Integration:**

```bash
# Use nix-shell in project
echo 'use nix' > .envrc
direnv allow

# Now nix environment loads automatically!
```

---

### 3. **llm-cli** - LLM Command-Line Tool

**Purpose:** Access LLMs (ChatGPT, Claude, local models) from command line.

**Setup:**

```bash
# Install via pip (or use NixOS package)
llm install llm

# Configure API keys
llm keys set openai
# Enter your OpenAI API key

llm keys set anthropic
# Enter your Anthropic API key
```

**Usage Examples:**

```bash
# Ask a question
llm "What is the capital of France?"

# Use specific model
llm -m gpt-4 "Explain quantum computing"
llm -m claude-3-opus "Write a poem"

# Pipe input
cat file.txt | llm "Summarize this"

# Save conversation
llm "Hello" -c myconv
llm "Tell me more" -c myconv  # Continues conversation

# List conversations
llm logs

# Use templates
llm -t summarize < document.txt
```

**Install Plugins:**

```bash
# List available plugins
llm plugins

# Install a plugin
llm install llm-gpt4all  # For local models
```

---

### 4. **tealdeer (tldr)** - Fast Man Pages

**Purpose:** Fast, community-driven man pages with practical examples.

**Setup:**

```bash
# Update cache (first time)
tldr --update

# Enable auto-updates (optional)
tldr --seed-config  # Creates ~/.config/tealdeer/config.toml
```

**Usage Examples:**

```bash
# Get help for a command
tldr tar
tldr git-commit
tldr docker

# List all pages
tldr --list

# Search
tldr --list | grep ssh

# Platform-specific
tldr -p linux ls
tldr -p osx ls

# Clear cache and update
tldr --clear-cache
tldr --update
```

**Configuration (~/.config/tealdeer/config.toml):**

```toml
[updates]
auto_update = true
auto_update_interval_hours = 720  # 30 days

[display]
compact = false
use_pager = false

[style.command_name]
foreground = "green"
bold = true
```

---

## Post-Installation Setup

### 1. Shell Integration

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Navi widget (Ctrl+G)
eval "$(navi widget bash)"  # or zsh

# Direnv
eval "$(direnv hook bash)"  # or zsh

# Tealdeer auto-completion
source <(tldr --gen-completion bash)  # or zsh
```

Then reload your shell:

```bash
exec $SHELL
```

### 2. Update Tealdeer Cache

```bash
tldr --update
```

### 3. Setup Navi Cheatsheets

```bash
# Browse and add cheatsheets
navi repo browse

# Add featured cheatsheets
navi repo add denisidoro/cheats
```

### 4. Configure LLM

```bash
# Set default model
llm models default gpt-4

# Or use environment variable
export LLM_DEFAULT_MODEL="gpt-4"
```

---

## Verification

Test each tool:

```bash
# Navi
navi --version

# Direnv
direnv --version

# Tealdeer
tldr --version

# LLM
llm --version

# Quick functionality test
tldr ls          # Should show ls examples
navi --query git # Should show git cheats
```

---

## Troubleshooting

### Navi: "No cheats found"

```bash
# Download cheatsheets
navi repo browse
```

### Direnv: Not loading .envrc

```bash
# Make sure hook is in shell config
eval "$(direnv hook bash)"

# Allow the .envrc
direnv allow
```

### Tealdeer: Cache errors

```bash
# Clear and rebuild cache
tldr --clear-cache
tldr --update
```

### LLM: API key issues

```bash
# Re-configure keys
llm keys set openai
llm keys set anthropic

# Check configuration
llm keys list
```

---

## Additional Resources

- **Navi:**
  - GitHub: https://github.com/denisidoro/navi
  - Cheatsheets: https://github.com/denisidoro/cheats

- **Direnv:**
  - Official Site: https://direnv.net/
  - Wiki: https://github.com/direnv/direnv/wiki

- **LLM:**
  - Documentation: https://llm.datasette.io/
  - Plugins: https://llm.datasette.io/en/stable/plugins/

- **Tealdeer:**
  - Documentation: https://tealdeer-rs.github.io/tealdeer/
  - TLDR Pages: https://tldr.sh/

---

## Integration Example

Combine all tools in a workflow:

```bash
# 1. Use direnv to set project environment
cd ~/projects/myapp
echo 'export API_KEY="secret"' > .envrc
direnv allow

# 2. Use tldr for quick command reference
tldr docker-compose

# 3. Use navi for complex commands
navi --query "docker network"

# 4. Use llm for documentation
cat README.md | llm "Explain this project structure"
```

---

**Installation Status:** ✅ Ready to install  
**NixOS Method:** Recommended (declarative, reproducible)  
**Created:** 2025-11-05  
**For:** shoshin desktop
