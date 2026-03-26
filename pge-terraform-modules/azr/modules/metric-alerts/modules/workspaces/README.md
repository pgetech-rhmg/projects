# Azure Log Analytics Workspaces - Metric Alerts Module

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Variables](#variables)
- [Alert Details](#alert-details)
- [Severity Levels](#severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Overview

This Terraform module creates comprehensive monitoring alerts for **Azure Log Analytics Workspaces**, providing critical observability monitoring for log ingestion, query performance, data retention, agent connectivity, and error rates across your Azure monitoring infrastructure. The module focuses on ensuring reliable log collection, optimal query performance, and proactive management of your centralized logging platform.

Azure Log Analytics Workspace is the central hub for collecting, analyzing, and acting on telemetry data from your cloud and on-premises environments. This module implements essential monitoring to detect data collection issues, performance bottlenecks, retention management, and connectivity problems that could impact your entire observability strategy.

## Features

- **Agent Heartbeat Monitoring**: Detection of missing heartbeat data from monitored systems
- **Query Performance Monitoring**: Identification of slow-running queries affecting workspace performance
- **Data Retention Management**: Proactive alerts for data approaching retention limits
- **Error Rate Monitoring**: Detection of high error rates in workspace operations
- **Agent Connection Monitoring**: Tracking of agent connectivity issues and timeout problems
- **Custom Table Ingestion**: Monitoring of custom log table data ingestion rates
- **Multi-Workspace Support**: Enterprise-scale monitoring across multiple Log Analytics workspaces
- **Scheduled Query Rules**: Advanced KQL-based alerting with customizable evaluation frequencies
- **Cost-Effective Monitoring**: Optimized alert configuration at $0.60 per workspace per month
- **Enterprise Integration**: Built-in support for PGE operational procedures and compliance requirements
- **Regulatory Compliance**: SOX, HIPAA, PCI-DSS compliance support for audit logging and monitoring

### Key Monitoring Capabilities
- **Data Quality Assurance**: Ensure consistent and reliable log data collection
- **Performance Optimization**: Identify and resolve query performance issues
- **Capacity Planning**: Proactive data retention and storage management
- **Operational Excellence**: Early detection of agent and connectivity issues
- **Custom Data Monitoring**: Track business-specific custom log tables

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/scheduledQueryRules/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.OperationalInsights/workspaces/read`
  - `Microsoft.OperationalInsights/workspaces/query/*/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Log Analytics Workspaces**: Workspaces deployed and collecting data
- **Log Analytics Agents**: Agents installed on monitored systems for comprehensive monitoring

## Usage

### Basic Configuration

```hcl
module "workspace_alerts" {
  source = "./modules/metricAlerts/workspaces"
  
  # Resource Configuration
  resource_group_name               = "rg-monitoring-production"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  location                          = "East US"
  
  # Log Analytics Workspaces to Monitor
  workspace_names = [
    "law-prod-eastus-001",
    "law-prod-westus-001",
    "law-security-001"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "Monitoring"
    Owner             = "monitoring-team@pge.com"
    CostCenter        = "IT-Operations"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "workspace_alerts_critical" {
  source = "./modules/metricAlerts/workspaces"
  
  # Resource Configuration
  resource_group_name               = "rg-monitoring-critical"
  action_group_resource_group_name  = "rg-monitoring"
  workspace_names                  = ["law-critical-systems-001"]
  
  # Strict Performance and Reliability Thresholds
  workspace_heartbeat_threshold         = 2     # Lower tolerance for missing heartbeats
  workspace_query_performance_threshold = 15000 # 15 seconds max query time
  workspace_error_rate_threshold       = 5     # Lower error rate tolerance
  workspace_agent_connection_threshold = 3     # Fewer connection issues tolerated
  workspace_custom_table_threshold     = 200   # Higher ingestion expectation
  
  # Data Retention Configuration
  workspace_retention_days         = 90  # 90-day retention
  workspace_retention_warning_days = 14  # 2-week warning period
  
  # Custom Tables Monitoring
  workspace_custom_tables = [
    "ApplicationLogs_CL",
    "SecurityEvents_CL",
    "PerformanceCounters_CL",
    "CustomMetrics_CL"
  ]
  
  # Enable All Monitoring
  enable_workspace_heartbeat_alert         = true
  enable_workspace_query_performance_alert = true
  enable_workspace_data_retention_alert    = true
  enable_workspace_error_rate_alert        = true
  enable_workspace_agent_connection_alert  = true
  enable_workspace_custom_table_alert      = true
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    Compliance  = "SOX-Critical"
    Owner       = "sre-team@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Workspaces - Relaxed Monitoring
workspace_heartbeat_threshold         = 10    # Higher tolerance
workspace_query_performance_threshold = 60000 # 60 seconds tolerance
workspace_error_rate_threshold       = 20    # Higher error tolerance
workspace_retention_days             = 7     # Shorter retention
workspace_retention_warning_days     = 2     # Short warning period

enable_workspace_data_retention_alert = false # Skip retention alerts in dev
enable_workspace_custom_table_alert   = false # Skip custom table monitoring
```

#### Staging Environment
```hcl
# Staging Workspaces - Production-like Monitoring
workspace_heartbeat_threshold         = 5     # Standard threshold
workspace_query_performance_threshold = 30000 # 30 seconds tolerance
workspace_error_rate_threshold       = 10    # Standard error tolerance
workspace_retention_days             = 30    # Standard retention
workspace_retention_warning_days     = 7     # Week warning

enable_workspace_heartbeat_alert         = true
enable_workspace_query_performance_alert = true
enable_workspace_error_rate_alert        = true
```

#### Production Environment
```hcl
# Production Workspaces - Strict Monitoring
workspace_heartbeat_threshold         = 3     # Low tolerance
workspace_query_performance_threshold = 20000 # 20 seconds max
workspace_error_rate_threshold       = 5     # Low error tolerance
workspace_retention_days             = 90    # Extended retention
workspace_retention_warning_days     = 14    # Two-week warning

# Enable comprehensive monitoring
enable_workspace_heartbeat_alert         = true
enable_workspace_query_performance_alert = true
enable_workspace_data_retention_alert    = true
enable_workspace_error_rate_alert        = true
enable_workspace_agent_connection_alert  = true
enable_workspace_custom_table_alert      = true
```

### Workspace Purpose-Specific Configurations

#### Security Operations Center (SOC) Workspace
```hcl
# SOC Workspace - Maximum Reliability
module "workspace_alerts_soc" {
  source = "./modules/metricAlerts/workspaces"
  
  workspace_names = ["law-soc-security-001"]
  
  # Critical security monitoring thresholds
  workspace_heartbeat_threshold         = 1     # Zero tolerance
  workspace_error_rate_threshold       = 2     # Minimal errors
  workspace_retention_days             = 365   # 1-year retention
  workspace_retention_warning_days     = 30    # Month warning
  
  workspace_custom_tables = [
    "SecurityIncidents_CL",
    "ThreatIntelligence_CL",
    "SecurityAlerts_CL"
  ]
  
  tags = {
    Purpose = "SecurityOperations"
    Criticality = "High"
    Compliance = "SOX,PCI-DSS,HIPAA"
  }
}
```

#### Application Performance Monitoring (APM) Workspace
```hcl
# APM Workspace - Performance Focus
module "workspace_alerts_apm" {
  source = "./modules/metricAlerts/workspaces"
  
  workspace_names = ["law-apm-performance-001"]
  
  # Performance-focused thresholds
  workspace_query_performance_threshold = 10000 # 10 seconds max
  workspace_custom_table_threshold     = 500   # High throughput expected
  
  workspace_custom_tables = [
    "ApplicationMetrics_CL",
    "PerformanceCounters_CL",
    "CustomTraces_CL",
    "UserBehavior_CL"
  ]
  
  tags = {
    Purpose = "ApplicationPerformanceMonitoring"
    DataType = "PerformanceMetrics"
  }
}
```

#### Infrastructure Monitoring Workspace
```hcl
# Infrastructure Workspace - System Focus
module "workspace_alerts_infra" {
  source = "./modules/metricAlerts/workspaces"
  
  workspace_names = ["law-infrastructure-001"]
  
  # Infrastructure-focused configuration
  workspace_heartbeat_threshold         = 5    # Monitor system agents
  workspace_agent_connection_threshold = 3    # Connection reliability
  
  workspace_custom_tables = [
    "VMPerformance_CL",
    "NetworkMetrics_CL",
    "StorageMetrics_CL",
    "SystemEvents_CL"
  ]
  
  tags = {
    Purpose = "InfrastructureMonitoring"
    DataType = "SystemTelemetry"
  }
}
```

#### Compliance and Audit Workspace
```hcl
# Compliance Workspace - Audit Focus
module "workspace_alerts_compliance" {
  source = "./modules/metricAlerts/workspaces"
  
  workspace_names = ["law-compliance-audit-001"]
  
  # Compliance-focused configuration
  workspace_retention_days             = 2555  # 7-year retention
  workspace_retention_warning_days     = 90    # 3-month warning
  workspace_error_rate_threshold       = 1     # Zero tolerance for audit data loss
  
  workspace_custom_tables = [
    "AuditLogs_CL",
    "ComplianceEvents_CL",
    "AccessLogs_CL",
    "DataClassificationEvents_CL"
  ]
  
  tags = {
    Purpose = "ComplianceAudit"
    DataRetention = "LongTerm"
    Compliance = "SOX,HIPAA,PCI-DSS"
  }
}
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `workspace_names` | `list(string)` | List of Log Analytics Workspace names to monitor |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for workspaces |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |

### Alert Enable/Disable Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_workspace_heartbeat_alert` | `bool` | `true` | Enable agent heartbeat monitoring |
| `enable_workspace_query_performance_alert` | `bool` | `true` | Enable query performance monitoring |
| `enable_workspace_data_retention_alert` | `bool` | `true` | Enable data retention monitoring |
| `enable_workspace_error_rate_alert` | `bool` | `true` | Enable error rate monitoring |
| `enable_workspace_agent_connection_alert` | `bool` | `true` | Enable agent connection monitoring |
| `enable_workspace_custom_table_alert` | `bool` | `true` | Enable custom table ingestion monitoring |

### Alert Threshold Variables

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `workspace_heartbeat_threshold` | `number` | `5` | Missing heartbeats before alert | 1-10 |
| `workspace_query_performance_threshold` | `number` | `30000` | Query duration threshold (ms) | 10000-60000 |
| `workspace_error_rate_threshold` | `number` | `10` | Error rate percentage threshold | 2-20% |
| `workspace_agent_connection_threshold` | `number` | `5` | Connection issues threshold | 1-10 |
| `workspace_custom_table_threshold` | `number` | `100` | Custom table ingestion threshold (MB) | 50-1000 MB |
| `workspace_retention_days` | `number` | `30` | Data retention period (days) | 7-2555 days |
| `workspace_retention_warning_days` | `number` | `7` | Retention warning period (days) | 1-90 days |

### Custom Tables Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `workspace_custom_tables` | `list(string)` | `["CustomTable1_CL", "CustomTable2_CL"]` | Custom table names to monitor |

**Example Custom Tables**:
```hcl
workspace_custom_tables = [
  "ApplicationLogs_CL",      # Application-specific logs
  "SecurityEvents_CL",       # Security event data
  "PerformanceMetrics_CL",   # Custom performance metrics
  "BusinessEvents_CL",       # Business process events
  "UserActivity_CL",         # User behavior tracking
  "SystemHealth_CL"          # Custom system health metrics
]
```

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "monitoring-team@pge.com"     # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "sre-team@pge.com"           # Notification contact
  DataClassification = "Internal"                    # Data sensitivity
  CostCenter         = "IT-Operations"              # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  Purpose            = "LogAnalytics"               # Workspace purpose
  DataRetention      = "Standard"                   # Retention classification
}
```

## Alert Details

### 1. Workspace Heartbeat Alert
- **Alert Name**: `workspace-heartbeat-missing-{workspace-names}`
- **Type**: Scheduled Query Rule
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Threshold**: 5 missing heartbeats (configurable)

**What this alert monitors**: Detection of agents that have stopped sending heartbeat data, indicating potential connectivity issues, agent failures, or system problems.

**KQL Query**:
```kusto
Heartbeat
| where TimeGenerated > ago(15m)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(10m)
| count
```

**What to do when this alert fires**:
1. **Identify Affected Systems**: Review alert details to identify which computers are missing heartbeats
2. **Connectivity Check**: Verify network connectivity between affected systems and Log Analytics workspace
3. **Agent Status Verification**: Check if Log Analytics agent (Microsoft Monitoring Agent/Azure Monitor Agent) is running
4. **System Health Assessment**: Verify that affected systems are online and responsive
5. **Agent Troubleshooting**: Restart Log Analytics agent service if necessary and check agent configuration

### 2. Workspace Query Performance Alert
- **Alert Name**: `workspace-query-performance-slow-{workspace-names}`
- **Type**: Scheduled Query Rule
- **Severity**: 3 (Informational)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Threshold**: Queries taking > 30 seconds (configurable)

**What this alert monitors**: Slow-running queries that may indicate workspace performance issues, inefficient queries, or resource constraints.

**KQL Query**:
```kusto
Operation
| where TimeGenerated > ago(30m)
| where OperationCategory == "Query"
| where OperationStatus == "Success"
| extend QueryDuration = todouble(OperationKey)
| where QueryDuration > 30000
| count
```

**What to do when this alert fires**:
1. **Query Analysis**: Identify specific queries that are running slowly using Log Analytics query performance logs
2. **Query Optimization**: Review and optimize KQL queries for better performance (reduce data scanned, use summarization)
3. **Resource Assessment**: Check workspace capacity limits and consider upgrading to higher tier if needed
4. **Time Range Optimization**: Reduce query time ranges and use appropriate time filters
5. **Index Usage**: Ensure queries are using indexed fields efficiently

### 3. Workspace Data Retention Alert
- **Alert Name**: `workspace-data-retention-expiring-{workspace-names}`
- **Type**: Scheduled Query Rule
- **Severity**: 3 (Informational)
- **Frequency**: P1D (Daily)
- **Window**: P1D (1 day)
- **Threshold**: Data within warning period of retention limit

**What this alert monitors**: Data approaching the configured retention period, providing advance warning for data archival or retention policy adjustments.

**KQL Query**:
```kusto
Usage
| where TimeGenerated > ago(1d)
| where IsBillable == true
| extend RetentionDays = 30
| extend DaysFromRetention = RetentionDays - datetime_diff('day', now(), TimeGenerated)
| where DaysFromRetention <= 7
| count
```

**What to do when this alert fires**:
1. **Data Assessment**: Identify which data types are approaching retention limits
2. **Archive Planning**: Plan data export or archival to cheaper storage if historical data is needed
3. **Retention Policy Review**: Evaluate if retention period should be extended for compliance or operational needs
4. **Cost Analysis**: Calculate costs of extending retention vs. archiving data
5. **Compliance Verification**: Ensure retention policies meet regulatory compliance requirements

### 4. Workspace Error Rate Alert
- **Alert Name**: `workspace-error-rate-high-{workspace-names}`
- **Type**: Scheduled Query Rule
- **Severity**: 2 (High)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Threshold**: Error rate > 10% (configurable)

**What this alert monitors**: High error rates in workspace operations, indicating data ingestion failures, query errors, or system issues.

**KQL Query**:
```kusto
Operation
| where TimeGenerated > ago(30m)
| where OperationStatus == "Failed"
| summarize ErrorCount = count(), TotalCount = countif(OperationStatus in ("Success", "Failed"))
| extend ErrorRate = (ErrorCount * 100.0) / TotalCount
| where ErrorRate > 10
| count
```

**What to do when this alert fires**:
1. **Error Analysis**: Investigate specific errors using Operation table to identify root causes
2. **Data Source Check**: Verify that data sources (agents, APIs, connectors) are functioning correctly
3. **Workspace Health**: Check workspace capacity, throttling limits, and service health
4. **Configuration Review**: Verify data collection rules and workspace configuration
5. **Escalation**: Contact Azure Support if errors indicate platform issues

### 5. Workspace Agent Connection Alert
- **Alert Name**: `workspace-agent-connection-lost-{workspace-names}`
- **Type**: Scheduled Query Rule
- **Severity**: 3 (Informational)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT1H (1 hour)
- **Threshold**: > 5 connection issues (configurable)

**What this alert monitors**: Agent connection problems including timeouts and connectivity failures that may indicate network or configuration issues.

**KQL Query**:
```kusto
Operation
| where TimeGenerated > ago(1h)
| where OperationCategory == "Data Collection"
| where Detail contains "connection" or Detail contains "timeout"
| summarize ConnectionIssues = count() by Computer
| where ConnectionIssues > 5
| count
```

**What to do when this alert fires**:
1. **Network Diagnostics**: Check network connectivity between agents and Azure Log Analytics endpoints
2. **Firewall Verification**: Ensure required URLs and ports are open for Log Analytics communication
3. **Agent Configuration**: Verify agent configuration including workspace ID and key
4. **DNS Resolution**: Test DNS resolution for Log Analytics endpoints
5. **Regional Issues**: Check for Azure service health issues in your region

### 6. Workspace Custom Table Ingestion Alert
- **Alert Name**: `workspace-custom-table-ingestion-low-{workspace-names}`
- **Type**: Scheduled Query Rule
- **Severity**: 3 (Informational)
- **Frequency**: PT30M (30 minutes)
- **Window**: PT2H (2 hours)
- **Threshold**: Ingestion < 100 MB (configurable)

**What this alert monitors**: Custom table data ingestion rates falling below expected thresholds, indicating potential data pipeline issues.

**KQL Query**:
```kusto
Usage
| where TimeGenerated > ago(2h)
| where DataType in ('CustomTable1_CL','CustomTable2_CL')
| summarize DataVolume = sum(Quantity) by DataType
| where DataVolume < 100
| count
```

**What to do when this alert fires**:
1. **Data Pipeline Check**: Verify custom data ingestion pipelines and APIs are functioning
2. **Source System Validation**: Check that source systems are generating and sending expected data
3. **API Authentication**: Verify API keys, certificates, and authentication mechanisms
4. **Data Format Validation**: Ensure custom data format matches expected schema
5. **Rate Limiting**: Check if hitting ingestion rate limits or throttling

## Severity Levels

### Severity 2 (High) - Operational Impact
- **Workspace Heartbeat**: Missing agent heartbeats indicating data collection issues
- **Workspace Error Rate**: High error rates affecting data reliability and system operations

**Response Time**: 1 hour
**Escalation**: Notification to monitoring team and affected system owners

### Severity 3 (Informational) - Performance and Maintenance
- **Query Performance**: Slow queries affecting user experience and dashboard performance
- **Data Retention**: Data approaching retention limits requiring action
- **Agent Connection**: Connection issues that may impact data collection
- **Custom Table Ingestion**: Reduced custom data ingestion requiring investigation

**Response Time**: 4 hours
**Escalation**: Standard operational notification for optimization and maintenance

## Cost Analysis

### Alert Costs (Monthly)
- **6 Scheduled Query Rules per Workspace**: 6 × $0.10 = **$0.60 per Workspace per month**
- **Action Group**: FREE (included)
- **Multi-Workspace Deployment**: Scales linearly with workspace count

### Cost Examples by Environment

#### Small Environment (2 Workspaces)
- **Monthly Alert Cost**: 2 × $0.60 = $1.20
- **Annual Alert Cost**: $14.40

#### Medium Environment (5 Workspaces)
- **Monthly Alert Cost**: 5 × $0.60 = $3.00
- **Annual Alert Cost**: $36.00

#### Large Environment (15 Workspaces)
- **Monthly Alert Cost**: 15 × $0.60 = $9.00
- **Annual Alert Cost**: $108.00

#### Enterprise Environment (50 Workspaces)
- **Monthly Alert Cost**: 50 × $0.60 = $30.00
- **Annual Alert Cost**: $360.00

#### Global Enterprise Environment (200 Workspaces)
- **Monthly Alert Cost**: 200 × $0.60 = $120.00
- **Annual Alert Cost**: $1,440.00

### Return on Investment (ROI)

#### Cost of Log Analytics Issues Without Monitoring
- **Data Loss**: $100,000-1,000,000 for compliance violations and audit failures
- **Troubleshooting Delays**: $50,000-500,000 in extended incident resolution time
- **Compliance Violations**: $500,000-5,000,000 in regulatory fines and penalties
- **Security Blind Spots**: $1,000,000-10,000,000 for undetected security incidents
- **Performance Degradation**: $25,000-250,000 in operational inefficiency
- **Data Recovery**: $100,000-1,000,000 for data reconstruction and recovery efforts

#### Alert Value Calculation (15 Workspaces)
- **Annual Alert Cost**: $108.00
- **Prevented Data Loss Incident**: $500,000 (conservative estimate for 1 incident/year)
- **Cost Avoidance**: $500,000/year
- **ROI**: 462,863% (($500,000 - $108) / $108 × 100)

#### Additional Benefits
- **Proactive Issue Resolution**: Early detection preventing data collection failures
- **Compliance Assurance**: Continuous monitoring for audit and regulatory requirements
- **Operational Efficiency**: Reduced manual monitoring and faster issue resolution
- **Data Quality**: Consistent data collection ensuring reliable analytics and insights
- **Performance Optimization**: Query performance monitoring enabling dashboard optimization

### Log Analytics Workspace Pricing Context
- **Pay-as-you-go**: $2.30/GB ingested per month
- **Commitment Tiers**: 100GB/day (~$196/month), 200GB/day (~$350/month)
- **Data Retention**: $0.10/GB/month beyond 31 days
- **Data Export**: $0.13/GB for continuous export

**Alert Cost Impact**: 0.1-1% of workspace operational costs, preventing 10-100x that cost in data loss and compliance issues

## Best Practices

### Workspace Configuration Best Practices

#### 1. Workspace Design and Structure
```hcl
# Workspace segregation by purpose and compliance requirements
module "workspace_alerts_security" {
  source = "./modules/metricAlerts/workspaces"
  
  workspace_names = ["law-security-soc-001"]
  
  # Security workspace - strict monitoring
  workspace_heartbeat_threshold    = 1    # Zero tolerance for missing data
  workspace_error_rate_threshold  = 2    # Minimal error tolerance
  workspace_retention_days        = 730  # 2-year retention for security
  
  tags = {
    Purpose = "SecurityOperations"
    DataClassification = "Confidential"
    Compliance = "SOX,PCI-DSS,HIPAA"
  }
}

module "workspace_alerts_application" {
  source = "./modules/metricAlerts/workspaces"
  
  workspace_names = ["law-app-performance-001"]
  
  # Application workspace - performance focus
  workspace_query_performance_threshold = 15000  # 15-second query limit
  workspace_custom_table_threshold     = 500    # High ingestion expected
  
  tags = {
    Purpose = "ApplicationMonitoring"
    DataClassification = "Internal"
  }
}
```

#### 2. Data Collection Rule Configuration
```bash
# Create data collection rule for structured data ingestion
az monitor data-collection rule create \
  --resource-group "rg-monitoring" \
  --name "dcr-application-logs" \
  --location "eastus" \
  --rule-file "dcr-application-logs.json"

# Example DCR configuration file
cat > dcr-application-logs.json << EOF
{
  "location": "eastus",
  "properties": {
    "dataSources": {
      "logFiles": [
        {
          "streams": ["Custom-ApplicationLog"],
          "filePatterns": ["/var/log/application/*.log"],
          "format": "text",
          "name": "applicationLogFiles"
        }
      ]
    },
    "destinations": {
      "logAnalytics": [
        {
          "workspaceResourceId": "/subscriptions/{sub-id}/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-app-performance-001",
          "name": "workspace001"
        }
      ]
    },
    "dataFlows": [
      {
        "streams": ["Custom-ApplicationLog"],
        "destinations": ["workspace001"],
        "transformKql": "source | extend TimeGenerated = now()",
        "outputStream": "Custom-ApplicationLogs_CL"
      }
    ]
  }
}
EOF
```

#### 3. Query Performance Optimization
```kusto
// Example of optimized query patterns

// BAD: Scanning all data without time filter
SecurityEvent
| where EventID == 4624
| summarize count() by Computer

// GOOD: Time filter first, then specific conditions
SecurityEvent
| where TimeGenerated > ago(1h)
| where EventID == 4624
| summarize count() by Computer

// BAD: Complex string operations on large datasets
Heartbeat
| extend ComputerLower = tolower(Computer)
| where ComputerLower contains "web"

// GOOD: Use built-in operators and filters
Heartbeat
| where TimeGenerated > ago(15m)
| where Computer has "web"

// Performance monitoring query example
Operation
| where TimeGenerated > ago(30m)
| where OperationCategory == "Query"
| where OperationStatus == "Success"
| extend QueryDuration = todouble(OperationKey)
| summarize 
    AvgDuration = avg(QueryDuration),
    MaxDuration = max(QueryDuration),
    QueryCount = count()
    by bin(TimeGenerated, 5m)
| render timechart
```

### Monitoring and Alerting Best Practices

#### 1. Custom Dashboard for Workspace Health
```powershell
# PowerShell script for workspace health dashboard
function New-WorkspaceHealthDashboard {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WorkspaceName,
        
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )
    
    # Get workspace information
    $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
    
    Write-Host "Creating health dashboard for workspace: $WorkspaceName" -ForegroundColor Green
    
    # Define key health queries
    $HealthQueries = @{
        "Agent Heartbeat Status" = @"
            Heartbeat
            | where TimeGenerated > ago(1h)
            | summarize LastHeartbeat = max(TimeGenerated) by Computer
            | extend Status = case(LastHeartbeat > ago(15m), "Healthy",
                                   LastHeartbeat > ago(30m), "Warning", 
                                   "Critical")
            | summarize count() by Status
"@
        "Data Ingestion Rate" = @"
            Usage
            | where TimeGenerated > ago(1h)
            | where IsBillable == true
            | summarize DataIngested = sum(Quantity) by bin(TimeGenerated, 5m), DataType
            | render timechart
"@
        "Query Performance" = @"
            Operation
            | where TimeGenerated > ago(1h)
            | where OperationCategory == "Query"
            | extend QueryDuration = todouble(OperationKey)
            | summarize 
                AvgDuration = avg(QueryDuration),
                MaxDuration = max(QueryDuration)
                by bin(TimeGenerated, 5m)
            | render timechart
"@
        "Error Rate" = @"
            Operation
            | where TimeGenerated > ago(1h)
            | summarize 
                TotalOps = count(),
                Errors = countif(OperationStatus == "Failed")
                by bin(TimeGenerated, 5m)
            | extend ErrorRate = (Errors * 100.0) / TotalOps
            | render timechart
"@
    }
    
    # Execute queries and display results
    foreach ($QueryName in $HealthQueries.Keys) {
        Write-Host "`n$QueryName" -ForegroundColor Cyan
        Write-Host "=" * $QueryName.Length -ForegroundColor Cyan
        
        try {
            $Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $HealthQueries[$QueryName]
            Write-Host "Query executed successfully. Results: $($Results.Results.Count) rows" -ForegroundColor Green
        } catch {
            Write-Host "Error executing query: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Usage
New-WorkspaceHealthDashboard -WorkspaceName "law-prod-eastus-001" -ResourceGroupName "rg-monitoring"
```

#### 2. Automated Workspace Health Check
```bash
#!/bin/bash
# Bash script for automated workspace health checks

WORKSPACE_NAME="law-prod-eastus-001"
RESOURCE_GROUP="rg-monitoring"
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --query "customerId" -o tsv)

echo "Workspace Health Check: $WORKSPACE_NAME"
echo "======================================"
echo "Workspace ID: $WORKSPACE_ID"
echo ""

# Check 1: Agent heartbeat status
echo "1. Checking agent heartbeat status..."
HEARTBEAT_QUERY="Heartbeat | where TimeGenerated > ago(15m) | distinct Computer | count"
ACTIVE_AGENTS=$(az monitor log-analytics query \
  --workspace "$WORKSPACE_ID" \
  --analytics-query "$HEARTBEAT_QUERY" \
  --query "tables[0].rows[0][0]" -o tsv)

echo "   Active agents (last 15 minutes): $ACTIVE_AGENTS"

# Check 2: Data ingestion rate
echo "2. Checking data ingestion rate..."
INGESTION_QUERY="Usage | where TimeGenerated > ago(1h) | where IsBillable == true | summarize TotalMB = sum(Quantity)"
INGESTION_RATE=$(az monitor log-analytics query \
  --workspace "$WORKSPACE_ID" \
  --analytics-query "$INGESTION_QUERY" \
  --query "tables[0].rows[0][0]" -o tsv)

echo "   Data ingested (last hour): ${INGESTION_RATE} MB"

# Check 3: Error rate
echo "3. Checking error rate..."
ERROR_QUERY="Operation | where TimeGenerated > ago(1h) | summarize ErrorRate = (countif(OperationStatus == 'Failed') * 100.0) / count()"
ERROR_RATE=$(az monitor log-analytics query \
  --workspace "$WORKSPACE_ID" \
  --analytics-query "$ERROR_QUERY" \
  --query "tables[0].rows[0][0]" -o tsv)

echo "   Error rate (last hour): ${ERROR_RATE}%"

# Health assessment
echo ""
echo "Health Assessment:"
echo "=================="

if (( $(echo "$ERROR_RATE > 10" | bc -l) )); then
    echo "❌ HIGH ERROR RATE: $ERROR_RATE% (threshold: 10%)"
else
    echo "✅ Error rate normal: $ERROR_RATE%"
fi

if (( $(echo "$INGESTION_RATE < 50" | bc -l) )); then
    echo "⚠️  LOW INGESTION RATE: $INGESTION_RATE MB (expected: >50 MB/hour)"
else
    echo "✅ Ingestion rate normal: $INGESTION_RATE MB"
fi

if [ "$ACTIVE_AGENTS" -lt 5 ]; then
    echo "⚠️  LOW AGENT COUNT: $ACTIVE_AGENTS (expected: >5)"
else
    echo "✅ Agent count normal: $ACTIVE_AGENTS"
fi

echo ""
echo "Health check completed at $(date)"
```

#### 3. Data Retention Management
```powershell
# PowerShell script for data retention management
function Manage-WorkspaceDataRetention {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WorkspaceName,
        
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$false)]
        [int]$RetentionDays = 90
    )
    
    Write-Host "Managing data retention for workspace: $WorkspaceName" -ForegroundColor Green
    Write-Host "Target retention period: $RetentionDays days" -ForegroundColor Yellow
    
    # Get current workspace configuration
    $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
    
    Write-Host "Current retention period: $($Workspace.RetentionInDays) days" -ForegroundColor Cyan
    
    # Calculate storage costs for different retention periods
    $RetentionOptions = @(30, 90, 180, 365, 730)
    
    Write-Host "`nRetention Cost Analysis:" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Green
    
    foreach ($Days in $RetentionOptions) {
        $MonthlyCost = if ($Days -le 31) { 0 } else { ($Days - 31) * 0.10 }  # $0.10/GB/month beyond 31 days
        $AnnualCost = $MonthlyCost * 12
        
        $Status = if ($Days -eq $Workspace.RetentionInDays) { " (CURRENT)" } else { "" }
        Write-Host "$Days days: $MonthlyCost/GB/month, $AnnualCost/GB/year$Status" -ForegroundColor $(if ($Status) { "Yellow" } else { "White" })
    }
    
    # Query for data volume analysis
    $DataVolumeQuery = @"
        Usage
        | where TimeGenerated > ago(30d)
        | where IsBillable == true
        | summarize 
            TotalGB = sum(Quantity) / 1000,
            DailyAvgGB = (sum(Quantity) / 1000) / 30
            by DataType
        | order by TotalGB desc
"@
    
    Write-Host "`nData Volume Analysis (Last 30 days):" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    
    try {
        $Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $DataVolumeQuery
        
        foreach ($Row in $Results.Results) {
            $DataType = $Row.DataType
            $TotalGB = [math]::Round($Row.TotalGB, 2)
            $DailyGB = [math]::Round($Row.DailyAvgGB, 2)
            
            Write-Host "$DataType`: $TotalGB GB total, $DailyGB GB/day average" -ForegroundColor White
        }
    } catch {
        Write-Host "Error querying data volume: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Update retention if different
    if ($RetentionDays -ne $Workspace.RetentionInDays) {
        Write-Host "`nUpdating retention period from $($Workspace.RetentionInDays) to $RetentionDays days..." -ForegroundColor Yellow
        
        try {
            Set-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -RetentionInDays $RetentionDays
            Write-Host "Retention period updated successfully!" -ForegroundColor Green
        } catch {
            Write-Host "Error updating retention period: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Usage
Manage-WorkspaceDataRetention -WorkspaceName "law-prod-eastus-001" -ResourceGroupName "rg-monitoring" -RetentionDays 90
```

### Custom Table Management

#### 1. Create and Monitor Custom Tables
```bash
# Create custom table schema
az monitor log-analytics workspace table create \
  --resource-group "rg-monitoring" \
  --workspace-name "law-prod-eastus-001" \
  --name "ApplicationMetrics_CL" \
  --columns '[
    {"name": "TimeGenerated", "type": "datetime"},
    {"name": "ApplicationName", "type": "string"},
    {"name": "MetricName", "type": "string"},
    {"name": "MetricValue", "type": "real"},
    {"name": "Environment", "type": "string"},
    {"name": "ServerName", "type": "string"}
  ]'

# Send sample data to custom table
curl -X POST \
  -H "Authorization: Bearer $(az account get-access-token --query accessToken -o tsv)" \
  -H "Content-Type: application/json" \
  -H "Log-Type: ApplicationMetrics" \
  -H "time-generated-field: TimeGenerated" \
  "https://law-prod-eastus-001.ods.opinsights.azure.com/api/logs?api-version=2016-04-01" \
  -d '[{
    "TimeGenerated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
    "ApplicationName": "WebApp1",
    "MetricName": "ResponseTime",
    "MetricValue": 245.5,
    "Environment": "Production",
    "ServerName": "web-01"
  }]'
```

#### 2. Custom Table Monitoring Query
```kusto
// Monitor custom table ingestion patterns
ApplicationMetrics_CL
| where TimeGenerated > ago(24h)
| summarize 
    RecordCount = count(),
    UniqueApps = dcount(ApplicationName),
    AvgMetricValue = avg(MetricValue),
    DataVolumeMB = (count() * 0.001)  // Approximate data volume
    by bin(TimeGenerated, 1h), Environment
| render timechart
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Missing Heartbeat Data
**Symptoms**: Workspace heartbeat alerts firing for multiple systems

**Possible Causes**:
- Log Analytics agent stopped or not installed
- Network connectivity issues
- Workspace key/ID misconfiguration
- Agent authentication failures

**Troubleshooting Steps**:
```bash
# Check agent status on Linux
sudo systemctl status omsagent

# Check agent status on Windows
Get-Service -Name "Microsoft Monitoring Agent" -ComputerName "target-server"

# Test connectivity to Log Analytics endpoints
curl -v https://law-prod-eastus-001.ods.opinsights.azure.com

# Verify agent configuration
sudo cat /etc/opt/microsoft/omsagent/conf/omsadmin.conf

# Windows agent configuration
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\HealthService\Parameters\Service Connector Services\Log Analytics*"
```

**Resolution**:
- Restart Log Analytics agent service
- Verify correct workspace ID and key configuration
- Check firewall rules and network connectivity
- Reinstall agent if configuration is corrupted

#### 2. Slow Query Performance
**Symptoms**: Query performance alerts indicating slow-running queries

**Possible Causes**:
- Inefficient KQL queries without time filters
- Large data volume queries without optimization
- Workspace resource limits reached
- Complex joins and aggregations

**Troubleshooting Steps**:
```kusto
// Identify slow queries
Operation
| where TimeGenerated > ago(24h)
| where OperationCategory == "Query"
| extend QueryDuration = todouble(OperationKey)
| where QueryDuration > 30000
| order by QueryDuration desc
| project TimeGenerated, QueryDuration, Detail, OperationId

// Query performance analysis
Operation
| where TimeGenerated > ago(24h)
| where OperationCategory == "Query"
| extend QueryDuration = todouble(OperationKey)
| summarize 
    AvgDuration = avg(QueryDuration),
    MaxDuration = max(QueryDuration),
    P95Duration = percentile(QueryDuration, 95),
    QueryCount = count()
    by bin(TimeGenerated, 1h)
| render timechart
```

**Resolution**:
- Add appropriate time filters to queries (`TimeGenerated > ago(1h)`)
- Use `summarize` and `where` clauses early in queries
- Avoid unnecessary `distinct` and complex string operations
- Consider workspace capacity upgrade if resource limits are reached

#### 3. High Error Rates
**Symptoms**: Error rate alerts indicating failures in workspace operations

**Possible Causes**:
- Data ingestion failures
- Authentication issues
- Rate limiting or throttling
- Malformed data submissions

**Troubleshooting Steps**:
```kusto
// Analyze error patterns
Operation
| where TimeGenerated > ago(24h)
| where OperationStatus == "Failed"
| summarize ErrorCount = count() by OperationCategory, ResultDescription
| order by ErrorCount desc

// Error trends over time
Operation
| where TimeGenerated > ago(24h)
| summarize 
    TotalOps = count(),
    Errors = countif(OperationStatus == "Failed"),
    SuccessRate = countif(OperationStatus == "Success") * 100.0 / count()
    by bin(TimeGenerated, 15m)
| render timechart
```

**Resolution**:
- Check data source authentication and configuration
- Verify API keys and certificates for custom data sources
- Review data format and schema compliance
- Check for workspace capacity limits and throttling

#### 4. Agent Connection Issues
**Symptoms**: Agent connection alerts indicating connectivity problems

**Possible Causes**:
- Network connectivity interruptions
- Firewall blocking Log Analytics endpoints
- DNS resolution issues
- Proxy configuration problems

**Troubleshooting Steps**:
```bash
# Test DNS resolution
nslookup law-prod-eastus-001.ods.opinsights.azure.com

# Test endpoint connectivity
telnet law-prod-eastus-001.ods.opinsights.azure.com 443

# Check proxy configuration (if applicable)
curl -x http://proxy:8080 -v https://law-prod-eastus-001.ods.opinsights.azure.com

# Review agent logs for connection errors
# Linux
sudo tail -f /var/opt/microsoft/omsagent/log/omsagent.log

# Windows
Get-EventLog -LogName "Operations Manager" -Source "Health Service*" -EntryType Error -Newest 50
```

**Resolution**:
- Configure firewall to allow required Log Analytics endpoints
- Fix DNS configuration or use alternative DNS servers
- Configure proxy settings if required
- Update agent to latest version

#### 5. Custom Table Ingestion Issues
**Symptoms**: Custom table ingestion alerts indicating low or no data ingestion

**Possible Causes**:
- API authentication failures
- Data format validation errors
- Rate limiting or schema mismatches
- Application or data pipeline failures

**Troubleshooting Steps**:
```bash
# Test API authentication
ACCESS_TOKEN=$(az account get-access-token --query accessToken -o tsv)
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://management.azure.com/subscriptions/{sub-id}/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-prod-eastus-001?api-version=2021-06-01"

# Test data ingestion API
curl -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Log-Type: TestTable" \
  "https://law-prod-eastus-001.ods.opinsights.azure.com/api/logs?api-version=2016-04-01" \
  -d '[{"TestField": "TestValue", "TimeGenerated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}]'
```

**Resolution**:
- Verify API authentication tokens and workspace access
- Check data format against table schema requirements
- Review application logs for data submission errors
- Validate JSON format and required fields

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Log Analytics Workspace monitoring and follows PGE operational standards. Ensure proper testing of KQL queries in non-production environments before deploying alerts to production workspaces. Regular review and optimization of queries based on actual data patterns, workspace performance, and retention requirements is recommended for optimal monitoring effectiveness. **Log Analytics workspace health is critical for overall observability** - ensure proper redundancy and backup strategies for production monitoring environments.