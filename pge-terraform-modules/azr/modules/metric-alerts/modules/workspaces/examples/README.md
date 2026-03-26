# Azure Log Analytics Workspace Monitoring Module - Examples

This directory contains example configurations for using the Azure Log Analytics Workspace Monitoring module in various deployment scenarios.

## Overview

The Azure Log Analytics Workspace Monitoring module provides comprehensive monitoring capabilities for Log Analytics Workspaces, including:

- **6 Scheduled Query Rules**: Heartbeat, query performance, data retention, error rate, agent connection, and custom table ingestion monitoring
- **2 Diagnostic Settings**: Integration with Event Hub and Log Analytics for centralized logging
- **Audit Logs**: Workspace configuration and access monitoring

## Prerequisites

Before using these examples, ensure you have:

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group for Log Analytics Workspaces
3. **Action Group**: Pre-configured action group for alert notifications (e.g., "PGE-Operations")
4. **Log Analytics Workspaces**: Existing Azure Log Analytics Workspaces to monitor
5. **Optional - Event Hub**: For SIEM integration and external log streaming
6. **Optional - Central Log Analytics Workspace**: For centralized log analysis of workspace audit logs
7. **Optional - Monitoring Agents**: For heartbeat and agent connection monitoring

## Example Scenarios

### Example 1: Production Workspaces with Full Monitoring

**Use Case**: Comprehensive monitoring for production Log Analytics Workspaces with SIEM integration

**Features**:
- Monitors 3 production workspaces (security, operations, applications)
- All 6 alert types enabled
- Stricter thresholds for production environment
- Custom table ingestion monitoring
- Diagnostic settings for both Event Hub (SIEM) and Log Analytics
- 90-day retention with 14-day warning period

**Alert Configuration**:
- Heartbeat: 3 missing heartbeats (Severity 2, PT5M)
- Query Performance: 20 seconds threshold (Severity 3, PT15M)
- Data Retention: 14 days before expiry (Severity 3, P1D)
- Error Rate: 5% threshold (Severity 2, PT15M)
- Agent Connection: 3 connection issues (Severity 3, PT15M)
- Custom Table: 50 MB minimum ingestion (Severity 3, PT30M)

**Monitored Workspaces**: law-pge-security-prod, law-pge-operations-prod, law-pge-applications-prod

### Example 2: Development Workspaces with Selective Monitoring

**Use Case**: Monitoring for development workspaces with cost optimization

**Features**:
- Monitors 2 development workspaces
- Core alerts only (heartbeat, query performance, error rate)
- More relaxed thresholds
- Log Analytics only (no Event Hub for cost savings)
- 30-day retention with 7-day warning period

**Alert Configuration**:
- Heartbeat: 10 missing heartbeats (Severity 2, PT5M)
- Query Performance: 60 seconds threshold (Severity 3, PT15M)
- Error Rate: 20% threshold (Severity 2, PT15M)

**Monitored Workspaces**: law-pge-dev, law-pge-test

### Example 3: Basic Workspace Monitoring (Alerts Only)

**Use Case**: Minimal monitoring for test/sandbox workspaces

**Features**:
- Monitors 1 test workspace
- Heartbeat alert only
- No diagnostic settings (cost-optimized for testing)
- Alert-only configuration

**Alert Configuration**:
- Heartbeat: 10 missing heartbeats (Severity 2, PT5M)

**Monitored Workspaces**: law-pge-sandbox

## Usage

### Step 1: Configure Provider

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Step 2: Reference Action Group

The examples assume a pre-existing action group for notifications:

```hcl
data "azurerm_monitor_action_group" "pge_operations" {
  name                = "PGE-Operations"
  resource_group_name = "rg-pge-monitoring-prod"
}
```

### Step 3: Deploy Module

Choose the appropriate example based on your environment:

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Step 4: Verify Deployment

After deployment, verify the alerts are active:

```bash
# List all scheduled query rules
az monitor scheduled-query list --resource-group rg-pge-monitoring-prod

# View diagnostic settings for a workspace
az monitor diagnostic-settings list --resource <workspace-resource-id>

# Run a test query in the workspace
az monitor log-analytics query --workspace <workspace-id> --analytics-query "Heartbeat | take 10"
```

