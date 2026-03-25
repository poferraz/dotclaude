# Contributing to dotclaude

Thank you for your interest. This is a minimal-by-design configuration — the
bar for adding new content is intentionally high.

## The Standard

Before proposing new context, agents, or skills, ask yourself one question:
**Can Claude figure this out on its own?**

If yes — from its training, from reading the codebase, or from the existing
config — don't add it. The research this repo is built on (Gloaguen et al.,
2026) shows that redundant context actively hurts performance. We are not
trying to teach Claude to code. We are providing the small set of behavioral
overrides and workflow tools it cannot infer.

Every PR that adds tokens to auto-loading files (CLAUDE.md, rules, agent
system prompts) must include a justification with estimated token cost and a
clear answer to why this cannot be inferred.

## What We're Looking For

**Good:**
- A leaner replacement for an existing agent or skill with evidence it performs better
- A research update that changes what should or shouldn't be in CLAUDE.md
- A bug fix (broken hook, incorrect tool permission, wrong model assignment)
- Attribution correction or addition

**Not a fit:**
- Generic agents that could apply to anything (use everything-claude-code instead)
- Skills that duplicate upstream repos
- Commands that would be better as a one-line shell alias
- Style opinions without evidence

## How to Contribute

1. Fork the repo
2. Create a branch: `git checkout -b type/short-description`
3. Make your changes
4. Open a PR using the PR template — the Token Impact section is required

## Commit Format

Conventional commits are required:

```
feat: add X agent for Y purpose
fix: correct tool permission for Z
docs: update attribution for W
chore: update .gitignore
refactor: simplify planner system prompt
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`

## Issue Templates

Use the provided templates in `.github/ISSUE_TEMPLATE/`:

- **Bug report** — something is broken or behaving unexpectedly
- **Feature request** — a new agent, skill, or command you want to propose
- **Research update** — new research that should inform this setup

## Code of Conduct

Be direct and specific. Back claims with evidence. Attribute your sources.
