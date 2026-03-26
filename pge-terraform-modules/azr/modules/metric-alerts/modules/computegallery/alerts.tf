# Azure Compute Gallery AMBA Alerts
# This file contains comprehensive monitoring alerts for Azure Compute Gallery operations
# following AMBA (Azure Monitor Baseline Alerts) best practices

# Data source for getting current client configuration
data "azurerm_client_config" "current" {}

# Data source for action group reference
data "azurerm_monitor_action_group" "action_group" {
  resource_group_name = var.action_group_resource_group_name
  name                = var.action_group
}

# Create scopes lists - empty arrays disable alert creation
locals {
  # Subscription-level alerts - empty array disables all alerts
  subscription_scopes = length(var.subscription_ids) > 0 ? [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"] : []
}

# 1. Compute Gallery Creation Alert
resource "azurerm_monitor_activity_log_alert" "gallery_creation" {
  count = var.enable_gallery_creation_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                = "ComputeGallery-Creation-Alert"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = local.subscription_scopes
  description         = "Alert triggered when a Compute Gallery is created"
  tags = merge(var.tags, {
    alert_type = "ResourceCreation"
  })

  criteria {
    resource_type  = "Microsoft.Compute/galleries"
    operation_name = "Microsoft.Compute/galleries/write"
    category       = "Administrative"
    level          = "Informational"
    status         = "Succeeded"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# 2. Compute Gallery Deletion Alert
resource "azurerm_monitor_activity_log_alert" "gallery_deletion" {
  count = var.enable_gallery_deletion_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                = "ComputeGallery-Deletion-Alert"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = local.subscription_scopes
  description         = "Alert triggered when a Compute Gallery is deleted"
  tags = merge(var.tags, {
    alert_type = "ResourceDeletion"
  })

  criteria {
    resource_type  = "Microsoft.Compute/galleries"
    operation_name = "Microsoft.Compute/galleries/delete"
    category       = "Administrative"
    level          = "Warning"
    status         = "Succeeded"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# 3. Image Definition Operations Alert
resource "azurerm_monitor_activity_log_alert" "image_definition_operations" {
  count = var.enable_image_definition_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                = "ImageDefinition-Operations-Alert"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = local.subscription_scopes
  description         = "Alert triggered when image definitions are created, modified, or deleted"
  tags = merge(var.tags, {
    alert_type = "ImageManagement"
  })

  criteria {
    resource_type  = "Microsoft.Compute/galleries/images"
    operation_name = "Microsoft.Compute/galleries/images/write"
    category       = "Administrative"
    level          = "Informational"
    status         = "Succeeded"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# 4. Image Version Operations Alert
resource "azurerm_monitor_activity_log_alert" "image_version_operations" {
  count = var.enable_image_version_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                = "ImageVersion-Operations-Alert"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = local.subscription_scopes
  description         = "Alert triggered when image versions are created, modified, or deleted"
  tags = merge(var.tags, {
    alert_type = "ImageVersioning"
  })

  criteria {
    resource_type  = "Microsoft.Compute/galleries/images/versions"
    operation_name = "Microsoft.Compute/galleries/images/versions/write"
    category       = "Administrative"
    level          = "Informational"
    status         = "Succeeded"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# 5. Gallery Sharing Profile Changes Alert
resource "azurerm_monitor_activity_log_alert" "sharing_profile_changes" {
  count = var.enable_sharing_profile_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                = "GallerySharing-Changes-Alert"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = local.subscription_scopes
  description         = "Alert triggered when gallery sharing profile is modified"
  tags = merge(var.tags, {
    alert_type = "SharingConfiguration"
  })

  criteria {
    resource_type  = "Microsoft.Compute/galleries"
    operation_name = "Microsoft.Compute/galleries/write"
    category       = "Administrative"
    level          = "Warning"
    status         = "Succeeded"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# 6. Access Control Changes Alert
resource "azurerm_monitor_activity_log_alert" "access_control_changes" {
  count = var.enable_access_control_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                = "GalleryAccessControl-Changes-Alert"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = local.subscription_scopes
  description         = "Alert triggered when gallery access control (RBAC) is modified"
  tags = merge(var.tags, {
    alert_type = "SecurityConfiguration"
  })

  criteria {
    operation_name = "Microsoft.Authorization/roleAssignments/write"
    category       = "Administrative"
    level          = "Warning"
    status         = "Succeeded"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# 7. Replication Failure Monitoring (Scheduled Query Rule)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "replication_failure_monitoring" {
  count = var.enable_replication_failure_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                 = "GalleryReplication-Failure-Alert"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_standard
  window_duration      = var.window_duration_standard
  scopes               = local.subscription_scopes
  severity             = 2
  description          = "Alert when Compute Gallery image replication fails"
  tags = merge(var.tags, {
    alert_type = "ReplicationMonitoring"
  })

  criteria {
    query = <<-QUERY
      AzureActivity
      | where TimeGenerated >= ago(1h)
      | where ResourceProvider == "Microsoft.Compute"
      | where Resource has "galleries"
      | where ActivityStatus == "Failed"
      | where OperationName has "replication"
      | project TimeGenerated, ResourceGroup, Resource, ActivityStatus, OperationName, Properties
      | summarize count() by bin(TimeGenerated, 15m), ResourceGroup
    QUERY

    time_aggregation_method = "Count"
    threshold               = var.replication_failure_threshold
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.action_group.id]
  }

  auto_mitigation_enabled = true
}

# 8. High Volume Image Version Creation (Scheduled Query Rule)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "high_volume_image_creation" {
  count = var.enable_image_version_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                 = "ImageVersion-HighVolume-Alert"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_standard
  window_duration      = var.window_duration_standard
  scopes               = local.subscription_scopes
  severity             = 3
  description          = "Alert when unusually high number of image versions are created"
  tags = merge(var.tags, {
    alert_type = "VolumeMonitoring"
  })

  criteria {
    query = <<-QUERY
      AzureActivity
      | where TimeGenerated >= ago(1h)
      | where ResourceProvider == "Microsoft.Compute"
      | where Resource has "galleries"
      | where OperationName == "Microsoft.Compute/galleries/images/versions/write"
      | where ActivityStatus == "Succeeded"
      | project TimeGenerated, ResourceGroup, Resource, OperationName
      | summarize count() by bin(TimeGenerated, 15m), ResourceGroup
    QUERY

    time_aggregation_method = "Count"
    threshold               = var.image_version_creation_threshold
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.action_group.id]
  }

  auto_mitigation_enabled = true
}

# 9. Failed Gallery Operations (Scheduled Query Rule)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_gallery_operations" {
  count = var.enable_gallery_modification_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                 = "GalleryOperations-Failed-Alert"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_critical
  window_duration      = var.window_duration_critical
  scopes               = local.subscription_scopes
  severity             = 1
  description          = "Alert when Compute Gallery operations fail"
  tags = merge(var.tags, {
    alert_type = "OperationalHealth"
  })

  criteria {
    query = <<-QUERY
      AzureActivity
      | where TimeGenerated >= ago(15m)
      | where ResourceProvider == "Microsoft.Compute"
      | where Resource has "galleries"
      | where ActivityStatus == "Failed"
      | where OperationName has_any ("write", "delete", "action")
      | project TimeGenerated, ResourceGroup, Resource, ActivityStatus, OperationName, Properties
      | summarize count() by bin(TimeGenerated, 5m), ResourceGroup, OperationName
    QUERY

    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.action_group.id]
  }

  auto_mitigation_enabled = true
}

# 10. Gallery Security Events (Scheduled Query Rule)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "gallery_security_events" {
  count = var.enable_access_control_alert && length(local.subscription_scopes) > 0 ? 1 : 0

  name                 = "GallerySecurity-Events-Alert"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_critical
  window_duration      = var.window_duration_standard
  scopes               = local.subscription_scopes
  severity             = 2
  description          = "Alert on security-related events for Compute Galleries"
  tags = merge(var.tags, {
    alert_type = "SecurityMonitoring"
  })

  criteria {
    query = <<-QUERY
      AzureActivity
      | where TimeGenerated >= ago(1h)
      | where ResourceProvider == "Microsoft.Compute"
      | where Resource has "galleries"
      | where Category == "Security"
      | union (
          AzureActivity
          | where TimeGenerated >= ago(1h)
          | where OperationName has_any ("Microsoft.Authorization/roleAssignments/write", "Microsoft.Authorization/roleAssignments/delete")
          | where Properties contains "galleries"
      )
      | project TimeGenerated, ResourceGroup, Resource, ActivityStatus, OperationName, Caller
      | summarize count() by bin(TimeGenerated, 15m), ResourceGroup
    QUERY

    time_aggregation_method = "Count"
    threshold               = var.gallery_access_threshold
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.action_group.id]
  }

  auto_mitigation_enabled = true
}