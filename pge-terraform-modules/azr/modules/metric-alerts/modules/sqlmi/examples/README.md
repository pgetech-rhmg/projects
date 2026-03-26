# Azure SQL Managed Instance Monitoring Module - Examples

This directory contains example configurations for deploying the Azure SQL Managed Instance monitoring module in different scenarios.

## Available Examples

### 1. Production Example (`sqlmi_alerts_production`)
Complete monitoring configuration with all 5 alerts enabled and tight thresholds suitable for production instances.

**Features:**
- All 5 metric alerts enabled for 2 SQL Managed Instances
- Production-grade thresholds (70% CPU warning, 75% storage warning)
- Full diagnostic settings (Event Hub + Log Analytics)
- Multiple managed instances
- Comprehensive monitoring coverage

**Use Case:** Production SQL Managed Instance deployments requiring comprehensive monitoring, alerting, and compliance with diagnostic log retention.

### 2. Development Example (`sqlmi_alerts_development`)
Balanced monitoring configuration with all alerts and relaxed thresholds for development environments.

**Features:**
- All 5 metric alerts enabled for 1 SQL Managed Instance
- Relaxed thresholds (80% CPU warning, 80% storage warning)
- Event Hub diagnostic settings only
- Single managed instance
- Focused on critical metrics

**Use Case:** Development and staging environments where alerting is needed but with more relaxed thresholds.

### 3. Basic Example (`sqlmi_alerts_basic`)
Minimal monitoring configuration with all alerts but very relaxed thresholds for testing.

**Features:**
- All 5 metric alerts enabled
- Very relaxed thresholds (85% CPU warning, 85% storage warning)
- No diagnostic settings
- Single managed instance
- Minimal overhead

**Use Case:** Testing environments, proof-of-concept, or cost-sensitive deployments.

## Alert Categories

The module provides comprehensive monitoring across three categories:

### CPU Alerts (2 alerts)
- **CPU Warning**: Monitors CPU utilization percentage - warning threshold
- **CPU Critical**: Monitors CPU utilization percentage - critical threshold (severity 1)

### Storage Alerts (2 alerts)
- **Storage Warning**: Tracks storage space utilization - warning threshold
- **Storage Critical**: Monitors storage space utilization - critical threshold (severity 1)

### vCore Alerts (1 alert)
- **vCore Warning**: Monitors virtual core utilization percentage

## Prerequisites

Before deploying these examples, ensure you have:

1. **Azure Resources**:
   - One or more Azure SQL Managed Instances
   - Action Group for alert notifications
   - (Optional) Event Hub namespace and hub for activity logs
   - (Optional) Log Analytics workspace for security logs

2. **Permissions**:
   - `Microsoft.Insights/metricAlerts/write` - Create metric alerts
   - `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
   - `Microsoft.Sql/managedInstances/read` - Read SQL MI properties
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
terraform apply -target=module.sqlmi_alerts_production

# Deploy only development example
terraform apply -target=module.sqlmi_alerts_development

# Deploy only basic example
terraform apply -target=module.sqlmi_alerts_basic
```

### 3. Customize Configuration

Create a `terraform.tfvars` file or modify the example directly:

```hcl
# Custom production deployment
module "sqlmi_alerts_custom" {
  source = "../"

  resource_group_name              = "my-sqlmi-rg"
  sql_mi_names                     = ["my-sqlmi-prod-01", "my-sqlmi-prod-02"]
  sql_mi_resource_group            = "my-sqlmi-rg"
  action_group_resource_group_name = "my-monitoring-rg"
  action_group                     = "my-action-group"

  # Customize thresholds
  cpu_warning_threshold     = 75
  cpu_critical_threshold    = 90
  storage_warning_threshold = 80
  storage_critical_threshold = 90

  # Configure evaluation settings
  evaluation_frequency = "PT5M"
  window_size          = "PT15M"

  # Configure diagnostic settings
  enable_diagnostic_settings         = true
  eventhub_namespace_name            = "my-eventhub-ns"
  eventhub_name                      = "my-eventhub"
  eventhub_resource_group_name       = "my-eventhub-rg"
  log_analytics_workspace_name       = "my-law"
  log_analytics_resource_group_name  = "my-law-rg"

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
- **monitored_resources**: Map of SQL MI names and IDs
- **action_group_id**: Action group resource ID
- **diagnostic_settings**: Diagnostic setting resource IDs (Event Hub and Log Analytics)
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
| `resource_group_name` | Action group resource group | Yes | "" |
| `sql_mi_names` | List of SQL MI names | Yes | [] |
| `sql_mi_resource_group` | SQL MI resource group | Yes | "rg-amba" |
| `action_group_resource_group_name` | Action group resource group | Yes | - |
| `action_group` | Action group name | Yes | "" |

### Threshold Variables

All alerts are created for all specified managed instances. Control sensitivity by adjusting thresholds:

| Variable | Metric | Production | Development | Basic |
|----------|--------|------------|-------------|-------|
| `cpu_warning_threshold` | CPU % (warning) | 70 | 80 | 85 |
| `cpu_critical_threshold` | CPU % (critical) | 85 | 90 | 95 |
| `storage_warning_threshold` | Storage % (warning) | 75 | 80 | 85 |
| `storage_critical_threshold` | Storage % (critical) | 85 | 90 | 95 |

### Evaluation Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `evaluation_frequency` | How often to evaluate alerts | PT5M (5 minutes) |
| `window_size` | Time window for evaluation | PT15M (15 minutes) |

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
  --resource-group rg-sqlmi-prod \
  --output table

# Check diagnostic settings for SQL MI
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-sqlmi-prod/providers/Microsoft.Sql/managedInstances/pge-sqlmi-prod-001 \
  --output table

# Test alert by generating load
# Run queries to increase CPU, storage usage, etc.
```

## Troubleshooting

### Common Issues

1. **Alert not triggering**:
   - Verify threshold values are appropriate for your workload
   - Check SQL MI names exist in the specified resource group
   - Confirm action group is properly configured
   - Review metric values in Azure Portal

2. **Diagnostic settings not working**:
   - Verify Event Hub/Log Analytics workspace exists
   - Check permissions on destination resources
   - Confirm `enable_diagnostic_settings = true`
   - Verify subscription IDs if using cross-subscription

3. **Module errors**:
   - Ensure SQL Managed Instances exist in specified resource group
   - Verify action group exists and is accessible
   - Check AzureRM provider version compatibility
   - Confirm instance names don't have extra spaces

4. **vCore alert not appearing**:
   - vCore metrics are only available for vCore-based purchasing model
   - Not applicable to DTU-based instances

## Cost Considerations

- **Metric Alerts**: ~$0.10 per alert rule per month
- **Diagnostic Settings**: Data ingestion costs for Event Hub and Log Analytics
- **Production Example**: ~$1.00/month for alerts (2 instances × 5 alerts × $0.10)
- **Development Example**: ~$0.50/month for alerts (1 instance × 5 alerts × $0.10)
- **Basic Example**: ~$0.50/month for alerts (1 instance × 5 alerts × $0.10)

Plus diagnostic logging costs based on data volume.

## Security Considerations

1. **Least Privilege**: Use managed identities or service principals with minimal required permissions
2. **Sensitive Data**: Store Event Hub and Log Analytics credentials in Key Vault
3. **Network Security**: Use private endpoints for Event Hub and Log Analytics if available
4. **Access Control**: Restrict access to diagnostic logs containing sensitive data
5. **Data Classification**: Apply appropriate tags based on data sensitivity
6. **SQL Injection**: Monitor for suspicious query patterns in logs

## Additional Resources

- [Azure SQL Managed Instance Documentation](https://docs.microsoft.com/azure/azure-sql/managed-instance/)
- [Azure Monitor Metrics for SQL MI](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftsqlmanagedinstances)
- [SQL MI Best Practices](https://docs.microsoft.com/azure/azure-sql/managed-instance/management-operations-overview)
- [SQL MI Troubleshooting](https://docs.microsoft.com/azure/azure-sql/managed-instance/troubleshoot-common-connectivity-issues)
- [Module Documentation](../README.md)

## Support

For issues, questions, or contributions, please refer to the main module repository.
