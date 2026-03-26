# Azure Compute Gallery AMBA Alerts Module

## Overview

This Terraform module implements comprehensive Azure Monitor Baseline Alerts (AMBA) for **Azure Compute Gallery** (formerly Shared Image Gallery). It provides production-ready monitoring across image management, replication, sharing, and administrative operations.

Azure Compute Gallery enables you to build, manage, and share custom VM images and application packages across your organization. This module monitors critical operations to ensure reliable image distribution and compliance.

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

- **6 Activity Log Alerts** for administrative operations
- **4 Scheduled Query Rules** for operational monitoring
- **Customizable Thresholds** for all alerts
- **Enable/Disable Flags** for flexible alert management
- **Image Replication Monitoring** to detect failures
- **Image Version Tracking** for change management
- **Security Monitoring** for access control changes
- **High Volume Detection** for unusual activity patterns
- **AMBA-Compliant** alert naming and severity

## Alert Categories

### 🔴 Image Management Alerts
- Image Definition Operations
- Image Version Operations
- High Volume Image Creation

### 🟠 Operational Health Alerts
- Replication Failure Monitoring
- Failed Gallery Operations

### 🟡 Administrative Alerts
- Compute Gallery Creation
- Compute Gallery Deletion
- Sharing Profile Changes

### 🔵 Security Alerts
- Access Control Changes
- Gallery Security Events

## Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure Compute Gallery (Shared Image Gallery)
- Azure Monitor Action Group (pre-configured)
- **Subscription-level permissions** (required for activity log alerts)
- Appropriate permissions to create Monitor alerts

## Usage

### Basic Example

```hcl
module "compute_gallery_alerts" {
  source = "./modules/metricAlerts/computegallery"

  # Resource Configuration
  resource_group_name              = "rg-images-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Subscription IDs to Monitor (REQUIRED)
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Tags
  tags = {
    Environment         = "Production"
    AppId              = "123456"
    CRIS               = "1"
    Compliance         = "SOX"
    DataClassification = "internal"
    Env                = "Prod"
    Notify             = "ops-team@pge.com"
    Owner              = "platform-team@pge.com"
    order              = "123456"
  }
}
```

### Production Example with Custom Thresholds

```hcl
module "compute_gallery_alerts_production" {
  source = "./modules/metricAlerts/computegallery"

  # Resource Configuration
  resource_group_name              = "rg-images-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "critical-alerts-actiongroup"
  location                         = "West US 3"

  # Subscription IDs
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]

  # Custom Thresholds
  replication_failure_threshold       = 1   # Alert on any replication failure
  image_version_creation_threshold    = 5   # Alert if > 5 versions/hour
  image_definition_threshold          = 3   # Alert if > 3 definitions created
  gallery_access_threshold            = 1   # Alert on any access change

  # Evaluation Settings
  evaluation_frequency_critical = "PT5M"   # Check every 5 minutes
  evaluation_frequency_standard = "PT15M"  # Check every 15 minutes
  window_duration_critical      = "PT15M"  # 15-minute window
  window_duration_standard      = "PT1H"   # 1-hour window

  # Enable All Alerts
  enable_gallery_creation_alert      = true
  enable_gallery_deletion_alert      = true
  enable_gallery_modification_alert  = true
  enable_image_definition_alert      = true
  enable_image_version_alert         = true
  enable_replication_failure_alert   = true
  enable_sharing_profile_alert       = true
  enable_access_control_alert        = true

  tags = {
    Environment     = "Production"
    CriticalityTier = "Tier1"
  }
}
```

### Selective Alert Monitoring Example

