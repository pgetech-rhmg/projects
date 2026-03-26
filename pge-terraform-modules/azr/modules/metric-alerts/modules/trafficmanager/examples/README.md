# Azure Traffic Manager Monitoring Module - Examples

This directory contains example configurations for using the Azure Traffic Manager Monitoring module in various deployment scenarios.

## Overview

The Azure Traffic Manager Monitoring module provides comprehensive monitoring capabilities for Azure Traffic Manager profiles, including:

- **2 Metric Alerts**: Real-time monitoring of endpoint health and probe agent state
- **4 Activity Log Alerts**: Tracking of Traffic Manager lifecycle events (creation, deletion, configuration changes, endpoint operations)
- **2 Scheduled Query Rules**: Advanced monitoring for DNS resolution failures and endpoint health degradation
- **2 Diagnostic Settings**: Integration with Event Hub and Log Analytics for centralized logging

## Prerequisites

Before using these examples, ensure you have:

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group for Traffic Manager profiles
3. **Action Group**: Pre-configured action group for alert notifications (e.g., "PGE-Operations")
4. **Traffic Manager Profiles**: Existing Traffic Manager profiles to monitor
5. **Optional - Event Hub**: For SIEM integration and external log streaming
6. **Optional - Log Analytics Workspace**: For centralized log analysis and querying

## Example Scenarios

### Example 1: Production Multi-Region Traffic Manager

**Use Case**: Full monitoring for production Traffic Manager profiles with SIEM integration

**Features**:
- Monitors 3 Traffic Manager profiles (`tm-pge-webapp-prod`, `tm-pge-api-prod`, `tm-pge-cdn-prod`)
- All alerts enabled for comprehensive visibility
- Diagnostic settings configured for both Event Hub (SIEM) and Log Analytics
- High-frequency evaluation for critical alerts (PT1M)
- Severity 1 alerts for endpoint health issues
- Subscription-level activity log monitoring

**Alert Configuration**:
- Endpoint Health: Triggers when healthy endpoints < 1 (Severity 1)
- Probe Agent State: Monitors endpoint state changes (Severity 2)
- DNS Resolution Failure: Detects DNS issues (Severity 1)
- Endpoint Health Degradation: Monitors overall health trends (Severity 2)
- Activity Logs: Profile creation, deletion, config changes, endpoint operations

**Thresholds**:
- `endpoint_health_threshold`: 1 (minimum healthy endpoints)
- `probe_agent_current_endpoint_state_by_profile_resource_id_threshold`: 1

### Example 2: Development Traffic Manager

**Use Case**: Selective monitoring for development Traffic Manager profiles with reduced alert frequency

**Features**:
- Monitors 2 Traffic Manager profiles (`tm-pge-webapp-dev`, `tm-pge-api-dev`)
- Only critical alerts enabled (endpoint health, probe monitoring, deletion)
- Diagnostic settings configured for Log Analytics only (no SIEM)
- Medium-frequency evaluation for cost optimization (PT5M-PT15M)
- Reduced alert noise for development environment

**Alert Configuration**:
- Endpoint Health: Enabled (Severity 1)
- Probe Agent State: Enabled (Severity 2)
- Traffic Manager Deletion: Enabled
- Other Alerts: Disabled for development efficiency

**Thresholds**:
- `endpoint_health_threshold`: 1 (minimum healthy endpoints)
- `probe_agent_current_endpoint_state_by_profile_resource_id_threshold`: 1

### Example 3: Basic Traffic Manager Monitoring

**Use Case**: Minimal monitoring for test/staging Traffic Manager profiles

**Features**:
- Monitors 1 Traffic Manager profile (`tm-pge-webapp-test`)
- Only endpoint health and deletion alerts enabled
- No diagnostic settings (cost-optimized for testing)
- Standard time windows and evaluation frequencies
- Minimal alert configuration for testing purposes

**Alert Configuration**:
- Endpoint Health: Enabled (Severity 1)
- Traffic Manager Deletion: Enabled
- All Other Alerts: Disabled

**Thresholds**:
- `endpoint_health_threshold`: 1 (minimum healthy endpoints)

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
az monitor metrics alert list --resource-group rg-pge-trafficmanager-prod

# List all activity log alerts
az monitor activity-log alert list --resource-group rg-pge-trafficmanager-prod

