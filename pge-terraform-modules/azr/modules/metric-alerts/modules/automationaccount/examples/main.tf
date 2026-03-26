# Automation Account Module Examples
# This example shows various configurations for Azure Automation Account AMBA Alerts

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

# Example 1: Production with all alerts and diagnostic settings
module "automation_account_alerts_production" {
  source = "../"

  # Required variables
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Automation Accounts to monitor
  automation_account_names = [
    "automation-prod-001",
    "automation-prod-002"
  ]

  # Subscription IDs for activity log alerts
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Automation Account resource IDs for scheduled query rules
  automation_account_resource_ids = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-automation-prod/providers/Microsoft.Automation/automationAccounts/automation-prod-001",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-automation-prod/providers/Microsoft.Automation/automationAccounts/automation-prod-002"
  ]

  # Enable all alert categories
  enable_automation_account_creation_alert = true
  enable_automation_account_deletion_alert = true
  enable_runbook_operations_alert          = true
  enable_hybrid_worker_alert               = true
  enable_update_deployment_alert           = true
  enable_webhook_alert                     = true
  enable_certificate_expiration_alert      = true

  # Enable diagnostic settings with both destinations
  enable_diagnostic_settings        = true
  log_analytics_workspace_name      = "law-monitoring-prod"
  log_analytics_resource_group_name = "rg-monitoring-prod"
  eventhub_namespace_name           = "evhns-siem-prod"
  eventhub_name                     = "evh-automation-logs"
  eventhub_authorization_rule_name  = "RootManageSharedAccessKey"
  eventhub_resource_group_name      = "rg-siem-prod"

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

# Example 2: Development with selective monitoring and Log Analytics only
module "automation_account_alerts_dev" {
  source = "../"

  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  automation_account_names = ["automation-dev-001"]

  subscription_ids = [
    "87654321-4321-4321-4321-210987654321"
  ]

  automation_account_resource_ids = [
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-automation-dev/providers/Microsoft.Automation/automationAccounts/automation-dev-001"
  ]

  # Enable only critical alerts
  enable_automation_account_creation_alert = true
  enable_automation_account_deletion_alert = true
  enable_runbook_operations_alert          = false
  enable_hybrid_worker_alert               = false
  enable_update_deployment_alert           = false
  enable_webhook_alert                     = false
  enable_certificate_expiration_alert      = false

  # Log Analytics only (no Event Hub)
  enable_diagnostic_settings        = true
  log_analytics_workspace_name      = "law-monitoring-dev"
  log_analytics_resource_group_name = "rg-monitoring-dev"
  eventhub_namespace_name           = ""
  eventhub_name                     = ""

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

# Example 3: Basic monitoring without diagnostic settings
module "automation_account_alerts_basic" {
  source = "../"

  resource_group_name              = "rg-monitoring-test"
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "test-alerts-actiongroup"
  location                         = "West US 3"

  automation_account_names = ["automation-test-001"]

  subscription_ids = [
    "11111111-1111-1111-1111-111111111111"
  ]

  automation_account_resource_ids = [
    "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-automation-test/providers/Microsoft.Automation/automationAccounts/automation-test-001"
  ]

  # Enable default alerts with default settings
  enable_automation_account_creation_alert = true
  enable_automation_account_deletion_alert = true
  enable_runbook_operations_alert          = true

  # No diagnostic settings
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
