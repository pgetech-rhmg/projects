# Azure Cache for Redis - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure Cache for Redis** instances, providing proactive monitoring for performance, capacity, and operational metrics. The module is designed to detect potential issues before they impact application performance and user experience.

Azure Cache for Redis is a fully managed, in-memory data store based on Redis software. It provides high-throughput, low-latency data access for Azure applications, serving as a distributed cache, session store, message broker, and real-time analytics engine.

## Features

- **Performance Monitoring**: CPU usage, server load, and operations per second tracking
- **Memory Management**: Memory usage and eviction monitoring with capacity alerts
- **Cache Efficiency**: Cache miss rate and hit rate optimization monitoring
- **Connection Monitoring**: Connected clients and connection health tracking
- **Bandwidth Monitoring**: Read/write bandwidth utilization alerts
- **Key Management**: Total keys, expired keys, and evicted keys monitoring
- **Command Processing**: Total commands processed and throughput monitoring
- **Shard-Level Monitoring**: Per-shard metrics for clustered Redis instances
- **Customizable Thresholds**: Adjustable alert thresholds for different environments
- **Cost-Effective Alerting**: Metric alerts at $0.10 per month per alert rule
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **Real-Time Performance**: 5-minute evaluation frequency for critical metrics
- **Capacity Planning**: Proactive alerts for memory and key count limits
- **Cache Optimization**: Miss rate monitoring for performance tuning
- **Connection Management**: Client connection limits and health monitoring
- **Bandwidth Utilization**: Network I/O performance tracking
- **Operational Health**: Command processing and throughput monitoring

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Cache/redis/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Redis Cache**: Existing Azure Cache for Redis instances to monitor
- **Recommended**: Log Analytics workspace for diagnostic settings
- **Recommended**: Diagnostic settings enabled on Redis Cache instances

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs provides essential troubleshooting capabilities for connection analysis, command tracing, and performance investigation.

## Usage

### Basic Configuration

```hcl
module "redis_alerts" {
  source = "./modules/metricAlerts/redis"
  
  # Resource Configuration
  resource_group_name               = "rg-production-cache"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # Redis Cache Instances
  redis_cache_names = [
    "redis-prod-web-001",
    "redis-prod-api-001",
    "redis-prod-session-001"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "WebApp"
    Owner             = "platform-team@pge.com"
    CostCenter        = "IT-Infrastructure"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "redis_alerts_custom" {
  source = "./modules/metricAlerts/redis"
  
  # Resource Configuration
  resource_group_name               = "rg-production-cache"
  action_group_resource_group_name  = "rg-monitoring"
  redis_cache_names                = ["redis-prod-high-traffic"]
  
  # Performance Thresholds (High-Traffic Environment)
  redis_cpu_threshold                      = 70   # Lower threshold for high-traffic
  redis_memory_threshold                   = 85   # More aggressive memory monitoring
  redis_server_load_threshold             = 75   # Lower server load tolerance
  
  # Capacity Thresholds
  redis_connected_clients_threshold        = 500  # Higher client limit
  redis_total_keys_threshold              = 5000000  # 5M keys for large cache
  
  # Performance Thresholds
  redis_operations_per_second_threshold    = 5000    # High-throughput environment
  redis_cache_miss_rate_threshold         = 15      # Stricter cache efficiency
  
  # Bandwidth Thresholds (500MB/s)
  redis_cache_read_bandwidth_threshold     = 524288000
  redis_cache_write_bandwidth_threshold    = 524288000
  
  # Key Management
  redis_evicted_keys_threshold            = 50      # Higher eviction tolerance
  redis_expired_keys_threshold            = 100     # Natural expiration tolerance
  
  # Alert Toggles
  enable_redis_cpu_alert                  = true
  enable_redis_memory_alert               = true
  enable_redis_cache_miss_rate_alert      = true
  enable_redis_operations_per_second_alert = true
  
  tags = {
    Environment = "Production"
    Tier        = "High-Performance"
    Owner       = "data-platform@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Redis - Relaxed Thresholds
redis_cpu_threshold                 = 90
redis_memory_threshold              = 95
redis_connected_clients_threshold   = 50
redis_operations_per_second_threshold = 100
```

