# Azure Automation Account AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure Automation Accounts**. It provides production-ready monitoring across job execution, runbook operations, hybrid worker management, and administrative activities.

Azure Automation delivers a cloud-based automation and configuration service that supports consistent management across Azure and non-Azure environments. This module monitors critical operational metrics to ensure reliable automation workflows.

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

- **6 Activity Log Alerts** for administrative operations
- **4 Scheduled Query Rules** for job and worker monitoring
- **Customizable Thresholds** for all alerts
- **Enable/Disable Flags** for flexible alert management
- **Job Failure Tracking** with detailed diagnostics
- **Hybrid Worker Monitoring** for connectivity and health
- **Runbook Execution Monitoring** to detect failures
- **Long-Running Job Detection** for performance optimization
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 🔴 Job Execution Alerts
- Job Failure Rate
- Runbook Execution Failures
- Long-Running Jobs

### 🟠 Hybrid Worker Alerts
- Hybrid Worker Operations (Activity Log)
- Hybrid Worker Connectivity (Query Rule)

### 🟡 Runbook Management Alerts
- Runbook Operations (Create/Modify/Delete)

### 🔵 Administrative Alerts
- Automation Account Creation
- Automation Account Deletion
- Update Deployment Operations
- Webhook Operations

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure Automation Account(s)
- Azure Monitor Action Group (pre-configured)
- **Required**: Log Analytics workspace for diagnostic settings
- **Required**: Diagnostic settings enabled on Automation Accounts (required for query-based alerts)
  - JobLogs category must be enabled
  - JobStreams category recommended
  - Send to Log Analytics Workspace
- Appropriate permissions to create Monitor alerts

> **Note**: Query-based alerts (Job Failure, Long-Running Jobs, Hybrid Worker Connectivity) will NOT work without diagnostic settings. Activity log alerts will still function.

## Usage

### Basic Example

```hcl
module "automation_account_alerts" {
  source = "./modules/metricAlerts/automationaccount"

  # Resource Configuration
  resource_group_name              = "rg-automation-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Automation Account Names to Monitor
  automation_account_names = [
    "automation-prod-001",
    "automation-prod-002"
  ]

  # Subscription IDs for Activity Log Alerts (optional, auto-detects if not provided)
  subscription_ids = []  # Leave empty to auto-detect

  # Tags
  tags = {
    Environment         = "Production"
    AppId              = "123456"
    CRIS               = "1"
    Compliance         = "SOX"
    DataClassification = "internal"
    Env                = "Prod"
    Notify             = "ops-team@pge.com"
    Owner              = "automation-team@pge.com"
    order              = "123456"
  }
}
```

### Production Example with Custom Thresholds

```hcl
module "automation_alerts_production" {
  source = "./modules/metricAlerts/automationaccount"

  # Resource Configuration
  resource_group_name              = "rg-automation-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-alerts-actiongroup"
  location                         = "West US 3"

  # Automation Accounts
  automation_account_names = [
    "automation-prod-001",
    "automation-prod-002",
    "automation-prod-003"
  ]

  # Custom Threshold
  job_duration_threshold_minutes = 30  # Alert if job runs > 30 minutes

  # Enable All Alerts
  enable_automation_account_creation_alert = true
  enable_automation_account_deletion_alert = true
  enable_runbook_operations_alert          = true
  enable_hybrid_worker_alert               = true
  enable_update_deployment_alert           = true
  enable_webhook_alert                     = true
  enable_job_failure_alert                 = true
  enable_runbook_execution_failure_alert   = true
  enable_job_duration_alert                = true
  enable_hybrid_worker_connectivity_alert  = true

  tags = {
    Environment     = "Production"
    CriticalityTier = "Tier1"
  }
}
```

### Selective Alert Monitoring Example

