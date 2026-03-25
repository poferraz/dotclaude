# Context Budget

How this setup keeps session start lean, and why it matters.

---

## Why Context Budget Matters

Claude Code's context window is 200K tokens. That sounds like a lot — until you realize that a single bloated CLAUDE.md plus auto-loaded agents, skills, and hook output can burn 20,000+ tokens before you type your first prompt. That's 10% of your budget gone on configuration overhead.

The Gloaguen et al. (2026) research confirms the cost isn't just tokens: redundant context actively reduces task success. More isn't better. More is worse.

**Target for this setup:** Under 3,000 tokens of config overhead at session start. That's less than 1.5% of the 200K window.

---

## Session Start Token Budget

What loads before you type anything:

| Source | Tokens | Controllable? |
|--------|--------|---------------|
| Claude Code system prompt | ~8,000 | No |
| `CLAUDE.md` (global) | ~450 | Yes — keep minimal |
| context-mode session index | ~1,500–3,000 | Yes — compressed |
| Hook output (SessionStart) | ~200 | Yes — kept terse |
| **Config contribution total** | **~2,150–3,650** | **Yes** |
| **Grand total at session start** | **~10,150–11,650** | Partially |

The Claude Code system prompt (~8,000 tokens) is fixed infrastructure. Everything else is controlled by this configuration.

---

## The Previous State (Before Audit)

Before the March 2026 audit and rebuild, the session start budget looked like this:

| Source | Tokens | Status |
|--------|--------|--------|
| CLAUDE.md (102 lines) | ~850 | ✅ Replaced with 71-line version |
| Auto-loaded god agents (12 agents, all sessions) | ~6,200 | ✅ Reduced to 8 on-demand agents |
| context-mode injection (uncompressed) | ~20,000 | ✅ Replaced with compressed index |
| Stack-specific rules (golang, etc.) | ~1,200 | ✅ Moved to project-level |
| Skills auto-loaded via CLAUDE.md @imports | ~3,500 | ✅ Moved to on-demand |
| **Previous total overhead** | **~31,750+** | **Replaced** |

The context-mode injection was the largest single problem: 20,000 tokens of raw session history injected into every turn. Switching to the compressed semantic index (titles, types, token counts — not full content) dropped this to ~1,500–3,000 tokens while preserving recall through on-demand MCP search.

---

## Per-Turn Hook Overhead

Every tool call runs the PostToolUse hook (context-mode observation capture). This is low but not zero:

| Hook event | Overhead | Frequency |
|-----------|---------|-----------|
| PostToolUse observation | ~50–100 tokens | Every tool call |
| UserPromptSubmit session-init | ~30 tokens | Every prompt |
| Stop summarize | ~200 tokens | End of session |

For a typical 50-tool-call session, hook overhead is roughly 2,500–5,000 tokens. This is acceptable because the observation data is what enables the compressed context-mode index — it's an investment in future session efficiency.

---

## What the Audit Removed

The March 2026 audit removed or relocated:

| Removed | Tokens saved | Reason |
|---------|-------------|--------|
| 4 god agents (architect-review, security-review, test-runner, orchestrator) | ~4,800 | Replaced by 8 focused agents; god agents loaded for every task |
| eval-harness skill (auto-loaded) | ~1,400 | Moved to project-level; not globally relevant |
| security-review skill (auto-loaded) | ~900 | Merged into security-reviewer agent prompt |
| coding-standards from CLAUDE.md @import | ~320 | Moved to on-demand skill |
| Stack-specific rules (golang/coding-style.md) | ~1,200 | Moved to project-level |
| PAULO_CONTEXT.md briefing doc | ~1,100 | Stale, deleted |
| 875 lines across god agent definitions | ~3,000 | Replaced with lean single-sentence versions |
| **Total removed** | **~12,720** | |

---

## Monitoring Your Own Budget

To see what's loading in your sessions:

```bash
# Check CLAUDE.md size
wc -w ~/.claude/CLAUDE.md

# Check agent sizes
wc -w ~/.claude/agents/*.md | sort -n

# Check if any skills are auto-loading via CLAUDE.md
grep -n "@import\|skills:" ~/.claude/CLAUDE.md

# Check context-mode session index size
# (visible in session start hook output)
```

**Red flags:**
- CLAUDE.md over 50 lines: audit for obvious/redundant content
- Any agent over 200 lines: split into agent + skill
- Any skill auto-loading via CLAUDE.md @import: move to on-demand
- context-mode injection over 5,000 tokens: check compression settings

---

## The Minimum Viable Config

If you want to start even leaner:

| Keep | Remove |
|------|--------|
| CLAUDE.md (behavioral overrides only) | All auto-loaded agents and skills |
| settings.json (permissions + hooks) | context-mode until you need it |
| planner + debugger + code-reviewer | Other 5 agents until needed |
| /plan and /verify | Other 12 commands until needed |

Add components only when you notice a recurring gap. The minimum viable config is ~2,000 tokens at session start. Everything above that is optional functionality.