#### Staging Environment
```hcl
# Staging Redis - Moderate Thresholds
redis_cpu_threshold                 = 85
redis_memory_threshold              = 90
redis_connected_clients_threshold   = 150
redis_operations_per_second_threshold = 500
```

#### Production Environment
```hcl
# Production Redis - Strict Thresholds
redis_cpu_threshold                 = 75
redis_memory_threshold              = 85
redis_connected_clients_threshold   = 300
redis_operations_per_second_threshold = 2000
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for Redis Cache instances |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
| `redis_cache_names` | `list(string)` | `[]` | List of Redis Cache instance names |

### Alert Enable Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_redis_cpu_alert` | `bool` | `true` | Enable CPU usage monitoring |
| `enable_redis_memory_alert` | `bool` | `true` | Enable memory usage monitoring |
| `enable_redis_server_load_alert` | `bool` | `true` | Enable server load monitoring |
| `enable_redis_connected_clients_alert` | `bool` | `true` | Enable client connection monitoring |
| `enable_redis_cache_miss_rate_alert` | `bool` | `true` | Enable cache miss rate monitoring |
| `enable_redis_evicted_keys_alert` | `bool` | `true` | Enable evicted keys monitoring |
| `enable_redis_expired_keys_alert` | `bool` | `true` | Enable expired keys monitoring |
| `enable_redis_total_keys_alert` | `bool` | `true` | Enable total keys monitoring |
| `enable_redis_operations_per_second_alert` | `bool` | `true` | Enable operations/sec monitoring |
| `enable_redis_cache_read_bandwidth_alert` | `bool` | `true` | Enable read bandwidth monitoring |
| `enable_redis_cache_write_bandwidth_alert` | `bool` | `true` | Enable write bandwidth monitoring |
| `enable_redis_total_commands_processed_alert` | `bool` | `true` | Enable commands processed monitoring |

### Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `redis_cpu_threshold` | `number` | `80` | CPU usage percentage | 70-90% |
| `redis_memory_threshold` | `number` | `90` | Memory usage percentage | 80-95% |
| `redis_server_load_threshold` | `number` | `80` | Server load percentage | 70-90% |
| `redis_connected_clients_threshold` | `number` | `250` | Connected clients count | 100-1000 |
| `redis_cache_miss_rate_threshold` | `number` | `20` | Cache miss rate percentage | 10-30% |
| `redis_evicted_keys_threshold` | `number` | `10` | Evicted keys per minute | 5-100 |
| `redis_expired_keys_threshold` | `number` | `10` | Expired keys per minute | 5-200 |
| `redis_total_keys_threshold` | `number` | `1000000` | Total keys count | 500K-10M |
| `redis_operations_per_second_threshold` | `number` | `1000` | Operations per second | 100-10K |
| `redis_cache_read_bandwidth_threshold` | `number` | `104857600` | Read bandwidth (bytes/sec) | 10MB-1GB |
| `redis_cache_write_bandwidth_threshold` | `number` | `104857600` | Write bandwidth (bytes/sec) | 10MB-1GB |
| `redis_total_commands_processed_threshold` | `number` | `1000` | Commands processed/sec | 100-10K |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                    # Application identifier
  Env                = "Production"                # Environment designation
  Owner              = "platform-team@pge.com"    # Team responsible
  Compliance         = "SOX"                       # Compliance requirement
  Notify             = "oncall@pge.com"           # Notification contact
  DataClassification = "Internal"                  # Data sensitivity
  CostCenter         = "IT-Infrastructure"         # Billing allocation
  CRIS               = "CRIS-12345"               # Change request ID
}
```

## Alert Details

### 1. CPU Usage Alert
- **Alert Name**: `redis-cpu-usage-high-{cache-names}`
- **Metric**: `percentProcessorTime`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: CPU utilization across all Redis server processes, including data structure operations, networking, and background tasks.

**What to do when this alert fires**:
1. **Immediate Assessment**: Check Redis operations and current workload
2. **Performance Analysis**: Review slow log and identify expensive operations
3. **Scaling Evaluation**: Consider upgrading to higher SKU or implementing clustering
4. **Optimization**: Review data structures and command patterns for efficiency
5. **Load Distribution**: Implement read replicas or connection pooling

### 2. Memory Usage Alert
- **Alert Name**: `redis-memory-usage-high-{cache-names}`
- **Metric**: `usedmemorypercentage`
- **Threshold**: 90% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Memory consumption including data storage, overhead, and fragmentation across all Redis processes.

**What to do when this alert fires**:
1. **Memory Analysis**: Use `INFO memory` to analyze memory breakdown
2. **Data Cleanup**: Implement TTL policies and remove obsolete keys
3. **Memory Optimization**: Configure appropriate eviction policies
4. **Scaling**: Upgrade to higher memory SKU or implement clustering
5. **Monitoring**: Set up key expiration and memory fragmentation monitoring

### 3. Server Load Alert
- **Alert Name**: `redis-server-load-high-{cache-names}`
- **Metric**: `serverLoad`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Overall server load including CPU, memory, and I/O operations combined into a single percentage.

**What to do when this alert fires**:
1. **Load Investigation**: Identify specific bottlenecks (CPU, memory, or I/O)
2. **Operation Analysis**: Review current operations and connection patterns
3. **Performance Tuning**: Optimize Redis configuration and client behavior
4. **Capacity Planning**: Evaluate need for vertical or horizontal scaling
5. **Load Balancing**: Implement read replicas or Redis Cluster for distribution

### 4. Connected Clients Alert
- **Alert Name**: `redis-connected-clients-high-{cache-names}`
- **Metric**: `connectedclients`
- **Threshold**: 250 connections (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Number of active client connections to the Redis instance.

**What to do when this alert fires**:
1. **Connection Analysis**: Review connection patterns and client behavior
2. **Connection Pooling**: Implement or optimize connection pooling in applications
3. **Idle Connection Cleanup**: Configure appropriate timeout settings
4. **Client Investigation**: Identify applications with excessive connections
5. **Capacity Planning**: Consider scaling Redis or implementing connection limits

### 5. Cache Miss Rate Alert
- **Alert Name**: `redis-cache-miss-rate-high-{cache-names}`
- **Metric**: `cachemissrate`
- **Threshold**: 20% (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Average

**What this alert monitors**: Percentage of cache requests that result in cache misses, indicating cache efficiency.

**What to do when this alert fires**:
1. **Cache Strategy Review**: Analyze caching patterns and TTL policies
2. **Data Preloading**: Implement cache warming strategies
3. **Key Pattern Analysis**: Review key naming and data access patterns
4. **Application Logic**: Optimize application caching logic and fallback mechanisms
5. **Memory Management**: Ensure sufficient memory to prevent premature evictions

### 6. Evicted Keys Alert
- **Alert Name**: `redis-evicted-keys-high-{cache-names}`
- **Metric**: `evictedkeys`
- **Threshold**: 10 keys/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: Number of keys evicted due to memory pressure or eviction policies.

**What to do when this alert fires**:
1. **Memory Pressure**: Investigate memory usage and consider scaling
2. **Eviction Policy**: Review and optimize maxmemory-policy configuration
3. **TTL Management**: Implement appropriate expiration times for keys
4. **Data Optimization**: Remove unnecessary data and optimize data structures
5. **Monitoring**: Set up detailed eviction tracking and analysis

### 7. Expired Keys Alert
- **Alert Name**: `redis-expired-keys-high-{cache-names}`
- **Metric**: `expiredkeys`
- **Threshold**: 10 keys/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: Number of keys that have expired naturally due to TTL settings.

**What to do when this alert fires**:
1. **TTL Analysis**: Review TTL patterns and application behavior
2. **Expiration Strategy**: Optimize key expiration policies
3. **Performance Impact**: Monitor CPU usage during key expiration cleanup
4. **Application Logic**: Ensure applications handle expired keys gracefully
5. **Capacity Planning**: Consider impact on cache refresh patterns

### 8. Total Keys Alert
- **Alert Name**: `redis-total-keys-high-{cache-names}`
- **Metric**: `totalkeys`
- **Threshold**: 1,000,000 keys (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Average

**What this alert monitors**: Total number of keys stored in the Redis instance across all databases.

**What to do when this alert fires**:
1. **Key Management**: Review key lifecycle and cleanup procedures
2. **Data Architecture**: Evaluate data partitioning and key naming strategies
3. **Cleanup Policies**: Implement automated key cleanup and archiving
4. **Scaling Strategy**: Consider Redis Cluster for horizontal scaling
5. **Performance Monitoring**: Watch for performance degradation with high key counts

### 9. Operations Per Second Alert
- **Alert Name**: `redis-operations-per-second-high-{cache-names}`
- **Metric**: `operationsPerSecond`
- **Threshold**: 1,000 ops/sec (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Rate of operations (commands) being processed by Redis per second.

**What to do when this alert fires**:
1. **Performance Analysis**: Monitor response times and identify bottlenecks
2. **Operation Optimization**: Review command efficiency and batch operations
3. **Scaling Assessment**: Evaluate need for read replicas or clustering
4. **Client Optimization**: Implement connection pooling and pipelining
5. **Capacity Planning**: Plan for vertical or horizontal scaling

### 10. Cache Read Bandwidth Alert
- **Alert Name**: `redis-cache-read-bandwidth-high-{cache-names}`
- **Metric**: `cacheRead`
- **Threshold**: 100 MB/sec (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Network bandwidth consumed by data reads from Redis cache.

**What to do when this alert fires**:
1. **Bandwidth Analysis**: Review data access patterns and payload sizes
2. **Data Optimization**: Implement data compression or optimize data structures
3. **Network Planning**: Evaluate network capacity and consider regional deployment
4. **Read Distribution**: Implement read replicas to distribute bandwidth load
5. **Client Optimization**: Optimize data serialization and batch read operations

### 11. Cache Write Bandwidth Alert
- **Alert Name**: `redis-cache-write-bandwidth-high-{cache-names}`
- **Metric**: `cacheWrite`
- **Threshold**: 100 MB/sec (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Network bandwidth consumed by data writes to Redis cache.

**What to do when this alert fires**:
1. **Write Pattern Analysis**: Review data ingestion and update patterns
2. **Data Optimization**: Optimize payload sizes and write frequency
3. **Batch Operations**: Implement batch writes and pipelining
4. **Network Capacity**: Evaluate network infrastructure and bandwidth limits
5. **Architecture Review**: Consider write sharding and data partitioning strategies

### 12. Total Commands Processed Alert
- **Alert Name**: `redis-total-commands-processed-high-{cache-names}`
- **Metric**: `totalcommandsprocessed`
- **Threshold**: 1,000 commands/sec (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: Total number of commands processed by Redis over time, indicating overall throughput.

**What to do when this alert fires**:
1. **Throughput Analysis**: Review command distribution and processing efficiency
2. **Performance Optimization**: Identify slow commands and optimize operations
3. **Scaling Strategy**: Plan for capacity increases or horizontal scaling
4. **Client Behavior**: Optimize application command patterns and batching
5. **Resource Monitoring**: Ensure adequate CPU and memory for command processing

## Severity Levels

### Severity 2 (High) - Critical Performance Impact
- **CPU Usage**: Direct impact on response times and throughput
- **Memory Usage**: Risk of memory pressure and evictions
- **Server Load**: Overall performance degradation risk

**Response Time**: 15 minutes
**Escalation**: Immediate notification to on-call engineer

### Severity 3 (Medium) - Performance Degradation Risk
- **Connected Clients**: Connection limit approaching
- **Cache Miss Rate**: Cache efficiency degradation
- **Key Management**: Capacity and lifecycle issues
- **Bandwidth**: Network utilization concerns
- **Operations**: Throughput monitoring

**Response Time**: 30 minutes
**Escalation**: Standard operational notification

## Cost Analysis

### Alert Costs (Monthly)
- **12 Metric Alerts**: 12 × $0.10 = **$1.20 per Redis Cache instance**
- **Multi-Instance Deployment**: Scales linearly with Redis Cache count
- **Action Group**: FREE (included)

### Cost Examples by Environment

#### Small Environment (2 Redis Caches)
- **Monthly Alert Cost**: $2.40
- **Annual Alert Cost**: $28.80

#### Medium Environment (5 Redis Caches)
- **Monthly Alert Cost**: $6.00
- **Annual Alert Cost**: $72.00

#### Large Environment (10 Redis Caches)
- **Monthly Alert Cost**: $12.00
- **Annual Alert Cost**: $144.00

#### Enterprise Environment (25 Redis Caches)
- **Monthly Alert Cost**: $30.00
- **Annual Alert Cost**: $360.00

### Return on Investment (ROI)

#### Cost of Redis Performance Issues
- **Cache Miss Impact**: 50ms additional latency per request
- **High Traffic Application**: 1M requests/hour during peak
- **Performance Degradation**: 10% slower response times
- **Business Impact**: $100,000/hour in lost productivity/revenue
- **Memory Pressure**: Risk of application failures and data loss
- **Connection Issues**: Service unavailability and user impact

#### Alert Value Calculation
- **Monthly Alert Cost**: $1.20 per Redis Cache
- **Prevented Downtime**: 2 hours/month average
- **Cost Avoidance**: $200,000/month
- **ROI**: 16,666,567% (($200,000 - $1.20) / $1.20 × 100)

#### Additional Benefits
- **Proactive Optimization**: Identify performance trends before impact
- **Capacity Planning**: Data-driven scaling decisions
- **Cache Efficiency**: Optimize hit rates and reduce backend load
- **Cost Optimization**: Right-size Redis instances based on actual usage
- **Compliance**: Demonstrate monitoring for audit requirements

### Azure Cache for Redis Pricing Context
- **Basic Tier**: $0.016/hour for C0 (250MB cache)
- **Standard Tier**: $0.040/hour for C1 (1GB cache)  
- **Premium Tier**: $0.325/hour for P1 (6GB cache)
- **Enterprise Tier**: Starting at $1.133/hour for E10 (12GB cache)

**Alert Cost as % of Redis Cost**: 0.3% - 2% of monthly Redis costs

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive monitoring and troubleshooting, enable diagnostic settings on your Azure Cache for Redis instances. While metric alerts monitor performance thresholds, diagnostic settings provide detailed logs for connection analysis and command tracing.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings for Redis via Azure CLI
az monitor diagnostic-settings create \
  --name "redis-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Cache/redis/{redis-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"ConnectedClientList","enabled":true,"retentionPolicy":{"days":7,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "redis_diagnostics" {
  for_each                   = toset(var.redis_cache_names)
  name                       = "redis-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_redis_cache.caches[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Connected Client List - Active connections
  enabled_log {
    category = "ConnectedClientList"
  }

  # All Metrics including CPU, memory, connections
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Category | Purpose | When to Enable |
|----------|---------|----------------|
| **ConnectedClientList** | List of connected clients with IP addresses and connection details | **Always** - Essential for connection troubleshooting |

#### Useful Log Analytics Queries

```kusto
// Connection count over time
AzureMetrics
| where ResourceProvider == "MICROSOFT.CACHE"
| where MetricName == "connectedclients"
| where TimeGenerated > ago(24h)
| summarize AvgConnections = avg(Total) by bin(TimeGenerated, 5m), Resource
| render timechart

