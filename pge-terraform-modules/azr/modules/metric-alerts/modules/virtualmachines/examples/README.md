# Azure Virtual Machine Monitoring Module - Examples

This directory contains example configurations for using the Azure Virtual Machine Monitoring module in various deployment scenarios.

## Overview

The Azure Virtual Machine Monitoring module provides comprehensive monitoring capabilities for Azure Virtual Machines, including:

- **13 Metric Alerts**: Real-time monitoring of CPU, memory, disk I/O, network, availability, and cache performance
- **2 Diagnostic Settings**: Integration with Event Hub and Log Analytics for centralized metrics collection
- **Multi-severity Alerting**: Critical (0), Warning (1-2), and Informational (3) alerts for different scenarios

## Prerequisites

Before using these examples, ensure you have:

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group for Virtual Machines
3. **Action Group**: Pre-configured action group for alert notifications (e.g., "PGE-Operations")
4. **Virtual Machines**: Existing Azure VMs to monitor
5. **Optional - Event Hub**: For SIEM integration and external metrics streaming
6. **Optional - Log Analytics Workspace**: For centralized metrics analysis

## Example Scenarios

### Example 1: Production VMs with Full Monitoring

**Use Case**: Comprehensive monitoring for production VMs with SIEM integration

**Features**:
- Monitors 5 production VMs (2 web, 2 app, 1 database)
- All 13 alerts enabled for complete visibility
- Strict thresholds for production SLAs
- Diagnostic settings for both Event Hub (SIEM) and Log Analytics
- Low CPU threshold (75% warning, 90% critical)
- Tight memory monitoring (20% available warning, 10% critical)
- Standard disk I/O limits (500 IOPS, 32 queue depth)

**Alert Configuration**:
- CPU: 75% warning (Severity 2), 90% critical (Severity 0)
- Memory: 20% available warning (Severity 2), 10% critical (Severity 0)
- Disk IOPS: 500 read/write ops per second (Severity 2)
- Network: 100MB/s in/out (Severity 2)
- Heartbeat: 5 minutes (Severity 1)
- Data Disk: 50MB/s read/write (Severity 3)
- Cache Miss: 20% premium disk cache miss (Severity 3)

**Monitored VMs**: vm-web-prod-01, vm-web-prod-02, vm-app-prod-01, vm-app-prod-02, vm-db-prod-01

### Example 2: Development VMs with Balanced Monitoring

**Use Case**: Monitoring for development VMs with relaxed thresholds

**Features**:
- Monitors 3 development VMs (web, app, database)
- All 13 alerts enabled
- Relaxed thresholds for development flexibility
- Log Analytics only (no Event Hub)
- Higher CPU tolerance (85% warning, 95% critical)
- More memory tolerance (15% available warning, 5% critical)
- Higher disk I/O limits (750 IOPS, 48 queue depth)

**Alert Configuration**:
- CPU: 85% warning, 95% critical
- Memory: 15% available warning, 5% critical
- Disk IOPS: 750 read/write ops per second
- Network: 150MB/s in/out
- Heartbeat: 10 minutes
- Data Disk: 100MB/s read/write
- Cache Miss: 30% premium disk cache miss

**Monitored VMs**: vm-web-dev-01, vm-app-dev-01, vm-db-dev-01

### Example 3: Basic VM Monitoring for Test Environment

**Use Case**: Minimal monitoring for test/staging VMs

**Features**:
- Monitors 1 test VM
- All 13 alerts enabled with very relaxed thresholds
- No diagnostic settings (cost-optimized)
- Very high CPU tolerance (90% warning, 98% critical)
- Minimal memory monitoring (10% available warning, 5% critical)
- Very high disk I/O limits (1000 IOPS, 64 queue depth)

**Alert Configuration**:
- CPU: 90% warning, 98% critical
- Memory: 10% available warning, 5% critical
- Disk IOPS: 1000 read/write ops per second
- Network: 200MB/s in/out
- Heartbeat: 15 minutes
- Data Disk: 150MB/s read/write
- Cache Miss: 40% premium disk cache miss

