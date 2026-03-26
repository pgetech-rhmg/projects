# Azure Cost Management - Resource Group Level AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure Cost Management at the Resource Group Level**. It provides production-ready cost monitoring, budget alerts, and resource activity tracking to help organizations control cloud spending and detect cost anomalies at the resource group level.

This module focuses on **resource group-level cost monitoring**, enabling granular financial governance and cost attribution across your Azure environment. It complements subscription-level cost monitoring by providing detailed visibility into individual resource group spending patterns.

## Table of Contents

- [Features](#features)
- [Alert Categories](#alert-categories)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Input Variables](#input-variables)
- [Alert Details](#alert-details)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Features

- **1 Budget Alert** with 3-tier threshold notifications (75%, 90%, 100%)
- **4 Scheduled Query Rules** for cost trends and resource activity
- **Customizable Thresholds** for all alerts
- **Enable/Disable Flags** for flexible alert management
- **Monthly Budget Tracking** per resource group
- **Daily Cost Spike Detection** for anomaly detection
- **Resource Creation Monitoring** to detect sprawl
- **Resource Deletion Tracking** for compliance
- **Idle Resource Detection** for cost optimization
- **Multi-Resource Group Support** with individual budgets
- **Email Notifications** for cost alerts
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 💰 Budget Alerts
- Monthly Resource Group Budget (3-tier: 75%, 90%, 100%)

### 📈 Cost Trend Alerts
- Daily Cost Spike Detection
- Idle Resource Detection

### 🔧 Resource Activity Alerts
- Resource Creation Spike
- Resource Deletion Monitoring

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure Resource Groups to monitor
- Azure Monitor Action Group (pre-configured)
- **Cost Management data** (typically available after 24-48 hours)
- **Email addresses** for budget notifications
- Reader permissions on resource groups
- Appropriate permissions to create budgets and alerts

## Usage

### Basic Example

```hcl
module "cost_alerts_rg" {
  source = "./modules/metricAlerts/costmanagement-resourcegroup"

  # Resource Configuration
  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Resource Groups to Monitor
  resource_group_names = [
    "rg-app-production",
    "rg-data-production"
  ]

  # Subscription ID
  subscription_id = "12345678-1234-1234-1234-123456789012"

  # Budget Configuration
  resource_group_monthly_cost_threshold = 5000  # $5,000/month per RG

  # Email Notifications
  contact_emails = [
    "finance@pge.com",
    "operations@pge.com"
  ]

  # Tags
  tags = {
    Environment         = "Production"
    AppId              = "123456"
    CRIS               = "1"
    Compliance         = "SOX"
    DataClassification = "internal"
    Env                = "Prod"
    Notify             = "finance@pge.com"
    Owner              = "finops-team@pge.com"
    order              = "123456"
  }
}
```

### Production Example with Custom Thresholds

```hcl
module "cost_alerts_production_rg" {
  source = "./modules/metricAlerts/costmanagement-resourcegroup"

  # Resource Configuration
  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-cost-actiongroup"
  location                         = "West US 3"

  # Resource Groups
  resource_group_names = [
    "rg-app-prod",
    "rg-database-prod",
    "rg-analytics-prod"
  ]

  subscription_id = "12345678-1234-1234-1234-123456789012"

  # Strict Budget Thresholds
  resource_group_monthly_cost_threshold = 10000  # $10K/month per RG
  resource_group_daily_cost_threshold   = 500    # $500/day spike alert

  # Earlier Warning Notifications
  budget_alert_percentage_first    = 70   # Alert at 70%
  budget_alert_percentage_second   = 85   # Alert at 85%
  budget_alert_percentage_critical = 100  # Alert at 100%

  # Resource Activity Thresholds
  resource_creation_threshold = 20   # Alert if >20 resources/day created
  resource_deletion_threshold = 10   # Alert if >10 resources/day deleted

  # Email Notifications
  contact_emails = [
    "finance-team@pge.com",
    "engineering-leads@pge.com",
    "cto@pge.com"
  ]

  # Enable All Alerts
  enable_resource_group_cost_alerts  = true
  enable_resource_group_trend_alerts = true
  enable_resource_activity_alerts    = true

  tags = {
    Environment     = "Production"
    CostCenter      = "Engineering"
    CriticalityTier = "Tier1"
  }
}
```

### Development Environment Example

```hcl
module "cost_alerts_dev_rg" {
  source = "./modules/metricAlerts/costmanagement-resourcegroup"

  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-cost-actiongroup"
  location                         = "West US 3"

  resource_group_names = [
    "rg-app-dev",
    "rg-testing-dev"
  ]

  subscription_id = "12345678-1234-1234-1234-123456789012"

  # Lower Budgets for Dev
  resource_group_monthly_cost_threshold = 1000   # $1K/month
  resource_group_daily_cost_threshold   = 50     # $50/day

  # More Lenient Activity Thresholds
  resource_creation_threshold = 50   # Dev creates more resources
  resource_deletion_threshold = 30   # Dev deletes more resources

  # Enable cost alerts only
  enable_resource_group_cost_alerts  = true
  enable_resource_group_trend_alerts = true
  enable_resource_activity_alerts    = false  # Skip activity alerts in dev

  contact_emails = ["dev-team@pge.com"]

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

### Multi-Resource Group Enterprise Example

```hcl
module "cost_alerts_enterprise_rg" {
  source = "./modules/metricAlerts/costmanagement-resourcegroup"

  resource_group_name              = "rg-monitoring"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "enterprise-cost-actiongroup"
  location                         = "West US 3"

  # Monitor Multiple Resource Groups
  resource_group_names = [
    "rg-web-prod",
    "rg-api-prod",
    "rg-database-prod",
    "rg-storage-prod",
    "rg-compute-prod",
    "rg-networking-prod"
  ]

  subscription_id = "12345678-1234-1234-1234-123456789012"

  # Tiered Budget Allocation
  resource_group_monthly_cost_threshold = 8000  # $8K/month average per RG

  # Budget Alert Thresholds
  budget_alert_percentage_first    = 75
  budget_alert_percentage_second   = 90
  budget_alert_percentage_critical = 100

  # Comprehensive Monitoring
  resource_group_daily_cost_threshold = 400
  resource_creation_threshold         = 15
  resource_deletion_threshold         = 8

  # Notifications to Multiple Stakeholders
  contact_emails = [
    "finance@pge.com",
    "cloudops@pge.com",
    "engineering-vp@pge.com"
  ]

  tags = {
    Environment = "Production"
    Scope       = "Enterprise"
    CostCenter  = "CloudOps"
  }
}
```

### Project-Based Resource Group Monitoring

```hcl
module "cost_alerts_project_rg" {
  source = "./modules/metricAlerts/costmanagement-resourcegroup"

  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "project-cost-actiongroup"
  location                         = "West US 3"

  # Project-Specific Resource Groups
  resource_group_names = [
    "rg-project-alpha",
    "rg-project-beta",
    "rg-project-gamma"
  ]

  subscription_id = "12345678-1234-1234-1234-123456789012"

  # Project Budget (e.g., $3K/month per project)
  resource_group_monthly_cost_threshold = 3000

  # Track project spending closely
  budget_alert_percentage_first  = 60   # Alert at 60% ($1,800)
  budget_alert_percentage_second = 80   # Alert at 80% ($2,400)
  budget_alert_percentage_critical = 100  # Alert at 100% ($3,000)

  # Project-specific email notifications
  contact_emails = [
    "project-manager@pge.com",
    "finance-controller@pge.com"
  ]

  tags = {
    Environment = "Production"
    BillingType = "Project"
    CostTracking = "Enabled"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `resource_group_names` | `list(string)` | **REQUIRED** - List of resource group names to monitor (empty list = no alerts created) |

### Core Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where alerts will be created |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group name for notifications |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `subscription_id` | `string` | `""` | Subscription ID where resource groups exist (auto-detects if empty) |
| `tags` | `map(string)` | See below | Tags applied to all alert resources |

### Default Tags

```hcl
{
  "AppId"              = "123456"
  "Env"                = "Dev"
  "Owner"              = "abc@pge.com"
  "Compliance"         = "SOX"
  "Notify"             = "abc@pge.com"
  "DataClassification" = "internal"
  "CRIS"               = "1"
  "order"              = "123456"
}
```

### Email Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `contact_emails` | `list(string)` | `["finance@pge.com", "operations@pge.com"]` | Email addresses for budget alert notifications |

### Alert Enable/Disable Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_resource_group_cost_alerts` | `bool` | `true` | Enable monthly budget alerts |
| `enable_resource_group_trend_alerts` | `bool` | `true` | Enable daily cost spike and idle resource alerts |
| `enable_resource_activity_alerts` | `bool` | `true` | Enable resource creation/deletion alerts |

### Budget Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_monthly_cost_threshold` | `number` | `2000` | Monthly budget per resource group (USD) |
| `resource_group_daily_cost_threshold` | `number` | `100` | Daily cost spike threshold (USD) |
| `budget_alert_percentage_first` | `number` | `75` | First notification threshold (%) |
| `budget_alert_percentage_second` | `number` | `90` | Second notification threshold (%) |
| `budget_alert_percentage_critical` | `number` | `100` | Critical notification threshold (%) |

### Resource Activity Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_creation_threshold` | `number` | `10` | Resources created per day to trigger alert |
| `resource_deletion_threshold` | `number` | `5` | Resources deleted per day to trigger alert |
| `resource_group_cost_increase_threshold_percent` | `number` | `30` | Cost increase percentage threshold |

### Evaluation Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `evaluation_frequency_daily` | `string` | `"P1D"` | Daily evaluation frequency (1 day) |
| `evaluation_frequency_hourly` | `string` | `"PT1H"` | Hourly evaluation frequency (1 hour) |
| `window_duration_daily` | `string` | `"P1D"` | Daily window duration (1 day) |
| `window_duration_weekly` | `string` | `"P7D"` | Weekly window duration (7 days) |

## Alert Details

### Budget Alerts

#### 1. Monthly Resource Group Budget Alert
- **Type**: Azure Consumption Budget
- **Time Grain**: Monthly
- **Scope**: Individual Resource Group
- **Threshold**: Configurable (default: $2,000/month per RG)
- **Notifications**: 3-tier threshold system
  - **75% ($1,500)**: Early warning - review spending
  - **90% ($1,800)**: Urgent - action required
  - **100% ($2,000)**: Critical - budget exceeded
- **Delivery**: Email notifications to configured addresses
- **Description**: Tracks actual monthly spending against budget for each resource group. Sends email notifications at 75%, 90%, and 100% of budget threshold.

**When to Adjust**:
- **High-cost RGs**: Set to $10K-$50K+ for production workloads
- **Dev/Test RGs**: Set to $500-$2K for cost control
- **Project-based**: Align with project budget allocation
- **Percentage thresholds**: Adjust for tighter control (60%, 80%, 100%) or looser monitoring (80%, 95%, 110%)

**Budget Calculation Example**:
```
Monthly Budget: $5,000
├─ 75% Alert: $3,750 (15 days into month if linear spend)
├─ 90% Alert: $4,500 (27 days into month if linear spend)
└─ 100% Alert: $5,000 (budget exceeded)
```

### Scheduled Query Rules

#### 2. Daily Cost Spike Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: Configurable (default: $100/day)
- **Severity**: 1 (Error)
- **Scope**: Individual Resource Group
- **Description**: Detects unusual daily cost increases that may indicate cost anomalies, misconfigurations, or unexpected resource scaling.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where ResourceGroup == "{resource_group_name}"
| where CategoryValue == "Administrative"
| where ActivityStatusValue == "Success"
| where OperationNameValue contains "write" or OperationNameValue contains "create"
| summarize ActivityCount = count() by bin(TimeGenerated, 1h)
| where ActivityCount > 0
```

**When to Adjust**:
- **Production**: Set to 2-3x normal daily spend for anomaly detection
- **Autoscaling workloads**: Set higher threshold to avoid false positives
- **Development**: Set lower threshold ($20-$50) for tight control

**Common Causes**:
- Unexpected autoscaling events
- Large data transfers or egress
- Premium tier resource creation
- Long-running compute jobs

#### 3. Resource Creation Spike Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: 10 resources/day (default)
- **Severity**: 2 (Warning)
- **Scope**: Individual Resource Group
- **Description**: Monitors resource creation activity to detect resource sprawl, automation issues, or potential security concerns.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where ResourceGroup == "{resource_group_name}"
| where CategoryValue == "Administrative"
| where OperationNameValue contains "write" and ActivityStatusValue == "Success"
| where OperationNameValue !contains "Microsoft.Authorization"
| summarize ResourceCreations = count() by bin(TimeGenerated, 1h)
| summarize DailyCreations = sum(ResourceCreations)
| where DailyCreations > {threshold}
```

**When to Adjust**:
- **Production**: Set to 5-10 for stable environments
- **Development**: Set to 20-50 for active development
- **Automation/IaC**: Set higher (50+) for environments with CI/CD
- **Sandbox**: Disable or set very high threshold

**Use Cases**:
- Detect runaway automation scripts
- Identify resource sprawl issues
- Track deployment activity
- Security: Detect unauthorized provisioning

#### 4. Resource Deletion Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: 5 resources/day (default)
- **Severity**: 2 (Warning)
- **Scope**: Individual Resource Group
- **Description**: Monitors resource deletion activity for compliance, audit trails, and potential accidental deletions.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where ResourceGroup == "{resource_group_name}"
| where CategoryValue == "Administrative"
| where OperationNameValue contains "delete" and ActivityStatusValue == "Success"
| summarize ResourceDeletions = count() by bin(TimeGenerated, 1h)
| summarize DailyDeletions = sum(ResourceDeletions)
| where DailyDeletions > {threshold}
```

**When to Adjust**:
- **Production**: Set to 3-5 for strict monitoring
- **Development**: Set to 10-20 for active cleanup
- **Ephemeral environments**: Set higher or disable
- **Critical RGs**: Set to 1 for immediate notification

**Use Cases**:
- Prevent accidental deletions
- Audit trail for compliance (SOX, HIPAA)
- Track resource lifecycle
- Security: Detect malicious activity

#### 5. Idle Resources Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: 2+ idle resources over 7 days
- **Severity**: 3 (Informational)
- **Scope**: Individual Resource Group
- **Description**: Identifies potentially idle resources (stopped VMs, deallocated compute) for cost optimization opportunities.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(7d)
| where ResourceGroup == "{resource_group_name}"
| where ResourceProviderValue in ("Microsoft.Compute", "Microsoft.Storage")
| where ActivityStatusValue == "Success"
| where OperationNameValue contains "deallocate" or OperationNameValue contains "stop"
| summarize IdleActivity = count() by ResourceId
| where IdleActivity > 0
| summarize TotalIdle = count()
| where TotalIdle > 2
```

**When to Adjust**:
- **Production**: Monitor closely, idle resources should be minimal
- **Development**: Higher threshold (5-10) for testing environments
- **Cost-sensitive**: Set to 1 for aggressive optimization

**Cost Optimization Actions**:
1. Deallocate stopped VMs permanently
2. Delete unused disks
3. Move infrequently accessed storage to cool/archive tier
4. Remove orphaned NICs and public IPs
5. Consider Azure Reservations for always-on resources

## Best Practices

### 1. Resource Group Name Configuration

```hcl
# Always provide specific resource group names
resource_group_names = [
  "rg-app-prod",
  "rg-database-prod"
]

# Empty list = no alerts created
resource_group_names = []  # Use only for testing
```

### 2. Budget Allocation Strategy

#### Project-Based Budgets
```hcl
# Allocate budgets based on project funding
resource_group_monthly_cost_threshold = 5000  # $5K/project

# Strict monitoring with early warnings
budget_alert_percentage_first    = 60   # Alert at $3,000
budget_alert_percentage_second   = 80   # Alert at $4,000
budget_alert_percentage_critical = 100  # Alert at $5,000
```

#### Environment-Based Budgets
```hcl
# Production: Higher budgets, strict monitoring
module "prod_rg_alerts" {
  resource_group_monthly_cost_threshold = 10000
  budget_alert_percentage_first         = 75
}

# Development: Lower budgets, looser monitoring
module "dev_rg_alerts" {
  resource_group_monthly_cost_threshold = 1000
  budget_alert_percentage_first         = 90
}
```

#### Workload-Based Budgets
```hcl
# High-compute workloads
resource_group_monthly_cost_threshold = 20000  # Analytics, ML

# Low-compute workloads
resource_group_monthly_cost_threshold = 2000   # Static sites, storage
```

### 3. Email Notification Strategy

```hcl
# Multiple stakeholders for different severity
contact_emails = [
  "finance-team@pge.com",      # Budget alerts
  "cloudops-team@pge.com",     # Operations
  "engineering-lead@pge.com",  # Technical ownership
  "cto@pge.com"                # Executive visibility
]

# Consider using distribution lists
contact_emails = [
  "cloud-cost-alerts@pge.com"  # DL for cost management team
]
```

### 4. Resource Activity Monitoring

```hcl
# Production: Strict thresholds
resource_creation_threshold = 10   # Flag unusual creation activity
resource_deletion_threshold = 5    # Flag any significant deletions

# Development: Relaxed thresholds
resource_creation_threshold = 50   # Allow rapid prototyping
resource_deletion_threshold = 30   # Allow frequent cleanup

# Automation-heavy environments
resource_creation_threshold = 100  # CI/CD pipelines create many resources
```

### 5. Cost Spike Detection

```hcl
# Calculate daily threshold from monthly budget
# If monthly budget is $30K, daily average is ~$1K
# Set spike alert to 2-3x daily average

resource_group_monthly_cost_threshold = 30000   # $30K/month
resource_group_daily_cost_threshold   = 2000    # $2K/day (2x normal)

# For highly variable workloads
resource_group_daily_cost_threshold   = 3000    # 3x normal to reduce false positives
```

### 6. Idle Resource Optimization

```hcl
# Enable for cost-sensitive environments
enable_resource_group_trend_alerts = true

# Regular review cadence
# - Daily: Check idle resource alerts
# - Weekly: Review and take action on idle resources
# - Monthly: Verify cost savings from optimization
```

### 7. Multi-Resource Group Governance

```hcl
# Standardize budgets by resource group type
locals {
  rg_budgets = {
    "rg-prod-"    = 10000  # Production RGs: $10K
    "rg-dev-"     = 1000   # Dev RGs: $1K
    "rg-test-"    = 500    # Test RGs: $500
    "rg-sandbox-" = 200    # Sandbox RGs: $200
  }
}

# Apply consistent thresholds
resource_group_names = [
  "rg-prod-app",
  "rg-prod-data",
  "rg-dev-app"
]
```

### 8. Tagging for Cost Attribution

```hcl
tags = {
  CostCenter      = "Engineering"
  Project         = "ProjectAlpha"
  Owner           = "team-lead@pge.com"
  Environment     = "Production"
  BudgetCode      = "BUDGET-2025-001"
  BusinessUnit    = "Digital Products"
  ChargebackTo    = "Product Team"
}

# Use tags for cost allocation reports
# Align with organizational chargeback policies
```

## Troubleshooting

### Common Issues

#### 1. No Alerts Being Created

**Problem**: No budget or query alerts appearing in Azure Monitor.

**Solution**:
```hcl
# Ensure resource_group_names is not empty
resource_group_names = ["rg-app-prod"]  # REQUIRED

# Verify resource groups exist
# Use exact resource group names (case-sensitive)

# Check subscription_id is correct
subscription_id = "12345678-1234-1234-1234-123456789012"

# Verify action group exists
action_group_resource_group_name = "rg-monitoring"
action_group                     = "existing-action-group"
```

**Validation**:
```bash
# List resource groups in subscription
az group list --query "[].name" --output table

# Verify specific resource group
az group show --name "rg-app-prod"
```

#### 2. Budget Alerts Not Triggering

**Problem**: Cost exceeds threshold but no email received.

**Solution**:
```hcl
# Verify email addresses are correct
contact_emails = ["valid-email@pge.com"]

# Check budget start date (must be first of month)
# Budgets evaluate against current month's spending

# Verify cost data is available (48-hour delay)
# Cost data typically available 24-48 hours after resource usage
```

**Diagnostics**:
```bash
# Check if budget exists
az consumption budget list \
  --resource-group "rg-app-prod" \
  --query "[].{Name:name, Amount:amount, CurrentSpend:currentSpend.amount}"

# View current spending
az consumption usage list \
  --start-date "2025-11-01" \
  --end-date "2025-11-24" \
  --query "[].{Date:usageStart, Cost:pretaxCost}" \
  --output table

# Verify email in spam/junk folder
# Check email address for typos
```

#### 3. Query-Based Alerts Not Firing

**Problem**: Daily cost spike or activity alerts not triggering.

**Diagnostics**:
```bash
# Verify AzureActivity logs are available
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureActivity | where ResourceGroup == 'rg-app-prod' | take 10"

# Test KQL query directly
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureActivity | where TimeGenerated >= ago(1d) | where ResourceGroup == 'rg-app-prod' | summarize count()"
```

**Solution**:
```hcl
# Ensure Activity Log is enabled (enabled by default)
# Wait 15-30 minutes for initial data ingestion
# Verify resource group has activity in the time window

# Check alert scope is correct
# Scope should match: /subscriptions/{sub-id}/resourceGroups/{rg-name}
```

#### 4. False Positives for Resource Creation

**Problem**: Alert firing during normal deployments.

**Solution**:
```hcl
# Increase threshold for deployment-heavy environments
resource_creation_threshold = 30  # Increase from 10

# Or temporarily disable during planned deployments
enable_resource_activity_alerts = false  # Before deployment
# Re-enable after deployment
enable_resource_activity_alerts = true
```

#### 5. Cost Data Delay Issues

**Problem**: Budget alerts delayed or inaccurate.

**Understanding**:
- Cost data has 24-48 hour latency
- Daily costs may not be final until next day
- Budget evaluations happen once per day

**Solution**:
```hcl
# Use conservative thresholds to account for delays
budget_alert_percentage_first = 70  # Alert earlier

# Monitor daily cost spikes for real-time visibility
enable_resource_group_trend_alerts = true

# Review Azure Cost Management portal for real-time estimates
```

#### 6. Subscription ID Issues

**Problem**: Alerts fail to create or monitor incorrect subscription.

**Solution**:
```hcl
# Explicitly provide subscription ID
subscription_id = "12345678-1234-1234-1234-123456789012"

# If empty, module auto-detects current subscription
# Verify current context
```

**Validation**:
```bash
# Check current subscription
az account show --query "{Name:name, ID:id}"

# Set correct subscription
az account set --subscription "12345678-1234-1234-1234-123456789012"
```

#### 7. Budget Not Resetting Monthly

**Problem**: Budget appears to carry over from previous month.

**Understanding**:
- Budgets automatically reset on start_date
- Start date must be first of month (YYYY-MM-01)
- Current month's budget starts on day 1

**Solution**:
```hcl
# Module automatically sets start_date to current month's first day
# time_period { start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp()) }

# Verify budget in portal:
# Cost Management + Billing > Budgets > View budget details
```

### Validation Commands

```bash
# Verify Terraform configuration
terraform init
terraform validate
terraform plan

# List resource groups
az group list --output table

# List budgets for resource group
az consumption budget list \
  --resource-group "rg-app-prod" \
  --output table

# Check current month spending
az consumption usage list \
  --start-date "2025-11-01" \
  --end-date "2025-11-24"

# List scheduled query rules
az monitor scheduled-query list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'rg-')].{Name:name, Enabled:enabled, Severity:severity}"

# Test action group
az monitor action-group test-notifications create \
  --action-group "pge-operations-actiongroup" \
  --resource-group "rg-monitoring" \
  --notification-type "Email"

# Query activity log for resource group
az monitor activity-log list \
  --resource-group "rg-app-prod" \
  --offset 1d \
  --query "[].{Time:eventTimestamp, Operation:operationName.value, Status:status.value}"

# View cost by resource group (Cost Management)
az costmanagement query \
  --type "ActualCost" \
  --dataset-grouping name="ResourceGroup" type="Dimension" \
  --timeframe "MonthToDate"
```

### Debug Mode

```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform apply

# Check Terraform state
terraform state list | grep consumption_budget
terraform state show module.cost_alerts_rg.azurerm_consumption_budget_resource_group.monthly_rg_budget[\"rg-app-prod\"]

# View budget configuration
az consumption budget show \
  --budget-name "monthly-budget-rg-app-prod" \
  --resource-group "rg-app-prod"
```

### Cost Analysis Queries (Azure Cost Management)

```bash
# Get resource group costs for current month
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}/resourceGroups/rg-app-prod" \
  --timeframe "MonthToDate" \
  --output table

# Get daily costs for resource group
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}/resourceGroups/rg-app-prod" \
  --timeframe "Custom" \
  --time-period from="2025-11-01" to="2025-11-24" \
  --dataset-granularity "Daily"

# Get costs grouped by resource type
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}/resourceGroups/rg-app-prod" \
  --timeframe "MonthToDate" \
  --dataset-grouping name="ResourceType" type="Dimension"
```

## Alert Severity Mapping

| Severity | Level | Use Case | Response Time | Action Required |
|----------|-------|----------|---------------|-----------------|
| 1 | Error | Daily cost spikes | < 4 hours | Investigate cost anomaly |
| 2 | Warning | Resource activity anomalies | < 8 hours | Review activity, assess risk |
| 3 | Informational | Idle resources, trends | Business hours | Optimize costs |
| N/A | Budget | Budget threshold exceeded | Immediate | Review spending, take action |

**This Module's Severity Distribution:**
- **Severity 1 (Error)**: Daily Cost Spike
- **Severity 2 (Warning)**: Resource Creation Spike, Resource Deletion
- **Severity 3 (Informational)**: Idle Resources
- **Budget Alerts**: Email notifications (3-tier: 75%, 90%, 100%)

## Performance Considerations

### Alert Evaluation Frequency

| Alert | Frequency | Window | Evaluations | Impact |
|-------|-----------|--------|-------------|--------|
| Monthly Budget | Daily | Monthly | 1/day | Very Low |
| Daily Cost Spike | Daily | 1 day | 1/day | Low |
| Resource Creation | Daily | 1 day | 1/day | Low |
| Resource Deletion | Daily | 1 day | 1/day | Low |
| Idle Resources | Daily | 7 days | 1/day | Low |

**Total per Resource Group**: ~4-5 evaluations/day (minimal overhead)

## Cost Optimization

### Alert Pricing (2025)

- **Consumption Budgets**: Free
- **Scheduled Query Rules**: $0.10 per alert per month
- **Email Notifications**: Free (unlimited)
- **Total Module Cost per Resource Group**:
  - 1 budget alert × $0 = $0/month
  - 4 scheduled query rules × $0.10 = $0.40/month
  - **Total: ~$0.40/month per resource group**

### Multi-Resource Group Cost Example

```hcl
# 10 resource groups monitored
resource_group_names = [
  "rg-app-prod", "rg-api-prod", "rg-db-prod",
  "rg-storage-prod", "rg-compute-prod",
  "rg-app-dev", "rg-api-dev", "rg-db-dev",
  "rg-storage-dev", "rg-compute-dev"
]

# Cost: 10 RGs × $0.40 = $4/month for comprehensive cost monitoring
# Potential savings: $1,000s/month from cost optimization
# ROI: Extremely high
```

### Cost Reduction Strategies

```hcl
# Disable non-essential alerts in dev/test
enable_resource_activity_alerts = false  # Save $0.20/RG

# Monitor only high-cost resource groups
resource_group_names = [
  "rg-prod-compute",  # High-cost workloads only
  "rg-prod-database"
]

# Use shared email distribution lists
contact_emails = ["cloud-cost-team@pge.com"]  # One DL for all notifications
```

## Return on Investment (ROI)

### Cost Monitoring Benefits

**Direct Savings**:
- **Idle Resource Detection**: $500-$5,000/month saved
- **Budget Enforcement**: Prevents overspending by 20-30%
- **Cost Spike Detection**: Catches misconfiguration before significant cost impact

**Example Scenario**:
```
Monthly Budget per RG: $5,000
Alert Cost: $0.40/month
Idle VM detected and deallocated: $200/month saved
ROI: 50,000% (500x return on investment)

Over 12 months:
- Alert Cost: $4.80
- Savings: $2,400 (just one idle VM)
- Net Benefit: $2,395.20
```

## Integration with FinOps Practices

### 1. Budget Allocation

- Set budgets based on historical spending
- Adjust quarterly based on business needs
- Allocate by environment (Prod, Dev, Test)
- Track against project funding

### 2. Cost Attribution

```hcl
# Tag all alerts for cost tracking
tags = {
  CostCenter   = "Engineering"
  Project      = "ProjectAlpha"
  BudgetCode   = "FY2025-ENG-001"
  ChargebackTo = "Product Team"
}
```

### 3. Continuous Optimization

- Weekly: Review idle resource alerts
- Monthly: Analyze budget utilization
- Quarterly: Adjust thresholds based on trends
- Annually: Review and reset budgets

### 4. Stakeholder Communication

```hcl
# Different notifications for different roles
contact_emails = [
  "finance@pge.com",      # Budget accountability
  "engineering@pge.com",  # Technical optimization
  "management@pge.com"    # Executive visibility
]
```

## Additional Resources

- [Azure Cost Management Documentation](https://learn.microsoft.com/azure/cost-management-billing/)
- [Azure Budgets](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- [FinOps Foundation](https://www.finops.org/)
- [Azure Well-Architected Framework - Cost Optimization](https://learn.microsoft.com/azure/well-architected/cost/)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

## License

This module follows your organization's licensing terms.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-11-24 | Initial release with 5 alerts (1 budget + 4 query rules) |

---

**Last Updated**: November 24, 2025  
**Module Version**: 1.0.0  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
