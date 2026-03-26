# dotclaude Source Verification Report
Date: Wednesday, March 25, 2026

## Research Papers

### Evaluating AGENTS.md: Are Repository-Level Context Files Helpful?
- Repo states — authors: Gloaguen et al. | Source shows — authors: Thibaud Gloaguen, Niels Mündler, Mark Müller, Veselin Raychev, Martin Vechev
- Repo states — title: Evaluating AGENTS.md: Are Repository-Level Context Files Helpful? | Source shows — title: Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?
- Repo states — year: 2026 | Source shows — year: 2026
- Repo states — arxiv: https://arxiv.org/abs/2602.11988 | Status: resolves to this paper
- Numerical claims:
  | Claim in repo | Value in source | Location in source | Match? |
  |---|---|---|---|
  | Increased API cost by 20–23% | inference cost by over 20% | Abstract | Approximate match |
  | Increased reasoning tokens by 14–22% | Not extracted in summary snippet | - | Not found |
- Qualitative claims:
  | Claim in repo | Statement in source | Difference in scope/strength |
  |---|---|---|
  | LLM-generated context files reduced task success in 5 of 8 settings | Context files tend to reduce task success rates compared to providing no repository context | Source speaks generally; repo specifies "5 of 8 settings" |
  | Human-written files performed better, but only when they contained non-obvious requirements the agent couldn't discover itself | Human-written context files should describe only minimal requirements to be effective | Matches closely in meaning |

### Seeing the Goal, Missing the Truth
- Repo states — authors: Cao, Jiang, Xu | Source shows — authors: Sean Cao, Wei Jiang, Hui Xu
- Repo states — title: Seeing the Goal, Missing the Truth | Source shows — title: Seeing the Goal, Missing the Truth: Human Accountability for AI Bias
- Repo states — year: 2026 | Source shows — year: 2026
- Repo states — arxiv: https://arxiv.org/abs/2602.09504 | Status: resolves to this paper
- Numerical claims:
  | Claim in repo | Value in source | Location in source | Match? |
  |---|---|---|---|
  | None explicitly in snippet | - | - | - |
- Qualitative claims:
  | Claim in repo | Statement in source | Difference in scope/strength |
  |---|---|---|
  | Telling an LLM how its output will be evaluated causes it to reshape outputs to game the metric, degrading out-of-sample performance. | Goal-aware prompting shifts intermediate measures toward the disclosed downstream objective... provides no advantage post-cutoff. | Matches closely |

### Control Illusion: Understanding and Addressing LLM Instruction Hierarchy Failure
- Repo states — authors: Geng et al. | Source shows — authors: Yilin Geng, Haonan Li, Honglin Mu, Xudong Han, Timothy Baldwin, Omri Abend, Eduard Hovy, Lea Frermann
- Repo states — title: Control Illusion: Understanding and Addressing LLM Instruction Hierarchy Failure | Source shows — title: Control Illusion: The Failure of Instruction Hierarchies in Large Language Models
- Repo states — year: 2025 | Source shows — year: 2025
- Repo states — arxiv: https://arxiv.org/abs/2502.15851 | Status: resolves to this paper
- Numerical claims:
  | Claim in repo | Value in source | Location in source | Match? |
  |---|---|---|---|
  | LLM instruction obedience drops to 9.6% under cross-tier conflict | 9.6% | Abstract | Exact match |
- Qualitative claims:
  | Claim in repo | Statement in source | Difference in scope/strength |
  |---|---|---|
  | Recency bias is the strongest compliance driver — position in context matters more than explicit priority markers | Models are significantly more likely to follow the instruction that appears last in the prompt, regardless of its assigned priority or role. Position in context matters more than explicit priority markers. | Exact match |
  | Critical rules placed at the END of context yield highest compliance | Critical rules placed at the end of the prompt yield the highest compliance. | Exact match |

### LLM Code Smells in Agentic Systems
- Repo states — authors: Mahmoudi et al. | Source shows — authors: Brahim Mahmoudi et al.
- Repo states — title: LLM Code Smells in Agentic Systems | Source shows — title: Specification and Detection of LLM Code Smells
- Repo states — year: 2025 | Source shows — year: 2025
- Repo states — arxiv: https://arxiv.org/abs/2512.18020 | Status: resolves to this paper
- Numerical claims:
  | Claim in repo | Value in source | Location in source | Match? |
  |---|---|---|---|
  | 40.5% of agent system failures are caused by Non-Specific Output (NSO) | 60.50% of them contained at least one of these code smells (UMM, NMVP, NSM, NSO, TNES). | Abstract/Summary | Mismatch / Not found in source |
