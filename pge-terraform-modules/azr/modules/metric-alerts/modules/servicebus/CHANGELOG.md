# Changelog

All notable changes to the Azure Service Bus Monitoring Module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure Service Bus monitoring module
- Comprehensive metric alerting for Service Bus namespaces with 14 alert types:
  - **Request Metrics** (5 alerts):
    - Incoming requests monitoring
    - Successful requests low threshold detection
    - Server errors tracking
    - User errors monitoring
    - Throttled requests detection
  - **Message Metrics** (5 alerts):
    - Incoming messages monitoring
    - Outgoing messages tracking
    - Active messages count monitoring
    - Dead letter messages detection
    - Scheduled messages tracking
  - **Connection Metrics** (3 alerts):
    - Active connections monitoring
    - Connections opened tracking
    - Connections closed monitoring
  - **Resource Metrics** (1 alert):
    - Namespace size monitoring
- Diagnostic settings support with dual destination options:
  - Event Hub integration for activity logs and metrics
  - Log Analytics workspace integration for security logs and analysis
- Cross-subscription support for diagnostic destinations:
  - Event Hub can be in different subscription
  - Log Analytics workspace can be in different subscription
- Individual enable/disable flags for all 14 metric alerts
- Customizable thresholds for all metrics
- Dynamic resource discovery using data sources
- Action group integration for alert notifications
- Comprehensive tagging support for resource organization
- Three deployment examples:
  - Production: All 14 alerts with tight thresholds
  - Development: 10 key alerts with relaxed thresholds
  - Basic: 5 critical alerts with very relaxed thresholds
- Module outputs:
  - Alert IDs and names by category
  - Monitored resource information
  - Action group details
  - Diagnostic settings IDs
  - Configuration summary
- Input validation for resource groups, action groups, and thresholds
- Terraform Registry-ready structure with versions.tf

### Supported Metrics
- **IncomingRequests**: Total incoming requests to the namespace
- **SuccessfulRequests**: Total successful requests
- **ServerErrors**: Server-side error count
- **UserErrors**: User/client error count
- **ThrottledRequests**: Requests throttled due to limits
- **IncomingMessages**: Messages sent to Service Bus
- **OutgoingMessages**: Messages delivered from Service Bus
- **ActiveConnections**: Current active connections
- **ConnectionsOpened**: New connections established
- **ConnectionsClosed**: Connection closures
- **Size**: Namespace storage utilization in bytes
- **ActiveMessages**: Messages in active state
- **DeadletterMessages**: Messages in dead letter queue
- **ScheduledMessages**: Scheduled/deferred messages

### Features
- Multi-instance support: Monitor multiple Service Bus namespaces with single module call
- Flexible alert configuration with individual enable flags
- Production-ready threshold defaults
- Cross-subscription diagnostic settings
- Comprehensive examples for different scenarios
- Full output exposure for integration with other modules
- Tag-based resource organization
- Support for Standard and Premium Service Bus tiers

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure Service Bus Namespace (Microsoft.ServiceBus/namespaces)
- Azure Monitor Action Group
- (Optional) Event Hub for activity logs
- (Optional) Log Analytics workspace for security logs

### Permissions Required
- `Microsoft.Insights/metricAlerts/write` - Create and manage metric alerts
- `Microsoft.Insights/metricAlerts/read` - Read metric alert configurations
- `Microsoft.Insights/diagnosticSettings/write` - Configure diagnostic settings
- `Microsoft.Insights/diagnosticSettings/read` - Read diagnostic settings
- `Microsoft.ServiceBus/namespaces/read` - Read Service Bus namespace properties
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
- Individual alert enable flags provide fine-grained control
- Cross-subscription diagnostic destinations supported for centralized logging
- Module follows Azure Monitor best practices
- Alerts use 5-minute evaluation frequency by default
- Compatible with Service Bus Standard and Premium tiers

[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
