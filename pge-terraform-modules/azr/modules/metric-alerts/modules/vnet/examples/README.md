# Azure Virtual Network Monitoring Module - Examples

This directory contains example configurations for using the Azure Virtual Network (VNet) Monitoring module in various deployment scenarios.

## Overview

The Azure Virtual Network Monitoring module provides monitoring capabilities for Azure Virtual Networks, including:

- **1 Metric Alert**: DDoS attack detection for immediate threat response
- **2 Diagnostic Settings**: Integration with Event Hub and Log Analytics for centralized logging
- **VM Protection Alerts**: Network-level security and threat monitoring

## Prerequisites

Before using these examples, ensure you have:

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group for Virtual Networks
3. **Action Group**: Pre-configured action group for alert notifications (e.g., "PGE-Operations")
4. **Virtual Networks**: Existing Azure VNets to monitor
5. **Optional - Event Hub**: For SIEM integration and external log streaming
6. **Optional - Log Analytics Workspace**: For centralized log analysis
7. **Optional - DDoS Protection Plan**: For enhanced DDoS attack detection and mitigation

## Example Scenarios

### Example 1: Production VNets with Full Monitoring

**Use Case**: Comprehensive monitoring for production VNets with SIEM integration

**Features**:
- Monitors 3 production VNets (hub-spoke topology: 1 hub + 2 spokes)
- DDoS attack alert enabled (Severity 1)
- Diagnostic settings for both Event Hub (SIEM) and Log Analytics
- Immediate detection of any DDoS attack (threshold = 0)
- VMProtectionAlerts log category for network security monitoring

**Alert Configuration**:
- IfUnderDDoSAttack: Triggers when metric > 0 (Severity 1)
- Evaluation: PT1M frequency, PT5M window
- Action: Immediate notification via action group

**Monitored VNets**: vnet-pge-hub-prod, vnet-pge-spoke1-prod, vnet-pge-spoke2-prod

### Example 2: Development VNets with Selective Monitoring

**Use Case**: Monitoring for development VNets with Log Analytics only

**Features**:
- Monitors 2 development VNets (hub + 1 spoke)
- DDoS attack alert enabled (Severity 1)
- Log Analytics only (no Event Hub for cost optimization)
- Same detection threshold as production
- Suitable for non-production workloads

**Alert Configuration**:
- IfUnderDDoSAttack: Triggers when metric > 0 (Severity 1)
- Same evaluation parameters as production
- Cost-optimized with single diagnostic destination

**Monitored VNets**: vnet-pge-hub-dev, vnet-pge-spoke1-dev

### Example 3: Basic VNet Monitoring for Test Environment

**Use Case**: Minimal monitoring for test/staging VNets

**Features**:
- Monitors 1 test VNet
- DDoS attack alert enabled (Severity 1)
- No diagnostic settings (cost-optimized for testing)
- Alert-only configuration

**Alert Configuration**:
- IfUnderDDoSAttack: Triggers when metric > 0 (Severity 1)
- No log collection for cost savings

**Monitored VNets**: vnet-pge-test

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
az monitor metrics alert list --resource-group rg-pge-network-prod

# View diagnostic settings for a VNet
az monitor diagnostic-settings list --resource <vnet-resource-id>

