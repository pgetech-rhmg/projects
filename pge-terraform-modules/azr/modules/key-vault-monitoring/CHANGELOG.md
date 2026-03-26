# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-25

### Added
- Initial release of Azure Key Vault Monitoring module
- Comprehensive metric alerts for Key Vault health monitoring
  - Availability alerts (default threshold: 99.9%)
  - Service API latency alerts (default threshold: 1000ms)
  - Service API hit rate monitoring
  - Service API result error tracking
  - Saturation monitoring
  - Authentication failure detection
  - Request throttling detection
- Activity log alerts for critical operations
  - Access policy change tracking
  - Key Vault deletion alerts
  - Key/Secret/Certificate operation monitoring
- Diagnostic settings integration
  - Event Hub streaming for activity logs
  - Log Analytics workspace integration
  - Cross-subscription resource support
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
- Severity levels configured appropriately (1-3)
- Alert frequencies optimized for real-time detection
- Integration with PGE action groups for notifications

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
