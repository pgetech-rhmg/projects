# Azure Virtual Machine Monitoring - Example Configurations
# This example demonstrates various deployment patterns for Virtual Machine monitoring

# =======================================================================================
# Data Sources - Common across all examples
# =======================================================================================

data "azurerm_monitor_action_group" "pge_operations" {
  name                = "PGE-Operations"
  resource_group_name = "rg-pge-monitoring-prod"
}

# =======================================================================================
# Example 1: Production VMs with Full Monitoring
# =======================================================================================
# This configuration monitors production VMs with comprehensive alerting and diagnostics

module "vm_monitoring_production" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-vms-prod"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"

  # Virtual Machines to Monitor
  virtual_machine_names = [
    "vm-web-prod-01",
    "vm-web-prod-02",
    "vm-app-prod-01",
    "vm-app-prod-02",
    "vm-db-prod-01"
  ]

  # Alert Thresholds - Strict for Production
  cpu_percentage_threshold             = 75
  cpu_percentage_critical_threshold    = 90
  memory_percentage_threshold          = 20
  memory_percentage_critical_threshold = 10
  disk_iops_threshold                  = 500
  disk_queue_depth_threshold           = 32
  network_in_threshold                 = 104857600 # 100MB/s
  network_out_threshold                = 104857600 # 100MB/s
  vm_heartbeat_threshold               = 5
  data_disk_read_bytes_threshold       = 52428800 # 50MB/s
  data_disk_write_bytes_threshold      = 52428800 # 50MB/s
  premium_disk_cache_miss_threshold    = 20

  # Diagnostic Settings - Event Hub for SIEM Integration
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-pge-monitoring-prod"
  eventhub_name                    = "evh-vm-metrics"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"
  eventhub_resource_group_name     = "rg-pge-monitoring-prod"
  eventhub_subscription_id         = ""

  # Diagnostic Settings - Log Analytics for Analysis
  log_analytics_workspace_name      = "law-pge-monitoring-prod"
  log_analytics_resource_group_name = "rg-pge-monitoring-prod"
  log_analytics_subscription_id     = ""

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
# Example 2: Development VMs with Balanced Monitoring
# =======================================================================================
# This configuration monitors development VMs with relaxed thresholds

module "vm_monitoring_development" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-vms-dev"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"

  # Virtual Machines to Monitor
  virtual_machine_names = [
    "vm-web-dev-01",
    "vm-app-dev-01",
    "vm-db-dev-01"
  ]

  # Alert Thresholds - Relaxed for Development
  cpu_percentage_threshold             = 85
  cpu_percentage_critical_threshold    = 95
  memory_percentage_threshold          = 15
  memory_percentage_critical_threshold = 5
  disk_iops_threshold                  = 750
  disk_queue_depth_threshold           = 48
  network_in_threshold                 = 157286400 # 150MB/s
  network_out_threshold                = 157286400 # 150MB/s
  vm_heartbeat_threshold               = 10
  data_disk_read_bytes_threshold       = 104857600 # 100MB/s
  data_disk_write_bytes_threshold      = 104857600 # 100MB/s
  premium_disk_cache_miss_threshold    = 30

  # Diagnostic Settings - Log Analytics Only
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = ""
  eventhub_name                     = ""
  log_analytics_workspace_name      = "law-pge-monitoring-dev"
  log_analytics_resource_group_name = "rg-pge-monitoring-dev"
  log_analytics_subscription_id     = ""

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
# Example 3: Basic VM Monitoring for Test Environment
# =======================================================================================
# This configuration provides minimal monitoring for test VMs

module "vm_monitoring_basic" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-vms-test"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"

  # Virtual Machines to Monitor
  virtual_machine_names = [
    "vm-test-01"
  ]

  # Alert Thresholds - Minimal
  cpu_percentage_threshold             = 90
  cpu_percentage_critical_threshold    = 98
  memory_percentage_threshold          = 10
  memory_percentage_critical_threshold = 5
  disk_iops_threshold                  = 1000
  disk_queue_depth_threshold           = 64
  network_in_threshold                 = 209715200 # 200MB/s
  network_out_threshold                = 209715200 # 200MB/s
  vm_heartbeat_threshold               = 15
  data_disk_read_bytes_threshold       = 157286400 # 150MB/s
  data_disk_write_bytes_threshold      = 157286400 # 150MB/s
  premium_disk_cache_miss_threshold    = 40

  # Disable Diagnostic Settings
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
