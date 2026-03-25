# Customization Guide

How to adapt this setup to your stack, workflow, and tools.

---

## Changing the Stack

This configuration is intentionally stack-agnostic at the global level. Stack-specific knowledge lives at the project level.

### Step 1: Run /new-project

The `/new-project` command bootstraps a project-level `.claude/` directory with a minimal `CLAUDE.md` (5–10 lines). That minimal CLAUDE.md is intentional — the research (Gloaguen et al., 2026) shows comprehensive guides don't help. Only add what the agent can't discover from reading the code.

```bash
# In your project directory:
/new-project
```

The command will ask for your stack (language, framework, database) and generate:
- `.claude/settings.json` (project-level permissions)
- `.claude/agents/tdd-guide.md` (if Go or Python — overrides the npm-based global)
- `CLAUDE.md` (5–10 lines: stack declaration + test commands)
- `.mcp.json` (GitHub + stack-specific MCP servers)

### Step 2: Override agents for your test runner

The global `tdd-guide` and `refactorer` agents use npm-based Bash tool rules. For other stacks, copy the agent to `.claude/agents/` and update the tools:

**Go:**
```yaml
tools:
  - Read
  - "Bash(go test ./...)"
  - "Bash(go test -cover ./...)"
  - "Bash(go test -run *)"
```

**Python:**
```yaml
tools:
  - Read
  - "Bash(python -m pytest *)"
  - "Bash(python -m pytest --cov *)"
```

**Rust:**
```yaml
tools:
  - Read
  - "Bash(cargo test *)"
  - "Bash(cargo tarpaulin *)"
```

The `/new-project` command generates the Go and Python overrides automatically.

### Step 3: Add stack-specific rules (optional)

If you have non-obvious project conventions, add a `CLAUDE.md` to the project root. Keep it under 15 lines. Include only what Claude can't discover from the codebase:

```markdown
# Project CLAUDE.md

## Stack
Next.js 15 / TypeScript / PostgreSQL / Prisma

## Running Tests
npm test                   # unit tests
npm run test:e2e           # Playwright E2E
npm run db:reset && npm test  # reset test DB first

## Non-obvious conventions
- All API routes return { success: boolean, data: T | null, error: string | null }
- Database queries go in lib/db/, never in route handlers
- Error boundaries are required for all page components
```

---

## Adding and Removing Agents

### Adding an agent

Create a file in `~/.claude/agents/my-agent.md` with frontmatter:

```yaml
---
name: my-agent
description: >
  One clear sentence about what this agent does and when to use it.
tools:
  - Read
  - Grep
  - Glob
model: sonnet
---

One sentence system prompt. Do one thing. Do it well.
```

**The bar for adding an agent:** It must do something Claude wouldn't do correctly without explicit configuration, AND it must be a recurring need across multiple projects. One-off tasks don't need agents.

**Choosing a persona strategy (Hu et al., 2026):**

Classify the task, then apply the matching strategy:

```yaml
# PRETRAINING task (code logic, debugging, refactoring, tests):
# → Empty body or single behavioral constraint. No persona.
---
name: my-reviewer
description: Review X for correctness and edge cases.
tools: [Read, Grep, Glob]
model: sonnet
---
# Empty — or one line like "Report findings only. Never implement."

# ALIGNMENT task (documentation, style, tone, UI/UX):
# → 1–2 sentence persona. Short.
---
name: my-doc-writer
...
---
You write docs that match the project's existing tone and structure.
Update only what is stale. Never add unprompted.

# SAFETY task (security, threat modeling, risk analysis):
# → Full 50+ word persona. Be specific about domain and adversarial posture.
---
name: my-security-checker
...
---
You are a meticulous security auditor specialized in [specific domain].
Evaluate both explicit content and implicit intent. Apply principled
judgment, not keyword filtering. Output severity-ranked findings.

# MIXED task (planning, multi-step reasoning with output formatting):
# → Behavioral constraint only. Not a persona — just a rule.
---
name: my-planner
...
---
Require user confirmation before any implementation begins.
```

