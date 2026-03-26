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
module "serverfarms_alerts_production" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-appservice-prod"
  serverfarm_names                 = ["asp-prod-001", "asp-prod-002"]
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "ag-appservice-prod"

  # Production thresholds - tighter monitoring
  cpu_percentage_threshold    = 80 # Alert at 80% CPU
  memory_percentage_threshold = 80 # Alert at 80% memory
  http_queue_length_threshold = 10 # Alert at 10 queued HTTP requests
  disk_queue_length_threshold = 10 # Alert at 10 queued disk operations

  # Diagnostic settings configuration
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "evhns-monitoring-prod"
  eventhub_name                     = "evh-appservice-logs"
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
module "serverfarms_alerts_development" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-appservice-dev"
  serverfarm_names                 = ["asp-dev-001"]
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "ag-appservice-dev"

  # Development thresholds - more relaxed
  cpu_percentage_threshold    = 90 # Alert at 90% CPU
  memory_percentage_threshold = 90 # Alert at 90% memory
  http_queue_length_threshold = 20 # Alert at 20 queued HTTP requests
  disk_queue_length_threshold = 20 # Alert at 20 queued disk operations

  # Diagnostic settings - Event Hub only
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-monitoring-dev"
  eventhub_name                    = "evh-appservice-logs"
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
module "serverfarms_alerts_basic" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-appservice-test"
  serverfarm_names                 = ["asp-test-001"]
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "ag-appservice-test"

  # Basic thresholds - only critical alerts
  cpu_percentage_threshold    = 95 # Alert at 95% CPU
  memory_percentage_threshold = 95 # Alert at 95% memory
  http_queue_length_threshold = 50 # Alert at 50 queued HTTP requests
  disk_queue_length_threshold = 50 # Alert at 50 queued disk operations

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
