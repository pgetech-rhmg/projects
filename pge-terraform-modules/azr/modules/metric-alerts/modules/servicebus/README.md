# Azure Service Bus - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure Service Bus** namespaces, providing proactive monitoring for messaging infrastructure that enables reliable asynchronous communication between distributed applications. The module monitors critical metrics to ensure optimal message processing, connection management, and system reliability.

Azure Service Bus is a fully managed enterprise message broker with message queues and publish-subscribe topics. It provides features like message sessions, duplicate detection, dead lettering, scheduled delivery, and transactions for building scalable and reliable distributed applications.

## Features

- **Message Flow Monitoring**: Incoming and outgoing message tracking with volume alerts
- **Request Processing**: Incoming requests, successful requests, and error rate monitoring
- **Error Detection**: Server errors, user errors, and throttling alerts with different severity levels
- **Connection Management**: Active connections, connection lifecycle, and churn rate monitoring
- **Queue Management**: Active messages, dead letter queue, and scheduled message monitoring
- **Capacity Monitoring**: Namespace size and message count limits with proactive alerting
- **Performance Optimization**: Throttling detection and request success rate monitoring
- **Multi-Namespace Support**: Individual monitoring for each Service Bus namespace
- **Cost-Effective Alerting**: Metric alerts at $0.10 per month per alert rule
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **Real-Time Messaging**: 5-15 minute evaluation frequency for critical metrics
- **Error Classification**: Separate monitoring for server errors vs. user errors
- **Capacity Planning**: Proactive alerts for namespace size and message limits
- **Connection Health**: Active connection monitoring and churn rate detection
- **Message Lifecycle**: Complete message journey from ingestion to delivery
- **Dead Letter Monitoring**: Automatic detection of failed message processing

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.ServiceBus/namespaces/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Service Bus Namespaces**: Existing Azure Service Bus namespaces to monitor

## Usage

### Basic Configuration

```hcl
module "servicebus_alerts" {
  source = "./modules/metricAlerts/servicebus"
  
  # Resource Configuration
  resource_group_name               = "rg-production-messaging"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # Service Bus Namespaces to Monitor
  servicebus_namespace_names = [
    "sb-prod-orders-001",
    "sb-prod-notifications-001",
    "sb-prod-events-001"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "Messaging"
    Owner             = "integration-team@pge.com"
    CostCenter        = "IT-Integration"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "servicebus_alerts_high_volume" {
  source = "./modules/metricAlerts/servicebus"
  
  # Resource Configuration
  resource_group_name               = "rg-production-messaging"
  action_group_resource_group_name  = "rg-monitoring"
  servicebus_namespace_names        = ["sb-prod-high-volume"]
  
  # High-Volume Thresholds
  servicebus_incoming_requests_threshold   = 5000     # Higher request volume
  servicebus_incoming_messages_threshold   = 10000    # Higher message volume
  servicebus_outgoing_messages_threshold   = 10000    # Higher delivery volume
  
  # Connection Thresholds (High-Concurrency)
  servicebus_active_connections_threshold  = 500      # More concurrent connections
  servicebus_connections_opened_threshold  = 200      # Higher connection churn
  servicebus_connections_closed_threshold  = 200      # Higher connection churn
  
  # Capacity Thresholds (Enterprise Tier)
  servicebus_size_threshold               = 214748364800  # 200GB for Premium
  servicebus_active_messages_threshold    = 10000         # Higher message backlog
  
  # Stricter Error Monitoring
  servicebus_server_errors_threshold      = 2            # Lower error tolerance
  servicebus_user_errors_threshold        = 5            # Stricter user error limits
  servicebus_dead_letter_messages_threshold = 5          # Quick dead letter detection
  
  tags = {
    Environment = "Production"
    Tier        = "High-Volume"
    Owner       = "platform-messaging@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Service Bus - Relaxed Thresholds
servicebus_incoming_requests_threshold    = 2000
servicebus_server_errors_threshold        = 20
servicebus_user_errors_threshold         = 50
servicebus_active_connections_threshold   = 50
servicebus_size_threshold                = 10737418240  # 10GB
```

#### Staging Environment
```hcl
# Staging Service Bus - Moderate Thresholds
servicebus_incoming_requests_threshold    = 1500
servicebus_server_errors_threshold        = 10
servicebus_user_errors_threshold         = 25
servicebus_active_connections_threshold   = 75
servicebus_size_threshold                = 53687091200  # 50GB
```

#### Production Environment
```hcl
# Production Service Bus - Strict Thresholds
servicebus_incoming_requests_threshold    = 1000
servicebus_server_errors_threshold        = 5
servicebus_user_errors_threshold         = 10
servicebus_active_connections_threshold   = 100
servicebus_size_threshold                = 85899345920  # 80GB
```

### Tier-Specific Configurations

#### Basic Tier
```hcl
# Basic Tier - Limited Throughput
servicebus_incoming_messages_threshold    = 100
servicebus_active_connections_threshold   = 20
servicebus_size_threshold                = 1073741824   # 1GB
```

