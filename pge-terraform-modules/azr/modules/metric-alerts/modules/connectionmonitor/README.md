# Azure Connection Monitor - AMBA Alerts Module

## Overview

This Terraform module creates comprehensive monitoring alerts for **Azure Connection Monitor**, Microsoft's network connectivity monitoring solution that provides end-to-end network path testing between Azure resources, on-premises resources, and external endpoints. The module implements Azure Monitor Baseline Alerts (AMBA) best practices.

**Connection Monitor** is part of Azure Network Watcher and provides:
- **End-to-end connectivity testing** between source and destination endpoints
- **Network latency monitoring** with round-trip time measurements
- **Path visualization** with hop-by-hop topology
- **Multi-protocol support** (TCP, HTTP, ICMP)
- **Hybrid monitoring** for Azure and on-premises resources

## Features

- **6 Metric Alerts** for connectivity monitoring
  - 2 alerts for failed connectivity checks (warning + critical)
  - 2 alerts for network latency/RTT (warning + critical)
  - 2 alerts for test result status (warning + failed)
- **Diagnostic Settings** with cross-subscription support
- **Customizable Thresholds** for all metrics
- **Multi-Monitor Support** for comprehensive connectivity testing
- **AMBA-Compliant** alert naming and severity levels

## Alert Categories

### 🔴 Critical Alerts (Severity 0-1)
- **Checks Failed Critical** - >50% connectivity check failures
- **Latency Critical** - Round-trip time >500ms
- **Test Result Failed** - Connection monitor test completely fails

### 🟡 Warning Alerts (Severity 2)
- **Checks Failed Warning** - >10% connectivity check failures
- **Latency Warning** - Round-trip time >100ms
- **Test Result Warning** - Connection monitor test shows degradation

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- **Azure Network Watcher** enabled in the region
- **Connection Monitor** resources already created
- Azure Monitor Action Group (pre-configured)
- Appropriate permissions to create Monitor alerts

## Connection Monitor Setup

Before using this module, you need to create Connection Monitor resources. Here's an example:

```hcl
# Enable Network Watcher (usually already exists per region)
resource "azurerm_network_watcher" "example" {
  name                = "NetworkWatcher_westus3"
  location            = "West US 3"
  resource_group_name = "NetworkWatcherRG"
}

# Create Connection Monitor
resource "azurerm_network_connection_monitor" "example" {
  name               = "conn-monitor-webapp-to-sql"
  network_watcher_id = azurerm_network_watcher.example.id
  location           = "West US 3"

  endpoint {
    name               = "source-webapp"
    target_resource_id = azurerm_linux_virtual_machine.source.id
  }

  endpoint {
    name    = "destination-sql"
    address = "sqlserver.database.windows.net"
  }

  test_configuration {
    name                      = "tcp-test"
    protocol                  = "Tcp"
    test_frequency_in_seconds = 60
    
    tcp_configuration {
      port                    = 1433
      destination_port_behavior = "None"
    }
  }

  test_group {
    name                     = "webapp-sql-connectivity"
    destination_endpoints    = ["destination-sql"]
    source_endpoints         = ["source-webapp"]
    test_configuration_names = ["tcp-test"]
  }
}
```

## Usage

### Basic Usage

```hcl
module "connection_monitor_metric_alerts" {
  source = "./modules/metricAlerts/connectionmonitor"

  resource_group_name                = "rg-amba"
  action_group_resource_group_name   = "rg-amba"
  connection_monitor_names           = [
    "conn-monitor-webapp-to-sql",
    "conn-monitor-webapp-to-api",
    "conn-monitor-onprem-to-azure"
  ]

  # Alert Thresholds
  checks_failed_threshold         = 10   # Warning at 10% failure
  checks_failed_critical_threshold = 50   # Critical at 50% failure
  latency_threshold_ms            = 100  # Warning at 100ms
  latency_critical_threshold_ms   = 500  # Critical at 500ms

  # Diagnostic Settings (optional)
  enable_diagnostic_settings      = true
  log_analytics_workspace_name    = "amba-workspace"

  tags = {
    Environment = "Production"
    Team        = "Network Operations"
  }
}
```

### With Cross-Subscription Support

```hcl
module "connection_monitor_metric_alerts" {
  source = "./modules/metricAlerts/connectionmonitor"

  resource_group_name                = "rg-amba"
  action_group_resource_group_name   = "rg-amba"
  connection_monitor_names           = ["conn-monitor-prod"]

  # Cross-subscription Log Analytics
  log_analytics_workspace_name        = "law-central-monitoring"
  log_analytics_resource_group_name   = "rg-monitoring"
  log_analytics_subscription_id       = "12345678-1234-1234-1234-123456789012"

  # Cross-subscription Event Hub
  eventhub_namespace_name             = "amba-eh-namespace"
  eventhub_name                       = "amba-eventhub"
  eventhub_resource_group_name        = "rg-eventhub"
  eventhub_subscription_id            = "87654321-4321-4321-4321-210987654321"
}
```

