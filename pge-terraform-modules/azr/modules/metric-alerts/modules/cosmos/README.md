# Azure Cosmos DB AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure Cosmos DB**. It provides production-ready monitoring across availability, performance, capacity, and administrative operations to ensure optimal database performance and reliability.

Azure Cosmos DB is a globally distributed, multi-model database service. This module monitors critical metrics to prevent availability issues, performance degradation, throttling, and capacity constraints while tracking administrative changes for audit and compliance.

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

- **9 Metric Alerts** for real-time performance and capacity monitoring
- **3 Activity Log Alerts** for administrative operations
- **Customizable Thresholds** for all alerts
- **Enable/Disable Flags** for flexible alert management
- **Availability Monitoring** to detect service degradation
- **Performance Tracking** for latency and RU consumption
- **Capacity Management** for data and index usage
- **Throttling Detection** via normalized RU consumption
- **Administrative Auditing** for account changes and deletions
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 🔴 Critical Alerts (Severity 0)
- Normalized RU Consumption (throttling indicator)

### 🟠 High Priority Alerts (Severity 1)
- Service Availability

### 🟡 Warning Alerts (Severity 2)
- Server Side Latency
- RU Consumption
- Data Usage
- Provisioned Throughput

### 🔵 Informational Alerts (Severity 3)
- Total Requests Volume
- Metadata Requests
- Index Usage

### 📋 Administrative Alerts
- Account Deletion
- Configuration Changes
- Failover Operations

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure Cosmos DB account(s)
- Azure Monitor Action Group (pre-configured)
- Appropriate permissions to create Monitor alerts
- **Cosmos DB account names** must be provided

## Usage

### Basic Example

```hcl
module "cosmos_alerts" {
  source = "./modules/metricAlerts/cosmos"

  # Resource Configuration
  resource_group_name              = "rg-cosmos-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"

  # Cosmos DB Accounts to Monitor
  cosmos_account_names = [
    "cosmos-app-prod",
    "cosmos-users-prod"
  ]

  # Tags
  tags = {
    Environment         = "Production"
    AppId              = "123456"
    CRIS               = "1"
    Compliance         = "SOX"
    DataClassification = "internal"
    Env                = "Prod"
    Notify             = "ops-team@pge.com"
    Owner              = "platform-team@pge.com"
    order              = "123456"
  }
}
```

### Production Example with Custom Thresholds

```hcl
module "cosmos_alerts_production" {
  source = "./modules/metricAlerts/cosmos"

  # Resource Configuration
  resource_group_name              = "rg-cosmos-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-alerts-actiongroup"

  # Cosmos DB Accounts
  cosmos_account_names = [
    "cosmos-app-prod",
    "cosmos-users-prod",
    "cosmos-analytics-prod"
  ]

  # Stricter Thresholds for Production
  cosmos_availability_threshold              = 99.95  # Higher availability requirement
  cosmos_server_side_latency_threshold       = 5      # Lower latency tolerance (5ms)
  cosmos_normalized_ru_consumption_threshold = 70     # Earlier throttling warning (70%)
  cosmos_ru_consumption_threshold            = 50000  # Higher RU threshold
  cosmos_data_usage_threshold                = 107374182400  # 100 GB
  cosmos_provisioned_throughput_threshold    = 80000  # Higher throughput

  # Enable All Alerts
  enable_availability_alerts   = true
  enable_performance_alerts    = true
  enable_error_alerts          = true
  enable_capacity_alerts       = true
  enable_activity_log_alerts   = true

  tags = {
    Environment     = "Production"
    CriticalityTier = "Tier1"
    CostCenter      = "Engineering"
  }
}
```

### Selective Alert Monitoring Example

