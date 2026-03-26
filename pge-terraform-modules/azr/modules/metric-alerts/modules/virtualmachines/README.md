# Azure Virtual Machines - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure Virtual Machines (VMs)**, providing proactive monitoring for compute performance, memory utilization, disk I/O operations, network throughput, and availability across Windows and Linux virtual machines. The module monitors critical infrastructure metrics to ensure optimal performance, availability, and resource efficiency.

Azure Virtual Machines provide on-demand, scalable computing resources with the flexibility of virtualization without the need to buy and maintain physical hardware. This module focuses on performance monitoring, resource optimization, availability tracking, and capacity planning for enterprise-grade VM operations.

## Features

- **CPU Performance Monitoring**: Two-tier CPU monitoring with warning (80%) and critical (90%) thresholds
- **Memory Management**: Dual-level memory alerts for warning (20%) and critical (10%) available memory
- **Disk I/O Operations**: IOPS monitoring for both read and write operations with queue depth tracking
- **Network Throughput**: Inbound and outbound network traffic monitoring with configurable thresholds
- **Availability Tracking**: VM heartbeat monitoring for uptime and availability assurance
- **Data Disk Performance**: Comprehensive data disk read/write throughput monitoring
- **Premium Disk Cache**: Cache miss rate monitoring for premium storage optimization
- **Multi-VM Support**: Enterprise-scale monitoring across multiple virtual machines
- **Real-Time Alerting**: 1-5 minute evaluation frequency for rapid issue detection
- **Cost-Effective Monitoring**: Optimized alert configuration at $1.40 per VM per month
- **Enterprise Integration**: Built-in support for PGE operational procedures and compliance requirements
- **Regulatory Compliance**: SOX, HIPAA, PCI-DSS compliance support for infrastructure monitoring

### Key Monitoring Capabilities
- **Performance Optimization**: Identify resource bottlenecks and optimize VM sizing
- **Availability Assurance**: Early detection of VM failures and availability issues
- **Capacity Planning**: Historical performance data for informed scaling decisions
- **Cost Optimization**: Right-size VMs based on actual utilization patterns
- **Storage Performance**: Premium disk cache optimization and I/O pattern analysis

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Compute/virtualMachines/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Virtual Machines**: VMs deployed and running in Azure
- **VM Insights** (Optional): Enhanced monitoring for heartbeat and availability metrics

## Usage

### Basic Configuration

```hcl
module "vm_alerts" {
  source = "./modules/metricAlerts/virtualmachines"
  
  # Resource Configuration
  resource_group_name               = "rg-production-vms"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # Virtual Machines to Monitor
  virtual_machine_names = [
    "vm-web-prod-01",
    "vm-web-prod-02",
    "vm-app-prod-01",
    "vm-app-prod-02",
    "vm-db-prod-01"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "WebApplication"
    Owner             = "infrastructure-team@pge.com"
    CostCenter        = "IT-Operations"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "vm_alerts_critical_systems" {
  source = "./modules/metricAlerts/virtualmachines"
  
  # Resource Configuration
  resource_group_name               = "rg-production-vms"
  action_group_resource_group_name  = "rg-monitoring"
  
  virtual_machine_names = [
    "vm-sql-prod-01",
    "vm-sql-prod-02",
    "vm-redis-prod-01"
  ]
  
  # Strict Performance Thresholds for Critical Systems
  cpu_percentage_threshold          = 70    # Lower threshold for earlier warnings
  cpu_percentage_critical_threshold = 85    # Conservative critical threshold
  memory_percentage_threshold       = 30    # More available memory buffer
  memory_percentage_critical_threshold = 15 # Higher critical threshold
  disk_iops_threshold              = 400    # Lower IOPS threshold for sensitive workloads
  disk_queue_depth_threshold       = 16     # Lower queue depth for faster response
  network_in_threshold             = 83886080  # 80MB/s for controlled traffic
  network_out_threshold            = 83886080  # 80MB/s for controlled traffic
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    Compliance  = "SOX-Critical"
    Owner       = "dba-team@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development VMs - Relaxed Thresholds
cpu_percentage_threshold          = 90    # Higher tolerance
cpu_percentage_critical_threshold = 95    # Very high before critical
memory_percentage_threshold       = 10    # Lower memory requirements
memory_percentage_critical_threshold = 5  # Minimal critical threshold
disk_iops_threshold              = 1000   # Higher IOPS tolerance
network_in_threshold             = 209715200  # 200MB/s
network_out_threshold            = 209715200  # 200MB/s
```

#### Staging Environment
```hcl
# Staging VMs - Moderate Thresholds
cpu_percentage_threshold          = 85    # Production-like monitoring
cpu_percentage_critical_threshold = 92    # Higher critical threshold
memory_percentage_threshold       = 20    # Standard threshold
memory_percentage_critical_threshold = 10 # Standard critical threshold
disk_iops_threshold              = 600    # Moderate IOPS monitoring
network_in_threshold             = 125829120  # 120MB/s
network_out_threshold            = 125829120  # 120MB/s
```

