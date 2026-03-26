# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-03-24

### Fixed
- Fixed Azure DevOps organization parallelism configuration to use `max_agents` instead of `max_parallel_jobs`
- Corrected parallelism value to match `maximumConcurrency` requirement for Azure DevOps Infrastructure
- Resolved "InvalidOrganizationCounts" error where organization parallelism must equal the pool's max agents

## [0.1.0] - 2026-03-03

### Added
- Initial release of Azure Managed DevOps Pool module
- Support for creating Azure-managed agent pools with auto-scaling
- No PAT required - uses Azure managed identity (MI2)
- Integration with Dev Center for pool governance
- Support for Azure DevOps organization and project configuration
- Configurable VM SKU and OS images for agents
- Network connectivity via subnet integration
- Stateless ephemeral agent profile
- Auto-scaling with configurable maximum concurrent agents
- User-assigned managed identity support
- Automatic agent pool registration in Azure DevOps
- Output variables for pool ID and ADO pool ID
- Dependency management for resource providers and managed identity

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

- **MINOR** (0.x.0): New features - backward compatible functionality
  - New optional variables
  - New outputs
  - New optional resources
  - Enhanced existing features

- **PATCH** (0.0.x): Bug fixes - backward compatible fixes
  - Bug fixes
  - Documentation updates
  - Performance improvements
  - Internal refactoring
