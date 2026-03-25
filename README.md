# dotclaude

**A research-backed global environment for Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-2.1.0%2B-blue)](https://claude.ai/code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/yourusername/dotclaude/pulls)

A curated `~/.claude/` configuration that combines the best open-source tools
from the Claude Code ecosystem into a single coherent setup. The key insight
behind this design: **most context files hurt performance** — they flood the
model's attention with boilerplate before a single line of your code is seen.
This setup is ruthlessly minimal. Every file, agent, and skill must earn its
tokens or it doesn't ship.

---

## Why This Exists

Coding agents perform measurably worse with bloated context files. When the
context window fills with generic instructions, framework boilerplate, and
catch-all rules, the model's attention is diluted before it ever sees your
actual problem. This isn't speculation — it's a consistent pattern observed
across published evaluations of LLM coding assistance and validated in
Anthropic's own guidance on effective system prompts.

Most "awesome Claude Code" setups operate in the opposite direction: they
add everything. Mega-agents with 20 tools. Skills with 500 lines of generic
advice. Commands for every conceivable workflow. The result is a system that
impresses in screenshots and degrades in daily use.

This configuration was born from real work — retail management tooling, PWA
development, bakery production planning — not theoretical best practices. It
was audited, stripped down, rebuilt leaner, and audited again. The agents you
see here survived because they provably helped. The ones that didn't are gone.

---

## What's Inside

```
~/.claude/
├── CLAUDE.md               # Core principles: think before coding, simplicity first,
│                           # surgical changes, goal-driven execution
├── settings.json           # Hardened permissions, lifecycle hooks, plugin registry
├── mcp.json                # MCP server config (GitHub, Google Drive; env-var only)
│
├── agents/                 # 8 lean, single-responsibility subagents
│   ├── code-reviewer.md    # SOLID/security/YAGNI review via git diff
│   ├── debugger.md         # Root-cause diagnosis only — never implements
│   ├── doc-updater.md      # Syncs docs after API/interface changes
│   ├── planner.md          # Phase-wise gated plans with acceptance criteria
│   ├── refactorer.md       # Structural cleanup with test-passing gates
│   ├── security-reviewer.md # Injection, auth gaps, secrets, data validation
│   ├── tdd-guide.md        # RED→GREEN→IMPROVE enforcement with coverage delta
│   └── ui-designer.md      # 2026-style React/Tailwind components
│
├── skills/                 # Preloaded knowledge packs for agents
│   ├── coding-standards/   # Language-agnostic quality rules (naming, structure,
│   │                       # error handling, immutability, code smells)
│   ├── continuous-learning-v2/  # Instinct-based learning from session patterns
│   ├── strategic-compact/  # Context compaction triggers at logical intervals
│   ├── tdd-workflow/       # TDD methodology loaded by the tdd-guide agent
│   ├── ui-ux-pro-max/      # 67 styles, 96 palettes, 57 font pairings
│   └── verification-loop/  # Systematic verification after multi-step changes
│
├── commands/               # Slash commands for repeatable workflows
│   ├── audit-repo.md       # Full GitHub repo audit
│   ├── build-fix.md        # Build error triage and resolution
│   ├── checkpoint.md       # Save session state before risky operations
│   ├── code-review.md      # Trigger code-reviewer agent
│   ├── evolve.md           # Analyze instincts and suggest refinements
│   ├── full-review.md      # Multi-agent comprehensive review orchestration
│   ├── full-stack-feature.md  # End-to-end feature implementation workflow
│   ├── instinct-status.md  # Show learned patterns with confidence scores
│   ├── learn.md            # Extract reusable patterns from the session
│   ├── new-project.md      # Bootstrap a new project with Claude Code config
│   ├── plan.md             # Restate requirements and build a gated plan
│   ├── pr-enhance.md       # PR quality and description enhancement
│   ├── tdd.md              # Enforce TDD throughout a feature
│   └── verify.md           # Run verification loop after changes
│
└── mcp.json                # GitHub + Google Drive (Supabase/Playwright disabled)
```

---

## Architecture Principles

This setup follows a three-tier orchestration model:

```
Command (/plan) → Agent (planner) → Skill (loaded knowledge)
```

- **Commands** are slash-invokable entry points for repeatable workflows
- **Agents** are single-responsibility subprocesses with scoped tools and
  explicit model selection (Opus for planning, Sonnet for everything else)
- **Skills** are knowledge packs — either preloaded via `skills:` frontmatter
  or invoked on-demand via the `Skill` tool

No god agents. No agents that spawn subagents via bash. No skills with 500 lines of boilerplate.

---

## Hooks Architecture

The `settings.json` runs a lifecycle hook system on four events:

| Event | Purpose |
|---|---|
| `SessionStart` | Install plugins, start context-mode worker, load session context |
| `UserPromptSubmit` | Prompt evaluation (via prompt-improver), session initialization |
| `PostToolUse` | Capture observations into the context-mode knowledge base |
| `Stop` | Summarize session, mark complete, log to `sessions/session-log.txt` |

All hooks call into the [context-mode](https://github.com/mksglu/context-mode)
worker service, which maintains a semantic session index and prevents raw tool
output from flooding the context window.

---

## Permission Model

`settings.json` uses an explicit allow/deny approach — permissions are off by
default and only unlocked when justified:

**Allowed by default:**
`Read`, `Glob`, `Grep`, `Bash(git *)`, `Bash(npm run *)`, `Bash(npx *)`,
`Bash(ls *)`, `Bash(mkdir *)`, `Bash(cp *)`, `Bash(chmod *)`,
`WebFetch(raw.githubusercontent.com)`

**Permanently denied:**
`Bash(rm -rf *)`, `Bash(git push --force *)`, `Read(.env)`, `Read(.env.*)`,
`Read(secrets/**)`

Projects override via their own `.claude/settings.json` — the global config
sets the floor, not the ceiling.

---

## MCP Servers

| Server | Source | Notes |
|---|---|---|
| `github` | `@modelcontextprotocol/server-github` | Requires `GITHUB_TOKEN` env var |
| `google-drive` | `workspace-mcp` | Requires OAuth env vars |
| `supabase` | `supabase-mcp-server` | Disabled globally; enable per-project |
| `playwright` | `@anthropic-ai/mcp-server-playwright` | Disabled globally; enable per-project |

No credentials in config files. All secrets via environment variables only.

---

## Getting Started

**Prerequisites:** Claude Code 2.1.0+, Node.js 18+

```bash
# Back up your existing config first
cp -r ~/.claude ~/.claude.bak

# Clone
git clone https://github.com/yourusername/dotclaude.git
cd dotclaude

# Copy files — selective merge recommended over wholesale overwrite
cp CLAUDE.md ~/.claude/CLAUDE.md
cp settings.json ~/.claude/settings.json    # Review first — your hooks will differ
cp mcp.json ~/.claude/mcp.json             # Add your own servers
cp -r agents/* ~/.claude/agents/
cp -r commands/* ~/.claude/commands/
cp -r skills/* ~/.claude/skills/
```

> **Note:** `settings.json` contains absolute paths in the hook commands
> (pointing to my machine). You'll need to update these for your environment,
> or install [context-mode](https://github.com/mksglu/context-mode) via the
> Claude Code plugin system.

### Installing Plugins

The following plugin marketplaces are referenced in `settings.json`:

```bash
# Install via Claude Code's plugin system
# Add to settings.json > extraKnownMarketplaces, then enable in enabledPlugins
```

| Plugin | Marketplace Repo | What It Adds |
|---|---|---|
| `everything-claude-code` | `affaan-m/everything-claude-code` | 100+ agents, skills, patterns |
| `context-mode` | `mksglu/context-mode` | Context window protection |
| `prompt-improver` | `severity1/severity1-marketplace` | Prompt evaluation hooks |
| `ui-ux-pro-max` | `nextlevelbuilder/ui-ux-pro-max-skill` | UI design intelligence |

---

## How to Adapt This

**Swap the model defaults** — edit `model:` in any agent frontmatter. Haiku
for cheap review passes, Opus for critical planning.

**Override globally-denied commands per-project** — add a project-level
`.claude/settings.json` with a `permissions.allow` that re-opens what you need.

**Add stack-specific agents** — copy `debugger.md` to your project's
`.claude/agents/debugger.md` and change the Bash tool rules from
`npm test *` to your runner (`pytest *`, `go test ./...`, etc.).

**Trim the commands** — most users only need 4-5 commands regularly. The rest
are there because they proved useful at least once. Delete what you don't use.

---

## Attribution

I assembled this from the open-source community. I wrote the integration
logic, the CLAUDE.md philosophy, and adapted components for my use cases.
Everything else has a source:

| Component | Source | Author |
|---|---|---|
| Plugin marketplace system | [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | [@affaan-m](https://github.com/affaan-m) |
| Context window protection | [context-mode](https://github.com/mksglu/context-mode) | [@mksglu](https://github.com/mksglu) |
| UI/UX skill system | [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | [@nextlevelbuilder](https://github.com/nextlevelbuilder) |
| Prompt evaluation hooks | [severity1-marketplace](https://github.com/severity1/severity1-marketplace) | [@severity1](https://github.com/severity1) |
| Continuous learning system | [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | [@affaan-m](https://github.com/affaan-m) |
| Structural inspiration | [beads](https://github.com/steveyegge/beads) | [@steveyegge](https://github.com/steveyegge) |
| Agent workflow patterns | [wshobson/agents](https://github.com/wshobson/agents) | [@wshobson](https://github.com/wshobson) |

If something in here looks familiar and isn't credited, open an issue — I want
to get this right.

---

## Contributing

This is a living configuration. If you've found a better way to handle
something that's already here — a leaner agent, a tighter permission model,
a hook pattern that works more reliably — PRs are welcome.

What I'm not looking for:
- Generic agents that could apply to anything
- Skills that duplicate what's already in everything-claude-code
- Commands that would be better as a one-line alias

What I am looking for:
- Evidence-backed changes (show me what it replaced and why it's better)
- Attribution for anything borrowed
- Lean additions that earn their tokens

---

## License

MIT — see [LICENSE](LICENSE)
