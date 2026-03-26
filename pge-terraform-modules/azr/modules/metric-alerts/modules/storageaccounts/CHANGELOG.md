# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

#### Alert Capabilities
- **Availability Monitoring (1 alert)**:
  - Availability alert - monitors storage account availability percentage (severity 1)
  
- **Performance Monitoring (3 alerts)**:
  - E2E Latency alert - tracks end-to-end latency in milliseconds (severity 2)
  - Server Latency alert - monitors server-side latency in milliseconds (severity 2)
  - Transactions alert - tracks transaction rate per minute (severity 2)
  
- **Capacity Monitoring (1 alert)**:
  - Capacity alert - monitors storage capacity utilization percentage (severity 2)
  
- **Error Monitoring (1 alert)**:
  - Errors alert - tracks failed transactions and error rates (severity 2)

#### Multi-Account Support
- Support for monitoring multiple Storage Accounts in a single deployment
- Dynamic alert creation for each specified account
- Shared configuration across all accounts with individual resource targeting

#### Diagnostic Settings
- Storage Account to Event Hub - activity log streaming
- Storage Account to Log Analytics - security log collection
- Cross-subscription support for centralized logging
- Configurable Event Hub authorization rules
- Support for multiple accounts with individual diagnostic settings

#### Configuration
- Configurable alert thresholds:
  - `storage_availability_threshold` - availability percentage (default: 99%)
  - `storage_capacity_threshold` - capacity utilization (default: 90%)
  - `storage_transaction_threshold` - transactions per minute (default: 10000)
  - `storage_latency_threshold` - E2E latency in ms (default: 1000ms)
  - `storage_server_latency_threshold` - server latency in ms (default: 100ms)
- Conditional diagnostic settings with `enable_diagnostic_settings` flag
- Support for custom Event Hub authorization rules
- Configurable action group for alert notifications
- Comprehensive tagging support

#### Outputs
- **Alert Identification**:
  - `alert_ids` - map of all alert resource IDs by type
  - `alert_names` - map of all alert names by type
  
- **Resource Tracking**:
  - `monitored_resources` - map showing account IDs, names, and count
  - `action_group_id` - reference to the monitoring action group
  
- **Diagnostic Settings**:
  - `diagnostic_settings` - diagnostic setting resource IDs for Event Hub and Log Analytics
  
- **Configuration Summary**:
  - `alert_summary` - comprehensive summary including:
    - Total alert count (6 alerts)
    - Alert categories and counts (Availability: 1, Performance: 3, Capacity: 1, Error: 1)
    - Accounts monitored count
    - Configured thresholds for all metrics
    - Diagnostic settings status
    - Action group information

#### Documentation
- Comprehensive README with alert descriptions and configuration guidance
- Detailed examples directory with three deployment patterns:
  - Production example (99.9% availability, 500ms latency, 85% capacity, 3 accounts)
  - Development example (99% availability, 1000ms latency, 90% capacity, 2 accounts)
  - Basic example (95% availability, 2000ms latency, 95% capacity, 1 account)
- Variable validation and input descriptions
- Troubleshooting guide for common scenarios
- Example outputs for all deployment patterns

#### Technical Features
- Terraform >= 1.0 compatibility
- AzureRM provider >= 3.0, < 5.0 support
- Dynamic alert creation using `for_each` over account list
- Data source references to existing action groups and Storage Accounts
- Auto-mitigation enabled for performance alerts
- 5-minute evaluation frequency for all alerts
- PT15M window size for all metrics
- Cross-subscription diagnostic destinations
- Support for multiple accounts per deployment

### Requirements

#### Terraform Version
- Terraform >= 1.0

#### Provider Versions
- azurerm >= 3.0, < 5.0

#### Azure Permissions
- `Microsoft.Insights/metricAlerts/write` - create and manage metric alerts
- `Microsoft.Insights/diagnosticSettings/write` - configure diagnostic settings
- `Microsoft.Storage/storageAccounts/read` - read Storage Account properties
- `Microsoft.Insights/actionGroups/read` - read action group details
- `Microsoft.EventHub/namespaces/eventhubs/write` - Event Hub access (if using)
- `Microsoft.OperationalInsights/workspaces/write` - Log Analytics access (if using)

### Notes
- All 6 alerts are created for every Storage Account specified in `storage_account_names`
- Availability alert uses severity 1 for critical importance
- Other alerts use severity 2 for standard notifications
- Diagnostic settings are optional and controlled by `enable_diagnostic_settings` variable
- Module supports cross-subscription scenarios for Event Hub and Log Analytics
- Storage Account names must follow Azure naming rules (lowercase, alphanumeric, 3-24 characters)
- Action group must exist in Azure before module deployment
- Storage Accounts must exist in the specified resource group before module deployment
- Capacity thresholds may need adjustment based on storage account tier (Standard vs Premium)

[1.0.0]: https://github.com/your-org/terraform-azurerm-storageaccount-monitoring/releases/tag/v1.0.0
