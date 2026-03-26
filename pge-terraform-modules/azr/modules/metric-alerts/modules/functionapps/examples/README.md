# Azure Function Apps Monitoring Module - Examples

This directory contains example configurations for the Azure Function Apps monitoring module, demonstrating different deployment patterns for serverless application monitoring.

## Overview

The Azure Function Apps monitoring module provides comprehensive observability for both Windows and Linux Function Apps, including:
- **Function Execution Monitoring**: Tracks execution count and compute units
- **Performance Monitoring**: Memory usage, response times, and request volumes
- **Error Detection**: HTTP 4xx/5xx errors and failure patterns
- **Resource Utilization**: I/O operations, private memory, and garbage collection
- **Activity Logging**: Creation, deletion, and configuration changes

## Examples

### 1. Production Deployment
**File**: See `main.tf` - Production example

High-sensitivity configuration optimized for production workloads with:
- Strict thresholds for immediate issue detection
- Critical response time monitoring (5s warning, 10s critical)
- Low error tolerances (3 for 5xx, 5 for 4xx)
- Aggressive garbage collection monitoring
- Cross-subscription diagnostic settings support
- All alert categories enabled

**Best for**:
- Production environments
- Mission-critical applications
- High-traffic serverless workloads
- SLA-driven deployments

**Key Features**:
- Function execution tracking (500 executions, 5000 units)
- Performance monitoring (512MB memory threshold)
- Error detection (3 5xx errors, 5 4xx errors)
- Response time alerts (5s/10s thresholds)
- I/O monitoring (50 ops/second)
- .NET GC monitoring (50/25/5 for Gen 0/1/2)
- EventHub for activity logs (cross-subscription)
- Log Analytics for security logs (cross-subscription)

### 2. Development Deployment
**File**: See `main.tf` - Development example

Relaxed configuration for development and testing:
- Higher thresholds to reduce alert noise
- Balanced monitoring across all categories
- Development-appropriate sensitivity
- Resource utilization monitoring enabled

**Best for**:
- Development environments
- Testing and staging
- Cost-conscious monitoring
- Learning and experimentation

**Key Features**:
- Relaxed execution limits (2000 executions, 20000 units)
- Generous memory thresholds (1GB)
- Higher error tolerances (10 5xx, 20 4xx errors)
- Relaxed response times (10s/20s)
- Higher I/O thresholds (200 ops/second)
- Less aggressive GC monitoring (200/100/20)

### 3. Basic Deployment
**File**: See `main.tf` - Basic example

Minimal configuration focusing on critical issues:
- Only error and performance alerts enabled
- Function execution and resource alerts disabled
- Simplified monitoring footprint
- No diagnostic settings

**Best for**:
- Proof-of-concept deployments
- Budget-constrained environments
- Non-critical applications
- Simplified monitoring requirements

**Key Features**:
- Critical error monitoring only
- Essential performance alerts
- Minimal alert volume
- Lower operational overhead

## Alert Types

### Function Execution Alerts
Monitor serverless function invocation patterns and compute consumption:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Function Execution Count | FunctionExecutionCount | 1000 | Tracks function invocation volume |
| Function Execution Units | FunctionExecutionUnits | 10000 | Monitors compute resource consumption |

### Performance Alerts
Track application responsiveness and memory utilization:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Average Memory Working Set | AverageMemoryWorkingSet | 1GB | Average memory usage across instances |
| Memory Working Set | MemoryWorkingSet | 1GB | Peak memory consumption |
| Average Response Time | AverageResponseTime | 5s | Application response latency |
| Response Time Critical | AverageResponseTime | 10s | Critical response time threshold |
| Total Requests | Requests | 1000 | Request volume monitoring |

### Error Alerts
Detect and alert on HTTP error patterns:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| HTTP 5xx Errors | Http5xx | 5 | Server-side errors |
| HTTP 4xx Errors | Http4xx | 10 | Client-side errors |

### Resource Utilization Alerts
Monitor I/O operations and memory consumption:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| I/O Read Operations | IoReadOperationsPerSecond | 100 ops/s | Disk read activity |
| I/O Write Operations | IoWriteOperationsPerSecond | 100 ops/s | Disk write activity |
| Private Bytes | PrivateBytes | 1GB | Process-private memory |

### .NET Garbage Collection Alerts (Windows Only)
Monitor .NET runtime garbage collection behavior:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Gen 0 Collections | Gen0Collections | 100 | Short-lived object collections |
| Gen 1 Collections | Gen1Collections | 50 | Medium-lived object collections |
| Gen 2 Collections | Gen2Collections | 10 | Long-lived object collections (expensive) |

**Note**: GC alerts only apply to Windows Function Apps running .NET applications. They are automatically scoped to Windows apps only.

## Diagnostic Settings

### Activity Logs (EventHub)
Sends Function App activity logs to Event Hub for:
- Real-time log streaming
- Integration with SIEM systems
- Long-term audit retention
- Cross-subscription support

