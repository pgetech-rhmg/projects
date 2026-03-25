terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-epic-terraform-state"
    storage_account_name = "pgeepicterraformstate"
    container_name       = "tfstate"
    key                  = "2d118b3d-8251-4f33-a681-c79ff46c5036/pge-php-example-php/dev/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
