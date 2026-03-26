# Azure Monitor Resources Monitoring - Example Configurations
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
# High-sensitivity configuration with strict thresholds for all monitoring resources
# =======================================================================================

module "monitor_alerts_production" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-alerts"
  action_group                     = "ag-prod-alerts"
  location                         = "East US"

  # Subscription monitoring
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Log Analytics workspaces to monitor
  log_analytics_workspace_names = [
    "law-prod-001",
    "law-prod-002",
    "law-security-prod"
  ]

  # Application Insights resources to monitor
  application_insights_names = [
    "appi-web-prod",
    "appi-api-prod"
  ]

  # Data Collection Rules to monitor
  data_collection_rule_names = [
    "dcr-vm-insights-prod",
    "dcr-container-insights-prod"
  ]

  # Strict production thresholds for Log Analytics
  workspace_data_ingestion_threshold_gb          = 50  # 50GB warning
  workspace_data_ingestion_critical_threshold_gb = 100 # 100GB critical
  workspace_query_timeout_threshold_minutes      = 5   # 5 minutes

  # Strict production thresholds for Application Insights
  app_insights_availability_threshold_percent = 99.5 # 99.5% availability
  app_insights_response_time_threshold_ms     = 1000 # 1 second
  app_insights_failed_requests_threshold      = 10   # 10 failed requests
  app_insights_exception_rate_threshold       = 5    # 5 exceptions

  # Strict production thresholds for Data Collection Rules
  dcr_collection_failure_threshold_percent = 5  # 5% failure rate
  dcr_data_latency_threshold_minutes       = 10 # 10 minutes latency

  # Enable all alert categories
  enable_workspace_alerts            = true
  enable_application_insights_alerts = true
  enable_data_collection_alerts      = true
  enable_monitor_service_alerts      = true
  enable_diagnostic_settings_alerts  = true

  tags = {
    AppId              = "123456"
    Env                = "Prod"
    Owner              = "abc@pge.com"
    Compliance         = "SOC2"
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

module "monitor_alerts_development" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-alerts"
  action_group                     = "ag-dev-alerts"
  location                         = "East US"

  # Subscription monitoring
  subscription_ids = [
    "87654321-4321-4321-4321-210987654321"
  ]

  # Log Analytics workspaces to monitor
  log_analytics_workspace_names = [
    "law-dev-001"
  ]

  # Application Insights resources to monitor
  application_insights_names = [
    "appi-web-dev"
  ]

  # Data Collection Rules to monitor
  data_collection_rule_names = [
    "dcr-vm-insights-dev"
  ]

  # Relaxed development thresholds for Log Analytics
  workspace_data_ingestion_threshold_gb          = 100 # 100GB warning
  workspace_data_ingestion_critical_threshold_gb = 200 # 200GB critical
  workspace_query_timeout_threshold_minutes      = 15  # 15 minutes

  # Relaxed development thresholds for Application Insights
  app_insights_availability_threshold_percent = 95.0 # 95% availability
  app_insights_response_time_threshold_ms     = 3000 # 3 seconds
  app_insights_failed_requests_threshold      = 50   # 50 failed requests
  app_insights_exception_rate_threshold       = 20   # 20 exceptions

  # Relaxed development thresholds for Data Collection Rules
  dcr_collection_failure_threshold_percent = 15 # 15% failure rate
  dcr_data_latency_threshold_minutes       = 30 # 30 minutes latency

  # Enable all alert categories for dev
  enable_workspace_alerts            = true
  enable_application_insights_alerts = true
  enable_data_collection_alerts      = true
  enable_monitor_service_alerts      = false # Disable for dev
  enable_diagnostic_settings_alerts  = false # Disable for dev

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
# Minimal configuration with default thresholds, monitoring only critical resources
# =======================================================================================

module "monitor_alerts_basic" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-monitoring-test"
  action_group_resource_group_name = "rg-alerts"
  action_group                     = "ag-test-alerts"

  # Subscription monitoring
  subscription_ids = [
    "11111111-2222-3333-4444-555555555555"
  ]

  # Monitor only critical Log Analytics workspace
  log_analytics_workspace_names = [
    "law-test-001"
  ]

  # Monitor only critical Application Insights
  application_insights_names = [
    "appi-test-001"
  ]

  # No Data Collection Rules monitoring for basic
  data_collection_rule_names = []

  # Use default thresholds
  # workspace_data_ingestion_threshold_gb = 100 (default)
  # workspace_data_ingestion_critical_threshold_gb = 200 (default)
  # app_insights_availability_threshold_percent = 99.0 (default)
  # app_insights_response_time_threshold_ms = 2000 (default)
  # app_insights_failed_requests_threshold = 20 (default)
  # app_insights_exception_rate_threshold = 10 (default)

  # Enable only workspace and App Insights alerts
  enable_workspace_alerts            = true
  enable_application_insights_alerts = true
  enable_data_collection_alerts      = false
  enable_monitor_service_alerts      = false
  enable_diagnostic_settings_alerts  = false

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