- Qualitative claims:
  | Claim in repo | Statement in source | Difference in scope/strength |
  |---|---|---|
  | NSO = agent returns free-form prose where a structured schema was expected | No Structured Output (NSO): Relying on raw text parsing instead of using structured formats | Matches meaning |
  | XML tag wrapping significantly reduces NSO failure rates for Claude | Not explicitly stated in the general abstract summary | Not found |

### Revisiting Role-Play Prompting: A Systematic Assessment of Persona Calibration in LLMs
- Repo states — authors: Hu et al. | Source shows — authors: Zizhao Hu, Mohammad Rostami, and Jesse Thomason
- Repo states — title: Revisiting Role-Play Prompting: A Systematic Assessment of Persona Calibration in LLMs | Source shows — title: Expert Personas Improve LLM Alignment but Damage Accuracy: Bootstrapping Intent-Based Persona Routing with PRISM
- Repo states — year: 2026 | Source shows — year: 2026
- Repo states — arxiv: https://arxiv.org/abs/2603.18507 | Status: resolves to this paper
- Numerical claims:
  | Claim in repo | Value in source | Location in source | Match? |
  |---|---|---|---|
  | For safety analysis, a full auditor persona raises refusal rate by +17.7%. | Not explicitly in abstract summary | - | Not found / Unverified |
- Qualitative claims:
  | Claim in repo | Statement in source | Difference in scope/strength |
  |---|---|---|
  | Persona effects are asymmetric by task type | Task Dependency: Generative/Alignment Tasks vs. Discriminative/Logic Tasks | Matches closely |
  | For code tasks (pretraining), personas hurt accuracy. | Discriminative/Logic Tasks: Personas are detrimental to math, coding, and factual retrieval. | Matches closely |
  | For style/tone tasks (alignment), personas help. | Generative/Alignment Tasks: Personas are beneficial for creative writing, roleplay, and safety | Matches closely |
  | Generic "helpful expert" personas on debugging tasks degrade output by directing attention to the persona narrative instead of the problem. | The model focuses more on acting like an expert than actually being accurate. | Matches closely |

## URLs

| URL | Status | Notes |
|---|---|---|
| https://agents.md | 200 | |
| https://arxiv.org/abs/2502.15851 | 200 | Paper title: Control Illusion: The Failure of Instruction Hierarchies in Large Language Models |
| https://arxiv.org/abs/2512.18020 | 200 | Paper title: Specification and Detection of LLM Code Smells |
| https://arxiv.org/abs/2602.09504 | 200 | Paper title: Seeing the Goal, Missing the Truth: Human Accountability for AI Bias |
| https://arxiv.org/abs/2602.11988 | 200 | Paper title: Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents? |
| https://arxiv.org/abs/2603.18507 | 200 | Paper title: Expert Personas Improve LLM Alignment but Damage Accuracy: Bootstrapping Intent-Based Persona Routing with PRISM |
| https://claude.ai/code | 403 | |
| https://docs.anthropic.com/en/docs/claude-code | 200 | |
| https://dotclaude-setup.vercel.app/ | 200 | |
| https://github.com/affaan-m/everything-claude-code | 200 | Repo title: affaan-m/everything-claude-code |
| https://github.com/garrytan/gstack | 200 | Repo title: garrytan/gstack |
| https://github.com/hardikpandya/stop-slop | 200 | Repo title: hardikpandya/stop-slop |
| https://github.com/poferraz/dotclaude.git | 200 | |
| https://github.com/severity1/claude-code-prompt-improver | 200 | Repo title: severity1/claude-code-prompt-improver |
| https://github.com/shanraisshan/claude-code-best-practice | 200 | Repo title: shanraisshan/claude-code-best-practice |
| https://github.com/steveyegge/beads | 200 | Repo title: steveyegge/beads |
| https://github.com/thedotmack | 200 | Page title: thedotmack (Alex Newman) · GitHub |
| https://img.shields.io/badge/Claude%20Code-2.1.0%2B-blue | 200 | |
| https://img.shields.io/badge/License-MIT-yellow.svg | 200 | |
| https://img.shields.io/badge/PRs-welcome-brightgreen.svg | 200 | |
| https://img.shields.io/badge/Website-dotclaude--setup.vercel.app-000000?logo=vercel | 200 | |
| https://json.schemastore.org/claude-code-settings.json | 200 | |
| https://keepachangelog.com/en/1.0.0/ | 200 | |
| https://opensource.org/licenses/MIT | 200 | |
| https://semver.org/spec/v2.0.0.html | 200 | |
| https://skill-creator.app | 000 | Fails / Connection error |
| https://x.com/affaanmustafa/status/2014040193557471352 | 200 | |

