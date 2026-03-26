# Azure Monitor Resources Monitoring Alerts - Terraform Module

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Production Configuration](#production-configuration)
  - [Multi-Workspace Deployment](#multi-workspace-deployment)
  - [Application Insights Monitoring](#application-insights-monitoring)
  - [Selective Alert Configuration](#selective-alert-configuration)
- [Input Variables](#input-variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
  - [Alert Configuration Variables](#alert-configuration-variables)
- [Alert Details](#alert-details)
  - [Log Analytics Workspace Alerts](#log-analytics-workspace-alerts)
  - [Application Insights Alerts](#application-insights-alerts)
  - [Data Collection Rule Alerts](#data-collection-rule-alerts)
  - [Activity Log Alerts](#activity-log-alerts)
- [Alert Severity Levels](#alert-severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
  - [Log Analytics Workspace Management](#log-analytics-workspace-management)
  - [Application Insights Configuration](#application-insights-configuration)
  - [Data Collection Optimization](#data-collection-optimization)
  - [Monitoring and Diagnostics](#monitoring-and-diagnostics)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Validation Commands](#validation-commands)
- [License](#license)

---

## Overview

This Terraform module provides comprehensive monitoring and alerting for **Azure Monitor Resources**, Microsoft's full-stack monitoring solution that includes Log Analytics workspaces, Application Insights, Data Collection Rules, diagnostic settings, and action groups. Azure Monitor is the foundational observability platform for all Azure resources and applications.

The module implements the **Azure Monitor Baseline Alerts (AMBA)** best practices specifically tailored for Azure Monitor infrastructure itself, covering:
- **Log Analytics workspace monitoring** - Data ingestion, heartbeat, capacity
- **Application Insights monitoring** - Availability, response time, errors, exceptions
- **Data Collection Rules monitoring** - Collection failures, data pipeline health
- **Administrative monitoring** - Resource deletions, configuration changes
- **Service health monitoring** - Diagnostic settings, action groups

**Key Capabilities:**
- Monitors monitoring infrastructure (meta-monitoring)
- Tracks Log Analytics workspace data ingestion and costs
- Detects Application Insights availability and performance issues
- Monitors data collection pipeline health
- Alerts on critical configuration changes
- Tracks deletion of monitoring resources
- Comprehensive diagnostic settings monitoring

This module is essential for organizations that need:
- Centralized observability infrastructure
- Cost management for monitoring services
- Compliance and audit trails for monitoring changes
- High availability for monitoring services
- Application performance monitoring (APM)
- Infrastructure and application insights

---

## Key Features

- **✅ 15 Comprehensive Alerts** - Workspace, Application Insights, DCR, and administrative monitoring
- **✅ 3 Log Analytics Workspace Alerts** - Data ingestion (warning + critical), heartbeat
- **✅ 4 Application Insights Alerts** - Availability, response time, failed requests, exceptions
- **✅ 1 Data Collection Rule Alert** - Collection failure detection
- **✅ 7 Activity Log Alerts** - Resource deletions, diagnostic settings, action group changes
- **✅ Cost Management** - Data ingestion monitoring to control monitoring costs
- **✅ Meta-Monitoring** - Monitor the monitoring infrastructure itself
- **✅ Multi-Resource Support** - Monitor multiple workspaces, App Insights, DCRs
- **✅ Pipeline Health** - Data collection and ingestion monitoring
- **✅ Customizable Thresholds** - All alert thresholds configurable per environment
- **✅ Production-Ready** - Follows Azure AMBA guidelines for enterprise deployments

---

## Prerequisites

Before using this module, ensure you have:

1. **Terraform >= 1.0** installed
2. **Azure Provider >= 3.0** configured
3. **Existing Azure Monitor resources** deployed:
   - Log Analytics workspace(s)
   - Application Insights resource(s)
   - Data Collection Rules (optional)
4. **Azure Monitor Action Group** created for alert notifications
5. **Appropriate Azure RBAC permissions**:
   - `Monitoring Contributor` role on the resource group/subscription
   - `Reader` role on monitored resources
   - Access to the action group for notifications

6. **Azure Monitor Requirements**:
   - Log Analytics workspace with data retention configured
   - Application Insights enabled for applications
   - Data Collection Rules configured (if monitoring VMs/containers)
   - Diagnostic settings enabled on critical resources

---

## Module Structure

```
monitor/
├── alerts.tf       # Azure Monitor metric and activity log alert definitions
├── variables.tf    # Input variable definitions
└── README.md       # This documentation file
```

---

## Usage

### Basic Usage

```hcl
module "monitor_alerts" {
  source = "./modules/metricAlerts/monitor"

  # Log Analytics Workspace monitoring
  log_analytics_workspace_names          = ["law-prod-centralus"]
  resource_group_name                    = "rg-monitoring-production"

  # Subscription for activity log alerts
  subscription_ids                       = ["12345678-1234-1234-1234-123456789012"]

  # Action group configuration
  action_group                           = "monitoring-ops-actiongroup"
  action_group_resource_group_name       = "rg-monitoring"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Monitoring-Infrastructure"
    CostCenter         = "Operations"
    DataClassification = "Internal"
    Owner              = "monitoring-team@company.com"
  }
}
```

### Production Configuration

```hcl
module "monitor_alerts_prod" {
  source = "./modules/metricAlerts/monitor"

  # Multiple Log Analytics Workspaces
  log_analytics_workspace_names = [
    "law-prod-centralus",
    "law-prod-eastus",
    "law-prod-sentinel"
  ]

  # Multiple Application Insights
  application_insights_names = [
    "appi-web-prod",
    "appi-api-prod",
    "appi-mobile-prod"
  ]

  # Data Collection Rules
  data_collection_rule_names = [
    "dcr-vm-insights",
    "dcr-container-insights",
    "dcr-performance"
  ]

  resource_group_name                    = "rg-monitoring-production"
  subscription_ids                       = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]

  # Action groups
  action_group                           = "monitoring-critical-alerts"
  action_group_resource_group_name       = "rg-monitoring-prod"

  # Enable all alert categories
  enable_workspace_alerts                = true
  enable_application_insights_alerts     = true
  enable_data_collection_alerts          = true
  enable_monitor_service_alerts          = true
  enable_diagnostic_settings_alerts      = true

  # Log Analytics thresholds
  workspace_data_ingestion_threshold_gb  = 500    # 500GB warning
  workspace_data_ingestion_critical_threshold_gb = 1000  # 1TB critical

  # Application Insights thresholds
  app_insights_availability_threshold_percent = 99    # 99% SLA
  app_insights_response_time_threshold_ms     = 3000  # 3 seconds
  app_insights_failed_requests_threshold      = 5     # Low tolerance
  app_insights_exception_rate_threshold       = 10

  # Evaluation frequencies
  evaluation_frequency_high              = "PT5M"
  evaluation_frequency_medium            = "PT15M"
  window_duration_short                  = "PT5M"
  window_duration_medium                 = "PT15M"
  window_duration_long                   = "PT1H"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Enterprise-Monitoring"
    CostCenter         = "Operations"
    Compliance         = "SOC2,ISO27001"
    DataClassification = "Confidential"
    DR                 = "Critical"
    Owner              = "monitoring-ops@company.com"
    AlertingSLA        = "24x7"
  }
}
```

### Multi-Workspace Deployment

```hcl
module "monitor_alerts_multi_workspace" {
  source = "./modules/metricAlerts/monitor"

  # Regional Log Analytics Workspaces
  log_analytics_workspace_names = [
    "law-prod-eastus",
    "law-prod-westus",
    "law-prod-centralus",
    "law-prod-sentinel",
    "law-prod-security"
  ]

  resource_group_name                    = "rg-monitoring-global"
  subscription_ids                       = ["12345678-1234-1234-1234-123456789012"]

  action_group                           = "monitoring-pagerduty"
  action_group_resource_group_name       = "rg-alerting"

  # Aggressive cost management
  workspace_data_ingestion_threshold_gb  = 250
  workspace_data_ingestion_critical_threshold_gb = 500

  # High-frequency evaluation
  evaluation_frequency_high              = "PT1M"
  evaluation_frequency_medium            = "PT5M"
  window_duration_short                  = "PT5M"

  tags = {
    Environment        = "Production"
    Application        = "Multi-Region-Monitoring"
    BusinessUnit       = "Platform"
    CostCenter         = "Infrastructure"
    Owner              = "platform-ops@company.com"
    CostOptimization   = "Enabled"
  }
}
```

### Application Insights Monitoring

```hcl
module "monitor_alerts_app_insights" {
  source = "./modules/metricAlerts/monitor"

  # Application Insights only
  application_insights_names = [
    "appi-frontend-prod",
    "appi-backend-prod",
    "appi-api-gateway-prod",
    "appi-microservices-prod"
  ]

  resource_group_name                    = "rg-application-insights"
  subscription_ids                       = ["12345678-1234-1234-1234-123456789012"]

  action_group                           = "application-team-alerts"
  action_group_resource_group_name       = "rg-monitoring"

  # Enable only Application Insights alerts
  enable_workspace_alerts                = false
  enable_application_insights_alerts     = true
  enable_data_collection_alerts          = false
  enable_monitor_service_alerts          = false
  enable_diagnostic_settings_alerts      = false

  # Strict SLA thresholds
  app_insights_availability_threshold_percent = 99.9   # Three nines
  app_insights_response_time_threshold_ms     = 2000   # 2 seconds
  app_insights_failed_requests_threshold      = 3      # Low tolerance
  app_insights_exception_rate_threshold       = 5

  # Frequent evaluation for user-facing apps
  evaluation_frequency_high              = "PT1M"
  window_duration_short                  = "PT5M"

  tags = {
    Environment = "Production"
    Application = "Customer-Facing-Apps"
    SLA         = "99.9"
    Owner       = "application-team@company.com"
  }
}
```

### Selective Alert Configuration

```hcl
module "monitor_alerts_dev" {
  source = "./modules/metricAlerts/monitor"

  # Development environment
  log_analytics_workspace_names          = ["law-dev"]
  application_insights_names             = ["appi-dev"]
  resource_group_name                    = "rg-monitoring-dev"
  subscription_ids                       = ["12345678-1234-1234-1234-123456789012"]

  action_group                           = "dev-team-alerts"
  action_group_resource_group_name       = "rg-monitoring-dev"

  # Enable selective alerts for dev
  enable_workspace_alerts                = true
  enable_application_insights_alerts     = true
  enable_data_collection_alerts          = false
  enable_monitor_service_alerts          = false   # Not needed in dev
  enable_diagnostic_settings_alerts      = false   # Not needed in dev

  # Relaxed thresholds for development
  workspace_data_ingestion_threshold_gb  = 50
  workspace_data_ingestion_critical_threshold_gb = 100
  app_insights_availability_threshold_percent = 90
  app_insights_response_time_threshold_ms     = 10000  # 10 seconds
  app_insights_failed_requests_threshold      = 50
  app_insights_exception_rate_threshold       = 100

  tags = {
    Environment = "Development"
    Application = "Dev-Monitoring"
    Owner       = "dev-team@company.com"
  }
}
```

---

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `action_group` | `string` | Name of the Azure Monitor action group for notifications |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group containing Azure Monitor resources |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `subscription_ids` | `list(string)` | `[]` | List of subscription IDs for activity log alerts |
| `log_analytics_workspace_names` | `list(string)` | `[]` | List of Log Analytics workspace names to monitor |
| `application_insights_names` | `list(string)` | `[]` | List of Application Insights names to monitor |
| `data_collection_rule_names` | `list(string)` | `[]` | List of Data Collection Rule names to monitor |
| `tags` | `map(string)` | See variables.tf | Resource tags for organization and cost tracking |

### Alert Configuration Variables

#### Alert Category Toggles

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_workspace_alerts` | `bool` | `true` | Enable Log Analytics workspace alerts |
| `enable_application_insights_alerts` | `bool` | `true` | Enable Application Insights alerts |
| `enable_data_collection_alerts` | `bool` | `true` | Enable Data Collection Rule alerts |
| `enable_monitor_service_alerts` | `bool` | `true` | Enable Azure Monitor service alerts |
| `enable_diagnostic_settings_alerts` | `bool` | `true` | Enable diagnostic settings alerts |

#### Log Analytics Workspace Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `workspace_data_ingestion_threshold_gb` | `number` | `100` | Daily data ingestion warning threshold (GB) |
| `workspace_data_ingestion_critical_threshold_gb` | `number` | `500` | Daily data ingestion critical threshold (GB) |
| `workspace_data_retention_days` | `number` | `30` | Expected data retention period (days) |
| `workspace_query_timeout_threshold_minutes` | `number` | `5` | Query timeout threshold (minutes) |

#### Application Insights Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `app_insights_availability_threshold_percent` | `number` | `95` | Availability percentage threshold |
| `app_insights_response_time_threshold_ms` | `number` | `5000` | Response time threshold (milliseconds) |
| `app_insights_failed_requests_threshold` | `number` | `10` | Failed requests count threshold |
| `app_insights_exception_rate_threshold` | `number` | `5` | Exception rate per minute threshold |

#### Data Collection Rule Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `dcr_collection_failure_threshold_percent` | `number` | `5` | Collection failure percentage threshold |
| `dcr_data_latency_threshold_minutes` | `number` | `15` | Data latency threshold (minutes) |

#### Evaluation Frequencies

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `evaluation_frequency_high` | `string` | `"PT5M"` | High-frequency evaluation (5 minutes) |
| `evaluation_frequency_medium` | `string` | `"PT15M"` | Medium-frequency evaluation (15 minutes) |
| `evaluation_frequency_low` | `string` | `"PT1H"` | Low-frequency evaluation (1 hour) |
| `window_duration_short` | `string` | `"PT5M"` | Short window duration (5 minutes) |
| `window_duration_medium` | `string` | `"PT15M"` | Medium window duration (15 minutes) |
| `window_duration_long` | `string` | `"PT1H"` | Long window duration (1 hour) |

---

## Alert Details

### Log Analytics Workspace Alerts

#### 1. Log Analytics Data Ingestion Alert (Warning)
- **Metric**: `BillableDataSizeGB`
- **Threshold**: 100 GB/day (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT15M
- **Window**: PT1H
- **Aggregation**: Total
- **Description**: Monitors daily data ingestion to manage costs
- **Use Case**: Cost management, capacity planning

**What to do when this alert fires:**
```bash
# Check data ingestion by table
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage 
    | where TimeGenerated > ago(1d)
    | where IsBillable == true
    | summarize DataGB = sum(Quantity) / 1000 by DataType
    | order by DataGB desc"

# Check data ingestion trend
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage 
    | where TimeGenerated > ago(7d)
    | where IsBillable == true
    | summarize TotalGB = sum(Quantity) / 1000 by bin(TimeGenerated, 1d)
    | render timechart"

# Identify top ingesting resources
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage 
    | where TimeGenerated > ago(1d)
    | where IsBillable == true
    | summarize DataGB = sum(Quantity) / 1000 by Resource
    | order by DataGB desc
    | take 20"

# Actions:
# 1. Review which tables are consuming the most data
# 2. Check for unexpected data spikes
# 3. Review diagnostic settings (may be too verbose)
# 4. Consider data collection rules optimization
# 5. Review retention policies
# 6. Implement data sampling if appropriate
# 7. Check for duplicate data collection
# 8. Review commitment tiers for cost optimization
```

#### 2. Log Analytics Data Ingestion Alert (Critical)
- **Metric**: `BillableDataSizeGB`
- **Threshold**: 500 GB/day (default)
- **Severity**: 0 (Critical)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: **CRITICAL** - Very high data ingestion, significant cost impact
- **Use Case**: Cost runaway prevention, anomaly detection

**What to do when this alert fires:**
```bash
# Immediate cost impact analysis
# Current cost: ~$0.30 per GB ingested (Pay-as-you-go)
# 500 GB/day = $150/day = $4,500/month

# Identify culprit immediately
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage 
    | where TimeGenerated > ago(1h)
    | where IsBillable == true
    | summarize RecentGB = sum(Quantity) / 1000 by DataType, Resource
    | order by RecentGB desc"

# Check for data collection rules issues
az monitor data-collection-rule list \
  --resource-group <resource-group> \
  --output table

# Actions (URGENT):
# 1. Identify source of data spike immediately
# 2. Disable problematic diagnostic settings if necessary
# 3. Review data collection rules
# 4. Check for application logging issues (excessive logging)
# 5. Verify no infinite loop in log collection
# 6. Consider temporary data cap to limit costs
# 7. Contact application teams if app-generated
# 8. Review for security incident (data exfiltration attempt)
```

#### 3. Log Analytics Workspace Heartbeat Alert
- **Type**: Scheduled Query Rule
- **Query**: Heartbeat data absence detection
- **Severity**: 1 (Error)
- **Frequency**: PT15M
- **Window**: PT15M
- **Description**: **CRITICAL** - Detects when workspace is not receiving heartbeat data
- **Use Case**: Workspace health, agent connectivity

**What to do when this alert fires:**
```bash
# Check heartbeat data
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Heartbeat 
    | where TimeGenerated > ago(1h)
    | summarize count() by bin(TimeGenerated, 5m)
    | render timechart"

# Check connected agents
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Heartbeat 
    | where TimeGenerated > ago(24h)
    | summarize LastHeartbeat = max(TimeGenerated) by Computer, OSType
    | where LastHeartbeat < ago(15m)
    | order by LastHeartbeat asc"

# Verify workspace health
az monitor log-analytics workspace show \
  --resource-group <resource-group> \
  --workspace-name <workspace-name> \
  --query "provisioningState"

# Actions (URGENT):
# 1. Check if workspace is operational
# 2. Verify agent connectivity (VMs, containers)
# 3. Check network connectivity to workspace
# 4. Review firewall rules
# 5. Verify service health in Azure
# 6. Check data collection rules
# 7. Restart Log Analytics agents if needed
# 8. Verify workspace key hasn't changed
```

### Application Insights Alerts

#### 4. Application Insights Availability Alert
- **Metric**: `availabilityResults/availabilityPercentage`
- **Threshold**: 95% (default)
- **Severity**: 1 (Error)
- **Frequency**: PT5M
- **Window**: PT5M
- **Aggregation**: Average
- **Description**: **CRITICAL** - Monitors application availability from availability tests
- **Use Case**: SLA monitoring, uptime tracking

**What to do when this alert fires:**
```bash
# Check availability test results
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "availabilityResults 
    | where timestamp > ago(1h)
    | summarize 
        Total = count(),
        Failed = countif(success == false),
        AvailabilityPct = (count() - countif(success == false)) * 100.0 / count()
        by name
    | order by AvailabilityPct asc"

# Check failed test details
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "availabilityResults 
    | where timestamp > ago(1h)
    | where success == false
    | project timestamp, name, location, message, duration
    | order by timestamp desc"

# Actions (URGENT):
# 1. Verify application is actually down (not just test issue)
# 2. Check application health endpoints
# 3. Review recent deployments
# 4. Check backend service dependencies
# 5. Verify DNS resolution
# 6. Check SSL certificate validity
# 7. Review application logs
# 8. Escalate to application team if confirmed outage
```

#### 5. Application Insights Response Time Alert
- **Metric**: `requests/duration`
- **Threshold**: 5,000ms (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT15M
- **Window**: PT15M
- **Aggregation**: Average
- **Description**: Monitors application response time performance
- **Use Case**: Performance monitoring, user experience

**What to do when this alert fires:**
```bash
# Check response time percentiles
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h)
    | summarize 
        P50 = percentile(duration, 50),
        P95 = percentile(duration, 95),
        P99 = percentile(duration, 99),
        Avg = avg(duration),
        Max = max(duration)
        by bin(timestamp, 5m)
    | render timechart"

# Identify slow operations
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h)
    | where duration > 5000
    | summarize 
        Count = count(),
        AvgDuration = avg(duration),
        MaxDuration = max(duration)
        by name
    | order by AvgDuration desc"

# Actions:
# 1. Identify slow operations
# 2. Check database query performance
# 3. Review external API dependencies
# 4. Check application resource utilization
# 5. Review recent code changes
# 6. Check for backend service issues
# 7. Analyze dependencies graph
# 8. Consider scaling if resource-constrained
```

#### 6. Application Insights Failed Requests Alert
- **Metric**: `requests/failed`
- **Threshold**: 10 failures (default)
- **Severity**: 1 (Error)
- **Frequency**: PT5M
- **Window**: PT5M
- **Aggregation**: Count
- **Description**: **CRITICAL** - Monitors failed HTTP requests
- **Use Case**: Error detection, service health

**What to do when this alert fires:**
```bash
# Check failed requests
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h)
    | where success == false
    | summarize Count = count() by resultCode, name
    | order by Count desc"

# Get failure details
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h)
    | where success == false
    | project timestamp, name, url, resultCode, duration
    | order by timestamp desc
    | take 50"

# Actions (URGENT):
# 1. Identify failure patterns (500 vs 400 errors)
# 2. Check for 500 errors (server issues)
# 3. Review 400 errors (client/validation issues)
# 4. Check dependencies availability
# 5. Review exception logs
# 6. Verify database connectivity
# 7. Check recent deployments
# 8. Review application logs
```

#### 7. Application Insights Exception Rate Alert
- **Metric**: `exceptions/count`
- **Threshold**: 5 exceptions/minute (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M
- **Window**: PT5M
- **Aggregation**: Count
- **Description**: Monitors unhandled exception rate
- **Use Case**: Code quality, error tracking

**What to do when this alert fires:**
```bash
# Check exception types
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "exceptions 
    | where timestamp > ago(1h)
    | summarize Count = count() by type, outerMessage
    | order by Count desc"

# Get exception details
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "exceptions 
    | where timestamp > ago(1h)
    | project timestamp, type, outerMessage, innermostMessage, operation_Name
    | order by timestamp desc
    | take 50"

# Actions:
# 1. Identify most common exception types
# 2. Review stack traces
# 3. Check for new code deployments
# 4. Verify input validation
# 5. Check for null reference errors
# 6. Review error handling logic
# 7. Update application code if needed
# 8. Add telemetry for better tracking
```

### Data Collection Rule Alerts

#### 8. Data Collection Rule Collection Failure Alert
- **Type**: Scheduled Query Rule
- **Query**: DCR error log detection
- **Severity**: 1 (Error)
- **Frequency**: PT15M
- **Window**: PT15M
- **Description**: **CRITICAL** - Detects data collection failures
- **Use Case**: Data pipeline health, collection reliability

**What to do when this alert fires:**
```bash
# Check DCR health
az monitor data-collection-rule show \
  --resource-group <resource-group> \
  --name <dcr-name>

# Check associated resources
az monitor data-collection-rule association list \
  --resource-group <resource-group> \
  --rule-name <dcr-name>

# Query error logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "DCRLogErrors 
    | where TimeGenerated > ago(1h)
    | summarize Count = count() by ErrorType, ErrorMessage
    | order by Count desc"

# Actions (URGENT):
# 1. Identify which DCR is failing
# 2. Check DCR configuration
# 3. Verify data sources are accessible
# 4. Check agent connectivity
# 5. Review network security rules
# 6. Verify workspace permissions
# 7. Check for quota limits
# 8. Review DCR associations
```

### Activity Log Alerts

#### 9. Log Analytics Workspace Deletion Alert
- **Operation**: `Microsoft.OperationalInsights/workspaces/delete`
- **Category**: Administrative
- **Severity**: Warning (implied)
- **Description**: **CRITICAL** - Detects workspace deletion
- **Use Case**: Accidental deletion prevention, security auditing

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Delete Workspace']"

# Check if workspace still exists
az monitor log-analytics workspace show \
  --resource-group <resource-group> \
  --workspace-name <workspace-name>

# Workspace is recoverable for 14 days (soft delete)
az monitor log-analytics workspace list-deleted \
  --resource-group <resource-group>

# Recover deleted workspace
az monitor log-analytics workspace recover \
  --resource-group <resource-group> \
  --workspace-name <workspace-name>

# Actions (URGENT):
# 1. Verify if deletion was authorized
# 2. Identify who deleted the workspace
# 3. Recover from soft-delete if accidental (14-day window)
# 4. If malicious: Escalate to security team
# 5. Review RBAC permissions
# 6. Check for compromised credentials
# 7. Document incident
# 8. Restore from IaC if recovery not possible
```

#### 10. Application Insights Deletion Alert
- **Operation**: `Microsoft.Insights/components/delete`
- **Category**: Administrative
- **Severity**: Warning (implied)
- **Description**: **CRITICAL** - Detects Application Insights deletion
- **Use Case**: Accidental deletion prevention

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Delete Application Insights']"

# Application Insights data is NOT recoverable
# Actions (URGENT):
# 1. Verify if deletion was authorized
# 2. Identify who deleted the resource
# 3. Re-create from IaC/Terraform
# 4. Update application instrumentation key
# 5. If malicious: Escalate to security team
# 6. Historical data is lost - no recovery
# 7. Implement delete locks on critical resources
```

#### 11. Data Collection Rule Deletion Alert
- **Operation**: `Microsoft.Insights/dataCollectionRules/delete`
- **Category**: Administrative
- **Severity**: Warning (implied)
- **Description**: Detects DCR deletion
- **Use Case**: Data collection pipeline protection

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Delete Data Collection Rule']"

# Re-create DCR
az monitor data-collection-rule create \
  --resource-group <resource-group> \
  --name <dcr-name> \
  --location <location> \
  --rule-file <dcr-config.json>

# Actions:
# 1. Verify if deletion was authorized
# 2. Re-create DCR from IaC
# 3. Re-associate with data sources
# 4. Verify data collection resumes
# 5. Document incident
```

#### 12. Diagnostic Settings Changes Alert
- **Operation**: `Microsoft.Insights/diagnosticSettings/write`
- **Category**: Administrative
- **Severity**: Informational (implied)
- **Description**: Tracks diagnostic settings modifications
- **Use Case**: Compliance, audit trail

**What to do when this alert fires:**
```bash
# Review changes
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Update Diagnostic Settings']"

# Actions:
# 1. Verify change was authorized
# 2. Review what was modified
# 3. Document in change management
# 4. Verify compliance requirements still met
# 5. Check data collection continues as expected
```

#### 13. Diagnostic Settings Deletion Alert
- **Operation**: `Microsoft.Insights/diagnosticSettings/delete`
- **Category**: Administrative
- **Severity**: Warning (implied)
- **Description**: **CRITICAL** - Detects diagnostic settings deletion
- **Use Case**: Compliance violation prevention

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Delete Diagnostic Settings']"

# Re-create diagnostic settings
az monitor diagnostic-settings create \
  --resource <resource-id> \
  --name "diagnostic-settings" \
  --workspace <workspace-id> \
  --logs '[{"category": "Administrative", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# Actions (URGENT):
# 1. Identify which resource lost diagnostic settings
# 2. Re-create immediately (compliance requirement)
# 3. Verify change was authorized
# 4. Check for compliance violations
# 5. Document incident
# 6. Review RBAC permissions
```

#### 14. Action Group Changes Alert
- **Operation**: `Microsoft.Insights/actionGroups/write`
- **Category**: Administrative
- **Severity**: Informational (implied)
- **Description**: Tracks action group modifications
- **Use Case**: Alert routing changes, audit trail

**What to do when this alert fires:**
```bash
# Review changes
az monitor action-group show \
  --resource-group <resource-group> \
  --name <action-group-name>

# Actions:
# 1. Verify change was authorized
# 2. Review what was modified (email, SMS, webhook)
# 3. Test action group
# 4. Document in change management
# 5. Verify alert notifications still work
```

#### 15. Action Group Deletion Alert
- **Operation**: `Microsoft.Insights/actionGroups/delete`
- **Category**: Administrative
- **Severity**: Warning (implied)
- **Description**: **CRITICAL** - Detects action group deletion
- **Use Case**: Alert routing protection

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Delete Action Group']"

# Re-create action group
az monitor action-group create \
  --resource-group <resource-group> \
  --name <action-group-name> \
  --short-name <short-name> \
  --email-receiver <name> <email>

# Actions (URGENT):
# 1. Re-create action group immediately
# 2. Update alert rules to use new action group
# 3. Verify alert notifications resume
# 4. Identify who deleted it
# 5. Check for compromised credentials
# 6. Document incident
```

---

## Alert Severity Levels

| Severity | Level | Use Case | Example Alerts |
|----------|-------|----------|----------------|
| **0** | Critical | Cost runaway, service outage | Data Ingestion (Critical) |
| **1** | Error | Functional failures, data loss | Workspace Heartbeat, Availability, Failed Requests, DCR Failures, Resource Deletions |
| **2** | Warning | Performance degradation, approaching limits | Data Ingestion (Warning), Response Time, Exceptions |
| **3** | Informational | Awareness, trend monitoring | None in this module |
| **4** | Verbose | Detailed diagnostics | None in this module |

**Severity Guidelines:**
- **Severity 0** alerts require **immediate response** (cost/service impact)
- **Severity 1** alerts require **urgent investigation** (data loss, outages)
- **Severity 2** alerts require **timely response** (performance, capacity)
- **Activity Log** alerts are critical for **compliance** and **security**

---

## Cost Analysis

### Alert Costs

**Azure Monitor Pricing (as of 2024):**
- Metric Alerts: **$0.10 per month** per alert rule
- Scheduled Query Rules: **$0.10 per month** per alert rule
- Activity Log Alerts: **FREE**

**This Module Cost Calculation:**
- **5 Metric Alerts** (2 workspace + 4 Application Insights) per resource
- **2 Scheduled Query Rules** (1 workspace + 1 DCR) per resource
- **7 Activity Log Alerts** (FREE, shared)

**Cost per Resource:**
- **Log Analytics Workspace**: (2 metric + 1 query) × $0.10 = **$0.30/month**
- **Application Insights**: 4 metric × $0.10 = **$0.40/month**
- **Data Collection Rule**: 1 query × $0.10 = **$0.10/month**
- Activity log alerts: **$0.00/month** (FREE)

**Example Deployment Costs:**
- **1 Workspace + 1 App Insights**: $0.30 + $0.40 = **$0.70/month**
- **3 Workspaces + 3 App Insights**: (3 × $0.30) + (3 × $0.40) = **$2.10/month**
- **10 Workspaces + 10 App Insights**: (10 × $0.30) + (10 × $0.40) = **$7.00/month**
- **Annual cost (3 Workspaces + 3 App Insights)**: **$25.20/year**

### Azure Monitor Resource Costs

**Log Analytics Workspace Pricing:**
- **Pay-as-you-go**: $0.30 per GB ingested (first 5GB/day free)
- **Commitment Tiers**: 
  - 100 GB/day: $196/month ($1.96/GB)
  - 200 GB/day: $374/month ($1.87/GB)
  - 500 GB/day: $890/month ($1.78/GB)
- **Data Retention**: First 31 days free, then $0.12 per GB per month

**Application Insights Pricing:**
- **First 5 GB/month**: FREE
- **Additional data**: $2.88 per GB (Log Analytics pricing applies)
- **Multi-step web tests**: $0.004 per test execution

**Example Monthly Costs:**
```
Scenario 1: Small Deployment
- 50 GB/month workspace: (50 - 5) × $0.30 = $13.50
- 3 GB App Insights: FREE
- Total: ~$13.50/month + alerts ($0.70)

Scenario 2: Medium Deployment
- 200 GB/day workspace: $374/month (commitment tier)
- 20 GB App Insights: (20 - 5) × $2.88 = $43.20
- Total: ~$417.20/month + alerts ($2.10)

Scenario 3: Large Deployment
- 500 GB/day workspace: $890/month (commitment tier)
- 100 GB App Insights: (100 - 5) × $2.88 = $273.60
- Total: ~$1,163.60/month + alerts ($7.00)
```

### ROI Analysis

**Scenario: Production Monitoring Infrastructure (200GB/day)**

**Without Monitoring:**
- Average downtime per incident: 3 hours
- Incidents per month: 2
- Revenue loss: $100,000/hour (service outage)
- Data loss cost: $50,000+ (workspace deletion)
- **Monthly loss**: 3 hours × 2 incidents × $100,000 = **$600,000**

**With Comprehensive Monitoring:**
- Alert cost: $2.10/month
- Early detection reduces MTTR by 75% (3 hours → 45 minutes)
- Cost runaway prevention: $10,000/month saved
- Prevented downtime: 2.25 hours × 2 incidents = 4.5 hours
- **Monthly savings**: (4.5 hours × $100,000) + $10,000 = **$460,000**

**ROI Calculation:**
```
Monthly Investment: $2.10
Monthly Benefit: $460,000
Monthly Net Benefit: $459,997.90
ROI: (459,997.90 / 2.10) × 100 = 21,904,662%
Annual ROI: $5,519,974.80 savings vs $25.20 cost
```

**Additional Benefits:**
- Prevents monitoring cost runaway
- Early detection of application issues
- Compliance audit trail
- Prevents monitoring infrastructure deletion
- Faster incident resolution
- Better capacity planning

---

## Best Practices

### Log Analytics Workspace Management

1. **Cost Optimization**
   - Use commitment tiers for predictable workloads (>100GB/day)
   - Set daily cap to prevent cost overruns (emergency only)
   - Review data ingestion by table monthly
   - Implement data sampling for high-volume, low-value logs
   - Use data collection rules to filter at source
   - Archive old data to Azure Storage (cheaper retention)

2. **Data Retention**
   - Set appropriate retention by table (30-730 days)
   - Use interactive retention (31 days free)
   - Archive data for compliance (lower cost)
   - Delete unnecessary tables
   - Review retention requirements regularly

3. **Query Performance**
   - Use time filters in queries
   - Limit result sets
   - Avoid cross-workspace queries when possible
   - Use materialized views for repeated queries
   - Optimize KQL queries
   - Use query packs for common queries

4. **Workspace Design**
   - One workspace per environment (dev, test, prod)
   - Consider multiple workspaces for scale (>1TB/day)
   - Dedicated workspace for security logs
   - Regional workspaces for compliance
   - Separate workspace for Sentinel

### Application Insights Configuration

1. **Instrumentation**
   - Use Application Insights SDK (not agent when possible)
   - Enable distributed tracing
   - Implement custom events and metrics
   - Use telemetry processors for filtering
   - Implement correlation IDs
   - Add business metrics

2. **Sampling**
   - Use adaptive sampling (default)
   - Fixed sampling for predictable costs
   - Ingestion sampling for high-volume apps
   - Preserve important telemetry
   - Monitor sampling rate
   - Adjust sampling based on cost

3. **Availability Tests**
   - Configure multi-step web tests
   - Test from multiple regions
   - Set appropriate frequency (5 min prod, 15 min dev)
   - Monitor SSL certificate expiration
   - Test critical user journeys
   - Set up custom availability tests

4. **Performance Monitoring**
   - Track key metrics (APDEX, response time)
   - Monitor dependencies
   - Track database query performance
   - Monitor external API calls
   - Set up alerts on SLOs
   - Use Application Map

### Data Collection Optimization

1. **Data Collection Rules**
   - Filter data at source (save ingestion costs)
   - Use transformations to reduce data volume
   - Target specific data types
   - Use multiple DCRs for different purposes
   - Test DCRs before production deployment
   - Monitor DCR performance

2. **Agent Management**
   - Use Azure Monitor Agent (AMA) over legacy agents
   - Deploy via policy for consistency
   - Monitor agent health
   - Keep agents updated
   - Use managed identity for authentication
   - Implement agent auto-update

3. **Diagnostic Settings**
   - Enable on all critical resources
   - Select only necessary log categories
   - Use resource-specific logs when available
   - Route to appropriate workspace
   - Monitor diagnostic settings changes
   - Implement via policy

### Monitoring and Diagnostics

1. **Meta-Monitoring**
   - Monitor the monitoring infrastructure
   - Track workspace health
   - Monitor data ingestion pipeline
   - Set up redundant alerting
   - Test alert notifications regularly
   - Document runbooks

2. **Alerting Strategy**
   - Implement tiered alerting (info → critical)
   - Avoid alert fatigue
   - Use action groups for routing
   - Implement escalation policies
   - Test alerts regularly
   - Document alert response procedures

3. **Compliance and Audit**
   - Enable activity log retention
   - Track all configuration changes
   - Implement Azure Policy
   - Regular access reviews
   - Document monitoring architecture
   - Maintain audit trail

4. **Disaster Recovery**
   - Enable soft-delete on workspaces (default)
   - Backup workspace configuration
   - Document recovery procedures
   - Test recovery process
   - Use IaC for reproducibility
   - Maintain separate monitoring region

---

## Troubleshooting

### Common Issues

#### Issue 1: Alerts Not Firing Despite Data

**Symptoms:**
- Workspace ingesting data but no alerts
- Metrics available but alerts not triggering

**Troubleshooting Steps:**
```bash
# Check workspace health
az monitor log-analytics workspace show \
  --resource-group <resource-group> \
  --workspace-name <workspace-name> \
  --query "provisioningState"

# Verify metric availability
az monitor metrics list-definitions \
  --resource <workspace-resource-id>

# Check alert configuration
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "loganalytics-data-ingestion-<name>"

# Test query
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage | where TimeGenerated > ago(1d) | summarize sum(Quantity)"
```

**Common Causes:**
- Wrong workspace name in variables
- Alert disabled
- Insufficient data for evaluation window
- Action group not configured

**Resolution:**
```hcl
# Verify workspace names
log_analytics_workspace_names = ["actual-workspace-name"]

# Ensure alert is enabled
enable_workspace_alerts = true
```

---

#### Issue 2: High Data Ingestion Costs

**Symptoms:**
- Data ingestion alert firing frequently
- Unexpected Azure bill

**Troubleshooting Steps:**
```bash
# Identify top data sources
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage 
    | where TimeGenerated > ago(7d)
    | where IsBillable == true
    | summarize TotalGB = sum(Quantity) / 1000 by DataType, Resource
    | order by TotalGB desc"

# Check for spikes
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage 
    | where TimeGenerated > ago(30d)
    | where IsBillable == true
    | summarize DailyGB = sum(Quantity) / 1000 by bin(TimeGenerated, 1d)
    | render timechart"
```

**Common Causes:**
- Verbose diagnostic settings
- Application logging too much
- Data collection rules not filtering
- Performance counter collection too frequent
- Duplicate data collection

**Resolution:**
```bash
# Review diagnostic settings
az monitor diagnostic-settings list \
  --resource <resource-id>

# Disable verbose categories
az monitor diagnostic-settings update \
  --resource <resource-id> \
  --name "diagnostic-settings" \
  --logs '[{"category": "Administrative", "enabled": true}, {"category": "Security", "enabled": true}]'

# Implement data collection rule filtering
# Use transformations to reduce data volume
# Consider commitment tier if >100GB/day
```

---

#### Issue 3: Application Insights Not Collecting Data

**Symptoms:**
- Availability alert not working
- No telemetry in Application Insights

**Troubleshooting Steps:**
```bash
# Check Application Insights resource
az monitor app-insights component show \
  --app <app-insights-name> \
  --resource-group <resource-group>

# Verify instrumentation key
az monitor app-insights component show \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --query "instrumentationKey"

# Test data ingestion
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests | where timestamp > ago(1h) | count"
```

**Common Causes:**
- Application not instrumented
- Wrong instrumentation key
- Network connectivity issues
- Application Insights disabled
- SDK not initialized

**Resolution:**
```javascript
// .NET example
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;

var configuration = TelemetryConfiguration.CreateDefault();
configuration.ConnectionString = "InstrumentationKey=<key>;IngestionEndpoint=https://...";
var telemetryClient = new TelemetryClient(configuration);

// Node.js example
const appInsights = require('applicationinsights');
appInsights.setup('<instrumentation-key>')
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .start();
```

---

#### Issue 4: Workspace Query Performance Issues

**Symptoms:**
- Slow dashboard load times
- Query timeouts
- High workspace CPU

**Troubleshooting Steps:**
```bash
# Check query performance
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage 
    | where TimeGenerated > ago(1d)
    | summarize TotalGB = sum(Quantity) / 1000"

# Optimize query
# Bad: Heartbeat | where Computer contains "web"
# Good: Heartbeat | where TimeGenerated > ago(1h) | where Computer has "web"
```

**Common Causes:**
- No time filter in queries
- Scanning too much data
- Complex joins
- Inefficient KQL
- Cross-workspace queries

**Resolution:**
```kql
-- Always use time filters
| where TimeGenerated > ago(1h)

-- Use 'has' instead of 'contains' when possible
| where Computer has "web"  // Faster

-- Limit result sets
| take 100

-- Use summarize for aggregations
| summarize count() by Computer

-- Use materialized views for repeated queries
.create materialized-view MyView on table Heartbeat {
    Heartbeat
    | summarize count() by bin(TimeGenerated, 5m), Computer
}
```

---

### Validation Commands

```bash
# 1. List Log Analytics workspaces
az monitor log-analytics workspace list \
  --resource-group <resource-group> \
  --output table

# 2. List Application Insights
az monitor app-insights component list \
  --resource-group <resource-group> \
  --output table

# 3. List Data Collection Rules
az monitor data-collection-rule list \
  --resource-group <resource-group> \
  --output table

# 4. Check workspace metrics
az monitor metrics list \
  --resource <workspace-resource-id> \
  --metric "BillableDataSizeGB" \
  --start-time <start-time> \
  --end-time <end-time>

# 5. Query workspace data
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Usage | where TimeGenerated > ago(1d) | summarize sum(Quantity)"

# 6. List all alerts
az monitor metrics alert list \
  --resource-group <resource-group> \
  --output table

# 7. Test action group
az monitor action-group test-notifications create \
  --action-group <action-group-name> \
  --resource-group <resource-group> \
  --alert-type "Monitoring"

# 8. Check Application Insights availability
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "availabilityResults | where timestamp > ago(1h) | summarize avg(success)"

# 9. Check DCR associations
az monitor data-collection-rule association list \
  --resource-group <resource-group> \
  --rule-name <dcr-name>

# 10. Validate Terraform deployment
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

---

## License

This module is provided as-is under the MIT License. See LICENSE file for details.

---

**Module Maintained By:** Platform Engineering Team  
**Last Updated:** 2024-11-24  
**Terraform Version:** >= 1.0  
**Azure Provider Version:** >= 3.0

For questions or issues, please contact the Platform Engineering team or open an issue in the repository.
