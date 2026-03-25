# GitHub Repository Audit

This skill performs a comprehensive, evidence-based audit of any local Git
repository. It checks security, structure, commit history, community files,
and GitHub-specific configuration. Every finding is reported as-is with
evidence. The output is a set of fixing prompts ready to paste into Claude
Code.

## Important context

The user running this audit may be new to Git and GitHub. Do not assume
familiarity with concepts like rebasing, force pushing, or branch protection
rules. When a finding requires explanation, provide it inline. When a fix
could cause data loss (like history rewriting), say so explicitly and explain
what "data loss" means in that context.

## Pre-flight

Before running any checks, establish these facts:

1. **Repo location**: Ask for the local path if not provided. Confirm it
   exists and contains a `.git` directory.
2. **Remote status**: Run `git remote -v`. Determine if the repo has been
   pushed to GitHub yet. This distinction matters because some fixes (like
   removing secrets from history) are straightforward before first push but
   require force-pushing after, which rewrites history for anyone who cloned.
3. **Repo intent**: Is this a public repo, private repo, or undecided?
   Public repos need stricter security and better community files.
4. **Tool availability**: Check which tools are installed and note any that
   are missing. Do not skip audit areas when a tool is missing; use fallback
   methods instead.
   - `gh` (GitHub CLI): used for API checks on branch protection, security
     settings. Fallback: note these as "manual verification needed" items.
   - `git`: required, abort if not found.
   - `grep`/`rg`: used for secret scanning. At least one must be available.

## Audit areas

Work through all 9 sections of the checklist below. Every item must be
checked and reported.

1. **SECRET AND CREDENTIAL SCAN** — The most important section. Leaked
   secrets in a public repo are immediately exploitable. Check tracked files,
   staged files, and full git history.

2. **GITIGNORE COVERAGE** — Verify `.gitignore` exists, covers common
   patterns for the detected stack, and was present from the first commit
   (files committed before `.gitignore` existed are still tracked even after
   adding the ignore rule).