## Alert Details

### Scheduled Query Rules

#### 1. Heartbeat Alert
- **Name**: `workspace-heartbeat-missing-{workspace-names}`
- **Severity**: 2 (Warning)
- **Query**: Detects agents that haven't sent heartbeat in 10 minutes
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)
- **Threshold**: Configurable (default: 5 missing heartbeats)
- **Use Case**: Monitor agent health and connectivity

#### 2. Query Performance Alert
- **Name**: `workspace-query-performance-slow-{workspace-names}`
- **Severity**: 3 (Informational)
- **Query**: Detects queries exceeding performance threshold
- **Window**: PT30M (30 minutes)
- **Frequency**: PT15M (15 minutes)
- **Threshold**: Configurable (default: 30,000ms)
- **Use Case**: Identify slow-running queries affecting workspace performance

#### 3. Data Retention Alert
- **Name**: `workspace-data-retention-expiring-{workspace-names}`
- **Severity**: 3 (Informational)
- **Query**: Warns when data approaches retention limit
- **Window**: P1D (1 day)
- **Frequency**: P1D (1 day)
- **Threshold**: Configurable warning days (default: 7 days before expiry)
- **Use Case**: Prevent unexpected data loss from retention policies

#### 4. Error Rate Alert
- **Name**: `workspace-error-rate-high-{workspace-names}`
- **Severity**: 2 (Warning)
- **Query**: Calculates error rate percentage from Operation table
- **Window**: PT30M (30 minutes)
- **Frequency**: PT15M (15 minutes)
- **Threshold**: Configurable (default: 10%)
- **Use Case**: Detect operational issues in workspace

#### 5. Agent Connection Alert
- **Name**: `workspace-agent-connection-lost-{workspace-names}`
- **Severity**: 3 (Informational)
- **Query**: Detects connection/timeout issues from agents
- **Window**: PT1H (1 hour)
- **Frequency**: PT15M (15 minutes)
- **Threshold**: Configurable (default: 5 connection issues)
- **Use Case**: Monitor network connectivity for data collection agents

#### 6. Custom Table Ingestion Alert
- **Name**: `workspace-custom-table-ingestion-low-{workspace-names}`
- **Severity**: 3 (Informational)
- **Query**: Monitors data volume for specified custom tables
- **Window**: PT2H (2 hours)
- **Frequency**: PT30M (30 minutes)
- **Threshold**: Configurable (default: 100 MB)
- **Use Case**: Ensure critical custom data is being ingested

## Diagnostic Settings

### Event Hub Integration

Sends workspace audit logs to Event Hub for SIEM integration:

- **Log Categories**: `Audit`
- **Metrics**: Disabled for Event Hub destination
- **Use Case**: External SIEM systems, compliance, real-time monitoring

### Log Analytics Integration

Sends workspace audit logs and metrics to central Log Analytics:

- **Log Categories**: `Audit`
- **Metrics**: `AllMetrics` enabled
- **Use Case**: Centralized logging, query-based analysis, dashboards

### Log Category Details

#### Audit
Captures workspace management and access events including:
- Configuration changes
- Access and authentication events
- Query execution (administrative)
- Data collection modifications
- Workspace management operations

## Cross-Subscription Support

The module supports cross-subscription scenarios for diagnostic settings:

```hcl
# Event Hub in different subscription
eventhub_subscription_id      = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
eventhub_resource_group_name  = "rg-shared-monitoring"

# Log Analytics in different subscription
log_analytics_subscription_id      = "ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj"
log_analytics_resource_group_name  = "rg-shared-analytics"
```

## Customization

### Adjusting Thresholds

Customize alert sensitivity based on your environment:

```hcl
# Production: Strict thresholds
workspace_heartbeat_threshold         = 3
workspace_query_performance_threshold = 20000 # 20 seconds
workspace_error_rate_threshold        = 5     # 5%

# Development: Relaxed thresholds
workspace_heartbeat_threshold         = 10
workspace_query_performance_threshold = 60000 # 60 seconds
workspace_error_rate_threshold        = 20    # 20%
```