```hcl
module "cosmos_alerts_selective" {
  source = "./modules/metricAlerts/cosmos"

  resource_group_name              = "rg-cosmos-dev"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-alerts-actiongroup"

  cosmos_account_names = ["cosmos-dev"]

  # Enable only critical alerts for development
  enable_availability_alerts   = true   # Monitor availability
  enable_performance_alerts    = true   # Monitor performance
  enable_error_alerts          = true   # Monitor throttling
  enable_capacity_alerts       = false  # Skip capacity alerts in dev
  enable_activity_log_alerts   = false  # Skip admin alerts in dev

  # More lenient thresholds for dev
  cosmos_normalized_ru_consumption_threshold = 90   # Allow higher usage
  cosmos_server_side_latency_threshold       = 20   # More tolerant latency

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

### Multi-Account Enterprise Example

```hcl
module "cosmos_alerts_enterprise" {
  source = "./modules/metricAlerts/cosmos"

  resource_group_name              = "rg-monitoring"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"

  # Monitor multiple Cosmos DB accounts
  cosmos_account_names = [
    "cosmos-customers-prod",
    "cosmos-orders-prod",
    "cosmos-inventory-prod",
    "cosmos-analytics-prod",
    "cosmos-sessions-prod"
  ]

  # Fine-tuned thresholds
  cosmos_availability_threshold              = 99.99  # Five nines
  cosmos_server_side_latency_threshold       = 10
  cosmos_normalized_ru_consumption_threshold = 75
  cosmos_total_requests_threshold            = 50000  # High-volume workload
  cosmos_metadata_requests_threshold         = 200

  tags = {
    Environment = "Production"
    Scope       = "Enterprise"
    Service     = "CosmosDB"
  }
}
```

### Serverless Cosmos DB Example

```hcl
module "cosmos_alerts_serverless" {
  source = "./modules/metricAlerts/cosmos"

  resource_group_name              = "rg-cosmos-serverless"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "serverless-alerts-actiongroup"

  cosmos_account_names = ["cosmos-serverless-app"]

  # Adjust for serverless consumption model
  cosmos_availability_threshold              = 99.9
  cosmos_server_side_latency_threshold       = 15
  cosmos_normalized_ru_consumption_threshold = 85   # Less critical for serverless
  cosmos_total_requests_threshold            = 20000

  # Disable provisioned throughput alert (not applicable to serverless)
  enable_capacity_alerts = false

