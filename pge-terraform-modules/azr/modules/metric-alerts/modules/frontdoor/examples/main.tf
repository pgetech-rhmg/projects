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

# Example 1: Production deployment with Standard/Premium Front Door and strict thresholds
module "frontdoor_alerts_production" {
  source = "../"

  front_door_names                 = ["prod-fd-001", "prod-fd-002"]
  resource_group_name              = "rg-cdn-prod"
  action_group_resource_group_name = "rg-actiongroups-prod"
  action_group                     = "ag-production-alerts"
  location                         = "East US"
  front_door_type                  = "standard"

  # Enable all alert categories
  enable_performance_alerts  = true
  enable_availability_alerts = true
  enable_security_alerts     = true
  enable_cost_alerts         = true

  # Production thresholds - strict monitoring
  response_time_threshold    = 3000   # 3 seconds
  backend_health_threshold   = 90     # 90% backend health
  request_count_threshold    = 8000   # 8,000 requests
  error_rate_threshold       = 3      # 3% error rate
  availability_threshold     = 99.9   # 99.9% availability
  waf_blocked_requests_threshold = 100    # 100 blocked requests

  # Diagnostic Settings
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "evhns-logs-prod"
  eventhub_name                     = "evh-diagnostics-prod"
  eventhub_resource_group_name      = "rg-monitoring-prod"
  eventhub_authorization_rule_name  = "RootManageSharedAccessKey"
  
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

# Example 2: Development deployment with Classic Front Door and relaxed thresholds
module "frontdoor_alerts_development" {
  source = "../"

  front_door_names                 = ["dev-fd-001"]
  resource_group_name              = "rg-cdn-dev"
  action_group_resource_group_name = "rg-actiongroups-dev"
  action_group                     = "ag-development-alerts"
  location                         = "East US"
  front_door_type                  = "classic"

  # Enable only critical alerts for development
  enable_performance_alerts  = true
  enable_availability_alerts = true
  enable_security_alerts     = false  # Disabled for dev
  enable_cost_alerts         = false  # Disabled for dev

  # Development thresholds - more relaxed
  response_time_threshold    = 10000  # 10 seconds
  backend_health_threshold   = 70     # 70% backend health
  request_count_threshold    = 20000  # 20,000 requests
  error_rate_threshold       = 10     # 10% error rate
  availability_threshold     = 95.0   # 95% availability

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

# Example 3: Basic deployment with default values
module "frontdoor_alerts_basic" {
  source = "../"

  front_door_names                 = ["basic-fd-001"]
  resource_group_name              = "rg-cdn-basic"
  action_group_resource_group_name = "rg-actiongroups-basic"
  action_group                     = "ag-basic-alerts"
  location                         = "East US"
  front_door_type                  = "standard"

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
