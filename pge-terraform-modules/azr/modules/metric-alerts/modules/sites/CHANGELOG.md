# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

#### Alert Capabilities
- **Performance Monitoring (3 alerts)**:
  - Response Time (Warning) alert - monitors average response time with warning threshold
  - Response Time (Critical) alert - monitors average response time with critical threshold
  - CPU Time alert - tracks CPU time consumption per site
  
- **Availability Monitoring (3 alerts)**:
  - Availability alert - monitors site availability percentage
  - HTTP 4xx Errors alert - tracks client error responses per minute
  - HTTP 5xx Errors alert - monitors server error responses per minute
  
- **Throughput Monitoring (1 alert)**:
  - Request Rate alert - monitors incoming requests per minute
  
- **I/O Operations Monitoring (2 alerts)**:
  - IO Read Operations alert - monitors disk read operations per second (100 ops/sec threshold)
  - IO Write Operations alert - tracks disk write operations per second (100 ops/sec threshold)

#### Platform Support
- Dual platform support for both Windows and Linux App Service sites
- Separate site name lists: `windows_site_names` and `linux_site_names`
- Platform-specific diagnostic settings for each OS type

#### Diagnostic Settings
- Windows App Service to Event Hub - activity log streaming
- Windows App Service to Log Analytics - security log collection
- Linux App Service to Event Hub - activity log streaming
- Linux App Service to Log Analytics - security log collection
- Cross-subscription support for centralized logging
- Configurable Event Hub authorization rules
- Flexible log category configuration per OS type

#### Configuration
- Configurable alert thresholds for all 9 metrics:
  - `availability_threshold` - minimum availability percentage (default: 99%)
  - `response_time_threshold` - maximum response time in seconds (default: 5s)
  - `response_time_critical_threshold` - critical response time threshold (default: 10s)
  - `http_4xx_threshold` - maximum client errors per minute (default: 20)
  - `http_5xx_threshold` - maximum server errors per minute (default: 10)
  - `request_rate_threshold` - maximum requests per minute (default: 20000)
  - `cpu_time_threshold` - maximum CPU time in seconds (default: 120s)
- Fixed IO operations thresholds (100 ops/sec for both read and write)
- Conditional diagnostic settings with `enable_diagnostic_settings` flag
- Support for custom Event Hub authorization rules
- Configurable action group for alert notifications
- Comprehensive tagging support

#### Outputs
- **Alert Identification**:
  - `alert_ids` - map of all alert resource IDs by type
  - `alert_names` - map of all alert names by type
  
- **Resource Tracking**:
  - `monitored_resources` - map showing Windows and Linux site names separately
  - `action_group_id` - reference to the monitoring action group
  
- **Diagnostic Settings**:
  - `diagnostic_settings` - all four diagnostic setting resource IDs:
    - `windows_site_to_eventhub`
    - `windows_site_to_loganalytics`
    - `linux_site_to_eventhub`
    - `linux_site_to_loganalytics`
  
- **Configuration Summary**:
  - `alert_summary` - comprehensive summary including:
    - Total alert count (9 alerts)
    - Alert categories and counts (Performance: 3, Availability: 3, Throughput: 1, I/O: 2)
    - Platform breakdown (Windows sites, Linux sites, total sites)
    - Configured thresholds for all 9 metrics
    - Diagnostic settings status
    - Action group information

#### Documentation
- Comprehensive README with alert descriptions and configuration guidance
- Detailed examples directory with three deployment patterns:
  - Production example (99.5% availability, 3s response time, 2 Windows + 1 Linux sites)
  - Development example (98% availability, 5s response time, 1 Windows + 1 Linux sites)
  - Basic example (95% availability, 10s response time, 1 Windows site)
- Variable validation and input descriptions
- Troubleshooting guide for common scenarios
- Example outputs for all deployment patterns

#### Technical Features
- Terraform >= 1.0 compatibility
- AzureRM provider >= 3.0, < 5.0 support
- Dynamic alert creation using `for_each` over site lists
- Separate data sources for Windows and Linux App Service sites
- Data source references to existing action groups
- Auto-mitigation enabled for all performance and availability alerts
- 5-minute evaluation frequency for all alerts
- PT1M granularity for all metrics
- Cross-subscription diagnostic destinations
- Platform-specific log categories

### Requirements

#### Terraform Version
- Terraform >= 1.0

#### Provider Versions
- azurerm >= 3.0, < 5.0

#### Azure Permissions
- `Microsoft.Insights/metricAlerts/write` - create and manage metric alerts
- `Microsoft.Insights/diagnosticSettings/write` - configure diagnostic settings
- `Microsoft.Web/sites/read` - read App Service site properties
- `Microsoft.Insights/actionGroups/read` - read action group details
- `Microsoft.EventHub/namespaces/eventhubs/write` - Event Hub access (if using)
- `Microsoft.OperationalInsights/workspaces/write` - Log Analytics access (if using)

### Notes
- All 9 alerts are created for every site specified in `windows_site_names` and `linux_site_names`
- At least one of `windows_site_names` or `linux_site_names` must be provided
- IO operations thresholds are fixed at 100 ops/sec (not configurable via variables)
- Diagnostic settings are optional and controlled by `enable_diagnostic_settings` variable
- Windows and Linux sites have separate diagnostic settings due to different log categories
- Module supports cross-subscription scenarios for Event Hub and Log Analytics
- All alerts use severity level 2 (Warning) except Response Time Critical (severity 1)
- Action group must exist in Azure before module deployment
- App Service sites must exist in the specified resource group before module deployment

[1.0.0]: https://github.com/your-org/terraform-azurerm-sites-monitoring/releases/tag/v1.0.0
