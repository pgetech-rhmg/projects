# Azure App Service Plan (Server Farms) Monitoring Module - Examples

This directory contains example configurations for deploying the Azure App Service Plan monitoring module in different scenarios.

## Available Examples

### 1. Production Example (`serverfarms_alerts_production`)
Complete monitoring configuration with all alerts enabled and tight thresholds suitable for production workloads.

**Features:**
- All 4 metric alerts enabled
- Production-grade thresholds (80% for CPU/memory, 10 for queues)
- Full diagnostic settings (Event Hub + Log Analytics)
- Multiple App Service Plan instances
- Comprehensive monitoring coverage

**Use Case:** Production App Service deployments requiring comprehensive monitoring, alerting, and compliance with diagnostic log retention.

### 2. Development Example (`serverfarms_alerts_development`)
Balanced monitoring configuration with all alerts and relaxed thresholds for development environments.

**Features:**
- All 4 metric alerts enabled
- Relaxed thresholds (90% for CPU/memory, 20 for queues)
- Event Hub diagnostic settings only
- Single App Service Plan instance
- Focused on critical performance metrics

**Use Case:** Development and staging environments where alerting is needed but with more relaxed thresholds.

### 3. Basic Example (`serverfarms_alerts_basic`)
Minimal monitoring configuration with all alerts but very relaxed thresholds for testing.

**Features:**
- All 4 metric alerts enabled
- Very relaxed thresholds (95% for CPU/memory, 50 for queues)
- No diagnostic settings
- Single App Service Plan instance
- Minimal overhead

**Use Case:** Testing environments, proof-of-concept, or cost-sensitive deployments.

## Alert Categories

The module provides comprehensive monitoring across two categories:

### Performance Alerts
- **CPU Percentage**: Monitors processor utilization across App Service Plan instances
- **Memory Percentage**: Tracks memory consumption across App Service Plan instances

### Queue Management Alerts
- **HTTP Queue Length**: Monitors pending HTTP requests waiting to be processed
- **Disk Queue Length**: Tracks pending disk I/O operations

## Prerequisites

Before deploying these examples, ensure you have:

1. **Azure Resources**:
   - One or more Azure App Service Plans (Server Farms)
   - Action Group for alert notifications
   - (Optional) Event Hub namespace and hub for activity logs
   - (Optional) Log Analytics workspace for security logs

2. **Permissions**:
   - `Microsoft.Insights/metricAlerts/write` - Create metric alerts
   - `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
   - `Microsoft.Web/serverfarms/read` - Read App Service Plan properties
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
terraform apply -target=module.serverfarms_alerts_production

# Deploy only development example
terraform apply -target=module.serverfarms_alerts_development

# Deploy only basic example
terraform apply -target=module.serverfarms_alerts_basic
```

### 3. Customize Configuration

Create a `terraform.tfvars` file or modify the example directly:

```hcl
# Custom production deployment
module "serverfarms_alerts_custom" {
  source = "../"

  resource_group_name              = "my-appservice-rg"
  serverfarm_names                 = ["my-app-service-plan"]
  action_group_resource_group_name = "my-monitoring-rg"
  action_group                     = "my-action-group"

  # Customize thresholds
  cpu_percentage_threshold    = 75
  memory_percentage_threshold = 85
  http_queue_length_threshold = 15
  disk_queue_length_threshold = 15

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
- **monitored_resources**: List of App Service Plan names being monitored
- **action_group_id**: Action group resource ID
- **diagnostic_settings**: Diagnostic setting resource IDs
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
| `resource_group_name` | App Service Plan resource group | Yes | "" |
| `serverfarm_names` | List of App Service Plan names to monitor | Yes | [] |
| `action_group_resource_group_name` | Action group resource group | Yes | - |
| `action_group` | Action group name | Yes | "" |

### Threshold Variables

All alerts are always created for all specified App Service Plans. You can control the sensitivity by adjusting thresholds:

| Variable | Metric | Production | Development | Basic |
|----------|--------|------------|-------------|-------|
| `cpu_percentage_threshold` | CPU % | 80 | 90 | 95 |
| `memory_percentage_threshold` | Memory % | 80 | 90 | 95 |
| `http_queue_length_threshold` | HTTP Queue Length | 10 | 20 | 50 |
| `disk_queue_length_threshold` | Disk Queue Length | 10 | 20 | 50 |

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

# Check diagnostic settings
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-appservice-prod/providers/Microsoft.Web/serverfarms/asp-prod-001 \
  --output table

# Test alert by generating load on App Service Plan
# Deploy apps and generate traffic to increase CPU/memory usage
```

## Troubleshooting

### Common Issues

1. **Alert not triggering**:
   - Verify threshold values are appropriate for your workload
   - Check alert is properly configured in Azure Portal
   - Confirm action group is properly configured
   - Review metric values in Azure Portal

2. **Diagnostic settings not working**:
   - Verify Event Hub/Log Analytics workspace exists
   - Check permissions on destination resources
   - Confirm `enable_diagnostic_settings = true`
   - Verify subscription IDs if using cross-subscription

3. **Module errors**:
   - Ensure App Service Plan names exist in specified resource group
   - Verify action group exists and is accessible
   - Check AzureRM provider version compatibility

## Cost Considerations

- **Metric Alerts**: ~$0.10 per alert rule per month
- **Diagnostic Settings**: Data ingestion costs for Event Hub and Log Analytics
- **Production Example**: ~$0.40/month for alerts (4 alerts × $0.10)
- **Development Example**: ~$0.40/month for alerts (4 alerts × $0.10)
- **Basic Example**: ~$0.40/month for alerts (4 alerts × $0.10)

Plus diagnostic logging costs based on data volume.

## Security Considerations

1. **Least Privilege**: Use managed identities or service principals with minimal required permissions
2. **Sensitive Data**: Store Event Hub and Log Analytics credentials in Key Vault
3. **Network Security**: Use private endpoints for Event Hub and Log Analytics if available
4. **Access Control**: Restrict access to diagnostic logs containing sensitive data
5. **Data Classification**: Apply appropriate tags based on data sensitivity

## Additional Resources

- [Azure App Service Plan Documentation](https://docs.microsoft.com/azure/app-service/overview-hosting-plans)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftwebserverfarms)
- [App Service Best Practices](https://docs.microsoft.com/azure/app-service/app-service-best-practices)
- [App Service Troubleshooting](https://docs.microsoft.com/azure/app-service/troubleshoot-performance-degradation)
- [Module Documentation](../README.md)

## Support

For issues, questions, or contributions, please refer to the main module repository.
