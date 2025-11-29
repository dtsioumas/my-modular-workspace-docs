# Continue.dev - AI Code Assistant Guide

**Last Updated:** 2025-11-29
**Sources Merged:** README.md, INSTALLATION.md, CONFIGURATION.md, API_KEYS.md
**Maintainer:** Mitsos

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [API Key Management](#api-key-management)
- [NixOS Issues & Fixes](#nixos-issues--fixes)
- [References](#references)

---

## Overview

Continue.dev is an open-source AI code assistant extension for VSCodium that provides chat, code editing, autocomplete, and agent capabilities.

### Key Features
- **Multi-Provider Support:** Use Claude Max AND ChatGPT together
- **Chat Interface:** Ask questions, explain code
- **Inline Editing:** Modify code without leaving editor
- **Autocomplete:** AI-powered code completion
- **Prompt Caching:** Reduce API costs (~90% savings)

### Continue.dev vs Claude Code

| Feature | Continue.dev | Claude Code |
|---------|--------------|-------------|
| Type | IDE Extension | CLI Tool |
| Interface | Visual sidebar | Terminal TUI |
| Providers | Multiple | Anthropic only |
| Installation | VSCodium extension | npm package |

**They are complementary tools - use both!**

---

## Installation

### Method 1: Manual VSIX (Recommended for NixOS)

```bash
# Download latest release
wget https://github.com/continuedev/continue/releases/latest/download/continue-vscode.vsix

# Install in VSCodium
codium --install-extension continue-vscode.vsix

# Verify
codium --list-extensions | grep Continue
```

### Verification

1. Extension appears in `codium --list-extensions`
2. Continue icon visible in sidebar
3. Sidebar panel opens when clicked

---

## Configuration

**Config Location:** `~/.continue/config.yaml`

### Dual-Provider Setup (Claude + OpenAI)

```yaml
name: mitsio-dev-config
version: 1.0.0

models:
  # PRIMARY: Claude 4 Sonnet
  - name: Claude 4 Sonnet
    provider: anthropic
    model: claude-sonnet-4-20250514
    apiKey: ${ANTHROPIC_API_KEY}
    roles: [chat, edit, apply]
    defaultCompletionOptions:
      temperature: 0.7
      maxTokens: 8192
      promptCaching: true  # CRITICAL: 90% cost savings!

  # FALLBACK: GPT-4o
  - name: GPT-4o
    provider: openai
    model: gpt-4o
    apiKey: ${OPENAI_API_KEY}
    roles: [chat]

  # AUTOCOMPLETE: Claude Haiku (fast/cheap)
  - name: Claude Haiku
    provider: anthropic
    model: claude-3-5-haiku-20241022
    apiKey: ${ANTHROPIC_API_KEY}
    roles: [autocomplete]
    defaultCompletionOptions:
      temperature: 0.2
      maxTokens: 1024

  # EMBEDDINGS: OpenAI
  - name: OpenAI Embeddings
    provider: openai
    model: text-embedding-3-small
    apiKey: ${OPENAI_API_KEY}
    roles: [embed]

context:
  - uses: file
  - uses: code
  - uses: codebase
  - uses: terminal
  - uses: git-diff
```

### Model Roles

| Role | Purpose | Recommended |
|------|---------|-------------|
| chat | Conversational Q&A | Claude 4 Sonnet |
| edit | Code modifications | Claude 4 Sonnet |
| autocomplete | Code completion | Claude Haiku |
| embed | Codebase search | OpenAI embeddings |

### Minimal Quick Start

```yaml
models:
  - name: Claude 4 Sonnet
    provider: anthropic
    model: claude-sonnet-4-20250514
    apiKey: ${ANTHROPIC_API_KEY}
    defaultCompletionOptions:
      promptCaching: true
```

---

## API Key Management

### Required Keys

| Provider | Console | Format |
|----------|---------|--------|
| Anthropic | console.anthropic.com | `sk-ant-api03-xxx` |
| OpenAI | platform.openai.com | `sk-xxx` |

### Storage Options

**Option 1: KeePassXC (Recommended)**

Store in KeePassXC under `Development/APIs/`:
- Entry: "Anthropic API - Claude Max"
- Entry: "OpenAI API - ChatGPT"

**Option 2: Environment File**

```bash
# ~/.config/continue/secrets.env
export ANTHROPIC_API_KEY="sk-ant-xxx"
export OPENAI_API_KEY="sk-xxx"
```

```bash
chmod 600 ~/.config/continue/secrets.env
# Add to ~/.bashrc:
source ~/.config/continue/secrets.env
```

**Option 3: Shell Export**

```bash
export ANTHROPIC_API_KEY="sk-ant-xxx"
export OPENAI_API_KEY="sk-xxx"
codium  # Launch from same terminal
```

### Test API Keys

```bash
# Test Anthropic
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 10, "messages": [{"role": "user", "content": "test"}]}'

# Test OpenAI
curl https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt-4o", "messages": [{"role": "user", "content": "test"}], "max_tokens": 10}'
```

---

## NixOS Issues & Fixes

### Issue: Extension Fails to Activate

**Cause:** Missing dynamic libraries in NixOS

**Solution: FHS Wrapper**

```nix
let
  vscodiumFHS = pkgs.buildFHSUserEnv {
    name = "vscodium-fhs";
    targetPkgs = pkgs: with pkgs; [
      vscodium
      stdenv.cc.cc.lib
      zlib
      libGL
    ];
    runScript = "codium";
  };
in {
  home.packages = [ vscodiumFHS ];
}
```

Use `vscodium-fhs` instead of `codium`.

### Issue: Keys Work in CLI but Not Continue

**Cause:** VSCodium doesn't inherit shell variables

**Solutions:**
1. Launch from terminal after exporting
2. Use systemd user environment
3. Source secrets before launching

```bash
# Launch with keys
export ANTHROPIC_API_KEY="xxx"
codium
```

---

## Home-Manager Integration

```nix
# continue-dev.nix
{ config, lib, pkgs, ... }:

{
  home.file.".continue/config.yaml".text = ''
    models:
      - name: Claude 4 Sonnet
        provider: anthropic
        model: claude-sonnet-4-20250514
        apiKey: ''${ANTHROPIC_API_KEY}
        defaultCompletionOptions:
          promptCaching: true
  '';

  home.activation.install-continue-dev = lib.hm.dag.entryAfter ["writeBoundary"] ''
    VSIX_URL="https://github.com/continuedev/continue/releases/latest/download/continue-vscode.vsix"
    VSIX_FILE="$HOME/.cache/continue-dev/continue.vsix"
    mkdir -p $HOME/.cache/continue-dev
    if [ ! -f "$VSIX_FILE" ]; then
      ${pkgs.wget}/bin/wget -O "$VSIX_FILE" "$VSIX_URL"
      ${pkgs.vscodium}/bin/codium --install-extension "$VSIX_FILE"
    fi
  '';
}
```

---

## Cost Optimization

1. **Enable prompt caching** - ~90% savings on Claude
2. **Use Haiku for autocomplete** - Much cheaper than Sonnet
3. **Limit maxTokens** - Set appropriate limits
4. **Monitor usage** - Check console dashboards

---

## References

- **GitHub:** https://github.com/continuedev/continue
- **Documentation:** https://docs.continue.dev/
- **Releases:** https://github.com/continuedev/continue/releases
- **Discord:** https://discord.gg/NWtdYexhMs

---

*Migrated from docs/commons/tools/continue.dev/ on 2025-11-29*
