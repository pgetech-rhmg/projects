# Azure Virtual Network (VNet) - Metric Alerts Module

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Variables](#variables)
- [Alert Details](#alert-details)
- [Severity Levels](#severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Overview

This Terraform module creates comprehensive monitoring alerts for **Azure Virtual Networks (VNet)**, providing critical security monitoring for Distributed Denial of Service (DDoS) attack detection across your network infrastructure. The module focuses on network security and availability by monitoring DDoS protection status to ensure rapid response to network-based attacks.

Azure Virtual Network is the fundamental building block for your private network in Azure, providing isolation, segmentation, and secure communication between Azure resources. This module implements essential security monitoring to detect and alert on DDoS attacks that could impact network availability and service continuity.

## Features

- **DDoS Attack Detection**: Real-time monitoring for Distributed Denial of Service attacks on VNets
- **Critical Security Alerting**: Immediate notification when DDoS attack is detected (Severity 1)
- **Multi-VNet Support**: Enterprise-scale monitoring across multiple virtual networks
- **Azure DDoS Protection Integration**: Works with both Basic and Standard DDoS Protection
- **Real-Time Alerting**: 1-minute evaluation frequency for immediate threat detection
- **Cost-Effective Monitoring**: Minimal alert configuration at $0.10 per VNet per month
- **Enterprise Integration**: Built-in support for PGE operational procedures and security compliance
- **Regulatory Compliance**: SOX, HIPAA, PCI-DSS compliance support for network security monitoring

### Key Monitoring Capabilities
- **Security Operations**: Early detection of network-level attacks for rapid incident response
- **Service Availability**: Protection of critical services from network-based attacks
- **Compliance Assurance**: Network security monitoring for regulatory compliance requirements
- **Threat Intelligence**: Real-time attack detection integrated with Azure DDoS Protection
- **Business Continuity**: Rapid response to threats impacting network availability

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Network/virtualNetworks/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Virtual Networks**: VNets deployed in Azure
- **Azure DDoS Protection** (Recommended): Standard DDoS Protection for enhanced attack detection and mitigation
- **Recommended**: Log Analytics workspace for diagnostic settings
- **Recommended**: Diagnostic settings enabled on Virtual Networks for DDoS Protection logs

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs provides essential security analysis capabilities for DDoS attack investigation, mitigation reports, and flow logs.

## Usage

### Basic Configuration

```hcl
module "vnet_alerts" {
  source = "./modules/metricAlerts/vnet"
  
  # Resource Configuration
  resource_group_name               = "rg-network-production"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-security-actiongroup"
  
  # Virtual Networks to Monitor
  vnet_names = [
    "vnet-prod-eastus-001",
    "vnet-prod-westus-001",
    "vnet-prod-centralus-001"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "NetworkInfrastructure"
    Owner             = "network-team@pge.com"
    CostCenter        = "IT-Infrastructure"
    Compliance        = "SOX"
    DataClassification = "Internal"
    SecurityTier       = "Critical"
  }
}
```

### Advanced Configuration with Security Action Group

```hcl
module "vnet_alerts_security" {
  source = "./modules/metricAlerts/vnet"
  
  # Resource Configuration
  resource_group_name               = "rg-network-security"
  action_group_resource_group_name  = "rg-security-monitoring"
  action_group                      = "pge-security-soc-actiongroup"  # Security Operations Center
  
  # Critical VNets with Enhanced Monitoring
  vnet_names = [
    "vnet-prod-dmz-001",
    "vnet-prod-webapp-001",
    "vnet-prod-data-001",
    "vnet-prod-management-001"
  ]
  
  # DDoS Attack Detection (0 = any attack detected)
  vnet_if_under_ddos_attack_threshold = 0
  
  tags = {
    Environment        = "Production"
    SecurityZone       = "DMZ"
    Compliance         = "PCI-DSS"
    Owner             = "security-team@pge.com"
    IncidentResponse   = "security-soc@pge.com"
    EscalationPath     = "critical"
    DataClassification = "Highly Confidential"
  }
}
```

### Environment-Specific Configurations

#### Production Environment
```hcl
# Production VNets - Maximum Security Monitoring
resource_group_name               = "rg-network-production"
action_group                      = "pge-security-soc-actiongroup"
vnet_if_under_ddos_attack_threshold = 0  # Alert on any attack detection

vnet_names = [
  "vnet-prod-hub-001",
  "vnet-prod-spoke-web-001",
  "vnet-prod-spoke-app-001",
  "vnet-prod-spoke-data-001"
]

tags = {
  Environment = "Production"
  Compliance  = "SOX-Critical"
  SecurityTier = "High"
}
```

#### Staging Environment
```hcl
# Staging VNets - Standard Security Monitoring
resource_group_name               = "rg-network-staging"
action_group                      = "pge-operations-actiongroup"
vnet_if_under_ddos_attack_threshold = 0

vnet_names = [
  "vnet-staging-hub-001",
  "vnet-staging-spoke-001"
]

tags = {
  Environment = "Staging"
  SecurityTier = "Medium"
}
```

#### Development Environment
```hcl
# Development VNets - Standard Monitoring
resource_group_name               = "rg-network-dev"
action_group                      = "pge-dev-actiongroup"
vnet_if_under_ddos_attack_threshold = 0

vnet_names = [
  "vnet-dev-001",
  "vnet-dev-002"
]

tags = {
  Environment = "Development"
  SecurityTier = "Low"
}
```

### Security Zone Configurations

#### DMZ (Demilitarized Zone)
```hcl
# DMZ VNets - Critical Security Monitoring
vnet_names = [
  "vnet-prod-dmz-public-001",
  "vnet-prod-dmz-services-001"
]

action_group = "pge-security-soc-actiongroup"

tags = {
  SecurityZone = "DMZ"
  Exposure = "Internet-Facing"
  Compliance = "PCI-DSS"
  IncidentPriority = "P1"
}
```

#### Internal Application Tier
```hcl
# Application Tier VNets
vnet_names = [
  "vnet-prod-app-web-001",
  "vnet-prod-app-api-001",
  "vnet-prod-app-services-001"
]

tags = {
  SecurityZone = "Application"
  Exposure = "Internal"
  DataClassification = "Confidential"
}
```

#### Data Tier
```hcl
# Data Tier VNets - Highest Security
vnet_names = [
  "vnet-prod-data-sql-001",
  "vnet-prod-data-storage-001"
]

tags = {
  SecurityZone = "Data"
  Exposure = "Private"
  DataClassification = "Highly Confidential"
  Compliance = "HIPAA,SOX,PCI-DSS"
}
```

#### Management Tier
```hcl
# Management VNets - Administrative Access
vnet_names = [
  "vnet-prod-mgmt-jumpbox-001",
  "vnet-prod-mgmt-tools-001"
]

tags = {
  SecurityZone = "Management"
  Exposure = "Restricted"
  AccessControl = "Privileged"
}
```

### Hub-Spoke Topology Configurations

#### Hub VNet (Central Connectivity)
```hcl
# Hub VNet with Shared Services
module "vnet_alerts_hub" {
  source = "./modules/metricAlerts/vnet"
  
  resource_group_name = "rg-network-hub"
  
  vnet_names = [
    "vnet-prod-hub-eastus-001"  # Central hub with firewall, VPN, ExpressRoute
  ]
  
  tags = {
    NetworkTopology = "Hub"
    SharedServices = "Firewall,VPN,ExpressRoute"
    Criticality = "High"
  }
}
```

#### Spoke VNets (Workload Isolation)
```hcl
# Spoke VNets for Different Workloads
module "vnet_alerts_spokes" {
  source = "./modules/metricAlerts/vnet"
  
  resource_group_name = "rg-network-spokes"
  
  vnet_names = [
    "vnet-prod-spoke-web-001",
    "vnet-prod-spoke-app-001",
    "vnet-prod-spoke-data-001",
    "vnet-prod-spoke-shared-001"
  ]
  
  tags = {
    NetworkTopology = "Spoke"
    ConnectedToHub = "vnet-prod-hub-eastus-001"
  }
}
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `vnet_names` | `list(string)` | List of Virtual Network names to monitor |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for virtual networks |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |

### Alert Threshold Variables

| Variable | Type | Default | Description | Recommended Value |
|----------|------|---------|-------------|-------------------|
| `vnet_if_under_ddos_attack_threshold` | `number` | `0` | DDoS attack detection threshold (0 = any attack) | 0 (immediate detection) |

**Note**: The threshold of `0` means any DDoS attack detection (value > 0) will trigger the alert. This ensures immediate notification of any attack activity.

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "network-team@pge.com"        # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "security-team@pge.com"       # Security notification contact
  DataClassification = "Internal"                    # Data sensitivity
  CostCenter         = "IT-Infrastructure"          # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  SecurityZone       = "Production"                  # Security zone designation
  IncidentResponse   = "security-soc@pge.com"       # SOC contact
}
```

## Alert Details

### 1. VNet Under DDoS Attack Alert
- **Alert Name**: `if_under_DDOS_Attack-{vnet-name}`
- **Metric**: `IfUnderDDoSAttack`
- **Threshold**: > 0 (any attack detected)
- **Severity**: 1 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Maximum

**What this alert monitors**: Real-time detection of Distributed Denial of Service (DDoS) attacks targeting the Virtual Network. Azure DDoS Protection analyzes network traffic patterns and identifies volumetric, protocol, and resource layer attacks. When an attack is detected, this metric changes from 0 to 1, triggering the alert.

**Attack Types Detected**:
- **Volumetric Attacks**: UDP floods, ICMP floods, amplification attacks consuming network bandwidth
- **Protocol Attacks**: SYN floods, fragmented packet attacks, Ping of Death targeting network infrastructure
- **Resource Layer Attacks**: HTTP floods, DNS query floods, slowloris attacks targeting application layer

**What to do when this alert fires**:

#### Immediate Response (First 5 Minutes)
1. **Verify Attack Status**: 
   - Check Azure Portal > Virtual Network > DDoS Protection metrics
   - Confirm attack is active and review attack vectors (volumetric/protocol/application layer)
   - Identify impacted services and assess business impact

2. **Activate Incident Response**:
   - Notify Security Operations Center (SOC) and on-call security team
   - Open critical incident ticket with all available attack details
   - Activate DDoS incident response plan and playbook
   - Document initial observations including attack start time, affected VNet, and service impact

3. **Communication**:
   - Notify application owners of potentially impacted services
   - Update status page if customer-facing services are affected
   - Prepare stakeholder communication for management and compliance teams

#### Short-Term Actions (15-30 Minutes)
4. **Azure DDoS Protection Response**:
   - **With DDoS Protection Standard**: Azure automatically mitigates the attack
     - Monitor DDoS Protection metrics for mitigation effectiveness
     - Review DDoS mitigation reports in Azure Monitor
     - Track dropped packets and attack bandwidth metrics
   - **Without DDoS Protection Standard**: Consider immediate enrollment if attacks persist
     - Basic protection provides platform-level mitigation but with fewer features
     - Standard protection offers advanced mitigation, traffic analytics, and attack alerting

5. **Traffic Analysis**:
   - Review Network Security Group (NSG) flow logs for attack sources
   - Analyze traffic patterns in Azure Monitor and Log Analytics
   - Identify attack signatures and source IP addresses/regions
   - Export logs for forensic analysis and threat intelligence

6. **Containment Measures**:
   - Update NSG rules to block identified malicious traffic sources (if applicable)
   - Implement rate limiting at application gateway or load balancer if available
   - Consider geo-blocking if attacks originate from specific regions not required for business
   - Enable Web Application Firewall (WAF) if application layer attack detected

#### Medium-Term Actions (1-4 Hours)
7. **Service Restoration**:
   - Verify service availability and performance as mitigation takes effect
   - Test critical application functionality and user access
   - Monitor for secondary attacks or attack pattern changes
   - Scale resources if legitimate traffic surge follows attack mitigation

8. **Enhanced Monitoring**:
   - Enable additional logging and monitoring during attack period
   - Set up real-time dashboards for attack metrics and service health
   - Increase frequency of security monitoring and log review
   - Activate enhanced threat detection and alerting

9. **Root Cause Analysis**:
   - Investigate what made the network a target (exposed services, vulnerabilities)
   - Review attack surface and potential weaknesses
   - Document attack patterns, mitigation effectiveness, and lessons learned

#### Long-Term Actions (Post-Incident)
10. **Post-Incident Review**:
    - Conduct formal incident debrief with security, network, and application teams
    - Document complete attack timeline, response actions, and outcomes
    - Update incident response procedures based on lessons learned
    - Report to compliance teams if regulatory notification required

11. **Security Hardening**:
    - **Upgrade to DDoS Protection Standard** if not already enabled (highly recommended)
      - Cost: ~$2,944/month base + $30/protected resource
      - Benefits: Advanced mitigation, real-time attack metrics, expert support
    - Implement defense-in-depth strategy:
      - Azure Front Door or Application Gateway with WAF for application protection
      - Azure Firewall for network filtering and threat intelligence
      - Traffic Manager for geographic traffic distribution
      - CDN for static content to reduce origin load
    - Review and optimize NSG rules to minimize attack surface
    - Implement network segmentation to limit lateral movement
    - Enable Just-In-Time (JIT) access for management ports

12. **Architecture Review**:
    - Evaluate network architecture for DDoS resilience
    - Consider multi-region deployment for high availability during attacks
    - Implement autoscaling to handle legitimate traffic surges
    - Review DNS configuration and consider Azure DNS with DDoS protection
    - Assess need for third-party DDoS mitigation services for enhanced protection

13. **Compliance and Reporting**:
    - Document incident for compliance audits (SOX, HIPAA, PCI-DSS)
    - Report to relevant authorities if required by regulations
    - Update security risk register with attack details
    - Share threat intelligence with industry partners (anonymized)

14. **Continuous Improvement**:
    - Schedule regular DDoS response drills and tabletop exercises
    - Update incident response playbooks with new procedures
    - Train operations team on DDoS detection and response
    - Review and test DDoS protection coverage quarterly
    - Establish metrics for DDoS preparedness and response effectiveness

## Severity Levels

### Severity 1 (Critical) - Security and Availability Impact
- **VNet Under DDoS Attack**: Network infrastructure under active distributed denial of service attack

**Response Time**: Immediate (within 5 minutes)
**Escalation**: Immediate notification to Security Operations Center (SOC), on-call security engineer, network team, and senior management

**Impact Assessment**:
- **Service Availability**: Potential service disruption affecting customers and business operations
- **Financial Impact**: Revenue loss from service downtime, potential SLA violations
- **Security Impact**: Active attack on infrastructure, potential precursor to other attacks
- **Reputational Impact**: Service unavailability affecting customer trust and brand reputation
- **Compliance Impact**: Security incident requiring documentation and potential regulatory notification

## Cost Analysis

### Alert Costs (Monthly)
- **1 Metric Alert per VNet**: 1 × $0.10 = **$0.10 per VNet per month**
- **Action Group**: FREE (included)
- **Multi-VNet Deployment**: Scales linearly with VNet count

### Cost Examples by Environment

#### Small Environment (3 VNets)
- **Monthly Alert Cost**: 3 × $0.10 = $0.30
- **Annual Alert Cost**: $3.60

#### Medium Environment (10 VNets)
- **Monthly Alert Cost**: 10 × $0.10 = $1.00
- **Annual Alert Cost**: $12.00

#### Large Environment (25 VNets)
- **Monthly Alert Cost**: 25 × $0.10 = $2.50
- **Annual Alert Cost**: $30.00

#### Enterprise Environment (100 VNets)
- **Monthly Alert Cost**: 100 × $0.10 = $10.00
- **Annual Alert Cost**: $120.00

#### Global Enterprise Environment (500 VNets)
- **Monthly Alert Cost**: 500 × $0.10 = $50.00
- **Annual Alert Cost**: $600.00

### Return on Investment (ROI)

#### Cost of DDoS Attacks Without Monitoring
- **Service Downtime**: $100,000-5,000,000/hour depending on business criticality
- **Revenue Loss**: $50,000-2,000,000/hour for e-commerce and online services
- **Customer Compensation**: $100,000-1,000,000 for SLA violations
- **Reputation Damage**: Immeasurable long-term customer trust impact
- **Emergency Response**: $50,000-500,000 in emergency mitigation costs
- **Incident Investigation**: $25,000-250,000 in forensic analysis and remediation

#### Alert Value Calculation (10 VNets)
- **Annual Alert Cost**: $12.00
- **Average DDoS Attack Cost Prevented**: $500,000 (1 attack/year conservative estimate)
- **Cost Avoidance**: $500,000/year
- **ROI**: 4,166,567% (($500,000 - $12) / $12 × 100)

#### DDoS Protection Cost Context
- **DDoS Protection Standard**: ~$2,944/month + $30/protected resource
- **Network Virtual Appliances**: $500-5,000/month for third-party solutions
- **Azure Firewall Premium**: ~$1,250/month with threat intelligence
- **Alert Monitoring**: $0.10/VNet/month

**Alert Cost Impact**: Negligible compared to DDoS attack costs and protection infrastructure

### Business Justification
This minimal monitoring investment ($0.10/VNet/month) provides:
- **Early Attack Detection**: Immediate notification enabling rapid response
- **Reduced Downtime**: Faster mitigation through early awareness
- **Compliance Evidence**: Documented security monitoring for audits
- **Incident Response**: Critical input for security operations and forensics
- **Risk Mitigation**: Proactive security posture against evolving threats

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive security monitoring and attack investigation, enable diagnostic settings on your Virtual Network resources. While metric alerts monitor DDoS attack status, diagnostic settings provide detailed logs for forensic analysis and attack mitigation reports.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings for DDoS Protection via Azure CLI
az monitor diagnostic-settings create \
  --name "vnet-ddos-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/virtualNetworks/{vnet-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"DDoSProtectionNotifications","enabled":true,"retentionPolicy":{"days":90,"enabled":true}},
    {"category":"DDoSMitigationFlowLogs","enabled":true,"retentionPolicy":{"days":90,"enabled":true}},
    {"category":"DDoSMitigationReports","enabled":true,"retentionPolicy":{"days":90,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "vnet_diagnostics" {
  for_each                   = toset(var.vnet_names)
  name                       = "vnet-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_virtual_network.vnets[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # DDoS Protection Notifications - Attack start/stop
  enabled_log {
    category = "DDoSProtectionNotifications"
  }

  # DDoS Mitigation Flow Logs - Real-time traffic flows
  enabled_log {
    category = "DDoSMitigationFlowLogs"
  }

  # DDoS Mitigation Reports - Post-attack analysis
  enabled_log {
    category = "DDoSMitigationReports"
  }

  # All Metrics including DDoS attack indicators
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Category | Purpose | When to Enable | Retention |
|----------|---------|----------------|-----------|
| **DDoSProtectionNotifications** | Attack start/stop notifications, threshold breaches | **Always** - Critical for security operations | 90+ days |
| **DDoSMitigationFlowLogs** | Real-time traffic flows during mitigation | **Always** - Forensic analysis | 90+ days |
| **DDoSMitigationReports** | Post-attack summary reports, metrics, mitigation actions | **Always** - Incident investigation | 90+ days |

#### Useful Log Analytics Queries

```kusto
// DDoS attack history
AzureDiagnostics
| where Category == "DDoSProtectionNotifications"
| where TimeGenerated > ago(90d)
| where resourceType_s == "VIRTUALNETWORK"
| project TimeGenerated, Resource, OperationName, Message, publicIpAddress_s
| order by TimeGenerated desc

// Attack mitigation summary
AzureDiagnostics
| where Category == "DDoSMitigationReports"
| where TimeGenerated > ago(30d)
| summarize 
    AttackCount = count(),
    MaxAttackDuration = max(attackDurationMinutes_d),
    AvgAttackDuration = avg(attackDurationMinutes_d)
  by Resource, bin(TimeGenerated, 1d)
| order by TimeGenerated desc

// Traffic flow analysis during attacks
AzureDiagnostics
| where Category == "DDoSMitigationFlowLogs"
| where TimeGenerated > ago(7d)
| summarize 
    TotalPackets = sum(packetsForwarded_d + packetsDropped_d),
    DroppedPackets = sum(packetsDropped_d),
    DropRate = round(100.0 * sum(packetsDropped_d) / sum(packetsForwarded_d + packetsDropped_d), 2)
  by bin(TimeGenerated, 5m), sourcePublicIpAddress_s
| order by TimeGenerated desc

// Public IP addresses under attack
AzureDiagnostics
| where Category == "DDoSProtectionNotifications"
| where TimeGenerated > ago(30d)
| where Message contains "attack"
| summarize AttackCount = count() by publicIpAddress_s
| order by AttackCount desc
```

### 2. DDoS Protection Configuration

#### Enable Azure DDoS Protection Standard (Highly Recommended)
```bash
# Create DDoS Protection Plan
az network ddos-protection create \
  --resource-group "rg-network-security" \
  --name "ddos-protection-prod" \
  --location "eastus"

# Enable DDoS Protection on VNet
az network vnet update \
  --resource-group "rg-network-production" \
  --name "vnet-prod-hub-001" \
  --ddos-protection true \
  --ddos-protection-plan "/subscriptions/{subscription-id}/resourceGroups/rg-network-security/providers/Microsoft.Network/ddosProtectionPlans/ddos-protection-prod"

# Verify DDoS Protection is enabled
az network vnet show \
  --resource-group "rg-network-production" \
  --name "vnet-prod-hub-001" \
  --query "{Name:name, DDoSProtection:enableDdosProtection, DDoSPlan:ddosProtectionPlan.id}"
```

#### Configure DDoS Protection Metrics
```bash
# View DDoS Protection metrics
az monitor metrics list \
  --resource "/subscriptions/{subscription-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001" \
  --metric "IfUnderDDoSAttack" \
  --start-time $(date -u -v-30d '+%Y-%m-%dT%H:%M:%SZ') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ')

# List available DDoS metrics
az monitor metrics list-definitions \
  --resource "/subscriptions/{subscription-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001" \
  --query "[?starts_with(name.value, 'DDoS')]"
```

### 3. Alert Response Procedures

#### Severity 1 (Critical) - Immediate Response
- **DDoS Attack Detected** → Activate incident response team, monitor traffic, verify mitigation effectiveness

**Response Time**: < 5 minutes  
**Escalation**: Page on-call engineer + security operations center (SOC)

**Immediate Actions**:
1. Verify attack is real (not false positive)
2. Activate DDoS response playbook
3. Monitor mitigation flow logs
4. Notify stakeholders (management, customers if needed)
5. Document attack characteristics
6. Engage Azure Support if needed

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable Azure DDoS Protection Standard on all critical VNets
- [ ] Enable diagnostic settings on all Virtual Networks
- [ ] Configure Log Analytics workspace with 90+ day retention for security logs
- [ ] Set up action groups with SOC and network team
- [ ] Create DDoS response playbook
- [ ] Test alert notifications to verify delivery
- [ ] Document escalation procedures
- [ ] Configure public IP addresses for DDoS Protection

#### Ongoing Operations
- [ ] Review DDoS attack logs weekly
- [ ] Test DDoS response procedures quarterly
- [ ] Verify diagnostic settings remain enabled monthly
- [ ] Update alert rules for new Virtual Networks
- [ ] Validate action group membership monthly
- [ ] Review DDoS Protection Plan coverage quarterly
- [ ] Conduct tabletop exercises for DDoS scenarios

#### Security & Compliance
- [ ] Audit DDoS Protection coverage across all VNets
- [ ] Document attack incidents for compliance
- [ ] Review and update DDoS response playbooks
- [ ] Maintain evidence for security audits
- [ ] Correlate DDoS attacks with threat intelligence
- [ ] Review DDoS Protection metrics and trends

### Network Security Best Practices (Continued)
```hcl
# Multi-layered security architecture
module "network_security" {
  source = "./modules/network-security"
  
  # Layer 1: Azure DDoS Protection
  enable_ddos_protection_standard = true
  
  # Layer 2: Azure Firewall with Threat Intelligence
  deploy_azure_firewall = true
  firewall_threat_intel_mode = "Alert and Deny"
  
  # Layer 3: Network Security Groups
  deploy_network_security_groups = true
  
  # Layer 4: Web Application Firewall
  deploy_waf_policy = true
  waf_mode = "Prevention"
  
  # Layer 5: Azure Front Door / Application Gateway
  deploy_front_door = true
  front_door_waf_policy_id = azurerm_frontdoor_firewall_policy.waf.id
}
```

#### 2. Configure Network Security Groups (NSGs)
```bash
# Create restrictive NSG for production VNet
az network nsg create \
  --resource-group "rg-network-production" \
  --name "nsg-prod-vnet-001"

# Allow only required inbound traffic
az network nsg rule create \
  --resource-group "rg-network-production" \
  --nsg-name "nsg-prod-vnet-001" \
  --name "Allow-HTTPS-Inbound" \
  --priority 100 \
  --source-address-prefixes "Internet" \
  --destination-port-ranges 443 \
  --access "Allow" \
  --protocol "Tcp"

# Deny all other inbound traffic (explicit deny)
az network nsg rule create \
  --resource-group "rg-network-production" \
  --nsg-name "nsg-prod-vnet-001" \
  --name "Deny-All-Inbound" \
  --priority 4096 \
  --source-address-prefixes "*" \
  --destination-port-ranges "*" \
  --access "Deny" \
  --protocol "*"

# Enable NSG flow logs for attack analysis
az network watcher flow-log create \
  --resource-group "rg-network-production" \
  --nsg "nsg-prod-vnet-001" \
  --storage-account "stprodnetflowlogs" \
  --workspace "/subscriptions/{sub-id}/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-security" \
  --name "nsg-flow-log-001" \
  --enabled true \
  --retention 90 \
  --traffic-analytics true \
  --interval 10
```

#### 3. Implement Azure Firewall with Threat Intelligence
```bash
# Create Azure Firewall for centralized security
az network firewall create \
  --resource-group "rg-network-hub" \
  --name "afw-hub-prod-001" \
  --location "eastus" \
  --vnet-name "vnet-prod-hub-001" \
  --public-ip "pip-firewall-001" \
  --sku "AZFW_VNet" \
  --tier "Premium"

# Enable threat intelligence in alert and deny mode
az network firewall update \
  --resource-group "rg-network-hub" \
  --name "afw-hub-prod-001" \
  --threat-intel-mode "Alert and Deny"

# Create firewall policy with threat intelligence
az network firewall policy create \
  --resource-group "rg-network-hub" \
  --name "afwp-hub-prod-001" \
  --threat-intel-mode "Alert and Deny" \
  --sku "Premium"
```

### Monitoring and Incident Response

#### 1. Configure Comprehensive DDoS Monitoring Dashboard
```powershell
# PowerShell script to create DDoS monitoring dashboard
function New-DDoSMonitoringDashboard {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$DashboardName,
        
        [Parameter(Mandatory=$true)]
        [string[]]$VNetResourceIds
    )
    
    $DashboardConfig = @{
        location = "eastus"
        properties = @{
            lenses = @{
                0 = @{
                    order = 0
                    parts = @{
                        0 = @{
                            position = @{ x = 0; y = 0; colSpan = 6; rowSpan = 4 }
                            metadata = @{
                                type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"
                                settings = @{
                                    content = @{
                                        chartTitle = "DDoS Attack Status"
                                        metrics = @(
                                            @{
                                                resourceMetadata = @{ id = $VNetResourceIds[0] }
                                                name = "IfUnderDDoSAttack"
                                                namespace = "Microsoft.Network/virtualNetworks"
                                                aggregationType = 4  # Maximum
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        1 = @{
                            position = @{ x = 6; y = 0; colSpan = 6; rowSpan = 4 }
                            metadata = @{
                                type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"
                                settings = @{
                                    content = @{
                                        chartTitle = "Inbound Packets Dropped DDoS"
                                        metrics = @(
                                            @{
                                                resourceMetadata = @{ id = $VNetResourceIds[0] }
                                                name = "PacketsDroppedDDoS"
                                                namespace = "Microsoft.Network/publicIPAddresses"
                                                aggregationType = 1  # Total
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        tags = @{
            Purpose = "DDoS Monitoring"
            Owner = "Security Team"
        }
    }
    
    # Create dashboard (simplified example)
    Write-Host "DDoS Monitoring Dashboard configuration prepared" -ForegroundColor Green
    Write-Host "Deploy through Azure Portal or ARM template" -ForegroundColor Yellow
}

# Usage
$VNets = @(
    "/subscriptions/{sub-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001"
)
New-DDoSMonitoringDashboard -ResourceGroupName "rg-monitoring" -DashboardName "ddos-monitoring-dashboard" -VNetResourceIds $VNets
```

#### 2. Automated Incident Response Workflow
```powershell
# PowerShell script for automated DDoS incident response
function Start-DDoSIncidentResponse {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VNetResourceId,
        
        [Parameter(Mandatory=$true)]
        [string]$IncidentTicketId
    )
    
    Write-Host "DDoS Incident Response Initiated" -ForegroundColor Red
    Write-Host "VNet: $VNetResourceId" -ForegroundColor Yellow
    Write-Host "Incident: $IncidentTicketId" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Red
    
    # Step 1: Gather attack metrics
    Write-Host "1. Gathering attack metrics..." -ForegroundColor Cyan
    $AttackStatus = Get-AzMetric -ResourceId $VNetResourceId -MetricName "IfUnderDDoSAttack" -TimeGrain 00:01:00 -StartTime (Get-Date).AddMinutes(-30)
    
    if ($AttackStatus.Data | Where-Object { $_.Maximum -gt 0 }) {
        Write-Host "   CONFIRMED: DDoS attack detected" -ForegroundColor Red
        
        # Step 2: Check DDoS Protection status
        Write-Host "2. Checking DDoS Protection status..." -ForegroundColor Cyan
        $VNet = Get-AzVirtualNetwork -ResourceId $VNetResourceId
        if ($VNet.EnableDdosProtection) {
            Write-Host "   DDoS Protection Standard: ENABLED" -ForegroundColor Green
            Write-Host "   Azure is automatically mitigating the attack" -ForegroundColor Green
        } else {
            Write-Host "   WARNING: DDoS Protection Standard NOT enabled" -ForegroundColor Red
            Write-Host "   Only basic platform-level protection active" -ForegroundColor Yellow
        }
        
        # Step 3: Collect NSG flow logs
        Write-Host "3. Collecting NSG flow logs for analysis..." -ForegroundColor Cyan
        # Implementation would query NSG flow logs from storage account
        
        # Step 4: Generate incident report
        Write-Host "4. Generating incident report..." -ForegroundColor Cyan
        $Report = @{
            IncidentId = $IncidentTicketId
            VNetId = $VNetResourceId
            AttackStartTime = ($AttackStatus.Data | Where-Object { $_.Maximum -gt 0 } | Select-Object -First 1).TimeStamp
            DDoSProtectionEnabled = $VNet.EnableDdosProtection
            ImpactAssessment = "Service availability at risk"
            RecommendedActions = @(
                "Monitor DDoS Protection metrics",
                "Review NSG flow logs for attack sources",
                "Prepare stakeholder communication",
                "Consider enabling DDoS Protection Standard if not active"
            )
        }
        
        Write-Host "`nIncident Report:" -ForegroundColor Green
        $Report | ConvertTo-Json -Depth 3 | Write-Host
        
        # Step 5: Send notifications
        Write-Host "5. Sending notifications to security team..." -ForegroundColor Cyan
        # Implementation would send emails, Teams messages, ServiceNow tickets, etc.
        
    } else {
        Write-Host "   No active DDoS attack detected" -ForegroundColor Green
    }
}

# Usage
Start-DDoSIncidentResponse -VNetResourceId "/subscriptions/{sub}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001" -IncidentTicketId "INC0001234"
```

#### 3. Post-Attack Analysis and Reporting
```bash
# Query DDoS mitigation reports
az monitor log-analytics query \
  --workspace "law-security" \
  --analytics-query "AzureDiagnostics 
    | where ResourceProvider == 'MICROSOFT.NETWORK' 
    | where Category == 'DDoSMitigationReports'
    | where TimeGenerated > ago(7d)
    | project TimeGenerated, Resource, OperationName, ResultDescription
    | order by TimeGenerated desc" \
  --output table

# Export DDoS flow logs for forensic analysis
az monitor log-analytics query \
  --workspace "law-security" \
  --analytics-query "AzureDiagnostics 
    | where Category == 'DDoSMitigationFlowLogs'
    | where TimeGenerated > ago(24h)
    | summarize TotalPackets=sum(PacketCount), 
                TotalBytes=sum(ByteCount) 
      by SourceIP=SourcePublicIPAddress, 
         DestinationIP=DestinationPublicIPAddress,
         Protocol=Protocol
    | order by TotalPackets desc" \
  --output table
```

### Network Architecture Best Practices

#### 1. Hub-Spoke Topology with Centralized Security
```
┌─────────────────────────────────────────────────────────────┐
│                     Hub VNet (Central)                      │
│  - Azure Firewall (Threat Intel: Alert and Deny)          │
│  - VPN Gateway / ExpressRoute                              │
│  - DDoS Protection Standard                                │
│  - Azure Bastion                                           │
└────────────┬────────────┬────────────┬──────────────────────┘
             │            │            │
      ┌──────┴────┐ ┌────┴────┐ ┌────┴────┐
      │  Spoke 1  │ │ Spoke 2 │ │ Spoke 3 │
      │    Web    │ │   App   │ │  Data   │
      └───────────┘ └─────────┘ └─────────┘
```

#### 2. Security Zoning with Tiered Protection
```
Internet
   ↓
[Azure Front Door + WAF] ← Application Layer Protection
   ↓
[DDoS Protection Standard] ← Network Layer Protection
   ↓
[Azure Firewall] ← Centralized filtering
   ↓
[DMZ VNet] → [App VNet] → [Data VNet]
     ↓            ↓           ↓
   [NSG]       [NSG]       [NSG] ← Subnet-level filtering
```

## Troubleshooting

### Common Issues and Solutions

#### 1. DDoS Attack Alert Fires
**Symptoms**: Alert notification indicates VNet is under DDoS attack

**Immediate Actions**:
```bash
# Verify attack status
az network vnet show \
  --resource-group "rg-network-production" \
  --name "vnet-prod-hub-001" \
  --query "{Name:name, DDoSProtection:enableDdosProtection}"

# Check DDoS metrics in real-time
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001" \
  --metric "IfUnderDDoSAttack" \
  --start-time "$(date -u -d '30 minutes ago' '+%Y-%m-%dT%H:%M:%SZ')" \
  --interval PT1M

# View DDoS mitigation details
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/publicIPAddresses/pip-frontend-001" \
  --metric "PacketsDroppedDDoS,PacketsForwardedDDoS,PacketsInDDoS" \
  --start-time "$(date -u -d '30 minutes ago' '+%Y-%m-%dT%H:%M:%SZ')"
```

**Resolution**:
- If DDoS Protection Standard is enabled, Azure is automatically mitigating
- Monitor mitigation effectiveness through Azure Portal DDoS Protection dashboard
- Document attack for post-incident review and compliance
- Consider additional protection measures based on attack patterns

#### 2. DDoS Protection Not Enabled
**Symptoms**: DDoS attack detected but limited mitigation available

**Troubleshooting**:
```bash
# Check if DDoS Protection Standard is enabled
az network vnet show \
  --resource-group "rg-network-production" \
  --name "vnet-prod-hub-001" \
  --query "{Name:name, DDoSEnabled:enableDdosProtection, DDoSPlan:ddosProtectionPlan}"
```

**Resolution**:
```bash
# Enable DDoS Protection Standard (recommended)
# 1. Create DDoS Protection Plan
az network ddos-protection create \
  --resource-group "rg-network-security" \
  --name "ddos-protection-prod" \
  --location "eastus"

# 2. Associate VNet with DDoS Protection Plan
az network vnet update \
  --resource-group "rg-network-production" \
  --name "vnet-prod-hub-001" \
  --ddos-protection true \
  --ddos-protection-plan "/subscriptions/{sub-id}/resourceGroups/rg-network-security/providers/Microsoft.Network/ddosProtectionPlans/ddos-protection-prod"

# Note: Enabling DDoS Protection Standard does NOT cause service interruption
```

**Cost Consideration**:
- DDoS Protection Standard: ~$2,944/month + $30/protected public IP
- Compared to potential attack costs: $100,000-5,000,000/hour downtime
- Strong ROI for production and critical environments

#### 3. False Positive Alerts
**Symptoms**: Alert fires but no actual attack is occurring

**Possible Causes**:
- Legitimate traffic spike misidentified as attack
- Threshold set too low (though 0 is standard for DDoS detection)
- Metric reporting lag or Azure platform issue

**Troubleshooting**:
```bash
# Verify metric values over time
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001" \
  --metric "IfUnderDDoSAttack" \
  --start-time "$(date -u -d '2 hours ago' '+%Y-%m-%dT%H:%M:%SZ')" \
  --interval PT1M \
  --output table

# Check for concurrent alerts or service health issues
az service-health-issue list \
  --subscription "{subscription-id}"

# Review NSG flow logs for traffic patterns
az network watcher flow-log show \
  --resource-group "rg-network-production" \
  --nsg "nsg-prod-vnet-001"
```

**Resolution**:
- Coordinate with Azure Support to investigate false positives
- Review DDoS Protection logs for attack classification details
- Document false positives for trend analysis
- Generally, threshold should remain at 0 for security reasons

#### 4. Unable to Access Services During Attack
**Symptoms**: Services unavailable or degraded performance during DDoS attack

**Immediate Actions**:
```bash
# Check service health
az network public-ip show \
  --resource-group "rg-network-production" \
  --name "pip-frontend-001" \
  --query "{IP:ipAddress, AllocationMethod:publicIpAllocationMethod, ProvisioningState:provisioningState}"

# Verify load balancer backend health
az network lb show \
  --resource-group "rg-network-production" \
  --name "lb-prod-web-001" \
  --query "backendAddressPools[].backendIpConfigurations"

# Check application gateway backend health
az network application-gateway show-backend-health \
  --resource-group "rg-network-production" \
  --name "agw-prod-001"
```

**Resolution**:
- Verify DDoS mitigation is active and effective
- Check if legitimate traffic is being blocked by overly restrictive NSG rules
- Consider scaling up resources to handle legitimate traffic surge post-mitigation
- Implement Azure Front Door or Traffic Manager for geographic distribution
- Contact Azure Support if mitigation is not effective

#### 5. Missing DDoS Metrics or Logs
**Symptoms**: Unable to view DDoS metrics or diagnostic logs

**Troubleshooting**:
```bash
# Verify diagnostic settings are configured
az monitor diagnostic-settings list \
  --resource "/subscriptions/{sub-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001"

# Check Log Analytics workspace connectivity
az monitor log-analytics workspace show \
  --resource-group "rg-monitoring" \
  --workspace-name "law-security" \
  --query "{Name:name, ProvisioningState:provisioningState, CustomerId:customerId}"
```

**Resolution**:
```bash
# Enable diagnostic settings for DDoS Protection
az monitor diagnostic-settings create \
  --name "ddos-diagnostics" \
  --resource "/subscriptions/{sub-id}/resourceGroups/rg-network-production/providers/Microsoft.Network/virtualNetworks/vnet-prod-hub-001" \
  --logs '[
    {"category": "DDoSProtectionNotifications", "enabled": true},
    {"category": "DDoSMitigationFlowLogs", "enabled": true},
    {"category": "DDoSMitigationReports", "enabled": true}
  ]' \
  --workspace "/subscriptions/{sub-id}/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-security"

# Verify logs are being ingested
az monitor log-analytics query \
  --workspace "law-security" \
  --analytics-query "AzureDiagnostics 
    | where ResourceProvider == 'MICROSOFT.NETWORK' 
    | where Category in ('DDoSProtectionNotifications', 'DDoSMitigationFlowLogs', 'DDoSMitigationReports')
    | summarize count() by Category, bin(TimeGenerated, 1h)
    | order by TimeGenerated desc"
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Virtual Network DDoS attack monitoring and follows PGE security and operational standards. **DDoS attacks are critical security incidents requiring immediate response.** Ensure proper incident response procedures, security team contacts, and escalation paths are established before deploying to production. **Enabling Azure DDoS Protection Standard is highly recommended for production VNets** to ensure automatic attack mitigation and enhanced monitoring capabilities. Regular DDoS response drills and security training are essential for effective incident management.