#### Standard Tier
```hcl
# Standard Tier - Moderate Throughput
servicebus_incoming_messages_threshold    = 1000
servicebus_active_connections_threshold   = 100
servicebus_size_threshold                = 85899345920  # 80GB
```

#### Premium Tier
```hcl
# Premium Tier - High Throughput
servicebus_incoming_messages_threshold    = 10000
servicebus_active_connections_threshold   = 1000
servicebus_size_threshold                = 1099511627776 # 1TB
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for Service Bus namespaces |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
| `servicebus_namespace_names` | `list(string)` | `[]` | List of Service Bus namespace names |

### Alert Enable Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_servicebus_incoming_requests_alert` | `bool` | `true` | Enable incoming requests monitoring |
| `enable_servicebus_successful_requests_alert` | `bool` | `true` | Enable successful requests monitoring |
| `enable_servicebus_server_errors_alert` | `bool` | `true` | Enable server errors monitoring |
| `enable_servicebus_user_errors_alert` | `bool` | `true` | Enable user errors monitoring |
| `enable_servicebus_throttled_requests_alert` | `bool` | `true` | Enable throttled requests monitoring |
| `enable_servicebus_incoming_messages_alert` | `bool` | `true` | Enable incoming messages monitoring |
| `enable_servicebus_outgoing_messages_alert` | `bool` | `true` | Enable outgoing messages monitoring |
| `enable_servicebus_active_connections_alert` | `bool` | `true` | Enable active connections monitoring |
| `enable_servicebus_connections_opened_alert` | `bool` | `true` | Enable connections opened monitoring |
| `enable_servicebus_connections_closed_alert` | `bool` | `true` | Enable connections closed monitoring |
| `enable_servicebus_size_alert` | `bool` | `true` | Enable namespace size monitoring |
| `enable_servicebus_active_messages_alert` | `bool` | `true` | Enable active messages monitoring |
| `enable_servicebus_dead_letter_messages_alert` | `bool` | `true` | Enable dead letter messages monitoring |
| `enable_servicebus_scheduled_messages_alert` | `bool` | `true` | Enable scheduled messages monitoring |

### Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `servicebus_incoming_requests_threshold` | `number` | `1000` | Incoming requests per minute | 100-10K |
| `servicebus_successful_requests_threshold` | `number` | `10` | Successful requests per minute | 5-100 |
| `servicebus_server_errors_threshold` | `number` | `5` | Server errors per minute | 1-50 |
| `servicebus_user_errors_threshold` | `number` | `10` | User errors per minute | 5-100 |
| `servicebus_throttled_requests_threshold` | `number` | `5` | Throttled requests per minute | 1-50 |
| `servicebus_incoming_messages_threshold` | `number` | `1000` | Incoming messages per minute | 100-50K |
| `servicebus_outgoing_messages_threshold` | `number` | `1000` | Outgoing messages per minute | 100-50K |
| `servicebus_active_connections_threshold` | `number` | `100` | Active connections count | 10-5K |
| `servicebus_connections_opened_threshold` | `number` | `50` | Connections opened per minute | 10-1K |
| `servicebus_connections_closed_threshold` | `number` | `50` | Connections closed per minute | 10-1K |
| `servicebus_size_threshold` | `number` | `85899345920` | Namespace size in bytes (80GB) | 1GB-1TB |
| `servicebus_active_messages_threshold` | `number` | `1000` | Active messages count | 100-1M |
| `servicebus_dead_letter_messages_threshold` | `number` | `10` | Dead letter messages count | 1-1K |
| `servicebus_scheduled_messages_threshold` | `number` | `100` | Scheduled messages count | 10-10K |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                          # Application identifier
  Env                = "Production"                      # Environment designation
  Owner              = "integration-team@pge.com"       # Team responsible
  Compliance         = "SOX"                             # Compliance requirement
  Notify             = "messaging-oncall@pge.com"       # Notification contact
  DataClassification = "Internal"                        # Data sensitivity
  CostCenter         = "IT-Integration"                  # Billing allocation
  CRIS               = "CRIS-12345"                     # Change request ID
}
```

## Alert Details

### 1. Incoming Requests Alert
- **Alert Name**: `servicebus-incoming-requests-high-{namespace-names}`
- **Metric**: `IncomingRequests`
- **Threshold**: 1,000 requests/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Total number of incoming requests to the Service Bus namespace per minute, indicating overall API usage and load.

**What to do when this alert fires**:
1. **Load Assessment**: Check current application load and message processing patterns
2. **Capacity Planning**: Evaluate if current tier can handle the request volume
3. **Scaling Strategy**: Consider upgrading to higher tier or implementing load balancing
4. **Client Analysis**: Review client applications for request patterns and optimization opportunities
5. **Performance Monitoring**: Monitor request success rates and response times

### 2. Successful Requests Low Alert
- **Alert Name**: `servicebus-successful-requests-low-{namespace-names}`
- **Metric**: `SuccessfulRequests`
- **Threshold**: 10 requests/minute (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: Number of successful requests falling below expected levels, potentially indicating service disruption or client connectivity issues.

**What to do when this alert fires**:
1. **Service Health**: Check Service Bus namespace availability and status
2. **Client Connectivity**: Verify client applications can connect to Service Bus
3. **Authentication**: Ensure connection strings and SAS tokens are valid
4. **Network Issues**: Check network connectivity and firewall configurations
5. **Error Investigation**: Review server and user error rates for root cause analysis

### 3. Server Errors Alert
- **Alert Name**: `servicebus-server-errors-high-{namespace-names}`
- **Metric**: `ServerErrors`
- **Threshold**: 5 errors/minute (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Server-side errors within the Service Bus service, indicating potential service issues or resource constraints.

**What to do when this alert fires**:
1. **Immediate Assessment**: Check Azure Service Health for Service Bus issues
2. **Service Limits**: Verify namespace isn't hitting throughput or connection limits
3. **Resource Utilization**: Monitor namespace capacity and message quotas
4. **Escalation**: Contact Azure Support if widespread server errors persist
5. **Disaster Recovery**: Activate backup messaging infrastructure if available

### 4. User Errors Alert
- **Alert Name**: `servicebus-user-errors-high-{namespace-names}`
- **Metric**: `UserErrors`
- **Threshold**: 10 errors/minute (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Client-side errors such as authentication failures, malformed requests, or permission issues.

**What to do when this alert fires**:
1. **Authentication Review**: Check SAS tokens, connection strings, and managed identity configuration
2. **Permission Analysis**: Verify client applications have appropriate Service Bus permissions
3. **Request Validation**: Review message formats and API usage patterns
4. **Client Code Review**: Examine client application error handling and retry logic
5. **Documentation**: Update client documentation and error handling best practices

### 5. Throttled Requests Alert
- **Alert Name**: `servicebus-throttled-requests-high-{namespace-names}`
- **Metric**: `ThrottledRequests`
- **Threshold**: 5 requests/minute (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Requests being throttled due to exceeding throughput limits or rate limiting policies.

**What to do when this alert fires**:
1. **Throughput Analysis**: Review current throughput against namespace limits
2. **Tier Evaluation**: Consider upgrading to higher Service Bus tier
3. **Load Distribution**: Implement client-side rate limiting and backoff strategies
4. **Scaling Strategy**: Distribute load across multiple namespaces if needed
5. **Client Optimization**: Optimize client batch sizes and connection patterns

### 6. Incoming Messages Alert
- **Alert Name**: `servicebus-incoming-messages-high-{namespace-names}`
- **Metric**: `IncomingMessages`
- **Threshold**: 1,000 messages/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: High volume of incoming messages that may indicate increased application activity or potential message processing bottlenecks.

**What to do when this alert fires**:
1. **Processing Capacity**: Ensure adequate message processing capacity and consumers
2. **Queue Monitoring**: Check queue depths and processing rates
3. **Auto-Scaling**: Implement auto-scaling for message processing applications
4. **Backlog Management**: Monitor active message counts to prevent queue buildup
5. **Performance Optimization**: Optimize message processing logic and batch sizes

### 7. Outgoing Messages Alert
- **Alert Name**: `servicebus-outgoing-messages-low-{namespace-names}`
- **Metric**: `OutgoingMessages`
- **Threshold**: 1,000 messages/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: High volume of outgoing messages indicating successful message delivery to consumers.

**What to do when this alert fires**:
1. **Consumer Health**: Verify message consumers are processing messages successfully
2. **Processing Rate**: Monitor message processing rates and consumer performance
3. **Scaling Assessment**: Evaluate if additional consumers or processing capacity needed
4. **Queue Management**: Ensure balanced message distribution across consumers
5. **Performance Monitoring**: Track end-to-end message processing times

### 8. Active Connections Alert
- **Alert Name**: `servicebus-active-connections-high-{namespace-names}`
- **Metric**: `ActiveConnections`
- **Threshold**: 100 connections (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Average

**What this alert monitors**: Number of active connections to the Service Bus namespace, indicating client activity and resource usage.

**What to do when this alert fires**:
1. **Connection Limits**: Check namespace connection limits and current usage
2. **Client Analysis**: Review client applications for connection pooling and management
3. **Connection Optimization**: Implement connection sharing and reuse strategies
4. **Scaling Strategy**: Consider tier upgrade or connection limit increases
5. **Monitoring Setup**: Track connection patterns and identify optimization opportunities

### 9. Connections Opened Alert
- **Alert Name**: `servicebus-connections-opened-high-{namespace-names}`
- **Metric**: `ConnectionsOpened`
- **Threshold**: 50 connections/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: Rate of new connections being established, indicating potential connection churn or scaling activity.

**What to do when this alert fires**:
1. **Connection Churn Analysis**: Investigate reasons for frequent connection creation
2. **Client Optimization**: Review client connection management and pooling strategies
3. **Authentication Issues**: Check for authentication failures causing reconnections
4. **Network Stability**: Verify network connectivity stability
5. **Performance Impact**: Monitor impact of connection churn on namespace performance

### 10. Connections Closed Alert
- **Alert Name**: `servicebus-connections-closed-high-{namespace-names}`
- **Metric**: `ConnectionsClosed`
- **Threshold**: 50 connections/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Total

**What this alert monitors**: Rate of connections being closed, which may indicate client issues or network problems.

**What to do when this alert fires**:
1. **Connection Stability**: Investigate causes of frequent connection termination
2. **Client Behavior**: Review client application connection handling and cleanup
3. **Network Issues**: Check for network timeouts or connectivity problems
4. **Error Correlation**: Correlate with error metrics to identify root causes
5. **Client Updates**: Update client applications with better connection management

### 11. Namespace Size Alert
- **Alert Name**: `servicebus-size-high-{namespace-names}`
- **Metric**: `Size`
- **Threshold**: 80GB (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Average

**What this alert monitors**: Total size of data stored in the Service Bus namespace, indicating capacity utilization.

**What to do when this alert fires**:
1. **Capacity Planning**: Review namespace size limits and current usage patterns
2. **Message Cleanup**: Implement message retention policies and cleanup procedures
3. **Queue Management**: Analyze queue sizes and implement appropriate TTL settings
4. **Tier Upgrade**: Consider upgrading to higher tier with more storage capacity
5. **Data Archival**: Implement message archival strategies for long-term storage

### 12. Active Messages Alert
- **Alert Name**: `servicebus-active-messages-high-{namespace-names}`
- **Metric**: `ActiveMessages`
- **Threshold**: 1,000 messages (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Average

**What this alert monitors**: Number of active messages across all queues and subscriptions, indicating message backlog and processing efficiency.

**What to do when this alert fires**:
1. **Processing Bottlenecks**: Identify queues with high message counts
2. **Consumer Scaling**: Increase number of message consumers or processing instances
3. **Processing Optimization**: Optimize message processing logic and performance
4. **Queue Analysis**: Review individual queue configurations and processing patterns
5. **Load Balancing**: Distribute message processing load across multiple consumers

### 13. Dead Letter Messages Alert
- **Alert Name**: `servicebus-dead-letter-messages-high-{namespace-names}`
- **Metric**: `DeadletteredMessages`
- **Threshold**: 10 messages (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Average

**What this alert monitors**: Messages that have been moved to dead letter queues due to processing failures or expiration.

**What to do when this alert fires**:
1. **Message Analysis**: Examine dead letter queue contents to identify failure patterns
2. **Processing Logic**: Review message processing code for error handling improvements
3. **Message Format**: Validate message formats and schema compliance
4. **Retry Policies**: Optimize message retry policies and failure handling
5. **Dead Letter Processing**: Implement dead letter queue monitoring and reprocessing procedures

### 14. Scheduled Messages Alert
- **Alert Name**: `servicebus-scheduled-messages-high-{namespace-names}`
- **Metric**: `ScheduledMessages`
- **Threshold**: 100 messages (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT15M (15 minutes)
- **Window**: PT30M (30 minutes)
- **Aggregation**: Average

**What this alert monitors**: Number of messages scheduled for future delivery, indicating deferred message processing load.

**What to do when this alert fires**:
1. **Scheduling Patterns**: Review message scheduling patterns and business requirements
2. **Capacity Planning**: Ensure adequate capacity for scheduled message processing
3. **Schedule Optimization**: Optimize scheduled message timing to balance load
4. **Processing Preparation**: Prepare for scheduled message processing peaks
5. **Resource Allocation**: Allocate appropriate resources for scheduled message handling

## Severity Levels

### Severity 1 (Critical) - Service Disruption
- **Server Errors**: Infrastructure issues requiring immediate attention

**Response Time**: 5 minutes
**Escalation**: Immediate page to on-call engineer and Azure Support contact

### Severity 2 (High) - Functional Impact
- **Successful Requests Low**: Service functionality disruption
- **User Errors**: Client connectivity and authentication issues
- **Throttled Requests**: Performance and capacity constraints
- **Namespace Size**: Capacity limits approaching
- **Active Messages**: Message processing backlog
- **Dead Letter Messages**: Message processing failures

**Response Time**: 15 minutes
**Escalation**: Immediate notification to messaging team and on-call engineer

### Severity 3 (Medium) - Performance Monitoring
- **Incoming Requests**: Load monitoring and capacity planning
- **Incoming/Outgoing Messages**: Throughput monitoring
- **Connection Metrics**: Connection management and optimization
- **Scheduled Messages**: Deferred processing monitoring

**Response Time**: 30 minutes
**Escalation**: Standard operational notification

## Cost Analysis

### Alert Costs (Monthly)
- **14 Metric Alerts per Service Bus Namespace**: 14 × $0.10 = **$1.40 per namespace**
- **Multi-Namespace Deployment**: Scales linearly with namespace count
- **Action Group**: FREE (included)

### Cost Examples by Environment

#### Small Messaging Infrastructure (2 Namespaces)
- **Monthly Alert Cost**: $2.80
- **Annual Alert Cost**: $33.60

#### Medium Enterprise Messaging (5 Namespaces)
- **Monthly Alert Cost**: $7.00
- **Annual Alert Cost**: $84.00

#### Large Distributed System (15 Namespaces)
- **Monthly Alert Cost**: $21.00
- **Annual Alert Cost**: $252.00

#### Enterprise Multi-Region Platform (50 Namespaces)
- **Monthly Alert Cost**: $70.00
- **Annual Alert Cost**: $840.00

### Return on Investment (ROI)

#### Cost of Service Bus Issues
- **Message Loss**: Critical business data loss with regulatory implications
- **Processing Delays**: 2-4 hour delays in business process execution
- **System Integration Failures**: Cascading failures across integrated systems
- **Business Impact**: $75,000/hour for order processing, $25,000/hour for notifications
- **Compliance Violations**: SOX compliance issues with audit trail gaps
- **Customer Experience**: Service degradation and transaction failures

#### Alert Value Calculation
- **Monthly Alert Cost**: $1.40 per Service Bus namespace
- **Prevented Downtime**: 3 hours/month average per namespace
- **Cost Avoidance**: $150,000/month for critical messaging infrastructure
- **ROI**: 10,714,186% (($150,000 - $1.40) / $1.40 × 100)

#### Additional Benefits
- **Proactive Issue Detection**: Identify problems before business impact
- **Message Integrity**: Ensure reliable message delivery and processing
- **Capacity Planning**: Data-driven scaling and capacity decisions
- **Performance Optimization**: Optimize message throughput and processing efficiency
- **Compliance Assurance**: Maintain audit trails and regulatory compliance

### Service Bus Pricing Context
- **Basic Tier**: $0.05 per million operations
- **Standard Tier**: $0.80/month base + $0.05 per million operations
- **Premium Tier**: $677.15/month per messaging unit

**Alert Cost as % of Service Bus Cost**: 0.2% - 4% of monthly Service Bus costs

## Best Practices

### Deployment Best Practices

#### 1. Environment-Specific Configuration
```hcl
# Development Environment - Relaxed monitoring
servicebus_server_errors_threshold     = 20
servicebus_dead_letter_messages_threshold = 50

