# Azure Cost Management - Subscription Level AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure Cost Management at the Subscription Level**. It provides enterprise-grade cost monitoring, budget enforcement, service-specific cost tracking, and administrative oversight to help organizations manage cloud spending at scale.

This module focuses on **subscription-level cost monitoring**, providing the highest level of financial governance across your entire Azure subscription. It complements resource group-level monitoring by offering organization-wide visibility into spending patterns, service costs, and budget compliance.

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

- **1 Budget Alert** with 4-tier notifications (75%, 90%, 100% actual + 90% forecasted)
- **6 Scheduled Query Rules** for cost trends and service-specific monitoring
- **3 Activity Log Alerts** for cost management configuration changes
- **Customizable Thresholds** for all alerts
- **Enable/Disable Flags** for flexible alert management
- **Monthly Budget Tracking** per subscription
- **Forecasted Budget Alerts** for proactive cost management
- **Daily Cost Spike Detection** for anomaly detection
- **Service-Specific Monitoring** (Compute, Storage, Database, Networking)
- **Unused Resource Detection** for cost optimization
- **Configuration Change Tracking** (budgets, exports)
- **Multi-Subscription Support** with individual budgets
- **Email Notifications** for cost alerts
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 💰 Budget Alerts
- Monthly Subscription Budget (4-tier: 75%, 90%, 100% actual + 90% forecasted)

### 📊 Service Cost Alerts
- Compute Services Cost Monitoring
- Storage Services Cost Monitoring
- Database Services Cost Monitoring
- Networking Services Cost Monitoring

### 📈 Cost Trend Alerts
- Daily Cost Spike Detection
- Unused Resources Detection

### 🔧 Administrative Alerts
- Budget Creation Monitoring
- Budget Deletion Tracking
- Cost Export Configuration Changes

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure Subscription(s) to monitor
- Azure Monitor Action Group (pre-configured)
- **Cost Management data** (typically available after 24-48 hours)
- **Email addresses** for budget notifications
- Reader permissions on subscriptions
- Appropriate permissions to create budgets and alerts

## Usage

### Basic Example

```hcl
module "cost_alerts_subscription" {
  source = "./modules/metricAlerts/costmanagement-subscription"

  # Resource Configuration
  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Subscription IDs to Monitor
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Budget Configuration
  subscription_monthly_cost_threshold = 50000  # $50,000/month

  # Email Notifications
  contact_emails = [
    "finance@pge.com",
    "cfo@pge.com",
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
module "cost_alerts_prod_subscription" {
  source = "./modules/metricAlerts/costmanagement-subscription"

  # Resource Configuration
  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-cost-actiongroup"
  location                         = "West US 3"

  # Production Subscription
  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Enterprise Budget
  subscription_monthly_cost_threshold = 100000  # $100K/month
  subscription_daily_cost_threshold   = 5000    # $5K/day spike alert

  # Earlier Warning Notifications
  budget_alert_percentage_first    = 70   # Alert at 70% ($70K)
  budget_alert_percentage_second   = 85   # Alert at 85% ($85K)
  budget_alert_percentage_critical = 100  # Alert at 100% ($100K)

  # Service-Specific Thresholds
  compute_cost_threshold    = 40000  # $40K/month for compute
  storage_cost_threshold    = 15000  # $15K/month for storage
  database_cost_threshold   = 30000  # $30K/month for databases
  networking_cost_threshold = 10000  # $10K/month for networking

  # Email Notifications to Leadership
  contact_emails = [
    "finance-vp@pge.com",
    "engineering-vp@pge.com",
    "cfo@pge.com",
    "cloudops-team@pge.com"
  ]

  # Enable All Alerts
  enable_subscription_cost_alerts = true
  enable_cost_increase_alerts     = true
  enable_service_cost_alerts      = true
  enable_export_alerts            = true

  tags = {
    Environment     = "Production"
    CostCenter      = "Engineering"
    CriticalityTier = "Tier1"
    BudgetYear      = "FY2025"
  }
}
```

### Multi-Subscription Enterprise Example

