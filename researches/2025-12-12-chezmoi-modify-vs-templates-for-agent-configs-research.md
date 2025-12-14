# Research: Chezmoi Modify vs Templates for Agent Configs

**Date:** 2025-12-12
**Author:** Claude Code (Technical Researcher Role)
**Context:** Investigating whether to use `chezmoi modify` or standard templates for managing AI agent configuration files
**Status:** ✅ Complete

---

## Executive Summary

**Recommendation:** **Keep current template-based approach** for `.claude/` and `.codex/` configuration files.

**Rationale:**
- Current templates are well-designed and appropriate for these files
- Files are primarily static configs with occasional user modifications
- Templates handle dynamic values (paths, env vars) efficiently
- `chezmoi modify` is better suited for heavily app-modified files (like KDE Plasma configs)

---

## Research Scope

### Questions Investigated

1. **What is `chezmoi modify`?** How does it differ from standard templates?
2. **When should we use `chezmoi modify`?** vs standard templates?
3. **Current state analysis:** What files do we have and how are they managed?
4. **Recommendation:** What approach should we take for agent configs?

---

## 1. Understanding `chezmoi modify`

### What It Is

`chezmoi modify` refers to two mechanisms:

#### A) `modify_` Prefix Scripts
- **Purpose:** Transform existing file content instead of replacing it entirely
- **How it works:**
  - Script receives current file contents on STDIN
  - Script outputs new contents to STDOUT
  - chezmoi replaces file only if output differs
- **Use case:** Files that external programs modify, where you want to selectively update parts

**Example:** Ensure environment variables exist without overwriting entire file
```bash
#!/bin/bash
# File: modify_dot_envrc
tmpfile=$(mktemp)
trap "rm -f ${tmpfile}" EXIT
cat > "${tmpfile}"

# Write existing content
cat "${tmpfile}"

# Add missing variables
if ! grep -q ^KEY= "${tmpfile}"; then
    echo "export KEY=VALUE"
fi
```

#### B) `chezmoi:modify-template` Marker
- **Purpose:** Use Go templates to transform existing file content
- **How it works:**
  - File contains `{{- /* chezmoi:modify-template */ -}}` marker
  - Rest of file is a Go template
  - Current file contents available as `.chezmoi.stdin`
  - Template output becomes new file content
  - File must NOT have `.tmpl` extension

**Example:** Update specific JSON values
```go
{{- /* chezmoi:modify-template */ -}}
{{ fromJson .chezmoi.stdin | setValueAtPath "key.nestedKey" "value" | toPrettyJson }}
```

### Difference from Standard Templates

| Feature | Standard Template (`.tmpl`) | `modify_` Script |
|---------|----------------------------|------------------|
| **Input** | Template variables only | Current file content + template vars |
| **Output** | Replaces entire file | Transforms existing content |
| **File Management** | Fully managed by chezmoi | Partially managed (selective updates) |
| **Use Case** | Static/controlled configs | Dynamic/app-modified configs |
| **Execution** | On `chezmoi apply` | On `chezmoi apply` |
| **Idempotency** | Automatic | Must be designed into script |

---

## 2. When to Use Each Approach

### Use Standard Templates (`.tmpl`) When:

✅ **You control most/all of the file content**
- Config files you edit manually or through chezmoi
- Files that don't get modified by applications
- Static configurations with some dynamic values (paths, hostnames)

✅ **File structure is stable and predictable**
- JSON/TOML/YAML configs where you define the schema
- Shell rc files where you control all exports
- Application settings where you set preferences