3. **SENSITIVE PATH EXPOSURE** — Check for hardcoded local paths
   (`/Users/`, `/home/`, `C:\Users\`), email addresses, internal hostnames,
   or machine-specific configuration that would leak in a public repo.

4. **COMMIT HISTORY HYGIENE** — Check that commits follow Conventional
   Commits format, are atomic (one logical change per commit), have
   meaningful descriptions, and use consistent author identity.

5. **REPOSITORY STRUCTURE** — Verify the presence and quality of: README.md,
   LICENSE, .gitignore, CHANGELOG.md, CONTRIBUTING.md, SECURITY.md,
   CODE_OF_CONDUCT.md, and .github/ templates (issue templates, PR template).

6. **README QUALITY** — Check that README has: project description, install/
   usage instructions, license reference, and that all internal links point
   to files that actually exist in the repo.

7. **BRANCH AND TAG HYGIENE** — Check branch naming, whether the default
   branch is `main`, and whether any stale branches exist.

8. **LARGE FILE DETECTION** — Find files over 1MB, binary files that should
   use Git LFS, and dependency directories that should be gitignored.

9. **GITHUB SETTINGS** (post-push only) — Branch protection rules, secret
   scanning, Dependabot, and repository topics/description. Skip entirely
   if the repo has no remote or has never been pushed.

## How to report findings

For each audit area, report findings using this exact format:

```
### [AREA NAME]

#### [ITEM]: PASS | FAIL | MANUAL CHECK NEEDED
Evidence: [command output, file excerpt, or explanation]
Current state: [what exists now — only for FAIL items]
```

Do not assign priority labels, severity scores, or timelines to findings.
Do not group findings as "critical" vs "minor." Report the current state and
let the user decide what matters. This avoids biasing which issues get
attention (per goal-blind prompt design: specify what to measure, never how
the output will be evaluated).

## How to generate fixing prompts

After reporting all findings, generate a separate section titled
**FIXING PROMPTS**. For each FAIL finding, produce a self-contained prompt
the user can paste directly into Claude Code. Each prompt must:

1. State the problem in one sentence
2. Specify the exact file(s) and location(s) involved
3. Describe the fix without ambiguity
4. Include any commands that need to run
5. End with a verification step ("confirm the fix by running X")

Group related fixes into a single prompt when they touch the same file or
the same concept. Number each prompt sequentially.

Format:

```
## FIXING PROMPT 1: [short description]

[Problem]: ...
[Files]: ...
[Fix]: ...
[Verify]: ...
```

If a fix involves git history rewriting (like removing a committed secret),
add a warning block:

```
HISTORY REWRITE: This fix changes commits that already exist.
If this repo has been pushed to GitHub and others have cloned it,
this will cause problems for them. If you are the only user and
have not pushed yet, this is safe.
```

## What counts as a complete audit

The audit is complete when every item in the checklist has been checked and
reported as PASS, FAIL, or MANUAL CHECK NEEDED. If an entire section is
not applicable (like GitHub Settings for an unpushed repo), state that
explicitly with the reason.

After the fixing prompts, add a one-paragraph summary stating:
- Total items checked
- Total PASS / FAIL / MANUAL
- Whether the repo is ready to push as-is, or needs fixes first
- Any items that require the user to make a judgment call (like choosing a
  license)

---

# Audit Checklist Reference

Every check item, the commands to run, fallback methods when tools are
missing, and what PASS/FAIL looks like for each.

---

## 1. SECRET AND CREDENTIAL SCAN

This is the highest-consequence section. A single leaked API key in a public
repo can be exploited within minutes by automated scanners.

### 1.1 Scan tracked files for secrets

**What to look for**: API keys, tokens, passwords, private keys, connection
strings, .env file contents, OAuth secrets, webhook URLs with tokens.

**Command (rg available)**:
```bash
rg -i --no-heading -n \
  '(api[_-]?key|api[_-]?secret|access[_-]?token|auth[_-]?token|secret[_-]?key|password|passwd|private[_-]?key|client[_-]?secret|webhook.*secret|Bearer\s+[A-Za-z0-9\-._~+/]+=*|ghp_[A-Za-z0-9]{36}|sk-[A-Za-z0-9]{48}|AKIA[A-Z0-9]{16})' \
  --glob '!.git' .
```

**Command (grep fallback)**:
```bash
grep -rn -i \
  -e 'api[_-]*key' -e 'api[_-]*secret' -e 'access[_-]*token' \
  -e 'auth[_-]*token' -e 'secret[_-]*key' -e 'password' \
  -e 'private[_-]*key' -e 'client[_-]*secret' \
  -e 'ghp_[A-Za-z0-9]' -e 'sk-[A-Za-z0-9]' -e 'AKIA[A-Z0-9]' \
  --exclude-dir=.git .
```

**Interpreting results**: Not every match is a real secret. Common false
positives include: placeholder values like `YOUR_API_KEY_HERE`, environment
variable references like `process.env.API_KEY`, documentation examples, and
template bracket placeholders like `[your-key]`. For each match, determine
whether it contains an actual credential value or just a reference/placeholder.

**PASS**: Zero matches, or all matches are confirmed false positives.
**FAIL**: Any match containing what appears to be a real credential value.

### 1.2 Scan git history for secrets

Files can be removed from the current tree but still exist in git history.
Anyone who clones the repo gets the full history, including deleted secrets.

**Command**:
```bash
git log --all --diff-filter=D --name-only --pretty=format:"%H %s" | head -100
```
This shows deleted files. Then check if any look like credential files
(.env, .pem, .key, credentials.json, etc.).

**Deeper scan (if available)**:
```bash
# trufflehog (best option)
trufflehog git file://. --only-verified

# git-secrets (alternative)
git secrets --scan-history
```

**Fallback (no specialized tools)**:
```bash
git log -p --all -S 'password' --no-textconv -- . ':!.git' | head -200
git log -p --all -S 'api_key' --no-textconv -- . ':!.git' | head -200
git log -p --all -S 'secret' --no-textconv -- . ':!.git' | head -200
```

**PASS**: No credentials found in history.
**FAIL**: Any credential found in any historical commit.

### 1.3 Check for credential files in tree

**Command**:
```bash
find . -not -path './.git/*' \( \
  -name '.env' -o -name '.env.*' -o -name '*.pem' -o -name '*.key' \
  -o -name '*.p12' -o -name '*.pfx' -o -name 'credentials.json' \
  -o -name 'service-account*.json' -o -name '*.keystore' \
  -o -name 'id_rsa' -o -name 'id_ed25519' -o -name '.htpasswd' \
  -o -name '.pgpass' -o -name '.netrc' \)
```

**PASS**: No credential files found, or only template versions.
**FAIL**: Any real credential file tracked by git.

---

## 2. GITIGNORE COVERAGE

### 2.1 .gitignore exists

**Command**: `test -f .gitignore && echo "EXISTS" || echo "MISSING"`

**PASS**: File exists and is non-empty.
**FAIL**: File missing or empty.

### 2.2 .gitignore covers stack-appropriate patterns

Detect the project stack and verify coverage. Common patterns by stack:

**Universal (every repo needs these)**:
```
.env
.env.*
.DS_Store
Thumbs.db
*.log
*.key
*.pem
*.p12
credentials*
```

**Node/JavaScript/TypeScript**:
```
node_modules/
dist/
build/
.next/
coverage/
*.tsbuildinfo
```

**Python**:
```
__pycache__/
*.pyc
.venv/
venv/
*.egg-info/
.pytest_cache/
```

**React/Vite**:
```
node_modules/
dist/
.env
.env.local
.env.production
*.local
```

**Command to detect stack**:
```bash
# Check for package.json (Node), requirements.txt (Python), Cargo.toml (Rust), etc.
ls package.json pyproject.toml requirements.txt Cargo.toml go.mod Gemfile 2>/dev/null
```

**PASS**: .gitignore covers all universal patterns plus stack-specific patterns.
**FAIL**: Missing any universal pattern, or missing obvious stack patterns.

### 2.3 .gitignore was present from first commit

This is commonly missed. If files were committed before .gitignore existed,
they are tracked even after adding the ignore rule. Adding .gitignore later
does not retroactively untrack files.

**Command**:
```bash
# Find when .gitignore was first committed
git log --diff-filter=A --format="%H %ai" -- .gitignore

# Find the first commit in the repo
git log --reverse --format="%H %ai" | head -1
```

**PASS**: .gitignore was added in the first commit.
**FAIL**: .gitignore was added after the first commit. Check if any
now-ignored files were committed before .gitignore existed:
```bash
# List files that are tracked but would be ignored
git ls-files -ci --exclude-standard
```

---

## 3. SENSITIVE PATH EXPOSURE

### 3.1 Hardcoded local paths

**Command**:
```bash
rg --no-heading -n '(/Users/|/home/|C:\\Users\\|/Documents/|/Desktop/)' \
  --glob '!.git' . 2>/dev/null || \
grep -rn -e '/Users/' -e '/home/' -e 'C:\\Users\\' \
  -e '/Documents/' -e '/Desktop/' --exclude-dir=.git .
```

**Interpreting**: Paths in documentation telling users where to clone are
fine. Paths that reference the repo author's specific machine layout are a
leak.

**PASS**: No author-specific local paths found.
**FAIL**: Any path containing the repo author's username or machine-specific
directory structure.

### 3.2 Email addresses

**Command**:
```bash
rg --no-heading -n '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  --glob '!.git' --glob '!LICENSE' . 2>/dev/null || \
grep -rn -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  --exclude-dir=.git --exclude=LICENSE .
```

**Interpreting**: Email in a LICENSE file or SECURITY.md contact section is
intentional. Email in source code, config files, or comments is usually
unintentional.

**PASS**: No unintentional email exposure.
**FAIL**: Email found in source code or config files.

### 3.3 Internal hostnames and IPs

**Command**:
```bash
rg --no-heading -n '(localhost:[0-9]{4,5}|192\.168\.|10\.[0-9]+\.|172\.(1[6-9]|2[0-9]|3[01])\.)' \
  --glob '!.git' . 2>/dev/null || \
grep -rn -E '(localhost:[0-9]{4,5}|192\.168\.|10\.[0-9]+\.)' \
  --exclude-dir=.git .
```

**Interpreting**: localhost references in development config are normal but
should be in .env or .env.example, not hardcoded. Private IPs indicate
internal infrastructure exposure.

**PASS**: No internal network references in committed code.
**FAIL**: Internal IPs or hostnames found outside of example/template files.

---

## 4. COMMIT HISTORY HYGIENE

### 4.1 Conventional Commits format

The Conventional Commits specification requires this format:
```
<type>[optional scope]: <description>
```

Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
`build`, `ci`, `chore`, `revert`.

**Command**:
```bash
git log --oneline --no-decorate | head -30
```

For each commit, check: Does it start with a valid type followed by a colon?
Is the description in imperative mood and lowercase after the colon? Is it
specific enough to understand without reading the diff?

**Examples of good commits**:
```
feat(auth): add OAuth2 login flow
fix(resume): correct ATS keyword matching logic
docs: update installation instructions in README
chore: add .gitignore for node_modules
```

**Examples of bad commits**:
```
Update files              (no type, vague description)
fixed stuff               (no type, meaningless description)
WIP                       (work in progress should not be in main)
feat: stuff               (type present but description is meaningless)
Added new feature         (no type, past tense instead of imperative)
```

**PASS**: All commits follow Conventional Commits format.
**FAIL**: Any commit deviates. Note which specific commits fail and why.

### 4.2 Consistent author identity

**Command**:
```bash
git log --format="%an <%ae>" | sort -u
```

**PASS**: One consistent author name and email across all commits.
**FAIL**: Multiple author identities (often caused by different git configs
on different machines, or committing from GitHub web UI vs. local terminal).

### 4.3 Atomic commits

**Command**:
```bash
# Show files changed per commit
git log --oneline --stat | head -60
```

Look for commits that touch many unrelated files. A single commit that
modifies the README, adds a new feature, and fixes a typo in a different
file is not atomic.

**PASS**: Each commit appears to address a single logical change.
**FAIL**: Commits that mix unrelated changes.

### 4.4 No WIP or fixup commits on main

**Command**:
```bash
git log --oneline | grep -i -E '(^wip|fixup|squash|temp|todo|hack|xxx)'
```

**PASS**: No work-in-progress commits on the main branch.
**FAIL**: Any WIP/fixup/temp commits found.

### 4.5 Clean working tree

**Command**:
```bash
git status --short
```

**PASS**: Working tree is clean (no output).
**FAIL**: Uncommitted changes, untracked files, or staged but uncommitted
changes exist.

---

## 5. REPOSITORY STRUCTURE

### 5.1 Essential files

Check for the presence of each file. For public repos, all are expected.
For private repos, some are optional (marked below).

| File | Public repo | Private repo | Check command |
|------|------------|-------------|---------------|
| README.md | Required | Required | `test -f README.md` |
| LICENSE | Required | Optional | `test -f LICENSE` |
| .gitignore | Required | Required | `test -f .gitignore` |
| CHANGELOG.md | Expected | Optional | `test -f CHANGELOG.md` |
| CONTRIBUTING.md | Expected | Optional | `test -f CONTRIBUTING.md` |
| SECURITY.md | Expected | Optional | `test -f SECURITY.md` |
| CODE_OF_CONDUCT.md | Optional | Optional | `test -f CODE_OF_CONDUCT.md` |

### 5.2 GitHub community files

| File/Directory | Purpose | Check command |
|---------------|---------|---------------|
| .github/ISSUE_TEMPLATE/ | Structured issue templates | `ls .github/ISSUE_TEMPLATE/ 2>/dev/null` |
| .github/PULL_REQUEST_TEMPLATE.md | PR template | `test -f .github/PULL_REQUEST_TEMPLATE.md` |
| .github/FUNDING.yml | Sponsor button config | `test -f .github/FUNDING.yml` |

### 5.3 No junk files

**Command**:
```bash
find . -not -path './.git/*' \( \
  -name '.DS_Store' -o -name 'Thumbs.db' -o -name '*.swp' \
  -o -name '*.swo' -o -name '*~' -o -name '*.bak' \
  -o -name '*.orig' -o -name '*.tmp' \)
```

**PASS**: No OS or editor junk files tracked.
**FAIL**: Any junk files found.

---

## 6. README QUALITY

### 6.1 Minimum content sections

Open README.md and check for the presence of:

- [ ] Project title / name
- [ ] One-paragraph description of what the project does
- [ ] Installation or setup instructions
- [ ] Usage instructions or examples
- [ ] License reference (matching the LICENSE file)
- [ ] Contact or contribution information

**PASS**: All six sections present.
**FAIL**: Any section missing. Note which ones.

### 6.2 Internal links resolve

**Command**:
```bash
# Extract markdown links to local files
grep -oP '\[.*?\]\(((?!http)[^)]+)\)' README.md | \
  grep -oP '\(([^)]+)\)' | tr -d '()' | while read -r link; do
    # Strip anchor fragments
    file=$(echo "$link" | cut -d'#' -f1)
    if [ -n "$file" ] && [ ! -e "$file" ]; then
      echo "BROKEN: $link"
    fi
  done
```

**Fallback** (if the above pipe fails):
```bash
# Simpler: just list all local links and manually verify
grep -oE '\]\([^http][^)]*\)' README.md
```

**PASS**: All internal links point to files that exist.
**FAIL**: Any broken link found.

### 6.3 No placeholder content

Search for common template leftovers:

**Command**:
```bash
grep -n -i -E '(TODO|FIXME|TBD|PLACEHOLDER|lorem ipsum|your-username|example\.com)' README.md
```

**PASS**: No placeholder content found.
**FAIL**: Any template leftovers remain.

---

## 7. BRANCH AND TAG HYGIENE

### 7.1 Default branch is main

**Command**:
```bash
git symbolic-ref --short HEAD
```

**PASS**: Default branch is `main`.
**FAIL**: Default branch is `master` or something else. (Note: `master` is
not wrong, but `main` is the current GitHub default and convention.)

### 7.2 No stale branches

**Command**:
```bash
git branch --list
```

**PASS**: Only `main` (and optionally `develop` or active feature branches).
**FAIL**: Branches that are clearly stale, merged, or leftover from
experiments.

---

## 8. LARGE FILE DETECTION

### 8.1 Files over 1MB

**Command**:
```bash
find . -not -path './.git/*' -type f -size +1M -exec ls -lh {} \;
```

**PASS**: No oversized files, or large files are appropriate (like bundled
assets that belong in the repo).
**FAIL**: Large files that should be gitignored (build artifacts, datasets,
media files) or tracked with Git LFS.

### 8.2 Binary files that should not be tracked

**Command**:
```bash
find . -not -path './.git/*' -type f \( \
  -name '*.zip' -o -name '*.tar.gz' -o -name '*.rar' \
  -o -name '*.mp4' -o -name '*.mp3' -o -name '*.wav' \
  -o -name '*.psd' -o -name '*.ai' -o -name '*.sketch' \
  -o -name '*.sqlite' -o -name '*.db' \)
```

**PASS**: No unnecessary binary files tracked.
**FAIL**: Binary files found that should be gitignored or in LFS.

### 8.3 Dependency directories committed

**Command**:
```bash
test -d node_modules && echo "FAIL: node_modules committed" || echo "PASS"
test -d vendor && echo "CHECK: vendor/ exists" || true
test -d __pycache__ && echo "FAIL: __pycache__ committed" || echo "PASS"
test -d .venv && echo "FAIL: .venv committed" || echo "PASS"
```

**PASS**: No dependency directories tracked.
**FAIL**: Any dependency directory committed to git.

---

## 9. GITHUB SETTINGS (post-push only)

Skip this entire section if `git remote -v` shows no remote or the repo has
never been pushed (no upstream tracking). These settings can only be verified
through the GitHub API or web interface.

### 9.1 Branch protection (requires `gh` CLI)

**Command**:
```bash
gh api repos/{owner}/{repo}/branches/main/protection 2>&1
```

Check for:
- [ ] Require PR reviews before merging
- [ ] Dismiss stale reviews
- [ ] Require status checks
- [ ] Prevent force pushes
- [ ] Prevent branch deletion

**Note for solo developers**: Requiring PR reviews only makes sense if you
want to enforce a review workflow on yourself or if you plan to accept
contributions. For a solo project, the most important protections are
preventing force pushes and branch deletion on main.

### 9.2 Secret scanning

**Command**:
```bash
gh api repos/{owner}/{repo} --jq '.security_and_analysis'
```

Check for:
- [ ] Secret scanning enabled
- [ ] Push protection enabled

### 9.3 Dependabot

**Check**: Does `.github/dependabot.yml` exist?

### 9.4 Repository metadata

**Command**:
```bash
gh api repos/{owner}/{repo} --jq '{description, topics, homepage}'
```

Check for:
- [ ] Repository description is set (not empty)
- [ ] At least 3 relevant topics are set
- [ ] Homepage URL is set (if applicable)

---

## Conventional Commits Quick Reference

Since this is important for commit hygiene and may be unfamiliar, here is
the full specification in brief.

**Format**: `<type>[optional scope]: <description>`

**Types and when to use them**:

| Type | Use when... |
|------|------------|
| `feat` | Adding new functionality |
| `fix` | Fixing a bug |
| `docs` | Changing only documentation |
| `style` | Formatting, whitespace, semicolons (no behavior change) |
| `refactor` | Restructuring code without changing behavior |
| `perf` | Improving performance |
| `test` | Adding or fixing tests |
| `build` | Changing build system or dependencies |
| `ci` | Changing CI/CD configuration |
| `chore` | Everything else (cleanup, maintenance, tooling) |
| `revert` | Reverting a previous commit |

**Scope** (optional): A word in parentheses describing what subsystem the
commit affects. Example: `fix(auth)`, `feat(resume)`, `docs(readme)`.

**Description rules**:
- Use imperative mood: "add feature" not "added feature"
- Lowercase after the colon
- No period at the end
- Keep under 72 characters total

**Breaking changes**: Add `!` after the type/scope, or include
`BREAKING CHANGE:` in the commit body.
Example: `feat!: drop support for Node 14`

**Multi-line commits**:
```
feat(interview): add behavioral question generator

Implements the STAR framework for generating behavioral interview
questions based on the user's experience history.

Refs: #42
```

---

# Git and GitHub Essentials Reference

A reference for safe, professional Git usage. Consult this when a finding
requires explanation for the user.

---

## Mental model: what Git actually does

Git tracks **snapshots** of your project over time. Each snapshot is called
a **commit**. Commits form a chain: each one points back to the one before
it. This chain is your project's **history**.

Your project exists in three places at once:

1. **Working directory**: the files you see in Finder/VS Code. This is where
   you edit things.
2. **Staging area** (also called "index"): a holding pen. When you
   `git add` a file, you are saying "include this file's current state in my
   next snapshot."
3. **Repository** (the `.git` folder): the database of all commits. When you
   `git commit`, the staged snapshot becomes a permanent entry in the chain.

**GitHub** is a website that hosts a copy of your repository. When you
`git push`, you upload your local commits to GitHub. When you `git pull`,
you download commits from GitHub to your local machine.

---

## The safe daily workflow

```bash
# 1. Check what has changed since your last commit
git status

# 2. Review the actual changes (optional but recommended)
git diff

# 3. Stage the files you want to include
git add <file>           # Stage one specific file
git add .                # Stage everything that changed

# 4. Commit with a conventional commit message
git commit -m "feat: add interview question generator"

# 5. Push to GitHub
git push
```

**Rules**:
- Commit often. Small, frequent commits are easier to understand and safer
  to undo than large, rare ones.
- Never commit and push in one muscle-memory motion. Always run `git status`
  first to see what you are about to commit.
- Read the output of every git command. Git tells you what it did and what
  to do next. Do not ignore its messages.

---

## Commands you will use constantly

| Command | What it does |
|---------|-------------|
| `git status` | Shows what changed, what is staged, what is not tracked |
| `git add <file>` | Stages a file for the next commit |
| `git add .` | Stages all changes in the current directory |
| `git commit -m "type: description"` | Creates a snapshot with a message |
| `git push` | Uploads commits to GitHub |
| `git pull` | Downloads commits from GitHub |
| `git log --oneline` | Shows commit history, one line per commit |
| `git diff` | Shows unstaged changes |
| `git diff --staged` | Shows staged changes (what will be in the next commit) |

---

## Commands you should understand but use carefully

| Command | What it does | Risk |
|---------|-------------|------|
| `git reset HEAD <file>` | Unstages a file (does not delete changes) | Low |
| `git checkout -- <file>` | Discards changes to a file (cannot undo) | Medium |
| `git commit --amend` | Rewrites the last commit | Safe before push, risky after |
| `git rebase` | Rewrites commit history | High: never use on pushed commits |
| `git push --force` | Overwrites GitHub's history with yours | High: can destroy shared work |
| `git reset --hard` | Discards all uncommitted changes | Medium: changes are gone |

**The golden rule**: Never rewrite history that has been pushed to GitHub
unless you are the only person using the repo and you understand the
consequences. "Rewriting history" means any command that changes existing
commits (amend, rebase, reset, force push).

---

## Branching (when you are ready)

Branches let you work on something without affecting `main`. This is
valuable once you start accepting contributions or working on multiple
features at once. For a solo project with a simple workflow, committing
directly to `main` is acceptable for now.

When you are ready:

```bash
# Create a new branch and switch to it
git checkout -b feature/add-linkedin-module

# Do your work, commit as normal
git add .
git commit -m "feat(linkedin): add profile optimization logic"

# Push the branch to GitHub
git push -u origin feature/add-linkedin-module

# On GitHub: open a Pull Request from the branch to main
# After review: merge the PR on GitHub
# Then locally:
git checkout main
git pull
```

---

## .gitignore: what it does and does not do

`.gitignore` tells Git to pretend certain files do not exist. Git will not
stage or commit them. But there is a critical catch:

**`.gitignore` only affects untracked files.** If a file was already
committed before you added the ignore rule, Git continues tracking it. To
stop tracking a file that was already committed:

```bash
# Remove from Git's tracking without deleting the actual file
git rm --cached <file>
git commit -m "chore: stop tracking <file>"
```

This is why the audit checks whether `.gitignore` was present from the
first commit.

---

## Undoing mistakes

### "I committed something I should not have"

**If you have NOT pushed yet**:
```bash
# Undo the last commit but keep the changes in your working directory
git reset --soft HEAD~1
# Now fix the problem and commit again
```

**If you HAVE pushed**:
The commit is now on GitHub. You have two options:

1. **Add a new commit that removes the problem** (safe, preserves history):
   ```bash
   git rm <the-bad-file>
   git commit -m "chore: remove accidentally committed file"
   git push
   ```
   Note: the file still exists in history. For secrets, this is not enough.

2. **Rewrite history** (removes the file from all history, but risky):
   ```bash
   # This is advanced. Use the fixing prompt from the audit skill,
   # which will give you the exact commands for your situation.
   ```

### "I want to discard my uncommitted changes"

```bash
# Discard changes to one file
git checkout -- <file>

# Discard ALL uncommitted changes (cannot undo this)
git reset --hard HEAD
```

### "I made a typo in my last commit message"

```bash
# Only do this before pushing
git commit --amend -m "fix: correct the typo in auth module"
```

---

## Setting up a new repo correctly (first time)

The order matters. Do these steps in this sequence:

```bash
# 1. Initialize
git init
git branch -M main

# 2. Create .gitignore FIRST (before adding any files)
# This prevents accidentally committing files you want to ignore
echo "node_modules/" >> .gitignore
echo ".env" >> .gitignore
echo ".DS_Store" >> .gitignore
# ... add all patterns for your stack

# 3. Create your initial files (README, LICENSE, etc.)

# 4. Stage and make your first commit
git add .
git commit -m "chore: initial commit with project structure"

# 5. Create the repo on GitHub (do NOT initialize with README/license/gitignore)
# Use GitHub web UI or:
gh repo create your-username/repo-name --public --source=. --remote=origin

# 6. Push
git push -u origin main
```

**Why create .gitignore first**: Any file committed before .gitignore exists
will remain tracked even after the ignore rule is added. Starting with
.gitignore prevents this entire category of problems.

**Why NOT initialize the GitHub repo with files**: If GitHub creates a
README or LICENSE for you, and you already have those files locally, your
first push will fail with a "histories have diverged" error. Start with an
empty GitHub repo and push your local content to it.

---

## GitHub settings to configure after first push

These are set through the GitHub web interface (or `gh` CLI), not through
git commands.

1. **Repository description and topics**: Go to the repo page, click the
   gear icon next to "About." Add a one-line description and relevant topic
   tags. This helps people find your repo.

2. **Branch protection** (Settings > Branches > Add rule):
   At minimum for a solo project: prevent force pushes and branch deletion
   on `main`.

3. **Secret scanning** (Settings > Code security and analysis):
   Enable "Secret scanning" and "Push protection." These are free for public
   repos and catch secrets before they reach GitHub.

4. **Dependabot** (Settings > Code security and analysis):
   Enable Dependabot alerts. If your project has dependencies (package.json,
   requirements.txt, etc.), Dependabot will notify you when a dependency has
   a known vulnerability.

---

## Common mistakes and how to avoid them

| Mistake | Prevention |
|---------|-----------|
| Committing secrets (.env, API keys) | Add .gitignore before first commit. Run the audit skill regularly. |
| Committing node_modules or other dependencies | Add to .gitignore before first commit. |
| Vague commit messages ("update", "fix stuff") | Follow Conventional Commits. Be specific. |
| Huge commits with mixed changes | Commit after each logical unit of work, not at the end of the day. |
| Force pushing to shared branches | Never force push to main. Use branches and PRs. |
| Initializing GitHub repo with files when local repo already exists | Always create empty GitHub repo when pushing an existing local project. |
| Forgetting to pull before pushing | Run `git pull` before starting work and before pushing. |
