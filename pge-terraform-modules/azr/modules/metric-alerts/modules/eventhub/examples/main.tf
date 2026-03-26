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
module "eventhub_alerts_production" {
  source = "../"

  eventhub_namespace_names         = ["prod-evhns-001", "prod-evhns-002"]
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-actiongroups-prod"
  action_group                     = "ag-production-alerts"

  # Request Alerts
  enable_eventhub_incoming_requests_alert    = true
  eventhub_incoming_requests_threshold       = 8000  # Stricter threshold for production
  enable_eventhub_successful_requests_alert  = true
  eventhub_successful_requests_threshold     = 100   # Alert if successful requests drop below 100

  # Error Alerts
  enable_eventhub_server_errors_alert   = true
  eventhub_server_errors_threshold      = 1
  enable_eventhub_user_errors_alert     = true
  eventhub_user_errors_threshold        = 5
  enable_eventhub_throttled_requests_alert = true
  eventhub_throttled_requests_threshold    = 1
  enable_eventhub_quota_exceeded_alert = true
  eventhub_quota_exceeded_threshold    = 1

  # Message Alerts
  enable_eventhub_incoming_messages_alert = true
  eventhub_incoming_messages_threshold    = 80000  # Stricter threshold for production
  enable_eventhub_outgoing_messages_alert = true
  eventhub_outgoing_messages_threshold    = 80000  # Stricter threshold for production

  # Throughput Alerts
  enable_eventhub_incoming_bytes_alert = true
  eventhub_incoming_bytes_threshold    = 800000000  # 800 MB
  enable_eventhub_outgoing_bytes_alert = true
  eventhub_outgoing_bytes_threshold    = 800000000  # 800 MB

  # Connection Alerts
  enable_eventhub_active_connections_alert   = true
  eventhub_active_connections_threshold      = 4000  # Stricter threshold for production
  enable_eventhub_connections_opened_alert   = true
  eventhub_connections_opened_threshold      = 800   # Stricter threshold for production
  enable_eventhub_connections_closed_alert   = true
  eventhub_connections_closed_threshold      = 800   # Stricter threshold for production

  # Capacity Alert
  enable_eventhub_size_alert = true
  eventhub_size_threshold    = 8000000000  # 8 GB

  # Diagnostic Settings
  enable_diagnostic_settings     = true
  eventhub_namespace_name        = "evhns-logs-prod"
  eventhub_name                  = "evh-diagnostics-prod"
  eventhub_resource_group_name   = "rg-monitoring-prod"
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

# Example 2: Development deployment with selective alerts and relaxed thresholds
module "eventhub_alerts_development" {
  source = "../"

  eventhub_namespace_names         = ["dev-evhns-001"]
  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-actiongroups-dev"
  action_group                     = "ag-development-alerts"

  # Enable only critical alerts for development
  enable_eventhub_incoming_requests_alert = false  # Disabled for dev
  enable_eventhub_successful_requests_alert = false  # Disabled for dev

  # Error Alerts - more relaxed
  enable_eventhub_server_errors_alert   = true
  eventhub_server_errors_threshold      = 10
  enable_eventhub_user_errors_alert     = true
  eventhub_user_errors_threshold        = 50
  enable_eventhub_throttled_requests_alert = true
  eventhub_throttled_requests_threshold    = 10
  enable_eventhub_quota_exceeded_alert = false  # Disabled for dev

  # Message Alerts - disabled for dev
  enable_eventhub_incoming_messages_alert = false
  enable_eventhub_outgoing_messages_alert = false

  # Throughput Alerts - disabled for dev
  enable_eventhub_incoming_bytes_alert = false
  enable_eventhub_outgoing_bytes_alert = false

  # Connection Alerts - disabled for dev
  enable_eventhub_active_connections_alert = false
  enable_eventhub_connections_opened_alert = false
  enable_eventhub_connections_closed_alert = false

  # Capacity Alert
  enable_eventhub_size_alert = true
  eventhub_size_threshold    = 5000000000  # 5 GB - more relaxed for dev

  # Diagnostic Settings - Only Log Analytics for dev
  enable_diagnostic_settings            = true
  log_analytics_workspace_name          = "law-dev-001"
  log_analytics_resource_group_name     = "rg-monitoring-dev"

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
module "eventhub_alerts_basic" {
  source = "../"

  eventhub_namespace_names         = ["basic-evhns-001"]
  resource_group_name              = "rg-monitoring-basic"
  action_group_resource_group_name = "rg-actiongroups-basic"
  action_group                     = "ag-basic-alerts"

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