✅ **Examples:**
- `~/.gitconfig` (user-controlled, rarely modified by apps)
- `~/.bashrc` (user-controlled shell init)
- `~/.config/app/settings.json` (if app doesn't modify it)
- `~/.claude/mcp_config.json` (MCP server definitions - stable)

### Use `chezmoi modify` When:

✅ **Applications heavily modify the file**
- KDE Plasma configs (window positions, recent files, UUIDs)
- IDE settings that store session state
- Files with volatile/runtime-generated content you don't care about

✅ **You only want to ensure specific values exist**
- Add/update specific keys in JSON without managing entire file
- Ensure environment variables are set without controlling all exports
- Transform portions of config while preserving app-generated content

✅ **Files have unpredictable or dynamic sections**
- Configs with auto-generated IDs, timestamps, or session data
- Files where apps add their own sections you don't want to track

✅ **Examples:**
- `~/.config/plasmarc` (Plasma heavily modifies window positions, UUIDs)
- `~/.config/dolphinrc` (file manager stores recent files, window sizes)
- `~/.envrc` (you want specific exports but app might add others)
- `~/.vscode/settings.json` (if VS Code frequently updates it)

---

## 3. Current State Analysis

### Files in `~/.claude/`

| File | Current Management | App Modifies? | Recommendation |
|------|-------------------|---------------|----------------|
| **CLAUDE.md** | None (will be home-manager symlink) | ❌ No (user-controlled) | ✅ Symlink (per plan) |
| **mcp_config.json** | ✅ chezmoi template (mcp_config.json.tmpl) | ❌ No (user-controlled) | ✅ Keep template |
| **settings.json** | ✅ chezmoi template (settings.json.tmpl) | ⚠️ Rarely (user preferences) | ✅ Keep template |
| **settings.local.json** | ❌ Not managed | ✅ Yes (local overrides) | ✅ Ignore (local only) |
| **commands/*.md** | ✅ chezmoi (plain files) | ❌ No | ✅ Keep as-is |
| **.credentials.json** | ❌ Not managed | ✅ Yes (secrets) | ❌ Never manage (secrets) |
| **claude.json** | ❌ Not managed | ✅ Yes (runtime state) | ❌ Never manage (runtime) |
| **config/git-token.json** | ❌ Not managed | ✅ Yes (secrets) | ❌ Never manage (secrets) |
| **cache/**, **file-history/**, etc. | ❌ Not managed | ✅ Yes (runtime data) | ❌ Never manage (runtime) |

### Files in `~/.codex/`

| File | Current Management | App Modifies? | Recommendation |
|------|-------------------|---------------|----------------|
| **AGENTS.md** | None (will be home-manager symlink) | ❌ No (user-controlled) | ✅ Symlink (per plan) |
| **config.toml** | ✅ chezmoi template (config.toml.tmpl) | ⚠️ Rarely (user config) | ✅ Keep template |
| **auth.json** | ❌ Not managed | ✅ Yes (auth tokens) | ❌ Never manage (secrets) |
| **history.jsonl** | ❌ Not managed | ✅ Yes (session history) | ❌ Never manage (runtime) |
| **version.json** | ❌ Not managed | ✅ Yes (version tracking) | ❌ Never manage (runtime) |
| **log/**, **sessions/** | ❌ Not managed | ✅ Yes (runtime data) | ❌ Never manage (runtime) |

### Current Template Quality Analysis

#### `private_dot_claude/settings.json.tmpl`
**Lines:** 145
**Complexity:** Medium
**Dynamic Elements:**
- Template variable for home directory: `{{ .chezmoi.homeDir }}`
- Permissions patterns for allow/deny/ask
- Hooks configuration
- MCP server definitions
- Theme and feature flags

**Assessment:** ✅ **Well-designed template**
- Properly uses template variables for paths
- Handles permissions comprehensively
- Clear structure
- Suitable for template approach (file is mostly static)

#### `private_dot_codex/config.toml.tmpl`
**Lines:** 93
**Complexity:** Medium-High
**Dynamic Elements:**
- Template variable for home directory: `{{ .chezmoi.homeDir }}`
- MCP server configurations with paths
- Wrapper script paths
- Feature flags

**Assessment:** ✅ **Well-designed template**
- Properly uses template variables for paths
- Clean TOML structure
- All MCP servers properly configured
- Suitable for template approach (file is mostly static)

---

## 4. Detailed Recommendations

### A) Keep Current Template Approach

**For: `.claude/settings.json` and `.codex/config.toml`**

**Why:**
1. **Files are primarily user-controlled**
   - You modify these when changing permissions, MCP servers, or features
   - Applications rarely modify these files automatically
   - When modified, it's deliberate user action

2. **Current templates are well-designed**
   - Proper use of `{{ .chezmoi.homeDir }}` for portability
   - Clean, maintainable structure
   - Easy to understand and update

3. **No unpredictable app modifications**
   - Claude Code doesn't randomly update `settings.json`
   - Codex doesn't auto-modify `config.toml`
   - User is in control of when/how these change

4. **Template advantages apply**
   - Cross-platform paths handled cleanly
   - Easy to version and track changes
   - Simple apply/rollback workflow

### B) Files to NEVER Manage

**Runtime/Cache Files:**
- `.claude/cache/`, `.claude/file-history/`, `.claude/session-env/`
- `.claude/todos/`, `.claude/plans/`, `.claude/debug/`
- `.claude/history.jsonl`, `.claude/claude.json`
- `.codex/history.jsonl`, `.codex/log/`, `.codex/sessions/`

**Reason:** These are runtime-generated, change constantly, no value in tracking

**Secrets/Auth Files:**
- `.claude/.credentials.json`, `.claude/config/git-token.json`
- `.codex/auth.json`

**Reason:** Security risk, should be in KeePassXC or env vars, not version control

**Local Overrides:**
- `.claude/settings.local.json`

**Reason:** Machine-specific overrides, shouldn't be synced

### C) Files Already Correctly Managed

**chezmoi (plain files):**
- `.claude/commands/*.md` - Static slash command files

**Reason:** No dynamic content, simple files, chezmoi perfect for this

**home-manager (symlinks - per today's plan):**
- `.claude/CLAUDE.md` → `llm-core/config/global-config.md`
- `.codex/AGENTS.md` → `llm-core/config/global-config.md`
- `.gemini/AGENTS.md` → `llm-core/config/global-config.md` (future)

**Reason:** Single source of truth for global instructions, declarative Nix management

---

## 5. Comparison: Current Approach vs `chezmoi modify`

### Scenario: Updating MCP Server in `settings.json`

#### Current Approach (Template)
```bash
# 1. Edit template
chezmoi edit ~/.claude/settings.json

# 2. Add new MCP server in JSON
# (in template editor, add to mcpServers section)

# 3. Apply
chezmoi apply ~/.claude/settings.json

# 4. Done
```

**Pros:**
- ✅ Simple, straightforward
- ✅ Full control over file content
- ✅ Easy to review in git diff
- ✅ Idempotent by design

**Cons:**
- ⚠️ If app modifies file, next apply overwrites changes
  - **But:** Claude Code rarely auto-modifies settings.json
  - **Mitigation:** settings.local.json for local overrides

#### `chezmoi modify` Approach

**Option 1: modify-template**
```text
{{- /* chezmoi:modify-template */ -}}
{{ $settings := fromJson .chezmoi.stdin }}
{{ $settings := $settings | setValueAtPath "mcpServers.newServer" (dict "command" "path" "args" (list)) }}
{{ $settings | toPrettyJson }}
```

**Option 2: modify_ script**
```bash
#!/bin/bash
tmpfile=$(mktemp)
trap "rm -f ${tmpfile}" EXIT
cat > "${tmpfile}"

