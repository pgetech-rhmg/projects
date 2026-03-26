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

# Example 1: Production deployment with Windows Function Apps and strict thresholds
module "functionapps_alerts_production" {
  source = "../"

  windows_function_app_names       = ["prod-func-001", "prod-func-002"]
  linux_function_app_names         = []
  resource_group_name              = "rg-functions-prod"
  action_group_resource_group_name = "rg-actiongroups-prod"
  action_group                     = "ag-production-alerts"
  location                         = "East US"

  # Enable all alert categories
  enable_function_execution_alerts = true
  enable_performance_alerts        = true
  enable_error_alerts              = true
  enable_resource_alerts           = true

  # Production thresholds - strict monitoring
  function_execution_count_threshold   = 8000  # 8,000 executions
  function_execution_units_threshold   = 80000 # 80,000 MB-ms
  average_memory_working_set_threshold = 800   # 800 MB
  response_time_threshold              = 3000  # 3 seconds
  response_time_critical_threshold     = 10000 # 10 seconds
  http_5xx_threshold                   = 10    # 10 server errors
  http_4xx_threshold                   = 50    # 50 client errors
  memory_working_set_threshold         = 1000  # 1 GB
  io_read_ops_threshold                = 8000  # 8,000 read ops
  io_write_ops_threshold               = 8000  # 8,000 write ops
  private_bytes_threshold              = 800   # 800 MB
  gen_0_collections_threshold          = 80    # 80 GC gen 0
  gen_1_collections_threshold          = 40    # 40 GC gen 1
  gen_2_collections_threshold          = 20    # 20 GC gen 2
  requests_threshold                   = 10000 # 10,000 requests

  # Diagnostic Settings
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-logs-prod"
  eventhub_name                    = "evh-diagnostics-prod"
  eventhub_resource_group_name     = "rg-monitoring-prod"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"

  log_analytics_workspace_name      = "law-prod-001"
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

# Example 2: Development deployment with Linux Function Apps and relaxed thresholds
module "functionapps_alerts_development" {
  source = "../"

  windows_function_app_names       = []
  linux_function_app_names         = ["dev-func-001"]
  resource_group_name              = "rg-functions-dev"
  action_group_resource_group_name = "rg-actiongroups-dev"
  action_group                     = "ag-development-alerts"
  location                         = "East US"

  # Enable only critical alerts for development
  enable_function_execution_alerts = true
  enable_performance_alerts        = true
  enable_error_alerts              = true
  enable_resource_alerts           = false # Disabled for dev

  # Development thresholds - more relaxed
  function_execution_count_threshold   = 20000  # 20,000 executions
  function_execution_units_threshold   = 200000 # 200,000 MB-ms
  average_memory_working_set_threshold = 1500   # 1.5 GB
  response_time_threshold              = 10000  # 10 seconds
  response_time_critical_threshold     = 30000  # 30 seconds
  http_5xx_threshold                   = 50     # 50 server errors
  http_4xx_threshold                   = 200    # 200 client errors
  requests_threshold                   = 30000  # 30,000 requests

  # Diagnostic Settings - Only Log Analytics for dev
  enable_diagnostic_settings        = true
  log_analytics_workspace_name      = "law-dev-001"
  log_analytics_resource_group_name = "rg-monitoring-dev"

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

# Example 3: Basic deployment with mixed Function Apps and default values
module "functionapps_alerts_basic" {
  source = "../"

  windows_function_app_names       = ["basic-func-win-001"]
  linux_function_app_names         = ["basic-func-linux-001"]
  resource_group_name              = "rg-functions-basic"
  action_group_resource_group_name = "rg-actiongroups-basic"
  action_group                     = "ag-basic-alerts"
  location                         = "East US"

  # Use all default threshold values and alert enablement
  # Diagnostic settings disabled by default

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
