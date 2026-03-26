# Microsoft Defender for Cloud Alerts Module - Examples

This directory contains examples demonstrating how to use the Microsoft Defender for Cloud (formerly Azure Security Center) alerts module.

## Examples

### 1. Production Environment
Demonstrates a comprehensive production security monitoring setup with:
- All Defender plan monitoring enabled
- All policy and security alerts enabled
- Multiple production subscriptions monitored
- Monitoring for all 8 Defender plans:
  - Servers
  - App Service
  - Storage
  - SQL
  - Containers
  - Key Vault
  - Resource Manager
  - DNS
- Comprehensive activity log alerts for security configuration changes

### 2. Development Environment
Shows a development configuration with:
- Essential Defender plan monitoring
- Policy alerts enabled
- Single subscription monitoring
- Selective Defender plan monitoring (6 out of 8 plans)
- Key Vault and DNS monitoring disabled for dev flexibility

### 3. Basic Configuration
Minimal setup using:
- Only Defender plan status monitoring
- Policy alerts disabled
- Critical Defender plans only (Servers, Storage, Resource Manager)
- Suitable for testing or non-critical environments

## Usage

```hcl
module "defender_alerts" {
  source = "path/to/modules/metricAlerts/defenderforcloud"

  resource_group_name                = "rg-security-monitoring-prod"
  action_group_resource_group_name   = "rg-security-monitoring-prod"
  action_group                       = "pge-security-actiongroup"
  location                           = "West US 2"

  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Enable alert categories
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true

  # Monitor specific Defender plans
  monitor_defender_for_servers          = true
  monitor_defender_for_app_service      = true
  monitor_defender_for_storage          = true
  monitor_defender_for_sql              = true
  monitor_defender_for_containers       = true
  monitor_defender_for_key_vault        = true
  monitor_defender_for_resource_manager = true
  monitor_defender_for_dns              = true

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
}
```

## Outputs

All examples demonstrate how to access module outputs:

- `alert_ids` - Map of all alert resource IDs
- `alert_names` - Map of all alert names
- `monitored_subscriptions` - List of monitored subscription IDs
- `action_group_id` - Action group resource ID
- `enabled_features` - Summary of enabled security monitoring features

## Alert Types

The module creates the following activity log alerts for Microsoft Defender for Cloud:

### 1. Defender Plan Status Change Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Security/pricings/write
   - Tracks changes to Microsoft Defender plan status (enabled/disabled)
   - Scope: Subscription-level
   - Level: Informational

### 2. Security Policy Changes Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Authorization/policyAssignments/write
   - Tracks modifications to security policy assignments
   - Scope: Subscription-level
   - Level: Warning

### 3. Security Policy Deletions Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Authorization/policyAssignments/delete
   - Tracks deletions of security policy assignments
   - Scope: Subscription-level
   - Level: Warning

### 4. Security Center Settings Changes Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Security/settings/write
   - Tracks changes to Security Center configuration settings
   - Scope: Subscription-level
   - Level: Informational

### 5. Security Center Auto-Provisioning Changes Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Security/autoProvisioningSettings/write
   - Tracks changes to auto-provisioning settings
   - Scope: Subscription-level
   - Level: Warning

### 6. Security Assessment Changes Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Security/assessments/write
   - Tracks changes to security assessments and recommendations
   - Scope: Subscription-level
   - Level: Informational

### 7. Security Alert Rule Changes Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Security/alertsSuppressionRules/write
   - Tracks changes to alert suppression rules
   - Scope: Subscription-level
   - Level: Warning

### 8. Workflow Automation Changes Alert
   - Type: `azurerm_monitor_activity_log_alert`
   - Monitors: Microsoft.Security/automations/write
   - Tracks changes to security workflow automations
   - Scope: Subscription-level
   - Level: Informational

## Feature Flags

Control which alert categories are enabled:

```hcl
enable_defender_plan_alerts = true   # Defender plan status monitoring
enable_policy_alerts        = true   # Security policy change monitoring
```

## Defender Plan Monitoring Flags

Selectively monitor specific Microsoft Defender plans:

```hcl
monitor_defender_for_servers          = true  # Virtual Machines, Scale Sets
monitor_defender_for_app_service      = true  # App Services, Function Apps
monitor_defender_for_storage          = true  # Storage Accounts, Blobs
monitor_defender_for_sql              = true  # SQL Databases, SQL Servers
monitor_defender_for_containers       = true  # AKS, Container Registries
monitor_defender_for_key_vault        = true  # Key Vaults
monitor_defender_for_resource_manager = true  # Azure Resource Manager operations
monitor_defender_for_dns              = true  # DNS queries
```

## Multi-Subscription Monitoring

Monitor security configuration changes across multiple subscriptions:

```hcl
subscription_ids = [
  "12345678-1234-1234-1234-123456789012",
  "87654321-4321-4321-4321-210987654321",
  "11111111-2222-3333-4444-555555555555"
]
```

All alerts are created at the subscription scope level.

## Prerequisites

- Azure subscriptions with Microsoft Defender for Cloud enabled
- Security Reader or Security Admin permissions on subscriptions
- Existing action group for alert notifications
- Resource group for creating activity log alerts

## Notes

- All alerts are activity log-based (no metric or scheduled query alerts)
- Alerts monitor configuration changes, not security threats/findings
- This module does NOT support diagnostic settings (Activity logs are handled by Azure automatically)
- All alerts have global location (activity logs are subscription-scoped)
- Tags are applied to all alert resources
- Alert creation is conditional based on `subscription_ids` list
- Empty `subscription_ids` list disables all alert creation
- Alerts track administrative changes to Defender for Cloud configuration
- For actual security threat alerts, configure Microsoft Defender for Cloud's built-in alerting
- Module follows Azure Monitor Baseline Alerts (AMBA) best practices

## Security Best Practices

1. **Enable All Defender Plans**: In production, enable monitoring for all Defender plans
2. **Policy Alerts**: Always enable policy alerts to track compliance configuration changes
3. **Multi-Subscription**: Monitor all production subscriptions for comprehensive visibility
4. **Action Groups**: Use dedicated security action groups with appropriate notification channels
5. **Regular Review**: Review alert configurations regularly to ensure coverage
6. **Compliance**: These alerts help maintain compliance by tracking security configuration changes
