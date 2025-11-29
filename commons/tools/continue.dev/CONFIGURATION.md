# Continue.dev Configuration Guide

**Config Location:** `~/.continue/config.yaml`
**Format:** YAML (JSON is deprecated)
**Last Updated:** 2025-11-26

---

## Configuration Overview

Continue.dev uses `~/.continue/config.yaml` to configure:
- AI model providers (Claude, OpenAI, etc.)
- Model roles (chat, edit, autocomplete, embeddings)
- Context providers
- Custom rules and prompts
- API keys and authentication

---

## Complete Configuration Template

### Dual-Provider Setup (Claude Max + ChatGPT)

Create `~/.continue/config.yaml`:

```yaml
# Continue.dev Configuration
# Using Claude Max (Anthropic) + ChatGPT Plus (OpenAI)

name: mitsio-dev-config
version: 1.0.0
schema: https://continue.dev/config-schema.json

# Model Providers
models:
  # === PRIMARY: Claude 4 Sonnet (Chat & Edit) ===
  - name: Claude 4 Sonnet
    provider: anthropic
    model: claude-sonnet-4-20250514
    apiKey: ${ANTHROPIC_API_KEY}
    roles:
      - chat
      - edit
      - apply
    defaultCompletionOptions:
      temperature: 0.7
      maxTokens: 8192
      promptCaching: true  # IMPORTANT: Cost optimization!

  # === SECONDARY: GPT-4o (Fallback Chat) ===
  - name: GPT-4o
    provider: openai
    model: gpt-4o
    apiKey: ${OPENAI_API_KEY}
    roles:
      - chat
    defaultCompletionOptions:
      temperature: 0.7
      maxTokens: 4096

  # === AUTOCOMPLETE: Claude Haiku (Fast & Cheap) ===
  - name: Claude Haiku
    provider: anthropic
    model: claude-3-5-haiku-20241022
    apiKey: ${ANTHROPIC_API_KEY}
    roles:
      - autocomplete
    defaultCompletionOptions:
      temperature: 0.2
      maxTokens: 1024

  # === EMBEDDINGS: OpenAI (For Codebase Search) ===
  - name: OpenAI Embeddings
    provider: openai
    model: text-embedding-3-small
    apiKey: ${OPENAI_API_KEY}
    roles:
      - embed

# Context Providers (what Continue can access)
context:
  - uses: file          # Current file context
  - uses: code          # Code structure
  - uses: codebase      # Full codebase search
  - uses: terminal      # Terminal output
  - uses: problems      # Linting errors
  - uses: git-diff      # Git changes

# Custom Rules (optional)
rules:
  - name: nix-strict
    rule: |
      When working with Nix code:
      - Use explicit attribute names
      - Prefer readFile over inline strings
      - Add comments for complex expressions
    globs: ["**/*.nix"]
    alwaysApply: true

  - name: python-typing
    rule: |
      Use type hints for all function parameters and return values
    globs: ["**/*.py"]
    alwaysApply: true
```

---

## Configuration Sections Explained

### 1. Models Array

Each model definition includes:

```yaml
models:
  - name: <DISPLAY_NAME>           # Shown in UI
    provider: <PROVIDER>           # anthropic, openai, etc.
    model: <MODEL_ID>              # Specific model identifier
    apiKey: ${ENV_VARIABLE}        # Reference environment variable
    roles:                         # What this model does
      - chat                       # Conversational interface
      - edit                       # Code modifications
      - apply                      # Apply changes
      - autocomplete               # Code completion
      - embed                      # Embeddings for search
    defaultCompletionOptions:
      temperature: 0.7             # Creativity (0.0-2.0)
      maxTokens: 4096              # Response length limit
      promptCaching: true          # Enable Claude caching
```

### 2. Provider-Specific Settings

#### Anthropic (Claude)

```yaml
- name: Claude 4 Sonnet
  provider: anthropic
  model: claude-sonnet-4-20250514
  apiKey: ${ANTHROPIC_API_KEY}
  defaultCompletionOptions:
    promptCaching: true  # MUST ENABLE for cost savings!
```

**Available Claude Models:**
- `claude-sonnet-4-20250514` - Claude 4 Sonnet (latest flagship)
- `claude-3-7-sonnet-20250219` - Claude 3.7 Sonnet (extended thinking)
- `claude-3-5-haiku-20241022` - Claude 3.5 Haiku (fast/cheap)
- `claude-opus-4-20250514` - Claude 4 Opus (most capable)

#### OpenAI (ChatGPT)

```yaml
- name: GPT-4o
  provider: openai
  model: gpt-4o
  apiKey: ${OPENAI_API_KEY}
```

**Available OpenAI Models:**
- `gpt-4o` - GPT-4 Optimized (best overall)
- `gpt-4-turbo-preview` - GPT-4 Turbo (large context)
- `gpt-3.5-turbo` - GPT-3.5 (fast/cheap)
- `o1-preview` - O1 reasoning model
- `text-embedding-3-small` - Embeddings