**Log Categories**:
- AppServiceAntivirusScanAuditLogs
- AppServiceIPSecAuditLogs
- AppServicePlatformLogs

### Security Logs (Log Analytics)
Sends security-focused logs to Log Analytics for:
- Advanced query capabilities
- Security analytics and alerting
- Compliance reporting
- Cross-subscription support

**Log Categories**:
- AppServiceConsoleLogs
- AppServiceHTTPLogs
- AppServiceAuditLogs
- AppServiceFileAuditLogs
- AppServiceAppLogs

## Windows vs Linux Function Apps

### Metric Availability

| Metric | Windows | Linux | Notes |
|--------|---------|-------|-------|
| FunctionExecutionCount | ✅ | ✅ | Available on both |
| FunctionExecutionUnits | ✅ | ✅ | Available on both |
| AverageMemoryWorkingSet | ✅ | ✅ | Available on both |
| MemoryWorkingSet | ✅ | ✅ | Available on both |
| AverageResponseTime | ✅ | ✅ | Available on both |
| Http5xx / Http4xx | ✅ | ✅ | Available on both |
| Requests | ✅ | ✅ | Available on both |
| IoReadOperationsPerSecond | ✅ | ✅ | Available on both |
| IoWriteOperationsPerSecond | ✅ | ✅ | Available on both |
| PrivateBytes | ✅ | ✅ | Available on both |
| Gen0Collections | ✅ | ❌ | Windows only (.NET) |
| Gen1Collections | ✅ | ❌ | Windows only (.NET) |
| Gen2Collections | ✅ | ❌ | Windows only (.NET) |

### Configuration Approach
The module uses separate variables for Windows and Linux apps:
- `windows_function_app_names`: List of Windows Function App names
- `linux_function_app_names`: List of Linux Function App names

This allows:
- Mixed Windows/Linux deployments
- OS-specific alert scoping
- .NET GC alerts only for Windows apps
- Flexible monitoring strategies per OS

## Usage

### Prerequisites
1. Azure subscription with Function Apps deployed
2. Existing Action Group for alert notifications
3. (Optional) Event Hub namespace for activity logs
4. (Optional) Log Analytics workspace for security logs

### Basic Usage

```hcl
module "function_app_monitoring" {
  source = "path/to/module"

  # Resource identification
  resource_group_name                = "rg-functionapps-prod"
  action_group_resource_group_name   = "rg-monitoring"
  action_group                       = "ag-prod-alerts"

  # Function App names
  windows_function_app_names = ["func-win-prod-001", "func-win-prod-002"]
  linux_function_app_names   = ["func-linux-prod-001"]

  # Subscription scoping
  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Alert thresholds
  function_execution_count_threshold = 500
  http_5xx_threshold                 = 3
  response_time_threshold            = 5

  # Tags
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### With Diagnostic Settings

```hcl
module "function_app_monitoring" {
  source = "path/to/module"

  # Basic configuration
  resource_group_name              = "rg-functionapps-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  windows_function_app_names = ["func-win-prod-001"]
  subscription_ids          = ["12345678-1234-1234-1234-123456789012"]

  # Enable diagnostic settings
  enable_diagnostic_settings = true

  # EventHub for activity logs (same subscription)
  eventhub_namespace_name          = "evhns-logging-prod"
  eventhub_name                    = "evh-functionapp-logs"
  eventhub_resource_group_name     = "rg-logging"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"

  # Log Analytics for security logs (same subscription)
  log_analytics_workspace_name        = "law-security-prod"
  log_analytics_resource_group_name   = "rg-security"
}
```

### Cross-Subscription Diagnostic Settings

```hcl
module "function_app_monitoring" {
  source = "path/to/module"

  # Basic configuration
  resource_group_name              = "rg-functionapps-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  windows_function_app_names = ["func-win-prod-001"]
  subscription_ids          = ["12345678-1234-1234-1234-123456789012"]

  # Enable diagnostic settings with cross-subscription targets
  enable_diagnostic_settings = true

  # EventHub in different subscription
  eventhub_subscription_id         = "87654321-4321-4321-4321-210987654321"
  eventhub_namespace_name          = "evhns-central-logging"
  eventhub_name                    = "evh-all-activity-logs"
  eventhub_resource_group_name     = "rg-central-logging"

  # Log Analytics in different subscription
  log_analytics_subscription_id      = "11111111-2222-3333-4444-555555555555"
  log_analytics_workspace_name       = "law-central-security"
  log_analytics_resource_group_name  = "rg-central-security"
}
```

### Selective Alert Categories

```hcl
module "function_app_monitoring" {
  source = "path/to/module"

  resource_group_name              = "rg-functionapps-dev"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-dev-alerts"

  windows_function_app_names = ["func-win-dev-001"]
  subscription_ids          = ["12345678-1234-1234-1234-123456789012"]

