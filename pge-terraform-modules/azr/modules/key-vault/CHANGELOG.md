# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-25

### Added
- Initial release of Azure Key Vault module
- Azure Key Vault resource with full configuration support
- Network ACLs with dynamic block support
- RBAC authorization capabilities
- Soft delete and purge protection options
- Disk encryption and deployment options
- SAF2.0 compliance tagging via workspace-info module
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
- RBAC authorization enabled by default (recommended)
- Network ACLs support for restricting access
- Proper variable validation for SKU types

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
