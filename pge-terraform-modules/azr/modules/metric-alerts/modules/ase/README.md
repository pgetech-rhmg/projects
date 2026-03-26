# Azure App Service Environment (ASE) AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure App Service Environment v3**. It provides production-ready monitoring across performance, capacity, availability, and security dimensions.

Azure App Service Environment (ASE) is an Azure App Service feature that provides a fully isolated and dedicated environment for securely running App Service apps at high scale. This module monitors critical ASE metrics to ensure optimal performance and reliability.

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

- **18 Metric Alerts** covering performance, capacity, and reliability
- **2 Activity Log Alerts** for administrative operations
- **Customizable Thresholds** for all alerts
- **Auto-scaling Integration** monitoring for capacity planning
- **HTTP Status Code Tracking** (401, 403, 404, 4xx, 5xx)
- **Response Time Monitoring** for performance optimization
- **Resource Utilization Tracking** (CPU, Memory, Network)
- **Queue Length Monitoring** to prevent request throttling
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 🔴 Performance Alerts
- CPU Percentage
- Memory Percentage
- Average Response Time
- HTTP Queue Length

### 🟠 Capacity Planning Alerts
- Large App Service Plan Instances
- Medium App Service Plan Instances
- Small App Service Plan Instances
- Total Front End Instances

### 🟡 Network & Traffic Alerts
- Data In (Bytes Received)
- Data Out (Bytes Sent)
- Total Requests (High Volume Detection)

### 🔵 HTTP Status Code Alerts
- HTTP 4xx Responses (Client Errors)
- HTTP 5xx Responses (Server Errors)
- HTTP 401 (Unauthorized)
- HTTP 403 (Forbidden)
- HTTP 404 (Not Found)

### 🟣 Administrative Alerts
- ASE Configuration Changes
- ASE Deletion

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure App Service Environment v3
- Azure Monitor Action Group (pre-configured)
- Appropriate permissions to create Monitor alerts

## Usage

### Basic Example

```hcl
module "ase_alerts" {
  source = "./modules/metricAlerts/ase"

  # Resource Configuration
  resource_group_name              = "rg-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # ASE Names to Monitor
  ase_names = [
    "ase-prod-001",
    "ase-prod-002"
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
module "ase_alerts_production" {
  source = "./modules/metricAlerts/ase"

  # Resource Configuration
  resource_group_name              = "rg-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-alerts-actiongroup"
  location                         = "West US 3"

  # ASE Names
  ase_names = ["ase-prod-001", "ase-prod-002", "ase-prod-003"]

  # Performance Thresholds (Stricter for Production)
  ase_cpu_percentage_threshold          = 75  # More aggressive
  ase_memory_percentage_threshold       = 75  # More aggressive
  ase_average_response_time_threshold   = 3   # Faster response expected
  ase_http_queue_length_threshold       = 50  # Lower queue tolerance

  # Capacity Planning Thresholds
  ase_large_app_service_plan_instances_threshold  = 10
  ase_medium_app_service_plan_instances_threshold = 15
  ase_small_app_service_plan_instances_threshold  = 20
  ase_total_front_end_instances_threshold         = 12

  # Network Thresholds
  ase_data_in_threshold  = 21474836480  # 20 GB
  ase_data_out_threshold = 21474836480  # 20 GB

  # HTTP Error Thresholds (Lower tolerance in production)
  ase_http_5xx_threshold = 5    # Very sensitive to server errors
  ase_http_4xx_threshold = 20   # Monitor client errors
  ase_http_401_threshold = 10   # Security monitoring
  ase_http_403_threshold = 5    # Access control monitoring
  ase_http_404_threshold = 15   # Broken links/routing

  # Traffic Volume
  ase_total_requests_threshold = 50000  # High traffic threshold

  tags = {
    Environment = "Production"
    CriticalityTier = "Tier1"
  }
}
```

### Development Environment Example

```hcl
module "ase_alerts_dev" {
  source = "./modules/metricAlerts/ase"

  resource_group_name              = "rg-development"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  ase_names = ["ase-dev-001"]

  # Relaxed Thresholds for Development
  ase_cpu_percentage_threshold    = 90
  ase_memory_percentage_threshold = 90
  ase_http_5xx_threshold         = 50   # More tolerant
  ase_http_queue_length_threshold = 200

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

### Multi-Region Deployment Example

```hcl
# West US Region
module "ase_alerts_west" {
  source = "./modules/metricAlerts/ase"

