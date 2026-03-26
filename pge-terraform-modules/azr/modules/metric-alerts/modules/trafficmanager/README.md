# Azure Traffic Manager - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure Traffic Manager**, providing proactive monitoring for global DNS load balancing, endpoint health, failover scenarios, and administrative operations. The module monitors critical traffic routing metrics to ensure optimal application availability, performance, and geographic distribution.

Azure Traffic Manager is a DNS-based traffic load balancer that enables you to distribute traffic optimally to services across global Azure regions, while providing high availability and responsiveness. This module focuses on endpoint health monitoring, DNS resolution reliability, probe agent status, and administrative oversight for mission-critical traffic routing scenarios.

## Features

- **Endpoint Health Monitoring**: Real-time tracking of endpoint availability and health status
- **Probe Agent Monitoring**: Continuous monitoring of Traffic Manager probe agent endpoint state
- **Administrative Security**: Creation, deletion, and configuration change alerts for audit compliance
- **DNS Resolution Monitoring**: Advanced query-based monitoring for DNS resolution failures
- **Endpoint Operations Tracking**: Comprehensive monitoring of endpoint management operations
- **Multi-Profile Support**: Individual monitoring for multiple Traffic Manager profiles in a single deployment
- **Real-Time Alerting**: 1-5 minute evaluation frequency for rapid failover detection
- **Cost-Effective Monitoring**: Optimized alert configuration at $0.70 per Traffic Manager profile per month
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **High Availability**: Endpoint health monitoring for automated failover scenarios
- **Performance Optimization**: Probe agent monitoring for optimal traffic routing decisions
- **Security Oversight**: Administrative operation monitoring and change management
- **DNS Reliability**: Query-based monitoring for DNS resolution and routing failures
- **Geographic Distribution**: Multi-region endpoint monitoring for global applications

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/scheduledQueryRules/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Network/trafficManagerProfiles/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Traffic Manager Profiles**: Existing Azure Traffic Manager profiles to monitor
- **Log Analytics Workspace**: For scheduled query rules (DNS and health monitoring)
- **Recommended**: Diagnostic settings enabled on Traffic Manager profiles

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs provides essential troubleshooting capabilities for DNS query analysis, endpoint health history, and routing decisions.

## Usage

### Basic Configuration

```hcl
module "traffic_manager_alerts" {
  source = "./modules/metricAlerts/trafficmanager"
  
  # Resource Configuration
  resource_group_name               = "rg-production-networking"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # Traffic Manager Profiles to Monitor
  traffic_manager_profile_names = [
    "tm-production-web",
    "tm-production-api",
    "tm-disaster-recovery"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "LoadBalancing"
    Owner             = "network-team@pge.com"
    CostCenter        = "IT-Networking"
    Compliance        = "SOX"
    DataClassification = "Public"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "traffic_manager_alerts_critical" {
  source = "./modules/metricAlerts/trafficmanager"
  
  # Resource Configuration
  resource_group_name               = "rg-production-networking"
  action_group_resource_group_name  = "rg-monitoring"
  traffic_manager_profile_names    = ["tm-mission-critical-app"]
  
  # Critical Application Thresholds
  endpoint_health_threshold        = 2    # Require at least 2 healthy endpoints
  
  # High-Frequency Monitoring for Critical Systems
  evaluation_frequency_high        = "PT1M"   # 1-minute evaluation
  evaluation_frequency_medium      = "PT2M"   # 2-minute evaluation
  window_duration_short           = "PT5M"    # 5-minute window
  
  # Comprehensive Alert Coverage
  enable_traffic_manager_creation_alert    = true
  enable_traffic_manager_deletion_alert    = true
  enable_traffic_manager_config_change_alert = true
  enable_endpoint_operations_alert        = true
  enable_endpoint_health_alert           = true
  enable_probe_agent_monitoring_alert    = true
  enable_dns_resolution_failure_alert    = true
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    SLA         = "99.99%"
    Owner       = "infrastructure-team@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Traffic Manager - Relaxed Thresholds
endpoint_health_threshold                 = 1     # Single endpoint acceptable
evaluation_frequency_high                = "PT5M" # 5-minute evaluation
evaluation_frequency_medium              = "PT15M" # 15-minute evaluation
window_duration_short                   = "PT15M" # 15-minute window
enable_dns_resolution_failure_alert     = false   # Disable for dev
enable_traffic_manager_creation_alert   = false   # Disable for dev
```

#### Staging Environment
```hcl
# Staging Traffic Manager - Moderate Thresholds
endpoint_health_threshold                 = 1     # Single endpoint acceptable
evaluation_frequency_high                = "PT2M" # 2-minute evaluation
evaluation_frequency_medium              = "PT5M" # 5-minute evaluation
window_duration_short                   = "PT10M" # 10-minute window
enable_dns_resolution_failure_alert     = true    # Enable for testing
enable_traffic_manager_creation_alert   = true    # Enable for testing
```

