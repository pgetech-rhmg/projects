# Changelog

All notable changes to the Azure Automation Account AMBA Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-30

### Added
- Initial release of Azure Automation Account AMBA (Azure Monitor Baseline Alerts) module
- Support for 7 activity log alert types:
  - **Automation Account Creation**: Monitors account creation operations
  - **Automation Account Deletion**: Monitors account deletion operations
  - **Runbook Operations**: Tracks runbook lifecycle operations
  - **Hybrid Worker Operations**: Monitors hybrid worker group operations
  - **Update Deployment Operations**: Tracks update deployment activities
  - **Webhook Operations**: Monitors webhook lifecycle operations
  - **Certificate Expiration**: Alerts on certificate expiration events

### Features
- Support for multiple Automation Accounts in a single deployment
- Activity log alerts for subscription-level operations
- Scheduled query rules for resource-specific monitoring
- Integration with Azure Monitor Action Groups for alert notifications
- Comprehensive tagging support
- Cross-subscription support for distributed architectures
- Configurable alert enable/disable flags for each alert type

### Diagnostic Settings
- Optional diagnostic settings for Automation Accounts
- Support for dual-destination logging:
  - Log Analytics Workspace integration
  - Event Hub integration for SIEM/external systems
- Flexible configuration (both destinations, single destination, or disabled)
- Cross-subscription support for Log Analytics and Event Hub resources

### Outputs
- `alert_ids`: Map of all created activity log alert resource IDs
- `alert_names`: Map of all created activity log alert names
- `diagnostic_setting_ids`: Map of diagnostic setting resource IDs
- `diagnostic_setting_names`: Map of diagnostic setting names
- `monitored_automation_accounts`: List of monitored Automation Account names
- `monitored_subscriptions`: List of subscription IDs being monitored
- `action_group_id`: Associated Action Group ID

### Examples
- **Production Deployment**: Full monitoring with all alerts and dual-destination diagnostics
- **Development Deployment**: Selective monitoring with critical alerts and Log Analytics only
- **Basic Deployment**: Minimal monitoring without diagnostic settings

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Automation Account

### Documentation
- Comprehensive README with configuration guidelines
- Example configurations for different deployment scenarios
- Alert configuration recommendations
- Diagnostic settings configuration guide

### Validation
- Input validation for resource names
- Conditional alert creation based on enable flags
- Support for empty resource lists to disable alerts

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
