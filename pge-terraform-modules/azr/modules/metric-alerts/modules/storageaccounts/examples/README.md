# Azure Storage Account Monitoring Module - Examples

This directory contains example configurations for deploying the Azure Storage Account monitoring module in different scenarios.

## Available Examples

### 1. Production Example (`storage_alerts_production`)
Complete monitoring configuration with all 6 alerts enabled and tight thresholds suitable for production storage accounts.

**Features:**
- All 6 metric alerts enabled for 3 Storage Accounts
- Production-grade thresholds (99.9% availability, 500ms latency, 85% capacity)
- Full diagnostic settings (Event Hub + Log Analytics)
- Multiple storage accounts
- Comprehensive monitoring coverage

**Use Case:** Production Storage Account deployments requiring comprehensive monitoring, alerting, and compliance with diagnostic log retention.

### 2. Development Example (`storage_alerts_development`)
Balanced monitoring configuration with all alerts and relaxed thresholds for development environments.

**Features:**
- All 6 metric alerts enabled for 2 Storage Accounts
- Relaxed thresholds (99% availability, 1000ms latency, 90% capacity)
- Event Hub diagnostic settings only
- Multiple storage accounts
- Focused on critical metrics

**Use Case:** Development and staging environments where alerting is needed but with more relaxed thresholds.

### 3. Basic Example (`storage_alerts_basic`)
Minimal monitoring configuration with all alerts but very relaxed thresholds for testing.

**Features:**
- All 6 metric alerts enabled
- Very relaxed thresholds (95% availability, 2000ms latency, 95% capacity)
- No diagnostic settings
- Single storage account
- Minimal overhead

**Use Case:** Testing environments, proof-of-concept, or cost-sensitive deployments.

## Alert Categories

The module provides comprehensive monitoring across four categories:

### Availability Alerts (1 alert)
- **Availability**: Monitors storage account availability percentage

### Performance Alerts (3 alerts)
- **E2E Latency**: Tracks end-to-end latency in milliseconds
- **Server Latency**: Monitors server-side latency in milliseconds
- **Transactions**: Tracks transaction rate per minute

### Capacity Alerts (1 alert)
- **Capacity**: Monitors storage capacity utilization percentage

### Error Alerts (1 alert)
- **Errors**: Tracks failed transactions and error rates

## Prerequisites

Before deploying these examples, ensure you have:

1. **Azure Resources**:
   - One or more Azure Storage Accounts
   - Action Group for alert notifications
   - (Optional) Event Hub namespace and hub for activity logs
   - (Optional) Log Analytics workspace for security logs

2. **Permissions**:
   - `Microsoft.Insights/metricAlerts/write` - Create metric alerts
   - `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
   - `Microsoft.Storage/storageAccounts/read` - Read Storage Account properties
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
terraform apply -target=module.storage_alerts_production

# Deploy only development example
terraform apply -target=module.storage_alerts_development

# Deploy only basic example
terraform apply -target=module.storage_alerts_basic
```

### 3. Customize Configuration

Create a `terraform.tfvars` file or modify the example directly:

```hcl
# Custom production deployment
module "storage_alerts_custom" {
  source = "../"

  resource_group_name              = "my-storage-rg"
  storage_account_names            = ["mystgacct001", "mystgacct002"]
  action_group_resource_group_name = "my-monitoring-rg"
  action_group                     = "my-action-group"

  # Customize thresholds
  storage_availability_threshold    = 99.5
  storage_capacity_threshold        = 80
  storage_transaction_threshold     = 10000
  storage_latency_threshold         = 800
  storage_server_latency_threshold  = 80

  # Configure diagnostic settings
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "my-eventhub-ns"
  eventhub_name                     = "my-eventhub"
  eventhub_resource_group_name      = "my-eventhub-rg"
  log_analytics_workspace_name      = "my-law"
  log_analytics_resource_group_name = "my-law-rg"

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
- **monitored_resources**: Map of Storage Account names and IDs
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
| `resource_group_name` | Storage Account resource group | Yes | "" |
| `storage_account_names` | List of Storage Account names | Yes | [] |
| `action_group_resource_group_name` | Action group resource group | Yes | - |
| `action_group` | Action group name | Yes | "" |

### Threshold Variables

All alerts are created for all specified storage accounts. Control sensitivity by adjusting thresholds:

| Variable | Metric | Production | Development | Basic |
|----------|--------|------------|-------------|-------|
| `storage_availability_threshold` | Availability % (min) | 99.9 | 99 | 95 |
| `storage_capacity_threshold` | Capacity % (max) | 85 | 90 | 95 |
| `storage_transaction_threshold` | Transactions/min (max) | 15000 | 20000 | 50000 |
| `storage_latency_threshold` | E2E Latency ms (max) | 500 | 1000 | 2000 |
| `storage_server_latency_threshold` | Server Latency ms (max) | 50 | 100 | 200 |

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
  --resource-group rg-storage-prod \
  --output table

# Check diagnostic settings for storage account
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-storage-prod/providers/Microsoft.Storage/storageAccounts/pgestgprod001 \
  --output table

# Test alert by generating load
# Upload/download files to trigger latency and transaction alerts
```

## Troubleshooting

### Common Issues

1. **Alert not triggering**:
   - Verify threshold values are appropriate for your workload
   - Check storage account names exist in the specified resource group
   - Confirm action group is properly configured
   - Review metric values in Azure Portal

2. **Diagnostic settings not working**:
   - Verify Event Hub/Log Analytics workspace exists
   - Check permissions on destination resources
   - Confirm `enable_diagnostic_settings = true`
   - Verify subscription IDs if using cross-subscription

3. **Module errors**:
   - Ensure Storage Accounts exist in specified resource group
   - Verify action group exists and is accessible
   - Check AzureRM provider version compatibility
   - Confirm storage account names follow Azure naming rules (lowercase, alphanumeric)

4. **Capacity alert issues**:
   - Capacity metrics may vary by storage account tier
   - Premium storage has different capacity characteristics
   - Consider adjusting thresholds based on account type

## Cost Considerations

- **Metric Alerts**: ~$0.10 per alert rule per month
- **Diagnostic Settings**: Data ingestion costs for Event Hub and Log Analytics
- **Production Example**: ~$1.80/month for alerts (3 accounts × 6 alerts × $0.10)
- **Development Example**: ~$1.20/month for alerts (2 accounts × 6 alerts × $0.10)
- **Basic Example**: ~$0.60/month for alerts (1 account × 6 alerts × $0.10)

Plus diagnostic logging costs based on data volume.

## Security Considerations

1. **Least Privilege**: Use managed identities or service principals with minimal required permissions
2. **Sensitive Data**: Store Event Hub and Log Analytics credentials in Key Vault
3. **Network Security**: Use private endpoints for Event Hub and Log Analytics if available
4. **Access Control**: Restrict access to diagnostic logs containing access patterns
5. **Data Classification**: Apply appropriate tags based on data sensitivity
6. **Storage Keys**: Monitor for unauthorized access attempts via error metrics

## Additional Resources

- [Azure Storage Documentation](https://docs.microsoft.com/azure/storage/)
- [Azure Monitor Metrics for Storage](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftstoragestorageaccounts)
- [Storage Best Practices](https://docs.microsoft.com/azure/storage/common/storage-performance-checklist)
- [Storage Troubleshooting](https://docs.microsoft.com/azure/storage/common/storage-monitoring-diagnosing-troubleshooting)
- [Module Documentation](../README.md)

## Support

For issues, questions, or contributions, please refer to the main module repository.
