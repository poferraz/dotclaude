---
description: Bootstrap a new project with Claude Code configuration
---

# /new-project — Project Bootstrap

You are bootstrapping a new project. Follow these steps exactly in order.

## Step 1: Collect Project Information

Use AskUserQuestion to collect:
- Project name
- Stack (language, framework, database — be specific, no defaults)
- Deployment target (if known)
- Package manager preference
- Whether this is a monorepo

Wait for all answers before proceeding.

## Step 2: Scaffold Project Structure

Create the `.claude/` directory structure in the project root:

```
.claude/
  settings.json   (project-level, inherits from global)
  rules/          (project-specific rules)
  agents/         (project-specific agents if needed)
  skills/         (project-specific skills if needed)
  commands/       (project-specific commands if needed)
```

Create `.claude/settings.json` with minimal project-level config:
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

## Step 2b: Generate TDD Agent Override (Go and Python only)

If the stack from Step 1 is **Go** or **Python**, create `.claude/agents/tdd-guide.md`
to override the global npm-only tdd-guide with the correct test runners:

**For Go projects** — create `.claude/agents/tdd-guide.md`:
```markdown
---
name: tdd-guide
description: >
  Enforce TDD methodology throughout implementation.
  Use when writing new features or fixing bugs.
tools:
  - Read
  - "Bash(go test ./...)"
  - "Bash(go test -cover ./...)"
  - "Bash(go test -run *)"
model: sonnet
---

# TDD Guide (Go)

Follow strict red-green-refactor:
1. Write a failing table-driven test first
2. Run `go test ./...` — confirm it fails
3. Write minimal implementation to pass
4. Run `go test -cover ./...` — verify coverage ≥ 80%
5. Refactor, keeping tests green
```

**For Python projects** — create `.claude/agents/tdd-guide.md`:
```markdown
---
name: tdd-guide
description: >
  Enforce TDD methodology throughout implementation.
  Use when writing new features or fixing bugs.
tools:
  - Read
  - "Bash(python -m pytest *)"
  - "Bash(python -m pytest --cov *)"
model: sonnet
---

# TDD Guide (Python)

Follow strict red-green-refactor:
1. Write a failing pytest test first
2. Run `python -m pytest` — confirm it fails
3. Write minimal implementation to pass
4. Run `python -m pytest --cov` — verify coverage ≥ 80%
5. Refactor, keeping tests green
```

Skip this step for all other stacks (TypeScript, etc.) — the global tdd-guide covers them.

## Step 3: Create Project-Level CLAUDE.md

Create `CLAUDE.md` in the project root with:
- A comment at the top: `# Global rules from ~/.claude/CLAUDE.md load automatically.`
- Stack section populated from Step 1 answers (language, framework, DB, etc.)
- Running Tests section with commands for the chosen stack
- Project-specific notes section (left blank for developer to fill)
- Under 150 lines
- Do NOT @import ~/.claude/CLAUDE.md — it loads automatically via hierarchical loading

**Show the generated file to the user before writing.**

## Step 4: Analyze Git History for Project-Specific Skills

Use AskUserQuestion to instruct the user:

"Step 4 of /new-project is ready. Please run the following command in
your Claude Code session to analyze this project's git history and
generate project-specific skills:

    /skill-create

Skip this if the project has no git history yet. Confirm when done
(or skipped) so I can continue to Step 5."

Wait for confirmation before proceeding.

## Step 5: Configure .mcp.json

Create `.mcp.json` in the project root based on the stack:
- Always include: GitHub MCP
- Include based on stack answers: Supabase, Vercel, Railway, etc.
- Disable unused MCPs via `disabledMcpServers`
- **Flag all API key placeholders — NEVER write real keys**
- Use placeholder format: `"YOUR_<SERVICE>_TOKEN_HERE"`

**Show the generated .mcp.json to the user before writing.**

## Step 6: Verify

Run `claude doctor` to verify the configuration.

## Step 7: Output Session Kickoff Summary

Display a summary including:
- Active plugins
- Active agents (global + project)
- Active skills
- Context budget estimate
- Current model
- Any flagged placeholders that need API keys
