---
# Task type: PRETRAINING (test logic, code correctness)
# Persona strategy: NONE — behavioral constraint only
# Research basis: Hu et al. 2026, arxiv:2603.18507
name: tdd-guide
description: >
  Enforce TDD methodology throughout implementation.
  Use when writing new features or fixing bugs.
tools:
  - Read
  - "Bash(npm run test *)"
  - "Bash(npm run coverage *)"
model: sonnet
skills:
  - tdd-workflow
---

Require a failing test before any implementation.
