# Azure App Service Sites Monitoring Module - Examples

This directory contains example configurations for deploying the Azure App Service Sites monitoring module in different scenarios.

## Available Examples

### 1. Production Example (`sites_alerts_production`)
Complete monitoring configuration with all 9 alerts enabled and tight thresholds suitable for production workloads.

**Features:**
- All 9 metric alerts enabled for both Windows and Linux sites
- Production-grade thresholds (99.5% availability, 3s response time)
- Full diagnostic settings (Event Hub + Log Analytics) for both OS types
- Multiple Windows sites and Linux sites
- Comprehensive monitoring coverage

**Use Case:** Production App Service deployments requiring comprehensive monitoring, alerting, and compliance with diagnostic log retention.

### 2. Development Example (`sites_alerts_development`)
Balanced monitoring configuration with all alerts and relaxed thresholds for development environments.

**Features:**
- All 9 metric alerts enabled for both Windows and Linux sites
- Relaxed thresholds (98% availability, 5s response time)
- Event Hub diagnostic settings only
- Balanced Windows and Linux site coverage
- Focused on critical metrics

**Use Case:** Development and staging environments where alerting is needed but with more relaxed thresholds.

### 3. Basic Example (`sites_alerts_basic`)
Minimal monitoring configuration with all alerts but very relaxed thresholds for testing.

**Features:**
- All 9 metric alerts enabled
- Very relaxed thresholds (95% availability, 10s response time)
- No diagnostic settings
- Single Windows site
- Minimal overhead

**Use Case:** Testing environments, proof-of-concept, or cost-sensitive deployments.

## Alert Categories

The module provides comprehensive monitoring across four categories:

### Performance Alerts (3 alerts)
- **Response Time (Warning)**: Monitors average response time - warning threshold
- **Response Time (Critical)**: Monitors average response time - critical threshold
- **CPU Time**: Tracks CPU time consumption

### Availability Alerts (3 alerts)
- **Availability**: Monitors site availability percentage
- **HTTP 4xx Errors**: Tracks client error responses
- **HTTP 5xx Errors**: Monitors server error responses

### Throughput Alerts (1 alert)
- **Request Rate**: Monitors incoming requests per minute

### I/O Operations Alerts (2 alerts)
- **IO Read Operations**: Monitors disk read operations per second
- **IO Write Operations**: Tracks disk write operations per second

## Prerequisites

Before deploying these examples, ensure you have:

1. **Azure Resources**:
   - One or more Azure App Service Sites (Windows and/or Linux)
   - Action Group for alert notifications
   - (Optional) Event Hub namespace and hub for activity logs
   - (Optional) Log Analytics workspace for security logs

2. **Permissions**:
   - `Microsoft.Insights/metricAlerts/write` - Create metric alerts
   - `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
   - `Microsoft.Web/sites/read` - Read App Service properties
   - `Microsoft.Insights/actionGroups/read` - Read action group details

3. **Terraform**:
   - Terraform >= 1.0
   - AzureRM provider >= 3.0, < 5.0

## Usage

### 1. Basic Deployment

```bash
# Navigate to examples directory
cd examples

# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Deploy all examples
terraform apply
```

### 2. Deploy Specific Example

```bash
# Deploy only production example
terraform apply -target=module.sites_alerts_production

# Deploy only development example
terraform apply -target=module.sites_alerts_development

# Deploy only basic example
terraform apply -target=module.sites_alerts_basic
```

### 3. Customize Configuration

Create a `terraform.tfvars` file or modify the example directly:

```hcl
# Custom production deployment
module "sites_alerts_custom" {
  source = "../"

  resource_group_name              = "my-appservice-rg"
  windows_site_names               = ["my-windows-app"]
  linux_site_names                 = ["my-linux-app"]
  action_group_resource_group_name = "my-monitoring-rg"
  action_group                     = "my-action-group"

  # Customize thresholds
  availability_threshold           = 99.9
  response_time_threshold          = 2
  response_time_critical_threshold = 4
  http_4xx_threshold               = 15
  http_5xx_threshold               = 3
  request_rate_threshold           = 15000
  cpu_time_threshold               = 90

  # Configure diagnostic settings
  enable_diagnostic_settings           = true
  eventhub_namespace_name              = "my-eventhub-ns"
  eventhub_name                        = "my-eventhub"
  eventhub_resource_group_name         = "my-eventhub-rg"
  log_analytics_workspace_name         = "my-law"
  log_analytics_resource_group_name    = "my-law-rg"

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
}
```

## Outputs

Each example provides comprehensive outputs:

- **alert_ids**: Map of alert resource IDs by type
- **alert_names**: Map of alert names by type
- **monitored_resources**: Map of site names by OS type
- **action_group_id**: Action group resource ID
- **diagnostic_settings**: Diagnostic setting resource IDs (Windows and Linux)
- **alert_summary**: Summary of configuration and enabled features

### Example Output Usage

```bash
# View all production alerts
terraform output production_alert_ids