# Check VNet metrics
az monitor metrics list --resource <vnet-resource-id> --metric "IfUnderDDoSAttack"
```

## Alert Details

### Metric Alert

#### 1. IfUnderDDoSAttack Alert
- **Name**: `if_under_DDOS_Attack-{vnet-name}`
- **Severity**: 1 (Warning)
- **Metric**: `IfUnderDDoSAttack`
- **Namespace**: `Microsoft.Network/virtualNetworks`
- **Condition**: Maximum > threshold (default: 0)
- **Window**: PT5M (5 minutes)
- **Frequency**: PT1M (1 minute)
- **Description**: Triggers when VNet is under a DDoS attack
- **Use Case**: Immediate notification of DDoS attacks for rapid response

**Metric Behavior**:
- Value = 0: No attack detected
- Value = 1: DDoS attack in progress
- Aggregation: Maximum (captures any attack within the time window)

## Diagnostic Settings

### Event Hub Integration

Sends VNet logs to Event Hub for SIEM integration:

- **Log Categories**: `VMProtectionAlerts`
- **Metrics**: Disabled for Event Hub destination
- **Use Case**: External SIEM systems, real-time monitoring, compliance

### Log Analytics Integration

Sends VNet logs and metrics to Log Analytics for analysis:

- **Log Categories**: `VMProtectionAlerts`
- **Metrics**: `AllMetrics` enabled
- **Use Case**: Centralized logging, query-based analysis, dashboards

### Log Category Details

#### VMProtectionAlerts
Captures network security events including:
- DDoS attack detection events
- Network protection alerts
- Security policy violations
- Threat intelligence matches

## Cross-Subscription Support

The module supports cross-subscription scenarios for diagnostic settings:

```hcl
# Event Hub in different subscription
eventhub_subscription_id      = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
eventhub_resource_group_name  = "rg-shared-monitoring"

# Log Analytics in different subscription
log_analytics_subscription_id      = "ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj"
log_analytics_resource_group_name  = "rg-shared-analytics"
```

## Customization

### Adjusting Threshold

The default threshold is 0 (detect any attack). In most cases, this should not be changed:

```hcl
# Default: Alert on any DDoS attack
vnet_if_under_ddos_attack_threshold = 0

# Not recommended: Higher threshold may miss attacks
vnet_if_under_ddos_attack_threshold = 1  # Only alert if metric > 1
```

**Recommendation**: Keep threshold at 0 for maximum protection.

### Selective Diagnostic Settings

Enable only the diagnostics you need:

```hcl
# Production: Both Event Hub and Log Analytics
enable_diagnostic_settings = true
eventhub_name = "evh-vnet-logs"
log_analytics_workspace_name = "law-pge-monitoring-prod"

# Development: Log Analytics only
enable_diagnostic_settings = true
eventhub_name = ""  # Disable Event Hub
log_analytics_workspace_name = "law-pge-monitoring-dev"

# Test: No diagnostics
enable_diagnostic_settings = false
```

### Multiple VNets

Monitor multiple VNets in a single module call:

```hcl
vnet_names = [
  "vnet-hub-prod",
  "vnet-spoke1-prod",
  "vnet-spoke2-prod",
  "vnet-spoke3-prod",
  # Add more VNets as needed
]
```

## Outputs

The module provides comprehensive outputs for integration:

```hcl
# DDoS attack alert IDs
output "if_under_ddos_attack_alert_ids" {
  value = module.vnet_monitoring.if_under_ddos_attack_alert_ids
}

# Diagnostic setting IDs
output "diagnostic_setting_eventhub_ids" {
  value = module.vnet_monitoring.diagnostic_setting_eventhub_ids
}

# Monitoring configuration summary
output "monitoring_configuration" {
  value = module.vnet_monitoring.monitoring_configuration
}
```

## Troubleshooting

### Alert Not Triggering

1. **Verify VNet exists**:
   ```bash
   az network vnet show --name vnet-pge-hub-prod --resource-group rg-pge-network-prod
   ```

2. **Check alert status**:
   ```bash
   az monitor metrics alert show --name if_under_DDOS_Attack-vnet-pge-hub-prod --resource-group rg-pge-network-prod
   ```

3. **Review current metric values**:
   ```bash
   az monitor metrics list --resource <vnet-resource-id> --metric "IfUnderDDoSAttack"
   ```

4. **Verify DDoS Protection Plan** (if applicable):
   ```bash
   az network ddos-protection show --name <ddos-plan-name> --resource-group <resource-group>
   ```

### DDoS Protection Plan

**Important**: The `IfUnderDDoSAttack` metric is most effective when used with Azure DDoS Protection Standard plan. Basic DDoS protection is included with all VNets, but the Standard plan provides:

- Enhanced DDoS detection and mitigation
- Real-time attack metrics
- Attack analytics and reports
- Cost protection guarantee

Without DDoS Protection Standard, the metric may not populate consistently.

### Diagnostic Settings Issues

1. **Verify Event Hub permissions**:
   ```bash
   az eventhubs eventhub show --name evh-vnet-logs --namespace-name evhns-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