# Staging Environment - Moderate monitoring  
servicebus_server_errors_threshold     = 10
servicebus_dead_letter_messages_threshold = 25

# Production Environment - Strict monitoring
servicebus_server_errors_threshold     = 5
servicebus_dead_letter_messages_threshold = 10
```

#### 2. Tier-Appropriate Thresholds
- **Basic Tier**: Higher thresholds due to limited throughput (100 messages/min)
- **Standard Tier**: Moderate thresholds for typical workloads (1K messages/min)
- **Premium Tier**: Lower thresholds for high-performance requirements (10K messages/min)

#### 3. Multi-Region Deployment
- Configure region-specific action groups for faster response
- Implement cross-region failover monitoring
- Adjust thresholds for network latency differences

### Service Bus Configuration Best Practices

#### 1. Message Processing Optimization
```csharp
// Implement efficient message processing
var processor = client.CreateProcessor(queueName, new ServiceBusProcessorOptions
{
    MaxConcurrentCalls = 10,
    AutoCompleteMessages = false,
    MaxAutoLockRenewalDuration = TimeSpan.FromMinutes(10),
    PrefetchCount = 20
});

// Handle messages with proper error handling
processor.ProcessMessageAsync += async args =>
{
    try
    {
        // Process message
        await ProcessBusinessLogic(args.Message);
        await args.CompleteMessageAsync(args.Message);
    }
    catch (Exception ex)
    {
        // Log error and decide on retry or dead letter
        await args.DeadLetterMessageAsync(args.Message, "ProcessingError", ex.Message);
    }
};
```

#### 2. Connection Management
```csharp
// Use connection pooling and singleton pattern
public class ServiceBusClientFactory
{
    private static readonly ServiceBusClient _client = new ServiceBusClient(connectionString);
    
