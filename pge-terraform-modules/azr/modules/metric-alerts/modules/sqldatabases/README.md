# Azure SQL Databases - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure SQL Databases**, providing proactive monitoring for database performance, capacity, availability, and operational health. The module monitors critical database metrics to ensure optimal query performance, resource utilization, and data integrity.

Azure SQL Database is a fully managed Platform-as-a-Service (PaaS) database engine that provides automatic scaling, built-in high availability, and intelligent performance optimization. This module focuses on database-specific metrics including CPU utilization, storage consumption, connection health, and query performance indicators.

## Features

- **Performance Monitoring**: CPU utilization, data reads, log writes, and query execution tracking
- **Capacity Management**: Storage percentage, storage bytes, and In-Memory OLTP monitoring
- **Connection Health**: Failed connections, successful connection volume, and session management
- **Database Operations**: Deadlock detection, worker threads, and SQL Server process monitoring
- **Resource Utilization**: TempDB usage, XTP storage, and system resource consumption
- **Activity Monitoring**: Administrative operations, configuration changes, and deletion tracking
- **Multi-Database Support**: Individual monitoring for each database with server/database naming
- **Real-Time Alerting**: 1-15 minute evaluation frequency for critical database metrics
- **Cost-Effective Monitoring**: Metric alerts at $0.10 per month per alert rule
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **Query Performance**: CPU and I/O monitoring for query optimization
- **Capacity Planning**: Storage and resource utilization for growth planning
- **Connection Management**: Connection failure detection and load monitoring
- **Database Health**: Deadlock detection and resource contention monitoring
- **System Performance**: TempDB, worker threads, and SQL Server process monitoring
- **Administrative Oversight**: Configuration changes and deletion protection

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Sql/servers/databases/read`
- **Action Group**: Pre-configured action group for alert notifications
- **SQL Databases**: Existing Azure SQL Databases to monitor

## Usage

### Basic Configuration

```hcl
module "sql_databases_alerts" {
  source = "./modules/metricAlerts/sqldatabases"
  
  # Resource Configuration
  resource_group_name               = "rg-production-data"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # SQL Databases to Monitor (format: server-name/database-name)
  sql_database_names = [
    "sql-prod-001/app-production",
    "sql-prod-001/app-reporting",
    "sql-prod-002/user-management"
  ]
  
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
module "sql_databases_alerts_high_performance" {
  source = "./modules/metricAlerts/sqldatabases"
  
  # Resource Configuration
  resource_group_name               = "rg-production-data"
  action_group_resource_group_name  = "rg-monitoring"
  sql_database_names               = ["sql-prod-critical/mission-critical-db"]
  
  # High-Performance Database Thresholds
  cpu_percent_threshold                    = 70    # Lower CPU tolerance for critical systems
  physical_data_read_percent_threshold     = 60    # Aggressive I/O monitoring
  log_write_percent_threshold             = 70    # Transaction log monitoring
  
  # Capacity Thresholds (Large Database)
  storage_percent_threshold               = 85    # Earlier storage warning
  storage_used_bytes_threshold           = 5497558138880  # 5TB threshold
  
  # Resource Monitoring (High-Concurrency Environment)
  sessions_percent_threshold              = 70    # Lower session threshold
  workers_percent_threshold              = 70    # Worker thread monitoring
  sqlserver_process_core_percent_threshold = 70    # SQL process monitoring
  
  # Connection and Health (Zero-Tolerance)
  connection_failed_threshold             = 1     # Immediate connection failure alert
  deadlock_threshold                     = 1     # Any deadlock triggers alert
  
