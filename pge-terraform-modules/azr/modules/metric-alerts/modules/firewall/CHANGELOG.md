# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Azure Firewall monitoring alerts module
- Health monitoring:
  - Firewall health state tracking with critical severity
- Capacity monitoring:
  - SNAT port utilization monitoring to prevent port exhaustion
  - Firewall throughput tracking for capacity planning
  - Latency monitoring for performance degradation detection
  - Data processed volume tracking
- Traffic monitoring:
  - Application rule hit count tracking
  - Network rule hit count tracking
- Comprehensive examples:
  - Production deployment with strict thresholds
  - Development deployment with relaxed thresholds
  - Basic deployment with defaults
- Module outputs for alert IDs, names, and monitored resources
- Variable validation for resource groups and action groups
- Configurable thresholds for all alert types
- Support for monitoring multiple Azure Firewalls
- Terraform Registry compatibility (versions.tf, outputs.tf, examples/)
- Full documentation and README

### Features
- 7 comprehensive metric alerts covering health, capacity, and traffic
- Flexible threshold configuration for different firewall SKUs
- Tag support for resource organization
- Action group integration for notifications
- Multi-firewall monitoring capability
- Per-firewall alert granularity

### Compatibility
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Firewall (Basic, Standard, and Premium SKUs)

### Notes
- No diagnostic settings support (Azure Firewall metrics only)
- Alerts created per firewall for granular monitoring
- Thresholds should be adjusted based on firewall SKU and traffic patterns
- SNAT port utilization is critical for preventing connection failures