### Selective Alert Enablement

Enable only the alerts you need:

```hcl
# Production: All alerts
enable_workspace_heartbeat_alert         = true
enable_workspace_query_performance_alert = true
enable_workspace_data_retention_alert    = true
enable_workspace_error_rate_alert        = true
enable_workspace_agent_connection_alert  = true
enable_workspace_custom_table_alert      = true

# Development: Core alerts only
enable_workspace_heartbeat_alert         = true
enable_workspace_query_performance_alert = true
enable_workspace_data_retention_alert    = false
enable_workspace_error_rate_alert        = true
enable_workspace_agent_connection_alert  = false
enable_workspace_custom_table_alert      = false

# Test: Minimal alerts
enable_workspace_heartbeat_alert         = true
enable_workspace_query_performance_alert = false
enable_workspace_data_retention_alert    = false
enable_workspace_error_rate_alert        = false
enable_workspace_agent_connection_alert  = false
enable_workspace_custom_table_alert      = false
```

### Custom Table Monitoring

Specify custom tables to monitor for ingestion:

```hcl
workspace_custom_tables = [
  "SecurityEvents_CL",
  "ApplicationLogs_CL",
  "CustomMetrics_CL",
  "BusinessData_CL"
]
```

### Retention Configuration

Configure data retention monitoring:

```hcl
# Production: Long retention with advance warning
workspace_retention_days         = 90
workspace_retention_warning_days = 14

# Development: Standard retention
workspace_retention_days         = 30
workspace_retention_warning_days = 7
```

### Multiple Workspaces

Monitor multiple workspaces in a single module call:

```hcl
workspace_names = [
  "law-security-prod",
  "law-operations-prod",
  "law-applications-prod",
  "law-infrastructure-prod"
]
```

## Outputs

The module provides comprehensive outputs for integration:

```hcl
# Alert IDs
output "workspace_heartbeat_alert_id" {
  value = module.workspace_monitoring.workspace_heartbeat_alert_id
}

# Diagnostic settings
output "diagnostic_setting_ids" {
  value = {
    eventhub      = module.workspace_monitoring.diagnostic_setting_eventhub_ids
    log_analytics = module.workspace_monitoring.diagnostic_setting_loganalytics_ids
  }
}

# Configuration summary
output "monitoring_configuration" {
  value = module.workspace_monitoring.monitoring_configuration
}
```

## Troubleshooting

### Alert Not Triggering

1. **Verify workspace exists and is accessible**:
   ```bash
   az monitor log-analytics workspace show --workspace-name law-pge-security-prod --resource-group rg-pge-monitoring-prod
   ```

2. **Check scheduled query rule status**:
   ```bash
   az monitor scheduled-query show --name workspace-heartbeat-missing-law-pge-security-prod --resource-group rg-pge-monitoring-prod
   ```

3. **Test the query manually**:
   ```bash
   az monitor log-analytics query --workspace law-pge-security-prod --analytics-query "Heartbeat | where TimeGenerated > ago(15m) | summarize LastHeartbeat = max(TimeGenerated) by Computer"
   ```

4. **Verify action group notifications**:
   ```bash
   az monitor action-group show --name PGE-Operations --resource-group rg-pge-monitoring-prod
   ```

### Heartbeat Alert Issues

**Common Causes**:
- No agents connected to workspace
- Agents not sending heartbeat data
- Workspace recently created (no historical data)

**Solutions**:
- Verify agents are installed and running
- Check agent configuration points to correct workspace
- Wait 15-30 minutes for initial heartbeat data

### Query Performance Alert Issues

**Common Causes**:
- Operation table not populated
- Queries not being logged
- Threshold too high or too low

**Solutions**:
- Enable operation logging in workspace settings
- Adjust threshold based on actual query performance
- Review slow queries in Azure Portal

### Custom Table Alert Issues

**Common Causes**:
- Custom table names incorrect
- Tables not receiving data
- Usage table not populated

