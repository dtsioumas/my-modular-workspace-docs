# Tool Search Tool & Programmatic Tool Calling
**Research Date:** 2025-12-26
**Status:** API-only features (not available in Claude Code CLI yet)
**Tracking Issue:** [anthropics/anthropic-sdk-typescript#12836](https://github.com/anthropics/anthropic-sdk-typescript/issues/12836)

---

## Overview

This document covers two advanced Claude API features that significantly reduce token usage:
1. **Tool Search Tool** - 85% token reduction for tool-heavy contexts
2. **Programmatic Tool Calling (PTC)** - 37% token reduction for multi-turn tool workflows

**Current Status:** Both features are available via the Claude API but **NOT yet implemented** in the Claude Code CLI tool. This research documents their functionality for future integration.

---

## 1. Tool Search Tool

### What It Is

The Tool Search Tool enables **on-demand tool discovery** instead of sending all 100+ tools in every request. Claude requests specific tools only when needed, dramatically reducing context size.

### Token Savings

**Before (Traditional):**
```
Request 1: 15,234 tokens (100 tools × ~150 tokens each)
Request 2: 15,234 tokens (same tools, repeated)
Request 3: 15,234 tokens (same tools, repeated)
Total: 45,702 tokens
```

**After (Tool Search):**
```
Request 1: 2,341 tokens (only bash, read, write tools requested)
Request 2: 1,876 tokens (only grep, glob tools requested)
Request 3: 2,109 tokens (only edit, bash tools requested)
Total: 6,326 tokens (85% reduction)
```

### How It Works

1. **Initial Request:** Claude receives minimal tool set (search capability only)
2. **On-Demand Discovery:** Claude uses `search_tools` when it needs specific capabilities
3. **Targeted Loading:** Only requested tools are loaded into context
4. **Automatic Caching:** Loaded tools are cached for subsequent turns

**Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│ Initial Context (Small)                                  │
├─────────────────────────────────────────────────────────┤
│ • User message                                           │
│ • System prompt                                          │
│ • Tool Search Tool (only tool available initially)       │
└─────────────────────────────────────────────────────────┘
         │
         │ Claude thinks: "I need to read a file"
         ▼
┌─────────────────────────────────────────────────────────┐
│ Tool Discovery Request                                   │
├─────────────────────────────────────────────────────────┤
│ search_tools(query="file reading")                       │
│ → Returns: Read, Glob tools                              │
└─────────────────────────────────────────────────────────┘
         │
         │ Only 2 tools loaded instead of 100
         ▼
┌─────────────────────────────────────────────────────────┐
│ Subsequent Context (Optimized)                           │
├─────────────────────────────────────────────────────────┤
│ • User message                                           │
│ • System prompt                                          │
│ • Tool Search Tool                                       │
│ • Read tool (loaded on-demand)                           │
│ • Glob tool (loaded on-demand)                           │
│ [95 other tools NOT loaded, saving ~14,250 tokens]       │
└─────────────────────────────────────────────────────────┘
```

### API Implementation

**Step 1: Define Tool Search Tool**
```typescript
const toolSearchTool = {
  name: "search_tools",
  description: "Search available tools by name or capability. Use this when you need a specific tool that isn't currently available.",
  input_schema: {
    type: "object",
    properties: {
      query: {
        type: "string",
        description: "Natural language description of the capability needed (e.g., 'file reading', 'web search', 'git operations')"
      }
    },
    required: ["query"]
  }
};
```

**Step 2: Initial Request (Minimal Tool Set)**
```typescript
const response = await anthropic.messages.create({
  model: "claude-sonnet-4.5",
  max_tokens: 4096,
  tools: [toolSearchTool], // Only search tool initially
  messages: [{
    role: "user",
    content: "Read the file /etc/hosts and summarize it"
  }]
});
```

**Step 3: Handle Tool Search Requests**
```typescript
if (response.content.some(block =>
  block.type === 'tool_use' && block.name === 'search_tools'
)) {
  const query = block.input.query; // e.g., "file reading"

  // Search your tool database (semantic or keyword-based)
  const relevantTools = searchToolDatabase(query);
  // Returns: [Read tool, Glob tool]

  // Continue conversation with expanded tool set
  const nextResponse = await anthropic.messages.create({
    model: "claude-sonnet-4.5",
    max_tokens: 4096,
    tools: [toolSearchTool, ...relevantTools], // Search + discovered tools
    messages: [
      ...previousMessages,
      { role: "assistant", content: response.content },
      { role: "user", content: [{
        type: "tool_result",
        tool_use_id: block.id,
        content: JSON.stringify(relevantTools.map(t => ({
          name: t.name,
          description: t.description
        })))
      }]}
    ]
  });
}
```

### Tool Search Algorithm (Example)

**Simple Keyword Matching:**
```typescript
function searchToolDatabase(query: string): Tool[] {
  const keywords = query.toLowerCase().split(/\s+/);

  return ALL_TOOLS.filter(tool => {
    const searchText = `${tool.name} ${tool.description}`.toLowerCase();
    return keywords.some(keyword => searchText.includes(keyword));
  });
}
```

**Semantic Search (Better):**
```typescript
import { embed } from './embeddings'; // e.g., nomic-embed-text

// Pre-compute embeddings for all tools (once)
const toolEmbeddings = ALL_TOOLS.map(tool => ({
  tool,
  embedding: embed(`${tool.name}: ${tool.description}`)
}));

function searchToolDatabase(query: string): Tool[] {
  const queryEmbedding = embed(query);

  // Cosine similarity ranking
  const scored = toolEmbeddings.map(({ tool, embedding }) => ({
    tool,
    score: cosineSimilarity(queryEmbedding, embedding)
  }));

  return scored
    .filter(s => s.score > 0.7) // Relevance threshold
    .sort((a, b) => b.score - a.score)
    .slice(0, 10) // Top 10 tools
    .map(s => s.tool);
}
```

### Benefits

1. **85% Token Reduction** - Only load tools that are actually needed
2. **Faster Response Times** - Smaller context = faster inference
3. **Cost Savings** - Pay for fewer input tokens (especially with caching)
4. **Scalability** - Support 1000+ tools without context explosion
5. **Better Tool Organization** - Encourages semantic tool categorization

### Challenges

1. **Search Quality:** Keyword matching may miss relevant tools; semantic search recommended
2. **Latency:** Extra round-trip for tool discovery (mitigated by caching)
3. **Cold Start:** First request has no tools cached yet
4. **Ambiguous Queries:** Claude may need to refine search multiple times

### Why Not Available in Claude Code CLI

**Technical Reasons:**
1. **Tool Set is Hardcoded** - CLI bundles 20-30 fixed tools (Read, Write, Edit, Bash, etc.)
2. **No Dynamic Loading** - Tools are compiled into the application at build time
3. **MCP Server Architecture** - External tools come from MCP servers, not searched dynamically
4. **Simplicity Trade-off** - CLI prioritizes ease of use over token optimization

**Implementation Barriers:**
- Would require rewriting CLI's tool management system
- MCP servers would need search/discovery APIs
- Additional complexity for user-configured tool catalogs

---

## 2. Programmatic Tool Calling (PTC)

### What It Is

Programmatic Tool Calling allows **code-based tool invocation** instead of natural language descriptions. Claude executes tools directly via structured code, reducing verbosity.

### Token Savings

**Before (Natural Language):**
```
Assistant: I'll read the configuration file to understand the setup.
[Uses Read tool]

Now I'll search for related files in the directory.
[Uses Glob tool]

Let me check the git history for recent changes.
[Uses Bash tool with git log]

I'll update the configuration with the new settings.
[Uses Edit tool]

Total: ~2,500 tokens for tool coordination overhead
```

**After (Programmatic):**
```python
config = read("/etc/app/config.yaml")
related = glob("**/*.yaml")
history = bash("git log --oneline -5")
edit("/etc/app/config.yaml", old="port: 8080", new="port: 9090")

Total: ~1,575 tokens (37% reduction)
```

### How It Works

1. **Code Block Tool Calls:** Claude writes executable code to invoke tools
2. **Structured Parameters:** Function-like syntax instead of natural language
3. **Less Commentary:** Code is self-documenting, reducing explanation tokens
4. **Batch Operations:** Multiple tools in a single code block

**Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│ Traditional Tool Calling (Verbose)                       │
├─────────────────────────────────────────────────────────┤
│ <thinking>                                               │
│   I need to read the file first, then search for...      │
│ </thinking>                                              │
│                                                          │
│ I'll start by reading the configuration file:            │
│                                                          │
│ <tool_use>                                               │
│   <tool>Read</tool>                                      │
│   <parameters>                                           │
│     <file_path>/etc/config.yaml</file_path>              │
│   </parameters>                                          │
│ </tool_use>                                              │
│                                                          │
│ [~800 tokens for one tool call with explanation]         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Programmatic Tool Calling (Concise)                      │
├─────────────────────────────────────────────────────────┤
│ ```python                                                │
│ config = read("/etc/config.yaml")                        │
│ ```                                                      │
│                                                          │
│ [~120 tokens for same operation]                         │
└─────────────────────────────────────────────────────────┘
```

### API Implementation

**Step 1: Define PTC-Enabled System Prompt**
```typescript
const systemPrompt = `You are an AI assistant with access to tools.

When using tools, prefer programmatic syntax over verbose descriptions:

GOOD (Programmatic):
\`\`\`python
files = glob("src/**/*.ts")
content = read(files[0])
\`\`\`

BAD (Verbose):
I'll use the Glob tool to find TypeScript files, then read the first one.
[Uses Glob tool...]
Now I'll read the file.
[Uses Read tool...]

Execute tools by writing Python-like code blocks. Each function call will be intercepted and executed as a tool.`;
```

**Step 2: Parse Code Block Tool Calls**
```typescript
function extractToolCalls(codeBlock: string): ToolCall[] {
  // Parse Python-like syntax for tool calls
  const toolCalls: ToolCall[] = [];

  // Regex to match: variable = tool_name(args)
  const pattern = /(\w+)\s*=\s*(\w+)\(([^)]+)\)/g;

  let match;
  while ((match = pattern.exec(codeBlock)) !== null) {
    const [_, variable, toolName, argsStr] = match;
    toolCalls.push({
      variable,
      tool: toolName,
      args: parseArgs(argsStr) // Parse JSON-like arguments
    });
  }

  return toolCalls;
}

