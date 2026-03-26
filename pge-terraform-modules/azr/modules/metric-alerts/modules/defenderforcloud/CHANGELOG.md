# Changelog

All notable changes to the Microsoft Defender for Cloud Alerts module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-30

### Added
- Initial release of Microsoft Defender for Cloud (Azure Security Center) activity log alerts module
- Defender plan status monitoring:
  - Plan status change alerts (enabled/disabled)
  - Support for all 8 Defender plans:
    - Microsoft Defender for Servers
    - Microsoft Defender for App Service
    - Microsoft Defender for Storage
    - Microsoft Defender for SQL
    - Microsoft Defender for Containers
    - Microsoft Defender for Key Vault
    - Microsoft Defender for Resource Manager
    - Microsoft Defender for DNS
- Security policy monitoring:
  - Policy assignment changes
  - Policy assignment deletions
  - Tracks compliance configuration modifications
- Security Center configuration monitoring:
  - Settings changes
  - Auto-provisioning settings changes
  - Tracks Security Center configuration modifications
- Security assessment monitoring:
  - Assessment changes
  - Security recommendation modifications
- Alert configuration monitoring:
  - Alert suppression rule changes
  - Tracks alert configuration modifications
- Workflow automation monitoring:
  - Automation rule changes
  - Tracks security workflow modifications
- Feature flags for enabling/disabling alert categories:
  - Defender plan alerts
  - Security policy alerts
- Individual Defender plan monitoring flags:
  - Selective monitoring of specific Defender plans
  - Granular control over which plans to track
- Comprehensive examples:
  - Production environment with all features enabled
  - Development environment with selective monitoring
  - Basic configuration with minimal alerts
- Module outputs:
  - Alert IDs and names
  - Monitored subscriptions list
  - Action group ID
  - Enabled features summary
- Variable validation for:
  - Resource group names
  - Action group configuration
  - Subscription IDs list
- Support for multi-subscription monitoring
- Activity log-based alerts (subscription scope)
- Tags support for all alert resources

### Configuration
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

### Alert Types (8 Activity Log Alerts)
1. **Defender Plan Status Change** - Tracks Microsoft.Security/pricings/write
2. **Security Policy Changes** - Tracks Microsoft.Authorization/policyAssignments/write
3. **Security Policy Deletions** - Tracks Microsoft.Authorization/policyAssignments/delete
4. **Security Center Settings Changes** - Tracks Microsoft.Security/settings/write
5. **Auto-Provisioning Changes** - Tracks Microsoft.Security/autoProvisioningSettings/write
6. **Security Assessment Changes** - Tracks Microsoft.Security/assessments/write
7. **Alert Rule Changes** - Tracks Microsoft.Security/alertsSuppressionRules/write
8. **Workflow Automation Changes** - Tracks Microsoft.Security/automations/write

### Notes
- All alerts are activity log-based (no metric or scheduled query alerts)
- Alerts monitor configuration changes, not security threats
- This module does NOT support diagnostic settings (Activity logs are handled automatically)
- All alerts have global location (activity logs are subscription-scoped)
- Alert creation is conditional based on subscription_ids list
- Empty subscription_ids disables all alert creation
- Alerts track administrative changes to Defender for Cloud configuration
- For security threat alerts, use Microsoft Defender for Cloud's built-in alerting
- Module follows Azure Monitor Baseline Alerts (AMBA) best practices
- Supports selective monitoring of specific Defender plans
- All alerts use subscription-level scope
- Tags applied to all alert resources
