# Azure Front Door Monitoring Alerts - Terraform Module

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Production Configuration](#production-configuration)
  - [Multi-Front Door Deployment](#multi-front-door-deployment)
  - [Classic Front Door Configuration](#classic-front-door-configuration)
  - [Selective Alert Configuration](#selective-alert-configuration)
- [Input Variables](#input-variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
  - [Alert Configuration Variables](#alert-configuration-variables)
- [Alert Details](#alert-details)
  - [Performance Monitoring Alerts](#performance-monitoring-alerts)
  - [Availability Monitoring Alerts](#availability-monitoring-alerts)
  - [Security Monitoring Alerts](#security-monitoring-alerts)
  - [Cost Monitoring Alerts](#cost-monitoring-alerts)
  - [Activity Log Alerts](#activity-log-alerts)
  - [Advanced Monitoring Alerts](#advanced-monitoring-alerts)
- [Alert Severity Levels](#alert-severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
  - [Front Door Architecture](#front-door-architecture)
  - [Performance Optimization](#performance-optimization)
  - [Security Configuration](#security-configuration)
  - [Cost Optimization](#cost-optimization)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Validation Commands](#validation-commands)
- [License](#license)

---

## Overview

This Terraform module provides comprehensive monitoring and alerting for **Azure Front Door**, Microsoft's global, scalable entry point that uses the Microsoft global edge network to deliver fast, secure, and scalable applications. Front Door combines CDN, application acceleration, SSL offload, Web Application Firewall (WAF), and global load balancing.

The module implements the **Azure Monitor Baseline Alerts (AMBA)** best practices specifically tailored for both Front Door types:
- **Azure Front Door Standard/Premium** (Microsoft.Cdn/profiles) - Modern, unified experience
- **Azure Front Door Classic** (Microsoft.Network/frontDoors) - Legacy version

**Coverage Areas:**
- **Performance monitoring** - Response time, request count, backend health
- **Availability monitoring** - Error rates, service availability, origin health
- **Security monitoring** - WAF blocked requests, SSL certificates, DDoS protection
- **Cost monitoring** - Bandwidth usage, request volume
- **Administrative monitoring** - Configuration changes, resource deletions
- **Advanced monitoring** - Origin health degradation patterns, certificate expiration

**Key Capabilities:**
- Automatic detection of Front Door type (Standard/Premium vs Classic)
- Multi-region global application delivery monitoring
- Backend pool health tracking
- WAF security event monitoring
- Bandwidth and cost optimization alerts
- SSL/TLS certificate lifecycle management

This module is essential for organizations running global web applications, API gateways, multi-region architectures, and applications requiring edge security and acceleration.

---

## Key Features

- **✅ 13 Comprehensive Alerts** - Performance, availability, security, cost, and administrative monitoring
- **✅ Dual Front Door Support** - Works with both Classic and Standard/Premium Front Door
- **✅ Auto-Detection** - Automatically identifies Front Door type and configures appropriate metrics
- **✅ 3 Metric Alerts** - Response time, backend health, request count
- **✅ 2 Availability Alerts** - Error rates, service availability
- **✅ 1 Security Alert** - WAF blocked requests monitoring
- **✅ 2 Cost Alerts** - Bandwidth and request volume tracking
- **✅ 3 Activity Log Alerts** - Configuration changes, deletions, backend pool changes
- **✅ 2 Advanced Alerts** - Origin health degradation, SSL certificate expiration
- **✅ Global Edge Monitoring** - Tracks performance across Microsoft's global edge network
- **✅ Customizable Thresholds** - All alert thresholds are configurable per environment
- **✅ Production-Ready** - Follows Azure AMBA guidelines for enterprise deployments

---

## Prerequisites

Before using this module, ensure you have:

1. **Terraform >= 1.0** installed
2. **Azure Provider >= 3.0** configured
3. **Existing Azure Front Door** deployed (Standard/Premium or Classic)
4. **Azure Monitor Action Group** created for alert notifications
5. **Appropriate Azure RBAC permissions**:
   - `Monitoring Contributor` role on the resource group
   - `Reader` role on Front Door resources
   - Access to the action group for notifications

6. **Front Door Requirements**:
   - Front Door deployed (Standard, Premium, or Classic tier)
   - Backend pools/origins configured
   - Routing rules defined
   - (Optional) WAF policy attached for security monitoring
   - (Optional) Custom domain with SSL/TLS certificate

---

## Module Structure

```
frontdoor/
├── alerts.tf       # Front Door metric and activity log alert definitions
├── variables.tf    # Input variable definitions
└── README.md       # This documentation file
```

---

## Usage

### Basic Usage

```hcl
module "frontdoor_alerts" {
  source = "./modules/metricAlerts/frontdoor"

  # Resource targeting
  front_door_names                   = ["global-app-frontdoor"]
  resource_group_name                = "rg-global-apps-production"

  # Front Door type (auto-detected by default)
  front_door_type                    = "standard"  # or "classic"
  auto_detect_front_door_type        = true

  # Action group configuration
  action_group                       = "frontdoor-ops-actiongroup"
  action_group_resource_group_name   = "rg-monitoring"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Global-Web-App"
    CostCenter         = "Engineering"
    DataClassification = "Public"
    Owner              = "platform-team@company.com"
  }
}
```

### Production Configuration

```hcl
module "frontdoor_alerts_prod" {
  source = "./modules/metricAlerts/frontdoor"

  # Production Front Door instances
  front_door_names = [
    "ecommerce-global-fd",
    "api-gateway-fd"
  ]
  resource_group_name                = "rg-frontdoor-production"
  subscription_ids                   = ["12345678-1234-1234-1234-123456789012"]

  # Action groups
  action_group                       = "frontdoor-critical-alerts"
  action_group_resource_group_name   = "rg-monitoring-prod"

  # Enable all alert categories
  enable_performance_alerts  = true
  enable_availability_alerts = true
  enable_security_alerts     = true
  enable_cost_alerts         = true

  # Performance Thresholds
  response_time_threshold    = 3000   # 3 seconds
  backend_health_threshold   = 90     # 90% healthy backends
  request_count_threshold    = 100000 # 100K requests per 15 min

  # Availability Thresholds
  error_rate_threshold       = 2      # 2% error rate
  availability_threshold     = 99.9   # 99.9% availability

  # Security Thresholds
  waf_blocked_requests_threshold = 500  # 500 blocked requests per 15 min

  # Cost Thresholds
  bandwidth_cost_threshold   = 5000   # 5TB bandwidth
  request_cost_threshold     = 10000000  # 10M requests

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "E-Commerce-Platform"
    CostCenter         = "Operations"
    Compliance         = "PCI-DSS"
    DR                 = "Critical"
    Owner              = "web-platform@company.com"
    AlertingSLA        = "24x7"
    BusinessImpact     = "High"
  }
}
```

### Multi-Front Door Deployment

```hcl
module "frontdoor_alerts_global" {
  source = "./modules/metricAlerts/frontdoor"

  # Multiple Front Door instances for different applications
  front_door_names = [
    "website-global-fd",
    "api-global-fd",
    "mobile-api-fd",
    "partner-portal-fd"
  ]
  resource_group_name                = "rg-frontdoor-global"
  subscription_ids                   = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]

  # Standard/Premium Front Door
  front_door_type                    = "standard"
  auto_detect_front_door_type        = true

  # Tiered action groups
  action_group                       = "global-apps-pagerduty"
  action_group_resource_group_name   = "rg-alerting"

  # Aggressive thresholds for global scale
  response_time_threshold            = 2000    # 2 seconds max
  backend_health_threshold           = 95      # 95% healthy
  request_count_threshold            = 500000  # 500K requests
  error_rate_threshold               = 1       # 1% error rate
  availability_threshold             = 99.95   # Four 9s
  waf_blocked_requests_threshold     = 1000    # 1K blocked requests

  # Cost monitoring for high-traffic
  bandwidth_cost_threshold           = 10000   # 10TB
  request_cost_threshold             = 50000000 # 50M requests

  tags = {
    Environment        = "Production"
    Application        = "Global-Platform"
    BusinessUnit       = "Digital"
    CostCenter         = "Platform"
    Compliance         = "SOC2,GDPR,PCI-DSS"
    DataClassification = "Confidential"
    DR                 = "Mission-Critical"
    Owner              = "platform-architecture@company.com"
    SLA                = "99.95"
    GlobalService      = "true"
  }
}
```

### Classic Front Door Configuration

```hcl
module "frontdoor_alerts_classic" {
  source = "./modules/metricAlerts/frontdoor"

  # Legacy Classic Front Door
  front_door_names                   = ["legacy-app-frontdoor"]
  resource_group_name                = "rg-legacy-apps"

  # Manual Front Door type specification
  front_door_type                    = "classic"
  auto_detect_front_door_type        = false

  # Action group
  action_group                       = "legacy-apps-alerts"
  action_group_resource_group_name   = "rg-monitoring"

  # Standard thresholds
  response_time_threshold            = 5000
  backend_health_threshold           = 80
  request_count_threshold            = 10000

  tags = {
    Environment = "Production"
    Application = "Legacy-Web-App"
    FrontDoorType = "Classic"
    Owner       = "legacy-team@company.com"
  }
}
```

### Selective Alert Configuration

```hcl
module "frontdoor_alerts_dev" {
  source = "./modules/metricAlerts/frontdoor"

  # Development Front Door
  front_door_names                   = ["dev-app-frontdoor"]
  resource_group_name                = "rg-frontdoor-dev"

  action_group                       = "dev-team-alerts"
  action_group_resource_group_name   = "rg-monitoring-dev"

  # Enable only critical alerts for dev
  enable_performance_alerts  = true
  enable_availability_alerts = true
  enable_security_alerts     = false   # Disable for dev
  enable_cost_alerts         = false   # Not needed in dev

  # Relaxed thresholds for development
  response_time_threshold    = 10000   # 10 seconds
  backend_health_threshold   = 70      # 70%
  request_count_threshold    = 1000    # Lower threshold
  error_rate_threshold       = 10      # 10% tolerable in dev
  availability_threshold     = 95      # 95% acceptable

  tags = {
    Environment = "Development"
    Application = "Web-App-Testing"
    CostCenter  = "Engineering"
    Owner       = "dev-team@company.com"
  }
}
```

---

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `front_door_names` | `list(string)` | List of Front Door names to monitor (leave empty to disable alerts) |
| `resource_group_name` | `string` | Resource group containing the Front Door resources |
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `action_group` | `string` | Name of the Azure Monitor action group for notifications |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `subscription_ids` | `list(string)` | `[]` (auto-detected) | Subscription IDs where Front Door resources are located |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `front_door_type` | `string` | `"standard"` | Front Door type: `standard` or `classic` |
| `auto_detect_front_door_type` | `bool` | `true` | Automatically detect Front Door type |
| `tags` | `map(string)` | See variables.tf | Resource tags for organization and cost tracking |

### Alert Configuration Variables

#### Alert Category Toggles

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_performance_alerts` | `bool` | `true` | Enable performance monitoring alerts |
| `enable_availability_alerts` | `bool` | `true` | Enable availability monitoring alerts |
| `enable_security_alerts` | `bool` | `true` | Enable security monitoring alerts |
| `enable_cost_alerts` | `bool` | `true` | Enable cost monitoring alerts |

#### Performance Alert Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `response_time_threshold` | `number` | `5000` | Response time threshold (milliseconds) |
| `backend_health_threshold` | `number` | `80` | Backend health percentage threshold |
| `request_count_threshold` | `number` | `10000` | Request count threshold (per 15-minute window) |

#### Availability Alert Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `error_rate_threshold` | `number` | `5` | Error rate percentage threshold |
| `availability_threshold` | `number` | `99` | Availability percentage threshold |
| `health_probe_failures_threshold` | `number` | `3` | Health probe failure count threshold |

#### Security Alert Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `waf_blocked_requests_threshold` | `number` | `100` | WAF blocked requests threshold (per 15-minute window) |
| `ddos_attack_threshold` | `number` | `1000` | DDoS attack requests threshold |

#### Cost Alert Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `bandwidth_cost_threshold` | `number` | `1000` | Bandwidth usage threshold (GB) for cost alerts |
| `request_cost_threshold` | `number` | `1000000` | Request count threshold for cost alerts |

---

## Alert Details

### Performance Monitoring Alerts

#### 1. High Response Time Alert
- **Metric**: `TotalLatency` (both types)
- **Threshold**: 5,000 ms (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Average
- **Description**: Monitors end-to-end response time from Front Door
- **Use Case**: Performance degradation detection, user experience monitoring

**What to do when this alert fires:**
```bash
# Check response time metrics
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "TotalLatency" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average

# Check backend health
az network front-door backend-pool list \
  --front-door-name <front-door-name> \
  --resource-group <resource-group>

# Actions:
# 1. Check backend origin response times
# 2. Review CDN cache hit ratios
# 3. Check for network latency issues
# 4. Verify backend capacity and CPU/memory
# 5. Review routing rules for optimization
# 6. Check for regional Azure service issues
# 7. Consider enabling compression if not active
```

#### 2. Backend Health Degradation Alert
- **Metric**: `BackendHealthPercentage` (Classic) or `OriginHealthPercentage` (Standard/Premium)
- **Threshold**: < 80% (default)
- **Severity**: 1 (Error)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Average
- **Description**: **CRITICAL** - Monitors percentage of healthy backends/origins
- **Use Case**: Service availability, backend failure detection

**What to do when this alert fires:**
```bash
# Check backend health (Classic)
az network front-door backend-pool backend show \
  --front-door-name <front-door-name> \
  --resource-group <resource-group> \
  --pool-name <backend-pool-name>

# Check origin health (Standard/Premium)
az afd origin show \
  --profile-name <profile-name> \
  --origin-group-name <origin-group-name> \
  --origin-name <origin-name> \
  --resource-group <resource-group>

# Check health probe settings
az network front-door probe show \
  --front-door-name <front-door-name> \
  --name <probe-name> \
  --resource-group <resource-group>

# Actions (URGENT):
# 1. Identify which backends are unhealthy
# 2. Check backend application health
# 3. Verify backend firewall/NSG rules allow Front Door traffic
# 4. Review health probe configuration (path, interval, threshold)
# 5. Check backend DNS resolution
# 6. Verify backend SSL certificates are valid
# 7. Check backend server capacity (CPU, memory, connections)
# 8. Review backend logs for errors
# 9. Consider adding additional backends for redundancy
```

#### 3. High Request Count Alert
- **Metric**: `RequestCount`
- **Threshold**: 10,000 requests (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: Monitors unusually high request volume
- **Use Case**: Traffic spike detection, capacity planning, potential attacks

**What to do when this alert fires:**
```bash
# Check request count
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "RequestCount" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Total

# Check request breakdown by status
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "RequestCount" \
  --filter "HttpStatus eq '*'" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Verify if traffic spike is expected (marketing campaign, viral content)
# 2. Check for potential DDoS attack patterns
# 3. Review WAF logs for malicious traffic
# 4. Monitor backend capacity and scaling
# 5. Check cache hit ratio (low ratio = more backend load)
# 6. Consider rate limiting if abuse detected
# 7. Review cost implications of increased traffic
# 8. Scale backend resources if legitimate traffic spike
```

### Availability Monitoring Alerts

#### 4. High Error Rate Alert
- **Metric**: `ResponseSize` (with dimension filtering)
- **Threshold**: > 5% errors (default)
- **Severity**: 1 (Error)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Average
- **Dimensions**: HttpStatusGroup = 4xx, 5xx
- **Description**: **CRITICAL** - Monitors HTTP error rate (client and server errors)
- **Use Case**: Service degradation detection, availability monitoring

**What to do when this alert fires:**
```bash
# Check error metrics by status code
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "RequestCount" \
  --filter "HttpStatus eq '4*' or HttpStatus eq '5*'" \
  --start-time <start-time> \
  --end-time <end-time>

# Check specific error codes
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "RequestCount" \
  --filter "HttpStatus eq '500' or HttpStatus eq '502' or HttpStatus eq '503'" \
  --start-time <start-time> \
  --end-time <end-time>

# Enable diagnostic logs
az monitor diagnostic-settings create \
  --resource <frontdoor-resource-id> \
  --name "frontdoor-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "FrontDoorAccessLog", "enabled": true}]'

# Actions (URGENT):
# 1. Identify specific HTTP status codes (4xx vs 5xx)
# 2. For 5xx errors: Check backend health immediately
# 3. For 502/503: Backends may be down or overloaded
# 4. For 404: Check routing rules and URL paths
# 5. For 403: Review WAF rules for false positives
# 6. Check backend application logs
# 7. Review recent configuration changes
# 8. Implement circuit breaker pattern if backends failing
```

#### 5. Low Availability Alert
- **Metric**: Backend/Origin Health Percentage
- **Threshold**: < 99% (default)
- **Severity**: 0 (Critical)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Average
- **Description**: **CRITICAL** - Service availability SLA breach
- **Use Case**: SLA monitoring, major outage detection

**What to do when this alert fires:**
```bash
# Check overall availability
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "BackendHealthPercentage" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Minimum

# Check all backends
az network front-door backend-pool list \
  --front-door-name <front-door-name> \
  --resource-group <resource-group>

# Actions (CRITICAL - IMMEDIATE):
# 1. Page on-call engineer immediately
# 2. Check all backend health status
# 3. Review Azure service health dashboard
# 4. Activate incident response procedures
# 5. Check for multi-backend failures (potential infrastructure issue)
# 6. Prepare customer communication
# 7. Consider failover to DR region if available
# 8. Document incident timeline
```

### Security Monitoring Alerts

#### 6. WAF High Blocked Requests Alert
- **Metric**: `WebApplicationFirewallRequestCount`
- **Threshold**: 100 blocked requests (default)
- **Severity**: 1 (Error)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Dimensions**: Action = Block
- **Description**: **SECURITY** - Unusually high number of WAF-blocked requests
- **Use Case**: Security threat detection, DDoS attack identification

**What to do when this alert fires:**
```bash
# Check WAF metrics
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "WebApplicationFirewallRequestCount" \
  --filter "Action eq 'Block'" \
  --start-time <start-time> \
  --end-time <end-time>

# Query WAF logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where Category == 'FrontDoorWebApplicationFirewallLog' 
    | where action_s == 'Block' 
    | where TimeGenerated > ago(15m) 
    | summarize count() by ruleName_s, clientIP_s 
    | order by count_ desc"

# Actions (SECURITY INCIDENT):
# 1. Identify attack patterns and source IPs
# 2. Check if legitimate traffic is being blocked (false positive)
# 3. Review WAF rule violations (SQL injection, XSS, etc.)
# 4. Consider adding IP blocking rules if DDoS attack
# 5. Tune WAF rules if false positives detected
# 6. Escalate to security team if coordinated attack
# 7. Document attack characteristics for post-mortem
# 8. Consider enabling additional WAF rule sets
# 9. Review rate limiting configuration
```

### Cost Monitoring Alerts

#### 7. High Bandwidth Usage Alert
- **Type**: Scheduled Query Rule
- **Threshold**: 1,000 GB (default)
- **Severity**: 2 (Warning)
- **Frequency**: P1D (daily)
- **Window**: P1D
- **Description**: Monitors bandwidth consumption for cost optimization
- **Use Case**: Cost management, unexpected traffic detection

**What to do when this alert fires:**
```bash
# Check bandwidth metrics
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "ResponseSize" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Total

# Check request count
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "RequestCount" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Review bandwidth usage trends
# 2. Check for large file downloads
# 3. Optimize image/video compression
# 4. Enable compression for text content
# 5. Review cache hit ratio (improve caching = lower bandwidth)
# 6. Consider CDN optimization rules
# 7. Identify top bandwidth-consuming endpoints
# 8. Forecast monthly costs based on current usage
```

#### 8. High Request Count Cost Alert
- **Type**: Scheduled Query Rule
- **Threshold**: 1,000,000 requests (default)
- **Severity**: 2 (Warning)
- **Frequency**: P1D
- **Window**: P1D
- **Description**: Monitors request volume for cost implications
- **Use Case**: Cost forecasting, usage pattern analysis

**What to do when this alert fires:**
```bash
# Analyze request patterns
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where Category == 'FrontDoorAccessLog' 
    | where TimeGenerated > ago(1d) 
    | summarize RequestCount = count() by bin(TimeGenerated, 1h), httpMethod_s, requestUri_s 
    | order by RequestCount desc"

# Actions:
# 1. Review top endpoints by request count
# 2. Identify potential bot traffic or scraping
# 3. Implement request caching where possible
# 4. Consider rate limiting for high-volume clients
# 5. Optimize API design to reduce request count
# 6. Review cost forecast for the month
# 7. Evaluate if Premium tier pricing is more cost-effective
```

### Activity Log Alerts

#### 9. Front Door Configuration Changes Alert
- **Operation**: `Microsoft.Network/frontDoors/write`
- **Category**: Administrative
- **Severity**: Informational
- **Description**: Tracks configuration changes to Front Door
- **Use Case**: Change auditing, security compliance

**What to do when this alert fires:**
```bash
# Query recent configuration changes
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --offset 24h \
  --query "[?contains(authorization.action, 'frontDoors/write')]"

# Actions:
# 1. Verify change was authorized
# 2. Review what configuration was changed
# 3. Document change in change management system
# 4. Test Front Door functionality after change
# 5. Monitor for any performance or availability impact
```

#### 10. Front Door Deletion Alert
- **Operation**: `Microsoft.Network/frontDoors/delete`
- **Category**: Administrative
- **Severity**: Warning
- **Description**: **CRITICAL** - Front Door resource deletion detected
- **Use Case**: Accidental deletion prevention, security auditing

**What to do when this alert fires:**
```bash
# Verify deletion event
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?contains(authorization.action, 'frontDoors/delete')]"

# Actions (URGENT):
# 1. Verify if deletion was authorized
# 2. Check who initiated the deletion
# 3. If accidental: Restore from Terraform state or backups
# 4. If malicious: Escalate to security team immediately
# 5. Review RBAC permissions to prevent future incidents
# 6. Document incident and recovery actions
```

#### 11. Backend Pool Changes Alert
- **Operation**: `Microsoft.Network/frontDoors/backendPools/write`
- **Category**: Administrative
- **Severity**: Informational
- **Description**: Tracks changes to backend pool configuration
- **Use Case**: Change tracking, availability correlation

**What to do when this alert fires:**
```bash
# Review backend pool changes
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?contains(authorization.action, 'backendPools/write')]"

# Actions:
# 1. Verify backend pool changes
# 2. Check backend health after change
# 3. Monitor for any traffic distribution changes
# 4. Document backend pool configuration
```

### Advanced Monitoring Alerts

#### 12. Origin Health Degradation Alert
- **Type**: Scheduled Query Rule
- **Severity**: 1 (Error)
- **Frequency**: PT5M
- **Window**: PT15M
- **Description**: Detects patterns of origin health degradation
- **Use Case**: Proactive failure detection, predictive alerting

**What to do when this alert fires:**
```bash
# Query health degradation patterns
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where Category == 'FrontDoorHealthProbeLog' 
    | where TimeGenerated > ago(15m) 
    | summarize FailureCount = countif(healthStatus_s == 'Unhealthy') by backendHostname_s 
    | where FailureCount > 2"

# Actions:
# 1. Identify backends showing degradation patterns
# 2. Check for intermittent failures
# 3. Review health probe success rate trends
# 4. Investigate backend infrastructure health
# 5. Consider preemptive scaling or failover
```

#### 13. SSL Certificate Expiration Alert
- **Type**: Scheduled Query Rule
- **Severity**: 2 (Warning)
- **Frequency**: P1D
- **Window**: P1D
- **Description**: Monitors SSL/TLS certificate lifecycle
- **Use Case**: Certificate expiration prevention, compliance

**What to do when this alert fires:**
```bash
# Check certificate expiration
az network front-door frontend-endpoint list \
  --front-door-name <front-door-name> \
  --resource-group <resource-group> \
  --query "[].{name:name, customHttpsConfiguration:customHttpsConfiguration}"

# Actions:
# 1. Identify certificates approaching expiration
# 2. Renew certificates through certificate authority
# 3. Update Front Door with new certificate
# 4. Test HTTPS connectivity after renewal
# 5. Document certificate renewal process
# 6. Consider automated certificate management (Azure Key Vault)
```

---

## Alert Severity Levels

| Severity | Level | Use Case | Example Alerts |
|----------|-------|----------|----------------|
| **0** | Critical | Service outage, complete unavailability | Low Availability |
| **1** | Error | Partial failures, security incidents | Backend Health Degradation, High Error Rate, WAF Blocked Requests, Origin Health Degradation |
| **2** | Warning | Performance degradation, cost overruns | High Response Time, High Request Count, Bandwidth Cost, Request Cost, SSL Expiration |
| **3** | Informational | Change tracking, awareness | Configuration Changes, Backend Pool Changes |
| **4** | Verbose | Detailed diagnostics | None in this module |

**Severity Guidelines:**
- **Severity 0** alerts require **immediate incident response** (service down)
- **Severity 1** alerts require **urgent investigation** (degradation, security)
- **Severity 2** alerts require **timely response** (performance, cost)
- **Severity 3** alerts are **informational** (awareness, auditing)

---

## Cost Analysis

### Alert Costs

**Azure Monitor Pricing (as of 2024):**
- Metric Alerts: **$0.10 per month** per alert rule
- Scheduled Query Rules: **$0.10 per month** per alert rule
- Activity Log Alerts: **FREE**

**This Module Cost Calculation:**
- **3 Metric Alerts** (per Front Door instance)
- **5 Scheduled Query Rules** (shared across instances)
- **3 Activity Log Alerts** (FREE)

**Cost per Front Door:**
- Metric alerts: 3 × $0.10 = **$0.30/month** per instance
- Shared query rules: $0.50/month total
- Activity log alerts: **$0.00/month** (FREE)

**Example Deployment Costs:**
- **1 Front Door**: 3 metric alerts + shared queries = **$0.30 + $0.50 = $0.80/month**
- **3 Front Doors**: (3 × $0.30) + $0.50 = **$1.40/month**
- **10 Front Doors**: (10 × $0.30) + $0.50 = **$3.50/month**
- **Annual cost (3 Front Doors)**: **$16.80/year**

### Front Door Costs

**Azure Front Door Standard Tier Pricing:**
- **Base Fee**: $35/month per profile
- **Data Transfer**: 
  - First 10 TB: $0.18/GB
  - Next 40 TB: $0.15/GB
  - Next 100 TB: $0.12/GB
- **HTTP/HTTPS Requests**: $0.0075 per 10,000 requests
- **Rules Engine**: First 100 rules free, then $1/month per rule

**Azure Front Door Premium Tier Pricing:**
- **Base Fee**: $330/month per profile
- **Data Transfer**: Same as Standard
- **HTTP/HTTPS Requests**: Same as Standard
- **Includes**: Private Link, advanced WAF, Bot protection

**Example Monthly Costs (Standard Tier):**
```
1 TB data transfer + 1M requests:
- Base fee: $35
- Data transfer: 1000 GB × $0.18 = $180
- Requests: (1,000,000 / 10,000) × $0.0075 = $0.75
- Total: ~$216/month

10 TB data transfer + 10M requests:
- Base fee: $35
- Data transfer: 10,000 GB × $0.18 = $1,800
- Requests: (10,000,000 / 10,000) × $0.0075 = $7.50
- Total: ~$1,843/month
```

### ROI Analysis

**Scenario: E-Commerce Platform with 5 TB Monthly Traffic**

**Without Monitoring:**
- Average downtime per incident: 2 hours
- Incidents per month: 2
- Revenue loss: $25,000/hour
- **Monthly loss**: 2 hours × 2 incidents × $25,000 = **$100,000**

**With Comprehensive Monitoring:**
- Alert cost: $0.80/month per Front Door
- Early detection reduces MTTR by 80% (2 hours → 24 minutes)
- Prevented downtime: 1.6 hours × 2 incidents = 3.2 hours
- **Monthly savings**: 3.2 hours × $25,000 = **$80,000**

**ROI Calculation:**
```
Monthly Investment: $0.80
Monthly Benefit: $80,000
Monthly Net Benefit: $79,999.20
ROI: (79,999.20 / 0.80) × 100 = 9,999,900%
Annual ROI: $959,990.40 savings vs $9.60 cost
```

**Additional Benefits:**
- Prevents security breaches (WAF monitoring)
- Optimizes costs through bandwidth monitoring
- Ensures SLA compliance (availability tracking)
- Reduces mean time to resolution (MTTR)
- Provides audit trail for compliance
- Proactive SSL certificate management

---

## Best Practices

### Front Door Architecture

1. **Global Distribution**
   - Deploy Front Door in front of multi-region backends
   - Use Front Door for global load balancing across regions
   - Configure health probes for each backend
   - Implement active-passive or active-active architectures
   - Test failover between regions regularly

2. **Backend Pool Design**
   - Use at least 2 backends per pool for redundancy
   - Distribute backends across availability zones
   - Configure appropriate priority and weight settings
   - Use session affinity only when necessary (stateful apps)
   - Monitor backend capacity and auto-scale

3. **Routing Rules**
   - Design routing rules for efficiency (fewer rules = lower cost)
   - Use URL path-based routing for microservices
   - Implement URL rewrite/redirect rules where needed
   - Test routing changes in staging before production
   - Document routing logic for operations teams

4. **Health Probes**
   - Use dedicated health probe endpoints (e.g., `/health`)
   - Set appropriate probe intervals (30-60 seconds typical)
   - Configure probe timeout based on backend response time
   - Use HTTP/HTTPS probes matching your backend protocol
   - Monitor probe success rates

### Performance Optimization

1. **Caching Strategy**
   - Enable caching for static content (images, CSS, JS)
   - Configure appropriate cache TTL values
   - Use query string caching when appropriate
   - Implement cache purging strategies
   - Monitor cache hit ratios (target > 80%)

2. **Compression**
   - Enable compression for text content (HTML, JSON, XML)
   - Configure MIME types for compression
   - Verify compression is working (check Content-Encoding header)
   - Measure bandwidth savings from compression

3. **Response Time Optimization**
   - Keep response times < 3 seconds for good user experience
   - Optimize backend application performance
   - Use CDN for static assets
   - Implement edge computing where applicable
   - Monitor P50, P95, P99 latency percentiles

4. **Connection Optimization**
   - Enable HTTP/2 and HTTP/3 (QUIC) when available
   - Use connection multiplexing
   - Optimize SSL/TLS handshake (session resumption)
   - Consider TCP optimization at backend

### Security Configuration

1. **WAF Configuration**
   - Enable WAF on all production Front Doors
   - Use Managed Rule Sets (OWASP, Bot protection)
   - Configure custom rules for application-specific threats
   - Tune rules to minimize false positives
   - Monitor WAF logs regularly
   - Test WAF rules in detection mode before blocking

2. **SSL/TLS**
   - Use minimum TLS 1.2 (prefer TLS 1.3)
   - Disable weak cipher suites
   - Implement HTTP to HTTPS redirect
   - Use Azure-managed certificates or bring your own
   - Monitor certificate expiration (30-60 days advance notice)
   - Implement certificate auto-renewal where possible

3. **DDoS Protection**
   - Azure Front Door includes built-in DDoS protection
   - Monitor for DDoS attack patterns in metrics
   - Configure rate limiting for API endpoints
   - Use WAF geo-filtering if traffic is region-specific
   - Implement bot protection (Premium tier)

4. **Access Control**
   - Use Private Link to backends (Premium tier)
   - Implement IP restrictions where appropriate
   - Use Azure AD authentication for APIs
   - Restrict access to Front Door management operations
   - Audit administrative actions regularly

### Cost Optimization

1. **Bandwidth Optimization**
   - Enable compression to reduce data transfer
   - Optimize image and video sizes
   - Use efficient file formats (WebP for images, H.265 for video)
   - Implement lazy loading for images
   - Monitor top bandwidth-consuming endpoints

2. **Request Optimization**
   - Reduce unnecessary API calls
   - Implement client-side caching
   - Use batching for API requests where possible
   - Optimize mobile app request patterns
   - Monitor request patterns for optimization opportunities

3. **Tier Selection**
   - Standard tier for most workloads
   - Premium tier for:
     - Private Link requirements
     - Advanced WAF and bot protection
     - Compliance requirements (PCI-DSS, HIPAA)
   - Classic tier only for legacy migrations

4. **Rules Engine**
   - First 100 rules are free
   - Consolidate rules to stay under limit
   - Review and remove unused rules
   - Use rule conditions efficiently

### Monitoring and Diagnostics

1. **Diagnostic Logging**
   - Enable FrontDoorAccessLog for all requests
   - Enable FrontDoorWebApplicationFirewallLog for WAF
   - Enable FrontDoorHealthProbeLog for backend health
   - Send logs to Log Analytics for analysis
   - Set appropriate retention policies

2. **Custom Dashboards**
   - Create Azure Workbooks for Front Door monitoring
   - Include: request count, latency, error rate, cache hit ratio
   - Set up separate dashboards for operations and security teams
   - Include cost tracking in dashboards

3. **Log Analytics Queries**
   ```kql
   // Top URLs by request count
   AzureDiagnostics
   | where Category == "FrontDoorAccessLog"
   | summarize RequestCount = count() by requestUri_s
   | top 20 by RequestCount desc

   // Error rate by status code
   AzureDiagnostics
   | where Category == "FrontDoorAccessLog"
   | where httpStatusCode_s startswith "5" or httpStatusCode_s startswith "4"
   | summarize ErrorCount = count() by httpStatusCode_s
   | order by ErrorCount desc

   // Backend latency analysis
   AzureDiagnostics
   | where Category == "FrontDoorAccessLog"
   | summarize 
       P50 = percentile(backendResponseLatencyMs_d, 50),
       P95 = percentile(backendResponseLatencyMs_d, 95),
       P99 = percentile(backendResponseLatencyMs_d, 99)
       by bin(TimeGenerated, 5m)
   | render timechart
   ```

4. **Testing and Validation**
   - Regularly test failover scenarios
   - Validate health probe functionality
   - Test WAF rules in safe environment
   - Verify SSL certificate renewal process
   - Conduct load testing to validate capacity

---

## Troubleshooting

### Common Issues

#### Issue 1: Alerts Not Firing Despite Meeting Thresholds

**Symptoms:**
- Metrics exceed thresholds but no alerts triggered
- Alert state shows "Not Activated"

**Troubleshooting Steps:**
```bash
# 1. Verify alert is enabled
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "FrontDoor-High-Response-Time-<name>" \
  --query "enabled"

# 2. Check if Front Door type is correct
az network front-door show \
  --name <front-door-name> \
  --resource-group <resource-group> \
  --query "type"

# 3. Verify metric availability
az monitor metrics list-definitions \
  --resource <frontdoor-resource-id> \
  --query "[].{name:name.value, namespace:namespace}"

# 4. Check action group
az monitor action-group show \
  --resource-group <action-group-rg> \
  --name <action-group-name>
```

**Common Causes:**
- Incorrect `front_door_type` variable (classic vs standard)
- Metric namespace mismatch
- Front Door not generating metrics (no traffic)
- Action group email not confirmed

**Resolution:**
```hcl
# Set correct Front Door type
front_door_type = "standard"  # or "classic"
auto_detect_front_door_type = true  # Enable auto-detection

# Verify resource scope matches Front Door type
# Classic: /subscriptions/.../Microsoft.Network/frontDoors/...
# Standard/Premium: /subscriptions/.../Microsoft.Cdn/profiles/...
```

---

#### Issue 2: High Response Time Alerts

**Symptoms:**
- Consistent high latency alerts
- Poor user experience

**Troubleshooting Steps:**
```bash
# Check latency metrics
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "TotalLatency" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Check backend health
az network front-door backend-pool list \
  --front-door-name <front-door-name> \
  --resource-group <resource-group>

# Check cache hit ratio
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "RequestCount" \
  --filter "CacheStatus eq 'HIT' or CacheStatus eq 'MISS'" \
  --start-time <start-time> \
  --end-time <end-time>
```

**Common Causes:**
- Backend response time slow
- Low cache hit ratio
- Network latency to backends
- Backend capacity issues
- Inefficient routing rules

**Resolution:**
```bash
# Improve caching
az network front-door routing-rule update \
  --front-door-name <front-door-name> \
  --name <rule-name> \
  --resource-group <resource-group> \
  --cache-duration PT1H

# Optimize backend pool
# - Add more backends for load distribution
# - Scale backend resources (CPU, memory)
# - Use content compression
# - Optimize database queries
# - Implement CDN for static assets
```

---

#### Issue 3: Backend Health Degradation

**Symptoms:**
- Backend health percentage drops below threshold
- Intermittent 5xx errors
- Some users experiencing failures

**Troubleshooting Steps:**
```bash
# Check specific backend health
az network front-door backend-pool backend list \
  --front-door-name <front-door-name> \
  --pool-name <pool-name> \
  --resource-group <resource-group>

# Check health probe configuration
az network front-door probe show \
  --front-door-name <front-door-name> \
  --name <probe-name> \
  --resource-group <resource-group>

# Test backend directly
curl -I https://<backend-hostname>/<health-probe-path>

# Check backend firewall rules
az network nsg rule list \
  --nsg-name <backend-nsg> \
  --resource-group <backend-resource-group> \
  --query "[?destinationPortRange=='443']"
```

**Common Causes:**
- Backend application errors
- Firewall blocking Front Door IPs
- Health probe path returning errors
- SSL certificate issues on backend
- Backend resource exhaustion

**Resolution:**
```bash
# Allow Front Door service tag in NSG
az network nsg rule create \
  --resource-group <backend-resource-group> \
  --nsg-name <backend-nsg> \
  --name AllowFrontDoor \
  --priority 100 \
  --source-address-prefixes AzureFrontDoor.Backend \
  --destination-port-ranges 443 \
  --access Allow \
  --protocol Tcp

# Fix health probe endpoint
# Ensure /health endpoint returns 200 OK
# Check backend application health
# Validate SSL certificates
# Scale backend resources if capacity issue
```

---

#### Issue 4: WAF Blocking Legitimate Traffic

**Symptoms:**
- High WAF blocked requests alert
- Users reporting 403 errors
- Legitimate traffic being blocked

**Troubleshooting Steps:**
```bash
# Query WAF logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where Category == 'FrontDoorWebApplicationFirewallLog' 
    | where action_s == 'Block' 
    | where TimeGenerated > ago(1h) 
    | summarize count() by ruleName_s, details_message_s 
    | order by count_ desc"

# Check specific rule details
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where Category == 'FrontDoorWebApplicationFirewallLog' 
    | where action_s == 'Block' 
    | where ruleName_s == '<rule-name>' 
    | project TimeGenerated, clientIP_s, requestUri_s, details_message_s"
```

**Common Causes:**
- Overly aggressive WAF rules
- False positive detections
- API requests triggering SQL injection rules
- User-generated content triggering XSS rules

**Resolution:**
```bash
# Create WAF exclusion
az network front-door waf-policy managed-rule-exclusion add \
  --policy-name <waf-policy-name> \
  --resource-group <resource-group> \
  --type RequestHeaderNames \
  --match-variable "User-Agent"

# Or create custom rule to allow specific patterns
az network front-door waf-policy rule create \
  --policy-name <waf-policy-name> \
  --resource-group <resource-group> \
  --name AllowLegitimate \
  --priority 10 \
  --rule-type MatchRule \
  --action Allow \
  --match-condition "RequestUri" "Contains" "/api/upload"

# Consider switching rule to Detection mode temporarily
az network front-door waf-policy managed-rule-override-rule add \
  --policy-name <waf-policy-name> \
  --resource-group <resource-group> \
  --rule-group-name <rule-group> \
  --rule-id <rule-id> \
  --action Log
```

---

#### Issue 5: SSL Certificate Issues

**Symptoms:**
- SSL certificate expiration alert
- HTTPS connection failures
- Certificate warnings in browsers

**Troubleshooting Steps:**
```bash
# Check certificate details
az network front-door frontend-endpoint list \
  --front-door-name <front-door-name> \
  --resource-group <resource-group>

# Test SSL certificate
curl -vI https://<custom-domain>

# Check certificate expiration
openssl s_client -connect <custom-domain>:443 -servername <custom-domain> 2>/dev/null | \
  openssl x509 -noout -dates
```

**Common Causes:**
- Certificate expired
- Certificate not renewed in time
- Wrong certificate uploaded
- Certificate chain incomplete

**Resolution:**
```bash
# For Azure-managed certificates (auto-renewal)
az network front-door frontend-endpoint enable-https \
  --front-door-name <front-door-name> \
  --name <frontend-endpoint> \
  --resource-group <resource-group>

# For custom certificates
# 1. Obtain renewed certificate from CA
# 2. Upload to Key Vault
# 3. Update Front Door

az keyvault certificate import \
  --vault-name <vault-name> \
  --name <cert-name> \
  --file <certificate-file>

az network front-door frontend-endpoint enable-https \
  --front-door-name <front-door-name> \
  --name <frontend-endpoint> \
  --resource-group <resource-group> \
  --certificate-source AzureKeyVault \
  --vault-id <key-vault-id> \
  --secret-name <cert-name>
```

---

### Validation Commands

```bash
# 1. List Front Doors (Classic)
az network front-door list \
  --resource-group <resource-group> \
  --output table

# 2. List Front Door profiles (Standard/Premium)
az afd profile list \
  --resource-group <resource-group> \
  --output table

# 3. Get Front Door details
az network front-door show \
  --name <front-door-name> \
  --resource-group <resource-group>

# 4. List backend pools
az network front-door backend-pool list \
  --front-door-name <front-door-name> \
  --resource-group <resource-group>

# 5. Check backend health
az network front-door backend-pool backend list \
  --front-door-name <front-door-name> \
  --pool-name <pool-name> \
  --resource-group <resource-group>

# 6. List routing rules
az network front-door routing-rule list \
  --front-door-name <front-door-name> \
  --resource-group <resource-group>

# 7. Check WAF policy
az network front-door waf-policy show \
  --name <waf-policy-name> \
  --resource-group <resource-group>

# 8. List metric definitions
az monitor metrics list-definitions \
  --resource <frontdoor-resource-id>

# 9. Query response time metrics
az monitor metrics list \
  --resource <frontdoor-resource-id> \
  --metric "TotalLatency" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --interval PT5M \
  --aggregation Average

# 10. List all alerts
az monitor metrics alert list \
  --resource-group <resource-group> \
  --output table

# 11. Get alert details
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "FrontDoor-High-Response-Time-<name>"

# 12. Test action group
az monitor action-group test-notifications create \
  --action-group <action-group-name> \
  --resource-group <resource-group> \
  --alert-type "Monitoring"

# 13. Enable diagnostic logging
az monitor diagnostic-settings create \
  --resource <frontdoor-resource-id> \
  --name "frontdoor-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[
    {"category": "FrontDoorAccessLog", "enabled": true},
    {"category": "FrontDoorWebApplicationFirewallLog", "enabled": true},
    {"category": "FrontDoorHealthProbeLog", "enabled": true}
  ]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# 14. Query access logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where Category == 'FrontDoorAccessLog' 
    | where TimeGenerated > ago(1h) 
    | summarize 
        RequestCount = count(),
        AvgLatency = avg(totalLatencyMilliseconds_d)
        by httpStatusCode_s 
    | order by RequestCount desc"

# 15. Check Front Door resource health
az rest --method get \
  --url "https://management.azure.com<frontdoor-resource-id>/providers/Microsoft.ResourceHealth/availabilityStatuses/current?api-version=2020-05-01"

# 16. Validate Terraform deployment
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

---

## License

This module is provided as-is under the MIT License. See LICENSE file for details.

---

**Module Maintained By:** Platform Engineering Team  
**Last Updated:** 2024-01-01  
**Terraform Version:** >= 1.0  
**Azure Provider Version:** >= 3.0

For questions or issues, please contact the Platform Engineering team or open an issue in the repository.