**Monitored VMs**: vm-test-01

## Usage

### Step 1: Configure Provider

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Step 2: Reference Action Group

The examples assume a pre-existing action group for notifications:

```hcl
data "azurerm_monitor_action_group" "pge_operations" {
  name                = "PGE-Operations"
  resource_group_name = "rg-pge-monitoring-prod"
}
```

### Step 3: Deploy Module

Choose the appropriate example based on your environment:

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Step 4: Verify Deployment

After deployment, verify the alerts are active:

```bash
# List all metric alerts
az monitor metrics alert list --resource-group rg-pge-vms-prod

# View diagnostic settings for a VM
az monitor diagnostic-settings list --resource <vm-resource-id>

# Check VM metrics
az monitor metrics list --resource <vm-resource-id> --metric "Percentage CPU"
```

## Alert Details

### Critical Alerts (Severity 0)

#### 1. CPU Percentage Critical Alert
- **Name**: `vm-cpu-percentage-critical-{vm-name}`
- **Metric**: `Percentage CPU`
- **Condition**: Average > threshold (default: 90%)
- **Window**: PT5M (5 minutes)
- **Frequency**: PT1M (1 minute)
- **Description**: Critical alert when VM CPU exceeds critical threshold

#### 2. Memory Percentage Critical Alert
- **Name**: `vm-memory-percentage-critical-{vm-name}`
- **Metric**: `Available Memory Bytes`
- **Condition**: Average < threshold (default: 10% of total)
- **Window**: PT5M (5 minutes)
- **Frequency**: PT1M (1 minute)
- **Description**: Critical alert when available memory drops below critical threshold

### Warning Alerts (Severity 1)

#### 3. VM Heartbeat/Availability Alert
- **Name**: `vm-heartbeat-{vm-name}`
- **Metric**: `VmAvailabilityMetric`
- **Condition**: Average < 1
- **Window**: PT5M (5 minutes)
- **Frequency**: PT1M (1 minute)
- **Description**: Alert when VM becomes unavailable or stops sending heartbeats

### Standard Alerts (Severity 2)

#### 4. CPU Percentage Warning Alert
- **Name**: `vm-cpu-percentage-{vm-name}`
- **Metric**: `Percentage CPU`
- **Condition**: Average > threshold (default: 80%)
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 5. Memory Percentage Warning Alert
- **Name**: `vm-memory-percentage-{vm-name}`
- **Metric**: `Available Memory Bytes`
- **Condition**: Average < threshold (default: 20% of total)
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 6. Disk Read Operations Alert
- **Name**: `vm-disk-read-ops-{vm-name}`
- **Metric**: `OS Disk Read Operations/Sec`
- **Condition**: Average > threshold (default: 500 IOPS)
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 7. Disk Write Operations Alert
- **Name**: `vm-disk-write-ops-{vm-name}`
- **Metric**: `OS Disk Write Operations/Sec`
- **Condition**: Average > threshold (default: 500 IOPS)
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 8. Disk Queue Depth Alert
- **Name**: `vm-disk-queue-depth-{vm-name}`
- **Metric**: `OS Disk Queue Depth`
- **Condition**: Average > threshold (default: 32)
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 9. Network In Alert
- **Name**: `vm-network-in-{vm-name}`
- **Metric**: `Network In Total`
- **Condition**: Average > threshold (default: 100MB/s)
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 10. Network Out Alert
- **Name**: `vm-network-out-{vm-name}`
- **Metric**: `Network Out Total`
- **Condition**: Average > threshold (default: 100MB/s)
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

### Informational Alerts (Severity 3)

