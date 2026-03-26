terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  tenant_id       = "44ae661a-ece6-41aa-bc96-7c2c85a08941"
  subscription_id = "ecfc6eff-38a3-462d-8fc8-6100ff878d8b"
}