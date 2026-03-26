# Azure Event Grid Namespace Monitoring Alerts - Terraform Module

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Production Configuration](#production-configuration)
  - [Multi-Namespace IoT Deployment](#multi-namespace-iot-deployment)
  - [Selective Alert Configuration](#selective-alert-configuration)
- [Input Variables](#input-variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
  - [Alert Configuration Variables](#alert-configuration-variables)
- [Alert Details](#alert-details)
  - [MQTT Protocol Alerts](#mqtt-protocol-alerts)
  - [HTTP Protocol Alerts](#http-protocol-alerts)
  - [Error and Failure Alerts](#error-and-failure-alerts)
  - [Performance and Throttling Alerts](#performance-and-throttling-alerts)
- [Alert Severity Levels](#alert-severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
  - [IoT and MQTT Workloads](#iot-and-mqtt-workloads)
  - [Event Routing and Delivery](#event-routing-and-delivery)
  - [Security and Authentication](#security-and-authentication)
  - [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Validation Commands](#validation-commands)
- [License](#license)

---

## Overview

This Terraform module provides comprehensive monitoring and alerting for **Azure Event Grid Namespaces**, which support both **MQTT** and **HTTP** protocols for IoT device communication and real-time event-driven messaging scenarios. Event Grid Namespaces are designed for modern IoT workloads, enabling bidirectional communication with millions of devices using MQTT 3.1.1, MQTT 5.0, and HTTP protocols.

The module implements the **Azure Monitor Baseline Alerts (AMBA)** best practices specifically tailored for Event Grid Namespaces, covering:
- **MQTT protocol monitoring** - Connection count, message publishing, message delivery
- **HTTP protocol monitoring** - Request volume and throughput
- **Error detection** - Routing failures, authentication issues, connection drops
- **Performance tracking** - Message latency and throttling
- **Capacity management** - Topic space usage and resource utilization

**Key Capabilities:**
- Monitors MQTT broker operations for IoT device fleets
- Tracks bidirectional message flow (publish/subscribe patterns)
- Detects authentication and authorization failures
- Identifies routing and delivery issues
- Monitors message latency and throughput
- Tracks throttling events and capacity constraints

This module is essential for organizations running IoT solutions, real-time telemetry systems, command-and-control architectures, and event-driven microservices using Event Grid Namespaces.

---

## Key Features

- **✅ 10 Metric Alerts** - Comprehensive coverage for MQTT, HTTP, errors, and performance
- **✅ Multi-Protocol Support** - Monitors both MQTT and HTTP event delivery
- **✅ IoT-Optimized** - Specifically designed for device fleet management
- **✅ Bidirectional Communication** - Tracks both device-to-cloud and cloud-to-device messaging
- **✅ Security Monitoring** - Authentication and authorization failure detection
- **✅ Real-Time Performance** - Message latency and throughput tracking
- **✅ Throttling Detection** - Identifies capacity constraints early
- **✅ Customizable Thresholds** - All alert thresholds are configurable per environment
- **✅ Auto-Discovery** - Subscription ID auto-detection when not explicitly provided
- **✅ Production-Ready** - Follows Azure AMBA guidelines for enterprise deployments

---

## Prerequisites

Before using this module, ensure you have:

1. **Terraform >= 1.0** installed
2. **Azure Provider >= 3.0** configured
3. **Existing Azure Event Grid Namespace(s)** deployed
4. **Azure Monitor Action Group** created for alert notifications
5. **Appropriate Azure RBAC permissions**:
   - `Monitoring Contributor` role on the resource group
   - `Reader` role on Event Grid namespaces
   - Access to the action group for notifications

6. **Event Grid Namespace Requirements**:
   - Namespace must be deployed (Standard or Premium tier)
   - MQTT broker enabled if using MQTT alerts
   - Topic spaces and subscriptions configured
   - Authentication configured (X.509 certificates, SAS tokens, or Azure AD)

7. **Recommended**: 
   - Log Analytics workspace for diagnostic settings
   - Diagnostic settings enabled on Event Grid Namespaces

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs provides essential troubleshooting capabilities for MQTT connection analysis, message tracing, and error investigation.

---

## Module Structure

```
eventgridnamespace/
├── alerts.tf       # Event Grid Namespace metric alert definitions
├── variables.tf    # Input variable definitions
└── README.md       # This documentation file
```

---

## Usage

### Basic Usage

```hcl
module "eventgrid_namespace_alerts" {
  source = "./modules/metricAlerts/eventgridnamespace"

  # Resource targeting
  eventgrid_namespace_names          = ["iot-mqtt-namespace-prod"]
  resource_group_name                = "rg-iot-production"
  subscription_id                    = "12345678-1234-1234-1234-123456789012"

  # Action group configuration
  action_group                       = "iot-operations-actiongroup"
  action_group_resource_group_name   = "rg-monitoring"

  # Alert timing
  eventgrid_evaluation_frequency     = "PT5M"   # Check every 5 minutes
  eventgrid_window_duration          = "PT15M"  # Over 15-minute window

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "IoT-Platform"
    CostCenter         = "Engineering"
    DataClassification = "Internal"
    Owner              = "iot-team@company.com"
  }
}
```

### Production Configuration

```hcl
module "eventgrid_namespace_alerts_prod" {
  source = "./modules/metricAlerts/eventgridnamespace"

  # Multi-namespace monitoring for IoT fleet
  eventgrid_namespace_names          = [
    "iot-devices-west-prod",
    "iot-devices-east-prod",
    "iot-telemetry-prod"
  ]
  resource_group_name                = "rg-iot-production"
  subscription_id                    = "12345678-1234-1234-1234-123456789012"

  # Action groups
  action_group                       = "iot-critical-alerts"
  action_group_resource_group_name   = "rg-monitoring-prod"

  # Alert timing - more frequent for production
  eventgrid_evaluation_frequency     = "PT1M"   # Check every 1 minute
  eventgrid_window_duration          = "PT5M"   # Over 5-minute window

  # MQTT Connection Monitoring
  enable_eventgrid_mqtt_connections_alert = true
  eventgrid_mqtt_connections_threshold    = 50000  # Alert at 50K connections

  # MQTT Message Volume
  enable_eventgrid_mqtt_messages_published_alert = true
  eventgrid_mqtt_messages_published_threshold    = 100000  # 100K messages per window

  enable_eventgrid_mqtt_messages_received_alert = true
  eventgrid_mqtt_messages_received_threshold    = 100000

  # HTTP Request Monitoring
  enable_eventgrid_http_requests_alert = true
  eventgrid_http_requests_threshold    = 10000

  # Critical Error Monitoring
  enable_eventgrid_routing_failures_alert = true
  eventgrid_routing_failures_threshold    = 1  # Alert on any routing failure

  enable_eventgrid_authentication_failures_alert = true
  eventgrid_authentication_failures_threshold    = 10  # Allow some retries

  enable_eventgrid_connection_failures_alert = true
  eventgrid_connection_failures_threshold    = 50  # Dropped sessions

  # Performance Monitoring
  enable_eventgrid_message_latency_alert = true
  eventgrid_message_latency_threshold    = 500  # 500ms latency threshold

  enable_eventgrid_throttled_requests_alert = true
  eventgrid_throttled_requests_threshold    = 10  # Alert early on throttling

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "IoT-Device-Fleet"
    CostCenter         = "Operations"
    Compliance         = "ISO27001"
    DR                 = "Critical"
    Owner              = "iot-platform@company.com"
    AlertingSLA        = "24x7"
  }
}
```

### Multi-Namespace IoT Deployment

```hcl
module "eventgrid_namespace_alerts_iot" {
  source = "./modules/metricAlerts/eventgridnamespace"

  # Regional IoT namespaces
  eventgrid_namespace_names = [
    "iot-manufacturing-us-west",
    "iot-manufacturing-us-east",
    "iot-logistics-central",
    "iot-telemetry-global"
  ]
  resource_group_name                = "rg-iot-global"
  subscription_id                    = "12345678-1234-1234-1234-123456789012"

  # Tiered action groups
  action_group                       = "iot-operations-pagerduty"
  action_group_resource_group_name   = "rg-alerting"

  # Aggressive monitoring for IoT
  eventgrid_evaluation_frequency     = "PT1M"   # Every minute
  eventgrid_window_duration          = "PT5M"   # 5-minute aggregation

  # MQTT-focused thresholds for device communication
  eventgrid_mqtt_connections_threshold       = 100000  # 100K concurrent devices
  eventgrid_mqtt_messages_published_threshold = 500000  # 500K messages per 5 min
  eventgrid_mqtt_messages_received_threshold  = 500000  # Bidirectional traffic

  # Zero tolerance for routing failures in production
  eventgrid_routing_failures_threshold = 1

  # Authentication monitoring for security
  eventgrid_authentication_failures_threshold = 5  # Detect brute force

  # Performance SLA enforcement
  eventgrid_message_latency_threshold = 300  # 300ms max latency

  # Capacity planning
  eventgrid_throttled_requests_threshold = 5  # Scale before hitting limits

  tags = {
    Environment        = "Production"
    Application        = "IoT-Global-Platform"
    BusinessUnit       = "Manufacturing"
    CostCenter         = "Operations"
    Compliance         = "SOC2"
    DataClassification = "Confidential"
    DR                 = "Mission-Critical"
    Owner              = "iot-architecture@company.com"
    SLA                = "99.95"
  }
}
```

### Selective Alert Configuration

```hcl
module "eventgrid_namespace_alerts_dev" {
  source = "./modules/metricAlerts/eventgridnamespace"

  # Development namespace
  eventgrid_namespace_names          = ["iot-dev-namespace"]
  resource_group_name                = "rg-iot-dev"
  subscription_id                    = "12345678-1234-1234-1234-123456789012"

  action_group                       = "dev-team-alerts"
  action_group_resource_group_name   = "rg-monitoring-dev"

  # Enable only critical alerts for dev
  enable_eventgrid_mqtt_connections_alert        = true
  enable_eventgrid_mqtt_messages_published_alert = false  # Not needed in dev
  enable_eventgrid_mqtt_messages_received_alert  = false  # Not needed in dev
  enable_eventgrid_http_requests_alert           = true
  enable_eventgrid_routing_failures_alert        = true   # Always monitor
  enable_eventgrid_authentication_failures_alert = false  # Disable for dev
  enable_eventgrid_message_latency_alert         = false  # Not critical in dev
  enable_eventgrid_connection_failures_alert     = true
  enable_eventgrid_throttled_requests_alert      = true
  enable_eventgrid_topic_space_usage_alert       = false  # Not needed

  # Relaxed thresholds for development
  eventgrid_mqtt_connections_threshold    = 100
  eventgrid_http_requests_threshold       = 1000
  eventgrid_routing_failures_threshold    = 10
  eventgrid_connection_failures_threshold = 50
  eventgrid_throttled_requests_threshold  = 100

  tags = {
    Environment = "Development"
    Application = "IoT-Testing"
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
| `eventgrid_namespace_names` | `list(string)` | List of Event Grid namespace names to monitor (supports MQTT and HTTP protocols) |
| `resource_group_name` | `string` | Resource group containing the Event Grid namespaces |
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `action_group` | `string` | Name of the Azure Monitor action group for notifications |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `subscription_id` | `string` | `""` (auto-detected) | Azure subscription ID where namespaces are located |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `eventgrid_evaluation_frequency` | `string` | `"PT5M"` | How often to evaluate alert conditions |
| `eventgrid_window_duration` | `string` | `"PT15M"` | Time window for metric aggregation |
| `tags` | `map(string)` | See variables.tf | Resource tags for organization and cost tracking |

### Alert Configuration Variables

#### MQTT Protocol Alert Toggles
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_eventgrid_mqtt_connections_alert` | `bool` | `true` | Enable MQTT concurrent connections monitoring |
| `enable_eventgrid_mqtt_messages_published_alert` | `bool` | `true` | Enable MQTT published messages volume monitoring |
| `enable_eventgrid_mqtt_messages_received_alert` | `bool` | `true` | Enable MQTT received messages volume monitoring |

#### HTTP Protocol Alert Toggles
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_eventgrid_http_requests_alert` | `bool` | `true` | Enable HTTP request volume monitoring |

#### Error Detection Alert Toggles
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_eventgrid_routing_failures_alert` | `bool` | `true` | Enable event routing failure detection |
| `enable_eventgrid_authentication_failures_alert` | `bool` | `true` | Enable authentication failure detection |
| `enable_eventgrid_connection_failures_alert` | `bool` | `true` | Enable connection drop/failure detection |

#### Performance Alert Toggles
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_eventgrid_message_latency_alert` | `bool` | `true` | Enable message publish latency monitoring |
| `enable_eventgrid_throttled_requests_alert` | `bool` | `true` | Enable throttling detection |
| `enable_eventgrid_topic_space_usage_alert` | `bool` | `true` | Enable topic space capacity monitoring (currently disabled) |

#### Alert Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `eventgrid_mqtt_connections_threshold` | `number` | `1000` | MQTT concurrent connection count threshold |
| `eventgrid_mqtt_messages_published_threshold` | `number` | `5000` | MQTT published message count threshold (per window) |
| `eventgrid_mqtt_messages_received_threshold` | `number` | `5000` | MQTT received message count threshold (per window) |
| `eventgrid_http_requests_threshold` | `number` | `1000` | HTTP request count threshold (per window) |
| `eventgrid_routing_failures_threshold` | `number` | `1` | Event routing failure count threshold |
| `eventgrid_authentication_failures_threshold` | `number` | `5` | Authentication failure count threshold |
| `eventgrid_connection_failures_threshold` | `number` | `10` | Dropped session/connection count threshold |
| `eventgrid_throttled_requests_threshold` | `number` | `50` | Throttling enforcement count threshold |
| `eventgrid_message_latency_threshold` | `number` | `1000` | Message publish latency threshold (milliseconds) |
| `eventgrid_topic_space_usage_threshold` | `number` | `80` | Topic space usage percentage threshold |

---

## Alert Details

### MQTT Protocol Alerts

#### 1. MQTT Connections Alert
- **Metric**: `Mqtt.Connections`
- **Threshold**: 1,000 concurrent connections (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Description**: Monitors the number of concurrent MQTT connections from IoT devices
- **Use Case**: Capacity planning, detecting connection storms, tracking device fleet size

**What to do when this alert fires:**
```bash
# Check current MQTT connections
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "properties.topicsConfiguration.mqttConfiguration"

# View connection metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.Connections" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z

# Actions:
# 1. Verify if connection spike is expected (new device rollout, firmware update)
# 2. Check for connection leaks (devices not properly disconnecting)
# 3. Review connection limits for your namespace tier
# 4. Consider scaling to a higher tier if sustained high connections
# 5. Implement connection pooling or device grouping strategies
```

#### 2. MQTT Messages Published Alert
- **Metric**: `Mqtt.SuccessfulPublishedMessages`
- **Threshold**: 5,000 messages per window (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors device-to-cloud message volume (telemetry, events)
- **Use Case**: Telemetry volume tracking, cost monitoring, capacity planning

**What to do when this alert fires:**
```bash
# Check published message volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.SuccessfulPublishedMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Verify if message spike is expected (seasonal pattern, new device deployment)
# 2. Check for chatty devices sending excessive telemetry
# 3. Review message batching configuration
# 4. Optimize message payload sizes
# 5. Implement message throttling at device level if needed
# 6. Monitor cost implications of increased message volume
```

#### 3. MQTT Messages Received Alert
- **Metric**: `SuccessfulReceivedEvents`
- **Threshold**: 5,000 messages per window (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors cloud-to-device message volume (commands, configurations)
- **Use Case**: Command-and-control operations, firmware updates, configuration changes

**What to do when this alert fires:**
```bash
# Check received message volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "SuccessfulReceivedEvents" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Verify if command volume spike is expected (mass configuration update)
# 2. Check for command retry storms
# 3. Review command expiration and TTL settings
# 4. Ensure devices are properly acknowledging commands
# 5. Optimize command batching strategies
```

### HTTP Protocol Alerts

#### 4. HTTP Requests Alert
- **Metric**: `Mqtt.RequestCount`
- **Threshold**: 1,000 requests per window (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Description**: Monitors HTTP-based event ingestion volume
- **Use Case**: HTTP publish volume tracking, capacity planning

**What to do when this alert fires:**
```bash
# Check HTTP request volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.RequestCount" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Verify HTTP request patterns
# 2. Check for retry storms from HTTP publishers
# 3. Review HTTP response codes for errors
# 4. Consider batching HTTP publish operations
# 5. Monitor for DDoS or abnormal traffic patterns
```

### Error and Failure Alerts

#### 5. Routing Failures Alert
- **Metric**: `Mqtt.FailedRoutedMessages`
- **Threshold**: 1 failure (default)
- **Severity**: 1 (Error)
- **Aggregation**: Total
- **Description**: **CRITICAL** - Detects failures in event routing to subscriptions
- **Use Case**: Message delivery guarantee, data loss prevention

**What to do when this alert fires:**
```bash
# Check routing failures
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.FailedRoutedMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# Check topic space and subscription configuration
az eventgrid namespace topic-space list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name>

az eventgrid namespace topic-space subscription list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --topic-space-name <topic-space-name>

# Actions (URGENT - data loss risk):
# 1. Verify all topic spaces are properly configured
# 2. Check subscription filter expressions for errors
# 3. Verify destination endpoints are reachable
# 4. Check for topic pattern mismatches
# 5. Review event schema compatibility
# 6. Enable dead-letter queue if not already configured
# 7. Check for permission issues on destination resources
```

#### 6. Authentication Failures Alert
- **Metric**: `Mqtt.FailedWebhookAuthenticationRequests`
- **Threshold**: 5 failures (default)
- **Severity**: 1 (Error)
- **Aggregation**: Total
- **Description**: **SECURITY** - Detects authentication failures (certificates, tokens, Azure AD)
- **Use Case**: Security monitoring, brute force detection, certificate expiration tracking

**What to do when this alert fires:**
```bash
# Check authentication metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.FailedWebhookAuthenticationRequests" \
  --start-time <start-time> \
  --end-time <end-time>

# Review authentication configuration
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "properties.topicsConfiguration.mqttConfiguration"

# Actions (SECURITY INCIDENT):
# 1. Identify failing client IDs from logs
# 2. Check certificate expiration dates
# 3. Verify SAS token validity and rotation
# 4. Review Azure AD authentication configuration
# 5. Look for brute force patterns (blocked IPs)
# 6. Rotate credentials if compromise suspected
# 7. Enable diagnostic logs for detailed failure analysis
# 8. Update client certificates before expiration
```

#### 7. Connection Failures Alert
- **Metric**: `Mqtt.DroppedSessions`
- **Threshold**: 10 dropped sessions (default)
- **Severity**: 1 (Error)
- **Aggregation**: Total
- **Description**: Detects unexpected connection drops and session terminations
- **Use Case**: Connection stability monitoring, network issue detection

**What to do when this alert fires:**
```bash
# Check dropped session metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.DroppedSessions" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Check network connectivity issues
# 2. Review keep-alive settings on devices
# 3. Verify session expiration timeouts
# 4. Check for resource exhaustion (connection limits)
# 5. Look for protocol violations causing disconnects
# 6. Review firewall and NSG rules
# 7. Check for DNS resolution issues
# 8. Monitor regional Azure service health
```

### Performance and Throttling Alerts

#### 8. Throttled Requests Alert
- **Metric**: `Mqtt.ThrottlingEnforcements`
- **Threshold**: 50 throttling events (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Description**: **CAPACITY** - Detects rate limiting due to quota exhaustion
- **Use Case**: Capacity planning, scaling triggers, performance optimization

**What to do when this alert fires:**
```bash
# Check throttling metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.ThrottlingEnforcements" \
  --start-time <start-time> \
  --end-time <end-time>

# Check namespace tier and limits
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "{name:name, sku:sku, capacity:properties.capacity}"

# Actions:
# 1. Review namespace tier limits (Basic, Standard, Premium)
# 2. Check current throughput unit allocation
# 3. Increase throughput units if consistently throttled
# 4. Implement message rate limiting at device level
# 5. Optimize message payload sizes
# 6. Consider scaling to Premium tier for higher limits
# 7. Distribute load across multiple namespaces
# 8. Review and optimize topic space routing rules
```

#### 9. Message Latency Alert
- **Metric**: `PublishLatencyInMilliseconds`
- **Threshold**: 1,000 ms (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Description**: Monitors end-to-end publish latency for messages
- **Use Case**: SLA monitoring, performance optimization, user experience

**What to do when this alert fires:**
```bash
# Check latency metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "PublishLatencyInMilliseconds" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Actions:
# 1. Check regional service health and latency
# 2. Review message payload sizes (large payloads = higher latency)
# 3. Check for throttling (throttling increases latency)
# 4. Verify network path between devices and namespace
# 5. Consider using Premium tier for lower latency
# 6. Optimize message serialization/deserialization
# 7. Review event routing complexity
# 8. Check for resource contention on destination endpoints
```

#### 10. Topic Space Usage Alert
- **Metric**: `UnmatchedEventCount` (placeholder - original metric doesn't exist)
- **Threshold**: 80% (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Status**: **Currently Disabled** (count = 0)
- **Description**: Monitors topic space capacity utilization
- **Note**: This alert is disabled until the correct capacity metric is identified by Azure

---

## Alert Severity Levels

| Severity | Level | Use Case | Example Alerts |
|----------|-------|----------|----------------|
| **0** | Critical | Service outage, data loss imminent | None in this module |
| **1** | Error | Functional failures, security issues | Routing Failures, Authentication Failures, Connection Failures |
| **2** | Warning | Performance degradation, approaching limits | MQTT Connections, HTTP Requests, Throttled Requests, Message Latency |
| **3** | Informational | Awareness, trend monitoring | MQTT Messages Published, MQTT Messages Received |
| **4** | Verbose | Detailed diagnostics | None in this module |

**Severity Guidelines:**
- **Severity 1** alerts require **immediate investigation** (security, data loss, service failure)
- **Severity 2** alerts require **timely response** (performance, capacity planning)
- **Severity 3** alerts are **informational** (trends, usage patterns)

---

## Cost Analysis

### Alert Costs

**Azure Monitor Pricing (as of 2024):**
- Metric Alerts: **$0.10 per month** per alert rule
- Dynamic Threshold Alerts: **$0.20 per month** per alert rule
- Scheduled Query Rules: **$0.10 per month** per alert rule

**This Module Cost Calculation:**
- **10 Metric Alerts** (9 enabled + 1 disabled)
- **Cost per namespace**: 9 alerts × $0.10 = **$0.90/month**
- **Cost for 3 namespaces**: 3 × $0.90 = **$2.70/month**
- **Annual cost for 3 namespaces**: **$32.40/year**

### Event Grid Namespace Costs

**Event Grid Namespace Pricing:**
- **Basic Tier**: 
  - First 100K messages: Free
  - Additional messages: $0.30 per million messages
  - Max 10 connections
  
- **Standard Tier**:
  - First 100K messages: Free
  - Additional messages: $0.50 per million messages
  - Up to 100 connections
  - MQTT support, routing, filtering
  
- **Premium Tier**:
  - First 100K messages: Free
  - Additional messages: $1.00 per million messages
  - Unlimited connections
  - Lower latency, higher throughput
  - Private endpoints, availability zones

**Example Monthly Costs (Standard Tier):**
```
10 million MQTT messages/month:
- First 100K: Free
- Remaining 9.9M: 9.9 × $0.50 = $4.95/month

100 million messages/month:
- First 100K: Free
- Remaining 99.9M: 99.9 × $0.50 = $49.95/month
```

### ROI Analysis

**Scenario: IoT Device Fleet with 50,000 Devices**

**Without Monitoring:**
- Average downtime per incident: 2 hours
- Incidents per month: 3
- Revenue loss: $10,000/hour
- **Monthly loss**: 2 hours × 3 incidents × $10,000 = **$60,000**

**With Comprehensive Monitoring:**
- Alert cost: $0.90/month per namespace
- Early detection reduces MTTR by 80% (2 hours → 24 minutes)
- Prevented downtime: 1.6 hours × 3 incidents = 4.8 hours
- **Monthly savings**: 4.8 hours × $10,000 = **$48,000**

**ROI Calculation:**
```
Monthly Investment: $0.90
Monthly Benefit: $48,000
Monthly Net Benefit: $47,999.10
ROI: (47,999.10 / 0.90) × 100 = 5,332,122%
Annual ROI: $575,989.20 savings vs $10.80 cost
```

**Additional Benefits:**
- Reduced incident response time (80% improvement)
- Proactive capacity planning (prevents throttling)
- Security threat detection (authentication failures)
- Compliance and audit trail
- Customer satisfaction from reliable IoT services

---

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive monitoring and troubleshooting, enable diagnostic settings on your Event Grid Namespace resources. While metric alerts monitor performance thresholds, diagnostic settings provide detailed logs for MQTT connection analysis, message tracing, and error investigation.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings for Event Grid Namespace via Azure CLI
az monitor diagnostic-settings create \
  --name "eventgrid-namespace-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.EventGrid/namespaces/{namespace-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"MqttDisconnections","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"PublishedMessages","enabled":true,"retentionPolicy":{"days":7,"enabled":true}},
    {"category":"DeliveryFailures","enabled":true,"retentionPolicy":{"days":30,"enabled":true}},
    {"category":"RoutingLogs","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "eventgrid_namespace_diagnostics" {
  for_each                   = toset(var.eventgrid_namespace_names)
  name                       = "eventgrid-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_eventgrid_namespace.namespaces[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # MQTT Disconnections - Connection issues
  enabled_log {
    category = "MqttDisconnections"
  }

  # Published Messages - Message flow tracking
  enabled_log {
    category = "PublishedMessages"
  }

  # Delivery Failures - Routing errors
  enabled_log {
    category = "DeliveryFailures"
  }

  # Routing Logs - Event routing decisions
  enabled_log {
    category = "RoutingLogs"
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
| **MqttDisconnections** | MQTT client disconnection events, reasons, patterns | **Always** - Critical for IoT troubleshooting |
| **PublishedMessages** | Message publish events, topics, sizes | **Production** - High volume, use sampling |
| **DeliveryFailures** | Failed message deliveries, routing errors | **Always** - Essential for reliability |
| **RoutingLogs** | Event routing decisions, filter matches | **When needed** - Troubleshooting routing |

#### Useful Log Analytics Queries

```kusto
// MQTT disconnection analysis
AzureDiagnostics
| where Category == "MqttDisconnections"
| where TimeGenerated > ago(24h)
| summarize DisconnectionCount = count() by DisconnectionReason_s, ClientId_s
| order by DisconnectionCount desc

// Message delivery failures
AzureDiagnostics
| where Category == "DeliveryFailures"
| where TimeGenerated > ago(24h)
| summarize FailureCount = count() by FailureReason_s, SubscriptionName_s
| order by FailureCount desc

// Published message volume by topic
AzureDiagnostics
| where Category == "PublishedMessages"
| where TimeGenerated > ago(1h)
| summarize MessageCount = count(), TotalBytes = sum(MessageSize_d) by TopicName_s
| order by MessageCount desc

// MQTT connection count trends
AzureMetrics
| where ResourceProvider == "MICROSOFT.EVENTGRID"
| where MetricName == "MqttV5Connections"
| where TimeGenerated > ago(24h)
| summarize AvgConnections = avg(Total) by bin(TimeGenerated, 5m), Resource
| render timechart
```

### 2. IoT and MQTT Workloads

#### Connection Management
- Implement exponential backoff for connection retries
- Use persistent sessions (Clean Session = false) for reliable delivery
- Configure appropriate keep-alive intervals (60-300 seconds)
- Monitor connection storms during device rollouts
- Implement connection pooling for backend services

#### Message Optimization
- Keep message payloads small (<4KB ideal, <64KB max)
- Use message batching when possible
- Implement message compression for large payloads
- Use QoS 0 for non-critical telemetry (lower latency)
- Use QoS 1 for critical commands (guaranteed delivery)

#### Device Authentication
- Use X.509 certificates for production (better security)
- Implement certificate rotation policies (90-day cycle)
- Monitor certificate expiration dates proactively
- Use per-device certificates (not shared credentials)
- Implement certificate revocation procedures

#### Capacity Planning
- Monitor connection count trends weekly
- Plan for 2x expected peak connections
- Review message volume trends for scaling decisions
- Test throttling behavior under load
- Implement gradual device onboarding (not all at once)

### 3. Alert Response Procedures

#### Severity 1 (Critical) - Immediate Response
- **Routing Failures** → Check subscription filters, verify endpoints, review dead-letter queue
- **Authentication Failures (High Rate)** → Investigate security threat, review certificate validity
- **Throttling** → Scale namespace tier, optimize message rate

**Response Time**: < 15 minutes  
**Escalation**: Page on-call engineer + IoT operations team

**Immediate Actions**:
1. Check namespace health status
2. Review recent configuration changes
3. Analyze error logs for patterns
4. Verify downstream endpoint availability
5. Check for certificate expiration

#### Severity 2 (Warning) - Review Within 1 Hour
- **High MQTT Connections** → Monitor for capacity, plan scaling
- **High Message Publish Rate** → Review for abnormal patterns
- **Elevated Latency** → Investigate performance bottlenecks

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Severity 3 (Informational) - Review During Business Hours
- **HTTP Request Volume** → Capacity planning
- **Message Delivery Trends** → Performance optimization

**Response Time**: Next business day  
**Escalation**: Log for review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on all Event Grid Namespaces
- [ ] Configure Log Analytics workspace retention (30 days for errors, 7 days for messages)
- [ ] Set up action groups for IoT operations team
- [ ] Customize alert thresholds based on device fleet size
- [ ] Test alert notifications to verify delivery
- [ ] Document escalation procedures
- [ ] Configure dead-letter queues for all subscriptions

#### Ongoing Operations
- [ ] Review MQTT disconnection patterns weekly
- [ ] Analyze message delivery failures daily
- [ ] Review alert thresholds monthly based on growth
- [ ] Update alert rules for new namespaces
- [ ] Validate action group membership monthly
- [ ] Monitor device certificate expiration dates
- [ ] Review routing filter effectiveness quarterly

#### Performance & Optimization
- [ ] Establish message volume baselines
- [ ] Optimize MQTT topic hierarchy
- [ ] Review and tune subscription filters
- [ ] Monitor connection patterns for optimization
- [ ] Analyze throttling events for capacity planning
- [ ] Document common failure scenarios and resolutions

### Event Routing and Delivery (Continued)
   - Use hierarchical topic naming: `devices/{deviceId}/telemetry`
   - Separate topics by data type: telemetry, commands, alerts
   - Implement topic access controls per device identity
   - Use wildcards efficiently: `devices/+/telemetry`
   - Document topic taxonomy for operations teams

2. **Subscription Filters**
   - Keep filter expressions simple (better performance)
   - Test filter logic before production deployment
   - Monitor unmatched event count (missing subscriptions)
   - Implement catch-all subscription for troubleshooting
   - Use subject filtering over payload filtering when possible

3. **Error Handling**
   - Configure dead-letter queues for all subscriptions
   - Implement retry policies with exponential backoff
   - Monitor routing failure metrics closely (Severity 1)
   - Set up alerting for dead-letter queue depth
   - Implement manual replay procedures for failed events

4. **Delivery Guarantees**
   - Use QoS 1 for at-least-once delivery
   - Implement idempotency in downstream processors
   - Monitor delivery success rates
   - Configure appropriate message TTL
   - Test failover scenarios regularly

### Security and Authentication

1. **Authentication Strategy**
   - Use X.509 certificates in production
   - Implement certificate pinning on devices
   - Rotate SAS tokens every 30 days (if used)
   - Enable Azure AD authentication for backend services
   - Monitor authentication failure patterns (Severity 1 alert)

2. **Authorization**
   - Implement least-privilege topic access
   - Use per-device identity for authorization
   - Regularly audit topic access policies
   - Implement device decommissioning procedures
   - Test authorization rules before deployment

3. **Network Security**
   - Use TLS 1.2 or higher for all connections
   - Implement IP filtering where applicable
   - Use Private Endpoints for sensitive workloads
   - Enable diagnostic logging for audit trails
   - Monitor connection sources for anomalies

4. **Threat Detection**
   - Monitor authentication failure spikes (potential brute force)
   - Track connection failures for DDoS patterns
   - Implement rate limiting at device level
   - Use Azure Sentinel for advanced threat detection
   - Correlate security events across services

### Performance Optimization

1. **Latency Optimization**
   - Deploy namespaces in regions close to devices
   - Use Premium tier for latency-sensitive workloads
   - Optimize message payload serialization
   - Implement edge processing where applicable
   - Monitor latency percentiles (p50, p95, p99)

2. **Throughput Optimization**
   - Use message batching for high-volume scenarios
   - Implement parallel processing in consumers
   - Scale throughput units based on load
   - Monitor throttling metrics proactively
   - Distribute load across multiple namespaces

3. **Resource Efficiency**
   - Right-size namespace tier based on actual usage
   - Implement message retention policies
   - Clean up unused topic spaces and subscriptions
   - Monitor unmatched event count (wasted processing)
   - Optimize filter expressions for performance

4. **Monitoring and Observability**
   - Enable diagnostic logging to Log Analytics
   - Create custom dashboards for operations teams
   - Set up anomaly detection for baseline deviations
   - Implement distributed tracing for end-to-end visibility
   - Correlate metrics across device → namespace → downstream services

### Multi-Region and High Availability

1. **Geo-Redundancy**
   - Deploy namespaces in multiple Azure regions
   - Implement device-side failover logic
   - Use Traffic Manager for DNS-based routing
   - Test regional failover procedures quarterly
   - Monitor cross-region latency

2. **Disaster Recovery**
   - Document namespace configuration as code (Terraform)
   - Back up topic space and subscription configurations
   - Implement automated DR provisioning
   - Test full DR scenarios annually
   - Maintain DR runbooks with clear procedures

3. **Availability Zones**
   - Use Premium tier with availability zone support
   - Deploy redundant consumers across zones
   - Monitor zone-specific metrics
   - Test zone failure scenarios
   - Implement automatic zone failover

---

## Troubleshooting

### Common Issues

#### Issue 1: Alerts Not Firing Despite Breaching Thresholds

**Symptoms:**
- Metrics exceed thresholds but no notifications received
- Alert state shows "Not Activated" in Azure Portal

**Troubleshooting Steps:**
```bash
# 1. Verify alert is enabled
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name <alert-name> \
  --query "enabled"

# 2. Check action group configuration
az monitor action-group show \
  --resource-group <action-group-rg> \
  --name <action-group-name>

# 3. Verify metric data availability
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.Connections" \
  --start-time <start-time> \
  --end-time <end-time>

# 4. Check alert evaluation history
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name <alert-name> \
  --query "evaluationFrequency"
```

**Common Causes:**
- Alert disabled in Terraform configuration
- Action group email not confirmed
- Metric namespace typo
- Insufficient data points for evaluation
- Window duration too short for aggregation

**Resolution:**
- Enable alert: Set `enable_*_alert = true`
- Confirm action group emails
- Verify metric names match Azure documentation
- Increase `window_duration` for better aggregation
- Check diagnostic settings enabled on namespace

---

#### Issue 2: False Positive Alerts (Alert Fires Incorrectly)

**Symptoms:**
- Alerts fire frequently for expected behavior
- Metrics appear normal when investigating

**Troubleshooting Steps:**
```bash
# 1. Review metric values during alert
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.SuccessfulPublishedMessages" \
  --start-time <alert-time-minus-window> \
  --end-time <alert-time-plus-window> \
  --aggregation Total

# 2. Check for data gaps
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.Connections" \
  --interval PT1M \
  --start-time <start-time> \
  --end-time <end-time>

# 3. Review alert evaluation logic
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name <alert-name> \
  --query "criteria"
```

**Common Causes:**
- Threshold too low for workload patterns
- Aggregation type mismatch (Total vs Average)
- Window duration too short (spikes in short windows)
- Seasonal or time-based patterns not accounted for

**Resolution:**
```hcl
# Adjust threshold for your workload
eventgrid_mqtt_connections_threshold = 10000  # Increase from 1000

# Use longer evaluation window for stability
eventgrid_window_duration = "PT30M"  # Increase from PT15M

# Adjust evaluation frequency
eventgrid_evaluation_frequency = "PT15M"  # Less frequent evaluation
```

---

#### Issue 3: MQTT Connection Failures

**Symptoms:**
- Connection failures alert firing
- Devices unable to connect to namespace

**Troubleshooting Steps:**
```bash
# 1. Check namespace health
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "provisioningState"

# 2. Review dropped session metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.DroppedSessions" \
  --start-time <start-time> \
  --end-time <end-time>

# 3. Check authentication configuration
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "properties.topicsConfiguration.mqttConfiguration"

# 4. Enable diagnostic logging
az monitor diagnostic-settings create \
  --resource <namespace-resource-id> \
  --name "eventgrid-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "MqttConnectionEvents", "enabled": true}]'

# 5. Query connection logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "EventGridNamespaceLogs 
    | where Category == 'MqttConnectionEvents' 
    | where TimeGenerated > ago(1h) 
    | where Status == 'Failed' 
    | summarize count() by ReasonCode, bin(TimeGenerated, 5m)"
```

**Common Causes:**
- Certificate expiration
- Invalid SAS tokens
- Network connectivity issues
- Firewall blocking MQTT ports (8883, 1883)
- Connection limit exceeded for namespace tier
- Keep-alive timeouts

**Resolution:**
- Rotate expired certificates
- Regenerate SAS tokens
- Check NSG rules and firewall configuration
- Upgrade namespace tier if connection limits reached
- Adjust keep-alive settings on devices

---

#### Issue 4: Routing Failures (Data Loss Risk)

**Symptoms:**
- Routing failures alert firing (Severity 1)
- Events not reaching downstream subscribers

**Troubleshooting Steps:**
```bash
# 1. Check routing failure metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.FailedRoutedMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# 2. List topic spaces and subscriptions
az eventgrid namespace topic-space list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name>

az eventgrid namespace topic-space subscription list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --topic-space-name <topic-space-name>

# 3. Enable routing diagnostics
az monitor diagnostic-settings create \
  --resource <namespace-resource-id> \
  --name "routing-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "MqttRoutedMessages", "enabled": true}]'

# 4. Query routing failure logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "EventGridNamespaceLogs 
    | where Category == 'MqttRoutedMessages' 
    | where TimeGenerated > ago(1h) 
    | where RoutingStatus == 'Failed' 
    | summarize count() by FailureReason, TargetSubscription"
```

**Common Causes:**
- Subscription filter expression errors
- Topic pattern mismatches
- Destination endpoint unavailable
- Permission issues on destination (Event Hubs, Service Bus)
- Schema validation failures
- Dead-letter queue full

**Resolution:**
- Validate filter expressions with test events
- Update topic patterns to match published topics
- Verify destination endpoints are reachable
- Grant namespace managed identity access to destinations
- Enable dead-letter queue if not configured
- Implement retry policies with exponential backoff

---

#### Issue 5: High Message Latency

**Symptoms:**
- Message latency alert firing
- Slow event processing and delivery

**Troubleshooting Steps:**
```bash
# 1. Check latency metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "PublishLatencyInMilliseconds" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# 2. Check for throttling
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.ThrottlingEnforcements" \
  --start-time <start-time> \
  --end-time <end-time>

# 3. Check namespace tier and capacity
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "{name:name, sku:sku, capacity:properties.capacity}"

# 4. Review Azure service health
az rest --method get \
  --url "https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2020-05-01"
```

**Common Causes:**
- Throttling due to quota exhaustion
- Large message payloads (>64KB)
- Complex routing rules with many subscriptions
- Downstream consumer processing delays
- Network latency between device and namespace
- Regional service degradation

**Resolution:**
```hcl
# Upgrade to Premium tier for lower latency
# Scale throughput units
# Optimize message payload sizes (<4KB ideal)
# Simplify routing rules
# Deploy namespace closer to devices
# Implement message batching
```

---

#### Issue 6: Terraform Apply Failures

**Symptoms:**
- `terraform apply` fails with resource errors
- Alerts not created despite successful plan

**Common Error Messages:**
```
Error: Error creating Metric Alert: 
features.MetricAlertsClient#CreateOrUpdate: 
Failure responding to request: StatusCode=400
```

**Troubleshooting Steps:**
```bash
# 1. Validate Terraform syntax
terraform validate

# 2. Check Terraform plan output
terraform plan -out=tfplan
terraform show tfplan

# 3. Verify namespace exists
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name>

# 4. Verify action group exists
az monitor action-group show \
  --resource-group <action-group-rg> \
  --name <action-group-name>

# 5. Check Azure provider version
terraform version
```

**Common Causes:**
- Namespace names don't exist
- Action group not found
- Subscription ID incorrect
- Resource group mismatch
- Azure provider version too old
- Metric namespace typo

**Resolution:**
```hcl
# Verify namespace names exist
eventgrid_namespace_names = ["actual-namespace-name"]

# Use correct subscription ID
subscription_id = "12345678-1234-1234-1234-123456789012"

# Verify action group resource group
action_group_resource_group_name = "rg-monitoring-prod"

# Update Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}
```

---

### Validation Commands

```bash
# 1. List all Event Grid namespaces
az eventgrid namespace list \
  --resource-group <resource-group> \
  --output table

# 2. Get namespace details
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name>

# 3. List topic spaces
az eventgrid namespace topic-space list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --output table

# 4. List subscriptions in topic space
az eventgrid namespace topic-space subscription list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --topic-space-name <topic-space-name> \
  --output table

# 5. Check MQTT configuration
az eventgrid namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "properties.topicsConfiguration.mqttConfiguration"

# 6. List metric definitions
az monitor metrics list-definitions \
  --resource <namespace-resource-id>

# 7. Query specific metric
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Mqtt.Connections" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --interval PT5M

# 8. List all metric alerts
az monitor metrics alert list \
  --resource-group <resource-group> \
  --output table

# 9. Get alert details
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name <alert-name>

# 10. Test action group
az monitor action-group test-notifications create \
  --action-group <action-group-name> \
  --resource-group <resource-group> \
  --alert-type "Monitoring"

# 11. Enable diagnostic logging
az monitor diagnostic-settings create \
  --resource <namespace-resource-id> \
  --name "eventgrid-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[
    {"category": "MqttConnectionEvents", "enabled": true},
    {"category": "MqttRoutedMessages", "enabled": true},
    {"category": "MqttPublishEvents", "enabled": true}
  ]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# 12. Query logs for connection events
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "EventGridNamespaceLogs 
    | where Category == 'MqttConnectionEvents' 
    | where TimeGenerated > ago(1h) 
    | summarize count() by Status, bin(TimeGenerated, 5m) 
    | render timechart"

# 13. Query logs for routing failures
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "EventGridNamespaceLogs 
    | where Category == 'MqttRoutedMessages' 
    | where RoutingStatus == 'Failed' 
    | summarize count() by FailureReason 
    | order by count_ desc"

# 14. Check Azure service health
az resource show \
  --ids <namespace-resource-id> \
  --query "properties.provisioningState"

# 15. Validate Terraform deployment
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
