# Application Insights Module Examples

This directory contains usage examples for the Azure Application Insights monitoring module. These examples demonstrate different deployment scenarios and configurations.

## Prerequisites

- Terraform >= 1.0
- Azure subscription with appropriate permissions
- Existing Azure Application Insights instance(s)
- Existing Azure Monitor Action Group
- (Optional) Log Analytics Workspace for diagnostic settings
- (Optional) Event Hub Namespace for diagnostic settings

## Examples Overview

### Example 1: Production with Full Monitoring

This example demonstrates a production-ready configuration with:
- All alert categories enabled (availability, performance, errors, usage, dependencies)
- Strict thresholds appropriate for production workloads
- Diagnostic settings enabled with both Log Analytics and Event Hub
- Multiple Application Insights instances being monitored

**Key Features:**
- 99% availability threshold
- 2-second response time limit
- Comprehensive error monitoring
- Dual-destination diagnostic logging

### Example 2: Development with Selective Monitoring

This example shows a development environment configuration with:
- Only critical alerts enabled (availability and errors)
- Relaxed thresholds suitable for development
- Log Analytics only (no Event Hub)
- Single Application Insights instance

**Key Features:**
- 95% availability threshold
- 5-second response time limit
- Reduced alert noise for development work
- Cost-optimized diagnostic settings

### Example 3: Basic Monitoring

This example demonstrates minimal monitoring configuration:
- Essential alerts only (availability, performance, errors)
- Default threshold values
- No diagnostic settings
- Suitable for test environments

**Key Features:**
- Quick setup with minimal configuration
- Default threshold values
- No additional diagnostic costs

## Usage

1. Navigate to this examples directory:
   ```bash
   cd examples
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Customization

### Alert Categories

You can enable or disable specific alert categories:

```hcl
enable_availability_alerts  = true   # Availability tracking
enable_performance_alerts   = true   # Response time and latency
enable_error_alerts         = true   # Exceptions and failed requests
enable_usage_alerts         = true   # Request rate and page views
enable_dependency_alerts    = true   # External dependency monitoring
```

### Threshold Customization

Adjust thresholds based on your application requirements:

```hcl
availability_threshold_percent        = 99.5  # Target availability
response_time_threshold_ms            = 3000  # Max acceptable response time
server_response_time_threshold_ms     = 1500  # Server-side response time
exception_rate_threshold              = 15    # Exceptions per 5 minutes
failed_requests_threshold             = 10    # Failed requests per 5 minutes
dependency_failure_rate_threshold     = 5     # Dependency failures per 5 minutes
dependency_duration_threshold_ms      = 2000  # Max dependency call time
page_view_load_time_threshold_ms      = 5000  # Max page load time
request_rate_threshold                = 1000  # Requests per minute
```

### Diagnostic Settings Options

**Both Log Analytics and Event Hub:**
```hcl
enable_diagnostic_settings        = true
log_analytics_workspace_name      = "law-monitoring"
log_analytics_resource_group_name = "rg-monitoring"
eventhub_namespace_name           = "evhns-siem"
eventhub_name                     = "evh-appinsights-logs"
eventhub_authorization_rule_name  = "RootManageSharedAccessKey"
eventhub_resource_group_name      = "rg-siem"
```

**Log Analytics Only:**
```hcl
enable_diagnostic_settings        = true
log_analytics_workspace_name      = "law-monitoring"
log_analytics_resource_group_name = "rg-monitoring"
eventhub_namespace_name           = ""
eventhub_name                     = ""
```

**No Diagnostic Settings:**
```hcl
enable_diagnostic_settings = false
```

## Outputs

The examples provide the following outputs:

- **alert_ids**: Map of all created metric alert resource IDs
- **alert_names**: Map of all created metric alert names
- **diagnostic_setting_ids**: Map of diagnostic setting resource IDs (when enabled)
- **monitored_application_insights**: Map of Application Insights resources being monitored
- **action_group_id**: ID of the Action Group receiving alerts

## Alert Types

The module can create the following metric alerts:

1. **Availability** - Tracks application availability percentage
2. **Response Time** - Monitors overall request response time
3. **Server Response Time** - Tracks server-side response time
4. **Dependency Duration** - Monitors external dependency call duration
5. **Page View Load Time** - Tracks client-side page load time
6. **Exception Rate** - Monitors application exceptions
7. **Failed Requests** - Tracks HTTP request failures
8. **Dependency Failure Rate** - Monitors external dependency failures
9. **Request Rate** - Tracks request volume
10. **Page View Count** - Monitors page view volume

## Tags

All examples use consistent tagging:

```hcl
tags = {
  AppId              = "123456"
  Env                = "Dev"
  Owner              = "abc@pge.com"
  Compliance         = "None"
  Notify             = "abc@pge.com"
  DataClassification = "internal"
  CRIS               = "1"
  order              = "123456"
}
```

Customize these tags according to your organization's standards.

## Cleanup

To remove all created resources:

```bash
terraform destroy
```

## Additional Resources

- [Azure Application Insights Documentation](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Azure Monitor Metric Alerts](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-metric-overview)
- [Azure Monitor Action Groups](https://learn.microsoft.com/azure/azure-monitor/alerts/action-groups)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
