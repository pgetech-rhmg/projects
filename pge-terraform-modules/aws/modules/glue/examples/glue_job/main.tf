/*
* # AWS GLUE Job, Glue Connection, Glue Dev EndPoint, Glue Security Configuration and Glue Trigger with usage example
* Terraform module which creates SAF2.0 Glue Job with Glue Connection, Glue Security Configuration Glue Dev Endpoint and Glue Trigger resources in AWS.
* S3 VPC Gateway endpoint is a pre-requisite and must be existing to run this example. 
*/
#
# Filename    : modules/glue/examples/glue_job/main.tf
# Date        : 27 July 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue job with the Glue connection, Glue Security Configuration Glue Dev Endpoint and Glue Trigger.

locals {
  optional_tags = var.optional_tags
  aws_role      = var.aws_role
  name          = "${var.name}-${random_string.name.result}"
  Order         = var.Order
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
  Order              = local.Order
}

# SSM Parameters for Glue Connection

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_subnet" "selected" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

# Glue Job

module "glue_job" {
  source = "../../../glue"

  glue_job_name                   = local.name
  glue_job_role_arn               = module.glue_job_iam_role.arn
  glue_job_command                = var.glue_job_command
  glue_job_security_configuration = module.glue_security_configuration.glue_security_configuration_id
  glue_job_connections            = [module.glue_connection.glue_connection_id]
  tags                            = merge(module.tags.tags, local.optional_tags)
}

# IAM Role for Glue Job

module "glue_job_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = local.name
  aws_service = var.role_service
  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
  tags        = merge(module.tags.tags, local.optional_tags)
}

# Glue Connection

module "glue_connection" {
  source = "../../../glue/modules/glue-connection/"

  glue_connection_name = local.name
  glue_connection_type = var.glue_connection_type
  glue_connection_physical_connection_requirements = [
    {
      availability_zone      = var.availability_zone
      security_group_id_list = [module.security_group_glue.sg_id]
      subnet_id              = data.aws_ssm_parameter.subnet_id1.value
    }
  ]
  tags = merge(module.tags.tags, local.optional_tags)
}

# Glue Dev EndPoint

module "glue_dev_endpoint" {
  source = "../../../glue/modules/dev-endpoint"

  glue_dev_endpoint_name     = local.name
  glue_dev_endpoint_role_arn = module.glue_job_iam_role.arn

  glue_dev_endpoint_arguments                 = var.glue_dev_endpoint_arguments
  glue_dev_endpoint_extra_jars_s3_path        = var.glue_dev_endpoint_extra_jars_s3_path
  glue_dev_endpoint_extra_python_libs_s3_path = var.glue_dev_endpoint_extra_python_libs_s3_path
  glue_dev_endpoint_glue_version              = var.glue_dev_endpoint_glue_version
  dev_endpoint = {
    number_of_workers = var.glue_dev_endpoint_number_of_workers
    worker_type       = var.glue_dev_endpoint_worker_type
    number_of_nodes   = var.glue_dev_endpoint_number_of_nodes
  }
  glue_dev_endpoint_public_key             = var.glue_dev_endpoint_public_key
  glue_dev_endpoint_public_keys            = var.glue_dev_endpoint_public_keys
  glue_dev_endpoint_security_configuration = module.glue_security_configuration.glue_security_configuration_id
  glue_dev_endpoint_security_group_ids     = [module.security_group_glue.sg_id]
  glue_dev_endpoint_subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  tags                                     = merge(module.tags.tags, local.optional_tags)
}

# Security Group for Glue Connection and Glue Dev Endpoint

module "security_group_glue" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.0"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.selected.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "Security Group egress rules 1"
    },
    {
      from             = 0,
      to               = 65535,
      protocol         = "tcp",
      cidr_blocks      = var.cidr_blocks
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Security Group egress rules 2"
  }]

  security_group_ingress_rules = [{
    from                     = 0,
    to                       = 65535,
    protocol                 = "tcp",
    source_security_group_id = module.security_group_glue.sg_id
    description              = "Security Group Ingress rules 1",
  }]

  cidr_ingress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.selected.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "Security Group Ingress rules 2"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

# Glue Security Configuration

module "glue_security_configuration" {
  source = "../../../glue/modules/security-configuration/"

  glue_security_configuration_name          = local.name
  glue_cloudwatch_encryption_kms_key_arn    = module.kms_key.key_arn
  glue_job_bookmarks_encryption_kms_key_arn = module.kms_key.key_arn
  glue_s3_encryption_kms_key_arn            = module.kms_key.key_arn

}

# KMS Key

module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name     = local.name
  aws_role = local.aws_role
  kms_role = var.kms_role
  tags     = merge(module.tags.tags, local.optional_tags)
}

# Random String
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "glue_trigger" {
  source = "../../../glue/modules/glue-trigger/"

  glue_trigger_name = "${var.name}-${random_string.name.result}"
  glue_trigger_type = var.glue_trigger_type
  glue_trigger_actions = [{
    job_name = module.glue_job.glue_job_id
  }]
  glue_trigger_predicate = var.glue_trigger_predicate

  tags = merge(module.tags.tags, local.optional_tags)
}

# Scheduled Glue Trigger 

module "Scheduled_glue_trigger" {
  source = "../../../glue/modules/glue-trigger/"

  glue_trigger_name     = "${var.name}-scheduled-${random_string.name.result}"
  glue_trigger_type     = "SCHEDULED"
  glue_trigger_schedule = "cron(15 12 * * ? *)"
  glue_trigger_actions = [{
    job_name = module.glue_job.glue_job_id
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}