```hcl
module "compute_gallery_alerts_selective" {
  source = "./modules/metricAlerts/computegallery"

  resource_group_name              = "rg-images-dev"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Enable only critical alerts for development
  enable_gallery_creation_alert     = false
  enable_gallery_deletion_alert     = true   # Critical: prevent accidental deletion
  enable_gallery_modification_alert = false
  enable_image_definition_alert     = false
  enable_image_version_alert        = true   # Monitor image versioning
  enable_replication_failure_alert  = true   # Critical: detect failures
  enable_sharing_profile_alert      = false
  enable_access_control_alert       = true   # Security monitoring

  # More lenient thresholds for dev
  replication_failure_threshold    = 3   # More tolerant
  image_version_creation_threshold = 20  # Higher volume allowed

  tags = {
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

### Multi-Subscription Monitoring Example

```hcl
module "compute_gallery_alerts_multi_sub" {
  source = "./modules/metricAlerts/computegallery"

  resource_group_name              = "rg-monitoring"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Monitor galleries across multiple subscriptions
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012",  # Production
    "87654321-4321-4321-4321-210987654321",  # Staging
    "11111111-2222-3333-4444-555555555555"   # Development
  ]

  tags = {
    Environment = "Multi-Subscription"
    Scope       = "Enterprise"
  }
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `subscription_ids` | `list(string)` | **REQUIRED** - List of subscription IDs to monitor (alerts not created if empty) |

### Core Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for alert resources |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group name for alert notifications |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
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
| `enable_gallery_creation_alert` | `bool` | `true` | Enable gallery creation monitoring |
| `enable_gallery_deletion_alert` | `bool` | `true` | Enable gallery deletion monitoring |
| `enable_gallery_modification_alert` | `bool` | `true` | Enable gallery modification monitoring |
| `enable_image_definition_alert` | `bool` | `true` | Enable image definition monitoring |
| `enable_image_version_alert` | `bool` | `true` | Enable image version monitoring |
| `enable_replication_failure_alert` | `bool` | `true` | Enable replication failure monitoring |
| `enable_sharing_profile_alert` | `bool` | `true` | Enable sharing profile monitoring |
| `enable_access_control_alert` | `bool` | `true` | Enable access control monitoring |

### Threshold Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `replication_failure_threshold` | `number` | `1` | Number of replication failures to trigger alert |
| `image_version_creation_threshold` | `number` | `10` | Image versions created per hour threshold |
| `image_definition_threshold` | `number` | `5` | Image definition operations threshold |
| `gallery_access_threshold` | `number` | `1` | Access control changes threshold |

### Evaluation Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `evaluation_frequency_standard` | `string` | `"PT15M"` | Standard evaluation frequency (15 minutes) |
| `evaluation_frequency_critical` | `string` | `"PT5M"` | Critical evaluation frequency (5 minutes) |
| `window_duration_standard` | `string` | `"PT1H"` | Standard window duration (1 hour) |
| `window_duration_critical` | `string` | `"PT15M"` | Critical window duration (15 minutes) |

## Alert Details

### Activity Log Alerts

#### 1. Compute Gallery Creation
- **Operation**: `Microsoft.Compute/galleries/write`
- **Category**: Administrative
- **Level**: Informational
- **Status**: Succeeded
- **Scope**: Subscription
- **Description**: Monitors creation of new Compute Galleries. Important for change tracking and compliance.

#### 2. Compute Gallery Deletion
- **Operation**: `Microsoft.Compute/galleries/delete`
- **Category**: Administrative
- **Level**: Warning
- **Status**: Succeeded
- **Scope**: Subscription
- **Description**: Triggers when Compute Gallery is deleted. Essential for preventing accidental deletions.

#### 3. Image Definition Operations
- **Operation**: `Microsoft.Compute/galleries/images/write`
- **Category**: Administrative
- **Level**: Informational
- **Status**: Succeeded
- **Scope**: Subscription
- **Description**: Monitors image definition creation, modification, and deletion. Critical for image catalog management.

#### 4. Image Version Operations
- **Operation**: `Microsoft.Compute/galleries/images/versions/write`
- **Category**: Administrative
- **Level**: Informational
- **Status**: Succeeded
- **Scope**: Subscription
- **Description**: Tracks image version creation and updates. Essential for version control and deployment tracking.

