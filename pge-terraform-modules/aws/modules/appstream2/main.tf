/*
 * # AWS appstream2.0 Image_builder module.
 * Terraform module which creates SAF2.0 Appstream2.0 in AWS.
*/
#  Filename    : aws/modules/appstream-2.0/main.tf
#  Author      : TCS
#  Description : Image_builder appstream2.0

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : image_builder Creation
# Description : This terraform module creates a appstream-2.0 image_builder.

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_appstream_image_builder" "image_builder" {
  name                           = var.name
  description                    = coalesce(var.description, format("%s appstream Image builder description - Managed by Terraform", var.name))
  display_name                   = var.display_name
  enable_default_internet_access = var.vpce_id == null ? true : false
  image_name                     = var.image_name
  instance_type                  = var.instance_type
  appstream_agent_version        = var.appstream_agent_version
  iam_role_arn                   = var.iam_role_arn

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  # Access endpoint configuration - only created when using VPC endpoint
  # For internet access, this block is omitted
  dynamic "access_endpoint" {
    for_each = var.vpce_id != null && var.vpce_id != "" ? [1] : []
    content {
      endpoint_type = var.endpoint_type
      vpce_id       = var.vpce_id
    }
  }

  # ✅ DOMAIN JOIN INFO - REQUIRES AWS DIRECTORY SERVICE
  # This block allows image builders to join a Microsoft Active Directory domain
  # IMPORTANT: directory_name must match an existing AWS Directory Service directory
  # 
  # To find your directory name, run:
  # aws ds describe-directories --query 'DirectoryDescriptions[*].[Name,DirectoryId]' --output table
  # 
  # Use either:
  # - The Directory ID (d-xxxxxxxxxx), or  
  # - The exact Name from AWS Directory Service (not just domain FQDN)
  # 
  # Note: This is different from directory_config which is for fleet runtime domain joining
  dynamic "domain_join_info" {
    for_each = var.domain_join_info != null ? [var.domain_join_info] : []
    content {
      directory_name                         = domain_join_info.value.directory_name
      organizational_unit_distinguished_name = domain_join_info.value.organizational_unit_distinguished_name
    }
  }

  tags = local.module_tags
}