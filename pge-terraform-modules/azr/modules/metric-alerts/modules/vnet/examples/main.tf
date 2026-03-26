# Azure Virtual Network Monitoring - Example Configurations
# This example demonstrates various deployment patterns for Virtual Network monitoring

# =======================================================================================
# Data Sources - Common across all examples
# =======================================================================================

data "azurerm_monitor_action_group" "pge_operations" {
  name                = "PGE-Operations"
  resource_group_name = "rg-pge-monitoring-prod"
}

# =======================================================================================
# Example 1: Production VNets with Full Monitoring
# =======================================================================================
# This configuration monitors production VNets with comprehensive DDoS protection alerting

module "vnet_monitoring_production" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-network-prod"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"

  # Virtual Networks to Monitor
  vnet_names = [
    "vnet-pge-hub-prod",
    "vnet-pge-spoke1-prod",
    "vnet-pge-spoke2-prod"
  ]

  # Alert Threshold - Detect any DDoS attack
  vnet_if_under_ddos_attack_threshold = 0

  # Diagnostic Settings - Event Hub for SIEM Integration
  enable_diagnostic_settings       = true
  eventhub_namespace_name          = "evhns-pge-monitoring-prod"
  eventhub_name                    = "evh-vnet-logs"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"
  eventhub_resource_group_name     = "rg-pge-monitoring-prod"
  eventhub_subscription_id         = ""

  # Diagnostic Settings - Log Analytics for Analysis
  log_analytics_workspace_name      = "law-pge-monitoring-prod"
  log_analytics_resource_group_name = "rg-pge-monitoring-prod"
  log_analytics_subscription_id     = ""

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
# Example 2: Development VNets with Selective Monitoring
# =======================================================================================
# This configuration monitors development VNets with Log Analytics only

module "vnet_monitoring_development" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-network-dev"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"

  # Virtual Networks to Monitor
  vnet_names = [
    "vnet-pge-hub-dev",
    "vnet-pge-spoke1-dev"
  ]

  # Alert Threshold - Detect any DDoS attack
  vnet_if_under_ddos_attack_threshold = 0

  # Diagnostic Settings - Log Analytics Only
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = ""
  eventhub_name                     = ""
  log_analytics_workspace_name      = "law-pge-monitoring-dev"
  log_analytics_resource_group_name = "rg-pge-monitoring-dev"
  log_analytics_subscription_id     = ""

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
# Example 3: Basic VNet Monitoring for Test Environment
# =======================================================================================
# This configuration provides minimal monitoring for test VNets

module "vnet_monitoring_basic" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-network-test"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"

  # Virtual Networks to Monitor
  vnet_names = [
    "vnet-pge-test"
  ]

  # Alert Threshold - Detect any DDoS attack
  vnet_if_under_ddos_attack_threshold = 0

  # Disable Diagnostic Settings
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
