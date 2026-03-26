# Azure Firewall Monitoring Alerts - Examples

This directory contains example configurations for deploying the Azure Firewall monitoring alerts module with different configurations.

## Examples

### 1. Production Deployment
A comprehensive production setup with:
- Strict thresholds for production workloads
- Monitoring multiple Azure Firewalls
- Critical alerting on health and performance metrics

### 2. Development Deployment
A development-focused configuration with:
- Relaxed thresholds suitable for dev/test environments
- Single firewall monitoring
- More lenient alerting for testing scenarios

### 3. Basic Deployment
A minimal configuration using:
- Default threshold values
- Standard alert configuration
- Quick setup for testing

## Alert Types

The module supports the following metric alerts for Azure Firewalls:

### Health and Availability
1. **Firewall Health** - Monitors the overall health state of Azure Firewall
   - Default threshold: 90% (Alert when below 90%)
   - Severity: Critical (0)
   - Indicates degraded or unhealthy firewall state

### Capacity and Performance
2. **SNAT Port Utilization** - Tracks SNAT port exhaustion risk
   - Default threshold: 95%
   - Severity: Error (1)
   - Critical for preventing connection failures due to port exhaustion

3. **Firewall Throughput** - Monitors data throughput capacity
   - Default threshold: 25 Gbps (25,000,000,000 bits/sec)
   - Severity: Warning (2)
   - Helps identify when approaching maximum capacity

4. **Firewall Latency** - Tracks firewall processing latency
   - Default threshold: 20 milliseconds
   - Severity: Warning (2)
   - Indicates performance degradation or resource constraints

5. **Data Processed** - Monitors total data processed volume
   - Default threshold: 1 TB per hour (1,000,000,000,000 bytes)
   - Severity: Informational (3)
   - Tracks overall firewall workload

### Rule Processing
6. **Application Rule Hits** - Tracks application rule processing rate
   - Default threshold: 100,000 hits per hour
   - Severity: Informational (3)
   - Monitors application-layer traffic patterns

7. **Network Rule Hits** - Monitors network rule processing rate
   - Default threshold: 100,000 hits per hour
   - Severity: Informational (3)
   - Tracks network-layer traffic patterns

## Usage

1. Copy one of the example configurations
2. Update the values to match your environment:
   - Firewall names
   - Resource group names
   - Action group details
   - Azure region location
   - Tags
3. Adjust thresholds based on your firewall capacity and traffic patterns
4. Run terraform commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Required Variables

All examples require these core variables:
- `firewall_names` - List of Azure Firewall names to monitor
- `resource_group_name` - Resource group containing the firewalls
- `action_group_resource_group_name` - Resource group containing the action group
- `action_group` - Name of the action group for alert notifications
- `location` - Azure region for the alerts

## Outputs

Each example exports:
- `alert_ids` - Map of firewall names to their alert resource IDs
- `alert_names` - Map of firewall names to their alert resource names
- `monitored_firewalls` - List of monitored firewall names
- `action_group_id` - ID of the action group used

## Customization

You can customize the alerts by:
- Adjusting thresholds based on your firewall SKU and capacity
- Modifying alert evaluation frequency and window size (in module code)
- Adding custom tags for organization
- Changing severity levels based on your operational requirements

## Notes

- **Firewall SKU**: Threshold values should be adjusted based on your Azure Firewall SKU (Basic, Standard, or Premium)
- **SNAT Ports**: The SNAT port utilization alert is critical - port exhaustion can cause outbound connection failures
- **Throughput**: Standard SKU supports up to 30 Gbps, Premium up to 100 Gbps - adjust thresholds accordingly
- **Latency**: Consistent high latency may indicate resource constraints or complex rule processing
- **Health State**: A health state below 100% indicates degraded performance; below 90% requires immediate attention
- **Rule Hits**: High rule hit counts are normal but sudden changes may indicate traffic pattern shifts or attacks
- **Data Processed**: Correlate with throughput and latency for complete performance picture

## Firewall SKU Considerations

### Basic SKU
- Throughput: Up to 250 Mbps
- Suitable for small-scale deployments
- Lower threshold recommendations: 200 Mbps throughput

### Standard SKU  
- Throughput: Up to 30 Gbps
- Default threshold: 25 Gbps is appropriate
- SNAT ports: 1,024 per public IP (pre-allocated)

### Premium SKU
- Throughput: Up to 100 Gbps
- Higher threshold recommendations: 80-90 Gbps
- Additional features: TLS inspection, IDPS, URL filtering

Adjust all threshold values based on your specific SKU and expected traffic patterns.
