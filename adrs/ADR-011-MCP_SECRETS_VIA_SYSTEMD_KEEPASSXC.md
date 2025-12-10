# ADR-011: MCP Secrets via systemd + KeePassXC Secret Service

**Status:** Accepted
**Date:** 2025-12-10
**Author:** Mitsio
**Context:** MCP server API key management

---

## Context and Problem Statement

MCP servers require API keys for external services:
- `FIRECRAWL_API_KEY` - Firecrawl web scraping
- `EXA_API_KEY` - Exa AI search
- `BRAVE_API_KEY` - Brave Search
- `CONTEXT7_API_KEY` - Context7 library docs (optional)

### Current State (Deprecated)

MCP wrappers currently source secrets from a file:

```bash
SECRETS_FILE="~/.config/mcp/secrets.env"
if [[ -f "$SECRETS_FILE" ]]; then
  source "$SECRETS_FILE"
fi
```

The file `~/.config/mcp/secrets.env` is populated by `mcp-load-secrets` script that runs `secret-tool lookup` at invocation time.

**Problems with file-based approach:**
1. File contains plaintext secrets on disk
2. Requires separate script execution
3. Not integrated with existing `load-keepassxc-secrets.service`
4. Duplicates functionality already solved by Phase 3 KeePassXC integration

---

## Decision

**Prefer systemd user environment + KeePassXC FdoSecrets over file-based secret loading.**

### Integration Pattern

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
                                           ↓
                          MCP wrappers use inherited $VAR
```

### Implementation

1. **KeePassXC entries** must have FdoSecrets attributes:
   - Entry: `FIRECRAWL_API_KEY` with `service=mcp`, `key=firecrawl`
   - Entry: `EXA_API_KEY` with `service=mcp`, `key=exa`
   - Entry: `BRAVE_API_KEY` with `service=mcp`, `key=brave`
   - Entry: `CONTEXT7_API_KEY` with `service=mcp`, `key=context7`

2. **`load-keepassxc-secrets.service`** loads all secrets at login:
   ```bash
   FIRECRAWL_API_KEY=$(secret-tool lookup service mcp key firecrawl)
   systemctl --user set-environment FIRECRAWL_API_KEY="$FIRECRAWL_API_KEY"
   ```

3. **MCP wrappers** simply inherit from environment:
   ```bash
   # No file sourcing needed - inherited from systemd
   exec $MCP_BINARY "$@"
   ```

---

## Rationale

### Why systemd environment over file-based?

| Aspect | File-based | systemd environment |
|--------|------------|---------------------|
| Secrets on disk | Yes (plaintext) | No |
| Single auth prompt | No (per-script) | Yes (at login) |
| Integration | Separate system | Unified with existing |
| Process inheritance | Manual sourcing | Automatic |
| Maintenance | Extra script | Existing service |

### Why KeePassXC FdoSecrets over direct file?

1. **Security:** Secrets stored in encrypted vault, not plaintext files
2. **Consistency:** Same pattern as ANTHROPIC_API_KEY, GITHUB_PAT, RCLONE_CONFIG_PASS
3. **User experience:** Single authorization prompt at login
4. **Maintainability:** One place to manage all secrets

---

## Consequences

### Positive

- **Unified secret management:** All secrets through KeePassXC
- **Better security:** No plaintext files with API keys
- **Single prompt:** User authorizes once at login
- **Simpler wrappers:** No file sourcing code needed
- **Consistent architecture:** Follows established Phase 3 pattern

### Negative

- **Setup required:** Must configure KeePassXC entry attributes
- **Dependency:** Requires KeePassXC unlocked at login

### Neutral

- **Deprecate** `~/.config/mcp/secrets.env` and `mcp-load-secrets` script
- **Update** MCP wrapper template to remove file sourcing

---

## KeePassXC Entry Configuration

For each MCP API key, set the following **Additional Attributes** in KeePassXC:

| Entry Name | Attribute: service | Attribute: key |
|------------|-------------------|----------------|
| FIRECRAWL_API_KEY | mcp | firecrawl |
| EXA_API_KEY | mcp | exa |
| BRAVE_API_KEY | mcp | brave |
| CONTEXT7_API_KEY | mcp | context7 |

**Steps:**
1. Open KeePassXC → Select entry (e.g., `FIRECRAWL_API_KEY`)
2. Click "Edit Entry" → "Advanced" tab
3. Under "Additional Attributes", add:
   - `service` = `mcp`
   - `key` = `firecrawl` (or appropriate key name)
4. Ensure entry is in a **FdoSecrets-enabled group** ("Workspace Secrets")

---

## Implementation Checklist

- [x] Update `keepassxc.nix` → `load-keepassxc-secrets.service` to load MCP secrets
- [x] Configure KeePassXC entries with correct attributes
- [x] Update MCP wrapper template to remove file sourcing
- [x] Deprecate `~/.config/mcp/secrets.env` file (removed 2025-12-10)
- [x] Deprecate `~/.local/bin/mcp-load-secrets` script (never existed)
- [x] Test MCP servers receive API keys from environment

---

## Related Decisions

- **ADR-007:** Autostart tools via Home-Manager (KeePassXC GUI service)
- **ADR-010:** Unified MCP server architecture
- **Phase 3:** KeePassXC systemd secret loading (RCLONE_CONFIG_PASS pattern)

---

## References

- KeePassXC FdoSecrets: https://keepassxc.org/docs/KeePassXC_UserGuide.html#_secret_service_integration
- Phase 3 docs: `docs/integrations/KEEPASSXC_SYSTEMD_SECRET_LOADING.md`
- Home-Manager config: `home-manager/keepassxc.nix`

---

**Decision:** Accepted
**Implementation Status:** Complete (2025-12-10)
