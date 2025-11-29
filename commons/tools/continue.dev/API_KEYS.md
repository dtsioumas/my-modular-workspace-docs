# API Key Management for Continue.dev

**Security Level:** HIGH - API keys grant access to paid subscriptions
**Storage:** KeePassXC vault (NEVER in git)
**Last Updated:** 2025-11-26

---

## Overview

Continue.dev requires API keys to access Claude Max (Anthropic) and ChatGPT Plus (OpenAI) subscriptions. Proper key management is critical for:
- Security (prevent unauthorized usage)
- Cost control (API calls cost money)
- Compliance (protect sensitive credentials)

---

## Required API Keys

### 1. Anthropic API Key (Claude Max)

**Where to get:**
- Console: https://console.anthropic.com/account/keys
- Subscription: Claude Max ($20/month provides API credits)

**Format:** `sk-ant-api03-xxxxx...`

**Permissions:** Full API access to Claude models

### 2. OpenAI API Key (ChatGPT Plus)

**Where to get:**
- Platform: https://platform.openai.com/account/api-keys
- Note: ChatGPT Plus ($20/month) is SEPARATE from API access
- API usage: Pay-per-use (separate billing)

**Format:** `sk-xxxxx...`

**Permissions:** Full API access to GPT models

---

## Secure Storage Options

### Option 1: KeePassXC Vault (RECOMMENDED)

Your KeePassXC vault is already set up at `~/MyVault/`. Use it to store API keys securely.

#### Store Keys in KeePassXC

1. Open KeePassXC
2. Navigate to `Development/APIs/` group (or create it)
3. Create entries:

```
Title: Anthropic API - Claude Max
Username: mitsio@anthropic
Password: sk-ant-api03-xxxxx...
URL: https://console.anthropic.com
Notes: Claude Max subscription - for Continue.dev

Title: OpenAI API - ChatGPT
Username: your-email@example.com
Password: sk-xxxxx...
URL: https://platform.openai.com
Notes: OpenAI API - for Continue.dev
```

#### Retrieve Keys for Environment Variables

**Method A: Manual Copy**
```bash
# Open KeePassXC, copy key, then:
export ANTHROPIC_API_KEY="<paste-key-here>"
export OPENAI_API_KEY="<paste-key-here>"
```

**Method B: KeePassXC CLI Integration**

```bash
# Install keepassxc-cli if not already
# (should be available if KeePassXC is installed)

# Unlock database and get key
keepassxc-cli show ~/MyVault/your-database.kdbx \
  "Development/APIs/Anthropic API - Claude Max" \
  -a Password

# Export to environment (interactive - prompts for master password)
export ANTHROPIC_API_KEY=$(keepassxc-cli show ~/MyVault/your-database.kdbx \
  "Development/APIs/Anthropic API - Claude Max" \
  -a Password -q)
```

**Method C: Automated with Chezmoi Templates**

Create `~/.local/share/chezmoi/dot_bashrc.tmpl`:

```bash
{{- $vault := keepassxcAttribute "Development/APIs/Anthropic API - Claude Max" "Password" -}}
export ANTHROPIC_API_KEY="{{ $vault }}"

{{- $openai := keepassxcAttribute "Development/APIs/OpenAI API - ChatGPT" "Password" -}}
export OPENAI_API_KEY="{{ $openai }}"
```

---

### Option 2: Environment Variables File (Encrypted)

Create `~/.config/continue/secrets.env` (git-ignored):

```bash
# Continue.dev API Keys
# WARNING: Keep this file secure!
export ANTHROPIC_API_KEY="sk-ant-api03-xxxxx"
export OPENAI_API_KEY="sk-xxxxx"
```

**Protect the file:**
```bash
chmod 600 ~/.config/continue/secrets.env
```

**Load in shell:**
```bash
# Add to ~/.bashrc
if [ -f ~/.config/continue/secrets.env ]; then
  source ~/.config/continue/secrets.env
fi
```

**Encrypt with GPG (extra security):**

```bash
# Encrypt secrets
gpg --symmetric --cipher-algo AES256 ~/.config/continue/secrets.env

# Decrypt and load
gpg --decrypt ~/.config/continue/secrets.env.gpg | source /dev/stdin
```

---

### Option 3: Home-Manager with Placeholders

**In home.nix** (commit this):

```nix
{
  home.sessionVariables = {
    # PLACEHOLDER: Replace with actual keys from KeePassXC
    # See: docs/commons/tools/continue.dev/API_KEYS.md
    ANTHROPIC_API_KEY = "REPLACE_WITH_KEEPASSXC_KEY";
    OPENAI_API_KEY = "REPLACE_WITH_KEEPASSXC_KEY";
  };

  # Or use activation script to fetch from KeePassXC
  home.activation.load-api-keys = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # This requires keepassxc-cli and unlocked database
    # NOTE: This is just an example - requires interactive password
    # Better to use chezmoi templates
  '';
}
```