```hcl
module "automation_alerts_selective" {
  source = "./modules/metricAlerts/automationaccount"

  resource_group_name              = "rg-automation-dev"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  automation_account_names = ["automation-dev-001"]

  # Enable only critical alerts for development
  enable_automation_account_creation_alert = false
  enable_automation_account_deletion_alert = true   # Critical: prevent accidental deletion
  enable_runbook_operations_alert          = false
  enable_hybrid_worker_alert               = false
  enable_update_deployment_alert           = false
  enable_webhook_alert                     = false
  enable_job_failure_alert                 = true   # Critical: monitor job failures
  enable_runbook_execution_failure_alert   = true   # Critical: detect runbook issues
  enable_job_duration_alert                = false
  enable_hybrid_worker_connectivity_alert  = false

  # More lenient threshold for dev environment
  job_duration_threshold_minutes = 120  # 2 hours

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

### Using Resource IDs Instead of Names

```hcl
module "automation_alerts_by_resource_id" {
  source = "./modules/metricAlerts/automationaccount"

  resource_group_name              = "rg-automation"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Use resource IDs directly (useful for cross-resource-group monitoring)
  automation_account_resource_ids = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-prod/providers/Microsoft.Automation/automationAccounts/automation-prod-001",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-staging/providers/Microsoft.Automation/automationAccounts/automation-staging-001"
  ]

  tags = {
    Environment = "Multi-Region"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Core Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where Automation Accounts are located |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group name for alert notifications |
| `location` | `string` | `"West US 3"` | Azure region for alert resources |
| `automation_account_names` | `list(string)` | `[]` | List of Automation Account names to monitor |
| `subscription_ids` | `list(string)` | `[]` | Subscription IDs for activity log alerts (auto-detects if empty) |
| `automation_account_resource_ids` | `list(string)` | `[]` | Automation Account resource IDs for query rules |
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

### Alert Enable/Disable Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_automation_account_creation_alert` | `bool` | `true` | Enable account creation monitoring |
| `enable_automation_account_deletion_alert` | `bool` | `true` | Enable account deletion monitoring |
| `enable_runbook_operations_alert` | `bool` | `true` | Enable runbook operations monitoring |
| `enable_hybrid_worker_alert` | `bool` | `true` | Enable hybrid worker operations monitoring |
| `enable_update_deployment_alert` | `bool` | `true` | Enable update deployment monitoring |
| `enable_webhook_alert` | `bool` | `true` | Enable webhook operations monitoring |
| `enable_job_failure_alert` | `bool` | `true` | Enable job failure monitoring |
| `enable_runbook_execution_failure_alert` | `bool` | `true` | Enable runbook failure monitoring |
| `enable_job_duration_alert` | `bool` | `true` | Enable long-running job monitoring |
| `enable_hybrid_worker_connectivity_alert` | `bool` | `true` | Enable worker connectivity monitoring |

### Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `job_duration_threshold_minutes` | `number` | `60` | Alert when job runs longer than this (minutes) |

## Alert Details

### Activity Log Alerts

#### 1. Automation Account Creation
- **Operation**: `Microsoft.Automation/automationAccounts/write`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors creation of new Automation Accounts. Important for change tracking and security compliance.

#### 2. Automation Account Deletion
- **Operation**: `Microsoft.Automation/automationAccounts/delete`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Triggers when Automation Account is deleted. Essential for preventing accidental deletions.

#### 3. Runbook Operations
- **Operation**: `Microsoft.Automation/automationAccounts/runbooks/write`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors runbook creation, modification, and deletion. Critical for change management.

#### 4. Hybrid Worker Operations
- **Operation**: `Microsoft.Automation/automationAccounts/hybridRunbookWorkerGroups/write`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Tracks hybrid worker registration and deregistration. Important for infrastructure monitoring.

#### 5. Update Deployment Operations
- **Operation**: `Microsoft.Automation/automationAccounts/softwareUpdateConfigurations/write`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors update deployment creation and modification. Critical for patch management compliance.

#### 6. Webhook Operations
- **Operation**: `Microsoft.Automation/automationAccounts/webhooks/write`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Tracks webhook creation, modification, and deletion. Important for security and integration monitoring.

### Scheduled Query Rules

#### 7. Job Failure Rate
- **Query Type**: AzureDiagnostics (JobLogs)
- **Evaluation Frequency**: 15 minutes
- **Window Duration**: 30 minutes
- **Threshold**: 3 or more failed jobs
- **Severity**: 1 (Error)
- **Description**: **CRITICAL** - Monitors overall job failure rate. High failure rates indicate systemic issues.

**KQL Query Logic**:
```kql
AzureDiagnostics
| where Category == "JobLogs"
| where ResultType == "Failed"
| summarize FailedJobs = count() by bin(TimeGenerated, 15m), Resource
| where FailedJobs >= 3
```

#### 8. Runbook Execution Failure
- **Query Type**: AzureDiagnostics (JobLogs)
- **Evaluation Frequency**: 10 minutes
- **Window Duration**: 15 minutes
- **Threshold**: 2 or more failures per runbook
- **Severity**: 1 (Error)
- **Description**: **CRITICAL** - Detects repeated failures of specific runbooks. Indicates runbook code or dependency issues.

**KQL Query Logic**:
```kql
AzureDiagnostics
| where Category == "JobLogs"
| where ResultType == "Failed"
| where RunbookName_s != ""
| summarize FailureCount = count() by RunbookName_s, Resource
| where FailureCount >= 2
```

#### 9. Job Duration (Long-Running Jobs)
- **Query Type**: AzureDiagnostics (JobLogs)
- **Evaluation Frequency**: 30 minutes
- **Window Duration**: 1 hour
- **Threshold**: Jobs running > 60 minutes (default)
- **Severity**: 2 (Warning)
- **Description**: Monitors jobs exceeding expected duration. Helps identify performance issues or stuck jobs.

**KQL Query Logic**:
```kql
AzureDiagnostics
| where Category == "JobLogs"
| where ResultType == "InProgress"
| extend JobDuration = now() - TimeGenerated
| where JobDuration > timespan(60m)  // Configurable via variable
| summarize LongRunningJobs = count() by Resource, RunbookName_s
```

#### 10. Hybrid Worker Connectivity
- **Query Type**: Heartbeat
- **Evaluation Frequency**: 15 minutes
- **Window Duration**: 30 minutes
- **Threshold**: Workers with no heartbeat in 15 minutes
- **Severity**: 1 (Error)
- **Description**: **CRITICAL** - Monitors hybrid worker connectivity. Loss of connectivity prevents job execution on hybrid workers.

**KQL Query Logic**:
```kql
Heartbeat
| where Category == "Automation Hybrid Worker"
| summarize LastHeartbeat = max(TimeGenerated) by Computer, Resource
| where LastHeartbeat < ago(15m)
| summarize DisconnectedWorkers = count() by Resource
```

## Best Practices

### 1. Diagnostic Settings Configuration

**CRITICAL**: Query-based alerts require diagnostic settings to be enabled.

For comprehensive monitoring and troubleshooting, enable diagnostic settings on your Automation Account resources. While activity log alerts work without diagnostic settings, query-based alerts (job failures, long-running jobs, hybrid worker connectivity) require diagnostic logs.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings via Azure CLI
az monitor diagnostic-settings create \
  --name "automation-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Automation/automationAccounts/{account-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"JobLogs","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"JobStreams","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"DscNodeStatus","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"AuditEvent","enabled":true,"retentionPolicy":{"days":90,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "automation_diagnostics" {
  for_each                   = toset(var.automation_account_names)
  name                       = "automation-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_automation_account.accounts[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Job Logs - REQUIRED for query-based alerts
  enabled_log {
    category = "JobLogs"
  }

  # Job Streams - Detailed job output
  enabled_log {
    category = "JobStreams"
  }

  # DSC Node Status - State Configuration
  enabled_log {
    category = "DscNodeStatus"
  }

  # Audit Events - Configuration changes
  enabled_log {
    category = "AuditEvent"
  }

  # All Metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Category | Purpose | When to Enable | Required for Alerts |
|----------|---------|----------------|---------------------|
| **JobLogs** | Job start, completion, failure, status | **Always** - Required for job alerts | ✅ YES |
| **JobStreams** | Detailed job output, logs, errors | **Always** - Essential for troubleshooting | Recommended |
| **DscNodeStatus** | DSC configuration compliance | **If using DSC** - Compliance tracking | No |
| **AuditEvent** | Configuration changes, security events | **Always** - Audit trail | No |

#### Useful Log Analytics Queries

```kusto
// Job failure rate over time
AzureDiagnostics
| where Category == "JobLogs"
| where TimeGenerated > ago(24h)
| where ResultType == "Failed"
| summarize FailureCount = count() by bin(TimeGenerated, 1h), RunbookName_s
| order by TimeGenerated desc

// Top 10 longest running jobs
AzureDiagnostics
| where Category == "JobLogs"
| where TimeGenerated > ago(7d)
| where ResultType == "Completed"
| extend Duration = datetime_diff('second', TimeGenerated, StartTime_t)
| top 10 by Duration desc
| project TimeGenerated, RunbookName_s, Duration, JobId_g

// Hybrid worker connectivity status
Heartbeat
| where ResourceType == "automationaccounts"
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer, Resource
| extend MinutesSinceLastHeartbeat = datetime_diff('minute', now(), LastHeartbeat)
| where MinutesSinceLastHeartbeat > 15
| order by MinutesSinceLastHeartbeat desc

// Runbook execution trends
AzureDiagnostics
| where Category == "JobLogs"
| where TimeGenerated > ago(30d)
| summarize 
    TotalJobs = count(),
    FailedJobs = countif(ResultType == "Failed"),
    SuccessRate = round(100.0 * countif(ResultType == "Completed") / count(), 2)
  by RunbookName_s
| order by TotalJobs desc
```

### 2. Threshold Configuration

#### Production Environments
```hcl
# Strict monitoring for production
job_duration_threshold_minutes = 30  # Alert on jobs > 30 minutes

# Enable all alerts
enable_job_failure_alert                = true
enable_runbook_execution_failure_alert  = true
enable_hybrid_worker_connectivity_alert = true
enable_automation_account_creation_alert = true
enable_automation_account_deletion_alert = true
```

#### Development Environments
```hcl
# Relaxed monitoring for development
job_duration_threshold_minutes = 120  # Alert on jobs > 2 hours

# Enable critical alerts only
enable_job_failure_alert                = true
enable_runbook_execution_failure_alert  = true
enable_hybrid_worker_connectivity_alert = true

# Disable non-critical alerts
enable_automation_account_creation_alert = false
enable_runbook_operations_alert          = false
enable_update_deployment_alert           = false
```

### 3. Alert Response Procedures

#### Severity 1 (Critical) - Immediate Response
- **Job Failure Rate** → Review job logs, check runbook code, verify dependencies
- **Runbook Execution Failures** → Investigate failure reason, fix code issues
- **Hybrid Worker Connectivity** → Check worker health, network connectivity, credentials

**Response Time**: < 15 minutes  
**Escalation**: Page on-call engineer

#### Severity 2 (Warning) - Review Within 1 Hour
- **Long-Running Jobs** → Review job performance, optimize runbook code

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Activity Log Alerts (Informational) - Review During Business Hours
- **Account Creation/Deletion** → Audit trail review
- **Runbook Operations** → Change management verification
- **Hybrid Worker Operations** → Infrastructure change tracking
- **Update Deployments** → Patch management review
- **Webhook Operations** → Integration monitoring

**Response Time**: Next business day  
**Escalation**: Log for review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on all Automation Accounts (CRITICAL)
- [ ] Configure Log Analytics workspace retention (30-90 days recommended)
- [ ] Verify JobLogs category is enabled (required for query-based alerts)
- [ ] Set up action groups with appropriate notification channels
- [ ] Customize alert thresholds based on runbook execution patterns
- [ ] Test alert notifications to verify delivery
- [ ] Document escalation procedures

#### Ongoing Operations
- [ ] Review alert thresholds quarterly
- [ ] Analyze false positive rates monthly
- [ ] Review diagnostic logs weekly for patterns
- [ ] Update alert rules for new Automation Accounts
- [ ] Validate action group membership monthly
- [ ] Conduct incident response drills quarterly
- [ ] Verify diagnostic settings remain enabled (quarterly)

#### Performance & Optimization
- [ ] Establish job execution baselines
- [ ] Optimize long-running runbooks
- [ ] Monitor alert fatigue and tune accordingly
- [ ] Review and update runbook error handling
- [ ] Analyze hybrid worker performance patterns
- [ ] Document common failure scenarios and resolutions

### 4. Runbook Best Practices

**Error Handling**:
```powershell
# Add try-catch blocks in runbooks for better failure tracking
try {
    # Your automation logic here
    Write-Output "Task completed successfully"
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Error "Job failed: $ErrorMessage"
    throw $ErrorMessage  # This ensures job fails properly for alerting
}
```

### 5. Hybrid Worker Monitoring

```hcl
# Ensure heartbeat monitoring is enabled
enable_hybrid_worker_connectivity_alert = true

# Monitor both operations and connectivity
enable_hybrid_worker_alert = true  # Activity log
```

### 6. Job Duration Optimization

**Set thresholds based on runbook types**:

```hcl
# For fast automation tasks (API calls, simple scripts)
job_duration_threshold_minutes = 15

# For batch processing tasks
job_duration_threshold_minutes = 60

# For long-running maintenance tasks
job_duration_threshold_minutes = 240
```

### 7. Multi-Environment Strategy

```hcl
# Production: All alerts enabled, strict thresholds
module "automation_prod" {
  job_duration_threshold_minutes = 30
  # All enable_* flags = true
}

# Staging: Selective alerts
module "automation_staging" {
  job_duration_threshold_minutes = 60
  enable_automation_account_creation_alert = false
  enable_runbook_operations_alert          = false
}

# Development: Minimal alerts
module "automation_dev" {
  job_duration_threshold_minutes = 120
  enable_job_failure_alert                = true
  enable_runbook_execution_failure_alert  = true
  # All other alerts disabled
}
```

## Troubleshooting

### Common Issues

#### 1. No Query-Based Alerts Being Created

**Problem**: Scheduled query rules (job failures, runbook failures, etc.) not appearing.

**Solution**:
```hcl
# Ensure you provide either automation_account_names OR automation_account_resource_ids
automation_account_names = ["automation-prod-001"]  # Option 1

# OR

automation_account_resource_ids = [
  "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Automation/automationAccounts/{name}"
]  # Option 2

# Verify diagnostic settings are enabled
az monitor diagnostic-settings list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Automation/automationAccounts/{name}"
```

#### 2. Query-Based Alerts Show "No Data"

**Problem**: Scheduled query rules not triggering or showing no data.

**Diagnostics**:
```bash
# Check if diagnostic logs are flowing to Log Analytics
az monitor diagnostic-settings show \
  --name "automation-diagnostics" \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Automation/automationAccounts/{name}"

# Verify JobLogs category is enabled
# Query Log Analytics directly
```

**Solution**:
```hcl
# 1. Enable diagnostic settings on Automation Account
# 2. Ensure JobLogs category is enabled
# 3. Verify Log Analytics workspace is receiving data
# 4. Wait 15-30 minutes for initial data ingestion
```

#### 3. Activity Log Alerts Not Triggering

**Problem**: Account creation/deletion alerts not firing.

**Solution**:
```hcl
# Provide subscription_ids (or leave empty for auto-detection)
subscription_ids = []  # Auto-detects current subscription

# Verify you have Reader permissions on the subscription
# Activity log alerts require subscription-level scope
```

#### 4. Alert Firing Too Frequently

**Problem**: Receiving too many job failure alerts.

**Solution**:
```hcl
# Adjust query thresholds by modifying the KQL query
# Current threshold: 3 failed jobs in 30 minutes

# To change, you'll need to edit the query in alerts.tf
# Or implement a variable for failure threshold (future enhancement)

# Alternative: Adjust evaluation frequency
evaluation_frequency = "PT30M"  # Check every 30 minutes instead of 15
```

#### 5. Hybrid Worker Connectivity False Positives

**Problem**: Workers showing as disconnected when they're online.

**Solution**:
```bash
# Verify hybrid workers are sending heartbeats
# Check Log Analytics for Heartbeat table

# Query to verify heartbeat data:
Heartbeat
| where Category == "Automation Hybrid Worker"
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
```

#### 6. Long-Running Job Alert Threshold Too Sensitive

**Problem**: Normal long-running jobs triggering alerts.

**Solution**:
```hcl
# Increase threshold for your workload
job_duration_threshold_minutes = 120  # 2 hours instead of 1 hour

# Or disable for specific environments
enable_job_duration_alert = false
```

### Validation Commands

```bash
# Verify Terraform configuration
terraform init
terraform validate
terraform plan

# Check Automation Account exists
az automation account show \
  --name "automation-prod-001" \
  --resource-group "rg-automation"

# List existing alerts
az monitor metrics alert list \
  --resource-group "rg-automation" \
  --query "[?contains(name, 'AutomationAccount')].{Name:name, Enabled:enabled, Severity:severity}"

# List scheduled query rules
az monitor scheduled-query list \
  --resource-group "rg-automation" \
  --query "[?contains(name, 'AutomationAccount')].{Name:name, Enabled:enabled, Severity:severity}"

# Test action group
az monitor action-group test-notifications create \
  --action-group "pge-operations-actiongroup" \
  --resource-group "rg-monitoring" \
  --notification-type "Email"

# Check diagnostic settings
az monitor diagnostic-settings list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Automation/automationAccounts/{name}"

# Query JobLogs in Log Analytics
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureDiagnostics | where Category == 'JobLogs' | take 10"
```

### Debug Mode

```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform apply

# Check Terraform state
terraform state list | grep automation
terraform state show module.automation_account_alerts.azurerm_monitor_activity_log_alert.automation_account_creation[0]
```

## Alert Severity Mapping

| Severity | Level | Use Case | Action Required |
|----------|-------|----------|-----------------|
| 0 | Critical | Service down, data loss | Immediate response (PagerDuty) |
| 1 | Error | Significant degradation | Immediate attention (15 min) |
| 2 | Warning | Approaching limits | Review within 1 hour |
| 3 | Informational | FYI, trending | Review during business hours |

**This Module's Severity Distribution:**
- **Severity 1 (Error)**: Job Failures, Runbook Execution Failures, Hybrid Worker Connectivity
- **Severity 2 (Warning)**: Long-Running Jobs
- **Activity Log Alerts**: Informational (no numeric severity)

## Performance Considerations

### Resource Creation Time
- **Activity Log Alerts**: ~5 seconds per alert
- **Scheduled Query Rules**: ~15 seconds per alert
- **Total Module Deployment**: ~2-3 minutes for 2-3 Automation Accounts

### Query Evaluation Impact
- **Job Failure Rate**: Evaluates every 15 minutes (4 queries/hour)
- **Runbook Failures**: Evaluates every 10 minutes (6 queries/hour)
- **Job Duration**: Evaluates every 30 minutes (2 queries/hour)
- **Hybrid Worker**: Evaluates every 15 minutes (4 queries/hour)

**Total**: ~16 queries/hour per Automation Account (minimal Log Analytics cost impact)

## Cost Optimization

### Alert Pricing (2025)
- **Activity Log Alerts**: Free
- **Scheduled Query Rules**: $0.10 per alert per month
- **Total Module Cost** (for 2 Automation Accounts):
  - 6 activity log alerts × $0 = $0/month
  - 4 query rules × $0.10 = $0.40/month
  - **Total: ~$0.40/month per module instance**

### Cost Reduction Strategies
```hcl
# Disable non-critical alerts in dev/test
enable_automation_account_creation_alert = false
enable_runbook_operations_alert          = false
enable_update_deployment_alert           = false

# Use longer evaluation frequencies
evaluation_frequency = "PT30M"  # Reduces query execution frequency

# Consolidate action groups
# (Reuse existing action groups across modules)
```

## License

This module follows your organization's licensing terms.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-24 | Initial release with 10 alerts |

---

**Last Updated**: November 24, 2025  
**Module Version**: 1.0.0  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
