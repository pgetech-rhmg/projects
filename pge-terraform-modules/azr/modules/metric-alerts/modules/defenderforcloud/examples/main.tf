# Example: Microsoft Defender for Cloud Alerts Module Usage

provider "azurerm" {
  features {}
}

# Example 1: Production Environment with Comprehensive Security Monitoring
module "defender_alerts_production" {
  source = "../../defenderforcloud"

  resource_group_name                = "rg-security-monitoring-prod"
  action_group_resource_group_name   = "rg-security-monitoring-prod"
  action_group                       = "pge-security-actiongroup"
  location                           = "West US 2"

  # Monitor multiple production subscriptions
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]

  # Enable all alert categories for comprehensive security monitoring
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true

  # Monitor all Defender plans
  monitor_defender_for_servers          = true
  monitor_defender_for_app_service      = true
  monitor_defender_for_storage          = true
  monitor_defender_for_sql              = true
  monitor_defender_for_containers       = true
  monitor_defender_for_key_vault        = true
  monitor_defender_for_resource_manager = true
  monitor_defender_for_dns              = true

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

# Example 2: Development Environment with Selective Monitoring
module "defender_alerts_development" {
  source = "../../defenderforcloud"

  resource_group_name                = "rg-security-monitoring-dev"
  action_group_resource_group_name   = "rg-security-monitoring-dev"
  action_group                       = "pge-security-actiongroup"
  location                           = "West US 2"

  # Monitor single development subscription
  subscription_ids = [
    "11111111-2222-3333-4444-555555555555"
  ]

  # Enable main security monitoring
  enable_defender_plan_alerts = true
  enable_policy_alerts        = true

  # Monitor only essential Defender plans for dev environment
  monitor_defender_for_servers          = true
  monitor_defender_for_app_service      = true
  monitor_defender_for_storage          = true
  monitor_defender_for_sql              = true
  monitor_defender_for_containers       = true
  monitor_defender_for_key_vault        = false  # Optional in dev
  monitor_defender_for_resource_manager = true
  monitor_defender_for_dns              = false  # Optional in dev

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

# Example 3: Basic Configuration with Minimal Monitoring
module "defender_alerts_basic" {
  source = "../../defenderforcloud"

  resource_group_name                = "rg-security-monitoring-test"
  action_group_resource_group_name   = "rg-security-monitoring-test"
  action_group                       = "pge-security-actiongroup"
  location                           = "West US 2"

  # Monitor single test subscription
  subscription_ids = [
    "99999999-8888-7777-6666-555555555555"
  ]

  # Enable only Defender plan monitoring
  enable_defender_plan_alerts = true
  enable_policy_alerts        = false  # Disable policy alerts for simplicity

  # Monitor critical Defender plans only
  monitor_defender_for_servers          = true
  monitor_defender_for_app_service      = false
  monitor_defender_for_storage          = true
  monitor_defender_for_sql              = false
  monitor_defender_for_containers       = false
  monitor_defender_for_key_vault        = false
  monitor_defender_for_resource_manager = true
  monitor_defender_for_dns              = false

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
