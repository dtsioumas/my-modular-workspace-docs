# TODO - Home Manager Configuration

Last Updated: 2025-12-04

---

## Recent Completions (2025-12-04)

### OpenAI Codex Installation & Configuration

- [x] Research OpenAI Codex agent capabilities and configuration
- [x] Fix build errors during node2nix installation
  - [x] Resolved deprecated `system` parameter → `stdenv.hostPlatform.system`
  - [x] Removed MCP packages from npm-packages.json (native dependency conflicts)
  - [x] Resolved binary name conflict (claude-code.nix vs npm-tools.nix)
- [x] Install Codex via node2nix (declarative)
  - [x] Added `@openai/codex` to npm-packages.json
  - [x] Created codex-wrapper with Bitwarden API key integration
  - [x] Commented out old claude-code.nix (replaced by npm-tools.nix)
- [x] Configure Codex MCP servers
  - [x] context7 (technical docs search)
  - [x] firecrawl (web scraping)
  - [x] read-website-fast (GitHub docs)
  - [x] time (timezone operations)
  - [x] fetch (web content)
  - [x] sequential-thinking (structured reasoning)
- [x] Create global AGENTS.md with shared instructions
  - [x] Reference to ~/.claude/CLAUDE.md
  - [x] User context (name, timezone, role, preferences)
  - [x] ADHD-friendly task management approach
  - [x] Available MCP servers documentation
- [x] Fix config.toml syntax error
  - [x] Moved `project_doc_*` settings before `[features]` section
  - [x] TOML parsing issue resolved
- [x] Verify Codex installation
  - [x] `codex --version` returns `codex-cli 0.64.0`
  - [x] Model upgraded to `gpt-5.1-codex`
- [x] Install OpenAI VSCodium extension (declarative)
  - [x] Added `pkgs.vscode-marketplace.openai.chatgpt` to vscodium.nix
- [x] Create comprehensive documentation
  - [x] docs/tools/codex.md (500+ lines)
  - [x] Installation, configuration, usage, troubleshooting
  - [x] MCP integration guide
  - [x] Comparison with Claude Code

---

## Pending Tasks

### Immediate (Session Continuation)

- [ ] Apply home-manager rebuild to install VSCodium extension
  ```bash
  cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
  home-manager switch --flake .#mitsio@shoshin
  ```
- [ ] Verify VSCodium extension installation
  - [ ] Open VSCodium
  - [ ] Check Extensions sidebar for OpenAI extension
  - [ ] Test authentication (ChatGPT account login)
- [ ] Commit changes to git
  - [ ] npm-packages.json (added Codex)
  - [ ] npm-tools.nix (codex-wrapper, fixed system parameter)
  - [ ] home.nix (commented claude-code.nix, added npm-tools.nix)
  - [ ] vscodium.nix (added openai.chatgpt extension)
  - [ ] ~/.codex/config.toml (created, fixed syntax)
  - [ ] ~/.codex/AGENTS.md (created)
  - [ ] docs/tools/codex.md (created)
  - [ ] docs/TODO.md (this file)
- [ ] Use Codex for web research about itself
  - [ ] Research additional capabilities via Codex CLI
  - [ ] Document MCP integration best practices
  - [ ] Test different MCP servers
  - [ ] Compare actual usage with Claude Code

### Future Improvements

- [ ] Test Codex with real coding tasks
- [ ] Fine-tune approval_policy and sandbox_mode
  - Current: `approval_policy = "on-request"`, `sandbox_mode = "workspace-write"`
  - Consider: More restrictive for production, more permissive for experimentation
- [ ] Configure additional MCP servers if needed
  - [ ] exa (AI-powered web search) - requires API key
  - [ ] grok (Chat with Grok AI)
  - [ ] chatgpt (Chat with ChatGPT)
- [ ] Create project-specific AGENTS.md files
  - [ ] Dissertation project
  - [ ] Eyeonix work repositories
  - [ ] Personal projects
- [ ] Explore Codex cloud delegation features
- [ ] Document workflow patterns
  - When to use Codex vs Claude Code
  - MCP server usage patterns
  - Approval policy strategies

---

## Known Issues & Solutions

### 1. Native Dependency Build Failures

**Issue**: MCP packages with native dependencies (e.g., `canvas` via `@just-every/mcp-read-website-fast`) fail to build with node2nix.

**Error**: `pkg-config: command not found`, `gyp ERR! configure error`

**Solution**: Install MCP servers via `local-mcp-servers.nix` using wrapper scripts that call `npx` on-demand, NOT via `npm-packages.json`.

**Files**:
- ✅ `local-mcp-servers.nix` - MCP server wrappers (existing)
- ❌ `npm-packages.json` - DO NOT add MCP packages here

### 2. Binary Name Conflicts

**Issue**: Multiple packages trying to install the same binary (e.g., `claude` from both claude-code.nix and npm-tools.nix).

**Error**: `pkgs.buildEnv error: two given paths contain a conflicting subpath`

**Solution**: Use only one installation method per tool. Commented out `claude-code.nix` in favor of consolidated `npm-tools.nix`.

### 3. TOML Section Boundary Issues

**Issue**: Top-level config options placed after a `[section]` header get parsed as part of that section, causing type mismatches.

**Error**: `invalid type: sequence, expected a boolean in \`features\``

**Solution**: Always place top-level options BEFORE any `[section]` headers, or create a dedicated section for them.

---

## Session History

### 2025-12-04: OpenAI Codex Installation

**Goal**: Install and configure OpenAI Codex agent with MCP integration and VSCodium extension.

**Roles**: Platform Engineer, Technical Researcher

**Key Decisions**:
1. Use node2nix for reproducible npm package installation (not imperative npm install)
2. Consolidate npm tools in npm-tools.nix (Claude Code + Codex wrappers)
3. Install MCP servers separately via local-mcp-servers.nix (avoid native dependency issues)
4. Share global instructions between Claude Code and Codex via ~/.claude/CLAUDE.md
5. Use declarative VSCodium extension installation (not imperative)

**Challenges Overcome**:
1. Deprecated Nix parameter (`system` → `stdenv.hostPlatform.system`)
2. Native dependency build failures (removed MCP packages from npm-packages.json)
3. Binary name conflicts (consolidated to npm-tools.nix)
4. TOML syntax error (section boundary issue)

**Result**: Codex successfully installed, configured, and documented. VSCodium extension ready for rebuild.

---

## References

- **Codex Documentation**: docs/tools/codex.md
- **Installation Guide**: docs/home-manager/node2nix.md (if exists)
- **Global Instructions**: ~/.claude/CLAUDE.md (shared)
- **Codex Instructions**: ~/.codex/AGENTS.md (Codex-specific)
- **MCP Servers**: home-manager/local-mcp-servers.nix

---

## Notes

- **MCP Integration**: Both Claude Code and Codex can access the same MCP servers configured in their respective config files
- **API Keys**: Wrapper scripts use Bitwarden for secure key storage with environment variable fallback
- **Session Persistence**: Codex saves transcripts to ~/.codex/transcripts/ when `persistence = "save-all"`
- **Model Selection**: Codex upgraded to `gpt-5.1-codex` automatically on first run
- **Authentication**: User has ChatGPT subscription, will use ChatGPT account auth (not API key)
