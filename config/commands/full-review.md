---
description: Review selected project changes for correctness, design, security and verification gaps.
argument-hint: "<target path or description> [--security-focus] [--performance-critical] [--strict-mode]"
---

# Full review

1. Confirm the target files or revision, requested focus and intended behavior. Limit the review to the selected repository.
2. Examine the changed implementation, callers and tests. Use the installed code-reviewer for an independent reading if available. Trace the behavior before judging the design.
3. For security-sensitive changes, use the read-only security-reviewer or inspect the source directly. Describe affected boundaries, likely impact and a defensive fix. Keep private values out of the result.
4. For performance-sensitive changes, identify measured costs and distinguish them from guesses. Review reliability and error handling for ordinary and edge cases.
5. Use the project’s own test entry points when authorized. Record the checks that passed, failed or were unavailable.
6. Present each actionable finding with its location, evidence and recommended correction. State what remains unverified. Keep the report in the conversation unless the user approves a private output location.