**Solutions**:
- Verify custom table names (usually end with \_CL)
- Check data ingestion into custom tables
- Ensure Usage table is available in workspace

### Diagnostic Settings Issues

1. **Verify Event Hub permissions**:
   ```bash
   az eventhubs eventhub show --name evh-workspace-logs --namespace-name evhns-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

2. **Check central Log Analytics workspace**:
   ```bash
   az monitor log-analytics workspace show --workspace-name law-pge-central-prod --resource-group rg-pge-monitoring-prod
   ```

3. **Review diagnostic setting**:
   ```bash
   az monitor diagnostic-settings show --name send-workspace-logs-to-eventhub --resource <workspace-resource-id>
   ```

### Permission Issues

Ensure the deployment identity has these permissions:

- `Microsoft.Insights/scheduledQueryRules/write`
- `Microsoft.Insights/diagnosticSettings/write`
- `Microsoft.OperationalInsights/workspaces/read`
- `Microsoft.OperationalInsights/workspaces/query/read`
- `Microsoft.EventHub/namespaces/eventhubs/read` (for Event Hub)

## Cost Optimization

### Production Environment
- **Estimated Cost**: $2-5/month per workspace
- **Components**: 
  - 6 scheduled query rules: ~$0.50/rule/month = $3
  - Diagnostic settings: Based on audit log volume (typically low)
  - Event Hub ingestion: Based on throughput
  - Query execution costs: Minimal for these simple queries

### Development Environment
- **Estimated Cost**: $1-2/month per workspace
- **Optimization**: Fewer alerts, Log Analytics only
- **Components**:
  - 3 scheduled query rules: ~$0.50/rule/month = $1.50
  - Log Analytics ingestion: Based on volume

### Test Environment
- **Estimated Cost**: $0.50/month per workspace
- **Optimization**: Minimal alerts, no diagnostics
- **Components**:
  - 1 scheduled query rule: ~$0.50/rule/month

**Note**: Actual costs depend on:
- Number of workspaces monitored
- Query execution frequency
- Diagnostic log volume
- Data ingestion rates

## Best Practices

1. **Monitor All Production Workspaces**: Include all business-critical workspaces
2. **Use Custom Tables Wisely**: Only monitor tables with predictable ingestion patterns
3. **Adjust Thresholds Gradually**: Start conservative and tune based on actual behavior
4. **Test Queries Before Deployment**: Validate KQL queries in Azure Portal first
5. **Review Alerts Regularly**: Fine-tune thresholds based on false positive/negative rates
6. **Implement Retention Policies**: Align retention monitoring with organizational policies
7. **Use Tags Consistently**: Apply consistent tags for cost tracking and governance
8. **Document Custom Tables**: Maintain documentation of custom table purposes
9. **Monitor Query Performance**: Use performance alerts to optimize query efficiency
10. **Centralize Audit Logs**: Use central workspace to analyze all workspace audit logs

## Query Optimization

### Heartbeat Query
The heartbeat query is optimized for performance:
- Filters by time first (`TimeGenerated > ago(15m)`)
- Aggregates per computer
- Uses indexed columns

### Performance Query
Monitor query duration using:
- Operation table with OperationCategory filter
- OperationKey contains duration
- Aggregation for threshold checking

### Custom Table Query
Efficient custom table monitoring:
- Usage table with DataType filter
- Summarization by table
- Volume-based thresholds

## Additional Resources

- [Azure Log Analytics Workspace Documentation](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-workspace-overview)
- [KQL Query Language](https://learn.microsoft.com/azure/data-explorer/kusto/query/)
- [Scheduled Query Rules](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-types#log-alerts)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)
- [Log Analytics Best Practices](https://learn.microsoft.com/azure/azure-monitor/best-practices-logs)

## Support

For issues or questions:
1. Review the main module README
2. Check Azure Log Analytics documentation
3. Test KQL queries in Azure Portal
4. Verify workspace configuration and data ingestion
5. Contact your Azure administrator

## License

This module follows the same license as the parent repository.