```hcl
module "cost_alerts_enterprise" {
  source = "./modules/metricAlerts/costmanagement-subscription"

  resource_group_name              = "rg-monitoring"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "enterprise-cost-actiongroup"
  location                         = "West US 3"

  # Monitor Multiple Subscriptions
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012",  # Production
    "87654321-4321-4321-4321-210987654321",  # Staging
    "11111111-2222-3333-4444-555555555555"   # Development
  ]

  # Aggregate Budget Across Subscriptions
  subscription_monthly_cost_threshold = 150000  # $150K/month total

  # Service-Specific Monitoring
  compute_cost_threshold    = 60000
  storage_cost_threshold    = 20000
  database_cost_threshold   = 40000
  networking_cost_threshold = 15000

  # Comprehensive Notifications
  contact_emails = [
    "finance-team@pge.com",
    "cloud-governance@pge.com",
    "executive-team@pge.com"
  ]

  tags = {
    Environment = "Multi-Subscription"
    Scope       = "Enterprise"
    CostCenter  = "CloudOps"
  }
}
```

### Development Subscription Example

```hcl
module "cost_alerts_dev_subscription" {
  source = "./modules/metricAlerts/costmanagement-subscription"

  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-cost-actiongroup"
  location                         = "West US 3"

  subscription_ids = ["11111111-2222-3333-4444-555555555555"]

  # Lower Budget for Development
  subscription_monthly_cost_threshold = 10000  # $10K/month
  subscription_daily_cost_threshold   = 500    # $500/day

  # More Lenient Service Thresholds
  compute_cost_threshold    = 4000
  storage_cost_threshold    = 2000
  database_cost_threshold   = 2000
  networking_cost_threshold = 1000

  # Enable cost alerts only
  enable_subscription_cost_alerts = true
  enable_cost_increase_alerts     = true
  enable_service_cost_alerts      = false  # Skip service-specific in dev
  enable_export_alerts            = false  # Skip admin alerts in dev

  contact_emails = ["dev-leads@pge.com", "finance@pge.com"]

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

### Department/Business Unit Example

```hcl
module "cost_alerts_department" {
  source = "./modules/metricAlerts/costmanagement-subscription"

  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dept-cost-actiongroup"
  location                         = "West US 3"

  # Department-Owned Subscription
  subscription_ids = ["aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"]

  # Department Budget Allocation
  subscription_monthly_cost_threshold = 75000  # $75K/month

  # Tight Budget Control
  budget_alert_percentage_first    = 65   # Alert at $48,750
  budget_alert_percentage_second   = 80   # Alert at $60,000
  budget_alert_percentage_critical = 95   # Alert at $71,250

  # Service Breakdown Aligned with Department Usage
  compute_cost_threshold    = 30000  # Heavy compute usage
  storage_cost_threshold    = 10000
  database_cost_threshold   = 25000  # Analytics workloads
  networking_cost_threshold = 8000

  contact_emails = [
    "dept-finance@pge.com",
    "dept-manager@pge.com",
    "it-chargeback@pge.com"
  ]

  tags = {
    Department  = "DataScience"
    CostCenter  = "DS-001"
    BudgetOwner = "dept-manager@pge.com"
  }
}
```

### Cost Optimization Focus Example

```hcl
module "cost_alerts_optimization" {
  source = "./modules/metricAlerts/costmanagement-subscription"

  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "cost-optimization-actiongroup"
  location                         = "West US 3"

  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Standard Budget
  subscription_monthly_cost_threshold = 50000

  # Focus on Cost Optimization
  enable_cost_increase_alerts = true  # Detect spikes
  enable_service_cost_alerts  = true  # Monitor service costs

  # Lower service thresholds to identify optimization opportunities
  compute_cost_threshold    = 15000  # Flag high compute costs
  storage_cost_threshold    = 8000   # Identify storage bloat
  database_cost_threshold   = 12000  # Monitor DB costs
  networking_cost_threshold = 5000   # Track egress costs

  contact_emails = [
    "finops-team@pge.com",
    "cloud-architects@pge.com"
  ]

