# Azure Redis Cache Monitoring Module - Examples

This directory contains example configurations for deploying the Azure Redis Cache monitoring module in different scenarios.

## Available Examples

### 1. Production Example (`redis_alerts_production`)
Complete monitoring configuration with all alerts enabled and tight thresholds suitable for production workloads.

**Features:**
- All 12 metric alerts enabled
- Production-grade thresholds (80-85% for critical metrics)
- Full diagnostic settings (Event Hub + Log Analytics)
- Multiple Redis cache instances
- Comprehensive monitoring coverage

**Use Case:** Production Redis deployments requiring comprehensive monitoring, alerting, and compliance with diagnostic log retention.

### 2. Development Example (`redis_alerts_development`)
Balanced monitoring configuration with key alerts and relaxed thresholds for development environments.

**Features:**
- 6 essential metric alerts enabled
- Relaxed thresholds (90% for critical metrics, 30% cache miss rate)
- Event Hub diagnostic settings only
- Single Redis cache instance
- Focused on critical performance metrics

**Use Case:** Development and staging environments where some alerting is needed but not full production coverage.

### 3. Basic Example (`redis_alerts_basic`)
Minimal monitoring configuration with only critical alerts for testing.

**Features:**
- 2 critical metric alerts (CPU and Memory)
- Very relaxed thresholds (95%)
- No diagnostic settings
- Single Redis cache instance
- Minimal overhead

**Use Case:** Testing environments, proof-of-concept, or cost-sensitive deployments.

## Alert Categories

The module provides comprehensive monitoring across five categories:

### Performance Alerts
- **CPU Usage**: Monitors processor utilization by ShardId
- **Memory Usage**: Tracks memory consumption by ShardId
- **Server Load**: Measures overall server load by ShardId
- **Operations Per Second**: Monitors command execution rate

### Connectivity Alerts
- **Connected Clients**: Tracks active client connections by ShardId

### Cache Health Alerts
- **Cache Miss Rate**: Monitors cache effectiveness
- **Evicted Keys**: Tracks keys removed due to memory pressure
- **Expired Keys**: Monitors key expiration rate
- **Total Keys**: Tracks total key count in cache

### Bandwidth Alerts
- **Cache Read Bandwidth**: Monitors data read throughput
- **Cache Write Bandwidth**: Monitors data write throughput

### Operations Alerts
- **Total Commands Processed**: Tracks cumulative command execution

## Prerequisites

Before deploying these examples, ensure you have:

1. **Azure Resources**:
   - One or more Azure Redis Cache instances
   - Action Group for alert notifications
   - (Optional) Event Hub namespace and hub for activity logs
   - (Optional) Log Analytics workspace for security logs

2. **Permissions**:
   - `Microsoft.Insights/metricAlerts/write` - Create metric alerts
   - `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
   - `Microsoft.Cache/Redis/read` - Read Redis cache properties
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
terraform apply -target=module.redis_alerts_production

# Deploy only development example
terraform apply -target=module.redis_alerts_development

# Deploy only basic example
terraform apply -target=module.redis_alerts_basic
```

### 3. Customize Configuration

Create a `terraform.tfvars` file or modify the example directly:

