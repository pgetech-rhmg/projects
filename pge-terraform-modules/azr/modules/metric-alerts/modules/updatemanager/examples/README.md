# Azure Update Manager Monitoring Module - Examples

This directory contains example configurations for using the Azure Update Manager Monitoring module in various deployment scenarios.

## Overview

The Azure Update Manager Monitoring module provides comprehensive monitoring capabilities for Azure Update Manager operations, including:

- **6 Activity Log Alerts**: Tracking update deployments, maintenance configuration changes, and VM update operations
- **6 Scheduled Query Rules**: Advanced monitoring for update compliance, critical updates, installation failures, assessment failures, and maintenance window violations
- **No Diagnostic Settings**: Update Manager monitoring relies on Activity Logs and Log Analytics queries

## Prerequisites

Before using these examples, ensure you have:

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group for Update Manager alerts
3. **Action Group**: Pre-configured action group for alert notifications (e.g., "PGE-Operations")
4. **Virtual Machines**: Azure VMs enrolled in Azure Update Manager
5. **Log Analytics Workspace**: Required for scheduled query rules and update compliance tracking
6. **Update Management Solution**: Azure Update Management or Azure Update Manager enabled

## Example Scenarios

### Example 1: Production Update Manager with Full Monitoring

**Use Case**: Comprehensive monitoring for production VMs with strict compliance requirements

**Features**:
- Monitors 5 production VMs across web, app, and database tiers
- All 12 alerts enabled for complete visibility
- Strict compliance threshold (95%)
- Low tolerance for failures (threshold = 1)
- Tight maintenance window monitoring (15 minutes)
- Critical and security updates tracked immediately

**Alert Configuration**:
- Update Deployment Failures: Threshold = 1 (immediate alert)
- Update Compliance: < 95% (high compliance requirement)
- Patch Installation Failures: Threshold = 1 (immediate alert)
- Update Assessment Failures: Threshold = 1 (immediate alert)
- Critical Updates Available: Threshold = 1 (immediate notification)
- Maintenance Window Violations: 15-minute tolerance

**Monitored VMs**: 5 VMs (web-prod-01, web-prod-02, app-prod-01, app-prod-02, db-prod-01)

### Example 2: Development Update Manager with Relaxed Monitoring

**Use Case**: Monitoring for development VMs with balanced alerting

**Features**:
- Monitors 3 development VMs (web, app, database)
- Critical alerts enabled (8 total)
- Relaxed compliance threshold (80%)
- Higher tolerance for failures (threshold = 2-3)
- Extended maintenance window monitoring (60 minutes)
- Non-essential alerts disabled

**Alert Configuration**:
- Update Deployment Failures: Threshold = 2
- Update Compliance: < 80% (development acceptable)
- Patch Installation Failures: Threshold = 2
- Critical Updates Available: Threshold = 3
- Maintenance Window: Disabled
- Update Assessment: Disabled

**Monitored VMs**: 3 VMs (web-dev-01, app-dev-01, db-dev-01)

### Example 3: Basic Update Manager Monitoring

**Use Case**: Minimal monitoring for test/staging VMs

**Features**:
- Monitors 1 test VM
- Only critical alerts enabled (6 total)
- Minimal compliance threshold (70%)
- High tolerance for failures (threshold = 3-5)
- Cost-optimized for testing
- Non-critical alerts disabled

**Alert Configuration**:
- Update Deployment Failures: Threshold = 3
- Patch Installation Failures: Threshold = 3
- Critical Updates Available: Threshold = 5
- Update Compliance: Disabled
- Maintenance Window: Disabled
- Update Assessment: Disabled

**Monitored VMs**: 1 VM (vm-test-01)

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
# List all activity log alerts
az monitor activity-log alert list --resource-group rg-pge-updatemanager-prod

# List scheduled query rules
az monitor scheduled-query list --resource-group rg-pge-updatemanager-prod