#### Production Environment
```hcl
# Production Traffic Manager - Strict Thresholds
endpoint_health_threshold                 = 1     # At least 1 healthy endpoint
evaluation_frequency_high                = "PT1M" # 1-minute evaluation
evaluation_frequency_medium              = "PT5M" # 5-minute evaluation
window_duration_short                   = "PT5M"  # 5-minute window
enable_dns_resolution_failure_alert     = true    # Full monitoring
enable_traffic_manager_creation_alert   = true    # Full audit trail
```

### Traffic Manager Routing-Specific Configurations

#### Performance Routing
```hcl
# Performance-Based Routing - Latency-Sensitive
endpoint_health_threshold                 = 2     # Multiple endpoints for performance
evaluation_frequency_high                = "PT1M" # Rapid detection
window_duration_short                   = "PT5M"  # Quick response
enable_probe_agent_monitoring_alert     = true    # Critical for performance routing
```

#### Priority Routing (Failover)
```hcl
# Priority-Based Routing - High Availability Focus
endpoint_health_threshold                 = 1     # Single primary endpoint
evaluation_frequency_high                = "PT30S" # 30-second evaluation
window_duration_short                   = "PT2M"   # Rapid failover detection
enable_endpoint_health_alert           = true     # Critical for failover
```

#### Geographic Routing
```hcl
# Geographic Routing - Regional Distribution
endpoint_health_threshold                 = 1     # Regional endpoint availability
evaluation_frequency_medium              = "PT2M" # Regional monitoring
window_duration_medium                  = "PT10M" # Regional tolerance
enable_dns_resolution_failure_alert     = true    # DNS critical for geographic routing
```

### Use Case-Specific Configurations

#### Web Application Load Balancing
```hcl
# Web Application - User Experience Focus
endpoint_health_threshold                 = 1
evaluation_frequency_high                = "PT1M"
window_duration_short                   = "PT5M"
enable_endpoint_health_alert           = true
enable_dns_resolution_failure_alert    = true
```

#### API Gateway Distribution
```hcl
# API Gateway - Service Availability Focus
endpoint_health_threshold                 = 2     # Multiple API endpoints
evaluation_frequency_high                = "PT1M"
window_duration_short                   = "PT3M"
enable_probe_agent_monitoring_alert     = true
enable_endpoint_operations_alert        = true
```

#### Disaster Recovery Scenarios
```hcl
# Disaster Recovery - Business Continuity Focus
endpoint_health_threshold                 = 1     # Primary/secondary setup
evaluation_frequency_high                = "PT30S" # Rapid DR detection
window_duration_short                   = "PT2M"
enable_traffic_manager_config_change_alert = true # Change management critical
enable_endpoint_health_alert            = true
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for Traffic Manager profiles |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `traffic_manager_profile_names` | `list(string)` | `[]` | List of Traffic Manager profile names to monitor |
| `subscription_ids` | `list(string)` | `[]` | Subscription IDs for activity log alerts (auto-detected if empty) |

### Alert Threshold Variables

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `endpoint_health_threshold` | `number` | `1` | Minimum healthy endpoints for service availability | 1-5 endpoints |
| `probe_agent_current_endpoint_state_by_profile_resource_id_threshold` | `number` | `1` | Probe agent endpoint state threshold | 1-3 |

### Alert Enable/Disable Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_traffic_manager_creation_alert` | `bool` | `true` | Enable profile creation monitoring |
| `enable_traffic_manager_deletion_alert` | `bool` | `true` | Enable profile deletion monitoring |
| `enable_traffic_manager_config_change_alert` | `bool` | `true` | Enable configuration change monitoring |
| `enable_endpoint_operations_alert` | `bool` | `true` | Enable endpoint operations monitoring |
| `enable_endpoint_health_alert` | `bool` | `true` | Enable endpoint health monitoring |
| `enable_probe_agent_monitoring_alert` | `bool` | `true` | Enable probe agent monitoring |
| `enable_dns_resolution_failure_alert` | `bool` | `true` | Enable DNS resolution failure monitoring |

