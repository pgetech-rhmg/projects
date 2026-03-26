/*
 * # AWS AppStream Directory Config Module
 * 
 * ✅ WHEN TO USE: For runtime domain joining with base images
 */
#  Filename    : aws/modules/appstream2/modules/directory_config/main.tf
#  Date         : 19 Aug 2022
#  Author      : TCS
#  Description : directory_config appstream2.0
# ⚠️  RUNTIME DOMAIN JOINING ONLY
# This resource configures Active Directory integration for fleet instances
# that need to join the domain at startup time (not for pre-joined images).

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}




resource "aws_appstream_directory_config" "directory_config" {
  directory_name                          = var.directory_name
  organizational_unit_distinguished_names = var.organizational_unit_names

  service_account_credentials {
    account_name     = var.account_name
    account_password = var.account_password
  }
}