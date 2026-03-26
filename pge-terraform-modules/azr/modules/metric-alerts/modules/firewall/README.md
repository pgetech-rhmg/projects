# Azure Firewall AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure Firewall**. It provides production-ready monitoring across security, performance, capacity, and availability dimensions.

Azure Firewall is a managed, cloud-based network security service that protects Azure Virtual Network resources. This module monitors critical firewall metrics to ensure optimal security posture, performance, and reliability while preventing service disruptions from SNAT port exhaustion or throughput limitations.

## Table of Contents

- [Features](#features)
- [Alert Categories](#alert-categories)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Input Variables](#input-variables)
- [Alert Details](#alert-details)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Features

- **8 Metric Alerts** covering health, security, performance, and capacity
- **Customizable Thresholds** for all alerts
- **SNAT Port Exhaustion Prevention** with 95% utilization alerts
- **Threat Intelligence Monitoring** for malicious traffic detection
- **Performance Tracking** with latency and throughput monitoring
- **Health State Monitoring** for proactive issue detection
- **Rule Hit Count Analysis** for capacity and performance optimization
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 🔴 Critical Health & Security Alerts
- Firewall Health State (Severity 0)
- SNAT Port Utilization (Severity 1)
- Threat Intelligence Hits (Severity 1)

### 🟠 Performance Alerts
- Firewall Throughput (Severity 2)
- Firewall Latency Probe (Severity 2)

### 🟡 Capacity & Usage Alerts
- Data Processed (Severity 3)
- Application Rule Hit Count (Severity 3)
- Network Rule Hit Count (Severity 3)

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure Firewall (Standard or Premium SKU)
- Azure Monitor Action Group (pre-configured)
- **Recommended**: Log Analytics workspace for diagnostic settings
- **Recommended**: Diagnostic settings enabled on Azure Firewall resources
- Appropriate permissions to create Monitor alerts

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs provides essential troubleshooting capabilities for rule hits, threat intelligence, and network flows.

## Usage

### Basic Example

```hcl
module "firewall_alerts" {
  source = "./modules/metricAlerts/firewall"

  # Resource Configuration
  resource_group_name              = "rg-network-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Firewall Names to Monitor
  firewall_names = [
    "fw-hub-prod-001",
    "fw-hub-prod-002"
  ]

  # Tags
  tags = {
    Environment        = "Production"
    AppId              = "123456"
    CRIS               = "1"
    Compliance         = "SOX"
    DataClassification = "internal"
    Env                = "Prod"
    Notify             = "network-ops@pge.com"
    Owner              = "network-team@pge.com"
    order              = "123456"
  }
}
```

### Production Example with Custom Thresholds

```hcl
module "firewall_alerts_production" {
  source = "./modules/metricAlerts/firewall"

  # Resource Configuration
  resource_group_name              = "rg-network-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-security-actiongroup"
  location                         = "West US 3"

  # Firewall Names
  firewall_names = [
    "fw-hub-eastus-prod",
    "fw-hub-westus-prod",
    "fw-spoke-prod"
  ]

  # Critical Health & Security Thresholds
  firewall_health_threshold               = 95   # Alert if health drops below 95%
  firewall_snat_port_utilization_threshold = 90   # More aggressive monitoring
  firewall_threat_intel_threshold         = 0    # Alert on any malicious traffic

  # Performance Thresholds (Azure Firewall Premium ~100 Gbps max)
  firewall_throughput_threshold = 80000000000  # 80 Gbps for Premium
  firewall_latency_threshold    = 15           # 15ms average latency

  # Capacity Planning Thresholds
  firewall_data_processed_threshold   = 5000000000000  # 5 TB/hour
  firewall_app_rule_hit_threshold     = 500000         # 500k hits/hour
  firewall_net_rule_hit_threshold     = 1000000        # 1M hits/hour

  tags = {
    Environment     = "Production"
    CriticalityTier = "Tier0"
    SecurityZone    = "DMZ"
    Compliance      = "PCI-DSS"
  }
}
```

### Hub-Spoke Architecture Example

```hcl
# Hub Firewall - Central Security Control
module "hub_firewall_alerts" {
  source = "./modules/metricAlerts/firewall"

  resource_group_name              = "rg-network-hub"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "security-operations-actiongroup"
  location                         = "West US 3"

  firewall_names = ["fw-hub-central"]

  # Strict security monitoring for hub
  firewall_threat_intel_threshold         = 0   # Zero tolerance
  firewall_snat_port_utilization_threshold = 95  # Critical threshold
  firewall_health_threshold               = 98   # High availability requirement

  tags = {
    NetworkTier = "Hub"
    Function    = "CentralSecurity"
    Compliance  = "SOX,PCI-DSS,HIPAA"
  }
}

# Spoke Firewall - Application-Specific
module "spoke_firewall_alerts" {
  source = "./modules/metricAlerts/firewall"

  resource_group_name              = "rg-network-spoke-app1"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "application-ops-actiongroup"
  location                         = "West US 3"

  firewall_names = ["fw-spoke-app1"]

  # Application-focused monitoring
  firewall_app_rule_hit_threshold = 200000
  firewall_throughput_threshold   = 10000000000  # 10 Gbps for Standard

  tags = {
    NetworkTier = "Spoke"
    Application = "App1"
  }
}
```

### Multi-Region High Availability Example

```hcl
# Primary Region - East US
module "firewall_alerts_east" {
  source = "./modules/metricAlerts/firewall"

  resource_group_name              = "rg-network-eastus"
  action_group_resource_group_name = "rg-monitoring-eastus"
  action_group                     = "eastus-security-actiongroup"
  location                         = "East US"

  firewall_names = [
    "fw-eastus-az1",
    "fw-eastus-az2",
    "fw-eastus-az3"
  ]

  # High availability monitoring
  firewall_health_threshold = 99  # Strict availability requirement

  tags = {
    Region      = "EastUS"
    HARole      = "Primary"
    Environment = "Production"
  }
}

# Secondary Region - West US
module "firewall_alerts_west" {
  source = "./modules/metricAlerts/firewall"

  resource_group_name              = "rg-network-westus"
  action_group_resource_group_name = "rg-monitoring-westus"
  action_group                     = "westus-security-actiongroup"
  location                         = "West US 3"

  firewall_names = [
    "fw-westus-az1",
    "fw-westus-az2",
    "fw-westus-az3"
  ]

  firewall_health_threshold = 99

  tags = {
    Region      = "WestUS"
    HARole      = "Secondary"
    Environment = "Production"
  }
}
```

### Security-Focused Deployment

```hcl
module "firewall_security_alerts" {
  source = "./modules/metricAlerts/firewall"

  resource_group_name              = "rg-security-dmz"
  action_group_resource_group_name = "rg-security-monitoring"
  action_group                     = "security-incident-actiongroup"
  location                         = "West US 3"

  firewall_names = ["fw-dmz-prod"]

  # Security-first thresholds
  firewall_threat_intel_threshold = 0    # Immediate alert on any threat
  firewall_health_threshold       = 100  # Perfect health required

  # Lower thresholds for security investigation
  firewall_app_rule_hit_threshold = 50000   # Lower for anomaly detection
  firewall_net_rule_hit_threshold = 100000  # Lower for traffic analysis

  tags = {
    SecurityTier    = "Critical"
    Compliance      = "PCI-DSS"
    MonitoringLevel = "Enhanced"
    SOC             = "true"
  }
}
```

### Development Environment Example

```hcl
module "firewall_alerts_dev" {
  source = "./modules/metricAlerts/firewall"

  resource_group_name              = "rg-network-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  firewall_names = ["fw-dev-001"]

  # Relaxed thresholds for development
  firewall_health_threshold               = 80
  firewall_snat_port_utilization_threshold = 98
  firewall_threat_intel_threshold         = 5   # Less sensitive
  firewall_throughput_threshold           = 5000000000  # 5 Gbps

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group name where the action group is located |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where Azure Firewalls are located |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Name of the action group for alerts |
| `location` | `string` | `"West US 3"` | Azure region location |
| `firewall_names` | `list(string)` | `[]` | List of Azure Firewall names to monitor |

### Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `firewall_health_threshold` | `number` | `90` | Health state threshold (100=healthy, 0=unhealthy). Alert when below |
| `firewall_snat_port_utilization_threshold` | `number` | `95` | SNAT port utilization %. Alert when exceeding |
| `firewall_throughput_threshold` | `number` | `25000000000` | Throughput in bits/sec (Default: 25 Gbps) |
| `firewall_latency_threshold` | `number` | `20` | Latency probe threshold in milliseconds |
| `firewall_data_processed_threshold` | `number` | `1000000000000` | Data processed in bytes/hour (Default: 1 TB) |
| `firewall_app_rule_hit_threshold` | `number` | `100000` | Application rule hits per hour |
| `firewall_net_rule_hit_threshold` | `number` | `100000` | Network rule hits per hour |
| `firewall_threat_intel_threshold` | `number` | `0` | Threat intelligence hits. Alert on any detection |

### Tags Variable

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | See below | Tags applied to all alert resources |

**Default Tags:**
```hcl
{
  AppId              = "123456"
  Env                = "Dev"
  Owner              = "abc@pge.com"
  Compliance         = "SOX"
  Notify             = "abc@pge.com"
  DataClassification = "internal"
  CRIS               = "1"
  order              = "123456"
}
```

## Alert Details

### 1. Firewall Health State Alert

**Purpose**: Monitor overall firewall health and detect degradation  
**Metric**: `FirewallHealth`  
**Threshold**: < 90% (configurable)  
**Severity**: 0 (Critical)  
**Frequency**: PT1M (Every 1 minute)  
**Window**: PT5M (5 minutes)

**Description**: Azure Firewall health state indicates the overall health of the firewall instance. A value of 100% means the firewall is healthy, while lower values indicate degradation. This alert triggers when health drops below the threshold, indicating potential issues with firewall operation.

**Common Causes**:
- Backend infrastructure issues
- Resource constraints
- Configuration problems
- Network connectivity issues

**Recommended Actions**:
1. Check Azure Service Health for regional issues
2. Review firewall diagnostic logs
3. Verify network connectivity
4. Check for recent configuration changes
5. Monitor other firewall metrics (throughput, latency)

### 2. SNAT Port Utilization Alert

**Purpose**: Prevent SNAT port exhaustion and outbound connectivity failures  
**Metric**: `SNATPortUtilization`  
**Threshold**: > 95% (configurable)  
**Severity**: 1 (Error)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: SNAT (Source Network Address Translation) port utilization measures the percentage of available SNAT ports currently in use. Azure Firewall provides 2,496 SNAT ports per public IP address. When utilization exceeds 95%, there's high risk of port exhaustion, leading to outbound connection failures.

**Common Causes**:
- High number of concurrent outbound connections
- Long-lived connections not being closed properly
- Insufficient public IP addresses configured
- Application connection pooling issues

**Recommended Actions**:
1. Add additional public IP addresses to the firewall
2. Integrate with Azure NAT Gateway for additional SNAT capacity
3. Review application connection handling
4. Implement connection pooling
5. Reduce connection idle timeouts
6. Scale firewall instances if needed

**Prevention**:
- Configure multiple public IPs during firewall deployment
- Use NAT Gateway for high-scale scenarios
- Monitor trends to predict capacity needs

### 3. Firewall Throughput Alert

**Purpose**: Monitor firewall capacity utilization and prevent performance degradation  
**Metric**: `Throughput`  
**Threshold**: > 25 Gbps (configurable, 25 Gbps for Standard, 80-100 Gbps for Premium)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Firewall throughput measures the total amount of data processed by the firewall. Maximum throughput varies by SKU and features enabled. This alert triggers when approaching capacity limits, which can affect performance.

**Azure Firewall Maximum Throughput**:
- Standard SKU: ~30 Gbps
- Premium SKU: ~100 Gbps
- Varies based on enabled features (TLS inspection, IDPS)

**Common Causes**:
- Unexpected traffic spikes
- DDoS attacks
- Large file transfers
- Backup operations
- Application traffic growth

**Recommended Actions**:
1. Review traffic patterns in logs
2. Identify top talkers and bandwidth consumers
3. Consider scaling to Premium SKU if on Standard
4. Implement traffic shaping policies
5. Offload non-critical traffic
6. Deploy additional firewall instances
7. Review and optimize firewall rules

### 4. Firewall Latency Probe Alert

**Purpose**: Monitor firewall performance and detect latency issues  
**Metric**: `AzureFirewallLatencyProbeMsLatency`  
**Threshold**: > 20 milliseconds (configurable)  
**Severity**: 2 (Warning)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Latency probe metric measures the average latency of Azure Firewall. Elevated latency indicates performance degradation and can impact application response times. Intermittent latency spikes are normal, but sustained high latency requires investigation.

**Common Causes**:
- High throughput utilization
- Complex rule processing
- TLS inspection overhead
- IDPS processing
- Backend infrastructure issues

**Recommended Actions**:
1. Check throughput and data processed metrics
2. Review rule hit counts for inefficient rules
3. Optimize firewall rule order (most-hit rules first)
4. Consider rule consolidation
5. Review TLS inspection configuration
6. Check for correlation with other metrics

### 5. Data Processed Alert

**Purpose**: Monitor data volume and detect unusual traffic patterns  
**Metric**: `DataProcessed`  
**Threshold**: > 1 TB/hour (configurable)  
**Severity**: 3 (Informational)  
**Frequency**: PT15M (Every 15 minutes)  
**Window**: PT1H (1 hour)

**Description**: Data processed metric tracks the total volume of data flowing through the firewall. Unusual spikes can indicate DDoS attacks, data exfiltration, backup operations, or legitimate traffic growth.

**Common Causes**:
- Large file transfers or backups
- DDoS attacks
- Data exfiltration attempts
- Application deployment or updates
- Traffic growth

**Recommended Actions**:
1. Review firewall logs for traffic patterns
2. Identify source and destination of high-volume traffic
3. Correlate with application events
4. Check threat intelligence hits
5. Verify against scheduled maintenance windows
6. Monitor costs (data processing charges apply)

### 6. Application Rule Hit Count Alert

**Purpose**: Monitor application rule processing and detect anomalies  
**Metric**: `ApplicationRuleHit`  
**Threshold**: > 100,000 hits/hour (configurable)  
**Severity**: 3 (Informational)  
**Frequency**: PT15M (Every 15 minutes)  
**Window**: PT1H (1 hour)

**Description**: Application rule hit count tracks how many times application-layer rules are evaluated. High hit counts can indicate increased traffic, application changes, or potential performance impacts from rule processing.

**Common Causes**:
- Increased application traffic
- New application deployments
- Chatty applications
- Inefficient rule ordering
- DDoS or scanning attacks

**Recommended Actions**:
1. Review application rule logs
2. Identify most-hit rules
3. Optimize rule order (move frequent rules higher)
4. Consolidate similar rules
5. Use FQDN tags where possible
6. Monitor latency correlation

### 7. Network Rule Hit Count Alert

**Purpose**: Monitor network rule processing and capacity planning  
**Metric**: `NetworkRuleHit`  
**Threshold**: > 100,000 hits/hour (configurable)  
**Severity**: 3 (Informational)  
**Frequency**: PT15M (Every 15 minutes)  
**Window**: PT1H (1 hour)

**Description**: Network rule hit count tracks network-layer (Layer 3/4) rule evaluations. High hit counts can affect firewall performance and indicate traffic patterns requiring optimization.

**Common Causes**:
- High connection rates
- Network scanning
- Microservices communication patterns
- Database connections
- Rule evaluation overhead

**Recommended Actions**:
1. Review network rule logs
2. Identify top rules by hit count
3. Optimize rule order
4. Consolidate IP address ranges
5. Use IP Groups for management
6. Consider service tags

### 8. Threat Intelligence Hits Alert

**Purpose**: Detect and respond to malicious traffic immediately  
**Metric**: `ThreatIntelHits`  
**Threshold**: > 0 (any detection, configurable)  
**Severity**: 1 (Error)  
**Frequency**: PT5M (Every 5 minutes)  
**Window**: PT15M (15 minutes)

**Description**: Threat intelligence hits indicate traffic from or to known malicious IP addresses, domains, or URLs based on Microsoft's threat intelligence feed. Any hit represents potential security threat requiring immediate investigation.

**Common Causes**:
- Malware infections
- Compromised systems
- Command and control traffic
- Phishing attempts
- Exploitation attempts

**Recommended Actions (IMMEDIATE)**:
1. Review threat intelligence logs for details
2. Identify source and destination
3. Isolate affected systems
4. Check for indicators of compromise
5. Investigate user activity
6. Run security scans
7. Review security policies
8. Consider incident response procedures
9. Update threat intelligence mode to "Alert and Deny"
10. Report to security operations team

**Threat Intelligence Modes**:
- **Alert Only**: Log traffic, allow to pass (use for baseline)
- **Alert and Deny**: Block malicious traffic (recommended for production)

## Cost Analysis

### Azure Firewall Pricing Components

Azure Firewall costs consist of:
1. **Deployment charges** (hourly fixed cost)
2. **Data processing charges** (per GB)

| Component | Standard SKU | Premium SKU |
|-----------|-------------|-------------|
| **Deployment** | $1.25/hour | $1.75/hour |
| **Data Processing** | $0.016/GB | $0.016/GB |

### Alert Costs

**Azure Monitor metric alerts are FREE** for the first signal per alert rule. Additional signals incur minimal costs:
- First signal per month: FREE
- Additional signals: $0.10 per signal per month

### Monthly Cost Examples

#### Small Deployment (1 Firewall, 100 GB/day)

**Firewall Costs:**
- Deployment: $1.25/hour × 730 hours = $912.50/month
- Data: 100 GB/day × 30 days × $0.016/GB = $48.00/month
- **Firewall Total: $960.50/month**

**Alert Costs:**
- 8 metric alerts × 1 firewall = 8 signals
- First signal FREE, 7 additional = $0.70/month
- **Alert Total: $0.70/month**

**Combined Monthly Cost: $961.20**

#### Medium Deployment (3 Firewalls, 500 GB/day)

**Firewall Costs:**
- Deployment: $1.25/hour × 730 hours × 3 = $2,737.50/month
- Data: 500 GB/day × 30 days × $0.016/GB = $240.00/month
- **Firewall Total: $2,977.50/month**

**Alert Costs:**
- 8 metric alerts × 3 firewalls = 24 signals
- First signal FREE, 23 additional = $2.30/month
- **Alert Total: $2.30/month**

**Combined Monthly Cost: $2,979.80**

#### Large Deployment (10 Premium Firewalls, 5 TB/day)

**Firewall Costs:**
- Deployment: $1.75/hour × 730 hours × 10 = $12,775.00/month
- Data: 5,000 GB/day × 30 days × $0.016/GB = $2,400.00/month
- **Firewall Total: $15,175.00/month**

**Alert Costs:**
- 8 metric alerts × 10 firewalls = 80 signals
- First signal FREE, 79 additional = $7.90/month
- **Alert Total: $7.90/month**

**Combined Monthly Cost: $15,182.90**

### Cost Optimization Strategies

1. **Right-Size Firewall SKU**: Use Standard for most workloads, Premium only when needed
2. **Optimize Data Processing**: Minimize unnecessary traffic through firewall
3. **Use Firewall Policies**: Centralize rules across multiple firewalls
4. **Implement NAT Gateway**: Reduce SNAT usage and potential need for additional IPs
5. **Alert Consolidation**: Consider using dynamic thresholds to reduce signal count
6. **Regional Deployment**: Place firewalls strategically to minimize cross-region data transfer

### ROI of Monitoring

**Prevented Incident Costs:**
- Security breach: $4.24M average (IBM Cost of Data Breach 2021)
- Downtime: $5,600/minute average (Gartner)
- SNAT exhaustion outage: Hundreds of affected services

**Monitoring Investment:**
- Alert costs: $1-10/month depending on scale
- **ROI: > 100,000% with single incident prevention**

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive monitoring and troubleshooting, enable diagnostic settings on your Azure Firewall resources. While metric alerts monitor performance thresholds, diagnostic settings provide detailed logs for security analysis and root cause investigation.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings via Azure CLI
az monitor diagnostic-settings create \
  --name "firewall-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/azureFirewalls/{firewall-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"AzureFirewallApplicationRule","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"AzureFirewallNetworkRule","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"AzureFirewallThreatIntelLog","enabled":true,"retentionPolicy":{"days":90,"enabled":true}},
    {"category":"AzureFirewallDnsProxy","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  for_each                   = toset(var.firewall_names)
  name                       = "firewall-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_firewall.firewalls[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Application Rule Logs - Layer 7 filtering
  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  # Network Rule Logs - Layer 3/4 filtering
  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  # Threat Intelligence Logs - Security events
  enabled_log {
    category = "AzureFirewallThreatIntelLog"
  }

  # DNS Proxy Logs - DNS queries
  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  # All Metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Category | Purpose | When to Enable |
|----------|---------|----------------|
| **AzureFirewallApplicationRule** | HTTP/HTTPS traffic with FQDN filtering, URL paths | **Always** - Essential for L7 analysis |
| **AzureFirewallNetworkRule** | Network traffic (IP, port, protocol) filtering | **Always** - Required for L3/L4 analysis |
| **AzureFirewallThreatIntelLog** | Microsoft threat intelligence hits and blocks | **Always** - Critical for security |
| **AzureFirewallDnsProxy** | DNS queries when DNS proxy is enabled | **If DNS Proxy enabled** - DNS analysis |

#### Useful Log Analytics Queries

```kusto
// Top blocked destinations by threat intelligence
AzureDiagnostics
| where Category == "AzureFirewallThreatIntelLog"
| where TimeGenerated > ago(24h)
| summarize BlockCount = count() by DestinationIp, ThreatDescription
| order by BlockCount desc
| take 20

// SNAT port utilization over time
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| where TimeGenerated > ago(1h)
| summarize ConnectionCount = count() by bin(TimeGenerated, 5m), SourceIp
| order by TimeGenerated desc

// Application rule denials
AzureDiagnostics
| where Category == "AzureFirewallApplicationRule"
| where TimeGenerated > ago(24h)
| where Action == "Deny"
| summarize DenyCount = count() by Fqdn, Protocol, SourceIp
| order by DenyCount desc

// Firewall health and throughput correlation
AzureDiagnostics
| where TimeGenerated > ago(1h)
| summarize 
    RequestCount = count(),
    AvgResponseTime = avg(ResponseTime)
  by bin(TimeGenerated, 5m), Resource
| order by TimeGenerated desc
```

### 2. Threshold Configuration Guidelines

#### Production Environments
```hcl
# Strict monitoring for production security
firewall_snat_port_utilization_threshold = 90    # Alert at 90%
firewall_throughput_threshold            = 800000000  # 800 Mbps for Standard
firewall_latency_threshold               = 50    # 50ms health probe
firewall_data_processed_threshold        = 1000000000000  # 1 TB daily

# Security - Zero tolerance
firewall_threat_intel_hits_threshold     = 1     # Alert on ANY threat
```

#### Development/Test Environments
```hcl
# Relaxed monitoring for non-production
firewall_snat_port_utilization_threshold = 95    # Higher threshold
firewall_throughput_threshold            = 900000000  # 900 Mbps
firewall_latency_threshold               = 100   # 100ms tolerance
firewall_data_processed_threshold        = 5000000000000  # 5 TB daily

# Security - Still monitor threats
firewall_threat_intel_hits_threshold     = 5     # Some tolerance for testing
```

### 3. Alert Response Procedures

#### Severity 0 (Critical) - Immediate Response
- **Firewall Health State** → Check firewall status, review diagnostics, prepare for failover

**Response Time**: < 5 minutes  
**Escalation**: Page on-call engineer + security team

#### Severity 1 (Error) - Immediate Response
- **SNAT Port Utilization** → Add public IPs, identify connection leaks
- **Threat Intelligence Hits** → Investigate source, block if malicious, review security posture

**Response Time**: < 15 minutes  
**Escalation**: Page on-call engineer

#### Severity 2 (Warning) - Review Within 1 Hour
- **Firewall Throughput** → Plan capacity increase, optimize traffic flow
- **Firewall Latency** → Check backend health, review routing

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Severity 3 (Informational) - Review During Business Hours
- **Data Processed** → Capacity planning and cost analysis
- **Rule Hit Counts** → Optimization and tuning opportunities

**Response Time**: Next business day  
**Escalation**: Log for review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on all Azure Firewalls
- [ ] Configure Log Analytics workspace retention (30-90 days recommended, 90+ for threat intel)
- [ ] Set up action groups with appropriate notification channels
- [ ] Customize alert thresholds based on baseline performance
- [ ] Test alert notifications to verify delivery
- [ ] Document escalation procedures
- [ ] Configure threat intelligence in Alert/Deny mode

#### Ongoing Operations
- [ ] Review alert thresholds quarterly
- [ ] Analyze false positive rates monthly
- [ ] Review diagnostic logs weekly for security patterns
- [ ] Update alert rules for new Azure Firewalls
- [ ] Validate action group membership monthly
- [ ] Conduct incident response drills quarterly
- [ ] Review threat intelligence hits weekly

#### Performance & Security Tuning
- [ ] Establish performance baselines (SNAT, throughput, latency)
- [ ] Set dynamic thresholds based on historical data
- [ ] Monitor alert fatigue and tune accordingly
- [ ] Correlate metrics with security events
- [ ] Review and optimize firewall rules monthly
- [ ] Analyze SNAT usage patterns and optimize

## Troubleshooting

### Common Issues and Solutions

#### 1. No Alert Data / Alerts Not Triggering

**Symptoms**: Alerts created but never fire, even during known issues

**Possible Causes**:
- Firewall diagnostic settings not configured
- Metrics not flowing to Azure Monitor
- Incorrect firewall names in configuration
- Resource group mismatch

**Troubleshooting Steps**:
```bash
# Verify firewall exists and is running
az network firewall show \
  --name "fw-hub-prod-001" \
  --resource-group "rg-network-production" \
  --query "{name:name,provisioningState:provisioningState,threatIntelMode:threatIntelMode}"

# Check if diagnostic settings are configured
az monitor diagnostic-settings list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/azureFirewalls/{fw-name}" \
  --query "value[].{name:name,logs:logs[].category,metrics:metrics[].category}"

# Verify metrics availability (last 24 hours)
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/azureFirewalls/{fw-name}" \
  --metric-names "FirewallHealth" \
  --start-time $(date -u -v-24H '+%Y-%m-%dT%H:%M:%SZ') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ')
```

**Resolution**:
```bash
# Enable diagnostic settings for detailed logging
az monitor diagnostic-settings create \
  --name "firewall-diagnostics" \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/azureFirewalls/{fw-name}" \
  --workspace "/subscriptions/{sub-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[{"category":"AzureFirewallApplicationRule","enabled":true},{"category":"AzureFirewallNetworkRule","enabled":true},{"category":"AzureFirewallThreatIntelLog","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
```

Additional steps:
1. Verify firewall names match exactly (case-sensitive)
2. Ensure metrics diagnostic setting uses "Azure Diagnostics" (not "Resource Specific")
3. Wait 5-10 minutes for metrics to populate
4. Check that the firewall is not in a stopped or failed state

#### 2. SNAT Port Utilization Always 100%

**Symptoms**: SNAT utilization constantly at 100%, causing connection failures

**Possible Causes**:
- Insufficient public IP addresses
- Applications not closing connections
- Very high concurrent connection count
- Long-lived connections

**Troubleshooting Steps**:
```bash
# Check current public IPs
az network firewall show \
  --name "fw-hub-prod-001" \
  --resource-group "rg-network-production" \
  --query "ipConfigurations[].publicIpAddress.id"

# View SNAT port utilization over time
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/azureFirewalls/{fw-name}" \
  --metric-names "SNATPortUtilization" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z
```

**Resolution**:
1. Add additional public IP addresses (up to 250)
2. Integrate Azure NAT Gateway for additional capacity
3. Review application connection handling
4. Implement connection pooling in applications
5. Reduce TCP idle timeout if appropriate
6. Consider scaling to multiple firewall instances

#### 3. High Latency Alerts

**Symptoms**: Frequent latency alerts, slow application performance

**Possible Causes**:
- High throughput utilization
- Inefficient rule processing
- TLS inspection overhead
- Complex IDPS rules

**Troubleshooting Steps**:
```bash
# Check latency correlation with throughput
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/azureFirewalls/{fw-name}" \
  --metric-names "AzureFirewallLatencyProbeMsLatency,Throughput" \
  --start-time 2024-01-01T00:00:00Z

# Review rule hit counts
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/azureFirewalls/{fw-name}" \
  --metric-names "ApplicationRuleHit,NetworkRuleHit"
```

**Resolution**:
1. Optimize firewall rules (most-hit rules first)
2. Consolidate similar rules
3. Review TLS inspection requirements
4. Optimize IDPS signature rules
5. Check if Premium features are needed
6. Consider scaling or load distribution

#### 4. Threat Intelligence False Positives

**Symptoms**: Legitimate traffic being flagged as malicious

**Possible Causes**:
- Shared IP addresses (cloud services)
- CDN or proxy IPs in threat feeds
- Outdated threat intelligence
- Testing/scanning tools

**Troubleshooting Steps**:
```bash
# Review threat intelligence logs
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureDiagnostics 
  | where ResourceType == 'AZUREFIREWALLS' 
  | where msg_s contains 'Threat Intelligence'
  | project TimeGenerated, msg_s, SourceIP=split(msg_s, ' ')[5]
  | summarize count() by SourceIP" \
  --timespan "PT24H"
```

**Resolution**:
1. Review specific IPs/domains flagged
2. Verify if traffic is actually legitimate
3. Create allowlist rules for known-good sources
4. Consider "Alert Only" mode for initial deployment
5. Report false positives to Microsoft
6. Document exceptions for compliance

#### 5. Terraform Deployment Failures

**Common Errors**:
```bash
# Error: Firewall not found
Error: "fw-hub-prod-001" was not found

# Error: Invalid metric name
Error: Metric "FirewallHealthState" is not valid

# Error: Action group not found
Error: Action Group "operations-actiongroup" not found
```

**Resolution**:
```hcl
# Verify firewall exists before creating alerts
data "azurerm_firewall" "firewalls" {
  for_each            = toset(var.firewall_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Correct metric namespace
metric_namespace = "Microsoft.Network/azureFirewalls"  # Not "AzureFirewall"

# Verify action group exists
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}
```

---

**Module Version**: 1.0.0  
**Last Updated**: December 2024  
**Maintained By**: PGE Platform Engineering

For questions or issues, contact the Platform Engineering team or open an issue in the repository.
