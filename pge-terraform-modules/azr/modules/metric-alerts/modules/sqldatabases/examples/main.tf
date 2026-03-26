# Examples for Azure SQL Database Monitoring Module

# Example 1: Production SQL Database Monitoring
# Complete monitoring with tight thresholds for production databases
module "sql_db_alerts_production" {
  source = "../"

  resource_group_name = "rg-sqlserver-prod"
  sql_database_names = [
    "pge-sqlserver-prod-001/app-database-prod",
    "pge-sqlserver-prod-001/reporting-database-prod",
    "pge-sqlserver-prod-002/analytics-database-prod"
  ]
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations"

  # Performance thresholds (tight for production)
  cpu_percent_threshold                    = 75
  physical_data_read_percent_threshold     = 75
  log_write_percent_threshold              = 75
  sessions_percent_threshold               = 75
  workers_percent_threshold                = 75
  sqlserver_process_core_percent_threshold = 75
  tempdb_log_used_percent_threshold        = 80

  # Storage thresholds
  storage_percent_threshold     = 85
  storage_used_bytes_threshold  = 214748364800 # 200GB
  xtp_storage_percent_threshold = 85

  # Connection thresholds
  connection_successful_threshold = 5
  connection_failed_threshold     = 3

  # Health thresholds
  deadlock_threshold = 1

  # Diagnostic settings (both Event Hub and Log Analytics)
  enable_diagnostic_settings        = true
  eventhub_namespace_name           = "evhns-monitoring-prod"
  eventhub_name                     = "evh-sqldb-logs-prod"
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

# Example 2: Development SQL Database Monitoring
# Balanced monitoring with relaxed thresholds for development databases
module "sql_db_alerts_development" {
  source = "../"

  resource_group_name = "rg-sqlserver-dev"
  sql_database_names = [
    "pge-sqlserver-dev-001/app-database-dev",
    "pge-sqlserver-dev-001/test-database-dev"
  ]
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "pge-operations"

  # Performance thresholds (relaxed for development)
  cpu_percent_threshold                    = 85
  physical_data_read_percent_threshold     = 85
  log_write_percent_threshold              = 85
  sessions_percent_threshold               = 85
  workers_percent_threshold                = 85
  sqlserver_process_core_percent_threshold = 85
  tempdb_log_used_percent_threshold        = 90

  # Storage thresholds
  storage_percent_threshold     = 90
  storage_used_bytes_threshold  = 107374182400 # 100GB
  xtp_storage_percent_threshold = 90

  # Connection thresholds
  connection_successful_threshold = 3
  connection_failed_threshold     = 10

  # Health thresholds
  deadlock_threshold = 3

  # Diagnostic settings (Event Hub only)
  enable_diagnostic_settings   = true
  eventhub_namespace_name      = "evhns-monitoring-dev"
  eventhub_name                = "evh-sqldb-logs-dev"
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

# Example 3: Basic SQL Database Monitoring
# Minimal monitoring with very relaxed thresholds for testing
module "sql_db_alerts_basic" {
  source = "../"

  resource_group_name = "rg-sqlserver-test"
  sql_database_names = [
    "pge-sqlserver-test-001/app-database-test"
  ]
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "pge-operations"

  # Performance thresholds (very relaxed for testing)
  cpu_percent_threshold                    = 90
  physical_data_read_percent_threshold     = 90
  log_write_percent_threshold              = 90
  sessions_percent_threshold               = 90
  workers_percent_threshold                = 90
  sqlserver_process_core_percent_threshold = 90
  tempdb_log_used_percent_threshold        = 95

  # Storage thresholds
  storage_percent_threshold     = 95
  storage_used_bytes_threshold  = 53687091200 # 50GB
  xtp_storage_percent_threshold = 95

  # Connection thresholds
  connection_successful_threshold = 1
  connection_failed_threshold     = 20

  # Health thresholds
  deadlock_threshold = 5

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