# Use jq to add MCP server
jq '.mcpServers.newServer = {"command": "path", "args": []}' "${tmpfile}"
```

**Pros:**
- ✅ Preserves app-modified content
- ✅ Selectively updates only what you care about

**Cons:**
- ❌ More complex to write and maintain
- ❌ Harder to review (logic in script, not data)
- ❌ Debugging is more difficult
- ❌ Overkill for files you fully control

### Verdict: Template is Better for Agent Configs

**Reason:** We fully control these files, apps don't modify them unpredictably, simplicity wins.

---

## 6. When to Reconsider

### Signals That `chezmoi modify` Might Be Needed

If you observe:

1. **Claude Code starts auto-modifying `settings.json` frequently**
   - Feature flags change automatically
   - App adds new keys you don't care about
   - Your template keeps getting out of sync

2. **Codex starts generating config dynamically**
   - Auto-adds MCP servers
   - Generates session-specific config
   - Your template can't keep up with changes

3. **You want selective updates**
   - Only ensure certain permissions exist
   - Only set specific feature flags
   - Don't care about rest of file

### How to Migrate to `modify_` If Needed

**Step 1: Backup current template**
```bash
cp $(chezmoi source-path)/.../settings.json.tmpl \
   $(chezmoi source-path)/.../settings.json.tmpl.backup