### Timing Configuration Variables

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `evaluation_frequency_high` | `string` | `"PT1M"` | High-frequency evaluation interval | PT30S - PT5M |
| `evaluation_frequency_medium` | `string` | `"PT5M"` | Medium-frequency evaluation interval | PT2M - PT15M |
| `evaluation_frequency_low` | `string` | `"PT15M"` | Low-frequency evaluation interval | PT5M - PT1H |
| `window_duration_short` | `string` | `"PT5M"` | Short evaluation window | PT2M - PT15M |
| `window_duration_medium` | `string` | `"PT15M"` | Medium evaluation window | PT5M - PT1H |
| `window_duration_long` | `string` | `"PT1H"` | Long evaluation window | PT15M - PT6H |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "network-team@pge.com"       # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "traffic-oncall@pge.com"     # Notification contact
  DataClassification = "Public"                     # Data sensitivity
  CostCenter         = "IT-Networking"              # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  RoutingMethod      = "Performance"                # Traffic routing method
}
```

## Alert Details

### 1. Endpoint Health Alert
- **Alert Name**: `TrafficManager-endpoint-health-{profile-name}`
- **Metric**: `ProbeAgentCurrentEndpointStateByProfileResourceId`
- **Threshold**: < 1 healthy endpoint (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Maximum

**What this alert monitors**: Number of healthy endpoints available for traffic routing, ensuring service availability and automatic failover capability.

**What to do when this alert fires**:
1. **Immediate Assessment**: Check endpoint health status in Azure portal Traffic Manager overview
2. **Endpoint Connectivity**: Verify connectivity and health of all configured endpoints
3. **Health Check Configuration**: Review health check paths and probe settings for accuracy
4. **Service Status**: Check the health status of backend services (App Service, VM, etc.)
5. **Failover Verification**: Ensure remaining healthy endpoints can handle traffic load

### 2. Probe Agent Endpoint State Alert
- **Alert Name**: `TrafficManager-probe-agent-state-{profile-name}`
- **Metric**: `ProbeAgentCurrentEndpointStateByProfileResourceId`
- **Threshold**: < 1 (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Traffic Manager probe agent status and endpoint state detection, critical for traffic routing decisions.

**What to do when this alert fires**:
1. **Probe Agent Status**: Verify Traffic Manager probe agents are functioning correctly
2. **Endpoint Probe Configuration**: Check probe protocol, port, and path configuration
3. **Network Connectivity**: Verify network connectivity between probe agents and endpoints
4. **Endpoint Response**: Test endpoint response to health check requests manually
5. **DNS Resolution**: Ensure endpoint DNS names resolve correctly from probe locations

### 3. Traffic Manager Profile Creation Alert
- **Alert Name**: `TrafficManager-Creation-Alert-{profile-names}`
- **Operation**: `Microsoft.Network/trafficManagerProfiles/write`
- **Severity**: Informational (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Creation of new Traffic Manager profiles for audit trail and security oversight.

**What to do when this alert fires**:
1. **Authorization Verification**: Confirm profile creation was authorized and follows change management
2. **Configuration Review**: Review new profile configuration for compliance with standards
3. **Documentation Update**: Update network architecture documentation and diagrams
4. **Access Control**: Verify appropriate RBAC permissions are configured for the new profile
5. **Testing Plan**: Implement testing plan for new Traffic Manager profile functionality

### 4. Traffic Manager Profile Deletion Alert
- **Alert Name**: `TrafficManager-Deletion-Alert-{profile-names}`
- **Operation**: `Microsoft.Network/trafficManagerProfiles/delete`
- **Severity**: Warning (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Deletion of Traffic Manager profiles, critical for preventing accidental service disruption.

**What to do when this alert fires**:
1. **Immediate Verification**: Confirm deletion was authorized and intentional
2. **Impact Assessment**: Evaluate impact on applications and services using the profile
3. **Service Continuity**: Verify alternative traffic routing mechanisms are in place
4. **Recovery Planning**: Initiate profile restoration if deletion was unauthorized
5. **Incident Documentation**: Document incident and review access control procedures

### 5. Traffic Manager Configuration Change Alert
- **Alert Name**: `TrafficManager-ConfigChange-Alert-{profile-names}`
- **Operation**: `Microsoft.Network/trafficManagerProfiles/write`
- **Severity**: Warning (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Configuration changes to Traffic Manager profiles including routing method, endpoint modifications, and settings updates.

**What to do when this alert fires**:
1. **Change Validation**: Review and validate the configuration changes made
2. **Impact Analysis**: Assess potential impact on traffic routing and application performance
3. **Change Documentation**: Ensure changes are properly documented and approved
4. **Testing Verification**: Verify changes work as expected and don't cause service disruption
5. **Rollback Planning**: Prepare rollback procedures if changes cause issues

### 6. Endpoint Operations Alert
- **Alert Name**: `TrafficManager-EndpointOps-Alert-{profile-names}`
- **Operation**: `Microsoft.Network/trafficManagerProfiles/write`
- **Severity**: Informational (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Endpoint management operations including addition, removal, and modification of Traffic Manager endpoints.

**What to do when this alert fires**:
1. **Endpoint Change Review**: Review endpoint additions, removals, or modifications
2. **Load Distribution**: Verify load distribution across endpoints remains appropriate
3. **Health Check Updates**: Ensure health check configurations are updated for new endpoints
4. **Performance Testing**: Test performance and availability after endpoint changes
5. **Monitoring Updates**: Update monitoring and alerting for new endpoint configurations

### 7. DNS Resolution Failure Alert
- **Alert Name**: `TrafficManager-DNSFailure-Alert-{profile-names}`
- **Query Type**: Scheduled Query Rule
- **Threshold**: ≥ 1 failure (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)

**What this alert monitors**: DNS resolution failures for Traffic Manager profiles that could prevent client access to applications.

**What to do when this alert fires**:
1. **DNS Resolution Testing**: Test DNS resolution from multiple locations and clients
2. **Traffic Manager Status**: Verify Traffic Manager profile status and configuration
3. **DNS Propagation**: Check DNS propagation across global DNS infrastructure
4. **Endpoint Availability**: Verify at least one endpoint is healthy and available
5. **Client Impact Assessment**: Evaluate impact on client applications and user experience

### 8. Endpoint Health Degradation Alert
- **Alert Name**: `TrafficManager-EndpointHealth-Alert-{profile-names}`
- **Query Type**: Scheduled Query Rule
- **Threshold**: ≥ 1 degradation event (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)

**What this alert monitors**: Endpoint health degradation events that may indicate service issues or impending failures.

**What to do when this alert fires**:
1. **Endpoint Health Analysis**: Analyze endpoint health trends and patterns
2. **Performance Metrics**: Review endpoint performance metrics and response times
3. **Capacity Assessment**: Check if endpoints are approaching capacity limits
4. **Infrastructure Health**: Verify underlying infrastructure health (VMs, App Services, etc.)
5. **Scaling Decisions**: Consider scaling endpoints or adding additional capacity

## Severity Levels

### Severity 1 (Critical) - Service Impact
- **Endpoint Health**: No healthy endpoints available, causing service outage
- **DNS Resolution Failures**: DNS resolution issues preventing client access

**Response Time**: 2 minutes
**Escalation**: Immediate notification to network team, on-call engineer, and incident commander

### Severity 2 (High) - Performance Impact
- **Probe Agent State**: Probe agent issues affecting traffic routing decisions
- **Endpoint Health Degradation**: Endpoint health declining, potential service impact

**Response Time**: 5 minutes
**Escalation**: Notification to network operations team and application owners

### Informational/Warning - Administrative Events
- **Profile Creation**: New Traffic Manager profiles created
- **Profile Deletion**: Traffic Manager profiles deleted
- **Configuration Changes**: Profile settings modified
- **Endpoint Operations**: Endpoint management activities

**Response Time**: 15 minutes
**Escalation**: Standard operational notification and audit trail

## Cost Analysis

### Alert Costs (Monthly)
- **2 Metric Alerts + 4 Activity Log Alerts + 2 Scheduled Query Rules per Profile**: 
  - 2 × $0.10 (Metric Alerts) + 4 × FREE (Activity Log) + 2 × $0.10 (Query Rules) = **$0.40 per Traffic Manager Profile**
- **Multi-Profile Deployment**: Scales with profile count
- **Action Group**: FREE (included)
- **Activity Log Alerts**: FREE (included)

### Cost Examples by Environment

#### Small Global Application (2 Profiles)
- **Monthly Alert Cost**: $0.80
- **Annual Alert Cost**: $9.60

#### Medium Multi-Region Platform (5 Profiles)
- **Monthly Alert Cost**: $2.00
- **Annual Alert Cost**: $24.00

#### Large Enterprise Global Platform (20 Profiles)
- **Monthly Alert Cost**: $8.00
- **Annual Alert Cost**: $96.00

#### Enterprise Multi-Application Platform (100 Profiles)
- **Monthly Alert Cost**: $40.00
- **Annual Alert Cost**: $480.00

### Return on Investment (ROI)

#### Cost of Traffic Manager Issues
- **Global Service Outage**: $500,000-5,000,000/hour for global e-commerce platforms
- **DNS Resolution Failures**: Complete application unavailability across all regions
- **Failover Delays**: 5-30 minutes additional downtime without proactive monitoring
- **Geographic Service Impact**: Regional outages affecting specific user bases
- **Performance Degradation**: 50-500% increase in response times during endpoint issues

#### Alert Value Calculation
- **Monthly Alert Cost**: $0.40 per Traffic Manager Profile
- **Prevented Downtime**: 1 hour/month average per profile
- **Cost Avoidance**: $2,500,000/month for critical global applications
- **ROI**: 624,999,900% (($2,500,000 - $0.40) / $0.40 × 100)

#### Additional Benefits
- **Proactive Failover**: Automated detection and response to endpoint failures
- **Global Availability**: Ensure high availability across multiple Azure regions
- **Performance Optimization**: Maintain optimal traffic routing for user experience
- **Compliance Assurance**: Audit trail for all Traffic Manager administrative operations
- **Cost Optimization**: Prevent revenue loss from global service disruptions

### Traffic Manager Pricing Context
- **Traffic Manager Profile**: $0.54 per month per profile
- **DNS Queries**: $0.40 per million queries per month
- **Health Checks**: $0.36 per endpoint per month

**Alert Cost Impact**: 74% of base Traffic Manager profile cost, significant value for global availability

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive monitoring and troubleshooting, enable diagnostic settings on your Traffic Manager profiles. While metric alerts monitor endpoint health and probe status, diagnostic settings provide detailed logs for DNS query analysis and routing decisions.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings for Traffic Manager via Azure CLI
az monitor diagnostic-settings create \
  --name "trafficmanager-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/trafficManagerProfiles/{profile-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"ProbeHealthStatusEvents","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "trafficmanager_diagnostics" {
  for_each                   = toset(var.traffic_manager_profile_names)
  name                       = "tm-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_traffic_manager_profile.profiles[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Probe Health Status Events - Endpoint health changes
  enabled_log {
    category = "ProbeHealthStatusEvents"
  }

  # All Metrics including endpoint health and DNS queries
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Category | Purpose | When to Enable |
|----------|---------|----------------|
| **ProbeHealthStatusEvents** | Endpoint health status changes, probe results, failover events | **Always** - Critical for troubleshooting |

#### Useful Log Analytics Queries

```kusto
// Endpoint health status changes
AzureDiagnostics
| where ResourceType == "TRAFFICMANAGERPROFILES"
| where Category == "ProbeHealthStatusEvents"
| where TimeGenerated > ago(24h)
| project TimeGenerated, Resource, EndpointName_s, EndpointStatus_s, LatencyInMilliseconds_d
| order by TimeGenerated desc