# View diagnostic settings
az monitor diagnostic-settings list --resource <traffic-manager-profile-id>
```

## Alert Details

### Metric Alerts

#### 1. Endpoint Health Alert
- **Name**: `TrafficManager-endpoint-health-{profile-name}`
- **Severity**: 1 (Critical)
- **Metric**: `ProbeAgentCurrentEndpointStateByProfileResourceId`
- **Condition**: Maximum < threshold (default: 1)
- **Window**: PT15M (configurable)
- **Frequency**: PT5M (configurable)
- **Description**: Triggers when Traffic Manager has fewer healthy endpoints than the threshold

#### 2. Probe Agent Endpoint State Alert
- **Name**: `TrafficManager-probe-agent-state-{profile-name}`
- **Severity**: 2 (Warning)
- **Metric**: `ProbeAgentCurrentEndpointStateByProfileResourceId`
- **Condition**: Average < threshold (default: 1)
- **Window**: PT5M (configurable)
- **Frequency**: PT1M (configurable)
- **Description**: Monitors endpoint state changes detected by probe agents

### Activity Log Alerts

#### 3. Traffic Manager Creation Alert
- **Name**: `TrafficManager-Creation-Alert-{profile-names}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Network/trafficManagerProfiles/write`
- **Category**: Administrative
- **Level**: Informational
- **Description**: Triggers when a new Traffic Manager profile is created

#### 4. Traffic Manager Deletion Alert
- **Name**: `TrafficManager-Deletion-Alert-{profile-names}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Network/trafficManagerProfiles/delete`
- **Category**: Administrative
- **Level**: Warning
- **Description**: Triggers when a Traffic Manager profile is deleted

#### 5. Traffic Manager Configuration Change Alert
- **Name**: `TrafficManager-ConfigChange-Alert-{profile-names}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Network/trafficManagerProfiles/write`
- **Category**: Administrative
- **Level**: Warning
- **Status**: Succeeded
- **Description**: Triggers when Traffic Manager profile configuration is modified

#### 6. Endpoint Operations Alert
- **Name**: `TrafficManager-EndpointOps-Alert-{profile-names}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Network/trafficManagerProfiles/write`
- **Category**: Administrative
- **Level**: Informational
- **Description**: Triggers when Traffic Manager endpoints are created, modified, or deleted

### Scheduled Query Rules

#### 7. DNS Resolution Failure Alert
- **Name**: `TrafficManager-DNSFailure-Alert-{profile-names}`
- **Severity**: 1 (Critical)
- **Query**: Monitors AzureActivity for failed DNS operations
- **Window**: PT15M (configurable)
- **Frequency**: PT5M (configurable)
- **Threshold**: >= 1 failure
- **Description**: Detects DNS resolution failures in Traffic Manager

#### 8. Endpoint Health Degradation Alert
- **Name**: `TrafficManager-EndpointHealth-Alert-{profile-names}`
- **Severity**: 2 (Warning)
- **Query**: Monitors AzureActivity for endpoint health issues
- **Window**: PT15M (configurable)
- **Frequency**: PT5M (configurable)
- **Threshold**: >= 1 degradation event
- **Description**: Monitors for significant endpoint health degradation

## Diagnostic Settings

### Event Hub Integration

Sends Traffic Manager activity logs to Event Hub for SIEM integration:

- **Log Categories**: `ProbeHealthStatusEvents`
- **Metrics**: Disabled for Event Hub destination
- **Use Case**: External SIEM systems, real-time monitoring, compliance

### Log Analytics Integration

Sends Traffic Manager logs and metrics to Log Analytics for analysis:

- **Log Categories**: `ProbeHealthStatusEvents`
- **Metrics**: `AllMetrics` enabled
- **Use Case**: Centralized logging, query-based analysis, dashboards

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

### Adjusting Thresholds

Modify alert thresholds based on your requirements:

```hcl
# Require at least 2 healthy endpoints
endpoint_health_threshold = 2

# Adjust probe agent monitoring threshold
probe_agent_current_endpoint_state_by_profile_resource_id_threshold = 2
```

### Time Windows and Frequencies

Customize evaluation windows and frequencies:

```hcl
# Faster evaluation for critical alerts
window_duration_short      = "PT1M"
evaluation_frequency_high  = "PT30S"

# Longer evaluation for trend analysis
window_duration_long       = "PT2H"
evaluation_frequency_low   = "PT30M"
```

### Selective Alert Enablement

Enable only the alerts you need:

```hcl
# Production: All alerts enabled
enable_endpoint_health_alert               = true
enable_probe_agent_monitoring_alert        = true
enable_traffic_manager_creation_alert      = true
enable_traffic_manager_deletion_alert      = true
enable_traffic_manager_config_change_alert = true
enable_endpoint_operations_alert           = true
enable_dns_resolution_failure_alert        = true

