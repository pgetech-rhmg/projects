# Azure Key Vault Monitoring - Example Configurations
# This file demonstrates three deployment patterns: Production, Development, and Basic

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
# Example 1: Production Deployment
# High-sensitivity configuration with strict thresholds and full diagnostic settings
# =======================================================================================

module "keyvault_alerts_production" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-keyvault-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  # Key Vault names to monitor
  key_vault_names = [
    "kv-app-prod-001",
    "kv-app-prod-002",
    "kv-secrets-prod"
  ]

  # Strict production thresholds
  availability_threshold        = 99.9 # 99.9% availability
  service_api_latency_threshold = 500  # 500ms latency
  service_api_hit_threshold     = 2000 # 2000 API hits
  service_api_result_threshold  = 5    # 5 API errors
  saturation_shoebox_threshold  = 75   # 75% saturation

  # Diagnostic settings with cross-subscription support
  enable_diagnostic_settings = true

  # EventHub for activity logs (different subscription)
  eventhub_subscription_id         = "87654321-4321-4321-4321-210987654321"
  eventhub_namespace_name          = "evhns-logging-prod"
  eventhub_name                    = "evh-keyvault-logs"
  eventhub_resource_group_name     = "rg-logging"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"

  # Log Analytics for security logs (different subscription)
  log_analytics_subscription_id     = "11111111-2222-3333-4444-555555555555"
  log_analytics_workspace_name      = "law-security-prod"
  log_analytics_resource_group_name = "rg-security"

  tags = {
    AppId              = "123456"
    Env                = "Prod"
    Owner              = "abc@pge.com"
    Compliance         = "PCI-DSS"
    Notify             = "abc@pge.com"
    DataClassification = "confidential"
    CRIS               = "1"
    order              = "123456"
  }
}

# =======================================================================================
# Example 2: Development Deployment
# Relaxed configuration for development and testing environments
# =======================================================================================

module "keyvault_alerts_development" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-keyvault-dev"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-dev-alerts"

  # Key Vault names to monitor
  key_vault_names = [
    "kv-app-dev-001"
  ]

  # Relaxed development thresholds
  availability_threshold        = 95.0 # 95% availability
  service_api_latency_threshold = 2000 # 2000ms latency
  service_api_hit_threshold     = 5000 # 5000 API hits
  service_api_result_threshold  = 20   # 20 API errors
  saturation_shoebox_threshold  = 85   # 85% saturation

  # Diagnostic settings (same subscription)
  enable_diagnostic_settings = true

  eventhub_namespace_name      = "evhns-logging-dev"
  eventhub_name                = "evh-keyvault-logs"
  eventhub_resource_group_name = "rg-logging-dev"

  log_analytics_workspace_name      = "law-monitoring-dev"
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

# =======================================================================================
# Example 3: Basic Deployment
# Minimal configuration with default thresholds and no diagnostic settings
# =======================================================================================

module "keyvault_alerts_basic" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-keyvault-test"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-test-alerts"

  # Key Vault names to monitor
  key_vault_names = [
    "kv-test-001"
  ]

  # Use default thresholds
  # availability_threshold = 99.9 (default)
  # service_api_latency_threshold = 1000 (default)
  # service_api_hit_threshold = 1000 (default)
  # service_api_result_threshold = 10 (default)
  # saturation_shoebox_threshold = 75 (default)

  # Disable diagnostic settings for basic deployment
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
