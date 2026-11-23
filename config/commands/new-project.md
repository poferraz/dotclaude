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

## Step 2b: Identify the project test command

Look for a test command in the project’s scripts, CI or contributor guide. Record that command in the project instructions. For a new project, ask which test runner the user expects before describing it as available. The bundled TDD guide provides read-only guidance across stacks. The main session runs authorized checks with its existing permissions.

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
