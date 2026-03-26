# Changelog

All notable changes to the Azure Application Insights AMBA Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure Application Insights AMBA (Azure Monitor Baseline Alerts) module
- Support for 10 metric alert types:
  - **Availability**: Monitors application availability percentage
  - **Response Time**: Tracks overall request response time
  - **Server Response Time**: Monitors server-side processing time
  - **Dependency Duration**: Tracks external dependency call duration
  - **Page View Load Time**: Monitors client-side page load performance
  - **Exception Rate**: Tracks application exception frequency
  - **Failed Requests**: Monitors HTTP request failure rate
  - **Dependency Failure Rate**: Tracks external dependency failures
  - **Request Rate**: Monitors request volume trends
  - **Page View Count**: Tracks page view volume patterns

### Features
- Configurable alert categories with granular enable/disable controls:
  - `enable_availability_alerts`: Control availability monitoring
  - `enable_performance_alerts`: Control response time and latency alerts
  - `enable_error_alerts`: Control exception and failure alerts
  - `enable_usage_alerts`: Control request rate and page view alerts
  - `enable_dependency_alerts`: Control external dependency monitoring
- Customizable thresholds for all metrics
- Configurable evaluation frequencies (high/medium/low priority)
- Adjustable time windows for metric aggregation
- Support for multiple Application Insights instances in a single deployment
- Integration with Azure Monitor Action Groups for alert notifications
- Comprehensive tagging support
- Cross-subscription support for distributed architectures

### Diagnostic Settings
- Optional diagnostic settings for metric alerts
- Support for dual-destination logging:
  - Log Analytics Workspace integration
  - Event Hub integration for SIEM/external systems
- Flexible configuration (both destinations, single destination, or disabled)
- Cross-subscription support for Log Analytics and Event Hub resources

### Outputs
- `alert_ids`: Map of all created metric alert resource IDs
- `alert_names`: Map of all created metric alert names  
- `diagnostic_setting_ids`: Map of diagnostic setting resource IDs
- `diagnostic_setting_names`: Map of diagnostic setting names
- `monitored_application_insights`: Map of monitored Application Insights resources
- `action_group_id`: Associated Action Group ID
- `application_insights_ids`: Map of Application Insights resource IDs

### Examples
- **Production Deployment**: Full monitoring with strict thresholds and dual-destination diagnostics
- **Development Deployment**: Selective monitoring with relaxed thresholds and Log Analytics only
- **Basic Deployment**: Essential monitoring without diagnostic settings

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

### Documentation
- Comprehensive README with configuration guidelines
- Example configurations for different deployment scenarios
- Alert threshold recommendations
- Diagnostic settings configuration guide

### Validation
- Input validation for resource names
- Threshold boundary validation
- List size validation for Application Insights names

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
