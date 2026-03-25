# MANIFEST

Every file in `config/` — purpose, source, token cost, and whether it auto-loads.

**Token cost formula:** word count × 1.3 (approximate tokens)
**Auto-loads:** YES = loaded every session. NO = loaded only when invoked.

> Files marked NO are on-demand by design. Loading only what the current task
> needs is the primary mechanism for keeping session start under 3,000 tokens.

---

## config/CLAUDE.md

| Field | Value |
|-------|-------|
| **Purpose** | Global behavioral overrides — principles the model wouldn't apply by default |
| **Source** | Original |
| **Token cost** | ~450 tokens |
| **Auto-loads** | YES — loads every session via Claude Code's hierarchical CLAUDE.md loading |

---

## config/settings.json

| Field | Value |
|-------|-------|
| **Purpose** | Permissions, lifecycle hooks, plugin registry, model defaults |
| **Source** | Original (hooks pattern from context-mode / @thedotmack) |
| **Token cost** | N/A — not injected into context, parsed by Claude Code runtime |
| **Auto-loads** | N/A — system config, not context |

---

## config/agents/

| File | Purpose | Source | Tokens | Auto-loads |
|------|---------|--------|--------|-----------|
| `code-reviewer.md` | Review `git diff` for SOLID/security/YAGNI violations | Original | ~65 | NO |
| `debugger.md` | Root cause trace only — never implements | Original | ~55 | NO |
| `doc-updater.md` | Sync docs after API/interface changes (runs in background, Haiku) | Original | ~50 | NO |
| `planner.md` | Phase-wise gated plans with acceptance criteria (Opus) | Original | ~65 | NO |
| `refactorer.md` | Structural cleanup — tests must pass before and after | Original | ~70 | NO |
| `security-reviewer.md` | Injection, auth gaps, secrets exposure, data validation | Original | ~55 | NO |
| `tdd-guide.md` | RED→GREEN→IMPROVE, 80%+ coverage enforcement | Original (references ECC tdd-workflow skill) | ~60 | NO |
| `ui-designer.md` | 2026-style React/Tailwind with preloaded ui-ux-pro-max | Original (preloads ECC ui-ux-pro-max skill) | ~70 | NO |

**Total agents context cost when all 8 invoked simultaneously:** ~490 tokens

---

## config/skills/

| File | Purpose | Source | Tokens | Auto-loads |
|------|---------|--------|--------|-----------|
| `coding-standards/SKILL.md` | Language-agnostic quality rules: naming, structure, error handling | Original | ~320 | NO |
| `continuous-learning-v2/SKILL.md` | Instinct-based learning from session patterns — observation, confidence scoring | ECC / @affaan-m | ~1,900 | NO |
| `strategic-compact/SKILL.md` | Context compaction decision guide for logical phase boundaries | ECC / @affaan-m | ~480 | NO |
| `strategic-compact/suggest-compact.sh` | Shell hook that triggers compaction suggestion at threshold (default: 50 tool calls) | ECC / @affaan-m | N/A (shell script) | Via hook |
| `tdd-workflow/SKILL.md` | TDD methodology reference: RED→GREEN→IMPROVE, test patterns, coverage | ECC / @affaan-m | ~2,600 | NO (agent-preloaded by tdd-guide) |
| `ui-ux-pro-max/SKILL.md` | 67 styles, 96 palettes, 57 font pairings, 99 UX guidelines | @nextlevelbuilder | ~600 | NO (agent-preloaded by ui-designer) |
| `verification-loop/SKILL.md` | 6-phase verification: build → types → lint → tests → security → diff | ECC / @affaan-m | ~520 | NO |

**Note:** `continuous-learning-v2` and `ui-ux-pro-max` are full plugin packages with scripts and hooks. Only their `SKILL.md` is here. Install the full package via Claude Code's plugin marketplace for hook-based observation and the complete data directory.

---

## config/commands/

| File | Purpose | Source | Tokens | Auto-loads |
|------|---------|--------|--------|-----------|
| `audit-repo.md` | 9-area GitHub repo audit (secrets, structure, CI, community files) | ECC | ~8,600 | NO |
| `build-fix.md` | Incremental build error resolution, one error at a time | ECC | ~320 | NO |
| `checkpoint.md` | Named workflow checkpoints with comparison reporting | ECC | ~260 | NO |
| `code-review.md` | Security + quality review of uncommitted changes | ECC | ~170 | NO |
| `evolve.md` | Cluster instincts into skills/commands, suggest promotions | ECC | ~1,350 | NO |
| `full-review.md` | Multi-agent orchestrated review (code + security + docs) | ECC | ~5,550 | NO |
| `full-stack-feature.md` | End-to-end feature development across backend/frontend/DB/infra | ECC | ~5,600 | NO |
| `instinct-status.md` | Show project + global instincts with confidence bars | ECC | ~170 | NO |
| `learn.md` | Extract reusable patterns from current session | ECC | ~170 | NO |
| `new-project.md` | Bootstrap project `.claude/` structure, CLAUDE.md, MCP config | Original | ~660 | NO |
| `plan.md` | Invoke planner agent — restate requirements, gate on confirmation | Original | ~440 | NO |
| `pr-enhance.md` | PR quality analysis and structured description generation | ECC | ~5,450 | NO |
| `tdd.md` | Invoke tdd-guide agent — scaffold, RED, GREEN, IMPROVE | ECC | ~550 | NO |
| `verify.md` | 6-phase verification report | ECC | ~165 | NO |

**All 14 commands: auto-loads = NO.** They load only when invoked.

---

## Session Start Token Budget

| Source | Tokens | Notes |
|--------|--------|-------|
| `CLAUDE.md` | ~450 | Only non-obvious behavioral overrides |
| Claude Code system prompt | ~8,000 | Fixed, not configurable |
| context-mode session index | ~1,500–3,000 | Compressed semantic index of past sessions |
| Hook overhead (per turn) | ~200 | context-mode observation capture |
| **Total at session start** | **~10,000–12,000** | Well under 10% of 200K context window |

**Target:** Keep the config contribution (CLAUDE.md + hooks) under 3,000 tokens at session start. That's the constraint that keeps this setup lean.

---

## What's Not Here

| Excluded | Reason |
|----------|--------|
| `settings.local.json` | Machine-specific, may contain personal permissions |
| `memory/` | Personal auto-memory, per-user by definition |
| `sessions/` | Session logs, ephemeral |
| `homunculus/` | Instinct runtime data, per-machine |
| Plugin source code | Separate projects with their own licenses — install via marketplace |
| `rules/` | No global rules directory in this setup — rules live in `CLAUDE.md` or per-project |
