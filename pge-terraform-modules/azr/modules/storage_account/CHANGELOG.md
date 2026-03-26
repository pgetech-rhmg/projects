# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-02

### Added
- Initial release of Azure Storage Account module
- Support for creating Azure Storage Account with configurable:
  - Account tier, replication type, and account kind
  - Access tier and minimum TLS version
  - HTTPS-only enforcement and nested item public access control
- Support for network rules including:
  - Default action, bypass rules, IP rules, and subnet restrictions
- Blob service configuration with:
  - Versioning enabled
  - Delete retention policy (7 days)
  - Container delete retention policy (7 days)
- Creation of blob containers using AzAPI to avoid data-plane authentication issues
- Creation of file shares using AzAPI with configurable quotas
- Optional private endpoints for:
  - Blob subresource
  - File subresource (only when file shares are defined)
- Support for private DNS zone group associations for blob and file endpoints
- Integration with workspace-info module for standardized tagging (tfc_wsname, tfc_wsid)
- Automatic module-level tagging including `managed_by` and `resource_type`
- Output variables for storage account properties (name, ID, endpoints, connection string)
- Configurable tags merged across module, workspace, and user-provided tags

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

- **MAJOR** (x.0.0): Breaking changes — incompatible API changes  
- **MINOR** (0.x.0): New features — backward‑compatible additions  
- **PATCH** (0.0.x): Bug fixes — backward‑compatible fixes  
