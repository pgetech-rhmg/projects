# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-30

### Added
- Initial release of Azure Monitor Action Groups Terraform module
- Support for creating multiple action groups
- Email receiver configuration
- Input validation for all variables
- Comprehensive examples (Production, Development, Regional)
- Outputs for action group IDs, names, and details
- Complete documentation with usage examples

### Features
- Multiple action groups from single configuration
- Email notification support with common alert schema
- Configurable enable/disable per action group
- Global location support
- Tag support for resource organization
- Production-ready default values

### Outputs
- `action_group_ids` - Map of action group names to resource IDs
- `action_group_names` - List of all action group names
- `action_group_short_names` - Map of names to short names
- `action_group_details` - Complete action group details

[1.0.0]: https://github.com/pgetech/azr-baselinealerts-ccoe/releases/tag/v1.0.0
