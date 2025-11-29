# Continue.dev Implementation Plan

**Project:** Continue.dev Integration for VSCodium
**Environment:** NixOS 25.05 (shoshin workspace)
**Owner:** Mitsio
**Status:** Planning Complete | Ready for Execution
**Created:** 2025-11-26

---

## Executive Summary

**Goal:** Install and fully integrate Continue.dev IDE extension with VSCodium, leveraging both Claude Max and ChatGPT Plus subscriptions for AI-powered coding assistance.

**Key Deliverables:**
1. ✅ Research & Documentation (COMPLETE)
2. Continue.dev extension installed in VSCodium
3. Dual-provider configuration (Claude + OpenAI)
4. Secure API key management via KeePassXC
5. Home-manager module for declarative management
6. Comprehensive testing and verification

**Estimated Time:** 3-4 hours
**Priority:** HIGH

---

## Phase 1: Research & Documentation ✅ COMPLETE

### Completed Tasks

- [x] Research Continue.dev architecture and capabilities
- [x] Investigate VSCodium compatibility (Open VSX lag confirmed)
- [x] Identify NixOS-specific issues (GitHub #821, Discourse #36652)
- [x] Research API configuration for Claude + OpenAI
- [x] Document prompt caching for cost optimization
- [x] Create comprehensive documentation structure
- [x] Write installation guide (INSTALLATION.md)
- [x] Write configuration guide (CONFIGURATION.md)
- [x] Write API key management guide (API_KEYS.md)
- [x] Document model optimization strategies
- [x] Create troubleshooting guide
- [x] Create this implementation plan

**Findings:**
- Continue.dev supports multiple AI providers simultaneously
- Manual VSIX installation recommended for NixOS due to Open VSX lag
- Prompt caching can reduce Claude API costs by ~90%
- NixOS may require FHS environment wrapper or library path fixes

---

## Phase 2: Installation

**Duration:** 30-45 minutes

### 2.1: Download Extension

```bash
# Create directory
mkdir -p ~/Downloads/continue-dev
cd ~/Downloads/continue-dev

# Download latest VSIX
wget https://github.com/continuedev/continue/releases/latest/download/continue-vscode.vsix

# Verify download
ls -lh continue-vscode.vsix
```

**Success Criteria:**
- [ ] VSIX file downloaded (~50-100 MB)
- [ ] File integrity verified

### 2.2: Install Extension

```bash
# Install in VSCodium
codium --install-extension continue-vscode.vsix

# Verify installation
codium --list-extensions | grep Continue
```

**Expected Output:**
```
Continue.continue
```

**Success Criteria:**
- [ ] Extension appears in extension list
- [ ] No installation errors

### 2.3: Verify Extension Loads

```bash
# Start VSCodium
codium

# Check for Continue icon in sidebar
# Look for errors in extension logs
```

**Check Extension Host Logs:**
```bash
tail -f ~/.config/VSCodium/logs/*/window1/exthost/output*
```

**Success Criteria:**
- [ ] Continue icon visible in VSCodium sidebar
- [ ] Sidebar opens when clicked
- [ ] No activation errors in logs

### 2.4: NixOS Troubleshooting (If Needed)

**If extension fails to activate:**

**Option A: FHS Wrapper**
```nix
# Add to home.nix temporarily for testing
{ pkgs, ... }:
{
  home.packages = [ pkgs.nodejs_20 ];
}
```

**Option B: LD_LIBRARY_PATH Fix**
```bash
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"
codium
```

**Success Criteria:**
- [ ] Extension activates without errors
- [ ] Continue server starts successfully

---

## Phase 3: API Key Setup

**Duration:** 20-30 minutes

### 3.1: Obtain API Keys

**Anthropic (Claude Max):**
1. Visit: https://console.anthropic.com/account/keys
2. Click "Create Key"
3. Name: "Continue.dev - VSCodium - Shoshin"
4. Copy key (format: `sk-ant-api03-xxxxx`)

**OpenAI:**
1. Visit: https://platform.openai.com/account/api-keys
2. Click "Create new secret key"
3. Name: "Continue.dev - VSCodium - Shoshin"
4. Copy key (format: `sk-xxxxx`)

**Success Criteria:**
- [ ] Anthropic API key obtained
- [ ] OpenAI API key obtained
- [ ] Keys saved temporarily in secure location

### 3.2: Store in KeePassXC

1. Open KeePassXC
2. Create group: `Development/APIs/` (if not exists)
3. Create entries:

**Entry 1:**
```
Title: Anthropic API - Claude Max
Username: mitsio@anthropic
Password: sk-ant-api03-xxxxx
URL: https://console.anthropic.com
Notes: For Continue.dev on shoshin
```

**Entry 2:**
```
Title: OpenAI API - ChatGPT
Username: your-email
Password: sk-xxxxx
URL: https://platform.openai.com
Notes: For Continue.dev on shoshin
```

**Success Criteria:**
- [ ] Keys stored in KeePassXC
- [ ] Entries properly labeled
- [ ] Database saved

### 3.3: Set Environment Variables

**Temporary (for testing):**
```bash
export ANTHROPIC_API_KEY="sk-ant-api03-xxxxx"
export OPENAI_API_KEY="sk-xxxxx"

# Verify
echo $ANTHROPIC_API_KEY
echo $OPENAI_API_KEY
```

**Permanent (add to ~/.bashrc):**
```bash
# Add this to ~/.bashrc
# Continue.dev API Keys (fetch from KeePassXC)
export ANTHROPIC_API_KEY="xxxxx"  # Replace with actual key
export OPENAI_API_KEY="xxxxx"     # Replace with actual key
```

**Success Criteria:**
- [ ] Environment variables set in current shell
- [ ] Keys accessible via `echo $ANTHROPIC_API_KEY`
- [ ] Variables persist across terminal sessions

### 3.4: Test API Connectivity

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

**Success Criteria:**
- [ ] Anthropic API returns HTTP 200
- [ ] OpenAI API returns HTTP 200
- [ ] No authentication errors

---

## Phase 4: Configuration

**Duration:** 30-45 minutes

### 4.1: Create config.yaml

```bash
# Create Continue config directory
mkdir -p ~/.continue

# Create configuration file
cat > ~/.continue/config.yaml <<'EOF'
# Continue.dev Configuration
# Managed by: Mitsio
# Environment: shoshin (NixOS 25.05)
# Date: 2025-11-26

name: mitsio-shoshin-config
version: 1.0.0

models:
  # PRIMARY: Claude 4 Sonnet (Chat & Edit)
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
      promptCaching: true  # Cost optimization!

  # SECONDARY: GPT-4o (Fallback)
  - name: GPT-4o
    provider: openai
    model: gpt-4o
    apiKey: ${OPENAI_API_KEY}
    roles:
      - chat
    defaultCompletionOptions:
      temperature: 0.7
      maxTokens: 4096

  # AUTOCOMPLETE: Claude Haiku (Fast)
  - name: Claude Haiku
    provider: anthropic
    model: claude-3-5-haiku-20241022
    apiKey: ${ANTHROPIC_API_KEY}
    roles:
      - autocomplete
    defaultCompletionOptions:
      temperature: 0.2
      maxTokens: 1024

  # EMBEDDINGS: OpenAI
  - name: OpenAI Embeddings
    provider: openai
    model: text-embedding-3-small
    apiKey: ${OPENAI_API_KEY}
    roles:
      - embed

context:
  - uses: file
  - uses: code
  - uses: codebase
  - uses: terminal
  - uses: problems
  - uses: git-diff
EOF
```

**Success Criteria:**
- [ ] config.yaml created at ~/.continue/config.yaml
- [ ] YAML syntax is valid
- [ ] All required models configured

### 4.2: Validate Configuration

```bash
# Check YAML syntax
yamllint ~/.continue/config.yaml

# Check file permissions
ls -la ~/.continue/config.yaml
```

**Success Criteria:**
- [ ] No YAML syntax errors
- [ ] Config file readable

### 4.3: Reload in Continue.dev

1. Open VSCodium
2. Open Continue sidebar
3. Click settings gear icon
4. Select "Reload Configuration"
5. Check for model list

**Success Criteria:**
- [ ] Configuration loads without errors
- [ ] All 4 models appear in model selector
- [ ] No API key errors

---

## Phase 5: Testing & Verification

**Duration:** 45-60 minutes

### 5.1: Test Chat Feature (Claude)

1. Open Continue sidebar
2. Select "Claude 4 Sonnet" model
3. Send test message: "Explain what Continue.dev is in one sentence"
4. Wait for response

**Success Criteria:**
- [ ] Response received from Claude
- [ ] No API errors
- [ ] Response quality is good

### 5.2: Test Chat Feature (OpenAI)

1. Switch to "GPT-4o" model
2. Send test message: "What model are you?"
3. Wait for response

**Success Criteria:**
- [ ] Response received from GPT-4o
- [ ] Model confirms it's GPT-4o
- [ ] No API errors

### 5.3: Test Code Editing

1. Open a test file (create `~/test-continue.py`)
2. Write comment: `# Create a function to check if number is prime`
3. Highlight comment
4. Press Ctrl+I (inline edit)
5. Wait for code generation

**Success Criteria:**
- [ ] Code generated successfully
- [ ] Code is syntactically correct
- [ ] Can accept/reject changes

### 5.4: Test Autocomplete

1. Open test file
2. Start typing: `def fib`
3. Wait for autocomplete suggestions
4. Accept suggestion with Tab

**Success Criteria:**
- [ ] Autocomplete suggestions appear
- [ ] Using Claude Haiku (fast model)
- [ ] Suggestions are relevant

### 5.5: Verify Prompt Caching

**Check Anthropic Console:**
1. Visit: https://console.anthropic.com/settings/usage
2. Look for "Cached tokens" in usage breakdown
3. Should see ~90% cache hit rate after a few requests

**Success Criteria:**
- [ ] Cached tokens shown in usage
- [ ] Significant cost reduction visible
- [ ] Cache working as expected

---

## Phase 6: Home-Manager Integration

**Duration:** 30-45 minutes

### 6.1: Create continue-dev.nix Module

```bash
# Create module file
cat > /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager/continue-dev.nix <<'EOF'
{ config, lib, pkgs, ... }:

{
  # Manage Continue.dev configuration
  home.file.".continue/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.MyHome/MySpaces/my-modular-workspace/dotfiles/continue/config.yaml";

  # Environment variables (PLACEHOLDERS - replace with KeePassXC keys)
  home.sessionVariables = {
    # SECURITY: Never commit real API keys!
    # Get actual keys from: KeePassXC -> Development/APIs/
    # See: docs/commons/tools/continue.dev/API_KEYS.md
    ANTHROPIC_API_KEY = "FETCH_FROM_KEEPASSXC";
    OPENAI_API_KEY = "FETCH_FROM_KEEPASSXC";
  };

  # Ensure Node.js is available (Continue.dev requires it)
  home.packages = with pkgs; [
    nodejs_20
  ];
}
EOF
```

### 6.2: Move config.yaml to Dotfiles

```bash
# Create dotfiles directory
mkdir -p /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles/continue

# Move config
mv ~/.continue/config.yaml \
   /home/mitsio/.MyHome/MySpaces/my-modular-workspace/dotfiles/continue/config.yaml

# Symlink will be created by home-manager
```

### 6.3: Add Module to home.nix

```nix
# In home-manager/home.nix
{
  imports = [
    # ... existing imports ...
    ./continue-dev.nix  # Add this line
  ];
}
```

### 6.4: Test Home-Manager Build

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace/home-manager
home-manager build --flake .#mitsio@shoshin
```

**Success Criteria:**
- [ ] Build succeeds without errors
- [ ] No evaluation errors

### 6.5: Apply Configuration

```bash
home-manager switch --flake .#mitsio@shoshin
```

**Success Criteria:**
- [ ] Switch completes successfully
- [ ] Symlink created correctly
- [ ] VSCodium still works with Continue.dev

---

## Phase 7: Documentation & Cleanup

**Duration:** 15-20 minutes

### 7.1: Update TODO.md

Add completed tasks and update status in:
`docs/TODO.md`

### 7.2: Commit Changes

```bash
cd /home/mitsio/.MyHome/MySpaces/my-modular-workspace

# Stage documentation
git add docs/commons/tools/continue.dev/

# Stage home-manager module
git add home-manager/continue-dev.nix
git add home-manager/home.nix
git add dotfiles/continue/

# Commit
git commit -m "Add Continue.dev integration

- Complete documentation suite
- Home-manager module for declarative config
- Dual-provider setup (Claude Max + OpenAI)
- Secure API key management guide
- NixOS-specific troubleshooting

Docs location: docs/commons/tools/continue.dev/"

# Push
git push origin main
```

### 7.3: Document Learnings

Create summary of installation experience for future reference.

---

## Success Metrics

### Functional Requirements

- [ ] Continue.dev extension installed and activated in VSCodium
- [ ] Claude 4 Sonnet accessible for chat and editing
- [ ] GPT-4o accessible as fallback
- [ ] Autocomplete working with Claude Haiku
- [ ] Prompt caching enabled and reducing costs
- [ ] Configuration managed declaratively via home-manager
- [ ] API keys stored securely in KeePassXC

### Non-Functional Requirements

- [ ] No secrets committed to git
- [ ] Documentation complete and accurate
- [ ] Installation reproducible on clean system
- [ ] Troubleshooting guide covers NixOS issues
- [ ] Cost optimization strategies documented

---

## Rollback Procedure

If something goes wrong:

```bash
# Uninstall extension
codium --uninstall-extension Continue.continue

# Remove configuration
rm -rf ~/.continue

# Remove from home-manager
# Remove ./continue-dev.nix from imports in home.nix

# Rebuild home-manager
home-manager switch
```

---

## Timeline

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| 1. Research | COMPLETE | None |
| 2. Installation | 30-45 min | VSIX download |
| 3. API Keys | 20-30 min | Claude Max + OpenAI accounts |
| 4. Configuration | 30-45 min | API keys ready |
| 5. Testing | 45-60 min | Configuration complete |
| 6. Home-Manager | 30-45 min | Testing passed |
| 7. Documentation | 15-20 min | All phases complete |

**Total Estimated Time:** 3-4 hours

---

## Next Actions

1. **START HERE:** Phase 2 - Installation
2. Follow each phase sequentially
3. Check off success criteria as you go
4. Document any deviations or issues
5. Update this plan with lessons learned

---

**Status:** Ready for Execution
**Last Updated:** 2025-11-26
**Owner:** Mitsio
