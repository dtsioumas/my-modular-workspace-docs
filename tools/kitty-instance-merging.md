# Kitty Terminal - Instance Merging & Management

**Date:** 2025-12-01
**Author:** Dimitris Tsioumas (Mitsio)
**Question:** Can I merge 2 separate kitty terminal instances into one?

---

## Short Answer

**No, you cannot directly merge two separate kitty OS window instances into one** without losing terminal state (command history, running processes, etc.).

However, there are several **workarounds** depending on your use case.

---

## Understanding Kitty Instances

### What is a Kitty "Instance"?

**Instance** = One kitty OS window (application window)

Each instance can have:
- Multiple **tabs**
- Multiple **windows** (splits) within each tab

### The Problem

When you launch kitty multiple times, you get **separate OS windows**:
```
Instance 1 (OS Window 1)
├── Tab 1
│   ├── Window 1
│   └── Window 2
└── Tab 2

Instance 2 (OS Window 2)  ← SEPARATE, cannot merge directly
├── Tab 1
└── Tab 2
```

You **cannot** move tabs/windows from Instance 2 into Instance 1 while preserving terminal state.

---

## Workarounds & Solutions

### Solution 1: Use One Instance with Tabs (RECOMMENDED)

**Best Practice:** Use **one kitty instance** with multiple tabs instead of multiple instances.

**How:**
- Launch kitty once
- Use `Ctrl+Shift+T` to create new tabs
- Use tabs to organize different projects/contexts
- Use windows (splits) within tabs for related tasks

**Benefits:**
- Easy navigation between contexts (Alt+Left/Right)
- No need to merge instances
- All in one OS window
- Lower memory footprint

**Example Organization:**
```
Kitty Instance (One OS Window)
├── Tab 1: Project A
│   ├── Window 1: Editor
│   └── Window 2: Logs
├── Tab 2: Project B
│   ├── Window 1: SSH session
│   └── Window 2: Local terminal
├── Tab 3: Monitoring
│   └── Window 1: htop/btop
└── Tab 4: Scratch (F12 dropdown also available)
```

---

### Solution 2: Remote Control (Move to Existing Instance)

**What:** Use kitty's remote control to create tabs in an existing instance

**Requirements:**
- Remote control must be enabled (already done in your config)
- Know the target instance (first instance launched)

**How to Move Content:**

**Step 1: Identify running kitty instances**
```bash
# List all kitty instances
kitty @ ls
```

**Step 2: Create new tab in specific instance**
```bash
# Create tab in first kitty instance
kitty @ --to unix:/tmp/kitty launch --type=tab --cwd=current

# Create tab with specific title
kitty @ launch --type=tab --title "My Project" --cwd ~/projects
```

**Step 3: Close the old instance manually**
- You'll need to manually recreate your work in the new tab
- Terminal state (history, running processes) **cannot** be transferred

**Limitations:**
- Cannot preserve terminal state (history, running programs)
- Manual work required to recreate environment
- Only useful for creating new tabs, not merging existing ones

---

### Solution 3: Use tmux/zellij Inside Kitty (Session Persistence)

**What:** Use a terminal multiplexer inside kitty for persistent sessions

**Recommended:** tmux or zellij

**How It Works:**
1. Start tmux/zellij in a kitty window
2. Create sessions/windows inside tmux/zellij
3. Detach from tmux/zellij
4. Attach from any kitty instance

**Benefits:**
- **True session persistence** - survives kitty restarts
- Can attach from different kitty instances
- Can "merge" by attaching to same session
- Survives SSH disconnects

**Example with zellij:**
```bash
# In first kitty instance
zellij attach -c work  # Create/attach to "work" session

# In second kitty instance
zellij attach work      # Attach to same "work" session
# Now both instances see the same terminal state!

# Detach from first instance
# The session persists

# Later, from any kitty instance
zellij attach work      # Resume exactly where you left off
```

**Why This Works:**
- tmux/zellij sessions are **independent of kitty**
- Multiple kitty instances can attach to the same session
- Session state is preserved even if kitty closes

**Setup:**
- Already planned in your TODO (Kitty Phase 2: Zellij Integration)
- See: `docs/plans/kitty-zellij-phase1-plan.md`

---

### Solution 4: Prevent Multiple Instances (Single Instance Mode)

**What:** Ensure only one kitty instance runs at a time

**How:** Use `--single-instance` flag (kitty 0.29+)

**Configuration:**
```bash
# In your shell alias or desktop launcher
alias kitty='kitty --single-instance'
```

