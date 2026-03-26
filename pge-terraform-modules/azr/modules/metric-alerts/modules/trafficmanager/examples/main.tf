# Azure Traffic Manager Monitoring - Example Configurations
# This example demonstrates various deployment patterns for Traffic Manager profile monitoring

# =======================================================================================
# Data Sources - Common across all examples
# =======================================================================================

data "azurerm_monitor_action_group" "pge_operations" {
  name                = "PGE-Operations"
  resource_group_name = "rg-pge-monitoring-prod"
}

# =======================================================================================
# Example 1: Production Multi-Region Traffic Manager with Full Monitoring
# =======================================================================================
# This configuration monitors multiple Traffic Manager profiles with comprehensive alerting

module "trafficmanager_monitoring_production" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-trafficmanager-prod"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Traffic Manager Profiles to Monitor
  traffic_manager_profile_names = [
    "tm-pge-webapp-prod",
    "tm-pge-api-prod",
    "tm-pge-cdn-prod"
  ]

  # Subscription IDs for Activity Log Alerts
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Alert Thresholds
  endpoint_health_threshold                                           = 1
  probe_agent_current_endpoint_state_by_profile_resource_id_threshold = 1

  # Enable All Alerts
  enable_endpoint_health_alert               = true
  enable_probe_agent_monitoring_alert        = true
  enable_traffic_manager_creation_alert      = true
  enable_traffic_manager_deletion_alert      = true
  enable_traffic_manager_config_change_alert = true
  enable_endpoint_operations_alert           = true
  enable_dns_resolution_failure_alert        = true

  # Diagnostic Settings - Event Hub for SIEM Integration
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-pge-monitoring-prod"
  eventhub_name                    = "evh-trafficmanager-logs"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"
  eventhub_resource_group_name     = "rg-pge-monitoring-prod"
  eventhub_subscription_id         = ""

  # Diagnostic Settings - Log Analytics for Analysis
  log_analytics_workspace_name      = "law-pge-monitoring-prod"
  log_analytics_resource_group_name = "rg-pge-monitoring-prod"
  log_analytics_subscription_id     = ""

  # Time Windows
  window_duration_short       = "PT5M"
  window_duration_medium      = "PT15M"
  window_duration_long        = "PT1H"
  evaluation_frequency_high   = "PT1M"
  evaluation_frequency_medium = "PT5M"
  evaluation_frequency_low    = "PT15M"

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
# Example 2: Development Traffic Manager with Selective Monitoring
# =======================================================================================
# This configuration monitors development Traffic Manager profiles with reduced alert frequency

module "trafficmanager_monitoring_development" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-trafficmanager-dev"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Traffic Manager Profiles to Monitor
  traffic_manager_profile_names = [
    "tm-pge-webapp-dev",
    "tm-pge-api-dev"
  ]

  # Subscription IDs for Activity Log Alerts
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Alert Thresholds
  endpoint_health_threshold                                           = 1
  probe_agent_current_endpoint_state_by_profile_resource_id_threshold = 1

  # Enable Critical Alerts Only
  enable_endpoint_health_alert               = true
  enable_probe_agent_monitoring_alert        = true
  enable_traffic_manager_creation_alert      = false
  enable_traffic_manager_deletion_alert      = true
  enable_traffic_manager_config_change_alert = false
  enable_endpoint_operations_alert           = false
  enable_dns_resolution_failure_alert        = false

  # Diagnostic Settings - Log Analytics Only
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = ""
  eventhub_name                     = ""
  log_analytics_workspace_name      = "law-pge-monitoring-dev"
  log_analytics_resource_group_name = "rg-pge-monitoring-dev"
  log_analytics_subscription_id     = ""

  # Time Windows - Less Frequent
  window_duration_short       = "PT10M"
  window_duration_medium      = "PT30M"
  window_duration_long        = "PT2H"
  evaluation_frequency_high   = "PT5M"
  evaluation_frequency_medium = "PT15M"
  evaluation_frequency_low    = "PT30M"

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
# Example 3: Basic Traffic Manager Monitoring with Single Profile
# =======================================================================================
# This configuration monitors a single Traffic Manager profile with minimal alerting

module "trafficmanager_monitoring_basic" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-trafficmanager-test"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Single Traffic Manager Profile
  traffic_manager_profile_names = [
    "tm-pge-webapp-test"
  ]

  # Subscription IDs for Activity Log Alerts
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Alert Thresholds
  endpoint_health_threshold                                           = 1
  probe_agent_current_endpoint_state_by_profile_resource_id_threshold = 1

  # Enable Only Critical Alerts
  enable_endpoint_health_alert               = true
  enable_probe_agent_monitoring_alert        = false
  enable_traffic_manager_creation_alert      = false
  enable_traffic_manager_deletion_alert      = true
  enable_traffic_manager_config_change_alert = false
  enable_endpoint_operations_alert           = false
  enable_dns_resolution_failure_alert        = false

  # Disable Diagnostic Settings
  enable_diagnostic_settings = false

  # Time Windows - Default
  window_duration_short       = "PT5M"
  window_duration_medium      = "PT15M"
  window_duration_long        = "PT1H"
  evaluation_frequency_high   = "PT1M"
  evaluation_frequency_medium = "PT5M"
  evaluation_frequency_low    = "PT15M"

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
