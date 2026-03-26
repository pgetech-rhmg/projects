# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Event Hub monitoring alerts module
- Request monitoring alerts:
  - Incoming requests volume tracking
  - Successful requests low threshold monitoring
- Error monitoring alerts:
  - Server errors detection
  - User errors tracking
  - Throttled requests monitoring
  - Quota exceeded alerts
- Message throughput alerts:
  - Incoming messages volume tracking
  - Outgoing messages volume tracking
- Data throughput alerts:
  - Incoming bytes monitoring
  - Outgoing bytes monitoring
- Connection monitoring alerts:
  - Active connections tracking
  - Connections opened monitoring
  - Connections closed monitoring
- Capacity monitoring:
  - Event Hub size tracking for storage management
- Diagnostic settings support for:
  - Event Hub integration
  - Log Analytics integration
  - Cross-subscription diagnostic settings
- Comprehensive examples:
  - Production deployment with all alerts enabled
  - Development deployment with selective alerts
  - Basic deployment with defaults
- Module outputs for alert IDs, names, and diagnostic settings
- Variable validation for resource groups and action groups
- Configurable thresholds for all alert types
- Support for monitoring multiple Event Hub namespaces
- Support for monitoring individual Event Hubs within namespaces
- Terraform Registry compatibility (versions.tf, outputs.tf, examples/)
- Full documentation and README

### Features
- Flexible alert enablement (each alert can be independently enabled/disabled)
- Customizable thresholds for all 14 metric types
- Optional diagnostic settings with Event Hub and Log Analytics support
- Tag support for resource organization
- Action group integration for notifications
- Multi-namespace and multi-Event Hub monitoring capability
- Cross-subscription support for diagnostic destinations

### Compatibility
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Event Hub (all tiers)
