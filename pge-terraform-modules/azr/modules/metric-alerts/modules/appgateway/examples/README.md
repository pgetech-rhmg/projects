# Complete Example

This example demonstrates all configuration capabilities of the Application Gateway AMBA Alerts module in a single, consolidated example covering:

1. **Production** - Full configuration with custom thresholds and dual diagnostic settings (Log Analytics + Event Hub)
2. **Development** - Log Analytics only diagnostic settings with relaxed thresholds
3. **Basic/Test** - Minimal configuration without diagnostic settings

## Features

- Multiple Application Gateways monitoring
- Custom thresholds for all alert types
- Diagnostic settings examples:
  - Both Log Analytics and Event Hub (Production)
  - Log Analytics only (Development)
  - No diagnostic settings (Basic/Test)
- Cross-subscription support demonstration
- Environment-specific configurations
- Comprehensive tagging strategies

## What Gets Created

### Production Environment
- **33 metric alerts** (11 alerts × 3 Application Gateways)
- **3 Log Analytics diagnostic settings**
- **3 Event Hub diagnostic settings**
- Production-grade alert thresholds

### Development Environment  
- **11 metric alerts** (1 Application Gateway)
- **1 Log Analytics diagnostic setting**
- Relaxed thresholds for development workloads

### Test Environment
- **11 metric alerts** (1 Application Gateway)
- No diagnostic settings
- Default thresholds

## Usage

1. Update the variables in `main.tf` to match your environment:
   ```hcl
   # Production
   resource_group_name = "your-rg"
   application_gateway_names = ["your-appgw"]
   log_analytics_workspace_name = "your-workspace"
   eventhub_namespace_name = "your-eventhub-ns"
   
   # Development
   log_analytics_workspace_name = "your-dev-workspace"
   eventhub_namespace_name = "" # Blank for Log Analytics only
   
   # Test
   enable_diagnostic_settings = false # No diagnostics
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Patterns Demonstrated

### Pattern 1: Full Production Setup
```hcl
enable_diagnostic_settings = true
log_analytics_workspace_name = "law-prod"
eventhub_namespace_name = "evhns-prod"
eventhub_name = "evh-logs"
```
**Result**: Logs sent to both destinations for analysis and SIEM integration

### Pattern 2: Log Analytics Only
```hcl
enable_diagnostic_settings = true
log_analytics_workspace_name = "law-dev"
eventhub_namespace_name = ""  # Empty
eventhub_name = ""            # Empty
```
**Result**: Logs sent only to Log Analytics (no Event Hub costs)

### Pattern 3: Alerts Only (No Diagnostics)
```hcl
enable_diagnostic_settings = false
```
**Result**: Only metric alerts created (minimal setup)

## Alert Thresholds Configured

### Production Environment
- **Compute Unit**: 10 CUs (strict)
- **Capacity Unit**: 80 CUs
- **Unhealthy Hosts**: 0 (immediate alert)
- **4xx Responses**: 100 in 15 minutes
- **5xx Responses**: 5 in 15 minutes
- **Failed Requests**: 50 in 15 minutes
- **Backend Response Time**: 3 seconds
- **Total Time**: 8 seconds
- **Backend Connect Time**: 500ms
- **Throughput**: 200 MBps

### Development Environment
- **Compute Unit**: 20 CUs (relaxed)
- **Unhealthy Hosts**: 3 (less sensitive)
- **5xx Responses**: 50 in 15 minutes
- **Failed Requests**: 500 in 15 minutes
- **Backend Response Time**: 10 seconds
- Other thresholds use module defaults

### Test/Basic Environment
- All module defaults

## Diagnostic Settings Details

### Production Logs
- **Destination 1**: Log Analytics (for Azure-native analysis)
  - ApplicationGatewayAccessLog
  - ApplicationGatewayPerformanceLog
  - ApplicationGatewayFirewallLog
  - AllMetrics

- **Destination 2**: Event Hub (for external SIEM)
  - ApplicationGatewayAccessLog
  - ApplicationGatewayPerformanceLog
  - ApplicationGatewayFirewallLog

### Development Logs
- **Destination**: Log Analytics only
  - All log categories + metrics
  - No SIEM integration (cost optimization)

### Test Environment
- No diagnostic settings configured
- Alerts only

## Cross-Subscription Support

The production example shows cross-subscription support:
```hcl
log_analytics_subscription_id = ""  # Uses current subscription
eventhub_subscription_id = ""       # Uses current subscription
```

To use resources in different subscriptions:
```hcl
log_analytics_subscription_id = "00000000-0000-0000-0000-000000000000"
eventhub_subscription_id = "11111111-1111-1111-1111-111111111111"
```

## Query Logs in Log Analytics

After deployment, query your logs:

```kusto
// Recent 5xx errors
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| where httpStatus_d >= 500
| project TimeGenerated, clientIP_s, httpStatus_d, requestUri_s, host_s

// Backend latency trends
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayPerformanceLog"
| summarize avg(backendResponseTime_d) by bin(TimeGenerated, 5m)
| render timechart
```

## Customization Tips

Adjust thresholds based on your:
- **SLA requirements**: Tighter SLAs need lower thresholds
- **Traffic patterns**: High traffic sites may need higher error thresholds
- **Application characteristics**: API backends may need tighter latency thresholds
- **Cost considerations**: Lower thresholds = more alerts = higher Action Group costs

## Prerequisites

- Application Gateways deployed in Azure
- Azure Monitor Action Group(s)
- Log Analytics workspace (for diagnostic settings)
- Event Hub namespace and Event Hub (optional, for SIEM)
- Appropriate Azure permissions

## Clean Up

```bash
terraform destroy
```

This will remove all alerts and diagnostic settings (logs remain in Log Analytics/Event Hub).

## Alert Thresholds Configured

### Capacity Alerts (v2 SKU)
- Compute Unit: 10 CUs
- Capacity Unit: 80 CUs

### Health Alerts
- Unhealthy Hosts: 0 (immediate alert)
- 4xx Responses: 100 in 15 minutes
- 5xx Responses: 5 in 15 minutes
- Failed Requests: 50 in 15 minutes

### Performance Alerts
- Backend Response Time: 3 seconds
- Total Time: 8 seconds
- Backend Connect Time: 500ms
- Throughput: 200 MBps

### v1 SKU Alert
- CPU Utilization: 85%

## Customization Tips

Adjust thresholds based on your:
- **SLA requirements**: Tighter SLAs need lower thresholds
- **Traffic patterns**: High traffic sites may need higher error thresholds
- **Application characteristics**: API backends may need tighter latency thresholds
- **Cost considerations**: Lower thresholds = more alerts = higher Action Group costs

## Prerequisites

- 3 existing Application Gateways in Azure
- Existing Azure Monitor Action Group
- Appropriate Azure permissions

## Clean Up

```bash
terraform destroy
```