# Check Log Analytics workspace
az monitor log-analytics workspace show --workspace-name law-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
```

## Alert Details

### Activity Log Alerts

#### 1. Update Deployment Started Alert
- **Name**: `update-deployment-started-{subscription-ids}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Maintenance/maintenanceConfigurations/write`
- **Category**: Administrative
- **Description**: Triggers when Update Manager deployment is started

#### 2. Update Deployment Failed Alert
- **Name**: `update-deployment-failed-{subscription-ids}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Maintenance/applyUpdates/write`
- **Category**: Administrative
- **Status**: Failed
- **Description**: Triggers when Update Manager deployment fails

#### 3. Maintenance Configuration Change Alert
- **Name**: `maintenance-config-change-{subscription-ids}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Maintenance/maintenanceConfigurations/write`
- **Category**: Administrative
- **Description**: Triggers when Maintenance Configuration is modified

#### 4. Maintenance Configuration Deleted Alert
- **Name**: `maintenance-config-deleted-{subscription-ids}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Maintenance/maintenanceConfigurations/delete`
- **Category**: Administrative
- **Description**: Triggers when Maintenance Configuration is deleted

#### 5. Update Assessment Triggered Alert
- **Name**: `update-assessment-triggered-{subscription-ids}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Maintenance/configurationAssignments/write`
- **Category**: Administrative
- **Description**: Triggers when Update Assessment is triggered

#### 6. VM Update Failed Alert
- **Name**: `vm-update-failed-{subscription-ids}`
- **Scope**: Subscription-level
- **Operation**: `Microsoft.Compute/virtualMachines/extensions/write`
- **Category**: Administrative
- **Status**: Failed
- **Description**: Triggers when VM update installation fails

### Scheduled Query Rules

#### 7. Update Compliance Low Alert
- **Name**: `update-compliance-low-{subscription-ids}`
- **Severity**: 2 (Warning)
- **Evaluation**: Every 1 day (P1D)
- **Window**: 1 day (P1D)
- **Query**: Monitors Update table for compliance rate
- **Threshold**: Configurable (default: < 90%)
- **Description**: Alerts when VM update compliance drops below threshold

#### 8. Critical Updates Available Alert
- **Name**: `critical-updates-available-{subscription-ids}`
- **Severity**: 1 (Critical)
- **Evaluation**: Every 1 day (P1D)
- **Window**: 1 day (P1D)
- **Query**: Monitors critical and security updates
- **Threshold**: Configurable (default: >= 1)
- **Description**: Alerts when critical updates are available for VMs

#### 9. Update Installation Failures Alert
- **Name**: `update-installation-failures-{subscription-ids}`
- **Severity**: 1 (Critical)
- **Evaluation**: Every 1 hour (PT1H)
- **Window**: 6 hours (PT6H)
- **Query**: Monitors failed update installations
- **Threshold**: Configurable (default: >= 1)
- **Description**: Alerts when update installations fail on VMs

#### 10. Update Assessment Failures Alert
- **Name**: `update-assessment-failures-{subscription-ids}`
- **Severity**: 2 (Warning)
- **Evaluation**: Every 6 hours (PT6H)
- **Window**: 6 hours (PT6H)
- **Query**: Monitors update assessment status
- **Threshold**: Configurable (default: >= 1)
- **Description**: Alerts when update assessments fail on VMs

#### 11. Maintenance Window Violations Alert
- **Name**: `maintenance-window-violations-{subscription-ids}`
- **Severity**: 2 (Warning)
- **Evaluation**: Every 1 hour (PT1H)
- **Window**: 1 hour (PT1H)
- **Query**: Monitors updates installed outside maintenance windows
- **Condition**: Outside 2-6 AM, not weekends
- **Description**: Alerts when updates are installed outside maintenance windows

## Customization

### Adjusting Thresholds

Modify alert thresholds based on your requirements:

```hcl
# Production: Strict compliance
update_compliance_threshold = 95  # 95% compliance required
patch_installation_failure_threshold = 1  # Alert on first failure
critical_update_available_threshold = 1  # Immediate notification

# Development: Relaxed compliance
update_compliance_threshold = 80  # 80% acceptable
patch_installation_failure_threshold = 2  # Tolerate some failures
critical_update_available_threshold = 3  # Less sensitive

# Test: Minimal compliance
update_compliance_threshold = 70  # 70% acceptable
patch_installation_failure_threshold = 3  # Higher tolerance
critical_update_available_threshold = 5  # Very relaxed
```

### Selective Alert Enablement

Enable only the alerts you need:

```hcl
# Production: All alerts enabled
enable_update_deployment_failure_alert = true
enable_update_compliance_alert         = true
enable_maintenance_window_alert        = true
enable_patch_installation_failure_alert = true
enable_update_assessment_failure_alert = true
enable_critical_update_available_alert = true

# Development: Critical alerts only
enable_update_deployment_failure_alert = true
enable_update_compliance_alert         = true
enable_maintenance_window_alert        = false
enable_patch_installation_failure_alert = true
enable_update_assessment_failure_alert = false
enable_critical_update_available_alert = true

