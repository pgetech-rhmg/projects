# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-03-23

### Changed
- **Breaking**: Changed output key structure to use `subscription_name` instead of `partner_name` for consistency
  - `approved_partner_configs` now keyed by `subscription_name`
  - `finops_validation_status` now keyed by `subscription_name`
  - `finops_mismatches` now uses `subscription_name` field instead of `partner_name`
- Improved alignment with subscription-based resource naming throughout infrastructure
- Enhanced consistency in downstream resource references

### Fixed
- Improved data structure consistency for better integration with subscription-based workflows

## [0.1.0] - 2026-03-11

### Added
- Initial release of FinOps Validation module
- CSV parsing logic for AppID and Order# extraction
- Partner configuration validation against approved combinations
- Comprehensive validation status reporting
- Detailed mismatch identification with specific failure reasons
- Approved partner filtering for downstream vending operations
- Complete example with terraform.auto.tfvars
- Comprehensive documentation

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- Module performs read-only validation without resource creation
- No external API calls or sensitive data exposure

---

## Semantic Versioning Guidelines

- **MAJOR** (x.0.0): Breaking changes - incompatible API changes
  - Renamed variables/outputs
  - Removed resources
  - Changed required inputs
  - Changed resource behavior significantly

- **MINOR** (0.x.0): New features - backward-compatible additions
  - New optional variables
  - New outputs
  - Enhanced validation logic
  - Bug fixes that don't affect API

- **PATCH** (0.0.x): Small fixes - backward-compatible bug fixes
  - Logic improvements
  - Documentation updates
  - Minor refactoring

## Release Process

1. Update this CHANGELOG file
2. Update version in module.info
3. Create a git tag: `git tag azr/finops_validation/v0.x.x`
4. Push changes and tag: `git push origin --tags`
