# Claude Code ↔ Atuin Integration Execution Plan (for Claude Code)

> This document is intended to be read and executed by Claude Code inside the user’s environment.
> When any step requires external documentation, use the **web MCP** to read GitHub pages and
> use the **context7 MCP** (or equivalent semantic search MCP) to search local project docs and notes.

---

## 0. High-Level Goal

Integrate **Claude Code** with **Atuin** using the `bash-history-mcp` project so that:

1. Any Bash command executed through Claude Code is **logged into Atuin history**.
2. Claude Code can **query Atuin history** via MCP tools to retrieve relevant commands and context.
3. When additional details are needed from the internet, Claude uses **web MCP** to search GitHub and documentation.
4. When additional details are needed from local knowledge, Claude uses **context7 MCP** (or similar) to search local notes/configs.

---

## 1. Prerequisites Validation

For all checks below, Claude Code should:
- Use the **terminal/bash tool** to run commands.
- Use **web MCP** to consult official docs where necessary.

### 1.1. Atuin

**Tasks**

1. Run:
   ```bash
   atuin --version
   ```
   Confirm that Atuin is installed.

2. Run:
   ```bash
   atuin history list | head
   ```
   Confirm that Atuin is able to show history.

3. Open the user’s shell configuration files (e.g. `~/.bashrc`, `~/.zshrc`) with the file tool and verify Atuin is initialized, e.g. something similar to:
   ```bash
   eval "$(atuin init bash)"
   ```

4. If anything is missing or broken:
   - Use **web MCP** to search: `atuin shell history install` and open the official Atuin docs.
   - Follow installation / init instructions for the user’s shell.

### 1.2. Claude Code CLI

**Tasks**

1. Run:
   ```bash
   claude --help
   ```
   Confirm the CLI is available.

2. If the command fails:
   - Use **web MCP** to search: `Claude Code CLI install`.
   - Open the official Anthropic docs and follow the installation instructions for the current OS.

### 1.3. Bun Runtime

**Tasks**

1. Run:
   ```bash
   bun --version
   ```
   If this fails, install Bun:
   ```bash
   curl -fsSL https://bun.sh/install | bash
   ```

2. Ensure Bun is on the PATH in the shell configuration that Claude uses.
   - Open `~/.bashrc` or equivalent and check the installed Bun path export.

3. If needed, use **web MCP** to open `https://bun.sh` and verify installation instructions.

---

## 2. Hook: Log Claude’s Bash Commands into Atuin (PostToolUse)

In this section, configure Claude’s **PostToolUse hook** so that each Bash command Claude runs is recorded into Atuin via `bash-history-mcp`.

### 2.1. Locate Claude Settings File

**Tasks**

1. Check for Claude settings file:
   - Expected paths (try in order):
     - `~/.claude/settings.json`
     - `~/.config/claude/settings.json`

2. If the file does not exist, create `~/.claude/settings.json` with minimal structure:
   ```json
   {
     "hooks": {
       "PostToolUse": []
     },
     "mcpServers": {}
   }
   ```

3. Open this file using the editor so it can be modified programmatically.

### 2.2. Inspect `bash-history-mcp` GitHub Repo

**Tasks**

1. Use **web MCP** to open the GitHub repository:
   - Search: `github nitsanavni bash-history-mcp`
   - Open the repository page.

2. Read the README carefully and identify:
   - Exact command for the **hook** mode (should look like `bunx github:nitsanavni/bash-history-mcp hook`).
   - Any environment variables or arguments required for the hook.
   - Any specific instructions for Claude’s settings integration.

3. Keep the relevant instructions in context while editing `settings.json`.

### 2.3. Add PostToolUse Hook for Bash Tool

**Conceptual behavior**

- After every Bash tool execution, Claude should call:
  ```bash
  bunx github:nitsanavni/bash-history-mcp hook
  ```
  with appropriate arguments so the tool can log to Atuin.

**Tasks**

1. In `settings.json`, locate the `hooks.PostToolUse` array.
2. Append a new object describing the hook, matching the Bash tool. The structure will be similar to (this is a template, adjust according to README):

   ```jsonc
   {
     "match": {
       "toolName": "bash"  // Adjust based on actual tool name in Claude settings
     },
     "command": "bunx",
     "args": [
       "github:nitsanavni/bash-history-mcp",
       "hook"
     ]
   }
   ```

3. Validate the JSON syntax (no trailing commas, correct quotes).
4. Save the file.

5. If the README for `bash-history-mcp` indicates additional arguments or env variables, incorporate them exactly as documented.

### 2.4. Test Hook Functionality

**Tasks**

1. Restart Claude Code / the editor so the new settings are loaded.
2. Through Claude’s Bash tool, run a simple command:
   ```bash
   echo "hello-from-claude-hook-test"
   ```

3. In the user’s normal terminal (outside Claude), run:
   ```bash
   atuin history search "hello-from-claude-hook-test"
   ```

4. Confirm that the command appears in Atuin history.

