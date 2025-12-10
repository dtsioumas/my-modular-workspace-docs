# ADR-011: Unified Secrets Management via KeePassXC + systemd

**Status:** Accepted
**Date:** 2025-12-10
**Author:** Mitsio
**Context:** Workspace-wide secrets and API key management

---

## Context and Problem Statement

The workspace requires various secrets for different services:

**Currently Integrated:**
- `ANTHROPIC_API_KEY` - Claude API access
- `GITHUB_PAT` - GitHub Personal Access Token
- `RCLONE_CONFIG_PASS` - Rclone encrypted config password
- `FIRECRAWL_API_KEY` - Firecrawl web scraping MCP
- `EXA_API_KEY` - Exa AI search MCP
- `BRAVE_API_KEY` - Brave Search MCP
- `CONTEXT7_API_KEY` - Context7 library docs MCP

**Potential Future Secrets:**
- `OPENAI_API_KEY` - OpenAI API
- `GROQ_API_KEY` - Groq API
- Other API keys, tokens, and passwords

### Problem: Fragmented Secret Management

Without a unified approach, secrets management becomes:
1. **Inconsistent:** Different patterns per application
2. **Insecure:** Plaintext files, hardcoded values, environment leaks
3. **Complex:** Multiple scripts, manual sourcing, scattered configs
4. **Unmaintainable:** No single source of truth

---

## Decision

**ALL secrets in the workspace MUST be managed via KeePassXC + systemd integration.**

### Core Principles

1. **Single Source of Truth:** KeePassXC vault is the only place secrets are stored
2. **systemd Integration:** `load-keepassxc-secrets.service` loads secrets at login
3. **No Plaintext Files:** Never store secrets in dotfiles, env files, or scripts
4. **FdoSecrets Protocol:** Use D-Bus Secret Service for secure retrieval
5. **Environment Inheritance:** Processes inherit secrets from systemd environment

---

## Architecture

### Secret Loading Flow

```
Login → graphical-session.target → load-keepassxc-secrets.service
                                           ↓
                              secret-tool lookup (ONE prompt)
                                           ↓
                         systemctl --user set-environment VAR=value
                                           ↓
                         dbus-update-activation-environment --systemd
                                           ↓
                    All processes inherit environment variables
```

### KeePassXC Entry Structure

Each secret requires **two attributes** for FdoSecrets lookup:

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `service` | Category/namespace | `api`, `mcp`, `rclone`, `github`, `anthropic` |
| `key` | Specific identifier | `apikey`, `pat`, `configpassword`, `firecrawl` |

### Current Secret Registry

| Environment Variable | KeePassXC Entry | service | key |
|---------------------|-----------------|---------|-----|
| `ANTHROPIC_API_KEY` | Anthropic | `anthropic` | `apikey` |
| `GITHUB_PAT` | Github-PAT | `github` | `pat` |
| `RCLONE_CONFIG_PASS` | rclone-config-password | `rclone` | `configpassword` |
| `FIRECRAWL_API_KEY` | FIRECRAWL_API_KEY | `mcp` | `firecrawl` |
| `EXA_API_KEY` | EXA_API_KEY | `mcp` | `exa` |
| `BRAVE_API_KEY` | BRAVE_API_KEY | `mcp` | `brave` |
| `CONTEXT7_API_KEY` | CONTEXT7_API_KEY | `mcp` | `context7` |

---

## Implementation

### Adding a New Secret

1. **Create KeePassXC Entry:**
   - Entry name: Descriptive (e.g., `OPENAI_API_KEY`)
   - Password field: The actual secret value
   - Group: FdoSecrets-enabled group (e.g., "Workspace Secrets")

2. **Add FdoSecrets Attributes:**
   - Edit Entry → Advanced tab → Additional Attributes
   - Add `service` = `<category>` (e.g., `api`, `mcp`)
   - Add `key` = `<identifier>` (e.g., `openai`)

3. **Update `keepassxc.nix`:** Add lookup and set-environment for the new secret

4. **Test:**
   ```bash
   systemctl --user restart load-keepassxc-secrets.service
   systemctl --user show-environment | grep NEW_SECRET
   ```

---

## Rationale

### Why KeePassXC + systemd?

| Approach | Security | UX | Maintenance |
|----------|----------|-----|-------------|
| Plaintext .env files | Poor | Simple | Complex |
| Per-app secret managers | Varies | Fragmented | High |
| Shell rc sourcing | Poor | Error-prone | Complex |
| **KeePassXC + systemd** | **Strong** | **Single prompt** | **Centralized** |

### Benefits

1. **Security:** Secrets encrypted at rest, never in plaintext files
2. **User Experience:** One password prompt at login
3. **Maintainability:** Centralized in `keepassxc.nix`
4. **Consistency:** Same pattern for all secrets

---

## Anti-Patterns (NEVER Do This)

1. **File-based secrets:** `source ~/.config/app/secrets.env`
2. **Hardcoded in configs:** `api_key: "sk-ant-xxxxx"`
3. **Wrapper script sourcing:** Each wrapper loads secrets from file
4. **Direct secret-tool in wrappers:** Prompts every time

---

## Consequences

### Positive
- Unified, secure, simple, consistent, auditable

### Negative
- Setup required for each secret
- KeePassXC must be unlocked at login

---

## Implementation Status

### Completed
- [x] Core infrastructure (`load-keepassxc-secrets.service`)
- [x] Anthropic, GitHub, Rclone integrations
- [x] MCP server secrets (Firecrawl, Exa, Brave, Context7)

### Future
- [ ] OpenAI API key (when needed)
- [ ] Groq API key (when needed)

---

## Related Decisions

- **ADR-007:** Autostart tools via Home-Manager
- **ADR-010:** Unified MCP server architecture

---

## References

- KeePassXC FdoSecrets: https://keepassxc.org/docs/KeePassXC_UserGuide.html#_secret_service_integration
- Implementation: `home-manager/keepassxc.nix`

---

**Decision:** Accepted
**Implementation Status:** Complete (Core), Ongoing (New Secrets)
