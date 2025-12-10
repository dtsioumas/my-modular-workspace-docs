# ADR-011: Unified Secrets Management via KeePassXC + systemd

**Status:** Accepted (v2)
**Date:** 2025-12-10 (revised)
**Author:** Mitsio
**Context:** Workspace-wide secrets and API key management (KeePassXC + systemd)

---

## Context and Problem Statement

The workspace requires various secrets for different services:

**Currently Integrated:**
- `ANTHROPIC_API_KEY` – Claude API access
- `GITHUB_PAT` – GitHub Personal Access Token
- `RCLONE_CONFIG_PASS` – rclone encrypted config password
- MCP tokens (`FIRECRAWL_API_KEY`, `EXA_API_KEY`, `BRAVE_API_KEY`, `CONTEXT7_API_KEY`)

**Planned / Pending Integrations:**
- `OPENAI_API_KEY`, `GROQ_API_KEY`, and any new LLM provider tokens
- `BUTTERFISH_API_KEY` / Codex CLI / Claude Code CLI secrets
- Dropbox secrets (if any) once KDE Wallet removal is complete
- Brave browser passwords + Sync recovery seed (see Brave integration plan)
- Future MCP/API keys introduced by tooling
- Shared secrets for Ansible playbooks, butterfish/autocomplete tooling, and any codified CLI

### Problem: Fragmented Secret Management

Without a unified approach, secrets management becomes:
1. **Inconsistent:** Different patterns per application
2. **Insecure:** Plaintext files, hardcoded values, environment leaks
3. **Complex:** Multiple scripts, manual sourcing, scattered configs
4. **Unmaintainable:** No single source of truth

---

## Decision

**ALL secrets in the workspace MUST be managed via KeePassXC + systemd integration.** ADR‑012 has been merged into this document; there is now a single canonical contract.

### Core Principles

1. **Single Source of Truth:** KeePassXC vault(s) (`~/MyVault/…`) store every API key, password, recovery seed, and CLI token.
2. **systemd Integration:** `load-keepassxc-secrets.service` + loader modules expose secrets via `$XDG_RUNTIME_DIR` files and/or systemd env; no ad-hoc `secret-tool` calls in wrappers.
3. **No Plaintext Files:** Secrets MUST NOT appear in dotfiles, repo-tracked configs, or standalone env files (.env, rc, YAML).
4. **FdoSecrets Protocol:** All retrieval happens via Secret Service (`secret-tool`/libsecret) so KeePassXC prompts exactly once per login.
5. **Environment Bridging:** Shells (.bashrc) must read from systemd env to support Plasma and other desktops.
6. **Governance Enforcement:** Any new tool/service must (a) define a KeePassXC entry, (b) register loader/service logic in home-manager, and (c) update documentation/TODOs.

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
| (pending) `OPENAI_API_KEY` | OpenAI | `api` | `openai` |
| (pending) `BUTTERFISH_API_KEY` | butterfish | `cli` | `butterfish` |
| (pending) `CLAUDE_CODE_API_KEY` | Claude Code | `cli` | `claude-code` |
| (pending) Brave Sync Seed | Brave Sync Chain | `brave` | `sync-seed` |
| (pending) Dropbox secrets | Dropbox | `dropbox` | `token` |

---

## Implementation

### Adding a New Secret / Loader

1. **Create KeePassXC Entry:**
   - Entry name: Descriptive (e.g., `OPENAI_API_KEY`)
   - Password field: The actual secret value
   - Group: FdoSecrets-enabled group (e.g., "Workspace Secrets")

2. **Add FdoSecrets Attributes:**
   - Edit Entry → Advanced tab → Additional Attributes
   - Add `service` = `<category>` (e.g., `api`, `mcp`)
   - Add `key` = `<identifier>` (e.g., `openai`)

3. **Update `keepassxc.nix` (or the loader factory):** Add a loader definition (`createSecretService` or extension to `load-keepassxc-secrets.service`) for the secret.

4. **Test:**
   ```bash
   systemctl --user restart load-keepassxc-secrets.service
   systemctl --user show-environment | grep NEW_SECRET
   ```

---

## Rationale

### Why KeePassXC + systemd (v2)?

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
- Brave/autocomplete/CLI integrations inherit the same security posture

### Negative
- Setup required for each secret
- KeePassXC must be unlocked at login
- Additional documentation/rotation policy to maintain

---

## Implementation Status

### Completed
- [x] Core infrastructure (`load-keepassxc-secrets.service` + `.bashrc` bridge)
- [x] Anthropic, GitHub, MCP tokens, rclone password

### Immediate (Dec 2025)
- [ ] Add `OPENAI_API_KEY` + `BUTTERFISH_API_KEY` loaders and KeePassXC entries
- [ ] Integrate Brave passwords + Sync seed per migration plan
- [ ] Wire Dropbox/rclone loaders through KeePassXC (no KDE Wallet)
- [ ] Document Codex/Claude Code usage and add loader modules for their CLIs
- [ ] Implement secret health-check timer + rotation policy documentation

### Future (Q1 2026)
- [ ] Integrate Groq / new MCP services as they appear
- [ ] Review and retire redundant ADRs (007/008) once new governance doc is live

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