2. **Check Log Analytics workspace**:
   ```bash
   az monitor log-analytics workspace show --workspace-name law-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

3. **Review diagnostic setting**:
   ```bash
   az monitor diagnostic-settings show --name send-vnet-logs-to-eventhub --resource <vnet-resource-id>
   ```

### Permission Issues

Ensure the deployment identity has these permissions:

- `Microsoft.Insights/metricAlerts/write`
- `Microsoft.Insights/diagnosticSettings/write`
- `Microsoft.Network/virtualNetworks/read`
- `Microsoft.EventHub/namespaces/eventhubs/read` (for Event Hub)
- `Microsoft.OperationalInsights/workspaces/read` (for Log Analytics)
- `Microsoft.Network/ddosProtectionPlans/read` (if using DDoS Protection Standard)

## Cost Optimization

### Production Environment
- **Estimated Cost**: $0.50-2/month per VNet
- **Components**: 
  - 1 metric alert: ~$0.10/alert/month
  - Diagnostic settings: Based on log volume
  - Event Hub ingestion: Based on throughput
  - DDoS Protection Standard: $2,944/month (subscription-level, not per-VNet)

### Development Environment
- **Estimated Cost**: $0.20-1/month per VNet
- **Optimization**: Log Analytics only (no Event Hub)
- **Components**:
  - 1 metric alert: ~$0.10/alert/month
  - Log Analytics ingestion: Based on volume

### Test Environment
- **Estimated Cost**: $0.10/month per VNet
- **Optimization**: No diagnostic settings
- **Components**:
  - 1 metric alert: ~$0.10/alert/month

**Note**: The largest cost factor for DDoS protection is the DDoS Protection Standard plan itself, which is applied at the subscription level and protects all VNets in that subscription.

## Best Practices

1. **Enable DDoS Protection Standard**: For production VNets handling critical workloads
2. **Monitor All Production VNets**: Include all VNets in hub-spoke topologies
3. **Test Alert Response**: Verify alert notifications reach the right teams
4. **Review Logs Regularly**: Check VMProtectionAlerts for security insights
5. **Document Runbooks**: Create response procedures for DDoS attacks
6. **Use Tags Consistently**: Apply consistent tags for cost tracking and governance
7. **Cross-Region Redundancy**: Monitor VNets in all regions
8. **Integration with NSG Flow Logs**: Combine with NSG Flow Logs for comprehensive network monitoring
9. **Regular Review**: Periodically review VNet security configurations
10. **Incident Response Plan**: Have a documented DDoS mitigation strategy

## DDoS Protection Strategy

### Without DDoS Protection Standard
- Basic protection included (network layer)
- Limited metrics and visibility
- Manual mitigation required
- Best for: Non-critical workloads, development/test

### With DDoS Protection Standard
- Enhanced detection and auto-mitigation
- Real-time attack metrics and analytics
- 24/7 monitoring by Azure
- Cost protection guarantee
- Best for: Production workloads, critical applications

## Additional Resources

- [Azure Virtual Network Documentation](https://learn.microsoft.com/azure/virtual-network/)
- [Azure DDoS Protection](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-overview)
- [Virtual Network Metrics](https://learn.microsoft.com/azure/virtual-network/monitor-virtual-network-reference)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)
- [DDoS Protection Pricing](https://azure.microsoft.com/pricing/details/ddos-protection/)

## Support

For issues or questions:
1. Review the main module README
2. Check Azure Virtual Network documentation
3. Verify VNet and DDoS Protection configuration
4. Review metric values in Azure Portal
5. Contact your Azure administrator

## License

This module follows the same license as the parent repository.
