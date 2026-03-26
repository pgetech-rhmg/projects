# Action Groups Module Examples
# This example shows various configurations for Azure Monitor Action Groups

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

# Example 1: Basic production action groups
module "action_groups_production" {
  source = "../"

  action_groups = [
    {
      name                = "pge-operations-actiongroup"
      short_name          = "pge-ops"
      resource_group_name = "rg-monitoring-prod"
      location            = "global"
      enabled             = true
      email_addresses = [
        "ops-team@example.com",
        "oncall@example.com"
      ]
    },
    {
      name                = "pge-security-actiongroup"
      short_name          = "pge-sec"
      resource_group_name = "rg-monitoring-prod"
      location            = "global"
      enabled             = true
      email_addresses = [
        "security-team@example.com",
        "soc@example.com"
      ]
    }
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

# Example 2: Development environment with single action group
module "action_groups_dev" {
  source = "../"

  action_groups = [
    {
      name                = "dev-alerts-actiongroup"
      short_name          = "dev-alerts"
      resource_group_name = "rg-monitoring-dev"
      location            = "global"
      enabled             = true
      email_addresses = [
        "dev-team@example.com"
      ]
    }
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

# Example 3: Multiple regional action groups
module "action_groups_regional" {
  source = "../"

  action_groups = [
    {
      name                = "westus-ops-actiongroup"
      short_name          = "westus-ops"
      resource_group_name = "rg-monitoring-westus"
      location            = "global"
      enabled             = true
      email_addresses = [
        "westus-ops@example.com"
      ]
    },
    {
      name                = "eastus-ops-actiongroup"
      short_name          = "eastus-ops"
      resource_group_name = "rg-monitoring-eastus"
      location            = "global"
      enabled             = true
      email_addresses = [
        "eastus-ops@example.com"
      ]
    }
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