#### Production Environment
```hcl
# Production VMs - Strict Thresholds
cpu_percentage_threshold          = 80    # Standard production threshold
cpu_percentage_critical_threshold = 90    # Critical at 90%
memory_percentage_threshold       = 20    # 20% available memory warning
memory_percentage_critical_threshold = 10 # Critical at 10% available
disk_iops_threshold              = 500    # Standard IOPS threshold
disk_queue_depth_threshold       = 32     # Standard queue depth
network_in_threshold             = 104857600  # 100MB/s
network_out_threshold            = 104857600  # 100MB/s
```

### Workload-Specific Configurations

#### Web Servers
```hcl
# Web Servers - Network and CPU Focus
cpu_percentage_threshold          = 75    # Lower CPU threshold
memory_percentage_threshold       = 25    # Higher memory buffer
network_in_threshold             = 125829120  # 120MB/s for high traffic
network_out_threshold            = 125829120  # 120MB/s for responses
disk_iops_threshold              = 300    # Lower disk I/O requirements
```

#### Database Servers
```hcl
# Database Servers - Memory and Disk Focus
cpu_percentage_threshold          = 70    # Conservative CPU monitoring
memory_percentage_threshold       = 30    # High memory requirements
memory_percentage_critical_threshold = 15 # Critical memory protection
disk_iops_threshold              = 800    # High IOPS for database operations
disk_queue_depth_threshold       = 16     # Low queue depth for performance
data_disk_read_bytes_threshold   = 104857600  # 100MB/s for queries
data_disk_write_bytes_threshold  = 104857600  # 100MB/s for transactions
```

#### Application Servers
```hcl
# Application Servers - Balanced Approach
cpu_percentage_threshold          = 80    # Standard CPU threshold
memory_percentage_threshold       = 20    # Standard memory threshold
disk_iops_threshold              = 500    # Moderate IOPS
network_in_threshold             = 83886080   # 80MB/s
network_out_threshold            = 83886080   # 80MB/s
```

#### Cache Servers (Redis, Memcached)
```hcl
# Cache Servers - Memory and Network Focus
cpu_percentage_threshold          = 85    # Higher CPU tolerance
memory_percentage_threshold       = 25    # Critical memory management
memory_percentage_critical_threshold = 15 # High memory protection
network_in_threshold             = 209715200  # 200MB/s for cache operations
network_out_threshold            = 209715200  # 200MB/s for cache responses
```

### VM Size-Specific Configurations

#### Small VMs (Standard_B2s, Standard_D2s_v3)
```hcl
# Small VMs - Conservative Thresholds
cpu_percentage_threshold          = 70    # Lower threshold for limited CPU
memory_percentage_threshold       = 30    # Higher memory buffer
disk_iops_threshold              = 300    # Lower IOPS capacity
network_in_threshold             = 52428800   # 50MB/s
network_out_threshold            = 52428800   # 50MB/s
```

#### Medium VMs (Standard_D4s_v3, Standard_E4s_v3)
```hcl
# Medium VMs - Standard Thresholds
cpu_percentage_threshold          = 80    # Standard threshold
memory_percentage_threshold       = 20    # Standard memory
disk_iops_threshold              = 500    # Standard IOPS
network_in_threshold             = 104857600  # 100MB/s
network_out_threshold            = 104857600  # 100MB/s
```

#### Large VMs (Standard_D16s_v3, Standard_E16s_v3)
```hcl
# Large VMs - Higher Capacity Thresholds
cpu_percentage_threshold          = 85    # Higher threshold for more CPUs
memory_percentage_threshold       = 15    # More memory capacity
disk_iops_threshold              = 1000   # Higher IOPS capacity
network_in_threshold             = 209715200  # 200MB/s
network_out_threshold            = 209715200  # 200MB/s
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `virtual_machine_names` | `list(string)` | List of VM names to monitor |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for virtual machines |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |

### Alert Threshold Variables

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `cpu_percentage_threshold` | `number` | `80` | CPU percentage warning threshold | 60-90% |
| `cpu_percentage_critical_threshold` | `number` | `90` | CPU percentage critical threshold | 85-95% |
| `memory_percentage_threshold` | `number` | `20` | Available memory percentage warning | 15-30% |
| `memory_percentage_critical_threshold` | `number` | `10` | Available memory percentage critical | 5-15% |
| `disk_iops_threshold` | `number` | `500` | Disk IOPS threshold for read/write | 300-1000 |
| `disk_queue_depth_threshold` | `number` | `32` | Disk queue depth threshold | 16-64 |
| `network_in_threshold` | `number` | `104857600` | Network bytes in threshold (100MB/s) | 50MB/s-500MB/s |
| `network_out_threshold` | `number` | `104857600` | Network bytes out threshold (100MB/s) | 50MB/s-500MB/s |
| `vm_heartbeat_threshold` | `number` | `5` | VM heartbeat threshold in minutes | 3-10 minutes |
| `data_disk_read_bytes_threshold` | `number` | `52428800` | Data disk read bytes/sec (50MB/s) | 25MB/s-200MB/s |
| `data_disk_write_bytes_threshold` | `number` | `52428800` | Data disk write bytes/sec (50MB/s) | 25MB/s-200MB/s |
| `premium_disk_cache_miss_threshold` | `number` | `20` | Premium disk cache miss percentage | 10-30% |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "infrastructure-team@pge.com" # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "vm-team@pge.com"            # Notification contact
  DataClassification = "Internal"                    # Data sensitivity
  CostCenter         = "IT-Operations"              # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  Workload           = "WebServer"                  # VM workload type
}
```

