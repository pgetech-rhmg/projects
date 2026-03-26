# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-09

### Added
- Initial release of Azure App Service Environment module
- Azure App Service Environment v3 resource
- Internal Load Balancing (ILB) mode support
- Automatic private DNS zone creation for ILB ASE
- VNet linking for private DNS resolution
- Hub-spoke DNS architecture support via DNS resolver VNet linking
- Automatic DNS A records for app endpoints, root domain, and SCM endpoints
- SAF2.0 compliance tagging via workspace-info module
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
- Network isolation via Internal Load Balancing mode
- Private DNS zone configuration for secure name resolution
- Proper lifecycle management for DNS zone VNet links

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
  - New optional resources
  - Enhanced functionality

- **PATCH** (0.0.x): Bug fixes - backward-compatible fixes
  - Bug fixes
  - Documentation updates
  - Internal refactoring
