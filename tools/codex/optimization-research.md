# Codex AI Agent Configuration Research
## Session: Enhancing Agents Configuration - Week 52, 2025

**Research Date:** December 22, 2025
**Research Scope:** Comprehensive analysis of Codex configuration, optimization, and feature utilization
**Target Configuration:** `dotfiles/private_dot_codex/config.toml.tmpl`

---

## Table of Contents

1. [Session History Compaction Configuration](#1-session-history-compaction-configuration)
2. [GPU Utilization and Performance](#2-gpu-utilization-and-performance)
3. [RAM Optimization and Memory Management](#3-ram-optimization-and-memory-management)
4. [Feature Analysis: Unused and Underutilized](#4-feature-analysis-unused-and-underutilized)
5. [Latest Upstream Features (GPT-5.2-Codex)](#5-latest-upstream-features-gpt-52-codex)
6. [Custom Commands and Skills Extension](#6-custom-commands-and-skills-extension)
7. [MCP Server Configuration and Optimization](#7-mcp-server-configuration-and-optimization)
8. [Configuration Best Practices and Recommendations](#8-configuration-best-practices-and-recommendations)

---

## 1. Session History Compaction Configuration

### Overview

Session compaction is a critical feature in Codex that prevents context window overflow during long-running tasks by automatically summarizing and condensing interaction history while preserving essential context.

### Compaction Mechanics

**Automatic Triggering:**
- Compaction is triggered when the model approaches its context window limit (approximately 80% of the available context)
- The system monitors token count of conversational history and intercepts the next user request when the threshold is exceeded
- For GPT-5.1-Codex-Max and GPT-5.2-Codex: automatic context compaction gives a fresh context window

**Compaction Process:**
- Identifies salient elements: decisions taken, architectural choices, test failures, current goals
- Distills identified elements into a dense summary block
- Replaces multiple turns with a concise, comprehensive summary
- Preserves critical context while pruning less important details
- Maintains original transcript, plan history, and approvals for session continuation

### Configuration Parameters

#### `history.max_bytes`
- **Purpose:** Limits the maximum size of `history.jsonl` file
- **Default:** Not explicitly specified in standard docs, but commonly 32-128 MB
- **Behavior:** When exceeded, history is automatically compacted/trimmed to approximately 80% of this limit by dropping oldest entries
- **Configuration:**
  ```toml
  [history]
  max_bytes = 134217728  # 128 MB example
  ```
- **Optimization Tip:** Adjust based on available disk space and session frequency; smaller values compact more aggressively

#### `history.persistence`
- **Purpose:** Controls how sessions are persisted to disk
- **Default:** `save-all`
- **Options:**
  - `save-all`: Saves full conversation transcripts to `history.jsonl`
  - Other modes may exist for selective saving (consult latest docs)
- **Configuration:**
  ```toml
  [history]
  persistence = "save-all"
  ```

#### `model_auto_compact_token_limit`
- **Purpose:** Configures the threshold at which automatic compaction is triggered
- **Behavior:** Baseline of 12,000 tokens is subtracted from both context window and current usage; percentage displayed in TUI
- **Recommendation:** Keep at default for GPT-5.1-Codex-Max and GPT-5.2-Codex to leverage native training for compaction

### Compaction Benefits

- **Token Efficiency:** Reduces overall tokens by 20-40% in long sessions, lowering costs
- **Performance:** Codex-Max runs 27-42% faster when compaction is optimized
- **Extended Sessions:** Enables sessions to persist for hundreds of thousands of tokens per window without performance degradation
- **Long-Running Autonomy:** Internal OpenAI tests show Codex working autonomously for 24+ hours on single tasks with iterative improvements

### Implementation Example

```toml
[history]
max_bytes = 67108864  # 64 MB - moderate sizing
persistence = "save-all"

# In main config section
model_auto_compact_token_limit = 400000  # For GPT-5.2-Codex's larger context
```

---

## 2. GPU Utilization and Performance

### GPU Utilization in Codex

**Direct Model Inference:**
- Codex relies on OpenAI's hosted models (GPT-5.1-Codex-Max, GPT-5.2-Codex)
- No local GPU utilization by default - all inference runs on OpenAI's infrastructure
- GPU consumption occurs on OpenAI's backend, not on your local machine

**Performance Optimization (Not GPU-specific):**
- Increased rate limits for ChatGPT Plus, Business, and Education plan users
- Supports more parallel task processing
- Reduces development workflow interruptions
- Rate limits: ~30-150 local messages per 5 hours, ~5-40 cloud tasks per 5 hours

### Performance Configuration Options

#### `model_reasoning_effort`
- **Purpose:** Controls reasoning depth for capable models
- **Options:** `minimal`, `low`, `medium` (default), `high`, `xhigh`
- **Trade-offs:**
  - Higher reasoning = better accuracy but slower and more expensive
  - Recommendation for optimization: Use `medium` for routine tasks, `high` for complex debugging
- **Example:**
  ```toml
  model_reasoning_effort = "medium"

  [profiles.deep-thinking]
  model_reasoning_effort = "high"  # For complex refactors
  ```

#### `model_verbosity`
- **Purpose:** Controls output detail level for GPT-5 models
- **Options:** `low`, `medium` (default), `high`
- **Performance Impact:** May affect token usage; `low` is most efficient
- **Configuration:**
  ```toml
  model_verbosity = "medium"
  ```

### Parallelization and Concurrency

**Rate Limit Management:**
- ChatGPT Plus users get higher rate limits than free tier
- Business/Education plans have premium rate limits
- Codex automatically manages concurrent tasks within these limits

**Streaming Configuration:**
- `stream_max_retries`: Controls SSE reconnection attempts (default: 5)
- `stream_idle_timeout_ms`: Idle threshold before timeout (default: 300,000 ms = 5 minutes)

---

## 3. RAM Optimization and Memory Management

### Memory Architecture

Codex's memory system operates in layers:
1. **Local History File** (`history.jsonl`) - persistent disk storage
2. **Session Context** - active conversation state in RAM
3. **Project Documentation** - AGENTS.md and related files
4. **Tool/MCP Cache** - MCP server responses cached in memory

### Key Configuration Parameters

#### `project_doc_max_bytes`
- **Purpose:** Limits total bytes read from AGENTS.md files in the project
- **Default:** 32 KiB (32,768 bytes)
- **Behavior:**
  - Empty files are skipped
  - Files are truncated when combined size reaches the limit
  - Silently truncates without warning (UX limitation known by OpenAI)
- **Optimization Strategies:**
  - **Strategy 1 - Increase Limit:**
    ```toml
    project_doc_max_bytes = 65536  # 64 KiB
    ```
  - **Strategy 2 - Split Guidance:**
    - Use nested directories for AGENTS.md files
    - Codex reads AGENTS.md per directory level
  - **Strategy 3 - Fallback Filenames:**
    ```toml
    project_doc_fallback_filenames = ["INSTRUCTIONS.md", "CONTEXT.md", "AGENTS.md"]
    ```

#### `project_doc_fallback_filenames`
- **Purpose:** Alternative filenames to check when AGENTS.md is absent
- **Behavior:** Checked in order provided; primary AGENTS.md checked first
- **Use Case:** Allows legacy or domain-specific instruction filenames
- **Example:**
  ```toml
  project_doc_fallback_filenames = ["INSTRUCTIONS.md", ".agent-instructions"]
  ```

### History File Optimization

#### File Trimming
- `history.jsonl` is trimmed by `history.max_bytes` during compaction
- Common "junk" directories (e.g., `__pycache__`, `node_modules`) are ignored by default
- Strategy: Set `max_bytes` to balance retention vs. memory usage

#### Session Resumption
- Sessions persist via RolloutRecorder (JSONL persistence layer)
- Enables session resume and fork operations: `codex resume <SESSION_ID>`
- Maintains original transcript, plan history, and approvals

#### Token Tracking
```
Effective Token Budget = Context Window - Baseline (12,000 tokens)
Usage % = (Current Tokens - 12,000) / Effective Budget
Auto-Compact Trigger = 80% of context window
```

### Context Window Management

#### Available Windows by Model
- **GPT-5.1-Codex-Max:** 272,000 tokens (some documentation claims 400,000)
- **GPT-5.2-Codex:** Similar or extended window
- Recommend subtracting 12,000 tokens as baseline for safe operation

#### RAM Impact of MCP Servers
**Significant Memory Consideration:**
- Each MCP server loaded consumes memory during startup
- Server definitions alone: 10,000-15,000 tokens per 15-20 enterprise tools
- All configured servers load by default, even if unused

**Mitigation Strategies:**
1. Disable unused servers: `enabled = false` in server config
2. Use `enabled_tools` allowlist to restrict tools per server
3. Use `disabled_tools` denylist to remove specific tools
4. Set per-server startup timeouts to prevent stalling

### Recommended RAM Optimization Config

```toml
# Conservative memory configuration
[history]
max_bytes = 33554432  # 32 MB - modest history retention
persistence = "save-all"

project_doc_max_bytes = 32768  # 32 KiB default
project_doc_fallback_filenames = ["AGENTS.md", ".instructions"]

# Disable expensive features
hide_agent_reasoning = false  # Display reasoning (native support)
show_raw_agent_reasoning = false

# Model settings for efficiency
model_verbosity = "low"  # Reduce token output
model_reasoning_effort = "medium"  # Balanced reasoning
```

---

## 4. Feature Analysis: Unused and Underutilized

### Stable Features (Recommended for Use)

| Feature | Status | Purpose | Configuration |
|---------|--------|---------|----------------|
| `view_image_tool` | Stable | View/interpret images and diagrams | `[features]` `view_image_tool = true` |
| `web_search_request` | Stable | Allow Codex to search the web | `[features]` `web_search_request = true` |
| `apply_patch_freeform` | Beta | Freeform patch application | `[features]` `apply_patch_freeform = false` |

### Experimental Features (Optional, Monitor for Issues)

| Feature | Status | Purpose | Configuration | Notes |
|---------|--------|---------|----------------|-------|
| `unified_exec` | Experimental | PTY-backed execution tool | `[features]` `unified_exec = false` | More stable shell integration |
| `ghost_commit` | Experimental | Auto-create commits per turn | `[features]` `ghost_commit = false` | Use with caution in production |
| `skills` | Experimental | Skill discovery/injection system | `[features]` `skills = false` | Enable with `--enable skills` |
| `experimental_sandbox_command_assessment` | Experimental | Model-based risk assessment for commands | `[features]` `experimental_sandbox_command_assessment = false` | Useful for tightening approval rules |

### Underutilized Features Analysis

#### 1. Web Search Feature
**Current Status:** Disabled by default
**Why Underutilized:**
- Requires explicit opt-in despite being stable
- Not visible in default feature list
- Requires additional context window budget

**Recommendation:**
```toml
[features]
web_search_request = true  # Enable if frequent web research needed
```
**Use Case:** Enable for tasks requiring real-time information or library API research

#### 2. Skills System
**Current Status:** Experimental, disabled by default
**Why Underutilized:**
- Requires special flag to enable: `--enable skills`
- Stored in `~/.codex/skills/`
- Limited documentation and examples

**Recommendation:**
```toml
[features]
skills = false  # Keep disabled until mature, or:
# Enable selectively with: codex --enable skills
```
**Use Case:** Create reusable, shareable capabilities for specific domains

#### 3. Experimental Sandbox Risk Assessment
**Current Status:** Experimental
**Purpose:** Model-based risk evaluation for sandbox-violating commands
**Why Underutilized:**
- Gated by experimental flag
- Requires understanding of sandbox policies
- Creates additional model call per violation

**Recommendation:**
```toml
[features]
experimental_sandbox_command_assessment = false
# Enable selectively:
# codex --enable experimental_sandbox_command_assessment
```
**Use Case:** Tighten approval rules and reduce accidental dangerous command execution

#### 4. Ghost Commits
**Current Status:** Experimental
**Why Underutilized:**
- Disabled by default for good reason (can clutter history)
- Requires git integration awareness
- Useful only for specific workflows

**Recommendation:**
```toml
[features]
ghost_commit = false  # Keep disabled unless needed
```
**Use Case:** Track Codex's intermediate work steps in git history

### Feature Enablement Strategy

**Conservative Approach (Recommended for Production):**
```toml
[features]
view_image_tool = true           # Stable - enable
web_search_request = false       # Stable but expensive - disable by default
apply_patch_freeform = false     # Beta - keep disabled
unified_exec = false             # Experimental - disabled
ghost_commit = false             # Experimental - disabled
skills = false                   # Experimental - disabled
experimental_sandbox_command_assessment = false  # Experimental - disabled
```

**Progressive Enhancement Approach (for experimentation):**
```toml
[features]
view_image_tool = true                           # Stable
web_search_request = true                        # Enable for web-heavy work
apply_patch_freeform = false                     # Monitor for maturity
unified_exec = false                             # Test in profiles
ghost_commit = false                             # Test selectively
skills = false                                   # Test in sandbox
experimental_sandbox_command_assessment = false  # Test for approval rules
```

---

## 5. Latest Upstream Features (GPT-5.2-Codex)

### GPT-5.2-Codex Release (December 18, 2025)

**Status:** Most advanced agentic coding model released by OpenAI

### Core Improvements

#### Long-Horizon Work
- Context compaction optimized for extended sessions
- Better performance on large code changes (refactors, migrations)
- Significantly improved Windows environment support
- Successfully autonomously works for 24+ hour sessions

#### Reasoning Enhancements
- Stronger performance on complex reasoning tasks
- Better handling of multi-step problem decomposition
- Improved decision-making on architectural choices

#### Vision Capabilities
- Stronger interpretation of screenshots and technical diagrams
- Better translation of UI mockups to functional prototypes
- Enhanced diagram understanding for design documentation

### Cybersecurity Advancements

**Industry-Leading Performance:**
- CVE-Bench score: **87%** (outperforming all other models)
- Effective vulnerability detection
- Defensive security work capabilities
- Trusted access for vetted security professionals available

### Benchmark Performance

- **SWE-Bench Pro:** 56.4% accuracy (unmatched score)
- **Terminal-Bench 2.0:** 64% accuracy
- Improvements over GPT-5.1-Codex-Max on reasoning-heavy tasks

### Availability and Access

- Available in all Codex surfaces for paid ChatGPT users
- API access rolling out in coming weeks
- Invite-only trusted access for cybersecurity professionals and organizations
- Better Windows support makes cross-platform development more viable

### Recommended Configuration for GPT-5.2-Codex

```toml
# Use latest model
model = "gpt-5.2-codex"

# Leverage extended context window
model_context_window = 272000  # Conservative estimate

# Optimize for new reasoning capabilities
model_reasoning_effort = "medium"  # Balanced for most tasks

# Profile for deep security analysis
[profiles.security-audit]
model = "gpt-5.2-codex"
model_reasoning_effort = "high"
approval_policy = "never"  # Trust the model for security work

# Profile for large refactors
[profiles.refactor]
model = "gpt-5.2-codex"
model_reasoning_effort = "medium"
approval_policy = "on-request"
```

### Backward Compatibility

- GPT-5.2-Codex is backward compatible with existing prompts and configurations
- No configuration changes required for basic operation
- Can gradually adopt new features as they stabilize

---

## 6. Custom Commands and Skills Extension

### Slash Commands

**Purpose:** Keyboard-first control for common tasks without leaving terminal

#### `/summary` Command
- **Function:** Compacts long conversations into concise summaries
- **Implementation:** Uses GPT-5-Codex custom summarizer (no preambles)
- **Benefit:** Frees context while preserving critical details
- **Automatic Use:** Triggered automatically during compaction
- **Manual Use:** Available via slash command interface

**Configuration:**
```toml
# No explicit configuration needed; built-in to Codex
```

#### `/experimental` Command
- **Purpose:** Access experimental features and test new functionality
- **Usage:** `codex --enable <feature>` or `/experimental <command>`

### Session Continuation

**Resume Previous Sessions:**
```bash
codex resume --last "Continue implementing authentication"
codex resume <SESSION_ID> "Add unit tests for feature"
```

**Preserved State:**
- Original transcript
- Plan history and decisions
- Approval history
- Implementation context

### Custom Prompts System

**Location:** `~/.codex/prompts/` (top-level Markdown files only)

**Structure:**
```markdown
---
description: Brief description shown in command popup
---

# Your custom prompt content

Use placeholders for arguments: $1, $2, etc.
Position-based arguments expand from space-separated input.
```

**Example Custom Prompt:**

```markdown
---
description: Analyze code for security vulnerabilities
---

# Security Analysis

Review the provided code for potential security issues:
- Input validation flaws
- SQL injection risks
- Authentication weaknesses
- Data exposure risks

Provide severity assessment (Critical/High/Medium/Low) for each finding.
```

**Invocation:** `codex /security-analysis <file.js>`

### Skills System

**Location:** `~/.codex/skills/` (when enabled)

**Enable:**
```bash
codex --enable skills
```

**Configuration:**
```toml
[features]
skills = false  # Enable for specific tasks, keep disabled for stability
```

**Capability:**
- Create reusable, shareable capabilities
- Domain-specific tool sets
- Integration with Codex's tool system
- Available for sharing in Codex community

**Example Skill Structure:**
```toml
# ~/.codex/skills/kubernetes-ops/skill.toml
[skill]
name = "kubernetes-operations"
description = "K8s cluster management and troubleshooting"
version = "1.0.0"

[[tools]]
name = "kubectl-debug"
description = "Debug Kubernetes resources"
```

### Minimal Prompting Philosophy

**Important Finding:**
- Codex CLI developer message uses ~40% fewer tokens than GPT-5
- Reinforces that minimal prompting is ideal for this model
- Avoid over-detailed prompts; let the model infer context

**Best Practice:**
```toml
# Good - concise and context-aware
# Bad - verbose with redundant instructions
```

---

## 7. MCP Server Configuration and Optimization

### MCP Overview

**Model Context Protocol:** Open standard for connecting models to external tools and context

### Server Management

#### Basic Configuration
```toml
[mcp_servers.filesystem]
command = "node"
args = ["/path/to/mcp-server-filesystem.js"]
startup_timeout_ms = 10000
```

#### Server Control Mechanisms

**Enable/Disable Server:**
```toml
[mcp_servers.example]
enabled = false  # Skip starting this server
```

**Tool Allowlist (enabled_tools):**
```toml
[mcp_servers.github]
command = "node"
args = ["github-mcp"]
enabled_tools = ["list_issues", "create_pull_request"]  # Only these tools
```

**Tool Denylist (disabled_tools):**
```toml
[mcp_servers.filesystem]
command = "node"
args = ["filesystem-mcp"]
disabled_tools = ["delete_file", "chmod"]  # Exclude these tools
```

### Performance Optimization

#### Context Window Impact
- **Token Cost per Server:** 10,000-15,000 tokens for 15-20 enterprise tools
- **Global Load:** All configured servers load by default, consuming memory for unused servers
- **Measured Impact:**
  - MCP usage: ~20.5% faster task execution
  - Success rate improvement: +100% task completion
  - Cost increase: ~27.5% (cache reads +28.5%, cache writes +53.7%)

#### Timeout Configuration
```toml
[mcp_servers.<name>]
startup_timeout_ms = 10000     # Initial connection timeout (default: 10s)
per_tool_timeout_ms = 60000    # Per-tool execution timeout (default: 60s)
```

**Tuning Strategy:**
- Increase timeouts for slow networks or cold starts
- Decrease for responsive environments
- Monitor for timeout errors in logs

### Recommended MCP Server Configuration

#### Conservative Setup (Minimal Overhead)
```toml
# Filesystem - essential
[mcp_servers.filesystem]
command = "node"
args = ["mcp-server-filesystem"]
startup_timeout_ms = 10000
enabled_tools = ["read_file", "write_file", "list_directory"]

# Git integration - useful for version control
[mcp_servers.git]
command = "node"
args = ["mcp-server-git"]
startup_timeout_ms = 10000

# Disable expensive servers by default
[mcp_servers.web]
enabled = false

[mcp_servers.slack]
enabled = false

[mcp_servers.github]
enabled = false  # Enable in profiles when needed
```

#### Profile-Based Server Activation
```toml
# Base config - minimal servers
[mcp_servers.filesystem]
command = "node"
args = ["mcp-server-filesystem"]

# Activate additional servers for specific profiles
[profiles.github-work]
[[profiles.github-work.mcp_servers_override]]
name = "github"
enabled = true

[profiles.web-research]
[[profiles.web-research.mcp_servers_override]]
name = "web"
enabled = true

[profiles.devops]
# Multiple servers for ops work
[[profiles.devops.mcp_servers_override]]
name = "docker"
enabled = true
[[profiles.devops.mcp_servers_override]]
name = "kubernetes"
enabled = true
```

### Tool Redundancy Analysis

#### mcp-fetch vs mcp-server-fetch
- **Configuration Name:** `fetch` (identifier in Codex config)
- **Package Name:** `mcp-server-fetch` (actual executable)
- **Relationship:** NOT separate competing implementations
- **Purpose:** Web content fetching via MCP protocol
- **Not Redundant:** These are the same tool referenced differently (config vs. package)

#### Identifying Redundant Servers

**Potential Redundancies to Audit:**
1. Multiple "fetch" or web access servers
2. Multiple git integration servers
3. Multiple file system access servers
4. Multiple database connection servers

**Audit Strategy:**
```bash
# Check config for duplicate capabilities
grep -A 3 "\[mcp_servers" config.toml | grep -E "command|args"

# Compare tool lists
codex --list-tools  # Shows all available tools from all servers
```

### MCP Server Performance Checklist

- [ ] Disable all unused servers (`enabled = false`)
- [ ] Use `enabled_tools` to restrict expensive servers to needed tools only
- [ ] Set appropriate timeouts (10-30s startup, 30-60s per-tool)
- [ ] Monitor context window impact of loaded servers
- [ ] Profile-based activation for domain-specific servers
- [ ] Regular audit of server necessity vs. performance cost

---

## 8. Configuration Best Practices and Recommendations

### Overall Philosophy

**Balance Principle:**
- **Don't over-configure:** Stick to defaults unless experiencing issues
- **Don't under-optimize:** Monitor and adjust for your usage patterns
- **Measure before tuning:** Use metrics (tokens, runtime, costs) to guide changes

### Phased Optimization Approach

#### Phase 1: Establish Baseline
```toml
model = "gpt-5.2-codex"
approval_policy = "on-request"
sandbox_mode = "read-only"

[history]
max_bytes = 67108864
persistence = "save-all"

[features]
view_image_tool = true
web_search_request = false
```

**Actions:**
- Monitor token usage, session length, cost
- Note performance patterns
- Identify pain points

#### Phase 2: Feature Optimization
```toml
# Based on Phase 1 analysis, enable beneficial features
[features]
view_image_tool = true          # Enable if using diagrams/screenshots
web_search_request = false      # Enable if frequent research tasks
apply_patch_freeform = false    # Test if default patches fail
```

#### Phase 3: MCP Optimization
```toml
# Audit and optimize MCP server configuration
# Disable unused servers
# Profile-based activation for specialized servers
# Set appropriate timeouts
```

#### Phase 4: Advanced Tuning
```toml
# Based on mature understanding:
# - Adjust reasoning effort by profile
# - Fine-tune history retention
# - Optimize project doc limits
# - Configure custom skills
```

### Template: Optimized Production Configuration

```toml
# ~/.codex/config.toml - Optimized Configuration Template

# Core model selection
model = "gpt-5.2-codex"
model_provider = "openai"
approval_policy = "on-request"
sandbox_mode = "read-only"

# Reasoning and output
model_reasoning_effort = "medium"
model_verbosity = "medium"
context_window = 272000

# History management
[history]
max_bytes = 67108864  # 64 MB
persistence = "save-all"

# Documentation and instruction limits
project_doc_max_bytes = 32768  # 32 KiB
project_doc_fallback_filenames = ["AGENTS.md", ".instructions"]

# Feature configuration
[features]
view_image_tool = true
web_search_request = false
apply_patch_freeform = false
unified_exec = false
ghost_commit = false
skills = false
experimental_sandbox_command_assessment = false

# Shell environment
shell_env = "inherit:core"  # Inherit safe env vars

# MCP Servers - Minimal core set
[mcp_servers.filesystem]
command = "node"
args = ["mcp-server-filesystem"]
startup_timeout_ms = 10000

[mcp_servers.git]
command = "node"
args = ["mcp-server-git"]
startup_timeout_ms = 10000

# Disable expensive servers by default
[mcp_servers.web]
enabled = false

[mcp_servers.github]
enabled = false

[mcp_servers.slack]
enabled = false

# Display options
hide_agent_reasoning = false
show_raw_agent_reasoning = false

# Profiles for different workflows
[profiles.research]
model_reasoning_effort = "high"
[profiles.research.features]
web_search_request = true

[profiles.refactoring]
approval_policy = "never"
model_reasoning_effort = "medium"

[profiles.security-audit]
model_reasoning_effort = "high"
approval_policy = "never"
[profiles.security-audit.mcp_servers.github]
enabled = true
```

### Configuration Validation

**Safety Checks:**
```bash
# Validate TOML syntax
codex --config ~/.codex/config.toml --help

# List all configured tools
codex --list-tools

# Test MCP server connectivity
codex --test-mcp  # If available

# Verify feature enablement
codex --show-features
```

### Monitoring and Iteration

**Key Metrics to Track:**
1. **Token Usage:** Average tokens per session, growth rate
2. **Cost:** Monthly API costs, cost per session
3. **Performance:** Average task completion time, success rate
4. **Context Efficiency:** Compaction frequency, history file size
5. **Errors:** MCP timeout errors, approval rejections, sandbox violations

**Adjustment Triggers:**
- Token usage exceeds budget → Increase compaction, reduce context
- MCP errors → Adjust timeouts, disable problematic servers
- Slow performance → Profile reasoning effort, reduce enabled tools
- High costs → Disable web search, reduce project doc limits

### Version-Specific Considerations

**For GPT-5.2-Codex:**
- Leverage enhanced reasoning for complex tasks
- Take advantage of improved Windows support
- Use cybersecurity features if applicable
- Monitor for new context window optimizations

**For Earlier Models:**
- Tighter context windows require more aggressive compaction
- Consider GPT-5.1-Codex-Max for extended sessions
- Web search may be less reliable; verify results

---

## References and Sources

### Official Documentation
- [Configuring Codex](https://developers.openai.com/codex/local-config/)
- [Codex Configuration Documentation](https://github.com/openai/codex/blob/main/docs/config.md)
- [Codex Example Configuration](https://github.com/openai/codex/blob/main/docs/example-config.md)
- [Model Context Protocol](https://developers.openai.com/codex/mcp/)
- [Custom Instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md/)
- [Slash Commands in Codex CLI](https://developers.openai.com/codex/guides/slash-commands/)

### Feature Releases
- [Introducing GPT-5.2-Codex](https://openai.com/index/introducing-gpt-5-2-codex/)
- [GPT-5.1-Codex-Max Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-1-codex-max_prompting_guide)
- [Codex Changelog](https://developers.openai.com/codex/changelog/)

### Performance and Optimization
- [Context Compaction Guide](https://forgecode.dev/docs/context-compaction/)
- [OpenAI Codex CLI Memory - Deep Dive](https://mer.vin/2025/12/openai-codex-cli-memory-deep-dive/)
- [10 OpenAI Codex Fixes for Performance Nightmares](https://medium.com/@ThinkingLoop/10-openai-codex-fixes-for-performance-nightmares-ad55d3fc293a)

### Community Resources
- [Codex Settings Repository](https://github.com/feiskyer/codex-settings)
- [Codex MCP Configuration Guide](https://vladimirsiedykh.com/blog/codex-mcp-config-toml-shared-configuration-cli-vscode-setup-2025)
- [Ultimate Codex CLI MCP Guide](https://blog.wenhaofree.com/en/posts/technology/codex-mcp-comprehensive-guide/)
- [MCP Plug Guide](https://www.vibesparking.com/en/blog/ai/openai/codex/mcp/2025-09-10-codex-mcp-setup-10-servers/)

---

## Next Steps and Action Items

### Immediate Actions (This Week)

1. **Review Current Configuration**
   - Compare existing `config.toml.tmpl` with template provided in Section 8
   - Identify deviations and evaluate if intentional

2. **Audit MCP Servers**
   - List all configured MCP servers
   - Identify unused or rarely-used servers
   - Estimate context window impact

3. **Test History Compaction**
   - Create extended session to trigger compaction
   - Monitor compaction quality and preserved context

### Short-term Improvements (Next 2 Weeks)

1. **Implement Conservative Optimization Profile**
   - Apply base configuration template
   - Enable only essential features
   - Profile-based activation for experimental features

2. **Establish Monitoring**
   - Set up token usage tracking
   - Monitor session lengths and compaction frequency
   - Track API costs

3. **Test GPT-5.2-Codex**
   - Upgrade to latest model if not already
   - Compare performance vs. earlier models
   - Validate cybersecurity capabilities if relevant

### Medium-term Enhancements (Next Month)

1. **Custom Skills Development**
   - Create domain-specific skills for dissertation and work projects
   - Evaluate skills feature stability before production use

2. **Advanced Profiles**
   - Develop specialized profiles for different workflows
   - Security audit profile for sensitive code
   - Research profile with web search enabled
   - Refactoring profile with high reasoning effort

3. **MCP Server Optimization**
   - Profile-based MCP server activation
   - Performance testing with different server configurations
   - Timeout tuning based on actual performance

### Ongoing Maintenance

- Monthly review of configuration effectiveness
- Quarterly evaluation of new features from upstream
- Regular audit of MCP server necessity
- Cost tracking and optimization
- Feedback collection on feature usefulness

---

**Document Complete**
Research conducted: December 22, 2025
Next review recommended: January 15, 2026 (after practical testing phase)
