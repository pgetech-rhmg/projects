# Azure Front Door Monitoring Alerts - Examples

This directory contains example configurations for deploying the Azure Front Door monitoring alerts module with different configurations.

## Examples

### 1. Production Deployment
A comprehensive production setup with:
- Standard/Premium Front Door (Azure CDN profile)
- All alert categories enabled
- Strict thresholds for production workloads
- Full diagnostic settings (Event Hub + Log Analytics)
- Monitoring multiple Front Door instances

### 2. Development Deployment
A development-focused configuration with:
- Classic Front Door (legacy)
- Only critical alerts enabled
- Relaxed thresholds suitable for dev/test environments
- Log Analytics only (no Event Hub)
- Single Front Door monitoring

### 3. Basic Deployment
A minimal configuration using:
- Standard/Premium Front Door
- Default threshold values
- Standard alert configuration
- No diagnostic settings
- Quick setup for testing

## Alert Types

The module supports the following metric alerts for Azure Front Door:

### Performance Monitoring
1. **High Response Time** - Monitors Front Door response latency
   - Default threshold: 5,000 milliseconds (5 seconds)
   - Severity: Warning (2)
   - Indicates performance degradation or backend issues

2. **Backend Health** - Tracks backend/origin health percentage
   - Default threshold: 80%
   - Severity: Error (1)
   - Critical for detecting backend availability issues

3. **High Request Count** - Monitors request volume spikes
   - Default threshold: 10,000 requests
   - Severity: Informational (3)
   - Helps identify traffic surges or potential DDoS

### Availability Monitoring
4. **High Error Rate** - Tracks HTTP error response percentage
   - Default threshold: 5%
   - Severity: Error (1)
   - Indicates application or configuration issues

5. **Low Availability** - Monitors overall service availability
   - Default threshold: 99% (alerts when below)
   - Severity: Critical (0)
   - Critical for SLA compliance

### Security Monitoring
6. **WAF Blocked Requests** - Tracks Web Application Firewall blocks
   - Default threshold: 1,000 blocked requests
   - Severity: Warning (2)
   - Indicates potential security threats or attacks

## Front Door Types

The module supports both Front Door types:

### Classic Front Door (Microsoft.Network/frontDoors)
- Legacy Front Door service
- Being phased out by Microsoft
- Use `front_door_type = "classic"`

### Standard/Premium Front Door (Microsoft.Cdn/profiles)
- Modern Azure CDN-based Front Door
- Recommended for new deployments
- Use `front_door_type = "standard"`

## Diagnostic Settings

The module supports forwarding Front Door diagnostic logs and metrics to:
- **Event Hub** - For streaming to external systems
- **Log Analytics** - For query and analysis in Azure Monitor

Diagnostic settings can be enabled/disabled independently per destination.

## Usage

1. Copy one of the example configurations
2. Update the values to match your environment:
   - Front Door names
   - Front Door type (classic or standard)
   - Resource group names
   - Action group details
   - Diagnostic settings endpoints (if enabled)
   - Tags
3. Adjust thresholds based on your traffic patterns and SLAs
4. Run terraform commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Required Variables

All examples require these core variables:
- `front_door_names` - List of Front Door names to monitor
- `resource_group_name` - Resource group containing the Front Door resources
- `action_group_resource_group_name` - Resource group containing the action group
- `action_group` - Name of the action group for alert notifications
- `location` - Azure region for the alerts
- `front_door_type` - Type of Front Door ("classic" or "standard")

## Outputs

Each example exports:
- `alert_ids` - Map of Front Door names to their alert resource IDs
- `alert_names` - Map of Front Door names to their alert resource names
- `diagnostic_settings` - Diagnostic settings configuration details
- `monitored_frontdoors` - List of monitored Front Door names
- `front_door_type` - Type of Front Door being monitored
- `action_group_id` - ID of the action group used

## Customization

You can customize the alerts by:
- Enabling/disabling alert categories (performance, availability, security, cost)
- Adjusting thresholds based on your baseline and SLAs
- Configuring diagnostic settings destinations
- Modifying alert evaluation frequency and window size (in module code)
- Adding custom tags for organization
- Supporting multiple subscriptions for Front Door resources

## Notes

- **Front Door Type**: Ensure you specify the correct type - Classic uses Microsoft.Network, Standard/Premium uses Microsoft.Cdn
- **Backend Health**: Low backend health directly impacts user experience - monitor closely
- **Response Time**: Includes time to first byte from origin - high values may indicate backend performance issues
- **Error Rate**: Sudden increases may indicate application errors, misconfigurations, or attacks
- **Availability**: Critical metric for SLA compliance - typical target is 99.9% or higher
- **WAF Blocks**: High block rates may indicate legitimate attacks or overly restrictive WAF rules
- **Request Count**: Useful for capacity planning and detecting traffic anomalies
- **Diagnostic Settings**: Provide detailed logs for troubleshooting and security analysis
- **Cross-subscription**: Module supports Front Door resources across multiple Azure subscriptions
- **Migration**: Microsoft recommends migrating from Classic to Standard/Premium Front Door

## Performance Considerations

### Response Time Factors
- Origin server performance
- Geographic distribution of users vs. origin location
- Front Door caching effectiveness
- Network latency between Front Door PoPs and origin

### Backend Health Factors
- Origin server availability
- Health probe configuration
- Network connectivity to origins
- SSL/TLS certificate validity

### Optimization Tips
1. Enable caching for static content
2. Use compression for text-based resources
3. Optimize origin server performance
4. Configure appropriate health probe intervals
5. Use multiple origins for redundancy
6. Consider Front Door Premium for advanced routing
