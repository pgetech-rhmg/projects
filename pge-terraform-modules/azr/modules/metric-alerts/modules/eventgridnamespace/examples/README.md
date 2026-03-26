# Azure Event Grid Namespace Monitoring Alerts - Examples

This directory contains example configurations for deploying the Event Grid Namespace monitoring alerts module with different configurations.

## Examples

### 1. Production Deployment
A comprehensive production setup with:
- All MQTT and HTTP alerts enabled
- Strict thresholds for production workloads
- Full diagnostic settings (Event Hub + Log Analytics)
- Monitoring multiple Event Grid namespaces

### 2. Development Deployment
A development-focused configuration with:
- Only critical failure alerts enabled
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

The module supports the following metric alerts for Event Grid Namespaces:

### MQTT Alerts
1. **MQTT Published Messages** - Tracks the volume of published MQTT messages
   - Default threshold: 10,000 messages
   - Helps detect unusual spikes in message traffic

2. **MQTT Failed Published Messages** - Monitors failed MQTT publish attempts
   - Default threshold: 1 failure
   - Critical for identifying publishing issues

3. **MQTT Connections** - Monitors active MQTT client connections
   - Default threshold: 1,000 connections
   - Helps detect connection storms or capacity issues

### HTTP Alerts
4. **HTTP Published Events** - Tracks the volume of published HTTP events
   - Default threshold: 10,000 events
   - Helps detect unusual spikes in event traffic

5. **HTTP Failed Published Events** - Monitors failed HTTP publish attempts
   - Default threshold: 1 failure
   - Critical for identifying publishing issues

### Delivery Alerts
6. **Delivery Attempts Failed** - Monitors failed event delivery attempts
   - Default threshold: 1 failure
   - Critical for detecting delivery issues to subscribers

7. **Delivery Attempts Succeeded** - Tracks successful event deliveries
   - Default threshold: 10,000 successful deliveries
   - Helps monitor delivery throughput

## Diagnostic Settings

The module supports forwarding Event Grid Namespace diagnostic logs and metrics to:
- **Event Hub** - For streaming to external systems
- **Log Analytics** - For query and analysis in Azure Monitor

Diagnostic settings can be enabled/disabled independently per destination.

## Usage

1. Copy one of the example configurations
2. Update the values to match your environment:
   - Event Grid namespace names
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
- `eventgrid_namespace_names` - List of Event Grid namespace names to monitor
- `resource_group_name` - Resource group containing the namespaces
- `action_group_resource_group_name` - Resource group containing the action group
- `action_group` - Name of the action group for alert notifications

## Outputs

Each example exports:
- `alert_ids` - Map of alert names to resource IDs
- `alert_names` - Map of alert types to resource names
- `diagnostic_settings` - Diagnostic settings configuration details
- `monitored_eventgrid_namespaces` - List of monitored namespace names
- `action_group_id` - ID of the action group used

## Customization

You can customize the alerts by:
- Enabling/disabling specific alert types
- Adjusting thresholds to match your workload
- Configuring diagnostic settings destinations
- Modifying alert evaluation frequency and window size (in module code)
- Adding custom tags for organization

## Notes

- All thresholds are configurable and should be tuned based on your baseline
- MQTT and HTTP alerts work independently based on your usage patterns
- Delivery alerts apply to event subscriptions configured on the namespace
- Diagnostic settings require appropriate permissions on target resources
- Cross-subscription diagnostic settings are supported
