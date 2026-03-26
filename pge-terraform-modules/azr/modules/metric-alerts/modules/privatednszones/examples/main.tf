# Azure Private DNS Zones Monitoring - Example Configurations
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
# Monitor multiple Private DNS zones with full alerting
# =======================================================================================

module "private_dns_alerts_production" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-network-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"
  location                         = "East US"

  # Private DNS zones to monitor
  dns_zone_names = [
    "privatelink.azurewebsites.net",
    "privatelink.database.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.vaultcore.azure.net"
  ]

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
# Monitor essential Private DNS zones for development environment
# =======================================================================================

module "private_dns_alerts_development" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-network-dev"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-dev-alerts"
  location                         = "East US"

  # Private DNS zones to monitor in dev
  dns_zone_names = [
    "privatelink.azurewebsites.net",
    "privatelink.database.windows.net"
  ]

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
# Monitor single critical Private DNS zone
# =======================================================================================

module "private_dns_alerts_basic" {
  source = "../"

  # Resource identification
  resource_group_name              = "rg-network-test"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-test-alerts"

  # Monitor single critical DNS zone
  dns_zone_names = [
    "privatelink.azurewebsites.net"
  ]

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
