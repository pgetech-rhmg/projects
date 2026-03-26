# Complete Example - Application Gateway AMBA Alerts Module
# This example shows all available configuration options including diagnostic settings

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

# Example 1: Complete configuration with custom thresholds and diagnostic settings
module "appgateway_alerts_production" {
  source = "../"

  # Required variables
  resource_group_name              = "rg-network-production"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 2"

  # Multiple Application Gateways
  application_gateway_names = [
    "appgw-prod-web-001",
    "appgw-prod-api-001",
    "appgw-prod-waf-001"
  ]

  # Custom v2 SKU thresholds
  appgw_compute_unit_threshold  = 10.0 # Alert at 10 compute units
  appgw_capacity_unit_threshold = 80   # Alert at 80 capacity units

  # Custom v1 SKU threshold
  appgw_cpu_utilization_threshold = 85 # Alert at 85% CPU

  # Health and error thresholds
  appgw_unhealthy_host_threshold  = 0   # Alert on any unhealthy host
  appgw_response_4xx_threshold    = 100 # Alert after 100 4xx responses
  appgw_response_5xx_threshold    = 5   # Alert after 5 5xx responses
  appgw_failed_requests_threshold = 50  # Alert after 50 failed requests

  # Performance thresholds (milliseconds)
  appgw_backend_response_time_threshold = 3000 # 3 seconds
  appgw_total_time_threshold            = 8000 # 8 seconds
  appgw_backend_connect_time_threshold  = 500  # 500ms

  # Throughput threshold (bytes per second)
  appgw_throughput_threshold = 200000000 # 200 MBps

  # Enable diagnostic settings with both Log Analytics and Event Hub
  enable_diagnostic_settings = true

  # Log Analytics workspace configuration
  log_analytics_workspace_name      = "law-monitoring-prod"
  log_analytics_resource_group_name = "rg-monitoring"
  log_analytics_subscription_id     = "" # Leave empty to use current subscription

  # Event Hub configuration for SIEM integration
  eventhub_namespace_name          = "evhns-siem-prod"
  eventhub_name                    = "evh-appgateway-logs"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"
  eventhub_resource_group_name     = "rg-siem"
  eventhub_subscription_id         = "" # Leave empty to use current subscription

  # Comprehensive tags
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

# Example 2: Log Analytics only (no Event Hub)
module "appgateway_alerts_dev" {
  source = "../"

  resource_group_name              = "rg-network-dev"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 2"

  application_gateway_names = ["appgw-dev-001"]

  # Enable diagnostic settings - Log Analytics only
  enable_diagnostic_settings        = true
  log_analytics_workspace_name      = "law-monitoring-dev"
  log_analytics_resource_group_name = "rg-monitoring"

  # Event Hub settings left blank - will not create Event Hub diagnostic settings
  eventhub_namespace_name = ""
  eventhub_name           = ""

  # Relaxed thresholds for development
  appgw_compute_unit_threshold          = 20
  appgw_unhealthy_host_threshold        = 3
  appgw_response_5xx_threshold          = 50
  appgw_failed_requests_threshold       = 500
  appgw_backend_response_time_threshold = 10000

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

# Example 3: Basic configuration without diagnostic settings
module "appgateway_alerts_basic" {
  source = "../"

  # Required variables
  resource_group_name              = "rg-network-test"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "test-alerts-actiongroup"
  location                         = "West US 2"

  # Single Application Gateway
  application_gateway_names = ["appgw-test-001"]

  # Disable diagnostic settings
  enable_diagnostic_settings = false

  tags = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "abc@pge.com"
    Compliance         = "SOX"
    Notify             = "abc@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    order              = "123456"
  }
}
