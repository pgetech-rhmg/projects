# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-19

### Added
- Initial release of Azure Cosmos DB module
- Support for Azure Cosmos DB account creation with SQL API
- RBAC-based authentication with disabled local authentication
- Configurable consistency levels (default: BoundedStaleness)
- Serverless and provisioned capacity modes
- Automatic backup configuration with Periodic backup policy
  - Configurable backup interval (60-1440 minutes)
  - Configurable retention period (48-720 hours)
  - Storage redundancy options (Local/Geo/Zone)
- SQL database and container provisioning
- Configurable partition key for containers
- Autoscale settings for provisioned capacity mode
- Public network access control (disabled by default)
- Lifecycle protection with `prevent_destroy` for production workloads
- Comprehensive tagging support with PG&E standards
- Integration with workspace-info module for TFC workspace tracking
- Output values for account ID, name, endpoint, database, container, and keys

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- RBAC-enabled by default for data plane operations
- Local authentication disabled to enforce Azure AD authentication
- Public network access disabled by default
- Lifecycle protection to prevent accidental resource deletion

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
