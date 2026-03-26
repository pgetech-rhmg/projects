# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-09

### Added
- Initial release of identity module
- Azure User-Assigned Managed Identity creation using azapi
- Federated credential for Terraform Cloud authentication
- Federated credential for GitHub Actions authentication
- Automatic Contributor role assignment at subscription scope
- Support for additional RBAC role assignments from partner config
- Integration with workspace-info module for consistent tagging
- Tag management with pge_team, tfc_wsname, and tfc_wsid

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

## Semantic Versioning Guidelines

- **MAJOR** (x.0.0): Breaking changes - incompatible API changes
  - Renamed variables/outputs
  - Removed resources
  - Changed required inputs
  - Changed resource behavior significantly

- **MINOR** (0.x.0): New features - backward-compatible additions
  - New optional variables
  - New resources (non-breaking)
  - New outputs
  - Enhanced functionality

- **PATCH** (0.0.x): Bug fixes - backward-compatible fixes
  - Bug fixes
  - Documentation updates
  - Internal refactoring
  - Security patches

## Format Rules

1. Each version must have a date in YYYY-MM-DD format
2. Group changes under: Added, Changed, Deprecated, Removed, Fixed, Security
3. Link version numbers to git tags (optional but recommended)
4. Keep a link list at the bottom (optional)

## Examples

**Patch Example (0.1.0 → 0.1.1):**
```
## [0.1.1] - 2026-03-15
### Fixed
- Fixed federated credential subject format for GitHub Actions
- Corrected role assignment dependency ordering
```

**Minor Example (0.1.1 → 0.2.0):**
```
## [0.2.0] - 2026-03-20
### Added
- Added support for Azure DevOps federated credentials
- New optional variable: enable_devops_credential
- New output: devops_credential_id
```

**Major Example (0.2.0 → 1.0.0):**
```
## [1.0.0] - 2026-04-01
### Changed
- BREAKING: Renamed variable `subscription_id` to `target_subscription_id`
- BREAKING: Changed default role from Contributor to Reader
### Removed
- BREAKING: Removed deprecated `github_branch` variable (now uses subject pattern)
```