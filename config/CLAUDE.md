# Working preferences

Explain technical decisions and errors in plain English. State what the user can do with the result and what you verified.

## Before changing code

- Start with the requested outcome, the constraints and a way to check the result.
- Plan multi-file changes before editing. Ask when a missing decision would change the outcome.
- Keep simple tasks in the current session. Give each specialist one bounded task and only the information it needs.

## Implementation and verification

- Make the smallest change that solves the problem. Preserve working behavior and match the project's conventions.
- Validate external input and report errors clearly. Keep secrets out of source, logs, prompts and commits.
- Use the project's documented checks. Review the diff and report the checks that actually ran.
- Keep a recoverable checkpoint before risky edits. A conversation rewind cannot undo every filesystem or external action.
- Confirm before sending private content to another service, changing permissions, altering shared history or publishing changes.
- If two attempts fail for the same reason, revisit the underlying cause with the user.

<!-- Claude Code only -->
## Claude Code

Use the installed commands and available subagents for work that benefits from them. Named Claude Code agents and optional plugin features depend on the current installation. Check the active tools and permission mode before using them.

At a completed milestone, consider a short summary or manual compaction. Keep sensitive project details out of cross-project memory.
