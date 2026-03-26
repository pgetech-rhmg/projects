/*
 * # AWS  Elastic Beanstalk User module example
*/
#
#  Filename    : aws/modules/elastic-beanstalk/examples//main.tf
#  Date        : 14 Oct 2022
#  Author      : TCS
#  Description : The terraform module creates a Elastic Beanstalk  application for python

locals {
  common_name = "${var.name}-${random_string.name.result}"
  Order       = var.Order
}

#To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"

#   name        = "${var.kms_name}-${random_pet.agw.id}"
#   description = var.kms_description
#   policy      = data.template_file.kms_custom_policy.rendered
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }

# Randon string for generating name
resource "random_string" "name" {
  length  = 5
  special = false
  upper   = false
}

# VPC ID from SSM Parameter Store
data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

# Subnet01 from SSM Parameter Store
data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

# Subnet02 from SSM Parameter Store
data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

# Subnet03 from SSM Parameter Store
data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
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

#######################################################################
#Elastic Beanstalk  application for python
#######################################################################

module "elastic_beanstalk_application" {
  source = "../../"

  name = local.common_name
  tags = merge(module.tags.tags, var.optional_tags)
}

module "elastic_beanstalk_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.common_name
  aws_service = var.aws_service
  policy_arns = var.policy_arns
  tags        = merge(module.tags.tags, var.optional_tags)
}

resource "aws_iam_instance_profile" "elastic_beanstalk_instance_profile" {
  name = local.common_name
  role = module.elastic_beanstalk_iam_role.name

  depends_on = [
    module.elastic_beanstalk_iam_role
  ]
}

module "s3_for_logs" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name   = "logs-${local.common_name}"
  force_destroy = true
  policy        = templatefile("${path.module}/${var.template_file_name}", { bucket_name = "logs-${local.common_name}", account_num = var.account_num, aws_role = var.aws_role })
  tags          = merge(module.tags.tags, var.optional_tags)
}

#######################################################################
#Elastic Beanstalk environment
#######################################################################

module "elastic_beanstalk_environment" {
  source = "../../modules/environment"

  name                = local.common_name
  application_name    = module.elastic_beanstalk_application.name
  solution_stack_name = var.environment_solution_stack_name
  version_label       = var.application_version
  asg_settings = {
    vpcid       = data.aws_ssm_parameter.vpc_id.value
    asg_subnets = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  }
  alb_settings = {
    elb_subnets             = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
    elb_logs_s3_bucket_name = module.s3_for_logs.id
    alb_certificate_arn     = module.acm.acm_certificate_arn
  }

  settings = [{
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.elastic_beanstalk_instance_profile.arn
    },
    {
      namespace = "aws:elbv2:loadbalancer"
      name      = "IdleTimeout"
      value     = "10"
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = "t2.medium"
  }]

  tags = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    module.elastic_beanstalk_application_version
  ]
}

#######################################################################
#Elastic Beanstalk  application version for dotnet
#######################################################################

module "elastic_beanstalk_application_version" {
  source = "../../modules/elastic_beanstalk_application_version"

  name         = var.application_version
  application  = module.elastic_beanstalk_application.name
  bucket       = module.s3.id
  key          = aws_s3_object.s3_object.key
  force_delete = var.application_version_force_delete

  tags = merge(module.tags.tags, var.optional_tags)
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = "application-${local.common_name}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, var.optional_tags)
}

resource "aws_s3_object" "s3_object" {
  bucket = module.s3.id
  key    = "python-${var.application_version}.zip"
  source = "${path.module}/${var.application_version_source_zip}"
}

module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name     = local.common_name
  aws_role = var.aws_role
  kms_role = var.aws_role
  tags     = merge(module.tags.tags, var.optional_tags)
}

module "acm" {
  source  = "app.terraform.io/pgetech/acm/aws//modules/acm_import_certificate"
  version = "0.1.2"

  acm_private_key      = tls_private_key.private_key.private_key_pem
  acm_certificate_body = tls_self_signed_cert.self_signed_cert.cert_pem
  tags                 = merge(module.tags.tags, var.optional_tags)
}

resource "tls_private_key" "private_key" {
  algorithm = var.private_key_algorithm
}

resource "tls_self_signed_cert" "self_signed_cert" {
  private_key_pem = tls_private_key.private_key.private_key_pem
  subject {
    common_name  = var.acm_domain_name
    organization = var.organization
  }

  validity_period_hours = var.validity_period_hours

  allowed_uses = var.allowed_uses
}