// Endpoint failure frequency
AzureDiagnostics
| where ResourceType == "TRAFFICMANAGERPROFILES"
| where Category == "ProbeHealthStatusEvents"
| where TimeGenerated > ago(7d)
| where EndpointStatus_s == "Degraded" or EndpointStatus_s == "Inactive"
| summarize FailureCount = count() by EndpointName_s, bin(TimeGenerated, 1h)
| order by FailureCount desc

// Endpoint latency trends
AzureDiagnostics
| where ResourceType == "TRAFFICMANAGERPROFILES"
| where Category == "ProbeHealthStatusEvents"
| where TimeGenerated > ago(24h)
| summarize 
    AvgLatency = avg(LatencyInMilliseconds_d),
    MaxLatency = max(LatencyInMilliseconds_d)
  by EndpointName_s, bin(TimeGenerated, 15m)
| render timechart

// DNS query volume by profile
AzureMetrics
| where ResourceType == "TRAFFICMANAGERPROFILES"
| where MetricName == "QpsByEndpoint"
| where TimeGenerated > ago(24h)
| summarize QueryCount = sum(Total) by Resource, bin(TimeGenerated, 1h)
| render timechart
```

### 2. Deployment Best Practices

#### Environment-Specific Configuration
```hcl
# Production Environment - Critical monitoring
endpoint_health_threshold         = 1
evaluation_frequency_high        = "PT1M"
evaluation_frequency_medium      = "PT5M"
window_duration_short           = "PT5M"
enable_dns_resolution_failure_alert = true
enable_endpoint_health_alert    = true