// Cache hit rate analysis
AzureMetrics
| where ResourceProvider == "MICROSOFT.CACHE"
| where TimeGenerated > ago(24h)
| where MetricName in ("cachehits", "cachemisses")
| summarize 
    Hits = sumif(Total, MetricName == "cachehits"),
    Misses = sumif(Total, MetricName == "cachemisses")
  by bin(TimeGenerated, 15m), Resource
| extend HitRate = round(100.0 * Hits / (Hits + Misses), 2)
| render timechart

// Memory usage trends
AzureMetrics
| where ResourceProvider == "MICROSOFT.CACHE"
| where MetricName == "usedmemorypercentage"
| where TimeGenerated > ago(7d)
| summarize 
    AvgMemory = avg(Total),
    MaxMemory = max(Total)
  by bin(TimeGenerated, 1h), Resource
| render timechart

// Server load analysis
AzureMetrics
| where ResourceProvider == "MICROSOFT.CACHE"
| where MetricName == "serverLoad"
| where TimeGenerated > ago(24h)
| summarize 
    AvgLoad = avg(Total),
    MaxLoad = max(Total)
  by bin(TimeGenerated, 5m), Resource
| order by TimeGenerated desc
```

### 2. Deployment Best Practices

#### Environment-Specific Configuration
```hcl
# Production Environment - Strict monitoring
redis_cpu_threshold              = 70
redis_memory_threshold           = 80
redis_server_load_threshold      = 75
redis_connected_clients_threshold = 900
redis_cache_miss_threshold       = 50

