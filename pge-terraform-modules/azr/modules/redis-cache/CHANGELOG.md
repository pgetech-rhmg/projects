# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-24

### Added
- Initial release of Azure Redis Cache module
- Support for Basic, Standard, and Premium SKU tiers
- Configurable capacity and family settings
- TLS configuration with minimum version support
- Non-SSL port option (configurable)
- Public network access control
- Redis version selection
- Premium SKU features:
  - Availability zone support
  - Replica configuration (replicas_per_master)
  - Clustering with shard count
  - VNet integration via subnet_id
- Redis configuration options (maxmemory_policy)
- Comprehensive tagging support with PG&E standards
- Integration with workspace-info module for TFC workspace tracking
- Output values for Redis cache ID, hostname, SSL port, primary/secondary keys, and connection strings

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