  tags = {
    Purpose         = "CostOptimization"
    OptimizationGoal = "Reduce20Percent"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `subscription_ids` | `list(string)` | **REQUIRED** - List of subscription IDs to monitor (empty list = no alerts created) |

### Core Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where alerts will be created |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group name for notifications |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
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
| `contact_emails` | `list(string)` | `["finance@pge.com", "operations@pge.com"]` | Email addresses for budget notifications |

### Alert Enable/Disable Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_subscription_cost_alerts` | `bool` | `true` | Enable monthly budget alerts |
| `enable_cost_increase_alerts` | `bool` | `true` | Enable daily cost spike and unused resource alerts |
| `enable_service_cost_alerts` | `bool` | `true` | Enable service-specific cost monitoring |
| `enable_export_alerts` | `bool` | `true` | Enable cost export and configuration alerts |

### Budget Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `subscription_monthly_cost_threshold` | `number` | `10000` | Monthly budget per subscription (USD) |
| `subscription_daily_cost_threshold` | `number` | `500` | Daily cost spike threshold (USD) |
| `budget_alert_percentage_first` | `number` | `75` | First notification threshold (%) |
| `budget_alert_percentage_second` | `number` | `90` | Second notification threshold (%) |
| `budget_alert_percentage_critical` | `number` | `100` | Critical notification threshold (%) |

### Service-Specific Cost Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `compute_cost_threshold` | `number` | `3000` | Monthly compute services cost threshold (USD) |
| `storage_cost_threshold` | `number` | `1500` | Monthly storage services cost threshold (USD) |
| `database_cost_threshold` | `number` | `2000` | Monthly database services cost threshold (USD) |
| `networking_cost_threshold` | `number` | `1000` | Monthly networking services cost threshold (USD) |

### Cost Trend Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `weekly_cost_increase_threshold_percent` | `number` | `25` | Weekly cost increase percentage threshold |

### Evaluation Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `evaluation_frequency_daily` | `string` | `"P1D"` | Daily evaluation frequency (1 day) |
| `window_duration_daily` | `string` | `"P1D"` | Daily window duration (1 day) |
| `window_duration_weekly` | `string` | `"P7D"` | Weekly window duration (7 days) |

## Alert Details

### Budget Alerts

#### 1. Monthly Subscription Budget Alert
- **Type**: Azure Consumption Budget
- **Time Grain**: Monthly
- **Scope**: Entire Subscription
- **Threshold**: Configurable (default: $10,000/month)
- **Notifications**: 4-tier threshold system
  - **75% Actual ($7,500)**: Early warning - review spending trends
  - **90% Actual ($9,000)**: Urgent - action required soon
  - **100% Actual ($10,000)**: Critical - budget exceeded
  - **90% Forecasted ($9,000)**: Proactive - projected to exceed budget
- **Delivery**: Email notifications to configured addresses
- **Description**: Tracks actual monthly spending and forecasted spending against budget for the entire subscription. Forecasted alerts provide early warning before budget is exceeded based on spending trends.

**When to Adjust**:
- **Enterprise Production**: Set to $100K-$500K+ based on organization size
- **Small Business**: Set to $5K-$20K for cost control
- **Development Subscription**: Set to $10K-$30K
- **Percentage thresholds**: Adjust for tighter control (60%, 80%, 100%) or looser monitoring (80%, 95%, 110%)

**Budget Calculation Example**:
```
Monthly Budget: $50,000
├─ 75% Actual Alert: $37,500
├─ 90% Actual Alert: $45,000
├─ 90% Forecasted Alert: Projected to reach $45,000 by month end
└─ 100% Actual Alert: $50,000 (budget exceeded)
```

**Forecasted Alert Benefits**:
- Predicts budget overrun before it happens
- Based on spending velocity and trends
- Allows proactive cost optimization
- Typically triggers 5-10 days before actual budget exceeded

### Scheduled Query Rules

#### 2. Daily Cost Spike Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: Configurable (default: $500/day)
- **Severity**: 1 (Error)
- **Scope**: Entire Subscription
- **Description**: Detects unusual daily cost increases at the subscription level that may indicate cost anomalies, misconfigurations, or unexpected scaling events.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where SubscriptionId == "{subscription_id}"
| where CategoryValue == "Administrative"
| where OperationNameValue contains "Microsoft.Consumption"
| summarize ActivityCount = count() by bin(TimeGenerated, 1h)
| where ActivityCount > 0
```

**When to Adjust**:
- **Enterprise**: Set to 10-15% of daily average (monthly budget / 30)
- **Variable workloads**: Set to 3x daily average
- **Stable workloads**: Set to 2x daily average

**Common Causes**:
- Unexpected autoscaling across multiple services
- Large data transfers or egress
- New service deployments
- Premium tier upgrades

#### 3. Compute Services Cost Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: $3,000/month (default)
- **Severity**: 2 (Warning)
- **Scope**: Multiple Subscriptions
- **Services Monitored**: Microsoft.Compute, Microsoft.Web, Microsoft.ClassicCompute
- **Description**: Monitors compute-related service activity to detect high resource creation or scaling that impacts costs.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where ResourceProviderValue in ("Microsoft.Compute", "Microsoft.Web", "Microsoft.ClassicCompute")
| where ActivityStatusValue == "Success"
| where OperationNameValue contains "write" or OperationNameValue contains "create"
| summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
| where ResourceActivity > 10
```

**When to Adjust**:
- **Compute-heavy workloads**: Increase to 50-60% of monthly budget
- **Serverless architecture**: Lower threshold (10-20% of budget)
- **High-performance computing**: Set to 70-80% of budget

**Optimization Opportunities**:
- Right-size VMs (use Azure Advisor)
- Use Azure Reservations for steady-state workloads
- Implement auto-shutdown for dev/test VMs
- Consider Azure Spot VMs for fault-tolerant workloads

#### 4. Storage Services Cost Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: $1,500/month (default)
- **Severity**: 2 (Warning)
- **Scope**: Multiple Subscriptions
- **Services Monitored**: Microsoft.Storage, Microsoft.RecoveryServices, Microsoft.Backup
- **Description**: Monitors storage-related service activity including storage accounts, backup services, and recovery services.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where ResourceProviderValue in ("Microsoft.Storage", "Microsoft.RecoveryServices", "Microsoft.Backup")
| where ActivityStatusValue == "Success"
| where OperationNameValue contains "write" or OperationNameValue contains "create"
| summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
| where ResourceActivity > 5
```

**When to Adjust**:
- **Data-intensive applications**: Increase to 30-40% of monthly budget
- **Low data volume**: Set to 5-10% of budget
- **Backup-heavy**: Consider separate monitoring for backup costs

**Optimization Opportunities**:
- Move infrequently accessed data to Cool/Archive tiers
- Delete old snapshots and backups
- Review blob lifecycle management policies
- Optimize backup retention policies
- Use Azure Data Box for large data transfers

#### 5. Database Services Cost Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: $2,000/month (default)
- **Severity**: 2 (Warning)
- **Scope**: Multiple Subscriptions
- **Services Monitored**: Microsoft.Sql, Microsoft.DocumentDB, Microsoft.Cache, Microsoft.DataMigration
- **Description**: Monitors database-related service activity including SQL Database, Cosmos DB, Redis Cache, and migration services.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where ResourceProviderValue in ("Microsoft.Sql", "Microsoft.DocumentDB", "Microsoft.Cache", "Microsoft.DataMigration")
| where ActivityStatusValue == "Success"
| where OperationNameValue contains "write" or OperationNameValue contains "create"
| summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
| where ResourceActivity > 3
```

**When to Adjust**:
- **Database-heavy applications**: Increase to 40-50% of monthly budget
- **Analytics workloads**: Higher threshold for Cosmos DB
- **Microservices**: May need higher threshold for many Redis instances

**Optimization Opportunities**:
- Use SQL elastic pools for multiple databases
- Implement Cosmos DB autoscale
- Right-size database DTUs/vCores
- Use Azure SQL serverless for dev/test
- Optimize indexing to reduce RU consumption

#### 6. Networking Services Cost Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 1 day
- **Threshold**: $1,000/month (default)
- **Severity**: 2 (Warning)
- **Scope**: Multiple Subscriptions
- **Services Monitored**: Microsoft.Network, Microsoft.Cdn, Microsoft.ApiManagement
- **Description**: Monitors networking-related service activity including VNets, Load Balancers, CDN, and API Management.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(1d)
| where ResourceProviderValue in ("Microsoft.Network", "Microsoft.Cdn", "Microsoft.ApiManagement")
| where ActivityStatusValue == "Success"
| where OperationNameValue contains "write" or OperationNameValue contains "create"
| summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
| where ResourceActivity > 2
```

**When to Adjust**:
- **High-bandwidth applications**: Increase threshold
- **Global distribution**: Higher for CDN costs
- **API-heavy architecture**: Consider API Management costs

**Optimization Opportunities**:
- Review data egress patterns (most expensive)
- Use CDN for static content
- Optimize API Management tier selection
- Consider VNet peering vs VPN costs
- Delete unused public IPs and NICs

#### 7. Unused Resources Cost Alert
- **Query Type**: AzureActivity
- **Evaluation Frequency**: Daily (P1D)
- **Window Duration**: 7 days
- **Threshold**: 5+ unused resources
- **Severity**: 3 (Informational)
- **Scope**: Multiple Subscriptions
- **Description**: Identifies potentially unused or idle resources across the subscription for cost optimization opportunities.

**KQL Query Logic**:
```kql
AzureActivity
| where TimeGenerated >= ago(7d)
| where ResourceProviderValue in ("Microsoft.Compute", "Microsoft.Storage")
| where ActivityStatusValue == "Success"
| where OperationNameValue contains "delete" or OperationNameValue contains "deallocate"
| summarize UnusedActivity = count() by ResourceId
| where UnusedActivity > 0
| summarize TotalUnused = count()
| where TotalUnused > 5
```

**When to Adjust**:
- **Cost-sensitive**: Set to 2-3 for aggressive optimization
- **Production**: Higher threshold (10+) to avoid false positives
- **Development**: Very high threshold or disable

**Cost Savings Potential**: $500-$5,000/month

### Activity Log Alerts

#### 8. Budget Creation Alert
- **Operation**: `Microsoft.Consumption/budgets/write`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors creation of new budgets for governance and audit purposes.

**Use Cases**:
- Track who creates budgets
- Ensure proper budget allocation
- Audit trail for compliance
- Prevent unauthorized budget creation

#### 9. Budget Deletion Alert
- **Operation**: `Microsoft.Consumption/budgets/delete`
- **Category**: Administrative
- **Level**: Warning
- **Scope**: Subscription
- **Description**: Triggers when a budget is deleted, which could indicate loss of cost control.

**Response Actions**:
- Verify deletion was intentional
- Investigate if unauthorized
- Recreate budget if accidental
- Review RBAC permissions

#### 10. Cost Export Configuration Changes
- **Operation**: `Microsoft.CostManagement/exports/write`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors changes to cost export configurations used for financial reporting and analysis.

**Use Cases**:
- Track changes to cost export schedules
- Ensure exports align with reporting needs
- Audit trail for financial compliance
- Detect unauthorized configuration changes

## Best Practices

### 1. Subscription ID Configuration

```hcl
# Always provide specific subscription IDs
subscription_ids = [
  "12345678-1234-1234-1234-123456789012"
]

# Empty list = no alerts created
subscription_ids = []  # Use only for testing
```

### 2. Budget Allocation Strategy

#### Enterprise Budget Planning
```hcl
# Allocate based on organizational structure
# Example: $1M annual budget = $83,333/month

subscription_monthly_cost_threshold = 83333

# Conservative thresholds for executive visibility
budget_alert_percentage_first    = 70   # $58,333
budget_alert_percentage_second   = 85   # $70,833
budget_alert_percentage_critical = 95   # $79,167
```

#### Environment-Based Budgets
```hcl
# Production: Largest allocation
module "prod_subscription" {
  subscription_monthly_cost_threshold = 100000  # $100K
  budget_alert_percentage_first       = 75
}

# Staging: Moderate allocation
module "staging_subscription" {
  subscription_monthly_cost_threshold = 20000  # $20K
  budget_alert_percentage_first       = 80
}

# Development: Smallest allocation
module "dev_subscription" {
  subscription_monthly_cost_threshold = 10000  # $10K
  budget_alert_percentage_first       = 90
}
```

### 3. Forecasted Budget Alerts

```hcl
# Forecasted alerts provide 5-10 days advance warning
# Based on current spending velocity

# Example: If spending $2K/day in a $50K budget:
# Day 20: $40K spent (80% actual)
# Forecast: Will reach $60K by month end (120% of budget)
# 90% Forecasted Alert: Triggers around day 18-20

# Allows time to:
# - Optimize costs
# - Request budget increase
# - Defer non-critical deployments
```

### 4. Service-Specific Threshold Setting

```hcl
# Analyze your cost breakdown first
# Example breakdown of $100K monthly budget:

compute_cost_threshold    = 40000  # 40% - VMs, App Services
storage_cost_threshold    = 15000  # 15% - Storage, Backup
database_cost_threshold   = 30000  # 30% - SQL, Cosmos DB
networking_cost_threshold = 10000  # 10% - Egress, Load Balancers
# Remaining 5% - Other services

# Set thresholds at 80-90% of expected spend
```

### 5. Multi-Subscription Governance

```hcl
# Standardize budgets by subscription type
locals {
  subscription_budgets = {
    production = 100000
    staging    = 20000
    development = 10000
    sandbox    = 5000
  }
}

# Apply consistent alerting
subscription_ids = [
  "prod-sub-id",
  "staging-sub-id"
]
```

### 6. Email Notification Strategy

```hcl
# Tier notifications by severity
contact_emails = [
  "finance-team@pge.com",        # All budget alerts
  "cloudops-team@pge.com",       # Operations
  "engineering-vp@pge.com",      # 90% and above
  "cfo@pge.com"                  # 100% and forecasted
]

# Consider using Office 365 groups or Teams channels
contact_emails = [
  "azure-cost-alerts@pge.com"  # Distribution list
]
```

### 7. Daily Cost Spike Calculation

```hcl
# Calculate appropriate daily threshold from monthly budget
# Monthly: $60,000
# Daily average: $60,000 / 30 = $2,000
# Spike threshold: 2-3x daily average = $4,000-$6,000

subscription_monthly_cost_threshold = 60000
subscription_daily_cost_threshold   = 5000  # 2.5x daily average

# For highly variable workloads (autoscaling):
subscription_daily_cost_threshold   = 6000  # 3x to reduce false positives
```

### 8. Cost Optimization Workflow

```hcl
# Enable optimization-focused alerts
enable_cost_increase_alerts = true
enable_service_cost_alerts  = true

# Regular review cadence
# Daily: Check unused resources alert
# Weekly: Review service-specific cost trends
# Monthly: Analyze budget utilization and adjust
# Quarterly: Reset budgets and thresholds
```

### 9. Tagging for Cost Attribution

```hcl
tags = {
  CostCenter       = "Engineering"
  BusinessUnit     = "Product Development"
  BudgetOwner      = "vp-engineering@pge.com"
  FiscalYear       = "FY2025"
  BudgetCode       = "BUDGET-2025-ENG"
  ApprovalLevel    = "VP"
  ChargebackTo     = "Product Team"
  ReviewFrequency  = "Monthly"
}
```

### 10. Integration with Azure Cost Management

```hcl
# Use this module alongside:
# - Azure Cost Management + Billing portal for detailed analysis
# - Cost allocation with tags
# - Reservation recommendations
# - Azure Advisor cost recommendations
# - Cost export to storage for Power BI analysis
```

## Troubleshooting

### Common Issues

#### 1. No Alerts Being Created

**Problem**: No budget or query alerts appearing in Azure Monitor.

**Solution**:
```hcl
# Ensure subscription_ids is not empty
subscription_ids = ["12345678-1234-1234-1234-123456789012"]  # REQUIRED

# Verify subscription exists and you have access
# Use exact subscription GUID

# Check action group exists
action_group_resource_group_name = "rg-monitoring"
action_group                     = "existing-action-group"
```

**Validation**:
```bash
# List subscriptions
az account list --query "[].{Name:name, ID:id}" --output table

# Verify access to subscription
az account show --subscription "12345678-1234-1234-1234-123456789012"
```

#### 2. Budget Alerts Not Triggering

**Problem**: Cost exceeds threshold but no email received.

**Solution**:
```hcl
# Verify email addresses are correct (no typos)
contact_emails = ["valid-email@pge.com"]

# Check spam/junk folder
# Budget emails come from: msonlineservicesteam@microsoft.com

# Verify cost data is available (24-48 hour delay)
# Budget evaluates once per day (not real-time)
```

**Diagnostics**:
```bash
# Check if budget exists
az consumption budget list \
  --subscription "12345678-1234-1234-1234-123456789012" \
  --query "[].{Name:name, Amount:amount}"

# View current spending
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/12345678-1234-1234-1234-123456789012" \
  --timeframe "MonthToDate"
```

#### 3. Forecasted Budget Alert Issues

**Problem**: Forecasted alert not triggering or seems inaccurate.

**Understanding**:
- Forecasted alerts require 30+ days of historical data
- Forecast accuracy improves over time
- Based on spending velocity and trends
- May not trigger if spending is very consistent

**Solution**:
```bash
# View forecast in Azure portal:
# Cost Management + Billing > Cost Analysis > Forecast view

# Verify budget has forecast notification configured
az consumption budget show \
  --budget-name "monthly-budget-{sub-id}" \
  --subscription "{sub-id}"
```

#### 4. Service-Specific Alerts False Positives

**Problem**: Service cost alerts triggering during normal operations.

**Solution**:
```hcl
# Analyze actual service costs first
# Azure portal: Cost Management > Cost by service

# Adjust thresholds based on observed patterns
compute_cost_threshold = 5000  # Increase from 3000

# Or disable for certain environments
enable_service_cost_alerts = false  # In dev subscription
```

#### 5. Query-Based Alerts Not Firing

**Problem**: Daily cost spike or service alerts not triggering.

**Diagnostics**:
```bash
# Test KQL query directly
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureActivity | where SubscriptionId == '{sub-id}' | take 10"

# Verify Activity Log is enabled (it's on by default)
```

**Solution**:
```hcl
# Ensure Activity Log retention is sufficient (90 days default)
# Wait 30 minutes after deployment for first evaluation
# Verify subscription has activity in the time window
```

#### 6. Multi-Subscription Alert Issues

**Problem**: Alerts not created for all subscriptions.

**Solution**:
```hcl
# Verify all subscription IDs are valid GUIDs
subscription_ids = [
  "12345678-1234-1234-1234-123456789012",
  "87654321-4321-4321-4321-210987654321"
]

# Check you have permissions on all subscriptions
# Minimum: Reader role + Cost Management Reader role

# Review Terraform output for errors
terraform apply
```

#### 7. Budget Not Resetting Monthly

**Problem**: Budget appears stuck or not resetting.

**Understanding**:
- Budgets automatically reset on start_date
- Start date is always first of current month
- Budget tracking starts from day 1

**Solution**:
```bash
# Verify budget start date
az consumption budget show \
  --budget-name "monthly-budget-{sub-id}" \
  --subscription "{sub-id}" \
  --query "timePeriod.startDate"

# Should show: "YYYY-MM-01T00:00:00Z" (first of current month)
```

### Validation Commands

```bash
# Verify Terraform configuration
terraform init
terraform validate
terraform plan

# List subscriptions
az account list --output table

# Check subscription access
az account show --subscription "12345678-1234-1234-1234-123456789012"

# List budgets for subscription
az consumption budget list \
  --subscription "12345678-1234-1234-1234-123456789012"

# View current month spending
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/12345678-1234-1234-1234-123456789012" \
  --timeframe "MonthToDate"

# View cost by service
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/12345678-1234-1234-1234-123456789012" \
  --timeframe "MonthToDate" \
  --dataset-grouping name="ServiceName" type="Dimension"

# List scheduled query rules
az monitor scheduled-query list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'subscription')].{Name:name, Enabled:enabled}"

