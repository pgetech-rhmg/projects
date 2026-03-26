# Redis Cache Metric Alerts
# This file contains metric alerts for Azure Redis Cache monitoring following AMBA best practices

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.redis_cache_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.redis_cache_names) > 0
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get Redis Cache instances using static names
data "azurerm_redis_cache" "redis_caches" {
  for_each            = toset(var.redis_cache_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Redis Cache - CPU Usage Alert
resource "azurerm_monitor_metric_alert" "redis_cpu_usage" {
  count               = var.enable_redis_cpu_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-cpu-usage-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache CPU usage is above threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "percentProcessorTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_cpu_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Redis Cache - Memory Usage Alert
resource "azurerm_monitor_metric_alert" "redis_memory_usage" {
  count               = var.enable_redis_memory_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-memory-usage-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache memory usage is above threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "usedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_memory_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Redis Cache - Server Load Alert
resource "azurerm_monitor_metric_alert" "redis_server_load" {
  count               = var.enable_redis_server_load_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-server-load-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache server load is above threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "serverLoad"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_server_load_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Redis Cache - Connected Clients Alert
resource "azurerm_monitor_metric_alert" "redis_connected_clients" {
  count               = var.enable_redis_connected_clients_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-connected-clients-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache connected clients count is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "connectedclients"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_connected_clients_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Redis Cache - Cache Miss Rate Alert
resource "azurerm_monitor_metric_alert" "redis_cache_miss_rate" {
  count               = var.enable_redis_cache_miss_rate_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-cache-miss-rate-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache miss rate is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "cachemissrate"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_cache_miss_rate_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Redis Cache - Evicted Keys Alert
resource "azurerm_monitor_metric_alert" "redis_evicted_keys" {
  count               = var.enable_redis_evicted_keys_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-evicted-keys-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache evicted keys count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "evictedkeys"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.redis_evicted_keys_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Capacity"
  })
}

# Redis Cache - Expired Keys Alert
resource "azurerm_monitor_metric_alert" "redis_expired_keys" {
  count               = var.enable_redis_expired_keys_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-expired-keys-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache expired keys count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "expiredkeys"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.redis_expired_keys_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Redis Cache - Total Keys Alert
resource "azurerm_monitor_metric_alert" "redis_total_keys" {
  count               = var.enable_redis_total_keys_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-total-keys-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache total keys count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "totalkeys"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_total_keys_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Capacity"
  })
}

# Redis Cache - Operations Per Second Alert
resource "azurerm_monitor_metric_alert" "redis_operations_per_second" {
  count               = var.enable_redis_operations_per_second_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-operations-per-second-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache operations per second is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "operationsPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_operations_per_second_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Redis Cache - Cache Read Bandwidth Alert
resource "azurerm_monitor_metric_alert" "redis_cache_read_bandwidth" {
  count               = var.enable_redis_cache_read_bandwidth_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-cache-read-bandwidth-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache read bandwidth is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "cacheRead"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_cache_read_bandwidth_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

resource "azurerm_monitor_metric_alert" "redis_cache_write_bandwidth" {
  count               = var.enable_redis_cache_write_bandwidth_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-cache-write-bandwidth-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache write bandwidth is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "cacheWrite"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_cache_write_bandwidth_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Redis Cache Total Commands Processed Alert
resource "azurerm_monitor_metric_alert" "redis_total_commands_processed" {
  count               = var.enable_redis_total_commands_processed_alert && length(var.redis_cache_names) > 0 ? 1 : 0
  name                = "redis-total-commands-processed-high-${join("-", var.redis_cache_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for cache in data.azurerm_redis_cache.redis_caches : cache.id]
  description         = "Redis Cache total commands processed is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "totalcommandsprocessed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.redis_total_commands_processed_threshold

    dimension {
      name     = "ShardId"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Diagnostic Settings to Event Hub (for activity logs)
resource "azurerm_monitor_diagnostic_setting" "redis_to_eventhub" {
  for_each                       = local.diagnostic_settings_eventhub_enabled ? toset(var.redis_cache_names) : []
  name                           = "redis-to-eventhub-${each.key}"
  target_resource_id             = data.azurerm_redis_cache.redis_caches[each.key].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "ConnectedClientList"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# Diagnostic Settings to Log Analytics (for security logs)
resource "azurerm_monitor_diagnostic_setting" "redis_to_loganalytics" {
  for_each                   = local.diagnostic_settings_loganalytics_enabled ? toset(var.redis_cache_names) : []
  name                       = "redis-to-loganalytics-${each.key}"
  target_resource_id         = data.azurerm_redis_cache.redis_caches[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "ConnectedClientList"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
