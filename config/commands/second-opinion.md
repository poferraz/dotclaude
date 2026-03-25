Get a focused second-opinion review of the current diff from a separate Claude instance.

```bash
git diff HEAD
```

Pass the diff above to a second Claude instance with this question:

```bash
claude -p "Review this diff for correctness, security issues, and missed edge cases. Be concise — flag real problems only, skip style.

$(git diff HEAD)"
```

If the diff is empty, run against staged changes instead:

```bash
claude -p "Review this diff for correctness, security issues, and missed edge cases. Be concise — flag real problems only, skip style.

$(git diff --cached)"
```

Report the findings to the user. If no issues are found, say so in one line.