The critical insight: a persona that "sounds helpful" for a code task ("You are an expert software engineer who writes clean, idiomatic code") can actively degrade output quality. The model already knows how to write clean code — the persona redirects attention away from your actual problem toward maintaining the persona narrative.

### Removing an agent

Delete the file. Or move it to your project's `.claude/agents/` if it's only relevant there.

The three agents most users actually need daily:
- `planner` — before any multi-file task
- `debugger` — when root cause isn't obvious
- `code-reviewer` — before any commit

Start with these three. Add others only when you notice a recurring gap.

---

## Adding Skills

### When to add a skill

A skill earns its place when:
1. It contains knowledge Claude can't reliably produce from training (proprietary standards, non-obvious domain rules)
2. It's needed frequently enough across sessions to warrant being a dedicated file
3. It's too long to include in an agent's system prompt

Ask yourself: "If I deleted this skill, would Claude's output be meaningfully worse?" If the answer is "maybe" or "I'm not sure," don't add it.

### Creating a skill

```yaml
---
name: my-skill
description: One sentence — used to decide when to load this skill.
user-invocable: true
---

# My Skill

[Knowledge content. No code behavior. No instructions — just reference material.]
```

### Loading modes

**On-demand (preferred):** The user or agent invokes the skill explicitly with the Skill tool. Zero tokens when not needed.

**Agent-preloaded:** Add to an agent's frontmatter:
```yaml
skills:
  - my-skill
```
This loads every time that agent runs. Only appropriate when the skill is needed for 100% of that agent's tasks.

**Never auto-load via CLAUDE.md @import:** This loads the skill every session regardless of task. Almost never the right choice.

---

## Configuring Hooks

The hook system is the most powerful and most dangerous part of the setup. Hooks run shell commands on every event — a poorly configured hook can add thousands of tokens to every turn.

### Safe hook additions

**Session end logging (already included):**
```json
"SessionEnd": [{
  "hooks": [{
    "type": "command",
    "command": "echo \"Session ended at $(date)\" >> ~/.claude/sessions/session-log.txt"
  }]
}]
```

**Strategic compact suggestion (via skill):**
```json
"PreToolUse": [{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "bash ~/.claude/skills/strategic-compact/suggest-compact.sh"
  }]
}]
```

### Hook rules

1. **Never print large output from hooks** — anything printed goes into Claude's context. Keep hook stdout under 200 characters.
2. **Use timeouts** — always set `"timeout": 60` or similar to prevent hanging sessions
3. **Test hooks before enabling** — run the command manually and measure its output size
4. **Prefer Stop over PostToolUse** — if you only need end-of-session behavior, use Stop (once per session) not PostToolUse (once per tool call)

---

## Session Memory: beads vs context-mode

This setup uses **context-mode** for session memory. An alternative is **beads** (steveyegge/beads).

| | context-mode | beads |
|---|---|---|
| **Model** | Automatic observation via hooks | Manual task tracking |
| **Storage** | Semantic index, compressed | Structured task/subtask tree |
| **Recall** | Semantic search via MCP | Direct file reference |
| **Best for** | "What did I work on last week?" | "What's the state of this multi-week feature?" |
| **Token cost** | 1,500–3,000 per session (compressed) | ~500 per session (structure only) |
| **Setup** | Install context-mode plugin, configure hooks | Install beads, add to CLAUDE.md |

**Recommendation:** Use context-mode if you want automatic session history and semantic search. Use beads if you want explicit task tracking for long-running projects. They can coexist — beads for task state, context-mode for session history.

---

## Disabling Components You Don't Need

### Disable context-mode (if you want a minimal setup)

Remove the SessionStart, UserPromptSubmit, PostToolUse, and Stop hooks from `settings.json`. Also remove from `enabledPlugins`:
```json
"context-mode@context-mode": false
```

### Disable specific agents

Delete the agent file. Agents only load when explicitly invoked — they don't cost tokens sitting in the directory.

### Disable plugins

Set to `false` in `enabledPlugins`:
```json
"everything-claude-code@everything-claude-code": false
```

### Use a different model default

Change `"model": "sonnet"` to `"model": "haiku"` for cheaper sessions, or `"model": "opus"` for maximum quality. Individual agents override this with their own `model:` frontmatter.
