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

# =======================================================================================
# Production Example - Complete monitoring with all alerts and diagnostic settings
# =======================================================================================
module "redis_alerts_production" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-redis-prod"
  redis_cache_names                = ["redis-cache-prod-001", "redis-cache-prod-002"]
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "ag-redis-prod"

  # Enable all alerts with production thresholds
  enable_redis_cpu_alert                      = true
  enable_redis_memory_alert                   = true
  enable_redis_server_load_alert              = true
  enable_redis_connected_clients_alert        = true
  enable_redis_cache_miss_rate_alert          = true
  enable_redis_evicted_keys_alert             = true
  enable_redis_expired_keys_alert             = true
  enable_redis_total_keys_alert               = true
  enable_redis_operations_per_second_alert    = true
  enable_redis_cache_read_bandwidth_alert     = true
  enable_redis_cache_write_bandwidth_alert    = true
  enable_redis_total_commands_processed_alert = true

  # Production thresholds - tighter monitoring
  redis_cpu_threshold                      = 80        # Alert at 80% CPU
  redis_memory_threshold                   = 85        # Alert at 85% memory
  redis_server_load_threshold              = 80        # Alert at 80% server load
  redis_connected_clients_threshold        = 900       # Alert at 900 clients
  redis_cache_miss_rate_threshold          = 20        # Alert at 20% cache miss rate
  redis_evicted_keys_threshold             = 100       # Alert at 100 evicted keys
  redis_expired_keys_threshold             = 1000      # Alert at 1000 expired keys
  redis_total_keys_threshold               = 900000    # Alert at 900K keys
  redis_operations_per_second_threshold    = 9000      # Alert at 9000 ops/sec
  redis_cache_read_bandwidth_threshold     = 900000000 # Alert at 900 MB/s
  redis_cache_write_bandwidth_threshold    = 900000000 # Alert at 900 MB/s
  redis_total_commands_processed_threshold = 90000     # Alert at 90K commands

  # Diagnostic settings configuration
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "evhns-monitoring-prod"
  eventhub_name                     = "evh-redis-logs"
  eventhub_resource_group_name      = "rg-monitoring-prod"
  eventhub_authorization_rule_name  = "RootManageSharedAccessKey"
  log_analytics_workspace_name      = "law-monitoring-prod"
  log_analytics_resource_group_name = "rg-monitoring-prod"

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

# =======================================================================================
# Development Example - Balanced monitoring with relaxed thresholds
# =======================================================================================
module "redis_alerts_development" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-redis-dev"
  redis_cache_names                = ["redis-cache-dev-001"]
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "ag-redis-dev"

  # Enable key alerts for development
  enable_redis_cpu_alert                      = true
  enable_redis_memory_alert                   = true
  enable_redis_server_load_alert              = true
  enable_redis_connected_clients_alert        = false # Disabled for dev
  enable_redis_cache_miss_rate_alert          = true
  enable_redis_evicted_keys_alert             = false # Disabled for dev
  enable_redis_expired_keys_alert             = false # Disabled for dev
  enable_redis_total_keys_alert               = false # Disabled for dev
  enable_redis_operations_per_second_alert    = true
  enable_redis_cache_read_bandwidth_alert     = false # Disabled for dev
  enable_redis_cache_write_bandwidth_alert    = false # Disabled for dev
  enable_redis_total_commands_processed_alert = false # Disabled for dev

  # Development thresholds - more relaxed
  redis_cpu_threshold                   = 90   # Alert at 90% CPU
  redis_memory_threshold                = 90   # Alert at 90% memory
  redis_server_load_threshold           = 90   # Alert at 90% server load
  redis_cache_miss_rate_threshold       = 30   # Alert at 30% cache miss rate
  redis_operations_per_second_threshold = 5000 # Alert at 5000 ops/sec

  # Diagnostic settings - Event Hub only
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-monitoring-dev"
  eventhub_name                    = "evh-redis-logs"
  eventhub_resource_group_name     = "rg-monitoring-dev"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"

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

# =======================================================================================
# Basic Example - Minimal monitoring for testing
# =======================================================================================
module "redis_alerts_basic" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-redis-test"
  redis_cache_names                = ["redis-cache-test-001"]
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "ag-redis-test"

  # Enable only critical alerts
  enable_redis_cpu_alert                      = true
  enable_redis_memory_alert                   = true
  enable_redis_server_load_alert              = false
  enable_redis_connected_clients_alert        = false
  enable_redis_cache_miss_rate_alert          = false
  enable_redis_evicted_keys_alert             = false
  enable_redis_expired_keys_alert             = false
  enable_redis_total_keys_alert               = false
  enable_redis_operations_per_second_alert    = false
  enable_redis_cache_read_bandwidth_alert     = false
  enable_redis_cache_write_bandwidth_alert    = false
  enable_redis_total_commands_processed_alert = false

  # Basic thresholds - only critical alerts
  redis_cpu_threshold    = 95 # Alert at 95% CPU
  redis_memory_threshold = 95 # Alert at 95% memory

  # Diagnostic settings disabled for testing
  enable_diagnostic_settings = false

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