    public static ServiceBusClient GetClient() => _client;
    
    // Implement proper disposal
    public static async Task DisposeAsync()
    {
        await _client.DisposeAsync();
    }
}
```

#### 3. Message Design Patterns
```csharp
// Implement message envelope pattern
public class MessageEnvelope<T>
{
    public string MessageId { get; set; } = Guid.NewGuid().ToString();
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public string MessageType { get; set; } = typeof(T).Name;
    public T Payload { get; set; }
    public Dictionary<string, object> Properties { get; set; } = new();
}

// Use structured logging for message correlation
public async Task SendMessageAsync<T>(T message, string correlationId = null)
{
    var envelope = new MessageEnvelope<T> { Payload = message };
    var serviceBusMessage = new ServiceBusMessage(JsonSerializer.Serialize(envelope))
    {
        MessageId = envelope.MessageId,
        CorrelationId = correlationId ?? Guid.NewGuid().ToString(),
        ContentType = "application/json"
    };
    
    await sender.SendMessageAsync(serviceBusMessage);
}
```

### Monitoring Best Practices

#### 1. Baseline Establishment
- Monitor for 2-4 weeks to establish message volume baselines
- Identify peak processing times and seasonal patterns
- Document normal vs. exceptional messaging patterns

#### 2. Message Flow Analysis
```bash
# Monitor message flow patterns
az servicebus namespace show \
  --name "sb-prod-namespace" \
  --resource-group "rg-production" \
  --query "serviceBusEndpoint"

