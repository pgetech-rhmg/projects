# Changelog

All notable changes to the Cosmos DB Metric Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-30

### Added
- Initial release of Cosmos DB metric alerts module
- Availability monitoring (ServiceAvailability metric)
- Performance monitoring:
  - Server side latency tracking
  - RU consumption monitoring
  - Normalized RU consumption percentage
- Request monitoring:
  - Total requests tracking
  - Metadata requests monitoring
- Capacity monitoring:
  - Data usage tracking
  - Index usage monitoring
  - Provisioned throughput alerts
- Diagnostic settings support:
  - Event Hub integration for activity logs
  - Log Analytics integration for security logs
  - Cross-subscription support for diagnostic destinations
- Feature flags for enabling/disabling alert categories:
  - Availability alerts
  - Performance alerts
  - Error alerts
  - Capacity alerts
- Comprehensive examples:
  - Production environment with strict thresholds
  - Development environment with relaxed thresholds
  - Basic configuration with defaults
- Module outputs:
  - Alert IDs and names
  - Diagnostic settings information
  - Monitored Cosmos DB accounts list
  - Action group ID
- Variable validation for:
  - Resource group names
  - Action group configuration
  - Cosmos DB account names
  - Threshold bounds (percentages, latency, RU limits)
- Support for monitoring multiple Cosmos DB accounts
- Configurable alert thresholds for all metrics
- Tags support for all resources

### Configuration
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

### Notes
- All alerts use the Microsoft.DocumentDB/databaseAccounts metric namespace
- Diagnostic settings support cross-subscription Event Hub and Log Analytics
- Alert creation is conditional based on cosmos_account_names list
- Empty cosmos_account_names disables all alert creation
- Module follows Azure Monitor Baseline Alerts (AMBA) best practices
