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

## Paper 3: Asymmetric Persona Calibration

**"Revisiting Role-Play Prompting: A Systematic Assessment of Persona Calibration in LLMs"**
Hu et al. (2026)
[arxiv.org/abs/2603.18507](https://arxiv.org/abs/2603.18507)

### What They Measured

The authors tested whether giving an LLM a persona ("You are an expert security auditor") helps or hurts performance across different task types. They systematically evaluated persona strategies across reasoning tasks, writing tasks, and safety-sensitive tasks.

### Key Findings

| Task type | Persona effect | Optimal strategy |
|-----------|---------------|-----------------|
| Pretraining tasks (code logic, debugging) | **Hurts accuracy** | None — empty body |
| Alignment tasks (style, format, tone) | **Helps quality** | Short (1–2 sentences) |
| Safety tasks (security analysis, threat modeling) | **+17.7% refusal rate** | Full (50+ word persona) |
| Mixed tasks (planning, multi-step reasoning) | Neutral to slight negative | Minimum (behavioral constraint only) |

The mechanism: for tasks where the model learned the skill during pretraining (coding, math, debugging), a persona redirects attention toward the persona narrative and away from the problem. For tasks that require behavioral calibration (tone, safety thresholds), a persona acts as an effective prior.

### How This Config Applies It

Every agent's system prompt body is calibrated by task type:

**PRETRAINING agents (code-reviewer, debugger, refactorer, tdd-guide) — body is empty or a single behavioral constraint:**
```
# code-reviewer: empty body
# debugger: "Output diagnosis and proposed fix only. Never implement."
```

**ALIGNMENT agents (doc-updater, ui-designer) — 1–2 sentence persona:**
```
# doc-updater: "You write documentation that matches the existing project's tone..."
# ui-designer: "You are a senior UI/UX designer who prioritizes accessibility..."
```

**SAFETY agents (security-reviewer) — full 50-word persona:**
```
# security-reviewer: "You are a meticulous security auditor specialized in OWASP Top 10,
# STRIDE threat modeling, secrets exposure, auth gaps, and injection risks. Evaluate
# both explicit content and implicit intent. Apply principled judgment, not keyword
# filtering. Output severity-ranked findings with concrete exploit scenarios."
```

**MIXED agents (planner) — behavioral constraint only:**
```
# planner: "Produce phase-gated plans with acceptance criteria.
# Require user confirmation before implementation begins."
```

**Decision:** The same agent system prompt that "sounds helpful" (long, encouraging, detailed) actively degrades code task performance. The code-reviewer has an empty body for the same reason CLAUDE.md stays under 30 lines: the model already knows how to review code. Adding a persona doesn't improve that — it adds noise.

---

## Paper 4: Instruction Hierarchy Failure and Recency Bias

**"Control Illusion: Understanding and Addressing LLM Instruction Hierarchy Failure"**
Geng, J., et al. (2025)
[arxiv.org/abs/2502.15851](https://arxiv.org/abs/2502.15851)

### What They Measured

The authors investigated whether LLMs reliably follow a hierarchy of instructions — i.e., whether system-level rules (like a CLAUDE.md) actually take precedence over user-level requests when they conflict. They designed controlled conflict scenarios and measured obedience rates across priority tiers.

### Key Findings

| Finding | Result |
|---------|--------|
| Instruction obedience under cross-tier conflict | **9.6%** — near-random |
| Most effective compliance mechanism | **Recency bias** (position in context) |
| "IMPORTANT" / "NON-NEGOTIABLE" labels | Minimal effect vs. no label |
| Rules placed at end of context | Highest compliance rate |

The mechanism: LLMs do not have a robust learned hierarchy for "system > user > human" in the way the spec implies. What actually drives compliance is **recency** — the model's attention weights are highest at the end of the context window. A rule stated at position 1000 will be followed more reliably than the same rule at position 100, regardless of labels.

This finding is sometimes called the "control illusion" — operators believe their system instructions govern behavior, but positional effects can override them.

### How This Config Applies It

**Decision 1: `<final_constraints>` block at the bottom of CLAUDE.md.**
The four non-negotiable core behaviors (THINK BEFORE CODING, SIMPLICITY FIRST, SURGICAL CHANGES, GOAL-DRIVEN EXECUTION) are placed at the absolute end of the file, inside a named XML block. This is a direct application of the recency finding: these rules earn their position, not just their label.

**Decision 2: XML demarcation.**
Geng et al. found that structural delimiters improve rule salience. XML tags create a cognitive and tokenization boundary that `##` headers do not. The entire CLAUDE.md was converted from Markdown headers to XML blocks to maximize structural clarity.

**Decision 3: Sections ordered by criticality (ascending).**
Context earlier in the file (About Me, Architecture) is informational. The most important behavioral rules are closest to the end. The model reads the whole file, but the recency anchor is reserved for constraints that must not be overridden.

---

## Paper 5: LLM Code Smells in Agentic Systems

**"LLM Code Smells: Identifying and Addressing Anti-Patterns in Agentic AI Systems"**
Mahmoudi, H., et al. (2025)
[arxiv.org/abs/2512.18020](https://arxiv.org/abs/2512.18020)

### What They Measured

The authors analyzed failure patterns in LLM-based agent systems — not failures from bad models, but architectural and prompting patterns that reliably produce bad outputs. They catalogued these as "code smells" by analogy to software engineering: patterns that aren't necessarily broken, but that reliably lead to problems at scale.

### Key Findings

| Smell | Failure Rate | Description |
|-------|------------|-------------|
| Non-Specific Output (NSO) | **40.5%** of failures | Agent returns free-form prose where a schema was required |
| Undefined Model Multiplexing (UMM) | 22.1% | Multiple agents use different models without clear routing logic |
| Missing Retry Logic | 18.3% | No fallback when tool calls fail or return unexpected structure |
| Context Window Overflow | 12.4% | Agent context grows unbounded, degrading later responses |

**NSO** is the dominant failure mode. It occurs when an agent is told to "report your findings" without a strict schema — and produces narrative prose that the calling system cannot parse or validate. The downstream agent that expected `<result>pass</result>` gets "I reviewed the code and it looks mostly good, though there are a few things worth noting..."

**UMM** matters because different models have different output styles. Routing code review to Haiku and security review to Opus without explicit schema enforcement amplifies NSO — each model produces differently-structured prose.

### How This Config Applies It

**Decision 1: Strict Output Schema section in every skill.**
All 5 first-party skills (`coding-standards`, `verification-loop`, `tdd-workflow`, `strategic-compact`, `continuous-learning-v2`) now include a mandatory "Strict Output Schema" section. Each schema uses XML tags — `<tool_output>`, `<verdict>`, `<report>` — that can be parsed programmatically. Free-form prose is named as a failure mode in the skill itself.

**Decision 2: Schema tied to the NSO finding by citation.**
Each schema section explicitly cites Mahmoudi et al. (2025). This serves two purposes: it prevents future editors from removing the schema thinking it's bureaucratic overhead, and it embeds the rationale where it's most actionable.

**Decision 3: Minimal schemas, not comprehensive ones.**
The schemas are deliberately narrow — only the fields that matter for downstream parsing. The Gloaguen finding (Paper 1) warns against bloated context files. A 20-line output schema that covers the critical fields beats a 200-line schema that covers everything.

---

## What's Not Here

Several papers influenced the general philosophy but didn't produce specific, implementable decisions:

- **LLM attention and context window utilization** — General research on how attention dilutes over long contexts. Informed the "tokens must earn their place" principle but didn't produce specific config decisions.
- **Anthropic's system prompt guidance** — Internal documentation on effective system prompts. Consistent with the Gloaguen findings but not a citable paper.

If you find research that should inform a specific config decision, open a [research update issue](../.github/ISSUE_TEMPLATE/research_update.md) and include confidence level and implementation recommendation.