  tags = {
    Environment   = "Production"
    BillingModel  = "Serverless"
    CostOptimized = "true"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `cosmos_account_names` | `list(string)` | **REQUIRED** - List of Cosmos DB account names to monitor (empty list = no alerts created) |

### Core Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where Cosmos DB accounts are located |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group name for alert notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
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
| `enable_availability_alerts` | `bool` | `true` | Enable availability monitoring |
| `enable_performance_alerts` | `bool` | `true` | Enable performance monitoring (latency, RU) |
| `enable_error_alerts` | `bool` | `true` | Enable error monitoring (throttling) |
| `enable_capacity_alerts` | `bool` | `true` | Enable capacity monitoring (data, index usage) |
| `enable_activity_log_alerts` | `bool` | `true` | Enable administrative operation monitoring |

### Threshold Variables

#### Availability & Performance

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cosmos_availability_threshold` | `number` | `99.9` | Service availability percentage threshold |
| `cosmos_server_side_latency_threshold` | `number` | `10` | Server-side latency in milliseconds |
| `cosmos_normalized_ru_consumption_threshold` | `number` | `80` | Normalized RU consumption percentage (0-100) |

#### Capacity & Usage

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cosmos_ru_consumption_threshold` | `number` | `10000` | Total Request Units consumed |
| `cosmos_provisioned_throughput_threshold` | `number` | `40000` | Provisioned throughput in RU/s |
| `cosmos_data_usage_threshold` | `number` | `85899345920` | Data usage in bytes (80 GB default) |
| `cosmos_index_usage_threshold` | `number` | `10737418240` | Index usage in bytes (10 GB default) |

#### Request Volume

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cosmos_total_requests_threshold` | `number` | `10000` | Total request count threshold |
| `cosmos_metadata_requests_threshold` | `number` | `100` | Metadata request count threshold |

## Alert Details

### Metric Alerts

#### 1. Service Availability
- **Metric**: `ServiceAvailability`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Average
- **Operator**: LessThan
- **Threshold**: 99.9% (default)
- **Frequency**: Every 1 hour
- **Window Size**: 1 hour
- **Severity**: 1 (Error)
- **Description**: Monitors Cosmos DB service availability. Triggers when availability drops below threshold, indicating potential service disruption.

**When to Adjust**:
- **Production**: Set to 99.95% or 99.99% for critical workloads
- **Development**: Set to 99% for cost optimization

#### 2. Server Side Latency
- **Metric**: `ServerSideLatency`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Average
- **Operator**: GreaterThan
- **Threshold**: 10 ms (default)
- **Frequency**: Every 1 minute
- **Window Size**: 5 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors server-side latency for Cosmos DB operations. High latency indicates performance degradation or query inefficiencies.

**When to Adjust**:
- **Low-latency apps**: Set to 5ms for real-time applications
- **Batch workloads**: Set to 20ms for less time-sensitive operations
- **Global distribution**: Consider regional latency differences

#### 3. Request Units (RU) Consumption
- **Metric**: `TotalRequestUnits`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Total
- **Operator**: GreaterThan
- **Threshold**: 10,000 RUs (default)
- **Frequency**: Every 5 minutes
- **Window Size**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors total RU consumption over time. High consumption indicates increased workload or inefficient queries.

**When to Adjust**:
- **High-throughput apps**: Increase to 50,000+ based on provisioned capacity
- **Small workloads**: Decrease to 5,000 for cost awareness
- **Autoscale**: Adjust based on max autoscale RU/s

#### 4. Normalized RU Consumption (CRITICAL)
- **Metric**: `NormalizedRUConsumption`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Maximum
- **Operator**: GreaterThan
- **Threshold**: 80% (default)
- **Frequency**: Every 1 minute
- **Window Size**: 5 minutes
- **Severity**: 0 (Critical)
- **Description**: **MOST IMPORTANT ALERT** - Monitors RU consumption as a percentage of provisioned throughput. Values above 100% indicate throttling (429 errors). This is the primary indicator of application performance issues.

**When to Adjust**:
- **Production**: Set to 70% for early warning, consider autoscale
- **Burst traffic**: Set to 85-90% if autoscale is enabled
- **Development**: Set to 90% for cost optimization

**Throttling Response**:
```
70-79%: Monitor closely, consider scaling
80-89%: Prepare to scale up
90-99%: Scale up recommended
100%+:  Throttling occurring, immediate action required
```

#### 5. Total Requests Volume
- **Metric**: `TotalRequests`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Count
- **Operator**: GreaterThan
- **Threshold**: 10,000 requests (default)
- **Frequency**: Every 5 minutes
- **Window Size**: 15 minutes
- **Severity**: 3 (Informational)
- **Description**: Monitors total request volume. Useful for detecting traffic spikes, DDoS attempts, or unexpected usage patterns.

**When to Adjust**:
- **High-volume apps**: Increase to 50,000+ based on typical load
- **Low-traffic apps**: Decrease to 5,000 for anomaly detection
- **API gateways**: Set based on expected API call volume

#### 6. Metadata Requests
- **Metric**: `MetadataRequests`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Count
- **Operator**: GreaterThan
- **Threshold**: 100 requests (default)
- **Frequency**: Every 5 minutes
- **Window Size**: 15 minutes
- **Severity**: 3 (Informational)
- **Description**: Monitors metadata operations (list collections, describe database). High metadata requests can indicate SDK issues, connection pooling problems, or application design issues.

**When to Adjust**:
- **Development**: Higher threshold (200+) during active development
- **Production**: Lower threshold (50) to detect SDK issues
- **SDKs < v3**: Legacy SDKs make more metadata calls

**Common Causes**:
- Creating new client instances per request
- Not using connection pooling
- Frequent collection/database listing operations

#### 7. Data Usage
- **Metric**: `DataUsage`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Total
- **Operator**: GreaterThan
- **Threshold**: 85,899,345,920 bytes (80 GB default)
- **Frequency**: Every 15 minutes
- **Window Size**: 1 hour
- **Severity**: 2 (Warning)
- **Description**: Monitors total data storage usage. Important for capacity planning and cost management.

**When to Adjust**:
- **Large databases**: Set to 80% of expected maximum (e.g., 400 GB for 500 GB limit)
- **Small databases**: Set to 10-20 GB for early warning
- **Serverless**: Set based on data retention policies

#### 8. Index Usage
- **Metric**: `IndexUsage`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Total
- **Operator**: GreaterThan
- **Threshold**: 10,737,418,240 bytes (10 GB default)
- **Frequency**: Every 15 minutes
- **Window Size**: 1 hour
- **Severity**: 3 (Informational)
- **Description**: Monitors index storage usage. High index usage can indicate over-indexing or inefficient indexing policies.

**When to Adjust**:
- **Complex queries**: Higher threshold if extensive indexing is required
- **Simple queries**: Lower threshold to detect unnecessary indexes
- **Cost optimization**: Monitor for index policy optimization opportunities

**Optimization Tips**:
- Review indexing policy for unused paths
- Exclude unnecessary properties from indexing
- Use composite indexes for common query patterns

#### 9. Provisioned Throughput
- **Metric**: `ProvisionedThroughput`
- **Namespace**: `Microsoft.DocumentDB/databaseAccounts`
- **Aggregation**: Maximum
- **Operator**: GreaterThan
- **Threshold**: 40,000 RU/s (default)
- **Frequency**: Every 5 minutes
- **Window Size**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors provisioned throughput levels. Useful for tracking capacity changes and cost management.

**When to Adjust**:
- **Manual throughput**: Set to current provisioned value for change detection
- **Autoscale**: Set to max autoscale RU/s
- **Serverless**: Disable this alert (not applicable)

### Activity Log Alerts

#### 10. Cosmos DB Account Deletion
- **Operation**: `Microsoft.DocumentDB/databaseAccounts/delete`
- **Category**: Administrative
- **Scope**: Subscription
- **Description**: Triggers when a Cosmos DB account is deleted. Critical for preventing accidental data loss and ensuring compliance with data retention policies.

**Response Actions**:
- Verify deletion was intentional
- Check if backups exist
- Review RBAC permissions
- Investigate if unintended

#### 11. Cosmos DB Account Configuration Change
- **Operation**: `Microsoft.DocumentDB/databaseAccounts/write`
- **Category**: Administrative
- **Scope**: Subscription
- **Description**: Monitors configuration changes to Cosmos DB accounts including consistency level, failover policy, backup policy, and firewall rules.

**Common Changes**:
- Consistency level modifications
- Geo-replication settings
- Backup policy updates
- Firewall rule changes
- Virtual network configuration

#### 12. Cosmos DB Failover
- **Operation**: `Microsoft.DocumentDB/databaseAccounts/failoverPriorityChange/action`
- **Category**: Administrative
- **Scope**: Subscription
- **Description**: Triggers when a manual or automatic failover occurs. Important for tracking regional availability and disaster recovery events.

**Response Actions**:
- Verify application connectivity to new region
- Check for data synchronization issues
- Review failover logs
- Update monitoring dashboards

## Best Practices

### 1. Cosmos DB Account Configuration

```hcl
# Always provide account names
cosmos_account_names = [
  "cosmos-prod-001",
  "cosmos-prod-002"
]

# Empty list = no alerts created
cosmos_account_names = []  # Avoid this in production
```

### 2. Normalized RU Consumption Monitoring (CRITICAL)

```hcl
# Production: Early warning for throttling
cosmos_normalized_ru_consumption_threshold = 70  # Alert at 70%

# Enable autoscale or increase provisioned throughput before reaching 100%
# 100% = throttling = 429 errors = application failures

# Evaluation frequency is critical
# Alert checks every 1 minute with 5-minute window for fast detection
```

### 3. Performance Optimization Based on Alerts

#### High Server-Side Latency
```hcl
# If latency > threshold:
# 1. Review query patterns (use query metrics)
# 2. Add composite indexes for common queries
# 3. Optimize partition key selection
# 4. Consider reducing document size
# 5. Check cross-partition query usage
```

#### High RU Consumption
```hcl
# If RU consumption > threshold:
# 1. Analyze query costs using request charge
# 2. Implement caching strategy
# 3. Optimize indexing policy
# 4. Use stored procedures for bulk operations
# 5. Consider autoscale if traffic is spiky
```

### 4. Capacity Planning

```hcl
# Data Usage Alert Strategy
cosmos_data_usage_threshold = 429496729600  # 400 GB

# Set to 80% of anticipated maximum
# Provides lead time to:
# - Archive old data
# - Increase storage limits
# - Implement data retention policies
```

### 5. Multi-Region Deployments

```hcl
# For globally distributed Cosmos DB:
# - Monitor all regional accounts
# - Set availability threshold to 99.99%
# - Enable failover alerts
# - Consider regional latency variations

cosmos_availability_threshold = 99.99
enable_activity_log_alerts   = true  # Track failovers

# Expect higher latency for cross-region writes
cosmos_server_side_latency_threshold = 20  # Adjust for global writes
```

### 6. Development vs Production Thresholds

```hcl
# Production
module "cosmos_prod" {
  cosmos_availability_threshold              = 99.95
  cosmos_server_side_latency_threshold       = 10
  cosmos_normalized_ru_consumption_threshold = 70
  enable_activity_log_alerts                = true
}

# Development
module "cosmos_dev" {
  cosmos_availability_threshold              = 99.0
  cosmos_server_side_latency_threshold       = 20
  cosmos_normalized_ru_consumption_threshold = 90
  enable_activity_log_alerts                = false
  enable_capacity_alerts                    = false
}
```

### 7. Cost Optimization

```hcl
# Monitor RU consumption to optimize costs
cosmos_ru_consumption_threshold = 50000

# High RU consumption may indicate:
# - Need for query optimization (reduce cost)
# - Need for throughput increase (improve performance)
# - Opportunity to use autoscale or serverless

# Data usage monitoring
cosmos_data_usage_threshold = 107374182400  # 100 GB

# Implement data retention policies to control costs
# Archive old data to Azure Storage (much cheaper)
```

### 8. Metadata Request Optimization

```hcl
# High metadata requests indicate SDK issues
cosmos_metadata_requests_threshold = 100

# Best practices to reduce metadata requests:
# - Use singleton pattern for CosmosClient
# - Implement connection pooling
# - Cache collection references
# - Use SDK v3+ which reduces metadata calls
```

## Troubleshooting

### Common Issues

#### 1. No Alerts Being Created

**Problem**: No alerts appear in Azure Monitor.

**Solution**:
```hcl
# Ensure cosmos_account_names is not empty
cosmos_account_names = ["cosmos-prod-001"]  # REQUIRED

# Verify account names are correct
# Account must exist in the specified resource_group_name

# Check action group exists
action_group_resource_group_name = "rg-monitoring"
action_group                     = "existing-action-group"
```

**Validation**:
```bash
# Verify Cosmos DB account exists
az cosmosdb show \
  --name "cosmos-prod-001" \
  --resource-group "rg-cosmos-production"

# List all Cosmos DB accounts in resource group
az cosmosdb list \
  --resource-group "rg-cosmos-production" \
  --query "[].name"
```

#### 2. Normalized RU Consumption Alert Not Triggering During Throttling

**Problem**: Application experiencing 429 errors but alert not firing.

**Diagnostics**:
```bash
# Check if metric is available
az monitor metrics list-definitions \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.DocumentDB/databaseAccounts/{account}" \
  --query "[?name.value=='NormalizedRUConsumption']"

# Query metric values
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.DocumentDB/databaseAccounts/{account}" \
  --metric "NormalizedRUConsumption" \
  --start-time 2025-11-24T00:00:00Z \
  --end-time 2025-11-24T23:59:59Z \
  --aggregation Maximum
```

**Solution**:
```hcl
# Lower threshold for earlier warning
cosmos_normalized_ru_consumption_threshold = 70  # Alert at 70% instead of 80%

# Verify alert is enabled
# Check that alert resource was created
```

#### 3. High False Positives for Latency Alerts

**Problem**: Latency alerts triggering during normal operations.

**Solution**:
```hcl
# Adjust threshold based on observed baseline
cosmos_server_side_latency_threshold = 15  # Increase from 10ms

# Or increase window size for more stable alerting
# Current: PT1M frequency, PT5M window
# Consider: PT5M frequency, PT15M window for less sensitive detection
```

**Analysis**:
```bash
# Review latency patterns
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.DocumentDB/databaseAccounts/{account}" \
  --metric "ServerSideLatency" \
  --aggregation Average \
  --interval PT1M
```

#### 4. Data Usage Alert Not Accurate

**Problem**: Data usage alert showing unexpected values.

**Solution**:
```bash
# Check actual data usage in portal or via metrics
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.DocumentDB/databaseAccounts/{account}" \
  --metric "DataUsage" \
  --aggregation Total

# Verify threshold is in bytes (not GB)
# 1 GB = 1,073,741,824 bytes
# 80 GB = 85,899,345,920 bytes
```

```hcl
# Correct threshold in bytes
cosmos_data_usage_threshold = 85899345920  # 80 GB

# Common mistake: using GB value
cosmos_data_usage_threshold = 80  # WRONG - this is 80 bytes!
```

#### 5. Activity Log Alerts Not Triggering

**Problem**: Administrative operation alerts not firing.

**Solution**:
```hcl
# Verify activity log alerts are enabled
enable_activity_log_alerts = true

# Ensure cosmos_account_names is not empty
cosmos_account_names = ["cosmos-prod-001"]

# Activity log alerts require subscription-level scope
# Verify you have Reader permissions on subscription
```

**Validation**:
```bash
# Check activity log for operations
az monitor activity-log list \
  --resource-group "rg-cosmos-production" \
  --offset 1d \
  --query "[?contains(resourceType, 'Microsoft.DocumentDB')]"

# Verify alert exists
az monitor activity-log alert list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'cosmos')]"
```

#### 6. Metadata Requests Alert Firing Frequently

**Problem**: Constant metadata request alerts.

**Root Causes**:
- Creating new CosmosClient per request
- Not using connection pooling
- SDK version issues

**Solution**:
```csharp
// ❌ WRONG - Creates new client per request
public async Task<Item> GetItem(string id)
{
    var client = new CosmosClient(connectionString);  // Anti-pattern
    var container = client.GetContainer("db", "container");
    return await container.ReadItemAsync<Item>(id, new PartitionKey(id));
}

