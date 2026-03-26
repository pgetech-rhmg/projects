# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Event Grid Namespace monitoring alerts module
- MQTT monitoring alerts:
  - Published messages volume tracking
  - Failed publish attempts monitoring
  - Active connections monitoring
- HTTP monitoring alerts:
  - Published events volume tracking
  - Failed publish attempts monitoring
- Delivery monitoring alerts:
  - Failed delivery attempts tracking
  - Successful delivery attempts tracking
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
- Support for monitoring multiple Event Grid namespaces
- Terraform Registry compatibility (versions.tf, outputs.tf, examples/)
- Full documentation and README

### Features
- Flexible alert enablement (each alert can be independently enabled/disabled)
- Customizable thresholds for all metrics
- Optional diagnostic settings with Event Hub and Log Analytics support
- Tag support for resource organization
- Action group integration for notifications
- Multi-namespace monitoring capability

### Compatibility
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Event Grid Namespace (MQTT and HTTP messaging support)
