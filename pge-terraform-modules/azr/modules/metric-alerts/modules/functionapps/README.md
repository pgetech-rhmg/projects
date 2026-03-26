# Azure Function Apps Monitoring Alerts - Terraform Module

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Production Configuration](#production-configuration)
  - [Multi-Platform Deployment](#multi-platform-deployment)
  - [Windows-Only Configuration](#windows-only-configuration)
  - [Selective Alert Configuration](#selective-alert-configuration)
- [Input Variables](#input-variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
  - [Alert Configuration Variables](#alert-configuration-variables)
- [Alert Details](#alert-details)
  - [Function Execution Alerts](#function-execution-alerts)
  - [Performance Alerts](#performance-alerts)
  - [Error Detection Alerts](#error-detection-alerts)
  - [Resource Utilization Alerts](#resource-utilization-alerts)
  - [Activity Log Alerts](#activity-log-alerts)
  - [Scheduled Query Rules](#scheduled-query-rules)
- [Alert Severity Levels](#alert-severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
  - [Function App Design](#function-app-design)
  - [Performance Optimization](#performance-optimization)
  - [Error Handling](#error-handling)
  - [Resource Management](#resource-management)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Validation Commands](#validation-commands)
- [License](#license)

---

## Overview

This Terraform module provides comprehensive monitoring and alerting for **Azure Function Apps**, Microsoft's serverless compute service that enables event-driven, scalable code execution without managing infrastructure. Function Apps support both Windows and Linux hosting, multiple programming languages (.NET, Node.js, Python, Java, PowerShell), and various trigger types (HTTP, Timer, Queue, Event Hub, Blob, etc.).

The module implements the **Azure Monitor Baseline Alerts (AMBA)** best practices specifically tailored for both Windows and Linux Function Apps, covering:
- **Function execution monitoring** - Execution count, execution units (GB-seconds)
- **Performance monitoring** - Response time, memory usage, CPU utilization
- **Error detection** - HTTP 4xx/5xx errors, exceptions
- **Resource utilization** - Memory working set, IO operations, private bytes
- **Garbage collection** - .NET GC monitoring (Windows apps only)
- **Administrative monitoring** - Creation, deletion, configuration changes
- **Availability monitoring** - Function app stopped detection

**Key Capabilities:**
- Monitors both Windows and Linux Function Apps
- Tracks serverless execution metrics (execution count and cost)
- Detects performance degradation and memory issues
- Identifies error patterns and availability problems
- Monitors .NET garbage collection (Windows)
- Tracks administrative changes and security events
- Supports Consumption, Premium, and Dedicated (App Service) plans

This module is essential for organizations running serverless workloads, event-driven architectures, microservices, API backends, scheduled jobs, and integration workflows.

---

## Key Features

- **✅ 18 Comprehensive Alerts** - Execution, performance, errors, resources, and administrative monitoring
- **✅ Cross-Platform Support** - Works with both Windows and Linux Function Apps
- **✅ 2 Function Execution Alerts** - Execution count and execution units (cost tracking)
- **✅ 3 Performance Alerts** - Response time (warning + critical), memory working set
- **✅ 2 Error Alerts** - HTTP 5xx (server errors), HTTP 4xx (client errors)
- **✅ 7 Resource Utilization Alerts** - Memory, IO operations, GC collections
- **✅ 3 Activity Log Alerts** - Creation, deletion, configuration changes
- **✅ 1 Scheduled Query Alert** - Function app stopped detection
- **✅ .NET Garbage Collection Monitoring** - Gen 0, 1, 2 collections (Windows only)
- **✅ Multi-Tier Support** - Consumption, Premium, Dedicated plans
- **✅ Customizable Thresholds** - All alert thresholds are configurable per environment
- **✅ Production-Ready** - Follows Azure AMBA guidelines for enterprise deployments

---

## Prerequisites

Before using this module, ensure you have:

1. **Terraform >= 1.0** installed
2. **Azure Provider >= 3.0** configured
3. **Existing Azure Function App(s)** deployed (Windows or Linux)
4. **Azure Monitor Action Group** created for alert notifications
5. **Appropriate Azure RBAC permissions**:
   - `Monitoring Contributor` role on the resource group
   - `Reader` role on Function Apps
   - Access to the action group for notifications

6. **Function App Requirements**:
   - Function App deployed (Windows or Linux)
   - Hosting plan configured (Consumption, Premium, or Dedicated)
   - Application Insights enabled (recommended for detailed monitoring)
   - Functions deployed and receiving traffic

---

## Module Structure

```
functionapps/
├── alerts.tf       # Function App metric and activity log alert definitions
├── variables.tf    # Input variable definitions
└── README.md       # This documentation file
```

---

## Usage

### Basic Usage

```hcl
module "functionapp_alerts" {
  source = "./modules/metricAlerts/functionapps"

  # Windows Function Apps
  windows_function_app_names         = ["func-orders-prod"]
  resource_group_name                = "rg-functions-production"

  # Action group configuration
  action_group                       = "functions-ops-actiongroup"
  action_group_resource_group_name   = "rg-monitoring"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Order-Processing"
    CostCenter         = "Engineering"
    DataClassification = "Internal"
    Owner              = "functions-team@company.com"
  }
}
```

### Production Configuration

```hcl
module "functionapp_alerts_prod" {
  source = "./modules/metricAlerts/functionapps"

  # Windows Function Apps
  windows_function_app_names = [
    "func-api-gateway-prod",
    "func-order-processor-prod",
    "func-notifications-prod"
  ]

  # Linux Function Apps
  linux_function_app_names = [
    "func-python-analytics-prod",
    "func-nodejs-webhook-prod"
  ]

  resource_group_name                = "rg-functions-production"
  subscription_ids                   = ["12345678-1234-1234-1234-123456789012"]

  # Action groups
  action_group                       = "functions-critical-alerts"
  action_group_resource_group_name   = "rg-monitoring-prod"

  # Enable all alert categories
  enable_function_execution_alerts   = true
  enable_performance_alerts          = true
  enable_error_alerts                = true
  enable_resource_alerts             = true
  enable_activity_log_alerts         = true

  # Function Execution Thresholds
  function_execution_count_threshold = 10000   # 10K executions per 15 min
  function_execution_units_threshold = 100000  # 100K GB-seconds

  # Performance Thresholds
  response_time_threshold            = 3       # 3 seconds warning
  response_time_critical_threshold   = 10      # 10 seconds critical
  average_memory_working_set_threshold = 2147483648  # 2GB

  # Error Thresholds
  http_5xx_threshold                 = 5       # Server errors
  http_4xx_threshold                 = 50      # Client errors

  # Resource Thresholds
  memory_working_set_threshold       = 2147483648  # 2GB
  io_read_ops_threshold              = 200
  io_write_ops_threshold             = 200
  private_bytes_threshold            = 2147483648  # 2GB

  # GC Thresholds (Windows .NET apps)
  gen_0_collections_threshold        = 500
  gen_1_collections_threshold        = 100
  gen_2_collections_threshold        = 20

  # Request Volume
  requests_threshold                 = 10000

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Serverless-Platform"
    CostCenter         = "Operations"
    Compliance         = "SOC2"
    DR                 = "Critical"
    Owner              = "platform-team@company.com"
    AlertingSLA        = "24x7"
  }
}
```

### Multi-Platform Deployment

```hcl
module "functionapp_alerts_multi_platform" {
  source = "./modules/metricAlerts/functionapps"

  # Windows Function Apps (.NET, C#, PowerShell)
  windows_function_app_names = [
    "func-dotnet-api-prod",
    "func-csharp-queue-processor",
    "func-powershell-automation"
  ]

  # Linux Function Apps (Python, Node.js, Java)
  linux_function_app_names = [
    "func-python-ml-inference",
    "func-nodejs-webhook",
    "func-java-batch-processor"
  ]

  resource_group_name                = "rg-functions-global"
  subscription_ids                   = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]

  # Tiered action groups
  action_group                       = "functions-pagerduty"
  action_group_resource_group_name   = "rg-alerting"

  # Aggressive thresholds for production
  function_execution_count_threshold = 50000
  function_execution_units_threshold = 500000
  response_time_threshold            = 2       # 2 seconds
  response_time_critical_threshold   = 5       # 5 seconds critical
  http_5xx_threshold                 = 1       # Zero tolerance
  http_4xx_threshold                 = 100

  # High-frequency evaluation for critical alerts
  evaluation_frequency_high          = "PT1M"
  window_duration_short              = "PT5M"

  tags = {
    Environment        = "Production"
    Application        = "Multi-Platform-Functions"
    BusinessUnit       = "Engineering"
    CostCenter         = "Platform"
    Compliance         = "SOC2,HIPAA"
    DataClassification = "Confidential"
    DR                 = "Mission-Critical"
    Owner              = "serverless-team@company.com"
    SLA                = "99.95"
  }
}
```

### Windows-Only Configuration

```hcl
module "functionapp_alerts_windows" {
  source = "./modules/metricAlerts/functionapps"

  # Windows Function Apps only
  windows_function_app_names = [
    "func-dotnet6-api",
    "func-csharp-isolated",
    "func-powershell-v7"
  ]

  resource_group_name                = "rg-windows-functions"

  action_group                       = "dotnet-team-alerts"
  action_group_resource_group_name   = "rg-monitoring"

  # Enable .NET-specific monitoring
  enable_resource_alerts             = true  # Includes GC monitoring

  # .NET Garbage Collection thresholds
  gen_0_collections_threshold        = 300   # Gen 0 (young generation)
  gen_1_collections_threshold        = 80    # Gen 1 (mid generation)
  gen_2_collections_threshold        = 15    # Gen 2 (old generation) - most expensive

  # Standard thresholds
  response_time_threshold            = 5
  http_5xx_threshold                 = 5
  memory_working_set_threshold       = 1073741824  # 1GB

  tags = {
    Environment = "Production"
    Application = "DotNet-Functions"
    Platform    = "Windows"
    Owner       = "dotnet-team@company.com"
  }
}
```

### Selective Alert Configuration

```hcl
module "functionapp_alerts_dev" {
  source = "./modules/metricAlerts/functionapps"

  # Development Function Apps
  windows_function_app_names         = ["func-dev-api"]
  linux_function_app_names           = ["func-dev-python"]
  resource_group_name                = "rg-functions-dev"

  action_group                       = "dev-team-alerts"
  action_group_resource_group_name   = "rg-monitoring-dev"

  # Enable only critical alerts for dev
  enable_function_execution_alerts   = true
  enable_performance_alerts          = true
  enable_error_alerts                = true
  enable_resource_alerts             = false   # Disable for dev
  enable_activity_log_alerts         = false   # Not needed in dev

  # Relaxed thresholds for development
  function_execution_count_threshold = 1000
  function_execution_units_threshold = 10000
  response_time_threshold            = 10      # 10 seconds
  response_time_critical_threshold   = 30      # 30 seconds
  http_5xx_threshold                 = 20
  http_4xx_threshold                 = 100
  requests_threshold                 = 1000

  tags = {
    Environment = "Development"
    Application = "Function-Testing"
    CostCenter  = "Engineering"
    Owner       = "dev-team@company.com"
  }
}
```

---

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `windows_function_app_names` | `list(string)` | List of Windows Function App names to monitor (leave empty if none) |
| `linux_function_app_names` | `list(string)` | List of Linux Function App names to monitor (leave empty if none) |
| `resource_group_name` | `string` | Resource group containing the Function Apps |
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `action_group` | `string` | Name of the Azure Monitor action group for notifications |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `subscription_ids` | `list(string)` | `[]` (auto-detected) | Subscription IDs for activity log alerts |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `tags` | `map(string)` | See variables.tf | Resource tags for organization and cost tracking |

### Alert Configuration Variables

#### Alert Category Toggles

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_function_execution_alerts` | `bool` | `true` | Enable function execution monitoring |
| `enable_performance_alerts` | `bool` | `true` | Enable performance monitoring (CPU, memory, response time) |
| `enable_error_alerts` | `bool` | `true` | Enable error monitoring (HTTP 4xx, 5xx) |
| `enable_resource_alerts` | `bool` | `true` | Enable resource utilization monitoring (IO, memory, GC) |
| `enable_activity_log_alerts` | `bool` | `true` | Enable activity log monitoring |
| `enable_function_app_creation_alert` | `bool` | `true` | Enable creation monitoring |
| `enable_function_app_deletion_alert` | `bool` | `true` | Enable deletion monitoring |
| `enable_function_app_config_change_alert` | `bool` | `true` | Enable configuration change monitoring |
| `enable_function_stopped_alert` | `bool` | `true` | Enable stopped state detection |

#### Alert Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `function_execution_count_threshold` | `number` | `1000` | Function execution count threshold (per window) |
| `function_execution_units_threshold` | `number` | `10000` | Execution units threshold (GB-seconds) |
| `average_memory_working_set_threshold` | `number` | `1073741824` | Average memory working set (1GB default) |
| `memory_working_set_threshold` | `number` | `1073741824` | Memory working set threshold (1GB default) |
| `http_5xx_threshold` | `number` | `5` | HTTP 5xx server error count threshold |
| `http_4xx_threshold` | `number` | `10` | HTTP 4xx client error count threshold |
| `response_time_threshold` | `number` | `5` | Response time warning threshold (seconds) |
| `response_time_critical_threshold` | `number` | `10` | Response time critical threshold (seconds) |
| `requests_threshold` | `number` | `1000` | Total requests count threshold |
| `io_read_ops_threshold` | `number` | `100` | IO read operations per second threshold |
| `io_write_ops_threshold` | `number` | `100` | IO write operations per second threshold |
| `private_bytes_threshold` | `number` | `1073741824` | Private bytes threshold (1GB default) |
| `gen_0_collections_threshold` | `number` | `100` | Gen 0 GC collections threshold (Windows only) |
| `gen_1_collections_threshold` | `number` | `50` | Gen 1 GC collections threshold (Windows only) |
| `gen_2_collections_threshold` | `number` | `10` | Gen 2 GC collections threshold (Windows only) |

#### Evaluation Frequencies

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `evaluation_frequency_high` | `string` | `"PT1M"` | High-frequency evaluation (1 minute) for critical alerts |
| `evaluation_frequency_medium` | `string` | `"PT5M"` | Medium-frequency evaluation (5 minutes) |
| `evaluation_frequency_low` | `string` | `"PT15M"` | Low-frequency evaluation (15 minutes) |
| `window_duration_short` | `string` | `"PT5M"` | Short window duration (5 minutes) |
| `window_duration_medium` | `string` | `"PT15M"` | Medium window duration (15 minutes) |
| `window_duration_long` | `string` | `"PT1H"` | Long window duration (1 hour) |

---

## Alert Details

### Function Execution Alerts

#### 1. Function Execution Count Alert
- **Metric**: `FunctionExecutionCount`
- **Threshold**: 1,000 executions (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: Monitors total number of function executions
- **Use Case**: Capacity planning, workload trending, anomaly detection

**What to do when this alert fires:**
```bash
# Check execution count
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "FunctionExecutionCount" \
  --start-time <start-time> \
  --end-time <end-time>

# Check per-function execution
az functionapp function show \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --function-name <function-name>

# Actions:
# 1. Verify if execution spike is expected (new deployment, increased load)
# 2. Check for retry storms or infinite loops
# 3. Review trigger configuration (queue, timer, HTTP)
# 4. Monitor cost implications (Consumption plan)
# 5. Consider scaling to Premium plan if sustained high volume
# 6. Review function timeout settings
```

#### 2. Function Execution Units Alert
- **Metric**: `FunctionExecutionUnits`
- **Threshold**: 10,000 GB-seconds (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Description**: Monitors execution units (GB-seconds) - primary cost driver
- **Use Case**: Cost monitoring, resource optimization

**What to do when this alert fires:**
```bash
# Check execution units
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "FunctionExecutionUnits" \
  --start-time <start-time> \
  --end-time <end-time>

# Calculate cost
# Consumption plan: First 400,000 GB-s free, then $0.000016/GB-s
# Example: 10,000 GB-s ≈ $0.16

# Actions:
# 1. Review function memory allocation (reduce if over-provisioned)
# 2. Optimize function execution time
# 3. Check for memory leaks
# 4. Review function timeout settings
# 5. Consider Premium plan for predictable costs
# 6. Implement caching to reduce executions
```

### Performance Alerts

#### 3. Average Memory Working Set Alert
- **Metric**: `AverageMemoryWorkingSet`
- **Threshold**: 1,073,741,824 bytes (1GB default)
- **Severity**: 2 (Warning)
- **Aggregation**: Average
- **Description**: Monitors average memory consumption across instances
- **Use Case**: Memory leak detection, resource optimization

**What to do when this alert fires:**
```bash
# Check memory metrics
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "AverageMemoryWorkingSet" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Actions:
# 1. Check for memory leaks in function code
# 2. Review large object allocations
# 3. Optimize data structures
# 4. Implement proper disposal patterns (IDisposable)
# 5. Reduce memory allocation size if over-provisioned
# 6. Consider scaling to Premium plan for more memory
```

#### 4. Average Response Time Alert (Warning)
- **Metric**: `AverageResponseTime`
- **Threshold**: 5 seconds (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Average
- **Description**: Monitors function response time performance
- **Use Case**: Performance monitoring, user experience

**What to do when this alert fires:**
```bash
# Check response time
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "AverageResponseTime" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Query Application Insights
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h) 
    | summarize 
        P50 = percentile(duration, 50),
        P95 = percentile(duration, 95),
        P99 = percentile(duration, 99)
        by name"

# Actions:
# 1. Identify slow functions
# 2. Optimize database queries
# 3. Implement caching (Redis, in-memory)
# 4. Review external API calls
# 5. Check cold start impact (Consumption plan)
# 6. Consider Premium plan for better performance
# 7. Optimize serialization/deserialization
# 8. Review async/await patterns
```

#### 5. Average Response Time Alert (Critical)
- **Metric**: `AverageResponseTime`
- **Threshold**: 10 seconds (default)
- **Severity**: 0 (Critical)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Average
- **Description**: **CRITICAL** - Severe performance degradation
- **Use Case**: Service availability, SLA breach detection

**What to do when this alert fires:**
```bash
# Immediate investigation required
# Check for:
# 1. Backend service outages
# 2. Database connection issues
# 3. Network problems
# 4. Resource exhaustion (CPU, memory)
# 5. Infinite loops or deadlocks
# 6. External dependency failures

# Actions (URGENT):
# 1. Check Application Insights for errors
# 2. Review function logs
# 3. Verify backend service health
# 4. Check for scaling issues
# 5. Consider manual scale-out if needed
# 6. Implement circuit breaker pattern
```

### Error Detection Alerts

#### 6. HTTP 5xx Errors Alert
- **Metric**: `Http5xx`
- **Threshold**: 5 errors (default)
- **Severity**: 1 (Error)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Total
- **Description**: **CRITICAL** - Server-side errors in function execution
- **Use Case**: Service health monitoring, incident detection

**What to do when this alert fires:**
```bash
# Check error count
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "Http5xx" \
  --start-time <start-time> \
  --end-time <end-time>

# Query Application Insights for error details
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h) 
    | where resultCode startswith '5' 
    | project timestamp, name, resultCode, duration, customDimensions 
    | order by timestamp desc"

# Check function logs
az functionapp log tail \
  --name <function-app-name> \
  --resource-group <resource-group>

# Actions (URGENT):
# 1. Identify failing functions
# 2. Review exception logs in Application Insights
# 3. Check for unhandled exceptions
# 4. Verify backend service availability
# 5. Check database connections
# 6. Review recent deployments
# 7. Implement proper error handling
# 8. Add retry logic with exponential backoff
```

#### 7. HTTP 4xx Errors Alert
- **Metric**: `Http4xx`
- **Threshold**: 10 errors (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: Client-side errors (bad requests, authentication failures)
- **Use Case**: Input validation monitoring, security monitoring

**What to do when this alert fires:**
```bash
# Check 4xx error types
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h) 
    | where resultCode startswith '4' 
    | summarize count() by resultCode 
    | order by count_ desc"

# Actions:
# 1. Check for 400 (Bad Request) - input validation issues
# 2. Check for 401 (Unauthorized) - authentication problems
# 3. Check for 403 (Forbidden) - authorization issues
# 4. Check for 404 (Not Found) - routing or missing resources
# 5. Review API documentation for clients
# 6. Implement better input validation
# 7. Add detailed error messages (non-production)
```

### Resource Utilization Alerts

#### 8. Memory Working Set Alert
- **Metric**: `MemoryWorkingSet`
- **Threshold**: 1,073,741,824 bytes (1GB default)
- **Severity**: 2 (Warning)
- **Aggregation**: Average
- **Description**: Monitors current memory working set size
- **Use Case**: Memory pressure detection, resource planning

**What to do when this alert fires:**
```bash
# Check memory usage
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "MemoryWorkingSet" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Actions:
# 1. Check for memory leaks
# 2. Review object lifecycle management
# 3. Implement proper disposal (IDisposable, using statements)
# 4. Optimize data structures
# 5. Review in-memory caching strategies
# 6. Monitor GC metrics (Windows .NET apps)
```

#### 9. IO Read Operations Alert
- **Metric**: `IoReadOperationsPerSecond`
- **Threshold**: 100 ops/sec (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Average
- **Description**: Monitors file system read operations
- **Use Case**: IO performance monitoring

**What to do when this alert fires:**
```bash
# Actions:
# 1. Review file operations in code
# 2. Implement file caching
# 3. Use async file IO
# 4. Consider Azure Blob Storage for large files
# 5. Optimize file access patterns
```

#### 10. IO Write Operations Alert
- **Metric**: `IoWriteOperationsPerSecond`
- **Threshold**: 100 ops/sec (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Average
- **Description**: Monitors file system write operations
- **Use Case**: IO performance monitoring

**What to do when this alert fires:**
```bash
# Actions:
# 1. Review file write operations
# 2. Batch write operations
# 3. Use async file IO
# 4. Consider Azure Storage for persistence
# 5. Implement write buffering
```

#### 11. Private Bytes Alert
- **Metric**: `PrivateBytes`
- **Threshold**: 1,073,741,824 bytes (1GB default)
- **Severity**: 2 (Warning)
- **Aggregation**: Average
- **Description**: Monitors private memory allocation
- **Use Case**: Memory leak detection

**What to do when this alert fires:**
```bash
# Actions:
# 1. Check for memory leaks
# 2. Review large object allocations
# 3. Implement proper memory management
# 4. Use memory profiling tools
# 5. Monitor garbage collection patterns
```

#### 12-14. Garbage Collection Alerts (Windows .NET Apps Only)

**12. Gen 0 Collections Alert**
- **Metric**: `Gen0Collections`
- **Threshold**: 100 collections (default)
- **Severity**: 3 (Informational)
- **Description**: Young generation GC - frequent, fast collections
- **Use Case**: Memory allocation pattern monitoring

**13. Gen 1 Collections Alert**
- **Metric**: `Gen1Collections`
- **Threshold**: 50 collections (default)
- **Severity**: 2 (Warning)
- **Description**: Mid-generation GC - less frequent than Gen 0
- **Use Case**: Memory pressure monitoring

**14. Gen 2 Collections Alert**
- **Metric**: `Gen2Collections`
- **Threshold**: 10 collections (default)
- **Severity**: 1 (Error)
- **Description**: **CRITICAL** - Old generation GC - expensive, full heap collections
- **Use Case**: Severe memory pressure detection

**What to do when GC alerts fire:**
```bash
# Check GC metrics
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "Gen0Collections,Gen1Collections,Gen2Collections" \
  --start-time <start-time> \
  --end-time <end-time>

# Gen 2 Collections (Most Critical):
# Actions (URGENT for high Gen 2):
# 1. Reduce object allocations
# 2. Implement object pooling
# 3. Use structs instead of classes where appropriate
# 4. Review large object heap (LOH) allocations
# 5. Optimize string operations (StringBuilder)
# 6. Implement proper disposal patterns
# 7. Review memory leaks
# 8. Consider increasing memory allocation
# 9. Profile application with dotMemory or PerfView

# Gen 0/Gen 1 Collections:
# Actions:
# 1. Review short-lived object allocations
# 2. Implement object pooling for frequently created objects
# 3. Optimize hot code paths
# 4. Reduce allocations in tight loops
```

#### 15. Total Requests Alert
- **Metric**: `Requests`
- **Threshold**: 1,000 requests (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors total HTTP request volume
- **Use Case**: Traffic monitoring, capacity planning

**What to do when this alert fires:**
```bash
# Actions:
# 1. Verify traffic spike is expected
# 2. Monitor for DDoS patterns
# 3. Check concurrent execution limits
# 4. Review scaling configuration
# 5. Consider Premium plan for unlimited executions
```

### Activity Log Alerts

#### 16. Function App Creation Alert
- **Operation**: `Microsoft.Web/sites/write`
- **Category**: Administrative
- **Level**: Informational
- **Description**: Tracks new Function App creation
- **Use Case**: Security auditing, change management

**What to do when this alert fires:**
```bash
# Query activity log
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?contains(authorization.action, 'sites/write')]"

# Actions:
# 1. Verify creation was authorized
# 2. Document in change management system
# 3. Validate configuration
# 4. Check compliance with naming conventions
```

#### 17. Function App Deletion Alert
- **Operation**: `Microsoft.Web/sites/delete`
- **Category**: Administrative
- **Level**: Warning
- **Description**: **CRITICAL** - Function App deletion detected
- **Use Case**: Accidental deletion prevention, security auditing

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?contains(authorization.action, 'sites/delete')]"

# Actions (URGENT):
# 1. Verify if deletion was authorized
# 2. Check who initiated deletion
# 3. If accidental: Restore from backups/Terraform
# 4. If malicious: Escalate to security team
# 5. Review RBAC permissions
# 6. Document incident
```

#### 18. Function App Configuration Change Alert
- **Operation**: `Microsoft.Web/sites/write`
- **Category**: Administrative
- **Level**: Warning
- **Status**: Succeeded
- **Description**: Tracks configuration modifications
- **Use Case**: Change tracking, compliance

**What to do when this alert fires:**
```bash
# Review configuration changes
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?contains(authorization.action, 'sites/write')]"

# Actions:
# 1. Verify change was authorized
# 2. Review what was changed
# 3. Test function app functionality
# 4. Document change
# 5. Monitor for impact on performance/errors
```

### Scheduled Query Rules

#### 19. Function App Stopped Alert
- **Type**: Scheduled Query Rule
- **Query**: Azure Activity Log for stop operations
- **Severity**: 1 (Error)
- **Frequency**: PT5M
- **Window**: PT15M
- **Description**: **CRITICAL** - Detects when Function App is stopped
- **Use Case**: Availability monitoring, unplanned downtime detection

**What to do when this alert fires:**
```bash
# Check Function App status
az functionapp show \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --query "state"

# Query stop operations
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureActivity 
    | where TimeGenerated > ago(15m) 
    | where OperationName == 'Microsoft.Web/sites/stop/action' 
    | where ActivityStatus == 'Succeeded' 
    | project TimeGenerated, ResourceGroup, Resource, Caller"

# Start Function App if stopped unexpectedly
az functionapp start \
  --name <function-app-name> \
  --resource-group <resource-group>

# Actions (URGENT):
# 1. Verify if stop was intentional
# 2. Check who stopped the Function App
# 3. Restart if unintentional
# 4. Review RBAC permissions
# 5. Check for Azure maintenance events
# 6. Investigate root cause
```

---

## Alert Severity Levels

| Severity | Level | Use Case | Example Alerts |
|----------|-------|----------|----------------|
| **0** | Critical | Service outage, complete failure | Response Time (Critical) |
| **1** | Error | Functional failures, severe issues | HTTP 5xx Errors, Gen 2 Collections, Function App Stopped |
| **2** | Warning | Performance degradation, approaching limits | Response Time (Warning), Memory Working Set, HTTP 4xx, Gen 1 Collections, Execution Units |
| **3** | Informational | Awareness, trend monitoring | Execution Count, IO Operations, Gen 0 Collections, Total Requests |
| **4** | Verbose | Detailed diagnostics | None in this module |

**Severity Guidelines:**
- **Severity 0** alerts require **immediate incident response** (service down)
- **Severity 1** alerts require **urgent investigation** (errors, failures)
- **Severity 2** alerts require **timely response** (performance, capacity)
- **Severity 3** alerts are **informational** (trends, usage patterns)

---

## Cost Analysis

### Alert Costs

**Azure Monitor Pricing (as of 2024):**
- Metric Alerts: **$0.10 per month** per alert rule
- Scheduled Query Rules: **$0.10 per month** per alert rule
- Activity Log Alerts: **FREE**

**This Module Cost Calculation:**
- **15 Metric Alerts** per Function App
- **3 Activity Log Alerts** (FREE, shared)
- **1 Scheduled Query Rule** (shared)

**Cost per Function App:**
- Metric alerts: 15 × $0.10 = **$1.50/month** per app
- Shared rules: $0.10/month total
- Activity log alerts: **$0.00/month** (FREE)

**Example Deployment Costs:**
- **1 Function App**: 15 alerts + shared = **$1.60/month**
- **3 Function Apps**: (3 × $1.50) + $0.10 = **$4.60/month**
- **10 Function Apps**: (10 × $1.50) + $0.10 = **$15.10/month**
- **Annual cost (3 Function Apps)**: **$55.20/year**

**Note**: Windows Function Apps have 3 additional GC alerts = $1.80/month per Windows app

### Function App Costs

**Azure Functions Pricing:**

**Consumption Plan:**
- **Free Grant**: 1 million executions + 400,000 GB-seconds per month
- **Execution Price**: $0.20 per million executions
- **Execution Time Price**: $0.000016 per GB-second
- **Best For**: Low to moderate traffic, event-driven workloads

**Premium Plan (EP1):**
- **Base Cost**: ~$150/month per instance
- **Included**: 1 million executions + 400,000 GB-seconds
- **Benefits**: VNet integration, unlimited execution duration, pre-warmed instances
- **Best For**: Production workloads requiring consistent performance

**Dedicated (App Service Plan):**
- **Cost**: Based on App Service Plan pricing
- **S1**: ~$75/month
- **P1V2**: ~$150/month
- **Best For**: Existing App Service Plan, predictable costs

**Example Monthly Costs (Consumption Plan):**
```
Scenario 1: Low Traffic
- 500K executions: FREE (under 1M)
- 200K GB-seconds: FREE (under 400K)
- Total: $0/month + monitoring ($1.60)

Scenario 2: Moderate Traffic
- 5M executions: (5M - 1M) × $0.20/1M = $0.80
- 2M GB-seconds: (2M - 400K) × $0.000016 = $25.60
- Total: ~$26.40/month + monitoring

Scenario 3: High Traffic
- 50M executions: (50M - 1M) × $0.20/1M = $9.80
- 20M GB-seconds: (20M - 400K) × $0.000016 = $313.60
- Total: ~$323.40/month + monitoring
```

### ROI Analysis

**Scenario: Order Processing Function App (5M Executions/Month)**

**Without Monitoring:**
- Average downtime per incident: 1 hour
- Incidents per month: 3
- Revenue loss: $10,000/hour (lost orders)
- **Monthly loss**: 1 hour × 3 incidents × $10,000 = **$30,000**

**With Comprehensive Monitoring:**
- Alert cost: $1.60/month per Function App
- Early detection reduces MTTR by 75% (1 hour → 15 minutes)
- Prevented downtime: 0.75 hours × 3 incidents = 2.25 hours
- **Monthly savings**: 2.25 hours × $10,000 = **$22,500**

**ROI Calculation:**
```
Monthly Investment: $1.60
Monthly Benefit: $22,500
Monthly Net Benefit: $22,498.40
ROI: (22,498.40 / 1.60) × 100 = 1,406,150%
Annual ROI: $269,980.80 savings vs $19.20 cost
```

**Additional Benefits:**
- Prevents Gen 2 GC-related outages (memory issues)
- Reduces function execution costs through optimization
- Early detection of cold start issues
- Improved SLA compliance
- Faster incident resolution

---

## Best Practices

### Function App Design

1. **Function Granularity**
   - Keep functions focused and single-purpose
   - Separate read and write operations
   - Use durable functions for long-running workflows
   - Implement idempotent functions
   - Design for stateless execution

2. **Trigger Selection**
   - HTTP triggers: Use for APIs and webhooks
   - Timer triggers: Use for scheduled jobs
   - Queue triggers: Use for async processing
   - Event Hub/Grid: Use for event-driven architectures
   - Blob triggers: Avoid for high-volume scenarios (use Event Grid)

3. **Hosting Plan Selection**
   - **Consumption**: Dev/test, variable workloads, cost-sensitive
   - **Premium**: Production, VNet integration, no cold starts
   - **Dedicated**: Existing App Service Plan, predictable costs

4. **Cold Start Mitigation**
   - Use Premium plan for production (always-on instances)
   - Minimize dependencies and package size
   - Use pre-warmed instances
   - Implement keep-alive patterns for Consumption
   - Optimize initialization code

### Performance Optimization

1. **Memory Optimization**
   - Right-size memory allocation (128MB to 1.5GB)
   - Monitor average memory working set
   - Implement proper disposal (IDisposable, using)
   - Avoid large object allocations
   - Use object pooling for frequently created objects

2. **Response Time Optimization**
   - Target < 3 seconds for user-facing functions
   - Implement caching (Redis, in-memory)
   - Optimize database queries
   - Use async/await properly
   - Avoid blocking calls
   - Implement connection pooling

3. **Execution Units Optimization**
   - Reduce memory allocation if over-provisioned
   - Optimize execution time
   - Implement early returns
   - Avoid unnecessary processing
   - Use efficient algorithms and data structures

4. **Cold Start Optimization**
   - Minimize package size
   - Reduce dependencies
   - Use compiled languages (.NET, Java) over interpreted (Python)
   - Implement module-level initialization carefully
   - Use Premium plan for zero cold starts

### Error Handling

1. **Exception Management**
   - Implement try-catch blocks
   - Log exceptions to Application Insights
   - Return appropriate HTTP status codes
   - Implement custom error messages (non-production)
   - Use structured logging

2. **Retry Strategies**
   - Implement exponential backoff
   - Set maximum retry counts
   - Use durable functions for complex retry logic
   - Handle transient failures gracefully
   - Implement circuit breaker pattern

3. **Input Validation**
   - Validate all inputs
   - Use data annotations
   - Return 400 Bad Request for invalid input
   - Sanitize user input
   - Implement schema validation

4. **Dependency Management**
   - Handle external service failures
   - Implement timeouts
   - Use circuit breakers for external APIs
   - Monitor dependency health
   - Implement fallback strategies

### Resource Management

1. **Memory Management**
   - Monitor GC collections (Windows .NET)
   - Implement proper disposal patterns
   - Avoid memory leaks
   - Use structs for small data structures
   - Implement object pooling

2. **Connection Management**
   - Use connection pooling
   - Reuse HttpClient instances
   - Implement singleton pattern for clients
   - Close connections properly
   - Monitor connection pool exhaustion

3. **File IO**
   - Use async file operations
   - Minimize file system access
   - Use Azure Storage for persistence
   - Implement file caching
   - Batch file operations

4. **Concurrency**
   - Set appropriate concurrency limits
   - Consumption: 200 concurrent executions per instance
   - Premium: Unlimited (resource-dependent)
   - Monitor concurrent execution count
   - Implement throttling for downstream services

### Monitoring and Diagnostics

1. **Application Insights**
   - Enable Application Insights on all Function Apps
   - Use structured logging
   - Implement custom metrics
   - Track dependencies
   - Monitor availability with availability tests

2. **Logging Best Practices**
   - Use appropriate log levels (Trace, Debug, Info, Warning, Error, Critical)
   - Include correlation IDs
   - Log function entry/exit
   - Log exception details
   - Avoid logging sensitive data

3. **Custom Metrics**
   - Track business metrics
   - Monitor success/failure rates
   - Track processing time per operation
   - Implement custom dimensions
   - Create custom dashboards

4. **Health Checks**
   - Implement health check functions
   - Monitor dependency health
   - Use Application Insights availability tests
   - Test critical paths regularly

### Security

1. **Authentication and Authorization**
   - Use Azure AD authentication
   - Implement function-level authorization
   - Use Managed Identity for Azure resources
   - Rotate access keys regularly
   - Implement least-privilege access

2. **Secrets Management**
   - Store secrets in Azure Key Vault
   - Use Managed Identity for Key Vault access
   - Never hard-code secrets
   - Rotate secrets regularly
   - Audit secret access

3. **Network Security**
   - Use Private Endpoints (Premium plan)
   - Implement VNet integration
   - Restrict inbound traffic with IP restrictions
   - Use service endpoints
   - Enable HTTPS only

---

## Troubleshooting

### Common Issues

#### Issue 1: Alerts Not Firing Despite Breaching Thresholds

**Symptoms:**
- Metrics exceed thresholds but no alerts triggered
- Alert state shows "Not Activated"

**Troubleshooting Steps:**
```bash
# 1. Verify Function App exists
az functionapp show \
  --name <function-app-name> \
  --resource-group <resource-group>

# 2. Verify alert is enabled
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "func-response-time-<name>" \
  --query "enabled"

# 3. Check metric availability
az monitor metrics list-definitions \
  --resource <function-app-resource-id> \
  --query "[?namespace=='Microsoft.Web/sites']"

# 4. Verify action group
az monitor action-group show \
  --resource-group <action-group-rg> \
  --name <action-group-name>
```

**Common Causes:**
- Function App not receiving traffic (no metrics)
- Wrong function app name in variables
- Alert disabled
- Action group email not confirmed

**Resolution:**
```hcl
# Verify Function App names
windows_function_app_names = ["actual-function-app-name"]

# Enable alert
enable_performance_alerts = true

# Confirm action group emails
```

---

#### Issue 2: High Execution Units (Cost Issue)

**Symptoms:**
- Execution units alert firing frequently
- Unexpected Azure costs

**Troubleshooting Steps:**
```bash
# Check execution units
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "FunctionExecutionUnits" \
  --start-time <start-time> \
  --end-time <end-time>

# Calculate cost
# Formula: GB-seconds × $0.000016

# Check memory allocation
az functionapp config show \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --query "memorySize"

# Check execution time
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(1h) 
    | summarize 
        AvgDuration = avg(duration),
        P95Duration = percentile(duration, 95)
        by name"
```

**Common Causes:**
- Over-provisioned memory allocation
- Long-running functions
- Inefficient code
- Memory leaks
- Excessive logging

**Resolution:**
```bash
# Optimize memory allocation
# Reduce from 1536MB to 512MB if usage is low

# Optimize execution time
# - Implement caching
# - Optimize database queries
# - Use async/await properly
# - Reduce external API calls
# - Implement early returns

# Consider Premium plan for predictable costs
```

---

#### Issue 3: Gen 2 Garbage Collections (Memory Pressure)

**Symptoms:**
- Gen 2 collections alert firing
- High memory usage
- Performance degradation

**Troubleshooting Steps:**
```bash
# Check GC metrics
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "Gen0Collections,Gen1Collections,Gen2Collections" \
  --start-time <start-time> \
  --end-time <end-time>

# Check memory usage
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "MemoryWorkingSet,PrivateBytes" \
  --start-time <start-time> \
  --end-time <end-time>
```

**Common Causes:**
- Memory leaks
- Large object allocations
- Inefficient string operations
- Excessive object creation
- LOH (Large Object Heap) fragmentation

**Resolution:**
```csharp
// Use StringBuilder for string concatenation
var sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.Append(i.ToString());
}

// Implement object pooling
ArrayPool<byte>.Shared.Rent(size);

// Use structs for small data structures
public struct Point {
    public int X;
    public int Y;
}

// Proper disposal
using (var resource = new Resource()) {
    // Use resource
}

// Avoid large object allocations (> 85KB)
// Consider chunking or streaming large data
```

---

#### Issue 4: HTTP 5xx Errors

**Symptoms:**
- HTTP 5xx errors alert firing
- Function executions failing

**Troubleshooting Steps:**
```bash
# Check error details in Application Insights
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "exceptions 
    | where timestamp > ago(1h) 
    | project timestamp, type, outerMessage, innermostMessage, details 
    | order by timestamp desc"

# Check function logs
az functionapp log tail \
  --name <function-app-name> \
  --resource-group <resource-group>

# Check specific function
az functionapp function show \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --function-name <function-name>
```

**Common Causes:**
- Unhandled exceptions
- Timeout errors
- Dependency failures
- Database connection issues
- Out of memory errors

**Resolution:**
```csharp
// Implement proper error handling
try {
    // Function logic
} catch (Exception ex) {
    log.LogError(ex, "Error processing request");
    return new StatusCodeResult(500);
}

// Implement retry logic
await Policy
    .Handle<Exception>()
    .WaitAndRetryAsync(3, retryAttempt => 
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)))
    .ExecuteAsync(async () => {
        // Operation to retry
    });

// Set appropriate timeout
[Timeout("00:05:00")] // 5 minutes
public static async Task Run([TimerTrigger("0 */5 * * * *")]TimerInfo myTimer, ILogger log)
{
    // Function logic
}
```

---

#### Issue 5: Cold Start Issues (Consumption Plan)

**Symptoms:**
- First request after idle period is slow
- High response time initially
- Inconsistent performance

**Troubleshooting Steps:**
```bash
# Check cold start impact
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(24h) 
    | where cloud_RoleInstance endswith '000000' 
    | summarize 
        ColdStarts = count(),
        AvgDuration = avg(duration)
        by bin(timestamp, 1h)"
```

**Common Causes:**
- Consumption plan (20-minute idle timeout)
- Large deployment package
- Many dependencies
- Slow initialization code

**Resolution:**
```bash
# Option 1: Upgrade to Premium Plan
az functionapp plan create \
  --resource-group <resource-group> \
  --name <plan-name> \
  --sku EP1

# Option 2: Implement keep-alive
# Set up external monitoring to ping function every 5 minutes

# Option 3: Optimize package size
# - Remove unused dependencies
# - Use .funcignore to exclude unnecessary files
# - Optimize initialization code

# Option 4: Use pre-warmed instances (Premium plan)
az functionapp config set \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --settings "WEBSITE_ALWAYS_READY_INSTANCES=3"
```

---

### Validation Commands

```bash
# 1. List Function Apps
az functionapp list \
  --resource-group <resource-group> \
  --output table

# 2. Get Function App details
az functionapp show \
  --name <function-app-name> \
  --resource-group <resource-group>

# 3. List functions in Function App
az functionapp function list \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --output table

# 4. Get Function App configuration
az functionapp config show \
  --name <function-app-name> \
  --resource-group <resource-group>

# 5. Check Function App status
az functionapp show \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --query "state"

# 6. List metric definitions
az monitor metrics list-definitions \
  --resource <function-app-resource-id> \
  --query "[?namespace=='Microsoft.Web/sites']"

# 7. Query execution count
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "FunctionExecutionCount" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --interval PT5M \
  --aggregation Total

# 8. Query execution units (cost)
az monitor metrics list \
  --resource <function-app-resource-id> \
  --metric "FunctionExecutionUnits" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Total

# 9. List all alerts
az monitor metrics alert list \
  --resource-group <resource-group> \
  --output table

# 10. Get alert details
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "func-response-time-<name>"

# 11. Test action group
az monitor action-group test-notifications create \
  --action-group <action-group-name> \
  --resource-group <resource-group> \
  --alert-type "Monitoring"

# 12. Enable Application Insights
az functionapp config appsettings set \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --settings "APPINSIGHTS_INSTRUMENTATIONKEY=<key>"

# 13. Query Application Insights for errors
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "exceptions 
    | where timestamp > ago(24h) 
    | summarize count() by type, outerMessage 
    | order by count_ desc"

# 14. Check function execution history
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <resource-group> \
  --analytics-query "requests 
    | where timestamp > ago(24h) 
    | summarize 
        Count = count(),
        SuccessRate = countif(success == true) * 100.0 / count(),
        AvgDuration = avg(duration)
        by name"

# 15. Restart Function App
az functionapp restart \
  --name <function-app-name> \
  --resource-group <resource-group>

# 16. Validate Terraform deployment
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

---

## License

This module is provided as-is under the MIT License. See LICENSE file for details.

---

**Module Maintained By:** Platform Engineering Team  
**Last Updated:** 2024-01-01  
**Terraform Version:** >= 1.0  
**Azure Provider Version:** >= 3.0

For questions or issues, please contact the Platform Engineering team or open an issue in the repository.
