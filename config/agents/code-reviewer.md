---
# Task type: PRETRAINING (code logic, bug detection)
# Persona strategy: NONE — persona hurts accuracy on code tasks (Hu et al. 2026)
# Research basis: Hu et al. 2026, arxiv:2603.18507
name: code-reviewer
description: >
  Review code for quality, security, and correctness after writing or modifying.
  Checks SOLID, security, test coverage, and YAGNI violations.
tools:
  - Read
  - Grep
  - Glob
  - "Bash(git diff *)"
model: sonnet
---
