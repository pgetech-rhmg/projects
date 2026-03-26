# Changelog

All notable changes to the Azure Monitor Resources Monitoring Module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-02

### Added
- Initial release of Azure Monitor resources monitoring module
- Comprehensive monitoring for Azure Monitor platform components
- 6 metric alert types covering workspace, App Insights, and DCR monitoring:
  - Log Analytics workspace data ingestion warning (50GB+ daily ingestion)
  - Log Analytics workspace data ingestion critical (100GB+ daily ingestion)
  - Application Insights availability monitoring
  - Application Insights response time tracking
  - Application Insights failed requests detection
  - Application Insights exception rate monitoring

### Features
- **Log Analytics Workspace Monitoring**: Track data ingestion with warning and critical thresholds
- **Application Insights Monitoring**: Comprehensive app health tracking
  - Availability monitoring with configurable uptime thresholds
  - Response time performance tracking
  - Failed request detection and alerting
  - Exception rate monitoring for code quality
- **Data Collection Rules Support**: Monitor DCR health and data pipeline
- **Multi-Resource Monitoring**: Monitor multiple workspaces and App Insights from single module
- **Alert Categories**: Five configurable alert categories for granular control
  - Workspace alerts (data ingestion, query performance)
  - Application Insights alerts (availability, performance, errors)
  - Data Collection Rule alerts (collection failures, latency)
  - Monitor service alerts (Azure Monitor service health)
  - Diagnostic settings alerts (configuration compliance)
- **Flexible Configuration**: 9 customizable threshold variables
- **Subscription Scoping**: Support for subscription-level monitoring
- **Action Group Integration**: Centralized alert notification management

### Alert Details

#### Log Analytics Workspace Alerts
- **Data Ingestion Warning**: Severity 2, medium frequency, long window
  - Monitors daily data volume to control costs
  - Configurable threshold (default 100GB)
- **Data Ingestion Critical**: Severity 0, high frequency, medium window
  - Critical alert for excessive data ingestion
  - Configurable threshold (default 200GB)

#### Application Insights Alerts
- **Availability**: Severity 1, monitors service uptime
  - Default threshold: 99% availability
  - Critical for SLA compliance
- **Response Time**: Severity 2, monitors performance
  - Default threshold: 2000ms
  - Warning for user experience degradation
- **Failed Requests**: Severity 2, monitors reliability
  - Default threshold: 20 failed requests
  - Detects application failures
- **Exceptions**: Severity 2, monitors code quality
  - Default threshold: 10 exceptions
  - Tracks application errors

### Examples
- Production deployment example with strict thresholds
  - 50GB/100GB data ingestion thresholds
  - 99.5% availability requirement
  - 1-second response time threshold
  - 10 failed requests threshold
  - 5 exceptions threshold
  - All alert categories enabled
- Development deployment example with relaxed thresholds
  - 100GB/200GB data ingestion thresholds
  - 95% availability requirement
  - 3-second response time threshold
  - 50 failed requests threshold
  - 20 exceptions threshold
  - Selective alert categories
- Basic deployment example with defaults
  - Default threshold values
  - Only workspace and App Insights monitoring
  - Minimal alert footprint

### Documentation
- Comprehensive README with usage examples
- Detailed alert type descriptions and thresholds
- Best practices for monitoring platform observability
- Multi-resource monitoring patterns
- Troubleshooting guide for common issues
- Cost management guidance for data ingestion

### Technical Details
- Terraform version requirement: >= 1.0
- AzureRM provider version: >= 3.0, < 5.0
- Dynamic resource creation based on resource name lists
- Conditional alert creation based on enable flags
- Support for multiple workspaces and App Insights
- Data source lookups for monitoring resources
- Validation for critical variables (planned)

### Outputs
- `alert_ids`: List of all created alert resource IDs
- `alert_names`: List of all created alert names
- `monitored_log_analytics_workspaces`: List of workspace names being monitored
- `monitored_application_insights`: List of App Insights names being monitored
- `monitored_data_collection_rules`: List of DCR names being monitored
- `monitored_subscriptions`: List of subscription IDs being monitored
- `monitored_resource_group`: Resource group name where resources are located
- `action_group_id`: Resource ID of the action group used
- `alert_summary`: Summary counts of each alert type configured
- `alert_categories_enabled`: Status of alert category enable flags

### Variables
- 9 threshold variables with sensible defaults
  - Log Analytics: data ingestion warning/critical, query timeout
  - Application Insights: availability, response time, failed requests, exceptions
  - Data Collection Rules: failure percentage, data latency
- 5 alert category enable flags for granular control
- Resource name lists for multi-resource monitoring
  - `log_analytics_workspace_names`
  - `application_insights_names`
  - `data_collection_rule_names`
  - `subscription_ids`
- Evaluation frequency and window duration variables
- Standard tag variables for resource management

### Use Cases
- **Platform Observability**: Monitor the monitoring platform itself
- **Cost Management**: Track data ingestion to control Log Analytics costs
- **Application Health**: Comprehensive App Insights monitoring
- **SLA Compliance**: Availability and performance tracking
- **Budget Protection**: Critical alerts for excessive data ingestion
- **Multi-Tenant Monitoring**: Support for multiple workspaces and subscriptions
- **Development vs Production**: Different threshold configurations per environment

### Notes
- Module does not support diagnostic settings (monitoring resources don't require them)
- All alerts use appropriate operators (GreaterThan for ingestion, LessThan for availability)
- Data ingestion alerts help prevent unexpected Azure costs
- Application Insights alerts provide full-stack observability
- Module supports monitoring multiple resources of each type simultaneously
- Alert names automatically include resource name for identification
- Conditional alert creation based on resource name lists and enable flags
- Supports both single and multi-subscription monitoring scenarios
