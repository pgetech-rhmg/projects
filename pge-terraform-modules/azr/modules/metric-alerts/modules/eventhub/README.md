# Azure Event Hub Monitoring Alerts - Terraform Module

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Production Configuration](#production-configuration)
  - [Multi-Namespace Deployment](#multi-namespace-deployment)
  - [Individual Event Hub Monitoring](#individual-event-hub-monitoring)
  - [Selective Alert Configuration](#selective-alert-configuration)
- [Input Variables](#input-variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
  - [Alert Configuration Variables](#alert-configuration-variables)
- [Alert Details](#alert-details)
  - [Request and Performance Alerts](#request-and-performance-alerts)
  - [Error Detection Alerts](#error-detection-alerts)
  - [Message Throughput Alerts](#message-throughput-alerts)
  - [Connection Management Alerts](#connection-management-alerts)
  - [Capacity and Quota Alerts](#capacity-and-quota-alerts)
- [Alert Severity Levels](#alert-severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
  - [Event Hub Design](#event-hub-design)
  - [Throughput and Scaling](#throughput-and-scaling)
  - [Consumer Groups](#consumer-groups)
  - [Partition Strategy](#partition-strategy)
  - [Error Handling](#error-handling)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Validation Commands](#validation-commands)
- [License](#license)

---

## Overview

This Terraform module provides comprehensive monitoring and alerting for **Azure Event Hubs**, a fully managed, real-time data ingestion service for streaming millions of events per second. Event Hubs is designed for big data streaming scenarios, event-driven architectures, and telemetry ingestion workloads.

The module implements the **Azure Monitor Baseline Alerts (AMBA)** best practices specifically tailored for Event Hub namespaces and individual Event Hubs, covering:
- **Request monitoring** - Incoming requests, successful requests, request patterns
- **Error detection** - Server errors, user errors, throttling
- **Message throughput** - Incoming/outgoing messages and bytes
- **Connection management** - Active connections, connection churn
- **Capacity planning** - Quota limits, storage size, throughput unit utilization

**Key Capabilities:**
- Monitors namespace-level and individual Event Hub metrics
- Tracks message ingestion and consumption patterns
- Detects errors, throttling, and capacity issues
- Identifies connection problems and connection storms
- Monitors storage capacity and quota limits
- Supports both Standard and Premium tier monitoring

This module is essential for organizations running streaming data pipelines, real-time analytics, event-driven microservices, IoT telemetry ingestion, and log aggregation workloads.

---

## Key Features

- **✅ 14 Metric Alerts** - Comprehensive coverage for requests, errors, messages, connections, and capacity
- **✅ Namespace-Level Monitoring** - Monitors entire Event Hub namespaces for aggregate metrics
- **✅ Individual Event Hub Monitoring** - Tracks storage size for specific Event Hubs
- **✅ Multi-Tier Support** - Works with Basic, Standard, and Premium tiers
- **✅ Error Detection** - Server errors, user errors, throttling, quota violations
- **✅ Throughput Monitoring** - Incoming/outgoing messages and bytes tracking
- **✅ Connection Tracking** - Active connections, connection open/close patterns
- **✅ Capacity Planning** - Storage size and quota exceeded monitoring
- **✅ Customizable Thresholds** - All alert thresholds are configurable per environment
- **✅ Production-Ready** - Follows Azure AMBA guidelines for enterprise deployments

---

## Prerequisites

Before using this module, ensure you have:

1. **Terraform >= 1.0** installed
2. **Azure Provider >= 3.0** configured
3. **Existing Azure Event Hub Namespace(s)** deployed
4. **Azure Monitor Action Group** created for alert notifications
5. **Appropriate Azure RBAC permissions**:
   - `Monitoring Contributor` role on the resource group
   - `Reader` role on Event Hub namespaces
   - Access to the action group for notifications

6. **Event Hub Requirements**:
   - Event Hub namespace deployed (Basic, Standard, or Premium tier)
   - Event Hubs created within namespace (if monitoring individual hubs)
   - Consumer groups configured
   - Throughput units allocated (Standard tier) or Processing units (Premium tier)

---

## Module Structure

```
eventhub/
├── alerts.tf       # Event Hub metric alert definitions
├── variables.tf    # Input variable definitions
└── README.md       # This documentation file
```

---

## Usage

### Basic Usage

```hcl
module "eventhub_alerts" {
  source = "./modules/metricAlerts/eventhub"

  # Resource targeting
  eventhub_namespace_names           = ["streaming-events-prod"]
  resource_group_name                = "rg-streaming-production"

  # Action group configuration
  action_group                       = "streaming-ops-actiongroup"
  action_group_resource_group_name   = "rg-monitoring"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Streaming-Platform"
    CostCenter         = "Engineering"
    DataClassification = "Internal"
    Owner              = "streaming-team@company.com"
  }
}
```

### Production Configuration

```hcl
module "eventhub_alerts_prod" {
  source = "./modules/metricAlerts/eventhub"

  # Multi-namespace monitoring
  eventhub_namespace_names = [
    "events-prod-west",
    "events-prod-east"
  ]
  resource_group_name                = "rg-events-production"

  # Action groups
  action_group                       = "events-critical-alerts"
  action_group_resource_group_name   = "rg-monitoring-prod"

  # Request Monitoring
  enable_eventhub_incoming_requests_alert = true
  eventhub_incoming_requests_threshold    = 100000  # 100K requests per window

  enable_eventhub_successful_requests_alert = true
  eventhub_successful_requests_threshold    = 1000  # Alert if too few

  # Error Monitoring (Critical)
  enable_eventhub_server_errors_alert = true
  eventhub_server_errors_threshold    = 1  # Alert on any server error

  enable_eventhub_user_errors_alert = true
  eventhub_user_errors_threshold    = 50  # User errors threshold

  enable_eventhub_throttled_requests_alert = true
  eventhub_throttled_requests_threshold    = 1  # Alert on any throttling

  # Message Throughput
  enable_eventhub_incoming_messages_alert = true
  eventhub_incoming_messages_threshold    = 500000  # 500K messages per window

  enable_eventhub_outgoing_messages_alert = true
  eventhub_outgoing_messages_threshold    = 500000

  # Data Volume
  enable_eventhub_incoming_bytes_alert = true
  eventhub_incoming_bytes_threshold    = 10737418240  # 10GB per window

  enable_eventhub_outgoing_bytes_alert = true
  eventhub_outgoing_bytes_threshold    = 10737418240  # 10GB

  # Connection Management
  enable_eventhub_active_connections_alert = true
  eventhub_active_connections_threshold    = 5000

  enable_eventhub_connections_opened_alert = true
  eventhub_connections_opened_threshold    = 10000

  enable_eventhub_connections_closed_alert = true
  eventhub_connections_closed_threshold    = 10000

  # Capacity Planning
  enable_eventhub_quota_exceeded_alert = true
  eventhub_quota_exceeded_threshold    = 1  # Alert immediately

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Event-Streaming"
    CostCenter         = "Operations"
    Compliance         = "SOC2"
    DR                 = "Critical"
    Owner              = "platform-team@company.com"
    AlertingSLA        = "24x7"
  }
}
```

### Multi-Namespace Deployment

```hcl
module "eventhub_alerts_multi_region" {
  source = "./modules/metricAlerts/eventhub"

  # Regional namespaces for geo-redundancy
  eventhub_namespace_names = [
    "telemetry-us-west",
    "telemetry-us-east",
    "telemetry-eu-west",
    "analytics-global"
  ]
  resource_group_name                = "rg-telemetry-global"

  # Tiered action groups
  action_group                       = "telemetry-pagerduty"
  action_group_resource_group_name   = "rg-alerting"

  # High-volume thresholds
  eventhub_incoming_requests_threshold = 1000000   # 1M requests
  eventhub_incoming_messages_threshold = 5000000   # 5M messages
  eventhub_incoming_bytes_threshold    = 107374182400  # 100GB

  # Zero tolerance for errors in production
  eventhub_server_errors_threshold     = 1
  eventhub_throttled_requests_threshold = 1
  eventhub_quota_exceeded_threshold    = 1

  # Connection monitoring for high-scale
  eventhub_active_connections_threshold = 10000
  eventhub_connections_opened_threshold = 50000

  tags = {
    Environment        = "Production"
    Application        = "Global-Telemetry"
    BusinessUnit       = "Analytics"
    CostCenter         = "Platform"
    Compliance         = "GDPR,SOC2"
    DataClassification = "Confidential"
    DR                 = "Mission-Critical"
    Owner              = "data-platform@company.com"
    SLA                = "99.95"
  }
}
```

### Individual Event Hub Monitoring

```hcl
module "eventhub_alerts_with_individual_hubs" {
  source = "./modules/metricAlerts/eventhub"

  # Namespace-level monitoring
  eventhub_namespace_names = [
    "orders-namespace-prod",
    "events-namespace-prod"
  ]
  resource_group_name                = "rg-events-production"

  # Individual Event Hub storage monitoring
  # Map structure: { "hub_name" = "namespace_name" }
  eventhub_configs = {
    "orders-events"      = "orders-namespace-prod"
    "inventory-events"   = "orders-namespace-prod"
    "customer-events"    = "events-namespace-prod"
    "analytics-events"   = "events-namespace-prod"
  }

  # Action group
  action_group                       = "events-ops-alerts"
  action_group_resource_group_name   = "rg-monitoring"

  # Enable size monitoring for individual hubs
  enable_eventhub_size_alert = true
  eventhub_size_threshold    = 85899345920  # 80GB (alert before 100GB limit)

  # Standard namespace-level alerts
  enable_eventhub_incoming_messages_alert = true
  enable_eventhub_server_errors_alert     = true
  enable_eventhub_throttled_requests_alert = true

  tags = {
    Environment = "Production"
    Application = "Order-Processing"
    Owner       = "orders-team@company.com"
  }
}
```

### Selective Alert Configuration

```hcl
module "eventhub_alerts_dev" {
  source = "./modules/metricAlerts/eventhub"

  # Development namespace
  eventhub_namespace_names           = ["events-dev"]
  resource_group_name                = "rg-events-dev"

  action_group                       = "dev-team-alerts"
  action_group_resource_group_name   = "rg-monitoring-dev"

  # Enable only critical alerts for dev
  enable_eventhub_incoming_requests_alert      = true
  enable_eventhub_successful_requests_alert    = false  # Not needed in dev
  enable_eventhub_server_errors_alert          = true   # Always monitor
  enable_eventhub_user_errors_alert            = false  # Disable for dev
  enable_eventhub_throttled_requests_alert     = true
  enable_eventhub_incoming_messages_alert      = true
  enable_eventhub_outgoing_messages_alert      = false  # Not critical
  enable_eventhub_incoming_bytes_alert         = false  # Not needed
  enable_eventhub_outgoing_bytes_alert         = false  # Not needed
  enable_eventhub_active_connections_alert     = true
  enable_eventhub_connections_opened_alert     = false  # Not needed
  enable_eventhub_connections_closed_alert     = false  # Not needed
  enable_eventhub_quota_exceeded_alert         = true
  enable_eventhub_size_alert                   = false  # Not critical

  # Relaxed thresholds for development
  eventhub_incoming_requests_threshold = 1000
  eventhub_server_errors_threshold     = 10
  eventhub_throttled_requests_threshold = 10
  eventhub_incoming_messages_threshold = 10000
  eventhub_active_connections_threshold = 100

  tags = {
    Environment = "Development"
    Application = "Event-Testing"
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
| `eventhub_namespace_names` | `list(string)` | List of Event Hub namespace names to monitor |
| `resource_group_name` | `string` | Resource group containing the Event Hub namespaces |
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `action_group` | `string` | Name of the Azure Monitor action group for notifications |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `eventhub_configs` | `map(string)` | `{}` | Map of Event Hub names to namespace names for individual hub monitoring |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `tags` | `map(string)` | See variables.tf | Resource tags for organization and cost tracking |

### Alert Configuration Variables

#### Alert Toggles

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_eventhub_incoming_requests_alert` | `bool` | `true` | Enable incoming requests monitoring |
| `enable_eventhub_successful_requests_alert` | `bool` | `true` | Enable successful requests monitoring (low threshold) |
| `enable_eventhub_server_errors_alert` | `bool` | `true` | Enable server errors detection |
| `enable_eventhub_user_errors_alert` | `bool` | `true` | Enable user errors detection |
| `enable_eventhub_throttled_requests_alert` | `bool` | `true` | Enable throttling detection |
| `enable_eventhub_incoming_messages_alert` | `bool` | `true` | Enable incoming message volume monitoring |
| `enable_eventhub_outgoing_messages_alert` | `bool` | `true` | Enable outgoing message volume monitoring |
| `enable_eventhub_incoming_bytes_alert` | `bool` | `true` | Enable incoming bytes monitoring |
| `enable_eventhub_outgoing_bytes_alert` | `bool` | `true` | Enable outgoing bytes monitoring |
| `enable_eventhub_active_connections_alert` | `bool` | `true` | Enable active connections monitoring |
| `enable_eventhub_connections_opened_alert` | `bool` | `true` | Enable connections opened monitoring |
| `enable_eventhub_connections_closed_alert` | `bool` | `true` | Enable connections closed monitoring |
| `enable_eventhub_quota_exceeded_alert` | `bool` | `true` | Enable quota exceeded detection |
| `enable_eventhub_size_alert` | `bool` | `true` | Enable Event Hub size monitoring (individual hubs) |
| `enable_eventhub_cpu_usage_alert` | `bool` | `true` | Enable CPU usage monitoring (Premium tier only) |

#### Alert Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `eventhub_incoming_requests_threshold` | `number` | `10000` | Incoming request count threshold |
| `eventhub_successful_requests_threshold` | `number` | `100` | Minimum successful request count |
| `eventhub_server_errors_threshold` | `number` | `1` | Server error count threshold |
| `eventhub_user_errors_threshold` | `number` | `10` | User error count threshold |
| `eventhub_throttled_requests_threshold` | `number` | `1` | Throttled request count threshold |
| `eventhub_incoming_messages_threshold` | `number` | `50000` | Incoming message count threshold |
| `eventhub_outgoing_messages_threshold` | `number` | `50000` | Outgoing message count threshold |
| `eventhub_incoming_bytes_threshold` | `number` | `1073741824` | Incoming bytes threshold (1GB default) |
| `eventhub_outgoing_bytes_threshold` | `number` | `1073741824` | Outgoing bytes threshold (1GB default) |
| `eventhub_active_connections_threshold` | `number` | `1000` | Active connection count threshold |
| `eventhub_connections_opened_threshold` | `number` | `5000` | Connections opened count threshold |
| `eventhub_connections_closed_threshold` | `number` | `5000` | Connections closed count threshold |
| `eventhub_quota_exceeded_threshold` | `number` | `1` | Quota exceeded error count threshold |
| `eventhub_size_threshold` | `number` | `85899345920` | Event Hub size threshold (80GB default) |

---

## Alert Details

### Request and Performance Alerts

#### 1. Incoming Requests Alert
- **Metric**: `IncomingRequests`
- **Threshold**: 10,000 requests (default)
- **Severity**: 3 (Informational)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: Monitors total number of incoming requests to the Event Hub namespace
- **Use Case**: Capacity planning, workload trending, cost optimization

**What to do when this alert fires:**
```bash
# Check incoming request volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingRequests" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Verify if request spike is expected (new application deployment)
# 2. Check for retry storms from producers
# 3. Review throughput unit allocation
# 4. Monitor for throttling events
# 5. Consider scaling throughput units if sustained high volume
```

#### 2. Successful Requests Alert (Low)
- **Metric**: `SuccessfulRequests`
- **Threshold**: < 100 requests (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT15M
- **Window**: PT30M
- **Aggregation**: Total
- **Description**: **ANOMALY** - Detects unusually low successful request counts (potential service issue)
- **Use Case**: Service health monitoring, early degradation detection

**What to do when this alert fires:**
```bash
# Check successful request trends
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "SuccessfulRequests" \
  --start-time <start-time> \
  --end-time <end-time>

# Check for errors
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ServerErrors" \
  --start-time <start-time> \
  --end-time <end-time>

az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "UserErrors" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions (INVESTIGATE):
# 1. Check if producers have stopped sending events
# 2. Review server and user error metrics
# 3. Check Event Hub namespace health
# 4. Verify network connectivity from producers
# 5. Review Azure service health for regional issues
# 6. Check authentication and authorization settings
# 7. Validate producer application health
```

### Error Detection Alerts

#### 3. Server Errors Alert
- **Metric**: `ServerErrors`
- **Threshold**: 1 error (default)
- **Severity**: 1 (Error)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: **CRITICAL** - Detects server-side errors in Event Hub namespace
- **Use Case**: Service health monitoring, incident detection

**What to do when this alert fires:**
```bash
# Check server error metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ServerErrors" \
  --start-time <start-time> \
  --end-time <end-time>

# Check namespace status
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "provisioningState"

# Enable diagnostic logs
az monitor diagnostic-settings create \
  --resource <namespace-resource-id> \
  --name "eventhub-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "OperationalLogs", "enabled": true}]'

# Actions (URGENT):
# 1. Check Azure service health dashboard
# 2. Review operational logs for error details
# 3. Verify namespace configuration
# 4. Check for resource exhaustion
# 5. Open Azure support ticket if persistent
# 6. Implement retry logic in producers if transient
```

#### 4. User Errors Alert
- **Metric**: `UserErrors`
- **Threshold**: 10 errors (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Description**: Detects client-side errors (authentication, authorization, invalid requests)
- **Use Case**: Client configuration issues, security monitoring

**What to do when this alert fires:**
```bash
# Check user error metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "UserErrors" \
  --start-time <start-time> \
  --end-time <end-time>

# Query operational logs for error details
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where ResourceProvider == 'MICROSOFT.EVENTHUB' 
    | where Category == 'OperationalLogs' 
    | where TimeGenerated > ago(1h) 
    | where Status == 'Failed' 
    | summarize count() by OperationName, ErrorCode"

# Actions:
# 1. Review authentication errors (expired tokens, invalid SAS)
# 2. Check authorization errors (insufficient permissions)
# 3. Validate producer connection strings
# 4. Review Event Hub access policies
# 5. Check for malformed event data
# 6. Verify partition key validity
# 7. Update client SDK versions if outdated
```

#### 5. Throttled Requests Alert
- **Metric**: `ThrottledRequests`
- **Threshold**: 1 request (default)
- **Severity**: 2 (Warning)
- **Aggregation**: Total
- **Description**: **CAPACITY** - Detects throttling due to throughput unit limits
- **Use Case**: Capacity planning, scaling triggers

**What to do when this alert fires:**
```bash
# Check throttling metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ThrottledRequests" \
  --start-time <start-time> \
  --end-time <end-time>

# Check throughput unit allocation
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "{name:name, sku:sku, maximumThroughputUnits:maximumThroughputUnits}"

# Actions (IMMEDIATE):
# 1. Increase throughput units (Standard tier)
# 2. Enable auto-inflate if not already enabled
# 3. Review maximum throughput unit limits
# 4. Consider upgrading to Premium tier for higher limits
# 5. Implement backoff/retry logic in producers
# 6. Review partition strategy (more partitions = higher throughput)
# 7. Monitor incoming bytes and message rates
# 8. Optimize message batch sizes
```

### Message Throughput Alerts

#### 6. Incoming Messages Alert
- **Metric**: `IncomingMessages`
- **Threshold**: 50,000 messages (default)
- **Severity**: 3 (Informational)
- **Frequency**: PT15M
- **Window**: PT30M
- **Aggregation**: Total
- **Description**: Monitors volume of messages ingested into Event Hub
- **Use Case**: Capacity planning, cost monitoring, trend analysis

**What to do when this alert fires:**
```bash
# Check incoming message volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Verify if message spike is expected
# 2. Review message ingestion patterns
# 3. Check for message duplication
# 4. Monitor throttling events
# 5. Review cost implications (messages are billed)
# 6. Consider message batching optimization
```

#### 7. Outgoing Messages Alert
- **Metric**: `OutgoingMessages`
- **Threshold**: 50,000 messages (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors volume of messages consumed from Event Hub
- **Use Case**: Consumer health monitoring, processing lag detection

**What to do when this alert fires:**
```bash
# Check outgoing message volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "OutgoingMessages" \
  --start-time <end-time> \
  --end-time <end-time>

# Compare ingestion vs consumption
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingMessages,OutgoingMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Compare incoming vs outgoing (detect consumer lag)
# 2. Check consumer group health
# 3. Scale out consumer applications if lagging
# 4. Review partition distribution across consumers
# 5. Monitor consumer checkpoint frequency
```

#### 8. Incoming Bytes Alert
- **Metric**: `IncomingBytes`
- **Threshold**: 1,073,741,824 bytes (1GB default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors data volume ingested (bytes)
- **Use Case**: Bandwidth monitoring, cost optimization

**What to do when this alert fires:**
```bash
# Check incoming byte volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingBytes" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Review message payload sizes
# 2. Implement message compression if large payloads
# 3. Monitor throughput unit utilization
# 4. Check for throttling due to bandwidth limits
```

#### 9. Outgoing Bytes Alert
- **Metric**: `OutgoingBytes`
- **Threshold**: 1,073,741,824 bytes (1GB default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors data volume consumed (bytes)
- **Use Case**: Consumer bandwidth monitoring

**What to do when this alert fires:**
```bash
# Check outgoing byte volume
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "OutgoingBytes" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Verify consumer processing capacity
# 2. Check network bandwidth availability
# 3. Monitor consumer application health
```

### Connection Management Alerts

#### 10. Active Connections Alert
- **Metric**: `ActiveConnections`
- **Threshold**: 1,000 connections (default)
- **Severity**: 3 (Informational)
- **Frequency**: PT15M
- **Window**: PT30M
- **Aggregation**: Average
- **Description**: Monitors current number of active connections
- **Use Case**: Capacity planning, connection limit monitoring

**What to do when this alert fires:**
```bash
# Check active connections
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ActiveConnections" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Check connection limits for tier
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "sku"

# Actions:
# 1. Review connection limits for your tier (5000 for Standard)
# 2. Implement connection pooling in applications
# 3. Check for connection leaks
# 4. Consider upgrading to Premium tier (unlimited connections)
# 5. Monitor connection opened/closed patterns
```

#### 11. Connections Opened Alert
- **Metric**: `ConnectionsOpened`
- **Threshold**: 5,000 connections (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors new connections established
- **Use Case**: Connection pattern analysis, detecting connection storms

**What to do when this alert fires:**
```bash
# Check connection open rate
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ConnectionsOpened" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Check for connection storms (rapid connect/disconnect)
# 2. Implement connection reuse in applications
# 3. Review connection lifecycle management
# 4. Monitor for application restarts causing reconnects
```

#### 12. Connections Closed Alert
- **Metric**: `ConnectionsClosed`
- **Threshold**: 5,000 connections (default)
- **Severity**: 3 (Informational)
- **Aggregation**: Total
- **Description**: Monitors connections closed
- **Use Case**: Connection stability analysis

**What to do when this alert fires:**
```bash
# Check connection close rate
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ConnectionsClosed" \
  --start-time <start-time> \
  --end-time <end-time>

# Compare opened vs closed
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ConnectionsOpened,ConnectionsClosed" \
  --start-time <start-time> \
  --end-time <end-time>

# Actions:
# 1. Check if connections are being closed prematurely
# 2. Review idle timeout settings
# 3. Check for network instability
# 4. Monitor for application errors causing disconnects
```

### Capacity and Quota Alerts

#### 13. Quota Exceeded Errors Alert
- **Metric**: `QuotaExceededErrors`
- **Threshold**: 1 error (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: **CAPACITY** - Detects quota violations (partitions, consumer groups, etc.)
- **Use Case**: Capacity limit monitoring

**What to do when this alert fires:**
```bash
# Check quota exceeded errors
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "QuotaExceededErrors" \
  --start-time <start-time> \
  --end-time <end-time>

# Check namespace limits
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name>

# List Event Hubs in namespace
az eventhubs eventhub list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name>

# Actions (URGENT):
# 1. Check partition count limits (32 for Standard, 100+ for Premium)
# 2. Review consumer group limits (20 for Standard)
# 3. Check Event Hub count limits (10 for Basic, 1000+ for higher tiers)
# 4. Upgrade namespace tier if hitting limits
# 5. Consolidate consumer groups if possible
# 6. Review operational logs for specific quota violation
```

#### 14. Event Hub Size Alert (Individual Hubs)
- **Metric**: `Size`
- **Threshold**: 85,899,345,920 bytes (80GB default)
- **Severity**: 2 (Warning)
- **Frequency**: PT15M
- **Window**: PT30M
- **Aggregation**: Average
- **Dimension**: `EntityName` (filters specific Event Hubs)
- **Description**: **CAPACITY** - Monitors storage usage for individual Event Hubs
- **Use Case**: Prevent data loss from reaching 100GB limit (Standard tier)

**What to do when this alert fires:**
```bash
# Check Event Hub size
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Size" \
  --start-time <start-time> \
  --end-time <end-time> \
  --filter "EntityName eq '<event-hub-name>'"

# Check retention settings
az eventhubs eventhub show \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <event-hub-name> \
  --query "messageRetentionInDays"

# Actions (URGENT - data loss risk):
# 1. Reduce message retention period (default 7 days)
# 2. Scale up consumers to process messages faster
# 3. Check for consumer lag (messages not being read)
# 4. Consider archiving to Azure Storage (Capture feature)
# 5. Upgrade to Premium tier for larger storage (1TB+)
# 6. Add more partitions to distribute storage
# 7. Review event data for unnecessary large payloads
```

---

## Alert Severity Levels

| Severity | Level | Use Case | Example Alerts |
|----------|-------|----------|----------------|
| **0** | Critical | Service outage, data loss imminent | None in this module |
| **1** | Error | Functional failures, service degradation | Server Errors |
| **2** | Warning | Performance issues, approaching limits | Successful Requests (Low), User Errors, Throttled Requests, Quota Exceeded, Event Hub Size |
| **3** | Informational | Awareness, trend monitoring | Incoming Requests, Messages, Bytes, Connections |
| **4** | Verbose | Detailed diagnostics | None in this module |

**Severity Guidelines:**
- **Severity 1** alerts require **immediate investigation** (service failure)
- **Severity 2** alerts require **timely response** (capacity, performance degradation)
- **Severity 3** alerts are **informational** (trends, usage patterns)

---

## Cost Analysis

### Alert Costs

**Azure Monitor Pricing (as of 2024):**
- Metric Alerts: **$0.10 per month** per alert rule
- Dynamic Threshold Alerts: **$0.20 per month** per alert rule

**This Module Cost Calculation:**
- **14 Metric Alerts** configured
- **Cost per namespace**: 14 alerts × $0.10 = **$1.40/month**
- **Cost for 3 namespaces**: 3 × $1.40 = **$4.20/month**
- **Annual cost for 3 namespaces**: **$50.40/year**

### Event Hub Costs

**Event Hub Namespace Pricing (Standard Tier):**
- **Throughput Units**: $0.028/hour per TU (~$20/month per TU)
- **Ingress**: First 1GB/day free, then $0.028/GB
- **Messages**: First 1M events free, then $0.02 per million events
- **Capture** (optional): $0.10/hour when enabled + Storage costs

**Example Monthly Costs:**
```
Standard Tier with 5 Throughput Units:
- Throughput Units: 5 × $20 = $100/month
- Messages: 100M events - 1M = 99M × $0.02/million = $1.98/month
- Ingress: 100GB - 1GB = 99GB × $0.028 = $2.77/month
- Total: ~$105/month

Premium Tier (1 Processing Unit):
- Base cost: ~$680/month
- Includes: Unlimited TUs, dedicated resources, 1TB storage
- Better for high-throughput, mission-critical workloads
```

### ROI Analysis

**Scenario: Streaming Analytics Platform with 100M Events/Month**

**Without Monitoring:**
- Average downtime per incident: 3 hours
- Incidents per month: 2
- Revenue loss: $15,000/hour
- **Monthly loss**: 3 hours × 2 incidents × $15,000 = **$90,000**

**With Comprehensive Monitoring:**
- Alert cost: $1.40/month per namespace
- Early detection reduces MTTR by 75% (3 hours → 45 minutes)
- Prevented downtime: 2.25 hours × 2 incidents = 4.5 hours
- **Monthly savings**: 4.5 hours × $15,000 = **$67,500**

**ROI Calculation:**
```
Monthly Investment: $1.40
Monthly Benefit: $67,500
Monthly Net Benefit: $67,498.60
ROI: (67,498.60 / 1.40) × 100 = 4,821,328%
Annual ROI: $809,983.20 savings vs $16.80 cost
```

**Additional Benefits:**
- Prevents data loss from reaching storage limits
- Early throttling detection prevents message loss
- Consumer lag detection improves processing SLAs
- Connection monitoring prevents application failures
- Capacity planning prevents quota violations

---

## Best Practices

### Event Hub Design

1. **Namespace Organization**
   - Group related Event Hubs in the same namespace
   - Separate production, staging, and development namespaces
   - Use separate namespaces for different business domains
   - Consider regional namespaces for geo-distributed applications

2. **Event Hub Configuration**
   - Use meaningful Event Hub names (e.g., `orders-events`, `telemetry-events`)
   - Set appropriate partition counts (more partitions = higher throughput)
   - Configure retention based on consumer processing speed (1-7 days)
   - Enable Capture for long-term storage and analytics

3. **Security**
   - Use Shared Access Signatures (SAS) with minimal permissions
   - Implement Azure AD authentication for enhanced security
   - Use separate policies for producers and consumers
   - Enable Virtual Network integration for network isolation
   - Rotate SAS keys regularly (every 90 days)

### Throughput and Scaling

1. **Throughput Units (Standard Tier)**
   - Start with auto-inflate enabled
   - Set maximum TUs based on expected peak load × 2
   - Monitor throttling metrics closely
   - Each TU provides: 1 MB/s ingress, 2 MB/s egress
   - Increase TUs when throttling occurs

2. **Processing Units (Premium Tier)**
   - Use for mission-critical workloads
   - Provides dedicated compute and storage
   - Auto-scaling within PU limits
   - Better latency and throughput consistency
   - Consider for > 10 TUs sustained load

3. **Capacity Planning**
   - Monitor incoming/outgoing bytes trends
   - Plan for 2x peak throughput capacity
   - Review message size patterns (optimize large messages)
   - Test with realistic production workloads
   - Set up auto-inflate to prevent throttling

### Consumer Groups

1. **Consumer Group Strategy**
   - Create separate consumer group per application
   - Don't exceed 20 consumer groups (Standard tier limit)
   - Use `$Default` only for testing
   - Name consumer groups descriptively (e.g., `analytics-processor`, `archiver`)
   - Monitor consumer lag per consumer group

2. **Consumer Best Practices**
   - Implement checkpointing frequently (every 50-100 messages)
   - Use one consumer per partition for maximum throughput
   - Handle transient errors with exponential backoff
   - Monitor consumer processing latency
   - Implement dead-letter queue for poison messages

### Partition Strategy

1. **Partition Count**
   - Standard tier: Up to 32 partitions
   - Premium tier: Up to 100 partitions per Event Hub
   - More partitions = higher throughput potential
   - Partition count cannot be changed after creation
   - Plan for future growth (choose higher initial count)

2. **Partition Key Selection**
   - Use partition key for ordered event processing
   - Good keys: `userId`, `deviceId`, `sessionId`
   - Avoid hot partitions (uneven distribution)
   - Null partition key = round-robin distribution
   - Test partition distribution in non-production first

3. **Partition Management**
   - Monitor per-partition metrics if available
   - Balance consumers across partitions
   - Implement partition rebalancing in consumers
   - Handle partition ownership changes gracefully

### Error Handling

1. **Producer Error Handling**
   - Implement exponential backoff for transient errors
   - Handle throttling (HTTP 429) with delays
   - Log failed events for manual replay
   - Use batching to improve throughput
   - Monitor send latency and success rates

2. **Consumer Error Handling**
   - Implement retry logic with max retry count
   - Move poison messages to dead-letter queue
   - Don't block partition processing on single message failure
   - Implement circuit breaker pattern for downstream dependencies
   - Monitor error rates per consumer

3. **Data Loss Prevention**
   - Monitor Event Hub Size alert (prevent 100GB limit)
   - Enable Capture for automatic archival
   - Reduce retention period if storage is filling
   - Scale out consumers to process faster
   - Alert on consumer lag exceeding threshold

### Monitoring and Diagnostics

1. **Diagnostic Logging**
   - Enable operational logs to Log Analytics
   - Log categories: OperationalLogs, AutoScaleLogs, KafkaCoordinatorLogs
   - Create custom Kusto queries for insights
   - Set up log retention based on compliance needs
   - Use logs for root cause analysis

2. **Custom Dashboards**
   - Create workbooks for Event Hub monitoring
   - Include: throughput, errors, latency, consumer lag
   - Set up live dashboards for operations teams
   - Include cost tracking metrics

3. **Performance Optimization**
   - Use batching for both producers and consumers
   - Optimize message payload sizes (<256KB ideal)
   - Use compression for large payloads
   - Monitor and optimize checkpoint frequency
   - Implement parallel processing in consumers

---

## Troubleshooting

### Common Issues

#### Issue 1: Alerts Not Firing Despite Breaching Thresholds

**Symptoms:**
- Metrics exceed thresholds but no notifications received
- Alert state shows "Not Activated"

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
  --metric "IncomingMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# 4. Check alert history
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name <alert-name>
```

**Common Causes:**
- Alert disabled in configuration
- Action group email not confirmed
- Incorrect metric namespace or name
- Insufficient data points for aggregation

**Resolution:**
- Enable alert: Set `enable_*_alert = true`
- Confirm action group emails
- Verify metric names match Azure documentation
- Check Event Hub is actively receiving traffic

---

#### Issue 2: Throttled Requests Alert Firing Frequently

**Symptoms:**
- Consistent throttling despite available capacity
- Messages being delayed or dropped

**Troubleshooting Steps:**
```bash
# 1. Check throttling rate
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ThrottledRequests" \
  --start-time <start-time> \
  --end-time <end-time>

# 2. Check throughput unit allocation
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "{sku:sku.name, capacity:sku.capacity, maxTU:maximumThroughputUnits, autoInflate:isAutoInflateEnabled}"

# 3. Check incoming throughput
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingBytes,OutgoingBytes" \
  --start-time <start-time> \
  --end-time <end-time>

# 4. Enable auto-inflate
az eventhubs namespace update \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --enable-auto-inflate true \
  --maximum-throughput-units 20
```

**Common Causes:**
- Insufficient throughput units allocated
- Auto-inflate not enabled
- Maximum TU limit too low
- Burst traffic exceeding capacity

**Resolution:**
```hcl
# Increase throughput capacity
# Option 1: Manually increase TUs
az eventhubs namespace update \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --capacity 10  # Increase TUs

# Option 2: Enable auto-inflate with higher max
az eventhubs namespace update \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --enable-auto-inflate true \
  --maximum-throughput-units 20

# Option 3: Upgrade to Premium tier
az eventhubs namespace create \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --sku Premium \
  --capacity 1  # Processing Units
```

---

#### Issue 3: Event Hub Size Approaching Limit

**Symptoms:**
- Event Hub Size alert firing
- Risk of data loss if 100GB limit reached

**Troubleshooting Steps:**
```bash
# 1. Check current size
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Size" \
  --start-time <start-time> \
  --end-time <end-time> \
  --filter "EntityName eq '<event-hub-name>'"

# 2. Check retention settings
az eventhubs eventhub show \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <event-hub-name> \
  --query "{name:name, partitions:partitionCount, retention:messageRetentionInDays}"

# 3. Check consumer lag
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingMessages,OutgoingMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# 4. Reduce retention (IMMEDIATE)
az eventhubs eventhub update \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <event-hub-name> \
  --message-retention 1  # Reduce to 1 day
```

**Common Causes:**
- Consumers not reading messages (consumer lag)
- Retention period too long (7 days default)
- High message volume with slow processing
- Insufficient consumer capacity

**Resolution (URGENT):**
```bash
# Step 1: Reduce retention immediately
az eventhubs eventhub update \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <event-hub-name> \
  --message-retention 1

# Step 2: Enable Capture for archival
az eventhubs eventhub create \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <event-hub-name> \
  --enable-capture true \
  --capture-interval 300 \
  --capture-size-limit 314572800 \
  --destination-name EventHubArchive \
  --storage-account <storage-account-id> \
  --blob-container <container-name>

# Step 3: Scale out consumers
# Deploy additional consumer instances

# Step 4: Consider Premium tier for 1TB+ storage
az eventhubs namespace create \
  --resource-group <resource-group> \
  --name <new-namespace-name> \
  --sku Premium \
  --capacity 1
```

---

#### Issue 4: Server Errors Detected

**Symptoms:**
- Server Errors alert firing
- Producers unable to send events

**Troubleshooting Steps:**
```bash
# 1. Check server error count
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "ServerErrors" \
  --start-time <start-time> \
  --end-time <end-time>

# 2. Check namespace health
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "provisioningState"

# 3. Check Azure service health
az rest --method get \
  --url "https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2020-05-01&$filter=resourceType eq 'Microsoft.EventHub/namespaces'"

# 4. Enable diagnostic logs
az monitor diagnostic-settings create \
  --resource <namespace-resource-id> \
  --name "eventhub-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "OperationalLogs", "enabled": true}, {"category": "AutoScaleLogs", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# 5. Query operational logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where ResourceProvider == 'MICROSOFT.EVENTHUB' 
    | where TimeGenerated > ago(1h) 
    | where Status == 'Failed' 
    | summarize count() by OperationName, ResultDescription"
```

**Common Causes:**
- Regional Azure service issues
- Namespace configuration problems
- Resource exhaustion
- Network connectivity issues

**Resolution:**
- Check Azure status page for known issues
- Open Azure support ticket if persistent
- Implement retry logic in producers
- Consider failover to secondary region

---

#### Issue 5: High User Errors

**Symptoms:**
- User Errors alert firing
- Authentication or authorization failures

**Troubleshooting Steps:**
```bash
# 1. Check user error metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "UserErrors" \
  --start-time <start-time> \
  --end-time <end-time>

# 2. Query error details from logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where ResourceProvider == 'MICROSOFT.EVENTHUB' 
    | where TimeGenerated > ago(1h) 
    | where Status == 'Failed' 
    | where Category == 'OperationalLogs' 
    | summarize count() by EventName, ErrorCode 
    | order by count_ desc"

# 3. List authorization rules
az eventhubs namespace authorization-rule list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name>

# 4. Check specific authorization rule
az eventhubs namespace authorization-rule show \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <rule-name>
```

**Common Causes:**
- Expired SAS tokens
- Invalid connection strings
- Insufficient permissions (Send/Listen/Manage)
- Revoked authorization rules
- Malformed event data

**Resolution:**
```bash
# Regenerate SAS keys
az eventhubs namespace authorization-rule keys renew \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <rule-name> \
  --key PrimaryKey

# Update application configuration with new keys
# Review and grant appropriate permissions
# Validate event payload format
```

---

#### Issue 6: Consumer Lag (Ingestion > Consumption)

**Symptoms:**
- Incoming messages > Outgoing messages consistently
- Event Hub size growing
- Processing delays

**Troubleshooting Steps:**
```bash
# 1. Compare ingestion vs consumption
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingMessages,OutgoingMessages" \
  --start-time <start-time> \
  --end-time <end-time>

# 2. Check Event Hub size growth
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "Size" \
  --start-time <start-time> \
  --end-time <end-time> \
  --filter "EntityName eq '<event-hub-name>'"

# 3. List consumer groups
az eventhubs eventhub consumer-group list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --eventhub-name <event-hub-name>
```

**Common Causes:**
- Insufficient consumer capacity
- Slow downstream processing
- Consumer errors causing retries
- Partition imbalance (hot partitions)
- Consumer not checkpointing

**Resolution:**
```bash
# Scale out consumers (add more instances)
# Implement parallel processing
# Optimize consumer processing logic
# Check for partition hot spots
# Monitor consumer checkpoint frequency
# Consider using Event Processor Host for auto-scaling
```

---

### Validation Commands

```bash
# 1. List all Event Hub namespaces
az eventhubs namespace list \
  --resource-group <resource-group> \
  --output table

# 2. Get namespace details
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name>

# 3. List Event Hubs in namespace
az eventhubs eventhub list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --output table

# 4. Get Event Hub details
az eventhubs eventhub show \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --name <event-hub-name>

# 5. List consumer groups
az eventhubs eventhub consumer-group list \
  --resource-group <resource-group> \
  --namespace-name <namespace-name> \
  --eventhub-name <event-hub-name> \
  --output table

# 6. List metric definitions
az monitor metrics list-definitions \
  --resource <namespace-resource-id>

# 7. Query specific metric
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingMessages" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --interval PT5M \
  --aggregation Total

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
  --name "eventhub-diagnostics" \
  --workspace <log-analytics-workspace-id> \
  --logs '[
    {"category": "OperationalLogs", "enabled": true},
    {"category": "AutoScaleLogs", "enabled": true},
    {"category": "KafkaCoordinatorLogs", "enabled": true},
    {"category": "KafkaUserErrorLogs", "enabled": true}
  ]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# 12. Query operational logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics 
    | where ResourceProvider == 'MICROSOFT.EVENTHUB' 
    | where Category == 'OperationalLogs' 
    | where TimeGenerated > ago(1h) 
    | summarize count() by Status, OperationName 
    | render barchart"

# 13. Check throughput metrics
az monitor metrics list \
  --resource <namespace-resource-id> \
  --metric "IncomingBytes,OutgoingBytes,ThrottledRequests" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Total

# 14. Check namespace capacity
az eventhubs namespace show \
  --resource-group <resource-group> \
  --name <namespace-name> \
  --query "{name:name, sku:sku, autoInflate:isAutoInflateEnabled, maxTU:maximumThroughputUnits}"

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
