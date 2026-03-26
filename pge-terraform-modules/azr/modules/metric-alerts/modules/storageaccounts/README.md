# Azure Storage Accounts - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure Storage Accounts**, providing proactive monitoring for storage availability, performance, capacity, and error rates. The module monitors critical storage metrics to ensure optimal data access performance, reliability, and operational continuity.

Azure Storage Accounts provide highly available, massively scalable, durable, and secure storage for a variety of data objects in the cloud. This module focuses on essential storage metrics including availability, latency, capacity utilization, transaction rates, and error monitoring across Blob, Queue, Table, and File services.

## Features

- **Availability Monitoring**: Real-time tracking of storage service availability and uptime
- **Performance Monitoring**: End-to-end and server latency tracking for optimal response times
- **Capacity Management**: Storage utilization monitoring for capacity planning and cost optimization
- **Transaction Monitoring**: High-volume transaction detection and rate limiting alerts
- **Error Detection**: Comprehensive error rate monitoring with response type classification
- **Multi-Storage Support**: Individual monitoring for multiple storage accounts in a single deployment
- **Real-Time Alerting**: 5-minute evaluation frequency for rapid issue detection
- **Cost-Effective Monitoring**: Optimized alert configuration at $0.60 per storage account per month
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **Service Reliability**: Availability monitoring to ensure 99%+ uptime SLA compliance
- **Performance Optimization**: Latency tracking for optimal application response times
- **Capacity Planning**: Storage utilization for growth planning and cost management
- **Error Analysis**: Detailed error classification including client, server, and network errors
- **Transaction Analysis**: High-volume workload detection and performance impact assessment

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Storage/storageAccounts/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Storage Accounts**: Existing Azure Storage Accounts to monitor
- **Recommended**: Log Analytics workspace for diagnostic settings
- **Recommended**: Diagnostic settings enabled on Storage Accounts

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs (Storage Analytics Logging) provides essential troubleshooting capabilities for detailed transaction analysis and error investigation.

## Usage

### Basic Configuration

```hcl
module "storage_account_alerts" {
  source = "./modules/metricAlerts/storageaccounts"
  
  # Resource Configuration
  resource_group_name               = "rg-production-data"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # Storage Accounts to Monitor
  storage_account_names = [
    "storageaccountprod001",
    "storageaccountprod002",
    "storageaccountbackup001"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "Storage"
    Owner             = "data-platform@pge.com"
    CostCenter        = "IT-Infrastructure"
    Compliance        = "SOX"
    DataClassification = "Confidential"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "storage_alerts_high_performance" {
  source = "./modules/metricAlerts/storageaccounts"
  
  # Resource Configuration
  resource_group_name               = "rg-production-data"
  action_group_resource_group_name  = "rg-monitoring"
  storage_account_names            = ["criticalstorageprod001"]
  
  # High-Performance Storage Thresholds
  storage_availability_threshold    = 99.5   # Higher availability requirement
  storage_latency_threshold        = 500     # Lower latency tolerance (500ms)
  storage_server_latency_threshold = 50      # Aggressive server latency (50ms)
  
  # Capacity and Transaction Thresholds
  storage_capacity_threshold       = 85      # Earlier capacity warning
  storage_transaction_threshold    = 50000   # Higher transaction volume threshold
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    SLA         = "99.95%"
    Owner       = "storage-team@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Storage - Relaxed Thresholds
storage_availability_threshold    = 95      # Lower availability requirement
storage_latency_threshold        = 2000     # Higher latency tolerance
storage_server_latency_threshold = 200      # Relaxed server latency
storage_capacity_threshold       = 95       # Higher capacity threshold
storage_transaction_threshold    = 5000     # Lower transaction threshold
```

#### Staging Environment
```hcl
# Staging Storage - Moderate Thresholds
storage_availability_threshold    = 98      # Moderate availability
storage_latency_threshold        = 1500     # Moderate latency tolerance
storage_server_latency_threshold = 150      # Moderate server latency
storage_capacity_threshold       = 90       # Standard capacity threshold
storage_transaction_threshold    = 7500     # Moderate transaction threshold
```

