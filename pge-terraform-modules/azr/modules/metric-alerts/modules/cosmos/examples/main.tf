# Example: Cosmos DB Metric Alerts Module Usage

provider "azurerm" {
  features {}
}

# Example 1: Production Environment with Strict Thresholds
module "cosmos_alerts_production" {
  source = "../../cosmos"

  resource_group_name                = "rg-cosmos-prod"
  action_group_resource_group_name   = "rg-monitoring-prod"
  action_group                       = "pge-operations-actiongroup"
  
  cosmos_account_names = [
    "cosmos-app-prod-eastus",
    "cosmos-app-prod-westus"
  ]

  # Strict production thresholds
  cosmos_availability_threshold                = 99.99
  cosmos_server_side_latency_threshold         = 5
  cosmos_ru_consumption_threshold              = 8000
  cosmos_normalized_ru_consumption_threshold   = 70
  cosmos_total_requests_threshold              = 8000
  cosmos_metadata_requests_threshold           = 50
  cosmos_data_usage_threshold                  = 75000000000  # 70 GB
  cosmos_index_usage_threshold                 = 8589934592   # 8 GB
  cosmos_provisioned_throughput_threshold      = 35000

  # Enable all alert categories
  enable_availability_alerts   = true
  enable_performance_alerts    = true
  enable_error_alerts         = true
  enable_capacity_alerts      = true

  # Diagnostic settings
  enable_diagnostic_settings           = true
  eventhub_namespace_name              = "evhns-monitoring-prod"
  eventhub_name                        = "evh-cosmos-logs"
  eventhub_authorization_rule_name     = "RootManageSharedAccessKey"
  log_analytics_workspace_name         = "law-security-prod"
  
  # Cross-subscription support (if needed)
  # eventhub_subscription_id            = "00000000-0000-0000-0000-000000000000"
  # eventhub_resource_group_name        = "rg-eventhub-prod"
  # log_analytics_subscription_id       = "00000000-0000-0000-0000-000000000000"
  # log_analytics_resource_group_name   = "rg-loganalytics-prod"

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

# Example 2: Development Environment with Relaxed Thresholds
module "cosmos_alerts_development" {
  source = "../../cosmos"

  resource_group_name                = "rg-cosmos-dev"
  action_group_resource_group_name   = "rg-monitoring-dev"
  action_group                       = "pge-operations-actiongroup"
  
  cosmos_account_names = [
    "cosmos-app-dev-eastus"
  ]

  # Relaxed development thresholds
  cosmos_availability_threshold                = 99.0
  cosmos_server_side_latency_threshold         = 20
  cosmos_ru_consumption_threshold              = 15000
  cosmos_normalized_ru_consumption_threshold   = 90
  cosmos_total_requests_threshold              = 15000
  cosmos_metadata_requests_threshold           = 150
  cosmos_data_usage_threshold                  = 107374182400  # 100 GB
  cosmos_index_usage_threshold                 = 15000000000   # ~14 GB
  cosmos_provisioned_throughput_threshold      = 50000

  # Enable diagnostic settings
  enable_diagnostic_settings           = true
  eventhub_namespace_name              = "evhns-monitoring-dev"
  eventhub_name                        = "evh-cosmos-logs"
  log_analytics_workspace_name         = "law-security-dev"

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

# Example 3: Basic Configuration with Default Thresholds
module "cosmos_alerts_basic" {
  source = "../../cosmos"

  resource_group_name                = "rg-cosmos-test"
  action_group_resource_group_name   = "rg-monitoring-test"
  action_group                       = "pge-operations-actiongroup"
  
  cosmos_account_names = [
    "cosmos-app-test"
  ]

  # Use default thresholds (defined in variables.tf)
  # Diagnostic settings disabled
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
