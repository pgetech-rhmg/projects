# Connection Monitor Module Examples
# This example shows various configurations for Azure Connection Monitor AMBA Alerts

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

# Example 1: Production with strict thresholds
module "connection_monitor_alerts_production" {
  source = "../"

  # Required variables
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Connection Monitor resource IDs to monitor
  connection_monitor_ids = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus3/connectionMonitors/vpn-prod-monitor",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus3/connectionMonitors/expressroute-prod-monitor"
  ]

  # Strict thresholds for production
  checks_failed_threshold          = 5   # 5% failed checks warning
  checks_failed_critical_threshold = 25  # 25% failed checks critical
  latency_threshold_ms             = 50  # 50ms latency warning
  latency_critical_threshold_ms    = 200 # 200ms latency critical

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

# Example 2: Development with relaxed thresholds
module "connection_monitor_alerts_dev" {
  source = "../"

  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  connection_monitor_ids = [
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus3/connectionMonitors/vpn-dev-monitor"
  ]

  # Relaxed thresholds for development
  checks_failed_threshold          = 20  # 20% failed checks warning
  checks_failed_critical_threshold = 60  # 60% failed checks critical
  latency_threshold_ms             = 200 # 200ms latency warning
  latency_critical_threshold_ms    = 1000 # 1000ms latency critical

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

# Example 3: Basic monitoring with default thresholds
module "connection_monitor_alerts_basic" {
  source = "../"

  resource_group_name              = "rg-monitoring-test"
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "test-alerts-actiongroup"
  location                         = "West US 3"

  connection_monitor_ids = [
    "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus3/connectionMonitors/test-monitor"
  ]

  # Use default thresholds
  # checks_failed_threshold = 10 (default)
  # latency_threshold_ms = 100 (default)

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
