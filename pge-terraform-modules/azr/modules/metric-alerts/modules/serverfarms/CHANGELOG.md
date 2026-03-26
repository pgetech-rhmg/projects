# Changelog

All notable changes to the Azure App Service Plan (Server Farms) Monitoring Module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure App Service Plan (Server Farms) monitoring module
- Comprehensive metric alerting for App Service Plans with 4 alert types:
  - **Performance Monitoring**:
    - CPU percentage monitoring across all instances
    - Memory percentage tracking across all instances
  - **Queue Management Monitoring**:
    - HTTP queue length monitoring for pending requests
    - Disk queue length tracking for pending I/O operations
- Diagnostic settings support with dual destination options:
  - Event Hub integration for activity logs and metrics
  - Log Analytics workspace integration for security logs and analysis
- Cross-subscription support for diagnostic destinations:
  - Event Hub can be in different subscription
  - Log Analytics workspace can be in different subscription
- Multi-instance monitoring with dynamic resource discovery using data sources
- Customizable thresholds for all metrics
- Action group integration for alert notifications
- Comprehensive tagging support for resource organization
- Three deployment examples:
  - Production: All alerts with tight thresholds (80%, 10 queue items)
  - Development: All alerts with relaxed thresholds (90%, 20 queue items)
  - Basic: All alerts with very relaxed thresholds (95%, 50 queue items)
- Module outputs:
  - Alert IDs and names by category
  - Monitored resource information
  - Action group details
  - Diagnostic settings IDs
  - Configuration summary
- Input validation for resource groups and action groups
- Terraform Registry-ready structure with versions.tf

### Supported Metrics
- **CpuPercentage**: Average CPU utilization percentage across all instances
- **MemoryPercentage**: Average memory usage percentage across all instances
- **HttpQueueLength**: Number of HTTP requests in the application queue
- **DiskQueueLength**: Number of pending I/O requests to the disk

### Features
- Multi-instance support: Monitor multiple App Service Plans with single module call
- Always-on alerting: All 4 alerts are created for every monitored App Service Plan
- Production-ready threshold defaults
- Cross-subscription diagnostic settings
- Comprehensive examples for different scenarios
- Full output exposure for integration with other modules
- Tag-based resource organization

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure App Service Plan (Microsoft.Web/serverfarms)
- Azure Monitor Action Group
- (Optional) Event Hub for activity logs
- (Optional) Log Analytics workspace for security logs

### Permissions Required
- `Microsoft.Insights/metricAlerts/write` - Create and manage metric alerts
- `Microsoft.Insights/metricAlerts/read` - Read metric alert configurations
- `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
- `Microsoft.Insights/diagnosticSettings/read` - Read diagnostic settings
- `Microsoft.Web/serverfarms/read` - Read App Service Plan properties
- `Microsoft.Insights/actionGroups/read` - Read action group details
- `Microsoft.EventHub/namespaces/read` - Read Event Hub namespace (if using)
- `Microsoft.OperationalInsights/workspaces/read` - Read Log Analytics workspace (if using)

### Documentation
- Comprehensive README with usage examples
- Detailed variable descriptions
- Output documentation
- Examples directory with three deployment patterns
- Alert threshold recommendations by environment type

### Notes
- All thresholds can be customized based on workload requirements
- Diagnostic settings are optional and can be disabled
- All 4 alerts are always created for monitored App Service Plans (no individual enable flags)
- Cross-subscription diagnostic destinations supported for centralized logging
- Module follows Azure Monitor best practices
- Alerts use 5-minute evaluation frequency by default
- Compatible with all App Service Plan tiers (Free, Shared, Basic, Standard, Premium, Isolated)

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
