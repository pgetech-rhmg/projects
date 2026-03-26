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
module "sites_alerts_production" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-appservice-prod"
  windows_site_names               = ["app-win-prod-001", "app-win-prod-002"]
  linux_site_names                 = ["app-linux-prod-001"]
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "ag-appservice-prod"

  # Production thresholds - tighter monitoring
  availability_threshold           = 99.5  # Alert if availability < 99.5%
  response_time_threshold          = 3     # Alert at 3 seconds response time
  response_time_critical_threshold = 5     # Critical alert at 5 seconds
  http_4xx_threshold               = 10    # Alert at 10 client errors/min
  http_5xx_threshold               = 5     # Alert at 5 server errors/min
  request_rate_threshold           = 10000 # Alert at 10K requests/min
  cpu_time_threshold               = 60    # Alert at 60 seconds CPU time

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
module "sites_alerts_development" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-appservice-dev"
  windows_site_names               = ["app-win-dev-001"]
  linux_site_names                 = ["app-linux-dev-001"]
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "ag-appservice-dev"

  # Development thresholds - more relaxed
  availability_threshold           = 98    # Alert if availability < 98%
  response_time_threshold          = 5     # Alert at 5 seconds response time
  response_time_critical_threshold = 10    # Critical alert at 10 seconds
  http_4xx_threshold               = 20    # Alert at 20 client errors/min
  http_5xx_threshold               = 10    # Alert at 10 server errors/min
  request_rate_threshold           = 20000 # Alert at 20K requests/min
  cpu_time_threshold               = 120   # Alert at 120 seconds CPU time

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
module "sites_alerts_basic" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-appservice-test"
  windows_site_names               = ["app-win-test-001"]
  linux_site_names                 = []
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "ag-appservice-test"

  # Basic thresholds - very relaxed
  availability_threshold           = 95    # Alert if availability < 95%
  response_time_threshold          = 10    # Alert at 10 seconds response time
  response_time_critical_threshold = 20    # Critical alert at 20 seconds
  http_4xx_threshold               = 50    # Alert at 50 client errors/min
  http_5xx_threshold               = 20    # Alert at 20 server errors/min
  request_rate_threshold           = 50000 # Alert at 50K requests/min
  cpu_time_threshold               = 180   # Alert at 180 seconds CPU time

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
