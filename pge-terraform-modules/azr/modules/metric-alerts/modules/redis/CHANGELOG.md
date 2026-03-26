# Changelog

All notable changes to the Azure Redis Cache Monitoring Module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure Redis Cache monitoring module
- Comprehensive metric alerting for Redis cache instances with 12 alert types:
  - **Performance Monitoring**:
    - CPU usage monitoring with ShardId dimension support
    - Memory usage tracking with ShardId dimension support
    - Server load monitoring with ShardId dimension support
    - Operations per second tracking
  - **Connectivity Monitoring**:
    - Connected clients monitoring with ShardId dimension support
  - **Cache Health Monitoring**:
    - Cache miss rate monitoring
    - Evicted keys tracking
    - Expired keys monitoring
    - Total keys count monitoring
  - **Bandwidth Monitoring**:
    - Cache read bandwidth monitoring
    - Cache write bandwidth monitoring
  - **Operations Monitoring**:
    - Total commands processed tracking
- Diagnostic settings support with dual destination options:
  - Event Hub integration for activity logs and metrics
  - Log Analytics workspace integration for security logs and analysis
- Cross-subscription support for diagnostic destinations:
  - Event Hub can be in different subscription
  - Log Analytics workspace can be in different subscription
- ShardId dimension support for clustered Redis deployments
- Individual enable/disable flags for all 12 metric alerts
- Customizable thresholds for all metrics
- Dynamic resource discovery using data sources
- Action group integration for alert notifications
- Comprehensive tagging support for resource organization
- Three deployment examples:
  - Production: Full monitoring with tight thresholds
  - Development: Balanced monitoring with relaxed thresholds
  - Basic: Minimal monitoring for testing
- Module outputs:
  - Alert IDs and names by category
  - Monitored resource information
  - Action group details
  - Diagnostic settings IDs
  - Configuration summary
- Input validation for resource groups and action groups
- Terraform Registry-ready structure with versions.tf

### Supported Metrics
- **percentProcessorTime**: CPU utilization percentage
- **usedmemorypercentage**: Memory usage percentage
- **serverLoad**: Redis server load percentage
- **connectedclients**: Number of active client connections
- **cachemissrate**: Percentage of cache misses vs hits
- **evictedkeys**: Number of keys evicted due to maxmemory limit
- **expiredkeys**: Number of expired keys removed
- **totalkeys**: Total number of keys in the cache
- **operationsPerSecond**: Number of operations per second
- **cacheRead**: Bytes read from cache per second
- **cacheWrite**: Bytes written to cache per second
- **totalcommandsprocessed**: Total commands processed since start

### Features
- Multi-instance support: Monitor multiple Redis caches with single module call
- Flexible alert configuration with individual enable flags
- Production-ready threshold defaults
- ShardId-level monitoring for clustered deployments
- Cross-subscription diagnostic settings
- Comprehensive examples for different scenarios
- Full output exposure for integration with other modules
- Tag-based resource organization

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Redis Cache (Microsoft.Cache/Redis)
- Azure Monitor Action Group
- (Optional) Event Hub for activity logs
- (Optional) Log Analytics workspace for security logs

### Permissions Required
- `Microsoft.Insights/metricAlerts/write` - Create and manage metric alerts
- `Microsoft.Insights/metricAlerts/read` - Read metric alert configurations
- `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
- `Microsoft.Insights/diagnosticSettings/read` - Read diagnostic settings
- `Microsoft.Cache/Redis/read` - Read Redis cache properties
- `Microsoft.Insights/actionGroups/read` - Read action group details
- `Microsoft.EventHub/namespaces/read` - Read Event Hub namespace (if using)
- `Microsoft.OperationalInsights/workspaces/read` - Read Log Analytics workspace (if using)

### Documentation
- Comprehensive README with usage examples
- Detailed variable descriptions
- Output documentation
- Examples directory with three deployment patterns
- Alert threshold recommendations by environment type

### Notes
- All thresholds can be customized based on workload requirements
- Diagnostic settings are optional and can be disabled
- ShardId dimension support enables per-shard monitoring in clustered deployments
- Cross-subscription diagnostic destinations supported for centralized logging
- Module follows Azure Monitor best practices
- Alerts use 5-minute evaluation frequency by default
- Compatible with Azure Redis Cache all tiers (Basic, Standard, Premium, Enterprise)

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
