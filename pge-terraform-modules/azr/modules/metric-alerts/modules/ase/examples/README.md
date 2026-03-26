# App Service Environment Module Examples

This directory contains usage examples for the Azure App Service Environment (ASE) monitoring module. These examples demonstrate different deployment scenarios and configurations.

## Prerequisites

- Terraform >= 1.0
- Azure subscription with appropriate permissions
- Existing Azure App Service Environment v3 instance(s)
- Existing Azure Monitor Action Group
- (Optional) Log Analytics Workspace for diagnostic settings
- (Optional) Event Hub Namespace for diagnostic settings

## Examples Overview

### Example 1: Production with Full Monitoring

This example demonstrates a production-ready configuration with:
- Multiple App Service Environments being monitored
- Strict thresholds appropriate for production workloads
- Diagnostic settings enabled with both Log Analytics and Event Hub
- Comprehensive monitoring across all alert types

**Key Features:**
- 75% CPU threshold
- 80% memory threshold
- 3-second response time limit
- HTTP error monitoring (4xx, 5xx)
- Queue length monitoring
- Dual-destination diagnostic logging

### Example 2: Development with Selective Monitoring

This example shows a development environment configuration with:
- Single App Service Environment
- Relaxed thresholds suitable for development
- Log Analytics only (no Event Hub)
- Essential monitoring for development work

**Key Features:**
- 85% CPU and memory thresholds
- 10-second response time limit
- Relaxed error thresholds
- Cost-optimized diagnostic settings

### Example 3: Basic Monitoring

This example demonstrates minimal monitoring configuration:
- Default threshold values for all alerts
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

### Threshold Customization

Adjust thresholds based on your ASE requirements:

```hcl
# Resource utilization thresholds
ase_cpu_percentage_threshold    = 80  # CPU percentage
ase_memory_percentage_threshold = 80  # Memory percentage

# App Service Plan capacity thresholds
ase_large_app_service_plan_instances_threshold  = 8   # Large instances
ase_medium_app_service_plan_instances_threshold = 10  # Medium instances
ase_small_app_service_plan_instances_threshold  = 15  # Small instances
ase_total_front_end_instances_threshold         = 10  # Front-end instances

# Network thresholds
ase_data_in_threshold  = 10737418240  # 10 GB data in
ase_data_out_threshold = 10737418240  # 10 GB data out

# Performance thresholds
ase_average_response_time_threshold = 5    # 5 seconds
ase_http_queue_length_threshold     = 100  # 100 queued requests

# HTTP error thresholds
ase_http_4xx_threshold = 50   # Client errors
ase_http_5xx_threshold = 10   # Server errors
ase_http_401_threshold = 20   # Unauthorized
ase_http_403_threshold = 20   # Forbidden
ase_http_404_threshold = 100  # Not found

# Request volume thresholds
ase_total_requests_threshold = 10000  # Total requests per period
```

### Diagnostic Settings Options

**Both Log Analytics and Event Hub:**
```hcl
enable_diagnostic_settings        = true
log_analytics_workspace_name      = "law-monitoring"
log_analytics_resource_group_name = "rg-monitoring"
eventhub_namespace_name           = "evhns-siem"
eventhub_name                     = "evh-ase-logs"
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

- **alert_ids**: Map of all created metric alert resource IDs organized by alert type
- **alert_names**: Map of all created metric alert names organized by alert type
- **diagnostic_setting_ids**: Map of diagnostic setting resource IDs (when enabled)
- **monitored_ases**: Map of App Service Environment resources being monitored
- **action_group_id**: ID of the Action Group receiving alerts

## Alert Types

The module can create the following metric alerts for App Service Environments:

### Resource Utilization
1. **CPU Percentage** - Tracks ASE CPU utilization
2. **Memory Percentage** - Monitors ASE memory usage

### Capacity Metrics
3. **Large App Service Plan Instances** - Monitors large worker instances
4. **Medium App Service Plan Instances** - Monitors medium worker instances
5. **Small App Service Plan Instances** - Monitors small worker instances
6. **Total Front End Instances** - Tracks front-end capacity

### Network Metrics
7. **Data In** - Monitors inbound network traffic
8. **Data Out** - Monitors outbound network traffic

### Performance Metrics
9. **Average Response Time** - Tracks request response time
10. **HTTP Queue Length** - Monitors request queue depth

### HTTP Status Codes
11. **HTTP 4xx** - Tracks client error responses
12. **HTTP 5xx** - Monitors server error responses
13. **HTTP 401** - Unauthorized access attempts
14. **HTTP 403** - Forbidden access attempts
15. **HTTP 404** - Not found errors

### Request Metrics
16. **Total Requests** - Monitors overall request volume

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

- [Azure App Service Environment Documentation](https://learn.microsoft.com/azure/app-service/environment/overview)
- [Azure Monitor Metric Alerts](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-metric-overview)
- [Azure Monitor Action Groups](https://learn.microsoft.com/azure/azure-monitor/alerts/action-groups)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
