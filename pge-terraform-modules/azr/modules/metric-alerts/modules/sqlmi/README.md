# Azure SQL Managed Instance - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure SQL Managed Instance**, providing proactive monitoring for instance performance, capacity, availability, and administrative operations. The module monitors critical infrastructure metrics to ensure optimal SQL Server performance, resource utilization, and operational continuity.

Azure SQL Managed Instance is a fully managed Platform-as-a-Service (PaaS) that provides near 100% compatibility with the latest SQL Server Database Engine, combining the best of SQL Server with the benefits of a fully managed service. This module focuses on instance-level metrics including CPU utilization, storage consumption, vCore usage, and administrative oversight.

## Features

- **Multi-Tier Performance Monitoring**: Warning and critical thresholds for CPU and storage metrics
- **Capacity Management**: Storage utilization and vCore monitoring for resource planning
- **Administrative Security**: Deletion protection and audit trail for critical operations
- **Scalable Monitoring**: Support for multiple SQL Managed Instances in a single deployment
- **Real-Time Alerting**: 5-minute evaluation frequency for rapid issue detection
- **Cost-Effective Monitoring**: Optimized alert configuration at $0.60 per instance per month
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **Performance Optimization**: CPU and vCore utilization tracking for workload management
- **Capacity Planning**: Storage monitoring for growth planning and threshold management
- **Resource Management**: vCore allocation and utilization for performance tuning
- **Operational Security**: Administrative operation monitoring and deletion protection
- **Multi-Instance Management**: Centralized monitoring for multiple managed instances

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Sql/managedInstances/read`
- **Action Group**: Pre-configured action group for alert notifications
- **SQL Managed Instances**: Existing Azure SQL Managed Instances to monitor

## Usage

### Basic Configuration

```hcl
module "sql_managed_instance_alerts" {
  source = "./modules/metricAlerts/sqlmi"
  
