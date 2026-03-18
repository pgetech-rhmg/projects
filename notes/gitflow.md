# Gitflow Best Practices

## Branch Purposes
- `main` - production only, always clean, always deployable
- `develop` - integration point for all feature work
- `feature/*` - individual efforts, always cut from `develop`
- `release/*` - stabilization only, cut from `develop` when ready to ship
- `hotfix/*` - emergency fixes only, cut from `main`

## Rules
- Engineers cut feature branches from `develop`. Always.
- Never cut feature branches from `main` or `release`
- Release branches are for stabilization only - no new features
- Hotfixes go to both `main` and `develop`, every time
- Tag `main` on every release and hotfix merge
- Merge `release` back to `develop` after it ships
- Rebase feature branches against `develop` frequently - don't let them drift

## The One Exception
- Cutting from a release branch is only valid if it contains unreleased work your feature depends on and it hasn't landed in `develop` yet - and that's a sign your integration timing needs fixing