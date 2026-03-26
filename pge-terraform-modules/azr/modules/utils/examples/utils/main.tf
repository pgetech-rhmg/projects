#
# Filename    : az/modules/utils/examples/main.tf
# Date        : 29 Jan 2026
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : example for sample azure utils module
#

# terraform version, provider versions
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

module "hello" {
  source = "../"
}

output "message" {
  value = module.hello.message
}
