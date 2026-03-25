# Architecture: Command → Agent → Skill

The three-tier orchestration model that makes this setup composable without becoming bloated.

## The Three Layers

```
┌─────────────────────────────────────────────────┐
│  COMMAND layer  (/plan, /tdd, /full-review)      │
│  Entry points. User-invocable. Orchestrate agents.│
└────────────────────────┬────────────────────────┘
                         │ invokes via Agent tool
                         ▼
┌─────────────────────────────────────────────────┐
│  AGENT layer  (planner, tdd-guide, debugger)     │
│  Single-responsibility subprocesses.             │
│  Scoped tools. Explicit model. One job.          │
└────────────────────────┬────────────────────────┘
                         │ loads via skills: frontmatter
                         │ or Skill tool
                         ▼
┌─────────────────────────────────────────────────┐
│  SKILL layer  (tdd-workflow, coding-standards)   │
│  Knowledge packs. No behavior — only context.    │
│  Load only when the agent actually needs them.   │
└─────────────────────────────────────────────────┘
```

### Layer 1: Commands

Commands are markdown files in `~/.claude/commands/` or `.claude/commands/`. They become slash commands (`/plan`, `/tdd`, `/verify`).

**What commands do:**
- Accept arguments from the user (`$ARGUMENTS`)
- Orchestrate one or more agents in sequence
- Handle checkpoints and user confirmation gates
- Write state to files when multi-step (e.g. `full-stack-feature` uses `.full-stack-feature/state.json`)

**What commands don't do:**
- Implement anything directly (that's agents)
- Load skills (that's agents)
- Run in the background

### Layer 2: Agents

Agents are markdown files with YAML frontmatter in `~/.claude/agents/`. Claude Code launches them as subprocesses with their own context window.

**Frontmatter fields that matter:**

```yaml
---
name: planner
description: >
  Produce phase-wise gated plans. Used before any multi-file task.
tools:
  - Read
  - Grep
  - Glob
  - WebSearch
model: opus          # override per-agent — planner uses Opus, doc-updater uses Haiku
memory: user         # access user memory files
skills:
  - tdd-workflow     # preloaded into this agent's context at launch
background: true     # runs without blocking the main session
---
```

**Single-responsibility rule:** Each agent does exactly one thing and reports back. The `debugger` diagnoses — it never implements. The `refactorer` changes structure — it never changes behavior. Mixing responsibilities creates god agents that are hard to reason about and easy to misuse.

**Tool scoping:** Each agent declares only the tools it needs. The `code-reviewer` only needs `Read`, `Grep`, `Glob`, and `Bash(git diff *)`. It cannot write files — by design. Narrow tool lists prevent agents from taking unintended actions.

### Layer 3: Skills

Skills are markdown files in `~/.claude/skills/<skill-name>/SKILL.md`. They are knowledge packs — not code, not behavior, just context that loads into an agent's prompt.

**Two loading modes:**

```
Mode 1 — Agent-preloaded:
  Agent's frontmatter has `skills: [tdd-workflow]`
  → SKILL.md loads into the agent's context when the agent launches
  → Agent has this knowledge for the entire conversation

Mode 2 — On-demand via Skill tool:
  Agent or Claude calls Skill tool with the skill name
  → SKILL.md loads into the current context on demand
  → Only costs tokens when actually needed
```

**Why skills are separate from agents:** A skill is reusable knowledge that multiple agents can load. The coding-standards skill can be loaded by the code-reviewer, the refactorer, or directly in the main session. If it lived inside one agent's system prompt, it would be duplicated across every agent that needs it.

---

## Why This Hierarchy Exists

### Separation of concerns

Each layer has a clear job:
- Commands know *what workflow to run*
- Agents know *how to do one specific thing*
- Skills know *domain knowledge about how to do it well*

Without this separation, you get god agents: single files that orchestrate, implement, review, and apply domain knowledge all at once. God agents are long, expensive to load, and impossible to test in isolation.

### Token efficiency

```
Without the hierarchy:
  One large agent loaded every session
  → 5,000 tokens in context even when you're writing a README

With the hierarchy:
  Agents load only when invoked
  Skills load only into the agents that need them
  → 0 tokens for agents/skills when not in use
```

### Composability

Commands mix and match agents. `/full-review` runs `code-reviewer` + `security-reviewer` + `doc-updater` in sequence — three agents with separate concerns, orchestrated by one command. Add a new agent and it can immediately participate in any command that needs it.

---

## How Agents Call Each Other

Agents invoke other agents via the **Agent tool**, never via bash:

```
✅ Correct:
  /full-review command → launches code-reviewer agent via Agent tool
                       → launches security-reviewer agent via Agent tool

❌ Wrong:
  /full-review command → bash: "claude -p 'review this code'"
```

The Agent tool gives each subagent its own context window. Bash subprocess calls would inherit the parent context, lose the ability to pass structured results, and break the permission model.

---

## Mermaid Diagram

```mermaid
graph TD
    U[User: /full-review] --> CMD[full-review.md command]
    CMD --> |Agent tool| A1[code-reviewer agent]
    CMD --> |Agent tool| A2[security-reviewer agent]
    CMD --> |Agent tool| A3[doc-updater agent]

    A1 --> |git diff| TOOLS1[Read, Grep, Glob]
    A2 --> |static analysis| TOOLS2[Read, Grep, Glob]
    A3 --> |background| TOOLS3[Read, Edit, Grep, Glob]

    U2[User: /tdd] --> CMD2[tdd.md command]
    CMD2 --> |Agent tool| A4[tdd-guide agent]
    A4 --> |skills: frontmatter| S1[tdd-workflow/SKILL.md]
    A4 --> |Bash| TOOLS4[npm test, npm run coverage]

    U3[User: /plan] --> CMD3[plan.md command]
    CMD3 --> |Agent tool| A5[planner agent]
    A5 --> |memory: user| MEM[User memory files]
```

---

## Project-Level Overrides

The global `~/.claude/` config is the baseline. Projects override by adding a `.claude/` directory to the project root:

```
project-root/
├── .claude/
│   ├── settings.json    # adds/removes permissions, enables project MCPs
│   ├── agents/
│   │   └── tdd-guide.md # override global tdd-guide with Go test runner
│   └── CLAUDE.md        # project-specific context (stack, test commands)
└── src/
```

Rules of override:
1. Project agents shadow global agents by the same `name:`
2. Project settings merge with global (project `allow` adds to global `allow`)
3. Project CLAUDE.md loads in addition to global CLAUDE.md — both are active
4. Use `/new-project` to scaffold the project `.claude/` structure correctly
