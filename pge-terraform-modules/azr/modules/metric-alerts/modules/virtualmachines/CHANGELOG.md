# Changelog

All notable changes to the Azure Virtual Machine Monitoring module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure Virtual Machine Monitoring module
- **Metric Alerts** (13 total):
  - CPU Percentage Warning Alert (Severity 2) - Monitors CPU usage
  - CPU Percentage Critical Alert (Severity 0) - Critical CPU threshold
  - Memory Percentage Warning Alert (Severity 2) - Monitors available memory
  - Memory Percentage Critical Alert (Severity 0) - Critical memory threshold
  - Disk Read Operations Alert (Severity 2) - Monitors OS disk read IOPS
  - Disk Write Operations Alert (Severity 2) - Monitors OS disk write IOPS
  - Disk Queue Depth Alert (Severity 2) - Monitors disk queue depth
  - Network In Alert (Severity 2) - Monitors inbound network traffic
  - Network Out Alert (Severity 2) - Monitors outbound network traffic
  - VM Heartbeat/Availability Alert (Severity 1) - Monitors VM availability
  - Data Disk Read Bytes Alert (Severity 3) - Monitors data disk read throughput
  - Data Disk Write Bytes Alert (Severity 3) - Monitors data disk write throughput
  - Premium Data Disk Cache Miss Alert (Severity 3) - Monitors cache efficiency
  - Premium OS Disk Cache Miss Alert (Severity 3) - Monitors cache efficiency
- **Diagnostic Settings** (2 total):
  - Event Hub integration for SIEM and external metrics streaming
  - Log Analytics integration for centralized metrics analysis
  - AllMetrics support for both destinations
- **Features**:
  - Multi-VM monitoring support via `virtual_machine_names` list
  - Cross-subscription support for Event Hub and Log Analytics workspaces
  - Configurable alert thresholds for all monitoring scenarios
  - Multi-severity alerting: Critical (0), Warning (1-2), Informational (3)
  - Fast evaluation for critical alerts (PT1M frequency)
  - Standard evaluation for warning alerts (PT5M frequency)
  - Comprehensive outputs including alert IDs, diagnostic settings, and configuration summary
  - Support for custom tags on all alert resources
- **Examples**:
  - Production VMs with full monitoring (5 VMs, strict thresholds, Event Hub + Log Analytics)
  - Development VMs with balanced monitoring (3 VMs, relaxed thresholds, Log Analytics only)
  - Basic VMs with minimal monitoring (1 VM, very relaxed thresholds, no diagnostics)
  - Environment-specific threshold configurations
  - Cost-optimized configurations for different environments
- **Documentation**:
  - Comprehensive README with usage instructions
  - Detailed examples with multiple deployment patterns
  - Alert descriptions and threshold guidance
  - Troubleshooting guide for common issues
  - Cost optimization recommendations
  - Best practices for VM monitoring

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Existing Azure Virtual Machines
- Pre-configured Azure Monitor Action Group
- Optional: Event Hub namespace and Event Hub for SIEM integration
- Optional: Log Analytics workspace for centralized metrics

### Configuration
- **Alert Categories**:
  - CPU Monitoring (2 alerts: warning + critical)
  - Memory Monitoring (2 alerts: warning + critical)
  - Disk I/O Monitoring (3 alerts: read ops, write ops, queue depth)
  - Network Monitoring (2 alerts: in + out)
  - Availability Monitoring (1 alert: heartbeat)
  - Data Disk Monitoring (2 alerts: read + write bytes)
  - Cache Performance Monitoring (2 alerts: data disk + OS disk)
- **Supported Metrics**:
  - Percentage CPU
  - Available Memory Bytes
  - OS Disk Read Operations/Sec
  - OS Disk Write Operations/Sec
  - OS Disk Queue Depth
  - Network In Total
  - Network Out Total
  - VmAvailabilityMetric
  - Data Disk Read Bytes/sec
  - Data Disk Write Bytes/sec
  - Premium Data Disk Cache Read Miss
  - Premium OS Disk Cache Read Miss
- **Default Thresholds**:
  - CPU Warning: 80%, Critical: 90%
  - Memory Warning: 20% available, Critical: 10% available
  - Disk IOPS: 500 operations/sec
  - Disk Queue Depth: 32
  - Network: 100MB/s in/out
  - Heartbeat: 5 minutes
  - Data Disk Throughput: 50MB/s
  - Premium Cache Miss: 20%
- **Default Time Windows**:
  - Critical Alerts: PT5M window, PT1M frequency
  - Warning Alerts: PT15M window, PT5M frequency
  - Informational Alerts: PT15M window, PT5M frequency

### Notes
- All alerts are created per-VM (for_each on virtual_machine_names)
- Diagnostic settings support both same-subscription and cross-subscription configurations
- Event Hub diagnostic setting includes only metrics (VMs don't support platform logs)
- Log Analytics diagnostic setting includes only metrics (VMs don't support platform logs)
- For guest-level monitoring (event logs, syslog), use Azure Monitor Agent separately
- Memory alerts convert percentage to bytes (assumes 8GB base, adjust per VM size)
- Heartbeat alert requires VM Insights or Azure Monitor Agent
- Premium disk cache alerts only relevant for VMs with Premium SSD disks
- All alerts disabled if `virtual_machine_names` is empty
