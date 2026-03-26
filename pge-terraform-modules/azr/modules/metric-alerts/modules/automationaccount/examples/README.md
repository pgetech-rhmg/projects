# Automation Account Module Examples

This directory contains usage examples for the Azure Automation Account monitoring module. These examples demonstrate different deployment scenarios and configurations.

## Prerequisites

- Terraform >= 1.0
- Azure subscription with appropriate permissions
- Existing Azure Automation Account(s)
- Existing Azure Monitor Action Group
- (Optional) Log Analytics Workspace for diagnostic settings
- (Optional) Event Hub Namespace for diagnostic settings

## Examples Overview

### Example 1: Production with Full Monitoring

This example demonstrates a production-ready configuration with:
- Multiple Automation Accounts being monitored
- All alert categories enabled
- Diagnostic settings enabled with both Log Analytics and Event Hub
- Activity log alerts for operational monitoring

**Key Features:**
- Automation Account creation/deletion monitoring
- Runbook operations tracking
- Hybrid Worker operations monitoring
- Update deployment monitoring
- Webhook operations tracking
- Certificate expiration alerts
- Dual-destination diagnostic logging

### Example 2: Development with Selective Monitoring

This example shows a development environment configuration with:
- Single Automation Account
- Only critical alerts enabled (creation/deletion)
- Log Analytics only (no Event Hub)
- Reduced alert noise for development work

**Key Features:**
- Essential operational alerts only
- Cost-optimized diagnostic settings
- Suitable for development/testing environments

### Example 3: Basic Monitoring

This example demonstrates minimal monitoring configuration:
- Core alerts only (creation, deletion, runbook operations)
- No diagnostic settings
- Suitable for test environments

**Key Features:**
- Quick setup with minimal configuration
- Default settings
- No additional diagnostic costs

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

### Alert Categories

You can enable or disable specific alert categories:

```hcl
enable_automation_account_creation_alert = true  # Account creation monitoring
enable_automation_account_deletion_alert = true  # Account deletion monitoring
enable_runbook_operations_alert          = true  # Runbook operations
enable_hybrid_worker_alert               = true  # Hybrid Worker operations
enable_update_deployment_alert           = true  # Update deployments
enable_webhook_alert                     = true  # Webhook operations
enable_certificate_expiration_alert      = true  # Certificate expiration
```

### Resource Configuration

Configure which Automation Accounts to monitor:

```hcl
# List of Automation Account names
automation_account_names = [
  "automation-prod-001",
  "automation-prod-002"
]

# Subscription IDs for activity log alerts
subscription_ids = [
  "12345678-1234-1234-1234-123456789012"
]

# Full resource IDs for scheduled query rules
automation_account_resource_ids = [
  "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-automation/providers/Microsoft.Automation/automationAccounts/automation-prod-001"
]
```

### Diagnostic Settings Options

**Both Log Analytics and Event Hub:**
```hcl
enable_diagnostic_settings        = true
log_analytics_workspace_name      = "law-monitoring"
log_analytics_resource_group_name = "rg-monitoring"
eventhub_namespace_name           = "evhns-siem"
eventhub_name                     = "evh-automation-logs"
eventhub_authorization_rule_name  = "RootManageSharedAccessKey"
eventhub_resource_group_name      = "rg-siem"
```

**Log Analytics Only:**
```hcl
enable_diagnostic_settings        = true
log_analytics_workspace_name      = "law-monitoring"
log_analytics_resource_group_name = "rg-monitoring"
eventhub_namespace_name           = ""
eventhub_name                     = ""
```

**No Diagnostic Settings:**
```hcl
enable_diagnostic_settings = false
```

## Outputs

The examples provide the following outputs:

- **alert_ids**: Map of all created activity log alert resource IDs
- **alert_names**: Map of all created activity log alert names
- **diagnostic_setting_ids**: Map of diagnostic setting resource IDs (when enabled)
- **monitored_automation_accounts**: List of Automation Account names being monitored
- **monitored_subscriptions**: List of subscription IDs being monitored
- **action_group_id**: ID of the Action Group receiving alerts

## Alert Types

The module can create the following activity log alerts for Automation Accounts:

### Operational Alerts
1. **Automation Account Creation** - Monitors account creation operations
2. **Automation Account Deletion** - Monitors account deletion operations
3. **Runbook Operations** - Tracks runbook create/update/delete operations
4. **Hybrid Worker Operations** - Monitors hybrid worker group operations
5. **Update Deployment Operations** - Tracks update deployment activities
6. **Webhook Operations** - Monitors webhook create/update/delete operations
7. **Certificate Expiration** - Alerts on certificate expiration events

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

## Cleanup

To remove all created resources:

```bash
terraform destroy
```

## Additional Resources

- [Azure Automation Account Documentation](https://learn.microsoft.com/azure/automation/overview)
- [Azure Monitor Activity Log Alerts](https://learn.microsoft.com/azure/azure-monitor/alerts/activity-log-alerts)
- [Azure Monitor Action Groups](https://learn.microsoft.com/azure/azure-monitor/alerts/action-groups)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