## Alert Details

### 1. Checks Failed Warning Alert
- **Alert Name**: `conn-monitor-checks-failed-warning-{monitor-name}`
- **Metric**: `ChecksFailedPercent`
- **Threshold**: 10% (configurable)
- **Severity**: 2 (Warning)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Percentage of connectivity checks that failed, indicating network connectivity issues or endpoint unavailability.

**What to do when this alert fires**:
1. **Check Connection Monitor Dashboard** in Azure Portal for detailed path analysis
2. **Review Hop-by-Hop Topology** to identify where connectivity breaks
3. **Verify Source Endpoint** health and network connectivity
4. **Verify Destination Endpoint** availability and reachability
5. **Check Network Security Groups (NSGs)** and firewall rules
6. **Review Azure Service Health** for any service outages

### 2. Checks Failed Critical Alert
- **Alert Name**: `conn-monitor-checks-failed-critical-{monitor-name}`
- **Metric**: `ChecksFailedPercent`
- **Threshold**: 50% (configurable)
- **Severity**: 0 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: High percentage of connectivity check failures, indicating severe network connectivity problems.

**What to do when this alert fires**:
1. **Immediate Investigation** - Critical connectivity failure
2. **Check Azure Status Page** for regional outages
3. **Verify Network Infrastructure** (VPN, ExpressRoute, Virtual Network)
4. **Check DNS Resolution** for destination endpoints
5. **Review Recent Network Changes** that might have broken connectivity
6. **Engage Network Operations Team** for escalation

### 3. Latency Warning Alert
- **Alert Name**: `conn-monitor-latency-warning-{monitor-name}`
- **Metric**: `RoundTripTimeMs`
- **Threshold**: 100ms (configurable)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Network round-trip time (RTT) exceeding acceptable latency thresholds.

**What to do when this alert fires**:
1. **Analyze Latency Patterns** - Is it sustained or sporadic?
2. **Check Network Path** for congestion or routing issues
3. **Review Hop-by-Hop Latency** in Connection Monitor details
4. **Monitor Network Bandwidth** utilization
5. **Check for Network Changes** (routing updates, new workloads)
6. **Consider Network Optimization** (ExpressRoute, FastPath, proximity placement)

### 4. Latency Critical Alert
- **Alert Name**: `conn-monitor-latency-critical-{monitor-name}`
- **Metric**: `RoundTripTimeMs`
- **Threshold**: 500ms (configurable)
- **Severity**: 1 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Severe network latency impacting application performance.

**What to do when this alert fires**:
1. **Immediate Performance Investigation**
2. **Check Network Congestion** on WAN links or VPN gateways
3. **Review ExpressRoute/VPN Gateway Metrics** if applicable
4. **Identify Latency Source** using hop-by-hop analysis
5. **Check for DDoS or Unusual Traffic Patterns**
6. **Consider Emergency Network Path Switching** if available

### 5. Test Result Failed Alert
- **Alert Name**: `conn-monitor-test-failed-{monitor-name}`
- **Metric**: `TestResult`
- **Threshold**: 3 (Failed state)
- **Severity**: 1 (High)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Overall test status indicating complete connectivity failure.

**TestResult Values**:
- 0 = Indeterminate (no data)
- 1 = Pass (healthy)
- 2 = Warning (degraded)
- 3 = Fail (connection failed)

**What to do when this alert fires**:
1. **Verify Endpoint Availability** - Are source/destination reachable?
2. **Check Protocol-Specific Settings** (TCP ports, HTTP endpoints, ICMP)
3. **Review Firewall Rules** blocking connectivity
4. **Check NSG Rules** on source and destination subnets
5. **Verify Routing Tables** for proper path
6. **Test Connectivity Manually** from source endpoint

### 6. Test Result Warning Alert
- **Alert Name**: `conn-monitor-test-warning-{monitor-name}`
- **Metric**: `TestResult`
- **Threshold**: 2 (Warning state)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Test showing degraded performance or intermittent issues.

**What to do when this alert fires**:
1. **Review Metrics Trends** - Is degradation worsening?
2. **Check Latency and Packet Loss** metrics
3. **Monitor for Pattern** - Time-based or load-based?
4. **Proactive Investigation** before it becomes critical
5. **Review Capacity Planning** for network resources

## Common Use Cases

