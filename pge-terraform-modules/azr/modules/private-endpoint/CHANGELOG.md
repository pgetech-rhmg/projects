# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-25

### Added
- Initial release of private-endpoint module

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
- BREAKING: Removed deprecated `acl` variable
```

## Tips for AI-Assisted CHANGELOG Generation

When using an AI assistant to help generate or update your CHANGELOG:

1. **Provide Context**: Share your git diff or list of changes made
2. **Specify Version Type**: Indicate if this is a patch, minor, or major update
3. **Example Prompt**:
   ```
   I've made the following changes to my Terraform module:
   - Added new variable "enable_versioning" (boolean)
   - Fixed bug in bucket policy attachment

   Please update my CHANGELOG.md with these changes as a minor version bump (0.1.0 -> 0.2.0).
   ```

4. **Review Output**: Always review the AI-generated changelog for accuracy
5. **Follow Format**: Ensure the output matches the template format above
6. **Be Specific**: Use clear, descriptive language for each change
7. **Group Properly**: Place changes under the correct category (Added,