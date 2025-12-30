# Plan: Codex + CK RAG Rollout
**Date:** 2025-12-26  
**Owners:** Mitsos (Ops), Codex Maintainers  
**Inputs:** `docs/tools/codex/rag-token-optimization.md`, `dotfiles/private_dot_codex/config.toml.tmpl`, `dotfiles/private_dot_config/ck/`.

---

## 1. Objective
Implement a CK-first Retrieval-Augmented Generation workflow for Codex CLI/IDE that:
- Cuts per-session token consumption by ≥40 % through semantic retrieval before any `read_file`.
- Keeps MCP/tool overhead minimal so prompts stop breaching weekly limits.citeturn1search2turn1search6turn1reddit14
- Provides auditable Ops guardrails (systemd timers, usage logs, MCP inventory).

## 2. Deliverables
1. Updated Codex configuration (`profiles.rag`, new commands, AGENTS.md reminders).
2. Verified CK automation (index timer, wrapper, GPU monitor).
3. Usage telemetry + runbook describing how to measure savings.
4. Post-implementation review captured in `sessions/<date>/USAGE.md`.

## 3. Phases & Tasks

| Phase | Scope | Tasks | Exit Criteria |
|-------|-------|-------|---------------|
|**0. Baseline Audit**|Confirm current state before touching config.|- `ck --status` & `journalctl -u ck-index.service` logs attached.<br>- `codex /status --json` captured for before/after comparison.<br>- MCP inventory reviewed; note which servers can be disabled.|Baseline log stored in `sessions/gpu-optimization-baseline/USAGE.md`.|
|**1. Config Updates**|Apply changes defined in the new RAG doc.|- Add `[profiles.rag]` block.<br>- Create `~/.codex/commands/rag.md` + `skills/rag-workflow`.<br>- Extend AGENTS.md with CK reminders.<br>- Flip `sandbox_mode` back to `workspace-write` once confidence is high.|Codex `config-check` passes; `/ck-rag-pass` command available in CLI.|citeturn1search0turn1search4|
|**2. Ops Automation**|Ensure CK + logs stay healthy.|- Enable/verify `ck-index.timer` (1–4 h cadence).<br>- Deploy `ck-rag` helper script to `.local/bin`. <br>- Add `codex-status` alias to capture usage JSON after every session.<br>- Document GPU expectations (35‑40 % util) in Ops wiki.|24 h later timer fired twice; GPU and usage logs present.|
|**3. Validation & Guardrails**|Prove the workflow lowers tokens and doesn’t blow limits.|- Run two representative Codex tasks (feature build + review) using `/ck-rag-pass` first.<br>- Capture token consumption deltas vs. baseline.<br>- File issues for any MCP that still balloons prompts.citeturn1search1turn1search5|Metrics show ≥40 % reduction; open issues documented if regressions occur.|
|**4. Handoff**|Publish guidance & next steps.|- Update `docs/tools/codex/rag-token-optimization.md` with observations.<br>- Summarise in `sessions/summaries/` for continuity.<br>- Decide whether to roll the workflow into other hosts (kinoite, WSL).|Summary posted; backlog tickets created for multi-host rollout.|

## 4. Risk Log
| Risk | Impact | Mitigation |
|------|--------|------------|
|CK index out-of-date → inaccurate results|High|Timer health check + weekly manual `ck --status`.|
|Codex still pastes giant files when commands skipped|Med|Team agreement to use `/ck-rag-pass` + CI lint that looks for `semantic_search` events in transcripts.|
|MCP schema regressions break config validation|Med|Track upstream issue #6426; run `codex --config-check` prior to each rebuild.citeturn1reddit18turn1search6|

## 5. Acceptance Criteria
- Two signed-off transcripts demonstrating the RAG workflow.  
- Usage log shows <10 % weekly quota consumed per long session.  
- Documentation + plan stored in git; future agents can replay the setup without oral context.

## Progress Log (2025-12-26)
- [x] Phase 0 / Phase 1: Added `[profiles.rag]`, created `/ck-rag-pass`, and extended project instructions (AGENTS) with the CK reminder.
- [x] Phase 2: Adjusted `ck-index.timer` cadence to every 2 hours, re-enabled via systemd, and captured GPU baseline using `monitor-gpu.sh`. Usage tracking lives in `sessions/2025-12-26-codex-rag/USAGE.md`.
- [ ] Phase 3: Validation runs pending — Codex CLI access requires the usual API credentials; once available, run two sessions with `/ck-rag-pass` and append token percentages to the usage log plus this plan.
