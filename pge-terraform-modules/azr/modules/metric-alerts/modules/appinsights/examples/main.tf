# Application Insights Module Examples
# This example shows various configurations for Azure Application Insights AMBA Alerts

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

# Example 1: Production with all alert categories and diagnostic settings
module "appinsights_alerts_production" {
  source = "../"

  # Required variables
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Application Insights to monitor
  application_insights_names = [
    "appinsights-web-prod",
    "appinsights-api-prod"
  ]

  # Enable all alert categories
  enable_availability_alerts = true
  enable_performance_alerts  = true
  enable_error_alerts        = true
  enable_usage_alerts        = true
  enable_dependency_alerts   = true

  # Custom thresholds for production
  availability_threshold_percent    = 99.0 # 99% availability
  response_time_threshold_ms        = 2000 # 2 seconds
  server_response_time_threshold_ms = 1000 # 1 second
  exception_rate_threshold          = 10   # 10 exceptions per 5 min
  failed_requests_threshold         = 5    # 5 failed requests per 5 min
  dependency_failure_rate_threshold = 3    # 3 dependency failures per 5 min

  # Enable diagnostic settings with both destinations
  enable_diagnostic_settings        = true
  log_analytics_workspace_name      = "law-monitoring-prod"
  log_analytics_resource_group_name = "rg-monitoring-prod"
  eventhub_namespace_name           = "evhns-siem-prod"
  eventhub_name                     = "evh-appinsights-logs"
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
module "appinsights_alerts_dev" {
  source = "../"

  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  application_insights_names = ["appinsights-dev"]

  # Enable only critical alerts
  enable_availability_alerts = true
  enable_performance_alerts  = false
  enable_error_alerts        = true
  enable_usage_alerts        = false
  enable_dependency_alerts   = false

  # Relaxed thresholds for development
  availability_threshold_percent = 95.0 # 95% availability
  response_time_threshold_ms     = 5000 # 5 seconds
  exception_rate_threshold       = 50   # 50 exceptions
  failed_requests_threshold      = 20   # 20 failed requests

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
module "appinsights_alerts_basic" {
  source = "../"

  resource_group_name              = "rg-monitoring-test"
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "test-alerts-actiongroup"
  location                         = "West US 3"

  application_insights_names = ["appinsights-test"]

  # Enable default alerts with default thresholds
  enable_availability_alerts = true
  enable_performance_alerts  = true
  enable_error_alerts        = true
  enable_usage_alerts        = false
  enable_dependency_alerts   = false

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
