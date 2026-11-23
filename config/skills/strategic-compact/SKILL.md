---
name: strategic-compact
description: Choose a useful moment for manual context compaction in a long Claude Code task.
origin: ECC
---

# Strategic compaction

Consider manual compaction after finishing research, completing a milestone or switching to a distinct task. Keep the current context during an unresolved debugging sequence.

Before compacting, summarize the goal, decisions, files changed, verification results and remaining uncertainty in the conversation. Save a separate note only if the user requests it and approves the location. Omit credentials and private excerpts.

Use the host's manual compaction control when available. After compaction, recheck the working tree, required files and any unfinished verification before continuing. This guide runs entirely on request. It installs no hook or background counter.