#### 5. Gallery Sharing Profile Changes
- **Operation**: `Microsoft.Compute/galleries/write`
- **Category**: Administrative
- **Level**: Warning
- **Status**: Succeeded
- **Scope**: Subscription
- **Description**: Monitors changes to gallery sharing configuration. Important for security and compliance.

#### 6. Access Control Changes
- **Operation**: `Microsoft.Authorization/roleAssignments/write`
- **Category**: Administrative
- **Level**: Warning
- **Status**: Succeeded
- **Scope**: Subscription
- **Description**: Tracks RBAC changes for galleries. Critical for security monitoring.

### Scheduled Query Rules

#### 7. Replication Failure Monitoring
- **Query Type**: AzureActivity
- **Evaluation Frequency**: 15 minutes (default)
- **Window Duration**: 1 hour (default)
- **Threshold**: 1 failure (default)
- **Severity**: 2 (Warning)
- **Description**: Monitors image replication failures across regions. Critical for multi-region deployments.

**KQL Query Logic**:
```kql
AzureActivity
| where ResourceProvider == "Microsoft.Compute"
| where Resource has "galleries"
| where ActivityStatus == "Failed"
| where OperationName has "replication"
| summarize count() by bin(TimeGenerated, 15m), ResourceGroup
```

#### 8. High Volume Image Version Creation
- **Query Type**: AzureActivity
- **Evaluation Frequency**: 15 minutes (default)
- **Window Duration**: 1 hour (default)
- **Threshold**: 10 versions/hour (default)
- **Severity**: 3 (Informational)
- **Description**: Detects unusually high image version creation rates. Useful for detecting automated processes or issues.

**KQL Query Logic**:
```kql
AzureActivity
| where ResourceProvider == "Microsoft.Compute"
| where Resource has "galleries"
| where OperationName == "Microsoft.Compute/galleries/images/versions/write"
| where ActivityStatus == "Succeeded"
| summarize count() by bin(TimeGenerated, 15m), ResourceGroup
```

#### 9. Failed Gallery Operations
- **Query Type**: AzureActivity
- **Evaluation Frequency**: 5 minutes (default)
- **Window Duration**: 15 minutes (default)
- **Threshold**: 1 failure (default)
- **Severity**: 1 (Error)
- **Description**: **CRITICAL** - Monitors failed gallery operations. Indicates configuration issues or permission problems.

**KQL Query Logic**:
```kql
AzureActivity
| where ResourceProvider == "Microsoft.Compute"
| where Resource has "galleries"
| where ActivityStatus == "Failed"
| where OperationName has_any ("write", "delete", "action")
| summarize count() by bin(TimeGenerated, 5m), ResourceGroup, OperationName
```

#### 10. Gallery Security Events
- **Query Type**: AzureActivity
- **Evaluation Frequency**: 5 minutes (default)
- **Window Duration**: 1 hour (default)
- **Threshold**: 1 event (default)
- **Severity**: 2 (Warning)
- **Description**: Monitors security-related events including access control changes. Important for compliance and security auditing.

**KQL Query Logic**:
```kql
AzureActivity
| where ResourceProvider == "Microsoft.Compute"
| where Resource has "galleries"
| where Category == "Security"
| union (
    AzureActivity
    | where OperationName has_any ("Microsoft.Authorization/roleAssignments/write", "Microsoft.Authorization/roleAssignments/delete")
    | where Properties contains "galleries"
)
| summarize count() by bin(TimeGenerated, 15m), ResourceGroup
```

## Best Practices

### 1. Subscription ID Configuration

**CRITICAL**: `subscription_ids` is required for all alerts.

```hcl
# Correct: Provide subscription IDs
subscription_ids = ["12345678-1234-1234-1234-123456789012"]

# Incorrect: Empty list = no alerts created
subscription_ids = []
```

### 2. Threshold Configuration

#### Production Environments
```hcl
# Strict monitoring for production
replication_failure_threshold       = 1   # Alert on any failure
image_version_creation_threshold    = 5   # Lower threshold
gallery_access_threshold            = 1   # Alert on any access change

# Enable all alerts
enable_replication_failure_alert = true
enable_access_control_alert      = true
enable_gallery_deletion_alert    = true
```