# List activity log alerts
az monitor activity-log alert list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'CostManagement')].{Name:name, Enabled:enabled}"

# Test action group
az monitor action-group test-notifications create \
  --action-group "pge-operations-actiongroup" \
  --resource-group "rg-monitoring" \
  --notification-type "Email"
```

### Debug Mode

```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform apply

# Check Terraform state
terraform state list | grep consumption_budget
terraform state show 'module.cost_alerts_subscription.azurerm_consumption_budget_subscription.monthly_budget["12345678-1234-1234-1234-123456789012"]'

# View budget details
az consumption budget show \
  --budget-name "monthly-budget-12345678-1234-1234-1234-123456789012" \
  --subscription "12345678-1234-1234-1234-123456789012"
```

### Cost Analysis Commands

```bash
# Get subscription cost for current month
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}" \
  --timeframe "MonthToDate"

# Get daily costs
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}" \
  --timeframe "Custom" \
  --time-period from="2025-11-01" to="2025-11-24" \
  --dataset-granularity "Daily"

# Get cost by resource group
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}" \
  --timeframe "MonthToDate" \
  --dataset-grouping name="ResourceGroup" type="Dimension"

# Get cost by service (compute, storage, etc.)
az costmanagement query \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}" \
  --timeframe "MonthToDate" \
  --dataset-grouping name="ServiceName" type="Dimension"

