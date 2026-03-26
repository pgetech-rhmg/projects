# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0-beta] - 2026-03-19

### Changed
- **BREAKING**: Removed embedded provider configurations (`azurerm` and `azapi`) from module
  - Module now expects provider configurations to be passed by the caller
  - Resolves incompatibility with `count`, `for_each`, and `depends_on` arguments
  - Enables dynamic module instantiation in calling configurations
- Updated version to 0.1.0-beta in preparation for next release

### Fixed
- Fixed legacy module limitations that prevented use with `for_each` loops
- Resolved "Module is incompatible with count, for_each, and depends_on" errors

## [0.1.0] - 2026-03-11


### Added
- Initial release of the **Azure Hub‑Peering Terraform Module**.
- Created bidirectional VNet peering using AzAPI:
  - Partner → Hub peering (`azapi_resource.partner_to_hub`)
  - Hub → Partner peering (`azapi_resource.hub_to_partner`)
- Added support for:
  - `allowVirtualNetworkAccess`
  - `allowForwardedTraffic`
  - `allowGatewayTransit`
  - `useRemoteGateways`
- Implemented variable inputs for hub/spoke VNet configurations.
- Implemented outputs for peering names, IDs, and status summary.
- Added dependency ordering to ensure correct Azure peering synchronization.
- Added workspace‑info module integration for automation metadata.

---

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
