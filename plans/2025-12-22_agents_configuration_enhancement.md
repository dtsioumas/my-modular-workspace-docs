# Plan: Agents Configuration Enhancement (2025-12-22)

**Status:** Final
**Owner:** Mitsio
**Context:** Week 52 - Enhancing Agents Config
**Reviewers:** Technical Researcher, Developer, Ops Engineer

## 1. Objectives
- **Optimization:** Configure 90% compaction threshold for all agents to maximize context usage.
- **Cleanup:** Remove redundant MCP servers (Filesystem, Git, Shell) from agent configurations to rely on native tools or specific replacements, reducing context overhead and potential conflicts.
- **Standardization:** Unify configuration management via Chezmoi templates.
- **Documentation:** Compact research into permanent docs.

## 2. Agent-Specific Enhancements

### 2.1 Claude Code
- **Compaction:** Implement manual/proactive compaction strategy (auto-compact setting not yet available).
- **MCP Cleanup:** Remove `filesystem-go`, `filesystem-rust`, `shell`, `git` from `mcp_config.json.tmpl`.
  - *Rationale:* Claude Code has native `Bash` and `Read`/`Write` tools that cover these functions.
- **Config:** Update `settings.json.tmpl` with `memory.limitMB: 4096`.

### 2.2 Gemini CLI
- **Compaction:** Set `model.compressionThreshold` to `0.9` in `settings.json.tmpl`.
- **MCP Cleanup:** Remove `filesystem-rust`, `shell`, `git` from `settings.json.tmpl` (mcpServers section).
  - *Rationale:* Enable `codebaseInvestigator` feature to provide native-like filesystem/search capabilities.
- **Features:** Ensure `codebaseInvestigator` is enabled in `experimental` section.

### 2.3 Codex
- **Compaction:** Set `model_auto_compact_token_limit` default (native handling).
- **MCP Cleanup:** Remove `filesystem`, `filesystem-rust`, `shell`, `git` from `config.toml.tmpl`.
  - *Risk Mitigation:* Verify `view_image_tool` and other native features. If FS access is lost, rollback and re-evaluate.
- **Memory:** Set `history.max_bytes` to 64MB.

## 3. Documentation Compaction
- Move `claude-code-research.md` -> `docs/tools/claude-code/optimization-research.md`
- Move `gemini-cli-research.md` -> `docs/tools/gemini-cli/optimization-research.md`
- Move `codex-research.md` -> `docs/tools/codex/optimization-research.md`
- Move `gpu-utilization-deep-research.md` -> `docs/researches/2025-12-22_agents_gpu_acceleration.md`
- Archive session files.

## 4. Execution Steps

### Phase 1: Documentation (Pre-Req)
1. Execute Compaction Structure Proposal.
2. Commit documentation changes.

### Phase 2: Configuration Updates (Chezmoi)
1. **Claude:** Edit `dotfiles/private_dot_claude/mcp_config.json.tmpl`.
2. **Gemini:** Edit `dotfiles/private_dot_gemini/settings.json.tmpl`.
3. **Codex:** Edit `dotfiles/private_dot_codex/config.toml.tmpl`.
4. **Apply:** Run `chezmoi apply` to deploy changes.

### Phase 3: Verification
1. **Claude:** Run `claude doctor` (or equivalent) and check `mcp list`. Verify file access.
2. **Gemini:** Run `gemini list-tools`. Verify `codebaseInvestigator` is active.
3. **Codex:** Run `codex --list-tools`. Verify native tools.

## 5. Rollback Plan
- Revert changes via Chezmoi if agents fail to start.
- `chezmoi apply` the previous state.