# View alert summary
terraform output production_alert_summary

# View monitored resources
terraform output production_monitored_resources
```

## Configuration Reference

### Common Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `resource_group_name` | App Service resource group | Yes | "" |
| `windows_site_names` | List of Windows App Service site names | No | [] |
| `linux_site_names` | List of Linux App Service site names | No | [] |
| `action_group_resource_group_name` | Action group resource group | Yes | - |
| `action_group` | Action group name | Yes | "" |

**Note**: At least one of `windows_site_names` or `linux_site_names` must be provided.

### Threshold Variables

All alerts are created for all specified sites. You can control the sensitivity by adjusting thresholds:

| Variable | Metric | Production | Development | Basic |
|----------|--------|------------|-------------|-------|
| `availability_threshold` | Availability % (min) | 99.5 | 98 | 95 |
| `response_time_threshold` | Response Time (s) | 3 | 5 | 10 |
| `response_time_critical_threshold` | Response Time Critical (s) | 5 | 10 | 20 |
| `http_4xx_threshold` | Client Errors/min | 10 | 20 | 50 |
| `http_5xx_threshold` | Server Errors/min | 5 | 10 | 20 |
| `request_rate_threshold` | Requests/min | 10000 | 20000 | 50000 |
| `cpu_time_threshold` | CPU Time (s) | 60 | 120 | 180 |

**Note**: IO operations thresholds are fixed at 100 ops/sec (read) and 100 ops/sec (write).

### Diagnostic Settings Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `enable_diagnostic_settings` | Enable diagnostic settings | No | true |
| `eventhub_namespace_name` | Event Hub namespace name | Conditional | "" |
| `eventhub_name` | Event Hub name | Conditional | "" |
| `eventhub_resource_group_name` | Event Hub resource group | Conditional | "" |
| `eventhub_authorization_rule_name` | Event Hub auth rule | No | "RootManageSharedAccessKey" |
| `log_analytics_workspace_name` | Log Analytics workspace name | Conditional | "" |
| `log_analytics_resource_group_name` | Log Analytics resource group | Conditional | "" |
| `eventhub_subscription_id` | Event Hub subscription ID | No | Current subscription |
| `log_analytics_subscription_id` | Log Analytics subscription ID | No | Current subscription |

## Validation

After deployment, verify the configuration:

```bash
# Check deployed alerts
az monitor metrics alert list \
  --resource-group rg-appservice-prod \
  --output table

# Check diagnostic settings for Windows site
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-appservice-prod/providers/Microsoft.Web/sites/app-win-prod-001 \
  --output table

# Check diagnostic settings for Linux site
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-appservice-prod/providers/Microsoft.Web/sites/app-linux-prod-001 \
  --output table

# Test alert by generating load
# Deploy application and generate traffic to trigger alerts
```

## Troubleshooting

### Common Issues

1. **Alert not triggering**:
   - Verify threshold values are appropriate for your workload
   - Check site names exist in the specified resource group
   - Confirm action group is properly configured
   - Review metric values in Azure Portal

2. **Diagnostic settings not working**:
   - Verify Event Hub/Log Analytics workspace exists
   - Check permissions on destination resources
   - Confirm `enable_diagnostic_settings = true`
   - Verify subscription IDs if using cross-subscription
   - Ensure correct log categories for Windows vs Linux sites

3. **Module errors**:
   - Ensure App Service site names exist in specified resource group
   - Verify Windows sites use `windows_site_names` and Linux sites use `linux_site_names`
   - Verify action group exists and is accessible
   - Check AzureRM provider version compatibility

## Cost Considerations

- **Metric Alerts**: ~$0.10 per alert rule per month
- **Diagnostic Settings**: Data ingestion costs for Event Hub and Log Analytics
- **Production Example**: ~$2.70/month for alerts (3 sites × 9 alerts × $0.10)
- **Development Example**: ~$1.80/month for alerts (2 sites × 9 alerts × $0.10)
- **Basic Example**: ~$0.90/month for alerts (1 site × 9 alerts × $0.10)

Plus diagnostic logging costs based on data volume.

## Security Considerations

1. **Least Privilege**: Use managed identities or service principals with minimal required permissions
2. **Sensitive Data**: Store Event Hub and Log Analytics credentials in Key Vault
3. **Network Security**: Use private endpoints for Event Hub and Log Analytics if available
4. **Access Control**: Restrict access to diagnostic logs containing sensitive data
5. **Data Classification**: Apply appropriate tags based on data sensitivity
6. **OS-Specific Logs**: Different log categories for Windows and Linux - review before enabling

## Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftwebsites)
- [App Service Best Practices](https://docs.microsoft.com/azure/app-service/app-service-best-practices)
- [App Service Troubleshooting](https://docs.microsoft.com/azure/app-service/troubleshoot-performance-degradation)
- [Module Documentation](../README.md)

## Support

For issues, questions, or contributions, please refer to the main module repository.