// ✅ CORRECT - Singleton client
private static readonly CosmosClient _cosmosClient = new CosmosClient(connectionString);

public async Task<Item> GetItem(string id)
{
    var container = _cosmosClient.GetContainer("db", "container");
    return await container.ReadItemAsync<Item>(id, new PartitionKey(id));
}
```

```hcl
# Adjust threshold if application design requires more metadata calls
cosmos_metadata_requests_threshold = 200
```

#### 7. Alert Firing During Scale Operations

**Problem**: Provisioned throughput alert triggers during planned scaling.

**Solution**:
```hcl
# Temporarily disable alerts during maintenance
enable_capacity_alerts = false  # Before scaling operation

# Or adjust threshold to account for scale-up operations
cosmos_provisioned_throughput_threshold = 100000  # Higher than max expected

# Re-enable after maintenance
enable_capacity_alerts = true
```

### Validation Commands

```bash
# Verify Terraform configuration
terraform init
terraform validate
terraform plan

# List Cosmos DB accounts
az cosmosdb list \
  --resource-group "rg-cosmos-production" \
  --output table

# List all metric alerts
az monitor metrics alert list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'cosmos')].{Name:name, Enabled:enabled, Severity:severity}"

# List activity log alerts
az monitor activity-log alert list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'cosmos')].{Name:name, Enabled:enabled}"

