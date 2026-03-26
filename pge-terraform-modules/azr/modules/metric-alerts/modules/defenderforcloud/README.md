# Microsoft Defender for Cloud AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Microsoft Defender for Cloud** (formerly Azure Security Center). It provides enterprise-grade security monitoring, policy compliance tracking, and configuration change detection to help organizations maintain robust cloud security posture.

Microsoft Defender for Cloud is Azure's unified security management system that strengthens security posture and provides threat protection. This module monitors critical security configuration changes, policy modifications, and Defender plan status to ensure continuous security compliance and visibility.

## Table of Contents

- [Features](#features)
- [Alert Categories](#alert-categories)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Input Variables](#input-variables)
- [Alert Details](#alert-details)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Features

- **8 Activity Log Alerts** for security configuration monitoring
- **Multi-Subscription Support** with centralized monitoring
- **Defender Plan Monitoring** for all protection types
- **Security Policy Tracking** for compliance enforcement
- **Configuration Change Detection** for security drift
- **Auto-Provisioning Monitoring** for agent deployment
- **Workflow Automation Tracking** for security orchestration
- **Enable/Disable Flags** for flexible alert management
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 🔐 Defender Plan Alerts
- Microsoft Defender Plan Status Changes

### 📋 Security Policy Alerts
- Security Policy Assignment Changes
- Security Policy Assignment Deletions
- Security Assessment Modifications

### ⚙️ Configuration Alerts
- Security Center Settings Changes
- Auto-Provisioning Configuration Changes
- Alert Suppression Rule Changes
- Workflow Automation Changes

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Microsoft Defender for Cloud enabled on subscription(s)
- Azure Monitor Action Group (pre-configured)
- **Subscription-level permissions** (Reader + Security Reader minimum)
- Appropriate permissions to create Activity Log alerts

## Usage

### Basic Example

```hcl
module "defender_alerts" {
  source = "./modules/metricAlerts/defenderforcloud"

  # Resource Configuration
  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"

  # Subscription IDs to Monitor
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Enable All Alerts
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true

  # Tags
  tags = {
    Environment         = "Production"
    AppId              = "123456"
    CRIS               = "1"
    Compliance         = "SOX"
    DataClassification = "internal"
    Env                = "Prod"
    Notify             = "security-team@pge.com"
    Owner              = "security-ops@pge.com"
    order              = "123456"
  }
}
```

### Production Example with All Defender Plans

```hcl
module "defender_alerts_production" {
  source = "./modules/metricAlerts/defenderforcloud"

  # Resource Configuration
  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "security-critical-actiongroup"

  # Production Subscription
  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Enable All Alerts
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true

  # Monitor All Defender Plans
  monitor_defender_for_servers          = true
  monitor_defender_for_app_service      = true
  monitor_defender_for_storage          = true
  monitor_defender_for_sql              = true
  monitor_defender_for_containers       = true
  monitor_defender_for_key_vault        = true
  monitor_defender_for_resource_manager = true
  monitor_defender_for_dns              = true

  tags = {
    Environment     = "Production"
    SecurityTier    = "Critical"
    Compliance      = "SOX,HIPAA,PCI-DSS"
    SecurityContact = "security-team@pge.com"
    IncidentTeam    = "security-ops@pge.com"
  }
}
```

### Multi-Subscription Enterprise Example

```hcl
module "defender_alerts_enterprise" {
  source = "./modules/metricAlerts/defenderforcloud"

  resource_group_name              = "rg-security-monitoring"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "enterprise-security-actiongroup"

  # Monitor Multiple Subscriptions
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012",  # Production
    "87654321-4321-4321-4321-210987654321",  # Staging
    "11111111-2222-3333-4444-555555555555"   # Development
  ]

  # Comprehensive Security Monitoring
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true

  # All Defender Plans
  monitor_defender_for_servers          = true
  monitor_defender_for_app_service      = true
  monitor_defender_for_storage          = true
  monitor_defender_for_sql              = true
  monitor_defender_for_containers       = true
  monitor_defender_for_key_vault        = true
  monitor_defender_for_resource_manager = true
  monitor_defender_for_dns              = true

  tags = {
    Environment     = "Multi-Subscription"
    Scope           = "Enterprise"
    SecurityOps     = "Enabled"
    ComplianceTeam  = "compliance@pge.com"
  }
}
```

### Selective Monitoring Example

```hcl
module "defender_alerts_selective" {
  source = "./modules/metricAlerts/defenderforcloud"

  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "security-actiongroup"

  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Enable only critical alerts
  enable_defender_plan_alerts = true   # Monitor plan changes
  enable_policy_alerts        = false  # Skip policy alerts

  # Monitor only critical Defender plans
  monitor_defender_for_servers          = true   # Critical: VM protection
  monitor_defender_for_sql              = true   # Critical: Database protection
  monitor_defender_for_key_vault        = true   # Critical: Secrets protection
  monitor_defender_for_resource_manager = true   # Critical: Management layer

  # Skip less critical plans
  monitor_defender_for_app_service = false
  monitor_defender_for_storage     = false
  monitor_defender_for_containers  = false
  monitor_defender_for_dns         = false

  tags = {
    Environment   = "Production"
    MonitoringTier = "Critical-Only"
  }
}
```

### Development Environment Example

```hcl
module "defender_alerts_dev" {
  source = "./modules/metricAlerts/defenderforcloud"

  resource_group_name              = "rg-amba"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-security-actiongroup"

  subscription_ids = ["11111111-2222-3333-4444-555555555555"]

  # Basic monitoring for dev
  enable_defender_plan_alerts = true   # Monitor plan status
  enable_policy_alerts        = false  # Skip policy alerts in dev

  # Monitor essential plans only
  monitor_defender_for_servers = true
  monitor_defender_for_sql     = true

  tags = {
    Environment = "Development"
    CostSensitive = "true"
  }
}
```

### Compliance-Focused Example

```hcl
module "defender_alerts_compliance" {
  source = "./modules/metricAlerts/defenderforcloud"

  resource_group_name              = "rg-compliance-monitoring"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "compliance-actiongroup"

  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Enable all security alerts for audit trail
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true

  # Monitor all Defender plans for compliance
  monitor_defender_for_servers          = true
  monitor_defender_for_app_service      = true
  monitor_defender_for_storage          = true
  monitor_defender_for_sql              = true
  monitor_defender_for_containers       = true
  monitor_defender_for_key_vault        = true
  monitor_defender_for_resource_manager = true
  monitor_defender_for_dns              = true

  tags = {
    Compliance      = "SOX,HIPAA,PCI-DSS,ISO27001"
    AuditRequired   = "true"
    RetentionPeriod = "7years"
    ComplianceOfficer = "compliance-officer@pge.com"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `subscription_ids` | `list(string)` | **REQUIRED** - List of subscription IDs to monitor (empty list = no alerts created) |

### Core Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group where alerts will be created |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group name for notifications |
| `location` | `string` | `"West US 3"` | Azure region (used for consistency) |
| `tags` | `map(string)` | See below | Tags applied to all alert resources |

### Default Tags

```hcl
{
  "AppId"              = "123456"
  "Env"                = "Dev"
  "Owner"              = "abc@pge.com"
  "Compliance"         = "SOX"
  "Notify"             = "abc@pge.com"
  "DataClassification" = "internal"
  "CRIS"               = "1"
  "order"              = "123456"
}
```

### Alert Enable/Disable Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_defender_plan_alerts` | `bool` | `true` | Enable Defender plan status monitoring |
| `enable_policy_alerts` | `bool` | `true` | Enable security policy and configuration alerts |

### Defender Plan Monitoring Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `monitor_defender_for_servers` | `bool` | `true` | Monitor Defender for Servers (VMs) |
| `monitor_defender_for_app_service` | `bool` | `true` | Monitor Defender for App Service |
| `monitor_defender_for_storage` | `bool` | `true` | Monitor Defender for Storage |
| `monitor_defender_for_sql` | `bool` | `true` | Monitor Defender for SQL |
| `monitor_defender_for_containers` | `bool` | `true` | Monitor Defender for Containers (AKS) |
| `monitor_defender_for_key_vault` | `bool` | `true` | Monitor Defender for Key Vault |
| `monitor_defender_for_resource_manager` | `bool` | `true` | Monitor Defender for Resource Manager |
| `monitor_defender_for_dns` | `bool` | `true` | Monitor Defender for DNS |

## Alert Details

### Activity Log Alerts

#### 1. Microsoft Defender Plan Status Change
- **Operation**: `Microsoft.Security/pricings/write`
- **Resource Type**: `Microsoft.Security/pricings`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors changes to Microsoft Defender plan status (enabled/disabled). Critical for ensuring continuous protection coverage across all Azure services.

**When This Fires**:
- Defender plan enabled for a service
- Defender plan disabled for a service (security risk!)
- Defender plan tier changed (Standard to Free or vice versa)

**Response Actions**:
1. Verify change was authorized
2. If disabled unexpectedly, re-enable immediately
3. Review who made the change (check activity log)
4. Investigate if part of cost-cutting without security approval
5. Update security documentation

**Common Scenarios**:
```
Scenario 1: Accidental Disable
- User disables Defender for Servers to reduce costs
- Alert fires immediately
- Security team re-enables within minutes

Scenario 2: Planned Change
- Security team disables Defender for DNS (not needed)
- Alert fires as expected
- Team acknowledges and documents decision

Scenario 3: Unauthorized Change
- Malicious actor disables threat protection
- Alert fires immediately
- Incident response team investigates
- RBAC permissions reviewed and tightened
```

#### 2. Security Policy Assignment Changes
- **Operation**: `Microsoft.Authorization/policyAssignments/write`
- **Resource Type**: `Microsoft.Authorization/policyAssignments`
- **Category**: Administrative
- **Level**: Warning
- **Scope**: Subscription
- **Description**: Monitors modifications to security policy assignments. Policy changes can weaken security posture or introduce compliance violations.

**When This Fires**:
- New security policy assigned
- Existing policy modified (parameters, scope)
- Policy enforcement mode changed (enforced to disabled)
- Policy exemptions created

**Response Actions**:
1. Review the policy change details
2. Verify change aligns with security requirements
3. Check if compliance is impacted
4. Update compliance documentation
5. Communicate to stakeholders if major change

**Impact Assessment**:
- **High**: Policy enforcement disabled or exemptions added
- **Medium**: Policy parameters loosened
- **Low**: New policy added or parameters tightened

#### 3. Security Policy Assignment Deletions
- **Operation**: `Microsoft.Authorization/policyAssignments/delete`
- **Resource Type**: `Microsoft.Authorization/policyAssignments`
- **Category**: Administrative
- **Level**: Warning
- **Scope**: Subscription
- **Description**: Monitors deletion of security policy assignments. Policy deletions remove security controls and can create compliance gaps.

**When This Fires**:
- Security policy unassigned from subscription
- Compliance policy removed
- Regulatory requirement policy deleted

**Response Actions**:
1. **IMMEDIATE**: Verify deletion was authorized
2. Identify which policy was deleted
3. Assess security impact
4. Re-assign policy if deletion was unauthorized
5. Review and update RBAC permissions
6. Document in audit log

**Critical Policies to Protect**:
- Network security controls
- Encryption requirements
- Access control policies
- Compliance framework policies (SOX, HIPAA, PCI-DSS)

#### 4. Security Center Settings Changes
- **Operation**: `Microsoft.Security/securityContacts/write`
- **Resource Type**: `Microsoft.Security/securityContacts`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors changes to Security Center contact information and notification preferences.

**When This Fires**:
- Security contact email updated
- Phone number changed
- Alert notification preferences modified
- Notification recipients added/removed

**Response Actions**:
1. Verify new contact information is valid
2. Test alert delivery to new contacts
3. Update security documentation
4. Ensure 24/7 monitoring coverage

**Best Practices**:
- Use distribution lists, not individual emails
- Maintain multiple contacts for redundancy
- Include Security Operations Center (SOC) contacts
- Enable alerts for high-severity findings

#### 5. Auto-Provisioning Configuration Changes
- **Operation**: `Microsoft.Security/autoProvisioningSettings/write`
- **Resource Type**: `Microsoft.Security/autoProvisioningSettings`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors changes to auto-provisioning settings for security agents (Log Analytics agent, vulnerability assessment, etc.).

**When This Fires**:
- Auto-provisioning enabled or disabled
- Workspace configuration changed
- Extension settings modified

**Response Actions**:
1. Verify change aligns with security strategy
2. If disabled, understand impact on coverage
3. Ensure alternative monitoring exists
4. Update agent deployment documentation

**Impact of Disabling**:
- New VMs won't get security agents automatically
- Reduced visibility into VM security posture
- Manual agent installation required
- Potential gaps in threat detection

#### 6. Security Assessment Changes
- **Operation**: `Microsoft.Security/assessments/write`
- **Resource Type**: `Microsoft.Security/assessments`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors modifications to security assessments and recommendations.

**When This Fires**:
- Assessment status manually changed
- Recommendation dismissed
- Assessment exemption created
- Custom assessment added

**Response Actions**:
1. Review assessment change justification
2. Verify exemptions are documented
3. Ensure compensating controls exist
4. Track in compliance reporting

**Common Changes**:
- Dismissing false positive recommendations
- Creating exemptions for exceptions
- Resolving security findings
- Adding custom assessments

#### 7. Security Alert Suppression Rule Changes
- **Operation**: `Microsoft.Security/alertsSuppressionRules/write`
- **Resource Type**: `Microsoft.Security/alertsSuppressionRules`
- **Category**: Administrative
- **Level**: Warning
- **Scope**: Subscription
- **Description**: Monitors changes to alert suppression rules. Excessive suppression can mask real threats.

**When This Fires**:
- New suppression rule created
- Existing rule modified
- Suppression scope expanded

**Response Actions**:
1. **CRITICAL**: Review suppression justification
2. Ensure rule is specific, not overly broad
3. Set expiration date for temporary suppressions
4. Document business reason
5. Review quarterly and remove outdated rules

**Warning Signs**:
- Too many suppression rules (>10)
- Broad suppression scopes
- No expiration dates
- Lack of justification documentation

**Best Practices**:
```
Good Suppression:
- Specific resource ID
- Defined time period
- Clear justification
- Compensating control documented

Bad Suppression:
- Entire subscription scope
- Permanent (no expiration)
- Vague reason ("too many alerts")
- No alternative monitoring
```

#### 8. Workflow Automation Changes
- **Operation**: `Microsoft.Security/automations/write`
- **Resource Type**: `Microsoft.Security/automations`
- **Category**: Administrative
- **Level**: Informational
- **Scope**: Subscription
- **Description**: Monitors changes to workflow automation (Logic Apps, Event Grid integrations) for security orchestration.

**When This Fires**:
- New automation created
- Automation modified or disabled
- Trigger conditions changed
- Action configuration updated

**Response Actions**:
1. Verify automation aligns with security workflows
2. Test automation functionality
3. Update runbook documentation
4. Ensure automation reliability

**Common Automations**:
- Auto-remediation of specific findings
- Ticket creation in ServiceNow/Jira
- Email notifications to security team
- Integration with SIEM systems

## Best Practices

### 1. Subscription ID Configuration

```hcl
# Always provide subscription IDs to monitor
subscription_ids = [
  "12345678-1234-1234-1234-123456789012"
]

# Empty list = no alerts created
subscription_ids = []  # Avoid in production
```

### 2. Defender Plan Strategy

#### Production Environment
```hcl
# Enable all Defender plans for maximum protection
enable_defender_plan_alerts = true

monitor_defender_for_servers          = true  # VM protection
monitor_defender_for_app_service      = true  # Web app protection
monitor_defender_for_storage          = true  # Data protection
monitor_defender_for_sql              = true  # Database protection
monitor_defender_for_containers       = true  # Container protection
monitor_defender_for_key_vault        = true  # Secrets protection
monitor_defender_for_resource_manager = true  # Control plane protection
monitor_defender_for_dns              = true  # DNS layer protection
```

#### Cost-Optimized Environment
```hcl
# Enable only essential Defender plans
monitor_defender_for_servers          = true  # Always enable
monitor_defender_for_sql              = true  # Critical data
monitor_defender_for_key_vault        = true  # Secrets are critical
monitor_defender_for_resource_manager = true  # Control plane is critical

# Optional based on usage
monitor_defender_for_app_service = false  # If not using App Service
monitor_defender_for_storage     = false  # If no sensitive data in Storage
monitor_defender_for_containers  = false  # If not using AKS
monitor_defender_for_dns         = false  # Lower priority
```

### 3. Policy Alert Configuration

```hcl
# Production: Enable all policy alerts
enable_policy_alerts = true

# Development: Optional
enable_policy_alerts = false  # If frequent policy testing
```

### 4. Multi-Subscription Security Governance

```hcl
# Centralized security monitoring across subscriptions
module "defender_production" {
  subscription_ids = ["prod-sub-id"]
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true
}

module "defender_nonprod" {
  subscription_ids = ["dev-sub-id", "test-sub-id"]
  enable_defender_plan_alerts = true
  enable_policy_alerts        = false  # Less strict in non-prod
}
```

### 5. Integration with Security Operations

```hcl
# Direct alerts to security team action group
action_group = "security-ops-actiongroup"

# Ensure action group includes:
# - Email to SOC team
# - SMS for critical alerts
# - Webhook to SIEM system
# - Integration with ticketing system
```

### 6. Compliance Monitoring

```hcl
# Tag alerts for compliance tracking
tags = {
  Compliance        = "SOX,HIPAA,PCI-DSS,ISO27001"
  AuditRequired     = "true"
  SecurityControl   = "DefenderForCloud"
  ComplianceOfficer = "compliance@pge.com"
}

# Enable all policy alerts for audit trail
enable_policy_alerts = true
```

### 7. Alert Response Procedures

**Defender Plan Disabled Alert**:
1. Immediate escalation to security team
2. Re-enable plan immediately
3. Investigate who disabled and why
4. Review RBAC permissions
5. Document in incident log

**Policy Deletion Alert**:
1. Identify deleted policy
2. Assess security impact
3. Re-assign if unauthorized
4. Review change approval process
5. Update compliance documentation

**Alert Suppression Alert**:
1. Review suppression justification
2. Verify compensating controls
3. Set expiration date
4. Quarterly review of all suppressions

### 8. Regular Security Reviews

```bash
# Monthly: Review Defender plan status
az security pricing list --output table

# Monthly: Review active security policies
az policy assignment list --query "[].{Name:name, Policy:policyDefinitionId}"

# Quarterly: Review alert suppression rules
az security alert-suppression-rule list --output table

# Quarterly: Review workflow automations
az security automation list --output table
```

### 9. Cost vs Security Trade-offs

**Defender Plan Costs (Approximate)**:
- Servers: ~$15/server/month
- App Service: ~$15/instance/month
- Storage: ~$0.02/10K transactions
- SQL: ~$15/server/month
- Containers: ~$7/vCore/month
- Key Vault: ~$0.02/10K transactions
- Resource Manager: ~$3/subscription/month
- DNS: ~$0.40/million queries

**Recommendations**:
- Always enable: Servers, SQL, Key Vault, Resource Manager
- Enable if applicable: App Service, Containers, Storage
- Optional: DNS (lower priority)

### 10. Integration with Azure Policy

```hcl
# Ensure Defender plans remain enabled via Azure Policy
# Example policy: Require Defender for Servers to be enabled

# This module alerts on changes
# Azure Policy enforces the requirement
# Combined approach = Defense in depth
```

## Troubleshooting

### Common Issues

#### 1. No Alerts Being Created

**Problem**: No activity log alerts appearing in Azure Monitor.

**Solution**:
```hcl
# Ensure subscription_ids is not empty
subscription_ids = ["12345678-1234-1234-1234-123456789012"]  # REQUIRED

# Verify resource group exists
resource_group_name = "rg-amba"

# Check action group exists
action_group_resource_group_name = "rg-monitoring"
action_group                     = "existing-action-group"
```

**Validation**:
```bash
# Verify subscription access
az account show --subscription "12345678-1234-1234-1234-123456789012"

# Check if Defender is enabled
az security pricing list --subscription "12345678-1234-1234-1234-123456789012"
```

#### 2. Defender Plan Alerts Not Firing

**Problem**: Plan status changes but no alert received.

**Solution**:
```hcl
# Verify flag is enabled
enable_defender_plan_alerts = true

# Ensure subscription_ids is provided
subscription_ids = ["12345678-1234-1234-1234-123456789012"]

# Check alert exists in Azure
```

**Diagnostics**:
```bash
# List activity log alerts
az monitor activity-log alert list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'DefenderPlan')]"

# Check activity log for plan changes
az monitor activity-log list \
  --start-time 2025-11-01 \
  --end-time 2025-11-24 \
  --query "[?contains(operationName.value, 'Microsoft.Security/pricings')]"
```

#### 3. Policy Alerts Too Noisy

**Problem**: Receiving too many policy change alerts.

**Solution**:
```hcl
# Disable policy alerts if too frequent
enable_policy_alerts = false

# Or filter alerts by severity in action group
# Configure action group to only alert on Warning level or above
```

#### 4. Activity Log Alerts Delayed

**Problem**: Alerts appear several minutes after change.

**Understanding**:
- Activity log alerts have 1-5 minute latency (by design)
- Not real-time, but near real-time
- Acceptable for administrative change monitoring

**Solution**:
- This is normal behavior
- For immediate notifications, consider Azure Policy compliance states
- Or use Event Grid for faster notifications

#### 5. Missing Defender Plan Monitoring

**Problem**: Want to monitor specific plan but not seeing alerts.

**Solution**:
```hcl
# The alert monitors ALL plan changes
# Individual plan flags are for documentation only
# To filter, use alert logic or action group filtering

# Current implementation monitors all plans together
enable_defender_plan_alerts = true

# All plan status changes will trigger the same alert
```

#### 6. Multi-Subscription Alert Confusion

**Problem**: Alert fires but unclear which subscription.

**Solution**:
```bash
# Check alert details in activity log
az monitor activity-log list \
  --correlation-id "{correlation-id-from-alert}" \
  --query "[].{Subscription:subscriptionId, Resource:resourceId}"

# Alert name includes subscription ID(s)
# Review alert name: SecurityCenter-DefenderPlan-StatusChange-{sub-id}
```

#### 7. Permissions Issues

**Problem**: Alerts not created due to permissions.

**Required Permissions**:
- **Monitoring Contributor** on resource group (for alert creation)
- **Reader** on subscriptions (for monitoring)
- **Security Reader** on subscriptions (recommended)

**Solution**:
```bash
# Verify permissions
az role assignment list \
  --assignee "{your-user-or-sp}" \
  --scope "/subscriptions/12345678-1234-1234-1234-123456789012"

# Assign missing roles
az role assignment create \
  --role "Security Reader" \
  --assignee "{your-user-or-sp}" \
  --scope "/subscriptions/12345678-1234-1234-1234-123456789012"
```

### Validation Commands

```bash
# Verify Terraform configuration
terraform init
terraform validate
terraform plan

# List subscriptions
az account list --query "[].{Name:name, ID:id}" --output table

# Check Defender for Cloud status
az security pricing list --output table

# List security policies
az policy assignment list \
  --query "[?contains(displayName, 'Security')].{Name:displayName, Policy:policyDefinitionId}"

# List activity log alerts
az monitor activity-log alert list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'SecurityCenter')].{Name:name, Enabled:enabled}"

# Check security contacts
az security contact list --output table

# List alert suppression rules
az security alert-suppression-rule list --output table

# List workflow automations
az security automation list --output table

# Test action group
az monitor action-group test-notifications create \
  --action-group "pge-operations-actiongroup" \
  --resource-group "rg-monitoring" \
  --notification-type "Email"

# View activity log for Defender changes
az monitor activity-log list \
  --start-time "2025-11-01" \
  --query "[?contains(operationName.value, 'Microsoft.Security')]" \
  --output table
```

### Debug Mode

```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform apply

# Check Terraform state
terraform state list | grep defender
terraform state show 'module.defender_alerts.azurerm_monitor_activity_log_alert.defender_plan_status_change[0]'

# View specific alert configuration
az monitor activity-log alert show \
  --name "SecurityCenter-DefenderPlan-StatusChange-{sub-id}" \
  --resource-group "rg-amba"
```

## Alert Severity Mapping

| Severity | Level | Use Case | Response Time | Action Required |
|----------|-------|----------|---------------|-----------------|
| Warning | High | Policy deletions, suppression rules | < 1 hour | Investigate and reverse if unauthorized |
| Informational | Medium | Configuration changes, plan status | < 4 hours | Review and document |

**This Module's Alert Distribution**:
- **Warning Level**: Policy deletions, policy changes, alert suppression changes
- **Informational Level**: Defender plan changes, settings changes, auto-provisioning, assessments, workflow automation

## Performance Considerations

### Alert Evaluation
- **Activity Log Alerts**: Near real-time (1-5 minute latency)
- **Evaluation Frequency**: Event-driven (fires on operation occurrence)
- **No Query Overhead**: Activity log alerts are free and lightweight

### Resource Impact
- **Minimal**: Activity log alerts have no performance impact
- **Event-driven**: Only fire when actual changes occur
- **Subscription-level**: No resource-level monitoring overhead

## Cost Optimization

### Alert Pricing (2025)

- **Activity Log Alerts**: **FREE** (no charge)
- **Email Notifications**: **FREE** (unlimited)
- **Action Group**: **FREE** (first 1,000 actions/month)
- **Total Module Cost**: **$0/month** ✅

**Key Benefit**: This module provides enterprise-grade security monitoring at **zero cost**.

### Defender for Cloud Costs (Separate)

While alerts are free, Defender for Cloud plans have costs:

| Plan | Approximate Cost |
|------|------------------|
| Defender for Servers | ~$15/server/month |
| Defender for App Service | ~$15/instance/month |
| Defender for SQL | ~$15/server/month |
| Defender for Storage | ~$0.02/10K transactions |
| Defender for Containers | ~$7/vCore/month |
| Defender for Key Vault | ~$0.02/10K transactions |
| Defender for Resource Manager | ~$3/subscription/month |
| Defender for DNS | ~$0.40/million queries |

**This module doesn't incur Defender costs** - it only monitors configuration changes.

## Security Compliance Integration

### Regulatory Frameworks

**SOX Compliance**:
- Monitor security policy changes (audit trail)
- Track access control modifications
- Document security configuration changes

**HIPAA Compliance**:
- Ensure continuous protection (Defender plans)
- Monitor encryption settings
- Track data protection policies

**PCI-DSS Compliance**:
- Monitor network security policies
- Track security assessment changes
- Ensure continuous monitoring

**ISO 27001 Compliance**:
- Document security control changes
- Track policy enforcement
- Maintain audit logs

### Audit Trail

```hcl
# All alerts provide audit trail for:
# - Who made the change (via activity log)
# - When the change occurred
# - What was changed
# - Previous and new values

# Retain activity logs for compliance periods
# - SOX: 7 years
# - HIPAA: 6 years
# - PCI-DSS: 1 year minimum
```

## Integration Scenarios

### 1. SIEM Integration

```hcl
# Configure action group with webhook to SIEM
# Alerts flow to: Splunk, Sentinel, QRadar, etc.

# All security configuration changes centralized
# Correlated with other security events
```

### 2. ServiceNow Integration

```hcl
# Workflow automation to create ServiceNow tickets
# Security changes automatically tracked
# Change management integration
```

### 3. Microsoft Sentinel Integration

```hcl
# Native integration with Azure Sentinel
# Security alerts enriched with threat intelligence
# Automated investigation and response
```

### 4. Slack/Teams Notifications

```hcl
# Action group with Logic App
# Real-time notifications to security team channel
# Faster incident response
```

## Additional Resources

- [Microsoft Defender for Cloud Documentation](https://learn.microsoft.com/azure/defender-for-cloud/)
- [Defender for Cloud Pricing](https://azure.microsoft.com/pricing/details/defender-for-cloud/)
- [Security Policies in Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/security-policy-concept)
- [Workflow Automation](https://learn.microsoft.com/azure/defender-for-cloud/workflow-automation)
- [Alert Suppression Rules](https://learn.microsoft.com/azure/defender-for-cloud/alerts-suppression-rules)
- [Azure Security Benchmark](https://learn.microsoft.com/security/benchmark/azure/)
- [Zero Trust Security Model](https://learn.microsoft.com/security/zero-trust/)

## License

This module follows your organization's licensing terms.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-11-24 | Initial release with 8 activity log alerts |

---

**Last Updated**: November 24, 2025  
**Module Version**: 1.0.0  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
