# App Service Environment Module Examples
# This example shows various configurations for Azure App Service Environment AMBA Alerts

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

# Example 1: Production with all alerts and diagnostic settings
module "ase_alerts_production" {
  source = "../"

  # Required variables
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations-actiongroup"

  # App Service Environments to monitor
  ase_names = [
    "ase-prod-001",
    "ase-prod-002"
  ]

  # Custom thresholds for production
  ase_cpu_percentage_threshold                    = 75  # 75% CPU
  ase_memory_percentage_threshold                 = 80  # 80% memory
  ase_large_app_service_plan_instances_threshold  = 10  # 10 large instances
  ase_medium_app_service_plan_instances_threshold = 12  # 12 medium instances
  ase_small_app_service_plan_instances_threshold  = 20  # 20 small instances
  ase_average_response_time_threshold             = 3   # 3 seconds
  ase_http_5xx_threshold                          = 10  # 10 5xx errors
  ase_http_4xx_threshold                          = 50  # 50 4xx errors
  ase_http_queue_length_threshold                 = 100 # 100 queued requests

  # Enable diagnostic settings with both destinations
  enable_diagnostic_settings        = true
  log_analytics_workspace_name      = "law-monitoring-prod"
  log_analytics_resource_group_name = "rg-monitoring-prod"
  eventhub_namespace_name           = "evhns-siem-prod"
  eventhub_name                     = "evh-ase-logs"
  eventhub_authorization_rule_name  = "RootManageSharedAccessKey"
  eventhub_resource_group_name      = "rg-siem-prod"

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

# Example 2: Development with relaxed thresholds and Log Analytics only
module "ase_alerts_dev" {
  source = "../"

  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "dev-alerts-actiongroup"

  ase_names = ["ase-dev-001"]

  # Relaxed thresholds for development
  ase_cpu_percentage_threshold        = 85  # 85% CPU
  ase_memory_percentage_threshold     = 85  # 85% memory
  ase_average_response_time_threshold = 10  # 10 seconds
  ase_http_5xx_threshold              = 50  # 50 5xx errors
  ase_http_queue_length_threshold     = 200 # 200 queued requests

  # Log Analytics only (no Event Hub)
  enable_diagnostic_settings        = true
  log_analytics_workspace_name      = "law-monitoring-dev"
  log_analytics_resource_group_name = "rg-monitoring-dev"
  eventhub_namespace_name           = ""
  eventhub_name                     = ""

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

# Example 3: Basic monitoring without diagnostic settings
module "ase_alerts_basic" {
  source = "../"

  resource_group_name              = "rg-monitoring-test"
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "test-alerts-actiongroup"

  ase_names = ["ase-test-001"]

  # Use default thresholds for all alerts

  # No diagnostic settings
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