#### Development Environments
```hcl
# Relaxed monitoring for development
replication_failure_threshold       = 3   # More tolerant
image_version_creation_threshold    = 20  # Higher volume allowed

# Disable non-critical alerts
enable_gallery_creation_alert = false
enable_sharing_profile_alert  = false
```

### 3. Replication Monitoring

```hcl
# Always enable replication monitoring in production
enable_replication_failure_alert = true
replication_failure_threshold    = 1  # Zero tolerance for failures

# Critical for multi-region image distribution
# Failures can break VM deployments across regions
```

### 4. Security Monitoring

```hcl
# Enable security alerts for compliance
enable_access_control_alert  = true
enable_sharing_profile_alert = true

# Low thresholds for security events
gallery_access_threshold = 1  # Alert on any RBAC change
```

### 5. Image Version Management

```hcl
# Track image versioning for audit trails
enable_image_version_alert = true
enable_image_definition_alert = true

# Set thresholds based on release cadence
# Daily releases: threshold = 10
# Weekly releases: threshold = 3
image_version_creation_threshold = 10
```

### 6. Multi-Subscription Strategy

```hcl
# Production: Monitor all production subscriptions
module "gallery_alerts_prod" {
  subscription_ids = [
    "prod-sub-1",
    "prod-sub-2"
  ]
  replication_failure_threshold = 1
}

# Development: Separate monitoring
module "gallery_alerts_dev" {
  subscription_ids = ["dev-sub-1"]
  replication_failure_threshold = 3
  enable_gallery_creation_alert = false
}
```

### 7. Gallery Sharing Best Practices

```hcl
# Enable sharing profile monitoring
enable_sharing_profile_alert = true

# Important for:
# - Cross-subscription image sharing
# - Community gallery management
# - Compliance with sharing policies
```

## Troubleshooting

### Common Issues

#### 1. No Alerts Being Created

**Problem**: No alerts appear in Azure Monitor.

**Solution**:
```hcl
# Ensure subscription_ids is not empty
subscription_ids = ["12345678-1234-1234-1234-123456789012"]  # REQUIRED

# Check resource group exists
resource_group_name = "rg-amba"  # Must exist

# Verify action group exists
action_group_resource_group_name = "rg-monitoring"
action_group                     = "existing-action-group"
```

#### 2. Query-Based Alerts Show "No Data"

**Problem**: Scheduled query rules not triggering or showing no data.

**Diagnostics**:
```bash
# Verify AzureActivity logs are available
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureActivity | where ResourceProvider == 'Microsoft.Compute' | where Resource has 'galleries' | take 10"
```

**Solution**:
```hcl
# 1. Ensure Activity Log is enabled (it's enabled by default)
# 2. Verify scopes include correct subscription IDs
# 3. Wait 15-30 minutes for initial data ingestion
# 4. Check that galleries exist and have activity
```

#### 3. Replication Failure Alert Not Triggering

**Problem**: Known replication failures not generating alerts.

**Solution**:
```bash
# Check if replication operations are logged
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureActivity | where OperationName has 'replication' | where Resource has 'galleries'"

# Verify threshold isn't too high
```

```hcl
# Lower threshold if needed
replication_failure_threshold = 1  # Alert on any failure
```

#### 4. Alert Firing Too Frequently

**Problem**: Receiving too many image version creation alerts.

**Solution**:
```hcl
# Increase threshold for high-volume environments
image_version_creation_threshold = 20  # Increase from 10

# Or increase evaluation window
evaluation_frequency_standard = "PT30M"  # Check every 30 minutes
window_duration_standard      = "PT2H"   # 2-hour window
```

#### 5. Activity Log Alerts Not Working

**Problem**: Administrative operation alerts not triggering.

