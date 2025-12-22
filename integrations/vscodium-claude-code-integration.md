# VSCodium + Claude Code CLI Integration Guide

This guide provides comprehensive configuration and integration patterns for using Claude Code CLI (NOT the VSCode extension) with VSCodium as your primary editor.

## Table of Contents

1. [Quick Start](#quick-start)
2. [File Opening from Claude Code](#file-opening-from-claude-code)
3. [Using Claude Code in VSCodium Terminal](#using-claude-code-in-vscodium-terminal)
4. [Passing Text from VSCodium to Claude Code](#passing-text-from-vscodium-to-claude-code)
5. [Claude Code Configuration](#claude-code-configuration)
6. [Advanced VSCodium Integration Patterns](#advanced-vscodium-integration-patterns)
7. [Complete Example Workflows](#complete-example-workflows)
8. [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Install Prerequisites

```bash
# Install Claude Code CLI (if not already installed)
npm install -g @anthropic-ai/claude-code

# Ensure VSCodium is installed
brew install vscodium  # macOS
# or use your system package manager

# Verify installations
claude --version
codium --version
```

### 2. Basic Configuration

```bash
# Initialize Claude Code configuration
claude /config

# Key settings to configure:
# - Model: Set to claude-opus-4-5 or claude-sonnet-4-5
# - Diff tool: Set to "auto" for automatic IDE detection
# - Editor command: Ensure "codium" is available in PATH
```

### 3. Test the Integration

```bash
# From VSCodium integrated terminal, test file opening:
claude /ide  # Connect to VSCodium instance

# In your Claude Code session, test opening a file:
# @filename.txt
# Then accept Claude's suggestion to open in editor
```

---

## File Opening from Claude Code

### How It Works

Claude Code can open files in VSCodium through three mechanisms:

1. **Automatic IDE Detection** - When Claude Code recognizes a supported IDE is available
2. **Manual `/ide` Command** - When running from external terminal
3. **VSCodium CLI Integration** - Using `codium` command with proper configuration

### VSCodium Command-Line Arguments

VSCodium accepts the same command-line arguments as VS Code, but uses `codium` instead of `code`:

```bash
# Basic file opening
codium filename.txt

# Open at specific line (note: may have issues with line numbers)
codium filename.txt:42

# Open current directory in VSCodium
codium .

# Open file in existing window (reuse window)
codium --reuse-window filename.txt

# Open folder
codium path/to/folder

# Open with specific profile
codium --profile dev-profile filename.txt
```

### Configuring Automatic File Opening

Claude Code's auto file opening is controlled by the editor configuration. To ensure proper integration:

#### Via CLI Configuration

```bash
# Open Claude Code config
claude /config

# Navigate to Settings → Editor
# Ensure "codium" is selected as the editor command
```

#### Via Configuration Files

Edit `~/.claude/settings.json`:

```json
{
  "editor": {
    "command": "codium",
    "openCommand": "codium --reuse-window"
  }
}
```

Or at project level (`.claude/settings.json`):

```json
{
  "editor": {
    "command": "codium",
    "openCommand": "codium --reuse-window --new-window"
  }
}
```

### Using the `/ide` Command

When running Claude Code from an external terminal (e.g., kitty), use the `/ide` command to establish connection:

```bash
# Start Claude Code session
claude

# Within the session, run:
/ide

# Claude Code will:
# 1. Detect VSCodium instance
# 2. Enable IDE-aware features
# 3. Allow file opening in VSCodium
# 4. Display diffs in IDE instead of terminal
```

### Troubleshooting File Opening

If Claude Code doesn't open files in VSCodium:

1. **Verify `codium` is in PATH:**
   ```bash
   which codium
   # If not found, add to PATH or create symlink
   ```

2. **Check IDE Detection:**
   ```bash
   # Run in VSCodium integrated terminal
   claude /config
   # Verify diff tool is set to "auto"
   ```

3. **Manual Editor Configuration:**
   ```json
   {
     "diffTool": "auto",
     "editor": "codium",
     "editorArgs": ["--reuse-window"]
   }
   ```

4. **Known Issues (2025):**
   - VSCodium on Debian 12 may have extension detection issues
   - Ensure VSCodium is updated to latest stable version
   - Consider fallback: Use `/ide` command manually if auto-detection fails

---

## Using Claude Code in VSCodium Terminal

### Terminal Setup

VSCodium provides a fully functional integrated terminal that works seamlessly with Claude Code.

#### Configure Terminal Profile

Edit `.vscode/settings.json` in your project:

```json
{
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.profiles.linux": {
    "bash": {
      "path": "/bin/bash",
      "args": ["-l"],
      "icon": "terminal-bash"
    }
  },
  "terminal.integrated.shellIntegration.enabled": true,
  "terminal.integrated.shellIntegration.suggestEnabled": true
}
```

#### Enable Shell Integration

Shell integration enables features like command decorations, working directory detection, and better terminal output parsing:

```bash
# Verify shell integration is active (VSCodium terminal shows command decorations)
# If not automatic, manually initialize:
source ~/.bashrc  # or your shell's rc file
```

### Running Claude Code in Integrated Terminal

```bash
# Open VSCodium terminal
# Default: Ctrl+` (backtick)

# Start interactive Claude Code session
claude

# Or run one-shot commands
claude "explain this code" @path/to/file.ts

# With pipe input
cat file.txt | claude -p "summarize this"
```

### Terminal Configuration for Optimal Performance

#### 1. Shell Integration Setup

Add to your shell configuration (`.bashrc`, `.zshrc`):

```bash
# Enable Claude Code terminal features
export CLAUDE_CODE_TERMINAL_INTEGRATION=1

# Set default editor for Claude Code
export EDITOR="codium --wait"

# Increase timeout for long-running operations
export BASH_DEFAULT_TIMEOUT_MS=60000
```

#### 2. VSCodium Settings for Claude Code

In `.vscode/settings.json`:

```json
{
  "terminal.integrated.fontSize": 12,
  "terminal.integrated.lineHeight": 1.2,
  "terminal.integrated.scrollback": 1000,

  "claude-code.enableTerminalIntegration": true,
  "claude-code.autoDetectIDE": true,
  "claude-code.diffTool": "auto",

  "workbench.colorCustomizations": {
    "terminal.ansiBlack": "#1e1e1e"
  }
}
```

#### 3. Keybinding for Quick Terminal Toggle

Add to `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+grave",
    "command": "workbench.action.terminal.toggleTerminal",
    "when": "!terminalFocus"
  },
  {
    "key": "ctrl+shift+grave",
    "command": "workbench.action.terminal.focus",
    "when": "terminalFocus"
  }
]
```

### Running Claude Code with Initial Prompt

```bash
# Start Claude with a file reference
claude "refactor this function to be more efficient" @src/utils/parser.ts

# Start with multiple files
claude "analyze these files for security issues" @src/auth/*.ts @src/security/*.ts

# With inline prompt
claude --print <<EOF
Explain what this code does:

$(cat file.ts)
EOF
```

---

## Passing Text from VSCodium to Claude Code

### Method 1: Direct Terminal Input

The simplest method - select text in editor, then manually pipe to Claude:

```bash
# Copy selected text (Ctrl+C in editor)
# Paste in terminal and pipe to Claude
cat <<'EOF' | claude -p "explain this code"
[pasted code here]
EOF
```

### Method 2: Shell Script Wrapper

Create a shell script to automate text passing via clipboard:

#### Create `~/.local/bin/claude-from-editor`

```bash
#!/bin/bash
# Pass selected text from editor to Claude Code

# Get clipboard content (works with most editors)
TEXT=$(xclip -selection clipboard -o 2>/dev/null || pbpaste 2>/dev/null)

if [ -z "$TEXT" ]; then
    echo "Error: No text in clipboard"
    exit 1
fi

# Optional: Get prompt from first argument
PROMPT="${1:-Review and suggest improvements for this code:}"

# Send to Claude with print flag (non-interactive)
echo "$TEXT" | claude -p "$PROMPT"
```

Make executable:

```bash
chmod +x ~/.local/bin/claude-from-editor
```

#### Create `~/.local/bin/claude-interactive`

For interactive sessions with selected text:

```bash
#!/bin/bash
# Start interactive Claude session with clipboard content pre-loaded

TEXT=$(xclip -selection clipboard -o 2>/dev/null || pbpaste 2>/dev/null)

if [ -z "$TEXT" ]; then
    # No clipboard content, start normal session
    claude
else
    # Create temp file with content
    TEMP_FILE=$(mktemp)
    echo "$TEXT" > "$TEMP_FILE"

    # Start Claude with file reference
    claude "Analyze this:" @"$TEMP_FILE"

    # Cleanup
    rm "$TEMP_FILE"
fi
```

### Method 3: VSCodium Custom Commands via Tasks

Create `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Claude: Review Code",
      "type": "shell",
      "command": "claude",
      "args": ["-p", "Review and suggest improvements:"],
      "isBackground": false,
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "Claude: Explain Selection",
      "type": "shell",
      "command": "bash",
      "args": [
        "-c",
        "pbpaste | claude -p 'Explain what this code does and how to improve it:'"
      ],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "Claude: Interactive Session",
      "type": "shell",
      "command": "claude",
      "isBackground": false,
      "presentation": {
        "reveal": "always",
        "panel": "new",
        "focus": true
      }
    }
  ]
}
```

Bind to keybindings in `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+c",
    "command": "workbench.action.tasks.runTask",
    "args": "Claude: Review Code",
    "when": "editorTextFocus"
  },
  {
    "key": "ctrl+shift+alt+c",
    "command": "workbench.action.tasks.runTask",
    "args": "Claude: Explain Selection",
    "when": "editorTextFocus"
  }
]
```

### Method 4: External Terminal Integration (Recommended for kitty)

If you use kitty terminal, leverage its remote control capabilities:

#### Create `~/.local/bin/claude-kitty`

```bash
#!/bin/bash
# Send selected text from kitty terminal to Claude Code

# Get the selected text from kitty
if command -v kitty &> /dev/null; then
    # Using kitty's capabilities
    TEXT=$(xclip -selection primary -o 2>/dev/null)
else
    TEXT=$(xclip -selection clipboard -o 2>/dev/null || pbpaste 2>/dev/null)
fi

if [ -z "$TEXT" ]; then
    echo "No text selected"
    exit 1
fi

PROMPT="${1:-Analyze this code:}"

# Start Claude in new kitty window with text
echo "$TEXT" | claude -p "$PROMPT"
```

### Method 5: Stdin Piping with Claude

Claude Code supports piping input via the `-p`/`--print` flag:

```bash
# Pipe from file
cat script.sh | claude -p "Explain what this script does"

# Pipe from command
git diff HEAD | claude -p "Summarize these changes"

# Pipe from echo
echo "let x = 5;" | claude -p "Is this valid JavaScript?"

# Chain with other tools
grep -r "TODO" . | claude -p "List all TODO items and their priority"
```

### Clipboard Integration Patterns

For persistent clipboard integration, add to your shell config:

```bash
# Add function to your .bashrc/.zshrc
claude-clipboard() {
    local prompt="${1:-Review this code:}"
    xclip -selection clipboard -o 2>/dev/null | claude -p "$prompt"
}

# Usage
claude-clipboard "Find security issues in:"
```

---

## Claude Code Configuration

### Configuration File Hierarchy

Claude Code uses a hierarchical configuration system:

1. **Enterprise** (highest priority) - `managed-settings.json`
2. **Project Local** - `.claude/settings.local.json` (git-ignored)
3. **Project Shared** - `.claude/settings.json` (version controlled)
4. **User Global** (lowest priority) - `~/.claude/settings.json`

### Global Configuration Structure

Create `~/.claude/settings.json`:

```json
{
  "model": "claude-opus-4-5-20251101",

  "maxTokens": 4096,

  "editor": {
    "command": "codium",
    "openCommand": "codium --reuse-window",
    "waitForClose": true
  },

  "diffTool": "auto",

  "permissions": {
    "allow": ["Bash(npm run lint)", "Read(~/.zshrc)"],
    "deny": ["Bash(curl:*)", "Read(.env*)"],
    "additionalDirectories": ["../docs", "../shared-libs"]
  },

  "env": {
    "EDITOR": "codium",
    "BASH_DEFAULT_TIMEOUT_MS": "60000"
  },

  "sandbox": {
    "enabled": true,
    "excludedCommands": ["docker", "nix"]
  },

  "terminal": {
    "shell": "bash",
    "shellArgs": ["-l"]
  }
}
```

### Project-Specific Configuration

Create `.claude/settings.json` in your project root:

```json
{
  "model": "claude-sonnet-4-5-20250929",

  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx)",
      "Read(src/**)",
      "Read(docs/**)",
      "Read(package.json)"
    ],
    "deny": [
      "Read(.env*)",
      "Read(secrets/**)",
      "Bash(rm -rf)"
    ],
    "additionalDirectories": ["docs", "examples"]
  },

  "fileSuggestion": {
    "type": "command",
    "command": "find . -type f -name '*.ts' -o -name '*.tsx' | head -20"
  }
}
```

### Local Overrides

Create `.claude/settings.local.json` (add to `.gitignore`):

```json
{
  "permissions": {
    "allow": ["Bash(rm -rf)"]
  },
  "maxTokens": 8000,
  "ANTHROPIC_API_KEY": "sk-..."
}
```

### Global Instructions

Create `~/.claude/CLAUDE.md` for persistent system instructions:

```markdown
# Global Claude Code Instructions

## VSCodium Integration

- Always open files in VSCodium using the `/ide` command when available
- Use `codium --reuse-window` to avoid opening multiple windows
- Enable diff viewing in VSCodium rather than terminal display

## Preferred Practices

- Use TypeScript over JavaScript
- Prefer functional programming patterns
- Write tests for all new code
- Document complex functions with JSDoc

## Project Structure

When working with the my-modular-workspace project:
- Respect the NixOS, Ansible, and Home Manager structure
- Always check existing ADRs before making architecture decisions
- Run tests before suggesting deployment changes
```

### Project-Specific Instructions

Create `.claude/CLAUDE.md`:

```markdown
# Project-Specific Instructions

## Context

This is a NixOS-based workspace project with IaC practices.

## Editor Integration

- Files should be opened in VSCodium
- Respect existing configurations in `/etc/nixos/`
- Test all configuration changes in VM before production

## Testing Requirements

- All Nix changes must build successfully
- Ansible playbooks must run without errors
- Home Manager configurations must not break existing setup
```

---

## Advanced VSCodium Integration Patterns

### Pattern 1: IDE-Aware Diff Viewing

VSCodium can display diffs directly in the editor instead of terminal output:

#### Enable Automatic Diff Viewing

In `.vscode/settings.json`:

```json
{
  "claude-code.diffTool": "auto",
  "claude-code.enableDiffPreview": true,
  "[diff]": {
    "editor.wordWrap": "off",
    "editor.renderWhitespace": "none"
  }
}
```

#### Keybinding for Accepting Diffs

In `keybindings.json`:

```json
[
  {
    "key": "ctrl+enter",
    "command": "editor.action.acceptSelectedSuggestion",
    "when": "diffEditorFocus"
  }
]
```

### Pattern 2: Code Actions Integration

Use VS Code's code actions to integrate Claude Code:

Create `.vscode/codeActions.json`:

```json
{
  "actions": [
    {
      "id": "claude.explainCode",
      "title": "Explain with Claude",
      "when": "editorTextFocus",
      "command": "workbench.action.tasks.runTask",
      "args": "Claude: Explain Selection"
    }
  ]
}
```

### Pattern 3: Snippet Generation from Claude

Store Claude-generated snippets with custom keybindings:

In `.vscode/snippets/claude-generated.json`:

```json
{
  "Claude Generated": {
    "prefix": "claude",
    "body": [
      "// Generated by Claude Code",
      "$0"
    ],
    "description": "Insert Claude-generated code"
  }
}
```

### Pattern 4: Problem Matcher for Claude Output

Create custom problem matchers for parsing Claude Code output:

In `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Claude Analysis",
      "type": "shell",
      "command": "claude",
      "args": ["-p", "Find issues in this code"],
      "problemMatcher": {
        "pattern": {
          "regexp": "^(.*?):(\\d+):(\\d+):\\s*(error|warning|info)\\s*(.*)$",
          "file": 1,
          "location": 2,
          "column": 3,
          "severity": 4,
          "message": 5
        }
      }
    }
  ]
}
```

### Pattern 5: Output Channel Integration

Create a dedicated output channel for Claude results:

In `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+o",
    "command": "workbench.action.output.toggleOutput",
    "when": "!outputFocus"
  }
]
```

### Pattern 6: Multi-File Context Gathering

Create a task that gathers multiple files for Claude analysis:

In `.vscode/tasks.json`:

```json
{
  "label": "Claude: Analyze Architecture",
  "type": "shell",
  "command": "bash",
  "args": [
    "-c",
    "echo '=== Architecture Files ===' && ls -la src/ && echo '\\n=== Dependencies ===' && cat package.json && echo '\\n=== Build Config ===' && cat build.config.ts | claude -p 'Analyze this project structure and suggest improvements'"
  ]
}
```

---

## Complete Example Workflows

### Workflow 1: Code Review Cycle

**Goal:** Use Claude Code for comprehensive code review with VSCodium integration.

#### Setup

1. Create review task in `.vscode/tasks.json`:

```json
{
  "label": "Claude: Full Code Review",
  "type": "shell",
  "command": "bash",
  "args": [
    "-c",
    "echo 'Files to review:' && find src -name '*.ts' | head -10 && echo '\\nRunning analysis...' && claude -p 'Review these TypeScript files for: 1) Type safety issues 2) Performance problems 3) Security concerns 4) Code style violations. Provide specific line numbers and suggestions.'"
  ],
  "presentation": {
    "reveal": "always",
    "panel": "new"
  }
}
```

2. Bind to keybinding:

```json
{
  "key": "ctrl+alt+r",
  "command": "workbench.action.tasks.runTask",
  "args": "Claude: Full Code Review"
}
```

#### Execution

1. Open VSCodium with your project
2. Press `Ctrl+Alt+R` to run review
3. Claude outputs findings in new panel
4. Copy findings to issue tracker or notes

### Workflow 2: Iterative Development with Real-Time Suggestions

**Goal:** Use Claude Code for interactive development with immediate code review.

#### Setup

```bash
# Terminal in VSCodium
claude

# Start interactive session
# @src/components/Button.tsx

# Type your request:
# Refactor this button component for accessibility and add TypeScript strict mode compliance
```

#### Process

1. Claude shows diff in VSCodium
2. Review changes with `codium --diff-tool=auto`
3. Accept/reject changes interactively
4. Claude makes further adjustments
5. Repeat until satisfied

### Workflow 3: Documentation Generation

**Goal:** Use Claude Code to generate comprehensive documentation from codebase.

#### Setup

Create `.vscode/tasks.json` task:

```json
{
  "label": "Claude: Generate Documentation",
  "type": "shell",
  "command": "bash",
  "args": [
    "-c",
    "find src -name '*.ts' -type f | head -20 | xargs -I {} bash -c 'echo \"## File: {}\" && cat {}' | claude -p 'Generate comprehensive documentation including: 1) Function signatures and purpose 2) Parameter explanations 3) Return value descriptions 4) Usage examples 5) Common pitfalls'"
  ]
}
```

#### Execution

1. Run task: `Ctrl+Shift+P` → `Tasks: Run Task` → `Claude: Generate Documentation`
2. Claude outputs formatted documentation
3. Copy output to `docs/` directory
4. Integrate into your doc site

### Workflow 4: VSCodium + Kitty Terminal Integration

**Goal:** Seamless workflow between kitty terminal and VSCodium using Claude Code.

#### Setup in kitty (`~/.config/kitty/kitty.conf`)

```ini
# Claude Code keybindings
map ctrl+shift+c send_text claude
map ctrl+shift+alt+c send_text claude --print "Analyze: "

# Copy to clipboard
map ctrl+c copy_to_clipboard

# Remote file editing
map ctrl+shift+e remote_control
```

#### Setup in VSCodium (`.vscode/settings.json`)

```json
{
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.external.linuxExec": "kitty",
  "claude-code.autoDetectIDE": true
}
```

#### Execution

1. Start Claude in kitty: `Ctrl+Shift+C`
2. Use `/ide` command to connect to VSCodium
3. Claude can now open files in VSCodium
4. Continue development seamlessly

---

## Troubleshooting

### Issue: Claude Code Cannot Find VSCodium

**Symptoms:**
- "Cannot detect IDE" message
- Files not opening in editor
- `/ide` command fails

**Solutions:**

1. Verify `codium` in PATH:
   ```bash
   which codium
   echo $PATH
   ```

2. Create symlink if needed:
   ```bash
   ln -s /Applications/VSCodium.app/Contents/Resources/app/bin/codium /usr/local/bin/codium
   ```

3. Manually configure in `~/.claude/settings.json`:
   ```json
   {
     "editor": {
       "command": "/path/to/codium",
       "openCommand": "/path/to/codium --reuse-window"
     }
   }
   ```

### Issue: Clipboard Content Not Passing to Claude

**Symptoms:**
- Piped text gets stuck
- Terminal hangs on `echo "text" | claude`
- "Raw mode not supported" errors

**Solutions:**

1. Use `-p` flag explicitly:
   ```bash
   cat file.txt | claude -p "summarize"
   # NOT: cat file.txt | claude "summarize"
   ```

2. Increase timeout:
   ```bash
   BASH_DEFAULT_TIMEOUT_MS=120000 claude
   ```

3. Use temp files instead:
   ```bash
   cat file.txt > /tmp/claude-input.txt
   claude "analyze this" @/tmp/claude-input.txt
   ```

### Issue: Shell Integration Not Working

**Symptoms:**
- Command decorations don't appear
- Working directory detection fails
- Keybindings don't respond

**Solutions:**

1. Re-enable shell integration:
   ```json
   {
     "terminal.integrated.shellIntegration.enabled": true
   }
   ```

2. Reinstall for your shell:
   ```bash
   # For zsh
   source ~/.zshrc

   # For bash
   source ~/.bashrc
   ```

3. Check shell profile order:
   - Ensure VSCodium shell settings match your preferred shell
   - Verify shell rc files are sourced correctly

### Issue: Diff View Not Appearing

**Symptoms:**
- Claude output shows as text instead of diff
- Cannot accept/reject changes
- No IDE integration features

**Solutions:**

1. Set diff tool to auto:
   ```bash
   claude /config
   # Navigate to Editor → Diff Tool → Auto
   ```

2. Manual configuration:
   ```json
   {
     "diffTool": "auto",
     "diffShowUnmodified": false
   }
   ```

3. Verify extension installation (if using VS Code version):
   ```bash
   codium --extensions-dir ~/.vscode-oss/extensions
   ```

### Issue: Files Opening in New Window Instead of Reusing

**Symptoms:**
- Multiple VSCodium windows open
- Not using existing workspace
- Messy workspace management

**Solutions:**

1. Use `--reuse-window` flag:
   ```json
   {
     "editor": {
       "openCommand": "codium --reuse-window"
     }
   }
   ```

2. Configure project-level settings:
   ```json
   {
     "editor": {
       "openCommand": "codium --reuse-window --folder-uri"
     }
   }
   ```

3. Test manually:
   ```bash
   codium --reuse-window test-file.txt
   ```

### Issue: VSCodium on Debian 12 - Extension Detection

**Symptoms:**
- "VSCodium Integration Fails: Extension Not Detected"
- Works on other systems but not Debian
- `/ide` command doesn't recognize VSCodium

**Known Issue (2025):**
This is a reported bug affecting VSCodium on Debian 12 specifically. Workarounds:

1. Update VSCodium to latest stable:
   ```bash
   sudo apt update && sudo apt upgrade vscodium
   ```

2. Use `/ide` command manually instead of relying on auto-detection:
   ```bash
   claude
   # Then type: /ide
   ```

3. Configure explicit editor path:
   ```json
   {
     "editor": {
       "command": "/usr/bin/codium"
     }
   }
   ```

4. Check VSCodium version:
   ```bash
   codium --version
   # Should be ≥ 1.95.0
   ```

### Issue: Long-Running Operations Timeout

**Symptoms:**
- Claude times out on large files
- "Timeout exceeded" messages
- Bash operations stuck

**Solutions:**

1. Increase timeout:
   ```bash
   export BASH_DEFAULT_TIMEOUT_MS=120000  # 2 minutes
   claude
   ```

2. Split large analysis:
   ```bash
   # Instead of analyzing all files at once
   for file in src/*.ts; do
       claude "analyze" @"$file"
   done
   ```

3. Use async mode:
   ```bash
   claude --print "async task" &
   ```

### Issue: Permission Denied on Scripts

**Symptoms:**
- Cannot execute shell scripts
- "Permission denied" on custom commands
- Tasks fail to run

**Solutions:**

1. Make scripts executable:
   ```bash
   chmod +x ~/.local/bin/claude-from-editor
   chmod +x .vscode/scripts/*.sh
   ```

2. Grant Claude Code permissions:
   ```json
   {
     "permissions": {
       "allow": ["Bash(sh)", "Bash(bash)", "Bash(~/.local/bin/*)"]
     }
   }
   ```

3. Test script directly:
   ```bash
   bash ~/.local/bin/claude-from-editor
   ```

---

## Best Practices

### 1. Terminal Hygiene

- Always use the `-p` flag for piped input
- Use `@filename` references instead of inline text when possible
- Keep terminal sessions focused and specific

### 2. Configuration Management

- Use project-level `.claude/settings.json` for team consistency
- Keep `.claude/settings.local.json` in `.gitignore`
- Document custom instructions in `.claude/CLAUDE.md`

### 3. IDE Integration

- Enable automatic IDE detection: `"diffTool": "auto"`
- Use `--reuse-window` to avoid workspace clutter
- Leverage diff viewing instead of terminal output

### 4. Performance

- Set reasonable token limits: `"maxTokens": 4096`
- Use file references (`@filename`) for context
- Batch similar tasks to avoid context switching

### 5. Shell Integration

- Enable shell integration for better command detection
- Use `export` for environment variables, not `export VAR=value`
- Keep shell startup fast by lazy-loading Claude initialization

### 6. Workflow Optimization

- Create task aliases for common workflows
- Use keybindings for frequent operations
- Organize custom commands in `.claude/commands/`

---

## References

### Official Documentation

- [Claude Code CLI Reference](https://code.claude.com/docs/en/cli-reference)
- [Claude Code Settings Documentation](https://code.claude.com/docs/en/settings)
- [VS Code Command Line Interface](https://code.visualstudio.com/docs/configure/command-line)
- [VS Code Shell Integration](https://code.visualstudio.com/docs/terminal/shell-integration)
- [VSCodium Official Site](https://vscodium.com/)

### Community Resources

- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code Guide](https://github.com/zebbern/claude-code-guide)
- [ClaudeLog - Claude Code Configuration](https://claudelog.com/configuration/)
- [Vibe Sparking AI - Claude Code Integration](https://www.vibesparking.com/en/blog/ai/claude-code/ide/2025-08-24-claude-code-ide-integration-vscode-cursor-jetbrains/)

### Integration Examples

- [kitty Remote File Support](https://sw.kovidgoyal.net/kitty/kittens/remote_file/)
- [kitty Shell Integration](https://sw.kovidgoyal.net/kitty/shell-integration/)
- [VS Code Tasks Documentation](https://code.visualstudio.com/docs/debugtest/tasks)
- [VS Code Keybindings](https://code.visualstudio.com/docs/getstarted/keybindings)

---

## Document Metadata

- **Last Updated:** 2025-12-22
- **Created By:** Mitsos (Dimitris Tsioumas)
- **Status:** Comprehensive Research (v1.0)
- **Applicable To:** VSCodium + Claude Code CLI integration (NOT VSCode extension)
- **Environment:** Linux (NixOS/Fedora Atomic compatible)