# Get cost forecast
az costmanagement forecast \
  --type "ActualCost" \
  --scope "/subscriptions/{sub-id}" \
  --timeframe "Custom" \
  --time-period from="2025-11-01" to="2025-11-30"
```

## Alert Severity Mapping

| Severity | Level | Use Case | Response Time | Action Required |
|----------|-------|----------|---------------|-----------------|
| 1 | Error | Daily cost spikes | < 4 hours | Investigate anomaly immediately |
| 2 | Warning | Service cost trends | < 8 hours | Review service costs, optimize |
| 3 | Informational | Unused resources | Business hours | Identify and remove waste |
| N/A | Budget | Budget thresholds | Immediate | Review spending, take corrective action |

**This Module's Severity Distribution:**
- **Severity 1 (Error)**: Daily Cost Spike
- **Severity 2 (Warning)**: Compute Cost, Storage Cost, Database Cost, Networking Cost
- **Severity 3 (Informational)**: Unused Resources
- **Budget Alerts**: Email notifications (4-tier: 75%, 90%, 100% actual + 90% forecasted)
- **Activity Log Alerts**: Administrative operations (budget/export changes)

## Performance Considerations

### Alert Evaluation Frequency

| Alert | Frequency | Window | Evaluations | Impact |
|-------|-----------|--------|-------------|--------|
| Monthly Budget | Daily | Monthly | 1/day | Very Low |
| Daily Cost Spike | Daily | 1 day | 1/day per subscription | Low |
| Compute Cost | Daily | 1 day | 1/day (all subs) | Low |
| Storage Cost | Daily | 1 day | 1/day (all subs) | Low |
| Database Cost | Daily | 1 day | 1/day (all subs) | Low |
| Networking Cost | Daily | 1 day | 1/day (all subs) | Low |
| Unused Resources | Daily | 7 days | 1/day (all subs) | Low |

**Total Evaluations**: ~6-7 per day (minimal overhead)

## Cost Optimization

### Alert Pricing (2025)

- **Consumption Budgets**: Free
- **Scheduled Query Rules**: $0.10 per alert per month
- **Activity Log Alerts**: Free
- **Email Notifications**: Free (unlimited)
- **Total Module Cost per Subscription**:
  - 1 budget alert × $0 = $0/month
  - 6 scheduled query rules × $0.10 = $0.60/month
  - 3 activity log alerts × $0 = $0/month
  - **Total: ~$0.60/month per subscription**

### Multi-Subscription Cost Example

```hcl
# 3 subscriptions monitored
subscription_ids = [
  "prod-sub-id",
  "staging-sub-id",
  "dev-sub-id"
]