# Staging Environment - Moderate monitoring
redis_cpu_threshold              = 80
redis_memory_threshold           = 85
redis_server_load_threshold      = 85
redis_connected_clients_threshold = 950
redis_cache_miss_threshold       = 60

# Development Environment - Relaxed monitoring
redis_cpu_threshold              = 90
redis_memory_threshold           = 95
redis_server_load_threshold      = 95
redis_connected_clients_threshold = 980
redis_cache_miss_threshold       = 70
```

#### Multi-Region Deployment
- Configure region-specific action groups
- Adjust thresholds for network latency differences
- Consider geo-replication monitoring needs

#### High Availability Setup
- Monitor both primary and secondary instances (if using Premium tier)
- Set up failover-specific alerts
- Configure backup and persistence monitoring

### 3. Alert Response Procedures

#### Severity 1 (Critical) - Immediate Response
- **High CPU Usage (>70%)** → Check slow operations, review command patterns, consider scaling up
- **High Memory Usage (>80%)** → Review eviction policy, check for memory leaks, plan capacity increase
- **High Server Load** → Analyze command complexity, optimize queries, scale tier

**Response Time**: < 15 minutes  
**Escalation**: Page on-call engineer

**Immediate Actions**:
1. Review Redis INFO command output
2. Identify expensive operations (SLOWLOG GET)
3. Check connection pool configuration
4. Review recent application changes
5. Consider immediate scaling if critical

#### Severity 2 (Warning) - Review Within 1 Hour
- **High Connection Count** → Review connection pooling, check for leaks
- **High Cache Miss Rate** → Optimize caching strategy, review TTL settings
- **High Eviction Rate** → Plan memory capacity increase

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Severity 3 (Informational) - Review During Business Hours
- **Network Bandwidth** → Capacity planning
- **Operations per Second** → Performance trend analysis

**Response Time**: Next business day  
**Escalation**: Log for review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on all Redis Cache instances
- [ ] Configure Log Analytics workspace retention (30+ days for metrics)
- [ ] Set up action groups with appropriate notification channels
- [ ] Customize alert thresholds based on tier and workload
- [ ] Test alert notifications to verify delivery
- [ ] Document escalation procedures
- [ ] Configure appropriate eviction policy

#### Ongoing Operations
- [ ] Review cache hit rates weekly
- [ ] Analyze slow operations monthly (SLOWLOG)
- [ ] Review alert thresholds quarterly based on growth
- [ ] Update alert rules for new Redis instances
- [ ] Validate action group membership monthly
- [ ] Monitor and optimize connection counts
- [ ] Review memory fragmentation monthly

#### Performance & Optimization
- [ ] Establish performance baselines (CPU, memory, latency)
- [ ] Optimize Redis commands and data structures
- [ ] Review and tune eviction policies
- [ ] Monitor key expiration patterns
- [ ] Analyze command patterns for optimization
- [ ] Consider clustering for scale-out scenarios

### Redis Configuration Best Practices (Continued)
```redis
# Enable appropriate eviction policy
maxmemory-policy allkeys-lru

