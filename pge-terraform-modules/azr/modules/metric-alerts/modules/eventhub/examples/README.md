# Azure Event Hub Monitoring Alerts - Examples

This directory contains example configurations for deploying the Event Hub monitoring alerts module with different configurations.

## Examples

### 1. Production Deployment
A comprehensive production setup with:
- All 14 metric alerts enabled
- Strict thresholds for production workloads
- Full diagnostic settings (Event Hub + Log Analytics)
- Monitoring multiple Event Hub namespaces

### 2. Development Deployment
A development-focused configuration with:
- Only critical error alerts enabled
- Relaxed thresholds suitable for dev/test environments
- Log Analytics only (no Event Hub)
- Single namespace monitoring

### 3. Basic Deployment
A minimal configuration using:
- Default threshold values
- Standard alert configuration
- No diagnostic settings
- Quick setup for testing

## Alert Types

The module supports the following metric alerts for Event Hubs:

### Request Monitoring
1. **Incoming Requests** - Tracks the volume of incoming requests
   - Default threshold: 10,000 requests
   - Helps detect unusual traffic spikes

2. **Successful Requests (Low)** - Monitors when successful requests drop below threshold
   - Default threshold: 50 successful requests
   - Indicates potential connectivity or processing issues

### Error Monitoring
3. **Server Errors** - Monitors server-side errors
   - Default threshold: 1 error
   - Critical for identifying Event Hub service issues

4. **User Errors** - Tracks client-side errors
   - Default threshold: 10 errors
   - Helps identify client configuration or usage issues

5. **Throttled Requests** - Monitors throttling events
   - Default threshold: 1 throttled request
   - Indicates capacity or throughput unit limitations

6. **Quota Exceeded** - Tracks quota violations
   - Default threshold: 1 exceeded event
   - Critical for capacity planning

### Message Throughput
7. **Incoming Messages** - Monitors incoming message volume
   - Default threshold: 100,000 messages
   - Helps track message ingestion patterns

8. **Outgoing Messages** - Tracks outgoing message volume
   - Default threshold: 100,000 messages
   - Helps monitor message consumption patterns

### Data Throughput
9. **Incoming Bytes** - Monitors incoming data volume
   - Default threshold: 1,000,000,000 bytes (1 GB)
   - Tracks data ingestion bandwidth

10. **Outgoing Bytes** - Tracks outgoing data volume
    - Default threshold: 1,000,000,000 bytes (1 GB)
    - Monitors data egress bandwidth

### Connection Monitoring
11. **Active Connections** - Monitors current active connections
    - Default threshold: 5,000 connections
    - Helps detect connection storms or capacity issues

12. **Connections Opened** - Tracks new connection rate
    - Default threshold: 1,000 connections opened
    - Identifies connection churn patterns

13. **Connections Closed** - Monitors connection closure rate
    - Default threshold: 1,000 connections closed
    - Helps identify abnormal disconnection patterns

### Capacity Monitoring
14. **Event Hub Size** - Tracks Event Hub storage usage
    - Default threshold: 10,000,000,000 bytes (10 GB)
    - Critical for storage capacity planning

## Diagnostic Settings

The module supports forwarding Event Hub diagnostic logs and metrics to:
- **Event Hub** - For streaming to external systems or another Event Hub
- **Log Analytics** - For query and analysis in Azure Monitor

Diagnostic settings can be enabled/disabled independently per destination.

## Usage

1. Copy one of the example configurations
2. Update the values to match your environment:
   - Event Hub namespace names
   - Resource group names
   - Action group details
   - Diagnostic settings endpoints (if enabled)
   - Tags
3. Run terraform commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Required Variables

All examples require these core variables:
- `eventhub_namespace_names` - List of Event Hub namespace names to monitor
- `resource_group_name` - Resource group containing the Event Hub resources
- `action_group_resource_group_name` - Resource group containing the action group
- `action_group` - Name of the action group for alert notifications

## Optional Variables

- `eventhub_names` - List of individual Event Hub names to monitor (requires `eventhub_default_namespace`)
- `eventhub_default_namespace` - Default namespace for individual Event Hub monitoring

## Outputs

Each example exports:
- `alert_ids` - Map of alert names to resource IDs
- `alert_names` - Map of alert types to resource names
- `diagnostic_settings` - Diagnostic settings configuration details
- `monitored_eventhub_namespaces` - List of monitored namespace names
- `monitored_eventhubs` - List of monitored individual Event Hub names
- `action_group_id` - ID of the action group used

## Customization

You can customize the alerts by:
- Enabling/disabling specific alert types
- Adjusting thresholds to match your workload baseline
- Configuring diagnostic settings destinations
- Modifying alert evaluation frequency and window size (in module code)
- Adding custom tags for organization
- Monitoring entire namespaces or individual Event Hubs

## Notes

- All thresholds should be tuned based on your baseline traffic patterns
- Request and error alerts help detect operational issues
- Message and byte alerts track throughput and capacity
- Connection alerts monitor client behavior
- Size alerts are critical for storage capacity management
- Diagnostic settings require appropriate permissions on target resources
- Cross-subscription diagnostic settings are supported
- You can monitor both Event Hub namespaces and individual Event Hubs within namespaces
