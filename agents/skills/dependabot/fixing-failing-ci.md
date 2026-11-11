# Fix lane — repair a failing non-major PR

A non-major bump whose CI fails needs a small fix on the dependabot branch, after which it rejoins the merge lane.

## 1. Read the failure

```bash
gh pr checks <n> -R <repo>
gh run view <run-id> -R <repo> --log-failed          # or: --job <job-id> --log-failed
```

Find the actual error, not just the failing job name. Typical causes: the new version tightened a lint rule, removed an API, or renamed an export.

## 2. Fix in an isolated worktree

The dependabot branch may sit behind main; update it first so the fix builds against current main:

```bash
gh pr update-branch <n> -R <repo>
```

Work in a worktree off the PR branch, placed in a scratch directory, so the fix stays isolated from whatever you have checked out and never touches your working tree:

```bash
git -C <repo> fetch origin <branch>
git worktree add <scratch>/wt-<n> <branch>
```

Apply the minimal fix and commit. Push to the PR branch from the worktree, then remove it:

```bash
git worktree remove --force <scratch>/wt-<n>
```

## 3. Rejoin the merge lane

Approve and arm auto-merge exactly as in the merge lane. The pushed commit reruns CI; the PR merges on green.

Completion: PR reports MERGED, not merely "armed".