# Configure memory limit
maxmemory 2gb

# Enable memory sampling
maxmemory-samples 5
```

#### 2. Performance Optimization
```redis
# Enable lazy freeing for better performance
lazyfree-lazy-eviction yes
lazyfree-lazy-expire yes
lazyfree-lazy-server-del yes

# Configure appropriate save settings
save 900 1
save 300 10
save 60 10000
```

#### 3. Connection Management
```redis
# Set appropriate timeout
timeout 300

# Configure TCP keepalive
tcp-keepalive 300

# Set client output buffer limits
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
```

### Monitoring Best Practices

#### 1. Baseline Establishment
- Monitor for 2-4 weeks to establish performance baselines
- Adjust thresholds based on observed normal operations
- Document peak usage patterns and expected variations

#### 2. Key Metrics Correlation
- CPU usage often correlates with operations per second
- Memory usage relates to cache miss rates and evictions
- Server load combines multiple resource utilizations

#### 3. Proactive Capacity Planning
- Monitor trends in total keys and memory usage
- Plan scaling before reaching 80% capacity
- Consider Redis Cluster for horizontal scaling needs

#### 4. Cache Efficiency Optimization
- Target cache hit rates above 80%
- Monitor miss rates during different traffic patterns
- Implement cache warming for predictable access patterns

### Application Integration Best Practices

#### 1. Connection Pooling
```python
import redis.connection
import redis

