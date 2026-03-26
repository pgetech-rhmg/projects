/*
 * # AWS Step Functions Standard Workflow Example
*/
#
#  Filename    : aws/modules/step-functions/examples/standard_workflow/main.tf
#  Date        : 17 Oct 2022
#  Author      : TCS
#  Description : The terraform example creates a step-functions standard workflow


locals {
  name = "${var.name}-${random_string.name.result}"
  Order = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
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
  Order              = local.Order
}

#########################################
# Supporting Resources
#########################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_subnet" "subnet_id1_cidr" {
  id = data.aws_ssm_parameter.subnet_id1.value
}


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
#module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.0"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = var.aws_role
#  kms_role    = var.kms_role
#  policy      = templatefile("${path.module}/policy.json", { cloudwatch_log_name_prefix = var.cloudwatch_log_name_prefix })
# }



#########################################

#Provides a Step Function State Machine with Standard workflow
module "standard_workflow" {
  source = "../.."

  state_machine_definition      = templatefile("${path.module}/${var.state_machine_definition}", { lambda_arn = module.lambda_function.lambda_arn })
  state_machine_name            = local.name
  state_machine_role_arn        = module.aws_state_machine_iam_role.arn
  log_destination               = module.cloudwatch_log-group.cloudwatch_log_group_arn
  tracing_configuration_enabled = var.tracing_configuration_enabled
  kms_key_id                    = var.kms_key_id
  kms_key_type                  = var.kms_key_type
  publish                       = var.publish
  tags                          = merge(module.tags.tags, var.optional_tags)
}

########################################

#Provides a cloud watch log group for the state Machine log_destination
module "cloudwatch_log-group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.1"

  name_prefix = var.cloudwatch_log_name_prefix
  tags        = module.tags.tags
  kms_key_id  = null  # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
}

########################################

#provides a lambda function for the state_machine_definition
module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = local.name
  role          = module.aws_lambda_iam_role.arn
  runtime       = var.runtime
  source_code = {
    source_dir = "${path.module}/${var.local_zip_source_directory}"
  }
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
  tags                          = merge(module.tags.tags, var.optional_tags)
}

###########################################

#provides a security group for the lambda function 
module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

###########################################

#provides iam role for the lambda function 
module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.lambda_iam_role_name
  aws_service = var.lambda_iam_aws_service
  tags        = merge(module.tags.tags, var.optional_tags)
  #AWS_Managed_Policy
  policy_arns = var.lambda_iam_policy_arns
}

############################################

#provides iam role for the state_machine
module "aws_state_machine_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.state_machine_iam_role_name
  aws_service = var.state_machine_iam_aws_service
  tags        = merge(module.tags.tags, var.optional_tags)
  #AWS_Managed_Policy
  policy_arns = var.state_machine_iam_policy_arns
}

#########################################

#provides a vpc_endpoint
module "vpc_endpoint" {
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version = "0.1.1"

  service_name        = var.service_name
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  subnet_ids          = [data.aws_ssm_parameter.subnet_id1.value]
  private_dns_enabled = var.private_dns_enabled
  security_group_ids  = [module.vpce_security_group.sg_id]
  tags                = merge(module.tags.tags, var.optional_tags)
}

#########################################

#provides the security group for vpc_endpoint
module "vpce_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name   = var.vpce_security_group_name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_subnet.subnet_id1_cidr.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