## Tool Descriptions

### everything-claude-code
- Repo says: Agents, skills, hooks, commands, rules, and the plugin architecture. The foundation this setup started from.
- Source says: The agent harness performance optimization system. Skills, instincts, memory, security, and research-first development for Claude Code, Codex, Opencode, Cursor and beyond.
- Username — repo: affaan-m | actual: affaan-m
- Repo name — repo: everything-claude-code | actual: everything-claude-code

### gstack
- Repo says: Persistent headless Chromium browser daemon for QA and dogfooding. `/browse`, `/careful`, `/freeze`, `/guard`, `/unfreeze`.
- Source says: Use Garry Tan's exact Claude Code setup: 15 opinionated tools that serve as CEO, Designer, Eng Manager, Release Manager, Doc Engineer, and QA
- Username — repo: garrytan | actual: garrytan
- Repo name — repo: gstack | actual: gstack

### claude-code-prompt-improver
- Repo says: Prompt evaluation plugin that intercepts vague prompts before execution
- Source says: Intelligent prompt improver hook for Claude Code. Type vibes, ship precision.
- Username — repo: severity1 | actual: severity1
- Repo name — repo: claude-code-prompt-improver | actual: claude-code-prompt-improver

### claude-code-best-practice
- Repo says: Reference patterns for Claude Code workflows and conventions
- Source says: practice made claude perfect
- Username — repo: shanraisshan | actual: shanraisshan
- Repo name — repo: claude-code-best-practice | actual: claude-code-best-practice

### context-mode
- Repo says: Session memory and observation system (context-mode plugin)
- Source says: claude-mem: A Claude Code plugin that captures session data, compresses it with AI, and injects relevant context back into future sessions. 
- Username — repo: thedotmack | actual: thedotmack
- Repo name — repo: context-mode | actual: claude-mem (or not found exactly as context-mode on profile)

### beads
- Repo says: Structured task tracking for coding agents. Recommended as the on-demand memory layer.
- Source says: Beads - A memory upgrade for your coding agent
- Username — repo: steveyegge | actual: steveyegge
- Repo name — repo: beads | actual: beads

### stop-slop
- Repo says: Writing quality patterns adapted for skill output
- Source says: A skill file for removing AI tells from prose
- Username — repo: hardikpandya | actual: hardikpandya
- Repo name — repo: stop-slop | actual: stop-slop

## Claude Code Claims

| Claim | Official docs say | Source URL |
|---|---|---|
| Use of hooks to intercept commands/actions | "Hooks let you run shell commands before or after Claude Code actions, like auto-formatting after every file edit or running lint before a commit." | https://docs.anthropic.com/en/docs/claude-code |
| Use of frontmatter fields like `skills:` | Not found in official docs | https://docs.anthropic.com/en/docs/claude-code |
| Use of "plugin architecture" | Not found in official docs (mentions JetBrains plugin, but not an extensible plugin architecture for Claude Code itself) | https://docs.anthropic.com/en/docs/claude-code |
| Auto-loading and skill discovery | Not found in official docs | https://docs.anthropic.com/en/docs/claude-code |
| "Agent tool" for agents to invoke other agents | Not found in official docs | https://docs.anthropic.com/en/docs/claude-code |

## Attribution Language

Sentences with unattributed findings:
- "The key insight behind this design: most context files hurt performance — they flood the model's attention with boilerplate before a single line of your code is seen."
- "Coding agents perform measurably worse with bloated context files."
- "When the context window fills with generic instructions, framework boilerplate, and catch-all rules, the model's attention is diluted before it ever sees your actual problem."
- "Research now confirms what practitioners suspected: more context is not better context."

Instances of "we/our/I" + finding:
- None found.
