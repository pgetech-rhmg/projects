# Azure Private DNS Zones Monitoring Module - Examples

This directory contains example configurations for the Azure Private DNS Zones monitoring module, demonstrating different deployment patterns for private DNS monitoring.

## Overview

The Azure Private DNS Zones monitoring module provides comprehensive observability for Azure Private DNS Zones, including:
- **Capacity Monitoring**: Track record set counts to prevent quota limits
- **Configuration Change Detection**: Alert on DNS zone configuration modifications
- **Deletion Protection**: Immediate alerts when DNS zones are deleted
- **Multi-Zone Support**: Monitor multiple Private DNS zones from a single module

## Examples

### 1. Production Deployment
**File**: See `main.tf` - Production example

Comprehensive monitoring for production Private DNS infrastructure:
- Multiple Private DNS zones (Web Apps, SQL, Storage, Key Vault)
- Record set capacity monitoring
- Configuration change detection
- Deletion protection
- Full audit trail

**Best for**:
- Production environments
- Mission-critical private networking
- Compliance-driven deployments
- Enterprise Private Link scenarios

**Key Features**:
- 5 Private DNS zones monitored
- Record set count alerts (25,000 limit)
- Configuration change tracking
- Deletion alerts
- Compliance tagging (SOC2)

### 2. Development Deployment
**File**: See `main.tf` - Development example

Essential monitoring for development Private DNS zones:
- Core Private DNS zones (Web Apps, SQL)
- Configuration change detection
- Deletion protection
- Development-appropriate tagging

**Best for**:
- Development environments
- Testing and staging
- Non-production workloads
- Cost-conscious monitoring

**Key Features**:
- 2 Private DNS zones monitored
- Essential alert coverage
- Simplified configuration

### 3. Basic Deployment
**File**: See `main.tf` - Basic example

Minimal monitoring for single Private DNS zone:
- Single critical zone (Web Apps)
- Basic alert coverage
- Simplified setup

**Best for**:
- Proof-of-concept deployments
- Quick setup requirements
- Testing the module
- Single-zone scenarios

**Key Features**:
- 1 Private DNS zone monitored
- Minimal configuration
- Essential monitoring only

## Alert Types

### Metric Alerts

#### Record Set Count Alert
Monitor DNS zone capacity to prevent quota exhaustion:

| Alert | Metric | Threshold | Description |
|-------|--------|-----------|-------------|
| Record Set Count | RecordSetCount | 25,000 | Private DNS zone capacity |

**Details**:
- **Severity**: 3 (Informational)
- **Frequency**: Every 1 hour
- **Window**: 1 hour
- **Aggregation**: Maximum
- **Purpose**: Prevent hitting Azure Private DNS zone limits

**Note**: Private DNS zones support up to 25,000 record sets (higher than public DNS zones).

### Activity Log Alerts

#### Configuration Change Alert
Detect when Private DNS zone configuration is modified:

| Alert | Operation | Category | Description |
|-------|-----------|----------|-------------|
| Configuration Change | privateDnsZones/write | Administrative | Zone configuration updated |

**Details**:
- **Scope**: All monitored zones
- **Location**: Global
- **Purpose**: Audit trail and change detection

#### Deletion Alert
Immediate notification when Private DNS zone is deleted:

| Alert | Operation | Category | Description |
|-------|-----------|----------|-------------|
| Zone Deletion | privateDnsZones/delete | Administrative | Zone deleted |

**Details**:
- **Scope**: All monitored zones
- **Location**: Global
- **Purpose**: Critical deletion protection

## Common Private Link DNS Zones

Azure Private Link uses specific Private DNS zones for different services:

| Service | Private DNS Zone | Purpose |
|---------|------------------|---------|
| Web Apps | privatelink.azurewebsites.net | App Service Private Endpoints |
| SQL Database | privatelink.database.windows.net | Azure SQL Private Endpoints |
| Storage Blob | privatelink.blob.core.windows.net | Blob Storage Private Endpoints |
| Storage File | privatelink.file.core.windows.net | File Storage Private Endpoints |
| Key Vault | privatelink.vaultcore.azure.net | Key Vault Private Endpoints |
| Cosmos DB | privatelink.documents.azure.com | Cosmos DB Private Endpoints |
| ACR | privatelink.azurecr.io | Container Registry Private Endpoints |
| Event Hubs | privatelink.servicebus.windows.net | Event Hubs Private Endpoints |
| Service Bus | privatelink.servicebus.windows.net | Service Bus Private Endpoints |
| Azure Monitor | privatelink.monitor.azure.com | Azure Monitor Private Link Scope |

## Usage

### Prerequisites
1. Azure subscription with Private DNS zones deployed
2. Existing Action Group for alert notifications
3. Private DNS zones linked to virtual networks
4. Private Endpoints using the DNS zones (if applicable)

### Basic Usage

```hcl
module "private_dns_monitoring" {
  source = "path/to/module"

  # Resource identification
  resource_group_name              = "rg-network-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  # Private DNS zones to monitor
  dns_zone_names = [
    "privatelink.azurewebsites.net",
    "privatelink.database.windows.net",
    "privatelink.blob.core.windows.net"
  ]

  # Tags
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Monitor All Common Private Link Zones

```hcl
module "private_dns_monitoring" {
  source = "path/to/module"