## Alert Details

### 1. CPU Percentage Warning Alert
- **Alert Name**: `vm-cpu-percentage-{vm-name}`
- **Metric**: `Percentage CPU`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: CPU utilization across all cores, indicating processor load and computational demand on the virtual machine.

**What to do when this alert fires**:
1. **Performance Analysis**: Review CPU usage patterns and identify processes consuming high CPU
2. **Workload Assessment**: Determine if high CPU is expected (batch jobs, peak traffic) or anomalous
3. **Process Investigation**: Use Task Manager (Windows) or top/htop (Linux) to identify resource-intensive processes
4. **Optimization**: Consider application optimization, code efficiency improvements, or workload distribution
5. **Capacity Planning**: If sustained high CPU, evaluate VM sizing and consider scaling up to larger VM sizes

### 2. CPU Percentage Critical Alert
- **Alert Name**: `vm-cpu-percentage-critical-{vm-name}`
- **Metric**: `Percentage CPU`
- **Threshold**: 90% (configurable)
- **Severity**: 0 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Critical CPU saturation that may impact application performance and user experience significantly.

**What to do when this alert fires**:
1. **Immediate Assessment**: Identify if VM is responsive and applications are functioning
2. **Emergency Response**: Consider scaling up VM size immediately if business-critical
3. **Load Distribution**: Redistribute workload to other VMs if part of a load-balanced environment
4. **Process Termination**: Identify and terminate runaway or non-essential processes consuming excessive CPU
5. **Incident Escalation**: Notify application owners and consider emergency change request for VM resizing

