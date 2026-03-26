# Virtual Machine Metric Alerts
# This file contains AMBA (Azure Monitor Baseline Alerts) for Azure Virtual Machines

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Local variables for cross-subscription support
locals {
  # Cross-subscription support for Event Hub and Log Analytics
  eventhub_subscription_id      = var.eventhub_subscription_id != "" ? var.eventhub_subscription_id : data.azurerm_client_config.current.subscription_id
  log_analytics_subscription_id = var.log_analytics_subscription_id != "" ? var.log_analytics_subscription_id : data.azurerm_client_config.current.subscription_id
  eventhub_resource_group       = var.eventhub_resource_group_name != "" ? var.eventhub_resource_group_name : var.resource_group_name
  log_analytics_resource_group  = var.log_analytics_resource_group_name != "" ? var.log_analytics_resource_group_name : var.resource_group_name

  # Construct full resource IDs for cross-subscription support
  eventhub_namespace_id      = "/subscriptions/${local.eventhub_subscription_id}/resourceGroups/${local.eventhub_resource_group}/providers/Microsoft.EventHub/namespaces/${var.eventhub_namespace_name}"
  eventhub_id                = "${local.eventhub_namespace_id}/eventhubs/${var.eventhub_name}"
  eventhub_auth_rule_id      = "${local.eventhub_namespace_id}/authorizationRules/${var.eventhub_authorization_rule_name}"
  log_analytics_workspace_id = "/subscriptions/${local.log_analytics_subscription_id}/resourceGroups/${local.log_analytics_resource_group}/providers/Microsoft.OperationalInsights/workspaces/${var.log_analytics_workspace_name}"

  # Simplified diagnostic settings flags
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.virtual_machine_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.virtual_machine_names) > 0
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get virtual machines using static names
data "azurerm_virtual_machine" "virtual_machines" {
  for_each            = toset(var.virtual_machine_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# CPU Percentage Alert (Warning)
resource "azurerm_monitor_metric_alert" "vm_cpu_percentage" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-cpu-percentage-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM CPU percentage exceeds ${var.cpu_percentage_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_percentage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-cpu-percentage"
  })
}

# CPU Percentage Alert (Critical)
resource "azurerm_monitor_metric_alert" "vm_cpu_percentage_critical" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-cpu-percentage-critical-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Critical alert when VM CPU percentage exceeds ${var.cpu_percentage_critical_threshold}%"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_percentage_critical_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-cpu-percentage-critical"
  })
}

# Available Memory Percentage Alert (Warning)
resource "azurerm_monitor_metric_alert" "vm_memory_percentage" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-memory-percentage-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM available memory drops below ${var.memory_percentage_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.memory_percentage_threshold * 1024 * 1024 * 1024 # Convert percentage to bytes (assuming 8GB base)
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-memory-percentage"
  })
}

# Available Memory Percentage Alert (Critical)
resource "azurerm_monitor_metric_alert" "vm_memory_percentage_critical" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-memory-percentage-critical-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Critical alert when VM available memory drops below ${var.memory_percentage_critical_threshold}%"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.memory_percentage_critical_threshold * 1024 * 1024 * 1024 # Convert percentage to bytes
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-memory-percentage-critical"
  })
}

# Disk Read Operations/Sec Alert
resource "azurerm_monitor_metric_alert" "vm_disk_read_ops" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-disk-read-ops-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM disk read operations exceed ${var.disk_iops_threshold} IOPS"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Read Operations/Sec"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_iops_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-disk-read-ops"
  })
}

# Disk Write Operations/Sec Alert
resource "azurerm_monitor_metric_alert" "vm_disk_write_ops" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-disk-write-ops-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM disk write operations exceed ${var.disk_iops_threshold} IOPS"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Write Operations/Sec"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_iops_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-disk-write-ops"
  })
}