# Check queue and topic metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ServiceBus/namespaces/{name}" \
  --metric "IncomingMessages,OutgoingMessages,ActiveMessages" \
  --interval PT15M
```

#### 3. Dead Letter Queue Management
```csharp
// Implement dead letter queue monitoring
public async Task<List<ServiceBusReceivedMessage>> GetDeadLetterMessagesAsync(string queueName)
{
    var deadLetterReceiver = client.CreateReceiver(queueName, 
        new ServiceBusReceiverOptions { SubQueue = SubQueue.DeadLetter });
    
    var messages = new List<ServiceBusReceivedMessage>();
    await foreach (var message in deadLetterReceiver.ReceiveMessagesAsync(maxMessages: 100))
    {
        messages.Add(message);
        // Log dead letter reason
        Console.WriteLine($"Dead Letter Reason: {message.DeadLetterReason}");
        Console.WriteLine($"Dead Letter Description: {message.DeadLetterErrorDescription}");
    }
    
    return messages;
}
```

### Security and Compliance Best Practices

#### 1. Authentication and Authorization
```csharp
// Use Managed Identity for authentication
var client = new ServiceBusClient("sb-namespace.servicebus.windows.net", 
    new DefaultAzureCredential());

// Implement least privilege access
// Create separate SAS policies for different operations
// Send-only policy for producers
// Listen-only policy for consumers
// Manage policy for administrative operations
```

#### 2. Message Encryption
```csharp
// Implement message-level encryption for sensitive data
public class EncryptedMessage
{
    public string EncryptedPayload { get; set; }
    public string KeyId { get; set; }
    public string Algorithm { get; set; } = "AES-256-GCM";
}

public async Task SendEncryptedMessageAsync<T>(T sensitiveData, string keyId)
{
    var encrypted = await encryptionService.EncryptAsync(
        JsonSerializer.Serialize(sensitiveData), keyId);
    
    var encryptedMessage = new EncryptedMessage 
    { 
        EncryptedPayload = encrypted,
        KeyId = keyId 
    };
    
    await SendMessageAsync(encryptedMessage);
}
```

#### 3. Compliance Requirements
- **SOX**: Maintain message audit trails and processing logs
- **HIPAA**: Encrypt PHI in messages and implement access controls
- **PCI-DSS**: Secure payment-related messages with end-to-end encryption
- **GDPR**: Implement message retention policies and data deletion procedures

### Application Integration Best Practices

#### 1. Retry Policies and Circuit Breakers
```csharp
// Implement exponential backoff retry policy
public class ServiceBusRetryPolicy
{
    private readonly TimeSpan[] _delays = {
        TimeSpan.FromSeconds(1),
        TimeSpan.FromSeconds(2),
        TimeSpan.FromSeconds(5),
        TimeSpan.FromSeconds(10),
        TimeSpan.FromSeconds(30)
    };
    
    public async Task<bool> ExecuteWithRetryAsync(Func<Task> operation, int maxAttempts = 5)
    {
        for (int attempt = 0; attempt < maxAttempts; attempt++)
        {
            try
            {
                await operation();
                return true;
            }
            catch (ServiceBusException ex) when (ex.IsTransient)
            {
                if (attempt == maxAttempts - 1) throw;
                await Task.Delay(_delays[Math.Min(attempt, _delays.Length - 1)]);
            }
        }
        return false;
    }
}
```

#### 2. Message Deduplication
```csharp
// Implement idempotent message processing
public class IdempotentMessageProcessor
{
    private readonly IDistributedCache _cache;
    
    public async Task<bool> ProcessIfNotProcessedAsync(ServiceBusReceivedMessage message, 
        Func<ServiceBusReceivedMessage, Task> processor)
    {
        var messageId = message.MessageId;
        var cacheKey = $"processed_message_{messageId}";
        
        // Check if already processed
        var processed = await _cache.GetStringAsync(cacheKey);
        if (processed != null) return false; // Already processed
        
        try
        {
            await processor(message);
            
            // Mark as processed with TTL
            await _cache.SetStringAsync(cacheKey, "processed", 
                new DistributedCacheEntryOptions 
                { 
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24) 
                });
            
            return true;
        }
        catch
        {
            // Don't mark as processed on failure
            throw;
        }
    }
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. High Server Error Rate
**Symptoms**: Server errors alert firing with service degradation

