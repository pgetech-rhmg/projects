# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

#### Alert Capabilities
- **CPU Monitoring (2 alerts)**:
  - CPU Warning alert - monitors CPU utilization percentage at warning level (severity 2)
  - CPU Critical alert - monitors CPU utilization percentage at critical level (severity 1)
  
- **Storage Monitoring (2 alerts)**:
  - Storage Warning alert - tracks storage space utilization at warning level (severity 2)
  - Storage Critical alert - monitors storage space utilization at critical level (severity 1)
  
- **vCore Monitoring (1 alert)**:
  - vCore Warning alert - monitors virtual core utilization percentage (severity 2)

#### Multi-Instance Support
- Support for monitoring multiple SQL Managed Instances in a single deployment
- Dynamic alert creation for each specified instance
- Shared configuration across all instances with individual resource targeting

#### Diagnostic Settings
- SQL Managed Instance to Event Hub - activity log streaming
- SQL Managed Instance to Log Analytics - security log collection
- Cross-subscription support for centralized logging
- Configurable Event Hub authorization rules
- Support for multiple instances with individual diagnostic settings

#### Configuration
- Configurable alert thresholds:
  - `cpu_warning_threshold` - CPU warning level (default: 80%)
  - `cpu_critical_threshold` - CPU critical level (default: 90%)
  - `storage_warning_threshold` - storage warning level (default: 80%)
  - `storage_critical_threshold` - storage critical level (default: 90%)
- Configurable evaluation settings:
  - `evaluation_frequency` - alert evaluation frequency (default: PT5M)
  - `window_size` - evaluation window size (default: PT15M)
- Conditional diagnostic settings with `enable_diagnostic_settings` flag
- Support for custom Event Hub authorization rules
- Configurable action group for alert notifications
- Comprehensive tagging support

#### Outputs
- **Alert Identification**:
  - `alert_ids` - map of all alert resource IDs by type
  - `alert_names` - map of all alert names by type
  
- **Resource Tracking**:
  - `monitored_resources` - map showing instance IDs, names, and count
  - `action_group_id` - reference to the monitoring action group
  
- **Diagnostic Settings**:
  - `diagnostic_settings` - diagnostic setting resource IDs for Event Hub and Log Analytics
  
- **Configuration Summary**:
  - `alert_summary` - comprehensive summary including:
    - Total alert count (5 alerts)
    - Alert categories and counts (CPU: 2, Storage: 2, vCore: 1)
    - Instances monitored count
    - Configured thresholds for all metrics
    - Evaluation settings (frequency and window size)
    - Diagnostic settings status
    - Action group information

#### Documentation
- Comprehensive README with alert descriptions and configuration guidance
- Detailed examples directory with three deployment patterns:
  - Production example (70% CPU warning, 75% storage warning, 2 instances)
  - Development example (80% CPU warning, 80% storage warning, 1 instance)
  - Basic example (85% CPU warning, 85% storage warning, 1 instance)
- Variable validation and input descriptions
- Troubleshooting guide for common scenarios
- Example outputs for all deployment patterns

#### Technical Features
- Terraform >= 1.0 compatibility
- AzureRM provider >= 3.0, < 5.0 support
- Dynamic alert creation using count-based iteration
- Data source references to existing action groups and SQL Managed Instances
- Auto-mitigation enabled for all alerts
- Configurable evaluation frequency and window size
- Cross-subscription diagnostic destinations
- Support for multiple instances per deployment
- Severity differentiation (Warning: severity 2, Critical: severity 1)

### Requirements

#### Terraform Version
- Terraform >= 1.0

#### Provider Versions
- azurerm >= 3.0, < 5.0

#### Azure Permissions
- `Microsoft.Insights/metricAlerts/write` - create and manage metric alerts
- `Microsoft.Insights/diagnosticSettings/write` - configure diagnostic settings
- `Microsoft.Sql/managedInstances/read` - read SQL Managed Instance properties
- `Microsoft.Insights/actionGroups/read` - read action group details
- `Microsoft.EventHub/namespaces/eventhubs/write` - Event Hub access (if using)
- `Microsoft.OperationalInsights/workspaces/write` - Log Analytics access (if using)

### Notes
- All 5 alerts are created for every SQL Managed Instance specified in `sql_mi_names`
- CPU and Storage alerts have both warning and critical thresholds
- Critical alerts use severity 1 for higher priority notifications
- Warning alerts use severity 2 for standard notifications
- Diagnostic settings are optional and controlled by `enable_diagnostic_settings` variable
- Module supports cross-subscription scenarios for Event Hub and Log Analytics
- vCore alerts are only applicable to vCore-based purchasing model instances
- Action group must exist in Azure before module deployment
- SQL Managed Instances must exist in the specified resource group before module deployment
- Evaluation frequency and window size can be customized based on monitoring requirements

[1.0.0]: https://github.com/your-org/terraform-azurerm-sqlmi-monitoring/releases/tag/v1.0.0