**Then manually override:**

```bash
# In ~/.bashrc (not managed by home-manager)
export ANTHROPIC_API_KEY="actual-key-from-keepassxc"
export OPENAI_API_KEY="actual-key-from-keepassxc"
```

---

## Security Best Practices

### ✅ DO:
- Store keys in KeePassXC vault
- Use environment variables (not hardcoded in config.yaml)
- Set restrictive file permissions (`chmod 600`)
- Rotate keys periodically (every 90 days)
- Monitor API usage for anomalies
- Use separate keys for different projects (if available)

### ❌ DON'T:
- Commit keys to git (EVER!)
- Share keys via email/chat
- Store keys in plain text files (unless encrypted)
- Use the same key across multiple machines (if avoidable)
- Leave keys in shell history

---

## Git Protection

### Ensure Keys Never Enter Git

**Add to `.gitignore`:**

```gitignore
# API Keys and Secrets
.env
.env.*
secrets.env
*.secret
*_SECRET*
*_KEY*

# Continue.dev (if you store keys here)
.continue/secrets.yaml
.continue/*.secret

# Chezmoi encrypted files (keep encrypted versions only)
*.age
!*.age.asc  # Keep encrypted but not decrypted
```

**Check for leaked keys:**

```bash
# Search git history for potential keys
git log -S "sk-ant-" --all
git log -S "sk-" --all

# Use git-secrets to prevent commits
git secrets --scan
```

---

## Verification

### Test API Keys

**Anthropic (Claude):**

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

Expected: HTTP 200 with response

**OpenAI:**

```bash
curl https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 10
  }'
```

Expected: HTTP 200 with response

---

## Troubleshooting

### Key Not Found in Environment

```bash
# Check if variables are set
echo $ANTHROPIC_API_KEY
echo $OPENAI_API_KEY

# Should output keys (or "REPLACE_WITH_KEEPASSXC_KEY" if placeholder)
```

**Fix:** Source your secrets file or restart shell

### Invalid Key Error

**Symptom:** Continue.dev shows "Invalid API key" error

**Causes:**
1. Key expired or revoked
2. Typo in key
3. Wrong key format
4. Insufficient permissions

**Fix:**
1. Generate new key from console
2. Update KeePassXC entry
3. Re-export environment variable
4. Restart VSCodium

### Key Works in CLI but Not in Continue.dev

**Cause:** VSCodium doesn't inherit shell environment variables

**Fix Option 1: Launch VSCodium from Terminal**

```bash
# Export keys first
export ANTHROPIC_API_KEY="xxxxx"
export OPENAI_API_KEY="xxxxx"

# Then launch
codium
```

**Fix Option 2: Use systemd User Environment**

```bash
# Set environment for user session
systemctl --user set-environment ANTHROPIC_API_KEY="xxxxx"
systemctl --user set-environment OPENAI_API_KEY="xxxxx"

# Restart VSCodium
```

**Fix Option 3: Hardcode in config.yaml (NOT RECOMMENDED)**

```yaml
models:
  - name: Claude
    apiKey: "sk-ant-xxxxx"  # DON'T DO THIS IN COMMITTED FILES!
```

---

## Recommended Workflow

### Initial Setup

1. **Store keys in KeePassXC**
   - Create entries in `Development/APIs/` group
   - Use strong master password

2. **Create shell script to load keys**

```bash
# ~/.local/bin/load-continue-keys.sh
#!/bin/bash
export ANTHROPIC_API_KEY=$(keepassxc-cli show ~/MyVault/your-db.kdbx \
  "Development/APIs/Anthropic API - Claude Max" -a Password -q)
export OPENAI_API_KEY=$(keepassxc-cli show ~/MyVault/your-db.kdbx \
  "Development/APIs/OpenAI API - ChatGPT" -a Password -q)
echo "✓ API keys loaded for Continue.dev"
```

3. **Load before starting VSCodium**

```bash
source ~/.local/bin/load-continue-keys.sh
codium
```

---

## Cost Monitoring

### Track API Usage

**Anthropic:**
- Dashboard: https://console.anthropic.com/settings/usage
- Set spending limits
- Enable email alerts

**OpenAI:**
- Dashboard: https://platform.openai.com/usage
- Set monthly budgets
- Monitor per-model costs

### Optimize Costs

1. **Enable prompt caching** (Claude only - saves ~90%)
2. **Use Haiku for autocomplete** (cheaper than Sonnet)
3. **Limit max_tokens** in config
4. **Monitor daily usage**
5. **Set hard limits** in provider console

---

## Next Steps

1. ✅ Store API keys in KeePassXC
2. ✅ Set environment variables
3. ✅ Test API connectivity
4. → Configure Continue.dev: [CONFIGURATION.md](./CONFIGURATION.md)
5. → Optimize model usage: [MODELS.md](./MODELS.md)
