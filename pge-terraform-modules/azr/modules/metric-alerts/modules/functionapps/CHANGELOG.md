# Changelog

All notable changes to the Azure Function Apps Monitoring Module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure Function Apps monitoring module
- Comprehensive monitoring for Windows and Linux Function Apps
- 15 metric alert types covering execution, performance, errors, and resource utilization:
  - Function execution count monitoring
  - Function execution units (compute) tracking
  - Average memory working set alerts
  - Memory working set (peak) alerts
  - Average response time monitoring with warning threshold
  - Critical response time alerts
  - HTTP 5xx server error detection
  - HTTP 4xx client error detection
  - Total request volume monitoring
  - I/O read operations per second tracking
  - I/O write operations per second tracking
  - Private bytes memory consumption alerts
  - .NET Gen 0 garbage collection monitoring (Windows only)
  - .NET Gen 1 garbage collection monitoring (Windows only)
  - .NET Gen 2 garbage collection monitoring (Windows only)

### Features
- **Dual OS Support**: Separate monitoring for Windows and Linux Function Apps
- **OS-Specific Metrics**: .NET garbage collection alerts automatically scoped to Windows apps only
- **Alert Categories**: Four configurable alert categories for granular control
  - Function execution alerts (execution count, units)
  - Performance alerts (memory, response time, requests)
  - Error alerts (HTTP 4xx/5xx)
  - Resource alerts (I/O, private bytes, GC collections)
- **Diagnostic Settings**: Integrated log forwarding to EventHub and Log Analytics
  - Activity logs to EventHub for real-time streaming
  - Security logs to Log Analytics for advanced querying
  - Cross-subscription support for centralized logging
- **Flexible Configuration**: 15 customizable threshold variables
- **Configurable Time Windows**: Three evaluation frequencies and window durations
  - High frequency: 1-minute evaluation with 5-minute window
  - Medium frequency: 5-minute evaluation with 15-minute window
  - Low frequency: 15-minute evaluation with 1-hour window
- **Multi-Subscription Support**: Monitor Function Apps across different subscriptions
- **Action Group Integration**: Centralized alert notification management

### Diagnostic Settings
- **EventHub Integration**: Streams activity logs including
  - AppServiceAntivirusScanAuditLogs
  - AppServiceIPSecAuditLogs
  - AppServicePlatformLogs
- **Log Analytics Integration**: Sends security-focused logs including
  - AppServiceConsoleLogs
  - AppServiceHTTPLogs
  - AppServiceAuditLogs
  - AppServiceFileAuditLogs
  - AppServiceAppLogs
- **Cross-Subscription Support**: Optional subscription IDs for EventHub and Log Analytics in different subscriptions

### Examples
- Production deployment example with strict thresholds
  - 500 execution count threshold
  - 5000 execution units threshold
  - 512MB memory threshold
  - 3 HTTP 5xx errors threshold
  - 5s/10s response time thresholds
  - 50 I/O operations per second
  - Aggressive GC monitoring (50/25/5)
  - Cross-subscription diagnostic settings
- Development deployment example with relaxed thresholds
  - 2000 execution count threshold
  - 20000 execution units threshold
  - 1GB memory threshold
  - 10 HTTP 5xx errors threshold
  - 10s/20s response time thresholds
  - 200 I/O operations per second
  - Relaxed GC monitoring (200/100/20)
- Basic deployment example with minimal monitoring
  - Only error and performance alerts enabled
  - No execution or resource alerts
  - Simplified monitoring footprint

### Documentation
- Comprehensive README with usage examples
- Detailed alert type descriptions and thresholds
- Windows vs Linux metric availability matrix
- Diagnostic settings configuration guide
- Cross-subscription deployment patterns
- Alert category management guide
- Garbage collection monitoring best practices
- Troubleshooting guide

### Technical Details
- Terraform version requirement: >= 1.0
- AzureRM provider version: >= 3.0, < 5.0
- Dynamic resource creation based on OS-specific app lists
- Conditional alert creation based on enable flags
- Resource ID construction with subscription scoping
- Proper handling of empty app name lists
- Validation for critical variables (planned)

### Outputs
- `alert_ids`: List of all created alert resource IDs
- `alert_names`: List of all created alert names
- `monitored_windows_function_apps`: List of Windows Function Apps being monitored
- `monitored_linux_function_apps`: List of Linux Function Apps being monitored
- `monitored_subscriptions`: List of subscription IDs being monitored
- `action_group_id`: Resource ID of the action group used
- `diagnostic_settings`: Map of diagnostic setting configurations (if enabled)

### Variables
- 15 threshold variables with sensible defaults
- 4 alert category enable flags
- Separate Windows and Linux Function App name lists
- Subscription ID list for multi-subscription support
- 3 evaluation frequency options
- 3 window duration options
- 9 diagnostic settings configuration variables
- Cross-subscription diagnostic settings support

### Notes
- .NET garbage collection metrics (Gen 0/1/2) only available on Windows Function Apps
- All alerts use "GreaterThan" operator for threshold comparison
- Severity levels: 1 (Critical) for response time and resource issues, 2 (Warning) for errors
- Dynamic scoping ensures GC alerts only target Windows apps
- Diagnostic settings are optional and disabled by default
- Cross-subscription support requires appropriate RBAC permissions