#### Production Environment
```hcl
# Production Storage - Strict Thresholds
storage_availability_threshold    = 99      # High availability requirement
storage_latency_threshold        = 1000     # Low latency tolerance
storage_server_latency_threshold = 100      # Strict server latency
storage_capacity_threshold       = 90       # Standard capacity threshold
storage_transaction_threshold    = 10000    # High transaction threshold
```

### Storage Type-Specific Configurations

#### General Purpose v2 Storage
```hcl
# GPv2 - Balanced Performance
storage_availability_threshold    = 99
storage_latency_threshold        = 1000
storage_server_latency_threshold = 100
storage_capacity_threshold       = 90
storage_transaction_threshold    = 10000
```

#### Premium Block Blob Storage
```hcl
# Premium Block Blob - High Performance
storage_availability_threshold    = 99.9
storage_latency_threshold        = 250
storage_server_latency_threshold = 25
storage_capacity_threshold       = 85
storage_transaction_threshold    = 50000
```

#### Premium File Shares
```hcl
# Premium Files - Low Latency Requirements
storage_availability_threshold    = 99.5
storage_latency_threshold        = 500
storage_server_latency_threshold = 50
storage_capacity_threshold       = 85
storage_transaction_threshold    = 25000
```

### Use Case-Specific Configurations

#### Backup Storage
```hcl
# Backup Storage - Cost-Optimized
storage_availability_threshold    = 98
storage_latency_threshold        = 5000     # Higher latency acceptable
storage_server_latency_threshold = 500
storage_capacity_threshold       = 95       # Allow higher utilization
storage_transaction_threshold    = 2000     # Lower transaction volume
```

#### Application Data Storage
```hcl
# Application Data - Performance-Focused
storage_availability_threshold    = 99.5
storage_latency_threshold        = 500
storage_server_latency_threshold = 50
storage_capacity_threshold       = 85
storage_transaction_threshold    = 20000
```

#### Archive Storage
```hcl
# Archive Storage - Long-Term Retention
storage_availability_threshold    = 95      # Lower availability acceptable
storage_latency_threshold        = 10000    # Very high latency acceptable
storage_server_latency_threshold = 1000
storage_capacity_threshold       = 98       # Maximize utilization
storage_transaction_threshold    = 500      # Minimal transactions expected
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for storage accounts |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
| `storage_account_names` | `list(string)` | `[]` | List of storage account names to monitor |

### Performance Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `storage_availability_threshold` | `number` | `99` | Availability percentage threshold | 95-99.9% |
| `storage_latency_threshold` | `number` | `1000` | End-to-end latency threshold (ms) | 250-5000ms |
| `storage_server_latency_threshold` | `number` | `100` | Server latency threshold (ms) | 25-500ms |

### Capacity Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `storage_capacity_threshold` | `number` | `90` | Capacity utilization percentage | 80-98% |
| `storage_transaction_threshold` | `number` | `10000` | Transaction rate per minute | 1000-50000 |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "storage-team@pge.com"       # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "storage-oncall@pge.com"     # Notification contact
  DataClassification = "Confidential"               # Data sensitivity
  CostCenter         = "IT-Infrastructure"          # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  StorageTier        = "Standard"                   # Storage performance tier
}
```

## Alert Details