  resource_group_name              = "rg-network-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  # Comprehensive Private Link DNS zone monitoring
  dns_zone_names = [
    "privatelink.azurewebsites.net",
    "privatelink.database.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.documents.azure.com",
    "privatelink.azurecr.io",
    "privatelink.servicebus.windows.net"
  ]

  tags = {
    Environment    = "Production"
    NetworkingTier = "Critical"
    Compliance     = "PCI-DSS"
  }
}
```

### Monitor Custom Private DNS Zones

```hcl
module "private_dns_monitoring" {
  source = "path/to/module"

  resource_group_name              = "rg-network-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  # Custom private DNS zones for internal services
  dns_zone_names = [
    "internal.contoso.com",
    "app.contoso.local",
    "services.internal"
  ]

  tags = {
    Environment = "Production"
    Purpose     = "Internal DNS"
  }
}
```

### Single Zone Monitoring

```hcl
module "private_dns_monitoring" {
  source = "path/to/module"

  resource_group_name              = "rg-network-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  # Monitor single critical zone
  dns_zone_names = [
    "privatelink.azurewebsites.net"
  ]

  tags = {
    Environment = "Production"
    Critical    = "Yes"
  }
}
```

## Outputs

The module provides comprehensive outputs:

```hcl
# Alert resource IDs (list)
output "alert_ids" {
  value = module.private_dns_monitoring.alert_ids
}

# Alert names (list)
output "alert_names" {
  value = module.private_dns_monitoring.alert_names
}

# Monitored DNS zones
output "monitored_zones" {
  value = module.private_dns_monitoring.monitored_dns_zones
}

# Alert summary (counts by type)
output "alert_summary" {
  value = module.private_dns_monitoring.alert_summary
}
```

## Best Practices

### 1. Zone Selection
- Monitor all Private Link zones used in your environment
- Include custom private DNS zones for internal services
- Group zones by environment and purpose
- Use consistent naming conventions

### 2. Capacity Planning
- Monitor record set counts proactively
- Alert at 25,000 records (zone limit)
- Plan zone segmentation if approaching limits
- Review record count trends regularly

### 3. Change Management
- Use configuration change alerts for audit trails
- Integrate with ITSM systems for change tracking
- Document expected configuration changes
- Review unexpected changes immediately

### 4. Deletion Protection
- Always enable deletion alerts for production
- Implement RBAC to prevent unauthorized deletions
- Use Azure Policy to enforce deletion locks
- Maintain backup DNS configurations

### 5. Private Link Integration
- Create zones before deploying Private Endpoints
- Link zones to all relevant virtual networks
- Monitor zones used by Private Endpoints closely
- Verify DNS resolution after Private Endpoint creation

### 6. Multi-Region Scenarios
- Create Private DNS zones in global scope
- Link zones to VNets in all regions
- Monitor zones centrally from one module
- Ensure consistent DNS resolution across regions

## Troubleshooting

### No Alerts Firing
1. Verify Private DNS zones exist in specified resource group
2. Check that zone names match exactly (case-sensitive)
3. Confirm Action Group is deployed and accessible
4. Verify zones are linked to virtual networks
5. Check for typos in zone names

### Record Set Count Alerts
1. Review total record sets in zone
2. Check for auto-created records from Private Endpoints
3. Verify no duplicate records
4. Consider zone consolidation or segmentation
5. Review Azure Private DNS zone limits

### Configuration Change Alerts
1. Review Azure Activity Log for recent changes
2. Identify who made the configuration change
3. Verify change was authorized
4. Check if change was part of deployment
5. Restore configuration if unauthorized

### Deletion Alerts
1. Immediately check Azure Activity Log
2. Identify who deleted the zone
3. Assess impact on Private Endpoints
4. Recreate zone and link to VNets
5. Restore DNS records from backup
6. Verify Private Endpoint DNS resolution

### Private Link DNS Resolution Issues
1. Verify Private DNS zone is linked to VNet
2. Check that zone name matches Private Link service
3. Ensure A records exist for Private Endpoints
4. Verify VNet DNS settings (use Azure DNS)
5. Test DNS resolution from VM in VNet

## Private DNS Zone Limits

### Azure Private DNS Zone Quotas
- **Record sets per zone**: 25,000
- **Records per record set**: 20
- **Virtual network links per zone**: 1,000
- **Virtual network links with auto-registration**: 100
- **Zones per subscription**: 1,000

### Planning Considerations
- Plan zone capacity for future growth
- Monitor record set counts proactively
- Segment large environments into multiple zones
- Use sub-zones for organizational boundaries

## Version Requirements

- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

## Related Documentation

- [Azure Private DNS Documentation](https://docs.microsoft.com/azure/dns/private-dns-overview)
- [Private Endpoint DNS Configuration](https://docs.microsoft.com/azure/private-link/private-endpoint-dns)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftnetworkprivatednszones)
- [Private Link Services](https://docs.microsoft.com/azure/private-link/private-link-service-overview)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review module documentation
3. Verify Azure resource configuration
4. Check Private DNS zone settings in portal
5. Test DNS resolution from VMs