# Development: Only critical alerts
enable_endpoint_health_alert               = true
enable_probe_agent_monitoring_alert        = true
enable_traffic_manager_deletion_alert      = true
# ... other alerts disabled
```

## Outputs

The module provides comprehensive outputs for integration:

```hcl
# Metric alert IDs by profile
output "endpoint_health_alert_ids" {
  value = module.trafficmanager_monitoring.endpoint_health_alert_ids
}

# Activity log alert IDs
output "traffic_manager_deletion_alert_id" {
  value = module.trafficmanager_monitoring.traffic_manager_deletion_alert_id
}

# Diagnostic setting IDs
output "diagnostic_setting_eventhub_ids" {
  value = module.trafficmanager_monitoring.diagnostic_setting_eventhub_ids
}

# Monitoring configuration summary
output "monitoring_configuration" {
  value = module.trafficmanager_monitoring.monitoring_configuration
}
```

## Troubleshooting

### Alert Not Triggering

1. **Verify Traffic Manager profile exists**:
   ```bash
   az network traffic-manager profile show --name tm-pge-webapp-prod --resource-group rg-pge-trafficmanager-prod
   ```

2. **Check alert status**:
   ```bash
   az monitor metrics alert show --name TrafficManager-endpoint-health-tm-pge-webapp-prod --resource-group rg-pge-trafficmanager-prod
   ```

3. **Review metric values**:
   ```bash
   az monitor metrics list --resource <traffic-manager-profile-id> --metric ProbeAgentCurrentEndpointStateByProfileResourceId
   ```

### Diagnostic Settings Issues

1. **Verify Event Hub connection**:
   ```bash
   az eventhubs eventhub show --name evh-trafficmanager-logs --namespace-name evhns-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

2. **Check Log Analytics workspace**:
   ```bash
   az monitor log-analytics workspace show --workspace-name law-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

3. **Review diagnostic setting configuration**:
   ```bash
   az monitor diagnostic-settings show --name send-trafficmanager-logs-to-eventhub --resource <traffic-manager-profile-id>
   ```

### Permission Issues

Ensure the deployment identity has these permissions:

- `Microsoft.Insights/metricAlerts/write`
- `Microsoft.Insights/activityLogAlerts/write`
- `Microsoft.Insights/scheduledQueryRules/write`
- `Microsoft.Insights/diagnosticSettings/write`
- `Microsoft.Network/trafficManagerProfiles/read`
- `Microsoft.EventHub/namespaces/eventhubs/read` (for Event Hub)
- `Microsoft.OperationalInsights/workspaces/read` (for Log Analytics)

## Cost Optimization

### Production Environment
- **Estimated Cost**: $5-10/month per profile
- **Components**: 
  - 2 metric alerts: ~$0.10/alert/month
  - 4 activity log alerts: Free
  - 2 scheduled query rules: ~$0.50/query/month
  - Diagnostic settings: Based on data ingestion

### Development Environment
- **Estimated Cost**: $2-5/month per profile
- **Optimization**: Fewer alerts, Log Analytics only
- **Components**:
  - 2 metric alerts: ~$0.10/alert/month
  - 1 activity log alert: Free
  - Diagnostic settings: Reduced data volume

### Test Environment
- **Estimated Cost**: $1-2/month per profile
- **Optimization**: Minimal alerts, no diagnostic settings
- **Components**:
  - 1 metric alert: ~$0.10/alert/month
  - 1 activity log alert: Free

## Best Practices

1. **Start with Critical Alerts**: Begin with endpoint health and deletion alerts, then expand
2. **Use Appropriate Thresholds**: Set thresholds based on your endpoint count and SLA requirements
3. **Test Alert Configuration**: Verify alerts trigger correctly before production deployment
4. **Monitor Cost**: Track alert and diagnostic settings costs in Azure Cost Management
5. **Regular Review**: Periodically review alert configurations and thresholds
6. **Document Runbooks**: Create response procedures for each alert type
7. **Use Tags Consistently**: Apply consistent tags for cost tracking and governance

## Additional Resources

- [Azure Traffic Manager Documentation](https://learn.microsoft.com/azure/traffic-manager/)
- [Azure Monitor Alerts Overview](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-overview)
- [Traffic Manager Metrics](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-metrics-alerts)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)

## Support

For issues or questions:
1. Review the main module README
2. Check Azure Traffic Manager documentation
3. Verify Traffic Manager profile configuration
4. Contact your Azure administrator

## License

This module follows the same license as the parent repository.