  # Specialized Features
  tempdb_log_used_percent_threshold      = 70    # TempDB monitoring
  xtp_storage_percent_threshold          = 80    # In-Memory OLTP monitoring
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    SLA         = "99.9%"
    Owner       = "dba-team@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Databases - Relaxed Thresholds
cpu_percent_threshold                = 90
storage_percent_threshold            = 95
connection_failed_threshold          = 20
deadlock_threshold                  = 10
sessions_percent_threshold           = 90
```

#### Staging Environment
```hcl
# Staging Databases - Moderate Thresholds
cpu_percent_threshold                = 85
storage_percent_threshold            = 90
connection_failed_threshold          = 10
deadlock_threshold                  = 5
sessions_percent_threshold           = 85
```

#### Production Environment
```hcl
# Production Databases - Strict Thresholds
cpu_percent_threshold                = 80
storage_percent_threshold            = 90
connection_failed_threshold          = 5
deadlock_threshold                  = 1
sessions_percent_threshold           = 80
```

### Database Tier-Specific Configurations

#### Basic/S0-S2 Databases
```hcl
# Basic/Standard Lower Tiers - Resource-Constrained
cpu_percent_threshold                = 85
sessions_percent_threshold           = 85
workers_percent_threshold           = 85
storage_used_bytes_threshold        = 10737418240  # 10GB
```

#### Standard/S3+ Databases
```hcl
# Standard Higher Tiers - Moderate Performance
cpu_percent_threshold                = 80
sessions_percent_threshold           = 80
workers_percent_threshold           = 80
storage_used_bytes_threshold        = 107374182400  # 100GB
```

#### Premium/P1+ Databases
```hcl
# Premium Tiers - High Performance
cpu_percent_threshold                = 75
sessions_percent_threshold           = 75
workers_percent_threshold           = 75
storage_used_bytes_threshold        = 1073741824000  # 1TB
```

### Use Case-Specific Configurations

#### OLTP (Transaction Processing) Databases
```hcl
# OLTP - Optimized for transaction processing
cpu_percent_threshold                = 75
log_write_percent_threshold         = 70
deadlock_threshold                  = 1
sessions_percent_threshold          = 70
tempdb_log_used_percent_threshold   = 75
```

#### Data Warehouse/OLAP Databases
```hcl
# Data Warehouse - Optimized for analytics
cpu_percent_threshold                = 90
physical_data_read_percent_threshold = 90
storage_percent_threshold           = 85
workers_percent_threshold          = 90
```

#### In-Memory OLTP Databases
```hcl
# In-Memory OLTP - Specialized for memory-optimized tables
cpu_percent_threshold                = 70
xtp_storage_percent_threshold       = 80
sqlserver_process_core_percent_threshold = 70
tempdb_log_used_percent_threshold   = 70
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for SQL databases |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
| `sql_database_names` | `list(string)` | `[]` | List of database names (server-name/database-name format) |

### Performance Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `cpu_percent_threshold` | `number` | `80` | CPU utilization percentage | 70-90% |
| `physical_data_read_percent_threshold` | `number` | `80` | Data read I/O percentage | 60-90% |
| `log_write_percent_threshold` | `number` | `80` | Transaction log write percentage | 70-90% |
| `sessions_percent_threshold` | `number` | `80` | Session utilization percentage | 70-90% |
| `workers_percent_threshold` | `number` | `80` | Worker thread percentage | 70-90% |
| `sqlserver_process_core_percent_threshold` | `number` | `80` | SQL Server process CPU percentage | 70-90% |
| `tempdb_log_used_percent_threshold` | `number` | `80` | TempDB log utilization percentage | 70-90% |

### Storage Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `storage_percent_threshold` | `number` | `90` | Storage utilization percentage | 80-95% |
| `storage_used_bytes_threshold` | `number` | `107374182400` | Storage used in bytes (100GB) | 10GB-5TB |
| `xtp_storage_percent_threshold` | `number` | `90` | In-Memory OLTP storage percentage | 80-95% |

### Connection and Health Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `connection_successful_threshold` | `number` | `10` | Minimum successful connections | 5-100 |
| `connection_failed_threshold` | `number` | `5` | Failed connections per minute | 1-50 |
| `deadlock_threshold` | `number` | `1` | Deadlocks per minute | 1-10 |

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
  BackupPolicy       = "Daily"                      # Backup requirements
}
```

## Alert Details

### 1. CPU Utilization Alert
- **Alert Name**: `sql-db-cpu-percent-{server-database}`
- **Metric**: `cpu_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: CPU utilization of the SQL Database instance, indicating query processing load and computational demands.

**What to do when this alert fires**:
1. **Query Analysis**: Identify resource-intensive queries using Query Performance Insight
2. **Index Optimization**: Review and optimize indexes for frequently executed queries
3. **Query Tuning**: Analyze execution plans and optimize slow-running queries
4. **Scaling Assessment**: Consider scaling up the database tier for more CPU resources
5. **Workload Distribution**: Evaluate read replica implementation for read-heavy workloads

### 2. Storage Utilization Alert
- **Alert Name**: `sql-db-storage-percent-{server-database}`
- **Metric**: `storage_percent`
- **Threshold**: 90% (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT1H (1 hour)
- **Aggregation**: Average

**What this alert monitors**: Percentage of allocated storage space being used by the database, critical for preventing out-of-space conditions.

**What to do when this alert fires**:
1. **Immediate Action**: Review storage consumption patterns and identify large objects
2. **Data Cleanup**: Implement data archiving and purging for old or unnecessary data
3. **Index Maintenance**: Rebuild fragmented indexes and remove unused indexes
4. **Storage Scaling**: Increase database storage limits or scale to higher tier
5. **Compression**: Implement data and backup compression to reduce storage footprint

### 3. Storage Used Bytes Alert
- **Alert Name**: `sql-db-storage-used-bytes-{server-database}`
- **Metric**: `storage`
- **Threshold**: 100GB (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT1H (1 hour)
- **Aggregation**: Maximum

**What this alert monitors**: Absolute storage consumption in bytes, providing early warning before percentage-based limits are reached.

**What to do when this alert fires**:
1. **Growth Analysis**: Analyze storage growth trends and project future requirements
2. **Capacity Planning**: Plan storage upgrades based on growth patterns
3. **Data Lifecycle Management**: Implement retention policies and data archiving strategies
4. **Storage Optimization**: Review table and index storage allocation
5. **Backup Strategy**: Ensure backup storage doesn't impact operational storage

### 4. Connection Failed Alert
- **Alert Name**: `sql-db-connection-failed-{server-database}`
- **Metric**: `connection_failed`
- **Threshold**: 5 failures/minute (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Total

**What this alert monitors**: Failed database connection attempts, indicating authentication issues, network problems, or database unavailability.

**What to do when this alert fires**:
1. **Connection Analysis**: Review connection strings and authentication configurations
2. **Network Diagnostics**: Check network connectivity and firewall rules
3. **Database Health**: Verify database availability and resource constraints
4. **Authentication Review**: Check SQL logins, Azure AD authentication, and permissions
5. **Connection Pooling**: Review application connection pooling configuration

### 5. High Successful Connections Alert
- **Alert Name**: `sql-db-connection-successful-high-{server-database}`
- **Metric**: `connection_successful`
- **Threshold**: 10 connections/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Unusually high number of successful connections, potentially indicating connection churn or scaling needs.

**What to do when this alert fires**:
1. **Connection Pattern Analysis**: Review application connection patterns and lifecycle
2. **Connection Pooling**: Optimize connection pooling in application configurations
3. **Load Assessment**: Evaluate if high connections indicate increased application load
4. **Performance Impact**: Monitor query performance during high connection periods
5. **Scaling Consideration**: Assess need for database tier upgrade or read replicas

### 6. Deadlock Alert
- **Alert Name**: `sql-db-deadlock-{server-database}`
- **Metric**: `deadlock`
- **Threshold**: 1 deadlock/minute (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Total

**What this alert monitors**: Database deadlocks occurring when two or more processes block each other, indicating design or query optimization issues.

**What to do when this alert fires**:
1. **Deadlock Analysis**: Review deadlock graphs and identify involved queries/tables
2. **Query Optimization**: Optimize query order and transaction scope to reduce deadlock potential
3. **Index Strategy**: Implement appropriate indexes to reduce lock duration
4. **Application Design**: Review application transaction patterns and implement retry logic
5. **Lock Escalation**: Configure appropriate lock escalation thresholds

### 7. Log Write Percent Alert
- **Alert Name**: `sql-db-log-write-percent-{server-database}`
- **Metric**: `log_write_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Transaction log write activity as a percentage of available log I/O bandwidth, indicating transaction processing intensity.

**What to do when this alert fires**:
1. **Transaction Analysis**: Identify large or long-running transactions affecting log writes
2. **Batch Processing**: Optimize batch operations to reduce transaction log pressure
3. **Log Management**: Review transaction log backup frequency and retention
4. **Query Optimization**: Optimize INSERT, UPDATE, DELETE operations for efficiency
5. **Tier Assessment**: Consider scaling to higher performance tier with better I/O

### 8. Physical Data Read Percent Alert
- **Alert Name**: `sql-db-physical-data-read-percent-{server-database}`
- **Metric**: `physical_data_read_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Physical data read I/O as a percentage of available read bandwidth, indicating query and storage access patterns.

**What to do when this alert fires**:
1. **Query Performance**: Identify queries causing excessive data reads
2. **Index Optimization**: Create or optimize indexes to reduce data scan operations
3. **Buffer Pool**: Monitor buffer pool hit ratio and memory utilization
4. **Storage Performance**: Consider premium storage or higher performance tiers
5. **Partitioning**: Implement table partitioning for large tables to improve I/O efficiency

### 9. Workers Percent Alert
- **Alert Name**: `sql-db-workers-percent-{server-database}`
- **Metric**: `workers_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Percentage of worker threads in use, indicating concurrent request processing load and potential threading bottlenecks.

**What to do when this alert fires**:
1. **Concurrency Analysis**: Review concurrent connection and query patterns
2. **Query Optimization**: Optimize long-running queries to free up worker threads
3. **Connection Management**: Implement connection pooling to reduce thread usage
4. **Blocking Analysis**: Identify and resolve blocking queries
5. **Scaling Strategy**: Consider database tier upgrade for more worker thread capacity

### 10. Sessions Percent Alert
- **Alert Name**: `sql-db-sessions-percent-{server-database}`
- **Metric**: `sessions_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Percentage of available database sessions in use, indicating connection and concurrent user load.

**What to do when this alert fires**:
1. **Session Management**: Review active sessions and identify idle or long-running sessions
2. **Connection Pooling**: Optimize application connection pooling configuration
3. **Session Cleanup**: Implement session timeout and cleanup procedures
4. **Load Distribution**: Consider read replicas to distribute session load
5. **Tier Upgrade**: Evaluate database tier upgrade for higher session limits

### 11. SQL Server Process Core Percent Alert
- **Alert Name**: `sql-db-sqlserver-process-core-percent-{server-database}`
- **Metric**: `sqlserver_process_core_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: CPU usage specifically by the SQL Server process, providing more granular CPU monitoring than general CPU metrics.

**What to do when this alert fires**:
1. **Process Analysis**: Analyze SQL Server-specific CPU consumption patterns
2. **Query Optimization**: Focus on CPU-intensive query optimization
3. **System Resource Review**: Check for other processes competing for CPU resources
4. **Performance Tuning**: Implement SQL Server performance tuning best practices
5. **Hardware Assessment**: Consider CPU upgrade or higher performance tier

### 12. TempDB Log Used Percent Alert
- **Alert Name**: `sql-db-tempdb-log-used-percent-{server-database}`
- **Metric**: `tempdb_log_used_percent`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Maximum

**What this alert monitors**: TempDB transaction log utilization, critical for temporary object operations and query processing.

**What to do when this alert fires**:
1. **TempDB Usage Analysis**: Identify queries or operations consuming TempDB space
2. **Query Optimization**: Optimize queries using temporary tables, table variables, or CTEs
3. **Indexing Strategy**: Review and optimize indexes to reduce TempDB spill operations
4. **Sort Operations**: Optimize ORDER BY and GROUP BY operations
5. **Memory Configuration**: Increase memory allocation to reduce TempDB spill

### 13. XTP Storage Percent Alert
- **Alert Name**: `sql-db-xtp-storage-percent-{server-database}`
- **Metric**: `xtp_storage_percent`
- **Threshold**: 90% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: In-Memory OLTP (XTP) storage utilization for memory-optimized tables and indexes.

**What to do when this alert fires**:
1. **Memory-Optimized Objects**: Review size and usage of memory-optimized tables
2. **Data Cleanup**: Implement retention policies for memory-optimized table data
3. **Index Optimization**: Optimize indexes on memory-optimized tables
4. **Memory Allocation**: Increase In-Memory OLTP memory allocation
5. **Architecture Review**: Evaluate memory-optimized table design and usage patterns

### 14. Database Deletion Activity Alert
- **Alert Name**: `sql-database-delete`
- **Operation**: `Microsoft.Sql/servers/databases/delete`
- **Severity**: Critical (Activity Log)
- **Frequency**: Immediate
- **Scope**: All monitored databases

**What this alert monitors**: Administrative deletion of SQL databases, providing audit trail and protection against accidental deletion.

**What to do when this alert fires**:
1. **Immediate Verification**: Confirm if deletion was authorized and intentional
2. **Backup Check**: Verify recent backups are available if restoration is needed
3. **Impact Assessment**: Evaluate impact on dependent applications and systems
4. **Recovery Planning**: Initiate database restoration procedures if deletion was unauthorized
5. **Access Review**: Review who had deletion permissions and audit access controls

### 15. Database Configuration Change Activity Alert
- **Alert Name**: `sql-database-config-change`
- **Operation**: `Microsoft.Sql/servers/databases/write`
- **Severity**: Medium (Activity Log)
- **Frequency**: Immediate
- **Scope**: All monitored databases

**What this alert monitors**: Administrative changes to database configuration, including tier changes, performance settings, and security configurations.

**What to do when this alert fires**:
1. **Change Validation**: Review and validate the configuration changes made
2. **Performance Impact**: Monitor database performance after configuration changes
3. **Change Documentation**: Ensure changes are properly documented and approved
4. **Rollback Planning**: Prepare rollback procedures if changes cause issues
5. **Compliance Check**: Verify changes comply with organizational policies and standards

## Severity Levels

### Severity 1 (Critical) - Service Impact
- **Storage Utilization**: Risk of database becoming unavailable due to storage exhaustion
- **Connection Failures**: Database connectivity issues affecting application availability
- **Deadlocks**: Database concurrency issues affecting transaction processing

**Response Time**: 5 minutes
**Escalation**: Immediate notification to DBA team and on-call engineer

### Severity 2 (High) - Performance Impact
- **CPU Utilization**: Performance degradation affecting query response times
- **I/O Performance**: Data read/write performance impacting application responsiveness
- **Resource Consumption**: Worker threads, sessions, and system resources nearing limits
- **Storage Capacity**: Storage usage approaching critical thresholds

**Response Time**: 15 minutes
**Escalation**: Notification to database administration team

### Severity 3 (Medium) - Capacity Monitoring
- **High Connection Volume**: Connection patterns indicating scaling or optimization needs

**Response Time**: 30 minutes
**Escalation**: Standard operational notification

## Cost Analysis

### Alert Costs (Monthly)
- **13 Metric Alerts + 2 Activity Log Alerts per Database**: 15 × $0.10 = **$1.50 per SQL Database**
- **Multi-Database Deployment**: Scales linearly with database count
- **Action Group**: FREE (included)
- **Activity Log Alerts**: FREE (included)

### Cost Examples by Environment

#### Small Database Environment (5 Databases)
- **Monthly Alert Cost**: $7.50
- **Annual Alert Cost**: $90.00

#### Medium Enterprise Database Platform (20 Databases)
- **Monthly Alert Cost**: $30.00
- **Annual Alert Cost**: $360.00

#### Large Multi-Tenant Database System (100 Databases)
- **Monthly Alert Cost**: $150.00
- **Annual Alert Cost**: $1,800.00

#### Enterprise Database Portfolio (500 Databases)
- **Monthly Alert Cost**: $750.00
- **Annual Alert Cost**: $9,000.00

### Return on Investment (ROI)

#### Cost of Database Issues
- **Query Performance Degradation**: 50-200% increase in response times
- **Database Unavailability**: $100,000-500,000/hour for mission-critical systems
- **Data Loss**: Potential compliance violations and business continuity impact
- **Storage Exhaustion**: Complete service outage until storage is increased
- **Deadlock Issues**: Transaction failures and data consistency problems
- **Recovery Time**: 4-24 hours average recovery time without proactive monitoring

#### Alert Value Calculation
- **Monthly Alert Cost**: $1.50 per SQL Database
- **Prevented Downtime**: 2 hours/month average per database
- **Cost Avoidance**: $200,000/month for critical database systems
- **ROI**: 13,333,233% (($200,000 - $1.50) / $1.50 × 100)

#### Additional Benefits
- **Proactive Performance Optimization**: Identify and resolve issues before user impact
- **Capacity Planning**: Data-driven decisions for scaling and resource allocation
- **Query Optimization**: Early detection of performance bottlenecks
- **Cost Optimization**: Right-size database tiers based on actual utilization
- **Compliance Assurance**: Maintain audit trails and operational oversight

### SQL Database Pricing Context
- **Basic**: $4.90/month (5 DTU)
- **Standard S0**: $15/month (10 DTU)
- **Standard S2**: $75/month (50 DTU)
- **Premium P1**: $465/month (125 DTU)
- **Premium P4**: $1,860/month (500 DTU)

**Alert Cost as % of Database Cost**: 0.08% - 30% of monthly database costs (decreasing with tier)

## Best Practices

### Deployment Best Practices

#### 1. Environment-Specific Configuration
```hcl
# Production Environment - Strict monitoring
cpu_percent_threshold         = 80
storage_percent_threshold     = 90
connection_failed_threshold   = 5
deadlock_threshold           = 1

# Staging Environment - Moderate monitoring  
cpu_percent_threshold         = 85
storage_percent_threshold     = 90
connection_failed_threshold   = 10
deadlock_threshold           = 5

# Development Environment - Relaxed monitoring
cpu_percent_threshold         = 90
storage_percent_threshold     = 95
connection_failed_threshold   = 20
deadlock_threshold           = 10
```

#### 2. Database Tier-Appropriate Thresholds
- **Basic Tiers**: Higher thresholds due to resource limitations (85-90%)
- **Standard Tiers**: Moderate thresholds for typical workloads (80-85%)
- **Premium Tiers**: Lower thresholds for high-performance requirements (70-80%)

#### 3. Workload-Specific Configurations
- **OLTP Databases**: Focus on deadlock and session monitoring
- **Data Warehouses**: Emphasize CPU and I/O performance monitoring
- **Reporting Databases**: Monitor read performance and connection volume

### Database Performance Best Practices

#### 1. Query Optimization
```sql
-- Index creation for performance
CREATE INDEX IX_Orders_CustomerDate 
ON Orders (CustomerId, OrderDate)
INCLUDE (TotalAmount, Status);

-- Query optimization with proper indexing
SELECT o.OrderId, o.TotalAmount, c.CustomerName
FROM Orders o WITH (NOLOCK)
INNER JOIN Customers c ON o.CustomerId = c.CustomerId
WHERE o.OrderDate >= DATEADD(day, -30, GETDATE())
  AND o.Status = 'Completed';

-- Use query hints for optimization
SELECT /*+ USE_HINT('FORCE_ORDER') */ 
    ProductId, SUM(Quantity) as TotalSold
FROM Sales s
INNER JOIN Products p ON s.ProductId = p.ProductId
WHERE s.SaleDate >= '2023-01-01'
GROUP BY ProductId;
```

#### 2. Connection Management
```csharp
// Implement proper connection pooling
public class DatabaseService
{
    private readonly string _connectionString;
    
    public DatabaseService(IConfiguration configuration)
    {
        var builder = new SqlConnectionStringBuilder(configuration.GetConnectionString("DefaultConnection"))
        {
            Pooling = true,
            MaxPoolSize = 100,
            MinPoolSize = 5,
            ConnectionTimeout = 30,
            CommandTimeout = 300
        };
        _connectionString = builder.ConnectionString;
    }
    
    public async Task<T> ExecuteAsync<T>(string sql, object parameters = null)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QuerySingleOrDefaultAsync<T>(sql, parameters);
    }
}

// Implement retry logic for transient failures
public async Task<T> ExecuteWithRetryAsync<T>(Func<Task<T>> operation, int maxRetries = 3)
{
    var retryPolicy = RetryPolicy.Create<SqlTransientErrorDetectionStrategy>(maxRetries);
    return await retryPolicy.ExecuteAsync(operation);
}
```

#### 3. Performance Monitoring Integration
```sql
-- Enable Query Store for performance monitoring
ALTER DATABASE [YourDatabase] SET QUERY_STORE = ON;
ALTER DATABASE [YourDatabase] SET QUERY_STORE 
(
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);

-- Create performance monitoring views
CREATE VIEW vw_PerformanceMetrics AS
SELECT 
    r.resource_type,
    r.avg_cpu_percent,
    r.avg_data_io_percent,
    r.avg_log_write_percent,
    r.avg_memory_usage_percent,
    r.end_time
FROM sys.dm_db_resource_stats r
WHERE r.end_time >= DATEADD(hour, -1, GETUTCDATE());
```

### Security and Compliance Best Practices

#### 1. Database Security Configuration
```sql
-- Enable Transparent Data Encryption (TDE)
ALTER DATABASE [YourDatabase] SET ENCRYPTION ON;

-- Configure Always Encrypted for sensitive data
CREATE COLUMN MASTER KEY [CMK_Auto1]
WITH (
    KEY_STORE_PROVIDER_NAME = N'AZURE_KEY_VAULT',
    KEY_PATH = N'https://your-keyvault.vault.azure.net/keys/AlwaysEncryptedKey/1234567890abcdef1234567890abcdef'
);

-- Implement Row Level Security
CREATE FUNCTION Security.fn_securitypredicate(@UserId AS int)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result 
WHERE @UserId = USER_ID() OR IS_MEMBER('db_owner') = 1;
```

#### 2. Audit and Compliance
```sql
-- Enable database auditing
CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpec]
FOR SERVER AUDIT [ServerAudit]
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP)
WITH (STATE = ON);

-- Implement data retention policies
CREATE TABLE DataRetentionPolicy (
    TableName NVARCHAR(128),
    RetentionDays INT,
    CreatedDate DATETIME2 DEFAULT GETUTCDATE()
);
```

#### 3. Backup and Recovery
```sql
-- Configure automated backups with retention
EXEC rds-backup-database 
    @source_db_name='YourDatabase', 
    @retention_period_in_days=35,
    @backup_type='FULL';

-- Implement point-in-time recovery testing
RESTORE DATABASE [YourDatabase_Test] FROM DATABASE_SNAPSHOT = 'YourDatabase_Snapshot'
WITH REPLACE, STATS = 10;
```

### Monitoring and Diagnostics Best Practices

#### 1. Custom Monitoring Queries
```sql
-- Monitor current connections and sessions
SELECT 
    COUNT(*) as ActiveConnections,
    SUM(CASE WHEN status = 'running' THEN 1 ELSE 0 END) as RunningQueries,
    SUM(CASE WHEN status = 'sleeping' THEN 1 ELSE 0 END) as IdleSessions
FROM sys.dm_exec_sessions 
WHERE is_user_process = 1;

-- Monitor blocking and deadlocks
SELECT 
    blocking_session_id,
    session_id,
    wait_type,
    wait_time,
    wait_resource,
    text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle)
WHERE blocking_session_id <> 0;

-- Monitor resource utilization
SELECT 
    resource_type,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    avg_memory_usage_percent,
    end_time
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;
```

#### 2. Performance Baseline Establishment
```bash
# Monitor database performance trends
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Sql/servers/{server}/databases/{db}" \
  --metric "cpu_percent,dtu_consumption_percent,storage_percent" \
  --interval PT15M \
  --start-time "2023-11-01T00:00:00Z" \
  --end-time "2023-11-30T23:59:59Z"
```

#### 3. Automated Health Checks
```powershell
# PowerShell script for database health monitoring
$ResourceGroup = "rg-production-data"
$ServerName = "sql-prod-001"
$DatabaseName = "app-production"

# Check database status
$Database = Get-AzSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $ServerName -DatabaseName $DatabaseName
Write-Output "Database Status: $($Database.Status)"

# Check recent metrics
$Metrics = Get-AzMetric -ResourceId $Database.ResourceId -MetricName "cpu_percent" -TimeGrain 00:15:00
$LatestCPU = $Metrics.Data | Sort-Object Timestamp -Descending | Select-Object -First 1
Write-Output "Latest CPU Usage: $($LatestCPU.Average)%"

# Check for recent alerts
$Alerts = Get-AzActivityLog -ResourceGroupName $ResourceGroup -StartTime (Get-Date).AddHours(-24)
$DatabaseAlerts = $Alerts | Where-Object { $_.ResourceId -like "*$DatabaseName*" }
Write-Output "Recent Alerts: $($DatabaseAlerts.Count)"
```

## Troubleshooting

### Common Issues and Solutions

#### 1. High CPU Utilization
**Symptoms**: CPU percentage alert firing with slow query performance

**Possible Causes**:
- Inefficient queries with missing or suboptimal indexes
- Large table scans or Cartesian products
- Excessive parallelism or blocking operations
- Outdated statistics causing poor execution plans

**Troubleshooting Steps**:
```sql
-- Identify top CPU-consuming queries
SELECT TOP 10 
    qs.sql_handle,
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    qs.execution_count,
    SUBSTRING(qt.text, qs.statement_start_offset/2 + 1,
              (CASE WHEN qs.statement_end_offset = -1 
                    THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
                    ELSE qs.statement_end_offset 
               END - qs.statement_start_offset)/2) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY avg_cpu_time DESC;

-- Check for missing indexes
SELECT 
    mid.database_id,
    mid.object_id,
    id.statement,
    id.equality_columns,
    id.inequality_columns,
    id.included_columns,
    migs.user_seeks,
    migs.avg_total_user_cost,
    migs.avg_user_impact
FROM sys.dm_db_missing_index_details mid
INNER JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
INNER JOIN sys.dm_db_missing_index_details id ON mid.index_handle = id.index_handle
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact DESC;
```

**Resolution**:
- Create or optimize indexes based on missing index recommendations
- Update statistics on heavily queried tables
- Optimize query logic and eliminate unnecessary operations
- Consider database tier upgrade for more CPU resources

#### 2. Storage Space Issues
**Symptoms**: Storage percentage or bytes alerts with potential database unavailability

**Possible Causes**:
- Rapid data growth without proper capacity planning
- Large transaction log files not being backed up
- Fragmented indexes consuming excessive space
- Temporary objects or staging tables not being cleaned up

**Troubleshooting Steps**:
```sql
-- Check database file sizes and usage
SELECT 
    name AS FileName,
    size * 8.0 / 1024 AS CurrentSizeMB,
    FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 AS UsedSpaceMB,
    size * 8.0 / 1024 - FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 AS FreeSpaceMB,
    max_size * 8.0 / 1024 AS MaxSizeMB
FROM sys.database_files;

-- Identify largest tables
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 / 1024 AS TotalSpaceMB,
    SUM(a.used_pages) * 8 / 1024 AS UsedSpaceMB,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024 AS UnusedSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0 AND i.object_id > 255
GROUP BY t.name, i.name, p.rows
ORDER BY TotalSpaceMB DESC;

-- Check index fragmentation
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 30 AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

**Resolution**:
- Implement data archiving and purging strategies
- Rebuild or reorganize fragmented indexes
- Configure transaction log backups to manage log file size
- Scale up database storage or tier
- Implement data compression to reduce storage footprint

#### 3. Connection and Deadlock Issues
**Symptoms**: Connection failure or deadlock alerts affecting application availability

**Possible Causes**:
- Connection pool exhaustion in applications
- Long-running transactions holding locks
- Poor transaction design causing lock conflicts
- Insufficient database session or worker thread limits

**Troubleshooting Steps**:
```sql
-- Monitor current connections and blocking
SELECT 
    s.session_id,
    s.status,
    s.login_name,
    s.host_name,
    s.program_name,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.command,
    t.text AS current_statement
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE s.is_user_process = 1
ORDER BY s.session_id;

-- Analyze deadlock history (if extended events are configured)
SELECT 
    xed.event_data.value('(/event/@timestamp)[1]', 'datetime2') AS timestamp,
    xed.event_data.value('(/event/data[@name="xml_report"]/value)[1]', 'varchar(max)') AS deadlock_graph
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_session_targets xet
    INNER JOIN sys.dm_xe_sessions xes ON xes.address = xet.event_session_address
    WHERE xes.name = 'system_health'
) AS data
CROSS APPLY target_data.nodes('//RingBufferTarget/event') AS xed(event_data)
WHERE xed.event_data.value('@name', 'varchar(60)') = 'xml_deadlock_report';

-- Check resource utilization limits
SELECT 
    resource_type,
    current_value,
    max_value,
    (current_value * 100.0 / max_value) AS utilization_percent
FROM sys.dm_db_resource_stats
WHERE end_time = (SELECT MAX(end_time) FROM sys.dm_db_resource_stats);
```

**Resolution**:
- Optimize application connection pooling configuration
- Identify and optimize long-running queries
- Implement proper transaction scope and retry logic
- Consider database tier upgrade for higher connection limits
- Design better locking strategies to minimize deadlock potential

#### 4. Performance Degradation
**Symptoms**: Multiple performance alerts (I/O, workers, sessions) with slow application response

**Possible Causes**:
- Database tier insufficient for current workload
- Parameter sniffing causing suboptimal execution plans
- Blocking or lock escalation issues
- Resource contention from concurrent operations

**Troubleshooting Steps**:
```bash
# Check current database performance metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Sql/servers/{server}/databases/{database}" \
  --metric "cpu_percent,dtu_consumption_percent,physical_data_read_percent,log_write_percent" \
  --interval PT5M

# Monitor active queries and wait statistics
az sql db show-usage \
  --name {database} \
  --server {server} \
  --resource-group {rg}
```

**Resolution**:
- Scale up database tier for better performance characteristics
- Implement query plan optimization and parameter sniffing solutions
- Configure appropriate maintenance tasks (index rebuilds, statistics updates)
- Optimize concurrent operations and implement proper resource management
- Consider read replicas to distribute read workload

### Advanced Monitoring Setup

#### 1. Custom Dashboard Creation
```json
{
  "dashboard": {
    "title": "SQL Database Performance Dashboard",
    "panels": [
      {
        "title": "CPU Utilization",
        "query": "AzureMetrics | where MetricName == 'cpu_percent' | render timechart"
      },
      {
        "title": "Storage Utilization",
        "query": "AzureMetrics | where MetricName == 'storage_percent' | render timechart"
      },
      {
        "title": "Connection Status",
        "query": "AzureMetrics | where MetricName in ('connection_successful', 'connection_failed') | render timechart"
      },
      {
        "title": "Deadlock Incidents",
        "query": "AzureMetrics | where MetricName == 'deadlock' | render columnchart"
      }
    ]
  }
}
```

#### 2. Automated Health Check Script
```bash
#!/bin/bash
# SQL Database health check script

SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="rg-production-data"
SERVER_NAME="sql-prod-001"
DATABASE_NAME="app-production"

echo "Checking SQL Database: $SERVER_NAME/$DATABASE_NAME"

# Check database status
DB_STATUS=$(az sql db show \
  --name "$DATABASE_NAME" \
  --server "$SERVER_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "status" -o tsv)

echo "Database Status: $DB_STATUS"

# Check recent CPU usage
CPU_USAGE=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Sql/servers/$SERVER_NAME/databases/$DATABASE_NAME" \
  --metric "cpu_percent" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv)

echo "Recent CPU Usage: ${CPU_USAGE:-N/A}%"

# Check storage utilization
STORAGE_USAGE=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Sql/servers/$SERVER_NAME/databases/$DATABASE_NAME" \
  --metric "storage_percent" \
  --interval PT15M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv)

echo "Storage Usage: ${STORAGE_USAGE:-N/A}%"

# Check for recent deadlocks
DEADLOCKS=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Sql/servers/$SERVER_NAME/databases/$DATABASE_NAME" \
  --metric "deadlock" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].total" -o tsv)

echo "Recent Deadlocks: ${DEADLOCKS:-0}"

# Health assessment
if [ "$DB_STATUS" != "Online" ]; then
  echo "CRITICAL: Database is not online"
  exit 2
fi

if [ "$CPU_USAGE" != "null" ] && (( $(echo "$CPU_USAGE > 85" | bc -l) )); then
  echo "WARNING: High CPU usage detected"
fi

if [ "$STORAGE_USAGE" != "null" ] && (( $(echo "$STORAGE_USAGE > 90" | bc -l) )); then
  echo "WARNING: High storage usage detected"
fi

if [ "$DEADLOCKS" != "null" ] && [ "$DEADLOCKS" != "0" ]; then
  echo "WARNING: Deadlocks detected"
fi

echo "Health check completed"
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure SQL Database monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual database performance patterns and business requirements is recommended for optimal monitoring effectiveness.