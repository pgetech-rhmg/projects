# Azure Application Insights AMBA Alerts

This Terraform module creates comprehensive monitoring alerts for Azure Application Insights resources following Azure Monitor Baseline Alerts (AMBA) best practices.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Alert Types](#alert-types)
- [Variables Reference](#variables-reference)
- [Alert Naming Convention](#alert-naming-convention)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Overview

The module provides a complete alerting solution for Application Insights, covering:
- **Availability Monitoring**: Application availability and uptime tracking
- **Performance Monitoring**: Response times, server performance, and page load times
- **Error Monitoring**: Exceptions, failed requests, and error rates
- **Usage Monitoring**: Request rates and page view statistics
- **Dependency Monitoring**: External dependency health and performance
- **Activity Log Alerts**: Administrative operations (creation, deletion, config changes)

## Features

✅ **Metric-based alerts** using Azure Monitor metrics  
✅ **Activity log alerts** for administrative operations  
✅ **Configurable thresholds** for all alert types  
✅ **Flexible alert categories** with enable/disable flags  
✅ **Customizable severity levels** (0-3)  
✅ **Adjustable evaluation frequencies** and window durations  
✅ **Integration with Azure Action Groups** for notifications

## Prerequisites

- Azure subscription with Application Insights resources
- Action Group for alert notifications
- Terraform >= 1.0
- Azure Provider >= 3.0

## Usage

### Advanced Configuration

```hcl
module "appinsights_metric_alerts" {
  source = "./modules/metricAlerts/appinsights"
  
  # Action Group Configuration
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "my-action-group"
  
  # Application Insights Resources
  application_insights_names = [
    "appinsights-webapp-prod",
    "appinsights-api-prod",
    "appinsights-functions-prod"
  ]
  
  # Resource Configuration
  resource_group_name = "rg-prod-applications"
  location           = "East US"
  
  # Subscription IDs for Activity Log Alerts (optional, auto-detects if not provided)
  subscription_ids = ["12345678-1234-1234-1234-123456789012"]
  
  # Enable/Disable Alert Categories
  enable_availability_alerts  = true
  enable_performance_alerts   = true
  enable_error_alerts         = true
  enable_usage_alerts         = true
  enable_dependency_alerts    = true
  enable_activity_log_alerts  = true
  
  # Custom Thresholds
  availability_threshold_percent      = 99     # Alert if < 99% availability
  response_time_threshold_ms          = 3000   # Alert if > 3 seconds
  exception_rate_threshold            = 5      # Alert if > 5 exceptions
  failed_requests_threshold           = 10     # Alert if > 10 failed requests
  dependency_duration_threshold_ms    = 5000   # Alert if > 5 seconds
  dependency_failure_rate_threshold   = 3      # Alert if > 3 failures
  server_response_time_threshold_ms   = 2000   # Alert if > 2 seconds
  page_view_load_time_threshold_ms    = 5000   # Alert if > 5 seconds
  request_rate_threshold              = 500    # Alert if > 500 req/sec
  
  # Evaluation Settings
  evaluation_frequency_high   = "PT1M"   # Check every 1 minute
  evaluation_frequency_medium = "PT5M"   # Check every 5 minutes
  evaluation_frequency_low    = "PT15M"  # Check every 15 minutes
  
  window_duration_short  = "PT5M"   # 5-minute window
  window_duration_medium = "PT15M"  # 15-minute window
  window_duration_long   = "PT30M"  # 30-minute window 
}
```

## Alert Types

### 1. Availability Alerts

| Alert | Metric | Threshold | Severity | Description |
|-------|--------|-----------|----------|-------------|
| Application Availability | `availabilityResults/availabilityPercentage` | 95% | 1 (Error) | Monitors overall application availability |

### 2. Performance Alerts

| Alert | Metric | Threshold | Severity | Description |
|-------|--------|-----------|----------|-------------|
| Response Time | `requests/duration` | 5000ms | 2 (Warning) | Average application response time |
| Server Response Time | `performanceCounters/requestExecutionTime` | 3000ms | 2 (Warning) | Server-side processing time |
| Page View Load Time | `browserTimings/totalDuration` | 8000ms | 2 (Warning) | Client-side page load time |

### 3. Error Alerts

| Alert | Metric | Threshold | Severity | Description |
|-------|--------|-----------|----------|-------------|
| Exception Rate | `exceptions/count` | 10 | 1 (Error) | Number of exceptions thrown |
| Failed Requests | `requests/failed` | 20 | 1 (Error) | HTTP 5xx and failed requests |

### 4. Usage Alerts

| Alert | Metric | Threshold | Severity | Description |
|-------|--------|-----------|----------|-------------|
| Request Rate | `requests/rate` | 100 req/s | 3 (Info) | Incoming request rate monitoring |

### 5. Dependency Alerts

| Alert | Metric | Threshold | Severity | Description |
|-------|--------|-----------|----------|-------------|
| Dependency Duration | `dependencies/duration` | 10000ms | 2 (Warning) | External dependency response time |
| Dependency Failures | `dependencies/failed` | 5 | 1 (Error) | Failed external dependency calls |

### 6. Activity Log Alerts

| Alert | Operation | Severity | Description |
|-------|-----------|----------|-------------|
| Application Insights Creation | `Microsoft.Insights/components/write` | 3 (Info) | Monitors new Application Insights creation |
| Application Insights Deletion | `Microsoft.Insights/components/delete` | 2 (Warning) | Monitors Application Insights deletion |
| Configuration Changes | `Microsoft.Insights/components/write` | 2 (Warning) | Monitors configuration modifications |

## Variables Reference

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `action_group_resource_group_name` | string | Resource group where the action group is located |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `application_insights_names` | list(string) | `[]` | List of Application Insights names to monitor |
| `resource_group_name` | string | `"rg-amba"` | Resource group where Application Insights are located |
| `action_group` | string | `"pge-operations-actiongroup"` | Action group name for alert notifications |
| `location` | string | `"West US 3"` | Azure region for scheduled query rules |
| `subscription_ids` | list(string) | `[]` | Subscription IDs for activity log alerts (auto-detects if empty) |

### Alert Threshold Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `availability_threshold_percent` | number | `95` | Availability percentage threshold |
| `response_time_threshold_ms` | number | `5000` | Average response time in milliseconds |
| `exception_rate_threshold` | number | `10` | Exception count threshold |
| `failed_requests_threshold` | number | `20` | Failed requests count threshold |
| `dependency_duration_threshold_ms` | number | `10000` | Dependency response time in milliseconds |
| `dependency_failure_rate_threshold` | number | `5` | Dependency failure count threshold |
| `server_response_time_threshold_ms` | number | `3000` | Server response time in milliseconds |
| `page_view_load_time_threshold_ms` | number | `8000` | Page load time in milliseconds |
| `request_rate_threshold` | number | `100` | Requests per second threshold |

### Alert Control Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enable_availability_alerts` | bool | `true` | Enable availability monitoring |
| `enable_performance_alerts` | bool | `true` | Enable performance monitoring |
| `enable_error_alerts` | bool | `true` | Enable error monitoring |
| `enable_usage_alerts` | bool | `true` | Enable usage monitoring |
| `enable_dependency_alerts` | bool | `true` | Enable dependency monitoring |
| `enable_activity_log_alerts` | bool | `true` | Enable activity log monitoring |

### Timing Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `evaluation_frequency_high` | string | `"PT1M"` | High priority evaluation frequency |
| `evaluation_frequency_medium` | string | `"PT5M"` | Medium priority evaluation frequency |
| `evaluation_frequency_low` | string | `"PT15M"` | Low priority evaluation frequency |
| `window_duration_short` | string | `"PT5M"` | Short-term window duration |
| `window_duration_medium` | string | `"PT15M"` | Medium-term window duration |
| `window_duration_long` | string | `"PT30M"` | Long-term window duration |

## Examples

### Scenario 1: High-Performance Application

For applications requiring strict SLAs:

```hcl
module "appinsights_alerts" {
  source = "./modules/metricAlerts/appinsights"
  
  action_group_resource_group_name = "rg-monitoring"
  application_insights_names       = ["appinsights-trading-app"]
  
  # Strict thresholds for mission-critical app
  availability_threshold_percent    = 99.9
  response_time_threshold_ms        = 500
  exception_rate_threshold          = 1
  failed_requests_threshold         = 5
  
  # Frequent monitoring
  evaluation_frequency_high = "PT1M"
  window_duration_short     = "PT5M"
}
```

### Scenario 2: Cost-Optimized Monitoring

For non-critical applications with relaxed requirements:

```hcl
module "appinsights_alerts" {
  source = "./modules/metricAlerts/appinsights"
  
  action_group_resource_group_name = "rg-monitoring"
  application_insights_names       = ["appinsights-internal-tools"]
  
  # Relaxed thresholds
  availability_threshold_percent = 90
  response_time_threshold_ms     = 10000
  
  # Less frequent monitoring
  evaluation_frequency_high   = "PT5M"
  evaluation_frequency_medium = "PT15M"
  
  # Disable optional alerts
  enable_usage_alerts      = false
  enable_dependency_alerts = false
}
```

### Scenario 3: Multiple Environments

```hcl
# Production Environment
module "appinsights_alerts_prod" {
  source = "./modules/metricAlerts/appinsights"
  
  action_group_resource_group_name = "rg-monitoring-prod"
  application_insights_names       = ["appinsights-webapp-prod", "appinsights-api-prod"]
  resource_group_name              = "rg-prod"
  
  # Strict production thresholds
  availability_threshold_percent = 99.5
  response_time_threshold_ms     = 2000
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
  }
}

# Development Environment
module "appinsights_alerts_dev" {
  source = "./modules/metricAlerts/appinsights"
  
  action_group_resource_group_name = "rg-monitoring-dev"
  application_insights_names       = ["appinsights-webapp-dev"]
  resource_group_name              = "rg-dev"
  
  # Relaxed dev thresholds
  availability_threshold_percent = 90
  response_time_threshold_ms     = 10000
  
  # Only critical alerts in dev
  enable_usage_alerts        = false
  enable_dependency_alerts   = false
  enable_activity_log_alerts = false
  
  tags = {
    Environment = "Development"
    Tier        = "Non-Critical"
  }
}
```

## Alert Naming Convention

Alerts follow this naming pattern:
- **Metric Alerts**: `appinsights-{alert-type}-{app-insights-name}`
  - Example: `appinsights-availability-appinsights-prod`
  - Example: `appinsights-response-time-appinsights-api`

- **Activity Log Alerts**: `AppInsights-{Operation}-Alert-{app-insights-names}`
  - Example: `AppInsights-Creation-Alert-appinsights-prod-appinsights-dev`

## Troubleshooting

### No Alerts Created

**Issue**: Running `terraform apply` creates no resources.

**Solution**: Ensure `application_insights_names` is not empty:
```hcl
application_insights_names = ["your-appinsights-name"]
```

### Activity Log Alerts Not Working

**Issue**: Activity log alerts don't trigger on operations.

**Solution**: 
1. Verify subscription IDs are correct (or let it auto-detect)
2. Ensure the service principal has `Reader` permissions on the subscription
3. Check that Application Insights operations are within the same subscription

### Metric Data Not Available

**Issue**: Alerts show "No data" in Azure Portal.

**Solution**:
1. Verify Application Insights is receiving telemetry data
2. Check that the Application Insights resource exists in the specified resource group
3. Ensure metric names haven't changed (rare, but possible)

### Alert Threshold Too Sensitive

**Issue**: Receiving too many alert notifications.

**Solution**: Adjust thresholds and evaluation windows:
```hcl
# Increase thresholds
response_time_threshold_ms = 10000  # More lenient

# Increase window duration
window_duration_medium = "PT30M"    # Longer observation period

# Decrease frequency
evaluation_frequency_medium = "PT15M"  # Check less often
```

## Best Practices

1. **Start with defaults**: Use default thresholds initially, then tune based on your application's behavior
2. **Monitor incrementally**: Enable one alert category at a time to avoid alert fatigue
3. **Use appropriate severities**: 
   - Severity 0 (Critical): Immediate action required
   - Severity 1 (Error): Issues affecting users
   - Severity 2 (Warning): Degraded performance
   - Severity 3 (Informational): FYI notifications
4. **Test alerts**: Manually trigger conditions to verify notifications work
5. **Document thresholds**: Add comments explaining why specific thresholds were chosen
6. **Review regularly**: Adjust thresholds based on actual application performance trends
7. **Tag consistently**: Use standardized tags for cost tracking and organization

