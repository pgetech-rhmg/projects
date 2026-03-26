# Changelog

All notable changes to the Azure Connection Monitor AMBA Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-30

### Added
- Initial release of Azure Connection Monitor AMBA (Azure Monitor Baseline Alerts) module
- Support for 6 metric alert types:
  - **Checks Failed Warning**: Warning when connectivity checks exceed threshold
  - **Checks Failed Critical**: Critical alert for high percentage of failed checks
  - **Latency Warning**: Warning when round-trip time exceeds threshold
  - **Latency Critical**: Critical alert for excessive latency
  - **Test Result Failed**: Alert when test results show failures
  - **Test Result Warning**: Warning for degraded test results

### Features
- Customizable thresholds for connectivity checks and latency
- Support for multiple Connection Monitors in a single deployment
- Separate warning and critical threshold levels
- Near real-time monitoring with PT1M evaluation frequency
- Integration with Azure Monitor Action Groups for alert notifications
- Comprehensive tagging support
- Resource ID-based monitoring for precise alert targeting

### Monitoring Capabilities
- **Connectivity Monitoring**: Track percentage of failed connectivity checks
- **Latency Monitoring**: Monitor round-trip time in milliseconds
- **Test Results**: Alert on test execution outcomes
- **Multi-threshold Alerting**: Separate warning and critical thresholds

### Outputs
- `alert_ids`: Map of all created metric alert resource IDs organized by alert type
- `alert_names`: Map of all created metric alert names organized by alert type
- `monitored_connection_monitors`: List of Connection Monitor resource IDs being monitored
- `action_group_id`: Associated Action Group ID

### Examples
- **Production Deployment**: Strict thresholds for production workloads
- **Development Deployment**: Relaxed thresholds for development environments
- **Basic Deployment**: Default thresholds for test environments

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Connection Monitor resource(s)
- Network Watcher deployed in the region

### Documentation
- Comprehensive README with configuration guidelines
- Example configurations for different deployment scenarios
- Alert threshold recommendations
- Connection Monitor resource ID format documentation

### Validation
- Input validation for resource names
- Connection Monitor resource ID format validation
- Threshold boundary validation

### Notes
- **No Diagnostic Settings**: Connection Monitor does not support diagnostic settings. Data is sent directly to the Log Analytics workspace configured in the Connection Monitor itself.
- Uses metric namespace `Microsoft.Network/networkWatchers/connectionMonitors`
- Alerts evaluate every minute for near real-time monitoring

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
