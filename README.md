# dotclaude

<p align="center">
  <img src="assets/header.jpg" alt="dotclaude — You Need This" width="600">
</p>

**A research-backed global environment for Claude Code**

[![Website](https://img.shields.io/badge/Website-dotclaude--setup.vercel.app-000000?logo=vercel)](https://dotclaude-setup.vercel.app/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-2.1.0%2B-blue)](https://claude.ai/code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

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
actual problem. Research now confirms what practitioners suspected: more
context is not better context.

Most "awesome Claude Code" setups operate in the opposite direction — they add
everything. Mega-agents with 20 tools. Skills with 500 lines of generic advice.
Commands for every conceivable workflow. The result is a system that impresses
in screenshots and degrades in daily use.

This configuration was born from real work: retail management tooling, PWA
development, bakery production planning. Not theoretical best practices. It was
audited, stripped down, rebuilt leaner, and audited again. The agents you see
here survived because they provably helped. The ones that didn't are gone.

---

## What's Inside

```
~/.claude/
├── CLAUDE.md              # Global context (under 30 lines, research-optimized)
├── agents/                # 8 single-purpose agents with 1-sentence instructions
├── skills/                # 6 skills + gstack browser (5 on-demand, 1 agent-preloaded)
├── commands/              # 15 slash commands (/new-project, /tdd, /plan, etc.)
└── settings.json          # Hooks, permissions, plugin config
```

**Command → Agent → Skill.** A command (`/plan`) launches a scoped subagent
(`planner`) that optionally loads a knowledge pack (`tdd-workflow`) via its
`skills:` frontmatter. Agents invoke other agents via the Agent tool — never
via bash. Skills are knowledge, not code: they load context, not behavior.

---

## Quick Start

> **Guided setup:** [dotclaude-setup.vercel.app](https://dotclaude-setup.vercel.app/) walks you through installation interactively.

```bash
# 1. Clone
git clone https://github.com/poferraz/dotclaude.git
cd dotclaude

# 2. Run the install script
#    (backs up your existing ~/.claude/ automatically)
bash scripts/install.sh

# 3. Merge settings manually
#    Review config/settings.json and add hook/plugin config to ~/.claude/settings.json
#    (the script will tell you exactly what to do)

# 4. Verify
claude --version
claude doctor
```

> The install script backs up your existing `~/.claude/` before touching anything,
> copies config files, and prints next steps for plugin installation.
> It does not transmit any data. See [SECURITY.md](SECURITY.md).

---

## The Research Behind It

### Context files can hurt you (Gloaguen et al., 2026)

**Paper:** ["Evaluating AGENTS.md: Are Repository-Level Context Files Helpful?"](https://arxiv.org/abs/2602.11988)

Key findings:
- LLM-generated context files **reduced task success in 5 of 8 settings**
- Increased API cost by **20–23%**
- Increased reasoning tokens by **14–22%**
- Human-written files performed better, but only when they contained
  *non-obvious* requirements the agent couldn't discover itself

**How this repo applies it:** `CLAUDE.md` is under 30 lines and contains only
behavioral principles that override default model behavior. No framework
boilerplate. No re-teaching what the model already knows. No comprehensive
style guides the model could infer from the codebase.

### Goal-blind prompting (Cao, Jiang, Xu, 2026)

**Paper:** ["Seeing the Goal, Missing the Truth"](https://arxiv.org/abs/2602.09504)

Key finding: Telling an LLM how its output will be evaluated causes it to
reshape outputs to game the metric, degrading out-of-sample performance.

**How this repo applies it:** The prompting philosophy in `CLAUDE.md` is
goal-blind by design — specify WHAT to build, never HOW it will be evaluated.
Never ask for success criteria. Infer quality from the task.

### Instruction hierarchy failure and recency bias (Geng et al., 2025)

**Paper:** ["Control Illusion: Understanding and Addressing LLM Instruction Hierarchy Failure"](https://arxiv.org/abs/2502.15851)

Key findings:
- LLM instruction obedience drops to **9.6%** under cross-tier conflict
- **Recency bias** is the strongest compliance driver — position in context
  matters more than explicit priority markers
- Critical rules placed at the END of context yield highest compliance

**How this repo applies it:** `CLAUDE.md` uses XML blocks (`<final_constraints>`)
with non-negotiable rules positioned at the **absolute bottom** of the file.
The recency anchor outperforms "NON-NEGOTIABLE" labels placed mid-document.

### LLM agent code smells and NSO mitigation (Mahmoudi et al., 2025)

**Paper:** ["LLM Code Smells in Agentic Systems"](https://arxiv.org/abs/2512.18020)

Key findings:
- **40.5%** of agent system failures are caused by Non-Specific Output (NSO)
- NSO = agent returns free-form prose where a structured schema was expected
- XML tag wrapping significantly reduces NSO failure rates for Claude

**How this repo applies it:** Every skill in `~/.claude/skills/` includes a
"Strict Output Schema" section with mandatory XML tags. Agents that invoke
these skills must wrap their outputs — free-form prose is treated as a bug,
not a style choice.

### Asymmetric persona calibration (Hu et al., 2026)

**Paper:** ["Revisiting Role-Play Prompting: A Systematic Assessment of Persona Calibration in LLMs"](https://arxiv.org/abs/2603.18507)

Key finding: Persona effects are **asymmetric by task type**. For code tasks
(pretraining), personas hurt accuracy. For style/tone tasks (alignment),
personas help. For safety analysis, a full auditor persona raises refusal rate
by +17.7%. Generic "helpful expert" personas on debugging tasks degrade output
by directing attention to the persona narrative instead of the problem.

**How this repo applies it:** All 8 agents use task-typed system prompts. Code
agents (`code-reviewer`, `debugger`, `refactorer`, `tdd-guide`) have empty
bodies or single behavioral constraints — no personas. Safety agents
(`security-reviewer`) have full 50+ word auditor personas. Style agents
(`doc-updater`, `ui-designer`) have 1–2 sentence personas. The planner uses
a behavioral constraint only. See [`docs/architecture.md`](docs/architecture.md)
for the full classification table.

---

## Built On The Shoulders Of Giants

| Project | What I Used | Credit |
|---------|-------------|--------|
| [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Agents, skills, hooks, commands, rules, and the plugin architecture. The foundation this setup started from. | @affaan-m |
| [gstack](https://github.com/garrytan/gstack) | Persistent headless Chromium browser daemon for QA and dogfooding. `/browse`, `/careful`, `/freeze`, `/guard`, `/unfreeze`. | @garrytan |
| [claude-code-prompt-improver](https://github.com/severity1/claude-code-prompt-improver) | Prompt evaluation plugin that intercepts vague prompts before execution | @severity1 |
| [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | Reference patterns for Claude Code workflows and conventions | @shanraisshan |
| [context-mode](https://github.com/thedotmack) | Session memory and observation system (context-mode plugin) | @thedotmack |
| [beads](https://github.com/steveyegge/beads) | Structured task tracking for coding agents. Recommended as the on-demand memory layer. | @steveyegge |
| [stop-slop](https://github.com/hardikpandya/stop-slop) | Writing quality patterns adapted for skill output | @hardikpandya |
| [AGENTS.md spec](https://agents.md) | The open standard for guiding coding agents | AGENTS.md community |
| [Anthropic Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) | Official documentation for CLAUDE.md, hooks, agents, skills, commands | Anthropic |

This repository is an assembly, not an invention. Every tool, pattern, and
architecture decision traces back to the work of the developers and researchers
listed above. I built this by installing their tools, testing them on real
projects, reading the research, and cutting everything that didn't earn its
place. If you find this useful, **star THEIR repos first.**

---

## Philosophy

- **Every token in your context window should earn its place.** If a rule
  describes behavior Claude would exhibit anyway from training, delete it.
- **Trust the model's training — don't re-teach it what it already knows.**
  A 30-line CLAUDE.md that overrides defaults beats a 300-line one that
  restates them.
- **On-demand over auto-loaded, always.** Skills and context that load only
  when invoked don't cost tokens on unrelated tasks.

---

## Agents

| Agent | Purpose | Model |
|-------|---------|-------|
| `code-reviewer` | Review changes via `git diff` — SOLID, security, YAGNI violations | sonnet |
| `debugger` | Trace bugs to root cause and propose minimal fix. Never implements. | sonnet |
| `doc-updater` | Sync documentation after public API or interface changes | sonnet |
| `planner` | Phase-wise gated plans with deliverables and acceptance criteria | opus |
| `refactorer` | Structural cleanup without behavior change. Requires tests before and after. | sonnet |
| `security-reviewer` | Injection, auth gaps, secrets exposure, data validation | sonnet |
| `tdd-guide` | Enforce RED→GREEN→IMPROVE. Report coverage delta each cycle. | sonnet |
| `ui-designer` | 2026-style React/Tailwind components with preloaded design system | sonnet |

All agents: single responsibility, scoped tool list, one-sentence system prompt.
The planner uses Opus because planning quality compounds across the entire task.

---

## Skills

| Skill | Purpose | Loading |
|-------|---------|---------|
| `coding-standards` | Language-agnostic quality rules: naming, structure, error handling, immutability | On-demand |
| `continuous-learning-v2` | Instinct-based learning from session patterns | On-demand |
| `strategic-compact` | Context compaction triggers at logical session intervals | On-demand |
| `tdd-workflow` | TDD methodology reference loaded by the `tdd-guide` agent | **Agent-preloaded** |
| `ui-ux-pro-max` | 67 styles, 96 palettes, 57 font pairings — loaded by `ui-designer` | On-demand |
| `verification-loop` | Systematic verification checklist after multi-step changes | On-demand |

5 of 6 skills are on-demand by design. Only `tdd-workflow` is preloaded — and
only by the agent that needs it, not at session start.

---

## Commands

| Command | Purpose |
|---------|---------|
| `/audit-repo` | Full GitHub repository audit |
| `/build-fix` | Triage and resolve build errors |
| `/checkpoint` | Save session state before risky operations |
| `/code-review` | Trigger the `code-reviewer` agent on current changes |
| `/evolve` | Analyze learned instincts and suggest refinements |
| `/full-review` | Multi-agent comprehensive review (code + security + docs) |
| `/full-stack-feature` | Orchestrate end-to-end feature implementation |
| `/instinct-status` | Show learned patterns with confidence scores |
| `/learn` | Extract reusable patterns from the current session |
| `/new-project` | Bootstrap a new project with minimal Claude Code config |
| `/plan` | Restate requirements and build a gated implementation plan |
| `/pr-enhance` | Improve PR quality and generate structured description |
| `/second-opinion` | Run `claude -p` on the current diff for a focused second-AI review |
| `/tdd` | Enforce TDD methodology throughout a feature |
| `/verify` | Run verification loop after completing a change |

---

## Customization

**Different stack?** Copy any agent to your project's `.claude/agents/` and
update the Bash tool rules. The `debugger` defaults to `npm test` — change it
to `pytest *`, `go test ./...`, or whatever your runner is.

**Project-level CLAUDE.md?** The `/new-project` command generates one — 5 to
10 lines maximum. The research (Gloaguen et al.) shows that comprehensive
guides don't help. Only include what the agent cannot discover from the code.

**Want fewer agents?** Start with `planner`, `debugger`, and `code-reviewer`.
Add others only when you notice a recurring gap.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

The bar for adding new content is high by design: it must contain non-obvious
information that Claude cannot discover from its training or existing repo
files. Generic advice doesn't clear the bar. Evidence does.

---

## License

MIT — see [LICENSE](LICENSE)
