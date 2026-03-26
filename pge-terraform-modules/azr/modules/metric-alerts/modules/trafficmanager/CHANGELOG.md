# Changelog

All notable changes to the Azure Traffic Manager Monitoring module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure Traffic Manager Monitoring module
- **Metric Alerts**:
  - Endpoint Health Alert (Severity 1) - Monitors healthy endpoint count
  - Probe Agent Endpoint State Alert (Severity 2) - Monitors endpoint state changes
- **Activity Log Alerts**:
  - Traffic Manager Creation Alert - Monitors profile creation events
  - Traffic Manager Deletion Alert - Monitors profile deletion events
  - Traffic Manager Configuration Change Alert - Monitors config modifications
  - Endpoint Operations Alert - Monitors endpoint lifecycle operations
- **Scheduled Query Rules**:
  - DNS Resolution Failure Alert (Severity 1) - Detects DNS resolution issues
  - Endpoint Health Degradation Alert (Severity 2) - Monitors health trend degradation
- **Diagnostic Settings**:
  - Event Hub integration for SIEM and external log streaming
  - Log Analytics integration for centralized logging and analysis
  - ProbeHealthStatusEvents log category support
  - AllMetrics support for Log Analytics destination
- **Features**:
  - Multi-profile monitoring support via `traffic_manager_profile_names` list
  - Cross-subscription support for Event Hub and Log Analytics workspaces
  - Subscription-level activity log monitoring via `subscription_ids` list
  - Configurable alert thresholds for endpoint health and probe agent state
  - Flexible time windows and evaluation frequencies (PT1M to PT2H)
  - Selective alert enablement via feature flags
  - Comprehensive outputs including alert IDs, diagnostic settings, and configuration summary
  - Support for custom tags on all alert resources
- **Examples**:
  - Production multi-region Traffic Manager with full monitoring
  - Development Traffic Manager with selective monitoring
  - Basic/test Traffic Manager with minimal monitoring
  - Cross-subscription diagnostic settings configuration
  - Cost-optimized configurations for different environments
- **Documentation**:
  - Comprehensive README with usage instructions
  - Detailed examples with multiple deployment patterns
  - Alert descriptions and threshold guidance
  - Troubleshooting guide for common issues
  - Cost optimization recommendations

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Existing Azure Traffic Manager profiles
- Pre-configured Azure Monitor Action Group
- Optional: Event Hub namespace and Event Hub for SIEM integration
- Optional: Log Analytics workspace for centralized logging

### Configuration
- **Alert Categories**:
  - Endpoint Health Monitoring (2 metric alerts)
  - Lifecycle Management (4 activity log alerts)
  - Advanced Monitoring (2 scheduled query rules)
  - Diagnostic Logging (2 diagnostic settings)
- **Supported Metrics**:
  - ProbeAgentCurrentEndpointStateByProfileResourceId
- **Supported Log Categories**:
  - ProbeHealthStatusEvents
- **Default Thresholds**:
  - Endpoint Health: < 1 healthy endpoint (Severity 1)
  - Probe Agent State: Average < 1 (Severity 2)
- **Default Time Windows**:
  - Short: PT5M
  - Medium: PT15M
  - Long: PT1H
- **Default Evaluation Frequencies**:
  - High: PT1M
  - Medium: PT5M
  - Low: PT15M

### Notes
- Activity log alerts and scheduled query rules require `subscription_ids` to be provided
- All alerts disabled if `traffic_manager_profile_names` is empty
- Diagnostic settings support both same-subscription and cross-subscription configurations
- Event Hub diagnostic setting includes only logs (metrics disabled)
- Log Analytics diagnostic setting includes both logs and metrics
- Each Traffic Manager profile gets individual metric alerts and diagnostic settings
- Activity log alerts and scheduled query rules are created once per module instance