#### 11. Data Disk Read Bytes Alert
- **Name**: `vm-data-disk-read-bytes-{vm-name}`
- **Metric**: `Data Disk Read Bytes/sec`
- **Condition**: Average > 50MB/s
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 12. Data Disk Write Bytes Alert
- **Name**: `vm-data-disk-write-bytes-{vm-name}`
- **Metric**: `Data Disk Write Bytes/sec`
- **Condition**: Average > 50MB/s
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 13. Premium Data Disk Cache Miss Alert
- **Name**: `vm-premium-data-disk-cache-miss-{vm-name}`
- **Metric**: `Premium Data Disk Cache Read Miss`
- **Condition**: Average > 20%
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

#### 14. Premium OS Disk Cache Miss Alert
- **Name**: `vm-premium-os-disk-cache-miss-{vm-name}`
- **Metric**: `Premium OS Disk Cache Read Miss`
- **Condition**: Average > 20%
- **Window**: PT15M (15 minutes)
- **Frequency**: PT5M (5 minutes)

## Diagnostic Settings

### Event Hub Integration

Sends VM metrics to Event Hub for SIEM integration:

- **Metrics**: `AllMetrics` enabled
- **Logs**: Not supported for VMs at platform level
- **Use Case**: External SIEM systems, real-time monitoring, compliance

### Log Analytics Integration

Sends VM metrics to Log Analytics for analysis:

- **Metrics**: `AllMetrics` enabled
- **Logs**: Not supported for VMs at platform level
- **Use Case**: Centralized metrics, query-based analysis, dashboards

**Note**: For VM guest-level logs (Windows Event Logs, Syslog, etc.), use the Azure Monitor Agent or Log Analytics Agent separately.

## Customization

### Adjusting Thresholds

Modify alert thresholds based on your workload:

```hcl
# Production: Strict thresholds
cpu_percentage_threshold = 75
cpu_percentage_critical_threshold = 90
memory_percentage_threshold = 20
memory_percentage_critical_threshold = 10

# Development: Balanced thresholds
cpu_percentage_threshold = 85
cpu_percentage_critical_threshold = 95
memory_percentage_threshold = 15
memory_percentage_critical_threshold = 5

# Test: Relaxed thresholds
cpu_percentage_threshold = 90
cpu_percentage_critical_threshold = 98
memory_percentage_threshold = 10
memory_percentage_critical_threshold = 5
```

### Network Threshold Examples

```hcl
# 100 MB/s
network_in_threshold = 104857600
network_out_threshold = 104857600

# 500 MB/s (high throughput applications)
network_in_threshold = 524288000
network_out_threshold = 524288000

# 1 GB/s (very high throughput)
network_in_threshold = 1073741824
network_out_threshold = 1073741824
```

### Disk I/O Threshold Examples

```hcl
# Standard VMs (low I/O)
disk_iops_threshold = 500
disk_queue_depth_threshold = 32

# High-performance VMs
disk_iops_threshold = 1000
disk_queue_depth_threshold = 64

# Premium VMs (very high I/O)
disk_iops_threshold = 5000
disk_queue_depth_threshold = 128
```

## Outputs

The module provides comprehensive outputs for integration:

```hcl
# CPU alert IDs
output "vm_cpu_percentage_alert_ids" {
  value = module.vm_monitoring.vm_cpu_percentage_alert_ids
}

# Memory alert IDs
output "vm_memory_percentage_alert_ids" {
  value = module.vm_monitoring.vm_memory_percentage_alert_ids
}

# Diagnostic setting IDs
output "diagnostic_setting_eventhub_ids" {
  value = module.vm_monitoring.diagnostic_setting_eventhub_ids
}

# Monitoring configuration summary
output "monitoring_configuration" {
  value = module.vm_monitoring.monitoring_configuration
}
```

## Troubleshooting

### Alert Not Triggering

1. **Verify VM exists and is running**:
   ```bash
   az vm show --name vm-web-prod-01 --resource-group rg-pge-vms-prod
   ```

2. **Check alert status**:
   ```bash
   az monitor metrics alert show --name vm-cpu-percentage-vm-web-prod-01 --resource-group rg-pge-vms-prod
   ```

