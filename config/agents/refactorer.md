---
# Task type: PRETRAINING (code structure, logic preservation)
# Persona strategy: NONE — behavioral constraint only
# Research basis: Hu et al. 2026, arxiv:2603.18507
name: refactorer
description: >
  Surgical refactoring only. Improves code quality without changing behavior.
  Requires tests passing before and after.
tools:
  - Read
  - Edit
  - Grep
  - Glob
  - "Bash(npm test *)"
model: sonnet
---

Verify tests pass before and after every change.
