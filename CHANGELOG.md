# Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

---

## [1.0.0] — 2026-03-24

### Added

**Core configuration**
- `CLAUDE.md` — global behavioral principles (under 30 lines, research-optimized)
- `settings.json` — hardened permission model, lifecycle hooks, plugin registry
- `mcp.json` — GitHub and Google Drive MCP servers (env-var credentials only)

**Agents (8 total)**
- `code-reviewer` — SOLID/security/YAGNI review via `git diff`
- `debugger` — root-cause diagnosis, never implements
- `doc-updater` — sync docs after API/interface changes
- `planner` — phase-wise gated plans with acceptance criteria (Opus)
- `refactorer` — structural cleanup with test-passing gates
- `security-reviewer` — injection, auth, secrets, data validation
- `tdd-guide` — RED→GREEN→IMPROVE with coverage delta reporting
- `ui-designer` — 2026-style React/Tailwind with preloaded design system

**Skills (6 total, 5 on-demand)**
- `coding-standards` — language-agnostic quality rules
- `continuous-learning-v2` — instinct-based session pattern learning
- `strategic-compact` — context compaction at logical intervals
- `tdd-workflow` — TDD methodology (agent-preloaded by `tdd-guide`)
- `ui-ux-pro-max` — 67 styles, 96 palettes, 57 font pairings
- `verification-loop` — systematic post-change verification

**Commands (14 total)**
- `/audit-repo`, `/build-fix`, `/checkpoint`, `/code-review`, `/evolve`
- `/full-review`, `/full-stack-feature`, `/instinct-status`, `/learn`
- `/new-project`, `/plan`, `/pr-enhance`, `/tdd`, `/verify`

**Plugins enabled**
- `everything-claude-code` (affaan-m) — extended agent and skill library
- `context-mode` (thedotmack) — session memory and context protection
- `prompt-improver` (severity1) — prompt evaluation on UserPromptSubmit
- `ui-ux-pro-max` (nextlevelbuilder) — UI design intelligence

**Repository**
- Full attribution table in README
- Research citations: Gloaguen et al. (2026), Cao et al. (2026)
- CONTRIBUTING.md with explicit content bar
- SECURITY.md
- GitHub issue templates and PR template
