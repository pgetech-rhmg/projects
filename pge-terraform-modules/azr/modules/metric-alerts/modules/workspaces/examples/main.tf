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

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = "PGE-Operations"
  resource_group_name = "rg-pge-monitoring-prod"
}

#======================================================================================
# Example 1: Production Log Analytics Workspaces with Full Monitoring
#======================================================================================

module "workspace_monitoring_production" {
  source = "../"

  resource_group_name              = "rg-pge-monitoring-prod"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Monitor multiple production workspaces
  workspace_names = [
    "law-pge-security-prod",
    "law-pge-operations-prod",
    "law-pge-applications-prod"
  ]

  # Custom tables to monitor
  workspace_custom_tables = [
    "SecurityEvents_CL",
    "ApplicationLogs_CL",
    "CustomMetrics_CL"
  ]

  # Enable all alerts
  enable_workspace_heartbeat_alert         = true
  enable_workspace_query_performance_alert = true
  enable_workspace_data_retention_alert    = true
  enable_workspace_error_rate_alert        = true
  enable_workspace_agent_connection_alert  = true
  enable_workspace_custom_table_alert      = true

  # Production thresholds (stricter)
  workspace_heartbeat_threshold         = 3     # More sensitive
  workspace_query_performance_threshold = 20000 # 20 seconds
  workspace_error_rate_threshold        = 5     # 5% error rate
  workspace_agent_connection_threshold  = 3     # More sensitive
  workspace_custom_table_threshold      = 50    # 50 MB minimum

  # Production retention settings
  workspace_retention_days         = 90
  workspace_retention_warning_days = 14

  # Diagnostic settings with both Event Hub and Log Analytics
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-pge-monitoring-prod"
  eventhub_name                    = "evh-workspace-logs"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"
  eventhub_resource_group_name     = "rg-pge-monitoring-prod"

  log_analytics_workspace_name      = "law-pge-central-prod"
  log_analytics_resource_group_name = "rg-pge-monitoring-prod"

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

#======================================================================================
# Example 2: Development Workspaces with Selective Monitoring
#======================================================================================

module "workspace_monitoring_development" {
  source = "../"

  resource_group_name              = "rg-pge-monitoring-dev"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Monitor development workspaces
  workspace_names = [
    "law-pge-dev",
    "law-pge-test"
  ]

  # Custom tables to monitor
  workspace_custom_tables = [
    "TestLogs_CL"
  ]

  # Enable core alerts only
  enable_workspace_heartbeat_alert         = true
  enable_workspace_query_performance_alert = true
  enable_workspace_data_retention_alert    = false # Not critical for dev
  enable_workspace_error_rate_alert        = true
  enable_workspace_agent_connection_alert  = false # Not critical for dev
  enable_workspace_custom_table_alert      = false # Not critical for dev

  # Development thresholds (more relaxed)
  workspace_heartbeat_threshold         = 10    # More lenient
  workspace_query_performance_threshold = 60000 # 60 seconds
  workspace_error_rate_threshold        = 20    # 20% error rate

  # Development retention settings
  workspace_retention_days         = 30
  workspace_retention_warning_days = 7

  # Diagnostic settings with Log Analytics only (cost optimized)
  enable_diagnostic_settings        = true
  eventhub_name                     = "" # Disabled
  log_analytics_workspace_name      = "law-pge-central-dev"
  log_analytics_resource_group_name = "rg-pge-monitoring-dev"

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

#======================================================================================
# Example 3: Basic Workspace Monitoring (Alerts Only)
#======================================================================================

module "workspace_monitoring_basic" {
  source = "../"

  resource_group_name              = "rg-pge-monitoring-test"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Monitor single test workspace
  workspace_names = [
    "law-pge-sandbox"
  ]

  # Enable minimal alerts
  enable_workspace_heartbeat_alert         = true
  enable_workspace_query_performance_alert = false
  enable_workspace_data_retention_alert    = false
  enable_workspace_error_rate_alert        = false
  enable_workspace_agent_connection_alert  = false
  enable_workspace_custom_table_alert      = false

  # Basic thresholds
  workspace_heartbeat_threshold = 10

  # No diagnostic settings (cost optimized for testing)
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