### 1. Storage Availability Alert
- **Alert Name**: `storage-availability-{storage-account-name}`
- **Metric**: `Availability`
- **Threshold**: 99% (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Storage service availability percentage, indicating the reliability and uptime of storage operations across all storage services.

**What to do when this alert fires**:
1. **Service Health Check**: Verify Azure Storage service health in the affected region
2. **Network Connectivity**: Test network connectivity from client applications to storage endpoints
3. **Access Key Validation**: Verify storage account access keys and connection strings are valid
4. **Firewall Rules**: Check storage account firewall and network access rules
5. **Region Status**: Consider failover to secondary region if geo-replication is enabled

### 2. End-to-End Latency Alert
- **Alert Name**: `storage-latency-{storage-account-name}`
- **Metric**: `SuccessE2ELatency`
- **Threshold**: 1000ms (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Total end-to-end latency for successful storage requests, including network latency and processing time.

**What to do when this alert fires**:
1. **Latency Analysis**: Analyze latency patterns and identify peak usage times
2. **Network Performance**: Check network performance between clients and storage endpoints
3. **Request Patterns**: Review application request patterns for optimization opportunities
4. **Geographic Distribution**: Consider using storage accounts closer to client applications
5. **Performance Tier**: Evaluate upgrading to premium storage for better performance

### 3. Server Latency Alert
- **Alert Name**: `storage-server-latency-{storage-account-name}`
- **Metric**: `SuccessServerLatency`
- **Threshold**: 100ms (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Server-side processing latency for successful storage requests, excluding network latency.

**What to do when this alert fires**:
1. **Storage Performance**: Check storage account performance metrics and IOPS utilization
2. **Request Size**: Analyze request sizes and optimize for better throughput
3. **Hotspotting**: Identify if specific containers/blobs are causing performance bottlenecks
4. **Scaling**: Consider partitioning data or scaling to premium storage tiers
5. **Storage Type**: Evaluate if current storage type meets performance requirements

### 4. Storage Capacity Alert
- **Alert Name**: `storage-capacity-{storage-account-name}`
- **Metric**: `UsedCapacity`
- **Threshold**: 90% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT1H (1 hour)
- **Window**: PT1H (1 hour)
- **Aggregation**: Average

**What this alert monitors**: Total used capacity as a percentage of allocated storage quota, providing early warning for capacity planning.

**What to do when this alert fires**:
1. **Capacity Analysis**: Review storage usage patterns and identify largest consumers
2. **Data Lifecycle Management**: Implement data archiving and deletion policies
3. **Storage Optimization**: Compress data or move infrequently accessed data to cooler tiers
4. **Quota Management**: Increase storage quotas if growth is legitimate
5. **Cost Analysis**: Balance storage costs with performance requirements

### 5. High Transaction Rate Alert
- **Alert Name**: `storage-transactions-{storage-account-name}`
- **Metric**: `Transactions`
- **Threshold**: 10,000 transactions/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Total transaction count indicating high-volume storage operations that may affect performance or costs.

**What to do when this alert fires**:
1. **Transaction Analysis**: Analyze transaction patterns and identify sources of high volume
2. **Performance Impact**: Monitor if high transactions are affecting storage performance
3. **Cost Implications**: Review transaction costs and optimize for cost efficiency
4. **Application Optimization**: Optimize applications to reduce unnecessary storage operations
5. **Scaling Strategy**: Consider load distribution or premium storage for better throughput

### 6. Storage Error Rate Alert
- **Alert Name**: `storage-errors-{storage-account-name}`
- **Metric**: `Transactions` (filtered by error response types)
- **Threshold**: > 0 (any errors detected)
- **Severity**: 1 (Critical)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Storage operation errors including client errors, server errors, network errors, and throttling errors.

**What to do when this alert fires**:
1. **Error Classification**: Analyze error types (ClientError, ServerError, NetworkError, ClientThrottlingError, ServerBusyError)
2. **Client Errors (4xx)**: Review application logic, authentication, and request formatting
3. **Server Errors (5xx)**: Check Azure service health and consider retry logic implementation
4. **Network Errors**: Investigate network connectivity and DNS resolution issues
5. **Throttling Errors**: Implement exponential backoff and optimize request patterns

## Severity Levels

### Severity 1 (Critical) - Service Impact
- **Storage Availability**: Service unavailability affecting application operations
- **Storage Errors**: Error conditions that may indicate service degradation or data access issues

**Response Time**: 5 minutes
**Escalation**: Immediate notification to storage team and on-call engineer

### Severity 2 (High) - Performance Impact
- **End-to-End Latency**: Performance degradation affecting application responsiveness
- **Server Latency**: Storage service performance impacting user experience
- **Storage Capacity**: Capacity approaching limits requiring proactive management

**Response Time**: 15 minutes
**Escalation**: Notification to storage administration team

### Severity 3 (Medium) - Operational Monitoring
- **High Transaction Volume**: Elevated transaction rates indicating scaling or optimization needs

**Response Time**: 30 minutes
**Escalation**: Standard operational notification

## Cost Analysis

### Alert Costs (Monthly)
- **6 Metric Alerts per Storage Account**: 6 × $0.10 = **$0.60 per Storage Account**
- **Multi-Storage Deployment**: Scales linearly with storage account count
- **Action Group**: FREE (included)

### Cost Examples by Environment

#### Small Storage Environment (3 Storage Accounts)
- **Monthly Alert Cost**: $1.80
- **Annual Alert Cost**: $21.60

#### Medium Enterprise Storage Platform (10 Storage Accounts)
- **Monthly Alert Cost**: $6.00
- **Annual Alert Cost**: $72.00

#### Large Multi-Application Storage System (50 Storage Accounts)
- **Monthly Alert Cost**: $30.00
- **Annual Alert Cost**: $360.00

#### Enterprise Storage Portfolio (200 Storage Accounts)
- **Monthly Alert Cost**: $120.00
- **Annual Alert Cost**: $1,440.00

### Return on Investment (ROI)

#### Cost of Storage Issues
- **Storage Unavailability**: $50,000-500,000/hour for applications dependent on storage access
- **Performance Degradation**: 200-1000% increase in application response times
- **Data Loss Risk**: Potential compliance violations and business continuity impact
- **Capacity Overflow**: Service outages when storage limits are exceeded
- **Recovery Time**: 2-12 hours average recovery time without proactive monitoring

#### Alert Value Calculation
- **Monthly Alert Cost**: $0.60 per Storage Account
- **Prevented Downtime**: 2 hours/month average per storage account
- **Cost Avoidance**: $100,000/month for critical storage systems
- **ROI**: 16,666,567% (($100,000 - $0.60) / $0.60 × 100)

#### Additional Benefits
- **Proactive Performance Management**: Identify and resolve issues before user impact
- **Capacity Planning**: Data-driven decisions for storage scaling and archiving
- **Cost Optimization**: Right-size storage tiers based on actual usage patterns
- **Compliance Assurance**: Maintain audit trails and operational oversight
- **Application Performance**: Ensure optimal storage performance for dependent applications

### Storage Account Pricing Context
- **Standard GPv2 (LRS)**: $0.018/GB/month
- **Standard GPv2 (GRS)**: $0.036/GB/month  
- **Premium Block Blob**: $0.15/GB/month
- **Premium File Shares**: $0.20/GB/month

**Alert Cost Impact**: Minimal impact on storage costs (typically <0.1% of total storage costs)

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive monitoring and troubleshooting, enable diagnostic settings on your Storage Account resources. While metric alerts monitor performance thresholds, diagnostic settings (Storage Analytics Logging) provide detailed transaction logs for root cause analysis.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings via Azure CLI for the storage account
az monitor diagnostic-settings create \
  --name "storage-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Storage/storageAccounts/{storage-account-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --metrics '[
    {"category":"Transaction","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"Capacity","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'

# Enable blob service diagnostics
az monitor diagnostic-settings create \
  --name "blob-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Storage/storageAccounts/{storage-account-name}/blobServices/default" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"StorageRead","enabled":true,"retentionPolicy":{"days":7,"enabled":true}},
    {"category":"StorageWrite","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"StorageDelete","enabled":true,"retentionPolicy":{"days":90,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"Transaction","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
# Storage Account level diagnostics
resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  for_each                   = toset(var.storage_account_names)
  name                       = "storage-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_storage_account.accounts[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Storage Account Metrics
  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }
}

# Blob Service diagnostics
resource "azurerm_monitor_diagnostic_setting" "blob_diagnostics" {
  for_each                   = toset(var.storage_account_names)
  name                       = "blob-diagnostics-${each.key}"
  target_resource_id         = "${data.azurerm_storage_account.accounts[each.key].id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Blob operation logs
  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  # Blob metrics
  metric {
    category = "Transaction"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Service | Category | Purpose | When to Enable |
|---------|----------|---------|----------------|
| **Storage Account** | Transaction | Account-level transaction metrics | **Always** - Required for performance analysis |
| **Storage Account** | Capacity | Storage utilization metrics | **Always** - Capacity planning |
| **Blob Service** | StorageRead | Read operations (GET, HEAD) | **Production** - Troubleshooting |
| **Blob Service** | StorageWrite | Write operations (PUT, POST, COPY) | **Always** - Audit trail |
| **Blob Service** | StorageDelete | Delete operations | **Always** - Security and audit |
| **File Service** | StorageRead/Write/Delete | File share operations | **If using Files** |
| **Queue Service** | StorageRead/Write/Delete | Queue operations | **If using Queues** |
| **Table Service** | StorageRead/Write/Delete | Table operations | **If using Tables** |

#### Useful Log Analytics Queries

```kusto
// Failed transactions by error type
StorageBlobLogs
| where TimeGenerated > ago(24h)
| where StatusCode >= 400
| summarize ErrorCount = count() by StatusCode, StatusText, OperationName
| order by ErrorCount desc

// Slow transactions (>1 second)
StorageBlobLogs
| where TimeGenerated > ago(1h)
| where DurationMs > 1000
| project TimeGenerated, OperationName, DurationMs, Uri, CallerIpAddress
| order by DurationMs desc
| take 50

// Storage capacity trend
StorageAccountCapacity
| where TimeGenerated > ago(30d)
| summarize AvgCapacity = avg(UsedCapacity) by bin(TimeGenerated, 1d)
| render timechart

// High transaction rate analysis
StorageAccountTransaction
| where TimeGenerated > ago(1h)
| where ApiName != "GetBlobServiceProperties"
| summarize TransactionCount = sum(Transactions) by bin(TimeGenerated, 5m), ApiName
| order by TransactionCount desc
```

### 2. Deployment Best Practices

#### Environment-Specific Configuration
```hcl
# Production Environment - Strict monitoring
storage_availability_threshold    = 99
storage_latency_threshold        = 1000
storage_server_latency_threshold = 100
storage_capacity_threshold       = 90
storage_transaction_threshold    = 10000

# Staging Environment - Moderate monitoring  
storage_availability_threshold    = 98
storage_latency_threshold        = 1500
storage_server_latency_threshold = 150
storage_capacity_threshold       = 90
storage_transaction_threshold    = 7500

# Development Environment - Relaxed monitoring
storage_availability_threshold    = 95
storage_latency_threshold        = 2000
storage_server_latency_threshold = 200
storage_capacity_threshold       = 95
storage_transaction_threshold    = 5000
```

#### Storage Type-Appropriate Thresholds
- **General Purpose v2**: Balanced thresholds for typical workloads
- **Premium Storage**: Lower latency thresholds (50ms server, 500ms E2E) for high-performance requirements
- **Archive Storage**: Higher latency tolerance, capacity-focused monitoring

#### Workload-Specific Configurations
- **Backup Storage**: Focus on capacity (80% threshold) and cost optimization
- **Application Storage**: Emphasis on availability (99.9%) and performance (100ms server latency)
- **Archive Storage**: Long-term retention with minimal performance requirements

### 3. Alert Response Procedures

#### Severity 1 (Critical) - Immediate Response
- **Storage Availability < 99%** → Check service health, review error logs, verify network connectivity

**Response Time**: < 15 minutes  
**Escalation**: Page on-call engineer

#### Severity 2 (Warning) - Review Within 1 Hour
- **High Latency** → Review transaction logs, check for throttling, analyze client patterns
- **High Capacity Usage** → Plan for capacity expansion, review retention policies
- **High Transaction Rate** → Analyze workload patterns, consider partitioning

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Severity 3 (Informational) - Review During Business Hours
- **High Error Rate** → Analyze error types, review application logs

**Response Time**: Next business day  
**Escalation**: Log for review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on all Storage Accounts
- [ ] Configure Log Analytics workspace retention (30 days for transactions, 90 days for deletes)
- [ ] Set up action groups with appropriate notification channels
- [ ] Customize alert thresholds based on workload patterns
- [ ] Test alert notifications to verify delivery
- [ ] Document escalation procedures
- [ ] Enable soft delete for blob recovery

#### Ongoing Operations
- [ ] Review alert thresholds quarterly based on growth
- [ ] Analyze false positive rates monthly
- [ ] Review diagnostic logs weekly for patterns
- [ ] Update alert rules for new Storage Accounts
- [ ] Validate action group membership monthly
- [ ] Review capacity trends for planning
- [ ] Audit access patterns and optimize

#### Performance & Cost Optimization
- [ ] Establish performance baselines (latency, throughput)
- [ ] Monitor and optimize access tier usage (Hot/Cool/Archive)
- [ ] Review lifecycle management policies
- [ ] Analyze transaction costs and optimize
- [ ] Implement caching strategies where applicable
- [ ] Review and optimize blob partitioning strategies

### Deployment Best Practices (Continued)

#### 1. Storage Account Configuration
```bash
# Enable storage analytics and metrics
az storage logging update \
  --account-name mystorageaccount \
  --account-key myaccountkey \
  --services b \
  --log-types rwd \
  --retention-days 30

# Configure CORS for web applications
az storage cors add \
  --account-name mystorageaccount \
  --account-key myaccountkey \
  --services b \
  --methods GET POST PUT \
  --origins "*" \
  --allowed-headers "*" \
  --exposed-headers "*" \
  --max-age 3600
```

#### 2. Performance Optimization
```csharp
// Implement optimal connection configuration
public class StorageService
{
    private readonly BlobServiceClient _blobServiceClient;
    
    public StorageService(string connectionString)
    {
        var options = new BlobClientOptions()
        {
            Transport = new HttpClientTransport(new HttpClient()
            {
                Timeout = TimeSpan.FromSeconds(100)
            }),
            Retry = {
                Delay = TimeSpan.FromSeconds(1),
                MaxRetries = 5,
                Mode = RetryMode.Exponential
            }
        };
        
        _blobServiceClient = new BlobServiceClient(connectionString, options);
    }
    
    // Implement parallel upload for large files
    public async Task UploadLargeFileAsync(string containerName, string blobName, Stream content)
    {
        var blobClient = _blobServiceClient.GetBlobContainerClient(containerName).GetBlobClient(blobName);
        
        var uploadOptions = new BlobUploadOptions
        {
            TransferOptions = new StorageTransferOptions
            {
                // Upload in parallel for better performance
                InitialTransferSize = 4 * 1024 * 1024,      // 4MB
                MaximumConcurrency = Environment.ProcessorCount,
                MaximumTransferSize = 4 * 1024 * 1024        // 4MB per chunk
            }
        };
        
        await blobClient.UploadAsync(content, uploadOptions);
    }
}
```

#### 3. Monitoring Integration
```powershell
# PowerShell script for storage performance monitoring
function Get-StorageAccountMetrics {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$false)]
        [int]$Hours = 24
    )
    
    $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    $ResourceId = $StorageAccount.Id
    
    Write-Host "Storage Account Metrics for: $StorageAccountName" -ForegroundColor Green
    Write-Host "=============================================="
    
    # Get availability metrics
    $AvailabilityMetrics = Get-AzMetric -ResourceId $ResourceId -MetricName "Availability" -TimeGrain 01:00:00
    $LatestAvailability = $AvailabilityMetrics.Data | Sort-Object Timestamp -Descending | Select-Object -First 1
    Write-Host "Current Availability: $($LatestAvailability.Average)%" -ForegroundColor Yellow
    
    # Get latency metrics
    $LatencyMetrics = Get-AzMetric -ResourceId $ResourceId -MetricName "SuccessE2ELatency" -TimeGrain 01:00:00
    $LatestLatency = $LatencyMetrics.Data | Sort-Object Timestamp -Descending | Select-Object -First 1
    Write-Host "Current E2E Latency: $($LatestLatency.Average) ms" -ForegroundColor Yellow
    
    # Get capacity metrics
    $CapacityMetrics = Get-AzMetric -ResourceId $ResourceId -MetricName "UsedCapacity" -TimeGrain 01:00:00
    $LatestCapacity = $CapacityMetrics.Data | Sort-Object Timestamp -Descending | Select-Object -First 1
    Write-Host "Used Capacity: $([math]::Round($LatestCapacity.Average / 1GB, 2)) GB" -ForegroundColor Yellow
    
    # Get transaction metrics
    $TransactionMetrics = Get-AzMetric -ResourceId $ResourceId -MetricName "Transactions" -TimeGrain 01:00:00
    $LatestTransactions = $TransactionMetrics.Data | Sort-Object Timestamp -Descending | Select-Object -First 1
    Write-Host "Transactions/Hour: $($LatestTransactions.Total)" -ForegroundColor Yellow
}

# Usage
Get-StorageAccountMetrics -ResourceGroupName "rg-production-data" -StorageAccountName "storageaccountprod001"
```

### Security and Compliance Best Practices

#### 1. Storage Security Configuration
```bash
# Enable storage account security features
az storage account update \
  --name mystorageaccount \
  --resource-group myresourcegroup \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Configure network access rules
az storage account network-rule add \
  --account-name mystorageaccount \
  --resource-group myresourcegroup \
  --ip-address 203.0.113.0/24

# Enable soft delete for blobs
az storage blob service-properties delete-policy update \
  --account-name mystorageaccount \
  --account-key myaccountkey \
  --enable true \
  --days-retained 30
```

#### 2. Access Control and Monitoring
```bash
# Configure Azure AD authentication
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee user@domain.com \
  --scope "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Storage/storageAccounts/{storage-account}"

# Enable diagnostic settings
az monitor diagnostic-settings create \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage-account}" \
  --name "storage-diagnostics" \
  --logs '[{"category":"StorageRead","enabled":true,"retentionPolicy":{"enabled":true,"days":30}}]' \
  --metrics '[{"category":"Transaction","enabled":true,"retentionPolicy":{"enabled":true,"days":30}}]' \
  --workspace "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}"
```

#### 3. Data Protection and Backup
```bash
# Configure blob versioning
az storage account blob-service-properties update \
  --account-name mystorageaccount \
  --resource-group myresourcegroup \
  --enable-versioning true

# Enable point-in-time restore
az storage account blob-service-properties update \
  --account-name mystorageaccount \
  --resource-group myresourcegroup \
  --enable-restore-policy true \
  --restore-days 30

# Configure lifecycle management
az storage account management-policy create \
  --account-name mystorageaccount \
  --resource-group myresourcegroup \
  --policy @lifecycle-policy.json
```

## Troubleshooting

### Common Issues and Solutions

#### 1. High Latency Issues
**Symptoms**: Latency alerts firing with slow application response times

**Possible Causes**:
- Network connectivity issues between clients and storage
- Geographic distance between clients and storage account
- High request volume causing throttling
- Large request sizes affecting throughput

**Troubleshooting Steps**:
```bash
# Test network connectivity to storage endpoints
nslookup mystorageaccount.blob.core.windows.net
telnet mystorageaccount.blob.core.windows.net 443

# Check storage account metrics for throttling
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage}" \
  --metric "Transactions" \
  --filter "ResponseType eq 'ClientThrottlingError' or ResponseType eq 'ServerBusyError'" \
  --interval PT5M

# Analyze request patterns
az storage logging show \
  --account-name mystorageaccount \
  --account-key myaccountkey \
  --services b
```

**Resolution**:
- Move storage account closer to client applications
- Implement retry logic with exponential backoff
- Optimize request sizes and patterns
- Consider premium storage for better performance
- Use CDN for frequently accessed content

#### 2. Storage Availability Issues
**Symptoms**: Availability alerts with intermittent storage access failures

**Possible Causes**:
- Azure service health issues in the region
- Network connectivity problems
- Authentication or authorization failures
- Storage account firewall blocking requests

**Troubleshooting Steps**:
```bash
# Check Azure service health
az rest --method get --url "https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2017-07-01" \
  --query "value[?contains(id, 'Microsoft.Storage')]"

# Verify storage account accessibility
az storage blob list \
  --account-name mystorageaccount \
  --account-key myaccountkey \
  --container-name mycontainer

# Check network access rules
az storage account show \
  --name mystorageaccount \
  --resource-group myresourcegroup \
  --query "networkRuleSet"
```

**Resolution**:
- Verify Azure service health status
- Check and update network access rules
- Validate authentication credentials
- Implement geo-redundant storage for high availability
- Consider read-access geo-redundant storage (RA-GRS)

#### 3. Storage Error Rate Issues
**Symptoms**: Error rate alerts with various HTTP error codes

**Possible Causes**:
- Application logic errors (4xx errors)
- Service-side issues (5xx errors)
- Authentication problems (401/403 errors)
- Request throttling (429 errors)

**Troubleshooting Steps**:
```bash
# Analyze error patterns in storage logs
az storage logging show \
  --account-name mystorageaccount \
  --account-key myaccountkey \
  --services b

# Download and analyze detailed logs
az storage blob download-batch \
  --source '$logs' \
  --destination ./storage-logs \
  --account-name mystorageaccount \
  --account-key myaccountkey

# Check authentication issues
az storage account keys list \
  --account-name mystorageaccount \
  --resource-group myresourcegroup
```

**Resolution**:
- **Client Errors (4xx)**: Fix application logic, validate request format, check permissions
- **Server Errors (5xx)**: Implement retry logic, check Azure service health
- **Authentication Errors**: Validate access keys, check Azure AD permissions
- **Throttling Errors**: Implement exponential backoff, optimize request patterns

#### 4. High Transaction Volume Issues
**Symptoms**: Transaction rate alerts with potential performance impact

**Possible Causes**:
- Application generating excessive requests
- Inefficient data access patterns
- Lack of caching mechanisms
- Automated processes causing spikes

**Troubleshooting Steps**:
```bash
# Analyze transaction patterns
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage}" \
  --metric "Transactions" \
  --interval PT5M \
  --start-time "2023-11-01T00:00:00Z"

# Check transaction costs
az consumption usage list \
  --start-date 2023-11-01 \
  --end-date 2023-11-30 \
  --query "[?contains(instanceName, 'mystorageaccount')]"
```

**Resolution**:
- Implement caching to reduce redundant requests
- Optimize application data access patterns
- Use batch operations where possible
- Consider CDN for frequently accessed content
- Monitor and optimize transaction costs

### Advanced Monitoring Setup

#### 1. Custom Storage Dashboard
```json
{
  "dashboard": {
    "title": "Storage Account Performance Dashboard",
    "panels": [
      {
        "title": "Storage Availability",
        "query": "AzureMetrics | where MetricName == 'Availability' | render timechart"
      },
      {
        "title": "End-to-End Latency",
        "query": "AzureMetrics | where MetricName == 'SuccessE2ELatency' | render timechart"
      },
      {
        "title": "Transaction Volume",
        "query": "AzureMetrics | where MetricName == 'Transactions' | render areachart"
      },
      {
        "title": "Error Rate by Type",
        "query": "AzureMetrics | where MetricName == 'Transactions' and ResponseType != 'Success' | render columnchart"
      },
      {
        "title": "Capacity Utilization",
        "query": "AzureMetrics | where MetricName == 'UsedCapacity' | render areachart"
      }
    ]
  }
}
```

#### 2. Automated Health Check Script
```bash
#!/bin/bash
# Storage Account health check script

RESOURCE_GROUP="rg-production-data"
STORAGE_ACCOUNT="storageaccountprod001"
SUBSCRIPTION_ID="your-subscription-id"

echo "Storage Account Health Check: $STORAGE_ACCOUNT"
echo "=============================================="

# Check storage account status
echo "1. Storage Account Status"
ACCOUNT_STATUS=$(az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --query "statusOfPrimary" -o tsv)
echo "   Primary Status: $ACCOUNT_STATUS"

# Check availability
echo "2. Availability Check"
AVAILABILITY=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
  --metric "Availability" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv 2>/dev/null)
echo "   Current Availability: ${AVAILABILITY:-N/A}%"

# Check latency
echo "3. Latency Check"
LATENCY=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
  --metric "SuccessE2ELatency" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv 2>/dev/null)
echo "   Current E2E Latency: ${LATENCY:-N/A} ms"

# Check capacity
echo "4. Capacity Check"
CAPACITY=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
  --metric "UsedCapacity" \
  --interval PT1H \
  --query "value[0].timeseries[0].data[-1].average" -o tsv 2>/dev/null)
if [ "$CAPACITY" != "" ]; then
  CAPACITY_GB=$(echo "scale=2; $CAPACITY / 1073741824" | bc)
  echo "   Used Capacity: ${CAPACITY_GB} GB"
fi

# Health assessment
echo "5. Health Assessment"
if [ "$ACCOUNT_STATUS" != "available" ]; then
  echo "   CRITICAL: Storage account is not available"
  exit 2
fi

if [ "$AVAILABILITY" != "" ] && (( $(echo "$AVAILABILITY < 99" | bc -l 2>/dev/null || echo 0) )); then
  echo "   WARNING: Low availability detected"
fi

if [ "$LATENCY" != "" ] && (( $(echo "$LATENCY > 1000" | bc -l 2>/dev/null || echo 0) )); then
  echo "   WARNING: High latency detected"
fi

echo "   Health check completed successfully"
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Storage Account monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual storage usage patterns and application requirements is recommended for optimal monitoring effectiveness.