### 1. Azure to On-Premises Connectivity
Monitor VPN or ExpressRoute connectivity:
```hcl
connection_monitor_names = [
  "conn-monitor-azure-to-onprem-dc1",
  "conn-monitor-azure-to-onprem-dc2"
]
```

### 2. Multi-Region Application Connectivity
Monitor connectivity between regions:
```hcl
connection_monitor_names = [
  "conn-monitor-eastus-to-westus",
  "conn-monitor-primary-to-dr"
]
```

### 3. Application Tier Connectivity
Monitor connectivity between application tiers:
```hcl
connection_monitor_names = [
  "conn-monitor-web-to-app",
  "conn-monitor-app-to-db",
  "conn-monitor-app-to-cache"
]
```

### 4. External Endpoint Monitoring
Monitor connectivity to external services:
```hcl
connection_monitor_names = [
  "conn-monitor-azure-to-saas",
  "conn-monitor-azure-to-api-external"
]
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `connection_monitor_names` | `list(string)` | List of Connection Monitor names to monitor |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for Connection Monitors |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `checks_failed_threshold` | `number` | `10` | Warning threshold for failed checks (%) |
| `checks_failed_critical_threshold` | `number` | `50` | Critical threshold for failed checks (%) |
| `latency_threshold_ms` | `number` | `100` | Warning threshold for latency (ms) |
| `latency_critical_threshold_ms` | `number` | `500` | Critical threshold for latency (ms) |
| `enable_diagnostic_settings` | `bool` | `true` | Enable diagnostic settings |
| `log_analytics_workspace_name` | `string` | `"amba-workspace"` | Log Analytics workspace name |
| `eventhub_namespace_name` | `string` | `""` | Event Hub namespace (empty to disable) |
| `eventhub_name` | `string` | `""` | Event Hub name (empty to disable) |

## Outputs

None. This module creates alert resources only.

## Diagnostic Settings

This module supports sending Connection Monitor metrics to:
- **Log Analytics Workspace** - For Azure-native analysis and long-term retention
- **Event Hub** - For external SIEM integration

Connection Monitor primarily provides **metrics** rather than traditional logs:
- ChecksFailedPercent
- RoundTripTimeMs
- TestResult

These metrics are sent to Log Analytics for analysis via Azure Monitor Metrics.

## Troubleshooting

### Connection Monitor Not Found
```bash
# List all Connection Monitors in subscription
az network watcher connection-monitor list --location "West US 3"

# Check specific Connection Monitor
az network watcher connection-monitor show \
  --location "West US 3" \
  --name "conn-monitor-webapp-to-sql"
```

### No Metrics Data
Connection Monitor requires:
- Azure Monitor Agent or Network Watcher Agent installed on source VMs
- Proper network connectivity between source and destination
- Valid test configuration with supported protocol

### High Latency Troubleshooting
```bash
# Get Connection Monitor test results
az network watcher connection-monitor query \
  --location "West US 3" \
  --name "conn-monitor-webapp-to-sql"

# Check hop-by-hop path
az network watcher show-topology \
  --resource-group "rg-network" \
  --name "NetworkWatcher_westus3"
```

## Best Practices

1. **Create Targeted Monitors** - One Connection Monitor per critical path
2. **Use Appropriate Test Frequency** - Balance monitoring granularity with cost
3. **Set Realistic Thresholds** - Based on application SLAs
4. **Monitor Both Directions** - Bidirectional connectivity if needed
5. **Include DNS Testing** - Use HTTP protocol to test DNS resolution
6. **Document Expected Latency** - Baseline latency for each path
7. **Regular Review** - Adjust thresholds based on observed patterns

## Integration with Other Modules

This module complements:
- **VNet Module** - Overall network health
- **VPN Gateway Module** - Site-to-site connectivity
- **ExpressRoute Module** - Private connectivity monitoring
- **Application Gateway Module** - Application delivery monitoring
- **Traffic Manager Module** - Global load balancing health

## Related Documentation

- [Connection Monitor Overview](https://learn.microsoft.com/en-us/azure/network-watcher/connection-monitor-overview)
- [Create Connection Monitor](https://learn.microsoft.com/en-us/azure/network-watcher/connection-monitor-create-using-portal)
- [Connection Monitor Metrics](https://learn.microsoft.com/en-us/azure/network-watcher/connection-monitor-overview#analyze-monitoring-data-and-set-alerts)
- [Network Watcher Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/)

## License

This module is part of the PGE AMBA implementation.

## Support

For issues or questions:
1. Review Azure Connection Monitor documentation
2. Check Connection Monitor test results in Azure Portal
3. Verify Network Watcher agent status
4. Contact Network Operations team
