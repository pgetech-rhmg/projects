# AI Disclosure for Committed Code

## Goal

Capture whether AI helped produce code that lands in GitHub. Committed files only. Uncommitted files are out of scope.

## The Model

This is attestation, not detection. You can't reliably detect AI authorship from content, so don't try. Instead you require a disclosure at the points you control, and you make a missing disclosure a policy violation.

## Two Pieces, Two Jobs

**Git hook - capture (advisory)**

A `prepare-commit-msg` or `commit-msg` hook in the repo's `.githooks` directory prompts for the AI trailer at commit time. It works the same for IDE users and CLI/bash committers. Its job is to make doing the right thing easy.

Limits: it's client-side. It only runs if installed (`git config core.hooksPath .githooks`, or baked into the managed dev image), and it's bypassable with `git commit --no-verify`. So it's a nudge, not a wall.

**PR check - enforcement (the gate)**

A required status check (a GitHub Action plus branch protection / ruleset) reads the commit trailers on the PR and fails when the disclosure is missing. It runs server-side, so it can't be skipped with `--no-verify`. No trailer, no merge. This is the deterministic gate.

Note: on GitHub cloud you can't install a custom `pre-receive` hook, so enforcement is the Action plus branch protection. On GitHub Enterprise Server you could use `pre-receive`, but the Action route is cleaner.

## The Trailer

Use a standard git trailer so it travels with the commit:

```
AI-Assisted: yes
AI-Tool: claude-code
```

Or, when none was used:

```
AI-Assisted: no
```

(`Co-authored-by:` works as a carrier too, but a dedicated trailer is clearer to parse.)

## What to Build

1. Add the hook to `.githooks` and install it through the managed dev image so every developer gets it automatically.
2. Add a GitHub Action that parses commit trailers on every PR and fails when `AI-Assisted` is missing.
3. Turn on branch protection / a ruleset that makes that check required to merge.

## The Limit

Attestation proves disclosure, not truth. You can't technically prove someone who marked `AI-Assisted: no` was lying. That's a policy and accountability matter, handled the same way you'd handle a forged sign-off or a falsified SBOM. Anyone asking for technical proof of AI authorship from content is asking for something that doesn't exist.