# Configure connection pool
pool = redis.ConnectionPool(
    host='your-redis.redis.cache.windows.net',
    port=6380,
    password='your-access-key',
    ssl=True,
    max_connections=20,
    retry_on_timeout=True,
    socket_connect_timeout=5,
    socket_timeout=5
)

redis_client = redis.Redis(connection_pool=pool)
```

#### 2. Error Handling
```python
import redis
from redis.exceptions import RedisError, TimeoutError

def get_from_cache(key):
    try:
        return redis_client.get(key)
    except TimeoutError:
        # Handle timeout gracefully
        return None
    except RedisError as e:
        # Log error and return fallback
        logger.error(f"Redis error: {e}")
        return None
```

#### 3. TTL Management
```python
# Set appropriate TTL values
redis_client.setex('user_session', 3600, user_data)  # 1 hour
redis_client.setex('api_cache', 300, api_response)    # 5 minutes
redis_client.setex('temp_data', 60, temp_value)      # 1 minute
```

### Security Best Practices

#### 1. Network Security
- Use Redis in VNet integration when possible
- Configure appropriate NSG rules
- Enable SSL/TLS for all connections

#### 2. Authentication
- Use strong access keys and rotate regularly
- Implement Azure AD authentication where supported
- Use separate keys for read-only access when possible

#### 3. Data Protection
- Enable encryption at rest for sensitive data
- Use appropriate data classification tags
- Implement data retention policies

### Compliance and Governance

#### 1. Regulatory Compliance
- **SOX**: Maintain change control and access logs
- **HIPAA**: Ensure encryption and access controls for PHI
- **PCI-DSS**: Secure cardholder data in cache with encryption
- **GDPR**: Implement data retention and deletion procedures

#### 2. Data Governance
- Tag resources with data classification levels
- Implement appropriate access controls
- Monitor data flow and usage patterns

#### 3. Audit Requirements
- Enable diagnostic logging for cache operations
- Maintain alert response documentation
- Regular review of alert thresholds and effectiveness

## Troubleshooting

### Common Issues and Solutions

#### 1. Alert Not Firing Despite High CPU Usage
**Symptoms**: CPU appears high in portal but alert doesn't trigger

**Possible Causes**:
- Alert evaluation frequency doesn't match spike duration
- Threshold configured higher than actual usage
- Insufficient permissions for metric collection
- Alert rule disabled or misconfigured

**Troubleshooting Steps**:
```bash
# Check alert rule configuration
az monitor metrics alert show --name "redis-cpu-usage-high-cache001" --resource-group "rg-prod"

# Verify metric data availability
az monitor metrics list-definitions --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Cache/redis/{name}"

# Check current CPU metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Cache/redis/{name}" \
  --metric "percentProcessorTime" \
  --interval PT5M
```

**Resolution**:
- Verify alert rule is enabled and configured correctly
- Check action group configuration and permissions
- Ensure metric collection is functioning
- Review evaluation frequency and window size settings

#### 2. High Memory Usage Not Triggering Memory Alert
**Symptoms**: Memory usage appears high but memory alert not firing

**Possible Causes**:
- Memory reporting includes fragmentation that doesn't count toward limit
- Alert threshold set too high
- Transient memory spikes not captured in evaluation window
- Different memory metrics being monitored vs. displayed

**Troubleshooting Steps**:
```bash
# Check current memory usage metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Cache/redis/{name}" \
  --metric "usedmemorypercentage" \
  --interval PT5M

# Review Redis memory info
redis-cli -h your-cache.redis.cache.windows.net -p 6380 -a your-key --tls INFO memory

# Check for memory fragmentation
redis-cli -h your-cache.redis.cache.windows.net -p 6380 -a your-key --tls MEMORY stats
```

**Resolution**:
- Review actual vs. reported memory usage
- Adjust threshold based on real memory pressure indicators
- Consider fragmentation ratio in threshold calculation
- Monitor both used memory percentage and absolute values

#### 3. Cache Miss Rate Alert Firing Frequently
**Symptoms**: Frequent cache miss rate alerts during normal operations

**Possible Causes**:
- Application not implementing proper caching patterns
- Cache warming not properly implemented
- TTL settings causing premature expiration
- Memory pressure causing evictions
- Cold start scenarios after maintenance

**Troubleshooting Steps**:
```bash
# Check cache hit/miss statistics
redis-cli -h your-cache.redis.cache.windows.net -p 6380 -a your-key --tls INFO stats