3. **Review current metric values**:
   ```bash
   az monitor metrics list --resource <vm-resource-id> --metric "Percentage CPU" --start-time 2024-01-01T00:00:00Z
   ```

### Memory Alert Issues

**Note**: The memory alert converts percentage to bytes. Ensure the conversion is appropriate for your VM size:

```hcl
# For 8GB RAM VM
memory_percentage_threshold = 20  # 20% = ~1.6GB available

# For 16GB RAM VM  
memory_percentage_threshold = 20  # 20% = ~3.2GB available
```

Consider adjusting thresholds based on actual VM memory size.

### Heartbeat Alert False Positives

If heartbeat alerts trigger frequently:

1. **Check VM Insights installation**:
   ```bash
   az vm extension show --vm-name vm-web-prod-01 --name AzureMonitorWindowsAgent --resource-group rg-pge-vms-prod
   ```

2. **Verify Log Analytics connection**
3. **Increase heartbeat threshold** to reduce noise

### Diagnostic Settings Issues

1. **Verify Event Hub permissions**:
   ```bash
   az eventhubs eventhub show --name evh-vm-metrics --namespace-name evhns-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

2. **Check Log Analytics workspace**:
   ```bash
   az monitor log-analytics workspace show --workspace-name law-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

3. **Review diagnostic setting**:
   ```bash
   az monitor diagnostic-settings show --name send-vm-metrics-to-eventhub --resource <vm-resource-id>
   ```

### Permission Issues

Ensure the deployment identity has these permissions:

- `Microsoft.Insights/metricAlerts/write`
- `Microsoft.Insights/diagnosticSettings/write`
- `Microsoft.Compute/virtualMachines/read`
- `Microsoft.EventHub/namespaces/eventhubs/read` (for Event Hub)
- `Microsoft.OperationalInsights/workspaces/read` (for Log Analytics)

## Cost Optimization

### Production Environment
- **Estimated Cost**: $2-4/month per VM
- **Components**: 
  - 13 metric alerts: ~$0.10/alert/month = $1.30
  - Diagnostic settings: Based on metrics volume
  - Event Hub ingestion: Based on throughput

### Development Environment
- **Estimated Cost**: $1.50-3/month per VM
- **Optimization**: Log Analytics only (no Event Hub)
- **Components**:
  - 13 metric alerts: ~$1.30/month
  - Log Analytics ingestion: Based on volume

### Test Environment
- **Estimated Cost**: $1-2/month per VM
- **Optimization**: No diagnostic settings
- **Components**:
  - 13 metric alerts: ~$1.30/month

## Best Practices

1. **Right-size Thresholds**: Set thresholds based on actual workload patterns
2. **Monitor Trends**: Review metric trends before setting static thresholds
3. **Test Alerts**: Verify alerts trigger correctly before production deployment
4. **Use Dynamic Thresholds**: Consider Azure's dynamic threshold feature for variable workloads
5. **Separate Critical from Warning**: Use different severities for different urgency levels
6. **Document Runbooks**: Create response procedures for each alert type
7. **Regular Review**: Periodically review and adjust thresholds
8. **Use Tags Consistently**: Apply consistent tags for cost tracking and governance
9. **VM Insights**: Consider enabling VM Insights for guest-level monitoring
10. **Consolidate Alerts**: Group similar VMs to reduce alert noise

## Additional Resources

- [Azure Virtual Machines Documentation](https://learn.microsoft.com/azure/virtual-machines/)
- [Azure Monitor Metrics](https://learn.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftcomputevirtualmachines)
- [VM Insights Overview](https://learn.microsoft.com/azure/azure-monitor/vm/vminsights-overview)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)

## Support

For issues or questions:
1. Review the main module README
2. Check Azure Virtual Machines documentation
3. Verify VM configuration and status
4. Review metric values in Azure Portal
5. Contact your Azure administrator

## License

This module follows the same license as the parent repository.