# Per-subscription alerts: 3 × $0.60 = $1.80/month
# Shared alerts (service-specific): 4 × $0.10 = $0.40/month
# Total: ~$2.20/month for comprehensive monitoring

# Potential savings: $10,000s-$100,000s per month
# ROI: Extremely high (>100,000%)
```

### Cost Reduction Strategies

```hcl
# Disable service-specific alerts if not needed
enable_service_cost_alerts = false  # Save $0.40/month

# Disable export monitoring in non-production
enable_export_alerts = false  # Save $0/month (already free)

# Monitor only production subscriptions
subscription_ids = ["prod-sub-id"]  # Reduce to 1 subscription
```

## Return on Investment (ROI)

### Cost Monitoring Benefits

**Direct Savings Example**:
```
Scenario: E-commerce company with $100K/month Azure spend

Monitoring Cost: $2.20/month (3 subscriptions)

Month 1 Savings:
- Unused VMs identified and deallocated: $3,500
- Storage tier optimization: $1,200
- Right-sized databases: $2,800
- Deleted orphaned resources: $800
Total Month 1 Savings: $8,300

Annual Savings: $8,300/month × 12 = $99,600
Annual Monitoring Cost: $2.20 × 12 = $26.40
Net Annual Benefit: $99,573.60
ROI: 377,173% (3,772x return)
```

**Additional Benefits**:
- Budget compliance and accountability
- Forecasted alerts prevent overspending
- Service-specific insights for optimization
- Audit trail for financial compliance
- Executive visibility into cloud costs

## Integration with FinOps Practices

### 1. Budget Accountability

```hcl
# Assign budget ownership
tags = {
  BudgetOwner  = "engineering-vp@pge.com"
  CostCenter   = "Engineering"
  Approver     = "cfo@pge.com"
  ReviewCycle  = "Monthly"
}
```

### 2. Cost Allocation

- Use tags for chargeback/showback
- Align budgets with business units
- Track costs by project/product
- Enable cost attribution reports

### 3. Continuous Optimization

**Weekly**: Review service-specific alerts
**Monthly**: Analyze budget utilization and forecast
**Quarterly**: Adjust budgets and thresholds
**Annually**: Review and reset based on business growth

### 4. Stakeholder Communication

```hcl
# Automated notifications create transparency
contact_emails = [
  "finance@pge.com",          # Financial governance
  "engineering-vp@pge.com",   # Technical ownership
  "cfo@pge.com",              # Executive visibility
  "board@pge.com"             # Board reporting
]
```

### 5. Forecasting and Planning

- Use forecasted alerts for proactive management
- Monthly budget reviews inform capacity planning
- Service-specific trends guide architecture decisions
- Historical data supports annual budget requests

## Additional Resources

- [Azure Cost Management Documentation](https://learn.microsoft.com/azure/cost-management-billing/)
- [Azure Budgets](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- [Cost Optimization Workbook](https://learn.microsoft.com/azure/advisor/advisor-cost-recommendations)
- [FinOps Foundation](https://www.finops.org/)
- [Azure Well-Architected Framework - Cost Optimization](https://learn.microsoft.com/azure/well-architected/cost/)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Azure Cost Management Best Practices](https://learn.microsoft.com/azure/cost-management-billing/costs/cost-mgt-best-practices)

## License

This module follows your organization's licensing terms.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-11-24 | Initial release with 10 alerts (1 budget + 6 query rules + 3 activity log) |

---

**Last Updated**: November 24, 2025  
**Module Version**: 1.0.0  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
