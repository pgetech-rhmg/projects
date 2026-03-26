# Azure SQL Database Monitoring Module - Examples

This directory contains example configurations for deploying the Azure SQL Database monitoring module in different scenarios.

## Available Examples

### 1. Production Example (`sql_db_alerts_production`)
Complete monitoring configuration with all 13 alerts enabled and tight thresholds suitable for production databases.

**Features:**
- All 13 metric alerts enabled for 3 SQL databases across 2 servers
- Production-grade thresholds (75% CPU, 85% storage, strict connection monitoring)
- Full diagnostic settings (Event Hub + Log Analytics)
- Multiple databases across multiple SQL servers
- Comprehensive monitoring coverage

**Use Case:** Production SQL Database deployments requiring comprehensive monitoring, alerting, and compliance with diagnostic log retention.

### 2. Development Example (`sql_db_alerts_development`)
Balanced monitoring configuration with all alerts and relaxed thresholds for development environments.

**Features:**
- All 13 metric alerts enabled for 2 SQL databases
- Relaxed thresholds (85% CPU, 90% storage)
- Event Hub diagnostic settings only
- Multiple databases on single server
- Focused on critical metrics

**Use Case:** Development and staging environments where alerting is needed but with more relaxed thresholds.

### 3. Basic Example (`sql_db_alerts_basic`)
Minimal monitoring configuration with all alerts but very relaxed thresholds for testing.

**Features:**
- All 13 metric alerts enabled
- Very relaxed thresholds (90% CPU, 95% storage)
- No diagnostic settings
- Single SQL database
- Minimal overhead

**Use Case:** Testing environments, proof-of-concept, or cost-sensitive deployments.

## Alert Categories

The module provides comprehensive monitoring across four categories:

### Performance Alerts (7 alerts)
- **CPU Percent**: Monitors CPU utilization percentage
- **Physical Data Read Percent**: Tracks data I/O percentage
- **Log Write Percent**: Monitors transaction log write percentage
- **Workers Percent**: Tracks worker thread utilization
- **Sessions Percent**: Monitors active session percentage
- **SQL Server Process Core Percent**: Tracks SQL process CPU percentage
- **TempDB Log Used Percent**: Monitors TempDB transaction log usage

### Storage Alerts (3 alerts)
- **Storage Percent**: Monitors allocated storage utilization
- **Storage Used Bytes**: Tracks absolute storage consumption
- **XTP Storage Percent**: Monitors In-Memory OLTP storage percentage

### Connection Alerts (2 alerts)
- **Connection Successful (Low)**: Alerts when successful connections drop too low
- **Connection Failed**: Monitors failed connection attempts

### Health Alerts (1 alert)
- **Deadlock**: Tracks database deadlock occurrences

## Prerequisites

Before deploying these examples, ensure you have:

1. **Azure Resources**:
   - One or more Azure SQL Databases (format: server-name/database-name)
   - Action Group for alert notifications
   - (Optional) Event Hub namespace and hub for activity logs
   - (Optional) Log Analytics workspace for security logs

2. **Permissions**:
   - `Microsoft.Insights/metricAlerts/write` - Create metric alerts
   - `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
   - `Microsoft.Sql/servers/databases/read` - Read SQL Database properties
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
terraform apply -target=module.sql_db_alerts_production

# Deploy only development example
terraform apply -target=module.sql_db_alerts_development

# Deploy only basic example
terraform apply -target=module.sql_db_alerts_basic
```

### 3. Customize Configuration

Create a `terraform.tfvars` file or modify the example directly:

```hcl
# Custom production deployment
module "sql_db_alerts_custom" {
  source = "../"

  resource_group_name              = "my-sqlserver-rg"
  sql_database_names               = [
    "my-sqlserver-prod/database1",
    "my-sqlserver-prod/database2"
  ]
  action_group_resource_group_name = "my-monitoring-rg"
  action_group                     = "my-action-group"

  # Customize performance thresholds
  cpu_percent_threshold                      = 80
  physical_data_read_percent_threshold       = 80
  log_write_percent_threshold                = 80
  sessions_percent_threshold                 = 80
  workers_percent_threshold                  = 80
  sqlserver_process_core_percent_threshold   = 80
  tempdb_log_used_percent_threshold          = 85

  # Customize storage thresholds
  storage_percent_threshold                  = 90
  storage_used_bytes_threshold               = 107374182400  # 100GB
  xtp_storage_percent_threshold              = 90

  # Customize connection thresholds
  connection_successful_threshold            = 10
  connection_failed_threshold                = 5

  # Customize health thresholds
  deadlock_threshold                         = 1

  # Configure diagnostic settings
  enable_diagnostic_settings                 = true
  eventhub_namespace_name                    = "my-eventhub-ns"
  eventhub_name                              = "my-eventhub"
  eventhub_resource_group_name               = "my-eventhub-rg"
  log_analytics_workspace_name               = "my-law"
  log_analytics_resource_group_name          = "my-law-rg"

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
- **monitored_resources**: Map of SQL Database names and IDs
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
| `resource_group_name` | SQL Server resource group | Yes | "" |
| `sql_database_names` | List of SQL databases (server/database format) | Yes | [] |
| `action_group_resource_group_name` | Action group resource group | Yes | - |
| `action_group` | Action group name | Yes | "" |

**Note**: Database names must be in format: `server-name/database-name`

### Threshold Variables

All alerts are created for all specified databases. Control sensitivity by adjusting thresholds:

| Variable | Metric | Production | Development | Basic |
|----------|--------|------------|-------------|-------|
| `cpu_percent_threshold` | CPU % | 75 | 85 | 90 |
| `physical_data_read_percent_threshold` | Data I/O % | 75 | 85 | 90 |
| `log_write_percent_threshold` | Log Write % | 75 | 85 | 90 |
| `sessions_percent_threshold` | Sessions % | 75 | 85 | 90 |
| `workers_percent_threshold` | Workers % | 75 | 85 | 90 |
| `sqlserver_process_core_percent_threshold` | SQL Process % | 75 | 85 | 90 |
| `tempdb_log_used_percent_threshold` | TempDB Log % | 80 | 90 | 95 |
| `storage_percent_threshold` | Storage % | 85 | 90 | 95 |
| `storage_used_bytes_threshold` | Storage Bytes | 200GB | 100GB | 50GB |
| `xtp_storage_percent_threshold` | XTP Storage % | 85 | 90 | 95 |
| `connection_successful_threshold` | Min Successful Connections | 5 | 3 | 1 |
| `connection_failed_threshold` | Max Failed Connections | 3 | 10 | 20 |
| `deadlock_threshold` | Max Deadlocks/min | 1 | 3 | 5 |

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
  --resource-group rg-sqlserver-prod \
  --output table

# Check diagnostic settings for SQL database
az monitor diagnostic-settings list \
  --resource /subscriptions/{sub-id}/resourceGroups/rg-sqlserver-prod/providers/Microsoft.Sql/servers/pge-sqlserver-prod-001/databases/app-database-prod \
  --output table

# Test alert by generating load
# Run queries to increase CPU, connections, etc.
```

## Troubleshooting

### Common Issues

1. **Alert not triggering**:
   - Verify threshold values are appropriate for your workload
   - Check database names are in correct format (server-name/database-name)
   - Confirm action group is properly configured
   - Review metric values in Azure Portal

2. **Diagnostic settings not working**:
   - Verify Event Hub/Log Analytics workspace exists
   - Check permissions on destination resources
   - Confirm `enable_diagnostic_settings = true`
   - Verify subscription IDs if using cross-subscription

3. **Module errors**:
   - Ensure SQL databases exist in specified format
   - Verify action group exists and is accessible
   - Check AzureRM provider version compatibility
   - Validate database names don't have extra spaces

4. **Database name format issues**:
   - Correct: `"sql-server-prod-01/database-prod-01"`
   - Incorrect: `"database-prod-01"` (missing server name)
   - Incorrect: `"sql-server-prod-01\\database-prod-01"` (wrong separator)

## Cost Considerations

- **Metric Alerts**: ~$0.10 per alert rule per month
- **Diagnostic Settings**: Data ingestion costs for Event Hub and Log Analytics
- **Production Example**: ~$3.90/month for alerts (3 databases × 13 alerts × $0.10)
- **Development Example**: ~$2.60/month for alerts (2 databases × 13 alerts × $0.10)
- **Basic Example**: ~$1.30/month for alerts (1 database × 13 alerts × $0.10)

Plus diagnostic logging costs based on data volume.

## Security Considerations

1. **Least Privilege**: Use managed identities or service principals with minimal required permissions
2. **Sensitive Data**: Store Event Hub and Log Analytics credentials in Key Vault
3. **Network Security**: Use private endpoints for Event Hub and Log Analytics if available
4. **Access Control**: Restrict access to diagnostic logs containing query data
5. **Data Classification**: Apply appropriate tags based on data sensitivity
6. **SQL Injection**: Monitor failed connections for potential attacks

## Additional Resources

- [Azure SQL Database Documentation](https://docs.microsoft.com/azure/azure-sql/database/)
- [Azure Monitor Metrics for SQL Database](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftsqlserversdatabases)
- [SQL Database Best Practices](https://docs.microsoft.com/azure/azure-sql/database/performance-guidance)
- [SQL Database Troubleshooting](https://docs.microsoft.com/azure/azure-sql/database/troubleshoot-common-errors-issues)
- [Module Documentation](../README.md)

## Support

For issues, questions, or contributions, please refer to the main module repository.
