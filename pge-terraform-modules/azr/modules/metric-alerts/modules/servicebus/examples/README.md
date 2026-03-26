# Azure Service Bus Monitoring Module - Examples

This directory contains example configurations for deploying the Azure Service Bus monitoring module in different scenarios.

## Available Examples

### 1. Production Example (`servicebus_alerts_production`)
Complete monitoring configuration with all 14 alerts enabled and tight thresholds suitable for production workloads.

**Features:**
- All 14 metric alerts enabled
- Production-grade thresholds
- Full diagnostic settings (Event Hub + Log Analytics)
- Multiple Service Bus namespace instances
- Comprehensive monitoring coverage

**Use Case:** Production Service Bus deployments requiring comprehensive monitoring, alerting, and compliance with diagnostic log retention.

### 2. Development Example (`servicebus_alerts_development`)
Balanced monitoring configuration with 10 key alerts and relaxed thresholds for development environments.

**Features:**
- 10 essential metric alerts enabled
- Relaxed thresholds
- Event Hub diagnostic settings only
- Single Service Bus namespace instance
- Focused on critical metrics

**Use Case:** Development and staging environments where alerting is needed but with more relaxed thresholds.

### 3. Basic Example (`servicebus_alerts_basic`)
Minimal monitoring configuration with 5 critical alerts for testing.

**Features:**
- 5 critical metric alerts enabled
- Very relaxed thresholds
- No diagnostic settings
- Single Service Bus namespace instance
- Minimal overhead

**Use Case:** Testing environments, proof-of-concept, or cost-sensitive deployments.

## Alert Categories

The module provides comprehensive monitoring across four categories:

### Request Metrics (5 alerts)
- **Incoming Requests**: Monitors total incoming requests
- **Successful Requests Low**: Alerts when successful requests drop below threshold
- **Server Errors**: Tracks server-side errors
- **User Errors**: Monitors user/client errors
- **Throttled Requests**: Tracks requests throttled due to limits

### Message Metrics (5 alerts)
- **Incoming Messages**: Monitors messages sent to Service Bus
- **Outgoing Messages**: Tracks messages delivered from Service Bus
- **Active Messages**: Monitors messages in active state
- **Dead Letter Messages**: Tracks messages moved to dead letter queue
- **Scheduled Messages**: Monitors scheduled/deferred messages

### Connection Metrics (3 alerts)
- **Active Connections**: Tracks current active connections
- **Connections Opened**: Monitors new connections established
- **Connections Closed**: Tracks connection closures

### Resource Metrics (1 alert)
- **Size**: Monitors namespace storage utilization

## Prerequisites

Before deploying these examples, ensure you have:

1. **Azure Resources**:
   - One or more Azure Service Bus Namespaces
   - Action Group for alert notifications
   - (Optional) Event Hub namespace and hub for activity logs
   - (Optional) Log Analytics workspace for security logs

2. **Permissions**:
   - `Microsoft.Insights/metricAlerts/write` - Create metric alerts
   - `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
   - `Microsoft.ServiceBus/namespaces/read` - Read Service Bus properties
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
terraform apply -target=module.servicebus_alerts_production

# Deploy only development example
terraform apply -target=module.servicebus_alerts_development

# Deploy only basic example
terraform apply -target=module.servicebus_alerts_basic
```

### 3. Customize Configuration

Create a `terraform.tfvars` file or modify the example directly:

```hcl
# Custom production deployment
module "servicebus_alerts_custom" {
  source = "../"

  resource_group_name              = "my-servicebus-rg"
  servicebus_namespace_names       = ["my-servicebus-ns"]
  action_group_resource_group_name = "my-monitoring-rg"
  action_group                     = "my-action-group"

  # Enable specific alerts
  enable_servicebus_incoming_requests_alert = true
  enable_servicebus_server_errors_alert     = true
  enable_servicebus_dead_letter_messages_alert = true
  # ... other alert flags

  # Customize thresholds
  servicebus_incoming_requests_threshold    = 15000
  servicebus_server_errors_threshold        = 10
  servicebus_dead_letter_messages_threshold = 5

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
- **monitored_resources**: List of Service Bus namespace names being monitored
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
| `resource_group_name` | Service Bus resource group | Yes | "" |
| `servicebus_namespace_names` | List of Service Bus namespace names to monitor | Yes | [] |
| `action_group_resource_group_name` | Action group resource group | Yes | - |
| `action_group` | Action group name | Yes | "" |

### Alert Enable Flags

Each alert can be individually enabled/disabled:

| Variable | Alert Type | Default |
|----------|------------|---------|
| `enable_servicebus_incoming_requests_alert` | Incoming Requests | true |
| `enable_servicebus_successful_requests_alert` | Successful Requests Low | true |
| `enable_servicebus_server_errors_alert` | Server Errors | true |
| `enable_servicebus_user_errors_alert` | User Errors | true |
| `enable_servicebus_throttled_requests_alert` | Throttled Requests | true |
| `enable_servicebus_incoming_messages_alert` | Incoming Messages | true |
| `enable_servicebus_outgoing_messages_alert` | Outgoing Messages | true |
| `enable_servicebus_active_connections_alert` | Active Connections | true |
| `enable_servicebus_connections_opened_alert` | Connections Opened | true |
| `enable_servicebus_connections_closed_alert` | Connections Closed | true |
| `enable_servicebus_size_alert` | Namespace Size | true |
| `enable_servicebus_active_messages_alert` | Active Messages | true |
| `enable_servicebus_dead_letter_messages_alert` | Dead Letter Messages | true |
| `enable_servicebus_scheduled_messages_alert` | Scheduled Messages | true |

### Threshold Variables

| Variable | Metric | Production | Development | Basic |
|----------|--------|------------|-------------|-------|
| `servicebus_incoming_requests_threshold` | Requests/min | 10000 | 20000 | 50000 |
| `servicebus_successful_requests_threshold` | Requests/min (min) | 5 | - | - |
| `servicebus_server_errors_threshold` | Errors/min | 5 | 10 | 20 |
| `servicebus_user_errors_threshold` | Errors/min | 10 | 20 | - |
| `servicebus_throttled_requests_threshold` | Requests/min | 5 | 10 | 20 |
| `servicebus_incoming_messages_threshold` | Messages/min | 10000 | 20000 | - |
| `servicebus_outgoing_messages_threshold` | Messages/min | 10000 | 20000 | - |
| `servicebus_active_connections_threshold` | Connections | 100 | - | - |
| `servicebus_connections_opened_threshold` | Connections/min | 50 | - | - |
| `servicebus_connections_closed_threshold` | Connections/min | 50 | - | - |
| `servicebus_size_threshold` | Bytes | 80GB | 100GB | 120GB |
| `servicebus_active_messages_threshold` | Messages | 1000 | 2000 | - |
| `servicebus_dead_letter_messages_threshold` | Messages | 10 | 20 | 50 |
| `servicebus_scheduled_messages_threshold` | Messages | 1000 | - | - |

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
  --resource-group rg-servicebus-prod \
  --output table

# Check diagnostic settings
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-servicebus-prod/providers/Microsoft.ServiceBus/namespaces/sbns-prod-001 \
  --output table

# Test alert by generating load
# Send messages to Service Bus to trigger alerts
```

## Troubleshooting

### Common Issues

1. **Alert not triggering**:
   - Verify threshold values are appropriate for your workload
   - Check alert is enabled (enable flag = true)
   - Confirm action group is properly configured
   - Review metric values in Azure Portal

2. **Diagnostic settings not working**:
   - Verify Event Hub/Log Analytics workspace exists
   - Check permissions on destination resources
   - Confirm `enable_diagnostic_settings = true`
   - Verify subscription IDs if using cross-subscription

3. **Module errors**:
   - Ensure Service Bus namespace names exist in specified resource group
   - Verify action group exists and is accessible
   - Check AzureRM provider version compatibility

## Cost Considerations

- **Metric Alerts**: ~$0.10 per alert rule per month
- **Diagnostic Settings**: Data ingestion costs for Event Hub and Log Analytics
- **Production Example**: ~$1.40/month for alerts (14 alerts × $0.10)
- **Development Example**: ~$1.00/month for alerts (10 alerts × $0.10)
- **Basic Example**: ~$0.50/month for alerts (5 alerts × $0.10)

Plus diagnostic logging costs based on data volume.

## Security Considerations

1. **Least Privilege**: Use managed identities or service principals with minimal required permissions
2. **Sensitive Data**: Store Event Hub and Log Analytics credentials in Key Vault
3. **Network Security**: Use private endpoints for Event Hub and Log Analytics if available
4. **Access Control**: Restrict access to diagnostic logs containing sensitive data
5. **Data Classification**: Apply appropriate tags based on data sensitivity

## Additional Resources

- [Azure Service Bus Documentation](https://docs.microsoft.com/azure/service-bus-messaging/)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftservicebusnamespaces)
- [Service Bus Best Practices](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-performance-improvements)
- [Service Bus Troubleshooting](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-messaging-exceptions)
- [Module Documentation](../README.md)

## Support

For issues, questions, or contributions, please refer to the main module repository.
