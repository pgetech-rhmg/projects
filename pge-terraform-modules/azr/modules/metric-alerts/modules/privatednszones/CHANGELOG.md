# Changelog

All notable changes to the Azure Private DNS Zones Monitoring Module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-02

### Added
- Initial release of Azure Private DNS Zones monitoring module
- Comprehensive monitoring for Azure Private DNS infrastructure
- 3 alert types covering capacity, configuration, and deletion:
  - Record set count monitoring (capacity planning)
  - Configuration change detection (audit trail)
  - DNS zone deletion alerts (protection)

### Features
- **Capacity Monitoring**: Track record set counts to prevent quota exhaustion
  - Monitors against 25,000 record set limit for Private DNS zones
  - Proactive alerting for capacity planning
  - Hourly evaluation for timely detection
- **Configuration Change Detection**: Alert on DNS zone modifications
  - Activity log monitoring for write operations
  - Audit trail for compliance and security
  - Global scope for all zone changes
- **Deletion Protection**: Immediate alerts when zones are deleted
  - Critical protection for private networking infrastructure
  - Activity log monitoring for delete operations
  - Prevents unnoticed DNS infrastructure loss
- **Multi-Zone Support**: Monitor multiple Private DNS zones from single module
- **Private Link Integration**: Optimized for Private Endpoint DNS zones
- **Flexible Configuration**: Support for any Private DNS zone name
- **Action Group Integration**: Centralized alert notification management

### Alert Details

#### Metric Alerts
- **Record Set Count**: Severity 3 (Informational), 1-hour frequency
  - Threshold: 25,000 record sets (Private DNS zone limit)
  - Aggregation: Maximum
  - Purpose: Capacity planning and quota management

#### Activity Log Alerts
- **Configuration Change**: Global scope, Administrative category
  - Operation: Microsoft.Network/privateDnsZones/write
  - Purpose: Change tracking and audit compliance
- **Zone Deletion**: Global scope, Administrative category
  - Operation: Microsoft.Network/privateDnsZones/delete
  - Purpose: Critical infrastructure protection

### Examples
- Production deployment example monitoring 5 Private Link zones
  - Web Apps (privatelink.azurewebsites.net)
  - SQL Database (privatelink.database.windows.net)
  - Blob Storage (privatelink.blob.core.windows.net)
  - File Storage (privatelink.file.core.windows.net)
  - Key Vault (privatelink.vaultcore.azure.net)
  - Full alert coverage with compliance tagging
- Development deployment example monitoring 2 essential zones
  - Web Apps and SQL Database zones
  - Simplified configuration for dev environments
- Basic deployment example monitoring single zone
  - Minimal setup for testing or single-zone scenarios

### Documentation
- Comprehensive README with usage examples
- Detailed alert type descriptions
- Common Private Link DNS zone reference
- Private Endpoint integration guidance
- Multi-zone monitoring patterns
- Capacity planning best practices
- Troubleshooting guide
- Azure Private DNS zone limits reference

### Technical Details
- Terraform version requirement: >= 1.0
- AzureRM provider version: >= 3.0, < 5.0
- Dynamic resource creation based on DNS zone name list
- Activity log alerts scope to all monitored zones
- Metric alerts created per zone
- Proper handling of empty zone name lists
- Data source lookups for DNS zone resources
- Zone name sanitization for alert naming (replaces dots with dashes)
- Validation for critical variables (planned)

### Outputs
- `alert_ids`: List of all created alert resource IDs
- `alert_names`: List of all created alert names
- `monitored_dns_zones`: List of DNS zone names being monitored
- `monitored_resource_group`: Resource group name where zones are located
- `action_group_id`: Resource ID of the action group used
- `alert_summary`: Summary counts of each alert type configured
  - Record set count alerts (per zone)
  - Configuration change alerts
  - Deletion alerts
  - Total metric alerts
  - Total activity log alerts
  - Total all alerts

### Variables
- `dns_zone_names`: List of Private DNS zone names to monitor
- `resource_group_name`: Resource group containing DNS zones
- `action_group_resource_group_name`: Resource group for action group
- `action_group`: Name of action group for notifications
- `location`: Azure region for scheduled query rules (default: West US 2)
- `tags`: Standard tag variables for resource management

### Use Cases
- **Private Link Monitoring**: Monitor DNS zones for Private Endpoints
  - App Service Private Endpoints
  - SQL Database Private Endpoints
  - Storage Account Private Endpoints
  - Key Vault Private Endpoints
  - Other Azure service Private Endpoints
- **Capacity Planning**: Prevent hitting record set limits
- **Change Audit**: Track DNS configuration modifications
- **Deletion Protection**: Immediate notification of zone deletions
- **Compliance**: Audit trail for DNS changes
- **Multi-Zone Environments**: Centralized monitoring for multiple zones
- **Custom DNS Zones**: Support for internal/custom private DNS zones

### Private Link DNS Zones Supported
The module works with all Azure Private Link DNS zones including:
- privatelink.azurewebsites.net (Web Apps)
- privatelink.database.windows.net (SQL Database)
- privatelink.blob.core.windows.net (Blob Storage)
- privatelink.file.core.windows.net (File Storage)
- privatelink.queue.core.windows.net (Queue Storage)
- privatelink.table.core.windows.net (Table Storage)
- privatelink.vaultcore.azure.net (Key Vault)
- privatelink.documents.azure.com (Cosmos DB)
- privatelink.azurecr.io (Container Registry)
- privatelink.servicebus.windows.net (Service Bus/Event Hubs)
- privatelink.monitor.azure.com (Azure Monitor)
- And any custom Private DNS zones

### Notes
- Module does not support diagnostic settings (Private DNS zones don't require them)
- Record set count threshold set to 25,000 (Private DNS zone limit)
- Activity log alerts are created once per module, scoped to all zones
- Metric alerts are created per zone for granular monitoring
- Alert names include zone names with dots replaced by dashes
- Module supports both Private Link zones and custom private zones
- No additional thresholds configurable (uses Azure limits)
- Conditional resource creation based on zone name list
