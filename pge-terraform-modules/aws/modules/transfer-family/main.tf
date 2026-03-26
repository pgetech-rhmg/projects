/*
 * # AWS Transfer family server module.
 * Terraform module which creates SAF2.0 aws_transfer_server in AWS.
*/
#
#  Filename    : aws/modules/transfer-family/main.tf
#  Date        : 20 September 2022
#  Author      : TCS
#  Description : Transfer family server Creation for for SFTP Protocol and identity_provider_type "AWS_DIRECTORY_SERVICE" only.
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_transfer_server" "transfer_server" {
  domain    = var.domain
  protocols = ["SFTP"]

  dynamic "endpoint_details" {
    #The below optional block will run only if the value of 'endpoint_type' is 'VPC'.
    for_each = var.endpoint.endpoint_type == "VPC" ? [true] : []
    content {
      address_allocation_ids = var.endpoint.address_allocation_ids
      security_group_ids     = var.endpoint.security_group_ids
      subnet_ids             = var.endpoint.subnet_ids
      vpc_id                 = var.endpoint.vpc_id
    }
  }

  dynamic "endpoint_details" {
    #The below optional block will run only if the value of 'endpoint_type' is 'VPC_ENDPOINT'.
    for_each = var.endpoint.endpoint_type == "VPC_ENDPOINT" ? [true] : []
    content {
      vpc_endpoint_id = var.endpoint.vpc_endpoint_id
    }
  }

  #If the endpoint_type is set to VPC, the ec2:DescribeVpcEndpoints and ec2:ModifyVpcEndpoint actions are used.
  endpoint_type                    = var.endpoint.endpoint_type
  host_key                         = var.host_key
  identity_provider_type           = "AWS_DIRECTORY_SERVICE"
  directory_id                     = var.directory_id
  logging_role                     = var.logging_role
  post_authentication_login_banner = var.post_authentication_login_banner
  pre_authentication_login_banner  = var.pre_authentication_login_banner
  security_policy_name             = var.security_policy_name

  dynamic "workflow_details" {
    #The below optional block will execute only when the arguments execution_role and workflow_id have values.
    for_each = var.workflow.execution_role != null && var.workflow.workflow_id != null ? [true] : []
    content {
      dynamic "on_upload" {
        #The below optional block will execute only when the arguments execution_role and workflow_id have values.
        for_each = var.workflow.execution_role != null && var.workflow.workflow_id != null ? [true] : []
        content {
          execution_role = var.workflow.execution_role
          workflow_id    = var.workflow.workflow_id
        }
      }
    }
  }

  tags = local.module_tags
}