# Compute Gallery Module Examples
# This example shows various configurations for Azure Compute Gallery AMBA Alerts

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

# Example 1: Production with all alerts enabled
module "compute_gallery_alerts_production" {
  source = "../"

  # Required variables
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-monitoring-prod"
  action_group                     = "pge-operations-actiongroup"
  location                         = "West US 3"

  # Subscription IDs for activity log alerts
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # Enable all alert categories
  enable_gallery_creation_alert     = true
  enable_gallery_deletion_alert     = true
  enable_gallery_modification_alert = true
  enable_image_definition_alert     = true
  enable_image_version_alert        = true
  enable_sharing_profile_alert      = true
  enable_access_control_alert       = true

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

# Example 2: Development with selective monitoring
module "compute_gallery_alerts_dev" {
  source = "../"

  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-monitoring-dev"
  action_group                     = "dev-alerts-actiongroup"
  location                         = "West US 3"

  subscription_ids = [
    "87654321-4321-4321-4321-210987654321"
  ]

  # Enable only critical alerts
  enable_gallery_creation_alert     = true
  enable_gallery_deletion_alert     = true
  enable_gallery_modification_alert = false
  enable_image_definition_alert     = false
  enable_image_version_alert        = false
  enable_sharing_profile_alert      = false
  enable_access_control_alert       = true

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

# Example 3: Basic monitoring with default settings
module "compute_gallery_alerts_basic" {
  source = "../"

  resource_group_name              = "rg-monitoring-test"
  action_group_resource_group_name = "rg-monitoring-test"
  action_group                     = "test-alerts-actiongroup"
  location                         = "West US 3"

  subscription_ids = [
    "11111111-1111-1111-1111-111111111111"
  ]

  # Use default alert settings (all enabled by default)

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