# Test: Minimal alerts
enable_update_deployment_failure_alert = true
enable_update_compliance_alert         = false
enable_maintenance_window_alert        = false
enable_patch_installation_failure_alert = true
enable_update_assessment_failure_alert = false
enable_critical_update_available_alert = true
```

### Adding More VMs

Expand the list of monitored VMs:

```hcl
vm_resource_ids = [
  "/subscriptions/{sub-id}/resourceGroups/rg-vms/providers/Microsoft.Compute/virtualMachines/vm-01",
  "/subscriptions/{sub-id}/resourceGroups/rg-vms/providers/Microsoft.Compute/virtualMachines/vm-02",
  "/subscriptions/{sub-id}/resourceGroups/rg-vms/providers/Microsoft.Compute/virtualMachines/vm-03",
  # Add more VMs as needed
]
```

## Outputs

The module provides comprehensive outputs for integration:

```hcl
# Activity log alert IDs
output "update_deployment_failed_alert_id" {
  value = module.updatemanager_monitoring.update_deployment_failed_alert_id
}

# Scheduled query rule IDs
output "critical_updates_available_alert_id" {
  value = module.updatemanager_monitoring.critical_updates_available_alert_id
}

# Monitoring configuration summary
output "monitoring_configuration" {
  value = module.updatemanager_monitoring.monitoring_configuration
}
```

## Troubleshooting

### Alert Not Triggering

1. **Verify VMs are enrolled in Update Manager**:
   ```bash
   az vm show --ids <vm-resource-id> --query "id"
   ```

2. **Check Log Analytics workspace connection**:
   ```bash
   az monitor log-analytics workspace show --workspace-name law-pge-monitoring-prod --resource-group rg-pge-monitoring-prod
   ```

3. **Review query results manually**:
   ```bash
   az monitor log-analytics query --workspace <workspace-id> --analytics-query "Update | where TimeGenerated > ago(1d)"
   ```

### Scheduled Query Rule Issues

1. **Verify Log Analytics workspace has Update data**:
   ```kql
   Update
   | where TimeGenerated > ago(7d)
   | summarize count() by Computer
   ```

2. **Check scheduled query rule status**:
   ```bash
   az monitor scheduled-query show --name update-compliance-low-{sub-id} --resource-group rg-pge-updatemanager-prod
   ```

3. **Review evaluation frequency and window**:
   - Ensure evaluation frequency is appropriate for your needs
   - Verify window duration captures relevant data

### Permission Issues

Ensure the deployment identity has these permissions:

- `Microsoft.Insights/activityLogAlerts/write`
- `Microsoft.Insights/scheduledQueryRules/write`
- `Microsoft.Compute/virtualMachines/read`
- `Microsoft.Maintenance/maintenanceConfigurations/read`
- `Microsoft.OperationalInsights/workspaces/read`
- `Microsoft.OperationalInsights/workspaces/query/action`

## Cost Optimization

### Production Environment
- **Estimated Cost**: $3-7/month
- **Components**: 
  - 6 activity log alerts: Free
  - 6 scheduled query rules: ~$0.50/query/month
  - Log Analytics queries: Based on data volume

### Development Environment
- **Estimated Cost**: $2-4/month
- **Optimization**: Fewer alerts, longer evaluation periods
- **Components**:
  - 4 activity log alerts: Free
  - 4 scheduled query rules: ~$0.50/query/month

### Test Environment
- **Estimated Cost**: $1-2/month
- **Optimization**: Minimal alerts, infrequent evaluation
- **Components**:
  - 3 activity log alerts: Free
  - 3 scheduled query rules: ~$0.50/query/month

## Best Practices

1. **Start with Critical Alerts**: Begin with deployment failures and critical updates, then expand
2. **Set Appropriate Thresholds**: Adjust based on your environment's update cadence
3. **Monitor Compliance Trends**: Track compliance over time to identify patterns
4. **Test Maintenance Windows**: Verify maintenance window configuration before production
5. **Regular Review**: Periodically review alert thresholds and enablement
6. **Document Runbooks**: Create response procedures for each alert type
7. **Use Tags Consistently**: Apply consistent tags for cost tracking and governance
8. **Integrate with ITSM**: Connect alerts to your ticketing system for automated workflows

## Additional Resources

- [Azure Update Manager Documentation](https://learn.microsoft.com/azure/update-manager/)
- [Azure Monitor Alerts Overview](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-overview)
- [Update Management Queries](https://learn.microsoft.com/azure/azure-monitor/logs/query-optimization)
- [Log Analytics Query Language](https://learn.microsoft.com/azure/azure-monitor/logs/log-query-overview)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)

## Support

For issues or questions:
1. Review the main module README
2. Check Azure Update Manager documentation
3. Verify VM enrollment in Update Manager
4. Review Log Analytics workspace data
5. Contact your Azure administrator

## License

This module follows the same license as the parent repository.
