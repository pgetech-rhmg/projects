# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-03-17

### Added
- Added the code from lz-ptr repo

### Changed
- Enhanced tagging logic with `local.module_tags` for consistent tag management

### Fixed
- N/A

### Security
- N/A

## [0.1.0] - 2026-02-24


### Added
- Initial release of subscription-vending module
- Azure subscription creation using the Subscription Alias API
- Support for Enterprise Agreement (EA) billing
- Management group association for subscription placement
- Tag flattening logic for Azure compliance
- Workspace info integration via `ws` module for consistent tagging
- Output variables for subscription ID, name, and details

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
## [0.1.1] - 2026-02-15
### Fixed
- Fixed variable validation for bucket_name
- Corrected documentation typo in README
```

**Minor Example (0.1.1 → 0.2.0):**
```
## [0.2.0] - 2026-02-20
### Added
- Added support for cross-region replication
- New optional variable: replication_configuration
- New output: replication_status
```

**Major Example (0.2.0 → 1.0.0):**
```
## [1.0.0] - 2026-03-01
### Changed
- BREAKING: Renamed variable `bucket_name` to `name`
- BREAKING: Changed KMS encryption to be enabled by default
### Removed
- BREAKING: Removed deprecated