**How It Works:**
- First launch: Creates new kitty instance
- Subsequent launches: Opens new tab in existing instance
- **Behavior like a browser** - all tabs in one window

**Benefits:**
- Never have multiple instances
- No need to merge
- Simplified workflow

**Trade-offs:**
- Can't have truly independent kitty windows
- All kitty windows share same process

**When to Use:**
- If you prefer browser-like behavior
- If you rarely need multiple OS windows
- If you want simplest setup

---

## Recommended Workflow (For You)

Based on your SRE/DevOps work and current setup:

### Primary Workflow: One Instance + Tabs + Dropdown

```
Main Kitty Instance
├── Tab 1: Current Project
│   ├── Window 1: Editor output
│   └── Window 2: Logs
├── Tab 2: Monitoring
│   └── Window 1: k9s/htop
├── Tab 3: SSH Sessions
│   └── Multiple windows with different servers
└── Tab 4: Scratch

PLUS: F12 Dropdown Terminal (separate, ephemeral)
```

**Navigation:**
- `Alt+Left/Right` - Switch between tabs
- `Ctrl+Alt+Arrow` - Navigate between windows (splits)
- `F12` - Quick dropdown for temporary commands

### When You Need Separate Instances

**Use Case 1:** Different projects that benefit from physical separation
- Keep main kitty for Project A
- Launch second kitty for Project B
- Use different workspaces/monitors

**Use Case 2:** Presentation mode
- Main kitty for actual work
- Second kitty with clean, large fonts for presenting

**Accept:** These instances **cannot be merged**. Plan accordingly.

---

## Future: Zellij Integration

**When implemented** (optional Phase 2):

```
Kitty (One Instance)
├── Tab 1: Zellij Session "work"
│   └── Persistent workspace, survives kitty restart
├── Tab 2: Zellij Session "monitoring"
│   └── Logs, metrics, always running
└── Tab 3: Regular shell
    └── Ephemeral terminal
```

**Benefits:**
- Best of both worlds
- Session persistence where needed
- Simple terminals where not needed
- Can "merge" by attaching to same zellij session from different kitty instances

---

## Summary

| Approach | Can Merge? | Terminal State | Complexity | Recommended For |
|----------|------------|----------------|------------|-----------------|
| **One Instance + Tabs** | N/A (no need) | ✅ Preserved | Low | **✅ Daily work (YOU)** |
| **Remote Control** | ⚠️ Partial | ❌ Lost | Medium | Scripting, automation |
| **tmux/zellij** | ✅ Yes (via attach) | ✅ Preserved | Medium | Session persistence |
| **Single Instance Mode** | ✅ Automatic | ✅ Preserved | Low | Browser-like workflow |
| **Multiple Instances** | ❌ No | ✅ Preserved | Low | Separate projects |

---

## Practical Examples

### Example 1: Accidentally Opened Two Instances

**Problem:** You have two kitty OS windows, want to consolidate.

**Solution:**
1. In second instance: Note what you're working on
2. In first instance: Open new tabs (`Ctrl+Shift+T`)
3. Recreate your work in the new tabs
4. Close second instance

**Time:** 2-3 minutes
**State Lost:** Command history in second instance

---

### Example 2: Want Persistent Sessions

**Problem:** Kitty closes, lose all terminal state.

**Solution:** Use zellij (coming in Phase 2)
```bash
# Start persistent session
zellij attach -c daily-work

# Do your work...

# Detach (Ctrl+Q in zellij)
# Session keeps running in background

# Later, reattach
zellij attach daily-work
# Everything exactly as you left it!
```

---

### Example 3: Working on Multiple Projects

**Problem:** 3 projects, want separation.

**Recommended:**
```
Option A: One kitty, 3 tabs (one per project)
├── Tab 1: Project A (Alt+1 or Ctrl+Alt+1)
├── Tab 2: Project B (Alt+2 or Ctrl+Alt+2)
└── Tab 3: Project C (Alt+3 or Ctrl+Alt+3)

Option B: Three kitty instances (if needed)
- Accept they cannot merge
- Use different workspaces or monitors
```

---

## Related Documentation

- **Customization Guide:** `docs/tools/kitty-customization-guide.md`
- **Zellij Integration Plan:** `docs/plans/kitty-zellij-phase1-plan.md`
- **Kitty Remote Control:** https://sw.kovidgoyal.net/kitty/remote-control/

---

**Maintained By:** Dimitris Tsioumas (Mitsio)
**Date:** 2025-12-01
