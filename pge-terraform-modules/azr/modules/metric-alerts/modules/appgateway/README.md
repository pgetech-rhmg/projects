# Azure Application Gateway AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure Application Gateway**. It provides production-ready monitoring across performance, capacity, availability, and security dimensions.

Azure Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. This module monitors critical metrics to ensure optimal performance, availability, and reliability while preventing service disruptions from capacity exhaustion or backend health issues.

## Table of Contents

- [Features](#features)
- [Alert Categories](#alert-categories)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Input Variables](#input-variables)
- [Alert Details](#alert-details)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Features

- **11 Metric Alerts** covering capacity, performance, health, and errors
- **Customizable Thresholds** for all alerts
- **SKU-Specific Monitoring** for v1 (CPU) and v2 (Compute/Capacity Units)
- **Backend Health Tracking** with unhealthy host detection
- **Error Rate Monitoring** for 4xx and 5xx responses
- **Performance Metrics** for latency and response times
- **Capacity Planning** with compute and capacity unit alerts
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 🔴 Critical Health & Availability Alerts
- Unhealthy Host Count (Severity 1)
- Response Status 5xx (Severity 1)
- Failed Requests (Severity 1)
- CPU Utilization - v1 SKU (Severity 1)

### 🟠 Capacity & Performance Alerts
- Compute Unit Utilization - v2 SKU (Severity 2)
- Capacity Unit Utilization - v2 SKU (Severity 2)
- Response Status 4xx (Severity 2)
- Backend Last Byte Response Time (Severity 2)
- Application Gateway Total Time (Severity 2)
- Backend Connect Time (Severity 2)

### 🟡 Informational Alerts
- Throughput (Severity 3)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.appgw_to_eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.appgw_to_loganalytics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.backend_connect_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.backend_response_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.capacity_unit_utilization](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.compute_unit_utilization](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.cpu_utilization](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.failed_requests](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.response_status_4xx](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.response_status_5xx](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.throughput](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.total_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.unhealthy_host_count](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_application_gateway.app_gateways](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_gateway) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_monitor_action_group.pge_operations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure Application Gateway (v1 or v2 SKU)
- Azure Monitor Action Group (pre-configured)
- Appropriate permissions to create Monitor alerts
- **Recommended**: Log Analytics workspace for diagnostic settings
- **Recommended**: Diagnostic settings enabled on Application Gateway resources

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs provides essential troubleshooting capabilities and detailed request/response analysis.

## Usage

### Basic Example

```hcl
module "appgateway_alerts" {
  source = "./modules/metricAlerts/appgateway"

  # Resource Configuration
  resource_group_name              = "rg-network-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Application Gateway Names to Monitor
  application_gateway_names = [
    "appgw-prod-001",
    "appgw-prod-002"
  ]

  # Tags
  tags = {
    Environment        = "Production"
    AppId              = "123456"
    CRIS               = "1"
    Compliance         = "SOX"
    DataClassification = "internal"
    Env                = "Prod"
    Notify             = "network-ops@pge.com"
    Owner              = "network-team@pge.com"
    order              = "123456"
  }
}
```

### Production v2 SKU Example with Custom Thresholds

```hcl
module "appgateway_alerts_v2_production" {
  source = "./modules/metricAlerts/appgateway"

  # Resource Configuration
  resource_group_name              = "rg-network-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-alerts-actiongroup"
  location                         = "West US 3"

  # Application Gateway Names (v2 SKU)
  application_gateway_names = [
    "appgw-web-prod",
    "appgw-api-prod",
    "appgw-app-prod"
  ]

  # v2 SKU Capacity Thresholds (Stricter for Production)
  appgw_compute_unit_threshold     = 15      # Alert at 15 CUs (75% of 20 CU average)
  appgw_capacity_unit_threshold    = 150     # Alert at 150 CUs (75% of 200 CU max)

  # Health & Error Thresholds
  appgw_unhealthy_host_threshold   = 1       # Alert on any unhealthy host
  appgw_response_5xx_threshold     = 5       # Very sensitive to server errors
  appgw_response_4xx_threshold     = 100     # Monitor client errors
  appgw_failed_requests_threshold  = 50      # Lower tolerance for failures

  # Performance Thresholds
  appgw_backend_response_time_threshold = 3000   # 3 seconds
  appgw_total_time_threshold           = 5000    # 5 seconds
  appgw_backend_connect_time_threshold = 500     # 500ms

  # Throughput Monitoring
  appgw_throughput_threshold = 500000000  # 500 MBps

  tags = {
    Environment     = "Production"
    CriticalityTier = "Tier1"
    SKU             = "WAF_v2"
  }
}
```

### Production v1 SKU Example

```hcl
module "appgateway_alerts_v1_production" {
  source = "./modules/metricAlerts/appgateway"

  resource_group_name              = "rg-legacy-network"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "operations-actiongroup"
  location                         = "West US 3"

  # Application Gateway Names (v1 SKU)
  application_gateway_names = ["appgw-legacy-prod"]

  # v1 SKU CPU Monitoring
  appgw_cpu_utilization_threshold = 75  # More aggressive CPU monitoring

  # Set v2 metrics to high values to effectively disable
  appgw_compute_unit_threshold  = 1000
  appgw_capacity_unit_threshold = 1000

  # Standard health and error thresholds
  appgw_unhealthy_host_threshold  = 2
  appgw_response_5xx_threshold    = 10
  appgw_failed_requests_threshold = 100

  tags = {
    Environment = "Production"
    SKU         = "Standard"
    Legacy      = "true"
  }
}
```

### Multi-Region High Availability Example

```hcl
# Primary Region - East US
module "appgateway_alerts_east" {
  source = "./modules/metricAlerts/appgateway"

  resource_group_name              = "rg-network-eastus"
  action_group_resource_group_name = "rg-monitoring-eastus"
  action_group                     = "eastus-ops-actiongroup"
  location                         = "East US"

  application_gateway_names = [
    "appgw-eastus-web",
    "appgw-eastus-api"
  ]

  # High availability monitoring
  appgw_unhealthy_host_threshold = 0  # Alert immediately

  tags = {
    Region      = "EastUS"
    HARole      = "Primary"
    Environment = "Production"
  }
}

# Secondary Region - West US
module "appgateway_alerts_west" {
  source = "./modules/metricAlerts/appgateway"

  resource_group_name              = "rg-network-westus"
  action_group_resource_group_name = "rg-monitoring-westus"
  action_group                     = "westus-ops-actiongroup"
  location                         = "West US 3"

  application_gateway_names = [
    "appgw-westus-web",
    "appgw-westus-api"
  ]

  appgw_unhealthy_host_threshold = 0

  tags = {
    Region      = "WestUS"
    HARole      = "Secondary"
    Environment = "Production"
  }
}
```

### WAF-Enabled Production Example

```hcl
module "appgateway_waf_alerts" {
  source = "./modules/metricAlerts/appgateway"

  resource_group_name              = "rg-security-dmz"
  action_group_resource_group_name = "rg-security-monitoring"
  action_group                     = "security-ops-actiongroup"
  location                         = "West US 3"

  application_gateway_names = ["appgw-waf-prod"]

  # Security-focused monitoring
  appgw_response_4xx_threshold    = 200   # Higher threshold for WAF blocks
  appgw_response_5xx_threshold    = 5     # Very sensitive to errors
  appgw_unhealthy_host_threshold  = 0     # Zero tolerance

  # Performance optimized for WAF overhead
  appgw_backend_response_time_threshold = 4000
  appgw_total_time_threshold           = 6000

  tags = {
    SecurityTier = "Critical"
    WAF          = "Enabled"
    Compliance   = "PCI-DSS"
  }
}
```

### Development Environment Example

```hcl
module "appgateway_alerts_dev" {
  source = "./modules/metricAlerts/appgateway"

  resource_group_name              = "rg-network-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  application_gateway_names = ["appgw-dev-001"]

  # Relaxed thresholds for development
  appgw_cpu_utilization_threshold      = 90
  appgw_compute_unit_threshold         = 20
  appgw_unhealthy_host_threshold       = 3
  appgw_response_5xx_threshold         = 50
  appgw_failed_requests_threshold      = 500
  appgw_backend_response_time_threshold = 10000

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group name where the action group is located |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where Application Gateways are located |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Name of the action group for alerts |
| `location` | `string` | `"West US 3"` | Azure region location |
| `application_gateway_names` | `list(string)` | `[]` | List of Application Gateway names to monitor |

### Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `appgw_compute_unit_threshold` | `number` | `7.5` | Compute unit utilization (v2 SKU). 75% of 10 CU average |
| `appgw_capacity_unit_threshold` | `number` | `75` | Capacity unit utilization (v2 SKU). 75% of 100 CU max |
| `appgw_cpu_utilization_threshold` | `number` | `80` | CPU utilization percentage (v1 SKU) |
| `appgw_unhealthy_host_threshold` | `number` | `1` | Unhealthy backend host count |
| `appgw_response_4xx_threshold` | `number` | `50` | 4xx client error responses in 15 min |
| `appgw_response_5xx_threshold` | `number` | `10` | 5xx server error responses in 15 min |
| `appgw_failed_requests_threshold` | `number` | `100` | Failed request count in 15 min |
| `appgw_backend_response_time_threshold` | `number` | `5000` | Backend response time in milliseconds |
| `appgw_total_time_threshold` | `number` | `10000` | Total processing time in milliseconds |
| `appgw_backend_connect_time_threshold` | `number` | `1000` | Backend connection time in milliseconds |
| `appgw_throughput_threshold` | `number` | `100000000` | Throughput in bytes/sec (100 MBps) |

### Tags Variable

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | See below | Tags applied to all alert resources |

**Default Tags:**
```hcl
{
  AppId              = "123456"
  Env                = "Dev"
  Owner              = "abc@pge.com"
  Compliance         = "SOX"
  Notify             = "abc@pge.com"
  DataClassification = "internal"
  CRIS               = "1"
  order              = "123456"
}
```

## Outputs

| Name | Description | Type |
|------|-------------|------|
| <a name="output_alert_ids"></a> [alert\_ids](#output\_alert\_ids) | Map of alert names to their resource IDs | `map(string)` |
| <a name="output_alert_names"></a> [alert\_names](#output\_alert\_names) | Map of alert types to their full resource names | `map(string)` |
| <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids) | Map of diagnostic setting resource IDs by destination type and Application Gateway name | `object` |
| <a name="output_diagnostic_setting_names"></a> [diagnostic\_setting\_names](#output\_diagnostic\_setting\_names) | Map of diagnostic setting names by destination type and Application Gateway name | `object` |
| <a name="output_monitored_application_gateways"></a> [monitored\_application\_gateways](#output\_monitored\_application\_gateways) | List of Application Gateway names being monitored by this module | `list(string)` |
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | The ID of the action group used for all alerts | `string` |
| <a name="output_application_gateway_ids"></a> [application\_gateway\_ids](#output\_application\_gateway\_ids) | Map of Application Gateway names to their resource IDs | `map(string)` |

## Alert Details

### 1. Compute Unit Utilization Alert (v2 SKU)

**Purpose**: Monitor Application Gateway v2 compute utilization  
**Metric**: `ComputeUnits`  
**Threshold**: > 7.5 CUs (configurable, 75% of 10 CU average)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Compute Units measure the compute utilization of your Application Gateway v2 SKU. This alert triggers when compute unit usage exceeds 75% of your average usage, giving you time to scale before performance degradation occurs.

**Common Causes**:
- Increased traffic volume
- Complex routing rules
- SSL/TLS processing overhead
- WAF inspection workload
- URL rewrite operations

**Recommended Actions**:
1. Review traffic patterns and trends
2. Increase minimum instance count
3. Optimize routing rules
4. Consider offloading SSL to backends
5. Review WAF rule complexity

### 2. Capacity Unit Utilization Alert (v2 SKU)

**Purpose**: Monitor overall gateway capacity utilization  
**Metric**: `CapacityUnits`  
**Threshold**: > 75 CUs (configurable, 75% of 100 CU max)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Capacity Units represent overall gateway utilization combining throughput, compute, and connection count. This alert triggers when capacity exceeds 75% of peak usage.

**Common Causes**:
- High connection count
- Bandwidth saturation
- Compute unit exhaustion
- Combined resource pressure

**Recommended Actions**:
1. Analyze which component (throughput/compute/connections) is limiting
2. Scale out by increasing max instance count
3. Review connection pooling configuration
4. Consider deploying additional Application Gateways
5. Optimize backend performance to reduce connection times

### 3. CPU Utilization Alert (v1 SKU)

**Purpose**: Monitor CPU utilization for v1 SKU gateways  
**Metric**: `CpuUtilization`  
**Threshold**: > 80% (configurable)  
**Severity**: 1 (Error)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: CPU usage should not regularly exceed 80-90% as this causes latency and degrades client experience. This alert is specific to Application Gateway v1 SKU (Standard/WAF).

**Common Causes**:
- Insufficient instance count
- High traffic volume
- SSL processing overhead
- Insufficient gateway size

**Recommended Actions**:
1. Increase instance count
2. Move to larger SKU size (Medium/Large)
3. Consider migrating to v2 SKU for better scaling
4. Offload SSL termination where possible
5. Review and optimize routing rules

### 4. Unhealthy Host Count Alert

**Purpose**: Detect backend server health issues  
**Metric**: `UnhealthyHostCount`  
**Threshold**: > 1 (configurable)  
**Severity**: 1 (Error)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Indicates the number of backend servers that Application Gateway cannot probe successfully. Alerts when servers are unhealthy (recommended: > 20% of backend capacity).

**Common Causes**:
- Backend server failures
- Network connectivity issues
- Health probe misconfiguration
- Application failures
- Firewall/NSG blocking probes

**Recommended Actions**:
1. Check backend server health and logs
2. Verify network connectivity to backends
3. Review health probe configuration
4. Check backend port availability
5. Verify NSG/firewall rules allow health probes
6. Review backend application logs
7. Consider auto-healing or auto-scaling backends

### 5. Response Status 4xx Alert

**Purpose**: Monitor client error rates  
**Metric**: `ResponseStatus` (dimension: HttpStatusGroup=4xx)  
**Threshold**: > 50 (configurable, total in 15 min)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Alerts when Application Gateway returns 4xx client errors. Some 4xx responses are expected (e.g., 404 for missing resources), but sudden increases indicate issues.

**Common Causes**:
- Client sending malformed requests
- Authentication/authorization failures (401, 403)
- Missing resources (404)
- WAF blocking requests
- Rate limiting

**Recommended Actions**:
1. Review access logs for specific 4xx codes
2. Check WAF logs if WAF is enabled
3. Investigate authentication issues
4. Review client applications for bugs
5. Adjust thresholds based on normal patterns
6. Consider using dynamic thresholds

### 6. Response Status 5xx Alert

**Purpose**: Detect server-side errors  
**Metric**: `ResponseStatus` (dimension: HttpStatusGroup=5xx)  
**Threshold**: > 10 (configurable, total in 15 min)  
**Severity**: 1 (Error)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Alerts when Application Gateway returns 5xx server errors. These indicate problems with Application Gateway or backend servers.

**Common 5xx Codes**:
- 502 Bad Gateway: Backend returned invalid response
- 503 Service Unavailable: No healthy backends
- 504 Gateway Timeout: Backend didn't respond in time

**Recommended Actions**:
1. Check unhealthy host count metric
2. Review backend server logs
3. Verify backend application health
4. Check timeout configurations
5. Review backend response times
6. Investigate Application Gateway health
7. Check for backend capacity issues

### 7. Failed Requests Alert

**Purpose**: Monitor overall request failure rate  
**Metric**: `FailedRequests`  
**Threshold**: > 100 (configurable, total in 15 min)  
**Severity**: 1 (Error)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Tracks total number of failed requests. Should be monitored in production to identify issues before customers report them.

**Common Causes**:
- Backend failures
- Timeout issues
- Connection failures
- SSL/TLS errors
- Gateway overload

**Recommended Actions**:
1. Correlate with 5xx error metrics
2. Check backend health
3. Review timeout settings
4. Investigate network connectivity
5. Check Application Gateway capacity
6. Review access logs for failure patterns

### 8. Backend Last Byte Response Time Alert

**Purpose**: Monitor backend performance  
**Metric**: `BackendLastByteResponseTime`  
**Threshold**: > 5000ms (configurable)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Measures time from establishing backend connection to receiving the last byte of the response. High values indicate slow backend performance.

**Common Causes**:
- Slow backend applications
- Database query performance
- Backend resource constraints
- Network latency to backends
- Large response payloads

**Recommended Actions**:
1. Review backend application performance
2. Optimize database queries
3. Scale backend resources
4. Implement caching
5. Review backend logs
6. Consider backend optimization

### 9. Application Gateway Total Time Alert

**Purpose**: Monitor end-to-end request processing time  
**Metric**: `ApplicationGatewayTotalTime`  
**Threshold**: > 10000ms (configurable)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Measures time from receiving first byte of HTTP request to sending last byte of response. Includes Application Gateway processing and backend time.

**Common Causes**:
- Backend latency issues
- Application Gateway processing overhead
- SSL/TLS handshake delays
- WAF inspection time
- Network latency

**Recommended Actions**:
1. Compare with BackendLastByteResponseTime
2. Identify if delay is in gateway or backend
3. Review SSL/TLS configuration
4. Check WAF rule complexity
5. Optimize routing rules
6. Consider connection keep-alive settings

### 10. Backend Connect Time Alert

**Purpose**: Monitor backend connection establishment  
**Metric**: `BackendConnectTime`  
**Threshold**: > 1000ms (configurable)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Time taken to establish connection to backend server. High values indicate network or backend connection issues.

**Common Causes**:
- Network latency
- Backend connection limits
- Firewall/NSG delays
- Backend server overload
- TCP connection issues

**Recommended Actions**:
1. Check network connectivity to backends
2. Review backend connection limits
3. Verify NSG/firewall rules
4. Enable connection pooling
5. Consider backend proximity to gateway
6. Review backend server capacity

### 11. Throughput Alert

**Purpose**: Monitor bandwidth utilization  
**Metric**: `Throughput`  
**Threshold**: > 100 MBps (configurable)  
**Severity**: 3 (Informational)  
**Frequency**: PT15M (Every 15 minutes)  
**Window**: PT1H (1 hour)

**Description**: Tracks bytes processed per second. Helps with capacity planning and detecting unusual traffic patterns.

**Common Causes**:
- Increased traffic volume
- Large file transfers
- DDoS attacks
- Legitimate traffic growth

**Recommended Actions**:
1. Review traffic patterns
2. Identify top bandwidth consumers
3. Plan capacity scaling
4. Consider DDoS protection
5. Implement rate limiting if needed
6. Monitor costs (data processing charges)

## Cost Analysis

### Azure Application Gateway Pricing

Application Gateway costs vary by SKU and usage:

| SKU | Fixed Cost | Data Processing | Outbound Data |
|-----|-----------|----------------|---------------|
| **Standard v1** | $0.025/hour per gateway | $0.008/GB | Standard rates |
| **WAF v1** | $0.05/hour per gateway | $0.008/GB | Standard rates |
| **Standard v2** | $0.246/hour per CU | Included | Standard rates |
| **WAF v2** | $0.443/hour per CU | Included | Standard rates |

**Capacity Unit (CU) Calculation (v2 SKU)**:
- **Throughput**: 2.22 Mbps per CU
- **Compute**: Based on SSL/TLS, HTTP/2, routing complexity
- **Connections**: 2,500 persistent connections per CU

### Alert Costs

**Azure Monitor metric alerts**: First signal FREE, additional signals $0.10/month

### Monthly Cost Examples

#### Small Deployment (1 Gateway v2, 10 CUs average)

**Gateway Costs**:
- Capacity: 10 CUs × 730 hours × $0.246/CU-hour = $1,795.80/month
- **Gateway Total: $1,795.80/month**

**Alert Costs**:
- 11 metric alerts × 1 gateway = 11 signals
- First signal FREE, 10 additional = $1.00/month
- **Alert Total: $1.00/month**

**Combined Monthly Cost: $1,796.80**

#### Medium Deployment (3 Gateways v2, 20 CUs average each)

**Gateway Costs**:
- Capacity: 20 CUs × 730 hours × $0.246/CU-hour × 3 = $10,774.80/month
- **Gateway Total: $10,774.80/month**

**Alert Costs**:
- 11 metric alerts × 3 gateways = 33 signals
- First signal FREE, 32 additional = $3.20/month
- **Alert Total: $3.20/month**

**Combined Monthly Cost: $10,778.00**

#### Large Deployment (10 WAF v2 Gateways, 50 CUs average each)

**Gateway Costs**:
- Capacity: 50 CUs × 730 hours × $0.443/CU-hour × 10 = $161,695.00/month
- **Gateway Total: $161,695.00/month**

**Alert Costs**:
- 11 metric alerts × 10 gateways = 110 signals
- First signal FREE, 109 additional = $10.90/month
- **Alert Total: $10.90/month**

**Combined Monthly Cost: $161,705.90**

### Cost Optimization Strategies

1. **Right-Size CUs**: Monitor actual usage and adjust min/max instance count
2. **Use v2 SKU**: Better scaling and cost efficiency than v1
3. **Connection Pooling**: Reduce connection CU consumption
4. **Optimize Rules**: Simplify routing rules to reduce compute
5. **Regional Deployment**: Place gateways close to backends
6. **Auto-scaling**: Configure proper min/max bounds
7. **Review WAF**: Use WAF v2 only where security requirements demand it

### ROI of Monitoring

**Prevented Incident Costs**:
- Downtime: $5,600/minute average (Gartner)
- Poor performance: Customer churn, revenue impact
- Security breach: $4.24M average (IBM)

**Monitoring Investment**:
- Alert costs: $1-11/month depending on scale
- **ROI: > 100,000% with single major incident prevention**

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive monitoring and troubleshooting, enable diagnostic settings on your Application Gateway resources. While metric alerts monitor performance thresholds, diagnostic settings provide detailed logs for root cause analysis.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings via Azure CLI
az monitor diagnostic-settings create \
  --name "appgw-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/applicationGateways/{gateway-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"ApplicationGatewayAccessLog","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"ApplicationGatewayPerformanceLog","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"ApplicationGatewayFirewallLog","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "appgw_diagnostics" {
  for_each                   = toset(var.application_gateway_names)
  name                       = "appgw-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_application_gateway.app_gateways[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Access Logs - All requests/responses
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  # Performance Logs - Health probe results
  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  # Firewall Logs - WAF actions (if WAF enabled)
  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  # All Metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Category | Purpose | When to Enable |
|----------|---------|----------------|
| **ApplicationGatewayAccessLog** | All HTTP requests/responses with status codes, timing, client IP | **Always** - Essential for troubleshooting |
| **ApplicationGatewayPerformanceLog** | Backend health probe results, connection counts | **Always** - Required for health diagnostics |
| **ApplicationGatewayFirewallLog** | WAF rule matches, blocks, detections | **If WAF enabled** - Security analysis |

#### Useful Log Analytics Queries

```kusto
// Top 10 slowest requests in last hour
ApplicationGatewayAccessLog
| where TimeGenerated > ago(1h)
| where httpStatus_d < 500
| top 10 by timeTaken_s desc
| project TimeGenerated, requestUri_s, httpStatus_d, timeTaken_s, clientIP_s

// 5xx error analysis
ApplicationGatewayAccessLog
| where TimeGenerated > ago(24h)
| where httpStatus_d >= 500
| summarize ErrorCount = count() by httpStatus_d, backendSettingName_s, bin(TimeGenerated, 1h)
| order by ErrorCount desc

// Backend health status
ApplicationGatewayPerformanceLog
| where TimeGenerated > ago(1h)
| summarize 
    TotalServers = dcount(serverName_s),
    HealthyServers = countif(healthProbe_s == "Passed")
  by backendPoolName_s, bin(TimeGenerated, 5m)

// WAF blocked requests (if WAF enabled)
ApplicationGatewayFirewallLog
| where TimeGenerated > ago(1h)
| where action_s == "Blocked"
| summarize BlockCount = count() by ruleId_s, Message, clientIp_s
| order by BlockCount desc
```

### 2. Threshold Configuration Guidelines

#### Production Environments
```hcl
# Strict monitoring for production workloads
appgw_compute_unit_threshold          = 15    # Alert at 75% capacity (v2)
appgw_capacity_unit_threshold         = 150   # Alert before hitting limits
appgw_cpu_utilization_threshold       = 70    # Alert at 70% CPU (v1)
appgw_unhealthy_host_threshold        = 1     # Alert on ANY unhealthy host
appgw_response_5xx_threshold          = 5     # Very sensitive to errors
appgw_failed_requests_threshold       = 50    # Low tolerance for failures
appgw_backend_response_time_threshold = 3000  # 3 seconds
appgw_total_time_threshold            = 5000  # 5 seconds
```

#### Development/Test Environments
```hcl
# Relaxed monitoring for non-production
appgw_compute_unit_threshold          = 30    # Higher threshold
appgw_capacity_unit_threshold         = 300   # More tolerance
appgw_cpu_utilization_threshold       = 85    # Higher CPU tolerance
appgw_unhealthy_host_threshold        = 2     # Some tolerance for restarts
appgw_response_5xx_threshold          = 20    # Expected during testing
appgw_failed_requests_threshold       = 100   # Higher tolerance
appgw_backend_response_time_threshold = 5000  # 5 seconds
appgw_total_time_threshold            = 8000  # 8 seconds
```

### 3. Alert Response Procedures

#### Severity 1 (Critical) - Immediate Response
- **Unhealthy Host Count** → Check backend health, review health probes
- **Response Status 5xx** → Investigate backend errors, check logs
- **Failed Requests** → Review access logs, check connectivity
- **CPU Utilization (v1)** → Scale out gateway immediately

**Response Time**: < 15 minutes  
**Escalation**: Page on-call engineer

#### Severity 2 (Warning) - Review Within 1 Hour
- **Compute Unit Utilization** → Plan capacity increase
- **Capacity Unit Utilization** → Review auto-scaling settings
- **Response Status 4xx** → Analyze request patterns
- **Backend Response Time** → Optimize backend performance

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Severity 3 (Informational) - Review During Business Hours
- **Throughput** → Capacity planning and trend analysis

**Response Time**: Next business day  
**Escalation**: Log for review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on all Application Gateways
- [ ] Configure Log Analytics workspace retention (30-90 days recommended)
- [ ] Set up action groups with appropriate notification channels
- [ ] Customize alert thresholds based on baseline performance
- [ ] Test alert notifications to verify delivery
- [ ] Document escalation procedures

#### Ongoing Operations
- [ ] Review alert thresholds quarterly
- [ ] Analyze false positive rates monthly
- [ ] Review diagnostic logs weekly for patterns
- [ ] Update alert rules for new Application Gateways
- [ ] Validate action group membership monthly
- [ ] Conduct incident response drills quarterly

#### Performance Tuning
- [ ] Establish performance baselines (CU, latency, throughput)
- [ ] Set dynamic thresholds based on historical data
- [ ] Monitor alert fatigue and tune accordingly
- [ ] Correlate metrics with application performance
- [ ] Review cost-to-benefit of monitoring strategy

## Troubleshooting

### Common Issues and Solutions

#### 1. No Metrics Available

**Symptoms**: Alerts created but no metric data flowing

**Possible Causes**:
- No traffic through Application Gateway
- Application Gateway is stopped or deallocated
- Incorrect gateway names in configuration
- Metrics not yet available (can take 5-10 minutes for new deployments)

**Resolution**:
```bash
# Verify gateway exists and is running
az network application-gateway show \
  --name "appgw-prod-001" \
  --resource-group "rg-network-production" \
  --query "{name:name,provisioningState:provisioningState,operationalState:operationalState}"

# Check if traffic is flowing (last 24 hours)
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{name}" \
  --metric "TotalRequests" \
  --start-time $(date -u -v-24H '+%Y-%m-%dT%H:%M:%SZ') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ')

# Enable diagnostic settings for detailed logging
az monitor diagnostic-settings create \
  --name "appgw-diagnostics" \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{name}" \
  --workspace "/subscriptions/{sub-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[{"category":"ApplicationGatewayAccessLog","enabled":true},{"category":"ApplicationGatewayPerformanceLog","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
```

**Verify Diagnostic Settings**:
```bash
# Check if diagnostic settings are configured
az monitor diagnostic-settings list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{name}" \
  --query "value[].{name:name,logs:logs[].category,metrics:metrics[].category}"
```

#### 2. High Compute Unit Usage

**Symptoms**: Frequent compute unit alerts, slow response times

**Resolution**:
1. Increase minimum instance count
2. Review and optimize routing rules
3. Consider offloading SSL
4. Check WAF rule complexity
5. Scale out the gateway

#### 3. Unhealthy Hosts Alert Firing

**Symptoms**: Continuous unhealthy host alerts

**Resolution**:
```bash
# Check backend health
az network application-gateway show-backend-health \
  --name "appgw-prod-001" \
  --resource-group "rg-network-production"

# Review health probe settings
az network application-gateway probe list \
  --gateway-name "appgw-prod-001" \
  --resource-group "rg-network-production"
```

Common fixes:
- Verify backend port is open
- Check NSG rules allow health probe
- Adjust health probe settings (interval, timeout, threshold)
- Fix backend application issues

#### 4. High 5xx Error Rate

**Symptoms**: Frequent 5xx alerts, failed requests

**Resolution**:
1. Check backend health metric
2. Review backend application logs
3. Verify timeout settings
4. Check backend capacity
5. Review Application Gateway diagnostics logs

#### 5. Terraform Deployment Errors

**Common Errors**:
```bash
# Error: Gateway not found
Error: "appgw-prod-001" was not found

# Error: Invalid metric dimension
Error: Dimension 'HttpStatusGroup' is not valid
```

**Resolution**:
```hcl
# Ensure gateway exists before creating alerts
data "azurerm_application_gateway" "app_gateways" {
  for_each            = toset(var.application_gateway_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Verify metric dimensions are correct
dimension {
  name     = "HttpStatusGroup"
  operator = "Include"
  values   = ["4xx"]  # or ["5xx"]
}
```

---

**Module Version**: 1.0.0  
**Last Updated**: December 2024  
**Maintained By**: PGE Platform Engineering

For questions or issues, contact the Platform Engineering team or open an issue in the repository.
