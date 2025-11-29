# Continue.dev - AI Code Assistant for VSCodium

**Status:** Research Complete | Installation Pending
**Last Updated:** 2025-11-26
**Target Environment:** VSCodium on NixOS 25.05 (shoshin workspace)

---

## Overview

Continue.dev is an open-source AI code assistant extension for IDEs that provides chat, code editing, autocomplete, and agent capabilities. Unlike Claude Code (Anthropic's CLI tool), Continue.dev is an IDE extension that can use **multiple AI providers** including Claude (Anthropic) and OpenAI simultaneously.

### Key Features

- **Multi-Provider Support:** Use Claude Max AND ChatGPT subscriptions together
- **Chat Interface:** Ask questions, explain code, get suggestions
- **Inline Editing:** Modify code without leaving the editor
- **Autocomplete:** AI-powered code completion
- **Agent Mode:** Autonomous task execution
- **Prompt Caching:** Reduce API costs with Claude's caching feature

---

## Architecture

```
Continue.dev Extension (VSCodium)
    ├── Configuration (~/.continue/config.yaml)
    ├── API Keys (Environment Variables / KeePassXC)
    ├── Model Providers
    │   ├── Anthropic (Claude Max)
    │   │   ├── Claude 4 Sonnet (chat, edit)
    │   │   ├── Claude 3.7 Sonnet (thinking)
    │   │   └── Claude Haiku (autocomplete - fast)
    │   └── OpenAI (ChatGPT Plus)
    │       ├── GPT-4o (chat, fallback)
    │       └── GPT-4 Turbo (optional)
    └── Context Providers
        ├── File context
        ├── Codebase search
        └── Custom docs
```

---

## Important Distinctions

### Continue.dev vs Claude Code

| Feature | Continue.dev | Claude Code |
|---------|--------------|-------------|
| **Type** | IDE Extension | CLI Tool |
| **Interface** | Visual sidebar in VSCodium | Terminal TUI |
| **Providers** | Multiple (Claude, OpenAI, etc.) | Anthropic only |
| **Use Case** | In-editor assistance | Command-line agent |
| **Installation** | VSCodium extension | npm global package |
| **Compatibility** | Work together | Work together |

**They are complementary tools** - you can (and should) use both!

---

## Installation Status

- [ ] Download latest VSIX from GitHub releases
- [ ] Install VSIX in VSCodium
- [ ] Create config.yaml with Claude + OpenAI
- [ ] Set up API keys (KeePassXC integration)
- [ ] Enable prompt caching for cost optimization
- [ ] Test all features
- [ ] Create home-manager module for declarative management

---

## Documentation Index

1. **[INSTALLATION.md](./INSTALLATION.md)** - Complete installation guide for NixOS
2. **[CONFIGURATION.md](./CONFIGURATION.md)** - Config.yaml setup and model configuration
3. **[API_KEYS.md](./API_KEYS.md)** - Secure API key management with KeePassXC
4. **[MODELS.md](./MODELS.md)** - Model selection and optimization guide
5. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - NixOS-specific issues and fixes
6. **[PLAN.md](./PLAN.md)** - Complete implementation plan

---

## Quick Start

```bash
# 1. Download latest VSIX
cd ~/Downloads
wget https://github.com/continuedev/continue/releases/latest/download/continue-vscode.vsix

# 2. Install in VSCodium
codium --install-extension continue-vscode.vsix

# 3. Get API keys
# - Anthropic: https://console.anthropic.com/account/keys
# - OpenAI: https://platform.openai.com/account/api-keys

# 4. Configure (see CONFIGURATION.md)
mkdir -p ~/.continue
# Create config.yaml with both providers

# 5. Restart VSCodium
codium
```

---

## Links

- **GitHub:** https://github.com/continuedev/continue
- **Documentation:** https://docs.continue.dev/
- **Releases:** https://github.com/continuedev/continue/releases
- **Discord:** https://discord.gg/NWtdYexhMs
- **VS Marketplace:** https://marketplace.visualstudio.com/items?itemName=Continue.continue
- **Open VSX (VSCodium):** https://open-vsx.org/extension/Continue/continue

---

## Known Issues on NixOS

- **Extension Activation Failures** (Issue #821)
- **Missing Dynamic Libraries**
- **FHS Compatibility Issues**

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for solutions.

---

## Next Steps

1. Read [INSTALLATION.md](./INSTALLATION.md)
2. Follow [PLAN.md](./PLAN.md) for step-by-step execution
3. Configure API keys per [API_KEYS.md](./API_KEYS.md)
4. Optimize model usage per [MODELS.md](./MODELS.md)
