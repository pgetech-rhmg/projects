# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-26

### Added
- Initial release of Azure Dev Center module
- Support for creating Azure Dev Center resources for managed DevOps pool governance
- Support for creating Dev Center Project resources
- Automatic region validation and fallback to supported regions
- Dev Center resource with configurable naming based on partner name
- Dev Center Project with governance settings (SharedServices-Dev-Project)
- Four output variables: dev_center_id, dev_center_name, dev_center_project_id, dev_center_project_name
- Support for custom tags on all resources
- Integration with workspace-info module for tagging
- Configurable timeouts for create, update, and delete operations (45m/30m/30m)
- Region support for 26 Azure regions where Dev Center is available
- Automatic fallback to westus3 when requested region is not supported

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
  - Security updates
  - Performance improvements
