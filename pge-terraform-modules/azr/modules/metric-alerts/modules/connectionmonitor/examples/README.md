# Connection Monitor Module Examples

This directory contains usage examples for the Azure Connection Monitor monitoring module. These examples demonstrate different deployment scenarios and configurations.

## Prerequisites

- Terraform >= 1.0
- Azure subscription with appropriate permissions
- Existing Azure Connection Monitor resource(s)
- Existing Azure Monitor Action Group
- Network Watcher deployed in the region

## Examples Overview

### Example 1: Production with Strict Thresholds

This example demonstrates a production-ready configuration with:
- Multiple Connection Monitors being monitored
- Strict thresholds appropriate for production workloads
- Comprehensive monitoring across all alert types

**Key Features:**
- 5% failed checks warning threshold
- 25% failed checks critical threshold
- 50ms latency warning threshold
- 200ms latency critical threshold
- Multiple connection monitors for VPN and ExpressRoute

### Example 2: Development with Relaxed Thresholds

This example shows a development environment configuration with:
- Single Connection Monitor
- Relaxed thresholds suitable for development
- Essential monitoring for development work

**Key Features:**
- 20% failed checks warning threshold
- 60% failed checks critical threshold
- 200ms latency warning threshold
- 1000ms latency critical threshold

### Example 3: Basic Monitoring

This example demonstrates minimal monitoring configuration:
- Default threshold values for all alerts
- Single connection monitor
- Suitable for test environments

**Key Features:**
- Quick setup with default thresholds
- Standard monitoring configuration

## Usage

1. Navigate to this examples directory:
   ```bash
   cd examples
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Customization

### Threshold Customization

Adjust thresholds based on your connectivity requirements:

```hcl
# Failed checks thresholds
checks_failed_threshold          = 10  # Warning at 10% failed checks
checks_failed_critical_threshold = 50  # Critical at 50% failed checks

# Latency thresholds
latency_threshold_ms             = 100 # Warning at 100ms latency
latency_critical_threshold_ms    = 500 # Critical at 500ms latency
```

### Connection Monitor Configuration

Specify which Connection Monitors to monitor using their full resource IDs:

```hcl
connection_monitor_ids = [
  "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus3/connectionMonitors/vpn-monitor",
  "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus3/connectionMonitors/expressroute-monitor"
]
```

## Outputs

The examples provide the following outputs:

- **alert_ids**: Map of all created metric alert resource IDs organized by alert type
- **alert_names**: Map of all created metric alert names organized by alert type
- **monitored_connection_monitors**: List of Connection Monitor resource IDs being monitored
- **action_group_id**: ID of the Action Group receiving alerts

## Alert Types

The module can create the following metric alerts for Connection Monitors:

### Connectivity Alerts
1. **Checks Failed Warning** - Warning when connectivity checks fail above threshold
2. **Checks Failed Critical** - Critical alert for high percentage of failed checks

### Latency Alerts
3. **Latency Warning** - Warning when round-trip time exceeds threshold
4. **Latency Critical** - Critical alert for excessive latency

### Test Result Alerts
5. **Test Result Failed** - Alert when test results show failures
6. **Test Result Warning** - Warning for degraded test results

## Tags

All examples use consistent tagging:

```hcl
tags = {
  AppId              = "123456"
  Env                = "Dev"
  Owner              = "abc@pge.com"
  Compliance         = "None"
  Notify             = "abc@pge.com"
  DataClassification = "internal"
  CRIS               = "1"
  order              = "123456"
}
```

Customize these tags according to your organization's standards.

## Important Notes

- **No Diagnostic Settings**: Connection Monitor does NOT support diagnostic settings. Data is sent directly to the Log Analytics workspace configured in the Connection Monitor itself.
- **Resource ID Format**: Connection Monitor resource IDs must include the full path including Network Watcher
- **Metric Namespace**: Uses `Microsoft.Network/networkWatchers/connectionMonitors` namespace
- **Real-time Monitoring**: Alerts evaluate every minute (PT1M frequency) for near real-time monitoring

## Cleanup

To remove all created resources:

```bash
terraform destroy
```

## Additional Resources

- [Azure Connection Monitor Documentation](https://learn.microsoft.com/azure/network-watcher/connection-monitor-overview)
- [Azure Monitor Metric Alerts](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-metric-overview)
- [Azure Monitor Action Groups](https://learn.microsoft.com/azure/azure-monitor/alerts/action-groups)
- [Network Watcher Overview](https://learn.microsoft.com/azure/network-watcher/network-watcher-overview)
