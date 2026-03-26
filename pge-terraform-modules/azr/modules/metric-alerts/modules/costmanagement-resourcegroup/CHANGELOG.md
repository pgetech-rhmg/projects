# Changelog

All notable changes to the Cost Management Resource Group Level Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-30

### Added
- Initial release of Cost Management Resource Group level alerts module
- Monthly budget monitoring per resource group:
  - Consumption budget with configurable thresholds
  - Three-tier notification system (75%, 90%, 100%)
  - Email notifications to configurable contact list
  - Automatic monthly budget period configuration
- Cost trend monitoring:
  - Daily cost spike detection
  - Configurable daily cost threshold
  - Cost increase percentage tracking
- Resource activity monitoring:
  - Resource creation spike alerts
  - Resource deletion tracking
  - Idle resource identification
  - Configurable activity thresholds
- Feature flags for enabling/disabling alert categories:
  - Resource group cost alerts (budgets)
  - Cost trend and anomaly alerts
  - Resource activity and usage alerts
- Comprehensive examples:
  - Production environment with strict cost controls
  - Development environment with relaxed thresholds
  - Basic configuration with defaults
- Module outputs:
  - Alert IDs and names
  - Monitored resource groups list
  - Subscription ID
  - Action group ID
  - Budget thresholds summary
- Variable validation for:
  - Resource group names
  - Action group configuration
  - Budget percentage thresholds (0-100+ range)
  - Cost thresholds (positive values)
  - Activity thresholds (positive integers)
- Support for monitoring multiple resource groups
- Cross-subscription support for resource group monitoring
- Configurable evaluation frequencies (daily, hourly)
- Configurable time windows (daily, weekly)
- Email notification configuration
- Tags support for all resources

### Configuration
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

### Alert Types
1. **Monthly Budget Alert** - Consumption budget with 3 notification tiers
2. **Daily Cost Spike Alert** - Scheduled query for unusual cost increases
3. **Resource Creation Spike Alert** - Scheduled query for resource sprawl detection
4. **Resource Deletion Alert** - Scheduled query for deletion tracking
5. **Idle Resources Alert** - Scheduled query for underutilized resources

### Notes
- Budget alerts use azurerm_consumption_budget_resource_group resource
- Query alerts use azurerm_monitor_scheduled_query_rules_alert_v2 resource
- Alert creation is conditional based on resource_group_names list
- Empty resource_group_names disables all alert creation
- Module does NOT support diagnostic settings (Cost Management uses built-in logging)
- Budget start date automatically set to current month
- Supports cross-subscription resource group monitoring
- Email notifications sent directly from budget alerts
- Scheduled query alerts use action group for notifications
- Module follows Azure Monitor Baseline Alerts (AMBA) best practices
