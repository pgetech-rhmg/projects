# Changelog

All notable changes to the Cost Management Subscription Level Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-30

### Added
- Initial release of Cost Management Subscription level alerts module
- Monthly budget monitoring per subscription:
  - Consumption budget with configurable thresholds
  - Four-tier notification system (75% actual, 90% actual, 100% actual, 90% forecasted)
  - Email notifications to configurable contact list
  - Automatic monthly budget period configuration
  - Forecasted budget alerts to predict overruns
- Cost trend monitoring:
  - Daily cost spike detection
  - Configurable daily cost threshold
  - Weekly cost increase percentage tracking
- Service-specific cost monitoring:
  - Compute services cost tracking (VMs, AKS, Functions)
  - Storage services cost tracking (Storage Accounts, Disks, Blobs)
  - Database services cost tracking (SQL, Cosmos DB, PostgreSQL)
  - Networking services cost tracking (VNet, Load Balancers, VPN)
  - Independent thresholds for each service category
- Cost optimization monitoring:
  - Unused resources cost identification
  - Underutilized resource detection
  - Cost waste identification
- Feature flags for enabling/disabling alert categories:
  - Subscription cost alerts (budgets)
  - Cost increase and trend alerts
  - Cost export configuration alerts
  - Service-specific cost alerts
- Comprehensive examples:
  - Production environment with strict cost controls
  - Development environment with relaxed thresholds
  - Basic configuration with defaults
- Module outputs:
  - Alert IDs and names
  - Monitored subscriptions list
  - Action group ID
  - Budget thresholds summary
  - Service-specific thresholds summary
- Variable validation for:
  - Resource group names
  - Action group configuration
  - Subscription IDs list (GUID format)
  - Budget percentage thresholds (0-200 range)
  - Cost thresholds (positive values)
  - Service cost thresholds (positive values)
- Support for monitoring multiple subscriptions
- Configurable evaluation frequencies (daily)
- Configurable time windows (daily, weekly)
- Email notification configuration
- Tags support for scheduled query alert resources

### Configuration
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

### Alert Types
1. **Monthly Budget Alert** - Consumption budget with 4 notification tiers (3 actual + 1 forecasted)
2. **Daily Cost Spike Alert** - Scheduled query for unusual daily cost increases
3. **Compute Cost Alert** - Scheduled query for compute service costs
4. **Storage Cost Alert** - Scheduled query for storage service costs
5. **Database Cost Alert** - Scheduled query for database service costs
6. **Networking Cost Alert** - Scheduled query for networking service costs
7. **Unused Resources Alert** - Scheduled query for cost waste identification

### Notes
- Budget alerts use azurerm_consumption_budget_subscription resource
- Query alerts use azurerm_monitor_scheduled_query_rules_alert_v2 resource
- Alert creation is conditional based on subscription_ids list
- Empty subscription_ids disables all alert creation
- Module does NOT support diagnostic settings (Cost Management uses built-in logging)
- Budget start date automatically set to current month
- Supports multi-subscription monitoring with single module instance
- Email notifications sent directly from budget alerts
- Scheduled query alerts use action group for notifications
- Service-specific alerts help identify cost drivers by Azure service category
- Forecasted budget notification helps predict and prevent cost overruns
- Module follows Azure Monitor Baseline Alerts (AMBA) best practices