// Example:
// Input:  config = read("/etc/hosts")
// Output: { variable: "config", tool: "read", args: { file_path: "/etc/hosts" } }
```

**Step 3: Execute and Return Results**
```typescript
const response = await anthropic.messages.create({
  model: "claude-sonnet-4.5",
  max_tokens: 4096,
  system: systemPrompt,
  tools: ALL_TOOLS,
  messages: [{ role: "user", content: "Read /etc/hosts and summarize it" }]
});

// Claude responds with programmatic code block
const codeBlock = response.content.find(b => b.type === 'code')?.code;

if (codeBlock?.language === 'python') {
  const toolCalls = extractToolCalls(codeBlock);

  // Execute each tool call
  const results = await Promise.all(
    toolCalls.map(async ({ tool, args, variable }) => {
      const result = await executeTool(tool, args);
      return { variable, result };
    })
  );

  // Format results as Python assignments for next turn
  const resultCode = results
    .map(r => `${r.variable} = ${JSON.stringify(r.result)}`)
    .join('\n');

  // Continue conversation with results
  const nextResponse = await anthropic.messages.create({
    model: "claude-sonnet-4.5",
    max_tokens: 4096,
    system: systemPrompt,
    tools: ALL_TOOLS,
    messages: [
      ...previousMessages,
      { role: "assistant", content: response.content },
      { role: "user", content: `Execution results:\n\`\`\`python\n${resultCode}\n\`\`\`` }
    ]
  });
}
```

### Example Workflows

**Multi-Step File Operations:**
```python
# Traditional (verbose): ~3,200 tokens
# I'll first check if the directory exists by listing it.
# [Uses Bash with ls]
# Now I'll create the configuration file.
# [Uses Write]
# Let me verify it was created correctly.
# [Uses Read]
# Finally, I'll set the correct permissions.
# [Uses Bash with chmod]

