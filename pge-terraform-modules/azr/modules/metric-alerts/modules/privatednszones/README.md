# Azure Private DNS Zones Monitoring Alerts - Terraform Module

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Production Configuration](#production-configuration)
  - [Multi-Zone Deployment](#multi-zone-deployment)
  - [App Service Environment Configuration](#app-service-environment-configuration)
- [Input Variables](#input-variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
- [Alert Details](#alert-details)
  - [Capacity Alerts](#capacity-alerts)
  - [Activity Log Alerts](#activity-log-alerts)
- [Alert Severity Levels](#alert-severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
  - [Private DNS Zone Design](#private-dns-zone-design)
  - [Virtual Network Integration](#virtual-network-integration)
  - [Record Management](#record-management)
  - [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Validation Commands](#validation-commands)
- [License](#license)

---

## Overview

This Terraform module provides comprehensive monitoring and alerting for **Azure Private DNS Zones**, Microsoft's DNS resolution service for resources within Azure Virtual Networks. Private DNS zones provide name resolution for virtual machines and services without exposing DNS records to the internet, enabling secure internal domain name resolution.

The module implements the **Azure Monitor Baseline Alerts (AMBA)** best practices specifically tailored for Private DNS zones, covering:
- **Capacity monitoring** - Record set count tracking
- **Administrative monitoring** - Configuration changes and deletions
- **Change tracking** - Audit trail for DNS modifications

**Key Capabilities:**
- Monitors DNS zone record set capacity
- Detects configuration changes
- Alerts on zone deletions
- Tracks administrative operations
- Supports multiple DNS zones
- Integrates with VNet link monitoring

This module is essential for organizations using:
- **Azure App Service Environments (ASE)** - Private DNS for ASE domains
- **Private Endpoints** - DNS resolution for private connectivity
- **Hybrid networking** - DNS integration with on-premises
- **VNet-integrated applications** - Internal service discovery
- **Kubernetes/AKS** - Private cluster DNS
- **Split-horizon DNS** - Different resolution for internal vs external

---

## Key Features

- **✅ 3 Comprehensive Alerts** - Capacity and administrative monitoring
- **✅ 1 Capacity Alert** - Record set count monitoring
- **✅ 2 Activity Log Alerts** - Configuration changes and deletion tracking
- **✅ Multi-Zone Support** - Monitor multiple Private DNS zones simultaneously
- **✅ High Capacity Threshold** - 25,000 record set default (Private DNS limit)
- **✅ Change Auditing** - Track all DNS modifications
- **✅ Deletion Protection** - Immediate alerts on zone deletion
- **✅ ASE Integration** - Perfect for App Service Environment monitoring
- **✅ Private Endpoint Support** - DNS for secure connectivity
- **✅ Customizable** - Configurable thresholds and tags
- **✅ Production-Ready** - Follows Azure AMBA guidelines

---

## Prerequisites

Before using this module, ensure you have:

1. **Terraform >= 1.0** installed
2. **Azure Provider >= 3.0** configured
3. **Existing Private DNS Zone(s)** deployed
4. **Azure Monitor Action Group** created for alert notifications
5. **Appropriate Azure RBAC permissions**:
   - `Private DNS Zone Contributor` or `Monitoring Contributor` role
   - `Reader` role on Private DNS zones
   - Access to the action group for notifications

6. **Private DNS Zone Requirements**:
   - Private DNS zone created
   - Virtual network links configured
   - DNS records created (A, AAAA, CNAME, MX, PTR, SRV, TXT)
   - Auto-registration enabled (if needed)

---

## Module Structure

```
privatednszones/
├── alerts.tf       # Private DNS zone metric and activity log alert definitions
├── variables.tf    # Input variable definitions
└── README.md       # This documentation file
```

---

## Usage

### Basic Usage

```hcl
module "private_dns_alerts" {
  source = "./modules/metricAlerts/privatednszones"

  # Private DNS zones to monitor
  dns_zone_names                     = ["privatelink.azurewebsites.net"]
  resource_group_name                = "rg-network-production"

  # Action group configuration
  action_group                       = "network-ops-actiongroup"
  action_group_resource_group_name   = "rg-monitoring"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Private-DNS"
    CostCenter         = "Networking"
    DataClassification = "Internal"
    Owner              = "network-team@company.com"
  }
}
```

### Production Configuration

```hcl
module "private_dns_alerts_prod" {
  source = "./modules/metricAlerts/privatednszones"

  # Multiple Private DNS zones
  dns_zone_names = [
    "privatelink.azurewebsites.net",        # App Service
    "privatelink.database.windows.net",     # SQL Database
    "privatelink.blob.core.windows.net",    # Storage Blob
    "privatelink.vaultcore.azure.net",      # Key Vault
    "privatelink.azurecr.io",               # Container Registry
    "contoso.internal"                       # Custom internal domain
  ]

  resource_group_name                = "rg-network-production"

  # Action groups
  action_group                       = "network-critical-alerts"
  action_group_resource_group_name   = "rg-monitoring-prod"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Enterprise-DNS"
    CostCenter         = "Infrastructure"
    Compliance         = "SOC2,ISO27001"
    DataClassification = "Internal"
    DR                 = "Critical"
    Owner              = "network-ops@company.com"
    AlertingSLA        = "24x7"
  }
}
```

### Multi-Zone Deployment

```hcl
module "private_dns_alerts_multi_zone" {
  source = "./modules/metricAlerts/privatednszones"

  # Comprehensive Private Link DNS zones
  dns_zone_names = [
    # Compute
    "privatelink.azurewebsites.net",
    "privatelink.scm.azurewebsites.net",
    
    # Data & Storage
    "privatelink.database.windows.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.blob.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.dfs.core.windows.net",
    
    # Security & Identity
    "privatelink.vaultcore.azure.net",
    "privatelink.managedhsm.azure.net",
    
    # Containers
    "privatelink.azurecr.io",
    
    # IoT
    "privatelink.azure-devices.net",
    "privatelink.servicebus.windows.net",
    "privatelink.azurewebsites.net",
    
    # Custom domains
    "prod.internal",
    "apps.internal",
    "data.internal"
  ]

  resource_group_name                = "rg-network-global"

  action_group                       = "network-pagerduty"
  action_group_resource_group_name   = "rg-alerting"

  tags = {
    Environment        = "Production"
    Application        = "Global-Private-DNS"
    BusinessUnit       = "Platform"
    CostCenter         = "Infrastructure"
    Owner              = "platform-network@company.com"
  }
}
```

### App Service Environment Configuration

```hcl
module "private_dns_alerts_ase" {
  source = "./modules/metricAlerts/privatednszones"

  # App Service Environment DNS zones
  dns_zone_names = [
    "ase-prod-centralus.appserviceenvironment.net",
    "ase-prod-eastus.appserviceenvironment.net",
    "scm.ase-prod-centralus.appserviceenvironment.net",
    "scm.ase-prod-eastus.appserviceenvironment.net"
  ]

  resource_group_name                = "rg-ase-network"

  action_group                       = "ase-ops-actiongroup"
  action_group_resource_group_name   = "rg-monitoring"

  tags = {
    Environment = "Production"
    Application = "ASE-DNS"
    CostCenter  = "AppServices"
    Owner       = "ase-team@company.com"
    Purpose     = "App-Service-Environment"
  }
}
```

---

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `dns_zone_names` | `list(string)` | List of Private DNS zone names to monitor |
| `resource_group_name` | `string` | Resource group containing the Private DNS zones |
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `action_group` | `string` | Name of the Azure Monitor action group for notifications |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `tags` | `map(string)` | See variables.tf | Resource tags for organization and cost tracking |

---

## Alert Details

### Capacity Alerts

#### 1. Private DNS Zone Record Set Count Alert
- **Metric**: `RecordSetCount`
- **Threshold**: 25,000 record sets (default)
- **Severity**: 3 (Informational)
- **Frequency**: PT1H
- **Window**: PT1H
- **Aggregation**: Maximum
- **Description**: Monitors DNS zone record set capacity approaching limit
- **Use Case**: Capacity planning, limit awareness

**What to do when this alert fires:**
```bash
# Check current record set count
az network private-dns record-set list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "length(@)"

# List record sets by type
az network private-dns record-set a list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "length(@)"

az network private-dns record-set cname list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "length(@)"

# Check for duplicate or unnecessary records
az network private-dns record-set list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --output table

# Azure Private DNS Zone Limits:
# - Maximum record sets per zone: 25,000
# - Maximum records per record set: 1,000
# - Maximum VNet links per zone: 1,000

# Actions:
# 1. Review and clean up old/unused DNS records
# 2. Check for auto-registration creating excessive records
# 3. Consider splitting into multiple zones
# 4. Review private endpoint DNS integration
# 5. Check for application-created dynamic DNS records
# 6. Verify no DNS record leaks from deleted resources
# 7. Implement DNS record lifecycle management
# 8. Consider using Azure Private DNS Resolver for large-scale needs
```

**Example cleanup script:**
```bash
#!/bin/bash
# Identify old or unused DNS records

# List all A records with their creation time
az network private-dns record-set list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "[?type=='Microsoft.Network/privateDnsZones/A'].{Name:name, TTL:ttl, Records:aRecords}" \
  --output table

# Delete a specific record set
az network private-dns record-set a delete \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --name <record-name> \
  --yes

# Example: Delete records older than 90 days (requires custom logic)
# Note: Azure CLI doesn't expose creation timestamps, use Azure Resource Graph
```

### Activity Log Alerts

#### 2. Private DNS Zone Configuration Change Alert
- **Operation**: `Microsoft.Network/privateDnsZones/write`
- **Category**: Administrative
- **Severity**: Informational (implied)
- **Description**: Tracks configuration changes to Private DNS zones
- **Use Case**: Change tracking, audit trail, troubleshooting

**What to do when this alert fires:**
```bash
# Review configuration changes
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Create or Update Private DNS Zone']"

# Get current zone configuration
az network private-dns zone show \
  --resource-group <resource-group> \
  --name <zone-name>

# Check virtual network links
az network private-dns link vnet list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --output table

# Review who made the change
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Create or Update Private DNS Zone'].{Time:eventTimestamp, User:caller, Status:status.localizedValue}"

# Actions:
# 1. Verify change was authorized
# 2. Document in change management system
# 3. Review what was modified (records, VNet links, tags)
# 4. Test DNS resolution after changes
# 5. Verify no service disruption
# 6. Check for impact on private endpoints
# 7. Update documentation if needed
# 8. Notify dependent teams if necessary
```

**Example DNS testing:**
```bash
# Test DNS resolution from a VM in the linked VNet
# SSH/RDP to a VM and run:

# Linux
nslookup <record-name>.<zone-name>
dig <record-name>.<zone-name>

# Windows
nslookup <record-name>.<zone-name>
Resolve-DnsName <record-name>.<zone-name>

# Example:
nslookup myapp.privatelink.azurewebsites.net
# Should return private IP address (e.g., 10.0.1.5)
```

#### 3. Private DNS Zone Deletion Alert
- **Operation**: `Microsoft.Network/privateDnsZones/delete`
- **Category**: Administrative
- **Severity**: Warning (implied)
- **Description**: **CRITICAL** - Detects Private DNS zone deletion
- **Use Case**: Accidental deletion prevention, security incident detection

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Delete Private DNS Zone']"

# Check if zone still exists
az network private-dns zone show \
  --resource-group <resource-group> \
  --name <zone-name>

# Private DNS zones are NOT soft-deleted (permanent deletion)

# Re-create zone immediately if accidental
az network private-dns zone create \
  --resource-group <resource-group> \
  --name <zone-name>

# Re-create virtual network links
az network private-dns link vnet create \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --name <link-name> \
  --virtual-network <vnet-id> \
  --registration-enabled <true|false>

# Restore DNS records from backup/IaC
# (DNS records are NOT automatically backed up)

# Actions (URGENT):
# 1. Verify if deletion was authorized
# 2. Identify who deleted the zone
# 3. Re-create zone immediately from IaC/Terraform
# 4. Restore DNS records (from documentation/backups)
# 5. Re-establish VNet links
# 6. Test DNS resolution
# 7. If malicious: Escalate to security team
# 8. Review RBAC permissions
# 9. Implement Azure Policy to prevent deletion
# 10. Consider resource locks on critical zones
# 11. Document incident
# 12. Notify affected application teams
```

**Example zone recreation script:**
```bash
#!/bin/bash
# Emergency DNS zone restoration script

RESOURCE_GROUP="rg-network-production"
ZONE_NAME="privatelink.azurewebsites.net"
VNET_ID="/subscriptions/.../virtualNetworks/vnet-prod"

# Recreate zone
az network private-dns zone create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ZONE_NAME"

# Recreate VNet link
az network private-dns link vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --zone-name "$ZONE_NAME" \
  --name "link-to-vnet-prod" \
  --virtual-network "$VNET_ID" \
  --registration-enabled false

# Recreate key DNS records (example)
az network private-dns record-set a add-record \
  --resource-group "$RESOURCE_GROUP" \
  --zone-name "$ZONE_NAME" \
  --record-set-name "myapp" \
  --ipv4-address "10.0.1.5"

echo "DNS zone restored. Verify resolution from VMs."
```

---

## Alert Severity Levels

| Severity | Level | Use Case | Example Alerts |
|----------|-------|----------|----------------|
| **0** | Critical | Service outage, complete failure | None in this module |
| **1** | Error | Functional failures, severe issues | None in this module |
| **2** | Warning | Performance degradation, approaching limits | None in this module |
| **3** | Informational | Awareness, trend monitoring, capacity planning | Record Set Count |
| **4** | Verbose | Detailed diagnostics | None in this module |

**Severity Guidelines:**
- **Severity 3** alerts are **informational** for capacity planning
- **Activity Log** alerts are critical for **change tracking** and **security**
- Zone deletion is **CRITICAL** despite being an activity log alert (immediate impact)

---

## Cost Analysis

### Alert Costs

**Azure Monitor Pricing (as of 2024):**
- Metric Alerts: **$0.10 per month** per alert rule
- Activity Log Alerts: **FREE**

**This Module Cost Calculation:**
- **1 Metric Alert** (record set count) per DNS zone
- **2 Activity Log Alerts** (FREE, shared across all zones)

**Cost per DNS Zone:**
- Metric alerts: 1 × $0.10 = **$0.10/month** per zone
- Activity log alerts: **$0.00/month** (FREE)

**Example Deployment Costs:**
- **1 DNS Zone**: 1 alert = **$0.10/month**
- **5 DNS Zones**: 5 × $0.10 = **$0.50/month**
- **20 DNS Zones**: 20 × $0.10 = **$2.00/month**
- **Annual cost (5 DNS Zones)**: **$6.00/year**

### Private DNS Zone Costs

**Azure Private DNS Zone Pricing:**
- **Hosted zone**: $0.50 per zone per month
- **DNS queries**: First 1 billion queries/month included
- **Additional queries**: $0.40 per million queries

**Example Monthly Costs:**
```
Scenario 1: Single Zone (App Service)
- 1 Private DNS zone: $0.50
- 100M queries: FREE (included)
- Monitoring: $0.10
- Total: $0.60/month

Scenario 2: Multi-Zone (Private Endpoints)
- 10 Private DNS zones: 10 × $0.50 = $5.00
- 500M queries: FREE (included)
- Monitoring: 10 × $0.10 = $1.00
- Total: $6.00/month

Scenario 3: Enterprise Deployment
- 50 Private DNS zones: 50 × $0.50 = $25.00
- 2 billion queries: (2B - 1B) × $0.40/1M = $400.00
- Monitoring: 50 × $0.10 = $5.00
- Total: $430.00/month
```

### ROI Analysis

**Scenario: Production Private DNS Infrastructure (10 Zones)**

**Without Monitoring:**
- Average downtime per incident: 1 hour
- Incidents per month: 1
- Revenue loss: $50,000/hour (DNS resolution failure)
- Accidental deletion recovery time: 4 hours
- **Monthly loss**: 1 hour × 1 incident × $50,000 = **$50,000**

**With Comprehensive Monitoring:**
- Alert cost: $1.00/month (10 zones)
- Early detection of capacity issues prevents outages
- Immediate notification on zone deletion reduces recovery time by 75%
- Prevented downtime: 0.75 hours × 1 incident = 0.75 hours
- **Monthly savings**: 0.75 hours × $50,000 = **$37,500**

**ROI Calculation:**
```
Monthly Investment: $1.00
Monthly Benefit: $37,500
Monthly Net Benefit: $37,499.00
ROI: (37,499.00 / 1.00) × 100 = 3,749,900%
Annual ROI: $449,988.00 savings vs $12.00 cost
```

**Additional Benefits:**
- Prevents DNS resolution failures
- Audit trail for compliance (SOX, HIPAA)
- Faster troubleshooting of DNS issues
- Capacity planning for zone limits
- Security incident detection
- Change tracking and documentation

---

## Best Practices

### Private DNS Zone Design

1. **Zone Organization**
   - Use separate zones for different environments (dev, test, prod)
   - Create zones for each Private Link service type
   - Use custom internal domains for organization naming
   - Document zone naming conventions
   - Consider zone hierarchy for large organizations

2. **Naming Conventions**
   - Private Link zones: Use Azure standard names (privatelink.*)
   - Custom zones: Use descriptive internal domains (apps.internal, data.internal)
   - App Service Environment: Follow ASE naming pattern
   - Avoid conflicts with public DNS
   - Document all zone purposes

3. **Zone Structure**
   ```
   # Private Link Zones
   privatelink.azurewebsites.net      # Web Apps, Function Apps
   privatelink.database.windows.net    # Azure SQL Database
   privatelink.blob.core.windows.net   # Storage Blobs
   privatelink.vaultcore.azure.net     # Key Vault
   
   # Custom Internal Zones
   prod.internal                       # Production apps
   dev.internal                        # Development apps
   apps.internal                       # Application services
   data.internal                       # Data services
   
   # App Service Environment
   ase-prod.appserviceenvironment.net
   scm.ase-prod.appserviceenvironment.net
   ```

### Virtual Network Integration

1. **VNet Links**
   - Link zones to appropriate virtual networks
   - Enable auto-registration only when needed (VM registration)
   - Disable auto-registration for private endpoints (manual records)
   - Use descriptive link names
   - Document which VNets are linked to which zones
   - Maximum 1,000 VNet links per zone

2. **Auto-Registration**
   - **Enable** for VM workloads (dynamic registration)
   - **Disable** for private endpoints (static records)
   - Only one zone per VNet can have auto-registration enabled
   - Monitor for excessive record creation
   - Clean up stale records regularly

3. **Hub-Spoke Topology**
   - Create DNS zones in hub VNet resource group
   - Link zones to all spoke VNets
   - Use single zone for consistent resolution
   - Consider Azure Private DNS Resolver for complex topologies
   - Document network architecture

### Record Management

1. **Record Types**
   - **A records**: IPv4 addresses (most common)
   - **AAAA records**: IPv6 addresses
   - **CNAME records**: Aliases (cannot be used at zone apex)
   - **MX records**: Mail servers (rarely used in private zones)
   - **PTR records**: Reverse lookups
   - **SRV records**: Service discovery
   - **TXT records**: Text data, verification

2. **Private Endpoints**
   - Private endpoints create DNS records automatically
   - Records follow pattern: `<resource-name>.privatelink.<service>.azure.net`
   - Example: `mystorageaccount.privatelink.blob.core.windows.net → 10.0.1.5`
   - Do not manually modify private endpoint records
   - Document private endpoint to DNS record mapping

3. **Record Lifecycle**
   - Set appropriate TTL values (300-3600 seconds)
   - Clean up records for deleted resources
   - Implement automated record creation (IaC)
   - Document manual record changes
   - Regular audits of DNS records

4. **Record Limits**
   - Maximum 25,000 record sets per zone
   - Maximum 1,000 records per record set
   - Plan for capacity with large environments
   - Monitor record set count proactively

### Monitoring and Troubleshooting

1. **DNS Resolution Testing**
   ```bash
   # From a VM in the linked VNet
   
   # Linux
   nslookup myapp.privatelink.azurewebsites.net
   dig myapp.privatelink.azurewebsites.net
   host myapp.privatelink.azurewebsites.net
   
   # Check specific name server
   nslookup myapp.privatelink.azurewebsites.net 168.63.129.16
   
   # Windows
   nslookup myapp.privatelink.azurewebsites.net
   Resolve-DnsName myapp.privatelink.azurewebsites.net
   
   # PowerShell - detailed
   Resolve-DnsName myapp.privatelink.azurewebsites.net -Type A -Server 168.63.129.16
   ```

2. **Common DNS Issues**
   - **Resolution fails**: Check VNet link, verify record exists
   - **Wrong IP returned**: Check for overlapping zones, conditional forwarding
   - **Slow resolution**: Check VNet DNS settings, custom DNS servers
   - **Intermittent failures**: DNS cache issues, check TTL values

3. **Diagnostic Commands**
   ```bash
   # List all DNS zones
   az network private-dns zone list \
     --resource-group <resource-group> \
     --output table
   
   # Show zone details
   az network private-dns zone show \
     --resource-group <resource-group> \
     --name <zone-name>
   
   # List VNet links
   az network private-dns link vnet list \
     --resource-group <resource-group> \
     --zone-name <zone-name>
   
   # List all records
   az network private-dns record-set list \
     --resource-group <resource-group> \
     --zone-name <zone-name>
   ```

4. **Logging and Auditing**
   - Enable diagnostic settings for activity logs
   - Monitor zone configuration changes
   - Track record modifications
   - Implement Azure Policy for governance
   - Regular security audits

---

## Troubleshooting

### Common Issues

#### Issue 1: Alert Not Firing Despite High Record Count

**Symptoms:**
- Record set count exceeds threshold
- No alert triggered

**Troubleshooting Steps:**
```bash
# Check current record set count
az network private-dns record-set list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "length(@)"

# Verify metric availability
az monitor metrics list \
  --resource <dns-zone-resource-id> \
  --metric "RecordSetCount"

# Check alert configuration
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "private-dns-recordset-count-<zone-name>"
```

**Common Causes:**
- Wrong zone name in variables (dots not replaced with dashes)
- Alert disabled
- Threshold too high (default 25,000)
- Action group misconfigured

**Resolution:**
```hcl
# Verify zone name format
dns_zone_names = ["privatelink.azurewebsites.net"]

# Alert names replace dots with dashes
# "private-dns-recordset-count-privatelink-azurewebsites-net"
```

---

#### Issue 2: DNS Resolution Not Working After Zone Creation

**Symptoms:**
- Private DNS zone created
- VNet linked
- DNS resolution fails

**Troubleshooting Steps:**
```bash
# Verify VNet link
az network private-dns link vnet list \
  --resource-group <resource-group> \
  --zone-name <zone-name>

# Check VNet link status
az network private-dns link vnet show \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --name <link-name> \
  --query "provisioningState"

# Verify DNS records exist
az network private-dns record-set a list \
  --resource-group <resource-group> \
  --zone-name <zone-name>

# Check VNet DNS settings
az network vnet show \
  --resource-group <resource-group> \
  --name <vnet-name> \
  --query "dhcpOptions.dnsServers"
```

**Common Causes:**
- VNet link not created
- VNet using custom DNS servers (not Azure DNS)
- DNS record not created
- Incorrect zone name
- DNS cache on client

**Resolution:**
```bash
# Create VNet link
az network private-dns link vnet create \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --name "link-to-vnet-prod" \
  --virtual-network <vnet-id> \
  --registration-enabled false

# Reset VNet to use Azure DNS (168.63.129.16)
az network vnet update \
  --resource-group <resource-group> \
  --name <vnet-name> \
  --dns-servers ""

# Clear DNS cache on client (Windows)
ipconfig /flushdns

# Clear DNS cache on client (Linux)
sudo systemd-resolve --flush-caches
```

---

#### Issue 3: Auto-Registration Creating Too Many Records

**Symptoms:**
- Record set count alert firing
- Many auto-registered VM records

**Troubleshooting Steps:**
```bash
# List auto-registered records
az network private-dns record-set a list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "[?metadata!=null]"

# Check VNet link auto-registration setting
az network private-dns link vnet show \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --name <link-name> \
  --query "registrationEnabled"
```

**Common Causes:**
- Auto-registration enabled on multiple zones
- Many VMs with short lifecycles (scale sets)
- Stale records not cleaned up

**Resolution:**
```bash
# Disable auto-registration if not needed
az network private-dns link vnet update \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --name <link-name> \
  --set registrationEnabled=false

# Manually clean up old records
# Note: Auto-registered records are cleaned up when VMs are deleted
# Manual cleanup needed for orphaned records

# Delete a specific auto-registered record
az network private-dns record-set a delete \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --name <vm-name> \
  --yes
```

---

#### Issue 4: Private Endpoint DNS Not Resolving

**Symptoms:**
- Private endpoint created
- DNS resolution returns public IP instead of private IP

**Troubleshooting Steps:**
```bash
# Check private endpoint
az network private-endpoint show \
  --resource-group <resource-group> \
  --name <private-endpoint-name>

# Check private DNS zone group (automatic DNS integration)
az network private-endpoint dns-zone-group show \
  --resource-group <resource-group> \
  --endpoint-name <private-endpoint-name> \
  --name default

# Verify A record exists
az network private-dns record-set a list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "[?name=='<resource-name>']"
```

**Common Causes:**
- Private DNS zone group not configured
- Wrong DNS zone linked
- DNS zone not linked to VNet
- DNS cached public IP

**Resolution:**
```bash
# Create private DNS zone group
az network private-endpoint dns-zone-group create \
  --resource-group <resource-group> \
  --endpoint-name <private-endpoint-name> \
  --name default \
  --private-dns-zone <dns-zone-id> \
  --zone-name <zone-name>

# Verify DNS resolution from VM
nslookup <resource-name>.<zone-name>
# Should return private IP (e.g., 10.0.1.5)

# Clear DNS cache if needed
ipconfig /flushdns  # Windows
sudo systemd-resolve --flush-caches  # Linux
```

---

### Validation Commands

```bash
# 1. List all Private DNS zones
az network private-dns zone list \
  --resource-group <resource-group> \
  --output table

# 2. Show zone details
az network private-dns zone show \
  --resource-group <resource-group> \
  --name <zone-name>

# 3. Count record sets
az network private-dns record-set list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --query "length(@)"

# 4. List VNet links
az network private-dns link vnet list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --output table

# 5. Check metric availability
az monitor metrics list-definitions \
  --resource <dns-zone-resource-id>

# 6. Query record set count metric
az monitor metrics list \
  --resource <dns-zone-resource-id> \
  --metric "RecordSetCount" \
  --start-time <start-time> \
  --end-time <end-time>

# 7. List all alerts
az monitor metrics alert list \
  --resource-group <resource-group> \
  --output table

# 8. Test DNS resolution
nslookup <record-name>.<zone-name> 168.63.129.16

# 9. List activity log for zone
az monitor activity-log list \
  --resource-id <dns-zone-resource-id> \
  --start-time <start-time>

# 10. Export zone records (backup)
az network private-dns record-set list \
  --resource-group <resource-group> \
  --zone-name <zone-name> \
  --output json > dns-zone-backup.json

# 11. Validate Terraform deployment
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan

# 12. Test from specific name server
dig @168.63.129.16 <record-name>.<zone-name>
```

---

## License

This module is provided as-is under the MIT License. See LICENSE file for details.

---

**Module Maintained By:** Platform Engineering Team  
**Last Updated:** 2024-11-24  
**Terraform Version:** >= 1.0  
**Azure Provider Version:** >= 3.0

For questions or issues, please contact the Platform Engineering team or open an issue in the repository.