# Test action group
az monitor action-group test-notifications create \
  --action-group "pge-operations-actiongroup" \
  --resource-group "rg-monitoring" \
  --notification-type "Email"

# Query specific metrics
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.DocumentDB/databaseAccounts/{account}" \
  --metric "NormalizedRUConsumption" \
  --aggregation Maximum \
  --interval PT5M

# Check account properties
az cosmosdb show \
  --name "cosmos-prod-001" \
  --resource-group "rg-cosmos-production"

# List databases and containers
az cosmosdb sql database list \
  --account-name "cosmos-prod-001" \
  --resource-group "rg-cosmos-production"

az cosmosdb sql container list \
  --account-name "cosmos-prod-001" \
  --database-name "mydb" \
  --resource-group "rg-cosmos-production"
```

### Debug Mode

```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform apply

# Check Terraform state
terraform state list | grep cosmos
terraform state show module.cosmos_alerts.azurerm_monitor_metric_alert.cosmos_normalized_ru_consumption[\"cosmos-prod-001\"]

# View alert configuration in Azure
az monitor metrics alert show \
  --name "cosmos-normalized-ru-consumption-cosmos-prod-001" \
  --resource-group "rg-amba"
```

### Performance Analysis Queries (Log Analytics/KQL)

```kql
// Query throttled requests
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DOCUMENTDB"
| where statusCode_s == "429"
| summarize ThrottledRequests=count() by bin(TimeGenerated, 5m), DatabaseName_s
| order by TimeGenerated desc

// Query high RU consumption operations
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DOCUMENTDB"
| where requestCharge_s > 100
| project TimeGenerated, OperationName, requestCharge_s, DatabaseName_s, CollectionName_s
| order by requestCharge_s desc

// Query slow operations
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DOCUMENTDB"
| where duration_s > 100  // Operations > 100ms
| summarize count() by bin(TimeGenerated, 5m), OperationName
```

## Alert Severity Mapping

| Severity | Level | Use Case | Response Time | Action Required |
|----------|-------|----------|---------------|-----------------|
| 0 | Critical | Throttling occurring | Immediate | Scale up RUs, optimize queries |
| 1 | Error | Service degradation | < 15 minutes | Investigate availability issues |
| 2 | Warning | Performance/capacity concerns | < 1 hour | Review metrics, plan scaling |
| 3 | Informational | Usage patterns, trends | Business hours | Optimize, plan capacity |

**This Module's Severity Distribution:**
- **Severity 0 (Critical)**: Normalized RU Consumption (throttling)
- **Severity 1 (Error)**: Service Availability
- **Severity 2 (Warning)**: Server Side Latency, RU Consumption, Data Usage, Provisioned Throughput
- **Severity 3 (Informational)**: Total Requests, Metadata Requests, Index Usage
- **Activity Log Alerts**: Administrative operations (no numeric severity)

## Performance Considerations

### Alert Evaluation Frequency

| Alert | Frequency | Window | Evaluations/Hour | Impact |
|-------|-----------|--------|------------------|--------|
| Availability | PT1H | PT1H | 1 | Low |
| Server Side Latency | PT1M | PT5M | 60 | Medium |
| RU Consumption | PT5M | PT15M | 12 | Low |
| Normalized RU | PT1M | PT5M | 60 | Medium |
| Total Requests | PT5M | PT15M | 12 | Low |
| Metadata Requests | PT5M | PT15M | 12 | Low |
| Data Usage | PT15M | PT1H | 4 | Very Low |
| Index Usage | PT15M | PT1H | 4 | Very Low |
| Provisioned Throughput | PT5M | PT15M | 12 | Low |

**Total per Account**: ~179 metric evaluations/hour (minimal Azure Monitor cost impact)

## Cost Optimization

### Alert Pricing (2025)

- **Metric Alerts**: $0.10 per alert per month
- **Activity Log Alerts**: Free
- **Total Module Cost per Cosmos DB Account**:
  - 9 metric alerts × $0.10 = $0.90/month
  - 3 activity log alerts × $0 = $0/month
  - **Total: ~$0.90/month per account**

### Multi-Account Cost Example

```hcl
# 5 Cosmos DB accounts
cosmos_account_names = [
  "cosmos-app-prod",
  "cosmos-users-prod",
  "cosmos-analytics-prod",
  "cosmos-inventory-prod",
  "cosmos-sessions-prod"
]

# Cost: 5 accounts × $0.90 = $4.50/month for monitoring
# Activity log alerts (3) = $0 (shared across accounts)
```

### Cost Reduction Strategies

```hcl
# Disable non-critical alerts in dev/test
enable_capacity_alerts     = false  # Save $0.30/account
enable_activity_log_alerts = false  # Already free

# Reduce evaluation frequency for non-critical alerts
# (Note: Not configurable in this module, but could be customized)

# Consolidate action groups
# Reuse existing action groups across modules
action_group = "shared-actiongroup"  # No additional cost

# Selective monitoring
cosmos_account_names = ["cosmos-prod"]  # Monitor only production
```

## Integration with Cosmos DB Best Practices

### 1. Partition Key Design
- Monitor normalized RU consumption to identify hot partitions
- High consumption on specific operations may indicate poor partition key choice
- Use query metrics to identify cross-partition queries

### 2. Indexing Policy
- Monitor index usage to optimize indexing policies
- Exclude unnecessary paths from indexing to reduce RU consumption
- Use composite indexes for common query patterns

### 3. Consistency Levels
- Strong consistency: Expect higher latency (2x read RUs)
- Session consistency: Balanced performance and consistency
- Eventual consistency: Lowest latency and RU cost

### 4. Request Unit Optimization
```
Read 1 KB document: ~1 RU
Write 1 KB document: ~5 RUs
Query (depends on complexity): 1-100+ RUs
Stored procedure: Varies by logic
```

### 5. Autoscale vs Provisioned Throughput
```hcl
# Manual provisioned: Set specific normalized RU threshold
cosmos_normalized_ru_consumption_threshold = 70

# Autoscale: More lenient threshold (scales automatically)
cosmos_normalized_ru_consumption_threshold = 85
```

## Additional Resources

- [Azure Cosmos DB Documentation](https://learn.microsoft.com/azure/cosmos-db/)
- [Cosmos DB Performance Tips](https://learn.microsoft.com/azure/cosmos-db/performance-tips)
- [Cosmos DB Monitoring](https://learn.microsoft.com/azure/cosmos-db/monitor-cosmos-db)
- [Request Units in Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/request-units)
- [Partitioning in Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/partitioning-overview)
- [Cosmos DB Best Practices](https://learn.microsoft.com/azure/cosmos-db/sql/best-practice-dotnet)

## License

This module follows your organization's licensing terms.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-11-24 | Initial release with 12 alerts (9 metric + 3 activity log) |

---

**Last Updated**: November 24, 2025  
**Module Version**: 1.0.0  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