# Staging Environment - Moderate monitoring  
endpoint_health_threshold         = 1
evaluation_frequency_high        = "PT2M"
evaluation_frequency_medium      = "PT5M"
window_duration_short           = "PT10M"
enable_dns_resolution_failure_alert = true
enable_endpoint_health_alert    = true

# Development Environment - Basic monitoring
endpoint_health_threshold         = 1
evaluation_frequency_high        = "PT5M"
evaluation_frequency_medium      = "PT15M"
window_duration_short           = "PT15M"
enable_dns_resolution_failure_alert = false
enable_endpoint_health_alert    = true
```

#### Routing Method-Appropriate Monitoring
- **Performance Routing**: Focus on probe agent monitoring and endpoint health (latency-sensitive)
- **Priority Routing**: Emphasis on rapid failover detection and endpoint health (high availability)
- **Geographic Routing**: DNS resolution monitoring critical for regional distribution
- **Weighted Routing**: Load distribution and endpoint performance monitoring

#### Multi-Region Considerations
- Enable comprehensive monitoring for global applications
- Configure probe agents in multiple regions
- Monitor DNS resolution from various geographic locations
- Implement region-specific endpoint health thresholds

### 3. Alert Response Procedures

#### Severity 1 (Critical) - Immediate Response
- **Endpoint Health Degraded** → Verify endpoint status, check backend health, investigate probe failures
- **DNS Resolution Failure** → Check DNS configuration, verify routing method, test name resolution

**Response Time**: < 5 minutes  
**Escalation**: Page on-call engineer + network team

**Immediate Actions**:
1. Verify endpoint health status in Azure Portal
2. Test endpoint directly (bypass Traffic Manager)
3. Review probe configuration (interval, timeout, tolerated failures)
4. Check backend application logs
5. Verify network connectivity and NSG rules
6. Consider manual failover if needed

#### Severity 2 (Warning) - Review Within 1 Hour
- **Probe Agent Status Changes** → Monitor for recurring issues, investigate root cause

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Activity Log Alerts (Informational) - Review During Business Hours
- **Profile Creation/Deletion** → Audit trail review
- **Endpoint Operations** → Change management verification

**Response Time**: Next business day  
**Escalation**: Log for review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on all Traffic Manager profiles
- [ ] Configure Log Analytics workspace retention (30+ days recommended)
- [ ] Set up action groups with network and ops teams
- [ ] Customize alert thresholds based on routing method
- [ ] Test alert notifications to verify delivery
- [ ] Document failover procedures
- [ ] Configure health probes with optimal settings (interval, timeout)

#### Ongoing Operations
- [ ] Review endpoint health status daily
- [ ] Analyze probe failure patterns weekly
- [ ] Review alert thresholds quarterly
- [ ] Update alert rules for new Traffic Manager profiles
- [ ] Validate action group membership monthly
- [ ] Test failover scenarios monthly
- [ ] Review DNS query patterns for optimization

#### Performance & Reliability
- [ ] Establish endpoint health baselines
- [ ] Optimize probe configurations (interval, path, protocol)
- [ ] Monitor DNS TTL impact on failover time
- [ ] Review endpoint latency trends
- [ ] Analyze geographic distribution effectiveness
- [ ] Document common failure scenarios and resolutions

### Traffic Manager Configuration Best Practices (Continued)
```bash
# Configure Traffic Manager profile with optimal settings
az network traffic-manager profile create \
  --resource-group "rg-production-networking" \
  --name "tm-production-web" \
  --routing-method "Performance" \
  --unique-dns-name "production-web-tm" \
  --ttl 30 \
  --protocol "HTTPS" \
  --port 443 \
  --path "/health" \
  --interval 10 \
  --timeout 5 \
  --tolerated-failures 2
