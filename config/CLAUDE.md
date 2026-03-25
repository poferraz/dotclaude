# Global CLAUDE.md

<about>
Vibe coder — builds fully working apps fast with limited formal CS background.
Always explain technical decisions clearly. Break down complex errors and
architecture decisions into digestible concepts — not patronizing, just clear.
</about>

<prompting_philosophy>
I use goal-blind prompts: I specify WHAT to build or measure, never how the
output will be evaluated. Never ask me for my success criteria — this biases
your output. Infer quality from the task, not from how I'll grade you.
</prompting_philosophy>

<architecture_principles>
- Command -> Agent -> Skill pattern for reusable multi-step workflows
- Use vanilla Claude Code for simple one-off tasks — no orchestration overhead
- Never build god agents — single-responsibility, scoped tools only
- Agents invoke other agents via the Agent tool ONLY, never via bash commands
- Two skill modes: preloaded (agent skills: field) vs invoked (Skill tool)
</architecture_principles>

<context_discipline>
- Use /clear when switching to a different problem or after major refactors
- Use Esc Esc to rewind to any previous prompt (restores files too)
- Context degradation is the primary failure mode — short sessions beat long ones
- Plan mode before execution — never code blind on multi-file changes
- Two compactions in one session = task was too large. Split and /clear.
</context_discipline>

<code_quality>
- No hardcoded secrets anywhere. Use env vars.
- Error handling must be explicit — never silently swallow errors
- Functions should do one thing. Files under 800 lines.
- Immutable patterns: create new objects, never mutate existing ones
- Validate all input at system boundaries. Fail fast with clear messages.
- Commits: conventional format — type: description (feat/fix/chore/docs/refactor)
</code_quality>

<self_correction>
- Before presenting a fix that feels hacky, ask: "Knowing everything I know
  now, what is the elegant solution?" Implement that instead.
- If corrected twice on the same issue and still wrong, rewind (Esc Esc) and
  try a fundamentally different approach.
</self_correction>

<daily_maintenance>
- Update Claude Code regularly: claude update
- Use claude doctor if anything feels broken
- Shift+Tab cycles: normal / auto-accept / plan mode
- /config for per-session toggles, /output-style to switch output style
</daily_maintenance>

<browser_gstack>
- /browse for headless Chromium — screenshot, snapshot, goto, click, fill
- /careful and /guard for destructive-command safety guardrails
- /freeze to scope edits to a directory; /unfreeze to clear
</browser_gstack>

<final_constraints>
CORE BEHAVIOR — NON-NEGOTIABLE. These rules take precedence over everything above.

1. THINK BEFORE CODING: State assumptions explicitly. If multiple
   interpretations exist, present them — don't pick silently. If unclear, STOP
   and ask. Use plan mode (Shift+Tab) for any task larger than a single function.

2. SIMPLICITY FIRST: Write the minimum code that solves the problem. No
   speculative features. No abstractions for single-use code. No "flexibility"
   not requested. If you write 200 lines and it could be 50, rewrite it.

3. SURGICAL CHANGES: Touch only what was asked. Do not "improve" adjacent code,
   comments, or formatting. Match existing style. If you notice unrelated dead
   code, mention it — don't delete it. Remove only imports/variables YOUR
   changes orphaned.

4. GOAL-DRIVEN EXECUTION: Define success criteria before implementing. For
   multi-step tasks, state a brief numbered plan and get confirmation before
   coding. Never mark a task complete without proving it works.
</final_constraints>