  # Enable only critical alert categories
  enable_function_execution_alerts = false  # Disable execution monitoring
  enable_performance_alerts        = true   # Keep performance alerts
  enable_error_alerts              = true   # Keep error alerts
  enable_resource_alerts           = false  # Disable resource utilization

  # No diagnostic settings for dev
  enable_diagnostic_settings = false
}
```

## Alert Category Flags

Control alert activation by category:

| Variable | Controls | Default |
|----------|----------|---------|
| `enable_function_execution_alerts` | Execution count and units | `true` |
| `enable_performance_alerts` | Memory, response time, requests | `true` |
| `enable_error_alerts` | HTTP 4xx/5xx errors | `true` |
| `enable_resource_alerts` | I/O, memory, GC collections | `true` |

## Threshold Variables

All threshold variables support customization:

| Variable | Default | Description |
|----------|---------|-------------|
| `function_execution_count_threshold` | 1000 | Function invocations |
| `function_execution_units_threshold` | 10000 | Compute units consumed |
| `average_memory_working_set_threshold` | 1GB | Average memory usage |
| `memory_working_set_threshold` | 1GB | Peak memory usage |
| `response_time_threshold` | 5s | Response time warning |
| `response_time_critical_threshold` | 10s | Response time critical |
| `requests_threshold` | 1000 | Total request count |
| `http_5xx_threshold` | 5 | Server errors |
| `http_4xx_threshold` | 10 | Client errors |
| `io_read_ops_threshold` | 100 | Read ops per second |
| `io_write_ops_threshold` | 100 | Write ops per second |
| `private_bytes_threshold` | 1GB | Private memory |
| `gen_0_collections_threshold` | 100 | Gen 0 GC count |
| `gen_1_collections_threshold` | 50 | Gen 1 GC count |
| `gen_2_collections_threshold` | 10 | Gen 2 GC count |

## Outputs

The module provides comprehensive outputs:

```hcl
# Alert resource IDs (list)
output "alert_ids" {
  value = module.function_app_monitoring.alert_ids
}

# Alert names (list)
output "alert_names" {
  value = module.function_app_monitoring.alert_names
}

# Monitored Function Apps
output "monitored_windows_apps" {
  value = module.function_app_monitoring.monitored_windows_function_apps
}

output "monitored_linux_apps" {
  value = module.function_app_monitoring.monitored_linux_function_apps
}

# Diagnostic settings (if enabled)
output "diagnostic_settings" {
  value = module.function_app_monitoring.diagnostic_settings
}
```

## Best Practices

### 1. Threshold Tuning
- Start with defaults and adjust based on baseline behavior
- Monitor alert frequency and adjust to reduce noise
- Set stricter thresholds for production environments
- Use relaxed thresholds for development/testing

### 2. Function App Categorization
- Separate Windows and Linux apps explicitly
- Group apps by environment and criticality
- Consider separate modules for different app tiers
- Use tags to identify alert ownership

### 3. Alert Categories
- Enable all categories for production
- Disable execution alerts for dev/test to reduce noise
- Always enable error alerts
- Resource alerts help identify scaling needs

### 4. Garbage Collection Monitoring
- Monitor Gen 2 collections closely (expensive operations)
- High Gen 0/1 counts are normal for active apps
- Excessive Gen 2 may indicate memory leaks
- Only applicable to Windows .NET Function Apps

### 5. Diagnostic Settings
- Use EventHub for real-time log streaming
- Use Log Analytics for security and compliance
- Consider cross-subscription for centralized logging
- Plan retention based on compliance requirements

### 6. Cross-Subscription Scenarios
- Central logging subscriptions improve governance
- Ensure proper RBAC permissions across subscriptions
- Use managed identities where possible
- Document subscription dependencies

## Troubleshooting

### No Alerts Firing
1. Verify Function Apps exist in specified resource group
2. Check that Function App names match exactly
3. Confirm subscription IDs are correct
4. Verify Action Group is deployed and accessible
5. Check alert enable flags are set to `true`

### GC Alerts Not Working
1. Verify apps are Windows-based (Linux doesn't support GC metrics)
2. Confirm apps are running .NET runtime
3. Check that `enable_resource_alerts` is `true`
4. Verify apps are actively processing requests

### Diagnostic Settings Issues
1. Verify Event Hub namespace and hub exist
2. Confirm authorization rule has send permissions
3. Check Log Analytics workspace is accessible
4. Verify cross-subscription RBAC if used
5. Ensure `enable_diagnostic_settings` is `true`

### High Alert Volume
1. Review and increase thresholds
2. Disable non-critical alert categories
3. Use alert suppression during maintenance
4. Consider separate modules for different environments

## Version Requirements

- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

## Related Documentation

- [Azure Function Apps Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftwebsites)
- [Diagnostic Settings](https://docs.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
- [.NET Garbage Collection](https://docs.microsoft.com/dotnet/standard/garbage-collection/)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review module documentation
3. Verify Azure resource configuration
4. Check Azure Monitor metrics in portal