# Disk Queue Depth Alert
resource "azurerm_monitor_metric_alert" "vm_disk_queue_depth" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-disk-queue-depth-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM disk queue depth exceeds ${var.disk_queue_depth_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Queue Depth"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_queue_depth_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-disk-queue-depth"
  })
}

# Network In Alert
resource "azurerm_monitor_metric_alert" "vm_network_in" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-network-in-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM network bytes in exceeds ${var.network_in_threshold / 1024 / 1024}MB/s"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network In Total"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.network_in_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-network-in"
  })
}

# Network Out Alert
resource "azurerm_monitor_metric_alert" "vm_network_out" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-network-out-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM network bytes out exceeds ${var.network_out_threshold / 1024 / 1024}MB/s"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out Total"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.network_out_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-network-out"
  })
}

# VM Availability Alert (using VM Insights)
resource "azurerm_monitor_metric_alert" "vm_heartbeat" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-heartbeat-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM heartbeat is missing for more than ${var.vm_heartbeat_threshold} minutes"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-heartbeat"
  })
}

# Data Disk Read Bytes/sec Alert
resource "azurerm_monitor_metric_alert" "vm_data_disk_read_bytes" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-data-disk-read-bytes-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM data disk read bytes/sec is high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Data Disk Read Bytes/sec"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 52428800 # 50MB/s
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-data-disk-read-bytes"
  })
}

# Data Disk Write Bytes/sec Alert
resource "azurerm_monitor_metric_alert" "vm_data_disk_write_bytes" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-data-disk-write-bytes-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM data disk write bytes/sec is high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Data Disk Write Bytes/sec"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 52428800 # 50MB/s
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-data-disk-write-bytes"
  })
}

# Premium Data Disk Cache Miss Percentage Alert
resource "azurerm_monitor_metric_alert" "vm_premium_data_disk_cache_miss" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-premium-data-disk-cache-miss-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM premium data disk cache miss percentage is high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Premium Data Disk Cache Read Miss"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 20 # 20% cache miss rate
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-premium-data-disk-cache-miss"
  })
}

# Premium OS Disk Cache Miss Percentage Alert
resource "azurerm_monitor_metric_alert" "vm_premium_os_disk_cache_miss" {
  for_each            = data.azurerm_virtual_machine.virtual_machines
  name                = "vm-premium-os-disk-cache-miss-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when VM premium OS disk cache miss percentage is high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Premium OS Disk Cache Read Miss"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 20 # 20% cache miss rate
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-premium-os-disk-cache-miss"
  })
}

#====================================================================================================
# DIAGNOSTIC SETTINGS - Send Activity Logs to Event Hub and Security Logs to Log Analytics Workspace
#====================================================================================================

# Send Virtual Machine Metrics to Event Hub for external SIEM integration
# Note: VMs only support metrics at the VM level, not logs
resource "azurerm_monitor_diagnostic_setting" "vm_to_eventhub" {
  for_each = local.diagnostic_settings_eventhub_enabled ? toset(var.virtual_machine_names) : []

  name                           = "send-vm-metrics-to-eventhub"
  target_resource_id             = data.azurerm_virtual_machine.virtual_machines[each.key].id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id

  # Virtual Machines support metrics only
  metric {
    category = "AllMetrics"
    enabled  = true
  }

  lifecycle {
    ignore_changes = [
      eventhub_name,
      eventhub_authorization_rule_id,
    ]
  }
}

# Send Virtual Machine Metrics to Log Analytics Workspace for analysis
resource "azurerm_monitor_diagnostic_setting" "vm_to_loganalytics" {
  for_each = local.diagnostic_settings_loganalytics_enabled ? toset(var.virtual_machine_names) : []

  name                       = "send-vm-metrics-to-loganalytics"
  target_resource_id         = data.azurerm_virtual_machine.virtual_machines[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Virtual Machines support metrics only
  metric {
    category = "AllMetrics"
    enabled  = true
  }

  lifecycle {
    ignore_changes = [
      log_analytics_workspace_id,
    ]
  }
}