### 3. Model Roles

| Role | Purpose | Recommended Model |
|------|---------|-------------------|
| `chat` | Conversational Q&A | Claude 4 Sonnet, GPT-4o |
| `edit` | Code modifications | Claude 4 Sonnet |
| `apply` | Apply code changes | Claude 4 Sonnet |
| `autocomplete` | Code completion | Claude Haiku (fast) |
| `embed` | Codebase search | OpenAI text-embedding-3-small |

### 4. Prompt Caching (Claude Only!)

**CRITICAL for cost optimization:**

```yaml
defaultCompletionOptions:
  promptCaching: true  # Caches system messages & context
```

**Benefits:**
- ~90% cost reduction on repeated context
- Faster response times
- Caches up to 5 minutes

**How it works:**
- System message cached
- Conversation history cached
- Only new messages charged at full rate

---

## Environment Variables

### Setting API Keys

**Option 1: Shell Environment (Temporary)**

```bash
# Add to ~/.bashrc or ~/.zshrc
export ANTHROPIC_API_KEY="sk-ant-xxxxx"
export OPENAI_API_KEY="sk-xxxxx"
```

**Option 2: Home-Manager (Declarative)**

```nix
# In home.nix
{
  home.sessionVariables = {
    # NEVER commit real keys!
    # Use placeholders and document manual setup
    ANTHROPIC_API_KEY = "REPLACE_WITH_YOUR_KEY";
    OPENAI_API_KEY = "REPLACE_WITH_YOUR_KEY";
  };
}
```

**Option 3: KeePassXC Integration (RECOMMENDED)**

See [API_KEYS.md](./API_KEYS.md) for secure secret management.

---

## Advanced Configuration

### Workspace-Specific Config

Create `.continuerc.json` in project root:

```json
{
  "mergeBehavior": "merge",
  "models": [
    {
      "name": "Project-Specific Model",
      "provider": "anthropic",
      "model": "claude-sonnet-4-20250514"
    }
  ]
}
```

### Custom Context Providers

```yaml
context:
  - provider: docs
    params:
      docs:
        - name: NixOS Manual
          startUrl: https://nixos.org/manual/nixos/stable/
        - name: Home Manager
          startUrl: https://nix-community.github.io/home-manager/
```

### TypeScript Config (Advanced)

For programmatic configuration, create `~/.continue/config.ts`:

```typescript
export function modifyConfig(config: Config): Config {
  // Add custom slash command
  config.slashCommands?.push({
    name: "nix-build",
    description: "Build Nix configuration",
    run: async function* (sdk) {
      const result = await sdk.ide.runCommand("nix-build");
      yield result;
    },
  });
  return config;
}
```

---

## Testing Configuration

### 1. Validate YAML Syntax

```bash
# Install yamllint if needed
nix-shell -p yamllint

# Validate config
yamllint ~/.continue/config.yaml
```

### 2. Test API Keys

```bash
# Test Anthropic API
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "test"}]
  }'

# Test OpenAI API
curl https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "test"}],
    "max_tokens": 10
  }'
```

### 3. Reload Configuration

1. Open VSCodium
2. Open Continue sidebar
3. Click gear icon → Reload Configuration
4. Or restart VSCodium

---

## Minimal Configuration (Quick Start)

If you just want to get started quickly:

```yaml
models:
  - name: Claude 4 Sonnet
    provider: anthropic
    model: claude-sonnet-4-20250514
    apiKey: ${ANTHROPIC_API_KEY}
    defaultCompletionOptions:
      promptCaching: true
```

Then add more models as needed.

---

## Home-Manager Integration

Create `continue-dev.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  # Manage config.yaml
  home.file.".continue/config.yaml".text = ''
    # Continue.dev config managed by home-manager
    # See: ${config.home.homeDirectory}/.MyHome/MySpaces/my-modular-workspace/docs/commons/tools/continue.dev/

    models:
      - name: Claude 4 Sonnet
        provider: anthropic
        model: claude-sonnet-4-20250514
        apiKey: ''${ANTHROPIC_API_KEY}
        defaultCompletionOptions:
          promptCaching: true
  '';

  # Set environment variables (placeholders)
  home.sessionVariables = {
    # IMPORTANT: Replace with actual keys from KeePassXC
    # See: docs/commons/tools/continue.dev/API_KEYS.md
    ANTHROPIC_API_KEY = "REPLACE_ME";
    OPENAI_API_KEY = "REPLACE_ME";
  };
}
```

---

## Next Steps

1. ✅ Configuration created
2. → Secure API keys: [API_KEYS.md](./API_KEYS.md)
3. → Optimize model usage: [MODELS.md](./MODELS.md)
4. → Troubleshoot issues: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
