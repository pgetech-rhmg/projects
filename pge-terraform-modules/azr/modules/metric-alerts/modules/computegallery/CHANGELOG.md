# Changelog

All notable changes to the Azure Compute Gallery AMBA Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-30

### Added
- Initial release of Azure Compute Gallery AMBA (Azure Monitor Baseline Alerts) module
- Support for 6 activity log alert types:
  - **Gallery Creation**: Monitors Compute Gallery creation operations
  - **Gallery Deletion**: Monitors Compute Gallery deletion operations
  - **Image Definition Operations**: Tracks image definition lifecycle operations
  - **Image Version Operations**: Monitors image version create/update/delete
  - **Sharing Profile Changes**: Tracks sharing configuration modifications
  - **Access Control Changes**: Monitors RBAC and permission changes

### Features
- Subscription-level activity log alerts for Compute Gallery operations
- Configurable alert enable/disable flags for each alert type
- Integration with Azure Monitor Action Groups for alert notifications
- Comprehensive tagging support
- Support for monitoring multiple subscriptions
- Global scope for activity log alerts

### Outputs
- `alert_ids`: Map of all created activity log alert resource IDs
- `alert_names`: Map of all created activity log alert names
- `monitored_subscriptions`: List of subscription IDs being monitored
- `action_group_id`: Associated Action Group ID

### Examples
- **Production Deployment**: Full monitoring with all alerts enabled
- **Development Deployment**: Selective monitoring with critical alerts only
- **Basic Deployment**: Standard monitoring with default settings

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure subscription with appropriate permissions

### Documentation
- Comprehensive README with configuration guidelines
- Example configurations for different deployment scenarios
- Alert type descriptions and use cases
- Best practices for Compute Gallery monitoring

### Validation
- Input validation for resource names
- Subscription ID format validation
- Conditional alert creation based on enable flags

### Notes
- No diagnostic settings support (Compute Gallery does not support diagnostic settings)
- Activity log alerts operate at subscription level
- Requires at least one subscription ID to create alerts

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