  resource_group_name              = "rg-westus-production"
  action_group_resource_group_name = "rg-monitoring-westus"
  action_group                     = "westus-operations-actiongroup"
  location                         = "West US 3"

  ase_names = [
    "ase-westus-prod-001",
    "ase-westus-prod-002"
  ]

  tags = {
    Environment = "Production"
    Region      = "WestUS"
  }
}

# East US Region
module "ase_alerts_east" {
  source = "./modules/metricAlerts/ase"

  resource_group_name              = "rg-eastus-production"
  action_group_resource_group_name = "rg-monitoring-eastus"
  action_group                     = "eastus-operations-actiongroup"
  location                         = "East US"

  ase_names = [
    "ase-eastus-prod-001",
    "ase-eastus-prod-002"
  ]

  tags = {
    Environment = "Production"
    Region      = "EastUS"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Core Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where ASEs are located |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group name for alert notifications |
| `location` | `string` | `"West US 3"` | Azure region for alert resources |
| `ase_names` | `list(string)` | `[]` | List of ASE names to monitor |
| `tags` | `map(string)` | See below | Tags applied to all alert resources |

### Default Tags

```hcl
{
  "AppId"              = "123456"
  "CRIS"               = "1"
  "Compliance"         = "SOX"
  "DataClassification" = "internal"
  "Env"                = "Dev"
  "Notify"             = "abc@pge.com"
  "Owner"              = "abc@pge.com"
  "order"              = "123456"
}
```

### Performance Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ase_cpu_percentage_threshold` | `number` | `80` | CPU percentage alert threshold (%) |
| `ase_memory_percentage_threshold` | `number` | `80` | Memory percentage alert threshold (%) |
| `ase_average_response_time_threshold` | `number` | `5` | Average response time threshold (seconds) |
| `ase_http_queue_length_threshold` | `number` | `100` | HTTP queue length alert threshold |

### Capacity Planning Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ase_large_app_service_plan_instances_threshold` | `number` | `8` | Large instance count threshold |
| `ase_medium_app_service_plan_instances_threshold` | `number` | `10` | Medium instance count threshold |
| `ase_small_app_service_plan_instances_threshold` | `number` | `15` | Small instance count threshold |
| `ase_total_front_end_instances_threshold` | `number` | `10` | Total front end instances threshold |

### Network Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ase_data_in_threshold` | `number` | `10737418240` | Data received threshold (bytes) - Default: 10 GB |
| `ase_data_out_threshold` | `number` | `10737418240` | Data sent threshold (bytes) - Default: 10 GB |
| `ase_total_requests_threshold` | `number` | `10000` | Total requests threshold for high volume detection |

### HTTP Status Code Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ase_http_4xx_threshold` | `number` | `25` | HTTP 4xx responses threshold |
| `ase_http_5xx_threshold` | `number` | `10` | HTTP 5xx responses threshold |
| `ase_http_401_threshold` | `number` | `15` | HTTP 401 (Unauthorized) threshold |
| `ase_http_403_threshold` | `number` | `10` | HTTP 403 (Forbidden) threshold |
| `ase_http_404_threshold` | `number` | `20` | HTTP 404 (Not Found) threshold |

## Alert Details

### Metric Alerts

#### 1. ASE CPU Percentage
- **Metric**: `CpuPercentage`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 80% (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors CPU utilization across the ASE. High CPU can impact application performance.

#### 2. ASE Memory Percentage
- **Metric**: `MemoryPercentage`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 80% (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors memory utilization. High memory usage can cause application instability.

#### 3. ASE Large App Service Plan Instances
- **Metric**: `LargeAppServicePlanInstances`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 8 (default)
- **Frequency**: 15 minutes
- **Window**: 1 hour
- **Severity**: 3 (Informational)
- **Description**: Tracks the number of large-sized App Service Plan instances for capacity planning.

#### 4. ASE Medium App Service Plan Instances
- **Metric**: `MediumAppServicePlanInstances`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 10 (default)
- **Frequency**: 15 minutes
- **Window**: 1 hour
- **Severity**: 3 (Informational)
- **Description**: Tracks medium-sized instances for workload distribution analysis.

#### 5. ASE Small App Service Plan Instances
- **Metric**: `SmallAppServicePlanInstances`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 15 (default)
- **Frequency**: 15 minutes
- **Window**: 1 hour
- **Severity**: 3 (Informational)
- **Description**: Tracks small-sized instances for granular capacity insights.

#### 6. ASE Total Front End Instances
- **Metric**: `TotalFrontEnds`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 10 (default)
- **Frequency**: 15 minutes
- **Window**: 1 hour
- **Severity**: 2 (Warning)
- **Description**: Monitors front-end instances handling HTTP requests. Critical for load balancing.

#### 7. ASE Data In
- **Metric**: `BytesReceived`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 10 GB (default)
- **Frequency**: 15 minutes
- **Window**: 1 hour
- **Severity**: 3 (Informational)
- **Description**: Tracks incoming network traffic for bandwidth planning and cost management.

#### 8. ASE Data Out
- **Metric**: `BytesSent`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 10 GB (default)
- **Frequency**: 15 minutes
- **Window**: 1 hour
- **Severity**: 3 (Informational)
- **Description**: Tracks outgoing network traffic for bandwidth analysis.

#### 9. ASE Average Response Time
- **Metric**: `AverageResponseTime`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 5 seconds (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors application response times. High values indicate performance degradation.

#### 10. ASE HTTP Queue Length
- **Metric**: `HttpQueueLength`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Average
- **Threshold**: 100 (default)
- **Frequency**: 1 minute
- **Window**: 5 minutes
- **Severity**: 1 (Error)
- **Description**: **CRITICAL** - Long queues indicate capacity issues or application bottlenecks.

#### 11. ASE HTTP 4xx Responses
- **Metric**: `Http4xx`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 25 (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors client-side errors (bad requests, not found, unauthorized, etc.).

#### 12. ASE HTTP 5xx Responses
- **Metric**: `Http5xx`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 10 (default)
- **Frequency**: 1 minute
- **Window**: 5 minutes
- **Severity**: 1 (Error)
- **Description**: **CRITICAL** - Server errors indicate application failures or infrastructure issues.

#### 13. ASE HTTP 401 Responses
- **Metric**: `Http401`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 15 (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Tracks unauthorized access attempts for security monitoring.

#### 14. ASE HTTP 403 Responses
- **Metric**: `Http403`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 10 (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 2 (Warning)
- **Description**: Monitors forbidden access attempts - potential security issue or misconfiguration.

#### 15. ASE HTTP 404 Responses
- **Metric**: `Http404`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 20 (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 3 (Informational)
- **Description**: Tracks not found errors - indicates broken links or routing issues.

#### 16. ASE Total Requests
- **Metric**: `Requests`
- **Namespace**: `Microsoft.Web/hostingEnvironments`
- **Aggregation**: Total
- **Threshold**: 10,000 (default)
- **Frequency**: 5 minutes
- **Window**: 15 minutes
- **Severity**: 3 (Informational)
- **Description**: High volume detection for capacity planning and traffic analysis.

### Activity Log Alerts

#### 17. ASE Configuration Changes
- **Operation**: `Microsoft.Web/hostingEnvironments/write`
- **Category**: Administrative
- **Severity**: N/A
- **Description**: Triggers when ASE configuration is modified. Critical for change tracking and compliance.

#### 18. ASE Deletion
- **Operation**: `Microsoft.Web/hostingEnvironments/delete`
- **Category**: Administrative
- **Severity**: N/A
- **Description**: Triggers when ASE is deleted. Essential for preventing accidental deletions.

## Best Practices

### 1. Threshold Configuration

#### Production Environments
```hcl
# Aggressive monitoring for production
ase_cpu_percentage_threshold          = 75   # Lower threshold
ase_memory_percentage_threshold       = 75   # Lower threshold
ase_average_response_time_threshold   = 3    # Faster response
ase_http_queue_length_threshold       = 50   # Lower queue tolerance
ase_http_5xx_threshold               = 5    # Very sensitive
```

#### Development Environments
```hcl
# Relaxed monitoring for development
ase_cpu_percentage_threshold    = 90
ase_memory_percentage_threshold = 90
ase_http_5xx_threshold         = 50
```

### 2. Action Group Strategy

**Severity-Based Routing:**
```hcl
# Critical alerts (Severity 0-1)
module "ase_alerts_critical" {
  action_group = "pager-duty-critical"
  
  ase_http_queue_length_threshold = 50   # Severity 1
  ase_http_5xx_threshold         = 5    # Severity 1
}

# Warning alerts (Severity 2)
module "ase_alerts_warning" {
  action_group = "email-operations-team"
  
  ase_cpu_percentage_threshold    = 75
  ase_memory_percentage_threshold = 75
}

# Informational alerts (Severity 3)
module "ase_alerts_info" {
  action_group = "teams-channel-notifications"
  
  ase_total_requests_threshold = 50000
}
```

### 3. Capacity Planning

**Monitor Instance Distribution:**
```hcl
# Ensure balanced workload distribution
ase_large_app_service_plan_instances_threshold  = 10
ase_medium_app_service_plan_instances_threshold = 15
ase_small_app_service_plan_instances_threshold  = 20

# Monitor front-end scaling
ase_total_front_end_instances_threshold = 12
```

### 4. Performance Optimization

**Response Time Monitoring:**
- Set `ase_average_response_time_threshold` based on SLA requirements
- Typical values:
  - High-performance apps: 1-2 seconds
  - Standard apps: 3-5 seconds
  - Background processing: 10+ seconds

**Queue Length Monitoring:**
- `ase_http_queue_length_threshold` should be very low (< 100)
- High queue lengths indicate capacity issues or slow backends

### 5. Security Monitoring

**HTTP Status Code Patterns:**
```hcl
# Security-focused thresholds
ase_http_401_threshold = 10   # Unauthorized access attempts
ase_http_403_threshold = 5    # Forbidden access attempts

# Application health
ase_http_404_threshold = 15   # Broken links/routing
ase_http_5xx_threshold = 5    # Server errors
```

### 6. Cost Management

**Network Traffic Monitoring:**
```hcl
# Set data transfer thresholds based on budget
ase_data_in_threshold  = 21474836480  # 20 GB
ase_data_out_threshold = 21474836480  # 20 GB

# Monitor request volume for cost estimation
ase_total_requests_threshold = 50000
```

### 7. Multi-Environment Strategy

```hcl
# Production: Strict thresholds, immediate notifications
module "ase_prod" {
  ase_cpu_percentage_threshold = 75
  action_group                = "pagerduty-critical"
}

# Staging: Moderate thresholds, delayed notifications
module "ase_staging" {
  ase_cpu_percentage_threshold = 85
  action_group                = "email-devops"
}

# Development: Relaxed thresholds, informational only
module "ase_dev" {
  ase_cpu_percentage_threshold = 90
  action_group                = "teams-channel"
}
```

## Troubleshooting

### Common Issues

#### 1. No Alerts Being Created

**Problem**: Alerts not appearing in Azure Monitor.

**Solution**:
```hcl
# Ensure ase_names is not empty
ase_names = ["ase-prod-001"]  # Must have at least one ASE name

# Verify resource group exists
resource_group_name = "rg-production"  # Must exist before deployment

# Check action group exists
action_group_resource_group_name = "rg-monitoring"
action_group                     = "existing-action-group"
```

#### 2. Alert Firing Too Frequently

**Problem**: Receiving too many alert notifications.

**Solution**:
```hcl
# Increase thresholds
ase_cpu_percentage_threshold = 85  # Increase from 80

# Or adjust window size (done in alerts.tf)
# Longer windows smooth out spikes
```

#### 3. Alert Not Firing When Expected

**Problem**: Metric exceeds threshold but no alert.

**Diagnostics**:
```bash
# Check if ASE exists and data is flowing
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Web/hostingEnvironments/{ase-name}" \
  --metric CpuPercentage \
  --start-time 2025-11-24T00:00:00Z \
  --end-time 2025-11-24T23:59:59Z

# Verify alert is enabled
az monitor metrics alert show \
  --name "ase-cpu-percentage-ase-prod-001" \
  --resource-group "rg-production"
```

**Solution**:
```hcl
# Lower threshold if metric is consistently below current threshold
ase_cpu_percentage_threshold = 70  # Decrease from 80

# Check aggregation type matches metric behavior
# Average vs. Maximum vs. Total
```

#### 4. Data Source Not Found

**Problem**: `Error: App Service Environment not found`

**Solution**:
```hcl
# Ensure ASE name matches exactly (case-sensitive)
ase_names = ["ase-prod-001"]  # Not "ASE-PROD-001"

# Verify resource group name is correct
resource_group_name = "rg-production"  # Where ASE actually lives

# Check ASE version - this module requires ASE v3
data "azurerm_app_service_environment_v3" "ases" {
  # Only works with ASE v3
}
```

#### 5. Activity Log Alerts Not Working

**Problem**: Configuration change alerts not triggering.

**Solution**:
```hcl
# Ensure location is set to "global" (done automatically in module)
location = "global"

# Activity log alerts require subscription-level permissions
# Verify you have Microsoft.Insights/activityLogAlerts/write permission
```

#### 6. High False Positive Rate

**Problem**: Alerts firing during normal operations.

**Solution**:
```hcl
# Establish baselines first using Azure Monitor Metrics
# Then set thresholds 10-20% above normal peaks

# Example: If normal CPU is 60%, set threshold to 75%
ase_cpu_percentage_threshold = 75

# Use longer evaluation windows for stability
# (window_size is configured in alerts.tf)
```

### Validation Commands

```bash
# Verify Terraform configuration
terraform init
terraform validate
terraform plan

# Check ASE exists
az appservice ase list \
  --resource-group "rg-production"

# List existing alerts
az monitor metrics alert list \
  --resource-group "rg-production" \
  --query "[?contains(name, 'ase-')].{Name:name, Enabled:enabled, Severity:severity}"

# Test action group
az monitor action-group test-notifications create \
  --action-group "pge-operations-actiongroup" \
  --resource-group "rg-monitoring" \
  --notification-type "Email"

# View alert history
az monitor metrics alert show \
  --name "ase-cpu-percentage-ase-prod-001" \
  --resource-group "rg-production" \
  --query "evaluationFrequency"

# Check metric data availability
az monitor metrics list-definitions \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Web/hostingEnvironments/{ase-name}"
```

### Debug Mode

```hcl
# Enable detailed logging
export TF_LOG=DEBUG
terraform apply

# Check Terraform state for alert IDs
terraform state list | grep ase
terraform state show module.ase_alerts.azurerm_monitor_metric_alert.ase_cpu_percentage
```

## Alert Severity Mapping

| Severity | Level | Use Case | Action Required |
|----------|-------|----------|-----------------|
| 0 | Critical | Service down, data loss | Immediate response (PagerDuty) |
| 1 | Error | Significant degradation | Immediate attention (15 min) |
| 2 | Warning | Approaching limits | Review within 1 hour |
| 3 | Informational | FYI, trending | Review during business hours |
| 4 | Verbose | Detailed diagnostics | Optional review |

**This Module's Severity Distribution:**
- **Severity 1 (Error)**: HTTP Queue Length, HTTP 5xx Responses
- **Severity 2 (Warning)**: CPU, Memory, Response Time, Front-End Instances, HTTP 4xx/401/403, Total Front-End Instances
- **Severity 3 (Informational)**: Instance Counts, Data Transfer, HTTP 404, Total Requests

## Performance Considerations

### Resource Creation Time
- **Metric Alerts**: ~10 seconds per alert
- **Activity Log Alerts**: ~5 seconds per alert
- **Total Module Deployment**: ~3-5 minutes for 2-3 ASEs

### Azure API Rate Limits
- Monitor API: 100 requests per minute per subscription
- Safe batch size: Process 5-10 ASEs per module invocation

### Metric Evaluation Frequency
| Alert | Frequency | Window | Impact |
|-------|-----------|--------|--------|
| HTTP Queue, HTTP 5xx | 1 min | 5 min | High - Rapid detection |
| CPU, Memory, Response Time | 5 min | 15 min | Medium - Balance accuracy & cost |
| Capacity Planning | 15 min | 1 hour | Low - Trend analysis |

## Cost Optimization

### Alert Pricing (2025)
- **Metric Alerts**: $0.10 per alert per month
- **Activity Log Alerts**: Free
- **Total Module Cost** (for 2 ASEs):
  - 32 metric alerts × $0.10 = $3.20/month
  - 2 activity log alerts × $0 = $0/month
  - **Total: ~$3.20/month per module instance**

### Cost Reduction Strategies
```hcl
# Disable non-critical alerts in dev/test
ase_names = var.environment == "production" ? var.prod_ases : []

# Use longer evaluation windows
# (Reduces evaluation frequency, lowers API calls)

# Consolidate action groups
# (Reuse existing action groups across modules)
```

## Alert Severity Mapping

| Severity | Level | Use Case | Action Required |
1. Check existing [Troubleshooting](#troubleshooting) section
2. Verify Terraform and Azure Provider versions
3. Collect diagnostic information:
   ```bash
   terraform version
   az version
   terraform state list
   ```
4. Open an issue with:
   - Error messages
   - Terraform configuration
   - Expected vs. actual behavior

### Contributing
- Follow AMBA naming conventions
- Include tests for new alerts
- Update README with new variables
- Validate with `terraform fmt` and `terraform validate`

## License

This module follows your organization's licensing terms.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-24 | Initial release with 18 alerts |

---

**Last Updated**: November 24, 2025  
**Module Version**: 1.0.0  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