5. If it does **not** appear:
   - Use **web MCP** to re-open the `bash-history-mcp` README.
   - Check for any troubleshooting section specific to the hook.
   - Confirm that:
     - `bunx` is available in the environment Claude uses.
     - The `match` condition correctly targets the Bash tool.
     - `settings.json` is in the correct location for this Claude installation.

---

## 3. Register `bash-history-mcp` as MCP Server (Read Path)

This section enables Claude to **query Atuin history** via MCP tools such as `search_history` and `get_recent_history`.

### 3.1. Understand the MCP Server Command

From the GitHub README (use **web MCP** if needed):

- The MCP server is typically started as:
  ```bash
  bunx github:nitsanavni/bash-history-mcp mcp
  ```

- Claude needs an entry in `settings.json` under `mcpServers` describing this.

### 3.2. Add MCP Server Entry

**Tasks**

1. In `~/.claude/settings.json`, locate or create the `"mcpServers"` object.
2. Add a new entry for `bash-history`, for example:

   ```jsonc
   "bash-history": {
     "command": "bunx",
     "args": [
       "github:nitsanavni/bash-history-mcp",
       "mcp"
     ]
   }
   ```

3. Ensure JSON syntax is valid.
4. Save the file.

> If the README specifies any additional settings (e.g. env vars, extra args), incorporate them exactly as documented.

### 3.3. Restart Claude Code and Validate MCP Tools

**Tasks**

1. Restart Claude Code / editor to load the MCP server.
2. Ask Claude (from inside the editor):
   - "List tools available from the bash-history MCP server."  
   or
   - Directly request:
     - "Use the bash-history MCP tool to get my most recent shell commands."

3. Confirm tools similar to the following exist and function:
   - `bash-history.search_history`
   - `bash-history.get_recent_history`

4. Test a concrete query:

   - Ask: "Use bash-history to get my last 10 commands, then summarize what I've been working on."

5. If tools are not available or fail:
   - Use **web MCP** to re-open the GitHub repo and look for an example `settings.json` snippet.
   - Check that `bunx` is callable from the environment where Claude runs.

---

## 4. Workflow Usage Guidelines

Once the integration works, use the following patterns.

### 4.1. Shared History Between User and Claude

- All commands run by the user are stored by Atuin as usual.
- Commands run by Claude via Bash are now also stored in the same Atuin DB.
- Both user and Claude see the same historical command universe.

### 4.2. Querying History via Claude

Example user instructions (from within Claude Code):

1. "Search my Atuin history for all kubectl commands used in the last week and summarize the main patterns."
2. "Find the last terraform plan command I ran for production and show me the exact arguments."
3. "Show me the last 20 commands involving 'nginx' and summarize what issues I was debugging."

Claude should:
- Call `bash-history.search_history` with a query string.
- Possibly call `bash-history.get_recent_history` to fetch a window of recent commands.
- Use its own reasoning to filter, summarize, and propose improved commands.

### 4.3. Turning Patterns into Better Tooling

When recurring command patterns are discovered, Claude can:

- Suggest turning them into:
  - Shell functions.
  - Scripts.
  - `navi` cheatsheets.
- Use **context7 MCP** to find related notes or documentation in the user’s local knowledge base that should be updated with these patterns.

---

## 5. Using web MCP and context7 MCP Effectively

### 5.1. web MCP Usage

Whenever a step requires external information or precise instructions, Claude should:

- Use **web MCP** to:
  - Search for `bash-history-mcp github` and open the README.
  - Search installation docs for Atuin, Bun, or Claude Code if commands fail.
  - Check any referenced blog posts or examples mentioned in the README.

**Always** prefer official / primary sources for configuration and arguments.

### 5.2. context7 MCP Usage

Whenever local context is needed (notes, configs, internal docs), Claude should:

- Use **context7 MCP** (or equivalent semantic search MCP) to:
  - Search for existing notes about Atuin, Claude, shell config, or history.
  - Locate internal documentation about how the user organizes their workspace.
  - Find any previous plans, TODOs, or design docs related to shell tooling and automation.

Example query to context7:
- "Search my local notes for 'Atuin' and 'Claude' and show any previous integration attempts."

Claude can then adapt this execution plan to align with the user’s existing conventions.

---

## 6. Validation and Maintenance

### 6.1. Regular Smoke Tests

Periodically, Claude should help the user verify the integration:

1. Run a new Bash command via Claude.
2. Confirm it appears in Atuin with `atuin history search`.
3. Use the `bash-history` MCP tools to fetch that command back.

If anything breaks:
- Use **web MCP** to check the latest version and docs of `bash-history-mcp`.
- Use **context7 MCP** to check any local change logs or notes about configuration changes.

### 6.2. Iterative Improvement

Over time, Claude and the user can:

- Extend the MCP server or add another one that performs **semantic embedding search** over Atuin history.
- Integrate additional data sources (Terraform logs, Ansible ARA data, etc.) using the same MCP pattern.
- Refine settings so that work and personal histories are separated when needed.

---

End of plan.

