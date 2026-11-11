---
name: dependabot
description: Triage open Dependabot PRs across a GitHub org or owner and drive the safe ones to merged.
argument-hint: "[org-or-owner]"
disable-model-invocation: true
---

# Dependabot

Every PR falls into one **lane**:

- **merge** — non-major bump with green CI: approve, arm auto-merge, shepherd to MERGED.
- **fix** — non-major bump with failing CI: repair on the dependabot branch, then it rejoins the merge lane.
- **hold** — major bump: never merge without an explicit go-ahead. Report it; investigate only on request.

"Non-major" means patch or minor: the leading semver component is unchanged. A major bump is held even when its CI is green.

## 1. Discover

Resolve the org/owner scope: take it from $ARGUMENTS (e.g. `/dependabot pmmmwh`); if none is given, infer it from the current repo's remote (`gh repo view --json owner -q .owner.login`); if that also fails, ask the user.

```bash
gh search prs --owner <owner> --author "app/dependabot" --state open --archived=false --limit 100 --json repository,number,title
```

One query covers every active repo in that scope. `--archived=false` skips archived repos - their PRs are stale and their CI no longer runs, so they are never merge candidates. Completion: every returned PR is carried into step 2.

## 2. Classify and present

For each PR, read its bump type from the version numbers in the title (not the commit prefix) and its CI/review state:

```bash
gh pr view <n> -R <repo> --json number,mergeStateStatus,reviewDecision,autoMergeRequest,statusCheckRollup
```

- A **grouped** bump ("bump the X group with N updates") hides its members. Read the PR body for each version delta; the group is major if any member's leading component moves.
- A **base-image tag** bump (e.g. a runtime's major version tag) counts as major - hold it unless the user has said otherwise.

Present a table with repo, #, bump (from → to), whether it is major, and CI state, grouped by lane (merge, fix, hold - least to most attention needed) so each lane reads as one block instead of interleaved by repo. Then STOP and wait for the user to confirm the merge set. Do not approve or merge before that confirmation.

Completion: every discovered PR appears in the table under its lane, with a bump range.

## 3. Merge lane — approve, arm, shepherd

For each confirmed merge-lane PR:

```bash
gh pr review <n> -R <repo> --approve
gh pr merge <n> -R <repo> --squash --delete-branch --auto
```

Approve AND arm. An armed PR with no approval never merges - forgetting the approve is the classic slip.

Any repo that requires up-to-date branches with no merge queue merges as a **cascade**: each merge pushes its siblings BEHIND, and auto-merge will not fire on a BEHIND branch. Shepherd the cascade - loop until every merge-lane PR is MERGED, updating stragglers as they fall behind:

```bash
gh pr update-branch <n> -R <repo>   # for each still-open BEHIND PR, then wait for CI and repeat
```

CI takes minutes per round, so run the shepherd as a background command (Monitor an until-loop), not hand-polling.

Completion: every merge-lane PR reports MERGED - not merely "auto-merge armed". Verify each; the one recurring failure is walking away at "armed" and leaving BEHIND branches stalled.

## Other lanes

- **fix** — a non-major PR with failing CI: see `fixing-failing-ci.md`.
- **hold** — on request, investigate a held major's breaking changes: see `investigating-majors.md`. Otherwise report the held majors and move on.