**Possible Causes**:
- Service Bus service issues or outages
- Namespace hitting throughput or connection limits
- Resource constraints in Azure region
- Network connectivity issues

**Troubleshooting Steps**:
```bash
# Check Service Bus service health
az rest --method GET --url "https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2018-07-01&$filter=resourceType eq 'Microsoft.ServiceBus/namespaces'"

# Monitor namespace metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ServiceBus/namespaces/{name}" \
  --metric "ServerErrors,ThrottledRequests,IncomingRequests" \
  --interval PT5M

# Check namespace limits and usage
az servicebus namespace show --name {namespace} --resource-group {rg}
```

**Resolution**:
- Check Azure Service Health dashboard for Service Bus issues
- Review namespace tier limits and consider upgrade
- Implement client-side retry logic with exponential backoff
- Contact Azure Support for persistent service issues

#### 2. High Dead Letter Queue Messages
**Symptoms**: Dead letter messages alert with processing failures

**Possible Causes**:
- Message processing logic errors
- Message format or schema issues
- Processing timeouts or lock duration exceeded
- Poison message scenarios

**Troubleshooting Steps**:
```csharp
// Analyze dead letter queue contents
public async Task AnalyzeDeadLetterMessagesAsync(string queueName)
{
    var receiver = client.CreateReceiver(queueName, 
        new ServiceBusReceiverOptions { SubQueue = SubQueue.DeadLetter });
    
    await foreach (var message in receiver.ReceiveMessagesAsync(maxMessages: 10))
    {
        Console.WriteLine($"Message ID: {message.MessageId}");
        Console.WriteLine($"Dead Letter Reason: {message.DeadLetterReason}");
        Console.WriteLine($"Dead Letter Description: {message.DeadLetterErrorDescription}");
        Console.WriteLine($"Delivery Count: {message.DeliveryCount}");
        Console.WriteLine($"Enqueued Time: {message.EnqueuedTime}");
        Console.WriteLine($"Message Body: {message.Body}");
        Console.WriteLine("---");
    }
}
```

**Resolution**:
- Analyze dead letter messages for common failure patterns
- Review and fix message processing logic
- Implement proper error handling and validation
- Consider message schema validation before processing
- Implement dead letter message reprocessing procedures

#### 3. Message Processing Backlog
**Symptoms**: Active messages alert with growing message queues

**Possible Causes**:
- Insufficient message consumers or processing capacity
- Slow message processing logic
- Downstream service dependencies causing delays
- Consumer application failures or scaling issues

**Troubleshooting Steps**:
```bash
# Monitor queue depths and processing rates
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ServiceBus/namespaces/{name}" \
  --metric "ActiveMessages,IncomingMessages,OutgoingMessages" \
  --interval PT15M

# Check individual queue statistics
az servicebus queue show --namespace-name {namespace} --name {queue} --resource-group {rg}
```

**Resolution**:
- Scale out message processing applications
- Optimize message processing logic for performance
- Implement parallel processing and batching strategies
- Monitor and optimize downstream service dependencies
- Consider implementing message processing priorities

#### 4. Connection Churn Issues
**Symptoms**: High connection opened/closed rates with performance impact

**Possible Causes**:
- Client applications not using connection pooling
- Network connectivity issues causing reconnections
- Authentication failures or token expiration
- Aggressive connection timeout settings

**Troubleshooting Steps**:
```bash
# Monitor connection patterns
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ServiceBus/namespaces/{name}" \
  --metric "ActiveConnections,ConnectionsOpened,ConnectionsClosed" \
  --interval PT5M

# Check for authentication errors
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ServiceBus/namespaces/{name}" \
  --metric "UserErrors" \
  --interval PT5M
```

**Resolution**:
- Implement proper connection pooling in client applications
- Review and optimize connection timeout settings
- Fix authentication issues and token renewal logic
- Monitor network stability and address connectivity issues
- Implement connection health monitoring and graceful reconnection

### Performance Optimization Strategies

#### 1. Message Throughput Optimization
```csharp
// Implement batch message processing
public async Task ProcessMessagesBatchAsync(int batchSize = 10)
{
    var processor = client.CreateProcessor(queueName, new ServiceBusProcessorOptions
    {
        MaxConcurrentCalls = Environment.ProcessorCount * 2,
        PrefetchCount = batchSize * 2,
        MaxAutoLockRenewalDuration = TimeSpan.FromMinutes(5)
    });
    
    var messageBatch = new List<ServiceBusReceivedMessage>();
    
    processor.ProcessMessageAsync += async args =>
    {
        lock (messageBatch)
        {
            messageBatch.Add(args.Message);
        }
        
        if (messageBatch.Count >= batchSize)
        {
            var batch = messageBatch.ToList();
            messageBatch.Clear();
            
            await ProcessBatchAsync(batch);
            
            // Complete all messages in batch
            foreach (var msg in batch)
            {
                await args.CompleteMessageAsync(msg);
            }
        }
    };
}
```

