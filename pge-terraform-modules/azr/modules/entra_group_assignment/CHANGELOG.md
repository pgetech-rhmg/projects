# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-04

### Added

- Initial release of the Entra Group Assignment module
- `azurerm_role_assignment.read_only` resource for assigning **Reader** role to Entra groups at subscription scope
- `azurerm_role_assignment.read_write` resource for assigning **Contributor** role to Entra groups at subscription scope
- Support for multiple groups via `for_each` iteration using `toset()`
- Input variables:
  - `subscription_id` - Target Azure subscription ID
  - `read_only_groups` - List of Entra group principal IDs for Reader access
  - `read_write_groups` - List of Entra group principal IDs for Contributor access

### Security

- Role assignments scoped to subscription level only
- Principal type explicitly set to "Group" for security enforcement
