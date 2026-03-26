# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

#### Alert Capabilities
- **Performance Monitoring (7 alerts)**:
  - CPU Percent alert - monitors CPU utilization percentage
  - Physical Data Read Percent alert - tracks data I/O percentage
  - Log Write Percent alert - monitors transaction log write percentage
  - Workers Percent alert - tracks worker thread utilization
  - Sessions Percent alert - monitors active session percentage
  - SQL Server Process Core Percent alert - tracks SQL process CPU percentage
  - TempDB Log Used Percent alert - monitors TempDB transaction log usage
  
- **Storage Monitoring (3 alerts)**:
  - Storage Percent alert - monitors allocated storage utilization
  - Storage Used Bytes alert - tracks absolute storage consumption in bytes
  - XTP Storage Percent alert - monitors In-Memory OLTP storage percentage
  
- **Connection Monitoring (2 alerts)**:
  - Connection Successful (Low) alert - alerts when successful connections drop below threshold
  - Connection Failed alert - monitors failed connection attempts
  
- **Health Monitoring (1 alert)**:
  - Deadlock alert - tracks database deadlock occurrences per minute

#### Database Format Support
- Support for multi-server database monitoring
- Database names in `server-name/database-name` format
- Dynamic parsing of server and database names from input list
- Single module deployment for databases across multiple SQL servers

#### Diagnostic Settings
- SQL Database to Event Hub - activity log streaming
- SQL Database to Log Analytics - security log collection
- Cross-subscription support for centralized logging
- Configurable Event Hub authorization rules
- Support for multiple databases with individual diagnostic settings

#### Configuration
- Configurable alert thresholds for all 13 metrics:
  - `cpu_percent_threshold` - CPU utilization (default: 80%)
  - `physical_data_read_percent_threshold` - data I/O (default: 80%)
  - `log_write_percent_threshold` - transaction log writes (default: 80%)
  - `sessions_percent_threshold` - active sessions (default: 80%)
  - `workers_percent_threshold` - worker threads (default: 80%)
  - `sqlserver_process_core_percent_threshold` - SQL process CPU (default: 80%)
  - `tempdb_log_used_percent_threshold` - TempDB log (default: 80%)
  - `storage_percent_threshold` - storage utilization (default: 90%)
  - `storage_used_bytes_threshold` - absolute storage (default: 100GB)
  - `xtp_storage_percent_threshold` - In-Memory OLTP storage (default: 90%)
  - `connection_successful_threshold` - minimum successful connections (default: 10)
  - `connection_failed_threshold` - maximum failed connections (default: 5)
  - `deadlock_threshold` - maximum deadlocks per minute (default: 1)
- Conditional diagnostic settings with `enable_diagnostic_settings` flag
- Support for custom Event Hub authorization rules
- Configurable action group for alert notifications
- Comprehensive tagging support

#### Outputs
- **Alert Identification**:
  - `alert_ids` - map of all alert resource IDs by type
  - `alert_names` - map of all alert names by type
  
- **Resource Tracking**:
  - `monitored_resources` - map showing database IDs, names, and count
  - `action_group_id` - reference to the monitoring action group
  
- **Diagnostic Settings**:
  - `diagnostic_settings` - diagnostic setting resource IDs for Event Hub and Log Analytics
  
- **Configuration Summary**:
  - `alert_summary` - comprehensive summary including:
    - Total alert count (13 alerts)
    - Alert categories and counts (Performance: 7, Storage: 3, Connection: 2, Health: 1)
    - Databases monitored count
    - Configured thresholds for all 13 metrics
    - Diagnostic settings status
    - Action group information

#### Documentation
- Comprehensive README with alert descriptions and configuration guidance
- Detailed examples directory with three deployment patterns:
  - Production example (75% CPU, 85% storage, 3 databases across 2 servers)
  - Development example (85% CPU, 90% storage, 2 databases on 1 server)
  - Basic example (90% CPU, 95% storage, 1 database)
- Variable validation and input descriptions
- Troubleshooting guide for common scenarios
- Database name format documentation
- Example outputs for all deployment patterns

#### Technical Features
- Terraform >= 1.0 compatibility
- AzureRM provider >= 3.0, < 5.0 support
- Dynamic alert creation using `for_each` over database list
- Local variables for parsing server/database names from input format
- Data source references to existing action groups and SQL databases
- Auto-mitigation enabled for all alerts
- 5-minute evaluation frequency for all alerts
- PT5M to PT15M window sizes optimized per metric type
- Cross-subscription diagnostic destinations
- Support for multiple databases per deployment

### Requirements

#### Terraform Version
- Terraform >= 1.0

#### Provider Versions
- azurerm >= 3.0, < 5.0

#### Azure Permissions
- `Microsoft.Insights/metricAlerts/write` - create and manage metric alerts
- `Microsoft.Insights/diagnosticSettings/write` - configure diagnostic settings
- `Microsoft.Sql/servers/databases/read` - read SQL Database properties
- `Microsoft.Insights/actionGroups/read` - read action group details
- `Microsoft.EventHub/namespaces/eventhubs/write` - Event Hub access (if using)
- `Microsoft.OperationalInsights/workspaces/write` - Log Analytics access (if using)

### Notes
- All 13 alerts are created for every database specified in `sql_database_names`
- Database names must be provided in `server-name/database-name` format
- Module supports monitoring databases across multiple SQL servers in single deployment
- Diagnostic settings are optional and controlled by `enable_diagnostic_settings` variable
- Module supports cross-subscription scenarios for Event Hub and Log Analytics
- All performance alerts use severity level 2 (Warning)
- All storage alerts use severity level 2 (Warning)
- Connection and health alerts use severity level 2 (Warning)
- Action group must exist in Azure before module deployment
- SQL databases must exist in the specified resource group before module deployment
- Storage Used Bytes threshold is in bytes (default: 107374182400 = 100GB)

[1.0.0]: https://github.com/your-org/terraform-azurerm-sqldatabase-monitoring/releases/tag/v1.0.0
