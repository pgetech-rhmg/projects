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

# Example 1: Production deployment with all alerts enabled and strict thresholds
module "eventgrid_namespace_alerts_production" {
  source = "../"

  eventgrid_namespace_names          = ["prod-egns-001", "prod-egns-002"]
  resource_group_name                = "rg-monitoring-prod"
  action_group_resource_group_name   = "rg-actiongroups-prod"
  action_group                       = "ag-production-alerts"

  # MQTT Alerts
  enable_eventgrid_mqtt_published_alert = true
  eventgrid_mqtt_published_threshold    = 8000  # Stricter threshold for production

  enable_eventgrid_mqtt_failed_published_alert = true
  eventgrid_mqtt_failed_published_threshold    = 1

  enable_eventgrid_mqtt_connections_alert = true
  eventgrid_mqtt_connections_threshold    = 800  # Stricter threshold for production

  # HTTP Alerts
  enable_eventgrid_http_published_alert = true
  eventgrid_http_published_threshold    = 8000  # Stricter threshold for production

  enable_eventgrid_http_failed_published_alert = true
  eventgrid_http_failed_published_threshold    = 1

  # Delivery Alerts
  enable_eventgrid_delivery_attempts_failed_alert = true
  eventgrid_delivery_attempts_failed_threshold    = 1

  enable_eventgrid_delivery_attempts_succeeded_alert = true
  eventgrid_delivery_attempts_succeeded_threshold    = 8000  # Stricter threshold for production

  # Diagnostic Settings
  enable_diagnostic_settings = true
  
  # Event Hub Configuration
  eventhub_namespace_name          = "evhns-logs-prod"
  eventhub_name                    = "evh-diagnostics-prod"
  eventhub_resource_group_name     = "rg-monitoring-prod"
  
  # Log Analytics Configuration
  log_analytics_workspace_name           = "law-prod-001"
  log_analytics_resource_group_name      = "rg-monitoring-prod"

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

# Example 2: Development deployment with selective alerts and relaxed thresholds
module "eventgrid_namespace_alerts_development" {
  source = "../"

  eventgrid_namespace_names          = ["dev-egns-001"]
  resource_group_name                = "rg-monitoring-dev"
  action_group_resource_group_name   = "rg-actiongroups-dev"
  action_group                       = "ag-development-alerts"

  # Enable only critical alerts for development
  enable_eventgrid_mqtt_published_alert = false  # Disabled for dev
  enable_eventgrid_mqtt_failed_published_alert   = true
  eventgrid_mqtt_failed_published_threshold      = 5      # More relaxed for dev

  enable_eventgrid_mqtt_connections_alert = false  # Disabled for dev

  enable_eventgrid_http_published_alert = false  # Disabled for dev
  enable_eventgrid_http_failed_published_alert = true
  eventgrid_http_failed_published_threshold    = 5      # More relaxed for dev

  enable_eventgrid_delivery_attempts_failed_alert = true
  eventgrid_delivery_attempts_failed_threshold    = 10  # More relaxed for dev

  enable_eventgrid_delivery_attempts_succeeded_alert = false  # Disabled for dev

  # Diagnostic Settings - Only Log Analytics for dev
  enable_diagnostic_settings = true
  log_analytics_workspace_name           = "law-dev-001"
  log_analytics_resource_group_name      = "rg-monitoring-dev"

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
module "eventgrid_namespace_alerts_basic" {
  source = "../"

  eventgrid_namespace_names          = ["basic-egns-001"]
  resource_group_name                = "rg-monitoring-basic"
  action_group_resource_group_name   = "rg-actiongroups-basic"
  action_group                       = "ag-basic-alerts"

  # Use all default threshold values
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
