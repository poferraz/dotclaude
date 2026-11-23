# Checkpoint

Use `/checkpoint create`, `verify`, `list` or `clear` with an optional name or exact Git reference.

## Create

Inspect the branch and changed paths using `git status --short --branch`. Avoid printing file contents. If the working tree is clean, report the existing commit from `git rev-parse --verify HEAD`.

For a dirty tree, explain which files the checkpoint would include. Ask the user to select a commit or a stash and approve the scope. A commit records its approved changes in the branch. A stash removes its selected changes from the working tree until restored. Leave private, ignored and unrelated files alone.

- For a commit, verify exactly what is staged before committing. Report the new commit ID from `git rev-parse --verify HEAD`.
- For a stash, read the current stash ID if one exists, make the approved stash, then read `git rev-parse --verify 'refs/stash^{commit}'`. Report the resulting stash ID only if it changed. If Git saved nothing, say so.

Keep the checkpoint type, name and exact ID in the conversation. Save a separate record only if the user requests and approves a private destination.

## Verify and list

For `verify`, resolve the selected record to its exact Git object. Compare the intended paths with the working tree and run the relevant checks. Report observed results and any unavailable comparison. If a name is ambiguous, ask for the exact ID.

For `list`, report checkpoints identified in the conversation. If the user wants existing Git stashes, list their references and IDs. Git does not distinguish ordinary commits from named checkpoints on its own.

For `clear`, remove conversational labels only. Dropping a saved stash needs separate approval for that exact stash ID. Recheck the selected reference immediately before any deletion.
