# Examples for Azure SQL Managed Instance Monitoring Module

# Example 1: Production SQL MI Monitoring
# Complete monitoring with all 5 alerts enabled and tight thresholds for production instances
module "sqlmi_alerts_production" {
  source = "../"

  resource_group_name              = "rg-sqlmi-prod"
  sql_mi_names                     = ["pge-sqlmi-prod-001", "pge-sqlmi-prod-002"]
  sql_mi_resource_group            = "rg-sqlmi-prod"
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations"

  # Performance thresholds (tight for production)
  cpu_warning_threshold      = 70
  cpu_critical_threshold     = 85
  storage_warning_threshold  = 75
  storage_critical_threshold = 85

  # Alert evaluation settings
  evaluation_frequency = "PT5M"
  window_size          = "PT15M"

  # Diagnostic settings (both Event Hub and Log Analytics)
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "evhns-monitoring-prod"
  eventhub_name                     = "evh-sqlmi-logs-prod"
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

# Example 2: Development SQL MI Monitoring
# Balanced monitoring with relaxed thresholds for development instances
module "sqlmi_alerts_development" {
  source = "../"

  resource_group_name              = "rg-sqlmi-dev"
  sql_mi_names                     = ["pge-sqlmi-dev-001"]
  sql_mi_resource_group            = "rg-sqlmi-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "pge-operations"

  # Performance thresholds (relaxed for development)
  cpu_warning_threshold      = 80
  cpu_critical_threshold     = 90
  storage_warning_threshold  = 80
  storage_critical_threshold = 90

  # Alert evaluation settings
  evaluation_frequency = "PT5M"
  window_size          = "PT15M"

  # Diagnostic settings (Event Hub only)
  enable_diagnostic_settings   = true
  eventhub_namespace_name      = "evhns-monitoring-dev"
  eventhub_name                = "evh-sqlmi-logs-dev"
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

# Example 3: Basic SQL MI Monitoring
# Minimal monitoring with very relaxed thresholds for testing
module "sqlmi_alerts_basic" {
  source = "../"

  resource_group_name              = "rg-sqlmi-test"
  sql_mi_names                     = ["pge-sqlmi-test-001"]
  sql_mi_resource_group            = "rg-sqlmi-test"
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "pge-operations"

  # Performance thresholds (very relaxed for testing)
  cpu_warning_threshold      = 85
  cpu_critical_threshold     = 95
  storage_warning_threshold  = 85
  storage_critical_threshold = 95

  # Alert evaluation settings
  evaluation_frequency = "PT5M"
  window_size          = "PT15M"

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