```hcl
# Custom production deployment
module "redis_alerts_custom" {
  source = "../"

  resource_group_name              = "my-redis-rg"
  redis_cache_names                = ["my-redis-cache"]
  action_group_resource_group_name = "my-monitoring-rg"
  action_group                     = "my-action-group"

  # Customize thresholds
  redis_cpu_threshold    = 75
  redis_memory_threshold = 80

  # Enable specific alerts
  enable_redis_cpu_alert    = true
  enable_redis_memory_alert = true
  # ... other alert flags

  # Configure diagnostic settings
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "my-eventhub-ns"
  eventhub_name                    = "my-eventhub"
  eventhub_resource_group_name     = "my-eventhub-rg"
  log_analytics_workspace_name     = "my-law"
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
- **monitored_resources**: List of Redis cache names being monitored
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
| `resource_group_name` | Redis Cache resource group | Yes | - |
| `redis_cache_names` | List of Redis cache names to monitor | Yes | - |
| `action_group_resource_group_name` | Action group resource group | Yes | - |
| `action_group` | Action group name | Yes | - |

### Alert Enable Flags

Each alert can be individually enabled/disabled:

| Variable | Alert Type | Default |
|----------|------------|---------|
| `enable_redis_cpu_alert` | CPU Usage | true |
| `enable_redis_memory_alert` | Memory Usage | true |
| `enable_redis_server_load_alert` | Server Load | true |
| `enable_redis_connected_clients_alert` | Connected Clients | true |
| `enable_redis_cache_miss_rate_alert` | Cache Miss Rate | true |
| `enable_redis_evicted_keys_alert` | Evicted Keys | true |
| `enable_redis_expired_keys_alert` | Expired Keys | true |
| `enable_redis_total_keys_alert` | Total Keys | true |
| `enable_redis_operations_per_second_alert` | Operations/Second | true |
| `enable_redis_cache_read_bandwidth_alert` | Read Bandwidth | true |
| `enable_redis_cache_write_bandwidth_alert` | Write Bandwidth | true |
| `enable_redis_total_commands_processed_alert` | Total Commands | true |

### Threshold Variables

| Variable | Metric | Production | Development | Basic |
|----------|--------|------------|-------------|-------|
| `redis_cpu_threshold` | CPU % | 80 | 90 | 95 |
| `redis_memory_threshold` | Memory % | 85 | 90 | 95 |
| `redis_server_load_threshold` | Server Load % | 80 | 90 | - |
| `redis_connected_clients_threshold` | Client Count | 900 | - | - |
| `redis_cache_miss_rate_threshold` | Cache Miss % | 20 | 30 | - |
| `redis_evicted_keys_threshold` | Evicted Keys | 100 | - | - |
| `redis_expired_keys_threshold` | Expired Keys | 1000 | - | - |
| `redis_total_keys_threshold` | Total Keys | 900000 | - | - |
| `redis_operations_per_second_threshold` | Ops/Sec | 9000 | 5000 | - |
| `redis_cache_read_bandwidth_threshold` | Read Bytes/Sec | 900MB | - | - |
| `redis_cache_write_bandwidth_threshold` | Write Bytes/Sec | 900MB | - | - |
| `redis_total_commands_processed_threshold` | Commands | 90000 | - | - |

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
  --resource-group rg-redis-prod \
  --output table

# Check diagnostic settings
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-redis-prod/providers/Microsoft.Cache/Redis/redis-cache-prod-001 \
  --output table

# Test alert by generating high CPU load
# (Use Redis benchmark tool or application load)
redis-benchmark -h redis-cache-prod-001.redis.cache.windows.net -a <access-key> -t set,get -n 1000000 -q
```

## Troubleshooting

### Common Issues

1. **Alert not triggering**:
   - Verify threshold values are appropriate for your workload
   - Check alert is enabled (`enable_redis_*_alert = true`)
   - Confirm action group is properly configured
   - Review metric values in Azure Portal

2. **Diagnostic settings not working**:
   - Verify Event Hub/Log Analytics workspace exists
   - Check permissions on destination resources
   - Confirm `enable_diagnostic_settings = true`
   - Verify subscription IDs if using cross-subscription

3. **Module errors**:
   - Ensure Redis cache names exist in specified resource group
   - Verify action group exists and is accessible
   - Check AzureRM provider version compatibility

## Cost Considerations

- **Metric Alerts**: ~$0.10 per alert rule per month
- **Diagnostic Settings**: Data ingestion costs for Event Hub and Log Analytics
- **Production Example**: ~$1.20/month for alerts (12 alerts × $0.10)
- **Development Example**: ~$0.60/month for alerts (6 alerts × $0.10)
- **Basic Example**: ~$0.20/month for alerts (2 alerts × $0.10)

Plus diagnostic logging costs based on data volume.

## Security Considerations

1. **Least Privilege**: Use managed identities or service principals with minimal required permissions
2. **Sensitive Data**: Store Event Hub and Log Analytics credentials in Key Vault
3. **Network Security**: Use private endpoints for Event Hub and Log Analytics if available
4. **Access Control**: Restrict access to diagnostic logs containing sensitive data
5. **Data Classification**: Apply appropriate tags based on data sensitivity

## Additional Resources

- [Azure Redis Cache Documentation](https://docs.microsoft.com/azure/azure-cache-for-redis/)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftcacheredis)
- [Redis Cache Best Practices](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-best-practices)
- [Redis Cache Troubleshooting](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-troubleshoot)
- [Module Documentation](../README.md)

## Support

For issues, questions, or contributions, please refer to the main module repository.