### 3. Available Memory Warning Alert
- **Alert Name**: `vm-memory-percentage-{vm-name}`
- **Metric**: `Available Memory Bytes`
- **Threshold**: 20% available (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Available physical memory, indicating memory pressure and potential paging/swapping activity.

**What to do when this alert fires**:
1. **Memory Analysis**: Review memory usage by application and process
2. **Memory Leak Detection**: Check for applications with steadily increasing memory consumption
3. **Cache Management**: Clear unnecessary caches or temporary data consuming memory
4. **Application Restart**: Consider restarting memory-intensive applications to reclaim memory
5. **Capacity Review**: Evaluate if VM has adequate memory for current workload and consider scaling up

### 4. Available Memory Critical Alert
- **Alert Name**: `vm-memory-percentage-critical-{vm-name}`
- **Metric**: `Available Memory Bytes`
- **Threshold**: 10% available (configurable)
- **Severity**: 0 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Critical memory shortage that may cause system instability, application crashes, or OS paging.

**What to do when this alert fires**:
1. **Immediate Action**: System is at risk of crashes or severe performance degradation
2. **Memory Liberation**: Identify and stop non-critical services and applications immediately
3. **Process Termination**: Force terminate memory-hogging processes if necessary
4. **Emergency Scaling**: Scale up VM to larger memory configuration immediately if possible
5. **Service Continuity**: Prepare for potential VM restart and ensure high availability mechanisms are active

### 5. Disk Read Operations Alert
- **Alert Name**: `vm-disk-read-ops-{vm-name}`
- **Metric**: `OS Disk Read Operations/Sec`
- **Threshold**: 500 IOPS (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: OS disk read I/O operations per second, indicating disk read activity and potential I/O bottlenecks.

**What to do when this alert fires**:
1. **I/O Analysis**: Identify applications or processes generating high disk read activity
2. **Performance Impact**: Assess if disk I/O is causing application performance issues
3. **Disk Type Review**: Consider upgrading to Premium SSD or Ultra Disk for higher IOPS capacity
4. **Read Optimization**: Implement caching strategies to reduce disk reads
5. **Data Access Patterns**: Review and optimize database queries or file access patterns

### 6. Disk Write Operations Alert
- **Alert Name**: `vm-disk-write-ops-{vm-name}`
- **Metric**: `OS Disk Write Operations/Sec`
- **Threshold**: 500 IOPS (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: OS disk write I/O operations per second, indicating disk write activity and potential write bottlenecks.

**What to do when this alert fires**:
1. **Write Activity Analysis**: Identify sources of high disk write operations
2. **Logging Review**: Check if excessive logging is contributing to disk writes
3. **Disk Upgrade**: Consider Premium SSD or Ultra Disk for higher write IOPS
4. **Write Buffering**: Implement write caching or buffering strategies where appropriate
5. **Data Archival**: Move old or infrequently accessed data to separate storage tiers

### 7. Disk Queue Depth Alert
- **Alert Name**: `vm-disk-queue-depth-{vm-name}`
- **Metric**: `OS Disk Queue Depth`
- **Threshold**: 32 (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Number of outstanding I/O requests waiting to be processed, indicating disk contention and latency.

**What to do when this alert fires**:
1. **Latency Assessment**: Measure disk latency and identify if I/O operations are delayed
2. **Concurrent I/O**: Review number of applications performing simultaneous disk operations
3. **Disk Performance**: Upgrade to higher-performance disk SKU (Premium SSD, Ultra Disk)
4. **I/O Optimization**: Optimize application I/O patterns to reduce concurrent requests
5. **Storage Architecture**: Consider splitting workloads across multiple data disks

### 8. Network In Alert
- **Alert Name**: `vm-network-in-{vm-name}`
- **Metric**: `Network In Total`
- **Threshold**: 100MB/s (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Inbound network traffic volume, indicating data ingress rate and potential network bandwidth saturation.

**What to do when this alert fires**:
1. **Traffic Analysis**: Identify sources and patterns of inbound network traffic
2. **DDoS Assessment**: Check for potential distributed denial of service attacks
3. **Bandwidth Capacity**: Review VM network bandwidth limits and consider accelerated networking
4. **Traffic Distribution**: Implement load balancing or traffic shaping if appropriate
5. **Network Optimization**: Enable accelerated networking or scale to VM sizes with higher network capacity

### 9. Network Out Alert
- **Alert Name**: `vm-network-out-{vm-name}`
- **Metric**: `Network Out Total`
- **Threshold**: 100MB/s (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Outbound network traffic volume, indicating data egress rate and response throughput.

**What to do when this alert fires**:
1. **Egress Analysis**: Identify destinations and patterns of outbound traffic
2. **Content Delivery**: Consider Azure CDN for static content delivery to reduce egress
3. **Data Transfer**: Review if large data transfers are expected or anomalous
4. **Bandwidth Optimization**: Implement compression or caching to reduce outbound traffic
5. **Cost Management**: Monitor data egress costs and optimize data transfer patterns

### 10. VM Heartbeat Alert
- **Alert Name**: `vm-heartbeat-{vm-name}`
- **Metric**: `VmAvailabilityMetric`
- **Threshold**: < 1 (availability loss)
- **Severity**: 1 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: VM availability and heartbeat, detecting VM failures, crashes, or unresponsive state.

**What to do when this alert fires**:
1. **Availability Check**: Immediately verify VM status in Azure Portal
2. **Connectivity Test**: Attempt to connect via RDP (Windows) or SSH (Linux)
3. **VM Restart**: Initiate VM restart through Azure Portal if unresponsive
4. **Service Health**: Check Azure Service Health for regional issues or platform problems
5. **Escalation**: If VM won't start, create Azure support ticket with high priority

### 11. Data Disk Read Bytes Alert
- **Alert Name**: `vm-data-disk-read-bytes-{vm-name}`
- **Metric**: `Data Disk Read Bytes/sec`
- **Threshold**: 50MB/s (configurable)
- **Severity**: 3 (Informational)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Data disk read throughput, indicating sustained data access patterns on additional disks.

**What to do when this alert fires**:
1. **Throughput Analysis**: Review data disk read patterns and identify data-intensive operations
2. **Disk Performance**: Verify data disk SKU meets throughput requirements (Premium SSD: up to 900MB/s)
3. **Caching Strategy**: Enable read caching on data disks for frequently accessed data
4. **Query Optimization**: For database workloads, optimize queries to reduce data reads
5. **Capacity Planning**: Consider disk striping or larger Premium SSD for higher throughput

### 12. Data Disk Write Bytes Alert
- **Alert Name**: `vm-data-disk-write-bytes-{vm-name}`
- **Metric**: `Data Disk Write Bytes/sec`
- **Threshold**: 50MB/s (configurable)
- **Severity**: 3 (Informational)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Data disk write throughput, indicating sustained write operations on additional disks.

**What to do when this alert fires**:
1. **Write Analysis**: Identify applications or processes generating high write throughput
2. **Disk Performance**: Verify data disk SKU supports required write throughput
3. **Write Caching**: Consider write acceleration techniques or Premium SSD with write caching
4. **Transaction Batching**: For databases, implement transaction batching to optimize writes
5. **Disk Upgrade**: Scale to larger Premium SSD or Ultra Disk for higher write throughput

### 13. Premium Data Disk Cache Miss Alert
- **Alert Name**: `vm-premium-data-disk-cache-miss-{vm-name}`
- **Metric**: `Premium Data Disk Cache Read Miss`
- **Threshold**: 20% (configurable)
- **Severity**: 3 (Informational)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Premium data disk cache effectiveness, indicating cache miss rate for read operations.

**What to do when this alert fires**:
1. **Cache Analysis**: Review cache hit/miss ratios and access patterns
2. **Working Set Size**: Verify data working set fits within disk cache capacity
3. **Cache Configuration**: Adjust cache settings (ReadOnly vs ReadWrite) based on workload
4. **Access Patterns**: Analyze data access patterns for cache-friendly optimization
5. **Disk Sizing**: Consider larger Premium SSD with bigger cache for improved cache hit rates

### 14. Premium OS Disk Cache Miss Alert
- **Alert Name**: `vm-premium-os-disk-cache-miss-{vm-name}`
- **Metric**: `Premium OS Disk Cache Read Miss`
- **Threshold**: 20% (configurable)
- **Severity**: 3 (Informational)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Premium OS disk cache effectiveness for operating system and application binaries.

**What to do when this alert fires**:
1. **OS Disk Performance**: Review OS disk cache utilization and miss patterns
2. **Application Loading**: Check if application binaries and libraries fit in cache
3. **Cache Optimization**: OS disks should use ReadOnly caching for optimal performance
4. **Disk Upgrade**: Consider P30 or larger Premium SSD for larger cache capacity
5. **Memory Management**: Ensure adequate RAM to reduce OS paging and disk access

## Severity Levels

### Severity 0 (Critical) - Immediate Action Required
- **CPU Critical**: CPU utilization exceeding 90%, system at capacity
- **Memory Critical**: Available memory below 10%, risk of crashes or severe performance degradation

**Response Time**: Immediate (within 5 minutes)
**Escalation**: Immediate notification to on-call engineer, infrastructure team, and application owners

### Severity 1 (Critical) - Availability Impact
- **VM Heartbeat**: VM unavailable or unresponsive, service interruption

**Response Time**: Immediate (within 5 minutes)
**Escalation**: Notification to on-call engineer and infrastructure team with high priority

### Severity 2 (High) - Performance Impact
- **CPU Warning**: CPU utilization exceeding 80%, performance degradation likely
- **Memory Warning**: Available memory below 20%, memory pressure building
- **Disk IOPS**: Read/write operations exceeding thresholds, I/O bottleneck
- **Disk Queue Depth**: High queue depth indicating disk contention
- **Network In/Out**: Network throughput approaching bandwidth limits

**Response Time**: 30 minutes
**Escalation**: Notification to infrastructure team and relevant application owners

### Severity 3 (Informational) - Monitoring and Optimization
- **Data Disk Throughput**: High but manageable data disk read/write operations
- **Premium Disk Cache**: Cache miss rates indicating optimization opportunities

**Response Time**: 4 hours
**Escalation**: Standard operational notification for optimization review

## Cost Analysis

### Alert Costs (Monthly)
- **14 Metric Alerts per VM**: 14 × $0.10 = **$1.40 per VM per month**
- **Action Group**: FREE (included)
- **Multi-VM Deployment**: Scales linearly with VM count

### Cost Examples by Environment

#### Small Environment (5 VMs)
- **Monthly Alert Cost**: 5 × $1.40 = $7.00
- **Annual Alert Cost**: $84.00

#### Medium Environment (25 VMs)
- **Monthly Alert Cost**: 25 × $1.40 = $35.00
- **Annual Alert Cost**: $420.00

#### Large Environment (100 VMs)
- **Monthly Alert Cost**: 100 × $1.40 = $140.00
- **Annual Alert Cost**: $1,680.00

#### Enterprise Environment (500 VMs)
- **Monthly Alert Cost**: 500 × $1.40 = $700.00
- **Annual Alert Cost**: $8,400.00

#### Global Enterprise Environment (2000 VMs)
- **Monthly Alert Cost**: 2000 × $1.40 = $2,800.00
- **Annual Alert Cost**: $33,600.00

### Return on Investment (ROI)

#### Cost of VM Performance Issues
- **Unplanned Downtime**: $100,000-1,000,000/hour for critical business applications
- **Performance Degradation**: $50,000-500,000/hour in lost productivity and revenue
- **Over-Provisioning**: $500-5,000/VM/month in unnecessary VM costs without optimization
- **Emergency Scaling**: $10,000-100,000 in emergency infrastructure changes
- **SLA Violations**: $100,000-1,000,000 in penalties and customer compensation

#### Alert Value Calculation (100 VMs)
- **Monthly Alert Cost**: $140.00
- **Prevented Downtime**: 4 hours/year average (conservative estimate)
- **Cost Avoidance**: $400,000/year (at $100,000/hour downtime cost)
- **ROI**: 238,095% (($400,000 - $1,680) / $1,680 × 100)

#### Additional Benefits
- **Right-Sizing Savings**: 20-40% cost reduction through data-driven VM sizing
- **Capacity Planning**: Informed scaling decisions preventing over-provisioning
- **Performance Optimization**: Proactive issue resolution before user impact
- **Compliance**: Audit trails and monitoring documentation for compliance requirements

### Azure VM Pricing Context
- **Standard_D2s_v3**: ~$70/month (2 vCPU, 8GB RAM)
- **Standard_D4s_v3**: ~$140/month (4 vCPU, 16GB RAM)
- **Standard_D8s_v3**: ~$280/month (8 vCPU, 32GB RAM)
- **Premium SSD P30**: ~$135/month (1TB, 5000 IOPS)

**Alert Cost Impact**: 1-2% of VM infrastructure costs, preventing 10-100x that cost in downtime and performance issues

## Best Practices

### Deployment Best Practices

#### 1. Environment-Specific Configuration
```hcl
# Production - Strict monitoring
cpu_percentage_threshold          = 80
cpu_percentage_critical_threshold = 90
memory_percentage_threshold       = 20
memory_percentage_critical_threshold = 10

# Staging - Production-like monitoring
cpu_percentage_threshold          = 85
cpu_percentage_critical_threshold = 92
memory_percentage_threshold       = 20
memory_percentage_critical_threshold = 10

# Development - Relaxed monitoring
cpu_percentage_threshold          = 90
cpu_percentage_critical_threshold = 95
memory_percentage_threshold       = 10
memory_percentage_critical_threshold = 5
```

#### 2. Workload-Specific Tuning
- **Web Servers**: Focus on CPU and network throughput
- **Database Servers**: Prioritize memory and disk I/O performance
- **Application Servers**: Balanced monitoring across all metrics
- **Cache Servers**: Emphasize memory and network performance

#### 3. VM Size Considerations
- **Small VMs**: More sensitive thresholds due to limited resources
- **Medium VMs**: Standard thresholds appropriate
- **Large VMs**: Higher thresholds leveraging increased capacity

### VM Performance Optimization

#### 1. CPU Optimization
```powershell
# Windows: Identify high CPU processes
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet

# Check for Windows Updates causing high CPU
Get-WindowsUpdate

# Review scheduled tasks
Get-ScheduledTask | Where-Object {$_.State -eq "Running"}
```

```bash
# Linux: Identify high CPU processes
top -b -n 1 | head -20

# Check CPU usage by process
ps aux --sort=-%cpu | head -10

# Monitor CPU in real-time
htop
```

#### 2. Memory Optimization
```powershell
# Windows: Memory analysis
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name="Memory(MB)";Expression={$_.WorkingSet / 1MB}}

# Check for memory leaks
Get-Counter '\Memory\Available MBytes'

# Review page file usage
Get-WmiObject -Class Win32_PageFileUsage
```

```bash
# Linux: Memory analysis
free -h

# Process memory usage
ps aux --sort=-%mem | head -10

# Detailed memory breakdown
cat /proc/meminfo
```

#### 3. Disk I/O Optimization
```powershell
# Windows: Disk performance monitoring
Get-PhysicalDisk | Get-StorageReliabilityCounter

# Check disk queue length
Get-Counter '\PhysicalDisk(*)\Avg. Disk Queue Length'

# Review disk IOPS
Get-Counter '\PhysicalDisk(*)\Disk Reads/sec'
Get-Counter '\PhysicalDisk(*)\Disk Writes/sec'
```

```bash
# Linux: Disk I/O monitoring
iostat -x 1 10

# Identify processes with high I/O
iotop

# Check disk queue depth
cat /sys/block/sda/queue/nr_requests
```

### Azure VM Best Practices

#### 1. Enable Accelerated Networking
```bash
# Check if accelerated networking is enabled
az vm show --resource-group "rg-production-vms" --name "vm-web-01" --query "networkProfile.networkInterfaces[0].enableAcceleratedNetworking"

# Enable accelerated networking (requires VM restart)
az network nic update \
  --resource-group "rg-production-vms" \
  --name "vm-web-01-nic" \
  --accelerated-networking true
```

#### 2. Configure Premium SSD for Production
```bash
# Check current disk SKU
az disk show --resource-group "rg-production-vms" --name "vm-web-01-osdisk" --query "sku.name"

# Upgrade to Premium SSD (requires VM to be stopped)
az vm deallocate --resource-group "rg-production-vms" --name "vm-web-01"

az disk update \
  --resource-group "rg-production-vms" \
  --name "vm-web-01-osdisk" \
  --sku Premium_LRS

az vm start --resource-group "rg-production-vms" --name "vm-web-01"
```

#### 3. Enable VM Insights for Enhanced Monitoring
```bash
# Enable VM Insights with Log Analytics workspace
az vm extension set \
  --resource-group "rg-production-vms" \
  --vm-name "vm-web-01" \
  --name "DependencyAgentWindows" \
  --publisher "Microsoft.Azure.Monitoring.DependencyAgent" \
  --version "9.10"

az vm extension set \
  --resource-group "rg-production-vms" \
  --vm-name "vm-web-01" \
  --name "MicrosoftMonitoringAgent" \
  --publisher "Microsoft.EnterpriseCloud.Monitoring" \
  --settings '{"workspaceId": "<workspace-id>"}' \
  --protected-settings '{"workspaceKey": "<workspace-key>"}'
```

#### 4. Right-Sizing VMs Based on Metrics
```powershell
# PowerShell script for VM right-sizing recommendations
function Get-VMRightSizingRecommendation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        
        [Parameter(Mandatory=$false)]
        [int]$Days = 30
    )
    
    # Get VM details
    $VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
    $VMSize = $VM.HardwareProfile.VmSize
    
    Write-Host "Analyzing VM: $VMName (Current Size: $VMSize)" -ForegroundColor Green
    Write-Host "Analysis Period: Last $Days days" -ForegroundColor Yellow
    
    # Get CPU metrics
    $CPUMetrics = Get-AzMetric -ResourceId $VM.Id -MetricName "Percentage CPU" -TimeGrain 01:00:00 -StartTime (Get-Date).AddDays(-$Days)
    $AvgCPU = ($CPUMetrics.Data.Average | Measure-Object -Average).Average
    $MaxCPU = ($CPUMetrics.Data.Maximum | Measure-Object -Maximum).Maximum
    
    Write-Host "CPU Utilization:" -ForegroundColor Cyan
    Write-Host "  Average: $([math]::Round($AvgCPU, 2))%" -ForegroundColor White
    Write-Host "  Maximum: $([math]::Round($MaxCPU, 2))%" -ForegroundColor White
    
    # Get Memory metrics (if available)
    try {
        $MemoryMetrics = Get-AzMetric -ResourceId $VM.Id -MetricName "Available Memory Bytes" -TimeGrain 01:00:00 -StartTime (Get-Date).AddDays(-$Days)
        $AvgMemory = ($MemoryMetrics.Data.Average | Measure-Object -Average).Average
        
        Write-Host "Memory Utilization:" -ForegroundColor Cyan
        Write-Host "  Average Available: $([math]::Round($AvgMemory / 1GB, 2)) GB" -ForegroundColor White
    } catch {
        Write-Host "Memory metrics not available (VM Insights required)" -ForegroundColor Yellow
    }
    
    # Recommendations
    Write-Host "`nRecommendations:" -ForegroundColor Green
    
    if ($AvgCPU -lt 20 -and $MaxCPU -lt 50) {
        Write-Host "  - Consider downsizing to smaller VM SKU (underutilized)" -ForegroundColor Yellow
    } elseif ($AvgCPU -gt 80 -or $MaxCPU -gt 95) {
        Write-Host "  - Consider upsizing to larger VM SKU (overutilized)" -ForegroundColor Red
    } else {
        Write-Host "  - Current VM size appears appropriate" -ForegroundColor Green
    }
}

# Usage
Get-VMRightSizingRecommendation -ResourceGroupName "rg-production-vms" -VMName "vm-web-01" -Days 30
```

### Monitoring and Alerting Best Practices

#### 1. Configure Alert Action Groups Appropriately
```hcl
# Create separate action groups for different severity levels
# Critical alerts: Page on-call engineer
# High alerts: Email infrastructure team
# Informational: Log to monitoring dashboard
```

#### 2. Implement Alert Suppression During Maintenance
```bash
# Disable alerts during planned maintenance
az monitor metrics alert update \
  --name "vm-cpu-percentage-vm-web-01" \
  --resource-group "rg-production-vms" \
  --enabled false

# Re-enable after maintenance
az monitor metrics alert update \
  --name "vm-cpu-percentage-vm-web-01" \
  --resource-group "rg-production-vms" \
  --enabled true
```

#### 3. Create Custom Dashboards for VM Monitoring
```json
{
  "dashboard": {
    "title": "Production VM Monitoring Dashboard",
    "panels": [
      {
        "title": "CPU Utilization Across All VMs",
        "metric": "Percentage CPU",
        "aggregation": "Average",
        "visualization": "LineChart"
      },
      {
        "title": "Available Memory",
        "metric": "Available Memory Bytes",
        "aggregation": "Average",
        "visualization": "LineChart"
      },
      {
        "title": "Disk IOPS",
        "metrics": ["OS Disk Read Operations/Sec", "OS Disk Write Operations/Sec"],
        "visualization": "LineChart"
      },
      {
        "title": "Network Throughput",
        "metrics": ["Network In Total", "Network Out Total"],
        "visualization": "AreaChart"
      }
    ]
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. High CPU Usage
**Symptoms**: CPU percentage alerts firing frequently, application performance degradation

**Possible Causes**:
- Inefficient application code or queries
- Runaway processes or infinite loops
- Insufficient VM size for workload
- Windows Update or antivirus scans
- Cryptocurrency mining malware

**Troubleshooting Steps**:
```powershell
# Windows: Identify CPU-intensive processes
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# Check for Windows services causing high CPU
Get-Service | Where-Object {$_.Status -eq "Running"} | ForEach-Object {
    $processId = (Get-WmiObject -Class Win32_Service -Filter "Name='$($_.Name)'").ProcessId
    if ($processId) {
        Get-Process -Id $processId | Select-Object Name, CPU, WorkingSet
    }
}

# Review recent Windows Updates
Get-WindowsUpdateLog
```

```bash
# Linux: Identify CPU-intensive processes
top -b -n 1 -o %CPU | head -20

# Check for zombie processes
ps aux | awk '$8=="Z" {print}'

# Review system load
uptime
cat /proc/loadavg
```

**Resolution**:
- Optimize application code and database queries
- Terminate runaway or unnecessary processes
- Scale up to larger VM size if workload has grown
- Schedule resource-intensive tasks during off-peak hours
- Implement auto-scaling for variable workloads

#### 2. Low Available Memory
**Symptoms**: Memory percentage alerts firing, system slowness, high page file usage

**Possible Causes**:
- Memory leaks in applications
- Insufficient memory for workload
- Memory-intensive operations (large data processing)
- Memory fragmentation
- Disabled or small page file

**Troubleshooting Steps**:
```powershell
# Windows: Analyze memory usage
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name="Memory(MB)";Expression={$_.WorkingSet / 1MB}}

# Check for memory leaks (monitor over time)
$process = Get-Process -Name "YourAppName"
while($true) {
    Write-Host "$(Get-Date): Memory = $($process.WorkingSet / 1MB) MB"
    Start-Sleep -Seconds 60
    $process.Refresh()
}

# Review page file configuration
Get-WmiObject -Class Win32_PageFileUsage | Select-Object Name, AllocatedBaseSize, CurrentUsage
```

```bash
# Linux: Analyze memory usage
free -h
cat /proc/meminfo

# Identify memory-intensive processes
ps aux --sort=-%mem | head -20

# Check for OOM (Out of Memory) killer activity
dmesg | grep -i "out of memory"
grep -i "killed process" /var/log/messages
```

**Resolution**:
- Restart applications with memory leaks
- Increase VM memory by scaling to larger size
- Configure appropriate page file/swap space
- Implement application memory limits and garbage collection tuning
- Clear caches and temporary files

#### 3. High Disk IOPS or Queue Depth
**Symptoms**: Disk IOPS or queue depth alerts, slow application response, high disk latency

**Possible Causes**:
- Standard HDD insufficient for workload
- Database or application generating excessive I/O
- Insufficient IOPS provisioning for disk tier
- Multiple applications competing for disk I/O
- Antivirus or backup operations

**Troubleshooting Steps**:
```powershell
# Windows: Monitor disk performance
Get-Counter '\PhysicalDisk(*)\Avg. Disk Queue Length'
Get-Counter '\PhysicalDisk(*)\Avg. Disk sec/Read'
Get-Counter '\PhysicalDisk(*)\Avg. Disk sec/Write'

# Identify processes with high disk I/O
Get-Process | Sort-Object -Property @{Expression={$_.WorkingSet + $_.PagedMemorySize}} -Descending | Select-Object -First 10
```

```bash
# Linux: Monitor disk I/O
iostat -x 1 10

# Identify I/O-intensive processes
iotop -o -d 5

# Check for disk errors
dmesg | grep -i "error"
smartctl -a /dev/sda
```

**Resolution**:
- Upgrade to Premium SSD or Ultra Disk for higher IOPS
- Enable disk caching (ReadOnly or ReadWrite based on workload)
- Optimize database indexes and queries
- Distribute workload across multiple data disks
- Schedule I/O-intensive operations during off-peak hours

#### 4. Network Bandwidth Saturation
**Symptoms**: Network In/Out alerts firing, slow data transfer, application timeouts

**Possible Causes**:
- Data transfer exceeding VM network bandwidth limits
- DDoS attack or unusual traffic patterns
- Large file transfers or backups
- Inefficient data serialization
- Missing accelerated networking

**Troubleshooting Steps**:
```powershell
# Windows: Monitor network usage
Get-Counter '\Network Interface(*)\Bytes Total/sec'

# Identify network-intensive processes
Get-NetTCPConnection | Group-Object -Property State | Sort-Object Count -Descending
```

```bash
# Linux: Monitor network usage
iftop -i eth0

# Check network statistics
netstat -s

# Monitor real-time bandwidth
nload
```

**Resolution**:
- Enable accelerated networking for better performance
- Scale to VM size with higher network bandwidth
- Implement Azure CDN for content delivery
- Optimize data transfer and use compression
- Implement rate limiting or traffic shaping

#### 5. VM Heartbeat Failures
**Symptoms**: VM heartbeat alerts, unable to connect to VM, service interruptions

**Possible Causes**:
- VM crashed or frozen
- Host infrastructure issues
- Network connectivity problems
- VM agent not running or misconfigured
- Azure platform issues

**Troubleshooting Steps**:
```bash
# Check VM status
az vm get-instance-view \
  --resource-group "rg-production-vms" \
  --name "vm-web-01" \
  --query "instanceView.statuses"

# Check VM agent status
az vm get-instance-view \
  --resource-group "rg-production-vms" \
  --name "vm-web-01" \
  --query "instanceView.vmAgent"

# Review Azure Service Health
az rest --method get \
  --url "https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2018-07-01"
```

**Resolution**:
- Restart VM through Azure Portal
- Check Azure Service Health for platform issues
- Verify network security group and firewall rules
- Reinstall VM agent if not responding
- Review boot diagnostics for startup failures

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Virtual Machine monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual workload patterns, VM sizes, and performance requirements is recommended for optimal infrastructure monitoring.