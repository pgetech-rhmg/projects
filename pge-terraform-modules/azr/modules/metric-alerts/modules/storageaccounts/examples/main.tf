# Examples for Azure Storage Account Monitoring Module

# Example 1: Production Storage Account Monitoring
# Complete monitoring with all 6 alerts enabled and tight thresholds for production accounts
module "storage_alerts_production" {
  source = "../"

  resource_group_name              = "rg-storage-prod"
  storage_account_names            = ["pgestgprod001", "pgestgprod002", "pgestgprod003"]
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations"

  # Performance thresholds (tight for production)
  storage_availability_threshold   = 99.9
  storage_capacity_threshold       = 85
  storage_transaction_threshold    = 15000
  storage_latency_threshold        = 500
  storage_server_latency_threshold = 50

  # Diagnostic settings (both Event Hub and Log Analytics)
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "evhns-monitoring-prod"
  eventhub_name                     = "evh-storage-logs-prod"
  eventhub_resource_group_name      = "rg-eventhub-prod"
  log_analytics_workspace_name      = "law-monitoring-prod"
  log_analytics_resource_group_name = "rg-loganalytics-prod"

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

# Example 2: Development Storage Account Monitoring
# Balanced monitoring with relaxed thresholds for development accounts
module "storage_alerts_development" {
  source = "../"

  resource_group_name              = "rg-storage-dev"
  storage_account_names            = ["pgestgdev001", "pgestgdev002"]
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "pge-operations"

  # Performance thresholds (relaxed for development)
  storage_availability_threshold   = 99
  storage_capacity_threshold       = 90
  storage_transaction_threshold    = 20000
  storage_latency_threshold        = 1000
  storage_server_latency_threshold = 100

  # Diagnostic settings (Event Hub only)
  enable_diagnostic_settings   = true
  eventhub_namespace_name      = "evhns-monitoring-dev"
  eventhub_name                = "evh-storage-logs-dev"
  eventhub_resource_group_name = "rg-eventhub-dev"

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

# Example 3: Basic Storage Account Monitoring
# Minimal monitoring with very relaxed thresholds for testing
module "storage_alerts_basic" {
  source = "../"

  resource_group_name              = "rg-storage-test"
  storage_account_names            = ["pgestgtest001"]
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "pge-operations"

  # Performance thresholds (very relaxed for testing)
  storage_availability_threshold   = 95
  storage_capacity_threshold       = 95
  storage_transaction_threshold    = 50000
  storage_latency_threshold        = 2000
  storage_server_latency_threshold = 200

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
