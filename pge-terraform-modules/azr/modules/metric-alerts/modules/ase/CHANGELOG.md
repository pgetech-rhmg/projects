# Changelog

All notable changes to the Azure App Service Environment AMBA Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-30

### Added
- Initial release of Azure App Service Environment (ASE) AMBA (Azure Monitor Baseline Alerts) module
- Support for 16 metric alert types:
  - **CPU Percentage**: Monitors ASE CPU utilization
  - **Memory Percentage**: Tracks ASE memory usage
  - **Large App Service Plan Instances**: Monitors large worker instance count
  - **Medium App Service Plan Instances**: Tracks medium worker instance count
  - **Small App Service Plan Instances**: Monitors small worker instance count
  - **Total Front End Instances**: Tracks front-end instance count
  - **Data In**: Monitors inbound network traffic volume
  - **Data Out**: Monitors outbound network traffic volume
  - **Average Response Time**: Tracks request response time
  - **HTTP Queue Length**: Monitors request queue depth
  - **HTTP 4xx**: Tracks client error responses
  - **HTTP 5xx**: Monitors server error responses
  - **HTTP 401**: Unauthorized access attempts
  - **HTTP 403**: Forbidden access attempts
  - **HTTP 404**: Not found errors
  - **Total Requests**: Monitors overall request volume

### Features
- Customizable thresholds for all metrics
- Support for multiple App Service Environments in a single deployment
- Integration with Azure Monitor Action Groups for alert notifications
- Comprehensive tagging support
- Cross-subscription support for distributed architectures
- Configurable evaluation frequencies and time windows

### Diagnostic Settings
- Optional diagnostic settings for App Service Environments
- Support for dual-destination logging:
  - Log Analytics Workspace integration
  - Event Hub integration for SIEM/external systems
- Flexible configuration (both destinations, single destination, or disabled)
- Cross-subscription support for Log Analytics and Event Hub resources

### Outputs
- `alert_ids`: Map of all created metric alert resource IDs organized by alert type
- `alert_names`: Map of all created metric alert names organized by alert type
- `diagnostic_setting_ids`: Map of diagnostic setting resource IDs
- `diagnostic_setting_names`: Map of diagnostic setting names
- `monitored_ases`: Map of monitored App Service Environment resources
- `action_group_id`: Associated Action Group ID
- `ase_ids`: Map of App Service Environment resource IDs

### Examples
- **Production Deployment**: Full monitoring with strict thresholds and dual-destination diagnostics
- **Development Deployment**: Essential monitoring with relaxed thresholds and Log Analytics only
- **Basic Deployment**: Minimal monitoring without diagnostic settings

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure App Service Environment v3

### Documentation
- Comprehensive README with configuration guidelines
- Example configurations for different deployment scenarios
- Alert threshold recommendations
- Diagnostic settings configuration guide

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
