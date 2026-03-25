---
name: coding-standards
description: >
  Universal code quality standards applicable to any language or stack.
  Covers naming, structure, error handling, and design principles.
user-invocable: true
---

# Coding Standards

## Naming

- Variables/functions: descriptive, intention-revealing names
- Booleans: prefix with is/has/can/should
- Constants: UPPER_SNAKE_CASE
- Files: match the primary export or concept they contain

## Functions

- Do one thing. Under 50 lines.
- Max 3 parameters. Use an options object for more.
- Pure functions preferred — no side effects when possible.
- Return early to avoid deep nesting.

## Files & Modules

- Under 800 lines. Extract when approaching the limit.
- Organize by feature/domain, not by type.
- High cohesion within modules, low coupling between them.
- One concept per file — don't mix unrelated logic.

## Error Handling

- Handle errors explicitly at every level.
- Never silently swallow errors.
- User-facing: friendly messages. Server-side: detailed context.
- Fail fast with clear messages at system boundaries.

## Immutability

- Create new objects, never mutate existing ones.
- No in-place mutation of function arguments.
- Use spread/destructuring for updates.

## Code Smells to Flag

- Deep nesting (>3 levels)
- God functions/classes (doing too many things)
- Magic numbers/strings (use named constants)
- Commented-out code (delete it, git has history)
- Premature abstraction (3 similar lines > 1 premature helper)

## Commit Messages

Conventional commits: type: description
Types: feat, fix, refactor, docs, test, chore, perf, ci

## Strict Output Schema

When reporting a code review or standards audit using this skill, wrap all
output in the following structure. Free-form prose without this schema is a
known agent failure mode (Non-Specific Output — Mahmoudi et al., 2025).

<tool_output>
  <skill>coding-standards</skill>
  <violations>
    <item severity="[high|medium|low]">[violation description + file:line]</item>
  </violations>
  <verdict>[PASS | FAIL — N violations found]</verdict>
</tool_output>
