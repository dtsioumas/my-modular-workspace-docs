# ADR-012: Documentation Organization Strategy

**Date:** 2025-12-20
**Status:** Accepted
**Context:** Documentation organization across multi-repo workspace
**Decision Makers:** Mitsos

---

## Context

The `my-modular-workspace` project consists of multiple Git repositories:
- `docs/` - Centralized documentation repository
- `home-manager/` - Home Manager user environment configuration
- `hosts/shoshin/nixos/` - NixOS system configuration
- `ansible/` - Ansible automation playbooks
- `chezmoi/` - Dotfiles management

**Problem:**
- Documentation was scattered across repositories
- Duplicate docs existed (e.g., multiple READMEs)
- No clear policy on where docs should live
- Hard to discover documentation

**Examples of Issues:**
- `home-manager/README.md` + `home-manager/docs/*.md` + `docs/home-manager/*.md`
- Unclear whether to document in repo or centralized docs/
- AI assistant instructions (WARP.md, AGENTS.md, CLAUDE.md) location unclear

---

## Decision

### Rule 1: Centralized Documentation Repository

**ALL detailed documentation lives in `docs/` repo**, organized by domain:

```
docs/
├── home-manager/     # Home Manager docs
├── nixos/            # NixOS system docs
├── ansible/          # Ansible docs
├── chezmoi/          # Dotfiles docs
├── tools/            # Tool-specific docs (warp, kde-connect, etc.)
├── services/         # Service docs
└── adrs/             # Architecture Decision Records
```

### Rule 2: README.md Exception

**Every repository MUST have its own `README.md`** in the root:

```
home-manager/
├── README.md         ✓ KEEP (repo-specific overview)
├── flake.nix
└── ... (no other docs here)

hosts/shoshin/nixos/
├── README.md         ✓ KEEP (repo-specific overview)
└── ...

docs/
├── README.md         ✓ Master documentation index
└── */
```

**Purpose of repo README.md:**
- Quick start / setup instructions
- Link to detailed docs in `docs/` repo
- Repo-specific context (architecture, usage, key files)

### Rule 3: AI Instructions Location

**AI assistant instructions stay in their functional location:**

```
home-manager/
├── WARP.md           ✓ KEEP (WARP reads from repo root)
├── AGENTS.md         ✓ KEEP (agents read from repo root)
└── CLAUDE.md         ✓ KEEP (Claude reads from repo root)
```

**Rationale:** These files are functional configuration for AI tools, not documentation for humans. They must stay where the tools expect to find them.

### Rule 4: No Nested docs/ in Repos

**Repositories MUST NOT have `<repo>/docs/` subdirectories.**

```bash
# ❌ WRONG
home-manager/
└── docs/
    ├── TODO.md
    └── guide.md

# ✓ CORRECT
home-manager/
└── README.md     # Links to docs/ repo

docs/
└── home-manager/
    ├── TODO.md
    └── guide.md
```

**Exception:** Temporary session docs during active work may exist briefly but must be moved to `docs/` before session completion.

---

## Migration Process (Completed 2025-12-20)

### What Was Moved

From `home-manager/` to `docs/home-manager/`:
- ✓ `docs/package-upgrade-guide.md` → `docs/home-manager/package-upgrade-guide.md`
- ✓ `docs/hardware-profile-system.md` → `docs/home-manager/hardware-profile-system.md`
- ✓ `docs/TODO.md` → `docs/home-manager/CODEX_INSTALLATION_LOG.md` (renamed for clarity)

### What Was Kept in home-manager/

- ✓ `README.md` - Repo overview (per Rule 2)
- ✓ `WARP.md` - AI instructions (per Rule 3)
- ✓ `AGENTS.md` - AI instructions (per Rule 3)
- ✓ `CLAUDE.md` - AI instructions (per Rule 3)

### Cleanup

- ✗ Removed `home-manager/docs/` subdirectory (empty after migration)
- ✓ Updated `docs/home-manager/INDEX.md` to point to all available docs

---

## Consequences

### Positive

✓ **Single source of truth** - All docs in one place
✓ **Easier discovery** - Browse `docs/` to find everything
✓ **Consistent structure** - Clear organization by domain
✓ **No duplication** - Each topic documented once
✓ **Better README.md** - Each repo has focused, concise README linking to full docs
✓ **AI instructions preserved** - Tools continue working as expected

### Negative

⚠️ **Cross-repo navigation** - Need to switch repos to read detailed docs
⚠️ **README maintenance** - Must keep repo README in sync with docs/ content
⚠️ **Learning curve** - Contributors need to know the organization policy

### Neutral

- Repos become "code-focused" with minimal docs
- `docs/` repo becomes "documentation-focused"

---

## Compliance Checklist

When creating new documentation:

- [ ] Is this a README for a repo root? → Keep in repo
- [ ] Is this AI instructions (WARP.md, AGENTS.md, etc.)? → Keep in repo
- [ ] Is this detailed documentation? → Move to `docs/<domain>/`
- [ ] Does `docs/<domain>/INDEX.md` link to this new doc?
- [ ] Does repo README.md link to relevant docs in `docs/` repo?

---

## Related ADRs

- **ADR-001** - NixOS System (Stable) vs Home-Manager (Unstable)
- **ADR-010** - Unified MCP Server Architecture
- **This ADR (012)** - Documentation Organization

---

## References

- Docs repository: `~/.MyHome/MySpaces/my-modular-workspace/docs/`
- Home Manager README: `~/.MyHome/MySpaces/my-modular-workspace/home-manager/README.md`
- Documentation index: `~/.MyHome/MySpaces/my-modular-workspace/docs/home-manager/INDEX.md`

---

**Approved:** 2025-12-20
**Implementation:** Completed 2025-12-20
**Review Date:** 2026-03-20 (after 3 months of usage)
