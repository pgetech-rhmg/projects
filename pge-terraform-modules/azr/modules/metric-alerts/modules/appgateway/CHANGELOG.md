# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-29

### Added
- Initial release of Azure Application Gateway AMBA Alerts Terraform module
- 11 comprehensive metric alerts covering capacity, performance, health, and errors
- Support for both v1 (CPU-based) and v2 (Compute/Capacity Unit-based) SKUs
- Diagnostic settings support for both Log Analytics and Event Hub destinations
- Cross-subscription support for Event Hub and Log Analytics resources
- Flexible diagnostic settings (EventHub only, Log Analytics only, or both)
- Input validation for all variables
- Complete examples: basic, complete, and with-diagnostic-settings
- Outputs for alert IDs, names, and diagnostic settings
- Comprehensive README with usage examples and troubleshooting guide

### Alerts Included
- Compute Unit Utilization (v2 SKU) - Severity 2
- Capacity Unit Utilization (v2 SKU) - Severity 2
- Unhealthy Host Count - Severity 1
- Response Status 5xx - Severity 1
- Response Status 4xx - Severity 2
- Failed Requests - Severity 1
- Backend Response Time - Severity 2
- Application Gateway Total Time - Severity 2
- Backend Connect Time - Severity 2
- CPU Utilization (v1 SKU) - Severity 1
- Throughput - Severity 3

### Features
- Customizable thresholds for all alerts
- Configurable alert frequencies and window sizes
- Tag support for resource organization
- AMBA-compliant naming conventions
- Production-ready default values

[1.0.0]: https://github.com/pgetech/azr-baselinealerts-ccoe/releases/tag/v1.0.0