**Solution**:
```hcl
# Verify subscription_ids is provided
subscription_ids = ["12345678-1234-1234-1234-123456789012"]

# Check you have Reader permissions on subscription
# Activity log alerts require subscription-level scope

# Verify operations are within the monitored subscriptions
```

#### 6. Security Alerts False Positives

**Problem**: Access control alerts triggering during normal operations.

**Solution**:
```hcl
# Adjust threshold for expected RBAC changes
gallery_access_threshold = 3  # Allow some changes

# Or disable during maintenance windows
enable_access_control_alert = false  # Temporarily disable
```

### Validation Commands

```bash
# Verify Terraform configuration
terraform init
terraform validate
terraform plan

# List existing alerts
az monitor activity-log alert list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'ComputeGallery')].{Name:name, Enabled:enabled}"

# List scheduled query rules
az monitor scheduled-query list \
  --resource-group "rg-amba" \
  --query "[?contains(name, 'Gallery')].{Name:name, Enabled:enabled, Severity:severity}"

# Test action group
az monitor action-group test-notifications create \
  --action-group "pge-operations-actiongroup" \
  --resource-group "rg-monitoring" \
  --notification-type "Email"

# Query gallery activity
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AzureActivity | where ResourceProvider == 'Microsoft.Compute' | where Resource has 'galleries' | summarize count() by OperationName, ActivityStatus"

# Check specific gallery
az sig show \
  --gallery-name "my-gallery" \
  --resource-group "rg-images"

# List image definitions
az sig image-definition list \
  --gallery-name "my-gallery" \
  --resource-group "rg-images"
```

### Debug Mode

```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform apply

# Check Terraform state
terraform state list | grep gallery
terraform state show module.compute_gallery_alerts.azurerm_monitor_activity_log_alert.gallery_creation[0]
```

## Alert Severity Mapping

| Severity | Level | Use Case | Action Required |
|----------|-------|----------|-----------------|
| 0 | Critical | Service down, data loss | Immediate response (PagerDuty) |
| 1 | Error | Significant degradation | Immediate attention (15 min) |
| 2 | Warning | Approaching limits | Review within 1 hour |
| 3 | Informational | FYI, trending | Review during business hours |

**This Module's Severity Distribution:**
- **Severity 1 (Error)**: Failed Gallery Operations
- **Severity 2 (Warning)**: Replication Failures, Gallery Security Events
- **Severity 3 (Informational)**: High Volume Image Creation
- **Activity Log Alerts**: No numeric severity (informational by nature)

## Performance Considerations

### Resource Creation Time
- **Activity Log Alerts**: ~5 seconds per alert
- **Scheduled Query Rules**: ~15 seconds per alert
- **Total Module Deployment**: ~2 minutes

### Query Evaluation Impact
- **Replication Monitoring**: Evaluates every 15 minutes (4 queries/hour)
- **High Volume Detection**: Evaluates every 15 minutes (4 queries/hour)
- **Failed Operations**: Evaluates every 5 minutes (12 queries/hour)
- **Security Events**: Evaluates every 5 minutes (12 queries/hour)

**Total**: ~32 queries/hour (minimal Log Analytics cost impact)

## Cost Optimization

### Alert Pricing (2025)
- **Activity Log Alerts**: Free
- **Scheduled Query Rules**: $0.10 per alert per month
- **Total Module Cost**:
  - 6 activity log alerts × $0 = $0/month
  - 4 query rules × $0.10 = $0.40/month
  - **Total: ~$0.40/month per module instance**

### Cost Reduction Strategies
```hcl
# Disable non-critical alerts in dev/test
enable_gallery_creation_alert    = false
enable_sharing_profile_alert     = false
enable_image_definition_alert    = false

# Use longer evaluation frequencies
evaluation_frequency_standard = "PT30M"  # Reduces query execution frequency

# Consolidate action groups
# (Reuse existing action groups across modules)
```

## License

This module follows your organization's licensing terms.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-24 | Initial release with 10 alerts |

---

**Last Updated**: November 24, 2025  
**Module Version**: 1.0.0  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
