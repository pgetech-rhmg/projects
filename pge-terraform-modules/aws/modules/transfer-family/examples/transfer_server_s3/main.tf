/*
* # AWS Transfer Family with usage example
* Terraform module which creates Transfer server for s3 in AWS.
*/
#
# Filename    : modules/glue/examples/transfer_server_s3/main.tf
# Date        : 16 September 2022
# Author      : TCS
# Description : The Terraform usage example creates transfer server for s3.

locals {
  name = "${var.name}-${random_string.name.result}"
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_subnet" "transfer_family" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
# name     = local.name
# aws_role = var.aws_role
# kms_role = var.kms_role
# tags     = merge(module.tags.tags, var.optional_tags)
# }

module "transfer_server" {
  source = "../.."

  domain = "S3"
  endpoint = {
    endpoint_type      = var.endpoint_type
    security_group_ids = [module.security_group_transfer_server.sg_id]
    subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
    vpc_id             = data.aws_ssm_parameter.vpc_id.value
  }
  directory_id = var.directory_id
  logging_role = module.iam_transfer_role.arn
  workflow = {
    execution_role = module.iam_transfer_role.arn
    workflow_id    = module.transfer_workflow.transfer_workflow_id
  }
  tags = merge(module.tags.tags, var.optional_tags)
}

module "security_group_transfer_server" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 22,
    to               = 22,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_subnet.transfer_family.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  cidr_egress_rules = [{
    from             = 22,
    to               = 22,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_subnet.transfer_family.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

module "iam_transfer_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = local.name
  policy_arns   = var.policy_arns
  aws_service   = var.aws_service
  inline_policy = [templatefile("${path.module}/iam_policy.json", { account_num = data.aws_caller_identity.current.account_id, aws_region = data.aws_region.current.name })]
  tags          = merge(module.tags.tags, var.optional_tags)
}

module "transfer_workflow" {
  source = "../../modules/transfer-workflow"

  on_exception_steps = [{
    copy_step_details = {
      destination_file_location = {
        s3_file_location = {
          bucket = module.s3.id
          key    = aws_s3_object.s3_object.key
        }
      }
      name                 = "copy-${local.name}"
      source_file_location = var.source_file_location
    }
    type = var.type1
    },
    {
      custom_step_details = {
        name                 = "custom-${local.name}"
        source_file_location = var.source_file_location
        target               = module.lambda_function.lambda_arn
        timeout_seconds      = var.timeout_seconds
      }
      type = var.type2
    },
    {
      delete_step_details = {
        name                 = "delete-${local.name}"
        source_file_location = var.source_file_location
      }
      type = var.type3
    },
    {
      tag_step_details = {
        name                 = "tag-${local.name}"
        source_file_location = var.source_file_location
        tags = [{
          key   = "id",
          value = "1"
          },
          {
            key   = "name",
            value = "test"
        }]
      }
      type = var.type4
  }]

  steps = [{
    copy_step_details = {
      destination_file_location = {
        s3_file_location = {
          bucket = module.s3.id
          key    = aws_s3_object.s3_object.key
        }
      }
      name                 = "copy-${local.name}"
      source_file_location = var.source_file_location
    }
    type = var.type1
    },
    {
      custom_step_details = {
        name                 = "custom-${local.name}"
        source_file_location = var.source_file_location
        target               = module.lambda_function.lambda_arn
        timeout_seconds      = var.timeout_seconds
      }
      type = var.type2
    },
    {
      delete_step_details = {
        name                 = "delete-${local.name}"
        source_file_location = var.source_file_location
      }
      type = var.type3
    },
    {
      tag_step_details = {
        name                 = "tag-${local.name}"
        source_file_location = var.source_file_location
        tags = [{
          key   = "id",
          value = "1"
          },
          {
            key   = "name",
            value = "test"
        }]
      }
      type = var.type4
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation if the DataClassification is not Internal/Public
  tags        = merge(module.tags.tags, var.optional_tags)
}

resource "aws_s3_object" "s3_object" {
  bucket = module.s3.id
  key    = "${path.module}/${var.bucket_object_key}"
}

module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = local.name
  role          = module.iam_transfer_role.arn
  description   = var.description
  runtime       = var.runtime
  source_code = {
    source_dir = "${path.module}/${var.local_zip_source_directory}"
  }
  tags                          = merge(module.tags.tags, var.optional_tags)
  vpc_config_security_group_ids = [module.security_group_transfer_server.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
}

module "transfer_access" {
  source = "../../modules/transfer-access"

  external_id    = var.external_id
  server_id      = module.transfer_server.transfer_server_id
  home_directory = "/${module.s3.id}/"
  role           = module.iam_transfer_role.arn
}