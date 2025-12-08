# Warp MCP Server Configuration Templates

**Created:** 2025-12-07
**Purpose:** Non-secret templates for configuring MCP servers in Warp
**Secrets Location:** See `docs/project-plans/PLAN_WARP_MCP_KITTY_INTEGRATION.md` for actual API keys

---

## Overview

These templates show the JSON structure for adding MCP servers to Warp.
Replace `${PLACEHOLDER}` variables with actual values from the plan document.

**How to add in Warp:**
1. Open Warp
2. Settings > MCP Servers > + Add
3. Paste the JSON (with real values)
4. Click Start

---

## Priority 1: Core AI Enhancement

### Context7 (Library Documentation)

```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp", "--api-key", "${CONTEXT7_API_KEY}"]
  }
}
```

**Variables:**
- `${CONTEXT7_API_KEY}` - Get from plan document

**Verify:** Ask Warp AI "What's in the React documentation?"

---

### Exa Web Search

```json
{
  "exa": {
    "url": "https://mcp.exa.ai/mcp"
  }
}
```

**Note:** No API key needed - uses HTTP endpoint with OAuth

**Verify:** Ask Warp AI to search for something

---

### Firecrawl (Web Scraping)

```json
{
  "firecrawl": {
    "command": "npx",
    "args": ["-y", "firecrawl-mcp"],
    "env": {
      "FIRECRAWL_API_KEY": "${FIRECRAWL_API_KEY}"
    }
  }
}
```

**Variables:**
- `${FIRECRAWL_API_KEY}` - Get from plan document

**Verify:** Ask Warp AI to scrape a webpage

---

### Sequential Thinking (Deep Reasoning)

```json
{
  "sequential-thinking": {
    "command": "uvx",
    "args": ["--from", "git+https://github.com/arben-adm/mcp-sequential-thinking", "--with", "portalocker", "mcp-sequential-thinking"]
  }
}
```

**Note:** No API key needed

**Verify:** Ask Warp AI to "think deeply about" something

---

## Priority 2: Utility Servers

### Time Server

```json
{
  "time": {
    "command": "uvx",
    "args": ["mcp-server-time", "--local-timezone=Europe/Athens"]
  }
}
```

**Note:** No API key needed. Adjust timezone as needed.

**Verify:** Ask Warp AI "What time is it?"

---

### Fetch Server

```json
{
  "fetch": {
    "command": "uvx",
    "args": ["mcp-server-fetch"]
  }
}
```

**Note:** No API key needed

---

### Read Website Fast

```json
{
  "read-website-fast": {
    "command": "npx",
    "args": ["-y", "@just-every/mcp-read-website-fast"]
  }
}
```

**Note:** No API key needed

---

## Priority 3: Optional Multi-Model

### Grok (X.AI)

```json
{
  "grok": {
    "command": "npx",
    "args": ["@pyroprompts/any-chat-completions-mcp"],
    "env": {
      "AI_CHAT_KEY": "${GROK_API_KEY}",
      "AI_CHAT_NAME": "Grok",
      "AI_CHAT_MODEL": "grok-3-mini",
      "AI_CHAT_BASE_URL": "https://api.x.ai/v1"
    }
  }
}
```

**Variables:**
- `${GROK_API_KEY}` - Get from plan document (starts with `xai-`)

---

### ChatGPT (OpenAI)

```json
{
  "chatgpt": {
    "command": "npx",
    "args": ["@pyroprompts/any-chat-completions-mcp"],
    "env": {
      "AI_CHAT_KEY": "${OPENAI_API_KEY}",
      "AI_CHAT_NAME": "ChatGPT",
      "AI_CHAT_MODEL": "gpt-4o",
      "AI_CHAT_BASE_URL": "https://api.openai.com/v1"
    }
  }
}
```

**Variables:**
- `${OPENAI_API_KEY}` - Get from plan document (starts with `sk-`)

---

## Quick Reference: Required Variables

| Server | Variable | Format |
|--------|----------|--------|
| context7 | `${CONTEXT7_API_KEY}` | `ctx7sk-...` |
| firecrawl | `${FIRECRAWL_API_KEY}` | `fc-...` |
| grok | `${GROK_API_KEY}` | `xai-...` |
| chatgpt | `${OPENAI_API_KEY}` | `sk-...` |

**All actual values are in:** `docs/project-plans/PLAN_WARP_MCP_KITTY_INTEGRATION.md`

---

## Notes

1. **Security:** Never commit actual API keys to version control
2. **Dependencies:** Requires `npx` (Node.js) and `uvx` (Python/uv) in PATH
3. **Warp Storage:** MCP configs are stored internally by Warp, not in a simple JSON file
4. **Testing:** After adding each server, verify it works before adding the next

---

## Related Files

- **Secrets & Full Plan:** `docs/project-plans/PLAN_WARP_MCP_KITTY_INTEGRATION.md`
- **Research:** `docs/researches/WARP_KITTY_MCP_INTEGRATION_RESEARCH.md`
- **Claude Code MCP Reference:** `~/.claude.json`