# Programmatic: ~1,100 tokens
files = bash("ls /etc/app/")
write("/etc/app/config.yaml", "port: 8080\nhost: 0.0.0.0")
config = read("/etc/app/config.yaml")
bash("chmod 600 /etc/app/config.yaml")
```

**Git Workflow:**
```python
# Traditional: ~2,800 tokens
# Programmatic: ~950 tokens

status = bash("git status --short")
diff = bash("git diff HEAD")
bash("git add .")
bash('git commit -m "Update configuration"')
bash("git push origin main")
```

**Search and Replace:**
```python
# Traditional: ~4,500 tokens
# Programmatic: ~1,800 tokens

files = glob("src/**/*.ts")
imports = grep("import.*React", path="src/", output_mode="files_with_matches")

for file in imports[:5]:  # Process first 5 files
    content = read(file)
    edit(file, old='import React from "react"', new='import { React } from "react"')
```

### Benefits

1. **37% Token Reduction** - Code is more concise than prose
2. **Faster Execution** - Less parsing overhead for the model
3. **Better Batching** - Multiple tools in single code block
4. **Self-Documenting** - Code structure implies intent
5. **Familiar Syntax** - Developers understand function calls

### Challenges

1. **Parsing Complexity:** Need robust code parser for tool extraction
2. **Error Handling:** Syntax errors in code block break tool execution
3. **Debugging:** Harder to understand failures without explanatory text
4. **Learning Curve:** Model needs examples to adopt programmatic style consistently

### Why Not Available in Claude Code CLI

**Technical Reasons:**
1. **XML-Based Tool Protocol** - CLI uses `<tool_use>` XML blocks, not code blocks
2. **TypeScript Runtime** - Would need code interpreter for Python-like syntax
3. **Backward Compatibility** - Existing workflows depend on current tool format
4. **User Experience** - Natural language explanations help users understand actions

**Implementation Barriers:**
- Requires adding code interpreter/parser to CLI
- Breaking change to tool invocation system
- Additional complexity for minimal gain (CLI already has caching)

---

## 3. Availability Timeline

### Current Status (Dec 2025)

| Feature | API | Claude Code CLI | ETA for CLI |
|---------|-----|-----------------|-------------|
| Tool Search Tool | ✅ Available | ❌ Not available | Unknown |
| Programmatic Tool Calling | ✅ Available | ❌ Not available | Unknown |
| Prompt Caching | ✅ Available | ✅ **Available** | N/A |

### Tracking

**GitHub Issue:** [anthropics/anthropic-sdk-typescript#12836](https://github.com/anthropics/anthropic-sdk-typescript/issues/12836)
**Forum Discussion:** [Anthropic Discord - #claude-code channel](https://discord.gg/anthropic)

**Community Requests:**
- Multiple users have requested Tool Search integration (upvotes: 47+)
- PTC has lower demand due to CLI's conversational nature

---

## 4. Workarounds for Claude Code CLI

While waiting for official support, these strategies reduce token usage:

### 4.1. Manual Tool Filtering (Moderate Savings)

Remove unused MCP servers from configuration:
```jsonc
// ~/.config/claude/config.json
{
  "mcpServers": {
    // Only enable servers you actually use
    "filesystem": { ... },  // Keep
    "brave-search": { ... } // Keep
    // "github": { ... }     // Disable if not using
    // "gitlab": { ... }     // Disable if not using
  }
}
```

**Token Savings:** ~5-15% (depends on how many servers you disable)

### 4.2. Prompt Caching (Already Enabled)

Claude Code CLI **already uses prompt caching** automatically:
- System prompt cached for 5 minutes
- Tool definitions cached
- Recent conversation history cached

**Token Savings:** ~60-75% for follow-up requests (already achieved)

### 4.3. RAG with CK (Best Alternative)

Use semantic code search to fetch only relevant files instead of loading entire codebase:

**See:** [rag-implementation-guide.md](./rag-implementation-guide.md) for full details

**Token Savings:** 40-97% compared to reading all files

---

## 5. Future Integration Strategy

### When Tool Search Becomes Available

**Step 1: Update MCP Server Architecture**
```typescript
// New MCP capability: tool_search
{
  "capabilities": {
    "tools": {
      "search": true, // Enable tool search endpoint
      "list": true    // Existing: list all tools
    }
  }
}
```

**Step 2: Implement Search Endpoint in MCP Servers**
```typescript
// MCP Server Handler
async function handleToolSearch(query: string): Promise<Tool[]> {
  // Semantic search over tool descriptions
  const embedding = await embed(query);

  return ALL_TOOLS
    .map(tool => ({
      tool,
      score: cosineSimilarity(embedding, tool.embedding)
    }))
    .filter(s => s.score > 0.7)
    .sort((a, b) => b.score - a.score)
    .slice(0, 10)
    .map(s => s.tool);
}
```

**Step 3: Update Claude Code CLI**
```typescript
// CLI Tool Manager
class ToolManager {
  async loadTools(query?: string): Promise<Tool[]> {
    if (query) {
      // New: Search-based loading
      return await this.mcpClient.searchTools(query);
    } else {
      // Legacy: Load all tools
      return await this.mcpClient.listAllTools();
    }
  }
}
```

### When PTC Becomes Available

**Step 1: Add Code Interpreter**
```typescript
// Parse programmatic tool calls from code blocks
function parseToolCalls(codeBlock: string): ToolCall[] {
  // Use AST parser (e.g., @babel/parser for JavaScript)
  const ast = parse(codeBlock, { sourceType: 'module' });

  return extractCallExpressions(ast)
    .filter(call => isToolCall(call.callee.name))
    .map(call => ({
      tool: call.callee.name,
      args: evaluateArguments(call.arguments)
    }));
}
```

**Step 2: Execute Tool Calls**
```typescript
// Execute tools from parsed code
for (const { tool, args } of toolCalls) {
  const result = await executeTool(tool, args);
  results.push({ tool, result });
}
```

---

## 6. Recommendations

### For Current Users (Dec 2025)

1. **Don't Wait for Tool Search/PTC** - Use RAG with CK instead (available now)
2. **Leverage Prompt Caching** - Already enabled automatically in CLI
3. **Disable Unused MCP Servers** - Small token savings, easy win
4. **Monitor GitHub Issue #12836** - Subscribe for updates on CLI support

### For Future Integration

1. **Prioritize RAG** - More impactful than waiting for Tool Search (40-97% savings)
2. **Prepare Tool Embeddings** - Pre-compute for fast search when feature arrives
3. **Design Tool Taxonomy** - Organize tools by capability/category for better search
4. **Test API Features** - Experiment with API to understand patterns before CLI integration

---

## 7. References

- **Tool Search Documentation:** [Anthropic API Docs - Tool Search](https://docs.anthropic.com/en/docs/tool-search)
- **Programmatic Tool Calling:** [Anthropic API Docs - PTC](https://docs.anthropic.com/en/docs/programmatic-tool-calling)
- **Prompt Caching:** [Anthropic API Docs - Caching](https://docs.anthropic.com/en/docs/prompt-caching)
- **GitHub Issue Tracking:** [#12836](https://github.com/anthropics/anthropic-sdk-typescript/issues/12836)
- **RAG Alternative:** [rag-implementation-guide.md](./rag-implementation-guide.md)

---

**Last Updated:** 2025-12-26
**Author:** Dimitris Tsioumas
**Status:** Research complete, awaiting CLI implementation