```

#### 2. Endpoint Configuration
```bash
# Add endpoints with health check configuration
az network traffic-manager endpoint create \
  --resource-group "rg-production-networking" \
  --profile-name "tm-production-web" \
  --name "endpoint-eastus" \
  --type "azureEndpoints" \
  --target-resource-id "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app}" \
  --endpoint-status "Enabled" \
  --weight 100 \
  --priority 1 \
  --custom-headers "Host:production.contoso.com"

# Configure geographic endpoint
az network traffic-manager endpoint create \
  --resource-group "rg-production-networking" \
  --profile-name "tm-production-web" \
  --name "endpoint-europe" \
  --type "azureEndpoints" \
  --target-resource-id "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app-eu}" \
  --geo-mapping "Europe"
```

#### 3. Health Check Optimization
```bash
# Configure custom health check probe
az network traffic-manager profile update \
  --resource-group "rg-production-networking" \
  --name "tm-production-web" \
  --protocol "HTTPS" \
  --port 443 \
  --path "/api/health/detailed" \
  --interval 10 \
  --timeout 5 \
  --tolerated-failures 2 \
  --expected-status-code-ranges "200-399"
```

### Monitoring and Diagnostics Best Practices

#### 1. Custom Monitoring Scripts
```powershell
# PowerShell script for Traffic Manager health monitoring
function Get-TrafficManagerHealth {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$ProfileName
    )
    
    Write-Host "Traffic Manager Health Check: $ProfileName" -ForegroundColor Green
    Write-Host "=========================================="
    
    # Get Traffic Manager profile
    $Profile = Get-AzTrafficManagerProfile -ResourceGroupName $ResourceGroupName -Name $ProfileName
    Write-Host "Profile Status: $($Profile.ProfileStatus)" -ForegroundColor Yellow
    Write-Host "Routing Method: $($Profile.TrafficRoutingMethod)" -ForegroundColor Yellow
    Write-Host "DNS Name: $($Profile.RelativeDnsName).trafficmanager.net" -ForegroundColor Yellow
    
    # Get endpoints
    $Endpoints = Get-AzTrafficManagerEndpoint -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName
    Write-Host "`nEndpoint Health Status:" -ForegroundColor Green
    
    foreach ($Endpoint in $Endpoints) {
        $HealthStatus = if ($Endpoint.EndpointStatus -eq "Enabled") { "Enabled" } else { "Disabled" }
        $EndpointMonitorStatus = $Endpoint.EndpointMonitorStatus
        
        Write-Host "  $($Endpoint.Name):" -ForegroundColor Cyan
        Write-Host "    Status: $HealthStatus" -ForegroundColor Yellow
        Write-Host "    Monitor Status: $EndpointMonitorStatus" -ForegroundColor Yellow
        Write-Host "    Target: $($Endpoint.Target)" -ForegroundColor Yellow
        
        if ($EndpointMonitorStatus -ne "Online") {
            Write-Host "    WARNING: Endpoint is not online!" -ForegroundColor Red
        }
    }
    
    # DNS resolution test
    $DnsName = "$($Profile.RelativeDnsName).trafficmanager.net"
    Write-Host "`nDNS Resolution Test:" -ForegroundColor Green
    try {
        $DnsResult = Resolve-DnsName -Name $DnsName -ErrorAction Stop
        Write-Host "  DNS Resolution: SUCCESS" -ForegroundColor Green
        Write-Host "  Resolved to: $($DnsResult.IPAddress -join ', ')" -ForegroundColor Yellow
    }
    catch {
        Write-Host "  DNS Resolution: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Usage
Get-TrafficManagerHealth -ResourceGroupName "rg-production-networking" -ProfileName "tm-production-web"
```

#### 2. Automated Health Check Script
```bash
#!/bin/bash
# Traffic Manager comprehensive health check

RESOURCE_GROUP="rg-production-networking"
PROFILE_NAME="tm-production-web"

echo "Traffic Manager Health Check: $PROFILE_NAME"
echo "============================================="

# Check profile status
echo "1. Profile Status Check"
PROFILE_STATUS=$(az network traffic-manager profile show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PROFILE_NAME" \
  --query "profileStatus" -o tsv)
echo "   Profile Status: $PROFILE_STATUS"

# Check routing method
ROUTING_METHOD=$(az network traffic-manager profile show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PROFILE_NAME" \
  --query "trafficRoutingMethod" -o tsv)
echo "   Routing Method: $ROUTING_METHOD"

# Check endpoints
echo "2. Endpoint Health Check"
ENDPOINTS=$(az network traffic-manager endpoint list \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$PROFILE_NAME" \
  --query "[].{Name:name,Status:endpointStatus,MonitorStatus:endpointMonitorStatus,Target:target}" -o table)
echo "$ENDPOINTS"

# DNS resolution test
echo "3. DNS Resolution Test"
DNS_NAME=$(az network traffic-manager profile show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PROFILE_NAME" \
  --query "dnsConfig.relativeName" -o tsv)

FQDN="${DNS_NAME}.trafficmanager.net"
echo "   Testing DNS resolution for: $FQDN"

if nslookup "$FQDN" > /dev/null 2>&1; then
    echo "   DNS Resolution: SUCCESS"
    RESOLVED_IP=$(nslookup "$FQDN" | grep "Address" | tail -1 | awk '{print $2}')
    echo "   Resolved to: $RESOLVED_IP"
else
    echo "   DNS Resolution: FAILED"
fi

# Health check probe test
echo "4. Health Check Probe Test"
PROBE_PROTOCOL=$(az network traffic-manager profile show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PROFILE_NAME" \
  --query "monitorConfig.protocol" -o tsv)
PROBE_PORT=$(az network traffic-manager profile show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PROFILE_NAME" \
  --query "monitorConfig.port" -o tsv)
PROBE_PATH=$(az network traffic-manager profile show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PROFILE_NAME" \
  --query "monitorConfig.path" -o tsv)

echo "   Probe Configuration: $PROBE_PROTOCOL:$PROBE_PORT$PROBE_PATH"

# Health assessment
echo "5. Health Assessment"
if [ "$PROFILE_STATUS" != "Enabled" ]; then
    echo "   CRITICAL: Traffic Manager profile is not enabled"
    exit 2
fi

# Count healthy endpoints
HEALTHY_ENDPOINTS=$(az network traffic-manager endpoint list \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$PROFILE_NAME" \
  --query "[?endpointMonitorStatus=='Online'] | length(@)")

echo "   Healthy Endpoints: $HEALTHY_ENDPOINTS"

if [ "$HEALTHY_ENDPOINTS" -eq 0 ]; then
    echo "   CRITICAL: No healthy endpoints available"
    exit 2
elif [ "$HEALTHY_ENDPOINTS" -eq 1 ]; then
    echo "   WARNING: Only one healthy endpoint available"
fi

echo "   Health check completed successfully"
```

### Security and Compliance Best Practices

#### 1. Access Control Configuration
```bash
# Configure RBAC for Traffic Manager
az role assignment create \
  --role "Traffic Manager Contributor" \
  --assignee "network-team@pge.com" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/{resource-group}"

# Create custom role for Traffic Manager monitoring
az role definition create --role-definition '{
  "Name": "Traffic Manager Monitor",
  "Description": "Can monitor Traffic Manager profiles and endpoints",
  "Actions": [
    "Microsoft.Network/trafficManagerProfiles/read",
    "Microsoft.Network/trafficManagerProfiles/endpoints/read",
    "Microsoft.Insights/metricDefinitions/read",
    "Microsoft.Insights/metrics/read"
  ],
  "AssignableScopes": ["/subscriptions/{subscription-id}"]
}'
```

#### 2. Network Security Implementation
```bash
# Configure diagnostic settings for Traffic Manager
az monitor diagnostic-settings create \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/trafficManagerProfiles/{profile}" \
  --name "tm-diagnostics" \
  --logs '[{"category":"ProbeHealthStatusEvents","enabled":true,"retentionPolicy":{"enabled":true,"days":90}}]' \
  --metrics '[{"category":"AllMetrics","enabled":true,"retentionPolicy":{"enabled":true,"days":90}}]' \
  --workspace "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}"
```

#### 3. Compliance and Audit Trail
```bash
# Enable Activity Log export for compliance
az monitor log-profiles create \
  --name "traffic-manager-audit" \
  --location "global" \
  --locations "global" "East US" "West Europe" \
  --categories "Administrative" \
  --enabled true \
  --storage-account-id "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage}" \
  --retention-policy-enabled true \
  --retention-policy-days 2555  # 7 years for SOX compliance
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Endpoint Health Issues
**Symptoms**: Endpoint health alerts firing with endpoints showing as unhealthy

**Possible Causes**:
- Backend service unavailability
- Health check probe configuration issues
- Network connectivity problems
- Firewall or NSG blocking probe agents

**Troubleshooting Steps**:
```bash
# Check endpoint health status
az network traffic-manager endpoint show \
  --resource-group "rg-production-networking" \
  --profile-name "tm-production-web" \
  --name "endpoint-eastus" \
  --query "{Status:endpointStatus,MonitorStatus:endpointMonitorStatus,Target:target}"

# Test health check endpoint manually
curl -v https://myapp.azurewebsites.net/health

# Check Traffic Manager probe logs
az monitor activity-log list \
  --resource-group "rg-production-networking" \
  --start-time "2023-11-01T00:00:00Z" \
  --query "[?contains(resourceId, 'trafficManagerProfiles')]"
```

**Resolution**:
- Verify backend service is running and healthy
- Check health check endpoint responds correctly
- Verify firewall rules allow Traffic Manager probe agents
- Review and adjust health check configuration (timeout, interval, failures)

#### 2. DNS Resolution Failures
**Symptoms**: DNS resolution failure alerts with clients unable to resolve Traffic Manager FQDN

**Possible Causes**:
- All endpoints are unhealthy
- DNS propagation delays
- Traffic Manager profile configuration issues
- Client DNS resolver problems

**Troubleshooting Steps**:
```bash
# Test DNS resolution from multiple locations
nslookup production-web-tm.trafficmanager.net 8.8.8.8
nslookup production-web-tm.trafficmanager.net 1.1.1.1

# Check Traffic Manager profile status
az network traffic-manager profile show \
  --resource-group "rg-production-networking" \
  --name "tm-production-web" \
  --query "{Status:profileStatus,DnsName:dnsConfig.relativeName,TTL:dnsConfig.ttl}"

# Verify at least one endpoint is healthy
az network traffic-manager endpoint list \
  --resource-group "rg-production-networking" \
  --profile-name "tm-production-web" \
  --query "[?endpointMonitorStatus=='Online']"
```

**Resolution**:
- Ensure at least one endpoint is healthy and available
- Check Traffic Manager profile is enabled
- Verify DNS configuration and TTL settings
- Test DNS resolution from client networks
- Consider DNS cache refresh if recent changes were made

#### 3. Probe Agent Configuration Issues
**Symptoms**: Probe agent alerts firing with inconsistent endpoint monitoring

**Possible Causes**:
- Incorrect health check probe configuration
- Backend service not responding to probe protocol/path
- Network security groups blocking probe traffic
- Load balancer health probe conflicts

**Troubleshooting Steps**:
```bash
# Check probe configuration
az network traffic-manager profile show \
  --resource-group "rg-production-networking" \
  --name "tm-production-web" \
  --query "monitorConfig"

# Test probe endpoint manually
curl -I https://myapp.azurewebsites.net/api/health

# Check NSG rules for Traffic Manager probes
az network nsg rule list \
  --resource-group "rg-production-app" \
  --nsg-name "nsg-production-web" \
  --query "[?contains(sourceAddressPrefix, 'Internet')]"
```

**Resolution**:
- Verify health check path returns appropriate HTTP status codes
- Ensure probe protocol and port match backend service configuration
- Configure NSG rules to allow Traffic Manager probe agents (Internet source)
- Align Traffic Manager probes with backend load balancer health probes

#### 4. Failover Performance Issues
**Symptoms**: Slow failover during endpoint failures, extended downtime

**Possible Causes**:
- High DNS TTL values causing slow failover
- Insufficient health check frequency
- Client-side DNS caching
- Application connection pooling issues

**Troubleshooting Steps**:
```bash
# Check current DNS TTL configuration
az network traffic-manager profile show \
  --resource-group "rg-production-networking" \
  --name "tm-production-web" \
  --query "dnsConfig.ttl"

# Review health check configuration
az network traffic-manager profile show \
  --resource-group "rg-production-networking" \
  --name "tm-production-web" \
  --query "monitorConfig.{Interval:intervalInSeconds,Timeout:timeoutInSeconds,ToleratedFailures:toleratedNumberOfFailures}"

# Test failover timing
time nslookup production-web-tm.trafficmanager.net
```

**Resolution**:
- Reduce DNS TTL for faster failover (balance between performance and failover speed)
- Decrease health check interval and timeout values
- Implement application-level retry and circuit breaker patterns
- Configure client applications to honor DNS TTL values
- Consider using Azure Front Door for faster global failover

### Advanced Monitoring Setup

#### 1. Custom Traffic Manager Dashboard
```json
{
  "dashboard": {
    "title": "Traffic Manager Global Load Balancing Dashboard",
    "panels": [
      {
        "title": "Endpoint Health Status",
        "query": "AzureMetrics | where MetricName == 'ProbeAgentCurrentEndpointStateByProfileResourceId' | render timechart"
      },
      {
        "title": "DNS Query Volume",
        "query": "AzureActivity | where ResourceProvider == 'Microsoft.Network' and Resource has 'trafficManagerProfiles' | summarize count() by bin(TimeGenerated, 5m)"
      },
      {
        "title": "Endpoint State Changes",
        "query": "AzureActivity | where OperationName has 'Microsoft.Network/trafficManagerProfiles' | render columnchart"
      },
      {
        "title": "Geographic Distribution",
        "query": "AzureMetrics | where MetricName == 'QueriesByEndpoint' | summarize sum(Total) by ResourceId"
      }
    ]
  }
}
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Traffic Manager monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual traffic patterns, endpoint performance, and failover requirements is recommended for optimal global load balancing effectiveness.