# Monitor key eviction patterns
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Cache/redis/{name}" \
  --metric "evictedkeys,expiredkeys" \
  --interval PT15M

# Analyze key patterns
redis-cli -h your-cache.redis.cache.windows.net -p 6380 -a your-key --tls --scan --pattern "*" | head -20
```

**Resolution**:
- Implement cache warming procedures
- Review and optimize TTL policies
- Analyze application caching patterns
- Consider increasing cache size or implementing tiered caching
- Adjust cache miss rate threshold based on acceptable levels

#### 4. Connected Clients Alert During Peak Hours
**Symptoms**: Connected clients alert during expected high traffic periods

**Possible Causes**:
- Application not using connection pooling
- Connection leaks in application code
- Insufficient connection pool configuration
- High connection churn rate
- Multiple applications connecting to same Redis instance

**Troubleshooting Steps**:
```bash
# Check current connection count
redis-cli -h your-cache.redis.cache.windows.net -p 6380 -a your-key --tls INFO clients

# Monitor connection patterns
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Cache/redis/{name}" \
  --metric "connectedclients" \
  --interval PT5M

# Check for connection errors
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Cache/redis/{name}" \
  --metric "errors" \
  --interval PT5M
```

**Resolution**:
- Implement connection pooling in applications
- Review application connection management
- Configure appropriate connection timeouts
- Consider Redis connection limits and scaling options
- Monitor for connection leaks and implement proper cleanup

### Performance Optimization

#### 1. CPU Optimization
- Use appropriate data structures (sets, sorted sets, hashes)
- Implement pipelining for batch operations
- Avoid expensive operations during peak hours
- Use Redis Cluster for CPU distribution

#### 2. Memory Optimization
```redis
# Optimize data structures
HSET user:1001 name "John" age 30 email "john@example.com"

# Use appropriate data types
SETBIT user:active:20231124 1001 1  # More efficient than sets for binary flags

# Implement memory-efficient patterns
ZADD leaderboard 1000 "player1" 950 "player2"  # Sorted sets for rankings
```

#### 3. Network Optimization
- Implement compression for large payloads
- Use batch operations to reduce round trips
- Configure appropriate client timeouts
- Consider Redis deployment proximity to applications

### Monitoring and Diagnostics

#### 1. Enable Diagnostic Logging
```bash
# Configure diagnostic settings
az monitor diagnostic-settings create \
  --name "redis-diagnostics" \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Cache/redis/{name}" \
  --logs '[{"category":"ConnectedClientList","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --workspace "/subscriptions/{sub}/resourcegroups/{rg}/providers/microsoft.operationalinsights/workspaces/{workspace}"
```

#### 2. Custom Monitoring Queries
```kql
// Redis connection analysis
AzureMetrics
| where ResourceProvider == "MICROSOFT.CACHE"
| where MetricName == "connectedclients"
| summarize avg(Average), max(Maximum) by bin(TimeGenerated, 5m)
| render timechart

// Cache efficiency analysis  
AzureMetrics
| where ResourceProvider == "MICROSOFT.CACHE"
| where MetricName in ("cachemiss", "cachehit")
| summarize HitRate = sum(iff(MetricName == "cachehit", Total, 0)) * 100.0 / sum(Total) by bin(TimeGenerated, 15m)
| render timechart
```

#### 3. Health Check Automation
```bash
#!/bin/bash
# Redis health check script

REDIS_HOST="your-cache.redis.cache.windows.net"
REDIS_PORT="6380"
REDIS_KEY="your-access-key"

# Test basic connectivity
redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_KEY --tls ping

# Check memory usage
MEMORY_USED=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_KEY --tls INFO memory | grep used_memory_human)
echo "Memory usage: $MEMORY_USED"

# Check connected clients
CLIENTS=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_KEY --tls INFO clients | grep connected_clients)
echo "Connected clients: $CLIENTS"
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Cache for Redis monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual usage patterns is recommended for optimal monitoring effectiveness.