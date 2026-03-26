# Changelog

All notable changes to the Azure Key Vault Monitoring Module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-02

### Added
- Initial release of Azure Key Vault monitoring module
- Comprehensive monitoring for Azure Key Vault secrets management
- 7 metric alert types covering availability, performance, errors, and capacity:
  - Key Vault availability monitoring (service uptime)
  - Service API latency tracking (response times)
  - Service API hit rate monitoring (request volumes)
  - Service API result error detection (failed requests)
  - Saturation shoebox alerts (vault capacity limits)
  - Authentication failure detection
  - Throttling alerts (rate limiting events)

### Features
- **High Availability Monitoring**: Track Key Vault service availability with configurable thresholds
- **Performance Tracking**: Monitor API latency and request volumes for capacity planning
- **Error Detection**: Alert on API errors and authentication failures
- **Capacity Management**: Proactive monitoring of vault saturation limits
- **Security Monitoring**: Detect throttling events and suspicious access patterns
- **Diagnostic Settings**: Integrated log forwarding to EventHub and Log Analytics
  - Activity logs to EventHub for real-time streaming
  - Security logs to Log Analytics for advanced querying
  - Cross-subscription support for centralized logging
- **Flexible Configuration**: 5 customizable threshold variables
- **Multi-Vault Support**: Monitor multiple Key Vaults from a single module
- **Action Group Integration**: Centralized alert notification management

### Diagnostic Settings
- **EventHub Integration**: Streams Key Vault logs including
  - AuditEvent (all Key Vault operations)
  - AllMetrics (performance metrics)
- **Log Analytics Integration**: Sends audit and metric data
  - AuditEvent logs for compliance
  - AllMetrics for performance analysis
- **Cross-Subscription Support**: Optional subscription IDs for EventHub and Log Analytics in different subscriptions

### Examples
- Production deployment example with strict thresholds
  - 99.9% availability threshold
  - 500ms API latency threshold
  - 2000 API hit monitoring
  - 5 API error threshold
  - 75% saturation alerting
  - Cross-subscription diagnostic settings
- Development deployment example with relaxed thresholds
  - 95% availability threshold
  - 2000ms API latency threshold
  - 5000 API hit monitoring
  - 20 API error threshold
  - 85% saturation alerting
  - Same-subscription diagnostic settings
- Basic deployment example with default thresholds
  - Default threshold values (99.9%, 1000ms, etc.)
  - No diagnostic settings
  - Minimal monitoring footprint

### Documentation
- Comprehensive README with usage examples
- Detailed alert type descriptions and thresholds
- Diagnostic settings configuration guide
- Cross-subscription deployment patterns
- Best practices for Key Vault monitoring
- Security and capacity planning guidance
- Troubleshooting guide for common issues

### Technical Details
- Terraform version requirement: >= 1.0
- AzureRM provider version: >= 3.0, < 5.0
- Dynamic resource creation based on Key Vault name list
- Conditional diagnostic settings based on enable flags
- Resource ID construction with subscription scoping
- Proper handling of empty Key Vault name lists
- Data source lookups for Key Vault resources
- Validation for critical variables (planned)

### Outputs
- `alert_ids`: List of all created alert resource IDs
- `alert_names`: List of all created alert names
- `monitored_key_vaults`: List of Key Vault names being monitored
- `monitored_resource_group`: Resource group name where Key Vaults are located
- `action_group_id`: Resource ID of the action group used
- `diagnostic_settings`: Map of diagnostic setting configurations (if enabled)
- `alert_summary`: Summary counts of each alert type configured

### Variables
- 5 threshold variables with sensible defaults
  - `availability_threshold`: 99.9% (default)
  - `service_api_latency_threshold`: 1000ms (default)
  - `service_api_hit_threshold`: 1000 requests (default)
  - `service_api_result_threshold`: 10 errors (default)
  - `saturation_shoebox_threshold`: 75% (default)
- Key Vault name list for multi-vault monitoring
- 9 diagnostic settings configuration variables
- Cross-subscription diagnostic settings support
- Standard tag variables for resource management

### Alert Details
- **Availability Alert**: Severity 1 (Critical), 1-minute frequency, 5-minute window
- **Latency Alert**: Severity 2 (Warning), 5-minute frequency, 15-minute window
- **API Hit Alert**: Severity 3 (Informational), 5-minute frequency, 15-minute window
- **API Error Alert**: Severity 2 (Warning), 5-minute frequency, 15-minute window
- **Saturation Alert**: Severity 2 (Warning), 5-minute frequency, 15-minute window
- **Authentication Failure Alert**: Severity 2 (Warning), 5-minute frequency, 15-minute window
- **Throttling Alert**: Severity 2 (Warning), 5-minute frequency, 15-minute window

### Use Cases
- **Production Secrets Management**: High-availability monitoring for critical vaults
- **Compliance and Audit**: Comprehensive logging for regulatory requirements
- **Capacity Planning**: Proactive monitoring of vault limits and quotas
- **Security Operations**: Detection of authentication failures and throttling
- **Performance Optimization**: Latency tracking for API response times
- **Multi-Vault Deployments**: Centralized monitoring across multiple vaults

### Notes
- All alerts use appropriate operators (LessThan for availability, GreaterThan for errors)
- Diagnostic settings are optional and disabled by default
- Cross-subscription support requires appropriate RBAC permissions
- Module supports monitoring multiple Key Vaults simultaneously
- Alert names automatically include Key Vault name for identification
- Saturation monitoring helps prevent quota exhaustion
- Authentication failure alerts help detect security incidents
