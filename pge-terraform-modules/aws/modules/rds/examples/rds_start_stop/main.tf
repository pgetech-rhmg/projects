#  Filename    : modules/rds/examples/rds_start_stop/main.tf
#  Date        : 26/8/2024
#  Author      : PGE
#  Description : RDS start/stop main file.
/********************************************** RDS Auto Start Stop *********************************************/
## auto start stop variables, enable auto start and auto stop by setting autostart and autostop to "yes"
## when the value is set to "yes", the rds instance will be started and stopped as per the schedule defined in the schedule_rds_auto_start and schedule_rds_auto_stop variables
## the schedule_rds_auto_start and schedule_rds_auto_stop variables are in cron format
## the cron format is "cron(minute hour day month weekday)"
## for example, to start the rds instance every monday at 12:32 PM, set the schedule_rds_auto_start variable to "cron(32 12 ? * MON *)"
## UTC time is used for the cron schedule
## to stop the rds instance every sunday at 9:30 PM, set the schedule_rds_auto_stop variable to "cron(30 21 ? * SUN *)"
## the cron format is explained in detail at https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
## the autostart and autostop variables are optional, by default the values are set to "no"
## the schedule_rds_auto_start and schedule_rds_auto_stop variables are optional, by default the values are set to null
## these variables are used by rds-start-stop module which uses lambda and cloudwatch event to start and stop the rds instance as per the schedule

terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}


locals {
  # ports and protocol
  ingress_lambda = [
    { port : 80, protocol : "tcp" },
    { port : 443, protocol : "tcp" }
  ]
}

locals {
  aws_role    = var.aws_role
  account_num = var.account_num
  user        = var.user

}

data "aws_ssm_parameter" "private_subnet1_id" {
  name = "/vpc/2/privatesubnet1/id"
}
data "aws_ssm_parameter" "private_subnet2_id" {
  name = "/vpc/2/privatesubnet2/id"
}
data "aws_ssm_parameter" "private_subnet3_id" {
  name = "/vpc/2/privatesubnet3/id"
}
data "aws_ssm_parameter" "vpc_cidr_1" {
  name = "/vpc/cidr"
}
data "aws_ssm_parameter" "vpc_cidr_2" {
  name = "/vpc/2/cidr"
}
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

#inline policy
data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions = [
      "rds:StartDBCluster",
      "rds:StopDBCluster",
      "rds:ListTagsForResource",
      "rds:DescribeDBInstances",
      "rds:StopDBInstance",
      "rds:DescribeDBClusters",
      "rds:StartDBInstance"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

#######################################################################################################
# module rds start/stop
#######################################################################################################

module "rds_start_stop" {
  source                        = "../../modules/rds-start-stop"
  rds_auto_control_service_name = var.rds_auto_control_service_name
  iam_role_start_stop           = module.iam_role_rds_auto_start_stop.arn
  lambda_runtime                = var.lambda_runtime
  lambda_timeout                = var.lambda_timeout
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.private_subnet1_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet3_id.value]
  schedule_rds_auto_start       = var.schedule_rds_auto_start
  schedule_rds_auto_stop        = var.schedule_rds_auto_stop
  tags                          = merge(module.tags.tags, local.optional_tags)


}


########################################################################################################
# VPC Endpoint - Lambda requires VPCe to communicate with RDS
########################################################################################################

module "vpc_endpoint_rds" {
  source              = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version             = "0.1.1"
  service_name        = var.service_name
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  subnet_ids          = [data.aws_ssm_parameter.private_subnet1_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet3_id.value]
  private_dns_enabled = true
  security_group_ids  = [module.security_group_lambda.sg_id]
  tags                = merge(module.tags.tags, local.optional_tags)
}

####################################################################
# IAM role with policy
####################################################################

module "iam_role_rds_auto_start_stop" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.rds_auto_control_service_name}-iam-role"
  aws_service = var.role_service_rds_auto_start_stop
  #AWS_Managed_Policy
  inline_policy = [data.aws_iam_policy_document.inline_policy.json]
  policy_arns   = var.iam_policy_arns_rds_auto_start_stop
  tags          = merge(module.tags.tags, local.optional_tags)
}



#########################################
# Security-group for Lambda Function
#########################################

module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = "${var.rds_auto_control_service_name}-sg"
  description = var.lambda_sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  cidr_ingress_rules = [{
    from             = local.ingress_lambda[0].port,
    to               = local.ingress_lambda[0].port,
    protocol         = local.ingress_lambda[0].protocol,
    cidr_blocks      = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "Lambda python backend ingress rules for port ${local.ingress_lambda[0].port}"
    },
    {
      from             = local.ingress_lambda[1].port,
      to               = local.ingress_lambda[1].port,
      protocol         = local.ingress_lambda[1].protocol,
      cidr_blocks      = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Lambda python backend ingress rules for port ${local.ingress_lambda[1].port}"
  }]

  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "Lambda python backend egress rules"
  }]

  tags = merge(module.tags.tags, local.optional_tags)
}