#### 2. Connection Optimization
```csharp
// Implement connection factory with pooling
public class OptimizedServiceBusClient
{
    private static readonly ConcurrentDictionary<string, ServiceBusClient> _clients = new();
    
    public static ServiceBusClient GetClient(string connectionString)
    {
        return _clients.GetOrAdd(connectionString, cs => new ServiceBusClient(cs, new ServiceBusClientOptions
        {
            RetryOptions = new ServiceBusRetryOptions
            {
                Mode = ServiceBusRetryMode.Exponential,
                MaxRetries = 3,
                MaxDelay = TimeSpan.FromMinutes(1)
            },
            TransportType = ServiceBusTransportType.AmqpWebSockets // For firewall compatibility
        }));
    }
}
```

#### 3. Message Size Optimization
```csharp
// Implement message compression for large payloads
public class CompressedMessage
{
    public bool IsCompressed { get; set; }
    public byte[] Data { get; set; }
    public string CompressionAlgorithm { get; set; } = "gzip";
}

public async Task SendLargeMessageAsync<T>(T largePayload)
{
    var json = JsonSerializer.Serialize(largePayload);
    var bytes = Encoding.UTF8.GetBytes(json);
    
    if (bytes.Length > 64 * 1024) // Compress if > 64KB
    {
        using var compressed = new MemoryStream();
        using (var gzip = new GZipStream(compressed, CompressionMode.Compress))
        {
            await gzip.WriteAsync(bytes, 0, bytes.Length);
        }
        
        var compressedMessage = new CompressedMessage 
        { 
            IsCompressed = true,
            Data = compressed.ToArray()
        };
        
        await SendMessageAsync(compressedMessage);
    }
    else
    {
        await SendMessageAsync(largePayload);
    }
}
```

### Advanced Monitoring and Diagnostics

#### 1. Custom Metrics Implementation
```csharp
// Implement custom telemetry for Service Bus operations
public class ServiceBusTelemetry
{
    private readonly TelemetryClient _telemetryClient;
    
    public ServiceBusTelemetry(TelemetryClient telemetryClient)
    {
        _telemetryClient = telemetryClient;
    }
    
    public void TrackMessageSent(string queueName, TimeSpan processingTime, bool success)
    {
        _telemetryClient.TrackDependency("ServiceBus", "Send", queueName, 
            DateTime.UtcNow.Subtract(processingTime), processingTime, success);
        
        _telemetryClient.TrackMetric("ServiceBus.MessageSent.ProcessingTime", 
            processingTime.TotalMilliseconds, 
            new Dictionary<string, string> { ["QueueName"] = queueName });
    }
    
    public void TrackMessageProcessed(string queueName, TimeSpan processingTime, 
        bool success, int retryCount = 0)
    {
        _telemetryClient.TrackMetric("ServiceBus.MessageProcessed.ProcessingTime", 
            processingTime.TotalMilliseconds,
            new Dictionary<string, string> 
            { 
                ["QueueName"] = queueName,
                ["Success"] = success.ToString(),
                ["RetryCount"] = retryCount.ToString()
            });
    }
}
```

#### 2. Health Check Implementation
```bash
#!/bin/bash
# Service Bus health check script

SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="your-resource-group"
NAMESPACE_NAME="your-servicebus-namespace"

echo "Checking Service Bus Namespace: $NAMESPACE_NAME"

# Check namespace status
NAMESPACE_STATUS=$(az servicebus namespace show \
  --name "$NAMESPACE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "status" -o tsv)

echo "Namespace Status: $NAMESPACE_STATUS"

# Check active messages across all queues
ACTIVE_MESSAGES=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ServiceBus/namespaces/$NAMESPACE_NAME" \
  --metric "ActiveMessages" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv)

echo "Active Messages: ${ACTIVE_MESSAGES:-0}"

# Check error rates
SERVER_ERRORS=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ServiceBus/namespaces/$NAMESPACE_NAME" \
  --metric "ServerErrors" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].total" -o tsv)

echo "Server Errors (last 5 min): ${SERVER_ERRORS:-0}"

# Health assessment
if [ "$NAMESPACE_STATUS" != "Active" ]; then
  echo "CRITICAL: Namespace is not active"
  exit 2
fi

if [ "$ACTIVE_MESSAGES" != "null" ] && (( $(echo "$ACTIVE_MESSAGES > 5000" | bc -l) )); then
  echo "WARNING: High active message count detected"
fi

if [ "$SERVER_ERRORS" != "null" ] && (( $(echo "$SERVER_ERRORS > 0" | bc -l) )); then
  echo "WARNING: Server errors detected"
fi

echo "Health check completed"
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Service Bus monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual message processing patterns and business requirements is recommended for optimal monitoring effectiveness.