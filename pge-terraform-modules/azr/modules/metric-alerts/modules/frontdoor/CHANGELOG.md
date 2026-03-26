# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Azure Front Door monitoring alerts module
- Support for both Front Door types:
  - Classic Front Door (Microsoft.Network/frontDoors)
  - Standard/Premium Front Door (Microsoft.Cdn/profiles)
- Performance monitoring alerts:
  - High response time tracking
  - Backend/origin health percentage monitoring
  - High request count detection
- Availability monitoring alerts:
  - High error rate tracking
  - Low availability detection
- Security monitoring alerts:
  - WAF blocked requests tracking
- Diagnostic settings support for:
  - Event Hub integration
  - Log Analytics integration
  - Cross-subscription diagnostic settings
- Alert category enablement flags:
  - Performance alerts toggle
  - Availability alerts toggle
  - Security alerts toggle
  - Cost alerts toggle
- Comprehensive examples:
  - Production deployment with Standard Front Door and all alerts
  - Development deployment with Classic Front Door and selective alerts
  - Basic deployment with defaults
- Module outputs for alert IDs, names, diagnostic settings, and monitored resources
- Variable validation for resource groups, action groups, and Front Door types
- Configurable thresholds for all alert types
- Support for monitoring multiple Front Door instances
- Cross-subscription resource support
- Terraform Registry compatibility (versions.tf, outputs.tf, examples/)
- Full documentation and README

### Features
- 6 comprehensive metric alerts covering performance, availability, and security
- Flexible alert category enablement for different environments
- Dual Front Door type support with automatic metric namespace handling
- Customizable thresholds for all metrics
- Optional diagnostic settings with Event Hub and Log Analytics support
- Tag support for resource organization
- Action group integration for notifications
- Multi-Front Door monitoring capability
- Per-Front Door alert granularity
- Multi-subscription support for enterprise scenarios

### Compatibility
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Front Door Classic (Microsoft.Network/frontDoors)
- Azure Front Door Standard/Premium (Microsoft.Cdn/profiles)

### Notes
- Supports both Classic and Standard/Premium Front Door types
- Microsoft recommends migrating from Classic to Standard/Premium
- Diagnostic settings provide comprehensive logging for troubleshooting
- Thresholds should be tuned based on traffic patterns and SLA requirements
- Backend health is critical for user experience monitoring
- WAF alerts require WAF policy configuration on Front Door
