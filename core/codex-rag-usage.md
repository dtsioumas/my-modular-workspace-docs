# Codex + CK RAG Usage & Ops Log (2025-12-26)

## Baseline Context
- `ck --status` (21:05 EET): 811 files / 9 772 chunks indexed with `nomic-embed-text-v1.5`; GPU tuning already active via `ck-wrapper`. This is the reference state prior to scheduling updates.

## ck-index Timer Activation
```
XDG_RUNTIME_DIR=/run/user/1001 \
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1001/bus \
systemctl --user status ck-index.timer --no-pager

● ck-index.timer - ck semantic search auto-indexing timer
     Loaded: loaded (/home/mitsio/.config/systemd/user/ck-index.timer; enabled)
     Active: active (running) since Fri 2025-12-26 21:42:49 EET
    Trigger: n/a (first shot after cadence change to every 2h)
```
- Cadence updated to **every 2 hours** via `OnCalendar=*-*-* *:00/2:00`.
- Reminder: timer runs ck-index.service from `~/.config/ck/ck-index.service`.

## GPU Snapshot (for log hygiene)
Command: `~/.local/bin/monitor-gpu.sh` (21:44 EET)
```
GPU: NVIDIA GeForce GTX 960 | Memory 1875 / 4096 MB
Utilization: GPU 3 %, Memory 6 % | Temp 55 °C | Power 25.73 W
Per-process GPU usage: none (idle baseline)
```
- Use this baseline to compare against future CK indexing runs (expect ~37‑40 % GPU util).

## Upcoming Validation Runs (placeholders)
| Session | Task Focus | `/status` Weekly % | Token % Used | Notes |
|---------|------------|--------------------|--------------|-------|
| A | _TBD (feature implementation)_ | _pending_ | _pending_ | Run `/ck-rag-pass` first, capture `codex /status --json` before/after |
| B | _TBD (code review)_ | _pending_ | _pending_ | Same workflow; store transcripts in `sessions/2025-12-26-codex-rag/` |

Add `codex-status` helper: `codex /status --json >> sessions/2025-12-26-codex-rag/USAGE.md` after each run.
