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
module "servicebus_alerts_production" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-servicebus-prod"
  servicebus_namespace_names       = ["sbns-prod-001", "sbns-prod-002"]
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "ag-servicebus-prod"

  # Enable all alerts with production thresholds
  enable_servicebus_incoming_requests_alert    = true
  enable_servicebus_successful_requests_alert  = true
  enable_servicebus_server_errors_alert        = true
  enable_servicebus_user_errors_alert          = true
  enable_servicebus_throttled_requests_alert   = true
  enable_servicebus_incoming_messages_alert    = true
  enable_servicebus_outgoing_messages_alert    = true
  enable_servicebus_active_connections_alert   = true
  enable_servicebus_connections_opened_alert   = true
  enable_servicebus_connections_closed_alert   = true
  enable_servicebus_size_alert                 = true
  enable_servicebus_active_messages_alert      = true
  enable_servicebus_dead_letter_messages_alert = true
  enable_servicebus_scheduled_messages_alert   = true

  # Production thresholds - tighter monitoring
  servicebus_incoming_requests_threshold    = 10000       # Alert at 10K requests/min
  servicebus_successful_requests_threshold  = 5           # Alert if successful < 5/min
  servicebus_server_errors_threshold        = 5           # Alert at 5 server errors/min
  servicebus_user_errors_threshold          = 10          # Alert at 10 user errors/min
  servicebus_throttled_requests_threshold   = 5           # Alert at 5 throttled requests/min
  servicebus_incoming_messages_threshold    = 10000       # Alert at 10K messages/min
  servicebus_outgoing_messages_threshold    = 10000       # Alert at 10K messages/min
  servicebus_active_connections_threshold   = 100         # Alert at 100 active connections
  servicebus_connections_opened_threshold   = 50          # Alert at 50 connections opened/min
  servicebus_connections_closed_threshold   = 50          # Alert at 50 connections closed/min
  servicebus_size_threshold                 = 85899345920 # Alert at 80GB
  servicebus_active_messages_threshold      = 1000        # Alert at 1000 active messages
  servicebus_dead_letter_messages_threshold = 10          # Alert at 10 dead letter messages
  servicebus_scheduled_messages_threshold   = 1000        # Alert at 1000 scheduled messages

  # Diagnostic settings configuration
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "evhns-monitoring-prod"
  eventhub_name                     = "evh-servicebus-logs"
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
module "servicebus_alerts_development" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-servicebus-dev"
  servicebus_namespace_names       = ["sbns-dev-001"]
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "ag-servicebus-dev"

  # Enable key alerts for development
  enable_servicebus_incoming_requests_alert    = true
  enable_servicebus_successful_requests_alert  = false # Disabled for dev
  enable_servicebus_server_errors_alert        = true
  enable_servicebus_user_errors_alert          = true
  enable_servicebus_throttled_requests_alert   = true
  enable_servicebus_incoming_messages_alert    = true
  enable_servicebus_outgoing_messages_alert    = true
  enable_servicebus_active_connections_alert   = false # Disabled for dev
  enable_servicebus_connections_opened_alert   = false # Disabled for dev
  enable_servicebus_connections_closed_alert   = false # Disabled for dev
  enable_servicebus_size_alert                 = true
  enable_servicebus_active_messages_alert      = true
  enable_servicebus_dead_letter_messages_alert = true
  enable_servicebus_scheduled_messages_alert   = false # Disabled for dev

  # Development thresholds - more relaxed
  servicebus_incoming_requests_threshold    = 20000        # Alert at 20K requests/min
  servicebus_server_errors_threshold        = 10           # Alert at 10 server errors/min
  servicebus_user_errors_threshold          = 20           # Alert at 20 user errors/min
  servicebus_throttled_requests_threshold   = 10           # Alert at 10 throttled requests/min
  servicebus_incoming_messages_threshold    = 20000        # Alert at 20K messages/min
  servicebus_outgoing_messages_threshold    = 20000        # Alert at 20K messages/min
  servicebus_size_threshold                 = 107374182400 # Alert at 100GB
  servicebus_active_messages_threshold      = 2000         # Alert at 2000 active messages
  servicebus_dead_letter_messages_threshold = 20           # Alert at 20 dead letter messages

  # Diagnostic settings - Event Hub only
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-monitoring-dev"
  eventhub_name                    = "evh-servicebus-logs"
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
module "servicebus_alerts_basic" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-servicebus-test"
  servicebus_namespace_names       = ["sbns-test-001"]
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "ag-servicebus-test"

  # Enable only critical alerts
  enable_servicebus_incoming_requests_alert    = true
  enable_servicebus_successful_requests_alert  = false
  enable_servicebus_server_errors_alert        = true
  enable_servicebus_user_errors_alert          = false
  enable_servicebus_throttled_requests_alert   = true
  enable_servicebus_incoming_messages_alert    = false
  enable_servicebus_outgoing_messages_alert    = false
  enable_servicebus_active_connections_alert   = false
  enable_servicebus_connections_opened_alert   = false
  enable_servicebus_connections_closed_alert   = false
  enable_servicebus_size_alert                 = true
  enable_servicebus_active_messages_alert      = false
  enable_servicebus_dead_letter_messages_alert = true
  enable_servicebus_scheduled_messages_alert   = false

  # Basic thresholds - very relaxed
  servicebus_incoming_requests_threshold    = 50000        # Alert at 50K requests/min
  servicebus_server_errors_threshold        = 20           # Alert at 20 server errors/min
  servicebus_throttled_requests_threshold   = 20           # Alert at 20 throttled requests/min
  servicebus_size_threshold                 = 128849018880 # Alert at 120GB
  servicebus_dead_letter_messages_threshold = 50           # Alert at 50 dead letter messages

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
