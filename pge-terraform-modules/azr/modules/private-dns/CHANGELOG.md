# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-05

### Added
- Initial release of Azure Private DNS Zone module
- Support for creating one or more Azure Private DNS Zones via `dns_zones` list variable
- Support for creating Virtual Network Links for each DNS zone to a specified VNet
- `registration_enabled` defaults to `false` for all VNet links
- `lifecycle { ignore_changes = all }` on VNet links to prevent drift on externally managed associations
- Three output variables: `dns_zone_ids`, `dns_zone_names`, `vnet_link_ids`
- Support for custom tags on all resources with automatic `managed_by` and `service` tag enrichment
- Integration with workspace-info module for `tfc_wsname` and `tfc_wsid` tagging
- `local.module_tags` for consistent module-level tagging across all resources

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
