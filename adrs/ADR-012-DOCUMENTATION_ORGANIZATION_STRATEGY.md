# ADR-012: Unified Documentation & Project Repository Structure

**Date:** 2025-12-29
**Status:** Supersedes ADR-012 (2025-12-20)
**Context:** Documentation consolidation across multi-repo workspace to minimize context fragmentation and maximize agent efficiency.

---

## 1. The "Single Source of Truth" Philosophy

To ensure that AI agents and human developers can efficiently locate context without wading through redundant or outdated files, the `docs/` repository is organized into **Topic-Based Project Clusters**.

### Rule 1: Topic-Based Clustering
Documentation is no longer split primarily by "type" (Plan vs Research). Instead, everything related to a specific project or complex tool is stored together in a subdirectory under `docs/projects/`.

**Standard Project Sub-structure:**
- `INDEX.md`: Master table of contents for the project.
- `RESEARCH.md`: COMPACTED research findings. Old researches are merged and deleted.
- `PLAN.md`: The active/current implementation plan. Past plans are merged or moved to the issues archive.
- `USAGE.md`: User-facing guides, cheatsheets, and quick references.
- `TESTING.md`: Verification steps and checklists.

### Rule 2: Compaction & Deletion
- **NO redundant context:** When new research is completed, the findings must be integrated into the master `RESEARCH.md` for that topic.
- **Delete old versions:** Once unique context is captured in the master file, the source/dated research file MUST be deleted to save token/context space.
- **Minimize Archive:** Do not move things to `archive/` if they can be merged or if they are no longer relevant. Only use `archive/` for truly deprecated system history.

### Rule 3: Issues Archive
Technical debt, post-mortems, and "how I fixed it" documentation must be extracted into `docs/issues-archive/`.
- Format: `YYYY-MM-DD-short-description.md`.
- Content: Clear "Problem" and "Resolution" sections.
- Purpose: Provides a historical "Fix-it" database for agents to reference when encountering similar errors.

### Rule 4: Sessions Cleanup
- The root `sessions/` directory is for **Conversational History** (summaries, continuations, prompts) ONLY.
- Any documentation, research, or TODOs generated during a session MUST be moved to the appropriate `docs/projects/` directory at the end of the session.

---

## 2. Directory Structure

```
docs/
├── projects/           # Multi-file projects/topics
│   ├── kitty/          # Merged research, plans, and usage for Kitty
│   ├── mcp/            # Merged MCP architecture and optimization
│   ├── sync/           # Rclone, Syncthing, and GDrive migration
│   ├── home-manager/   # Refactoring and modularity docs
│   ├── plasma/         # KDE Plasma configuration and themes
│   └── semantic-tools/ # ck, semtools, and semantic-grep
├── tools/              # Single-file documentation for simple tools
├── issues-archive/     # Post-mortems and resolutions
├── adrs/               # Architecture Decision Records
└── core/               # High-level workspace strategy and audits
```

---

## 3. Implementation Workflow for Agents

When an agent needs to document something new:
1. **Identify Topic:** Determine if the task belongs to an existing Project Cluster.
2. **Read INDEX.md:** Understand the current state of that topic.
3. **Update Master Files:**
    - Add to `RESEARCH.md` if it's new knowledge.
    - Update `PLAN.md` if it's a new implementation step.
4. **Clean Up:** If a session file was used, move its content to `docs/` and delete the original.

---

## 4. Consequences

### Positive
- ✅ **Token Efficiency:** Agents don't read 5 different versions of the same research.
- ✅ **Faster Discovery:** All info for a topic is in one predictable directory.
- ✅ **Better Continuity:** New sessions can instantly grasp the "Master State" of a project.

### Negative
- ⚠️ **Destructive by Design:** Old research files are deleted. If "raw" history is needed, it must be retrieved from Git history.
- ⚠️ **Maintenance Overhead:** Requires active effort to merge and "compact" rather than just adding new files.

---

**Approved By:** Mitsos
**Date:** 2025-12-29