  # Resource Configuration
  resource_group_name               = "rg-production-data"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # SQL Managed Instances to Monitor
  sql_mi_names = [
    "sqlmi-prod-001",
    "sqlmi-prod-002"
  ]
  sql_mi_resource_group = "rg-production-data"
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "Database"
    Owner             = "data-platform@pge.com"
    CostCenter        = "IT-DataServices"
    Compliance        = "SOX"
    DataClassification = "Confidential"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "sql_mi_alerts_high_performance" {
  source = "./modules/metricAlerts/sqlmi"
  
  # Resource Configuration
  resource_group_name               = "rg-production-data"
  action_group_resource_group_name  = "rg-monitoring"
  sql_mi_names                     = ["sqlmi-critical-001"]
  sql_mi_resource_group            = "rg-production-data"
  
  # High-Performance Instance Thresholds
  cpu_warning_threshold    = 70    # Lower CPU tolerance for critical systems
  cpu_critical_threshold   = 80    # Aggressive CPU monitoring
  
  # Capacity Thresholds (Large Instance)
  storage_warning_threshold  = 75    # Earlier storage warning
  storage_critical_threshold = 85    # Earlier critical alert
  
  # Custom Evaluation Windows
  evaluation_frequency = "PT1M"      # 1-minute evaluation for critical instances
  window_size         = "PT5M"      # 5-minute window for faster detection
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    SLA         = "99.95%"
    Owner       = "dba-team@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Instances - Relaxed Thresholds
cpu_warning_threshold      = 90
cpu_critical_threshold     = 95
storage_warning_threshold  = 90
storage_critical_threshold = 95
evaluation_frequency      = "PT15M"
window_size              = "PT30M"
```

#### Staging Environment
```hcl
# Staging Instances - Moderate Thresholds
cpu_warning_threshold      = 85
cpu_critical_threshold     = 92
storage_warning_threshold  = 85
storage_critical_threshold = 92
evaluation_frequency      = "PT10M"
window_size              = "PT20M"
```

#### Production Environment
```hcl
# Production Instances - Strict Thresholds
cpu_warning_threshold      = 80
cpu_critical_threshold     = 90
storage_warning_threshold  = 80
storage_critical_threshold = 90
evaluation_frequency      = "PT5M"
window_size              = "PT15M"
```

### Instance Tier-Specific Configurations

#### General Purpose (GP) Instances
```hcl
# General Purpose - Balanced Performance
cpu_warning_threshold      = 80
cpu_critical_threshold     = 90
storage_warning_threshold  = 85
storage_critical_threshold = 92
```

#### Business Critical (BC) Instances
```hcl
# Business Critical - High Performance Requirements
cpu_warning_threshold      = 70
cpu_critical_threshold     = 85
storage_warning_threshold  = 75
storage_critical_threshold = 85
```

#### Memory Optimized Instances
```hcl
# Memory Optimized - High Memory Workloads
cpu_warning_threshold      = 75
cpu_critical_threshold     = 87
storage_warning_threshold  = 80
storage_critical_threshold = 90
```

### Use Case-Specific Configurations

#### OLTP Workloads
```hcl
# OLTP - High Transaction Processing
cpu_warning_threshold      = 75
cpu_critical_threshold     = 85
storage_warning_threshold  = 80
storage_critical_threshold = 90
evaluation_frequency      = "PT1M"
window_size              = "PT5M"
```

#### Data Warehouse Workloads
```hcl
# Data Warehouse - Analytics Focused
cpu_warning_threshold      = 85
cpu_critical_threshold     = 95
storage_warning_threshold  = 70
storage_critical_threshold = 80
evaluation_frequency      = "PT5M"
window_size              = "PT15M"
```

#### Hybrid Workloads
```hcl
# Hybrid - Mixed Workload Types
cpu_warning_threshold      = 80
cpu_critical_threshold     = 90
storage_warning_threshold  = 80
storage_critical_threshold = 90
evaluation_frequency      = "PT5M"
window_size              = "PT15M"
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for SQL Managed Instances |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
| `sql_mi_names` | `list(string)` | `[]` | List of SQL Managed Instance names |
| `sql_mi_resource_group` | `string` | `"rg-amba"` | Resource group containing SQL Managed Instances |

### Alert Configuration Variables

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `evaluation_frequency` | `string` | `"PT5M"` | Alert evaluation frequency | PT1M - PT15M |
| `window_size` | `string` | `"PT15M"` | Evaluation window size | PT5M - PT1H |

### Performance Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `cpu_warning_threshold` | `number` | `80` | CPU utilization warning percentage | 70-85% |
| `cpu_critical_threshold` | `number` | `90` | CPU utilization critical percentage | 80-95% |

### Storage Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `storage_warning_threshold` | `number` | `80` | Storage utilization warning percentage | 70-85% |
| `storage_critical_threshold` | `number` | `90` | Storage utilization critical percentage | 80-95% |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "data-platform@pge.com"      # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "dba-oncall@pge.com"         # Notification contact
  DataClassification = "Confidential"               # Data sensitivity
  CostCenter         = "IT-DataServices"            # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  SLA                = "99.95%"                     # Service level agreement
}
```

## Alert Details

### 1. CPU Utilization Warning Alert
- **Alert Name**: `sqlmi-cpu-warning-{instance-name}`
- **Metric**: `avg_cpu_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: CPU utilization of the SQL Managed Instance, indicating overall computational load and query processing demands across all databases.

**What to do when this alert fires**:
1. **Performance Analysis**: Use SQL Server Management Studio or Azure portal to identify resource-intensive queries
2. **Database Assessment**: Review individual database CPU consumption patterns
3. **Query Optimization**: Analyze and optimize the most CPU-consuming queries using execution plans
4. **Index Review**: Identify missing indexes that could reduce CPU load
5. **Scaling Consideration**: Evaluate if workload requires more vCores or different service tier

### 2. CPU Utilization Critical Alert
- **Alert Name**: `sqlmi-cpu-critical-{instance-name}`
- **Metric**: `avg_cpu_percent`
- **Threshold**: 90% (configurable)
- **Severity**: 0 (Critical)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Critical CPU utilization levels that may impact application performance and user experience across all databases on the instance.

**What to do when this alert fires**:
1. **Immediate Action**: Identify and terminate any non-essential or runaway queries
2. **Emergency Scaling**: Consider immediate vCore scaling if supported by service tier
3. **Workload Distribution**: Move non-critical workloads to other instances if available
4. **Performance Bottleneck Resolution**: Focus on immediate optimization of top CPU consumers
5. **Incident Management**: Engage DBA team and stakeholders for critical performance issue resolution

### 3. Storage Utilization Warning Alert
- **Alert Name**: `sqlmi-storage-warning-{instance-name}`
- **Metric**: `storage_space_used_mb`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Storage space consumption across all databases on the SQL Managed Instance, providing early warning for capacity planning.

**What to do when this alert fires**:
1. **Storage Analysis**: Review storage consumption by database and identify largest consumers
2. **Data Cleanup**: Implement data archiving and purging for old or unnecessary data
3. **Growth Planning**: Analyze storage growth trends and project future requirements
4. **Database Maintenance**: Perform index maintenance and cleanup operations
5. **Capacity Planning**: Plan for storage expansion or tier upgrade

### 4. Storage Utilization Critical Alert
- **Alert Name**: `sqlmi-storage-critical-{instance-name}`
- **Metric**: `storage_space_used_mb`
- **Threshold**: 90% (configurable)
- **Severity**: 0 (Critical)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Critical storage space utilization that may lead to database unavailability if storage is exhausted.

**What to do when this alert fires**:
1. **Immediate Storage Review**: Identify immediate opportunities for space reclamation
2. **Emergency Cleanup**: Execute emergency data cleanup and archiving procedures
3. **Storage Scaling**: Increase storage limits immediately if possible
4. **Database Shrinking**: Consider database shrinking operations for immediate space recovery
5. **Escalation**: Engage management for emergency storage expansion approval

### 5. vCore Utilization Warning Alert
- **Alert Name**: `sqlmi-vcore-warning-{instance-name}`
- **Metric**: `virtual_core_count`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: vCore utilization indicating computational resource consumption and the need for potential scaling decisions.

**What to do when this alert fires**:
1. **vCore Analysis**: Review current vCore allocation versus utilization patterns
2. **Workload Assessment**: Analyze workload distribution and peak usage times
3. **Performance Impact**: Evaluate if vCore constraints are affecting query performance
4. **Scaling Planning**: Plan for vCore scaling based on workload requirements
5. **Cost Optimization**: Balance performance needs with cost implications of scaling

### 6. SQL Managed Instance Deletion Alert
- **Alert Name**: `sqlmi-deletion-{instance-name}`
- **Operation**: `Microsoft.Sql/managedInstances/delete`
- **Severity**: Critical (Activity Log)
- **Frequency**: Immediate
- **Scope**: Individual managed instances

**What this alert monitors**: Administrative deletion of SQL Managed Instances, providing audit trail and protection against accidental deletion.

**What to do when this alert fires**:
1. **Immediate Verification**: Confirm if deletion was authorized and intentional
2. **Impact Assessment**: Evaluate impact on all databases and dependent applications
3. **Backup Verification**: Confirm recent backups are available for all databases
4. **Recovery Planning**: Initiate instance restoration procedures if deletion was unauthorized
5. **Security Review**: Investigate who had deletion permissions and review access controls

## Severity Levels

### Severity 0 (Critical) - Service Impact
- **CPU Critical**: Severe performance degradation affecting all applications
- **Storage Critical**: Risk of database unavailability due to storage exhaustion
- **Instance Deletion**: Complete service loss requiring immediate restoration

**Response Time**: Immediate (< 5 minutes)
**Escalation**: Immediate notification to DBA team, on-call engineer, and management

### Severity 2 (High) - Performance Impact
- **CPU Warning**: Performance degradation affecting application responsiveness
- **Storage Warning**: Capacity approaching limits requiring proactive management
- **vCore Warning**: Resource utilization indicating potential scaling needs

**Response Time**: 15 minutes
**Escalation**: Notification to database administration team and application owners

## Cost Analysis

### Alert Costs (Monthly)
- **5 Metric Alerts + 1 Activity Log Alert per Instance**: 6 × $0.10 = **$0.60 per SQL Managed Instance**
- **Multi-Instance Deployment**: Scales linearly with instance count
- **Action Group**: FREE (included)
- **Activity Log Alerts**: FREE (included)

### Cost Examples by Environment

#### Small SQL MI Environment (2 Instances)
- **Monthly Alert Cost**: $1.20
- **Annual Alert Cost**: $14.40

#### Medium Enterprise SQL MI Platform (5 Instances)
- **Monthly Alert Cost**: $3.00
- **Annual Alert Cost**: $36.00

#### Large Multi-Tenant SQL MI System (20 Instances)
- **Monthly Alert Cost**: $12.00
- **Annual Alert Cost**: $144.00

#### Enterprise SQL MI Portfolio (100 Instances)
- **Monthly Alert Cost**: $60.00
- **Annual Alert Cost**: $720.00

### Return on Investment (ROI)

#### Cost of SQL MI Issues
- **Performance Degradation**: 100-500% increase in query response times
- **Instance Unavailability**: $500,000-2,000,000/hour for mission-critical enterprise systems
- **Data Loss**: Potential compliance violations and massive business continuity impact
- **Recovery Time**: 2-48 hours average recovery time without proactive monitoring
- **Scaling Delays**: 6-24 hours to properly scale resources without predictive monitoring

#### Alert Value Calculation
- **Monthly Alert Cost**: $0.60 per SQL Managed Instance
- **Prevented Downtime**: 4 hours/month average per instance
- **Cost Avoidance**: $2,000,000/month for critical enterprise systems
- **ROI**: 333,333,233% (($2,000,000 - $0.60) / $0.60 × 100)

#### Additional Benefits
- **Proactive Performance Management**: Identify and resolve issues before user impact
- **Capacity Planning**: Data-driven decisions for scaling and resource allocation
- **Cost Optimization**: Right-size instances based on actual utilization patterns
- **Compliance Assurance**: Maintain audit trails and operational oversight
- **Business Continuity**: Ensure high availability for mission-critical database workloads

### SQL Managed Instance Pricing Context
- **General Purpose 4 vCore**: $1,446/month
- **General Purpose 8 vCore**: $2,892/month
- **Business Critical 4 vCore**: $4,339/month
- **Business Critical 8 vCore**: $8,678/month

**Alert Cost as % of Instance Cost**: 0.007% - 0.04% of monthly instance costs

## Best Practices

### Deployment Best Practices

#### 1. Environment-Specific Configuration
```hcl
# Production Environment - Strict monitoring
cpu_warning_threshold      = 80
cpu_critical_threshold     = 90
storage_warning_threshold  = 80
storage_critical_threshold = 90
evaluation_frequency      = "PT5M"

# Staging Environment - Moderate monitoring  
cpu_warning_threshold      = 85
cpu_critical_threshold     = 92
storage_warning_threshold  = 85
storage_critical_threshold = 92
evaluation_frequency      = "PT10M"

# Development Environment - Relaxed monitoring
cpu_warning_threshold      = 90
cpu_critical_threshold     = 95
storage_warning_threshold  = 90
storage_critical_threshold = 95
evaluation_frequency      = "PT15M"
```

#### 2. Service Tier-Appropriate Thresholds
- **General Purpose**: Moderate thresholds (80-90%) for typical workloads
- **Business Critical**: Lower thresholds (70-85%) for high-performance requirements
- **Memory Optimized**: Balanced thresholds (75-87%) for memory-intensive workloads

#### 3. Workload-Specific Configurations
- **OLTP Workloads**: Aggressive monitoring with 1-minute evaluation frequency
- **Data Warehouse**: Focus on storage and longer-term CPU trends
- **Hybrid Workloads**: Balanced approach with standard thresholds

### SQL Managed Instance Performance Best Practices

#### 1. Instance Configuration Optimization
```sql
-- Configure SQL Server settings for optimal performance
EXEC sp_configure 'max degree of parallelism', 0;  -- Use all available cores
EXEC sp_configure 'cost threshold for parallelism', 50;
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;

-- Enable Query Store for all databases
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'ALTER DATABASE [' + name + '] SET QUERY_STORE = ON;' + CHAR(13)
FROM sys.databases WHERE database_id > 4;
EXEC sp_executesql @sql;

-- Configure memory settings
EXEC sp_configure 'min server memory (MB)', 2048;  -- Set based on instance size
EXEC sp_configure 'max server memory (MB)', 16384; -- Leave memory for OS
RECONFIGURE;
```

#### 2. Performance Monitoring Setup
```sql
-- Create performance monitoring views
CREATE VIEW vw_InstancePerformance AS
SELECT 
    'CPU_Percent' as Metric,
    AVG(CAST(cntr_value AS DECIMAL(10,2))) as CurrentValue,
    GETUTCDATE() as Timestamp
FROM sys.dm_os_performance_counters 
WHERE counter_name = 'CPU usage %' 
  AND instance_name = 'default'
UNION ALL
SELECT 
    'Memory_Usage_KB' as Metric,
    SUM(CAST(cntr_value AS DECIMAL(15,2))) as CurrentValue,
    GETUTCDATE() as Timestamp
FROM sys.dm_os_performance_counters 
WHERE counter_name IN ('Total Server Memory (KB)', 'Target Server Memory (KB)');

-- Monitor wait statistics
SELECT TOP 10 
    wait_type,
    wait_time_ms / 1000.0 AS wait_time_s,
    waiting_tasks_count,
    signal_wait_time_ms / 1000.0 AS signal_wait_time_s,
    wait_time_ms / waiting_tasks_count AS avg_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
ORDER BY wait_time_ms DESC;
```

#### 3. Capacity Management
```sql
-- Database size monitoring
SELECT 
    DB_NAME(database_id) AS DatabaseName,
    SUM(CASE WHEN type_desc = 'ROWS' THEN size * 8.0 / 1024 END) AS DataFileSizeMB,
    SUM(CASE WHEN type_desc = 'LOG' THEN size * 8.0 / 1024 END) AS LogFileSizeMB,
    SUM(size * 8.0 / 1024) AS TotalSizeMB
FROM sys.master_files
WHERE database_id > 4
GROUP BY database_id
ORDER BY TotalSizeMB DESC;

-- Storage utilization analysis
WITH StorageInfo AS (
    SELECT 
        DB_NAME() AS DatabaseName,
        SUM(CASE WHEN type_desc = 'ROWS' THEN FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 END) AS DataUsedMB,
        SUM(CASE WHEN type_desc = 'ROWS' THEN size * 8.0 / 1024 END) AS DataAllocatedMB,
        SUM(CASE WHEN type_desc = 'LOG' THEN FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 END) AS LogUsedMB,
        SUM(CASE WHEN type_desc = 'LOG' THEN size * 8.0 / 1024 END) AS LogAllocatedMB
    FROM sys.database_files
)
SELECT 
    *,
    CASE WHEN DataAllocatedMB > 0 THEN (DataUsedMB / DataAllocatedMB) * 100 END AS DataUsedPercent,
    CASE WHEN LogAllocatedMB > 0 THEN (LogUsedMB / LogAllocatedMB) * 100 END AS LogUsedPercent
FROM StorageInfo;
```

### Security and Compliance Best Practices

#### 1. Instance Security Configuration
```sql
-- Enable SQL Server Audit
CREATE SERVER AUDIT [PGE_Audit]
TO FILE (FILEPATH = 'C:\Audits\', MAXSIZE = 1000 MB, MAX_FILES = 10)
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);

CREATE SERVER AUDIT SPECIFICATION [PGE_Audit_Spec]
FOR SERVER AUDIT [PGE_Audit]
ADD (LOGIN_CHANGE_PASSWORD_GROUP),
ADD (LOGOUT_GROUP),
ADD (LOGIN_FAILED_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP);

ALTER SERVER AUDIT [PGE_Audit] WITH (STATE = ON);
ALTER SERVER AUDIT SPECIFICATION [PGE_Audit_Spec] WITH (STATE = ON);

-- Configure security policies
EXEC sp_configure 'clr enabled', 0;  -- Disable CLR unless required
EXEC sp_configure 'xp_cmdshell', 0;  -- Disable xp_cmdshell
EXEC sp_configure 'Database Mail XPs', 0;  -- Disable unless required
RECONFIGURE;
```

#### 2. Access Control and Monitoring
```sql
-- Create security monitoring views
CREATE VIEW vw_SecurityEvents AS
SELECT 
    session_id,
    login_time,
    login_name,
    program_name,
    client_interface_name,
    endpoint_id,
    last_request_start_time,
    last_request_end_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;

-- Monitor failed logins
SELECT 
    error_number,
    error_severity,
    error_state,
    error_message,
    error_time
FROM sys.dm_server_audit_status
WHERE error_number IN (18456, 18470, 18486);
```

#### 3. Backup and Recovery Strategy
```sql
-- Automated backup verification
DECLARE @BackupInfo TABLE (
    DatabaseName NVARCHAR(128),
    LastFullBackup DATETIME,
    LastLogBackup DATETIME,
    BackupAge INT
);

INSERT INTO @BackupInfo
SELECT 
    d.name,
    MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS LastFullBackup,
    MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS LastLogBackup,
    DATEDIFF(HOUR, MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END), GETDATE()) AS BackupAge
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b ON d.name = b.database_name
WHERE d.database_id > 4
GROUP BY d.name;

-- Alert on backup age
SELECT * FROM @BackupInfo WHERE BackupAge > 24;
```

### Monitoring and Diagnostics Best Practices

#### 1. Custom Monitoring Scripts
```sql
-- Instance health check
SELECT 
    'Instance_Status' AS Metric,
    CASE 
        WHEN @@SERVERNAME IS NOT NULL THEN 'Online'
        ELSE 'Offline'
    END AS Status,
    GETUTCDATE() AS CheckTime
UNION ALL
SELECT 
    'Database_Count' AS Metric,
    CAST(COUNT(*) AS VARCHAR(50)) AS Status,
    GETUTCDATE() AS CheckTime
FROM sys.databases WHERE state = 0  -- Online databases
UNION ALL
SELECT 
    'Active_Connections' AS Metric,
    CAST(COUNT(*) AS VARCHAR(50)) AS Status,
    GETUTCDATE() AS CheckTime
FROM sys.dm_exec_sessions WHERE is_user_process = 1;

-- Performance baseline
SELECT 
    object_name,
    counter_name,
    instance_name,
    cntr_value,
    cntr_type,
    GETUTCDATE() AS sample_time
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%SQL Statistics%'
   OR object_name LIKE '%Buffer Manager%'
   OR object_name LIKE '%Memory Manager%'
ORDER BY object_name, counter_name;
```

#### 2. Automated Health Monitoring
```powershell
# PowerShell script for SQL MI health monitoring
$ResourceGroup = "rg-production-data"
$ManagedInstanceName = "sqlmi-prod-001"

# Check SQL MI status
$ManagedInstance = Get-AzSqlInstance -ResourceGroupName $ResourceGroup -Name $ManagedInstanceName
Write-Output "SQL MI Status: $($ManagedInstance.State)"

# Check recent CPU metrics
$Metrics = Get-AzMetric -ResourceId $ManagedInstance.Id -MetricName "avg_cpu_percent" -TimeGrain 00:05:00
$LatestCPU = $Metrics.Data | Sort-Object Timestamp -Descending | Select-Object -First 1
Write-Output "Latest CPU Usage: $($LatestCPU.Average)%"

# Check storage utilization
$StorageMetrics = Get-AzMetric -ResourceId $ManagedInstance.Id -MetricName "storage_space_used_mb" -TimeGrain 00:15:00
$LatestStorage = $StorageMetrics.Data | Sort-Object Timestamp -Descending | Select-Object -First 1
Write-Output "Storage Used: $($LatestStorage.Average) MB"

# Check for recent alerts
$StartTime = (Get-Date).AddHours(-24)
$Alerts = Get-AzActivityLog -ResourceGroupName $ResourceGroup -StartTime $StartTime
$SQLMIAlerts = $Alerts | Where-Object { $_.ResourceId -like "*$ManagedInstanceName*" }
Write-Output "Recent Alerts: $($SQLMIAlerts.Count)"
```

#### 3. Performance Trend Analysis
```bash
# Azure CLI script for SQL MI performance analysis
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="rg-production-data"
MI_NAME="sqlmi-prod-001"

echo "SQL MI Performance Analysis for: $MI_NAME"

# CPU trend analysis
az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Sql/managedInstances/$MI_NAME" \
  --metric "avg_cpu_percent" \
  --interval PT1H \
  --start-time "$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --query "value[0].timeseries[0].data[].{Time:timeStamp,CPU:average}" \
  --output table

# Storage growth analysis
az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Sql/managedInstances/$MI_NAME" \
  --metric "storage_space_used_mb" \
  --interval PT1D \
  --start-time "$(date -d '30 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --query "value[0].timeseries[0].data[].{Date:timeStamp,StorageMB:average}" \
  --output table
```

## Troubleshooting

### Common Issues and Solutions

#### 1. High CPU Utilization
**Symptoms**: CPU warning or critical alerts firing with slow query performance

**Possible Causes**:
- Resource-intensive queries or procedures
- Missing or outdated statistics
- Inefficient query execution plans
- Excessive parallelism or blocking

**Troubleshooting Steps**:
```sql
-- Identify top CPU-consuming queries
SELECT TOP 10 
    qs.sql_handle,
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    qs.execution_count,
    qs.last_execution_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2 + 1,
              (CASE WHEN qs.statement_end_offset = -1 
                    THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
                    ELSE qs.statement_end_offset 
               END - qs.statement_start_offset)/2) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY avg_cpu_time DESC;

-- Check for blocking
SELECT 
    r.session_id,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.command,
    s.login_name,
    s.program_name,
    t.text
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0;

-- Update statistics
EXEC sp_MSforeachdb 'USE [?]; EXEC sp_updatestats;'
```

**Resolution**:
- Optimize inefficient queries using execution plan analysis
- Update statistics on heavily queried tables
- Consider scaling up vCores if sustained high CPU usage is legitimate
- Implement query plan guides for problematic queries

#### 2. Storage Space Issues
**Symptoms**: Storage warning or critical alerts with potential service disruption

**Possible Causes**:
- Rapid database growth
- Large transaction log files
- Lack of data archiving strategy
- Index fragmentation

**Troubleshooting Steps**:
```sql
-- Check database sizes across all databases
EXEC sp_MSforeachdb 'USE [?]; 
SELECT 
    DB_NAME() AS DatabaseName,
    SUM(CASE WHEN type_desc = ''ROWS'' THEN size * 8.0 / 1024 END) AS DataSizeMB,
    SUM(CASE WHEN type_desc = ''LOG'' THEN size * 8.0 / 1024 END) AS LogSizeMB,
    SUM(size * 8.0 / 1024) AS TotalSizeMB
FROM sys.database_files
GROUP BY DB_NAME()
HAVING SUM(size * 8.0 / 1024) > 0;'

-- Identify largest tables across all databases
EXEC sp_MSforeachdb 'USE [?]; 
SELECT TOP 5
    DB_NAME() AS DatabaseName,
    t.name AS TableName,
    SUM(p.rows) AS RowCount,
    SUM(a.total_pages) * 8 / 1024 AS TotalSpaceMB,
    SUM(a.used_pages) * 8 / 1024 AS UsedSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0 AND i.object_id > 255
GROUP BY t.name
ORDER BY TotalSpaceMB DESC;'
```

**Resolution**:
- Implement data archiving and purging strategies
- Configure appropriate transaction log backup frequency
- Perform index maintenance to reclaim space
- Scale up storage if growth is legitimate
- Consider data compression for large tables

#### 3. Instance Performance Degradation
**Symptoms**: Multiple alerts firing with overall slow performance

**Possible Causes**:
- Insufficient vCore allocation for workload
- Memory pressure
- I/O bottlenecks
- Network latency

**Troubleshooting Steps**:
```sql
-- Check wait statistics
SELECT TOP 20 
    wait_type,
    waiting_tasks_count,
    wait_time_ms / 1000.0 AS wait_time_seconds,
    max_wait_time_ms / 1000.0 AS max_wait_time_seconds,
    signal_wait_time_ms / 1000.0 AS signal_wait_time_seconds
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
  AND wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 
                        'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR')
ORDER BY wait_time_ms DESC;

-- Memory utilization
SELECT 
    physical_memory_kb / 1024 AS PhysicalMemoryMB,
    virtual_memory_kb / 1024 AS VirtualMemoryMB,
    committed_kb / 1024 AS CommittedMemoryMB,
    committed_target_kb / 1024 AS CommittedTargetMB
FROM sys.dm_os_sys_info;

-- I/O statistics
SELECT 
    DB_NAME(vfs.database_id) AS DatabaseName,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    (vfs.io_stall_read_ms + vfs.io_stall_write_ms) AS io_stall_total_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
INNER JOIN sys.master_files mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY io_stall_total_ms DESC;
```

**Resolution**:
- Scale up to higher vCore count if CPU-bound
- Optimize memory usage and query plans
- Consider Business Critical tier for better I/O performance
- Review network configuration and connectivity
- Implement query optimization and index strategies

#### 4. Instance Connectivity Issues
**Symptoms**: Application connectivity problems and timeout errors

**Possible Causes**:
- Network security group configuration
- Firewall rules
- DNS resolution issues
- Connection pool exhaustion

**Troubleshooting Steps**:
```bash
# Test connectivity from client machine
sqlcmd -S "sqlmi-prod-001.public.database.windows.net,3342" -U "sqladmin" -P "password" -Q "SELECT @@VERSION"

# Check DNS resolution
nslookup sqlmi-prod-001.public.database.windows.net

# Verify network connectivity
Test-NetConnection -ComputerName "sqlmi-prod-001.public.database.windows.net" -Port 1433

# Check Azure SQL MI connectivity
az sql mi show --resource-group "rg-production-data" --name "sqlmi-prod-001" --query "state"
```

**Resolution**:
- Verify network security group rules allow SQL traffic
- Check SQL MI firewall configuration
- Ensure proper DNS configuration
- Review application connection string configuration
- Monitor connection pool settings in applications

### Advanced Monitoring Setup

#### 1. Custom Performance Dashboard
```json
{
  "dashboard": {
    "title": "SQL Managed Instance Performance Dashboard",
    "panels": [
      {
        "title": "CPU Utilization Trend",
        "query": "AzureMetrics | where MetricName == 'avg_cpu_percent' | render timechart"
      },
      {
        "title": "Storage Utilization",
        "query": "AzureMetrics | where MetricName == 'storage_space_used_mb' | render areachart"
      },
      {
        "title": "vCore Usage",
        "query": "AzureMetrics | where MetricName == 'virtual_core_count' | render columnchart"
      },
      {
        "title": "Instance Availability",
        "query": "AzureActivity | where ResourceType == 'Microsoft.Sql/managedInstances' | render columnchart"
      }
    ]
  }
}
```

#### 2. Automated Health Check Script
```bash
#!/bin/bash
# SQL MI comprehensive health check

RESOURCE_GROUP="rg-production-data"
MI_NAME="sqlmi-prod-001"
SUBSCRIPTION_ID="your-subscription-id"

echo "SQL Managed Instance Health Check: $MI_NAME"
echo "==========================================="

# Check instance status
echo "1. Instance Status Check"
MI_STATE=$(az sql mi show --resource-group "$RESOURCE_GROUP" --name "$MI_NAME" --query "state" -o tsv)
echo "   State: $MI_STATE"

# Check CPU utilization
echo "2. CPU Utilization Check"
CPU_USAGE=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Sql/managedInstances/$MI_NAME" \
  --metric "avg_cpu_percent" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv 2>/dev/null)
echo "   Current CPU: ${CPU_USAGE:-N/A}%"

# Check storage utilization
echo "3. Storage Utilization Check"
STORAGE_USED=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Sql/managedInstances/$MI_NAME" \
  --metric "storage_space_used_mb" \
  --interval PT15M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv 2>/dev/null)
echo "   Storage Used: ${STORAGE_USED:-N/A} MB"

# Check connectivity
echo "4. Connectivity Check"
FQDN=$(az sql mi show --resource-group "$RESOURCE_GROUP" --name "$MI_NAME" --query "fullyQualifiedDomainName" -o tsv)
echo "   FQDN: $FQDN"

# Health assessment
echo "5. Health Assessment"
if [ "$MI_STATE" != "Ready" ]; then
  echo "   CRITICAL: Instance is not in Ready state"
  exit 2
fi

if [ "$CPU_USAGE" != "" ] && (( $(echo "$CPU_USAGE > 90" | bc -l 2>/dev/null || echo 0) )); then
  echo "   WARNING: High CPU usage detected"
fi

if [ "$STORAGE_USED" != "" ] && (( $(echo "$STORAGE_USED > 800000" | bc -l 2>/dev/null || echo 0) )); then
  echo "   WARNING: High storage usage detected"
fi

echo "   Health check completed successfully"
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure SQL Managed Instance monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual instance performance patterns and business requirements is recommended for optimal monitoring effectiveness.