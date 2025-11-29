# LLM Terminal Tools Documentation

**Created:** 2025-11-07
**System:** Windows 11 + WSL2 Ubuntu
**Purpose:** Command-line tools for LLM interaction, command cheatsheets, and navigation

---

## Table of Contents

1. [Simon Willison's LLM Tool](#simon-willisons-llm-tool)
2. [Navi - Interactive Cheatsheet](#navi---interactive-cheatsheet)
3. [Tealdeer/TLDR - Quick Command Reference](#tealdeerτldr---quick-command-reference)
4. [Claude Code CLI](#claude-code-cli)
5. [Installation Commands](#installation-commands)
6. [Configuration](#configuration)
7. [References](#references)

---

## Simon Willison's LLM Tool

### Overview

**Repository:** https://github.com/simonw/llm
**Description:** Access large language models from the command-line
**Author:** Simon Willison
**Latest Version:** 0.27 (2025)

### Features

- ✅ Access multiple LLM providers (OpenAI, Anthropic, Google, etc.)
- ✅ Plugin system for extensibility
- ✅ Tool calling support (v0.26+)
- ✅ Self-hosted model support
- ✅ Conversation history
- ✅ System prompts
- ✅ Template system

### Installation

**Method 1: pip (Recommended για Ubuntu/WSL)**
```bash
pip install llm
```

**Method 2: pipx (Isolated environment)**
```bash
pipx install llm
```

**Method 3: uv tool (Modern Python tool runner)**
```bash
uv tool install llm
```

### Upgrade

```bash
pip install -U llm
```

### Basic Usage

```bash
# Simple query
llm "What is the capital of Greece?"

# With system prompt
llm -s "You are a Python expert" "Explain list comprehensions"

# Using specific model
llm -m gpt-4o "Complex question here"

# Continue conversation
llm --continue "Follow-up question"
```

### Plugin Installation

```bash
# Anthropic Claude
llm install llm-anthropic

# Google Gemini
llm install llm-gemini

# Local models
llm install llm-gpt4all
```

### Configuration

```bash
# Set API key
llm keys set openai

# List available models
llm models list

# Set default model
llm models default gpt-4o
```

---

## Navi - Interactive Cheatsheet

### Overview

**Repository:** https://github.com/denisidoro/navi
**Description:** Interactive cheatsheet tool for the command-line
**Written in:** Rust

### Features

- ✅ Interactive fuzzy finder
- ✅ Community cheatsheets
- ✅ Custom cheatsheets
- ✅ Shell integration
- ✅ Variable interpolation
- ✅ Tldr integration (with tealdeer)

### Installation

**Ubuntu/Debian:**
```bash
# Using cargo
cargo install navi

# Or download binary από releases
curl -L https://github.com/denisidoro/navi/releases/latest/download/navi-x86_64-unknown-linux-musl.tar.gz | tar xz
sudo mv navi /usr/local/bin/
```

**Homebrew (macOS/Linux):**
```bash
brew install navi
```

### Basic Usage

```bash
# Launch navi
navi

# Search for specific command
navi --query "git"

# Best match for query
navi --best-match

# Preview without executing
navi --print
```

### Shell Integration

**Bash:**
```bash
# Add to ~/.bashrc
eval "$(navi widget bash)"

# Then use Ctrl+G to open navi
```

**Zsh:**
```zsh
# Add to ~/.zshrc
eval "$(navi widget zsh)"
```

### Custom Cheatsheets

Create files in `~/.local/share/navi/cheats/`:

```bash
# Example cheatsheet
% git, version control

# Commit changes
git commit -m "<message>"

# Push to remote
git push origin <branch>

$ branch: git branch --list | awk '{print $NF}'
```

---

## Tealdeer/TLDR - Quick Command Reference

### Overview

**Tealdeer Repository:** https://github.com/dbrgn/tealdeer
**TLDR Pages:** https://tldr.sh/
**Description:** Fast Rust implementation of tldr
**Purpose:** Simplified, community-driven man pages

### Tealdeer vs TLDR Clients

**Tealdeer (Recommended):**
- ✅ Written in Rust (fast)
- ✅ Local caching
- ✅ Offline support
- ✅ Single binary
- ✅ Auto-updates

**Traditional tldr clients:**
- Node.js client (npm)
- Python client (pip)
- Slower, more dependencies

### Installation

**Ubuntu/Debian:**
```bash
# From apt
sudo apt install tealdeer

# Or download binary
wget https://github.com/dbrgn/tealdeer/releases/latest/download/tealdeer-linux-x86_64-musl
chmod +x tealdeer-linux-x86_64-musl
sudo mv tealdeer-linux-x86_64-musl /usr/local/bin/tldr
```

**Using cargo:**
```bash
cargo install tealdeer
```

### Initial Setup

```bash
# Update cache
tldr --update

# List all pages
tldr --list
```

### Basic Usage

```bash
# Get help για command
tldr git

# Search pages
tldr --list | grep docker

# Show raw markdown
tldr --raw curl

# Specify platform
tldr --platform linux systemctl
```

### Configuration

**Config file:** `~/.config/tealdeer/config.toml`

```toml
[display]
compact = false
use_pager = false

[style.command_name]
foreground = "cyan"
bold = true

[updates]
auto_update = true
auto_update_interval_hours = 720  # 30 days
```

### Comparison: Tealdeer vs Navi

| Feature | Tealdeer | Navi |
|---------|----------|------|
| **Purpose** | Quick reference | Interactive cheatsheets |
| **Interaction** | Static pages | Fuzzy finder |
| **Customization** | Limited | Extensive |
| **Speed** | Very fast | Fast |
| **Use case** | Quick syntax lookup | Complex commands με variables |
| **Learning curve** | Easy | Moderate |

**Recommendation:** Use both!
- **Tealdeer** για quick syntax lookups
- **Navi** για complex workflows and custom commands

---

## Claude Code CLI

### Overview

**Official Docs:** https://docs.claude.com/en/docs/claude-code/setup
**Description:** Official CLI for Claude AI
**Requirements:** Ubuntu 20.04+, active billing at console.anthropic.com

### Installation

**Stable Version:**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Latest Version:**
```bash
curl -fsSL https://claude.ai/install.sh | bash -s latest
```

**NPM Install (Alternative):**
```bash
npm install -g @anthropic/claude-code
```

### Authentication

```bash
# Connect through Claude Console
claude auth

# OAuth process opens browser
# Requires active billing
```

### Verification

```bash
# Check installation
claude doctor

# Show version
claude --version
```

### Basic Usage

```bash
# Start Claude Code
claude code

# With specific file
claude code --file myfile.py

# With prompt
claude code --prompt "Refactor this code"
```

### WSL2 Considerations

**Best Practices:**
- Work in Linux filesystem (`~/`) not Windows mounts (`/mnt/c/`)
- Configure memory limits in `.wslconfig`
- Use WSL2 (not WSL1) για best performance

**Memory Limit Config** (`C:\Users\<user>\.wslconfig`):
```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
```

---

## Installation Commands

### All Tools Installation Script

```bash
#!/bin/bash
# Install all LLM terminal tools

# Update system
sudo apt update && sudo apt upgrade -y

# Install Python tools
pip install llm
pip install -U llm

# Install Tealdeer
sudo apt install tealdeer -y
tldr --update

# Install Navi (using cargo)
# First install rust if not present
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
cargo install navi

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Verify installations
echo "=== Installed Versions ==="
llm --version
tldr --version
navi --version
claude --version

# Update caches
tldr --update
navi repo browse
```

### Individual Installations

```bash
# LLM Tool
pip install llm

# Tealdeer
sudo apt install tealdeer && tldr --update

# Navi
cargo install navi

# Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash
```

---

## Configuration

### LLM Tool Configuration

**Config file:** `~/.config/io.datasette.llm/`

```bash
# Set OpenAI key
llm keys set openai
# Enter key: sk-...

# Set Anthropic key
llm keys set anthropic
# Enter key: sk-ant-...

# Set default model
llm models default claude-sonnet-4
```

### Navi Configuration

**Cheatsheets location:** `~/.local/share/navi/cheats/`

**Add shell widget to ~/.bashrc:**
```bash
# Navi widget (Ctrl+G)
eval "$(navi widget bash)"
```

### Tealdeer Configuration

**Config:** `~/.config/tealdeer/config.toml`

```toml
[display]
compact = false
use_pager = false

[style]
description.foreground = "white"
command_name.foreground = "cyan"
command_name.bold = true
example_text.foreground = "green"

[updates]
auto_update = true
auto_update_interval_hours = 720
```

---

## Workflow Integration

### Combined Usage Examples

**1. Learn Command με Tealdeer:**
```bash
tldr docker
```

**2. Find Complex Command με Navi:**
```bash
navi --query "docker compose"
# Select and customize από fuzzy finder
```

**3. Ask LLM για Explanation:**
```bash
llm "Explain: $(navi --best-match --query 'docker volume')"
```

**4. Get Code Review από Claude:**
```bash
claude code --file script.py --prompt "Review this script"
```

### Bash Aliases

Add to `~/.bashrc`:

```bash
# Quick LLM queries
alias ask='llm'
alias claude='claude code'

# Quick reference
alias cheat='navi'
alias help='tldr'

# Combined workflow
explain() {
    tldr "$1" && llm "Explain $1 command in simple terms"
}
```

---

## References

### Documentation Links

**LLM Tool:**
- GitHub: https://github.com/simonw/llm
- Setup Docs: https://github.com/simonw/llm/blob/main/docs/setup.md
- Blog: https://simonwillison.net/

**Navi:**
- GitHub: https://github.com/denisidoro/navi
- Cheatsheet Format: https://github.com/denisidoro/navi/blob/master/docs/cheatsheet_syntax.md

**Tealdeer:**
- GitHub: https://github.com/dbrgn/tealdeer
- Installation: https://lindevs.com/install-tealdeer-on-ubuntu
- TLDR Pages: https://tldr.sh/

**Claude Code:**
- Setup Docs: https://docs.claude.com/en/docs/claude-code/setup
- Installation Guide: https://claudelog.com/installation/

### Community Resources

- **TLDR Pages Repository:** https://github.com/tldr-pages/tldr
- **Navi Cheatsheets:** https://github.com/denisidoro/navi/tree/master/cheats
- **LLM Plugins:** https://llm.datasette.io/en/stable/plugins/directory.html

---

## Troubleshooting

### LLM Tool Issues

**Missing API Keys:**
```bash
llm keys list  # Check configured keys
llm keys set <provider>  # Add missing key
```

**Plugin Errors:**
```bash
pip install -U llm  # Update to latest
llm plugins list  # Check installed plugins
```

### Navi Issues

**Cheatsheets Not Found:**
```bash
# Update cheatsheets
navi repo browse

# Or clone manually
git clone https://github.com/denisidoro/cheats ~/.local/share/navi/cheats/denisidoro
```

### Tealdeer Issues

**Cache Not Updated:**
```bash
# Force update
tldr --update

# Clear και rebuild cache
rm -rf ~/.cache/tealdeer
tldr --update
```

### Claude Code Issues

**Authentication Failed:**
```bash
# Re-authenticate
claude auth

# Check billing
# Visit: https://console.anthropic.com/
```

---

## Next Steps

1. **Install all tools** using script above
2. **Configure API keys** για LLM tool
3. **Update caches** (tldr, navi)
4. **Add shell aliases** to ~/.bashrc
5. **Create custom navi cheatsheets**
6. **Test workflow integration**

---

**Last Updated:** 2025-11-07
**Maintainer:** Dimitris Tsioumas (dtsioumas0@gmail.com)
