# Cost Management Subscription Level Alerts Module - Examples

This directory contains examples demonstrating how to use the Cost Management Subscription level alerts module.

## Examples

### 1. Production Environment
Demonstrates a production setup with:
- Strict monthly budget threshold ($50,000/subscription)
- Low daily cost spike detection ($2,000)
- Conservative weekly cost increase threshold (15%)
- Early warning percentages (70%, 85%, 100%)
- Strict service-specific thresholds (Compute: $15k, Storage: $5k, Database: $10k, Networking: $3k)
- All alert categories enabled
- Multiple production subscriptions monitored
- Comprehensive notification contacts including finance leadership

### 2. Development Environment
Shows a development configuration with:
- Relaxed monthly budget threshold ($15,000/subscription)
- Higher daily cost spike tolerance ($700)
- More lenient weekly cost increase threshold (40%)
- Later warning percentages (80%, 95%, 110%)
- Relaxed service-specific thresholds (Compute: $5k, Storage: $2k, Database: $3k, Networking: $1.5k)
- Export alerts disabled for flexibility
- Development-specific notification contacts

### 3. Basic Configuration
Minimal setup using:
- Default thresholds from variables.tf
- Single subscription monitoring
- Only basic budget alerts enabled
- All trend and service alerts disabled
- Suitable for testing or non-critical environments

## Usage

```hcl
module "cost_alerts_subscription" {
  source = "path/to/modules/metricAlerts/costmanagement-subscription"

  resource_group_name                = "rg-monitoring-prod"
  action_group_resource_group_name   = "rg-monitoring-prod"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Customize thresholds as needed
  subscription_monthly_cost_threshold = 50000
  subscription_daily_cost_threshold   = 2000
  budget_alert_percentage_first       = 70
  budget_alert_percentage_second      = 85
  budget_alert_percentage_critical    = 100

  # Service-specific thresholds
  compute_cost_threshold    = 15000
  storage_cost_threshold    = 5000
  database_cost_threshold   = 10000
  networking_cost_threshold = 3000

  contact_emails = [
    "finance-prod@pge.com",
    "operations-prod@pge.com"
  ]

  tags = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "abc@pge.com"
    Compliance         = "None"
    Notify             = "abc@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    order              = "123456"
  }
}
```

## Outputs

All examples demonstrate how to access module outputs:

- `alert_ids` - Map of all alert resource IDs
- `alert_names` - Map of all alert names
- `monitored_subscriptions` - List of monitored subscription IDs
- `action_group_id` - Action group resource ID
- `budget_thresholds` - Budget configuration summary
- `service_cost_thresholds` - Service-specific thresholds summary

## Alert Types

The module creates the following cost management alerts for each subscription:

### 1. Monthly Budget Alert (Consumption Budget)
   - Type: `azurerm_consumption_budget_subscription`
   - Monitors monthly spending per subscription
   - Four notification thresholds:
     - First warning (default: 75% actual)
     - Second warning (default: 90% actual)
     - Critical (default: 100% actual)
     - Forecasted (default: 90% forecasted)
   - Default monthly threshold: $10,000
   - Sends email notifications to contact_emails list

### 2. Daily Cost Spike Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Detects unusual daily cost increases
   - Severity: 1 (Critical)
   - Default threshold: $500/day
   - Evaluation frequency: Daily (P1D)
   - Uses Azure Activity logs for cost detection

### 3. Compute Cost Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Monitors compute service costs (VMs, AKS, Azure Functions)
   - Severity: 2 (Warning)
   - Default threshold: $3,000/month
   - Tracks Virtual Machines, Container services, App Services

### 4. Storage Cost Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Monitors storage service costs
   - Severity: 2 (Warning)
   - Default threshold: $1,500/month
   - Tracks Storage Accounts, Managed Disks, Blob Storage

### 5. Database Cost Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Monitors database service costs
   - Severity: 2 (Warning)
   - Default threshold: $2,000/month
   - Tracks SQL Database, Cosmos DB, PostgreSQL, MySQL

### 6. Networking Cost Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Monitors networking service costs
   - Severity: 2 (Warning)
   - Default threshold: $1,000/month
   - Tracks VNet, Load Balancers, Application Gateway, VPN

### 7. Unused Resources Cost Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Identifies underutilized resources consuming budget
   - Severity: 3 (Informational)
   - Tracks unattached disks, unused IPs, idle resources
   - Helps optimize costs by identifying waste

## Feature Flags

Control which alert categories are enabled:

```hcl
enable_subscription_cost_alerts = true   # Budget alerts
enable_cost_increase_alerts     = true   # Daily cost spike detection
enable_export_alerts            = true   # Cost export configuration monitoring
enable_service_cost_alerts      = true   # Service-specific cost tracking
```

## Customizable Thresholds

### Budget Thresholds
- `subscription_monthly_cost_threshold` - Monthly budget per subscription (default: $10,000)
- `subscription_daily_cost_threshold` - Daily spike threshold (default: $500)
- `budget_alert_percentage_first` - First warning % (default: 75%)
- `budget_alert_percentage_second` - Second warning % (default: 90%)
- `budget_alert_percentage_critical` - Critical threshold % (default: 100%)
- `weekly_cost_increase_threshold_percent` - Weekly cost increase % (default: 25%)

### Service-Specific Thresholds (Monthly)
- `compute_cost_threshold` - Compute services (default: $3,000)
- `storage_cost_threshold` - Storage services (default: $1,500)
- `database_cost_threshold` - Database services (default: $2,000)
- `networking_cost_threshold` - Networking services (default: $1,000)

### Evaluation Frequencies
- `evaluation_frequency_daily` - Daily checks (default: P1D)
- `window_duration_daily` - Daily window (default: P1D)
- `window_duration_weekly` - Weekly window (default: P7D)

## Email Notifications

Budget alerts send email notifications to the contact_emails list:

```hcl
contact_emails = [
  "finance@pge.com",
  "operations@pge.com",
  "manager@pge.com"
]
```

Scheduled query alerts use the action group for notifications.

## Multi-Subscription Monitoring

Monitor multiple subscriptions with a single module instance:

```hcl
subscription_ids = [
  "12345678-1234-1234-1234-123456789012",
  "87654321-4321-4321-4321-210987654321",
  "11111111-2222-3333-4444-555555555555"
]
```

Each subscription gets its own set of alerts with the same configuration.

## Prerequisites

- Azure subscriptions with appropriate permissions
- Cost Management/billing read permissions on subscriptions
- Existing action group for alert notifications
- Resource group for creating scheduled query alerts

## Notes

- Budget alerts are created at the subscription scope
- All thresholds are customizable per environment
- Alert creation is conditional based on `subscription_ids` list
- Empty `subscription_ids` list disables all alert creation
- Scheduled query alerts require Log Analytics workspace
- This module does NOT support diagnostic settings (Cost Management uses built-in logging)
- Tags are applied to scheduled query alert resources
- Budget start date is automatically set to the current month
- Forecasted budget notification helps predict cost overruns
- Service-specific alerts help identify which Azure services are driving costs