```

**Step 2: Create modify-template**
```bash
# Remove .tmpl extension, add modify-template marker
cat > $(chezmoi source-path)/.../modify_settings.json << 'EOF'
{{- /* chezmoi:modify-template */ -}}
{{ $s := fromJson .chezmoi.stdin }}
{{ $s := $s | setValueAtPath "permissions.allow" (list "pattern1" "pattern2") }}
{{ $s | toPrettyJson }}
EOF
```

**Step 3: Test**
```bash
chezmoi diff ~/.claude/settings.json
```

**Step 4: Apply if satisfied**
```bash
chezmoi apply ~/.claude/settings.json
```

---

## 7. Final Recommendations Summary

### ✅ DO (Current State is Good)

1. **Keep using templates** for `settings.json` and `config.toml`
2. **Keep `.chezmoiignore` entries** for runtime/cache files (as updated today)
3. **Use home-manager symlinks** for CLAUDE.md/AGENTS.md (as planned today)
4. **Continue using chezmoi_modify_manager** for Plasma configs (existing successful pattern)

### ❌ DON'T

1. **Don't migrate to `modify_` scripts** for agent configs (unnecessary complexity)
2. **Don't try to manage** runtime files (cache, history, sessions)
3. **Don't version control** secrets (auth.json, credentials.json, tokens)
4. **Don't overthink it** - current approach is solid

### 📋 Action Items

1. ✅ **Document current approach** (this document)
2. ✅ **Validate `.chezmoiignore`** is comprehensive (done today)
3. ✅ **Confirm template quality** (analyzed above - good quality)
4. ⏭️ **Proceed with symlink plan** (llm-global-instructions-symlinks.nix from today)
5. ⏭️ **Test home-manager switch** when ready
6. ⏭️ **Monitor for issues** - if apps start auto-modifying files, revisit

---

## 8. Conclusion

**Current template-based approach is correct for `.claude/` and `.codex/` configuration files.**

**Rationale:**
- Files are user-controlled, not heavily app-modified
- Templates handle dynamic values (paths) efficiently
- Current templates are well-designed and maintainable
- `chezmoi modify` would add unnecessary complexity
- We already successfully use `chezmoi_modify_manager` for files that need it (Plasma configs)

**Path Forward:**
- Continue with today's plan (home-manager symlinks for global instructions)
- Keep existing chezmoi templates for settings/config files
- Monitor for changes in app behavior that might warrant modify_ approach
- Document and move forward with confidence

---

## Research Metadata

**Research Duration:** ~45 minutes
**Web Research Tools Used:** firecrawl, context7, web search
**Local Investigation:** File analysis, template review, current state audit
**Confidence in Recommendation:** 0.92 (Band C - SAFE)
**Review Date:** 2026-03-12 (3 months - reassess if app behavior changes)

---

**Research completed successfully. Ready to proceed with implementation plan.** ✅

