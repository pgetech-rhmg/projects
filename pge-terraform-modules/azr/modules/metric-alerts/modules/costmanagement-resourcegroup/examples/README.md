# Cost Management Resource Group Level Alerts Module - Examples

This directory contains examples demonstrating how to use the Cost Management Resource Group level alerts module.

## Examples

### 1. Production Environment
Demonstrates a production setup with:
- Strict monthly budget threshold ($5,000/RG)
- Low daily cost spike detection ($200)
- Conservative cost increase threshold (20%)
- Early warning percentages (70%, 85%, 100%)
- Lower resource activity thresholds (15 creates, 8 deletes)
- All alert categories enabled
- Multiple production resource groups monitored
- Comprehensive notification contacts

### 2. Development Environment
Shows a development configuration with:
- Relaxed monthly budget threshold ($1,500/RG)
- Higher daily cost spike tolerance ($100)
- More lenient cost increase threshold (50%)
- Later warning percentages (80%, 95%, 110%)
- Higher resource activity thresholds (30 creates, 20 deletes)
- Activity alerts disabled for flexibility
- Development-specific notification contacts

### 3. Basic Configuration
Minimal setup using:
- Default thresholds from variables.tf
- Single resource group monitoring
- Only basic cost alerts enabled
- Trend and activity alerts disabled
- Suitable for testing or non-critical environments

## Usage

```hcl
module "cost_alerts_rg" {
  source = "path/to/modules/metricAlerts/costmanagement-resourcegroup"

  resource_group_name                = "rg-monitoring-prod"
  action_group_resource_group_name   = "rg-monitoring-prod"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  resource_group_names = [
    "rg-app-prod-eastus",
    "rg-app-prod-westus"
  ]

  # Customize thresholds as needed
  resource_group_monthly_cost_threshold = 5000
  resource_group_daily_cost_threshold   = 200
  budget_alert_percentage_first         = 70
  budget_alert_percentage_second        = 85
  budget_alert_percentage_critical      = 100

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
- `monitored_resource_groups` - List of monitored resource groups
- `subscription_id` - Target subscription ID
- `action_group_id` - Action group resource ID
- `budget_thresholds` - Budget configuration summary

## Alert Types

The module creates the following cost management alerts for each resource group:

### 1. Monthly Budget Alert (Consumption Budget)
   - Type: `azurerm_consumption_budget_resource_group`
   - Monitors monthly spending per resource group
   - Three notification thresholds:
     - First warning (default: 75%)
     - Second warning (default: 90%)
     - Critical (default: 100%)
   - Default monthly threshold: $2,000
   - Sends email notifications to contact_emails list

### 2. Daily Cost Spike Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Detects unusual daily cost increases
   - Severity: 1 (Critical)
   - Default threshold: $100/day
   - Evaluation frequency: Daily (P1D)
   - Uses Azure Activity logs for cost detection

### 3. Resource Creation Spike Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Monitors unusual resource creation patterns
   - Severity: 2 (Warning)
   - Default threshold: 10 resources/day
   - Evaluation frequency: Hourly (PT1H)
   - Helps identify potential cost overruns from resource sprawl

### 4. Resource Deletion Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Tracks resource deletion activities
   - Severity: 2 (Warning)
   - Default threshold: 5 resources/day
   - Evaluation frequency: Hourly (PT1H)
   - Helps detect accidental or malicious deletions

### 5. Idle Resources Alert (Scheduled Query)
   - Type: `azurerm_monitor_scheduled_query_rules_alert_v2`
   - Identifies underutilized resources
   - Severity: 3 (Informational)
   - Tracks resources with minimal activity
   - Helps optimize costs by identifying waste

## Feature Flags

Control which alert categories are enabled:

```hcl
enable_resource_group_cost_alerts   = true   # Budget alerts
enable_resource_group_trend_alerts  = true   # Cost spike detection
enable_resource_activity_alerts     = true   # Resource creation/deletion tracking
```

## Cross-Subscription Support

Monitor resource groups in a different subscription:

```hcl
subscription_id = "00000000-0000-0000-0000-000000000000"
```

If not specified, uses the current subscription from Azure CLI context.

## Customizable Thresholds

### Budget Thresholds
- `resource_group_monthly_cost_threshold` - Monthly budget per RG (default: $2,000)
- `resource_group_daily_cost_threshold` - Daily spike threshold (default: $100)
- `budget_alert_percentage_first` - First warning % (default: 75%)
- `budget_alert_percentage_second` - Second warning % (default: 90%)
- `budget_alert_percentage_critical` - Critical threshold % (default: 100%)

### Activity Thresholds
- `resource_creation_threshold` - Max resources created/day (default: 10)
- `resource_deletion_threshold` - Max resources deleted/day (default: 5)
- `resource_group_cost_increase_threshold_percent` - Cost increase % (default: 30%)

### Evaluation Frequencies
- `evaluation_frequency_daily` - Daily checks (default: P1D)
- `evaluation_frequency_hourly` - Hourly checks (default: PT1H)
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

## Prerequisites

- Azure subscription with appropriate permissions
- Existing resource groups to monitor
- Existing action group for alert notifications
- Cost Management/billing read permissions

## Notes

- Budget alerts are created at the resource group scope
- All thresholds are customizable per environment
- Alert creation is conditional based on `resource_group_names` list
- Empty `resource_group_names` list disables all alert creation
- Scheduled query alerts require Log Analytics workspace
- This module does NOT support diagnostic settings (Cost Management uses built-in logging)
- Tags are applied to all alert resources
- Budget start date is automatically set to the current month
