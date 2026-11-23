---
name: verification-loop
description: "A comprehensive verification system for Claude Code sessions."
origin: ECC
---

# Verification Loop Skill

A comprehensive verification system for Claude Code sessions.

## When to Use

Invoke this skill:
- After completing a feature or significant code change
- Before creating a PR
- When you want to ensure quality gates pass
- After refactoring

## Verification phases

1. **Build.** Read the repository's scripts and run its documented build. Keep its actual exit status.
2. **Types.** Run the existing type-check command where the project provides one.
3. **Lint.** Run the configured linter. Distinguish warnings from errors.
4. **Tests.** Run the relevant suite. Report its observed test count and any coverage actually measured.
5. **Security.** Use a trusted local redacting scanner for the requested files or history. Keep keys, raw matched lines and private contents out of logs. Report only the category and location. If scanning is unavailable, mark it unverified.
6. **Diff.** Review changed paths for unexpected changes, sensitive material and missed error handling. Compare the tested state with the state proposed for a commit.

Mark unavailable or irrelevant checks explicitly. A passing build supports the build claim only. Avoid automatically downloading tools or packages to fill a missing check.

## Output Format

After running all phases, produce a verification report:

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```

## Continuous Mode

For long sessions, run verification every 15 minutes or after major changes:

```markdown
Set a mental checkpoint:
- After completing each function
- After finishing a component
- Before moving to next task

Run: /verify
```

## Integration with Hooks

This skill complements PostToolUse hooks but provides deeper verification.
Run these checks explicitly. Any additional hooks require separate configuration.

## Strict Output Schema

All verification reports MUST use this XML wrapper. Unstructured prose reports
are a known agent failure mode (Non-Specific Output — Mahmoudi et al., 2025).

<tool_output>
  <skill>verification-loop</skill>
  <report>
    <build>[PASS|FAIL]</build>
    <types>[PASS|FAIL] (N errors)</types>
    <lint>[PASS|FAIL] (N warnings)</lint>
    <tests>[PASS|FAIL] (N/M passed, X% coverage)</tests>
    <security>[PASS|FAIL] (N issues)</security>
    <diff>N files changed</diff>
  </report>
  <verdict>[READY|NOT READY] for PR</verdict>
  <issues>[list any blocking issues here, or "none"]</issues>
</tool_output>
