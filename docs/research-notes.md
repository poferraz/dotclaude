# Research Notes

The two papers that directly shaped this configuration, and how.

---

## Paper 1: Context Files Can Hurt You

**"Evaluating AGENTS.md: Are Repository-Level Context Files Helpful?"**
Gloaguen, Büyükkaya, Hajdu, et al. (2026)
[arxiv.org/abs/2602.11988](https://arxiv.org/abs/2602.11988)

### What They Measured

The authors evaluated whether AGENTS.md / CLAUDE.md files — the markdown context files that Claude Code and similar tools load at session start — actually help coding agents perform better. They tested across 8 diverse coding tasks with multiple agent systems.

### Key Findings

| Finding | Magnitude |
|---------|-----------|
| LLM-generated context files reduced success | 5 of 8 settings |
| Increased API cost | 20–23% |
| Increased reasoning tokens | 14–22% |
| Human-written files | Mixed — helped only when containing non-obvious requirements |

The critical distinction: **files containing information the agent couldn't discover on its own** (environment-specific constraints, non-obvious project conventions, required tool availability) showed positive signal. Files containing generic best practices, obvious conventions, or re-stated framework defaults showed negative or neutral signal.

### How This Config Applies It

**Decision 1: CLAUDE.md is under 30 lines.**
Every line in CLAUDE.md was evaluated against the question: "Would Claude apply this behavior without being told?" If yes, it was removed. What remains are genuine overrides — behaviors that contradict defaults or require explicit setup (goal-blind prompting, surgical changes, context discipline triggers).

**Decision 2: Skills are on-demand, not auto-loaded.**
5 of 6 skills load only when invoked. The `tdd-workflow` skill (400+ lines of TDD methodology) only loads when the `tdd-guide` agent runs. It costs zero tokens in sessions where you're writing documentation, fixing a bug, or planning architecture. Auto-loading it would waste 2,600 tokens every session for tasks where TDD doesn't apply.

**Decision 3: Agent instructions are single sentences.**
The `debugger` agent system prompt is: *"Never guess. Trace the error to its origin. Show the chain of causation. Propose the minimal surgical fix."* That's it. The agent's training already covers debugging methodology. The one-sentence prompt overrides only the behavior that would otherwise be different: no guessing, no implementing, only diagnosing.

**Decision 4: Project CLAUDE.md files are 5–10 lines maximum.**
The `/new-project` command generates a minimal project-level CLAUDE.md. The research shows that comprehensive guides don't help — only requirements the agent cannot discover from the codebase itself.

---

## Paper 2: Goal-Blind Prompting

**"Seeing the Goal, Missing the Truth"**
Cao, Jiang, Xu (2026)

### What They Measured

The authors studied what happens when you tell a model how its output will be evaluated — i.e., revealing the scoring criteria or success metrics before the model produces its response.

### Key Finding

When a model knows the evaluation criteria, it reshapes its output to score well on that criterion — at the expense of out-of-sample performance. The model games the metric rather than solving the problem. This is analogous to Goodhart's Law: *when a measure becomes a target, it ceases to be a good measure.*

Specifically, they found that telling the model "your response will be evaluated on clarity, accuracy, and conciseness" caused it to optimize for those labeled dimensions while degrading on unmeasured dimensions.

### How This Config Applies It

**The CLAUDE.md prompting philosophy:**

```
I use goal-blind prompts: I specify WHAT to build or measure, never how the
output will be evaluated. Never ask me for my success criteria — this biases
your output. Infer quality from the task, not from how I'll grade you.
```

This is a direct application of the paper's finding. Specifying WHAT to build (the task) gives the model the right signal. Specifying HOW the output will be evaluated (the scoring criteria) causes it to optimize for the metric rather than the outcome.

**In practice:** If you're building an API endpoint, say "build a paginated GET /items endpoint." Don't say "build an API endpoint — I'll evaluate it on REST compliance, error handling, and test coverage." The second framing causes the model to optimize for those named dimensions, potentially at the expense of others (performance, edge cases, documentation).

**Why this is in CLAUDE.md and not just a practice:**
Left to defaults, Claude Code agents often ask for success criteria ("What does a good solution look like to you?"). The CLAUDE.md line explicitly suppresses this behavior — it's a genuine behavioral override, not a general best practice the model would apply anyway. This makes it appropriate for CLAUDE.md under the Gloaguen et al. standard.

---

## What's Not Here

Several papers influenced the general philosophy but didn't produce specific, implementable decisions:

- **LLM attention and context window utilization** — General research on how attention dilutes over long contexts. Informed the "tokens must earn their place" principle but didn't produce specific config decisions.
- **Anthropic's system prompt guidance** — Internal documentation on effective system prompts. Consistent with the Gloaguen findings but not a citable paper.

If you find research that should inform a specific config decision, open a [research update issue](../.github/ISSUE_TEMPLATE/research_update.md) and include confidence level and implementation recommendation.
