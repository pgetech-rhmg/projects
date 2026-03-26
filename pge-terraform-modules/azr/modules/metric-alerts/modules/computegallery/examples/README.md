# Compute Gallery Module Examples

This directory contains usage examples for the Azure Compute Gallery monitoring module. These examples demonstrate different deployment scenarios and configurations.

## Prerequisites

- Terraform >= 1.0
- Azure subscription with appropriate permissions
- Existing Azure Compute Gallery (optional - alerts monitor gallery operations)
- Existing Azure Monitor Action Group

## Examples Overview

### Example 1: Production with Full Monitoring

This example demonstrates a production-ready configuration with:
- All alert categories enabled
- Comprehensive monitoring for gallery operations
- Activity log alerts at the subscription level

**Key Features:**
- Gallery creation/deletion monitoring
- Image definition and version tracking
- Sharing profile change alerts
- Access control monitoring
- Gallery modification alerts

### Example 2: Development with Selective Monitoring

This example shows a development environment configuration with:
- Only critical alerts enabled (creation, deletion, access control)
- Reduced alert noise for development work
- Essential operational monitoring

**Key Features:**
- Gallery creation/deletion alerts
- Access control monitoring
- Disabled modification and image alerts

### Example 3: Basic Monitoring

This example demonstrates minimal monitoring configuration:
- Default alert settings (all enabled)
- Quick setup with minimal configuration
- Suitable for test environments

**Key Features:**
- Standard alert configuration
- Default settings for all alert types

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
enable_gallery_creation_alert     = true  # Gallery creation monitoring
enable_gallery_deletion_alert     = true  # Gallery deletion monitoring
enable_gallery_modification_alert = true  # Gallery modification tracking
enable_image_definition_alert     = true  # Image definition operations
enable_image_version_alert        = true  # Image version operations
enable_sharing_profile_alert      = true  # Sharing profile changes
enable_access_control_alert       = true  # Access control modifications
```

### Subscription Configuration

Configure which subscriptions to monitor:

```hcl
# Subscription IDs for activity log alerts
subscription_ids = [
  "12345678-1234-1234-1234-123456789012",
  "87654321-4321-4321-4321-210987654321"
]
```

## Outputs

The examples provide the following outputs:

- **alert_ids**: Map of all created activity log alert resource IDs
- **alert_names**: Map of all created activity log alert names
- **monitored_subscriptions**: List of subscription IDs being monitored
- **action_group_id**: ID of the Action Group receiving alerts

## Alert Types

The module can create the following activity log alerts for Compute Gallery:

### Operational Alerts
1. **Gallery Creation** - Monitors Compute Gallery creation operations
2. **Gallery Deletion** - Monitors Compute Gallery deletion operations
3. **Gallery Modification** - Tracks gallery property modifications
4. **Image Definition Operations** - Monitors image definition create/update/delete
5. **Image Version Operations** - Tracks image version operations
6. **Sharing Profile Changes** - Monitors sharing configuration changes
7. **Access Control Changes** - Tracks RBAC and permission modifications

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

## Important Notes

- **Activity Log Alerts**: All alerts in this module are activity log alerts that monitor subscription-level operations
- **No Diagnostic Settings**: Compute Gallery does not support diagnostic settings configuration
- **Subscription Scope**: Alerts require at least one subscription ID to be configured
- **Global Location**: Activity log alerts use "global" location as they monitor subscription-level events

## Cleanup

To remove all created resources:

```bash
terraform destroy
```

## Additional Resources

- [Azure Compute Gallery Documentation](https://learn.microsoft.com/azure/virtual-machines/azure-compute-gallery)
- [Azure Monitor Activity Log Alerts](https://learn.microsoft.com/azure/azure-monitor/alerts/activity-log-alerts)
- [Azure Monitor Action Groups](https://learn.microsoft.com/azure/azure-monitor/alerts/action-groups)
- [Shared Image Gallery Best Practices](https://learn.microsoft.com/azure/virtual-machines/shared-image-galleries)
