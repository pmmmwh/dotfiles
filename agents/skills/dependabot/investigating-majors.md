# Hold lane — investigate a major bump

Held majors are only investigated on request. The question is never "what changed" but "does what changed touch us".

## 1. Read the breaking changes

```bash
gh api repos/<upstream-owner>/<repo>/releases        # or the package's release notes
```

Read the BREAKING CHANGES between the current and target versions - skip additive changes.

## 2. Check our actual usage

Grep the codebase for each affected API, config key, or default. A breaking change that touches no call site of ours is zero-impact.

Two outcomes:

- **Zero-impact** — CI-action and base-image majors (e.g. actions/checkout, setup-node, or a runtime's base image) are safe once usage is verified: bare checkout, standard cache/version inputs, a pinned OS image, no `pull_request_target`/`workflow_run`. These can move to the merge lane.
- **Real work** — framework majors (e.g. a web framework, UI library, ORM, or validation library) need a migration. Report the breaking changes that hit us and sketch the migration; do not start it without a go-ahead.

## 3. Coupled majors

A major doesn't always declare its peer requirements in its own diff - the release notes, changelog, migration guide, or README are where a package states what else must move with it (e.g. a CSS framework's v4 requiring its class-merging helper's v3+ to support it). Whenever more than one major is held on the same repo, read each one's docs for such a stated constraint, not just the one you started with - the requirement can be named on either side of the pair. If one exists, land the coupled set together in one PR or stack, and note the coupling in the report.

Completion: a findings report classifying each held major as zero-impact or real-work, with affected call sites named, and every held major on the repo checked against the others for a stated peer-version constraint.
